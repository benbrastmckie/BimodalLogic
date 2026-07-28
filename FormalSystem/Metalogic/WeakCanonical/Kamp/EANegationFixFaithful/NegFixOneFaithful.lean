/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFixOne
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.BoundedFixAnchoredFaithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEACombinators
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

/-!
# Lemma 5.1 at one witness, at `VVecEA2` over the faithful carrier (Rabinovich, PDF pp.9-10)

Rabinovich proves Lemma 5.1 on PDF p.9 by an explicit **three-case** split, and the printed output
shape is `∨ᵢ (Condᵢ ∧ Formᵢ)`:

> *"We assume that `(z₀,z₁)` is non-empty. Hence, at least one of the following cases holds:*
> ***Case 1:** `¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`.*
> ***Case 2:** `α₀(z₀)`, and `β₁` holds along `(z₀,z₁)`.*
> ***Case 3:** (1) `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and (2) there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`.*
> *For each of these cases we construct a `∨∃⃗∀` formula `Condᵢ` that describes it … and show that
> if `Condᵢ` holds, then `¬[α₀,β₁…,β_{n-1},α_{n-1},βₙ,αₙ](z₀,z₁)` is equivalent to a `∨∃⃗∀` formula
> `Formᵢ`."*

For the one-witness bracket `bracketOne s0 p s1` (`EANegationFix/NegFixOne.lean:37`) the paper's
names instantiate as `α₀ = ⊤`, `β₁ = s0`, `α₁ = p`, `β₂ = s1`, `α₂ = ⊤`: the `α`'s are **point**
types (`α₀` at `z₀`, `α₁` at the interior witness, `α₂` at `z₁`) and the `β`'s are **segment**
types, exactly as PDF p.10's Figure 1 draws them. With `α₀ = ⊤` the first alternative of Case 1 is
unavailable, so Case 1 is `K⁺(¬s0)(z₀)` alone.

The three cases are the three outcomes of the faithful carrier read at `P := ¬β₁`, which is why
this module needs no case analysis of its own beyond the paper's:

| paper (PDF pp.9-10) | this module | carrier obligation |
|---|---|---|
| Case 2: `β₁` along `(z₀,z₁)` | `negFixOneCase2` | `¬β₁` does not occur — no `first_occ` call |
| Case 1: `K⁺(¬β₁)(z₀)` | `negFixOneCase1` | `HasDedekindINF.first_occ`, **left** disjunct |
| Case 3: the `r₀` pin, eq (5.3) | `negFixOneCase3a/b/c` | `HasDedekindINF.first_occ`, right disjunct |

and eq (5.3) of PDF p.10,

> `INF^{¬β₁}(z₀,z,z₁) := z₀ < z < z₁ ∧ (∀y)^{<z}_{>z₀} β₁(y) ∧ (¬β₁(z) ∨ K⁺(¬β₁)(z))`,

is eq (5.2) of PDF p.8 read at `P := ¬β₁` — the same formula the faithful carrier
`HasDedekindINF` (`DedekindINF.lean:136`) is stated from. Its three conjuncts appear here as: the
`z₀ < r < z₁` of `VVecEA2.concatPin` (`VecEACombinators.lean:194`); the left block `allSeg s0`;
and the pin point type `infPinPoint s0`.

## Why this is not the six-disjunct attained list with the carriers swapped

`negFixOne` (`EANegationFix/NegFixOne.lean:90`) is a **six**-disjunct list `{A, B1, B2, B3, B4,
B4′}` that is not Rabinovich's case split: it is the tree's own formulation, and its cover
(`negFixOne_cover`, `EANegationFix/NegFixOne.lean:207`) pins four *attained* witnesses —

* `:224` the attained **first `p`-point**, via `HasAttainedINF.first_occ_tp p`;
* `:243` the attained **last `p`-point**, via `HasAttainedSUP.last_occ_tp p`;
* `:272` the attained **last `¬s1`-point**, via `HasAttainedSUP.last_occ_tp s1.neg`;
* `:276` the attained **first `¬s0`-point**, via `HasAttainedINF.first_occ_tp s0.neg`.

None of those four appears in Rabinovich's proof. The paper pins exactly one point, `r₀`, and it
is the eq (5.3) infimum of `¬β₁ = ¬s0` — the fourth site's predicate, but taken in the **INF**
(possibly-unattained) sense rather than the attained one. The other three sites have no
counterpart on pp.9-10 at all.

That is not merely a stylistic difference: `NegFixOneFaithfulGateProbe` below **machine-checks**
that the six-disjunct list is not a cover once attainment is dropped. On the `ℝ` structure it
builds, `bracketOne` fails on `(0,10)` and every one of the six disjuncts fails too, while the
faithful carrier's eq (5.2) obligation *is* dischargeable at the very predicate the attained cover
pins. So the six-disjunct list cannot be re-proved under a weaker carrier by any argument; a
faithful `n = 1` negation has to be the paper's case split, which is what is built here.

## What this costs in carrier strength

| | attained, `VBracketFormula` | faithful, `VVecEA2` (here) |
|---|---|---|
| shape | six gated disjuncts `{A,B1,B2,B3,B4,B4′}` | Rabinovich's `∨ᵢ (Condᵢ ∧ Formᵢ)`, three cases |
| pinned points | four, all attained | one, `r₀`, as eq (5.3) |
| carrier | `HasAttainedINF` **and** `HasAttainedSUP` | `HasDedekindINF` **alone** |

Nothing in `EANegationFix/` is deleted, weakened, or edited. `negFixOne`, `negFixOne_cover`,
`negFixOne_iff` and the `ℤ` gate probe `NegFixGateProbe` all stay live and stay consumed
(`NfMultiAnchorBridge/Base.lean:1416` cites them); everything below is a pure addition, and the
attained carriers reach the faithful statement through `HasAttainedINF.toHasDedekindINF`
(`DedekindINF.lean:172`).

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
Everything below cites **PDF pp.9-10**. The companion `.md` conversion is corrupt and is never
ground truth.

## Non-vacuity — what these statements exclude, and where the carrier is actually spent

1. **Nothing here re-introduces attainment.** The only carrier hypothesis in
   `negFixOneFaithful_cover`, `negFixOneFaithful_sound` and `negFixOneFaithful_iff` is
   `HasDedekindINF`. `HasAttainedINF`, `HasAttainedSUP`, `HasDefinableINF` and `HasDefinableSUP`
   occur in **no** statement in this module except the deliberate `_of_attained` shim, whose entire
   content is that the attained hypothesis still reaches the faithful result. Checkable from the
   signatures, not merely asserted here.

2. **`HasDedekindSUP` is NOT consumed, and this is a fact about Rabinovich's proof, not an
   omission.** The attained cover spends `HasAttainedSUP` twice (`:243`, `:272`). Rabinovich's
   Lemma 5.1 proof uses no `K⁻`, no supremum and no last-occurrence point anywhere on pp.9-10: its
   only pinned point is the eq (5.3) **infimum**, and its Case 2 discharges the whole `s1` side
   through Corollary 5.4(2), which `negBoundedLeftFixAnchoredFaithful_iff`
   (`BoundedFixAnchoredFaithful.lean:228`) proves under `HasDedekindINF` alone. Stating an unused
   `HasDedekindSUP` hypothesis here would be a strengthening that buys nothing and hides what the
   proof costs.

3. **Where the faithful carrier's weak branch is genuinely taken.** `HasDedekindINF.first_occ_tp`
   is called once, at `s0.neg`, and **both** of its disjuncts are live proof branches of
   `negFixOneFaithful_cover`: the left one — `kplus M atomMap s0.neg.formula z0`, Rabinovich's
   Case 1 and the *Subcase `r₀ = z₀`* of PDF p.8 — produces `negFixOneCase1` and is the branch the
   attained carrier deletes outright; the right one produces the eq (5.3) pin of Cases 3a/3b/3c.
   The carrier is spent a second time inside `negFixOneTail_iff`, and there too the `K⁺` branch is
   on the invoked path (see `BoundedFixAnchoredFaithful.lean`'s non-vacuity note 2).

4. **The soundness direction needs the pin, not the carrier.** `bracketOne_witness_le_infPin` is
   the load-bearing step of `negFixOneFaithful_sound`, and it has **no** carrier hypothesis: the
   eq (5.3) point type `¬β₁(r) ∨ K⁺(¬β₁)(r)` is by itself enough to confine every bracket witness
   to `(z₀,r₀]`. This is the exact place where the possibly-unattained infimum does the work that
   the attained first `¬s0`-point does in `negFixOne_cover`.

5. **What is NOT claimed.** The `ℝ` probe below is not claimed to satisfy `HasDedekindINF` at every
   predicate — that would need a definability theorem about `ℝ` this tree does not have. What is
   proved is sharper and sufficient: at the predicate the attained cover pins, `ℝ` discharges the
   faithful carrier's eq (5.2) obligation and refutes the attained one, and the six-disjunct list
   fails there. As elsewhere in this stack, on Prior structures attainment holds outright, so no
   current consumer can distinguish the faithful carrier from the attained one.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## The faithful carrier at `TemporalPred` level

The INF-side counterpart of `HasDedekindSUP.last_occ_tp` (`Lemma53FaithfulPast.lean:171`). -/

/-- First occurrence of a temporal predicate `P` in `(z₀,z₁)` on structures satisfying the
    **faithful** `HasDedekindINF` carrier: either the infimum sits at the left endpoint (as
    `K⁺(P)(z₀)`) or it is an eq (5.2) point strictly inside `(z₀,z₁)`.

    Wraps `HasDedekindINF.first_occ` (`DedekindINF.lean:140`) to accept a `TemporalPred` directly,
    following the pattern of `HasAttainedINF.first_occ_tp` (`EANegationClosure.lean:66`) and
    `HasDedekindSUP.last_occ_tp` (`Lemma53FaithfulPast.lean:171`). Unlike the attained version the
    disjunction is preserved rather than collapsed: that is precisely the content the faithful
    carrier adds.

    Source correspondence: Rabinovich 2014, eq (5.2), PDF p.8 — read at `P := ¬β₁` this is eq
    (5.3), PDF p.10. -/
theorem HasDedekindINF.first_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasDedekindINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    kplus M atomMap P.formula z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬P.EvalAt M atomMap y) ∧
        (P.EvalAt M atomMap r0 ∨ kplus M atomMap P.formula r0)) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  rcases h_INF.first_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩ with
    hk | ⟨r0, hr0_above, hr0_below, h_none, h_disj⟩
  · exact Or.inl hk
  · exact Or.inr ⟨r0, hr0_above, hr0_below,
      fun y hy0 hy1 hPy => h_none y hy0 hy1 hPy, h_disj⟩

/-! ## eq (5.3)'s three conjuncts as `VVecEA2` pieces (PDF p.10) -/

/-- The third conjunct of eq (5.3) (PDF p.10): the point type `¬β₁(z) ∨ K⁺(¬β₁)(z)` carried at the
    pin `r₀`. This is eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))` (PDF p.8) at `P₁ := ¬β₁`, built from
    `TemporalPred.disj` (`ExistsForallNF.lean:87`) and `kplusPred` (`Lemma53Faithful.lean:81`). -/
noncomputable def infPinPoint (β : TemporalPred) : TemporalPred :=
  β.neg.disj (kplusPred β.neg)

/-- Semantics of eq (5.3)'s pin point type. -/
theorem infPinPoint_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (β : TemporalPred) (t : M.carrier) :
    (infPinPoint β).EvalAt M atomMap t ↔
      ¬β.EvalAt M atomMap t ∨ kplus M atomMap β.neg.formula t := by
  rw [infPinPoint, TemporalPred.eval_at_disj, TemporalPred.eval_at_neg', kplusPred_eval]

/-- The second conjunct of eq (5.3) (PDF p.10): `(∀y)^{<z}_{>z₀} β₁(y)`, as a `VVecEA2` block with
    trivial endpoints. Built as `trivialTrue.conjEverywhere` so the interval quantifier is the one
    `VVecEA2.conjEverywhere` already characterizes (`VecEACombinators.lean:110`). -/
noncomputable def allSeg (s : TemporalPred) : VVecEA2 :=
  VVecEA2.trivialTrue.conjEverywhere s

theorem allSeg_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (allSeg s).holds M atomMap z0 z1 ↔
      ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y := by
  rw [allSeg, VVecEA2.conjEverywhere_holds_iff]
  exact ⟨fun h => h.2, fun h => ⟨VVecEA2.trivialTrue_holds M atomMap z0 z1, h⟩⟩

/-- A `VVecEA2` block asserting that `P` holds at *some* interior point. Needed for Case 3's
    arm (a), where the paper's `β₂ = s1` fails somewhere strictly above the pin. -/
noncomputable def somePointBlock (P : TemporalPred) : VVecEA2 :=
  ⟨[⟨1, VecEA2.fromBracket
      (BracketFormula.prepend TemporalPred.top P
        (BracketFormula.trivial TemporalPred.top))⟩]⟩

theorem somePointBlock_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (somePointBlock P).holds M atomMap z0 z1 ↔
      ∃ w : M.carrier, z0 < w ∧ w < z1 ∧ P.EvalAt M atomMap w := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [somePointBlock, List.mem_singleton] at hmem
    subst hmem
    rw [VecEA2.fromBracket_holds] at hh
    obtain ⟨w, h1, h2, h3, -, -⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ hh
    exact ⟨w, h1, h2, h3⟩
  · rintro ⟨w, h1, h2, h3⟩
    refine ⟨_, List.mem_singleton.mpr rfl, ?_⟩
    rw [VecEA2.fromBracket_holds]
    exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 w h1 h2 h3
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
      ((BracketFormula.trivial_holds M atomMap _ w z1).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y))

/-! ## `Form₂`: Corollary 5.4(2) at the anchor `α₁ = p` (PDF pp.9-10)

*"In this case `¬[α₀,β₁…,β_{n-1},α_{n-1},βₙ,αₙ](z₀,z₁)` is equivalent to «there is no
`z ∈ (z₀,z₁)` such that `[α₁,β₂…,βₙ,αₙ](z,z₁)`». By Corollary 5.4(2) this is expressible by a
`∨∃⃗∀` formula."* — PDF p.10, Case 2. At one witness the inner bracket is the point type `α₁ = p`
at `z` together with the segment `β₂ = s1` on `(z,z₁)`, which is precisely the **anchored** Cor
5.4(2) at anchor `p` over the zero-witness bracket `[s1]`. -/

/-- Rabinovich's `Form₂` (PDF p.10): the `VVecEA2` equivalent of *"there is no `z ∈ (z₀,z₁)` such
    that `[α₁,β₂,α₂](z,z₁)`"*, i.e. no `p`-point above which `s1` holds throughout.

    This is `negBoundedLeftFixAnchoredFaithful` (`BoundedFixAnchoredFaithful.lean:218`) at
    `α := p` over `BracketFormula.trivial s1`; it is reused unchanged rather than re-derived. -/
noncomputable def negFixOneTail (p s1 : TemporalPred) : VVecEA2 :=
  negBoundedLeftFixAnchoredFaithful p (BracketFormula.trivial s1)

/-- `Form₂` characterized (PDF p.10), over `HasDedekindINF` alone. -/
theorem negFixOneTail_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (p s1 : TemporalPred)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOneTail p s1).holds M atomMap z0 z1 ↔
    ¬ ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.EvalAt M atomMap x ∧
      ∀ y : M.carrier, x < y → y < z1 → s1.EvalAt M atomMap y := by
  rw [negFixOneTail,
    negBoundedLeftFixAnchoredFaithful_iff M atomMap h_INF.toHasFaithfulDedekindINF p
      (BracketFormula.trivial s1) z0 z1 h_lt]
  simp only [BracketFormula.trivial_holds]

/-! ## The three cases of PDF p.9, as `VVecEA2` disjuncts -/

/-- **Case 1** (PDF p.9): `K⁺(¬β₁)(z₀)`, with `Form₁ = True` — *"In this case
    `¬[α₀,β₁…,β_{n-1},α_{n-1},βₙ,αₙ](z₀,z₁)` is equivalent to True."*

    A pure left-endpoint condition, carried by `kplusLeftBlock` (`Lemma53Faithful.lean:184`). The
    other alternative of the paper's Case 1, `¬α₀(z₀)`, is unavailable at `α₀ = ⊤`. -/
noncomputable def negFixOneCase1 (s0 : TemporalPred) : VVecEA2 :=
  kplusLeftBlock s0.neg

/-- **Case 2** (PDF p.10): `Cond₂ = β₁` along `(z₀,z₁)`, conjoined with `Form₂` = the anchored
    Cor 5.4(2). `Cond₂` rides in through `VVecEA2.conjEverywhere`. -/
noncomputable def negFixOneCase2 (s0 p s1 : TemporalPred) : VVecEA2 :=
  (negFixOneTail p s1).conjEverywhere s0

/-- **Case 3, arm (a)** (PDF p.10): the eq (5.3) pin `r₀`, with `β₂ = s1` failing somewhere
    strictly above it. Then no witness at all survives, because every witness is confined to
    `(z₀,r₀]` by `bracketOne_witness_le_infPin`. -/
noncomputable def negFixOneCase3a (s0 s1 : TemporalPred) : VVecEA2 :=
  (allSeg s0).concatPin (infPinPoint s0) (somePointBlock s1.neg)

/-- **Case 3, arm (b)** (PDF p.10): the eq (5.3) pin `r₀` carrying `¬α₁(r₀) ∧ ¬β₂(r₀)`, with `β₂`
    holding throughout `(r₀,z₁)`. The witness cannot be `r₀` itself (`¬α₁`), and cannot lie below
    `r₀` either, since `β₂` would then have to hold at `r₀`. -/
noncomputable def negFixOneCase3b (s0 p s1 : TemporalPred) : VVecEA2 :=
  (allSeg s0).concatPin ((infPinPoint s0).conj (p.neg.conj s1.neg)) VVecEA2.trivialTrue

/-- **Case 3, arm (c)** (PDF p.10): the eq (5.3) pin `r₀` carrying `¬α₁(r₀)`, with `Form₂` holding
    on the *shrunken* interval `(z₀,r₀)`. This is the arm in which the paper's Case 3 recurses:
    the pin splits the interval and the negation is asked again to the left of it. -/
noncomputable def negFixOneCase3c (s0 p s1 : TemporalPred) : VVecEA2 :=
  (negFixOneCase2 s0 p s1).concatPin ((infPinPoint s0).conj p.neg) VVecEA2.trivialTrue

/-- **Lemma 5.1 at one witness, faithful form** (Rabinovich 2014, PDF pp.9-10): the `VVecEA2`
    formula equivalent to `¬ bracketOne s0 p s1` over `HasDedekindINF`.

    Rabinovich's `∨ᵢ (Condᵢ ∧ Formᵢ)` with `i` ranging over the paper's three cases, the third
    split into the three arms its pinned form requires. Compare `negFixOne`
    (`EANegationFix/NegFixOne.lean:90`), whose six disjuncts are a different formulation altogether
    and which `NegFixOneFaithfulGateProbe` shows cannot be a cover once attainment is dropped. -/
noncomputable def negFixOneFaithful (s0 p s1 : TemporalPred) : VVecEA2 :=
  (negFixOneCase1 s0).disj
    ((negFixOneCase2 s0 p s1).disj
      ((negFixOneCase3a s0 s1).disj
        ((negFixOneCase3b s0 p s1).disj (negFixOneCase3c s0 p s1))))

/-! ## The eq (5.3) pin confines every witness — carrier-free (PDF p.10) -/

/-- **The load-bearing step, and it needs no carrier.** If the eq (5.3) point type
    `¬β₁(r) ∨ K⁺(¬β₁)(r)` holds at `r`, then every `x` whose `β₁`-prefix condition is met
    satisfies `x ≤ r`.

    This is where the possibly-unattained infimum does the work that `negFixOne_cover`'s attained
    first `¬s0`-point does at `EANegationFix/NegFixOne.lean:276`. The `K⁺` alternative is handled
    by density rather than by a witness, which is exactly why no attainment is needed.

    Note that eq (5.3)'s *second* conjunct — `(∀y)^{<z}_{>z₀} β₁(y)`, the `allSeg s0` block of the
    Case 3 arms — is **not** used here: the pin's point type alone confines the witness. That
    conjunct is carried in the disjuncts because Rabinovich prints it (it is what makes `r₀` the
    infimum, and hence unique), not because this step needs it. -/
theorem bracketOne_witness_le_infPin {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 : TemporalPred) {z0 r x : M.carrier} (hr0 : z0 < r)
    (hpin : (infPinPoint s0).EvalAt M atomMap r)
    (hpre : ∀ y : M.carrier, z0 < y → y < x → s0.EvalAt M atomMap y) : x ≤ r := by
  rcases lt_or_ge r x with hgt | hle
  · exfalso
    rcases (infPinPoint_holds M atomMap s0 r).mp hpin with hns0 | hk
    · exact hns0 (hpre r hr0 hgt)
    · obtain ⟨-, hdense⟩ := hk
      obtain ⟨q, hq1, hq2, hq3⟩ := hdense x hgt
      exact ((TemporalPred.eval_at_neg' M atomMap s0 q).mp hq3)
        (hpre q (lt_trans hr0 hq1) hq2)
  · exact hle

/-! ## Soundness: every disjunct refutes the bracket (PDF pp.9-10) -/

/-- Each of the five disjuncts implies `¬ bracketOne s0 p s1`, i.e. each of the paper's
    `Condᵢ ∧ Formᵢ` is sufficient. `HasDedekindINF` enters only through `negFixOneTail_iff`'s
    forward direction (Cases 2 and 3c); Cases 1, 3a and 3b consume no carrier at all. -/
theorem negFixOneFaithful_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFixOneFaithful s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  simp only [negFixOneFaithful, VVecEA2.disj_holds] at h
  rcases h with h1 | h2 | h3a | h3b | h3c
  · -- Case 1: `K⁺(¬β₁)(z₀)` — `¬s0` occurs inside `(z₀,x)`, breaking the witness's prefix.
    rw [negFixOneCase1, kplusLeftBlock_holds] at h1
    obtain ⟨-, hdense⟩ := h1
    obtain ⟨q, hq1, hq2, hq3⟩ := hdense x hx0
    exact ((TemporalPred.eval_at_neg' M atomMap s0 q).mp hq3) (hxs0 q hq1 hq2)
  · -- Case 2: the witness is exactly an instance forbidden by `Form₂`.
    rw [negFixOneCase2, VVecEA2.conjEverywhere_holds_iff] at h2
    exact (negFixOneTail_iff M atomMap h_INF p s1 z0 z1 (lt_trans hx0 hx1)).mp h2.1
      ⟨x, hx0, hx1, hxp, hxs1⟩
  · -- Case 3a: the witness is confined to `(z₀,r₀]`, so the `¬β₂`-point above `r₀` breaks it.
    rw [negFixOneCase3a, VVecEA2.concatPin_holds_iff] at h3a
    obtain ⟨r, hr0, hr1, hL, hpin, hR⟩ := h3a
    rw [allSeg_holds] at hL
    rw [somePointBlock_holds] at hR
    obtain ⟨w, hw0, hw1, hw2⟩ := hR
    have hxr : x ≤ r := bracketOne_witness_le_infPin M atomMap s0 hr0 hpin hxs0
    exact ((TemporalPred.eval_at_neg' M atomMap s1 w).mp hw2)
      (hxs1 w (lt_of_le_of_lt hxr hw0) hw1)
  · -- Case 3b: `x = r₀` is blocked by `¬α₁(r₀)`; `x < r₀` is blocked by `¬β₂(r₀)`.
    rw [negFixOneCase3b, VVecEA2.concatPin_holds_iff] at h3b
    obtain ⟨r, hr0, hr1, hL, hpin, -⟩ := h3b
    rw [allSeg_holds] at hL
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg'] at hpin
    obtain ⟨hpin0, hnp, hns1⟩ := hpin
    have hxr : x ≤ r := bracketOne_witness_le_infPin M atomMap s0 hr0 hpin0 hxs0
    rcases lt_or_eq_of_le hxr with hlt | heq
    · exact hns1 (hxs1 r hlt hr1)
    · exact hnp (heq ▸ hxp)
  · -- Case 3c: `x = r₀` is blocked by `¬α₁(r₀)`; `x < r₀` is an instance forbidden by `Form₂`
    -- on the shrunken interval `(z₀,r₀)`.
    rw [negFixOneCase3c, VVecEA2.concatPin_holds_iff] at h3c
    obtain ⟨r, hr0, hr1, hL, hpin, -⟩ := h3c
    rw [negFixOneCase2, VVecEA2.conjEverywhere_holds_iff] at hL
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg'] at hpin
    obtain ⟨hpin0, hnp⟩ := hpin
    have hxr : x ≤ r := bracketOne_witness_le_infPin M atomMap s0 hr0 hpin0 hxs0
    rcases lt_or_eq_of_le hxr with hlt | heq
    · exact (negFixOneTail_iff M atomMap h_INF p s1 z0 r hr0).mp hL.1
        ⟨x, hx0, hlt, hxp, fun y hy0 hy1 => hxs1 y hy0 (lt_trans hy1 hr1)⟩
    · exact hnp (heq ▸ hxp)

/-! ## The cover: Rabinovich's three cases are exhaustive (PDF pp.9-10) -/

/-- **Cover** (Rabinovich Lemma 5.1 at one witness, PDF pp.9-10): if `bracketOne s0 p s1` fails on
    a non-empty `(z₀,z₁)`, one of the paper's cases holds.

    The case split is not invented here: it is exactly the trichotomy *"`¬β₁` does not occur"* /
    *"`HasDedekindINF.first_occ`'s left disjunct"* / *"its right disjunct"*, which is why the paper
    can assert *"at least one of the following cases holds"* over Dedekind complete chains and no
    fourth case is needed.

    Compare `negFixOne_cover` (`EANegationFix/NegFixOne.lean:207`), which needs `HasAttainedINF`
    **and** `HasAttainedSUP` and pins four attained points. -/
theorem negFixOneFaithful_cover {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : ¬ (bracketOne s0 p s1).holds M atomMap z0 z1) :
    (negFixOneFaithful s0 p s1).holds M atomMap z0 z1 := by
  rw [bracketOne_holds_iff] at h_neg
  simp only [negFixOneFaithful, VVecEA2.disj_holds]
  by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ s0.neg.EvalAt M atomMap x
  case neg =>
    -- **Case 2** (PDF p.10): `β₁` holds along `(z₀,z₁)`, so the bracket reduces to its tail.
    have hs0 : ∀ y : M.carrier, z0 < y → y < z1 → s0.EvalAt M atomMap y := by
      intro y hy0 hy1
      by_contra hns0
      exact h_occ ⟨y, hy0, hy1, (TemporalPred.eval_at_neg' M atomMap s0 y).mpr hns0⟩
    refine Or.inr (Or.inl ?_)
    rw [negFixOneCase2, VVecEA2.conjEverywhere_holds_iff]
    refine ⟨(negFixOneTail_iff M atomMap h_INF p s1 z0 z1 h_lt).mpr ?_, hs0⟩
    rintro ⟨x, hx0, hx1, hxp, hxs1⟩
    exact h_neg ⟨x, hx0, hx1, hxp, fun y hy0 hy1 => hs0 y hy0 (lt_trans hy1 hx1), hxs1⟩
  case pos =>
  rcases h_INF.first_occ_tp s0.neg z0 z1 h_lt h_occ with
    hk | ⟨r0, hr0a, hr0b, hnone, hdisj⟩
  · -- **Case 1** (PDF p.9): `K⁺(¬β₁)(z₀)`, the *Subcase `r₀ = z₀`* of PDF p.8.
    refine Or.inl ?_
    rw [negFixOneCase1, kplusLeftBlock_holds]
    exact hk
  -- **Case 3** (PDF p.10): the eq (5.3) pin `r₀`.
  have hs0pre : ∀ y : M.carrier, z0 < y → y < r0 → s0.EvalAt M atomMap y := by
    intro y hy0 hy1
    by_contra hns0
    exact hnone y hy0 hy1 ((TemporalPred.eval_at_neg' M atomMap s0 y).mpr hns0)
  have hpin : (infPinPoint s0).EvalAt M atomMap r0 := by
    rw [infPinPoint_holds]
    rcases hdisj with h | h
    · exact Or.inl ((TemporalPred.eval_at_neg' M atomMap s0 r0).mp h)
    · exact Or.inr h
  by_cases hQ : ∃ y : M.carrier, r0 < y ∧ y < z1 ∧ ¬s1.EvalAt M atomMap y
  case pos =>
    -- Arm (a): `β₂` already fails above the pin.
    obtain ⟨w, hw0, hw1, hw2⟩ := hQ
    refine Or.inr (Or.inr (Or.inl ?_))
    rw [negFixOneCase3a, VVecEA2.concatPin_holds_iff]
    exact ⟨r0, hr0a, hr0b, (allSeg_holds M atomMap s0 z0 r0).mpr hs0pre, hpin,
      (somePointBlock_holds M atomMap s1.neg r0 z1).mpr
        ⟨w, hw0, hw1, (TemporalPred.eval_at_neg' M atomMap s1 w).mpr hw2⟩⟩
  case neg =>
  have hs1post : ∀ y : M.carrier, r0 < y → y < z1 → s1.EvalAt M atomMap y := by
    intro y hy0 hy1
    by_contra hn
    exact hQ ⟨y, hy0, hy1, hn⟩
  -- The pin itself cannot be a witness: it would be one of the bracket instances just refuted.
  have hnp : ¬p.EvalAt M atomMap r0 := fun hp =>
    h_neg ⟨r0, hr0a, hr0b, hp, hs0pre, hs1post⟩
  by_cases hs1r : s1.EvalAt M atomMap r0
  case neg =>
    -- Arm (b): `β₂` fails at the pin, so no witness below it survives either.
    refine Or.inr (Or.inr (Or.inr (Or.inl ?_)))
    rw [negFixOneCase3b, VVecEA2.concatPin_holds_iff]
    refine ⟨r0, hr0a, hr0b, (allSeg_holds M atomMap s0 z0 r0).mpr hs0pre, ?_,
      VVecEA2.trivialTrue_holds M atomMap r0 z1⟩
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg']
    exact ⟨hpin, hnp, hs1r⟩
  case pos =>
    -- Arm (c): `β₂` holds from the pin on, so the whole question moves to `(z₀,r₀)`.
    refine Or.inr (Or.inr (Or.inr (Or.inr ?_)))
    rw [negFixOneCase3c, VVecEA2.concatPin_holds_iff]
    refine ⟨r0, hr0a, hr0b, ?_, ?_, VVecEA2.trivialTrue_holds M atomMap r0 z1⟩
    · rw [negFixOneCase2, VVecEA2.conjEverywhere_holds_iff]
      refine ⟨(negFixOneTail_iff M atomMap h_INF p s1 z0 r0 hr0a).mpr ?_, hs0pre⟩
      rintro ⟨x, hx0, hx1, hxp, hxs1⟩
      refine h_neg ⟨x, hx0, lt_trans hx1 hr0b, hxp,
        fun y hy0 hy1 => hs0pre y hy0 (lt_trans hy1 hx1), ?_⟩
      intro y hy0 hy1
      rcases lt_trichotomy y r0 with hlt | heq | hgt
      · exact hxs1 y hy0 hlt
      · exact heq ▸ hs1r
      · exact hs1post y hgt hy1
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact ⟨hpin, hnp⟩

/-- **Lemma 5.1 at one witness, faithful `iff`** (Rabinovich 2014, PDF pp.9-10). The carrier is
    `HasDedekindINF` alone, where the attained counterpart `negFixOne_iff`
    (`EANegationFix/NegFixOne.lean:353`) needs `HasAttainedINF` **and** `HasAttainedSUP`. -/
theorem negFixOneFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOneFaithful s0 p s1).holds M atomMap z0 z1 ↔
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 :=
  ⟨negFixOneFaithful_sound M atomMap h_INF s0 p s1 z0 z1,
   negFixOneFaithful_cover M atomMap h_INF s0 p s1 z0 z1 h_lt⟩

/-- The faithful `n = 1` negation is available wherever the attained one is — and needs only the
    **INF** half of the attained pair that `negFixOne_iff` (`EANegationFix/NegFixOne.lean:353`)
    consumes. `HasAttainedSUP` is not a hypothesis here, and that is the measured delta. -/
theorem negFixOneFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOneFaithful s0 p s1).holds M atomMap z0 z1 ↔
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 :=
  negFixOneFaithful_iff M atomMap h_INF.toHasDedekindINF s0 p s1 z0 z1 h_lt

/-! # The gate probe: the six-disjunct attained list is not a cover without attainment

`negFixOne`'s disjunct list `{A, B1, B2, B3, B4, B4′}` (`EANegationFix/NegFixOne.lean:90`) is a
biconditional cover **only** because `negFixOne_cover` may pin four attained points. The `ℤ` probe
`NegFixGateProbe` (`EANegationFix/NegFixOne.lean:402`) machine-checks that the two-point gated
shapes `B4`/`B4′` are unavoidable *given* attainment. This probe checks the complementary fact,
which is what decides the shape of the faithful `n = 1` negation: once attainment is dropped, the
six-disjunct list stops being a cover altogether, so no re-proof of it under a weaker carrier is
possible and the faithful version must be Rabinovich's own case split.

Take the carrier `ℝ` — a Dedekind complete chain — the interval `(0,10)`, and

* `β₂ = s1` false exactly on `(2,3)`,
* `β₁ = s0` false exactly on `(3,4)`,
* `α₁ = p`  true  exactly on `(2,3) ∪ {7}`.

Then `[s0, p, s1]` fails on `(0,10)`: a witness in `(2,3)` has a `¬s1`-point above it (inside
`(2,3)`), and the witness `7` has a `¬s0`-point below it (inside `(3,4)`). Yet every disjunct
fails too:

* `A = [¬p]` — refuted by `p 2.5`;
* `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — every `¬s0`-point is `> 3`, and `p 2.5` breaks the `¬p` prefix;
* `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — every `¬s1`-point lies in `(2,3)`, where `p` holds, so the pinned
  point's own `¬p` conjunct already fails;
* `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — needs a `¬s0`-point strictly before a `¬s1`-point, i.e. some
  `w₀ ∈ (3,4)` below some `w₁ ∈ (2,3)`;
* `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` — fails at its first pinned point for `B2`'s reason;
* `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` — needs one point in `(3,4) ∩ (2,3)`.

The two carrier facts below make the diagnosis exact rather than suggestive: at `p` on `(0,10)`
this structure **discharges** the faithful eq (5.2) obligation (with `r₀ = 2`, through the `K⁺`
alternative that `HasDedekindINF` admits and `HasDefinableINF` forbids) and **refutes** the
attained one. The failure is therefore located precisely at attainment, not at Dedekind
completeness.

What is *not* claimed: that this structure satisfies `HasDedekindINF` at every predicate. That
would need a definability theorem about `ℝ` which this tree does not have, and it is not needed —
the obligation is discharged at the predicate the attained cover actually pins. -/

namespace NegFixOneFaithfulGateProbe

/-- Three predicate symbols: `p`, `s0`, `s1`. -/
abbrev sigR : MonadicSignature := { preds := Fin 3 }

/-- The `ℝ` structure of the counterexample: `p` exactly on `(2,3) ∪ {7}`, `¬s0` exactly on
    `(3,4)`, `¬s1` exactly on `(2,3)`. -/
noncomputable abbrev MR : OrderedMonadicStructure sigR where
  carrier := ℝ
  interp k t :=
    match k with
    | ⟨0, _⟩ => (2 < t ∧ t < 3) ∨ t = 7
    | ⟨1, _⟩ => ¬(3 < t ∧ t < 4)
    | ⟨2, _⟩ => ¬(2 < t ∧ t < 3)
  carrierOrder := inferInstance

/-- Atom map: fresh atoms with indices 0, 1, 2 name the three predicates. -/
def atomMapR : Formula → sigR.preds
  | .atom ⟨_, some 1⟩ => 1
  | .atom ⟨_, some 2⟩ => 2
  | _ => 0

/-- The point predicate `α₁ = p` (true exactly on `(2,3) ∪ {7}`). -/
def pR : TemporalPred := ⟨.atom ⟨"", some 0⟩⟩

/-- The left segment predicate `β₁ = s0` (false exactly on `(3,4)`). -/
def s0R : TemporalPred := ⟨.atom ⟨"", some 1⟩⟩

/-- The right segment predicate `β₂ = s1` (false exactly on `(2,3)`). -/
def s1R : TemporalPred := ⟨.atom ⟨"", some 2⟩⟩

theorem pR_eval (t : ℝ) : pR.EvalAt MR atomMapR t ↔ (2 < t ∧ t < 3) ∨ t = 7 := Iff.rfl

theorem s0R_eval (t : ℝ) : s0R.EvalAt MR atomMapR t ↔ ¬(3 < t ∧ t < 4) := Iff.rfl

theorem s1R_eval (t : ℝ) : s1R.EvalAt MR atomMapR t ↔ ¬(2 < t ∧ t < 3) := Iff.rfl

/-- `p` holds at `2.5`, the witness that refutes disjunct `A` and both `¬p` prefixes. -/
theorem pR_at_two_five : pR.EvalAt MR atomMapR 2.5 := by
  rw [pR_eval]; left; norm_num

/-- `¬s0` at `3.5`: the `¬β₁`-point that breaks the witness `7`. -/
theorem s0R_fails_at_three_five : ¬s0R.EvalAt MR atomMapR 3.5 := by
  rw [s0R_eval]; push Not; norm_num

/-- Every `¬s1`-point of the structure carries `p`. This is why `B2` and `B4` both die at their
    first pinned point. -/
theorem pR_of_not_s1R {t : ℝ} (h : ¬s1R.EvalAt MR atomMapR t) : pR.EvalAt MR atomMapR t := by
  rw [s1R_eval] at h
  rw [pR_eval]
  exact Or.inl (not_not.mp h)

/-- Every `¬s0`-point of the structure lies above `3`. -/
theorem three_lt_of_not_s0R {t : ℝ} (h : ¬s0R.EvalAt MR atomMapR t) : 3 < t := by
  rw [s0R_eval] at h
  exact (not_not.mp h).1

/-- Every `¬s1`-point of the structure lies below `3`. -/
theorem lt_three_of_not_s1R {t : ℝ} (h : ¬s1R.EvalAt MR atomMapR t) : t < 3 := by
  rw [s1R_eval] at h
  exact (not_not.mp h).2

/-- **The bracket `[s0, p, s1]` fails on `(0,10)`.** A witness inside `(2,3)` is broken by a
    `¬s1`-point just above it; the witness `7` is broken by the `¬s0`-point `3.5`. -/
theorem bracketOneR_not_holds : ¬(bracketOne s0R pR s1R).holds MR atomMapR 0 10 := by
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases (pR_eval x).mp hxp with ⟨h2, h3⟩ | h7
  · -- `x ∈ (2,3)`: the midpoint of `(x,3)` is a `¬s1`-point above `x`
    have hy : s1R.EvalAt MR atomMapR ((x + 3) / 2) :=
      hxs1 ((x + 3) / 2) (by linarith) (by linarith)
    rw [s1R_eval] at hy
    exact hy ⟨by linarith, by linarith⟩
  · -- `x = 7`: `3.5` is a `¬s0`-point below it
    exact s0R_fails_at_three_five (hxs0 3.5 (by norm_num) (by rw [h7]; norm_num))

/-- **The six-disjunct attained list fails on `(0,10)` too.** Together with
    `bracketOneR_not_holds` this is the statement that `negFixOne` is not a cover here. -/
theorem negFixOneR_not_holds : ¬(negFixOne s0R pR s1R).holds MR atomMapR 0 10 := by
  rintro ⟨d, hmem, hd⟩
  simp only [negFixOne, List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with rfl | rfl | rfl | rfl | rfl | rfl
  · -- `A = [¬p]`: refuted by `p 2.5`
    rw [negFix1A, BracketFormula.trivial_holds] at hd
    have h := hd 2.5 (by norm_num) (by norm_num)
    rw [TemporalPred.eval_at_neg'] at h
    exact h pR_at_two_five
  · -- `B1`: the pinned `¬s0`-point is above `3`, and `p 2.5` breaks the `¬p` prefix
    obtain ⟨w, hw0, hw1, hwpt, hwseg, -⟩ :=
      BracketFormula.prepend_holds_inv MR atomMapR _ _ _ _ _ hd
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg'] at hwpt
    have hw3 : (3 : ℝ) < w := three_lt_of_not_s0R hwpt.1
    have h := hwseg 2.5 (by norm_num) (by linarith)
    rw [TemporalPred.eval_at_neg'] at h
    exact h pR_at_two_five
  · -- `B2`: every `¬s1`-point carries `p`, contradicting the pin's own `¬p` conjunct
    rw [negFix1B2, BracketFormula.snoc_holds_iff] at hd
    obtain ⟨w, -, -, -, hwpt, -⟩ := hd
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg'] at hwpt
    exact hwpt.2 (pR_of_not_s1R hwpt.1)
  · -- `B3`: needs a `¬s0`-point strictly below a `¬s1`-point, i.e. `3 < w₀ < w₁ < 3`
    obtain ⟨w0, -, -, hw0pt, -, htail⟩ :=
      BracketFormula.prepend_holds_inv MR atomMapR _ _ _ _ _ hd
    obtain ⟨w1, hw01, -, hw1pt, -, -⟩ :=
      BracketFormula.prepend_holds_inv MR atomMapR _ _ _ _ _ htail
    rw [TemporalPred.eval_at_neg'] at hw0pt hw1pt
    have h0 : (3 : ℝ) < w0 := three_lt_of_not_s0R hw0pt
    have h1 : w1 < (3 : ℝ) := lt_three_of_not_s1R hw1pt
    exact absurd hw01 (by linarith)
  · -- `B4`: dies at its first pinned point for `B2`'s reason
    obtain ⟨w1, -, -, hw1pt, -, -⟩ :=
      BracketFormula.prepend_holds_inv MR atomMapR _ _ _ _ _ hd
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg'] at hw1pt
    exact hw1pt.2 (pR_of_not_s1R hw1pt.1)
  · -- `B4′`: needs one point in `(3,4) ∩ (2,3)`
    obtain ⟨w, -, -, hwpt, -, -⟩ :=
      BracketFormula.prepend_holds_inv MR atomMapR _ _ _ _ _ hd
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
      TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg'] at hwpt
    have h0 : (3 : ℝ) < w := three_lt_of_not_s0R hwpt.1
    have h1 : w < (3 : ℝ) := lt_three_of_not_s1R hwpt.2.1
    exact absurd h0 (by linarith)

/-- **The faithful carrier's obligation IS discharged here, at the pinned predicate.** This is
    `HasDedekindINF.first_occ` (`DedekindINF.lean:140`) read at `P := p`, `(z₀,z₁) = (0,10)`: the
    eq (5.2) point is `r₀ = 2`, reached through the `K⁺(P)(r₀)` alternative — the alternative
    `HasDefinableINF` forbids (`hasDefinableINF_excludes_kplus`, `Lemma53.lean`) and
    `HasDedekindINF` admits. -/
theorem MR_dedekind_shape_at_pR :
    kplus MR atomMapR pR.formula 0 ∨
      (∃ r0 : ℝ, 0 < r0 ∧ r0 < 10 ∧
        (∀ y : ℝ, 0 < y → y < r0 → ¬TemporalTruth MR atomMapR y pR.formula) ∧
        (TemporalTruth MR atomMapR r0 pR.formula ∨ kplus MR atomMapR pR.formula r0)) := by
  refine Or.inr ⟨2, by norm_num, by norm_num, ?_, Or.inr ⟨?_, ?_⟩⟩
  · intro y hy0 hy2 hPy
    rcases (pR_eval y).mp hPy with ⟨h2, -⟩ | h7
    · exact absurd h2 (by linarith)
    · exact absurd h7 (by linarith)
  · intro hP2
    rcases (pR_eval 2).mp hP2 with ⟨h2, -⟩ | h7
    · exact absurd h2 (by norm_num)
    · exact absurd h7 (by norm_num)
  · intro s hs
    have hpos : 0 < min (s - 2) 1 := lt_min (by linarith) (by norm_num)
    have hle : min (s - 2) 1 ≤ s - 2 := min_le_left _ _
    have hle1 : min (s - 2) 1 ≤ 1 := min_le_right _ _
    exact ⟨2 + min (s - 2) 1 / 2, by linarith, by linarith,
      (pR_eval _).mpr (Or.inl ⟨by linarith, by linarith⟩)⟩

/-- **The attained carrier's obligation is REFUTED here.** `p`'s first occurrence in `(0,10)` has
    infimum `2`, and `p` does not hold at `2`; no attained first-occurrence point exists. Hence
    the failure of `negFixOne`'s disjunct list above is located exactly at attainment. -/
theorem MR_not_hasAttainedINF : ¬HasAttainedINF MR atomMapR := by
  intro h
  obtain ⟨r0, hr00, hr01, hnone, hPr0⟩ :=
    h.first_occ pR.formula 0 10 (by norm_num)
      ⟨2.5, by norm_num, by norm_num, pR_at_two_five⟩
  rcases (pR_eval r0).mp hPr0 with ⟨h2, h3⟩ | h7
  · -- infimum `2` is approached but never attained inside `(2,3)`
    exact hnone ((2 + r0) / 2) (by linarith) (by linarith)
      ((pR_eval _).mpr (Or.inl ⟨by linarith, by linarith⟩))
  · -- `r0 = 7` is not the first occurrence: `2.5` precedes it
    exact hnone 2.5 (by norm_num) (by rw [h7]; norm_num) pR_at_two_five

/-- **The probe's headline, as one statement.** On a Dedekind complete chain that discharges the
    faithful eq (5.2) obligation at the pinned predicate and refutes the attained one, the bracket
    fails while every one of `negFixOne`'s six disjuncts fails. The attained disjunct list is
    therefore not re-provable at the faithful carrier by any argument, which is why
    `negFixOneFaithful` is Rabinovich's three-case split rather than that list. -/
theorem negFixOne_not_a_cover_without_attainment :
    ¬(bracketOne s0R pR s1R).holds MR atomMapR 0 10 ∧
    ¬(negFixOne s0R pR s1R).holds MR atomMapR 0 10 ∧
    ¬HasAttainedINF MR atomMapR :=
  ⟨bracketOneR_not_holds, negFixOneR_not_holds, MR_not_hasAttainedINF⟩

end NegFixOneFaithfulGateProbe

end FormalSystem.Metalogic.WeakCanonical.Kamp
