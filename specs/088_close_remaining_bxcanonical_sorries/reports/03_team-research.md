# Research Report: Task #88 (Round 3)

**Task**: 88 — Close remaining 6 BXCanonical sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)
**Focus**: User question — "Are Until and Since operators still included in the proof system? What is to my advantage to establish the representation theorem?"

## Summary

Until and Since are **fully present and functional** at every level of the proof system — syntax, axioms (BX2-BX12, all 22 constructors), semantics, and derivation rules. Nothing was removed. The gap is exclusively in the **canonical model construction** (4 sorry sites in Frame.lean) caused by the X-vs-G mismatch: `φ U ψ ∈ w` does not give `G(φ U ψ) ∈ w`, so Until formulas don't propagate through the `g_content`-based canonical ordering `bx_le`.

The project already has several sorry-free completeness results: `fragment_completeness` (temporal-free fragment), `fmp_contrapositive` (MCS membership form for full TM), `parametric_algebraic_representation_relative` (conditional on BFMCS), and `validity_decidable` + FMP (decidability). Closing all 6 BXCanonical sorries would yield `bx_completeness` — the full `valid φ → Nonempty (DerivationTree [] φ)` — which would be the **first verified formalization of Until/Since temporal logic completeness in Lean 4**.

Critical finding from the Critic (Teammate C): the round 2 claim that "interval linearity is derivable from BX7 + BX12" is **unverified and suspect**. BX7 constrains Until-witness ordering, not arbitrary bx_le-successor ordering. The backward Until "simpler" claim is also **incorrect** — backward sorries have the same linearity gap. BX11/BX12 are used nowhere in BXCanonical. The FMP bridge is also not viable as-is: the semantic validity → MCS membership direction requires the same truth lemma that BXCanonical needs.

## Key Findings

### 1. Until/Since Are Fully Present — Nothing Was Removed (Teammate A, HIGH confidence)

- **Syntax**: `Formula.untl` and `Formula.snce` are primitive constructors in `Formula.lean:79-83`. All recursive functions handle them. Derived operators: `next φ := bot U φ`, `prev φ := bot S φ`.
- **Axioms**: 22 axiom constructors in `Axioms.lean` cover BX2-BX12 (future + past pairs). All are present and uncommented. BX11 (temp_linearity) and BX12 (F_until_equiv) were restored in Phase 1.
- **Semantics**: `Truth.lean:128-131` defines Until with reflexive witness (`s ≥ t`) and open-left guard; Since with reflexive witness (`s ≤ t`) and open-right guard. Standard Burgess-Xu semantics.
- **Derivation rules**: `DerivationTree` handles Until/Since formulas. No restrictions.

**Bottom line**: The proof system is complete for Until/Since. The 6 sorries are in the metalogic (canonical model), not the object logic.

### 2. What's Sorry-Free RIGHT NOW (Teammate B, HIGH confidence)

| Result | Location | Logic Fragment | Status |
|--------|----------|---------------|--------|
| `fragment_completeness` | CanonicalEmbedding.lean:310 | {atom, bot, imp, box} | **Sorry-free** |
| `fmp_contrapositive` | Decidability/FMP/FMP.lean:206 | full TM (MCS membership form) | **Sorry-free** |
| `parametric_algebraic_representation_relative` | Algebraic/ParametricRepresentation.lean:184 | full TM (conditional on BFMCS) | **Sorry-free** |
| `validity_decidable` | Decidability/ | full TM | **Sorry-free** |
| `soundness` | Soundness.lean | full TM | **Sorry-free, axiom-free** |
| `base_truth_lemma` | BaseCompleteness.lean:147 | base TM on Int | **Sorry-free** |
| `usf_completeness` | CanonicalEmbedding.lean:382 | {atom, bot, imp, box, G, H} | 1 sorry (imp Case B) |
| `bx_completeness` | Completeness.lean:124 | full TM with Until/Since | 1 sorry (+4 upstream) |

### 3. The 6 Sorries Are 3 Distinct Problems, Not 6 (Teammate C, HIGH confidence)

| Problem | Sorries | Difficulty | Blocker |
|---------|---------|-----------|---------|
| A: Forward eventuality resolution | Frame.lean:653, 690 | **HARD** | X-vs-G mismatch: guard propagation for intermediate points requires Until formula persistence through bx_le steps, which is impossible with g_content-based ordering |
| B: Backward eventuality construction | Frame.lean:675, 704 | **HARD** (not medium as round 2 claimed) | Same linearity gap: backward witness u from `bx_backward_witness` satisfies u ≤ v, not necessarily w ≤ u, so the guard hypothesis is inapplicable |
| C: CanonicalEmbedding imp Case B | CanonicalEmbedding.lean:418 | **INDEPENDENT, 4-6 hours** | WorldHistory infrastructure: constant histories collapse G(α) to α, need non-constant history construction |
| Downstream: Completeness | Completeness.lean:160 | Closes when A closes | Via TruthLemma's `until_iff_mcs` and `since_iff_mcs` |

**Critical correction**: CanonicalEmbedding:418 is **NOT on the critical path** for `bx_completeness`. Completeness.lean imports TruthLemma and Validity, not CanonicalEmbedding. The CanonicalEmbedding sorry is for the standalone `usf_completeness` (Until/Since-free fragment), not for the main theorem.

### 4. BX11/BX12 Do NOT Help With BXCanonical Sorries (Teammate C, 85% confidence)

- Neither BX11 (temp_linearity) nor BX12 (F_until_equiv) is used anywhere in BXCanonical (grep confirmed).
- BX12 converts `F(ψ) → ⊤ U ψ`, giving the same witness as BX10 + `bx_forward_witness`. It adds nothing for witness existence.
- The round 2 claim that BX7 + BX12 gives interval linearity is **suspect**: BX7 constrains Until-witness ordering (the specific points where Until resolves), not the ordering of ALL bx_le-successors. Two BXPoints that are not Until-witnesses for any formula need not be comparable.
- BX11/BX12 were primarily valuable for DovetailedChain.lean and LinearityDerivedFacts.lean (Phase 1 wins).

### 5. The FMP Bridge Is NOT Viable As-Is (Teammates B, C, D consensus)

- `fmp_contrapositive` proves `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)` sorry-free.
- But the semantic bridge `valid φ → ∀ S : ClosureMCSBundle φ, φ ∈ S.carrier` requires the filtration truth lemma for temporal operators.
- `TruthPreservation.lean:247-249`: temporal operator cases are archived to Boneyard — "needs redesign for strict semantics."
- **Both BXCanonical and FMP fail at the same step**: the semantic truth lemma for temporal operators.

### 6. What `bx_completeness` Would Give (Teammate D, HIGH confidence)

- The full representation theorem: `valid φ ↔ Nonempty (DerivationTree [] φ)` (completeness + soundness)
- **First verified formalization** of Until/Since temporal logic completeness in Lean 4 (no bimodal or tense logic completeness in Mathlib)
- Validates the BX axiom set (confirms BX11/BX12 restoration was correct)
- Publication-quality result for logic venues (ITP, IJCAR)

### 7. Strategic Value Thresholds (Teammate D)

| Sorries Closed | What You Get | Publication Value |
|---------------|-------------|------------------|
| 0 more | Soundness + FMP + decidability + fragment completeness | System description paper |
| 4/6 (Frame.lean) | Sorry-free truth lemma for Until/Since | Infrastructure value only |
| 5/6 (+CanonicalEmbedding) | Sorry-free `usf_completeness` for S5+G/H | First formalization of S5+G/H completeness |
| 6/6 | Sorry-free `bx_completeness` for full TM | First formalization of TM bimodal completeness |

## Synthesis

### Conflicts Found and Resolved

| Conflict | Round 2 Claim | Teammate C Challenge | Resolution |
|----------|--------------|---------------------|------------|
| Backward Until is simpler | "May close via direct contradiction + BX8" (70%) | Same linearity gap as forward (90%) | **Teammate C correct**: backward witness u satisfies u ≤ v, not w ≤ u, so guard is inapplicable. Both forward and backward sorries are HARD. |
| Interval linearity from BX7+BX12 | "Derivable" (70%) | "BX7 gives witness ordering, not interval ordering" (80%) | **Teammate C correct**: BX7 orders Until-resolution points, not arbitrary bx_le-successors. The guard needs φ at ALL intermediate points, not just resolution points. |
| FMP bridge bypasses BXCanonical | "55% confidence, 2-hour spike" | "Same truth lemma gap" (50%) | **Teammate C correct**: TruthPreservation.lean explicitly archives temporal operator cases. Both paths fail at the same step. |
| CanonicalEmbedding on critical path | Implied by prior plans | "NOT imported by Completeness.lean" (95%) | **Teammate C correct**: CanonicalEmbedding:418 is for `usf_completeness` (fragment), not `bx_completeness` (main theorem). |

### Gaps Identified

1. **The X-vs-G mismatch is confirmed for the 5th time** (tasks 83, 85, 86, 87, 88 rounds 1-3). `φ U ψ ∈ w` does not give `G(φ U ψ) ∈ w`. No BX axiom bridges this. No axiom set can bridge this because Until-membership and G-membership are semantically distinct properties.

2. **No viable proof strategy exists for Frame.lean:653/690 without architecture change**. All proposed approaches (global linearity, interval linearity, BX4 contradiction, Zorn minimality, chain extraction) have been analyzed and all fail at the same point: Until formulas don't propagate through g_content-based bx_le steps.

3. **Architecture alternatives are underexplored**:
   - (A) Redefine bx_le via Until-witness chains (linearity by construction, but G/H truth lemma must be reproved)
   - (B) Quasimodel approach (bypass canonical model entirely)
   - (C) Two-indexed canonical model (separate orderings for temporal and modal dimensions)
   - (D) Accept the sorry and document as open problem

4. **SuccChainFMCS.lean has 3 "derive from BX axioms" sorries** (lines 125, 135, 420) that may be closable proof engineering — underexplored path to parametric completeness.

### Recommendations

**To answer the user's question directly**:

1. **Until and Since are fully in the proof system.** Nothing was removed. All syntax, axioms (BX2-BX12), semantics, and derivation infrastructure is present and working.

2. **What's to your advantage for the representation theorem**:
   - You already have sorry-free soundness, decidability, FMP, and fragment completeness
   - The 4 Frame.lean sorries are the single bottleneck for the full representation theorem
   - These sorries are blocked by a **fundamental architectural constraint** (X-vs-G mismatch), not missing axioms or proof engineering
   - Closing them requires choosing an architecture alternative (redefine bx_le, quasimodel, or accept as open)
   - The CanonicalEmbedding sorry (1 of 6) is independent and closable with 4-6 hours of WorldHistory infrastructure work
   - The Completeness.lean sorry (1 of 6) closes automatically when Frame.lean closes

3. **Priority recommendation**:
   - **Immediate**: Close CanonicalEmbedding:418 for `usf_completeness` (independent, 4-6 hours, first S5+G/H completeness in Lean 4)
   - **Research spike**: Investigate architecture alternative (A) — redefine bx_le via Until-witness chains (2-4 hours research)
   - **If architecture change is feasible**: Implement new bx_le definition and reprove G/H truth lemma (8-16 hours)
   - **If architecture change is infeasible**: Document Frame.lean sorries as open problems requiring novel mathematical technique

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Until/Since Audit | completed | HIGH | Comprehensive proof system audit confirming full presence of Until/Since |
| B | Representation Strategy | completed | HIGH | Complete map of all completeness paths with sorry status |
| C | Critic | completed | HIGH (95%) | Demolished interval linearity claim; identified CanonicalEmbedding independence; confirmed X-vs-G as fundamental |
| D | Strategic Horizons | completed | HIGH (85%) | Publication value assessment; first-in-Lean-4 claim; strategic priority ordering |

## References

- Round 1 report: `specs/088_close_remaining_bxcanonical_sorries/reports/01_team-research.md`
- Round 2 report: `specs/088_close_remaining_bxcanonical_sorries/reports/02_team-research.md`
- Phase 1 summary: `specs/088_close_remaining_bxcanonical_sorries/summaries/01_implementation-summary.md`
- Frame.lean X-vs-G diagnosis: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-622`
- TruthPreservation.lean archived cases: `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean:247-249`
