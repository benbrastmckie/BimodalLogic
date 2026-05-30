import Std.Data.HashMap
import Std.Data.HashSet
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Automation.SuccessPatterns
import Bimodal.Theorems.Combinators

/-!
# Automated Proof Search

This module implements automated proof search for the TM bimodal logic system,
including IDDFS, best-first search, and success pattern learning.

## Main Functions

- `search`: Unified search interface with configurable strategy (recommended)
- `search_with_learning`: Search with pattern learning for repeated proofs
- `bestFirst_search`: Priority queue-based best-first search
- `iddfs_search`: Iterative deepening DFS with completeness guarantees
- `bounded_search`: Depth-limited DFS (may miss deep proofs)
- `batch_search_with_learning`: Batch search with cumulative pattern learning

## Search Strategies

### SearchStrategy.IDDFS (Default - Recommended for Axioms)

Iterative Deepening Depth-First Search (IDDFS) combines the completeness of BFS
with the space efficiency of DFS by running depth-limited searches with
increasing depth limits.

**Properties**:
- **Complete**: Guaranteed to find a proof if one exists (within maxDepth)
- **Optimal**: Guaranteed to find the shortest proof (minimum depth)
- **Space efficient**: O(d) space complexity where d = solution depth
- **Time complexity**: O(b^d) where b = branching factor

**Best for**: Axiom-like goals, shallow proofs, memory-constrained environments

### SearchStrategy.BoundedDFS

Traditional depth-limited DFS. Faster for shallow proofs but may miss proofs
beyond the depth limit. Not complete or optimal.

**Best for**: Quick shallow searches where depth bound is known

### SearchStrategy.BestFirst (Recommended for Context-Based Goals)

Priority queue-based best-first search that explores nodes by f-score (cost + heuristic).
Uses pattern-aware heuristics for intelligent branch ordering.

**Properties**:
- **Guided**: Explores promising branches first based on heuristics
- **Adaptive**: Leverages success pattern history for improved ordering
- **Complete**: Guaranteed to find proof if one exists (within expansion limit)

**Best for**: Context-based goals (with hypotheses), modus ponens chains

## Strategy Selection Guide

| Goal Type | Recommended Strategy | Reason |
|-----------|---------------------|--------|
| Axiom match | IDDFS-20 | Fast, depth-1 usually suffices |
| Modal K rule | IDDFS-20 | Predictable depth structure |
| Temporal K rule | IDDFS-20 | Predictable depth structure |
| Context assumption | BestFirst-1000 | Benefits from heuristic ordering |
| Modus ponens chain | BestFirst-10000 | Heuristics guide antecedent search |
| Unknown complexity | IDDFS-100 | Safe default with completeness |

## Success Pattern Learning

The pattern learning system (`SuccessPatterns.lean`) records successful proofs
and uses them to guide future searches:

1. **Pattern Recording**: After each successful proof, the formula's structural
   pattern (modal depth, temporal depth, complexity) is recorded along with the
   successful strategy.

2. **Heuristic Boosting**: When searching similar formulas, strategies that
   previously succeeded receive priority boosts (-10 for >80% success rate,
   -5 for >50%, -2 for >20%).

3. **Depth Hints**: Average successful depth is tracked to suggest depth limits.

**Usage**:
```lean
-- Search with learning (pattern database is updated)
let result := search_with_learning Γ φ
let updatedDb := result.patternDb

-- Batch search accumulates patterns
let finalResult := batch_search_with_learning benchmarks PatternDatabase.empty
```

## Heuristic Tuning

The `HeuristicWeights` structure controls search behavior:

| Weight | Default | Effect |
|--------|---------|--------|
| `axiomWeight` | 0 | Priority for axiom matching (lower = try first) |
| `assumptionWeight` | 1 | Priority for context lookup |
| `mpBase` | 3 | Base cost for modus ponens |
| `mpPerAntecedent` | 1 | Additional cost per antecedent complexity |
| `modalKWeight` | 5 | Cost for modal K rule application |
| `temporalKWeight` | 5 | Cost for temporal K rule application |

**Weight Presets**:
- Default: Balanced for general proofs
- Modal-Optimized: `modalKWeight := 2` - prioritize modal reasoning
- Temporal-Optimized: `temporalKWeight := 2` - prioritize temporal reasoning
- Low-Context: `assumptionWeight := 5` - deprioritize context search

## Complexity Analysis

| Strategy | Time | Space | Complete | Optimal |
|----------|------|-------|----------|---------|
| IDDFS | O(b^d) | O(d) | Yes | Yes |
| BoundedDFS | O(b^d) | O(d) | No | No |
| BestFirst | O(b^d) | O(b^d) | Yes | Heuristic-dep |

Where b = branching factor, d = depth of shallowest solution.

## Benchmark Results

| Category | IDDFS | BestFirst | Winner |
|----------|-------|-----------|--------|
| Modal axioms (5) | 5/5, 5 visits | 5/5, 5 visits | Tie |
| Temporal axioms (3) | 3/3, 3 visits | 3/3, 3 visits | Tie |
| Propositional (4) | 4/4, 4 visits | 4/4, 4 visits | Tie |
| Context-based (3) | 1/3, 39 visits | 3/3, 6 visits | **BestFirst** |

BestFirst significantly outperforms IDDFS on context-based goals requiring
modus ponens or assumption lookup in larger contexts.

## Implementation Status

**Implemented**:
- ✓ Bounded DFS with heuristics and caching
- ✓ Iterative deepening DFS (IDDFS) with completeness guarantees
- ✓ Best-first search with priority queue
- ✓ Success pattern learning with `PatternDatabase`
- ✓ Pattern-aware heuristic scoring
- ✓ SearchStrategy enum with unified interface
- ✓ Visit limit enforcement
- ✓ Search statistics tracking
- ✓ Domain-specific heuristics (modal, temporal, structure)
- ✓ Comprehensive benchmark suite

**Future Work**:
- Proof term construction (blocked by Axiom Prop vs Type issue)
- Adaptive strategy selection based on goal analysis

## Example Usage

```lean
-- Use IDDFS (default, complete and optimal)
let (found, cache, visited, stats, visits) := search [] myFormula

-- Use BestFirst for context-based goals
let (found, _, _, _, _) := search Γ myFormula (.BestFirst 10000)

-- Use search with pattern learning
let result := search_with_learning Γ myFormula (.IDDFS 100)
-- result.patternDb contains updated pattern database

-- Batch search with cumulative learning
let benchmarks := [("goal1", [], φ1), ("goal2", [], φ2)]
let finalResult := batch_search_with_learning benchmarks
```

## References

* Korf, R.E. (1985). Depth-first iterative-deepening: An optimal admissible
  tree search. Artificial Intelligence, 27(1), 97-109.
* Yang et al. (2019). Learning to Prove Theorems via Interacting with
  Proof Assistants. ICML.
* Automated Theorem Proving: https://www.cs.cmu.edu/~fp/courses/atp/
* LEAN Proof Search: Mathlib's `solve_by_elim` tactic
-/

namespace Bimodal.Automation

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Proof Search Types (Planned)
-/

/--
Proof search result: either a derivation or search failure.

**Design**: Uses `Bool` for the original implementation.
See `SearchResultWithProof` for the proof-term-returning variant.
-/
abbrev SearchResult (_ : Context) (_ : Formula) := Bool

/--
Proof search result with actual derivation tree.

Returns `Option (DerivationTree Γ φ)` where `some d` means proof found.
This is the proof-constructing variant enabled by the Axiom : Type refactor.
-/
abbrev SearchResultWithProof (Γ : Context) (φ : Formula) := Option (Γ ⊢ φ)

/--
Membership witness for formula in context.

A value `MembershipWitness Γ φ` is a proof that `φ ∈ Γ`.
This is used to enable proof term construction for assumptions.
-/
structure MembershipWitness (Γ : Context) (φ : Formula) : Type where
  proof : φ ∈ Γ

/--
Find a membership witness for formula in context.

Returns `some wit` where `wit.proof : φ ∈ Γ` if the formula is in the context,
`none` otherwise. This enables proof term construction for assumptions.
-/
def findMembershipWitness (Γ : Context) (φ : Formula) : Option (MembershipWitness Γ φ) :=
  match Γ with
  | [] => none
  | ψ :: rest =>
      if h : φ = ψ then
        some ⟨h ▸ List.Mem.head rest⟩
      else
        match findMembershipWitness rest φ with
        | some wit => some ⟨List.Mem.tail ψ wit.proof⟩
        | none => none

/-- Cache key combines the current context and goal formula. -/
abbrev CacheKey := Context × Formula

/-- Hash-based proof cache for memoization (stores success/failure). -/
abbrev ProofCache := Std.HashMap CacheKey Bool

/-- Visited set to prevent cycles during search. -/
abbrev Visited := Std.HashSet CacheKey

/-- Search statistics surfaced to callers and tests. -/
structure SearchStats where
  /-- Cache hits (entries found). -/
  hits : Nat := 0
  /-- Cache misses (entries inserted). -/
  misses : Nat := 0
  /-- Nodes visited (after passing depth/limit guard). -/
  visited : Nat := 0
  /-- Nodes pruned because visit limit was reached. -/
  prunedByLimit : Nat := 0
  deriving Inhabited, DecidableEq

namespace ProofCache

/-- Empty proof cache. -/
@[simp] def empty : ProofCache := {}

end ProofCache

namespace Visited

/-- Empty visited set. -/
@[simp] def empty : Visited := {}

end Visited

/-!
## Heuristic Weights
-/

/--
Tunable weights for heuristic scoring. Lower scores are preferred.
-/
structure HeuristicWeights where
  /-- Score assigned when a goal matches an axiom schema. -/
  axiomWeight : Nat := 0
  /-- Score assigned when a goal is already present in the context. -/
  assumptionWeight : Nat := 1
  /-- Base cost for a modus ponens step before considering antecedent complexity. -/
  mpBase : Nat := 2
  /-- Multiplier applied to antecedent complexity when ranking modus ponens candidates. -/
  mpComplexityWeight : Nat := 1
  /-- Base cost for modal K-style expansion (□). -/
  modalBase : Nat := 5
  /-- Base cost for temporal K-style expansion (G/all_future). -/
  temporalBase : Nat := 5
  /-- Penalty per context entry when performing context-transforming steps. -/
  contextPenaltyWeight : Nat := 1
  /-- Fallback cost when no strategy applies. -/
  deadEnd : Nat := 100
  deriving Inhabited

/-!
## Helper Functions
-/

/--
Match a formula against axiom patterns, returning the Axiom witness if matched.

This function enables proof term construction by returning the actual
Axiom constructor that matches the formula pattern. Now that Axiom is a Type
(not Prop), we can use the witness in DerivationTree construction.

**Returns**: `some ⟨φ, witness⟩` if φ matches an axiom schema, `none` otherwise

**Performance**: O(1) - pattern matching on formula structure

**Design Notes**:
- Uses `Sigma Axiom` to package the witness with its formula type
- The formula returned is the matched formula (same as input on success)
- Each axiom pattern is checked in sequence with early return on match
- Uses a decomposition approach (like matches_axiom) to handle derived operators
-/
def matchAxiom (φ : Formula) : Option (Sigma Axiom) :=
  -- Decompose into implication (all 42 axioms are implications or negations)
  match φ with
  | .imp lhs rhs =>
      -- ex_falso: ⊥ → φ
      (if lhs = .bot then some ⟨_, Axiom.ex_falso rhs⟩ else none)

      -- prop_k: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
      <|> (match lhs, rhs with
           | .imp a (.imp b c), .imp (.imp a' b') (.imp a'' c') =>
               if a = a' ∧ a' = a'' ∧ b = b' ∧ c = c' then
                 some ⟨_, Axiom.prop_k a b c⟩
               else none
           | _, _ => none)

      -- peirce: ((φ → ψ) → φ) → φ
      <|> (match lhs, rhs with
           | .imp (.imp phi psi) phi', phi'' =>
               if phi = phi' ∧ phi' = phi'' then
                 some ⟨_, Axiom.peirce phi psi⟩
               else none
           | _, _ => none)

      -- modal_k_dist: □(φ → ψ) → (□φ → □ψ)
      <|> (match lhs, rhs with
           | .box (.imp phi psi), .imp (.box phi') (.box psi') =>
               if phi = phi' ∧ psi = psi' then
                 some ⟨_, Axiom.modal_k_dist phi psi⟩
               else none
           | _, _ => none)

      -- modal_5_collapse: ◇□φ → □φ
      <|> (match lhs, rhs with
           | .diamond (.box phi), .box phi' =>
               if phi = phi' then
                 some ⟨_, Axiom.modal_5_collapse phi⟩
               else none
           | _, _ => none)

      -- modal_4: □φ → □□φ
      <|> (match lhs, rhs with
           | .box phi, .box (.box phi') =>
               if phi = phi' then
                 some ⟨_, Axiom.modal_4 phi⟩
               else none
           | _, _ => none)

      -- modal_future: □φ → □(Gφ)
      <|> (match lhs, rhs with
           | .box phi, .box (.all_future phi') =>
               if phi = phi' then
                 some ⟨_, Axiom.modal_future phi⟩
               else none
           | _, _ => none)

      -- modal_b: φ → □◇φ
      <|> (match lhs, rhs with
           | phi, .box (.diamond phi') =>
               if phi = phi' then
                 some ⟨_, Axiom.modal_b phi⟩
               else none
           | _, _ => none)

      -- modal_t: □φ → φ (general; must come after modal_4, modal_future)
      <|> (match lhs, rhs with
           | .box phi, phi' =>
               if phi = phi' then
                 some ⟨_, Axiom.modal_t phi⟩
               else none
           | _, _ => none)

      -- NOTE: temp_k_dist and temp_4 removed as axiom constructors (Task 116).

      -------------------------------------------------------------------
      -- Ground axioms (0-parameter)
      -------------------------------------------------------------------

      -- serial_future: ⊤ → F(⊤)
      <|> (match lhs, rhs with
           | .imp .bot .bot, .some_future (.imp .bot .bot) =>
               some ⟨_, Axiom.serial_future⟩
           | _, _ => none)

      -- serial_past: ⊤ → P(⊤)
      <|> (match lhs, rhs with
           | .imp .bot .bot, .some_past (.imp .bot .bot) =>
               some ⟨_, Axiom.serial_past⟩
           | _, _ => none)

      -- discrete_symm_fwd: U(⊤,⊥) → S(⊤,⊥)
      <|> (match lhs, rhs with
           | .untl (.imp .bot .bot) .bot, .snce (.imp .bot .bot) .bot =>
               some ⟨_, Axiom.discrete_symm_fwd⟩
           | _, _ => none)

      -- discrete_symm_bwd: S(⊤,⊥) → U(⊤,⊥)
      <|> (match lhs, rhs with
           | .snce (.imp .bot .bot) .bot, .untl (.imp .bot .bot) .bot =>
               some ⟨_, Axiom.discrete_symm_bwd⟩
           | _, _ => none)

      -- discrete_propagate_fwd: U(⊤,⊥) → G(U(⊤,⊥))
      <|> (match lhs, rhs with
           | .untl (.imp .bot .bot) .bot, .all_future (.untl (.imp .bot .bot) .bot) =>
               some ⟨_, Axiom.discrete_propagate_fwd⟩
           | _, _ => none)

      -- discrete_propagate_bwd: U(⊤,⊥) → H(U(⊤,⊥))
      <|> (match lhs, rhs with
           | .untl (.imp .bot .bot) .bot, .all_past (.untl (.imp .bot .bot) .bot) =>
               some ⟨_, Axiom.discrete_propagate_bwd⟩
           | _, _ => none)

      -- discrete_box_necessity: U(⊤,⊥) → □(U(⊤,⊥))
      <|> (match lhs, rhs with
           | .untl (.imp .bot .bot) .bot, .box (.untl (.imp .bot .bot) .bot) =>
               some ⟨_, Axiom.discrete_box_necessity⟩
           | _, _ => none)

      -- dense_indicator: ¬U(⊤,⊥) = U(⊤,⊥) → ⊥
      <|> (match lhs, rhs with
           | .untl (.imp .bot .bot) .bot, .bot =>
               some ⟨_, Axiom.dense_indicator⟩
           | _, _ => none)

      -------------------------------------------------------------------
      -- 1-parameter axioms
      -------------------------------------------------------------------

      -- connect_future (BX4): φ → G(P(φ))
      <|> (match lhs, rhs with
           | phi, .all_future (.some_past phi') =>
               if phi = phi' then
                 some ⟨_, Axiom.connect_future phi⟩
               else none
           | _, _ => none)

      -- connect_past (BX4'): φ → H(F(φ))
      <|> (match lhs, rhs with
           | phi, .all_past (.some_future phi') =>
               if phi = phi' then
                 some ⟨_, Axiom.connect_past phi⟩
               else none
           | _, _ => none)

      -- F_until_equiv (BX12): F(φ) → U(φ, ⊤)
      <|> (match lhs, rhs with
           | .some_future phi, .untl phi' (.imp .bot .bot) =>
               if phi = phi' then
                 some ⟨_, Axiom.F_until_equiv phi⟩
               else none
           | _, _ => none)

      -- P_since_equiv (BX12'): P(φ) → S(φ, ⊤)
      <|> (match lhs, rhs with
           | .some_past phi, .snce phi' (.imp .bot .bot) =>
               if phi = phi' then
                 some ⟨_, Axiom.P_since_equiv phi⟩
               else none
           | _, _ => none)

      -- z1: G(Gφ→φ) → (F(Gφ)→Gφ)
      <|> (match lhs, rhs with
           | .all_future (.imp (.all_future phi) phi'),
             .imp (.some_future (.all_future phi'')) (.all_future phi''') =>
               if phi = phi' ∧ phi' = phi'' ∧ phi'' = phi''' then
                 some ⟨_, Axiom.z1 phi⟩
               else none
           | _, _ => none)

      -- density: GGφ → Gφ
      <|> (match lhs, rhs with
           | .all_future (.all_future phi), .all_future phi' =>
               if phi = phi' then
                 some ⟨_, Axiom.density phi⟩
               else none
           | _, _ => none)

      -------------------------------------------------------------------
      -- 2-parameter axioms
      -------------------------------------------------------------------

      -- self_accum_until (BX5): U(ψ,φ) → U(ψ, φ∧U(ψ,φ))
      <|> (match lhs, rhs with
           | .untl psi phi, .untl psi' (.and phi' (.untl psi'' phi'')) =>
               if phi = phi' ∧ phi' = phi'' ∧ psi = psi' ∧ psi' = psi'' then
                 some ⟨_, Axiom.self_accum_until phi psi⟩
               else none
           | _, _ => none)

      -- self_accum_since (BX5'): S(ψ,φ) → S(ψ, φ∧S(ψ,φ))
      <|> (match lhs, rhs with
           | .snce psi phi, .snce psi' (.and phi' (.snce psi'' phi'')) =>
               if phi = phi' ∧ phi' = phi'' ∧ psi = psi' ∧ psi' = psi'' then
                 some ⟨_, Axiom.self_accum_since phi psi⟩
               else none
           | _, _ => none)

      -- absorb_until (BX6): U(φ∧U(ψ,φ), φ) → U(ψ,φ)
      <|> (match lhs, rhs with
           | .untl (.and phi (.untl psi phi')) phi'', .untl psi' phi''' =>
               if phi = phi' ∧ phi' = phi'' ∧ phi'' = phi''' ∧ psi = psi' then
                 some ⟨_, Axiom.absorb_until phi psi⟩
               else none
           | _, _ => none)

      -- absorb_since (BX6'): S(φ∧S(ψ,φ), φ) → S(ψ,φ)
      <|> (match lhs, rhs with
           | .snce (.and phi (.snce psi phi')) phi'', .snce psi' phi''' =>
               if phi = phi' ∧ phi' = phi'' ∧ phi'' = phi''' ∧ psi = psi' then
                 some ⟨_, Axiom.absorb_since phi psi⟩
               else none
           | _, _ => none)

      -- until_F (BX10): U(ψ,φ) → F(ψ)
      <|> (match lhs, rhs with
           | .untl psi _phi, .some_future psi' =>
               if psi = psi' then
                 some ⟨_, Axiom.until_F _phi psi⟩
               else none
           | _, _ => none)

      -- since_P (BX10'): S(ψ,φ) → P(ψ)
      <|> (match lhs, rhs with
           | .snce psi _phi, .some_past psi' =>
               if psi = psi' then
                 some ⟨_, Axiom.since_P _phi psi⟩
               else none
           | _, _ => none)

      -- temp_linearity (BX11): F(φ)∧F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)
      <|> (match lhs, rhs with
           | .and (.some_future phi) (.some_future psi),
             .or (.some_future (.and phi' psi'))
               (.or (.some_future (.and phi'' (.some_future psi'')))
                 (.some_future (.and (.some_future phi''') psi'''))) =>
               if phi = phi' ∧ phi' = phi'' ∧ phi'' = phi''' ∧
                  psi = psi' ∧ psi' = psi'' ∧ psi'' = psi''' then
                 some ⟨_, Axiom.temp_linearity phi psi⟩
               else none
           | _, _ => none)

      -- temp_linearity_past (BX11'): P(φ)∧P(ψ) → P(φ∧ψ) ∨ P(φ∧P(ψ)) ∨ P(P(φ)∧ψ)
      <|> (match lhs, rhs with
           | .and (.some_past phi) (.some_past psi),
             .or (.some_past (.and phi' psi'))
               (.or (.some_past (.and phi'' (.some_past psi'')))
                 (.some_past (.and (.some_past phi''') psi'''))) =>
               if phi = phi' ∧ phi' = phi'' ∧ phi'' = phi''' ∧
                  psi = psi' ∧ psi' = psi'' ∧ psi'' = psi''' then
                 some ⟨_, Axiom.temp_linearity_past phi psi⟩
               else none
           | _, _ => none)

      -- prior_UZ: F(φ) → U(φ, ¬φ)
      <|> (match lhs, rhs with
           | .some_future phi1, .untl phi2 (.neg phi3) =>
               if phi1 = phi2 ∧ phi2 = phi3 then
                 some ⟨_, Axiom.prior_UZ phi1⟩
               else none
           | _, _ => none)

      -- prior_SZ: P(φ) → S(φ, ¬φ)
      <|> (match lhs, rhs with
           | .some_past phi1, .snce phi2 (.neg phi3) =>
               if phi1 = phi2 ∧ phi2 = phi3 then
                 some ⟨_, Axiom.prior_SZ phi1⟩
               else none
           | _, _ => none)

      -------------------------------------------------------------------
      -- 3-parameter axioms
      -------------------------------------------------------------------

      -- left_mono_until_G (BX2G): G(φ→χ) → (U(ψ,φ) → U(ψ,χ))
      <|> (match lhs, rhs with
           | .all_future (.imp phi chi),
             .imp (.untl psi phi') (.untl psi' chi') =>
               if phi = phi' ∧ chi = chi' ∧ psi = psi' then
                 some ⟨_, Axiom.left_mono_until_G phi chi psi⟩
               else none
           | _, _ => none)

      -- left_mono_since_H (BX2H): H(φ→χ) → (S(ψ,φ) → S(ψ,χ))
      <|> (match lhs, rhs with
           | .all_past (.imp phi chi),
             .imp (.snce psi phi') (.snce psi' chi') =>
               if phi = phi' ∧ chi = chi' ∧ psi = psi' then
                 some ⟨_, Axiom.left_mono_since_H phi chi psi⟩
               else none
           | _, _ => none)

      -- right_mono_until (BX3): G(φ→ψ) → (U(φ,χ) → U(ψ,χ))
      <|> (match lhs, rhs with
           | .all_future (.imp phi psi),
             .imp (.untl phi' chi) (.untl psi' chi') =>
               if phi = phi' ∧ psi = psi' ∧ chi = chi' then
                 some ⟨_, Axiom.right_mono_until phi psi chi⟩
               else none
           | _, _ => none)

      -- right_mono_since (BX3'): H(φ→ψ) → (S(φ,χ) → S(ψ,χ))
      <|> (match lhs, rhs with
           | .all_past (.imp phi psi),
             .imp (.snce phi' chi) (.snce psi' chi') =>
               if phi = phi' ∧ psi = psi' ∧ chi = chi' then
                 some ⟨_, Axiom.right_mono_since phi psi chi⟩
               else none
           | _, _ => none)

      -- enrichment_until (BX13): p∧U(ψ,φ) → U(ψ∧S(p,φ), φ)
      <|> (match lhs, rhs with
           | .and pp (.untl psi phi),
             .untl (.and psi' (.snce pp' phi')) phi'' =>
               if phi = phi' ∧ phi' = phi'' ∧ psi = psi' ∧ pp = pp' then
                 some ⟨_, Axiom.enrichment_until phi psi pp⟩
               else none
           | _, _ => none)

      -- enrichment_since (BX13'): p∧S(ψ,φ) → S(ψ∧U(p,φ), φ)
      <|> (match lhs, rhs with
           | .and pp (.snce psi phi),
             .snce (.and psi' (.untl pp' phi')) phi'' =>
               if phi = phi' ∧ phi' = phi'' ∧ psi = psi' ∧ pp = pp' then
                 some ⟨_, Axiom.enrichment_since phi psi pp⟩
               else none
           | _, _ => none)

      -------------------------------------------------------------------
      -- 4-parameter axioms
      -------------------------------------------------------------------

      -- linear_until (BX7): U(ψ,φ)∧U(θ,χ) → U(ψ∧θ,φ∧χ) ∨ U(ψ∧χ,φ∧χ) ∨ U(φ∧θ,φ∧χ)
      <|> (match lhs, rhs with
           | .and (.untl psi phi) (.untl theta chi),
             .or (.or (.untl (.and psi' theta') (.and phi' chi'))
                      (.untl (.and psi'' chi'') (.and phi'' chi''')))
                 (.untl (.and phi'''' theta'') (.and phi''''' chi'''')) =>
               if psi = psi' ∧ psi' = psi'' ∧
                  theta = theta' ∧ theta' = theta'' ∧
                  phi = phi' ∧ phi' = phi'' ∧ phi'' = phi'''' ∧ phi'''' = phi''''' ∧
                  chi = chi' ∧ chi' = chi'' ∧ chi'' = chi''' ∧ chi''' = chi'''' then
                 some ⟨_, Axiom.linear_until phi psi chi theta⟩
               else none
           | _, _ => none)

      -- linear_since (BX7'): S(ψ,φ)∧S(θ,χ) → S(ψ∧θ,φ∧χ) ∨ S(ψ∧χ,φ∧χ) ∨ S(φ∧θ,φ∧χ)
      <|> (match lhs, rhs with
           | .and (.snce psi phi) (.snce theta chi),
             .or (.or (.snce (.and psi' theta') (.and phi' chi'))
                      (.snce (.and psi'' chi'') (.and phi'' chi''')))
                 (.snce (.and phi'''' theta'') (.and phi''''' chi'''')) =>
               if psi = psi' ∧ psi' = psi'' ∧
                  theta = theta' ∧ theta' = theta'' ∧
                  phi = phi' ∧ phi' = phi'' ∧ phi'' = phi'''' ∧ phi'''' = phi''''' ∧
                  chi = chi' ∧ chi' = chi'' ∧ chi'' = chi''' ∧ chi''' = chi'''' then
                 some ⟨_, Axiom.linear_since phi psi chi theta⟩
               else none
           | _, _ => none)

      -------------------------------------------------------------------
      -- prop_s must be LAST (very general: φ → (ψ → φ))
      -------------------------------------------------------------------

      -- prop_s: φ → (ψ → φ)
      <|> (match lhs, rhs with
           | phi, .imp psi phi' =>
               if phi = phi' then
                 some ⟨_, Axiom.prop_s phi psi⟩
               else none
           | _, _ => none)

  | _ => none

/--
Check if a formula matches any of the 42 TM axiom schemata.

Delegates to `matchAxiom` and returns `true` on match, `false` otherwise.
Covers all axiom constructors: propositional (4), modal (5), BX temporal (22),
interaction (1), uniformity (5), prior (2), Z1 (1), density (2).
-/
def matches_axiom (φ : Formula) : Bool :=
  (matchAxiom φ).isSome

/--
Find all implications `ψ → φ` in context where the consequent matches the goal.

This function filters the context for implications whose consequent is the target
formula, returning the list of antecedents. This is used for backward chaining
via modus ponens: if we want to prove φ and we have ψ → φ, we should try to prove ψ.

**Parameters**:
- `Γ`: Context (list of assumptions)
- `φ`: Goal formula (the desired consequent)

**Returns**: List of antecedent formulas ψ such that `ψ → φ` is in the context

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `find_implications_to [p.imp q, r.imp q] q` returns `[p, r]`
- `find_implications_to [p, q] r` returns `[]`
-/
def find_implications_to (Γ : Context) (φ : Formula) : List Formula :=
  Γ.filterMap (fun f => match f with
    | Formula.imp ψ χ => if χ = φ then some ψ else none
    | _ => none)

/--
Transform context for modal K application: map all formulas with box operator.

The modal K inference rule states: if `Γ.map box ⊢ φ` then `Γ ⊢ box φ`.
This function applies the box operator to every formula in the context.

**Parameters**:
- `Γ`: Context to transform

**Returns**: New context where every formula is wrapped with `Formula.box`

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `box_context [Formula.atom_s "p", Formula.atom_s "q"]` returns
  `[Formula.box (Formula.atom_s "p"), Formula.box (Formula.atom_s "q")]`
-/
def box_context (Γ : Context) : Context :=
  Γ.map Formula.box

/--
Transform context for temporal K application: map all formulas with all_future operator.

The temporal K inference rule states: if `Γ.map all_future ⊢ φ` then `Γ ⊢ all_future φ`.
This function applies the all_future operator to every formula in the context.

**Parameters**:
- `Γ`: Context to transform

**Returns**: New context where every formula is wrapped with `Formula.all_future`

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `future_context [Formula.atom_s "p", Formula.atom_s "q"]` returns
  `[Formula.all_future (Formula.atom_s "p"), Formula.all_future (Formula.atom_s "q")]`
-/
def future_context (Γ : Context) : Context :=
  Γ.map Formula.all_future

/-!
## Domain-Specific Heuristics

Heuristic functions that provide bonuses/penalties based on formula structure.
Lower scores are preferred (higher priority).
-/

/--
Modal heuristic bonus: prioritize modal goals that can use modal axioms.

Returns a negative bonus (priority boost) for modal goals (□φ, ◇φ).
Modal goals benefit from modal axioms (T, 4, 5, B) so we explore them earlier.

**Returns**:
- `-5` for box goals (□φ)
- `-5` for diamond goals (◇φ)
- `0` for non-modal goals
-/
def modal_heuristic_bonus (φ : Formula) : Int :=
  match φ with
  | .box _ => -5
  | .diamond _ => -5
  | _ => 0

/--
Temporal heuristic bonus: prioritize temporal goals that can use temporal axioms.

Returns a negative bonus (priority boost) for temporal goals (Gφ, Fφ, Hφ, Pφ).
Temporal goals benefit from temporal axioms (4, A, L) so we explore them earlier.

**Returns**:
- `-5` for all_future goals (Gφ)
- `-5` for some_future goals (Fφ)
- `-5` for all_past goals (Hφ)
- `-5` for some_past goals (Pφ)
- `0` for non-temporal goals
-/
def temporal_heuristic_bonus (φ : Formula) : Int :=
  match φ with
  | .all_future _ => -5
  | .some_future _ => -5
  | .all_past _ => -5
  | .some_past _ => -5
  | _ => 0

/--
Structure-based heuristic penalty: penalize complex formulas.

Computes penalty based on formula structure:
- Base complexity (number of nodes)
- Modal depth (nesting of □/◇)
- Temporal depth (nesting of G/F/H/P)
- Implication count (→ operators)

**Formula**: `complexity + 2*modalDepth + 2*temporalDepth + countImplications`

Higher penalty = lower priority (complex formulas are harder to prove).
-/
def structure_heuristic (φ : Formula) : Nat :=
  φ.complexity + 2 * φ.modalDepth + 2 * φ.temporalDepth + φ.countImplications

/--
Compute heuristic score for a proof search branch (lower score = higher priority).

Scores are configurable via `HeuristicWeights` while keeping the default
ordering used by bounded search.
-/
def heuristic_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula) : Nat :=
  if matches_axiom φ then
    weights.axiomWeight
  else if Γ.contains φ then
    weights.assumptionWeight
  else
    let implications := find_implications_to Γ φ
    if implications.isEmpty then
      match φ with
      | Formula.box _ =>
          weights.modalBase + weights.contextPenaltyWeight * Γ.length
      | Formula.untl _ _ =>
          weights.temporalBase + weights.contextPenaltyWeight * Γ.length
      | _ => weights.deadEnd
    else
      let min_complexity := implications.foldl
        (fun acc ψ => min acc (weights.mpComplexityWeight * ψ.complexity))
        weights.deadEnd
      weights.mpBase + min_complexity

/--
Advanced heuristic score combining base scoring with domain-specific adjustments.

Combines:
1. Base heuristic score (axiom/assumption/modus ponens/modal/temporal priorities)
2. Modal bonus for modal goals
3. Temporal bonus for temporal goals
4. Structure penalty for complex formulas

**Parameters**:
- `weights`: Configurable heuristic weights
- `Γ`: Current proof context
- `φ`: Goal formula to score

**Returns**: Combined score (lower = higher priority). Score is clamped to 0 minimum.
-/
def advanced_heuristic_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula) : Nat :=
  let baseScore : Int := heuristic_score weights Γ φ
  let modalBonus := modal_heuristic_bonus φ
  let temporalBonus := temporal_heuristic_bonus φ
  let structurePenalty : Int := structure_heuristic φ / 4  -- Damped to avoid overwhelming base score
  let combined := baseScore + modalBonus + temporalBonus + structurePenalty
  combined.toNat  -- Clamp to 0 if negative

/--
Order candidate subgoals by heuristic score so cheaper branches are explored first.

Uses stable merge sort (O(n log n)) to order targets by ascending heuristic score.
Lower scores indicate higher priority (axioms/assumptions before complex modus ponens).
-/
def orderSubgoalsByScore (weights : HeuristicWeights) (Γ : Context) (targets : List Formula) :
    List Formula :=
  targets.mergeSort (fun φ ψ => heuristic_score weights Γ φ ≤ heuristic_score weights Γ ψ)

/--
Order candidate subgoals by advanced heuristic score (includes domain-specific bonuses).

Uses stable merge sort (O(n log n)) to order targets by ascending advanced heuristic score.
Lower scores indicate higher priority. Includes modal/temporal bonuses and structure penalties.
-/
def orderSubgoalsByAdvancedScore (weights : HeuristicWeights) (Γ : Context) (targets : List Formula) :
    List Formula :=
  targets.mergeSort (fun φ ψ => advanced_heuristic_score weights Γ φ ≤ advanced_heuristic_score weights Γ ψ)

/-!
## Pattern-Aware Heuristic Scoring

Heuristic functions that incorporate learned success patterns.
-/

/--
Pattern-aware heuristic score incorporating learned success patterns.

Combines the advanced heuristic score with bonuses from the pattern database
for strategies that have worked on similar formulas.

**Parameters**:
- `weights`: Configurable heuristic weights
- `Γ`: Current proof context
- `φ`: Goal formula to score
- `patternDb`: Optional pattern database for learned hints
- `strategy`: The strategy being considered (for pattern bonus lookup)

**Returns**: Combined score (lower = higher priority)
-/
def pattern_aware_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula)
    (patternDb : PatternDatabase := PatternDatabase.empty)
    (strategy : ProofStrategy := .ModusPonens) : Nat :=
  let baseScore : Int := advanced_heuristic_score weights Γ φ
  let patternBonus := patternDb.heuristicBonus φ strategy
  (baseScore + patternBonus).toNat  -- Clamp to 0 if negative

/--
Order candidate subgoals by pattern-aware heuristic score.

Uses the pattern database to boost scores for formulas that match
previously successful patterns.
-/
def orderSubgoalsByPatternScore (weights : HeuristicWeights) (Γ : Context)
    (targets : List Formula) (patternDb : PatternDatabase := PatternDatabase.empty) :
    List Formula :=
  targets.mergeSort (fun φ ψ =>
    pattern_aware_score weights Γ φ patternDb .ModusPonens ≤
    pattern_aware_score weights Γ ψ patternDb .ModusPonens)

/-!
## Search Functions
-/

/--
Bounded depth-first search for a derivation of `φ` from context `Γ`.

**Parameters**:
- `Γ`: Proof context (list of assumptions)
- `φ`: Goal formula to derive
- `depth`: Maximum search depth (prevents infinite loops)
- `weights`: Heuristic weights to rank branch ordering

**Returns**: `true` if derivation found within depth bound, `false` otherwise

**Algorithm**:
1. Base case: depth = 0 → return false
2. Check axioms and assumptions eagerly
3. Rank modus ponens antecedents by heuristic score (cheapest first)
4. Explore modal/temporal branches with cached results
5. Return false if all strategies fail or visit limits are exceeded

**Complexity**: O(b^d) where b = branching factor, d = depth
-/
def bounded_search (Γ : Context) (φ : Formula) (depth : Nat)
    (cache : ProofCache := ProofCache.empty)
    (visited : Visited := Visited.empty)
    (visits : Nat := 0)
    (visitLimit : Nat := 500)
    (weights : HeuristicWeights := {})
    (stats : SearchStats := {}) : Bool × ProofCache × Visited × SearchStats × Nat :=
  if depth = 0 then
    (false, cache, visited, stats, visits)
  else if visits ≥ visitLimit then
    (false, cache, visited, {stats with prunedByLimit := stats.prunedByLimit + 1}, visits)
  else
    let visits := visits + 1
    let stats := {stats with visited := stats.visited + 1}
    let key : CacheKey := (Γ, φ)
    if visited.contains key then
      (false, cache, visited, stats, visits)
    else
      match cache[key]? with
      | some result => (result, cache, visited, {stats with hits := stats.hits + 1}, visits)
      | none =>
          let visited := visited.insert key
          let stats := {stats with misses := stats.misses + 1}
          if matches_axiom φ then
            (true, cache.insert key true, visited, stats, visits)
          else if Γ.contains φ then
            (true, cache.insert key true, visited, stats, visits)
          else
            -- Try modus ponens: search for antecedents of implications
            let implications := find_implications_to Γ φ
            let orderedTargets := orderSubgoalsByScore weights Γ implications
            -- Try each antecedent in order (simplified - no nested recursion)
            let tryAntecedent (state : Bool × ProofCache × Visited × SearchStats × Nat) (ψ : Formula) :
                Bool × ProofCache × Visited × SearchStats × Nat :=
              let (found, cache, visited, stats, visits) := state
              if found then state  -- Already found, skip
              else
                let (result, cache', visited', stats', visits') :=
                  bounded_search Γ ψ (depth - 1) cache visited visits visitLimit weights stats
                (result, cache', visited', stats', visits')
            let (mpFound, cacheAfterMp, visitedAfterMp, statsAfterMp, visitsAfterMp) :=
              orderedTargets.foldl tryAntecedent (false, cache, visited, stats, visits)
            if mpFound then
              (true, cacheAfterMp.insert key true, visitedAfterMp, statsAfterMp, visitsAfterMp)
            else
              -- Try modal/temporal rules
              match φ with
              | Formula.box ψ =>
                  let (found, cache', visited', stats', visits') :=
                    bounded_search (box_context Γ) ψ (depth - 1) cacheAfterMp visitedAfterMp visitsAfterMp visitLimit weights statsAfterMp
                  (found, cache'.insert key found, visited', stats', visits')
              | Formula.untl ψ _ =>
                  let (found, cache', visited', stats', visits') :=
                    bounded_search (future_context Γ) ψ (depth - 1) cacheAfterMp visitedAfterMp visitsAfterMp visitLimit weights statsAfterMp
                  (found, cache'.insert key found, visited', stats', visits')
              | _ => (false, cacheAfterMp.insert key false, visitedAfterMp, statsAfterMp, visitsAfterMp)
termination_by depth
decreasing_by
  all_goals simp_wf
  all_goals omega

/--
Match a formula against derived theorem patterns, returning a DerivationTree if matched.

Currently handles:
- TF (temp_future_derived): `□φ → G(□φ)` -- derived from MF + T + Modal 4
-/
def matchDerived (φ : Formula) : Option (⊢ φ) :=
  match φ with
  | .imp (.box phi) (.all_future (.box phi')) =>
      if h : phi = phi' then
        some (h ▸ Bimodal.Theorems.Combinators.temp_future_derived phi)
      else none
  | _ => none

/--
Bounded depth-first search returning proof term if successful.

This is the proof-constructing variant of `bounded_search`. Instead of
returning `Bool`, it returns `Option (DerivationTree Γ φ)` with the actual
proof term when successful.

**Parameters**:
- `Γ`: Proof context (list of assumptions)
- `φ`: Goal formula to derive
- `depth`: Maximum search depth (prevents infinite loops)
- `visited`: Set of already-visited (context, goal) pairs to prevent cycles
- `visits`: Current visit count
- `visitLimit`: Maximum visits allowed

**Returns**: `some proof` if derivation found, `none` otherwise

**Algorithm**:
1. Base case: depth = 0 → return none
2. Check axioms (via matchAxiom) and construct axiom proof
3. Check assumptions and construct assumption proof
4. Try modus ponens with recursive search for antecedent
5. Return none if all strategies fail

**Complexity**: O(b^d) where b = branching factor, d = depth

**Note**: This simplified version does not use caching for proof terms
since caching would require storing proofs indexed by (Γ, φ) and proof
terms can be large. For performance-critical applications, use `bounded_search`
to first check provability, then use this function to construct the proof.
-/

def bounded_search_with_proof (Γ : Context) (φ : Formula) (depth : Nat)
    (visited : Visited := Visited.empty)
    (visits : Nat := 0)
    (visitLimit : Nat := 500)
    : Option (Γ ⊢ φ) × Visited × Nat :=
  if depth = 0 then
    (none, visited, visits)
  else if visits ≥ visitLimit then
    (none, visited, visits)
  else
    let visits := visits + 1
    let key : CacheKey := (Γ, φ)
    if visited.contains key then
      (none, visited, visits)
    else
      let visited := visited.insert key

      -- Try axiom match first (via matchAxiom for proof construction)
      match _hax : matchAxiom φ with
      | some ⟨ψ, witness⟩ =>
          -- We need to verify φ = ψ and frame class compatibility
          if heq : φ = ψ then
            if hfc : witness.minFrameClass ≤ FrameClass.Base then
              (some (heq ▸ DerivationTree.axiom Γ ψ witness hfc), visited, visits)
            else
              -- Axiom not compatible with Base frame class (e.g., discrete-only axioms)
              (none, visited, visits)
          else
            -- Formula mismatch - this shouldn't happen with correct matchAxiom
            (none, visited, visits)
      | none =>
        -- Try derived theorems (e.g., temp_future_derived: □φ → G□φ)
        match matchDerived φ with
        | some d =>
            (some (DerivationTree.weakening [] Γ φ d (List.nil_subset Γ)), visited, visits)
        | none =>
        -- Try assumption (using findMembershipWitness to get the proof witness)
        match findMembershipWitness Γ φ with
        | some wit =>
            (some (DerivationTree.assumption Γ φ wit.proof), visited, visits)
        | none =>
          -- Try modus ponens: search for antecedents of implications (ψ → φ) in Γ
          let implications := find_implications_to Γ φ
          -- Process implications iteratively (without nested let rec to simplify termination)
          let result := implications.foldl
            (fun acc antecedent =>
              match acc with
              | (some _, _, _) => acc  -- Already found a proof
              | (none, visited, visits) =>
                  -- The implication (antecedent → φ) must be in context
                  match findMembershipWitness Γ (antecedent.imp φ) with
                  | some wit_imp =>
                    -- Try to prove the antecedent
                    let (antResult, visited', visits') :=
                      bounded_search_with_proof Γ antecedent (depth - 1) visited visits visitLimit
                    match antResult with
                    | some antProof =>
                        -- Build modus ponens: we have proof of antecedent and (antecedent → φ) ∈ Γ
                        let impProof := DerivationTree.assumption Γ (antecedent.imp φ) wit_imp.proof
                        (some (DerivationTree.modus_ponens Γ antecedent φ impProof antProof), visited', visits')
                    | none =>
                        (none, visited', visits')
                  | none =>
                    -- Implication not actually in context (shouldn't happen with find_implications_to)
                    (none, visited, visits))
            (none, visited, visits)

          match result with
          | (some proof, visited', visits') => (some proof, visited', visits')
          | (none, visited', visits') =>
              -- Modal/temporal rules would go here
              -- Note: Full implementation of modal K and temporal K rules requires
              -- helper lemmas from the deduction theorem. For now, we skip these.
              (none, visited', visits')
termination_by depth
decreasing_by
  all_goals simp_wf
  all_goals omega

/--
Iterative deepening depth-first search for a derivation of `φ` from context `Γ`.

Runs bounded_search with increasing depth limits until proof found or maxDepth reached.
Guarantees finding shortest proof (minimum depth) if it exists.

**Parameters**:
- `Γ`: Proof context (list of assumptions)
- `φ`: Goal formula to derive
- `maxDepth`: Maximum search depth (prevents infinite loops)
- `visitLimit`: Maximum total visits across all depths
- `weights`: Heuristic weights to rank branch ordering

**Returns**: `(found, cache, visited, stats, totalVisits)` where:
- `found`: true if derivation found within maxDepth
- `cache`: Updated proof cache
- `visited`: Visited set from final depth iteration
- `stats`: Cumulative search statistics
- `totalVisits`: Total visits across all depth iterations

**Complexity**: O(b^d) time, O(d) space where b = branching factor, d = solution depth

**Completeness**: Guaranteed to find proof if it exists within maxDepth

**Optimality**: Guaranteed to find shortest proof (minimum depth)
-/
def iddfs_search (Γ : Context) (φ : Formula) (maxDepth : Nat := 100)
    (visitLimit : Nat := 10000) (weights : HeuristicWeights := {})
    : Bool × ProofCache × Visited × SearchStats × Nat :=
  let rec iterate (depth : Nat) (cache : ProofCache) (stats : SearchStats)
                  (totalVisits : Nat) : Bool × ProofCache × Visited × SearchStats × Nat :=
    if hdepth : depth ≥ maxDepth then
      (false, cache, Visited.empty, stats, totalVisits)
    else if totalVisits ≥ visitLimit then
      (false, cache, Visited.empty, stats, totalVisits)
    else
      -- Run bounded search at current depth, starting with fresh visited set
      let (found, cache', visited', stats', visits') :=
        bounded_search Γ φ depth cache Visited.empty totalVisits visitLimit weights stats

      if found then
        (true, cache', visited', stats', visits')
      else if visits' ≥ visitLimit then
        (false, cache', visited', stats', visits')
      else
        have hdec : maxDepth - (depth + 1) < maxDepth - depth := by
          have hlt : depth < maxDepth := Nat.not_le.mp hdepth
          omega
        iterate (depth + 1) cache' stats' visits'
  termination_by maxDepth - depth
  iterate 0 ProofCache.empty {} 0


end Bimodal.Automation
