{
  inputs.hello = { url = github:tweag/nix-ux?dir=hello; };

  outputs = { self, hello }: {

    modules.my-hello = module {
      extends = [ hello.modules.hello ];
      config = { config }: {
        who = "NixCon";
      };
    };

  };
}
