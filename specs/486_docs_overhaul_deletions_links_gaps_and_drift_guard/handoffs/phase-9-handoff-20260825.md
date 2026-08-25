# Phase 9 Handoff

**Next action**: Phase 10 (final verification gate).

**State**: `bash scripts/check-module-invariants.sh --no-build` -> ALL CHECKS PASSED, with
C12, C13 and C14 all enforced and green, and C9D reporting its debt as a `TODO` line.

**Scope hypothesis vs. measurement**: the plan hypothesised **152** task-number citations under
`docs/`. The measured figure is **138**. The difference is the Phase 1 deletions plus the
citations removed incidentally while rewriting host prose in Phases 2, 3 and 7. As the plan
intended, the number is reported and not gated, so the divergence is recorded rather than
forcing extra work. 100 of the 138 remain in `docs/development/PHASED_IMPLEMENTATION.md`.

**Negative tests**:
- C14: injecting `| Sorry Placeholders | 7 |` into `test-coverage.md` produced
  `FAIL C14  0 stale axiom count(s), 1 documented non-zero sorry count(s)` and exit 1.
  Reverted cleanly.
- `ENFORCE_C9_DOCS=1` produces `FAIL C9D 138 task-number citation(s)` and exit 1, confirming
  the computation is live rather than a stub.
- C12 and C14 additionally caught **this phase's own documentation** while it was being
  written: an illustrative `.../Foo.lean` path and the phrase "claimed 21 axioms" in
  `MODULE_INVARIANTS.md`. Both were real hits, both were fixed, and the file now carries a
  closing note explaining why prose in `docs/` must not name hypothetical paths or quote stale
  counts in tripwire shape.

**Surplus defect found by C14**: `docs/research/competitive-landscape.md` carried three
occurrences of "42 axiom constructors" -- the stale figure from the `Axioms.lean:92-95`
docstring that omits the Dedekind layer. Corrected to 45, with the derived percentage and the
acceptance-criteria target updated. The numerator (14 anchors) is the benchmark's own
measurement and is flagged in-text as not re-derived here.

**Key decisions**:
- C14 runs its own `#print axioms` rather than extending C2's baseline heredoc, which is
  documented as a HARD STOP.
- `readme-lint.sh` now classifies each root: a root containing `.lean` files keeps the
  README.md-only scope; any other root has Checks 3-4 scan every `*.md`. Pointing it at `docs/`
  now covers 70 files rather than 6. It also accepts multiple roots.
- Checks 2 and 4 are explicitly labelled REPORTED-not-gated in both the script header and the
  summary block, which now prints their counts so "not gated" cannot be misread as "not
  measured".
- `readme-lint.sh` reads C13's allowlist file, so the two checks cannot disagree about what
  counts as a link-syntax illustration.
