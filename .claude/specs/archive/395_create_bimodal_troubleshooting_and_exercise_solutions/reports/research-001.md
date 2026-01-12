# Research Report: Task #395

**Task**: Create Bimodal troubleshooting guide and exercise solutions
**Date**: 2026-01-12
**Focus**: Documentation structure, common errors, and exercises needing solutions

## Summary

Researched the Bimodal library documentation structure, identified 9 exercises in EXAMPLES.md section 7 that need solutions with hints, catalogued common error patterns from source code analysis, and reviewed existing troubleshooting content in QUICKSTART.md. The documentation structure is well-organized with clear navigation; the troubleshooting guide should follow similar patterns.

## Findings

### 1. Documentation Structure

The Bimodal documentation is organized in `Theories/Bimodal/docs/`:

```
docs/
├── user-guide/
│   ├── QUICKSTART.md       # Entry point, has basic troubleshooting section
│   ├── PROOF_PATTERNS.md   # Common proof strategies
│   ├── EXAMPLES.md         # 7 sections with exercises in section 7
│   ├── TUTORIAL.md         # Detailed tutorial
│   ├── ARCHITECTURE.md     # Technical architecture
│   └── TACTIC_DEVELOPMENT.md
├── reference/
│   ├── AXIOM_REFERENCE.md  # Complete axiom schemas
│   ├── TACTIC_REFERENCE.md # Custom tactics
│   └── OPERATORS.md        # Operator reference
├── project-info/
│   ├── KNOWN_LIMITATIONS.md # Existing limitations doc
│   └── IMPLEMENTATION_STATUS.md
└── research/               # Research documents
```

**QUICKSTART.md already has a minimal troubleshooting section** (lines 105-127) covering:
- "unknown identifier" → Check imports
- "type mismatch" → Use Formula type, not Prop
- "unsolved goals" → Check goal view

### 2. Exercises Requiring Solutions (EXAMPLES.md Section 7)

Nine exercises are listed in section 7 (lines 555-579), currently pointing to solution files without inline hints:

#### Basic Exercises (1-3)
1. `⊢ □(P → Q) → (□P → □Q)` (K axiom) - Direct axiom application
2. `[P, P → Q] ⊢ Q` using modus ponens - Basic MP
3. `⊢ □P → ◇P` from MT and MB - Composition

#### Intermediate Exercises (4-6)
4. `⊢ ◇◇P → ◇P` in S5 - Uses S5 collapse axiom
5. `[always P] ⊢ P` by extracting from conjunction - Conjunction elimination
6. `{□P, □Q}` entails `□(P ∧ Q)` - Modal K distribution

#### Advanced Exercises (7-9)
7. Perpetuity P1: `⊢ □P → always P` - Full perpetuity proof
8. `⊢ always □P ↔ □P` in TM - Bimodal interaction
9. Canonical model proof for specific formula - Advanced metalogic

**Current solution reference** (line 577-580): Points to `Logos/Examples/` modules

### 3. Common Error Patterns from Source Analysis

#### Import Errors
- **Missing namespace opens**: Users often forget `open Bimodal.Syntax` and `open Bimodal.ProofSystem`
- **Wrong import path**: `import Bimodal` vs `import Theories.Bimodal.Bimodal`
- **Missing dependencies**: Automation tactics require `import Bimodal.Automation`

#### Type Mismatch Errors
- **Formula vs Prop confusion**: Variables declared as `Prop` instead of `Formula`
- **DerivationTree vs Prop**: Goal type `⊢ φ` is `DerivationTree [] φ` (a Type), not Prop
- **Context list ordering**: `[p, q]` vs `[q, p]` affects assumption lookup
- **Derived operator expansion**: `diamond φ = φ.neg.box.neg` requires understanding

#### Proof Construction Errors
- **Wrong axiom application**: E.g., using `modal_t` when `modal_4` is needed
- **Missing weakening**: Need to add assumptions to context explicitly
- **Necessitation context**: `necessitation` only works on empty context `[]`
- **Temporal duality**: Only works on theorems (empty context)

#### Tactic Errors
- **aesop internal errors**: `tm_auto` has known issues (see KNOWN_LIMITATIONS.md)
- **modal_search depth**: Complex proofs need higher depth (default 10)
- **Tactic name confusion**: `modal_t` (axiom tactic) vs `Axiom.modal_t` (axiom constructor)

### 4. Existing Troubleshooting Content (KNOWN_LIMITATIONS.md)

Already documents 6 limitations:
1. Completeness proof incomplete (Tasks 132-135, 257)
2. ProofSearch build issues (aesop errors)
3. Example files have pedagogical sorries
4. Test suite has pending tests
5. Modal S4 theorems partial
6. No decidability procedures (Tasks 136-138, 261)

**Gap**: KNOWN_LIMITATIONS.md is about system limitations, not user errors

### 5. Key Types and APIs for Troubleshooting

#### Formula Construction
```lean
inductive Formula : Type where
  | atom : String → Formula      -- Propositional atom
  | bot : Formula                -- ⊥
  | imp : Formula → Formula → Formula  -- →
  | box : Formula → Formula      -- □
  | all_past : Formula → Formula -- H (always was)
  | all_future : Formula → Formula -- G (always will be)
```

#### DerivationTree Constructors
```lean
| axiom      -- Apply axiom schema
| assumption -- From context
| modus_ponens -- If Γ ⊢ φ→ψ and Γ ⊢ φ then Γ ⊢ ψ
| necessitation -- If ⊢ φ then ⊢ □φ (empty context only!)
| temporal_necessitation -- If ⊢ φ then ⊢ Gφ
| temporal_duality -- If ⊢ φ then ⊢ swap φ
| weakening -- Add assumptions
```

#### Common Axiom Patterns
- `modal_t`: `□φ → φ`
- `modal_4`: `□φ → □□φ`
- `modal_b`: `φ → □◇φ`
- `modal_k_dist`: `□(φ → ψ) → (□φ → □ψ)`
- `temp_4`: `Gφ → GGφ`
- `prop_k`: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- `prop_s`: `φ → (ψ → φ)`

## Recommendations

### TROUBLESHOOTING.md Structure

1. **Import and Setup Errors** (4-5 items)
   - Missing imports, namespace issues
   - Build failures, dependency issues

2. **Type Errors** (5-6 items)
   - Formula vs Prop confusion
   - Context type mismatches
   - Derived operator type issues

3. **Proof Construction Errors** (5-6 items)
   - Axiom selection guide
   - Necessitation context requirement
   - Weakening and assumption handling

4. **Tactic Errors** (4-5 items)
   - modal_search configuration
   - aesop/tm_auto workarounds
   - Depth limit issues

5. **Build and Performance** (3-4 items)
   - Slow compilation
   - Memory issues
   - Known build failures

### Exercise Solutions Format

For each exercise in EXAMPLES.md section 7:

```markdown
### Exercise N: [Title]

**Problem**: `⊢ formula`

**Hint 1**: [High-level approach]
**Hint 2**: [Specific axiom/tactic to use]

<details>
<summary>Solution</summary>

```lean
example ... := by
  -- Step-by-step proof
```

**Explanation**: [Why this works]
</details>
```

## References

- `Theories/Bimodal/docs/user-guide/EXAMPLES.md` - Exercise definitions
- `Theories/Bimodal/docs/user-guide/QUICKSTART.md` - Existing troubleshooting
- `Theories/Bimodal/docs/project-info/KNOWN_LIMITATIONS.md` - System limitations
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Axiom definitions
- `Theories/Bimodal/ProofSystem/Derivation.lean` - Derivation tree
- `Theories/Bimodal/Automation/Tactics.lean` - Custom tactics
- `Theories/Bimodal/Examples/ModalProofs.lean` - Modal proof examples with exercises

## Next Steps

1. Create `Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md` with ~20 error patterns
2. Add exercise solutions with progressive hints to `EXAMPLES.md` section 7
3. Cross-reference new troubleshooting guide from QUICKSTART.md and README.md
4. Ensure navigation links are consistent across documentation
