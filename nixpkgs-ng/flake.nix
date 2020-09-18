{
  outputs = { self, nixpkgs }: let pkgs = import nixpkgs{ system = "x86_64-linux"; }; in {

    modules = {

      derivation = module {
        doc = "A Nix derivation.";

        options = {

          name = {
            example = "hello-1.2.3";
            doc = "The name component of the store paths produced by this derivation.";
          };

          system = {
            default = "x86_64-linux";
            example = "x86_64-darwin";
            doc = "The platform type on which to build this derivation.";
          };

          derivation = {
            doc = "The resulting derivation.";
          };

          environment = {
            default = {};
            doc = "Environment variables passed to the builder.";
          };

          # TODO: outputs, builder, args, ...

          buildCommand = {
            doc = "The contents of the shell script that builds the derivation.";
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
        doc =
          ''
            This module provides a standard environment for building
            packages.
          '';

        extends = [ self.modules.derivation ];

        config = { config }: {
          environment.PATH = "${pkgs.coreutils}/bin:${pkgs.gnutar}/bin";
        };
      };

      package = module {
        doc = "An installable package.";

        extends = [ self.modules.derivation ];

        options = {

          pname = {
            example = "hello";
            doc = "Name of the package.";
          };

          version = {
            default = null;
            example = "1.2.3";
            doc = "The version of the package. Must be null or start with a digit.";
          };

        };

        config = { config }: {
          name = "${config.pname}${if config.version != null then "-" + config.version else ""}";
        };

      };

      bundle = module {

        extends = [ self.modules.derivation ];

        options = {

          bundle = {
            doc = "A derivation that produces a tarball containing the closure of a package.";
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

    };

  };
}
