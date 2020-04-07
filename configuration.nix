# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  emacsCustom = import ./emacs.nix { inherit pkgs; };

  pia = import ./pia.nix { inherit pkgs; };

  rtl8812au = config.boot.kernelPackages.rtl8812au.override {
    stdenv = pkgs.addAttrsToDerivation rec {
      name = "rtl8812au-aircrack-ng-${version}";
      version = "5.1.5+69";
      src = builtins.fetchGit {
        rev = "be92ddcdb2ef989d14bd4ed10d3a40e3259b4e44";
        url = "https://github.com/aircrack-ng/rtl8812au.git";
      };
    } pkgs.stdenv;
  };

  systemPackages = with pkgs; [
    acpitool
    alacritty
    ag
    alsaLib
    alsaPlugins
    alsaUtils
    ansible
    autossh
    awscli
    brave
    compton
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
    jq
    jwhois
    libnotify
    lsof
    maim
    man
    netcat
    nmap
    pcmanfm
    postgresql_11
    pstree
    python3
    ripgrep
    scrot
    sdparm
    stdmanpages
    tcpdump
    telnet
    terminator
    tmux
    tree
    unzip
    vim
    wget
    xclip
    xfontsel
    xlibs.xev
    xlibs.xinput
    xlibs.xmessage
    xlibs.xmodmap
    xmobar
    xorg.xkill
    xpdf
    xscreensaver
    xsel
    zip
    zsh
  ] ++ pia.systemPackages;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "blibberblob";

  # See https://nixos.org/nixos/manual/index.html#sec-networkmanager
  networking.networkmanager.enable = true;

  services.openvpn = {
    inherit (pia) servers;
  };

  # Set the kernel version here
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ rtl8812au ];

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

  services.dbus.enable = true;

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

  # List packages installed in system profile.
  environment.systemPackages = systemPackages;

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
      dejavu_fonts
      ipafont
    ];

    # Below: see https://functor.tokyo/blog/2018-10-01-japanese-on-nixos
    fontconfig.ultimate.enable = true;
    fontconfig.defaultFonts = {
      monospace = [
        "Terminus"
        "Source Code Pro"
        "IPAGothic"
      ];
      sansSerif = [
        "Source Sans Pro"
        "Source Han Sans JP"
        "DejaVu Sans"
        "IPAPGothic"
      ];
      serif = [
        "Source Serif Pro"
        "DejaVu Serif"
        "IPAPMincho"
      ];
    };
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";

    # Below: see https://functor.tokyo/blog/2018-10-01-japanese-on-nixos
    # This enables "fcitx" as your input method editor (IME). This is an
    # easy-to-use IME. It supports many different input methods.
    inputMethod.enabled = "fcitx";

    # This enables "mozc" as an input method in "fcitx".
    inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Enable sudo.
  security.sudo.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.allen = {
    isNormalUser = true;
    home = "/home/allen";
    description = "Allen Nelson";
    extraGroups = ["wheel" "docker" "audio" "networkmanager"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_rsa.pub)
    ];
  };

  users.extraUsers.root.shell = "/run/current-system/sw/bin/zsh";
  # TODO figure this out
  # users.extraUsers.root.ssh.startAgent = true;
}
