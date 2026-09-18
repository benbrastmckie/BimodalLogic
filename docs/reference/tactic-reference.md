# Bimodal Tactic Reference

Reference for custom tactics in the Bimodal TM logic library.

## Available Tactics

| Tactic | Purpose | Call sites in the library |
|--------|---------|---------------------------|
| `propDecide` | Close a goal whose imp/bot skeleton is a propositional tautology | load-bearing |
| `deduction`, `undischarge` | The deduction theorem in tactic form | 0 (interactive use) |
| `modal_search` | Bounded proof search for derivability goals | 3, all in `Examples/` |
| `modal_t` | Apply the modal T axiom | 0 |
| `apply_axiom` | Apply a specific axiom schema | 0 |
| `assumption_search` | Find a matching assumption in context | 0 |

The six EF-game tactics in `FormalSystem/Metalogic/WeakCanonical/EFGameTactics.lean` are the
most-used custom tactics in the repository (68 call sites between them) and are documented at
their declarations rather than here.

**`modal_search` is the pedagogical entry point, not library infrastructure.** All three of its
call sites are in `Examples/`; nothing in `Metalogic/`, `Theorems/` or `Semantics/` is proved
by it. Use it to show that a formula is derivable — not to build a proof on.

**Three tactics were removed** after measurement: `tm_auto`, `temporal_search` and
`propositional_search`. Each was behaviourally identical to `modal_search`: they differed only
in `SearchConfig` weight fields (`axiomWeight`, `assumptionWeight`, `mpWeight`, `modalKWeight`,
`temporalKWeight`) that `searchProof` never read, so the presets built from them had no effect
at all. The three docstrings claiming otherwise — "prioritizes temporal K rules over modal K
rules", "disables modal K and temporal K rules" — were false. Replace any occurrence with
`modal_search`; the behaviour is unchanged, and the whole test suite was migrated with no
change in outcome.

## Tactic Details

### `modal_t`

Applies the modal T axiom (`□φ → φ`).

**Usage**:
```lean
example (φ : Formula) : ⊢ φ.box.imp φ := by
  modal_t
```

**When to use**: When goal matches `□φ → φ` pattern.

### `apply_axiom`

Applies a specific axiom schema by name.

**Usage**:
```lean
-- Apply modal T
example (φ : Formula) : ⊢ φ.box.imp φ := by
  apply_axiom MT φ

-- Apply modal K
example (φ ψ : Formula) : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box) := by
  apply_axiom MK φ ψ

-- Apply modal 4
example (φ : Formula) : ⊢ φ.box.imp φ.box.box := by
  apply_axiom M4 φ
```

**Axiom Names**:
- `MT` - Modal T: `□φ → φ`
- `M4` - Modal 4: `□φ → □□φ`
- `MB` - Modal B: `φ → □◇φ`
- `MK` - Modal K: `□(φ → ψ) → (□φ → □ψ)`
- `T4` - Temporal 4: `△φ → △△φ`
- `TK` - Temporal K: `△(φ → ψ) → (△φ → △ψ)`
- `TA` - Temporal A: `△φ → ▽△φ`
- `TL` - Temporal L: `▽△φ → φ`

### `modal_search`

Automated proof search for modal formulas.

**Usage**:
```lean
example (p q : Formula) : ⊢ p.box.imp p := by
  modal_search

-- With depth limit
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search 5
```

**Named parameters**: `depth` (default 10) and `visitLimit` (default 1000) are the only two.
`visitLimit` bounds total node visits through an `IO.Ref` counter, independently of `depth`, so
a pathological goal terminates promptly rather than exploring a shallow but enormous tree. Any
other parameter name is silently ignored.

**Limitations**:
- Depth- and visit-bounded: a failure means "not found within the bounds", never "not derivable"
- Its axiom matcher covers 27 of the tree's 29 schemata; the two Layer-9 Reynolds Dedekind
  axioms (`prior_U_gap`, `prior_S_gap`, `sep`) are outside its list
- Cannot discharge goals needing forward modus ponens from a context hypothesis

### `propDecide`

Closes any derivability goal whose imp/bot skeleton is a propositional tautology, by
reflection. Schematic in the reification environment, so it does not care which atoms appear.
This is the one tactic in `Automation/Tactics/` that library proofs actually depend on.

### `deduction`, `deduction n`, `undischarge`

The deduction theorem in tactic form: `deduction` turns `Γ ⊢[fc] A → B` into
`(A :: Γ) ⊢[fc] B`, `deduction n` iterates it, and `undischarge h` closes the goal from the
other direction.

Because `deductionTheorem` is `noncomputable`, any `def` or `example` whose proof term these
produce must be marked `noncomputable`. For `Prop`-valued derivability use
`Derivable.deduction` instead, which carries no such marker; for the derivation tree itself use
the `deductionTheorem` term form. Those two cover every use in the library, and
`Tactics/Deduction.lean`'s docstring records why the tactic form is not adopted inside
`Metalogic/Core/DeductionTheorem.lean` (it would be circular: every candidate site is one of
the cases the theorem itself dispatches to).

## Tactic Strategies

### Strategy 1: Direct Axiom Application

For simple goals, use `apply_axiom`:

```lean
example (p : Formula) : ⊢ p.box.imp p := by apply_axiom MT p
example (p : Formula) : ⊢ p.box.imp p.box.box := by apply_axiom M4 p
```

### Strategy 2: Automation First

Try automation, fall back to manual:

```lean
example (p : Formula) : ⊢ p.box.imp p := by
  first
  | modal_search
  | apply_axiom MT p
```

This pattern is for `Examples/`. In library code, prove the goal directly: `modal_search` is
depth- and visit-bounded, and a proof that depends on it silently depends on those bounds.

### Strategy 3: Build-Up Approach

For complex proofs, build intermediate steps:

```lean
example (p q : Formula) (h1 : ⊢ p.imp q) : ⊢ p.box.imp q.box := by
  -- Use modal K + modus ponens
  have mk := modal_k p q
  have h2 := DerivationTree.necessitation h1
  exact DerivationTree.modusPonens mk h2
```

## Aesop Integration (retired)

There is **no** Aesop rule set for TM derivability goals, and adding one is not a small job.

A `TMLogic` rule set existed and was retired to
`FormalSystem/Boneyard/RetiredTactics/`. Two facts killed it. First, Aesop's proof
reconstruction does not work over `DerivationTree`, which is `Type`-valued rather than
`Prop`-valued — that is why the search tactics build proof terms in `TacticM` via `mkAppM`
instead. Second, because the rules lived in a *dedicated* rule set rather than Aesop's default
one, reaching them required writing `aesop (rule_sets := [TMLogic])` explicitly, and no call
site in the library or the test suite ever did. The rule set had zero consumers of any kind.

Use `modal_search` for derivability goals. Plain `aesop` remains available and useful for the
ordinary `Prop`-valued side conditions that arise inside metalogic proofs.

## Troubleshooting

### "tactic failed" with `modal_search`

1. Check if goal is actually provable
2. Try increasing depth limit
3. Fall back to manual proof

### Timeout with automation

1. Use bounded search
2. Break proof into steps
3. Apply axioms manually

### "unexpected token" errors

1. Check import statements
2. Verify tactic is available in current scope

## See Also

- [Axiom Reference](axiom-reference.md) - Axiom schemas used by tactics
- [Proof Patterns](../user-guide/proof-patterns.md) - Manual proof strategies
- [Automation README](../../FormalSystem/Automation/README.md) - Automation implementation
