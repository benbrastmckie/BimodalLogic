# Deprecation Notice

This per-project `specs/literature/` directory has been superseded by the centralized
`~/Projects/Literature/` repository.

## Migration Status

All content from this directory has been migrated to the central repository:
- **183 entries** copied to `~/Projects/Literature/index.json` (v2 schema)
- **175 markdown files** copied preserving subdirectory structure
- **v2 fields backfilled**: `doc_type`, `source_format`, `zotero_key`, `zotero_path`, `project_tags`

Migration was performed on 2026-06-14 (task 710).

## How to Use the Central Repository

Set `LITERATURE_DIR` in your environment to use the centralized repo:

```bash
export LITERATURE_DIR=/home/benjamin/Projects/Literature
```

This variable is configured in:
- `~/.config/nvim/.claude/settings.json` (Claude Code sessions)
- `~/.dotfiles/home.nix` (shell sessions, requires `home-manager switch`)

With `LITERATURE_DIR` set, `/research`, `/plan`, and `/implement` with `--lit` flag will
inject content from the central repo instead of this directory.

## Fallback

This directory is preserved as a read-only fallback. If `LITERATURE_DIR` is unset or points
to a nonexistent path, the `--lit` flag falls back to this directory.

Do NOT add new entries here. Use `/literature --index` or `/literature --convert` commands
from the central repo context (with `LITERATURE_DIR` set) instead.
