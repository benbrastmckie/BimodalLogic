# Implementation Summary: Truth Layer Simp Normal Form

- **Task**: 521 — Truth layer simp normal form
- **Plan**: `specs/521_truth_layer_simp_normal_form/plans/01_truth-layer-simp-normal-form.md`
- **Status**: COMPLETED — all ten phases `[COMPLETED]`, no exclusions
- **Type**: lean4

## What was built

`FormalSystem/Semantics/Truth.lean` now has the `@[simp]` characterization API its base-language
mirror `BLTruth.lean` has always had, and the call sites that the API makes rewritable have been
rewritten. The attribute is only the enabler; the call-site rewrite is the work.

- **New module** `FormalSystem/Automation/TruthNormAttr.lean` (55 lines) declaring
  `register_simp_attr truth_norm`, `register_simp_attr swap_norm`, and the `truth_simp` macro.
  It is a sibling of `NormalizationAttr.lean`, not an amendment of it: that file's docstring says
  "It must not acquire any other content", and this honours the instruction rather than editing
  it. Deliberately **not** added to `scripts/module-invariants-manifest.txt`.
- **Eleven new `Truth` lemmas**: `neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff`,
  `untl_iff`, `snce_iff`, `always_iff`, `always_iff_tri`, `kPlus_iff`, `kMinus_iff`. Ten carry
  `@[simp, truth_norm]`; `always_iff_tri` is deliberately plain.
- **Five A-17 lemmas**: `truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_cogap`,
  `truthAt_gap_shift`, `truthAt_gap_iff_cogap`.
- **`swap_norm`** collects all eleven `Formula.swap_temporal_*` lemmas, tagged in their declaring
  module so membership holds at every use site.
- **`Truth.lean`'s module docstring** gained a "Simp-normal form" section: the full normal-form
  table, why only one `always` form may be tagged, and the bottom-up caveat about rewriting an
  existing `simp only` list.
- **`TaskFrame.validOn_iff_total`** moved from `Correspondence/FwdRec.lean` to
  `Semantics/Validity.lean`, beside `TaskFrame.ValidOn`.

## Acceptance criterion, scored

Both halves of the restated criterion are **met**.

### (A) Relative, inside the eleven named declarations — target 14 → ≤2

**Result: 14 → 0.**

| Declaration | Baseline lines | Final lines | Ratio | Baseline sites | Final sites |
|---|---|---|---|---|---|
| `temp_l_valid` | 23 | 7 | 30% | 2 | 0 |
| `temp_linearity_valid` | 34 | 14 | 41% | 1 | 0 |
| `discreteness_forward_valid` | 19 | 13 | 68% | 1 | 0 |
| `enrichment_until_valid` | 17 | 9 | 53% | 1 | 0 |
| `enrichment_since_valid` | 17 | 9 | 53% | 1 | 0 |
| `absorb_until_valid` | 21 | 13 | 62% | 1 | 0 |
| `absorb_since_valid` | 19 | 12 | 63% | 1 | 0 |
| `linear_until_valid` | 37 | 22 | 59% | 1 | 0 |
| `linear_since_valid` | 39 | 22 | 56% | 1 | 0 |
| `prior_U_gap_valid` | 36 | 40 | **111%** | 2 | 0 |
| `prior_S_gap_valid` | 36 | 39 | **108%** | 2 | 0 |
| **TOTAL** | **298** | **200** | **67%** | **14** | **0** |

**The "each declaration at most half its baseline length" sub-criterion is NOT met, and this is
reported rather than glossed.** Two of the eleven got *longer*: the two Prior gap proofs. Opening
the consequent's disjunction honestly with `by_cases` on `TruthAt M τ s φ` costs about four more
lines than the old `intro hnn; rintro ⟨w, …⟩; Classical.byContradiction hnn` double-negation
trick did. Only `temp_l_valid` and `temp_linearity_valid` clear 50% outright; the rest land in
the 50-70% band, because each declaration carries 3-6 lines of irreducible signature that no
proof rewrite can shorten. Measured on **proof bodies alone** the picture is better — e.g.
`enrichment_until_valid`'s body went 14 → 6 — but the plan asked for whole-declaration length and
that is what is reported. The aggregate is 298 → 200 lines (67%).

### (B) Absolute, per touched file, before and after

| File | Baseline | Final | Target | Met |
|---|---|---|---|---|
| `Metalogic/Soundness.lean` | 67 | **48** | ≤50 | yes |
| `Metalogic/SoundnessLemmas/CoValidity.lean` | 1 | **0** | 0 | yes |
| `Semantics/Correspondence/DurationFrames.lean` | 0 | 0 | — | — |
| `Metalogic/DedekindNonCompactness.lean` | 0 | 0 | — | — |
| `Metalogic/Independence/CoNotPriorU.lean` | 0 | 0 | — | — |
| `Metalogic/DiscreteNonCompactness.lean` | 0 | 0 | — | — |
| `Semantics/BLTruth.lean` | 5 | 5 | untouched | — |
| `Semantics/Truth.lean` | 19 | **28** | expected to RISE | reported |
| **tree-wide live sites** | **199** | **188** | — | — |

**`Truth.lean` rose 19 → 28, and that is correct, not a regression.** Those sites *are* the
characterization proofs — you cannot prove `and_iff` without unfolding `TruthAt` — and each of
the eleven new lemmas plus the five A-17 lemmas adds one or two. `BLTruth.lean`'s five sites are
irreducible for the same reason and were not touched.

### Other criteria

- `lake build` green at every phase boundary and at the end: **2517 jobs, 0 errors**.
- `check-module-invariants.sh`: **ALL CHECKS PASSED**, including the C6 gate that is the only
  thing that compiles `CoValidity.lean` (plain `lake build` never does — it is a manifested
  known-unreachable module).
- **C2 axiom baseline unchanged**: all four flagship theorems still
  `[propext, Classical.choice, Quot.sound]`.
- **Exactly one `@[simp]`-tagged `always` characterization lemma** (`always_iff`, the collected
  `∀ s` form). `always_iff_tri` is plain.
- **Nine confluence probes** all close under bare `simp`, including the two duals, the
  `untl top φ` / `someFuture φ` convergence, the gap formula, the nesting-termination case
  `always (always (and φ ψ))`, and `strongRelease`/`strongTrigger` composing through the nested
  `and_iff`.
- **Zero sorries, zero new axioms, zero vacuous definitions** introduced. The five `sorry`
  string hits in touched files are docstring prose asserting sorry-freeness; the count is
  unchanged from the baseline commit. The one `:= trivial` grep hit
  (`Examples/TemporalStructures.lean:542`) is pre-existing and untouched.
- **Zero `truth_and_iff` and zero `and_of_not_imp_not` copies** in the eight scoped files.

### The two out-of-scope survivors, named explicitly

Both survive because `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` is out of
scope by orchestrator decision, **not** by oversight:

1. `and_of_not_imp_not'` at `Decidable.lean:2570`, with its three call sites (:2602, :2642, :2779).
2. `Decidable.truthAt_and` at `:1408` — an introduction lemma, not a biconditional.

`FrameClassVariants.lean` (37 sites) and `Decidable.lean` (27 sites) are untouched. The mechanical
sweep across them is a separate task's charter.

## Plan Deviations

| Phase | Deviation | Detail |
|---|---|---|
| 1 | altered | The `truth_simp` macro needed `loc?:(Lean.Parser.Tactic.location)?`; the bare `(location)?` category is not in scope under `import Lean` alone. No move to `Truth.lean` was needed. |
| 1 | recorded | The plan's bare-simp audit command yields **258** lines, not the stated 48. 258 is a superset, so it stayed a valid upper bound on Phase 3's blast radius. Recorded in `baseline.txt`, not silently accepted. |
| 3 | sequencing | Phase 7's five `Truth.lean` A-17 lemmas were landed in Phase 3's edit. They are purely additive and cannot strand a proof, and `Truth.lean` is deep enough in the import graph that each edit costs a ~240-module rebuild; landing them together paid that once. Phase 7 reduced to its `Soundness.lean` rewrites. |
| 3 | none needed | The `@[simp]` batch reddened **zero** sites tree-wide, so the "walk the audit list and repair" step had nothing to do. |
| 5 | altered | All three `validOn_iff_total` references are spelled `TaskFrame.validOn_iff_total`; the lemma now lives inside `namespace TaskFrame`. |
| 5 | skipped | No import was dropped from `FwdRec.lean` — it has exactly one, still required. |
| 6 | altered | No `τ.val`-normalised companion lemma was added, because none is expressible: the four lemmas are *already* stated about the histories, and the obstruction is that `τ` is a `set`-bound `F.HF` local whose `.val` is only definitionally the history. Feeding simp the `set` equation already in scope (`simp only [hτ, X_atom]`) is what collapses all eight sites. Verified: tagging alone leaves simp reporting "made no progress" at seven of the eight. |
| 6 | checked, no change | The seven `clock_atom_truth` / `zTruth_atom` sites stay: they are mid-proof rewrites whose goal still needs work afterwards, so the plan's own "where the tag alone already closes the step" condition is not met. |
| 7 | not needed | The `[reasoned]` dual `truthAt_cogap` **did** land (as `truthAt_gap_iff_cogap`), so `discrete_symm_fwd_valid` and `discrete_symm_bwd_valid` are each a single term and no `#### Reasoned Exclusions` record was required. |
| 9 | altered | In the two Prior gap proofs `and_of_not_imp_not` is deleted outright rather than replaced by `(Truth.and_iff _ _).mp` — once `Truth.and_iff` is in the opening `simp only`, `h_ant` arrives as a real `∧` and a plain `obtain` suffices. Both proofs grew slightly; see the table above. |
| 10 | altered | `Formula.and`/`Formula.neg` were **not** deleted from `sep_valid`/`sep_swap_valid`'s `simp only` lists. That was attempted and reverted: both proofs run on the raw unfolded shapes downstream, and opening the inner `Formula.and` breaks them. The working edit splits `h_ant` with `(Truth.and_iff _ _).mp` *before* the raw `simp only`, which is what actually retires the helper. In `sep_swap_valid` this works by defeq — `swapTemporal` distributes through `Formula.and` — with no rewrite needed. Their 5 further sites stay, as the plan's own bullet allows. |
| process | recorded | Phases 7 and 8 landed in one commit rather than two: both are proof-body-only edits to `Soundness.lean` and Phase 8 was applied before Phase 7's separate commit was made. Both are named in that commit's message. |

## Files modified

New:
- `FormalSystem/Automation/TruthNormAttr.lean`

Modified:
- `FormalSystem/Semantics/Truth.lean`
- `FormalSystem/Syntax/Formula.lean`
- `FormalSystem/Semantics/Validity.lean`
- `FormalSystem/Semantics/Correspondence/FwdRec.lean`
- `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
- `FormalSystem/Metalogic/Soundness.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`
- `FormalSystem/Metalogic/DedekindNonCompactness.lean`
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean`
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean`

Not modified, deliberately: `FormalSystem/Automation/NormalizationAttr.lean`,
`scripts/module-invariants-manifest.txt`,
`FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean`,
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`,
`FormalSystem/Semantics/BLTruth.lean`, and everything under `Metalogic/Bundle/`,
`Syntax/SubformulaClosure/`, `Theorems/`, `Boneyard/`.
