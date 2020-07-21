$ nix config set [--local] binaryCaches cache.my-project.com
// TODO: does the above override 

$ nix config show --local

[config]
binaryCaches = [
  "cache.my-project.com"
]


$ nix config show -v

G for --global
U for --user
L for --local (default)

G: [config]
G: binaryCaches = [
L:   "cache.my-project.com"
G: ]

$ nix show/info
description: 
maintainer: 
builds: 
  packageA
  packageB
defaultBuild = packageA
defaultDevelop = packageA
