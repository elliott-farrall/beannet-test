{ ... }:

{
  flake.modules.nixos.default =
    { lib, pkgs, config, ... }:
    let
      headroom-ai = pkgs.python3Packages.buildPythonPackage {
        pname = "headroom-ai";
        version = "0.34.0";
        format = "wheel";

        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/93/09/2b5a3470207cb4c8d75bf737d0bc8e59c5ab80b3c28f5d46b2aaa97913df/headroom_ai-0.34.0-cp310-abi3-manylinux_2_28_x86_64.whl";
          hash = "sha256-Bh2XS09Olbj8lhH8TQWTMeQ/0r1HNyQ7vtX8s6+Cd18=";
        };

        nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

        buildInputs = with pkgs; [ stdenv.cc.cc.lib openssl ];

        dependencies = with pkgs; [
          python3Packages."tiktoken"
          python3Packages."pydantic"
          python3Packages."litellm"
          python3Packages."click"
          python3Packages."rich"
          python3Packages."opentelemetry-api"
          python3Packages."ast-grep-py"
          python3Packages."pyyaml"
          python3Packages."tomlkit"
          python3Packages."fastapi"
          python3Packages."uvicorn"
          python3Packages."orjson"
          python3Packages."httpx"
          python3Packages."openai"
          python3Packages."mcp"
          python3Packages."magika"
          python3Packages."zstandard"
          python3Packages."websockets"
          python3Packages."h2"
          python3Packages."onnxruntime"
          python3Packages."transformers"
          python3Packages."watchdog"
          python3Packages."sqlite-vec"
        ];

        env.dontCheckRuntimeDeps = "1";

        doCheck = false;

        meta = {
          description = "Context compression proxy for AI coding tools";
          homepage = "https://headroom-docs.vercel.app";
          license = lib.licenses.mit;
          mainProgram = "headroom";
        };
      };
    in
    {
      systemd.services.headroom = {
        description = "Headroom — context compression proxy";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = toString (pkgs.writeShellScript "headroom-start" ''
            export OPENAI_API_KEY=$(< "$CREDENTIALS_DIRECTORY/openrouter-key")
            exec ${lib.getExe headroom-ai} proxy --port 8787
          '');

          LoadCredential = [
            "openrouter-key:${config.clan.core.vars.generators.openrouter.files.api-key.path}"
          ];

          Environment = [
            "OPENAI_TARGET_API_URL=https://openrouter.ai/api/v1"
            "HEADROOM_WORKSPACE_DIR=/var/lib/headroom"
            "HF_HOME=/var/cache/headroom/huggingface"
          ];

          User = "headroom";
          Group = "headroom";
          StateDirectory = "headroom";
          CacheDirectory = "headroom";

          Restart = "on-failure";
          RestartSec = "5s";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
        };
      };

      users.users.headroom = {
        isSystemUser = true;
        group = "headroom";
      };
      users.groups.headroom = { };

      environment.persistence.state.directories = [
        { directory = "/var/lib/headroom"; user = "headroom"; group = "headroom"; mode = "0750"; }
      ];
    };
}
