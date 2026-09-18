# Implementation Summary: Task #619

- **Task**: 619 - require_reasons_for_linter_suppressions
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T00:39:00-07:00
- **Completed**: 2026-09-18T02:05:00-07:00
- **Effort**: ~1.5 hours
- **Dependencies**: 585 (burn-down; complete)
- **Artifacts**: plans/01_linter-suppression-reasons-c29.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Every `set_option linter.* false` occurrence in the live tree now carries a reason at its site,
and a new build-free invariant check (C29) keeps it that way. The tree began with 12 occurrences,
7 of them bare. Five bare suppressions were deleted after an empirical deletion trial measured
that they hid nothing; one was removed by fixing the warning it hid; one was kept with a
documented reason; and one — `Carrier.lean`'s file-scoped blanket — was kept with a documented
reason after the prescribed `omit` fix was measured not to converge. `lake build` is green,
`scripts/check-module-invariants.sh` reports `ALL CHECKS PASSED` including `PASS C29`, and
`scripts/warning-budget.txt` is unedited at zero warnings across zero files.

## What Changed

- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` — deleted the dead
  `linter.unusedVariables` suppression at the old line 128 (deletion trial: zero warnings; it had
  been silently retargeted by `bcb8e110b` and its original target fixed by `e18cd2271`). Deleted
  the second one at the old line 278 by taking the fix `scripts/warning-budget.txt`'s own
  disposition row prescribes: renamed `def regionHistory`'s unused binder `f` to `_f`. All ~36
  call sites are positional (re-verified by grep before editing), so the rename is
  source-compatible; the docstring was updated to the new spelling.
- `FormalSystem/Semantics/Ultraproduct/Los.lean`,
  `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean`,
  `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` — deleted their file-scoped
  `linter.unusedSectionVars` blankets. Each hides zero warnings (burn-down measurement for the
  first two, deletion trial for the third), confirmed by a guarded per-module build.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/UntlSnceFree.lean` — added a
  13-line reason comment above the stacked `set_option` group. The `linter.unusedTactic`
  suppression is load-bearing: the flagged `assumption` is the alternative's *failure* mechanism,
  and replacing it with `skip` fails the build with `unsolved goals` at
  `applyRule_emitted_time_mem_of_untlSnceFree`, twice over (`case h_2.inr.inr`, once per `Sign`).
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` — added an 18-line reason comment above the
  retained file-scoped blanket. See Plan Deviations.
- `scripts/check-module-invariants.sh` — new C29 block (header check-list entry, `ENFORCE_C29`
  default 1, ~45-line rationale comment, python scan), inserted between C28 and C9-DOCS.
- `docs/development/MODULE_INVARIANTS.md` — C29 row after C28's.
- `docs/development/LEAN_STYLE_GUIDE.md` — the "Suppressing Linters" snippet now models a
  *reasoned* suppression instead of the bare shape C29 rejects, plus a new note that a
  `set_option … in` binds to whatever declaration follows it and is silently retargeted by an
  insertion.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Semantics/Ultraproduct/README.md`,
  `README.md` — regenerated inventory blocks (`--emit-inventory`), stale as a downstream
  consequence of the line-count changes above.

### The C29 check

Build-free by construction, so it runs identically under `--no-build`; measured at well under a
second within a 24-second `--no-build` harness pass. Scope is live `.lean` under `FormalSystem/`,
`Tests/` and `scripts/` via the shared `live_walk.live_files` Boneyard-pruning walk — `Tests/` is
deliberately in scope, unlike C27's debug-directive scan. A `'linter.' in text` pre-filter runs
before masking and is exact for this pattern, since every match contains that literal. The match
runs on text masked by `scripts/lib/lean_debug_artifacts.mask`, whose 21-fixture self-test runs
first and fails C29 outright on a masker regression, exactly as it does for C27; a suppression
quoted in a docstring or commented out is therefore not a suppression. The reason rule walks
upward past contiguous stacked `set_option … in` lines before looking for the comment block —
required, not a refinement, because `UntlSnceFree.lean` really does carry
`set_option maxHeartbeats 4000000 in` directly above its linter suppression. A docstring above the
suppression does not count as a reason: it documents the declaration, and it is masked away.
There is **no companion allow-list**; the task description offered one as an alternative and both
research and this implementation decline it, because a reason in a central file goes stale
silently when the code it covers moves.

C29 ships with its own 13-fixture reason-rule self-test covering the bare, documented,
stacked-`set_option`, commented-out, docstring-quoted, docstring-above, unnamed-linter,
wrong-linter, file-scoped, blank-line-break, `set_option … true`, and `--`-inside-a-string shapes.

## Decisions

- **Reasons live at the site, not in an allowlist.** The task description permitted either; a
  site-local comment moves with the code it covers and is re-read by whoever next touches the
  declaration.
- **Naming the linter is required, not decorative.** `RegionFrame.lean:128` is the evidence: a
  suppression drifted onto a declaration it was never written for and nothing caught it. A reason
  that does not say which option it justifies cannot be checked against the option that is there.
- **C29 ships enforced with no soft window**, on the C24/C25/C26/C27 precedent — the tree reached
  zero bare suppressions in the same change that added the check.
- **Both anti-silence paths exit 2 and are not suppressed by `ENFORCE_C29=0`**, following C28's
  convention: a scan the harness cannot trust is an error in every mode.
- **The `UntlSnceFree` comment cites a declaration name, not a line number.** Inserting the
  comment shifts every line below it, so a pinned `file.lean:NNN` would have been wrong the moment
  it was written — and C20 gates such citations.

## Plan Deviations

- **Phase 1** altered: the plan's Risks row assumed C16 was already red from the burn-down with
  seven ungrandfathered `unusedArguments` findings. It is **green** on the clean tree
  (`PASS C16 … has no un-nolisted finding`). The only C16 debt is the pre-existing, not-yet-enforced
  `TODO C16 161 finding(s) across 10 of 14 non-FormalSystem lakefile root(s)`, identical at
  baseline and at the final gate.
- **Phase 3** deferred: `lake exe runLinter FormalSystem` cannot run against a partial build
  (`DecisionProcedure.olean does not exist`), so the C16 diff moved to Phase 9's full-harness run.
  It came back byte-identical to the Phase 1 capture, so the `regionHistory` entry in
  `scripts/nolints.json` was **not** reported stale and was left alone. No entry was added.
- **Phase 4** `[COMPLETED WITH EXCLUSIONS]`: `Carrier.lean`'s blanket was **kept** (with a reason)
  rather than deleted, taking the phase's own documented fallback. The deletion trial reported
  exactly the three warnings the burn-down recorded, all naming
  `[∀ (i : I), IsOrderedAddMonoid (D i)]`, at `mem_evZero`, `mk_surjective` and `mk_zero`. But the
  prescribed `omit [...] in` fix does **not** reach a fixpoint here: each `omit` narrows that
  lemma's signature, so its consumers stop mentioning the instance too and the linter moves on.
  With those three `omit`s the build reported six warnings (the same three, now for
  `[(i : I) → LinearOrder (D i)]`, plus `mk_eq_mk`, `mk_le_mk`, `shU_mk`); with six `omit`s it
  reported six further ones (`mk_eq_mk` and `shU_mk` for `LinearOrder`, plus `mk_lt_mk`,
  `shU_zero`, `shU_add`, `mk_max`). The route ends with an `omit` above nearly every theorem in
  the file. The `omit`s were reverted and the blanket documented instead. Nothing was baselined.
- **Phase 6** altered: the scan reports **7** occurrences in 6 files, not the hypothesised 6,
  because of the Phase 4 exclusion (12 − 4 − 1 = 7). The same pass surfaced three stale generated
  inventory blocks, a downstream consequence of Phases 2–5's line-count changes; regenerated in
  the same commit.
- **Phase 7** altered: both anti-silence paths were exercised, not only the empty walk.
- **Phase 8** altered: the script-header C29 entry landed in Phase 6's commit, beside the block it
  describes, rather than Phase 8's.

## Verification

- Build: Success — full `lake build` through the guard, 2660 jobs, exit 0, zero compiler warnings.
- Sorry count: 0
- Vacuous count: 0
- Axiom count: 11 declared `axiom` lines under `FormalSystem/`, unchanged from the pre-task commit.
- Tests: N/A (no new Lean statements; the test library builds as part of the full build)
- Files verified: Yes
- `bash scripts/check-module-invariants.sh`: `ALL CHECKS PASSED`, exit 0, including `PASS C29`,
  `PASS C28`, `PASS C9D`, `PASS C16`.
- `python3 scripts/warning-budget.py`: `0 warning(s) across 0 file(s)`.
  `git diff` over `scripts/warning-budget.txt` and `scripts/nolints.json` across the whole task is
  empty — nothing was baselined or grandfathered.
- Final inventory: 7 `set_option linter.* false` occurrences in 6 files, every one carrying a `--`
  comment block (6 to 18 lines) that opens by naming its linter in backticks.

### Negative-test evidence (Phase 7), verbatim

Injected bare suppression (`set_option linter.unusedTactic false in` above `def tailFilter` in
`FormalSystem/Semantics/Ultraproduct/IndexFilter.lean`, no comment):

```
FAIL  C29  1 `set_option linter.* false` occurrence(s) carry no reason
            FormalSystem/Semantics/Ultraproduct/IndexFilter.lean:58: linter.unusedTactic
            put a `--` comment block directly above the suppression (above any
            stacked `set_option ... in`) naming the linter and what a deletion
            trial actually showed; model: MintBound/Invariants.lean
```

with `2 CHECK GROUP(S) FAILED` and a script exit of **1** — the printed line alone is not the
test, per the C25 precedent.

Documented-but-does-not-name-the-linter (`-- see the note above` above the same suppression):

```
FAIL  C29  1 reason comment(s) never name the linter being suppressed
            FormalSystem/Semantics/Ultraproduct/IndexFilter.lean:59: comment above does not mention `linter.unusedTactic`
            name the linter in the comment: a suppression stack drifts onto other
            declarations, and an unnamed reason cannot be checked against its option
```

with a script exit of **1**.

Anti-silence guard, both paths, under `ENFORCE_C29=1` **and** `ENFORCE_C29=0`, exit **2** in all
four runs:

```
FAIL  C29  the walk produced ZERO .lean files across <dir> -- the scan cannot vouch for a tree it never read
            (exit 2: an untrustworthy scan is an error in every mode)

FAIL  C29  ZERO `set_option linter.* false` occurrence(s) found in 1 live .lean file(s) -- silence, not a pass
            the tree has always carried some; a zero here means the matcher, the
            masker or the walk stopped seeing them, not that they were all removed
            (exit 2: an untrustworthy scan is an error in every mode)
```

The injection was then reverted and the restoration confirmed byte-identical
(`git status --porcelain` empty over the touched path), with `PASS C29` and `ALL CHECKS PASSED`
returning.

## Impacts

- The harness now has a gate on the one class of debt C28 structurally cannot see: a warning
  suppressed before it is ever counted. The two checks are complementary halves of one ratchet.
- `RegionFrame.lean`'s `regionHistory` binder is now `_f`. The rename is source-compatible (all
  call sites positional) and the declaration's arity is unchanged.
- The style guide no longer teaches the exact shape C29 rejects.

## Follow-ups

- **Coordination note for the sibling Mathlib-linter-set task** (not edited here, per this plan's
  Non-Goals): its item covering the file-scoped Ultraproduct blankets drops from four targets to
  **one** — only `Carrier.lean` still carries a file-scoped blanket. That means (a) a shape ratchet
  permitting only the `in`-scoped form would have almost nothing left to convert and needs its own
  anti-silence guard, and (b) it would be better folded into C29 than added as a C30, since both
  read the same matched set. `Carrier.lean`'s blanket is deliberately file-scoped and is the one
  case such a ratchet would have to accommodate or drive.
- **`Carrier.lean` wants a `variable`-block split**, which is the fix the linter's own message
  suggests first and the one `scripts/warning-budget.txt` records for the same condition elsewhere
  in the tree: put `[∀ i, LinearOrder (D i)]` and `[∀ i, IsOrderedAddMonoid (D i)]` in scope only
  for the order-dependent declarations. That would let the blanket go. It is a restructuring of
  the file, not a suppression decision, and belongs in its own change.
- **Two stale prose claims noticed but not touched** (both owned by the burn-down's area, not this
  task): `scripts/check-module-invariants.sh`'s `ENFORCE_C28` comment still says "The floor is 7,
  not 0", and `docs/development/MODULE_INVARIANTS.md` still says "The tree currently carries 7 such
  entries, all in `DenseModelSurgery/`". `scripts/warning-budget.txt` now has zero entries.
- **`docs/development/MODULE_INVARIANTS.md`'s C9D row** still describes the check as "computed
  always, **soft** by default"; the script has `ENFORCE_C9_DOCS=1`.

## References

- `specs/619_require_reasons_for_linter_suppressions/plans/01_linter-suppression-reasons-c29.md`
- `specs/619_require_reasons_for_linter_suppressions/reports/01_linter-suppression-reasons.md`
- `scripts/check-module-invariants.sh` (C29 block and its header rationale)
- `docs/development/MODULE_INVARIANTS.md` (C29 row)
- `docs/development/LEAN_STYLE_GUIDE.md` ("Suppressing Linters")
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Invariants.lean` — the house
  model for a documented suppression
