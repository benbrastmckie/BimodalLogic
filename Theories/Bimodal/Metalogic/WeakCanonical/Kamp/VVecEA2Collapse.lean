import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType
import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly
import Bimodal.Metalogic.WeakCanonical.Kamp.Prop42ExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave

/-!
# E[Σ] collapse bridge `VVecEA2 → VeeExistsForall` (Rabinovich Def 4.1, PDF p.5-6) — assembly half

This module supplies the **disjunctive-assembly half** of the E[Σ] atom-collapse bridge that lifts a
`VVecEA2` witness (the object the arbitrary-pin negation engine `prop42_efSat_negation_general`
produces) back into a `VeeExistsForall` object. The bridge is Rabinovich Def 4.1 (PDF p.5-6) — the
`VVecEA2 → VeeExistsForall` re-expression is the E[Σ] atom-collapse, the genuine reverse of the
landed forward bridge `translateVeeProp42` (`Prop42ExistsForall.lean`, which runs
`VeeExistsForall → VVecEA2`).

## What is here (green): the per-clause → disjunction assembly

`vvecea2_collapse_of_perClause` reduces the full bridge to a **per-clause reverse translation**: given
a map `trans` sending each `VVecEA2` disjunct `⟨n, vea⟩` to an `ExistsForallFormula sig F 2` whose
`efSat` matches `vea.holds` on strictly-ordered pairs, the disjunction `v'.disjuncts.map trans` is a
`VeeExistsForall` object satisfied exactly when `v'` holds. This is the `foldr`/`map`-over-disjuncts
step (Def 3.3 disjunction distributivity), proved directly by disjunct matching — the same shape as
`translateVeeProp42_correct` in reverse. It is sorry-free and axiom-clean.

## The top-level bridge (green): `vvecea2_collapse_bridge`, conditional on `hCapture`

`vvecea2_collapse_bridge` completes the reverse bridge as a **CONDITIONAL** result taking the exact
capture/definability hypothesis the reverse direction needs:

```
hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
    ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A
```

`hCapture` is the literal reverse of `unaryToFormula_correct` lifted to `IntervalType` — every
arbitrary `TL(Until,Since)` endpoint/segment `Formula` the negation engine emits
(`Prop42NegationGeneral.lean`) is captured as an admissible-completion `IntervalType`. The capture
map `cap : Formula → IntervalType` is obtained by `Classical.choice`/`choose` **inside** the bridge.
Because an `ExistsForallFormula` point type is a *single* complete `UnaryType` while a captured truth
set is a *union* of complete types (report 11 R4), each `VecEA2` clause expands into a **disjunction
over point completions** — a `List` of endpoint-pinned `ExistsForallFormula`s (`collapseEF`),
reassembled by `vvecea2_collapse_of_perClauseList`. Per tuple, `translateProp42_correct` collapses
`efSat` to the completed clause (`collapseEF_translate` reduces the `translateProp42` field reads
through the `Fin.cons`/`Fin.snoc` lemmas; `collapseEF_cap` supplies the two vacuous caps via
`intervalHolds_intervalTop`), and `bracket_completion_iff` collapses the bracket half.

`hCapture` is **threaded here, NOT discharged** — its discharge (against a `canonExpand` whose `F` is
closed under the engine's output formulas) is Phase ζ. The result is therefore a proved CONDITIONAL
biconditional, an orphan gated on `hCapture`, off the live import path. No `sorry` or placeholder is
introduced; the axiom set is `[propext, Classical.choice, Quot.sound]`.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5-6). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `Prop42ExistsForall.lean`: `translateVeeProp42` / `translateVeeProp42_correct` (the forward bridge).
- `Prop42NegationGeneral.lean`: `prop42_efSat_negation_general` (produces the `VVecEA2` this lifts).
- `VeeExistsForall.lean`: `veeSat`, `veeSat_append`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-- **E[Σ] collapse bridge, disjunctive-assembly half (Def 4.1, p.5-6).** Given a per-clause reverse
translation `trans` that sends every `VVecEA2` disjunct to an `ExistsForallFormula sig F 2` matching
it on strictly-ordered pairs (`htrans`), the mapped disjunction is a `VeeExistsForall` object
satisfied exactly when the whole `VVecEA2` holds. This is the reverse of `translateVeeProp42_correct`:
the `map`-over-disjuncts step, proved by disjunct matching (Def 3.3 disjunction distributivity).

The per-clause hypothesis `trans`/`htrans` is the genuine Def 4.1 atom-collapse content and is the
`[BLOCKED]` crux under the current hypotheses (see the module docstring). -/
theorem vvecea2_collapse_of_perClause {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (v' : VVecEA2)
    (trans : (Σ n, VecEA2 n) → ExistsForallFormula sig F 2)
    (htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (efSat N env (trans vea) ↔ vea.2.holds N atomMap (env 0) (env 1))) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  refine ⟨v'.disjuncts.map trans, fun env henv => ?_⟩
  simp only [veeSat, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, rfl⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp hsat⟩
  · rintro ⟨vea, hvea, hholds⟩
    exact ⟨trans vea, ⟨vea, hvea, rfl⟩, (htrans vea hvea env henv).mpr hholds⟩

/-! ## Conditional reverse bridge threading `hCapture` (Def 4.1 E[Σ] collapse, p.5-6)

The per-clause reverse translation `trans`/`htrans` demanded by `vvecea2_collapse_of_perClause`
is the genuine Def 4.1 atom-collapse. It is discharged here as a **conditional** result taking the
capture/definability hypothesis `hCapture` (a `TL` formula over the processed E[Σ] alphabet is
realized by an admissible-completion set at every point — the literal reverse of
`unaryToFormula_correct`, lifted to `IntervalType`). With `hCapture` in hand every arbitrary
`TL(Until,Since)` endpoint/segment `Formula` the negation engine emits
(`Prop42NegationGeneral.lean`) is captured as an `IntervalType`. Because an `ExistsForallFormula`
point type is a *single* complete `UnaryType` while a captured truth set is a *union* of complete
types, each `VecEA2` clause expands into a disjunction over the admissible completions at its
point positions — the E[Σ] collapse of Def 4.1. The result is a proved CONDITIONAL biconditional,
an orphan gated on `hCapture` (discharged only at ζ / Phase 10P), off the live import path.
-/

/-- **Capture at the `TemporalPred` level.** `hCapture` supplies, for every `Formula`, an
admissible-completion set (`IntervalType`) whose partial satisfaction matches temporal truth. Since
`TemporalPred.eval_at` is `temporal_truth` on the wrapped formula, every `TemporalPred` is captured
by an `IntervalType`. This is the reusable wrapper the reverse bridge routes all endpoint and
segment predicates through. -/
theorem intervalType_captures_temporalPred {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (tp : TemporalPred) :
    ∃ S : IntervalType sig F, ∀ y : N.carrier,
      intervalHolds N S y ↔ tp.eval_at N atomMap y := by
  obtain ⟨S, hS⟩ := hCapture tp.formula
  exact ⟨S, fun y => hS y⟩

/-- **Trivial-cap realizability.** The full admissible set `intervalTop = univ` is satisfied at
every point: a point realizes its own depth-0 characteristic type (`nf_characteristic`), which lies
in `univ`. This is what makes the two unbounded `ExistsForallFormula` caps (before `x₀`, after `xₙ`)
vacuous — Rabinovich's trivial caps — so the reverse translation reduces exactly to the bounded
`VecEA2` interval content. -/
theorem intervalHolds_intervalTop {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (y : N.carrier) :
    intervalHolds N (intervalTop sig F) y :=
  ⟨nf_characteristic N 0 1 (fun _ => y), Finset.mem_univ _,
   nf_characteristic_satisfies N 0 1 (fun _ => y)⟩

/-- **List-valued per-clause assembly (Def 3.3 disjunction distributivity, reverse).** The
`vvecea2_collapse_of_perClause` interface sends each `VVecEA2` disjunct to a *single*
`ExistsForallFormula`. The E[Σ] atom-collapse of Def 4.1, however, expands one `VecEA2` clause into
a *disjunction* over the admissible completions at its point positions (a point type is a single
complete `UnaryType`, but a captured truth set is a union of complete types). This variant therefore
takes a **list**-valued per-clause reverse translation `transL` and flattens with `List.flatMap`;
it is the assembly the capture-threaded bridge routes through. Reduces the whole bridge to the
per-clause list-satisfaction correctness `htrans`. -/
theorem vvecea2_collapse_of_perClauseList {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (v' : VVecEA2)
    (transL : (Σ n, VecEA2 n) → List (ExistsForallFormula sig F 2))
    (htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        ((∃ ψ ∈ transL vea, efSat N env ψ) ↔ vea.2.holds N atomMap (env 0) (env 1))) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  refine ⟨v'.disjuncts.flatMap transL, fun env henv => ?_⟩
  simp only [veeSat, VVecEA2.holds, List.mem_flatMap]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp ⟨ψ, hψ, hsat⟩⟩
  · rintro ⟨vea, hvea, hholds⟩
    obtain ⟨ψ, hψ, hsat⟩ := (htrans vea hvea env henv).mpr hholds
    exact ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩

/-- **Finite choice distribution over `piFinset`.** A single admissible completion tuple realizing a
per-index predicate exists iff every index has an admissible realizer. This is the combinatorial
core of the point-completion enumeration: the interior bracket witnesses each pick a completion from
their own captured set, assembled into one tuple. -/
theorem exists_piFinset_forall_iff {ι : Type*} [Fintype ι] [DecidableEq ι]
    {α : ι → Type*} [∀ i, DecidableEq (α i)] (t : ∀ i, Finset (α i)) (p : ∀ i, α i → Prop) :
    (∃ f ∈ Fintype.piFinset t, ∀ i, p i (f i)) ↔ ∀ i, ∃ a ∈ t i, p i a := by
  constructor
  · rintro ⟨f, hf, hp⟩ i
    exact ⟨f i, (Fintype.mem_piFinset.mp hf) i, hp i⟩
  · intro h
    choose g hg hgp using h
    exact ⟨g, Fintype.mem_piFinset.mpr hg, hgp⟩

/-- **Bracket-level E[Σ] collapse (Def 4.1, p.5-6).** A bracket formula `bf` whose point predicates
`pointTypes i` and segment predicates `segmentTypes j` are captured by admissible-completion sets
`Sp i` / `Ss j` (`intervalHolds` matches `eval_at`) is satisfied on `(z0, z1)` iff *some* completion
tuple `g` of the point sets yields a satisfied bracket whose point types are the single complete
types `g i` and whose segment types are the captured sets. The interior witnesses each draw a
completion from their own point set (`exists_piFinset_forall_iff`); the segments carry the sets
directly. This is the bracket half of the atom-collapse the reverse bridge threads through. -/
theorem bracket_completion_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    {m : Nat} (bf : BracketFormula m)
    (Sp : Fin m → IntervalType sig F) (Ss : Fin (m + 1) → IntervalType sig F)
    (hSp : ∀ (i : Fin m) (y : N.carrier),
        intervalHolds N (Sp i) y ↔ (bf.pointTypes i).eval_at N atomMap y)
    (hSs : ∀ (j : Fin (m + 1)) (y : N.carrier),
        intervalHolds N (Ss j) y ↔ (bf.segmentTypes j).eval_at N atomMap y)
    (z0 z1 : N.carrier) :
    (∃ g ∈ Fintype.piFinset Sp,
        (BracketFormula.mk (fun i => efPointTP atomMap h_surj (g i))
          (fun j => efIntervalSetTP atomMap h_surj (Ss j))).holds N atomMap z0 z1)
      ↔ bf.holds N atomMap z0 z1 := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  rcases Nat.eq_zero_or_pos m with hm | hm
  · -- No interior witnesses: the bracket is just its single segment predicate on (z0, z1).
    subst hm
    -- `holds_eq_zero` rewrites only the `bf` side; the LHS `holds` sits under the `∃ g` binder.
    rw [IntervalPattern.holds_eq_zero (h := rfl)]
    constructor
    · rintro ⟨g, -, hbody⟩
      rw [IntervalPattern.holds_eq_zero (h := rfl)] at hbody
      intro y hy0 hy1
      have hb := hbody y hy0 hy1
      rw [efIntervalSetTP_eval] at hb
      rw [← hSs ⟨0, by omega⟩ y]
      exact hb
    · intro hbody
      refine ⟨Fin.elim0, Fintype.mem_piFinset.mpr (fun i => i.elim0), ?_⟩
      rw [IntervalPattern.holds_eq_zero (h := rfl)]
      intro y hy0 hy1
      rw [efIntervalSetTP_eval, hSs ⟨0, by omega⟩ y]
      exact hbody y hy0 hy1
  · -- k+1 interior witnesses.
    obtain ⟨k, hk⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
    -- `holds_eq_succ` rewrites only the `bf` side; the LHS `holds` sits under the `∃ g` binder,
    -- so it is unfolded after `g` is introduced.
    rw [IntervalPattern.holds_eq_succ (h := hk)]
    constructor
    · rintro ⟨g, hg, hbody⟩
      rw [IntervalPattern.holds_eq_succ (h := hk)] at hbody
      obtain ⟨w, hmono, hrange, hpt, hb0, hbmid, hblast⟩ := hbody
      have hgmem := Fintype.mem_piFinset.mp hg
      refine ⟨w, hmono, hrange, ?_, ?_, ?_, ?_⟩
      · intro i
        rw [← hSp ⟨i.val, by omega⟩ (w i)]
        exact ⟨g ⟨i.val, by omega⟩, hgmem _, (efPointTP_eval N atomMap h_surj _ (w i)).mp (hpt i)⟩
      · intro y hy0 hy1
        rw [← hSs ⟨0, by omega⟩ y, ← efIntervalSetTP_eval N atomMap h_surj]
        exact hb0 y hy0 hy1
      · intro i y hy0 hy1
        rw [← hSs ⟨i.val + 1, by omega⟩ y, ← efIntervalSetTP_eval N atomMap h_surj]
        exact hbmid i y hy0 hy1
      · intro y hy0 hy1
        rw [← hSs ⟨k + 1, by omega⟩ y, ← efIntervalSetTP_eval N atomMap h_surj]
        exact hblast y hy0 hy1
    · rintro ⟨w, hmono, hrange, hpt, hb0, hbmid, hblast⟩
      -- Build the completion tuple g from the realizers at each interior witness.
      have hchoice : ∀ i : Fin m, ∃ τ ∈ Sp i, unaryHolds N τ (w ⟨i.val, by omega⟩) := by
        intro i
        obtain ⟨τ, hτS, hτ⟩ := (hSp i (w ⟨i.val, by omega⟩)).mpr (by
          have hpt' := hpt ⟨i.val, by omega⟩
          simpa using hpt')
        exact ⟨τ, hτS, hτ⟩
      obtain ⟨g, hg, hgpt⟩ := (exists_piFinset_forall_iff Sp
        (fun i τ => unaryHolds N τ (w ⟨i.val, by omega⟩))).mpr hchoice
      refine ⟨g, hg, ?_⟩
      rw [IntervalPattern.holds_eq_succ (h := hk)]
      refine ⟨w, hmono, hrange, ?_, ?_, ?_, ?_⟩
      · intro i
        exact (efPointTP_eval N atomMap h_surj _ (w i)).mpr (by simpa using hgpt ⟨i.val, by omega⟩)
      · intro y hy0 hy1
        rw [efIntervalSetTP_eval, hSs ⟨0, by omega⟩ y]
        exact hb0 y hy0 hy1
      · intro i y hy0 hy1
        rw [efIntervalSetTP_eval, hSs ⟨i.val + 1, by omega⟩ y]
        exact hbmid i y hy0 hy1
      · intro y hy0 hy1
        rw [efIntervalSetTP_eval, hSs ⟨k + 1, by omega⟩ y]
        exact hblast y hy0 hy1

/-! ## Top-level conditional collapse bridge (Def 4.1 E[Σ] collapse, p.5-6)

Assembles the reverse bridge `VVecEA2 → VeeExistsForall` on top of the five reusable lemmas above,
threading the capture hypothesis `hCapture` at the `IntervalType` level. The capture map
`cap : Formula → IntervalType` is obtained by `Classical.choice`/`choose` inside the bridge; each
`VecEA2` clause expands into a **disjunction over its point completions** (a `List` of endpoint-pinned
`ExistsForallFormula`s), reassembled by `vvecea2_collapse_of_perClauseList`. The result is a proved
CONDITIONAL biconditional gated on `hCapture` (discharged only at ζ), off the live import path. -/

/-- **Per-tuple endpoint-pinned `∃∀`-formula for the reverse collapse.** For a `VecEA2 m` clause and
a completion tuple `(τ_L, τ_R, g)` — endpoint completions `τ_L`/`τ_R` and an interior point-completion
tuple `g : Fin m → UnaryType` — the `m+1`-point `ExistsForallFormula` whose two endpoints are pinned
to the free variables (`pin = ![0, last]`), whose point types are `τ_L`, the interior `g i`, and `τ_R`
(assembled by `Fin.cons`/`Fin.snoc`), and whose bounded interval slots carry the captured segment sets
`Ss`, with the two unbounded caps set to `intervalTop` (Rabinovich's vacuous caps). -/
def collapseEF {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula} {m : Nat}
    (Ss : Fin (m + 1) → IntervalType sig F)
    (τ_L τ_R : UnaryType sig F) (g : Fin m → UnaryType sig F) :
    ExistsForallFormula sig F 2 where
  n := m + 1
  pin := fun i => if i.val = 0 then 0 else Fin.last (m + 1)
  pointType := Fin.cons τ_L (Fin.snoc g τ_R)
  intervalType := Fin.cons (intervalTop sig F) (Fin.snoc Ss (intervalTop sig F))

/-- The per-tuple EF `collapseEF` is endpoint-pinned with trivial caps: the two free variables sit at
the chain endpoints (`pin 0 = 0`, `pin 1 = last`) and the two unbounded caps are `intervalTop`, hence
realized at every point (`intervalHolds_intervalTop`). This is what lets `translateProp42_correct`
collapse `efSat` to the bounded endpoint + bracket content. -/
theorem collapseEF_cap {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula} {m : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (Ss : Fin (m + 1) → IntervalType sig F)
    (τ_L τ_R : UnaryType sig F) (g : Fin m → UnaryType sig F) :
    EndpointPinnedCapTrivial N (collapseEF Ss τ_L τ_R g) where
  posN := Nat.le_add_left 1 m
  pinLeft := rfl
  pinRight := rfl
  capTrivialLeft := fun y => by
    simp only [ExistsForallFormula.intervalSet, collapseEF, Fin.cons_zero]
    exact intervalHolds_intervalTop N y
  capTrivialRight := fun y => by
    simp only [ExistsForallFormula.intervalSet, collapseEF]
    rw [← Fin.succ_last, Fin.cons_succ, Fin.snoc_last]
    exact intervalHolds_intervalTop N y

/-- **Field reduction of `translateProp42` on `collapseEF`.** The forward translation
`translateProp42` reads the endpoint/interior point types and segment sets of `collapseEF` back out;
via the `Fin.cons`/`Fin.snoc` simp lemmas these reduce to exactly `τ_L`, `τ_R`, the interior `g i`,
and the captured segments `Ss j`. This gives the per-tuple `VecEA2` explicitly as the completed
clause, so `translateProp42_correct` reads as an `efSat ↔ completed-clause` biconditional. -/
theorem collapseEF_translate {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula} {m : Nat}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (Ss : Fin (m + 1) → IntervalType sig F)
    (τ_L τ_R : UnaryType sig F) (g : Fin m → UnaryType sig F) :
    translateProp42 atomMap h_surj (collapseEF Ss τ_L τ_R g) =
      ⟨efPointTP atomMap h_surj τ_L, efPointTP atomMap h_surj τ_R,
       ⟨fun i => efPointTP atomMap h_surj (g i),
        fun j => efIntervalSetTP atomMap h_surj (Ss j)⟩⟩ := by
  have hpt0 : (collapseEF Ss τ_L τ_R g).pointType 0 = τ_L := by
    simp only [collapseEF, Fin.cons_zero]
  have hptlast :
      (collapseEF Ss τ_L τ_R g).pointType (Fin.last (collapseEF Ss τ_L τ_R g).n) = τ_R := by
    simp only [collapseEF]
    rw [← Fin.succ_last, Fin.cons_succ, Fin.snoc_last]
  have hpti : ∀ i : Fin m,
      (collapseEF Ss τ_L τ_R g).pointType (⟨i.val + 1, by omega⟩ : Fin (m + 2)) = g i := by
    intro i
    simp only [collapseEF]
    rw [show (⟨i.val + 1, by omega⟩ : Fin (m + 2)) = (i.castSucc).succ from by
          apply Fin.ext; simp [Fin.val_succ],
      Fin.cons_succ, Fin.snoc_castSucc]
  have hsj : ∀ j : Fin (m + 1),
      (collapseEF Ss τ_L τ_R g).intervalSet (⟨j.val + 1, by omega⟩ : Fin (m + 3)) = Ss j := by
    intro j
    simp only [ExistsForallFormula.intervalSet, collapseEF]
    rw [show (⟨j.val + 1, by omega⟩ : Fin (m + 3)) = (j.castSucc).succ from by
          apply Fin.ext; simp [Fin.val_succ],
      Fin.cons_succ, Fin.snoc_castSucc]
  unfold translateProp42
  simp only [hpt0, hptlast, hpti, hsj]

/-- **E[Σ] collapse bridge, conditional on `hCapture` (Rabinovich Def 4.1, p.5-6).** The reverse of the
landed forward bridge `translateVeeProp42` (`VeeExistsForall → VVecEA2`): every `VVecEA2` object `v'`
(the output of the arbitrary-pin negation engine) is lifted back to a `VeeExistsForall` object
satisfied exactly when `v'` holds on strictly-ordered pairs. The capture/definability the reverse
direction needs is supplied by `hCapture` (a `TL` formula's truth set is an admissible-completion
`IntervalType` at every point — the literal reverse of `unaryToFormula_correct`, lifted to
`IntervalType`); it is threaded here, NOT discharged (its discharge is Phase ζ, against a closed
`canonExpand`). `h_INF`/`h_SUP` are carried for uniformity with the downstream β/γ/δ threading. The
result is a proved CONDITIONAL biconditional — an orphan gated on `hCapture`, off the live import
path. -/
theorem vvecea2_collapse_bridge {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (_h_INF : HasAttainedINF N atomMap) (_h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (v' : VVecEA2) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  choose cap hcap using hCapture
  refine vvecea2_collapse_of_perClauseList N atomMap v'
    (fun vea =>
      ((cap vea.2.endpointLeft.formula) ×ˢ (cap vea.2.endpointRight.formula) ×ˢ
        Fintype.piFinset (fun i => cap (vea.2.bracket.pointTypes i).formula)).toList.map
        (fun t => collapseEF (fun j => cap (vea.2.bracket.segmentTypes j).formula)
          t.1 t.2.1 t.2.2))
    ?_
  rintro ⟨m, vc⟩ hvea env henv
  dsimp only
  set S_L := cap vc.endpointLeft.formula with hSL
  set S_R := cap vc.endpointRight.formula with hSR
  set Sp := fun i => cap (vc.bracket.pointTypes i).formula with hSp_def
  set Ss := fun j => cap (vc.bracket.segmentTypes j).formula with hSs_def
  -- Per-tuple correctness: efSat of the endpoint-pinned EF ↔ completed clause on (env 0, env 1).
  have hcorrect : ∀ (τ_L τ_R : UnaryType sig F) (g : Fin m → UnaryType sig F),
      efSat N env (collapseEF Ss τ_L τ_R g) ↔
        unaryHolds N τ_L (env 0) ∧ unaryHolds N τ_R (env 1) ∧
        (BracketFormula.mk (fun i => efPointTP atomMap h_surj (g i))
          (fun j => efIntervalSetTP atomMap h_surj (Ss j))).holds N atomMap (env 0) (env 1) := by
    intro τ_L τ_R g
    rw [translateProp42_correct N atomMap h_surj env (collapseEF Ss τ_L τ_R g)
          (collapseEF_cap N Ss τ_L τ_R g) henv,
        collapseEF_translate atomMap h_surj Ss τ_L τ_R g]
    constructor
    · rintro ⟨hL, hR, hbr⟩
      exact ⟨(efPointTP_eval N atomMap h_surj τ_L (env 0)).mp hL,
             (efPointTP_eval N atomMap h_surj τ_R (env 1)).mp hR, hbr⟩
    · rintro ⟨hL, hR, hbr⟩
      exact ⟨(efPointTP_eval N atomMap h_surj τ_L (env 0)).mpr hL,
             (efPointTP_eval N atomMap h_surj τ_R (env 1)).mpr hR, hbr⟩
  -- Capture facts for endpoints and bracket predicates.
  have hSpcap : ∀ (i : Fin m) (y : N.carrier),
      intervalHolds N (Sp i) y ↔ (vc.bracket.pointTypes i).eval_at N atomMap y :=
    fun i y => hcap (vc.bracket.pointTypes i).formula y
  have hSscap : ∀ (j : Fin (m + 1)) (y : N.carrier),
      intervalHolds N (Ss j) y ↔ (vc.bracket.segmentTypes j).eval_at N atomMap y :=
    fun j y => hcap (vc.bracket.segmentTypes j).formula y
  rw [VecEA2.holds]
  constructor
  · -- forward
    rintro ⟨ψ, hψmem, hsat⟩
    rw [List.mem_map] at hψmem
    obtain ⟨t, htmem, rfl⟩ := hψmem
    rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product] at htmem
    obtain ⟨htL, htR, htg⟩ := htmem
    rw [hcorrect] at hsat
    obtain ⟨huL, huR, hbr⟩ := hsat
    refine ⟨?_, ?_, ?_⟩
    · exact (hcap vc.endpointLeft.formula (env 0)).mp ⟨t.1, htL, huL⟩
    · exact (hcap vc.endpointRight.formula (env 1)).mp ⟨t.2.1, htR, huR⟩
    · exact (bracket_completion_iff N atomMap h_surj vc.bracket Sp Ss hSpcap hSscap
        (env 0) (env 1)).mp ⟨t.2.2, htg, hbr⟩
  · -- backward
    rintro ⟨heL, heR, hbrk⟩
    have hiL : intervalHolds N S_L (env 0) := (hcap vc.endpointLeft.formula (env 0)).mpr heL
    have hiR : intervalHolds N S_R (env 1) := (hcap vc.endpointRight.formula (env 1)).mpr heR
    obtain ⟨τ_L, hτL, huL⟩ := hiL
    obtain ⟨τ_R, hτR, huR⟩ := hiR
    obtain ⟨g, hg, hbr⟩ := (bracket_completion_iff N atomMap h_surj vc.bracket Sp Ss
      hSpcap hSscap (env 0) (env 1)).mpr hbrk
    refine ⟨collapseEF Ss τ_L τ_R g, ?_, ?_⟩
    · rw [List.mem_map]
      exact ⟨(τ_L, τ_R, g), by
        rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product]
        exact ⟨hτL, hτR, hg⟩, rfl⟩
    · rw [hcorrect]
      exact ⟨huL, huR, hbr⟩

/-! ## Fin layer: the collapse bridge on the per-formula representation (Def 4.1, p.5-6)

Fin counterparts of the whole module on `ExistsForallFormulaFin`/`efSatFin`/`veeSatFin`
(`PerFormulaExistsForall.lean`, `ExistsForallLemmas.lean` Fin section): the capture hypothesis
becomes `M`-relative (`∃ M, ∃ S : IntervalTypeFin sig F M, …` — the only capture shape that
exists without alphabet finiteness), and because the captured sets of the different clause slots
mention DIFFERENT atom sets, each clause first expands its captured sets to the clause's ambient
union `M` via `intervalExpandFin` (the one-factor analog of `intervalGlueFin`,
`ConjInterleave.lean` Fin section). The `VVecEA2`/`VecEA2`/`BracketFormula` source layer is
`TemporalPred`-level and reused verbatim; `exists_piFinset_forall_iff` above is generic and
reused verbatim. NO alphabet instances, NO full-alphabet `Finset.univ` (every `Finset.univ`
below ranges over `UnaryTypeFin sig F M` — functions on the finite mentioned subtype). -/

section FinLayer

/-- Fin-variant of `vvecea2_collapse_of_perClause`: given a per-clause reverse translation into
per-formula `∃∀`-objects matching each disjunct on strictly-ordered pairs, the mapped
disjunction is a `VeeExistsForallFin` object satisfied exactly when the whole `VVecEA2`
holds. -/
theorem vvecea2_collapse_of_perClauseFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (v' : VVecEA2)
    (trans : (Σ n, VecEA2 n) → ExistsForallFormulaFin sig F 2)
    (htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (efSatFin N env (trans vea) ↔ vea.2.holds N atomMap (env 0) (env 1))) :
    ∃ Φ : VeeExistsForallFin sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSatFin N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  refine ⟨v'.disjuncts.map trans, fun env henv => ?_⟩
  simp only [veeSatFin, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, rfl⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp hsat⟩
  · rintro ⟨vea, hvea, hholds⟩
    exact ⟨trans vea, ⟨vea, hvea, rfl⟩, (htrans vea hvea env henv).mpr hholds⟩

/-- Fin-variant of `intervalType_captures_temporalPred`: the `M`-relative capture hypothesis
captures every `TemporalPred` (whose `eval_at` is `temporal_truth` on the wrapped formula). -/
theorem intervalTypeFin_captures_temporalPred {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (hCapture : ∀ A : Formula, ∃ (M : Finset (AtomKind (sigE sig F) 1))
        (S : IntervalTypeFin sig F M),
        ∀ y : N.carrier, intervalHoldsFin N S y ↔ temporal_truth N atomMap y A)
    (tp : TemporalPred) :
    ∃ (M : Finset (AtomKind (sigE sig F) 1)) (S : IntervalTypeFin sig F M),
      ∀ y : N.carrier, intervalHoldsFin N S y ↔ tp.eval_at N atomMap y := by
  obtain ⟨M, S, hS⟩ := hCapture tp.formula
  exact ⟨M, S, fun y => hS y⟩

/-- Fin-variant of `vvecea2_collapse_of_perClauseList`: list-valued per-clause reverse
translation flattened with `List.flatMap` — the assembly the capture-threaded Fin bridge
routes through. -/
theorem vvecea2_collapse_of_perClauseListFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (v' : VVecEA2)
    (transL : (Σ n, VecEA2 n) → List (ExistsForallFormulaFin sig F 2))
    (htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        ((∃ ψ ∈ transL vea, efSatFin N env ψ) ↔ vea.2.holds N atomMap (env 0) (env 1))) :
    ∃ Φ : VeeExistsForallFin sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSatFin N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  refine ⟨v'.disjuncts.flatMap transL, fun env henv => ?_⟩
  simp only [veeSatFin, VVecEA2.holds, List.mem_flatMap]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp ⟨ψ, hψ, hsat⟩⟩
  · rintro ⟨vea, hvea, hholds⟩
    obtain ⟨ψ, hψ, hsat⟩ := (htrans vea hvea env henv).mpr hholds
    exact ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩

open Classical in
/-- **`M`-expansion of a partial interval set (the one-factor analog of `intervalGlueFin`).**
The admissible completions over an ambient mentioned set `M` whose restriction to `M₁ ⊆ M`
lands in `S`. `Finset.univ` ranges over `UnaryTypeFin sig F M` — functions on the finite
mentioned subtype — never over any whole-alphabet type. -/
noncomputable def intervalExpandFin {sig : MonadicSignature} {F : Finset Formula}
    {M₁ M : Finset (AtomKind (sigE sig F) 1)} (h : M₁ ⊆ M)
    (S : IntervalTypeFin sig F M₁) : IntervalTypeFin sig F M :=
  Finset.univ.filter fun c => weaken h c ∈ S

/-- Membership in the expanded interval set: the restriction is admissible. -/
theorem mem_intervalExpandFin {sig : MonadicSignature} {F : Finset Formula}
    {M₁ M : Finset (AtomKind (sigE sig F) 1)} (h : M₁ ⊆ M)
    (S : IntervalTypeFin sig F M₁) (c : UnaryTypeFin sig F M) :
    c ∈ intervalExpandFin h S ↔ weaken h c ∈ S := by
  classical
  simp only [intervalExpandFin, Finset.mem_filter, Finset.mem_univ, true_and]

/-- **Expansion preserves satisfaction.** A point satisfies the expanded set over the ambient
`M` iff it satisfies the original set over `M₁`. Forward: restrict the realized completion
(`partialHolds_weaken`). Backward: the point's characteristic completion over `M` restricts to
the realized completion by uniqueness (`partialHolds_eq_charTypeFin`). -/
theorem intervalHoldsFin_expandFin_iff {sig : MonadicSignature} {F : Finset Formula}
    {M₁ M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (h : M₁ ⊆ M)
    (S : IntervalTypeFin sig F M₁) (y : N.carrier) :
    intervalHoldsFin N (intervalExpandFin h S) y ↔ intervalHoldsFin N S y := by
  constructor
  · rintro ⟨c, hcmem, hcy⟩
    rw [mem_intervalExpandFin] at hcmem
    exact ⟨_, hcmem, partialHolds_weaken N h hcy⟩
  · rintro ⟨c, hcS, hcy⟩
    refine ⟨charTypeFin N M y, ?_, partialHolds_charTypeFin N _ y⟩
    rw [mem_intervalExpandFin, weaken_charTypeFin, ← partialHolds_eq_charTypeFin N hcy]
    exact hcS

/-- Fin-variant of `bracket_completion_iff` (Def 4.1, p.5-6), over a single ambient mentioned
set `M`: a bracket formula whose point/segment predicates are captured by `M`-relative
admissible sets is satisfied on `(z0, z1)` iff some completion tuple of the point sets yields a
satisfied bracket whose point types are the single partial types `g i` and whose segment types
are the captured sets. Same proof on the partial relations, with
`efPointTPFin`/`efIntervalSetTPFin` renders and `exists_piFinset_forall_iff` reused verbatim. -/
theorem bracket_completion_iffFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    {M : Finset (AtomKind (sigE sig F) 1)}
    {m : Nat} (bf : BracketFormula m)
    (Sp : Fin m → IntervalTypeFin sig F M) (Ss : Fin (m + 1) → IntervalTypeFin sig F M)
    (hSp : ∀ (i : Fin m) (y : N.carrier),
        intervalHoldsFin N (Sp i) y ↔ (bf.pointTypes i).eval_at N atomMap y)
    (hSs : ∀ (j : Fin (m + 1)) (y : N.carrier),
        intervalHoldsFin N (Ss j) y ↔ (bf.segmentTypes j).eval_at N atomMap y)
    (z0 z1 : N.carrier) :
    (∃ g ∈ Fintype.piFinset Sp,
        (BracketFormula.mk (fun i => efPointTPFin atomMap h_surj (g i))
          (fun j => efIntervalSetTPFin atomMap h_surj (Ss j))).holds N atomMap z0 z1)
      ↔ bf.holds N atomMap z0 z1 := by
  classical
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  rcases Nat.eq_zero_or_pos m with hm | hm
  · -- No interior witnesses: the bracket is just its single segment predicate on (z0, z1).
    subst hm
    rw [IntervalPattern.holds_eq_zero (h := rfl)]
    constructor
    · rintro ⟨g, -, hbody⟩
      rw [IntervalPattern.holds_eq_zero (h := rfl)] at hbody
      intro y hy0 hy1
      have hb := hbody y hy0 hy1
      rw [efIntervalSetTPFin_eval] at hb
      rw [← hSs ⟨0, by omega⟩ y]
      exact hb
    · intro hbody
      refine ⟨Fin.elim0, Fintype.mem_piFinset.mpr (fun i => i.elim0), ?_⟩
      rw [IntervalPattern.holds_eq_zero (h := rfl)]
      intro y hy0 hy1
      rw [efIntervalSetTPFin_eval, hSs ⟨0, by omega⟩ y]
      exact hbody y hy0 hy1
  · -- k+1 interior witnesses.
    obtain ⟨k, hk⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
    rw [IntervalPattern.holds_eq_succ (h := hk)]
    constructor
    · rintro ⟨g, hg, hbody⟩
      rw [IntervalPattern.holds_eq_succ (h := hk)] at hbody
      obtain ⟨w, hmono, hrange, hpt, hb0, hbmid, hblast⟩ := hbody
      have hgmem := Fintype.mem_piFinset.mp hg
      refine ⟨w, hmono, hrange, ?_, ?_, ?_, ?_⟩
      · intro i
        rw [← hSp ⟨i.val, by omega⟩ (w i)]
        exact ⟨g ⟨i.val, by omega⟩, hgmem _,
          (efPointTPFin_eval N atomMap h_surj _ (w i)).mp (hpt i)⟩
      · intro y hy0 hy1
        rw [← hSs ⟨0, by omega⟩ y, ← efIntervalSetTPFin_eval N atomMap h_surj]
        exact hb0 y hy0 hy1
      · intro i y hy0 hy1
        rw [← hSs ⟨i.val + 1, by omega⟩ y, ← efIntervalSetTPFin_eval N atomMap h_surj]
        exact hbmid i y hy0 hy1
      · intro y hy0 hy1
        rw [← hSs ⟨k + 1, by omega⟩ y, ← efIntervalSetTPFin_eval N atomMap h_surj]
        exact hblast y hy0 hy1
    · rintro ⟨w, hmono, hrange, hpt, hb0, hbmid, hblast⟩
      -- Build the completion tuple g from the realizers at each interior witness.
      have hchoice : ∀ i : Fin m, ∃ τ ∈ Sp i, partialHolds N τ (w ⟨i.val, by omega⟩) := by
        intro i
        obtain ⟨τ, hτS, hτ⟩ := (hSp i (w ⟨i.val, by omega⟩)).mpr (by
          have hpt' := hpt ⟨i.val, by omega⟩
          simpa using hpt')
        exact ⟨τ, hτS, hτ⟩
      obtain ⟨g, hg, hgpt⟩ := (exists_piFinset_forall_iff Sp
        (fun i τ => partialHolds N τ (w ⟨i.val, by omega⟩))).mpr hchoice
      refine ⟨g, hg, ?_⟩
      rw [IntervalPattern.holds_eq_succ (h := hk)]
      refine ⟨w, hmono, hrange, ?_, ?_, ?_, ?_⟩
      · intro i
        exact (efPointTPFin_eval N atomMap h_surj _ (w i)).mpr
          (by simpa using hgpt ⟨i.val, by omega⟩)
      · intro y hy0 hy1
        rw [efIntervalSetTPFin_eval, hSs ⟨0, by omega⟩ y]
        exact hb0 y hy0 hy1
      · intro i y hy0 hy1
        rw [efIntervalSetTPFin_eval, hSs ⟨i.val + 1, by omega⟩ y]
        exact hbmid i y hy0 hy1
      · intro y hy0 hy1
        rw [efIntervalSetTPFin_eval, hSs ⟨k + 1, by omega⟩ y]
        exact hblast y hy0 hy1

/-- Fin-variant of `collapseEF`: the per-tuple endpoint-pinned per-formula `∃∀`-formula for the
reverse collapse, over a single ambient mentioned set `M` — endpoint completions `τ_L`/`τ_R`,
interior tuple `g`, captured segment sets `Ss`, both unbounded caps `intervalTopFin M`
(Rabinovich's vacuous caps). -/
noncomputable def collapseEFFin {sig : MonadicSignature} {F : Finset Formula}
    {M : Finset (AtomKind (sigE sig F) 1)} {m : Nat}
    (Ss : Fin (m + 1) → IntervalTypeFin sig F M)
    (τ_L τ_R : UnaryTypeFin sig F M) (g : Fin m → UnaryTypeFin sig F M) :
    ExistsForallFormulaFin sig F 2 where
  n := m + 1
  M := M
  pin := fun i => if i.val = 0 then 0 else Fin.last (m + 1)
  pointType := Fin.cons τ_L (Fin.snoc g τ_R)
  intervalType := Fin.cons (intervalTopFin M) (Fin.snoc Ss (intervalTopFin M))

/-- Fin-variant of `collapseEF_cap`: `collapseEFFin` is endpoint-pinned with trivial caps on
the partial relation (`intervalHoldsFin_top`). -/
theorem collapseEFFin_cap {sig : MonadicSignature} {F : Finset Formula}
    {M : Finset (AtomKind (sigE sig F) 1)} {m : Nat}
    (N : OrderedMonadicStructure (sigE sig F))
    (Ss : Fin (m + 1) → IntervalTypeFin sig F M)
    (τ_L τ_R : UnaryTypeFin sig F M) (g : Fin m → UnaryTypeFin sig F M) :
    EndpointPinnedCapTrivialFin N (collapseEFFin Ss τ_L τ_R g) where
  posN := Nat.le_add_left 1 m
  pinLeft := rfl
  pinRight := rfl
  capTrivialLeft := fun y => by
    simp only [collapseEFFin, Fin.cons_zero]
    exact intervalHoldsFin_top N y
  capTrivialRight := fun y => by
    simp only [collapseEFFin]
    rw [← Fin.succ_last, Fin.cons_succ, Fin.snoc_last]
    exact intervalHoldsFin_top N y

/-- Fin-variant of `collapseEF_translate`: `translateProp42Fin` reads the endpoint/interior
point types and segment sets of `collapseEFFin` back out — exactly `τ_L`, `τ_R`, the interior
`g i`, and the captured segments `Ss j`, via the `Fin.cons`/`Fin.snoc` lemmas. -/
theorem collapseEFFin_translate {sig : MonadicSignature} {F : Finset Formula}
    {M : Finset (AtomKind (sigE sig F) 1)} {m : Nat}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (Ss : Fin (m + 1) → IntervalTypeFin sig F M)
    (τ_L τ_R : UnaryTypeFin sig F M) (g : Fin m → UnaryTypeFin sig F M) :
    translateProp42Fin atomMap h_surj (collapseEFFin Ss τ_L τ_R g) =
      ⟨efPointTPFin atomMap h_surj τ_L, efPointTPFin atomMap h_surj τ_R,
       ⟨fun i => efPointTPFin atomMap h_surj (g i),
        fun j => efIntervalSetTPFin atomMap h_surj (Ss j)⟩⟩ := by
  have hpt0 : (collapseEFFin Ss τ_L τ_R g).pointType 0 = τ_L := by
    simp only [collapseEFFin, Fin.cons_zero]
  have hptlast :
      (collapseEFFin Ss τ_L τ_R g).pointType (Fin.last (collapseEFFin Ss τ_L τ_R g).n) = τ_R := by
    simp only [collapseEFFin]
    rw [← Fin.succ_last, Fin.cons_succ, Fin.snoc_last]
  have hpti : ∀ i : Fin m,
      (collapseEFFin Ss τ_L τ_R g).pointType (⟨i.val + 1, by omega⟩ : Fin (m + 2)) = g i := by
    intro i
    simp only [collapseEFFin]
    rw [show (⟨i.val + 1, by omega⟩ : Fin (m + 2)) = (i.castSucc).succ from by
          apply Fin.ext; simp [Fin.val_succ],
      Fin.cons_succ, Fin.snoc_castSucc]
  have hsj : ∀ j : Fin (m + 1),
      (collapseEFFin Ss τ_L τ_R g).intervalType (⟨j.val + 1, by omega⟩ : Fin (m + 3)) = Ss j := by
    intro j
    simp only [collapseEFFin]
    rw [show (⟨j.val + 1, by omega⟩ : Fin (m + 3)) = (j.castSucc).succ from by
          apply Fin.ext; simp [Fin.val_succ],
      Fin.cons_succ, Fin.snoc_castSucc]
  unfold translateProp42Fin
  simp only [hpt0, hptlast, hpti, hsj]

/-- **Fin-variant of `vvecea2_collapse_bridge` (Rabinovich Def 4.1, p.5-6), conditional on the
`M`-relative capture hypothesis.** Every `VVecEA2` object `v'` is lifted back to a
`VeeExistsForallFin` object satisfied exactly when `v'` holds on strictly-ordered pairs. Each
clause's captured endpoint/point/segment sets (each over its own mentioned set) are first
expanded to the clause's ambient union `M` (`intervalExpandFin`), so the per-tuple objects
`collapseEFFin` are single-`M` per-formula objects; per-disjunct `M`s differ freely inside the
resulting `VeeExistsForallFin` (each disjunct bundles its own `M`). `hCapture` is threaded,
NOT discharged (Phase ζ); `h_INF`/`h_SUP` carried for threading uniformity. -/
theorem vvecea2_collapse_bridgeFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (_h_INF : HasAttainedINF N atomMap) (_h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ (M : Finset (AtomKind (sigE sig F) 1))
        (S : IntervalTypeFin sig F M),
        ∀ y : N.carrier, intervalHoldsFin N S y ↔ temporal_truth N atomMap y A)
    (v' : VVecEA2) :
    ∃ Φ : VeeExistsForallFin sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSatFin N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  classical
  choose Mcap Scap hcap using hCapture
  -- Ambient mentioned set of one clause: union of all its captured sets' mentioned sets.
  let MA : (Σ n, VecEA2 n) → Finset (AtomKind (sigE sig F) 1) := fun vea =>
    ((Mcap vea.2.endpointLeft.formula ∪ Mcap vea.2.endpointRight.formula) ∪
      Finset.univ.sup fun i : Fin vea.1 => Mcap (vea.2.bracket.pointTypes i).formula) ∪
      Finset.univ.sup fun j : Fin (vea.1 + 1) => Mcap (vea.2.bracket.segmentTypes j).formula
  have subL : ∀ vea : Σ n, VecEA2 n, Mcap vea.2.endpointLeft.formula ⊆ MA vea := fun vea =>
    (Finset.subset_union_left.trans Finset.subset_union_left).trans Finset.subset_union_left
  have subR : ∀ vea : Σ n, VecEA2 n, Mcap vea.2.endpointRight.formula ⊆ MA vea := fun vea =>
    (Finset.subset_union_right.trans Finset.subset_union_left).trans Finset.subset_union_left
  have subP : ∀ (vea : Σ n, VecEA2 n) (i : Fin vea.1),
      Mcap (vea.2.bracket.pointTypes i).formula ⊆ MA vea := fun vea i =>
    (Finset.le_iff_subset.mp (Finset.le_sup
        (f := fun i => Mcap (vea.2.bracket.pointTypes i).formula) (Finset.mem_univ i))).trans
      (Finset.subset_union_right.trans Finset.subset_union_left)
  have subS : ∀ (vea : Σ n, VecEA2 n) (j : Fin (vea.1 + 1)),
      Mcap (vea.2.bracket.segmentTypes j).formula ⊆ MA vea := fun vea j =>
    (Finset.le_iff_subset.mp (Finset.le_sup
        (f := fun j => Mcap (vea.2.bracket.segmentTypes j).formula) (Finset.mem_univ j))).trans
      Finset.subset_union_right
  refine vvecea2_collapse_of_perClauseListFin N atomMap v'
    (fun vea =>
      ((intervalExpandFin (subL vea) (Scap vea.2.endpointLeft.formula)) ×ˢ
        (intervalExpandFin (subR vea) (Scap vea.2.endpointRight.formula)) ×ˢ
        Fintype.piFinset (fun i =>
          intervalExpandFin (subP vea i) (Scap (vea.2.bracket.pointTypes i).formula))).toList.map
        (fun t => collapseEFFin
          (fun j => intervalExpandFin (subS vea j) (Scap (vea.2.bracket.segmentTypes j).formula))
          t.1 t.2.1 t.2.2))
    ?_
  rintro ⟨m, vc⟩ hvea env henv
  dsimp only
  set S_L := intervalExpandFin (subL ⟨m, vc⟩) (Scap vc.endpointLeft.formula) with hSL
  set S_R := intervalExpandFin (subR ⟨m, vc⟩) (Scap vc.endpointRight.formula) with hSR
  set Sp := fun i : Fin m =>
    intervalExpandFin (subP ⟨m, vc⟩ i) (Scap (vc.bracket.pointTypes i).formula) with hSp_def
  set Ss := fun j : Fin (m + 1) =>
    intervalExpandFin (subS ⟨m, vc⟩ j) (Scap (vc.bracket.segmentTypes j).formula) with hSs_def
  -- Per-tuple correctness: efSatFin of the endpoint-pinned EF ↔ completed clause on (env 0, env 1).
  have hcorrect : ∀ (τ_L τ_R : UnaryTypeFin sig F (MA ⟨m, vc⟩))
      (g : Fin m → UnaryTypeFin sig F (MA ⟨m, vc⟩)),
      efSatFin N env (collapseEFFin Ss τ_L τ_R g) ↔
        partialHolds N τ_L (env 0) ∧ partialHolds N τ_R (env 1) ∧
        (BracketFormula.mk (fun i => efPointTPFin atomMap h_surj (g i))
          (fun j => efIntervalSetTPFin atomMap h_surj (Ss j))).holds N atomMap (env 0) (env 1) := by
    intro τ_L τ_R g
    rw [translateProp42Fin_correct N atomMap h_surj env (collapseEFFin Ss τ_L τ_R g)
          (collapseEFFin_cap N Ss τ_L τ_R g) henv,
        collapseEFFin_translate atomMap h_surj Ss τ_L τ_R g]
    constructor
    · rintro ⟨hL, hR, hbr⟩
      exact ⟨(efPointTPFin_eval N atomMap h_surj τ_L (env 0)).mp hL,
             (efPointTPFin_eval N atomMap h_surj τ_R (env 1)).mp hR, hbr⟩
    · rintro ⟨hL, hR, hbr⟩
      exact ⟨(efPointTPFin_eval N atomMap h_surj τ_L (env 0)).mpr hL,
             (efPointTPFin_eval N atomMap h_surj τ_R (env 1)).mpr hR, hbr⟩
  -- Capture facts for endpoints and bracket predicates, through the expansion.
  have hSpcap : ∀ (i : Fin m) (y : N.carrier),
      intervalHoldsFin N (Sp i) y ↔ (vc.bracket.pointTypes i).eval_at N atomMap y := fun i y =>
    (intervalHoldsFin_expandFin_iff N (subP ⟨m, vc⟩ i) _ y).trans
      (hcap (vc.bracket.pointTypes i).formula y)
  have hSscap : ∀ (j : Fin (m + 1)) (y : N.carrier),
      intervalHoldsFin N (Ss j) y ↔ (vc.bracket.segmentTypes j).eval_at N atomMap y := fun j y =>
    (intervalHoldsFin_expandFin_iff N (subS ⟨m, vc⟩ j) _ y).trans
      (hcap (vc.bracket.segmentTypes j).formula y)
  rw [VecEA2.holds]
  constructor
  · -- forward
    rintro ⟨ψ, hψmem, hsat⟩
    rw [List.mem_map] at hψmem
    obtain ⟨t, htmem, rfl⟩ := hψmem
    rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product] at htmem
    obtain ⟨htL, htR, htg⟩ := htmem
    rw [hcorrect] at hsat
    obtain ⟨huL, huR, hbr⟩ := hsat
    refine ⟨?_, ?_, ?_⟩
    · exact (hcap vc.endpointLeft.formula (env 0)).mp
        ((intervalHoldsFin_expandFin_iff N (subL ⟨m, vc⟩) _ (env 0)).mp ⟨t.1, htL, huL⟩)
    · exact (hcap vc.endpointRight.formula (env 1)).mp
        ((intervalHoldsFin_expandFin_iff N (subR ⟨m, vc⟩) _ (env 1)).mp ⟨t.2.1, htR, huR⟩)
    · exact (bracket_completion_iffFin N atomMap h_surj vc.bracket Sp Ss hSpcap hSscap
        (env 0) (env 1)).mp ⟨t.2.2, htg, hbr⟩
  · -- backward
    rintro ⟨heL, heR, hbrk⟩
    have hiL : intervalHoldsFin N S_L (env 0) :=
      (intervalHoldsFin_expandFin_iff N (subL ⟨m, vc⟩) _ (env 0)).mpr
        ((hcap vc.endpointLeft.formula (env 0)).mpr heL)
    have hiR : intervalHoldsFin N S_R (env 1) :=
      (intervalHoldsFin_expandFin_iff N (subR ⟨m, vc⟩) _ (env 1)).mpr
        ((hcap vc.endpointRight.formula (env 1)).mpr heR)
    obtain ⟨τ_L, hτL, huL⟩ := hiL
    obtain ⟨τ_R, hτR, huR⟩ := hiR
    obtain ⟨g, hg, hbr⟩ := (bracket_completion_iffFin N atomMap h_surj vc.bracket Sp Ss
      hSpcap hSscap (env 0) (env 1)).mpr hbrk
    refine ⟨collapseEFFin Ss τ_L τ_R g, ?_, ?_⟩
    · rw [List.mem_map]
      exact ⟨(τ_L, τ_R, g), by
        rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product]
        exact ⟨hτL, hτR, hg⟩, rfl⟩
    · rw [hcorrect]
      exact ⟨huL, huR, hbr⟩

end FinLayer

end Bimodal.Metalogic.WeakCanonical.Kamp
