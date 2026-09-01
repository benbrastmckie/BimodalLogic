/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Constraint

/-!
# `lem:fibers` and `lem:admissible`: from constraint membership to a one-point extension

This module lands the two lemmas that turn "belongs to every constraint" into "extends the
partial history by one point", mirroring the paper's decomposition exactly:

- `lem:fibers` rewrites membership in *every* member of `def:constraints` as the plain fiber
  condition `τ(t) ⇒_{z-t} u` at *every* domain time — no sign proviso, no case split surviving
  into the statement.
- `lem:admissible` then characterizes when the one-point extension `τ ∪ {⟨z, u⟩}` is itself a
  partial history on `X ∪ {z}`, and `PartialHistory.adjoin` builds that extension.

## Paper Specification Reference

Anchors are `\label` keys into `specs/paper-definitions-of-record.md`, which — not the paper
source — is the citation source of record.

- `lem:fibers` (verbatim, as last resolved before the paper retired the anchor): "For any
  partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration
  $z \in D \setminus X$, a world state $u \in W$ belongs to every member of the constraints
  imposed on $z$ just in case $\tau(t) \Rightarrow_{z-t} u$ for every $t \in X$."
- `lem:admissible` (verbatim): "For any partial history $\tau : X \to W$ over a task frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function
  $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs
  to every member of the constraints imposed on $z$."
- `lem:nullity` (verbatim): "$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame
  $\F = \tuple{W, \D, \Rightarrow}$."
- `def:constraints` (verbatim): "For a partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the \textit{constraints
  imposed on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where
  $t < z < s$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise."
- `def:world-history` (verbatim, the clause `adjoin` discharges): "A \textit{partial history} over
  a task frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set
  $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$."

**`lem:fibers` is a RETIRED paper anchor.** The paper removed `\label{lem:fibers}` in a
2026-08-17 editing wave; the lemma's content was absorbed into the proof of `lem:admissible`
rather than restated. Every `lem:fibers` citation in this tree resolves against
`specs/paper-definitions-of-record.md`'s **DANGLING** entry — which retains the lemma's last
resolved text — and not against any live `\label` in the paper. The name is kept because the
statement is still exactly what `PartialHistory.fibers` proves and because no live anchor covers
the same content; a reader going to the paper for it will not find it there.


The recorded proof recipe for `lem:admissible` is: "Proof consumes `lem:nullity` (the zero loop at
`z` itself) plus `lem:fibers`." Both halves appear literally below — `fibers` for the domain-time
pairs, `TaskFrame.nullity_of_serial_limit` for the single `⟨z, z⟩` pair.

## Why `lem:fibers` carries no sign proviso, and why `respects_task` is unconditional

`lem:fibers`' conclusion quantifies over *every* `t ∈ X`, with `τ(t) ⇒_{z-t} u` read through the
paper's converse convention when `z - t` is negative. That is exactly why
`PartialHistory.respects_task` is stated unconditionally rather than under an `s ≤ t` guard
(`PartialHistory`'s module docstring, decision 2, recorded in
`specs/decisions/total-history-validity-decisions.md` as Decision B): the unconditional field is
the shape this lemma and `lem:admissible` consume, and `adjoin` discharges it directly, with no
`ofLe` detour and no guarded restatement.

## The `z ∉ dom τ` proviso: needed here, unlike in `lem:constraint`

`lem:constraint` (previous module) was deliberately proved *without* the paper's `z ∈ D \ X`
proviso, because it holds a fortiori when `z` is a domain time. That is **not** the situation
here:

- `fibers` still needs no proviso — its proof never touches `z`'s own domain status.
- `admissible` genuinely needs `hz : ¬ τ.domain z`, and the need is in the left-to-right
  direction. When `z ∈ X` the function `τ ∪ {⟨z, u⟩}` is not a function extending `τ` at all
  (the paper's `z ∈ D \ X` is what makes the union well defined), and `adjoinFun` correspondingly
  keeps `τ`'s own value at `z` and discards `u`; the task-respect condition then holds for *every*
  `u`, while constraint membership of course does not. So the proviso is load bearing exactly
  where the paper puts it.

## Main Definitions

- `PartialHistory.adjoinDomain` — the extended domain `X ∪ {z}`
- `PartialHistory.adjoinFun` — the extended state function `τ ∪ {⟨z, u⟩}`
- `PartialHistory.AdjoinRespects` — "`τ ∪ {⟨z, u⟩}` is a partial history on `X ∪ {z}`", i.e. the
  task-respect condition of `def:world-history` for the extended function
- `PartialHistory.adjoin` — the one-point extension as a `PartialHistory`

## Main Results

- `PartialHistory.fibers` — `lem:fibers`
- `PartialHistory.admissible` — `lem:admissible`
- `PartialHistory.adjoin_extends` — the one-point extension extends `τ`

## Implementation Notes

- **`nullity_identity` is not consumed, and its open design question is not decided here.** The
  existing `ParamTaskFrame.nullity_identity` field is an *iff* (`TaskRel w 0 u ↔ w = u`), strictly
  stronger than the paper's derived `lem:nullity`, which asserts reflexivity only. `admissible`
  consumes only the reflexivity half, and takes it from `TaskFrame.nullity_of_serial_limit`
  (*Seriality* + *Limit*, choice-free) rather than from the field. Whether the field should be
  demoted to the reflexivity half, kept as an iff, or have its injectivity-at-zero content dropped
  is a joint question with the four-axiom frame-alignment work recorded in
  `specs/decisions/total-history-validity-decisions.md`; nothing here forecloses any of those
  options, because nothing here depends on the field.
- ***Spherical* is not consumed here either.** It is applied only at `lem:step`, the sole
  application site the paper names. This module supplies that application its *other* input —
  the certificate that a state common to all the constraints yields a genuine extension.
- **`adjoinFun` is `noncomputable`.** Deciding `τ.domain t` to choose between `τ(t)` and `u`
  is a classical case distinction on an arbitrary predicate. This is a property of the
  *construction*, not of `lem:nullity`, which stays choice-free as `nullity_of_serial_limit`
  proves it.
- **Fibers and segments stay two separate classes** throughout, as in the previous module; the
  case analysis is driven by `Constraints`' own two clauses.
-/

namespace FormalSystem.Semantics

namespace PartialHistory

open ParamTaskFrame TaskFrame

variable {F : TaskFrame}

/-!
### `lem:fibers`
-/

/--
`lem:fibers`: a world state belongs to every constraint imposed on `z` exactly when it satisfies
the fiber condition at every domain time.

Recorded source (`lem:fibers`, verbatim, as last resolved before the paper retired the anchor):
"For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and
duration $z \in D \setminus X$, a world state $u \in W$ belongs to every member of the
constraints imposed on $z$ just in case $\tau(t) \Rightarrow_{z-t} u$ for every $t \in X$."

The anchor is DANGLING; see this module's header for the retirement note.

**The statement carries no sign proviso**: `z - t` may be negative, in which case
`τ(t) ⇒_{z-t} u` is read through the paper's converse convention, exactly as
`def:world-history`'s own `%` comment prescribes. This is why `PartialHistory.respects_task` is
stated unconditionally — the unconditional form is what this lemma and `lem:admissible` consume.

The `z ∈ D \ X` proviso is not needed and not assumed: when `z` is itself a domain time it is
unpaired, so `Fib(τ(z), 0)` is simply one more fiber constraint and the argument is unchanged.

The right-to-left direction is immediate from `seg_eq_inter_fib` (a constraint segment *is* the
intersection of its two endpoint fiber conditions). The left-to-right direction is where the
`def:constraints` "otherwise" reading does its work: an unpaired time contributes its own fiber
directly, and a paired time is an endpoint of a straddling segment whose corresponding half is
that same fiber condition.
-/
theorem fibers (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState) :
    (∀ c ∈ Constraints τ z, u ∈ c)
      ↔ ∀ (t : F.Duration) (ht : τ.domain t), F.TaskRel (τ.states t ht) (z - t) u := by
  constructor
  · intro h t ht
    by_cases hp : IsPaired τ z t
    · rcases hp with ⟨htz, s, hs, hzs⟩ | ⟨hzt, s, hs, hsz⟩
      · -- `t < z < s`: the straddling segment's *left* fiber condition is the one wanted
        have hmem := h _ (mem_Constraints.mpr (Or.inl ⟨t, s, ht, hs, htz, hzs, rfl⟩))
        rw [seg_eq_inter_fib] at hmem
        exact TaskFrame.mem_Fib.mp hmem.1
      · -- `s < z < t`: the straddling segment's *right* fiber condition is the one wanted
        have hmem := h _ (mem_Constraints.mpr (Or.inl ⟨s, t, hs, ht, hsz, hzt, rfl⟩))
        rw [seg_eq_inter_fib] at hmem
        exact TaskFrame.mem_Fib.mp hmem.2
    · -- unpaired: `def:constraints`' "otherwise" clause contributes the fiber itself
      exact TaskFrame.mem_Fib.mp (h _ (mem_Constraints.mpr (Or.inr ⟨t, ht, hp, rfl⟩)))
  · intro h c hc
    rcases hc with ⟨t, s, ht, hs, _, _, rfl⟩ | ⟨t, ht, _, rfl⟩
    · rw [seg_eq_inter_fib]
      exact ⟨TaskFrame.mem_Fib.mpr (h t ht), TaskFrame.mem_Fib.mpr (h s hs)⟩
    · exact TaskFrame.mem_Fib.mpr (h t ht)

/-!
### The one-point extension `τ ∪ {⟨z, u⟩}`
-/

/-- The domain of the one-point extension: the paper's `X ∪ {z}`. -/
def adjoinDomain (τ : PartialHistory F) (z : F.Duration) : F.Duration → Prop := fun t => τ.domain t ∨ t = z

open Classical in
/--
The state function of the one-point extension, the paper's `τ ∪ {⟨z, u⟩}`, as a **total**
function on `D`.

Totality is a convenience, not a widening of the paper's `τ ∪ {⟨z, u⟩}`: `adjoin` below restricts
it to `adjoinDomain τ z`, and no result reads its value off that domain. Taking it proof-free
(rather than as a dependent function of a domain proof) is what keeps the two rewriting lemmas
below free of proof-argument metavariables.

Classical case distinction on `τ.domain t` is what makes this `noncomputable`; the union is a
function precisely because of the paper's `z ∈ D \ X` proviso, which the results below carry as
the explicit hypothesis `hz` wherever it is needed.
-/
noncomputable def adjoinFun (τ : PartialHistory F) (u : F.WorldState) (t : F.Duration) : F.WorldState :=
  if ht : τ.domain t then τ.states t ht else u

/-- On the old domain, the one-point extension is `τ` itself. -/
theorem adjoinFun_of_domain (τ : PartialHistory F) (u : F.WorldState) {t : F.Duration}
    (ht : τ.domain t) : adjoinFun τ u t = τ.states t ht :=
  dif_pos ht

/-- Off the old domain — i.e. at `z` itself, under the paper's `z ∈ D \ X` proviso — the
one-point extension takes the new value `u`. -/
theorem adjoinFun_of_not_domain (τ : PartialHistory F) (u : F.WorldState) {t : F.Duration}
    (ht : ¬ τ.domain t) : adjoinFun τ u t = u :=
  dif_neg ht

/--
"`τ ∪ {⟨z, u⟩}` is a partial history on `X ∪ {z}`", spelled out as the task-respect condition of
`def:world-history` for the extended function.

Only task-respect is asserted: the other requirement of `def:world-history`, nonemptiness of the
domain, is automatic here (`X` is already nonempty, and `z` is in the extended domain regardless),
so the condition below is the entire content of the phrase `lem:admissible` uses.

Note the condition is stated **unconditionally** over pairs, matching `PartialHistory.respects_task`;
`adjoin` discharges that field with a proof of this predicate verbatim, with no `ofLe` detour.
-/
def AdjoinRespects (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState) : Prop :=
  ∀ (s t : F.Duration), adjoinDomain τ z s → adjoinDomain τ z t →
    F.TaskRel (adjoinFun τ u s) (t - s) (adjoinFun τ u t)

/--
The concrete one-point extension of `τ` by `⟨z, u⟩`, as a `PartialHistory`.

Both structure fields beyond the data are discharged here: `nonempty_domain` from `τ`'s own
nonemptiness field (the old domain is a subset of the new one), and the **unconditional**
`respects_task` from the `AdjoinRespects` hypothesis directly.

`lem:admissible` (`admissible` below) is what supplies that hypothesis from constraint
membership, which is in turn what `lem:step` will obtain from *Spherical*.
-/
noncomputable def adjoin (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState)
    (h : AdjoinRespects τ z u) : PartialHistory F where
  domain := adjoinDomain τ z
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    exact ⟨t, Or.inl ht⟩
  states := fun t _ => adjoinFun τ u t
  respects_task := fun s t hs ht => h s t hs ht

/-- The one-point extension extends `τ`, in the paper's sense (`def:world-history`'s `extends`). -/
theorem adjoin_extends (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState)
    (h : AdjoinRespects τ z u) : Extends (adjoin τ z u h) τ where
  subset := fun _ ht => Or.inl ht
  agree := fun _ ht => adjoinFun_of_domain τ u ht

/-- The new time is in the extended domain — the point of the construction. -/
theorem adjoin_domain_self (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState)
    (h : AdjoinRespects τ z u) : (adjoin τ z u h).domain z := Or.inr rfl

/-- At the new time, the extension takes the new value, under the paper's `z ∈ D \ X` proviso. -/
theorem adjoin_states_self (τ : PartialHistory F) (z : F.Duration) (u : F.WorldState)
    (h : AdjoinRespects τ z u) (hz : ¬ τ.domain z) :
    (adjoin τ z u h).states z (adjoin_domain_self τ z u h) = u :=
  adjoinFun_of_not_domain τ u hz

/-!
### `lem:admissible`
-/

/--
`lem:admissible`: the one-point extension is a partial history exactly when the new state belongs
to every constraint.

Recorded source (`lem:admissible`, verbatim): "For any partial history $\tau : X \to W$ over a
frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function
$\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs to
every member of the constraints imposed on $z$."

**Proof recipe, exactly as recorded**: `lem:nullity` (the zero loop at `z` itself) plus
`lem:fibers`. The four pair-cases of the task-respect condition split accordingly —

- both times in `X`: `τ`'s own `respects_task`, no axiom needed;
- old time then `z`: the fiber condition at that time, i.e. `fibers`;
- `z` then old time: the same fiber condition through the converse convention (`ParamTaskFrame.converse`
  plus `neg_sub`), which is precisely the negative-difference instance `def:world-history`'s `%`
  comment covers;
- `z` twice: `u ⇒₀ u`, which is `lem:nullity` — taken here from
  `TaskFrame.nullity_of_serial_limit` (*Seriality* at `x = 0` plus *Limit*, choice-free), **not**
  from the strictly stronger `ParamTaskFrame.nullity_identity` field, whose design question stays open.

The hypothesis `hz : ¬ τ.domain z` is the paper's `z ∈ D \ X` and is genuinely load bearing in the
left-to-right direction; see this module's docstring for why, and contrast `lem:constraint`, which
holds without it.

*Spherical* is not consumed.
-/
theorem admissible (τ : PartialHistory F) {z : F.Duration} (hz : ¬ τ.domain z) (u : F.WorldState) :
    AdjoinRespects τ z u ↔ ∀ c ∈ Constraints τ z, u ∈ c := by
  rw [fibers]
  constructor
  · intro h t ht
    have hst := h t z (Or.inl ht) (Or.inr rfl)
    rwa [adjoinFun_of_domain τ u ht, adjoinFun_of_not_domain τ u hz] at hst
  · intro h s t hs ht
    by_cases hsd : τ.domain s <;> by_cases htd : τ.domain t
    · -- both times old: `τ`'s own unconditional task-respect
      rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_domain τ u htd]
      exact τ.respects_task s t hsd htd
    · -- old time then the new one: the fiber condition at `s`
      obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_not_domain τ u htd]
      exact h s hsd
    · -- the new time then an old one: the same fiber condition, via the converse convention
      obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      rw [adjoinFun_of_not_domain τ u hsd, adjoinFun_of_domain τ u htd]
      have hconv := (F.converse (τ.states t htd) (z - t) u).mp (h t htd)
      rwa [neg_sub] at hconv
    · -- the new time twice: `lem:nullity`, the zero loop at `z` itself
      obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_not_domain τ u hsd, sub_self]
      exact TaskFrame.nullity_of_serial_limit F.serial F.limit u

end PartialHistory

end FormalSystem.Semantics
