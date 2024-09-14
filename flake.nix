{
  description = "My nix flake templates";

  outputs = {...}: {
    templates = {
      rust = {
        path = ./templates/rust;
        description = "nix flake new -t github:x3rAx/flakify#rust .";
      };
    };
  };
}
