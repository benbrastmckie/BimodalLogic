# Teammate B Findings: Inconsistent Case Analysis

**Task**: 107 -- Chain Design Diagnostics for Representation Theorem
**Date**: 2026-04-29
**Focus**: Can the inconsistent case in `g_content(A) ⊆ B` be ruled out?
**Verdict**: NO -- the inconsistent case is semantically realizable on non-dense frames and therefore cannot be refuted in the base BX axiom system.

---

## 1. Problem Statement

Given:
- `G(φ) ∈ A` (i.e., φ ∈ g_content(A))
- `φ ∉ B`
- `¬φ ∈ B` (the inconsistent case: {φ}∪B is inconsistent because B is DCS)
- `BurgessR3Maximal(A, B, C)`
- `g_content(A) ⊆ C`

**Goal**: Derive ⊥ (show this situation is impossible).

---

## 2. Definitive Semantic Analysis

### The inconsistent case IS realizable on non-dense frames

Consider a frame with exactly two time points: t < t', where t' is the immediate successor of t (no points between them).

- A = MCS at t, with G(φ) ∈ A (φ holds at all strict future of t, i.e., at t' and beyond)
- C = MCS at t', with φ ∈ C (from g_content(A) ⊆ C)
- B = DCS for the interval (t, t')

Since (t, t') is EMPTY (no intermediate points), B represents constraints on the empty interval. The formula ¬φ ∈ B means "¬φ holds throughout (t, t')", which is vacuously true.

The burgessRSet condition: for all β ∈ B, γ ∈ C: untl(β, γ) ∈ A. Under open guard, untl(β, γ) at t means ∃s > t: γ(s) ∧ β on (t, s). With s = t': γ(t') holds (γ ∈ C at t'), and β on (t, t') is vacuously true (empty interval). So untl(β, γ) is true at t for ANY β, including ¬φ.

Similarly, burgessRSetSince works: snce(β, α) ∈ C means ∃s < t': α(s) ∧ β on (s, t'). With s = t: α(t) holds (α ∈ A), and β on (t, t') is vacuously true.

The maximality of B: any proper DCS extension D ⊃ B with consistency fails burgessR3(A, D, C). This can hold because the maximality quantifies over proper DCS extensions, and the specific extensions that would witness non-maximality are inconsistent.

**Conclusion**: There exist models where G(φ) ∈ A, ¬φ ∈ B, BurgessR3Maximal(A, B, C), and g_content(A) ⊆ C all hold simultaneously. The inconsistent case is satisfiable.

### Why dense frames prevent it

On dense frames, (t, t') is always nonempty for t < t'. G(φ) at t gives φ at all u ∈ (t, t'). So ¬φ cannot hold throughout (t, t'). The inconsistent case is unsatisfiable on dense frames.

---

## 3. Exhaustive Derivation Attempts (All Failed)

### Attempt 1: left_mono_until_G + BX10

From ¬φ ∈ B + burgessRSet: untl(¬φ, γ) ∈ A for all γ ∈ C.
From G(φ) ∈ A: G(¬φ → ⊥) ∈ A (since φ → (¬φ → ⊥) is a tautology, apply TG + temp_k_dist).
By left_mono_until_G: untl(⊥, γ) ∈ A for all γ ∈ C.
By BX10: F(γ) ∈ A for all γ ∈ C.

**Dead end**: untl(⊥, γ) is satisfiable on non-dense frames (empty guard interval).

### Attempt 2: BX7 (linearity) to collapse

untl(⊥, γ₁) ∧ untl(⊥, γ₂) via BX7 gives a three-way disjunction. Two disjuncts reduce to untl(⊥, ⊥) which is refutable (F(⊥) contradicts G(⊤)). But the first disjunct untl(⊥, γ₁∧γ₂) survives. No contradiction.

### Attempt 3: temp_4 + enrichment in C

From G(φ) ∈ A, by temp_4: G(G(φ)) ∈ A, so G(φ) ∈ g_content(A) ⊆ C.
From burgessRSetSince: snce(¬φ, α) ∈ C for all α ∈ A.
Apply BX13' in C with p = G(φ): snce(¬φ, α ∧ untl(¬φ, G(φ))) ∈ C.

The sub-formula untl(¬φ, G(φ)) is semantically contradictory on dense frames (¬φ guard with G(φ) event), but syntactically satisfiable on non-dense frames (empty guard interval). No contradiction.

### Attempt 4: BX13 enrichment in A

Apply BX13 in A with p = G(φ), phi = ¬φ, psi = γ:
untl(¬φ, γ ∧ snce(¬φ, G(φ))) ∈ A.

Again: snce(¬φ, G(φ)) is semantically contradictory on dense frames (G(φ) at past s gives φ throughout (s,t), contradicting ¬φ guard), but satisfiable on non-dense frames.

### Attempt 5: left_mono_since_H via H(φ) ∈ C

To use left_mono_since_H on snce(¬φ, α) in C: need H(¬φ → ⊥) = H(φ) ∈ C.
From g_content(A) ⊆ C duality: h_content(C) ⊆ A. If H(φ) ∈ C then φ ∈ h_content(C) ⊆ A.
But we cannot show H(φ) ∈ C. From φ ∈ C: BX4' gives H(F(φ)) ∈ C, not H(φ).
G and H are independent operators (future vs past). No axiom connects them.

### Attempt 6: BurgessR3Maximal_extension_fails on Set.univ

When {φ}∪B is inconsistent, DC({φ}∪B) = Set.univ. But Set.univ is not a DCS (it's inconsistent). The maximality condition only quantifies over SetDeductivelyClosed extensions, which require consistency. So the condition gives NO information in this case.

### Attempt 7: Xu 2.3 approach for P(α) ∈ B

Same problem. If P(α) ∉ B and {P(α)}∪B inconsistent: H(¬α) ∈ B. From G(P(α)) ∈ A (via BX4): G(H(¬α) → ⊥) ∈ A. By left_mono_until_G: untl(⊥, γ) ∈ A. Same dead end.

---

## 4. Root Cause Analysis

The BX axiom system axiomatizes ALL linear temporal orders (dense, discrete, and mixed). On discrete frames, immediate successors create empty open intervals (t, s) = {} where the guard of Until/Since is vacuously satisfied. This makes formulas like `untl(⊥, γ)` satisfiable (guard ⊥ on empty interval is vacuous, event γ at immediate successor suffices).

The formula `g_content(A) ⊆ B` is a property that holds ONLY on dense frames. On non-dense frames, it can fail: the interval DCS B can contain ¬φ for G(φ) ∈ A because the interval is empty.

Since BX proves only formulas valid on ALL frames, `g_content(A) ⊆ B` is not provable.

---

## 5. Why g_content(A) ⊆ C IS Provable but g_content(A) ⊆ B Is Not

g_content(A) ⊆ C works because G(φ) ∈ A semantically means φ at all strict future of t, including at t' (the right endpoint). This holds on ALL frames (t < t' always, regardless of density).

g_content(A) ⊆ B fails because B represents the OPEN interval (t, t'), and on non-dense frames this interval can be empty. The semantic content of B is "formulas true throughout (t, t')", which is vacuously everything when (t, t') = {}.

This is the fundamental asymmetry: endpoints are always reachable (G(φ) at t gives φ at t'), but intervals can be empty.

---

## 6. Implications for the Codebase

### What cannot work
- The extension-based proof of `g_content_sub_B_of_BurgessR3Maximal` (current approach)
- Any attempt to derive ⊥ from the inconsistent case using only BX axioms
- Xu 2.3 (P(α) ∈ B) in its full generality under BX

### What CAN work

**Option A: Add a density axiom** such as `untl(⊥, γ) → ⊥` or equivalently `G(G(φ)) → G(φ)`. This makes the inconsistent case trivially contradictory: `untl(⊥, γ) ∈ A` and `⊢ untl(⊥, γ) → ⊥` gives `⊥ ∈ A`. The axiom is sound on dense linear orders (the intended frame class for Q-based chronicles).

Cost: Changes the axiom system from "all linear orders" to "dense linear orders". Requires soundness proof update and match arm additions.

**Option B: Restructure to avoid g_content(A) ⊆ B entirely**. The Xu 2.4 approach (described in report 46_density-analysis.md) constructs D from B ∪ {β.neg} and uses the Burgess 2.3 equivalence (already in codebase) to establish r(A, ⊤, D) and r(D, ⊤, C). However, establishing these still requires P(α) ∈ D for all α ∈ A, which requires P(α) ∈ B (Xu 2.3), which has the same inconsistent-case problem.

**Option C: Two-phase approach**. Prove the consistent case only (already done in codebase). For the inconsistent case, add a density axiom scoped to the chronicle construction. This is the minimal change.

**Option D: Semantic shortcut via soundness**. If soundness is fully established, prove consistency of the seed set semantically (it's satisfiable on Q, hence consistent by soundness). This bypasses the syntactic proof entirely.

### Recommendation

Option A (density axiom) is the cleanest path. The axiom `untl(⊥, γ) → ⊥` (or equivalently `G(G(φ)) → G(φ)`) is:
- Sound on dense linear orders (3-line proof)
- Directly resolves the blocker (1-line proof of the inconsistent case)
- Needed only in `g_content_sub_B_of_BurgessR3Maximal` and its dual
- Compatible with the rest of the BX axiom system

The axiom `G(G(φ)) → G(φ)` is already declared with a sorry in `density_derivable` (TemporalDerived.lean:143), suggesting it was anticipated as part of the system.

---

## 7. Summary

| Question | Answer |
|----------|--------|
| Can the inconsistent case be ruled out in BX? | **NO** -- semantically realizable on non-dense frames |
| Is g_content(A) ⊆ B true on all frames? | **NO** -- fails on non-dense frames |
| Is g_content(A) ⊆ B true on dense frames? | **YES** -- (t,t') nonempty prevents vacuous satisfaction |
| Is there a BX proof? | **NO** -- BX proves only frame-universal validities |
| What's needed? | Density axiom or restructured proof strategy |
| Minimal change? | Add `density_axiom : untl(⊥, γ) → ⊥` to Axioms.lean |
