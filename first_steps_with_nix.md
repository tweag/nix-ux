# First steps with Nix

Borrowed from [Cargo documentation](https://doc.rust-lang.org/cargo/getting-started/first-steps.html).

To start a new project with Nix, use  `nix new`:

```console
$ nix new --template=templates#hello-world hello/
```

or 

```console
$ mkdir hello/
$ nix init --template=templates#hello-world 
```

Nix defaults to `only-flake` template. To use a different template we passed 
`--template=hello-world`. To list all available templates use 
`nix list-templates` .

Let's check out what Nix has generated for us:

```console
$ cd hello
$ tree .
├── flake.nix 
└── src/ 
 └── hello.sh 
 1 directory, 2 files
 ```

 This is all we need to get started. First, let’s check out `flake.nix`:

 ```nix
 {
   inputs =
     { nixpkgs.url = "nixpkgs/nixos-unstable";
     };
   outpus = { self, nixpkgs }:
     let
       inherit (nixpkgs.lib) genAttrs;
       systems =
         [ "x86_64-linux"
           "i686-linux"
           "x86_64-darwin"
           "aarch64-linux"
         ];
       forAllSystems = f: genAttrs systems (system: f (import nixpkgs { inherit system; }));
       project = pkgs: pkgs.stdenv.mkDerivation
         { name = "hello-0.1.0";
           src = self;
           buildInputs = [ ];
           buildPhase = ''
             echo "Building hello.sh ..."
           '';
           installPhase = ''
             mkdir -p $out/bin
             cp ./src/hello.sh $out/bin
             chmod +x $out/bin/hello.sh
           '';
         };
     in rec { defaultPackage = packages.hello;
              defaultCommand = "./bin/hello.sh";
              packages.hello = forAllSystems project;
            };
 }
 ```
 This is called a **manifest**, and it contains all of the metadata that Nix 
 needs to build your project.

 Here's what is in `src/hello.sh`:

 ```bash
 echo "Hello, world!"
 ```

Nix generated a "hello world" project for us. Let's build it:

```console
$ nix build 
   Building hello-0.1.0 (file:///path/to/package/hello)
```

And then run it:

```console
$ ./result/bin/hello
Hello, world!
```

We can also use `nix run` to compile and then run it, all in one step:

```console
$ nix run
     Fresh hello-0.1.0 (file:///path/to/package/hello)
   Running `result/bin/hello`
Hello, world!
```

To enter development environment of you project use `nix develop` command:

```console
$ nix develop 
   Developing hello-0.1.0 (file:///path/to/package/hello)
(dev) $ bash src/hello.sh
Hello, world!
(dev) $ # Let's edit `src/hello.sh` with sed and allow for argument to be passed
(dev) $ sed -i -e 's|, world|, ${1:-world}|' src/hello.sh 
(dev) $ bash src/hello.sh Nix
Hello, Nix! 
```

Sometimes you want to just run a certain build phase inside a development 
environment that gives you an opportunity to inspect and retry. You know, the 
usual development cycle.

```console
$ nix develop --run-phase=check 
     Developing hello-0.1.0 (file:///path/to/package/hello)
   Running phase: check
... <here is check phase output> ...
(dev) $ exit
```

Above command can be also used to run build phase and thus having incremental
support for your build.

```console
$ nix develop --run-phase=build --exit
     Developing hello-0.1.0 (file:///path/to/package/hello)
   Running phase: build
Building hello.sh ...
$
```


## Going further 

For more details on using Nix, check out the [Nix Guide](https://nixos.org/learn.html).
