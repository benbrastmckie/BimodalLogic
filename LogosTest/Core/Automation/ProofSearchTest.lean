import Logos.Core.Automation.ProofSearch
import Logos.Core.ProofSystem

namespace LogosTest.Core.Automation

open Logos.Core.Syntax Logos.Core.Automation Logos.Core.ProofSystem

abbrev p : Formula := .atom "p"
abbrev q : Formula := .atom "q"
abbrev r : Formula := .atom "r"

/-- Axiom matching positives across the TM schemata. -/
example : matches_axiom ((p.imp (q.imp r)).imp ((p.imp q).imp (p.imp r))) = true := rfl
example : matches_axiom (p.imp (q.imp p)) = true := rfl
example : matches_axiom (Formula.bot.imp p) = true := rfl
example : matches_axiom (((p.imp q).imp p).imp p) = true := rfl
example : matches_axiom ((Formula.box p).imp p) = true := rfl
example : matches_axiom ((Formula.box p).imp (Formula.box (Formula.box p))) = true := rfl
example : matches_axiom (p.imp (Formula.box p.diamond)) = true := rfl
example : matches_axiom ((Formula.box p).diamond.imp (Formula.box p)) = true := rfl
example : matches_axiom ((Formula.box (p.imp q)).imp ((Formula.box p).imp (Formula.box q))) = true := rfl
example : matches_axiom ((Formula.all_future (p.imp q)).imp ((Formula.all_future p).imp (Formula.all_future q))) = true := rfl
example : matches_axiom ((Formula.all_future p).imp (Formula.all_future (Formula.all_future p))) = true := rfl
example : matches_axiom (p.imp (Formula.all_future (Formula.some_past p))) = true := rfl
example : matches_axiom ((Formula.always p).imp (Formula.all_future (Formula.all_past p))) = true := rfl
example : matches_axiom ((Formula.box p).imp (Formula.box (Formula.all_future p))) = true := rfl
example : matches_axiom ((Formula.box p).imp (Formula.all_future (Formula.box p))) = true := rfl

/-- Negative axiom matching checks to avoid false positives. -/
example : matches_axiom (Formula.imp (Formula.box p) q) = false := rfl
example : matches_axiom (Formula.imp p q) = false := rfl

/-- Heuristic scoring baseline cases. -/
example : heuristic_score {} [] ((Formula.box p).imp p) = 0 := by decide
example : heuristic_score {} [p] p = 1 := by decide
example : heuristic_score {} [p.imp q] q = 2 + p.complexity := by decide
example : heuristic_score {} [] (Formula.box p) = 5 := by decide
example : heuristic_score {} [] (Formula.atom "x") = 100 := by decide

/-- Heuristic scoring respects custom weights. -/
def weightedHeuristics : HeuristicWeights :=
  { mpComplexityWeight := 2, contextPenaltyWeight := 2 }
example : heuristic_score weightedHeuristics [p.imp q] q = 2 + 2 * p.complexity := by decide
example : heuristic_score weightedHeuristics [] (Formula.box p) = 5 + 2 * 0 := by decide

/-- Heuristic ordering prefers cheaper antecedents first. -/
example :
    orderSubgoalsByScore {} [r.imp q, p.imp q, p] (find_implications_to [r.imp q, p.imp q, p] q)
      = [p, r] := by decide

/-- Bounded search respects depth and visit limits and succeeds on simple MP chains. -/
example : (bounded_search [p.imp q, p] q 2).1 = true := by decide
example : (bounded_search [p.imp q] q 1).1 = false := by decide
example : (bounded_search [p.imp p] p 3 ProofCache.empty Visited.empty 0 1).1 = false := by decide

/-- Cache hit/miss and visit-limit stats are surfaced. -/
example :
    let (_, cache1, _, stats1, _) := search_with_cache ProofCache.empty [p.imp q, p] q 2
    let (_, _, _, stats2, _) := search_with_cache cache1 [p.imp q, p] q 2
    stats1.misses = 1 ∧ stats2.hits = stats1.hits + 1 := by decide

/-- Visit limit prunes and increments pruned counter. -/
example :
    let (_, _, _, stats, _) := bounded_search [] p 1 ProofCache.empty Visited.empty 0 0
    stats.prunedByLimit = 1 := by decide

end LogosTest.Core.Automation
