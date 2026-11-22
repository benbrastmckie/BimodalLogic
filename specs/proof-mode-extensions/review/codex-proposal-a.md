# Proposal A — checked proof transformations and pointed semantics

Independent Codex proposal, 2026-11-19, written before reading Opus's proposal B. Baseline: BimodalLogic `81ae7a6c09807630b5000992a8bb5f689e051fa6`, Lean v4.33.0-rc1. All interfaces below are proposed unless identified as existing. This plan covers the three requested extensions, not a new logic or a Veil implementation.

## 1. Architectural commitments

Retain native Type-valued `DerivationTree fc Γ A` / `PlusDerivationTree fc Γ A`. Add a second backend for existing pointed semantic truth, not a coercion between the judgments. Share formula views, positions, parsing, diagnostics and deterministic rule lookup; keep proof construction backend-specific.

The dependency order is: existing constructors/theorems → small pure rule/certificate library → native/semantic adapters → bounded planner → tactic frontend. Pure semantic rules reuse `TruthEnv`, `ImpClause`, `UntlClause`, `SnceClause`, `BoxClause`, `StabClause` and the existing derived truth-clause lemmas. No new semantic recursor or universal language framework is needed. Soundness belongs at the layer-3 seam, not in lower `Semantics/`.

Opaque providers are consumed through their typed statements. The planner may inspect formula syntax, parameter types and context indices; it does not unfold provider proofs to discover that an assumption was supposedly unused. An opaque proof weakened to Γ is a Γ-proof until an explicit certificate says otherwise.

Reuse the existing source layer split: pure native transformations under `Theorems/ProofMode/`, semantic wrappers under `Semantics/`, metaprogramming under `Automation/ProofMode/`, and soundness adapters under `Metalogic/`. New directory trees are unnecessary initially. Keep the present TM/TM-plus adapter enum while there are only two implemented languages; factor only the capabilities actually shared.

## 2. Three kinds of equivalence

Do not call all three of these `rw` evidence:

1. Lean equality `A = B` of formula data: a syntactic cast, usable under every constructor. The existing `Automation/Normalization.lean` rfl-based unfold/fold lemmas are this kind.
2. Native equivalence: a Type-valued pair of derivations `Γ ⊢ A → B` and `Γ ⊢ B → A` (or a checked conversion from the existing encoded conjunction). This is logical interchange at the source context, not equality of ASTs.
3. Semantic equivalence: `TruthEnv.T M τ t e A ↔ TruthEnv.T M τ t e B`, indexed by its actual point. It has no native derivation interpretation by itself.

Proposed native certificate sketch:

```text
ProvIff fc Γ A B :=
  { forward : Γ ⊢[fc] A.imp B
    backward : Γ ⊢[fc] B.imp A }

RewriteCertificate fc Γ old new := ProvIff fc Γ old new
```

For a goal rewrite `old ↦ new`, create the `new` subgoal and reconstruct the original goal with `backward`. A fact rewrite uses `forward`. Ordinary Lean equality uses an explicit cast. The distinction must be visible in tracing and in lemma registration.

## 3. Positions and scope-demand compilation

Represent a selected occurrence by a checked one-hole formula path with constructor-specific selectors: implication left/right, box body, until guard/event, since guard/event, and stability body. Derived-operator views preserve the actual source definitions; do not infer argument order from English operator names. Existing `Formula.release`, `weakUntil`, `trigger`, and `weakSince` are event-first wrappers around guard-first primitives, and `before` documents another swap. Audit each wrapper separately.

A path compiler constructs the whole-formula certificate from congruence rules. It is not a text substitution engine. Starting at the hole, each enclosing constructor transforms the equivalence obligation:

| Enclosing position | Minimum supported route |
| --- | --- |
| Propositional constructors | Equivalence at the same Γ/point; implication antecedents reverse directions |
| □ body | Closed native equivalence, or necessary equivalence available at Γ; semantic equivalence for every quantified history |
| ⊡ body | Closed native equivalence, or settled equivalence; semantic equivalence on every same-state alternative |
| G/H body | Closed native equivalence, or matching G/H equivalence; semantic equivalence at all corresponding future/past points |
| Until guard/event | Future-scoped equivalence, lifted through the correct monotonicity rule; semantic equivalence throughout the relevant interval/event range |
| Since guard/event | The matching past-scoped route |

These are sufficient initial routes, not claims of logically weakest premises. Nested barriers compose in order. For example, rewriting inside `□ G A` needs a checked □/G lift chain, not an unqualified current equivalence. A closed theorem can be necessitated repeatedly without changing its dependency context. A Γ-theorem cannot be closed by the planner. Optional stronger-to-weaker scope conversions must themselves be registered proved rules.

Derived Next congruence is not uniformly ZTime-only: a conditional mapping of an existing Next proof can be valid at Base, although closed Next necessitation needs existence. Reuse `nextConsequence`/`prevConsequence` or `nextK`/`prevK` with their exact premises. Do not infer a frame requirement solely from the displayed operator.

Registration stores checked declaration names and a typed certificate builder. Metadata indexes rules but never proves a scope or side condition. Registration rejects a native theorem/semantic theorem kind mismatch. The initial native congruence library needs propositional equivalence lifting; □, G/H, Until/Since lifting derived from K/monotonicity; and stability lifting from its own K rule. Transfer TM schemas to arbitrary Plus formulas with `ofTMSubst`; native stability requires a genuine Plus rule.

## 4. User interface and context discipline

Proposed syntax, subject to parser prototyping:

```text
lrewrite hEq (path := [.boxBody, .futureBody])
lrewrite ← hEq at h as h'
lsimp only [closed_rule, scoped_fact] (maxSteps := 64)
```

Ambiguous occurrence selection reports candidate paths; it does not select an arbitrary matching subterm. Paths refer to the current formula view and are invalidated by a rewrite. Initially support an explicit path or a single unambiguous occurrence.

`at h as h'` creates a new derived fact at the same object context; it does not replace an item inside Γ or retype every local derivation. Rewriting Γ itself requires a separate proved context correspondence and complete transport of the dependent proof environment; defer that operation. Preserve existing `lapply`/`lexact` behavior and explicit `using [...]` discipline.

Simp accepts a finite explicit rule set. Closed native schemas, scoped native facts and semantic pointwise lemmas remain tagged by kind. Use deterministic head-indexed lookup, left-to-right rule order and fixed traversal. Default transformations should have decreasing orientation or occur in separate one-way phases. Do not put both folds and unfolds, or temporal dualization and its inverse, into one automatic set.

Fuel bounds matching attempts/traversal, not merely successful rewrites. Also bound nesting and reject repeated formula/rule states. Compile and replay transactionally: on failure or exhausted fuel leave the original goal intact, and explain the blocked scope, missing premise or exhausted budget. Reusable rules remain opaque references; avoid splicing or normalizing provider proof trees. Cache closed certificates globally only with their frame/profile/declaration dependencies; local plans/proofs stay within the exact fvar context and include Γ/model/history/time/environment dependencies.

## 5. Temporal proof-theory layer

Native Until/Since operations build derivations from existing schemata. They do not introduce a Lean time witness for an object-language formula.

Provide a rule-based interface with separate semantic implementations:

```text
luntil use h using rule
luntil unfold h as hEvent hContinue
luntil fold
lsince ...
ltemporal_dual using theorem
ltime_reflect
linvariant using rule
lprogress using rule [facts]
```

Keep existing `luntil guard/event`, `lsince guard/event`, `linvariant future/past`, and two-guarantee `lprogress` as compatibility shorthands. A generic `using rule` applies a native derivation-producing statement and exposes its actual premises. It is not a search across semantic theorems.

Audit matrix:

- `DiscreteUnfolding.unfoldForward event guard`: `U guard event → X event ∨ X(guard ∧ U guard event)`, ZTime. Lift explicitly to fc.
- `unfoldBackward event guard`: the converse, Base. This supplies native introduction/folding without inventing a witness.
- `unfoldBackwardSince event guard`: despite its name, the reflected forward Since-to-Previous-disjunction rule, ZTime.
- Missing work: derive the Base Since converse by closed time reflection, and transfer the required schemas to arbitrary Plus formulas.
- A native case command exposes both Next/Previous branches and joins their common conclusion. It never strips Next or asserts the eventual event now.
- Release/trigger/weak variants reuse the literal existing wrapper definitions. Prove or reuse each conversion; do not import reflexive LTL identities by name.
- Native `ltime_reflect` initially operates only on closed derivations. Contextual reflection must transform every assumption as well, through a separately proved map-context theorem. Reflecting a semantic model/history uses a correspondence, not this native constructor.
- Preserve the strict induction premises `A`, `A → X A`, `G(A → X A)` and their past mirrors. A universally scoped step omits the present.
- Extend progress first with consequence and finite case rules whose source derivations are proved. Well-founded semantic progress needs an event-occurrence hypothesis plus descent/persistence, not just a rank. A general Lean-valued rank is not automatically expressible by a finite TM formula; a native counterpart is deferred until its precise schema is derivation-producing.

Before exposing a rule, the catalog records its source definition, AST convention, context dependencies, frame hypotheses, retained/discharged assumptions, and proof-producing theorem. Missing source theorems are explicit implementation dependencies, not semantic promises.

## 6. Pointed semantic backend

Recognize existing `TruthAt`, `PlusTruthAt`, and the corresponding `TruthEnv.T` instances without first fully unfolding their recursors. A small dependent focus view contains the actual model M, history τ, time t and inert environment e. Do not create a parallel model representation or erase those indices into labels.

Use the existing `TruthClauses` classes for pure intro/elimination/congruence lemmas, requiring only the operator capabilities consumed. TM/TM-plus adapters preserve their existing definitions. `PUnit` stays an implementation detail for their environments; future environment-changing operators are outside this extension.

The same surface commands can dispatch on a unique typed goal kind. Native commands return derivation data; semantic commands return Lean proofs. No failed native match may silently become a semantic fallback. Explicit `luse_derivation d` invokes `soundness_in` or `Conservativity.plus_soundness_in`, leaving `fc.Sat F` and all Γ-facts at this exact point as obligations. At the current baseline `.Base.Sat F` includes regularity; it is not `True`. There is no reverse semantic-to-native command.

Semantic operations:

- G/H introduction chooses an arbitrary later/earlier time and preserves its inequality; F/P introduction supplies a time and its strict direction.
- □ introduction chooses an arbitrary history at the same time; stability adds the current-state equation. Possibility supplies a typed history and the relevant relation evidence.
- Until/Since introduction supplies an event time, its ordering, event truth there, and guard truth on the strict open interval. Elimination retains all four pieces. Endpoint obligations for inclusive variants come from an explicit translation theorem.
- Eliminating a semantic existential leaves the caller's goal at its original point. The witness fact has its own point index. A semantic `ladvance` may focus the event point only when an enclosing eventual goal or an explicit goal-transport theorem reconstructs the original conclusion.
- An ordinary ambient fact remains usable at its original point after opening a new scope. It is not silently copied to the new point. Show all point indices in the proof-mode view.

## 7. Transport is an opaque theorem interface

The minimal transport consumer accepts a proved implication between indexed judgments, possibly parameterized by relation evidence and a supported formula fragment. It must cover the conclusion as well as any facts a focus change promises to preserve. A source/target name or footprint annotation supplies no proof.

Reuse existing concrete certificates:

- TM `TruthCorr` and `Truth.truthAt_of_truthCorr` for global history correspondence with order-reindexed time; do not strengthen it to a bijection when its relational evidence suffices.
- `TruthIso` / `TruthAntiIso` and their existing transport theorems when those stronger structures are available.
- `TimeShift.timeShift_preserves_truth` in `TruthTransport.lean` for shifting history and time together. Merely replacing t by t+d in the same history is not this theorem.
- `PlusFormula.StateLocal`, `isPlusStateLocal_of_stateLocal` and `plusStateLocal_stab_iff`. Existing locality admits entire □/⊡ formulas even with arbitrary interiors; the recognizer must reuse that theorem-backed classification. Bare `F p` / `G p` are not transportable merely from equal present states.
- `HistMorphism.plus_invariance` for its actual same-temporal-order and pulled-back-valuation hypotheses. A TM `TruthCorr` is not automatically a Plus certificate: same-state alternatives need their own correspondence.

Cross-model transport pins valuations, time maps and history coverage. Native soundness at the target still needs the target frame certificate. Full component contracts and refinement libraries can consume these interfaces later; they are not designed here.

Time remains the frame's ordered abelian-group carrier. Explicit arithmetic delegation can use `abel` for additive equalities and `omega` for integer instances, while inequalities over abstract carriers use appropriate proved lemmas/tactics. No Nat/Int index or numerical bounded-temporal syntax is baked into the backend.

## 8. Milestones and acceptance

1. **Source and API inventory:** freeze baseline; classify equality/certificates; prototype a propositional native equivalence lift and semantic clause wrapper. No new global attribute framework.
2. **Native checked rewriting:** propositional, □, G/H, U/S, stability congruence, scoped nested paths, explicit simp set and transactional budgets. A TM-plus argument containing stability must work without copying the rewriter.
3. **Temporal rule interface:** asymmetric U/S fold/unfold, exact dual views, closed reflection, generic native rule application, documented proof debt for broader induction/progress. Keep current scripts compatible.
4. **Semantic core:** shared clauses, point-indexed facts, modal/temporal witnesses, Until intervals, explicit one-way soundness use.
5. **Transport and compositional use:** locality, existing TM correspondences, supported Plus morphisms, goal-safe advance. Demonstrate opaque theorem application across two certified steps without unfolding providers.

Use three small positive stories: (a) the same nested rewrite at native TM and Plus goals with explicit scoped equivalence; (b) a strict Until branch proof and a past mirror with Base-vs-ZTime obligations visible; (c) a semantic eventuality composition retaining G facts, plus same-state transport of a certified local fact. Keep one compact rejection matrix: unscoped modal rewrite, incomplete scope chain, implicit Γ mutation, TR with unchanged open context, dense discrete-unfolding, rank without occurrence evidence, model mismatch, state-equality transport of a bare future fact, and a semantic fact supplied to native `lexact`.

Measure touched-module elaboration, generated term size with opaque providers, rewrite attempts and maximum path depth. Benchmark each mechanism once after it works, not every syntax edit. Source/import/README/count gates are run for the eventual code PR; this design document itself needs only source audit and documentation checks.

## 9. Known open obligations

The exact native congruence theorem family and minimal scope-demand composition still need proof prototypes. Stable derived-operator occurrence views need a parser/normalizer prototype because existing fold normalization is ambiguous. Native general well-founded progress is not promised. Plus transport under time reindexing may need a new theorem beyond the existing same-order morphism. The user-facing `using rule` grammar and goal/fact path syntax should be confirmed with two minimal elaborator prototypes before freezing names. Scores should deduct for these unprototyped pieces without mistaking them for existing support.
