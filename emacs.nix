# Custom emacs expression
{ pkgs }:

pkgs.emacsWithPackages (
  epkgs: with epkgs; [
    haskell-mode
    markdown-mode
    monokai-theme
    nix-mode
    ocaml-mode
    reason-mode
    rust-mode
    smex
    systemd
    typescript-mode
    yaml-mode
  ]
)
