{
  description = "Home Manager configuration of dinosaur";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fresh.url = "github:sinelaw/fresh";
  };

  outputs =
    { nixpkgs, home-manager, fresh, ... } @ attrs:
    let
      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = attrs;
      };
    in
    {
      homeConfigurations."dinosaur" = mkHome "x86_64-linux";
      homeConfigurations."droid" = mkHome "aarch64-linux";
    };
}
