# Teammate D Findings: Solution Architecture — Viable Paths Evaluation

**Task**: 109 — Close chain construction sorries for sorry-free completeness
**Role**: Teammate D (Horizons researcher)
**Date**: 2026-04-21

## Path Evaluation Table

| Path | Description | Closes Sorries | Effort | Hidden Obstacles | Viability |
|------|-------------|----------------|--------|------------------|-----------|
| A | Reflexive Until (s >= t), Irreflexive G/H (s > t / s < t) | #1, #3 partially | 15-25h | **BX10 unsound**: (φ U ψ) → F(ψ) fails when witness s = t but F needs s > t | NOT VIABLE as stated |
| B | Full Reflexive Restoration (G/H use ≤/≥) | All 3 | 15-25h | Abandoned in task 93 for philosophical reasons; T-axiom Gφ→φ valid | VIABLE — recommended |
| C | Semantic Completeness (full MCS space) | All 3 | 40-60h | Massive re-engineering; unclear if restricted coherence can be proved for arbitrary MCS ordering | VIABLE but costly |
| D | Alternative Axiomatization (add new axiom) | Possibly #1 | 10-15h | Does not close #2 (psi_imp_until foundation); ad hoc; not standard | NOT VIABLE alone |
| E | Hybrid — Reflexive Until, Irreflexive G/H | Same as A | 15-25h | Same BX10 failure as Path A | NOT VIABLE |
| F | Redefine F to be reflexive (F(φ) = φ ∨ ¬G(¬φ)) | All 3 if combined with reflexive Until | 20-30h | F is no longer dual of G; breaks fundamental duality; non-standard | NOT RECOMMENDED |

## Key Findings

### Finding 1: Path A/E are blocked by BX10 unsoundness (VERY HIGH confidence)

The critical check for Path A (reflexive Until with irreflexive G/H):

**Current semantics**:
- `φ U ψ` at t: ∃s, **t < s** ∧ ψ(s) ∧ ∀r, t ≤ r → r < s → φ(r)
- `F(ψ)` at t: ∃s, **t < s** ∧ ψ(s) (i.e., ¬G(¬ψ), where G uses strict <)

BX10 `(φ U ψ) → F(ψ)` is sound because both Until and F use strict future (s > t). The Until witness directly provides the F witness.

**Under Path A** (reflexive Until, irreflexive F):
- `φ U ψ` at t: ∃s, **t ≤ s** ∧ ψ(s) ∧ ∀r, t ≤ r → r < s → φ(r)
- `F(ψ)` at t: ∃s, **t < s** ∧ ψ(s) (still irreflexive since G stays irreflexive)

When the Until witness is s = t: ψ(t) holds but F(ψ) requires s' > t with ψ(s'). Having ψ at time t does not provide a strictly future witness. **BX10 is NOT sound.**

This blocks both Path A and Path E. Any approach that makes Until reflexive while keeping F/G irreflexive breaks this fundamental axiom.

### Finding 2: Path B (Full Reflexive Restoration) is mathematically coherent (HIGH confidence)

Under full reflexive semantics:
- G(φ) at t: ∀s, t ≤ s → φ(s) (reflexive, includes present)
- H(φ) at t: ∀s, s ≤ t → φ(s) (reflexive, includes present)
- φ U ψ at t: ∃s, t ≤ s ∧ ψ(s) ∧ ∀r, t ≤ r → r < s → φ(r)
- F(φ) = ¬G(¬φ): ∃s ≥ t, φ(s)

**All BX axioms check out**:
- BX1 (T-axiom): G(φ) → φ — sound (s = t case of ∀s ≥ t)
- BX8 (Until intro): ψ → φ U ψ — sound (witness s = t, guard [t,t) = ∅)
- BX9 (Until elim): φ U ψ → φ ∨ ψ — sound (guard includes t ∈ [t,s) when s > t giving φ; when s = t giving ψ)
- BX10 (Until→F): φ U ψ → F(ψ) — sound (Until witness s ≥ t provides F witness since F needs s ≥ t)
- BX12 (F→Until): F(φ) → ⊤ U φ — sound (F witness becomes Until witness with vacuous guard)
- Seriality BX1/BX1' become redundant (subsumed by T-axiom) but remain sound
- temp_4: G(φ) → G(G(φ)) — sound on transitive reflexive orders
- BX4 connect_future: φ → G(P(φ)) — sound (at any s ≥ t, t ≤ s so P(φ) at s via witness t)
- All other axioms checked: sound on reflexive linear orders

**This restores the complete Burgess-Xu axiomatization as originally intended.**

### Finding 3: Why task 93 abandoned reflexive semantics — and why the reason may not apply (MEDIUM confidence)

I examined `specs/archive/093_complete_bxcanonical_embedding/`. The transition to irreflexive semantics in task 93 was motivated by:

1. **Philosophical preference**: The JPL paper discusses both reflexive and irreflexive options; the project chose irreflexive to model "strict future/past" (excluding present)
2. **T-axiom concerns**: Under reflexive G, Gφ → φ is valid. The project wanted to avoid this because in some readings, "it will always be the case that φ" should not entail "φ holds now"
3. **Seriality as replacement**: BX1 (⊤ → F(⊤)) was intended to replace the T-axiom

However, the consequence was catastrophic for completeness: removing G(φ) → φ breaks g_content self-inclusion (`g_content(M) ⊆ M`), which is foundational to canonical model constructions in tense logic. Every standard reference (Burgess 1984, Goldblatt 1992, Xu 1988) uses reflexive G for completeness.

**The philosophical distinction can be recovered after completeness** by defining derived operators G_strict(φ) = G(φ) ∧ ¬φ in the metatheory, keeping the base logic reflexive for the completeness proof.

### Finding 4: Path B closes all 3 sorries directly (HIGH confidence)

Under reflexive semantics, the existing infrastructure becomes sufficient:

**Sorry #1 (restricted_tc — F/P resolution)**:
- g_content(M) ⊆ M holds (from G(φ) → φ, i.e., G(φ) ∈ M implies φ ∈ M)
- F(φ) ∈ chain(n) implies either φ ∈ chain(n) (resolved) or F(φ) persists because g_content propagation now includes self-membership
- The schedule-based chain resolves all F-obligations because F-formulas cannot be silently destroyed: if F(φ) ∈ M then φ ∈ g_content(M) via G(φ)→φ... Actually, this needs care. F(φ) ∈ M does not directly give G(F(φ)) ∈ M even under reflexive G. But g_content(M) ⊆ M means the Lindenbaum seed includes MORE formulas, making it harder for Classical.choice to destroy F-obligations.
- More precisely: the `fwd_succ` seed `{ψ} ∪ g_content(M)` with g_content(M) ⊆ M means the seed is `{ψ} ∪ M_restricted`, a much richer set. If F(φ) ∈ M and G(F(φ)) ∉ M, then ¬G(F(φ)) ∈ M, so F(¬F(φ)) ∈ M = F(G(¬φ)) ∈ M. But this does NOT mean G(¬φ) enters the seed. So the enrichment from g_content(M) ⊆ M doesn't directly solve F-persistence.

**Correction**: The real benefit of reflexive semantics for sorry #1 is that the **Ordered Seed Consistency approach from task 93 report 13 becomes viable**. With BX8 restored (ψ → φ U ψ), the defect-discharge chain construction works end-to-end:
- BX11 gives ordering of F-witnesses
- Ordered Seed Consistency Theorem holds (proved in report 13)
- F-Defect Monotonicity ensures termination
- Identity tail works because defect-free MCS satisfies all F-obligations

**Sorry #2 (restricted_buc — backward Until/Since)**:
- `psi_imp_until` (ψ → φ U ψ) becomes valid and provable (BX8 restored)
- `backward_until_reflexive` base case works: ψ ∈ M gives φ U ψ ∈ M
- Step transfer for inductive case: the task 93 report 13 analysis shows this requires Until-enriched seeds, which ARE consistent under reflexive semantics because g_content(M) ⊆ M

**Sorry #3 (restricted_fuc — forward Until/Since)**:
- BX10 gives F(ψ) from (φ U ψ)
- Sorry #1 resolution gives ψ at some future chain position
- BX9 gives guard persistence: at intermediate positions, (φ U ψ) ∈ chain(r) and ψ ∉ chain(r) implies φ ∈ chain(r)
- The defect-discharge construction resolves Until witnesses explicitly

### Finding 5: Path C (Semantic Completeness) is viable but expensive (MEDIUM confidence)

The full MCS space approach would:
- Use ALL MCS as time points ordered by g_content inclusion
- Leverage `bx_forward_witness` (sorry-free in Frame.lean) for F-resolution
- Use `bx_G_backward` (sorry-free in Frame.lean) for G backward direction
- Build the truth lemma directly on this structure

**Advantages**:
- Mathematically elegant; standard approach in literature
- `bx_forward_witness` and `bx_backward_witness` already proved
- No chain construction needed

**Obstacles**:
- The BFMCS/parametric architecture expects Int-indexed families with shifted histories
- Would need to completely re-engineer the canonical model to use BXPoint as the time domain
- The modal equivalence classes add complexity (each MCS cluster generates a separate family)
- Restricted coherence would need to be re-proved for the new structure
- **bx_le is NOT a total order** on BXPoints — it's a preorder with "junk points" from unrelated Lindenbaum extensions. This creates problems for linearity axioms.
- Estimated 40-60 hours of work vs 15-25 hours for Path B

### Finding 6: Path D (Alternative Axiomatization) is insufficient (HIGH confidence)

Adding `F(φ) ∧ G(φ → F(φ)) → G(F(φ))` to close sorry #1:

**Soundness check**: At time t, F(φ) means ∃s > t, φ(s). G(φ → F(φ)) means ∀u > t, (φ(u) → ∃v > u, φ(v)). Together: there's a chain s₁ < s₂ < ... with φ at each. So ∀u > t, ∃v > u, φ(v). This gives G(F(φ)). **Sound on ℤ and any order without a maximum element.**

However:
- This only helps with F-persistence, not with backward Until (sorry #2)
- The `psi_imp_until` sorry cannot be closed by any axiom addition — it requires reflexive Until semantics
- Adding axioms is non-standard and moves away from the Burgess-Xu system

### Finding 7: The bx_le_refl sorry in Frame.lean is another symptom (HIGH confidence)

Frame.lean line 202 has `bx_le_refl` (w ≤ w for all BXPoints) marked sorry with the comment "Under irreflexive semantics, bx_le is NOT reflexive." This is because bx_le is defined as g_content(w) ⊆ w, which requires G(φ) ∈ w → φ ∈ w, i.e., the T-axiom.

Under Path B, this sorry disappears immediately: the T-axiom G(φ) → φ gives g_content(w) ⊆ w for any MCS w.

## Recommended Path: B (Full Reflexive Restoration)

### Justification

1. **Mathematical correctness**: Reflexive G/H/Until/Since is the standard semantics in Burgess (1984), Goldblatt (1992), and Xu (1988). The BX axiom system was designed for this semantics.

2. **Closes all sorries**: All 3 sorry sites in RootScopedChain.lean plus bx_le_refl in Frame.lean and psi_imp_until in TemporalDerived.lean.

3. **Minimal disruption**: The semantic definitions change in exactly one file (Truth.lean): `<` becomes `≤` for G/H, and the Until/Since witness condition changes from `t < s` to `t ≤ s`. The axiom system is unchanged (BX8 was removed but can be re-added; or ψ → φ U ψ becomes derivable).

4. **Existing infrastructure reused**: The BFMCS, FMCS, parametric representation, truth lemma, and canonical model construction all remain. The chain construction (schedule-based or defect-discharge) gains the properties it needs.

5. **Proven approach**: Task 93 report 13 provides a complete mathematical proof sketch for the defect-discharge chain under reflexive semantics with no hidden obstacles identified.

6. **Soundness already proved**: The soundness proof in Soundness.lean proves each axiom valid. Under reflexive semantics, all axioms remain valid (they were originally designed for this). The soundness proof needs minor updates to change `<` to `≤` in the G/H/Until/Since cases.

### Implementation Sketch

**Phase 1: Semantic Restoration (5-8 hours)**
1. `Truth.lean`: Change `s < t` to `s ≤ t` in `all_past`, `t < s` to `t ≤ s` in `all_future`
2. `Truth.lean`: Change `t < s` to `t ≤ s` in `untl` witness, `s < t` to `s ≤ t` in `snce` witness
3. Update docstrings throughout Truth.lean
4. Fix time-shift preservation proofs (should be straightforward substitutions)

**Phase 2: Axiom System Update (3-5 hours)**
1. Re-add BX8/BX8' constructors to `Axiom` inductive type, or derive ψ → φ U ψ from the reflexive semantics
2. Optionally keep seriality axioms (redundant but harmless) or convert BX1/BX1' back to T-axioms
3. Update Axioms.lean docstrings

**Phase 3: Soundness Re-proof (5-8 hours)**
1. Update all soundness proofs in Soundness.lean and SoundnessLemmas.lean
2. Most proofs need `<` changed to `≤` with corresponding `le_refl` for reflexive cases
3. The seriality proof changes to T-axiom proof (or stays as seriality which is weaker)

**Phase 4: Close Sorry Sites (5-10 hours)**
1. `Frame.lean`: Close `bx_le_refl` using T-axiom
2. `TemporalDerived.lean`: Close `psi_imp_until` and `psi_imp_since` using BX8
3. `RootScopedChain.lean`: Close `bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`
   - For #1 (restricted_tc): Use the Ordered Seed Consistency approach from report 13
   - For #2 (restricted_buc): backward_until_reflexive base case + step transfer
   - For #3 (restricted_fuc): BX10 + F-resolution + BX9 guard

**Phase 5: Verification (2-4 hours)**
1. `lake build` — full project compilation
2. Verify no new sorries introduced
3. Run test suite

**Total estimated effort: 20-35 hours**

## Confidence Level

**HIGH** — The analysis is based on:
- Direct reading of Truth.lean semantic definitions (lines 125-130)
- Verification of BX10 soundness/unsoundness under each path
- Study of all 35 BX axioms and their soundness proofs
- Task 93 report 13's complete mathematical proof sketch
- Frame.lean infrastructure (bx_forward_witness, bx_G_backward — both sorry-free)
- The fundamental observation that standard tense logic completeness proofs ALL use reflexive semantics

The main risk is Phase 3 (soundness re-proofs): some proofs may need non-trivial restructuring when `<` becomes `≤`. However, reflexive semantics is strictly easier for soundness (more things are valid), so no proof should become impossible — at worst, some need reorganization.

## References

### Codebase Files Studied
- `Theories/Bimodal/Semantics/Truth.lean` — semantic definitions (lines 119-130)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all 35 BX axioms
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — bx_le, bx_forward_witness, bx_le_refl sorry
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 3 sorry sites + dd_countermodel
- `Theories/Bimodal/Metalogic/Soundness.lean` — until_F_valid (BX10 soundness, line 778)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward_until_reflexive, psi_imp_until dependency
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — coherence definitions
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` — restricted truth lemma
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — psi_imp_until sorry (line 232-236)

### Prior Research
- `specs/archive/093_complete_bxcanonical_embedding/reports/13_long-term-solution.md` — Ordered Seed Consistency proof sketch
- `specs/109_close_chain_construction_sorries/reports/08_team-research.md` — Team consensus on structural impossibility under irreflexive semantics

### Literature
- Burgess (1984): "Basic Tense Logic" — uses reflexive G/H, reflexive Until/Since
- Goldblatt (1992): "Logics of Time and Computation" — reflexive canonical model
- Xu (1988): "Decidability of Kt4.3" — reflexive Until completeness
- Venema (1993): Survey of temporal logic — confirms reflexive standard
