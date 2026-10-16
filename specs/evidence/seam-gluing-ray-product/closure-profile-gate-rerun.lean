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

/-! ## Reading the local conditions and the link at one closure member

Each lemma below instantiates one of the three universally quantified conditions `coh_iff`
delivers, at a SINGLE closure formula, with the membership side condition closed by `decide`, and
turns the `Bool` equation into the propositional fact the hand proofs use.  No `decide` below is
ever applied to a goal quantifying over `ClType chi`: `decide` closes closure-membership facts
and object-graph facts only. -/

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

/-! ## The chi-consistent product never passes through `d`

The three lemmas of this section turn the claim "the pattern `psi2` and its eventuality `ev` are
closure members, hence tracked by the product" into compiled fact. -/

/-- **`chi` is in a locally coherent type exactly when the pattern and its eventuality are both
absent.**  This is the chain `chi ∈ T ⇒ (psi2.neg.imp ev.neg.neg) ∉ T ⇒ psi2.neg ∈ T ∧
ev.neg.neg ∉ T ⇒ ev.neg ∈ T ⇒ ev ∉ T`, read off one closure member at a time. -/
theorem chi_mem_iff {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    (h : ∀ ψ ∈ plusSubformulaClosure chi, locPred lab q T ψ = true) :
    chi ∈ T ↔ (psi2 ∉ T ∧ ev ∉ T) := by
  have hbot : PlusFormula.bot ∉ T := loc_bot h (by decide)
  have e0 : chi ∈ T ↔ (psi2.neg.imp ev.neg.neg) ∉ T :=
    loc_neg h hbot (psi2.neg.imp ev.neg.neg) (by decide)
  have e1 : (psi2.neg.imp ev.neg.neg) ∈ T ↔ (psi2.neg ∉ T ∨ ev.neg.neg ∈ T) :=
    loc_imp h psi2.neg ev.neg.neg (by decide)
  have e2 : psi2.neg ∈ T ↔ psi2 ∉ T := loc_neg h hbot psi2 (by decide)
  have e3 : ev.neg.neg ∈ T ↔ ev.neg ∉ T := loc_neg h hbot ev.neg (by decide)
  have e4 : ev.neg ∈ T ↔ ev ∉ T := loc_neg h hbot ev (by decide)
  rw [e0]; tauto

/-- **At the pending `a` state the type is forced to contain the pattern's first conjunct.**  Only
`a5`'s OWN atoms are read, which is the compiled form of "the pattern forbids no letter". -/
theorem pa_mem_of_a {T : Finset PlusFormula}
    (h : ∀ ψ ∈ plusSubformulaClosure chi, locPred lab6 a5 T ψ = true) : pa ∈ T := by
  have hbot : PlusFormula.bot ∉ T := loc_bot h (by decide)
  have hp : p ∈ T ↔ lab6 a5 pA = true := loc_atom h pA (by decide)
  have hla : la ∈ T ↔ lab6 a5 aA = true := loc_atom h aA (by decide)
  have hpT : p ∈ T := hp.mpr (by decide)
  have hlaT : la ∈ T := hla.mpr (by decide)
  have e0 : pa ∈ T ↔ (p.imp la.neg) ∉ T := loc_neg h hbot (p.imp la.neg) (by decide)
  have e1 : (p.imp la.neg) ∈ T ↔ (p ∉ T ∨ la.neg ∈ T) := loc_imp h p la.neg (by decide)
  have e2 : la.neg ∈ T ↔ la ∉ T := loc_neg h hbot la (by decide)
  rw [e0]; tauto

/-- **`chi` propagates forward along every `coh6` step.**  `ev = top U psi2` is a closure member,
so the link condition carries the absence of the eventuality across the step, and `top` is forced
into every locally coherent type. -/
theorem coh6_chi_propagates (x y : ProdState Q5 chi) (h : coh6 x y = true)
    (hc : chi ∈ x.2.1) : chi ∈ y.2.1 := by
  obtain ⟨-, -, -, hx, hy, hl⟩ := (coh_iff step5 pend5 lab6 chi x y).mp h
  have hbotY : PlusFormula.bot ∉ y.2.1 := loc_bot hy (by decide)
  have hex : psi2 ∉ x.2.1 ∧ ev ∉ x.2.1 := (chi_mem_iff hx).mp hc
  have l1 : ev ∈ x.2.1 ↔ (psi2 ∈ y.2.1 ∨ (top ∈ y.2.1 ∧ ev ∈ y.2.1)) :=
    link_untl hl top psi2 (by decide)
  have htop : top ∈ y.2.1 := by
    have e : top ∈ y.2.1 ↔ (PlusFormula.bot ∉ y.2.1 ∨ PlusFormula.bot ∈ y.2.1) :=
      loc_imp hy PlusFormula.bot PlusFormula.bot (by decide)
    exact e.mpr (Or.inl hbotY)
  have hnpsi : psi2 ∉ y.2.1 := fun hpsi => hex.2 (l1.mpr (Or.inl hpsi))
  have hnev : ev ∉ y.2.1 := fun hev => hex.2 (l1.mpr (Or.inr ⟨htop, hev⟩))
  exact (chi_mem_iff hy).mpr ⟨hnpsi, hnev⟩

/-- **The `chi`-consistent product never passes through `d`.**  An `a`-`d`-`a` segment forces the
pattern `psi2` into the type at the first `a`: `pa` holds at both `a` endpoints, the link on
`Xpa = X pa` carries `pa` back one step and the link on `XXpa = X X pa` carries it back a second,
so `XXpa` is in the first type, `B` is not, `psi2` is, and `chi` is not.  `d5`'s LABELLING is never
read -- which is exactly the compiled form of "the pattern forbids no letter". -/
theorem coh6_no_a_d_a (T T' T'' : ClType chi) (h1 : coh6 (a5, T) (d5, T') = true)
    (h2 : coh6 (d5, T') (a5, T'') = true) : chi ∉ T.1 := by
  obtain ⟨-, -, -, hx, hy, hl⟩ := (coh_iff step5 pend5 lab6 chi (a5, T) (d5, T')).mp h1
  obtain ⟨-, -, -, -, hz, hl2⟩ := (coh_iff step5 pend5 lab6 chi (d5, T') (a5, T'')).mp h2
  have hxT : ∀ ψ ∈ plusSubformulaClosure chi, locPred lab6 a5 T.1 ψ = true := hx
  have hzT : ∀ ψ ∈ plusSubformulaClosure chi, locPred lab6 a5 T''.1 ψ = true := hz
  have hlT : ∀ ψ ∈ plusSubformulaClosure chi, linkPred T.1 T'.1 ψ = true := hl
  have hl2T : ∀ ψ ∈ plusSubformulaClosure chi, linkPred T'.1 T''.1 ψ = true := hl2
  have hbotT : PlusFormula.bot ∉ T.1 := loc_bot hxT (by decide)
  have hpaT : pa ∈ T.1 := pa_mem_of_a hxT
  have hpaT'' : pa ∈ T''.1 := pa_mem_of_a hzT
  have lXpa : Xpa ∈ T'.1 ↔ (pa ∈ T''.1 ∨ (PlusFormula.bot ∈ T''.1 ∧ Xpa ∈ T''.1)) :=
    link_untl hl2T PlusFormula.bot pa (by decide)
  have hXpa : Xpa ∈ T'.1 := lXpa.mpr (Or.inl hpaT'')
  have lXXpa : XXpa ∈ T.1 ↔ (Xpa ∈ T'.1 ∨ (PlusFormula.bot ∈ T'.1 ∧ XXpa ∈ T'.1)) :=
    link_untl hlT PlusFormula.bot Xpa (by decide)
  have hXXpa : XXpa ∈ T.1 := lXXpa.mpr (Or.inl hXpa)
  have e0 : psi2 ∈ T.1 ↔ B ∉ T.1 := loc_neg hxT hbotT B (by decide)
  have e1 : B ∈ T.1 ↔ (pa ∉ T.1 ∨ XXpa.neg ∈ T.1) := loc_imp hxT pa XXpa.neg (by decide)
  have e2 : XXpa.neg ∈ T.1 ↔ XXpa ∉ T.1 := loc_neg hxT hbotT XXpa (by decide)
  have hpsi2 : psi2 ∈ T.1 := by rw [e0]; tauto
  intro hchi
  exact ((chi_mem_iff hxT).mp hchi).1 hpsi2

/-- **A `d`-free `coh6`-chain out of `a` follows the 3-cycle.**  `walk_mod3`'s shape with the
admissible-ladder run replaced by a `coh6` chain: the pending conjunct of `coh_iff` splits each
successor state's pair, and the ported `step5_cyc` does the rest. -/
theorem chain_cyc (g : ℕ → ProdState Q5 chi) (k : ℕ)
    (hg : ∀ i, i < k → coh6 (g i) (g (i + 1)) = true) (h0 : (g 0).1 = a5)
    (hd : ∀ j, j ≤ k → (g j).1 ≠ d5) :
    ∀ i, i ≤ k → (g i).1 = (true, cyc (i : ℤ)) := by
  intro i
  induction i with
  | zero => intro _; rw [h0]; rfl
  | succ i ih =>
    intro hik
    have hprev := ih (by omega)
    have hc := hg i (by omega)
    have hp : pend5 (g (i + 1)).1 = true :=
      ((coh_iff step5 pend5 lab6 chi (g i) (g (i + 1))).mp hc).2.2.1
    have hp' : (g (i + 1)).1.1 = true := hp
    have hq : (g (i + 1)).1 = (true, (g (i + 1)).1.2) := by rw [← hp']
    have hne : (g (i + 1)).1.2 ≠ 3 := by
      intro hthree
      exact hd (i + 1) hik (by rw [hq, hthree]; rfl)
    have hstep : step5 (true, cyc (i : ℤ)) (true, (g (i + 1)).1.2) = true := by
      have := coh6_liesOver (g i) (g (i + 1)) hc
      rw [hprev, hq] at this
      exact this
    have hcast : ((i : ℤ) + 1) = ((i + 1 : ℕ) : ℤ) := by push_cast; ring
    have hcyc := step5_cyc (i : ℤ) (g (i + 1)).1.2 hstep hne
    rw [hcast] at hcyc
    rw [hq, hcyc]

/-- **Every `coh6`-chain from a `chi`-carrying `a` back to `a` has length divisible by three.**
This is gate 6's separation on the real fixture: the pattern `psi2` is a closure member, so the
product tracks it, so the 3-cycle is carved out -- with no letter naming it and no parameter to
choose. -/
theorem coh6_chain_a_to_a_mod3 (g : ℕ → ProdState Q5 chi) (k : ℕ)
    (hg : ∀ i, i < k → coh6 (g i) (g (i + 1)) = true) (h0 : (g 0).1 = a5)
    (hchi : chi ∈ (g 0).2.1) (hk : (g k).1 = a5) : 3 ∣ k := by
  have hall : ∀ i, i ≤ k → chi ∈ (g i).2.1 := by
    intro i
    induction i with
    | zero => intro _; exact hchi
    | succ i ih =>
      intro hik
      exact coh6_chi_propagates (g i) (g (i + 1)) (hg i (by omega)) (ih (by omega))
  have hd : ∀ j, j ≤ k → (g j).1 ≠ d5 := by
    intro j hj hjd
    have hj0 : j ≠ 0 := by
      intro he; rw [he, h0] at hjd; exact absurd hjd (by decide)
    have hjk : j ≠ k := by
      intro he; rw [he, hk] at hjd; exact absurd hjd (by decide)
    obtain ⟨j', rfl⟩ : ∃ j', j = j' + 1 := ⟨j - 1, by omega⟩
    have hc1 := hg j' (by omega)
    have hc2 := hg (j' + 1) (by omega)
    have hpa : pend5 (g j').1 = true :=
      ((coh_iff step5 pend5 lab6 chi (g j') (g (j' + 1))).mp hc1).2.1
    have hpa' : (g j').1.1 = true := hpa
    have hqa : (g j').1 = (true, (g j').1.2) := by rw [← hpa']
    have hpc : pend5 (g (j' + 1 + 1)).1 = true :=
      ((coh_iff step5 pend5 lab6 chi (g (j' + 1)) (g (j' + 1 + 1))).mp hc2).2.2.1
    have hpc' : (g (j' + 1 + 1)).1.1 = true := hpc
    have hqc : (g (j' + 1 + 1)).1 = (true, (g (j' + 1 + 1)).1.2) := by rw [← hpc']
    have hstep1 : step5 (true, (g j').1.2) (true, 3) = true := by
      have := coh6_liesOver (g j') (g (j' + 1)) hc1
      rw [hqa, hjd] at this
      exact this
    have hstep2 : step5 (true, 3) (true, (g (j' + 1 + 1)).1.2) = true := by
      have := coh6_liesOver (g (j' + 1)) (g (j' + 1 + 1)) hc2
      rw [hjd, hqc] at this
      exact this
    have ha1 : (g j').1 = a5 := by rw [hqa, pred_of_d _ hstep1]; rfl
    have ha2 : (g (j' + 1 + 1)).1 = a5 := by rw [hqc, succ_of_d _ hstep2]; rfl
    have eq1 : ((a5, (g j').2) : ProdState Q5 chi) = g j' := by rw [← ha1]
    have eq2 : ((d5, (g (j' + 1)).2) : ProdState Q5 chi) = g (j' + 1) := by rw [← hjd]
    have eq3 : ((a5, (g (j' + 1 + 1)).2) : ProdState Q5 chi) = g (j' + 1 + 1) := by rw [← ha2]
    have c1 : coh6 (a5, (g j').2) (d5, (g (j' + 1)).2) = true := by rw [eq1, eq2]; exact hc1
    have c2 : coh6 (d5, (g (j' + 1)).2) (a5, (g (j' + 1 + 1)).2) = true := by
      rw [eq2, eq3]; exact hc2
    exact coh6_no_a_d_a (g j').2 (g (j' + 1)).2 (g (j' + 1 + 1)).2 c1 c2 (hall j' (by omega))
  have hcyck := chain_cyc g k hg h0 hd k le_rfl
  rw [hk] at hcyck
  have hc0 : cyc (k : ℤ) = 0 := by
    have := congrArg Prod.snd hcyck
    simpa [a5] using this.symm
  exact dvd_of_cyc_zero k hc0

/-! ## The countdown profile, and the separation gate 6 refuted the sixth index with

The datum below is a SET-valued per-state datum over the object-closure product, quotiented
implicitly by the kernel of the profile map (two product states are identified exactly when they
lie in the same `Prof6 k` for every `k`).  It carries NO parameter: no threshold, no modulus, no
clip bound.  That is why the separations below hold for EVERY `P`, with nothing to choose. -/

/-- The fibre over the pending `a` state -- the state the region's last pending state is, on this
fixture.  The countdown measures distance to this set. -/
def Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)

/-- **The countdown profile at distance `k`**: the set of product states from which a `coh6`-chain
of length `k` reaches the fibre `Ea`.  Parameter-free. -/
def Prof6 (k : ℕ) : Finset (ProdState Q5 chi) := (prodPreStep coh6)^[k] Ea

theorem prof6_succ (k : ℕ) : Prof6 (k + 1) = prodPreStep coh6 (Prof6 k) := by
  simp only [Prof6, Function.iterate_succ_apply']

theorem mem_prof6_succ (x : ProdState Q5 chi) (k : ℕ) :
    x ∈ Prof6 (k + 1) ↔ ∃ y ∈ Prof6 k, coh6 x y = true := by
  rw [prof6_succ]
  simp [prodPreStep]

/-- Prepend a state to a chain. -/
def consChain (x : ProdState Q5 chi) (g : ℕ → ProdState Q5 chi) : ℕ → ProdState Q5 chi
  | 0 => x
  | j + 1 => g j

/-- **Membership in the profile at distance `k` exhibits a `coh6`-chain of length `k` into the
fibre.**  The converse direction of the profile's definition, unfolded into a chain. -/
theorem prof6_chain (x : ProdState Q5 chi) (k : ℕ) (h : x ∈ Prof6 k) :
    ∃ g : ℕ → ProdState Q5 chi, g 0 = x ∧ (∀ i, i < k → coh6 (g i) (g (i + 1)) = true) ∧
      (g k).1 = a5 := by
  induction k generalizing x with
  | zero =>
    refine ⟨fun _ => x, rfl, fun i hi => absurd hi (by omega), ?_⟩
    have hx : x ∈ Ea := by simpa [Prof6] using h
    simpa [Ea] using hx
  | succ k ih =>
    obtain ⟨y, hy, hxy⟩ := (mem_prof6_succ x k).mp h
    obtain ⟨g, hg0, hgc, hgk⟩ := ih y hy
    refine ⟨consChain x g, rfl, ?_, ?_⟩
    · intro i hi
      cases i with
      | zero => show coh6 x (g 0) = true; rw [hg0]; exact hxy
      | succ j => exact hgc j (by omega)
    · exact hgk

/-- **The `a`-fibre of the profile is empty except at the multiples of three**, for every type
carrying `chi`.  Gate 6's 3-cycle, read off the profile. -/
theorem prof6_fibre_a_of_mem (k : ℕ) (T : ClType chi) (hT : chi ∈ T.1)
    (h : (a5, T) ∈ Prof6 k) : 3 ∣ k := by
  obtain ⟨g, hg0, hgc, hgk⟩ := prof6_chain (a5, T) k h
  refine coh6_chain_a_to_a_mod3 g k hgc ?_ ?_ hgk
  · rw [hg0]
  · rw [hg0]; exact hT

/-- **And it is nonempty at every multiple of three**, witnessed by the coherent 3-cycle. -/
theorem prof6_fibre_a_witness (k : ℕ) (hk : 3 ∣ k) : (a5, Ta) ∈ Prof6 k := by
  obtain ⟨m, rfl⟩ := hk
  induction m with
  | zero => simp [Prof6, Ea]
  | succ m ih =>
    have w := coh6_cycle_witness
    rw [show 3 * (m + 1) = 3 * m + 1 + 1 + 1 by ring]
    refine (mem_prof6_succ _ _).mpr ⟨(b5, Tb), ?_, w.2.1⟩
    refine (mem_prof6_succ _ _).mpr ⟨(c5, Tc), ?_, w.2.2.1⟩
    exact (mem_prof6_succ _ _).mpr ⟨(a5, Ta), ih, w.2.2.2⟩

/-- **THE COUNTDOWN PROFILE SEPARATES THE EXACT PAIR GATE 6 USED TO REFUTE THE SIXTH INDEX**, for
EVERY modulus coprime to three, with no parameter to choose.  The two countdowns are the sixteenth
probe's `x5`/`y5` countdowns -- `C` with `3 ∣ C`, and `C + (P+1)` -- and the hypotheses name only
the PAIR: there is no threshold, no modulus and no clip bound to instantiate, because this datum
has none. -/
theorem prof6_separates_gate6_pair (C P : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1)) :
    Prof6 C ≠ Prof6 (C + (P + 1)) := by
  intro h
  have hmem : (a5, Ta) ∈ Prof6 C := prof6_fibre_a_witness C hC
  rw [h] at hmem
  have h1 : 3 ∣ C + (P + 1) := prof6_fibre_a_of_mem _ Ta coh6_cycle_witness.1 hmem
  exact h3 (by omega)

/-- **The profile's period is not one**, at every multiple of three. -/
theorem prof6_period_not_one (k : ℕ) (hk : 3 ∣ k) : Prof6 (k + 1) ≠ Prof6 k := by
  intro h
  have hmem : (a5, Ta) ∈ Prof6 k := prof6_fibre_a_witness k hk
  rw [← h] at hmem
  have h1 : 3 ∣ k + 1 := prof6_fibre_a_of_mem _ Ta coh6_cycle_witness.1 hmem
  omega

/-- **GATE 5'S CONTRAST, on the same fixture.**  The OBJECT's full-graph reach set is CONSTANT
from threshold four -- period one, exactly the shape `reachN_eventually_periodic` returns, and
minimal -- while the profile's `a`-fibre is nonempty at exactly the multiples of three for
`chi`-types.  So the object's exhibited period does not bind the profile, and gate 5's disarming
mechanism (a modulus admissible for the object's own graph) does not reach this datum. -/
theorem reach5_eventually_constant :
    ∀ k : ℕ, 4 ≤ k → (reachStep step5)^[k + 1] {a5} = (reachStep step5)^[k] {a5} := by
  intro k hk
  obtain ⟨m, rfl⟩ : ∃ m, k = 4 + m := ⟨k - 4, by omega⟩
  have huniv : ∀ m, (reachStep step5)^[4 + m] {a5} = Finset.univ := by
    intro m
    induction m with
    | zero => exact reach5_four
    | succ m ih =>
      rw [show 4 + (m + 1) = (4 + m) + 1 by omega, Function.iterate_succ_apply', ih,
        reachStep5_univ]
  rw [show 4 + m + 1 = 4 + (m + 1) by omega, huniv, huniv]

end Probe806

/-! ## Axiom check -/

#print axioms Probe806.chi_closure_untl_only
#print axioms Probe806.coh6_liesOver
#print axioms Probe806.coh6_cycle_witness
#print axioms Probe806.coh6_chi_propagates
#print axioms Probe806.coh6_no_a_d_a
#print axioms Probe806.coh6_chain_a_to_a_mod3
#print axioms Probe806.prof6_fibre_a_of_mem
#print axioms Probe806.prof6_fibre_a_witness
#print axioms Probe806.prof6_separates_gate6_pair
#print axioms Probe806.prof6_period_not_one
#print axioms Probe806.reach5_eventually_constant
