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
| `lexit` | Optional marker; ordinary Lean tactics are available throughout |

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
Invariance requires A, A → X A, and G(A → X A), with the H/Y mirror for the past.

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
