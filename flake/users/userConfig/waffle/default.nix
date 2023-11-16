{ userName }: { config, osConfig, ... }:
let 
  
in
{

  userConfig = {
    features = [
      #additional user features
      #Note: these apply to every system with this user
    ];
    #to add system specific, you could refer to the systemName
    #then use mkMerge with the above and a mkIf systemName = blah
    #features = mkMerge [ [] (mkIf true []) ];
  };

}
