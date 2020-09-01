{
  inputs.nixpkgs-ng = { url = github:tweag/nix-ux/configs?dir=nixpkgs-ng; };

  outputs = { self, nixpkgs-ng }: {

    modules = {

      hello = module {
        description = "A program that prints a friendly greeting.";

        extends = [ nixpkgs-ng.modules.package nixpkgs-ng.modules.stdenv ];

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

      my-hello = module {
        extends = [ self.modules.hello nixpkgs-ng.modules.bundle ];
        config = { config }: {
          who = "Utrecht";
          version = "2020";
        };
      };

    };

  };
}
