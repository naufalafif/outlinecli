---
name: outline
description: Read a self-hosted Outline knowledge base from the shell via the `outline` CLI — search, grep, browse collections, read/export docs, and hit any API endpoint. Use when the user mentions Outline, a wiki/knowledge base, docs.pdevsecops.com, or asks to find, read, or export an internal doc / runbook / deployment note.
---

# outline — read-only Outline knowledge-base CLI

Drive a self-hosted [Outline](https://www.getoutline.com) instance from the shell. The CLI is read-only by design: every named command calls a read endpoint. Only `raw` can reach mutating endpoints, and a read-only token blocks even that.

## Pre-flight checks (always run first)

```bash
command -v outline        # is the CLI installed?
outline doctor            # config (host + token) + connectivity in one shot
```

`doctor` prints the host, masked token, and the connected user/team. If it fails, it tells the user exactly what to set. Never hard-code the host — read it from `doctor`/`whoami`. Don't print the token.

Config the CLI reads (env first, then file):
- Host: `$OUTLINE_HOST` or `~/.config/outline-cli/host`
- Token: `$OUTLINE_TOKEN` or `~/.config/outline-token` (chmod 600)

## Finding documents

```bash
outline search "course bumper deployment"      # full-text, ranked; default 10
outline search "billing" -n 20                 # more results
outline search "jwt" -c <collection-id>        # scope to one collection
outline grep "task sync"                        # regex, shows matching LINES inside hit docs
outline recent                                  # recently updated docs
outline recent --mine                           # only docs the token's user has viewed
```

- **`search` vs `grep`:** `search` ranks documents (use to locate a doc); `grep` fetches the hit bodies and shows the actual matching lines (use to find where a phrase appears). `grep -n N` caps how many docs it scans (default 50).
- Results show a `slug / id` column — feed that to `read`/`pull`.

## Browsing structure

```bash
outline ls                       # list collections (with ids)
outline ls <collection-id>       # docs in a collection
outline tree <collection-id>     # full nested doc hierarchy
```

Typical flow when the user doesn't know where something lives: `ls` → pick collection → `tree <id>` → `read <slug>`.

## Reading & exporting

```bash
outline read <slug>              # render markdown in the terminal
outline read <slug> --raw        # raw markdown to stdout (pipe/redirect)
outline pull <slug> -o doc.md    # export to a file (default: stdout)
```

`<slug>` is a document **id or url-slug**. The url-slug is the trailing token of an Outline URL, e.g. `https://<host>/doc/...-JVboQbgVvb` → slug `JVboQbgVvb`. To build a shareable link from a slug, fetch `documents.info` and join the host with the returned `url`.

## Escape hatch — any endpoint

```bash
outline raw collections.list
outline raw documents.info '{"id":"<slug>"}'
outline raw documents.search '{"query":"deploy","limit":5}'
```

`raw <endpoint> '<json>'` POSTs to `/api/<endpoint>`. Use it for anything the named commands don't cover (e.g. `documents.users`, `revisions.info`). ⚠️ `raw` CAN call destructive endpoints (`*.update`, `*.delete`, `*.move`) — only do so on explicit user request, and prefer a read-only token so the server rejects mutations regardless.

## Behavioral notes for Claude

1. **Run `doctor` first** if anything errors — it pinpoints missing host/token vs. a connectivity problem before you guess.
2. **Surface URLs, not just slugs.** When the user asks for a doc, give the full `https://<host>/doc/...` link (host from `whoami`, path from the doc's `url` field).
3. **Prefer `read` for consumption, `pull -o` for saving.** Use `--raw` when piping into other tools.
4. **Don't mutate.** Treat the knowledge base as read-only. If a write is genuinely requested, confirm explicitly and warn that it needs a write-scoped token.
5. **Never echo the token.** `doctor` already masks it; don't `cat` the token file.
6. **Default output is human tables (rich).** For programmatic parsing, use `raw` (JSON) or `read --raw`.

## If the CLI is missing

Point the user at the one-line install (uv + drop the script on PATH); see the repo README. Don't fabricate a host — they must set `$OUTLINE_HOST`/config and a token first, then `outline doctor`.
