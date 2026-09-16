# Notation

Every notation this library declares, what it unfolds to, and where it is declared. Fifteen
`notation` declarations in live scope, and one deliberate absence.

The organising fact is an **asymmetry**: the turnstile side is tagged by frame class and the
double-turnstile side is not. That is a recorded decision, not an oversight, and the last
section says why.

## Derivability: the `⊢` family

Twelve declarations, all of the shape "context, turnstile, formula", all carrying the frame
class as a bracketed tag. `fc : FrameClass` ranges over `Base`, `Dense`, `ZTime` and `RTime`.

### TM, `Type`-valued (`FormalSystem/ProofSystem/Derivation.lean`)

| Notation | Unfolds to |
|---|---|
| `Γ ⊢[fc] φ` | `DerivationTree fc Γ φ` |
| `⊢[fc] φ` | `DerivationTree fc [] φ` |
| `Γ ⊢ φ` | `DerivationTree FrameClass.Base Γ φ` |
| `⊢ φ` | `DerivationTree FrameClass.Base [] φ` |

The untagged pair is the tagged pair at `.Base`, not a separate relation. `.Base` is the
weakest class, so it is the right default for a derivation that uses no class-specific axiom.

### TM, `Prop`-valued (`FormalSystem/ProofSystem/Derivable.lean`)

| Notation | Unfolds to |
|---|---|
| `Γ \|-![fc] p` | `Derivable fc Γ p` |
| `\|-![fc] p` | `Derivable fc [] p` |
| `Γ \|-! p` | `Derivable FrameClass.Base Γ p` |
| `\|-! p` | `Derivable FrameClass.Base [] p` |

`Derivable fc Γ φ` is `Nonempty (DerivationTree fc Γ φ)`: the same claim with the proof term
forgotten. Use it when only the fact of derivability matters. These four are spelled in ASCII
precisely so that they cannot be confused at a glance with the `Type`-valued four above — the
distinction is load-bearing, and a Unicode near-twin would hide it.

### L⁻, the tense-primitive language (`FormalSystem/Syntax/MinusLanguage/Derivation.lean`)

| Notation | Unfolds to |
|---|---|
| `Γ ⊢⁻[fc] φ` | `DerivationTree fc Γ φ` (over `MinusFormula`) |
| `⊢⁻[fc] φ` | `DerivationTree fc [] φ` (over `MinusFormula`) |

The `⁻` marker exists so these do not collide with TM's `⊢[fc]` in a file that has opened both
`FormalSystem.ProofSystem` and `FormalSystem.MinusLanguage`. The declaration's own docstring says
so; it is a disambiguator, not decoration.

### L⁺, the stability extension (`FormalSystem/Syntax/PlusLanguage/Derivation.lean`)

| Notation | Unfolds to |
|---|---|
| `Γ ⊢⁺[fc] φ` | `PlusDerivationTree fc Γ φ` |
| `⊢⁺[fc] φ` | `PlusDerivationTree fc [] φ` |

Same shape again, over `PlusFormula` and `PlusContext`. TM⁺ has no untagged abbreviation: its
whole point is that the class matters.

## Validity: the `⊨` family

Two declarations, in `FormalSystem/Semantics/Validity.lean`, and **neither carries a frame-class
tag**.

| Notation | Unfolds to |
|---|---|
| `Γ ⊨ φ` | `SemanticConsequence Γ φ` |
| `⊨ φ` | `Valid φ` |

Both are `.Base` instances of a tagged definition — `SemanticConsequence Γ φ` is
`SemanticConsequenceIn FrameClass.Base Γ φ`, and `Valid φ` is `ValidIn FrameClass.Base φ` — so
the tag exists in the *definitions* and simply has no notation.

The class-restricted forms are written out by name rather than by notation. There are seven
validity predicates and four consequence predicates:

* `ValidOnFrames`, `ValidIn`, `Valid`, `ValidDense`, `ValidZTime`, `ValidComplete`, `ValidRTime`
  (`Semantics/Validity.lean`).
* `SemanticConsequenceIn`, `SemanticConsequence`, and the `Dense`/`ZTime`/`RTime` siblings.
* `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`, `PlusValidDense`, `PlusValidZTime`,
  `PlusValidRTime` (`Semantics/PlusLanguage/PlusValidity.lean`) mirror the first list over `PlusFormula`.

`ValidComplete` is the one member that is not a `ValidIn` instance: it quantifies over
`TaskFrame.IsComplete` directly, and `Validity.lean` argues at length why it must not be
conflated with `ValidRTime`.

## Algebra

| Notation | Unfolds to | Declared in |
|---|---|---|
| `⟦φ⟧` | `toQuot φ` | `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean` |

The Lindenbaum class of a formula. This one is `scoped`: it is visible only after
`open FormalSystem.Metalogic.Algebraic`, because `⟦_⟧` is a bracket other quotients in a Lean
development will also want.

## The deliberate absence: no `⊨_F`

The paper writes frame validity as `⊨_F φ`. This library declares **no notation for it**, and
the omission is recorded rather than accidental.

`Semantics/Truth.lean` dropped a `TruthAt` notation because it conflicts, in the parser, with
the `⊨` validity notation. `Semantics/Validity.lean` then declined to add a subscripted variant
on the same ground: it would sit in the same parser neighbourhood and buy nothing. The ASCII
name is used instead, and dot-notation reads the way the paper does:

```lean
F.ValidOn φ        -- the paper's  ⊨_F φ
```

`valid_iff_forall_validOn` proves `ValidOn` is a specialisation of the one validity predicate,
quantified over frames — so this is one notion written two ways, not two competing notions.

### On adding a per-logic judgement tag

A `TM[...]`-style tag on the validity side has been considered and **declined**. The proposal
rests on the premise that the repository carries several unrelated `⊨`-shaped relations needing
to be told apart. It does not: the `⊨` family above is one definition (`ValidIn`) with its
frame-class argument fixed, plus a `Plus` mirror for a different formula type, and the
turnstile side already carries the tag wherever a tag can disambiguate. Adding a second tagging
scheme on the `⊨` side would reintroduce the parser conflict the two decisions above exist to
avoid, in exchange for a distinction the type checker already makes.

## Verifying this page

```bash
# every notation declaration in live scope
grep -rnE '^(scoped |local )?notation:?[0-9]* ' --include='*.lean' FormalSystem/ \
  | grep -v Boneyard | grep '=>'
```

The count is fifteen: twelve derivability, two validity, one scoped quotient bracket.

Both filters earn their place. Anchoring at column zero drops one docstring line that wraps
onto the word "notation"; requiring `=>` drops another, in `Semantics/TaskFrame.lean`, which
begins a sentence with it. Without them the census reports seventeen.

## Related documentation

- [ORGANISATION.md](ORGANISATION.md) — where each of these files sits in the layering
- [docs/reference/operators.md](docs/reference/operators.md) — the object-language operators
- [docs/reference/axiom-reference.md](docs/reference/axiom-reference.md) — the axiom schemata

## Tags

notation · syntax · derivability · validity · frame-class
