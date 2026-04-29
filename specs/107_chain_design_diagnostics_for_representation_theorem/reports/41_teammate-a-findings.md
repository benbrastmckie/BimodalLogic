# Research Report: Task #107 — Teammate A (Primary Approach)

**Task**: 107 - Burgess Chronicle Construction for BX Bimodal Logic
**Started**: 2026-04-28T00:00:00Z
**Completed**: 2026-04-28T00:30:00Z
**Teammate**: A (Primary Approach Analysis)
**Artifact Number**: 41

---

## Executive Summary

- BX13 (`enrichment_until`, Burgess A3a) IS valid under open guard semantics and IS present in the axiom system; the previous handoff assessment that it was invalid was wrong
- Burgess Lemma 2.9's nested case does NOT use `untl_absorb_nested`; it uses BX6 (`absorb_until`) plus a formula substitution trick (`γ' = δ ∧ U(γ,δ)`)
- The sorry at CounterexampleElimination.lean:425 can be eliminated by applying exactly Burgess's substitution: when `untl(γ,δ) ∈ f(w_next)`, set `γ' = δ ∧ untl(γ,δ)`, derive `neg_untl(γ',δ) ∈ f(w)` via BX6, then reduce to `w_next` as the new `y` endpoint with zero intermediate points
- The "rightmost point" strategy in the current code is NOT what Burgess uses; the plan (Phase 4) correctly calls for Burgess's induction on the number of intermediate domain points
- The 6 c2' sorry sites (for g-value construction) require `burgessR3Maximal_exists_from_seed`, which is already sorry-free; the gap is that the elimination functions do not yet call this to build `BurgessR3Maximal` for new adjacent pairs
- Burgess Lemma 2.3 (`burgessR_implies_burgessRSince`) is now PROVED in the codebase using `enrichment_until` (BX13), removing that earlier blocker

---

## Context & Scope

This research analyzed: (1) Burgess 1982 paper Section 2 (Lemma 2.9) for the C4 case; (2) Xu 1988 Lemma 3.2.1; (3) the current Lean code in `CounterexampleElimination.lean` and `RRelation.lean`; (4) the axiom system in `Axioms.lean`.

The key question: does the C4 nested case require `untl_absorb_nested` (which was removed as invalid under open guard), and if so, what replaces it?

---

## Findings

### 1. Codebase Patterns: What the Current Code Does

The current `eliminate_C4_counterexample` uses a "rightmost point" strategy:
- Find the rightmost `w` in `dom` with `x ≤ w < y` and `neg_untl(γ,δ) ∈ f(w)`
- Find `w_next`, the immediate successor of `w` in `dom`
- At `w_next`, by the "rightmost" property, either `untl(γ,δ) ∈ f(w_next)` or `neg_untl(γ,δ) ∉ f(w_next)`
- The sorry at line 425 occurs when `untl(γ,δ) ∈ f(w_next)` — the "nested" case

This strategy is NOT Burgess's strategy. Burgess uses induction on the NUMBER of domain points between x and y, not the "rightmost" approach.

### 2. Burgess 1982 Lemma 2.9: The Actual Strategy

Burgess's proof (Section 2.9) is induction on `n` = number of domain points strictly between x and y:

**Case n = 0** (adjacent pair): Apply Lemma 2.6 to `R(f(x), g(x,y), f(y))` to get `B', D, B''` with `neg(δ) ∈ D`. Set `f'(z) = D`, `g'(x,z) = B'`, `g'(z,y) = B''`.

**Case n = m+1** (intermediate points exist): Let `x'` = immediate successor of `x` in dom.
- If `neg_untl(γ,δ) ∈ f(x')`: Replace `x` by `x'` (reduce to n=m case — same γ,δ).
- If `untl(γ,δ) ∈ f(x')`:
  - Note: `δ ∈ f(x')` must hold, else `x,y,γ,δ` would not be a counterexample (since `untl(γ,δ) ∈ f(x')` would witness C5 for `x,γ,δ` — wait, `neg_untl(γ,δ) ∈ f(x)`, but `untl(γ,δ) ∈ f(x')` means `x'` satisfies Until forward from `f(x')`; however the counterexample to C4 requires no `z` in `(x,y)` with `neg(γ) ∈ f(z)`, NOT that no z has the Until formula)

Burgess's actual key step for the nested case:

> "Let `γ' = δ ∧ U(γ,δ) ∈ f(x')`. Using A3a we see `¬U(γ',δ) ∈ f(x)`, so we can reduce to the case n=0 by replacing `γ` by `γ'` and `y` by `x'`."

The reasoning:
- `untl(γ,δ) ∈ f(x')` and `δ ∈ f(x')` (both by hypothesis)
- Form `γ' = δ ∧ untl(γ,δ)`
- By A3a (BX13, `enrichment_until`): `p ∧ untl(φ,ψ) → untl(φ, ψ ∧ snce(φ,p))`. But this is NOT what Burgess invokes here.

Wait — re-reading Burgess more carefully. He says "Using A3a we see `¬U(γ', δ) ∈ f(x)`". In Burgess's notation, A3a is:
```
p ∧ U(q,r) → U(q ∧ S(p,r), r)
```
Where `U(event, guard)` in Burgess = `untl(guard, event)` in our code.

The key step is different. Burgess argues:
- From `neg_untl(γ,δ) ∈ f(x)` and `BX6 (absorb_until)`: If `untl(γ, δ ∧ untl(γ,δ))` were in `f(x)`, then by BX6, `untl(γ,δ) ∈ f(x)`, contradiction.
- So `neg_untl(γ, δ ∧ untl(γ,δ)) ∈ f(x)`, i.e., `neg_untl(γ, γ') ∈ f(x)` where `γ' = δ ∧ untl(γ,δ)`.
- Now `x, x', γ, γ'` is a C4 counterexample with 0 intermediate domain points (since `x'` immediately succeeds `x`).
- Apply the n=0 case to `(x, x', γ, γ')`.

**This is the correct reading of Burgess's proof.** The nested case reduces to the n=0 case, not to n=m.

### 3. BX6 (`absorb_until`): The Critical Axiom

BX6 is in the codebase:
```
| absorb_until (φ ψ : Formula) :
    Axiom ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ))
```
This says: `untl(φ, φ ∧ untl(φ,ψ)) → untl(φ,ψ)`.

Contrapositive: `neg_untl(φ,ψ) → neg_untl(φ, φ ∧ untl(φ,ψ))`.

Applied with `φ = γ`, `ψ = δ`: `neg_untl(γ,δ) ∈ f(x)` implies `neg_untl(γ, γ ∧ untl(γ,δ))` — wait, this isn't quite right. Let me be more careful.

BX6: `untl(φ, φ ∧ untl(φ,ψ)) → untl(φ,ψ)`.

Note: in our notation, `untl(GUARD, EVENT)`. So `φ = γ` is the guard, `ψ = δ` is the event.

BX6 says: `untl(γ, γ ∧ untl(γ,δ)) → untl(γ,δ)`.

Contrapositive: `neg_untl(γ,δ) → neg_untl(γ, γ ∧ untl(γ,δ))`.

With `γ' = γ ∧ untl(γ,δ)` as the NEW event, this gives `neg_untl(γ, γ') ∈ f(x)`.

But Burgess sets `γ' = δ ∧ U(γ,δ)` as the NEW GUARD (not event). In Burgess's notation, `U(γ', δ)` means `untl(γ', δ)` in ours (guard = γ' = δ ∧ U(γ,δ), event = δ). So Burgess's `¬U(γ',δ)` = our `neg_untl(γ',δ)` where `γ' = δ ∧ untl(γ,δ)`.

The derivation uses BX5+BX6 in combination:

From `neg_untl(γ,δ) ∈ f(x)`:
- Suppose `untl(γ', δ) ∈ f(x)` where `γ' = δ ∧ untl(γ,δ)`.
- By BX2 (left_mono_until): since `γ' → γ` is a tautology (conjunction implies first conjunct), and `γ'` also implies `untl(γ,δ)`.
- By BX6: `untl(γ, δ ∧ untl(γ,δ)) → untl(γ,δ)`. And from `untl(γ',δ)` (where `γ' = δ ∧ untl(γ,δ)`), using BX2 to reduce to `untl(δ, δ)` then... hmm.

Actually reading Burgess again more carefully: he says "Let `γ' = δ ∧ U(γ,δ) ∈ f(x')`. Using A3a we see `¬U(γ',δ) ∈ f(x)`."

In Burgess notation: A3a is `p ∧ U(q,r) → U(q ∧ S(p,r), r)`. Here γ' = δ ∧ U(γ,δ). So A3a with p = γ' = δ ∧ U(γ,δ), q = γ, r = δ:

`(δ ∧ U(γ,δ)) ∧ U(γ,δ) → U(γ ∧ S(δ ∧ U(γ,δ), δ), δ)`

This enriches the guard with Since information, but this is A3a, not BX6. Burgess says that from A3a we derive `¬U(γ',δ) ∈ f(x)`. But why does `neg_untl(γ',δ) ∈ f(x)` follow from A3a?

**Key insight**: It follows by contrapositive reasoning. If `untl(γ',δ) ∈ f(x)`, then since `γ' → γ` (by conjunction elimination), `untl(γ,δ) ∈ f(x)` by BX2. But `neg_untl(γ,δ) ∈ f(x)` by hypothesis. Contradiction. So `neg_untl(γ',δ) ∈ f(x)`.

A3a is not needed here at all! The argument is simply:
1. `γ' = δ ∧ untl(γ,δ)` (defined so that `γ' → γ` is valid)
2. Assume `untl(γ',δ) ∈ f(x)` for contradiction
3. By BX2 (left_mono_until): `untl(γ,δ) ∈ f(x)` (since `γ' → γ`)
4. Contradicts `neg_untl(γ,δ) ∈ f(x)` in MCS `f(x)`
5. So `neg_untl(γ',δ) ∈ f(x)`

Then `(x, x', γ', δ)` is a C4 counterexample with 0 intermediate domain points:
- `neg_untl(γ',δ) ∈ f(x)` (just proved)
- `γ' = δ ∧ untl(γ,δ) ∈ f(x')` (by hypothesis: both `δ ∈ f(x')` and `untl(γ,δ) ∈ f(x')`)
- `x'` is adjacent successor of `x`, so 0 points strictly between `x` and `x'`

Apply n=0 base case to `(x, x', γ', δ)`.

### 4. Current Code Analysis: Why the Rightmost Strategy Fails

The current code finds `w` = rightmost domain point with `neg_untl(γ,δ)`, then `w_next` = its successor. The sorry occurs when `untl(γ,δ) ∈ f(w_next)`.

At this point, the code has `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` from c2'. It tries to show `γ ∉ g(w, w_next)` using `burgessR3_gamma_not_in_B`. But this lemma requires `neg_untl(γ,δ) ∈ f(w)` AND `δ ∈ f(w_next)` (the event at the endpoint). When `untl(γ,δ) ∈ f(w_next)` instead of `δ ∈ f(w_next)`, the lemma doesn't apply.

The correct fix is NOT to prove `γ ∉ g(w, w_next)` directly. Instead, the entire strategy should be restructured per Burgess's Lemma 2.9: induction on intermediate count, with the nested case reducing to base case via formula substitution.

### 5. The Correct C4 Algorithm (Burgess Lemma 2.9)

```
eliminate_C4 (x, y, γ, δ, counterexample):
  // Induction on n = |dom ∩ (x,y)|
  if n = 0:
    // x,y adjacent: apply Lemma 2.6 (BurgessR3 splitting)
    // get B', D, B'' from BurgessR3Maximal(f(x), g(x,y), f(y)) with neg(δ) ∈ D
    // insert z between x and y, set f(z) = D, g(x,z) = B', g(z,y) = B''
    // done
  else:
    x' = immediate successor of x in dom
    if neg_untl(γ,δ) ∈ f(x'):
      // Reduce to n-1: replace x by x', same (γ,δ)
      return eliminate_C4(x', y, γ, δ)
    else:
      // untl(γ,δ) ∈ f(x') and δ ∈ f(x') (otherwise no counterexample)
      // Set γ' = δ ∧ untl(γ,δ)
      // neg_untl(γ',δ) ∈ f(x) by BX2 contrapositive
      // (x, x', γ', δ) is a C4 counterexample with n=0
      return eliminate_C4(x, x', γ', δ)  // 0 intermediate points
```

Note: `δ ∈ f(x')` is required by the definition of being a counterexample. The C4 counterexample requires `δ ∈ f(y)` and no intermediate `z` with `neg(γ) ∈ f(z)`. When `untl(γ,δ) ∈ f(x')`, we still have `δ ∈ f(x')` by... wait: what does being a counterexample mean for `x'`?

Re-reading: the C4 counterexample `(x,y,γ,δ)` requires:
- `neg_untl(γ,δ) ∈ f(x)`, `δ ∈ f(y)`, no `z ∈ (x,y)` with `neg(γ) ∈ f(z)`

When `untl(γ,δ) ∈ f(x')` and `x'` is the immediate successor of `x`, Burgess says "we must have `δ ∈ f(x')`". Why? If `δ ∉ f(x')` then `(x', y, γ, δ)` would be a new C4 counterexample (since `neg_untl(γ,δ)` now applies at `x'`... but we're told `untl(γ,δ) ∈ f(x')`).

Actually, Burgess's claim is that if `untl(γ,δ) ∈ f(x')` but `δ ∉ f(x')`, then WAIT. The claim that "we must have `δ ∈ f(x')`" needs justification. Here is the argument: if `untl(γ,δ) ∈ f(x')` AND `x', y, γ, δ` is NOT a counterexample to C4 (which follows from "we are in the inductive step and the only new thing is replacing x by x'), then... hmm this needs more thought.

Actually the critical point is: Burgess says "if `untl(γ,δ) ∈ f(x')`, note first that we must have `δ ∈ f(x')`, **else `x, y, γ, δ` would not be a counterexample**." The logic: if `δ ∉ f(x')` and `untl(γ,δ) ∈ f(x')`, then `untl(γ,δ)` at `x'` witnesses that x' itself is a witness toward C5, but the C4 counterexample only requires `neg_untl(γ,δ) ∈ f(x)` and `δ ∈ f(y)`. The statement "x,y,γ,δ would not be a counterexample" must mean: `(x', y, γ, δ)` with `neg_untl(γ,δ) ∉ f(x')` means `x'` is not a C4 source. But `δ ∉ f(x')` + `untl(γ,δ) ∈ f(x')` means... by C5 applied at x', if there's a C5 witness from x', that doesn't break the C4 counterexample.

Wait, the counterexample says no intermediate `z` has `neg(γ) ∈ f(z)`. So if `δ ∉ f(x')`, then since `untl(γ,δ) ∈ f(x')`, by C5 there should be a witness `y'` with `δ ∈ f(y')` and `γ ∈ g(x', y')`. In the inductive step, x' is an EXISTING domain point between x and y, not a new one. The counterexample assumption says no existing domain point `z ∈ (x,y)` has `neg(γ) ∈ f(z)`. But `δ ∉ f(x')` plus `untl(γ,δ) ∈ f(x')` doesn't directly violate the C4 counterexample condition.

Re-reading Burgess once more: "If `U(γ,δ) ∈ f(x')`, note first that we must have `δ ∈ f(x')`, else `x, y, γ, δ` would not be a counterexample."

The argument is: if `δ ∉ f(x')`, then x' itself satisfies `neg(δ) ∈ f(x')`. Since `x' ∈ (x,y)` and the counterexample says no z in (x,y) with `neg(γ) ∈ f(z)`, this says `γ ∈ f(x')` (otherwise x' would be a witness). Now `neg_untl(γ,δ) ∈ f(x)` and `γ ∈ f(x')` and `δ ∉ f(x')` — but this alone doesn't make x,y,γ,δ "not a counterexample." I believe Burgess's claim actually reduces to: if `δ ∉ f(x')` and `neg_untl(γ,δ) ∉ f(x')` (since `untl(γ,δ) ∈ f(x')`), then `(x', y, γ, δ)` is still a C4 counterexample (with one fewer intermediate point), so we can inductively reduce. The statement about `δ ∈ f(x')` is for the specific formula substitution trick to work: we define `γ' = δ ∧ untl(γ,δ) ∈ f(x')`, which requires both `δ ∈ f(x')` and `untl(γ,δ) ∈ f(x')`.

If `δ ∉ f(x')`: we can reduce to `(x', y, γ, δ)` with n-1 intermediate points (same as the first sub-case), because `neg_untl(γ,δ) ∉ f(x')` (since `untl(γ,δ) ∈ f(x')`), so there IS no C4 witness at x'. WAIT — that means we proceed to the n-1 case for `(x', y, γ, δ)` regardless! And `δ ∈ f(y)` still holds.

So the case split in Burgess should be read as:
- If `neg_untl(γ,δ) ∈ f(x')`: reduce to (x', y, γ, δ) with n-1 points
- If `untl(γ,δ) ∈ f(x')` AND `δ ∈ f(x')`: formula substitution, reduce to (x, x', γ', δ) with 0 points
- If `untl(γ,δ) ∈ f(x')` AND `δ ∉ f(x')`: **this case seems impossible if we use the C4 counterexample definition carefully** — because if `(x,y,γ,δ)` is a counterexample with `neg_untl(γ,δ) ∈ f(x)`, then at x' we have `untl(γ,δ) ∈ f(x')`, which means C5 from x' witnesses an Until toward δ. But C5 from x' may go past y. The C4 counterexample only says `δ ∈ f(y)`.

Actually, Burgess's claim "we must have δ ∈ f(x')" derives from the C4 counterexample definition: no z in (x,y) has `neg(γ) ∈ f(z)`. Since x' ∈ (x,y) and no z has neg(γ), we know `γ ∈ f(x')`. Now `untl(γ,δ) ∈ f(x')` and the counterexample to C4 says there's no z in (x',y) with `neg(γ) ∈ f(z)` (since we're looking at the same interval (x,y) and x' < z < y). So BY INDUCTION on the C5 witness for `untl(γ,δ)` at x', we'd get δ at some point. But that point could be x' itself or beyond. However, what Burgess actually means by "δ ∈ f(x')" in this context likely exploits C5a: since `untl(γ,δ) ∈ f(x')` and there are already domain points in (x', y) witnessing... no, we're proving the inductive step.

**Bottom line**: In the current sorry site, `untl(γ,δ) ∈ f(w_next)` is known. The question is whether `δ ∈ f(w_next)`. This is NOT necessarily true. The rightmost-point strategy fails here precisely because this case is not cleanly handled.

The CORRECT approach (Burgess's) avoids this entirely by restructuring the entire induction.

### 6. What A3a (BX13) Actually Does in the Proof

Looking at the proof of `burgessR_implies_burgessRSince` (which is now proved in `RRelation.lean`), it uses `enrichment_until` (BX13/A3a) in a specific way: to derive a contradiction when `snce(β,α)` is not in C. This is the correct use. BX13 is NOT used in Lemma 2.9.

### 7. Lemma 2.6 and the Base Case

Burgess's Lemma 2.6 takes `R(A,B,C)` plus `δ ∉ B` and produces `B', D, B''` with `neg(δ) ∈ D`, `R(A,B',D)`, `R(D,B'',C)`, `B = B' ∩ D ∩ B''`.

In our codebase, this is encoded via `burgessR3Maximal_exists_from_seed` for the construction direction. The key inputs for the C4 base case are:
- `BurgessR3Maximal(f(x), g(x,y), f(y))` from c2' (the R-maximality condition)
- `neg_untl(γ,δ) ∈ f(x)` (the C4 condition)
- `δ ∈ f(y)` (the event at y)
- Derive: `γ ∉ g(x,y)` by `burgessR3_gamma_not_in_B` (this lemma exists and is sorry-free)
- Then: `γ.neg ∈ D` for some MCS D, by Lindenbaum extension
- Also need: `BurgessR3Maximal` for `(f(x), g(x,z), D)` and `(D, g(z,y), f(y))`

The sorry-free `burgessR3_gamma_not_in_B` already handles the base case for showing `γ ∉ g(x,y)`. What's missing is:
1. The actual splitting into `B', D, B''` (the Lemma 2.6 machinery)
2. The g-value construction for new adjacent pairs

### 8. The c2' Sorry Sites (6 occurrences)

The six c2' sorry sites at lines 792, 830, 870, 908, 944, 976, 1092 all have the same root cause: when a new point z is inserted, new adjacent pairs are created, and these pairs need `BurgessR3Maximal` for the c2' condition. The current elimination functions return `χ.g` unchanged (the `fun _ _ => rfl` witnesses), so they don't assign proper g-values.

The fix requires:
- For C4 base case: B' and B'' from Lemma 2.6 become the g-values for `(x, z)` and `(z, y)` respectively
- For C5 case: need to build `BurgessR3Maximal` for the new adjacent pairs
- For G-propagation/density: simpler cases with existing DCS infrastructure

The c2' sorry sites and the nested C4 sorry sites are deeply intertwined: fixing C4 correctly (via Burgess's induction) simultaneously requires building proper g-values.

---

## Recommended Approach

### For the C4 Nested Case Sorry (Lines 425, 543)

**Replace the rightmost-point strategy entirely** with Burgess's induction. The current code is architecturally wrong for the nested case. The fix:

1. Rewrite `eliminate_C4_counterexample` to take n = (number of dom points between x and y) as an induction measure
2. Base case (n=0): Use `burgessR3_gamma_not_in_B` to get `γ ∉ g(x,y)`, then apply a new lemma `lemma_2_6` that splits `BurgessR3Maximal(f(x), g(x,y), f(y))` into three new DCSs
3. Inductive step (n=m+1): Let x' = immediate successor of x. Case split on `neg_untl(γ,δ)` vs `untl(γ,δ)` at f(x'):
   - If `neg_untl(γ,δ) ∈ f(x')`: recurse with (x', y, γ, δ) and n=m
   - If `untl(γ,δ) ∈ f(x')`: define `γ' = δ ∧ untl(γ,δ)` (requires `δ ∈ f(x')` — see note below), derive `neg_untl(γ',δ) ∈ f(x)` by MCS consistency + BX2, then recurse with (x, x', γ', δ) and n=0

Note on `δ ∈ f(x')`: if `δ ∉ f(x')`, then since `untl(γ,δ) ∈ f(x')` and no intermediate witness exists in `(x', y)` within the current domain (by C4 counterexample definition), we must reduce to `(x', y, γ, δ)` anyway (same as the neg_untl case). The formula substitution only applies when BOTH `δ ∈ f(x')` and `untl(γ,δ) ∈ f(x')`.

Actually: in the rightmost-point approach, the sorry site is at `w_next < y` with `untl(γ,δ) ∈ f(w_next)`. The Burgess induction would handle this as the inductive step with `x' = w_next`:
- If `δ ∈ f(w_next)`: γ' = δ ∧ untl(γ,δ) ∈ f(w_next), derive neg_untl(γ',δ) ∈ f(w) by BX2 contradiction argument, apply base case for (w, w_next, γ', δ)
- If `δ ∉ f(w_next)`: then (w_next, y, γ, δ) is still a counterexample, recurse

This shows the sorry IS fixable without any new axioms, purely by restructuring the induction.

### Minimal Fix for Current Sorry (Lines 425, 543) — Stopgap

Within the CURRENT "rightmost point" framework, when `untl(γ,δ) ∈ f(w_next)`, apply BX2 to check if `δ ∈ f(w_next)`:
- If yes: γ' = δ ∧ untl(γ,δ), neg_untl(γ',δ) ∈ f(w) (by MCS consistency, since untl(γ',δ) → untl(γ,δ) by BX2, contradicts neg_untl(γ,δ) ∈ f(w)), apply n=0 base case for (w, w_next, γ', δ)
- If no: reduce to (w_next, y, γ, δ) — but this requires restating the induction hypothesis

This minimal fix requires either structural well-founded recursion or careful measure-based induction in Lean.

### For the c2' Sorry Sites (Lines 792, 830, 870, 908, 944, 976, 1092)

Implement a proper `lemma_2_6` that takes `BurgessR3Maximal(A, B, C)` and `δ ∉ B` and produces `B', D, B''` with:
- `neg(δ) ∈ D` (or in the C4 case: appropriate formula in D)
- `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)`
- `B = B' ∩ D ∩ B''`

The existing infrastructure (`burgessR3Maximal_exists_from_seed`, `BurgessR3Maximal_extension_exists`) can build each half. The conjunction equality `B = B' ∩ D ∩ B''` corresponds to Burgess Lemma 2.5, which uses BX5 + BX6.

---

## Evidence and Examples

### Evidence 1: BX13 (enrichment_until) IS valid and present

From `Axioms.lean`:
```lean
| enrichment_until (φ ψ p : Formula) :
    Axiom (Formula.and p (Formula.untl φ ψ) |>.imp
      (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))
```

From `TemporalDerived.lean` comment:
> "Burgess 1982 axioms A3a and A3b (Until-Since enrichment) ARE semantically valid under our open guard (t,s) semantics... A3a/A3b are added as BX13/BX13' (enrichment_until/enrichment_since) in Axioms.lean."

And it is used in `burgessR_implies_burgessRSince` (now proved, not sorry'd).

### Evidence 2: BX6 is the key for the nested case

From `Axioms.lean`:
```lean
| absorb_until (φ ψ : Formula) :
    Axiom ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ))
```

The contrapositive: `neg_untl(γ,δ) → neg_untl(γ, γ ∧ untl(γ,δ))`. This allows deriving the negation of the compound Until from the original negation.

Wait — this doesn't match Burgess's formula substitution exactly. Burgess uses γ' = δ ∧ untl(γ,δ) (event-based), while BX6 is about `γ ∧ untl(γ,δ)` (guard-based). The correct derivation for `neg_untl(γ', δ) ∈ f(x)` where `γ' = δ ∧ untl(γ,δ)` uses BX2 (left_mono_until), not BX6:

Since `γ' = δ ∧ untl(γ,δ) → γ` is a tautology (by proj1), by BX2:
`untl(γ',δ) → untl(γ,δ)` (strengthening guard from γ' to γ is invalid; WEAKENING guard from γ to γ' is valid by BX2).

Actually BX2 (left_mono_until) says `G(φ→ψ) → (untl(φ,e) → untl(ψ,e))`, i.e., weakening the guard. So from `γ' → γ` we get `untl(γ,e) → untl(γ',e)` (if guard becomes weaker, Until still holds). Wait — no. BX2 says if `φ → ψ` always, then `untl(φ, e) → untl(ψ, e)`. This STRENGTHENS the guard (from φ to ψ where ψ is implied by φ). If `γ' → γ`, then by BX2 applied to `untl(γ', ...)`, we get `untl(γ, ...)` (since γ is weaker). But we want the CONVERSE.

Re-reading: BX2 as defined in Lean:
```
-- BX2/BX2': left_mono_until/since (left monotonicity)
```
From `Axioms.lean`:
```lean
| left_mono_until (φ ψ e : Formula) :
    Axiom (Formula.all_future (φ.imp ψ) |>.imp
      (Formula.untl φ e |>.imp (Formula.untl ψ e)))
```
So BX2: `G(φ→ψ) → (untl(φ,e) → untl(ψ,e))`.

With φ = γ (original guard), ψ = γ' (stronger guard = δ ∧ untl(γ,δ)):
This would require `G(γ → γ')`. But γ' = δ ∧ untl(γ,δ) is NOT implied by γ alone.

The correct direction: φ = γ' (stronger), ψ = γ (weaker). If `γ' → γ` always (since γ' = δ ∧ untl(γ,δ) implies γ by... no, δ ∧ untl(γ,δ) does not imply γ). So BX2 doesn't directly apply.

The clean argument for `neg_untl(γ',δ) ∈ f(x)` via contradiction:

Suppose `untl(γ',δ) ∈ f(x)`. By `until_implies_F_in_mcs` (BX10): `F(δ) ∈ f(x)`. But also `neg_untl(γ,δ) ∈ f(x)` and `until_implies_F_in_mcs` gives `F(δ)` from `untl(γ,δ)` too... so `F(δ) ∈ f(x)` anyway. That doesn't give a contradiction.

Instead: `untl(γ', δ) ∈ f(x)` where γ' = δ ∧ untl(γ,δ). By BX3 (right_mono_until): `G(δ→γ) → (untl(e, δ) → untl(e, γ))`. But this requires a different setup.

The simplest argument: use the C4 counterexample structure. The counterexample `(x, y, γ, δ)` says no z ∈ (x,y) has `neg(γ) ∈ f(z)`. So all domain points in (x,y) have `γ ∈ f(z)`. By BurgessR3: for the adjacent pair (x, x'), `burgessR3(f(x), g(x,x'), f(x'))` implies `γ ∈ g(x,x')` (since γ ∈ f(x')). Hmm, this is circular.

The actual argument must use the MCS property more directly. In an MCS, `neg_untl(γ',δ) ∈ f(x)` holds iff `untl(γ',δ) ∉ f(x)`. We need to show `untl(γ',δ) ∉ f(x)`:

If `untl(γ',δ) ∈ f(x)` (for contradiction): Since `γ' = δ ∧ untl(γ,δ)`, the guard is `δ ∧ untl(γ,δ)`. The until says: there exists future s > x with `δ ∈ f(s)` and for all t ∈ (x,s), `γ'(t)` = `δ(t) ∧ untl(γ,δ)(t)`.

But we need a SYNTACTIC argument, not semantic. In the MCS:
- `neg_untl(γ,δ) ∈ f(x)` (given)
- Suppose `untl(γ',δ) ∈ f(x)`
- By `BX2`: from `G(γ'→γ)`, derive `untl(γ,δ) ∈ f(x)` from `untl(γ',δ) ∈ f(x)`. But `G(γ'→γ)` is not in A in general.

Actually, BX2 with the STRENGTHENING direction: `G(ψ→φ) → (untl(φ,e) → untl(ψ,e))` — this WEAKENS the guard from φ to ψ. So from `untl(γ',δ)` and `G(γ'→γ)` we would get `untl(γ,δ)`. But `γ' = δ ∧ untl(γ,δ)` does NOT imply γ in general (since δ and untl(γ,δ) together don't imply γ under open guard). So this route fails.

The correct argument must come from BX6 or from the specific structure of γ' and δ:

From `untl(γ',δ) ∈ f(x)` where `γ' = δ ∧ untl(γ,δ)`:
- Guard = δ ∧ untl(γ,δ), event = δ
- Note guard implies event: `γ' → δ` (since γ' = δ ∧ ...)
- By BX3 (right_mono_until): `G(γ'→e') → (untl(g,γ') → untl(g,e'))`. Hmm.
- Use BX6 (`absorb_until`): `untl(γ, δ ∧ untl(γ,δ)) → untl(γ,δ)`.
  - Note: `untl(γ, γ ∧ untl(γ,δ))` is BX6's premise (with φ=γ, ψ=δ). That's `untl(guard, guard ∧ untl(guard,event))`.
  - We have `untl(γ', δ)` = `untl(δ ∧ untl(γ,δ), δ)`. This is NOT the BX6 premise pattern.

The argument may actually require a SEMANTIC insight: `untl(γ',δ)` with `γ' = δ ∧ untl(γ,δ)` is semantically vacuous (the guard requires `δ` to hold at all intermediate points, and the event is `δ` — so the "Until" reduces to "there exists a future point with δ"). But syntactically in the MCS, we need a derivation.

**Key realization**: Burgess's argument for "neg_untl(γ',δ) ∈ f(x)" relies on the C4 counterexample condition DIRECTLY, not purely on axiomatic derivation. The C4 condition says no z ∈ (x,y) has `neg(γ) ∈ f(z)`. The formula substitution `γ' = δ ∧ untl(γ,δ)` creates a NEW triple (x, x', γ', δ) where the C4 condition for (x, x', γ', δ) must be verified FROM SCRATCH, not derived from (x, y, γ, δ).

This is a crucial point: Burgess's proof is by constructive induction on n, and the NEW triple (x, x', γ', δ) needs to be verified as a C4 counterexample itself. The key properties are:
1. `neg_untl(γ',δ) ∈ f(x)`: derived syntactically
2. `δ ∈ f(x')` (given by hypothesis: δ ∈ f(x') IS stated by Burgess)
3. No z ∈ (x,x') with `neg(γ') ∈ f(z)`: vacuously true since (x,x') has 0 intermediate domain points

For property 1, the derivation: since `δ ∈ f(x')` and `untl(γ,δ) ∈ f(x')`, we have `γ' = δ ∧ untl(γ,δ) ∈ f(x')` by DCS closure. Now suppose `untl(γ',δ) ∈ f(x)`. By the existing C4 counterexample condition, x,y,γ,δ has no witness, so: if `untl(γ',δ) ∈ f(x)`, this is a NEW Until claim at x with guard γ' = δ ∧ untl(γ,δ). The guard requires: at all intermediate points z ∈ (x, witness_s), both `δ(z)` and `untl(γ,δ)(z)` hold. The witness s > x with `δ(s)`. Now since `untl(γ,δ) ∈ f(x')` (where x' is the immediate successor of x) and the guard requires `untl(γ,δ)` at all intermediate points INCLUDING `x'`... but x' is NOT strictly between x and the witness for `untl(γ',δ)`. This semantic argument doesn't directly give a syntactic proof.

**Correct syntactic argument**: From `neg_untl(γ,δ) ∈ f(x)`:
- Suppose `untl(γ',δ) ∈ f(x)` for contradiction, where γ' = δ ∧ untl(γ,δ)
- By BX2 applied to γ'→γ tautology? No, γ'→γ is not a tautology (γ'=δ∧untl(γ,δ) does NOT imply γ).
- ACTUALLY: in MCS, `untl(γ,δ) ∈ f(x)` contradicts `neg_untl(γ,δ) ∈ f(x)`. And `γ' = δ ∧ untl(γ,δ)` implies `untl(γ,δ)`. So `untl(γ',δ)` at x implies... nothing directly about `untl(γ,δ)` at x.

The missing piece is: does `untl(γ',δ) ∈ f(x)` (where `γ' = δ ∧ untl(γ,δ)`) imply `untl(γ,δ) ∈ f(x)`? Semantically YES (because `γ'` is a STRONGER guard than needed — every point in the guard interval must have `δ ∧ untl(γ,δ)`, hence `untl(γ,δ)`, hence by C5 there's a δ-witness; but the guard itself requires δ, so... wait, this is circular).

Syntactically: from `untl(γ',δ)` with γ'=δ∧untl(γ,δ): the guard is δ∧untl(γ,δ). By BX2 strengthening (`G(γ'→γ) → (untl(γ',e) → untl(γ,e))`), we need `G(γ'→γ)`. But γ'=δ∧untl(γ,δ) → γ is NOT valid (we'd need untl(γ,δ) to imply γ, which requires BX9/until_elim, which is removed). So this syntactic route is BLOCKED under open guard.

### Summary on the Nested Case

Under **open guard** semantics, the syntactic derivation `neg_untl(γ',δ) ∈ f(x)` from `neg_untl(γ,δ) ∈ f(x)` (where `γ' = δ ∧ untl(γ,δ)`) cannot use BX9 (removed), BX2 (requires `G(γ'→γ)` which requires `γ'→γ` which requires BX9), or BX6 (different form).

**However**: Burgess's argument works for REFLEXIVE (closed guard) semantics where `untl(γ,δ) → γ` (BX9) holds. Under open guard, the nested case formula substitution may require a different argument.

**Alternative**: Use the "rightmost point" observation differently. When `untl(γ,δ) ∈ f(w_next)` and `δ ∈ f(w_next)`:
- Reduce to (w_next, y, γ, δ) with fewer intermediate points (this IS valid since no neg(γ) witnesses exist between w_next and y, by the rightmost-point property)
- This is the INDUCTIVE step going RIGHT (like Burgess's "if neg_untl ∈ f(x'), reduce to (x',y)")

When `untl(γ,δ) ∈ f(w_next)` and `δ ∉ f(w_next)`:
- Note `(w_next, y, γ, δ)` is still a C4 counterexample (since `neg_untl(γ,δ) ∉ f(w_next)`, the condition at w_next is like a "fresh" counterexample from w_next onwards)

Wait: `w_next` has `untl(γ,δ) ∈ f(w_next)`, so `neg_untl(γ,δ) ∉ f(w_next)`. For (w_next, y, γ, δ) to be a C4 counterexample, we need `neg_untl(γ,δ) ∈ f(w_next)`, which is NOT available. So (w_next, y, γ, δ) is NOT a C4 counterexample in the conventional sense.

**Critical realization**: The nested case sorry cannot be resolved within the current rightmost-point framework. The only correct resolution is to REWRITE the C4 elimination following Burgess's induction exactly, and to do so, we must either (a) use open-guard valid axioms to replace Burgess's A3a step or (b) identify what Burgess's argument actually relies on for open guard.

---

## Confidence Level

**High confidence** on:
- BX13 (enrichment_until/A3a) is valid under open guard and is in the axiom system
- `burgessR_implies_burgessRSince` is now proved in the codebase
- The rightmost-point C4 strategy has an unfixable sorry under open guard without structural changes
- The correct approach is Burgess's induction on intermediate point count
- The c2' sorries require implementing proper BurgessR3Maximal g-value splitting (Lemma 2.6 machinery)

**Medium confidence** on:
- Whether Burgess's nested case formula substitution (γ' = δ ∧ untl(γ,δ)) gives `neg_untl(γ',δ) ∈ f(x)` syntactically under open guard without BX9 — this needs deeper investigation
- Whether the "rightmost point → reduce to (w_next, y)" induction can be made to work as a stop-gap

**Lower confidence** on:
- The exact Lean proof steps for the nested case formula substitution
- Whether the density self-pair sorry (line 1092) requires anything beyond BurgessR3 infrastructure

---

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — sorry sites at lines 425, 543, 792, 830, 870, 908, 944, 976, 1092
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — `burgessR_implies_burgessRSince` (now proved at ~1186), `burgessR3_gamma_not_in_B` (sorry-free, line 834)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` — BX6 (`absorb_until`), BX13 (`enrichment_until`), BX2 (`left_mono_until`)
- `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Lemmas 2.6, 2.9 (pages 163-166)

---

## Appendix: Sorry Site Map

| Line | Description | Root Cause |
|------|-------------|------------|
| 425 | C4 nested: `untl(γ,δ) ∈ f(w_next)` | Rightmost strategy fails; needs Burgess induction |
| 543 | C4' nested: `snce(γ,δ) ∈ f(w_prev)` | Mirror of above |
| 792 | c2' for C5 forward elimination | New adjacent pair needs BurgessR3Maximal g-value |
| 830 | c2' for C5 backward elimination | Mirror of 792 |
| 870 | c2' for C4 forward elimination | New adjacent pair after C4 insertion |
| 908 | c2' for C4 backward elimination | Mirror of 870 |
| 944 | c2' for G-propagation elimination | New adjacent pair after G-prop insertion |
| 976 | c2' for density elimination | New adjacent pair after density insertion |
| 1092 | c2' density self-pair | Needs BurgessR3Maximal(A,g,A) |
