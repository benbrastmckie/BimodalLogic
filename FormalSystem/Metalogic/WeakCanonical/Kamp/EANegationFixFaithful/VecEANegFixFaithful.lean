/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.NegFixListFaithful

/-!
# The Prop 4.2 / 4.3 lift chain over the faithful carrier (Rabinovich, PDF p.6 and pp.10-11)

This module is the three-step lift that carries Lemma 5.1's recursion up to the disjunction level,
over `HasDedekindINF` **alone**:

```
BracketFormula.negFixFaithful  →  VecEA2.negFixFaithful  →  VVecEA2.negFixFaithful
```

It mirrors, declaration for declaration, the attained chain `BracketFormula.negFix`
(`EANegationFix/NegFix.lean:479`) → `VecEA2.negFix` (`EANegationFix/VecEANegFix.lean:67`) →
`VVecEA2.negFix` (`:154`), whose `_iff` lemmas assume `HasAttainedINF` **and** `HasAttainedSUP`.

## Source correspondence

PDF **p.6** prints the two steps this module formalizes, inside the proof of Proposition 4.3
(structural induction), under **Negation:**

> *"If `φ` is an `∃⃗∀`-formula, then by Lemma 3.2(2) it is equivalent to a conjunction of `∃⃗∀`
> formulas with at most two free variables. Hence, `¬φ` is equivalent to a disjunction of `¬ψᵢ`
> where `ψᵢ` are `∃⃗∀`-formulas with at most two free variables. By Proposition 4.2, `¬ψᵢ` is
> equivalent to a disjunction of `∃⃗∀` formulas `γᵢʲ`."*

and, immediately below it, the De Morgan fold:

> *"If `φ` is a disjunction of `∃⃗∀` formulas `φᵢ`, then `¬φ` is equivalent to the conjunction of
> `¬φᵢ`. By the above, `¬φᵢ` is equivalent to a `∨∃⃗∀` formula. Since `∨∃⃗∀` formulas are closed
> under conjunction (Lemma 3.4), we obtain that `¬φ` is equivalent to a disjunction of `∃⃗∀`
> formulas."*

The two-free-variable case those steps invoke is Proposition 4.2 itself — stated on the same page
as holding **over Dedekind complete chains**, which is precisely the carrier this module's `_iff`
lemmas are anchored to (via `HasDedekindINF`) rather than the strictly stronger attainment the
landed chain assumes. Lemma 5.1's recursion, PDF **pp.10-11**, supplies the bracket leg and is
consumed opaquely here through `negFixListFaithful_iff` (`NegFixListFaithful.lean:333`).

## What the migrated type buys at the lift

`VecEA2.negFix` must wrap each bracket-leg disjunct in `⊤` endpoints, because a `VBracketFormula`
disjunct carries no endpoint predicates and the surrounding `VecEA2` slot has to be filled with
something. At `VVecEA2` the bracket leg is *already* a list of `VecEA2` disjuncts, each carrying its
own endpoint predicates, so the lift splices them **verbatim**:

```
vea.negFixFaithful.disjuncts = ¬ψ₀-leg :: ¬ψ₁-leg :: vea.bracket.negFixFaithful.disjuncts
```

No `List.map`, no endpoint erasure. `VecEA2.negFixFaithful_of_bracket` below machine-checks that
consequence, and `VecEA2.negFixFaithful_carries_limit_gate` machine-checks the consequence that
matters for fidelity: the `K⁺(¬β₁)(z₀)` limit disjunct that the faithful recursion adds at every
cons step (PDF p.9, Case 1) is still reachable at the top of the lift. A lift that dropped or
collapsed disjuncts would satisfy the `_iff` lemmas' *statements* just as well while silently
deleting the paper's limit case; that is the failure mode these two declarations exist to exclude.

## Carrier discipline

Every `_iff` lemma here assumes `HasDedekindINF` and nothing else — no `HasDedekindSUP`, no
`HasAttained*`. The only shim used is `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`),
in the attained → faithful direction, in `VVecEA2.negFixFaithful_iff_of_attained`. There is no use
of a faithful → attained shim anywhere in this module; such a use would be a strengthening, not a
lift.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Propositions 4.2 and 4.3, PDF p.6; Lemma 5.1,
  PDF pp.10-11.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Step 1: the bracket-level entry point -/

/-- **Lemma 5.1 fixed-formula negation, faithful** (Rabinovich 2014, PDF pp.10-11): the general
    negation of a bracket formula over the faithful carrier, via the faithful list recursion.
    Mirror of `BracketFormula.negFix` (`EANegationFix/NegFix.lean:479`), which is the same two
    lines over `negFixList`.

    The result type is `VVecEA2`, not `VBracketFormula`: the faithful recursion's disjuncts carry
    endpoint predicates (the `K⁺` limit gate is a pure left-endpoint condition), which is exactly
    what a `VBracketFormula` has no room for. -/
noncomputable def BracketFormula.negFixFaithful {n : Nat} (bf : BracketFormula n) : VVecEA2 :=
  negFixListFaithful (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) bf.foldPairs

/-- **Lemma 5.1, general fixed formula, faithful** (Rabinovich 2014, PDF pp.10-11): over
    `HasDedekindINF` **alone**, `bf.negFixFaithful` holds on `(z₀,z₁)` iff the bracket `bf` fails
    there. Mirror of `BracketFormula.negFix_iff` (`EANegationFix/NegFix.lean:694`), which needs
    `HasAttainedINF` **and** `HasAttainedSUP`.

    Both are carrier-anchored, and the anchor is what makes the direction go through; neither is a
    model-independent negation result. -/
theorem BracketFormula.negFixFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    bf.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ bf.holds M atomMap z0 z1 := by
  unfold BracketFormula.negFixFaithful
  exact (negFixListFaithful_iff M atomMap h_INF bf.foldPairs.length bf.foldPairs
    (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 (Nat.le_refl _) h_lt).trans
    (not_congr (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z1).symm)

/-! ## Step 2: the per-disjunct negation (Prop 4.2, two-free-variable case) -/

/-- **Prop 4.2 per-disjunct negation, faithful** (PDF p.6): the three-way split
    `¬ψ₀(z₀) ∨ ¬ψ₁(z₁) ∨ ¬bracket(z₀,z₁)` of a single `VecEA2` disjunct, as a `VVecEA2`.

    Mirror of `VecEA2.negFix` (`EANegationFix/VecEANegFix.lean:67`) with one structural difference:
    the bracket leg is spliced **verbatim** (`… :: vea.bracket.negFixFaithful.disjuncts`) rather
    than mapped under `⊤` endpoints. The attained version has to map, because its bracket leg is a
    list of `BracketFormula`s with no endpoint slots; the faithful bracket leg is already a list of
    `VecEA2`s, so mapping would *erase* endpoint predicates that the faithful recursion needs. -/
noncomputable def VecEA2.negFixFaithful {n : Nat} (vea : VecEA2 n) : VVecEA2 :=
  { disjuncts :=
      ⟨0, { endpointLeft := vea.endpointLeft.neg
            endpointRight := TemporalPred.top
            bracket := BracketFormula.trivial TemporalPred.top }⟩ ::
      ⟨0, { endpointLeft := TemporalPred.top
            endpointRight := vea.endpointRight.neg
            bracket := BracketFormula.trivial TemporalPred.top }⟩ ::
      vea.bracket.negFixFaithful.disjuncts }

/-- **Prop 4.2 per-disjunct iff, faithful** (PDF p.6): over `HasDedekindINF` alone,
    `vea.negFixFaithful` holds on `(z₀,z₁)` iff the disjunct `vea` fails there. The bracket leg
    reduces to `BracketFormula.negFixFaithful_iff`. -/
theorem VecEA2.negFixFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    vea.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ vea.holds M atomMap z0 z1 := by
  have hbr := BracketFormula.negFixFaithful_iff M atomMap h_INF vea.bracket z0 z1 h_lt
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [negFixFaithful, List.mem_cons] at hmem
    rcases hmem with rfl | rfl | hmem
    · -- Left-endpoint leg: ¬ψ₀(z₀)
      simp only [VecEA2.holds] at hh
      obtain ⟨hel, -, -⟩ := hh
      rw [TemporalPred.eval_at_neg'] at hel
      rintro ⟨hl, -, -⟩
      exact hel hl
    · -- Right-endpoint leg: ¬ψ₁(z₁)
      simp only [VecEA2.holds] at hh
      obtain ⟨-, her, -⟩ := hh
      rw [TemporalPred.eval_at_neg'] at her
      rintro ⟨-, hr, -⟩
      exact her hr
    · -- Bracket leg: `d` is a disjunct of the faithful bracket negation, endpoints intact
      have hneg : vea.bracket.negFixFaithful.holds M atomMap z0 z1 := ⟨d, hmem, hh⟩
      rintro ⟨-, -, hb⟩
      exact (hbr.mp hneg) hb
  · intro hne
    by_cases hl : vea.endpointLeft.EvalAt M atomMap z0
    · by_cases hr : vea.endpointRight.EvalAt M atomMap z1
      · -- Both endpoints hold, so the bracket must fail: bracket leg
        have hb : ¬ vea.bracket.holds M atomMap z0 z1 :=
          fun hb => hne ⟨hl, hr, hb⟩
        obtain ⟨d, hmem, hh⟩ := hbr.mpr hb
        refine ⟨d, ?_, hh⟩
        simp only [negFixFaithful, List.mem_cons]
        exact Or.inr (Or.inr hmem)
      · -- Right endpoint fails: right-endpoint leg
        refine ⟨⟨0, { endpointLeft := TemporalPred.top
                      endpointRight := vea.endpointRight.neg
                      bracket := BracketFormula.trivial TemporalPred.top }⟩,
                ?_, TemporalPred.eval_at_top M atomMap z0, ?_, ?_⟩
        · simp [negFixFaithful]
        · exact (TemporalPred.eval_at_neg' M atomMap _ z1).mpr hr
        · rw [BracketFormula.trivial_holds]
          intro y _ _
          exact TemporalPred.eval_at_top M atomMap y
    · -- Left endpoint fails: left-endpoint leg
      refine ⟨⟨0, { endpointLeft := vea.endpointLeft.neg
                    endpointRight := TemporalPred.top
                    bracket := BracketFormula.trivial TemporalPred.top }⟩,
              ?_, ?_, TemporalPred.eval_at_top M atomMap z1, ?_⟩
      · simp [negFixFaithful]
      · exact (TemporalPred.eval_at_neg' M atomMap _ z0).mpr hl
      · rw [BracketFormula.trivial_holds]
        intro y _ _
        exact TemporalPred.eval_at_top M atomMap y

/-! ## Step 3: the De Morgan fold (Prop 4.3) -/

/-- **Prop 4.3 De Morgan fold, faithful** (PDF p.6): the negation of a `VVecEA2` disjunction
    `∨ᵢ ϕᵢ` is the conjunction `∧ᵢ ¬ϕᵢ` of the per-disjunct negations, closed back into `VVecEA2`
    by the Lemma 3.4 conjunction `VVecEA2.conjFull`, with `VVecEA2.trivialTrue` as the neutral
    element. Mirror of `VVecEA2.negFix` (`EANegationFix/VecEANegFix.lean:154`). -/
noncomputable def VVecEA2.negFixFaithful (v : VVecEA2) : VVecEA2 :=
  v.disjuncts.foldr (fun d acc => d.2.negFixFaithful.conjFull acc) VVecEA2.trivialTrue

/-- List form of the faithful De Morgan fold: the fold holds iff every disjunct in the list fails.
    Induction on the list; the cons step is `VVecEA2.conjFull_iff` + `VecEA2.negFixFaithful_iff`.
    Mirror of `vecEANegFixFold_iff` (`EANegationFix/VecEANegFix.lean:160`). -/
theorem vecEANegFixFaithfulFold_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (Σ n, VecEA2 n)) :
    (l.foldr (fun d acc => d.2.negFixFaithful.conjFull acc)
      VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
    ∀ d ∈ l, ¬ d.2.holds M atomMap z0 z1 := by
  induction l with
  | nil =>
    simp only [List.foldr_nil]
    constructor
    · intro _ d hd
      exact absurd hd (by simp)
    · intro _
      exact VVecEA2.trivialTrue_holds M atomMap z0 z1
  | cons d ds ih =>
    rw [List.foldr_cons, VVecEA2.conjFull_iff,
        VecEA2.negFixFaithful_iff M atomMap h_INF d.2 z0 z1 h_lt, ih,
        List.forall_mem_cons]

/-- **Prop 4.2 / 4.3, faithful** (Rabinovich 2014, PDF p.6): over `HasDedekindINF` **alone**, the
    De Morgan fold `v.negFixFaithful` holds on `(z₀,z₁)` iff the `VVecEA2` disjunction `v` fails
    there. Mirror of `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:183`), which needs
    `HasAttainedINF` **and** `HasAttainedSUP`.

    Rabinovich states Proposition 4.2 over **Dedekind complete chains** (p.6); this is the
    statement one strengthening step away from that, where the landed attained version is three. -/
theorem VVecEA2.negFixFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    v.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1 := by
  refine (vecEANegFixFaithfulFold_iff M atomMap h_INF z0 z1 h_lt v.disjuncts).trans ?_
  simp only [VVecEA2.holds, not_exists, not_and]

/-! ## The lift preserves what the faithful recursion added

The `_iff` lemmas above are silent about *how* the lift is built: a lift that dropped, merged or
`⊤`-erased bracket-leg disjuncts would prove exactly the same biconditionals, because the right
hand sides mention only `¬ vea.holds`. The two declarations below are the machine-checked content
that a plain reading of the `_iff` statements does not give. -/

/-- **Nothing is dropped and nothing is erased at the lift.** Every disjunct of the faithful
    bracket negation occurs, *verbatim* — same witness count, same endpoint predicates, same
    bracket — among the disjuncts of the per-disjunct negation. Carrier-free.

    The attained `VecEA2.negFix` (`EANegationFix/VecEANegFix.lean:75`) cannot state this: it maps
    its bracket leg through `fun bf => ⟨bf.1, {endpointLeft := ⊤, endpointRight := ⊤, ..}⟩`, so no
    disjunct survives verbatim. -/
theorem VecEA2.mem_negFixFaithful_disjuncts {n : Nat} (vea : VecEA2 n)
    (d : Σ m, VecEA2 m) (hd : d ∈ vea.bracket.negFixFaithful.disjuncts) :
    d ∈ vea.negFixFaithful.disjuncts := by
  simp only [negFixFaithful, List.mem_cons]
  exact Or.inr (Or.inr hd)

/-- Semantic form of the previous lemma: the bracket leg reaches the top of the lift. Carrier-free
    and direction-free — it consumes no `_iff`, so it holds of the *construction*, not of the
    theorem about it. -/
theorem VecEA2.negFixFaithful_of_bracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h : vea.bracket.negFixFaithful.holds M atomMap z0 z1) :
    vea.negFixFaithful.holds M atomMap z0 z1 := by
  obtain ⟨d, hmem, hh⟩ := h
  exact ⟨d, VecEA2.mem_negFixFaithful_disjuncts vea d hmem, hh⟩

/-- **The limit gate survives the lift.** The disjunct the faithful recursion adds and the attained
    one cannot have — Case 1, `K⁺(¬β₁)(z₀)`, PDF p.9, carried by `kplusLeftBlock`
    (`Lemma53Faithful.lean:189`) — still forces `vea.negFixFaithful` at the top of the chain.

    Carrier-free: the hypothesis is `kplus` at `z₀` itself, not a carrier assumption that would
    produce it. This is the Phase-8 counterpart of `negFixListFaithful_case1_is_indispensable`
    (`NegFixListFaithful.lean:542`): that one shows the limit disjunct cannot be absorbed by its
    neighbours *inside* the recursion, this one shows it is not quietly discarded *by the lift*.
    Together they exclude the two ways a three-disjunct recursion degrades into a two-disjunct one
    without any statement in this module becoming false. -/
theorem VecEA2.negFixFaithful_carries_limit_gate {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (a b : TemporalPred)
    (qs : List (TemporalPred × TemporalPred))
    (hpairs : vea.bracket.foldPairs = (a, b) :: qs)
    (z0 z1 : M.carrier)
    (hk : kplus M atomMap (vea.bracket.segmentTypes ⟨0, Nat.succ_pos n⟩).neg.formula z0) :
    vea.negFixFaithful.holds M atomMap z0 z1 := by
  refine VecEA2.negFixFaithful_of_bracket M atomMap vea z0 z1 ?_
  show (negFixListFaithful (vea.bracket.segmentTypes ⟨0, Nat.succ_pos n⟩)
    vea.bracket.foldPairs).holds M atomMap z0 z1
  rw [hpairs]
  simp only [negFixListFaithful]
  refine (VVecEA2.disj_holds M atomMap _ _ z0 z1).mpr (Or.inl ?_)
  exact (kplusLeftBlock_holds M atomMap _ z0 z1).mpr hk

/-! ## Availability shim (attained → faithful, never the reverse) -/

/-- The faithful fold is available wherever the attained one is, and needs only the INF half:
    `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`) supplies the carrier, and
    `HasAttainedSUP` — which `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:183`) requires —
    is not needed at all. Mirrors `negFixListFaithful_iff_of_attained`
    (`NegFixListFaithful.lean:574`).

    The shim runs attained → faithful. No declaration in this module runs it in the opposite
    direction; a faithful → attained use would be a strengthening, not a lift. -/
theorem VVecEA2.negFixFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    v.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1 :=
  VVecEA2.negFixFaithful_iff M atomMap h_INF.toHasDedekindINF v z0 z1 h_lt

end FormalSystem.Metalogic.WeakCanonical.Kamp
