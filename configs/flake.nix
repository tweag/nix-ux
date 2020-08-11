{
  outputs = { self, nixpkgs }: let pkgs = import nixpkgs{ system = "x86_64-linux"; }; in {

    # FIXME: make 'module' a primop.
    lib = {
      module =
        { description ? null, extends ? [], options ? {}, config ? ({ config }: {}) } @ inArgs:
        let thisModule = rec {
          type = "module";

          _module = {
            inherit description extends options config;
          };

          _allModules = [thisModule] ++ builtins.concatLists (map (mod: assert mod.type or "<untyped>" == "module"; mod._allModules) extends);

          _allOptions = builtins.foldl' (xs: mod: xs // mod._module.options) {} _allModules;

          _allConfigs = map (mod: mod._module.config { config = final; }) _allModules;

          _allDefinitions = builtins.mapAttrs (name: value: map (x: x) (builtins.catAttrs name _allConfigs)) _allOptions;

          final = builtins.mapAttrs
            (name: defs:
              if defs == []
              then
                _allOptions.${name}.default
                  or (throw "Option '${name}' is not defined by module at ${self.lib.showPos (self.lib.getAnyPos inArgs)} and has no default value.")
              else
                # FIXME: support merge functions.
                if builtins.isList (builtins.head defs)
                then builtins.concatLists defs
                else
                  if builtins.isAttrs (builtins.head defs)
                  then builtins.foldl' (xs: ys: xs // ys) {} defs
                  else builtins.head defs)
            _allDefinitions;

        }; in thisModule;

      showPos = pos:
        if pos == null
        then "<unknown location>"
        else "${pos.file}:${toString pos.line}:${toString pos.column}";

      getAnyPos = attrs:
        builtins.foldl' (prev: name: if prev == null then builtins.unsafeGetAttrPos name attrs else prev) null (builtins.attrNames attrs);
    };

    modules = with self.lib; {

      derivation = module {
        description = "A Nix derivation.";

        options = {

          name = {
            example = "hello-1.2.3";
            description = "The name component of the store paths produced by this derivation.";
          };

          system = {
            default = "x86_64-linux";
            example = "x86_64-darwin";
            description = "The platform type on which to build this derivation.";
          };

          derivation = {
            description = "The resulting derivation.";
          };

          environment = {
            default = {};
          };

          # TODO: outputs, builder, args, ...

          buildCommand = {
            description = "The contents of the shell script that builds the derivation.";
          };

        };

        config = { config }: {

          derivation = derivation ({
            __structuredAttrs = true;
            name = config.name;
            system = config.system;
            builder = "${pkgs.bash}/bin/bash";
            args = [ "-c" ("source .attrs.sh; out=\${outputs[out]}; " + config.buildCommand) ];
          } // config.environment);

        };

      };

      stdenv = module {
        extends = [ self.modules.derivation ];

        config = { config }: {
          environment.PATH = "${pkgs.coreutils}/bin:${pkgs.gnutar}/bin";
        };
      };

      package = module {
        description = "An installable package.";

        extends = [ self.modules.derivation ];

        options = {

          pname = {
            example = "hello";
            description = "Name of the package.";
          };

          version = {
            default = null;
            example = "1.2.3";
            description = "The version of the package. Must be null or start with a digit.";
          };

        };

        config = { config }: {
          name = "${config.pname}${if config.version != null then "-" + config.version else ""}";
        };

      };

      hello = module {
        description = "A program that prints a friendly greeting.";

        extends = [ self.modules.package self.modules.stdenv ];

        options = {

          who = {
            default = "World";
            example = "Utrecht";
            description = "Who to greet.";
          };

        };

        config = { config }: {
          pname = "hello";
          version = "1.12";
          environment.WHO = config.who;
          buildCommand =
            ''
              mkdir -p $out/bin
              cat > $out/bin/hello <<EOF
              #! /bin/sh
              echo Hello $WHO
              EOF
              chmod +x $out/bin/hello
            '';
        };

      };

      bundle = module {

        extends = [ self.modules.derivation ];

        options = {

          bundle = {
            description = "A derivation that produces a tarball containing the closure of a package.";
          };

        };

        config = { config } @ outer: {

          bundle = (module {
            extends = [ self.modules.stdenv ];
            config = { config }: {
              name = "${outer.config.pname}-closure-${outer.config.version}";
              buildCommand =
                ''
                  mkdir $out
                  tar cvf $out/bundle.tar ${outer.config.derivation}
                '';
            };
          }).final.derivation;

        };

      };

      my-hello = module {
        extends = [ self.modules.hello self.modules.bundle ];
        config = { config }: {
          who = "Utrecht";
          version = "2020";
        };
      };

    };

  };
}
