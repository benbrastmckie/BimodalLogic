# Implementation Plan: Irreflexive Completeness (v8)

- **Task**: 109 - Irreflexive completeness for chain construction
- **Status**: [NOT STARTED]
- **Effort**: 30 hours
- **Dependencies**: Task 93 (reflexive completeness on `until` branch)
- **Research Inputs**: reports/10_reflexive-until-evaluation.md, reports/11_team-research.md, reports/12_van-benthem-analysis.md
- **Artifacts**: plans/12_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Establish sorry-free completeness for irreflexive G/H semantics (the paper's intended semantics) on the `irr_until` branch. This plan presupposes that task 93 has achieved sorry-free reflexive completeness on the `until` branch. The strategy draws on reports 09-12 which established: (1) the B1 convention (irreflexive G/H with reflexive U/S) is the optimal Until/Since choice for irreflexive completeness, (2) the enriched-seed chain with Ordered Seed Consistency handles F-resolution under irreflexive G, and (3) no clean conservative extension exists for the Until/Since language, so irreflexive completeness requires a separate (though structurally parallel) proof.

The key mathematical challenge unique to the irreflexive setting is F-resolution: under irreflexive G, `g_content(M) ⊄ M`, so F-obligations can be silently destroyed by Lindenbaum extensions. The enriched-seed approach (carrying all F-obligations explicitly at every chain step) overcomes this. The Ordered Seed Consistency theorem, already proved sorry-free on the `until` branch, provides the foundation.

### Research Integration

- Report 10 (reflexive-until-evaluation.md): B1 convention analysis. BX10 → BX10' replacement. Enriched-seed chain construction under irreflexive G. 6-phase implementation sketch.
- Report 11 (team-research.md): No conservative extension for U/S. Branch strategy (work on `until` first). 130/166 files identical between branches.
- Report 12 (van-benthem-analysis.md): Van Benthem's irreflexivity undefinability result poses no obstruction. For basic G/H, irreflexive/reflexive validities coincide. Until/Since validities genuinely differ — hence separate proof needed.

### Key Decision: B1 Convention

The plan adopts the **B1 semantic convention**:

| Operator | Convention | Semantics |
|----------|-----------|-----------|
| G(φ) | Irreflexive | ∀s, t < s → φ(s) |
| H(φ) | Irreflexive | ∀s, s < t → φ(s) |
| φ U ψ | Reflexive | ∃s ≥ t, ψ(s) ∧ ∀r ∈ [t,s), φ(r) |
| φ S ψ | Reflexive | ∃s ≤ t, ψ(s) ∧ ∀r ∈ (s,t], φ(r) |

This preserves BX8 (ψ → φ U ψ, sound with reflexive Until witness s = t) and BX9 ((φ U ψ) → φ ∨ ψ, sound with half-open guard covering t). Only BX10 needs replacement with BX10' ((φ U ψ) → ψ ∨ F(ψ)).

### Alternative: Fully Irreflexive (A2 Convention)

If the paper requires fully irreflexive Until/Since (strict witnesses), the A2 convention loses BX8 and requires either Venema-style axioms or a quasimodel approach. This is a fundamentally different proof architecture estimated at 40-60 additional hours. Phase 5 of this plan provides a decision point.

## Goals & Non-Goals

**Goals**:
- Establish sorry-free `bx_completeness` on `irr_until` under B1 convention (irreflexive G/H, reflexive U/S)
- Verify soundness of the modified axiom system
- Adapt the chain construction from `until` for irreflexive G using enriched seeds
- Produce `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`

**Non-Goals**:
- Reflexive completeness (handled by task 93 on `until` branch)
- Fully irreflexive (A2) completeness (separate task if B1 is insufficient)
- Dense completeness (task 68)
- Merging `until` into `irr_until` (cherry-pick specific files instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Enriched-seed consistency proof fails under irreflexive G (BX1 not available) | H | L | Ordered Seed Consistency theorem does NOT use BX1 — proof verified in report 10, Section 4.3. Uses only temp_4, MCS consistency, G/F duality. |
| F-defect re-emergence creates infinite cycling | M | M | Report 10, Section 4.5: cycling is bounded by \|Σ\| and every defect is resolved infinitely often. Schedule surjectivity ensures termination. |
| BX10' is insufficient where BX10 was needed | M | L | In MCS contexts, BX10' is equivalent to BX10 when ψ ∉ M (report 10, Section 2.3). The reflexive base case (ψ ∈ M) is handled by BX8. |
| g_content(M) ⊄ M breaks existing chain proofs | H | M | Port proofs carefully. `forward_G` property still holds (temp_4 + g_content propagation, report 10 Section 4.6). `bx_le_refl` stays sorry — not on critical path. |
| Paper requires fully irreflexive Until (A2), not B1 | M | M | Phase 5 decision point. If A2 is required, create follow-up task for Venema-style axiomatization. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

All phases are sequential. Each depends on the previous.

---

### Phase 1: Semantic and Axiom System Adaptation [NOT STARTED]

**Goal**: Modify Truth.lean and Axioms.lean for the B1 convention. Get the project compiling.

**Tasks**:
- [ ] Cherry-pick or port the sorry-free chain construction from `until` branch's `RootScopedChain.lean` (once task 93 completes)
- [ ] Modify `Truth.lean`: change G clause `t ≤ s` → `t < s`, H clause `s ≤ t` → `s < t`. Keep Until/Since as `t ≤ s` / `s ≤ t` (reflexive, B1)
- [ ] Modify `Axioms.lean`:
  - Replace BX1 (`temp_t_future: G(φ) → φ`) with seriality (`serial_future: ⊤ → F(⊤)`)
  - Replace BX1' (`temp_t_past: H(φ) → φ`) with seriality (`serial_past: ⊤ → P(⊤)`)
  - Keep BX8/BX8' (ψ → φ U ψ / ψ → φ S ψ) — sound under B1
  - Replace BX10 with BX10': `(φ U ψ) → ψ ∨ F(ψ)`
  - Replace BX10' (since) with: `(φ S ψ) → ψ ∨ P(ψ)`
- [ ] Fix all Axiom pattern match compilation errors throughout the codebase
- [ ] Run `lake build` — fix iteratively until compilation succeeds (expect errors in soundness, Frame.lean, TemporalDerived.lean)

**Timing**: 6 hours

**Depends on**: none (but presupposes task 93 completed on `until`)

**Files**: Truth.lean, Axioms.lean, various files with Axiom pattern matches

---

### Phase 2: Re-prove Soundness [NOT STARTED]

**Goal**: Fix all soundness proofs for the modified axiom system.

**Tasks**:
- [ ] Prove soundness of `serial_future` (⊤ → F(⊤)): under irreflexive G on any linear order without maximum, ∃s > t (seriality). Use order properties of the temporal domain.
- [ ] Prove soundness of `serial_past` symmetrically
- [ ] Prove soundness of BX10' ((φ U ψ) → ψ ∨ F(ψ)): reflexive Until witness s ≥ t. If s = t: ψ(t). If s > t: F(ψ). Sound.
- [ ] Verify BX8 soundness under B1: reflexive Until witness s = t, guard [t,t) = ∅, ψ(t). Sound.
- [ ] Verify all other axiom soundness proofs transfer (BX2-BX7, BX9, BX11-BX12 — should be unchanged or strengthened)
- [ ] Fix `g_content_set_consistent` to use seriality instead of BX1 (reference `irr_until` branch's existing proof)
- [ ] Fix `h_content_set_consistent` symmetrically
- [ ] `lake build` — soundness module compiles sorry-free

**Timing**: 6 hours

**Depends on**: 1

**Files**: Soundness.lean, SoundnessLemmas.lean, Frame.lean

---

### Phase 3: Adapt Chain Construction for Irreflexive G [NOT STARTED]

**Goal**: Modify the chain construction so that F-resolution works under irreflexive G where `g_content(M) ⊄ M`.

**Tasks**:
- [ ] Verify `fwd_succ_g_content` still holds: g_content(chain(n)) ⊆ chain(n+1). This uses the Lindenbaum seed including g_content — unchanged by irreflexive G.
- [ ] Verify `forward_G` property: G(φ) ∈ chain(t) → φ ∈ chain(s) for all s > t. Proof via temp_4 + g_content propagation — does NOT use BX1 (confirmed in report 10, Section 4.6).
- [ ] Adapt `fwd_chain_forward_F` for irreflexive G:
  - Under irreflexive G, F(φ) is not directly preserved by g_content
  - The `f_carry` enrichment must explicitly include all F-obligations in the seed
  - Verify `f_carry` consistency: `{target} ∪ g_content(M) ∪ f_carry(M)` is consistent. Under irreflexive G, this requires the Ordered Seed Consistency theorem (does NOT use BX1).
  - If `f_carry` seed consistency fails, implement the enriched-seed approach from report 10 Section 4.2: at each step, include all F-defects in the seed explicitly.
- [ ] Adapt `fwd_chain_F_obligation_monotone` (F-not-return): proof uses only temp_4 + MCS properties — should transfer directly.
- [ ] Handle the key difference: under irreflexive G, `bx_le_refl` is NOT provable. Mark it with a clear comment; it is NOT on the completeness critical path.
- [ ] Close `dd_bfmcs_restricted_tc` (F/P resolution) using the adapted chain
- [ ] `lake build`

**Timing**: 10 hours

**Depends on**: 2

**Files**: CanonicalModel.lean, RootScopedChain.lean, Frame.lean

---

### Phase 4: Adapt Until/Since Coherence and Final Audit [NOT STARTED]

**Goal**: Close the remaining coherence sorries and achieve sorry-free completeness.

**Tasks**:
- [ ] Adapt `dd_bfmcs_restricted_fuc` (forward Until coherence):
  - BX10' gives ψ ∨ F(ψ) from (φ U ψ). If ψ: resolved reflexively (BX8). If F(ψ): use F-resolution from Phase 3.
  - Guard persistence via BX5 + BX9 — unchanged from reflexive proof
- [ ] Adapt `dd_bfmcs_restricted_buc` (backward Until coherence):
  - BX8 still available (reflexive Until intro): base case ψ → φ U ψ works
  - Step transfer: same argument as reflexive proof since Until is reflexive under B1
  - This should transfer with minimal changes from the `until` branch proof
- [ ] Run `#print axioms bx_completeness` — target: no `sorryAx`
- [ ] Run full `lake build`
- [ ] Grep for remaining sorries in BXCanonical
- [ ] Document any remaining sorries (e.g., `bx_le_refl`)
- [ ] Update task description and ROADMAP

**Timing**: 6 hours

**Depends on**: 3

**Files**: RootScopedChain.lean, Completeness.lean

---

### Phase 5: Evaluate A2 Convention Necessity [NOT STARTED]

**Goal**: Decision point — determine if the paper requires fully irreflexive Until/Since (A2) or if B1 (reflexive U/S, irreflexive G/H) is acceptable.

**Tasks**:
- [ ] Review the paper's semantic definitions for Until/Since
- [ ] If B1 is acceptable: task 109 is COMPLETE
- [ ] If A2 is required: create a follow-up task for Venema-style axiomatization with fully irreflexive Until/Since. This would need:
  - New axioms replacing BX8 (e.g., `G(φ ∨ ψ) ∧ φ ∧ F(ψ) → φ U ψ`)
  - New axioms replacing BX10 (already strict under A2)
  - Quasimodel or enriched chain construction that handles strict Until
  - Estimated 40-60 additional hours
- [ ] Document the decision and rationale

**Timing**: 2 hours

**Depends on**: 4

**Files**: Documentation only

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each modified theorem confirms no `sorryAx`
- [ ] `#print axioms bx_completeness` checked at Phase 4
- [ ] Soundness module compiles sorry-free (Phase 2)
- [ ] Chain construction compiles under B1 convention (Phase 3)
- [ ] All 3 coherence properties (tc, buc, fuc) sorry-free (Phase 4)

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/12_implementation-plan.md` (this file)
- Modified source files (`irr_until` branch):
  - `Theories/Bimodal/Semantics/Truth.lean` — G/H from ≤ to <
  - `Theories/Bimodal/ProofSystem/Axioms.lean` — BX1→seriality, BX10→BX10'
  - `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` — Re-proved for B1
  - `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Adapted chain
  - `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — Adapted coherence
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable
- Phase 1 fallback: if B1 convention creates too many cascading changes, consider porting the sorry-free `until` branch as a separate Lean module alongside the irreflexive one
- Phase 3 fallback: if enriched-seed consistency fails under irreflexive G despite report 10's analysis, investigate whether the `irr_until` branch's existing soundness infrastructure can be repurposed for a semantic completeness (full MCS space) approach
- Phase 5: if A2 is required, the B1 completeness proof is still valuable infrastructure and can serve as the foundation for A2 work
- Overall: if irreflexive completeness stalls, the reflexive completeness on `until` (task 93) is a publishable result on its own
