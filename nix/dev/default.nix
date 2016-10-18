# nix-build dev

with import <nixpkgs> {};

let
  goshawkdbVersion = "dev";
  archivePrefix = if goshawkdbVersion == "dev" then "" else "goshawkdb_";

  findDeps = list:
    let
      asDep = dep: {
        inherit (dep) goPackagePath src;
      };
      findDepsH = list: acc:
        if list == []
        then acc
        else
          let
            h = builtins.head list;
            t = builtins.tail list;
            acc1 = if h ? extraSrcs then h.extraSrcs ++ acc else acc;
            acc2 = [(asDep h)] ++ acc1;
          in
            findDepsH t acc2;
    in
      findDepsH list [];

  self = rec {
    skiplist = rec {
      name = "skiplist";
      goPackagePath = "github.com/msackman/skiplist";
      rev = "4c22b4dbe8ed82d9b62dd4923b3e3877242f03f4";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "0pjv01d6g67zqkkm9iq0rpcf8ikfsshpg5kg4b94nnzj71nj6nfb";
      };
    };

    chancell = rec {
      name = "chancell";
      goPackagePath = "github.com/msackman/chancell";
      rev = "f422164a269c10a3ec7495720dc97100d598fb98";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "0n9ng03akn8kczfs8ivz7jhig6qzjkblpg29y2fdpl7mrwqbx17n";
      };
    };

    gotimerwheel = rec {
      name = "gotimerwheel";
      goPackagePath = "github.com/msackman/gotimerwheel";
      rev = "d3263727885fcb6e20fbd01d29774580ec548590";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "1air256v8aabdri9f4yrcwfahn4n5pnm292h3i8qm12vl3frwqhk";
      };
    };

    lmdb0 = lmdb.overrideDerivation (oldAttrs: {
      postInstall = ''
        mv $out/lib/liblmdb.so $out/lib/liblmdb.so.0.0.0
        ln $out/lib/liblmdb.so.0.0.0 $out/lib/liblmdb.so.0
      '';
    });

    gomdb = rec {
      name = "gomdb";
      goPackagePath = "github.com/msackman/gomdb";
      rev = "b380364713e00fe67c90f5867952663e95aba720";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "10yc2vvnacrah5jwibpbpm247ys412y8xkjzz88vbb1ww57prx5p";
      };
      extraSrcs = findDeps [ chancell ];
      propagatedBuildInputs = [ lmdb0 ];
    };

    rbtree = rec {
      name = "rbtree";
      goPackagePath = "github.com/glycerine/rbtree";
      rev = "cd7940bb26b149ce2faf398e7c63fff01aa7b394";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "1xnl4m9yn998jj1xlws10d9sgq7jvira8i5w4vls1mgphd4hx0zg";
      };
    };

    capnp = rec {
      name = "go-capnproto";
      goPackagePath = "github.com/glycerine/go-capnproto";
      rev = "6212efb58029e575442ea95cfa4285ef96ad4617";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "1qhb7af9rz3wrywim0ds81lqsb3xc9hpnnjazgbfdxi0qliv3hpz";
      };
      extraSrcs = findDeps [ rbtree ];
    };

    goshawkdb-common = rec {
      name = "goshawkdb-common";
      goPackagePath = "goshawkdb.io/common";
      rev = goshawkdbVersion;
      src = fetchhg {
        inherit rev;
        url = "https://src.${goPackagePath}";
        sha256 = "1wbbz2m0kwnx75w6viwsdwy5r9hd1idq5gmalnp79ghxssgbp08p";
      };
      extraSrcs = findDeps [ capnp ];
      propagatedBuildInputs = [ (buildGoPackage capnp) ];
    };

    goshawkdb-server = rec {
      name = "goshawkdb-server";
      goPackagePath = "goshawkdb.io/server";
      rev = goshawkdbVersion;
      src = fetchurl {
        url = "https://src.goshawkdb.io/server/archive/${archivePrefix}${goshawkdbVersion}.tar.gz";
        sha256 = "0walbalyicncp9h38ba8j79aazw2i9a26phzhpbyvwz9akgb1ymc";
      } // {
        archiveTimeStampSrc = "server-${archivePrefix}${goshawkdbVersion}/.hg_archival.txt";
        license = "server-${archivePrefix}${goshawkdbVersion}/LICENSE";
      };
      subPackages = [ "cmd/goshawkdb" ]; # we may want to debitrot consistency checker
      extraSrcs = findDeps [ goshawkdb-common capnp skiplist chancell gomdb gotimerwheel ];
      propagatedBuildInputs = [ lmdb0 ];
    };

    goshawkdb-server-dist = stdenv.mkDerivation {
      name = "goshawkdb-server-dist";
      buildInputs = [ patchelf binutils ];
      src = (buildGoPackage goshawkdb-server).bin;
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
