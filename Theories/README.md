# Theories

This directory contains the formal logic theories implemented in Lean 4.

## Structure

| Directory | Description |
|-----------|-------------|
| `Bimodal/` | TM bimodal logic combining S5 modal and linear temporal operators |
| `Logos/` | Recursive semantics with hyperintensional foundation and layered extensions |

## Bimodal Theory

The Bimodal library provides:
- Syntax for modal (Box/Diamond) and temporal (Future/Past) operators
- Axiomatic proof system with derivation trees
- Task frame semantics with world histories
- Soundness and completeness proofs
- Proof automation tactics

See `Bimodal/README.md` for details.

## Logos Theory

The Logos library provides:
- Constitutive semantics foundation (mereological state space)
- Explanatory extension layer (task-based intensional semantics)
- Planned extensions: Epistemic, Normative, Spatial, Agential

The theory layers are organized under `Logos/SubTheories/`:
- `Foundation/` - Constitutive frame with bilateral propositions
- `Explanatory/` - Task relation and temporal structure
- `Epistemic/` - Belief and knowledge operators (stub)
- `Normative/` - Deontic and preference operators (stub)

See `Logos/README.md` for details.

## Adding a New Theory

1. Create `Theories/NewTheory/` directory
2. Create `Theories/NewTheory.lean` as the root module
3. Add `lean_lib NewTheory` to `lakefile.lean`:
   ```lean
   lean_lib NewTheory where
     srcDir := "Theories"
     roots := #[`NewTheory]
     leanOptions := theoryLeanOptions
   ```
4. Create corresponding test directory `Tests/NewTheoryTest/`
