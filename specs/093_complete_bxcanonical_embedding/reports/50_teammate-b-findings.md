# Teammate B Findings: Literature Survey of Until Semantics

**Task**: 93 - Complete BXCanonical Embedding
**Role**: Teammate B (Alternative Approaches)
**Focus**: Until guard conventions in temporal logic literature

---

## Executive Summary

The literature survey reveals a fundamental tension in the current codebase: the `truth_at` definition uses an OPEN guard `(t, s)` for Until (i.e., `t < r → r < s`), but the module comments claim a "half-open" guard `[t, s)`. This inconsistency is the root cause of why BX9 (`φ U ψ → φ ∨ ψ`) has a `sorry`. The literature provides clear guidance on how standard systems handle this, and there is a well-known solution: using a half-open guard on the code level (i.e., `t ≤ r < s`) combined with an irreflexive G operator.

---

## 1. Standard Literature Definitions

### 1.1 Kamp's Original Until (1968)

Hans Kamp introduced Until in his 1968 PhD thesis. The standard definition used in the philosophical tradition is the **strict (open) version**:

> M, t ⊨ φ U ψ iff ∃s with t ≺ s, M,s ⊨ ψ and ∀u with t ≺ u ≺ s, M,u ⊨ φ

This is the **open guard** `(t, s)` — neither endpoint is included. Under this convention, the current time `t` is NOT in the guard range.

### 1.2 Computer Science Convention (Reflexive Until)

In computer science (LTL, CTL*), the standard is the **reflexive version**:

> M, t ⊨ φ U ψ iff ∃i ≥ 0 such that w_i ⊨ ψ and ∀k with 0 ≤ k < i, w_k ⊨ φ

This allows the witness to be at the current time (i = 0), and when ψ holds at the current time, nothing is required about φ. Under this convention:
- φ U ψ → ψ (because i = 0 is allowed, where nothing about φ is needed)
- G is defined as Gφ ↔ φ ∧ X(Gφ), which **includes** the current time

### 1.3 Burgess (1982) and Xu (1988)

The Burgess (1982a) and Xu (1988) axiomatization is for **reflexive** linear orders, using the reflexive versions of U and S. The axiom system includes:
- `Gφ → φ` (T-axiom; requires reflexive G)
- `G(φ → ψ) → φUχ → ψUχ` (left monotonicity, BX2)
- `G(φ → ψ) → χUφ → χUψ` (right monotonicity, BX3)
- `φUψ ∧ χUθ → ...` (linearity, BX7)

Notably, under the **reflexive** Burgess-Xu system, there is **no axiom** `φ U ψ → φ ∨ ψ` — this would only be needed/valid under a convention where the current time is in the guard range.

### 1.4 Venema (1993) and Reynolds (1994/1996)

Extensions to **strict** linear orders were provided by Venema (1993) and Reynolds (1994, 1996). These use the strict (open) versions U^s and S^s. Under these strict versions:
- The T-axiom `Gφ → φ` is dropped (irreflexive G)
- Seriality axioms `F(⊤)` replace reflexivity
- The open guard `(t, s)` is standard

Under strict semantics with open guard, `φ U^s ψ → φ ∨ ψ` is NOT a theorem because the current time is excluded from both the witness check and the guard.

### 1.5 The Reflexive-vs-Strict Definability Relationship

A key result from the literature: the reflexive versions can be defined in terms of the strict (irreflexive) ones:
- `φ U_ref ψ := ψ ∨ (φ ∧ φ U^s ψ)`
- `φ S_ref ψ := ψ ∨ (φ ∧ φ S^s ψ)`

The reverse is NOT generally possible (strict is more expressive on reflexive orders). On **discrete** orders, X (Next) allows recovery: `φ U^s ψ := X(φ U_ref ψ)`.

---

## 2. Analysis of the Current Codebase

### 2.1 The Core Contradiction

Reading `Truth.lean` lines 127-128:

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
```

This is the **open guard** `(t, s)`: `t < r` means the current time `t` is NOT in the guard range. This is Kamp's strict definition.

However, `Truth.lean` header (line 14) states:
> "Until uses strict witness (s > t) with half-open guard [t, s)."

And `Soundness.lean` line 492 states:
```
-- `φ U ψ` at `t`: ∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)
```

**This is a contradiction.** The header claims half-open `[t, s)` (with `t ≤ r`), but the actual code implements open `(t, s)` (with `t < r`). The `Soundness.lean` comment at line 492 appears to be aspirational or from a previous version, not a description of the current code.

### 2.2 Why BX9 has `sorry`

Because the code implements open guard `(t, s)`:
- `φ U ψ` at `t` means: ∃s > t, ψ(s) ∧ ∀r ∈ (t, s), φ(r)
- Nothing ensures φ(t) or ψ(t)
- Therefore `φ U ψ → φ ∨ ψ` is NOT semantically valid
- The `until_elim_valid` theorem correctly has `sorry` and comments "The guard does NOT include t, so φ(t) is not directly guaranteed."

### 2.3 Why BX2 works under open guard

Left monotonicity `G(φ → χ) → ((φ U ψ) → (χ U ψ))` is valid under open guard because:
- G uses strict future: `G(φ → χ)` at t means `∀r > t, φ(r) → χ(r)`
- The Until guard covers `r ∈ (t, s)`, and all such r satisfy `r > t`
- So G's knowledge of `φ → χ` at all `r > t` covers all guard points

The `left_mono_until_valid` proof (Soundness.lean line 501-506) correctly handles this.

### 2.4 Why BX2 would FAIL under half-open guard with strict G

If we changed Until to use half-open guard `[t, s)` (i.e., guard at r with `t ≤ r < s`), then the guard includes `r = t`. But G with strict semantics (`∀s > t, ...`) does NOT cover `r = t`. So:
- `G(φ → χ)` at `t` says: `∀r > t, φ(r) → χ(r)` (excludes r = t)
- But the half-open guard requires φ(t) for the Until guard at r = t
- BX2 would fail to discharge the case r = t

This confirms the BX2/BX9 tension precisely: you cannot have both simultaneously with mismatched G and Until conventions.

---

## 3. The Two-Convention Incompatibility — Formal Analysis

The tension is as follows:

| Convention | G semantics | Until guard | BX2 valid? | BX9 valid? |
|------------|-------------|-------------|------------|------------|
| Open (t, s) + strict G | ∀r > t | t < r < s | YES | NO |
| Half-open [t, s) + strict G | ∀r > t | t ≤ r < s | NO | YES |
| Half-open [t, s) + reflexive G | ∀r ≥ t | t ≤ r < s | YES | YES |
| Open (t, s) + reflexive G | ∀r ≥ t | t < r < s | YES | NO |

The **only convention where both BX2 and BX9 are simultaneously valid** is when G is **reflexive** (`∀r ≥ t`) and Until uses the **half-open** guard `[t, s)`. This is essentially the reflexive Burgess-Xu convention.

### 3.1 Why the Reflexive Convention Works for BX9

With reflexive G and half-open guard `[t, s)`:
- `φ U ψ` at t: ∃s > t, ψ(s) ∧ ∀r, t ≤ r < s → φ(r)
- Since t ≤ t < s (when s > t), the guard requires φ(t)
- Therefore φ(t) holds, so φ ∨ ψ holds at t ✓

### 3.2 Why the Reflexive Convention Works for BX2

With reflexive G:
- `G(φ → χ)` at t: ∀r ≥ t, φ(r) → χ(r)
- The Until guard is over r with t ≤ r < s, so all guard points r satisfy r ≥ t
- G provides φ(r) → χ(r) for all such r ✓

### 3.3 The Tradeoff: The T-Axiom

The tradeoff for using reflexive G is that `Gφ → φ` (T-axiom) becomes valid, which changes the logic class. Under BX (irreflexive G), the T-axiom is not included, and seriality axioms replace it. Switching to reflexive G would:
- Make T-axiom valid (a derivable truth, not a new axiom)
- Invalidate seriality axioms as the sole reason for serial frames
- Change the completeness result from Venema/Reynolds (strict) to Burgess/Xu (reflexive)

---

## 4. What the Standard Literature Says to Do

### 4.1 The Canonical Approach: Choose One, Be Consistent

The literature is unanimous: **choose one convention and be internally consistent**. Either:

**Option A: Strict (Open) Convention**
- G: ∀r > t (strict future)
- Until: ∃s > t, ψ(s) ∧ ∀r, t < r < s → φ(r)
- Then BX9 is NOT a theorem; drop it
- The logic is Kamp/Venema-style strict tense logic
- Completeness follows Venema (1993)

**Option B: Reflexive Convention**
- G: ∀r ≥ t (reflexive future)
- Until: ∃s, t ≤ s, ψ(s) ∧ ∀r, t ≤ r < s → φ(r)
- OR equivalently: ∃s > t, ψ(s) ∧ ∀r, t ≤ r < s → φ(r) (strict witness, half-open guard)
- Then BX9 IS a theorem; BX2 IS valid
- Completeness follows Burgess/Xu (1982/1988)
- T-axiom `Gφ → φ` is valid (T-axiom ≠ seriality)

### 4.2 The Half-Open Guard with Strict G is Incoherent

There is no standard treatment that uses half-open Until guard `[t, s)` with strictly irreflexive G (`∀r > t`). This combination is not standard and creates the exact incompatibility seen in the BX2/BX9 tension. The codebase comment claiming this combination is the "A2 guard convention" does not correspond to any standard treatment in the literature.

### 4.3 What Burgess (1984) Actually Uses

From the SEP Burgess-Xu supplement, the reflexive BX system has:
- `Gφ → φ` as the first axiom (reflexive G)
- `G(φ → ψ) → φUχ → ψUχ` (left monotonicity)
- No `φUψ → φ ∨ ψ` axiom (not needed; φ(t) follows from guard under reflexive witness)

This confirms that the original Burgess-Xu paper used **reflexive** semantics where the witness can be at or after t, and the guard includes t.

---

## 5. Implications for the BXCanonical Embedding

### 5.1 The Root Problem

The codebase has a semantic inconsistency between comments and implementation:
- Header claims: half-open `[t, s)` guard (would give BX9)
- Actual code implements: open `(t, s)` guard (breaks BX9)
- G is strictly irreflexive (breaks BX2 under half-open guard)

### 5.2 Recommended Fix: Align with Strict Open Convention

The simplest fix that preserves the irreflexive G semantics (which the rest of the codebase is built around) is to **drop BX9** from the axiom system and update the comments.

Under strictly irreflexive G with open Until guard `(t, s)`:
- BX2 (left monotonicity): valid ✓
- BX3 (right monotonicity): valid ✓
- BX5/BX6 (self-accumulation/absorption): valid ✓
- BX7 (linearity): valid ✓
- BX8 (step introduction): **invalid on general linear orders** (confirmed by sorry in codebase, needs density or discreteness)
- BX9 (elimination): **invalid** under open guard ✗
- BX10 (Until → F): valid ✓

The strict system without BX9 corresponds to Kamp/Venema-style tense logic.

### 5.3 Alternative Fix: Switch to Reflexive Convention

The alternative is to switch to the Burgess-Xu reflexive convention by changing `truth_at`:

```lean
-- Change Until from:
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
-- To (half-open guard, strict witness):
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
-- AND change G from:
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
-- To:
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

This makes both BX2 and BX9 valid, but changes the logic class (now reflexive G, T-axiom valid).

### 5.4 Hybrid Options Are Not Standard

There is no literature precedent for "half-open Until guard with strictly irreflexive G." Any attempt to combine these two conventions breaks either BX2 or BX9.

---

## 6. Is There a Known Solution to Having Both BX2 and BX9?

**Yes.** The solution is well-known in the literature: use the **reflexive convention** for Until (half-open guard with t ≤ r) together with **reflexive G** (t ≤ s).

This is exactly what Burgess (1982) and Xu (1988) use. The BXCanonical embedding should target this convention if both axioms are required.

The key insight from the literature is that BX9 (`φ U ψ → φ ∨ ψ`) is a *consequence* of the half-open guard, not an independent axiom. It does not need to be separately axiomatized—it follows semantically from the convention that the current time is in the Until guard range.

---

## 7. G Operator Redefinition: Implications

If G were redefined to include the current time (`∀r ≥ t`):

1. **T-axiom** `Gφ → φ` becomes valid (currently NOT in the axiom system)
2. **BX2** remains valid (because G now covers the r = t case in the half-open guard)
3. **BX9** becomes valid (because Until guard now includes r = t)
4. **BX4 (original)** `φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))` might become valid (needs checking)
5. **Temp_4** `Gφ → GGφ` remains valid
6. **Seriality** `F(⊤)` becomes derivable from T-axiom + seriality of the frame

The full impact of changing G's semantics would require auditing all soundness proofs. Most would likely become easier (reflexive operators are more standard), but any proofs that specifically use the strict irreflexive property of G would need updating.

---

## 8. Summary of Key Findings

1. **Standard (philosophical) convention**: Open guard `(t, s)` for Until, strictly irreflexive G. This makes BX2 valid but BX9 invalid.

2. **Computer science convention**: Reflexive Until (witness at t possible), reflexive G (includes t). This makes both BX2 and BX9 valid. This is the Burgess-Xu (1982/1988) convention.

3. **Kamp's theorem**: Until and Since are expressively complete for FO[<] on continuous strict linear orders (open guard). No BX9 equivalent is needed for completeness.

4. **The only combination supporting both BX2 and BX9**: Reflexive G + half-open Until guard (i.e., `t ≤ r` for the guard). This is the Burgess-Xu reflexive convention.

5. **Current codebase state**: Implements open guard `(t, s)` for Until (despite comments claiming half-open), with strictly irreflexive G. BX8 and BX9 both have `sorry` because they are genuinely invalid under this combination.

6. **Recommended path**: Either (a) drop BX9 and accept the strict Kamp/Venema framework, or (b) switch to the Burgess-Xu reflexive convention (change both G and Until to include the current time in their ranges), which is what the Soundness.lean comments at line 491-495 actually describe.

---

## References

- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Burgess, J.P. (1982a). Axioms for tense logic. I. "Since" and "until." *Notre Dame Journal of Formal Logic*, 23(4):367-374.
- Xu, M. (1988). On some U, S-tense logics. *Journal of Philosophical Logic*, 17:181-202.
- Venema, Y. (1993). Completeness via Completeness: Since and Until. In *Diamonds and Defaults*, Springer.
- Reynolds, M. (1994/1996). Axioms for temporally linear tense logics. (Various publications)
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1.* Oxford.
- Stanford Encyclopedia of Philosophy, "Temporal Logic" — Burgess-Xu Axiomatic System supplement.
