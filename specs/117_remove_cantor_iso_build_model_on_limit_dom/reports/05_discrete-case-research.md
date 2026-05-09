# Research Report: Discrete Case of the Case-Split Completeness Approach

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: Research complete
- **Type**: lean4
- **Artifacts**: reports/05_discrete-case-research.md

## Executive Summary

This report investigates the discrete case of a proposed case-split completeness strategy. The idea: when the chronicle's limit domain X is discrete (i.e., when G'bot and H'bot are in every domain MCS), X should be order-isomorphic to Z, enabling a direct FMCS over Int that avoids the extension-to-all-rationals problem entirely.

**Key findings**:

1. **Mathlib has the exact theorem needed**: `orderIsoIntOfLinearSuccPredArch` gives `iota ~~o Z` for any linear order with SuccOrder, PredOrder, IsSuccArchimedean, NoMaxOrder, NoMinOrder, Nonempty. This is available in the project's mathlib at `Mathlib.Order.SuccPred.LinearLocallyFinite` (already imported by `FrameConditions/FrameClass.lean`).

2. **Mathlib has the case-split theorem**: `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` from `Mathlib.GroupTheory.ArchimedeanDensely` gives: for any Archimedean linearly ordered additive commutative group G, either G ~~+o Z or G is DenselyOrdered. This is the exact dichotomy needed for the case split.

3. **The existing Int chain (bx_bfmcs) already has forward_G and backward_H proved**. The three sorry'd coherence properties (restricted_tc, restricted_buc, restricted_fuc) remain the sole obstacle. The discrete case does NOT simplify these sorries in any obvious way.

4. **The chronicle provides domain-point-only guards** (`limit_g`), not all-of-D guards. The FMCS coherence conditions require guards over ALL of D. In the discrete case with D = Int, the domain IS all of Int (via the iso), so this gap vanishes -- but only if we can prove the iso and transport the chronicle properties.

5. **Two viable strategies exist**: (A) Transport the chronicle to Int via the Z-iso (bypasses the extension problem), or (B) Prove coherence directly on the existing Int chain in `RootScopedChain.lean` (the current plan's "alternative" recommendation). Both require proving Until/Since resolution, which is the fundamental mathematical challenge.

---

## 1. Discrete Domain Structure

### 1.1 When is the limit domain discrete?

The chronicle construction (Burgess 1982) builds X = limit_dom via iterative counterexample elimination. Without the density counterexample kind (removed in Phase 2), points are only inserted to resolve C4 (backward counterexamples for Until/Since) and C5 (forward Until/Since witnesses).

The limit domain is discrete when:
- Every element x in X has an **immediate successor** in X: exists y in X with x < y and no z in X with x < z < y
- Every element x in X has an **immediate predecessor**: symmetric condition

The user's hypothesis is that when G'bot (= U(top, bot)) and H'bot (= S(top, bot)) are in every domain MCS, the domain becomes uniformly discrete. Let me analyze this.

**G'bot = neg(F(top))**: In TM notation, G(phi) = neg(F(neg(phi))). So G(bot) = neg(F(neg(bot))) = neg(F(top)). Having G(bot) in an MCS means F(top) is NOT in that MCS. Since F(top) is a theorem of base TM (by seriality: top -> F(top)), G(bot) is INCONSISTENT with base TM.

**Correction**: The user notation "G'bot" likely means the discreteness axiom. Let me check what Burgess's discreteness axiom actually says. In Burgess 1982, the discreteness axiom DF is: `F(phi) -> phi v X(phi)` where X(phi) = neg(G(neg(phi))) restricted to immediate successors. Under the codebase's formulation, this is an additional axiom NOT in the base BX system (confirmed: `Axiom.isDiscreteCompatible` is trivially true because no axiom IS a discreteness axiom).

**Important realization**: The base BX axiom system has NO discreteness axioms. The discrete case in the case-split is a FUTURE EXTENSION, not something achievable with the current axiom system. The ROADMAP confirms this at line 1267-1270:

> "Discrete variant (axioms G'bot AND H'bot): the discrete axioms ensure X is globally discrete (X/Y operators require immediate successors). Then X = Z via Mathlib's orderIsoIntOfLinearSuccPredArch. D = Z. This is a separate completeness theorem (valid_discrete) with its own construction."

### 1.2 Implications for Task 117

Task 117 is about the **base logic** (no density/discreteness axioms). The limit domain for the base logic is a general countable linear order without endpoints -- it may be discrete in some regions and dense in others depending on formula content. The "discrete case" as described in the user's request is about a **future extension** to the logic, not the base case.

For the base logic:
- The limit domain X is NOT guaranteed to be globally discrete
- It is NOT guaranteed to be globally dense (density was removed)
- It has no endpoints (from seriality: limit_dom_no_max, limit_dom_no_min)
- It is countable (limitDomSubtype_countable)
- 0 is in it (zero_mem_limit_dom)

### 1.3 Mathlib Support for Z-Isomorphism

If we WERE to prove the domain is discrete (for the extension):

**Theorem**: `orderIsoIntOfLinearSuccPredArch`
- **File**: `Mathlib.Order.SuccPred.LinearLocallyFinite` (line 378)
- **Type**: `{iota : Type} -> [LinearOrder iota] -> [SuccOrder iota] -> [PredOrder iota] -> [IsSuccArchimedean iota] -> [NoMaxOrder iota] -> [NoMinOrder iota] -> [Nonempty iota] -> iota ~~o Z`
- **Status**: Available in project mathlib (file exists at `.lake/packages/mathlib/Mathlib/Order/SuccPred/LinearLocallyFinite.lean`; imported by `FrameConditions/FrameClass.lean`)

**Requirements to invoke**: The LimitDomSubtype would need instances for:
- `LinearOrder` -- inherited from Rat (already available)
- `SuccOrder` -- must prove each element has an immediate successor
- `PredOrder` -- must prove each element has an immediate predecessor
- `IsSuccArchimedean` -- must prove succ-reachability
- `NoMaxOrder` -- already proved (`limitDomSubtype_noMaxOrder`)
- `NoMinOrder` -- already proved (`limitDomSubtype_noMinOrder`)
- `Nonempty` -- already proved (`limitDomSubtype_nonempty`)

The hard part is proving SuccOrder and PredOrder on LimitDomSubtype. This requires the discreteness axiom to ensure no point is a limit point.

### 1.4 Mathlib Case-Split Theorem

**Theorem**: `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`
- **File**: `Mathlib.GroupTheory.ArchimedeanDensely`
- **Type**: `(G : Type) -> [LinearOrderedAddCommGroup G] -> [Archimedean G] -> Nonempty (G ~~+o Z) v DenselyOrdered G`
- **Status**: Available in project mathlib (verified via lean_local_search)

This applies to the DURATION type D, not to limit_dom. It says: D is either iso to Z (discrete) or densely ordered. For D = Rat, we get DenselyOrdered (the dense case). For D = Int, we get iso to Z (the discrete case). This is useful for the general case-split strategy but does NOT directly help with limit_dom.

---

## 2. Existing Int Chain Infrastructure

### 2.1 Schedule-Based Chain (CanonicalModel.lean)

The existing Int chain in `CanonicalModel.lean` is the PROVEN infrastructure for D = Int:

- `int_chain M0 h0 : Int -> Set Formula` (line 138)
- `int_chain_mcs` : every time point is an MCS (line 146)
- `int_chain_forward_G` : G(phi) at t, t < t' implies phi at t' (line 250)
- `int_chain_backward_H` : H(phi) at t, t' < t implies phi at t' (line 265)
- `bx_fmcs M0 h0 : FMCS Int` (line 273) -- wraps int_chain
- `shifted_bx_fmcs M0 h0 s : FMCS Int` (line 290) -- shifted version
- `bx_bfmcs M0 h0 : BFMCS Int` (line 64 of RootScopedChain.lean) -- the bundle

### 2.2 Current Sorry Sites (RootScopedChain.lean)

Three sorry sites remain on the Int chain path:

1. **`bx_bfmcs_restricted_tc`** (line 182-186): Restricted temporal coherence
   - Requires: F(phi) in chain(n) implies exists m > n with phi in chain(m)
   - The fundamental issue: the chain construction (fwd_succ via Lindenbaum) does not preserve F-obligations. When building chain(n+1) from g_content(chain(n)), F(phi) may be absent from the result even if present in chain(n).
   - The SCHEDULE addresses this: `schedule_surjective_above` guarantees every formula is targeted infinitely often. When F(phi) is in chain(n), there exists k >= n with schedule(k) = phi, and at step k, fwd_succ checks `by_cases h_F : Formula.some_future psi in M`. If F(phi) is still present, it resolves. The challenge is showing F(phi) persists until step k.
   - `fwd_chain_F_not_return` (line 113-143) proves the OPPOSITE direction: once F(phi) LEAVES, it never returns. This is useful but doesn't prove persistence.

2. **`bx_bfmcs_restricted_buc`** (line 190-193): Backward Until/Since coherence
   - Requires: witness pattern (phi at s, psi on guard [t,s)) implies (phi U psi) in chain(t)
   - Infrastructure exists: `backward_until_from_step` (UntilSinceCoherence.lean line 111) parameterized by a step transfer property
   - Step transfer needed: `(phi U psi) in chain(r+1) AND psi in chain(r) -> (phi U psi) in chain(r)`
   - This requires: the chain construction preserves backward Until information across steps

3. **`bx_bfmcs_restricted_fuc`** (line 195-198): Forward Until/Since coherence
   - Requires: (phi U psi) in chain(n) implies exists m > n with phi in chain(m) and psi on guard [n,m)
   - This is the HARDEST part: the Int chain does NOT insert Until witnesses (unlike the chronicle construction which uses C5 counterexample elimination)

### 2.3 Assessment

The Int chain already has D = Int with AddCommGroup structure and proven forward_G/backward_H. The three sorry sites are genuinely hard mathematical problems. The discrete case of the case-split does NOT make these easier -- the same challenges apply regardless of whether the MCSs contain discreteness axioms.

---

## 3. FMCS on Int from Discrete Chronicle

### 3.1 Construction Outline (If Domain Is Proved Discrete)

Given a chronicle with limit_dom iso to Z via `e : LimitDomSubtype ~~o Z`:

```lean
noncomputable def discrete_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ~~o Z) : Int -> Set Formula :=
  fun n => limit_f A h_mcs (e.symm n).val

theorem discrete_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ~~o Z) (n : Int) :
    SetMaximalConsistent (discrete_f A h_mcs e n) :=
  limit_c0 A h_mcs (e.symm n).val (e.symm n).property

noncomputable def discrete_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ~~o Z) : FMCS Int where
  mcs := discrete_f A h_mcs e
  is_mcs := discrete_f_is_mcs A h_mcs e
  forward_G := by
    intro t t' phi h_lt h_G
    have h_lt_dom := e.symm.strictMono h_lt
    exact limit_forward_G A h_mcs
      (e.symm t).val (e.symm t').val
      (e.symm t).property (e.symm t').property
      h_lt_dom phi h_G
  backward_H := by
    intro t t' phi h_lt h_H
    have h_lt_dom := e.symm.strictMono h_lt
    exact limit_backward_H A h_mcs
      (e.symm t).val (e.symm t').val
      (e.symm t).property (e.symm t').property
      h_lt_dom phi h_H
```

This mirrors the archived `cantor_fmcs` (CantorIsoCountermodel.lean line 74-96) exactly, replacing `cantor_iso` with the discrete Z-iso `e`.

### 3.2 Advantages Over the Cantor Iso Path

If we could prove the domain is discrete:
- **No extension problem**: Every integer maps to a domain point. There are no "non-domain" points to extend to.
- **forward_G and backward_H are immediate**: Transport via the order isomorphism from limit_forward_G/limit_backward_H.
- **D = Int has AddCommGroup**: Int is a perfectly good AddCommGroup, so all parametric infrastructure works.

### 3.3 Coherence Properties

The three coherence conditions become:

**restricted_tc** (F/P resolution):
- Need: F(phi) in discrete_f(n) implies exists m > n with phi in discrete_f(m)
- Transport: F(phi) in limit_f(e.symm(n)) implies (by limit_F_resolution) exists y in limit_dom with e.symm(n) < y and phi in limit_f(y). Then m = e(y) > n and discrete_f(m) = limit_f(y) contains phi.
- **This works directly from limit_F_resolution!**

**restricted_buc** (backward Until/Since):
- Need: witness pattern over Int implies Until membership
- The chronicle's C4 provides the backward direction
- Since D = Int (discrete), the guard quantifies over ALL integers between t and s. Via the iso, this corresponds to ALL domain points between e.symm(t) and e.symm(s). Since the domain IS all of Z via the iso, this is exactly the domain-point guard that `limit_g` provides.
- **This should work via limit_satisfies_c4 transported through the iso.**

**restricted_fuc** (forward Until/Since):
- Need: (phi U psi) in discrete_f(n) implies exists m > n with phi in discrete_f(m) and psi on guard (n,m)
- Transport: (phi U psi) in limit_f(e.symm(n)). By `limit_satisfies_c5_strong`, exists y in limit_dom with phi in limit_f(y) and psi in limit_g(e.symm(n), y).
- `limit_g(x, y)` means: for all w in limit_dom with x < w < y, psi in limit_f(w).
- Via the iso (domain = all of Z), this covers ALL integers between n and e(y).
- **This works directly from limit_satisfies_c5_strong!**

### 3.4 Critical Insight

**In the discrete case (domain iso to Z), ALL three coherence properties transport directly from the chronicle.** The domain-point-only guard of `limit_g` becomes an all-of-D guard because the domain IS all of D (via the iso). This is the key advantage of the discrete case -- it completely avoids the extension problem AND the coherence sorries.

---

## 4. Restricted Coherence for Int: Detailed Analysis

### 4.1 restricted_tc via limit_F_resolution

```lean
theorem discrete_bfmcs_restricted_tc
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ~~o Z)
    (root : Formula) :
    (discrete_bfmcs A h_mcs e).restricted_temporally_coherent root := by
  intro fam hfam
  -- fam is a shifted_discrete_fmcs N h_N s for some box-equivalent N
  obtain <N, h_N, s, h_eqN, rfl> := hfam
  constructor
  . -- Forward F: F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s
    intro t phi _ h_F
    -- fam.mcs t = limit_f(e.symm(t - s))
    -- F(phi) in limit_f(e.symm(t - s))
    -- By limit_F_resolution: exists y in limit_dom, e.symm(t-s) < y, phi in limit_f(y)
    -- Set m = e(y) + s > t
    -- fam.mcs m = limit_f(e.symm(m - s)) = limit_f(e.symm(e(y))) = limit_f(y)
    sorry -- proof sketch above
  . -- Backward P: symmetric
    sorry
```

The proof sketch is sound. The key step is that `limit_F_resolution` already does the work, and the iso just transports it.

### 4.2 restricted_buc via backward induction + C4

For the backward Until direction, we need: given phi at s > t and psi on guard (t,s), derive (phi U psi) in fam.mcs t.

In the discrete case with D = Int, "guard (t,s)" means psi in fam.mcs r for all integers r with t < r < s. Since the domain is all of Z, this is the same as the domain-point guard.

The `backward_until_from_step` infrastructure in UntilSinceCoherence.lean already provides the induction, parameterized by a step transfer. For the discrete chronicle FMCS, the step transfer would come from the chronicle's C2 condition (r-relation) or from the BX5 axiom (self_accum_until).

Alternatively, if the chronicle satisfies C4 (backward counterexample elimination), we can derive backward Until directly without step-by-step induction. C4 says: if neg(phi U psi) in f(x) and phi in f(y) with x < y, then exists z with x < z < y and psi.neg in f(z). The contrapositive: if phi in f(y) and psi in f(z) for all z with x < z < y, then (phi U psi) in f(x).

Wait -- that's not quite right. C4 gives a counterexample to the GUARD, not a direct proof of Until. Let me reconsider.

Actually, backward Until coherence in the discrete case is:
Given:
- phi in fam.mcs s (event at s)
- psi in fam.mcs r for all t < r < s (guard)
Need: (phi U psi) in fam.mcs t

For D = Int, this is a finite induction from s down to t. At each step:
- Base: phi in fam.mcs s implies (phi U psi) in fam.mcs s (by BX8: psi -> (phi U psi) -- wait, the EVENT is phi, GUARD is psi)

Actually the codebase's FMCS Until convention: `Formula.untl phi psi` where phi is the EVENT and psi is the GUARD. So `phi U psi` means "psi until phi": psi holds on the guard interval and phi at the witness.

So backward Until coherence is:
Given: exists s > t with phi in fam.mcs s AND psi in fam.mcs r for all t < r < s
Need: (phi U psi) = `Formula.untl phi psi` in fam.mcs t

By BX8 (psi_imp_until): phi -> (phi U psi). So the base case (s = t+1, no guard needed) gives: phi in fam.mcs(t+1), and we need (phi U psi) in fam.mcs t.

This requires the step transfer: (phi U psi) in fam.mcs(t+1) AND psi in fam.mcs(t) -> (phi U psi) in fam.mcs(t).

The step transfer would follow from BX5 (self_accum_until): `(phi U psi) -> ((psi AND (phi U psi)) U phi)`. Hmm, that doesn't directly give what we need.

Actually, looking at BX axioms more carefully, the step transfer in the DISCRETE case can potentially use:
- BX4 (connect_future): phi AND F(psi) -> (phi U psi) v F(phi AND F(psi))
  With phi = psi (the guard) and psi = (event U guard): if guard in fam.mcs(t) and F(event U guard) in fam.mcs(t), this gives (event U guard) v F(guard AND F(event U guard)) in fam.mcs(t).

For the discrete case, F(chi) at t means chi at t+1 (immediate successor). So:
- (phi U psi) in fam.mcs(t+1) means F(phi U psi) in fam.mcs(t) (by definition of F in discrete)

Wait -- F is not "next step" in the base logic. F(chi) means "exists s > t, chi at s" (existential). In the base logic, F is NOT a next-step operator. The base logic does NOT have the equivalence F(chi) at t iff chi at t+1.

This is the fundamental difficulty. The step transfer `(phi U psi) in chain(r+1) AND guard in chain(r) -> (phi U psi) in chain(r)` requires relating chain(r+1) content to chain(r) content, which the schedule-based chain does not directly support.

### 4.3 restricted_fuc via limit_satisfies_c5_strong

For the forward direction: (phi U psi) in fam.mcs t implies exists s > t with phi in fam.mcs s and psi in fam.mcs r for all t < r < s.

In the discrete case with the chronicle-based FMCS:
- (phi U psi) in limit_f(e.symm(t))
- By limit_satisfies_c5_strong: exists y in limit_dom with e.symm(t) < y, phi in limit_f(y), and psi in limit_g(e.symm(t), y)
- limit_g(x,y) = {chi | forall w in limit_dom, x < w < y -> chi in limit_f(w)}
- Since domain = all of Z (via iso), "forall w in limit_dom, x < w < y" = "forall integers between x and y"
- So psi holds at all integers between e.symm(t) and y
- Set s = e(y). Then psi in fam.mcs r for all t < r < s.

**This works.** The domain-point-only guard of limit_g covers all of D because the domain IS all of D.

---

## 5. Parametric Infrastructure with D = Int

### 5.1 Required Instances

The `dd_countermodel` in `RootScopedChain.lean` (line 202-228) already demonstrates that D = Int works with the parametric infrastructure:

```lean
refine <Int, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int, ...>
```

Int has:
- `AddCommGroup Int` -- from Mathlib (inferInstance)
- `LinearOrder Int` -- from Mathlib (inferInstance)
- `IsOrderedAddMonoid Int` -- from Mathlib (inferInstance)
- `Nontrivial Int` -- from Mathlib (inferInstance)

All parametric infrastructure (`ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`, `ShiftClosedParametricCanonicalOmega`, `parametric_to_history`) is parameterized by D and works for any D satisfying these constraints. No code changes needed.

### 5.2 RestrictedParametricTruthLemma

The `fully_restricted_parametric_representation_from_neg_membership` theorem (RestrictedParametricTruthLemma.lean line 459-473) is fully generic:

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

It works for D = Int with no changes. The representation theorem at line 459 takes:
- B : BFMCS D
- root : Formula
- h_rtc : B.restricted_temporally_coherent root
- h_buc : B.restricted_backward_until_since_coherent root
- h_fuc : B.restricted_forward_until_since_coherent root

These are exactly the three properties we need to prove.

---

## 6. Two Strategies for the Discrete Case

### Strategy A: Chronicle-Based (Transport via Z-iso)

**Prerequisite**: Prove LimitDomSubtype has SuccOrder, PredOrder, IsSuccArchimedean (requires discreteness axioms in the logic extension).

**Construction**:
1. Prove `e : LimitDomSubtype ~~o Z` via `orderIsoIntOfLinearSuccPredArch`
2. Define `discrete_f n = limit_f (e.symm n).val`
3. Build `discrete_fmcs : FMCS Int` with forward_G/backward_H from limit_forward_G/limit_backward_H
4. Build `discrete_bfmcs : BFMCS Int` with modal coherence (same pattern as bx_bfmcs)
5. Prove restricted_tc from limit_F_resolution / limit_P_resolution
6. Prove restricted_buc -- either via C4 transport or step induction
7. Prove restricted_fuc from limit_satisfies_c5_strong + limit_g completeness

**Estimated effort**: 15-20 hours (assuming discreteness axioms are added to the system)
- 3-4h: SuccOrder/PredOrder/IsSuccArchimedean instances
- 3-4h: FMCS/BFMCS construction and modal coherence
- 8-12h: Three coherence properties (restricted_tc easy, restricted_fuc medium, restricted_buc hard)

**Advantage**: The coherence properties transport almost directly from the chronicle. The key insight is that domain = all of Z means limit_g's domain-point guard = all-of-D guard.

**Risk**: The backward Until coherence (restricted_buc) still requires either:
- Step transfer (linking chain(n+1) to chain(n)), or
- Direct proof from C4 + MCS properties

### Strategy B: Int Chain Directly (RootScopedChain.lean)

This is the approach recommended by report 04. Fix the three sorries on the existing Int chain.

**Construction**: Already exists (bx_bfmcs in RootScopedChain.lean).

**Remaining work**: Prove restricted_tc, restricted_buc, restricted_fuc.

**Estimated effort**: 20-30 hours (from report 04)

**Advantage**: No new infrastructure needed. Self-contained.

**Disadvantage**: The Int chain does NOT have Until/Since witnesses by construction (unlike the chronicle). The schedule only guarantees F/P resolution, not Until/Since resolution. This makes restricted_fuc extremely difficult.

### Strategy Comparison

| Aspect | A: Chronicle + Z-iso | B: Int chain fix |
|--------|---------------------|------------------|
| Prereq | Discreteness axioms | None (base logic) |
| forward_G/backward_H | Proved (transport) | Proved (existing) |
| restricted_tc | Easy (transport) | Hard (F-persistence) |
| restricted_buc | Medium (C4 transport) | Hard (step transfer) |
| restricted_fuc | Easy (C5 transport) | Very hard (no witnesses) |
| Effort | 15-20h | 20-30h |
| Scope | Discrete extension only | Base logic |

**Key difference**: Strategy A gets restricted_fuc almost for free (from C5 + complete domain), while Strategy B has to solve the hardest problem (creating Until witnesses) from scratch.

---

## 7. Detailed Proof Outlines for Strategy A

### 7.1 SuccOrder on LimitDomSubtype

With discreteness axioms G'bot and H'bot in every MCS:

```lean
-- G'bot = all_future bot = neg(some_future (neg bot)) = neg(F(top))
-- Having G(bot) in f(x) means: for all y > x in domain, bot in f(y).
-- But bot is never in any MCS (consistency). So there IS no y > x in domain... 
-- Wait, that contradicts NoMaxOrder.
```

**Problem**: G(bot) = neg(F(top)). Having neg(F(top)) in an MCS means F(top) is NOT in the MCS. But seriality (BX1) gives top -> F(top), so F(top) IS in every MCS. This is a contradiction.

**Correction**: G'bot cannot literally be `Formula.all_future Formula.bot`. Let me reconsider the discrete axiom. The user says `G'bot = U(top, bot)`. Let me check:

`U(top, bot)` = `Formula.untl bot (Formula.bot.imp Formula.bot)` where top = bot -> bot. This means "bot Until top", i.e., "there exists a future point where bot holds, and top holds on the guard until then." Since bot never holds in any MCS, U(top, bot) is INCONSISTENT.

Actually, wait. Let me re-read the user's notation:
- G'bot = U(top, bot): In the codebase's convention, `Formula.untl event guard`. So U(top, bot) has event = top and guard = bot. This means "bot holds until top" -- i.e., there exists s > t where top holds (always true), and bot holds on the guard interval (t, s). Since bot never holds, this requires the guard interval to be empty, meaning s = t+1 (immediate successor).

Hmm, but under strict semantics, U(phi, psi) at t means: exists s > t, phi at s, and psi at r for all t < r < s. If we want the guard interval to be empty, we need s to be the immediate successor of t (no r with t < r < s). This is exactly the discreteness condition!

So `U(top, bot)` in f(x) means: there exists y > x in domain with top in f(y) (always true) and bot in f(z) for all z with x < z < y. Since bot is never in any MCS (by consistency), the set {z in domain | x < z < y} must be EMPTY. This means y is the immediate successor of x in the domain.

**Therefore**: `U(top, bot) in f(x)` for all domain x is exactly the statement that every domain point has an immediate successor. Similarly, `S(top, bot) in f(x)` for all x means every point has an immediate predecessor.

This is consistent with seriality (F(top) is still in every MCS, since the Until witness y exists).

### 7.2 SuccOrder Construction

With `U(top, bot) in limit_f(x)` for all x in limit_dom:

```lean
instance limitDomSubtype_succOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_disc : forall x, x in limit_dom A h_mcs -> 
      Formula.untl (Formula.bot.imp Formula.bot) Formula.bot in limit_f A h_mcs x) :
    SuccOrder (LimitDomSubtype A h_mcs) where
  succ := fun x => 
    -- By h_disc: U(top, bot) in limit_f(x.val)
    -- By C5: exists y in dom with x < y and top in f(y) and bot on guard
    -- Bot on guard means no domain points between x and y
    -- y is the immediate successor
    Classical.choice (limit_satisfies_c5_strong A h_mcs x.val x.property 
      (Formula.bot.imp Formula.bot) Formula.bot (h_disc x.val x.property))
    -- (need to extract the y and wrap as subtype)
  ...
```

The existence of the immediate successor follows from:
1. `U(top, bot) in limit_f(x)` (hypothesis)
2. `limit_satisfies_c5_strong` gives y with x < y and top in f(y) and bot in limit_g(x, y)
3. limit_g(x, y) contains bot means: for all w in limit_dom with x < w < y, bot in limit_f(w)
4. But no MCS contains bot (consistency). So no w exists between x and y.
5. Therefore y is the immediate successor of x.

### 7.3 IsSuccArchimedean

`IsSuccArchimedean` says: for any a <= b, there exists n such that succ^n(a) >= b. In a discrete linear order without endpoints where every element has an immediate successor, this follows from the well-ordering of N and the fact that the order has no infinite descending subsequences between any two points (which is guaranteed by the order embedding into Rat, which is Archimedean).

The proof can use the embedding into Rat: if a < b in limit_dom, then a.val < b.val in Rat, and the distance b.val - a.val > 0. Each successor step increases the Rat value by at least the minimum gap (which exists in a discrete order). After finitely many steps, we exceed b.val.

### 7.4 Coherence Transport

**restricted_tc**: Directly from limit_F_resolution. If F(phi) in discrete_f(n), then F(phi) in limit_f(e.symm(n)). By limit_F_resolution, exists y in limit_dom with y > e.symm(n) and phi in limit_f(y). Set m = e(y). Then m > n (since e is order-preserving) and phi in discrete_f(m).

**restricted_fuc**: Directly from limit_satisfies_c5_strong. If (phi U psi) in discrete_f(n), by C5 strong, exists y in limit_dom with phi in limit_f(y) and psi in limit_g(e.symm(n), y). Since the domain is all of Z (via iso), limit_g covers all integers between n and e(y). So psi in discrete_f(r) for all n < r < e(y).

**restricted_buc**: This is the most involved. Given: phi in discrete_f(s) and psi in discrete_f(r) for all n < r < s. Need: (phi U psi) in discrete_f(n).

Approach 1: Use C4 (contrapositive). Assume neg(phi U psi) in discrete_f(n). Since phi in discrete_f(s) and n < s, by C4 (limit_satisfies_c4), exists z with n < z < s and psi.neg in discrete_f(z). But psi in discrete_f(z) (from guard). Contradiction with MCS consistency.

Wait -- let me check C4 carefully. C4 says: if neg(untl(eta, xi)) in f(x) and eta in f(y) with x < y, then exists z with x < z < y and xi.neg in f(z).

In our case: neg(untl(phi, psi)) in f(n) and phi in f(s) with n < s. C4 gives z with n < z < s and psi.neg in f(z). But psi in f(z) (from guard hypothesis). Contradiction.

**This works!** The backward Until direction follows by contradiction using C4, which is already proved for the chronicle limit (`limit_satisfies_c4`).

---

## 8. Summary and Recommendations

### For the Discrete Extension (Future Work)

The discrete case (axioms U(top,bot) and S(top,bot) in every MCS) provides a clean path to a sorry-free countermodel:

1. Prove SuccOrder/PredOrder on LimitDomSubtype from the discreteness axioms
2. Prove IsSuccArchimedean from the Rat embedding
3. Get Z-iso from `orderIsoIntOfLinearSuccPredArch`
4. Transport chronicle to FMCS Int (forward_G, backward_H automatic)
5. Prove restricted_tc from limit_F_resolution (straightforward)
6. Prove restricted_fuc from limit_satisfies_c5_strong (straightforward)
7. Prove restricted_buc by contradiction using limit_satisfies_c4 (medium difficulty)
8. Build countermodel using fully_restricted_parametric_representation

**Estimated effort**: 15-20 hours for the discrete completeness theorem.

### For the Base Logic (Task 117 NOW)

The discrete case does NOT help with task 117's base logic, because:
- The base logic has no discreteness axioms
- The limit domain may be mixed discrete/dense
- Neither the Z-iso nor the Cantor iso is available

The base logic still faces the extension problem (report 04's finding). The recommended approaches remain:
1. Fix the Int chain sorries directly (Strategy B above, 20-30h)
2. Domain-restricted truth lemma (approach D1 from report 04, 25-40h)

### For a Case-Split Approach

A case-split strategy would:
1. Add the discreteness axioms to produce a `valid_discrete` theorem
2. Add the density axiom to produce a `valid_dense` theorem (restoring the Cantor iso path)
3. Use `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` to case-split
4. Show `valid` implies both `valid_discrete` and `valid_dense`
5. Derive `valid -> provable` from the case split

This is mathematically elegant but requires building BOTH the discrete AND dense completeness theorems, plus the case-split infrastructure. Total effort: 35-50 hours.

The base logic completeness (without case split) can alternatively use the Int chain fix (20-30h) or domain-restricted truth (25-40h), which are simpler approaches.

---

## Appendix: Key File Locations

| File | Purpose | Lines |
|------|---------|-------|
| `Metalogic/BXCanonical/CanonicalModel.lean` | Int chain, bx_fmcs, shifted_bx_fmcs | 299 |
| `Metalogic/BXCanonical/RootScopedChain.lean` | bx_bfmcs, 3 sorries, dd_countermodel | 229 |
| `Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` | Chronicle structure, conditions C0-C5 | 698 |
| `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` | omega chain, limit domain, C4/C5 | ~1520 |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | BLOCKED: dd_countermodel_chronicle | 182 |
| `Metalogic/Algebraic/ParametricRepresentation.lean` | Parametric representation theorem | 300 |
| `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` | Restricted truth lemma | 475 |
| `Metalogic/Bundle/FMCSDef.lean` | FMCS definition | 127 |
| `Metalogic/Bundle/BFMCS.lean` | BFMCS definition | ~200 |
| `Metalogic/Bundle/TemporalCoherence.lean` | Restricted coherence definitions | ~600 |
| `Metalogic/Bundle/UntilSinceCoherence.lean` | Backward Until/Since from step | 209 |
| `Boneyard/DenseChronicle/CantorIsoCountermodel.lean` | Archived Cantor iso path | 103 |
| `Mathlib/.../LinearLocallyFinite.lean` | orderIsoIntOfLinearSuccPredArch | (mathlib) |
| `Mathlib/.../ArchimedeanDensely.lean` | discrete_or_denselyOrdered | (mathlib) |

## Appendix: Mathlib Theorem Signatures

```
-- Z-isomorphism for discrete linear orders
orderIsoIntOfLinearSuccPredArch :
  {iota : Type} -> [LinearOrder iota] -> [SuccOrder iota] -> [PredOrder iota] ->
  [IsSuccArchimedean iota] -> [NoMaxOrder iota] -> [NoMinOrder iota] ->
  [Nonempty iota] -> iota ~~o Z

-- Case-split dichotomy for Archimedean ordered groups
LinearOrderedAddCommGroup.discrete_or_denselyOrdered :
  (G : Type) -> [LinearOrderedAddCommGroup G] -> [Archimedean G] ->
  Nonempty (G ~~+o Z) v DenselyOrdered G

-- Cantor theorem for countable dense linear orders (archived path)
Order.iso_of_countable_dense :
  (alpha beta : Type) -> [LinearOrder alpha] -> [LinearOrder beta] ->
  [Countable alpha] -> [DenselyOrdered alpha] -> [NoMinOrder alpha] ->
  [NoMaxOrder alpha] -> [Nonempty alpha] ->
  [Countable beta] -> [DenselyOrdered beta] -> [NoMinOrder beta] ->
  [NoMaxOrder beta] -> [Nonempty beta] -> Nonempty (alpha ~~o beta)
```
