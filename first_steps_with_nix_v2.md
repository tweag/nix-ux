# First steps with Nix

Borrowed from [Cargo documentation](https://doc.rust-lang.org/cargo/getting-started/first-steps.html).

To start a new project with Nix, use  `nix new`:

```console
$ nix new --template=templates#hello-world hello/
```

or `nix init`

```console
$ mkdir hello/
$ nix init --template=templates#hello-world 
```

Nix defaults to `minimal` template. To use a different template we passed 
`--template=hello-world`.

Let's check out what Nix has generated for us:

```console
$ cd hello
$ tree .
├── flake.toml
└── src/ 
 └── hello.sh 
 1 directory, 2 files
 ```

This is all we need to get started. First, let’s check out `flake.toml`:

```toml
maintainers = [ "Name Surname <name.surname@example.com>" ]
description = "A description of a flake"

[inputs]
nixpkgs = "nixos-unstable"

[package]  # or [[package]]
name = "hello"
version = "0.1.0"
src = "./."
platforms = [ "x86_64-linux" ]
dependencies = [
  "nixpkgs#bash",
]
buildPhase = """
  echo "Building hello.sh ..."
"""
installPhase = """
  mkdir -p $out/bin
  echo -e "#!$(realpath bash)\n$(cat ./src/hello.sh)" > $out/bin/hello
  chmod +x $out/bin/hello
"""
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

To add a additional dependencies to our package use `nix add` command:

```console
$ nix add nixpkgs#cowsay
nixpkgs#cowsay added to hello package in ./flake.toml
```

To enter development environment of you project use `nix develop` command:

```console
$ nix develop 
   Developing hello-0.1.0 (file:///path/to/package/hello)
(dev) $ bash src/hello.sh
Hello, world!
(dev) $ sed -i -e "s|echo|cowsay|" src/hello.sh 
(dev) $ bash src/hello.sh
 _______________ 
< Hello, world! >
 --------------- 
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

Sometimes you want to just run a certain phase inside a development environment
that gives you an opportunity to inspect and retry. You know, the usual
development cycle.

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
