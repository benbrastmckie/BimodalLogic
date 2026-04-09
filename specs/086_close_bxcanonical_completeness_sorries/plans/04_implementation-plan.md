# Implementation Plan: Close usf_completeness imp Case B via Dovetailed Chain Truth Lemma

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/04_restructure-research.md, reports/03_team-research.md
- **Artifacts**: plans/04_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single remaining sorry in `usf_completeness` (imp Case B, CanonicalEmbedding.lean:409) by constructing a two-dimensional canonical model with a bidirectional truth lemma. Research round 4 identified the correct architecture: for each modal-equivalent `v ~ w`, build a dovetailed chain history that visits G/H-backward witnesses, then define Omega as the union of all time-shifts of all such histories. The key enabling lemma is that box formulas are preserved in both directions along `bx_le` chains (proved via S5 negative introspection + `temp_future`), which guarantees modal equivalence is maintained along temporal chains. The 4 Frame.lean Until/Since sorries remain out of scope.

### Research Integration

- **Round 4** (04_restructure-research.md): Exhaustive analysis of all failed approaches (constant histories, flatten, one-directional lemmas, shifts-only Omega, modal_omega-only). Identified the correct two-dimensional construction (dovetail chains through all modal-equivalents) and verified every case of the bidirectional truth lemma. Proved the key box-preservation lemma mathematically.
- **Round 3** (03_team-research.md): Confirmed constant histories are insufficient for G/H backward direction. Identified fragment completeness as achieved. Established that the imp Case B sorry is the single remaining blocker.

## Goals & Non-Goals

**Goals**:
- Prove `box_preserved_along_bx_le`: box formulas propagate both directions along `bx_le`
- Derive `bx_modal_equiv_of_bx_le`: modal equivalence holds along `bx_le` chains
- Build dovetailed chain histories that visit G/H-backward witnesses
- Define two-dimensional Omega (histories through all modal-equivalents, all time-shifts)
- Prove bidirectional truth lemma `chain_truth_iff` on dovetail histories
- Close the sorry at CanonicalEmbedding.lean:409 using the truth lemma
- Achieve zero sorries in CanonicalEmbedding.lean

**Non-Goals**:
- Close the 4 Frame.lean Until/Since sorries (blocked on Until-induction)
- Build a single universal canonical model (surjectivity problem)
- Prove full completeness for formulas containing Until/Since
- Redefine `bx_le` or pursue FMP bridge
- Optimize for computational efficiency (all definitions are `noncomputable`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dovetail chain definition requires complex well-founded recursion | M | M | Use `Denumerable.ofNat` with explicit Nat recursion; all definitions noncomputable |
| G-contrapositive from dovetail construction fails | H | L | Core design property; chain explicitly places witnesses at dovetailed positions |
| Box backward case requires Delta=-s trick on shift-closed Omega | H | L | Verified algebraically in research; time_shift(history, -s) at time s gives chain(0) |
| `respects_task` obligation for dovetail history | L | L | canonical_task_frame has permissive task_rel (d != 0 or states agree); full domain trivially satisfies |
| S5 negative introspection not yet proved as standalone lemma | M | M | Already used implicitly in bx_modal_witness; extract and reuse the argument |
| Interaction between box and G/H in truth lemma induction | M | M | Each case verified in research Section 11; box uses modal_equiv transitivity, G uses chain monotonicity |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Box Preservation and Modal Equivalence Along bx_le [COMPLETED]

**Goal**: Prove that box formulas are preserved in both directions along `bx_le` chains, and that `bx_modal_equiv` holds between any two `bx_le`-related BXPoints.

**Tasks**:
- [ ] Prove `box_preserved_along_bx_le`: `bx_le w v -> (box phi in w <-> box phi in v)`
  - Forward: `box phi in w -> G(box phi) in w` (temp_future) `-> box phi in v` (bx_G_forward)
  - Backward: contrapositive using S5 negative introspection (`neg(box phi) -> box(neg(box phi))`)
- [ ] Extract or prove S5 negative introspection as a standalone lemma if not already available (check existing code in `bx_modal_witness`)
- [ ] Prove `bx_modal_equiv_of_bx_le`: immediate corollary wrapping `box_preserved_along_bx_le`
- [ ] Prove `modal_omega_eq_of_bx_le`: `bx_le w v -> modal_omega w = modal_omega v` (from `bx_modal_equiv_of_bx_le` + existing `modal_omega_eq_of_equiv` if available, or direct proof)
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- add box_preserved_along_bx_le, bx_modal_equiv_of_bx_le

**Verification**:
- `lake build` succeeds with no new sorries
- `#check @box_preserved_along_bx_le` shows expected type signature

---

### Phase 2: Dovetailed Chain Construction [BLOCKED]

**Goal**: Define the dovetailed chain function that maps `Int -> BXPoint` for a given starting BXPoint, visiting G-backward witnesses for positive times and H-backward witnesses for negative times.

**Tasks**:
- [ ] Define `dovetail_chain_pos : BXPoint -> Nat -> BXPoint` for positive direction
  - `dovetail_chain_pos w 0 = w`
  - `dovetail_chain_pos w (n+1)`: let `phi_n = Denumerable.ofNat Formula n`; if `G(phi_n) not-in (dovetail_chain_pos w n).formulas`, use `bx_G_backward` witness; else keep current point
- [ ] Define `dovetail_chain_neg : BXPoint -> Nat -> BXPoint` for negative direction (mirror using `bx_H_backward`)
- [ ] Define `dovetail_chain : BXPoint -> Int -> BXPoint` combining positive and negative
- [ ] Prove `dovetail_chain_zero`: `dovetail_chain w 0 = w`
- [ ] Prove monotonicity: `0 <= m <= n -> bx_le (dovetail_chain w m) (dovetail_chain w n)` and mirror for negative
- [ ] Prove G-completeness: `G(alpha) not-in (dovetail_chain w s).formulas -> exists r > s, alpha not-in (dovetail_chain w r).formulas`
- [ ] Prove G-contrapositive: `(forall r >= s, alpha in (dovetail_chain w r).formulas) -> G(alpha) in (dovetail_chain w s).formulas`
- [ ] Prove H mirrors of the above
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add dovetail chain definitions and properties

**Verification**:
- `lake build` succeeds with no new sorries
- All dovetail chain properties type-check

---

### Phase 3: Dovetail History and Omega Construction [NOT STARTED]

**Goal**: Wrap dovetail chains into `WorldHistory canonical_task_frame` values and define the two-dimensional Omega containing histories through all modal-equivalents.

**Tasks**:
- [ ] Define `dovetail_history : BXPoint -> WorldHistory canonical_task_frame`
  - `domain := fun _ => True`
  - `states := fun t _ => dovetail_chain w t`
  - Prove `convex` (trivial with full domain)
  - Prove `respects_task` using canonical_task_frame's permissive task_rel
- [ ] Define `dovetail_omega : BXPoint -> Set (WorldHistory canonical_task_frame)`
  - Contains `time_shift (dovetail_history v) delta` for all `v` with `bx_modal_equiv w v` and all `delta : Int`
- [ ] Prove `dovetail_omega_shift_closed`: Omega is shift-closed
- [ ] Prove `dovetail_history_mem_omega`: `dovetail_history v in dovetail_omega w` for `v ~ w`
- [ ] Prove `dovetail_history_self_mem`: `dovetail_history w in dovetail_omega w` (since `bx_modal_equiv_refl`)
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add history and omega definitions

**Verification**:
- `lake build` succeeds with no new sorries
- `dovetail_omega_shift_closed` has expected signature

---

### Phase 4: Bidirectional Truth Lemma [NOT STARTED]

**Goal**: Prove the bidirectional truth lemma `chain_truth_iff` for all USF formulas on dovetail histories, which is the core technical result enabling the sorry closure.

**Tasks**:
- [ ] State `chain_truth_iff`: for all USF phi, all `v ~ w`, all `s : Int`:
  `phi in (dovetail_chain v s).formulas <-> truth_at canonical_valuation (dovetail_omega w) (dovetail_history v) s phi`
- [ ] Prove atom case: by definition of `canonical_valuation` and full domain
- [ ] Prove bot case: both sides False (bot_not_in_mcs)
- [ ] Prove imp case: using `imp_iff_mcs` + IH on both sub-formulas
- [ ] Prove box case:
  - Forward: `box phi in chain_v(s)` -> by box_preserved + bx_modal_equiv transitivity -> `box phi in u` for all `u ~ w` -> `phi in chain_u(s')` for all s' -> by IH forward -> `truth_at phi` at all sigma in Omega
  - Backward: for all sigma in Omega, `truth_at phi at (sigma, s)` -> by IH backward at each modal-equivalent u -> `phi in chain_u(s + delta)` for all u,delta -> take delta=-s to get `phi in u` for all `u ~ chain_v(s)` -> `box phi in chain_v(s)`
- [ ] Prove G case:
  - Forward: `G(phi) in chain_v(s)` -> by bx_G_forward + chain monotonicity -> `phi in chain_v(r)` for all `r >= s` -> by IH -> `truth_at phi` at all future times
  - Backward: `truth_at phi` at all `r >= s` -> by IH backward -> `phi in chain_v(r)` for all `r >= s` -> by G-contrapositive from Phase 2 -> `G(phi) in chain_v(s)`
- [ ] Prove H case: mirror of G using H-backward witnesses and negative times
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add chain_truth_iff

**Verification**:
- `lake build` succeeds with no new sorries in the truth lemma
- `#check @chain_truth_iff` confirms the bidirectional iff

---

### Phase 5: Close the Sorry and Verify [NOT STARTED]

**Goal**: Replace the sorry at CanonicalEmbedding.lean:409 with a proof using the truth lemma, achieving zero sorries in CanonicalEmbedding.lean.

**Tasks**:
- [ ] Replace the sorry in `usf_completeness` imp Case B:
  - We have `w : BXPoint` with `psi in w`, `chi not-in w`, `h_valid : valid (psi.imp chi)`
  - Instantiate `h_valid` with `(canonical_task_frame, canonical_valuation, dovetail_omega w, dovetail_history w, 0)`
  - Provide `dovetail_omega_shift_closed w` and `dovetail_history_self_mem w`
  - This gives `truth_at psi -> truth_at chi` at `(dovetail_omega w, dovetail_history w, 0)`
  - By `chain_truth_iff` forward on psi: `psi in w -> truth_at psi` (using dovetail_chain_zero)
  - By `chain_truth_iff` backward on chi: `truth_at chi -> chi in w`
  - Chain: `psi in w -> truth_at psi -> truth_at chi -> chi in w`, contradicting `h_chi_not`
- [ ] Run `lake build` and verify zero errors
- [ ] Verify zero sorries in CanonicalEmbedding.lean: `grep sorry CanonicalEmbedding.lean`
- [ ] Run `lean_verify` on `usf_completeness` to confirm no non-standard axioms
- [ ] Update comments/docstrings to reflect the completed proof

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- replace sorry with proof

**Verification**:
- `lake build` succeeds with zero errors
- `grep -c sorry CanonicalEmbedding.lean` returns 0
- `lean_verify` on `usf_completeness` shows only standard axioms (propext, Quot.sound, Classical.choice)

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] Zero sorries in `CanonicalEmbedding.lean` after Phase 5
- [ ] `lean_verify` on `usf_completeness` confirms no non-standard axioms
- [ ] The 4 Frame.lean Until/Since sorries remain unchanged (not regressed)
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows only the expected Frame.lean sorries

## Artifacts & Outputs

- `plans/04_implementation-plan.md` (this file)
- `summaries/04_execution-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (new lemmas in Phase 1)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` (dovetail construction + sorry closure)

## Rollback/Contingency

- All changes are additive (new definitions and lemmas) except the sorry replacement in Phase 5
- If the truth lemma proves intractable, preserve all new lemmas (they are independently valuable) and keep the sorry with updated comments explaining the progress
- Git provides full rollback via `git revert` on individual phase commits
- If the dovetail chain construction is too complex for Lean's definitional machinery, fall back to a simpler indexed construction using `Fin n -> BXPoint` for a finite set of witness formulas (sufficient for any fixed phi)
