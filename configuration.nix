# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  networking = {
    hostName = "blibberblob";
    hostId = "f02ca7ee";
    defaultGateway = "10.0.248.1";
    nameservers = [ "8.8.8.8" "4.4.4.4" ];
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

  # Allows NVidia drivers to be installed
  nixpkgs.config.allowUnfree = true;
  services.xserver = {
    enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
    windowManager.i3.enable = true;
    xkbOptions = "eurosign:e";
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
  };

  hardware.opengl.driSupport32Bit = true;

  # Allow virtualbox to run
  services.virtualboxHost.enable = true;

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
    firefoxWrapper
    acpitool
    alsaLib
    alsaPlugins
    alsaUtils
    cpufrequtils
    cryptsetup
    ddrescue
    dmenu
    file
    hdparm
    htop
    keychain
    sdparm
    zsh
    irssi
    gitMinimal
    i3
    jwhois
    lsof
    man
    netcat
    nmap
    vagrant
    tmux
    stdmanpages
    tcpdump
    telnet
    zip
    unzip
    vim
    emacs
    vlc
    wget
    rxvt_unicode
    xorg.xkill
    xpdf
    xfontsel
    xlibs.xev
    xlibs.xinput
    xlibs.xmessage
    xlibs.xmodmap
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
    ];
  };
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
    authorizedKeys = [
      builtins.readFile ./id_adnelson.pub
    ];
  };
}
