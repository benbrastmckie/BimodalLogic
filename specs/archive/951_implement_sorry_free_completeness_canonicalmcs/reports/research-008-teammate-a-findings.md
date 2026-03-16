# Research Report: Task #951 (research-008, Teammate A) -- MCS Subsets as Times and the Task Relation

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-28
**Focus**: Syntactic reconstruction approach -- Can constrained MCS subsets serve as "times"? What is the task relation?
**Dependencies**: research-004 through research-007, phases A-D completed, phase E blocked
**Sources/Inputs**: TaskFrame.lean, Validity.lean, CanonicalFMCS.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean, CanonicalChain.lean, TemporalCoherentConstruction.lean, CanonicalFrame.lean, FMCSDef.lean, TruthLemma.lean, DovetailingChain.lean
**Artifacts**: This report

---

## 1. Executive Summary

This report investigates whether constrained subsets of all MCSes can serve as "times" in a sorry-free completeness proof, and how the task relation should be defined from pure syntax. The analysis identifies the BidirectionalFragment as the correct MCS subset, confirms that the CanonicalR preorder provides the temporal ordering, and proposes a concrete approach for defining the task relation.

**Key Findings:**

- The BidirectionalFragment is the right MCS subset for "times" -- it has total preorder (proven), and its Antisymmetrization quotient has LinearOrder (proven)
- The CanonicalR preorder IS the temporal ordering -- it directly encodes the GContent inclusion that drives forward_G/backward_H coherence
- The task relation should be defined as the reflexive transitive closure of CanonicalR on the fragment, making nullity (reflexivity) and compositionality (transitivity) trivial
- The fundamental Phase E blocker is NOT the temporal structure -- it is the mismatch between `valid`'s requirement for `AddCommGroup D` and the BidirectionalQuotient's lack of additive structure
- Two viable resolution paths exist: (A) weaken `valid` to remove `AddCommGroup`, or (B) add a discreteness axiom and embed into `Int`

**Confidence Level:** HIGH for structural analysis; MEDIUM for resolution paths (each has verified trade-offs)

---

## 2. MCS Subsets as Times: Which Subsets Work?

### 2.1 The Full CanonicalMCS Collection

The type `CanonicalMCS` (`CanonicalFMCS.lean:77-81`) wraps ALL maximal consistent sets:

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
```

With the CanonicalR preorder (`CanonicalFMCS.lean:93-96`):
- `a <= b` iff `CanonicalR a.world b.world` iff `GContent(a.world) ⊆ b.world`
- Reflexive (via T-axiom: `G(phi) -> phi`)
- Transitive (via Temporal 4: `G(phi) -> G(G(phi))`)

**Problem:** The full CanonicalMCS preorder is NOT total. Two MCSes from completely different logical "branches" may be incomparable under CanonicalR. Totality only holds within connected fragments.

### 2.2 The BidirectionalFragment: The Right Subset

The `BidirectionalFragment M0 h_mcs0` (`BidirectionalReachable.lean:119-125`) restricts to MCSes reachable from a root `M0` by finite sequences of CanonicalR edges in either direction:

```lean
structure BidirectionalFragment (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  reachable : BidirectionalReachable M0 h_mcs0 world is_mcs
```

**Key proven properties (all sorry-free):**

1. **Total preorder** (`BidirectionalReachable.lean:768`):
   ```lean
   instance : IsTotal (BidirectionalFragment M0 h_mcs0) (. <= .) where
     total := fragment_le_total
   ```

2. **Forward_F closure** (`BidirectionalReachable.lean:195-204`): If `F(phi) in w.world` for a fragment element `w`, there exists `s` in the fragment with `w <= s` and `phi in s.world`.

3. **Backward_P closure** (`BidirectionalReachable.lean:214-228`): Symmetric for past.

4. **LinearOrder on quotient** (`BidirectionalReachable.lean:784-795`): The Antisymmetrization `BidirectionalQuotient` has a full `LinearOrder` instance.

### 2.3 Why BidirectionalFragment is Suitable as "Times"

The BidirectionalFragment satisfies the essential properties needed for times in the completeness proof:

| Property | Status | Location |
|----------|--------|----------|
| Total preorder | PROVEN | `BidirectionalReachable.lean:768` |
| Forward_F witnesses exist | PROVEN | `BidirectionalReachable.lean:195-204` |
| Backward_P witnesses exist | PROVEN | `BidirectionalReachable.lean:214-228` |
| Forward_G coherence | PROVEN | `CanonicalCompleteness.lean:76-78` |
| Backward_H coherence | PROVEN | `CanonicalCompleteness.lean:79-81` |
| LinearOrder (quotient) | PROVEN | `BidirectionalReachable.lean:784-795` |
| Nonempty | PROVEN | `BidirectionalReachable.lean:145-146` |
| Contains root | PROVEN | `BidirectionalReachable.lean:140-143` |

---

## 3. The CanonicalR Preorder as Temporal Structure

### 3.1 How CanonicalR Relates to Temporal Ordering

`CanonicalR M M'` is defined as `GContent M ⊆ M'` (`CanonicalFrame.lean:63-64`), meaning: for all `phi`, if `G(phi) in M` then `phi in M'`. This exactly encodes the future temporal direction:

- If `M` is "earlier" than `M'`, then everything that is always-future-true at `M` should be true at `M'`
- This is precisely the `forward_G` coherence condition of FMCS

The dual `CanonicalR_past M M'` = `HContent M ⊆ M'` encodes the past direction.

**Critical duality** (used extensively): `CanonicalR M M'` for MCSes implies `CanonicalR_past M' M` and vice versa, via `GContent_subset_implies_HContent_reverse`. This means the single ordering `CanonicalR` captures BOTH temporal directions.

### 3.2 GContent Ordering as a Measure of "Time"

GContent(M) = `{phi | G(phi) in M}` measures "how much the MCS commits to the future." Two MCSes are CanonicalR-related when one's future commitments are a subset of the other's world.

The relationship to temporal ordering is:
- **Larger GContent** = "earlier" time (more G-formulas, stronger future commitments)
- **Smaller GContent** = "later" time (fewer G-formulas, weaker future commitments)

This is because as we move forward in time, `G(phi)` formulas get "consumed" -- `G(phi)` gives us `phi` at the current time but the formula `G(phi)` itself may no longer hold unless `G(G(phi))` held at the earlier time (which it does by the Temporal 4 axiom `G(phi) -> G(G(phi))`).

### 3.3 Why the BidirectionalQuotient Quotients Correctly

Two fragment elements `a, b` are identified in the quotient when both `a <= b` and `b <= a`, i.e., `CanonicalR a.world b.world` and `CanonicalR b.world a.world`. This means `GContent(a) ⊆ b` and `GContent(b) ⊆ a`, so the two MCSes agree on all G-formulas. They represent the "same time" from a temporal perspective.

---

## 4. The Task Relation: Definition from Pure Syntax

### 4.1 What the Task Relation Must Satisfy

From `TaskFrame.lean:84-103`, the task relation `task_rel : WorldState -> D -> WorldState -> Prop` must satisfy:

1. **Nullity**: `task_rel w 0 w` -- zero-duration task is identity
2. **Compositionality**: `task_rel w x u /\ task_rel u y v -> task_rel w (x+y) v`

### 4.2 How to Define It From Syntax

For the canonical model construction, the task relation should connect world states (which are BFMCS families) via temporal stepping. In the BidirectionalFragment approach:

- **World states** = FMCS families in the BFMCS (as in the current approach)
- **Times** = elements of the BidirectionalFragment (or its quotient)
- **Task relation**: `task_rel fam1 t fam2` iff for all `phi`, `phi in fam1.mcs 0` implies `phi in fam2.mcs t` (or the appropriate transfer condition)

However, the simpler approach, which avoids the complexity of BFMCS entirely, is:

**Direct fragment-based task relation:**
```
task_rel w d w' := (the ordering) w' is exactly the element at "distance d" from w
```

Since the fragment is totally ordered, "distance" makes sense: `task_rel w d w'` iff `w'` is the element satisfying the fragment ordering at the right position.

But this hits the Phase E blocker: `D` needs to be a time type with `AddCommGroup` structure, and the fragment has no natural addition.

### 4.3 The Fundamental Issue: Addition on Times

The task relation requires that `D` (the time type) support `+`, which enters through compositionality: `task_rel w (x+y) v`. The BidirectionalQuotient has `LinearOrder` but NOT `AddCommGroup`:

- There is no canonical way to "add" two CanonicalR-equivalence classes
- The quotient has no natural zero element beyond the root
- Addition would need to satisfy `a + b = b + a` (commutativity) which has no MCS justification

**This is the same Phase E blocker identified in research-006 and research-007.**

---

## 5. Viable Resolution Paths

### 5.1 Path A: Use BidirectionalFragment Directly as D (Weaken `valid`)

**Approach:** Change the `valid` definition to not require `AddCommGroup D`. Instead quantify over types with just `LinearOrder D` (or `Preorder D`).

**Impact on soundness:** This requires verifying which axioms need `AddCommGroup`:
- `nullity` uses `0` from `AddCommGroup` -- needs `Zero D` at minimum
- `compositionality` uses `+` from `AddCommGroup` -- needs `Add D`
- The MF/TF axioms (shift-closed Omega) use shift operations `tau + d` which need `Add D`

**Assessment:** As research-007 concluded, this requires significant rework (soundness proofs for MF, TF axioms depend on `AddCommGroup`). Estimated 40-60 hours.

### 5.2 Path B: Add Discreteness Axiom, Embed into Int

**Approach:** Add a discreteness axiom to the logic that forces the temporal order to have successor/predecessor functions. Combined with linearity and the existing axioms, this forces D to be order-isomorphic to `Int`. Then use the existing `Int`-based infrastructure.

**Mathlib support:** `LinearOrderedAddCommGroup.isAddCyclic_iff_nonempty_equiv_int` and `orderIsoIntOfLinearSuccPredArch` provide the machinery to show that a discrete, linear, archimedean ordered abelian group is isomorphic to `Int`.

**Assessment:** As research-007 concluded, this is the preferred approach. Estimated 15-20 hours. Preserves all existing soundness proofs.

### 5.3 Path C: Syntactic Reconstruction (NEW -- this report's focus)

**Approach:** Instead of embedding the BidirectionalQuotient into `Int`, reconstruct the entire completeness proof to use the BidirectionalFragment DIRECTLY as the time type, building the task relation purely from syntactic structure.

**How it would work:**
1. Define `TaskFrame (BidirectionalFragment M0 h_mcs0)` where the preorder serves as both time and world state ordering
2. The task relation would be trivial: `task_rel w t w' := w' = (some function of w and t)`
3. But this requires `AddCommGroup (BidirectionalFragment M0 h_mcs0)` which does NOT exist

**Assessment:** This path ultimately reduces to the same Phase E blocker. The BidirectionalFragment has no additive group structure, and fabricating one would break the connection to the MCS ordering.

### 5.4 Path D: Bypass TaskFrame Entirely

**Approach:** Prove completeness directly without going through `TaskFrame`. Define `truth_at` directly using the fragment FMCS, bypassing the semantic framework.

**How it would work:**
1. The fragment FMCS already provides `mcs : BidirectionalFragment -> Set Formula`
2. Truth for `G(phi)` at fragment element `w` = `phi in mcs(s)` for all `s >= w` (already proven)
3. Truth for `F(phi)` at `w` = exists `s >= w` with `phi in mcs(s)` (already proven)
4. The truth lemma `bmcs_truth_lemma` already works for any `D` with `Preorder D` and `Zero D`
5. Completeness = consistent context is satisfiable = has a model where all formulas are true

**The key insight:** Completeness actually says "if `Gamma` is consistent, then `Gamma` is NOT derivable to contradiction." The contrapositive is: "if `Gamma |= phi`, then `Gamma |- phi`." To prove this, we need:

- If `Gamma |- phi` is NOT derivable, find a model where `Gamma` is true but `phi` is false
- This model uses the canonical construction with BidirectionalFragment as time

**The problem:** The found model must be a model in the sense of `valid`, which requires `AddCommGroup D`. We cannot bypass this without changing `valid`.

---

## 6. Detailed Analysis: What Properties Make MCS Subsets Suitable as Times?

### 6.1 Essential Properties (All Proven for BidirectionalFragment)

1. **Total preorder**: Elements must be linearly comparable. This is essential because time is linear in TM logic (no branching).

2. **Forward/backward witness closure**: If `F(phi)` (resp. `P(phi)`) holds at a time, there must exist a later (resp. earlier) time where `phi` holds. This is essential for the truth lemma.

3. **Nonemptiness with root**: There must be a distinguished element (time 0) where the input context holds.

4. **G/H coherence**: If `G(phi)` holds at time `t`, then `phi` holds at all `t' >= t` (and symmetrically for `H`).

### 6.2 Additional Property Needed But Not Present

5. **Additive group structure**: The `valid` definition requires `AddCommGroup D` with `IsOrderedAddMonoid D`. This provides:
   - Zero element (time 0)
   - Addition (temporal composition: task of duration `x` followed by task of duration `y` = task of duration `x + y`)
   - Negation (past = negative of future)
   - Commutativity (temporal addition is order-independent)

The BidirectionalFragment has property (1-4) but NOT (5). This is the fundamental gap.

### 6.3 Can the Gap Be Bridged?

**Option 1: Define addition on the fragment.** Given two fragment elements `a, b`, define `a + b` as... what? There is no canonical way to combine two CanonicalR-equivalence classes additively. The CanonicalR preorder is NOT translation-invariant (adding an element doesn't shift all others uniformly).

**Option 2: Embed into a type with addition.** Map the fragment into `Int` (or `Rat`/`Real`) via an order-preserving injection. The enriched canonical chain (`CanonicalChain.lean`) already does this -- it maps `Int -> CanonicalMCS` in an order-preserving way. But the map from `Int` through the chain back to MCSes is what the DovetailingChain approach uses, and it has the 2 sorries for forward_F/backward_P.

**Option 3: The enriched chain (`CanonicalChain.lean`) resolves the forward_F/backward_P.** The `enrichedForwardStep` and `enrichedBackwardStep` place witness formulas in the chain, and the witness placement is proven (`enrichedForwardStep_witness_placed`, `enrichedBackwardStep_witness_placed`). What remains unproven is the "eventually processed" argument: every F-obligation from every position is eventually decoded and processed.

---

## 7. The Enriched Canonical Chain: Almost There

### 7.1 What Exists

`CanonicalChain.lean` provides:

- `enrichedForwardStep` / `enrichedBackwardStep`: Chain construction with witness placement
- `enrichedForwardStep_ordered` / `enrichedBackwardStep_ordered`: CanonicalR ordering (PROVEN)
- `enrichedForwardStep_witness_placed` / `enrichedBackwardStep_witness_placed`: If `decodeFormula(n) = phi` and `F(phi) in chain(n)`, then `phi in chain(n+1)` (PROVEN)
- `buildEnrichedCanonicalChain`: Full Z-indexed chain (PROVEN)
- Diagonal enumeration surjectivity (PROVEN)

### 7.2 What's Missing for forward_F/backward_P

To prove `forward_F` for the enriched chain FMCS, we need:

**Claim:** For all `t : Int` and `phi : Formula`, if `F(phi) in chain(t)`, then there exists `s > t` with `phi in chain(s)`.

**Proof sketch:**
1. By surjectivity of `decodeFormula`, there exists `n_phi : Nat` with `decodeFormula(n_phi) = phi`
2. At step `n_phi` of the forward chain, the enriched construction checks if `F(phi) in chain(n_phi)`
3. If yes, `phi` is placed in `chain(n_phi + 1)` -- done
4. If no (`F(phi) not in chain(n_phi)`), we need to show that `F(phi)` is NOT in the chain at position `t` either, which is FALSE in general

**The gap:** Step (4) fails because `F(phi)` might be in `chain(t)` but NOT in `chain(n_phi)` (if `t > n_phi` or if `t < 0`). The diagonal enumeration processes obligation `(t, phi)` at a specific step, not at position `t` itself. The enriched chain checks the formula at the CURRENT chain position, not at position `t`.

### 7.3 How to Close the Gap

The enriched chain processes the obligation `(n, phi)` at step `n`, meaning it checks `F(phi) in chain(n)`. To handle `F(phi) in chain(t)` for arbitrary `t`, we need:

**Key property (G-persistence of F):** If `F(phi) in chain(t)` and `t <= s`, does `F(phi) in chain(s)` hold?

Answer: **In general, NO.** This is the fundamental F-persistence problem identified in research-007 and the DovetailingChain analysis. `F(phi) = neg(G(neg(phi)))`. When we extend via Lindenbaum, the new MCS might contain `G(neg(phi))`, killing `F(phi)`.

**However:** The enriched chain uses `{phi} union GContent(prev)` as seed when `F(phi)` is alive. This means `phi in chain(n+1)`. But `phi in chain(s)` for `s > n+1` is NOT guaranteed (phi might not persist through GContent propagation either).

**Resolution:** The diagonal enumeration must process obligations from ALL positions, not just the current one. The `decodePosFormula` function (`CanonicalChain.lean:512-516`) already decodes `(position, formula)` pairs. The enriched chain should check `F(phi) in chain(pos)` rather than `F(phi) in chain(n)`. Since `chain(pos)` is fixed once constructed, this check is well-defined for `pos <= n`.

This is the omega-squared construction approach referenced in DovetailingChain.lean line 1862.

---

## 8. Recommended Approach

### 8.1 Immediate Path: Fix Enriched Chain Forward_F/Backward_P

The enriched canonical chain in `CanonicalChain.lean` is the closest to a sorry-free `FMCS Int`. The remaining gap is the forward_F/backward_P proofs. The fix requires:

1. **Modify `enrichedForwardStep`** to use the diagonal `(position, formula)` decoding, checking `F(phi) in chain(pos)` for the decoded position `pos` (when `pos <= n`)
2. **Prove forward_F** by showing: for any `t >= 0` and `phi`, if `F(phi) in chain(t)`, then at step `k = encodePosFormula t phi`, the obligation is processed and `phi in chain(k+1)`
3. **Handle negative positions** symmetrically via the backward chain

### 8.2 Combine with Modal Saturation

Once the enriched chain FMCS is sorry-free for forward_F/backward_P, it can replace the DovetailingChain in `TemporalCoherentConstruction.lean:497-506`, eliminating the 2 sorry-backed lemmas. The remaining sorry at line 600 (`fully_saturated_bfmcs_exists_int`) combines temporal coherence with modal saturation.

### 8.3 The AddCommGroup Question

Even with a sorry-free `FMCS Int`, we still need `Int` as the time type (which has `AddCommGroup`). The enriched chain approach gives us exactly this -- the chain is `Int`-indexed. No change to `valid` is needed.

The alternative MCS-as-times approach (using BidirectionalFragment directly) hits the AddCommGroup wall and should NOT be pursued.

---

## 9. Evidence: Verified Lemma Names

All lemma names verified via `lean_local_search` and file reading:

| Lemma | File | Status |
|-------|------|--------|
| `canonicalR_reflexive` | CanonicalFrame.lean:180 | PROVEN |
| `canonicalR_transitive` | CanonicalFrame.lean:217 | PROVEN |
| `canonical_forward_F` | CanonicalFrame.lean:122 | PROVEN |
| `canonical_backward_P` | CanonicalFrame.lean:151 | PROVEN |
| `GContent_subset_implies_HContent_reverse` | (imported) | PROVEN |
| `HContent_subset_implies_GContent_reverse` | (imported) | PROVEN |
| `bidirectional_totally_ordered` | BidirectionalReachable.lean:728 | PROVEN |
| `fragment_le_total` | BidirectionalReachable.lean:756 | PROVEN |
| `instLinearOrderBidirectionalQuotient` | BidirectionalReachable.lean:784 | PROVEN |
| `fragmentFMCS` | CanonicalCompleteness.lean:72 | PROVEN |
| `fragmentFMCS_forward_F` | CanonicalCompleteness.lean:90 | PROVEN |
| `fragmentFMCS_backward_P` | CanonicalCompleteness.lean:104 | PROVEN |
| `enrichedForwardStep_ordered` | CanonicalChain.lean:633 | PROVEN |
| `enrichedForwardStep_witness_placed` | CanonicalChain.lean:657 | PROVEN |
| `enrichedBackwardStep_ordered` | CanonicalChain.lean:734 | PROVEN |
| `enrichedBackwardStep_witness_placed` | CanonicalChain.lean:747 | PROVEN |
| `decodePosFormula_encodePosFormula` | CanonicalChain.lean:527 | PROVEN |
| `bmcs_truth_lemma` | TruthLemma.lean:260 | PROVEN (no sorry) |
| `buildDovetailingChainFamily_forward_F` | DovetailingChain.lean:1865 | SORRY |
| `buildDovetailingChainFamily_backward_P` | DovetailingChain.lean:1877 | SORRY |
| `fully_saturated_bfmcs_exists_int` | TemporalCoherentConstruction.lean:580 | SORRY |

---

## 10. Summary and Conclusions

### 10.1 MCS Subsets as Times

The BidirectionalFragment IS the right MCS subset for times. It has total preorder, forward/backward witness closure, and G/H coherence -- all proven sorry-free. Its Antisymmetrization quotient has LinearOrder. However, it lacks `AddCommGroup`, making it unsuitable as a DIRECT time type for the current `valid` definition.

### 10.2 The Task Relation

For the Int-indexed approach (enriched canonical chain), the task relation is inherited from the standard BFMCS construction: `task_rel fam1 d fam2` iff `fam2` is the family reached by a d-duration task from `fam1`. The chain's CanonicalR ordering provides the temporal backbone.

For a hypothetical fragment-based approach, the task relation would be the preorder relation itself, but this cannot be formalized without AddCommGroup on the fragment.

### 10.3 Recommendation

**Do NOT pursue MCS subsets as a direct replacement for the time type.** The AddCommGroup requirement is fundamental to the task semantics.

**DO pursue the enriched canonical chain approach:** Fix the forward_F/backward_P proofs using omega-squared diagonal processing (checking obligations at decoded positions, not current positions). This gives a sorry-free `FMCS Int`, which slots directly into the existing completeness architecture.

The 3 sorry locations can be reduced as follows:
1. `buildDovetailingChainFamily_forward_F` -- replaced by enriched chain forward_F
2. `buildDovetailingChainFamily_backward_P` -- replaced by enriched chain backward_P
3. `fully_saturated_bfmcs_exists_int` -- requires combining enriched chain temporal coherence with modal saturation (separate challenge)
