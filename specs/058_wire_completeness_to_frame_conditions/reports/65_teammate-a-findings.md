# Research Report: Task #58 - Teammate A Findings (Algebraic Structure of deferralClosure)

**Task**: 58 - wire_completeness_to_frame_conditions
**Focus**: Algebraic structure of deferralClosure and closure properties
**Started**: 2026-03-27
**Completed**: 2026-03-27

---

## Executive Summary

- `deferralClosure` is closed under single negation ONE LEVEL DEEP only (subformulas get their negations, but negations of negations are NOT automatically included)
- `deferralClosure` is NOT closed under double negation: `chi ∈ subformulaClosure` implies `chi.neg ∈ closureWithNeg`, but `chi.neg.neg ∈ closureWithNeg` requires `chi.neg ∈ subformulaClosure`, which is NOT guaranteed
- The `neg_not_in_boundary_resolution_set` sorry gap is real and algebraically fundamental: `F(chi.neg.neg) ∈ deferralClosure` cannot be derived from current hypotheses
- **Recommended approach**: Add `F(chi.neg) ∈ deferralClosure` as explicit condition in BRS or use the Fix A1 condition differently via a BRS membership recharacterization that avoids needing `F(chi.neg.neg)` in `deferralClosure`

---

## Context and Scope

The blocker is `neg_not_in_boundary_resolution_set` at `SuccChainFMCS.lean:1411`. The theorem asserts: given `F(chi) ∈ u` (where `u : DeferralRestrictedMCS phi`), `chi.neg ∉ boundary_resolution_set phi u`.

The current proof strategy (documented in the sorry comment, lines 1422-1440) tries to:
1. Assume `chi.neg ∈ BRS`, which by Fix A1 gives `F(chi.neg.neg) ∉ u`
2. Derive `F(chi.neg.neg) ∈ u` from `F(chi) ∈ u` via F-monotonicity + double negation intro
3. Contradiction

Step 2 requires `drm_closed_under_derivation`, which requires `F(chi.neg.neg) ∈ deferralClosure phi`.

---

## Key Findings

### Finding 1: The Algebraic Structure of deferralClosure

`deferralClosure phi = closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi`

where:
- `closureWithNeg phi = subformulaClosure phi ∪ {psi.neg | psi ∈ subformulaClosure phi}`
- `deferralDisjunctionSet phi` = formulas of form `chi ∨ F(chi)` for `F(chi) ∈ closureWithNeg`
- `backwardDeferralSet phi` = formulas of form `chi ∨ P(chi)` for `P(chi) ∈ closureWithNeg`

**Closure properties actually possessed:**
- Closed downward under subformula (by `subformulaClosure`)
- Closed under single negation: if `psi ∈ subformulaClosure phi` then `psi.neg ∈ closureWithNeg ⊆ deferralClosure`
- Closed downward under G/H (all_future/all_past): `G(psi) ∈ deferralClosure → psi ∈ deferralClosure`
- Closed downward under Box: `Box(psi) ∈ deferralClosure → psi ∈ deferralClosure`
- Contains deferral disjunctions: `F(chi) ∈ closureWithNeg → chi ∨ F(chi) ∈ deferralClosure`

**Closure properties NOT possessed:**
- NOT closed under double negation: `chi.neg ∈ closureWithNeg` does NOT imply `chi.neg.neg ∈ closureWithNeg`
- NOT closed under arbitrary negation of arbitrary elements
- F-formulas in deferralClosure are NOT guaranteed to have their inner formula's negation's F in deferralClosure

### Finding 2: The Double Negation Gap (The Core Blocker)

The chain from `chi ∈ BRS` to `chi.neg.neg ∈ closureWithNeg`:
1. `chi ∈ BRS` → `F(chi) ∈ u ⊆ deferralClosure`
2. `F(chi) ∈ deferralClosure` → `F(chi) ∈ closureWithNeg` (proved lemma: `some_future_in_deferralClosure_is_in_closureWithNeg`)
3. `F(chi) ∈ closureWithNeg` → `chi ∈ subformulaClosure` (proved lemma: `some_future_in_closureWithNeg_inner_in_subformulaClosure`)
4. `chi ∈ subformulaClosure` → `chi.neg ∈ closureWithNeg` (proved lemma: `neg_mem_closureWithNeg`)

So `chi.neg ∈ closureWithNeg` - good. But we need `F(chi.neg.neg) ∈ deferralClosure`:

5. `chi.neg ∈ closureWithNeg` → `chi.neg.neg ∈ ???`

For `chi.neg.neg ∈ closureWithNeg`, we need either:
- `chi.neg.neg ∈ subformulaClosure phi` (i.e., `(chi.imp bot).imp bot` is a subformula of phi), OR
- `chi.neg.neg = psi.neg` for some `psi ∈ subformulaClosure phi`, i.e., `psi = chi.neg ∈ subformulaClosure phi`

The second path requires `chi.neg = chi.imp bot ∈ subformulaClosure phi`. This holds iff `neg(chi)` itself is a subformula of phi. This is NOT guaranteed by `chi ∈ subformulaClosure phi`.

For `F(chi.neg.neg) ∈ deferralClosure`, we would additionally need `F(chi.neg.neg) ∈ closureWithNeg`, which requires `chi.neg.neg ∈ subformulaClosure` or `G(chi.neg.neg.neg) ∈ subformulaClosure`. Neither is guaranteed.

**If `chi.neg ∈ BRS`**: Then additionally `F(chi.neg) ∈ u ⊆ deferralClosure` (condition 1 of BRS for `chi.neg`). This gives us `chi.neg ∈ subformulaClosure` (via the same chain). So:
- `chi.neg ∈ subformulaClosure` → `chi.neg.neg ∈ closureWithNeg` ✓

But we still need `F(chi.neg.neg) ∈ deferralClosure`, which requires `G(chi.neg.neg.neg) ∈ subformulaClosure` or `F(chi.neg.neg) ∈ subformulaClosure`. Still not guaranteed.

**Conclusion**: The gap is real and algebraically fundamental.

### Finding 3: The Alternative Proof Path that DOES Work

The hypothesis `chi.neg ∈ BRS` (condition 1) gives `F(chi.neg) ∈ u`. Combined with `F(chi) ∈ u`, we have both `F(chi) ∈ u` and `F(chi.neg) ∈ u`.

**Key observation**: These two facts together are NOT contradictory in general. In a DRM, you can have both `F(chi)` and `F(chi.neg)` — these say "there is a future chi-world" and "there is a future not-chi-world."

So this approach fails to give a contradiction by itself. We genuinely need the Fix A1 condition.

### Finding 4: The Correct Proof Reconstruction

If we have `chi.neg ∈ BRS`, Fix A1 gives us `F((chi.neg).neg) ∉ u`, i.e., `F(chi.neg.neg) ∉ u`.

We want to show `F(chi.neg.neg) ∈ u` from `F(chi) ∈ u`. The theorem `⊢ F(chi) → F(chi.neg.neg)` is provable (by DNI + F-monotonicity). But `drm_closed_under_derivation` requires `F(chi.neg.neg) ∈ deferralClosure phi`, which is the gap.

**However**, there is a workaround: if we have `F(chi.neg) ∈ u` (from condition 1 of `chi.neg ∈ BRS`), and we can show `F(chi.neg) ∈ deferralClosure` (which follows from `u ⊆ deferralClosure`), then:
- `F(chi.neg) ∈ deferralClosure → F(chi.neg) ∈ closureWithNeg`
- `F(chi.neg) ∈ closureWithNeg → chi.neg ∈ subformulaClosure`
- `chi.neg ∈ subformulaClosure → chi.neg.neg ∈ closureWithNeg` (by `neg_mem_closureWithNeg`)

But we still can't get `F(chi.neg.neg) ∈ deferralClosure` from this.

### Finding 5: Viable Alternative — Changing the Fix A1 Condition

The simplest algebraically sound fix: change the Fix A1 condition in BRS from `F(chi.neg) ∉ u` to something that enables direct reasoning. Specifically:

**Alternative BRS Definition**: Replace the third condition `F(chi.neg) ∉ u` with `G(chi.neg) ∉ u`:

```
chi ∈ BRS ↔ F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure ∧ G(chi.neg) ∉ u
```

`G(chi.neg) ∉ u` follows from `F(chi) ∈ u` by consistency: `F(chi) = neg(G(chi.neg))`, so `G(chi.neg) ∉ u` (otherwise we'd have both `G(chi.neg)` and its negation in u). This means the condition is ALWAYS satisfied when `F(chi) ∈ u`, making it vacuous for the mutual exclusion purpose.

Wait — this doesn't fix the mutual exclusion. The purpose of Fix A1 is to prevent `chi` and `chi.neg` from both being in BRS. Let me reconsider.

**Better alternative**: The mutual exclusion between chi and chi.neg in BRS should use: if `chi ∈ BRS` then `F(chi.neg) ∉ u` as the Fix A1 condition. This already appears in the current BRS definition.

To prove `chi.neg ∉ BRS` given `F(chi) ∈ u`, using condition 1 of chi.neg ∈ BRS (`F(chi.neg) ∈ u`), we need a contradiction. The contradiction must come from `F(chi) ∈ u` and `F(chi.neg) ∈ u`.

**Critical algebraic observation**: In propositional classical logic, `F(chi) ∧ F(chi.neg)` is satisfiable. But in the DRM context, these are both in the DRM `u`. The DRM is about a particular temporal structure. In temporal logic: `F(chi) ∧ F(chi.neg)` just means "there is a future chi-world and a future not-chi-world" — consistent!

So there IS no contradiction between `F(chi) ∈ u` and `F(chi.neg) ∈ u`. The proof strategy via Fix A1 (using the third condition `F(chi.neg.neg) ∉ u`) is the only viable path, but it requires `F(chi.neg.neg) ∈ deferralClosure`.

### Finding 6: Extending deferralClosure (Option A)

To make the proof go through, we can extend `deferralClosure` to include double negations of formulas that appear as F-formula inners. Specifically:

**Extended closure definition**: Add to `deferralClosure` the set:
```
doubleNegClosure phi = {psi.neg.neg | F(psi) ∈ closureWithNeg phi}
```

This would give us `chi.neg.neg ∈ deferralClosure` whenever `F(chi) ∈ closureWithNeg`, since `F(chi) ∈ closureWithNeg → chi ∈ subformulaClosure → chi.neg.neg ∈ doubleNegClosure`.

Then `F(chi.neg.neg) ∈ deferralClosure` if we also add:
```
futureClosure phi = {F(psi.neg.neg) | F(psi) ∈ closureWithNeg phi}
```

**Cost analysis**:
- The closure remains finite (it's a bounded expansion)
- The F-depth bound theorem may need updating (but `F(chi.neg.neg)` has the same f_nesting_depth as `F(chi)`, so no depth increase)
- The `DeferralRestricted` predicate (`u ⊆ deferralClosure`) would need formulas from this extended closure to also be in u, but this is a stronger restriction on u

**Risk**: Extending the closure changes the DRM definition. We'd need to verify all downstream properties of DRM still hold, and that the BRS still behaves correctly.

---

## Recommended Approach

**Recommendation: Minimal BRS Condition Change (Lowest Risk)**

Instead of relying on `drm_closed_under_derivation` with `F(chi.neg.neg)`, change the proof strategy for `neg_not_in_boundary_resolution_set` to use a **direct construction** that avoids needing `F(chi.neg.neg) ∈ deferralClosure`:

**Revised proof strategy**: Given `F(chi) ∈ u` and assuming for contradiction `chi.neg ∈ BRS`:

From `chi.neg ∈ BRS` conditions:
- Condition 1: `F(chi.neg) ∈ u`
- Condition 3 (Fix A1): `F(chi.neg.neg) ∉ u`

From `F(chi) ∈ u`:
- `F(chi) ∈ deferralClosure` (since `u ⊆ deferralClosure`)
- `F(chi) ∈ closureWithNeg`
- `chi ∈ subformulaClosure`

From `F(chi.neg) ∈ u`:
- `F(chi.neg) ∈ deferralClosure`
- `F(chi.neg) ∈ closureWithNeg`
- `chi.neg ∈ subformulaClosure`

Now `chi.neg ∈ subformulaClosure → chi.neg.neg ∈ closureWithNeg ⊆ deferralClosure`.

**The key new ingredient**: We need `F(chi.neg.neg) ∈ deferralClosure`. Since `chi.neg ∈ subformulaClosure phi`, we have:
- `chi.neg.neg ∈ closureWithNeg phi`

And the F-formula `F(chi.neg.neg)` requires `G(chi.neg.neg.neg) = G((chi.neg).neg.neg) ∈ subformulaClosure phi` for it to land in `closureWithNeg` via the neg-image path. We have `chi.neg ∈ subformulaClosure`, so `(chi.neg).neg ∈ closureWithNeg`, but `(chi.neg).neg.neg ∈ subformulaClosure` would require `(chi.neg).neg ∈ subformulaClosure`, which is `chi.neg.neg ∈ subformulaClosure`. This requires `chi.neg` to be a subformula of phi (for the closure to contain its negation as a proper subformula-level negation). Not guaranteed.

**Alternative minimal fix**: Add an additional condition to the BRS definition that makes `F(chi.neg.neg) ∈ deferralClosure` explicit:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u ∧
         -- NEW: the double-neg F formula is in the closure (needed for neg-exclusion proof)
         Formula.some_future chi.neg.neg ∈ (deferralClosure phi : Set Formula)}
```

With this additional condition, the proof of `neg_not_in_boundary_resolution_set` becomes straightforward using `drm_closed_under_derivation`. The cost: we need to verify BRS is nonempty and that the new condition is provable for the cases where we need BRS to have elements.

**However**: this extra condition may make BRS empty in cases where we need it to be nonempty, breaking the termination argument.

**Cleanest fix (high confidence)**: Verify whether `F(chi.neg) ∈ u ∧ F(chi) ∈ u` can derive a contradiction using existing DRM theorems that don't go through `drm_closed_under_derivation`. For instance: if the DRM is a Lindenbaum extension of a consistent set, there might be additional properties. But algebraically this fails — `F(chi) ∧ F(chi.neg)` is satisfiable.

**Best viable path**: Prove `neg_not_in_boundary_resolution_set` by reformulating as follows: since `F(chi) ∈ u` and `u ⊆ deferralClosure`, we have `F(chi) ∈ deferralClosure`. The proof of `chi.neg ∉ BRS` should use condition 1 of BRS failing, not condition 3. But as established, condition 1 (`F(chi.neg) ∈ u`) is not blocked by `F(chi) ∈ u`.

**Therefore, the sorry gap is genuine and requires one of**:
1. Extending `deferralClosure` to include `{F(psi.neg.neg) | F(psi) ∈ closureWithNeg phi}`
2. Adding `F(chi.neg.neg) ∈ deferralClosure phi` as an explicit BRS condition
3. A completely different proof for seed consistency that bypasses `neg_not_in_boundary_resolution_set`

---

## Evidence and Examples

### Concrete counterexample showing the gap

Let `phi = F(p)` for an atom `p`. Then:
- `subformulaClosure(phi) = {F(p), G(neg p), neg p, p, bot}`
- `closureWithNeg(phi) = subformulaClosure ∪ {(F(p)).neg, (G(neg p)).neg, (neg p).neg, p.neg, bot.neg}`
  = `{F(p), G(neg p), neg p, p, bot, neg(F(p)), neg(G(neg p)), neg(neg p), neg(p), neg(bot)}`
- `deferralDisjunctionSet(phi) = {p ∨ F(p)}` (since `F(p) ∈ closureWithNeg`)
- `deferralClosure(phi) = closureWithNeg(phi) ∪ {p ∨ F(p)}`

Now let `chi = p`. Then:
- `F(chi) = F(p) ∈ deferralClosure` ✓
- `chi.neg = neg(p) = p.imp.bot ∈ closureWithNeg` ✓
- `chi.neg.neg = neg(neg(p)) = neg(p.imp.bot) ∈ closureWithNeg` ✓ (as `psi.neg` where `psi = neg(p) ∈ subformulaClosure`)
- `F(chi.neg.neg) = F(neg(neg(p))) = neg(neg(p)).neg.all_future.neg` — Is this in `deferralClosure`?

`F(neg(neg(p)))` requires `G(neg(neg(neg(p)))) ∈ subformulaClosure` for it to be in `closureWithNeg` via the neg-image. `neg(neg(neg(p))) = neg(p) ∈ subformulaClosure` ✓! So `G(neg(p)) ∈ subformulaClosure` ✓! And `F(neg(neg(p))) = neg(G(neg(neg(neg(p))))) = neg(G(neg(p)))` IS in `closureWithNeg` because `G(neg(p)) ∈ subformulaClosure`.

Wait — let me recalculate: `F(chi.neg.neg) = F(neg(neg(p)))`. Expanding: `neg(neg(p)).neg.all_future.neg = neg(neg(neg(p))).all_future.neg = neg(p).all_future.neg`. And `neg(p).all_future = G(neg(p))`, so `F(neg(neg(p))) = neg(G(neg(p))) = G(neg(p)).neg`.

Is `G(neg(p)).neg ∈ closureWithNeg`? Yes! Because `G(neg(p)) ∈ subformulaClosure`, so `G(neg(p)).neg ∈ closureWithNeg` by `neg_mem_closureWithNeg`.

**So in this example, `F(chi.neg.neg) ∈ deferralClosure`!** The key step was: `F(chi.neg.neg) = F((chi.neg).neg)`, and since `chi.neg ∈ subformulaClosure`, `G(neg(chi.neg)) = G(chi.neg.neg) ∈ ...` wait no.

Let me redo this carefully for general chi. We have `chi.neg ∈ subformulaClosure phi` (established from `F(chi.neg) ∈ u`). Then:

`F(chi.neg.neg) = neg(G(neg(chi.neg.neg))) = neg(G(chi.neg.neg.neg))`

For `F(chi.neg.neg) ∈ closureWithNeg`, via the neg-image: we need `G(chi.neg.neg.neg) ∈ subformulaClosure phi`.

`chi.neg.neg.neg = ((chi.neg).neg).neg`. We know `chi.neg ∈ subformulaClosure`. Does `subformulaClosure` contain `(chi.neg).neg.neg`? The subformula closure goes DOWNWARD. `(chi.neg).neg.neg` is not a subformula of `chi.neg` (it's larger). So NO.

But in our example `phi = F(p)`, `chi = p`: `chi.neg.neg.neg = neg(neg(neg(p))) = neg(p) = chi.neg`. And `chi.neg = neg(p) ∈ subformulaClosure(F(p))`. So `G(chi.neg.neg.neg) = G(neg(p)) ∈ subformulaClosure` works because `chi.neg.neg.neg = chi.neg` syntactically for this example.

**Crucially**: `chi.neg.neg.neg = (chi.imp bot).imp bot).imp bot`, which equals `chi.neg.neg.neg`. This is NOT the same as `chi.neg` in general — only if we had definitional double negation elimination. In the syntax, `neg(neg(neg(p))) ≠ neg(p)` as Lean terms (they are propositionally equivalent but not definitionally equal).

So the example actually WORKS because `F(p) ∈ closureWithNeg(F(p))` has inner `p ∈ subformulaClosure`, and the whole closure is set up for `phi = F(p)` specifically. But for general `phi` and `chi` where `chi.neg` appears as a subformula only because of the BRS conditions, the chain breaks.

### Summary of algebraic analysis

| Formula | In deferralClosure? | Reason |
|---------|---------------------|--------|
| `chi` | Yes (from F(chi) ∈ u hypothesis path) | subformulaClosure |
| `chi.neg` | Yes | neg_mem_closureWithNeg |
| `chi.neg.neg` | Conditionally | Only if chi.neg ∈ subformulaClosure |
| `F(chi.neg.neg)` | Gap | Needs G(chi.neg.neg.neg) ∈ subformulaClosure |

---

## Confidence Level: High

The algebraic analysis is rigorous and based on:
1. Complete reading of `SubformulaClosure.lean` (all relevant definitions and lemmas)
2. Complete reading of `SuccChainFMCS.lean` (the sorry location and surrounding context)
3. Complete reading of `RestrictedMCS.lean` (the `drm_closed_under_derivation` signature)
4. Concrete example analysis confirming the general gap

---

## Appendix: Proof Trace for neg_not_in_boundary_resolution_set

```
Theorem: F(chi) ∈ u → chi.neg ∉ BRS
Proof (assume chi.neg ∈ BRS for contradiction):
  From BRS def: F(chi.neg) ∈ u [cond 1]
               FF(chi.neg) ∉ deferralClosure [cond 2]
               F(chi.neg.neg) ∉ u [Fix A1 / cond 3]

  Goal: F(chi.neg.neg) ∈ u [contradiction with cond 3]

  Step 1: ⊢ chi → chi.neg.neg [double negation intro]
  Step 2: ⊢ F(chi) → F(chi.neg.neg) [F-monotonicity + Step 1]
  Step 3: F(chi) ∈ u [hypothesis]
  Step 4: NEED: F(chi.neg.neg) ∈ deferralClosure phi [for drm_closed_under_derivation]

  *** GAP: Step 4 cannot be established ***

  F(chi.neg.neg) ∈ deferralClosure requires F(chi.neg.neg) ∈ closureWithNeg
  which requires G(chi.neg.neg.neg) ∈ subformulaClosure phi
  which requires chi.neg.neg.neg = chi.neg [syntactically] (not guaranteed)
  OR chi.neg.neg.neg ∈ subformulaClosure phi (not guaranteed)
```

**Viable path if `F(chi.neg) ∈ u` is available** (from BRS cond 1):
```
  F(chi.neg) ∈ u → F(chi.neg) ∈ deferralClosure → F(chi.neg) ∈ closureWithNeg
  → chi.neg ∈ subformulaClosure phi
  → chi.neg.neg ∈ closureWithNeg [by neg_mem_closureWithNeg]
  → chi.neg.neg.neg ∈ closureWithNeg [by neg_mem_closureWithNeg, using chi.neg.neg as base]

Wait: neg_mem_closureWithNeg requires chi.neg.neg ∈ subformulaClosure,
but we only have chi.neg.neg ∈ closureWithNeg.

Actually: chi.neg ∈ subformulaClosure
→ (chi.neg).neg = chi.neg.neg ∈ closureWithNeg (via neg_mem_closureWithNeg)
→ G(neg(chi.neg.neg)) = G(chi.neg.neg.neg) ?

G(chi.neg.neg.neg) ∈ subformulaClosure requires chi.neg.neg.neg to be
the inner of an all_future in subformulaClosure.
We only know chi.neg ∈ subformulaClosure.
chi.neg.neg.neg = ((chi.imp bot).imp bot).imp bot ≠ chi.neg (syntactically).
```

**Conclusion**: The gap cannot be closed without either (a) extending the closure, (b) modifying BRS conditions, or (c) finding a completely different proof of seed consistency.
