{
  description = "AI News Aggregator dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        pythonEnv = pkgs.python312.withPackages (ps: with ps; [
          # Database
          sqlalchemy
          psycopg2

          # HTTP & scraping
          requests
          beautifulsoup4

          # LLM
          openai

          # Email
          markdown

          # Data validation
          pydantic

          # Config
          python-dotenv

        ]);

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pythonEnv
            uv          # for packages missing from nixpkgs
            postgresql  # psql CLI for inspecting the DB
            docker
            docker-compose
            stdenv.cc.cc.lib 
            zlib
          ];

          # Runs automatically when you enter nix develop
          shellHook = ''
          export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH
          if [ ! -d .venv ]; then
            python -m venv .venv
          fi
          source .venv/bin/activate

          uv pip install \
            markdownify \
            feedparser\
            youtube-transcript-api \
            apscheduler \
            httpx \
            --quiet
          echo "✅ Dev environment ready!"
        '';
        };
      }
    );
}

