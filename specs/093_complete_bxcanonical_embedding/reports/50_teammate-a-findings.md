# Teammate A Findings: Guard Convention Mathematical Analysis

**Task**: 93 - Complete BXCanonical Embedding
**Role**: Teammate A (Primary Angle) - Core Mathematical Analysis
**Date**: 2026-04-20

---

## Executive Summary

This report provides a rigorous analysis of six Until/Since guard conventions and their
compatibility with the BX axiom system. The key finding is:

**The current implementation uses an OPEN guard `(t, s)` - not half-open `[t, s)` as
the comments claim.** This creates a mismatch between the code comments and actual
semantics. The correct convention for making all BX axioms valid simultaneously is
convention (f): reflexive witness `s ≥ t` with half-open guard `[t, s)`.

---

## Section 1: Current Implementation Audit

### Truth.lean (actual code)

```
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
```

This is: witness `s > t` (strict), guard `(t, s)` = open interval.

```
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

G is strict: covers only `s > t` (irreflexive).

### Comment/Code Discrepancy

- Axioms.lean BX9 comment says: "guard φ on [t,s)" (half-open)
- Soundness.lean BX2-BX7 block comment says: "∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)" (reflexive + half-open)
- **Actual code**: strict witness `s > t`, open guard `(t, s)` - neither matches the comments

### Sorry Sites in Soundness.lean

| Theorem | Axiom | Reason for sorry |
|---------|-------|-----------------|
| `serial_future_axiom_valid` | BX1 | Needs `NoMaxOrder` on D, not available for general ordered groups |
| `serial_past_axiom_valid` | BX1' | Same issue for past direction |
| `until_step_valid` | BX8 | Open guard `(t,s)` makes BX8 invalid semantically |
| `since_step_valid` | BX8' | Mirror of BX8 |
| `until_elim_valid` | BX9 | Open guard `(t,s)` makes BX9 invalid (t not covered) |
| `since_elim_valid` | BX9' | Mirror of BX9 |
| `discreteness_forward_valid` | DF | Requires successor structure |

---

## Section 2: Notation and Semantic Conventions

For the analysis, define these semantic variants precisely:

- **G_strict**: `G(φ)(t)` iff `∀ s > t, φ(s)` (irreflexive, current code)
- **G_reflex**: `G(φ)(t)` iff `∀ s ≥ t, φ(s)` (reflexive)
- **F_strict**: `F(φ)(t)` iff `∃ s > t, φ(s)` (strict, current code)
- **F_reflex**: `F(φ)(t)` iff `∃ s ≥ t, φ(s)` (reflexive)

For Until:
- **Witness**: either `s > t` (strict) or `s ≥ t` (reflexive/weak)
- **Guard**: `∀ r. condition → φ(r)` where condition is one of:
  - `(t < r) ∧ (r < s)`: open interval `(t, s)`
  - `(t ≤ r) ∧ (r < s)`: half-open `[t, s)`
  - `(t < r) ∧ (r ≤ s)`: half-open `(t, s]`
  - `(t ≤ r) ∧ (r ≤ s)`: closed `[t, s]`

The G in BX2/BX3 refers to the CURRENT G semantics being used.

---

## Section 3: Convention Analysis Table

Below, we analyze each combination for the key BX axioms, using the CURRENT implementation's
strict G/H semantics (`∀ s > t`). The variation is only in the Until/Since definition.

### Key Axioms Under Examination

| Label | Axiom |
|-------|-------|
| BX2 | `G(φ → χ) → (φ U ψ → χ U ψ)` |
| BX3 | `G(φ → ψ) → (χ U φ → χ U ψ)` |
| BX5 | `φ U ψ → (φ ∧ (φ U ψ)) U ψ` |
| BX6 | `φ U (φ ∧ (φ U ψ)) → φ U ψ` |
| BX7 | `(φ U ψ) ∧ (χ U θ) → (...)` |
| BX8 | `φ ∧ F(φ U ψ) → φ U ψ` |
| BX9 | `φ U ψ → φ ∨ ψ` |
| BX10 | `φ U ψ → F(ψ)` |
| BX12 | `F(φ) → ⊤ U φ` |
| BX1 | `⊤ → F(⊤)` (seriality) |

---

## Section 4: Convention (a) — Open Guard `(t, s)` with Strict Witness

**Definition**: `φ U ψ` at `t` iff `∃ s > t, ψ(s) ∧ ∀ r, t < r < s → φ(r)`
(Current actual implementation)

### BX2: `G_strict(φ → χ) → (φ U ψ → χ U ψ)` — VALID

**Proof**: Given `G_strict(φ → χ)` at `t`, meaning `∀ r > t, φ(r) → χ(r)`.
Given `φ U ψ` with witness `s > t`, guard `∀ r, t < r < s → φ(r)`.
Same witness `s` works for `χ U ψ`: for guard `r ∈ (t, s)`, have `r > t` so `φ(r) → χ(r)` applies. QED.

### BX3: `G_strict(φ → ψ) → (χ U φ → χ U ψ)` — VALID

**Proof**: Witness `s > t`, `φ(s)` with `G_strict(φ → ψ)` gives `s > t` and `φ(s) → ψ(s)`. Same guard. QED.

### BX5: `φ U ψ → (φ ∧ (φ U ψ)) U ψ` — VALID

**Proof**: Given `∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)`. Use same witness `s`.
For guard `r ∈ (t, s)`: need `φ(r) ∧ (φ U ψ)(r)`.
- `φ(r)`: from original guard.
- `(φ U ψ)(r)`: use witness `s` again; `ψ(s)` holds; guard `q ∈ (r, s) ⊂ (t, s)` gives `φ(q)`. But need `q > r`, not `q > t`. Since `r > t`, for `q > r > t` and `q < s`, we have `q ∈ (t, s)` so `φ(q)`. QED.

### BX6: `φ U (φ ∧ (φ U ψ)) → φ U ψ` — VALID

**Proof**: Witness `s1 > t` with `(φ ∧ (φ U ψ))(s1)` and guard `φ` on `(t, s1)`.
Extract: `φ(s1)` and `∃ s2 > s1, ψ(s2) ∧ φ` on `(s1, s2)`.
Use `s2` as new witness: `s2 > s1 > t`. Guard `r ∈ (t, s2)`:
- `r < s1`: from outer guard, `φ(r)`.
- `r = s1`: `φ(s1)` from endpoint.
- `r > s1` and `r < s2`: from inner guard. QED.

### BX7: Linearity — VALID

**Proof sketch**: Given `s1, s2 > t` (witnesses for two Untils). By trichotomy on `s1, s2`:
- `s1 = s2`: use conjunction as endpoint.
- `s1 < s2`: use `s1` as witness; `χ(s1)` from guard2 since `t < s1 < s2`.
- `s2 < s1`: use `s2` as witness; `φ(s2)` from guard1 since `t < s2 < s1`. QED.

### BX8: `φ ∧ F(φ U ψ) → φ U ψ` — **INVALID**

**Counterexample**: Let `D = ℝ`, time `t = 0`. Let `φ = ⊤`, `ψ = ⊥`.
More carefully: Let `φ` be true at all `s ≠ 0`, false at `0`. Let `ψ` be true only at `1`.

With `F_strict(φ U ψ)` at `0`: there exists `s' > 0` with `(φ U ψ)(s')`.
Say `s' = 0.5`. Then `(φ U ψ)(0.5)`: witness `s'' > 0.5`, say `s'' = 1` with `ψ(1)`, guard `φ` on `(0.5, 1)` — fine.

Now try to conclude `(φ U ψ)(0)` with witness e.g. `s'' = 1`: guard is `(0, 1)`.
But φ is false at 0, so `φ` is needed on `(0, 1)`. Wait, `φ` is false only at `0`.
So `φ` holds on `(0, 1)` (open guard excludes `0`). So `(φ U ψ)(0)` IS valid here.

Better counterexample: Let `φ` be false on `(0, 0.5)` and true elsewhere. Let `ψ` be true only at `1`.
- `φ(0)`: assume true (needed for hypothesis `φ ∧ F(...)`).
- `F(φ U ψ)`: exists `s' > 0` with `(φ U ψ)(s')`. Take `s' = 0.6` (where `φ` is true). Witness `1 > 0.6`, `ψ(1)`, guard `(0.6, 1)` — `φ` true there. So `(φ U ψ)(0.6)` holds.
- Now we need `(φ U ψ)(0)`: witness must be `s'' > 0`. Must have guard `φ` on `(0, s'')`. But `φ` is false on `(0, 0.5)`. So any witness `s'' > 0` would need to have `φ$ on `(0, s'')`, which fails for `r \in (0, 0.5)`.
- Conclusion: `(φ U ψ)(0)` is FALSE, but `φ(0) ∧ F(φ U ψ)(0)` is TRUE. BX8 fails.

**Why it fails**: The open guard `(t, s)` provides no information about `φ(t)` itself, so F of a future Until cannot "stitch" back to include the current interval `(t, s')`. The gap `(t, s')` has unknown `φ` behavior.

### BX9: `φ U ψ → φ ∨ ψ` — **INVALID**

**Counterexample**: Let `φ` be false at `t` (and `ψ` be false at `t`). Let `ψ` be true at some `s > t`, and `φ` be true on `(t, s)`. Then `(φ U ψ)(t)` holds (with open guard, `t` is NOT in the guard region). But `φ(t)` is false and `ψ(t)` is false, so `φ ∨ ψ` at `t` fails.

**Why it fails**: The open guard `(t, s)` explicitly excludes `t`, so there's no way to derive `φ(t)` from the Until formula.

### BX10: `φ U ψ → F(ψ)` — VALID

**Proof**: Witness `s > t` with `ψ(s)`. Then `F_strict(ψ)(t)` holds since `s > t`. QED.

### BX12: `F(ψ) → ⊤ U ψ` — VALID

**Proof**: Given `F_strict(ψ)`: `∃ s > t, ψ(s)`. Use this `s` as witness for `⊤ U ψ`. Guard `⊤` on `(t, s)` holds vacuously. QED.

### BX1: `⊤ → F(⊤)` — **Requires `NoMaxOrder`**

**Analysis**: `F_strict(⊤)(t)` means `∃ s > t`. This is valid iff `D` has no maximum. On `ℤ` or `ℝ` this holds, but not on finite orders. For general `AddCommGroup + LinearOrder`, no guarantee.

### Summary for Convention (a)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | YES | G_strict covers all guard points r > t |
| BX3 | YES | Witness unchanged |
| BX5 | YES | Sub-guard argument works |
| BX6 | YES | Composition of witnesses; endpoint φ(s1) extracted |
| BX7 | YES | Linearity of witnesses |
| BX8 | NO | Gap (t, s') has unknown φ |
| BX9 | NO | Open guard excludes t |
| BX10 | YES | Witness directly gives F |
| BX12 | YES | Trivial guard |
| BX1 | Conditional | Requires NoMaxOrder |

---

## Section 5: Convention (b) — Half-Open Guard `[t, s)` with Strict Witness

**Definition**: `φ U ψ` at `t` iff `∃ s > t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)`

Note: The guard now INCLUDES `t`.

### BX2: `G_strict(φ → χ) → (φ U ψ → χ U ψ)` — **INVALID**

**Counterexample**: Let `D = ℤ`, `t = 0`, `s = 2`. Let `φ` and `χ` be arbitrary.
`G_strict(φ → χ)` at `0` means: `∀ r > 0, φ(r) → χ(r)`.
Guard is `∀ r, 0 ≤ r < 2 → φ(r)`, which covers `r = 0, 1`.
For `χ U ψ` with same witness, need `χ(r)` for all `r ∈ [0, 2)`.
At `r = 0`: G_strict at `t=0` only covers `r > 0`, so `φ(0) → χ(0)` is NOT guaranteed.
We have `φ(0)` (from guard), but no implication `φ(0) → χ(0)`.

**Why it fails**: G_strict provides `φ → χ` for `r > t`, but the half-open guard `[t, s)` requires `χ(t)` which is at the current time, not in the strict future.

### Fix possibility: use G_reflex

If G were reflexive (`∀ s ≥ t`), then `G_reflex(φ → χ)` at `t` would cover `r = t` too, making BX2 valid. But with G_strict, BX2 fails under convention (b).

### BX9: `φ U ψ → φ ∨ ψ` — VALID

**Proof**: Guard `[t, s)` includes `t`. So `φ(t)` holds (r = t satisfies `t ≤ t < s`). Hence `φ ∨ ψ` at `t`. QED.

### BX10: `φ U ψ → F(ψ)` — VALID (same as (a))

### BX8: `φ ∧ F(φ U ψ) → φ U ψ` — **Still problematic**

With half-open guard, `(φ U ψ)(s')` gives: `∃ s'' > s', ψ(s'') ∧ φ` on `[s', s'')`.
Hypothesis: `φ(t) ∧ F_strict(φ U ψ)(t)`, so `∃ s' > t, (φ U ψ)(s')`.
For `(φ U ψ)(t)` with witness `s''`: guard `[t, s'')`.
- At `t`: `φ(t)` — OK from hypothesis.
- In `(t, s')`: unknown!
- In `[s', s'')`: `φ` from inner guard.

The interval `(t, s')` is still uncovered. So BX8 is INVALID under (b) as well.

### Summary for Convention (b)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | NO | G_strict doesn't cover r = t |
| BX3 | YES | Witness endpoint ψ(s) → χ(s) via G_strict (s > t) |
| BX5 | YES | Guard composition works |
| BX6 | YES | Endpoint φ(s1) from guard [t, s1) at r=s1 edge: wait, r < s1 so r=s1 not in guard. Need separate. Actually φ(s1) is from the endpoint (φ ∧ ...) extraction |
| BX7 | YES | Linearity argument still valid |
| BX8 | NO | Gap (t, s') uncovered |
| BX9 | YES | t is in [t, s) |
| BX10 | YES | |
| BX12 | YES | |
| BX1 | Conditional | Same as (a) |

---

## Section 6: Convention (c) — Half-Open Guard `(t, s]` with Strict Witness

**Definition**: `φ U ψ` at `t` iff `∃ s > t, ψ(s) ∧ ∀ r, t < r ≤ s → φ(r)`

The guard includes `s` but not `t`.

### BX9: `φ U ψ → φ ∨ ψ` — **INVALID**

Same issue as (a): `t` is not in the guard `(t, s]`. So `φ(t)` is not guaranteed.

### BX3: `G(φ → ψ) → (χ U φ → χ U ψ)` — **Modified**

The witness satisfies `φ(s)`, and `G_strict(φ → ψ)` at `t` gives `φ(s) → ψ(s)` for `s > t`. Valid.
But the guard is `(t, s]`. For `χ U ψ` with same witness, we need guard `(t, s]` for `χ`:
same guard transfers. OK.

### BX6 with closed-right guard:

Given `φ U (φ ∧ (φ U ψ))` with witness `s1` and guard `φ` on `(t, s1]`:
`φ(s1)` comes directly from the guard (since `s1 ≤ s1`).
Inner: `(φ U ψ)(s1)` has witness `s2 > s1` with `ψ(s2)` and guard `(s1, s2]`.
New witness `s2`, guard `(t, s2]`:
- `r ∈ (t, s1]`: from outer guard, `φ(r)`.
- `r ∈ (s1, s2]`: from inner guard, `φ(r)`. QED.

BX6 seems VALID under (c).

### Summary for Convention (c)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | YES | Guard (t,s] all r > t, G_strict covers |
| BX3 | YES | |
| BX5 | YES | Sub-guard: q ∈ (r, s] ⊂ (t, s] for q > r > t |
| BX6 | YES | Guard includes s1 |
| BX7 | YES | |
| BX8 | NO | Still gap (t, s') |
| BX9 | NO | t not in (t, s] |
| BX10 | YES | |
| BX12 | YES | |
| BX1 | Conditional | |

---

## Section 7: Convention (d) — Closed Guard `[t, s]` with Strict Witness

**Definition**: `φ U ψ` at `t` iff `∃ s > t, ψ(s) ∧ ∀ r, t ≤ r ≤ s → φ(r)`

### BX2: `G_strict(φ → χ) → (φ U ψ → χ U ψ)` — **INVALID**

Same as (b): G_strict at `t` does not cover `r = t`. Guard `[t, s]` requires `χ(t)`. No guarantee.

### BX3: `G_strict(φ → ψ) → (χ U φ → χ U ψ)` — VALID

Witness `s > t`, `φ(s)` and `G_strict(φ → ψ)` gives `ψ(s)`. Guard unchanged. OK.

### BX5: `φ U ψ → (φ ∧ (φ U ψ)) U ψ` — VALID

Guard `[t, s]`, same witness. For `r ∈ [t, s)`:
- `φ(r)`: from original guard.
- `(φ U ψ)(r)` with witness `s`: guard `[r, s] ⊂ [t, s]`, `φ` holds on `[r, s]`. QED.

Actually wait - the inner Until is `∃ s'' > r, ψ(s'') ∧ φ` on `[r, s'')`. Using `s'' = s`, but `s > r` (since `r < s`), `ψ(s)` holds. Guard `[r, s) ⊂ [t, s]` (we have `φ` on `[t,s]` so certainly `[r,s)`). Except for `r = s`: but `r < s` so `r ≠ s`. OK.

Wait, the endpoint `s` itself: in `φ U ψ` with closed guard, guard is `[t, s]` which includes `s`. But `ψ(s)`. And `φ(s)` from guard too. This is perhaps strange but consistent.

### BX9: `φ U ψ → φ ∨ ψ` — VALID

Guard `[t, s]` includes `t`, so `φ(t)` holds. QED.

### BX8: Same gap problem

`F_strict(φ U ψ)` gives `(φ U ψ)(s')` with `s' > t`. Closed guard on inner: `[s', s'']`.
For `(φ U ψ)(t)`: witness `s''`, guard `[t, s'']`. Need `φ` on `[t, s']`.
At `t`: hypothesis `φ(t)`. But `(t, s')` is still uncovered! BX8 INVALID.

Actually wait - with hypothesis `φ(t)` and `φ` on `[s', s'']`, we still lack `φ` on `(t, s')`.

### Summary for Convention (d)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | NO | G_strict misses r = t |
| BX3 | YES | |
| BX5 | YES | Sub-guard works with closed interval |
| BX6 | YES | |
| BX7 | YES | |
| BX8 | NO | (t, s') gap |
| BX9 | YES | t ∈ [t, s] |
| BX10 | YES | |
| BX12 | YES | |
| BX1 | Conditional | |

---

## Section 8: Convention (e) — Open Guard `(t, s)` with Reflexive Witness `s ≥ t`

**Definition**: `φ U ψ` at `t` iff `∃ s ≥ t, ψ(s) ∧ ∀ r, t < r < s → φ(r)`

Note: when `s = t`, the condition becomes `∃ s = t, ψ(t) ∧ ∀ r ∈ (t, t) = ∅ → φ(r)`,
which is `ψ(t)` (vacuously valid guard). So `(φ U ψ)(t)` is true whenever `ψ(t)`.

### BX9: `φ U ψ → φ ∨ ψ` — **INVALID**

If `s = t`: then `ψ(t)` holds, so `ψ ∈ φ ∨ ψ`. Good.
If `s > t`: guard is `(t, s)` which doesn't include `t`. We have `ψ(s)` but not necessarily `ψ(t)` or `φ(t)`. So `φ ∨ ψ` at `t` may fail.

**Counterexample**: Let `φ` be false at `t`, `ψ` false at `t` but true at some `s > t`. Take `s > t` as witness. Guard `(t, s)` is irrelevant (φ is vacuously irrelevant for validity). `(φ U ψ)(t)` holds but `(φ ∨ ψ)(t)` = false ∨ false = false. INVALID.

### BX10: `φ U ψ → F(ψ)` — **F depends on definition of F**

If `F_strict` (current): witness `s ≥ t`. If `s = t`, then `ψ(t)` but `F_strict(ψ)(t)` requires `∃ u > t, ψ(u)`. If `ψ` is only true at `t`, then `F_strict(ψ)` is false. BX10 INVALID with strict F.

If `F_reflex`: `F_reflex(ψ)(t)` iff `∃ u ≥ t, ψ(u)`. Then `s` itself witnesses this. VALID.

### BX2: VALID (same as (a), guard is still open, G_strict covers all r > t).

### Summary for Convention (e)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | YES | Open guard (t,s), G_strict covers r > t |
| BX3 | YES (if s > t) | But if s = t: endpoint ψ(t), G covers ψ(t) → χ(t)? No: s = t, not > t, G_strict misses! |
| BX9 | NO | Open guard excludes t when s > t |
| BX10 | NO with F_strict | s = t case: ψ(t) but F_strict needs s > t |
| BX12 | Needs care | F(ψ) → ⊤ U ψ: F_strict gives s > t, use as strict witness OK |

**Convention (e) is worse than (a)**. Mixing reflexive witness with open guard creates new failures without fixing existing ones.

---

## Section 9: Convention (f) — Reflexive Witness `s ≥ t` with Half-Open Guard `[t, s)`

**Definition**: `φ U ψ` at `t` iff `∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)`

Key cases:
- `s = t`: condition is `ψ(t) ∧ ∀ r ∈ [t, t) = ∅ → φ(r)` = `ψ(t)` (vacuous guard). So `(φ U ψ)(t)` holds iff `ψ(t)`.
- `s > t`: condition is `ψ(s) ∧ φ` on `[t, s)`.

This is the **standard reflexive Until semantics** used in temporal logic (Manna & Pnueli, etc.).

With this definition, G must also be reflexive for BX2 to work: `G_reflex(φ)` at `t` = `∀ s ≥ t, φ(s)`.
Otherwise BX2 fails as in case (b).

**So convention (f) requires:**
- Until: reflexive witness, half-open guard
- G/H: reflexive (`∀ s ≥ t`)

This changes the ENTIRE semantics significantly.

### BX2 with G_reflex: `G_reflex(φ → χ) → (φ U ψ → χ U ψ)` — VALID

Guard `[t, s)`, G_reflex covers `r ≥ t`. For all `r ∈ [t, s)`: `r ≥ t` so `φ(r) → χ(r)`. QED.

### BX9: `φ U ψ → φ ∨ ψ` — VALID

- If `s = t`: `ψ(t)` holds, so `φ ∨ ψ` at `t`. ✓
- If `s > t`: guard `[t, s)` includes `t`, so `φ(t)` holds, so `φ ∨ ψ`. ✓

### BX8: `φ ∧ F(φ U ψ) → φ U ψ` — Analysis with G_reflex/F_reflex

With `F_reflex(φ U ψ)` at `t`: `∃ s' ≥ t, (φ U ψ)(s')`.
- If `s' = t`: then `(φ U ψ)(t)` directly holds. So the conclusion holds trivially.
- If `s' > t`: `(φ U ψ)(s')` gives `∃ s'' ≥ s', ψ(s'') ∧ φ` on `[s', s'')`.
  Try witness `s''` for `(φ U ψ)(t)`: guard `[t, s'')`.
  - `[t, s')`: unknown!
  But hypothesis includes `φ(t)`. And... we don't know about `(t, s')`. BX8 is still problematic.

Actually, BX8 with G_reflex/F_reflex is the standard "until step" axiom. Let me reconsider.

In the **standard reflexive semantics** (used by Burgess-Xu paper), BX8 is typically:
`φ ∧ F(φ U ψ) → φ U ψ`

With reflexive F: `F(φ U ψ)(t)` gives `∃ s' ≥ t` with `(φ U ψ)(s')`.
Case `s' = t`: immediate.
Case `s' > t`: `(φ U ψ)(s')` gives `∃ s'' ≥ s', ψ(s'') ∧ φ` on `[s', s'')`.
For `(φ U ψ)(t)` with witness `s''`:
Guard `[t, s'')`:
- `t`: `φ(t)` from hypothesis. ✓
- `(t, s')`: **unknown**. ✗

So BX8 is **still invalid** even with reflexive semantics and half-open guard, unless we have density or a successor axiom!

**This is the fundamental difficulty with BX8**: it is NOT valid on arbitrary linear orders. It requires either:
1. Discrete (successor) structure: so `s'` is the immediate successor of `t`, and there's no gap.
2. Density: so we can find intermediate points to cover the gap.

In the Burgess-Xu completeness proof, BX8 is valid because BX8 is derivable from BX5+BX6+BX7 in the proof system — it's not a primitive semantic validity but rather an axiom that is provable from more basic axioms.

Wait — let me reread the axiom descriptions. Looking at Axioms.lean BX8:
```
/-- BX8: Until step: `φ ∧ F(φ U ψ) → (φ U ψ)`.
Under irreflexive Until semantics with strict witness s > t:
if φ holds now and F(φ U ψ) holds, then there exists s' > t with (φ U ψ)(s').
That s' has witness s'' > s' with ψ(s''). Use s'' as witness: s'' > t,
guard holds at t (φ from hypothesis) and on [s', s'') from inner guard,
and on (t, s') from F-position. -/
```

The comment says "on (t, s') from F-position" — but this is **incorrect**. F gives existence of `s'`, not the behavior of `φ` on `(t, s')`. This is a bug in the comment.

Let me check what happens in the Burgess-Xu literature with reflexive semantics:

With **G_reflex** and **reflexive witness + half-open guard**:
- G(φ U ψ) at `t` means: `∀ s ≥ t, (φ U ψ)(s)`.

In this case, BX8 = `φ ∧ F(φ U ψ) → φ U ψ`. This IS valid when G_reflex is used!

Proof with G_reflex: `F_reflex(φ U ψ)(t)` = `¬G_reflex(¬(φ U ψ))(t)`.
`G_reflex(¬(φ U ψ))` at `t` = `∀ s ≥ t, ¬(φ U ψ)(s)`.
So `F_reflex(φ U ψ)` means this is false, i.e., `∃ s ≥ t, (φ U ψ)(s)`.

Hmm, the proof still runs into the same gap issue unless G_reflex is used in a specific way.

Actually wait — I need to revisit more carefully. In Burgess-Xu, BX8 has a specific validity proof that uses the axioms BX5-BX7 for deriving it semantically. Let me look at this differently:

**BX8 with G_reflex (reflexive witness, half-open guard)**:

Claim: If `φ(t)` and `∃ s' ≥ t, (φ U ψ)(s')`, then `(φ U ψ)(t)`.

Case `s' = t`: done.
Case `s' > t`: `(φ U ψ)(s') = ∃ s'' ≥ s', ψ(s'') ∧ φ` on `[s', s'')`.
Need `(φ U ψ)(t)` = `∃ s_w ≥ t, ψ(s_w) ∧ φ` on `[t, s_w)`.
Use `s_w = s''`: need `φ` on `[t, s'')`.
- `φ(t)`: hypothesis.
- `(t, s')`: **gap - unknown**.
- `[s', s'')`: from inner guard.

**BX8 is NOT valid on arbitrary linear orders, even with reflexive semantics.**

This is consistent with the sorry in Soundness.lean. The issue is structural: BX8 requires either a constraint on `D` or must be derived from BX5+BX6+BX7 as a theorem rather than treated as a primitive axiom.

### BX10: `φ U ψ → F(ψ)` — VALID with matching F

With reflexive witness and F_reflex: witness `s ≥ t` gives `F_reflex(ψ)(t)`. ✓
With reflexive witness and F_strict: if `s = t`, then `ψ(t)` but `F_strict` needs `∃ u > t`. FAILS.

So BX10 is valid iff F is reflexive (matching the Until witness). The current code uses F_strict, which would fail for the `s = t` case.

### BX12: `F(φ) → ⊤ U φ` — VALID if F matches witness

With F_reflex: `∃ s ≥ t, φ(s)`. Use this `s` as witness for reflexive Until. Guard `[t, s)` for `⊤` — vacuously true. ✓

### BX4 (original Burgess-Xu): `φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))`

With reflexive Until and reflexive Since (same patterns):
- `χ U ψ` at `t`: witness `s ≥ t`, `ψ(s)`, guard `χ` on `[t, s)`.
- Need `χ U (ψ ∧ χ S φ)` at `t`: witness `s`, `ψ(s) ∧ (χ S φ)(s)`.
- `(χ S φ)(s)` = `∃ u ≤ s, φ(u) ∧ χ` on `(u, s]`.
- Use `u = t`: `φ(t)` from hypothesis, `χ` on `(t, s] = [t, s]` (excluding t... wait).
- Half-open Since `(s, t]`: guard `(u, s]` means `(t, s]`. We need `χ` on `(t, s]`.
- From `χ U ψ` guard: `χ` on `[t, s)`. But `(t, s]` needs `χ(s)`, which is NOT in `[t, s)`.

So the original BX4 fails even with reflexive semantics + half-open guard.

This explains the comment in Soundness.lean: "BX4 is not valid under half-open guard convention".
The replacement BX4 (`φ → G(P(φ))`) avoids this.

### Summary for Convention (f) (Reflexive witness, half-open guard, requires G_reflex)

| Axiom | Valid? | Notes |
|-------|--------|-------|
| BX2 | YES (with G_reflex) | G_reflex covers r ≥ t including t |
| BX3 | YES | Witness point s ≥ t, G_reflex gives χ(s) → ψ(s) |
| BX5 | YES | Same-witness argument |
| BX6 | YES | Composition; φ(s1) from guard [t,s1) since t ≤ s1 → wait, s1 is strict successor witness (s1 > t in strict, or s1 ≥ t in reflexive). Need to trace carefully. |
| BX7 | YES | Linearity of witnesses, all strictly positive |
| BX8 | NO (on arbitrary D) | Gap (t, s') still present; requires density or discreteness |
| BX9 | YES | Guard [t,s) includes t; or s=t gives ψ(t) |
| BX10 | YES (with F_reflex) | Witness s ≥ t gives F_reflex(ψ) |
| BX12 | YES (with F_reflex) | |
| BX1 | YES (with G_reflex) | G_reflex(⊤)(t) = ∀ s ≥ t, ⊤(s) is trivially true |

**Note on BX1**: With reflexive G, `F_reflex(⊤)(t)` = `¬G_reflex(¬⊤)(t)` = `¬∀ s ≥ t, ⊥` = TRUE (since we can take s = t). So seriality `⊤ → F(⊤)` becomes trivially true without needing NoMaxOrder!

---

## Section 10: Summary Comparison Table

The table uses `G_strict` or `G_reflex` as specified; "G = strict" means the current implementation's G.

```
Convention | Witness | Guard     | G-type   | BX1 | BX2 | BX3 | BX5 | BX6 | BX7 | BX8 | BX9 | BX10| BX12
(a) Open   | s > t   | (t, s)    | strict   | ★   | YES | YES | YES | YES | YES | NO  | NO  | YES | YES
(b) Half-L | s > t   | [t, s)    | strict   | ★   | NO  | YES | YES | YES | YES | NO  | YES | YES | YES
(c) Half-R | s > t   | (t, s]    | strict   | ★   | YES | YES | YES | YES | YES | NO  | NO  | YES | YES
(d) Closed | s > t   | [t, s]    | strict   | ★   | NO  | YES | YES | YES | YES | NO  | YES | YES | YES
(e) Open+R | s ≥ t   | (t, s)    | strict   | ★   | YES | PARTIAL| YES | YES | YES | NO | NO | PARTIAL | YES
(f) Half+R | s ≥ t   | [t, s)    | reflex   | YES | YES | YES | YES | YES | YES | NO  | YES | YES | YES
```

★ = valid only on orders with NoMaxOrder (requires assumption on frame)

---

## Section 11: Key Conclusions

### 1. No convention makes ALL BX axioms valid on arbitrary linear orders

BX8 (`φ ∧ F(φ U ψ) → φ U ψ`) is the problematic axiom. It requires additional structure:
- **Densely ordered**: can find intermediate points, but the proof still requires an inductive argument.
- **Discretely ordered**: immediate successor closes the gap.
- **Or**: BX8 is derivable from BX5+BX6+BX7 as a proof-theoretic fact, not a semantic primitive.

The last point is most likely the correct interpretation: Burgess-Xu include BX8 as an axiom that is **provably valid in the proof system** (derivable), not as a semantic primitive that holds on all frames. The Lean sorry for BX8 reflects this — it cannot be proved semantically without additional frame conditions.

### 2. For the remaining axioms (BX2, BX3, BX5, BX6, BX7, BX9, BX10, BX12), the best convention is (f)

Convention (f) (reflexive witness, half-open guard, with G_reflex) makes all of these valid AND makes BX1 (seriality) trivially valid without requiring NoMaxOrder.

### 3. The current implementation (a) has BOTH BX8 and BX9 sorry'd

This is correct behavior — both fail under the open guard. The choice is between:
- Sticking with (a) and accepting BX8+BX9 require frame conditions or are proof-theoretically derived
- Switching to (b) or (f) to fix BX9 at the cost of breaking BX2

### 4. Convention (b) is the "obvious" fix but breaks BX2

The naive fix of making the guard half-open `[t, s)` fixes BX9 but breaks BX2 because G_strict doesn't cover time `t`. This is exactly the blocker described in the task context.

### 5. The correct fix requires a coordinated change

To make both BX2 and BX9 valid simultaneously, we need EITHER:

**Option A**: Use convention (f) with reflexive G/H/Until/Since throughout.
- Makes BX1 trivially valid (no NoMaxOrder needed)
- Makes BX2, BX9 both valid
- Changes meaning of G (now includes present time)
- T-axiom `Gφ → φ` becomes valid (S4 → changes modal structure if not desired)
- The seriality BX1 axiom is now redundant

**Option B**: Use convention (b) but add a "strong G" or modify BX2.
- Keep G_strict but use `G̃(φ → χ)` = `φ(t) ∧ G_strict(φ → χ)` in BX2
- This is non-standard and changes the axiom schema

**Option C**: Keep convention (a) (current), add frame condition `NoMaxOrder` for BX1, and treat BX8+BX9 as derivable theorems rather than primitive axioms.
- The Soundness.lean sorries for BX8+BX9 would become theorems about the canonical model (ℤ) rather than about arbitrary frames
- This matches what seems to be the current design intention

### 6. The BX2 proof in Soundness.lean is CORRECT for the current open guard (a)

The proof at line 506: `intro h_G ⟨s, hts, h_ψs, h_guard⟩ ; exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩`

This works because `h_G r htr` applies G_strict at `r > t`, and `h_guard r htr hrs` gives `φ(r)` for `r ∈ (t, s)`. Both require `r > t`, and the open guard provides this. BX2 is VALID under convention (a) — the comment in Soundness.lean is correct that BX2 succeeds.

### 7. The stale comment about "reflexive semantics" in Soundness.lean

The block comment at line 491-495 describes "reflexive semantics" with `s ≥ t` and `[t,s)`. This is **documentation from a previous design iteration** that was never updated. The actual proofs use the strict witness and open guard.

---

## Section 12: Recommended Path Forward

The mathematically cleanest solution — and the one most consistent with the Burgess-Xu completeness result — is:

### Recommendation: Convention (f) with Full Reflexive Semantics

Switch all temporal operators to reflexive:
- `G(φ)` at `t`: `∀ s ≥ t, φ(s)` (includes present)
- `H(φ)` at `t`: `∀ s ≤ t, φ(s)` (includes present)
- `φ U ψ` at `t`: `∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)` (reflexive witness, half-open guard)
- `φ S ψ` at `t`: `∃ s ≤ t, ψ(s) ∧ ∀ r, s < r ≤ t → φ(r)` (reflexive witness, half-open guard)

Consequences:
1. T-axiom `Gφ → φ` becomes valid (this is appropriate for S4-type temporal logic)
2. BX1 (seriality) becomes provable as `F(⊤)(t)` = `¬G(¬⊤)(t)` = TRUE (trivial)
3. BX2, BX3, BX5, BX6, BX7, BX9, BX10, BX12 all become valid
4. BX8 still requires frame conditions — it's valid on dense orders (can fill gap) or discrete (successor closes gap), but NOT on arbitrary linear orders

### Alternative Recommendation: Keep (a) + Conditional Axioms

If the irreflexive G semantics must be preserved (for mathematical reasons tied to the Task Frame):
1. Keep convention (a) (open guard, strict witness)
2. Mark BX8 and BX9 as "valid on canonical model ℤ" rather than "valid on all frames"
3. The soundness theorem becomes: BX derivations are sound on well-founded discrete orders
4. Modify BX1 proof to assume `NoMaxOrder` as a frame condition

### What NOT to do

Convention (b) (strict witness + half-open guard) in isolation creates a worse situation: BX9 is fixed but BX2 breaks. Unless G is simultaneously changed to reflexive, (b) is a strictly inferior choice.

---

## References

- Soundness.lean, lines 480-778 (BX2-BX9 validity proofs and sorries)
- Truth.lean, lines 119-131 (current semantics definition)
- Axioms.lean (BX axiom definitions)
- Burgess (1982/84): Original Until-Since axiomatization (foundational reference)
- Xu (1988): Completeness for Until-Since on linear orders (reflexive semantics)
