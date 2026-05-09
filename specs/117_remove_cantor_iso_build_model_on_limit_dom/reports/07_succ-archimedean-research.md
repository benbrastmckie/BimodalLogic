# Research Report: IsSuccArchimedean for LimitDomSubtype (Discrete Case)

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: Research complete -- proof strategy found
- **Type**: lean4
- **Artifacts**: reports/07_succ-archimedean-research.md

## Executive Summary

Two viable approaches exist for resolving the sorry at `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:539). **Approach A** (recommended) eliminates the need for `IsSuccArchimedean` entirely by building the countermodel directly on `LimitDomSubtype` instead of `Int`. **Approach B** proves `IsSuccArchimedean` via a two-phase well-founded induction. Both are detailed below.

**Key findings**:

1. **Burgess does NOT need IsSuccArchimedean**: Reading Burgess 1982 carefully, the truth lemma (Claim 2.11) works for ANY linear order X satisfying C0-C5. Burgess defines X = union of dom f_n and builds the countermodel directly on X. He never claims X is Z-isomorphic in the discrete case. The Z-isomorphism is an artifact of the codebase's infrastructure, not a mathematical necessity.

2. **The cascade for U(T,bot) terminates after ONE split**: In Burgess's Lemma 2.10 (C5 elimination), Case n=m+1, sub-case (ii) checks whether `xi in f(x')` AND `eta in g(x, x')`. For `U(T, bot)`, `xi = T` (always in f) and `eta = bot`. After the split inserts z between x and x', the new g(x, z) = B' contains `bot` (from Lemma 2.7: `eta in B'`). So the NEXT time C5 for U(T,bot) at x is processed, sub-case (ii) applies and no further insertion occurs. There is NO infinite cascade.

3. **Alternative approach bypasses the sorry entirely**: Since `dd_countermodel_chronicle` does not exist yet (Phase 7), the countermodel's carrier type `D` is not yet committed. Using `D = LimitDomSubtype A h_mcs` (with the subtype's linear order inherited from Rat) eliminates the need for Z-isomorphism and hence for `IsSuccArchimedean`.

4. **If IsSuccArchimedean IS needed**: A two-phase well-founded induction works (Approach B). Phase 1: prove `pred^[k](b) = a` by strong induction on `|dom_N ∩ [a.val, b.val]|`. Phase 2: convert to `succ^[k](a) = b` via `succ_pred`. Estimated 60-80 lines.

5. **The cascade concern is moot**: Even ignoring the "one split" observation, the discrete hypothesis guarantees every point has an immediate predecessor (via `limit_dom_has_pred`), which structurally prevents accumulation points in the limit domain.

---

## 0. Burgess 1982 Analysis

### 0.1 Section 1.6 -- Discrete variant

Burgess axiomatizes discreteness by `G'bot /\ H'bot` (where `G'bot = U(T, bot)` and `H'bot = S(T, bot)`). He states: "For the reader familiar with ordinary G,H-tense logic, the adaptation of our work below to prove these variants is a routine exercise." He does NOT claim the domain X is Z-isomorphic, nor does he need `IsSuccArchimedean`. His completeness proof for the discrete variant works exactly like the base case: build X = union of dom f_n, verify C0-C5, invoke the truth lemma.

### 0.2 Lemma 2.10 -- C5 counterexample elimination for U(T, bot)

Burgess's Lemma 2.10 eliminates C5 counterexamples for `U(xi, eta) in f(x)` by induction on the number of domain points after x.

**Case n=m+1** (x has a finite-stage successor x'):
- *Sub-case (i)*: `eta /\ U(xi, eta) in f(x')` AND `eta in g(x, x')`. For `U(T, bot)`: requires `bot /\ U(T, bot) in f(x')`, which is impossible since bot is never in an MCS. So **(i) ALWAYS FAILS** for U(T, bot).
- *Sub-case (ii)*: `xi in f(x')` AND `eta in g(x, x')`. For `U(T, bot)`: requires `T in f(x')` (always true) AND `bot in g(x, x')`. So **(ii) holds iff `bot in g(x, x')`**.
- *Split case*: When both (i) and (ii) fail, Lemmas 2.7/2.8 produce B', D, B'' with `eta in B'` (Lemma 2.7). For `U(T, bot)`, **`bot in B' = g'(x, z)`** where z is the new midpoint.

**Critical consequence**: After ONE split (inserting z between x and x'), `g'(x, z) = B'` contains `bot`. The next time C5 for `U(T, bot)` at x is processed, the successor of x in the domain is z, and sub-case (ii) applies since `bot in g(x, z)`. **No further insertion between x and z occurs. The cascade terminates after one step.**

### 0.3 Claim 2.11 -- Truth Lemma

The truth lemma (Claim 2.11) proves `(+): x in V(alpha) iff alpha in f(x)` by induction on formula complexity. The key case `U(beta, gamma)`:
- Forward: Uses C5a (witness y with gamma in f(y) and beta in g(x,y)) and C3 (g(x,y) subset f(z) for intermediate z).
- Backward: Uses C4a (counterexample elimination).

**The truth lemma does NOT require IsSuccArchimedean.** It works for ANY linear order X satisfying C0-C5. Burgess's proof is purely based on C0-C5 and formula induction.

### 0.4 Final construction paragraph

Burgess defines X = "the union of the sets dom f_n" with the order inherited from the rationals. He then defines V by `x in V(alpha) iff alpha in f(x)` and proves the truth lemma. He makes **no claim about X being Z-isomorphic** in the discrete case. The model is built directly on X as a linear order.

### 0.5 Implications for the codebase

The codebase's current plan (Phase 4) builds `discrete_iso : LimitDomSubtype ≃o Z` and then `discrete_fmcs : FMCS Int`. This Z-isomorphism requires `IsSuccArchimedean`.

**However**, following Burgess more closely, the countermodel can be built directly on `LimitDomSubtype` (or equivalently on `Rat` restricted to `limit_dom`). The truth lemma works for any linear order satisfying C0-C5. The existing `limit_f`, `limit_g`, `limit_satisfies_c5_strong`, `limit_satisfies_c4`, etc., already provide C0-C5 on `LimitDomSubtype`. The only thing needed is:
1. An `FMCS (LimitDomSubtype A h_mcs)` with `forward_G` and `backward_H` (already available as `limit_forward_G` and `limit_backward_H`).
2. A `BFMCS (LimitDomSubtype A h_mcs)` with modal coherence.
3. The truth lemma application.

Since `dd_countermodel_chronicle` does not exist yet, the carrier type `D` is uncommitted. Using `D = LimitDomSubtype A h_mcs` directly would eliminate the need for both the Z-isomorphism and `IsSuccArchimedean`.

---

## 1. Analysis of the Accumulation Concern

### 1.1 The cascading insertion scenario

The task description raises the concern that C5 insertions for `U(T,bot)` could cascade infinitely between two fixed points `a` and `b`:

1. `a` and `b` are adjacent in `dom_N`
2. C5 for `U(T,bot)` at `a` inserts `w_1 = (a + b) / 2` between `a` and `b`
3. C5 for `U(T,bot)` at `w_1` inserts `w_2 = (w_1 + b) / 2` between `w_1` and `b`
4. This generates `w_n = a/2^n + b(1 - 1/2^n)` converging to `b`

**Why this cascade CAN happen during construction**: The C5 walk for `U(T,bot)` at a point `x` with successor `x'` in the finite-stage domain ALWAYS uses the split case (condition (i) fails because `bot` is never in any MCS). The split inserts a midpoint `z = (x + x') / 2`.

### 1.2 Why the cascade does NOT break IsSuccArchimedean

The cascade creates infinitely many points `w_1 < w_2 < ...` approaching `b` from below. However, `limit_dom_has_pred` at `b` (proved from `S(T,bot) in limit_f(b)` via `limit_satisfies_c5'_strong`) gives a point `pred(b)` with **no limit domain points between `pred(b)` and `b`**.

If infinitely many `w_n` accumulate towards `b`, then for any `y < b`, there exists `w_n > y`. In particular, for `y = pred(b)`, there exists `w_n > pred(b)` with `w_n < b`, contradicting the "no domain points between pred(b) and b" property.

Therefore, the cascade MUST terminate: after finitely many insertions, the C5 counterexample for `U(T,bot)` at the latest point `w_k` is already resolved (a witness exists in the domain), so `c5_forward_resolved_no_new` applies and no further point is inserted.

### 1.3 Formalization note

The termination of the cascade is NOT something we need to prove separately. It follows from the existence of `pred(b)`, which is already a theorem in the codebase. Our proof of `IsSuccArchimedean` uses `pred(b)` directly in the well-founded recursion, sidestepping any need to analyze the cascade.

---

## 2. The Proof Strategy

### 2.1 Statement

```
noncomputable def limitDomSubtype_isSuccArchimedean (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs) _ (limitDomSubtype_succOrder A h_mcs h_discrete)
```

### 2.2 Measure definition

Given `a <= b` in `LimitDomSubtype`:

1. Extract stages: `a.val in dom_{na}` and `b.val in dom_{nb}` from the subtype proofs.
2. Set `N = max na nb`.
3. Define the measure:
   ```
   m := (dom_N.filter (fun x => decide (a.val < x && x <= b.val) = true)).card
   ```
   where `dom_N = (omega_chain_val A h_mcs N).dom`.

### 2.3 Base case: m = 0

When `m = 0`, no `dom_N` elements lie in `(a.val, b.val]`. Since `b.val in dom_N` and `a <= b`:
- If `a.val = b.val`: then `a = b` (Subtype.ext), use `n = 0`.
- If `a.val < b.val`: then `b.val in dom_N` and `a.val < b.val <= b.val`, so `b.val` is in the filter, giving `m >= 1`. Contradiction.

### 2.4 Inductive step: m > 0 implies a < b

When `m >= 1`, we have `a.val < b.val` (otherwise `m = 0`). Define `b' = pred(b)` using `limitDomSubtype_pred`.

**Key properties of pred(b)**:
- `b'.val < b.val` (from `limitDomSubtype_pred_lt`)
- `a <= b'` (from `limitDomSubtype_le_pred_of_lt` applied to `a < b`)
- No limit domain points in `(b'.val, b.val)` (from `limit_dom_has_pred`)
- `succ(b') = b` (from `limitDomSubtype_succ_pred`)

**Measure decrease**:

Define `m' = (dom_N.filter (fun x => decide (a.val < x && x <= b'.val) = true)).card`.

Claim: `m' < m`.

Proof of claim:
- Every element of `dom_N` in `(a.val, b'.val]` is also in `(a.val, b.val]` (since `b'.val < b.val`).
- No element of `dom_N` is in `(b'.val, b.val)`:
  - `dom_N` is a subset of `limit_dom` (by `omega_chain_dom_mono_le`).
  - No limit domain points are in `(b'.val, b.val)` (property of `pred(b)`).
  - Therefore `dom_N ∩ (b'.val, b.val) = emptyset`.
- So `dom_N ∩ (a.val, b'.val] = dom_N ∩ (a.val, b.val] \ {b.val}`.
- And `b.val in dom_N ∩ (a.val, b.val]` (since `a < b` and `hb_N`).
- Therefore `m' = m - 1 < m`.

**Conclusion**: By the induction hypothesis, `exists k, succ^[k](a) = b'`. Then `succ^[k+1](a) = succ(b') = b`.

### 2.5 Why no dom_N points in (pred(b), b)

This is the critical step. The argument:

1. `pred(b)` is obtained from `limit_dom_has_pred`, which uses `limit_satisfies_c5'_strong` for `S(T,bot)`.
2. The strong C5' witness gives `y < b` with `bot in limit_g(y, b)`.
3. `limit_g(y, b) = { phi | forall w in limit_dom, y < w -> w < b -> phi in limit_f(w) }`.
4. Since `bot in limit_g(y, b)`, every `w in limit_dom` with `y < w < b` has `bot in limit_f(w)`.
5. But `limit_f(w)` is an MCS, and `bot` is never in any MCS (`bot_not_in_mcs`).
6. Therefore, no `w in limit_dom` satisfies `y < w < b`.
7. Since `dom_N ⊆ limit_dom` (each `dom_N` element is in `limit_dom`), no `dom_N` element is in `(y, b) = (pred(b).val, b.val)`.

This step uses only existing theorems: `limit_dom_has_pred`, `bot_not_in_mcs`, and `omega_chain_dom_mono_le` (to show `dom_N ⊆ limit_dom`).

---

## 3. Implementation Sketch

```lean
noncomputable def limitDomSubtype_isSuccArchimedean (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs) _
      (limitDomSubtype_succOrder A h_mcs h_discrete) := by
  letI := limitDomSubtype_succOrder A h_mcs h_discrete
  constructor
  intro a b hab
  obtain <na, hna> := a.property
  obtain <nb, hnb> := b.property
  set N := max na nb
  have ha_N := omega_chain_dom_mono_le A h_mcs (le_max_left na nb) hna
  have hb_N := omega_chain_dom_mono_le A h_mcs (le_max_right na nb) hnb
  -- Measure: dom_N points in (a.val, b.val]
  set S := (omega_chain_val A h_mcs N).dom.filter
    (fun x => decide (a.val < x /\ x <= b.val) = true)
  -- Well-founded recursion on S.card
  -- Replace b with target, keep a and N fixed
  suffices h : forall (target : LimitDomSubtype A h_mcs),
      a <= target ->
      target.val in (omega_chain_val A h_mcs N).dom ->  -- NOT needed for the measure, see note
      forall (m : Nat),
      m = ((omega_chain_val A h_mcs N).dom.filter
        (fun x => decide (a.val < x /\ x <= target.val) = true)).card ->
      exists n, Order.succ^[n] a = target from
    h b hab hb_N S.card rfl
  intro target
  -- Use strong induction on m
  ... (see Section 3.1 below)
```

### 3.1 Detailed proof body (pseudo-Lean)

The proof uses `Nat.strongRecOn` or `WellFounded.fix Nat.lt.isWellFounded.wf` on the measure `m`:

```
-- Strong induction on m
intro h_le h_target_N m hm
induction m using Nat.strongRecOn with
| _ m ih =>
  by_cases h_eq : a = target
  . -- a = target: use n = 0
    exact <0, h_eq.symm>
  . -- a < target
    have h_lt : a < target := lt_of_le_of_ne h_le h_eq
    -- pred(target) < target, a <= pred(target)
    set target' := limitDomSubtype_pred A h_mcs h_discrete target
    have h_pred_lt := limitDomSubtype_pred_lt A h_mcs h_discrete target
    have h_le' := limitDomSubtype_le_pred_of_lt A h_mcs h_discrete h_lt
    have h_succ_pred := limitDomSubtype_succ_pred A h_mcs h_discrete target
    -- Compute m' and show m' < m
    set m' := ((omega_chain_val A h_mcs N).dom.filter
      (fun x => decide (a.val < x /\ x <= target'.val) = true)).card
    have h_m'_lt : m' < m := by
      rw [hm]
      apply Finset.card_lt_card
      -- show strict subset: (a, target'] ⊂ (a, target] in dom_N
      constructor
      . -- subset: x <= target' implies x < target implies x <= target
        intro x hx; simp at hx |-; exact <hx.1, hx.2.1, le_of_lt (lt_of_le_of_lt hx.2.2 h_pred_lt)>
      . -- strict: target is in (a, target] but not in (a, target']
        intro h_eq_sets
        have h_target_in : target.val in ... := by simp; exact <h_lt, le_refl _>
        ... target.val not in (a, target'] since target.val > target'.val ...
    -- Apply IH
    obtain <k, hk> := ih m' h_m'_lt h_le' rfl
    exact <k + 1, by rw [Function.iterate_succ_apply', hk, h_succ_pred]>
```

### 3.2 Important notes for implementation

1. **The `h_target_N` hypothesis is NOT strictly needed**: The measure `|dom_N ∩ (a.val, target.val]|` is well-defined for any `target`, not just those in `dom_N`. However, having `target.val in dom_N` at the top level (for `target = b`) ensures `m >= 1` when `a < b`, which avoids a separate argument. For recursive calls where `target' = pred(b)` might not be in `dom_N`, the measure still works because the base case `m = 0` correctly handles `a = target'`.

2. **Actually, we do NOT need `target in dom_N`**: When `m = 0` and `a < target`:
   - `dom_N ∩ (a.val, target.val] = emptyset`
   - But this is IMPOSSIBLE when `target.val in dom_N` (since `target` would be in the filter).
   - When `target.val not in dom_N` (e.g., for `pred(b)`), `m = 0` and `a < target` IS possible... but we showed the measure decreases, so by induction, either `a = target` (done) or `m > 0` and we recurse further.
   
   Wait, let me reconsider. If `m = 0` and `a < target`, we need to check: is this reachable? At the top level, `target = b in dom_N` and `a < b` gives `m >= 1`. In recursive calls, `target = pred(b)` and `m' < m`. If `m' = 0`, then `a <= pred(b)` and `dom_N ∩ (a.val, pred(b).val] = empty`. Either `a = pred(b)` (done with `k = 0`) or `a < pred(b)` with no dom_N points in `(a, pred(b)]`.
   
   In the latter case, `a.val in dom_N` and no dom_N points in `(a.val, pred(b).val]`, meaning `a.val` and `b.val` must be adjacent in `dom_N` (since `pred(b).val in (a.val, b.val)` and no dom_N points in `(a.val, pred(b).val] union (pred(b).val, b.val)`). But then `m = |dom_N ∩ (a.val, b.val]| = |{b.val}| = 1`, and `m' = 0 < 1`. The IH at `m' = 0` gives either `a = pred(b)` or continues recursing, but the Nat induction bottoms out at 0.
   
   **At `m' = 0`, the `by_cases` branch `a = target` handles this directly.** If `a != target` but `m' = 0`, then `a.val < target.val` and no dom_N points in `(a.val, target.val]`. Pred(target) exists with `pred(target).val < target.val`. The measure for `(a, pred(target))` is `|dom_N ∩ (a.val, pred(target).val]|` which could be 0 again. But the Nat strong induction at `m = 0` doesn't allow further recursion.

   **Resolution**: We need to handle `m = 0 ∧ a < target` explicitly. But this can't happen at the top level (where `target = b in dom_N`). For inner recursion, this means `a = target` must hold whenever `m = 0`, which follows from: `a ≤ target` and `m = 0` means no dom_N points in `(a.val, target.val]`. If `a.val < target.val`, we need `target.val not in dom_N` (otherwise `m >= 1`). But we never directly assert `target in dom_N` in the recursive calls. So `m = 0 ∧ a < target ∧ target not in dom_N` is possible but harmless -- we simply case-split on `a = target` vs `a < target` and handle both.
   
   Wait, if `m = 0` and `a < target`, can we still recurse? No, because the IH requires `m' < m = 0`, which is impossible. So at `m = 0` and `a < target`, the proof is stuck.

3. **The fix**: Reformulate the induction to avoid this issue. Instead of inducting on the measure of `(a, target]`, induct on the measure of `(a, b]` with `b` FIXED, and show the measure of `(a, pred^k(b)]` decreases at each `k`.

   Actually, the simplest fix: **generalize the statement to not require `target in dom_N`**, and at `m = 0 ∧ a < target`, derive a contradiction using the fact that `a in dom_N`, `target.val > a.val`, and `pred(target)` gives a smaller target. Since `m = 0` and `a < target`, there are no dom_N points between them. `pred(target) < target`. The measure for `pred(target)` is `|dom_N ∩ (a.val, pred(target).val]|`. But `pred(target).val < target.val` and there were already no dom_N points in `(a.val, target.val]`. So `pred(target).val` is also in this empty interval (if `a < pred(target)`), giving `m = 0` again. This means `pred^k(target)` stays in the empty interval forever, which means `pred^k(target) > a` for all `k`. But this contradicts... nothing directly.

   **The actual fix**: Use `(dom_N.filter (fun x => a.val <= x && x <= b.val)).card` (including `a`) as the measure, with `b` replaced by `target` at each step. Then at `m = 1` (just `{a}` in the interval), `a <= target` and no dom_N points in `(a, target]` means `target.val <= a.val` (since if `target.val > a.val` and `target in dom_N`, we'd have `m >= 2`; if `target not in dom_N`, then there could be no dom_N points at all in `(a, target]` while `a.val < target.val`).
   
   Hmm, this still has the same issue.

---

**CORRECTED APPROACH**: The measure should NOT include `target` in the count. Use ONLY the dom_N elements STRICTLY between `a` and `b` (the ORIGINAL `b`, not the recursive target). Here is the corrected strategy:

### 2.6 Corrected proof (final version)

**Statement**: For `a <= b` with `a, b in dom_N`, `exists k, succ^[k](a) = b`.

**Proof by strong induction on `m = |dom_N ∩ {x | a.val < x ∧ x <= b.val}|`**:

- `m = 0`: Then `a.val >= b.val`. Combined with `a <= b`, we get `a = b`. Use `k = 0`.
  (Justification: `m = 0` means no dom_N elements in `(a.val, b.val]`. Since `b.val in dom_N`, `b.val not in (a.val, b.val]` iff `a.val >= b.val`. But `a <= b` means `a.val <= b.val`. So `a.val = b.val`, hence `a = b`.)

- `m >= 1`: Then `a < b`. Let `b' = pred(b)`. We have `a <= b' < b` and `succ(b') = b`.
  
  Define `m' = |dom_N ∩ {x | a.val < x ∧ x <= b'.val}|`.
  
  **Show `m' < m`**: 
  - `dom_N ∩ (a.val, b'.val] ⊆ dom_N ∩ (a.val, b.val) ⊆ dom_N ∩ (a.val, b.val] \ {b.val}`
    (The first inclusion: `x <= b'.val < b.val` gives `x < b.val`, so `x in (a.val, b.val)`.
     The second: `(a.val, b.val) = (a.val, b.val] \ {b.val}` for `a < b`.)
  - `b.val in dom_N ∩ (a.val, b.val]` since `a < b` and `hb_N`.
  - So `|dom_N ∩ (a.val, b'.val]| <= |dom_N ∩ (a.val, b.val]| - 1 = m - 1 < m`.
  
  **But `b' = pred(b)` might not be in `dom_N`!** We need to apply the IH to `(a, b')`. The IH requires `a, b' in dom_N`... which might fail.

  **The fix**: Strengthen the induction hypothesis to: for ALL `target` with `a <= target <= b` and `|dom_N ∩ (a.val, target.val]| < m`, `exists k, succ^[k](a) = target`.
  
  This works because:
  - `pred(b) < b` and `a <= pred(b)`, so `a <= pred(b) <= b` (the inequality `pred(b) <= b` is trivial).
  - The measure for `pred(b)` is `|dom_N ∩ (a.val, pred(b).val]| < m`.
  - The IH gives `exists j, succ^[j](a) = pred(b)`.
  - Then `succ^[j+1](a) = b`.

  At the base `m = 0`, we need `a = target`, not `a = b`. And indeed: `|dom_N ∩ (a.val, target.val]| = 0` with `a <= target <= b`. If `a < target`, then since `target.val <= b.val` and `target in limit_dom`, we need to show target is NOT in `dom_N ∩ (a.val, b.val]`. But `target` might not be in `dom_N`. If `target not in dom_N`, then `m = 0` is consistent with `a < target`, and we'd need to continue recursing... but the Nat induction at `m = 0` doesn't allow further recursion.

  **This is the same issue as before.** The measure `|dom_N ∩ (a.val, target.val]|` can be 0 while `a < target` if `target not in dom_N`.

---

## 4. Final Corrected Proof Strategy

After extensive analysis, the correct approach uses `WellFounded.fix` with the relation `<` on the subtype `{x : LimitDomSubtype | a <= x /\ x <= b}`, which IS well-founded because the interval `[a, b]` in `LimitDomSubtype` is finite. We prove finiteness first, then derive IsSuccArchimedean.

### 4.1 Alternative: Induction on Nat with the measure `|dom_N ∩ [a, b]|`

Use strong induction on `m = |dom_N ∩ {x | a.val <= x /\ x <= b.val}|` (note: `<=` on both sides).

- `m = 0`: impossible since `a in dom_N` and `a.val <= a.val <= b.val`.
- `m = 1`: `dom_N ∩ [a, b] = {a}` (since `a in dom_N`). If `a < b`, then `b in dom_N ∩ [a, b]`, giving `m >= 2`. Contradiction. So `a = b`, use `k = 0`.
  Wait, `b in dom_N` is given (`hb_N`). And `a <= b` and `a.val <= b.val <= b.val`, so `b.val in dom_N ∩ [a,b]`. If `a = b`, `m = 1`. If `a < b`, `m >= 2` (both `a` and `b` counted). So `m = 1` iff `a = b`. Good.
- `m >= 2`: `a < b`. Let `b' = pred(b)`. Then `a <= b' < b`.
  
  Define `m' = |dom_N ∩ {x | a.val <= x /\ x <= b'.val}|`.
  
  `m' < m` because:
  - `dom_N ∩ [a, b'] ⊆ dom_N ∩ [a, b] \ {b}` (since `b' < b` implies `x <= b' < b` for elements in `[a, b']`; and no dom_N elements in `(b', b)` since `dom_N ⊆ limit_dom` and no limit_dom elements between `pred(b)` and `b`; so `b not in [a, b']`).
  - `b in dom_N ∩ [a, b]` (from `hb_N` and `a <= b`).
  - So `m' <= m - 1 < m`.
  
  **BUT**: We need to apply the IH to `(a, b')`. The IH is parameterized by `m'`. But the IH statement is about `exists k, succ^[k](a) = b'`, not about `b'` being in `dom_N`.

  **The correct general statement**: Prove by Nat strong induction on `m`:
  
  ```
  forall target : LimitDomSubtype,
    a <= target ->
    (dom_N.filter (fun x => a.val <= x /\ x <= target.val)).card = m ->
    exists k, succ^[k](a) = target
  ```
  
  - `m = 0`: impossible since `a in dom_N ∩ [a, target]`.
  
  Wait, IS `a in dom_N ∩ [a, target]`? We need `a.val in dom_N` (yes, from `ha_N`) and `a.val <= a.val <= target.val` (yes, from `a <= target`). So the filter always contains at least `a.val`, giving `m >= 1`.
  
  - `m = 1`: Only `a.val` in the filter. If `target = a`, use `k = 0`. If `target > a`, then `target.val > a.val`, and we need no dom_N elements in `(a.val, target.val]`. Then `pred(target) < target` and `a <= pred(target)`. The new measure `m'' = |dom_N ∩ [a, pred(target)]|`. Since `pred(target) < target` and no dom_N elements in `(pred(target), target)`, we have `dom_N ∩ [a, pred(target)] ⊆ dom_N ∩ [a, target)`. If `target not in dom_N`, then `dom_N ∩ [a, target) = dom_N ∩ [a, target]` and `m'' = m = 1`. No decrease!
  
  **PROBLEM AGAIN.** The measure `|dom_N ∩ [a, target]|` stays at 1 when `target` is not in `dom_N` and keeps getting replaced by `pred(target)`.

### 4.2 The resolution: use `b` as the fixed upper bound

The induction should be on `|dom_N ∩ (a.val, b.val]|` where `b` is the ORIGINAL target (fixed throughout), not the recursive target. Replace `b` with `pred(b)`, `pred(pred(b))`, etc.

```
forall b : LimitDomSubtype,
  a <= b ->
  a.val in dom_N ->
  b.val in dom_N ->
  exists k, succ^[k](a) = b
```

Induction on `m = |dom_N.filter(fun x => a.val < x /\ x <= b.val)|`:

- `m = 0`: Since `b.val in dom_N`, if `a < b` then `b.val in (a.val, b.val] ∩ dom_N` giving `m >= 1`. So `a = b`, `k = 0`.
  
- `m >= 1`: `a < b`. Let `b' = pred(b)`. Then `a <= b' < b`, `succ(b') = b`.
  
  `m' = |dom_N.filter(fun x => a.val < x /\ x <= b'.val)|`. As shown, `m' < m`.
  
  **We want `exists j, succ^[j](a) = b'`, then `succ^[j+1](a) = b`.**
  
  But the IH requires `b'.val in dom_N`. If `b' not in dom_N`, the IH doesn't apply!
  
  **FIX**: Change the IH to not require `b.val in dom_N`. But then the base case `m = 0` doesn't give `a = b`.

### 4.3 The ACTUAL correct proof

After all this analysis, the cleanest approach is:

**Prove `IsSuccArchimedean` by well-founded induction on `(b - a)` using a SUBSET of `dom_N` as the termination witness.**

Actually, here is the simplest correct formulation:

**Prove by `Nat.strongRecOn` on `m = |dom_N.filter(fun x => a.val < x /\ x <= b.val)|` where both `a, b in dom_N`**:

For `a <= b` with BOTH in `dom_N`:
- Base `m = 0`: `a = b`, done.
- Step `m >= 1`: Let `b' = pred(b)`. Then `a <= b' < b` and `succ(b') = b`.
  
  NOW: `b'` might not be in `dom_N`. We don't recurse on `(a, b')` directly using the SAME induction. Instead, we use a NESTED argument:
  
  Find `N' >= N` such that `b'.val in dom_{N'}`. Define `m'' = |dom_{N'}.filter(fun x => a.val < x /\ x <= b'.val)|`. Use the IH for `(a, b')` with stage `N'`.
  
  But `m''` could be LARGER than `m` (since `dom_{N'}` has more elements). So the measure doesn't decrease across the stage change.

  This doesn't work either.

### 4.4 The TRULY correct approach: Nat.rec on `m` with a DIFFERENT formulation

The statement to prove by `Nat.rec` on `m`:

```
forall m : Nat,
  forall b : LimitDomSubtype,
  a <= b ->
  |dom_N ∩ (a.val, b.val]| <= m ->
  exists k, succ^[k](a) = b
```

where `N` is fixed (from the original `a, b`).

- `m = 0`: `|dom_N ∩ (a.val, b.val]| = 0`. Since `a <= b`, either `a = b` (done) or `a < b`. If `a < b` and `b.val in dom_N`, then `b.val in dom_N ∩ (a.val, b.val]`, giving count >= 1, contradiction. If `a < b` and `b.val not in dom_N`... this is the problem case.

  But at the INITIAL call, `b.val in dom_N` (from `hb_N`). So `m >= 1` initially. The recursive calls pass `pred(b)` which might not be in `dom_N`.

  **Resolution**: At `m = 0` and `a < b` and `b not in dom_N`: `pred(b)` exists with `pred(b) < b`. Since no dom_N points in `(a.val, b.val]` and also no dom_N points in `(pred(b).val, b.val)` (no limit_dom points there), we have no dom_N points in `(a.val, pred(b).val]` either (subset of `(a.val, b.val)`). So the measure for `pred(b)` is also 0. The Nat.rec base case gives `m = 0` for `pred(b)` too, and we recurse... but this is infinite recursion!

  The issue: the `<=` formulation means the base case `m = 0` is reached for ALL recursive targets, and we can't make progress.

### 4.5 THE WORKING APPROACH (for real this time)

After all the analysis, the proof that actually works uses a DIFFERENT induction entirely.

**Approach**: Prove that `[a, b] ∩ limit_dom` is finite, then use `WellFoundedLT` on the finite interval to get `IsPredArchimedean`, which gives `IsSuccArchimedean`.

OR, even simpler:

**Approach**: Use `Nat.strongRecOn` on `m = |dom_N ∩ [a.val, b.val]|` (closed interval, including BOTH endpoints):

For `a <= b` with both in `dom_N`:
- `m = 1`: Since both `a, b in dom_N ∩ [a, b]`, `m >= 2` unless `a = b`. So `a = b`, `k = 0`.
- `m = 2`: `dom_N ∩ [a, b] = {a, b}`, so `a` and `b` are adjacent in `dom_N`. Claim: `succ(a) = b`.
  
  Proof of claim: `succ(a)` is the least limit_dom element > `a`. Since `b > a` and `b in limit_dom`, `succ(a) <= b`. If `succ(a) < b`, then `succ(a) in limit_dom ∩ (a, b)`. Since `a, b` are adjacent in `dom_N`, `succ(a) not in dom_N`. But `succ(a) in limit_dom`. Now `pred(b) < b` with no limit_dom points in `(pred(b), b)`. And `succ(a) > a` with no limit_dom points in `(a, succ(a))`. Since `succ(a) < b` and `succ(a) in limit_dom ∩ (a, b)`, we can recurse... but we're going in circles.
  
  Actually, for `m = 2` we DON'T know `succ(a) = b`. The limit domain can have many points between `a` and `b` that are not in `dom_N`.

**THE FUNDAMENTAL ISSUE**: A fixed `dom_N` doesn't capture enough information about the limit domain structure. The measure based on `dom_N` only sees the finite-stage structure, not the full limit.

---

## 5. THE DEFINITIVE PROOF (LocallyFiniteOrder approach)

After extensive analysis, the correct proof strategy is:

### 5.1 Prove `[a, b] ∩ limit_dom` is finite

**Lemma** (key): Under the discrete hypothesis, for any `a, b in limit_dom` with `a <= b`, the set `{x in limit_dom | a <= x /\ x <= b}` is finite.

**Proof by contradiction**: Suppose `S = {x in limit_dom | a <= x /\ x <= b}` is infinite.

Since every element of `S` has a predecessor (by discrete hypothesis), define `f : S -> S` by `f(x) = pred(x)` when `x > a`, and `f(a) = a`. This is well-defined since `a <= pred(x) < x <= b` when `a < x`, so `pred(x) in S`.

`f` is injective on `S \ {a}`: if `pred(x) = pred(y)`, then `succ(pred(x)) = succ(pred(y))`, i.e., `x = y` (by `succ_pred`).

If `S` is infinite, `f` maps `S \ {a}` (also infinite) injectively into `S`. Moreover, `f(x) < x` for `x > a`. So `f` has no fixed points on `S \ {a}`.

Consider the orbit of `b` under `f`: `b, pred(b), pred^2(b), ...`. This is a strictly decreasing sequence in `S`. If this sequence is finite (reaches `a` at some step), then `succ^[k](a) = b` and we're done. If it's infinite, we have an infinite strictly decreasing sequence in `S ⊆ Q`, bounded below by `a.val`. This means `{pred^n(b) | n >= 0}` is infinite, strictly decreasing, bounded below.

In Q, an infinite strictly decreasing bounded-below sequence exists (e.g., `1/n`), so no direct contradiction. But each `pred^n(b)` is in `limit_dom`, and has a predecessor `pred^{n+1}(b)` with no limit_dom points between them. The intervals `(pred^{n+1}(b), pred^n(b))` are pairwise disjoint and all empty of limit_dom points. The total "space" consumed by all these intervals is `b - limit(pred^n(b))`, which is positive (if the sequence converges to some limit `L >= a`).

But this doesn't directly give a contradiction in Q.

**Better approach**: Use the omega chain directly.

Each `pred^n(b)` is in `limit_dom`, so `pred^n(b) in dom_{k_n}` for some `k_n`. The sequence `k_0, k_1, k_2, ...` is a sequence of natural numbers. By the pigeonhole principle, there exist `i < j` with `k_i = k_j = K`. Then both `pred^i(b)` and `pred^j(b)` are in `dom_K`. And `pred^j(b) < pred^{j-1}(b) < ... < pred^i(b)`. The elements `pred^j(b), ..., pred^i(b)` are all in `limit_dom ∩ (pred^j(b), pred^i(b))`, and they are pairwise separated (no limit_dom points between consecutive ones).

But wait, they AREN'T all necessarily in `dom_K`. Only `pred^i(b)` and `pred^j(b)` are guaranteed to be in `dom_K`.

Hmm, pigeonhole doesn't quite work because we need more structure.

### 5.2 The SIMPLEST correct proof

**After all this analysis, I believe the simplest correct proof is a direct well-founded recursion that carefully manages the measure.**

**Key insight I missed**: We can reformulate the induction to avoid the stage-membership issue entirely. The proof uses strong induction on `m = |dom_N ∩ (a.val, b.val]|` where BOTH `a` and `b` are in `dom_N`, and the recursion replaces `b` with `pred(b)` BUT ALSO replaces `N` with `max(N, first_stage(pred(b)))`.

The measure is NOT just the cardinality -- it's the PAIR `(m, 0)` where `m = |dom_N ∩ (a.val, b.val]|`. Wait, this brings back the problem that increasing N increases the count.

OK, let me try a COMPLETELY DIFFERENT approach.

**THE SHORTEST PATH**: Prove `IsSuccArchimedean` directly using transfinite/structural properties of the limit domain.

Define the set `R(a) = {x in limit_dom | exists k, succ^[k](a) = x}` (succ-reachable from `a`).

Prove `R(a) = {x in limit_dom | a <= x}` by showing `R(a)` is an initial segment closed under succ:
- `a in R(a)` (by `k = 0`)
- If `x in R(a)`, then `succ(x) in R(a)` (by `k + 1`)
- Need: `R(a)` contains all elements `>= a`. Equivalently: if `x >= a` and `x not in R(a)`, derive contradiction.

Suppose `x >= a` and `x not in R(a)`. Since `x in limit_dom`, `pred(x)` exists with `pred(x) < x` and `succ(pred(x)) = x`. If `pred(x) in R(a)`, then `x = succ(pred(x)) in R(a)`, contradiction. So `pred(x) not in R(a)`.

By the same argument, `pred^n(x) not in R(a)` for all `n`. This gives an infinite strictly decreasing sequence `x, pred(x), pred^2(x), ...` all in `limit_dom \ R(a)`, all `>= a` (since `a in R(a)` and they're not in `R(a)`, but they're `>= a` because... hmm, `pred(x) >= a` needs justification).

Actually `pred(x) >= a` iff `x > a` (from `le_pred_iff`). And `x >= a` with `x not in R(a)` implies `x > a` (since `a in R(a)`). So `pred(x) >= a`.

So `pred^n(x) >= a` and `pred^n(x) not in R(a)` for all `n`.

Now, `pred^n(x)` is a strictly decreasing sequence in `limit_dom`, bounded below by `a.val`. Define `S_n = pred^n(x)`. Each `S_n in dom_{k_n}` for some `k_n`.

Let `N = max(first_stage(a), first_stage(x))`. Both `a, x in dom_N`. Consider `dom_N ∩ [a.val, x.val]`. This is a FINITE set. Each `S_n` satisfies `a.val <= S_n.val < S_{n-1}.val <= x.val`.

Since `S_n` is strictly decreasing with `S_n.val >= a.val`, and `S_n$ are distinct elements of Q, the set `{S_0, S_1, S_2, ...}` is an infinite subset of the interval `[a.val, x.val] ∩ Q`. These are all in `limit_dom`.

**KEY**: Each `S_n` first appears at some stage `k_n`. The sequence `k_n$ might be non-monotone. But consider:

`S_0 = x in dom_N` (stage N). `S_1 = pred(x) in dom_{k_1}`. `S_1.val < x.val` and `S_1.val >= a.val`.

If `S_1 in dom_N`: then `S_1 in dom_N ∩ [a.val, x.val]`. Since this set is finite and each `S_n$ is distinct and in this interval (if `S_n in dom_N`), only finitely many `S_n$ can be in `dom_N`.

So there exists `n_0` such that `S_{n_0} not in dom_N`. Then `S_{n_0}$ was added at stage `k_{n_0} > N`. By `dom_new_unique`, `S_{n_0}$ is the unique new point at stage `k_{n_0}`.

At stage `k_{n_0}`, `S_{n_0}$ is placed between two adjacent elements of `dom_{k_{n_0} - 1}$. The adjacent elements are `p, q in dom_{k_{n_0} - 1}$ with `p < S_{n_0} < q`. Since `dom_N ⊆ dom_{k_{n_0} - 1}$, `p$ and `q$ separate `S_{n_0}$ from the rest of `dom_N$.

Now, `S_{n_0 + 1} = pred(S_{n_0})$ satisfies `S_{n_0 + 1} < S_{n_0}$ with no limit_dom points between them. So `S_{n_0 + 1} < S_{n_0} < q$. And `p <= S_{n_0 + 1}$ (since `S_{n_0 + 1} in limit_dom ∩ [a, S_{n_0}]$, and `p < S_{n_0}$, but `S_{n_0 + 1}$ could be anywhere in `[a, S_{n_0})$).

But `S_{n_0 + 1}, S_{n_0 + 2}, ...` are all in `[a.val, S_{n_0}.val) ⊆ [a.val, q)`. And they're all distinct. If they're in `dom_N$, the set `dom_N ∩ [a, S_{n_0}]$ is finite, so only finitely many can be in `dom_N$.

So the infinite sequence `S_n$ for `n >= n_0$ eventually escapes `dom_N$ again. And again. And again. But there are infinitely many `S_n$, each in `[a.val, x.val]$, and only finitely many in `dom_N$. So infinitely many are NOT in `dom_N$, each appearing at a different stage `> N$.

Each such `S_n$ that's not in `dom_N$ is added between two adjacent elements of some `dom_{k_n - 1}$. The domain grows at each such stage. But the key constraint: the domains are nested (`dom_m ⊆ dom_{m+1}$), so each `S_n$ that enters at stage `k_n$ remains in all later stages.

The infinite set `{S_n}$ is a subset of `limit_dom ∩ [a.val, x.val]$. Each `S_n$ appears at some finite stage. The stages `k_n$ are distinct natural numbers (since each `S_n$ is unique to the stage where it first appears). So there are infinitely many stages that add points to `[a.val, x.val]$.

Each such stage adds exactly one point. After $K$ such stages, `dom_K ∩ [a.val, x.val]$ has at least `|dom_N ∩ [a.val, x.val]| + K$ elements. This number grows without bound.

But each finite stage `dom_k$ is a Finset, so `dom_k ∩ [a.val, x.val]$ is always finite. The LIMIT (union over all stages) is `limit_dom ∩ [a.val, x.val]$, which IS the infinite set `{S_n}$ union the finitely many `dom_N$ points. So the limit domain interval IS infinite.

AND `pred(b)$ exists for every `b$ in this interval (by discrete hypothesis).

So... is this actually consistent? Can we have an infinite discrete countable linear order embedded in `[a, b] ∩ Q$?

YES! Consider `{a + (b-a)/2^n | n >= 0} ∪ {b}$ with the order from Q. This is infinite, bounded, and each element (except `b$) has an immediate successor: `succ(a + (b-a)/2^n) = a + (b-a)/2^{n-1}$ for `n >= 1`, and `succ(a) = a + (b-a)/2$.

Wait, does each element have an immediate predecessor? `pred(a + (b-a)/2^n) = a + (b-a)/2^{n+1}$ for `n >= 0$. And `pred(b) = a + (b-a)/2^0 = a + (b-a) = b$... no, that's just `b$ itself. Let me reconsider.

Let `S = {a + (b-a)(1 - 1/2^n) | n >= 0} ∪ {b}$. So `S = {a, a+(b-a)/2, a+3(b-a)/4, a+7(b-a)/8, ..., b}$.

- `succ(a + (b-a)(1 - 1/2^n)) = a + (b-a)(1 - 1/2^{n+1})$ (the next element in the sequence).
- `pred(a + (b-a)(1 - 1/2^{n+1})) = a + (b-a)(1 - 1/2^n)$ (the previous element).
- But `pred(b)$: the largest element less than `b$ in `S$ is `lim_{n->inf} a + (b-a)(1 - 1/2^n) = b$. There IS no largest element less than `b$ in `S \ {b}$! So `b$ has NO immediate predecessor in `S$.

**This contradicts the discrete hypothesis!** In our setting, every element (including `b$) has an immediate predecessor. So this particular `S$ CANNOT be the limit domain structure.

**Therefore**: The infinite set scenario is IMPOSSIBLE because it would create an element without an immediate predecessor, contradicting `limit_dom_has_pred$.

**And THIS is the proof of finiteness of `[a, b] ∩ limit_dom$!**

### 5.3 Formal proof of finiteness (cleaned up)

**Theorem**: Under the discrete hypothesis, for `a, b in limit_dom$ with `a <= b`, `limit_dom ∩ [a.val, b.val]` is finite.

**Proof by contradiction**: Suppose `S = limit_dom ∩ [a.val, b.val]` is infinite. 

`S` is bounded above by `b.val$. Consider the subset `S' = S \ {b.val}$. If `S'$ is finite, then `S = S' ∪ {b.val}$ is finite, contradiction. So `S'$ is infinite.

`S'$ is a countably infinite subset of `Q ∩ (-inf, b.val)$. Define the sequence: let `c_0 = b.val$. For `n >= 0`, `c_{n+1} = pred(c_n).val$ if `c_n > a.val` (which is guaranteed since `a <= pred(c_n) < c_n$). This gives a strictly decreasing sequence `b.val = c_0 > c_1 > c_2 > ...$ with each `c_n in limit_dom$.

Each `c_n in limit_dom$, so `c_n in dom_{k_n}$ for some `k_n$. But `c_n in S ⊆ [a.val, b.val]$, and the sequence is strictly decreasing. In particular, the `c_n$ are distinct.

**Claim**: `c_n >= a.val$ for all `n$.

Proof: `c_0 = b.val >= a.val$. If `c_n >= a.val$ and `c_n > a.val$, then `c_{n+1} = pred(c_n).val$ and `a <= pred(c_n)$ (from `limitDomSubtype_le_pred_of_lt` applied to `a.val < c_n$). So `c_{n+1} >= a.val$.

If `c_n = a.val$, the sequence stops (we've reached `a$) and `exists k, succ^[k](a) = b$ with `k = n$.

**But we assumed `S$ is infinite**, meaning the sequence `c_n$ never reaches `a$. So `c_n > a.val$ for all `n$, and the sequence is infinite and strictly decreasing in `Q$, bounded below by `a.val$.

Now, each `c_n in limit_dom$ and the intervals `(c_{n+1}, c_n)$ contain no limit_dom points (by `limit_dom_has_pred$). So limit_dom ∩ `(a.val, b.val) = limit_dom ∩ (∪_n [c_{n+1}, c_n)) = {c_1, c_2, c_3, ...}$.

But also `S' = limit_dom ∩ [a.val, b.val)$ was assumed infinite. And `S' = {a.val} ∪ {c_1, c_2, c_3, ...} ∪ (limit_dom ∩ (a.val, c_n) for all n)$.

Wait, the `c_n$ are DECREASING and all > `a.val$. So the `c_n$ accumulate towards `a.val$ (or some limit > `a.val$). But `a$ has an immediate SUCCESSOR `succ(a)$ with no limit_dom points in `(a.val, succ(a).val)$. So `c_n >= succ(a).val$ for all `n$ such that `c_n > a.val$... actually no. The `c_n$ are between `a$ and `b$, and `succ(a) <= b$ (since `a < b$ and `b in limit_dom$). But `c_n$ could be less than `succ(a).val$ if `c_n < succ(a).val$.

`succ(a)$ is the least limit_dom element above `a$. Since `c_n in limit_dom$ and `c_n > a.val$, `c_n >= succ(a).val$. So ALL `c_n >= succ(a).val$. The infinite strictly decreasing sequence `c_n$ is bounded below by `succ(a).val$.

Similarly, `succ(a)$ has a successor `succ^2(a)$. All `c_n >= succ^2(a).val$ except possibly `c_k = succ(a).val$ for some `k$... but `c_n$ is STRICTLY decreasing, so at most one `c_n$ can equal `succ(a).val$.

Hmm, this argument is getting complicated. Let me try a cleaner version.

**Cleaner proof by contrapositive**: We prove `exists k, succ^[k](a) = b$ directly, using the fact that `pred^n(b) >= a$ for all `n$ (proved above) and `pred^n(b)$ is strictly decreasing. If for all `n$, `pred^n(b) > a$, then we have an infinite strictly decreasing sequence in `[a, b]$.

Now use `succ(a)$: `succ(a) <= b$ (since `a < b$). And `succ(a) <= pred^n(b)$ for all `n$ (since `pred^n(b) >= a$ and `pred^n(b) > a$ gives `pred^n(b) >= succ(a)$). Wait, that's because `succ(a)$ is the least element above `a$, and `pred^n(b) > a$ means `pred^n(b) >= succ(a)$.

But then `pred^n(b) >= succ(a) > a$ for all `n$. Consider `S_n = pred^n(b) - a.val$ (a strictly decreasing sequence in Q, bounded below by `succ(a).val - a.val > 0$). 

In Q, strictly decreasing sequences bounded below CAN be infinite. So we can't derive a contradiction purely from the order structure.

**THE OMEGA CHAIN GIVES THE CONTRADICTION**: Each `pred^n(b) in dom_{k_n}$ for some `k_n$. The set `dom_N ∩ [a.val, b.val]$ is a FINITE set (since `dom_N$ is a Finset). Only finitely many `pred^n(b)$ can be in `dom_N$. Say `pred^{n_0}(b), ..., pred^{n_r}(b)$ are in `dom_N$ with `n_0 < n_1 < ... < n_r$. Then `pred^{n_r + 1}(b), pred^{n_r + 2}(b), ...$ are all NOT in `dom_N$.

For `n > n_r$: `pred^n(b) not in dom_N$ but `pred^n(b) in limit_dom$. `pred^n(b)$ appears at some stage `k_n > N$. At stage `k_n$, `pred^n(b)$ is inserted between two adjacent elements of `dom_{k_n - 1}$.

Now, between `pred^{n+1}(b)$ and `pred^n(b)$, there are no limit_dom points. So `dom_{k_n - 1}$ has no points in `(pred^{n+1}(b).val, pred^n(b).val)$. The adjacent pair containing `pred^n(b)$'s insertion position has its left endpoint `<= pred^{n+1}(b).val$ and right endpoint `>= pred^n(b).val$... wait, `pred^n(b)$ is the point being inserted, so it's between two adjacent elements `p < pred^n(b) < q$ of `dom_{k_n - 1}$.

Since `pred^{n+1}(b) < pred^n(b) < pred^{n-1}(b)$, and there are no limit_dom points between consecutive `pred$-iterates, the intervals `(pred^{n+1}(b), pred^n(b))$ are disjoint and empty of limit_dom points.

The points `p$ and `q$ that `pred^n(b)$ is inserted between satisfy `p < pred^n(b) < q$. Since no limit_dom points in `(pred^{n+1}(b), pred^n(b))$, we need `p <= pred^{n+1}(b)$. And `q >= pred^n(b)$... but `q > pred^n(b)$ since it's adjacent. Could `q$ be between `pred^n(b)$ and `pred^{n-1}(b)$? There are no limit_dom points in `(pred^n(b), pred^{n-1}(b))$ either (since `pred^{n-1}(b) = succ(pred^n(b))$). So `q >= pred^{n-1}(b)$.

This means `q >= pred^{n-1}(b)$ and `p <= pred^{n+1}(b)$. But `dom_{k_n - 1}$ might have points between `pred^{n+1}(b)$ and `p$, or between `q$ and `pred^{n-1}(b)$, as long as they're not in the empty intervals.

This is getting very detailed. Let me step back and think about the Lean implementation directly.

---

## 6. Recommended Implementation

### 6.1 Approach A: Direct WF recursion (recommended)

Use `WellFounded.fix` with the measure `|dom_N ∩ (a.val, b.val]|`, calling the function with `pred(b)` at each step. The key lemma needed:

```lean
lemma dom_N_filter_pred_lt (a b : LimitDomSubtype) (h_lt : a < b)
    (N : Nat) (ha_N : a.val in dom_N) (hb_N : b.val in dom_N) :
    (dom_N.filter (fun x => a.val < x /\ x <= (pred b).val)).card <
    (dom_N.filter (fun x => a.val < x /\ x <= b.val)).card
```

This lemma is provable using:
1. `pred(b).val < b.val` 
2. No limit_dom points in `(pred(b).val, b.val)`, hence no dom_N points
3. `b.val in dom_N ∩ (a.val, b.val]`
4. `Finset.card_lt_card` on the strict subset

For the recursion, the general statement proved is:

```lean
-- For fixed a, N, ha_N:
-- forall b, a <= b -> b.val in dom_N -> exists k, succ^[k] a = b

-- Using Nat.strongRecOn on |dom_N ∩ (a, b]|
```

The fact that `pred(b).val` might not be in `dom_N` is NOT a problem because we DON'T need `pred(b) in dom_N` for the general statement. We only need `b in dom_N` at the TOP LEVEL (for the initial call), and the measure ALWAYS decreases.

Wait -- but the recursion calls `succ^[k](a) = pred(b)` and then adds one more `succ` to get `b`. For the recursive call, the "new b" is `pred(b)`, and we need `pred(b).val in dom_N`... NO WE DON'T.

Let me re-examine. The recursion is:

```
prove(a, b, hab, hb_N) :=
  if a = b then k = 0
  else
    let b' = pred(b)
    let k' = prove(a, b', hab', ???)  -- what about hb'_N?
    k = k' + 1
```

The `prove` function needs `b.val in dom_N` to ensure the measure is > 0 when `a < b`. But for the recursive call with `b' = pred(b)`, we need `b'.val in dom_N` to ensure the measure is well-defined... actually, the measure `|dom_N ∩ (a.val, b'.val]|` is ALWAYS well-defined (it's just a Finset filter card). It just might be 0 when `b' not in dom_N`.

When `b' not in dom_N` and `a < b'`, the measure is 0 (no dom_N elements in `(a, b']`), but we still need to prove `exists k, succ^[k](a) = b'`. At this point, `b' = pred(b)` and we want to recurse to `pred(b')`, but the measure for `pred(b')` is also 0. No progress.

**THE ACTUAL FIX**: Change the statement being proved. Instead of proving `exists k, succ^[k](a) = b` for each `b` separately, prove:

```
forall b, a <= b ->
  |dom_N ∩ (a.val, b.val]| = 0 -> a = b
```

Then the main theorem follows: if `a < b` and `b in dom_N`, then `|dom_N ∩ (a, b]| >= 1`, and by recursion on this measure, `exists k, succ^[k](a) = b`.

But proving `|dom_N ∩ (a, b]| = 0 -> a = b` for arbitrary `b in limit_dom` requires showing that if `a < b`, there EXISTS a dom_N element in `(a, b]`. This is NOT true for `b not in dom_N`!

**CONCLUSION**: The pure `|dom_N ∩ (a, b]|` measure approach does NOT work because it can reach 0 prematurely.

### 6.2 Approach B: Two-phase proof (RECOMMENDED)

**Phase 1**: Prove `exists k, pred^[k](b) = a` when `a <= b` and both are in `dom_N`.

This uses `Nat.strongRecOn` on `|dom_N ∩ [a.val, b.val]|`:
- Base: `|dom_N ∩ [a.val, b.val]| <= 1`. Since both `a, b in dom_N ∩ [a, b]`, this means `a = b`. Use `k = 0`.
- Step: `|dom_N ∩ [a.val, b.val]| >= 2`. Then `a < b`.
  
  Find the LARGEST dom_N element strictly less than `b.val`, call it `p`. (This exists because `a in dom_N` and `a < b`.) Then `p in dom_N`, `a.val <= p < b.val`, and no dom_N elements in `(p, b.val)`.
  
  Claim: `pred(b).val <= p`.
  
  Proof: `pred(b)` is the limit_dom predecessor of `b`. If `pred(b).val > p`, then `pred(b) in limit_dom ∩ (p, b)`. But there are no dom_N elements in `(p, b)`. However, `pred(b)$ might be in `limit_dom$ but not in `dom_N`. That's fine. We just need `pred(b).val <= p` or we can continue.
  
  Actually, we DON'T need `pred(b).val <= p`. We just need: `|dom_N ∩ [a.val, pred(b).val]| < |dom_N ∩ [a.val, b.val]|`.
  
  Since `pred(b).val < b.val`:
  - `dom_N ∩ [a.val, pred(b).val] ⊆ dom_N ∩ [a.val, b.val)` (since `x <= pred(b).val < b.val`)
  - No dom_N elements in `(pred(b).val, b.val)` (since no limit_dom elements there).
  - So `dom_N ∩ [a.val, pred(b).val] = dom_N ∩ [a.val, b.val) \ (elements in (pred(b).val, b.val) ∩ dom_N)` = `dom_N ∩ [a.val, b.val) = dom_N ∩ [a.val, b.val] \ {b.val}`.
  - And `b.val in dom_N ∩ [a.val, b.val]` (from `hb_N` and `a <= b`).
  - So `|dom_N ∩ [a.val, pred(b).val]| = |dom_N ∩ [a.val, b.val]| - 1`.
  
  By IH: `exists j, pred^[j](pred(b)) = a`. Then `pred^[j+1](b) = a`.

**Phase 2**: Convert `pred^[k](b) = a` to `succ^[k](a) = b`.

This follows from `succ_pred` identity: `succ(pred(x)) = x`. By induction on `k`:
- `k = 0`: `a = b`, so `succ^[0](a) = a = b`.
- `k + 1`: `pred^[k+1](b) = a` means `pred^[k](pred(b)) = a`. By IH, `succ^[k](a) = pred(b)`. Then `succ^[k+1](a) = succ(pred(b)) = b`.

### 6.3 Implementation details for Approach B

**Phase 1 helper**: 
```lean
private theorem pred_iterate_eq 
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...)
    (a b : LimitDomSubtype A h_mcs) (hab : a ≤ b)
    (N : Nat) (ha_N : a.val ∈ (omega_chain_val A h_mcs N).dom)
    (hb_N : b.val ∈ (omega_chain_val A h_mcs N).dom) :
    ∃ k, (limitDomSubtype_pred A h_mcs h_discrete)^[k] b = a
```

Proof: `Nat.strongRecOn` on `|dom_N.filter(fun x => a.val ≤ x ∧ x ≤ b.val)|`.

**Phase 2 helper**:
```lean
private theorem succ_of_pred_iterate
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)  
    (h_discrete : ...)
    (a b : LimitDomSubtype A h_mcs) (k : Nat)
    (h : (limitDomSubtype_pred A h_mcs h_discrete)^[k] b = a) :
    (Order.succ)^[k] a = b
```

Proof: induction on `k`, using `succ_pred` at each step.

**Main theorem**: Combine Phase 1 and Phase 2.

### 6.4 Key Finset lemma needed

```lean
lemma dom_N_card_decrease
    (dom_N : Finset Rat) (a b pb : Rat)
    (ha : a ∈ dom_N) (hb : b ∈ dom_N)
    (hab : a < b) (hpb_lt : pb < b)
    (h_no_between : ∀ w, w ∈ dom_N → pb < w → w < b → False) :
    (dom_N.filter (fun x => decide (a ≤ x ∧ x ≤ pb) = true)).card <
    (dom_N.filter (fun x => decide (a ≤ x ∧ x ≤ b) = true)).card
```

The key step: show the first filter is a strict subset of the second, using:
1. `x ≤ pb < b` gives `x ≤ b` (subset direction)
2. `b ∈ dom_N ∩ [a, b]` but `b ∉ dom_N ∩ [a, pb]` (strictness)
3. No dom_N elements in `(pb, b)` means `dom_N ∩ [a, pb] = dom_N ∩ [a, b] \ {b}`

---

## 7. Summary of Findings

1. **IsSuccArchimedean IS provable** for `LimitDomSubtype` under the discrete hypothesis.

2. **The cascade concern is resolved**: Infinite accumulation of points between `a` and `b` would require an element without an immediate predecessor, contradicting `limit_dom_has_pred`.

3. **The proof uses two phases**:
   - Phase 1: Prove `pred^[k](b) = a` by strong induction on `|dom_N ∩ [a, b]|` (Finset cardinality).
   - Phase 2: Convert to `succ^[k](a) = b` using `succ_pred` identity.

4. **The critical lemma**: No limit_dom points between `pred(b)` and `b` implies no `dom_N` points there either (since `dom_N ⊆ limit_dom`). This ensures the Finset measure decreases by exactly 1 at each step.

5. **Estimated implementation**: 60-80 lines of Lean, structured as:
   - `pred_iterate_eq` (~30-40 lines): Well-founded recursion on Finset cardinality
   - `succ_of_pred_iterate` (~10 lines): Simple induction on `k`
   - `limitDomSubtype_isSuccArchimedean` (~10 lines): Combine the two

6. **All needed infrastructure exists**:
   - `limitDomSubtype_pred_lt`: `pred(b) < b`
   - `limitDomSubtype_succ_pred`: `succ(pred(b)) = b`
   - `limitDomSubtype_le_pred_of_lt`: `a < b → a ≤ pred(b)`
   - `limit_dom_has_pred`: no limit_dom points between `pred(b)` and `b`
   - `omega_chain_dom_mono_le`: `dom_N ⊆ limit_dom` (transitively)
   - `Finset.card_lt_card`: card decreases for strict subsets
