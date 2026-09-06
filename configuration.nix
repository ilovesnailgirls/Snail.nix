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
  # USER-WIDE PKGS
  users.users."snail" = {
    isNormalUser = true;
    description = "Snail";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
  # SYSTEM-WIDE PKGS
  environment.systemPackages = with pkgs; [
    thunderbird
    heroic
    vesktop
    gearlever
    zapzap
    telegram-desktop
    gnome-tweaks
    qbittorrent
    fetchPkg
    brave
    gpu-screen-recorder
    obs-studio
    kdePackages.qt6ct
    snapshot
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
    wineWow64Packages.stable
    xwayland-satellite
    unstablePkgs.noctalia-shell
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono
    inter
    overpass
  ];
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    package = pkgs.millennium-steam;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  services.flatpak.enable = true;
  # DESKTOP ENVIRONMENTS & DISPLAY MANAGER
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gnome" "gtk" ];
      };
      Plasma = {
        default = [ "kde" "gtk" ];
      };
    };
  };
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_MENU_PREFIX = "plasma-";
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "niri:GNOME";
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
  };
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  };
  programs.gpu-screen-recorder.enable = true;
  # REQUIRED SERVICES FOR NOCTALIA SHELL
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  # INPUT
  services.logind.settings.Login = {
  HandleLidSwitch = "suspend";
  HandleLidSwitchExternalPower = "suspend";
  HandleLidSwitchDocked = "suspend";
  };
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
