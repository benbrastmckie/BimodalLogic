import Bimodal.Metalogic.WeakCanonical.Kamp.PerFormulaType
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType

/-!
# The per-formula ∃∀-object `ExistsForallFormulaFin` and its `completions` bridge to `efSat`

**Purpose.** The production per-formula exists-forall object: an ∃∀-formula (Def 3.1, p.4)
whose point and interval types are **partial** types over the formula's own finite
mentioned-atom set `M` — bundled as a field — rather than total assignments to the whole
alphabet. This IS Def 3.1: the exists-forall formula is a finite formula, and `M` is exactly
the finite set of atoms it mentions. `efSatFin` is the literal Def 3.1 satisfaction on the
partial relations (`partialHolds` / `intervalHoldsFin`).

The **bridge** `efSatFin_iff_efSat_completions` connects `efSatFin` to the old total-type
satisfaction `efSat` on the finite alphabet: a per-formula object is satisfied iff SOME
selection of total completions of its point types yields a satisfied total
`ExistsForallFormula` whose interval clauses are the completion sets of the partial interval
clauses (`toTotal`). Every step routes through the single-type bridge
`intervalHolds_completions_iff` (`PerFormulaType.lean`); NO correctness statement is weakened.
Like `completions` itself, the bridge exists precisely WHILE `sigE` is finite (it takes
`[Fintype sig.preds]`) and is deleted at the switchover, BEFORE the summand flip makes `sigE`
infinite. `ExistsForallFormulaFin` / `efSatFin` themselves consume NO alphabet finiteness —
they survive the infinite E[Σ] of Def 4.1 (p.5).

Nothing here is imported by `KampPrior.lean` or the completeness spine; this module is
off-path until the switchover repoints the consumer chain.

## Reference grounding: Rabinovich PDF page → repo construct

| Rabinovich (PDF) | Statement | This module |
|---|---|---|
| Def 3.1, p.4 | ∃∀-formula: ordered points `x₀ < … < xₙ`, unary point types `αⱼ`, interval types `βⱼ`; each mentions finitely many atoms | `ExistsForallFormulaFin` (with `M` bundled) |
| Def 3.1, p.4 | satisfaction: witnesses realize the point types; interval types hold on the open segments | `efSatFin` |
| Prop 3.5, p.5 | a partial type = the finite set of its admissible completions | `toTotal`, `intervalHolds_biUnion_completions_iff` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet enumeration in the Fin layer | only the bridge (deleted at switchover) touches `completions` |

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1
  (p.5). Cited by PDF page; the companion markdown transcription is corrupt.
- `PerFormulaType.lean` (`UnaryTypeFin`, `partialHolds`, `IntervalTypeFin`,
  `intervalHoldsFin`, `completions`, `mem_completions`, `intervalHolds_completions_iff`);
  `ExistsForallFormula.lean` (`ExistsForallFormula`, `efSat`, `unaryHolds`, `intervalHolds`);
  `IntervalType.lean` (`efSat_interval_iff`).
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

/-! ## 2. The completion map to the total object (bridge side; finite alphabet only) -/

open Classical in
/-- The **total completion sets** of a partial interval type: the union of the completion
sets of its members. A point satisfies it (totally) iff it satisfies the partial interval
type (partially) — `intervalHolds_biUnion_completions_iff`. Exists only WHILE `sigE` is
finite; deleted at the switchover together with `completions`. -/
noncomputable def completionsSet [Fintype sig.preds] [DecidableEq sig.preds]
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) : IntervalType sig F :=
  S.biUnion completions

open Classical in
/-- **Interval-clause bridge.** A point totally satisfies the completion sets of `S` iff it
partially satisfies `S`. Routes through the single-type bridge
`intervalHolds_completions_iff`. -/
theorem intervalHolds_biUnion_completions_iff [Fintype sig.preds] [DecidableEq sig.preds]
    (N : OrderedMonadicStructure (sigE sig F))
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) (y : N.carrier) :
    intervalHolds N (completionsSet S) y ↔ intervalHoldsFin N S y := by
  classical
  simp only [completionsSet, intervalHolds, intervalHoldsFin, Finset.mem_biUnion]
  constructor
  · rintro ⟨τ, ⟨c, hcS, hτc⟩, hτy⟩
    exact ⟨c, hcS,
      (intervalHolds_completions_iff N c y).mp ⟨τ, hτc, hτy⟩⟩
  · rintro ⟨c, hcS, hcy⟩
    obtain ⟨τ, hτc, hτy⟩ := (intervalHolds_completions_iff N c y).mpr hcy
    exact ⟨τ, ⟨c, hcS, hτc⟩, hτy⟩

open Classical in
/-- The **total counterpart** of a per-formula ∃∀-object under a chosen completion of each
point type: same skeleton (`n`, `pin`), point types replaced by the chosen total completions,
interval types replaced by their completion sets. Exists only WHILE `sigE` is finite; deleted
at the switchover. -/
noncomputable def ExistsForallFormulaFin.toTotal [Fintype sig.preds] [DecidableEq sig.preds]
    {r : Nat} (ψ : ExistsForallFormulaFin sig F r)
    (choice : Fin (ψ.n + 1) → UnaryType sig F) : ExistsForallFormula sig F r where
  n := ψ.n
  pin := ψ.pin
  pointType := choice
  intervalType := fun i => completionsSet (ψ.intervalType i)

/-! ## 3. The bridge: `efSatFin` ↔ `efSat` via completions -/

/-- **The `efSat` bridge (finite alphabet only; deleted at the switchover).** A per-formula
∃∀-object is satisfied iff SOME selection of total completions of its point types yields a
satisfied total `ExistsForallFormula` (`toTotal`). Forward: complete each witness point's
partial type by a realized total completion (choice from `intervalHolds_completions_iff`).
Backward: restrict the chosen completions back to the mentioned atoms. NO correctness
statement is weakened — both sides are the literal Def 3.1 satisfaction of their respective
objects, and every point/interval clause is transported by the one-type bridge lemmas. -/
theorem efSatFin_iff_efSat_completions [Fintype sig.preds] [DecidableEq sig.preds]
    {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) :
    efSatFin N env ψ ↔
      ∃ choice : Fin (ψ.n + 1) → UnaryType sig F,
        (∀ j : Fin (ψ.n + 1), choice j ∈ completions (ψ.pointType j)) ∧
        efSat N env (ψ.toTotal choice) := by
  classical
  constructor
  · intro h
    rw [efSatFin_interval_iff] at h
    obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
    have h_all : ∀ j : Fin (ψ.n + 1),
        ∃ τ ∈ completions (ψ.pointType j), unaryHolds N τ (x j) := by
      intro j
      exact (intervalHolds_completions_iff N (ψ.pointType j) (x j)).mpr (hpt j)
    choose choice hmem hhold using h_all
    refine ⟨choice, hmem, ?_⟩
    rw [efSat_interval_iff]
    refine ⟨x, hmono, hpin, ?_, ?_, ?_, ?_⟩
    · intro j
      exact hhold j
    · intro y hy
      exact (intervalHolds_biUnion_completions_iff N (ψ.intervalType 0) y).mpr (hbefore y hy)
    · intro i y hy1 hy2
      exact (intervalHolds_biUnion_completions_iff N
        (ψ.intervalType i.succ.castSucc) y).mpr (hbetween i y hy1 hy2)
    · intro y hy
      exact (intervalHolds_biUnion_completions_iff N
        (ψ.intervalType (Fin.last (ψ.n + 1))) y).mpr (hafter y hy)
  · rintro ⟨choice, hmem, h⟩
    rw [efSat_interval_iff] at h
    obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
    rw [efSatFin_interval_iff]
    refine ⟨x, hmono, hpin, ?_, ?_, ?_, ?_⟩
    · intro j
      exact (intervalHolds_completions_iff N (ψ.pointType j) (x j)).mp
        ⟨choice j, hmem j, hpt j⟩
    · intro y hy
      exact (intervalHolds_biUnion_completions_iff N (ψ.intervalType 0) y).mp (hbefore y hy)
    · intro i y hy1 hy2
      exact (intervalHolds_biUnion_completions_iff N
        (ψ.intervalType i.succ.castSucc) y).mp (hbetween i y hy1 hy2)
    · intro y hy
      exact (intervalHolds_biUnion_completions_iff N
        (ψ.intervalType (Fin.last (ψ.n + 1))) y).mp (hafter y hy)

end Bimodal.Metalogic.WeakCanonical.Kamp
