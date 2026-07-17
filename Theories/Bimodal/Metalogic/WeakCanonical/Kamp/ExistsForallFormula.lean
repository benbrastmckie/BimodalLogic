import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion

/-!
# The ∃∀-Formula Object (Rabinovich Definition 3.1, PDF p.4)

The ordered-existential-prefix object that replaces `NormalForm sig k n` on the completeness
spine. An ∃∀-formula over a signature is, per Def 3.1 (p.4), a formula of the form

```
ψ(z₀,…,z_m) := ∃xₙ…∃x₁∃x₀
    (⋀_{k=0}^m z_k = x_{i_k}) ∧ (xₙ > x_{n-1} > … > x₁ > x₀)
  ∧ ⋀_{j=0}^n αⱼ(xⱼ)                         -- each αⱼ holds at xⱼ
  ∧ ⋀_{j=1}^n (∀y)_{>x_{j-1}}^{<x_j} βⱼ(y)    -- each βⱼ holds along (x_{j-1}, xⱼ)
  ∧ (∀y)_{>xₙ} β_{n+1}(y)                     -- β_{n+1} holds everywhere after xₙ
  ∧ (∀y)^{<x₀} β₀(y)                          -- β₀ holds everywhere before x₀
```

with a prefix of `n+1` existential quantifiers, all `αⱼ, βⱼ` **quantifier-free with one
variable**, and pinning indices `i₀,…,i_m ∈ {0,…,n}`.

## Encoding

The load-bearing faithfulness point (the reason the whole re-architecture works) is that the
`αⱼ, βⱼ` are **unary** — quantifier-free with a single variable. A quantifier-free unary type
over the E[Σ] alphabet is exactly `NormalForm (sigE sig F) 0 1` (depth 0, one free variable; over
`Fin 1` there are no order atoms, so it is a truth assignment to the unary E[Σ] predicates at the
point). Representing every point/interval type this way makes each constraint **arity 1**, so no
joint type over several points is ever formed — this is the structural source of Lemma 3.2(2)'s
≤2-free-variable cap (Phase 4), and the reason processed depth folds into E[Σ] atoms rather than
accumulating as arity.

The free variables `z₀,…,z_m` are **pinned** to the ordered existential points by
`pin : Fin r → Fin (n+1)` (`r = m+1` free variables), so they are not independent arity: the
object's arity is capped by construction.

- `numPoints`-style indexing: there are `n+1` points `x₀,…,xₙ` (`Fin (n+1)`), and `n+2` interval
  slots `Fin (n+2)`: slot `0` is "before x₀", slot `i` (`1 ≤ i ≤ n`) is the open interval
  `(x_{i-1}, xᵢ)`, and slot `n+1` is "after xₙ".

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 3.1 (p.4). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `ESigmaExpansion.lean`: the E[Σ] alphabet `sigE` and canonical expansion `canonExpand`.
- `NormalForm.lean`: `NormalForm`, `nf_eval_nf`, `AtomKind`, `atom_eval`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

/-! ## 1. Quantifier-free unary types and their satisfaction -/

/-- A quantifier-free unary type over the E[Σ] alphabet: a depth-0 normal form with one free
variable. Over `Fin 1` there are no order atoms, so this is precisely a truth assignment to the
unary E[Σ] predicates at a single point (the `αⱼ`/`βⱼ` of Def 3.1). -/
abbrev UnaryType (sig : MonadicSignature) (F : Finset Formula) : Type :=
  NormalForm (sigE sig F) 0 1

/-- A point `p` **realizes** the unary type `τ`: every E[Σ] atom at `p` matches `τ`'s assignment.
This is `nf_eval_nf` at depth 0 with the constant environment `fun _ => p`. -/
def unaryHolds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryType sig F) (p : N.carrier) : Prop :=
  nf_eval_nf N 0 1 (fun _ => p) τ

/-- Unfolding lemma: realizing `τ` at `p` is atom-wise agreement with `τ`. -/
theorem unaryHolds_iff {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (τ : UnaryType sig F) (p : N.carrier) :
    unaryHolds N τ p ↔
      ∀ a : AtomKind (sigE sig F) 1, atom_eval N (fun _ => p) a ↔ (τ a = true) :=
  Iff.rfl

/-! ## 2. The ∃∀-formula object (Def 3.1, p.4) -/

/--
An ∃∀-formula over `sigE sig F` with `r` free variables. `n` gives `n+1` ordered existential
points; `pin` pins each free variable to a point; `pointType j` is `αⱼ`; `intervalType` carries
`β₀` (slot `0`, before `x₀`), the `βᵢ` on `(x_{i-1}, xᵢ)` (slots `1..n`), and `β_{n+1}`
(slot `n+1`, after `xₙ`). All types are unary — the arity cap is structural.
-/
structure ExistsForallFormula (sig : MonadicSignature) (F : Finset Formula) (r : Nat) where
  /-- `n+1` ordered existential points `x₀ < … < xₙ`. -/
  n : Nat
  /-- Free variable `z_k` is pinned to existential point `x_{pin k}`. -/
  pin : Fin r → Fin (n + 1)
  /-- The quantifier-free unary point type `αⱼ` asserted at `xⱼ`. -/
  pointType : Fin (n + 1) → UnaryType sig F
  /-- The quantifier-free unary interval types: slot `0` before `x₀`, slot `i` on
      `(x_{i-1}, xᵢ)` for `1 ≤ i ≤ n`, slot `n+1` after `xₙ`. -/
  intervalType : Fin (n + 2) → UnaryType sig F

/-! ## 3. Satisfaction of the ∃∀-object -/

/--
Satisfaction of an ∃∀-formula in an expanded structure `N` under environment `env`. There exist
`n+1` strictly increasing witness points `x₀ < … < xₙ` such that: each free variable equals its
pinned point; each `αⱼ` holds at `xⱼ`; the before/between/after interval types hold along their
open intervals. This is the literal reading of Def 3.1 (p.4).
-/
def efSat {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) : Prop :=
  ∃ x : Fin (ψ.n + 1) → N.carrier,
    StrictMono x ∧
    (∀ k : Fin r, env k = x (ψ.pin k)) ∧
    (∀ j : Fin (ψ.n + 1), unaryHolds N (ψ.pointType j) (x j)) ∧
    (∀ y : N.carrier, y < x 0 → unaryHolds N (ψ.intervalType 0) y) ∧
    (∀ (i : Fin ψ.n) (y : N.carrier),
        x i.castSucc < y → y < x i.succ → unaryHolds N (ψ.intervalType i.succ.castSucc) y) ∧
    (∀ y : N.carrier, x (Fin.last ψ.n) < y →
        unaryHolds N (ψ.intervalType (Fin.last (ψ.n + 1))) y)

/-! ## 4. Basic structural facts -/

/-- The witness points of a satisfied ∃∀-formula are strictly increasing (hence pairwise
distinct): the ordered existential prefix `xₙ > … > x₀` of Def 3.1. -/
theorem efSat_strictMono {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (h : efSat N env ψ) :
    ∃ x : Fin (ψ.n + 1) → N.carrier, StrictMono x ∧ (∀ k, env k = x (ψ.pin k)) := by
  obtain ⟨x, hmono, hpin, _⟩ := h
  exact ⟨x, hmono, hpin⟩

/-- Each free variable of a satisfied ∃∀-formula sits at its pinned existential point; in
particular the free variables are not independent of the ordered points (the pinning of
Def 3.1). -/
theorem efSat_pinned {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r)
    (h : efSat N env ψ) (k : Fin r) :
    ∃ x : Fin (ψ.n + 1) → N.carrier, env k = x (ψ.pin k) := by
  obtain ⟨x, _, hpin, _⟩ := h
  exact ⟨x, hpin k⟩

end Bimodal.Metalogic.WeakCanonical
