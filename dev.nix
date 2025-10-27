
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.cmake    # Required for Linux builds
  ];

  # Sets environment variables in the workspace
  env = {};

  # Defines scripts for your workspace, like run, test, and install.
  scripts = {};
}
