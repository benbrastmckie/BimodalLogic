/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

/-!
# Formula Test Suite

Tests for the Formula inductive type and derived operators.

## Test Categories

- Formula construction (atom, bot, imp, box, past, future)
- Decidable equality
- Structural complexity measure
- Derived Boolean operators (neg, and, or)
- Derived modal operators (diamond)
- Derived temporal operators (always, sometimes, some_past, some_future)
- Temporal duality (swap_temporal)
-/

namespace BimodalTest.Syntax

open FormalSystem.Syntax

-- Test: Formula atom construction
example : Formula.atomS "p" = Formula.atomS "p" := rfl

-- Test: Formula bot construction
example : Formula.bot = Formula.bot := rfl

-- Test: Formula implication construction
example (p q : Formula) : (Formula.imp p q) = (Formula.imp p q) := rfl

-- Test: Formula box construction
example (p : Formula) : (Formula.box p) = (Formula.box p) := rfl

-- Test: Formula all_past construction
example (p : Formula) : (Formula.allPast p) = (Formula.allPast p) := rfl

-- Test: Formula all_future construction
example (p : Formula) : (Formula.allFuture p) = (Formula.allFuture p) := rfl

-- Test: Decidable equality - same atoms
example : (Formula.atomS "p") = (Formula.atomS "p") := rfl

-- Test: Decidable equality - different atoms
example : (Formula.atomS "p") ≠ (Formula.atomS "q") := by
  intro h
  injection h with h'
  contradiction

-- Test: Decidable equality - bot
example : Formula.bot = Formula.bot := rfl

-- Test: Decidable equality - complex formulas
example :
  (Formula.imp (Formula.atomS "p") (Formula.atomS "q")) =
  (Formula.imp (Formula.atomS "p") (Formula.atomS "q")) := rfl

-- Test: Complexity of atom
example : (Formula.atomS "p").complexity = 1 := rfl

-- Test: Complexity of bot
example : Formula.bot.complexity = 1 := rfl

-- Test: Complexity of implication
example : ((Formula.atomS "p").imp (Formula.atomS "q")).complexity = 3 := rfl

-- Test: Complexity of box
example : ((Formula.atomS "p").box).complexity = 2 := rfl

-- Test: Complexity of nested formula
example : ((Formula.atomS "p").box.imp (Formula.atomS "q").box).complexity = 5 := rfl

-- Test: Derived negation operator
example (p : Formula) : p.neg = (p.imp Formula.bot) := rfl

-- Test: Derived conjunction operator
example (p q : Formula) : (p.and q) = ((p.imp q.neg).neg) := rfl

-- Test: Derived disjunction operator
example (p q : Formula) : (p.or q) = (p.neg.imp q) := rfl

-- Test: Derived diamond (possibility) operator
example (p : Formula) : p.diamond = p.neg.box.neg := rfl

-- Test: Derived 'always' temporal operator (at all times: past ∧ present ∧ future)
-- Definition: always φ = H φ ∧ φ ∧ G φ (all_past φ ∧ φ ∧ all_future φ)
example (p : Formula) : p.always = p.allPast.and (p.and p.allFuture) := rfl

-- Test: Derived 'sometimes' temporal operator (at some time: past ∨ present ∨ future)
-- Definition: sometimes φ = ¬always¬φ = ¬(H¬φ ∧ ¬φ ∧ G¬φ)
example (p : Formula) : p.sometimes = p.neg.always.neg := rfl

-- Test: Derived 'some_past' operator (at some past time)
-- Definition: some_past φ = S(φ, ⊤) (Task 116: direct def, not ¬H¬φ)
-- The duality some_past φ ↔ ¬H¬φ is now a semantic equivalence via @[simp] theorems.
example (p : Formula) : p.somePast = Formula.snce p Formula.top := rfl

-- Test: Derived 'some_future' operator (at some future time)
-- Definition: some_future φ = U(φ, ⊤) (Task 116: direct def, not ¬G¬φ)
-- The duality some_future φ ↔ ¬G¬φ is now a semantic equivalence via @[simp] theorems.
-- Note: some_future ≠ sometimes (sometimes covers past, present, AND future)
example (p : Formula) : p.someFuture = Formula.untl p Formula.top := rfl

-- Test: Triangle notation parsing - always (△)
example (p : Formula) : △p = p.always := rfl

-- Test: Triangle notation parsing - sometimes (▽)
example (p : Formula) : ▽p = p.sometimes := rfl

-- Test: Triangle notation equivalence - always is all times (H ∧ present ∧ G)
example (p : Formula) : △p = p.allPast.and (p.and p.allFuture) := rfl

-- Test: Triangle notation equivalence - sometimes is dual
example (p : Formula) : ▽p = p.neg.always.neg := rfl

-- Test: Triangle notation composition - implication
example (p q : Formula) : △(p.imp q) = (p.imp q).always := rfl

-- Test: Triangle notation composition - negation
example (p : Formula) : ▽p.neg = p.neg.sometimes := rfl

-- Test: Triangle notation with modal operators - box
example (p : Formula) : △(p.box) = p.box.always := rfl

-- Test: Triangle notation with modal operators - diamond
example (p : Formula) : ▽(p.diamond) = p.diamond.sometimes := rfl

-- Test: Mixed temporal-modal notation - always applied to box
example (p : Formula) : △(p.box) = p.box.always := rfl

-- Test: always definition consistency - verify H ∧ present ∧ G structure
example (p : Formula) : p.always = p.allPast.and (p.and p.allFuture) := rfl

-- Test: sometimes definition consistency - verify dual of always
example (p : Formula) : p.sometimes = p.neg.always.neg := rfl

-- Test: swap_temporal on atom (unchanged)
example : (Formula.atomS "p").swapTemporal = Formula.atomS "p" := rfl

-- Test: swap_temporal on bot (unchanged)
example : Formula.bot.swapTemporal = Formula.bot := rfl

-- Test: swap_temporal on implication (recursive)
example (p q : Formula) :
  (p.imp q).swapTemporal = (p.swapTemporal.imp q.swapTemporal) := rfl

-- Test: swap_temporal on box (unchanged)
example (p : Formula) : (p.box).swapTemporal = p.swapTemporal.box := rfl

-- Test: swap_temporal on all_past (becomes all_future)
-- Note: all_past/all_future are def abbreviations (Task 116), so equality
-- requires unfolding through imp/untl/snce.
example (p : Formula) : (p.allPast).swapTemporal = p.swapTemporal.allFuture := by
  simp only [Formula.allPast, Formula.allFuture, Formula.somePast, Formula.someFuture,
    Formula.neg, Formula.top, Formula.swapTemporal]

-- Test: swap_temporal on all_future (becomes all_past)
example (p : Formula) : (p.allFuture).swapTemporal = p.swapTemporal.allPast := by
  simp only [Formula.allFuture, Formula.allPast, Formula.someFuture, Formula.somePast,
    Formula.neg, Formula.top, Formula.swapTemporal]

-- Test: swap_temporal is involution (applying twice gives identity)
example (p : Formula) : p.swapTemporal.swapTemporal = p := by
  induction p with
  | atom _ => rfl
  | bot => rfl
  | imp p q ihp ihq => simp only [Formula.swapTemporal, ihp, ihq]
  | box p ih => simp only [Formula.swapTemporal, ih]
  | untl p q ih1 ih2 => simp only [Formula.swapTemporal, ih1, ih2]
  | snce p q ih1 ih2 => simp only [Formula.swapTemporal, ih1, ih2]

/-! ## Formula Complexity Metrics Tests -/

-- Define test formulas
def p : Formula := Formula.atomS "p"
def q : Formula := Formula.atomS "q"
def r : Formula := Formula.atomS "r"
def s : Formula := Formula.atomS "s"

-- modalDepth tests: atoms and bot have depth 0
example : (Formula.atomS "p").modalDepth = 0 := rfl
example : Formula.bot.modalDepth = 0 := rfl

-- modalDepth tests: box increases depth
example : p.box.modalDepth = 1 := rfl
example : p.box.box.modalDepth = 2 := rfl

-- modalDepth tests: max depth in implications
example : (p.box.imp q.box).modalDepth = 1 := rfl
example : (p.box.box.imp q.box).modalDepth = 2 := rfl

-- modalDepth tests: temporal operators don't affect modal depth
example : p.box.allFuture.modalDepth = 1 := rfl
example : p.allFuture.box.modalDepth = 1 := rfl

-- temporalDepth tests: atoms and bot have depth 0
example : (Formula.atomS "p").temporalDepth = 0 := rfl
example : Formula.bot.temporalDepth = 0 := rfl

-- temporalDepth tests: temporal operators increase depth
example : p.allFuture.temporalDepth = 1 := rfl
example : p.allPast.temporalDepth = 1 := rfl
example : p.allFuture.allFuture.temporalDepth = 2 := rfl
example : p.allPast.allPast.temporalDepth = 2 := rfl

-- temporalDepth tests: max depth in implications
example : (p.allFuture.imp q.allPast).temporalDepth = 1 := rfl
example : (p.allFuture.allFuture.imp q.allPast).temporalDepth = 2 := rfl

-- temporalDepth tests: modal operators don't affect temporal depth
example : p.allFuture.box.temporalDepth = 1 := rfl
example : p.box.allFuture.temporalDepth = 1 := rfl

-- countImplications tests: atoms and bot have 0 implications
example : (Formula.atomS "p").countImplications = 0 := rfl
example : Formula.bot.countImplications = 0 := rfl

-- countImplications tests: count implications recursively
example : (p.imp q).countImplications = 1 := rfl
example : ((p.imp q).imp r).countImplications = 2 := rfl
example : (p.imp (q.imp r)).countImplications = 2 := rfl
example : ((p.imp q).imp (r.imp s)).countImplications = 3 := rfl

-- countImplications tests: operators preserve implication count
example : (p.imp q).box.countImplications = 1 := rfl
-- Note: all_future is now a def abbreviation (Task 116) involving neg/imp,
-- so countImplications counts the structural implication constructors.
example : (p.imp q).allFuture.countImplications = 4 := rfl

-- Mixed complexity tests: verify all metrics work together
example : (p.allFuture.box.imp q).modalDepth = 1 := rfl
example : (p.allFuture.box.imp q).temporalDepth = 1 := rfl
-- countImplications counts structural imp constructors in the expanded def
example : (p.allFuture.box.imp q).countImplications = 4 := rfl

/-! ## Strong Release and Strong Trigger Tests (Task 276) -/

-- Test: strong_release construction
example (φ ψ : Formula) : Formula.strongRelease φ ψ = Formula.untl (Formula.and ψ φ) ψ := rfl

-- Test: strong_trigger construction
example (φ ψ : Formula) : Formula.strongTrigger φ ψ = Formula.snce (Formula.and ψ φ) ψ := rfl

-- Test: strong_release complexity for atoms (overhead 2)
example : (Formula.strongRelease p q).complexity = 4 := rfl

-- Test: strong_trigger complexity for atoms (overhead 2)
example : (Formula.strongTrigger p q).complexity = 4 := rfl

-- Test: swap_temporal on strong_release
example (φ ψ : Formula) :
    (Formula.strongRelease φ ψ).swapTemporal = Formula.strongTrigger φ.swapTemporal ψ.swapTemporal := by
  simp [Formula.strongRelease, Formula.strongTrigger, Formula.and, Formula.swapTemporal, Formula.swap_temporal_neg]

-- Test: swap_temporal on strong_trigger
example (φ ψ : Formula) :
    (Formula.strongTrigger φ ψ).swapTemporal = Formula.strongRelease φ.swapTemporal ψ.swapTemporal := by
  simp [Formula.strongRelease, Formula.strongTrigger, Formula.and, Formula.swapTemporal, Formula.swap_temporal_neg]

-- Test: strong_release modal depth
example : (Formula.strongRelease p q).modalDepth = 0 := rfl

-- Test: strong_trigger modal depth
example : (Formula.strongTrigger p q).modalDepth = 0 := rfl

-- Test: strong_release temporal depth
example : (Formula.strongRelease p q).temporalDepth = 1 := rfl

-- Test: strong_trigger temporal depth
example : (Formula.strongTrigger p q).temporalDepth = 1 := rfl

end BimodalTest.Syntax
