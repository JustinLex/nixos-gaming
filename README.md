# nixos-gaming
NixOS configuration for my gaming computer

To apply configuration, run `sudo nixos-rebuild switch -I nixos-config=configuration.nix`

## Nice benefits with Linux gaming

* htop gives much more information about system performance than Task Manager
* No background Windows Defender stealing performance
* Bluetooth connects faster and seems to not have major hardware issues like Windows
* OS and apps start faster
* Gnome has a nicer interface, the taskbar actually hides, and the Activities overlay is really nice to use
* Gnome settings are much nicer and usable than Windows settings
* I can install and configure a lot of things through Nix, which makes it easier to maintain my gaming computer
* Discord notifications actually tell you who messaged
* Just much less weird background shit running
* Much less tweaking needed for an optimal experience, no Cortana/ads to disable, no 3rd party junk to install


## Known bugs for Linux gaming

### General issues

* AMD's open-source driver does not support HDMI 2.1 for legal reasons, restricting my LG OLED to 4:2:0 Limited color
* Linux does not support HDR
* No GUI for disabling audio devices in Wireplumber as far as I know

### Issues specific to Wayland

* Games like Satisfactory lock to 60fps under vsync, even though Wayland and X11 correctly enable freesync. League of Legends runs fine, but it might be locking to 120fps.
  * Might be caused by multi-monitor
  * This might help: https://zamundaaa.github.io/wayland/2021/12/14/about-gaming-on-wayland.html
* Satisfactory crashes on startup in some situations
* League of Legends prevents Gnome from switching to different desktops
* Discord does not support streaming an entire screen
* Webcord does not show full-screen apps when streaming
* Firefox crashes when trying to stream to Discord

### Issues specific to X11

* League of legends stutters
* League of Legends resets display settings, making my secondary monitor go sideways
* League of legends prevent my mouse from going to my secondary monitor, even when alt-tabbed
* Alt key gets stuck in League of Legends after alt-tab
* Discord streaming has high CPU usage (~1 core)
