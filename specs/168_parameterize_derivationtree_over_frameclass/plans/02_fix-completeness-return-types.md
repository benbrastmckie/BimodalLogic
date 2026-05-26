# Revised Plan: Fix completeness_dense/discrete Return Types

- **Task**: 168 - Parameterize DerivationTree over FrameClass (Phase 8 addendum)
- **Status**: [COMPLETED]
- **Effort**: 4-6 hours
- **Dependencies**: Phases 1-7 (all complete), Task 197 (complete)
- **Research Inputs**: Completion audit (reports/02_completion-audit.md)
- **Artifacts**: plans/02_fix-completeness-return-types.md (this file)
- **Standards**: plan-format.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The original plan (Phase 5, item 5.5) correctly specified that `completeness_dense` should
return `DerivationTree FrameClass.Dense [] φ` and `completeness_discrete` should return
`DerivationTree FrameClass.Discrete [] φ`. The implementation deviated: both currently
return `DerivationTree FrameClass.Base`, which is mathematically **incorrect**.

### The Bug

The density axiom `Fφ → FFφ` is valid on all dense frames (`valid_dense`), but it is NOT
derivable in the base system. On Z (integers), if φ holds only at t=1, then Fφ holds at
t=0 but FFφ fails (no integer in (0,1) to serve as intermediate witness). Since the base
system is sound for all linear frames including Z, `Fφ → FFφ` is not Base-derivable.

Therefore `valid_dense φ → Nonempty (DerivationTree FrameClass.Base [] φ)` is **false**
— the density axiom is a direct counterexample. The sorry in the non-dense branch of
`completeness_dense` is not a temporary gap; it guards an unprovable goal.

### The Fix

Change return types to match the plan specification:
- `completeness_dense`: return `DerivationTree FrameClass.Dense [] φ`
- `completeness_discrete`: return `DerivationTree FrameClass.Discrete [] φ`

With Dense-derivability as the conclusion, the proof uses Dense-consistency and Dense-MCS
in the Lindenbaum construction. The density axiom is available in the MCS, which should
force the canonical model into the dense case — potentially eliminating the sorry in the
non-dense branch (or reducing it to a separate, genuine mathematical question about
whether Dense-MCS forces the dense indicator formula □(F'⊤)).

## Goals & Non-Goals

**Goals**:
- Correct return types for `completeness_dense` and `completeness_discrete`
- Parameterize `neg_consistent_of_not_derivable` over fc
- Update `countermodel_dense_enriched` and `countermodel_discrete_enriched` for fc-MCS
- Eliminate false sorries (sorries guarding unprovable goals)
- `lake build` passes

**Non-Goals**:
- Proving the `succ_cofinal` sorry (separate mathematical gap)
- Refactoring the countermodel construction machinery
- Changing the base `completeness` theorem (it is correct as-is)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dense-MCS does not force □(F'⊤) indicator | H | M | If unprovable, the sorry transforms from "false statement" to "genuine open question" — still an improvement. Document clearly. |
| countermodel_dense_enriched needs fc-MCS | M | H | The Chronicle pipeline is already parameterized over fc (task 197). Pass fc through. |
| Cascading type changes through downstream consumers | M | L | Few consumers of completeness_dense/discrete exist. Check imports. |

## Implementation Phases

### Phase 1: Parameterize neg_consistent_of_not_derivable [COMPLETED]

**Goal**: Make `neg_consistent_of_not_derivable` work at arbitrary fc. The proof uses only
structural rules (deduction theorem, modus ponens, double negation, ex falso) — all already
parameterized over fc by tasks 168/197.

**Tasks**:
- [x] **1.1** Change `neg_consistent_of_not_derivable` signature to take `{fc : FrameClass}`:
  ```lean
  theorem neg_consistent_of_not_derivable {fc : FrameClass} (φ : Formula)
      (h_not_deriv : ¬Nonempty (DerivationTree fc [] φ)) :
      SetConsistent (fc := fc) ({Formula.neg φ} : Set Formula)
  ```
- [x] **1.2** Update the proof body: replace hardcoded `FrameClass.Base` with `fc`.
  All internal helpers (deduction_theorem, double_negation, ex_falso, modus_ponens)
  are already fc-polymorphic.
- [x] **1.3** Verify: base `completeness` still compiles (it will infer fc = Base).

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

### Phase 2: Fix completeness_dense [COMPLETED]

**Goal**: Change return type and proof structure for dense completeness.

**Tasks**:
- [x] **2.1** Change `completeness_dense` return type:
  ```lean
  theorem completeness_dense (φ : Formula) :
      valid_dense φ → Nonempty (DerivationTree FrameClass.Dense [] φ)
  ```
- [x] **2.2** Update the proof to use `neg_consistent_of_not_derivable` at fc = Dense.
  The Lindenbaum lemma produces a Dense-MCS.
- [x] **2.3** Update `countermodel_dense_enriched` to accept a Dense-MCS
  (or any fc-MCS with fc ≥ Base, since the Chronicle pipeline is fc-parameterized).
- [x] **2.4** Investigate the non-dense branch: with a Dense-MCS, determine whether
  □(F'⊤) ∈ M is forced by the density axiom. If so, the non-dense branch is
  unreachable and the sorry can be eliminated. If not, document as a genuine
  open question (distinct from the previous false sorry).
- [x] **2.5** Verify: `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes.

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

### Phase 3: Fix completeness_discrete [COMPLETED]

**Goal**: Same treatment for discrete completeness.

**Tasks**:
- [x] **3.1** Change `completeness_discrete` return type:
  ```lean
  theorem completeness_discrete (φ : Formula) :
      valid_discrete φ → Nonempty (DerivationTree FrameClass.Discrete [] φ)
  ```
- [x] **3.2** Update the proof to use `neg_consistent_of_not_derivable` at fc = Discrete.
- [x] **3.3** Update `countermodel_discrete_enriched` to accept a Discrete-MCS. *(deviation: altered -- implemented full proof body using dd_countermodel_chronicle_discrete pipeline instead of sorry, eliminating the sorry entirely)*
- [x] **3.4** Investigate whether Discrete-MCS forces the discrete indicator □(U(⊤,⊥)) ∈ M,
  making the dense branch unreachable.
- [x] **3.5** Verify compilation.

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

### Phase 4: Downstream Consumers and Final Verification [COMPLETED]

**Goal**: Update any code that calls `completeness_dense` or `completeness_discrete` and
expects `DerivationTree Base`.

**Tasks**:
- [x] **4.1** Search for all callers of `completeness_dense` and `completeness_discrete`:
  ```bash
  grep -rn "completeness_dense\|completeness_discrete" Theories/
  ```
- [x] **4.2** Update callers — they may need `DerivationTree.lift` to convert *(deviation: skipped -- no Lean callers exist outside Completeness.lean itself; only documentation references in README.md and Metalogic.lean)*
  Dense/Discrete trees back to a common fc if needed.
- [x] **4.3** Update docstrings in Completeness.lean to reflect correct return types.
- [x] **4.4** Full `lake build` verification.
- [x] **4.5** Grep for sorry in Completeness.lean — document any remaining sorries
  with their mathematical status (genuine gap vs. machinery gap).

**Files**: Various (determined by grep in 4.1)

## Testing & Validation

- [x] `lake build` passes after each phase
- [x] `completeness_dense` returns `DerivationTree FrameClass.Dense`
- [x] `completeness_discrete` returns `DerivationTree FrameClass.Discrete`
- [x] Base `completeness` unchanged and still compiles
- [x] No new sorries introduced (2 sorries remain from 4 original; 2 eliminated)
- [x] Every remaining sorry has clear mathematical documentation (genuine gap, not false statement)

## Artifacts & Outputs

- This plan file
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- Possibly modified: downstream consumers, countermodel enriched functions
