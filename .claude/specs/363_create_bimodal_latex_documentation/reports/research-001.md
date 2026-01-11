# Research Report: Task #363

**Task**: Create Bimodal LaTeX documentation
**Date**: 2026-01-11
**Focus**: Analyze Logos/LaTeX structure and Bimodal implementation to design documentation

## Summary

The Bimodal theory implements TM (Tense and Modality) logic in Lean 4, combining S5 modal logic with linear temporal logic. The documentation should mirror the structure of Logos/LaTeX but focus specifically on what has been implemented in the Bimodal/ directory, including syntax, proof system, semantics, metalogic (soundness), and key theorems.

## Findings

### 1. Logos/LaTeX Structure

The existing Logos/LaTeX documentation has this structure:

```
Logos/latex/
├── LogosReference.tex          # Main document
├── assets/
│   ├── logos-notation.sty      # Custom notation macros
│   ├── formatting.sty          # Document formatting
│   └── bib_style.bst           # Bibliography style
├── bibliography/
│   └── LogosReferences.bib     # References
├── subfiles/
│   ├── 00-Introduction.tex     # Overview and dependencies
│   ├── 01-ConstitutiveFoundation.tex  # State space semantics
│   ├── 02-CoreExtension-Syntax.tex    # Modal/temporal operators
│   ├── 03-CoreExtension-Semantics.tex # Truth conditions
│   ├── 04-CoreExtension-Axioms.tex    # Axiom system
│   ├── 05-Epistemic.tex        # (Stub)
│   ├── 06-Normative.tex        # (Stub)
│   ├── 07-Spatial.tex          # (Stub)
│   └── 08-Agential.tex         # (Stub)
└── build/                      # Build outputs
```

Key features:
- Uses `subfiles` package for modular organization
- Custom notation via `logos-notation.sty` (modal operators, temporal operators, etc.)
- Theorem environments for definitions, theorems, lemmas
- Cross-references to Lean implementation via `\leansrc{}{}` command

### 2. Bimodal Theory Implementation

The Bimodal/ directory implements:

#### 2.1 Syntax (`Bimodal/Syntax/`)
- **Formula.lean**: 6-constructor inductive type
  - `atom`: Propositional variables
  - `bot`: Bottom/falsum
  - `imp`: Implication (primitive)
  - `box`: Modal necessity (□)
  - `all_past`: Universal past (H)
  - `all_future`: Universal future (G)
- Derived operators: `neg`, `and`, `or`, `diamond` (◇), `always` (△), `sometimes` (▽), `some_past` (P), `some_future` (F)
- `swap_temporal`: Past/future duality transformation

#### 2.2 Proof System (`Bimodal/ProofSystem/`)
- **Axioms.lean**: 14 axiom schemata
  - Propositional: `prop_k`, `prop_s`, `ex_falso`, `peirce`
  - Modal S5: `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`
  - Temporal: `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`
  - Modal-Temporal: `modal_future`, `temp_future`
- **Derivation.lean**: 7 inference rules
  - `axiom`, `assumption`, `modus_ponens`
  - `necessitation`, `temporal_necessitation`
  - `temporal_duality`, `weakening`

#### 2.3 Semantics (`Bimodal/Semantics/`)
- **TaskFrame.lean**: Task frame structure with `WorldState`, `task_rel`, `nullity`, `compositionality`
- **TaskModel.lean**: Model with valuation function
- **WorldHistory.lean**: World histories with domain, state mapping, convexity, task respect
- **Truth.lean**: Truth conditions for all formula constructors
- **Validity.lean**: Semantic validity and consequence

#### 2.4 Metalogic (`Bimodal/Metalogic/`)
- **Soundness.lean**: COMPLETE soundness proof (Γ ⊢ φ → Γ ⊨ φ)
  - 14/14 axiom validity lemmas proven
  - 7/7 inference rule cases proven
- **Completeness.lean**: Infrastructure only (axiomatized)
  - Lindenbaum lemma, canonical model construction, truth lemma
  - Estimated 70-90 hours to complete
- **DeductionTheorem.lean**: Deduction theorem (Γ, φ ⊢ ψ → Γ ⊢ φ → ψ)

#### 2.5 Theorems (`Bimodal/Theorems/`)
- **Perpetuity.lean**: All 6 perpetuity principles P1-P6 PROVEN
  - P1: □φ → △φ (necessary implies always)
  - P2: ▽φ → ◇φ (sometimes implies possible)
  - P3: □φ → □△φ (necessity of perpetuity)
  - P4: ◇▽φ → ◇φ (possibility of occurrence)
  - P5: ◇▽φ → △◇φ (persistent possibility)
  - P6: ▽□φ → □△φ (occurrent necessity is perpetual)
- **Propositional.lean**: Propositional combinators (K, S, I), negation rules, DNE
- **Combinators.lean**: Basic proof combinators (identity, composition)
- **ModalS4.lean**: S4 theorems
- **ModalS5.lean**: S5 theorems (box_to_diamond, contraposition, etc.)
- **GeneralizedNecessitation.lean**: Generalized K rules

#### 2.6 Automation (`Bimodal/Automation/`)
- **Tactics.lean**: Custom tactics
- **AesopRules.lean**: Aesop integration
- **ProofSearch.lean**: Proof search (partially blocked)

#### 2.7 Examples (`Bimodal/Examples/`)
- ModalProofs, TemporalProofs, BimodalProofs
- Proof strategy examples

### 3. Documentation Scope

The Bimodal LaTeX documentation should cover:

1. **Introduction**: TM logic overview, relationship to Logos
2. **Syntax**: Formula type, primitive/derived operators, notation
3. **Proof System**: Axiom schemata, inference rules, derivation trees
4. **Semantics**: Task frames, models, world histories, truth conditions
5. **Metalogic**: Soundness theorem (proven), completeness (infrastructure)
6. **Key Theorems**: Perpetuity principles P1-P6, S5 modal theorems

### 4. Notation Requirements

Need a `bimodal-notation.sty` similar to `logos-notation.sty` with:

- Modal operators: □, ◇
- Temporal operators: H, G, P, F, △ (always), ▽ (sometimes)
- Task frame notation: task relation, world states
- Proof system: ⊢ (derives), ⊨ (satisfies)
- Meta-variables: φ, ψ, χ for formulas

## Recommendations

1. **Create parallel structure**: Mirror Logos/LaTeX organization but focused on Bimodal
2. **Adapt notation package**: Create `bimodal-notation.sty` based on `logos-notation.sty`
3. **Focus on implemented content**: Document what's actually proven, not placeholders
4. **Include implementation status**: Note which proofs are complete vs axiomatized
5. **Cross-reference Lean code**: Use `\leansrc` macro for all definitions

## Proposed Structure

```
Bimodal/latex/
├── BimodalReference.tex        # Main document
├── assets/
│   ├── bimodal-notation.sty    # TM-specific notation
│   └── formatting.sty          # Copy from Logos/LaTeX
├── bibliography/
│   └── BimodalReferences.bib   # References (can share with Logos)
└── subfiles/
    ├── 00-Introduction.tex     # TM logic overview
    ├── 01-Syntax.tex           # Formula type, operators
    ├── 02-ProofSystem.tex      # Axioms and rules
    ├── 03-Semantics.tex        # Task frames, models, truth
    ├── 04-Metalogic.tex        # Soundness and completeness
    └── 05-Theorems.tex         # Perpetuity principles, S5
```

## References

- Logos/latex/LogosReference.tex - Template for structure
- Bimodal/Bimodal.lean - Module documentation
- Bimodal/Theorems/Perpetuity.lean - Implementation status
- Bimodal/Metalogic/Soundness.lean - Proof completion status

## Next Steps

1. Create directory structure for Bimodal/latex/
2. Adapt notation package for TM-specific operators
3. Write main document with appropriate sections
4. Create subfiles documenting each component
5. Ensure cross-references to Lean implementation
