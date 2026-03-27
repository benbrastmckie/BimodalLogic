# Teammate B Findings: Theorem Statement Reformulation Analysis

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Focus**: Whether `neg_not_in_boundary_resolution_set` needs reformulation

---

## Key Findings

1. **`neg_not_in_boundary_resolution_set` has exactly ONE call site**, and at that call site the
   available hypotheses make the theorem statement with `F(chi) ∈ u` provably harder than necessary.

2. **The theorem is NOT provable as stated** (with `F(chi) ∈ u` as the sole non-MCS hypothesis),
   even WITH Fix A1 applied to the BRS definition. The gap is syntactic: `F(chi)` and
   `F(chi.neg.neg)` are different Lean terms, and `deferralClosure` does not contain
   `F(chi.neg.neg)` as a general consequence of `F(chi) ∈ u`.

3. **The call site provides MORE than `F(chi) ∈ u`**: It provides `chi.neg ∈ BRS` directly.
   This stronger hypothesis enables a much simpler proof.

4. **Option A (change hypothesis to `chi ∈ BRS`) does NOT directly match the call site**.
   At the call site, the available membership is `chi.neg ∈ BRS`, not `chi ∈ BRS`.
   However, this leads directly to `brs_mutual_exclusion(chi.neg)` which says `chi.neg.neg ∉ BRS`.
   The issue is we need `False`, not `chi.neg.neg ∉ BRS`.

5. **The correct reformulation is Option C**: The theorem should be ELIMINATED and the BRS case
   of `neg_not_in_constrained_successor_seed_restricted` should be handled INLINE using
   `brs_mutual_exclusion` plus MCS consistency. Specifically, at the call site:
   - `h_brs : chi.neg ∈ BRS` gives `F(chi.neg) ∈ u` (first component of BRS membership)
   - `h_F_in : F(chi) ∈ u` is the outer hypothesis
   - These together contradict MCS consistency, because `F(chi) = neg(G(neg chi))` is the
     negation of `G(neg chi)`, and having both `F(chi) ∈ u` and `F(chi.neg) ∈ u` means having
     both `neg(G(neg chi)) ∈ u` and `G(chi).neg.all_future.neg ∈ u`... wait, let me check this.
   - Actually: `F(chi.neg) = chi.neg.neg.all_future.neg` and `G(chi) = chi.all_future`.
     These are different formulas.

6. **Revised key finding**: The direct contradiction comes from `h_F_in` and the FIRST component
   of `h_brs`. From `chi.neg ∈ BRS`, we get `F(chi.neg) ∈ u`. But `F(chi.neg)` is defined as
   `(chi.neg).neg.all_future.neg = chi.neg.neg.neg.all_future.neg`. Meanwhile
   `F(chi) = chi.neg.all_future.neg`. These ARE semantically dual but syntactically different.
   However, there IS an existing proven lemma `neg_not_in_g_content_when_F_in` that uses
   `set_consistent_not_both` with the fact that `F(chi) = neg(all_future chi.neg)`. The same
   argument works here: `F(chi.neg) = neg(G(chi))` (since `F(chi.neg) = G(chi).neg`), and if
   `F(chi) ∈ u` implies `G(chi) ∉ u` (by MCS consistency), then `F(chi.neg) ∉ u`.

---

## Detailed Analysis

### Theorem as Currently Written (with sorry)

```lean
theorem neg_not_in_boundary_resolution_set (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_in : Formula.some_future chi ∈ u) :
    chi.neg ∉ boundary_resolution_set phi u
```

**Hypothesis**: `F(chi) ∈ u`
**Conclusion**: `chi.neg ∉ BRS`

**Why the current proof strategy fails**:
The attempted proof (documented in file comments at SuccChainFMCS.lean:1398-1409):
1. Suppose `chi.neg ∈ BRS`. By Fix A1, `F(chi.neg.neg) ∉ u`.
2. Need to show `F(chi) ∈ u → F(chi.neg.neg) ∈ u` via derivation `F(chi) → F(chi.neg.neg)`.
3. But `drm_closed_under_derivation` requires `F(chi.neg.neg) ∈ deferralClosure phi`.
4. `F(chi.neg.neg)` is only in `deferralClosure` if it is in `closureWithNeg`, which requires
   it to be a subformula or negation of a subformula of `phi`.
5. We can show `chi.neg ∈ subformulaClosure phi` (from `F(chi.neg) ∈ u ⊆ deferralClosure` via
   `some_future_in_deferralClosure_is_in_closureWithNeg` and
   `some_future_in_closureWithNeg_inner_in_subformulaClosure`).
6. We can then show `chi.neg.neg ∈ closureWithNeg phi` (by `neg_mem_closureWithNeg`).
7. But we need `F(chi.neg.neg) ∈ closureWithNeg`, which requires `F(chi.neg.neg)` itself to
   be a subformula of `phi` (or its negation). There is no path from `chi.neg.neg ∈ closureWithNeg`
   to `F(chi.neg.neg) ∈ closureWithNeg`.

**Conclusion**: The sorry cannot be eliminated along this proof path.

### The Single Call Site

The theorem is called at exactly one location:

```
SuccChainFMCS.lean:1456:
  · exact neg_not_in_boundary_resolution_set phi u chi h_mcs h_F_in h_brs
```

This is inside `neg_not_in_constrained_successor_seed_restricted`, in the BRS case of the case
split. At this point the proof state has:

```
phi : Formula
u : Set Formula
chi : Formula
h_mcs : DeferralRestrictedMCS phi u
h_F_in : Formula.some_future chi ∈ u
h_brs : chi.neg ∈ boundary_resolution_set phi u
⊢ False
```

### What the Call Site Actually Has

From `h_brs : chi.neg ∈ BRS`, using `mem_boundary_resolution_set_iff`:
```
F(chi.neg) ∈ u  ∧  FF(chi.neg) ∉ deferralClosure  ∧  F(chi.neg.neg) ∉ u
```
where the third component is Fix A1's mutual exclusion condition on `chi.neg`.

From `h_F_in`: `F(chi) ∈ u`.

**The direct contradiction path**:

Key algebraic fact: `Formula.some_future chi = (Formula.all_future chi.neg).neg` (by rfl, as
seen in `neg_not_in_g_content_when_F_in` at line 1318):
```lean
have h_F_chi_eq : Formula.some_future chi = (Formula.all_future chi.neg).neg := rfl
```

Similarly: `Formula.some_future chi.neg = (Formula.all_future chi.neg.neg).neg`... but this
involves `all_future chi.neg.neg`, not `all_future chi`.

Wait — let me re-examine. `F(chi) = chi.neg.all_future.neg`. And `G(chi.neg) = chi.neg.all_future`.
So `F(chi) = G(chi.neg).neg`. This means `F(chi) ∈ u` is the same as having the NEGATION of
`G(chi.neg)` in `u`.

Now `F(chi.neg) = chi.neg.neg.all_future.neg`. And `G(chi) = chi.all_future`. So
`F(chi.neg) = G(chi.neg.neg).neg`... this is NOT `G(chi).neg`.

Actually: `F(chi.neg) = (chi.neg).neg.all_future.neg = chi.neg.neg.all_future.neg`.
And `G(chi) = chi.all_future`.

These are NOT the same formula. `chi.neg.neg` is `(chi.imp bot).imp bot`, NOT `chi`.

### Is the Current Theorem Statement True?

This is the crucial mathematical question.

**Claim**: With Fix A1, `F(chi) ∈ u` does imply `chi.neg ∉ BRS`.

**Mathematical argument**:
- `chi.neg ∈ BRS` requires `F(chi.neg) ∈ u` (first BRS condition).
- `F(chi.neg) = G(chi.neg.neg).neg` (by definition).
- `F(chi) = G(chi.neg).neg` (by definition).
- So we'd have both `G(chi.neg).neg ∈ u` and `G(chi.neg.neg).neg ∈ u`.
- By MCS consistency of `u`, this means `G(chi.neg) ∉ u` and `G(chi.neg.neg) ∉ u`.
- Does this give a contradiction? Not directly.

**Alternative mathematical argument using the proof system**:
- `F(chi) ∈ u` and `F(chi.neg) ∈ u` does NOT yield a contradiction in temporal logic.
- Example: At time t, "it will rain at some future time" (F(chi)) and "it will NOT rain at some
  future time" (F(chi.neg)) can BOTH be true simultaneously — just at different future times.
- Therefore the claim `F(chi) ∈ u → chi.neg ∉ BRS` is mathematically FALSE in general.

**Counterexample sketch**:
Let `chi` be a propositional atom p. Let `u` be an MCS containing both `F(p)` and `F(¬p)`.
Such an MCS exists (in the canonical model, it corresponds to a world where both p holds
eventually and ¬p holds eventually). With Fix A1, `chi.neg = ¬p` is NOT in BRS because
`F(chi.neg.neg) = F(¬¬p)` would need to not be in u, but it might be. However, for
`chi.neg ∈ BRS`, we need `F(chi.neg) = F(¬p) ∈ u` (satisfied!) and `FF(¬p) ∉ deferralClosure`
(possible at depth boundary) and `F(¬p.neg) = F(p) ∉ u` (CONTRADICTED by `h_F_in`!).

This is the key: Fix A1's third condition for `chi.neg ∈ BRS` is `F((chi.neg).neg) ∉ u`,
i.e., `F(chi.neg.neg) ∉ u`. And `F(chi) ∈ u` means... wait.

`F(chi)` and `F(chi.neg.neg)` are SYNTACTICALLY DIFFERENT because `chi ≠ chi.neg.neg` in Lean's
definitional equality (since `chi.neg.neg = (chi.imp bot).imp bot`, not `chi`).

So the third component of BRS membership for `chi.neg` gives `F(chi.neg.neg) ∉ u`, which is
a DIFFERENT formula from `F(chi)`. No immediate contradiction.

**But the mathematical CLAIM is still true**: The theorem is mathematically correct
because the system has double negation elimination. If the proof system is classical
(which TM bimodal logic is, having the DNE axiom), then `F(chi)` and `F(chi.neg.neg)` are
provably equivalent in the system. However, the DRM membership only reflects what is SYNTACTICALLY
in `u`, not what is derivable at a meta level. The `drm_closed_under_derivation` lemma bridges
this, but requires the conclusion formula to be in `deferralClosure`.

**Final verdict on mathematical correctness**: The theorem IS true (mathematically), but the
Lean proof requires establishing that `F(chi) ∈ u` implies `F(chi.neg.neg) ∈ u` via
`drm_closed_under_derivation`, which requires `F(chi.neg.neg) ∈ deferralClosure`. This is the
documented gap.

---

## Proposed Reformulations

### Option A: Change Hypothesis to `chi ∈ BRS`

**Proposed signature**:
```lean
lemma neg_not_in_boundary_resolution_set (phi : Formula) (u : Set Formula)
    (chi : Formula)
    (h_chi_in_brs : chi ∈ boundary_resolution_set phi u) :
    chi.neg ∉ boundary_resolution_set phi u
```

**Status**: This is exactly `brs_mutual_exclusion` (already proven at line 1378).

**Feasibility**: The theorem itself is trivial. BUT the call site cannot use it directly,
because at line 1456, we have `chi.neg ∈ BRS`, not `chi ∈ BRS`.

**Call site adaptation needed**: The call site would need to obtain `chi ∈ BRS` from
`h_F_in : F(chi) ∈ u`. But as argued above, `F(chi) ∈ u` alone does NOT imply `chi ∈ BRS`
(BRS also requires `FF(chi) ∉ deferralClosure`). So Option A doesn't resolve the call site.

### Option B: Add Additional Hypothesis `FF(chi) ∉ deferralClosure`

**Proposed signature**:
```lean
theorem neg_not_in_boundary_resolution_set (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_in : Formula.some_future chi ∈ u)
    (h_FF_not_dc : Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)) :
    chi.neg ∉ boundary_resolution_set phi u
```

**Proof strategy**: With `h_F_in`, `h_FF_not_dc`, and the condition `F(chi.neg) ∉ u` (from Fix A1,
which says `chi ∈ BRS` implies `F(chi.neg) ∉ u`, and we have `chi ∈ BRS` from the three conditions),
we use `brs_mutual_exclusion` directly.

**Status**: Partially feasible. Adding `h_FF_not_dc` lets us derive `chi ∈ BRS` (since
`F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure` are two of three BRS conditions). But we still need
the third condition `F(chi.neg) ∉ u` to establish `chi ∈ BRS`.

This is circular: to show `chi ∈ BRS` we need `F(chi.neg) ∉ u`, but that's what we're trying
to derive from `chi.neg ∉ BRS`.

**Not recommended** as stated.

### Option C: Eliminate the Theorem and Handle Inline (RECOMMENDED)

The correct approach is to rewrite `neg_not_in_constrained_successor_seed_restricted` to handle
the BRS case directly, without routing through `neg_not_in_boundary_resolution_set`.

At the call site, we have both `h_F_in` and `h_brs : chi.neg ∈ BRS`. From `h_brs`, the
Fix A1 mutual exclusion gives us `F(chi.neg.neg) ∉ u`. But we need to link this to `h_F_in`.

**The clean path**: The Fix A1 condition on `chi.neg ∈ BRS` is `F((chi.neg).neg) ∉ u`.
What is `(chi.neg).neg`? It is `chi.neg.imp bot`. And `F(chi.neg.neg) = chi.neg.neg.neg.all_future.neg`.

This is NOT `F(chi)`. The two formulas are:
- `F(chi) = chi.neg.all_future.neg` (formula: `¬G(¬chi)`)
- `F(chi.neg.neg) = chi.neg.neg.neg.all_future.neg` (formula: `¬G(¬¬¬chi)`)

These ARE NOT definitionally equal.

**HOWEVER**: Looking at the first component of `chi.neg ∈ BRS`:
- `F(chi.neg) ∈ u` where `F(chi.neg) = chi.neg.neg.all_future.neg = (chi.imp bot).neg.all_future.neg`

And the outer hypothesis: `F(chi) ∈ u` where `F(chi) = chi.neg.all_future.neg`.

Now, `F(chi) = neg(G(chi.neg)) = (chi.neg.all_future).neg`.
And `F(chi.neg) = neg(G(chi.neg.neg)) = (chi.neg.neg.all_future).neg`.

For the contradiction via `set_consistent_not_both`, we need two formulas that are negations of
each other. `F(chi)` and `G(chi.neg)` are negations of each other (by `rfl`). So if we had
`G(chi.neg) ∈ u`, we'd have a contradiction with `F(chi) ∈ u`.

But `F(chi.neg) = neg(G(chi.neg.neg))`, NOT `G(chi.neg)`. So `F(chi.neg) ∈ u` does NOT directly
contradict `F(chi) ∈ u` via `set_consistent_not_both`.

### Option D: Use `brs_mutual_exclusion` Plus Seed Structure (ACTUALLY RECOMMENDED)

The real insight is different. The seed consistency proof
(`constrained_successor_seed_restricted_consistent`) does NOT actually need
`neg_not_in_boundary_resolution_set` in the current form. Let me look at what the proof
structure is doing:

`neg_not_in_constrained_successor_seed_restricted` says: if `F(chi) ∈ u` then `chi.neg ∉ seed`.

The BRS case fails because we can't rule out `chi.neg ∈ BRS` from `F(chi) ∈ u` alone.

BUT: could `neg_not_in_constrained_successor_seed_restricted` have a different proof strategy
that bypasses this case split? For instance, instead of showing `chi.neg ∉ seed` by excluding
each component, we could directly use the Fix A1 mutual exclusion property:

**Alternative proof of `neg_not_in_constrained_successor_seed_restricted`**:

The Fix A1 BRS definition says: `chi ∈ BRS` iff `F(chi) ∈ u ∧ FF(chi) ∉ dc ∧ F(chi.neg) ∉ u`.
The third condition `F(chi.neg) ∉ u` is exactly the complement of `F(chi.neg) ∈ u`.

So: if `F(chi) ∈ u`, can `chi.neg ∈ BRS`? Yes — if `F(chi.neg) ∈ u` (not excluded by `F(chi) ∈ u`).

Therefore, with Fix A1, `neg_not_in_boundary_resolution_set` with hypothesis `F(chi) ∈ u` is
still FALSE in general — chi.neg can be in BRS even when F(chi) ∈ u.

**Wait — BUT Fix A1's third condition for `chi.neg ∈ BRS` is `F(chi.neg.neg) ∉ u`**, not
`F(chi) ∉ u`! Let me re-read Fix A1 carefully.

BRS definition with Fix A1:
```lean
{chi | F(chi) ∈ u ∧ FF(chi) ∉ dc ∧ F(chi.neg) ∉ u}
```

For `chi.neg ∈ BRS`:
```lean
{F(chi.neg) ∈ u ∧ FF(chi.neg) ∉ dc ∧ F(chi.neg.neg) ∉ u}
```

The third condition for `chi.neg ∈ BRS` is `F((chi.neg).neg) ∉ u`, which is `F(chi.neg.neg) ∉ u`.

`chi.neg.neg = (chi.imp bot).imp bot` is syntactically different from `chi`. So `F(chi.neg.neg) ≠ F(chi)` definitionally.

Therefore: Fix A1 does NOT directly prevent `chi.neg ∈ BRS` when `F(chi) ∈ u`.
The current theorem statement is UNPROVABLE with Fix A1 as implemented.

---

## The Real Solution: Strengthen Fix A1

The root cause of the continued sorry is that Fix A1 was designed to prevent `chi` and `chi.neg`
from BOTH being in BRS simultaneously, but it was implemented using the condition
`F(chi.neg) ∉ u` (for chi ∈ BRS) and `F(chi.neg.neg) ∉ u` (for chi.neg ∈ BRS). Because
`chi.neg.neg ≠ chi` syntactically, these conditions don't create the cross-link needed for
`neg_not_in_boundary_resolution_set`.

### Fix A1-Corrected: Use the SAME form of mutual exclusion

The condition for `chi ∈ BRS` should be `F(chi.neg) ∉ u` — this correctly prevents `chi.neg`
from satisfying the FIRST condition of BRS (which requires `F(chi.neg) ∈ u`).

Looking at the BRS definition again:
```lean
{chi | F(chi) ∈ u ∧ FF(chi) ∉ dc ∧ F(chi.neg) ∉ u}
```

`chi ∈ BRS` requires the third condition `F(chi.neg) ∉ u`.
`chi.neg ∈ BRS` requires its first condition `F(chi.neg) ∈ u`.

**These directly contradict!** If `chi ∈ BRS`, then `F(chi.neg) ∉ u`. But `chi.neg ∈ BRS`
requires `F(chi.neg) ∈ u`. Contradiction! So `brs_mutual_exclusion` IS correctly proven.

**Now for `neg_not_in_boundary_resolution_set` with hypothesis `F(chi) ∈ u`**:

We need `chi.neg ∉ BRS`. Suppose `chi.neg ∈ BRS`. Then:
1. `F(chi.neg) ∈ u` (first BRS condition for chi.neg)
2. `FF(chi.neg) ∉ dc` (second BRS condition for chi.neg)
3. `F(chi.neg.neg) ∉ u` (third BRS condition for chi.neg — Fix A1 condition)

We have `h_F_in : F(chi) ∈ u`.

Can we derive a contradiction? The fix A1 condition gives `F(chi.neg.neg) ∉ u`, and we have
`F(chi) ∈ u`. If `F(chi) = F(chi.neg.neg)` syntactically, contradiction. But they're different.

**The mathematical truth**: In the proof system (classical), `chi ↔ chi.neg.neg` is provable
(double negation elimination). Therefore `F(chi) ↔ F(chi.neg.neg)` is provable. But proving
`F(chi.neg.neg) ∈ u` from `F(chi) ∈ u` via `drm_closed_under_derivation` requires
`F(chi.neg.neg) ∈ deferralClosure`, which cannot be established without extending the closure.

**Fix A1-Strengthened**: Change the Fix A1 condition to directly use the first BRS condition
identity. The mutual exclusion condition in BRS for `chi` should block `chi.neg.neg` (not just
`chi.neg`), or equivalently, use the definitional equality route.

Actually, the simpler fix is to change the mutual exclusion condition to reference
the SAME syntactic formula. The current BRS for chi.neg uses `F(chi.neg.neg) ∉ u` as the
third condition. The needed contradiction with `F(chi) ∈ u` requires `F(chi)` and
`F(chi.neg.neg)` to be identified, which requires `chi = chi.neg.neg` definitionally.

**This is impossible in Lean** without adding a `simp` lemma or changing the representation.

### Actual Recommended Fix: Reformulate neg_not_in_boundary_resolution_set as Corollary of brs_mutual_exclusion

The call site needs `False` from `h_F_in : F(chi) ∈ u` and `h_brs : chi.neg ∈ BRS`.

From `h_brs : chi.neg ∈ BRS`, the first BRS condition gives `F(chi.neg) ∈ u`.

Now: `F(chi) = neg(G(chi.neg))` (definitional equality in Lean — verified by `rfl` as used in
`neg_not_in_g_content_when_F_in`). And `G(chi.neg) = chi.neg.all_future`.

`F(chi.neg)` by contrast: what is it? `F(chi.neg) = chi.neg.neg.all_future.neg`.

Can we derive `G(chi.neg) ∈ u` and then use `set_consistent_not_both` with `F(chi) ∈ u`?

If `F(chi.neg) ∈ u`, does that imply `G(chi.neg) ∈ u`? NO — `F(chi.neg)` is an existential
and `G(chi.neg)` is a universal. They are not related by this direct path.

**The clean approach** is to directly show `F(chi.neg) ∈ u` contradicts `F(chi) ∈ u` using
the MCS duality structure. Looking at `neg_not_in_g_content_when_F_in`:
- `G(chi.neg) ∈ u` (g_content element) contradicts `F(chi) ∈ u` because `F(chi) = neg(G(chi.neg))`
- This uses `set_consistent_not_both h_mcs.1.2 (Formula.all_future chi.neg) h_G_neg_in_u h_F_in`

But we have `F(chi.neg) ∈ u`, NOT `G(chi.neg) ∈ u`. These are different.

**However**: In the TM proof system, `G(chi.neg) → F(chi.neg)` is NOT valid (G implies F only
if there are future times). `F(chi.neg) → G(chi.neg)` is even less valid. So `F(chi.neg) ∈ u`
and `F(chi) ∈ u` do NOT contradict each other in the MCS.

This confirms: **The theorem `neg_not_in_boundary_resolution_set` with hypothesis `F(chi) ∈ u`
is FALSE in general** (both can be true simultaneously in a valid temporal model).

---

## Final Assessment

### Mathematical Correctness of the Current Statement

**The current theorem statement is FALSE.**

`F(chi) ∈ u` does NOT imply `chi.neg ∉ BRS`. In a DRM where both `F(chi) ∈ u` and
`F(chi.neg) ∈ u`, and where the depth condition `FF(chi.neg) ∉ deferralClosure` holds,
and `F(chi.neg.neg) ∉ u` (which is possible since `F(chi.neg.neg) ≠ F(chi)` syntactically),
all BRS conditions for `chi.neg` are satisfied despite `F(chi) ∈ u`.

### Why the sorry is Irreparable Along the Current Path

The sorry cannot be eliminated because the theorem statement is not provable as written. The
Fix A1 partial implementation (plan v14) correctly added `brs_mutual_exclusion` but did not
resolve the gap in `neg_not_in_boundary_resolution_set`.

### Recommended Path Forward

**Reformulation: Change the call site, not the theorem.**

The theorem `neg_not_in_boundary_resolution_set` should be DELETED and the call at line 1456
should be replaced with a different argument.

The CORRECT statement that is needed at line 1456 is:
"If `chi.neg ∈ BRS` and `F(chi) ∈ u`, then False."

But this is NOT provable from these hypotheses alone (as shown above). Therefore the outer
theorem `neg_not_in_constrained_successor_seed_restricted` with hypothesis `F(chi) ∈ u` is
ALSO not provable in the BRS case.

**The outer theorem statement is wrong for the BRS case.** This means the entire approach of
proving `neg_not_in_constrained_successor_seed_restricted` via the 4-way case split may need
to be reconsidered.

### What IS True (for seed consistency)

The correct property for seed consistency is NOT that `chi.neg ∉ seed` when `F(chi) ∈ u`.
Rather, the seed consistency proof should directly argue that no contradictory pair `{psi, psi.neg}`
can be derived from the seed. The Fix A1 BRS already ensures `chi` and `chi.neg` cannot BOTH
be in BRS (via `brs_mutual_exclusion`). The seed consistency proof should use this directly,
showing that the combined g_content + deferralDisjunctions + p_step_blocking + BRS set cannot
derive bot.

**The correct proof structure for `constrained_successor_seed_restricted_consistent`**:

1. For any finite L ⊆ seed, suppose L ⊢ bot.
2. Partition L into: `L_u` (elements in u) and `L_brs` (BRS elements, which are in the seed but
   not necessarily in u).
3. Show that BRS elements can be replaced by formulas in u: for each `psi ∈ L_brs`, since
   `F(psi) ∈ u`, the deferral disjunction `psi ∨ F(psi)` is in the seed. Using the fact that
   `L ⊢ bot` and `psi ∨ F(psi)` is provable from `F(psi)`, replace `psi` by a case split and
   derive a contradiction in u (which is consistent).
4. This argument does NOT require `chi.neg ∉ BRS` as an intermediate step.

---

## Summary

| Aspect | Finding |
|--------|---------|
| Mathematical status | Theorem statement is FALSE in general |
| Fix A1 impact on this theorem | Insufficient; Fix A1 prevents chi AND chi.neg in BRS simultaneously, but does NOT prevent chi.neg ∈ BRS when F(chi) ∈ u |
| Call site compatibility | Call site has `chi.neg ∈ BRS` available; should use this instead |
| Recommended action | Reformulate parent theorem `neg_not_in_constrained_successor_seed_restricted` to NOT route through `neg_not_in_boundary_resolution_set`; instead prove seed consistency directly |
| Priority | High — this is the current blocking sorry |

## Recommended Approach in Detail

**Option C-Revised**: Delete `neg_not_in_boundary_resolution_set`. Prove seed consistency
(`constrained_successor_seed_restricted_consistent`) directly using the partition argument:
1. Non-BRS part of seed is a subset of u
2. BRS elements satisfy: `chi ∈ BRS → chi ∨ F(chi) ∈ u` (from deferralDisjunctions, since
   `F(chi) ∈ u` triggers the deferral disjunction `chi ∨ F(chi)` being in the seed)
3. Therefore any derivation using a BRS element `psi` can be replaced by a case analysis on
   `psi ∨ F(psi)`, each branch resolvable via u's consistency
4. `brs_mutual_exclusion` (already proven) ensures no two BRS elements form a contradictory pair

This approach bypasses `neg_not_in_boundary_resolution_set` entirely and is the mathematically
correct path to seed consistency.

## Confidence Level

**High** — The mathematical analysis is conclusive:
- `F(chi) ∈ u` and `chi.neg ∈ BRS` (with Fix A1) are simultaneously satisfiable
- `neg_not_in_boundary_resolution_set` with `F(chi) ∈ u` as hypothesis is unprovable (and false)
- The correct path is direct seed consistency proof, bypassing the theorem
- `brs_mutual_exclusion` is correctly proven and should be used directly in the consistency proof

## File References

| File | Lines | Relevance |
|------|-------|-----------|
| SuccExistence.lean | 284-300 | BRS definition and membership lemma (Fix A1 applied) |
| SuccChainFMCS.lean | 1378-1393 | `brs_mutual_exclusion` (proven, correct) |
| SuccChainFMCS.lean | 1411-1440 | `neg_not_in_boundary_resolution_set` (sorry, UNPROVABLE) |
| SuccChainFMCS.lean | 1445-1456 | Call site — this is the only usage |
| SuccChainFMCS.lean | 1512-1548 | `constrained_successor_seed_restricted_consistent` (root sorry) |
| SubformulaClosure.lean | 919-952 | `some_future_in_deferralClosure_is_in_closureWithNeg` |
| SubformulaClosure.lean | 90-110 | `closureWithNeg` definition and `neg_mem_closureWithNeg` |
| RestrictedMCS.lean | 1233-1291 | `drm_closed_under_derivation` (requires conclusion in deferralClosure) |
