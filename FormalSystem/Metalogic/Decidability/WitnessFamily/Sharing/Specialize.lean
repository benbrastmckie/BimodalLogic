/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement
import FormalSystem.Semantics.TruthTransport

/-!
# The Deterministic Device as the Diagonal Instance

The branching device is an **addition**, not a replacement: the deterministic witness family is
the state-sharing family whose sharing relation is equality. This module exhibits that instance
and proves each branching condition equivalent to — not merely implied by — its deterministic
counterpart, so `Sharing/` is a genuine generalisation rather than a parallel development.

## `share u i j ↔ i = j`, by three singleton segments of `id`

`SharingWitnessFamily` encodes its sharing datum as three periodic segments of **representative
maps**, with the out-of-range default the identity (`Sharing/Basic.lean`). Setting all three
segments to `id` — `[id]`, `[]`, `[id]`, the two cycles non-empty as the structure requires —
makes the decoded map the identity at *every* time, in range or out, and `share` therefore
literal equality of indices. `rep_idem` is discharged because `id` is idempotent.

## Why each reduction is an `iff`, not an implication

`Sharing/Predicates.lean` already proves the two implications (C1') → (C1) and (C2') → (C2)
**unconditionally**, for an arbitrary sharing family, by instantiating the shared-successor and
thread quantifiers at the reflexive witness. Those are the directions that make the branching
conditions strengthenings. Here the converses hold too, and only here: under `share u i j ↔ i = j`

* the shared-successor quantifier of (C1')'s `untl` clause ranges over the single index `i`, so
  the branching clause *is* the deterministic clause;
* every thread is **constant** — its step field reads `θ.idx u = θ.idx (u + 1)` — so the thread
  quantifier of (C2') ranges over the constant threads alone, which is the per-lasso quantifier
  of (C2).

`thread_toSharing_idx` is the whole content of the second bullet and is proved by an integer
induction on the step field.

## (C0) is free here, and that is the explanation of a deliberate omission

`WitnessFamily/Predicates.lean` records that atoms are "deliberately unconstrained", which is
what makes the deterministic agreement theorem's `atom` case `Iff.rfl`. `atomCoherent_toSharing`
is why that was sound: at the diagonal instance (C0) says "if `i = j` then the labels at `i` and
`j` agree on atoms", which is true with nothing to check. The condition only acquires content
once two *distinct* indices may name one state.

## What the diagonal instance says about the stability modal

`FormalSystem.PlusLanguage.states_eq_of_deterministic` shows that on a frame whose task relation
is functional, any two histories through a common state agree at every time;
`FormalSystem.PlusLanguage.stab_iff_of_deterministic` turns that into `⊡φ ↔ φ` at every point.
`W.toSharing`'s task relation is functional — `share` is equality, so a state has exactly one
successor — and the collapse therefore holds at the diagonal instance. That is the semantic
statement of why the deterministic device is blind to `⊡` by construction, and why the branching
instance, whose relation is not functional, is what a stability clause would need. The clause
itself is out of scope here; see `Sharing/Agreement.lean`'s header.

## Main Definitions

- `WitnessFamily.toSharing` — the diagonal state-sharing family over a witness family

## Main Results

- `WitnessFamily.share_toSharing` — the sharing relation is equality
- `WitnessFamily.atomCoherent_toSharing` — (C0) holds unconditionally at the diagonal
- `WitnessFamily.localCoherentShare_toSharing` — (C1') ↔ (C1)
- `WitnessFamily.threadFulfilling_toSharing` — (C2') ↔ (C2)
- `WitnessFamily.certifies_toSharing` — the deterministic bundle yields the branching bundle
- `WitnessFamily.stateEquiv` / `histEquiv` / `truthIso` — the frame isomorphism and its transport
- `WitnessFamily.truth_iff_mem_toSharing` — branching agreement, read in the deterministic model
- `WitnessFamily.refutes_of_certifies_toSharing` — the two producers inhabit one statement
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace WitnessFamily

variable {Γ Del : Context}

/--
**The diagonal state-sharing family.**

Three segments of representative maps, all `id`, so the decoded map is the identity everywhere
and `share u i j` is `i = j`. The parent's five exported fields are `W`'s own, unchanged, so the
JSON export contract is untouched by this construction.
-/
def toSharing (W : WitnessFamily Γ Del) : SharingWitnessFamily Γ Del where
  toWitnessFamily := W
  repBack := [id]
  repMid := []
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    have hid : f = id := by
      simp only [List.append_assoc, List.nil_append] at hf
      rcases List.mem_append.mp hf with h | h <;> simpa using h
    subst hid
    rfl
  transBack := transFullOf _ [id]
  transMid := transFullOf _ []
  transFwd := transFullOf _ [id]
  transBack_len := transFullOf_length _ _
  transMid_len := transFullOf_length _ _
  transFwd_len := transFullOf_length _ _
  trans_refl := transFullOf_refl _ _ _ _
  lift := liftable_of_transFullOf _ _ _ _ (by simp) (by simp)

@[simp]
theorem toSharing_toWitnessFamily (W : WitnessFamily Γ Del) :
    W.toSharing.toWitnessFamily = W := rfl

/-- **The decoded representative map is the identity at every time**, in range and out. -/
theorem rep_toSharing (W : WitnessFamily Γ Del) (u : ℤ) : W.toSharing.rep u = id := by
  have hlists : W.toSharing.repBack ++ W.toSharing.repMid ++ W.toSharing.repFwd
      = [id, id] := rfl
  rcases W.toSharing.rep_mem_or_id u with h | h
  · rw [hlists] at h
    rcases List.mem_cons.mp h with h' | h'
    · exact h'
    · rcases List.mem_cons.mp h' with h'' | h''
      · exact h''
      · cases h''
  · exact h

/-- **The sharing relation at the diagonal instance is equality.** -/
@[simp]
theorem share_toSharing (W : WitnessFamily Γ Del) (u : ℤ)
    (i j : Fin W.toSharing.lassos.length) : W.toSharing.share u i j ↔ i = j := by
  change W.toSharing.rep u i = W.toSharing.rep u j ↔ i = j
  rw [rep_toSharing]
  exact Iff.rfl

/--
**(C0) holds unconditionally at the diagonal instance.**

This is the explanation of `WitnessFamily/Predicates.lean`'s deliberate omission of an atom
clause: the condition has no content until two distinct indices may name one state.
-/
theorem atomCoherent_toSharing (W : WitnessFamily Γ Del) : W.toSharing.AtomCoherent := by
  intro u i j h a
  have hij : i = j := (share_toSharing W u i j).mp h
  subst hij
  exact Iff.rfl

/-- **(C1') at the diagonal instance is exactly (C1).** -/
theorem localCoherentShare_toSharing (W : WitnessFamily Γ Del) :
    W.toSharing.LocalCoherentShare ↔ W.LocalCoherentLab := by
  constructor
  · intro h
    exact SharingWitnessFamily.localCoherentLab_of_share h
  · intro h i t
    obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
    refine ⟨hbot, himp, hbox, ?_, ?_⟩
    · intro j hj g e hc
      have hij : i = j := (share_toSharing W (t + 1) i j).mp hj
      subst hij
      exact huntl g e hc
    · intro k hk g e hc
      have hik : i = k := (share_toSharing W t i k).mp hk
      subst hik
      exact hsnce g e hc

/--
**Every thread of the diagonal instance is constant.**

The step field reads `share (u + 1) (idx u) (idx (u + 1))`, which is `idx u = idx (u + 1)` here,
so the index never moves. Proved at `0` by `Int.induction_on` and then transported.
-/
theorem thread_toSharing_eq_zero (W : WitnessFamily Γ Del) (θ : W.toSharing.Thread) :
    ∀ u : ℤ, θ.idx u = θ.idx 0 := by
  have hstep : ∀ u : ℤ, θ.idx u = θ.idx (u + 1) := fun u =>
    (share_toSharing W (u + 1) (θ.idx u) (θ.idx (u + 1))).mp (θ.step u)
  intro u
  refine Int.induction_on u rfl ?_ ?_
  · intro n ih
    rw [← hstep (n : ℤ)]
    exact ih
  · intro n ih
    rw [hstep (-(n : ℤ) - 1), show -(n : ℤ) - 1 + 1 = -(n : ℤ) from by omega]
    exact ih

/-- A thread of the diagonal instance holds one index at every pair of times. -/
theorem thread_toSharing_idx (W : WitnessFamily Γ Del) (θ : W.toSharing.Thread) (u v : ℤ) :
    θ.idx u = θ.idx v := by
  rw [thread_toSharing_eq_zero W θ u, thread_toSharing_eq_zero W θ v]

/-- **(C2') at the diagonal instance is exactly (C2).** -/
theorem threadFulfilling_toSharing (W : WitnessFamily Γ Del) :
    W.toSharing.ThreadFulfilling ↔ W.FulfillingLab := by
  constructor
  · intro h
    exact SharingWitnessFamily.fulfillingLab_of_thread h
  · intro h
    refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ hθ => ?_⟩
    · obtain ⟨s, hs, hes, hgs⟩ := h.1 i u g e hmem
      refine ⟨s, hs, ?_, ?_⟩
      · rw [(thread_toSharing_idx W θ s u).trans hθ]
        exact hes
      · intro r hr1 hr2
        rw [(thread_toSharing_idx W θ r u).trans hθ]
        exact hgs r hr1 hr2
    · obtain ⟨s, hs, hes, hgs⟩ := h.2 i u g e hmem
      refine ⟨s, hs, ?_, ?_⟩
      · rw [(thread_toSharing_idx W θ s u).trans hθ]
        exact hes
      · intro r hr1 hr2
        rw [(thread_toSharing_idx W θ r u).trans hθ]
        exact hgs r hr1 hr2

/--
**The deterministic bundle yields the branching bundle at the diagonal instance.**

(C0) is free, (C1') and (C2') are the two reductions above, and (C3) `BoxFaithful` and (C4)
`Target` are inherited literally — `W.toSharing.toWitnessFamily` is `W`. A fifth component,
`StabFaithful`, was planned and is out of scope; see this module's header for the semantic
statement that stands in its place.
-/
theorem certifies_toSharing (W : WitnessFamily Γ Del) {t : ℤ} (h : W.Certifies t) :
    W.toSharing.Certifies t :=
  ⟨atomCoherent_toSharing W,
    ⟨(localCoherentShare_toSharing W).mpr h.1, (threadFulfilling_toSharing W).mpr h.2.1⟩,
    h.2.2.1, h.2.2.2⟩

/-!
## The frame isomorphism, and truth transport across it

The reductions above are statements about *conditions*. They leave open the question a reader
of two parallel developments actually asks: are the two **models** the same model? They are —
up to isomorphism, not on the nose — and this section exhibits the isomorphism and transports
truth across it, so the deterministic device is a specialization of the branching one rather
than a second, unrelated construction that happens to satisfy analogous lemmas.

### Isomorphic, not definitionally equal

`W.std.frame`'s carrier is `Fin |lassos| × ℤ`. `W.toSharing.frame`'s carrier is
`Quotient W.toSharing.shareSetoid` — a quotient of that same type, by equality. A quotient by
equality is *equivalent* to what it quotients, never equal to it: `Quotient.mk` and
`Quotient.lift id` are mutually inverse but `Quotient s α` and `α` are distinct types. Every
lemma below therefore goes through `stateEquiv` explicitly, and none of them is `rfl` at the
level of types. The cost is the `histEquiv` round trip; a future reader who tries to collapse
it will rediscover that `Quotient.lift id` has no definitional inverse.

### Why the relation transport is the only real work

`stateEquiv` itself is three lines. What has to be proved is that the two task relations agree
under it, and that reduces to one fact about the diagonal instance: connectivity is index
equality. `reachN_toSharing` proves it by induction on the step count, `conn_toSharing` lifts it
past the duration-free `Conn` case split, and `taskRel_toSharing` is then a matter of
reassociating a conjunction against `Prod.ext_iff`.
-/

/-- **One step at the diagonal instance is identity of indices.** -/
@[simp]
theorem step_toSharing (W : WitnessFamily Γ Del) (u : ℤ)
    (i j : Fin W.toSharing.lassos.length) : W.toSharing.Step u i j ↔ i = j := by
  constructor
  · rintro ⟨k, hik, hkj⟩
    exact ((share_toSharing W u i k).mp hik).trans ((share_toSharing W (u + 1) k j).mp hkj)
  · intro h
    subst h
    exact SharingWitnessFamily.step_refl _ u i

/-- **Reachability of any length at the diagonal instance is identity of indices.** -/
theorem reachN_toSharing (W : WitnessFamily Γ Del) :
    ∀ (n : ℕ) (u : ℤ) (i j : Fin W.toSharing.lassos.length),
      W.toSharing.ReachN n u i j ↔ i = j := by
  intro n
  induction n with
  | zero => intro u i j; exact share_toSharing W u i j
  | succ m ih =>
    intro u i j
    constructor
    · rintro ⟨k, hik, hkj⟩
      exact ((step_toSharing W u i k).mp hik).trans ((ih (u + 1) k j).mp hkj)
    · intro h
      subst h
      exact SharingWitnessFamily.reachN_const _ (m + 1) u i

/-- **Connectivity at the diagonal instance is identity of indices**, in either time order. -/
theorem conn_toSharing (W : WitnessFamily Γ Del)
    (p q : Fin W.toSharing.lassos.length × ℤ) : W.toSharing.Conn p q ↔ p.1 = q.1 := by
  unfold SharingWitnessFamily.Conn
  split
  · exact reachN_toSharing W _ _ _ _
  · exact (reachN_toSharing W _ _ _ _).trans eq_comm

/--
**The carrier isomorphism.** `Quotient.lift id` one way, `Quotient.mk` the other; the quotient
is by equality, so the lift's compatibility obligation is discharged by `share_toSharing`.
-/
def stateEquiv (W : WitnessFamily Γ Del) :
    W.toSharing.WorldState ≃ (Fin W.lassos.length × ℤ) where
  toFun := fun C => Quotient.liftOn C id (by
    rintro ⟨i, u⟩ ⟨j, v⟩ ⟨ht, hs⟩
    have hij : i = j := (share_toSharing W u i j).mp hs
    have ht' : u = v := ht
    subst hij
    subst ht'
    rfl)
  invFun := fun p => W.toSharing.cls p.1 p.2
  left_inv := by
    intro C
    induction C using Quotient.inductionOn with
    | _ p => cases p; rfl
  right_inv := by
    intro p
    cases p
    rfl

@[simp]
theorem stateEquiv_cls (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (u : ℤ) :
    stateEquiv W (W.toSharing.cls i u) = (i, u) := rfl

theorem stateEquiv_symm_apply (W : WitnessFamily Γ Del) (p : Fin W.lassos.length × ℤ) :
    (stateEquiv W).symm p = W.toSharing.cls p.1 p.2 := rfl

/-- The carrier isomorphism at a pair, stated with the pair itself rather than its components.

Both this and `cls_stateEquiv` below exist because `W.std.Carrier` is a structure field of a
plain `def` (`ShiftSet.ofIntAction`), so it unfolds only at default transparency: a `rw` whose
pattern is at `Fin |lassos| × ℤ` does not fire against a term typed at `W.std.frame.WorldState`.
Stating the round trips as their own lemmas and discharging them by `exact` sidesteps that. -/
theorem stateEquiv_cls_pair (W : WitnessFamily Γ Del) (p : Fin W.lassos.length × ℤ) :
    stateEquiv W (W.toSharing.cls p.1 p.2) = p := by
  cases p
  rfl

/-- The other round trip: rebuilding a class from the components of its image. -/
theorem cls_stateEquiv (W : WitnessFamily Γ Del) (C : W.toSharing.WorldState) :
    W.toSharing.cls (stateEquiv W C).1 (stateEquiv W C).2 = C := by
  induction C using Quotient.inductionOn with
  | _ p => cases p; rfl

/-- **The two task relations agree under the carrier isomorphism.** -/
theorem taskRel_toSharing (W : WitnessFamily Γ Del) (C C' : W.toSharing.WorldState) (d : ℤ) :
    W.toSharing.frame.toTaskFrame.TaskRel C d C' ↔
      W.std.frame.TaskRel (stateEquiv W C) d (stateEquiv W C') := by
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q =>
      obtain ⟨i, u⟩ := p
      obtain ⟨j, v⟩ := q
      refine Iff.trans (W.toSharing.frame_taskRel _ _ _) ?_
      refine Iff.trans ?_ (W.std.fibre_taskRel (i, u) d (j, v)).symm
      constructor
      · rintro ⟨ht, hc⟩
        have hij : i = j := (conn_toSharing W (i, u) (j, v)).mp hc
        subst hij
        have hv : v = u + d := ht
        subst hv
        rfl
      · intro h
        have h' : ((j, v) : Fin W.lassos.length × ℤ) = (i, u + d) := h
        refine ⟨(congrArg Prod.snd h' : v = u + d), ?_⟩
        exact (conn_toSharing W (i, u) (j, v)).mpr (congrArg Prod.fst h').symm

/-- **The relation transport at raw pairs.** `taskRel_toSharing` with both arguments presented
as pairs rather than as quotient elements, which is the form `histEquiv` can apply by `exact`
against a state typed at `W.std.frame.WorldState`. -/
theorem taskRel_toSharing' (W : WitnessFamily Γ Del) (w w' : Fin W.lassos.length × ℤ) (d : ℤ) :
    W.toSharing.frame.toTaskFrame.TaskRel
        (W.toSharing.cls w.1 w.2) d (W.toSharing.cls w'.1 w'.2) ↔
      W.std.frame.TaskRel w d w' := by
  obtain ⟨i, u⟩ := w
  obtain ⟨j, v⟩ := w'
  exact taskRel_toSharing W (W.toSharing.cls i u) (W.toSharing.cls j v) d

/--
**The world-history isomorphism**, transported pointwise from `stateEquiv`.

A world history is determined by its states (`WorldHistory.ext_state`) and is built from a bare
state function by `WorldHistory.ofTotal`, so the equivalence is `stateEquiv` composed pointwise
in each direction, with `taskRel_toSharing` discharging the `respects_task` obligation.
-/
def histEquiv (W : WitnessFamily Γ Del) :
    WorldHistory W.toSharing.frame.toTaskFrame ≃ WorldHistory W.std.frame where
  toFun := fun τ => WorldHistory.ofTotal _ (fun t => stateEquiv W (τ.state t)) (by
    intro s t
    exact (taskRel_toSharing W _ _ _).mp (τ.respects_task s t))
  invFun := fun σ => WorldHistory.ofTotal _
    (fun t => W.toSharing.cls (σ.state t).1 (σ.state t).2) (by
      intro s t
      exact (taskRel_toSharing' W (σ.state s) (σ.state t) (t - s)).mpr (σ.respects_task s t))
  left_inv := by
    intro τ
    exact WorldHistory.ext_state (fun t => cls_stateEquiv W (τ.state t))
  right_inv := by
    intro σ
    exact WorldHistory.ext_state (fun t => stateEquiv_cls_pair W (σ.state t))

@[simp]
theorem histEquiv_state (W : WitnessFamily Γ Del)
    (τ : WorldHistory W.toSharing.frame.toTaskFrame) (t : ℤ) :
    (histEquiv W τ).state t = stateEquiv W (τ.state t) := rfl

/-- The two valuations agree under the carrier isomorphism. -/
theorem valuation_toSharing (W : WitnessFamily Γ Del)
    (hat : W.toSharing.AtomCoherent) (C : W.toSharing.WorldState) (a : Atom) :
    (W.toSharing.model hat).valuation C a ↔ W.std.model.valuation (stateEquiv W C) a := by
  induction C using Quotient.inductionOn with
  | _ q => cases q; exact Iff.rfl

/--
**The truth isomorphism** between the branching model at the diagonal instance and the
deterministic shift-set model. Time is reindexed by the identity — both frames are over
`intOrder` — so the transported formula is `φ` itself, not `φ.reflectTime`.
-/
def truthIso (W : WitnessFamily Γ Del) (hat : W.toSharing.AtomCoherent) :
    TruthIso (W.toSharing.model hat) W.std.model where
  dur := OrderIso.refl _
  hist := histEquiv W
  atom := by
    intro τ t a
    rw [histEquiv_state]
    exact valuation_toSharing W hat (τ.state t) a

/--
**The branching agreement theorem, transported to the deterministic model.**

`SharingWitnessFamily.truth_iff_mem` at `W.toSharing`, carried across `truthIso`. The
hypotheses are the *deterministic* conditions — (C0) is free at the diagonal instance and the
other two are the reductions above — so this is the branching theorem stated entirely in the
deterministic device's own terms.
-/
theorem truth_iff_mem_toSharing (W : WitnessFamily Γ Del)
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (θ : W.toSharing.Thread) (s t : ℤ) (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) :
    TruthAt W.std.model (histEquiv W (W.toSharing.hist θ s)) t ψ ↔
      ψ ∈ W.L (θ.idx (s + t)) (s + t) := by
  have h := SharingWitnessFamily.truth_iff_mem W.toSharing (atomCoherent_toSharing W)
    ((localCoherentShare_toSharing W).mpr hloc)
    ((threadFulfilling_toSharing W).mpr hful) hbox ψ hψ θ s t
  rw [Truth.truthAt_of_truthIso (truthIso W (atomCoherent_toSharing W)) ψ
    (W.toSharing.hist θ s) t] at h
  exact h

/--
**The specialization corollary**: the branching producer at the diagonal instance and the
deterministic producer inhabit the *same* statement, and the deterministic acceptance branch is
untouched.

`WitnessFamily.Refutes` is a `Prop`, so the equality itself is proof irrelevance and carries no
mathematical content. What carries the content is what the equality's *statement* requires in
order to typecheck: both sides are terms of one and the same `Refutes Γ Del`, produced from one
and the same `W.Certifies t`, with no coercion, no re-proof and no change to
`WitnessFamily.refutes_of_certifies`. The substantive specialization is `truthIso` above — the
two countermodels are built over isomorphic frames — not this line.
-/
theorem refutes_of_certifies_toSharing (W : WitnessFamily Γ Del) {t : ℤ} (h : W.Certifies t) :
    SharingWitnessFamily.refutes_of_certifies W.toSharing (certifies_toSharing W h)
      = WitnessFamily.refutes_of_certifies W h := rfl

end WitnessFamily

end FormalSystem.Metalogic.Decidability
