/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.LiftPair
import FormalSystem.Metalogic.WeakCanonical.Kamp.EFSatNegation
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35Assembly

/-!
# General `∃∀`-object negation at the `∨∃∀` type (Rabinovich Prop 4.3, ¬-case, PDF p.6) — assembly

This module assembles `efSat_negation_general` (β at the `VeeExistsForall` type): the negation
`¬ efSat N env ψ` of a general `r`-free-variable `∃∀`-object realized as a `VeeExistsForall` (`∨∃∀`)
object, with capture discharged DIRECTLY (`capTypeFin` under the atom-naming premise `hNamed` —
every readback IS an atom of the infinite expansion), off the live import path.

## Strategy (Prop 4.3, ¬-case, p.6) and what is landed here

The De Morgan decomposition `efSat_negation_demorgan` (`EFSatNegation.lean`) gives
```
¬ efSat N env ψ ↔ (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2)
                    ∨ ¬ efSat N ![] (existenceSentence ψ)
```
where `pairwiseProjections ψ` ranges over **all** ordered pairs `(k, l) ∈ Fin r × Fin r`. The
assembly
splits this into three pair classes:

- **`k < l` (main case):** `efSat_negation_pair` gives a `VeeExistsForall sig F 2` negation object,
  lifted to arity `r` by `liftPairV` (`liftPairV_iff`, gate `k < l` from `StrictMono env`). LANDED.
- **`k > l` (redundant):** folded to its `l < k` counterpart by `pairProject_swap_efSat`. LANDED.
- **`k = l` (diagonal):** a genuine one-free-variable condition. Reduced here (`diagProject`,
  `diagProject_efSat_iff`, LANDED green) to `¬ efSat N ![env k] (diagProject ψ k)`, then negated by
  the arity-1 negation object `efSat_negation_diagonal` and lifted by `liftSingleV`
  (`liftSingleV_iff`, no order gate). LANDED lifts; the arity-1 negation object is a strategic
  sorry.
- **Existence sentence (`r = 0`):** negated by the arity-0 negation object
`efSat_negation_existence`
  and lifted by `liftSentenceV` (`liftSentenceV_iff`, LANDED green here).

## Status

The two low-arity negation objects are now **LANDED sorry-free** (axiom-clean). No reverse Prop 3.5
syntactic map (`Formula → VeeExistsForall sig F 1`) was needed: the reverse direction is discharged
*semantically* by the direct capture + degenerate single-point objects (`pointEF1`, `univSentence`)
disjoined
over admissible completions — the same device the landed arity-2 `vvecea2_collapse_bridge` uses.

1. `efSat_negation_diagonal` — arity-1 negation object. **LANDED** (capture + `pointEF1` route).
2. `efSat_negation_existence` — arity-0 negation object. **LANDED** (capture + `univSentence` +
   order-trichotomy route). Gained a mandatory `Nonempty N.carrier` hypothesis: the theorem is
   provably FALSE on an empty carrier (see its docstring).
3. `efSat_negation_general` — the trichotomy assembly over `pairwiseProjections` chaining
   `veeSat_append`/`veeSat_flatMap` + the three class lemmas + the `k > l` symmetry fold + the
   `efSat_negation_demorgan` decomposition, consuming 1 and 2. **LANDED sorry-free** (axiom-clean
   `[propext, Classical.choice, Quot.sound]`); threads `hne` to supply `efSat_negation_existence`
   at the Phase-ζ discharge site.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Prop 4.3 ¬-case (PDF p.6), Prop 3.5 (p.5).
Cited by
  PDF page; the companion markdown transcription is corrupt.
- `EFSatNegation.lean`: `efSat_negation_pair`, `efSat_negation_demorgan`, `pairProject_swap_efSat`.
- `LiftPair.lean`: `liftPairV`/`liftPairV_iff`, `liftSingleV`/`liftSingleV_iff`,
  `liftSentence`/`liftSentence_iff`.
- `Prop35Assembly.lean` / `Prop35ExistsForall.lean` / `Prop35VeeLift.lean`: the forward Prop 3.5
  translation (`translateProp35_correct`, arity 1) — the reverse of which the arity-1 negation
  object
  requires.

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **Order-trichotomy bridge.** On a nonempty linear order, a predicate `Q` holding at some point
together with everywhere strictly-below and strictly-above that point is equivalent to `Q` holding
everywhere. The ⟸ direction needs a nonemptiness anchor; ⟹ uses `lt_trichotomy`. Instance-free
(`omit`): consumed by the Fin layer below. -/
theorem order_point_forall_iff (N : OrderedMonadicStructure (sigE sig F))
    (hne : Nonempty N.carrier) (Q : N.carrier → Prop) :
    (∃ x0 : N.carrier, Q x0 ∧ (∀ y, y < x0 → Q y) ∧ (∀ y, x0 < y → Q y)) ↔ ∀ z, Q z := by
  constructor
  · rintro ⟨x0, hx0, hb, ha⟩ z
    rcases lt_trichotomy z x0 with h | h | h
    · exact hb z h
    · exact h ▸ hx0
    · exact ha z h
  · intro h
    obtain ⟨a⟩ := hne
    exact ⟨a, h a, fun y _ => h y, fun y _ => h y⟩

section FinLayer

/- The Fin layer below deliberately takes NO `Fintype sig.preds` / `DecidableEq sig.preds`:
everything is stated on the per-formula representation. -/
variable {sig₀ : MonadicSignature} {F₀ : Finset Formula}

/-! ## 5. Fin layer: degenerate single-point per-formula objects

Fin counterparts of section 2a on `ExistsForallFormulaFin` (`PerFormulaExistsForall.lean`): the
mentioned-atom set `M` is bundled per object, the caps use the `M`-relative top
`intervalTopFin` (`IntervalType.lean`), and satisfaction collapses to the partial relations
`partialHolds`/`intervalHoldsFin`. NO alphabet instances, NO full-alphabet `Finset.univ`
(the `intervalTopFin` universe is over `UnaryTypeFin _ _ M`, per-formula-finite). -/

/-- Fin-variant of `pointEF1`: one existential point (`n := 0`), the single free variable
pinned to it, partial point type `τ` over `M`, both unbounded caps trivial (`intervalTopFin`).
Its `efSatFin` collapses to `partialHolds N τ (env 0)` (`pointEF1Fin_efSat`). -/
noncomputable def pointEF1Fin {M : Finset (AtomKind (sigE sig₀ F₀) 1)}
    (τ : UnaryTypeFin sig₀ F₀ M) : ExistsForallFormulaFin sig₀ F₀ 1 where
  n := 0
  M := M
  pin := ![0]
  pointType := ![τ]
  intervalType := ![intervalTopFin M, intervalTopFin M]

/-- Fin-variant of `pointEF1_efSat`: the degenerate single-point per-formula object holds at
`env` exactly when its partial point type is realized at `env 0`. -/
theorem pointEF1Fin_efSat (N : OrderedMonadicStructure (sigE sig₀ F₀))
    {M : Finset (AtomKind (sigE sig₀ F₀) 1)}
    (τ : UnaryTypeFin sig₀ F₀ M) (env : Fin 1 → N.carrier) :
    efSatFin N env (pointEF1Fin τ) ↔ partialHolds N τ (env 0) := by
  constructor
  · rintro ⟨x, _, hpin, hpt, _, _, _⟩
    have h0 := hpt 0
    have hp0 := hpin 0
    simp only [pointEF1Fin, Matrix.cons_val_zero] at h0 hp0
    rw [hp0]; exact h0
  · intro h
    haveI : Subsingleton (Fin ((pointEF1Fin τ).n + 1)) :=
      inferInstanceAs (Subsingleton (Fin 1))
    refine ⟨fun _ => env 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact absurd (Subsingleton.elim a b) (ne_of_lt hab)
    · intro k
      rw [Subsingleton.elim k 0]
    · intro j
      rw [Subsingleton.elim j 0]
      simpa [pointEF1Fin] using h
    · intro y _
      simpa [pointEF1Fin] using intervalHoldsFin_top N y
    · intro i; exact i.elim0
    · intro y _
      simpa [pointEF1Fin] using intervalHoldsFin_top N y

/-- Fin-variant of `pinFirst`: pin an arity-0 per-formula sentence to a single free variable
(same chain, same `M`, same partial point/interval types). -/
def pinFirstFin (ξ : ExistsForallFormulaFin sig₀ F₀ 0) : ExistsForallFormulaFin sig₀ F₀ 1 where
  n := ξ.n
  M := ξ.M
  pin := ![0]
  pointType := ξ.pointType
  intervalType := ξ.intervalType

/-- Fin-variant of `pinFirst_efSat`: an arity-0 per-formula sentence is satisfiable exactly
when its `pinFirstFin` pin is satisfiable for some anchor `z`. -/
theorem pinFirstFin_efSat (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (ξ : ExistsForallFormulaFin sig₀ F₀ 0) :
    efSatFin N ![] ξ ↔ ∃ z : N.carrier, efSatFin N ![z] (pinFirstFin ξ) := by
  constructor
  · rintro ⟨x, hmono, _, hpt, hb, hm, ha⟩
    refine ⟨x 0, x, hmono, ?_, hpt, hb, hm, ha⟩
    intro k
    rw [Subsingleton.elim k 0]
    simp [pinFirstFin]
  · rintro ⟨z, x, hmono, _, hpt, hb, hm, ha⟩
    exact ⟨x, hmono, fun k => k.elim0, hpt, hb, hm, ha⟩

/-- Fin-variant of `univSentence`: an arity-0 per-formula object with one existential point,
partial point type `τ`, and both unbounded caps carrying the captured `M`-relative set `S`. -/
def univSentenceFin {M : Finset (AtomKind (sigE sig₀ F₀) 1)}
    (τ : UnaryTypeFin sig₀ F₀ M) (S : IntervalTypeFin sig₀ F₀ M) :
    ExistsForallFormulaFin sig₀ F₀ 0 where
  n := 0
  M := M
  pin := Fin.elim0
  pointType := ![τ]
  intervalType := ![S, S]

/-- Fin-variant of `univSentence_efSat`: the single-point per-formula sentence holds exactly
when some `x0` realizes `τ` and the captured set `S` holds strictly below and strictly above
`x0` (all on the partial relations). -/
theorem univSentenceFin_efSat (N : OrderedMonadicStructure (sigE sig₀ F₀))
    {M : Finset (AtomKind (sigE sig₀ F₀) 1)}
    (τ : UnaryTypeFin sig₀ F₀ M) (S : IntervalTypeFin sig₀ F₀ M) :
    efSatFin N ![] (univSentenceFin τ S) ↔
      ∃ x0 : N.carrier, partialHolds N τ x0 ∧
        (∀ y : N.carrier, y < x0 → intervalHoldsFin N S y) ∧
        (∀ y : N.carrier, x0 < y → intervalHoldsFin N S y) := by
  constructor
  · rintro ⟨x, _, _, hpt, hb, _, ha⟩
    refine ⟨x 0, ?_, ?_, ?_⟩
    · simpa [univSentenceFin] using hpt 0
    · intro y hy
      simpa [univSentenceFin] using hb y hy
    · intro y hy
      simpa [univSentenceFin] using ha y hy
  · rintro ⟨x0, hτ, hb, ha⟩
    haveI : Subsingleton (Fin ((univSentenceFin τ S).n + 1)) :=
      inferInstanceAs (Subsingleton (Fin 1))
    refine ⟨fun _ => x0, ?_, fun k => k.elim0, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact absurd (Subsingleton.elim a b) (ne_of_lt hab)
    · intro j
      rw [Subsingleton.elim j 0]
      simpa [univSentenceFin] using hτ
    · intro y hy
      simpa [univSentenceFin] using hb y hy
    · intro i; exact i.elim0
    · intro y hy
      simpa [univSentenceFin] using ha y hy

/-! ## 6. Fin layer: the two low-arity negation objects

Fin counterparts of section 3 (Rabinovich Prop 3.5 negation-closure at arity 0/1, PDF p.5-6).
Capture is the direct `M`-relative `capTypeFin` (singleton mentioned-atom set — the readback
IS an atom of the infinite expansion), the only capture shape that exists without alphabet
finiteness, matching the bundled-`M` design of
`ExistsForallFormulaFin`. The forward translation is `translateProp35Fin_correct`
(`Prop35Assembly.lean` §5, THROUGH `unaryToFormulaFin`). `hNamed` is threaded, never
discharged. NOTE: the Fin general assembly (`efSat_negation_general` counterpart) additionally
needs the Fin lift wrappers (`liftPairV`/`liftSingleV`/`liftSentence`) and the Fin pair objects
(`pairProject`/`efSat_negation_pair`, `EFSatNegation.lean`) — those land with the
`LiftPair.lean` re-encode, not here. -/

/-- Fin-variant of `efSat_negation_diagonal` (arity-1 negation object). For a one-free-variable
per-formula `∃∀`-object `ξ`, a `VeeExistsForallFin sig F 1` realizing `¬ efSatFin N env ξ`:
translate forward (`translateProp35Fin_correct`), negate (`temporal_truth_neg`), capture the
negated truth-set `M`-relatively, and disjoin the degenerate single-point objects
`pointEF1Fin τ` over the admissible partial completions `τ ∈ S` — an `M`-relative enumeration,
never alphabet-sized. -/
theorem efSat_negation_diagonalFin
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (atomMap : Formula → (sigE sig₀ F₀).preds)
    (nameOf : (sigE sig₀ F₀).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F₀) A) y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormulaFin sig₀ F₀ 1) :
    ∃ Φ : VeeExistsForallFin sig₀ F₀ 1, ∀ env : Fin 1 → N.carrier,
      (veeSatFin N env Φ ↔ ¬ efSatFin N env ξ) := by
  set S := capTypeFin (esigmaPred (F := F₀) (translateProp35Fin atomMap nameOf ξ).neg) with hSdef
  have hS : ∀ y : N.carrier, intervalHoldsFin N S y ↔
      temporal_truth N atomMap y (translateProp35Fin atomMap nameOf ξ).neg :=
    fun y => capTypeFin_atomNamed N atomMap hNamed _ y
  refine ⟨S.toList.map (fun τ => pointEF1Fin τ), fun env => ?_⟩
  have hveeLHS : veeSatFin N env (S.toList.map (fun τ => pointEF1Fin τ)) ↔
      intervalHoldsFin N S (env 0) := by
    simp only [veeSatFin, List.mem_map, Finset.mem_toList, intervalHoldsFin]
    constructor
    · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩
      exact ⟨τ, hτ, (pointEF1Fin_efSat N τ env).mp hsat⟩
    · rintro ⟨τ, hτ, hu⟩
      exact ⟨pointEF1Fin τ, ⟨τ, hτ, rfl⟩, (pointEF1Fin_efSat N τ env).mpr hu⟩
  rw [hveeLHS, hS (env 0), temporal_truth_neg,
    translateProp35Fin_correct N atomMap nameOf hName env ξ]

/-- Fin-variant of `efSat_negation_existence` (arity-0 negation object). The
`Nonempty N.carrier` hypothesis is mandatory for the same reason as the total version (the
statement is false on an empty carrier). Construction: pin (`pinFirstFin`), translate forward
+ negate + capture `M`-relatively, and disjoin the universal single-point sentences
`univSentenceFin τ S` over `τ ∈ S`; `veeSatFin` collapses by order trichotomy
(`order_point_forall_iff`) to `∀ z, intervalHoldsFin N S z`. -/
theorem efSat_negation_existenceFin
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (atomMap : Formula → (sigE sig₀ F₀).preds)
    (nameOf : (sigE sig₀ F₀).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F₀) A) y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    (ξ : ExistsForallFormulaFin sig₀ F₀ 0) :
    ∃ Φ : VeeExistsForallFin sig₀ F₀ 0, veeSatFin N ![] Φ ↔ ¬ efSatFin N ![] ξ := by
  set S := capTypeFin
    (esigmaPred (F := F₀) (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg) with hSdef0
  have hS : ∀ y : N.carrier, intervalHoldsFin N S y ↔
      temporal_truth N atomMap y (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg :=
    fun y => capTypeFin_atomNamed N atomMap hNamed _ y
  refine ⟨S.toList.map (fun τ => univSentenceFin τ S), ?_⟩
  have hRHS : (¬ efSatFin N ![] ξ) ↔ (∀ z : N.carrier, intervalHoldsFin N S z) := by
    rw [pinFirstFin_efSat N ξ, not_exists]
    apply forall_congr'
    intro z
    rw [translateProp35Fin_correct N atomMap nameOf hName ![z] (pinFirstFin ξ), ←
        temporal_truth_neg,
      ← hS (![z] 0)]
    simp
  have hLHS : veeSatFin N ![] (S.toList.map (fun τ => univSentenceFin τ S)) ↔
      (∀ z : N.carrier, intervalHoldsFin N S z) := by
    rw [← order_point_forall_iff N hne (intervalHoldsFin N S)]
    have step : veeSatFin N ![] (S.toList.map (fun τ => univSentenceFin τ S)) ↔
        ∃ τ ∈ S, efSatFin N ![] (univSentenceFin τ S) := by
      simp only [veeSatFin, List.mem_map, Finset.mem_toList]
      constructor
      · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩; exact ⟨τ, hτ, hsat⟩
      · rintro ⟨τ, hτ, hsat⟩; exact ⟨univSentenceFin τ S, ⟨τ, hτ, rfl⟩, hsat⟩
    rw [step]
    simp only [univSentenceFin_efSat]
    constructor
    · rintro ⟨τ, hτ, x0, hτx0, hb, ha⟩
      exact ⟨x0, ⟨τ, hτ, hτx0⟩, hb, ha⟩
    · rintro ⟨x0, hx0, hb, ha⟩
      obtain ⟨τ, hτ, hτx0⟩ := hx0
      exact ⟨τ, hτ, x0, hτx0, hb, ha⟩
  rw [hLHS, hRHS]

/-! ## 7. Fin layer: diagonal reduction and disjunctive sentence lift

Fin counterparts of sections 1-2: the `k = l` diagonal of `pairwiseProjectionsFin` is a genuine
one-free-variable object, and the arity-0 negation object is lifted to arity `r` disjunct-wise
through `liftSentenceFin` (`LiftPair.lean` Fin section). No alphabet instances. -/

/-- Fin-variant of `diagProject`: the arity-1 diagonal projection of a per-formula
`∃∀`-formula at free variable `k` — same chain, mentioned-atom set `M`, and partial types,
pinning the single free variable to `x_{ψ.pin k}`. -/
def diagProjectFin {r : Nat} (ψ : ExistsForallFormulaFin sig₀ F₀ r) (k : Fin r) :
    ExistsForallFormulaFin sig₀ F₀ 1 where
  n := ψ.n
  M := ψ.M
  pin := ![ψ.pin k]
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- Fin-variant of `diagProject_efSat_iff`: the diagonal pair projection on `![env k, env k]`
holds exactly when the arity-1 diagonal projection holds on `![env k]` — the two identical pin
clauses of `pairProjectFin ψ k k` collapse to the single pin clause of `diagProjectFin ψ k`.
Same witness chain and partial types. -/
theorem diagProjectFin_efSat_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (ψ : ExistsForallFormulaFin sig₀ F₀ r) (k : Fin r) :
    efSatFin N ![env k, env k] (pairProjectFin ψ k k) ↔
      efSatFin N ![env k] (diagProjectFin ψ k) := by
  constructor
  · rintro ⟨x, hmono, hpin, hpt, hb, hm, ha⟩
    refine ⟨x, hmono, Fin.forall_fin_one.mpr ?_, hpt, hb, hm, ha⟩
    exact hpin 0
  · rintro ⟨x, hmono, hpin, hpt, hb, hm, ha⟩
    refine ⟨x, hmono, Fin.forall_fin_two.mpr ⟨?_, ?_⟩, hpt, hb, hm, ha⟩
    · exact hpin 0
    · exact hpin 0

/-- Fin-variant of `liftSentenceV`: lift an arity-0 per-formula `∨∃∀`-object to arity `r` by
lifting each disjunct with `liftSentenceFin` and flattening. -/
noncomputable def liftSentenceVFin {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 0) :
    VeeExistsForallFin sig₀ F₀ r :=
  Ψ.flatMap (fun ξ => liftSentenceFin (r := r) ξ)

/-- Fin-variant of `liftSentenceV_iff`: for a strictly increasing environment,
`liftSentenceVFin Ψ` is satisfied at `env` exactly when the arity-0 `Ψ` is satisfiable.
Per-disjunct `liftSentenceFin_iff` pushed through `veeSatFin_flatMap`. -/
theorem liftSentenceVFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (Ψ : VeeExistsForallFin sig₀ F₀ 0) :
    veeSatFin N env (liftSentenceVFin (r := r) Ψ) ↔ veeSatFin N ![] Ψ := by
  unfold liftSentenceVFin
  rw [veeSatFin_flatMap]
  constructor
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSentenceFin_iff N env h ξ).mp hξsat⟩
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSentenceFin_iff N env h ξ).mpr hξsat⟩

/-- Every disjunct of `liftSentenceVFin Ψ` has a strictly monotone pin. -/
theorem liftSentenceVFin_pin_strictMono {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 0)
    (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSentenceVFin (r := r) Ψ) :
    StrictMono φ.pin := by
  unfold liftSentenceVFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨ξ, _, hφξ⟩ := hφ
  exact liftSentenceFin_pin_strictMono ξ φ hφξ

/-! ## 8. Fin layer: the general negation assembly

Fin counterpart of section 4: identical trichotomy reindexing over `pairwiseProjectionsFin`
(`k < l` via `liftPairVFin ∘ efSat_negation_pairFin`; `k > l` folded by
`pairProject_swap_efSatFin`; `k = l` via `diagProjectFin_efSat_iff` + `liftSingleVFin ∘
efSat_negation_diagonalFin`; existence via `liftSentenceVFin ∘ efSat_negation_existenceFin`),
chained `veeSatFin_append ×2 + veeSatFin_flatMap` ↔ `efSatFin_negation_demorgan`. The capture
capture is the direct `M`-relative `capTypeFin`; `hNamed` and `hne` threaded. -/

/-- **Fin-variant of `efSat_negation_general` (Rabinovich Prop 4.3 ¬-case, PDF p.6).** The
negation of a general `r`-free-variable per-formula `∃∀`-object as a `VeeExistsForallFin`,
threading the `M`-relative capture hypothesis and `hne` (never discharged). CONDITIONAL orphan
gated on the atom-naming premise `hNamed` (discharged at ζ by `canonExpand_atom_named`).
Every disjunct of the output carries a strictly monotone pin
(T1 invariant). -/
theorem efSat_negation_generalFin
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (atomMap : Formula → (sigE sig₀ F₀).preds)
    (nameOf : (sigE sig₀ F₀).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F₀) A) y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {r : Nat} (ψ : ExistsForallFormulaFin sig₀ F₀ r) :
    ∃ Φ : VeeExistsForallFin sig₀ F₀ r, (∀ φ ∈ Φ, StrictMono φ.pin) ∧
      ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ efSatFin N env ψ ↔ veeSatFin N env Φ) := by
  classical
  -- Per-pair (`k < l`), per-diagonal (`k = l`), and existence-sentence negation objects.
  have hpair := fun (k l : Fin r) =>
    efSat_negation_pairFin N atomMap nameOf hName h_INF h_SUP hNamed (pairProjectFin ψ k l)
  choose P hPspec using hpair
  have hdiag := fun (k : Fin r) =>
    efSat_negation_diagonalFin N atomMap nameOf hName hNamed (diagProjectFin ψ k)
  choose D hDspec using hdiag
  obtain ⟨E, hEspec⟩ :=
    efSat_negation_existenceFin N atomMap nameOf hName hNamed hne (existenceSentenceFin ψ)
  refine ⟨((List.finRange r).flatMap fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairVFin (P k l) k l else [])
          ++ ((List.finRange r).flatMap fun k => liftSingleVFin (D k) k)
          ++ liftSentenceVFin E, ?_, fun env h => ?_⟩
  · -- Pin-monotonicity of every disjunct (T1 invariant): each disjunct is a lift disjunct.
    intro φ hφ
    rw [List.mem_append, List.mem_append] at hφ
    rcases hφ with (hφ | hφ) | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      rw [List.mem_flatMap] at hφ
      obtain ⟨l, _, hφ⟩ := hφ
      by_cases hkl : k < l
      · rw [if_pos hkl] at hφ
        exact liftPairVFin_pin_strictMono (P k l) k l φ hφ
      · rw [if_neg hkl] at hφ
        exact absurd hφ List.not_mem_nil
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      exact liftSingleVFin_pin_strictMono (D k) k φ hφ
    · exact liftSentenceVFin_pin_strictMono E φ hφ
  set A := (List.finRange r).flatMap (fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairVFin (P k l) k l else []) with hAdef
  set B := (List.finRange r).flatMap (fun k => liftSingleVFin (D k) k) with hBdef
  set C := liftSentenceVFin E with hCdef
  -- The `k < l` pair disjuncts.
  have hA : veeSatFin N env A ↔
      ∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
    rw [hAdef, veeSatFin_flatMap]
    constructor
    · rintro ⟨k, -, hk⟩
      rw [veeSatFin_flatMap] at hk
      obtain ⟨l, -, hl⟩ := hk
      by_cases hkl : k < l
      · rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
          hPspec k l ![env k, env l] (by simpa using h hkl)] at hl
        exact ⟨k, l, hkl, hl⟩
      · rw [if_neg hkl] at hl
        simp [veeSatFin] at hl
    · rintro ⟨k, l, hkl, hnp⟩
      refine ⟨k, List.mem_finRange k, ?_⟩
      rw [veeSatFin_flatMap]
      refine ⟨l, List.mem_finRange l, ?_⟩
      rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
        hPspec k l ![env k, env l] (by simpa using h hkl)]
      exact hnp
  -- The diagonal (`k = l`) disjuncts.
  have hB : veeSatFin N env B ↔
      ∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k) := by
    rw [hBdef, veeSatFin_flatMap]
    constructor
    · rintro ⟨k, -, hk⟩
      rw [liftSingleVFin_iff N env h (D k) k, hDspec k ![env k],
        ← diagProjectFin_efSat_iff N env ψ k] at hk
      exact ⟨k, hk⟩
    · rintro ⟨k, hk⟩
      refine ⟨k, List.mem_finRange k, ?_⟩
      rw [liftSingleVFin_iff N env h (D k) k, hDspec k ![env k],
        ← diagProjectFin_efSat_iff N env ψ k]
      exact hk
  -- The existence-sentence disjunct.
  have hC : veeSatFin N env C ↔ ¬ efSatFin N ![] (existenceSentenceFin ψ) := by
    rw [hCdef, liftSentenceVFin_iff N env h E, hEspec]
  -- Reindex the De Morgan pair-part over `pairwiseProjectionsFin`.
  have hDemPairs : (∃ p ∈ pairwiseProjectionsFin ψ, ¬ efSatFin N ![env p.1, env p.2.1] p.2.2)
      ↔ ∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
    constructor
    · rintro ⟨p, hp, hnp⟩
      unfold pairwiseProjectionsFin at hp
      rw [List.mem_flatMap] at hp
      obtain ⟨k, -, hp⟩ := hp
      rw [List.mem_map] at hp
      obtain ⟨l, -, rfl⟩ := hp
      exact ⟨k, l, hnp⟩
    · rintro ⟨k, l, hnp⟩
      refine ⟨(k, l, pairProjectFin ψ k l), ?_, hnp⟩
      unfold pairwiseProjectionsFin
      rw [List.mem_flatMap]
      exact ⟨k, List.mem_finRange k, by rw [List.mem_map]; exact ⟨l, List.mem_finRange l, rfl⟩⟩
  -- Trichotomy + swap fold: all ordered pairs reduce to `k < l` pairs plus the diagonal.
  have hTri : (∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
      ↔ (∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
        ∨ (∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k)) := by
    constructor
    · rintro ⟨k, l, hnp⟩
      rcases lt_trichotomy k l with hkl | hkl | hkl
      · exact Or.inl ⟨k, l, hkl, hnp⟩
      · subst hkl; exact Or.inr ⟨_, hnp⟩
      · refine Or.inl ⟨l, k, hkl, ?_⟩
        rw [← pairProject_swap_efSatFin N env ψ k l]
        exact hnp
    · rintro (⟨k, l, -, hnp⟩ | ⟨k, hnp⟩)
      · exact ⟨k, l, hnp⟩
      · exact ⟨k, k, hnp⟩
  -- Assemble.
  rw [efSatFin_negation_demorgan N env ψ, hDemPairs, veeSatFin_append, veeSatFin_append,
    hA, hB, hC, hTri]

end FinLayer

end FormalSystem.Metalogic.WeakCanonical.Kamp
