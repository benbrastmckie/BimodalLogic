/- EIGHTEENTH PROBE -- header written in Phase 5 -/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.PlusLanguage

namespace Probe806

/-! ## The object layer, ported from the sixteenth probe

Ported from `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`.  Probes
do not import probes, so everything used below is restated here.  Only the OBJECT layer is
ported: no frame, no history, no model layer, no `cellAt`, no `tpOf`.  The fixture is
label-generic, so the frame/regularity/history layer the sixteenth probe builds on top of this
object is exactly what is NOT needed here. -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩
/-- The letter shared by `b`, `c` and `d`. -/
def bA : Atom := ⟨"b", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]
theorem bA_ne_pA : bA ≠ pA := by simp [bA, pA]
theorem bA_ne_rA : bA ≠ rA := by simp [bA, rA]
theorem bA_ne_aA : bA ≠ aA := by simp [bA, aA]

def p : PlusFormula := .atom pA
def la : PlusFormula := .atom aA

/-- `k` nested nexts. -/
def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

/-- The pending `a` state as a formula: `p AND l_a`. -/
def pa : PlusFormula := p.and la

/-- The PATTERN the 2-cycle exhibits and the 3-cycle does not: a pending `a` with a pending `a`
exactly two instants later.  It forbids no letter -- `l_a` is required, never forbidden, and no
atom of `b`, `c` or `d` appears at all. -/
def psi2 : PlusFormula := pa.and (nextPow 2 pa)

/-- Gate 6's constraint: the pattern fails here and at every strictly later instant. -/
def chi : PlusFormula := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg

/-- Object states `(pending?, index)`; pending indices `0 = a`, `1 = b`, `2 = c`, `3 = d`. -/
abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

/-- Pending edges `a → b → c → a` and `a → d → a` (a 3-cycle and a 2-cycle sharing `a`); every
pending `(true, i)` steps to its idle copy `(false, i)`; idle states self-loop. -/
def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

/-- A pending successor index: `a → b`, `b → c`, `c → a`, `d → a`. -/
def nxt : Fin 4 → Fin 4 := fun i => if i = 0 then 1 else if i = 1 then 2 else 0

/-- A pending predecessor index: `a` from `c`, `b` from `a`, `c` from `b`, `d` from `a`. -/
def prv : Fin 4 → Fin 4 :=
  fun i => if i = 0 then 2 else if i = 1 then 0 else if i = 2 then 1 else 0

theorem step5_nxt : ∀ i : Fin 4, step5 (true, i) (true, nxt i) = true := by decide

theorem step5_prv : ∀ i : Fin 4, step5 (true, prv i) (true, i) = true := by decide

/-- The index `i` pending steps after `a` along the 3-cycle. -/
def cyc (i : ℤ) : Fin 4 := ⟨(i % 3).toNat, by omega⟩

theorem cyc_cases (i : ℤ) :
    (cyc i = 0 ∧ cyc (i + 1) = 1) ∨ (cyc i = 1 ∧ cyc (i + 1) = 2) ∨
      (cyc i = 2 ∧ cyc (i + 1) = 0) := by
  have h3 : i % 3 = 0 ∨ i % 3 = 1 ∨ i % 3 = 2 := by omega
  rcases h3 with h | h | h
  · exact Or.inl ⟨Fin.ext (by change (i % 3).toNat = 0; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 1; omega)⟩
  · exact Or.inr (Or.inl ⟨Fin.ext (by change (i % 3).toNat = 1; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 2; omega)⟩)
  · exact Or.inr (Or.inr ⟨Fin.ext (by change (i % 3).toNat = 2; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 0; omega)⟩)

/-- The 3-cycle never visits `d`. -/
theorem cyc_ne_three (i : ℤ) : cyc i ≠ 3 := fun h => by
  have h' : (i % 3).toNat = 3 := congrArg Fin.val h
  omega

theorem step5_cyc_succ (i : ℤ) : step5 (true, cyc i) (true, cyc (i + 1)) = true := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;> rw [h0, h1] <;> decide

/-- **The `d`-free pending successor of a 3-cycle state is the next 3-cycle state.** -/
theorem step5_cyc (i : ℤ) (j : Fin 4) (hs : step5 (true, cyc i) (true, j) = true)
    (hj : j ≠ 3) : j = cyc (i + 1) := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;>
    (rw [h0] at hs; rw [h1]; revert j; decide)

theorem cyc_zero (c : ℕ) (h : 3 ∣ c) : cyc c = 0 :=
  Fin.ext (by change ((c : ℤ) % 3).toNat = 0; omega)

theorem dvd_of_cyc_zero (c : ℕ) (h : cyc c = 0) : 3 ∣ c := by
  have h' : ((c : ℤ) % 3).toNat = 0 := congrArg Fin.val h
  omega

/-- **`d`'s only pending predecessor is `a`.** -/
theorem pred_of_d (i : Fin 4) (hs : step5 (true, i) (true, 3) = true) : i = 0 := by
  revert i; decide

/-- **`d`'s only pending successor is `a`.** -/
theorem succ_of_d (j : Fin 4) (hs : step5 (true, 3) (true, j) = true) : j = 0 := by
  revert j; decide

/-- Gate 6's labelling: `p` pending, `r` idle, `l_a` index `0`, `l_b` every index OTHER than `0`
-- so `b`, `c` and `d` share one letter and `l_d` does not exist. -/
def lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = bA then !(q.2 == 0) else false

theorem lab6_p : ∀ q, lab6 q pA = q.1 := fun _ => by simp [lab6]
theorem lab6_r : ∀ q, lab6 q rA = !q.1 := fun _ => by simp [lab6, pA_ne_rA.symm]
theorem lab6_a : ∀ q, lab6 q aA = (q.2 == 0) := fun _ => by simp [lab6, aA_ne_pA, aA_ne_rA]

/-- One step of reachability under the object's step relation, ported byte-for-byte: the map
whose iteration `reachN_eventually_periodic` shows eventually periodic. -/
def reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

def a5 : Q5 := (true, 0)
def b5 : Q5 := (true, 1)
def c5 : Q5 := (true, 2)
def d5 : Q5 := (true, 3)

/-- From `a`, four steps reach every state. -/
theorem reach5_four : (reachStep step5)^[4] {a5} = Finset.univ := by decide

/-- Every state has a predecessor, so the full set is a fixed point of `reachStep`. -/
theorem reachStep5_univ : reachStep step5 Finset.univ = Finset.univ := by decide

/-! ## The closure-indexed carrier, restated from the seventeenth probe

Restated from `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`, which
establishes that this carrier is finite and that the operator below is eventually periodic on it.
`prodReachStep` is not needed here; the countdown iterates the BACKWARD operator. -/

/-- The closure component: a subset of `plusSubformulaClosure φ`. -/
abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

/-- The product carrier: the object paired with the closure component. -/
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

/-- One step of BACKWARD reachability in the product: the product states from which some member
of `S` is reachable in one `pstep`.  This is the operator the COUNTDOWN iterates. -/
def prodPreStep {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}
    (pstep : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

/-! ## The LOCAL coherence relation

`coh` below is built from `(Q, step, pend, lab, φ)` ALONE.  It quantifies over no history, names
no world, no `WorldHistory`, no `PlusTruthAt` and no cell; it is a computable `Bool` relation on
a finite carrier.  That is gate 7 in its definability form.

**`coh` is LOCAL coherence and it OVER-APPROXIMATES realizability.**  It imposes the Hintikka
conditions of the Boolean fragment at each endpoint and the one-step strict-until unfolding
across the step; it imposes NO fulfilment condition, so a `coh`-chain may carry an `untl`
eventuality forever without ever discharging it.  Every negative result proved through `coh`
therefore transfers to the realizable sub-relation (a smaller relation separates at least as
much), and no positive result does.  Constructing the ADEQUATE relation is the expensive half of
the first standing obligation and is not attempted here. -/

/-- The arms of the closure a LOCAL relation says nothing about: `box`, `snce` and `stab`. -/
def noModalArm : PlusFormula → Bool
  | .box _ => false | .snce _ _ => false | .stab _ => false | _ => true

/-- The Hintikka condition for one closure formula at a labelled object state.  The `box`, `untl`,
`snce` and `stab` arms are UNCONSTRAINED -- a deliberate over-approximation, and the reason gate 8
(`stab`'s self-reference through `stab_mem_tpOf_iff`) is NOT ADDRESSED by this relation. -/
def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

/-- `PlusTruthAt`'s STRICT-until unfolding across one step.  Every arm other than `untl` is
UNCONSTRAINED -- again a deliberate over-approximation; in particular nothing here constrains
`snce`, so the past direction is untouched. -/
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

/-- **The LOCAL coherence relation.**  The object step, pending-ness of BOTH endpoints (the
countdown profile lives on the pending sub-object, because `Count`'s `py ∧ px → c' + 1 = c`
clause is what makes the countdown measure distance), local coherence at both endpoints, and the
one-step strict-until link.  No history, no cell, no parameter. -/
def coh {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && pend x.1 && pend y.1 && locCoh lab φ x && locCoh lab φ y &&
    untlLink φ x.2 y.2

/-- The fixture instance: the coprime-cycle object, gate 6's labelling, gate 6's formula. -/
def coh6 : ProdState Q5 chi → ProdState Q5 chi → Bool := coh step5 pend5 lab6 chi

/-- **The unfolding lemma.**  The workhorse for every hand proof below. -/
theorem coh_iff {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x y : ProdState Q φ) :
    coh step pend lab φ x y = true ↔
      step x.1 y.1 = true ∧ pend x.1 = true ∧ pend y.1 = true ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab y.1 y.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, linkPred x.2.1 y.2.1 ψ = true) := by
  simp [coh, locCoh, untlLink, Bool.and_eq_true, and_assoc]

/-! ## Gate 6's pattern is tracked by the closure, and the fragment check -/

/-- **The closure of `chi` has no `box`, `snce` or `stab` member.**  So the unconstrained arms of
`locPred` and `linkPred` are never exercised on this fixture: gate 8 is SIDESTEPPED here, not
passed. -/
theorem chi_closure_untl_only : ∀ ψ ∈ plusSubformulaClosure chi, noModalArm ψ = true := by decide

/-- **The coherence relation lies over the object's step relation.** -/
theorem coh6_liesOver : ∀ x y : ProdState Q5 chi, coh6 x y = true → step5 x.1 y.1 = true := by
  intro x y h
  exact ((coh_iff step5 pend5 lab6 chi x y).mp h).1

/-! ## The non-vacuity witness: an explicit coherent 3-cycle of types

`coh6` could in principle be always `false`, in which case every negative lemma below would hold
trivially -- the characteristic failure mode of a definability exhibit.  The 3-cycle of types
below rules that out BEFORE any negative lemma is stated. -/

def top : PlusFormula := .imp .bot .bot
def Xpa : PlusFormula := nextPow 1 pa
def XXpa : PlusFormula := nextPow 2 pa
def B : PlusFormula := pa.imp XXpa.neg
def C : PlusFormula := p.imp la.neg
def ev : PlusFormula := PlusFormula.untl top psi2

def TaL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, pa, XXpa.neg, p, la]
def TbL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, XXpa, C, p, la.neg]
def TcL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, XXpa.neg, Xpa, C, p, la.neg]

/-- A closure type from a membership list.  Built as a `filter`, never by `decide` on
`Finset.powerset` -- the latter hits `maxRecDepth` on this closure. -/
def mkT (L : List PlusFormula) : ClType chi :=
  ⟨(plusSubformulaClosure chi).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩

def Ta : ClType chi := mkT TaL
def Tb : ClType chi := mkT TbL
def Tc : ClType chi := mkT TcL

/-- **NON-VACUITY.**  An explicit `coh6`-coherent 3-cycle of types over the object's 3-cycle,
carrying `chi`.  So `coh6` is not the empty relation and the separations below say something. -/
theorem coh6_cycle_witness :
    chi ∈ Ta.1 ∧ coh6 (a5, Ta) (b5, Tb) = true ∧ coh6 (b5, Tb) (c5, Tc) = true ∧
      coh6 (c5, Tc) (a5, Ta) = true :=
  ⟨by decide, by decide, by decide, by decide⟩

end Probe806

/-! ## Axiom check -/

#print axioms Probe806.chi_closure_untl_only
#print axioms Probe806.coh6_liesOver
#print axioms Probe806.coh6_cycle_witness
