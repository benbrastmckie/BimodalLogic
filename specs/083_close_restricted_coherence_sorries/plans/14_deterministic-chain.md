# Implementation Plan: Deterministic Chain for Sorry-Free Completeness over Int

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (self-contained; does NOT affect FMP completeness path)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/14_team-research.md
- **Artifacts**: plans/14_deterministic-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The sole remaining blocker for sorry-free `completeness_over_Int` is X-content propagation through the successor chain. Under strict semantics, `until_unfold` yields X-formulas, but the successor seed only propagates g_content. Research report 14 identified the root cause: two standard temporal logic axioms (X-K distribution and X-Det determinism) are missing from the axiom system, exposed by the strict-semantics transition.

The solution is to add X-K + X-Det (and Y duals), then replace the dovetailed chain construction with a deterministic chain where `chain(n+1) = x_content(chain(n))`. With X-K + X-Det, x_content of an MCS is itself an MCS, eliminating the need for Lindenbaum extension, fair scheduling, and seed consistency arguments. The truth lemma Until/Since cases then follow by structural induction on Until-depth.

### Research Integration

Report 14 (team research, 2 teammates) established:
- X-K is NOT derivable from current 33 axioms (95% confidence)
- X-K + X-Det are standard and sound on discrete linear frames (99% confidence)
- x_content(M) is MCS when X-K + X-Det are axioms (mathematical proof sketched)
- Deterministic chain construction is SIMPLER than dovetailed chain
- Truth lemma strategy using Until-depth induction with non-constructive F-witness

## Goals & Non-Goals

**Goals**:
- Add X-K, X-Det, Y-K, Y-Det axioms to the TM axiom system
- Prove soundness of the new axioms on discrete linear frames
- Build deterministic chain construction (chain(n+1) = x_content(chain(n)))
- Close all 8 critical-path sorries for `completeness_over_Int`
- Close the 4 ParametricTruthLemma Until/Since sorries
- Close the 2 UltrafilterChain sorries (succ_chain_restricted_forward_F/backward_P)
- Archive or delete the dovetailed chain's fair scheduling infrastructure

**Non-Goals**:
- FMP TruthPreservation (task 82 scope)
- dense_completeness_fc (task 68 scope)
- The old full-coherence sorry (bfmcs_from_mcs_temporally_coherent, bypassed by restricted path)
- RestrictedTruthLemma dead-code sorries (restricted_chain_G_step, restricted_chain_H_step) -- these have zero references and can be left or deleted

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| X-K is actually derivable (making axiom addition unnecessary but harmless) | L | L | Axiom is sound regardless; redundancy is benign |
| Axiom addition breaks existing proofs via new pattern-match cases | M | M | Phase 1 is purely additive; `lake build` catches all missing cases |
| x_content MCS proof has a gap (e.g., X_bot_absurd is not available) | H | L | Verify X_bot_absurd derivability from disc_next before Phase 2 |
| Truth lemma Until induction measure is not well-founded in Lean | M | M | Use `Formula.sizeOf` or explicit `Nat` measure; test early |
| Backward chain (y_content) has asymmetries vs forward chain | M | L | Y-K + Y-Det are symmetric duals; same proof strategy applies |
| Interaction with existing 33 axiom pattern matches (many files) | M | H | Grep for all `Axiom.` pattern matches; update systematically in Phase 1 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add X-K + X-Det Axioms and Update Pattern Matches [COMPLETED]

**Goal**: Extend the axiom system with 4 new constructors and achieve `lake build` success with no new sorries (existing sorries unchanged).

**Tasks**:
- [ ] Add 4 constructors to `Axiom` inductive in `Axioms.lean`:
  - `x_k_dist (phi psi : Formula)` : `Axiom (X(phi.imp psi).imp (X(phi).imp X(psi)))` where X(a) = Formula.untl Formula.bot a
  - `x_det (phi : Formula)` : `Axiom ((X(phi)).neg.imp (X(phi.neg)))` -- determinism of Next
  - `y_k_dist (phi psi : Formula)` : `Axiom (Y(phi.imp psi).imp (Y(phi).imp Y(psi)))` where Y(a) = Formula.snce Formula.bot a
  - `y_det (phi : Formula)` : `Axiom ((Y(phi)).neg.imp (Y(phi.neg)))` -- determinism of Previous
- [ ] Update `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible`, `Axiom.isBase`, `Axiom.frameClass` predicates
- [ ] Add 4 substitution cases in `Substitution.lean` (mechanical: `Axiom.x_k_dist (a.subst q r) (b.subst q r)`, etc.)
- [ ] Add 4 `sorry` cases in `Soundness.lean` general soundness (these are discrete-only axioms)
- [ ] Add 4 soundness proofs in `soundness_discrete_valid` or equivalent
- [ ] Add pattern match cases in `SoundnessLemmas.lean` if needed
- [ ] Update any `cases h_ax with` exhaustive matches throughout codebase
- [ ] Run `lake build` to verify no regressions

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- 4 new constructors + predicate updates (~40 lines)
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- 4 new pattern cases (~20 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness proof cases (~80 lines)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- pattern match updates (~10 lines)
- Any other files with exhaustive `Axiom` pattern matches (find via `lake build` errors)

**Verification**:
- `lake build` succeeds
- No new sorries introduced (existing sorry count unchanged except soundness general cases for discrete axioms)
- `lean_verify` on key theorems unchanged

---

### Phase 2: Prove x_content/y_content are MCS [NOT STARTED]

**Goal**: Establish that `x_content(M) = {a | X(a) in M}` is an MCS when M is an MCS, using the new axioms.

**Tasks**:
- [ ] Define `x_content` and `y_content` formally (may already exist; check `TemporalContent.lean`)
- [ ] Derive `X_bot_absurd : ⊢ ¬X(⊥)` from `disc_next` and propositional logic
- [ ] Prove `x_content_consistent`: if L subset x_content(M) and L derives ⊥, then M is inconsistent (using X-Nec + X-K)
- [ ] Prove `x_content_deductively_closed`: if a, a->b in x_content(M) then b in x_content(M) (using X-K)
- [ ] Prove `x_content_maximal`: for all p, either p in x_content(M) or neg(p) in x_content(M) (using X-Det + MCS maximality)
- [ ] Combine into `x_content_mcs : SetMaximalConsistent M -> SetMaximalConsistent (x_content M)`
- [ ] Prove symmetric `y_content_mcs` for the backward direction
- [ ] Derive useful X-distribution lemmas in `TemporalDerived.lean`:
  - `X_conj : ⊢ X(a) ∧ X(b) → X(a ∧ b)` (from X-K)
  - `X_neg : ⊢ ¬X(a) ↔ X(¬a)` (from X-Det + X-K)

**Timing**: 2.5 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- x_content_mcs theorem (~100 lines)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- X-distribution derived theorems (~50 lines)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- x_content/y_content definitions if needed

**Verification**:
- `lake build` succeeds
- `lean_verify` on `x_content_mcs` shows no sorry dependencies
- `lean_goal` inspection of key proof states

---

### Phase 3: Build Deterministic Chain and Prove Properties [NOT STARTED]

**Goal**: Replace the dovetailed chain with `chain(n+1) = x_content(chain(n))` and prove G-coherence, box_class_agree, and Until persistence.

**Tasks**:
- [ ] Define `deterministic_chain (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0) : Nat -> Set Formula` where `chain(0) = M_0`, `chain(n+1) = x_content(chain(n))`
- [ ] Prove `deterministic_chain_mcs` : each chain element is MCS (from x_content_mcs)
- [ ] Prove G-coherence: `G(a) in chain(n) -> a in chain(m)` for all m > n
  - Sub-lemma: `G(a) in chain(n) -> G(a) in chain(n+1)` via temp_4 + G->X + x_content
  - Induction on m - n
- [ ] Prove box_class_agree propagation: `box(a) in chain(n) -> box(a) in chain(n+1)` via temp_a + G->X
- [ ] Prove Until persistence: `(phi U psi) in chain(n), psi not in chain(n) -> (phi U psi) in chain(n+1) AND phi in chain(n+1)`
  - Uses until_unfold: X(psi or (phi and (phi U psi))) in chain(n)
  - x_content gives: psi or (phi and (phi U psi)) in chain(n+1)
  - Case split on psi vs phi and (phi U psi)
- [ ] Prove symmetric backward chain using y_content
- [ ] Build the full chain over Int: forward (Nat) + backward (Nat) + stitch at 0
- [ ] Prove the combined chain has forward_G, backward_H, forward_box, backward_box properties
- [ ] Archive or mark dead-code the dovetailed chain infrastructure (DovetailedChain.lean)

**Timing**: 3 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` or new `DeterministicChain.lean` -- chain definition + properties (~250 lines)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- archive or mark as dead code

**Verification**:
- `lake build` succeeds
- Chain properties verified sorry-free via `lean_verify`
- DovetailedChain sorries become irrelevant (dead code)

---

### Phase 4: Truth Lemma Until/Since Cases [NOT STARTED]

**Goal**: Close the 4 Until/Since sorry sites in ParametricTruthLemma.lean using the deterministic chain's Until persistence and the Until-depth induction strategy.

**Tasks**:
- [ ] Establish the Until-depth measure on Formula (may use existing `Formula.sizeOf` or define custom)
- [ ] Prove forward Until truth lemma: `(phi U psi) in chain(t) -> truth(phi U psi, t)`
  - Step 1: `(phi U psi) in chain(t)` implies `F(psi) in chain(t)` via `until_implies_some_future`
  - Step 2: By IH on F(psi) (lower Until-depth since F(psi) = neg(G(neg(psi)))): truth(F(psi), t), giving witness s > t with truth(psi, s)
  - Step 3: Take minimal s. By IH backward on psi: psi in chain(s)
  - Step 4: For intermediate r in (t,s): psi not in chain(r) (minimality), so by Until persistence: phi in chain(r) and (phi U psi) in chain(r). By IH on phi: truth(phi, r)
  - Step 5: Combine for truth(phi U psi, t)
- [ ] Prove backward Until truth lemma: `truth(phi U psi, t) -> (phi U psi) in chain(t)`
  - By contrapositive: neg(phi U psi) in chain(t) -> truth(neg(phi U psi), t) -> not truth(phi U psi, t)
- [ ] Prove forward/backward Since cases (symmetric)
- [ ] Close the 4 sorry sites in `parametric_truth_lemma` and `shifted_parametric_truth_lemma`

**Timing**: 3 hours

**Depends on**: Phase 2 (needs x_content_mcs for Until persistence proof in the truth lemma induction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- close 4 sorries (~200 lines)

**Verification**:
- `lake build` succeeds
- `lean_verify` on `parametric_truth_lemma` and `shifted_parametric_truth_lemma` shows no sorry
- All 4 sorry sites closed

---

### Phase 5: Wire Deterministic Chain to completeness_over_Int [NOT STARTED]

**Goal**: Close the 2 UltrafilterChain sorries (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`) and connect the deterministic chain to the existing completeness theorem structure.

**Tasks**:
- [ ] Replace or provide the `succ_chain_restricted_forward_F` proof using deterministic chain's F-resolution
  - The deterministic chain's truth lemma gives: F(psi) in chain(n) -> truth(F(psi), n) -> exists m > n, truth(psi, m) -> psi in chain(m) (by backward truth lemma)
- [ ] Replace or provide the `succ_chain_restricted_backward_P` proof symmetrically
- [ ] Verify that the `restricted_shifted_truth_lemma` now has all inputs sorry-free
- [ ] Verify that `completeness_over_Int` compiles without sorry on the critical path
- [ ] Clean up: delete or archive dead code paths (RestrictedTruthLemma dead-code sorries if desired)

**Timing**: 2 hours

**Depends on**: Phase 3 (deterministic chain properties), Phase 4 (truth lemma)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- close 2 sorries (~80 lines)
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- optional cleanup
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- verify wiring

**Verification**:
- `lake build` succeeds
- `lean_verify` on `completeness_over_Int` shows no sorry on critical path
- Sorry count decreases by at least 8 from baseline

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, sorry audit, and dead-code cleanup.

**Tasks**:
- [ ] Run `lake build` from clean state
- [ ] Run `lean_verify` on `completeness_over_Int` and all key theorems
- [ ] Audit remaining sorries: separate critical-path from non-critical
- [ ] Archive dovetailed chain infrastructure to Boneyard if not already done
- [ ] Update module docstrings to reflect new axiom system (37 axioms, not 33)
- [ ] Verify FMP completeness path is unaffected

**Timing**: 1.5 hours

**Depends on**: Phase 5

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- archive to Boneyard
- Various files -- docstring updates

**Verification**:
- `lake build` succeeds from clean state
- `lean_verify Bimodal.Metalogic.Algebraic.UltrafilterChain.completeness_over_Int` reports no sorry
- FMP completeness path unaffected (verify `lean_verify` on FMP theorems)

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `lean_verify` on `completeness_over_Int` shows no sorry on critical path after Phase 5
- [ ] `lean_verify` on all 4 new axiom soundness proofs (discrete frame)
- [ ] `lean_verify` on `x_content_mcs` and `y_content_mcs`
- [ ] Sorry count audit: baseline vs final (expect -8 to -14 net reduction)
- [ ] FMP completeness path unaffected: `lean_verify` on FMP theorems unchanged
- [ ] No axiom regressions: `lean_verify` on existing theorems

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/14_deterministic-chain.md` (this file)
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- extended with 4 new axiom constructors
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- x_content_mcs + deterministic chain
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- Until/Since cases closed
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- X/Y distribution theorems
- `Theories/Bimodal/Boneyard/` -- archived dovetailed chain infrastructure

## Rollback/Contingency

- **Phase 1 rollback**: `git revert` the axiom addition commit. All existing proofs unchanged since new axioms are purely additive.
- **Phase 2-5 rollback**: Revert to Phase 1 state. The 4 new axioms remain (sound and harmless) but deterministic chain is removed.
- **Alternative approach**: If x_content MCS proof fails (Phase 2), investigate whether Y-K/Y-Det can be derived from X-K/X-Det via temporal duality, reducing to 2 axioms. If the entire approach fails, fall back to the dovetailed chain with enriched seed (harder but does not require new axioms).
- **Partial success**: If truth lemma Until case proves difficult (Phase 4), the deterministic chain (Phase 3) is still valuable infrastructure. Mark Phase 4 as [PARTIAL] and resume.
