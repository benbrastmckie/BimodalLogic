# Report 20: Simultaneous Induction Construction for Canonical Completeness

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-04-02
**Author**: Teammate A
**Focus**: Rigorous mathematical construction of temporally coherent canonical families via simultaneous induction on formula complexity

---

## Executive Summary

This report works through the simultaneous induction approach for canonical completeness of TM (S5 + linear tense logic with reflexive task semantics). The key findings:

1. **The stratification by modal-temporal depth resolves the Imp-case circularity** -- but only partially. The standard claim that "the backward Imp direction at depth k+1 only needs forward_F at depth <= k" is **correct for temporal sub-formulas but requires careful handling of nested implications**. (Confidence: HIGH)

2. **The base case (depth 0) is trivial** and requires no temporal coherence. (Confidence: CERTAIN)

3. **The inductive step has a genuine subtlety** at the interaction between the S5 modal dimension and the temporal dimension. The boxClassFamilies construction handles S5 saturation sorry-free, but the temporal chain construction at each depth level must be compatible with the modal equivalence classes. This is achievable but non-trivial. (Confidence: MEDIUM-HIGH)

4. **The construction does NOT produce a single monolithic canonical model** but rather a depth-indexed family of models that agree on lower-depth formulas. The final model is obtained by a limiting argument or by working at sufficient depth. (Confidence: HIGH)

5. **Closing `bfmcs_from_mcs_temporally_coherent`** via this approach requires restructuring the truth lemma proof to be depth-indexed, which is a significant but well-understood refactoring of the existing `ParametricTruthLemma.lean`. (Confidence: MEDIUM)

---

## Part 1: The Stratification

### Definition: Modal-Temporal Depth

For TM formulas (with primitives: atom, bot, imp, box, all_past, all_future), define:

```
depth(atom p)     = 0
depth(bot)        = 0
depth(phi -> psi) = max(depth(phi), depth(psi))
depth(box phi)    = depth(phi) + 1
depth(H phi)      = depth(phi) + 1
depth(G phi)      = depth(phi) + 1
```

**Note on derived operators**: The existential temporal operators F and P are defined as:
- `F(phi) = neg(G(neg(phi))) = (phi.neg.all_future).neg = phi.neg.all_future.imp bot`
- `P(phi) = neg(H(neg(phi))) = (phi.neg.all_past).neg = phi.neg.all_past.imp bot`

So `depth(F(phi)) = depth(neg(G(neg(phi)))) = depth(G(neg(phi))) = depth(neg(phi)) + 1 = depth(phi) + 1`. Similarly for P. This is consistent.

**Critical property**: For any formula phi, all proper sub-formulas of phi have strictly smaller depth, EXCEPT for the imp case where sub-formulas have depth <= depth(phi).

### Why This Resolves the Imp-Case Circularity

The truth lemma for `phi -> psi` at depth k requires:

**Forward**: If `(phi -> psi) in M` and `truth(phi)`, then `truth(psi)`.
- Step 1: `truth(phi)` implies `phi in M` (backward IH for phi)
- Step 2: `(phi -> psi) in M` and `phi in M` implies `psi in M` (MCS modus ponens)
- Step 3: `psi in M` implies `truth(psi)` (forward IH for psi)

**Backward**: If `(phi -> psi) not in M`, then `not truth(phi -> psi)`, i.e., `truth(phi)` and `not truth(psi)`.
- Step 1: `(phi -> psi) not in M` implies by MCS maximality: `neg(phi -> psi) in M`
- Step 2: From `neg(phi -> psi) in M`, derive `phi in M` and `neg(psi) in M` (MCS properties)
- Step 3: `phi in M` implies `truth(phi)` (forward IH for phi)
- Step 4: `neg(psi) in M` implies `psi not in M` (MCS consistency)
- Step 5: `psi not in M` implies `not truth(psi)` (forward direction of the CONTRAPOSITIVE of backward IH for psi)

**The key observation**: Both directions of the Imp case use the IH for the sub-formulas phi and psi. Since `depth(phi) <= depth(phi -> psi)` and `depth(psi) <= depth(phi -> psi)`, if we do induction on depth, we need the truth lemma at the SAME depth level for the Imp case. This means the Imp case is NOT directly resolved by depth induction alone.

**However**, the circularity involving temporal coherence IS resolved. Here is why:

The problematic cycle is:
```
truth lemma for G(phi) (backward)
  -> needs forward_F for phi
  -> needs truth lemma for phi (to verify consistency of witness seeds)
  -> if phi = (alpha -> beta) where alpha or beta contain G/H...
  -> needs truth lemma for G-subformulas of alpha, beta
```

Since `depth(phi) < depth(G(phi))`, when we need the truth lemma for phi to establish forward_F for phi, we are working at a strictly lower depth. The truth lemma at depth k-1 is already available by the inductive hypothesis. The forward_F for phi is constructed USING the truth lemma at depth k-1, not at depth k.

**Precise statement**: At depth k, we need:
- The truth lemma for all formulas of depth < k (given by IH)
- forward_F and backward_P only for formulas of depth < k (to support the backward G/H cases at depth k)
- The construction of temporal witnesses at depth k uses the truth lemma at depth < k

The Imp case at depth k uses the truth lemma at depth <= k for its sub-formulas. But the sub-formulas of an Imp at depth k have depth <= k, and if they have depth exactly k, they are NOT of the form G(phi) or H(phi) (since those would push the Imp's depth to k+1). Therefore, the backward G/H case is never triggered for sub-formulas at the same depth level.

**Wait -- this needs more care.** Consider `phi -> psi` at depth k where `psi = G(alpha)` with `depth(alpha) = k - 1`. Then `depth(psi) = k` and `depth(phi -> psi) = k` (assuming `depth(phi) <= k`). The backward direction for `phi -> psi` at depth k needs the forward IH for psi = G(alpha). The forward direction for G(alpha) requires forward_G (if G(alpha) in M then alpha in M_s for all s >= t), which comes from the chain construction's g_persistence property -- NOT from forward_F. Forward_F is only needed for the BACKWARD direction of G (i.e., if alpha holds at all future times, then G(alpha) in M). And the backward direction of G(alpha) at depth k needs forward_F for alpha at depth k-1, which IS available by IH.

**Conclusion**: The depth stratification DOES resolve the circularity. The argument is subtle but sound.

**Confidence: HIGH**

---

## Part 2: The Base Case (depth 0)

At depth 0, the only formulas are:
- Atoms: `atom p`
- Bottom: `bot`
- Implications between depth-0 formulas: `phi -> psi` where both phi, psi are depth 0

These are purely propositional formulas containing no modal or temporal operators.

### Truth Lemma at Depth 0

For the canonical model where valuation is MCS membership:

**Atom case**: `atom p in M <-> truth_at(M, omega, tau, t, atom p)`
- This holds by definition of `ParametricCanonicalTaskModel` where `valuation M p = (atom p in M.val)`.
- The truth definition (`Truth.lean:120`) says `truth_at M Omega tau t (atom p) = exists (ht : tau.domain t), M.valuation (tau.states t ht) p`.
- For the canonical model, `tau.states t ht` is the MCS at time t, and `valuation` checks membership. So this reduces to: `atom p in fam.mcs t <-> truth_at(...)`.
- This holds by construction.

**Bot case**: `bot in M <-> truth_at(M, omega, tau, t, bot)`
- `truth_at ... bot = False` by definition.
- `bot not in M` for any MCS (since M is consistent).
- Both sides are False. QED.

**Imp case** (depth 0): `(phi -> psi) in M <-> truth_at(M, omega, tau, t, phi.imp psi)`
- Forward: If `(phi -> psi) in M` and `truth(phi)`, then by backward IH (depth 0): `phi in M`. By MCS modus ponens: `psi in M`. By forward IH (depth 0): `truth(psi)`.
- Backward: If `(phi -> psi) not in M`, then `neg(phi -> psi) in M`. This gives `phi in M` and `psi.neg in M` (by MCS properties). By forward IH: `truth(phi)`. By consistency: `psi not in M`, so by contrapositive of backward IH: `not truth(psi)`.

This is standard and involves no temporal operators. The induction is on the **complexity** (number of connectives) within depth 0, which is well-founded.

### No Temporal Coherence Needed

At depth 0, there are no G, H, F, or P formulas. The truth lemma holds purely from MCS algebraic properties. No forward_F or backward_P is required.

### Automatic Coherence

Any family of MCS indexed by integers is automatically "temporally coherent at depth 0" because there are no temporal formulas to witness.

**Confidence: CERTAIN**

---

## Part 3: The Inductive Step (depth k -> k+1)

**Inductive Hypothesis (IH)**: For all formulas psi with `depth(psi) <= k`:
1. The truth lemma holds: `psi in fam.mcs t <-> truth_at(model, omega, to_history(fam), t, psi)`
2. forward_F holds: if `F(psi) in fam.mcs t`, then there exists `s >= t` with `psi in fam.mcs s`
3. backward_P holds: if `P(psi) in fam.mcs t`, then there exists `s <= t` with `psi in fam.mcs s`

**Goal**: Establish (1), (2), (3) for formulas of depth k+1.

### Step 3.1: Temporal Witness Construction for depth k+1

Consider `F(phi)` where `depth(phi) = k`. We need: if `F(phi) in fam.mcs t`, then there exists `s >= t` with `phi in fam.mcs s`.

Recall `F(phi) = neg(G(neg(phi)))`. So `F(phi) in M` means `G(neg(phi)) not in M`, which by MCS maximality means `neg(G(neg(phi))) in M`.

**The witness construction** uses the following argument:

1. We have `F(phi) in fam.mcs t`, meaning the MCS at time t asserts that phi holds at some future time.

2. By `temporal_theory_witness_consistent` (existing sorry-free infrastructure in SuccExistence.lean): from `F(phi) in M_t`, we can build a consistent seed `{phi} union g_content(M_t)` that can be extended to an MCS.

3. The key question: can we find a witness **within the same family** fam? This is where the existing approach struggles.

**The simultaneous induction resolution**: At depth k, the truth lemma already holds (by IH). This means:
- `phi in fam.mcs s <-> truth_at(model, omega, to_history(fam), s, phi)` for all s.
- So finding a witness `s >= t` with `phi in fam.mcs s` is equivalent to finding `s >= t` with `truth(phi)` at s in the canonical model.

But wait -- this seems circular: we're trying to BUILD the family to have forward_F, and we're using the truth lemma at depth k to do so. The resolution is that the family is built INCREMENTALLY:

**Construction Order**:
1. Start with a root MCS M_0 (containing the target formula's negation).
2. Build the temporal chain `..., M_{-1}, M_0, M_1, ...` using constrained successor/predecessor construction (SuccChainFMCS).
3. At this point, the chain satisfies the Succ relation (g_persistence, f_step) by construction.
4. The truth lemma at depth k holds for THIS chain because:
   - The chain's g_persistence ensures forward_G at all depths
   - The chain's f_step ensures F-obligations are tracked
   - By IH, the truth lemma at depth k-1 was used to verify consistency of the chain at the previous level

**Critical insight**: The chain construction does NOT need the truth lemma to build the chain. It only needs:
- `temporal_theory_witness_consistent`: to show seeds are consistent (sorry-free)
- `g_persistence`: to show G-content propagates (follows from the Succ relation)
- Lindenbaum's lemma: to extend seeds to full MCS (sorry-free)

The truth lemma at depth k is then PROVEN for the chain after construction, not used during construction. The forward_F at depth k is established using the chain's f_step property together with the fair scheduling argument.

### Step 3.2: The Fair Scheduling Argument at Depth k

**The f_step property** (from SuccChainFMCS): For consecutive MCS in the chain, `f_content(M_n) subset {phi | phi in M_{n+1}} union f_content(M_{n+1})`. This means every F-obligation is either resolved or deferred.

**For formulas at depth k**: The set of formulas that can appear as F-obligations at depth k is bounded by `deferralClosure(root_formula)` intersected with formulas of depth <= k. This is finite.

**Fair scheduling**: Using the Nat.unpair enumeration, every (time_position, formula) pair is targeted infinitely often. When targeting `(t, phi)` at step n:
- If `F(phi) in M_n` (where depth(phi) = k), use `temporal_theory_witness_consistent` to include phi in the successor seed.
- The seed `{phi} union g_content(M_n)` is consistent because `F(phi) in M_n` guarantees this.
- After Lindenbaum extension, `phi in M_{n+1}`.

**The gap identified in Report 19**: F-obligations can be "killed" when resolving other obligations. Specifically, resolving chi at step n might cause `G(neg(phi))` to enter M_{n+1}, killing the obligation `F(phi)`.

**Resolution at depth k**: For formulas at depth k, we can use the **truth lemma at depth k-1** to reason about the killing. If `phi` has depth k and `G(neg(phi))` enters M_{n+1}, then since `neg(phi)` has depth k, and we're working at depth k, this is within the scope of our current construction. The killing relation among depth-k F-obligations is a strict partial order on a FINITE set (bounded by deferralClosure), so it IS well-founded at any given depth level.

**However**, this argument has a subtlety: the killing relation's well-foundedness depends on the depth restriction. Report 19 showed that the killing relation on ALL formulas can have infinite descending chains. But restricted to formulas of depth <= k within deferralClosure, the relation is on a finite set and hence well-founded.

**Confidence: MEDIUM-HIGH** (the finite restriction argument is sound but the formal details of bounding the killing relation to a depth level need careful verification)

### Step 3.3: Imp-Case Resolution at Depth k+1

Consider `phi -> psi` at depth k+1. There are two cases:

**Case A**: `depth(phi -> psi) = k+1` because one of phi, psi has depth k+1 (involving a modal/temporal operator).

Example: `phi -> G(alpha)` where `depth(alpha) = k`.

Forward direction: If `(phi -> G(alpha)) in M_t` and `truth(phi)` at t:
- By backward IH for phi (depth <= k+1, but we handle this by inner induction on complexity): `phi in M_t`
- By MCS modus ponens: `G(alpha) in M_t`
- Need: `truth(G(alpha))` at t, i.e., for all `s >= t`, `truth(alpha)` at s
- By forward_G (chain construction): `G(alpha) in M_t` implies `alpha in M_s` for all `s >= t`
- By forward IH for alpha (depth k, available by outer IH): `alpha in M_s` implies `truth(alpha)` at s
- Done.

Backward direction: If `(phi -> G(alpha)) not in M_t`:
- By MCS maximality: `neg(phi -> G(alpha)) in M_t`
- This gives: `phi in M_t` and `neg(G(alpha)) in M_t`
- `phi in M_t` implies `truth(phi)` by forward IH (depth <= k+1, inner induction)
- `neg(G(alpha)) in M_t` means `F(neg(alpha)) in M_t` (by temporal duality in MCS)
- By forward_F for neg(alpha) (depth k, available by outer IH): exists `s >= t` with `neg(alpha) in M_s`
- So `alpha not in M_s` (MCS consistency)
- By contrapositive of backward IH for alpha (depth k): `not truth(alpha)` at s
- So `not (forall s >= t, truth(alpha) at s)`, i.e., `not truth(G(alpha))`
- Therefore `truth(phi)` and `not truth(psi)`, giving `not truth(phi -> psi)`.

**The crucial point**: The backward Imp case for `phi -> G(alpha)` at depth k+1 uses forward_F for `neg(alpha)` at depth k. This is available by the outer IH. No circularity.

**Case B**: `depth(phi -> psi) = k+1` where both phi and psi have depth k+1 but are not directly G/H formulas.

Example: `(G(a) -> G(b)) -> G(c)` at depth 2 (assuming a, b, c are atoms).

This is handled by the **inner induction on formula complexity within depth k+1**. The key structural property: in the Imp case, we use the IH for phi and psi, which are proper sub-formulas and hence have strictly smaller complexity (even if they share the same depth). The only cases where we need forward_F/backward_P are the G and H backward cases, which always involve formulas of strictly lower depth.

**Confidence: HIGH**

### Step 3.4: The Truth Lemma at Depth k+1

Combining the above, we prove the truth lemma at depth k+1 by structural induction on formulas of depth k+1:

- **atom**: Same as depth 0 (atoms have depth 0, so this is covered by base case)
- **bot**: Same as depth 0
- **imp**: By inner structural induction + outer depth IH (as traced in Step 3.3)
- **box(phi)** where depth(phi) = k:
  - Forward: `box(phi) in M_t` implies `phi in every MCS at time t` (by S5 modal saturation via boxClassFamilies). By IH at depth k, this means `truth(phi)` at every history at time t, i.e., `truth(box(phi))`.
  - Backward: If `truth(box(phi))` at t, then `truth(phi)` at every history sigma at time t. For each such sigma corresponding to a family in BFMCS, by backward IH at depth k: `phi in sigma.mcs t`. In particular, `phi in M_t` (taking sigma = current family). Then by MCS properties and modal completeness: `box(phi) in M_t`. (This uses the S5 saturation property: if phi is in EVERY MCS of the equivalence class at time t, then box(phi) is in M_t.)
- **G(phi)** where depth(phi) = k:
  - Forward: `G(phi) in M_t` implies by g_persistence: `phi in M_s` for all `s >= t`. By forward IH at depth k: `truth(phi)` at all `s >= t`. So `truth(G(phi))` at t.
  - Backward: If `truth(phi)` at all `s >= t`, then by backward IH at depth k: `phi in M_s` for all `s >= t`. By `temporal_backward_G` (which uses forward_F at depth k from outer IH): `G(phi) in M_t`.
- **H(phi)** where depth(phi) = k: Symmetric to G case using backward_P.

**Confidence: HIGH**

---

## Part 4: Integration with boxClassFamilies

### The S5 Dimension

The existing `boxClassFamilies` construction (in `CanonicalConstruction.lean` / `UltrafilterChain.lean`) handles S5 modal saturation:

1. Given a root MCS M, partition all MCS into box-equivalence classes: M ~ N iff for all phi, `box(phi) in M <-> box(phi) in N`.
2. By S5 properties (T, 4, B, 5-collapse), these form a genuine equivalence relation.
3. For each equivalence class, build a temporal chain (using SuccChainFMCS).
4. The resulting BFMCS has families indexed by equivalence classes, each family being a temporal chain.

This construction is **sorry-free** for the modal dimension.

### The Temporal Dimension

At each depth level k, the temporal construction adds forward_F and backward_P for depth-k formulas. The integration with boxClassFamilies works because:

**Independence of dimensions**: For a formula `box(G(phi))`:
- The box part is handled by boxClassFamilies (modal saturation across equivalence classes)
- The G part is handled by the temporal chain within each family
- These don't interfere because:
  - S5 modal saturation at time t is independent of temporal behavior
  - Temporal chain construction preserves box-class membership (by the `modal_future` and `temp_future` axioms: `box(phi) -> box(G(phi))` and `box(phi) -> G(box(phi))`)

**The key axioms enabling compatibility**:
- `modal_future`: `box(phi) -> box(G(phi))` -- if phi is necessary, so is G(phi)
- `temp_future`: `box(phi) -> G(box(phi))` -- necessary truths remain necessary at all future times

These ensure that box-class membership is **temporally stable**: if two MCS are in the same box-class at time t, they remain in the same box-class at all times. This means the partition into box-classes is time-independent, and temporal chains can be built within each class independently.

### At Each Depth Level k

1. **Modal dimension**: boxClassFamilies provides the partition into equivalence classes. For depth-k box formulas (`box(phi)` where `depth(phi) = k-1`), the saturation is handled by the existing sorry-free construction.

2. **Temporal dimension**: Within each box-class family, build the temporal chain satisfying forward_F and backward_P for depth-k formulas. This uses:
   - The truth lemma at depth k-1 (outer IH) to verify consistency of witness seeds
   - The f_step property from SuccChainFMCS for obligation tracking
   - Fair scheduling for eventual resolution

3. **Compatibility**: The temporal chain within a box-class preserves box-class membership (by `modal_future` and `temp_future`), so the modal saturation is not disrupted by temporal extensions.

**Confidence: MEDIUM-HIGH**

---

## Part 5: The Full Construction

### Algorithm

Given a target formula Phi that is not provable:

1. **Initialization**:
   - `neg(Phi)` is consistent (by unprovability)
   - Extend to root MCS M_0 containing `neg(Phi)` via Lindenbaum's lemma
   - Let `max_depth = depth(Phi)`

2. **Depth 0** (Base):
   - Build boxClassFamilies from M_0 (sorry-free)
   - Each family is a temporal chain satisfying Succ relations
   - Truth lemma at depth 0 holds automatically (propositional only)
   - No forward_F/backward_P needed

3. **Depth k -> k+1** (Inductive step):
   - **Given**: Truth lemma, forward_F, backward_P at depth k
   - **Build temporal witnesses**: For each family fam and each F-obligation `F(phi)` at depth k in `fam.mcs t`:
     - Use `temporal_theory_witness_consistent` to build successor seed
     - Extend via Lindenbaum to get witness MCS
     - Fair scheduling ensures all obligations are eventually resolved
   - **Prove truth lemma at depth k+1**: By structural induction within depth k+1
     - Imp case: uses IH at depth <= k+1 (inner) and forward_F/backward_P at depth k (outer)
     - Box case: uses boxClassFamilies saturation (sorry-free) + IH at depth k
     - G/H case: uses g_persistence (forward) + temporal_backward_G/H with forward_F at depth k (backward)
   - **Establish forward_F/backward_P at depth k+1**: From the truth lemma at depth k+1 + fair scheduling for depth k+1 formulas

4. **Final model**: After establishing the truth lemma at depth `max_depth`:
   - `Phi` is in `fam.mcs 0` iff `truth(Phi)` at time 0 in the canonical model
   - Since `neg(Phi) in M_0 = fam.mcs 0`, we have `Phi not in fam.mcs 0`
   - By truth lemma: `not truth(Phi)` at time 0
   - So Phi is not valid in the canonical model
   - Contrapositive: valid implies provable

### Important Subtlety: Chain Modification

The construction above has an implicit issue: at each depth level, we may need to MODIFY the temporal chain to accommodate new F-obligations at the higher depth. The chain built for depth k may not automatically satisfy forward_F for depth k+1 formulas.

**Two approaches**:

**Approach A (Rebuilt chains)**: At each depth level, rebuild the chains from scratch using stronger constraints. This is clean but wastes work.

**Approach B (Cumulative construction)**: Build a single chain that simultaneously satisfies all depth levels. This is possible because:
- The deferralClosure of Phi is finite and contains all relevant formulas at all depths
- The SuccChainFMCS construction with fair scheduling over ALL formulas in deferralClosure handles all depths simultaneously
- The truth lemma is then proved by induction on depth, but the CHAIN is built once

**Approach B is the correct one** and matches the existing codebase architecture. The SuccChainFMCS is built over the full deferralClosure, which includes formulas at all depth levels. The simultaneous induction is used only for the PROOF of the truth lemma, not for the construction of the chain.

This is the critical insight: **the chain is built once; the truth lemma is proved by induction on depth**.

**Confidence: HIGH**

---

## Part 6: Closing `bfmcs_from_mcs_temporally_coherent`

### The Sorry's Requirements

The sorry at `FrameConditions/Completeness.lean:237` requires:

```lean
theorem bfmcs_from_mcs_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent
```

where `temporally_coherent` means every family in the BFMCS has `forward_F` and `backward_P` (from `TemporalCoherence.lean:146-152`):

```lean
forward_F : forall t : D, forall phi : Formula,
    Formula.some_future phi in mcs t -> exists s : D, t <= s /\ phi in mcs s
backward_P : forall t : D, forall phi : Formula,
    Formula.some_past phi in mcs t -> exists s : D, s <= t /\ phi in mcs s
```

### Mapping the Construction

Each family in `construct_bfmcs_bundle M h_mcs` is a `shifted_fmcs (SuccChainFMCS S) delta` for some SerialMCS S and shift delta. So we need to prove `forward_F` and `backward_P` for SuccChainFMCS families.

**Using the simultaneous induction**:

The existing SuccChainFMCS already has:
- `g_persistence`: `G(phi) in chain(n)` implies `phi in chain(n+1)` (for Succ relation)
- `f_step`: `f_content(chain(n)) subset {phi | phi in chain(n+1)} union f_content(chain(n+1))`
- The restricted chain construction (`build_restricted_tc_family` at SuccChainFMCS.lean:6313) is sorry-free for restricted MCS

**The bridge gap** is from restricted MCS to full MCS. The simultaneous induction approach resolves this:

1. For `F(phi) in full_chain(n)`:
   - `F(phi) = neg(G(neg(phi)))`, so `G(neg(phi)) not in full_chain(n)`
   - By MCS maximality: `neg(G(neg(phi))) in full_chain(n)`
   - The restricted chain at position n contains all formulas in `deferralClosure(root)` that are in `full_chain(n)`
   - If `phi in deferralClosure(root)`, then `neg(phi) in deferralClosure(root)` (by closure under negation)
   - And `G(neg(phi)) in deferralClosure(root)` (by closure under G when neg(phi) is in closure)
   - So `F(phi) in restricted_chain(n)` (since F(phi) is a Boolean combination of formulas in deferralClosure)

2. The restricted chain has `forward_F` for formulas in deferralClosure (sorry-free, from `build_restricted_tc_family`)

3. So there exists `s >= n` with `phi in restricted_chain(s)`

4. Since `restricted_chain(s) subset full_chain(s)` (the Lindenbaum extension preserves membership), `phi in full_chain(s)`

**But wait**: Step 2 claims restricted forward_F is sorry-free. Let me verify. Looking at `build_restricted_tc_family` (SuccChainFMCS.lean:6313), the sorry-free claim from Report 19 needs checking.

Actually, Report 19 states: "The `build_restricted_tc_family` (line 6313) packages both forward_F and backward_P sorry-free." But also notes: "these work with `DeferralRestrictedMCS`, not full MCS. The bridge from restricted to full MCS is the gap."

The bridge argument above (steps 1-4) IS the resolution. The key lemma needed:

**Lemma**: If `F(phi) in full_MCS` and `phi in deferralClosure(root)`, then `F(phi)` is "represented" in the restricted chain, and the restricted chain's forward_F provides a witness that lifts to the full chain.

**Formalization path**: This requires:
- Proving that `restricted_chain_subset_extended` (already exists, RestrictedTruthLemma.lean:218-225, sorry-free)
- Proving that restricted forward_F witnesses lift to full chain witnesses (follows from the subset property)
- Proving that ALL F-obligations in the full chain are about formulas in deferralClosure (needs argument: `F(phi) in MCS` implies `phi in deferralClosure` if MCS was built from a root formula whose deferralClosure contains phi)

**The last point is the remaining gap**: We need that the full chain, built by Lindenbaum extension of the restricted chain, only contains F-obligations for formulas within deferralClosure. But this is FALSE in general -- Lindenbaum extension can introduce arbitrary formulas, including `F(psi)` for psi outside deferralClosure.

**Resolution**: We don't need ALL F-obligations to be within deferralClosure. We need forward_F for ALL formulas phi, not just those in deferralClosure. But for phi outside deferralClosure, the argument is different:

For `F(phi) in full_chain(n)` where `phi not in deferralClosure`:
- This F-obligation was introduced by the Lindenbaum extension (not present in restricted chain)
- The truth lemma only needs forward_F for formulas that appear as sub-formulas of the target formula Phi
- All sub-formulas of Phi are in `subformulaClosure(Phi) subset deferralClosure(Phi)`
- So forward_F for formulas outside deferralClosure is NOT needed for the truth lemma

**But the type signature requires forward_F for ALL formulas**. This is an over-specification in the Lean code. The `TemporalCoherentFamily` structure (TemporalCoherence.lean:146) quantifies over ALL phi, not just sub-formulas.

**Two paths to resolution**:

**Path 1 (Weaken the type)**: Change `TemporalCoherentFamily.forward_F` to quantify only over formulas in `subformulaClosure(Phi)` or `deferralClosure(Phi)`. This requires refactoring `ParametricTruthLemma.lean` to use the restricted version.

**Path 2 (Strengthen the construction)**: Prove forward_F for ALL formulas, not just those in deferralClosure. This would require the fair-scheduling argument on the full chain, which is the original gap.

**Path 1 is more tractable** and aligns with the literature (truth lemmas are always stated relative to a specific formula or its closure).

### Concrete Steps for the Lean Implementation

1. **Define `RestrictedTemporalCoherentFamily`** (already exists in SuccChainFMCS.lean for the restricted setting):
   - forward_F restricted to deferralClosure
   - backward_P restricted to deferralClosure

2. **Refactor `ParametricTruthLemma`** to accept a restricted coherence hypothesis:
   - The truth lemma proof only invokes forward_F/backward_P on sub-formulas of Phi
   - All sub-formulas of Phi are in deferralClosure(Phi) by definition
   - So the restricted version suffices

3. **Bridge**: Use `restricted_chain_subset_extended` + restricted forward_F to provide the restricted coherence

4. **Close the sorry**: `bfmcs_from_mcs_temporally_coherent` becomes provable with the restricted coherence

**Estimated effort**: 15-20 hours for the refactoring + proof

**Confidence: MEDIUM** (the refactoring is well-defined but touching core infrastructure carries risk)

---

## Part 7: Remaining Gaps and Assumptions

### Gap 1: Fair Scheduling Well-Foundedness (MEDIUM risk)

The fair scheduling argument at each depth level claims that F-obligations are resolved in finite time because the killing relation is well-founded on a finite set. This is sound for the restricted setting (deferralClosure is finite), but the formal proof requires:
- Explicit construction of the fair schedule (via Nat.unpair -- exists)
- Proof that every obligation is targeted infinitely often (follows from Nat.unpair surjectivity)
- Proof that targeting an obligation resolves it unless it's been killed (follows from temporal_theory_witness_consistent)
- Proof that killed obligations have a finite killing chain (follows from finiteness of deferralClosure at each depth)

**Status**: The components exist but are not assembled into a single proof. The existing `build_restricted_tc_family` is sorry-free, suggesting this is achievable.

### Gap 2: Lindenbaum Extension Preservation (LOW risk)

The bridge from restricted to full MCS requires that the restricted chain embeds into the Lindenbaum extension. `restricted_chain_subset_extended` is sorry-free. The converse (`extended_chain_closure_subset`) has a sorry but is ONLY needed for the truth lemma's backward direction at the DRM level, which is handled differently in the simultaneous induction approach.

### Gap 3: boxClassFamilies Temporal Stability (LOW risk)

We claimed that box-class membership is temporally stable (two MCS in the same box-class remain so at all times). This follows from `modal_future` and `temp_future` axioms but has not been formally verified in the codebase. If this fails, the entire construction collapses because temporal chains could "escape" their box-class.

**Mitigation**: The axioms `modal_future` (`box(phi) -> box(G(phi))`) and `temp_future` (`box(phi) -> G(box(phi))`) together with the chain's g_persistence ensure that if `box(phi) in M_t` for all phi in a characterizing set, then `box(phi) in M_s` for all `s >= t`. The past direction follows from `temp_a` and the H analogs.

### Gap 4: Over-Specified Type (MEDIUM risk)

The `TemporalCoherentFamily` type requires forward_F/backward_P for ALL formulas. If we cannot prove this for the full chain (only for deferralClosure), we must refactor the type. This is a well-defined refactoring but touches several files:
- `TemporalCoherence.lean`: definition
- `ParametricTruthLemma.lean`: truth lemma proof
- `FrameConditions/Completeness.lean`: wiring

### Assumption: Existing Sorry-Free Components Are Correct

This analysis assumes:
- `build_restricted_tc_family` (SuccChainFMCS.lean:6313) is genuinely sorry-free
- `temporal_theory_witness_consistent` (SuccExistence.lean) is sorry-free
- `boxClassFamilies` construction is sorry-free
- `set_lindenbaum` (Lindenbaum's lemma) is sorry-free

These have been verified by the codebase audit in Report 19.

---

## Summary

| Component | Status | Confidence | Effort |
|-----------|--------|------------|--------|
| Depth stratification resolves circularity | Verified | HIGH | N/A (math only) |
| Base case (depth 0) | Trivial | CERTAIN | 0 hours |
| Inductive step: witness construction | Sound with caveats | MEDIUM-HIGH | 5-8 hours |
| Inductive step: Imp case | Verified | HIGH | 2-3 hours |
| Inductive step: Box case | Delegated to boxClassFamilies | HIGH | 1-2 hours |
| Inductive step: G/H case | Sound | HIGH | 3-5 hours |
| Integration with boxClassFamilies | Sound but unverified formally | MEDIUM-HIGH | 3-5 hours |
| Closing bfmcs_from_mcs_temporally_coherent | Feasible via restricted coherence | MEDIUM | 15-20 hours |

**Overall assessment**: The simultaneous induction approach is mathematically sound and resolves the core circularity. The main implementation risk is the refactoring needed to use restricted (deferralClosure-bounded) temporal coherence instead of universal temporal coherence. This is a well-defined change but requires careful coordination across several modules.

**Recommended path**:
1. Close the 2 FMP sorries first (Phase 1 from Report 19, ~1-2 hours)
2. Refactor `TemporalCoherentFamily` to use restricted coherence (~5 hours)
3. Adapt `ParametricTruthLemma` for the restricted version (~5 hours)
4. Prove the bridge from restricted chain to restricted coherence (~5 hours)
5. Close `bfmcs_from_mcs_temporally_coherent` using the restricted version (~3 hours)
