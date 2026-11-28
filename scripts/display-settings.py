#!/usr/bin/env python3
"""Edit the active Hyprland display layout and save it as machine-local Lua."""

import json
import math
import os
from pathlib import Path
import re
import subprocess
import tempfile
from dataclasses import dataclass

import gi

gi.require_version("Gtk", "4.0")
gi.require_foreign("cairo")
from gi.repository import Gio, GLib, Gtk


MODE = re.compile(r"(\d+)x(\d+)@([\d.]+)(?:Hz)?$")


def hypr(*args):
    return subprocess.check_output(["hyprctl", *args], text=True, stderr=subprocess.STDOUT, timeout=4).strip()


def monitors():
    return {output["name"]: output for output in json.loads(hypr("monitors", "all", "-j"))}


@dataclass
class Display:
    name: str
    modes: list
    mode: str
    scale: float
    transform: int
    x: int
    y: int

    @classmethod
    def from_output(cls, output):
        width, height = output["width"], output["height"]
        modes = list(dict.fromkeys(mode.removesuffix("Hz") for mode in output["availableModes"] if MODE.fullmatch(mode)))
        refresh = output["refreshRate"]
        mode = f"{width}x{height}@{refresh:g}"
        matches = [candidate for candidate in modes if dimensions(candidate)[:2] == (width, height)]
        if matches:
            nearest = min(matches, key=lambda candidate: abs(dimensions(candidate)[2] - refresh))
            if abs(dimensions(nearest)[2] - refresh) < 0.06:
                mode = nearest
        if mode not in modes:
            modes.insert(0, mode)
        return cls(output["name"], modes, mode, output["scale"], output["transform"], output["x"], output["y"])

    @property
    def size(self):
        width, height, _ = dimensions(self.mode)
        if self.transform % 2:
            width, height = height, width
        return round(width / self.scale), round(height / self.scale)

    @property
    def rect(self):
        return self.x, self.y, *self.size


def dimensions(mode):
    w, h, rate = MODE.fullmatch(mode).groups()
    return int(w), int(h), float(rate)


def scales(mode, current):
    w, h, _ = dimensions(mode)
    values = {step / 120 for step in range(60, 481) if not (w * 120 % step or h * 120 % step)}
    if all(abs(side / current - round(side / current)) < 0.02 for side in (w, h)):
        values.add(current)
    return sorted(values)


def overlap(a, b):
    x, y, w, h = a
    u, v, s, t = b
    return min(x + w, u + s) - max(x, u), min(y + h, v + t) - max(y, v)


def share_edge(a, b):
    horizontal, vertical = overlap(a, b)
    return (horizontal == 0 and vertical > 0) or (vertical == 0 and horizontal > 0)


def connected(rects):
    if not rects:
        return True
    reached = {0}
    while True:
        adjoining = {i for i, rect in enumerate(rects) for j in reached
                     if share_edge(rect, rects[j])}
        if adjoining <= reached:
            return len(reached) == len(rects)
        reached |= adjoining


def snap(display, others, want_x, want_y):
    """Find the nearest nonoverlapping placement with a shared edge."""
    if not others:
        return display.x, display.y
    w, h = display.size
    align_x = {p for x, _, width, _ in others for p in (x, x + width - w)}
    align_y = {p for _, y, _, height in others for p in (y, y + height - h)}
    x_options = align_x | {round(want_x)} | {p for x, _, width, _ in others for p in (x - w, x + width)}
    y_options = align_y | {round(want_y)} | {p for _, y, _, height in others for p in (y - h, y + height)}
    candidates = {}
    for x, y, width, height in others:
        for edge in (x - w, x + width):
            for option in y_options:
                v = max(y - h + 1, min(y + height - 1, option))
                aligned = v in align_y
                pos = edge, v
                score = (edge - want_x) ** 2 + (v - want_y) ** 2 - (48 ** 2 if aligned else 0)
                candidates[pos] = min(candidates.get(pos, score), score)
        for edge in (y - h, y + height):
            for option in x_options:
                u = max(x - w + 1, min(x + width - 1, option))
                aligned = u in align_x
                pos = u, edge
                score = (u - want_x) ** 2 + (edge - want_y) ** 2 - (48 ** 2 if aligned else 0)
                candidates[pos] = min(candidates.get(pos, score), score)
    for x, y in sorted(candidates, key=lambda p: (candidates[p], p)):
        rect = x, y, w, h
        if not any(min(overlap(rect, other)) > 0 for other in others) and connected([*others, rect]):
            return x, y
    return display.x, display.y


def atomic_write(path, data):
    if data is None:
        path.unlink(missing_ok=True)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as tmp:
        try:
            tmp.write(data)
            tmp.close()
            os.replace(tmp.name, path)
        finally:
            Path(tmp.name).unlink(missing_ok=True)


def lua_layout(displays, disabled):
    lines = ["-- Machine-local layout generated by Display settings."]
    for display in displays:
        lines.append(f"hl.monitor({{ output = {json.dumps(display.name)}, mode = {json.dumps(display.mode)}, "
                     f'position = "{display.x}x{display.y}", scale = {display.scale:.12g}, transform = {display.transform} }})')
    lines.extend(f"hl.monitor({{ output = {json.dumps(name)}, disabled = true }})" for name in disabled)
    lines.append('hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })')
    return ("\n".join(lines) + "\n").encode()


class Settings(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Display settings", default_width=660, default_height=420)
        self.path = (Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config") / "hypr/monitors.lua").resolve()
        self.preview = None
        self.drag = None
        self.updating = False
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=16, margin_bottom=16,
                      margin_start=16, margin_end=16)
        self.set_child(box)
        box.append(Gtk.Label(label="Drag displays to rearrange them. Edges snap together.", xalign=0))
        self.canvas = Gtk.DrawingArea(content_width=540, content_height=250, vexpand=True)
        self.canvas.set_draw_func(self.draw)
        box.append(self.canvas)
        gesture = Gtk.GestureDrag()
        gesture.connect("drag-begin", self.drag_begin)
        gesture.connect("drag-update", self.drag_update)
        gesture.connect("drag-end", self.drag_end)
        self.canvas.add_controller(gesture)

        controls = Gtk.Box(spacing=10)
        box.append(controls)
        self.selectors = [Gtk.DropDown() for _ in range(3)]
        for label, selector in zip(("Display", "Resolution / refresh", "Scale"), self.selectors):
            field = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5, hexpand=True)
            field.append(Gtk.Label(label=label, xalign=0))
            field.append(selector)
            controls.append(field)
            selector.connect("notify::selected", self.selection_changed)
        self.status = Gtk.Label(xalign=0, wrap=True)
        box.append(self.status)
        actions = Gtk.Box(spacing=8, halign=Gtk.Align.END)
        box.append(actions)
        reset = Gtk.Button(label="Reset")
        reset.connect("clicked", lambda *_: self.load())
        actions.append(reset)
        self.apply_button = Gtk.Button(label="Apply")
        self.apply_button.add_css_class("suggested-action")
        self.apply_button.connect("clicked", self.apply)
        actions.append(self.apply_button)
        self.connect("close-request", self.close_requested)
        self.load()

    def load(self, message=""):
        try:
            self.outputs = monitors()
            self.displays = [Display.from_output(output) for output in self.outputs.values() if not output["disabled"]]
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            self.displays = []
            message = str(error)
        self.selected = 0
        if self.displays and not self.valid_layout():
            self.reflow(self.displays[0])
        self.refresh_controls(update_displays=True)
        self.status.set_label(message or ("" if self.displays else "No active displays found."))
        self.apply_button.set_sensitive(bool(self.displays))
        self.canvas.queue_draw()

    def refresh_controls(self, *, update_displays=False, update_modes=True):
        self.updating = True
        display, mode, scale = self.selectors
        if update_displays:
            display.set_model(Gtk.StringList.new([output.name for output in self.displays]))
        if self.displays:
            if display.get_selected() != self.selected:
                display.set_selected(self.selected)
            output = self.displays[self.selected]
            if update_modes:
                mode.set_model(Gtk.StringList.new([item.replace("@", " @ ") + " Hz" for item in output.modes]))
                mode.set_selected(output.modes.index(output.mode))
            self.scale_options = scales(output.mode, output.scale)
            scale.set_model(Gtk.StringList.new([f"{item * 100:.4g}%" for item in self.scale_options]))
            scale.set_selected(self.scale_options.index(output.scale) if output.scale in self.scale_options else Gtk.INVALID_LIST_POSITION)
        else:
            mode.set_model(None)
            scale.set_model(None)
        self.updating = False

    def selection_changed(self, selector, _):
        if self.updating or not self.displays or selector.get_selected() == Gtk.INVALID_LIST_POSITION:
            return
        value = selector.get_selected()
        display, mode, _ = self.selectors
        if selector == display:
            self.selected = value
            self.refresh_controls()
        else:
            output = self.displays[self.selected]
            if selector == mode:
                output.mode = output.modes[value]
                output.scale = min(scales(output.mode, output.scale), key=lambda scale: abs(output.scale - scale))
                # Replacing a dropdown's own model from its selection signal re-enters GTK.
                self.refresh_controls(update_modes=False)
            else:
                output.scale = self.scale_options[value]
            if not self.valid_layout():
                self.reflow(output)
        self.canvas.queue_draw()

    def valid_layout(self):
        rects = [output.rect for output in self.displays]
        return connected(rects) and not any(min(overlap(rect, other)) > 0
                                            for i, rect in enumerate(rects) for other in rects[:i])

    def reflow(self, anchor):
        placed = [anchor.rect]
        others = sorted((output for output in self.displays if output is not anchor),
                        key=lambda output: math.hypot(output.x - anchor.x, output.y - anchor.y))
        for output in others:
            output.x, output.y = snap(output, placed, output.x, output.y)
            placed.append(output.rect)

    def viewport(self, width, height):
        rects = [output.rect for output in self.displays]
        left, top = min(x for x, _, _, _ in rects), min(y for _, y, _, _ in rects)
        span_x = max(x + w for x, _, w, _ in rects) - left
        span_y = max(y + h for _, y, _, h in rects) - top
        zoom = min(max(1, width - 120) / span_x, max(1, height - 70) / span_y)
        return zoom, (width - span_x * zoom) / 2 - left * zoom, (height - span_y * zoom) / 2 - top * zoom

    def draw(self, _, cr, width, height):
        cr.set_source_rgb(0.08, 0.09, 0.10)
        cr.paint()
        if not self.displays:
            return
        zoom, ox, oy = self.drag[3] if self.drag else self.viewport(width, height)
        for index, output in enumerate(self.displays):
            x, y, w, h = output.rect
            x, y, w, h = x * zoom + ox, y * zoom + oy, w * zoom, h * zoom
            selected = index == self.selected
            cr.rectangle(x, y, w, h)
            cr.set_source_rgb(*((0.14, 0.29, 0.23) if selected else (0.16, 0.18, 0.20)))
            cr.fill_preserve()
            cr.set_source_rgb(*((0.47, 0.82, 0.65) if selected else (0.37, 0.40, 0.43)))
            cr.set_line_width(2 if selected else 1)
            cr.stroke()
            cr.save()
            cr.rectangle(x, y, w, h)
            cr.clip()
            cr.set_font_size(15)
            cr.set_source_rgb(0.92, 0.94, 0.95)
            extents = cr.text_extents(output.name)
            cr.move_to(x + (w - extents.width) / 2 - extents.x_bearing, y + h / 2 + 5)
            cr.show_text(output.name)
            cr.restore()

    def drag_begin(self, gesture, px, py):
        if not self.displays:
            return
        view = self.viewport(self.canvas.get_width(), self.canvas.get_height())
        zoom, ox, oy = view
        x, y = (px - ox) / zoom, (py - oy) / zoom
        for index, output in enumerate(self.displays):
            u, v, w, h = output.rect
            if u <= x < u + w and v <= y < v + h:
                self.selected = index
                self.drag = output, u, v, view
                gesture.set_state(Gtk.EventSequenceState.CLAIMED)
                self.refresh_controls()
                self.canvas.queue_draw()
                break

    def drag_update(self, _, dx, dy):
        if self.drag:
            output, x, y, (zoom, _, _) = self.drag
            output.x, output.y = snap(output, [other.rect for other in self.displays if other is not output],
                                      x + dx / zoom, y + dy / zoom)
            self.canvas.queue_draw()

    def drag_end(self, *args):
        self.drag = None
        self.canvas.queue_draw()

    def apply(self, *_):
        try:
            if monitors().keys() != self.outputs.keys():
                self.load("Connected displays changed. Please review the new layout.")
                return
            old_errors = hypr("configerrors")
            original = self.path.read_bytes() if self.path.exists() else None
            disabled = [name for name in self.outputs if self.outputs[name]["disabled"]]
            atomic_write(self.path, lua_layout(self.displays, disabled))
            self.preview = {"original": original, "timer": 0, "dialog": None}
            if hypr("reload") != "ok":
                raise RuntimeError("Hyprland could not reload the layout.")
        except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
            self.finish(False, str(error))
            return
        self.set_sensitive(False)
        self.preview["timer"] = GLib.timeout_add(800, self.confirm, old_errors)

    def confirm(self, old_errors):
        self.preview["timer"] = 0
        try:
            outputs = monitors()
            errors = hypr("configerrors")
            if errors and errors != old_errors:
                raise RuntimeError(errors)
            for display in self.displays:
                actual = outputs.get(display.name, {})
                w, h, rate = dimensions(display.mode)
                if (actual.get("disabled", True) or (actual["x"], actual["y"], actual["width"], actual["height"])
                        != (display.x, display.y, w, h) or abs(actual["scale"] - display.scale) > 0.011
                        or abs(actual["refreshRate"] - rate) > 0.15):
                    raise RuntimeError(f"Hyprland did not apply the requested settings for {display.name}.")
        except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
            self.finish(False, str(error))
            return GLib.SOURCE_REMOVE
        dialog = Gtk.Dialog(title="Keep this display layout?", transient_for=self, modal=True)
        dialog.add_button("Revert", Gtk.ResponseType.CANCEL)
        dialog.add_button("Keep changes", Gtk.ResponseType.ACCEPT)
        label = Gtk.Label(margin_top=18, margin_bottom=18, margin_start=18, margin_end=18)
        dialog.get_content_area().append(label)
        dialog.connect("response", lambda _, response: self.finish(response == Gtk.ResponseType.ACCEPT))
        self.preview["dialog"] = dialog
        deadline = GLib.get_monotonic_time() + 15_000_000

        def tick():
            remaining = math.ceil((deadline - GLib.get_monotonic_time()) / 1_000_000)
            if remaining <= 0:
                self.preview["timer"] = 0
                self.finish(False)
                return GLib.SOURCE_REMOVE
            label.set_label(f"The previous layout will be restored in {remaining} seconds.")
            return GLib.SOURCE_CONTINUE

        tick()
        self.preview["timer"] = GLib.timeout_add(250, tick)
        dialog.present()
        return GLib.SOURCE_REMOVE

    def finish(self, keep, error=""):
        preview, self.preview = self.preview, None
        if preview:
            if preview["timer"]:
                GLib.source_remove(preview["timer"])
            if preview["dialog"]:
                preview["dialog"].destroy()
            if not keep:
                try:
                    atomic_write(self.path, preview["original"])
                    if hypr("reload") != "ok":
                        raise RuntimeError("Hyprland did not reload the previous layout.")
                except (OSError, RuntimeError, subprocess.SubprocessError) as restore_error:
                    error = f"Could not restore the previous layout: {restore_error}"
        self.set_sensitive(True)
        self.load(error or ("Display layout saved." if keep else "Previous layout restored."))

    def close_requested(self, *_):
        if self.preview:
            self.finish(False)
        return False


if __name__ == "__main__":
    app = Gtk.Application(application_id="io.github.dotfiles.DisplaySettings", flags=Gio.ApplicationFlags.DEFAULT_FLAGS)
    app.connect("activate", lambda app: (app.get_active_window() or Settings(app)).present())
    app.run()
