# Research Report: Task #951 (research-006) -- Intrinsic Group Structure from Bundle Automorphisms

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-28
**Session**: sess_1772311409_0734df
**Effort**: High (deep architectural analysis of additive structure emergence from automorphisms)
**Dependencies**: research-004, research-005, phases A-D completed, phase E blocked
**Sources/Inputs**: Truth.lean, WorldHistory.lean, Validity.lean, TaskFrame.lean, BFMCS.lean, FMCSDef.lean, TemporalCoherentConstruction.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean, Representation.lean
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report analyzes the user's fundamental insight that **additive structure on times should emerge from time-shift constraints on the bundle of families**, rather than being assumed via `AddCommGroup D`. The proposal is category-theoretic: the group structure arises from the **automorphisms of the bundle** (time-shift symmetries), not from pre-existing ordered groups.

**Main findings**:

1. The current codebase uses `AddCommGroup D` in TWO fundamentally different roles: (a) as the algebraic structure for time-shifts in semantic definitions (`time_shift`, `ShiftClosed`, `time_shift_preserves_truth`), and (b) as the type parameter in `valid`/`satisfiable` (which must be instantiated at the canonical model). These two roles have different solutions.

2. The **fragment automorphism** idea has mathematical merit: the BidirectionalFragment has an automorphism group under the CanonicalR preorder. However, this automorphism group does NOT naturally form an AddCommGroup -- it is at most a group under composition, but crucially **it lacks a compatible total order** (automorphisms do not have a natural linear order).

3. The **bundle time-shift approach** (mapping one family to another via time-shift) corresponds to what the codebase already does via `shiftClosedCanonicalOmega`: given a canonical history for family `fam`, the time-shift by `delta : Int` produces a new history indexed at shifted times. This IS an automorphism of the history space, and the set of all such shifts DOES form an additive group (isomorphic to `Int` or `Rat`, depending on the chosen D).

4. The key insight "don't assume Int or Rat -- let structure emerge" is **in tension with** the current semantic architecture, which requires `AddCommGroup D` in the `valid` definition (Validity.lean:72). The `valid` definition universally quantifies over all such D, so the completeness proof must produce a MODEL with a CONCRETE D having AddCommGroup structure. There is no way around this without changing `valid`.

5. The most viable path that honors the "emergent structure" philosophy while working within the current architecture is **Path B from research-005 (embed FPClosure into Rat)**, combined with a semantic rethinking where `satisfiable_abs` replaces `satisfiable Int` as the canonical completeness statement.

6. An alternative radical approach -- **Path D: define a new `valid_intrinsic`** that does not require AddCommGroup -- is mathematically interesting but would require reproving soundness for MF/TF axioms, a major undertaking.

---

## 2. Current Time-Shift Infrastructure Analysis

### 2.1 Where AddCommGroup Is Used

The `AddCommGroup D` constraint appears in the following locations, organized by role:

**Role A: Semantic Time-Shift Operations**

| Location | Usage | Specific Operations |
|----------|-------|-------------------|
| `WorldHistory.time_shift` (WorldHistory.lean:236) | Construct shifted history | `z + Delta`, group addition |
| `ShiftClosed` (Truth.lean:231) | Omega closure under shifts | Uses `time_shift sigma Delta` |
| `time_shift_preserves_truth` (Truth.lean:344) | Truth invariance under shift | `y - x`, `x + (y-x) = y`, `neg_add_cancel` |
| `truth_double_shift_cancel` (Truth.lean:275) | Double shift cancellation | `z + (-Delta) + Delta = z` |
| `TaskFrame.nullity` (TaskFrame.lean:95) | Zero-duration identity | `0 : D` |
| `TaskFrame.compositionality` (TaskFrame.lean:103) | Task composition | `x + y` |

**Role B: Universal Quantification in Validity**

| Location | Usage |
|----------|-------|
| `valid` (Validity.lean:72) | `forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` |
| `semantic_consequence` (Validity.lean:95) | Same universal quantification |
| `satisfiable` (Validity.lean:119) | Requires D with same instances |
| `satisfiable_abs` (Validity.lean:127) | Existential: `exists D [AddCommGroup D] ...` |

### 2.2 How `time_shift` Currently Works on BFMCS

In `Representation.lean:114-119`, the canonical history for family `fam` is defined:

```lean
def canonicalHistory (B : BFMCS Int) (fam : FMCS Int) (_hfam : fam in B.families) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True
  states := fun t _ => mkCanonicalWorldState B fam t  -- fam.mcs t
  respects_task := fun _ _ _ _ _ => trivial
```

The time-shift of this history by `delta : Int` produces:

```lean
time_shift (canonicalHistory B fam hfam) delta
-- domain: fun z => True (unchanged, since t + delta always satisfies True)
-- states: fun z _ => mkCanonicalWorldState B fam (z + delta)  -- fam.mcs (z + delta)
```

So **shifting a canonical history by delta just reindexes the family**: instead of looking up `fam.mcs t` at time `t`, we look up `fam.mcs (t + delta)`.

The `shiftClosedCanonicalOmega` (Representation.lean:156-158) is defined as all such shifts:

```lean
def shiftClosedCanonicalOmega (B : BFMCS Int) :=
  { sigma | exists fam hfam delta, sigma = time_shift (canonicalHistory B fam hfam) delta }
```

This is exactly the **orbit of `canonicalOmega` under the time-shift action of Int**. The set of shifts `{ delta : Int }` forms the additive group Int acting on histories.

### 2.3 What `ShiftClosed` Means for BFMCS

The `ShiftClosed` property (Truth.lean:231) requires:

```lean
forall sigma in Omega, forall Delta : D, time_shift sigma Delta in Omega
```

For `shiftClosedCanonicalOmega`, this holds because shifting `time_shift (canonicalHistory fam) delta` by `delta'` gives `time_shift (canonicalHistory fam) (delta + delta')`, which is still in the set (Representation.lean:181-187).

Key observation: **ShiftClosed is precisely the statement that Omega is closed under the group action of (D, +) on histories**. This is the bundle automorphism structure the user describes.

---

## 3. Fragment Automorphisms Analysis

### 3.1 What Are Fragment Automorphisms?

An **automorphism of the BidirectionalFragment** would be an order-preserving bijection:

```
alpha : BidirectionalFragment M0 h_mcs0 -> BidirectionalFragment M0 h_mcs0
```

such that `a <= b iff alpha(a) <= alpha(b)`.

Since the CanonicalR preorder on the fragment is total (by `bidirectional_totally_ordered`, BidirectionalReachable.lean:728), this is an order-automorphism of a total preorder.

### 3.2 Does the Fragment Have Non-Trivial Automorphisms?

The fragment is built from CanonicalR edges starting at root M0. An automorphism must:
1. Preserve the CanonicalR preorder
2. Map MCSes to MCSes with the same formula structure (to preserve membership)

In general, the fragment does NOT have non-trivial automorphisms:
- Each element is a specific MCS with specific formula content
- Different positions in the total order have different formula content (the whole point of the construction)
- An order-automorphism that preserves formula content must be the identity

**This means the automorphism group of the fragment is typically trivial** (just the identity). The "rich automorphism structure" that the user envisions does not naturally arise at the fragment level.

### 3.3 Why Time-Shifts Are Not Fragment Automorphisms

The time-shift operation `time_shift sigma Delta` acts on **histories** (functions from D to WorldState), not on **the time domain itself**. It translates the indexing of a history, not the structure of the MCSes.

In the canonical model:
- The fragment elements are MCSes (sets of formulas)
- The time domain D is separate from the fragment
- Time-shift acts on D -> WorldState, not on the fragment

To get an additive group from fragment structure, we would need a way to "add" two fragment elements, which has no natural meaning for MCSes.

### 3.4 The Category-Theoretic Perspective

In the user's category-theoretic framing:
- The **bundle of families** is the set `B.families` (a set of FMCS)
- A **time-shift** maps one FMCS to another by reindexing: `shift_fam fam delta := fun t => fam.mcs (t + delta)`
- The **group of time-shift mappings** is `(D, +)` acting on the family's MCS function

But this action REQUIRES D to already have additive group structure -- the "shift by delta" operation uses `t + delta`, which presupposes `AddCommGroup D`. The group structure does not "emerge" from the bundle; it IS the additive structure of D.

**In other words**: The user is right that the additive structure comes from time-shift constraints on the bundle. But this is a SEMANTIC insight about what the additive group MEANS, not a CONSTRUCTIVE insight about how to build it without assuming it.

---

## 4. Can We Define Time-Shifts as Fragment Automorphisms?

### 4.1 The Attempt

Define a "shift" on the fragment:

```lean
def fragment_shift (w : BidirectionalFragment M0 h_mcs0) :
    BidirectionalFragment M0 h_mcs0 :=
  -- "move to the next element" in the total order
```

The idea: if the fragment is totally ordered, "shifting by one step" could be well-defined as "move to the successor element." Then the group of such shifts would be an additive group isomorphic to a subgroup of Z.

### 4.2 Why This Does Not Work

**Problem 1: No canonical successor.** The fragment's total order may have elements with no immediate successor. Between two elements `a < b`, there might be no element `c` with `a < c < b` (discrete), or there might be a dense chain of elements (dense). Without a canonical notion of "one step," there is no canonical shift operation.

**Problem 2: No uniform step size.** Even if successors exist, different elements may have different "step sizes" in any embedding into an ordered group. The linearity axiom forces totality but does not force uniformity of spacing.

**Problem 3: The shift group would be a quotient of the fragment, not the fragment itself.** If we define shifts as "differences between fragment elements," we get a group that is a quotient of the fragment's ordered structure. But this quotient IS an ordered group -- it IS the time domain D we are trying to construct. We are back to the same problem: we need to equip this quotient with AddCommGroup structure.

### 4.3 The Fundamental Obstacle

The obstacle is that the BidirectionalQuotient (the antisymmetrization of the fragment) has `LinearOrder` but NOT `AddCommGroup`. To get `AddCommGroup`, we need:

1. A binary operation `+` on the quotient
2. An identity element `0`
3. Inverses
4. Commutativity and associativity
5. Compatibility of `+` with the linear order

None of these arise naturally from the formula structure. The MCSes in the fragment are unrelated by any algebraic operation -- they are just sets of formulas related by CanonicalR (a subset relation on GContent).

**There is no natural way to "add" two MCSes**, and therefore no natural AddCommGroup on the fragment or its quotient.

---

## 5. How Would `ShiftClosed` Work Without `AddCommGroup D`?

### 5.1 Current ShiftClosed

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), time_shift sigma Delta in Omega
```

This requires `time_shift`, which requires `AddCommGroup D`.

### 5.2 Alternative: Shift-Closure Via Fragment Automorphisms

If D were the BidirectionalQuotient (no AddCommGroup), we could attempt:

```lean
-- Hypothetical: Omega is "automorphism-closed"
def AutoClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (alpha : Aut (LinearOrder D)),
    compose_history sigma alpha in Omega
```

where `compose_history sigma alpha` reindexes `sigma` by the order-automorphism `alpha`.

**Problem**: The BidirectionalQuotient typically has trivial automorphism group (as argued in Section 3.2). So `AutoClosed` would be trivially satisfied by any Omega, making it useless as a constraint.

### 5.3 Alternative: Define `valid_intrinsic` Without ShiftClosed

```lean
-- No ShiftClosed requirement
def valid_intrinsic (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D] (F : TaskFrame_intrinsic D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

where `TaskFrame_intrinsic` uses only `LinearOrder D` (no AddCommGroup, no nullity/compositionality).

**Problem**: The MF and TF axioms are NOT sound under `valid_intrinsic`, because their soundness proofs (Truth.lean:344-412) fundamentally use `time_shift_preserves_truth`, which requires:
- `y - x` (subtraction, from AddCommGroup)
- `x + (y - x) = y` (group identity)
- `neg_add_cancel` (inverse property)

Without these, MF (`Box phi -> Box (G phi)`) and TF (`Box phi -> G (Box phi)`) have no semantic justification. The logic TM with MF/TF is specifically designed for ordered additive group time domains.

### 5.4 Could MF/TF Soundness Be Reproven Without AddCommGroup?

**No, not in general.** The MF axiom says: if phi holds at all histories at time t, then G(phi) also holds at all histories at time t. The soundness proof needs to show: for any history sigma and any future time s >= t, there exists a history sigma' in Omega such that truth at (sigma', s) implies truth at (sigma, s).

The time-shift construction produces sigma' = `time_shift sigma (s - t)`. This history has the property that `truth_at sigma' t phi iff truth_at sigma s phi`. Without the ability to shift, we cannot relate truth at different times across different histories.

**The MF/TF axioms encode the requirement that D is an ordered additive group.** Removing AddCommGroup from D would make MF/TF unsound, and therefore the logic TM would no longer be the logic we are trying to prove complete.

---

## 6. What Architectural Changes Would This Require?

### 6.1 Option 1: Keep Current Architecture (Recommended)

Use the existing semantic definitions with `AddCommGroup D`. The completeness proof instantiates D = Rat (or Int) -- a concrete ordered additive group. The additive structure is "external" to the fragment but is provided by the embedding target.

**Changes needed**: Just the embedding from FPClosure into Rat (or Int), as outlined in research-004 and research-005.

### 6.2 Option 2: Define `valid_intrinsic` (Major Rearchitecture)

Create a parallel semantic layer:

```lean
-- TaskFrame without AddCommGroup
structure TaskFrame_intrinsic (D : Type*) [LinearOrder D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  -- No nullity (no 0)
  -- No compositionality (no +)

-- truth_at without time_shift
def truth_at_intrinsic (M : TaskModel_intrinsic F) (Omega : Set History)
    (tau : History) (t : D) : Formula -> Prop
  -- Same as truth_at but no ShiftClosed, no time_shift

-- Validity without AddCommGroup
def valid_intrinsic (phi : Formula) : Prop :=
  forall D [LinearOrder D], forall F M Omega tau t, truth_at_intrinsic ...
```

**Major issues**:
1. MF/TF axioms are NOT sound for this semantics
2. Would need to REMOVE MF/TF from the axiom system (changing the logic)
3. Or add replacement axioms that work without AddCommGroup
4. All soundness proofs would need reproving
5. All existing completeness infrastructure would need adapting

**Estimated effort**: 50-100+ hours. This is a separate research project.

### 6.3 Option 3: Hybrid -- AddCommGroup From Fragment (Theoretical Interest Only)

Attempt to equip the BidirectionalQuotient with AddCommGroup structure by:
1. Pick a distinguished root element as `0`
2. Define `a + b` as "the element that is as far from a as b is from 0"
3. Prove this forms an ordered additive group

**Fatal problem**: Step 2 has no well-defined meaning. "Distance" between elements requires an external metric, which presupposes the additive structure we are trying to construct. This is circular.

---

## 7. Comparison with Rat Embedding (research-005)

### 7.1 The Automorphism Approach vs. Rat Embedding

| Aspect | Fragment Automorphisms | Rat Embedding (research-005) |
|--------|----------------------|------------------------------|
| Mathematical elegance | High (intrinsic, no external structure) | Medium (external embedding) |
| Compatibility with current `valid` | None (no AddCommGroup) | Full (Rat has AddCommGroup) |
| MF/TF soundness | Lost | Preserved |
| Implementation effort | 50-100+ hours (rearchitecture) | 12-18 hours |
| Risk | Very high (changes the logic) | Low (Mathlib provides embedding) |
| Prior art in logic literature | Non-standard (research-level) | Standard (canonical model into Rat) |

### 7.2 Where the Automorphism Insight IS Valuable

The user's insight is correct in the following sense:

**The additive structure of time IS the group of time-shifts acting on histories.** This is a deep semantic truth about TM logic. The time-shift operation `time_shift sigma Delta` is an **action** of the group `(D, +)` on the set of world histories. The group structure IS the time-shift structure.

But in the completeness proof, we need to GO THE OTHER WAY: we have the fragment (a linear order of MCSes) and need to embed it into a group-structured type. The group structure does not emerge FROM the fragment -- it is IMPOSED ON IT by the embedding.

This is analogous to how in topology, a manifold's differential structure does not emerge from its point-set topology; it must be imposed via an atlas of charts into R^n. Similarly, the additive structure on times must be imposed via an embedding into an ordered group.

### 7.3 The "Don't Assume Int or Rat" Principle

The user's principle "don't assume Int or Rat" is best honored by:

1. **Using `satisfiable_abs`** (existential over D) rather than `satisfiable Int` or `satisfiable Rat` in the completeness statement
2. **The embedding target is a proof artifact**, not a semantic assumption. The completeness theorem says "there EXISTS a D where phi is satisfiable." The proof happens to use D = Rat, but the statement is D-agnostic.
3. **The axioms determine the structure.** Different axiom systems (adding density, discreteness, etc.) would produce different fragment structures. The embedding into Rat accommodates all of them.

---

## 8. Answers to Research Questions

### Q1: What is the "bundle of families" in current infrastructure?

The bundle of families is `B.families` in `BFMCS D` (BFMCS.lean:90). It is a `Set (FMCS D)` -- a set of time-indexed MCS families. In the current codebase:
- `construct_saturated_bfmcs_int` builds this for D = Int
- The eval_family is the distinguished family containing Gamma at time 0
- Additional families are added for modal saturation (diamond witnesses)
- The `shiftClosedCanonicalOmega` in Representation.lean is the orbit of canonical histories under the Int time-shift action

### Q2: How does `time_shift` work in the codebase?

`time_shift sigma Delta` (WorldHistory.lean:236) constructs a new history where:
- Domain: `fun z => sigma.domain (z + Delta)`
- States: `fun z hz => sigma.states (z + Delta) hz`
- Convexity and task relation are preserved by group properties

In the canonical model (Representation.lean), time-shifting a canonical history just reindexes the FMCS: `time_shift (canonicalHistory fam) delta` maps time `t` to `fam.mcs (t + delta)` instead of `fam.mcs t`.

### Q3: Can we define time-shifts as automorphisms of the fragment?

**No, not usefully.** The BidirectionalFragment typically has trivial automorphism group because each element has unique formula content. The time-shift operation acts on histories (D -> WorldState), not on the fragment (a set of MCSes). There is no natural way to derive an AddCommGroup from fragment automorphisms.

### Q4: How would ShiftClosed work without AddCommGroup?

It cannot work in its current form. ShiftClosed is defined via `time_shift`, which requires AddCommGroup. Alternatives:
- AutoClosed via order automorphisms: trivially satisfied (useless)
- Remove ShiftClosed entirely: loses MF/TF soundness
- Replace with a different closure property: requires rearchitecting soundness

### Q5: What architectural changes would this require?

To fully implement the automorphism approach:
- New `TaskFrame_intrinsic` without AddCommGroup (or with only `Preorder D`)
- New `valid_intrinsic` without ShiftClosed
- Reprove (or replace) MF/TF soundness
- Adapt all downstream completeness infrastructure
- Estimated 50-100+ hours

**Not recommended.** The Rat embedding approach (12-18 hours) achieves the same result within the current architecture.

---

## 9. Viability Assessment

### 9.1 Fragment Automorphism Approach: NOT VIABLE for Phase E

The approach of deriving AddCommGroup from fragment automorphisms is not viable for eliminating the sorry in `fully_saturated_bfmcs_exists_int` because:

1. The fragment does not have non-trivial automorphisms
2. There is no natural AddCommGroup on the BidirectionalQuotient
3. The current `valid` definition requires AddCommGroup D
4. MF/TF soundness requires time_shift, which requires AddCommGroup

### 9.2 Rat Embedding Approach: VIABLE (from research-005)

The Rat embedding remains the recommended path:

1. Define FPClosure on BidirectionalFragment
2. Prove countability and LinearOrder
3. Embed into Rat via Mathlib's `Order.embedding_from_countable_to_dense`
4. Build FMCS Rat from the embedding
5. Build BFMCS Rat with modal saturation
6. Use `satisfiable_abs` in completeness statements

### 9.3 Keep-It-General Principle

The user's principle "don't assume Int or Rat" is best honored by:

- **Statement level**: Use `satisfiable_abs` (D-agnostic)
- **Proof level**: Use D = Rat (or any sufficiently rich ordered group)
- **Philosophy**: The AXIOMS determine time structure. The EMBEDDING target is a proof artifact. Different axiom systems produce different fragments; all embed into Rat.

---

## 10. Comparison Summary: All Approaches

| Approach | Viability | Effort | Risk | Honors "emergent structure" |
|----------|-----------|--------|------|-----------------------------|
| Fragment automorphisms (this report) | NOT viable | 50-100h | Very high | Yes, but breaks soundness |
| FPClosure + Int (research-004) | Viable, complex | 22-33h | Medium | No (assumes discrete) |
| FPClosure + Rat (research-005) | Viable, cleanest | 12-18h | Low | Partially (accommodates any structure) |
| `satisfiable_abs` + Rat (recommended) | Viable, cleanest | 12-18h | Low | Yes (statement is D-agnostic) |
| `valid_intrinsic` rearchitecture | Theoretical | 50-100h+ | Very high | Yes (no external assumptions) |

---

## 11. Decisions

1. **The fragment automorphism approach is not viable** for the current task. The fundamental obstacle is that AddCommGroup cannot emerge from the fragment's order structure without external imposition.

2. **The user's insight is philosophically correct** but requires a different semantic framework (one without MF/TF or with weakened time-shift requirements) to be fully realized. This is a separate research direction, not part of the current sorry elimination.

3. **The recommended approach remains research-005's Rat embedding** with `satisfiable_abs` completeness statement. This is the minimal-effort path that:
   - Eliminates the sorry
   - Works within the current semantic architecture
   - Accommodates any fragment structure (dense, discrete, or mixed)
   - Uses Mathlib-verified infrastructure

4. **Future work**: The `valid_intrinsic` idea (removing AddCommGroup from validity) is worth exploring as a separate research project. It would produce a more general completeness result but requires rethinking the MF/TF axiom semantics.

---

## 12. Open Questions

1. **Could TM be reformulated with weaker axioms** that do not require full AddCommGroup? For example, if MF/TF were replaced by axioms that only require a partial group action, the fragment-automorphism approach might become viable.

2. **Is there a completeness proof that works at the fragment level directly** without embedding? The fragment has `LinearOrder` and the truth lemma works over `Preorder D`. If we could bypass `valid` (which requires AddCommGroup) and prove completeness directly via the non-shifted truth lemma and `canonicalOmega` (not shift-closed), we might avoid the embedding entirely. However, this would require changing the meaning of `valid`.

3. **Does the paper's original proof specify D = Int, D = Rat, or D = abstract?** If the paper uses an abstract ordered group, the `satisfiable_abs` approach matches perfectly.
