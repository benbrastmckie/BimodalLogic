# Implementation Summary: Clear Lean v4.33 Deprecation Warnings

- **Task**: 400 - clear_lean_v433_deprecation_warnings
- **Status**: [COMPLETED]
- **Plan**: `specs/400_clear_lean_v433_deprecation_warnings/plans/01_clear-deprecation-warnings.md`
- **Research**: `specs/400_clear_lean_v433_deprecation_warnings/reports/01_deprecation-census-and-validation.md`
- **Type**: lean4
- **Phases**: 6 of 6 completed

## Outcome

All **553 deprecation warnings across 60 files** under `Theories/Bimodal/Metalogic/` are cleared.
The tree builds green from a clean state with **zero** deprecation warnings.

| Metric | Baseline | Final |
|--------|----------|-------|
| Deprecation warnings | 553 | **0** |
| Build errors | 0 | 0 |
| Jobs | 1875 | 1874 (see below) |
| Live sorries | 1 | 1 (unchanged, `countermodel_discrete`) |
| Long lines (>100 chars) | 312 | 312 |
| `linter.defProp` | 38 | 38 |
| `linter.dupNamespace` | 13 | 13 |
| `(rintro-try-this)` | 14 | 14 |
| `warn.classDefReducibility` | 2 | 2 |
| `linter.unusedVariables` | 1 | 1 |
| `axiom` declarations | 2 | 2 |
| Declaration inventory | — | unchanged (no renames, no `def`→`theorem`) |

Net source change: **60 files, 552 insertions, 552 deletions**. The 553 sites map to 552 changed
lines because `SharedWitness.lean:5221` carried two deprecations (`List.Chain.cons` and
`List.Chain.nil`) on one line.

## Phases

### Phase 1: Harness Repair and Baseline Capture [COMPLETED]

Copied the tier-3 harness into this task's `tools/` and repaired it:

- **`run_lint` permissiveness fix** (the prerequisite): it invoked `lake env lean` without
  `-DautoImplicit=false`, so it elaborated *more permissively* than `lake build` and could report
  a false green. Now passes `-DautoImplicit=false -Dpp.unicode.fun=true`, mirroring
  `theoryLeanOptions` in `lakefile.lean`.
- **`(deprecation)` moved** from `OUT_OF_SCOPE_FROZEN` into `IN_SCOPE`; added `defsWithUnderscore`
  to the frozen set.
- **Added `parse_lake()`** for lake-format logs (`severity: PATH:L:C: msg`), keeping `POS_RE`/
  `parse()` for raw `lean` output (`PATH:L:C: severity: msg`). Both parsers now exist and are
  documented as non-interchangeable; the recorded dead end was *assuming* one format against the
  other's output, which matches nothing and reports vacuous zeros.
- **Added `fixers.apply_anchored()`**: position-anchored replacement that asserts the expected
  token at the exact reported `(line, col)`, refuses and reports on mismatch, and applies edits
  bottom-up. Global substring replacement appears nowhere in it. Unit-tested for all three
  behaviours including refusal on a deliberately wrong column.
- **Added `gate.py`**: equality-based frozen-category gate, content-located sorry check,
  source-level long-line count, and a declaration inventory that detects renames and
  `def`→`theorem` flips.

Baseline captured: 1875 jobs, 0 errors, 553 deprecations, 1 live sorry, 312 long lines. Site lists
regenerated: **505 `push_neg` (56 files) + 48 other (10 files) = 553 distinct sites over 60 files**,
matching raw emissions 1:1 with no distinct-site discount.

### Phase 2: `push_neg` → `push Not` (505 sites, 56 files) [COMPLETED]

Single scripted position-anchored pass. All 505 sites asserted to hold the literal token before
substitution; zero mismatches, zero reverts. Both tokens are 8 characters, so columns and line
lengths were preserved exactly and no `longLine` movement was possible.

The **4 `push_neg` occurrences that carry no warning were left untouched**, as required: 3 prose
comments (including one recording that "`push_neg` no longer fires here") and — a case worth
noting — one inside a `/- -/` block comment in `GapDetection.lean:4361`, which *looks* like live
code (`by_contra h_all; push_neg at h_all`) but is commented out and therefore never elaborated.
Position anchoring excluded all four automatically; a grep-and-replace would have rewritten them.

Result: 553 → 48 deprecations, gate passed.

### Phase 3: Statement-Identical Alias Swaps (32 sites, 6 files) [COMPLETED]

`Fin.coe_castSucc` → `Fin.val_castSucc` (17), `Fin.lt_iff_val_lt_val` → `Fin.lt_def` (10),
`List.chain_cons` → `List.isChain_cons_cons` (4), `List.take_succ` → `List.take_add_one` (1).

The `take_succ` edit is the known prefix collision — `List.take_succ` is a strict prefix of the
distinct, non-deprecated `List.take_succ_cons` used in the same file. Position anchoring kept it
intact: `take_succ_cons` count still 1, zero `take_add_one_cons` corruption.

Result: 48 → 16 deprecations, gate passed.

### Phase 4: Wrapper Deletion, `Option.iget`, and Import Swap (7 sites, 4 files) [COMPLETED]

- **`Finset.le_iff_subset` (4 sites, 2 files)**: now a tautology, so the `Finset.le_iff_subset.mp `
  wrapper was deleted, leaving `(Finset.le_sup …)`, which typechecks directly. The near-identical
  duplicated blocks in `VVecEA2Collapse.lean` and `ZetaUniformExtract.lean` were each verified
  independently rather than assumed symmetric.
- **`Option.iget` pair (`ShiftAndGlue.lean`)**: `.iget` → `.getD default` and
  `Encodable.surjective_decode_iget α` → `Encodable.surjective_decode_getD α default`. The
  successor's signature was confirmed against Mathlib before editing; the `Inhabited` instance
  three lines above supplies `default`.
- **Import swap (`MonadicFO.lean`)**: `Mathlib.Data.Finite.Card` →
  `Mathlib.SetTheory.Cardinal.NatCard`. The warning is reported at the module header (line 7),
  not at the offending import, so the target was located by content.

Result: 16 → 9 deprecations, gate passed.

### Phase 5: `List.Chain` → `List.IsChain` in `SharedWitness.lean` [COMPLETED]

The only shape-changing class, applied with per-edit reasoning rather than a script.

Six statement rewrites of the form `List.Chain R a l` → `List.IsChain R (a :: l)`:
`kvE2_sepGapRegions_pos`, `kvE2_sepChain_lt_between`, `kvE2_sepHonestAnchorsL_chain`,
`kvE2_sepHonestAnchorsR_chain`, `kvE2_sepGapRegions_lo_le`, `kvE2_sepGapRegions_hi_le`. Plus two
term rewrites: `List.Chain.cons` → `List.IsChain.cons_cons`, `List.Chain.nil` →
`(List.IsChain.singleton _)`.

Containment was **re-verified rather than assumed**: all six theorems have zero references outside
`SharedWitness.lean`, so the API change reaches no other module. The bridge was confirmed
definitional *before* editing (`List.Chain R a l = List.IsChain R (a :: l)` by `rfl`, both coercion
directions by `exact h`), which is why every proof body survived its statement rewrite unchanged
and the file built on the first attempt. Longest resulting line is 80 chars.

Result: 9 → **0** deprecations, gate passed.

### Phase 6: Full-Build Gate and Closeout [COMPLETED]

Bimodal's build artifacts were deleted and the library rebuilt from scratch (Mathlib's cache left
intact) so the end state could not rest on a stale `olean`. Clean rebuild: **1874 jobs, 0 errors,
0 deprecation warnings, 1 live sorry**, all frozen categories at baseline.

`Boneyard/` confirmed untouched: still holds its 176 `push_neg` occurrences and appears in no
commit's diff. No changes outside `Theories/` and this task's `specs/` directory.

## Plan Deviations

- **Phase 2 & 3, `sweep.py` per-file revert-on-regression gate — altered.** Used the new `gate.py`
  equality gate over the full `lake build` log instead. `sweep.py`'s per-file `lake env lean` pass
  is explicitly not an accepted build gate for this task, and no file needed reverting in any
  phase. The revert-on-regression capability was retained but never triggered.
- **Phase 3 file count — altered.** The plan said 7 files; the 32 sites are distributed over 6.
  Site count matched exactly.
- **Phase 4 job count — altered.** The plan predicted the count would stay at 1875 and required any
  change to be investigated. It moved to **1874**, and the cause was established rather than
  accepted: `Mathlib.Data.Finite.Card` is a pure deprecation shim (one `public import` plus
  `deprecated_module`, zero declarations) and was the tree's only reference, so importing its
  target directly drops exactly that one shim module from the build closure. The baseline was
  rebaselined to 1874 with the rationale recorded in `baseline_snapshot.json`.
- **Phase 5 statement count — altered.** The plan named four theorems carrying `List.Chain` in
  their statements; there are six — `kvE2_sepHonestAnchorsL_chain` and
  `kvE2_sepHonestAnchorsR_chain` are statements as well. All six were verified caller-free.
- **`defProp` baseline — corrected.** The plan expected "~35" and the brief said 35; the measured
  value is **38**. The measured value was frozen and held exactly through all phases.
- **Plan-marker bookkeeping — repaired mid-task.** The Phase 3 commit step bundled the plan-marker
  update and the `git commit` into one shell call, which a git guard hook rejected wholesale; the
  retry re-ran only the commit, so Phase 3's markers were never written and Phase 4's
  `[IN PROGRESS]` → `[COMPLETED]` replace then silently matched nothing. Caught at closeout and
  repaired, with assertion-guarded replacements substituted for the silent `str.replace` calls.
  No source file or build result was affected.

## Corrections to the Task Brief

- The brief described the sorry line as having "drifted 1242 → 1225". These are not two readings of
  one anchor: **line 1225 is the `theorem countermodel_discrete` declaration line** (what the build
  reports for `declaration uses 'sorry'`) and **line 1242 is the `sorry` token itself** (what a
  source census reports). Both are current and consistent. Locating by content remains correct
  practice, but no drift occurred here.
- Several tier-3 in-scope categories are **not** at 0 under `lake build` (`(rintro-try-this)` 14,
  `warn.classDefReducibility` 2, `linter.unusedVariables` 1). They read 0 only under
  `-Dlinter.mathlibStandardSet=true`, which `lake build` does not set. The measured `lake build`
  values were frozen instead, and `longLine` — which `lake build` never reports — was gated with a
  direct source-level count of lines over 100 characters (312, unchanged), so that check is not
  vacuous.

## Verification

- `lake build` from cleaned artifacts: **1874 jobs, 0 errors, 0 deprecation warnings**.
- Exactly **1** live sorry, located by content (`countermodel_discrete` in
  `WeakCanonical/Transfer.lean`) — unchanged from baseline.
- `Bimodal.Metalogic.BXCanonical.completeness` still depends on `sorryAx`, inherited from that one
  sorry; no new axioms (`axiom` declaration count 2 → 2).
- No vacuous definitions introduced. The single `:= trivial` match in the tree
  (`int_domain_universal`) is pre-existing and genuine — `intTimeHistory.domain t` really does
  reduce to `True`.
- Frozen sibling-owned categories hold by **equality**, so trespass would surface as a failure
  rather than read as a bonus. Declaration inventory unchanged across all 60 files: no declaration
  renamed, no `def` converted to `theorem`.
- `Boneyard/` and `Tests/` untouched.

## Artifacts

- `specs/400_clear_lean_v433_deprecation_warnings/tools/{lintlib,fixers,sweep,runlinter,sites,gate}.py`
- `specs/400_clear_lean_v433_deprecation_warnings/tools/{push_neg_sites.txt,other_sites.txt}`
- `specs/400_clear_lean_v433_deprecation_warnings/tools/{baseline_snapshot.json,baseline_categories.json}`
- `specs/400_clear_lean_v433_deprecation_warnings/summaries/01_clear-deprecation-warnings-summary.md`
- 60 modified files under `Theories/Bimodal/Metalogic/`
- Six commits, one per phase, each at a verified-green `lake build`
