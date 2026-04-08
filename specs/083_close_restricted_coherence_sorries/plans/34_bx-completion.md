# Implementation Plan: BX Canonical Completeness — Phase 4 Completion

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 12-15 hours
- **Dependencies**: None (phases 1-3 complete, Phase 6 complete)
- **Research Inputs**: reports/34_team-research.md (3-teammate synthesis on eventuality resolution, Lean infrastructure, BX literature)
- **Artifacts**: plans/34_bx-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Complete the remaining BXCanonical sorries from plan v33 Phase 4, plus the Soundness.lean refactoring and Phase 5 Boneyard archival. The team research (report 34) identified a clear dependency-ordered strategy: derive key lemmas first (ψ→φUψ, φUψ→F(ψ)), then close Until/Since truth lemma cases, then wire canonical TaskModel for completeness. The Soundness.lean sorries have a unified mechanical fix. This would produce the first mechanized Until/Since canonical completeness proof in any proof assistant.

### Research Integration

Key findings from reports/34_team-research.md (3 teammates, HIGH/MEDIUM-HIGH confidence):

1. **Critical prerequisite**: `ψ → φ U ψ` must be derived from BX axioms (all 3 teammates agree)
2. **Forward Until**: Derive `F(ψ)` from `φ U ψ`, use `bx_forward_witness`, verify guard via BX5+BX7
3. **Backward Until**: Two-case proof using `ψ → φ U ψ` + BX4 contrapositive
4. **Constant histories fail**: G/H truth quantifies over all times, not just one MCS — need rich histories via CanonicalConstruction.lean
5. **Soundness sorries**: All 3 share one root cause (density constraint inheritance from `derivable_valid_and_swap_valid`), single refactoring fix
6. **No prior formalization**: Our work is the first mechanized Until/Since canonical completeness

## Goals & Non-Goals

**Goals**:
- Derive `ψ → φ U ψ`, `φ U ψ → φ ∨ ψ`, `φ U ψ → F(ψ)` as BX-derived theorems
- Close `until_iff_mcs` forward and backward directions (TruthLemma.lean)
- Close `since_iff_mcs` forward and backward directions (mirror)
- Close `bx_completeness` by constructing canonical TaskModel embedding
- Fix 3 Soundness.lean sorries (swap-valid density refactoring)
- Move remaining 7 chain files to Boneyard/
- Clean `lake build` with reduced sorry count

**Non-Goals**:
- FMP TruthPreservation (task 82)
- dense_completeness_fc (task 68)
- Discrete completeness (future work)
- Ordering.lean or EventualityResolution.lean as separate files (integrate into existing files)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ψ → φ U ψ` derivation harder than expected | H | 30% | Try BX3 right-mono first; fallback: derive from soundness+validity if pure syntactic derivation stalls |
| Guard verification for forward Until requires complex BX7 argument | H | 60% | Try direct bx_forward_witness first; fallback to Zorn-based "closest witness" approach |
| Canonical TaskModel embedding conflicts with existing CanonicalConstruction | M | 40% | Reuse CanonicalConstruction.lean components; only add BX-specific wiring |
| Forward Until eventuality resolution genuinely requires new Lean infrastructure | M | 50% | BX5/BX6 MCS consequences are straightforward; Zorn already available via `zorn_subset_nonempty` |
| Soundness refactoring introduces regressions | L | 20% | Incremental: prove `axiom_swap_valid_general` first, then rewire; `lake build` after each step |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Derive Key BX Lemmas [COMPLETED]

**Goal**: Establish the three critical derived theorems that all subsequent truth lemma proofs depend on. These go in `Theorems/TemporalDerived.lean` or a new `BXCanonical/DerivedLemmas.lean`.

**Tasks**:
- [ ] **Derive `psi_imp_until`**: `ψ → φ U ψ` from BX axioms
  - Approach A: Use BX3 (right_mono_until) with `G(⊤ → ψ) → (φ U ⊤ → φ U ψ)`, then show `φ U ⊤` is a theorem via BX1 reflexivity
  - Approach B: Use BX1 + BX5 structure: `ψ` at current time gives reflexive witness
  - Approach C: If pure syntactic derivation stalls, use soundness+completeness bootstrap (derive from semantic validity + the already-proved forward G case)
- [ ] **Derive `until_imp_or`**: `φ U ψ → φ ∨ ψ` from BX axioms
  - Uses `psi_imp_until` contrapositive: `¬(φ U ψ) → ¬ψ`
  - Combined with BX5 self-accumulation structure
  - If `φ U ψ ∈ w` and `ψ ∉ w`, then by reflexive Until semantics, witness v > w, so guard at w requires `φ ∈ w`
- [ ] **Derive `until_imp_F`**: `φ U ψ → F(ψ)` from BX axioms
  - Via BX3 + BX1: `G(ψ → ⊥) → (φ U ψ → φ U ⊥)`, and `φ U ⊥ → ⊥` (no witness for ⊥)
  - Contrapositive: `¬⊥ → ¬(φ U ⊥)`, so `G(¬ψ) → ¬(φ U ψ)`, i.e. `φ U ψ → ¬G(¬ψ) = F(ψ)`
- [ ] **Derive mirrors**: `ψ → φ S ψ`, `φ S ψ → φ ∨ ψ`, `φ S ψ → P(ψ)` using BX3'/BX1'
- [ ] **Derive unfolding** (if needed): `φ U ψ ↔ ψ ∨ (φ ∧ F(φ U ψ))` for backward direction support
- [ ] Run `lake build` to verify all derived theorems compile

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — Add BX-derived Until/Since theorems (~150 LOC)
- Or create `Theories/Bimodal/Metalogic/BXCanonical/DerivedLemmas.lean` if TemporalDerived.lean is too crowded

**Verification**:
- All derived theorems compile with zero sorry
- `lake build` passes
- `psi_imp_until`, `until_imp_or`, `until_imp_F` available as `DerivationTree [] (...)` terms

---

### Phase 2: Fix Soundness.lean Sorries [COMPLETED]

**Goal**: Close the 3 `temporal_duality` sorries at lines 877, 1094, 1151 by factoring `derivable_implies_swap_valid` to remove the density constraint.

**Tasks**:
- [ ] **Create `axiom_swap_valid_general`**: Copy `axiom_swap_valid` (lines 466-702) into a new theorem without `[DenselyOrdered D] [Nontrivial D]` constraints
  - Verify that no case in the match actually uses density (confirmed by Teammate B analysis)
  - Handle the base BX axioms only (no density extension axiom)
- [ ] **Create `derivable_swap_valid_general`**: Mutual induction on derivation tree proving swap-validity without density
  - `axiom` case: `axiom_swap_valid_general`
  - `temporal_duality` case: swap involution + IH (needs both validity and swap-validity from IH)
  - `modus_ponens`, `necessitation`, `temporal_necessitation`: existing helper lemmas
  - `weakening`: structural
- [ ] **Wire into `soundness` (line 877)**: Replace sorry with `derivable_swap_valid_general`
- [ ] **Wire into `soundness_discrete_valid` (line 1094)**: Replace sorry
- [ ] **Wire into `soundness_discrete` (line 1151)**: Replace sorry
- [ ] Run `lake build Bimodal.Metalogic.Soundness` — target zero sorry in temporal_duality cases

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` — Add general swap-valid, wire 3 sorries (~200 LOC)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — Add helper if needed

**Verification**:
- 3 temporal_duality sorries eliminated
- `lake build Bimodal.Metalogic.Soundness` passes
- No regressions in soundness_dense, soundness_dense_valid

---

### Phase 3: Close Until/Since Truth Lemma [NOT STARTED]

**Goal**: Prove `until_iff_mcs` and `since_iff_mcs` in TruthLemma.lean, eliminating the 4 remaining sorries. This is the hardest phase.

**Tasks**:
- [ ] **Backward Until** (easier, do first): Prove `(∃ v ≥ w, ψ ∈ v, φ on [w,v)) → φ U ψ ∈ w`
  - Case 1 (v = w in bx_le sense): `ψ ∈ v`, by `psi_imp_until`: `φ U ψ ∈ v`. Need to transfer to w. If `bx_le v w` also holds, then g_content(v) ⊆ w. Use BX4: `φ U ψ → G(P(φ U ψ))` to get `P(φ U ψ) ∈ w`. But we actually need `φ U ψ ∈ w` directly. If bx_le is antisymmetric on MCS (w = v), direct. If not, use `psi_imp_until` on `ψ ∈ w` if we can show `ψ ∈ w`.
  - Case 2 (v > w strictly): `φ ∈ w` (from guard at w), `φ U ψ ∈ v` (from `psi_imp_until`). Use contrapositive: assume `¬(φ U ψ) ∈ w`, derive contradiction. `¬(φ U ψ) → ¬ψ` (from `psi_imp_until` contrapositive). Apply BX4: `¬(φ U ψ) → G(P(¬(φ U ψ)))`. At v: `P(¬(φ U ψ)) ∈ v`, so ∃ u ≤ v with `¬(φ U ψ) ∈ u` and hence `¬ψ ∈ u`. Need to show this u is in [w, v) to violate guard. Use BX7 (linearity) for ordering.
- [ ] **Forward Until** (harder): Prove `φ U ψ ∈ w → ∃ v ≥ w, ψ ∈ v, φ on [w,v)`
  - From `φ U ψ ∈ w` and `ψ ∉ w`:
  - Step 1: Derive `φ ∈ w` (from `until_imp_or`)
  - Step 2: Derive `F(ψ) ∈ w` (from `until_imp_F`)
  - Step 3: Use `bx_forward_witness` to get `v ≥ w` with `ψ ∈ v`
  - Step 4: Guard verification — for all u with `bx_le w u` and `bx_lt u v`, show `φ ∈ u`
    - **Primary approach**: Use BX5 enrichment + BX7 linearity
    - **Fallback approach**: Zorn-based "closest witness" — define S_bad = {MCS M | w ≤ M, φ U ψ ∈ M, ψ ∉ M}, find maximal M via Zorn, build v just above M
  - If primary approach stalls, add a helper lemma in Frame.lean for the BX7-based guard argument
- [ ] **Backward Since**: Mirror of backward Until using BX4'/BX7'/`psi_imp_since`
- [ ] **Forward Since**: Mirror of forward Until using BX5'/BX6'/`bx_backward_witness`
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.TruthLemma` — target zero sorry

**Timing**: 3-5 hours

**Depends on**: 1 (key derived lemmas)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — Close 4 sorries (~300 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — Add guard helper lemmas if needed (~100 LOC)

**Verification**:
- `until_iff_mcs` and `since_iff_mcs` compile with zero sorry
- `lake build` passes
- All BXCanonical modules compile

---

### Phase 4: Canonical TaskModel + Completeness Wiring [NOT STARTED]

**Goal**: Construct the canonical TaskModel embedding BXPoints and wire to the completeness theorem, eliminating the `bx_completeness` sorry.

**Tasks**:
- [ ] **Study existing CanonicalConstruction.lean** to understand TaskModel embedding pattern
  - WorldState, task_rel, nullity, compositionality
  - WorldHistory construction via `to_history`
  - Omega (shift-closed set)
  - Existing truth lemma mapping
- [ ] **Wire BXCanonical into existing canonical infrastructure**:
  - BXPoints correspond to CanonicalWorldState (both wrap MCS)
  - bx_le corresponds to canonical_task_rel's forward direction
  - Reuse CanonicalTaskFrame with D=Int
  - Reuse CanonicalTaskModel with valuation from atom membership
- [ ] **Define canonical histories for BXPoints**:
  - For each BXPoint w₀, need a history visiting multiple MCS
  - Use the existing FMCS-to-history pattern: embed bx_le chain into Int-indexed family
  - Omega must be shift-closed
- [ ] **Prove BX truth lemma connects to semantic truth_at**:
  - For each formula case, connect `*_iff_mcs` to `truth_at` in the canonical model
  - G/H: already done in TruthLemma.lean at MCS level; need to show it matches truth_at quantification over history times
  - Until/Since: connect MCS-level truth (exists witness BXPoint) to semantic truth (exists witness time in history)
  - This is the key mapping: BXPoint witnesses ↔ time witnesses in histories
- [ ] **Complete `bx_completeness` proof**:
  - Contrapositive: ¬derivable → ¬valid
  - {¬φ} consistent (already proved: `neg_consistent_of_not_derivable`)
  - Extend to MCS w₀ (already proved via `set_lindenbaum`)
  - Build canonical model (new)
  - Apply truth lemma: ¬φ true at w₀ (new)
  - Therefore φ not valid (contradiction)
- [ ] Wire `bx_completeness` to `BaseCompleteness.lean` and `DenseCompleteness.lean`
- [ ] Run `lake build` on all completeness modules

**Timing**: 3-4 hours

**Depends on**: 3 (truth lemma must be complete)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Close bx_completeness sorry (~300 LOC)
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` — Wire to BX completeness
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` — Wire (= base under BX)

**Files to create** (if needed):
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` — TaskModel construction (~200 LOC)

**Verification**:
- `bx_completeness` compiles with zero sorry
- BaseCompleteness and DenseCompleteness wire through BXCanonical
- `lake build` passes

---

### Phase 5: Archive Remaining Chain Files [NOT STARTED]

**Goal**: Move the remaining 7 chain files from build path to Boneyard/ and clean up imports.

**Tasks**:
- [ ] Move remaining Algebraic chain files to `Boneyard/ChainCompleteness/Algebraic/`:
  - `DovetailedChain.lean` (has DEPRECATED sorries)
  - `UltrafilterChain.lean` (has the original forward_F/backward_P sorries)
  - `RestrictedTruthLemma.lean` (has chain-specific sorries)
- [ ] Move remaining Bundle chain files to `Boneyard/ChainCompleteness/Bundle/`:
  - `SuccChainFMCS.lean`
  - `SuccExistence.lean`
  - `SuccRelation.lean`
  - `TemporalCoherence.lean`
- [ ] Update `Metalogic/Algebraic/Algebraic.lean` — remove chain imports
- [ ] Update `Metalogic/Bundle/FMCS.lean` or `BFMCS.lean` — remove chain imports
- [ ] Update `Metalogic/Metalogic.lean` — remove chain imports
- [ ] Run `lake build` — verify clean build without chain code

**Timing**: 1 hour

**Depends on**: 3 (Phase 4 BXCanonical modules must compile first, but truth lemma suffices)

**Files to move** (to Boneyard/ChainCompleteness/):
- 3 Algebraic files + 4 Bundle files = 7 files

**Files to modify**:
- 3-4 import aggregator files

**Verification**:
- `lake build` succeeds with zero chain-related imports outside Boneyard
- Sorry count significantly reduced (chain sorries no longer compiled)

---

### Phase 6: Final Audit + Summary [NOT STARTED]

**Goal**: Full sorry audit, verify all target sorries eliminated, create completion summary.

**Tasks**:
- [ ] Run full `lake build` and verify success
- [ ] Run sorry audit: `grep -rn "sorry" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard`
- [ ] Verify original 4 target sorries eliminated:
  - succ_chain_restricted_forward_F — archived to Boneyard
  - succ_chain_restricted_backward_P — archived to Boneyard
  - F_until_equiv_valid — removed (Phase 2 of plan v33)
  - P_since_equiv_valid — removed (Phase 2 of plan v33)
- [ ] Verify 3 Soundness.lean sorries eliminated (Phase 2 of this plan)
- [ ] Verify 4 BXCanonical sorries eliminated (Phase 3-4 of this plan)
- [ ] Catalog remaining sorries with classification (Boneyard, discrete-only, extension stubs)
- [ ] Create implementation summary at `specs/083_close_restricted_coherence_sorries/summaries/34_bx-completion-summary.md`
- [ ] Run `lake build BimodalTest` if test suite exists

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification**:
- Full `lake build` clean
- Target sorries all eliminated
- Summary artifact created

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental)
- [ ] Phase 1 gate: All derived theorems (`psi_imp_until`, `until_imp_or`, `until_imp_F`) sorry-free
- [ ] Phase 2 gate: 3 Soundness.lean `temporal_duality` sorries closed
- [ ] Phase 3 gate: `until_iff_mcs` and `since_iff_mcs` sorry-free (CRITICAL)
- [ ] Phase 4 gate: `bx_completeness` sorry-free, BaseCompleteness wired
- [ ] Phase 5 gate: Chain files archived, `lake build` clean
- [ ] Phase 6 gate: Sorry audit shows only Boneyard/discrete/extension sorries remain
- [ ] Regression: Propositional, ModalS5, Perpetuity theorems unaffected
- [ ] Regression: Algebraic infrastructure (BooleanStructure, LindenbaumQuotient, etc.) unaffected

## Artifacts & Outputs

- `plans/34_bx-completion.md` (this file)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — BX-derived Until/Since lemmas
- `Theories/Bimodal/Metalogic/Soundness.lean` — Density-free swap-valid
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — Sorry-free Until/Since truth lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Sorry-free completeness
- `Theories/Bimodal/Boneyard/ChainCompleteness/` — 7 additional archived files
- `summaries/34_bx-completion-summary.md` — Final summary

## Rollback/Contingency

- **Phase 1**: If derived lemma proofs stall, add as axioms temporarily (document as technical debt)
- **Phase 2**: Independent of Phase 1; can proceed/rollback independently
- **Phase 3 forward direction**: If guard verification via BX7 stalls, fall back to Zorn-based "closest witness" approach. If both stall, leave sorry with detailed documentation of the exact gap.
- **Phase 3 backward direction**: If contrapositive approach stalls, try direct proof or inductive argument.
- **Phase 4**: If canonical TaskModel wiring is blocked, keep `bx_completeness` sorry but document that it's a plumbing issue, not a mathematical gap.
- **Phase 5**: Safe — files are moved, not deleted. Restore imports from Boneyard if build breaks.
