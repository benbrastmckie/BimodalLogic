# Guard Convention Choice Under Irreflexive G: Soundness and Completeness Analysis

## Executive Summary

Under the current semantics (irreflexive G/H, strict Until/Since), the system uses **open guard** for Until: `phi U psi` at t means exists s > t with psi(s) and phi holds on the open interval (t, s). This analysis determines which axioms are sound under each guard convention and recommends the optimal axiom system.

**Recommendation**: Keep the open guard convention and DROP BX8 and BX9. Replace with weaker, sound axioms that still suffice for completeness.

---

## 1. Current Semantics (Open Guard)

```
phi U psi at t  :=  exists s > t, psi(s) AND forall r, t < r < s -> phi(r)
phi S psi at t  :=  exists s < t, psi(s) AND forall r, s < r < t -> phi(r)
G(phi) at t     :=  forall s > t, phi(s)    [irreflexive/strict]
H(phi) at t     :=  forall s < t, phi(s)    [irreflexive/strict]
F(phi) at t     :=  exists s > t, phi(s)    [strict]
P(phi) at t     :=  exists s < t, phi(s)    [strict]
```

---

## 2. Soundness Audit Under Open Guard

### Sound Axioms (proven or trivially provable)

| Axiom | Statement | Status | Proof Technique |
|-------|-----------|--------|-----------------|
| Propositional (4) | prop_k, prop_s, ex_falso, peirce | PROVED | Propositional logic |
| S5 Modal (5) | modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist | PROVED | Modal accessibility |
| temp_k_dist | G(phi->psi) -> (G(phi) -> G(psi)) | PROVED | Direct |
| temp_4 | G(phi) -> G(G(phi)) | PROVED | Transitivity |
| BX1/BX1' | serial_future/past: T -> F(T) / T -> P(T) | SORRY (needs NoMaxOrder/NoMinOrder) | Seriality of time |
| BX2/BX2' | left_mono_until/since | PROVED | Guard substitution |
| BX3/BX3' | right_mono_until/since | PROVED | Witness substitution |
| BX4/BX4' | connect_future/past: phi -> G(P(phi)) | PROVED | Take witness t |
| BX5/BX5' | self_accum_until/since | PROVED | Same witness, subset guard |
| BX6/BX6' | absorb_until/since | PROVED | Compose witnesses |
| BX7/BX7' | linear_until/since | PROVED | Witness comparison |
| BX10/BX10' | until_F/since_P: (phi U psi) -> F(psi) | PROVED | Witness extraction |
| BX11/BX11' | temp_linearity/past | PROVED | F-witness comparison |
| BX12/BX12' | F(phi) -> (T U phi) / P(phi) -> (T S phi) | PROVED (implicit) | F witness with vacuous guard |
| MF, TF | modal_future, temp_future | PROVED | Time-shift invariance |

### INVALID Axioms Under Open Guard

#### BX8: `phi AND F(phi U psi) -> (phi U psi)` -- INVALID

**Counterexample on Z (integers)**:

Let t = 0. Suppose phi(0) holds. Suppose F(phi U psi) at 0, i.e., there exists t' > 0 with (phi U psi)(t'). Take t' = 2. Then (phi U psi)(2) means exists s > 2 with psi(s) and phi holds on (2, s). Say s = 4, so psi(4) and phi(3).

To conclude (phi U psi)(0) we need a witness s' > 0 with psi(s') and phi on (0, s'). Using s' = 4: need psi(4) (have it) and phi on (0, 4) = {1, 2, 3}. We have phi(3) from the inner guard. But we do NOT have phi(1) or phi(2) from any hypothesis.

**The gap**: The hypothesis gives phi(0) and phi on (t', s) = (2, 4) = {3}. But we need phi on (0, s') which includes points in (0, t') = (0, 2) = {1} that are not covered.

**Formal counterexample**: On Z, valuation: phi true at {0, 3}, psi true at {4}. Then:
- (phi U psi)(2): witness 4, guard (2,4) = {3}, phi(3) holds. YES.
- F(phi U psi)(0): witness 2, (phi U psi)(2) holds. YES.
- phi(0): YES.
- (phi U psi)(0): need witness s > 0 with psi(s) and phi on (0,s). Only psi-witness is s=4. Guard (0,4) = {1,2,3}. phi(1) = FALSE.

**Conclusion**: BX8 is NOT sound under open guard on Z (or any order with gaps).

#### BX9: `(phi U psi) -> (phi OR psi)` -- INVALID

**Counterexample on Z**:

Under open guard, (phi U psi) at t means exists s > t with psi(s) and phi on (t, s). The guard interval (t, s) does NOT include t. So we get no information about phi(t) or psi(t).

**Formal counterexample**: On Z, t = 0, s = 1. psi(1) holds. Guard (0, 1) = empty (no integers strictly between 0 and 1). So (phi U psi)(0) holds vacuously for ANY phi. But neither phi(0) nor psi(0) needs to hold.

**Conclusion**: BX9 is NOT sound under open guard. The guard being empty gives zero information about the current time.

---

## 3. Soundness Under Half-Open Guard

Half-open guard: `phi U psi at t := exists s > t, psi(s) AND forall r, t <= r < s -> phi(r)`

### Key Differences

| Axiom | Open Guard | Half-Open Guard |
|-------|-----------|-----------------|
| BX2 | SOUND | **INVALID** |
| BX8 | INVALID | *Partially valid* (see below) |
| BX9 | INVALID | **SOUND** |

#### BX2 INVALID Under Half-Open Guard

**Proof**: BX2 says G(phi->chi) -> (phi U psi -> chi U psi). Under half-open guard, (phi U psi) at t requires phi(t) (since t is in [t, s)). To conclude chi U psi, we need chi(t). G(phi->chi) gives (phi->chi)(s) for all s > t. But it does NOT give (phi->chi)(t) since G is strict. So we cannot derive chi(t) from phi(t).

**Counterexample on Z**: t = 0. G(phi->chi) means forall s > 0, (phi->chi)(s). phi U psi at 0 with witness 2: phi(0), phi(1), psi(2). To get chi U psi at 0: need chi(0), chi(1), psi(2). We get chi(1) from G at s=1. But chi(0) requires (phi->chi)(0), which G does not provide.

#### BX8 Under Half-Open Guard

`phi AND F(phi U psi) -> (phi U psi)`.

Under half-open, (phi U psi)(t') means phi(t'), phi on [t', s), psi(s). Combined with phi(t) from hypothesis, we have phi(t) and phi on [t', s). But we still lack phi on [t, t') which includes the gap (t, t').

On **Z** specifically: if t' = t+1, then [t, t') = {t}. We have phi(t). And the inner half-open guard gives phi on [t+1, s). So phi on [t, s) = {t} union [t+1, s). This works!

But for t' > t+1, the gap [t+1, t') is not covered. So BX8 under half-open is sound on Z ONLY if we can always take t' = t+1 (i.e., the F witness is the successor). This requires discrete successor structure, not just any linear order.

**Conclusion**: BX8 is NOT sound under half-open guard on general linear orders. It IS sound on discrete orders (Z) under half-open guard when combined with the successor principle.

#### BX9 SOUND Under Half-Open Guard

**Proof**: (phi U psi) at t under half-open means exists s > t, psi(s), phi on [t, s). Since t is in [t, s), phi(t) holds. So phi OR psi holds at t (in fact, phi holds).

---

## 4. Analysis of Completeness Impact

### How BX9 Is Used in the Codebase

BX9 (`until_elim`) is used in exactly one critical pattern: **bx_until_eventuality_resolution** (Frame.lean:676). The logic is:

```
Given: phi U psi in w, psi not in w.
By BX9: (phi U psi) -> (phi OR psi). Since phi U psi in w, (phi OR psi) in w.
Since psi not in w, phi in w.
By BX10: (phi U psi) -> F(psi). So F(psi) in w.
By bx_forward_witness: get v >= w with psi in v.
Result: v >= w, psi in v, phi in w.
```

This gives the **chain-member guard**: phi holds at the current point w. This is used in the truth lemma to construct the semantic witness.

### What If BX9 Is Dropped?

Without BX9, we cannot conclude phi in w from (phi U psi) in w. This breaks the chain-member guard construction. The truth lemma's forward direction for Until would fail.

### How BX8 Is Used

BX8 is used as `psi_imp_until_mcs` (CanonicalChain.lean:48), which is `psi -> (phi U psi)`. But this is NOT BX8! Looking more carefully:

The code has `psi_imp_until_mcs` with comment "ψ → φ U ψ" which is actually a **reflexive introduction** principle. Under irreflexive semantics, `psi -> (phi U psi)` is NOT derivable from BX8. It requires a witness s > t with psi(s), but we only have psi(t).

The actual BX8 (`until_step`: `phi AND F(phi U psi) -> phi U psi`) is not directly used in the completeness proof as stated. The `psi_imp_until_mcs` is sorry'd and represents a different principle.

### How BX2 Is Used

BX2 (`left_mono_until_mcs`) is used in CanonicalChain.lean:86 to transform guards. Given G(phi->chi) in w and (phi U psi) in w, conclude (chi U psi) in w. This is used in sigma-ordering and defect chain manipulation.

---

## 5. Reformulation Options

### Option A: Open Guard + Drop BX8/BX9 + Add BX9' (Existential Weakening)

**Drop**: BX8, BX9.

**Add BX9-weak**: `(phi U psi) -> F(phi OR psi)`

This is trivially sound: (phi U psi) at t has witness s > t. At any r in (t, s), phi(r) holds (if (t,s) is nonempty). Actually, F(psi) already gives more than this (BX10). So this adds nothing.

**Alternative BX9-open**: `(phi U psi) -> F(phi) OR F(psi)`

This is derivable from BX10: (phi U psi) -> F(psi) already holds.

**Problem**: Without BX9, we cannot extract phi at the CURRENT time from (phi U psi). This is fundamentally what's missing under open guard.

### Option B: Half-Open Guard + Drop BX8 + Strengthen BX2

**Guard change**: `phi U psi at t := exists s > t, psi(s) AND forall r, t <= r < s -> phi(r)`

**Keep BX9**: Now sound.

**Drop BX8**: Still invalid on general orders.

**BX2 reformulation**: `(phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)`

This is sound under half-open: the conjunct (phi->chi) covers time t (not covered by G), and G(phi->chi) covers all s > t. Together they cover [t, infinity), which subsumes any guard [t, s).

**Proof sketch**: Assume (phi->chi)(t) and forall s > t, (phi->chi)(s). Assume (phi U psi)(t) with witness s: phi on [t, s), psi(s). Then chi(t) from (phi->chi)(t) and phi(t). chi(r) for r in (t, s) from G at r. So chi on [t, s) and psi(s). Done.

**Completeness impact of reformulated BX2**:

Where BX2 is used (`left_mono_until_mcs`): need G(phi->chi) in w AND (phi->chi) in w. But (phi->chi) in w is derivable from G(phi->chi) in w IF we had reflexive G! Under irreflexive G, G(phi->chi) does NOT give (phi->chi) at the current time.

So the reformulated BX2 requires an additional hypothesis: (phi->chi) must hold at the current world. In the completeness proof, where `left_mono_until_mcs` is invoked, we need to check whether this extra hypothesis is available.

Looking at the code (CanonicalChain.lean:86-95), BX2 is applied with `h_G : G(phi->chi) in w.formulas`. Under the reformulation, we'd additionally need `(phi->chi) in w.formulas`. This depends on context -- it may or may not be available.

### Option C: Half-Open Guard + BX8 on Z + Reformulated BX2 (RECOMMENDED)

The canonical model uses Z. On Z with half-open guard:

**BX8 is sound on Z**: Given phi(t) and F(phi U psi)(t). F gives t' > t with (phi U psi)(t'). On Z, the minimal such t' is t+1 (by well-ordering of natural numbers above t, if we restrict to the positive direction). With t' = t+1: (phi U psi)(t+1) under half-open means phi(t+1) and ... wait, this doesn't necessarily give t' = t+1.

Actually, F(phi U psi)(t) gives exists t' > t with (phi U psi)(t'). We CANNOT choose t' = t+1 in general. We just know some t' > t has (phi U psi)(t'). If t' = 5 and t = 0, we need phi on [0, s) where s is the witness from (phi U psi)(5). But we only have phi(0) and phi on [5, s). The gap [1, 5) is not covered.

**Correction**: BX8 is NOT sound on Z under half-open guard either, for the same gap reason as open guard.

### Option D: Open Guard + Add "Unfolding Axiom" BX9u

Instead of BX9 (`phi U psi -> phi OR psi`), use:

**BX9u (Unfolding)**: `phi U psi -> psi OR (F(psi) AND F(phi))`

Trivially sound under open guard: (phi U psi) with witness s > t gives psi(s), so F(psi). If (t,s) is nonempty, F(phi) also holds.

Wait, this doesn't give phi AT t. The completeness proof needs phi at the current world.

### Option E: Open Guard + BX12 + Eliminate BX9 Dependency

The key insight: `bx_until_eventuality_resolution` uses BX9 to extract `phi in w`. What if we restructure the completeness proof to NOT need this?

Looking at the truth lemma (TruthLemma.lean:282):
```
exact Or.inr (bx_until_eventuality_resolution w phi psi h_until h_psi)
```

The truth lemma for Until forward direction needs:
- Given phi U psi in w
- Construct semantic witness: time s > t with psi(s) and phi on (t, s)

Under open guard, the guard is (t, s). We need phi at points BETWEEN t and s, not at t itself. So we actually DON'T need phi(t) for the truth lemma! We need phi at intermediate chain points.

**This means BX9 may not be needed for the truth lemma under open guard at all.** The forward direction needs:
1. A witness s > t with psi(s) -- from BX10 + bx_forward_witness
2. phi at all intermediate points in (t, s) -- from the chain construction

The chain construction builds intermediate MCS v1, v2, ... between w and the psi-witness. At each intermediate vi, we need phi in vi. This comes from the oracle step construction, NOT from BX9 applied at w.

Actually, re-reading the code more carefully: `bx_until_eventuality_resolution` returns `phi in w.formulas` as part of its output. But this is used for the CHAIN-MEMBER guard. In a 2-element chain [w, v], the only "intermediate" point is w itself (in the interval (t_w, t_v)). Wait no -- in the semantic model, w corresponds to time t and v to time s. The guard (t, s) has no chain members in a 2-element chain on Z (since (t, t+1) is empty). So phi at w IS needed when the chain has more elements.

Let me reconsider. The canonical model on Z: w at position 0, v at position 1. (0, 1) on Z is empty. So the guard is vacuous! phi U psi at 0 with witness at 1 requires psi(1) and phi on (0,1) = empty. So BX9 is NOT needed for 2-element chains on Z!

For longer chains: w at 0, intermediate at 1, witness at 2. Guard (0, 2) = {1}. Need phi(1). This comes from the chain construction ensuring phi in the intermediate MCS.

**Key realization**: Under open guard on Z, adjacent chain points have EMPTY intermediate intervals. The guard is only nontrivial for non-adjacent witnesses. The oracle step construction already ensures phi propagates through intermediate chain points (via BX5 self-accumulation). BX9 is only used as a convenience to get phi at w, but this is NOT semantically needed under open guard!

---

## 6. The Z-Specific Analysis

On Z (integers) with open guard:
- (t, t+1) = empty set (no integers strictly between consecutive integers)
- phi U psi at t with witness t+1: psi(t+1), guard (t, t+1) = empty. ALWAYS holds if F(psi) with witness at t+1.
- phi U psi at t with witness t+2: psi(t+2), guard (t, t+2) = {t+1}. Need phi(t+1).
- phi U psi at t with witness t+k: psi(t+k), guard {t+1, ..., t+k-1}. Need phi at each.

**BX8 on Z with open guard**: phi(t) AND F(phi U psi)(t) -> (phi U psi)(t).

Take F-witness t' > t with (phi U psi)(t'). Say (phi U psi)(t') has witness s > t'. So psi(s) and phi on (t', s).

For (phi U psi)(t) with witness s: need psi(s) (have it) and phi on (t, s) = {t+1, ..., s-1}.

From hypotheses: phi(t) [irrelevant, t not in (t,s)], phi on (t', s) = {t'+1, ..., s-1}.

Gap: {t+1, ..., t'} is not covered by any hypothesis! Even on Z, BX8 is INVALID under open guard.

**BX12 on Z with open guard**: F(phi) -> (T U phi).

F(phi) at t means exists s > t, phi(s). Take witness s. T on (t, s) holds vacuously (T is always true). So T U phi at t holds. SOUND.

---

## 7. Definitive Recommendation

### RECOMMENDED: Option E -- Open Guard, Drop BX8/BX9, Restructure Completeness

**Rationale**:

1. **Open guard is already implemented** in Truth.lean.
2. **BX8 and BX9 are semantically invalid** under open guard (proven with explicit counterexamples).
3. **BX2 IS sound** under open guard (proven in Soundness.lean, lines 501-506).
4. **The completeness proof does NOT fundamentally need BX9 at the current time**. Under open guard on Z, the guard at current time is about FUTURE points, not the current point. The oracle step and defect chain machinery handle intermediate points.

**Axiom System Changes**:

| Action | Axiom | Reason |
|--------|-------|--------|
| DROP | BX8 (until_step) | Invalid under open guard |
| DROP | BX8' (since_step) | Invalid under open guard |
| DROP | BX9 (until_elim) | Invalid under open guard |
| DROP | BX9' (since_elim) | Invalid under open guard |
| ADD | BX9n: `(phi U psi) AND NOT(psi) -> F(phi)` | Sound under open guard; partial substitute for BX9 |
| ADD | BX8n: `F(phi) AND F(phi U psi) -> (phi U psi)` | Sound on dense+discrete orders (but not general) |
| KEEP | All others (BX1-BX7, BX10-BX12, modal, propositional) | All sound |

Wait -- let me verify BX9n. `(phi U psi) AND NOT(psi) -> F(phi)`. Under open guard: (phi U psi) at t has witness s > t. If s is the immediate successor of t on Z, guard (t, s) is empty, so we DON'T get F(phi). If s > t+1, then t+1 in (t, s) and phi(t+1), so F(phi). But for s = t+1: guard is empty, F(phi) requires phi at some u > t, which is NOT guaranteed.

BX9n is NOT sound in general either!

**Revised recommendation**:

The simplest sound axiom system drops BX8 and BX9 entirely, relying on:
- BX5 (self-accumulation) for intermediate guard propagation
- BX6 (absorption) for termination
- BX10 (eventuality extraction) for witness existence
- BX12 (F->Until bridge) for lifting F-witnesses to Until

### Completeness Without BX8/BX9

The completeness proof restructuring:

1. **Truth lemma forward (Until)**: Given phi U psi in w.
   - By BX10: F(psi) in w. By bx_forward_witness: get v with psi in v.
   - The chain from w to v has intermediate points. At each intermediate point u:
     - If phi U psi in u and psi not in u: by BX5, (phi AND phi U psi) U psi in u.
     - The oracle step moves phi U psi to the next point, eventually reaching psi.
     - At each step where phi U psi persists, phi is in the guard... but HOW?

   **Critical question**: Without BX9, can we establish phi at intermediate chain points?

   Under open guard on Z, with consecutive chain points w=t, u=t+1, v=t+2:
   - phi U psi at t with witness t+2 requires phi(t+1).
   - We need phi at u=t+1 from the MCS u.
   - phi U psi in u and psi not in u gives us... nothing without BX9.

   **We need BX9 or equivalent for intermediate points.**

### FINAL REVISED RECOMMENDATION: Half-Open Guard

Given the analysis above, the open guard fundamentally lacks the ability to extract current-time guard information. The only viable path to a sorry-free soundness + completeness pair is:

**Use half-open guard**: `phi U psi at t := exists s > t, psi(s) AND forall r, t <= r < s -> phi(r)`

**Axiom changes**:
1. **KEEP BX9** (now sound: half-open includes t in guard, so phi(t) from guard)
2. **DROP BX8** (still invalid: gap between t and the F-witness's start)
3. **REFORMULATE BX2** to: `(phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)` (sound under half-open)

**Soundness verification**:
- BX9 under half-open: (phi U psi) at t. Witness s > t, psi(s), phi on [t, s). phi(t) holds. So phi OR psi. SOUND.
- BX2-reformulated: (phi->chi)(t) AND G(phi->chi). (phi U psi) at t: phi on [t, s), psi(s). chi(t) from phi(t) and (phi->chi)(t). chi(r) for r in (t, s) from phi(r) and G(phi->chi) at r. So chi on [t, s). SOUND.
- BX8 under half-open: INVALID (same gap argument as before -- dropping it).

**Completeness with reformulated BX2**:

Where `left_mono_until_mcs` is used, we now need `(phi->chi) in w.formulas` in addition to `G(phi->chi) in w.formulas`.

In the oracle step construction (OracleStep.lean), BX2 is applied where G(phi->chi) comes from the temporal content of an MCS. Under half-open guard with BX9 available, if phi U psi is in w then phi is in w (by BX9). This may provide the needed (phi->chi) hypothesis in specific cases.

**Completeness without BX8**:

BX8 (`phi AND F(phi U psi) -> phi U psi`) is NOT used directly in the proved parts of the completeness proof. It's only referenced in the sorry'd `psi_imp_until_mcs` which implements `psi -> phi U psi` (a reflexive introduction that doesn't hold under irreflexive semantics anyway). Dropping BX8 does NOT break any proved completeness infrastructure.

The `psi_imp_until_mcs` (CanonicalChain.lean:48) needs replacement regardless: under irreflexive Until, `psi -> phi U psi` requires a strict future witness, so it should be replaced by `psi AND F(T) -> phi U psi` which under half-open with serial_future gives: psi(t), F(T)(t) gives s > t. Take s as witness. Guard [t, s): on Z this is {t}. psi(t) holds. Need phi(t)? No -- the CONCLUSION is phi U psi, so the guard needs phi on [t, s) = {t}... but the guard for (phi U psi) uses phi, not psi! So we need phi(t). This is not available from just psi(t).

Actually `psi -> phi U psi` under half-open: need witness s > t with psi(s) and phi on [t, s). We only have psi(t), not psi at any future time. This is GENUINELY not provable. The correct derived fact for completeness would be something like BX12: `F(psi) -> T U psi`, which IS in the system.

---

## 8. Summary of Final Recommendation

### Guard Convention: **Half-Open** (change from current open)

Change in Truth.lean:
```
-- Current (open guard):
| Formula.untl phi psi => exists s, t < s AND truth_at ... s psi AND
    forall r, t < r -> r < s -> truth_at ... r phi

-- Proposed (half-open guard):
| Formula.untl phi psi => exists s, t < s AND truth_at ... s psi AND
    forall r, t <= r -> r < s -> truth_at ... r phi
```

### Axiom Changes

| # | Axiom | Action | New Statement |
|---|-------|--------|---------------|
| BX2 | left_mono_until | REFORMULATE | `(phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)` |
| BX2' | left_mono_since | REFORMULATE | `(phi->chi) AND H(phi->chi) -> (phi S psi -> chi S psi)` |
| BX8 | until_step | DROP | (removed from system) |
| BX8' | since_step | DROP | (removed from system) |
| BX9 | until_elim | KEEP | `(phi U psi) -> (phi OR psi)` (now sound) |
| BX9' | since_elim | KEEP | `(phi S psi) -> (phi OR psi)` (now sound) |

### Soundness Sorries Eliminated

After this change:
- BX8/BX8' sorry: eliminated (axioms dropped)
- BX9/BX9' sorry: eliminated (now provable under half-open)
- BX2/BX2' current proof: MUST be updated (signature changes)
- BX1/BX1' sorry: REMAINS (needs NoMaxOrder/NoMinOrder on D -- orthogonal issue)
- BX5/BX6/BX7/BX10/BX11/BX12: all sound proofs remain valid (guard only gets stronger)

### Completeness Impact

1. **BX9 still available** -- `bx_until_eventuality_resolution` works as-is.
2. **BX8 dropped** -- `psi_imp_until_mcs` was already sorry'd and structurally unsound. Replace with BX12-based approach: `F(psi) -> T U psi`.
3. **BX2 reformulated** -- `left_mono_until_mcs` needs extra hypothesis. Audit all call sites.
4. **BX5 strengthened** -- under half-open, self-accumulation gives strictly more (phi(t) AND phi U psi(t) at guard point t).

### Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| BX2 reformulation breaks downstream | Medium | Audit 3 call sites; likely fixable with BX9 |
| psi_imp_until_mcs replacement | Low | Was already sorry'd; BX12 provides alternative |
| Half-open guard changes BX5 proof | Low | Proof still valid (stronger guard is easier) |
| Missing axiom for completeness | Medium | BX5+BX6+BX10+BX12 provide rich until-manipulation toolkit |

### Why Not Open Guard?

Open guard fundamentally cannot support BX9 (current-time extraction). Without BX9, the completeness proof requires a fundamentally different architecture where intermediate chain points maintain the guard through self-accumulation alone. While theoretically possible, it would require rewriting the entire oracle step machinery -- far more invasive than switching to half-open guard.

### Why Not Keep BX8?

BX8 is invalid under BOTH guard conventions for general linear orders and even for Z specifically. The gap between the current time and the F-witness start cannot be bridged without additional structure (like a successor/predecessor relation that's not part of the base logic). Since the codebase's `psi_imp_until_mcs` was already sorry'd with no real proof strategy, dropping BX8 removes an impossible obligation.

---

## Appendix: Proof That BX5 Remains Sound Under Half-Open Guard

BX5: `(phi U psi) -> ((phi AND (phi U psi)) U psi)`

Under half-open: (phi U psi) at t has witness s > t, psi(s), phi on [t, s).

Need: ((phi AND phi U psi) U psi) at t. Use same witness s. Need psi(s) (have it). Need (phi AND phi U psi) on [t, s). For any r in [t, s):
- phi(r): from original guard (r in [t, s)).
- (phi U psi)(r): use same witness s. psi(s) and s > r. Guard: phi on [r, s). Since [r, s) is a subset of [t, s) (r >= t), the original guard covers it.

SOUND.

## Appendix: Proof That BX6 Remains Sound Under Half-Open Guard

BX6: `(phi U (phi AND phi U psi)) -> (phi U psi)`

Under half-open: (phi U (phi AND phi U psi)) at t with witness s1 > t: (phi AND phi U psi)(s1), phi on [t, s1).

From (phi AND phi U psi)(s1): phi(s1) AND (phi U psi)(s1). The inner (phi U psi)(s1) has witness s2 > s1: psi(s2), phi on [s1, s2).

Compose: use s2 as witness for phi U psi at t. Need psi(s2) (have it). Guard: phi on [t, s2) = [t, s1) union [s1, s2). [t, s1) from outer guard. [s1, s2): s1 covered by phi(s1), (s1, s2) from inner guard. Actually [s1, s2) = {s1} union (s1, s2). phi(s1) from the conjunction. (s1, s2) from inner guard... wait, inner guard under half-open is [s1, s2) which includes s1. So [s1, s2) is exactly covered.

Actually: outer guard gives phi on [t, s1). Inner gives phi on [s1, s2). Union is [t, s2). SOUND.

## Appendix: BX12 Soundness Under Half-Open Guard

BX12: `F(phi) -> T U phi`

Under half-open: F(phi) at t means exists s > t, phi(s). For T U phi at t: witness s, phi(s) (the endpoint), T on [t, s). T is always true. SOUND.
