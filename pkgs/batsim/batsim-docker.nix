{ dockerTools, batsim, bash }:

let self = rec {
  tag = if batsim.version == "master" then "latest" else batsim.version;
  layer-dependencies = dockerTools.buildImage {
    name = "oarteam/batsim-deps";
    inherit tag;
    contents = batsim.runtimeDeps ++ [bash];
  };
  layer-batsim = dockerTools.buildImage {
    fromImage = layer-dependencies;
    fromImageName = layer-dependencies.name;
    fromImageTag = layer-dependencies.tag;

    name = "oarteam/batsim";
    inherit tag;
    contents = batsim;

    config = {
      Entrypoint = [ "${batsim}/bin/batsim" ];
      ExposedPorts = {
        "28000/tcp" = {};
      };
      WorkingDir = "/data";
      Volumes = {
        "/data" = {};
      };
    };
  };
};
in
  self.layer-batsim
