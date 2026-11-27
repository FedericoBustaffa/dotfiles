#!/usr/bin/env python3
"""Small libnm bridge. Network passwords are received via stdin, never argv."""

import json
import subprocess
import sys

import gi

gi.require_version("NM", "1.0")
from gi.repository import Gio, GLib, NM


SECURITY = getattr(NM, "80211ApSecurityFlags")
AP_FLAGS = getattr(NM, "80211ApFlags")


def security(ap):
    wpa, rsn = ap.get_wpa_flags(), ap.get_rsn_flags()
    flags = wpa | rsn
    if flags & SECURITY.KEY_MGMT_PSK:
        return "WPA2/WPA Personal", "wpa-psk"
    if flags & SECURITY.KEY_MGMT_SAE:
        return "WPA3 Personal", "sae"
    if flags & (SECURITY.KEY_MGMT_802_1X | SECURITY.KEY_MGMT_EAP_SUITE_B_192):
        return "Enterprise", None
    if flags & SECURITY.KEY_MGMT_OWE:
        return "Enhanced Open", "owe"
    if not flags and not ap.get_flags() & AP_FLAGS.PRIVACY:
        return "Open", "open"
    return "Secured", None


def compatible_profiles(device, ap=None):
    profiles = device.get_available_connections()
    return ap.filter_connections(profiles) if ap else profiles


def snapshot(client):
    devices = []
    for device in client.get_devices():
        wifi = isinstance(device, NM.DeviceWifi)
        if not wifi and not isinstance(device, NM.DeviceEthernet):
            continue
        active = device.get_active_connection()
        ip = device.get_ip4_config()
        item = {
            "path": NM.Object.get_path(device), "iface": device.get_iface(), "wifi": wifi,
            "state": device.get_state().value_nick, "profile": active.get_id() if active else "",
            "ip": ip.get_addresses()[0].get_address() if ip and ip.get_addresses() else "",
            "networks": [],
        }
        if wifi:
            current_ap = device.get_active_access_point()
            current_path = current_ap.get_path() if current_ap else None
            for ap in device.get_access_points():
                ssid = ap.get_ssid()
                if not ssid:
                    continue
                label, mode = security(ap)
                profiles = compatible_profiles(device, ap)
                item["networks"].append({
                    "path": ap.get_path(), "name": NM.utils_ssid_to_utf8(ssid.get_data()),
                    "signal": ap.get_strength(), "security": label, "mode": mode,
                    "active": ap.get_path() == current_path,
                    "saved": bool(profiles),
                })
            item["networks"].sort(key=lambda ap: (not ap["active"], not ap["saved"], -ap["signal"]))
            # Show the strongest access point per SSID/security, preferring the active one.
            unique = {}
            for ap in item["networks"]:
                unique.setdefault((ap["name"], ap["security"]), ap)
            item["networks"] = list(unique.values())
        devices.append(item)
    return {"wifiEnabled": client.props.wireless_enabled,
            "wifiHardwareEnabled": client.props.wireless_hardware_enabled, "devices": devices}


def run_async(obj, method, *args):
    loop = GLib.MainLoop()
    cancel = Gio.Cancellable()
    result = None
    failure = None

    def complete(source, reply, _data):
        nonlocal result, failure
        try:
            result = getattr(source, method + "_finish")(reply)
        except GLib.Error as error:
            failure = error
        loop.quit()

    def timeout():
        cancel.cancel()
        return GLib.SOURCE_REMOVE

    deadline = GLib.timeout_add_seconds(12, timeout)
    getattr(obj, method + "_async")(*args, cancel, complete, None)
    loop.run()
    source = loop.get_context().find_source_by_id(deadline)
    if source:
        source.destroy()
    if failure:
        raise failure
    return result


def wait_for_connection(active):
    loop = GLib.MainLoop()

    def finished(*_args):
        if active.get_state() in (NM.ActiveConnectionState.ACTIVATED, NM.ActiveConnectionState.DEACTIVATED):
            loop.quit()

    def timeout():
        loop.quit()
        return GLib.SOURCE_REMOVE

    if active.get_state() not in (NM.ActiveConnectionState.ACTIVATED, NM.ActiveConnectionState.DEACTIVATED):
        handler = active.connect("notify::state", finished)
        deadline = GLib.timeout_add_seconds(25, timeout)
        loop.run()
        source = loop.get_context().find_source_by_id(deadline)
        if source:
            source.destroy()
        active.disconnect(handler)
    if active.get_state() != NM.ActiveConnectionState.ACTIVATED:
        raise ValueError("Could not connect. Check the password, signal, or saved profile and try again.")


def personal_profile(ap, mode, password):
    profile = NM.SimpleConnection.new()
    wireless = NM.SettingWireless.new()
    wireless.set_property("ssid", ap.get_ssid())
    wireless.set_property("mode", "infrastructure")
    profile.add_setting(wireless)
    if mode != "open":
        setting = NM.SettingWirelessSecurity.new()
        setting.set_property("key-mgmt", mode)
        if mode in ("wpa-psk", "sae"):
            if not password or (mode == "wpa-psk" and not NM.utils_wpa_psk_valid(password)):
                raise ValueError("Enter a valid Wi-Fi password.")
            setting.set_property("psk", password)
        profile.add_setting(setting)
    return profile


def action(client, request):
    verb = request["verb"]
    if verb == "radio":
        state = "on" if request["enabled"] else "off"
        result = subprocess.run(["nmcli", "radio", "wifi", state], capture_output=True, text=True, timeout=8)
        if result.returncode:
            raise ValueError(result.stderr.strip() or "Unable to change Wi-Fi power.")
        return

    device = client.get_device_by_path(request["device"])
    if not isinstance(device, (NM.DeviceWifi, NM.DeviceEthernet)):
        raise ValueError("That network adapter is no longer available.")
    if verb == "disconnect":
        run_async(device, "disconnect")
        return
    if verb == "wired" and isinstance(device, NM.DeviceEthernet):
        wait_for_connection(run_async(client, "activate_connection", None, device, None))
        return
    if not isinstance(device, NM.DeviceWifi):
        raise ValueError("This action needs a Wi-Fi adapter.")
    if verb == "scan":
        run_async(device, "request_scan")
        return

    ap = next((ap for ap in device.get_access_points() if ap.get_path() == request.get("ap")), None)
    if not ap:
        raise ValueError("That network is no longer visible. Scan again and retry.")
    profiles = compatible_profiles(device, ap)
    if verb == "forget" and profiles:
        run_async(profiles[0], "delete")
    elif verb == "connect":
        if profiles:
            active = run_async(client, "activate_connection", profiles[0], device, ap.get_path())
        else:
            _, mode = security(ap)
            if mode is None:
                raise ValueError("Use Advanced settings for this network’s security type.")
            profile = personal_profile(ap, mode, request.get("password", ""))
            active = run_async(client, "add_and_activate_connection", profile, device, ap.get_path())
        wait_for_connection(active)
    else:
        raise ValueError("No matching saved connection.")


def main():
    try:
        client = NM.Client.new(None)
        if not client.get_nm_running():
            raise ValueError("NetworkManager is not running.")
        if sys.argv[1:] == ["status"]:
            print(json.dumps(snapshot(client)))
        else:
            action(client, json.loads(sys.stdin.readline()))
            print("{}")
    except (GLib.Error, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(json.dumps({"error": str(error)}))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
