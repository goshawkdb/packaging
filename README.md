# GoshawkDB Packaging

GoshawkDB builds all server release artifacts
using [Nix](https://nixos.org/). This repo contains the Nix
expressions used to build the server release artifacts for each
release. These may bitrot. For example, Nix has changed its build
mechanism for Go at some point between the 0.2 and 0.3 releases of
GoshawkDB, which is why the Nix expressions for 0.3 are quite
different for 0.2.

The fact that all Go dependencies of the GoshawkDB server are fully
pinned by these expressions is one reason why GoshawkDB does not do
any vendoring of dependencies.

Unless you're looking for examples of interesting Nix recipes which
build `.deb`s or `.rpm`s or docker images, there's probably not much
in here. If you're looking to install GoshawkDB, head on over to
the [downloads](https://goshawkdb.io/download.html) page.
