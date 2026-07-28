# Phase 7.1c — the truth-lemma induction, four cases of six

**Date**: 2026-07-28l · **Dispatch**: seventh on Phase 7 · **Status**: PARTIAL

## Phases executed

Phase 7 only, sub-phase 7.1c, resuming from the prior dispatch's committed prerequisites. Phase 7
remains `[PARTIAL]`; 7.1c remains unchecked because its "done when" is sorry-free at ℤ for both
classes and two cases are owed.

## What landed

Four green commits, each verified before it was made.

### `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean` (new, registered)

- `normWorld` / `normModel` — Correction 10 (below).
- `stateLabel` — the label a carrier point reads. Unifies the placed readback
  (`truthAt_atom_branch_placed`) and the gap readback (`truthAt_atom_branch_region`) into one
  `iff`, `truthAt_atom_state`.
- `BranchTruthAt` — the induction predicate, signed and one-directional in each sign.
- `branchTruthAt_atom`, `branchTruthAt_bot`, `branchTruthAt_imp`, `branchTruthAt_box` —
  **sorry-free**, and generic in the carrier `D` and the placement `f`, so sub-phase 7.1d
  inherits them unchanged. The `box` case was written first and closes exactly as the
  region-labelling decision predicted.
- `OrderFaithful`, `RayOnly` — what the temporal cases need of a placement, stated without a
  `LinearOrder` instance on `BranchTime b`.
- `intPlace`, `intPlace_injective`, `le_intPlace_of_branchLE`, `orderFaithful_intPlace`,
  `rayOnly_intPlace` — the ℤ instantiation, `finiteOrderEmbInt` used directly.
- `branchTruthAt` — the assembled six-case induction.
- `not_valid_of_hasOpen_int`, `not_validDiscrete_of_hasOpen_int` — the two headline results,
  complete modulo the two temporal cases.
- `branchTruthAt_untl`, `branchTruthAt_snce` — **the two tracked strategic sorries**.

### `Tests/BimodalTest/RayRegionProbe.lean` (new, registered)

Seven `#guard_msgs` rows measuring the ray self-demand on engine output plus one synthetic
non-vacuity row.

## Corrections this dispatch forced

**Correction 10 — the model must normalise worlds the branch never mentions.** `regionOmega f`
ranges over all of `WorldIndex` (`Nat`) and `truthAt_box_iff_base` quantifies over it, so a single
unmentioned world falsifies `□p` on a branch carrying `T(□p)`. `normWorld` reads every carrier
world as a known one. No signature moves.

**Correction 11 — "ℤ is the easy milestone" holds only for the interior.** Contiguity does empty
the interior gaps. It does not supply region invariance, which needs `DenselyOrdered` and is
machine-refuted at ℤ by the in-tree `not_exists_gt_sameRegion_int`. The two rays are therefore
infinite regions handled one point at a time at ℤ, where at ℚ/ℝ one lemma handles each region
wholesale. This inverts the sub-phase ordering's rationale for the `untl`/`snce` cases
specifically; it leaves the four landed cases untouched.

## Probe before proving — the hypothesis was refuted, again

Correction 11 suggested a specific defect: the gate asks nothing about what a region's chosen
label demands of the region itself, and an upper-ray point has no witness above it outside its own
ray. Measured before being stated in `Verified/`: `rayUp` and `rayDn` are `true` on all six engine
rows alongside `check=true`. So it is a **candidate additional gate row**, not a refutation of
`regionLabelCheck`. Row G pins a synthetic branch with `check=true rayUp=false`, so the condition
has content. Fourth consecutive dispatch in which probing first changed the conclusion.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1113 jobs |
| `lake env lean …/Bridge/IntTruth.lean` | green, only the two intended `sorry` warnings |
| `lake env lean Tests/BimodalTest/RayRegionProbe.lean` | green, all seven rows pass |
| `lake build BimodalTest` | `RayRegionProbe` built (job 1976/1978); the target fails on `WeakCanonical/DenseModelSurgery/BadIntervals.lean`, which is **uncommitted work from a concurrent session** and out of territory |
| `lean-sorry-census.sh …/Verified/` | `sorry_count: 2`, both the tracked temporal cases |
| vacuous definitions | 0 |
| new axioms | 0 |

## Sorry inventory

Two, both strategic, both in `IntTruth.lean`, both with the four remaining items enumerated in the
file and in the plan's 2026-07-28l banner:

1. `branchTruthAt_untl` (line 434)
2. `branchTruthAt_snce` (line 444)

## Plan deviations

7.1c's "done when: sorry-free at ℤ for both classes" is **not** met and the item stays unchecked;
the deviation is annotated inline on the item.
