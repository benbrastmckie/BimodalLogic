# Research Report: Task #951 (research-009) -- Time-Shift Groups, Torsor Constructions, and Frame-First Completeness

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-28
**Session**: sess_1740700800_m951
**Effort**: High (deep mathematical analysis of algebraic bridging approaches)
**Dependencies**: research-001 through research-008, phases A-D completed, phase E blocked
**Sources/Inputs**: Validity.lean, Truth.lean, TaskFrame.lean, WorldHistory.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean, CanonicalChain.lean, CanonicalFrame.lean, FMCSDef.lean, BFMCS.lean, TemporalCoherentConstruction.lean, Mathlib AddTorsor/Grothendieck group/OrderIso infrastructure
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report addresses the user's five key questions about constructing `AddCommGroup` structure from the canonical frame's `LinearOrder`, with emphasis on the "time-shift group" interpretation, torsor constructions, and a frame-first design philosophy.

**Principal findings**:

1. **Time-shift groups from LinearOrder**: Yes, there is a natural and well-studied construction. Given a linearly ordered set P acted upon freely and transitively by a group G, the group G is the "group of time-shifts." But the direction of construction matters: you cannot *derive* an AddCommGroup from a bare LinearOrder -- you must either (a) embed the linear order into a pre-existing group, or (b) construct the group of formal differences (Grothendieck construction) from the order's monoidal structure. For the BidirectionalQuotient, option (a) via embedding into Int is the viable path.

2. **Action interpretation**: The view of times as actions (0 = identity, x = shift by x) is precisely the *torsor* perspective from Mathlib's `AddTorsor`. The MCS configurations form a torsor for the time-shift group: given any two configurations M, M', there is a unique "duration" separating them. However, constructing the torsor structure requires the group to exist first -- torsors do not generate groups, they presuppose them.

3. **Frame-first approach**: The user's intuition is correct that the frame should determine the time domain, not vice versa. The current architecture already follows this: the BidirectionalFragment (from the canonical frame) determines the temporal structure, and the remaining step is purely algebraic -- embedding this structure into a type that satisfies `AddCommGroup`. The frame is defined; what remains is choosing D.

4. **Canonical world histories**: The standard semantics does determine world histories given a frame. The FMCS structure IS the canonical history (mapping times to MCSes). The gap is not in history construction but in the algebraic signature of the time type.

5. **Best alternative to BidirectionalQuotient**: Embedding the BidirectionalFragment into Int (via the enriched chain construction in CanonicalChain.lean) is the most direct path. The Grothendieck group and torsor constructions are mathematically elegant but introduce unnecessary complexity for this specific problem.

**Recommendation**: Fix the enriched canonical chain's `forward_F`/`backward_P` proofs (the omega-squared diagonal fix). This is the narrowest path to sorry-free completeness. The time-shift / torsor perspective is conceptually illuminating but does not change the implementation strategy.

---

## 2. Question 1: Time-Shift Groups from LinearOrder

### 2.1 The Mathematical Question

Given a type `D` with `LinearOrder D`, can we construct an `AddCommGroup D` where the group operations represent "time-shifts"?

### 2.2 Answer: Not in General, But With Additional Structure

A bare linear order has no canonical additive group structure. Consider:

- The set `{0, 1, 2}` with the usual order is a linear order but admits no additive group structure (any group on 3 elements is cyclic, which conflicts with the linear ordering being translation-invariant).
- The rationals Q with the usual order have AddCommGroup, but the reals R restricted to the irrationals do not (no additive closure).
- The Cantor set with its natural order is a linear order with no group structure.

**What IS true**: If a linear order admits a *free transitive action* by an additive group G, then G is uniquely determined (up to isomorphism) and is called the "group of time-shifts" or the "difference group." This is the torsor perspective.

### 2.3 The Difference/Grothendieck Construction

Given a linearly ordered commutative monoid (M, +, <=), the **Grothendieck group** K(M) is the universal abelian group containing M. Formally:

```
K(M) = (M x M) / ~ where (a, b) ~ (c, d) iff a + d = b + c
```

The equivalence class of (a, b) represents the formal difference "a - b". This is how the integers are constructed from the natural numbers.

**In Mathlib**: `Algebra.GrothendieckGroup M` (at `Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup`) implements this. For a cancellative commutative monoid, the inclusion `M -> K(M)` is injective.

**For BidirectionalQuotient**: The problem is that the BidirectionalQuotient does NOT have a commutative monoid structure to begin with. Its elements are equivalence classes of MCSes under mutual CanonicalR-reachability. There is no natural "addition" operation on MCS equivalence classes:
- What would `[M] + [M']` mean? Union is not an MCS. Intersection is not an MCS.
- The GContent inclusion ordering is not compatible with any natural addition.

Therefore, the Grothendieck construction does not apply directly.

### 2.4 What DOES Work: Embedding into a Group

The viable approach is to *embed* the linearly ordered BidirectionalQuotient into a pre-existing linearly ordered additive commutative group. The embedding preserves the order, and the target group provides the algebraic structure.

**Candidate targets**:

| Target | Has AddCommGroup | Has LinearOrder | Embedding Existence |
|--------|-----------------|-----------------|---------------------|
| Int (Z) | Yes | Yes | Only if source is discrete (has successor/predecessor, Archimedean) |
| Rat (Q) | Yes | Yes | Any countable linear order without max/min embeds (Cantor's theorem) |
| Real (R) | Yes | Yes | Any countable linear order embeds |

**For Int**: Mathlib's `orderIsoIntOfLinearSuccPredArch` provides an *order isomorphism* (not just embedding) between `ι` and `Z` whenever `ι` has `LinearOrder`, `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`, and `Nonempty`. The enriched canonical chain in CanonicalChain.lean constructs exactly such a structure.

**For Rat**: Mathlib provides `Order.embedding_from_countable_to_dense` (or similar) for embedding countable linear orders into dense orders. This was analyzed in research-005 and found viable but more complex than the Int path for this discrete temporal logic.

---

## 3. Question 2: Action Interpretation and Torsor Structure

### 3.1 Times as Actions on MCS Configurations

The user's intuition is: interpret times not as abstract elements but as *actions* on MCS configurations, where:
- 0 = "do nothing" (identity action)
- x = "shift by duration x"

This is precisely the mathematical concept of a **torsor** (or principal homogeneous space).

### 3.2 What is a Torsor?

An `AddTorsor G P` (Mathlib: `Mathlib.Algebra.AddTorsor.Defs`) consists of:
- An additive group G (the "group of shifts")
- A type P (the "space of points" / "space of MCS configurations")
- An action `(+v) : G -> P -> P` (shifting a point by a group element)
- A subtraction `(-v) : P -> P -> G` (computing the "distance" between points)
- Axioms: `(g +v p) -v p = g` and `(p -v q) +v q = p`

Key property: **The action is free and transitive.** For any two points p, q in P, there exists a *unique* g in G with `g +v p = q`. This g is `q -v p`.

### 3.3 Does the BidirectionalFragment Form a Torsor?

For the BidirectionalFragment to be a torsor for some group G, we would need:
1. A group G with `AddCommGroup G`
2. An action `G -> BidirectionalFragment -> BidirectionalFragment`
3. Free and transitive action

**The problem**: The BidirectionalFragment has only `LinearOrder` (via quotient). For it to be a torsor, G would need to exist *first*, and the action would need to be defined. But defining the action requires knowing how to "shift" an MCS by a group element, which circularly requires the group.

**The resolution**: The torsor perspective is conceptually correct but operationally backwards for our situation. We don't start with the group and derive the torsor -- we start with the ordered set (BidirectionalQuotient) and need to *find* a group that acts on it. This is equivalent to embedding the ordered set into a group.

### 3.4 Self-Torsor Structure

Every additive group G is trivially an `AddTorsor G G` (Mathlib: `addGroupIsAddTorsor`). Once we embed the BidirectionalQuotient into Int (via the enriched chain), Int becomes both the time domain AND the group of time-shifts. The action is just addition: `n +v m = n + m`.

This is exactly what the current architecture does: `FMCS Int` uses `Int` as both the time index and the group providing `AddCommGroup`.

### 3.5 Can We Define AddCommGroup on Actions Without the Embedding?

The user asks: even when the underlying MCS space has only LinearOrder, can we define AddCommGroup operations on the *space of time-shifts*?

**Answer**: If we define time-shifts as formal expressions `shift(M, M')` for pairs of MCS configurations, and quotient by the natural equivalence, we get the Grothendieck-like construction:

```
TimeShift = (Fragment x Fragment) / ~ where (M1, M2) ~ (M3, M4) iff "M1 - M2 = M3 - M4"
```

But defining what "M1 - M2 = M3 - M4" means requires a notion of "distance" between MCSes, which in turn requires the AddCommGroup structure we are trying to build. The circularity is fundamental.

**The only escape**: Ground the construction in a concrete group (Int, Rat, Real) via embedding.

---

## 4. Question 3: Frame-First Approach

### 4.1 The User's Vision

Define a frame (W, R_F, R_P, Task) such that:
- The time domain D comes from frame structure, not external integers
- D has AddCommGroup structure (for time_shift in valid)
- Task relation respects D via actual time differences

### 4.2 Current Architecture Already Follows This (Partially)

The existing code constructs the frame structure first:

1. **W** = `BidirectionalFragment M0 h_mcs0` (MCSes reachable from root)
2. **R_F** = `CanonicalR` (GContent inclusion, proven sorry-free)
3. **R_P** = `CanonicalR_past` (HContent inclusion, proven sorry-free)
4. **Task** = derived from CanonicalR (nullity via reflexivity, compositionality via transitivity)

The frame is fully determined by the syntax (axiom set + formula structure). The time domain D is the `BidirectionalQuotient` with `LinearOrder`.

### 4.3 Where the Frame-First Approach Breaks

The gap is at step "D has AddCommGroup." The frame determines a linear order on times, but the AddCommGroup structure must come from outside the frame -- it is a property of the *semantic interpretation* (the `valid` definition), not the frame itself.

**Why `valid` requires AddCommGroup**: The definition of `valid` (Validity.lean:71-75) universally quantifies:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...
```

This means: a formula is valid if it is true in ALL models with time type D satisfying AddCommGroup. To prove completeness (not valid implies not provable), we must construct a SPECIFIC D with AddCommGroup and a model where the formula fails. The BidirectionalQuotient provides the model but not the AddCommGroup.

### 4.4 The Correct Frame-First Design

The frame-first approach works as follows:

1. **Build the canonical frame** from the unprovable formula phi (Phases A-D, done sorry-free)
2. **Extract the linear order** from the frame (BidirectionalQuotient, done)
3. **Embed the linear order into a known group** (Int via enriched chain, partially done)
4. **Pull back the frame structure** along the embedding to get a TaskFrame over Int
5. **Construct world histories** (FMCS Int -> WorldHistory via existing infrastructure)
6. **Verify truth at root** (Truth Lemma, done sorry-free)

Steps 1-2 and 5-6 are complete. Step 3 is the Phase E blocker. Step 4 is straightforward once step 3 is done.

### 4.5 Why the Frame Does Not Directly Determine D

The fundamental issue is that the `valid` definition requires completeness relative to ALL choices of D, not just the one the frame suggests. Soundness was proven for all D simultaneously (the universal quantifier in `valid`). Completeness must find ONE specific D that refutes the formula. The frame suggests a linear order; we must embed it into a D with AddCommGroup.

This is not a deficiency -- it is the structure of the problem. The paper (JPL, app:TaskSemantics) defines frames with `D = <D, +, <=>`  as a totally ordered abelian group. The frame does not generate D; D is given and the frame is built over it.

---

## 5. Question 4: Canonical World Histories

### 5.1 How Histories Emerge from the Frame

Given a frame (W, task_rel), the standard semantics defines world histories as:

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop
  convex : ...
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t, domain s -> domain t ->
    s <= t -> F.task_rel (states s) (t - s) (states t)
```

For the canonical model, the FMCS IS the canonical history:

```
canonical_history(t) = fam.mcs(t)  -- the MCS at time t
```

The `forward_G` and `backward_H` conditions on FMCS are exactly the `respects_task` condition specialized to the canonical frame where `task_rel w d w' := CanonicalR w.world w'.world`.

### 5.2 MCS Membership Determines Truth

The Truth Lemma (TruthLemma.lean, sorry-free) establishes:

```
phi in fam.mcs(t) iff truth_at M Omega tau t phi
```

So MCS membership at each time IS truth at that time. The canonical history's truth values are determined by the MCS assignment, exactly as the user envisions.

### 5.3 The ShiftClosed Omega Bypass

The user might worry about the `ShiftClosed Omega` condition in `valid`. The BFMCS approach (Representation.lean) bypasses this by constructing completeness relative to a specific Omega (the set of all BFMCS families), which is shown to be shift-closed by construction. This is already proven in the existing architecture.

---

## 6. Question 5: Alternatives to BidirectionalQuotient

### 6.1 Requirements Recap

We need D with:
- `AddCommGroup D` (for time_shift, subtraction in respects_task)
- `LinearOrder D` (for temporal ordering)
- `IsOrderedAddMonoid D` (compatibility)
- An order-preserving map from BidirectionalFragment into D (to transfer the MCS assignment)

### 6.2 Option Analysis

#### Option A: Free Abelian Group on Generators

**Idea**: Take generators from the BidirectionalFragment and form `FreeAbelianGroup (BidirectionalFragment ...)`.

**Problem**: FreeAbelianGroup has AddCommGroup but no LinearOrder. The ordering on BidirectionalFragment does not extend to a compatible linear order on the free abelian group. (Linear orders on free abelian groups exist but are not unique and do not generally respect the fragment ordering.)

**Verdict**: Possible in theory but requires nontrivial work to define and verify the correct order. Not available in Mathlib out-of-the-box.

#### Option B: Difference Structure (Grothendieck Group)

**Idea**: Form pairs (M, M') of fragment elements representing "time M minus time M'", quotient by the natural equivalence.

**Problem**: As analyzed in Section 2.3, there is no natural commutative monoid structure on the BidirectionalFragment to feed into the Grothendieck construction. The ordering is a preorder (now made into a linear order via antisymmetrization), but ordering alone does not provide a monoid.

**Verdict**: Not directly applicable. The Grothendieck construction requires a monoid, which we do not have.

#### Option C: Torsor Construction

**Idea**: View the fragment as a torsor for some group G and extract G.

**Problem**: Torsor construction requires G to exist first. We would need to construct G independently, which brings us back to the embedding problem.

**Verdict**: Conceptually correct but operationally circular. Does not help.

#### Option D: Embedding into Int (Enriched Chain)

**Idea**: Build an order-preserving embedding `BidirectionalFragment -> Int` by constructing a Z-indexed chain that visits all fragment elements.

**Status**: CanonicalChain.lean implements the chain construction. The chain is monotone (`CanonicalChain.monotone`), converts to FMCS Int (`CanonicalChain.toFMCS`), and the enriched version places F/P witnesses at decoded positions.

**What remains**: Proving forward_F and backward_P for the enriched chain FMCS. The omega-squared diagonal fix (decode obligations as (position, formula) pairs) is technically clear but not yet implemented.

**Verdict**: Most direct path. Requires 4-6 hours of proof engineering, not mathematical innovation. All prerequisites are in place.

#### Option E: Embedding into Rat

**Idea**: Use Mathlib's `Order.embedding_from_countable_to_dense` to embed the countable BidirectionalQuotient into Rat.

**Status**: Analyzed in research-005. Mathematically viable but more complex than the Int path because:
- Requires proving countability of BidirectionalQuotient
- Rat embedding is non-constructive (uses choice extensively)
- Dense embeddings are harder to control than discrete ones
- The enriched chain for Int is already mostly built

**Verdict**: Valid backup if Int path fails, but Int path is preferred.

#### Option F: Using Int Directly (Bypass Fragment)

**Idea**: Skip the BidirectionalFragment entirely and build FMCS Int directly via the enriched canonical chain, using canonical_forward_F and canonical_backward_P at each step.

**Status**: This is what the enriched chain in CanonicalChain.lean already does. The chain maps `Int -> CanonicalMCS`, and the FMCS coherence (forward_G, backward_H) follows from chain monotonicity.

**Verdict**: This IS Option D, just phrased differently. The BidirectionalFragment is used conceptually (to understand why the construction works) but the chain directly produces FMCS Int.

### 6.3 Comparison Table

| Option | AddCommGroup | LinearOrder | Embedding Ease | Mathlib Support | Effort |
|--------|-------------|-------------|----------------|-----------------|--------|
| A: FreeAbelianGroup | Yes | Hard | Hard | Partial | High |
| B: Grothendieck | Yes | N/A | N/A | Yes but inapplicable | N/A |
| C: Torsor | Circular | Circular | Circular | Yes but circular | N/A |
| **D: Embed into Int** | **Yes (Int)** | **Yes (Int)** | **Moderate** | **Yes** | **Low-Med** |
| E: Embed into Rat | Yes (Rat) | Yes (Rat) | Complex | Yes | Medium |
| F: Direct Int chain | Yes (Int) | Yes (Int) | Same as D | Yes | Low-Med |

---

## 7. Deep Dive: The Time-Shift Group Perspective

### 7.1 Mathematical Framework

In the standard mathematical treatment of temporal logic completeness (Goldblatt 1992, Ch. 4), the time domain is given as part of the frame definition. The canonical model for tense logics over `(Z, <)` uses Z as the time domain from the start.

The user's question inverts this: can we *derive* the group from the frame? In abstract terms:

**Given**: A set P (MCS configurations) with a total preorder <= (CanonicalR)
**Want**: An abelian group G and an identification P ≅ G (or P embeds into G) such that <= on P corresponds to <= on G

**Answer**: This is the **orderability problem for groups**. A group G is orderable if it admits a total order compatible with the group operation. Not every total order on a set comes from an ordered group structure, but:

- **Z** is the unique (up to isomorphism) countable linearly ordered group with no max or min and discrete (Archimedean successor/predecessor) structure.
- **Q** is the unique (up to isomorphism) countable densely linearly ordered group with no max or min.

So the question reduces to: is BidirectionalQuotient order-isomorphic to Z or Q (or embeddable into one)?

### 7.2 Why Z is the Right Target

The BidirectionalFragment, when enriched with the dovetailing chain construction, produces a *discrete* linear order (each element has an immediate successor and predecessor). This is because:

- Each chain step adds exactly one new MCS (the Lindenbaum extension of a seed)
- The chain is indexed by Int, providing successor/predecessor structure
- The enriched chain visits all F/P obligations (by dovetailing), ensuring completeness

The resulting structure is order-isomorphic to Z. No density axioms are present in TM logic's axiom set, so the temporal order is inherently discrete at the proof-theoretic level.

### 7.3 The "Space of All Possible Time-Shifts"

The user asks about generating "the space of all possible time-shifts for any linear order of MCSs." This space is precisely Int, acting on the chain by translation:

```
shift_n(chain(k)) = chain(k + n)
```

Properties:
- shift_0 = identity (0 = "do nothing")
- shift_n compose shift_m = shift_(n+m) (group operation)
- shift_n preserves order (n >= 0 means forward in time)

This is the regular representation of (Z, +) acting on itself. The FMCS Int structure encodes exactly this: `fam.mcs(t)` gives the MCS at position t, and shifting by n corresponds to looking at position t + n.

### 7.4 When Times Are Defined, World Histories Follow

The user correctly notes: "once the times and tasks complete the frame, then the world-histories are already determined." This is precisely the relationship between FMCS and WorldHistory:

- **FMCS Int** defines the time-indexed MCS assignment (the canonical history)
- **WorldHistory F** is the semantic packaging of the same data (with domain, convexity, task respect)
- The conversion from FMCS to WorldHistory is mechanical (full domain = Set.univ, convexity trivial, task respect from FMCS coherence)

The existing code already implements this conversion path. The blocker is not in the history construction but in obtaining sorry-free FMCS Int with forward_F and backward_P.

---

## 8. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient Stack | HIGH | This dead end documents that future-only reachability fails because backward_P witnesses may not be future-reachable. Our recommendation (enriched chain) uses BIDIRECTIONAL reachability, avoiding this pitfall. |
| Constant Witness Family Approach | MEDIUM | Confirms that temporal saturation requires time-varying families. The enriched chain creates time-varying MCS assignments. |
| Single-Family BFMCS modal_backward | LOW | Not directly relevant to the algebraic structure question, but confirms multi-family modal saturation is needed. |
| Non-Standard Validity Completeness | HIGH | Confirms that completeness must use the STANDARD `valid` definition. Any approach that changes `valid` falls into this dead end. Our recommendation preserves `valid` unchanged. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Our recommendation (enriched chain -> FMCS Int) is a direct instantiation of this strategy. |
| Representation-First Architecture | CONCLUDED | The completeness proof derives from the representation theorem via BFMCS. Our approach maintains this architecture. |

---

## 9. Detailed Recommendations

### Recommendation 1 (Primary): Fix Enriched Chain forward_F/backward_P

**Problem**: CanonicalChain.lean's enriched construction places F-witnesses and P-witnesses at chain positions, but the `forward_F` proof for the resulting FMCS Int is incomplete. The chain checks `F(phi) in chain(n)` only at step n, but `F(phi)` may enter the chain at position t != n.

**Fix (omega-squared diagonal)**:
1. Use `decodePosFormula` to decode step n as a pair `(pos, phi)`
2. At step n, check `F(phi) in chain(pos)` for the decoded position `pos <= n`
3. If satisfied, place phi at position n+1 (which is > pos, satisfying the witness requirement)
4. Surjectivity of `decodePosFormula` (already proven: `decodePosFormula_encodePosFormula`) ensures every (pos, phi) pair is eventually decoded

**Key lemmas available**:
- `decodePosFormula_encodePosFormula` (CanonicalChain.lean) -- surjectivity of decoding
- `enrichedForwardStep_ordered` -- chain ordering preservation
- `enrichedForwardStep_witness_placed` -- witness formula in successor
- `enriched_seed_consistent_from_F` (CanonicalCompleteness.lean) -- seed consistency

**Estimated effort**: 4-6 hours.
**Risk**: Low. All mathematical foundations are in place.

### Recommendation 2 (Secondary): Do NOT Pursue Torsor/Grothendieck Constructions

While mathematically elegant, the torsor and Grothendieck group approaches add complexity without benefit for this specific problem:
- The torsor approach is circular (requires the group to exist first)
- The Grothendieck construction requires a monoid, which BidirectionalQuotient lacks
- The free abelian group approach requires nontrivial order construction
- All of these would need significant new Lean infrastructure

The enriched chain into Int is simpler, better supported by existing code, and leverages Mathlib's Int infrastructure directly.

### Recommendation 3: Preserve the `valid` Definition Unchanged

The analysis confirms:
- `valid` correctly requires `AddCommGroup D` for MF/TF soundness
- The time_shift construction (WorldHistory.time_shift) uses `z + Delta` (AddCommGroup)
- The respects_task condition uses `t - s` (AddCommGroup)
- ShiftClosed requires `time_shift sigma Delta` (AddCommGroup)

Changing `valid` to remove AddCommGroup would break soundness of MF and TF axioms, as documented in Dead End "Non-Standard Validity Completeness."

### Recommendation 4: After Sorry-Free FMCS Int, Address Modal Saturation

Once Recommendation 1 provides sorry-free FMCS Int, the remaining sorry (`fully_saturated_bfmcs_exists_int` in TemporalCoherentConstruction.lean:600) requires combining:
- Sorry-free FMCS Int (temporal coherence)
- Diamond witness families (modal saturation via `diamondWitnessMCS` in CanonicalCompleteness.lean)

This is independent of the algebraic structure questions and requires separate investigation.

---

## 10. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| AddTorsor and temporal semantics | Section 3 | No | new_file |
| Grothendieck group construction | Section 2.3 | No | extension |
| Frame-first vs group-first design | Section 4 | No | extension |
| Omega-squared diagonal decoding | Section 9.1 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `torsors-and-time-domains.md` | `math/algebra/` | AddTorsor concept, relationship to temporal semantics, why torsor approach is circular for generating groups from orders | Low | No |

**Rationale**: The torsor concept is educational context that helps understand WHY the BidirectionalQuotient cannot directly serve as D, but it does not change the implementation path. Low priority because the main insight (embed into Int) is already well-established.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `lattices.md` | N/A | N/A | N/A | No |

### Summary

- **New files needed**: 0-1 (low priority)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

---

## 11. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Enriched chain forward_F proof harder than estimated | Low | Medium | All prerequisites proven; the gap is proof engineering, not mathematical |
| Modal saturation more complex than anticipated | Medium | High | Diamond witness infrastructure already implemented in CanonicalCompleteness.lean |
| Performance of omega-squared encoding in Lean | Low | Low | Int arithmetic is well-supported; encoding/decoding are simple Nat pair functions |

---

## 12. Appendix

### A. Mathlib Tools Used

- `lean_leansearch`: "torsor additive group acting on linear order" (found AddTorsor, OrderIso infrastructure)
- `lean_loogle`: `AddTorsor` (found Mathlib.Algebra.AddTorsor.Defs definition and instances)
- `lean_leanfinder`: "torsor structure on linearly ordered set" (found AddTorsor, vaddConst equivalence)
- `lean_leansearch`: "free abelian group on generators embedding into integers" (found FreeAbelianGroup, punitEquiv ≅ Int)
- `lean_loogle`: `orderIsoIntOfLinearSuccPredArch` (found Mathlib.Order.SuccPred.LinearLocallyFinite)
- `lean_leanfinder`: "Grothendieck group of commutative monoid" (found FreeAbelianGroup definition)
- `lean_local_search`: `GrothendieckGroup` (found Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup)
- `lean_local_search`: `IsSuccArchimedean` (found Mathlib.Order.SuccPred.Archimedean)

### B. Web Research

- Grothendieck group construction (Wikipedia): formal differences (M x M) / ~ for commutative monoids
- Torsor / principal homogeneous space (nLab, Wikipedia): group acting freely and transitively on a set
- Linearly ordered groups (Wikipedia): groups with translation-invariant total order
- Mathlib AddTorsor documentation: +v, -v, free transitive action, equivalence with group

### C. Codebase Files Examined

- `Validity.lean` -- `valid` definition requiring AddCommGroup D
- `Truth.lean` -- truth_at evaluation, time_shift_preserves_truth
- `TaskFrame.lean` -- TaskFrame structure, nullity, compositionality
- `WorldHistory.lean` -- WorldHistory structure, time_shift, convexity, respects_task
- `BidirectionalReachable.lean` -- BidirectionalFragment, LinearOrder quotient, totality
- `CanonicalCompleteness.lean` -- fragmentFMCS, enriched seed consistency, diamond witnesses
- `CanonicalFrame.lean` -- CanonicalR, reflexivity, transitivity
- `CanonicalChain.lean` -- Z-indexed chain, monotonicity, toFMCS conversion
- `FMCSDef.lean` -- FMCS structure, forward_G, backward_H
- `Completeness.lean` -- MCS modal/temporal properties
- `TemporalCoherentConstruction.lean` -- temporal backward properties, sorry locations

### D. Previous Research Cross-References

- research-004: FPClosure into Int (failed due to non-discrete fragment)
- research-005: Rat embedding (viable backup, more complex than Int)
- research-006: Bundle automorphism analysis (established no natural AddCommGroup on quotient)
- research-007: Change valid vs discreteness axiom comparison (recommended discreteness / Int embedding)
- research-008: Syntactic reconstruction synthesis (confirmed enriched chain as primary path)
