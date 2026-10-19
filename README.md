# GPU Status

KDE Plasma 6 system tray widget showing NVIDIA dGPU power state.

- **nv** (bold, red) — GPU is `active`
- **in** — GPU is suspended (integrated graphics in use)
- Hover — tooltip with `fuser -v /dev/nvidia*` (processes using the GPU)
- Click — refresh immediately and show the process list in a popup

Status is read every 2 seconds from
`/sys/bus/pci/devices/0000:01:00.0/power/runtime_status`, which does not wake
the GPU. If your GPU has a different PCI address, change `statusCmd` in
`package/contents/ui/main.qml`.

## Install / upgrade

```sh
./install.sh
systemctl --user restart plasma-plasmashell
```

`install.sh` installs the widget if it's missing and upgrades it if it's already installed.

On a fresh install, enable it in the tray: right-click the tray →
**Configure System Tray…** → **Entries** → **GPU Status** → **Always shown**.
Upgrades keep this setting.

## Uninstall

```sh
kpackagetool6 -t Plasma/Applet -r org.sv.gpustatus
```

## Waking the GPU for testing

```sh
nvidia-smi                 # wakes it for a few seconds
prime-run glxgears         # keeps it active while the window is open (needs nvidia-prime, mesa-utils)
sleep 30 < /dev/nvidia0    # holds the device open for 30 seconds (untested)
```

Force it on with no process (root); set it back to `auto` afterwards:

```sh
echo on   | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control
echo auto | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control
```

After the last process exits, the GPU stays active for a few seconds before
suspending.

## Notes

- Run as your normal user, `fuser` lists only your own processes. Processes
  owned by root or other users (e.g. Xorg) won't appear in the tooltip.
- To test without restarting plasmashell, install `plasma-sdk` and run
  `plasmoidviewer -a org.sv.gpustatus`.
