# Research Report: Task #951 (research-004) -- Direct Linearization via Linearity Axioms

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-28
**Session**: sess_1772309482_b679d5
**Effort**: High (analysis of linearity axiom infrastructure + novel approach evaluation)
**Dependencies**: research-003, implementation-002 (phases A-D completed, phase E blocked)
**Sources/Inputs**: BidirectionalReachable.lean (832 lines), CanonicalCompleteness.lean (425 lines), Axioms.lean (temp_linearity), SoundnessLemmas.lean (soundness proof), CanonicalFrame.lean (canonical_forward_F, canonical_backward_P), DovetailingChain.lean, TemporalCoherentConstruction.lean, Representation.lean, Validity.lean, LinearityDerivedFacts.lean, FMCSDef.lean, BFMCS.lean
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report investigates the user's insight that **linearity axioms can be used to construct a total ordering directly** rather than building a partial order and then embedding it. The key observation is that whenever F(phi) and F(psi) both hold at an MCS M, the `temp_linearity` axiom forces their witnesses into a linear relationship, and this can be used to incrementally build a chain of MCSes indexed by Int.

**Main findings**:

1. The linearity axiom infrastructure is already **fully proven and operational** in BidirectionalReachable.lean (Phase B of plan v2, completed).

2. The user's insight about "direct linearization" is closely related to **Solution Path E from research-003** (multi-witness seed consistency / monotone enumeration chain).

3. The approach avoids the F-persistence problem because it does NOT build a chain via GContent propagation. Instead, it places witnesses one at a time using `enriched_seed_consistent_from_F` (proven sorry-free in CanonicalCompleteness.lean).

4. The key open question is whether we can construct an FMCS Int whose range is closed under F/P witnesses. The direct linearization approach suggests a novel construction: **build the chain incrementally, using linearity to determine where each new witness belongs relative to existing elements**.

5. However, the approach faces a fundamental tension: **the chain must be built over Int (a fixed countable linear order), but witness placement requires the ordering to be "extensible"** -- which means the construction is closer to building a countable dense linear order (like Q) and then mapping to Int. This is exactly the approach from research-003's Phase E/C.

6. **The most viable concrete strategy** combines the user's insight with the existing sorry-free infrastructure: use the fragment-level FMCS (proven complete in CanonicalCompleteness.lean) and embed it into Int via a countable enumeration argument.

---

## 2. Current Linearity Axiom Infrastructure

### 2.1 The temp_linearity Axiom

Defined in `Theories/Bimodal/ProofSystem/Axioms.lean` (line 316):

```
temp_linearity (phi psi : Formula) :
    Axiom (F(phi) /\ F(psi) -> F(phi /\ psi) \/ F(phi /\ F(psi)) \/ F(F(phi) /\ psi))
```

Semantics (from `SoundnessLemmas.lean`, lines 746-817): Given witnesses s1 >= t for phi and s2 >= t for psi in a linearly ordered time domain D, either:
- s1 = s2: first disjunct F(phi /\ psi) holds
- s1 <= s2: second disjunct F(phi /\ F(psi)) holds (phi before psi)
- s2 <= s1: third disjunct F(F(phi) /\ psi) holds (psi before phi)

The past version (`P(phi) /\ P(psi) -> P(phi /\ psi) \/ P(phi /\ P(psi)) \/ P(P(phi) /\ psi)`) is derived from `temp_linearity` via `DerivationTree.temporal_duality`.

### 2.2 Linearity Lemmas in BidirectionalReachable.lean

All proven sorry-free:

**`mcs_F_linearity`** (line 284): Applies temp_linearity within an MCS context.
- Input: F(phi) in M, F(psi) in M, M is MCS
- Output: F(phi /\ psi) in M, or F(phi /\ F(psi)) in M, or F(F(phi) /\ psi) in M

**`mcs_P_linearity`** (line 456): Past analog via temporal duality.
- Input: P(phi) in M, P(psi) in M, M is MCS
- Output: P(phi /\ psi) in M, or P(phi /\ P(psi)) in M, or P(P(phi) /\ psi) in M

**`canonical_forward_reachable_linear`** (line 354): If M1 and M2 are both CanonicalR-successors of M, they are CanonicalR-comparable. Proof uses `mcs_F_linearity` on compound formulas to derive contradiction if neither M1 <= M2 nor M2 <= M1.

**`canonical_backward_reachable_linear`** (line 540): Backward analog using `mcs_P_linearity`.

**`bidirectional_totally_ordered`** (line 728): Any two elements of the BidirectionalFragment are CanonicalR-comparable. Proved by induction on BidirectionalReachable, using `comparable_step_forward` and `comparable_step_backward` as step cases.

**`fragment_le_total`** (line 756) and `instLinearOrderBidirectionalQuotient` (line 784): The Antisymmetrization quotient has a LinearOrder.

### 2.3 Summary

The linearity infrastructure is complete and sorry-free. The bidirectional fragment from any root MCS is totally ordered. The fragment has sorry-free forward_F and backward_P. The quotient of the fragment is a LinearOrder.

---

## 3. Analysis of the "Direct Linearization" Approach

### 3.1 The User's Insight

The user proposes: given F(phi) and F(psi) in some MCS M, the linearity axiom tells us the RELATIVE ORDERING of their witnesses. So instead of building a partial order and then embedding, we should:

1. Start with root MCS M0
2. For each F(phi) in M0, add a witness at a determined position
3. Use linearity to determine relative positions of witnesses
4. Result: a linear chain by construction

### 3.2 What This Looks Like Concretely

Starting from M0 with F(phi) and F(psi) in M0:
- Linearity gives one of three cases for their witnesses
- Case F(phi /\ psi): witnesses coincide -- one MCS W with phi /\ psi in W, CanonicalR M0 W
- Case F(phi /\ F(psi)): phi's witness W1 comes first; at W1, F(psi) still holds, so psi's witness W2 > W1
- Case F(F(phi) /\ psi): psi's witness W2 comes first; at W2, F(phi) still holds, so phi's witness W1 > W2

This determines the relative ordering of W1 and W2. Then for each new F-formula at each witness, the process repeats, placing new witnesses relative to existing ones.

### 3.3 How This Relates to Existing Infrastructure

This approach is essentially a **constructive reading of `bidirectional_totally_ordered`**. The existing proof shows that any elements added to the fragment via forward_F/backward_P witnesses are comparable with all existing elements. The user's insight is to read this as a CONSTRUCTION algorithm rather than just a property.

Specifically:
- `forward_F_stays_in_fragment` (line 195) already proves that F-witnesses stay in the fragment
- `backward_P_stays_in_fragment` (line 214) already proves that P-witnesses stay in the fragment
- `bidirectional_totally_ordered` (line 728) proves that any two elements are comparable
- The fragment already has a `Preorder` and `IsTotal` instance

The fragment IS the "direct linearization" -- it IS the linearly ordered collection built by following F/P witnesses.

### 3.4 Why This Does NOT Immediately Solve the Problem

The fragment has a sorry-free FMCS (`fragmentFMCS` in CanonicalCompleteness.lean, line 72) with sorry-free forward_F/backward_P (`fragmentFMCS_forward_F`, line 90; `fragmentFMCS_backward_P`, line 104).

The problem remains: **how to get from FMCS(BidirectionalFragment) to FMCS(Int)**. The fragment is not Int. Int has `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`. The fragment has none of these algebraic structures.

This is the same blocker identified in the Phase E handoff v2.

---

## 4. The Core Remaining Challenge: Fragment-to-Int Transfer

### 4.1 What the Completeness Proof Actually Needs

The downstream completeness proof (`Representation.lean`) constructs:
- `canonicalFrame : TaskFrame Int` -- requires Int as the time type
- `canonicalHistory : WorldHistory (canonicalFrame B)` -- requires `states : Int -> WorldState`
- `shiftClosedCanonicalOmega` -- requires `time_shift` which uses `AddCommGroup`

The `valid` definition quantifies over `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. To prove completeness, we must produce a model over SOME such D. The standard choice is D = Int.

### 4.2 The Transfer Problem, Precisely Stated

We have:
- `fragmentFMCS : FMCS (BidirectionalFragment M0 h_mcs0)` -- sorry-free, has forward_F/backward_P
- `BidirectionalQuotient M0 h_mcs0` has `LinearOrder` -- sorry-free
- Need: `FMCS Int` with forward_F/backward_P

The transfer requires an order-preserving surjection `f : Int -> BidirectionalFragment M0 h_mcs0` (or more precisely, a function whose range includes all F/P witnesses).

### 4.3 Why "Building a Chain" is the Natural Next Step

The user's insight points in exactly the right direction. Instead of trying to embed the (potentially uncountable) fragment into Int, we should **build a countable sub-chain of the fragment that is closed under F/P witnesses, then enumerate it as Int**.

This is the **monotone enumeration chain** approach (Solution Path E from research-003, Section 5):

1. Start with M0 as the root at position 0
2. Enumerate all F/P obligations: (t, phi) where F(phi) in chain(t) or P(phi) in chain(t)
3. For each obligation, use `fragmentFSucc` or the backward analog to place a witness
4. Use `bidirectional_totally_ordered` to determine where the witness fits in the chain
5. The chain grows, inserting new witnesses between existing elements

**The key insight from the user is that linearity tells us WHERE to insert**. Given existing chain elements c(0) < c(1) < ... < c(n) and a new witness W for F(phi) at c(k), the totality theorem tells us exactly where W fits in the chain: either W = c(j) for some j, or c(j) < W < c(j+1) for some j.

### 4.4 The Insertion-Based Chain Construction

Here is a concrete approach:

**Step 1**: Define a type `GrowingChain` as a finite increasing sequence of BidirectionalFragment elements.

**Step 2**: Define an `insert_witness` operation that, given F(phi) at some chain element c(k):
- Compute W = fragmentFSucc c(k) phi
- Use totality to find where W belongs in the chain
- Insert W at the correct position

**Step 3**: Enumerate all F/P obligations using a Cantor-pairing-like scheme:
- Obligations are pairs (n, phi) where n is a chain position and phi is a formula
- Formulas are countable (inductive type), so obligations are countable

**Step 4**: Process obligations one at a time, growing the chain at each step.

**Step 5**: The limit of this process is a countable linear chain closed under F/P witnesses.

**Step 6**: Index the final chain by Int (negative for past witnesses, positive for future witnesses, or use any bijection from the chain to Int).

### 4.5 Critical Technical Detail: Strictness

The fragment's `Preorder` is NOT antisymmetric. Two distinct MCSes M1, M2 can satisfy both CanonicalR M1 M2 and CanonicalR M2 M1 (i.e., GContent(M1) = GContent(M2) while M1 != M2).

The `Antisymmetrization` quotient collapses these. But the FMCS over the quotient loses information: if M1 and M2 are in the same equivalence class, the FMCS can only assign ONE MCS to that time point, but both M1 and M2 may be needed as witnesses for different obligations.

**Resolution**: Work with the fragment directly (before quotienting). The FMCS uses `BidirectionalFragment` elements, not quotient classes. The `Preorder` is total. Since we use `<=` (not `<`) for forward_G/backward_H and `>=`/`<=` for forward_F/backward_P, the non-antisymmetric Preorder is fine for all temporal coherence properties.

When building the chain `f : Int -> BidirectionalFragment`, we can simply assign multiple "equal" positions in the preorder to consecutive integers. The FMCS properties hold because:
- `forward_G`: G(phi) in f(t).world, t <= t' implies f(t) <= f(t') (order-preserving), so phi in f(t').world
- `forward_F`: F(phi) in f(t).world implies exists witness W in fragment with f(t) <= W and phi in W.world. Since the chain is closed under witnesses, W = f(s) for some s >= t.

### 4.6 An Even Simpler Alternative: Direct Fragment BFMCS

Actually, there is a possibility that avoids the Int embedding entirely:

**Observation**: The `satisfiable` definition requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The `BFMCS` structure requires `[Preorder D]`. The `Representation.lean` module specifically targets `D = Int`.

But what if we proved satisfiability using a DIFFERENT D? Specifically:

Could we define a **countable linearly ordered additive abelian group** from the fragment?

The answer is no in general: the fragment has no natural additive structure. Adding two MCSes does not produce a third MCS. The group structure on Int is essential for time shifts.

### 4.7 The Controlled Insertion Construction (Recommended)

Combining the user's insight with the existing infrastructure, the recommended approach is:

**Phase E-revised: Controlled Insertion into Int**

1. **Enumerate F/P obligations**: Use a bijection `Nat -> (Nat x Formula)` to enumerate all potential obligations. At each step, check if the obligation is actually active (F(phi) in some chain element).

2. **Maintain a growing partial function** `chain : Finset Int -> BidirectionalFragment M0 h_mcs0` that is order-preserving (i <= j in the finset implies chain(i) <= chain(j) in the fragment).

3. **For each active obligation**: compute the witness (via `forward_F_stays_in_fragment` or `backward_P_stays_in_fragment`), use totality to find its position relative to existing chain elements, insert at a fresh Int position between existing elements (this is always possible because Int is discrete but we can leave gaps).

4. **Key invariant**: the chain uses positions {..., -3, -1, 0, 1, 3, 5, ...} (leaving even positions as gaps for future insertions). This is a standard technique for building order-preserving maps into Int from a step-by-step construction.

5. **After omega steps**: the limit is a partial function `chain : Int -> BidirectionalFragment` that is:
   - Order-preserving
   - Closed under F/P witnesses of elements in its range
   - Has M0 at position 0 with all of Gamma in M0

6. **Extend to total function**: For positions not in the chain's range, assign the nearest chain element (or M0). The forward_G/backward_H properties still hold because the chain is order-preserving and the fill values are monotone.

7. **Define FMCS Int**: `mcs(t) = chain(t).world` with forward_G/backward_H from order-preservation and forward_F/backward_P from the closure property.

**Why this works**: The linearity axioms ensure that at each insertion step, the witness has a well-defined position relative to all existing chain elements. The existing sorry-free infrastructure (`forward_F_stays_in_fragment`, `backward_P_stays_in_fragment`, `bidirectional_totally_ordered`) provides all the needed lemmas.

**Why it avoids F-persistence**: We never build a chain via GContent seeds. Instead, each witness is placed directly from the fragment-level construction. The fragment's `forward_F_stays_in_fragment` gives us the witness; totality tells us where it goes.

---

## 5. Comparison with Failed Approaches

| Property | DovetailingChain | Direct Linearization |
|----------|-----------------|---------------------|
| Chain topology | GContent propagation | Fragment element insertion |
| Witness placement | Process at encoding step | Insert when obligation discovered |
| F-persistence issue | Fatal (Lindenbaum kills F-formulas) | Non-issue (witnesses are fragment elements) |
| Ordering source | CanonicalR between consecutive elements | `bidirectional_totally_ordered` (proven) |
| forward_F proof | BLOCKED (F not in GContent) | From `forward_F_stays_in_fragment` + closure |
| backward_P proof | BLOCKED (P not in HContent) | From `backward_P_stays_in_fragment` + closure |
| GContent transfer | By chain construction | By order-preservation of chain function |

The fundamental difference: the DovetailingChain builds NEW MCSes at each step via Lindenbaum extension, which can destroy F-formulas. The Direct Linearization approach uses EXISTING fragment MCSes (which are already sorry-free) and merely ORDERS them using linearity.

---

## 6. Technical Implementation Plan

### 6.1 Phase E-revised: Countable Closure + Int Embedding

**Step 1: Define the Countable Closure**

```lean
-- A countable sub-fragment closed under F/P witnesses
-- Built by starting from a root and iteratively adding witnesses
inductive FPClosure (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    BidirectionalFragment M0 h_mcs0 -> Prop where
  | root : FPClosure M0 h_mcs0 (BidirectionalFragment.root)
  | fwd_witness {w : BidirectionalFragment M0 h_mcs0} {phi : Formula}
      (h_mem : FPClosure M0 h_mcs0 w)
      (h_F : Formula.some_future phi in w.world) :
      FPClosure M0 h_mcs0 (fragmentFSucc w phi h_F)
  -- (+ backward analog)
```

**Step 2: Prove FPClosure is countable**

The FPClosure is generated from a countable set (formulas) by a countable inductive process. Each step adds one element, and there are countably many (position, formula) pairs.

**Step 3: Prove FPClosure elements are totally ordered**

Inherited from `bidirectional_totally_ordered` since FPClosure is a subset of BidirectionalFragment.

**Step 4: Construct the embedding**

A countable total order embeds into Int. For a discrete order (which this likely is, since each step adds one element), a direct enumeration suffices. For a non-discrete order, use Mathlib's order embedding infrastructure.

**Step 5: Define FMCS Int**

Pull back the fragment FMCS along the embedding. Forward_F and backward_P transfer because the FPClosure is closed under witnesses.

### 6.2 Key Lemmas Needed

1. **`FPClosure_forward_F_closed`**: If `w` is in FPClosure and `F(phi) in w.world`, then the F-witness for phi is also in FPClosure.

2. **`FPClosure_backward_P_closed`**: Symmetric.

3. **`FPClosure_countable`**: The FPClosure is countable.

4. **`FPClosure_enumeration`**: There exists an order-preserving surjection from Int onto FPClosure (or a cofinal/coinitial subset).

5. **`pullback_forward_F`**: Given the enumeration `f : Int -> FPClosure`, if `F(phi) in f(t).world`, then there exists `s >= t` with `phi in f(s).world`.

6. **`pullback_backward_P`**: Symmetric.

### 6.3 Existing Infrastructure to Leverage

All sorry-free:
- `fragmentFMCS` (CanonicalCompleteness.lean line 72)
- `fragmentFMCS_forward_F` (line 90)
- `fragmentFMCS_backward_P` (line 104)
- `fragmentFSucc` (line 266) + `fragmentFSucc_contains_witness` (line 279) + `fragmentFSucc_le` (line 291)
- `enriched_seed_consistent_from_F` (line 197)
- `enriched_seed_consistent_from_P` (line 224)
- `bidirectional_totally_ordered` (BidirectionalReachable.lean line 728)
- `fragment_le_total` (line 756)
- `instLinearOrderBidirectionalQuotient` (line 784)
- `witness_seed_consistent` (line 142)

---

## 7. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Countable enumeration of FPClosure is complex | Medium | Medium | Use Mathlib's Set.Countable, Set.enumerateCountable |
| Int embedding for non-dense order is subtle | Medium | Medium | The order is likely discrete (each element added one at a time); direct bijection with Z suffices |
| Filling gaps in the chain function breaks forward_G | Medium | High | Use constant-filling (repeat the nearest element); monotonicity of CanonicalR + reflexivity handles this |
| FPClosure is not closed under ALL F/P obligations (only "reachable" ones) | Low | High | The inductive construction ensures closure: each obligation generates a new element, which may generate new obligations, all handled |
| Multi-witness obligations require more than pairwise linearity | Low | Low | Each witness is placed independently; pairwise comparability (from totality) is sufficient |
| BFMCS modal saturation requires separate constructions per diamond witness | Medium | Medium | Each diamond witness gets its own bidirectional fragment + FPClosure + embedding. Proven sorry-free infrastructure applies uniformly. |

---

## 8. Concrete Next Steps

### Step 1: Define FPClosure (4-6 hours)
- Add inductive type `FPClosure` in CanonicalCompleteness.lean
- Prove closure under F/P witnesses
- Prove countability

### Step 2: Prove totality of FPClosure (2-3 hours)
- Follows directly from `bidirectional_totally_ordered` restricted to FPClosure elements

### Step 3: Construct Int embedding (6-10 hours)
- Build a bijection from the countable total order to Int
- This is the most technically challenging step
- Consider using Mathlib's `Set.enumerateCountable` or building a custom enumeration
- Alternative: avoid explicit embedding by defining a Nat-indexed sequence and mapping positive naturals to future positions, negative to past positions

### Step 4: Define FMCS Int and prove properties (4-6 hours)
- Pull back fragment FMCS along the embedding
- Forward_G/backward_H from order-preservation
- Forward_F/backward_P from FPClosure closure + totality

### Step 5: Build BFMCS Int (6-8 hours)
- Eval family from Step 4
- Diamond witness families: for each diamond obligation, construct a separate FPClosure + embedding
- Modal saturation from `box_witness_seed_consistent` (proven in CanonicalCompleteness.lean)
- Eliminate `fully_saturated_bfmcs_exists_int` sorry

### Total: 22-33 hours (significantly less than the 43-64 hour estimate for the original Phase E-H approach)

---

## 9. Decisions

1. **The user's insight is correct**: linearity axioms determine witness placement, and this avoids the F-persistence problem.

2. **The existing infrastructure already captures this**: `bidirectional_totally_ordered` and the fragment FMCS are the formal embodiment of "direct linearization."

3. **The remaining gap is purely about embedding into Int**: the fragment-level FMCS is sorry-free; we need a countable closure + enumeration.

4. **Recommended approach**: FPClosure (countable closure under F/P witnesses) + order-preserving bijection to Int.

5. **This supersedes the old Phase E approach**: no need for "controlled Lindenbaum" or "Zorn on chains." The fragment already provides everything.

---

## 10. Open Questions

1. **Is FPClosure discrete or dense?** If fragments can contain MCSes with infinitely many elements between them (under the preorder), the closure may not be discrete. This affects the choice of embedding strategy.

2. **Can we avoid Antisymmetrization?** Working directly with the Preorder (not quotienting) may be simpler. If f : Int -> FPClosure is just order-preserving (not strictly monotone), forward_G/backward_H still hold.

3. **What is the right formalization of "grows to cover all obligations"?** The FPClosure is inductively defined, but we need all obligations to be eventually witnessed. An omega-indexed construction (analogous to DovetailingChain but with fragment elements instead of Lindenbaum extensions) may be needed.

4. **Is there a Mathlib theorem for "countable total preorder embeds into Int"?** This would simplify Step 3 significantly.
