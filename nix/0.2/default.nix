# nix-build 0.2

with import <nixpkgs> {}; with go16Packages;

let
  goshawkdbVersion = "0.2";
  self = rec {
    skiplist = buildFromGitHub {
      rev = "3669b5426fe8517d1732b490d176f372284f595d";
      owner = "msackman";
      repo = "skiplist";
      sha256 = "0j75kvb1nkalh547k3hwrdxgrc5dqgmx715ajh0w04nx2ba0h2ya";
    };

    chancell = buildFromGitHub {
      rev = "f422164a269c10a3ec7495720dc97100d598fb98";
      owner = "msackman";
      repo = "chancell";
      sha256 = "0n9ng03akn8kczfs8ivz7jhig6qzjkblpg29y2fdpl7mrwqbx17n";
    };

    lmdb0 = lmdb.overrideDerivation (oldAttrs: {
      postInstall = ''
        mv $out/lib/liblmdb.so $out/lib/liblmdb.so.0.0.0
        ln $out/lib/liblmdb.so.0.0.0 $out/lib/liblmdb.so.0
      '';
    });

    gomdb = buildFromGitHub {
      rev = "b380364713e00fe67c90f5867952663e95aba720";
      owner = "msackman";
      repo = "gomdb";
      sha256 = "10yc2vvnacrah5jwibpbpm247ys412y8xkjzz88vbb1ww57prx5p";
      propagatedBuildInputs = [ lmdb0 chancell ];
    };

    rbtree = buildFromGitHub {
      rev = "cd7940bb26b149ce2faf398e7c63fff01aa7b394";
      owner = "glycerine";
      repo = "rbtree";
      sha256 = "1xnl4m9yn998jj1xlws10d9sgq7jvira8i5w4vls1mgphd4hx0zg";
    };

    capnp = buildFromGitHub {
      rev = "6212efb58029e575442ea95cfa4285ef96ad4617";
      owner = "glycerine";
      repo = "go-capnproto";
      sha256 = "1qhb7af9rz3wrywim0ds81lqsb3xc9hpnnjazgbfdxi0qliv3hpz";
      propagatedBuildInputs = [ rbtree ];
    };

    goshawkdb-common = buildGoPackage rec {
      name = "goshawkdb-common";
      goPackagePath = "goshawkdb.io/common";
      rev = "goshawkdb_${goshawkdbVersion}";
      src = fetchhg {
        inherit rev;
        url = "https://src.${goPackagePath}";
        sha256 = "04fy03rga2nd399grr8ws7fmk3g6gnjqwndclrr1dc87p91yh0jy";
      };
      propagatedBuildInputs = [ capnp ];
    };

    goshawkdb-server = buildGoPackage rec {
      name = "goshawkdb-server";
      goPackagePath = "goshawkdb.io/server";
      src = fetchurl {
        url = "https://src.goshawkdb.io/server/archive/goshawkdb_${goshawkdbVersion}.tar.gz";
        sha256 = "0sq7p5m8aqm1mqdm5qid4lh1hdrn26yi0pcz624crwcyp5nh891k";
      } // {
        archiveTimeStampSrc = "server-goshawkdb_${goshawkdbVersion}/.hg_archival.txt";
        license = "server-goshawkdb_${goshawkdbVersion}/LICENSE";
      };
      buildInputs = [ goshawkdb-common capnp skiplist chancell gomdb crypto ];
    };

    goshawkdb-server-dist = stdenv.mkDerivation {
      name = "goshawkdb-server-dist";
      buildInputs = [ patchelf binutils ];
      src = goshawkdb-server.bin;
      builder = ./builder-patchelf.sh;
    };

    goshawkdb-server-deb = stdenv.mkDerivation rec {
      name = "goshawkdb-server-deb";
      server = goshawkdb-server-dist;
      debian = ./debian;
      builder = ./builder-deb.sh;
      buildInputs = [ dpkg fakeroot ];
      inherit (goshawkdb-server) src;
      inherit (goshawkdb-server.src) archiveTimeStampSrc license;
    };

    goshawkdb-server-tar = stdenv.mkDerivation rec {
      name = "goshawkdb-server-tar";
      server = goshawkdb-server-dist;
      debian = ./debian;
      builder = ./builder-tar.sh;
      buildInputs = [ fakeroot ];
      inherit (goshawkdb-server) src;
      inherit (goshawkdb-server.src) archiveTimeStampSrc license;
      inherit goshawkdbVersion;
    };

    goshawkdb-server-rpm = stdenv.mkDerivation rec {
      name = "goshawkdb-server-rpm";
      server = goshawkdb-server-dist;
      tar = goshawkdb-server-tar;
      spec = ./rpm/goshawkdb-server.spec;
      builder = ./builder-rpm.sh;
      buildInputs = [ rpm file libfaketime ];
      inherit (goshawkdb-server) src;
      inherit (goshawkdb-server.src) archiveTimeStampSrc;
      inherit goshawkdbVersion;
    };
  };
in
  self
