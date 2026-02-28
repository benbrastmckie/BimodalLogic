# Research Report: Task #951 (research-005) -- Recursive Unpacking and Constructed Time Domains

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-28
**Session**: sess_1772310457_34e8db
**Effort**: High (mathematical analysis of alternative canonical model construction approaches)
**Dependencies**: research-004, phases A-D completed, phase E blocked on Int embedding
**Sources/Inputs**: Validity.lean, Truth.lean, Axioms.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean, Representation.lean, FMCSDef.lean, BFMCS.lean, TemporalCoherentConstruction.lean, TaskFrame.lean, Mathlib order embedding theorems
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report analyzes the user's fundamental insight that **times need not have the structure of Int** and that the time domain should be **constructed from the formula structure** via recursive unpacking of consistent sets. The key idea is to avoid committing to Int upfront and instead build the time domain intrinsically so that its properties (dense, discrete, linear) emerge from the axioms present.

**Main findings**:

1. The "recursive unpacking" approach is mathematically sound and corresponds precisely to the **BidirectionalFragment construction** already implemented sorry-free in the codebase (Phases A-D).

2. The constructed time domain IS the `BidirectionalQuotient` -- a `LinearOrder` type built entirely from formula structure. This type already exists in the codebase (line 777, BidirectionalReachable.lean).

3. **The critical obstacle is NOT building the time domain** (that is done). It is that the downstream semantic definitions (`valid`, `satisfiable`, `TaskFrame`) require `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, and the BidirectionalQuotient has no natural additive group structure.

4. **Two viable paths forward** are identified:
   - **Path A (Generalize D)**: Relax the type class requirements on D throughout the semantics layer to only require `[LinearOrder D]` where possible, using BidirectionalQuotient directly as the time type.
   - **Path B (Embed into Rat)**: Use Mathlib's `Order.embedding_from_countable_to_dense` to embed the countable FPClosure into Rat (a `LinearOrderedAddCommGroup`), avoiding the discrete-order-into-Int problem entirely.

5. Path B is **strictly superior** to the FPClosure-into-Int approach from research-004 because Mathlib already provides the embedding theorem for countable linear orders into densely ordered types (Rat, Real), whereas no such theorem exists for embedding into Int (and indeed, non-discrete countable linear orders cannot embed into Int at all).

---

## 2. Mathematical Analysis of "Recursive Unpacking"

### 2.1 What the User Describes

The user's insight decomposes into four stages:

**Stage 1: Unpack the initial consistent set recursively.** Starting from a consistent set Gamma, recursively process F(phi) and P(phi) obligations. Each such obligation creates a new consistent (but not yet maximal) set containing the witness formula plus the GContent or HContent of the parent.

**Stage 2: Construct partial families of consistent sets forming linear orderings.** The linearity axiom (`temp_linearity`) forces all these partial sets into a total order. Each new witness is placed relative to existing elements by the three-way case split from linearity.

**Stage 3: Extend finite families to MCSes.** Each finite consistent set in the family is extended to a maximal consistent set via Lindenbaum's lemma.

**Stage 4: Enrichment determines time domain properties.** The axioms present determine whether the resulting time domain is:
- Dense (if density axioms like `F(phi) -> F(F(phi) /\ ~phi)` are included)
- Discrete (if successor axioms are included)
- Neither specifically, but guaranteed totally ordered

### 2.2 Correspondence to Existing Codebase

This construction is **exactly what the BidirectionalFragment implements**:

| User's Stage | Codebase Correspondence | File |
|---|---|---|
| Unpack initial set | `BidirectionalFragment.root` (M0) | BidirectionalReachable.lean:140 |
| Process F(phi) obligations | `forward_F_stays_in_fragment` | BidirectionalReachable.lean:195 |
| Process P(phi) obligations | `backward_P_stays_in_fragment` | BidirectionalReachable.lean:214 |
| Linear ordering from axioms | `bidirectional_totally_ordered` | BidirectionalReachable.lean:728 |
| Extension to MCS | Lindbaum (via `lindenbaumMCS_set`) | CanonicalCompleteness.lean:270 |
| Enriched witnesses | `fragmentFSucc`, `fragmentFSucc_le` | CanonicalCompleteness.lean:266,291 |

The BidirectionalFragment IS the "recursively unpacked" time domain. Each element is an MCS reachable from M0 by F/P witness steps (the "recursive unpacking"). The totality theorem proves these elements form a linear order (Stage 2). And this is all sorry-free.

### 2.3 How Axioms Determine Time Domain Properties

The `temp_linearity` axiom forces totality of the CanonicalR preorder on the fragment. This gives us a `LinearOrder` on the quotient.

**Density**: If TM included a density axiom like `F(phi) -> F(F(phi) /\ ~phi)` (there exists a strictly intermediate point), then between any two fragment elements with `w < w'`, there would exist a third element strictly between them. The current TM axiom set does NOT include such an axiom, so the fragment may or may not be dense.

**Discreteness**: If TM included successor/predecessor axioms, the fragment would be discrete. The current TM axiom set does NOT include such axioms, so discreteness is not guaranteed.

**What we DO have**: A total preorder (from `temp_linearity`) that we can antisymmetrize into a `LinearOrder`. The structure of this order depends entirely on which formulas are in the consistent set Gamma and which F/P witness chains are generated.

### 2.4 The "Termination" Question

The user asks whether the recursive unpacking process terminates. In a precise sense:

- **Each individual unpacking step terminates**: given `F(phi) in W`, `forward_F_stays_in_fragment` produces a witness in finite time (one Lindenbaum extension).

- **The overall construction need not terminate**: the fragment may be infinite. Starting from M0 with `F(phi)`, we get a witness W1 with `phi in W1`. But W1 may contain `F(psi)` for new psi, generating further witnesses. This can continue indefinitely.

- **Countability is guaranteed**: each step adds at most one element per (element, formula) pair. Since formulas are countable (they form an inductive type), the fragment's FPClosure (the sub-fragment reachable by F/P witness steps) is countable.

---

## 3. Type Requirements Analysis

### 3.1 Current Requirements on D

The semantic layer requires three type classes for the time domain D:

```
[AddCommGroup D]       -- zero, addition, negation, subtraction
[LinearOrder D]        -- total order with decidable comparison
[IsOrderedAddMonoid D] -- order compatibility with addition
```

These appear in:
- `valid` (Validity.lean:72)
- `semantic_consequence` (Validity.lean:95)
- `satisfiable` (Validity.lean:119)
- `TaskFrame` (TaskFrame.lean:84)
- `time_shift` (WorldHistory.lean:236)
- `time_shift_preserves_truth` (Truth.lean:344)
- `ShiftClosed` (Truth.lean:231)

### 3.2 What Actually Uses AddCommGroup

The `AddCommGroup` structure is used ONLY for:

1. **`time_shift`**: Shifts a history by `Delta : D`, using `t + Delta` to reindex domain/states.
2. **`time_shift_preserves_truth`**: Uses `y - x`, `x + (y - x) = y`, and negation `-(x - y)`.
3. **`ShiftClosed`**: Definition uses `time_shift sigma Delta`, hence `AddCommGroup`.
4. **Soundness of MF/TF axioms**: The `time_shift_preserves_truth` theorem is essential for proving the modal-temporal interaction axioms sound.
5. **`shiftClosedCanonicalOmega`**: In Representation.lean, the shift-closed enlargement requires time-shifting canonical histories.
6. **`TaskFrame.nullity`**: Uses `0` from `AddCommGroup`.
7. **`TaskFrame.compositionality`**: Uses `x + y` from `AddCommGroup`.

### 3.3 What Does NOT Use AddCommGroup

Critically, the following components work over `[Preorder D]` alone:
- `FMCS D` (FMCSDef.lean:80)
- `BFMCS D` (BFMCS.lean:88)
- `forward_G`, `backward_H` (FMCS coherence conditions)
- The entire BFMCS truth lemma (`canonical_truth_lemma_all`) in Representation.lean

The truth lemma uses `truth_at`, which requires `AddCommGroup D` only in its type signature. But the cases that matter for the truth lemma are:
- **atom**: domain membership check (no group operations)
- **bot**: trivial
- **imp**: recursive
- **box**: quantification over Omega (no group operations needed for non-shifted Omega)
- **all_future/all_past**: quantification over `s >= t` or `s <= t` (only `Preorder` needed)

### 3.4 The Shifted Truth Lemma Problem

The `shifted_truth_lemma` (Representation.lean:411) -- the version used in the completeness proof -- is where `AddCommGroup` becomes essential. Its box-forward case uses `box_persistent` combined with `time_shift_preserves_truth` to handle shifted histories in `shiftClosedCanonicalOmega`.

The issue is:
- `valid` quantifies over all shift-closed Omega
- Completeness must produce a model with shift-closed Omega
- Shift-closure requires time-shift, which requires AddCommGroup

However, there is an alternative:

**Key observation**: The non-shifted truth lemma (`canonical_truth_lemma_all`, line 266) works with `canonicalOmega` (not shift-closed). If we could prove completeness using the non-shifted version, we would NOT need `AddCommGroup` for the model construction.

The problem: `valid` is defined with the `ShiftClosed Omega` precondition. For weak completeness, we instantiate `valid` at our canonical model, and we need to provide a shift-closed Omega. If we cannot produce shift-closed Omega without AddCommGroup, we need AddCommGroup on D.

### 3.5 Can We Generalize valid?

An alternative approach: change `valid` to NOT require `ShiftClosed Omega`. Instead, quantify over ALL Omega (not just shift-closed ones). This would mean:
- Soundness must work for arbitrary Omega (not just shift-closed)
- The MF/TF soundness proofs would need restructuring

This is a substantial change and was previously analyzed (Task 912). The current design (ShiftClosed Omega) was chosen precisely to enable both soundness and completeness. Changing it is risky.

---

## 4. Path A: Generalize D to LinearOrder

### 4.1 Concept

Replace the type class requirements throughout the semantics layer:

**Current**: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
**Proposed**: `[LinearOrder D]` for the core definitions; `[AddCommGroup D] ...` only where time_shift is used

### 4.2 What Changes

1. **`TaskFrame`**: Remove AddCommGroup requirement. Replace `nullity` and `compositionality` with Preorder-based axioms, or make them conditional on having group structure.

2. **`truth_at`**: No changes needed -- it uses only `<=` for all_future/all_past.

3. **`valid`**: Parameterize differently. The current `valid` quantifies over all `D` with AddCommGroup. We could add a new `valid_linear` that quantifies over all `D` with `[LinearOrder D]` alone, WITHOUT the ShiftClosed condition.

4. **Soundness**: Would need to be reproven for `valid_linear`. The MF/TF axioms' soundness relies on `time_shift_preserves_truth`, which requires AddCommGroup. These axioms would NOT be sound in the weakened setting without additional conditions.

### 4.3 Fundamental Problem

The MF axiom (`Box phi -> Box (G phi)`) and TF axiom (`Box phi -> G(Box phi)`) are ONLY sound when the Omega set is shift-closed. Their soundness proofs fundamentally use time-shift operations. If we remove AddCommGroup from D, we cannot prove time_shift_preserves_truth, and the MF/TF axioms lose their semantic grounding.

**This means Path A requires restructuring how MF/TF soundness is established**, which is a major undertaking that goes well beyond the Phase E blocker.

### 4.4 Verdict on Path A

**Not recommended for this task.** While theoretically clean, generalizing the semantics to work without AddCommGroup would require rearchitecting the soundness proof and the MF/TF axiom semantics. This is a separate research project, not a fix for the Phase E blocker.

---

## 5. Path B: Embed into Rat (or Another Group-Structured Type)

### 5.1 Concept

Instead of embedding FPClosure into Int (which requires the FPClosure to be discrete), embed it into Rat, which:
- IS a `LinearOrderedAddCommGroup` (satisfies all current type class requirements)
- IS densely ordered (Mathlib provides `Order.embedding_from_countable_to_dense`)
- Accepts ANY countable linear order as a source

### 5.2 The Mathlib Theorem

```lean
-- Mathlib.Order.CountableDenseLinearOrder
theorem Order.embedding_from_countable_to_dense
    [Countable alpha] [DenselyOrdered beta] [Nontrivial beta] :
    Nonempty (alpha embedsInto beta)
```

This gives us: for any `Countable` type `alpha` with `LinearOrder`, there exists an order embedding `alpha embedsInto beta` for any densely ordered nontrivial `beta`.

Instantiating with `alpha = FPClosure` and `beta = Rat`:

```
Nonempty (FPClosure embedsInto Rat)
```

### 5.3 Why Rat Works Where Int Fails

The FPClosure inherits a total preorder from BidirectionalFragment. Its Antisymmetrization quotient is a LinearOrder. But this linear order need not be discrete:

- If the fragment contains elements `a < b` with nothing between them, fine.
- If the fragment contains elements `a < c < b` (three-way witness placement from linearity), we need room to insert `c`.
- In Int, insertion requires gaps. In Rat, insertion is always possible.

With Int, we need to manage gaps explicitly (the "leave even positions empty" trick from research-004). With Rat, the embedding is guaranteed by Mathlib.

### 5.4 Implementation Sketch

**Step 1: Define FPClosure**

```lean
inductive FPClosure (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    BidirectionalFragment M0 h_mcs0 -> Prop where
  | root : FPClosure M0 h_mcs0 BidirectionalFragment.root
  | fwd {w} {phi} (h_mem : FPClosure M0 h_mcs0 w) (h_F : some_future phi in w.world) :
      FPClosure M0 h_mcs0 (fragmentFSucc w phi h_F)
  | bwd {w} {phi} (h_mem : FPClosure M0 h_mcs0 w) (h_P : some_past phi in w.world) :
      FPClosure M0 h_mcs0 (fragmentPSucc w phi h_P)  -- (need backward analog)
```

**Step 2: Prove FPClosure is countable**

Each element of FPClosure is determined by a finite sequence of (direction, formula) pairs starting from root. Since formulas are countable and sequences of countable choices are countable, FPClosure is countable.

**Step 3: FPClosure has LinearOrder**

Inherited from `BidirectionalQuotient` via the inclusion map. The Antisymmetrization of the FPClosure (viewed as a sub-preorder of BidirectionalFragment) is a countable linear order.

**Step 4: Embed into Rat**

Apply `Order.embedding_from_countable_to_dense` with alpha = FPClosureQuotient and beta = Rat. This gives an order embedding `e : FPClosureQuotient embedsInto Rat`.

**Step 5: Build FMCS Rat**

Define `fmcs_rat : FMCS Rat` by:
- For `q` in the image of `e`: `fmcs_rat.mcs q = fragmentFMCS.mcs (e_inv q)`
- For `q` not in the image: `fmcs_rat.mcs q = fragmentFMCS.mcs (nearest_below q)`

Properties:
- `forward_G`: From order-preservation of `e` and monotone filling
- `backward_H`: Similarly
- `forward_F`: From FPClosure's closure under F-witnesses + order-preservation
- `backward_P`: Similarly

**Step 6: Build BFMCS Rat**

Same pattern as the current Int construction:
- `eval_family = fmcs_rat`
- Witness families for Diamond obligations: each gets its own BidirectionalFragment + FPClosure + Rat embedding
- Modal saturation from `box_witness_seed_consistent` (sorry-free)

**Step 7: Change `satisfiable Int` to `satisfiable Rat` in completeness theorems**

OR: Prove `satisfiable Rat Gamma -> satisfiable Int Gamma` (which is NOT generally true for arbitrary Gamma, but IS implied by `satisfiable_abs`).

### 5.5 The D = Rat vs D = Int Question

The completeness theorems currently state `satisfiable Int [phi]`. If we change to `satisfiable Rat [phi]`, the completeness proof is easier but the statement is weaker (though for a different reason than one might think).

**Key insight**: `valid` quantifies over ALL D with the appropriate type classes. So `valid phi` implies `truth_at` for EVERY such D, including both Int and Rat. The contrapositive of weak completeness says: if phi is not derivable, then phi.neg is satisfiable in SOME D. We only need to produce ONE D where phi.neg is satisfiable.

For weak completeness: `valid phi -> derivable phi`
Contrapositive: `not (derivable phi) -> not (valid phi)`
Which means: `not (derivable phi) -> exists D, not (forall models of D, phi true)`
Which means: `not (derivable phi) -> exists D, satisfiable D [phi.neg]`

We only need to provide ONE D. So `satisfiable Rat [phi.neg]` suffices.

**For `standard_representation`**: Currently states `satisfiable Int [phi]`. This could be changed to `satisfiable Rat [phi]` or `satisfiable_abs [phi]` (existential over D). The latter is cleaner and arguably more natural.

### 5.6 Comparison: Rat Embedding vs Int Embedding

| Aspect | Int Embedding | Rat Embedding |
|--------|--------------|---------------|
| Mathlib support | No theorem exists | `Order.embedding_from_countable_to_dense` |
| Discreteness required | Yes | No |
| Gap management | Must leave gaps, fill monotonically | Free (density handles insertion) |
| Time shift | Int has AddCommGroup | Rat has AddCommGroup |
| Shift-closed Omega | Works the same | Works the same |
| Downstream changes | None (currently targets Int) | Change `Int` to `Rat` in ~5 files |
| Implementation effort | 22-33 hours (research-004 estimate) | 12-18 hours (Mathlib does heavy lifting) |
| Risk of subtle bugs | High (gap-filling logic) | Low (Mathlib-verified embedding) |

---

## 6. Path C: Use the BidirectionalQuotient Directly (Hybrid)

### 6.1 Concept

Observe that the weak completeness theorem does NOT actually need `satisfiable`. It proves: `valid phi -> derivable phi` by contraposition. The contrapositive produces a model, but the statement is about derivability, not satisfiability.

Could we reformulate the proof to avoid `satisfiable` entirely?

### 6.2 Analysis

Looking at `standard_weak_completeness` (Representation.lean:608):
1. Assume `not (derivable phi)`
2. `[phi.neg]` is consistent
3. Construct BFMCS B
4. By shifted truth lemma: phi.neg is true at canonical model
5. By validity: phi is true at same model (using ShiftClosed Omega)
6. Contradiction

Step 5 instantiates `valid` at the canonical model. The key requirement: we must provide a D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and a ShiftClosed Omega.

Even if we avoid `satisfiable`, we still need a concrete D with group structure for the canonical model.

### 6.3 Verdict

Path C does not avoid the need for a concrete D. It is not a viable shortcut.

---

## 7. Recommended Approach: Path B (Rat Embedding)

### 7.1 Why Path B is Best

1. **Mathlib provides the hard part**: `Order.embedding_from_countable_to_dense` gives us the embedding for free, after we prove the FPClosure is countable and linearly ordered.

2. **Avoids the discrete-insertion problem**: The whole difficulty with Int embedding was managing gaps and proving the filling is order-preserving. With Rat, density handles this automatically.

3. **Minimal codebase changes**: The only files that hard-code `Int` are:
   - `TemporalCoherentConstruction.lean` (the sorry)
   - `Representation.lean` (the completeness statements)
   These can be parameterized over D or changed to Rat.

4. **Leverages all existing sorry-free infrastructure**: fragmentFMCS, forward_F/backward_P witnesses, bidirectional totality, box_witness_seed_consistent.

5. **Cleaner mathematics**: The constructed time domain's structure (dense, discrete, etc.) is NOT predetermined -- it emerges from the formulas. Embedding into Rat accommodates ANY structure.

### 7.2 Detailed Implementation Plan

**Phase E-revised (Rat embedding): 12-18 hours**

**E.1: FPClosure definition and properties (3-4 hours)**
- Define `FPClosure` as inductive predicate on BidirectionalFragment
- Prove closure under F/P witnesses
- Prove countability (each element determined by finite witness chain; formulas are countable)
- Prove inherited LinearOrder on Antisymmetrization

**E.2: Rat embedding via Mathlib (2-3 hours)**
- Verify `Order.embedding_from_countable_to_dense` applies to FPClosureQuotient -> Rat
- Prove necessary instances: `Countable FPClosureQuotient`, `LinearOrder FPClosureQuotient`, `Nonempty FPClosureQuotient`
- Extract the order embedding `e`

**E.3: FMCS Rat construction (3-4 hours)**
- Define `fmcs_rat : FMCS Rat` via the embedding
- Prove forward_G, backward_H (from order-preservation + monotone filling)
- Prove forward_F, backward_P (from FPClosure closure properties + embedding)

**E.4: BFMCS Rat construction (2-3 hours)**
- eval_family from E.3
- Diamond witness families: each diamond obligation generates its own fragment + FPClosure + Rat embedding
- Modal forward/backward from box_witness_seed_consistent

**E.5: Completeness theorem updates (2-4 hours)**
- Change `fully_saturated_bfmcs_exists_int` to `fully_saturated_bfmcs_exists_rat`
- Update Representation.lean to use Rat instead of Int
- OR: Change to `satisfiable_abs` (existential over D)
- Prove sorry-free

### 7.3 Key Lemmas to Prove

1. `FPClosure_countable`: FPClosure is countable
2. `FPClosure_linearOrder`: Antisymmetrization of FPClosure has LinearOrder
3. `FPClosure_nonempty`: Root is in FPClosure
4. `fmcs_rat_forward_F`: F-witnesses exist in the Rat-indexed family
5. `fmcs_rat_backward_P`: P-witnesses exist in the Rat-indexed family
6. `fmcs_rat_forward_G`: G-formulas propagate to future Rat times
7. `fmcs_rat_backward_H`: H-formulas propagate to past Rat times
8. `monotone_fill_order_preserving`: Filling gaps preserves order

### 7.4 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| FPClosure countability proof is complex | Medium | Medium | Use Mathlib's Set.Countable infrastructure; each element has finite encoding |
| Monotone filling for non-image points | Medium | Medium | Use `sSup`/`sInf` of image below/above; Rat has these |
| `Order.embedding_from_countable_to_dense` is noncomputable | Certain | Low | All canonical model constructions are already noncomputable |
| Downstream changes from Int->Rat | Low | Medium | Few files reference Int directly; most are polymorphic |
| Rat lacks `Fintype` for finite model property | Low | Low | FMP is a separate concern; completeness does not need it |

---

## 8. Alternative: Satisfiable_abs Instead of Satisfiable D

### 8.1 The Cleanest Approach

Instead of `satisfiable Int [phi]` or `satisfiable Rat [phi]`, the completeness theorem could state:

```lean
theorem standard_representation (phi : Formula) (h_cons : ContextConsistent [phi]) :
    satisfiable_abs [phi]
```

Where `satisfiable_abs` (already defined in Validity.lean:127) is:

```lean
def satisfiable_abs (Gamma : Context) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D),
    satisfiable D Gamma
```

This is the most natural statement: a consistent context is satisfiable in SOME time domain. The weak/strong completeness theorems then follow identically (they only need the existence of a countermodel, not that it uses a specific D).

### 8.2 Advantage

With `satisfiable_abs`, we can instantiate D = Rat (or D = BidirectionalQuotient-with-Rat-structure, or whatever is most convenient) and the user never sees the choice. The statement is clean and D-agnostic.

### 8.3 What About satisfiable Int Specifically?

If we want to ALSO prove `satisfiable Int`, we can do it as a separate theorem using an order embedding from Rat to Real to ... but this is unnecessary. The completeness theorem only needs `satisfiable_abs`.

In fact, `satisfiable Int Gamma` is a STRONGER statement than completeness requires. Completeness says: consistent implies satisfiable-somewhere. It does NOT say: consistent implies satisfiable-in-every-D.

---

## 9. Answers to Research Questions

### Q1: What is the "recursive unpacking" approach?

It is the process of starting from a consistent set Gamma, extending it to an MCS M0, then iteratively creating new MCSes for each F(phi) and P(phi) obligation. Each new MCS is placed in a linear order relative to existing ones (via the temp_linearity axiom). This process is exactly the BidirectionalFragment construction.

The time domain is the set of MCSes generated this way (or more precisely, its Antisymmetrization quotient to get a LinearOrder).

### Q2: How does this differ from FPClosure?

It IS FPClosure. The user's description of "recursively unpacking" is a constructive/algorithmic reading of the FPClosure inductive definition. The FPClosure approach from research-004 is the formalization of the user's insight.

### Q3: What type D should replace Int?

**Recommended**: D = Rat. The type `Rat` has all required instances (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`) and is densely ordered, so Mathlib provides the embedding from any countable linear order into Rat.

**Alternative**: D could be the BidirectionalQuotient itself, IF we could equip it with an AddCommGroup structure. But the quotient has no natural addition operation (adding two MCSes is meaningless), so this is not viable without artificial construction.

**Simplest change**: Use `satisfiable_abs` (existential over D) in the completeness statement, instantiating D = Rat internally.

### Q4: How do axioms determine density/discreteness?

The `temp_linearity` axiom determines **totality** (linearity) of the time domain. The presence of density or successor axioms would determine further structure:

- **Density**: Would follow from axioms like `F(phi) -> F(F(phi) /\ ~phi)` (between now and any future point, there is an intermediate point). TM does not include this.
- **Discreteness**: Would follow from successor axioms like `exists_next : F(phi) -> F(phi /\ ~F(~phi))` (the first future point where phi holds). TM does not include this.
- **Neither**: The current TM axiom set leaves the order structure underdetermined beyond linearity. This is exactly why embedding into a dense order (Rat) is the right move -- it accommodates whatever structure the fragment happens to have.

### Q5: Implementation path?

1. Define FPClosure (inductive on BidirectionalFragment)
2. Prove countability and LinearOrder
3. Embed into Rat via `Order.embedding_from_countable_to_dense`
4. Build FMCS Rat from the embedding
5. Build BFMCS Rat with modal saturation
6. Change completeness theorems to use `satisfiable_abs` (or `satisfiable Rat`)
7. Eliminate the sorry in `fully_saturated_bfmcs_exists_int`

---

## 10. Comparison: FPClosure+Int (research-004) vs FPClosure+Rat (this report)

| Aspect | research-004 (Int) | research-005 (Rat) |
|--------|-------------------|-------------------|
| Embedding theorem | None in Mathlib; must build manually | `Order.embedding_from_countable_to_dense` |
| Gap management | Manual (leave even positions) | Automatic (density) |
| Filling strategy | Nearest-element monotone fill | Same, but simpler (Sup/Inf in Rat) |
| Proof complexity | High (custom enumeration) | Lower (Mathlib embedding) |
| Estimate | 22-33 hours | 12-18 hours |
| Downstream changes | None (currently targets Int) | ~5 files (Int -> Rat or satisfiable_abs) |
| Risk of bugs | High (gap arithmetic) | Low (Mathlib-verified) |
| Mathematical naturality | Artificial (Int is arbitrary choice) | Natural (Rat accommodates any structure) |

---

## 11. Decisions

1. **The user's "recursive unpacking" insight is correct and already implemented** as the BidirectionalFragment + FPClosure.

2. **The time domain should NOT be forced to be Int**. Using Rat (or satisfiable_abs) is mathematically cleaner and practically easier.

3. **Path B (Rat embedding) is recommended** over Path A (generalize D) and the original Int embedding approach.

4. **The cleanest completeness statement uses `satisfiable_abs`** rather than `satisfiable Int` or `satisfiable Rat`.

5. **Estimated effort: 12-18 hours** (down from 22-33 hours for Int embedding).

---

## 12. Open Questions

1. **Is `Order.embedding_from_countable_to_dense` computable enough?** It uses `Encodable` and an ideal construction. We need it to be at least `noncomputable def`, which should be fine since all canonical model constructions are already noncomputable.

2. **Does the shift-closed Omega construction work over Rat?** The `shiftClosedCanonicalOmega` in Representation.lean uses `time_shift` with delta : D. Since Rat has AddCommGroup, time_shift works. Shift-closure should follow by the same proof as for Int.

3. **Can we avoid FPClosure entirely?** If the full BidirectionalFragment is countable (not just the FPClosure), we could embed the entire fragment into Rat. But the full fragment may be uncountable (uncountably many MCSes are reachable). The FPClosure restricts to the FINITELY-generated sub-fragment, ensuring countability.

4. **Is there a simpler alternative to the monotone-fill strategy?** For Rat positions not in the embedding's image, we assign the nearest fragment element below. Could we instead make the FMCS constant on gaps? Yes -- assign the MCS of the supremum of image points below q. This is essentially the same as monotone fill.
