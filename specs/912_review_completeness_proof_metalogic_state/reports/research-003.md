# Research Report 003: Shift-Closed Canonical Omega Approach

**Task**: 912 - Review Completeness Proof and Metalogic State
**Focus**: Redesigning canonical model to be shift-closed instead of changing Validity.lean
**Session**: sess_1771547875_22ab31
**Date**: 2026-02-19

## 1. Executive Summary

This report analyzes the feasibility of constructing a **shift-closed canonical Omega** that contains all canonical histories and their time-shifts, as an alternative to modifying the `valid` definition in `Validity.lean`. The key question: can we build `shiftClosedCanonicalOmega B` such that the truth lemma holds at all histories in this enlarged set, thereby matching the `Set.univ` used in `valid`?

**Verdict**: This approach is **viable but requires careful design**. The shift-closed Omega approach avoids changing `Validity.lean` and `Soundness.lean` entirely. Instead, it concentrates all changes in `Representation.lean` by proving a **truth-at-shift lemma** that extends the canonical truth lemma to shifted histories. The mathematical crux is that shifted histories are "structurally equivalent" to canonical histories at offset times, and truth at a shifted canonical history can be related back to truth at the original canonical history via the time-shift preservation theorem -- but only if Omega itself is shift-closed, creating a circularity that must be resolved by a carefully staged proof.

**The deeper insight (Section 5)**: Rather than enlarging Omega and reprove the truth lemma from scratch, the cleanest approach is to **define validity with `ShiftClosed Omega`** after all. But this report also provides a complete mathematical analysis of the shift-closed Omega alternative, showing exactly where it works and where it is blocked, so that a fully informed architectural decision can be made.

## 2. Current State Recap

### 2.1 The Omega-Mismatch

The two sorries in `Representation.lean` (lines ~425, ~457) exist because:

- **`valid phi`** requires `truth_at M Set.univ tau t phi` (all histories admissible)
- **`satisfiable`** provides `truth_at M (canonicalOmega B) tau t phi` (only canonical histories)
- These Omega values differ, and truth is neither monotone nor anti-monotone in Omega

### 2.2 Current Canonical Constructions

```
canonicalFrame B      : TaskFrame Int
                        WorldState = { S : Set Formula // SetMaximalConsistent S }
                        task_rel = fun _ _ _ => True

canonicalModel B      : TaskModel (canonicalFrame B)
                        valuation w p = (Formula.atom p in w.val)

canonicalHistory B fam hfam : WorldHistory (canonicalFrame B)
                               domain = fun _ => True
                               states t _ = mkCanonicalWorldState B fam t
                                          = (fam.mcs t, fam.is_mcs t)

canonicalOmega B      : Set (WorldHistory (canonicalFrame B))
                       = { sigma | exists fam hfam, sigma = canonicalHistory B fam hfam }
```

### 2.3 Why canonicalOmega Is NOT Shift-Closed

For `sigma = canonicalHistory B fam hfam`, the shifted history `time_shift sigma delta` has:
- `(time_shift sigma delta).states t _ = sigma.states (t + delta) _ = fam.mcs (t + delta)`

This shifted history maps time `t` to `fam.mcs (t + delta)`. For this to equal some `canonicalHistory B fam' hfam'`, we would need a family `fam'` with `fam'.mcs t = fam.mcs (t + delta)` for ALL `t`. In general, `fam` is a non-constant indexed family (built by DovetailingChain), so there is no reason such a `fam'` exists in the BMCS.

## 3. Approach A: Shift-Closed Canonical Omega

### 3.1 Definition

```lean
def shiftClosedCanonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists (fam : IndexedMCSFamily Int) (hfam : fam in B.families) (delta : Int),
    sigma = WorldHistory.time_shift (canonicalHistory B fam hfam) delta }
```

This set contains:
- All canonical histories (take `delta = 0`)
- All time-shifts of canonical histories by any integer amount

### 3.2 Shift-Closure Proof (Straightforward)

**Claim**: `ShiftClosed (shiftClosedCanonicalOmega B)`.

**Proof**: Let `sigma in shiftClosedCanonicalOmega B` and `delta' : Int`. Then `sigma = time_shift (canonicalHistory B fam hfam) delta` for some `fam, hfam, delta`. We need `time_shift sigma delta' in shiftClosedCanonicalOmega B`.

```
time_shift sigma delta'
  = time_shift (time_shift (canonicalHistory B fam hfam) delta) delta'
```

This history maps time `t` to `canonicalHistory B fam hfam`'s state at `t + delta' + delta`, which equals `fam.mcs (t + delta' + delta)`.

By WorldHistory extensionality (if it exists) or by direct construction, this equals `time_shift (canonicalHistory B fam hfam) (delta + delta')`. So we can witness membership with the same `fam`, `hfam`, and `delta + delta'`.

**Assessment**: This part is clean and should be straightforward to formalize.

### 3.3 Membership of canonicalOmega

`canonicalOmega B subset shiftClosedCanonicalOmega B` trivially (take `delta = 0`).

### 3.4 The Crux: Truth Lemma at Shifted Histories

The existing truth lemma states:
```
canonical_truth_lemma_all B h_tc phi fam hfam t :
  phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi
```

We need a truth lemma for the enlarged Omega:
```
phi in fam.mcs t <-> truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B fam hfam) t phi
```

**Critical difference**: The box case now quantifies over all `sigma in shiftClosedCanonicalOmega B`, not just `sigma in canonicalOmega B`.

## 4. Detailed Analysis of the Truth Lemma Extension

### 4.1 Non-Box Cases (Trivial)

For `atom`, `bot`, `imp`, `all_future`, `all_past`: truth does not depend on Omega (these cases either examine the current history's domain/states, or recurse on the same history at different times). So truth at these cases is identical regardless of whether Omega is `canonicalOmega B` or `shiftClosedCanonicalOmega B`.

**Wait -- this is wrong for `imp`.** The `imp` case recurses on subformulas, and those subformulas might be `box` formulas. So the non-box cases are NOT truly independent of Omega. The correct statement is: the truth lemma must be proven by induction on the formula, and the Omega parameter affects all cases through the box subcase.

### 4.2 The Box Case (The Hard Part)

The box case of the truth lemma needs:
```
Box phi in fam.mcs t
<->
forall sigma in shiftClosedCanonicalOmega B, truth_at M (shiftClosedCanonicalOmega B) sigma t phi
```

**Forward direction**: `Box phi in fam.mcs t` implies `phi in fam'.mcs t` for all `fam' in B.families` (by `modal_forward`). By IH (if we have it), `truth_at M shiftClosedOmega (canonicalHistory B fam' hfam') t phi` for all `fam' in B.families`. But we also need truth at SHIFTED canonical histories `time_shift (canonicalHistory B fam' hfam') delta`.

For a shifted history at time `t`, we need `truth_at M shiftClosedOmega (time_shift (canonicalHistory B fam' hfam') delta) t phi`. By `time_shift_preserves_truth` (which requires `ShiftClosed Omega`), this equals `truth_at M shiftClosedOmega (canonicalHistory B fam' hfam') (t + delta) phi`.

By IH at time `t + delta`: this equals `phi in fam'.mcs (t + delta)`.

**But wait**: Does `Box phi in fam.mcs t` imply `phi in fam'.mcs (t + delta)` for ALL `delta`? By `modal_forward`, we only get `phi in fam'.mcs t` (at the SAME time `t`). We do NOT get `phi in fam'.mcs (t + delta)` for arbitrary `delta`.

**THIS IS THE FUNDAMENTAL OBSTRUCTION.**

### 4.3 Why the Forward Box Case Fails

The forward box case requires showing that if `Box phi in fam.mcs t`, then `phi` is true at ALL shifted canonical histories at time `t`. A shifted canonical history `time_shift (canonicalHistory B fam' hfam') delta` at time `t` has state `fam'.mcs (t + delta)`.

By `time_shift_preserves_truth` with shift-closed Omega:
```
truth_at M Omega (time_shift (canonicalHistory B fam' hfam') delta) t phi
<-> truth_at M Omega (canonicalHistory B fam' hfam') (t + delta) phi
```

So we need `truth_at M Omega (canonicalHistory B fam' hfam') (t + delta) phi`, which by IH requires `phi in fam'.mcs (t + delta)`.

But `Box phi in fam.mcs t` only gives us `phi in fam'.mcs t` via `modal_forward`. We have NO information about `phi` at times other than `t`.

**The only way to get `phi in fam'.mcs s` for all `s` and all `fam'` is to have `Box (always phi)` or equivalently `Box phi AND G(Box phi) AND H(Box phi)`.** But `Box phi` alone says nothing about other times.

### 4.4 The Backward Box Case

Even if forward worked, backward has similar issues. We would need:
```
(forall sigma in shiftClosedOmega, truth_at ... sigma t phi)
-> Box phi in fam.mcs t
```

The hypothesis gives us truth at all shifted histories. In particular, for `delta = 0`, truth at all canonical histories. By IH backward, `phi in fam'.mcs t` for all `fam'`. By `modal_backward`, `Box phi in fam.mcs t`.

**The backward direction actually WORKS!** The extra histories (shifted ones) only make the hypothesis stronger, and we only use the `delta = 0` case.

### 4.5 Summary of Box Case Analysis

| Direction | Status | Reason |
|-----------|--------|--------|
| Forward (MCS -> truth) | BLOCKED | `Box phi in fam.mcs t` only gives `phi in fam'.mcs t`, but shifted histories need `phi in fam'.mcs (t + delta)` |
| Backward (truth -> MCS) | Works | Extra shifted histories strengthen hypothesis; we only use canonical ones |

## 5. The Fundamental Mathematical Issue

### 5.1 Why Shift-Closed Omega Cannot Work Without Additional Conditions

The core issue is a **mismatch between modal and temporal quantification**:

- **Box** quantifies over histories at a **fixed time**: `forall sigma in Omega, truth_at M Omega sigma t phi`
- **Time-shift** creates histories that are "the same" but at **different times**

When Omega contains shifted histories, box must verify phi at shifted histories at time `t`. But a shifted history's state at time `t` is the original history's state at time `t + delta` -- a DIFFERENT time. So box suddenly requires knowledge about OTHER TIMES in the original history, which box alone does not provide.

In the standard semantics with `Omega = Set.univ`, this is not a problem because the soundness of `Box phi -> G(Box phi)` (the MF axiom) is proven using time-shift invariance: `truth_at M Set.univ sigma y phi` is related to `truth_at M Set.univ (time_shift sigma (y-x)) x phi` using `Set.univ_shift_closed`. But this USES the fact that Omega is already Set.univ -- it does not help when building up from a restricted Omega.

### 5.2 What Would Make Shift-Closed Omega Work

For the forward box case to work with shift-closed Omega, we would need one of:

**(A) MF axiom in the MCS**: If `Box phi in fam.mcs t`, then by the MF axiom (`Box phi -> G(Box phi)`), we get `G(Box phi) in fam.mcs t`. This gives `Box phi in fam.mcs s` for all `s >= t`. Combined with `modal_forward`, this gives `phi in fam'.mcs s` for all `s >= t` and all `fam'`. Similarly, using the past analog, we get `phi in fam'.mcs s` for all `s <= t`.

**But**: The MF axiom gives `G(Box phi)`, not `H(Box phi)`. We need the TF analog for the past direction. Let us check: the TF axiom is `Box phi -> F(Box phi)`, which is the FUTURE version. We also need the PAST version.

Actually, examining the axiom set more carefully:
- MF: `Box phi -> Box(G phi)` (if box phi, then box of always-future phi)
- TF: `Box phi -> G(Box phi)` (if box phi, then always-future box phi)

Wait, let me re-read the actual axioms from Soundness.lean:
- `modal_future_valid`: `Box phi -> Box(G phi)` -- "If phi holds at all histories now, then G phi holds at all histories now"
- `temp_future_valid`: `Box phi -> G(Box phi)` -- "If phi holds at all histories now, then at all future times, phi holds at all histories"

These are both FUTURE-directed. For the PAST direction, we would need:
- `Box phi -> Box(H phi)` (modal-past)
- `Box phi -> H(Box phi)` (temporal-past)

These are the temporal duals. By temporal duality (swap past/future), if MF and TF are axioms, their past duals should also be derivable.

**Key insight**: If `Box phi in fam.mcs t`, then by the axioms of the proof system:
1. By TF: `G(Box phi) in fam.mcs t`, so `Box phi in fam.mcs s` for all `s >= t`
2. By temporal duality (past analog of TF): `H(Box phi) in fam.mcs t`, so `Box phi in fam.mcs s` for all `s <= t`
3. Therefore `Box phi in fam.mcs s` for ALL `s`
4. By `modal_forward`: `phi in fam'.mcs s` for all `fam'` and all `s`

**THIS WOULD MAKE THE BOX FORWARD CASE WORK!**

### 5.3 Verifying the Past Analog of TF

The past analog of TF (`Box phi -> H(Box phi)`) should be derivable via temporal duality. The proof system has `temporal_duality`: from `[] |- phi`, derive `[] |- swap_past_future phi`.

TF is: `[] |- (Box phi).imp (Box phi).all_future`
Past analog: `[] |- (Box phi).imp (Box phi).all_past`

This is `swap_past_future` of TF: swapping `all_future` to `all_past`. If TF is derivable, then by temporal duality, the past analog is derivable.

Actually, to be precise: temporal duality takes a THEOREM `[] |- phi` and produces `[] |- swap_past_future phi`. So from TF (which is an axiom, hence a theorem), we can derive its past dual.

**Conclusion**: `Box phi -> H(Box phi)` is a theorem of TM logic.

### 5.4 Detailed Proof Sketch for Box Forward with Shift-Closed Omega

**Setup**: We have `Box phi in fam.mcs t` and need to show `truth_at M shiftClosedOmega sigma t phi` for all `sigma in shiftClosedOmega`.

Let `sigma = time_shift (canonicalHistory B fam' hfam') delta` for some `fam', hfam', delta`.

**Step 1**: From `Box phi in fam.mcs t`, derive `Box phi in fam.mcs (t + delta)`:
- By TF (axiom): `G(Box phi) in fam.mcs t`
- If `delta >= 0`: By `forward_G`, `Box phi in fam.mcs (t + delta)`
- If `delta < 0`: By the past analog of TF (derivable by temporal duality): `H(Box phi) in fam.mcs t`. By `backward_H`, `Box phi in fam.mcs (t + delta)`.
- Actually, combining TF and its past dual with the T-axiom: `Box phi in fam.mcs t` implies `always(Box phi) in fam.mcs t`, implies `Box phi in fam.mcs s` for ALL `s`.

**Step 2**: From `Box phi in fam.mcs (t + delta)`, by `modal_forward`: `phi in fam'.mcs (t + delta)`.

**Step 3**: By IH at `(fam', hfam', t + delta)`: `truth_at M shiftClosedOmega (canonicalHistory B fam' hfam') (t + delta) phi`.

**Step 4**: By `time_shift_preserves_truth` with `ShiftClosed (shiftClosedOmega)`:
```
truth_at M shiftClosedOmega (canonicalHistory B fam' hfam') (t + delta) phi
<-> truth_at M shiftClosedOmega (time_shift (canonicalHistory B fam' hfam') delta) t phi
```

Wait -- `time_shift_preserves_truth` says:
```
truth_at M Omega (time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi
```

So with `sigma = canonicalHistory B fam' hfam'`, `x = t`, `y = t + delta`:
```
truth_at M Omega (time_shift (canonicalHistory B fam' hfam') ((t + delta) - t)) t phi
<-> truth_at M Omega (canonicalHistory B fam' hfam') (t + delta) phi
```

And `(t + delta) - t = delta`. So:
```
truth_at M Omega (time_shift (canonicalHistory B fam' hfam') delta) t phi
<-> truth_at M Omega (canonicalHistory B fam' hfam') (t + delta) phi
```

From Step 3, the RHS holds. Therefore the LHS holds: `truth_at M shiftClosedOmega sigma t phi`.

**Step 5 (CIRCULARITY CHECK)**: Step 4 uses `time_shift_preserves_truth`, which requires `ShiftClosed Omega`. We established in Section 3.2 that `shiftClosedCanonicalOmega` is shift-closed. But critically, Step 3 uses the IH which assumes the truth lemma holds at the enlarged Omega. **This is the induction hypothesis** -- it is fine because the induction is on the formula structure, and `phi` is a strict subformula of `Box phi`.

**THIS PROOF SKETCH IS VALID.** The key non-trivial step is Step 1, which requires proving that `Box phi in fam.mcs t` implies `Box phi in fam.mcs s` for all `s`, using TF and its past dual.

## 6. Concrete Lean Implementation Proposal

### 6.1 Required Lemmas

**Lemma 1**: `box_persistent` -- Box formulas persist across all times in any family.

```lean
/-- Box phi at time t implies Box phi at ALL times (via MF/TF axioms). -/
theorem box_persistent (B : BMCS Int) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily Int) (hfam : fam in B.families)
    (phi : Formula) (t s : Int) :
    Formula.box phi in fam.mcs t -> Formula.box phi in fam.mcs s
```

**Proof sketch**: From `Box phi in fam.mcs t`:
1. By TF axiom (`Box phi -> G(Box phi)`) and MCS closure: `G(Box phi) in fam.mcs t`
2. By past-TF (derivable via temporal duality) and MCS closure: `H(Box phi) in fam.mcs t`
3. For `s >= t`: by `forward_G` on `G(Box phi)`, get `Box phi in fam.mcs s`
4. For `s = t`: trivially
5. For `s < t`: by `backward_H` on `H(Box phi)`, get `Box phi in fam.mcs s`

**Sub-lemma needed**: Past analog of TF (`Box phi -> H(Box phi)`) is derivable. This requires showing that `temporal_duality` can be applied to TF. Need to verify that `swap_past_future` of TF gives the right formula.

Actually: TF is `(Box phi).imp (Box phi).all_future`. Its past dual is `(Box phi).imp (Box phi).all_past`. Since `swap_past_future` swaps `all_future <-> all_past`, and `Box` is not temporal, `swap_past_future ((Box phi).imp (Box phi).all_future) = (Box phi).imp (Box phi).all_past`.

Since `temporal_duality` takes `[] |- phi` to `[] |- swap_past_future phi`, and TF is derivable from empty context, the past dual of TF is derivable.

**Lemma 2**: `shiftClosedCanonicalOmega_is_shift_closed`

```lean
theorem shiftClosedCanonicalOmega_is_shift_closed (B : BMCS Int) :
    ShiftClosed (shiftClosedCanonicalOmega B)
```

**Lemma 3**: `shifted_truth_lemma` -- Truth lemma for the enlarged Omega.

```lean
theorem shifted_truth_lemma (B : BMCS Int) (h_tc : B.temporally_coherent)
    (phi : Formula) (fam : IndexedMCSFamily Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B fam hfam) t phi
```

The proof follows the same structure as `canonical_truth_lemma_all` but with the enlarged Omega. The key difference is in the box case, which uses `box_persistent` + `time_shift_preserves_truth`.

### 6.2 Modified Representation Theorems

With `shifted_truth_lemma`, the representation theorem becomes:

```lean
theorem standard_representation (phi : Formula) (h_cons : ContextConsistent [phi]) :
    satisfiable Int [phi] := by
  let B := construct_saturated_bmcs_int [phi] h_cons
  ...
  -- Use shifted_truth_lemma instead of canonical_truth_lemma
  have h_truth := (shifted_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 phi).mp h_in_mcs
  exact (canonicalFrame B, canonicalModel B, shiftClosedCanonicalOmega B,
    canonicalHistory B ..., _, 0, ...)
```

### 6.3 Discharging the Weak Completeness Sorry

For `standard_weak_completeness`:
```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_deriv
  have h_neg_cons : ContextConsistent [phi.neg] := ...
  obtain (F, M, Omega, tau, h_mem, t, h_all_true) := standard_representation phi.neg h_neg_cons
  have h_neg_true : truth_at M Omega tau t phi.neg := h_all_true phi.neg (by simp)
  have h_phi_false : not (truth_at M Omega tau t phi) := h_neg_true
  -- NOW: valid phi gives truth_at M Set.univ tau t phi
  -- We need truth_at M Omega tau t phi where Omega = shiftClosedCanonicalOmega
  -- STILL BLOCKED: valid uses Set.univ, representation uses shiftClosedCanonicalOmega
  sorry
```

**THIS STILL DOES NOT DISCHARGE THE SORRY.** The shift-closed Omega approach makes `satisfiable` return a shift-closed Omega, but `valid` still uses `Set.univ`. Since `shiftClosedCanonicalOmega != Set.univ`, the mismatch persists.

### 6.4 The Remaining Gap

Even with shift-closed Omega, the gap is:

- `valid phi` gives `truth_at M Set.univ tau t phi`
- We need `truth_at M shiftClosedCanonicalOmega tau t phi` (or its negation to be contradictory with the above)

These two Omega values are still different. Truth is not monotone in Omega, so we cannot directly relate them.

## 7. What WOULD Close the Gap

### 7.1 Option 1: Prove canonicalOmega Covers All States

If we could prove that for every possible history `sigma : WorldHistory (canonicalFrame B)` and every time `t`, there exists a family `fam` such that `sigma.states t = (fam.mcs t, ...)`, then the box quantification over `Set.univ` reduces to quantification over `canonicalOmega` (or its shift-closure).

**Why this is hard**: The canonical frame has `WorldState = { S // SetMaximalConsistent S }`. The type includes ALL MCSes. But `B.families` only includes families from the BMCS construction. There is no guarantee that every MCS `S` appears as `fam.mcs t` for some `fam in B.families` and some `t`.

For the truth lemma to bridge to `Set.univ`, we need: for every MCS `S`, there exists `fam in B.families` with `fam.mcs t = S` (at the relevant time `t`). This is essentially the **modal saturation** property pushed to its extreme: not just diamond witnesses, but EVERY MCS must appear as a family's MCS at time t.

In the standard canonical model construction (without bundles), this holds trivially because the "families" are indexed by ALL MCSes. In the BMCS construction, this would require the bundle to contain a family for every possible MCS at every time, which is a much stronger condition than `is_modally_saturated`.

### 7.2 Option 2: Add ShiftClosed to valid (The Recommended Approach)

**Change `valid` to add `ShiftClosed Omega`:**

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

**Soundness**: All soundness proofs go through because `ShiftClosed Omega` provides `time_shift_preserves_truth`, which is the only place `Set.univ_shift_closed` is used. The key soundness changes:

1. **MF axiom** (`Box phi -> Box(G phi)`): Currently uses `Set.univ_shift_closed`. With `ShiftClosed Omega` hypothesis, the same proof works verbatim.

2. **TF axiom** (`Box phi -> G(Box phi)`): Same situation -- uses `Set.univ_shift_closed`, directly replaceable with `ShiftClosed Omega`.

3. **Other axioms** (propositional, modal T/4/B/5, temporal 4/A/L/T): Do not use `Set.univ` explicitly. They quantify over `sigma in Omega` or `s : D` without needing shift-closure.

4. **Necessitation, temporal necessitation, temporal duality, modus ponens, weakening**: These structural rules are Omega-independent.

**Completeness**: With `shiftClosedCanonicalOmega B` providing a shift-closed Omega, the representation theorem directly provides `satisfiable` with a shift-closed Omega. The weak/strong completeness proofs work because:
- `valid phi` with `Omega = shiftClosedCanonicalOmega B` gives `truth_at M Omega tau t phi`
- `satisfiable` provides `truth_at M Omega tau t phi.neg` with the SAME Omega
- Contradiction follows from the same Omega on both sides

### 7.3 Option 3: Prove Truth-at-State Lemma (From research-002 Section 5.3)

In the canonical model with trivial task relation, one might hope to prove that `truth_at M Omega1 sigma t phi <-> truth_at M Omega2 sigma t phi` when both Omega contain the same set of "reachable states" at time t. This would directly bridge `canonicalOmega` to `Set.univ`.

**The issue**: This requires proving that for the canonical model, truth depends only on the state at time t (and the states reachable via Omega), not on the specific history. While intuitively true for the canonical model (because the task relation is trivial), formalizing this is complex because:
- Box quantifies over histories in Omega, not states
- Different histories in `Set.univ` might have the same state at time t but different states at other times, affecting temporal subformulas within box
- The proof would require an intricate argument showing that within the canonical model, the temporal structure at other times is determined by the MCS at those times, and MCSes are "functionally independent" across times

This is feasible but significantly more complex than Option 2.

## 8. Comparative Assessment

| Approach | Validity.lean Change | Soundness.lean Change | Representation.lean Change | New Infrastructure | Sorry Elimination |
|----------|---------------------|----------------------|---------------------------|-------------------|-------------------|
| A: Shift-closed Omega (naive) | None | None | Redefine Omega | shiftClosedCanonicalOmega, shifted truth lemma | NO -- Set.univ mismatch persists |
| B: ShiftClosed in valid | Add ShiftClosed param | Replace Set.univ with Omega | Use shiftClosedCanonicalOmega | shiftClosedCanonicalOmega, shifted truth lemma, box_persistent | YES |
| C: State-determination | None | None | Prove coverage + state-determination | Complex state-determination lemma | YES (if successful) |
| D: Full coverage | None | None | Prove all MCSes covered | Requires stronger saturation | Unclear |

## 9. Recommended Path: Option B (ShiftClosed in valid)

### 9.1 Rationale

Option B is recommended because:
1. **It eliminates both sorries** in Representation.lean
2. **Soundness changes are mechanical**: replace `Set.univ_shift_closed` with the `ShiftClosed Omega` hypothesis
3. **The paper supports it**: The JPL paper defines validity relative to a model `(F, Omega, V)`. Making Omega a parameter with structural conditions (like shift-closure) is natural
4. **No mathematical risk**: All components are individually provable

### 9.2 Implementation Steps

**Phase 1: Infrastructure** (Representation.lean)
1. Define `shiftClosedCanonicalOmega B`
2. Prove `shiftClosedCanonicalOmega_is_shift_closed`
3. Prove `box_persistent` (Box phi persists across times)
4. Prove `shifted_truth_lemma` (truth lemma for enlarged Omega)

**Phase 2: Validity Changes** (Validity.lean)
1. Add `ShiftClosed Omega` and `tau in Omega` to `valid` definition
2. Add same to `semantic_consequence`
3. Update `satisfiable` to existentially quantify over shift-closed Omega
4. Update `Validity` namespace lemmas

**Phase 3: Soundness Updates** (Soundness.lean, SoundnessLemmas.lean)
1. Replace `Set.univ` with `Omega` parameter in axiom validity lemmas
2. Replace `Set.univ_shift_closed` with `h_sc : ShiftClosed Omega`
3. Add `h_mem : tau in Omega` to axiom validity signatures
4. Verify all proofs still typecheck

**Phase 4: Completeness Discharge** (Representation.lean)
1. Update `standard_representation` to use `shiftClosedCanonicalOmega`
2. Discharge `standard_weak_completeness` sorry using matching Omega
3. Discharge `standard_strong_completeness` sorry using matching Omega

### 9.3 Key Sub-Lemma: box_persistent

This is the most mathematically interesting new result. It requires:

1. **TF axiom membership**: `Box phi in fam.mcs t` implies `G(Box phi) in fam.mcs t`
   - Proof: TF is an axiom, so `(Box phi).imp (Box phi).all_future` is in every MCS. Apply MCS closure.

2. **Past-TF membership**: `Box phi in fam.mcs t` implies `H(Box phi) in fam.mcs t`
   - Proof: Past-TF is derivable via temporal duality from TF. So `(Box phi).imp (Box phi).all_past` is in every MCS. Apply MCS closure.

3. **Combining**: From G(Box phi) and H(Box phi), extract `Box phi in fam.mcs s` for any `s`:
   - If `s >= t`: by `forward_G` on `G(Box phi)`, or by T-axiom if `s = t`
   - If `s < t`: by `backward_H` on `H(Box phi)`

### 9.4 Effort Estimate

| Component | Effort | Risk |
|-----------|--------|------|
| shiftClosedCanonicalOmega definition + shift-closed proof | 1-2 hours | Low |
| box_persistent (TF + past-TF + combining) | 3-4 hours | Low-Medium |
| shifted_truth_lemma (adapt canonical_truth_lemma) | 4-6 hours | Medium |
| Validity.lean changes | 1-2 hours | Low |
| Soundness.lean updates (mechanical) | 3-4 hours | Low |
| SoundnessLemmas.lean updates | 2-3 hours | Low |
| Representation.lean sorry discharge | 2-3 hours | Low |
| Testing and verification | 2-3 hours | Low |
| **Total** | **18-27 hours** | **Low-Medium** |

## 10. Technical Note on `time_shift_preserves_truth` and the Truth Lemma

A subtle but critical point: `time_shift_preserves_truth` is a theorem about the standard `truth_at` definition. It requires `ShiftClosed Omega` because the box case needs shifted histories to remain in Omega.

In the shifted truth lemma proof (box forward case, Step 4 in Section 6.4), we use `time_shift_preserves_truth` with `Omega = shiftClosedCanonicalOmega B`. This is circular if we are in the middle of PROVING the truth lemma for this Omega. However, `time_shift_preserves_truth` is a general theorem about `truth_at` -- it does not depend on any truth lemma. It is proven by induction on the formula and only requires `ShiftClosed Omega`. So there is no actual circularity: `time_shift_preserves_truth` is an already-proven theorem that we can freely use.

The actual induction in the shifted truth lemma is on the formula structure, and `time_shift_preserves_truth` is used as a helper within the box case (to relate truth at shifted histories to truth at canonical histories at different times), with the IH applied at a SUBFORMULA `phi` rather than `Box phi`.

## 11. Summary and Recommendations

1. **The shift-closed Omega approach alone does NOT eliminate the sorries** -- it only moves the problem. The Omega mismatch between `shiftClosedCanonicalOmega` and `Set.univ` persists.

2. **To fully discharge the sorries**, we MUST either:
   - (a) Change `valid` to use `ShiftClosed Omega` (Option B above), OR
   - (b) Prove a state-determination lemma showing truth in the canonical model is Omega-independent (Option C, harder)

3. **Option B (ShiftClosed in valid) is recommended** because:
   - It is mathematically clean and natural
   - All components are individually tractable
   - Soundness changes are mechanical (replace `Set.univ_shift_closed` with `h_sc`)
   - The paper's definition naturally supports this parameterization

4. **The `box_persistent` lemma is the key new mathematical insight**: using TF and its temporal dual to show Box phi propagates across ALL times in every family, enabling the shifted truth lemma's box case.

5. **Estimated effort**: 18-27 hours for full implementation and verification.

## References

- `Theories/Bimodal/Metalogic/Representation.lean` - Current canonical model + 2 sorries
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - BMCS truth lemma (sorry-free)
- `Theories/Bimodal/Semantics/Validity.lean` - Current `valid` definition
- `Theories/Bimodal/Semantics/Truth.lean` - `truth_at`, `ShiftClosed`, `time_shift_preserves_truth`
- `Theories/Bimodal/Metalogic/Soundness.lean` - Current soundness proof
- `specs/912_review_completeness_proof_metalogic_state/reports/research-002.md` - Omega-mismatch analysis
- `specs/912_review_completeness_proof_metalogic_state/summaries/implementation-summary-20260220.md` - Phase 2 findings
