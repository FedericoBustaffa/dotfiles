#!/usr/bin/env bash
# One status snapshot shared by all screens. Omit unavailable readings.
export LC_ALL=C

cpu_sample() {
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    printf '%s %s\n' "$((user + nice + system + idle + iowait + irq + softirq + steal))" "$((idle + iowait))"
}

read -r total idle < <(cpu_sample)
sleep 0.15
read -r next_total next_idle < <(cpu_sample)
if ((next_total > total)); then
    printf 'cpu=%d%%\n' "$((100 * (next_total - total - next_idle + idle) / (next_total - total)))"
fi

awk '/^MemTotal:/ { total=$2 } /^MemAvailable:/ { available=$2 }
    END { if (total) {
        used = total - available
        printf "memory=%.0f%%\nmemoryUsed=%.1f GB\n", 100 * used / total, used * 1024 / 1e9
    } }' /proc/meminfo
df -kP / | awk 'NR == 2 { printf "disk=%s\ndiskUsed=%.1f GB\n", $5, $3 * 1024 / 1e9 }'

for hwmon in /sys/class/hwmon/hwmon*; do
    [[ -r "$hwmon/name" ]] || continue
    case $(<"$hwmon/name") in coretemp|k10temp|zenpower) ;; *) continue ;; esac
    for sensor in "$hwmon"/temp*_input; do
        [[ -r "$sensor" ]] || continue
        temp=$(<"$sensor")
        if [[ "$temp" =~ ^[0-9]+$ ]] && ((temp > 0)); then
            printf 'temp=%d°C\n' "$((temp / 1000))"
            break 2
        fi
    done
done

nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '
    $2 == "connected" && $1 == "wifi" { wifi=1 }
    $2 == "connected" && $1 == "ethernet" { ethernet=1 }
    END { if (NR) print "network=" (wifi ? "Wi-Fi" : ethernet ? "Wired" : "Offline") }'
if profiles=$(LC_ALL=C powerprofilesctl list 2>/dev/null); then
    awk '/^[* ]+[a-z-]+:$/ {
        name = $0; sub(/^[* ]+/, "", name); sub(/:$/, "", name)
        if ($0 ~ /^\*/) print "profile=" name
        list = list (list ? "," : "") name
    } END { if (list) print "profiles=" list }' <<< "$profiles"
fi
for device in /sys/class/power_supply/*; do
    [[ -r "$device/type" && -r "$device/capacity" && $(<"$device/type") == Battery ]] || continue
    printf 'battery=%s%%\n' "$(<"$device/capacity")"
    break
done
exit 0
