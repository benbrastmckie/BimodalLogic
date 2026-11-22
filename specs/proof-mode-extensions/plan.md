# Proof-mode extensions: checked rewriting, temporal rules, pointed semantics

**Design proposal, 19 November 2026.** Joint revision of independent designs by Codex and
Claude Opus 5.5. The [review record](review.md) preserves the mutual grades, objections and
dispositions. This document specifies future work; proposed interfaces and theorem obligations
are not implemented features.

Baseline: BimodalLogic `81ae7a6c09807630b5000992a8bb5f689e051fa6`, after PR #6;
Lean `leanprover/lean4:v4.33.0-rc1`. The existing
[usage guide](../../docs/user-guide/derivation-proof-mode.md) describes what is implemented.

## 1. Scope and decisions

Extend the public TM/TM⁺ proof mode in three areas:

1. Position-aware rewriting and predictable, bounded simplification.
2. Compositional Until/Since rules, exact duals, reflection, induction and progress interfaces.
3. A separate pointed-truth backend with witnesses and certified fact/goal transport.

The governing principle is **small checked transformations of opaque guarantees**. Inspect
formula syntax and theorem types; consume provider proofs through their statements. A large
provider proof must not be unfolded to decide whether its assumptions were really needed.

Keep these boundaries:

- Native tactics produce `DerivationTree` or `PlusDerivationTree` data.
- Semantic tactics produce Lean proofs of the existing truth relations.
- Soundness is an explicit native-to-semantic adapter. Model-specific truth supplies no reverse
  adapter. Completeness-based extraction and extraction from `Nonempty` are not construction
  strategies for this proof mode.
- Every frame condition, context change and transport premise remains evidence in the proof.
- Explicit `using [...]` remains the recommended capture style.
- General duration carriers remain supported through the frame. No physical clock, metric
  language, Veil DSL, private Logos fragment, or full component-contract library is added here.

### Source reuse, before adding abstractions

| Existing source | Reuse |
| --- | --- |
| [Derivation](../../FormalSystem/ProofSystem/Derivation.lean), [Plus derivation](../../FormalSystem/PlusLanguage/Derivation.lean) | Type-valued judgments, weakening, closed necessitation/reflection |
| [Native rule helpers](../../FormalSystem/Theorems/ProofMode/README.md) | Cut, substitution, temporal consequence/bind, conditional Next rules, invariance |
| [Generalized necessitation](../../FormalSystem/Theorems/GeneralizedNecessitation.lean) | Contextual K rules; no necessitation of open assumptions |
| [Plus schema transfer](../../FormalSystem/PlusLanguage/Substitution.lean) | `PlusDerivationTree.ofTMSubst` at arbitrary Plus arguments |
| [TemporalDerived](../../FormalSystem/Theorems/TemporalDerived.lean) | G/H distribution, temporal 4, U/S monotonicity, progress ingredients |
| [DiscreteUnfolding](../../FormalSystem/Theorems/DiscreteUnfolding.lean) | Asymmetric forward/converse unfolding and one-step rules |
| [Normalization](../../FormalSystem/Automation/Normalization.lean) | Genuine formula equalities and an audited, partly ambiguous folding view |
| [TruthClauses](../../FormalSystem/Semantics/TruthClauses.lean) | `TruthEnv`, individual operator clauses and shared derived-operator lemmas |
| [TM truth](../../FormalSystem/Semantics/Truth.lean), [Plus truth](../../FormalSystem/PlusLanguage/PlusTruth.lean) | Existing instances, strict interval clauses, Plus shift/state/box invariance |
| [TruthTransport](../../FormalSystem/Semantics/TruthTransport.lean) | `TruthCorr`, `TruthIso`, `TruthAntiIso`, their transport theorems and TM time shift |
| [HistoryMorphism](../../FormalSystem/Semantics/HistoryMorphism.lean) | `HistMorphism.plus_invariance` under its actual lifting/valuation hypotheses |
| [PlusStateLocal](../../FormalSystem/PlusLanguage/PlusStateLocal.lean) | Existing syntactic recognizer and semantic locality certificates |
| [TM reversal](../../FormalSystem/Semantics/Reversal.lean), [Plus reversal](../../FormalSystem/PlusLanguage/PlusReversal.lean) | `truthAt_rev`, `plusTruthAt_rev` |
| [FrameClassValidity](../../FormalSystem/Semantics/FrameClassValidity.lean) | `fc.Sat F`, including regularity at Base; `FrameClass.Sat.rev` |
| [TM soundness](../../FormalSystem/Metalogic/Soundness.lean), [Plus soundness](../../FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean) | `soundness_in`, `Conservativity.plus_soundness_in` consume trees directly |

Proof-theoretic basis: §§3.2–3.3 and relevant semantic/transport results of
[The Construction of Possible Worlds](https://benbrastmckie.com/publications/possible_worlds.pdf),
checked against the native formalization. The audited PDF SHA256 is
`38fd887e0c2711a873206df24dd57e6be9929a824def8c7b7fdb4a60418f07d9`.
Formalization-native extension results must be attributed to their source, not to the paper.

## 2. Shared architecture and trust boundaries

Use a small sum of native and semantic goal views. The parser, formula-position representation,
rule indexing, budgets and diagnostics may be shared. Their proof builders remain distinct.
Do not replace the existing languages, models, or clause API with a universal new framework.

```text
Native:    DerivationTree fc Γ A              -- Type-valued data
           PlusDerivationTree fc Γ A

Semantic:  TruthEnv.T M τ t e A                -- Prop; existing instances
           TruthAt M τ t A / PlusTruthAt ...  -- accepted surface heads
```

The semantic view retains actual expressions for the language, frame, model, history, time and
inert environment. It recognizes known heads before unfolding a truth recursor. It never
identifies two contexts by their printed names. TM/TM⁺ use `PUnit` environments internally;
environment-changing operators are outside this extension.

Existing tactic names can dispatch by the unique typed judgment. A failed native match does
not try semantic reasoning as a fallback. Ordinary Lean tactics remain available throughout;
there is no no-op enter/exit marker. Native `lstart` retains its actual assumption-naming job.

Pure native rules stay at layer 2; pure semantic clause/transport wrappers at layer 1;
elaborators and soundness adapters at layer 3. In particular, a module under `Semantics/`
must not import `soundness_in`. The current layer/import gates remain in force.
The generic semantic rule module imports only the needed clause interfaces. Concrete Plus
wrappers use audited individual semantic modules, not the `PlusLanguage` aggregator, whose
imports mix layers. A new Plus-specific semantic file needs its per-file layer registration.

At native proof-mode roots, use the existing `assert_not_exists` mechanism to guard named
completeness declarations such as `FormalSystem.Metalogic.completeness_base` and its Dense,
ZTime and RTime counterparts. This checks the dependency boundary cheaply; construction audits
still check the producer route. Do not assert the absence of the already-present core axiom
`Classical.choice`. Semantic frontend imports may include soundness, never completeness extraction.

Replace runtime namespace concatenation for primitive constructors with checked declaration
names in the adapters. Validate registered theorem telescopes and result judgment kinds at
registration. Names identify evidence; metadata never establishes an inference rule. A signature
change should fail registration or compilation, not wait for a rare interactive invocation.

## 3. Checked rewriting

### 3.1 Evidence kinds and direction

There are three distinct inputs:

| Evidence | Meaning | Permitted use |
| --- | --- | --- |
| Lean equality `A = B` | Formula data are equal | Cast through any constructor |
| Native implication/equivalence | Derivations of `A → B`, optionally also `B → A`, at a specified Γ/fc | Reconstruct a derivation with checked congruence and scope |
| Semantic implication/equivalence | Truth implication at a specified point, or a quantified family of points | Reconstruct semantic truth under the matching point/range certificate |

Logical equivalence is not equality of formula ASTs. A point-specific Lean `Iff` is not a native
derivation. Definitional normalization and logical rewriting therefore have separate handlers.

For a selected occurrence `A ↦ B`, direction depends on **both** target role and implication
polarity. An implication antecedent flips polarity; the other primitive positions are monotone.

| Target | Positive occurrence needs | Negative occurrence needs |
| --- | --- | --- |
| Derived fact | `A → B` | `B → A` |
| Goal | `B → A` | `A → B` |

Goal rewriting creates the new subgoal and proves the old goal from it. Fact rewriting proves
the new fact from the old one. Equivalence supplies both directions; an implication-only rule
can be used only when its direction fits this table. `←` reverses A/B before planning.

### 3.2 A typed scope-demand kernel

Each primitive position supplies a pure transfer theorem and closed demand monotonicity.
Schematic native interface, to be proved before the frontend:

```text
Step (L : Type) (J : FrameClass → List L → L → Type) (imp : L → L → L) fc:
  wrap   : L → L
  demand : L → L
  flips  : Bool
  transfer : ∀ A B, J fc []
    (demand(A ⟶ B) ⟶ (if flips then (wrap B ⟶ wrap A) else (wrap A ⟶ wrap B)))
  demandMono : ∀ P Q, J fc [] (P ⟶ Q) → J fc [] (demand P ⟶ demand Q)
```

Here `⟶` abbreviates `imp`; J is the existing TM or Plus native tree family. This is a local
adapter signature, not a replacement calculus. Ordinary `→` is a Lean function arrow.
In particular, `transfer` proves a **closed formula**,
not merely a metalevel function from one open derivation to another.
Each concrete position is bound to its actual formula constructor. Arbitrary `wrap` metadata
cannot change which occurrence the user selected.

| Primitive/derived position | Initial demand | Source for transfer |
| --- | --- | --- |
| Implication right / left | Identity / identity with polarity flip | Closed propositional combinators |
| □ body | □ | Modal K |
| ⊡ body | ⊡ | Plus stability K |
| G/H body | G/H | `gDistribution` / `hDistribution` |
| Until guard / event | G | `untilMonoGuard` / `untilMonoEvent` |
| Since guard / event | H | `sinceMonoGuard` / `sinceMonoEvent` |
| Next event | X or G | Closed `nextK`, or `untilMonoEvent` with guard ⊥ |
| Previous event | Y or H | Closed `prevK`, or `sinceMonoEvent` with guard ⊥ |

For path `[s₁,…,sₙ]`, demands compose outermost first:
`D₁(D₂(…Dₙ(P)…))`. The required leaf arrow is chosen by target role and total polarity.
Compose the closed transfer proofs using `demandMono` and implication transitivity; weaken the
result to Γ and apply the supplied scoped premise. This produces a whole-formula native
implication. The rule itself, not a scope tag, justifies reconstruction.

The composite closed theorem has shape:

```text
pathTransfer p A B : J fc []
  (W_p(A ⟶ B) ⟶
    (if odd p then (plug p B ⟶ plug p A) else (plug p A ⟶ plug p B)))
```

Here W is the composed demand. A scoped equivalence `W(A↔B)` supplies either arrow by
lifting the appropriate closed conjunction projection through W's composed `demandMono`.
The per-language adapter supplies the ordinary closed propositional combinators as well as
`Step`: reuse TM `Propositional.lceImp`/`rceImp` and their existing Plus proof-mode counterparts.
P0 pins the chosen iff expansion to that conjunction of implications. These projections do
not follow merely from the `imp` field of `Step`.

**Plus composition is stepwise.** Transfer each closed TM step schema with `ofTMSubst` at its
arbitrary Plus arguments; supply the ⊡ step natively; compose in Plus. Do not transfer an entire
path containing ⊡ through `ofTM`, and do not duplicate the path compiler for Plus.
`ofTMSubst` transfers formula theorems, not the metalevel `demandMono` function. Construct Plus
demand monotonicity from its own closed necessitation and the transferred K schema, using the
existing `liftContext` capability pattern. For an X demand at Base, necessitate P→Q with G,
then apply the transferred `untilMonoEvent` at guard ⊥; use H/S for Y. This proves XP→XQ
without asserting X(P→Q). P0 pins each atomic-schema substitution against the intended Plus
wrap/demand by a checked definitional equality or an explicit normalization lemma.

### 3.3 Evidence discharge and occurrence views

The initial resolver uses a fixed, bounded order:

1. Exact matching scoped evidence, with existing checked weakening/frame lifting.
2. A genuinely closed native rule, lifted through the required closed necessitation rules.
   For a closed rewrite through X/Y, choose the G/H transfer route: conditional congruence at
   Base does not require existence of an adjacent time.
3. Explicit proved scope conversions in the finite table below. Each adapter has its own theorem;
   there is no unrestricted search for compositions of adapters.
4. Report the unmet demand. Further scope conversions are added only with a consumer and proof.

| Available evidence | Supported demand | Justification |
| --- | --- | --- |
| W P | The same W P | Exact match, including mixed words |
| □P | G P, H P, or ⊡P | `temporalFutureDerived`, `temporalPastDerived`, `box_stab` |
| □P / GP / HP | □ᵏP / GᵏP / HᵏP, respectively, k≥1 | `modal4`, `gTransitivity`, `hTransitivity`, bounded iteration |
| XP / YP | The identical X/Y demand | Exact conditional evidence; no X/Y necessitation at Base |

The first release does not chain □→G with G iteration or infer □→GH / □→⊡G. Supply the exact
mixed evidence, a closed rule, or an explicit conversion theorem. This deliberate supported
subset keeps the resolver predictable; it is not a claim that those mixed implications are false.

An optional general boxed-demand-word theorem is a proof obligation, not a prerequisite for
every first-release rewrite. Native promotion of an arbitrary syntactically state-local Plus
formula to stability likewise needs a native theorem; semantic locality does not supply it.

Inside an existing modal/temporal introduction body, evidence must already have been captured
with `using [...]` and have that body's Γ. The rewriter does not recover an outer fact by
unfolding its provider. Diagnostics show the actual missing context/demand; scope-trail
metadata may suggest a capture but cannot certify one.

Paths initially refer to primitive positions or explicitly registered derived views. A view
must prove its primitive expansion and pin argument roles. Existing folding is ambiguous, so
pretty-printing is not an occurrence oracle. Wrappers that duplicate an argument, such as the
guard of `weakUntil`, require a proved operator-level congruence recipe; otherwise users select
a primitive occurrence after explicit unfolding. A trace lists the expanded occurrences.

### 3.4 Frontend contract

Proposed syntax (parser spelling is finalized after the proof prototypes):

```text
lrewrite hEq (path := [boxBody, futureBody, orLeft])
lrewrite ← hEq at h as h'
lsimp only [closedRule, scopedFact] (maxSteps := 64)
```

For `at h as h'`, Γ is unchanged; h' is a new derived fact. An assumption introduced by
`lstart` and an opaque provider with the same judgment type behave identically. Replacing
members of Γ is a separate context-correspondence feature and is deferred.

An explicit rewrite fails atomically on an ambiguous path, missing scope, wrong direction, or
missing frame proof. An optional explicit `obligations := expose` mode may generate the missing
native/semantic evidence goal before the rewritten goal. The assignment must reconstruct the
original goal from both obligations. Automated simp never invents or silently assumes one.
The step/unfold family follows the existing `lstep` convention and exposes missing frame
premises; `lrewrite` does so only with `obligations := expose`. Both reject a concrete incompatible
frame tag. These defaults apply uniformly to the new command forms.

## 4. Bounded simplification

Start with an explicit `only` set and per-tactic planning state; do not introduce a global
contextual-certificate cache. Use a deterministic traversal and selected-rule order. Report
the applied theorem, path, evidence route, frame obligation and output in an opt-in trace.

Three distinct mechanisms keep the normalizer predictable:

1. **View preparation:** selected definitional expansions, with a fixed direction. Folding for
   display is separate and never alternates with unfolding during a simp run.
2. **Logical reduction:** apply only a justified directional rewrite whose actual instantiated
   target decreases primitive constructor count after view preparation. Equivalences have a
   registered orientation; decrease guards that orientation rather than choosing one per instance.
   Fresh-atom samples do not prove schematic
   decrease; inspect the concrete before/after formulas or require a parametric decrease proof.
3. **Explicit expansion:** U/S unfolding, dualization and other growing transformations are
   single requested operations, outside the default decreasing pass.

Seed the logical pass with audited closed Boolean equivalences and selected modal
equivalences (`boxConjIff`, `diamondDisjIff`, `s5DiamondBox`). Directed temporal rules are tagged
as implications: `futureCollapse` is `FFA → FA`, not an equivalence; `GGA → GA` needs Dense
evidence through `LinearityDerived.density`. Goal role can reverse which direction is usable.
Transfer only the required TM seed schemas to Plus; stability seeds need their own proofs.

Simp uses a frame-gated rule only when the gate is explicitly provided, already available, or
decidable on the concrete tag. Otherwise it skips it; it does not accumulate speculative
ZTime/Dense obligations while searching. Explicit `lrewrite` can expose such an obligation.

Bound node visits, matching attempts, scope-discharge attempts, nesting depth and successful
steps. Use Lean's normal heartbeat/unification controls too; a step count is not a wall-clock
bound. Reject repeated states. Exhaustion rolls back the entire tactic and reports the counters.
Fuel bounds execution and strict decrease prevents reduction cycles; the repeated-state check
is defensive, not permission to accept a growing rule.
No change is a documented failure, not a successful no-op marker under `--wfail`.
Non-decreasing rules are skipped; a run that therefore makes no change fails without mutation.
Budget exhaustion and detected repeated states instead abort and roll back the whole run.

Term construction calls opaque rule constants and references provider values. It does not
normalize derivation values or splice their bodies. Any later cache must be justified by a
measured consumer and keyed by the actual context, profile, frame, point and local fvar lifetime;
formula text alone is insufficient. An optional trace-to-explicit-script printer follows stable
path syntax; it is not required to land the first rewriter.

## 5. Richer temporal interfaces

### 5.1 Native rules and semantic witnesses remain different

A native U/S proof contains no Lean time witness to extract. Native introduction/use tactics
apply source-calculus rules and checked admissible transformations. Semantic tactics expose the
actual quantified time and interval from the truth clauses.

| Operation | Native route | Semantic route |
| --- | --- | --- |
| Introduce U/S | Proved rule, persistent guard plus eventual event, or fold rule | Supply event time, strict ordering, event truth, open-interval guard |
| Use U/S | Monotonicity/composition or a proved case theorem | Eliminate the witness, ordering, event and interval facts |
| Discrete unfolding | ZTime forward rule; Base converse | A supplied covering-point argument or appropriate frame evidence |
| Next/Previous | Existing conditional rules; closed introduction keeps its existence gate | Supply/eliminate a covering-time witness |
| Duals/weak variants | Literal definitions and native conversion proofs | Existing/derived truth-clause equivalences with exact endpoints |

Preserve current `luntil guard/event`, `lsince guard/event`, `linvariant future/past` and
two-guarantee `lprogress` forms. Add a uniform `using rule` route for native derivation-producing
theorems and the corresponding semantic theorem applications. The rule's type controls premises.

### 5.2 Unfolding and duals

With guard g and event e:

```text
U g e  →  X e ∨ X(g ∧ U g e)    ZTime: unfoldForward e g
X e ∨ X(g ∧ U g e)  →  U g e    Base:  unfoldBackward e g
S g e  →  Y e ∨ Y(g ∧ S g e)    ZTime: unfoldBackwardSince e g
Y e ∨ Y(g ∧ S g e)  →  S g e    Base:  new closed reflection of unfoldBackward
```

Do not infer a rule's direction from the existing misleading Since helper name. The new Base
Since fold earns its place through the frontend consumer. Transfer each schema to arbitrary
Plus arguments and add only the table forms actually used.

Proposed `luntil unfold h as hEvent hContinue` consumes the ZTime inequality, exposes both
one-step branches, and requires the common conclusion in both. It does not strip X in either
branch. `luntil fold` reduces a goal to the Base disjunction; `lsince` mirrors these forms.
For an explicitly requested unfolding, a missing frame proof is a real user goal; at a concrete
incompatible tag, reject immediately. The automatic simp policy remains skip-on-missing-gate.

All U/S clauses are strict and guard-first/event-second. TM's `release`, `trigger`, `weakUntil`
and `weakSince` wrappers put the event first: for example `weakUntil e g = U g e ∨ G g`.
Their literal definitions, including the documented `before` swap, are authoritative. These
wrapper names are absent from Plus at the baseline; either add certified derived aliases there
or advertise only an explicit primitive view until they land. An inclusive-U interface needs the
proved translation `e ∨ (g ∧ U g e)`; it cannot reuse strict rules by changing notation.

### 5.3 Reflection and progress

Closed native reflection uses the existing constructor. A contextual form needs a proved
`Derivation fc Γ A → Derivation fc (map reflectTime Γ) (reflectTime A)` transformation.
Plus's existing `liftContext` provides the construction pattern; TM needs its counterpart.
The goal-direction wrapper also proves involution for the mapped context and conclusion.
Expose contextual reflection explicitly; never reflect the conclusion while keeping Γ silently.

Semantic reflection applies `truthAt_rev` / `plusTruthAt_rev`: frame/model, history, time and
formula all follow the actual theorem. `FrameClass.Sat.rev` transports any later soundness
obligation. A same-model shortcut requires an additional proved correspondence.

Native progress first gains consequence and finite-case composition through proved schemas.
Generic induction applies an already proved rule. Keep the strict current-step premise of
integer invariance: A, A→X A, and G(A→X A), with the past mirror. G alone omits now.

Well-founded semantic progress has a concrete proposed theorem. For a fixed history, an
invariant I, a rank into a well-founded relation ≺, and target predicate Q, require:

```text
∀ s, I s → ¬Q s → ∃ u, s < u ∧ I u ∧ (Q u ∨ rank u ≺ rank s)
```

Then I t implies `Q t ∨ ∃ u > t, Q u`. Strict eventuality additionally requires that Q is not
already true at t, or another premise guaranteeing a future occurrence. The displayed step is
an occurrence assumption: it asserts a later point exists. A rank that decreases only if a
step occurs proves no progress without that existence premise.
Instantiate Q by pointed truth when a formula-valued conclusion is wanted. A general Lean rank
is not silently encoded by a finite TM formula; a native counterpart waits for a genuine
derivation-producing schema.

## 6. Pointed semantic proof mode

### 6.1 Clause-directed operations

Pure semantic helpers use the existing individual `TruthClauses` capabilities, not the largest
bundle. Shared parser/command families dispatch to those helpers. Model-specific theorem
application uses theorem types without unfolding provider bodies. Raw Lean proofs remain usable.

- □ introduction chooses an arbitrary history at the same time; ⊡ adds current-state equality.
- G/H introduction chooses an arbitrary later/earlier time with its strict inequality.
- Possibility and F/P introduction supply a typed history/time witness and required evidence.
- U/S introduction and cases retain event time, direction, event truth and the guard on the
  strict open interval. The guard is not silently required at either endpoint.

A semantic existential elimination leaves the original goal at its original point. The
witness fact is at its own indexed point. Changing displayed focus does not change either type.

Semantic rewriting uses the same path/polarity planner, with a separate typed transfer kernel.
For fixed language/frame/model, let p retain its history, time and environment, and write
`At p A` for its truth judgment. A demand transforms predicates on these points:

```text
D□ Q p  := ∀ σ, Q (σ, p.time, p.env)
D⊡ Q p  := ∀ σ, p.history.state p.time = σ.state p.time → Q (σ, p.time, p.env)
DG Q p  := ∀ s, p.time < s → Q (p.history, s, p.env)   -- DH reverses <
QAB p   := At p A → At p B
```

Each position proves that `D QAB p` implies the correctly oriented implication between
`At p (wrap A)` and `At p (wrap B)`, and proves D monotone under pointwise implication.
Compose these predicate transformers outermost first, using the same polarity table as §3.
Until/Since positions initially use DG/DH; Next/Previous may use those conservative demands or
a separately proved covering-point adapter. Primitive clauses justify each transfer; a
point-specific Iff discharges only an identity demand. A quantified family or explicit
transport/persistence certificate must justify a larger range. No point is silently generalized.
P4 must prototype a mixed world/time path before the semantic rewriter is exposed.

Add the missing generic Next/Previous characterizations without a new recursor:

```text
T M τ t e (U ⊥ A) ↔ ∃ s, t ⋖ s ∧ T M τ s e A
T M τ t e (S ⊥ A) ↔ ∃ s, s ⋖ t ∧ T M τ s e A
```

Here ⋖ is covering, not an assumed successor function. These hold without a universal ZTime
assumption. Existence must be supplied or generated through a proved appropriate frame theorem;
elimination of an existing Next fact already supplies it. Pin the generic definitions against
`Formula.next/prev` and their Plus counterparts. Arithmetic side goals remain ordinary Lean
goals; abstract durations do not acquire `omega` or integer induction automatically.

### 6.2 Explicit soundness seam

Proposed `luse_derivation d using hFrame, hΓ` invokes the existing context-form soundness theorem:

```text
d      : DerivationTree fc Γ A
hFrame : fc.Sat F
hΓ     : ∀ B, B ∈ Γ → TruthAt M τ t B
-------------------------------------
         TruthAt M τ t A
```

Use `Conservativity.plus_soundness_in` for Plus. Γ may be abstract; accept its proof environment
without enumerating it. Preserve all model/history/time indices. At Base, `hFrame` includes
regularity, not `True`. Language translation, if needed, is explicit before this application.
No semantic proof is accepted as input to native `lexact`/`lapply`.

### 6.3 Fact transport and goal transport

The smallest reusable transport interface is a theorem between fully indexed judgments:

```text
Fact:  R p q → At p A → At q B
Goal:  R p q → At q B → At p A
```

`At` is explanatory notation for the existing truth relation, with all model/frame/environment
indices retained. A certificate may provide one direction or both. A one-way fact certificate
cannot move a goal; an Iff supplies the matching direction. Cross-language or cross-model
certificates also specify formula translation and its supported fragment.

Reuse these actual routes:

| Certificate/theorem | Direction | What it supports |
| --- | --- | --- |
| `Truth.truthAt_of_truthCorr` | Iff | TM with global history coverage, atomic agreement and order-reindexed time |
| `Truth.truthAt_of_truthIso` / `truthAt_of_truthAntiIso` | Iff | Existing bijective/order-reversing cases; do not require a bijection when `TruthCorr` suffices |
| `TimeShift.timeShift_preserves_truth` | Iff | TM: shift history and evaluation time together |
| `plusTruthAt_timeShift` | Iff | Existing Plus shift theorem; no new duplicate |
| `Truth.box_const`, `FormalSystem.PlusLanguage.box_global` | Iff | Whole boxed formulas across histories/times in the same model |
| `isPlusStateLocal_of_stateLocal`, `plusStateLocal_stab_iff` | Iff under the locality certificate | Same-state/same-time locality, or the separate φ/⊡φ correspondence |
| `stab_state_only` | Iff | Whole Plus stability formulas at equal states, including different times |
| `HistMorphism.plus_invariance` | Iff | Plus under its same-order, history-lifting and pulled-back-valuation assumptions |

All audited routes in this table are bidirectional under their hypotheses. The one-way rejection
test uses a supplied preservation theorem of type `R p q → At p A → At q B`; its inverse must
not be fabricated. Formula-locality recognition alone is not such a preservation theorem.
Use the clause-proved `At p A → At p (A ∨ B)` at the same point as the concrete one-way
fixture, with ordinary disjunction introduction. Its reverse fails at A=⊥, B=⊤. The provider
is proved from the existing clauses, never an axiom or `sorry` introduced for testing.

The existing locality predicate admits whole □/⊡ formulas with arbitrary interiors. Reuse its
proved classification; a bare F p/G p does not transport from present-state equality alone.
For TM, use the existing TM-to-Plus truth correspondence or a small proved adapter; a new
duplicated locality calculus is not required. A TM `TruthCorr` does not by itself establish the
same-state-alternative correspondence needed by Plus stability.

### 6.4 Advancing while retaining guarantees

Distinguish three operations:

1. Cases on an eventuality: acquire a localized witness; leave the goal where it was.
2. Eventuality bind: focus a witness while a proved bind rule reconstructs the original eventual
   conclusion. This is the semantic counterpart of existing native `ladvance`.
3. An arbitrary point/model change: require a goal-direction certificate as well as certificates
   for any facts the operation promises to keep.

Proposed `keeping [...]` explicitly selects persistent facts. For a future step, native G4 can
turn Γ⊢G P into Γ⊢GG P before the existing scope helper unwraps it; the body retains G P.
The semantic counterpart proves G P at the later point by transitivity of `<`. H mirrors this
for past steps. Other facts require their own registered preservation theorem. An arbitrary
point-local fact remains at the old point.

The required native Base example is `[F A, G(A→F B), G(B→F C)] ⊢ F C`, with opaque providers
for the two G-guarantees and a semantic twin at the same initial point. After reaching A at a
strictly later point, the second guarantee must still be G-scoped for reaching B later. Merely
obtaining B→F C at the first witness is insufficient. Either compose the providers first through
the existing progress rule or retain the second guarantee through an explicit persistence step.
The refusal case is `[A, G(A→F B)] ⊢ F B`: strict G omits the current point, so it cannot handle
A now without another premise. No implementation may repair that failure by adding temporal T.

## 7. Proposed implementation map and milestones

Reuse existing folders. Proposed files below are allocation sketches, not existing APIs:

| Responsibility | Placement |
| --- | --- |
| Native positional transfer/demand composition | `Theorems/ProofMode/Congruence.lean` |
| Temporal fold/converse/reflection/progress adapters | Existing native temporal/discrete rule modules, split when needed |
| Generic semantic clauses, covering-time and persistence lemmas | `Semantics/ProofModeRules.lean`, with only lower semantic imports |
| Native-to-semantic soundness adapter | `Metalogic/ProofModeSoundness.lean` |
| Goal/formula views and checked rule declarations | Existing `Automation/ProofMode/Meta.lean` plus small registry module |
| Planning/replay and bounded normalization | `Automation/ProofMode/Rewriting.lean` / `Simplification.lean` |
| Pointed semantic tactic adapter | `Automation/ProofMode/Semantic.lean` |

New code must update relevant READMEs, aggregators, generated root and inventories. Add a new
directory only when there is an actual split that needs it. Do not duplicate TM/Plus planners.

| Phase | Deliverable | Go/no-go criterion |
| --- | --- | --- |
| P0 | Exact source/rule inventory and small theorem prototypes | Type-check signed path composition, mixed Plus path and its substitution pin, Base conditional Next, Base Since fold, and a pointed soundness application; verify every transfer-table row's closed source before frontend machinery |
| P1 | Pure native transfer kernel and validated adapters | Goal/fact direction and nested demands match the table; arbitrary Plus arguments work by stepwise transfer; no semantic/completeness dependency enters the pure native layer |
| P2 | `lrewrite` and bounded `lsimp only` | Scoped successes, precise atomic failures, actual-instance decrease, frame skips and budget rollback pass |
| P3 | Temporal fold/use/duals/reflection and generic rule application | Strictness, operand roles, Base/ZTime asymmetry, reflected contexts and current-step premises are explicit; existing scripts stay compatible |
| P4 | Shared-clause semantic frontend and one-way soundness | Witnesses retain indices; U/S intervals and covering evidence are correct; no model-specific truth is accepted natively |
| P5 | Transport, `keeping`, compositional examples and semantic progress | One-way fact/goal certificates are distinguished; two opaque providers compose across repeated advances; rank rules retain occurrence and endpoint premises |

The source inventory lists each entry's actual declaration, language, judgment, frame premise,
retained/discharged assumptions, operand convention and required new theorem. Entries distinguish
formula theorems from functions on derivations and confirm each import's per-file layer;
transport entries record Iff versus one-way direction. Native
state-local promotion and general Plus time-reindexing remain separate optional proof obligations;
existing concrete shift/reversal/morphism routes are enough to land P4–P5.

## 8. Compact acceptance suite

Extend one shared test file with mechanism-driven fixtures, aiming at roughly 12–16 short new
proofs across the phases, not that many per milestone. Reuse regular integer/real translation
frames from existing constructors for semantic counterexamples. Each scenario fixes its formula,
frame class and outcome mode; test refusal by `fail_if_success`, and inspect explicit obligations
where the documented interface exposes them. Add a case only for a distinct mechanism or failure.

| Scenario | Required success | Required rejection/obligation |
| --- | --- | --- |
| R1: nested rewriting | Γ⊢□G(A→B) transports a positive fact □G(A∨C) to □G(B∨C), with the reverse direction for goal rewriting | Current-only A↔B cannot rewrite under G/□; missing scopes fail atomically |
| R2: Plus reuse | A path through □, ⊡ and G works with arguments containing ⊡ | A whole-path TM embedding cannot substitute for the native stability step |
| R3: conditional next | Closed A↔B rewrites G X A at Base through the G route; X(A→B) maps an existing X A at Base | Closed Next necessitation or integer unfolding keeps its existence/frame obligation |
| R4: direction and normalization | FFA→FA acts in the supported fact/goal direction; Boolean equivalences reduce normally | The false converse on ℤ and Dense-only GGA→GA at Base are refused; growing rules are skipped, no-change fails, and actual budget exhaustion rolls back |
| T1: strict U/S | Future/past fold/cases preserve a distinct guard and event and join both branches | Dense-time forward discrete unfolding is rejected; present truth alone is no future witness |
| T2: reflection | Closed reflection works; contextual reflection maps Γ as proved | [G p]⊢G p cannot become [G p]⊢H p by reflecting only the conclusion |
| S1: pointed truth/transport | Existing soundness, shift, and a certified local-fact transfer work | Missing Sat/context evidence, a mismatched model, or state-equality transport of bare F p cannot be silently accepted |
| S2: composition/progress | [F A, G(A→F B), G(B→F C)]⊢F C at Base and its semantic twin retain the second G-guarantee; rank progress yields its inclusive conclusion | [A,G(A→F B)]⊢F B is refused; keeping local facts, descent without occurrence, and fact-only goal transport need missing evidence |

Registration/type checks cover checked declaration names. The suite demonstrates logical
behavior rather than mirroring the implementation or exhaustively multiplying all profiles.

Run touched-module checks during implementation, then the appropriate milestone/integration
checks with caches. The standard counter generator needs a built library; account for that once
instead of repeatedly rebuilding it. This design-only change requires no Lean library build.

Prototype measurements record matching attempts, path depth, generated expression size and
touched-module elaboration. The acceptance criterion is structural first: provider bodies remain
constant/local references and are never inspected or copied into the generated expression.
Use one representative nested proof to set a reproducible performance baseline before freezing
budgets; no unmeasured O(n) runtime or arbitrary millisecond target is promised.

## 9. Remaining proof/prototype risks

P0 must confirm demand composition and polarity, the exact Plus transfer telescope, and derived
view matching before the tactic interface is frozen. U/S dual wrappers need an explicit Plus
availability decision. Contextual reflection requires a real mapped-context theorem. Covering-time
and semantic progress lemmas need normal proofs, not semantic-to-native extraction. All of
these are implementation dependencies, not claims of already supplied logical power.

Unsupported derived views, scope conversions, frame classes or transports fail with the missing
requirement. They do not silently fall back to stronger automation. Full contracts/views, stored
indices, counterfactuals, metric syntax and timed Veil integration can consume these interfaces in
separate work without changing their judgments or weakening their proof obligations.
