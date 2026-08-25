# Implementation Summary: Documentation Anchor Correction

- **Task**: 484 — Documentation anchor correction: `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md`
- **Plan**: `specs/484_documentation_anchor_roadmap_and_metalogic_readme/plans/01_anchor-doc-correction.md`
- **Report**: `specs/484_documentation_anchor_roadmap_and_metalogic_readme/reports/01_anchor-doc-verification.md`
- **Status**: all 7 phases COMPLETED
- **Type**: lean4 (prose and markdown only — zero `.lean` changes)

## Outcome

Both anchor documents are corrected against source. All nine asserted defects (A1-A4, B1-B5) are
repaired, with the three that research found materially larger than the task description stated
(A3, B4, B5) repaired at their true size. Every figure written was derived at implementation time
from Lean source, `lean_verify`, or the invariant script's own `live_files` walk — none was copied
from another markdown document.

## Verification

| Gate | Baseline (at `e0d92a930`) | Final | Verdict |
|------|---------------------------|-------|---------|
| `bash scripts/check-module-invariants.sh` | ALL CHECKS PASSED (exit 0) | ALL CHECKS PASSED (exit 0) | no regression |
| `bash scripts/readme-lint.sh` | 9 missing READMEs / 5 broken refs | 9 missing / 5 broken | no regression |
| C5 (module paths resolve) | PASS | PASS | held |
| C7 (`Metalogic 314`) | 314 | 314 | matches the rewritten inventory |
| C8 (aggregator convention) | PASS | PASS | held |
| C9 (no task-number citations under `FormalSystem/`) | PASS | PASS | held |
| `.lean` files in diff | — | none | held |
| `grep 'axiom-free'` in both anchors | — | no match | held |
| Layer table rows | 24 (summing to 42) | 45 | matches enumeration |

`readme-lint.sh` still exits FAIL on its pre-existing 9/5; that is the recorded baseline, and
fixing it was an explicit non-goal. `FormalSystem/Metalogic/README.md` is no longer among the
READMEs Check 4 flags for a missing "Last verified" date.

Additional implementation-time verification:

- `lean_verify FormalSystem.Metalogic.completeness_dedekind` -> `[propext, Classical.choice, Quot.sound]`
- `lean_verify FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` -> `[propext, Classical.choice, Quot.sound]`
- A script cross-check confirmed the rebuilt layer table's 45 rows are exactly the 45
  `inductive Axiom` constructors, with every `Axioms.lean:NN` citation matching the enumerated
  line, no duplicates, and no phantom rows.

## What changed

### `specs/ROADMAP.md` (Phases 1-3)

- **A1**: the `isValid`-to-validity bridge bullet now records that the SOUND direction has landed
  (`sound_of_isValid` `Correctness.lean:100`, `isValid_sound` `:111`) and that the completeness
  direction remains open, transcribed from the in-source obligation at `Correctness.lean:209-224`.
  The stale `decide_sound'` citation was corrected `:66` -> `:71`.
- **A2/A3**: headline and `## BX Axiom System` intro corrected to 45 constructors in nine layers.
  The layer table was rebuilt from a fresh enumeration: three phantom rows removed
  (`temp_k_dist`, `temp_4`, `temp_future` — derived theorems, not constructors), three layers
  added (7 Z1, 8 Density, 9 Reynolds Dedekind), and all 45 line citations refreshed. A `File:Line`
  column was added to Layers 5 and 6, which previously had none, so every row is now checkable.
- **A4**: `completeness_dedekind`'s axiom profile recorded in a paragraph typographically separate
  from the C2 baseline, attributed to `FormalSystem/Metalogic.lean:57-60` and `#print axioms`, and
  explicitly flagged as not a checked invariant.

### `FormalSystem/Metalogic/README.md` (Phases 4-6)

- **B1**: the false axiom-set code block (which recorded `completeness` as depending on `sorryAx`)
  replaced by a pointer to check **C2** of `scripts/check-module-invariants.sh`, cited by path and
  check name without a line number so the pointer cannot itself drift.
- **B2**: the false one-structural-sorry inventory replaced by the verified ZERO per C3;
  `countermodel_discrete` relocated to `WeakCanonical/GroupModel/CountermodelBase.lean`; the
  paragraph explaining a `sorryAx` dependency that does not exist deleted.
- **B4**: the Lake root paragraph rewritten from C8's own comment.
- **B5**: every file/line figure refreshed; `Independence/`, `DenseModelSurgery/`, `GroupModel/`,
  `RealModel/`, and `EANegationFixFaithful/` added; the loose non-aggregator list corrected from
  two entries to five; a "Last verified" line added.

### `FormalSystem/Metalogic/BXCanonical/README.md` (Phase 5)

- **B3**: the single row at line 13 corrected — `BXCanonical.lean` is a sibling at
  `FormalSystem/Metalogic/BXCanonical.lean`, 43 lines, not a 28-line file inside `BXCanonical/`.

## Plan Deviations

1. **D1 — gated deviation from the task's DO-NOT-TOUCH instruction (pre-declared in the plan).**
   The task designated `specs/ROADMAP.md:21-46` untouchable, but `:28-29` carried the same false
   claim A1 exists to remove. A single clause was narrowed; the item, its headline, the section,
   and every other line in `:21-46` are unchanged. `git diff` confirms exactly one hunk inside
   that range.

   Before:
   > `DecisionProcedure.isValid` (`…DecisionProcedure.lean:317`) has no theorem anywhere
   > relating it to semantic validity — no `isValid φ fc = true → ⊨ φ` biconditional exists,
   > proven or otherwise

   After:
   > `DecisionProcedure.isValid` (`…DecisionProcedure.lean:317`) has its *sound* direction
   > proved (`isValid_sound`, `Correctness.lean:111`), but no `isValid φ fc = true ↔ ⊨ φ`
   > biconditional exists, proven or otherwise — and the biconditional is the property the name
   > `isValid` invites a reader to assume

   If this deviation is rejected on review, revert only that hunk; the `:109-115` rewrite stands
   independently.

2. **Altered — two citations diverged from research report §3.2, and the source won.** The plan's
   D2 said to keep `Axioms.lean:55-59` cited for the Burgess/Xu/Venema references. Source shows
   those references are at `Axioms.lean:72-74`; `:55-59` is the modal-temporal/total block. The
   ROADMAP's claim that Reynolds 1992 is cited inline at `Axioms.lean:309` is likewise stale —
   Reynolds is cited on the Dedekind constructors at `:426`, `:437`, `:449`. Both corrected to
   the observed values. D2's substance is unaffected: the count is anchored on
   `Axioms.lean:571-582`, and no `.lean` file was edited.

3. **Altered — a stale task pointer dropped.** The rewritten A1 bullet no longer carries
   `**ADD, task 480**` (`bridge_isvalid_bool_to_semantic_validity`); that named target is exactly
   what landed as `isValid_sound`, so the pointer would have been a fresh inaccuracy.

4. **Scope note.** The dispatch declared a `file_scope` of `specs/ROADMAP.md` and
   `FormalSystem/Metalogic/README.md`. Phase 5 of the plan additionally requires the single
   line-13 row of `FormalSystem/Metalogic/BXCanonical/README.md` (defect B3, whose real location
   research corrected). That one row was changed as the plan specifies; the rest of that file was
   left to the downstream README pass.

No other deviations. Constructor names and all 45 line numbers matched research report §3.2
exactly, and every §4.5 inventory figure matched the recomputed `live_files` walk.

## Handoff to the downstream 42-to-45 sweep

Per decision D2, `FormalSystem/ProofSystem/Axioms.lean:58` ("42 axiom constructors") and `:84`
("42 constructors organized into eight layers") are **still stale** and were deliberately not
edited — no `.lean` change was permitted here. `specs/ROADMAP.md` now quotes both explicitly as
stale so a reader is not misled in the interim.

The downstream sweep can consume the verified enumeration below rather than redoing it. The
partition is 4 / 5 / 18 / 4 / 1 / 5 / 2 / 1 / 2 / 3 = **45**, across nine layers (Layer 3 is split
into 3 and 3b in-source):

| Layer | Count | Constructors (`Axioms.lean` line) |
|-------|------:|-----------------------------------|
| 1 Propositional | 4 | `prop_k` 103, `prop_s` 106, `ex_falso` 108, `peirce` 110 |
| 2 S5 Modal | 5 | `modal_t` 113, `modal_4` 115, `modal_b` 117, `modal_5_collapse` 119, `modal_k_dist` 121 |
| 3 BX Temporal | 18 | `serial_future` 128, `serial_past` 132, `left_mono_until_G` 138, `left_mono_since_H` 144, `right_mono_until` 149, `right_mono_since` 153, `connect_future` 158, `connect_past` 162, `enrichment_until` 171, `enrichment_since` 179, `self_accum_until` 189, `self_accum_since` 194, `absorb_until` 201, `absorb_since` 205, `linear_until` 211, `linear_since` 220, `until_F` 241, `since_P` 246 |
| 3b Additional BX Temporal | 4 | `temp_linearity` 253, `temp_linearity_past` 261, `F_until_equiv` 270, `P_since_equiv` 275 |
| 4 Modal-Temporal Interaction | 1 | `modal_future` 283 |
| 5 Uniformity | 5 | `discrete_symm_fwd` 291, `discrete_symm_bwd` 296, `discrete_propagate_fwd` 302, `discrete_propagate_bwd` 308, `discrete_box_necessity` 316 |
| 6 Prior for Integers | 2 | `prior_UZ` 330, `prior_SZ` 335 |
| 7 Z1 | 1 | `z1` 347 |
| 8 Density | 2 | `density` 358, `dense_indicator` 369 |
| 9 Reynolds Dedekind | 3 | `prior_U_gap` 431, `prior_S_gap` 441, `sep` 452 |

Traps the sweep must not fall into:

- `temp_k_dist`, `temp_4`, and `temp_future` are **derived theorems, not constructors**. A
  different `temp_4` exists at `FormalSystem/BaseLanguage/Axioms.lean:99` on `BLFormula` — a
  different inductive.
- The in-source `-- Layer N` comments are wrong on two counts: `Axioms.lean:123` says Layer 3 is
  20 (it is 18) and `:349` says Layer 8 is 1 (it is 2). Only enumeration is authoritative.
- "Nine layers" is the value downstream sites should converge on. `FormalSystem/README.md:79` and
  `FormalSystem/ProofSystem/README.md:22` currently say "eight".

Remaining out-of-scope sites carrying the stale count (from research report §3.2, unverified
since): `FormalSystem/ProofSystem/Axioms.lean:58`, `:84`; `FormalSystem/README.md:79`, `:92`,
`:94`, `:200`, `:282`; `FormalSystem/ProofSystem/README.md:12`, `:22`, `:23`, `:40`;
`FormalSystem/Automation/Tactics/Helpers.lean:33`, `:1103`;
`FormalSystem/Automation/ProofSearch/Core.lean:322`;
`FormalSystem/Metalogic/Decidability/ProofExtraction.lean:27`;
`Tests/BimodalTest/Automation/ProofFirstTests.lean:36`; `typst/SYNC-MAP.md:149`, `:216`, `:246`,
`:283`, `:302`, `:350`; `docs/research/competitive-landscape.md:101`, `:341`, `:344`.

## Files Modified

- `specs/ROADMAP.md`
- `FormalSystem/Metalogic/README.md`
- `FormalSystem/Metalogic/BXCanonical/README.md`
