# nix-build dev

{ pkgs ? import <nixpkgs> {} }:

with pkgs;

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
    runc = rec {
      name = "runc";
      goPackagePath = "github.com/opencontainers/runc";
      rev = "c91b5bea4830a57eac7882d7455d59518cdf70ec";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "06bxc4g3frh4i1lkzvwdcwmzmr0i52rz4a4pij39s15zaigm79wk";
      };
    };

    gosu = rec {
      name = "gosu";
      goPackagePath = "github.com/tianon/gosu";
      rev = "d2937f478b317e55a77e0e0ed4f79a333a6f5735";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "074md9gzsmydcrzh8fq9l4pmk9d1y5sdkwjpsgxca77ns2bi4wv9";
      };
      extraSrcs = findDeps [ runc ];
    };

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

    websocket = rec {
      name = "websocket";
      goPackagePath = "github.com/gorilla/websocket";
      rev = "3ab3a8b8831546bd18fd182c20687ca853b2bb13";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "17y94ngp1yrswq5pxxy97naiw6jgxz2yvm8zydi83gfixdgs99fc";
      };
    };

    fwd = rec {
      name = "fwd";
      goPackagePath = "github.com/philhofer/fwd";
      rev = "98c11a7a6ec829d672b03833c3d69a7fae1ca972";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "1vp52nxmnh3acmxa2izlwcly65apm7fmiil76vzijakni36nxi8h";
      };
    };

    msgp = rec {
      name = "msgp";
      goPackagePath = "github.com/tinylib/msgp";
      rev = "b433144bef5f20ebd771c0872945f6707ed3f178";
      src = fetchgit {
        inherit rev;
        url = "https://${goPackagePath}.git";
        sha256 = "0fn803p3nbn44kj6h47cs12c906djgzs7l9pjgprm4gfa10lndvb";
      };
      extraSrcs = findDeps [ fwd ];
    };

    goshawkdb-common = rec {
      name = "goshawkdb-common";
      goPackagePath = "goshawkdb.io/common";
      rev = goshawkdbVersion;
      src = fetchurl {
        url = "https://src.goshawkdb.io/common/archive/${archivePrefix}${goshawkdbVersion}.tar.gz";
        sha256 = "0gpiyci7irzxxvi22znyq1vxp20hva1g495ihqxmbzyqbh60d0gl";
      };
      extraSrcs = findDeps [ capnp msgp ];
      propagatedBuildInputs = [ built.capnp ];
    };

    goshawkdb-server = rec {
      name = "goshawkdb-server";
      goPackagePath = "goshawkdb.io/server";
      rev = goshawkdbVersion;
      src = fetchurl {
        url = "https://src.goshawkdb.io/server/archive/${archivePrefix}${goshawkdbVersion}.tar.gz";
        sha256 = "1fkmjvqa0qsww3lfak8590kmwfibsn4g5hfxvkchycxa6zj7b16z";
      } // {
        archiveTimeStampSrc = "server-${archivePrefix}${goshawkdbVersion}/.hg_archival.txt";
        license = "server-${archivePrefix}${goshawkdbVersion}/LICENSE";
      };
      subPackages = [ "cmd/goshawkdb" ]; # we may want to add consistency checker
      extraSrcs = findDeps [ goshawkdb-common capnp skiplist chancell gomdb gotimerwheel msgp websocket ];
      propagatedBuildInputs = [ lmdb0 ];
    };

    goshawkdb-server-dist = stdenv.mkDerivation {
      name = "goshawkdb-server-dist";
      buildInputs = [ patchelf binutils ];
      src = built.goshawkdb-server.bin;
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

    docker-entrypoint = writeScript "entrypoint.sh" ''
      #!${busybox}/bin/ash
      set -e
      if [ "$1" = "goshawkdb" ]; then
        ${busybox}/bin/chown -R goshawkdb /data
        exec ${built.gosu.bin}/bin/gosu goshawkdb \
          ${built.goshawkdb-server.bin}/bin/goshawkdb \
          -dir /data/goshawkdb \
          -config /data/config.json \
          -cert /data/clusterCert.pem \
          -wss
      fi
      if [ "$1" = "setup" ]; then
        if [ -e /data/goshawkdb -o -e /data/config.json -o -e /data/clusterCert.pem ]; then
          printf "/data is not empty. Cannot continue with setup"
          exit 1
        fi

        ${busybox}/bin/chown -R goshawkdb /data
        ${built.gosu.bin}/bin/gosu goshawkdb ${built.goshawkdb-server.bin}/bin/goshawkdb \
          -gen-cluster-cert > /data/clusterCert.pem
        ${built.gosu.bin}/bin/gosu goshawkdb ${built.goshawkdb-server.bin}/bin/goshawkdb \
          -cert /data/clusterCert.pem \
          -gen-client-cert 1> /data/clientKeyPair.pem 2> /data/clientKeyPairFingerprint.txt
        fp=$(${busybox}/bin/grep 'Fingerprint:' /data/clientKeyPairFingerprint.txt | ${busybox}/bin/sed -e 's/^.\+Fingerprint: //')
        ${busybox}/bin/sed -e "s/FINGERPRINT/$fp/" < ${default-config} > /data/config.json

        ${busybox}/bin/mkdir /data/goshawkdb
        ${busybox}/bin/chown -R goshawkdb:goshawkdb /data
        ${busybox}/bin/chmod 400 /data/clusterCert.pem /data/clientKeyPair.pem
        ${busybox}/bin/chmod 444 /data/config.json
        ${busybox}/bin/chmod 700 /data/goshawkdb

        exit 0
      fi
      exec "$@"
    '';

    default-config = writeScript "config.json" ''
      {
        "ClusterId": "MyFirstGoshawkDBCluster",
        "Version": 1,
        "Hosts": ["localhost"],
        "F": 0,
        "MaxRMCount": 5,
        "ClientCertificateFingerprints": {
          "FINGERPRINT": {
            "myFirstRoot": {
              "Read": true,
              "Write": true
            }
          }
        }
      }
    '';

    docker-image = dockerTools.buildImage {
      name = "goshawkdb-server";
      tag = goshawkdbVersion;

      runAsRoot = ''
        #!${stdenv.shell}
        ${dockerTools.shadowSetup}
        groupadd -r goshawkdb
        useradd -r -g goshawkdb -d /data -M goshawkdb
        mkdir /data
        chown goshawkdb:goshawkdb /data
      '';

      config = {
        Cmd = [ "goshawkdb" ];
        Entrypoint = [ docker-entrypoint ];
        ExposedPorts = {
          "7894/tcp" = {};
          "7895/tcp" = {};
        };
        WorkingDir = "/data";
        Volumes = {
          "/data" = {};
        };
      };
    };

    built = {
      gosu = buildGoPackage self.gosu;
      capnp = buildGoPackage self.capnp;
      goshawkdb-server = buildGoPackage self.goshawkdb-server;
    };
  };
in
  self
