#!/bin/sh
# Install or upgrade the plasmoid, then restart plasmashell to pick it up.
cd "$(dirname "$0")"
kpackagetool6 -t Plasma/Applet -u package >/dev/null 2>&1 || kpackagetool6 -t Plasma/Applet -i package
