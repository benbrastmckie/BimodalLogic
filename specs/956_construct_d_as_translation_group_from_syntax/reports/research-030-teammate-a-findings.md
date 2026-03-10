# Research Report: Countability Blocker Resolution Paths

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-10
**Run**: 030 (teammate A)
**Focus**: Mathematical analysis of four approaches to resolve the countability blocker
**Role**: Evaluate approaches 1-4 from the task context with Mathlib infrastructure assessment

---

## Key Findings

1. **The countability blocker is real and fundamental**: The canonical timeline as defined (all MCS bidirectionally reachable from M₀ via CanonicalR) is genuinely uncountable. The argument from research-018 is correct. There is no error; the blocker requires a positive resolution strategy.

2. **Approach 1 (Constructive Countable Fragment) is the strongest**: It is mathematically sound, avoids Löwenheim-Skolem formalization complexity, preserves "D from syntax" philosophy, and has a clear Lean 4 implementation path using `Set.countable_iUnion` and `Nat`-indexed induction.

3. **Approach 2 (Löwenheim-Skolem) is sound but has severe formalization overhead**: Mathlib has the required theorems (`FirstOrder.Language.exists_elementarySubstructure_card_eq`), but bridging our custom propositional modal logic to Mathlib's first-order framework requires approximately 200-400 lines of boilerplate. This is disproportionate to the gain.

4. **Approach 3 (Enumerated Witness Chains) is essentially Approach 1 with a different name**: When examined carefully, the "specific enumerated witnesses" ARE the constructive fragment induction. It is not a separate approach but a corollary of Approach 1 with explicit witnesses.

5. **Approach 4 (D = Q directly with justification) is philosophically acceptable and pragmatically superior**: The "D from syntax" goal is ABOUT THE PROPERTIES, not the explicit construction. If the canonical timeline demonstrably has the properties of Q (countable dense linear order without endpoints), then declaring D = Q and pointing to those properties IS the syntactic justification. Mathlib's `Order.iso_of_countable_dense` provides the formal bridge.

6. **The linearity blocker is separate from countability but interacts**: Plan v011 Phase 2 already marks density as [BLOCKED]. Countability requires the same timeline that density requires. If linearity and density are not proven, countability is moot. The blockers must be addressed jointly.

---

## The Countability Blocker: Precise Statement

The canonical timeline is defined as:

```
CanonicalTimeline M₀ = { M : Set Formula | SetMaximalConsistent M ∧
  (M = M₀ ∨ Relation.TransGen BidirectionalR M₀ M) }
```

where `BidirectionalR M M' := CanonicalR M M' ∨ CanonicalR_past M M'`.

**Why it is uncountable**: `CanonicalR M M' := GContent M ⊆ M'`. For any fixed M, there are `2^ℵ₀` MCS extending `GContent M` (binary tree argument: each formula not in GContent M can independently be in or out of M', giving a Cantor-space-many extensions). Therefore `BidirectionalR M` has `2^ℵ₀`-many successors from any M. `Relation.TransGen BidirectionalR M₀` reaches all these successors and their successors. The timeline is uncountable.

**Why Formula countability does not save us**: Formula is countable (as confirmed in `Formula.lean`), but the SET OF ALL SUBSETS of Formula is uncountable. MCS are subsets of Formula (specifically, maximal consistent ones). Lindenbaum's lemma (which uses Classical.choice) selects one MCS per seed, but `CanonicalTimeline` includes ALL MCS bidirectionally reachable, not just the specific Lindenbaum witnesses.

**Formal precision**: The countability of Formula gives us |Formula| = ℵ₀. The set of MCS over Formula has cardinality ≤ 2^ℵ₀ (each MCS is a subset of Formula). The SPECIFIC WITNESSES chosen by canonical_forward_F are countable (one per formula), but CanonicalTimeline includes ALL MCS satisfying the reachability predicate, which is uncountable.

---

## Approach 1: Constructive Countable Fragment

### Mathematical Description

Define a countable fragment by Nat-indexed induction:

```
Layer 0 = { M₀ }
Layer (n+1) = Layer n ∪ { canonicalWitness M φ | M ∈ Layer n, F(φ) ∈ M }
                    ∪ { canonicalWitnessPast M φ | M ∈ Layer n, P(φ) ∈ M }
CountableFragment = ⋃ n, Layer n
```

where `canonicalWitness M φ` is the SPECIFIC MCS returned by `canonical_forward_F M h_mcs φ h_F` (using Lindenbaum on `{φ} ∪ GContent M`).

### Why This Is Countable

- Layer 0 is a singleton (countable).
- If Layer n is countable, then Layer (n+1) is a countable union over Layer n of the image of `(Formula → Set Formula)` over a countable set. Specifically:
  - For each M ∈ Layer n: the set of F-witnesses is `{ canonicalWitness M φ | F(φ) ∈ M }`, which has at most |Formula| = ℵ₀ elements.
  - So Layer (n+1) is a union of countably many sets, each of size ≤ ℵ₀.
  - By `Set.countable_iUnion`: countable union of countable sets is countable.
- CountableFragment is a countable union (over ℕ) of countable sets = countable.
  - Mathlib: `Set.countable_iUnion` with `Countable ℕ`.

### Mathlib Infrastructure

- `Set.countable_iUnion : [Countable ι] → (∀ i, (t i).Countable) → (⋃ i, t i).Countable` ✓
- `Set.Countable.image : s.Countable → (f '' s).Countable` ✓
- `Nat.rec` / well-founded induction for the layer construction ✓
- `Encodable.ofCountable Formula` for the enumeration of formulas ✓

### Key Technical Questions

**Q1: Does CountableFragment have the temporal witness property?**

Yes, by construction. For any M ∈ CountableFragment and any F(φ) ∈ M, the witness `canonicalWitness M φ` is in Layer (n+1) ⊆ CountableFragment where M ∈ Layer n. This is the inductive step.

**Q2: Does CountableFragment satisfy CanonicalR-closure?**

For F-witnesses: yes by construction. For P-witnesses: yes by construction (symmetric). For G-formulas propagating forward: G(φ) ∈ M and CanonicalR M M' (meaning M' is the canonical witness for some F(ψ) ∈ M) implies φ ∈ M'. This follows from `canonical_forward_G` which is already proven sorry-free.

**Q3: Is CountableFragment linearly ordered?**

This requires the same `temp_linearity` argument as the full BidirectionalTimeline. The linear order proof does NOT depend on which MCS are in the timeline — it says: for any two MCSes M, M' that are bidirectionally related, their equivalence classes are linearly ordered. This argument transfers to CountableFragment unchanged.

**Q4: Is CountableFragment dense?**

This is the SAME density question that DenseQuotient.lean has 4 sorries for. The constructive fragment does NOT solve the density problem. Between any M₁ < M₂ in CountableFragment, we need an intermediate MCS that is ALSO in CountableFragment. Countability of the fragment and density of the fragment are INDEPENDENT problems.

**Critical Interaction**: If the density problem remains (4 sorries in DenseQuotient.lean), then even after proving CountableFragment is countable, Cantor's theorem cannot be applied. Countability and density are BOTH required. This approach resolves ONLY the countability half.

### Lean 4 Formalization Sketch

```lean
-- Step 1: Define layers by Nat induction
noncomputable def fragmentLayer (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    Nat → Set (Set Formula)
  | 0     => {M₀}
  | n + 1 => fragmentLayer M₀ h₀ n ∪
    ⋃ M ∈ fragmentLayer M₀ h₀ n, ⋃ φ,
    (if h : SetMaximalConsistent M ∧ Formula.some_future φ ∈ M
     then {(canonical_forward_F M h.1 φ h.2).choose}  -- Lindenbaum witness
     else ∅) ∪
    (if h : SetMaximalConsistent M ∧ Formula.some_past φ ∈ M
     then {(canonical_backward_P M h.1 φ h.2).choose}
     else ∅)

-- Step 2: Define the countable fragment
def CountableFragment (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    Set (Set Formula) :=
  ⋃ n : Nat, fragmentLayer M₀ h₀ n

-- Step 3: Prove countability
theorem countableFragment_countable : (CountableFragment M₀ h₀).Countable :=
  Set.countable_iUnion (fun n => by induction n with ...)
```

### Failure Modes

1. **Classical.choice non-determinism**: `canonical_forward_F` uses `Classical.choice` internally (via `set_lindenbaum`). The `canonicalWitness M φ` construction works because we just take `.choose` from the existence proof — this is valid even noncomputably.

2. **MCS-ness of layer elements**: Each witness produced by `canonical_forward_F` is an MCS (by the theorem's statement). So `∀ M ∈ CountableFragment, SetMaximalConsistent M` holds inductively.

3. **Linear ordering requires BidirectionalReachability**: The `bidirectional_totally_ordered` theorem (proven sorry-free) works on any pair of MCS that are bidirectionally connected. CountableFragment elements are all connected to M₀, so the linear order applies.

### Confidence Assessment

**Mathematical soundness**: HIGH. The construction is standard in modal logic completeness theory (it is essentially Henkin's witness construction applied inductively). The countability argument is textbook.

**Lean 4 formalization complexity**: MEDIUM-HIGH. The inductive definition with Classical.choice (`.choose`) requires care. The `fragmentLayer` definition above uses dependent if-then-else with proof terms, which can be painful. Alternative: define `canonicalWitness` as a separate `noncomputable def` first.

**Resolves ALL blockers**: NO. Resolves countability only. Density (4 sorries) remains separate.

---

## Approach 2: Löwenheim-Skolem

### Mathematical Description

Apply the downward Löwenheim-Skolem theorem to the full canonical model (which has carrier `Set Formula`, relations CanonicalR and CanonicalR_past, valuation from atoms): extract a countable elementary submodel that satisfies the same first-order sentences, including the witnesses for all F/P-formulas.

### Mathlib Infrastructure

Mathlib has:
- `FirstOrder.Language.exists_elementarySubstructure_card_eq` — extracts elementary substructure of given cardinal
- `FirstOrder.Language.exists_elementarilyEquivalent_card_eq` — gives elementarily equivalent model of given cardinality
- `FirstOrder.Language.exists_small_elementarySubstructure` — small elementary substructure

The key theorem pattern needed:
```
∃ S : L.ElementarySubstructure CanonicalModel, Countable S
```

### Fatal Formalization Gap

The Mathlib Löwenheim-Skolem theorems work with `FirstOrder.Language.Structure`. Our canonical model is NOT formalized as a `FirstOrder.Language.Structure` — it is an ad-hoc construction using `Set Formula`, `CanonicalR`, and `SetMaximalConsistent`. Bridging this gap requires:

1. Defining a first-order language L with symbols for CanonicalR, CanonicalR_past, and each propositional atom
2. Constructing a `FirstOrder.Language.Structure` instance on `Set Formula` using CanonicalR as an interpretation
3. Translating TM formulas into L-formulas and proving equivalence
4. Applying the Löwenheim-Skolem theorem to get a countable elementary substructure
5. Translating back to our MCS framework

**Estimated cost**: 300-600 lines of Lean 4 boilerplate, significantly exceeding the direct approach.

### Alternative: Model Theory Route

The "natural" Löwenheim-Skolem route for propositional modal logic is via compactness + construction. The SEMANTIC formulation is: take the full canonical model, find a countable elementary sub-model. But since TM is a PROPOSITIONAL (not first-order predicate) logic, Löwenheim-Skolem in the standard sense does not directly apply. Propositional logic is already complete via the canonical model construction and does not have "large" models in the relevant sense.

The difficulty is that "elementarily equivalent" requires a precise definition of what "first-order sentences" about our timeline are. This adds conceptual layers unnecessary for our goal.

### Confidence Assessment

**Mathematical soundness**: HIGH in principle. The downward Löwenheim-Skolem theorem is proven in Mathlib and is correct.

**Lean 4 formalization complexity**: VERY HIGH. The bridging from our custom logic to Mathlib's first-order framework is the main obstacle. This is at least as hard as the original task.

**Resolves ALL blockers**: Unclear. An elementary submodel preserves truth of first-order sentences, but our density property (from the DN axiom) and linearity property (from temp_linearity) need to be formulated as first-order sentences ABOUT the model. Whether `DenselyOrdered` on the submodel is preserved by elementary substructure inclusion depends on how "dense" is formulated.

**Verdict**: Not recommended. The formalization cost is prohibitive and the approach introduces new complexity without resolving the density blocker.

---

## Approach 3: Enumerated Witness Chains

### Mathematical Description

Instead of including all bidirectionally reachable MCSes, build the fragment using ONLY the specific witnesses produced by `canonical_forward_F` and `canonical_backward_P`. The "enumeration" comes from the formula enumeration: since Formula is countable, each MCS M has at most countably many F-obligations `F(φ) ∈ M`, each generating one specific witness.

### Relationship to Approach 1

**This is identical to Approach 1.** The "enumerated witness chains" ARE the constructive fragment layers. The difference in language conceals the same construction:

- "Enumerated witness" = `canonicalWitness M φ` = the Lindenbaum witness for seed `{φ} ∪ GContent M`
- "Building by induction" = the Layer n / Layer (n+1) construction
- "Finite chains" = each layer is a finite extension of the previous (formally: bounded-size expansion)

The approach names are different but the mathematics is the same. Any analysis of Approach 3 reduces to Approach 1 analysis.

### Additional Subtlety: Witness Chains vs Fragment Closure

One potential distinction: "witness chains" might refer to keeping ONLY the witnesses explicitly produced, without including all CanonicalR-related MCS. This is exactly what CountableFragment does: it adds M' to the fragment only when M' is the SPECIFIC Lindenbaum witness for some F(φ) ∈ M, NOT all MCS M' with CanonicalR M M'.

This distinction matters for the temporal witness property: CountableFragment is closed under F-witnesses BY CONSTRUCTION (each F(φ) ∈ M produces `canonicalWitness M φ ∈ CountableFragment`). But it is NOT closed under all CanonicalR successors.

**Does this matter?** For the truth lemma, we need: if F(φ) ∈ M and M ∈ CountableFragment, then ∃ M' ∈ CountableFragment with CanonicalR M M' and φ ∈ M'. This is TRUE because `canonicalWitness M φ ∈ CountableFragment` and `φ ∈ canonicalWitness M φ` and `CanonicalR M (canonicalWitness M φ)`.

For the linear order, we need: for any M, M' ∈ CountableFragment, either CanonicalR M M' or CanonicalR M' M (or they are in the same equivalence class). This requires the full `bidirectional_totally_ordered` argument applied to CountableFragment. Since CountableFragment ⊆ BidirectionalTimeline and the linear order is defined on all MCS pairs (not just fragment pairs), this transfers.

**Confidence**: Same as Approach 1.

---

## Approach 4: D = Q Directly with Justification

### Mathematical Description

Declare D = Q (the rationals) at the outset, but JUSTIFY this by proving that the canonical timeline has exactly the properties that characterize Q: countable dense linear order without endpoints. The "syntactic emergence" of D is demonstrated by showing that ANY model satisfying the axioms must have a Q-isomorphic timeline, rather than constructing D explicitly from the syntax.

The argument structure:
1. From pure syntax (axioms TM + DN + seriality), prove that the canonical timeline has:
   - Linear order (from temp_linearity)
   - Dense order (from DN density axiom)
   - No endpoints (from seriality F(¬⊥), P(¬⊥))
   - Countable (from the constructive fragment, Approach 1)
2. By `Order.iso_of_countable_dense`, T ≅ Q.
3. THEREFORE, D = Q is the "right" choice — not a postulate but a THEOREM.
4. The task_rel is defined as `task_rel d w u := e(u) - e(w) = d` where e : T ≃o Q.

### Philosophical Justification

The "D from syntax" goal means: the algebraic structure of D should be DICTATED by the temporal axioms, not freely chosen. Under Approach 4:

- If the axioms included a DISCRETENESS axiom (∀w ∃w', w' = succ(w)) instead of DN, the canonical timeline would be Z-isomorphic, and D = Z would emerge.
- Under DN (density), the canonical timeline is Q-isomorphic, so D = Q.
- The AXIOMS determine D; we are not arbitrarily importing Q.

The difference between Approach 4 and "just using D = Int" (the rejected approach) is:
- D = Int directly: Q is never mentioned; no argument that Int is the "right" D; truth of the representation theorem happens to work but the connection to syntax is opaque.
- Approach 4: The axioms PROVE the canonical timeline is Q-isomorphic; D = Q is a THEOREM, not an assumption.

This IS what task 956 originally intended, as stated in research-001 Section 7: "the construction derives D; it does not assume it."

### Mathlib Infrastructure

Confirmed from search results:
- `Order.iso_of_countable_dense : [LinearOrder α] [LinearOrder β] [Countable α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α] [Countable β] [DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β] → Nonempty (OrderIso α β)` ✓
- `Rat.linearOrder : LinearOrder ℚ` ✓
- `Rat.instDenselyOrdered` (implicitly from `LinearOrderedField`) ✓
- `Rat.noMinOrder`, `Rat.noMaxOrder` (from `LinearOrderedField`, unbounded) ✓
- `Rat.instCountable` (rationals are countable) ✓

Instantiating with α = CountableFragment, β = ℚ gives the isomorphism IF CountableFragment satisfies all four properties.

### Required Conditions

For Approach 4 to work (applying Cantor), we need:

| Property | Status | Path |
|----------|--------|------|
| LinearOrder on timeline | DONE (BidirectionalReachable.lean, sorry-free) | Existing infrastructure |
| Countable timeline | NOT DONE | Approach 1 (constructive fragment) |
| DenselyOrdered timeline | PARTIAL (4 sorries in DenseQuotient.lean) | Unresolved |
| NoMinOrder | DONE-ish (CanonicalTimeline.lean proves mcs_has_canonical_successor) | Needs extension to fragment |
| NoMaxOrder | DONE-ish (symmetric) | Needs extension to fragment |
| Nonempty | DONE (M₀ is in the fragment) | Trivial |

**Critical observation**: Approach 4 requires ALL four conditions. The density blocker (4 sorries) blocks Approach 4 just as it blocks the naive approach. However, Approach 4 has a cleaner separation: once we have the constructive countable fragment AND resolve the density sorries, Approach 4 gives D = Q in one line (`Order.iso_of_countable_dense`).

### Confidence Assessment

**Mathematical soundness**: HIGH. If the four conditions are met, Cantor's theorem is a one-line application.

**"D from syntax" preservation**: HIGH. The argument that D = Q FOLLOWS FROM the axioms (because the axioms force the timeline to be Q-isomorphic) directly satisfies the original task motivation.

**Dependency on density**: HIGH (the fatal dependency). Approach 4 does not resolve the density blocker; it presupposes it.

**Formalization once conditions are met**: LOW effort (~10 lines). The heavy lifting is in proving the four conditions, not in applying Cantor.

---

## Comparative Analysis

### Approaches vs Blockers Matrix

| Approach | Resolves Countability | Resolves Density | Resolves Linearity | Mathlib Cost | "D from syntax" |
|----------|----------------------|-----------------|-------------------|-------------|----------------|
| 1: Constructive Fragment | YES | NO | NO (transfers) | MEDIUM | YES |
| 2: Löwenheim-Skolem | YES | Unclear | Unclear | VERY HIGH | YES (indirectly) |
| 3: Enumerated Witnesses | YES (= Approach 1) | NO | NO (transfers) | MEDIUM | YES |
| 4: D = Q with justification | Requires 1 | Requires density fix | NO (transfers) | LOW | YES (strongest) |

### The Real Blocker Priority

The task context identifies TWO blockers:
- **Countability Blocker**: The timeline as defined is uncountable.
- **Linearity Blocker**: DenselyOrdered has 4 sorries (not "linearity" per se, but density of the quotient).

From the analysis:
1. Countability is resolvable via Approach 1/3 (constructive fragment). This is medium-complexity but straightforward.
2. Density (the 4 sorries in DenseQuotient.lean) is the deeper blocker. Research-023 confirms this is the "SINGLE HARD STEP in the pipeline." The Lindenbaum collapse problem (constructing intermediate MCS that don't collapse to either endpoint) has resisted 28 research reports.

**Countability is the EASIER blocker.** Resolving it does not resolve density. Density must be tackled separately.

### Recommended Path

**Phase 1: Resolve countability via Approach 1/3 (constructive fragment)**

Define `CountableFragment` by induction. The formalization is medium-complexity but mathematically sound. This gives `Countable CountableFragment`.

**Phase 2: Prove the four Cantor conditions on CountableFragment**

- Linear order: transfers from existing BidirectionalReachable.lean proof.
- No endpoints: transfers from CanonicalTimeline.lean (`mcs_has_canonical_predecessor/successor`).
- Countable: proved in Phase 1.
- Dense: requires fixing the 4 sorries in DenseQuotient.lean.

**Phase 3: Apply Cantor's theorem (Approach 4)**

Once Phase 2 is complete, `Order.iso_of_countable_dense` gives T ≅ Q in one line. This is Approach 4.

**Phase 4: Define task_rel and build TaskFrame**

`task_rel d w u := e u - e w = d` where `e : CountableFragment ≃o ℚ`.

### On the Density Blocker (Separate Research Needed)

The 4 sorries in DenseQuotient.lean (Case B subcases and Case A subcase) involve the Lindenbaum collapse problem. Research-023 Section 6 gives the best analysis. Possible resolution paths not yet exhausted:

1. **Enriched seed with separator**: Add a formula that is in b but not in a to the Goldblatt seed. If the Lindenbaum extension c contains this formula, c ≠ a. Requires careful analysis of which formulas can separate a and b in the canonical timeline.

2. **Work at preorder level before quotienting**: The density proof may be easier if we prove the PREORDER (not quotient) is dense: given M₁ <_pre M₂ (meaning M₁ <_CanonicalR M₂ strictly), find intermediate M with M₁ <_CanonicalR M and M <_CanonicalR M₂. This is the Goldblatt seed approach and the 4 sorries are precisely here.

3. **Use a different characterization of density**: Instead of the quotient definition, use the "no gaps" characterization: ∀ M₁ <_CanonicalR M₂, ∃ M with CanonicalR M₁ M and CanonicalR M M₂. This is equivalent but the proof may be more tractable by working with the raw preorder.

This density analysis belongs to a separate research thread (see task context note about linearity blocker). The current report focuses on countability.

---

## Summary and Recommended Path

### Recommended Approach: 1/3 for Countability, then 4 for D = Q

The strongest overall recommendation is:

1. **Implement Approach 1** (Constructive Countable Fragment) to resolve the countability blocker. This is mathematically sound, uses existing Mathlib infrastructure (`Set.countable_iUnion`, `Set.Countable.image`), and stays entirely within the existing codebase framework.

2. **Use Approach 4 framing** (D = Q with syntactic justification) as the philosophical narrative. The countable constructive fragment, combined with proofs of density and no-endpoints, enables Cantor's theorem, giving D = Q as a THEOREM, not a postulate.

3. **Do not pursue Approach 2** (Löwenheim-Skolem). The formalization overhead is prohibitive and does not resolve the density blocker.

4. **Recognize Approach 3 as a restatement of Approach 1**: No additional work is needed for Approach 3 beyond what Approach 1 delivers.

### Confidence Levels

| Claim | Confidence |
|-------|------------|
| Countability via Approach 1 is mathematically sound | HIGH |
| Approach 1 is formalizable in ~100-150 lines of Lean 4 | MEDIUM |
| Approach 2 is disproportionately expensive | HIGH |
| Approach 4 preserves "D from syntax" philosophy | HIGH |
| Density (4 sorries) is the deeper remaining blocker | HIGH |
| Density blocker is resolvable without major new ideas | LOW-MEDIUM |

---

## Appendix: Mathlib Infrastructure Verified

| Mathlib Declaration | Module | Status |
|--------------------|--------|--------|
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | VERIFIED (leansearch) |
| `Set.countable_iUnion` | `Mathlib.Data.Set.Countable` | VERIFIED (leansearch + loogle) |
| `Set.Countable.image` | `Mathlib.Data.Set.Countable` | VERIFIED (leansearch) |
| `Set.Countable.union` | `Mathlib.Data.Set.Countable` | VERIFIED (leansearch) |
| `Rat.linearOrder` | `Mathlib.Algebra.Order.Ring.Unbundled.Rat` | VERIFIED (leansearch) |
| `FirstOrder.Language.exists_elementarySubstructure_card_eq` | `Mathlib.ModelTheory.Skolem` | VERIFIED (leansearch) |
| `Encodable.ofCountable Formula` | (from `Countable Formula` instance in `Formula.lean`) | VERIFIED (local) |

## Appendix: Files Consulted

| File | Lines | Key Finding |
|------|-------|-------------|
| `Theories/Bimodal/Syntax/Formula.lean` | 1-98 | `Formula` derives `Countable`; atoms are `String` |
| `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` | All | `CanonicalTimeline` definition; NoMaxOrder/NoMinOrder proven |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | 1-167 | `canonical_forward_F`, `canonical_backward_P` proven sorry-free |
| `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` | 1855-1881 | 2 sorries in F/P witness construction for Int chain |
| `specs/956_.../reports/research-018.md` | All | Uncountability argument: 2^ℵ₀ MCS per seed |
| `specs/956_.../reports/research-023.md` | All | Complete pipeline analysis; density as single hard step |
| `specs/956_.../plans/implementation-011.md` | All | Current plan v011; Phase 2 marked [BLOCKED] |
