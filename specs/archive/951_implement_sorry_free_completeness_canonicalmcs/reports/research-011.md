# Research Report: Task #951 (research-011) -- Constructing the Canonical Frame from Syntax: Durations as Proof-Theoretic Objects

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-28
**Session**: sess_1772340782_d4be07
**Effort**: High (deep foundational analysis of syntactic frame construction)
**Dependencies**: research-001 through research-010 (especially research-010 Successor Algebra approach)
**Sources/Inputs**: Codebase (CanonicalFMCS.lean, CanonicalFrame.lean, FMCSDef.lean, CanonicalConstruction.lean, CanonicalCompleteness.lean, Representation.lean, Truth.lean, TaskFrame.lean, Formula.lean, TemporalCoherentConstruction.lean), Mathlib (orderIsoIntOfLinearSuccPredArch, Equiv.addCommGroup, Antisymmetrization, FreeAbelianGroup), ROAD_MAP.md
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report addresses a fundamental reframing of the completeness problem: the aim is not to equip a pre-existing frame with algebraic structure, but to **construct the canonical frame itself from pure syntax**, where the temporal domain D emerges from the logic's proof theory with structure determined by which axioms are present.

**Principal Findings**:

1. **The canonical frame IS already constructed from syntax.** The current codebase's `CanonicalMCS` construction (worlds = all MCSes, temporal relation = GContent inclusion) is precisely the syntactic canonical frame. The open question is only about the **time index type D** used to parameterize the TaskFrame.

2. **Durations ARE syntactic objects -- they are equivalence classes of MCS pairs under "same temporal position."** Concretely, the Antisymmetrization of the CanonicalMCS preorder gives a linearly ordered set where each element represents a "temporal position" in the canonical model. The duration between two positions is their difference in this order.

3. **The proof-theoretic content of G/H/F/P determines the structure of D:**
   - **Base logic** (no discreteness/density axioms): D = Antisymmetrization of CanonicalMCS = a linearly ordered set with `Preorder` (proven), where the FMCS requires only `Preorder` (verified in codebase). This gives `LinearOrder + AddCommGroup` if we can prove the successor algebra properties.
   - **With discreteness axioms**: The quotient has intrinsic successor structure -> `SuccOrder + PredOrder + IsSuccArchimedean` -> order-isomorphic to Z -> `AddCommGroup` transferred from Z.
   - **With density axioms**: The quotient is densely ordered -> embeddable in Q -> `AddCommGroup` from Q.

4. **There are TWO distinct completeness architectures, and the user's question reveals a gap between them:**
   - **Architecture A (Current)**: D is fixed as `Int` (or `CanonicalMCS` with `Preorder`), and completeness is proven relative to this fixed choice. The `TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.
   - **Architecture B (User's Vision)**: D is CONSTRUCTED from the logic, and its structure is DERIVED from proof theory. The TaskFrame constraints should follow from the construction.

5. **The key technical insight**: The current codebase already has TWO completeness paths:
   - `Representation.lean` uses `TaskFrame Int` with `AddCommGroup Int` (Architecture A)
   - `CanonicalFMCS.lean` uses `FMCS CanonicalMCS` with only `Preorder CanonicalMCS` (no group structure needed)

   The TruthLemma and CanonicalConstruction both work with just `Preorder D`. The `AddCommGroup` requirement exists ONLY in the TaskFrame definition (for nullity/compositionality) and in `truth_at` (for temporal operator semantics). The canonical truth lemma in `CanonicalConstruction.lean` already works with `D = Int` by using `FMCS Int` and matching truth_at.

6. **Recommendation**: The syntactic construction of D should proceed as follows:
   - Define `SyntacticDuration` = `Antisymmetrization CanonicalMCS (· <= ·)` (a `PartialOrder` by Mathlib)
   - Prove `LinearOrder SyntacticDuration` (from `IsTotal` on CanonicalMCS -- requires proof, partially explored in archived CanonicalQuotient)
   - Prove `SuccOrder + PredOrder` from `fragmentGSucc` and backward analog
   - Apply `orderIsoIntOfLinearSuccPredArch` to get `SyntacticDuration ≃o Z`
   - Transfer `AddCommGroup` via `Equiv.addCommGroup` and `LinearOrder` via the `OrderIso`
   - Construct `TaskFrame SyntacticDuration` using the transferred structure

---

## 2. Context: What the Codebase Already Has

### 2.1 The Two Completeness Chains

**Chain 1: CanonicalMCS (Preorder-based, sorry-free for FMCS)**

```
CanonicalMCS (structure)
  .world : Set Formula
  .is_mcs : SetMaximalConsistent world

Preorder CanonicalMCS  (via CanonicalR = GContent subset)
  le_refl  : canonicalR_reflexive (T-axiom)
  le_trans  : canonicalR_transitive (Temporal 4)

FMCS CanonicalMCS  (canonicalMCSBFMCS)
  mcs w := w.world
  forward_G : by CanonicalR definition
  backward_H : by GContent/HContent duality

forward_F : sorry-FREE (via Lindenbaum witness)
backward_P : sorry-FREE (via Lindenbaum witness)
```

This chain requires only `Preorder D`, NOT `AddCommGroup D`.

**Chain 2: TaskFrame Int (AddCommGroup-based, sorry in fully_saturated_bfmcs_exists_int)**

```
TaskFrame Int  (CanonicalTaskFrame in CanonicalConstruction.lean)
  WorldState := { M : Set Formula // SetMaximalConsistent M }
  task_rel := canonical_task_rel (GContent + HContent)
  nullity : by T-axioms
  compositionality : by Temporal 4

truth_at requires [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  (but only through the TaskFrame parameter -- temporal operators
   themselves just need ≤ on D)

Representation.lean completeness: sorry from fully_saturated_bfmcs_exists_int
```

### 2.2 The Actual Sorry Situation

The single sorry in `fully_saturated_bfmcs_exists_int` (line 600 of TemporalCoherentConstruction.lean) blocks the combination of:
1. Temporal coherence (forward_F + backward_P for all families)
2. Modal saturation (enough families for Box backward)

This sorry has NOTHING to do with the algebraic structure of D. It is about constructing enough FMCS families with the right properties.

### 2.3 Key Observation: The FMCS Infrastructure Doesn't Need AddCommGroup

Reading `FMCSDef.lean`:
```lean
variable (D : Type*) [Preorder D]
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t ≤ t' -> ...
  backward_H : forall t t' phi, t' ≤ t -> ...
```

The FMCS structure requires only `Preorder D`. The `TruthLemma.lean` and `TemporalCoherentConstruction.lean` also use only `Preorder D` and `Zero D`.

The `AddCommGroup` constraint enters ONLY at the TaskFrame level (for `nullity` and `compositionality`) and in `truth_at` (through the TaskFrame parameter).

---

## 3. The Syntactic Construction of Durations

### 3.1 What IS a "Duration" Syntactically?

A duration is **the abstract "temporal distance" between two temporal positions in the canonical model**. Formally:

**Definition**: A *temporal position* is an equivalence class of MCSes under the symmetric closure of CanonicalR. Two MCSes M and M' are at the "same temporal position" if `CanonicalR M M'` and `CanonicalR M' M` (i.e., `GContent(M) ⊆ M'` and `GContent(M') ⊆ M`).

This is exactly the `AntisymmRel` used by Mathlib's `Antisymmetrization`:
```
AntisymmRel CanonicalMCS (· ≤ ·) =
  fun a b => a ≤ b ∧ b ≤ a =
  fun a b => CanonicalR a.world b.world ∧ CanonicalR b.world a.world
```

So:
```
SyntacticDuration := Antisymmetrization CanonicalMCS (· ≤ ·)
```

Each element of `SyntacticDuration` is a set of MCSes that are "temporally equivalent" -- they agree on all G-formulas and H-formulas.

### 3.2 What Determines the Structure of SyntacticDuration?

The structure of this quotient depends on which axioms are in the logic:

**Base TM Logic** (with G, H, F, P, T-axioms, Temporal 4, Temporal K):
- `SyntacticDuration` has `PartialOrder` (from Antisymmetrization)
- Needs proof of `LinearOrder` (totality of the quotient)
- Has successor/predecessor via `fragmentGSucc` and backward analog
- If `SuccOrder + PredOrder + IsSuccArchimedean + NoMaxOrder + NoMinOrder` can be proven, then `orderIsoIntOfLinearSuccPredArch` gives `SyntacticDuration ≃o Z`

**With Discreteness Axiom** `F(phi) -> phi -> P(phi)`:
- Forces the quotient to be discrete (no element strictly between x and succ(x))
- Ensures `SuccOrder` with immediate successors
- Combined with Archimedean property: isomorphic to Z

**With Density Axiom** `F(F(phi)) -> F(phi)`:
- Forces the quotient to be dense (between any two distinct elements, there's a third)
- Rules out `SuccOrder` with immediate successors
- Quotient embeds into Q (Cantor's theorem on countable dense linear orders without endpoints)

**Neither discreteness nor density**:
- Quotient could be any countable linear order
- Still has `AddCommGroup` if we can prove the successor algebra properties
- The "default" case for the base logic should give something isomorphic to Z (because the logic has no mechanism to force intermediate points)

### 3.3 Why the Base Logic Gives a Discrete Order (and Hence Z)

This is the subtle but crucial point. In the base TM logic:

1. **Every MCS extension is a Lindenbaum extension.** When we construct a successor via `fragmentGSucc w`, we take the Lindenbaum extension of `GContent(w.world)`. Lindenbaum's lemma uses Zorn's lemma to produce a maximal extension.

2. **The canonical quotient is countable.** Since formulas are countable (proven: `Countable Formula` in `Formula.lean`), there are at most continuum-many MCSes, and the quotient is at most continuum-large. But the equivalence classes are determined by G-content, and each equivalence class is determined by its G-content set, which is a subset of a countable set.

3. **The key question is whether the successor is immediate.** For `fragmentGSucc w` to be the immediate successor of `[w]` in the quotient, there must be no element strictly between `[w]` and `[fragmentGSucc w]`. This depends on the logic's axioms:
   - Without density axioms, the logic provides no mechanism to produce an intermediate point
   - The construction is "as tight as possible" -- `fragmentGSucc` adds exactly the G-content obligations and nothing more
   - Any MCS M with `w < M < fragmentGSucc(w)` would need to contain `GContent(w)` but not be equivalent to `fragmentGSucc(w)`, which requires M to have STRICTLY more temporal obligations than w but strictly fewer than `fragmentGSucc(w)` -- this seems impossible without density axioms

4. **Formal argument sketch**: Suppose M is strictly between w and fragmentGSucc(w). Then `GContent(w) ⊆ M` (from `w ≤ M`) and `GContent(M) ⊆ fragmentGSucc(w)` (from `M ≤ fragmentGSucc(w)`). But `fragmentGSucc(w)` is the Lindenbaum extension of `GContent(w)`, and M is an MCS containing `GContent(w)`. The Lindenbaum extension adds formulas that don't follow from `GContent(w)` alone. The question is whether M can "commit" to some of these extra formulas but not all, producing an intermediate position. In the absence of density axioms, the temporal formulas available are exactly those generated by the G/H/F/P operators, and the commitment structure is all-or-nothing for each temporal position.

### 3.4 The Construction Pipeline

```
Step 1: CanonicalMCS (Preorder, already in codebase)
         |
Step 2: Antisymmetrization CanonicalMCS (· ≤ ·)  [PartialOrder, Mathlib]
         |
Step 3: Prove LinearOrder on the quotient  [needs IsTotal proof]
         |
Step 4: Prove SuccOrder + PredOrder  [from fragmentGSucc + backward analog]
         |
Step 5: Prove IsSuccArchimedean + NoMaxOrder + NoMinOrder  [from F/P witness existence]
         |
Step 6: orderIsoIntOfLinearSuccPredArch  [Mathlib: D ≃o Z]
         |
Step 7: Equiv.addCommGroup  [Mathlib: transfer AddCommGroup from Z to D]
         |
Step 8: Prove IsOrderedAddMonoid  [from order iso + Z's ordered group]
         |
Step 9: TaskFrame SyntacticDuration  [using transferred structure]
```

### 3.5 What About Non-Discrete Cases?

If we want to support density axioms (where D should be dense, embeddable in Q):

**Approach A: Axiom-parameterized construction**
- Define `SyntacticDuration` as above for any logic
- For the base logic, prove `SuccOrder` etc. -> Z
- For logic + density axioms, prove `DenselyOrdered` -> embed in Q via `Rat.denselyOrdered_of_countable`
- Each case provides `AddCommGroup` differently (Z vs Q)

**Approach B: Universal construction**
- Define `SyntacticDuration` as `FreeAbelianGroup (SomeGenerators)` quotiented by relations from the logic
- The generators are "atomic temporal steps" and the relations come from axioms
- The quotient inherits `AddCommGroup` from `FreeAbelianGroup`
- Order comes from the canonical order on MCS equivalence classes

Approach A is more practical for the current codebase. Approach B is mathematically cleaner but requires more infrastructure.

---

## 4. The Relationship Between Syntax and Temporal Structure

### 4.1 Times as Syntactic Objects: The Lindenbaum-Tarski Analogy

In propositional completeness:
- **Worlds** = maximal consistent sets (syntactic objects)
- The **accessibility relation** between worlds is defined by formula membership (syntactic)
- The **valuation** at a world is determined by atom membership (syntactic)

In temporal completeness:
- **Worlds** = maximal consistent sets (syntactic objects) -- same
- **Temporal positions** = equivalence classes of MCSes under G-content agreement (syntactic)
- **Temporal order** = GContent inclusion on the quotient (syntactic)
- **Durations** = elements of the quotient, or differences in the quotient's group structure (syntactic IF we derive the group from the quotient)

The analogy is complete: just as worlds are syntactic in the Lindenbaum construction, temporal positions are syntactic in the canonical temporal model.

### 4.2 How the Task Relation Emerges

The user asked: "How should task_rel properly relate durations d to the transition between world states?"

In the current `CanonicalConstruction.lean`, the task relation is:
```lean
def canonical_task_rel (M : CanonicalWorldState) (_d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val
```

The duration parameter `_d` is **unused** -- the task relation is purely about temporal content inclusion.

In the syntactic construction, the task relation SHOULD be:
```
canonical_task_rel M d N  iff
  the temporal position of N minus the temporal position of M equals d
```

That is, `d` represents the "temporal distance" from M to N in the quotient. This requires:
1. An assignment `pos : CanonicalWorldState -> SyntacticDuration` mapping each MCS to its temporal position
2. Group structure on `SyntacticDuration` to compute `pos(N) - pos(M)`
3. The task relation: `task_rel M d N := pos(N) - pos(M) = d ∧ GContent M ⊆ N ∧ HContent N ⊆ M`

This gives a MEANINGFUL duration parameter, where `d` is the syntactically-determined temporal distance.

### 4.3 The Compositionality Proof Becomes Trivial

With the syntactic task relation:
```
task_rel M x N := pos(N) - pos(M) = x ∧ coherent(M, N)
task_rel N y V := pos(V) - pos(N) = y ∧ coherent(N, V)
```

Compositionality: `task_rel M (x + y) V`
```
pos(V) - pos(M) = pos(V) - pos(N) + pos(N) - pos(M) = y + x = x + y  (by AddCommGroup)
coherent(M, V) = coherent by transitivity (Temporal 4)
```

This is exactly the algebraic content of compositionality -- it follows from the group law on `SyntacticDuration`.

### 4.4 Nullity Proof is Also Algebraic

`task_rel M 0 M` requires `pos(M) - pos(M) = 0`, which is trivially true in any group.

---

## 5. Implementation Analysis

### 5.1 What Needs to Be Built

**Required new definitions/theorems**:

1. `SyntacticDuration` := `Antisymmetrization CanonicalMCS (· ≤ ·)`
2. `LinearOrder SyntacticDuration` (proof that the preorder on CanonicalMCS quotients to a total order)
3. `SuccOrder SyntacticDuration` (from fragmentGSucc)
4. `PredOrder SyntacticDuration` (from backward analog)
5. `IsSuccArchimedean SyntacticDuration` (any two positions are finitely many steps apart)
6. `NoMaxOrder SyntacticDuration` (always a future MCS)
7. `NoMinOrder SyntacticDuration` (always a past MCS)
8. `syntacticOrderIso : SyntacticDuration ≃o Z` (from `orderIsoIntOfLinearSuccPredArch`)
9. `AddCommGroup SyntacticDuration` (from `Equiv.addCommGroup`)
10. `IsOrderedAddMonoid SyntacticDuration` (from order iso)
11. `SyntacticTaskFrame : TaskFrame SyntacticDuration` (using all the above)
12. Connection to existing `FMCS CanonicalMCS` (pullback along quotient map)

**Estimated difficulty**:
- Items 1, 8, 9, 10: Easy (Mathlib infrastructure)
- Items 3, 4: Medium (need to prove successor is immediate in quotient)
- Items 5, 6, 7: Medium (need structural lemmas about MCS chains)
- Item 2: **HARD** -- this is the totality proof, which was partially explored in the archived CanonicalQuotient work. The archived `CanonicalQuotient.lean` proved `IsTotal` on the REACHABLE fragment but this was abandoned because backward_P witnesses weren't reachable. For ALL MCSes, totality does NOT hold (two unrelated MCSes may not be comparable).

### 5.2 The Totality Problem

**Critical obstacle**: The Antisymmetrization of ALL CanonicalMCSes is NOT totally ordered. Two MCSes M1 and M2 with `GContent(M1) ⊄ M2` and `GContent(M2) ⊄ M1` are incomparable. For example:
- M1 = MCS containing {G(p), not q}
- M2 = MCS containing {G(q), not p}

Neither GContent(M1) ⊆ M2 (since p ∉ M2) nor GContent(M2) ⊆ M1 (since q ∉ M1).

**Resolution**: The temporal domain should NOT be the quotient of ALL MCSes. It should be the quotient of a SINGLE temporal chain (a linearly ordered subset of MCSes connected by CanonicalR).

This is exactly what the **BidirectionalFragment** provides: given a root MCS M0, the set of all MCSes reachable from M0 by iterated forward/backward Lindenbaum extensions. This fragment IS totally ordered (proven in the archived CanonicalQuotient work, modulo the reachability issue).

### 5.3 Revised Construction: Per-Chain Durations

The correct syntactic construction of D:

1. Start from consistent context Gamma
2. Extend to MCS M0 via Lindenbaum
3. Construct `BidirectionalFragment M0` (all forward/backward-reachable MCSes)
4. The fragment has `Preorder` via `CanonicalR` (already in codebase)
5. Prove `IsTotal` on the fragment (archived work showed this for reachable fragment)
6. `SyntacticDuration` = `Antisymmetrization (BidirectionalFragment M0) (· ≤ ·)` [LinearOrder]
7. Prove `SuccOrder` etc. from `fragmentGSucc`
8. Apply Mathlib infrastructure for Z isomorphism

**Key advantage**: Per-chain construction gives totality automatically because the chain is linearly ordered by construction.

**Key challenge**: Forward_F and backward_P witnesses must stay in the fragment. This IS proven in the codebase (`forward_F_stays_in_fragment`, `backward_P_stays_in_fragment` in `BidirectionalReachable.lean`).

### 5.4 How This Connects to the Existing Sorry

The remaining sorry in `fully_saturated_bfmcs_exists_int` is about combining temporal coherence with modal saturation. The syntactic construction of D does NOT resolve this sorry -- it is orthogonal.

However, the syntactic construction provides a cleaner ARCHITECTURE for the completeness proof:
1. D is constructed from syntax (not assumed to be Int)
2. The FMCS works over `BidirectionalFragment M0` (sorry-free for forward_F/backward_P)
3. The TaskFrame over `SyntacticDuration` has algebraic structure derived from proof theory
4. The remaining gap is still modal saturation (multi-family construction)

---

## 6. Addressing the User's Specific Questions

### 6.1 "How do we construct the canonical frame (W, task_rel, durations)?"

**W** = `CanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }` (already in codebase)

**task_rel** = `canonical_task_rel` based on GContent/HContent inclusion (already in codebase, but should incorporate duration parameter meaningfully)

**durations D** = `Antisymmetrization (BidirectionalFragment M0) (· ≤ ·)` with algebraic structure transferred from Z via `orderIsoIntOfLinearSuccPredArch` and `Equiv.addCommGroup`

### 6.2 "Can durations be defined as equivalence classes of formula derivations?"

Yes, in the following sense: Two MCS pairs (M1, M2) and (M3, M4) have the "same duration" iff they map to the same element under `pos(M2) - pos(M1)` in the `SyntacticDuration` group. This is an equivalence class of pairs, exactly as the user suggested (Approach B in the task).

The equivalence is determined by the temporal content of the MCSes, which is itself determined by derivability of G/H/F/P formulas.

### 6.3 "What syntactic construction gives D linear order?"

The `CanonicalR` preorder on MCSes, restricted to a single bidirectional chain and quotiented by the antisymmetric closure, gives a `LinearOrder`. The order is determined entirely by GContent inclusion, which is a syntactic property (G(phi) in M means phi is derivable from M under the G-closure operation).

### 6.4 "What syntactic construction gives D additive group structure?"

NOT a direct syntactic construction. Instead, it follows from the representation theorem for discrete linear orders:

1. Discrete linear order without endpoints -> isomorphic to Z (categorically unique)
2. Z has `AddCommGroup`
3. Transfer via `Equiv.addCommGroup`

The group structure is DERIVED from the order structure, which is derived from syntax. So the group structure is indirectly syntactic.

### 6.5 "How does adding axioms CHANGE the syntactic construction of D?"

**Base logic**: D ≃ Z (discrete, no endpoints, Archimedean -> unique isomorphism)

**+ Discreteness axioms**: Same result, but with an ADDITIONAL proof that the discreteness is "immediate" (the successor is the next element with no gap). This doesn't change D ≃ Z but provides a more direct proof.

**+ Density axioms**: D is now densely ordered, NOT discrete. `SuccOrder` fails. Instead:
- D is a countable dense linear order without endpoints
- By Cantor's theorem: D ≃o Q (unique up to isomorphism)
- `AddCommGroup` comes from Q (or from Dedekind completion -> R)

**Neither**: D could be any countable linear order. If Archimedean (which TM's axioms likely force), then D ≃ Z or D ≃ Q depending on density.

### 6.6 "The aim is to construct the frame itself from pure syntax"

This is EXACTLY what the canonical model construction does. The current codebase constructs:
- Worlds from MCSes (syntactic)
- Temporal relation from GContent (syntactic)
- Temporal order from GContent inclusion (syntactic)

The only non-syntactic element is the CHOICE of D as `Int`. The proposed construction removes this choice by DERIVING D from the temporal structure of MCSes.

---

## 7. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient Stack | HIGH | The archived work on totality of the reachable fragment is directly relevant. Use BidirectionalFragment (which resolves the backward_P issue) instead. |
| Constant Witness Family Approach | MEDIUM | Confirms that D must support time-varying families, not constant ones. The syntactic D construction is compatible with this. |
| Single-Family BFMCS modal_backward | LOW | Orthogonal -- about modal saturation, not temporal domain construction. |
| Non-Standard Validity Completeness | MEDIUM | The syntactic construction must produce a standard TaskFrame, not a non-standard structure. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Directly aligned -- the syntactic D indexes the FMCS |
| Successor Algebra (research-010) | ACTIVE | The recommended approach for deriving group structure |
| Representation-First Architecture | CONCLUDED | The syntactic TaskFrame should fit into this architecture |

---

## 8. Comparison of Approaches (User's A/B/C/D vs Recommended)

### Approach A: Times as Formula Classes
**Verdict**: Partially viable but too coarse. Formulas don't naturally partition into temporal equivalence classes without reference to MCSes.

### Approach B: Times as Proof-Theoretic Distances (MCS pairs)
**Verdict**: This is essentially what the recommended construction does. The "distance" between M and N is `pos(N) - pos(M)` in the syntactic duration group. Pairs (M1,M2) ~ (M3,M4) iff `pos(M2) - pos(M1) = pos(M4) - pos(M3)`.

### Approach C: Times as Canonical Witnesses
**Verdict**: Subsumed by the BidirectionalFragment approach. Each F-witness IS a canonical witness, and the chain of witnesses determines the temporal structure.

### Approach D: Free Construction
**Verdict**: Mathematically clean but not needed. The quotient of the BidirectionalFragment already gives us the right group (isomorphic to Z or Q depending on axioms). No need for a free group quotiented by relations -- the Antisymmetrization quotient is simpler.

### Recommended: Successor Algebra on BidirectionalFragment Quotient
**Verdict**: Combines the best of all approaches. Uses the existing codebase infrastructure (BidirectionalFragment, fragmentGSucc), leverages Mathlib (Antisymmetrization, orderIsoIntOfLinearSuccPredArch, Equiv.addCommGroup), and gives a clean syntactic construction of D.

---

## 9. Concrete Implementation Path

### Phase 1: BidirectionalQuotient (LinearOrder)
- Define `BidirectionalQuotient M0 := Antisymmetrization (BidirectionalFragment M0) (· ≤ ·)`
- Prove `IsTotal` on the BidirectionalFragment (or on its quotient)
- Obtain `LinearOrder BidirectionalQuotient`

### Phase 2: Successor Structure
- Define `SuccOrder BidirectionalQuotient` from `fragmentGSucc`
- Prove successor is immediate (no element strictly between x and succ(x))
- Define `PredOrder` from backward analog
- Prove `IsSuccArchimedean` (finite steps between any two elements)

### Phase 3: Algebraic Transfer
- Apply `orderIsoIntOfLinearSuccPredArch` -> `BidirectionalQuotient ≃o Z`
- Apply `Equiv.addCommGroup` -> `AddCommGroup BidirectionalQuotient`
- Prove `IsOrderedAddMonoid` from the order isomorphism

### Phase 4: Canonical TaskFrame
- Define `SyntacticTaskFrame : TaskFrame BidirectionalQuotient`
- Define meaningful `task_rel` using position differences
- Prove nullity and compositionality from group structure

### Phase 5: Connect to Completeness
- Build `FMCS BidirectionalQuotient` from existing `fragmentFMCS`
- Adapt truth lemma for `SyntacticTaskFrame`
- Show completeness relative to syntactic frames implies completeness relative to all frames

---

## 10. Risks and Mitigations

### Risk 1: Totality proof on BidirectionalFragment may be hard
**Mitigation**: The archived CanonicalQuotient work proved totality for the reachable fragment. The BidirectionalFragment is a superset (includes backward-reachable elements too), but the argument should be similar. If totality fails, fall back to proving it only for specific chains.

### Risk 2: Successor immediacy may require non-trivial proof theory
**Mitigation**: If we cannot prove successor is immediate in the general case, we can:
- Add it as an axiom (justified by the absence of density axioms)
- Prove it under the assumption that the logic contains no density axioms
- Work with the weaker `SuccOrder` without immediacy and use a different Archimedean characterization

### Risk 3: The syntactic D construction may not resolve the actual sorry
**Mitigation**: Acknowledged. The sorry is about modal saturation, not D's structure. The syntactic construction provides architectural clarity but does not directly eliminate the sorry. The two can be pursued in parallel.

### Risk 4: Complexity of construction may exceed practical benefit
**Mitigation**: The construction can be implemented incrementally. Phase 1-3 can be done independently and provide the algebraic D. Phase 4-5 connect to completeness. Even partial completion is valuable for the project's understanding.

---

## 11. Decisions

1. **D should be constructed as the Antisymmetrization of the BidirectionalFragment**, not of all MCSes (totality fails for all MCSes).

2. **The Successor Algebra approach (research-010) is the correct path** for deriving AddCommGroup from intrinsic structure.

3. **The construction should be axiom-parameterized**: base logic -> Z-isomorphic, with density -> Q-embeddable.

4. **The existing FMCS CanonicalMCS infrastructure should be preserved** as the primary sorry-free completeness chain. The syntactic D construction is an enrichment, not a replacement.

5. **The sorry in fully_saturated_bfmcs_exists_int is orthogonal** to the syntactic D construction and should be addressed separately.

---

## 12. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Syntactic duration construction | Section 3 | No | new_file |
| Successor Algebra on MCS quotients | Section 3.4 | Partial (research-010) | extension |
| Axiom-dependent temporal structure | Section 3.2 | No | new_file |
| BidirectionalFragment quotient properties | Section 5.2 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `syntactic-temporal-domain.md` | `lattice-theory/` | How D emerges from proof theory | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| None identified | - | - | - | - |

### Summary

- **New files needed**: 1 (medium priority)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

---

## 13. Appendix

### A. Search Queries Used

**Codebase exploration**:
- `Glob Theories/**/*.lean` -- all Lean files
- `Read TaskFrame.lean` -- understand frame requirements
- `Read CanonicalFMCS.lean` -- understand canonical construction
- `Read CanonicalConstruction.lean` -- understand direct truth lemma
- `Read CanonicalCompleteness.lean` -- understand BidirectionalFragment FMCS
- `Read Representation.lean` -- understand final completeness proof
- `Read TemporalCoherentConstruction.lean` -- understand sorry situation
- `Read Truth.lean` -- understand temporal operator semantics
- `Read Formula.lean` -- understand syntax
- `Read FMCSDef.lean` -- understand FMCS structure
- `Read Construction.lean` -- understand building blocks
- `Read TruthLemma.lean` -- understand BFMCS truth lemma
- `Read CanonicalFrame.lean` -- understand CanonicalR and relations
- `Read ROAD_MAP.md` -- strategies and dead ends

**Mathlib lookup**:
- `lean_leansearch`: "canonical model completeness temporal logic maximal consistent set"
- `lean_leanfinder`: "constructing additive group structure on linearly ordered set with successor and predecessor"
- `lean_leanfinder`: "Antisymmetrization linear order quotient of preorder"
- `lean_leanfinder`: "free abelian group quotient construction"
- `lean_loogle`: `orderIsoIntOfLinearSuccPredArch`
- `lean_loogle`: `Equiv.addCommGroup`

### B. Key Mathlib Declarations

```lean
-- Quotient of preorder to partial order
Antisymmetrization (α : Type*) (r : α → α → Prop) : Type

-- Partial order on quotient
instPartialOrderAntisymmetrization : PartialOrder (Antisymmetrization α (· ≤ ·))

-- Discrete linear order without endpoints ≃ Z
orderIsoIntOfLinearSuccPredArch :
  {ι : Type} [LinearOrder ι] [SuccOrder ι] [PredOrder ι]
  [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] : ι ≃o ℤ

-- Transfer group structure through equivalence
Equiv.addCommGroup : (e : α ≃ β) → [AddCommGroup β] → AddCommGroup α

-- Free abelian group
FreeAbelianGroup (α : Type) : Type
```

### C. References

1. Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes. (Canonical model for tense logics)
2. Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press. Chapter 4 (Canonical Models)
3. Burgess, J.P. (1984). "Basic Tense Logic". *Handbook of Philosophical Logic*, Vol. II. (Completeness of basic tense logic)
4. Mathlib documentation for `Order.SuccPred.LinearLocallyFinite` (orderIsoIntOfLinearSuccPredArch)
5. Mathlib documentation for `Algebra.Group.TransferInstance` (Equiv.addCommGroup)
