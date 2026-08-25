# Phase 8 Handoff

**Next action**: Phase 9 (C14, the soft C9-over-docs computation, readme-lint scope extension,
MODULE_INVARIANTS.md documentation).

**State**: `bash scripts/check-module-invariants.sh --no-build` -> ALL CHECKS PASSED, with:
- `PASS C12  all slash-shaped source paths in 71 markdown files resolve`
- `PASS C13  all relative markdown links in 68 markdown files resolve (3 file(s) allowlisted)`

Both report real, enforced, non-soft results with **zero** allowlisted slash paths. The scope
hypothesis (C12: 85 -> 69 -> 0; C13: 96 -> 0) held: Phase 7 cleared the debt entirely, so
neither check needed weakening.

**Negative tests**: injecting one broken slash path and one broken link into `docs/README.md`
produced `FAIL C12` and `FAIL C13` naming both by file and line, and the script exited 1.
Reverted cleanly (`git diff --stat` empty; exit back to 0).

**Key decisions**:
- C5's regex was **not** touched, per report F8. C12 is a distinct check over a distinct path
  shape, and its pattern includes `Logos/` and `Bimodal/` -- the two pre-merge tree roots --
  precisely because neither resolves to anything today, so any occurrence is a defect by
  construction.
- Two companion allowlist files, both with prose stating what is and is not an admissible
  entry. `scripts/markdown-link-allowlist.txt` carries C13's three documented ignore-paths;
  `scripts/markdown-slash-path-allowlist.txt` is empty, since Phase 7 rewrote the five
  illustrative placeholder paths to name containing directories instead.
- Both allowlists report stale entries as INFO, so they cannot silently rot.
