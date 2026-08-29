{ config, lib, pkgs, unstablePkgs, fetchPkg, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  # NIX DAEMON
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # COLLECT GARBAGE
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # USER-WIDE PKGS
  users.users."snail" = {
    isNormalUser = true;
    description = "Snail";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      thunderbird
      heroic
      vesktop
      gearlever
      zapzap
      telegram-desktop
      qbittorrent
    ];
  };

  # SYSTEM-WIDE PKGS
  environment.systemPackages = with pkgs; [
    fetchPkg
    gpu-screen-recorder
    obs-studio
    gnome-music
    snapshot
    nautilus
    ffmpegthumbnailer
    gdk-pixbuf
    webp-pixbuf-loader
    libgsf
    poppler_utils
    evince
    totem
    loupe
    celluloid
    glib
    gsettings-desktop-schemas
    spicetify-cli
    pywal
    iptables
    pywalfox-native
    komikku
    cmatrix
    alacritty
    swayidle
    kdePackages.kate
    kdePackages.dolphin
    kdePackages.plasma-integration
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.polkit-kde-agent-1
    kdePackages.filelight
    kdePackages.partitionmanager
    protonup-qt
    steam-run
    vlc
    gnome-tweaks
    scrcpy
    fastfetch
    git
    appimage-run
    dwarfs
    fuse3
    unzip
    unrar
    file
    psmisc
    squashfuse
    bubblewrap
    fuse-overlayfs
    wineWow64Packages.stable
    xwayland-satellite
    # Noctalia Shell sourced directly from unstable
    unstablePkgs.noctalia-shell
  ];

  # INSECURE PERMITTED PACKAGES
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono
    inter
  ];

  # APPLICATIONS
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # APPIMAGES
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # FLATPAKS
  services.flatpak.enable = true;

  # DESKTOP ENVIRONMENTS & DISPLAY MANAGER
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config = {
      common = {
        default = [ "kde" ];
      };
    };
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_MENU_PREFIX = "plasma-";
  };
  environment.pathsToLink = [ "/libexec" ];
  security.polkit.enable = true;
  programs.niri.enable = true;
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  services.gvfs.enable = true;
  services.gvfs.package = pkgs.gvfs;
  services.desktopManager.plasma6.enable = true;
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "nier-automata";
  };

  # REQUIRED SERVICES FOR NOCTALIA SHELL
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # INPUT / LAPTOP
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "suspend";
  services.logind.lidSwitchDocked = "suspend";

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  # TIMEZONE & LOCALE
  time.timeZone = "Africa/Algiers";
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # HARDWARE & GRAPHICS
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];
  };
  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # AUDIO
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # NETWORKING
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.printing.enable = true;

  # SWAP
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8192;
  } ];

  # BOOTLOADER
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 35;

  # KERNEL
  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = [ "ntfs" ];
}
