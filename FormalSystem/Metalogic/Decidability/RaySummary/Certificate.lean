/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

/-!
# The certificate layer: the K-free, LABEL-LEVEL certificate of realizable closure types

PROMOTED from two compiled evidence probes, which remain the oracles and keep their own copies
unchanged:

  * `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` (`Probe809C`) —
    the existential until-fixpoint `euStep`/`euIter`/`euLfp` with its discharge lemmas, and the
    product layer `ClType`/`ProdState`/`locPred`/`linkPred`/`locCoh`/`untlLink`/`coh`.
  * `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`
    (`Probe815`) — the same two blocks (which that probe itself carries verbatim, because probes
    do not import probes), the dovetailing theorem `exists_dovetail_chain`, the certificate
    predicates with the relation as a PARAMETER, the backward arm `snceLink`/`cohBi`, the
    forward and backward chain constructions, `Realizes`, the splice, and the label-level
    sufficiency `realizes_of_certAdm_cohBi`.

Everything below is a PORT: statements and proofs are the probes' own, carried over
byte-for-byte except where a library linter the probes are not subject to forced a
statement-preserving tactic rewrite, each such rewrite recorded in the "Ported adaptations"
list below. The source of each block is named in that block's own section docstring.

## Renames forced by a namespace collision

NONE. Every promoted name is free in `FormalSystem.Metalogic.Decidability.RaySummary`. Two names
exist elsewhere in the library under different full names and are therefore not collisions:
`FormalSystem.Metalogic.WeakCanonical.PathEntry.Realizes` and both
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.splice` and
`FormalSystem.PlusLanguage.splice`.

## Ported adaptations (statement-preserving, linter-forced)

Three, none of which touches a statement or a proof step:

  1. Nine `show` tactics are written `change` (`linter.style.show` requires `change` whenever the
     tactic actually alters the goal). Sites: two inside `eu_path_mem_iter`, one inside
     `exists_dovetail_chain`, six inside `realizes_of_certAdm_cohBi`.
  2. `coh_iff` keeps the probe's `[Fintype Q] [DecidableEq Q]` binders, which its TYPE does not
     use, under a local `set_option linter.unusedDecidableInType false` /
     `linter.unusedFintypeInType false`. Dropping a hypothesis would change the statement, and
     statement fidelity to a compiled oracle outranks an advisory style check.
  3. Two long `change` lines are wrapped under the 100-column limit
     (`linter.style.longLine`).

## REGION-INTERIOR: what this layer is sufficiency FOR, and what it is not

`coh` and `cohBi` require `pend` at BOTH endpoints of every edge. Two compiled facts say what
that costs. `Probe816.exists_idle_of_rlad_ray` and `Probe816.no_rlad_ray_of_pending_forever`
(`specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`) establish that NO forward
`Rlad` ray is pending forever: every such ray goes idle. A `Realizes` chain is therefore never
the object projection of an `Rlad` history, and `realizes_of_certAdm_cohBi` is sufficiency for
the INTERIOR OF ONE REGION. It transfers to the region segments of a ladder history and it does
NOT apply to the history itself.

The idle-extended relation `cohIdle` below is the relation a ladder consequence would be stated
over — `cohBi`'s two `pend` conjuncts dropped, and nothing else changed — and it is defined here
only so that the dropping is visible at one named site. Dropping those two conjuncts removes the
relation's dependence on the pending bit altogether, so `cohIdle` does not take `pend` at all;
`cohIdle_eq_cohBi_of_pend` and `cohIdle_of_cohBi` are the two lemmas that pin the comparison.
NO LADDER CONSEQUENCE IS STATED IN THIS MODULE. Composition across
idle runs is the content of the soundness and completeness obligations, and no theorem here
supplies it.

## Deliberately NOT promoted

The counter quotient `K`, the `K`-indexed certificate predicates, and the maximum certified
subset. `certStab` and `certAdm` ARE promoted, at the `K`-free carrier `ProdState Q φ`, because
`realizes_of_certAdm_cohBi` is stated in terms of both and cannot be promoted without them; the
`K`-indexed versions of the same two conditions are separate objects over a different carrier
and carry their own names.

The pin lemma's soundness half (`forward_window`, `backward_constraint`, `region_doubling`,
`iter_doubling`) stays in `counter-lift-gates.lean`; its lift half is in `RunLayer.lean`.

## Guardrails

(a) The letters are closure-indexed over the time axis and the `box`/`stab` bits are included:
`certBox` and `certStab` are conditions of `certAdm` and are never dropped. (b) Nothing here
bounds a fibre or assumes a finite width; the only finiteness is `[Fintype Q]` on the OBJECT,
exactly as the probes have it. (c) No quantity here is an upper bound: `euLfp` is a fixpoint of
a monotone operator on a `Finset` and `eu_lfp_eq_iter_card` is a count of iterations.
(d) Zero debt: no Büchi or MSO lemma is cited in place of a proof and nothing external is
required. (e) The layer is direction-symmetric only once `cohBi` replaces `coh`:
`Probe815.sufficiency_refuted` shows `coh` alone is NOT sufficient, and
`Probe815.cohBi_rejects_x1_x0` is the edge that separates them. No device-discrimination claim
is made anywhere.
-/

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ## The EXISTENTIAL until-fixpoint, ported VERBATIM from `realizable-type-certificate.lean`

Probes do not import probes, so the operator the certificate's conditions (3) and (4) run is
restated here, unchanged: `euStep`/`euIter`/`euLfp` and the lemmas through
`eu_lfp_eq_empty_of_no_event`.  Nothing in this section is new. -/

variable {α : Type*} [DecidableEq α]

/--
One step of the EXISTENTIAL `E[g U e]` operator: the positions SOME successor of which either
delivers the event now, or carries the guard and is already known to deliver it later.
-/
def euStep (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    Finset α :=
  V.filter (fun v => ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

theorem eu_step_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    euStep V succ isE isG X ⊆ V := Finset.filter_subset _ _

/-- **The operator is monotone**, which is what makes the iteration a chain.  The only property
the iteration needs, and the only one the quantifier change could have broken. -/
theorem eu_step_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    {X Y : Finset α} (h : X ⊆ Y) :
    euStep V succ isE isG X ⊆ euStep V succ isE isG Y := by
  intro v hv
  rw [euStep, Finset.mem_filter] at hv ⊢
  obtain ⟨hvV, w, hw, hcase⟩ := hv
  refine ⟨hvV, w, hw, ?_⟩
  rcases hcase with he | ⟨hg, hx⟩
  · exact Or.inl he
  · exact Or.inr ⟨hg, h hx⟩

/-- The iteration of the operator from `∅`. -/
def euIter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : ℕ → Finset α
  | 0 => ∅
  | n + 1 => euStep V succ isE isG (euIter V succ isE isG n)

theorem eu_iter_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, euIter V succ isE isG n ⊆ V
  | 0 => Finset.empty_subset _
  | _ + 1 => eu_step_subset _ _ _ _ _

theorem eu_iter_succ_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, euIter V succ isE isG n ⊆ euIter V succ isE isG (n + 1)
  | 0 => Finset.empty_subset _
  | n + 1 => eu_step_mono V succ isE isG (eu_iter_succ_mono V succ isE isG n)

theorem eu_iter_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {m n : ℕ}
    (h : m ≤ n) : euIter V succ isE isG m ⊆ euIter V succ isE isG n := by
  induction n with
  | zero =>
      have hm : m = 0 := Nat.le_zero.mp h
      subst hm
      exact Finset.Subset.refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact subset_trans (ih (Nat.lt_succ_iff.mp hlt)) (eu_iter_succ_mono V succ isE isG k)
      · have hm : m = k + 1 := le_antisymm h hge
        subst hm
        exact Finset.Subset.refl _

/-- **Stabilization propagates**: once one step is fixed, every later index agrees with it. -/
theorem eu_iter_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {n : ℕ}
    (h : euIter V succ isE isG (n + 1) = euIter V succ isE isG n) :
    ∀ m, n ≤ m → euIter V succ isE isG m = euIter V succ isE isG n := by
  intro m
  induction m with
  | zero =>
      intro hm
      have hn : n = 0 := Nat.le_zero.mp hm
      subst hn
      rfl
  | succ k ih =>
      intro hm
      rcases Nat.lt_or_ge n (k + 1) with hlt | hge
      · have hk : n ≤ k := Nat.lt_succ_iff.mp hlt
        have hek : euIter V succ isE isG k = euIter V succ isE isG n := ih hk
        have hstep : euIter V succ isE isG (k + 1)
            = euStep V succ isE isG (euIter V succ isE isG n) := by
          rw [← hek]; rfl
        rw [hstep]
        exact h
      · have hn : n = k + 1 := le_antisymm hm hge
        subst hn
        rfl

/-- **The iteration stabilizes within `|V|` steps.**  The pigeonhole on the cardinality measure,
unchanged from `AUFix.exists_stab`. -/
theorem eu_exists_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∃ n ≤ V.card, euIter V succ isE isG (n + 1) = euIter V succ isE isG n := by
  by_contra hc
  push Not at hc
  have hcard : ∀ n, n ≤ V.card + 1 → n ≤ (euIter V succ isE isG n).card := by
    intro n
    induction n with
    | zero => intro _; exact Nat.zero_le _
    | succ k ih =>
        intro hk
        have hk' : k ≤ V.card := by omega
        have hne := hc k hk'
        have hsub := eu_iter_succ_mono V succ isE isG k
        have hss : euIter V succ isE isG k ⊂ euIter V succ isE isG (k + 1) :=
          Finset.ssubset_iff_subset_ne.mpr ⟨hsub, fun hcon => hne hcon.symm⟩
        have hlt := Finset.card_lt_card hss
        have hprev := ih (by omega)
        omega
  have h1 := hcard (V.card + 1) (le_refl _)
  have h2 : (euIter V succ isE isG (V.card + 1)).card ≤ V.card :=
    Finset.card_le_card (eu_iter_subset V succ isE isG _)
  omega

/-- **The `E[g U e]` fixpoint**: the iteration run to its stabilization bound. -/
def euLfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  euIter V succ isE isG (V.card + 1)

theorem eu_lfp_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euLfp V succ isE isG ⊆ V := eu_iter_subset _ _ _ _ _

/-- **It is a fixpoint.** -/
theorem eu_lfp_fixed (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euStep V succ isE isG (euLfp V succ isE isG) = euLfp V succ isE isG := by
  obtain ⟨n, hn, hstab⟩ := eu_exists_stab V succ isE isG
  have e1 : euIter V succ isE isG (V.card + 1) = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ (by omega)
  have e2 : euIter V succ isE isG (V.card + 2) = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ (by omega)
  change euIter V succ isE isG (V.card + 2) = euIter V succ isE isG (V.card + 1)
  rw [e1, e2]

/-- **It is the least pre-fixpoint**, which is what excludes the eventualities passed around a
cycle forever without ever being delivered. -/
theorem eu_lfp_least (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {X : Finset α}
    (h : euStep V succ isE isG X ⊆ X) : euLfp V succ isE isG ⊆ X := by
  have key : ∀ n, euIter V succ isE isG n ⊆ X := by
    intro n
    induction n with
    | zero => exact Finset.empty_subset _
    | succ k ih => exact subset_trans (eu_step_mono V succ isE isG ih) h
  exact key _

/-- Membership in the fixpoint, unfolded one step. -/
theorem eu_mem_lfp_iff (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (v : α) :
    v ∈ euLfp V succ isE isG ↔
      v ∈ V ∧ ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ euLfp V succ isE isG) := by
  constructor
  · intro hv
    rw [← eu_lfp_fixed V succ isE isG, euStep, Finset.mem_filter] at hv
    exact hv
  · intro hv
    rw [← eu_lfp_fixed V succ isE isG, euStep, Finset.mem_filter]
    exact hv

/-! ## What the fixpoint MEANS: a guarded path that delivers the event

The existential analogue of `AUFix.lfp_induction`, read as a path statement.  The path is
STRICTLY later: `0 < n` and the event is demanded at `f n`, so this is strict until and not weak
until.  Dropping `0 < n` would silently turn one into the other. -/

/-- Every iterate lies inside the fixpoint -- for EVERY index, not only the indices below the
stabilization bound.  This is what makes the backward direction of the path characterization need
no path-shortening argument. -/
theorem eu_iter_subset_lfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (n : ℕ) :
    euIter V succ isE isG n ⊆ euLfp V succ isE isG := by
  obtain ⟨k, hk, hstab⟩ := eu_exists_stab V succ isE isG
  rcases Nat.lt_or_ge n (V.card + 1) with hlt | hge
  · exact eu_iter_mono V succ isE isG (by omega)
  · have e1 : euIter V succ isE isG n = euIter V succ isE isG k :=
      eu_iter_stab V succ isE isG hstab n (by omega)
    have e2 : euIter V succ isE isG (V.card + 1) = euIter V succ isE isG k :=
      eu_iter_stab V succ isE isG hstab _ (by omega)
    rw [euLfp, e1, e2]

/-- Forward: membership in an iterate exhibits a guarded path to the event. -/
theorem eu_iter_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ (k : ℕ), ∀ v ∈ euIter V succ isE isG k,
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := by
  intro k
  induction k with
  | zero => intro v hv; simp only [euIter] at hv; exact absurd hv (by simp)
  | succ k ih =>
    intro v hv
    have hv' : v ∈ euStep V succ isE isG (euIter V succ isE isG k) := hv
    rw [euStep, Finset.mem_filter] at hv'
    obtain ⟨hvV, w, hw, hcase⟩ := hv'
    rcases hcase with he | ⟨hg, hwk⟩
    · refine ⟨1, fun i => if i = 0 then v else w, Nat.one_pos, by simp, ?_, ?_, ?_, ?_⟩
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hvV
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hw
      · simpa using he
      · intro i h0 hi; omega
    · obtain ⟨n, f, hn, hf0, hfV, hfs, hfe, hfg⟩ := ih w hwk
      refine ⟨n + 1, fun i => if i = 0 then v else f (i - 1), Nat.succ_pos _, by simp,
        ?_, ?_, ?_, ?_⟩
      · intro i hi
        cases i with
        | zero => simpa using hvV
        | succ j => simpa using hfV j (by omega)
      · intro i hi
        cases i with
        | zero => simpa [hf0] using hw
        | succ j => simpa using hfs j (by omega)
      · simpa using hfe
      · intro i h0 hi
        cases i with
        | zero => omega
        | succ j =>
          cases j with
          | zero => simpa [hf0] using hg
          | succ j' => simpa using hfg (j' + 1) (Nat.succ_pos _) (by omega)

/-- Backward: a guarded path of length `n` to the event puts its origin in the `n`-th iterate. -/
theorem eu_path_mem_iter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ (n : ℕ) (f : ℕ → α), 0 < n → (∀ i < n, f i ∈ V) → (∀ i < n, f (i + 1) ∈ succ (f i)) →
      isE (f n) = true → (∀ i, 0 < i → i < n → isG (f i) = true) →
      f 0 ∈ euIter V succ isE isG n := by
  intro n
  induction n with
  | zero => intro f h0 _ _ _ _; exact absurd h0 (by omega)
  | succ m ih =>
    intro f _ hV hs hE hG
    rcases Nat.eq_zero_or_pos m with hm | hm
    · subst hm
      change f 0 ∈ euStep V succ isE isG (euIter V succ isE isG 0)
      rw [euStep, Finset.mem_filter]
      exact ⟨hV 0 (by omega), f 1, hs 0 (by omega), Or.inl hE⟩
    · have key : f 1 ∈ euIter V succ isE isG m := by
        have h := ih (fun i => f (i + 1)) hm
          (fun i hi => hV (i + 1) (by omega))
          (fun i hi => hs (i + 1) (by omega))
          (by simpa using hE)
          (fun i h0 hi => hG (i + 1) (by omega) (by omega))
        simpa using h
      change f 0 ∈ euStep V succ isE isG (euIter V succ isE isG m)
      rw [euStep, Finset.mem_filter]
      exact ⟨hV 0 (by omega), f 1, hs 0 (by omega),
        Or.inr ⟨hG 1 (by omega) (by omega), key⟩⟩

/-- **THE FIXPOINT IS THE GUARDED-PATH OPERATOR.**  `v` is in the existential fixpoint exactly
when SOME path out of `v`, staying inside `V`, carries the guard at every strictly interior
position and delivers the event at a STRICTLY later index.  This is the condition the certificate
checks, and it is existential: one path suffices. -/
theorem eu_mem_lfp_iff_exists_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (v : α) :
    v ∈ euLfp V succ isE isG ↔
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := by
  constructor
  · intro hv
    have hv' : v ∈ euIter V succ isE isG (V.card + 1) := hv
    exact eu_iter_path V succ isE isG (V.card + 1) v hv'
  · rintro ⟨n, f, hn, hf0, hfV, hfs, hfe, hfg⟩
    have h := eu_path_mem_iter V succ isE isG n f hn hfV hfs hfe hfg
    rw [hf0] at h
    exact eu_iter_subset_lfp V succ isE isG n h

/-- **The one negative lemma the rejection proof consumes.**  If `V` is closed under `succ` and no
member of `V` delivers the event, the existential fixpoint is EMPTY -- no amount of guarded
wandering inside `V` discharges anything.  Proved through `eu_lfp_least` at `X := ∅`, structurally
rather than by brute force. -/
theorem eu_lfp_eq_empty_of_no_event (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (hclosed : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hno : ∀ w ∈ V, isE w = false) :
    euLfp V succ isE isG = ∅ := by
  refine Finset.subset_empty.mp (eu_lfp_least V succ isE isG ?_)
  intro v hv
  rw [euStep, Finset.mem_filter] at hv
  obtain ⟨hvV, w, hw, hcase⟩ := hv
  rcases hcase with he | ⟨-, hx⟩
  · rw [hno w (hclosed v hvV w hw)] at he
    exact absurd he (by simp)
  · exact absurd hx (Finset.notMem_empty w)

/-! ## Item (b): the length bound of condition (3) is DERIVED, not assumed

Condition (3) as compiled checks membership in `euLfp R (succR R) _ _`; the research round's
prose attached "of length at most `|R|`" to it and called that bound "the obvious one rather than
a derived one".  The two theorems below derive it: every member of the fixpoint has a guarded
delivering path of at most `V.card` steps (`eu_mem_lfp_path_le_card`), because the iteration is
already stable at index `V.card` (`eu_lfp_eq_iter_card`).  Nothing downstream consumes the bound:
the dovetailing theorem uses only the existence of a finite path, and decidability of condition
(3) is by the iteration itself, not by a bounded path search.  So what the prose "assumed" was a
corollary, and it costs nothing. -/

/-- The fixpoint is already reached at index `V.card`. -/
theorem eu_lfp_eq_iter_card (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euLfp V succ isE isG = euIter V succ isE isG V.card := by
  obtain ⟨n, hn, hstab⟩ := eu_exists_stab V succ isE isG
  have e1 : euIter V succ isE isG (V.card + 1) = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ (by omega)
  have e2 : euIter V succ isE isG V.card = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ hn
  rw [euLfp, e1, e2]

/-- `eu_iter_path` with the length of the exhibited path recorded: a member of the `k`-th iterate
has a delivering path of at most `k` steps. -/
theorem eu_iter_path_le (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ (k : ℕ), ∀ v ∈ euIter V succ isE isG k,
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ n ≤ k ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := by
  intro k
  induction k with
  | zero => intro v hv; simp only [euIter] at hv; exact absurd hv (by simp)
  | succ k ih =>
    intro v hv
    have hv' : v ∈ euStep V succ isE isG (euIter V succ isE isG k) := hv
    rw [euStep, Finset.mem_filter] at hv'
    obtain ⟨hvV, w, hw, hcase⟩ := hv'
    rcases hcase with he | ⟨hg, hwk⟩
    · refine ⟨1, fun i => if i = 0 then v else w, Nat.one_pos, by omega, by simp, ?_, ?_, ?_, ?_⟩
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hvV
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hw
      · simpa using he
      · intro i h0 hi; omega
    · obtain ⟨n, f, hn, hnk, hf0, hfV, hfs, hfe, hfg⟩ := ih w hwk
      refine ⟨n + 1, fun i => if i = 0 then v else f (i - 1), Nat.succ_pos _, by omega, by simp,
        ?_, ?_, ?_, ?_⟩
      · intro i hi
        cases i with
        | zero => simpa using hvV
        | succ j => simpa using hfV j (by omega)
      · intro i hi
        cases i with
        | zero => simpa [hf0] using hw
        | succ j => simpa using hfs j (by omega)
      · simpa using hfe
      · intro i h0 hi
        cases i with
        | zero => omega
        | succ j =>
          cases j with
          | zero => simpa [hf0] using hg
          | succ j' => simpa using hfg (j' + 1) (Nat.succ_pos _) (by omega)

/-- **THE BOUND, DERIVED.**  A member of the existential fixpoint has a guarded delivering path
inside `V` of at most `V.card` steps. -/
theorem eu_mem_lfp_path_le_card (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (v : α) (hv : v ∈ euLfp V succ isE isG) :
    ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ n ≤ V.card ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
      (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
      (∀ i, 0 < i → i < n → isG (f i) = true) := by
  rw [eu_lfp_eq_iter_card] at hv
  exact eu_iter_path_le V succ isE isG V.card v hv

/-! ## Item (a): the dovetailing argument, as a theorem over an arbitrary finite graph

The research round's argument: from any `x` in `R`, round-robin the finitely many eventualities
of the closure, discharging each by its guarded path and otherwise stepping; every eventuality is
then discharged infinitely often.  It is stated here with NO formula, NO label and NO object --
a finite carrier `V`, a successor map `succ`, a list `L` of eventualities, and for each one a
"carried" predicate, an event test and a guard test -- so that the forward arm of the certificate
and the backward arm of the strengthened one are both INSTANCES of the one theorem, at `succR`
and at `preR` respectively.

Two hypotheses carry the whole argument, and the report's prose named only the second:
  * `LinkStep`: an obligation carried at `v` is, at EVERY successor `w`, either delivered or
    carried on under its guard -- the ONE-STEP LINK.  This is what `untl_propagates_along_coh`
    iterates, and it is exactly what the compiled relation has for `untl` and lacks for `snce`.
  * the discharge paths of conditions (3)/(4), read through `eu_mem_lfp_iff_exists_path`.
Without the link, an obligation picked up at an interior position of someone else's discharge
path has no reason to survive to the next position where its own round comes up, and the
round-robin cannot see it.  That is the whole content of item (c) below. -/

section Dovetail

variable {β : Type*} {ε : Type*}

/-- The one-step link for a single eventuality: carried at `v` means, at every successor `w`,
delivered now or carried on under the guard. -/
def LinkStep (succ : β → Finset β) (car : β → Prop) (evt grd : β → Bool) : Prop :=
  ∀ v w, w ∈ succ v → car v → evt w = true ∨ (grd w = true ∧ car w)

/-- **Propagation along a chain**, abstractly: `untl_propagates_along_coh` with the relation
abstracted into `LinkStep`, over a chain that need only be a chain up to `n`. -/
theorem propagates (succ : β → Finset β) (car : β → Prop) (evt grd : β → Bool)
    (hlink : LinkStep succ car evt grd) (f : ℕ → β) (i n : ℕ) (hin : i ≤ n)
    (hf : ∀ k, k < n → f (k + 1) ∈ succ (f k)) (hcar : car (f i)) :
    (∃ j, i < j ∧ j ≤ n ∧ evt (f j) = true ∧ ∀ r, i < r → r < j → grd (f r) = true) ∨
      (car (f n) ∧ ∀ r, i < r → r ≤ n → grd (f r) = true) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = i + d := ⟨n - i, by omega⟩
  clear hin
  induction d with
  | zero => exact Or.inr ⟨hcar, fun r h1 h2 => absurd h1 (by omega)⟩
  | succ d ih =>
    rcases ih (fun k hk => hf k (by omega)) with hleft | hright
    · obtain ⟨j, hij, hjn, hej, hgj⟩ := hleft
      exact Or.inl ⟨j, hij, by omega, hej, hgj⟩
    · obtain ⟨hcarry, hguards⟩ := hright
      rcases hlink (f (i + d)) (f (i + d + 1)) (hf (i + d) (by omega)) hcarry with he' | ⟨hu', hc'⟩
      · exact Or.inl ⟨i + d + 1, by omega, by omega, he', fun r h1 h2 => hguards r h1 (by omega)⟩
      · refine Or.inr ⟨hc', ?_⟩
        intro r h1 h2
        rcases Nat.lt_or_ge r (i + d + 1) with hlt | hge
        · exact hguards r h1 (by omega)
        · have hr : r = i + d + 1 := by omega
          subst hr
          exact hu'

/-- A finite segment from `x`: a `succ`-chain of POSITIVE length inside `V`. -/
def Segment (V : Finset β) (succ : β → Finset β) (x : β) (n : ℕ) (h : ℕ → β) : Prop :=
  0 < n ∧ h 0 = x ∧ (∀ i ≤ n, h i ∈ V) ∧ ∀ i < n, h (i + 1) ∈ succ (h i)

/-- An obligation at the BASE of a segment is delivered inside it, under its guard. -/
def DischargedAtBase (evt grd : β → Bool) (n : ℕ) (h : ℕ → β) : Prop :=
  ∃ j, 0 < j ∧ j ≤ n ∧ evt (h j) = true ∧ ∀ r, 0 < r → r < j → grd (h r) = true

/-- The shape of a discharge path, as `eu_mem_lfp_iff_exists_path` delivers it. -/
def HasDischargePath (V : Finset β) (succ : β → Finset β) (evt grd : β → Bool) (v : β) : Prop :=
  ∃ (n : ℕ) (h : ℕ → β), 0 < n ∧ h 0 = v ∧ (∀ i < n, h i ∈ V) ∧
    (∀ i < n, h (i + 1) ∈ succ (h i)) ∧ evt (h n) = true ∧
    (∀ i, 0 < i → i < n → grd (h i) = true)

/-- **ONE ROUND.**  From any `x ∈ V` there is a segment inside `V` discharging EVERY eventuality
of `L` carried at `x`.  Induction on `L`: the segment built for the tail is extended, if the head
is still carried at its end (`propagates`), by the head's own discharge path from there. -/
theorem exists_round (V : Finset β) (succ : β → Finset β) (car : ε → β → Prop)
    (evt grd : ε → β → Bool)
    (hV : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hne : ∀ v ∈ V, (succ v).Nonempty)
    (L : List ε) (hlink : ∀ ψ ∈ L, LinkStep succ (car ψ) (evt ψ) (grd ψ))
    (hdis : ∀ ψ ∈ L, ∀ v ∈ V, car ψ v → HasDischargePath V succ (evt ψ) (grd ψ) v)
    (x : β) (hx : x ∈ V) :
    ∃ (n : ℕ) (h : ℕ → β), Segment V succ x n h ∧
      ∀ ψ ∈ L, car ψ x → DischargedAtBase (evt ψ) (grd ψ) n h := by
  induction L with
  | nil =>
    obtain ⟨y, hy⟩ := hne x hx
    refine ⟨1, fun i => if i = 0 then x else y, ⟨Nat.one_pos, by simp, ?_, ?_⟩,
      fun ψ hψ => by simp at hψ⟩
    · intro i hi
      rcases Nat.eq_zero_or_pos i with rfl | hpos
      · simpa using hx
      · have h1 : i = 1 := by omega
        subst h1; simpa using hV x hx y hy
    · intro i hi
      have h0 : i = 0 := by omega
      subst h0; simpa using hy
  | cons ψ L ih =>
    obtain ⟨n, h, hseg, hall⟩ := ih (fun ψ' hψ' => hlink ψ' (List.mem_cons_of_mem _ hψ'))
      (fun ψ' hψ' => hdis ψ' (List.mem_cons_of_mem _ hψ'))
    by_cases hcar : car ψ x
    · have hcar0 : car ψ (h 0) := by rw [hseg.2.1]; exact hcar
      rcases propagates succ (car ψ) (evt ψ) (grd ψ) (hlink ψ List.mem_cons_self) h 0 n
          (Nat.zero_le _) hseg.2.2.2 hcar0 with hin | ⟨hcarn, hgrd⟩
      · obtain ⟨j, hj0, hjn, hej, hgj⟩ := hin
        refine ⟨n, h, hseg, fun ψ' hψ' hc => ?_⟩
        rcases List.mem_cons.mp hψ' with rfl | hψ'
        · exact ⟨j, hj0, hjn, hej, hgj⟩
        · exact hall ψ' hψ' hc
      · obtain ⟨m, p, hm, hp0, hpV, hps, hpe, hpg⟩ :=
          hdis ψ List.mem_cons_self (h n) (hseg.2.2.1 n le_rfl) hcarn
        have hpV' : ∀ i ≤ m, p i ∈ V := by
          intro i hi
          rcases Nat.lt_or_ge i m with hlt | hge
          · exact hpV i hlt
          · have him : i = m := by omega
            subst him
            have h1 : i - 1 < i := by omega
            have h2 := hV _ (hpV (i - 1) h1) _ (hps (i - 1) h1)
            rwa [show i - 1 + 1 = i by omega] at h2
        refine ⟨n + m, fun i => if i ≤ n then h i else p (i - n),
          ⟨by omega, by simp [hseg.2.1], ?_, ?_⟩, ?_⟩
        · intro i hi
          by_cases hin : i ≤ n
          · simp only [hin, if_true]; exact hseg.2.2.1 i hin
          · simp only [hin, if_false]; exact hpV' (i - n) (by omega)
        · intro i hi
          by_cases hin : i + 1 ≤ n
          · simp only [hin, show i ≤ n by omega, if_true]; exact hseg.2.2.2 i (by omega)
          · by_cases hi0 : i ≤ n
            · have hin' : i = n := by omega
              subst hin'
              simp only [hin, hi0, if_true, if_false, show i + 1 - i = 1 by omega]
              rw [← hp0]; exact hps 0 hm
            · simp only [hin, hi0, if_false, show i + 1 - n = (i - n) + 1 by omega]
              exact hps (i - n) (by omega)
        · intro ψ' hψ' hc
          rcases List.mem_cons.mp hψ' with rfl | hψ'
          · refine ⟨n + m, by omega, le_rfl, ?_, ?_⟩
            · simp only [show ¬ (n + m ≤ n) by omega, if_false, show n + m - n = m by omega]
              exact hpe
            · intro r h0 hr
              by_cases hrn : r ≤ n
              · simp only [hrn, if_true]; exact hgrd r h0 hrn
              · simp only [hrn, if_false]; exact hpg (r - n) (by omega) (by omega)
          · obtain ⟨j, hj0, hjn, hej, hgj⟩ := hall ψ' hψ' hc
            refine ⟨j, hj0, by omega, ?_, ?_⟩
            · simp only [hjn, if_true]; exact hej
            · intro r h0 hr
              simp only [show r ≤ n by omega, if_true]; exact hgj r h0 hr
    · refine ⟨n, h, hseg, fun ψ' hψ' hc => ?_⟩
      rcases List.mem_cons.mp hψ' with rfl | hψ'
      · exact absurd hc hcar
      · exact hall ψ' hψ' hc

/-! ### Assembling the rounds into an infinite chain

`baseSeq` is the sequence of round-boundary states and `bnd` the boundary positions; a position
`k` belongs to the round `roundOf k` whose boundaries enclose it, and `chain k` reads the state
off that round's segment.  `chain_eq` is the only fact needed about the bookkeeping: on
`[bnd r, bnd (r + 1)]` the chain IS the `r`-th segment, endpoint included. -/

/-- Round-boundary states. -/
def baseSeq (nR : β → ℕ) (hR : β → ℕ → β) (x : β) : ℕ → β
  | 0 => x
  | r + 1 => hR (baseSeq nR hR x r) (nR (baseSeq nR hR x r))

/-- Round-boundary positions. -/
def bnd (nR : β → ℕ) (hR : β → ℕ → β) (x : β) : ℕ → ℕ
  | 0 => 0
  | r + 1 => bnd nR hR x r + nR (baseSeq nR hR x r)

theorem bnd_lt (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (r : ℕ) :
    bnd nR hR x r < bnd nR hR x (r + 1) := by
  simp only [bnd]; have := hpos (baseSeq nR hR x r); omega

theorem bnd_mono (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) {r s : ℕ}
    (h : r ≤ s) : bnd nR hR x r ≤ bnd nR hR x s := by
  induction s with
  | zero => have : r = 0 := by omega
            subst this; exact le_rfl
  | succ s ih =>
    rcases Nat.lt_or_ge r (s + 1) with hlt | hge
    · exact le_trans (ih (by omega)) (le_of_lt (bnd_lt nR hR x hpos s))
    · have : r = s + 1 := by omega
      subst this; exact le_rfl

theorem le_bnd (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (r : ℕ) :
    r ≤ bnd nR hR x r := by
  induction r with
  | zero => exact Nat.zero_le _
  | succ r ih => have := bnd_lt nR hR x hpos r; omega

theorem exists_round_bound (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v)
    (k : ℕ) : ∃ r, k < bnd nR hR x (r + 1) :=
  ⟨k, by have := le_bnd nR hR x hpos (k + 1); omega⟩

/-- The round a position belongs to. -/
def roundOf (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (k : ℕ) : ℕ :=
  Nat.find (exists_round_bound nR hR x hpos k)

theorem roundOf_eq (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (k r : ℕ)
    (h1 : bnd nR hR x r ≤ k) (h2 : k < bnd nR hR x (r + 1)) :
    roundOf nR hR x hpos k = r := by
  rw [roundOf, Nat.find_eq_iff]
  refine ⟨h2, fun r' hr' hlt => ?_⟩
  have := bnd_mono nR hR x hpos (show r' + 1 ≤ r by omega)
  omega

theorem roundOf_spec (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (k : ℕ) :
    bnd nR hR x (roundOf nR hR x hpos k) ≤ k ∧ k < bnd nR hR x (roundOf nR hR x hpos k + 1) := by
  refine ⟨?_, Nat.find_spec (exists_round_bound nR hR x hpos k)⟩
  rcases Nat.eq_zero_or_pos (roundOf nR hR x hpos k) with h0 | hpos'
  · rw [h0]; simp [bnd]
  · have hmin := Nat.find_min (exists_round_bound nR hR x hpos k)
      (show roundOf nR hR x hpos k - 1 < roundOf nR hR x hpos k by omega)
    rw [show roundOf nR hR x hpos k - 1 + 1 = roundOf nR hR x hpos k by omega] at hmin
    omega

/-- The assembled chain. -/
def chain (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v) (k : ℕ) : β :=
  hR (baseSeq nR hR x (roundOf nR hR x hpos k)) (k - bnd nR hR x (roundOf nR hR x hpos k))

/-- **On `[bnd r, bnd (r + 1)]` the chain is the `r`-th segment, endpoint included.** -/
theorem chain_eq (nR : β → ℕ) (hR : β → ℕ → β) (x : β) (hpos : ∀ v, 0 < nR v)
    (hR0 : ∀ v, hR v 0 = v) (r j : ℕ) (hj : j ≤ nR (baseSeq nR hR x r)) :
    chain nR hR x hpos (bnd nR hR x r + j) = hR (baseSeq nR hR x r) j := by
  rcases Nat.lt_or_ge j (nR (baseSeq nR hR x r)) with hlt | hge
  · have hr : roundOf nR hR x hpos (bnd nR hR x r + j) = r :=
      roundOf_eq nR hR x hpos _ r (by omega) (by simp only [bnd]; omega)
    simp only [chain, hr, Nat.add_sub_cancel_left]
  · have hj' : j = nR (baseSeq nR hR x r) := by omega
    subst hj'
    have hb : bnd nR hR x r + nR (baseSeq nR hR x r) = bnd nR hR x (r + 1) := rfl
    have hr : roundOf nR hR x hpos (bnd nR hR x (r + 1)) = r + 1 :=
      roundOf_eq nR hR x hpos _ (r + 1) le_rfl (bnd_lt nR hR x hpos (r + 1))
    rw [hb]
    simp only [chain, hr, Nat.sub_self, hR0]
    rfl

/-- **THE DOVETAILING THEOREM.**  From any `x ∈ V` there is an infinite `succ`-chain inside `V`
along which EVERY eventuality of `L` carried at ANY position is delivered strictly later, under
its guard.  The chain is the concatenation of rounds; an obligation at an interior position is
carried by `propagates` to the next round boundary, where that round discharges it. -/
theorem exists_dovetail_chain (V : Finset β) (succ : β → Finset β) (car : ε → β → Prop)
    (evt grd : ε → β → Bool)
    (hV : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hne : ∀ v ∈ V, (succ v).Nonempty)
    (L : List ε) (hlink : ∀ ψ ∈ L, LinkStep succ (car ψ) (evt ψ) (grd ψ))
    (hdis : ∀ ψ ∈ L, ∀ v ∈ V, car ψ v → HasDischargePath V succ (evt ψ) (grd ψ) v)
    (x : β) (hx : x ∈ V) :
    ∃ f : ℕ → β, f 0 = x ∧ (∀ k, f k ∈ V) ∧ (∀ k, f (k + 1) ∈ succ (f k)) ∧
      ∀ k, ∀ ψ ∈ L, car ψ (f k) →
        ∃ j, k < j ∧ evt ψ (f j) = true ∧ ∀ r, k < r → r < j → grd ψ (f r) = true := by
  have hround : ∀ v : β, ∃ (n : ℕ) (h : ℕ → β), 0 < n ∧ h 0 = v ∧
      (v ∈ V → Segment V succ v n h ∧
        ∀ ψ ∈ L, car ψ v → DischargedAtBase (evt ψ) (grd ψ) n h) := by
    intro v
    by_cases hv : v ∈ V
    · obtain ⟨n, h, hseg, hall⟩ := exists_round V succ car evt grd hV hne L hlink hdis v hv
      exact ⟨n, h, hseg.1, hseg.2.1, fun _ => ⟨hseg, hall⟩⟩
    · exact ⟨1, fun _ => v, Nat.one_pos, rfl, fun h => absurd h hv⟩
  choose nR hR hpos hR0 hspec using hround
  have hbase : ∀ r, baseSeq nR hR x r ∈ V := by
    intro r
    induction r with
    | zero => exact hx
    | succ r ih =>
      change hR (baseSeq nR hR x r) (nR (baseSeq nR hR x r)) ∈ V
      exact (hspec _ ih).1.2.2.1 _ le_rfl
  have hchainV : ∀ k, chain nR hR x hpos k ∈ V := by
    intro k
    obtain ⟨h1, h2⟩ := roundOf_spec nR hR x hpos k
    set r := roundOf nR hR x hpos k
    have hk : k = bnd nR hR x r + (k - bnd nR hR x r) := by omega
    have hj : k - bnd nR hR x r ≤ nR (baseSeq nR hR x r) := by
      have : bnd nR hR x (r + 1) = bnd nR hR x r + nR (baseSeq nR hR x r) := rfl
      omega
    rw [hk, chain_eq nR hR x hpos hR0 r _ hj]
    exact (hspec _ (hbase r)).1.2.2.1 _ hj
  have hchainS : ∀ k, chain nR hR x hpos (k + 1) ∈ succ (chain nR hR x hpos k) := by
    intro k
    obtain ⟨h1, h2⟩ := roundOf_spec nR hR x hpos k
    set r := roundOf nR hR x hpos k
    have hb : bnd nR hR x (r + 1) = bnd nR hR x r + nR (baseSeq nR hR x r) := rfl
    have hk : k = bnd nR hR x r + (k - bnd nR hR x r) := by omega
    have hj : k - bnd nR hR x r < nR (baseSeq nR hR x r) := by omega
    have hk1 : k + 1 = bnd nR hR x r + (k - bnd nR hR x r + 1) := by omega
    have e1 : chain nR hR x hpos (k + 1) = hR (baseSeq nR hR x r) (k - bnd nR hR x r + 1) := by
      rw [hk1]; exact chain_eq nR hR x hpos hR0 r _ (by omega)
    have e2 : chain nR hR x hpos k = hR (baseSeq nR hR x r) (k - bnd nR hR x r) := by
      have e := chain_eq nR hR x hpos hR0 r (k - bnd nR hR x r) (by omega)
      rw [← hk] at e
      exact e
    rw [e1, e2]
    exact (hspec _ (hbase r)).1.2.2.2 _ hj
  refine ⟨chain nR hR x hpos, ?_, hchainV, hchainS, ?_⟩
  · have := chain_eq nR hR x hpos hR0 0 0 (Nat.zero_le _)
    simp only [bnd, Nat.add_zero, baseSeq, hR0] at this
    exact this
  · intro k ψ hψ hcar
    obtain ⟨h1, h2⟩ := roundOf_spec nR hR x hpos k
    set r := roundOf nR hR x hpos k
    have hb : bnd nR hR x (r + 1) = bnd nR hR x r + nR (baseSeq nR hR x r) := rfl
    set k' := bnd nR hR x (r + 1)
    have hkk' : k ≤ k' := by omega
    rcases propagates succ (car ψ) (evt ψ) (grd ψ) (hlink ψ hψ) (chain nR hR x hpos) k k' hkk'
        (fun j _ => hchainS j) hcar with hin | ⟨hcarn, hgrd⟩
    · obtain ⟨j, hkj, _, hej, hgj⟩ := hin
      exact ⟨j, hkj, hej, hgj⟩
    · have hk'eq : chain nR hR x hpos k' = baseSeq nR hR x (r + 1) := by
        have := chain_eq nR hR x hpos hR0 (r + 1) 0 (Nat.zero_le _)
        rw [Nat.add_zero, hR0] at this
        exact this
      rw [hk'eq] at hcarn
      obtain ⟨j0, hj0, hj0n, hej, hgj⟩ := (hspec _ (hbase (r + 1))).2 ψ hψ hcarn
      have hseg := chain_eq nR hR x hpos hR0 (r + 1)
      refine ⟨k' + j0, by omega, ?_, ?_⟩
      · rw [hseg j0 hj0n]; exact hej
      · intro s hks hsj
        rcases Nat.lt_or_ge k' s with hlt | hge
        · have hs : s = k' + (s - k') := by omega
          rw [hs, hseg (s - k') (by omega)]
          exact hgj (s - k') (by omega) (by omega)
        · exact hgrd s hks hge

end Dovetail


/-! ## The product layer, ported VERBATIM from `realizable-type-certificate.lean`

`ClType`, `ProdState`, `locPred`, `linkPred`, `locCoh`, `untlLink`, `coh`, the unfolding lemma
`coh_iff`, the reading lemmas `loc_*`/`link_untl`, and the shape tests `isUntl`/`isSnce`/
`isBox`/`isStab`/`argsOf`/`argOf`.  Nothing in this section is new and nothing is changed:
`linkPred` constrains the forward-until arm and NOTHING ELSE -- in particular no backward arm,
which is the fact item (c) turns on. -/

/-- The closure component: a subset of `plusSubformulaClosure φ`. -/
abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

/-- The product carrier: the object paired with the closure component. -/
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

/-- The Hintikka condition for one closure formula at a labelled object state.  The modal arms and
both temporal arms are UNCONSTRAINED -- a deliberate over-approximation, and the reason gate 8 is
NOT ADDRESSED by this relation. -/
def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

/-- The STRICT-until unfolding across one step.  Every arm other than the
forward-until one is UNCONSTRAINED -- again a deliberate over-approximation; in particular the
BACKWARD temporal arm is constrained by nothing here, so the past direction is untouched and no
backward propagation theorem is available from this relation. -/
def linkPred (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.untl g e) =>
      decide (ψ ∈ T) == (decide (e ∈ T') || (decide (g ∈ T') && decide (ψ ∈ T')))
  | _ => true

/-- Local coherence of a product state: the Hintikka condition at every closure formula. -/
def locCoh {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (x : ProdState Q φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true)

/-- The link condition across one step: the strict-until unfolding at every closure formula. -/
def untlLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPred T.1 T'.1 ψ = true)

/-- **The LOCAL coherence relation**, with NO fulfilment clause. -/
def coh {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && pend x.1 && pend y.1 && locCoh lab φ x && locCoh lab φ y &&
    untlLink φ x.2 y.2

-- linter.unusedDecidableInType / linter.unusedFintypeInType, scoped to this declaration.
-- A deletion trial of the suppressions reports `coh_iff`'s TYPE not mentioning `[Fintype Q]` or
-- `[DecidableEq Q]`, and its one-line `simp` proof not using either. The binders are kept rather
-- than dropped because the statement is ported verbatim from the compiled oracle
-- `certificate-sufficiency-dovetailing.lean`, and dropping a hypothesis changes the statement.
-- The matching `unusedArguments` env_linter finding is exempted in `scripts/nolints.json` for the
-- same reason.
set_option linter.unusedDecidableInType false in
set_option linter.unusedFintypeInType false in
/-- **The unfolding lemma.**  The workhorse for every hand proof below. -/
theorem coh_iff {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x y : ProdState Q φ) :
    coh step pend lab φ x y = true ↔
      step x.1 y.1 = true ∧ pend x.1 = true ∧ pend y.1 = true ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab y.1 y.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, linkPred x.2.1 y.2.1 ψ = true) := by
  simp [coh, locCoh, untlLink, Bool.and_eq_true, and_assoc]

theorem loc_bot {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (hm : PlusFormula.bot ∈ plusSubformulaClosure φ) : PlusFormula.bot ∉ T := by
  have h1 := h _ hm
  simp only [locPred, decide_eq_true_eq] at h1
  exact h1

theorem loc_atom {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (a : Atom) (hm : PlusFormula.atom a ∈ plusSubformulaClosure φ) :
    (PlusFormula.atom a ∈ T ↔ lab q a = true) := by
  have h1 := h _ hm
  simp only [locPred, beq_iff_eq] at h1
  by_cases hmem : PlusFormula.atom a ∈ T <;> simp_all

theorem loc_imp {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (α β : PlusFormula) (hm : α.imp β ∈ plusSubformulaClosure φ) :
    (α.imp β ∈ T ↔ (α ∉ T ∨ β ∈ T)) := by
  have h1 := h _ hm
  simp only [locPred, beq_iff_eq] at h1
  by_cases h2 : α.imp β ∈ T <;> by_cases h3 : α ∈ T <;> by_cases h4 : β ∈ T <;> simp_all

theorem loc_neg {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (hbot : PlusFormula.bot ∉ T) (α : PlusFormula)
    (hm : α.neg ∈ plusSubformulaClosure φ) : (α.neg ∈ T ↔ α ∉ T) := by
  have h1 : α.neg ∈ T ↔ (α ∉ T ∨ PlusFormula.bot ∈ T) := loc_imp h α .bot hm
  rw [h1]; tauto

theorem link_untl {T T' : Finset PlusFormula} {φ : PlusFormula}
    (h : ∀ ψ ∈ plusSubformulaClosure φ, linkPred T T' ψ = true)
    (g e : PlusFormula) (hm : PlusFormula.untl g e ∈ plusSubformulaClosure φ) :
    (PlusFormula.untl g e ∈ T ↔ (e ∈ T' ∨ (g ∈ T' ∧ PlusFormula.untl g e ∈ T'))) := by
  have h1 := h _ hm
  simp only [linkPred, beq_iff_eq] at h1
  by_cases h2 : PlusFormula.untl g e ∈ T <;> by_cases h3 : e ∈ T' <;> by_cases h4 : g ∈ T' <;>
    by_cases h5 : PlusFormula.untl g e ∈ T' <;> simp_all

/-- The shape test for a forward strict-until formula. -/
def isUntl : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

/-- The shape test for a backward strict-since formula. -/
def isSnce : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

/-- The shape test for a `□` formula. -/
def isBox : PlusFormula → Bool
  | .box _ => true
  | _ => false

/-- The shape test for a `⊡` formula. -/
def isStab : PlusFormula → Bool
  | .stab _ => true
  | _ => false

/-- The guard and the event of a binary temporal formula, in that order. -/
def argsOf : PlusFormula → PlusFormula × PlusFormula
  | .untl g e => (g, e)
  | .snce g e => (g, e)
  | _ => (.bot, .bot)

/-- The argument of a unary modal formula. -/
def argOf : PlusFormula → PlusFormula
  | .box σ => σ
  | .stab σ => σ
  | _ => .bot

theorem isUntl_eq {ψ : PlusFormula} (h : isUntl ψ = true) : ∃ g e, ψ = .untl g e := by
  cases ψ <;> first | exact ⟨_, _, rfl⟩ | simp [isUntl] at h

theorem isSnce_eq {ψ : PlusFormula} (h : isSnce ψ = true) : ∃ g e, ψ = .snce g e := by
  cases ψ <;> first | exact ⟨_, _, rfl⟩ | simp [isSnce] at h

/-! ## The certificate, with its relation as a PARAMETER

`realizable-type-certificate.lean` states the seven fields at the fixture, over `coh6`.  They are
restated here field for field with the fixture parameters abstracted and the relation `rel` made
explicit, so that ONE definition covers the compiled certificate (`rel := coh step pend lab φ`,
which at the fixture is `coh6`) and the strengthened one of item (c) (`rel := cohBi …`).  The
names are kept; a reader can diff this section against that file's. -/

section Certificate

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

/-- The successors of `x` INSIDE `R`. -/
def succR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Finset (ProdState Q φ) :=
  R.filter (fun y => rel x y = true)

/-- The predecessors of `x` INSIDE `R`. -/
def preR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Finset (ProdState Q φ) :=
  R.filter (fun y => rel y x = true)

/-- The relation with both endpoints confined to `R`. -/
def cohR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x y : ProdState Q φ) : Bool :=
  rel x y && decide (x ∈ R) && decide (y ∈ R)

/-- Condition (1). -/
def certLoc (lab : Q → Atom → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, locCoh lab φ x = true)

/-- Condition (2): a successor AND a predecessor inside `R`. -/
def certBiInf (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, 0 < (succR rel R x).card ∧ 0 < (preR rel R x).card)

/-- Condition (3): EXISTENTIAL forward discharge inside `R`. -/
def certFwd (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
    x ∈ euLfp R (succR rel R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                              (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- Condition (4): the past-directed mirror, through `preR`. -/
def certBwd (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isSnce ψ = true →
    x ∈ euLfp R (preR rel R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                             (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- The `⊡` acceptance test at one product state for one closure formula: the `stab` letter's
bit agreed against the fibre the candidate set gives that state. -/
def stabOk (R : Finset (ProdState Q φ)) (x : ProdState Q φ) (ψ : PlusFormula) : Bool :=
  decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, y.1 = x.1 → argOf ψ ∈ y.2.1)

/-- Condition (5). -/
def certStab (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isStab ψ = true → stabOk R x ψ = true)

/-- Condition (6). -/
def certBox (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isBox ψ = true →
    (decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, argOf ψ ∈ y.2.1)) = true)

/-- **THE CERTIFICATE**, over its relation. -/
def certAdm (lab : Q → Atom → Bool) (rel : ProdState Q φ → ProdState Q φ → Bool)
    (R : Finset (ProdState Q φ)) : Bool :=
  certLoc lab R && certBiInf rel R && certFwd rel R && certBwd rel R && certStab R && certBox R

theorem certAdm_iff (lab : Q → Atom → Bool) (rel : ProdState Q φ → ProdState Q φ → Bool)
    (R : Finset (ProdState Q φ)) :
    certAdm lab rel R = true ↔ certLoc lab R = true ∧ certBiInf rel R = true ∧
      certFwd rel R = true ∧ certBwd rel R = true ∧ certStab R = true ∧ certBox R = true := by
  simp [certAdm, Bool.and_eq_true, and_assoc]

/-! ## Item (a), forward arm: the compiled certificate's conditions (2) and (3) give a forward
chain fulfilling every `untl` obligation at every position

This is `exists_dovetail_chain` at `succR (coh …) R`, with the one-step link supplied by
`link_untl` -- the forward arm `linkPred` DOES constrain -- and the discharge paths by condition
(3) through `eu_mem_lfp_iff_exists_path`.  It is LABELLED FORWARD-ONLY: it says nothing about
`snce` obligations and nothing about any position before `x`. -/

/-- **FORWARD-ONLY SUFFICIENCY**, for ANY relation that implies the compiled one -- `coh`
itself, and `cohBi` below. -/
theorem forward_chain_of_certFwd_rel (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (rel : ProdState Q φ → ProdState Q φ → Bool)
    (hrel : ∀ x y, rel x y = true → coh step pend lab φ x y = true)
    (R : Finset (ProdState Q φ))
    (hbi : certBiInf rel R = true) (hfwd : certFwd rel R = true)
    (x : ProdState Q φ) (hx : x ∈ R) :
    ∃ f : ℕ → ProdState Q φ, f 0 = x ∧
      (∀ k, cohR rel R (f k) (f (k + 1)) = true) ∧
      ∀ k (g e : PlusFormula), PlusFormula.untl g e ∈ (f k).2.1 →
        ∃ j, k < j ∧ e ∈ (f j).2.1 ∧ ∀ r, k < r → r < j → g ∈ (f r).2.1 := by
  have hV : ∀ v ∈ R, ∀ w ∈ succR rel R v, w ∈ R :=
    fun v _ w hw => (Finset.mem_filter.mp hw).1
  have hne : ∀ v ∈ R, (succR rel R v).Nonempty := by
    intro v hv
    simp only [certBiInf, decide_eq_true_eq] at hbi
    exact Finset.card_pos.mp (hbi v hv).1
  have hlink : ∀ ψ ∈ (plusSubformulaClosure φ).toList,
      LinkStep (succR rel R) (fun v => isUntl ψ = true ∧ ψ ∈ v.2.1)
        (fun w => decide ((argsOf ψ).2 ∈ w.2.1)) (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) := by
    intro ψ hψ v w hw hc
    obtain ⟨hu, hmem⟩ := hc
    rw [Finset.mem_toList] at hψ
    obtain ⟨g, e, rfl⟩ := isUntl_eq hu
    have hcoh : coh step pend lab φ v w = true := hrel v w (Finset.mem_filter.mp hw).2
    have hl := ((coh_iff step pend lab φ v w).mp hcoh).2.2.2.2.2
    rcases (link_untl hl g e hψ).mp hmem with he | ⟨hg, hc⟩
    · exact Or.inl (decide_eq_true he)
    · exact Or.inr ⟨decide_eq_true hg, rfl, hc⟩
  have hdis : ∀ ψ ∈ (plusSubformulaClosure φ).toList, ∀ v ∈ R,
      (isUntl ψ = true ∧ ψ ∈ v.2.1) →
      HasDischargePath R (succR rel R)
        (fun w => decide ((argsOf ψ).2 ∈ w.2.1)) (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) v := by
    intro ψ _ v hv hc
    obtain ⟨hu, hmem⟩ := hc
    simp only [certFwd, decide_eq_true_eq] at hfwd
    exact (eu_mem_lfp_iff_exists_path R _ _ _ v).mp (hfwd v hv ψ hmem hu)
  obtain ⟨f, hf0, hfV, hfs, hful⟩ := exists_dovetail_chain R (succR rel R)
    (fun ψ v => isUntl ψ = true ∧ ψ ∈ v.2.1) (fun ψ w => decide ((argsOf ψ).2 ∈ w.2.1))
    (fun ψ w => decide ((argsOf ψ).1 ∈ w.2.1)) hV hne (plusSubformulaClosure φ).toList
    hlink hdis x hx
  refine ⟨f, hf0, ?_, ?_⟩
  · intro k
    simp only [cohR, Bool.and_eq_true, decide_eq_true_eq]
    exact ⟨⟨(Finset.mem_filter.mp (hfs k)).2, hfV k⟩, (Finset.mem_filter.mp (hfs k)).1⟩
  · intro k g e hmem
    have hcl : PlusFormula.untl g e ∈ plusSubformulaClosure φ :=
      Finset.mem_powerset.mp (f k).2.2 hmem
    obtain ⟨j, hkj, hej, hgj⟩ := hful k _ (Finset.mem_toList.mpr hcl) ⟨rfl, hmem⟩
    exact ⟨j, hkj, of_decide_eq_true hej, fun r h1 h2 => of_decide_eq_true (hgj r h1 h2)⟩

/-- **FORWARD-ONLY SUFFICIENCY, for the compiled relation and the whole certificate.**  Every
member of an admissible candidate set starts a forward `cohR`-chain fulfilling every `untl`
obligation at every position.  LABELLED FORWARD-ONLY: nothing is said about `snce`, nothing about
any position before `x`. -/
theorem forward_chain_of_certAdm (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (R : Finset (ProdState Q φ)) (hadm : certAdm lab (coh step pend lab φ) R = true)
    (x : ProdState Q φ) (hx : x ∈ R) :
    ∃ f : ℕ → ProdState Q φ, f 0 = x ∧
      (∀ k, cohR (coh step pend lab φ) R (f k) (f (k + 1)) = true) ∧
      ∀ k (g e : PlusFormula), PlusFormula.untl g e ∈ (f k).2.1 →
        ∃ j, k < j ∧ e ∈ (f j).2.1 ∧ ∀ r, k < r → r < j → g ∈ (f r).2.1 := by
  obtain ⟨-, hbi, hfwd, -, -, -⟩ := (certAdm_iff lab _ R).mp hadm
  exact forward_chain_of_certFwd_rel step pend lab _ (fun _ _ h => h) R hbi hfwd x hx

/-! ## Item (c): the backward arm, constrained

`linkPredB` is the strict-since unfolding of the LATER type in terms of the EARLIER one -- the
mirror of `linkPred` -- and `cohBi` is `coh` with that arm added.  `link_snce` is the reading
lemma, the mirror of `link_untl`; with it the backward instance of `exists_dovetail_chain` goes
through at `preR`.  `cohBi_eq_coh_of_snce_free` is the cost of the strengthening elsewhere: on a
`snce`-free closure -- the fixture's `chi`, by `chi_closure_box_snce_stab_free` in the compiled
certificate probe -- the added arm is vacuous and the two relations are the SAME function, so
every fixture result stands verbatim. -/

end Certificate

/-- The BACKWARD arm `linkPred` lacks. -/
def linkPredB (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.snce g e) =>
      decide (ψ ∈ T') == (decide (e ∈ T) || (decide (g ∈ T) && decide (ψ ∈ T)))
  | _ => true

/-- The link condition across one step for the BACKWARD arm: the strict-since unfolding at
every closure formula. The mirror of `untlLink`. -/
def snceLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPredB T.1 T'.1 ψ = true)

/-- **The two-arm local relation**: `coh` with the backward arm. -/
def cohBi {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  coh step pend lab φ x y && snceLink φ x.2 y.2

theorem cohBi_iff {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) :
    cohBi step pend lab φ x y = true ↔
      coh step pend lab φ x y = true ∧
        ∀ ψ ∈ plusSubformulaClosure φ, linkPredB x.2.1 y.2.1 ψ = true := by
  simp [cohBi, snceLink]

theorem link_snce {T T' : Finset PlusFormula} {φ : PlusFormula}
    (h : ∀ ψ ∈ plusSubformulaClosure φ, linkPredB T T' ψ = true)
    (g e : PlusFormula) (hm : PlusFormula.snce g e ∈ plusSubformulaClosure φ) :
    (PlusFormula.snce g e ∈ T' ↔ (e ∈ T ∨ (g ∈ T ∧ PlusFormula.snce g e ∈ T))) := by
  have h1 := h _ hm
  simp only [linkPredB, beq_iff_eq] at h1
  by_cases h2 : PlusFormula.snce g e ∈ T' <;> by_cases h3 : e ∈ T <;> by_cases h4 : g ∈ T <;>
    by_cases h5 : PlusFormula.snce g e ∈ T <;> simp_all

/-- **The cost elsewhere: none on a `snce`-free closure.** -/
theorem cohBi_eq_coh_of_snce_free {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hfree : ∀ ψ ∈ plusSubformulaClosure φ, isSnce ψ = false) (x y : ProdState Q φ) :
    cohBi step pend lab φ x y = coh step pend lab φ x y := by
  have hs : snceLink φ x.2 y.2 = true := by
    simp only [snceLink, decide_eq_true_eq]
    intro ψ hψ
    have hψ' := hfree ψ hψ
    cases ψ <;> simp [linkPredB, isSnce] at hψ' ⊢
  simp [cohBi, hs]

/-! ## The IDLE-EXTENDED relation

`coh` and `cohBi` demand `pend` at both endpoints, so neither relates a pair in which either
endpoint is idle. `cohIdle` is `cohBi` with those two conjuncts DROPPED and nothing else
changed.

Why the all-pending relation cannot be the ladder's:
`Probe816.exists_idle_of_rlad_ray` and `Probe816.no_rlad_ray_of_pending_forever`
(`specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`) show that every forward
`Rlad` ray goes idle, so a chain in which every state is pending is never the object projection
of a ladder history. The certified chains of record are region-interior; `cohIdle` is the
relation whose chains can cross an idle run.

This definition states NO ladder consequence. Nothing below relates `cohIdle` to `Rlad`, to
`RladAdm`, or to any realization statement: that composition is the content of the soundness and
completeness obligations and is not discharged here. -/
/-- **The IDLE-EXTENDED relation**: `cohBi` with both `pend` conjuncts dropped and nothing else
changed. It does not take `pend` at all, because dropping those two conjuncts removes the
relation's dependence on the pending bit entirely. States NO ladder consequence. -/
def cohIdle {Q : Type} (step : Q → Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && locCoh lab φ x && locCoh lab φ y && untlLink φ x.2 y.2 &&
    snceLink φ x.2 y.2

/-- `cohIdle` is exactly `cohBi` once both endpoints are pending: dropping the two `pend`
conjuncts is the ONLY difference between the two relations. -/
theorem cohIdle_eq_cohBi_of_pend {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x y : ProdState Q φ)
    (hx : pend x.1 = true) (hy : pend y.1 = true) :
    cohIdle step lab φ x y = cohBi step pend lab φ x y := by
  simp [cohIdle, cohBi, coh, hx, hy, Bool.and_assoc]

/-- Every `cohBi` edge is a `cohIdle` edge: the idle-extended relation is WEAKER, and the
inclusion is strict (a pair with an idle endpoint is `cohIdle` and never `cohBi`). -/
theorem cohIdle_of_cohBi {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x y : ProdState Q φ)
    (h : cohBi step pend lab φ x y = true) : cohIdle step lab φ x y = true := by
  have hx : pend x.1 = true := by
    simp only [cohBi, coh, Bool.and_eq_true] at h; tauto
  have hy : pend y.1 = true := by
    simp only [cohBi, coh, Bool.and_eq_true] at h; tauto
  rw [cohIdle_eq_cohBi_of_pend step pend lab φ x y hx hy]
  exact h

-- `cohIdle` does not mention `pend` at all, and that is the point: `coh`'s two `pend` conjuncts
-- are the ONLY thing dropped, and dropping them removes the relation's dependence on the pending
-- bit entirely, so the parameter is gone from the signature rather than carried unused.

section Backward

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

/-- **BACKWARD SUFFICIENCY, for the strengthened relation**: conditions (2) and (4) over `cohBi`
give a past-directed chain fulfilling every `snce` obligation at every position.  The index `k`
counts steps INTO THE PAST.  This is `exists_dovetail_chain` at `preR`, with the link from
`link_snce` -- the arm `cohBi` has and `coh` does not. -/
theorem backward_chain_of_certBwd (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (R : Finset (ProdState Q φ))
    (hbi : certBiInf (cohBi step pend lab φ) R = true)
    (hbwd : certBwd (cohBi step pend lab φ) R = true)
    (x : ProdState Q φ) (hx : x ∈ R) :
    ∃ b : ℕ → ProdState Q φ, b 0 = x ∧
      (∀ k, cohR (cohBi step pend lab φ) R (b (k + 1)) (b k) = true) ∧
      ∀ k (g e : PlusFormula), PlusFormula.snce g e ∈ (b k).2.1 →
        ∃ j, k < j ∧ e ∈ (b j).2.1 ∧ ∀ r, k < r → r < j → g ∈ (b r).2.1 := by
  have hV : ∀ v ∈ R, ∀ w ∈ preR (cohBi step pend lab φ) R v, w ∈ R :=
    fun v _ w hw => (Finset.mem_filter.mp hw).1
  have hne : ∀ v ∈ R, (preR (cohBi step pend lab φ) R v).Nonempty := by
    intro v hv
    simp only [certBiInf, decide_eq_true_eq] at hbi
    exact Finset.card_pos.mp (hbi v hv).2
  have hlink : ∀ ψ ∈ (plusSubformulaClosure φ).toList,
      LinkStep (preR (cohBi step pend lab φ) R) (fun v => isSnce ψ = true ∧ ψ ∈ v.2.1)
        (fun w => decide ((argsOf ψ).2 ∈ w.2.1)) (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) := by
    intro ψ hψ v w hw hc
    obtain ⟨hu, hmem⟩ := hc
    rw [Finset.mem_toList] at hψ
    obtain ⟨g, e, rfl⟩ := isSnce_eq hu
    have hcoh : cohBi step pend lab φ w v = true := (Finset.mem_filter.mp hw).2
    have hl := ((cohBi_iff step pend lab φ w v).mp hcoh).2
    rcases (link_snce hl g e hψ).mp hmem with he | ⟨hg, hc⟩
    · exact Or.inl (decide_eq_true he)
    · exact Or.inr ⟨decide_eq_true hg, rfl, hc⟩
  have hdis : ∀ ψ ∈ (plusSubformulaClosure φ).toList, ∀ v ∈ R,
      (isSnce ψ = true ∧ ψ ∈ v.2.1) →
      HasDischargePath R (preR (cohBi step pend lab φ) R)
        (fun w => decide ((argsOf ψ).2 ∈ w.2.1)) (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) v := by
    intro ψ _ v hv hc
    obtain ⟨hu, hmem⟩ := hc
    simp only [certBwd, decide_eq_true_eq] at hbwd
    exact (eu_mem_lfp_iff_exists_path R _ _ _ v).mp (hbwd v hv ψ hmem hu)
  obtain ⟨b, hb0, hbV, hbs, hful⟩ := exists_dovetail_chain R (preR (cohBi step pend lab φ) R)
    (fun ψ v => isSnce ψ = true ∧ ψ ∈ v.2.1) (fun ψ w => decide ((argsOf ψ).2 ∈ w.2.1))
    (fun ψ w => decide ((argsOf ψ).1 ∈ w.2.1)) hV hne (plusSubformulaClosure φ).toList
    hlink hdis x hx
  refine ⟨b, hb0, ?_, ?_⟩
  · intro k
    simp only [cohR, Bool.and_eq_true, decide_eq_true_eq]
    exact ⟨⟨(Finset.mem_filter.mp (hbs k)).2, (Finset.mem_filter.mp (hbs k)).1⟩, hbV k⟩
  · intro k g e hmem
    have hcl : PlusFormula.snce g e ∈ plusSubformulaClosure φ :=
      Finset.mem_powerset.mp (b k).2.2 hmem
    obtain ⟨j, hkj, hej, hgj⟩ := hful k _ (Finset.mem_toList.mpr hcl) ⟨rfl, hmem⟩
    exact ⟨j, hkj, of_decide_eq_true hej, fun r h1 h2 => of_decide_eq_true (hgj r h1 h2)⟩

end Backward

/-! ## Realizability at the label level, over `ℤ`

What the research round's section 6 claims the certificate's conditions imply: every member of
the candidate set lies on a BI-INFINITE `cohR`-chain along which every `untl` obligation at every
position is delivered strictly later under its guard, and every `snce` obligation strictly
earlier.  This is the label-level reading of `PlusTruthAt`'s two temporal clauses -- the condition
`evRay_unfulfilled` (`realizable-type-adequacy-gap.lean`) negates -- and NOT semantic
realizability through `tpOf`/`cellAt`, which no declaration of this file mentions. -/

section Realizes

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

/-- A bi-infinite `rel`-chain lying inside the candidate set `R`. -/
def IsChain (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z, cohR rel R (f z) (f (z + 1)) = true

/-- Forward fulfilment along a bi-infinite chain: every `untl` obligation carried at every
position is delivered at some later position, with the guard holding throughout. -/
def FwdFulfilling (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z (g e : PlusFormula), PlusFormula.untl g e ∈ (f z).2.1 →
    ∃ j, z < j ∧ e ∈ (f j).2.1 ∧ ∀ r, z < r → r < j → g ∈ (f r).2.1

/-- Backward fulfilment along a bi-infinite chain: the mirror of `FwdFulfilling` for `snce`. -/
def BwdFulfilling (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z (g e : PlusFormula), PlusFormula.snce g e ∈ (f z).2.1 →
    ∃ j, j < z ∧ e ∈ (f j).2.1 ∧ ∀ r, j < r → r < z → g ∈ (f r).2.1

/-- **Label-level realizability of `x` inside `R`.** -/
def Realizes (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Prop :=
  ∃ f : ℤ → ProdState Q φ, f 0 = x ∧ IsChain rel R f ∧ FwdFulfilling f ∧ BwdFulfilling f

end Realizes

/-! ## Item (c), the REPAIR: the strengthened certificate IS sufficient

With the backward arm constrained, the forward and backward chains of
`forward_chain_of_certFwd_rel` and `backward_chain_of_certBwd` splice at `x` into a bi-infinite
chain, and an obligation on the wrong side of `0` is carried across `0` by `propagates` -- forward
along the backward half for an `untl`, backward along the forward half for a `snce` -- and then
discharged by the half that owns it.  Both crossings need the arm in question, which is why this
theorem is for `cohBi` and `sufficiency_refuted` is for `coh`. -/

section Splice

variable {Q : Type} {φ : PlusFormula}

/-- The two-sided chain spliced from a forward and a backward chain. -/
def splice (F B : ℕ → ProdState Q φ) (z : ℤ) : ProdState Q φ :=
  if 0 ≤ z then F z.toNat else B (-z).toNat

theorem splice_ofNat (F B : ℕ → ProdState Q φ) (n : ℕ) : splice F B n = F n := by
  simp [splice]

theorem splice_nonneg (F B : ℕ → ProdState Q φ) (z : ℤ) (hz : 0 ≤ z) :
    splice F B z = F z.toNat := by
  simp [splice, hz]

theorem splice_negNat (F B : ℕ → ProdState Q φ) (h0 : F 0 = B 0) (n : ℕ) :
    splice F B (-(n : ℤ)) = B n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [splice, h0]
  · have h : ¬ (0 : ℤ) ≤ -(n : ℤ) := by omega
    rw [splice, if_neg h]
    simp

theorem splice_neg (F B : ℕ → ProdState Q φ) (h0 : F 0 = B 0) (z : ℤ) (hz : z ≤ 0) :
    splice F B z = B (-z).toNat := by
  conv_lhs => rw [show z = -(((-z).toNat : ℕ) : ℤ) by omega]
  exact splice_negNat F B h0 _

end Splice

section Full

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

/-- **SUFFICIENCY, for the STRENGTHENED relation.**  Every member of a candidate set the
two-arm certificate accepts is label-level realizable inside it. -/
theorem realizes_of_certAdm_cohBi (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (R : Finset (ProdState Q φ))
    (hadm : certAdm lab (cohBi step pend lab φ) R = true)
    (x : ProdState Q φ) (hx : x ∈ R) : Realizes (cohBi step pend lab φ) R x := by
  obtain ⟨-, hbi, hfwd, hbwd, -, -⟩ := (certAdm_iff lab _ R).mp hadm
  obtain ⟨F, hF0, hFc, hFf⟩ := forward_chain_of_certFwd_rel step pend lab
    (cohBi step pend lab φ) (fun x y h => ((cohBi_iff step pend lab φ x y).mp h).1) R hbi hfwd x hx
  obtain ⟨B, hB0, hBc, hBf⟩ := backward_chain_of_certBwd step pend lab R hbi hbwd x hx
  have h0 : F 0 = B 0 := by rw [hF0, hB0]
  have hchain : IsChain (cohBi step pend lab φ) R (splice F B) := by
    intro z
    rcases le_or_gt 0 z with hz | hz
    · rw [splice_nonneg F B z hz, splice_nonneg F B (z + 1) (by omega),
        show (z + 1).toNat = z.toNat + 1 by omega]
      exact hFc z.toNat
    · rw [splice_neg F B h0 z (le_of_lt hz),
        show z + 1 = -((((-z).toNat - 1 : ℕ) : ℤ)) by omega, splice_negNat F B h0]
      have h := hBc ((-z).toNat - 1)
      rwa [show (-z).toNat - 1 + 1 = (-z).toNat by omega] at h
  refine ⟨splice F B, by simp [splice, hF0], hchain, ?_, ?_⟩
  · intro z g e hmem
    rcases le_or_gt 0 z with hz | hz
    · rw [splice_nonneg F B z hz] at hmem
      obtain ⟨j, hj, hej, hgj⟩ := hFf z.toNat g e hmem
      refine ⟨j, by omega, by rw [splice_ofNat]; exact hej, ?_⟩
      intro r h1 h2
      rw [splice_nonneg F B r (by omega)]
      exact hgj r.toNat (by omega) (by omega)
    · have hs : ∀ k, k < (-z).toNat →
          (fun i : ℕ => splice F B (z + i)) (k + 1) ∈
            succR (cohBi step pend lab φ) R ((fun i : ℕ => splice F B (z + i)) k) := by
        intro k _
        have h := hchain (z + k)
        simp only [cohR, Bool.and_eq_true, decide_eq_true_eq] at h
        refine Finset.mem_filter.mpr ⟨?_, ?_⟩
        · change splice F B (z + ((k + 1 : ℕ) : ℤ)) ∈ R
          rw [show z + ((k + 1 : ℕ) : ℤ) = z + k + 1 by push_cast; ring]
          exact h.2
        · change cohBi step pend lab φ (splice F B (z + k))
              (splice F B (z + ((k + 1 : ℕ) : ℤ))) = true
          rw [show z + ((k + 1 : ℕ) : ℤ) = z + k + 1 by push_cast; ring]
          exact h.1.1
      have hlink : LinkStep (succR (cohBi step pend lab φ) R)
          (fun v => PlusFormula.untl g e ∈ v.2.1)
          (fun w => decide (e ∈ w.2.1)) (fun w => decide (g ∈ w.2.1)) := by
        intro v w hw hc
        have hcoh := ((cohBi_iff step pend lab φ v w).mp (Finset.mem_filter.mp hw).2).1
        have hl := ((coh_iff step pend lab φ v w).mp hcoh).2.2.2.2.2
        have hcl : PlusFormula.untl g e ∈ plusSubformulaClosure φ :=
          Finset.mem_powerset.mp v.2.2 hc
        rcases (link_untl hl g e hcl).mp hc with he | ⟨hg, hc'⟩
        · exact Or.inl (decide_eq_true he)
        · exact Or.inr ⟨decide_eq_true hg, hc'⟩
      have hs0 : PlusFormula.untl g e ∈ ((fun i : ℕ => splice F B (z + i)) 0).2.1 := by
        change PlusFormula.untl g e ∈ (splice F B (z + ((0 : ℕ) : ℤ))).2.1
        rw [show z + ((0 : ℕ) : ℤ) = z by simp]
        exact hmem
      rcases propagates (succR (cohBi step pend lab φ) R) _ _ _ hlink
          (fun i : ℕ => splice F B (z + i)) 0 (-z).toNat (Nat.zero_le _) hs hs0
        with hin | ⟨hcar, hgrd⟩
      · obtain ⟨i, hi0, _, hei, hgi⟩ := hin
        refine ⟨z + i, by omega, of_decide_eq_true hei, ?_⟩
        intro r h1 h2
        have h : g ∈ (splice F B (z + (((r - z).toNat : ℕ) : ℤ))).2.1 :=
          of_decide_eq_true (hgi (r - z).toNat (by omega) (by omega))
        rwa [show z + (((r - z).toNat : ℕ) : ℤ) = r by omega] at h
      · have hcar' : PlusFormula.untl g e ∈ (F 0).2.1 := by
          have h : PlusFormula.untl g e ∈ (splice F B (z + (((-z).toNat : ℕ) : ℤ))).2.1 := hcar
          rwa [show z + (((-z).toNat : ℕ) : ℤ) = ((0 : ℕ) : ℤ) by omega, splice_ofNat] at h
        obtain ⟨j, hj, hej, hgj⟩ := hFf 0 g e hcar'
        refine ⟨j, by omega, by rw [splice_ofNat]; exact hej, ?_⟩
        intro r h1 h2
        rcases le_or_gt r 0 with hr | hr
        · have h : g ∈ (splice F B (z + (((r - z).toNat : ℕ) : ℤ))).2.1 :=
            of_decide_eq_true (hgrd (r - z).toNat (by omega) (by omega))
          rwa [show z + (((r - z).toNat : ℕ) : ℤ) = r by omega] at h
        · rw [splice_nonneg F B r (by omega)]
          exact hgj r.toNat (by omega) (by omega)
  · intro z g e hmem
    rcases le_or_gt z 0 with hz | hz
    · rw [splice_neg F B h0 z hz] at hmem
      obtain ⟨j, hj, hej, hgj⟩ := hBf (-z).toNat g e hmem
      refine ⟨-(j : ℤ), by omega, by rw [splice_negNat F B h0]; exact hej, ?_⟩
      intro r h1 h2
      rw [splice_neg F B h0 r (by omega)]
      exact hgj (-r).toNat (by omega) (by omega)
    · have hs : ∀ k, k < z.toNat →
          (fun i : ℕ => splice F B (z - i)) (k + 1) ∈
            preR (cohBi step pend lab φ) R ((fun i : ℕ => splice F B (z - i)) k) := by
        intro k _
        have h := hchain (z - k - 1)
        rw [show z - k - 1 + 1 = z - k by ring] at h
        simp only [cohR, Bool.and_eq_true, decide_eq_true_eq] at h
        refine Finset.mem_filter.mpr ⟨?_, ?_⟩
        · change splice F B (z - ((k + 1 : ℕ) : ℤ)) ∈ R
          rw [show z - ((k + 1 : ℕ) : ℤ) = z - k - 1 by push_cast; ring]
          exact h.1.2
        · change cohBi step pend lab φ (splice F B (z - ((k + 1 : ℕ) : ℤ)))
              (splice F B (z - k)) = true
          rw [show z - ((k + 1 : ℕ) : ℤ) = z - k - 1 by push_cast; ring]
          exact h.1.1
      have hlink : LinkStep (preR (cohBi step pend lab φ) R)
          (fun v => PlusFormula.snce g e ∈ v.2.1)
          (fun w => decide (e ∈ w.2.1)) (fun w => decide (g ∈ w.2.1)) := by
        intro v w hw hc
        have hl := ((cohBi_iff step pend lab φ w v).mp (Finset.mem_filter.mp hw).2).2
        have hcl : PlusFormula.snce g e ∈ plusSubformulaClosure φ :=
          Finset.mem_powerset.mp v.2.2 hc
        rcases (link_snce hl g e hcl).mp hc with he | ⟨hg, hc'⟩
        · exact Or.inl (decide_eq_true he)
        · exact Or.inr ⟨decide_eq_true hg, hc'⟩
      have hs0 : PlusFormula.snce g e ∈ ((fun i : ℕ => splice F B (z - i)) 0).2.1 := by
        change PlusFormula.snce g e ∈ (splice F B (z - ((0 : ℕ) : ℤ))).2.1
        rw [show z - ((0 : ℕ) : ℤ) = z by simp]
        exact hmem
      rcases propagates (preR (cohBi step pend lab φ) R) _ _ _ hlink
          (fun i : ℕ => splice F B (z - i)) 0 z.toNat (Nat.zero_le _) hs hs0
        with hin | ⟨hcar, hgrd⟩
      · obtain ⟨i, hi0, _, hei, hgi⟩ := hin
        refine ⟨z - i, by omega, of_decide_eq_true hei, ?_⟩
        intro r h1 h2
        have h : g ∈ (splice F B (z - (((z - r).toNat : ℕ) : ℤ))).2.1 :=
          of_decide_eq_true (hgi (z - r).toNat (by omega) (by omega))
        rwa [show z - (((z - r).toNat : ℕ) : ℤ) = r by omega] at h
      · have hcar' : PlusFormula.snce g e ∈ (B 0).2.1 := by
          have h : PlusFormula.snce g e ∈ (splice F B (z - ((z.toNat : ℕ) : ℤ))).2.1 := hcar
          rwa [show z - ((z.toNat : ℕ) : ℤ) = -((0 : ℕ) : ℤ) by omega, splice_negNat F B h0] at h
        obtain ⟨j, hj, hej, hgj⟩ := hBf 0 g e hcar'
        refine ⟨-(j : ℤ), by omega, by rw [splice_negNat F B h0]; exact hej, ?_⟩
        intro r h1 h2
        rcases lt_or_ge r 0 with hr | hr
        · rw [splice_neg F B h0 r (le_of_lt hr)]
          exact hgj (-r).toNat (by omega) (by omega)
        · have h : g ∈ (splice F B (z - (((z - r).toNat : ℕ) : ℤ))).2.1 :=
            of_decide_eq_true (hgrd (z - r).toNat (by omega) (by omega))
          rwa [show z - (((z - r).toNat : ℕ) : ℤ) = r by omega] at h

end Full

end FormalSystem.Metalogic.Decidability.RaySummary
