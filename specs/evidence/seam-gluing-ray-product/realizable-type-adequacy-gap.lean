/-
LOCAL COHERENCE ADMITS A FORWARD-INFINITE CHAIN CARRYING AN `untl` EVENTUALITY THAT IS NEVER
DISCHARGED, ON THE VERY FIXTURE THE EIGHTEENTH PROBE'S GATE TABLE WAS RUN ON: the countdown
profile's membership witnesses are therefore NOT realizability witnesses, and the adequacy half of
the first standing obligation is a gap EXHIBITED rather than merely scoped.  `evTa`/`evTb`/`evTc`
is a `coh6`-coherent 3-cycle of closure types carrying `ev = T U psi2` at every position and
`psi2` at none, so the eventuality is passed forward forever and its event never delivered; the
cycle sits in the profile at every multiple of three (`prof6_ev_witness`).  What this does NOT
say: it does not refute the countdown profile, it does not refute any gate verdict of the
eighteenth probe, it constructs NO adequate relation, and it is not a statement about
`PlusTruthAt`, `tpOf`, `cellAt` or any cell -- no clause of the truth definition is unfolded here
and no history, world or model appears.

## What was asked

The eighteenth probe (`specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean`)
records, in its own header, that its coherence relation `coh6` is LOCAL coherence, that it
over-approximates realizability, and that the ADEQUATE relation -- one computing the REALIZABLE
types, with `untl`/`snce` fulfilment -- is OPEN and is the expensive half of the first standing
obligation.  That record states the over-approximation as a property of the DEFINITION (`coh`
imposes no fulfilment clause).  What it does not do is exhibit a witness: a concrete
`coh6`-coherent run on which the over-approximation is strict.  Without such a witness, "the
profile over-approximates" is a reading of a definition rather than a fact about the fixture, and
a plan could rationally treat the gap as an artefact of a conservative definition that disappears
once the real relation is written.  This probe closes exactly that reading, and nothing else.

## The verdict

On the coprime-cycle object with gate 6's labelling and gate 6's formula `chi`, there is a
`coh6`-coherent 3-cycle of closure types -- `evTa` at the pending `a`, `evTb` at `b`, `evTc` at
`c` -- which

  - carries `ev = PlusFormula.untl top psi2` at all three positions (`ev_mem_evTa`, and the
    conjunction `ev_mem_all`), and
  - contains `psi2` at NONE of them (`psi2_not_mem_all`).

So the forward-infinite chain `evRay` obtained by running that cycle (`evRay_coh`) carries the
eventuality `ev` at every position (`evRay_carries`) and never delivers its event
(`evRay_no_event`), hence has no fulfilling time at any position (`evRay_unfulfilled`) -- the
exact negation of the fulfilment clause `PlusTruthAt`'s `untl` case demands and of the condition
`FormalSystem.Metalogic.Decidability.Fulfilling` (`BiLasso/Annotation.lean`) and
`PlusSharingWitnessFamily.PlusThreadFulfilling` (`PlusWitnessFamily/Predicates.lean`) impose.
The cycle lies in the profile at every multiple of three (`prof6_ev_witness`), so the profile's
own membership witnesses include chains of this kind.

The three types do NOT carry `chi` (`chi_not_mem_all`), and that is not a weakening of the
exhibit -- it is the compiled reason this probe does not collide with the eighteenth probe's
`coh6_no_a_d_a`, whose hypothesis is a `chi`-carrying type.  `chi` is the gate-6 CONSTRAINT, not
part of the coherence relation: `coh6` constrains every closure member, `chi` among them, by the
Hintikka biconditionals, and a type that falsifies `chi` is as coherent as one that satisfies it.
A reader who expects `chi` in every type of this fixture is reading the constraint as an axiom of
the relation, which it is not.

## Why this is the right witness and not a stronger one

Two stronger statements are deliberately NOT made here.

  - **`(a5, evTa)` is not claimed non-realizable.**  `psi2` is satisfiable on this object only
    through the 2-cycle `a -> d -> a`, which a `chi`-free type may enter; so some OTHER
    `coh6`-chain out of `(a5, evTa)` may well discharge `ev`.  What is exhibited is that local
    coherence does not FORCE discharge, which is what adequacy needs and what the profile's
    `pre`-iteration cannot see.
  - **No fulfilment-refined profile is defined.**  Intersecting the carrier with a
    fulfilment-respecting subset is the adequacy construction itself; it is the open obligation,
    not this probe's content.

## What this does NOT say

  - **Nothing here refutes the countdown profile, and no gate verdict of the eighteenth probe is
     changed.**  Gates 3-7 stand exactly as that probe records them; gate 8 remains SIDESTEPPED
     on this `stab`-free fixture; gates 1, 2 remain NOT ADDRESSED and gate 9 OPEN.  This file
     adds no gate and settles none.
  - **No adequate relation is constructed, and none is sketched in Lean.**  `coh6` is reproduced
     here unchanged from the eighteenth probe; not one clause is added, strengthened or removed.
  - **Nothing here is a factorization lemma, a cell index, or any part of one.**  No declaration
     named `ladderRealized`, `LadderCons` or `ladderCons_localRun` appears, under those names or
     any others, and no same-named weaker substitute for any of them is stated, with or without
     the `box`/`stab` clause.
  - **No clause of `PlusTruthAt` is unfolded and no cell is computed.**  `tpOf`, `cellAt`,
     `WorldHistory`, `PlusTruthAt` and `Rlad` appear in no declaration of this file.  The
     eventuality and its non-discharge are statements about the LABELS of a chain, which is the
     only level at which a local relation can be gated.
  - **One fixture is one fixture.**  The exhibit is on the coprime-cycle object with gate 6's
     labelling and gate 6's formula.  A gate probing one coordinate certifies one coordinate
     only.
  - **The SET of cells was never in question.**  `anchorCells_finite` and `anchorCells_ncard_le`
     already bound it; only the computable INDEX is open, and this file does not close it.
  - **No seventh tuple coordinate is proposed.**  The tuple-widening line is spent and nothing
     here reopens it.

Compile:
`lake env lean specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.PlusLanguage

namespace Probe809

/-! ## The object layer, the closure carrier and the LOCAL coherence relation

All of this section is ported VERBATIM from
`specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` (itself porting the
object layer from `ladder-joint-index-refutation.lean` and the carrier from
`closure-indexed-periodicity.lean`).  Probes do not import probes, so everything used below is
restated here.  Nothing in this section is new, and nothing in it is changed: in particular `coh`
carries exactly the clauses it carries there -- object step, pending-ness of both endpoints,
local coherence at both endpoints, and the one-step strict-until link -- and NO fulfilment
clause. -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩
/-- The letter shared by `b`, `c` and `d`. -/
def bA : Atom := ⟨"b", none⟩

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

/-- The Hintikka condition for one closure formula at a labelled object state. -/
def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

/-- `PlusTruthAt`'s STRICT-until unfolding across one step. -/
def linkPred (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.untl g e) =>
      decide (ψ ∈ T) == (decide (e ∈ T') || (decide (g ∈ T') && decide (ψ ∈ T')))
  | _ => true

def locCoh {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (x : ProdState Q φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true)

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

/-- **The countdown profile at distance `k`.** -/
def Prof6 (k : ℕ) : Finset (ProdState Q5 chi) := (prodPreStep coh6)^[k] Ea

theorem prof6_succ (k : ℕ) : Prof6 (k + 1) = prodPreStep coh6 (Prof6 k) := by
  simp only [Prof6, Function.iterate_succ_apply']

theorem mem_prof6_succ (x : ProdState Q5 chi) (k : ℕ) :
    x ∈ Prof6 (k + 1) ↔ ∃ y ∈ Prof6 k, coh6 x y = true := by
  rw [prof6_succ]
  simp [prodPreStep]

/-! ## The eventuality, and the three types that carry it forever

`ev` is the eventuality gate 6's constraint `chi` DENIES; the types below are the same three the
eighteenth probe's non-vacuity witness uses, with that denial replaced by its affirmation.  Every
member below is a subformula of `chi`, so each list is a list of closure members and `mkT`
discards nothing:

  `chi = ((psi2.neg).imp (ev.neg).neg).neg`, so `dd := psi2.neg.imp evnn` and `evnn := ev.neg.neg`
  are subformulas of `chi`; `psi2 = (pa.imp xxpa.neg).neg` gives `bb`, `xxpa`, `xpa`, `pa`; and
  `pa = (p.imp la.neg).neg` gives `cc`, `la.neg`, `p`, `la`. -/

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

def evTaL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, pa, xxpa.neg, p, la]
def evTbL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa, cc, p, la.neg]
def evTcL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def evTa : ClType chi := mkT evTaL
def evTb : ClType chi := mkT evTbL
def evTc : ClType chi := mkT evTcL

/-! ## The exhibit -/

/-- **A `coh6`-coherent 3-cycle.**  Landed BEFORE every statement about what it fails to deliver,
which is the discipline a non-vacuity obligation asks for: a cycle that did not cohere would make
every claim below vacuous. -/
theorem ev_cycle_witness :
    coh6 (a5, evTa) (b5, evTb) = true ∧ coh6 (b5, evTb) (c5, evTc) = true ∧
      coh6 (c5, evTc) (a5, evTa) = true :=
  ⟨by decide, by decide, by decide⟩

/-- **The eventuality is carried at every position of the cycle.** -/
theorem ev_mem_all : ev ∈ evTa.1 ∧ ev ∈ evTb.1 ∧ ev ∈ evTc.1 :=
  ⟨by decide, by decide, by decide⟩

theorem ev_mem_evTa : ev ∈ evTa.1 := ev_mem_all.1

/-- **Its event is delivered at no position of the cycle.** -/
theorem psi2_not_mem_all : psi2 ∉ evTa.1 ∧ psi2 ∉ evTb.1 ∧ psi2 ∉ evTc.1 :=
  ⟨by decide, by decide, by decide⟩

/-- **The three types falsify gate 6's constraint**, which is why this exhibit does not collide
with the eighteenth probe's `coh6_no_a_d_a`: that lemma's hypothesis is a `chi`-CARRYING type.
`chi` is the constraint, not a clause of the relation. -/
theorem chi_not_mem_all : chi ∉ evTa.1 ∧ chi ∉ evTb.1 ∧ chi ∉ evTc.1 :=
  ⟨by decide, by decide, by decide⟩

/-! ## The forward-infinite chain, and the fulfilment clause it falsifies -/

/-- The forward-infinite run of the cycle. -/
def evRay : ℕ → ProdState Q5 chi := fun k =>
  if k % 3 = 0 then (a5, evTa) else if k % 3 = 1 then (b5, evTb) else (c5, evTc)

theorem evRay_zero : evRay 0 = (a5, evTa) := by simp [evRay]

/-- **It is a `coh6`-chain at every step.** -/
theorem evRay_coh (k : ℕ) : coh6 (evRay k) (evRay (k + 1)) = true := by
  have h : k % 3 = 0 ∨ k % 3 = 1 ∨ k % 3 = 2 := by omega
  rcases h with h | h | h
  · have h1 : (k + 1) % 3 = 1 := by omega
    rw [show evRay k = (a5, evTa) from by simp [evRay, h],
      show evRay (k + 1) = (b5, evTb) from by simp [evRay, h1]]
    exact ev_cycle_witness.1
  · have h1 : (k + 1) % 3 = 2 := by omega
    rw [show evRay k = (b5, evTb) from by simp [evRay, h],
      show evRay (k + 1) = (c5, evTc) from by simp [evRay, h1]]
    exact ev_cycle_witness.2.1
  · have h1 : (k + 1) % 3 = 0 := by omega
    rw [show evRay k = (c5, evTc) from by simp [evRay, h],
      show evRay (k + 1) = (a5, evTa) from by simp [evRay, h1]]
    exact ev_cycle_witness.2.2

/-- **The eventuality is carried at every position.** -/
theorem evRay_carries (k : ℕ) : ev ∈ (evRay k).2.1 := by
  have h : k % 3 = 0 ∨ k % 3 = 1 ∨ k % 3 = 2 := by omega
  rcases h with h | h | h
  · rw [show evRay k = (a5, evTa) from by simp [evRay, h]]; exact ev_mem_all.1
  · rw [show evRay k = (b5, evTb) from by simp [evRay, h]]; exact ev_mem_all.2.1
  · rw [show evRay k = (c5, evTc) from by simp [evRay, h]]; exact ev_mem_all.2.2

/-- **Its event is delivered at no position.** -/
theorem evRay_no_event (k : ℕ) : psi2 ∉ (evRay k).2.1 := by
  have h : k % 3 = 0 ∨ k % 3 = 1 ∨ k % 3 = 2 := by omega
  rcases h with h | h | h
  · rw [show evRay k = (a5, evTa) from by simp [evRay, h]]; exact psi2_not_mem_all.1
  · rw [show evRay k = (b5, evTb) from by simp [evRay, h]]; exact psi2_not_mem_all.2.1
  · rw [show evRay k = (c5, evTc) from by simp [evRay, h]]; exact psi2_not_mem_all.2.2

/-- **THE EXHIBIT.**  At every position of a `coh6`-chain, the eventuality `ev` is in the label
and there is NO strictly later position whose label contains its event `psi2`.  That is the exact
negation of the fulfilment clause `PlusTruthAt`'s `untl` case demands, and of the condition
`Fulfilling` / `PlusThreadFulfilling` impose on a label sequence.  So local coherence does not
force discharge, and the countdown profile's `pre`-iteration -- which asks only for a
`coh6`-chain -- cannot see the difference. -/
theorem evRay_unfulfilled (k : ℕ) :
    ev ∈ (evRay k).2.1 ∧ ¬ ∃ s : ℕ, k < s ∧ psi2 ∈ (evRay s).2.1 :=
  ⟨evRay_carries k, fun ⟨s, _, hs⟩ => evRay_no_event s hs⟩

/-- **And the cycle sits in the profile at every multiple of three**, so the profile's own
membership witnesses include chains of this kind.  Mirrors the eighteenth probe's
`prof6_fibre_a_witness` at the unfulfilled cycle instead of the `chi`-carrying one. -/
theorem prof6_ev_witness (k : ℕ) (hk : 3 ∣ k) : (a5, evTa) ∈ Prof6 k := by
  obtain ⟨m, rfl⟩ := hk
  induction m with
  | zero => simp [Prof6, Ea]
  | succ m ih =>
    have w := ev_cycle_witness
    rw [show 3 * (m + 1) = 3 * m + 1 + 1 + 1 by ring]
    refine (mem_prof6_succ _ _).mpr ⟨(b5, evTb), ?_, w.1⟩
    refine (mem_prof6_succ _ _).mpr ⟨(c5, evTc), ?_, w.2.1⟩
    exact (mem_prof6_succ _ _).mpr ⟨(a5, evTa), ih, w.2.2⟩

end Probe809

/-! ## Axiom check -/

#print axioms Probe809.ev_cycle_witness
#print axioms Probe809.ev_mem_all
#print axioms Probe809.psi2_not_mem_all
#print axioms Probe809.chi_not_mem_all
#print axioms Probe809.evRay_coh
#print axioms Probe809.evRay_carries
#print axioms Probe809.evRay_no_event
#print axioms Probe809.evRay_unfulfilled
#print axioms Probe809.prof6_ev_witness
