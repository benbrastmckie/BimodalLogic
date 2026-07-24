import Bimodal.Metalogic.WeakCanonical.Kamp.PerFormulaType
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType

/-!
# The per-formula ∃∀-object `ExistsForallFormulaFin`

**Purpose.** The production per-formula exists-forall object: an ∃∀-formula (Def 3.1, p.4)
whose point and interval types are **partial** types over the formula's own finite
mentioned-atom set `M` — bundled as a field — rather than total assignments to the whole
alphabet. This IS Def 3.1: the exists-forall formula is a finite formula, and `M` is exactly
the finite set of atoms it mentions. `efSatFin` is the literal Def 3.1 satisfaction on the
partial relations (`partialHolds` / `intervalHoldsFin`).

`ExistsForallFormulaFin` / `efSatFin` consume NO alphabet finiteness — they survive the
infinite E[Σ] of Def 4.1 (p.5). The finite-alphabet `completions` bridge
(`efSatFin_iff_efSat_completions` / `toTotal` / `completionsSet`) that connected `efSatFin`
to the old total-type satisfaction `efSat` during the additive migration was DELETED at the
switchover, together with `completions` itself (`PerFormulaType.lean`): the Fin layer is
self-contained and every consumer is on the Fin variants.

Nothing here is imported by `KampPrior.lean` or the completeness spine; this module is
off-path until the ζ re-wire repoints the consumer chain.

## Reference grounding: Rabinovich PDF page → repo construct

| Rabinovich (PDF) | Statement | This module |
|---|---|---|
| Def 3.1, p.4 | ∃∀-formula: ordered points `x₀ < … < xₙ`, unary point types `αⱼ`, interval types `βⱼ`; each mentions finitely many atoms | `ExistsForallFormulaFin` (with `M` bundled) |
| Def 3.1, p.4 | satisfaction: witnesses realize the point types; interval types hold on the open segments | `efSatFin` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet enumeration in the Fin layer | no declaration here touches `Finset.univ` at `UnaryType` |

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Def 4.1 (p.5). Cited by PDF
  page; the companion markdown transcription is corrupt.
- `PerFormulaType.lean` (`UnaryTypeFin`, `partialHolds`, `IntervalTypeFin`,
  `intervalHoldsFin`); `IntervalType.lean` (partial interval-type algebra).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The per-formula ∃∀-object (Def 3.1, p.4, with `M` bundled) -/

/-- An ∃∀-formula over `sigE sig F` with `r` free variables, on the **per-formula finite**
representation: the mentioned-atom set `M` is bundled, and all point/interval types are
partial types over `M`. `n` gives `n+1` ordered existential points; `pin` pins each free
variable to a point; `pointType j` is `αⱼ`; `intervalType` carries `β₀` (slot `0`, before
`x₀`), the `βᵢ` on `(x_{i-1}, xᵢ)` (slots `1..n`), and `β_{n+1}` (slot `n+1`, after `xₙ`).
This is Def 3.1 (p.4) with the finite mentioned-atom set made explicit — no structure field
consumes any alphabet finiteness. -/
structure ExistsForallFormulaFin (sig : MonadicSignature) (F : Finset Formula)
    (r : Nat) where
  /-- `n+1` ordered existential points `x₀ < … < xₙ`. -/
  n : Nat
  /-- The finite mentioned-atom set of this formula (Def 3.1: a finite formula mentions
      finitely many atoms). -/
  M : Finset (AtomKind (sigE sig F) 1)
  /-- Free variable `z_k` is pinned to existential point `x_{pin k}`. -/
  pin : Fin r → Fin (n + 1)
  /-- The partial unary point type `αⱼ` asserted at `xⱼ`. -/
  pointType : Fin (n + 1) → UnaryTypeFin sig F M
  /-- The partial interval types: slot `0` before `x₀`, slot `i` on `(x_{i-1}, xᵢ)` for
      `1 ≤ i ≤ n`, slot `n+1` after `xₙ`. -/
  intervalType : Fin (n + 2) → IntervalTypeFin sig F M

/-- Satisfaction of the per-formula ∃∀-object: there exist `n+1` strictly increasing witness
points such that each free variable equals its pinned point, each point type is realized
(`partialHolds`), and the before/between/after interval types hold along their open intervals
(`intervalHoldsFin`). The literal Def 3.1 (p.4) reading on the partial relations. -/
def efSatFin {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) : Prop :=
  ∃ x : Fin (ψ.n + 1) → N.carrier,
    StrictMono x ∧
    (∀ k : Fin r, env k = x (ψ.pin k)) ∧
    (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (x j)) ∧
    (∀ y : N.carrier, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
    (∀ (i : Fin ψ.n) (y : N.carrier),
        x i.castSucc < y → y < x i.succ →
          intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
    (∀ y : N.carrier, x (Fin.last ψ.n) < y →
        intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y)

/-- `efSatFin` in explicit interval form (definitional unfolding; the analog of
`efSat_interval_iff`). -/
theorem efSatFin_interval_iff {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) :
    efSatFin N env ψ ↔
      ∃ x : Fin (ψ.n + 1) → N.carrier,
        StrictMono x ∧
        (∀ k : Fin r, env k = x (ψ.pin k)) ∧
        (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (x j)) ∧
        (∀ y : N.carrier, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
        (∀ (i : Fin ψ.n) (y : N.carrier),
            x i.castSucc < y → y < x i.succ →
              intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
        (∀ y : N.carrier, x (Fin.last ψ.n) < y →
            intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y) := by
  simp only [efSatFin]

end Bimodal.Metalogic.WeakCanonical.Kamp
