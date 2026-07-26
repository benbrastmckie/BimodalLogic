# Implementation Plan: Clear Lean v4.33 Deprecation Warnings

- **Task**: 400 - clear_lean_v433_deprecation_warnings
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/400_clear_lean_v433_deprecation_warnings/reports/01_deprecation-census-and-validation.md`
- **Artifacts**: plans/01_clear-deprecation-warnings.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Clear all **553 deprecation warnings across 60 files** under `Theories/Bimodal/Metalogic/`,
introduced by the move to Lean v4.33.0-rc1 / Mathlib `v4.33.0-rc1`. The work is overwhelmingly
mechanical: 505 of 553 sites are the single substitution `push_neg` → `push Not`, which research
proved (by reading `Mathlib/Tactic/Push.lean`) to be a pure substitution differing only by a
`logWarning` call, and confirmed empirically across all 56 affected files under a category-count
differential gate. The remaining 48 sites were all fixed and validated on scratch copies during
research. Definition of done: `lake build` reports 0 errors, 0 deprecation warnings, and exactly
**1** live sorry (in `WeakCanonical/Transfer.lean`), with all sibling-owned linter category counts
unchanged.

### Research Integration

The plan is driven end-to-end by `reports/01_deprecation-census-and-validation.md`:

- **Census (§2)**: 553 total = 505 `push_neg` + 48 others. This supersedes the task brief's 554/506
  and the tier-3-era 521 figure. `Automation/` is now clean; all 553 are under `Metalogic/`.
- **Risk resolution (§3)**: `push Not` is provably equivalent — same `push` function, same
  arguments (`.const \`\`Not`, `none` discharger, identical cfg/loc/`ifUnchanged`). All seven
  codebase-specific hazards (shadowed `Not`, config forms, `at *`, conv mode, `<;>`, `colGt`
  absorption, line length) were checked and cleared. Both tokens are 8 characters, so column
  positions and tier-3 `longLine` compliance are preserved exactly.
- **Non-`push_neg` remainder (§4)**: all 48 fixed and validated; all 10 affected files elaborate
  clean. Phases 3-5 below transcribe those validated end states.
- **Phase shape (§5)**: phases cut by **risk class**, not site count, because the bulk is one
  scripted pass. Splitting the `push_neg` phase by file buys nothing.
- **Toolkit reuse (§6)**: the tier-3 harness at
  `specs/399_mathlib_linter_compliance_tier3_metalogic/tools/` is reused with the `run_lint`
  option fix and a new position-anchored fixer.
- **Mandatory constraint (§7)**: position-anchored replacement only.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- Eliminate all 553 deprecation warnings in `Theories/Bimodal/` (all under `Metalogic/`).
- Preserve the build invariant at every phase boundary: `lake build` 0 errors, exactly 1 live sorry.
- Leave every sibling-owned linter category count **unchanged** (not merely non-increased).
- Reuse and repair the tier-3 harness rather than building a new one.

**Non-Goals**:
- Renaming any declaration, or converting any `def` to `theorem` — that is the naming task's
  territory (`linter.defProp`, `linter.dupNamespace`, `defsWithUnderscore` counts must stay frozen).
- Touching `Boneyard/` (unbuilt, inert; still holds 176 `push_neg` occurrences that must remain).
- Touching `Tests/` (not in the default target; contains zero `push_neg`).
- Discharging the one live sorry in `WeakCanonical/Transfer.lean`.
- Any reformatting, line rewrapping, or incidental cleanup beyond the deprecation substitutions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Global substring replace corrupts a longer non-deprecated identifier (`List.take_succ` is a prefix of `List.take_succ_cons`) | H | H if unguarded | **Position-anchored replacement is mandatory**: replace only at the exact compiler-reported `(line, col)`, assert the expected token is present first, apply bottom-up. Exactly one such collision exists, but the discipline is uniform. |
| Prose mentions of `push_neg` (3 doc-comments + 1 comment) get rewritten, destroying notes whose accuracy depends on naming the old tactic | M | H if unguarded | Position-anchoring protects these automatically — they carry no warning and therefore no position. Never grep-and-replace on source text. |
| Parser format mismatch reports vacuous zeros: raw `lean` emits `PATH:L:C: severity: msg`, lake emits `severity: PATH:L:C: msg` | H (false green) | M | Use `lintlib.py`'s existing `POS_RE`, which already handles the raw format correctly. Do not write a new parser. |
| Harness elaborates more permissively than `lake build` (`run_lint` omits `-DautoImplicit=false`), masking an error | H (false green) | M | Fix `run_lint` in Phase 1 **before** relying on the harness. Suspected contributor to the prior task's `DecidablePred` divergence. |
| Per-file `lake env lean` passes but full build fails (cross-module effect) | H | L-M | `lake env lean` on a single file is **not** a substitute for `lake build`. Full-build gate at every phase boundary, no exceptions. |
| A tactic substitution changes goal state and breaks a proof several lines later | M | L (505/505 already validated) | Per-file category-count differential gate with revert-on-regression (`sweep.py` already implements this). |
| `List.Chain` → `List.IsChain` shape change breaks a downstream caller | M | L | Four affected theorem statements have all call sites inside `SharedWitness.lean` itself (verified). Bridge holds definitionally: `List.Chain R a l = List.IsChain R (a :: l)` by `rfl`. Full-build gate covers the rest. |
| Import swap in `MonadicFO.lean` has real cross-module reach (8 importers) | M | L | Deprecated module is a pure shim (`public import Mathlib.SetTheory.Cardinal.NatCard` + `deprecated_module`). Full-build gate covers it. |
| Trespass into sibling territory goes unnoticed because the gate only checks "no increase" | M | L | Gate is **equality**, not non-increase: `defProp` 35, `dupNamespace` 13, `defsWithUnderscore`, and all tier-3 in-scope categories (now 0) must hold exactly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
mutates the tree and is gated by a full `lake build`, so no two phases may run concurrently.

---

### Phase 1: Harness Repair and Baseline Capture [COMPLETED]

**Goal**: Make the tier-3 harness trustworthy for this task, and capture the authoritative
baseline that every later differential gate compares against.

**Tasks**:
- [x] Copy the tier-3 harness to this task's own tools directory:
      `specs/399_mathlib_linter_compliance_tier3_metalogic/tools/{lintlib,fixers,sweep,runlinter}.py`
      → `specs/400_clear_lean_v433_deprecation_warnings/tools/`. Do not edit the tier-3 originals.
- [x] **Fix `run_lint` in `lintlib.py`**: it currently runs
      `lake env lean -Dlinter.mathlibStandardSet=true <path>` with no `-DautoImplicit=false`,
      elaborating **more permissively** than `lake build` (`lean_lib Bimodal` sets
      `autoImplicit := false`). Add `-DautoImplicit=false -Dpp.unicode.fun=true`. This is a
      prerequisite for every later gate — do it first.
- [x] Move the `(deprecation)` category in `lintlib.py` from `OUT_OF_SCOPE_FROZEN` into `IN_SCOPE`
      (one-line change; the category already exists in `classify()`).
- [x] Add a **position-anchored deprecation fixer** to `fixers.py`. Contract: given a list of
      `(file, line, col, expected_token, replacement)`, assert `expected_token` is present at
      exactly that `(line, col)` before substituting; refuse and report otherwise; apply edits
      bottom-up within each file. Global substring replacement must not appear anywhere in the
      fixer.
- [x] Confirm `POS_RE` is used for all parsing (it already handles the raw `lean` format
      `PATH:L:C: severity: msg`; lake's `severity: PATH:L:C: msg` is a different shape). Do not
      write a new parser; keep `runlinter.py` for `runLinter` output.
- [x] Run a clean `lake build 2>&1 | tee <scratch>/build_baseline.log`. Record: job count,
      error count, sorry count and location.
- [x] Regenerate both site lists from the baseline log (do not trust the report's stale copies):
      `grep '^warning:' build_baseline.log | grep 'has been deprecated'` → split into
      `push_neg_sites.txt` (`file|line|col`) and `other_sites.txt` (`file|line|col|symbol`).
- [x] Record the **frozen category baseline** from the same log: `defProp` (expect ~35),
      `dupNamespace` (expect 13), `defsWithUnderscore`, and all tier-3 in-scope categories
      (expect 0 each). These are equality targets for every later gate.
- [x] Commit the harness and baseline artifacts.

**Timing**: 1 hour (dominated by the clean `lake build`).

**Depends on**: none

**Files to modify**:
- `specs/400_clear_lean_v433_deprecation_warnings/tools/lintlib.py` - add `-DautoImplicit=false -Dpp.unicode.fun=true` to `run_lint`; move `(deprecation)` to `IN_SCOPE`
- `specs/400_clear_lean_v433_deprecation_warnings/tools/fixers.py` - add position-anchored deprecation fixer
- `specs/400_clear_lean_v433_deprecation_warnings/tools/{sweep,runlinter}.py` - copied as-is
- No `Theories/` files touched in this phase

**Verification**:
- `lake build` baseline reproduced: 0 errors, exactly 1 `declaration uses \`sorry\`` in
  `WeakCanonical/Transfer.lean` (identify by **content**, not line number — the line has already
  drifted 1242 → 1225 and will drift again).
- `push_neg_sites.txt` has 505 lines; `other_sites.txt` has 48 lines; each entry is a distinct
  `(file, line, col)` triple. Raw emissions equal distinct sites 1:1 here — no distinct-site
  discount applies (unlike the tier-3 78 → 41 collapse). Investigate any deviation before
  proceeding.
- Sanity-check the fixer refuses a deliberately wrong `(line, col)`.

---

### Phase 2: `push_neg` → `push Not` (505 sites, 56 files) [IN PROGRESS]

**Goal**: Eliminate all 505 `push_neg` deprecations in a single scripted, position-anchored pass.

**Tasks**:
- [ ] Drive the position-anchored fixer over `push_neg_sites.txt`, substituting the 8-character
      token `push_neg` with the 8-character token `push Not` at each exact `(line, col)`.
- [ ] Assert per site that the token at that position is exactly `push_neg` before substituting;
      abort and report on any mismatch rather than guessing.
- [ ] Run `sweep.py`'s per-file revert-on-regression gate in place (not on scratch copies —
      `POS_RE` anchors on `^Theories/`). Revert any file that does not reach zero in-scope
      deprecations, or where any other category count changes, or where an error appears.
- [ ] Confirm the 4 prose mentions of `push_neg` (3 doc-comments, 1 comment recording that
      "`push_neg` no longer fires here") are **untouched** — they carry no warning position.
- [ ] Run full `lake build`.
- [ ] Commit at green.

**Timing**: 1 hour (single scripted pass; cost is elaboration, not lines written).

**Depends on**: 1

**Files to modify**:
- 56 files under `Theories/Bimodal/Metalogic/`, as enumerated in `push_neg_sites.txt`. Top-heavy:
  `WeakCanonical/EFGames/GapDetection.lean` (201), `WeakCanonical/Expressiveness/SplitPoint.lean`
  (65), `BXCanonical/Chronicle/CounterexampleElimination.lean` (26),
  `WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (23) — 315 of 505 in 4 files.

**Verification**:
- Zero `push_neg` deprecation warnings remain in the build log.
- `lake build`: 0 errors, exactly 1 live sorry at `WeakCanonical/Transfer.lean`.
- **Category-count differential (equality, not reduction)**: `defProp`, `dupNamespace`,
  `defsWithUnderscore`, and every tier-3 in-scope category hold their Phase 1 baseline values
  exactly. Sibling categories being *reduced* is a trespass signal, not a bonus.
- No `longLine` regression is possible (both tokens are 8 chars) — but confirm the count is
  unchanged anyway, since it is one of the frozen categories.

---

### Phase 3: Statement-Identical Alias Swaps (32 sites, 7 files) [NOT STARTED]

**Goal**: Replace four deprecated lemma names with their statement-identical successors.

**Tasks**:
- [ ] `Fin.coe_castSucc` → `Fin.val_castSucc` (17 sites).
- [ ] `Fin.lt_iff_val_lt_val` → `Fin.lt_def` (10 sites).
- [ ] `List.chain_cons` → `List.isChain_cons_cons` (4 sites). Note `List.chain_cons` is *already*
      stated in terms of `IsChain`, so this is a pure rename.
- [ ] `List.take_succ` → `List.take_add_one` (1 site). **This is the known collision**:
      `List.take_succ` is a strict prefix of the distinct, non-deprecated `List.take_succ_cons`
      used at `SharedWitness.lean`. Position-anchoring is what prevents corrupting it. A naive
      global replace produced `List.take_add_one_cons` and surfaced as a `rewrite` failure a line
      away, plus a spurious `unusedSimpArgs` warning.
- [ ] Run the per-file revert-on-regression gate.
- [ ] Run full `lake build`.
- [ ] Commit at green.

**Timing**: 45 minutes.

**Depends on**: 2

**Files to modify**:
- 7 files under `Theories/Bimodal/Metalogic/`, as enumerated in `other_sites.txt` for these four
  symbols. Includes `Kamp/NfMultiAnchorBridge/SharedWitness.lean` (the collision site).

**Verification**:
- Zero deprecation warnings for these four symbols.
- `grep -c 'List.take_succ_cons'` in `SharedWitness.lean` is unchanged from baseline — the
  collision target survived intact.
- `lake build`: 0 errors, exactly 1 live sorry.
- Frozen category counts hold exactly (including `unusedSimpArgs`, whose spurious appearance was
  the tell for the collision during research).

---

### Phase 4: Wrapper Deletion, `Option.iget`, and Import Swap (7 sites, 4 files) [NOT STARTED]

**Goal**: Apply the three small one-off edit classes.

**Tasks**:
- [ ] **`Finset.le_iff_subset` (4 sites, 2 files)**: the lemma is now the tautology
      `s₁ ⊆ s₂ ↔ s₁ ⊆ s₂`. All four uses have the form `Finset.le_iff_subset.mp (Finset.le_sup …)`;
      delete the string `Finset.le_iff_subset.mp ` leaving `(Finset.le_sup …)`, which typechecks
      directly. `VVecEA2Collapse.lean` and `ZetaUniformExtract.lean` contain near-identical
      duplicated blocks — verify both, do not assume symmetry.
- [ ] **`Option.iget` pair (2 adjacent sites, `ShiftAndGlue.lean`)**:
      `(Encodable.decode (α := α) n).iget` → `(Encodable.decode (α := α) n).getD default`, and
      `Encodable.surjective_decode_iget α` → `Encodable.surjective_decode_getD α default`.
      `surjective_decode_getD` requires an explicit default; an `Inhabited α` instance is already
      in scope three lines above, so `default` resolves.
- [ ] **Import swap (`MonadicFO.lean`)**: the warning is reported at `:7:0` but **line 7 is
      `import Mathlib.Data.Fintype.Card`** — Lean reports module-level import deprecations at the
      header position. The actual edit target is `import Mathlib.Data.Finite.Card` →
      `import Mathlib.SetTheory.Cardinal.NatCard`. This is the one edit with genuine cross-file
      reach (8 modules import `MonadicFO`); the full-build gate covers it.
- [ ] Run full `lake build`.
- [ ] Commit at green.

**Timing**: 45 minutes.

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/**/VVecEA2Collapse.lean` - delete `Finset.le_iff_subset.mp ` wrapper
- `Theories/Bimodal/Metalogic/**/ZetaUniformExtract.lean` - same wrapper deletion
- `Theories/Bimodal/Metalogic/**/ShiftAndGlue.lean` - `iget` → `getD default` pair
- `Theories/Bimodal/Metalogic/**/MonadicFO.lean` - import swap (edit the `Finite.Card` line, **not**
  the line the warning names)

**Verification**:
- Zero deprecation warnings for `Finset.le_iff_subset`, `Option.iget`,
  `Encodable.surjective_decode_iget`, and `Mathlib.Data.Finite.Card`.
- `lake build`: 0 errors, exactly 1 live sorry; job count still 1875 (the import swap is the edit
  most likely to perturb it — investigate any change).
- Frozen category counts hold exactly.

---

### Phase 5: `List.Chain` → `List.IsChain` in `SharedWitness.lean` (13 sites) [NOT STARTED]

**Goal**: Apply the only shape-changing edit class. **This is the sole phase requiring per-edit
reasoning** — do not batch it with a script and do not merge it into another phase.

**Tasks**:
- [ ] Apply the three transformations, reasoning about each site individually:
  - `List.Chain R a l` → `List.IsChain R (a :: l)` — e.g.
    `List.Chain (· < ·) lo (mid ++ [hi])` → `List.IsChain (· < ·) (lo :: (mid ++ [hi]))`
  - `List.Chain.cons` → `List.IsChain.cons_cons`
  - `List.Chain.nil` → `(List.IsChain.singleton _)`
- [ ] Note the bridge holds **definitionally**: `List.Chain R a l = List.IsChain R (a :: l)` by
      `rfl` (verified), and both coercion directions typecheck by `exact h` — so proofs survive
      the statement rewrite.
- [ ] Four of the six `List.Chain` occurrences sit in **theorem statements**
      (`kvE2_sepGapRegions_pos`, `kvE2_sepChain_lt_between`, `kvE2_sepGapRegions_lo_le`,
      `kvE2_sepGapRegions_hi_le`). All call sites are inside `SharedWitness.lean` itself — no
      downstream module references them, so the API change is contained. Re-verify this before
      editing rather than assuming it.
- [ ] After each statement rewrite, check the proof body several lines onward — a changed
      statement can break a proof at a distance.
- [ ] Confirm resulting lines stay under the 100-char `longLine` limit (research measured a peak
      of 79).
- [ ] Run full `lake build`.
- [ ] Commit at green.

**Timing**: 1 hour.

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Kamp/NfMultiAnchorBridge/SharedWitness.lean` - 13 sites: 6
  `List.Chain`, 2 `List.Chain.cons`, 1 `List.Chain.nil`, plus the associated statement rewrites

**Verification**:
- Zero `List.Chain*` deprecation warnings.
- `lake build`: 0 errors, exactly 1 live sorry.
- Frozen category counts hold exactly, **including `longLine`** — this is the one phase that can
  lengthen a line.

---

### Phase 6: Full-Build Gate and Closeout [NOT STARTED]

**Goal**: Assert the end state globally and close out the task.

**Tasks**:
- [ ] Run a clean full `lake build` from a fresh state, capturing the log.
- [ ] Assert the complete end-state contract (below).
- [ ] Confirm `Boneyard/` is untouched: it still holds its 176 `push_neg` occurrences, and
      `git diff` shows no `Boneyard/` paths.
- [ ] Confirm no declaration was renamed and no `def` became a `theorem` (sibling territory).
- [ ] Write the implementation summary to
      `specs/400_clear_lean_v433_deprecation_warnings/summaries/01_clear-deprecation-warnings-summary.md`.
- [ ] Final commit.

**Timing**: 30 minutes.

**Depends on**: 5

**Files to modify**:
- `specs/400_clear_lean_v433_deprecation_warnings/summaries/01_clear-deprecation-warnings-summary.md` - new

**Verification**:
- `lake build`: **0 errors**, **0 deprecation warnings**, **1875 jobs**, exactly **1**
  `declaration uses \`sorry\`` in `WeakCanonical/Transfer.lean`.
- `Bimodal.Metalogic.BXCanonical.completeness` remains the single declaration whose axiom set
  includes `sorryAx`.
- All frozen categories at their Phase 1 baseline values, exactly.

---

## Testing & Validation

- [ ] `lake build` returns 0 errors at **every** phase boundary — not only at the end.
- [ ] Exactly 1 live sorry at every phase boundary, located by **content** in
      `WeakCanonical/Transfer.lean` (never by line number).
- [ ] Build targets are `Bimodal.*`, **not** `Theories.Bimodal.*` (`srcDir := "Theories"`,
      `roots := #[\`Bimodal]`) — a wrong target name yields a vacuous pass.
- [ ] Category-count differential gate is **equality-based**: sibling-owned categories must be
      UNCHANGED, so that trespass into their territory is caught. A reduction is a failure signal.
- [ ] `lake env lean` on a single file is **not** accepted as a substitute for `lake build` at any
      boundary — a `DecidablePred` synthesis failure previously showed clean under a per-file
      census and still failed the full build.
- [ ] Verify per file after substitution: a tactic substitution that changes goal state can break a
      proof several lines later.
- [ ] `git diff --stat` touches only files enumerated in the site lists, plus this task's
      `specs/` artifacts.

## Artifacts & Outputs

- `specs/400_clear_lean_v433_deprecation_warnings/plans/01_clear-deprecation-warnings.md` (this file)
- `specs/400_clear_lean_v433_deprecation_warnings/tools/{lintlib,fixers,sweep,runlinter}.py`
  (repaired harness copy)
- `specs/400_clear_lean_v433_deprecation_warnings/summaries/01_clear-deprecation-warnings-summary.md`
- Modified sources: 60 files under `Theories/Bimodal/Metalogic/`
- Six commits, one per phase, each at a verified-green `lake build`

## Rollback/Contingency

- **Per-file**: `sweep.py`'s revert-on-regression gate reverts any file that fails its differential
  check, leaving the rest of the pass intact.
- **Per-phase**: each phase is committed only at a green build, so `git revert` of a single phase
  commit restores a known-good state without disturbing earlier phases.
- **Mid-phase**: if a phase fails its build gate, fix forward — correct the source rather than
  discarding uncommitted work. If a rollback is genuinely required, run
  `bash .claude/scripts/git-snapshot.sh` first (mandatory before any destructive git operation on
  a dirty tree).
- **Phase 5 specifically**: if the `List.Chain` shape change proves harder than the research
  indicates, phases 1-4 already stand green and committed; Phase 5 can be deferred to a follow-up
  without regressing the other 540 sites.
