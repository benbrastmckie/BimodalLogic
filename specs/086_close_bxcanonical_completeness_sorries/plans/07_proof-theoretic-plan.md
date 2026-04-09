# Implementation Plan: Close usf_completeness imp Case B via Proof-Theoretic Route

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [BLOCKED]
- **Effort**: 5 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/07_team-research.md, reports/06_usf-completeness-path.md
- **Artifacts**: plans/07_proof-theoretic-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single remaining sorry in `usf_completeness` (imp Case B, CanonicalEmbedding.lean:418) using a direct proof-theoretic argument that completely bypasses the semantic gap. The strategy uses BX axioms and derivation machinery to derive `⊢ ψ → χ` structurally, without building a countermodel. The prior plan (06) was based on combined F-seed chain construction, which was invalidated because G does not distribute over disjunction and constant-history backward G truth lemma is structurally impossible. The FMP bridge approach is also inappropriate — it faces the same branching-vs-linear mismatch as the direct canonical model construction (see ROADMAP.md). Definition of done: `lake build` succeeds with zero sorries in CanonicalEmbedding.lean.

### Research Integration

- **Report 07** (team-research.md): 4-teammate research confirming all three obstructions (combined F-seed inconsistency, F-formula non-persistence, constant-history backward G). Identified proof-theoretic Case B (60% confidence) and USF normal form reduction (45%) as most promising new directions.
- **Report 06** (usf-completeness-path.md): Combined F-seed chain approach -- INVALIDATED by research report 07.

### Prior Plan Reference

Prior plan 06 proposed 4 sequential phases: combined F-seed consistency, dovetail history + omega, bidirectional truth lemma, sorry closure. Total estimated effort was 10 hours. The plan was blocked at Phase 1 because the combined F-seed consistency assumption is mathematically false (G does not distribute over disjunction). Effort calibration suggests 5 hours for the revised approach: 3 hours exploration + 2 hours formalization.

### Roadmap Alignment

ROADMAP.md documents the FMP bridge as dead end #10 (faces same branching-vs-linear mismatch). The proof-theoretic approach is the active path for USF completeness.

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
- FMP bridge to completeness (faces same branching-vs-linear mismatch, see ROADMAP.md)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct proof-theoretic argument has a logical gap we haven't seen | H | M | Phase 1 is pure exploration with explicit go/no-go gate before committing |
| Proof-theoretic argument fails, leaving sorry intact | H | M | Phase 1 is designed to produce reusable lemmas even if sorry remains; partial progress is preserved; task marked [BLOCKED] with detailed analysis |
| Lean4 formalization of proof-theoretic argument is significantly harder than pen-and-paper | M | M | Use lean-lsp tools (lean_goal, lean_multi_attempt) for interactive development; budget extra time |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Proof-Theoretic Derivation of imp Case B [BLOCKED]

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

### Phase 2: Formalize and Close Sorry [NOT STARTED]

**Goal**: Formalize the proof strategy from Phase 1 into a complete Lean proof replacing the sorry at CanonicalEmbedding.lean:418.

**Tasks**:
- [ ] Implement the proof strategy identified in Phase 1 in Lean 4
- [ ] Use `lean_goal` at each step to verify proof state
- [ ] Use `lean_multi_attempt` to test tactic candidates
- [ ] Replace the `sorry` at line 418 with the complete proof
- [ ] Run `lake build` and verify zero errors
- [ ] Run grep for `sorry` in CanonicalEmbedding.lean to confirm zero remain
- [ ] Verify the 4 Frame.lean sorries are unchanged (no regression)
- [ ] Update module docstring to remove "sorry" references from the imp Case B description

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- replace sorry with proof, update docstring

**Verification**:
- `lake build` succeeds with zero errors
- `grep -c sorry Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns 0
- The 4 Frame.lean Until/Since sorries remain unchanged

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] Zero sorries in `CanonicalEmbedding.lean` after Phase 2
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows only the expected Frame.lean sorries (lines 646, 668, 683, 697)
- [ ] No regression in existing sorry-free proofs (fragment_completeness, fragment_truth_iff, G_iff_mcs, etc.)

## Artifacts & Outputs

- `plans/07_proof-theoretic-plan.md` (this file)
- `summaries/07_execution-summary.md` (after implementation)
- `ROADMAP.md` (updated with dead ends #7-10)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` (sorry closure)

## Rollback/Contingency

- All changes are additive (new lemmas) except the sorry replacement in Phase 2
- If Phase 1 fails at its go/no-go gate, the sorry remains with updated comments documenting the investigation. The task should be marked [BLOCKED] with a description of why the proof-theoretic approach failed.
- If Phase 2 formalization hits Lean-specific issues, preserve all helper lemmas and keep the sorry with a detailed comment explaining the proof strategy that works on paper but needs further Lean engineering.
- Git provides full rollback via `git revert` on individual phase commits.
