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
    librewolf
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

    # 1. Ensure git safe directory setting for /etc/nixos
    git config --global --add safe.directory /etc/nixos 2>/dev/null || true

    # 2. Stage changes so Nix Flakes can see untracked files
    echo "==> Staging configuration changes..."
    git -C /etc/nixos add -A

    # 3. Rebuild and switch system
    echo "==> Rebuilding NixOS..."
    if ! sudo nixos-rebuild switch "$@"; then
      echo "==> Rebuild failed! Aborting git commit."
      exit 1
    fi

    # 4. Extract current generation number directly from profile symlink
    GEN=$(readlink /nix/var/nix/profiles/system | cut -d'-' -f2)
    BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")

    # 5. Commit and push using current user's SSH keys
    echo "==> Committing and pushing Generation $GEN..."
    if git -C /etc/nixos diff-index --quiet HEAD --; then
      echo "==> No changes detected in Git repository."
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
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  config = {
    common = {
      default = [ "gtk" ];
    };
    niri = {
      default = lib.mkForce [ "gtk" ];
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
  # REQUIRED SERVICES FOR NOCTALIA SHELL
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  # INPUT / LAPTOP
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
