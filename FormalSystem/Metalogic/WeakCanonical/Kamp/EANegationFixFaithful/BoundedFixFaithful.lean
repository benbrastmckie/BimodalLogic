/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFix
import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53Faithful

/-!
# Corollary 5.4(1)/(2) at `VVecEA2` over the faithful carrier (Rabinovich, PDF p.9)

Rabinovich's Cor 5.4(1) (PDF p.9) closes with exactly one displayed disjunction:

> *"The above observation and Lemma 5.3 imply that `¬F₀(z₀) ∨ Oₙ(F₁,…,Fₙ,z₀,z₁)` is a `∨∃⃗∀`
> formula that is equivalent to `¬(∃z)^{<z₁}_{>z₀}[α₀,β₁,α₁,β₂,…,α_{n-1},βₙ,αₙ](z₀,z)."*

Two disjuncts, and the first of them — `¬F₀(z₀)` — is a **point** condition at the left endpoint
`z₀`, not an interval condition. That is the whole content of this module.

## Why the landed attained version looks different, and what changes here

`negBoundedRightFix` (`EANegationFix/BoundedFix.lean:446`) is typed `VBracketFormula`, and a
`VBracketFormula` **carries no endpoint predicates at all**: it is a disjunction of pure interval
brackets. Rabinovich's `¬F₀(z₀)` therefore could not be written down in that type, and was instead
re-expressed as an *interval* disjunct, `rightPinBracket`
(`EANegationFix/BoundedFix.lean:411`) — the bracket `[s ∧ ¬F₁, (¬s ∧ ¬F₁), ⊤]`, which asserts the
existence of a point `r ∈ (z₀,z₁)` that is the **attained first `¬s`-point**. That re-expression is
sound but it is not free: recovering such an `r` is exactly what forces `HasAttainedINF` into
`negBoundedRightFix_iff` a second time, over and above the copy that Lemma 5.3 consumes. The module
docstring at `EANegationFix/BoundedFix.lean:406-410` says so in as many words.

`VVecEA2` (`VecEAFormula.lean:277`) is the type that **does** carry endpoint predicates:
`VecEA2.holds` (`VecEAFormula.lean:268`) is
`endpointLeft(z₀) ∧ endpointRight(z₁) ∧ bracket(z₀,z₁)`. At this type Rabinovich's `¬F₀(z₀)` is
writable *as printed*, as a left-endpoint predicate on an otherwise trivial block. No first-`¬s`
point has to be produced, so no attainment has to be assumed, and the disjunct is the paper's
rather than a re-encoding of it.

The consequence for the carrier is the point of the exercise:

| | attained, `VBracketFormula` | faithful, `VVecEA2` (here) |
|---|---|---|
| Cor 5.4(1) head | `rightPinBracket` (needs an attained first `¬β₁`) | `¬F₀(z₀)`, as printed |
| Cor 5.4(1) carrier | `HasAttainedINF` | `HasFaithfulDedekindINF` |
| Cor 5.4(2) head | `leftPinBracket` (needs an attained last `¬βₙ`) | `¬Ĝ(z₁)`, as printed |
| Cor 5.4(2) carrier | `HasAttainedINF` **and** `HasAttainedSUP` | `HasFaithfulDedekindINF` alone |

Nothing in `EANegationFix/` is deleted, weakened, or edited. `negBoundedRightFix`,
`negBoundedLeftFix` and their `_iff` lemmas stay live and stay consumed; everything below is a pure
addition, and the attained carriers reach the faithful one through the landed shims
`HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`),
`HasDedekindINF.toHasFaithfulDedekindINF` (`KPlusFaithful.lean:364`) and
`HasAttainedSUP.toHasDedekindSUP` (`DedekindINF.lean:200`).

`ADAPTED-FROM`: both `_iff` statements below were first pinned at `HasDedekindINF`. Re-basing
`negChainOnFaithful_iff` (`Lemma53Faithful.lean`) onto `HasFaithfulDedekindINF` moved the two
carrier binders here, and nothing else: neither statement below opens the carrier, so there is no
destructure to re-shape. The change is one clause per binder.

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
Everything below cites **PDF p.9**. The companion `.md` conversion is corrupt and is never ground
truth.

## Non-vacuity — what these statements exclude, and where the carrier is actually spent

Every module that lands or weakens a carrier must state what the carrier excludes and where its
weak branch is genuinely taken; an over-strong hypothesis and a re-introduced attainment both pass
sorry-free, axiom-clean and EXIT 0 exactly as a vacuous conclusion does.

1. **Neither statement below re-introduces attainment.** The only carrier hypothesis in
   `negBoundedRightFixFaithful_iff` is `HasFaithfulDedekindINF`, and the only carrier hypothesis in
   `negBoundedLeftFixFaithful_iff` is `HasFaithfulDedekindINF`. `HasAttainedINF`, `HasAttainedSUP`,
   `HasDefinableINF` and `HasDefinableSUP` occur in **no** statement in this module. This is
   checkable from the signatures, not merely asserted here.

2. **Where the faithful carrier's weak branch is spent, named exactly.** The head disjunct of each
   formula consumes **no carrier at all** — it is a point condition, discharged by
   `endpointFailLeft_holds` / `endpointFailRight_holds`, which have no structural hypothesis beyond
   `OrderedMonadicStructure`. The carrier is spent entirely in the chain arm, inside
   `negChainOnFaithful_iff` (`Lemma53Faithful.lean`), and there the `K⁺` branch is genuinely
   taken: `negChainOnFaithful_iff` `rcases`es `h_INF.first_occ` and its **left** disjunct is
   Rabinovich's *Subcase r₀ = z₀* (PDF p.8), discharged by `orderedPointsExist_combine_kplusOpen`
   (`Lemma53Faithful.lean`) at the source's conjunct-free `K⁺`. **This module itself never opens
   the carrier**: `h_INF` is passed to `negChainOnFaithful_iff` and to nothing else, in all four
   uses. That branch is reached from both `negBoundedRightFixFaithful_iff` and
   `negBoundedLeftFixFaithful_iff`, in both the `mp` and the `mpr` direction, through the
   `negChainOnFaithful_iff` call each of them makes.

3. **What is NOT claimed.** No structure is exhibited here in which `K⁺(P)(z₀)` actually holds;
   that needs a formalized non-attained Dedekind-complete chain, which this tree does not build
   (`DedekindINF.lean:49-50` states that absence explicitly). On Prior structures — the live goal
   chain — attainment holds outright, so no current consumer can distinguish the faithful carrier
   from the attained one. What is established is that the faithful statements are provable with the
   weaker hypothesis, which is what the re-base needs and what the attained versions cannot supply.

4. **The `HasDedekindSUP` carrier is not consumed here, and is not silently smuggled in either.**
   The landed `negBoundedLeftFix_iff` (`EANegationFix/BoundedFix.lean:774`) takes both
   `HasAttainedINF` and `HasAttainedSUP`, the second solely to build `leftPinBracket`'s attained
   *last* `¬βₙ`-point. Once the head is the printed endpoint condition `¬Ĝ(z₁)`, that second
   carrier has nothing left to do: the chain arm of Cor 5.4(2) is still an **increasing** chain of
   points (`chainAllTrue (sinceChainPreds …)`), so it is still `negChainOnFaithful` and still
   `HasFaithfulDedekindINF`. `negBoundedLeftFixFaithful_iff` therefore carries strictly fewer
   hypotheses than its attained counterpart, rather than the mirrored-carrier pair one might
   expect. Declining
   to state an unused `HasDedekindSUP` hypothesis is deliberate: an unused hypothesis is a
   strengthening that buys nothing and hides what the proof actually costs.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Rabinovich's endpoint disjunct, carried natively

`¬F₀(z₀)` (Cor 5.4(1), PDF p.9) and its mirror `¬Ĝ(z₁)` (Cor 5.4(2)) are point conditions at an
endpoint of the interval. `VecEA2` has a field for exactly that. -/

/-- A `VecEA2` block asserting a point condition at the **left** endpoint `z₀` and nothing else:
    trivial right endpoint, trivial (`⊤`) interior.

    Source correspondence: PDF p.9, the `¬F₀(z₀)` disjunct of Cor 5.4(1). -/
def endpointFailLeft (ψ : TemporalPred) : VecEA2 0 :=
  { endpointLeft := ψ.neg
    endpointRight := TemporalPred.top
    bracket := BracketFormula.trivial TemporalPred.top }

theorem endpointFailLeft_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (ψ : TemporalPred) (z0 z1 : M.carrier) :
    (endpointFailLeft ψ).holds M atomMap z0 z1 ↔ ¬ψ.EvalAt M atomMap z0 := by
  simp only [endpointFailLeft, VecEA2.holds]
  rw [BracketFormula.trivial_holds]
  constructor
  · rintro ⟨h, -, -⟩
    exact (TemporalPred.eval_at_neg' M atomMap ψ z0).mp h
  · intro h
    exact ⟨(TemporalPred.eval_at_neg' M atomMap ψ z0).mpr h,
      TemporalPred.eval_at_top M atomMap z1,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-- A `VecEA2` block asserting a point condition at the **right** endpoint `z₁` and nothing else.
    Mirror of `endpointFailLeft`.

    Source correspondence: PDF p.9, the mirror of the `¬F₀(z₀)` disjunct in Cor 5.4(2). -/
def endpointFailRight (ψ : TemporalPred) : VecEA2 0 :=
  { endpointLeft := TemporalPred.top
    endpointRight := ψ.neg
    bracket := BracketFormula.trivial TemporalPred.top }

theorem endpointFailRight_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (ψ : TemporalPred) (z0 z1 : M.carrier) :
    (endpointFailRight ψ).holds M atomMap z0 z1 ↔ ¬ψ.EvalAt M atomMap z1 := by
  simp only [endpointFailRight, VecEA2.holds]
  rw [BracketFormula.trivial_holds]
  constructor
  · rintro ⟨-, h, -⟩
    exact (TemporalPred.eval_at_neg' M atomMap ψ z1).mp h
  · intro h
    exact ⟨TemporalPred.eval_at_top M atomMap z0,
      (TemporalPred.eval_at_neg' M atomMap ψ z1).mpr h,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## Cor 5.4(1), faithful (PDF p.9) -/

/-- `F₀` of Cor 5.4(1) as the tree spells it: `F₀ := β₁ Until F₁` with `F₁ := untilFold` of the
    fold pairs and `β₁ := bf.segmentTypes 0`. This is the left-hand conjunct of the observation on
    PDF p.9 (*"there is `z ∈ (z₀,z₁)` such that `[α₀,β₁,…,αₙ](z₀,z)` iff `F₀(z₀)` and there is an
    increasing sequence `x₁ < ⋯ < xₙ` …"*), already discharged in the tree by
    `exists_bracketOf_right_iff`. -/
noncomputable def rightFoldHead {n : Nat} (bf : BracketFormula n) : TemporalPred :=
  TemporalPred.untl (untilFold bf.foldPairs) (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)

/-- **Cor 5.4(1), faithful form** (Rabinovich 2014, PDF p.9): the `VVecEA2` formula equivalent to
    `¬∃ z ∈ (z₀,z₁), bf.holds z₀ z` over `HasFaithfulDedekindINF`.

    Disjuncts, exactly the two the paper prints:
    1. `¬F₀(z₀)` — as a left-endpoint predicate, needing no carrier;
    2. `Oₙ(F₁,…,Fₙ, z₀, z₁)` — `negChainOnFaithful` (`Lemma53Faithful.lean:217`), the printed
       three-disjunct Lemma 5.3.

    Compare `negBoundedRightFix` (`EANegationFix/BoundedFix.lean:446`), which replaces disjunct (1)
    by the attained-first-`¬β₁` interval encoding `rightPinBracket` because its result type cannot
    carry an endpoint predicate. -/
noncomputable def negBoundedRightFixFaithful {n : Nat} (bf : BracketFormula n) : VVecEA2 :=
  ⟨⟨0, endpointFailLeft (rightFoldHead bf)⟩ ::
    (negChainOnFaithful (untilChainPreds bf.foldPairs)).disjuncts⟩

/-- **Cor 5.4(1) iff, faithful** (PDF p.9). The carrier is `HasFaithfulDedekindINF` alone —
    Rabinovich's eq (5.2) hypothesis read with the source's own conjunct-free `K⁺`
    (`KPlusFaithful.lean`) — where the attained counterpart `negBoundedRightFix_iff`
    (`EANegationFix/BoundedFix.lean:455`) needs `HasAttainedINF`.

    `ADAPTED-FROM`: the previous pin of this same statement bound `HasDedekindINF`. The one clause
    that changed is the carrier binder; the statement and the proof are otherwise unchanged. The
    swap is forced by `negChainOnFaithful_iff` (`Lemma53Faithful.lean`), which now binds the
    faithful carrier, and it strictly weakens the hypothesis:
    `HasDedekindINF.toHasFaithfulDedekindINF` (`KPlusFaithful.lean:364`) runs one way only. -/
theorem negBoundedRightFixFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasFaithfulDedekindINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixFaithful bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z := by
  -- PDF p.9's observation, already discharged in the tree and carrier-free: an instance of the
  -- bracket to the right of `z₀` splits into the point condition `F₀(z₀)` and the chain.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z) ↔
      ((rightFoldHead bf).EvalAt M atomMap z0 ∧
       (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hF0, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- disjunct (1): the endpoint condition `¬F₀(z₀)` contradicts `F₀(z₀)` outright
      subst heq
      exact (endpointFailLeft_holds M atomMap (rightFoldHead bf) z0 z1).mp hh hF0
    · -- disjunct (2): Lemma 5.3 over the faithful carrier
      exact (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1
    · -- the chain exists, so `F₀` must fail at `z₀`: that IS disjunct (1), no carrier needed
      refine ⟨_, List.mem_cons_self .., ?_⟩
      change (endpointFailLeft (rightFoldHead bf)).holds M atomMap z0 z1
      rw [endpointFailLeft_holds]
      exact fun hF0 => hnex (h_rhs.mpr ⟨hF0, hchain⟩)
    · -- the chain fails: the faithful Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## Cor 5.4(2), faithful (PDF p.9)

*"(2) is the mirror image of (1) and is proved similarly."* — PDF p.9. -/

/-- `Ĝ` of Cor 5.4(2) as the tree spells it: `Ĝ := βₙ Since G₁` with `G₁ := sinceFold` of the
    reversed fold pairs and `βₙ := bf.segmentTypes n`. Mirror of `rightFoldHead`. -/
noncomputable def leftFoldHead {n : Nat} (bf : BracketFormula n) : TemporalPred :=
  TemporalPred.snce (sinceFold bf.foldPairsRev) (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)

/-- **Cor 5.4(2), faithful form** (Rabinovich 2014, PDF p.9): the `VVecEA2` formula equivalent to
    `¬∃ z ∈ (z₀,z₁), bf.holds z z₁` over `HasFaithfulDedekindINF`.

    Disjuncts, mirroring `negBoundedRightFixFaithful`:
    1. `¬Ĝ(z₁)` — as a right-endpoint predicate, needing no carrier;
    2. `Oₙ(G₁,…,G_{n+1}, z₀, z₁)` — `negChainOnFaithful` over the Since folds.

    Compare `negBoundedLeftFix` (`EANegationFix/BoundedFix.lean:764`), which replaces disjunct (1)
    by the attained-last-`¬βₙ` interval encoding `leftPinBracket`. -/
noncomputable def negBoundedLeftFixFaithful {n : Nat} (bf : BracketFormula n) : VVecEA2 :=
  ⟨⟨0, endpointFailRight (leftFoldHead bf)⟩ ::
    (negChainOnFaithful (sinceChainPreds bf.foldPairsRev)).disjuncts⟩

/-- **Cor 5.4(2) iff, faithful** (PDF p.9). The carrier is `HasFaithfulDedekindINF` alone, where
    the attained counterpart `negBoundedLeftFix_iff` (`EANegationFix/BoundedFix.lean:774`) needs
    `HasAttainedINF` **and** `HasAttainedSUP` — the latter only to place `leftPinBracket`'s
    attained last `¬βₙ`-point, which the printed endpoint disjunct does not require.

    `ADAPTED-FROM`: the previous pin bound `HasDedekindINF`; the carrier binder is the one clause
    that changed. Mirror of the change recorded on `negBoundedRightFixFaithful_iff`. -/
theorem negBoundedLeftFixFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasFaithfulDedekindINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixFaithful bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1 := by
  -- The mirror of PDF p.9's observation, likewise already discharged and carrier-free.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1) ↔
      ((leftFoldHead bf).EvalAt M atomMap z1 ∧
       (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hG, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · subst heq
      exact (endpointFailRight_holds M atomMap (leftFoldHead bf) z0 z1).mp hh hG
    · exact (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1
    · refine ⟨_, List.mem_cons_self .., ?_⟩
      change (endpointFailRight (leftFoldHead bf)).holds M atomMap z0 z1
      rw [endpointFailRight_holds]
      exact fun hG => hnex (h_rhs.mpr ⟨hG, hchain⟩)
    · obtain ⟨d, hmem, hh⟩ :=
        (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## Recorded delta against the attained versions

These two lemmas are what makes the carrier claim above checkable rather than asserted: each
faithful statement is *derivable from the attained hypotheses* through the landed shim, so the
attained call sites lose nothing, while the converse direction is exactly what is not available. -/

/-- The faithful Cor 5.4(1) is available wherever the attained one is: `HasAttainedINF` reaches
    `HasDedekindINF` through `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`), and
    `HasDedekindINF` reaches the faithful carrier through
    `HasDedekindINF.toHasFaithfulDedekindINF` (`KPlusFaithful.lean:364`). -/
theorem negBoundedRightFixFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixFaithful bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z :=
  negBoundedRightFixFaithful_iff M atomMap
    h_INF.toHasDedekindINF.toHasFaithfulDedekindINF bf z0 z1 h_lt

/-- The faithful Cor 5.4(2) is likewise available wherever the attained one is — and needs only
    the INF half of the attained pair the landed `negBoundedLeftFix_iff` consumes. -/
theorem negBoundedLeftFixFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixFaithful bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1 :=
  negBoundedLeftFixFaithful_iff M atomMap
    h_INF.toHasDedekindINF.toHasFaithfulDedekindINF bf z0 z1 h_lt

/-! ## The head disjunct SUBSUMES the attained pin — machine-checked, not asserted

Replacing `rightPinBracket`/`leftPinBracket` by the printed endpoint condition is only a genuine
weakening if nothing the pin could express is lost. The two theorems below establish exactly that,
with **no carrier hypothesis on either side**: wherever the attained pin disjunct fires, the
faithful endpoint disjunct fires too. The converse fails — an interval on which `F₀(z₀)` merely
fails, with no attained first `¬β₁`-point available, satisfies the endpoint disjunct and no pin —
and that asymmetry is the whole reason the carrier drops. -/

/-- Whenever `negBoundedRightFix`'s attained pin disjunct holds, so does
    `negBoundedRightFixFaithful`'s printed endpoint disjunct `¬F₀(z₀)`. No carrier hypothesis is
    used on either side. This is the transcription of the pin-vs-`F₀` trichotomy already carried
    out inside `negBoundedRightFix_iff` (`EANegationFix/BoundedFix.lean:486-489`), isolated here so
    the subsumption is a checkable statement rather than a step buried in a larger proof. -/
theorem endpointFailLeft_of_rightPinBracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier)
    (h : (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
      (untilFold bf.foldPairs)).holds M atomMap z0 z1) :
    (endpointFailLeft (rightFoldHead bf)).holds M atomMap z0 z1 := by
  rw [endpointFailLeft_holds]
  intro hF0
  obtain ⟨r, hr0, _hr1, hseg, hns, hnF1⟩ :=
    (rightPinBracket_holds_iff M atomMap _ _ z0 z1).mp h
  rw [rightFoldHead, TemporalPred.eval_at_untl] at hF0
  obtain ⟨y, hy0, hyF1, hyseg⟩ := hF0
  rcases lt_trichotomy y r with hlt | heq | hgt
  · exact (hseg y hy0 hlt).2 hyF1
  · exact hnF1 (heq ▸ hyF1)
  · exact hns (hyseg r hr0 hgt)

/-- Mirror of `endpointFailLeft_of_rightPinBracket`: `negBoundedLeftFix`'s attained pin disjunct
    implies `negBoundedLeftFixFaithful`'s printed endpoint disjunct `¬Ĝ(z₁)`, with no carrier
    hypothesis on either side. Note in particular that no `HasAttainedSUP` appears here even though
    the attained pin is the disjunct `HasAttainedSUP` exists to construct. -/
theorem endpointFailRight_of_leftPinBracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier)
    (h : (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
      (sinceFold bf.foldPairsRev)).holds M atomMap z0 z1) :
    (endpointFailRight (leftFoldHead bf)).holds M atomMap z0 z1 := by
  rw [endpointFailRight_holds]
  intro hG
  obtain ⟨r, _hr0, hr1, hns, hnG, hseg⟩ :=
    (leftPinBracket_holds_iff M atomMap _ _ z0 z1).mp h
  rw [leftFoldHead, TemporalPred.eval_at_snce] at hG
  obtain ⟨y, hy1, hyG, hyseg⟩ := hG
  rcases lt_trichotomy r y with hlt | heq | hgt
  · exact (hseg y hlt hy1).2 hyG
  · exact hnG (heq ▸ hyG)
  · exact hns (hyseg r hgt hr1)

end FormalSystem.Metalogic.WeakCanonical.Kamp
