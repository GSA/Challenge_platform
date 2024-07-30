{
  lib ? import <lib> {},
  pkgs ? import (fetchTarball channel:nixos-24.05) {}
}:

let

  # define packages to install with special handling for OSX
  basePackages = [
    pkgs.gnumake
    pkgs.gcc
    pkgs.readline
    pkgs.zlib
    pkgs.libxml2
    pkgs.libiconv
    pkgs.libyaml
    pkgs.openssl
    pkgs.curl
    pkgs.netcat-gnu
    pkgs.git

    pkgs.imagemagick
    pkgs.postgresql
    pkgs.redis

    pkgs.ruby_3_2
    pkgs.bundler
    pkgs.nodejs_20
    pkgs.yarn

    # cloud foundry CLI
    pkgs.cloudfoundry-cli
  ];

  inputs = basePackages
    ++ [ pkgs.bashInteractive ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.inotify-tools ]
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
        CoreFoundation
        CoreServices
      ]);

in pkgs.mkShell {
  buildInputs = inputs;
}
