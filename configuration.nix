# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.extraEntries = {
    "ms.conf" = ''
    title Miblowsoft Wandows
    efi /EFI/MICROSOFT/BOOT/BOOTMGFW.EFI
'';
    "mz.conf" = ''
    title Memtest86+
    efi /EFI/memtest86plus/memtest.efi
''; };

  

  networking.hostName = "nixos-gaming"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
  
  # fix udev for via
  services.udev.packages = [ pkgs.via ];
  
  # Enable SSD TRIM timer https://www.reddit.com/r/NixOS/comments/rbzhb1/if_you_have_a_ssd_dont_forget_to_enable_fstrim/
  services.fstrim.enable = true;

  # Enable the windowing system.
  services.xserver.enable = true;
  # services.xserver.displayManager.gdm.wayland = false;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  
  # KDE
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.defaultSession = "plasma";

  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "us";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";
  
  # Temporary fix for fonts in flatpaks https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1767513263
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = with pkgs; [
        #libsForQt5.breeze-qt5  # for plasma
        gnome-themes-extra
      ];
      pathsToLink = [ "/share/icons" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
    
    # Steam NFS
    "/gaming" = {
      device = "nfs.jlh.name:/gaming";
      fsType = "nfs";
      options = [ "nfsvers=4.2" ];
    };
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [ # https://nixos.wiki/wiki/Fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code  # FF programming font, better than cascadia code https://medium.com/@oocx/comparing-the-new-cascadia-code-font-to-fira-code-v2-c2c63dd87098
      fira-code-symbols
      mplus-outline-fonts.githubRelease  # Japanese font
      dina-font  # Bitmap font, might be cool
    ];
  };

  
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gamer = {
    isNormalUser = true;
    description = "Gamer Society";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "docker" ];
    packages = with pkgs; [
      firefox
      bitwarden
      gnome-tweaks
      gnome-shell-extensions
      gnomeExtensions.appindicator
      gnomeExtensions.hide-top-bar
      gnomeExtensions.net-speed-simplified
      xwaylandvideobridge
      r2modman
      ungoogled-chromium
      via
      qmk
      xonotic
      rocmPackages.rocm-smi
      jellyfin-mpv-shim
      mpv
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "gamer";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    memtest86plus
    ark
    wineWowPackages.staging
    wireshark
    cryptsetup
    comma
    gamescope
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.git = {
    enable = true;
  };
  
  hardware.steam-hardware.enable = true;

  # Needed for bluetooth in KDE https://search.nixos.org/options?channel=22.11&show=hardware.bluetooth.enable&from=0&size=50&sort=relevance&type=packages&query=bluetooth
  hardware.bluetooth.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };  


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.xserver.excludePackages = [ pkgs.xterm ];  
  services.flatpak.enable = true;

hardware.opengl = { # enable 32 bit drivers
  driSupport32Bit = true;
};

programs.steam = {
  enable = true;
  gamescopeSession.enable = true;
};

  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
