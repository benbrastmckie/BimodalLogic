# Bimodal Tactic Reference

Reference for custom tactics in the Bimodal TM logic library.

## Available Tactics

| Tactic | Purpose | Status |
|--------|---------|--------|
| `modal_t` | Apply modal T axiom | Working |
| `apply_axiom` | Apply specific axiom schema | Working |
| `modal_search` | Modal proof search | Partial |
| `temporal_search` | Temporal proof search | Partial |
| `tm_auto` | General TM automation | In Development |

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

**Limitations**:
- May timeout on complex formulas
- Depth-bounded search
- Known issues with certain formula patterns

### `temporal_search`

Automated proof search for temporal formulas.

**Usage**:
```lean
example (φ : Formula) : ⊢ φ.future.imp φ.future.future := by
  temporal_search
```

**Limitations**: Similar to `modal_search`.

### `tm_auto`

General automation for TM logic combining modal and temporal reasoning.

**Usage**:
```lean
example (φ : Formula) : ⊢ φ.box.imp φ := by
  tm_auto
```

**Status**: In development. May not work on all formulas.

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

### Strategy 3: Build-Up Approach

For complex proofs, build intermediate steps:

```lean
example (p q : Formula) (h1 : ⊢ p.imp q) : ⊢ p.box.imp q.box := by
  -- Use modal K + modus ponens
  have mk := modal_k p q
  have h2 := DerivationTree.necessitation h1
  exact DerivationTree.modusPonens mk h2
```

## Aesop Integration

Bimodal provides an Aesop rule set for automated reasoning:

```lean
import Bimodal.Automation.AesopRules

-- Use Aesop with TMLogic rules
example (p : Formula) : ⊢ p.box.imp p := by
  aesop (rule_sets := [TMLogic])
```

**Available Rules**:
- Modal axiom applications
- Modus ponens
- Necessitation (for theorems)
- Common propositional lemmas

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

- [Axiom Reference](AXIOM_REFERENCE.md) - Axiom schemas used by tactics
- [Proof Patterns](../user-guide/PROOF_PATTERNS.md) - Manual proof strategies
- [Automation README](../../Automation/README.md) - Automation implementation
