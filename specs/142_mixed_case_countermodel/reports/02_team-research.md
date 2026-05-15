# Research Report: Task #142 — Mixed-Case Countermodel

**Task**: 142 — mixed_case_countermodel
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778871005_29226d

## Summary

The mixed-case sorry in `bx_completeness` (ChronicleToCountermodel.lean:3327) is the mathematically hardest of the 6 remaining critical-path sorries. Four parallel investigators converged on a key architectural insight: **any ordered abelian group D is either globally dense or globally discrete** (by translation invariance of the successor property). This forces a case split on which formulas appear in `subformulaClosure(φ)`, using the restricted truth lemma to avoid needing semantic correctness for the "wrong type" families.

The recommended approach is a **formula-guided domain selection** with a **restricted Burgess construction** that skips C5 resolution for irrelevant Until formulas. This produces dense chronicles even for discrete MCS's, enabling the Cantor isomorphism on ℚ. Estimated effort: 40-60 hours, with a focused 4-8 hour feasibility study recommended first.

## Key Findings

### 1. The Algebraic Constraint (New — from synthesis)

**In any ordered abelian group (D, +, <), the existence of an immediate successor is translation-invariant.** If some d ∈ D has an immediate successor d + ε (where ε = inf{g > 0}), then every element has an immediate successor. Conversely, if inf{g > 0} = 0, no element has an immediate successor.

**Consequence**: D is EITHER globally dense (like ℚ) OR globally discrete (like ℤ). There is no ordered abelian group with mixed-density regions. Since `TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, the domain D MUST be uniformly dense or uniformly discrete.

This means:
- On dense D (e.g., ℚ): `U(T,⊥)` (= "immediate successor exists") is always semantically **false**
- On discrete D (e.g., ℤ): `F'T` (= ¬U(T,⊥) = "no immediate successor") is always semantically **false**

### 2. The Three-Way Split Is an Artifact (Teammates A, C)

Burgess's original completeness proof for J₀ (Until/Since over arbitrary linear orders) has **no density case split**. The split was introduced because the formalization chose concrete domains: ℚ for dense (Cantor isomorphism) and ℤ for discrete (successor embedding). The mixed case arises solely because no single standard domain accommodates both.

**Evidence**: The Burgess chronicle construction (ChronicleConstruction.lean) works uniformly for ANY MCS. The case split appears only in ChronicleToCountermodel.lean when mapping the limit domain onto a standard type.

### 3. Uniformity Axioms Guarantee Within-History Uniformity (Teammate C)

The uniformity axioms (`discrete_propagate_fwd`: U(T,⊥) → G(U(T,⊥)), `discrete_propagate_bwd`: U(T,⊥) → H(U(T,⊥))) ensure that density/discreteness is an **all-or-nothing** property within each individual history. A single FMCS family is either uniformly dense or uniformly discrete at ALL time points.

The "mixing" occurs only across box-equivalent MCS's (different histories in the BFMCS), not within a single history. This simplifies analysis: each family has a clean temporal character.

### 4. Gap-Filling on ℚ Fails Fundamentally (Teammates A, B, C)

All four teammates independently confirmed that naive gap-filling of discrete chronicles on ℚ is impossible:

- **Constant filling fails**: G(φ) ∈ mcs(gap_point) does NOT imply φ ∈ mcs(gap_point) under strict (irreflexive) temporal semantics. No single MCS can serve as a gap-filler for constant regions on a dense order.
- **Right-neighbor filling fails**: Same G-reflexivity issue for points within the same interval.
- **Consistency failure**: The "G-content" from the left neighbor and "H-content" from the right neighbor can be mutually inconsistent when a formula switches between consecutive chronicle points.
- **Densification is blocked**: Burgess Lemma 2.6 (point insertion) cannot split intervals protected by U(T,⊥) witnesses (⊥ in the guard forces ⊥ in intermediate MCS's, violating consistency).

### 5. The Restricted Truth Lemma Provides the Escape (All teammates)

The `restricted_forward_until_since_coherent` (TemporalCoherence.lean:535-544) only requires Until/Since witnesses for formulas in `subformulaClosure(root)`. If `U(T,⊥) ∉ subformulaClosure(φ)`:
- The coherence condition for U(T,⊥) doesn't apply
- U(T,⊥) can be in family MCS's without needing an immediate-successor witness
- The FMCS `forward_G` (which is purely syntactic) still propagates U(T,⊥) correctly

**Key distinction**: `forward_G` is a syntactic condition (G(φ) ∈ mcs(t) → φ ∈ mcs(t')), not a semantic one. It doesn't require truth values to match the model. The restricted truth lemma handles semantic correctness only for subformulaClosure(φ).

### 6. The Mixed Case Is Genuine (Teammate C confirms)

All BX interaction axioms were checked. The sole interaction axiom is `modal_future: □φ → □(Gφ)` (Axioms.lean:301). This cannot force `□(F'T) ∨ □(U(T,⊥))` from the mixed-case hypotheses. The formula `□(F'T ∨ U(T,⊥))` IS a theorem (necessitation of a tautology), but `□(F'T) ∨ □(U(T,⊥))` is NOT (box doesn't distribute over disjunction).

### 7. Alternative Approaches Were Investigated and Ranked (Teammate B)

| Rank | Approach | Confidence | Effort | Verdict |
|------|----------|-----------|--------|---------|
| 1 | D = ℚ with restricted construction | Medium-High | 20-40h | Most promising |
| 2 | Eliminate three-way split | Medium-High | 30-50h | Same core idea |
| 3 | Doets/Reynolds transfer | Low | 50-70h | Too many upstream sorries |
| 4 | Product/coproduct domain | Low | 40-60h | Algebraically impossible (Finding 1) |
| 5 | Mosaic method | Low | 80-120h | Incompatible with TaskFrame |

### 8. Strategic Context (Teammate D)

- Task 142 is one of 6 critical-path sorries; tasks 147/148 (3.5-5h combined) should complete first
- Sorry-free `fmp_completeness` already exists (Correctness.lean:100) over closure MCS bundles
- A sorry-free `bx_completeness` over TaskFrame models would be the **first such formalization in any proof assistant**
- The FMP bridge strategy (connecting `fmp_completeness` to `bx_completeness`) is attractive but likely circular
- Realistic estimate: 40-80h with 30% risk of exceeding 100h

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate A says gap-filling fails; Teammate B ranks it #1 | **Converge**: Gap-filling the *discrete limit domain* fails, but a *restricted Burgess construction* producing a dense limit domain avoids gap-filling entirely |
| Teammate C says D=ℚ is blocked; Others say restricted truth lemma helps | **Resolved by domain selection**: D=ℚ is blocked ONLY when U(T,⊥) ∈ subformulaClosure(φ). The approach must case-split on the subformula closure |
| Teammates C/D suggest eliminating the split; A/B work within it | **Architecture decision**: The recommended approach adds a formula-guided case split (on subformulaClosure) rather than restructuring the three-way case split, keeping architectural changes minimal |

### Gaps Identified

1. **Case 3 (both U(T,⊥) and F'T in subformulaClosure(φ))**: Neither D=ℚ nor D=ℤ works. Requires separate analysis — possibly a proof that such φ can't have ¬φ in a mixed-class MCS, or a novel domain construction.

2. **Restricted Burgess construction not yet formalized**: The existing ChronicleConstruction.lean resolves C5 for ALL Until formulas. A parameterized version that skips C5 for a specified set of formulas requires new infrastructure.

3. **Reynolds compression for dense families on ℤ**: When D=ℤ is needed, dense box-equivalent families require compression to ℤ. The existing WeakCanonical pipeline has upstream sorries (k_type_of, doets_lemma_1_4).

4. **Prior axiom status**: Prior-UZ/SZ are classified as `Discrete` (Axioms.lean:384-388). Whether the completeness derivation includes them affects domain constraints. Needs formal verification.

### Recommendations

**Primary approach: Formula-Guided Domain Selection with Restricted Burgess Construction**

```
Case analysis on subformulaClosure(φ):

Case A: U(T,⊥) ∉ subformulaClosure(φ)
  → Use D = ℚ
  → Dense families: standard Cantor iso FMCS (existing)
  → Discrete families: restricted Burgess construction
    (skip C5 for U(T,⊥)) → dense limit domain → Cantor iso
  → Restricted truth claim holds (U(T,⊥) excluded)

Case B: U(T,⊥) ∈ subformulaClosure(φ) and F'T ∉ subformulaClosure(φ)
  → Use D = ℤ
  → Discrete families: standard succ-embedding FMCS (existing)
  → Dense families: restricted Burgess construction
    (skip C5 for S(T,⊥), the Since-dual) → discrete limit domain → succ embedding
    OR: exploit that F'T truth lemma isn't needed
  → U(T,⊥) coherence satisfied via immediate successors on ℤ

Case C: Both U(T,⊥) and F'T ∈ subformulaClosure(φ)
  → Requires separate argument (OPEN — see feasibility study)
  → Possible resolution: show ¬φ in a mixed-class MCS forces
    a contradiction when both are subformulas
  → Fallback: check if subformulaClosure is closed under negation
    (if so, Case C is always triggered when either is)

Case D: Neither ∈ subformulaClosure(φ)
  → Use D = ℚ (simplest existing infrastructure)
  → All families use restricted Burgess + Cantor iso
  → Restricted truth claim holds trivially
```

**Feasibility study (4-8 hours) before full implementation**:
1. Check if subformulaClosure is closed under negation for Until/neg patterns (determines if Case C is reachable) — 2h
2. Check if Prior-UZ/SZ are in the completeness derivation path — 1h  
3. Prototype restricted Burgess construction: add formula-set parameter to C5 resolution — 3h
4. Verify that the restricted chronicle's limit domain is indeed dense when U(T,⊥) is excluded — 2h

**Estimated effort for full implementation**:
- Restricted Burgess construction (parameterized C5): 15-20h
- Restricted truth claim proof: 10-15h
- Mixed BFMCS with formula-guided families: 10-15h
- Case C resolution (if needed): 5-15h
- Integration and wire-up: 5-10h
- **Total: 45-75 hours** (with feasibility study reducing uncertainty)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | medium | Exhaustive gap-filling analysis proving all naive strategies fail; identified restricted Burgess as path forward |
| B | Alternatives | completed | medium | Ranked 5 alternatives; all converge on same core challenge; mosaic method ruled out |
| C | Critic | completed | high | Three critical findings: algebraic constraint, uniformity simplification, U(T,⊥)-on-ℚ blocker |
| D | Horizons | completed | medium | Strategic prioritization (147/148 first); risk analysis (40-80h realistic); insurance plan |

## References

- Burgess 1982: Chronicle construction (C0-C5, Lemma 2.6/2.10) — `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
- Caleiro-Vigano-Volpe 2013: Mosaic method for tense+S5 — `literature/Caleiro_Vigano_Volpe_2013_Mosaic_Method_Tense_Modal.md`
- Reynolds 1994: Integer compression pipeline — `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Existing research: `specs/142_mixed_case_countermodel/reports/01_mixed-case-research.md`
- Key source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (sorry site, BFMCS constructions)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (three-way case split)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence definitions)
  - `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (BFMCS structure)
  - `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (restricted truth lemma)
