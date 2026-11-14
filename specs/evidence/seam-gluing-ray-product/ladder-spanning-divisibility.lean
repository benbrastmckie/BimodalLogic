/-
THE DECISION GATE: is a spanning block's length constrained by `(K1)`?

A wired probe, compiled by `scripts/check-evidence-probes.sh`.

ONE question. The pigeonhole over region starts produces, from pin density at a given object, a
type-respecting block `[u, u + l)` that SPANS a pin — an idle position `t` with `u ≤ t` and
`t + 1 < u + l`. The landed bridge `realized_typeBlock_mem_prodCycleLens` does not apply to such a
block: its hypothesis `l ≤ cntAt g u` puts the block INSIDE one pending region, and a block
spanning a pin crosses an idle position by construction. Is `l ∣ P + 1` nevertheless derivable
from `(K1)`?

**VERDICT: FAIL.** It is not derivable, and the schema is REFUTED by a compiled object.

**The three conjuncts of `(K1)`, read against the schema.**
* `prodCycleLens` — the certificate graph's cycle lengths on saturated classes. Its membership
  condition carries `∀ i, pend (f i).1 = true`: the closed walk is PENDING THROUGHOUT. A spanning
  block's own induced walk is idle at the index of the pin inside it
  (`spanning_walk_not_pending` below), so the block never witnesses this membership.
* `objCycleLens` — the object's own pending cycle lengths. Its membership condition carries the
  same `∀ i, pend (f i) = true`, and additionally `l ≤ Fintype.card Q`, which the pigeonhole's
  block does not satisfy either: its length is bounded by the pin window, not by the object's
  cardinality. Ruled out by the same compiled fact.
* `satPeriod` — the periodicity fixpoint's period, a datum of `step`, `lab` and `φ` alone. Nothing
  relates a block's length to it: it is not quantified over block lengths at all, so it constrains
  `P + 1` without constraining `l`.

**The refuting object** (`spanningBlockLengthDvd_refuted`): the ALTERNATING path `wD` — idle at
every even position, pending at every odd one, every countdown `0` and the register constantly
`0` — carries, for the atomic closure `aD` (stab-free, and `tpOf` along it is a function of the
object state alone), a type-respecting block of EVERY even length whose left end is the pin at
`0`. If the schema held, every one of those lengths would divide `P + 1`; taking the length
`2 · (P + 1)` contradicts `Nat.le_of_dvd`. The parameters are the periodicity fixpoint's own
outputs at `aD`, discharged by the landed `paramsOk_params`, so the refutation is at a tuple the
parameter conditions genuinely admit and not at a vacuous hypothesis.

**What this settles and what it does not.** It settles the gate: `(K1)` does not constrain the
length of a type-respecting block that spans a pin, so the pigeonhole's block cannot be shifted
by a multiple of `P + 1`, and the downward cell inclusion cannot be assembled from it in the
unrestricted regime. It does NOT amend `(K1)` — no conjunct is touched here, and an amendment
would alter the parameter contract every wired probe discharges; that is recorded as a follow-up
candidate, never implemented. It does NOT refute the depth-`0` cell obligation: the obligation is
about cells, the schema here is about one divisibility, and the pin-free side on which the
register IS rebuildable is untouched.

The object below is RE-DECLARED from the sibling prototype rather than imported: a standalone file
under `specs/**` is not a module on the Lake library path, so there is no module name to import.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderPin

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe838B

/-! ## Re-declared from the sibling prototype: the object -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

theorem fwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · cases c with
    | zero =>
        refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_one]
    | succ d =>
        refine ⟨⟨(0, d, n), admZeroC d n⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_one]

theorem bwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · refine ⟨⟨(0, c + 1, n), admZeroC (c + 1) n⟩, rfl, admZeroC (c + 1) n,
      Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    have hc : c = 0 := hx hq
    refine ⟨⟨(0, 0, n), admZeroC 0 n⟩, rfl, admZeroC 0 n, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero, hc]

/-! ## The gate's schema

The spanning-block tuple is exactly the pigeonhole's conclusion, with the window bounds dropped:
a type-respecting block `[u, u + l)` of a ladder path containing a pin `t` strictly inside it. The
schema asserts the one thing the downward cell inclusion would need of it — that its length
divides `P + 1`, so that a whole number of copies realizes a shift by a multiple of `P + 1`. It is
stated as a named `def` so that the verdict is a theorem about a named object either way. -/

def SpanningBlockLengthDvd {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q → Bool)
    (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
    ∀ (u : ℤ) (l : ℕ) (t : ℤ), 0 < l → u ≤ t → t + 1 < u + (l : ℤ) →
      pend (objAt g t) = false → pend (objAt g (t + 1)) = true →
      objAt g u = objAt g (u + (l : ℤ)) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) →
      l ∣ (P + 1)

/-! ## Why neither cycle-length conjunct of `(K1)` can carry a spanning block

Both `prodCycleLens` and `objCycleLens` carry `∀ i, pend (f i) = true` on the closed walk they
quantify: the walk is PENDING THROUGHOUT, which is the region-interior restriction. The walk a
spanning block induces is idle at the index of the pin strictly inside it, so the block's own
length never witnesses either membership. This is the mechanical content of the gate's FAIL. -/

theorem spanning_walk_not_pending {Q : Type} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (u : ℤ) (l : ℕ) (t : ℤ)
    (hut : u ≤ t) (htl : t + 1 < u + (l : ℤ)) (hti : pend (objAt g t) = false) :
    ¬ (∀ i : ℕ, pend (objAt g (u + (((i % l : ℕ)) : ℤ))) = true) := by
  intro h
  have hlt : (t - u).toNat < l := by omega
  have hmod : (t - u).toNat % l = (t - u).toNat := Nat.mod_eq_of_lt hlt
  have hv := h (t - u).toNat
  rw [hmod, show u + ((((t - u).toNat : ℕ)) : ℤ) = t by omega] at hv
  exact Bool.false_ne_true (hti.symm.trans hv)

/-! ## The refuting object: the alternating path, and the atomic closure

`wD` is idle at every even position and pending at every odd one. Every pending region has length
one, so every countdown is `0` and the register is constantly `0`; the walk lifts to a ladder path
through the landed `exists_ladderPath_of_walk`. For the atomic closure `aD` the realized type is a
function of the object state alone, so any two positions carrying the same object state carry the
same type — and the even positions all carry the same one. -/

def wD : ℤ → Qc := fun v => if v % 2 = 0 then 1 else 0

def cD : ℤ → ℕ := fun _ => 0

theorem wD_of_even (v : ℤ) (h : v % 2 = 0) : wD v = 1 := by unfold wD; rw [if_pos h]

theorem pendC_wD_iff (v : ℤ) : pendC (wD v) = false ↔ v % 2 = 0 := by
  unfold wD
  split_ifs with h <;> simp [pendC, h]

theorem pendC_wD_true_iff (v : ℤ) : pendC (wD v) = true ↔ ¬ (v % 2 = 0) := by
  rw [← Bool.not_eq_false, pendC_wD_iff]

/-- The alternating walk with its forced countdown lifts to a ladder path. -/
theorem exists_gD : ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
    (∀ v, objAt g v = wD v) ∧ (∀ v, cntAt g v = cD v) := by
  refine exists_ladderPath_of_walk wD cD 0 (fun _ => rfl) ?_ ?_ ?_ ?_ ?_
  · intro v _; rfl
  · intro v h0 h1
    exfalso
    rw [pendC_wD_true_iff] at h0 h1
    omega
  · intro v _ _; rfl
  · intro s v _ _ _ _; simp [cD]
  · intro v _ _; simp [cD]

def aD : PlusFormula := .atom pC

noncomputable abbrev MD := ladderModel stepC pendC fwdC bwdC labC

abbrev HistD := WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame

theorem closure_aD : plusSubformulaClosure aD = {aD} := by
  simp [plusSubformulaClosure, aD, PlusFormula.subformulas]

theorem no_stab_in_closure_aD :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure aD := by
  intro χ h
  rw [closure_aD, Finset.mem_singleton] at h
  exact PlusFormula.noConfusion h

theorem atom_iff_pend {g : ℤ → LadderState Qc pendC} (τ : HistD)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt MD τ t aD ↔ pendC (objAt g t) = true := by
  rw [aD, PlusTruth.atom_iff, hτ t]
  change labC (objAt g t) pC = true ↔ _
  rw [labC_pC]

/-- **THE ATOMIC TYPE IS A FUNCTION OF THE OBJECT STATE.** Two positions with the same object
state realize the same `aD`-closure type, because the closure is the singleton `{aD}` and `aD`'s
truth reads the label at the position's own object state. -/
theorem tpOf_eq_of_objAt_eq {g : ℤ → LadderState Qc pendC} (τ : HistD)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (x y : ℤ) (h : objAt g x = objAt g y) :
    tpOf MD aD τ x = tpOf MD aD τ y := by
  refine Finset.ext fun ψ => ?_
  rw [mem_tpOf_iff, mem_tpOf_iff, closure_aD]
  constructor
  · rintro ⟨hm, ht⟩
    rw [Finset.mem_singleton] at hm
    subst hm
    exact ⟨Finset.mem_singleton_self _,
      (atom_iff_pend τ hτ y).mpr (h ▸ (atom_iff_pend τ hτ x).mp ht)⟩
  · rintro ⟨hm, ht⟩
    rw [Finset.mem_singleton] at hm
    subst hm
    exact ⟨Finset.mem_singleton_self _,
      (atom_iff_pend τ hτ x).mpr (h ▸ (atom_iff_pend τ hτ y).mp ht)⟩

noncomputable def TcD : ℕ := Tcof stepC pendC labC aD
noncomputable def TnD : ℕ := Tnof stepC pendC labC aD
noncomputable def PD : ℕ := Pof stepC pendC labC aD
noncomputable def BD : ℕ := Bof stepC pendC labC aD

theorem paramsOkD : ParamsOk stepC pendC labC aD TcD TnD PD BD :=
  paramsOk_params stepC pendC labC aD

/-! ## The verdict -/

/-- **THE GATE IS FAIL: `(K1)` DOES NOT CONSTRAIN A SPANNING BLOCK'S LENGTH.** The alternating
path carries a type-respecting block of every even length with the pin at `0` strictly inside it,
at the periodicity fixpoint's own outputs for a stab-free atomic closure. The length
`2 · (P + 1)` exceeds `P + 1`, so it cannot divide it, and the schema fails. -/
theorem spanningBlockLengthDvd_refuted :
    ¬ SpanningBlockLengthDvd stepC pendC fwdC bwdC labC aD TcD TnD PD BD := by
  intro h
  obtain ⟨g, hg, hobj, -⟩ := exists_gD
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC g hg
  have hpar : (0 : ℤ) % 2 = 0 := by omega
  have h0 : pendC (objAt g 0) = false := by rw [hobj, pendC_wD_iff]; omega
  have h1 : pendC (objAt g (0 + 1)) = true := by rw [hobj, pendC_wD_true_iff]; omega
  have heven : ((0 : ℤ) + ((2 * (PD + 1) : ℕ) : ℤ)) % 2 = 0 := by push_cast; omega
  have hobjeq : objAt g 0 = objAt g (0 + ((2 * (PD + 1) : ℕ) : ℤ)) := by
    rw [hobj, hobj, wD_of_even 0 hpar, wD_of_even _ heven]
  have htyeq := tpOf_eq_of_objAt_eq τ hτ 0 (0 + ((2 * (PD + 1) : ℕ) : ℤ)) hobjeq
  have hdvd := h paramsOkD no_stab_in_closure_aD g hg τ hτ 0 (2 * (PD + 1)) 0
    (by omega) le_rfl (by push_cast; omega) h0 h1 hobjeq htyeq
  have hle := Nat.le_of_dvd (by omega) hdvd
  omega

end Probe838B

#print axioms Probe838B.spanning_walk_not_pending
#print axioms Probe838B.spanningBlockLengthDvd_refuted
