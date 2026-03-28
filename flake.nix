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
          feedparser

          # LLM
          openai

          # Email
          markdown

          # Data validation
          pydantic

          # Config
          python-dotenv

          # Dev
          ipykernel
        ]);

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pythonEnv
            uv          # for packages missing from nixpkgs
            postgresql  # psql CLI for inspecting the DB
            docker
            docker-compose
          ];

          # Runs automatically when you enter nix develop
          shellHook = ''
              echo "🐍 Python: $(python --version)"
              
              # Create venv if it doesn't exist
              if [ ! -d .venv ]; then
                python -m venv .venv
              fi
              
              # Activate it
              source .venv/bin/activate

              echo "📦 Installing packages not in nixpkgs..."
              uv pip install \
                markdownify \
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

