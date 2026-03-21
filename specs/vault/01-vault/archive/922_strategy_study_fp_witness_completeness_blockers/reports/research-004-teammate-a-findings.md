# Research Report: CanonicalR Antisymmetry Blocker Analysis

**Task**: 922 - strategy_study_fp_witness_completeness_blockers
**Date**: 2026-02-24
**Focus**: Can CanonicalR antisymmetry be proven with temp_linearity, and what is the recommended path forward?

## Summary

CanonicalR antisymmetry (CanonicalR M1 M2 AND CanonicalR M2 M1 implies M1 = M2) **cannot be proven** from the current axiom set, including temp_linearity. The linearity axiom ensures *totality* (comparability) of the reachable fragment but does not prevent two distinct MCSes from being mutually related. The recommended approach is to use Mathlib's `Antisymmetrization` quotient, which turns the total preorder into a `LinearOrder` with no proof of antisymmetry required.

## Key Findings

### 1. Antisymmetry is Unprovable from temp_linearity

**Analysis**: Suppose M1 and M2 are distinct MCSes with CanonicalR M1 M2 and CanonicalR M2 M1. From `gcontent_eq_of_mutual_R`, we know GContent(M1) = GContent(M2), meaning G(phi) is in M1 iff G(phi) is in M2 for all phi.

Since M1 and M2 are distinct MCSes, there exists some phi such that phi in M1 and phi NOT in M2. From this setup, we can derive:

1. **G(phi) NOT in M1**: If G(phi) in M1, then phi in GContent(M1), so phi in M2 via CanonicalR(M1, M2). But phi NOT in M2 -- contradiction.

2. **G(neg(phi)) NOT in M1**: If G(neg(phi)) in M1, then neg(phi) in M1 via temp_t_future. But phi in M1 -- consistency violation.

3. Therefore **F(phi) in M1 and F(neg(phi)) in M1** (both by MCS negation completeness and the definition F(psi) = neg(G(neg(psi)))).

4. Applying temp_linearity to F(phi) and F(neg(phi)) in M1, Case 1 (F(phi AND neg(phi))) is ruled out by `F_conj_neg_not_in_mcs`. Cases 2 and 3 each produce witnesses W at which G-formulas from one component propagate via CanonicalR. However:

   - **Cases 2 and 3 do NOT produce contradictions.** The witnesses W satisfy CanonicalR(M1, W) and contain specific formulas, but the linearity comparison of W with M2 has three sub-cases, and the non-equality sub-cases (CanonicalR(W, M2) or CanonicalR(M2, W)) do not yield contradictions. They just produce further CanonicalR chains without closing the proof.

5. **The linearity argument is vacuously satisfied for mutual CanonicalR.** The proof of `canonical_reachable_linear` shows: if M1 and M2 are NOT comparable, derive a contradiction. When M1 and M2 ARE mutually CanonicalR-related, the comparability hypothesis is trivially satisfied. The linearity axiom never needs to "fire" to rule out this case.

**Semantic counterexample sketch**: In a canonical frame construction, consider two MCSes M1 and M2 that are Lindenbaum completions of the same seed {GContent(M0)} but with different non-deterministic choices for propositional atoms. Since Lindenbaum (via Zorn's lemma) produces SOME maximal extension, different applications can produce different MCSes. Both M1 and M2 will contain GContent(M0), making them CanonicalR-related from M0 and from each other (since they have the same GContent by construction), but they may differ on propositional atoms.

### 2. GContent Equality Does NOT Constrain Full Content

When GContent(M1) = GContent(M2), the MCSes agree on all G-prefixed formulas. But they can differ on:

- **Propositional atoms**: p in M1, neg(p) in M2 (as long as G(p) and G(neg(p)) are both absent)
- **F-formulas**: F(psi) in M1, neg(F(psi)) in M2 (as long as this is consistent with shared GContent)
- **Box-formulas**: Box(psi) in M1 but not in M2 (modal content is independent of temporal GContent)
- **H-formulas / P-formulas**: Past-temporal content is not constrained by GContent equality

The only constraint is: for any phi where G(phi) is in the shared GContent, phi must be in both M1 and M2 (by CanonicalR). This does NOT force M1 = M2 because:
- Not every formula is of the form "some phi where G(phi) exists in the MCS"
- Propositional atoms, F-formulas, and complex combinations can freely differ

### 3. Mathlib's Antisymmetrization is the Right Tool

**`Antisymmetrization` (Mathlib.Order.Antisymmetrization)**: This quotient construction takes a preorder and produces a partial order by identifying elements that are related both ways. For a total preorder, the result is a linear order.

The key Mathlib result (line 306-311 of Antisymmetrization.lean):

```
instance [DecidableLE alpha] [DecidableLT alpha] [IsTotal alpha (. <= .)] :
    LinearOrder (Antisymmetrization alpha (. <= .))
```

**Requirements for applying this to CanonicalReachable**:
1. **Preorder on CanonicalReachable** - Define LE via CanonicalR. Reflexivity from `canonicalR_reflexive`, transitivity from `canonicalR_transitive`.
2. **IsTotal** - From `canonical_reachable_comparable` (any two elements are CanonicalR-comparable or equal, and equal implies CanonicalR-comparable by reflexivity). Note: the existing theorem gives a three-way disjunction; need to massage this into `IsTotal (. <= .)`.
3. **DecidableLE** - Since Formula has DecidableEq and is Countable, CanonicalR (GContent subset) is in principle decidable. However, for sets (Set Formula), decidability may require classical logic or a classical instance. Can use `Classical.dec` instances.
4. **DecidableLT** - Follows from DecidableLE.

**Verified lemma existence** (via lean_local_search):
- `Antisymmetrization` - exists in Mathlib (Mathlib.Order.Antisymmetrization)
- `AntisymmRel` - exists
- `toAntisymmetrization` - exists
- `ofAntisymmetrization` - exists
- `instPartialOrderAntisymmetrization` - exists
- The LinearOrder instance for total preorder antisymmetrization exists

### 4. Detailed Antisymmetrization Approach

**Step 1: Define Preorder on CanonicalReachable**

```lean
instance : LE (CanonicalReachable M0 h_mcs0) where
  le a b := CanonicalR a.world b.world

instance : Preorder (CanonicalReachable M0 h_mcs0) where
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc
```

**Step 2: Prove IsTotal**

From `canonical_reachable_comparable`: for any a b, CanonicalR a.world b.world OR CanonicalR b.world a.world OR a.world = b.world. The third case implies the first (by reflexivity), so we get `a <= b OR b <= a`.

**Step 3: Define the quotient**

```lean
def CanonicalReachableQuotient := Antisymmetrization (CanonicalReachable M0 h_mcs0) (. <= .)
```

This automatically has a `LinearOrder` (from the Mathlib instance).

**Step 4: Lift properties to the quotient**

The quotient representatives (via `ofAntisymmetrization`) map back to CanonicalReachable elements. The key insight: elements in the same equivalence class (mutually CanonicalR-related) have the same GContent and therefore satisfy the same G-formulas. For the completeness proof, this means:

- **forward_G**: If G(phi) in the representative, then phi propagates to all future quotient classes (since CanonicalR respects equivalence classes).
- **forward_F**: If F(phi) in ANY element of a class, then F(phi) in ALL elements of that class (because mutual CanonicalR means the same F-formulas hold... wait, this needs verification).

**Critical subtlety**: Do mutually CanonicalR-related MCSes have the same F-content? NOT necessarily. F(phi) = neg(G(neg(phi))), and while G(neg(phi)) is shared (by GContent equality), F(phi) depends on neg(G(neg(phi))) which IS shared (since G(neg(phi)) is shared, its negation is shared by MCS negation completeness).

Wait -- this is a key insight! Let me verify:

For any phi: G(phi) in M1 iff G(phi) in M2 (from GContent equality).
Therefore: neg(G(phi)) in M1 iff neg(G(phi)) in M2 (by MCS negation completeness applied to each).
But F(neg(phi)) = neg(G(phi)), so: F(neg(phi)) in M1 iff F(neg(phi)) in M2.
And F(phi) = neg(G(neg(phi))), so: G(neg(phi)) in M1 iff G(neg(phi)) in M2, which means F(phi) in M1 iff F(phi) in M2.

**Therefore: mutually CanonicalR-related MCSes agree on ALL F-formulas and G-formulas.** They can only differ on:
- Propositional atoms (not prefixed by G or F)
- Box/Diamond formulas (modal content independent of temporal content)
- H/P formulas (past-temporal content)
- Complex nested combinations

But for the BFMCS construction, what matters is: the truth value of temporal formulas at each position. If equivalence-class representatives agree on G and F formulas, the temporal coherence properties (forward_G, forward_F, backward_H, backward_P) are well-defined on equivalence classes.

### 5. Confidence Assessment

**Can antisymmetry be proven with temp_linearity alone?**

**Confidence: LOW (10-15%)**

The linearity axiom constrains comparability, not identity. The case analysis from temp_linearity with F(phi) and F(neg(phi)) produces witnesses but does not close to a contradiction. The fundamental issue is that Lindenbaum's lemma (Zorn's lemma) is non-deterministic: different maximal extensions of the same consistent seed can produce distinct MCSes.

For antisymmetry to hold, one would need an axiom that forces: if two MCSes agree on all G-formulas, they agree on all formulas. No such axiom exists in the TM system. The T-axiom (G(phi) -> phi) lets you extract phi from G(phi), but does not force every phi in an MCS to be derivable from G-formulas.

**Can the quotient approach work?**

**Confidence: HIGH (85-90%)**

The `Antisymmetrization` quotient is a standard Mathlib construction with a proven `LinearOrder` instance for total preorders. The main risks are:
1. Ensuring DecidableLE / DecidableLT (mitigated by classical instances)
2. Proving NoMaxOrder / NoMinOrder on the quotient (transfers from the preorder)
3. Proving IsSuccArchimedean on the quotient (requires countability + locally finite)
4. The quotient may not be `Countable` automatically (but Formula is Countable, so the quotient of a countable type by a decidable relation is countable)

### 6. Alternative: Direct Antisymmetry Proof via Stronger Axiom

If antisymmetry is absolutely needed (without quotient), one could add an axiom:

**G-determinacy**: `G(phi) OR G(neg(phi))` for all phi

This would force: every formula phi either always holds in the future or its negation always holds. Combined with temp_t (G(phi) -> phi), this would mean: for mutually CanonicalR-related MCSes with GContent equality, every phi is either in GContent or its negation is in GContent, so both MCSes agree on phi.

However, this axiom is semantically unsound for interesting temporal models (it would force all propositions to be "eventually settled"). It is NOT recommended.

### 7. Impact on Downstream Phases

Using the Antisymmetrization quotient affects the remaining plan:

**Phase 3 revision**:
- Define Preorder on CanonicalReachable (straightforward)
- Take Antisymmetrization quotient (automatic LinearOrder)
- Prove Countable, NoMaxOrder, NoMinOrder on the quotient
- Define SuccOrder/PredOrder (from linear order on countable type)
- Prove IsSuccArchimedean (from LocallyFiniteOrder, if available, or directly from countability)
- Apply `orderIsoIntOfLinearSuccPredArch`

**Phase 4 revision**:
- BFMCS construction uses quotient representatives
- forward_G/backward_H: representatives share GContent, so G-propagation works through quotient
- forward_F/backward_P: F-formulas are shared within equivalence classes (proven above), so canonical_forward_F witnesses can be projected to the quotient

**Phase 5**: Unchanged. The completeness chain receives a BFMCS Int as before.

## Recommended Approach

**Use the Antisymmetrization quotient.** This is the mathematically clean and Mathlib-supported path.

1. **Define Preorder on CanonicalReachable** via CanonicalR
2. **Prove IsTotal** from canonical_reachable_comparable
3. **Define CanonicalReachableQuotient** as `Antisymmetrization (CanonicalReachable M0 h_mcs0) (. <= .)`
4. **LinearOrder is automatic** from Mathlib's instance
5. **Prove Countable** on the quotient (Formula is Countable, CanonicalReachable is a subtype, quotient of countable is countable)
6. **Prove NoMaxOrder and NoMinOrder** (transfer from preorder: strict successors/predecessors exist)
7. **Define SuccOrder/PredOrder and prove IsSuccArchimedean** (from countability and linear order)
8. **Apply orderIsoIntOfLinearSuccPredArch** to get OrderIso to Int
9. **Construct BFMCS Int** via the OrderIso, using quotient representatives

## Evidence

### Verified Lemma Existence (via lean_local_search)

| Lemma Name | Exists | Location |
|-----------|--------|----------|
| `Antisymmetrization` | Yes | Mathlib.Order.Antisymmetrization |
| `AntisymmRel` | Yes | Mathlib.Order.Antisymmetrization |
| `AntisymmRel.setoid` | Yes | Mathlib.Order.Antisymmetrization |
| `toAntisymmetrization` | Yes | Mathlib.Order.Antisymmetrization |
| `ofAntisymmetrization` | Yes | Mathlib.Order.Antisymmetrization |
| `instPartialOrderAntisymmetrization` | Yes | Mathlib.Order.Antisymmetrization |
| `orderIsoIntOfLinearSuccPredArch` | Yes | Mathlib.Order.SuccPred.LinearLocallyFinite |
| `canonical_reachable_linear` | Yes | Project (CanonicalEmbedding.lean) |
| `gcontent_eq_of_mutual_R` | Yes | Project (CanonicalReachable.lean) |
| `canonical_forward_F_strict` | Yes | Project (CanonicalReachable.lean) |
| `F_conj_neg_not_in_mcs` | Yes | Project (CanonicalReachable.lean) |
| `canonicalR_reflexive` | Yes | Project (CanonicalFrame.lean) |
| `canonicalR_transitive` | Yes | Project (CanonicalFrame.lean) |

### Key Mathlib Instance (from Antisymmetrization.lean, line 306-311)

```lean
instance [DecidableLE alpha] [DecidableLT alpha] [IsTotal alpha (. <= .)] :
    LinearOrder (Antisymmetrization alpha (. <= .)) :=
  { instPartialOrderAntisymmetrization with
    le_total := fun a b => Quotient.inductionOn2' a b <| total_of (. <= .),
    toDecidableLE := ...,
    toDecidableLT := ... }
```

### Key Project Lemma Types

- `gcontent_eq_of_mutual_R`: GContent M1 = GContent M2 when CanonicalR M1 M2 and CanonicalR M2 M1
- `canonical_reachable_comparable`: For reachable a b, CanonicalR a.world b.world OR CanonicalR b.world a.world OR a.world = b.world
- `canonical_forward_F_strict`: F(phi) in M with phi not in M gives DISTINCT successor W
- `F_conj_neg_not_in_mcs`: F(phi AND neg(phi)) never in any MCS

## Confidence Level

**Overall confidence in the Antisymmetrization approach: HIGH (85-90%)**

- Mathlib infrastructure is mature and well-tested
- The Preorder + IsTotal requirements are already essentially proven
- The quotient preserves the properties needed for BFMCS construction
- F-formula and G-formula agreement within equivalence classes ensures temporal coherence transfers cleanly
- Main risks are around DecidableLE (mitigated by Classical instances), Countable quotient (straightforward), and NoMaxOrder/NoMinOrder (needs careful proof but expected to work)

**Confidence that antisymmetry can be proven directly: LOW (10-15%)**

- The linearity axiom does not force antisymmetry
- Lindenbaum non-determinism allows distinct MCSes with identical GContent
- No existing axiom constrains propositional content from G-content
- The Case 2/3 sub-case analysis does not close

## Next Steps

1. Implement the Preorder instance on CanonicalReachable
2. Prove IsTotal from canonical_reachable_comparable
3. Define the Antisymmetrization quotient and verify LinearOrder is synthesized
4. Prove Countable on the quotient
5. Address NoMaxOrder/NoMinOrder for the quotient
6. Define SuccOrder/PredOrder and prove IsSuccArchimedean
7. Apply orderIsoIntOfLinearSuccPredArch

## References

- Mathlib `Antisymmetrization`: Mathlib.Order.Antisymmetrization
- Mathlib `orderIsoIntOfLinearSuccPredArch`: Mathlib.Order.SuccPred.LinearLocallyFinite
- Goldblatt 1992, *Logics of Time and Computation* (canonical model for tense logics)
- Phase 3 handoff: `specs/922_strategy_study_fp_witness_completeness_blockers/handoffs/phase-3-handoff-20260224T215519.md`
- Research-003: `specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-003.md`
- CanonicalReachable.lean: `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`
- CanonicalFrame.lean: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- CanonicalEmbedding.lean: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`
