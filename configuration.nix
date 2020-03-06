# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let emacsCustom = with pkgs; emacsWithPackages (
  epkgs: with epkgs; [
    monokai-theme
    smex
    nix-mode
    haskell-mode
    reason-mode
    rust-mode
  ]
);

  networking = {
    hostName = "blibberblob";
    # hostId = "f02ca7ee";
    # defaultGateway = "10.0.248.1";
    # nameservers = [
    #   # Google DNS
    #   "8.8.8.8" "8.8.4.4"
    #   # Level 3 DNS
    #   "4.2.2.1" "4.2.2.2" "4.2.2.3" "4.2.2.4"
    # ];
    # firewall = {
    #   allowPing = true;
    #   allowedTCPPorts = [ 80 8000 8001 8002 8003 ];
    # };
    # interfaces.enp0s31f6.ip4 = [{
    #   address = "10.0.248.12";
    #   prefixLength = 22;
    # }];
    # wireless.enable = true;
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  inherit networking;

  # Set the kernel version here
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Start up the ssh agent on login
  programs.ssh.startAgent = true;

  # Allows NVidia drivers to be installed
  nixpkgs.config.allowUnfree = true;
  services.xserver = {
    # Set autorun = false if you want to manually start X
    # autorun = false;
    enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
    displayManager.lightdm.enable = true;
    # windowManager.i3.enable = true;
    windowManager.xmonad.enable = true;
    windowManager.xmonad.extraPackages = (ps: [ps.xmobar ps.xmonad-contrib]);
    windowManager.default = "xmonad";
    xkbOptions = "eurosign:e";
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;
  };

  # Uncomment to enable opengl
  # hardware.opengl.driSupport32Bit = true;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Allow virtualbox and docker to run
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = false;
  virtualisation.docker.enable = true;

  # Use NTP for system time
  services.ntp.enable = true;

  # Allow zsh to be used.
  programs.zsh.enable = true;

  # Set time zone to Chicago
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    acpitool
    ag
    alsaLib
    alsaPlugins
    alsaUtils
    ansible
    awscli
    cpufrequtils
    cryptsetup
    curl
    ddrescue
    dmenu
    emacsCustom
    feh
    file
    firefoxWrapper
    gitMinimal
    hdparm
    htop
    irssi
    jwhois
    lsof
    man
    netcat
    nmap
    postgresql_11
    python3
    rxvt_unicode
    scrot
    sdparm
    stdmanpages
    tcpdump
    telnet
    terminator
    tmux
    unzip
    vim
    wget
    xfontsel
    xlibs.xev
    xlibs.xinput
    xlibs.xmessage
    xlibs.xmodmap
    xorg.xkill
    xpdf
    xsel
    xclip
    zip
    zsh
    pcmanfm
  ];

  # Install some fonts
  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      gohufont
      inconsolata
      liberation_ttf
      source-code-pro
      source-han-sans-japanese
      source-han-sans-korean
      source-han-sans-simplified-chinese
      source-han-sans-traditional-chinese
      source-sans-pro
      source-serif-pro
      terminus_font
      ubuntu_font_family
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable sudo.
  security.sudo.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.allen = {
    isNormalUser = true;
    home = "/home/allen";
    description = "Allen Nelson";
    extraGroups = ["wheel" "docker" "audio"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_rsa.pub)
    ];
  };

  users.extraUsers.root.shell = "/run/current-system/sw/bin/zsh";
  # TODO figure this out
  # users.extraUsers.root.ssh.startAgent = true;
}
