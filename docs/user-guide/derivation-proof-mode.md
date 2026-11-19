# Derivation proof mode

```lean
import FormalSystem.Automation.ProofMode
```

The commands construct `DerivationTree fc Γ A` or `PlusDerivationTree fc Γ A` values.
They apply constructors and proved derivation transformations; no model, semantic validity,
or completeness argument replaces a derivation. Ordinary Lean tactics remain available.

## Named assertions and composition

| Command | Effect |
| --- | --- |
| `lstart h₁ … hₙ` | Name the explicit object assumptions; omitted names become `h1`, `h2`, … |
| `lintro h` | Prove an implication under its antecedent, then discharge it by deduction |
| `lexact d` | Reuse a derivation with checked context inclusion and Base-frame lifting |
| `lapply d` | Apply an opaque statement, generating its Lean parameters and object premises |
| `lhave h : A [:= d]` | Prove an intermediate assertion and continue through checked cut |
| `lsplit`, `lcases d as h₁ h₂` | Introduce conjunction; project conjunction or prove both disjunction branches |
| `lleft`, `lright` | Select a disjunction alternative |

Composition reuses a statement's guarantees with its source assumptions, parameters and frame
class. A disjunction join requires both branches to establish the same conclusion. Proof bodies
are not inspected. Supply parameters explicitly when they cannot be inferred from the goal.

```lean
open FormalSystem.Syntax FormalSystem.ProofSystem

example (A B C : Formula) : [A.or B, A.imp C, B.imp C] ⊢ C := by
  lstart hAB hAC hBC
  lcases hAB as hA hB
  · lapply hAC
    lexact hA
  · lapply hBC
    lexact hB
```

## Modal and temporal scopes

| Command | Rule and body |
| --- | --- |
| `lmodal_intro necessity` / `settled` | Generalized □/⊡ K; body uses the selected guarantees without their outer operator |
| `lmodal_intro possibility` / `settled_possibility` | Derive ◇A / dual-⊡ A from a current A using modal T |
| `lmodal_use d [as h]` | Apply □/⊡ T; close the goal or name the result |
| `lmodal_cases d … as h …` | Prove a possible conclusion under an alternative, carrying □ or ⊡ guarantees |
| `ltemporal_intro future` / `past` | Generalized strict G/H K |
| `ltemporal_use d` | Apply a G/H-scoped implication to a matching G/H/F/P premise |
| `ltemporal_cases d … as h …` | Prove F/P B under the event A by establishing B in the body |
| `ladvance d … as h …` | The same scope, with an F/P B body; close through temporal bind |
| `lprogress using [d₁, d₂]` | Compose G(A → F B), G(B → F C), or their past mirrors |
| `luntil guard\|event using d` | Map the chosen Until operand through a G-scoped implication |
| `lsince guard\|event using d` | Map the chosen Since operand through an H-scoped implication |
| `lstep future` / `past` | Introduce Next/Previous through a checked shifted-context rule |
| `linvariant future` / `past` | Integer-time invariance: initialization, current step, persistent G/H step |

Universal introductions, `lstep`, and case commands accept `using [d₁, …]`. Omission selects
matching explicit assumptions; `using []` selects none. Introductions may name body assumptions
with `as h₁ …`; cases require names for the event first, then selected assumptions.
For abstract contexts, supply guarantees explicitly. The source contexts of outer Lean locals
remain in their types: `lexact` and `lapply` reject unavailable assumptions inside a new scope.

Prefer explicit `using [...]` in reusable proofs: it records exactly what a scope captures.
Omitting it is convenient interactively, but adding a matching modal assumption to the outer
context then changes the selected body assumptions.

```lean
example (A B : Formula) : [A.allFuture, B.someFuture] ⊢ (A.and B).someFuture := by
  lstart hA hB
  ltemporal_cases hB using [hA] as hB hA
  lsplit
  · lexact hA
  · lexact hB
```

G/H are strict: they do not supply A at the present. F/P cases retain an eventual conclusion;
they do not turn eventual assertions into current facts. Until/Since arguments are guard first,
event second. Next/Previous scope introduction and invariance require `ZTime ≤ fc`; the tactics
solve the reflexive ZTime instance or expose the certificate as an ordinary Lean goal.
The legacy `lstep` and `linvariant future/past` forms retain that explicit abstract gate even
when a local certificate is available; new rule routes reuse exact local certificates.
Invariance requires A, A → X A, and G(A → X A), with the H/Y mirror for the past.

## Temporal composition

Until/Since remain strict, with guard first and event second.

| Command | Obligations |
| --- | --- |
| `luntil intro`, `lsince intro` | G/H guard and F/P event |
| `luntil fold`, `lsince fold` | `X e ∨ X(g ∧ U g e)`, or the Y/S mirror; Base-valid |
| `luntil unfold h as he hc`, `lsince unfold h as he hc` | Integer-time certificate, then both one-step branches proving the same conclusion |
| `lprogress cases` | A persistent leads-to guarantee for each disjunct |
| `lprogress consequence using h` | Source strengthening and persistent target weakening |
| `lprogress trans using h` | A persistent second step; the first may be current or persistent |
| `luntil using rule`, `lsince using rule` | Apply the supplied native rule's premises |
| `lprogress using rule`, `linvariant using rule`, `linduction using rule` | Apply a proved rule; no unbounded search |
| `linduction future` / `past` | Integer-time Z1 backward induction, retaining its eventuality premise |
| `ltime_reflect [as h …]` | Reflect the whole context and conclusion |
| `ltime_reflect using d [as h]` | Reflect a fact with its own context, or apply a reflection rule |
| `ltemporal_dual [←] view [at h as h']` | Expand/fold all exact occurrences of one derived view |
| `ltemporal_dual [←] using theorem [at h as h']` | Use a checked equivalence or formula equality |

Dual views are `release`, `trigger`, `weakUntil`, `weakSince`, `strongRelease`, `strongTrigger`,
`before`, `after`, `inclusiveUntil`, and `inclusiveSince`, in both languages. The pre-existing
release/weak/strong wrappers are event-first; inclusive views are guard-first:
`inclusiveUntil g e = e ∨ (g ∧ U g e)`. Use an expansion equality with `lrewrite (path := …)`
for one occurrence. A literal fold does not choose missing formula parameters.

`keeping [...]` on temporal introduction, cases, advance and step retains G/H guarantees
through temporal 4. Names list the event (if any), ordinary `using` bodies, then kept facts.
Bare current facts need a separate preservation rule. For example, two advances compose opaque
providers without losing the second guarantee at the first witness:

```lean
example (A B C : Formula)
    (ab : [A.someFuture] ⊢ (A.imp B.someFuture).allFuture)
    (bc : [A.someFuture] ⊢ (B.imp C.someFuture).allFuture) :
    [A.someFuture] ⊢ C.someFuture := by
  lstart hA
  ladvance hA using [ab] keeping [bc] as hA hAB hBC
  lhave hB : B.someFuture
  · lapply hAB; lexact hA
  ladvance hB using [hBC] as hB hBC
  lapply hBC
  lexact hB
```

New integer-time rules reuse exact local certificates, decide concrete tags, reject false tags,
and expose unresolved abstract conditions. A decreasing measure alone is not a progress rule:
its designated events must also occur. Semantic rank reasoning is a separate interface.

## Checked rewriting and simplification

`lrewrite rule` accepts a native implication, a native equivalence encoded as the conjunction
of converse implications, or a Lean equality of formula data. Parenthesize applied rules:
`lrewrite (lemma A B)`. A logical rewrite constructs a derivation through every enclosing
constructor; a formula equality uses checked equality casts.

| Command | Effect |
| --- | --- |
| `lrewrite d` / `lrewrite ← d` | Rewrite the unique applicable occurrence, reconstructing the old goal |
| `lrewrite d (path := [boxBody, futureBody, orLeft])` | Select one explicit occurrence |
| `lrewrite d at h as h'` | Derive a new fact; retain the original object context Γ |
| `lrewrite d (obligations := expose)` | Expose missing scoped evidence or theorem premises as real goals |
| `lsimp only [d₁, ← d₂]` | Deterministic decreasing normalization using only listed rules |
| `lsimp only [d] (maxSteps := 32) at h as h'` | Normalize a fact within an explicit step budget |

For positive occurrences, fact rewriting needs A→B while goal rewriting needs B→A.
An implication antecedent flips that direction. Equivalences supply both arrows; implications
remain one-way. Ambiguous logical rewrites report candidate paths instead of choosing silently.

Paths name actual arguments: `impLeft`/`impRight`, `andLeft`/`andRight`, `orLeft`/`orRight`,
`negBody`, `boxBody`, `stabilityBody`, `possibilityBody`, `settledPossibilityBody`,
`futureBody`/`pastBody`, `futureEvent`/`pastEvent`, `nextBody`/`prevBody`, and
`untilGuard`/`untilEvent`/`sinceGuard`/`sinceEvent`. Stability paths require TM⁺.
For other derived operators, unfold to these views explicitly; duplicated operands are not
silently identified with a single occurrence.

A local A↔B cannot rewrite beneath □ or G. The corresponding scoped guarantee, a closed rule,
or a checked scope conversion is required. Supported conversions are exact scope words;
□→G/H/⊡; and bounded homogeneous □/G/H iteration. Arbitrary mixed-word conversions are explicit.
Closed rewrites beneath Next/Previous use G/H monotonicity at Base, so they require no invented
successor. Rewrite inside an introduction body only with guarantees captured by `using [...]`.

`lsimp` checks the instantiated primitive constructor count before applying each logical
reduction. Registered orientations are fixed; `←` reverses that orientation (or the declaration
orientation for an unregistered rule). Non-decreasing or unavailable frame-gated rules are skipped. No change fails;
budget exhaustion restores the entire original state. Matching attempts, node visits, depth
and scope positions have finite limits in addition to Lean's heartbeat controls.
Set `trace.proofMode.rewrite` or `trace.proofMode.simp` for paths, demands and counters.

Library authors can use `register_lrewrite declaration [reverse]` to validate a closed schema's
telescope and set its simp orientation. Registration never adds it to an `only` list. Boolean
seeds are `Theorems.ProofMode.doubleNegationIff` and `conjunctionSelfIff`; modal seeds include
`Theorems.ModalS5.boxConjIff`, `diamondDisjIff`, and `s5DiamondBox`, with corresponding
`PlusLanguage.ProofMode` guarantees for arbitrary Plus arguments.

```lean
example (Γ : Context) (A B C : Formula)
    (mapping : Γ ⊢ (A.imp B).allFuture.box)
    (provider : Γ ⊢ (A.or C).allFuture.box) : Γ ⊢ (B.or C).allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped
```

The compact [extension examples](../../Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean)
also exercise mixed TM⁺ scopes, conditional Next, equality casts, frame gates and rollback.

The separate [pointed semantic backend](semantic-proof-mode.md) reuses these command families
for model-specific truth, witnesses, certified transport and explicit soundness.

## Foundations and scope

Pure rules live in `FormalSystem/Theorems/ProofMode/`; elaborators live in
`FormalSystem/Automation/ProofMode/`. TM⁺ rules operate on arbitrary `PlusFormula` values,
including nested stability. TM theorem-schema transfer uses `ofTMSubst`, not an embedding that
would restrict arguments to the TM sublanguage.

The basis is the TM proof theory in §§3.2–3.3 of Brast-McKie's
[The Construction of Possible Worlds](https://benbrastmckie.com/publications/possible_worlds.pdf),
and this repository's pinned native calculi. Contextual rules use deduction, distribution and
closed necessitation; temporal bind/progress use derived transitivity. Integer-time invariance
uses UZ first-failure reasoning, enrichment and Since unfolding. TM⁺ uses its formalized
stability calculus. Every rule retains its source frame restrictions.

This implementation covers the public TM/TM⁺ fragment. Counterfactuals, stored-index languages,
metric syntax, semantic duration reasoning and Veil integration remain separate work.
