/-
PLACEHOLDER HEADER -- replaced in Phase 6 by the collection's convention.

Compile:
`lake env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace Probe809C

/-! ## The EXISTENTIAL until-fixpoint, at an arbitrary finite graph

The one-quantifier edit of `AUFix` (`WitnessFamily/Sharing/Fulfil.lean`): `∃ w ∈ succ v` in place
of `∀ w ∈ succ v`.  Every lemma below is the `AUFix` original read side by side, with the
quantifier changed and nothing else restructured -- which is the compiled form of the research
round's claim that `step_mono`/`iter`/`iter_stab`/`exists_stab`/`lfp_fixed`/`lfp_least`/
`mem_lfp_iff` read only monotonicity in `X`, never the quantifier.

The section mentions NO formula, NO label and NO object: the operator is language-agnostic, which
is the property that makes it the dual of `AUFix` rather than a fixture device.  The port lives
here rather than in `FormalSystem/` because this task's scope forbids library edits -- a
deliberate consequence, not an oversight. -/

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

end Probe809C

/-! ## Axiom check -/

#print axioms Probe809C.eu_step_mono
#print axioms Probe809C.eu_lfp_fixed
#print axioms Probe809C.eu_mem_lfp_iff
#print axioms Probe809C.eu_lfp_least
