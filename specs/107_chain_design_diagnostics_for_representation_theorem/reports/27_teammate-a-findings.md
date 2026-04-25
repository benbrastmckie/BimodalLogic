# Teammate A: Non-Domain Extension -- Cantor Isomorphism Implementation Design

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Focus**: Cantor isomorphism for eliminating non-domain sorry sites
**Confidence Level**: HIGH

---

## 1. Where forward_G Breaks for Non-Domain Points

The `extended_limit_f` definition (ChronicleToCountermodel.lean:99-104):

```lean
noncomputable def extended_limit_f ... : Rat -> Set Formula :=
  fun x =>
    if h : exists n, x in (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).f x
    else A    -- <== non-domain fallback
```

The sorry at line 195 (`chronicle_fmcs.forward_G`) requires:

> For ALL t < t' in Rat, G(phi) in extended_limit_f(t) implies phi in extended_limit_f(t').

Consider t in limit_dom but t' NOT in limit_dom. Then:
- `extended_limit_f(t) = limit_f(t)` (domain point)
- `extended_limit_f(t') = A` (root MCS, non-domain fallback)

We need: G(phi) in limit_f(t) implies phi in A. But there is no reason phi should be in A. The formula G(phi) being in limit_f(t) means phi holds at all domain points after t, but A = limit_f(0) and 0 < t typically, so phi is not required to be in A.

Worse: consider t NOT in limit_dom and t' in limit_dom. Then:
- `extended_limit_f(t) = A`
- `extended_limit_f(t') = limit_f(t')`

We need: G(phi) in A implies phi in limit_f(t'). This requires that the root MCS's G-content propagates to ALL domain points, which is exactly g_ordered for the root -- a property we cannot establish.

**Conclusion**: The current `extended_limit_f` design is fundamentally broken for forward_G. The non-domain fallback to A creates irrecoverable gaps.

---

## 2. Mathlib's Cantor Isomorphism

### The Theorem

```
Order.iso_of_countable_dense :
  forall (alpha beta : Type) [LinearOrder alpha] [LinearOrder beta]
    [Countable alpha] [DenselyOrdered alpha] [NoMinOrder alpha] [NoMaxOrder alpha] [Nonempty alpha]
    [Countable beta] [DenselyOrdered beta] [NoMinOrder beta] [NoMaxOrder beta] [Nonempty beta],
    Nonempty (alpha >=o beta)
```

Located in `Mathlib.Order.CountableDenseLinearOrder`.

### Extracting the Isomorphism

The result is `Nonempty (alpha >=o beta)`, which wraps the isomorphism in an existential. To extract it:

```lean
noncomputable def cantor_iso : limit_dom_subtype >=o Rat :=
  Classical.choice (Order.iso_of_countable_dense limit_dom_subtype Rat)
```

This is standard and unproblematic with `open Classical`.

---

## 3. Prerequisites for limit_dom Subtype

Define `limit_dom_subtype := { q : Rat // q in limit_dom A h_mcs }`.

### 3a. LinearOrder

Inherited from Rat via `Subtype.linearOrder`. Available automatically -- Lean derives this for subtypes of linear orders.

### 3b. Countable

`limit_dom = Union_n (omega_chain_val A h_mcs n).dom` where each `dom` is a `Finset Rat`.

Proof sketch:
1. Each `(omega_chain_val A h_mcs n).dom` is `Finset Rat`, hence `Set.Finite` when coerced to a set.
2. A countable union of finite sets is countable: `Set.countable_iUnion` + `Set.Finite.countable`.
3. `Set.Countable.to_subtype` converts `Set.Countable limit_dom` to `Countable limit_dom_subtype`.

Mathlib API:
- `Set.Countable.to_subtype` (in `Mathlib.Data.Set.Countable`): `s.Countable -> Countable (Subtype s)`
- `Set.countable_iUnion` (needs each set countable): `(forall i, (f i).Countable) -> (Union i, f i).Countable`
- `Set.Finite.countable`: finite sets are countable.

**Estimated difficulty**: LOW. The API exists; just compose the pieces.

### 3c. DenselyOrdered

We need: for any a b in limit_dom_subtype with a < b, there exists c in limit_dom_subtype with a < c < c < b.

This follows directly from `limit_dom_dense` (ChronicleConstruction.lean:677, sorry-free):

```lean
theorem limit_dom_dense ... (hxy : x < y) :
    exists z in limit_dom A h_mcs, x < z and z < y
```

Construction: build a `DenselyOrdered limit_dom_subtype` instance by wrapping `limit_dom_dense`.

**Estimated difficulty**: LOW. Manual instance construction with 1 field.

### 3d. NoMinOrder

We need: for any x in limit_dom, there exists y in limit_dom with y < x.

**Proof**: Let x be in limit_dom. Then limit_f(x) is an MCS (by limit_c0). The BX axiom `serial_past` gives `P(top) in limit_f(x)` (top = bot -> bot is a theorem, so top is in every MCS, and serial_past says top -> P(top)). By `limit_P_resolution` (ChronicleConstruction.lean:639, sorry-free), P(top) in limit_f(x) gives y in limit_dom with y < x and top in limit_f(y).

**Dependency**: `limit_P_resolution` is already sorry-free. The seriality axiom `serial_past` is in the BX system. The only new work is composing these into a `NoMinOrder` instance.

**Estimated difficulty**: LOW.

### 3e. NoMaxOrder

Dual of NoMinOrder, using `serial_future` and `limit_F_resolution` (also sorry-free).

**Estimated difficulty**: LOW.

### 3f. Nonempty

`0 in limit_dom` by `zero_mem_limit_dom`. So `Nonempty limit_dom_subtype` follows immediately.

**Estimated difficulty**: TRIVIAL.

### Summary of Prerequisites

| Prerequisite | Status | Difficulty |
|-------------|--------|-----------|
| LinearOrder | Automatic (Subtype) | None |
| Countable | Need to prove | Low |
| DenselyOrdered | From limit_dom_dense | Low |
| NoMinOrder | From serial_past + limit_P_resolution | Low |
| NoMaxOrder | From serial_future + limit_F_resolution | Low |
| Nonempty | From zero_mem_limit_dom | Trivial |

All prerequisites for `Order.iso_of_countable_dense` are achievable. No blockers.

---

## 4. cantor_fmcs Construction Design

### Definition

```lean
noncomputable def cantor_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    limit_dom_subtype A h_mcs >=o Rat :=
  Classical.choice (Order.iso_of_countable_dense _ _)

noncomputable def cantor_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat -> Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso A h_mcs).symm q).val
```

### cantor_fmcs Fields

```lean
noncomputable def cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    FMCS Rat where
  mcs := cantor_f A h_mcs
  is_mcs := by
    intro q
    -- cantor_f(q) = limit_f(iso.symm(q).val)
    -- iso.symm(q) : limit_dom_subtype, so iso.symm(q).val in limit_dom
    exact limit_c0 A h_mcs _ (iso.symm q).property
  forward_G := by
    intro t t' phi h_lt h_G
    -- cantor_f(t) = limit_f(iso.symm(t).val)
    -- cantor_f(t') = limit_f(iso.symm(t').val)
    -- h_lt : t < t', iso.symm is order-preserving, so iso.symm(t) < iso.symm(t')
    -- iso.symm(t).val < iso.symm(t').val
    -- Both are in limit_dom
    -- Apply limit_forward_G directly!
    exact limit_forward_G A h_mcs
      (iso.symm t).val (iso.symm t').val
      (iso.symm t).property (iso.symm t').property
      (iso.symm.strictMono h_lt)  -- order isomorphism preserves strict order
      phi h_G
  backward_H := by
    -- Mirror of forward_G using limit_backward_H
    ...
```

**Key insight**: Every rational maps to a domain point via `iso.symm`, so forward_G reduces PURELY to `limit_forward_G` (which is sorry-free). No non-domain extension needed.

### cantor_fmcs at 0

We need `cantor_fmcs.mcs` at some distinguished point to equal A. Currently:
- `cantor_f(q) = limit_f(iso.symm(q).val)`
- We need some q0 such that `iso.symm(q0).val = 0`
- That means q0 = `iso(0_in_limit_dom)` where 0_in_limit_dom is the subtype element `<0, zero_mem_limit_dom>`.

Define: `cantor_zero := (cantor_iso A h_mcs) (Subtype.mk 0 (zero_mem_limit_dom A h_mcs))`

Then: `cantor_f(cantor_zero) = limit_f(iso.symm(iso(0)).val) = limit_f(0) = A` by `limit_f_zero`.

This is NOT at Rat 0 in general -- it's at `cantor_zero` which is some rational. The shifted_chronicle_fmcs handles this by shifting.

---

## 5. Shifting and the iso Non-Additivity Problem

### The Problem

The shifted FMCS uses `mcs t := cantor_fmcs.mcs (t - s)`. For this to produce an FMCS, we need forward_G for the shifted version:

```
G(phi) in cantor_fmcs.mcs(t - s) and t < t'
  implies phi in cantor_fmcs.mcs(t' - s)
```

Since `t < t'` implies `t - s < t' - s` (Rat subtraction preserves order), and `cantor_fmcs.forward_G` gives exactly:

```
G(phi) in cantor_fmcs.mcs(u) and u < v implies phi in cantor_fmcs.mcs(v)
```

with u = t - s, v = t' - s, this works perfectly.

**The iso does NOT need to be additive.** The shifting happens in the Rat domain (where subtraction is well-defined), and the iso is only used inside `cantor_f` to map from Rat to limit_dom. The composition is:

```
shifted_cantor_fmcs.mcs(t) = cantor_f(t - s) = limit_f(iso.symm(t - s).val)
```

The fact that `iso.symm(t - s) != iso.symm(t) - iso.symm(s)` is irrelevant. We never need additivity -- we only need order-preservation, and `t - s < t' - s` in Rat implies the correct ordering in limit_dom via `iso.symm`.

### Shifted at s

```
shifted_cantor_fmcs.mcs(s) = cantor_f(s - s) = cantor_f(0) = limit_f(iso.symm(0).val)
```

This equals A only if `iso.symm(0).val = 0`, i.e., if `iso` maps 0 (in limit_dom) to 0 (in Rat). This is NOT guaranteed by the Cantor isomorphism.

**Solution**: The shift offset s should be `cantor_zero` (see Section 4), not a user-chosen value. More precisely, `shifted_cantor_fmcs A h_mcs cantor_zero` has `mcs(cantor_zero) = A`.

Or equivalently, the `chronicle_bfmcs` should define:

```lean
eval_family := shifted_cantor_fmcs M0 h0 cantor_zero
```

And `shifted_cantor_fmcs_at_s` would be:

```lean
theorem shifted_cantor_fmcs_at_s ... (s : Rat) :
    (shifted_cantor_fmcs A h_mcs s).mcs s = cantor_f A h_mcs 0
    = limit_f(iso.symm(0).val)
```

If we want `mcs(s) = A`, we need `s = cantor_zero`.

**This is a clean design**: the BFMCS bundles shifted families `{shifted_cantor_fmcs N h_N s | N box-equiv M0, s : Rat}`, and the eval family uses `s = cantor_zero(M0)`.

---

## 6. Alternative: Avoid Cantor Isomorphism Entirely?

### Burgess's Approach

Burgess defines his model on `X = union of dom f_n` (Section 2 finale). He does NOT extend to all of Rat. His valuation V is defined on X, and the completeness argument works entirely within X.

The reason we need to extend to all of Rat is the FMCS/BFMCS/ParametricHistory framework, which requires:
- `FMCS D` with D = some type having `AddCommGroup + LinearOrder + IsOrderedAddMonoid`
- The FMCS assigns an MCS to EVERY element of D
- The parametric history conversion assumes full domain

### Could We Refactor FMCS to Work on limit_dom?

This would mean `FMCS limit_dom_subtype`. The problem: `limit_dom_subtype` does NOT have `AddCommGroup`. It is not closed under addition or subtraction. The parametric framework requires `AddCommGroup D` because:

1. `ParametricCanonicalTaskFrame D` needs `AddCommGroup D` (ParametricCanonical.lean:72)
2. `parametric_to_history` uses `t - s` (ParametricHistory.lean:66)
3. `WorldHistory.time_shift` uses `t + delta` (WorldHistory.lean:238)
4. `ShiftClosedParametricCanonicalOmega` quantifies over `delta : D` shifts

**Verdict**: Refactoring FMCS to work on limit_dom would require rewriting the entire parametric framework. This is NOT feasible.

### Could We Use a Different Domain Extension?

Instead of Cantor iso, could we define `extended_limit_f` more carefully?

**Nearest-point interpolation**: For non-domain q, find closest domain points below/above and use their MCS. Problem: requires well-defined "nearest point" in a dense set (no such thing -- limit_dom is dense in itself).

**G-content extension**: For non-domain q, Lindenbaum-extend g_content(A). Problem: this gives a set containing all G-formulas from A, but that's exactly what g_ordered asserts for non-domain points, and we showed g_ordered is problematic.

**Constant extension**: Use A everywhere. This is what we currently do and it breaks forward_G.

**Verdict**: No reasonable alternative to Cantor iso exists within the current framework.

---

## 7. Does Burgess Even Need All Rationals?

Burgess works on X (limit domain) directly. His model `(X, <)` with valuation V satisfies the completeness theorem. He never mentions extending to all of Rat.

In our formalization, the mismatch is that we chose `D = Rat` for the parametric framework rather than `D = X`. The Cantor isomorphism is the bridge: it gives a bijection `X >=o Rat` that lets us work on Rat while the mathematical content lives on X.

This is the standard approach in formalizations: Cantor's theorem says all countable dense linear orders without endpoints are isomorphic to (Rat, <), so working on Rat is without loss of generality.

---

## 8. Does BFMCS Require AddCommGroup D?

**Yes, critically.** The full dependency chain:

```
FMCS D                      -- needs Preorder D only
BFMCS D                     -- needs Preorder D only
ParametricCanonicalTaskFrame -- needs AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D
parametric_to_history        -- needs AddCommGroup D (uses t - s)
ShiftClosedOmega             -- needs AddCommGroup D (shifts by delta : D)
RestrictedParametricTruthLemma -- needs AddCommGroup D
dd_countermodel_chronicle    -- needs AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D + Nontrivial D
```

The existential in `dd_countermodel_chronicle` explicitly witnesses `AddCommGroup D`:

```lean
exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) ...
```

And it instantiates D = Rat. So **the Cantor isomorphism is necessary**: we cannot use limit_dom directly as D because it lacks AddCommGroup.

---

## 9. Implementation Plan

### Step 1: Define limit_dom_subtype and prove instances (~ 2 hours)

```lean
def limit_dom_subtype (A : Set Formula) (h_mcs : SetMaximalConsistent A) :=
  { q : Rat // q in limit_dom A h_mcs }
```

Prove:
- `instance : Countable (limit_dom_subtype A h_mcs)` via Set.Countable.to_subtype
- `instance : DenselyOrdered (limit_dom_subtype A h_mcs)` from limit_dom_dense
- `instance : NoMinOrder (limit_dom_subtype A h_mcs)` from serial_past + limit_P_resolution
- `instance : NoMaxOrder (limit_dom_subtype A h_mcs)` from serial_future + limit_F_resolution
- `instance : Nonempty (limit_dom_subtype A h_mcs)` from zero_mem_limit_dom

### Step 2: Define cantor_iso and cantor_f (~ 1 hour)

```lean
noncomputable def cantor_iso ... : limit_dom_subtype A h_mcs >=o Rat :=
  Classical.choice (Order.iso_of_countable_dense _ _)

noncomputable def cantor_f ... : Rat -> Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso A h_mcs).symm q).val
```

### Step 3: Build cantor_fmcs (~ 2 hours)

Replace `chronicle_fmcs` with `cantor_fmcs`. The forward_G and backward_H fields close via limit_forward_G/limit_backward_H (both sorry-free) composed with iso.symm's order-preservation.

### Step 4: Update shifted_chronicle_fmcs and chronicle_bfmcs (~ 2 hours)

- `shifted_cantor_fmcs` uses `cantor_fmcs.mcs (t - s)` -- same pattern, works because Rat has subtraction.
- `cantor_zero` defined as `cantor_iso(0_in_limit_dom)`.
- `shifted_cantor_fmcs_at_cantor_zero` proves `mcs(cantor_zero) = A`.
- `chronicle_bfmcs` uses `shifted_cantor_fmcs` with appropriate eval_family.

### Step 5: Close remaining sorry sites (~ 3 hours)

With cantor_fmcs providing sorry-free forward_G/backward_H, the 8 sorry sites in ChronicleToCountermodel.lean should close:
- Lines 195, 200: forward_G/backward_H -- now trivial from cantor_fmcs definition
- Lines 372, 375: restricted_tc -- uses limit_F_resolution/limit_P_resolution via cantor_f
- Lines 394, 397: restricted_buc -- uses C5/C5' witnesses via cantor_f
- Lines 426, 429: restricted_fuc -- uses C5/C5' witnesses via cantor_f

**Total estimate**: 8-10 hours.

---

## 10. Key Risks

1. **Instance resolution**: Lean may struggle to find the chain of instances for `limit_dom_subtype`. May need explicit instance registration.

2. **Definitional equality**: `cantor_f(q)` unfolds to `limit_f(iso.symm(q).val)`. Proofs that compose this with limit-level theorems may need explicit `show` or `change` steps.

3. **NonMinOrder/NoMaxOrder proofs**: These require composing seriality axioms with limit resolution theorems. The composition itself is straightforward but may require careful term construction for the seriality axiom application.

4. **box_stable_in_chronicle_fmcs**: This theorem (line 234) uses forward_G and backward_H from chronicle_fmcs. Once cantor_fmcs replaces chronicle_fmcs, the proof should transfer directly since it only uses the FMCS fields abstractly.

5. **Eval family at 0**: The `dd_countermodel_chronicle` currently uses `shifted_chronicle_fmcs M h_mcs 0` as the eval family and evaluates at time `0`. With cantor_fmcs, the eval family would be `shifted_cantor_fmcs M h_mcs cantor_zero` evaluated at `cantor_zero`. The existential `exists ... (t : D), neg truth_at ...` can use `t = cantor_zero` instead of `t = 0`.
