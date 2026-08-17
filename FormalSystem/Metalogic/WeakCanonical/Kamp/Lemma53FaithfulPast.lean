/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful

/-!
# The `HasFaithfulDedekindSUP` / Since mirror of the eq (5.2) primitives (Rabinovich, PDF p.8)

`Lemma53Faithful.lean` restores Rabinovich's printed three-disjunct `Oₙ₊₁` over the faithful
`HasFaithfulDedekindINF` carrier (`KPlusFaithful.lean:320`). That module is entirely
**future/Until-directed**: it peels the *first* point type off the chain and pins it at the
first-occurrence infimum. This module supplies the **past/Since-directed** primitives, which the
tree did not have at all: `kminus` (`PriorINF.lean:98`) was declared with **no object-language
spelling and no correctness lemma anywhere**, so the `HasDedekindSUP` carrier
(`DedekindINF.lean:153`) could be stated but none of its content could be used.

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
The companion `.md` conversion is corrupt (it drops the displayed equations — and Lemma 5.3 *is*
displayed equations — and inverts `k ≠ m` to `k = m`) and is never ground truth.

## Source correspondence: PDF p.8, mirrored

p.8 prints only the future direction. Its Case 2 reads:

> *"let `r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}` (such `r₀` exists by Dedekind completeness). Note that
> `r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀,z₁)` and `r₀` is definable by the
> following `∨∃⃗∀` formula:"*
> `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))`  (5.2)

The mirror replaces `inf` by `sup{z ∈ (z₀,z₁) | Pₙ(z)}`, the boundary subcase `r₀ = z₀` by
`r₀ = z₁` (equivalently `K⁻(Pₙ)(z₁)`), and the `(∀y)^{<r₀}_{>z₀}` block by `(∀y)^{<z₁}_{>r₀}`.
This is the Until/Since symmetry the paper itself relies on: p.8 proves the `Until` instance and
Corollary 5.4 immediately takes both directions. **No hypothesis absent from p.8 is introduced.**
In particular `K⁻` needs nothing new: `Formula.snce` interprets Since natively
(`Table.lean:198`), so `kminusFormula` below is the literal transcription of `¬P ∧ ¬(⊤ S ¬P)`,
exactly as `kplusFormula` (`PriorINF.lean:93`) is `¬P ∧ ¬(⊤ U ¬P)`.

## What this module lands

* `kminusFormula` / `kminus_formula_correct` — `K⁻(P)` as an object-language formula, with the
  correctness lemma that was missing. Mirrors `kplusFormula` / `kplus_formula_correct`
  (`Lemma53.lean:162`).
* `kminusPred` / `kminusPred_eval` — the same at `TemporalPred` level; mirrors
  `kplusPred` / `kplusPred_eval` (`Lemma53Faithful.lean:81`, `:83`).
* `kminusOpenPred` / `kminusOpenPred_eval` — the **sources'** `K⁻` at `TemporalPred` level, on
  `Formula.kMinus` (`Syntax/Formula.lean:193`); mirrors `kplusOpenPred` / `kplusOpenPred_eval`.
* `HasDedekindSUP.last_occ_tp` and `HasFaithfulDedekindSUP.last_occ_tp` — the `TemporalPred`-level
  wrappers of the two past carriers, following the pattern of `HasAttainedSUP.last_occ_tp`
  (`EANegationFix/BoundedFix.lean:72`) and `HasAttainedINF.first_occ_tp`
  (`EANegationClosure.lean:66`).
* `orderedPointsExist_combine_right` — the right-end mirror of `orderedPointsExist_combine`
  (`EANegationFix/OnBuilder.lean:95`), which only ever combined at the left end.
* `orderedPointsExist_combine_kminusOpen` / `orderedPointsExist_combine_kminus` /
  `orderedPointsExist_widen_right` — the duals of `orderedPointsExist_combine_kplusOpen` /
  `orderedPointsExist_combine_kplus` / `orderedPointsExist_widen_left`
  (`Lemma53Faithful.lean`).
* `HasAttainedSUP.toHasDefinableSUP`, `hasDefinableSUP_excludes_kminus`,
  `prior_makes_faithful_kminus_disjunct_unreachable`, `prior_makes_kminus_disjunct_unreachable` —
  the SUP-side exclusion route at both `K⁻` spellings, mirroring
  `HasAttainedINF.toHasDefinableINF` (`PriorINF.lean:221`), `hasDefinableINF_excludes_kplus`
  (`Lemma53.lean:290`) and the two INF-side exclusion theorems in `Lemma53Faithful.lean`.

## ADAPTED-FROM: this module previously supplied only the `HasDedekindSUP` spelling

**What changed, in one clause**: the boundary disjunct `K⁻(Pₙ)(z₁)` gained a second, source-exact
spelling — `kminusOpen` (`KPlusFaithful.lean:126`), on `Formula.kMinus` — beside the tree's
`kminus` (`PriorINF.lean:98`), which carries an extra `¬P(z₁)` conjunct that neither Rabinovich
2014 (`K⁻` Definition (2), PDF p.3) nor Reynolds 1992 (abbreviation table §1, printed p.168:
`K⁻A` for `¬S(⊤,¬A)`) states.

**The re-base is additive at `last_occ_tp`, not in place, and this is deliberate.**
`HasDedekindSUP.last_occ_tp`'s conclusion carries `kminus P z₁`; the faithful carrier can only
supply `kminusOpen P z₁`, and `kminusOpen ↛ kminus`. So an in-place re-base of that wrapper would
strictly *weaken* a landed conclusion. Both wrappers are therefore kept: neither subsumes the
other (weaker hypothesis, weaker conclusion), and no landed statement moves. The `combine` and
exclusion primitives, where the two spellings *are* interderivable in the direction used, are
re-based in place with the `kminus` versions derived from the `kminusOpen` ones.

Nothing here deletes or weakens any landed declaration. Every declaration is an addition or a
same-statement re-derivation, and the attained-carrier stack in `EANegationFix/` reaches the past
carriers through the landed shims `HasAttainedSUP.toHasDedekindSUP` (`DedekindINF.lean:200`) and
`HasAttainedSUP.toHasFaithfulDedekindSUP` (`KPlusFaithful.lean:388`).

## What this carrier EXCLUDES — read this before citing anything below

Extended non-vacuity rule: *every module that lands or weakens a carrier must state what that
carrier excludes.* An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as
a vacuous conclusion does. Mirroring the three statements made in `Lemma53Faithful.lean`:

1. **`HasDedekindSUP` excludes** chains on which a last occurrence of `P` in `(z₀,z₁)` has a
   supremum that is none of the mirrored eq (5.2) shapes: the supremum `r₀` must satisfy
   `r₀ = z₁` (equivalently `K⁻(P)(z₁)`), or `r₀ ∈ (z₀,z₁)` with `¬P` on `(r₀,z₁)` and
   `P(r₀) ∨ K⁻(P)(r₀)`. Bare Dedekind completeness supplies the supremum's *existence* only;
   `HasDedekindSUP` additionally asserts it is **TL-definable** in one of those shapes. The
   strengthening chain mirrors the INF side exactly:
   `Rabinovich's Dedekind completeness < HasDedekindSUP < HasDefinableSUP < HasAttainedSUP`.
   So this carrier is still strictly stronger than the paper's hypothesis, only much less so.
   `HasFaithfulDedekindSUP` (`KPlusFaithful.lean:339`) sits one link below `HasDedekindSUP` on
   that chain, and its own exclusion statement is at `KPlusFaithful.lean:333-338`.
2. **The `K⁻` boundary disjunct is provably dead on every Prior structure, at BOTH `K⁻`
   spellings.** `prior_makes_faithful_kminus_disjunct_unreachable` below proves it for the
   sources' `K⁻`, and `prior_makes_kminus_disjunct_unreachable` — kept, and now derived from it —
   for the tree's `kminus`: `SemanticPriorSZ` gives `HasAttainedSUP` (`PriorINF.lean:275`), whose
   attained last occurrence `r₀ < z₁` with `¬P` on `(r₀,z₁)` collides with `K⁻` asserting that
   `P` occurs in every interval below `z₁`. This is the exact mirror of what the two INF-side
   exclusion theorems establish for `K⁺(P)(z₀)`.

   **Weakening the boundary disjunct's spelling did not resurrect it** — the same live risk the
   INF side records, resolved the same way: attainment kills `kminusOpen P z₁` outright, and the
   tree's extra `¬P(z₁)` conjunct is never read in the argument.
3. **The past mirror is therefore NOT observable by any current consumer.** The live goal chain
   in this tree runs on Prior structures, where SUP attainment holds outright from the SZ axiom,
   so no live consumer can tell `HasAttainedSUP` and `HasDedekindSUP` apart — the same reason,
   and the same honest limitation, as the INF direction. Observability arrives only with a
   genuinely non-attained Dedekind-complete frame class, which this tree does not construct
   (`DedekindINF.lean:49-50` states that absence explicitly).
   `hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) must **not** be cited against
   this: its proof is `Or.inl h_kplus` and its own docstring admits it exhibits no structure.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## `K⁻(P)` as an object-language formula

`kminus` (`PriorINF.lean:98`) was declared semantically and never given a spelling. `Formula.snce`
interprets Since natively (`Table.lean:198`): `snce φ ψ` at `t` is
`∃s < t, φ(s) ∧ ∀r ∈ (s,t), ψ(r)`. So `⊤ S ¬P` at `t` reads *"there is a gap below `t` on which
`P` never holds"*, and its negation is *"`P` occurs in every interval `(s,t)`"* — which, conjoined
with `¬P(t)`, is exactly `K⁻(P)(t)`. -/

/-- `K⁻(P)` is TL-definable: the formula `P.neg ∧ ¬(⊤ S P.neg)`.

    Exact mirror of `kplusFormula` (`PriorINF.lean:93`), with `Formula.untl` replaced by
    `Formula.snce`.

    Source correspondence: PDF p.8, mirrored — `K⁺(P₁)(z₀)` is asserted there to be *"an atomic
    (and hence a `∨∃⃗∀`) formula in the canonical expansion"*; this tree needs no canonical
    expansion in either direction, since both operators are outright TL-definable. -/
noncomputable def kminusFormula (P : Formula) : Formula :=
  Formula.and P.neg (Formula.imp (Formula.snce P.neg Formula.top) Formula.bot)

/-- `kminusFormula P` defines `K⁻(P)` in the object language: its truth at `t` is exactly the
    semantic `kminus M atomMap P t`.

    This is the missing correctness lemma — `kminus` had none, so the `HasDedekindSUP` carrier
    could be stated but its left disjunct could not be used as syntax. Structural dual of
    `kplus_formula_correct` (`Lemma53.lean:162`); no step of that proof needed adaptation beyond
    reversing the order comparisons.

    Source correspondence: Rabinovich 2014, Lemma 5.3 proof and eq (5.2), PDF p.8, mirrored. -/
theorem kminus_formula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    TemporalTruth M atomMap t (kminusFormula P) ↔ kminus M atomMap P t := by
  simp only [kminusFormula, kminus, Formula.and, Formula.neg, Formula.top, TemporalTruth]
  constructor
  · intro h
    refine ⟨fun hP => ?_, fun s hs => ?_⟩
    · exact h (fun hnP => absurd hP hnP)
    · by_contra h_no
      push Not at h_no
      refine h (fun _ h_snce => h_snce ⟨s, hs, fun h0 => h0, fun r hr1 hr2 hPr => ?_⟩)
      exact h_no r hr1 hr2 hPr
  · rintro ⟨hnP, h_dense⟩ h
    refine h (fun hP => absurd hP hnP) ?_
    rintro ⟨s, hs, -, h_none⟩
    obtain ⟨r, hr1, hr2, hPr⟩ := h_dense s hs
    exact h_none r hr1 hr2 hPr

/-- `K⁻(P)` as a point type. Mirror of `kplusPred` (`Lemma53Faithful.lean:81`). -/
noncomputable def kminusPred (P : TemporalPred) : TemporalPred := ⟨kminusFormula P.formula⟩

/-- `kminusPred` evaluates to the semantic `kminus`. Mirror of `kplusPred_eval`
    (`Lemma53Faithful.lean:83`). -/
theorem kminusPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    (kminusPred P).EvalAt M atomMap t ↔ kminus M atomMap P.formula t :=
  kminus_formula_correct M atomMap P.formula t

/-- **The sources' `K⁻(P)` as a point type.** Mirror of `kplusOpenPred`
    (`Lemma53Faithful.lean`), and, like it, needing no new formula: `Formula.kMinus`
    (`Syntax/Formula.lean:193`) is `(snce P.neg ⊤).neg`, Reynolds' `¬S(⊤,¬P)` letter for letter
    (abbreviation table §1, printed p.168).

    ADAPTED-FROM `kminusPred` above, which is pinned at `kminusFormula` and so carries this
    tree's extra `¬P(t)` conjunct. What changed: the conjunct is gone. Rabinovich 2014, PDF p.3,
    Definition (2): *"`K−(F)` holds at a moment `t` iff `t = sup({t′ | t′ < t and F holds at
    t′})`"* — nothing there constrains the point of evaluation. `Syntax/Formula.lean:189` carries
    the standing name-collision warning between `Formula.kMinus` and `kminusFormula`. -/
def kminusOpenPred (P : TemporalPred) : TemporalPred := ⟨Formula.kMinus P.formula⟩

/-- `kminusOpenPred` evaluates to the sources' semantic `K⁻`, via the bridge lemma
    `kMinus_formula_correct` (`KPlusFaithful.lean:172`). Mirror of `kplusOpenPred_eval`. -/
theorem kminusOpenPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    (kminusOpenPred P).EvalAt M atomMap t ↔ kminusOpen M atomMap P.formula t :=
  kMinus_formula_correct M atomMap P.formula t

/-! ## The past carriers at `TemporalPred` level -/

/-- Last occurrence of a temporal predicate `P` in `(z₀,z₁)` on structures satisfying the
    **faithful** `HasDedekindSUP` carrier: either the supremum sits at the right endpoint (as
    `K⁻(P)(z₁)`) or it is a mirrored eq (5.2) point strictly inside `(z₀,z₁)`.

    Wraps `HasDedekindSUP.last_occ` (`DedekindINF.lean:157`) to accept a `TemporalPred` directly,
    following the pattern of `HasAttainedSUP.last_occ_tp` (`EANegationFix/BoundedFix.lean:72`) and
    `HasAttainedINF.first_occ_tp` (`EANegationClosure.lean:66`). Unlike those two, the disjunction
    is preserved rather than collapsed: that is precisely the content the faithful carrier adds.

    Source correspondence: Rabinovich 2014, eq (5.2), PDF p.8, mirrored. -/
theorem HasDedekindSUP.last_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_SUP : HasDedekindSUP M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    kminus M atomMap P.formula z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬P.EvalAt M atomMap y) ∧
        (P.EvalAt M atomMap r0 ∨ kminus M atomMap P.formula r0)) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  rcases h_SUP.last_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩ with
    hk | ⟨r0, hr0_above, hr0_below, h_none, h_disj⟩
  · exact Or.inl hk
  · exact Or.inr ⟨r0, hr0_above, hr0_below,
      fun y hy0 hy1 hPy => h_none y hy0 hy1 hPy, h_disj⟩

/-- **The same wrapper at the faithful past carrier** (`HasFaithfulDedekindSUP`,
    `KPlusFaithful.lean:339`): the supremum sits at the right endpoint — which, at the sources'
    `K⁻`, is exactly `kminusOpen P z₁` — or is a mirrored eq (5.2) point strictly inside
    `(z₀,z₁)`.

    ADAPTED-FROM `HasDedekindSUP.last_occ_tp` above. What changed: the carrier binder, and with it
    the boundary disjunct's spelling, `kminus P z₁` → `kminusOpen P z₁`. The proof is the same
    unconditional `rcases`-and-repackage, so the wrapper's **two-arm shape is unchanged**; only
    the left arm's type moves.

    **Why this is landed beside `HasDedekindSUP.last_occ_tp` rather than replacing it.** The two
    are incomparable: this one has the weaker hypothesis *and* the weaker conclusion. Replacing
    the older wrapper would strictly weaken a landed conclusion, which the re-base is not
    permitted to do; keeping both loses nothing, since neither has a live consumer to disturb.

    Source correspondence: Rabinovich 2014, eq (5.2), PDF p.8, mirrored, with `K⁻` per his
    Definition (2), PDF p.3. -/
theorem HasFaithfulDedekindSUP.last_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    kminusOpen M atomMap P.formula z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬P.EvalAt M atomMap y) ∧
        (P.EvalAt M atomMap r0 ∨ kminus M atomMap P.formula r0)) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  rcases h_SUP.last_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩ with
    hk | ⟨r0, hr0_above, hr0_below, h_none, h_disj⟩
  · exact Or.inl hk
  · exact Or.inr ⟨r0, hr0_above, hr0_below,
      fun y hy0 hy1 hPy => h_none y hy0 hy1 hPy, h_disj⟩

/-! ## Chain primitives at the right end

`orderedPointsExist_combine` (`EANegationFix/OnBuilder.lean:95`) only ever prepends a witness at
the *left* end, because the whole landed stack peels point types off the front of the list. The
past direction pins the *last* point type at the supremum, so the right-end mirror is needed and
does not exist. -/

/-- Combine an initial chain with a last witness: if `Ps n` holds at `r ∈ (z₀,z₁)` and the chain
    for the first `n` predicates exists on `(z₀,r)`, the full chain exists on `(z₀,z₁)`.

    Right-end mirror of `orderedPointsExist_combine` (`EANegationFix/OnBuilder.lean:95`). -/
theorem orderedPointsExist_combine_right {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 r : M.carrier),
    z0 < r → r < z1 →
    (Ps ⟨n, Nat.lt_succ_self n⟩).EvalAt M atomMap r →
    orderedPointsExist M atomMap n (fun i => Ps i.castSucc) z0 r →
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
  intro n
  match n with
  | 0 =>
    intro Ps z0 z1 r hr_above hr_below hr_P _
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
    refine ⟨fun _ => r, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab; exact absurd hab (by omega)
    · intro _; exact ⟨hr_above, hr_below⟩
    · intro ⟨i, hi⟩; simp only [zero_add, Order.lt_one_iff] at hi; subst hi; exact hr_P
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro j; exact Fin.elim0 j
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
  | n' + 1 =>
    intro Ps z0 z1 r hr_above hr_below hr_P h_init
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
      at h_init ⊢
    obtain ⟨w_init, hmono_init, hrange_init, hpoint_init, _, _, _⟩ := h_init
    let w' : Fin (n' + 2) → M.carrier := fun ⟨i, _⟩ =>
      if h : i < n' + 1 then w_init ⟨i, h⟩ else r
    refine ⟨w', ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨a, ha⟩ ⟨b, hb⟩ hab
      simp only [Fin.lt_def] at hab; simp only [w']
      by_cases hb1 : b < n' + 1
      · simp only [dif_pos hb1, dif_pos (show a < n' + 1 from by omega)]
        exact hmono_init ⟨a, by omega⟩ ⟨b, hb1⟩ (by simp only [Fin.lt_def]; omega)
      · simp only [dif_neg hb1, dif_pos (show a < n' + 1 from by omega)]
        exact (hrange_init ⟨a, by omega⟩).2
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi1 : i < n' + 1
      · simp only [dif_pos hi1]
        exact ⟨(hrange_init ⟨i, hi1⟩).1, lt_trans (hrange_init ⟨i, hi1⟩).2 hr_below⟩
      · simp only [dif_neg hi1]; exact ⟨hr_above, hr_below⟩
    · intro ⟨i, hi⟩; simp only [w']
      by_cases hi1 : i < n' + 1
      · simp only [dif_pos hi1]
        exact hpoint_init ⟨i, hi1⟩
      · simp only [dif_neg hi1]
        have hieq : i = n' + 1 := by omega
        subst hieq; exact hr_P
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- **The mirrored boundary subcase** (PDF p.8, mirrored): given `K⁻(Pₙ)(z₁)`, a chain for the
    initial `n` predicates on `(z₀,z₁)` extends to a chain for all `n+1` on the *same* interval.
    This is precisely why the paper's `Subcase r₀ = z₀` — here `r₀ = z₁` — recurses on `(z₀,z₁)`
    rather than on a shrunken interval.

    Dual of `orderedPointsExist_combine_kplusOpen` (`Lemma53Faithful.lean`): the chain is extended
    **upward** by one `P`-point drawn from the density that `K⁻(P)(z₁)` asserts below `z₁`.

    ADAPTED-FROM `orderedPointsExist_combine_kminus` below, which took the tree's `kminus`. What
    changed: the hypothesis, and the first line of the proof. The landed proof opened `hk` as
    `obtain ⟨-, hdense⟩ := hk`, **discarding the `¬P(z₁)` conjunct unused**, so dropping it costs
    nothing; everything below the first line is the landed proof unaltered. -/
theorem orderedPointsExist_combine_kminusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) (hlt : z0 < z1)
    (hk : kminusOpen M atomMap (Ps ⟨n, Nat.lt_succ_self n⟩).formula z1)
    (h_init : orderedPointsExist M atomMap n (fun i => Ps i.castSucc) z0 z1) :
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
  have hdense := hk
  match n with
  | 0 =>
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense z0 hlt
    exact orderedPointsExist_combine_right M atomMap 0 Ps z0 z1 r hr1 hr2 hPr
      (orderedPointsExist_zero M atomMap _ z0 r)
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at h_init
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := h_init
    obtain ⟨r, hr1, hr2, hPr⟩ := hdense (w ⟨n', Nat.lt_succ_self n'⟩)
      (hrange ⟨n', Nat.lt_succ_self n'⟩).2
    refine orderedPointsExist_combine_right M atomMap (n' + 1) Ps z0 z1 r
      (lt_trans (hrange ⟨n', Nat.lt_succ_self n'⟩).1 hr1) hr2 hPr ?_
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
    refine ⟨w, hmono, ?_, hpoint, ?_, ?_, ?_⟩
    · intro j
      refine ⟨(hrange j).1, lt_of_le_of_lt ?_ hr1⟩
      rcases Nat.eq_or_lt_of_le (Nat.le_of_lt_succ j.isLt) with hj | hj
      · exact le_of_eq (congrArg w (Fin.ext hj))
      · exact le_of_lt (hmono j ⟨n', Nat.lt_succ_self n'⟩ (by simp only [Fin.lt_def]; omega))
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- **The mirrored boundary subcase at the tree's `kminus`.** Retained verbatim in statement, and
    now *derived* from the source-exact version above (`kminusOpen_of_kminus`,
    `KPlusFaithful.lean:218`) rather than re-proved, so nothing is duplicated in substance.

    Kept because the mirrored eq (5.2)'s point condition still says `P(r₀) ∨ kminus P r₀` — the
    faithful past carrier's right disjunct is literally `HasDedekindSUP`'s — so a consumer still
    reaches this spelling at `r₀`. -/
theorem orderedPointsExist_combine_kminus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) (hlt : z0 < z1)
    (hk : kminus M atomMap (Ps ⟨n, Nat.lt_succ_self n⟩).formula z1)
    (h_init : orderedPointsExist M atomMap n (fun i => Ps i.castSucc) z0 z1) :
    orderedPointsExist M atomMap (n + 1) Ps z0 z1 :=
  orderedPointsExist_combine_kminusOpen M atomMap n Ps z0 z1 hlt (kminusOpen_of_kminus hk) h_init

/-- Widening the right endpoint is free: a chain on `(z₀,r₀)` is a chain on `(z₀,z₁)` whenever
    `r₀ < z₁`. Dual of `orderedPointsExist_widen_left` (`Lemma53Faithful.lean:169`); needed by the
    mirrored eq (5.2)'s `K⁻(P)(r₀)` alternative, where the witness produced at `r₀` must be
    reported back on the outer interval. -/
theorem orderedPointsExist_widen_right {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin n → TemporalPred) (z0 r0 z1 : M.carrier) (h : r0 < z1)
    (hc : orderedPointsExist M atomMap n Ps z0 r0) :
    orderedPointsExist M atomMap n Ps z0 z1 := by
  match n with
  | 0 => exact orderedPointsExist_zero M atomMap _ z0 z1
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at hc ⊢
    obtain ⟨w, hmono, hrange, hpoint, -, -, -⟩ := hc
    exact ⟨w, hmono, fun j => ⟨(hrange j).1, lt_trans (hrange j).2 h⟩, hpoint,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun _ y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## Extended non-vacuity: the SUP-side exclusion, machine-checked

The INF side records its exclusion as `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`) and
`prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`). The SUP side had **neither**:
`HasAttainedSUP.toHasDefinableSUP` and the `kminus` exclusion did not exist. Both are supplied
here so the exclusion statement in this module's docstring is machine-checked rather than
asserted. -/

/-- `HasAttainedSUP` implies `HasDefinableSUP`. Mirror of `HasAttainedINF.toHasDefinableINF`
    (`PriorINF.lean:221`); the attained last occurrence is the `P(r₀)` alternative of the
    disjunctive point condition, and `z₀ < r₀` weakens to `z₀ ≤ r₀`. -/
theorem HasAttainedSUP.toHasDefinableSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedSUP M atomMap) : HasDefinableSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    obtain ⟨r0, hr0_above, hr0_below, h_no_after, h_P_r0⟩ := h.last_occ P z0 z1 h_lt h_occ
    exact ⟨r0, le_of_lt hr0_above, hr0_below, h_no_after, Or.inl h_P_r0⟩

/-- **`HasDefinableSUP` is not the mirrored eq (5.2) carrier: it silently deletes the `K⁻`
    boundary disjunct.**

    Mirror of `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`). Assuming `HasDefinableSUP`
    makes `K⁻(P)(z₁)` *unreachable* whenever `P` occurs in `(z₀,z₁)` — which is exactly the
    mirrored `Subcase r₀ = z₁`. The proof is immediate: `last_occ` hands back an `r₀ < z₁` with
    `¬P` throughout `(r₀,z₁)`, while `K⁻(P)(z₁)` says `P` occurs in *every* interval below `z₁`;
    instantiate the latter at `r₀` and the two collide.

    Source correspondence: Rabinovich 2014, Lemma 5.3 proof, Case 2 and its boundary subcase,
    PDF p.8, mirrored. -/
theorem hasDefinableSUP_excludes_kminus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_sup : HasDefinableSUP M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kminus M atomMap P z1 := by
  rintro ⟨-, h_dense⟩
  obtain ⟨r0, -, h_r0_z1, h_none, -⟩ := h_sup.last_occ P z0 z1 h_lt h_occ
  obtain ⟨r, hr1, hr2, hPr⟩ := h_dense r0 h_r0_z1
  exact h_none r hr1 hr2 hPr

/-- **On Prior structures, the `K⁻` boundary disjunct is unreachable — at the SOURCES' `K⁻`.**

    `SemanticPriorSZ` gives `HasAttainedSUP` (`prior_hasAttainedSUP`, `PriorINF.lean:275`), whose
    `last_occ` hands back an attained `r₀ < z₁` with `¬P` throughout `(r₀,z₁)`. The sources' `K⁻`
    says `P` occurs in *every* interval `(s,z₁)`; instantiate it at `s := r₀` and the two collide.
    No use is made of the tree's extra `¬P(z₁)` conjunct, which is why the weaker boundary
    spelling is dead for the same reason the stronger one is.

    Consequence, stated honestly: the mirrored boundary case can only ever fire on a structure
    that is **not** a Prior structure. No such structure is constructed anywhere in this tree, so
    the faithful past carrier is **not observable by any current consumer** — it becomes
    observable only once a genuinely non-attained Dedekind-complete frame class is built. This is
    the exact mirror of `prior_makes_faithful_disjunct2_unreachable` (`Lemma53Faithful.lean`),
    and it fails for exactly the same reason.

    Source correspondence: Rabinovich 2014, `K⁻` Definition (2), PDF p.3, and Lemma 5.3 Case 2's
    boundary subcase, PDF p.8, mirrored. -/
theorem prior_makes_faithful_kminus_disjunct_unreachable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : SemanticPriorSZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kminusOpen M atomMap P z1 := by
  intro h_open
  obtain ⟨r0, -, hr0_below, h_none, -⟩ :=
    (prior_hasAttainedSUP M atomMap h_SZ).last_occ P z0 z1 h_lt h_occ
  obtain ⟨r, hr1, hr2, hPr⟩ := h_open r0 hr0_below
  exact h_none r hr1 hr2 hPr

/-- **On Prior structures, the `K⁻` boundary disjunct is unreachable — at the TREE's `kminus`.**

    Statement retained verbatim from before the re-base, and now *derived* from the source-exact
    version above (`kminusOpen_of_kminus`, `KPlusFaithful.lean:218`) rather than routed through
    `hasDefinableSUP_excludes_kminus`. That route remains available and unedited; deriving instead
    from the stronger exclusion keeps the two statements from drifting apart. -/
theorem prior_makes_kminus_disjunct_unreachable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : SemanticPriorSZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) :
    ¬kminus M atomMap P z1 := fun hk =>
  prior_makes_faithful_kminus_disjunct_unreachable M atomMap h_SZ P z0 z1 h_lt h_occ
    (kminusOpen_of_kminus hk)

end FormalSystem.Metalogic.WeakCanonical.Kamp
