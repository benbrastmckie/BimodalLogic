# Implementation Plan: Close usf_completeness imp Case B via Proof-Theoretic Route

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/07_team-research.md, reports/06_usf-completeness-path.md
- **Artifacts**: plans/07_proof-theoretic-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single remaining sorry in `usf_completeness` (imp Case B, CanonicalEmbedding.lean:418) using a proof-theoretic argument that completely bypasses the semantic gap. The strategy splits into two approaches tried in sequence: (1) direct structural argument using available BX axioms and derivation machinery, (2) FMP bridge via USF truth lemma on closure MCS. Both avoid the known-impossible constant-history semantic construction. The prior plan (06) was based on combined F-seed chain construction, which was invalidated because G does not distribute over disjunction and constant-history backward G truth lemma is structurally impossible. Definition of done: `lake build` succeeds with zero sorries in CanonicalEmbedding.lean.

### Research Integration

- **Report 07** (team-research.md): 4-teammate research confirming all three obstructions (combined F-seed inconsistency, F-formula non-persistence, constant-history backward G). Identified proof-theoretic Case B (60% confidence) and USF normal form reduction (45%) as most promising new directions.
- **Report 06** (usf-completeness-path.md): Combined F-seed chain approach -- INVALIDATED by research report 07.

### Prior Plan Reference

Prior plan 06 proposed 4 sequential phases: combined F-seed consistency, dovetail history + omega, bidirectional truth lemma, sorry closure. Total estimated effort was 10 hours. The plan was blocked at Phase 1 because the combined F-seed consistency assumption is mathematically false (G does not distribute over disjunction). Effort calibration suggests 8 hours is appropriate for the new approach, accounting for the exploratory nature of the proof-theoretic route but avoiding the dovetail chain machinery entirely.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Close the sorry at CanonicalEmbedding.lean:418 (imp Case B of `usf_completeness`)
- Achieve zero sorries in CanonicalEmbedding.lean
- Use only sorry-free infrastructure already available in the codebase
- Avoid all known-impossible approaches (combined F-seed, constant histories, flatten reduction)

**Non-Goals**:
- Close the 4 Frame.lean Until/Since sorries (require Until-induction, orthogonal to USF)
- Build non-constant-history canonical models (no chain construction)
- Prove bx_le linearity (may be needed for Until/Since but not for this approach)
- General completeness for all formulas (only USF fragment)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct proof-theoretic argument has a logical gap we haven't seen | H | M | Phase 1 is pure exploration with explicit go/no-go gate before committing |
| FMP bridge (Phase 2) requires a truth lemma on closure MCS that has same difficulty as full truth lemma | H | M | Closure MCS are restricted to subformula closure, which may simplify; go/no-go gate at end of Phase 2 |
| Both approaches fail, leaving sorry intact | H | L | Phases are designed to produce reusable lemmas even if sorry remains; partial progress is preserved |
| Lean4 formalization of proof-theoretic argument is significantly harder than pen-and-paper | M | M | Use lean-lsp tools (lean_goal, lean_multi_attempt) for interactive development; budget extra time |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 (only if Phase 1 fails) |
| 3 | 3 | 1 or 2 |

Phases within the same wave can execute in parallel. Phase 2 is only attempted if Phase 1 reaches its go/no-go gate without success. Phase 3 uses whichever of Phase 1 or 2 succeeds.

### Phase 1: Proof-Theoretic Derivation of imp Case B [NOT STARTED]

**Goal**: Derive `⊢ ψ → χ` directly from `valid (ψ → χ)` using BX axioms and the structural induction hypothesis, without building a semantic countermodel.

**Tasks**:
- [ ] Analyze the sorry site context: we have `h_valid : valid (ψ.imp χ)`, `h_usf : untilSinceFree (ψ.imp χ)`, `¬valid ψ`, and `h_not_deriv : ¬Nonempty (DerivationTree [] (ψ.imp χ))`. Goal: `False`.
- [ ] Investigate if `valid (ψ → χ)` combined with `¬valid ψ` yields additional structural information via the sub-formula IH. Specifically:
  - `¬valid ψ` means ∃ model M where ψ is false at some point
  - If χ were valid, then `ih_χ` gives `⊢ χ`, then `prop_s χ ψ` gives `⊢ χ → (ψ → χ)`, then modus_ponens gives `⊢ ψ → χ` -- contradiction with h_not_deriv
  - So χ is NOT valid either. Both ψ and χ are not individually valid.
- [ ] Investigate the case analysis on the outermost connective of χ:
  - If χ = atom/bot: χ is temporal-free, so `fragment_completeness` handles `ψ → χ` if ψ is also temporal-free. Check if this case can be dispatched separately.
  - If χ = G(α): `valid (ψ → G(α))` implies `valid (ψ → α)` (by temp_t_future / validity reduction). Then `ih` on `ψ → α` may give `⊢ ψ → α`. From `⊢ ψ → α` need to get `⊢ ψ → G(α)` -- this requires temporal necessitation on `ψ → α` giving `G(ψ → α)`, then temp_k_dist giving `G(ψ) → G(α)`, but we need `ψ → G(α)`, not `G(ψ) → G(α)`.
  - If χ = H(α): mirror of G case
  - If χ = box(α): `valid (ψ → box(α))` does NOT reduce to `valid (ψ → α)` -- box has different quantification
  - If χ = imp(α, β): recursive, handled by IH on α, β
- [ ] Investigate a case analysis on the outermost connective of ψ (the antecedent):
  - If ψ = G(α): ψ not valid means ∃ countermodel for G(α). But `valid (G(α) → χ)`. Since `temp_t_future` gives `⊢ G(α) → α`, we have `valid (α → χ)` does NOT follow from `valid (G(α) → χ)`.
- [ ] Determine if there is a proof-theoretic decomposition of `valid (ψ → χ)` for USF ψ, χ that can be reduced to strictly simpler valid formulas where the IH applies. The key challenge: the imp connective does not decrease temporal depth, so induction on temporal depth does not help directly.
- [ ] **Go/no-go gate**: If a clear proof strategy emerges with a concrete Lean sketch, proceed to formalize it. If after 3 hours no viable path is found, proceed to Phase 2.

**Timing**: 3 hours (with hard stop at go/no-go gate)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add helper lemmas if proof-theoretic route works

**Verification**:
- If successful: `lake build` with zero new sorries
- If go/no-go reached: documented analysis of why direct route failed, proceed to Phase 2

---

### Phase 2: FMP Bridge via Closure MCS Truth Lemma [NOT STARTED]

**Goal**: Prove `valid (ψ.imp χ) → ψ.imp χ ∈ S.carrier` for all `S : ClosureMCSBundle (ψ.imp χ)` where ψ, χ are USF. Combined with sorry-free `fmp_contrapositive`, this yields `⊢ ψ → χ`.

**Tasks**:
- [ ] Understand `ClosureMCS` structure: a closure MCS for `ψ.imp χ` is an MCS restricted to formulas in `subformulaClosure (ψ.imp χ)`. The closure is FINITE (bounded by sub-formulas). This finiteness may simplify the truth lemma.
- [ ] Investigate building a FINITE canonical model from closure MCS where truth corresponds to membership:
  - Define a canonical model on `ClosureMCSBundle (ψ.imp χ)` using the filtration structure
  - The `FilteredWorld` type already exists in the FMP module
  - Need: truth lemma restricted to sub-formulas of `ψ.imp χ` (all of which are USF)
- [ ] Key simplification for USF on finite models: the sub-formula closure of a USF formula contains only USF sub-formulas. On a finite model with finitely many "worlds" (closure MCS), the temporal quantifiers G/H range over finite linear orders. The truth lemma for G/H on finite linear orders may be tractable without chain construction.
- [ ] Investigate whether the existing `filtered_model_truth_lemma` or similar infrastructure in the FMP module already provides what's needed (the filtration truth lemma for sub-formulas)
- [ ] If filtration truth lemma exists or can be proved: combine with `valid → true in all models → true in finite model → φ ∈ S.carrier` to close the gap
- [ ] **Go/no-go gate**: If closure MCS truth lemma is achievable, proceed to formalize. If it reduces to the same branching-vs-linear mismatch, document and proceed to Phase 3 alternative.

**Timing**: 3 hours (with hard stop)

**Depends on**: 1 (only if Phase 1 fails at its go/no-go gate)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add FMP bridge lemma
- Possibly `Theories/Bimodal/Metalogic/Decidability/FMP/` -- extend filtration truth lemma if needed

**Verification**:
- If successful: `lake build` with zero new sorries
- If go/no-go reached: documented analysis

---

### Phase 3: Formalize and Close Sorry [NOT STARTED]

**Goal**: Formalize whichever approach succeeded in Phase 1 or 2 into a complete Lean proof replacing the sorry at CanonicalEmbedding.lean:418.

**Tasks**:
- [ ] Implement the proof strategy identified in Phase 1 or 2 in Lean 4
- [ ] Use `lean_goal` at each step to verify proof state
- [ ] Use `lean_multi_attempt` to test tactic candidates
- [ ] Replace the `sorry` at line 418 with the complete proof
- [ ] Run `lake build` and verify zero errors
- [ ] Run grep for `sorry` in CanonicalEmbedding.lean to confirm zero remain
- [ ] Verify the 4 Frame.lean sorries are unchanged (no regression)
- [ ] Update module docstring to remove "sorry" references from the imp Case B description

**Timing**: 2 hours

**Depends on**: 1 or 2 (whichever succeeds)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- replace sorry with proof, update docstring

**Verification**:
- `lake build` succeeds with zero errors
- `grep -c sorry Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns 0
- The 4 Frame.lean Until/Since sorries remain unchanged

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] Zero sorries in `CanonicalEmbedding.lean` after Phase 3
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows only the expected Frame.lean sorries (lines 646, 668, 683, 697)
- [ ] No regression in existing sorry-free proofs (fragment_completeness, fragment_truth_iff, G_iff_mcs, etc.)

## Artifacts & Outputs

- `plans/07_proof-theoretic-plan.md` (this file)
- `summaries/07_execution-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` (sorry closure)

## Rollback/Contingency

- All changes are additive (new lemmas) except the sorry replacement in Phase 3
- If both Phase 1 and Phase 2 fail at their go/no-go gates, the sorry remains with updated comments documenting the investigation. The task should be marked [BLOCKED] with a description of why both approaches failed.
- If Phase 3 formalization hits Lean-specific issues, preserve all helper lemmas and keep the sorry with a detailed comment explaining the proof strategy that works on paper but needs further Lean engineering.
- Git provides full rollback via `git revert` on individual phase commits.
- Fallback: if proof-theoretic and FMP routes both fail, consider marking the sorry as a genuine open problem and documenting it as such, since 7 research iterations have exhausted known approaches.
