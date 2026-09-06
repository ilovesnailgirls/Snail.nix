{ config, lib, pkgs, unstablePkgs, fetchPkg, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";

  # NIX DAEMON & SYSTEM CONFIG
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # USER CONFIGURATION
  users.users."snail" = {
    description = "Snail";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    packages = with pkgs; [ ];
  };

  # SYSTEM-WIDE PACKAGES
  environment.systemPackages = with pkgs; [
    alacritty
    appimage-run
    brave
    bubblewrap
    cmatrix
    dwarfs
    fastfetch
    fetchPkg
    file
    fuse-overlayfs
    fuse3
    gearlever
    git
    gnome-tweaks
    heroic
    iptables
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.dolphin
    kdePackages.filelight
    kdePackages.kate
    kdePackages.partitionmanager
    kdePackages.plasma-integration
    kdePackages.polkit-kde-agent-1
    kdePackages.qt6ct
    komikku
    protonup-qt
    psmisc
    pywal
    pywalfox-native
    qbittorrent
    scrcpy
    snapshot
    spicetify-cli
    squashfuse
    steam-run
    swayidle
    telegram-desktop
    thunderbird
    unrar
    unstablePkgs.noctalia-shell
    unzip
    vesktop
    vlc
    wineWow64Packages.stable
    xwayland-satellite
    zapzap

    # DEPLOYMENT GIT
    (writeShellScriptBin "nixos-deploy" ''
      set -e
      git config --global --add safe.directory /etc/nixos 2>/dev/null || true

      echo "Staging configuration changes..."
      git -C /etc/nixos add -A

      echo "Rebuilding NixOS..."
      if ! sudo nixos-rebuild switch "$@"; then
        echo "Rebuild failed! Aborting git commit."
        exit 1
      fi

      GEN=$(readlink /nix/var/nix/profiles/system | cut -d'-' -f2)
      BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")

      echo "Committing and pushing Generation $GEN..."
      if git -C /etc/nixos diff-index --quiet HEAD --; then
        echo "No changes detected in Git repository."
      else
        git -C /etc/nixos commit -m "Generation $GEN ($BUILD_DATE)"
        git -C /etc/nixos push origin main
      fi
    '')
  ];

  # FONTS
  fonts.packages = with pkgs; [
    inter
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono
    overpass
  ];

  # PROGRAMS & APPLICATIONS
  programs.appimage = {
    binfmt = true;
    enable = true;
  };
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.gamemode.enable = true;
  programs.gpu-screen-recorder.enable = true;
  programs.niri.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      wlrobs
    ];
  };
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.millennium-steam;
    remotePlay.openFirewall = true;
  };

  # DESKTOP ENVIRONMENT, DISPLAY MANAGER & XDG PORTALS
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  environment.pathsToLink = [ "/libexec" ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_CURRENT_DESKTOP = "niri:GNOME";
    XDG_MENU_PREFIX = "plasma-";
  };

  security.polkit.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.flatpak.enable = true;
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.xserver.enable = true;

  xdg.portal = {
    config = {
      Plasma = {
        default = [ "kde" "gtk" ];
      };
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gnome" "gtk" ];
      };
    };
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # INPUT & POWER MANAGEMENT
  console.keyMap = "fr";
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # HARDWARE & GRAPHICS
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver ];
  };

  # AUDIO
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    enable = true;
    pulse.enable = true;
  };

  # NETWORKING & PRINTING
  networking.firewall.enable = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  services.printing.enable = true;

  # TIMEZONE & LOCALE
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
  time.timeZone = "Africa/Algiers";

  # SWAP & STORAGE
  boot.supportedFilesystems = [ "ntfs" ];
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8192;
  } ];

  # BOOTLOADER & KERNEL
  boot.kernelPackages = pkgs.linuxPackages;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 35;
  boot.loader.systemd-boot.enable = true;
}
