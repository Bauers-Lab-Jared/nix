{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # You also have access to your flake's inputs.
    inputs,

    # All other arguments come from NixPkgs. You can use `pkgs` to pull packages or helpers
    # programmatically or you may add the named attributes as arguments here.
    pkgs,
    stdenv,
    ...
}:

stdenv.mkDerivation {
    # Create your package
    # Rename the file to "default.nix"
}

#This package will be made available on your flake’s packages output
# with the same name as the directory that you created.