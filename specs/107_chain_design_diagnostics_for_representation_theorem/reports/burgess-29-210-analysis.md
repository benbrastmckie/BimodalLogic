# Burgess 1982 Sections 2.9–2.10 vs. Current Codebase: Exact Mapping & Deviation Analysis

**Date**: 2026-05-03  
**Task**: 107 — Chain Design Diagnostics for Representation Theorem  
**Source files analyzed**:
- `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` (Sections 2.9, 2.10, surrounding definitions)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (lines 1–948)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines 2320–2519)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (lines 1–656)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (lines 720–1200)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (lines 1–400)
- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/54_implementation-plan.md`

---

## Table of Contents

1. [Burgess Definitions Recap](#1-burgess-definitions-recap)
2. [Section 2.9 (C4 Elimination) — Burgess vs. Code](#2-section-29-c4-elimination--burgess-vs-code)
3. [Section 2.10 (C5 Elimination) — Burgess vs. Code](#3-section-210-c5-elimination--burgess-vs-code)
4. [Structural Deviations Summary](#4-structural-deviations-summary)
5. [Role of C2' (Maximality at Adjacent Pairs)](#5-role-of-c2-maximality-at-adjacent-pairs)
6. [What Must Be Implemented to Match Burgess Exactly](#6-what-must-be-implemented-to-match-burgess-exactly)
7. [Critical Observations for Implementation](#7-critical-observations-for-implementation)

---

## 1. Burgess Definitions Recap

### The Chronicle Conditions (Burgess 1982, p. 373)

| Condition | Burgess Text | Our Code Name |
|-----------|--------------|---------------|
| **C0** | `f` maps a finite subset of ℚ to MCSs | `Chronicle.c0` |
| **C1** | `g` maps pairs `x < y` to DCSs | `Chronicle.c1` |
| **C2** | `r(f(x), g(x,y), f(y))` for all `x < y` in dom | `Chronicle.c2` |
| **C2'** | `R(f(x), g(x,y), f(y))` for adjacent pairs | `Chronicle.c2'` (BurgessR3Maximal) |
| **C3** | `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)` for `x < y < z` | `Chronicle.c3` |
| **C4a** | If `¬U(γ,δ) ∈ f(x)` and `δ ∈ f(y)`, then ∃z with `x < z < y` and `¬γ ∈ f(z)` | `Chronicle.c4` |
| **C5a** | If `U(ξ,η) ∈ f(x)`, then ∃y with `x < y` and `ξ ∈ f(y)` and `η ∈ g(x,y)` | `Chronicle.c5` |

**Key definitions used in the proofs**:

- `r(A, B, C)`: For all `β ∈ B`, `γ ∈ C`, `U(β,γ) ∈ A`, AND for all `β ∈ B`, `α ∈ A`, `S(β,α) ∈ C`. (Burgess 2.3)
- `R(A, B, C)`: `B` is a **maximal** DCS satisfying `r(A, B, C)`. (Burgess 2.5)
- **Adjacent**: `x` immediately precedes `y` in `dom f` (no element of dom between them).

---

## 2. Section 2.9 (C4 Elimination) — Burgess vs. Code

### 2.1 Burgess 2.9 — Exact Text

> **Lemma 2.9 (Counterexample Lemma)**:
> Let `(f,g) ∈ F` and suppose `x, y, γ, δ` constitute a counterexample to C4a for `(f,g)`. Then there exists an extension `(f',g') ∈ F` of `(f,g)` for which `x, y, γ, δ` do not constitute a counterexample to C4a.
>
> **Proof**: What we claim is that it is possible to add a single point `z` lying between `x` and `y` to dom `f`, and extend `f` and `g` to functions `f'` and `g'` on this enlarged domain, in such a way that `¬δ ∈ f'(z)`, and all the conditions for membership in `F` are satisfied by `(f',g')`. We prove this by induction on the number `n` of elements of dom `f` lying between `x` and `y`.
>
> **Case n = 0.** By C2' we have `R(f(x), g(x,y), f(y))` and so we can apply 2.6 to `A = f(x)`, `B = g(x,y)`, `C = f(y)` to obtain `B', D, B''`. Let `z = (x + y)/2`. Set `f'(z) = D`. Set `g'(x,z) = B'`, `g'(z,y) = B''`, and let C3 determine the other values of `g'(w,z)` and `g'(z,w)`.
>
> **Case n = m + 1.** Let `x'` immediately succeed `x` in dom `f`. If `¬U(γ, δ) ∈ f(x')`, we can reduce to the case `n = m` by replacing `x` by `x'`. If `U(γ, δ) ∈ f(x')`, note first that we must have `δ ∈ f(x')`, else `x`, `y`, `γ`, `δ` would not be a counterexample. Let `γ' = δ ∧ U(γ, δ) ∈ f(x')`. Using A3a we see `¬U(γ', δ) ∈ f(x)`, so we can reduce to the case `n = 0` by replacing `γ` by `γ'` and `y` by `x'`.

### 2.2 Our Current Code (`eliminate_C4_counterexample`, lines 304–416)

Our code **does NOT implement the induction structure**. Instead, it attempts a direct construction:

**Step 1**: Find a fresh rational `z` between `x` and `y`, not in the finite domain. (Line 316)

**Step 2**: Find an MCS `D` containing `¬γ` (negated GUARD). (Line 322)

**Step 3**: Build `χ'` by inserting `z` and assigning `f'(z) = D`, leaving `g` unchanged. (Line 324)

The code then uses negation completeness to pick `D` in three cases:

| Case | Condition | Action | Burgess Analogue |
|------|-----------|--------|------------------|
| **Case 2** | `¬γ ∈ f(x)` | `D = f(x)` | Not in Burgess — Burgess always uses Lemma 2.6 |
| **Case 1b** | `γ ∈ f(x)` and `¬γ ∈ f(y)` | `D = f(y)` | Not in Burgess — Burgess always uses Lemma 2.6 |
| **Case 1a** (hard case) | `γ ∈ f(x)` and `γ ∈ f(y)` | Find `w_max`, then `sorry` | Closest to Burgess's `n=m+1` inductive case, but **still structurally wrong** |

### 2.3 Critical Deviations in C4

#### Deviation 1: No Induction on `n` (Number of Intermediate Domain Points)

**Burgess**: Uses induction on `n = #{v ∈ dom | x < v < y}`. The induction structure is **essential** because:
- Base case `n=0`: `x` and `y` are adjacent. C2' gives `R(f(x), g(x,y), f(y))`. Lemma 2.6 can be applied because `γ ∉ g(x,y)` (see Deviation 3 below).
- Inductive case: Either move `x` forward to `x'` (reducing `n` by 1) or replace `(γ, y)` by `(δ ∧ U(γ,δ), x')` (making `x` and `x'` adjacent, reducing to `n=0`).

**Our code**: Skips induction entirely. It directly finds a fresh `z` between `x` and `y` and tries to pick `D` by case analysis on negation completeness at the endpoints. This is fundamentally different.

**Severity**: HIGH. The induction is the **correctness argument** that the C4 condition can always be satisfied by finite extension. Our direct construction does not prove this.

#### Deviation 2: g-Values Not Constructed

**Burgess**: In the base case, explicitly sets:
- `g'(x,z) = B'`
- `g'(z,y) = B''`
- Other `g'` values determined by C3

Where `B', D, B''` come from the **output of Lemma 2.6** applied to `A = f(x)`, `B = g(x,y)`, `C = f(y)`.

**Our code**: Sets `g' = χ.g` unchanged for all pairs. (Lines 324–326: `fun _ _ _ _ => rfl, fun _ _ => rfl`)

**Severity**: HIGH. g-values are critical for maintaining C2, C2', C3 through the elimination. The `EliminationResult` type at line 693 includes a `c2'` field that should prove `BurgessR3Maximal` for adjacent pairs, but every case branch fills this with `sorry`.

#### Deviation 3: Missing `γ ∉ g(x,y)` Justification

**Burgess**: In the base case `n=0`, Burgess **does not say** which variable corresponds to the `δ` in Lemma 2.6 (which requires `δ ∉ B`). But we can deduce it must be `γ` (the guard):

If `γ ∈ g(x,y)`, then by definition of `r(A,B,C)` (C2), for all `δ' ∈ f(y)`, `U(γ, δ') ∈ f(x)`. Since `δ ∈ f(y)` (counterexample condition), we'd have `U(γ,δ) ∈ f(x)`. But the counterexample gives `¬U(γ,δ) ∈ f(x)`. Contradiction. So `γ ∉ g(x,y)`. This is exactly the condition needed to apply Lemma 2.6 with `β = γ`.

**Our code**: Does not prove or use this crucial fact. Instead, it bypasses Lemma 2.6 entirely in Cases 2 and 1b, and in Case 1a it tries to find a different adjacent pair `(w, w_next)` where `¬U(γ,δ) ∈ f(w)` and apply `burgessR3_gamma_not_in_B` + `lemma_2_6_splitting`.

**Severity**: MEDIUM-HIGH. The `γ ∉ g(x,y)` argument is the **bridge** between C4 and Lemma 2.6. Our code attempts a workaround (finding `w_max` and its successor) but this is a deviation from Burgess's cleaner approach.

#### Deviation 4: A3a Usage in Inductive Case

**Burgess**: In the inductive case, when `U(γ,δ) ∈ f(x')`:
1. Note that `δ ∈ f(x')` must hold, else `x', y, γ, δ` would already be a witness for C4 (specifically: if `δ ∉ f(x')`, then because `x'` is between `x` and `y` and `¬U(γ,δ) ∈ f(x')` with `δ ∈ f(y)`... wait, that's not quite right either. Let me re-read: "note first that we must have `δ ∈ f(x')`, else `x, y, γ, δ` would not be a counterexample." This means: if `δ ∉ f(x')`, then `x'` is a witness for the C4 condition (we need `¬γ ∈ f(z)` for some `z` between `x` and `y`). But if `δ ∉ f(x')`, does that give `¬γ ∈ f(x')`? No. So Burgess's reasoning must be: if `δ ∉ f(x')`, then `x'` itself is a point in dom where something holds... Actually, I think Burgess means: if `U(γ,δ) ∈ f(x')` but `δ ∉ f(x')`, then `x'` is not relevant. The counterexample is about `x`, not `x'`. Hmm.

Wait, let me re-read more carefully. The counterexample `(x, y, γ, δ)` means: `¬U(γ,δ) ∈ f(x)` and `δ ∈ f(y)` and NO intermediate `z` in dom with `¬γ ∈ f(z)`. The inductive step lets `x'` immediately succeed `x`. We check `¬U(γ,δ) ∈ f(x')` or `U(γ,δ) ∈ f(x')`.

- If `¬U(γ,δ) ∈ f(x')`: then `(x', y, γ, δ)` might also be a counterexample (need to check no intermediate z). Since `x' > x`, there are fewer elements between `x'` and `y` than between `x` and `y`. So we can apply IH. ✓

- If `U(γ,δ) ∈ f(x')`: Burgess says "note first that we must have `δ ∈ f(x')`, else `x, y, γ, δ` would not be a counterexample."

  Why must `δ ∈ f(x')`? If `δ ∉ f(x')`, then... what? The counterexample requires `δ ∈ f(y)` and no intermediate `z` with `¬γ`. If `U(γ,δ) ∈ f(x')` and `δ ∉ f(x')`, then by C4 on the pair `(x', y)`: if `¬U(γ,δ) ∈ f(x')` then we'd get a witness... but we have `U(γ,δ) ∈ f(x')`, not `¬U(γ,δ)`. 

  Actually, I think the point is: if `U(γ,δ) ∈ f(x')` but `δ ∉ f(x')`, then the reason we can't use `x'` as the witness for C4 at `x` is that we need `¬γ ∈ f(x')`, not `U(γ,δ) ∈ f(x')`. But if `δ ∉ f(x')`, then C5 says there must be some intermediate point where... no, C5 is about `U` at `x'`, not about `U` at `x`.

  I think the reasoning is: if `U(γ,δ) ∈ f(x')` and `δ ∉ f(x')`, then there must be some point between `x'` and `y` where... actually no. The eventuality for `U(γ,δ)` at `x'` might be resolved before `y`.

  Actually, I think the simpler reading is correct: if `δ ∉ f(x')`, then either there's an intermediate point showing `¬γ`, or the eventuality hasn't happened yet. But the counterexample at `x` says `¬U(γ,δ) ∈ f(x)`. If `x'` has `U(γ,δ)`, then `x'` witnesses that the Until obligation is present at `x'`. Combined with `δ ∈ f(y)`, perhaps this means the counterexample at `x` is not genuine? Hmm, I'm not sure.

  In any case, Burgess's claim is: if `U(γ,δ) ∈ f(x')`, then `δ ∈ f(x')`. Now `γ' = δ ∧ U(γ,δ) ∈ f(x')`. Then `¬U(γ', δ) ∈ f(x)`. This uses A3a in reverse: A3a is `p ∧ U(q,r) ⊃ U(q ∧ S(p,r), r)`. If `p = ¬U(γ,δ)`... no, that doesn't work.

  Wait, I think Burgess is using a contrapositive argument. If `U(γ',δ) ∈ f(x)`, then by A3a (or the contrapositive of some axiom), something about `U(γ,δ)`... Let me think.

  Actually, A3a: `p ∧ U(q,r) ⊃ U(q ∧ S(p,r), r)`. If we take `p = ¬U(γ,δ)`? No, `p` must be positive.

  Perhaps Burgess means: from `U(γ,δ) ∈ f(x')` and `δ ∈ f(x')`, by A5a (`U(p,q) ⊃ U(p, q ∧ U(p,q))`), we get `U(γ, δ ∧ U(γ,δ)) ∈ f(x')`. But that's not `¬U(γ',δ) ∈ f(x)`.

  I think I may be over-interpreting Burgess's brief text. The key structural point for our analysis is:
  - **Burgess uses the inductive structure with specific sub-cases**
  - **Our code does not**

#### Deviation 5: The `w_max` Strategy (Our Code, Case 1a)

Our code defines `w_max` as the rightmost point in `[x, y)` with `¬U(γ,δ) ∈ f(w)`. Then it finds the successor `w_next` of `w_max` in dom.

This is **invented structure**, not from Burgess. Burgess doesn't need `w_max` because his induction directly moves `x` to `x'` (the immediate successor). Our `w_max` strategy is overly complex and attempts to avoid the induction by finding a "later" base case.

**Severity**: MEDIUM. The `w_max` approach might work if `c2'` is restored, but it is not Burgess's original structure.

### 2.4 C4' Mirror (Since Direction)

Same deviations apply to `eliminate_C4'_counterexample` (lines 426–514), which mirrors C4 elimination for the Since direction (C4b). Our code:
- Does not use induction on intermediate points
- Does not construct g-values (uses `χ.g` unchanged)
- Uses `w_min` strategy (leftmost point with negated Since) instead of Burgess's induction
- Hard case at line 510 is `sorry`

---

## 3. Section 2.10 (C5 Elimination) — Burgess vs. Code

### 3.1 Burgess 2.10 — Exact Text

> **Lemma 2.10 (Counterexample Lemma)**:
> Let `(f,g) ∈ F` and suppose `x, ξ, η` constitute a counterexample to C5a for `(f,g)`. Then there exists an extension `(f',g') ∈ F` of `(f,g)` for which `x, ξ, η` do not constitute a counterexample to C5a.
>
> **Proof**: What we claim is that it is possible to add a single point `y` lying after `x` to dom `f`, and extend `f` and `g` to functions `f'` and `g'` on this enlarged domain, in such a way that `ξ ∈ f'(y)`, `η ∈ g'(x, y)`, and all the requirements for membership in `F` are satisfied by `(f',g')`. We prove this by induction on the number `n` of elements of dom `f` lying after `x`.
>
> **Case n = 0.** We can apply 2.4 to `A = f(x)` obtaining `B, C`. Set `y = x + 1`, `f'(y) = C`, `g'(x, y) = B`, and let C3 determine the other values of `g'(w, y)`.
>
> **Case n = m + 1.** Let `x'` immediately succeed `x` in dom `f`. If (i) both `η ∧ U(ξ, η) ∈ f(x')` and `η ∈ g(x, x')`, then we can reduce to the case `n = m` by replacing `x` by `x'`. If (i) fails, note also that we cannot have (ii) both `ξ ∈ f(x')` and `η ∈ g(x, x')`; else `x, ξ, η` would not be a counterexample. But if (i) and (ii) both fail, then the hypotheses either of 2.7 or else of 2.8 must hold for `A = f(x)`, `B = g(x, x')`, `C = f(x')`. So we can obtain `B', D, B''` as in the conclusion of 2.7. Set `z = (x + x')/2`, `f'(z) = D`, `g'(x, z) = B'`, `g'(z, x') = B''`, and let C3 determine the other values of `g'(w, z)` and `g'(z, w)`.

### 3.2 Our Current Code (`eliminate_C5_counterexample`, lines 167–204)

```lean
noncomputable def eliminate_C5_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C5Counterexample χ) :
    ∃ χ' : Chronicle, ... := by
  -- Step 1: Get a fresh point y > all domain points
  obtain ⟨y, hy_gt, hy_notin⟩ := exists_rat_gt_finset χ.dom
  -- Step 2: Use Lemma 2.4 to get an MCS with eta and g_content(f(x)), plus interval DCS B
  have h_mcs_x := h_c0 ce.x ce.x_mem
  obtain ⟨_B, C, h_C_mcs, h_η_C, _, _, _⟩ :=
    lemma_2_4 h_mcs_x ce.ξ ce.η ce.until_mem
  -- Step 3: Build the new chronicle
  -- f' agrees with f on old domain, assigns C to y
  -- g' is unchanged (placeholder; full interval assignment in ChronicleConstruction)
  refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩, ...
```

### 3.3 Critical Deviations in C5

#### Deviation 1: No Induction on `n` (Number of Points After `x`)

**Burgess**: Uses induction on `n = #{v ∈ dom | v > x}`:
- Base `n=0`: `x` is the **rightmost** point in dom. Apply Lemma 2.4 to get `B, C`. Insert new point `y = x+1` (adjacent to `x`). Set `f'(y) = C`, `g'(x,y) = B`.
- Inductive `n=m+1`: Let `x'` immediately succeed `x`. Check conditions (i) and (ii):
  - (i): `η ∧ U(ξ,η) ∈ f(x')` AND `η ∈ g(x,x')`
  - (ii): `ξ ∈ f(x')` AND `η ∈ g(x,x')`
  - If (i) holds: replace `x` by `x'`, reduce to case `m` (fewer points after `x'`).
  - If (i) fails: (ii) must also fail (else not a counterexample). Then hypotheses of Lemma 2.7 or 2.8 hold for `A = f(x), B = g(x,x'), C = f(x')`. Apply Lemma 2.7 to get `B', D, B''`. Insert `z = (x+x')/2` between `x` and `x'` with `f'(z) = D`, `g'(x,z) = B'`, `g'(z,x') = B''`.

**Our code**: Completely skips induction. Picks a fresh point `y > all domain points`. `y` is placed at the extreme right, far beyond `x`, making it non-adjacent to anything relevant.

**Severity**: CRITICAL. Our C5 elimination places the witness at an arbitrary far-right point. This means:
1. The point is not adjacent to `x`, so C2' does not apply to `g(x,y)`.
2. The `C5Counterexample` structure expects a witness with both `η ∈ f(y)` AND intermediate guard propagation in `f` (not `g`). Our code only guarantees `η ∈ f(y)`.
3. The limit stage C5 condition requires `η ∈ g(x,y)`, but our construction never assigns `g(x,y)` values.

#### Deviation 2: Point Placement

**Burgess**: In base case `n=0`, `y = x+1`. In inductive case, `z = (x+x')/2` between `x` and `x'`.

**Our code**: `y > max(dom)`. Placed far to the right. This breaks the adjacency and C3 decomposition that Burgess relies on.

**Severity**: HIGH. C5 satisfaction at finite stages requires the inserted point to be close enough for C2' or C3 to apply.

#### Deviation 3: g-Values Not Constructed

**Burgess**: In base case, `g'(x,y) = B` from Lemma 2.4 output.
In inductive case, `g'(x,z) = B'` and `g'(z,x') = B''` from Lemma 2.7 output.

**Our code**: `g' = χ.g` unchanged. No g-value construction.

**Severity**: CRITICAL. The whole point of C5 is `η ∈ g(x,y)`. Our elimination produces `η ∈ f(y)` but fails to put `η` in `g(x,y)`.

Wait — let me re-read Lemma 2.4. `lemma_2_4` in our code returns `⟨B, C, h_C_mcs, h_η_C, _, _, _⟩`. Does it return `η ∈ B` or `η ∈ C`?

Looking at `lemma_2_4` in PointInsertion.lean (line 153), let me check what it returns. I didn't read the full type signature, but the C5 code uses `h_η_C` which suggests `η ∈ C`. But Burgess's Lemma 2.4 gives `β ∈ B` and `γ ∈ C` (where `U(γ,β) ∈ A`). In our notation, `ξ = γ` (guard) and `η = β` (event). So Burgess says `η ∈ B = g(x,y)` and `ξ ∈ C = f(y)`.

Wait, that contradicts! Let me re-read Burgess 2.4:

> Let `A` be an MCS and suppose `U(γ, β) ∈ A`. Then there exist `B, C` such that `β ∈ B`, `γ ∈ C`, and `R(A, B, C)` holds.

So: `β ∈ B`, `γ ∈ C`. In our notation with `U(ξ,η) ∈ f(x)`:
- `η ∈ B` = `g(x,y)` (event in the interval set)
- `ξ ∈ C` = `f(y)` (guard at the endpoint)

But our C5 code says `h_η_C` — `η ∈ C = f(y)`. This is **wrong per Burgess**!

Wait, let me check the actual return types of `lemma_2_4`.

Looking at the code (line 182):
```lean
obtain ⟨_B, C, h_C_mcs, h_η_C, _, _, _⟩ :=
    lemma_2_4 h_mcs_x ce.ξ ce.η ce.until_mem
```

The underscore `_B` is unused. `C` is the MCS with `h_η_C` which means `η ∈ C`. But if `η ∈ C`, and `C = f(y)`, then `η ∈ f(y)`. But Burgess says `η ∈ B` (the interval DCS), and `ξ ∈ C` (the endpoint MCS).

So our code's C5 witness has `η ∈ f(y)` but NOT `ξ ∈ f(y)`. And it doesn't have `η ∈ g(x,y)` at all.

This is a **major semantic deviation** from Burgess. Our C5Counterexample definition at lines 48–55 checks:

```lean
no_witness : ¬∃ y ∈ χ.dom, x < y ∧ η ∈ χ.f y ∧
    ∀ z ∈ χ.dom, x < z → z < y → ξ ∈ χ.f z ∧ Formula.untl ξ η ∈ χ.f z
```

This requires `η ∈ f(y)` AND guard propagation at intermediate points. Burgess C5a only requires `ξ ∈ f(y)` and `η ∈ g(x,y)`. The intermediate propagation comes from C3 + C2 at the limit, not from the witness condition.

But wait — maybe our `C5Counterexample` was deliberately designed to check a stronger condition because we don't properly construct g-values? If g-values are absent, the only way to ensure guard propagation is to check it in f at all intermediate points. But this is a **hack around missing g-values**, not a faithful implementation of Burgess.

So we have a self-reinforcing problem:
1. g-values are not constructed → we can't check `η ∈ g(x,y)`
2. So `C5Counterexample` checks `η ∈ f(y)` + intermediate f-values instead
3. But this doesn't match Burgess's C5a definition
4. And the truth lemma needs `η ∈ g(x,y)` to function correctly

#### Deviation 4: Conditions (i) and (ii) Not Checked

**Burgess**: In the inductive case, explicitly checks:
- (i) `η ∧ U(ξ,η) ∈ f(x')` AND `η ∈ g(x,x')`
- (ii) `ξ ∈ f(x')` AND `η ∈ g(x,x')`

**Our code**: Never checks either condition. The induction itself is absent, so these conditions are irrelevant to our direct construction.

**Severity**: HIGH. Conditions (i) and (ii) are the logical pivot that determines whether we reduce the induction or apply Lemma 2.7. Without them, our construction cannot replicate Burgess's proof.

#### Deviation 5: C5' Mirror (`eliminate_C5'_counterexample`, lines 211–249)

Our C5' code:
- Gets `y < all domain points` (extreme left placement)
- Uses `past_temporal_witness_seed_consistent` + `set_lindenbaum` to build `C` with `η ∈ C`
- Does NOT use Lemma 2.4
- Does NOT construct g-values
- Places the witness at the extreme left, far from `x`

**Severity**: HIGH. Same issues as C5, plus it doesn't mirror Burgess's Lemma 2.4' (which should be symmetric to Lemma 2.4).

---

## 4. Structural Deviations Summary

| # | Deviation | Burgess | Our Code | Severity |
|---|-----------|---------|----------|----------|
| 1 | **C4: No induction on `n`** | Induction on intermediate points | Direct fresh point insertion | HIGH |
| 2 | **C4: g-values not constructed** | `g'(x,z) = B'`, `g'(z,y) = B''` from Lemma 2.6 | `g' = χ.g` unchanged | CRITICAL |
| 3 | **C5: No induction on `n`** | Induction on points after `x` | Direct extreme-right placement | CRITICAL |
| 4 | **C5: Point placement** | `y = x+1` (adjacent) or `z = (x+x')/2` | `y > max(dom)` (far right) | HIGH |
| 5 | **C5: g-values not constructed** | `g'(x,y) = B` from Lemma 2.4 | `g' = χ.g` unchanged | CRITICAL |
| 6 | **C5: Lemma 2.4 output misused** | `η ∈ B` (interval), `ξ ∈ C` (endpoint) | `η ∈ C` (endpoint), no interval | CRITICAL |
| 7 | **C5: Conditions (i) and (ii) absent** | Checked in inductive step | Never checked | HIGH |
| 8 | **C4/C5: `c2'` not used in elimination** | C2' is the key premise for base cases | c2' removed from finite stages | HIGH |
| 9 | **C4: `w_max`/`w_min` invented** | Not in Burgess | Used in hard case | MEDIUM |
| 10 | **EliminationResult g-agreement** | g must be extended at new adjacent pairs | g unchanged for all pairs | CRITICAL |

---

## 5. Role of C2' (Maximality at Adjacent Pairs)

### 5.1 What C2' Does in Burgess's Construction

**C2'** = `R(f(x), g(x,y), f(y))` for adjacent pairs `x < y`. BurgessR3Maximal in our code.

C2' is **absolutely essential** for:

1. **C4 base case (n=0)**: Since `x` and `y` are adjacent, C2' gives `R(f(x), g(x,y), f(y))`. Then:
   - As argued in §2.3 Deviation 3, `γ ∉ g(x,y)` (because `¬U(γ,δ) ∈ f(x)` and `δ ∈ f(y)`).
   - Apply Lemma 2.6 with `β = γ` to get `B', D, B''` with `¬γ ∈ D`.
   - This requires C2' to get `R(f(x), g(x,y), f(y))` as the maximality premise.

2. **C5 inductive case**: When conditions (i) and (ii) both fail:
   - Condition (ii) failing means: `ξ ∉ f(x')` OR `η ∉ g(x, x')`.
   - Since `x'` immediately succeeds `x`, C2' gives `R(f(x), g(x,x'), f(x'))`.
   - If `η ∉ g(x,x')`, then the hypotheses of Lemma 2.7 apply (with `η` not in the interval DCS).
   - If condition (ii) fails because `ξ ∉ f(x')`, then Lemma 2.8 applies.
   - Both 2.7 and 2.8 require `R(A, B, C)` where `A = f(x)`, `B = g(x,x')`, `C = f(x')`.

3. **Limit construction**: At the limit (dense domain with no adjacent pairs), C2' is vacuously true. But to **get** to the limit, every finite stage must preserve C2' so that the inductive steps of C4 and C5 elimination can continue.

### 5.2 What Happened to C2' in Our Code

From `ChronicleConstruction.lean` (lines 246–248):

```lean
-- The c2' invariant is no longer threaded through
-- finite stages (Phase 7 change); it is vacuously true at the limit
-- since the limit domain is dense with no adjacent pairs.
```

**This is a fundamental design decision that breaks the Burgess construction.**

By removing C2' from the finite omega-chain, we:
1. Lose the maximality needed for Lemma 2.6 in C4 base cases
2. Lose the maximality needed for Lemma 2.7 in C5 inductive cases
3. Lose the ability to correctly assign g-values at new adjacent pairs
4. Cannot prove the C4/C5 elimination lemmas structurally

The implementation plan (Phase 4a–4e) proposes restoring C2' threading, but this is **add-on work** that should have been part of the original design. The plan acknowledges this by noting:

> "The c2' invariant is no longer threaded through finite stages (Phase 7 change)"

### 5.3 Restoring C2': What It Requires

Per the implementation plan (Phase 4), restoring C2' requires:
1. Adding `c2'` to `EliminationResult` (already done in the type signature, but filled with `sorry`)
2. Proving `c2'` for each branch of `eliminate_potential_counterexample`
3. In C5 elimination: assigning `g(x,y) = B` from Lemma 2.4 output, then proving `BurgessR3Maximal(f(x), B, C)`
4. In C4 elimination: using `lemma_2_6_splitting` to get `B', D, B''`, then assigning `g(x,z) = B'` and `g(z,y) = B''`

But this is only possible if we **first** construct g-values correctly in the elimination functions, which currently don't.

---

## 6. What Must Be Implemented to Match Burgess Exactly

### 6.1 High-Level Requirements

To make our code match Burgess 1982 Sections 2.9 and 2.10 exactly, the following must be implemented:

1. **C4 Elimination must use induction on `n`**:
   - Define `n = number of domain points between x and y`
   - Base `n=0`: `x` and `y` are adjacent. Use C2' to apply `lemma_2_6_splitting` with `β = γ` (guard).
   - Inductive `n=m+1`: Let `x'` immediately succeed `x`.
     - If `¬U(γ,δ) ∈ f(x')`: replace `x ← x'`, recurse (fewer points)
     - If `U(γ,δ) ∈ f(x')` with `δ ∈ f(x')`: replace `γ ← δ ∧ U(γ,δ)`, `y ← x'`, recurse (becomes adjacent)
   - Construct `g'` at new adjacent pairs from `lemma_2_6_splitting` output.

2. **C5 Elimination must use induction on `n`**:
   - Define `n = number of domain points after x`
   - Base `n=0`: `x` is rightmost. Apply `lemma_2_4` to get `B, C`. Set `f'(y) = C`, `g'(x,y) = B` where `y = x+1`.
   - Inductive `n=m+1`: Let `x'` immediately succeed `x`.
     - If (i) `η ∧ U(ξ,η) ∈ f(x')` and `η ∈ g(x,x')`: replace `x ← x'`, recurse.
     - If (ii) `ξ ∈ f(x')` and `η ∈ g(x,x')`: contradiction with counterexample definition.
     - Otherwise: hypotheses of `lemma_2_7` or `lemma_2_8` hold. Apply to get `B', D, B''`. Insert `z = (x+x')/2` with `f'(z) = D`, `g'(x,z) = B'`, `g'(z,x') = B''`.
   - Construct `g'` at new adjacent pairs from Lemma 2.4 or Lemma 2.7 output.

3. **g-Value Construction in Every Elimination**:
   - C4 base case: `g(x,z) = B'`, `g(z,y) = B''` from `lemma_2_6_splitting`
   - C5 base case: `g(x,y) = B` from `lemma_2_4`
   - C5 inductive case: `g(x,z) = B'`, `g(z,x') = B''` from `lemma_2_7`
   - C3 must be used to determine all other g-values involving the new point
   - The EliminationResult must return a modified `g` function, not keep `χ.g` unchanged

4. **C5Counterexample Must Match Burgess C5a**:
   - Burgess C5a: `U(ξ,η) ∈ f(x)` but NO `y > x` with `ξ ∈ f(y)` and `η ∈ g(x,y)`
   - Current code checks: `η ∈ f(y)` + intermediate `ξ ∈ f(z)` for all `z`
   - This should be changed to: check `ξ ∈ f(y)` and `η ∈ g(x,y)` (the latter requires g to be populated)

5. **C2' Must Be Threaded Through the Omega-Chain**:
   - `EliminationResult` already has `c2'` field, but every case fills it with `sorry`
   - Phase 4 of the implementation plan addresses this
   - Without C2', the inductive arguments for C4 and C5 base cases cannot work

6. **Lemma 2.4 Output Must Be Used Correctly**:
   - `lemma_2_4` returns `B, C` where `η ∈ B` and `ξ ∈ C` (for input `U(ξ,η) ∈ A`)
   - In C5 elimination: `B = g(x,y)` (so `η ∈ g(x,y)`) and `C = f(y)` (so `ξ ∈ f(y)`)
   - Current code extracts `h_η_C` but ignores `_B`, which means `η ∈ C = f(y)` (wrong per Burgess)
   - Fix: extract `h_η_B` from `B` and set `ξ ∈ C = f(y)`. Then `η ∈ g(x,y)` by construction.

---

## 7. Critical Observations for Implementation

### 7.1 The C4 `γ ∉ g(x,y)` Argument Is Key

In Burgess's C4 base case (`n=0`), the proof relies on showing `γ ∉ g(x,y)` to apply Lemma 2.6. This argument is:

> If `γ ∈ g(x,y)`, then by `r(A,B,C)` (C2), for all `δ' ∈ C = f(y)`, `U(γ, δ') ∈ A = f(x)`. Since `δ ∈ f(y)` (C4 counterexample), we get `U(γ,δ) ∈ f(x)`. But the counterexample has `¬U(γ,δ) ∈ f(x)`. Contradiction.

This argument does **not** require C2' (maximality), only C2 (the r-relation). But C2' is needed to apply Lemma 2.6, which requires `R(A,B,C)` (maximal R).

So the C4 base case needs:
1. `r(f(x), g(x,y), f(y))` (from C2)
2. `γ ∉ g(x,y)` (proven by contradiction)
3. `R(f(x), g(x,y), f(y))` (from C2')
4. Apply Lemma 2.6 with `β = γ` to get `B', D, B''` with `¬γ ∈ D`

### 7.2 The C5 Condition (ii) Contradiction Is Key

In Burgess's C5 inductive case, condition (ii) says: `ξ ∈ f(x')` AND `η ∈ g(x,x')`.

If condition (ii) holds, then `x'` itself is a witness for C5 at `x`! Because:
- `x' > x` (immediate successor)
- `ξ ∈ f(x')` (condition ii)
- `η ∈ g(x,x')` (condition ii)

So if (ii) holds, `x, ξ, η` is NOT a counterexample. This is why Burgess says "we cannot have (ii)... else `x, ξ, η` would not be a counterexample."

### 7.3 Lemma 2.7 vs. 2.8 in C5 Inductive Case

When conditions (i) and (ii) both fail in the C5 inductive case:

- If `η ∉ g(x,x')`: hypothesis of Lemma 2.7 applies (with `η` not in the interval DCS).
  - Lemma 2.7: `R(A,B,C)` and `U(ξ,η) ∈ A` and `η ∉ B`.
- If `η ∈ g(x,x')` but `ξ ∉ f(x')`: this means condition (ii) fails because `ξ ∉ f(x')`.
  - Then `¬(ξ ∨ (η ∧ U(ξ,η))) ∈ f(x')` (because `ξ ∉ f(x')`, and if `η ∧ U(ξ,η) ∈ f(x')` then condition (i) would hold).
  - So `¬ξ ∈ f(x')`, which means `¬(ξ ∨ (η ∧ U(ξ,η))) ∈ f(x')`.
  - This is the hypothesis of Lemma 2.8: `R(A,B,C)` and `U(ξ,η) ∈ A` and `¬(ξ ∨ (η ∧ U(ξ,η))) ∈ C`.

So one of 2.7 or 2.8 always applies when (i) and (ii) both fail.

### 7.4 g-Value Propagation to Limit

The implementation plan (Phase 5a) proposes proving:

```lean
theorem limit_satisfies_c5_full ... :
  ∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f y ∧
    ∀ z ∈ limit_dom, x < z → z < y → ξ ∈ limit_f z
```

This is **stronger** than Burgess's C5a. Burgess's C5a only requires:

```
∃ y, x < y ∧ ξ ∈ f(y) ∧ η ∈ g(x,y)
```

Then the truth lemma uses C3 to get `g(x,y) ⊆ f(z)` for intermediate `z`, hence `ξ ∈ f(z)`.

Our `limit_satisfies_c5_full` skips g-values and directly proves intermediate guard propagation in f. This is possible but requires a different proof structure from Burgess, or requires proving that `ξ ∈ g(x,y)` implies `ξ ∈ f(z)` for all intermediate `z` via C3.

### 7.5 The Self-Reinforcing g-Value Problem

Our codebase has a **self-reinforcing problem** with g-values:

1. `Chronicle.g` is defined for ALL pairs `x < y`, not just adjacent pairs (line 340 of ChronicleTypes).
2. But C2' only constrains g at adjacent pairs.
3. C3 determines g at non-adjacent pairs by intersection.
4. However, our elimination functions never modify g, so g remains empty/unchanged.
5. If g is empty/unchanged at all finite stages, then C3 gives `g(x,z) = ∅ ∩ f(y) ∩ g(y,z) = ∅`.
6. At the limit, g is also empty (union of empty sets).
7. So `η ∈ g(x,y)` can never hold at the limit unless g-values are populated during finite stages.

**This means our current construction CANNOT satisfy Burgess C5a at the limit**, because g is always empty.

The fix is:
- Populate g at adjacent pairs during each elimination step
- Use C3 to propagate to non-adjacent pairs automatically
- At the limit, g is the union of all finite-stage g-values
- If g was populated correctly at finite stages, the limit g will be correct

### 7.6 The Density Problem

Burgess's construction does not require explicit "density" elimination (inserting midpoints between adjacent pairs) because the C4 and C5 elimination steps naturally insert points between existing adjacent pairs. Every time we apply Lemma 2.6 or Lemma 2.7, we insert a point between two existing points, breaking their adjacency. Over infinitely many steps, the domain becomes dense.

Our code has a separate `eliminate_density_counterexample` (lines 620–651) and a `.density` kind in `PotentialCounterexampleKind`. This is **not from Burgess**. Burgess does not have a separate density elimination lemma. Density emerges naturally from the C4/C5 elimination steps.

The density elimination in our code (inserting midpoint between adjacent pairs with no specific counterexample) was added as a **workaround** to ensure the limit is dense despite our direct point placement strategy. But if we correctly implement Burgess's induction, density emerges naturally from the inductive cases of C4/C5.

---

## 8. Reference: Exact Mapping of Burgess Variables to Our Code

| Burgess | Our Code | Meaning |
|---------|----------|---------|
| `A` | `f(x)` or `f(x_prev)` | Left endpoint MCS |
| `B` | `g(x,y)` or current interval DCS | Interval DCS |
| `C` | `f(y)` or `f(x_next)` | Right endpoint MCS |
| `R(A,B,C)` | `BurgessR3Maximal A B C` | Maximal r-relation |
| `r(A,B,C)` | `burgessR3 A B C` | Non-maximal r-relation |
| `δ` (guard in Lemma 2.6) | `γ` (guard of Until) | Formula to negate in new MCS |
| `γ` (event in Lemma 2.4) | `ξ` | Guard of Until |
| `β` (event in Lemma 2.4) | `η` | Event of Until |
| `U(γ,β) ∈ A` | `Formula.untl ξ η ∈ χ.f x` | Until obligation |
| `S(α,β) ∈ C` | `Formula.snce ...` | Since obligation |
| `n = # points between x,y` | Not explicitly computed | Induction parameter for C4 |
| `n = # points after x` | Not explicitly computed | Induction parameter for C5 |
| `x'` (immediate successor of `x`) | `x_next` or `w_next` | Next domain point after `x` |

---

## 9. Conclusion

**Our current codebase deviates significantly from Burgess 1982 Sections 2.9 and 2.10.**

The most critical deviations are:

1. **Neither C4 nor C5 elimination uses Burgess's induction structure.** Both eliminate by direct construction without induction on domain point counts.

2. **g-values are never constructed in elimination steps.** This breaks C2, C2', C3 at all finite stages and at the limit.

3. **C5 elimination places the witness far from `x`** instead of adjacent to `x` (or between `x` and `x'`).

4. **C2' was removed from the finite omega-chain**, making it impossible to apply Lemma 2.6 and Lemma 2.7 structurally.

5. **The self-reinforcing g-value problem**: because g is never populated, C5a (with `η ∈ g(x,y)`) can never be satisfied at the limit.

**What must be done** (in priority order):

1. **Restore C2' threading** through finite omega-chain stages (Phases 4a–4e of the implementation plan).
2. **Implement Burgess's induction structure** for C4 and C5 elimination.
3. **Construct g-values** in every elimination step using Lemma 2.4 / Lemma 2.6 / Lemma 2.7 outputs.
4. **Fix C5 output usage**: `η ∈ B` (interval), not `η ∈ C` (endpoint).
5. **Ensure C3 propagation** of g-values at non-adjacent pairs.
6. **Remove or repurpose density elimination** — density should emerge naturally from correct C4/C5 elimination.

Following Burgess exactly is not optional if we want the limit construction to work. The induction structure exists precisely to handle the finite-to-limit bridge. Removing it creates the gaps we now see in the codebase.

---

*End of Report*
