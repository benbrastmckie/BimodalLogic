// ============================================================================
// p4-proof-automation.typ
// Part II chapter -- Proof Automation
// Lean name ground truth: Automation/ live source (see ../SYNC-MAP.md);
// line counts cited from live files.
// ============================================================================

#import "../template.typ": *

= Proof Automation <sec:proof-automation>

#chapter-header(
  description: [The ~4,300-line tactic, Aesop-integration, and bounded-proof-search half of `Automation/`: what each entry point does, one worked invocation each, and a precise account of what is wired to what.],
  dependencies: [Chapter 3 (proof theory) for the axiom/rule vocabulary these tactics target.],
)


== Tactics

Three user-facing tactics automate common derivation patterns; `apply_axiom` and `modal_t` live in `Automation/Tactics/Helpers.lean`, and `tm_auto` in `Tactics/Commands.lean`.

#items[
  #item[`apply_axiom` (`Tactics/Helpers.lean:96`) -- expands to `apply DerivationTree.axiom; refine ?_`, unifying the goal with an axiom schema and letting Lean infer the axiom's formula parameters via `refine`.]
  #item[`modal_t` (`Tactics/Helpers.lean:113`) -- named for the T axiom $square.stroked φ arrow.r φ$; its macro body expands identically to `apply_axiom`'s (`apply DerivationTree.axiom; refine ?_`), so it applies to any axiom-shaped goal.]
  #item[`tm_auto` (`Tactics/Commands.lean:284`) -- delegates to `runModalSearch` with `SearchConfig.default` (search depth 10, overridable: `tm_auto 5`). It is implemented directly over the bounded search engine below, not over Aesop.]
]

A typical invocation: given a goal of the shape "$square.stroked φ arrow.r square.stroked square.stroked φ$" (the M4 pattern), `tm_auto` searches up to depth 10 via bounded proof search (@sec:proof-search-engine below) and closes the goal if a derivation exists within that bound.
Related tactics `modal_search` (`Tactics/Commands.lean:105`), `temporal_search` (`Tactics/Commands.lean:177`), and `propositional_search` (`Tactics/Commands.lean:233`) restrict the search to a single operator family.

== Aesop Integration

`AesopRules.lean` (276 lines, sorry-free) registers `@[aesop safe apply]`/`@[aesop safe forward]`/`@[aesop norm unfold]` rules over direct axiom applications (7 rules: `modal_t`, `prop_k`, `prop_s`, `modal_4`, `modal_b`, `temp_4`, `temp_a`), forward-chaining variants of the same seven, three inference-rule apply rules (modus ponens, modal K, temporal K), and four normalization unfold rules.
Excluded by design (soundness incomplete for these under the current axiom set): `temp_l`, `modal_future`, `temp_future_derived`.

Every Aesop attribute in the file is unqualified, so the rules register into Aesop's *default* rule set; there is no dedicated rule set for the logic.
`AesopRules.lean` serves direct `aesop` invocations by users who opt in explicitly -- `tm_auto` itself does not route through Aesop.
Reach for plain `aesop` (default rule set) when a goal is a short chain of the seven covered axioms; reach for `tm_auto` for anything requiring the bounded search engine's heuristics.

== Bounded Proof Search <sec:proof-search-engine>

`ProofSearch/Core.lean` (1,195 lines, sorry-free) is the search engine `tm_auto` and its variants call into.
`bounded_search` (`ProofSearch/Core.lean:958`) is a depth-limited, memoized DFS (default visit limit 500) with several heuristic-ordering functions (`heuristic_score` at `ProofSearch/Core.lean:829`, `advanced_heuristic_score` at `ProofSearch/Core.lean:865`, `pattern_aware_score` at `ProofSearch/Core.lean:914`) that reorder subgoals to prefer promising branches; `bounded_search_with_proof` (`ProofSearch/Core.lean:1064`) is the proof-carrying variant that actually produces a `DerivationTree`.
`iddfs_search` (`ProofSearch/Core.lean:1168`, default max depth 100, default visit limit 10000) iteratively deepens `bounded_search`, and is documented as complete and optimal (shortest proof) within the max-depth bound.
`ProofSearch/Strategies.lean` (379 lines, sorry-free) adds a priority-queue best-first search (`bestFirst_search`, `ProofSearch/Strategies.lean:90`) and a `SearchStrategy` dispatcher (`ProofSearch/Strategies.lean:187`: `BoundedDFS`/`IDDFS`/`BestFirst`, default IDDFS depth 100) that `search` (`ProofSearch/Strategies.lean:219`) selects between, plus a learning variant (`search_with_learning`, `ProofSearch/Strategies.lean:304`) that records success patterns (below) across calls.
Relationship to the tableau (@sec:decidability-practice): this is a *different* algorithm on the *same* underlying proof system -- the tableau builds a refutation tree over signed subformulas of a single target formula and is what `decide` ultimately falls back to, while this search engine explores `DerivationTree` construction directly and is what the tactics above call; `decide` itself also tries this engine first, as a fast path, before falling back to the tableau (@sec:decidability-practice).

=== The Search Space

A search node is a pair of a context $Gamma$ and a goal formula $phi.alt$ -- exactly the data of a derivability claim $Gamma tack.r phi.alt$ -- and the engine explores backward from the target claim toward closed leaves.
At each node, `bounded_search` proceeds through an ordered cascade:

+ *Leaf checks first.* If $phi.alt$ matches an axiom schema (`matches_axiom`) or is an assumption in $Gamma$, the node closes immediately.
+ *Backward modus ponens.* Otherwise the engine collects every $psi$ such that $psi arrow.r phi.alt$ is available from $Gamma$ (`find_implications_to`) and recursively searches each antecedent $psi$ at depth $d - 1$, cheapest-scoring antecedent first.
+ *Structural descent.* If the goal is itself modal or temporal ($square.stroked psi$ or an Until formula), the engine descends into $psi$ under the correspondingly transformed context -- the backward image of the necessitation-style rules.

Three mechanisms keep the exploration tractable.
A *memoization cache* keyed on $(Gamma, phi.alt)$ pairs stores completed verdicts, so the same claim is never searched twice; a *visited set* on the current path blocks cycles; and a global *visit limit* (default 500) bounds total work even when the depth bound alone would admit an exponential frontier.
The engine also accumulates `SearchStats` (visits, cache hits and misses, limit-pruned branches), which the learning layer below consumes.

=== Heuristic Ordering

The subgoal ordering is where the engine's domain knowledge lives.
`heuristic_score` assigns each candidate a cost: axiom-shaped goals score lowest, context assumptions next, modus-ponens candidates score by the complexity of their cheapest antecedent, and modal or temporal goals pay a base cost plus a penalty growing with context size; goals with none of these prospects score as dead ends.
`advanced_heuristic_score` layers domain-specific adjustments on top -- bonuses for modal and temporal goals and a damped structural penalty `structure_heuristic` combining formula complexity, modal depth, temporal depth, and implication count -- and `pattern_aware_score` further adds bonuses from the learned pattern database described below.
All weights are configurable through a `HeuristicWeights` record, so the default ordering can be re-tuned without touching the algorithm.

=== Worked Invocations

Consider the M4 pattern $square.stroked p arrow.r square.stroked square.stroked p$ under `tm_auto`.
The goal is not an assumption; `matches_axiom` recognizes it against the axiom table (M4 is primitive in BX), and the search closes at depth 1 with a one-node `DerivationTree`.
A goal requiring genuine search, such as a chained implication whose antecedents must themselves be derived, exercises the modus-ponens cascade: each candidate antecedent is scored, the cheapest is searched first, and the memoization cache ensures that shared antecedents across branches are proven once.
The single-family variants behave identically but restrict the candidate moves: `modal_search` closes $tack.r square.stroked p arrow.r p$ (T) and $tack.r square.stroked p arrow.r square.stroked square.stroked p$ (4) without considering temporal rules, which shrinks the branching factor when the goal's operator family is known in advance (worked instances in the `Examples/` library are collected in the dual-verification chapter).

== Learning and Game-Theoretic Tactics

`SuccessPatterns.lean` (423 lines, sorry-free) implements a `PatternDatabase`-based heuristic layer: it records structural features (modal depth, temporal depth, top-level operator, context size) of goals that were successfully closed, and boosts the heuristic score of future goals matching those patterns, citing the machine-learning-guided-search literature (Yang et al. 2019; Kaliszyk et al. 2018) as its design inspiration.
The loop is deliberately conservative: patterns only ever *reorder* the search frontier via `pattern_aware_score`, so a mistrained database can slow the search but can never cause an unsound answer -- soundness lives entirely in the `DerivationTree` terms the search produces, never in the heuristics that find them.
`EFGameTactics.lean` (326 lines, sorry-free) is a narrower-purpose module: tactic macros (`simp_game_tuple`, `game_tuple_unfold`, and per its header comment, components for pivot-order and winning-condition reasoning) automating repetitive steps in the `WeakCanonical/EFGames` Ehrenfeucht-Fraïssé game infrastructure, built specifically for the Gabbay-Hodkinson-Reynolds expressive-completeness proof technique @gabbayhodkinsonreynolds1994.
The module belongs to the discrete-case expressiveness infrastructure of the metalogic chapter: the GHR EF-game technique is the classical descendant of Kamp-style expressive-completeness arguments @kamp1971formalproperties for temporal logic over linear orders, and `EFGameTactics.lean` automates the game-position bookkeeping that technique requires.

== Module Map

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Module*], [*Lines*], [*Role*]),
    table.hline(),
    [`Tactics/Helpers.lean`], [1,032], [`apply_axiom`, `modal_t`, and supporting macro infrastructure],
    [`Tactics/Commands.lean`], [710], [`tm_auto`, `modal_search`, `temporal_search`, `propositional_search`],
    [`ProofSearch/Core.lean`], [1,195], [`bounded_search`, `iddfs_search`, heuristic scoring, memoization],
    [`ProofSearch/Strategies.lean`], [379], [Best-first search, `SearchStrategy` dispatcher, learning variant],
    [`AesopRules.lean`], [276], [Aesop rule registrations for direct `aesop` use],
    [`SuccessPatterns.lean`], [423], [`PatternDatabase` learned-heuristic layer],
    [`EFGameTactics.lean`], [326], [EF-game bookkeeping tactics for `WeakCanonical/EFGames`],
    table.hline(),
  ),
  caption: [The tactic and proof-search half of `Automation/` (live line counts). The dataset-pipeline half is covered in @sec:dataset-pipeline.],
)

All modules in the table are sorry-free.

