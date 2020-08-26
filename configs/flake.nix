{
  outputs = { self, nixpkgs }: let pkgs = import nixpkgs{ system = "x86_64-linux"; }; in {

    modules = {

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
