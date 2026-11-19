# Pointed semantic proof mode

```lean
import FormalSystem.Automation.ProofMode.Semantic
```

Commands produce Lean proofs of `TruthAt M τ t A`, `PlusTruthAt M τ t A`, or the existing
`TruthEnv.T M τ t e A`. The judgment retains its actual language, dictionary, frame, model,
history, time and environment. Ordinary Lean tactics remain available. The
[derivation backend](derivation-proof-mode.md) builds native trees separately.

## Clauses and scopes

`lexact`, `lapply`, `lintro`, `lhave`, `lsplit`, `lleft`, `lright`, and `lcases` reuse statements
or apply the corresponding truth clauses. `lapply` exposes proof premises; data parameters
remain inferable from those premises. Native trees require the explicit soundness adapter below.

| Command | Indexed obligations |
| --- | --- |
| `lmodal_intro necessity/settled using […] as σ …` | Arbitrary history; settledness adds current-state equality |
| `lmodal_witness σ` | Possibility witness, and same-state evidence for settled possibility |
| `lmodal_use h [as name]` | □/⊡ instance; retain the required state equality |
| `lmodal_cases h using […] as σ …` | Alternative and its facts; original goal stays in place |
| `ltemporal_intro future/past using […] as s hs …` | Arbitrary strict later/earlier time |
| `ltemporal_witness s` | F/P witness and direction; X/Y requires a cover |
| `ltemporal_use h [at s] [as name]` | Scoped mapping, or explicit time instance with order/cover evidence |
| `ltemporal_cases h using […] as s hs event …` | Localized witness; original goal stays in place |
| `ladvance h using […] keeping […] as s hs event …` | Eventual body; bind reconstructs the original eventual goal |
| `luntil/lsince witness s` | Direction, event, then guard on the strict open interval |
| `luntil/lsince cases h as s order event guard` | The same witness/interval data for elimination |
| `luntil/lsince guard/event using h` | Operand mapping under G/H |
| `lstep future/past using […] as s hcov …` | First X/Y fact supplies a cover; other facts use cover uniqueness |
| `lprogress using rule`, `linvariant using rule`, `linduction using rule` | Apply a supplied theorem with all its premises |

Names list history/time, its evidence, the event (when present), ordinary captures, then kept
facts. Omitted `using` captures nothing in this backend. `keeping` on temporal introduction,
cases, advance and step carries G/H facts through proved persistence; it never carries a bare
current fact. G/H omit the present. Until/Since are guard-first, event-second, with guards
excluding both endpoints. Next/Previous needs covering evidence, rather than a universal ZTime
assumption. General duration carriers receive no integer induction or arithmetic solver implicitly.

Two opaque guarantees compose across two advances:

```lean
open FormalSystem.Syntax FormalSystem.Semantics

example {F : TaskFrame} (A B C : Formula) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (fa : TruthAt M τ t A.someFuture)
    (ab : TruthAt M τ t (A.imp B.someFuture).allFuture)
    (bc : TruthAt M τ t (B.imp C.someFuture).allFuture) :
    TruthAt M τ t C.someFuture := by
  ladvance fa using [ab] keeping [bc] as u hu a ab bc
  lhave fb : B.someFuture
  · lapply ab; lexact a
  ladvance fb using [bc] as v hv b bc
  lapply bc
  lexact b
```

## Rewriting and bounded normalization

`lrewrite h` and `lrewrite ← h` use the [same paths and polarity discipline](derivation-proof-mode.md#checked-rewriting-and-simplification)
as native rewriting, with semantic certificates. These commands select the backend from the
main goal; target facts use that backend too. For mixed proofs, run the transformation inside
a `have` subproof whose goal matches the fact’s judgment.
Use `(path := […])` for ambiguous occurrences and `at fact as newFact` for forward rewriting.
Lean formula equality is distinct from a semantic implication/Iff.

Evidence may be a same-point Lean implication/Iff, an object-language scoped implication or
converse-pair equivalence, or a quantified family over demanded histories/times/typed points.
A local Iff cannot enter □/G. `(obligations := expose)` makes a missing indexed demand a real
goal; it does not generalize the original proof. Every side condition and point remains explicit.

`lsimp only […] (maxSteps := n)` considers only listed rules, in fixed order, with strict
concrete formula-size decrease and finite matching/traversal/scope budgets. No change fails;
exhaustion restores the entire state. Registration validates the statement and records only its
orientation. Generic semantic seeds in `Semantics.ProofModeRules` are `doubleNegation_iff`,
`conjunctionSelf_iff`, and one-way `futureCollapse_at`; specialize `L := Formula` or
`L := PlusFormula` explicitly when supplying a generic seed. Each matching attempt elaborates
its listed rule with fresh metavariables; finite matching budgets bound these attempts.

`Semantics.ProofModeIntervals` supplies exact release/trigger and weak Until/Since truth views
in both languages, with event first and strict intervals. Its inclusive U/S views separately
retain the present-time guard. The semantic aggregator imports these lemmas.

## Transport and soundness

| Command | Direction |
| --- | --- |
| `ltransport h using certificate [with relationEvidence] as h'` | Forward fact transport |
| `ltransport using certificate [with relationEvidence]` | Backward goal reduction |
| `ltime_reflect` | Goal at converse model/history, negative time and reflected formula |
| `ltime_reflect using h [as name]` | Reflected fact at that converse point |
| `luse_derivation d using hFrame, hΓ` | Native tree to truth at the exact goal point |

`FactTransport` works for facts; `GoalTransport` for goals; `IffTransport` for both. Kernel
certificates require `with` evidence fixing their two points. Lean functions apply in their
proved direction; Iffs supply both directions. `←` reverses only an Iff. A forward certificate
is never inverted. A point relation's `.intro` or a typed term states its points; unconstrained
models, points and formulas are not chosen from local data.

Factories in `Semantics.ProofModeTransport` reuse truth correspondence/isomorphism, shifts,
converse models, box invariance, Plus state locality/stability and history morphisms. Their
valuation, lifting and state hypotheses remain premises. State locality can recognize whole
□/⊡ formulas with arbitrary interiors, but refuses bare F/G. A whole stability formula can
move across times at equal states; its interior cannot be extracted without its own rule.
Staying in the same model during time reflection needs an explicit certificate.

Soundness requires `hFrame : fc.Sat F` and `hΓ : ∀ A ∈ Γ, TruthAt M τ t A` (Plus analogue).
Γ may be abstract. Base satisfaction includes regularity. The adapter uses canonical dictionaries;
other interpretations need explicit correspondence. Semantic truth never constructs a native tree.

`rank_progress_truth` gives truth now or strictly eventually. Its strict version requires
failure now. Both retain an invariant, a well-founded rank relation and actual later occurrence
of each progress event. A merely conditional rank decrease supplies no occurrence proof.

The compact [extension examples](../../Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean)
exercise the public commands and refusal paths. Counterfactuals, metric syntax and Veil integration
remain separate work.
