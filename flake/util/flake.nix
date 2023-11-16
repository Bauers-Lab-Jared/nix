
{
  description = "Utility functions";
  
  outputs = { self, nixpkgs }: (import ./utilFiles {inherit (nixpkgs) lib;});
}
