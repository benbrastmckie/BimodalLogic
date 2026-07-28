/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# The faithful three-disjunct `Oₙ₊₁` over `HasFaithfulDedekindINF` (Rabinovich, PDF p.8)

Rabinovich's **printed** inductive step for Lemma 5.3 has THREE disjuncts. The landed
`negChainOn` (`EANegationFix/OnBuilder.lean:179`) truncates to TWO and assumes the strictly
stronger `HasAttainedINF`. This module restores the third and carries the whole construction on
`HasFaithfulDedekindINF` (`KPlusFaithful.lean:320`), which states eq (5.2) verbatim **with the
sources' `K⁺`**.

`Oₙ₊₁` for `P :: rest`, exactly as printed on p.8:

1. `(∀y)^{<z₁}_{>z₀}¬P(y)`
2. `K⁺(P)(z₀) ∧ Oₙ(rest, z₀, z₁)`                                     — **restored here**
3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P) ∧ Oₙ(rest, r₀, z₁))`

with eq (5.2)
`INF(z₀,r₀,z₁,P) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P(y) ∧ (P(r₀) ∨ K⁺(P)(r₀))`.

## ADAPTED-FROM: this module previously pinned `HasDedekindINF` (`DedekindINF.lean:136`)

**What changed, in one clause**: disjunct (2)'s left conjunct moved from the tree's `kplus`
(`PriorINF.lean:86`, which carries an extra `¬P(z₀)` conjunct that neither source states) to the
sources' own `K⁺` — `Formula.kPlus` (`Syntax/Formula.lean:180`) at the object level, `kplusOpen`
(`KPlusFaithful.lean:113`) at the `Prop` level. Nothing else about the transcription moved: the
three printed disjuncts, the recursion on `(z₀,z₁)` in the boundary subcase, and eq (5.2)'s point
condition `P(r₀) ∨ K⁺(P)(r₀)` — whose `K⁺` is *still* the tree's `kplus`, because
`HasFaithfulDedekindINF`'s right disjunct is literally `HasDedekindINF`'s — are unchanged.

Rabinovich's printed subcase split (PDF p.9) is on `r₀ = z₀` versus `r₀ ∈ (z₀,z₁)`, and
`K⁺(P₁)(z₀)` is his definable proxy for the first. At **his** `K⁺` (Definition (3), PDF p.3:
*"`K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`"*) the proxy is
exact; at the tree's `kplus` it is strictly stronger, and the gap is precisely a point at which
`P` holds and also recurs arbitrarily soon above. Disjunct (2) is now gated on the exact proxy.

**Nothing is weakened by this.** `HasDedekindINF.toHasFaithfulDedekindINF`
(`KPlusFaithful.lean:364`) keeps every current supplier — the whole discrete/attained pipeline —
and `negChainOnFaithful_iff` therefore proves *more* than it did: it now also covers structures
on which `P` holds at `z₀` and recurs above it, which the previous carrier could not describe.

The result type is `VVecEA2`, **not** `VBracketFormula`: disjunct (2) conjoins the endpoint
predicate `K⁺(P)` at `z₀`, which a `VBracketFormula` cannot carry. That type difference is the
whole reason the faithful version cannot be spliced into the landed attained stack in place.

Nothing here is deleted from, or weakens, the attained-carrier transcription in `EANegationFix/`:
these declarations are **additions**, and the attained versions reach them through the landed
shims (`HasAttainedINF.toHasDedekindINF`, `DedekindINF.lean:172`).

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
Everything below cites **PDF p.8**. The companion `.md` conversion is corrupt and is never
ground truth.

## What this carrier EXCLUDES — read this before citing anything below

Extended non-vacuity rule: *every module that lands or weakens a carrier must state what that
carrier excludes.* An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly
as a vacuous conclusion does. Three statements are needed here, and all three are made as code
rather than as prose.

1. **`lemma53Faithful` is the HOISTED shape**, `∃ O, ∀ M atomMap z₀ z₁`. That is what "is
   equivalent to a `∨∃⃗∀` formula" means: `O` is a function of `P` alone. The per-point
   ordering (`∃ O` *inside* `∀ z₀ z₁`) is a different and worthless statement — it is provable
   with **no carrier hypothesis at all**, and `lemma53Faithful_perPoint_is_VACUOUS` below
   compiles exactly that way as the failed-vacuity control.
2. **`HasFaithfulDedekindINF` excludes** chains on which a first occurrence of `P` in `(z₀,z₁)`
   has an infimum that is none of the paper's printed shapes: eq (5.2) requires the infimum `r₀`
   to satisfy `r₀ = z₀` (equivalently, at the sources' `K⁺`, `kplusOpen P z₀`) or
   `r₀ ∈ (z₀,z₁)` with `P(r₀) ∨ K⁺(P)(r₀)`. The strengthening chain is
   `Rabinovich's Dedekind completeness < HasFaithfulDedekindINF < HasDedekindINF <
   HasDefinableINF < HasAttainedINF`,
   so this carrier is still stronger than the paper's hypothesis, but by one link less than the
   carrier this module previously took. `KPlusFaithful.lean:311-319` states the exclusion in
   full, including what the faithful carrier **admits** that `HasDedekindINF` refuses.
3. **Disjunct (2) is provably dead on every Prior structure, at BOTH `K⁺` spellings.**
   `prior_makes_faithful_disjunct2_unreachable` below proves it for the source-exact `K⁺` now
   gating disjunct (2), and `prior_makes_disjunct2_unreachable` — kept, and now derived from it —
   proves it for the tree's `kplus`. Consequently the re-base is contentful mathematics whose
   content **is not yet reachable from any live consumer**: the live chain is Prior structures,
   where attainment holds outright. Observability arrives only with a genuinely non-attained
   Dedekind-complete frame class, which is not constructed anywhere in this tree
   (`DedekindINF.lean:49-50` states that absence explicitly).
   `hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) must **not** be cited against
   this: its proof is `Or.inl h_kplus` and its own docstring admits it exhibits no structure.

   **Weakening the carrier did not weaken this exclusion** — that was the live risk, since
   `kplusOpen` is implied by `kplus` and a weaker gate could in principle fire where the stronger
   one cannot. It does not: attainment kills `kplusOpen P z₀` outright, because an attained first
   occurrence `r₀ > z₀` with `¬P` on `(z₀,r₀)` contradicts `P` occurring in *every* `(z₀,s)`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## `K⁺(P)` as a `TemporalPred` -/

/-- `K⁺(P)` as a point type. `kplusFormula` (`PriorINF.lean:93`) is the object-language
    spelling; `kplus_formula_correct` (`Lemma53.lean:162`) is its correctness lemma.

    Source correspondence: PDF p.8, *"K⁺(P₁)(z₀) is an atomic ... formula in the canonical
    expansion"*. The tree needs no canonical expansion: `K⁺` is outright TL-definable here. -/
noncomputable def kplusPred (P : TemporalPred) : TemporalPred := ⟨kplusFormula P.formula⟩

theorem kplusPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    (kplusPred P).EvalAt M atomMap t ↔ kplus M atomMap P.formula t :=
  kplus_formula_correct M atomMap P.formula t

/-- **The sources' `K⁺(P)` as a point type** — the operator Rabinovich's printed disjunct (2)
    actually asks for, and the one this module's disjunct (2) is now gated on.

    The object-language spelling needed no new formula: `Formula.kPlus`
    (`Syntax/Formula.lean:180`) has been in the tree all along, and `kPlus_formula_correct`
    (`KPlusFaithful.lean:150`) is its correctness lemma against `kplusOpen`.

    ADAPTED-FROM `kplusPred` above, which is pinned at `kplusFormula` (`PriorINF.lean:93`). What
    changed: `kplusFormula` conjoins `¬P(t)`, and that conjunct is this tree's addition. Neither
    Rabinovich 2014 (`K⁺` definition, PDF p.3 — *"`K+(F)` … is an abbreviation for
    `¬((¬F)UntilTrue)`"*) nor Reynolds 1992 (abbreviation table §1, printed p.168 — `K⁺A` for
    `¬U(⊤,¬A)`, *"`A` will be true arbitrarily soon"*) says anything about the point of
    evaluation. `Syntax/Formula.lean:163-179` carries the standing name-collision warning between
    the two spellings; this declaration is the `TemporalPred`-level side of that distinction.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8 — *"`K⁺(P₁)(z₀)` is an atomic (and
    hence a `∨∃⃗∀`) formula in the canonical expansion"*. As for `kplusPred`, no canonical
    expansion is needed here: `K⁺` is outright TL-definable. -/
def kplusOpenPred (P : TemporalPred) : TemporalPred := ⟨Formula.kPlus P.formula⟩

/-- `kplusOpenPred` evaluates to the sources' semantic `K⁺`. Mirror of `kplusPred_eval`, routed
    through the bridge lemma `kPlus_formula_correct` (`KPlusFaithful.lean:150`) rather than
    through `kplus_formula_correct` (`Lemma53.lean:162`). -/
theorem kplusOpenPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    (kplusOpenPred P).EvalAt M atomMap t ↔ kplusOpen M atomMap P.formula t :=
  kPlus_formula_correct M atomMap P.formula t

/-! ## The `VVecEA2`-level prepend

`VBracketFormula.prependAll` (`EANegation.lean:312`) cannot be reused: the recursive `Oₙ` is now
a `VVecEA2` carrying its own `endpointLeft` **at `r₀`**, which must be absorbed into the point
type at `r₀`. That absorption is the only new construction disjunct (3) needs. -/

/-- Prepend a `¬P₁` segment and a point type at `r₀` to every disjunct of a `VVecEA2`,
    absorbing that disjunct's left-endpoint predicate (which lives at `r₀`) into the point type.

    Source correspondence: PDF p.8, disjunct (3)
    `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))`. -/
def VVecEA2.prependAllVec (segLeft ptType : TemporalPred) (v : VVecEA2) : VVecEA2 :=
  ⟨v.disjuncts.map fun d =>
    ⟨d.1 + 1,
      { endpointLeft := TemporalPred.top
        endpointRight := d.2.endpointRight
        bracket := d.2.bracket.prepend segLeft (ptType.conj d.2.endpointLeft) }⟩⟩

theorem VVecEA2.prependAllVec_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (segLeft ptType : TemporalPred) (v : VVecEA2) (z0 z1 : M.carrier) :
    (v.prependAllVec segLeft ptType).holds M atomMap z0 z1 ↔
      ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        ptType.EvalAt M atomMap r0 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → segLeft.EvalAt M atomMap y) ∧
        v.holds M atomMap r0 z1 := by
  simp only [prependAllVec, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨_, ⟨⟨m, vea⟩, hmem, rfl⟩, hEL, hER, hbr⟩
    obtain ⟨r0, ha, hb, hPt, hSeg, htail⟩ :=
      BracketFormula.prepend_holds_inv M atomMap vea.bracket segLeft
        (ptType.conj vea.endpointLeft) z0 z1 hbr
    rw [TemporalPred.eval_at_conj] at hPt
    exact ⟨r0, ha, hb, hPt.1, hSeg, ⟨m, vea⟩, hmem, hPt.2, hER, htail⟩
  · rintro ⟨r0, ha, hb, hPt, hSeg, ⟨m, vea⟩, hmem, hEL, hER, hbr⟩
    refine ⟨_, ⟨⟨m, vea⟩, hmem, rfl⟩, TemporalPred.top_eval_at M atomMap z0, hER, ?_⟩
    exact BracketFormula.prepend_holds M atomMap vea.bracket segLeft
      (ptType.conj vea.endpointLeft) z0 z1 r0 ha hb
      ((TemporalPred.eval_at_conj M atomMap _ _ r0).mpr ⟨hPt, hEL⟩) hSeg hbr

/-! ## Disjunct (2)'s backward half

The paper's `Subcase r₀ = z₀`. `K⁺(P₁)(z₀)` says `P₁` occurs in *every* interval above `z₀`, so
a tail chain on `(z₀,z₁)` can always be extended downward by one `P₁`-point. -/

/-- **Disjunct (2), backward half** (PDF p.8): given `K⁺(P₁)(z₀)` **at the sources' `K⁺`**, a chain
    for the tail on `(z₀,z₁)` extends to a chain for `P₁ :: tail` on the *same* interval. This is
    precisely why the paper's `Subcase r₀ = z₀` recurses on `(z₀,z₁)` rather than on a shrunken
    interval.

    ADAPTED-FROM `orderedPointsExist_combine_kplus` below, which took the tree's `kplus`. What
    changed: the hypothesis, and the first line of the proof. The landed proof opened `hk` as
    `obtain ⟨-, hdense⟩ := hk`, **discarding the `¬P(z₀)` conjunct unused** — so the conjunct was
    never doing work here, and dropping it costs nothing. Everything below the first line is the
    landed proof unaltered.

    Source correspondence: Rabinovich 2014, Lemma 5.3, `Subcase r₀ = z₀`, PDF pp.8-9. -/
theorem orderedPointsExist_combine_kplusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) (hlt : z0 < z1)
    (hk : kplusOpen M atomMap (Ps ⟨0, Nat.succ_pos n⟩).formula z0)
    (h_tail : orderedPointsExist M atomMap n (fun i => Ps i.succ) z0 z1) :
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
  have hdense := hk
  match n with
  | 0 =>
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense z1 hlt
    exact orderedPointsExist_combine M atomMap 0 Ps z0 z1 r hr1 hr2 hPr
      (orderedPointsExist_zero M atomMap _ r z1)
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at h_tail
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := h_tail
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense (w ⟨0, Nat.succ_pos n'⟩) (hrange ⟨0, Nat.succ_pos n'⟩).1
    refine orderedPointsExist_combine M atomMap (n' + 1) Ps z0 z1 r hr1
      (lt_trans hr2 (hrange ⟨0, Nat.succ_pos n'⟩).2) hPr ?_
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
    refine ⟨w, hmono, ?_, hpoint, ?_, ?_, ?_⟩
    · intro j
      refine ⟨lt_of_lt_of_le hr2 ?_, (hrange j).2⟩
      rcases Nat.eq_zero_or_pos j.val with hj | hj
      · exact le_of_eq (congrArg w (Fin.ext hj.symm))
      · exact le_of_lt (hmono ⟨0, Nat.succ_pos n'⟩ j (Fin.mk_lt_mk.mpr hj))
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- **Disjunct (2), backward half, at the tree's `kplus`.** Retained verbatim in statement, and
    now *derived* from the source-exact version above rather than re-proved, so nothing is
    duplicated in substance: `kplus` is `kplusOpen` plus a conjunct this proof never reads
    (`kplusOpen_of_kplus`, `KPlusFaithful.lean:212`).

    Kept because eq (5.2)'s point condition still says `P(r₀) ∨ kplus P r₀` — the faithful
    carrier's right disjunct is literally `HasDedekindINF`'s — so `negChainOnFaithful_iff` still
    reaches this spelling at `r₀`, even though it no longer reaches it at `z₀`. -/
theorem orderedPointsExist_combine_kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) (hlt : z0 < z1)
    (hk : kplus M atomMap (Ps ⟨0, Nat.succ_pos n⟩).formula z0)
    (h_tail : orderedPointsExist M atomMap n (fun i => Ps i.succ) z0 z1) :
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 :=
  orderedPointsExist_combine_kplusOpen M atomMap n Ps z0 z1 hlt (kplusOpen_of_kplus hk) h_tail

/-- Widening the left endpoint is free: a chain on `(r₀,z₁)` is a chain on `(z₀,z₁)` whenever
    `z₀ < r₀`. Needed by eq (5.2)'s `K⁺(P₁)(r₀)` alternative, where the witness produced at `r₀`
    must be reported back on the outer interval. -/
theorem orderedPointsExist_widen_left {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin n → TemporalPred) (z0 r0 z1 : M.carrier) (h : z0 < r0)
    (hc : orderedPointsExist M atomMap n Ps r0 z1) :
    orderedPointsExist M atomMap n Ps z0 z1 := by
  match n with
  | 0 => exact orderedPointsExist_zero M atomMap _ z0 z1
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at hc ⊢
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := hc
    exact ⟨w, hmono, fun j => ⟨lt_trans h (hrange j).1, (hrange j).2⟩, hpoint,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun _ y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## The faithful three-disjunct `Oₙ₊₁` (PDF p.8) -/

/-- Disjunct (2)'s endpoint block, alone: `K⁺(P₁)(z₀)` with a trivial interval and right
    endpoint. Conjoined with `Oₙ(rest)` via `VVecEA2.conjFull` (`VecEAConjFull.lean:498`),
    which conjoins `endpointLeft` pairwise — exactly what disjunct (2) needs. -/
noncomputable def kplusLeftBlock (P : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := kplusPred P
          endpointRight := TemporalPred.top
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

theorem kplusLeftBlock_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (kplusLeftBlock P).holds M atomMap z0 z1 ↔ kplus M atomMap P.formula z0 := by
  simp only [kplusLeftBlock, VVecEA2.holds, List.mem_singleton, exists_eq_left, VecEA2.holds]
  rw [BracketFormula.trivial_holds]
  constructor
  · rintro ⟨h, -, -⟩; exact (kplusPred_eval M atomMap P z0).mp h
  · intro h
    exact ⟨(kplusPred_eval M atomMap P z0).mpr h, TemporalPred.top_eval_at M atomMap z1,
      fun y _ _ => TemporalPred.top_eval_at M atomMap y⟩

/-- **Disjunct (2)'s endpoint block at the sources' `K⁺`**: `K⁺(P₁)(z₀)` with a trivial interval
    and right endpoint, conjoined with `Oₙ(rest)` via `VVecEA2.conjFull`
    (`VecEAConjFull.lean:498`).

    ADAPTED-FROM `kplusLeftBlock` above (previously pinned at `kplusPred`). What changed: the
    point type at `z₀`, `kplusPred P` → `kplusOpenPred P`. This is the block `negChainOnFaithful`
    now uses, so its `Oₙ₊₁` carries Rabinovich's own *"`K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`"*
    (PDF p.9) rather than a strictly stronger proxy of it.

    `kplusLeftBlock` is **kept**: `NegFixOneFaithful.lean:265` and `NegFixListFaithful.lean:279`
    use it for Rabinovich's Lemma 5.1 Case 1 `K⁺(¬β₁)(z₀)`, which is re-based in its own phase. -/
def kplusOpenLeftBlock (P : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := kplusOpenPred P
          endpointRight := TemporalPred.top
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

theorem kplusOpenLeftBlock_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (kplusOpenLeftBlock P).holds M atomMap z0 z1 ↔ kplusOpen M atomMap P.formula z0 := by
  simp only [kplusOpenLeftBlock, VVecEA2.holds, List.mem_singleton, exists_eq_left, VecEA2.holds]
  rw [BracketFormula.trivial_holds]
  constructor
  · rintro ⟨h, -, -⟩; exact (kplusOpenPred_eval M atomMap P z0).mp h
  · intro h
    exact ⟨(kplusOpenPred_eval M atomMap P z0).mpr h, TemporalPred.top_eval_at M atomMap z1,
      fun y _ _ => TemporalPred.top_eval_at M atomMap y⟩

/-- **The faithful `Oₙ` (PDF p.8), all three printed disjuncts.**

    * `[] ↦ ⊥` (the empty chain always exists, so its negation is `False`)
    * `P :: rest ↦`
      1. `(∀y)^{<z₁}_{>z₀}¬P(y)`                              — `oOne P`
      2. `K⁺(P)(z₀) ∧ Oₙ(rest, z₀, z₁)`                        — **RESTORED HERE**
      3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P) ∧ Oₙ(rest, r₀, z₁))`

    Disjunct (3)'s point type at `r₀` is `P ∨ K⁺(P)` — eq (5.2)'s third conjunct, needing
    `TemporalPred.disj` (`ExistsForallNF.lean:87`). Result type is `VVecEA2`, not
    `VBracketFormula`: disjunct (2) conjoins an endpoint predicate at `z₀`.

    ADAPTED-FROM the `HasDedekindINF`-era spelling of this definition. What changed: **one
    identifier** — disjunct (2)'s block is `kplusOpenLeftBlock` where it was `kplusLeftBlock`, so
    the `K⁺` at `z₀` is now Rabinovich's own (PDF p.3 Definition (3)) rather than the tree's
    conjunct-carrying `kplus`. Disjunct (3)'s point type is deliberately left at `kplusPred`:
    eq (5.2)'s third conjunct is `P(r₀) ∨ K⁺(P)(r₀)` and, **as a disjunction**, that is
    interderivable between the two spellings, so `HasFaithfulDedekindINF` keeps
    `HasDedekindINF`'s right disjunct character-for-character and nothing at `r₀` needs to move. -/
noncomputable def negChainOnFaithful : List TemporalPred → VVecEA2
  | [] => ⟨[]⟩
  | P :: rest =>
    ((oOne P).disj
      ((kplusOpenLeftBlock P).conjFull (negChainOnFaithful rest))).disj
        ((negChainOnFaithful rest).prependAllVec P.neg (P.disj (kplusPred P)))

/-- **Lemma 5.3, faithful form (PDF pp.8-9), over `HasFaithfulDedekindINF`.**

    Compare `negChainOn_iff` (`EANegationFix/OnBuilder.lean:189`), which proves the same shape
    with TWO disjuncts under the strictly stronger `HasAttainedINF`.

    ADAPTED-FROM the `HasDedekindINF` pin. What changed: the carrier binder, and with it the type
    of `hk` in the left arm of the `rcases` at the boundary subcase — `kplus P z₀` became
    `kplusOpen P z₀`. **The two-arm `rcases … with hk | ⟨r0, …⟩` shape is unchanged**, and so is
    every tactic in the proof except the two lines that name the boundary-subcase primitive.
    The carrier is strictly weaker (`HasDedekindINF.toHasFaithfulDedekindINF`), so this statement
    is strictly stronger than the one it replaces.

    Rabinovich's printed `Oₙ₊₁`, verbatim (PDF p.9), disjunct by disjunct against the definition
    above — *"`Oₙ₊₁` can be defined as the disjunction of "`(z₀,z₁)` is empty" and the following
    formulas: (1) `(∀y)^{<z₁}_{>z₀} ¬P₁(y)` (2) `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`
    (3) `(∃r₀)^{<z₁}_{>z₀} INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁)`"* — where his subcase split is
    *"Subcase `r₀ = z₀`: … `Oₙ(P₂,…,Pₙ,z₀,z₁)` and `Oₙ₊₁(P₁,…,Pₙ₊₁,z₀,z₁)` should be equivalent.
    Subcase `r₀ ∈ (z₀,z₁)`: Now `Oₙ(P₂,…,Pₙ,r₀,z₁)` and `Oₙ₊₁` should be equivalent."* -/
theorem negChainOnFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasFaithfulDedekindINF M atomMap)
    (Ps : List TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negChainOnFaithful Ps).holds M atomMap z0 z1 ↔
      ¬ (chainAllTrue Ps).holds M atomMap z0 z1 := by
  induction Ps generalizing z0 z1 with
  | nil =>
    rw [chainAllTrue_holds_iff]
    simp only [negChainOnFaithful, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim
      (fun h => absurd (orderedPointsExist_zero M atomMap _ z0 z1) h)
  | cons P rest ih =>
    rw [chainAllTrue_holds_iff]
    rw [negChainOnFaithful, VVecEA2.disj_holds, VVecEA2.disj_holds,
      VVecEA2.conjFull_iff, kplusOpenLeftBlock_holds, VVecEA2.prependAllVec_holds]
    constructor
    · rintro ((h1 | ⟨hk, hOn⟩) | ⟨r0, hr0a, hr0b, hPt, hSeg, hOn⟩)
      · -- Disjunct (1): `¬P` throughout `(z₀,z₁)` — no first witness can be placed.
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left] at h1
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds] at h1
        rintro ⟨w, -, hrange, hpoint, -, -, -⟩
        have := h1 (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 (hrange ⟨0, by omega⟩).2
        simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth] at this
        exact this (hpoint ⟨0, by omega⟩)
      · -- Disjunct (2): drop the first witness; the tail chain lands on the SAME interval.
        intro h_exists
        refine ((ih z0 z1 h_lt).mp hOn) ?_
        rw [chainAllTrue_holds_iff]
        exact orderedPointsExist_decompose M atomMap rest.length
          (fun i => (P :: rest).get i) z0 z1 z0
          (fun y hy0 hy1 => absurd (lt_trans hy0 hy1) (lt_irrefl z0)) h_exists
      · -- Disjunct (3): the eq (5.2) pin; the tail chain fails on `(r₀,z₁)` by IH.
        intro h_exists
        refine ((ih r0 z1 hr0b).mp hOn) ?_
        rw [chainAllTrue_holds_iff]
        exact orderedPointsExist_decompose M atomMap rest.length
          (fun i => (P :: rest).get i) z0 z1 r0
          (fun y hy0 hy1 => by
            have := hSeg y hy0 hy1
            simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth] at this
            exact this)
          h_exists
    · intro h_neg
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x
      · -- `P` occurs: the faithful carrier fires, and its LEFT disjunct is disjunct (2).
        rcases h_INF.first_occ P.formula z0 z1 h_lt
          (by obtain ⟨x, h1, h2, h3⟩ := h_occ; exact ⟨x, h1, h2, h3⟩) with
          hk | ⟨r0, hr0a, hr0b, hnone, hPr0⟩
        · -- **Subcase `r₀ = z₀`** (p.8) — the branch the attained carrier DELETES. `hk` is now
          -- the sources' `K⁺(P₁)(z₀)`; the arm's shape is otherwise unchanged.
          refine Or.inl (Or.inr ⟨hk, (ih z0 z1 h_lt).mpr ?_⟩)
          rw [chainAllTrue_holds_iff]
          intro h_tail
          exact h_neg (orderedPointsExist_combine_kplusOpen M atomMap rest.length
            (fun i => (P :: rest).get i) z0 z1 h_lt hk h_tail)
        · -- **Subcase `r₀ ∈ (z₀,z₁)`** — eq (5.2), disjunct (3).
          refine Or.inr ⟨r0, hr0a, hr0b, ?_, ?_, (ih r0 z1 hr0b).mpr ?_⟩
          · rw [TemporalPred.eval_at_disj]
            rcases hPr0 with h | h
            · exact Or.inl h
            · exact Or.inr ((kplusPred_eval M atomMap P r0).mpr h)
          · intro y hy0 hy1
            simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth]
            exact hnone y hy0 hy1
          · rw [chainAllTrue_holds_iff]
            intro h_tail
            refine h_neg ?_
            rcases hPr0 with h | h
            · -- `P₁(r₀)` attained: pin `r₀` directly.
              exact orderedPointsExist_combine M atomMap rest.length
                (fun i => (P :: rest).get i) z0 z1 r0 hr0a hr0b h h_tail
            · -- `K⁺(P₁)(r₀)`: `P₁` is not at `r₀`, so pin a point just above it, then widen.
              exact orderedPointsExist_widen_left M atomMap _ _ z0 r0 z1 hr0a
                (orderedPointsExist_combine_kplus M atomMap rest.length
                  (fun i => (P :: rest).get i) r0 z1 hr0b h h_tail)
      · -- `P` never occurs: disjunct (1).
        push Not at h_occ
        refine Or.inl (Or.inl ?_)
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left]
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
        intro y hy0 hy1
        simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth]
        exact h_occ y hy0 hy1

/-! ## `lemma53` with `HasAttainedINF` weakened to `HasFaithfulDedekindINF`

This is `lemma53` (`Lemma53.lean:432`) verbatim except for the carrier. `O` is hoisted out of
`M`, `atomMap`, `z₀`, `z₁`, so it is a function of `P` alone — which is what "is equivalent to a
`∨∃⃗∀` formula" means, and the whole content of the claim.

ADAPTED-FROM the `HasDedekindINF` pin: the binder moved one link down the strengthening chain to
`HasFaithfulDedekindINF` (`KPlusFaithful.lean:320`). Nothing else changed — the proof is the
landed one, and `HasDedekindINF.toHasFaithfulDedekindINF` keeps every previous supplier. -/

theorem lemma53Faithful {sig : MonadicSignature} {n : Nat} (P : Fin n → TemporalPred) :
    ∃ O : VVecEA2, ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds),
      HasFaithfulDedekindINF M atomMap →
      ∀ z0 z1 : M.carrier,
        O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  refine ⟨negChainOnFaithful (List.ofFn P), fun M atomMap h_INF z0 z1 => ?_⟩
  by_cases hlt : z0 < z1
  · rw [negChainOnFaithful_iff M atomMap h_INF _ z0 z1 hlt]
    exact not_congr (chainAllTrue_ofFn_iff_allTopBracket M atomMap P z0 z1)
  · match n, P with
    | 0, P =>
      -- `n = 0`: the bracket holds on every interval, so `Oₙ` must hold nowhere.
      simp only [negChainOnFaithful, List.ofFn_zero, VVecEA2.holds, List.not_mem_nil,
        false_and, exists_false]
      exact Iff.intro False.elim (fun h => absurd (allTopBracket_zero_holds M atomMap P z0 z1) h)
    | k + 1, P =>
      -- Empty interval: no witness fits, and disjunct (1) is vacuously satisfied.
      constructor
      · intro _ hb; exact hlt (allTopBracket_succ_lt M atomMap P z0 z1 hb)
      · intro _
        rw [show List.ofFn P = P 0 :: List.ofFn (fun i : Fin k => P i.succ) from by
          simp [List.ofFn_succ]]
        rw [negChainOnFaithful, VVecEA2.disj_holds, VVecEA2.disj_holds]
        refine Or.inl (Or.inl ?_)
        simp only [oOne, VVecEA2.holds, List.mem_singleton, exists_eq_left]
        rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
        intro y hy0 hy1
        exact absurd (lt_trans hy0 hy1) hlt

/-! ## Failed-vacuity control (mandatory)

The **per-point** ordering below quantifies `∃ O` *inside* `∀ z₀ z₁`. It is provable with **no
carrier hypothesis at all** — one picks the all-`⊤` block when the RHS is true and `oZero` when
it is false. That it compiles is exactly what makes it worthless, and is the control showing the
hoisted `lemma53Faithful` above is not the same statement. -/

theorem lemma53Faithful_perPoint_is_VACUOUS {sig : MonadicSignature} {n : Nat}
    (P : Fin n → TemporalPred) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (z0 z1 : M.carrier) :
    ∃ O : VVecEA2, O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  by_cases h : (allTopBracket P).holds M atomMap z0 z1
  · refine ⟨oZero, ?_⟩
    simp only [oZero, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    exact Iff.intro False.elim (fun hn => absurd h hn)
  · refine ⟨⟨[⟨0, VecEA2.fromBracket (BracketFormula.trivial TemporalPred.top)⟩]⟩, ?_⟩
    simp only [VVecEA2.holds, List.mem_singleton, exists_eq_left]
    rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
    exact Iff.intro (fun _ => h) (fun _ y _ _ => TemporalPred.top_eval_at M atomMap y)

/-! ## Extended non-vacuity: what the faithful carrier buys, and where it is OBSERVABLE

Disjunct (2) is restored above and is genuinely exercised by the proof — but on **Prior
structures** it is provably dead. This is the exclusion statement the extended non-vacuity rule
demands, stated as a theorem rather than as prose.

**Weakening disjunct (2)'s gate from `kplus` to `kplusOpen` did not resurrect it**, and that was
the live risk of this re-base: `kplus → kplusOpen`, so a weaker gate could in principle fire
where the stronger one cannot, and the module's own exclusion claim would have quietly become
false. It does not. Both spellings are dead on Prior structures, and the source-exact one is
proved dead first, with the tree's spelling derived from it. -/

/-- **On Prior structures, disjunct (2) is unreachable — at the SOURCES' `K⁺`.**

    `SemanticPriorUZ` gives `HasAttainedINF` (`prior_hasAttainedINF`, `PriorINF.lean:230`), whose
    `first_occ` hands back an attained `r₀ > z₀` with `¬P` throughout `(z₀,r₀)`. The sources' `K⁺`
    says `P` occurs in *every* interval `(z₀,s)`; instantiate it at `s := r₀` and the two collide.
    No use is made of the tree's extra `¬P(z₀)` conjunct, which is why the weaker gate is dead for
    the same reason the stronger one is.

    Consequence: `negChainOnFaithful`'s disjunct (2) — now gated on Rabinovich's own `K⁺` — can
    only ever fire on a structure that is **not** a Prior structure. No such structure is
    constructed anywhere in this tree, so the faithful re-base is not observable by any current
    consumer; it becomes observable only once a genuinely non-attained Dedekind-complete frame
    class is built.

    Source correspondence: Rabinovich 2014, `K⁺` Definition (3), PDF p.3, and Lemma 5.3
    `Subcase r₀ = z₀`, PDF pp.8-9. -/
theorem prior_makes_faithful_disjunct2_unreachable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kplusOpen M atomMap P z0 := by
  intro h_open
  obtain ⟨r0, hr0_above, -, h_none, -⟩ :=
    (prior_hasAttainedINF M atomMap h_UZ).first_occ P z0 z1 h_lt h_occ
  obtain ⟨r, hr1, hr2, hPr⟩ := h_open r0 hr0_above
  exact h_none r hr1 hr2 hPr

/-- **On Prior structures, disjunct (2) is unreachable — at the TREE's `kplus`.**

    Statement retained verbatim from before the re-base, and now *derived* from the source-exact
    version above (`kplusOpen_of_kplus`, `KPlusFaithful.lean:212`) rather than routed through
    `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`). The route through `HasDefinableINF`
    remains available and unedited; deriving instead from the stronger exclusion keeps the two
    statements from drifting apart. -/
theorem prior_makes_disjunct2_unreachable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kplus M atomMap P z0 := fun hk =>
  prior_makes_faithful_disjunct2_unreachable M atomMap h_UZ P z0 z1 h_lt h_occ
    (kplusOpen_of_kplus hk)

/-! ## Re-base compatibility shim — ORIGINAL GLUE, and scheduled for removal

**This section is not mathematics and is not attributable to any source.** It exists for exactly
one reason, stated plainly.

`negChainOnFaithful_iff` and `lemma53Faithful` now bind `HasFaithfulDedekindINF`. Their four live
call sites — `EANegationFixFaithful/BoundedFixFaithful.lean:215`, `:227`, `:281`, `:290` and
`EANegationFixFaithful/BoundedFixAnchoredFaithful.lean:181`, `:193`, `:257`, `:266` — pass a
`HasDedekindINF` drawn from their own binders (`BoundedFixFaithful.lean:188`, `:258`;
`BoundedFixAnchoredFaithful.lean:150`, `:230`). Those two modules are **not** this module's
territory: their carrier binders are re-based in their own phase, one module-boundary later in the
import chain. Until that happens the four binders and the eight call sites would be red.

The instance below closes that window. It is `HasDedekindINF.toHasFaithfulDedekindINF`
(`KPlusFaithful.lean:364`) and nothing else — a landed, sorry-free, axiom-clean theorem, wrapped
so Lean inserts it at an application site rather than requiring it to be written out.

**Two things follow, and both are binding:**

1. **It weakens nothing and hides nothing mathematically.** The coercion runs in the safe
   direction only (strong carrier ⇒ faithful carrier). The reverse edge does not exist and is not
   creatable: `HasDenseDedekindINF → HasFaithfulDedekindINF` fails for the reason recorded at
   `KPlusFaithful.lean:434-440`.
2. **It is scheduled for deletion, not for keeping.** The phase that re-bases
   `BoundedFixFaithful` and `BoundedFixAnchoredFaithful` swaps those four binders to
   `HasFaithfulDedekindINF` and must then delete this instance in the same change. Leaving it in
   place would let a later reader pass a needlessly strong carrier without seeing that they had. -/

/-- Compatibility coercion, `HasDedekindINF ⇒ HasFaithfulDedekindINF`. See the section note
    above: original glue, semantically just `HasDedekindINF.toHasFaithfulDedekindINF`, and to be
    deleted when the `EANegationFixFaithful/` binders are re-based. -/
instance coeHasDedekindINFToFaithful {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} :
    Coe (HasDedekindINF M atomMap) (HasFaithfulDedekindINF M atomMap) :=
  ⟨HasDedekindINF.toHasFaithfulDedekindINF⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
