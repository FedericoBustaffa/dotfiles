#!/usr/bin/env bash

for hwmon in /sys/class/hwmon/hwmon*; do
    name_file="$hwmon/name"
    [[ -r "$name_file" ]] || continue

    name=$(<"$name_file")
    [[ "$name" == "coretemp" ]] || continue

    # Cerca la temperatura del package (preferita)
    for temp in "$hwmon"/temp*_input; do
        label="${temp/_input/_label}"

        if [[ -r "$label" ]] && grep -q "Package" "$label"; then
            value=$(<"$temp")
            echo " $((value / 1000))°C"
            exit 0
        fi
    done

    # Fallback: primo valore valido
    for temp in "$hwmon"/temp*_input; do
        [[ -r "$temp" ]] || continue
        value=$(<"$temp")

        if (( value > 20000 && value < 120000 )); then
            echo "$((value / 1000))°C"
            exit 0
        fi
    done
done
