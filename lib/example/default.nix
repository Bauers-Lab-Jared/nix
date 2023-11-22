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
    # This will be available as `lib.my-namespace.my-helper-function`.
    #my-helper-function = x: x;

    #my-scope = {
        # This will be available as `lib.my-namespace.my-scope.my-scoped-helper-function`.
        #my-scoped-helper-function = x: x;
    #};
}

#This library will be made available on your flake’s lib output.