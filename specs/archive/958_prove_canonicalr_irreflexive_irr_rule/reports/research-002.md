# Research Report: Task #958 - CanonicalR Irreflexivity (Team Research)

**Task**: 958 - prove_canonicalr_irreflexive_irr_rule
**Date**: 2026-03-11
**Mode**: Team Research (2 teammates)
**Domain Override**: logic (Lean task with modal logic focus)
**Focus**: Rigorously study the problem, compare best solutions, work forwards and backwards

## Summary

Team research conclusively establishes that:
1. **Direct axiom approach FAILS** - CanonicalR(M, M) is syntactically consistent with all axiom instances
2. **IRR rule is ESSENTIAL** - the only path to deriving irreflexivity
3. **Substitution approach is MOST PROMISING** - standard technique from Goldblatt/Blackburn-de Rijke-Venema
4. **Fixed-point/density approach FAILS** - witnesses can collapse to same MCS (documented in Boneyard)

Estimated implementation: **200-400 lines**, with significant proof engineering required.

## Key Findings

### From Teammate A: Axiom-Based Analysis

#### Forward Analysis: What CanonicalR(M, M) Gives Us

Assuming `GContent(M) ⊆ M`:

1. **HContent reflexivity follows**: `HContent(M) ⊆ M` via temp_a + double negation
2. **F-closure**: For any phi in M, `F(phi) in M` (via past_temp_a + H-closure)
3. **P-closure**: For any phi in M, `P(phi) in M` (via temp_a + G-closure)
4. **G-negation constraint**: For any phi in M, `G(neg phi) not in M`
5. **H-negation constraint**: For any phi in M, `H(neg phi) not in M`

These constraints are **mutually consistent** - no contradiction from axioms alone.

#### Key Realization

Without IRR, the axiom system is complete for **both** reflexive AND irreflexive frames. A reflexive-future point t where t < t satisfies all non-IRR axioms. The IRR rule **adds theorems** that distinguish "now" from "strict future."

### From Teammate B: IRR Rule and Semantic Analysis

#### The Projection Barrier

Direct IRR application faces a fundamental obstacle: all useful consequences of `(p AND H(neg p))` mention the fresh atom p. To derive a p-free contradiction:

- `neg G(H(neg p))` is derivable from `(p AND H(neg p))` but mentions p
- `G(bot) -> bot` is already derivable from seriality (no new information)
- `G(alpha) -> alpha` cannot be derived for arbitrary alpha

#### The H-Closure Derivation (New Result)

**Theorem**: If `CanonicalR(M, M)` then `HContent(M) ⊆ M`

**Proof Sketch**:
1. temp_a: `alpha -> G(P(alpha))` is a theorem
2. If `alpha in M`: `G(P(alpha)) in M`, hence `P(alpha) in M` (by G-closure)
3. `P(alpha) = neg(H(neg alpha))`, so `H(neg alpha) not in M`
4. Contrapositive + double negation in MCS: `H(psi) in M -> psi in M`

This intermediate result is useful for the final proof.

### Approach Comparison

| Approach | Status | Reasoning |
|----------|--------|-----------|
| Direct axioms (no IRR) | **FAILS** | Reflexive frames satisfy all non-IRR axioms |
| IRR direct theorem | **BLOCKED** | Projection barrier: p-free conclusions require p-information to project out |
| Semantic lifting + substitution | **MOST PROMISING** | Standard technique from literature, uses IRR contrapositively |
| Fixed-point / density | **FAILS** | Witnesses can collapse to same MCS (Boneyard RestrictedFragment.lean:434-444) |

## Recommended Approach: Substitution-Based Proof

### The Standard Literature Technique (Goldblatt, Blackburn-de Rijke-Venema)

1. **Assume** `CanonicalR(M, M)` for MCS M
2. **Choose** fresh atom p. Define `Gamma_p = { psi in M : p not in psi.atoms }`
3. **Show** `Gamma_p cup {p, H(neg p)}` is consistent (uses IRR contrapositively)
4. **Extend** to MCS M' via Lindenbaum
5. **Show** `CanonicalR(M, M')` (GContent(M) is p-free, subset of Gamma_p, subset of M')
6. **Derive contradiction**:
   - At M': `p in M'` and `H(neg p) in M'`
   - By H-closure derivation applied to M': `neg p in M'`
   - Contradiction with `p in M'`

### Implementation Steps

1. **Define** `atomFreeSubset (M : Set Formula) (p : String) : Set Formula`
2. **Prove** consistency lemma using IRR contrapositive:
   ```lean
   lemma naming_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
       (h_R : CanonicalR M M) (p : String) (h_fresh : p_fresh_for M) :
       SetConsistent (atomFreeSubset M p ∪ {atom p, H(neg(atom p))})
   ```
3. **Apply** Lindenbaum to extend to MCS M'
4. **Show** `CanonicalR(M, M')` from GContent subset property
5. **Derive** contradiction from H-closure at M'

### Critical Formalization Steps

1. **H-closure derivation** (~50-80 lines):
   - temp_a_past: `phi -> H(F(phi))`
   - Double negation theorems for temporal contexts
   - Chain through MCS implication property

2. **Consistency argument for Gamma_p cup {p, H(neg p)}** (~80-120 lines):
   - IRR contrapositive: if inconsistent, then `⊢ (p AND H(neg p)) -> neg(bigwedge Gamma)`
   - By IRR: `⊢ neg(bigwedge Gamma)`
   - But `bigwedge Gamma subset M`, contradicting M's consistency

3. **Main theorem** (~50-80 lines):
   - Combine consistency lemma with Lindenbaum
   - Show CanonicalR preservation
   - Apply H-closure contradiction

## Evidence: Key Lemmas from Codebase

### Existing Lemmas

| Lemma | Location | Signature |
|-------|----------|-----------|
| `GContent` | TemporalContent.lean:25 | `def GContent (M : Set Formula) : Set Formula := {phi \| Formula.all_future phi in M}` |
| `CanonicalR` | CanonicalFrame.lean:63 | `def CanonicalR (M M' : Set Formula) : Prop := GContent M ⊆ M'` |
| `theorem_in_mcs` | MaximalConsistent.lean:482 | `[] ⊢ φ → φ in S` |
| `set_mcs_implication_property` | MCSProperties.lean:150 | `(φ.imp ψ) in S → φ in S → ψ in S` |
| `set_mcs_negation_complete` | MCSProperties.lean:174 | `φ in S ∨ (neg φ) in S` |
| `set_consistent_not_both` | MCSProperties.lean:331 | `phi in S → phi.neg in S → False` |
| `canonical_forward_F` | CanonicalFrame.lean:122 | F-witness existence |
| `not_G_implies_F_neg` | SeparationLemma.lean:100 | G-negation to F-dual conversion |
| `DerivationTree.irr` | Derivation.lean:149 | IRR rule constructor |
| `irr_sound_dense_at_domain` | IRRSoundness.lean:232 | IRR soundness on dense irreflexive frames |

### Lemmas to Create

| Lemma | Estimated Lines | Purpose |
|-------|-----------------|---------|
| `H_closure_from_G_closure` | 50-80 | HContent(M) ⊆ M from GContent(M) ⊆ M |
| `naming_set_consistent` | 80-120 | Consistency of Gamma_p cup {p, H(neg p)} |
| `canonicalR_irreflexive` | 50-80 | Main theorem |

## Synthesis

### Conflicts Resolved

**Conflict**: Teammate A initially explored more formula candidates hoping for direct contradiction.

**Resolution**: Teammate B's systematic analysis of the projection barrier confirms that no p-free formula can be derived from `(p AND H(neg p))` that directly contradicts GContent closure. The substitution approach is necessary.

### Gaps Identified

1. **Syntactic complexity**: `neg` is a derived operator (`phi -> bot`), causing double negation issues
2. **Lindenbaum machinery**: May need to verify/extend existing Lindenbaum construction for this use case
3. **Atom freshness**: Need to formalize "p not appearing in any formula of GContent(M)"

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Substitution proof blocked by syntactic issues | HIGH | MEDIUM | Fall back to semantic soundness meta-argument |
| Lindenbaum extension fails | HIGH | LOW | Check existing machinery in MaximalConsistent.lean |
| Double negation overhead large | MEDIUM | MEDIUM | Use classical lemmas from MCSProperties |
| Proof exceeds 400 lines | MEDIUM | MEDIUM | Consider phased implementation |

## Confidence Level

**Medium** with justification:
- The theoretical approach (Goldblatt/BdRV) is well-established in modal logic literature
- Both teammates independently converged on the same approach
- The codebase has most required lemmas (MCS properties, IRR rule, temporal content)
- Remaining gaps (H-closure, consistency argument) have clear proof sketches
- Main risk is syntactic complexity of Lean formalization

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Axiom analysis | completed | Forward/backward analysis; demonstrated axiom approach fails | medium |
| B | IRR/semantic | completed | Projection barrier; H-closure derivation; substitution approach detail | medium-low |

## Next Steps

1. **Implement H-closure derivation** as standalone lemma
2. **Implement consistency argument** for naming set
3. **Implement main theorem** combining the pieces
4. **Verify with `lake build`** after each major lemma

## References

- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Cambridge University Press. Chapter 5.
- Gabbay, D.M. (1981). An irreflexivity lemma with applications to axiomatizations of conditions on tense frames.

---

**Research completed by team of 2 agents**
**Synthesis by lead agent**
**Session**: sess_1773249619_be194992
