/-
# THE CHAIN OBJECT: EVERY FORMULA-ONLY GAP CLIP REFUTED

The last rescue of the filed fibre equation over `kappa` was a bigger gap clip — read the counter
gap `n - c` further before clipping it, and the cells that separate two states of one class would
stop separating them.  This probe closes that rescue for EVERY clip a formula can determine, by
varying the OBJECT rather than the formula.

## What the route names

`kappa Tc Tn P B` quotients a counter pair `(c, n)` with the gap coordinate clipped at `B`, and
`paramsOkK4` constrains `B` by the formula's depths alone (`dBack`, `dFwd`).  The filed equation
asks `cellAt` to be constant on `kappa`-classes.  Earlier refutations in this chain were
deliberately scoped BELOW an exponential clip — `gap_clip_below_exponential_refuted` is silent at
or above `2 ^ (dBack φ + 1)` — so the open question was whether some formula-determined clip
`E : PlusFormula → ℕ` is large enough.

## What this probe compiles

The object is a CHAIN: one pending state, a forced idle chain of `m + 1` states, one idle sink
(`Qm`, `stepM`, `pendM`, `labM`), with a separating formula `chainC` whose core `coreC` records
how long the chain is held.

* `gM_isPath`, `truth_coreC`, `coreC_false` — the fixture's path, the truth read-off for the core,
  and the core's failure at the displaced gap.  Supporting, and the headline theorems reduce
  through them.
* `chainC_cell_ne` — the two cells genuinely DIFFER at gap `m + 1` against any larger gap: a type
  is exhibited in one cell and shown absent from the other, which is the separation the whole
  chain of rounds was asking for.
* `gap_clip_refuted_at_every_clip` — for EVERY `(B, Tc, Tn, P)`, a `kappa`-collision exists whose
  two cells differ.  The quantifier is over the clip, not inside it.
* `no_formula_only_clip` — the headline, quantified over ALL `E : PlusFormula → ℕ`.  For every such
  clip function there is an object in this family on which the parameter conditions hold, the
  clip is met (`E chainC ≤ B` and `Bof … ≤ B`), and the cells still separate.  The reason is
  structural: the gap threshold a formula can read scales with the OBJECT — here with the chain
  length `m` — not only with formula depth, so no function of the formula alone can outrun it.
* `exponential_clip_refuted` — the instance at `fun φ => 2 ^ (dBack φ + 1)`, which is exactly the
  clip the preceding round left open.

## What this probe does NOT settle

It refutes every FORMULA-ONLY clip and says nothing against an OBJECT-DEPENDENT clip `B(Q, φ)`.
That route is left OPEN by this probe, deliberately and not by oversight: it is refuted only up to
`card Q - 2` by the chain family here, and taking it would itself be a signature change, since
`paramsOkK4` and `Bof` read the formula alone.  Nothing here bears on the read-off direction, on
the construction direction, on `Dmax`, or on whether a certified set yields a model; those are
separate statements over a model that is an OUTPUT rather than a pre-given `ladderModel`.  It is
not a device-discrimination claim.  Every quantity named is a COUNT — the chain length `m`, the
clip `B`, the gap — and no bound of any kind is asserted; `kappa_collision_pos` is re-proved
locally here so this file depends on no other probe.

## Verification

`#print axioms` on every headline theorem.  No `sorry`, no axiom, no `native_decide`, no
placeholder body and no vacuous definition anywhere in this file.

Compile: `lake env lean` on this file
(`specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761G

/-! ### The chain object: one pending state, a FORCED idle chain of `m + 1` states, one sink -/

/-- States: `0` pending; `1 … m + 1` the idle chain; `m + 2` an idle sink. -/
abbrev Qm (m : ℕ) : Type := Fin (m + 3)

def pendM (m : ℕ) : Qm m → Bool := fun q => decide (q.val = 0)

/-- The pending state loops, exits into the chain's first state or into the sink; a chain state
has exactly ONE successor (the next chain state, and the pending state from the last one); the
sink loops. No idle chain state has a self-loop: the idle stretch between two regions is forced
to last exactly `m + 1` steps. -/
def stepM (m : ℕ) : Qm m → Qm m → Bool := fun i j =>
  decide ((i.val = 0 ∧ (j.val = 0 ∨ j.val = 1 ∨ j.val = m + 2)) ∨
    (1 ≤ i.val ∧ i.val ≤ m ∧ j.val = i.val + 1) ∨
    (i.val = m + 1 ∧ j.val = 0) ∨
    (i.val = m + 2 ∧ j.val = m + 2))

def pM : Atom := ⟨"p", none⟩

def labM (m : ℕ) : Qm m → Atom → Bool := fun q at_ => decide (at_ = pM ∧ q.val = 0)

theorem labM_pM (m : ℕ) (q : Qm m) : labM m q pM = pendM m q := by
  simp [labM, pendM]

theorem pendM_iff (m : ℕ) (q : Qm m) : pendM m q = true ↔ q.val = 0 := by
  simp [pendM]

theorem pendM_false_iff (m : ℕ) (q : Qm m) : pendM m q = false ↔ q.val ≠ 0 := by
  simp [pendM]

/-! ### Seriality -/

theorem fwdM (m : ℕ) : ∀ (t : ℤ) (x : LadderState (Qm m) (pendM m)),
    ∃ y, RladAdm (stepM m) (pendM m) t x y := by
  rintro t ⟨⟨q, c, n⟩, h⟩
  have h' : q.val ≠ 0 → c = 0 := fun hq => h ((pendM_false_iff m q).mpr hq)
  have hq := q.isLt
  by_cases h0 : q.val = 0
  · rcases Nat.eq_zero_or_pos c with hc | hc
    · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m q ⟨m + 2, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨m + 2, _⟩) c n 0
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · simp [stepM, h0]
      · simp [Count, pendM, hc]
    · refine ⟨⟨(⟨0, by omega⟩, c - 1, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
      show stepM m q ⟨0, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨0, _⟩) c n (c - 1)
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · simp [stepM, h0]
      · simp [Count, pendM, h0]; omega
  · by_cases hm : q.val ≤ m
    · refine ⟨⟨(⟨q.val + 1, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m q ⟨q.val + 1, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
        Count (pendM m q) (pendM m ⟨q.val + 1, _⟩) c n 0
      refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
      · exact decide_eq_true (Or.inr (Or.inl ⟨by omega, hm, rfl⟩))
      · simp [Count, pendM, h0]
    · by_cases hm1 : q.val = m + 1
      · refine ⟨⟨(⟨0, by omega⟩, n, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
        show stepM m q ⟨0, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
          Count (pendM m q) (pendM m ⟨0, _⟩) c n n
        refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
        · exact decide_eq_true (Or.inr (Or.inr (Or.inl ⟨hm1, rfl⟩)))
        · simp [Count, pendM, h0]
      · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
        show stepM m q ⟨m + 2, _⟩ = true ∧ (pendM m q = false → c = 0) ∧ Drift n n ∧
          Count (pendM m q) (pendM m ⟨m + 2, _⟩) c n 0
        refine ⟨?_, fun hp => h hp, Or.inl rfl, ?_⟩
        · exact decide_eq_true (Or.inr (Or.inr (Or.inr ⟨by omega, rfl⟩)))
        · simp [Count, pendM, h0]

theorem bwdM (m : ℕ) : ∀ (t : ℤ) (x : LadderState (Qm m) (pendM m)),
    ∃ y, RladAdm (stepM m) (pendM m) (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, h⟩
  have h' : q.val ≠ 0 → c = 0 := fun hq => h ((pendM_false_iff m q).mpr hq)
  have hq := q.isLt
  by_cases h0 : q.val = 0
  · refine ⟨⟨(⟨0, by omega⟩, c + 1, n), fun hp => absurd hp (by simp [pendM])⟩, ?_⟩
    show stepM m ⟨0, _⟩ q = true ∧ (pendM m ⟨0, _⟩ = false → c + 1 = 0) ∧ Drift n n ∧
      Count (pendM m ⟨0, _⟩) (pendM m q) (c + 1) n c
    refine ⟨?_, fun hp => absurd hp (by simp [pendM]), Or.inl rfl, ?_⟩
    · simp [stepM, h0]
    · simp [Count, pendM, h0]
  · have hc : c = 0 := h' h0
    subst hc
    by_cases h1 : q.val = m + 2
    · refine ⟨⟨(⟨m + 2, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m ⟨m + 2, _⟩ q = true ∧ (pendM m ⟨m + 2, _⟩ = false → 0 = 0) ∧ Drift n n ∧
        Count (pendM m ⟨m + 2, _⟩) (pendM m q) 0 n 0
      refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
      · exact decide_eq_true (Or.inr (Or.inr (Or.inr ⟨rfl, h1⟩)))
      · simp [Count, pendM, h0]
    · refine ⟨⟨(⟨q.val - 1, by omega⟩, 0, n), fun _ => rfl⟩, ?_⟩
      show stepM m ⟨q.val - 1, _⟩ q = true ∧ (pendM m ⟨q.val - 1, _⟩ = false → 0 = 0) ∧
        Drift n n ∧ Count (pendM m ⟨q.val - 1, _⟩) (pendM m q) 0 n 0
      refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
      · simp only [stepM, decide_eq_true_eq]; omega
      · simp [Count, pendM, h0]

/-- The ladder model of the chain object. -/
noncomputable abbrev MM (m : ℕ) :
    TaskModel (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame :=
  ladderModel (stepM m) (pendM m) (fwdM m) (bwdM m) (labM m)

/-- The pending ladder state `⟨(0, c, n), _⟩`. -/
def stM (m c n : ℕ) : LadderState (Qm m) (pendM m) :=
  ⟨((⟨0, by omega⟩ : Qm m), c, n), fun hp => absurd hp (by simp [pendM])⟩

/-! ### The formula: FIXED, independent of `m` -/

def nxtF (ψ : PlusFormula) : PlusFormula := .untl .bot ψ
def andF (a b : PlusFormula) : PlusFormula := PlusFormula.neg (.imp a (PlusFormula.neg b))
def diaF (ψ : PlusFormula) : PlusFormula := PlusFormula.neg (.stab (PlusFormula.neg ψ))

/-- "The region entered next is a single position": `¬p U (p ∧ X ¬p)`. -/
def oneC : PlusFormula :=
  .untl (PlusFormula.neg (.atom pM)) (andF (.atom pM) (nxtF (PlusFormula.neg (.atom pM))))

/-- `p U (¬p ∧ oneC)`: at the end of the current region, the region entered next is a single
position. -/
def coreC : PlusFormula := .untl (.atom pM) (andF (PlusFormula.neg (.atom pM)) oneC)

/-- **THE SEPARATING FORMULA**, one formula for every object of the family: `◇ coreC`. -/
def chainC : PlusFormula := diaF coreC

theorem dBack_chainC : dBack chainC = 0 := rfl
theorem dFwd_chainC : dFwd chainC = 3 := rfl

theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

section truth
variable {m : ℕ}

theorem truth_andF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (a b : PlusFormula) :
    PlusTruthAt (MM m) τ t (andF a b) ↔ PlusTruthAt (MM m) τ t a ∧ PlusTruthAt (MM m) τ t b := by
  show ((PlusTruthAt (MM m) τ t a → (PlusTruthAt (MM m) τ t b → False)) → False) ↔ _
  tauto

theorem truth_nxtF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (MM m) τ t (nxtF ψ) ↔ PlusTruthAt (MM m) τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

theorem truth_diaF (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (MM m) τ t (diaF ψ) ↔
      ∃ σ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame,
        τ.state t = σ.state t ∧ PlusTruthAt (MM m) σ t ψ := by
  show ((∀ σ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame,
    τ.state t = σ.state t → (PlusTruthAt (MM m) σ t ψ → False)) → False) ↔ _
  constructor
  · intro h
    by_contra hn
    exact h (fun σ e hψ => hn ⟨σ, e, hψ⟩)
  · rintro ⟨σ, e, hψ⟩ h
    exact h σ e hψ

theorem truth_p (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (s : ℤ) :
    PlusTruthAt (MM m) τ s (.atom pM) ↔ pendM m (objAt g s) = true := by
  show labM m (τ.state s).2.1.1 pM = true ↔ _
  rw [hτ s]
  show labM m (objAt g s) pM = true ↔ _
  rw [labM_pM]

theorem truth_np (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (s : ℤ) :
    PlusTruthAt (MM m) τ s (PlusFormula.neg (.atom pM)) ↔ pendM m (objAt g s) = false := by
  show (PlusTruthAt (MM m) τ s (.atom pM) → False) ↔ _
  rw [truth_p τ g hτ s]
  cases pendM m (objAt g s) <;> simp

/-- The semantic content of `coreC` on a history read as a ladder path. -/
theorem truth_coreC (τ : WorldHistory (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).toTaskFrame)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt (MM m) τ t coreC ↔
      ∃ s : ℤ, t < s ∧ pendM m (objAt g s) = false ∧
        (∃ u : ℤ, s < u ∧ pendM m (objAt g u) = true ∧ pendM m (objAt g (u + 1)) = false ∧
          ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false) ∧
        ∀ r : ℤ, t < r → r < s → pendM m (objAt g r) = true := by
  show (∃ s : ℤ, t < s ∧ PlusTruthAt (MM m) τ s (andF (PlusFormula.neg (.atom pM)) oneC) ∧
      ∀ r : ℤ, t < r → r < s → PlusTruthAt (MM m) τ r (.atom pM)) ↔ _
  have hone : ∀ s : ℤ, PlusTruthAt (MM m) τ s oneC ↔
      ∃ u : ℤ, s < u ∧ pendM m (objAt g u) = true ∧ pendM m (objAt g (u + 1)) = false ∧
          ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false := by
    intro s
    show (∃ u : ℤ, s < u ∧
        PlusTruthAt (MM m) τ u (andF (.atom pM) (nxtF (PlusFormula.neg (.atom pM)))) ∧
        ∀ r : ℤ, s < r → r < u → PlusTruthAt (MM m) τ r (PlusFormula.neg (.atom pM))) ↔ _
    constructor
    · rintro ⟨u, h1, h2, h3⟩
      rw [truth_andF, truth_nxtF, truth_p τ g hτ, truth_np τ g hτ] at h2
      exact ⟨u, h1, h2.1, h2.2, fun r a b => (truth_np τ g hτ r).mp (h3 r a b)⟩
    · rintro ⟨u, h1, h2, h3, h4⟩
      refine ⟨u, h1, ?_, fun r a b => (truth_np τ g hτ r).mpr (h4 r a b)⟩
      rw [truth_andF, truth_nxtF, truth_p τ g hτ, truth_np τ g hτ]
      exact ⟨h2, h3⟩
  constructor
  · rintro ⟨s, h1, h2, h3⟩
    rw [truth_andF, truth_np τ g hτ, hone] at h2
    exact ⟨s, h1, h2.1, h2.2, fun r a b => (truth_p τ g hτ r).mp (h3 r a b)⟩
  · rintro ⟨s, h1, h2, h3, h4⟩
    refine ⟨s, h1, ?_, fun r a b => (truth_p τ g hτ r).mpr (h4 r a b)⟩
    rw [truth_andF, truth_np τ g hτ, hone]
    exact ⟨h2, h3⟩

end truth

/-! ### Negative half: gap above `m + 1` -/

/-- On EVERY ladder path through `(0, c, n)` with `n ≥ c + m + 2`, `coreC` fails: the region ends
at `c + 1`, the forced chain reaches the next pending state at most `m + 1` steps later, and the
register cannot fall to `0` by then. -/
theorem coreC_false (m c n : ℕ) (hgap : c + m + 2 ≤ n)
    (g : ℤ → LadderState (Qm m) (pendM m)) (hg : IsLadderPath (stepM m) (pendM m) g)
    (h0 : g 0 = stM m c n)
    (s : ℤ) (hs0 : 0 < s) (hsidle : pendM m (objAt g s) = false)
    (u : ℤ) (hsu : s < u) (hup : pendM m (objAt g u) = true)
    (hu1 : pendM m (objAt g (u + 1)) = false)
    (hmid : ∀ r : ℤ, s < r → r < u → pendM m (objAt g r) = false)
    (hguard : ∀ r : ℤ, 0 < r → r < s → pendM m (objAt g r) = true) : False := by
  have hobj : objAt g 0 = (⟨0, by omega⟩ : Qm m) := by rw [objAt, h0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, h0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, h0]; rfl
  have hp0 : pendM m (objAt g 0) = true := by rw [hobj]; simp [pendM]
  have hend := not_pend_of_count g hg 0 hp0
  -- the region ends exactly at `c + 1`
  have hs' : s = (c : ℤ) + 1 := by
    rcases lt_trichotomy s (0 + (cntAt g 0 : ℤ) + 1) with hlt | heq | hgt
    · have := (cntAt_sub_of_pend g hg 0 hp0 s.toNat (by omega)).1
      rw [show (0 : ℤ) + ((s.toNat : ℕ) : ℤ) = s by omega] at this
      exact absurd (this.symm.trans hsidle) (by simp)
    · rw [heq, hcnt]; ring
    · exact absurd ((hguard _ (by omega) hgt).symm.trans hend) (by simp)
  -- the chain invariant
  have hchain : ∀ k : ℕ, s + (k : ℤ) < u →
      (objAt g (s + (k : ℤ))).val = m + 2 ∨ k + 1 ≤ (objAt g (s + (k : ℤ))).val := by
    intro k
    induction k with
    | zero =>
      intro _
      right
      have := (pendM_false_iff m _).mp hsidle
      simp only [Nat.cast_zero, add_zero]
      omega
    | succ k ih =>
      intro hk
      have hprev := ih (by push_cast at hk; omega)
      have hstep := objAt_step g hg (s + (k : ℤ))
      have hidle := (pendM_false_iff m _).mp (hmid (s + ((k + 1 : ℕ) : ℤ)) (by push_cast; omega) hk)
      rw [show s + ((k + 1 : ℕ) : ℤ) = s + (k : ℤ) + 1 by push_cast; ring] at hidle ⊢
      simp only [stepM, decide_eq_true_eq] at hstep
      omega
  -- the last idle position before `u`
  have hlast : (objAt g (u - 1)).val = m + 1 := by
    have hstep := objAt_step g hg (u - 1)
    rw [show u - 1 + 1 = u by ring] at hstep
    have hupz := (pendM_iff m _).mp hup
    have hidle : (objAt g (u - 1)).val ≠ 0 := by
      apply (pendM_false_iff m _).mp
      by_cases he : u - 1 = s
      · rw [he]; exact hsidle
      · exact hmid (u - 1) (by omega) (by omega)
    simp only [stepM, decide_eq_true_eq] at hstep
    omega
  have hk := hchain (u - 1 - s).toNat (by omega)
  rw [show s + (((u - 1 - s).toNat : ℕ) : ℤ) = u - 1 by omega] at hk
  have hbound : u - 1 ≤ (c : ℤ) + m + 1 := by omega
  -- the register at `u - 1` is `0`
  have hidle' : pendM m (objAt g (u - 1)) = false := by
    rw [pendM_false_iff]; omega
  have hup' : pendM m (objAt g (u - 1 + 1)) = true := by
    rw [show u - 1 + 1 = u by ring]; exact hup
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (u - 1) hidle' hup'
  rw [show u - 1 + 1 = u by ring] at hpin
  have hcu : cntAt g u = 0 := by
    have h := (isLadderPath_components g hg u).2.2.2
    simp only [Count, hup, hu1] at h
    simpa using h.2
  have hlip := nxtAt_lipschitz g hg 0 (u - 1).toNat
  rw [show (0 : ℤ) + (((u - 1).toNat : ℕ) : ℤ) = u - 1 by omega] at hlip
  omega

/-! ### Positive half: gap exactly `m + 1` -/

def objN (m c : ℕ) (v : ℤ) : ℕ :=
  if v ≤ (c : ℤ) then 0 else if v ≤ (c : ℤ) + m + 1 then (v - c).toNat
  else if v = (c : ℤ) + m + 2 then 0 else m + 2

def cntN (c : ℕ) (v : ℤ) : ℕ := ((c : ℤ) - v).toNat

def regN (m c : ℕ) (v : ℤ) : ℕ := if v ≤ 0 then c + m + 1 else ((c : ℤ) + m + 1 - v).toNat

theorem objN_lt (m c : ℕ) (v : ℤ) : objN m c v < m + 3 := by
  unfold objN; split_ifs <;> omega

theorem objN_eq_zero_iff (m c : ℕ) (v : ℤ) :
    objN m c v = 0 ↔ v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2 := by
  unfold objN; split_ifs with h1 h2 h3 <;> constructor <;> intro h <;> first | omega | exact h.elim

/-- The witnessing path: count down, let the register fall at every step from `0` on, walk the
chain, enter a single-position region, fall into the sink. -/
def gM (m c : ℕ) : ℤ → LadderState (Qm m) (pendM m) := fun v =>
  ⟨((⟨objN m c v, objN_lt m c v⟩ : Qm m), cntN c v, regN m c v), by
    intro hp
    have hne : objN m c v ≠ 0 := (pendM_false_iff m _).mp hp
    have := objN_eq_zero_iff m c v
    show cntN c v = 0
    unfold cntN
    omega⟩

theorem gM_pend_iff (m c : ℕ) (v : ℤ) :
    pendM m (objAt (gM m c) v) = true ↔ v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2 := by
  rw [pendM_iff]; exact objN_eq_zero_iff m c v

theorem gM_idle_iff (m c : ℕ) (v : ℤ) :
    pendM m (objAt (gM m c) v) = false ↔ ¬ (v ≤ (c : ℤ) ∨ v = (c : ℤ) + m + 2) := by
  rw [← gM_pend_iff]; cases pendM m (objAt (gM m c) v) <;> simp

theorem gM_isPath (m c : ℕ) : IsLadderPath (stepM m) (pendM m) (gM m c) := by
  intro u
  show stepM m ⟨objN m c u, _⟩ ⟨objN m c (u + 1), _⟩ = true ∧
    (pendM m ⟨objN m c u, _⟩ = false → cntN c u = 0) ∧
    Drift (regN m c u) (regN m c (u + 1)) ∧
    Count (pendM m ⟨objN m c u, _⟩) (pendM m ⟨objN m c (u + 1), _⟩) (cntN c u) (regN m c u)
      (cntN c (u + 1))
  have e0 := objN_eq_zero_iff m c u
  have e1 := objN_eq_zero_iff m c (u + 1)
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp only [stepM, decide_eq_true_eq]
    unfold objN
    split_ifs <;> omega
  · intro hp
    have hne : objN m c u ≠ 0 := (pendM_false_iff m _).mp hp
    unfold cntN
    omega
  · unfold Drift regN
    split_ifs <;> omega
  · unfold Count
    simp only [pendM, decide_eq_true_eq]
    unfold cntN regN
    split_ifs <;> omega

theorem gM_zero (m c : ℕ) : gM m c 0 = stM m c (c + m + 1) := by
  apply Subtype.ext
  show ((⟨objN m c 0, _⟩ : Qm m), cntN c 0, regN m c 0) = ((⟨0, _⟩ : Qm m), c, c + m + 1)
  have h1 : objN m c 0 = 0 := (objN_eq_zero_iff m c 0).mpr (Or.inl (by omega))
  have h2 : cntN c 0 = c := by unfold cntN; omega
  have h3 : regN m c 0 = c + m + 1 := by unfold regN; simp
  simp only [h1, h2, h3]

/-! ### The cells differ -/

/-- **THE CELLS DIFFER AT THE CHAIN LENGTH.** At the pending state of the chain object, the gap
`m + 1` and every gap above it have different cells at the FIXED formula `chainC`. -/
theorem chainC_cell_ne (m c n' : ℕ) (hgap : c + m + 2 ≤ n') :
    cellAt (MM m) chainC
        ((0, stM m c (c + m + 1)) :
          (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0
      ≠ cellAt (MM m) chainC
          ((0, stM m c n') :
            (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0 := by
  intro heq
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath (fwdM m) (bwdM m) (gM m c) (gM_isPath m c)
  -- a realized type at gap `m + 1` containing `chainC`
  have hT : tpOf (MM m) chainC σ 0 ∈ cellAt (MM m) chainC
      ((0, stM m c (c + m + 1)) :
        (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState) 0 :=
    (mem_cellAt_ladder_iff (fwdM m) (bwdM m) (labM m) chainC _ 0 _).mpr
      ⟨gM m c, σ, gM_isPath m c, gM_zero m c, hσ, rfl⟩
  have hin : chainC ∈ tpOf (MM m) chainC σ 0 := by
    rw [mem_tpOf_iff]
    refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
    show PlusTruthAt (MM m) σ 0 (diaF coreC)
    refine (truth_diaF σ 0 coreC).mpr ⟨σ, rfl, ?_⟩
    rw [truth_coreC σ (gM m c) hσ 0]
    refine ⟨(c : ℤ) + 1, by omega, ?_, ⟨(c : ℤ) + m + 2, by omega, ?_, ?_, ?_⟩, ?_⟩
    · rw [gM_idle_iff]; omega
    · rw [gM_pend_iff]; omega
    · rw [gM_idle_iff]; omega
    · intro r h1 h2; rw [gM_idle_iff]; omega
    · intro r h1 h2; rw [gM_pend_iff]; omega
  -- transport to the other cell and contradict
  rw [heq] at hT
  obtain ⟨g, τ, hg, hg0, hτ, hTeq⟩ :=
    (mem_cellAt_ladder_iff (fwdM m) (bwdM m) (labM m) chainC _ 0 _).mp hT
  rw [← hTeq, mem_tpOf_iff] at hin
  obtain ⟨σ', he, hcore⟩ := (truth_diaF τ 0 coreC).mp hin.2
  obtain ⟨k, g', hg', hp'⟩ := exists_isLadderPath_of_hist (fwdM m) (bwdM m) σ'
  have h0 : ((0, g 0) : (ladderFrameAdm (stepM m) (pendM m) (fwdM m) (bwdM m)).WorldState)
      = (0 + k, g' 0) := (hτ 0).symm.trans (he.trans (hp' 0))
  have hk : (0 : ℤ) = 0 + k := congrArg Prod.fst h0
  have hk0 : k = 0 := by omega
  subst hk0
  have hp'' : ∀ v : ℤ, σ'.state v = (v, g' v) := fun v => by rw [hp' v, add_zero]
  have hg'0 : g' 0 = stM m c n' := ((congrArg Prod.snd h0).symm).trans hg0
  rw [truth_coreC σ' g' hp'' 0] at hcore
  obtain ⟨s, hs0, hsidle, ⟨u, hsu, hup, hu1, hmid⟩, hguard⟩ := hcore
  exact coreC_false m c n' hgap g' hg' hg'0 s hs0 hsidle u hsu hup hu1 hmid hguard

/-! ### The collision, at every clip -/

theorem kappa_collision_pos (Tc Tn P B c n : ℕ) (hn : Tn ≤ n) (hB : c + B ≤ n) :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n + (P + 1)) := by
  unfold kappa
  refine Prod.ext rfl (Prod.ext rfl (Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Fin.ext ?_))))
  · show min n Tn = min (n + (P + 1)) Tn
    omega
  · show n % (P + 1) = (n + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · show clipIdx B c n = clipIdx B c (n + (P + 1))
    unfold clipIdx
    split_ifs <;> omega

/-- **NO CLIP SURVIVES THE CHAIN FAMILY.** For EVERY gap clip `B` — no upper bound on it — and
every threshold pair and modulus, the chain object with `B + 1` idle chain states carries a
`kappa`-collision whose cells differ at the one fixed formula `chainC` (`dBack = 0`,
`dFwd = 3`). The separated gaps are `B + 1` and `B + 1 + (P + 1)`. -/
theorem gap_clip_refuted_at_every_clip (B Tc Tn P : ℕ) :
    ∃ c n n' : ℕ, n = c + (B + 1) ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') ∧
      cellAt (MM B) chainC
          ((0, stM B c n) :
            (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
        ≠ cellAt (MM B) chainC
          ((0, stM B c n') :
            (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 := by
  refine ⟨Tn, Tn + (B + 1), Tn + (B + 1) + (P + 1), rfl, ?_, ?_⟩
  · exact kappa_collision_pos Tc Tn P B Tn _ (by omega) (by omega)
  · rw [show Tn + (B + 1) = Tn + B + 1 by omega]
    exact chainC_cell_ne B Tn _ (by omega)

/-- The filed (K4) at `chainC` is `7 ≤ B`. -/
theorem Bof_chainC (m : ℕ) : Bof (stepM m) (pendM m) (labM m) chainC = 7 := by
  unfold Bof
  rw [dBack_chainC, dFwd_chainC]
  rfl

/-- **AT THE FILED `ParamsOk`, WITH THE CLIP RAISED TO ANY FORMULA-ONLY VALUE.** Let `E` be ANY
function of the formula alone (for instance `fun φ => 2 ^ (dBack φ + 1)`, or a tower). Put
`B := max (E chainC) 7`. Then at the chain object with `B + 1` chain states: `ParamsOk` holds at
the periodicity fixpoint's own `Tcof`, `Tnof`, `Pof` with the clip `B`; `B` dominates `E chainC`
and the filed `Bof`; and two counter pairs of one `kappa`-class have different cells. -/
theorem no_formula_only_clip (E : PlusFormula → ℕ) :
    ∃ B : ℕ, E chainC ≤ B ∧ Bof (stepM B) (pendM B) (labM B) chainC ≤ B ∧
      ParamsOk (stepM B) (pendM B) (labM B) chainC
        (Tcof (stepM B) (pendM B) (labM B) chainC) (Tnof (stepM B) (pendM B) (labM B) chainC)
        (Pof (stepM B) (pendM B) (labM B) chainC) B ∧
      ∃ c n n' : ℕ,
        kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n)
          = kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n') ∧
        cellAt (MM B) chainC
            ((0, stM B c n) :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
          ≠ cellAt (MM B) chainC
            ((0, stM B c n') :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 := by
  refine ⟨max (E chainC) 7, le_max_left _ _, ?_, ?_, ?_⟩
  · rw [Bof_chainC]; exact le_max_right _ _
  · obtain ⟨h1, h2, h3, -⟩ := paramsOk_params (stepM (max (E chainC) 7))
      (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC
    refine ⟨h1, h2, h3, ?_⟩
    have h7 : 7 ≤ max (E chainC) 7 := le_max_right _ _
    unfold paramsOkK4
    rw [dBack_chainC, dFwd_chainC]
    omega
  · obtain ⟨c, n, n', -, hk, hne⟩ := gap_clip_refuted_at_every_clip (max (E chainC) 7)
      (Tcof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
      (Tnof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
      (Pof (stepM (max (E chainC) 7)) (pendM (max (E chainC) 7)) (labM (max (E chainC) 7)) chainC)
    exact ⟨c, n, n', hk, hne⟩

/-- **THE INSTANCE THE QUESTION NAMES**: the clip `max (2 ^ (dBack φ + 1)) (Bof φ)`-or-larger. -/
theorem exponential_clip_refuted :
    ∃ B : ℕ, 2 ^ (dBack chainC + 1) ≤ B ∧ Bof (stepM B) (pendM B) (labM B) chainC ≤ B ∧
      ParamsOk (stepM B) (pendM B) (labM B) chainC
        (Tcof (stepM B) (pendM B) (labM B) chainC) (Tnof (stepM B) (pendM B) (labM B) chainC)
        (Pof (stepM B) (pendM B) (labM B) chainC) B ∧
      ∃ c n n' : ℕ,
        kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n)
          = kappa (Tcof (stepM B) (pendM B) (labM B) chainC)
            (Tnof (stepM B) (pendM B) (labM B) chainC)
            (Pof (stepM B) (pendM B) (labM B) chainC) B (c, n') ∧
        cellAt (MM B) chainC
            ((0, stM B c n) :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0
          ≠ cellAt (MM B) chainC
            ((0, stM B c n') :
              (ladderFrameAdm (stepM B) (pendM B) (fwdM B) (bwdM B)).WorldState) 0 :=
  no_formula_only_clip (fun φ => 2 ^ (dBack φ + 1))

end Probe761G

#print axioms Probe761G.chainC_cell_ne
#print axioms Probe761G.gap_clip_refuted_at_every_clip
#print axioms Probe761G.no_formula_only_clip
#print axioms Probe761G.exponential_clip_refuted
