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

/-! ## The fixture: the coprime-cycle object, the closure carrier, and LOCAL coherence

Ported from `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` (the
eighteenth probe) and `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`
(the twentieth), which themselves port the object layer from `ladder-joint-index-refutation.lean`
and the carrier from `closure-indexed-periodicity.lean`.  Probes do not import probes, so
everything used below is restated here.  Nothing in this section is new and nothing in it is
changed: `coh` carries exactly the clauses it carries there -- the object step, pending-ness of
BOTH endpoints, local coherence at both endpoints, and the one-step strict-until link -- and NO
fulfilment clause.  The fixture is label-generic, so the frame/regularity/history layer ports
verbatim.  The only edits are the four renames this round fixes: `B`/`C`/`Xpa`/`XXpa` become
`bb`/`cc`/`xpa`/`xxpa`. -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]

def p : PlusFormula := .atom pA
def la : PlusFormula := .atom aA

/-- `k` nested nexts. -/
def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

/-- The pending `a` state as a formula: `p AND l_a`. -/
def pa : PlusFormula := p.and la

/-- The PATTERN the 2-cycle exhibits and the 3-cycle does not. -/
def psi2 : PlusFormula := pa.and (nextPow 2 pa)

/-- Gate 6's constraint: the pattern fails here and at every strictly later instant. -/
def chi : PlusFormula := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg

/-- Object states `(pending?, index)`; pending indices `0 = a`, `1 = b`, `2 = c`, `3 = d`. -/
abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

/-- Pending edges `a → b → c → a` and `a → d → a`. -/
def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

/-- Gate 6's labelling: `d` is given `b`'s letter, so no set of atoms carves out the 2-cycle. -/
def lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else (q.2 == 0)

def a5 : Q5 := (true, 0)
def b5 : Q5 := (true, 1)
def c5 : Q5 := (true, 2)

/-- The closure component: a subset of `plusSubformulaClosure φ`. -/
abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

/-- The product carrier: the object paired with the closure component. -/
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

/-- One step of BACKWARD reachability in the product -- the operator the COUNTDOWN iterates. -/
def prodPreStep {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}
    (pstep : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

/-- The Hintikka condition for one closure formula at a labelled object state.  The modal arms and
both temporal arms are UNCONSTRAINED -- a deliberate over-approximation, and the reason gate 8 is
NOT ADDRESSED by this relation. -/
def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

/-- `PlusTruthAt`'s STRICT-until unfolding across one step.  Every arm other than the
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

/-- The fixture instance: the coprime-cycle object, gate 6's labelling, gate 6's formula. -/
def coh6 : ProdState Q5 chi → ProdState Q5 chi → Bool := coh step5 pend5 lab6 chi

/-- A closure type from a membership list.  Built as a `filter`, never by `decide` on
`Finset.powerset`. -/
def mkT (L : List PlusFormula) : ClType chi :=
  ⟨(plusSubformulaClosure chi).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩

/-- The fibre over the pending `a` state. -/
def Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)

def top : PlusFormula := .imp .bot .bot
def xpa : PlusFormula := nextPow 1 pa
def xxpa : PlusFormula := nextPow 2 pa
def bb : PlusFormula := pa.imp xxpa.neg
def cc : PlusFormula := p.imp la.neg
/-- **The eventuality**: `T U psi2`, strictly in the future.  A member of
`plusSubformulaClosure chi`, because `chi` denies it. -/
def ev : PlusFormula := PlusFormula.untl top psi2
def evnn : PlusFormula := ev.neg.neg
def dd : PlusFormula := psi2.neg.imp evnn

def TaL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, pa, xxpa.neg, p, la]
def TbL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa, cc, p, la.neg]
def TcL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def Ta : ClType chi := mkT TaL
def Tb : ClType chi := mkT TbL
def Tc : ClType chi := mkT TcL

def evTaL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, pa, xxpa.neg, p, la]
def evTbL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa, cc, p, la.neg]
def evTcL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def evTa : ClType chi := mkT evTaL
def evTb : ClType chi := mkT evTbL
def evTc : ClType chi := mkT evTcL

/-! The closure cardinality this round's gate work depends on, confirmed by `#eval` rather than
trusted: `plusSubformulaClosure chi` has 18 members. -/
#eval (plusSubformulaClosure chi).card

/-! ## Reading the local conditions and the link at one closure member

Each lemma below instantiates one of the six conditions `coh_iff` delivers, at a SINGLE closure
formula, with the membership side condition closed by `decide`, and turns the `Bool` equation into
the propositional fact the hand proofs use.  No `decide` below is ever applied to a goal
quantifying over `ClType chi`. -/

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

/-! ## The restriction of the local relation to a candidate set

`cohR R` is LOCAL coherence with both endpoints constrained to lie in `R`.  This is the relation
the certificate's discharge conditions run their fixpoint over, which is the "inside `R`" the
research round insists on: no path outside `R` can discharge anything. -/

def cohR (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi) : Bool :=
  coh6 x y && decide (x ∈ R) && decide (y ∈ R)

/-- **The restriction is a restriction**: it implies the unrestricted relation and both
memberships, and adds nothing.  So every negative result proved through `coh6` transfers to
`cohR R`, and no positive one does. -/
theorem cohR_le_coh (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi)
    (h : cohR R x y = true) : coh6 x y = true ∧ x ∈ R ∧ y ∈ R := by
  simp only [cohR, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1, h.1.2, h.2⟩

/-! ## The chain-to-ray composition theorem

The place the restriction to `R` could silently have failed: an `untl` obligation carried at an
interior position of a `coh`-chain must either be discharged inside the chain, with the guard
holding at every strictly intermediate position, or still be carried at the chain's end with the
guard holding throughout.  Stated generically over the object, the labelling and the formula, so
it covers `coh6` and -- through `cohR_le_coh` -- the restricted relation as well.

No backward mirror is stated: `linkPred` constrains no backward arm, so a backward propagation
theorem is not available from this relation, and claiming one would be a strictly weaker statement
wearing a stronger name. -/

theorem untl_propagates_along_coh {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℕ → ProdState Q φ) (hg : ∀ k, coh step pend lab φ (g k) (g (k + 1)) = true)
    (u e : PlusFormula) (hmem : PlusFormula.untl u e ∈ plusSubformulaClosure φ)
    (i n : ℕ) (hin : i ≤ n) (hcar : PlusFormula.untl u e ∈ (g i).2.1) :
    (∃ j, i < j ∧ j ≤ n ∧ e ∈ (g j).2.1 ∧ ∀ r, i < r → r < j → u ∈ (g r).2.1) ∨
      (PlusFormula.untl u e ∈ (g n).2.1 ∧ ∀ r, i < r → r ≤ n → u ∈ (g r).2.1) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = i + d := ⟨n - i, by omega⟩
  clear hin
  induction d with
  | zero => exact Or.inr ⟨hcar, fun r h1 h2 => absurd h1 (by omega)⟩
  | succ d ih =>
    rcases ih with hleft | hright
    · obtain ⟨j, hij, hjn, hej, hgj⟩ := hleft
      exact Or.inl ⟨j, hij, by omega, hej, hgj⟩
    · obtain ⟨hcarry, hguards⟩ := hright
      have hlink :=
        ((coh_iff step pend lab φ (g (i + d)) (g (i + d + 1))).mp (hg (i + d))).2.2.2.2.2
      rcases (link_untl hlink u e hmem).mp hcarry with he' | ⟨hu', hcarry'⟩
      · exact Or.inl ⟨i + d + 1, by omega, by omega, he', fun r h1 h2 => hguards r h1 (by omega)⟩
      · refine Or.inr ⟨hcarry', ?_⟩
        intro r h1 h2
        rcases Nat.lt_or_ge r (i + d + 1) with hlt | hge
        · exact hguards r h1 (by omega)
        · have hr : r = i + d + 1 := by omega
          subst hr
          exact hu'

/-! ## The certificate presentation: Route B, with seven decidable fields

Route B of the research round -- GUESS the realizable set `R ⊆ ProdState Q5 chi` and CHECK
decidable conditions on it -- rather than Route A, DECIDE realizability, whose missing piece is
generalized-Büchi nonemptiness per state: a nested fixpoint nothing in this tree decides.  The
shape is the one this tree already uses three times (`Cons`'s eleven fields, `AnchorCons`,
`PlusCertifies`'s six checked components), and the `box`/`stab` clauses follow
`BoxOracleSound`/`StabFaithful`/`AnchorCons`: a SPECIFICATION on the candidate datum, deliberately
not a bottom-up computation, which is what breaks the DEFINITIONAL circularity gate 8 names.

Every field below is a computable `Bool` built from `(Q5, step5, pend5, lab6, chi)` and the
candidate set alone.  No history, world, model or cell appears in any of them -- that is gate 7 in
its definability form -- and `cert_accepts_Rchi` lands a non-empty instance BEFORE every statement
about what the certificate rejects.

The fulfilment conditions are EXISTENTIAL and run INSIDE `R`: `certFwd` and `certBwd` run the
fixpoint at `V := R` with `succ := succR R` / `preR R`, so no path outside `R` can discharge
anything.  Weakening that to "a path somewhere in the carrier" would be strictly weaker and still
type-correct, which is why `cert_fwd_iff_eu_lfp` puts condition (3)'s quantifier structure inside
a THEOREM rather than leaving it only inside a definition.

The `stab` and `box` clauses are PRESENT as checked biconditionals and are not dropped because
this fixture makes them vacuous: `chi_closure_box_snce_stab_free` compiles the reason they are
unexercised here, which is why gate 8 stays SIDESTEPPED rather than passed. -/

def isUntl : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

def isSnce : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

def isBox : PlusFormula → Bool
  | .box _ => true
  | _ => false

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

/-- The successors of `x` INSIDE `R`. -/
def succR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 x y = true)

/-- The predecessors of `x` INSIDE `R`. -/
def preR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 y x = true)

/-- Condition (1): every member of the candidate set is locally coherent. -/
def certLoc (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, locCoh lab6 chi x = true)

/-- Condition (2): every member has a successor AND a predecessor inside `R` -- bi-infinity, read
against `R` itself and not against the carrier. -/
def certBiInf (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, 0 < (succR R x).card ∧ 0 < (preR R x).card)

/-- Condition (3): every forward eventuality carried by a member is discharged by a guarded
forward path INSIDE `R`.  EXISTENTIAL: one path suffices. -/
def certFwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
    x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                          (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- Condition (4): the past-directed mirror of condition (3), through `preR R`. -/
def certBwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isSnce ψ = true →
    x ∈ euLfp R (preR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                         (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- The `stab` biconditional at one member and one closure formula, read against `R`'s OWN fibre
over the member's object state. -/
def stabOk (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) (ψ : PlusFormula) : Bool :=
  decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, y.1 = x.1 → argOf ψ ∈ y.2.1)

/-- Condition (5): the `stab` clause, PRESENT as a checked biconditional. -/
def certStab (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isStab ψ = true → stabOk R x ψ = true)

/-- Condition (6): the `box` clause, the global bit read against `R`, PRESENT as a checked
biconditional. -/
def certBox (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isBox ψ = true →
    (decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, argOf ψ ∈ y.2.1)) = true)

/-- **THE CERTIFICATE**: a candidate realizable set is ADMISSIBLE when all six conditions hold.
The `stab` and `box` conjuncts are part of the certificate, not optional extras. -/
def certAdm (R : Finset (ProdState Q5 chi)) : Bool :=
  certLoc R && certBiInf R && certFwd R && certBwd R && certStab R && certBox R

/-- The `chi`-carrying 3-cycle of the eighteenth probe, as a candidate realizable set. -/
def Rchi : Finset (ProdState Q5 chi) := {(a5, Ta), (b5, Tb), (c5, Tc)}

theorem mem_Rchi (x : ProdState Q5 chi) :
    x ∈ Rchi ↔ (x = (a5, Ta) ∨ x = (b5, Tb) ∨ x = (c5, Tc)) := by
  simp [Rchi]

/-- **The closure of `chi` has no `box`, no `snce` and no `stab` member.**  So conditions (4), (5)
and (6) have NO CONTENT on this fixture: they are checked and vacuously satisfied.  This is the
compiled statement of the gate-8 sidestep -- the standing `BoxStabFree` scope line of the whole
anchor/run layer, which `Realize.lean` and the eighteenth probe buy their results under at exactly
the same place.  Gate 8 is SIDESTEPPED here, not passed. -/
theorem chi_closure_box_snce_stab_free :
    ∀ ψ ∈ plusSubformulaClosure chi,
      isBox ψ = false ∧ isSnce ψ = false ∧ isStab ψ = false := by decide

/-- **Condition (3), unfolded.**  The quantifier structure of the forward discharge condition,
stated as a theorem so that "inside `R`" is visible in a signature and not only in a definition:
the fixpoint runs at `V := R` with `succ := succR R`. -/
theorem cert_fwd_iff_eu_lfp (R : Finset (ProdState Q5 chi)) :
    certFwd R = true ↔
      ∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
        x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                              (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) := by
  simp only [certFwd, decide_eq_true_eq]

/-! The three figures the non-vacuity witness below depends on, confirmed by `#eval` rather than
trusted: the closure of `chi` has 18 members, and the `untl` members of the three types number
`0`, `1` and `1` -- `Tb` carries `xxpa = .untl .bot xpa` and `Tc` carries `xpa = .untl .bot pa`,
so condition (3) has exactly two obligations on `Rchi` and both are discharged in one step. -/
#eval (Ta.1.filter (fun ψ => isUntl ψ = true)).card
#eval (Tb.1.filter (fun ψ => isUntl ψ = true)).card
#eval (Tc.1.filter (fun ψ => isUntl ψ = true)).card

/-! ### The six conditions on `Rchi`, one at a time

No `decide` below is ever applied to a goal quantifying over the candidate set: kernel-reducing
the three-element `Rchi` literal means deciding equality of closure types, which overruns the
recursion depth at any budget worth setting.  Each condition is therefore discharged by hand
through `mem_Rchi` and the per-state facts, exactly as this round's Risks table directs and as the
eighteenth probe does -- `decide` closes concrete closure memberships, concrete `coh6` facts and
bounded quantifications over ONE closure type, and nothing else. -/

theorem ta_untl_free : ∀ ψ ∈ Ta.1, isUntl ψ = false := by decide

theorem tb_untl_only : ∀ ψ ∈ Tb.1, isUntl ψ = true → ψ = xxpa := by decide

theorem tc_untl_only : ∀ ψ ∈ Tc.1, isUntl ψ = true → ψ = xpa := by decide

theorem certLoc_Rchi : certLoc Rchi = true := by
  simp only [certLoc, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · decide
  · decide
  · decide

theorem certBiInf_Rchi : certBiInf Rchi = true := by
  simp only [certBiInf, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · exact ⟨Finset.card_pos.mpr ⟨(b5, Tb), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), by decide⟩⟩,
      Finset.card_pos.mpr ⟨(c5, Tc), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(c5, Tc), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩⟩,
      Finset.card_pos.mpr ⟨(a5, Ta), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(a5, Ta), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩⟩,
      Finset.card_pos.mpr ⟨(b5, Tb), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), by decide⟩⟩⟩

/-- Condition (3) on `Rchi`: its two `untl` obligations -- `xxpa` in `Tb` and `xpa` in `Tc` --
reach their events in ONE step inside `Rchi`, and `Ta` carries no `untl` member at all. -/
theorem certFwd_Rchi : certFwd Rchi = true := by
  rw [cert_fwd_iff_eu_lfp]
  intro x hx ψ hψ huntl
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · rw [ta_untl_free ψ hψ] at huntl
    exact absurd huntl (by simp)
  · have hb : ψ = xxpa := tb_untl_only ψ hψ huntl
    subst hb
    refine (eu_mem_lfp_iff Rchi (succR Rchi) _ _ (b5, Tb)).mpr
      ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), (c5, Tc), ?_, Or.inl (by decide)⟩
    exact Finset.mem_filter.mpr ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩
  · have hc : ψ = xpa := tc_untl_only ψ hψ huntl
    subst hc
    refine (eu_mem_lfp_iff Rchi (succR Rchi) _ _ (c5, Tc)).mpr
      ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), (a5, Ta), ?_, Or.inl (by decide)⟩
    exact Finset.mem_filter.mpr ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩

/-- Condition (4) on `Rchi`: VACUOUS, because the closure has no backward temporal member.  The
condition is checked, not omitted. -/
theorem certBwd_Rchi : certBwd Rchi = true := by
  simp only [certBwd, decide_eq_true_eq]
  intro x _ ψ hψ hsnce
  rw [(chi_closure_box_snce_stab_free ψ (Finset.mem_powerset.mp x.2.2 hψ)).2.1] at hsnce
  exact absurd hsnce (by simp)

/-- Condition (5) on `Rchi`: VACUOUS, because the closure has no `stab` member.  The condition is
checked, not omitted -- which is why gate 8 is SIDESTEPPED and not passed. -/
theorem certStab_Rchi : certStab Rchi = true := by
  simp only [certStab, decide_eq_true_eq]
  intro x _ ψ hψ hstab
  rw [(chi_closure_box_snce_stab_free ψ hψ).2.2] at hstab
  exact absurd hstab (by simp)

/-- Condition (6) on `Rchi`: VACUOUS, because the closure has no `box` member.  Checked, not
omitted. -/
theorem certBox_Rchi : certBox Rchi = true := by
  simp only [certBox, decide_eq_true_eq]
  intro x _ ψ hψ hbox
  rw [(chi_closure_box_snce_stab_free ψ hψ).1] at hbox
  exact absurd hbox (by simp)

/-- **THE NON-VACUITY WITNESS: the certificate ACCEPTS a non-empty candidate set.**  Landed BEFORE
every negative statement about the certificate, which is the discipline gate 7's non-vacuity
obligation asks for: a certificate that accepted nothing would make every rejection below vacuous.
All six conditions hold on the `chi`-carrying 3-cycle, with conditions (4), (5) and (6) vacuous by
`chi_closure_box_snce_stab_free` and condition (3) discharged by its two `untl` obligations
reaching their events in one step inside `Rchi`. -/
theorem cert_accepts_Rchi : certAdm Rchi = true := by
  simp only [certAdm, certLoc_Rchi, certBiInf_Rchi, certFwd_Rchi, certBwd_Rchi, certStab_Rchi,
    certBox_Rchi, Bool.and_self]

end Probe809C

/-! ## Axiom check -/

#print axioms Probe809C.eu_step_mono
#print axioms Probe809C.eu_lfp_fixed
#print axioms Probe809C.eu_mem_lfp_iff
#print axioms Probe809C.eu_lfp_least
#print axioms Probe809C.eu_mem_lfp_iff_exists_path
#print axioms Probe809C.eu_lfp_eq_empty_of_no_event
#print axioms Probe809C.au_lfp_ne_eu_lfp_on_exit_graph
#print axioms Probe809C.untl_propagates_along_coh
#print axioms Probe809C.cohR_le_coh
#print axioms Probe809C.chi_closure_box_snce_stab_free
#print axioms Probe809C.cert_fwd_iff_eu_lfp
#print axioms Probe809C.cert_accepts_Rchi
