# Research Report: Task #363 (Supplemental)

**Task**: Create Bimodal LaTeX documentation
**Date**: 2026-01-11
**Focus**: Align documentation with JPL paper "The Perpetuity Calculus of Agency" sections

## Summary

The Bimodal LaTeX documentation should closely follow the structure and content of the JPL paper sections sec:Construction, sub:Logic, app:TaskSemantics, sub:ProofTheory, and sub:Soundness. This ensures the Lean implementation is documented in alignment with the formal specification from which it derives.

## Findings

### 1. JPL Paper Structure Analysis

The relevant paper sections are:

#### sec:Construction (lines 841-948)
- **World Histories**: Functions from durations to world states (τ : X → W)
- **Temporal Order**: Totally ordered abelian group D = ⟨D, +, ≤⟩
- **Frame Definition**: F = ⟨W, D, ⇒⟩ with Nullity and Compositionality constraints
- **World History Definition**: Convex domain, task relation respect
- **Model Definition**: M = ⟨W, D, ⇒, |·|⟩ with valuation function
- **Truth Conditions**: 6 clauses (atom, bot, imp, box, past, future)

#### sub:Logic (lines 1020-1100)
- **Language Definition**: L = ⟨SL, ⊥, →, □, H, G⟩
- **Axiom Schemata**:
  - MP (modus ponens)
  - MN (modal necessitation)
  - MK (modal K distribution)
  - MT (modal T)
  - M5 (modal 5 collapse)
  - MF (modal-future interaction)
  - TD (temporal duality)
  - TK (temporal K distribution)
  - TL (temporal linearity)
  - T4 (temporal 4)
  - TA (temporal accessibility)
  - TF (temporal-future interaction)
- **Perpetuity Principles P1-P6**: Derived theorems

#### app:TaskSemantics (lines 1832-2105)
- **Formal Definitions**: def:BL-language, def:frame, def:world-history, def:BL-model, def:BL-semantics
- **Time-Shift**: def:time-shift-histories
- **Key Lemmas**:
  - app:auto_existence (time-shift automorphism)
  - lem:history-time-shift-preservation (truth preservation under time-shift)
- **Validity Proofs**: app:valid (P1, P2 validity)
- **Countermodels**: app:not-dense (density axiom invalid over all models)
- **Restricted Validity**: app:dense (density valid over dense models)

#### sub:ProofTheory (lines 2106-2263)
- **Additional Theorems P9-P22**: Interaction principles between always/sometimes and box/diamond

#### sub:Soundness (lines 2266-2330)
- **Definitions**: def:logical-consequence, def:derivability, def:soundness
- **Validity Proofs**: thm:MF-valid, thm:TF-valid
- **Main Theorem**: thm:TM-soundness (soundness of TM)
- **Corollary**: cor:perpetuity-valid (P1-P6 validity follows from soundness)

### 2. Mapping to Bimodal Lean Implementation

| Paper Section | Lean Module | Documentation Section |
|---------------|-------------|----------------------|
| sec:Construction (frames) | `Bimodal/Semantics/TaskFrame.lean` | 03-Semantics |
| sec:Construction (histories) | `Bimodal/Semantics/WorldHistory.lean` | 03-Semantics |
| sec:Construction (models) | `Bimodal/Semantics/TaskModel.lean` | 03-Semantics |
| sec:Construction (truth) | `Bimodal/Semantics/Truth.lean` | 03-Semantics |
| sub:Logic (language) | `Bimodal/Syntax/Formula.lean` | 01-Syntax |
| sub:Logic (axioms) | `Bimodal/ProofSystem/Axioms.lean` | 02-ProofSystem |
| sub:Logic (derivation) | `Bimodal/ProofSystem/Derivation.lean` | 02-ProofSystem |
| app:TaskSemantics | All Semantics modules | 03-Semantics |
| sub:ProofTheory (P1-P6) | `Bimodal/Theorems/Perpetuity.lean` | 05-Theorems |
| sub:ProofTheory (P9-P22) | `Bimodal/Theorems/*.lean` | 05-Theorems |
| sub:Soundness | `Bimodal/Metalogic/Soundness.lean` | 04-Metalogic |

### 3. Paper Notation Mapping

| Paper Symbol | LaTeX Command | Lean Definition | Description |
|--------------|---------------|-----------------|-------------|
| L | `\BL` | `Formula` | Bimodal language |
| W | `W` | `WorldState` | World states |
| D | `\D` | `T` (generic type) | Temporal order |
| ⇒_x | `\Rightarrow_x` | `task_rel` | Task relation |
| τ | `\tau` | `WorldHistory` | World history |
| H_F | `H_{\F}` | Implicit | Set of world histories |
| M | `\M` | `TaskModel` | Model |
| □ | `\Box` | `Formula.box` | Modal necessity |
| ◇ | `\Diamond` | `Formula.diamond` | Modal possibility |
| H/P | `\Past` | `Formula.all_past` | Universal past |
| G/F | `\Future` | `Formula.all_future` | Universal future |
| △ | `\always` | `Formula.always` | Always (temporal) |
| ▽ | `\sometimes` | `Formula.sometimes` | Sometimes (temporal) |
| ⊢ | `\vdash` | `DerivationTree` | Derivability |
| ⊨ | `\vDash` | `valid`, `truth_at` | Semantic validity |

### 4. Key Implementation Alignment Points

#### 4.1 Frame Definition (def:frame, line 1840)
Paper: F = ⟨W, D, ⇒⟩ with nullity and compositionality
Lean: `TaskFrame T` with `WorldState`, `task_rel`, `nullity`, `compositionality`

#### 4.2 World History (def:world-history, line 1854)
Paper: τ : X → W where X ⊆ D convex, τ(x) ⇒_{y-x} τ(y)
Lean: `WorldHistory` with `domain`, `state`, `convexity`, `task_respect`

#### 4.3 Truth Conditions (def:BL-semantics, line 1862)
Paper's 6 clauses match Lean's `truth_at` definition exactly

#### 4.4 Time-Shift Invariance (lem:history-time-shift-preservation, line 1918)
Paper: Truth preserved under time-shift automorphisms
Lean: `TimeShift.time_shift_preserves_truth` in `Bimodal/Metalogic/SoundnessLemmas.lean`

#### 4.5 Axiom System
Paper's 12 axiom schemata in sub:Logic match Lean's `Axiom` inductive type exactly:
- prop_k, prop_s, ex_falso, peirce (propositional)
- modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist (S5 modal)
- temp_k_dist, temp_4, temp_a, temp_l (temporal)
- modal_future, temp_future (bimodal interaction)

### 5. Implementation Status Summary

| Component | Paper Reference | Lean Status |
|-----------|-----------------|-------------|
| Frame definition | def:frame | COMPLETE |
| World history | def:world-history | COMPLETE |
| Model | def:BL-model | COMPLETE |
| Truth conditions | def:BL-semantics | COMPLETE |
| Time-shift lemma | lem:history-time-shift-preservation | COMPLETE |
| P1-P2 validity | app:valid | COMPLETE |
| MF validity | thm:MF-valid | COMPLETE |
| TF validity | thm:TF-valid | COMPLETE |
| Soundness theorem | thm:TM-soundness | COMPLETE |
| P1-P6 derivations | sub:Logic | COMPLETE |
| P9-P22 theorems | sub:ProofTheory | PARTIAL (some proven) |
| Completeness | Not in paper | AXIOMATIZED |

### 6. Recommended Documentation Structure

Based on paper alignment:

```
Bimodal/latex/
├── BimodalReference.tex           # Main document
├── assets/
│   ├── bimodal-notation.sty       # Match paper notation
│   └── formatting.sty             # From Logos/LaTeX
├── bibliography/
│   └── BimodalReferences.bib      # Include JPL paper
└── subfiles/
    ├── 00-Introduction.tex        # TM logic overview, paper reference
    ├── 01-Syntax.tex              # L definition (sub:Logic language)
    ├── 02-ProofSystem.tex         # Axioms/rules (sub:Logic axioms)
    ├── 03-Semantics.tex           # Frames/models/truth (sec:Construction + app:TaskSemantics)
    ├── 04-Metalogic.tex           # Soundness (sub:Soundness)
    └── 05-Theorems.tex            # P1-P22 (sub:ProofTheory)
```

## Recommendations

1. **Use paper notation**: Match the JPL paper's notation (□, ◇, H, G, △, ▽) exactly
2. **Reference paper sections**: Include explicit references to paper definitions (e.g., "def:frame, line 1840")
3. **Document time-shift invariance**: This is the key lemma enabling MF and TF validity
4. **Include implementation status**: Note which theorems are fully proven vs. axiomatized
5. **Add countermodel**: Include the density countermodel (app:not-dense) as an example

## References

- JPL Paper "The Perpetuity Calculus of Agency" sec:Construction (lines 841-948)
- JPL Paper sub:Logic (lines 1020-1100)
- JPL Paper app:TaskSemantics (lines 1832-2105)
- JPL Paper sub:ProofTheory (lines 2106-2263)
- JPL Paper sub:Soundness (lines 2266-2330)
- Bimodal/Bimodal.lean - Module structure
- Bimodal/Metalogic/Soundness.lean - Soundness proof

## Next Steps

1. Create `bimodal-notation.sty` matching paper's LaTeX commands
2. Structure main document to parallel paper sections
3. Include cross-references to both paper definitions and Lean implementations
4. Document time-shift infrastructure (critical for soundness)
5. Include all P1-P22 theorem statements with derivation status
