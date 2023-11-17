{
    # This is the merged library containing your namespaced library as well as all libraries from
    # your flake's inputs.
    lib,

    # Your flake inputs are also available.
    inputs,

    # Additionally, Snowfall Lib's own inputs are passed. You probably don't need to use this!
    snowfall-inputs,
}:
{
    
    rollupNixFiles = dir: (
        builtins.map 
            (file: (dir + file)) 
            (lib.snowfall-lib.fs.get-non-default-nix-files dir)
    );

}

#This library will be made available on your flake’s lib output.