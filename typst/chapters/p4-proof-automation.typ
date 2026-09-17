// ============================================================================
// p4-proof-automation.typ
// Part II chapter -- Proof Automation
// Lean name ground truth: Automation/ live source (see ../SYNC-MAP.md); the
// Module Map below is rendered from a machine-generated data file
// (generated/automation-module-map.typ, scripts/typst-module-map.sh),
// never hand-copied. Freshness is enforced by
// scripts/typst-sync-check.sh Check 2's module-map sub-check.
// ============================================================================

#import "../template.typ": *
#import "../generated/automation-module-map.typ": automation-module-map, automation-module-total

// Thousands-separator for line counts (max value in practice is 4 digits,
// but this handles any width via a single recursive comma insertion).
#let fmt-lines(n) = {
  let s = str(n)
  if s.len() > 3 {
    fmt-lines(int(s.slice(0, s.len() - 3))) + "," + s.slice(s.len() - 3)
  } else {
    s
  }
}

// Look up a generated row's line count by path, for inline prose that cites
// a module-map count without hand-copying it.
#let module-lines(path) = automation-module-map.find(row => row.at(0) == path).at(1)

= Proof Automation <sec:proof-automation>

#chapter-header(
  description: [The tactic surface, the two proof-search engines behind it, and a retired Aesop integration, in `Automation/`: what each entry point does, one worked invocation each, and a precise account of what is wired to what.],
  dependencies: [Chapter 3 (proof theory) for the axiom/rule vocabulary these tactics target.],
)


== Tactics

Four user-facing tactics automate common derivation patterns.

#items[
  #item[`apply_axiom` (`Tactics/UserTactics.lean`) -- expands to `apply DerivationTree.axiom; refine ?_`, unifying the goal with an axiom schema and letting Lean infer the axiom's formula parameters via `refine`.]
  #item[`modal_t` (`Tactics/UserTactics.lean`) -- named for the T axiom $square.stroked φ arrow.r φ$; its macro body expands identically to `apply_axiom`'s (`apply DerivationTree.axiom; refine ?_`), so it applies to any axiom-shaped goal.]
  #item[`assumption_search` (`Tactics/UserTactics.lean`) -- searches the local context for an assumption matching the goal by definitional equality, with an explicit failure message on miss (unlike the built-in `assumption`).]
  #item[`modal_search` (`Tactics/Commands.lean`) -- the single proof-search entry point. Three syntax forms: `modal_search` alone (default depth 10, visitLimit 1000), a bare custom depth (`modal_search 5`), and named parameters (`modal_search (depth := 20)`, or `modal_search (depth := 20) (visitLimit := 2000)` for both). It runs the bounded search engine below (@sec:proof-search-engine).]
]

Two further tactics round out the surface: `deduction`/`deduction n`/`undischarge` (`Tactics/Deduction.lean`) apply the frame-class-polymorphic deduction theorem to transform a goal `Γ ⊢[fc] A → B` into `(A :: Γ) ⊢[fc] B` and back, built on `apply` rather than a syntactic match so it sees through `def`s like `Formula.neg`; and `propDecide` (`Tactics/PropDecide.lean`) reflectively decides any derivability goal whose implication/bot skeleton is a propositional tautology, reifying non-imp/bot subterms as opaque `PropForm` variables and closing with the kernel `decide` tactic (never `native_decide`).

`modal_search` is the sole survivor of what were once four search-entry tactics: per `FormalSystem/Automation.lean`'s module docstring, it "replaced `temporal_search`, `propositional_search` and `tm_auto`, which differed from it only in `SearchConfig` weight fields that `searchProof` never read, and which have been removed."

A typical invocation: given a goal of the shape "$square.stroked φ arrow.r square.stroked square.stroked φ$" (the M4 pattern), `modal_search` searches up to depth 10 via the bounded search engine below (@sec:proof-search-engine) and closes the goal if a derivation exists within that bound.

== A Retired Aesop Rule Set

A dedicated Aesop rule set (named, by its own removed declaration, after the logic) once existed, populated across two modules (`Boneyard/RetiredTactics/AesopRuleSet.lean`, `Boneyard/RetiredTactics/AesopRules.lean`, 322 lines total) with rule-set-scoped attributes over the seven axioms most amenable to direct application, their forward-chaining variants, three inference-rule apply rules, and four normalization unfold rules.
It was retired on measurement, not on a design change: because the rules lived in that *dedicated* rule set rather than Aesop's default one, plain `aesop` never saw them, and reaching them required an explicit rule-set-qualified invocation naming it -- of which there was none, anywhere in the live tree or in `Tests/`. The rule set therefore had zero consumers of any kind: it was not merely unused, it was unreachable.

The deeper reason Aesop's automatic proof reconstruction does not work over these goals at all, even setting reachability aside: `Axiom` is `Prop`-valued while `DerivationTree` is `Type`-valued, and Aesop's reconstruction machinery is built for `Prop`-valued goals (per `Tactics/Search.lean`'s docstring, which is why the live search engines below work at the meta level with `mkAppM` instead).

Both retired modules were moved unchanged to `FormalSystem/Boneyard/RetiredTactics/`; see that directory's `README.md` for the full inventory and the invocation count that retired it.

== Bounded Proof Search <sec:proof-search-engine>

Two independent search engines live under `Automation/`, with different interfaces, different callers, and no import relationship between them.

=== The tactic engine (`Tactics/Search.lean`)

`searchProof` is what `modal_search` runs. It tries, in order: `tryAxiomMatch` (42 of the 45 axiom schemata; the three Layer-9 Reynolds Dedekind axioms `prior_U_gap`, `prior_S_gap` and `sep` are outside its list), `tryLemmaMatch` (tagged-lemma matching), `tryAssumptionMatch` (context lookup), `tryModusPonens` (backward-chaining decomposition), `tryModalK` (reduce $square.stroked Gamma tack.r square.stroked φ$ to $Gamma tack.r φ$), and `tryTemporalK` (the temporal analogue). This is a bounded depth-first search under an `IO.Ref`-threaded visit counter (`modal_search`'s `visitLimit`, default 1000), working entirely in `TacticM` and constructing proof terms directly with `mkAppM` -- the same `Prop`/`Type` mismatch discussed above rules out returning ordinary proof witnesses.

=== The `ProofSearch/` engine (`ProofSearch/Core.lean`, `ProofSearch/Strategies.lean`)

A second, larger search engine, reachable from *no* tactic. `boundedSearch` is a depth-limited, memoized DFS (default visit limit 500) with several heuristic-ordering functions (`heuristicScore`, `advancedHeuristicScore`, `patternAwareScore`) that reorder subgoals to prefer promising branches; `boundedSearchWithProof` is the proof-carrying variant that actually produces a `DerivationTree`. `iddfsSearch` (default max depth 100, default visit limit 10000) iteratively deepens `boundedSearch`, and is documented as complete and optimal (shortest proof) within the max-depth bound. `ProofSearch/Strategies.lean` adds a priority-queue best-first search (`bestFirstSearch`) and a `SearchStrategy` dispatcher (`BoundedDFS`/`IDDFS`/`BestFirst`, default `IDDFS 100`) that `search` selects between, plus a learning variant (`searchWithLearning`) that records success patterns (below) across calls.

This is the engine `decide`'s decision procedure (`Metalogic/Decidability/DecisionProcedure.lean`) reaches for as a fast path: after the direct axiom and compositional-proof checks fail, `decide` tries `boundedSearchWithProof` before falling back to the tableau method (@sec:decidability-practice). The two engines are, in this precise sense, a *different* algorithm on the *same* underlying proof system as the tableau -- the tableau builds a refutation tree over signed subformulas of a single target formula, while this engine explores `DerivationTree` construction directly -- but neither engine here is what the tactics above call; that is the tactic engine, immediately above.

=== The Search Space

A search node is a pair of a context $Gamma$ and a goal formula $phi.alt$ -- exactly the data of a derivability claim $Gamma tack.r phi.alt$ -- and the `ProofSearch/` engine explores backward from the target claim toward closed leaves.
At each node, `boundedSearch` proceeds through an ordered cascade:

+ *Leaf checks first.* If $phi.alt$ matches an axiom schema (`matchesAxiom`) or is an assumption in $Gamma$, the node closes immediately.
+ *Backward modus ponens.* Otherwise the engine collects every $psi$ such that $psi arrow.r phi.alt$ is available from $Gamma$ (`findImplicationsTo`) and recursively searches each antecedent $psi$ at depth $d - 1$, cheapest-scoring antecedent first.
+ *Structural descent.* If the goal is itself modal or temporal ($square.stroked psi$ or an Until formula), the engine descends into $psi$ under the correspondingly transformed context -- the backward image of the necessitation-style rules.

Three mechanisms keep the exploration tractable.
A *memoization cache* keyed on $(Gamma, phi.alt)$ pairs stores completed verdicts, so the same claim is never searched twice; a *visited set* on the current path blocks cycles; and a global *visit limit* (default 500) bounds total work even when the depth bound alone would admit an exponential frontier.
The engine also accumulates `SearchStats` (visits, cache hits and misses, limit-pruned branches), which the learning layer below consumes.

=== Heuristic Ordering

The subgoal ordering is where the `ProofSearch/` engine's domain knowledge lives.
`heuristicScore` assigns each candidate a cost: axiom-shaped goals score lowest, context assumptions next, modus-ponens candidates score by the complexity of their cheapest antecedent, and modal or temporal goals pay a base cost plus a penalty growing with context size; goals with none of these prospects score as dead ends.
`advancedHeuristicScore` layers domain-specific adjustments on top -- bonuses for modal and temporal goals and a damped structural penalty `structureHeuristic` combining formula complexity, modal depth, temporal depth, and implication count -- and `patternAwareScore` further adds bonuses from the learned pattern database described below.
All weights are configurable through a `HeuristicWeights` record, so the default ordering can be re-tuned without touching the algorithm.

=== Worked Invocations

Consider the M4 pattern $square.stroked p arrow.r square.stroked square.stroked p$ under `modal_search`.
The goal is not an assumption; `tryAxiomMatch` recognizes it against the axiom table (M4 is primitive in BX), and the search closes at depth 1.
A goal requiring genuine search, such as a chained implication whose antecedents must themselves be derived, exercises `tryModusPonens`'s cascade in the tactic engine: each candidate antecedent is tried in order via the fixed strategy sequence above, and `modal_search`'s depth/visitLimit parameters bound the recursion (worked instances in the `Examples/` library are collected in the dual-verification chapter).

== Learning and Game-Theoretic Tactics

`SuccessPatterns.lean` (#module-lines("SuccessPatterns.lean") lines, sorry-free) implements a `PatternDatabase`-based heuristic layer consumed by the `ProofSearch/` engine's `patternAwareScore`: it records structural features (modal depth, temporal depth, top-level operator, context size) of goals that were successfully closed, and boosts the heuristic score of future goals matching those patterns, citing the machine-learning-guided-search literature (Yang et al. 2019; Kaliszyk et al. 2018) as its design inspiration.
The loop is deliberately conservative: patterns only ever *reorder* the search frontier, so a mistrained database can slow the search but can never cause an unsound answer -- soundness lives entirely in the `DerivationTree` terms the search produces, never in the heuristics that find them.
`EFGameTactics.lean` (331 lines, sorry-free), at `FormalSystem/Metalogic/WeakCanonical/EFGameTactics.lean` (not under `Automation/`), is a narrower-purpose module: tactic macros (`simp_game_tuple`, `game_tuple_unfold`) plus pivot-order (`pivot_chain_order'`) and winning-condition (`winning_condition_tac`) helpers automating repetitive steps in the `WeakCanonical/EFGames` Ehrenfeucht-Fraïssé game infrastructure, built specifically for the Gabbay-Hodkinson-Reynolds expressive-completeness proof technique @gabbayhodkinsonreynolds1994.
The module belongs to the discrete-case expressiveness infrastructure of the metalogic chapter: the GHR EF-game technique is the classical descendant of Kamp-style expressive-completeness arguments @kamp1971formalproperties for temporal logic over linear orders, and `EFGameTactics.lean` automates the game-position bookkeeping that technique requires.

== Module Map

#let roles = (
  "Tactics/Commands.lean": [The `modal_search` tactic: its `SearchConfig`, its two syntax forms, and the elaborators that run the search],
  "Tactics/Deduction.lean": [`deduction`, `deduction n`, `undischarge`: frame-class-polymorphic applications of `Metalogic.Core.deductionTheorem`],
  "Tactics/Meta.lean": [Shared `MetaM` plumbing for derivability goals: goal recognition, head-symbol readers, context rebuilding],
  "Tactics/PropDecide.lean": [`propDecide`: reflective tautology tactic for the propositional fragment],
  "Tactics/Search.lean": [The bounded proof-search engine behind `modal_search`: `searchProof` and its five strategies, in `TacticM` because `Axiom` is `Prop`-valued and `DerivationTree` is `Type`-valued],
  "Tactics/UserTactics.lean": [The hand-written tactics -- `apply_axiom`, `modal_t`, `assumption_search` -- and the `Formula` predicates deciding when they apply],
  "ProofSearch/Core.lean": [`boundedSearch`, `iddfsSearch`, heuristic scoring, memoization -- the larger search engine reached from `decide`'s fast path, not from any tactic],
  "ProofSearch/Strategies.lean": [Best-first search, `SearchStrategy` dispatcher, learning variant],
  "SuccessPatterns.lean": [`PatternDatabase` learned-heuristic layer],
)

// A renamed, added, or removed row in automation-module-map.typ (regenerated
// by scripts/typst-module-map.sh from a live glob) without a matching Role
// entry fails loudly here rather than drifting silently.
#assert(roles.len() == automation-module-map.len(), message: "roles dictionary and automation-module-map row count diverged -- add/remove a Role entry in p4-proof-automation.typ")

#let all-sorry-free = automation-module-map.all(row => row.at(2))

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Module*], [*Lines*], [*Role*]),
    table.hline(),
    ..automation-module-map.map(((path, lines, sorry-free)) => (
      raw(path),
      fmt-lines(lines),
      roles.at(path),
    )).flatten(),
    table.hline(),
  ),
  caption: [The tactic and proof-search half of `Automation/` (#fmt-lines(automation-module-total) lines total, machine-generated via `scripts/typst-module-map.sh`). The dataset-pipeline half is covered in @sec:dataset-pipeline.],
)

#if all-sorry-free [
  All modules in the table are sorry-free.
] else [
  Not every module in the table is sorry-free; see the generated data for which.
]
