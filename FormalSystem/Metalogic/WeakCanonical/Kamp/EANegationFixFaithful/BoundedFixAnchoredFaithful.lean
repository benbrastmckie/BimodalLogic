/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFixAnchored
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.BoundedFixFaithful

/-!
# Anchored Corollary 5.4(1)/(2) at `VVecEA2` over the faithful carrier (Rabinovich, PDF pp.9-10)

The anchored mirrors of `BoundedFixFaithful.lean`. Where that module lands Rabinovich's Cor 5.4 at
the `α := ⊤` innermost fold goal, this one lands it at an arbitrary anchor `α` — the point type
that sits AT the moving endpoint after the outermost peel of the fixed-formula negation recursion.

## The anchor is Rabinovich's, not an invention of the tree

PDF p.9 defines the fold chain of Cor 5.4(1) as

> `Fₙ := αₙ`
> `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`   for `i = 1, …, n`

The innermost fold goal is **already a point type** in the paper — `αₙ`, not `⊤`. The anchored
generalization here is therefore the paper's own construction read at `αₙ := α`, and
`untilFoldAnchored` / `sinceFoldAnchored` (`EANegationFix/BoundedFixAnchored.lean:36`, `:262`) are
that reading. PDF p.10's Figure 1 is where the shape is put to work: the split point `z` of
`B₂(z₀,z,z₁) := [α₀,β₁,α₁,β₂,β₂](z₀,z) ∧ [β₂,β₂,α₂,β₃,α₃](z,z₁)` is an interior point carrying
point types handed to it by both adjacent brackets — an endpoint that is anchored rather than free.

## What changes relative to the attained anchored pair

`negBoundedRightFixAnchored` (`EANegationFix/BoundedFixAnchored.lean:154`) and
`negBoundedLeftFixAnchored` (`:381`) are typed `VBracketFormula`, which carries no endpoint
predicates: it is a disjunction of pure interval brackets. PDF p.9's printed head disjunct `¬F₀(z₀)`
is a **point** condition at `z₀` and cannot be written in that type, so both landed definitions
re-express it as an interval disjunct — `rightPinBracket` at `:156-157` and `leftPinBracket` at
`:383-384`, each asserting the existence of an *attained* first (resp. last) `¬β`-point. Recovering
such a point is what forces attainment into the anchored `_iff` lemmas a second time, over and above
the copy Lemma 5.3 consumes:

* `negBoundedRightFixAnchored_iff` (`:164`) spends `h_INF.first_occ_tp` at `:237`;
* `negBoundedLeftFixAnchored_iff` (`:392`) spends `h_SUP.last_occ_tp` at `:468` — and
  `HasAttainedSUP` enters that statement for no other reason.

`VVecEA2` (`VecEAFormula.lean:277`) does carry endpoint predicates: `VecEA2.holds`
(`VecEAFormula.lean:268`) is `endpointLeft(z₀) ∧ endpointRight(z₁) ∧ bracket(z₀,z₁)`. At that type
`¬F₀(z₀)` is writable *as printed*, no first-`¬β` point has to be produced, and the second
attainment consumption simply disappears — exactly as in the unanchored case.

| | attained anchored, `VBracketFormula` | faithful anchored, `VVecEA2` (here) |
|---|---|---|
| Cor 5.4(1) head | `rightPinBracket` (attained first `¬β₁`) | `¬F₀(z₀)`, as printed |
| Cor 5.4(1) carrier | `HasAttainedINF` | `HasDedekindINF` |
| Cor 5.4(2) head | `leftPinBracket` (attained last `¬βₙ`) | `¬Ĝ(z₁)`, as printed |
| Cor 5.4(2) carrier | `HasAttainedINF` **and** `HasAttainedSUP` | `HasDedekindINF` alone |

The head construction is reused verbatim from `BoundedFixFaithful.lean`: `endpointFailLeft` /
`endpointFailRight` and their `_holds` characterizations are parametric in the point predicate, so
the anchor rides in through the predicate argument and nothing about the head is re-derived here.
The chain arm is `negChainOnFaithful` (`Lemma53Faithful.lean:217`) over the **anchored** chain
predicate lists, spliced exactly as the attained anchored definitions splice `negChainOn`.

Nothing in `EANegationFix/` is deleted, weakened, or edited. `negBoundedRightFixAnchored`,
`negBoundedLeftFixAnchored` and their `_iff` lemmas stay live and stay consumed; everything below is
a pure addition, and the attained carriers reach the faithful ones through the landed shim
`HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`).

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
Everything below cites **PDF pp.9-10**. The companion `.md` conversion is corrupt and is never
ground truth.

## Non-vacuity — what these statements exclude, and where the carrier is actually spent

1. **Neither anchored arm re-introduces attainment.** The only carrier hypothesis in
   `negBoundedRightFixAnchoredFaithful_iff` is `HasDedekindINF`, and the only carrier hypothesis in
   `negBoundedLeftFixAnchoredFaithful_iff` is `HasDedekindINF`. `HasAttainedINF`, `HasAttainedSUP`,
   `HasDefinableINF` and `HasDefinableSUP` occur in **no** statement in this module except the two
   deliberate `_of_attained` shims, whose entire content is that the attained hypothesis still
   reaches the faithful result. Checkable from the signatures, not merely asserted here.

2. **Where the faithful carrier's weak branch is spent, named exactly.** The head disjunct of each
   anchored formula consumes **no carrier at all** — it is a point condition discharged by
   `endpointFailLeft_holds` / `endpointFailRight_holds` (`BoundedFixFaithful.lean:121`, `:144`),
   which have no structural hypothesis beyond `OrderedMonadicStructure`. The carrier is spent
   entirely in the chain arm, through the `negChainOnFaithful_iff` (`Lemma53Faithful.lean:228`) call
   each `_iff` below makes in **both** the `mp` and the `mpr` direction. Inside that lemma the proof
   `rcases`es `h_INF.first_occ` (`Lemma53Faithful.lean:274`) and its **left** disjunct —
   `hk : kplus M atomMap P z0`, Rabinovich's *Subcase `r₀ = z₀`* (PDF p.8) — is the branch at
   `Lemma53Faithful.lean:277-282`, discharged by `orderedPointsExist_combine_kplus`
   (`Lemma53Faithful.lean:281`). That is the `K⁺` branch the attained carrier deletes, and it is on
   the invoked code path in both directions of both lemmas below.

3. **The `K⁻`/`kminus` branch is NOT taken here, and `HasDedekindSUP` is not consumed.** Stated
   rather than papered over. `HasAttainedSUP` entered `negBoundedLeftFixAnchored_iff`
   (`EANegationFix/BoundedFixAnchored.lean:394`) for exactly one purpose: placing
   `leftPinBracket`'s attained *last* `¬βₙ`-point at `:468`. Once the head is the printed `¬Ĝ(z₁)`,
   the SUP carrier has nothing left to do — the chain arm of anchored Cor 5.4(2) is still an
   **increasing** chain of points (`chainAllTrue (sinceChainPredsAnchored …)`), so it is still
   `negChainOnFaithful` and still `HasDedekindINF`. `negBoundedLeftFixAnchoredFaithful_iff`
   therefore carries strictly fewer hypotheses than its attained counterpart rather than the
   mirrored-carrier pair one might expect. Declining to state an unused `HasDedekindSUP` is
   deliberate: an unused hypothesis is a strengthening that buys nothing and hides what the proof
   actually costs.

4. **What is NOT claimed.** No structure is exhibited here in which `K⁺(P)(z₀)` actually holds; that
   needs a formalized non-attained Dedekind-complete chain, which this tree does not build
   (`DedekindINF.lean:49-50` states that absence explicitly). What is established is that the
   anchored faithful statements are provable with the weaker hypothesis.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Anchored Cor 5.4(1), faithful (PDF pp.9-10) -/

/-- `F₀` of the anchored Cor 5.4(1), as the tree spells it: `F₀ := β₁ Until F₁` with
    `F₁ := untilFoldAnchored α` of the fold pairs and `β₁ := bf.segmentTypes 0`. The anchor `α` is
    Rabinovich's `Fₙ := αₙ` (PDF p.9) read at the peeled outermost point type; `rightFoldHead`
    (`BoundedFixFaithful.lean:165`) is the `α := ⊤` reading of the same definition. -/
noncomputable def rightFoldHeadAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : TemporalPred :=
  TemporalPred.untl (untilFoldAnchored α bf.foldPairs) (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)

/-- **Anchored Cor 5.4(1), faithful form** (Rabinovich 2014, PDF pp.9-10): the `VVecEA2` formula
    equivalent to `¬∃ z ∈ (z₀,z₁), α(z) ∧ bf.holds z₀ z` over `HasDedekindINF`.

    Disjuncts, exactly the two the paper prints on p.9:
    1. `¬F₀(z₀)` — as a left-endpoint predicate, needing no carrier;
    2. `Oₙ(F₁,…,Fₙ, z₀, z₁)` — `negChainOnFaithful` (`Lemma53Faithful.lean:217`) over the anchored
       chain predicates.

    Compare `negBoundedRightFixAnchored` (`EANegationFix/BoundedFixAnchored.lean:154`), which
    replaces disjunct (1) by the attained-first-`¬β₁` interval encoding `rightPinBracket` because
    its `VBracketFormula` result type cannot carry an endpoint predicate. -/
noncomputable def negBoundedRightFixAnchoredFaithful (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VVecEA2 :=
  ⟨⟨0, endpointFailLeft (rightFoldHeadAnchored α bf)⟩ ::
    (negChainOnFaithful (untilChainPredsAnchored α bf.foldPairs)).disjuncts⟩

/-- **Anchored Cor 5.4(1) iff, faithful** (PDF pp.9-10). The carrier is `HasDedekindINF` alone —
    Rabinovich's eq (5.2) hypothesis as stated in `DedekindINF.lean:136` — where the attained
    counterpart `negBoundedRightFixAnchored_iff` (`EANegationFix/BoundedFixAnchored.lean:164`)
    needs `HasAttainedINF`, spending it a second time at `:237` on `first_occ_tp`. -/
theorem negBoundedRightFixAnchoredFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixAnchoredFaithful α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z0 z := by
  -- PDF p.9's observation at the anchor, already discharged in the tree and carrier-free: an
  -- `α`-anchored instance of the bracket to the right of `z₀` splits into the point condition
  -- `F₀(z₀)` and the anchored chain.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z0 z) ↔
      ((rightFoldHeadAnchored α bf).EvalAt M atomMap z0 ∧
       (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no anchored bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hF0, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- disjunct (1): the endpoint condition `¬F₀(z₀)` contradicts `F₀(z₀)` outright
      subst heq
      exact (endpointFailLeft_holds M atomMap (rightFoldHeadAnchored α bf) z0 z1).mp hh hF0
    · -- disjunct (2): Lemma 5.3 over the faithful carrier
      exact (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no anchored bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds M atomMap z0 z1
    · -- the chain exists, so `F₀` must fail at `z₀`: that IS disjunct (1), no carrier needed
      refine ⟨_, List.mem_cons_self .., ?_⟩
      change (endpointFailLeft (rightFoldHeadAnchored α bf)).holds M atomMap z0 z1
      rw [endpointFailLeft_holds]
      exact fun hF0 => hnex (h_rhs.mpr ⟨hF0, hchain⟩)
    · -- the chain fails: the faithful Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## Anchored Cor 5.4(2), faithful (PDF pp.9-10)

*"(2) is the mirror image of (1) and is proved similarly."* — PDF p.9. -/

/-- `Ĝ` of the anchored Cor 5.4(2), as the tree spells it: `Ĝ := βₙ Since G₁` with
    `G₁ := sinceFoldAnchored α` of the reversed fold pairs and `βₙ := bf.segmentTypes n`. Mirror of
    `rightFoldHeadAnchored`; `leftFoldHead` (`BoundedFixFaithful.lean:236`) is its `α := ⊤`
    reading. -/
noncomputable def leftFoldHeadAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : TemporalPred :=
  TemporalPred.snce (sinceFoldAnchored α bf.foldPairsRev)
    (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)

/-- **Anchored Cor 5.4(2), faithful form** (Rabinovich 2014, PDF pp.9-10): the `VVecEA2` formula
    equivalent to `¬∃ z ∈ (z₀,z₁), α(z) ∧ bf.holds z z₁` over `HasDedekindINF`.

    Disjuncts, mirroring `negBoundedRightFixAnchoredFaithful`:
    1. `¬Ĝ(z₁)` — as a right-endpoint predicate, needing no carrier;
    2. `Oₙ(G₁,…,G_{n+1}, z₀, z₁)` — `negChainOnFaithful` over the anchored Since folds.

    Compare `negBoundedLeftFixAnchored` (`EANegationFix/BoundedFixAnchored.lean:381`), which
    replaces disjunct (1) by the attained-last-`¬βₙ` interval encoding `leftPinBracket`. -/
noncomputable def negBoundedLeftFixAnchoredFaithful (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VVecEA2 :=
  ⟨⟨0, endpointFailRight (leftFoldHeadAnchored α bf)⟩ ::
    (negChainOnFaithful (sinceChainPredsAnchored α bf.foldPairsRev)).disjuncts⟩

/-- **Anchored Cor 5.4(2) iff, faithful** (PDF pp.9-10). The carrier is `HasDedekindINF` alone,
    where the attained counterpart `negBoundedLeftFixAnchored_iff`
    (`EANegationFix/BoundedFixAnchored.lean:392`) needs `HasAttainedINF` **and** `HasAttainedSUP` —
    the latter only to place `leftPinBracket`'s attained last `¬βₙ`-point at `:468`, which the
    printed endpoint disjunct does not require. -/
theorem negBoundedLeftFixAnchoredFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixAnchoredFaithful α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z z1 := by
  -- The mirror of PDF p.9's observation at the anchor, likewise already discharged and
  -- carrier-free.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z z1) ↔
      ((leftFoldHeadAnchored α bf).EvalAt M atomMap z1 ∧
       (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hG, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · subst heq
      exact (endpointFailRight_holds M atomMap (leftFoldHeadAnchored α bf) z0 z1).mp hh hG
    · exact (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds M atomMap z0 z1
    · refine ⟨_, List.mem_cons_self .., ?_⟩
      change (endpointFailRight (leftFoldHeadAnchored α bf)).holds M atomMap z0 z1
      rw [endpointFailRight_holds]
      exact fun hG => hnex (h_rhs.mpr ⟨hG, hchain⟩)
    · obtain ⟨d, hmem, hh⟩ :=
        (negChainOnFaithful_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## Recorded delta against the attained anchored versions

These two lemmas make the carrier claim checkable rather than asserted: each anchored faithful
statement is *derivable from the attained hypotheses* through the landed shim, so the attained
anchored call sites lose nothing, while the converse direction is exactly what is not available. -/

/-- The anchored faithful Cor 5.4(1) is available wherever the attained anchored one is:
    `HasAttainedINF` reaches `HasDedekindINF` through `HasAttainedINF.toHasDedekindINF`
    (`DedekindINF.lean:172`). -/
theorem negBoundedRightFixAnchoredFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixAnchoredFaithful α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z0 z :=
  negBoundedRightFixAnchoredFaithful_iff M atomMap h_INF.toHasDedekindINF α bf z0 z1 h_lt

/-- The anchored faithful Cor 5.4(2) is likewise available wherever the attained anchored one is —
    and needs only the INF half of the attained pair that `negBoundedLeftFixAnchored_iff`
    (`EANegationFix/BoundedFixAnchored.lean:392`) consumes. -/
theorem negBoundedLeftFixAnchoredFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixAnchoredFaithful α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.EvalAt M atomMap z ∧
      bf.holds M atomMap z z1 :=
  negBoundedLeftFixAnchoredFaithful_iff M atomMap h_INF.toHasDedekindINF α bf z0 z1 h_lt

/-! ## The anchored head disjunct SUBSUMES the anchored attained pin — machine-checked

Replacing `rightPinBracket`/`leftPinBracket` by the printed endpoint condition is a genuine
weakening only if nothing the pin could express is lost. The two theorems below establish exactly
that at the anchor, with **no carrier hypothesis on either side**: wherever the attained anchored
pin disjunct fires, the anchored faithful endpoint disjunct fires too. The converse fails — an
interval on which `F₀(z₀)` merely fails, with no attained first `¬β₁`-point available, satisfies the
endpoint disjunct and no pin — and that asymmetry is why the carrier drops. -/

/-- Whenever `negBoundedRightFixAnchored`'s attained pin disjunct
    (`EANegationFix/BoundedFixAnchored.lean:156-157`) holds, so does
    `negBoundedRightFixAnchoredFaithful`'s printed endpoint disjunct `¬F₀(z₀)`. No carrier
    hypothesis is used on either side. This is the transcription of the pin-vs-`F₀` trichotomy
    already carried out inside `negBoundedRightFixAnchored_iff`
    (`EANegationFix/BoundedFixAnchored.lean:202-205`), isolated here so the subsumption is a
    checkable statement rather than a step buried in a larger proof. -/
theorem endpointFailLeftAnchored_of_rightPinBracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier)
    (h : (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
      (untilFoldAnchored α bf.foldPairs)).holds M atomMap z0 z1) :
    (endpointFailLeft (rightFoldHeadAnchored α bf)).holds M atomMap z0 z1 := by
  rw [endpointFailLeft_holds]
  intro hF0
  obtain ⟨r, hr0, _hr1, hseg, hns, hnF1⟩ :=
    (rightPinBracket_holds_iff M atomMap _ _ z0 z1).mp h
  rw [rightFoldHeadAnchored, TemporalPred.eval_at_untl] at hF0
  obtain ⟨y, hy0, hyF1, hyseg⟩ := hF0
  rcases lt_trichotomy y r with hlt | heq | hgt
  · exact (hseg y hy0 hlt).2 hyF1
  · exact hnF1 (heq ▸ hyF1)
  · exact hns (hyseg r hr0 hgt)

/-- Mirror of `endpointFailLeftAnchored_of_rightPinBracket`: `negBoundedLeftFixAnchored`'s attained
    pin disjunct (`EANegationFix/BoundedFixAnchored.lean:383-384`) implies
    `negBoundedLeftFixAnchoredFaithful`'s printed endpoint disjunct `¬Ĝ(z₁)`, with no carrier
    hypothesis on either side. Note in particular that no `HasAttainedSUP` appears here even though
    the attained anchored pin is the disjunct `HasAttainedSUP` exists to construct
    (`EANegationFix/BoundedFixAnchored.lean:468`). -/
theorem endpointFailRightAnchored_of_leftPinBracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier)
    (h : (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
      (sinceFoldAnchored α bf.foldPairsRev)).holds M atomMap z0 z1) :
    (endpointFailRight (leftFoldHeadAnchored α bf)).holds M atomMap z0 z1 := by
  rw [endpointFailRight_holds]
  intro hG
  obtain ⟨r, _hr0, hr1, hns, hnG, hseg⟩ :=
    (leftPinBracket_holds_iff M atomMap _ _ z0 z1).mp h
  rw [leftFoldHeadAnchored, TemporalPred.eval_at_snce] at hG
  obtain ⟨y, hy1, hyG, hyseg⟩ := hG
  rcases lt_trichotomy r y with hlt | heq | hgt
  · exact (hseg y hlt hy1).2 hyG
  · exact hnG (heq ▸ hyG)
  · exact hns (hyseg r hgt hr1)

end FormalSystem.Metalogic.WeakCanonical.Kamp
