{
  description = "flake for zig development";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.zig.url = "github:mitchellh/zig-overlay";

  outputs = { self, nixpkgs, zig }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {
      # Add dependencies that are only needed for development
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          zigPkgs = zig.packages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ zigPkgs.master pkgs.zls ];
          };
        });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
    };
}
