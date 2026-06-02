# outline

Tiny, read-only CLI for [Outline](https://www.getoutline.com) — self-hosted or hosted. Search, read, list, tree, pull, grep. One escape-hatch command (`raw`) for the long tail.

Single Python file with [PEP 723 inline metadata](https://peps.python.org/pep-0723/), so [`uv`](https://github.com/astral-sh/uv) resolves dependencies on first run. No venv to manage.

## Install

```sh
# 1. uv (if you don't have it)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. drop the script on PATH
curl -fsSL https://raw.githubusercontent.com/naufalafif/outlinecli/main/outline \
  -o ~/.local/bin/outline
chmod +x ~/.local/bin/outline
```

## Configure

Host and token, either as env vars or files. The CLI checks env first, then files.

```sh
# Host
export OUTLINE_HOST="https://docs.yourdomain.com"
# OR
mkdir -p ~/.config/outline-cli
echo "https://docs.yourdomain.com" > ~/.config/outline-cli/host

# Token (Outline → Settings → API → New Token; pick read-only)
export OUTLINE_TOKEN="ol_api_..."
# OR
echo "ol_api_..." > ~/.config/outline-token
chmod 600 ~/.config/outline-token
```

Sanity check:

```sh
outline doctor
```

## Commands

```
outline doctor                          Check config + connectivity
outline whoami                          Show the token's user / team
outline ls                              List collections
outline ls <collection-id>              List docs in a collection
outline tree <collection-id>            Hierarchical tree
outline search "query"                  Full-text search
outline search "q" --collection <id>    Search within a collection
outline read <slug>                     Render markdown to terminal
outline read <slug> --raw               Raw markdown (pipeable)
outline pull <slug> -o file.md          Export a doc to file
outline grep "regex"                    Regex search across hit bodies
outline recent                          Recently updated docs
outline recent --mine                   Docs I've viewed
outline raw <endpoint> '<json>'         Call any endpoint (long-tail)
outline --install-completion            Add shell completion
```

## Token scope — read-only by default

Every named command only calls read endpoints (`*.list`, `*.info`, `*.search`, `*.export`, `auth.info`, `documents.viewed`). No `*.create / *.update / *.delete / *.move / *.archive` anywhere.

The `raw` escape hatch CAN call destructive endpoints if you point it at them. The safest belt-and-braces is to **create a read-only token in Outline** — then the server rejects mutations regardless of what you type.

## Requirements

- Python 3.10+
- [uv](https://github.com/astral-sh/uv) (the script's shebang invokes it)

Deps (resolved automatically): `typer`, `httpx`, `rich`.

## Why

I wanted a self-contained, install-in-one-line wrapper for the Outline API that I could keep on `PATH` without setting up a venv. Existing community CLIs were either narrow (a few commands) or large packages with their own install ceremony.

## License

MIT — see [LICENSE](LICENSE).
