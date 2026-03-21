# Research Findings: Two-Place Task Relation as Temporal Ordering

**Teammate**: B
**Focus**: Using the two-place MCS accessibility relation as temporal ordering, with linearly ordered families
**Date**: 2026-02-25

## Key Findings

### 1. The Current Architecture Already Uses a Two-Place Relation

The codebase already defines a two-place relation between MCSs: `CanonicalR M M'` iff `GContent(M) ⊆ M'` (CanonicalFrame.lean:63). This relation has proven properties:

- **Reflexive**: `canonicalR_reflexive` (CanonicalFrame.lean:180) -- uses T-axiom `G phi -> phi`
- **Transitive**: `canonicalR_transitive` (CanonicalFrame.lean:217) -- uses Temporal 4 axiom `G phi -> GG phi`
- **NOT antisymmetric in general**: see Finding 3 below

The current `BFMCS` structure (BFMCS.lean:79) indexes families by a time type `D` with `[Preorder D]`. The `CanonicalMCS` type wraps all MCSs with the `CanonicalR`-based preorder (CanonicalBFMCS.lean:95).

**The user's proposal is effectively: take `CanonicalR` (or a variant using BoxGContent) as the temporal ordering, and define families as chains within this ordering.**

### 2. Two Candidate Relations: CanonicalR vs BoxG-Relation

The user's specification in research-002.md defines four constraints (C1-C4) using `BoxGContent` and `BoxHContent`:

| Relation | Definition | Properties |
|----------|-----------|------------|
| **CanonicalR** | `GContent(w) ⊆ u` (i.e., `G phi in w => phi in u`) | Reflexive + Transitive (proven) |
| **BoxG-Relation** | `BoxGContent(w) ⊆ u` (i.e., `Box(G phi) in w => phi in u`) | Reflexive (proven in research-002), NOT transitive (proven in research-002) |

Research-002 Finding 3 established that the BoxG-relation is **not transitive**: from `w -> u` and `u -> v`, we cannot derive `w -> v` because `phi in u` does not imply `Box(G phi) in u`.

Research-002 Finding 1 established that `BoxGContent(w) ⊆ GContent(w)` (strictly weaker), meaning the BoxG-relation connects MORE pairs of MCSs than CanonicalR.

**Verdict**: `CanonicalR` is the better candidate for temporal ordering because it is already transitive. The BoxG-relation would need to be made transitive through taking its transitive closure, which loses the clean compositional structure.

### 3. Antisymmetry Analysis -- The Critical Question

The user asks for the ordering to be **anti-symmetric** (`w <= u` and `u <= w` implies `w = u`). This would upgrade the preorder to a partial order.

**Is CanonicalR antisymmetric?**

`CanonicalR w u` AND `CanonicalR u w` means:
- `GContent(w) ⊆ u` AND `GContent(u) ⊆ w`

This implies:
1. For all phi: `G phi in w => phi in u` AND `G phi in u => phi in w`
2. By Temporal 4 (`G phi => GG phi`), if `G phi in w` then `GG phi in w`, so `G phi in GContent(w) ⊆ u`, and thus `G phi in u`
3. Similarly, `G phi in u => G phi in w`
4. So `GContent(w) = GContent(u)` (as sets of G-formulas)

But does `GContent(w) = GContent(u)` and `GContent(w) ⊆ u` and `GContent(u) ⊆ w` imply `w = u`?

**NO**. Two distinct MCSs can have the same GContent while differing on non-G formulas. Consider MCSs w and u where:
- `w` contains `p` but not `G p`
- `u` contains `neg p` but not `G(neg p)`
- Both contain exactly the same G-formulas

Such pairs are possible because GContent only constrains the G-fragment. The MCSs can differ on propositional atoms and non-temporal formulas.

**Conclusion**: CanonicalR is **NOT antisymmetric** in general on the space of all MCSs. Making it a partial order would require quotienting by the equivalence relation `w ~ u iff (CanonicalR w u and CanonicalR u w)`.

Mathlib provides exactly this construction: `Antisymmetrization` (in `Mathlib.Order.Antisymmetrization`), which quotients a preorder by its induced equivalence to produce a partial order. We have:
- `Antisymmetrization CanonicalMCS (fun a b => a <= b)` would give a `PartialOrder`
- `toAntisymmetrization` and `ofAntisymmetrization` for conversions

**However**, quotienting MCSs destroys the ability to evaluate formula membership at specific MCSs. Two equivalent MCSs (same G-formulas, different propositional content) would be identified, but we need propositional formulas for the truth lemma.

### 4. Families as Chains in the CanonicalR Preorder

The user proposes: "consider sets of MCSs that are linearly ordered by this temporal ordering."

In Mathlib, `IsChain (fun x y => x <= y) S` (from `Mathlib.Order.Preorder.Chain`) defines a chain: a set `S` where any two distinct elements are comparable. For MCSs with the CanonicalR preorder:

A **family** would be a set `S : Set CanonicalMCS` with `IsChain (fun x y => x <= y) S`, meaning:
- For any `w, u in S` with `w != u`, either `CanonicalR w.world u.world` or `CanonicalR u.world w.world`
- Equivalently: `GContent(w) ⊆ u` or `GContent(u) ⊆ w`

**Advantages of this formulation**:

1. **No commitment to integer time**: The ordering comes from the logical content of the MCSs themselves. No external time index is needed.
2. **Temporal density is not precluded**: Between any two MCSs in the chain, there could be arbitrarily many intermediate MCSs. This allows temporal density axioms to be added without changing the framework.
3. **Linear ordering within families is structural**: The `IsChain` property directly encodes totality within each family, without needing to derive it from integer properties.
4. **Convexity/completeness can be imposed separately**: Additional axioms (like `Flag.max_chain'` for maximal chains) can enforce completeness.

**Challenges**:

1. **The BFMCS structure currently requires `mcs : D -> Set Formula`**: Converting to chain-based families requires changing the signature from a function on an ordered type to a set with chain structure.
2. **G/H coherence must hold within chains**: For `w <= u` in the chain (i.e., `GContent(w) ⊆ u`), the forward_G property is automatic. But backward_H requires the duality: `CanonicalR w u => HContent(u) ⊆ w`. This is **already proven** as `GContent_subset_implies_HContent_reverse` (DovetailingChain.lean:767).
3. **Evaluation at "times" becomes evaluation at chain elements**: Instead of `fam.mcs t` for time `t`, we have `w.world` for chain element `w`. The truth lemma would quantify over chain elements rather than time indices.

### 5. Formal Definition of Chain-Based Families

Here is a concrete Lean 4 formalization sketch:

```lean
/-- A temporal family is a chain of MCSs under CanonicalR, with an evaluation point. -/
structure TemporalFamily where
  /-- The set of MCSs forming the family -/
  chain : Set CanonicalMCS
  /-- The chain is linearly ordered under CanonicalR -/
  is_chain : IsChain (fun x y => x <= y) chain
  /-- The chain is non-empty -/
  nonempty : chain.Nonempty

/-- Get the MCS at a chain element -/
def TemporalFamily.mcs_at (fam : TemporalFamily) (w : CanonicalMCS) (hw : w ∈ fam.chain) :
    Set Formula :=
  w.world

/-- Forward G coherence within the chain (automatic from CanonicalR definition) -/
theorem TemporalFamily.forward_G (fam : TemporalFamily)
    (w u : CanonicalMCS) (hw : w ∈ fam.chain) (hu : u ∈ fam.chain)
    (h_le : w ≤ u) (phi : Formula) (h_G : Formula.all_future phi ∈ w.world) :
    phi ∈ u.world :=
  canonical_forward_G w.world u.world h_le phi h_G

/-- Backward H coherence within the chain (from GContent/HContent duality) -/
theorem TemporalFamily.backward_H (fam : TemporalFamily)
    (w u : CanonicalMCS) (hw : w ∈ fam.chain) (hu : u ∈ fam.chain)
    (h_le : u ≤ w) (phi : Formula) (h_H : Formula.all_past phi ∈ w.world) :
    phi ∈ u.world :=
  -- Uses GContent_subset_implies_HContent_reverse
  canonical_backward_H w.world u.world
    (GContent_subset_implies_HContent_reverse u.world w.world u.is_mcs w.is_mcs h_le) phi h_H
```

### 6. Transitivity is Already Proven -- No Additional Constraints Needed

The user asks: "Do the C1/C2 constraints give transitivity?"

For **CanonicalR** (using `GContent`):
- **Yes**, transitivity is already proven in `canonicalR_transitive` (CanonicalFrame.lean:217)
- The proof uses Temporal 4: `G phi => GG phi`. From `G phi in w` we get `GG phi in w`, so `G phi in GContent(w) ⊆ u`, and then `phi in GContent(u) ⊆ v`.

For the **BoxG-relation** (using `BoxGContent`):
- **No**, as established in research-002 Finding 3. The step `phi in u => Box(G phi) in u` fails because there is no axiom `phi => Box(G phi)`.

**The GContent-based relation (CanonicalR) satisfies both transitivity and anti-reflexivity requirements automatically from existing axioms.** No additional constraints are needed beyond what the axiom system already provides.

### 7. Non-Integer Time Advantage -- Temporal Density

The current `TaskFrame` (TaskFrame.lean:84) parameterizes by `D` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. When instantiated with `Int`, this commits to discrete time.

The user notes: "Using Int implicitly commits to discreteness and prevents adding temporal density axioms."

**With chain-based families**:
- The "time structure" emerges from the logical content of MCSs
- Between any two chain elements `w < u`, there may be 0, finitely many, or infinitely many intermediate MCSs
- Temporal density (for any `w < u`, exists `v` with `w < v < u`) becomes a property of the chain, not an axiom about integers
- The current `temp_linearity` axiom (Axioms.lean:316) ensures linearity of the temporal order. In the chain-based approach, linearity is built into the `IsChain` structure.

**Practical impact**: If a temporal density axiom were added to the proof system, the chain-based construction could naturally accommodate it by finding intermediate MCSs (via Lindenbaum). An Int-indexed construction could not.

### 8. Integration with Existing BMCS Architecture

The current BMCS (BMCS.lean:82) bundles `families : Set (BFMCS D)`. Converting to chain-based families requires either:

**Option A: Redefine BFMCS as chain-based**
- Replace `mcs : D -> Set Formula` with chain structure
- Loses the clean function-based interface
- Requires rewriting all downstream consumers

**Option B: Use CanonicalMCS as the time type D (current approach)**
- Already implemented: `canonicalMCSBFMCS` (CanonicalBFMCS.lean:158)
- Each chain in CanonicalMCS IS a family indexed by its chain elements
- The preorder on CanonicalMCS provides CanonicalR as the temporal ordering
- **This is essentially the chain-based approach already**, just expressed differently

**Key insight**: The current `canonicalMCSBFMCS` construction ALREADY implements the user's idea! It uses `CanonicalMCS` (all MCSs with CanonicalR preorder) as the time domain `D`, and `mcs(w) = w.world` is the identity mapping. The "family" is the entire set of MCSs, ordered by CanonicalR.

The difference from the user's proposal is that the current construction uses ONE family containing ALL MCSs, rather than MULTIPLE families that are each linear chains. The user's proposal would partition (or select subsets of) the CanonicalMCS space into linear chains.

### 9. Why Multiple Chain Families Matter

Using one big family (current approach) vs. multiple chain families (user's proposal):

**One family (current canonicalMCSBFMCS)**:
- `D = CanonicalMCS` (preorder, not linear order)
- The preorder is NOT total: two MCSs may be CanonicalR-incomparable
- This means the `temp_linearity` axiom is NOT validated by this structure
- The truth lemma's G/H cases assume `s <= t` or `t <= s` for time comparison, which fails for incomparable elements

**Multiple chain families (user's proposal)**:
- Each family is a maximal chain in the CanonicalR preorder
- Within each chain, the ordering IS total (by definition of chain)
- This validates linearity within each family
- The Box operator quantifies over ALL families (chains)
- G/H operators quantify over elements WITHIN the same chain

**This addresses a real problem**: The current `canonicalMCSBFMCS` construction uses a non-total preorder, which means the BFMCS's `forward_G` and `backward_H` only apply to comparable elements. For the truth lemma's G case, we need: "if `G phi` not in `fam.mcs(t)`, then there exists `s >= t` with `neg phi` in `fam.mcs(s)`." This requires `forward_F`, which gives a witness `s` with `CanonicalR t s`. But in the truth lemma, we need to evaluate at ALL `s >= t`, which in a non-total order might include elements incomparable with the witness.

With chain-based families, every pair of elements in a family is comparable, so the G/H truth lemma arguments work correctly.

## Two-Place Relation Definition (Formal)

The proposed temporal ordering between MCSs:

```
w ≤ u  :=  CanonicalR w u  :=  GContent(w) ⊆ u
         equivalently: for all phi, G phi in w implies phi in u
```

**Properties (all proven in the codebase)**:
- Reflexive: by T-axiom `G phi -> phi` (CanonicalFrame.lean:180)
- Transitive: by Temporal 4 `G phi -> GG phi` (CanonicalFrame.lean:217)
- Duality: `w ≤ u` implies `HContent(u) ⊆ w` (DovetailingChain.lean:767)

**Properties NOT satisfied**:
- Antisymmetric: fails in general (distinct MCSs can have identical G-fragments)
- Total: fails in general (MCSs may have incomparable G-fragments)

## Family Structure Without Int

A family is defined as a **maximal chain** in the CanonicalR preorder:

```lean
structure TemporalChainFamily where
  chain : Set CanonicalMCS
  is_chain : IsChain (fun x y => x ≤ y) chain
  is_maximal : ∀ S : Set CanonicalMCS, IsChain (fun x y => x ≤ y) S → chain ⊆ S → chain = S
```

This corresponds to Mathlib's `Flag` structure (Mathlib.Order.Preorder.Chain):
```lean
structure Flag (α : Type*) [LE α] where
  carrier : Set α
  Chain' : IsChain (· ≤ ·) carrier
  max_chain' : ∀ ⦃s⦄, IsChain (· ≤ ·) s → carrier ⊆ s → carrier = s
```

**Existence**: By Zorn's lemma, every element of CanonicalMCS is contained in some maximal chain. Mathlib provides `maxChain_spec` or related results for this.

**Equivalence to current BFMCS**: A `Flag CanonicalMCS` gives a linearly ordered subset of all MCSs. The ordering within this subset is total, reflexive, and transitive. The MCS at each "time point" (chain element) is the element itself. Forward_G and backward_H hold by the CanonicalR definition and duality.

## Transitivity Analysis

### CanonicalR Transitivity (Proven)

Given `w ≤ u` (GContent(w) ⊆ u) and `u ≤ v` (GContent(u) ⊆ v):

1. Let `phi in GContent(w)`, i.e., `G phi in w`
2. By Temporal 4: `G phi -> GG phi`, so `GG phi in w` (MCS closure)
3. `G phi in GContent(w)` (since `GG phi = G(G phi) in w`)
4. `G phi in u` (by `GContent(w) ⊆ u`)
5. `phi in GContent(u)` (since `G phi in u`)
6. `phi in v` (by `GContent(u) ⊆ v`)

Therefore `GContent(w) ⊆ v`, i.e., `w ≤ v`. QED.

### BoxG-Relation Non-Transitivity (From Research-002)

Given `w ->_BG u` (BoxGContent(w) ⊆ u) and `u ->_BG v` (BoxGContent(u) ⊆ v):

For `w ->_BG v` we need BoxGContent(w) ⊆ v. Take `phi in BoxGContent(w)`, so `Box(G phi) in w`.
- From `w ->_BG u`: `phi in u`
- For `phi in v`, we need `Box(G phi) in u`, i.e., `phi in BoxGContent(u)`
- But we only have `phi in u`, not `Box(G phi) in u`
- There is no axiom `phi -> Box(G phi)` in TM

**The gap**: transitivity requires each step to "re-box" the formula, but there's no axiom for this.

**However**: There IS an axiom `Box phi -> Box(G phi)` (modal_future, Axioms.lean:282). And `Box phi -> G phi` follows from modal_t + the temp_future direction. This means `Box(G phi) in w -> Box phi in w -> Box(G phi) in w` is circular but `Box(G phi) in w -> G phi in w` (by modal_t applied to `Box(G phi)` giving `G phi`).

The issue is that from `phi in u` alone, we cannot get `Box(G phi) in u`. We would need `phi -> Box(G phi)` which is not a theorem of TM.

## Confidence Level

**HIGH (80%)** for the CanonicalR-based chain approach:
- CanonicalR is already proven reflexive and transitive
- Chain-based families naturally provide linearity
- Forward_G and backward_H are automatic within chains
- The approach genuinely avoids commitment to integer time
- Existing Mathlib infrastructure (IsChain, Flag) can be leveraged

**MODERATE (55%)** for practical implementation:
- Significant refactoring of BFMCS required
- The antisymmetry failure means chains are preorder-chains, not partial-order chains
- Modal saturation (witness families for Diamond) still needs resolution
- Forward_F/backward_P within chains requires showing witnesses can be chosen IN the same chain

**LOW (25%)** for the BoxG-relation variant:
- Non-transitive, requiring transitive closure
- Weaker than CanonicalR (less information)
- No clear advantage over CanonicalR

## Open Questions

1. **Can forward_F witnesses be chosen within maximal chains?** If `F phi in w` and `w` is in chain `C`, can we find `s in C` with `s >= w` and `phi in s`? Or might the witness be outside `C`?

2. **How does modal saturation interact with chain families?** When constructing witness families for Diamond formulas, are the witness families also maximal chains?

3. **Does the antisymmetry failure matter in practice?** The chain elements are preorder-comparable, which gives totality but not uniqueness of representation. Two "different times" in a chain might have `w <= u` and `u <= w` without `w = u`.

4. **Can the current BFMCS interface be preserved?** Ideally, chain-based families would be a refinement of the existing BFMCS, not a replacement. Is there a type `D` with `[LinearOrder D]` that represents chain elements?

## References

- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR definition, reflexivity, transitivity
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - canonicalMCSBFMCS, CanonicalMCS type with Preorder
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - Current BFMCS structure with `D -> Set Formula`
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - Bundle structure with modal coherence
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - GContent/HContent duality theorem
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame with polymorphic time type D
- `Theories/Bimodal/ProofSystem/Axioms.lean` - TM axioms including temp_4, temp_t_future, modal_future
- `Mathlib.Order.Preorder.Chain` - IsChain, Flag structures
- `Mathlib.Order.Antisymmetrization` - Antisymmetrization of preorders
- `specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-002.md` - C1-C4 constraints, BoxGContent analysis
