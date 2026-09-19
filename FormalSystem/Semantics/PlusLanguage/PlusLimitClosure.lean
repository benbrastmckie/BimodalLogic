/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.PlusLanguage.PlusPasting

/-!
# Limit closure: a valid formula of L⁺ that says the set of world histories is closed

The all-histories task semantics quantifies `⊡` over **every** world history through the state of
evaluation. That set is closed under limits of chains of partial histories: by the Extension
Theorem (`Semantics/Extension/Extension.lean`) every partial history extends to a world history,
and partial histories are closed under unions of chains. This module turns that closure property
into a valid formula of L⁺,

```
blc p  :=  (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp)),
```

which reads: if some history through the present state reaches `p`, and along every history
through the present state each later `p`-point can be continued to a further `p`-point, then some
single history through the present state reaches `p` and returns to `p` after every later
`p`-point. The antecedent supplies the recurrences one at a time, each on a possibly different
history; the consequent asks for one history carrying all of them. It contains no next-time
operator, so it is a formula of every frame class.

## The argument

The validity proof is a Zorn argument run through one general lemma.

1. **The property.** `LCProp P t w μ` says that the partial history `μ` has a down-closed domain,
   passes through `w` at `t`, has a `P`-point after `t`, and that each of its `P`-points after
   `t` either has a later `P`-point in `μ` or is the maximum of `μ`'s domain.
2. **Nonempty.** Restricting the antecedent's witness to `(-∞, s]` at its `P`-point `s`
   (`restrictIic`) has the property: `lcProp_restrictIic`.
3. **Chain-closed.** The property is preserved by `chainSup` of a nonempty chain:
   `lcProp_chainSup`. The only delicate clause is the last, where a `P`-point that was the
   maximum of one member need not be the maximum of the union; chain comparability settles it.
4. **Zorn plus extension.** `PartialHistory.exists_maximal_of_chainClosed` gives a maximal such
   partial history `μ` together with a world history `τ` extending it.
5. **Failure bounds the domain.** If `G(p → Fp)` failed on `τ` at some `f > t`, then every point
   of `μ`'s domain is `≤ f`: a domain point beyond `f` would put `f` strictly inside the domain,
   where the recurrence clause yields a later `P`-point of `μ`, hence of `τ`.
6. **One paste strictly extends.** The antecedent's second conjunct gives a history `η` through
   `τ(f)` with a `P`-point `s' > f`. The restriction to `(-∞, s']` of `paste τ η f` has the
   property and lies above `μ`, so by maximality `s'` is in `μ`'s domain, contradicting step 5.

Step 6 uses `paste` at its total-history signature (`Semantics/PlusLanguage/PlusPasting.lean`).

## Consistency check

Under the reading `⊡ = id` — which is what `⊡` collapses to over every `TaskFrame.Deterministic`
frame (`Semantics/PlusLanguage/PlusDeterminism.lean`) — the formula reduces to
`(Fp ∧ G(p → Fp)) → (Fp ∧ G(p → Fp))`, a propositional tautology, so it is a theorem of TM⁺
extended by *Determined* (`Metalogic/Deterministic/`). Any model separating the formula from the
theorems of TM⁺ is therefore necessarily nondeterministic.

## Main Definitions

- `restrictIic` — restriction of a world history to `(-∞, s]`, as a partial history
- `LCProp` — the chain-closed property the Zorn argument runs on
- `blc` — the limit-closure formula

## Main Results

- `PartialHistory.exists_maximal_of_chainClosed` — for a property of partial histories closed
  under `chainSup` of nonempty chains, every member lies below a maximal member, and that
  maximal member extends to a world history
- `limit_history` — the semantic content of the formula, for an arbitrary state predicate
- `blc_plusValid` — `blc p` is valid at `.Base`

## References

* Thomason, *Combinations of Tense and Modality* (1984), §4, formulas (19) (Burgess) and (20)
  (Thomason): the Ockhamist-valid, Kamp-invalid formulas that "trade on the fact that any
  linearly-ordered subset of a tree can be extended to a branch". `blc` is that pattern
  transposed from the historical-necessity modal to the stability modal, with the Extension
  Theorem playing the role of the branch-extension fact.
* `Semantics/Extension/Extension.lean` — `PartialHistory.extension`
* `Semantics/PlusLanguage/PlusPasting.lean` — `paste`

## Tags

plus-language · stability-modal · limit-closure · zorn
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open PartialHistory
open PlusTruth

variable {F : TaskFrame}

/--
**Maximal members of a chain-closed property of partial histories.** If `Q` is preserved by
`chainSup` of every nonempty chain, then above any `μ₀` with `Q μ₀` there is a `Q`-maximal `μ`,
and `μ` extends to a world history. Proof: `zorn_le_nonempty₀`, then `PartialHistory.extension`.

This is the partial-history lemma; the formula-set lemma with the same base name,
`FormalSystem.Metalogic.Core.exists_maximal_of_chainClosed`
(`Metalogic/Core/MaximalConsistent.lean`), is unrelated. `Q` is arbitrary: `LCProp` below is one
instance, and the instance at an `ω`-indexed recurrence schema is not stated here.
-/
theorem PartialHistory.exists_maximal_of_chainClosed (Q : PartialHistory F → Prop)
    (hQ : ∀ (c : Set (PartialHistory F)) (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty),
      (∀ μ ∈ c, Q μ) → Q (chainSup c hc hne))
    {μ₀ : PartialHistory F} (h₀ : Q μ₀) :
    ∃ μ, μ₀ ≤ μ ∧ Q μ ∧ (∀ ν, Q ν → μ ≤ ν → ν ≤ μ) ∧
      ∃ τ : WorldHistory F, Extends τ.val μ := by
  obtain ⟨m, hle, hmax⟩ := zorn_le_nonempty₀ {μ | Q μ}
    (fun c hcs hc y hy => ⟨chainSup c hc ⟨y, hy⟩, hQ c hc ⟨y, hy⟩ hcs,
      fun z hz => le_chainSup hc ⟨y, hy⟩ hz⟩) μ₀ h₀
  obtain ⟨τ, hτ⟩ := extension F m
  exact ⟨m, hle, hmax.1, fun ν hν h => hmax.2 hν h, τ, hτ⟩

/-- Restriction of a world history to `(-∞, s]`, as a partial history. -/
def restrictIic (τ : WorldHistory F) (s : F.Duration) : PartialHistory F where
  domain x := x ≤ s
  nonempty_domain := ⟨s, le_rfl⟩
  states x _ := τ.state x
  respects_task a b _ _ := τ.respects_task a b

/--
The chain-closed property behind `limit_history`: a partial history through `w` at `t` with a
`P`-point after `t`, in which every `P`-point after `t` recurs unless it is the last point of the
domain. `P`-points are stated in the dependent form `∃ hx : μ.domain x, P (μ.states x hx)`.
-/
structure LCProp (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (μ : PartialHistory F) : Prop where
  /-- The domain is a down-set. -/
  down : ∀ x y, μ.domain x → y ≤ x → μ.domain y
  /-- The partial history passes through `w` at `t`. -/
  anchor : ∃ ht : μ.domain t, μ.states t ht = w
  /-- There is a `P`-point strictly after `t`. -/
  some_p : ∃ s, t < s ∧ ∃ hs : μ.domain s, P (μ.states s hs)
  /-- Every `P`-point after `t` has a later `P`-point, or is the maximum of the domain. -/
  recur : ∀ x, t < x → ∀ hx : μ.domain x, P (μ.states x hx) →
      (∃ y, x < y ∧ ∃ hy : μ.domain y, P (μ.states y hy)) ∨ (∀ y, μ.domain y → y ≤ x)

/-- **Nonempty.** A world history through `w` at `t` with a `P`-point `s > t`, restricted to
`(-∞, s]`, has the property: its only `P`-point without a successor is its maximum `s`. -/
theorem lcProp_restrictIic (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (τ : WorldHistory F) (hw : τ.state t = w) (s : F.Duration) (hts : t < s)
    (hp : P (τ.state s)) : LCProp P t w (restrictIic τ s) where
  down := fun x y hx hy => le_trans hy hx
  anchor := ⟨le_of_lt hts, hw⟩
  some_p := ⟨s, hts, le_rfl, hp⟩
  recur := by
    intro x _ hx _
    rcases lt_or_eq_of_le (show x ≤ s from hx) with h | h
    · exact Or.inl ⟨s, h, le_rfl, hp⟩
    · exact Or.inr fun y hy => h ▸ (show y ≤ s from hy)

/-- **Chain-closed.** The property is preserved by `chainSup` of a nonempty chain. In the
recurrence clause, a `P`-point that is the maximum of one member but not of the union lies
strictly inside a larger member of the chain, whose own recurrence clause supplies the
successor. -/
theorem lcProp_chainSup (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (c : Set (PartialHistory F)) (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty)
    (hall : ∀ μ ∈ c, LCProp P t w μ) : LCProp P t w (chainSup c hc hne) := by
  have agree : ∀ {ν} (hν : ν ∈ c) (x) (hx : ν.domain x),
      (chainSup c hc hne).states x ⟨ν, hν, hx⟩ = ν.states x hx :=
    fun hν x hx => (le_def.mp (le_chainSup hc hne hν)).agree x hx
  refine ⟨?_, ?_, ?_, ?_⟩
  · rintro x y ⟨ν, hν, hx⟩ hy
    exact ⟨ν, hν, (hall ν hν).down x y hx hy⟩
  · obtain ⟨ν, hν⟩ := hne
    obtain ⟨ht, e⟩ := (hall ν hν).anchor
    exact ⟨⟨ν, hν, ht⟩, (agree hν t ht).trans e⟩
  · obtain ⟨ν, hν⟩ := hne
    obtain ⟨s, hts, hs, hp⟩ := (hall ν hν).some_p
    exact ⟨s, hts, ⟨ν, hν, hs⟩, by rw [agree hν s hs]; exact hp⟩
  · rintro x htx ⟨ν, hν, hxν⟩ hp
    rw [agree hν x hxν] at hp
    rcases (hall ν hν).recur x htx hxν hp with ⟨y, hxy, hy, hpy⟩ | hmax
    · exact Or.inl ⟨y, hxy, ⟨ν, hν, hy⟩, by rw [agree hν y hy]; exact hpy⟩
    · by_cases hU : ∀ y, (chainSup c hc hne).domain y → y ≤ x
      · exact Or.inr hU
      · push Not at hU
        obtain ⟨y, ⟨ν', hν', hy'⟩, hxy⟩ := hU
        rcases hc.total hν hν' with h | h
        · have hx' : ν'.domain x := (le_def.mp h).subset x hxν
          have hp' : P (ν'.states x hx') := by rw [(le_def.mp h).agree x hxν]; exact hp
          rcases (hall ν' hν').recur x htx hx' hp' with ⟨z, hxz, hz, hpz⟩ | hmax'
          · exact Or.inl ⟨z, hxz, ⟨ν', hν', hz⟩, by rw [agree hν' z hz]; exact hpz⟩
          · exact absurd (hmax' y hy') (not_le.mpr hxy)
        · exact absurd (hmax y ((le_def.mp h).subset y hy')) (not_le.mpr hxy)

/--
**The limit-closure lemma**, at every temporal order and with no next-time step. If some world
history through `w` at `t` reaches a `P`-point, and every `P`-point after `t` of every world
history through `w` at `t` can be continued — on a possibly different history through the same
state — to a later `P`-point, then a single world history through `w` at `t` reaches a `P`-point
and returns to `P` after each of its `P`-points.
-/
theorem limit_history (P : F.WorldState → Prop) (t : F.Duration) (w : F.WorldState)
    (h1 : ∃ τ₀ : WorldHistory F, τ₀.state t = w ∧ ∃ s, t < s ∧ P (τ₀.state s))
    (h2 : ∀ ρ : WorldHistory F, ρ.state t = w → ∀ s, t < s → P (ρ.state s) →
        ∃ η : WorldHistory F, η.state s = ρ.state s ∧ ∃ s', s < s' ∧ P (η.state s')) :
    ∃ τ : WorldHistory F, τ.state t = w ∧ (∃ s, t < s ∧ P (τ.state s)) ∧
      ∀ s, t < s → P (τ.state s) → ∃ s', s < s' ∧ P (τ.state s') := by
  obtain ⟨τ₀, hw₀, s₀, hs₀, hp₀⟩ := h1
  obtain ⟨μ, _, hQ, hmax, τ, hτ⟩ := exists_maximal_of_chainClosed (LCProp P t w)
    (lcProp_chainSup P t w) (lcProp_restrictIic P t w τ₀ hw₀ s₀ hs₀ hp₀)
  have agree : ∀ x (hx : μ.domain x), τ.state x = μ.states x hx := fun x hx => hτ.agree x hx
  obtain ⟨ht, hw⟩ := hQ.anchor
  have hτw : τ.state t = w := (agree t ht).trans hw
  refine ⟨τ, hτw, ?_, ?_⟩
  · obtain ⟨s, hts, hs, hp⟩ := hQ.some_p
    exact ⟨s, hts, by rw [agree s hs]; exact hp⟩
  · intro f htf hpf
    by_contra hno
    push Not at hno
    have hdom : ∀ y, μ.domain y → y ≤ f := by
      intro y hy
      by_contra hfy
      have hfy := not_le.mp hfy
      have hf : μ.domain f := hQ.down y f hy hfy.le
      rcases hQ.recur f htf hf (by rw [← agree f hf]; exact hpf) with ⟨z, hfz, hz, hpz⟩ | hm
      · exact hno z hfz (by rw [agree z hz]; exact hpz)
      · exact absurd (hm y hy) (not_le.mpr hfy)
    obtain ⟨η, hη, s', hfs', hps'⟩ := h2 τ hτw f htf hpf
    have hsame : τ.state f = η.state f := hη.symm
    have hπ' : (paste τ η f hsame).state s' = η.state s' :=
      paste_agreeFrom τ η f hsame s' hfs'.le
    have hν : LCProp P t w (restrictIic (paste τ η f hsame) s') :=
      lcProp_restrictIic P t w _ ((paste_agreeUpTo τ η f hsame t htf.le).trans hτw) s'
        (htf.trans hfs') (by rw [hπ']; exact hps')
    have hle : μ ≤ restrictIic (paste τ η f hsame) s' :=
      le_def.mpr ⟨fun y hy => le_trans (hdom y hy) hfs'.le, fun y hy =>
        (paste_agreeUpTo τ η f hsame y (hdom y hy)).trans (agree y hy)⟩
    have := (le_def.mp (hmax _ hν hle)).subset s' (le_refl s')
    exact absurd (hdom s' this) (not_le.mpr hfs')

/--
**The limit-closure formula** `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`: the Burgess/Thomason
branch-extension pattern transposed to the stability modal.
-/
def blc (p : Atom) : PlusFormula :=
  ((dstab (someFuture (.atom p))).and
      (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))).imp
    (dstab ((someFuture (.atom p)).and
      (allFuture ((PlusFormula.atom p).imp (someFuture (.atom p))))))

/--
**`blc p` is valid at `.Base`**: on every task frame, the set of world histories through a state
is closed under the limit the formula describes. `limit_history` at the predicate "`p` holds".

Paper: — (formalization-native)
-/
theorem blc_plusValid (p : Atom) : PlusValid (blc p) := by
  refine PlusValid.of_forall fun F M σ t => ?_
  intro h
  rw [and_iff] at h
  obtain ⟨hA, hB⟩ := h
  rw [dstab_iff] at hA
  obtain ⟨τ₀, he₀, hF₀⟩ := hA
  rw [someFuture_iff] at hF₀
  obtain ⟨s₀, hs₀, hp₀⟩ := hF₀
  obtain ⟨τ, hτ, ⟨s, hs, hp⟩, hrec⟩ := limit_history (fun u => M.valuation u p) t (σ.state t)
    ⟨τ₀, he₀.symm, s₀, hs₀, hp₀⟩
    (fun ρ hρ s hs hps => by
      have := hB ρ hρ.symm
      rw [allFuture_iff] at this
      have := this s hs hps
      rw [dstab_iff] at this
      obtain ⟨η, heη, hFη⟩ := this
      rw [someFuture_iff] at hFη
      obtain ⟨s', hs', hp'⟩ := hFη
      exact ⟨η, heη.symm, s', hs', hp'⟩)
  rw [dstab_iff]
  refine ⟨τ, hτ.symm, ?_⟩
  rw [and_iff]
  refine ⟨(someFuture_iff M τ t _).mpr ⟨s, hs, hp⟩, ?_⟩
  rw [allFuture_iff]
  intro x hx hpx
  obtain ⟨s', hs', hp'⟩ := hrec x hx hpx
  exact (someFuture_iff M τ x _).mpr ⟨s', hs', hp'⟩

end FormalSystem.Semantics
