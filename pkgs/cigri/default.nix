{ stdenv, pkgs, fetchFromGitHub, bundlerEnv, ruby, bash, perl }:
let
  rubyEnv = bundlerEnv rec {
  name = "cigri-env";
  inherit ruby;
  gemdir  = ./.;
  #groups = [ "default" "unicorn" "test" ]; # TODO not used
};
  in
    stdenv.mkDerivation rec {
  name = "cigri-3.0.0";
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "cigri";
    rev = "904bed81d61f5565bd5b86c345241bc0c511c317";
    sha256 = "001rapmzp08314c4y9birmfi6njgyvn7f95735qrd0443kfwhd19";
  };
  
  buildInputs = [ rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler bash perl ];
  
  buildPhase = ''
    # TODO warning /var/cigri/state can be overriden /modules/services/cigri.nix configuration 
    substituteInPlace modules/almighty.rb \
    --replace /var/run/cigri/almighty.pid /var/cigri/state/home/pidsalmighty.pid

    mkdir -p $out/bin $out/sbin
    make PREFIX=$out SHELL=${bash}/bin/bash \
    install-cigri-libs install-cigri-modules \
    install-cigri-server-tools install-cigri-user-cmds \
    install-cigri-api
  '';

  postInstall = ''
    cp -r database $out
  '';
  
  passthru = {
    inherit rubyEnv;
  };
  
  meta = with stdenv.lib; {
    homepage = "https://github.com/oar-team/cigri";
    description = "CiGri: a Lightweight Grid Middleware";
    license = licenses.lgpl3;
    longDescription = ''
    '';
  };
}
