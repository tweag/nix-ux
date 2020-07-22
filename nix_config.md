`nix config` is a new command that configures different aspects of Nix for your
project.

A simple example would be to change development environment marker from `(dev)`
to `(work)`.

```console
$ cd /path/to/project
$ nix config develop-env-marker "(work)"
Adding configuration to ./flake.toml
$ cat flake.toml
...
[config]
develop-env-marker = "(work)"
...
$ nix develop
   Developing hello-0.1.0 (file:///path/to/project)
(work) $ exit
$
```

By default it `nix config` command will try to all to local `flake.toml` file.
To change this configuration globally use `--global` flag. And if you wish
to change it for current user then use `--user` flag.

Global nix configuration file is at `/etc/nix/nix.toml` and user specific
configuration file is at `~/.nix/nix.toml`.

To see what what is being configured use `--list` option:

```console
$ nix config --list --show-origin
global: allowed-users = "*"
global: auto-optimise-store = false
global: build-users-group = "nixbld"
global: builders = []
global: builders-use-substitutes = true
global: cores = 0
 local: develop-env-marker = "(work)"
global: experimental-features = "nix-command flakes"
global: extra-sandbox-paths = []
global: max-jobs = 8
global: require-sigs = true
global: sandbox = true
global: sandbox-fallback = false
global: substituters = "https://cache.nixos.org/"
global: system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]
global: trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ]
global: trusted-substituters = []
global: trusted-users = [ "@wheel" ]
```

To remove the configuration `--rm` option can be used:

```console
$ nix config --rm develop-env-marker
$ nix develop
   Developing hello-0.1.0 (file:///path/to/project)
(dev) $ 
```

In cases when value of the configuration option is array and you want to add to
the list use `--add` option. An example would be providing additional binary
cache for your project.

```console
$ nix config --add binary-caches "cache.example.com"
$ nix config --list | grep binary-caches
binary-caches = [ "cache.nixos.org", "cache.example.com" ]
```
