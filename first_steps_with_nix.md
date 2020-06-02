# First steps with Nix

Borrowed from [Cargo documentation](https://doc.rust-lang.org/cargo/getting-started/first-steps.html).

To start a new project with Nix, use  `nix new`:

```console
$ nix new --template=templates#hello-world hello_world/
```

or 

```console
$ mkdir hello_world/
$ nix init --template=templates#hello-world 
```

Nix defaults to `only-flake` template. To use a different template we passed 
`--template=hello-world`. To list all available templates use 
`nix list-templates` .

Let’s check out what Nix has generated for us:

```console
$ cd hello_world
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
     { nixpkgs = ...
     };
   outpus =
     { defaultPackage = ...;
       packages = ...;
     };
 }
 ```
 This is called a **manifest**, and it contains all of the metadata that Nix 
 needs to build your project.

 Here’s what is in `src/hello.sh`:

 ```bash
 echo "Hello, world!"
 ```

Nix generated a "hello world" project for us. Let’s build it:

```console
$ nix build 
   Building hello_world v0.1.0 (file:///path/to/package/hello_world)
```

And then run it:

```console
$ ./result/bin/hello-world 
Hello, world!
```

We can also use `nix run` to compile and then run it, all in one step:

```console
$ nix run
     Fresh hello_world v0.1.0 (file:///path/to/package/hello_world)
   Running `result/bin/hello_world`
Hello, world!
```

To enter development environment of you project use `nix develop` command:

```console
$ nix develop 
   Developing hello_world v0.1.0 (file:///path/to/package/hello_world)
(dev) $ bash src/hello_world.sh 
Hello, world!
(dev) $ sed -i -e 's|, world|, ${1:-world}|' src/hello.sh 
(dev) $ bash src/hello_world.sh Nix 
Hello, Nix! 
```

Sometimes you want to just run a certain build phase inside a development 
environment that gives you an opportunity to inspect and retry. You know, the 
usual development cycle.

```console
$ nix develop --run-phase=check 
     Developing hello_world v0.1.0 (file:///path/to/package/hello_world)
   Running phase: check
... <here is check phase output> ...
(dev) $ exit
```

## Going further 

For more details on using Nix, check out the [Nix Guide](https://nixos.org/learn.html).

