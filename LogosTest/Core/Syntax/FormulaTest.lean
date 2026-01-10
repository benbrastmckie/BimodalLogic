import Bimodal.Syntax.Formula

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

namespace LogosTest.Core.Syntax

open Bimodal.Syntax

-- Test: Formula atom construction
example : Formula.atom "p" = Formula.atom "p" := rfl

-- Test: Formula bot construction
example : Formula.bot = Formula.bot := rfl

-- Test: Formula implication construction
example (p q : Formula) : (Formula.imp p q) = (Formula.imp p q) := rfl

-- Test: Formula box construction
example (p : Formula) : (Formula.box p) = (Formula.box p) := rfl

-- Test: Formula all_past construction
example (p : Formula) : (Formula.all_past p) = (Formula.all_past p) := rfl

-- Test: Formula all_future construction
example (p : Formula) : (Formula.all_future p) = (Formula.all_future p) := rfl

-- Test: Decidable equality - same atoms
example : (Formula.atom "p") = (Formula.atom "p") := rfl

-- Test: Decidable equality - different atoms
example : (Formula.atom "p") ≠ (Formula.atom "q") := by
  intro h
  injection h with h'
  contradiction

-- Test: Decidable equality - bot
example : Formula.bot = Formula.bot := rfl

-- Test: Decidable equality - complex formulas
example :
  (Formula.imp (Formula.atom "p") (Formula.atom "q")) =
  (Formula.imp (Formula.atom "p") (Formula.atom "q")) := rfl

-- Test: Complexity of atom
example : (Formula.atom "p").complexity = 1 := rfl

-- Test: Complexity of bot
example : Formula.bot.complexity = 1 := rfl

-- Test: Complexity of implication
example : ((Formula.atom "p").imp (Formula.atom "q")).complexity = 3 := rfl

-- Test: Complexity of box
example : ((Formula.atom "p").box).complexity = 2 := rfl

-- Test: Complexity of nested formula
example : ((Formula.atom "p").box.imp (Formula.atom "q").box).complexity = 5 := rfl

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
example (p : Formula) : p.always = p.all_past.and (p.and p.all_future) := rfl

-- Test: Derived 'sometimes' temporal operator (at some time: past ∨ present ∨ future)
-- Definition: sometimes φ = ¬always¬φ = ¬(H¬φ ∧ ¬φ ∧ G¬φ)
example (p : Formula) : p.sometimes = p.neg.always.neg := rfl

-- Test: Derived 'some_past' operator (at some past time)
-- Definition: some_past φ = ¬H¬φ = ¬(all_past ¬φ)
example (p : Formula) : p.some_past = p.neg.all_past.neg := rfl

-- Test: Derived 'some_future' operator (at some future time)
-- Definition: some_future φ = ¬G¬φ = ¬(all_future ¬φ)
-- Note: some_future ≠ sometimes (sometimes covers past, present, AND future)
example (p : Formula) : p.some_future = p.neg.all_future.neg := rfl

-- Test: Triangle notation parsing - always (△)
example (p : Formula) : △p = p.always := rfl

-- Test: Triangle notation parsing - sometimes (▽)
example (p : Formula) : ▽p = p.sometimes := rfl

-- Test: Triangle notation equivalence - always is all times (H ∧ present ∧ G)
example (p : Formula) : △p = p.all_past.and (p.and p.all_future) := rfl

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
example (p : Formula) : p.always = p.all_past.and (p.and p.all_future) := rfl

-- Test: sometimes definition consistency - verify dual of always
example (p : Formula) : p.sometimes = p.neg.always.neg := rfl

-- Test: swap_temporal on atom (unchanged)
example : (Formula.atom "p").swap_temporal = Formula.atom "p" := rfl

-- Test: swap_temporal on bot (unchanged)
example : Formula.bot.swap_temporal = Formula.bot := rfl

-- Test: swap_temporal on implication (recursive)
example (p q : Formula) :
  (p.imp q).swap_temporal = (p.swap_temporal.imp q.swap_temporal) := rfl

-- Test: swap_temporal on box (unchanged)
example (p : Formula) : (p.box).swap_temporal = p.swap_temporal.box := rfl

-- Test: swap_temporal on all_past (becomes all_future)
example (p : Formula) : (p.all_past).swap_temporal = p.swap_temporal.all_future := rfl

-- Test: swap_temporal on all_future (becomes all_past)
example (p : Formula) : (p.all_future).swap_temporal = p.swap_temporal.all_past := rfl

-- Test: swap_temporal is involution (applying twice gives identity)
example (p : Formula) : p.swap_temporal.swap_temporal = p := by
  induction p with
  | atom _ => rfl
  | bot => rfl
  | imp p q ihp ihq => simp [Formula.swap_temporal, ihp, ihq]
  | box p ih => simp [Formula.swap_temporal, ih]
  | all_past p ih => simp [Formula.swap_temporal, ih]
  | all_future p ih => simp [Formula.swap_temporal, ih]

/-! ## Formula Complexity Metrics Tests -/

-- Define test formulas
def p : Formula := Formula.atom "p"
def q : Formula := Formula.atom "q"
def r : Formula := Formula.atom "r"
def s : Formula := Formula.atom "s"

-- modalDepth tests: atoms and bot have depth 0
example : (Formula.atom "p").modalDepth = 0 := rfl
example : Formula.bot.modalDepth = 0 := rfl

-- modalDepth tests: box increases depth
example : p.box.modalDepth = 1 := rfl
example : p.box.box.modalDepth = 2 := rfl

-- modalDepth tests: max depth in implications
example : (p.box.imp q.box).modalDepth = 1 := rfl
example : (p.box.box.imp q.box).modalDepth = 2 := rfl

-- modalDepth tests: temporal operators don't affect modal depth
example : p.box.all_future.modalDepth = 1 := rfl
example : p.all_future.box.modalDepth = 1 := rfl

-- temporalDepth tests: atoms and bot have depth 0
example : (Formula.atom "p").temporalDepth = 0 := rfl
example : Formula.bot.temporalDepth = 0 := rfl

-- temporalDepth tests: temporal operators increase depth
example : p.all_future.temporalDepth = 1 := rfl
example : p.all_past.temporalDepth = 1 := rfl
example : p.all_future.all_future.temporalDepth = 2 := rfl
example : p.all_past.all_past.temporalDepth = 2 := rfl

-- temporalDepth tests: max depth in implications
example : (p.all_future.imp q.all_past).temporalDepth = 1 := rfl
example : (p.all_future.all_future.imp q.all_past).temporalDepth = 2 := rfl

-- temporalDepth tests: modal operators don't affect temporal depth
example : p.all_future.box.temporalDepth = 1 := rfl
example : p.box.all_future.temporalDepth = 1 := rfl

-- countImplications tests: atoms and bot have 0 implications
example : (Formula.atom "p").countImplications = 0 := rfl
example : Formula.bot.countImplications = 0 := rfl

-- countImplications tests: count implications recursively
example : (p.imp q).countImplications = 1 := rfl
example : ((p.imp q).imp r).countImplications = 2 := rfl
example : (p.imp (q.imp r)).countImplications = 2 := rfl
example : ((p.imp q).imp (r.imp s)).countImplications = 3 := rfl

-- countImplications tests: operators preserve implication count
example : (p.imp q).box.countImplications = 1 := rfl
example : (p.imp q).all_future.countImplications = 1 := rfl

-- Mixed complexity tests: verify all metrics work together
example : (p.all_future.box.imp q).modalDepth = 1 := rfl
example : (p.all_future.box.imp q).temporalDepth = 1 := rfl
example : (p.all_future.box.imp q).countImplications = 1 := rfl

end LogosTest.Core.Syntax
