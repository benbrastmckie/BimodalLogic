# Teammate A Findings: ModelChecker Integration as Corrective Training Signal

**Task**: 201 — AlphaZero-Style Proof Search Harness (Round 2)
**Angle**: Primary implementation approach for connecting ModelChecker to training pipeline
**Date**: 2026-05-29

---

## Key Finding 1: Critical Semantic Divergence Between ModelChecker and ProofChecker

**Confidence**: HIGH (confirmed by direct codebase comparison)

The ModelChecker and ProofChecker implement **fundamentally different logics**, not merely different implementations of the same logic. This is the single most important finding and must be resolved before any integration work.

### Operator-Level Differences

| Feature | ModelChecker (Python/Z3) | ProofChecker (Lean 4) |
|---------|--------------------------|----------------------|
| **Temporal primitives** | `\Future` (G), `\Past` (H) as primitives | `untl` (Until U) and `snce` (Since S) as primitives |
| **Until/Since** | NOT IMPLEMENTED | Primitive binary operators |
| **G/H derivation** | Primitive (direct universal quantification) | Derived: G(φ) = ¬F(¬φ), where F(φ) = U(φ,⊤) |
| **Temporal semantics** | Reflexive (≤): G quantifies over t ≤ s | Strict/Irreflexive (<): G quantifies over t < s |
| **Next/Previous** | NOT IMPLEMENTED | Derived: X(φ) = U(φ,⊥), Y(φ) = S(φ,⊥) |
| **Frame structure** | Finite bitvector world states, integer times, bounded intervals | Abstract type D with ordered abelian group, convex domains |
| **Task relation** | Binary relation on world states (no duration) | Ternary: task_rel w d u (world × duration × world) |
| **Time model** | Discrete integer interval [-M+1, M-1] | Parametric: Int, Rat, Real, or custom |
| **Abundance** | Skolem functions for time-shifted worlds | Time-shift construction on world histories |
| **Atoms** | Evaluated at world states (bitvectors) | Evaluated at world states with domain check |

### Semantic Consequence

The reflexive vs. irreflexive temporal semantics creates **different valid formulas**:
- Under reflexive G (ModelChecker): `Gφ → φ` is valid (T-axiom)
- Under irreflexive G (ProofChecker): `Gφ → φ` is NOT valid; replaced by seriality `⊤ → F(⊤)`

A countermodel produced by the ModelChecker under reflexive semantics may NOT be a valid countermodel under the ProofChecker's irreflexive semantics, and vice versa. Using such countermodels directly as training signals would teach the neural network incorrect information.

### Task Relation Mismatch

The ModelChecker's task relation is `Task(state1, state2) → Bool` — a binary relation between world states without explicit duration. The ProofChecker's task relation is `task_rel : WorldState → D → WorldState → Prop` — ternary with explicit duration, plus algebraic constraints:
- `nullity_identity`: task_rel w 0 u ↔ w = u
- `forward_comp`: compositionality for non-negative durations
- `converse`: task_rel w d u ↔ task_rel u (-d) w

The ModelChecker has lawful transitions between consecutive states but no compositionality or converse constraints.

---

## Key Finding 2: Formula Translation Layer Is Straightforward (Despite Semantic Gap)

**Confidence**: HIGH

Despite the deep semantic differences, the SYNTACTIC translation between formula representations is mechanically simple:

### Lean Formula Constructors → ModelChecker Strings

```
Formula.atom (Atom.mk_base "p")  →  'A'  (or 'p' with name mapping)
Formula.bot                       →  '\\bot'
Formula.imp φ ψ                   →  '(φ_str \\rightarrow ψ_str)'
Formula.box φ                     →  '\\Box φ_str'
```

### Lean Derived Operators → ModelChecker Strings

```
Formula.neg φ (= φ.imp bot)       →  '\\neg φ_str'
Formula.and φ ψ                   →  '(φ_str \\wedge ψ_str)'
Formula.or φ ψ                    →  '(φ_str \\vee ψ_str)'
Formula.diamond φ                 →  '\\Diamond φ_str'
Formula.all_future φ              →  '\\Future φ_str'
Formula.all_past φ                →  '\\Past φ_str'
Formula.some_future φ             →  '\\future φ_str'  (lowercase)
Formula.some_past φ               →  '\\past φ_str'    (lowercase)
```

### Gap: No ModelChecker Support for Until/Since

The Lean formula type has primitive Until (`untl φ ψ`) and Since (`snce φ ψ`), but the ModelChecker has NO corresponding operators. Translation of formulas containing Until/Since would require either:
1. **Extending the ModelChecker** to support Until/Since operators (significant work)
2. **Restricting the training corpus** to the G/H/F/P fragment (losing expressiveness)

The G/H/F/P fragment IS definable in terms of Until/Since in Lean, so formulas using only these derived operators can be round-tripped. But any formula with explicit Until/Since subformulas cannot be checked by the current ModelChecker.

---

## Key Finding 3: Two Viable Integration Architectures

**Confidence**: MEDIUM

### Architecture A: Update ModelChecker to Match ProofChecker (Recommended)

Update the ModelChecker's bimodal theory to match the ProofChecker's semantics:

1. Change temporal operators from reflexive to irreflexive (strict <)
2. Add Until/Since as primitive operators with Z3 constraints
3. Update the task relation to include explicit duration
4. Add nullity_identity, forward_comp, converse constraints

**Advantages**: Guaranteed semantic alignment, can check any formula the ProofChecker can express.
**Cost**: Moderate Python/Z3 engineering (2-3 weeks). The Z3 encoding of Until/Since is well-understood.

**Z3 Encoding for Until** (sketch):
```python
def true_at_until(self, event, guard, eval_point):
    semantics = self.semantics
    eval_world = eval_point["world"]
    eval_time = eval_point["time"]
    witness = z3.Int('until_witness')
    guard_time = z3.Int('until_guard')
    return z3.Exists(witness,
        z3.And(
            semantics.is_valid_time_for_world(eval_world, witness),
            eval_time < witness,  # strict!
            semantics.true_at(event, {"world": eval_world, "time": witness}),
            z3.ForAll(guard_time,
                z3.Implies(
                    z3.And(eval_time < guard_time, guard_time < witness),
                    semantics.true_at(guard, {"world": eval_world, "time": guard_time})
                )
            )
        )
    )
```

### Architecture B: Use ModelChecker as Heuristic Signal (Fallback)

Accept the semantic gap and use the ModelChecker as a HEURISTIC signal rather than a guaranteed-correct one:

1. Restrict training to the modal-only fragment (Box/Diamond) where semantics align (both are S5)
2. Use temporal countermodels as "soft" negative signal with lower confidence weight
3. Add a verification step where Lean confirms/rejects the countermodel

**Advantages**: No ModelChecker changes needed. Can start immediately.
**Cost**: Weaker training signal, potential for semantic confusion.

---

## Key Finding 4: Countermodel Representation for Neural Training

**Confidence**: MEDIUM

ModelChecker countermodels consist of:
1. **World histories**: {world_id → {time → world_state}} mappings
2. **Truth assignments**: {world_state × atom → bool}
3. **Task transitions**: {(state1, state2) → bool}
4. **Time intervals**: {world_id → (start, end)}
5. **Time-shift relations**: {source_world → {shift → target_world}}

### Recommended Encoding: Graph + Sequence Hybrid

```
Countermodel Tensor Structure:
  - world_states: [num_worlds, num_times, state_dim]  # 3D tensor
  - truth_values: [num_states, num_atoms]              # 2D boolean
  - task_matrix: [num_states, num_states]               # 2D adjacency
  - time_intervals: [num_worlds, 2]                     # start, end per world
  - formula_tokens: [seq_len]                           # tokenized formula
  - label: 0/1                                          # valid/invalid
```

For transformer-based architectures, flatten the countermodel into a token sequence:
```
[CLS] formula_tokens [SEP] W0:(t0:s1)(t1:s2) W1:(t0:s1)(t1:s3) [SEP] V:s1→A s2→¬A s3→A [SEP] T:s1→s2 s2→s1
```

The key insight from task 203 (formula enumerator): the Lean side exports JSON, so the Python side can consume JSON countermodels from the ModelChecker in the same pipeline.

---

## Key Finding 5: Corrective Signal Pipeline Design

**Confidence**: MEDIUM

### Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    LEAN SIDE (this repo)                        │
│                                                                 │
│  FormulaEnumerator → DecisionProcedure → JSON Dataset Export    │
│  (task 203)           (Decidability/)     {formula, label,      │
│                                            proof_trace}         │
└──────────────────────────┬──────────────────────────────────────┘
                           │ JSON file
┌──────────────────────────▼──────────────────────────────────────┐
│                    PYTHON SIDE (harness repo)                   │
│                                                                 │
│  Load JSON → For invalid formulas → ModelChecker.check()        │
│                                     ↓                           │
│                              Countermodel extraction             │
│                                     ↓                           │
│                         Encode as training tensors              │
│                              ↓              ↓                   │
│                    Positive signal      Negative signal          │
│                    (proof traces)       (countermodels)          │
│                              ↓              ↓                   │
│                         Neural Network Training                  │
└─────────────────────────────────────────────────────────────────┘
```

### Critical Pipeline Detail

The formula enumerator (task 203) produces formulas labeled by the tableau decider. For INVALID formulas, the ModelChecker adds a richer signal: not just "invalid" but "here is WHY it's invalid" via the concrete countermodel. This is the dual verification architecture from the technical memo.

For VALID formulas where the proof search fails, the ModelChecker confirms validity (no countermodel found), indicating a search failure rather than a logic failure — a different kind of training signal.

---

## Recommended Approach

### Phase 0 (Prerequisite): Semantic Alignment
**Before any integration**, update the ModelChecker bimodal theory to match the ProofChecker's semantics:
1. Switch G/H/F/P to strict temporal quantification
2. Add Until/Since operators
3. Update task relation to ternary with duration
4. Validate alignment by running shared test cases (theorems/countermodels that should agree)

### Phase 1: Formula Translation Bridge
Build a Python module that converts Lean-exported JSON formulas into ModelChecker input format.

### Phase 2: Countermodel Extraction Pipeline
For each invalid formula, run ModelChecker to extract structured countermodel, encode as training data.

### Phase 3: Training Integration
Feed both positive (proof traces) and negative (countermodels) signals into the neural training loop.

---

## Evidence Sources

- Lean Formula type: `Theories/Bimodal/Syntax/Formula.lean` (6 constructors: atom, bot, imp, box, untl, snce)
- Lean truth evaluation: `Theories/Bimodal/Semantics/Truth.lean` (strict temporal quantification confirmed at lines 128-131)
- Lean task frame: `Theories/Bimodal/Semantics/TaskFrame.lean` (ternary task_rel with duration)
- ModelChecker operators: `theory_lib/bimodal/operators.py` (no Until/Since classes)
- ModelChecker semantics: `theory_lib/bimodal/semantic.py` (reflexive G/H at lines 386-406, 529-547)
- ModelChecker examples: `theory_lib/bimodal/examples.py` (string formula format)
- ProofChecker axioms: `ProofSystem/Axioms.lean` (42 BX axiom constructors, irreflexive seriality axioms)
