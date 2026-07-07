# Phase 4 Handoff: typst-sync-check.sh Drift Detector

**Status**: COMPLETED
**Files touched**: `scripts/typst-sync-check.sh` (new), `Theories/Bimodal/typst/sync-check-whitelist.txt` (new), plus a small bug-fix carried over from Phase 3 in `chapters/04-metalogic.typ` and `chapters/06-notes.typ`.

## What was done

- Wrote `scripts/typst-sync-check.sh` with all four required checks:
  1. **Name resolution**: extracts every backtick span across `typst/**/*.typ` (excluding
     `generated/`), resolves path-like candidates against `Theories/Bimodal/` and the repo
     root (with a suffix-matching fallback for context-dropped path prefixes, and a
     deliberate-Boneyard-reference exception when the candidate itself names `Boneyard/`),
     resolves bare/dotted identifiers via `grep -rF` over `*.lean` excluding `Boneyard/`,
     and treats multi-word spans as literal-match-or-whitelist. A whitelist file
     (`sync-check-whitelist.txt`) covers type-signature illustrations, typst/template API
     names (`ref`, `link`, `taskto`), the planned-but-not-yet-created `notation/
     constitutive-notation.typ` (follow-up 317), and the `ProofChecker` proper noun.
  2. **Banner presence**: every chapter file `#include`d by `BimodalReference.typ` must
     contain a `#sync-banner(` call.
  3. **Legend discipline**: no chapter may declare both a `"paper"`/`"outlook"` banner and a
     `"check"`-class banner (mechanical proxy for "no ✓ claim in a ○/◇ chapter").
  4. **Count freshness**: re-runs `scripts/typst-status-counts.sh --json` and diffs every
     scalar field and the `sorry-table` array against the committed `generated/status.typ`,
     deliberately excluding the commit/date stamp fields (expected to advance between commits;
     Phase 12 re-stamps at the final commit).
- Verified pass on the current tree (218 backtick candidates, zero violations; all chapters
  banner-marked; no legend conflicts; zero count drift).
- Verified each check's seeded-failure path independently (restored after each test):
  an injected fake Lean name, a removed `#sync-banner(` call, and a conflicting
  outlook+check banner pair on the same file all correctly produced a non-zero-report
  violation; the real tree was restored from backup and re-verified green after each seed.

## Deviation from plan

- **Bug fix carried over into this phase's commit**: while building Check 1's candidate
  extraction, discovered that `` `#stamp-commit` `` and `` [`#subtree`] `` (backtick/bracket
  interpolation syntax written in Phase 3) do not interpolate inside typst raw spans --
  raw content is literal, so the rendered PDF showed the literal string `#stamp-commit`
  instead of the commit hash, and `#subtree` instead of each sorry-table row's subtree name.
  Fixed by using `#raw(stamp-commit)` / `#raw(subtree)` outside the backtick span in
  `chapters/04-metalogic.typ` and `chapters/06-notes.typ`. Confirmed via `pdftotext` on the
  compiled PDF before and after. This is a rendering-correctness fix to Phase 3's work, not
  a Phase 4 scope item; flagged here since Phase 3 was already marked COMPLETED when found.

## Verification

`bash scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS) against the current tree.
`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0, and `pdftotext`
confirms the stamp/subtree text now renders correctly (e.g. "commit d040a22b4" instead of
"commit #stamp-commit").
