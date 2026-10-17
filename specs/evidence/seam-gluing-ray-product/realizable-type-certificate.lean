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
      show f 0 ∈ euStep V succ isE isG (euIter V succ isE isG 0)
      rw [euStep, Finset.mem_filter]
      exact ⟨hV 0 (by omega), f 1, hs 0 (by omega), Or.inl hE⟩
    · have key : f 1 ∈ euIter V succ isE isG m := by
        have h := ih (fun i => f (i + 1)) hm
          (fun i hi => hV (i + 1) (by omega))
          (fun i hi => hs (i + 1) (by omega))
          (by simpa using hE)
          (fun i h0 hi => hG (i + 1) (by omega) (by omega))
        simpa using h
      show f 0 ∈ euStep V succ isE isG (euIter V succ isE isG m)
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

/-! ## The universal and the existential operator are DIFFERENT: a cycle with an exit

The four-state graph `0 → 1 → 2 → 0` with the exit `0 → 3` and the self-loop `3 → 3` at the only
event state.  This is the mechanism the research round identified as the expensive thing to
rediscover: a pending eventuality on a cycle that has an exit.  The universal operator rejects
vertex `0` because the cycle branch never discharges; the existential operator accepts it because
the exit branch does. -/

def exitSucc : Fin 4 → Finset (Fin 4) := fun i =>
  if i = 0 then {1, 3} else if i = 1 then {2} else if i = 2 then {0} else {3}

def exitIsE : Fin 4 → Bool := fun i => i == 3

def exitIsG : Fin 4 → Bool := fun _ => true

/-! The two fixpoint values on this graph, confirmed by `#eval` before the inequality below was
proved: the UNIVERSAL fixpoint is `{3}` -- only the event state itself -- and the EXISTENTIAL one
is `{0, 1, 2, 3} = Finset.univ`.  Vertex `1` is the sharpest witness: every universal obligation
through it runs `1 → 2 → 0 → 1` forever, while the existential one reaches `3` through `0`. -/
#eval AUFix.lfp Finset.univ exitSucc exitIsE exitIsG
#eval euLfp Finset.univ exitSucc exitIsE exitIsG

/-- **THE UNIVERSAL AND THE EXISTENTIAL FULFILMENT CONDITIONS ARE DIFFERENT**, compiled on a cycle
with an exit.  This is the strength distinction the research round identified as the single most
expensive thing in this line to rediscover: the landed `AUFix` operator and the existential one
built above do NOT agree, so transplanting the universal condition onto the object-closure product
is not a conservative choice of presentation -- it rejects states the existential condition
accepts. -/
theorem au_lfp_ne_eu_lfp_on_exit_graph :
    AUFix.lfp Finset.univ exitSucc exitIsE exitIsG
      ≠ euLfp Finset.univ exitSucc exitIsE exitIsG := by decide

end Probe809C

/-! ## Axiom check -/

#print axioms Probe809C.eu_step_mono
#print axioms Probe809C.eu_lfp_fixed
#print axioms Probe809C.eu_mem_lfp_iff
#print axioms Probe809C.eu_lfp_least
#print axioms Probe809C.eu_mem_lfp_iff_exists_path
#print axioms Probe809C.eu_lfp_eq_empty_of_no_event
#print axioms Probe809C.au_lfp_ne_eu_lfp_on_exit_graph
