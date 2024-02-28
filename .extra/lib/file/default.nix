{ lib, ... }:

rec {
  ## Append text to the contents of a file
  ##
  ## ```nix
  ## fileWithText ./some.txt "appended text"
  ## ```
  ##
  #@ Path -> String -> String
  fileWithText = file: text: ''
    ${builtins.readFile file}
    ${text}'';

  ## Prepend text to the contents of a file
  ##
  ## ```nix
  ## fileWithText' ./some.txt "prepended text"
  ## ```
  ##
  #@ Path -> String -> String
  fileWithText' = file: text: ''
    ${text}
    ${builtins.readFile file}'';


    ###### extra
    nixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
                           (filterAttrs (name: _: hasSuffix ".nix" name)
                                        (readDir dir));
    
    dirsToAttrs = dir: mapAttrs (n: v: if v == "regular" || v == "symlink"
                                      then  dir + "/${n}"
                                      else dirsToAttrs (dir + "/${n}"))
                            (readDir dir);

    nixFilesToList = dir: let
        recur = dir: acc: thisDirAttrs:
            acc ++ flatten (attrsets.mapAttrsToList ((acc: name: value:
            let
                newPath = dir + "/${name}";
                newName = (strings.removeSuffix ".nix" name);
            in
                if value == "regular" || value == "symlink" then
                    nameValuePair newName (toString newPath)
                else
                    recur newPath acc (readDir newPath)
            ) acc) thisDirAttrs);
    in (recur dir [] (readDir dir));

  toPaths = prefix: val: if isPath val || isDerivation val
        then [{ name  = prefix;
                value = val; }]
        else concatMap (n: toPaths (if prefix == ""
                                        then n
                                        else prefix + "/" + n)
                                    (getAttr n val))
                        (attrNames val);

    toCmds = attrs: map 
        (entry: 
            with {
                n = escapeShellArg entry.name;
                v = escapeShellArg entry.value;
            };
            ''
            mkdir -p "$(dirname "$out"/${n})"
            ln -s ${v} "$out"/${n}
            ''
        )
        (toPaths "" attrs);

    attrsToDirs = attrs: runCommand "merged" {}
    (''mkdir -p "$out"'' + concatStringsSep "\n" (toCmds attrs));

    sanitiseName = stringAsChars (c: if elem c (lowerChars ++ upperChars)
                                    then c
                                    else "");

  isPath  = x: typeOf x == "path" || (isString x && hasPrefix "/" x);
}
