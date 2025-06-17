{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    azure-cli
    terraform
    terraform-ls
  ];
}
