# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  networking = {
    hostName = "blibberblob";
    hostId = "f02ca7ee";
    defaultGateway = "10.0.248.1";
    nameservers = [
      "8.8.8.8"
      "4.4.4.4"
    ];
    interfaces.enp3s0.ip4 = [{
      address = "10.0.248.12";
      prefixLength = 22;
    }];
    firewall = {
      allowPing = true;
      allowedTCPPorts = [ 80 8000 8001 8002 8003 ];
    };
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Start up the ssh agent on login
  programs.ssh.startAgent = true;

  # Allows NVidia drivers to be installed
  nixpkgs.config.allowUnfree = true;
  services.xserver = {
    enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
    displayManager.slim.enable = true;
    # Uncomment this if you want i3 instead of xmonad
    # windowManager.i3.enable = true;

    # Comment these lines if you don't want xmonad
    windowManager.xmonad.enable = true;
    windowManager.xmonad.extraPackages = haskellPackages: (
      # Packages that xmonad.hs imports must be included here
      with haskellPackages; [ xmobar xmonad-contrib yeganesh ]);
    windowManager.default = "xmonad";
    xkbOptions = "eurosign:e";
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
  };

  hardware.opengl.driSupport32Bit = true;

  # Allow virtualbox and docker to run
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # Use NTP for system time
  services.ntp.enable = true;

  # Allow zsh to be used.
  programs.zsh.enable = true;

  # Set time zone to chicago
  time.timeZone = "America/Chicago";
  
  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  inherit networking;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    acpitool
    alsaLib
    alsaPlugins
    alsaUtils
    cpufrequtils
    cryptsetup
    curl
    ddrescue
    dmenu
    emacs
    file
    firefoxWrapper
    gitMinimal
    haskellPackages.xmobar
    hdparm
    htop
    irssi
    jwhois
    lsof
    man
    netcat
    nmap
    rxvt_unicode
    scrot
    sdparm
    stdmanpages
    tcpdump
    telnet
    terminator
    tmux
    unzip
    vagrant
    vim
    wget
    xfontsel
    xlibs.xev
    xlibs.xinput
    xlibs.xmessage
    xlibs.xmodmap
    xorg.xkill
    xpdf
    zip
    zsh
  ];

  # Install some fonts
  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      terminus_font
      liberation_ttf
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
      source-han-sans-japanese
      source-han-sans-korean
      source-han-sans-simplified-chinese
      source-han-sans-traditional-chinese
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # NFS for vagrant osx file sharing.
  services.nfs.server.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.anelson = {
    isNormalUser = true;
    home = "/home/anelson";
    description = "Allen Nelson";
    extraGroups = ["wheel"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_adnelson.pub)
    ];
  };
  users.extraUsers.guest = {
    isNormalUser = true;
    home = "/home/guest";
    description = "Guest account";
    shell = "/run/current-system/sw/bin/zsh";
  };
}
