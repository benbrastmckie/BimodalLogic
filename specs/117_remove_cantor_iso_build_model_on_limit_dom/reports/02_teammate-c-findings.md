# Teammate C (Critic) Findings: Round 2 — Soundness Impact Analysis

**Task**: 117 — Remove Cantor isomorphism, generalize parametric infrastructure
**Date**: 2026-05-08
**Focus**: What breaks if we remove AddCommGroup from the semantic infrastructure?

## Key Findings

### 1. AddCommGroup Is Structurally Load-Bearing — Not Just Parametric

The group structure is NOT just a parametric convenience. It is **load-bearing** in three critical ways:

#### A. The TaskFrame Axioms ARE Group-Theoretic

`TaskFrame D` (TaskFrame.lean:93) has three axioms:
- `nullity_identity`: `task_rel w 0 u ↔ w = u` — uses **zero element**
- `forward_comp`: `task_rel w (x+y) v` — uses **addition**
- `converse`: `task_rel w d u ↔ task_rel u (-d) w` — uses **negation**

These three axioms literally encode additive group structure. A `TaskFrame` over a type without `AddCommGroup` is **meaningless** — you can't state the axioms. The converse axiom specifically requires negation, and forward_comp requires addition. These are not implementation details; they are part of the definition of what a task frame IS.

**Verdict**: You CANNOT define `TaskFrame D` with just `[LinearOrder D]`. The axioms would be unstatable.

#### B. WorldHistory.respects_task Uses Subtraction

`WorldHistory` (WorldHistory.lean:69) requires:
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

The `t - s` expression computes the **duration** between two time points. This is the core connection between the temporal domain D and the task relation. Without subtraction (which requires at minimum `Sub D` and ideally `AddCommGroup D`), you cannot express "the task relation holds for the duration between s and t."

**Verdict**: `WorldHistory` requires subtraction on D. Cannot be defined with just `[LinearOrder D]`.

#### C. time_shift and ShiftClosed Use Addition and Negation

`time_shift σ Δ` (WorldHistory.lean:238) defines:
```lean
domain := fun z => σ.domain (z + Δ)
states := fun z hz => σ.states (z + Δ) hz
```

And the respects_task proof uses `add_sub_add_right_eq_sub`: `(t + Δ) - (s + Δ) = t - s`.

`ShiftClosed Omega` (Truth.lean:242) uses time_shift:
```lean
∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega
```

The MF/TF soundness proofs (Soundness.lean:259-273) use `time_shift σ (s - t)` and `time_shift_preserves_truth`, which requires the ShiftClosed condition and subtraction.

**Verdict**: The MF and TF axiom soundness proofs fundamentally depend on time_shift, which requires AddCommGroup.

### 2. Which Axiom Soundness Proofs Use Group Operations?

| Axiom | Uses Group Ops? | Specific Operations |
|-------|----------------|---------------------|
| prop_k, prop_s, ex_falso, peirce | No | Pure logic |
| modal_t, modal_4, modal_b, modal_5 | No | Only box quantification |
| modal_k_dist | No | Only box quantification |
| temp_k_dist | No | Only order quantification |
| temp_4 | No | Only order quantification (transitivity of <) |
| temp_a | No | Only order quantification (s < t < r) |
| temp_l | No | Only order quantification (linearity of <) |
| **modal_future (MF)** | **YES** | `time_shift σ (s - t)`, `ShiftClosed`, subtraction |
| **temp_future (TF)** | **YES** | `time_shift σ (s - t)`, `ShiftClosed`, subtraction |
| density | No | Uses `DenselyOrdered` (order property, not group) |
| discreteness_forward | No | Uses `SuccOrder` (order property, not group) |

**Only MF (□φ → □(Fφ)) and TF (□φ → F(□φ)) require group operations for soundness.**

These two axioms express the interaction between modality (□) and temporality (F/P). They require time-shift invariance: truth is preserved when you shift a world history in time. This shift operation requires addition, subtraction, and negation.

### 3. Soundness Risk: Expanding the Model Class

If we weaken D from `[AddCommGroup D]` to `[LinearOrder D]`:

- **Validity becomes more restrictive**: `valid φ` quantifies over ALL D. Weakening D means quantifying over MORE types, so FEWER formulas are valid.
- **MF and TF could become UNSOUND**: If we remove AddCommGroup, we can't define time_shift, so we can't prove MF and TF. But more fundamentally, there might exist a `[LinearOrder D]` model where MF is false.

**Concrete example**: Consider D = a finite linear order {0, 1, 2}. Without group structure, there's no notion of shifting. The box modality quantifies over histories, but without time_shift, shifted histories needn't be in Omega. A carefully constructed model could have □φ true at t=0 (φ true in all histories at t=0) but F(□φ) false at t=0 (at some future time t=1, there's a history where φ is false).

**However**: This risk applies ONLY if we change the definition of `valid`. If we keep `valid` quantifying over `[AddCommGroup D]` and only change the completeness proof to work on `[LinearOrder D]` internally, there is no soundness risk.

### 4. The TaskFrame/WorldHistory Preservation Issue

The user says: "Make sure nothing gets lost, weakening the logic in doing so, or threatening the definition of world histories in terms of the task relation."

**This is fundamentally in tension with removing AddCommGroup.** The task relation IS defined in terms of group operations (0, +, -). World histories ARE defined in terms of the task relation via `respects_task` which uses subtraction (`t - s`).

Three options:
1. **Keep TaskFrame/WorldHistory with AddCommGroup**: Don't change the semantics. Only change the completeness proof pathway to avoid requiring density. This is the SAFE option.
2. **Create a parallel "Kripke-style" semantics**: Define `SimpleFrame D [LinearOrder D]` without tasks. Prove completeness for SimpleFrame. Separately prove that every SimpleFrame model embeds into a TaskFrame model (a "representation theorem"). This preserves the TaskFrame definition while enabling LimitDomSubtype completeness.
3. **Fully replace TaskFrame with LinearOrder-only semantics**: This would DELETE the task relation concept, fundamentally changing the project's semantic foundations. NOT recommended per user constraint.

### 5. Frame Conditions Do NOT Depend on AddCommGroup Intrinsically

Frame conditions (FrameClass.lean) are currently stated with AddCommGroup because they extend LinearTemporalFrame. But conceptually:
- `DenselyOrdered D`: purely about the order
- `SuccOrder D` / `PredOrder D`: purely about the order
- `NoMaxOrder D` / `NoMinOrder D`: purely about the order
- `Nontrivial D`: purely about having ≥ 2 elements

These could all be stated with just `[LinearOrder D]`. The AddCommGroup requirement on these marker classes is inherited from LinearTemporalFrame, not intrinsic.

### 6. FMP/Decidability Depends on AddCommGroup Indirectly

FMP.lean, Filtration.lean, FiniteModel.lean all use `variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` in their variable blocks. This is because they build on TaskFrame/WorldHistory/truth_at.

If TaskFrame is changed, FMP proofs would need updating. But the FMP uses **finite** task frames (`FiniteTaskFrame D`), and in practice the finite model construction works on Int or a finite quotient — both of which have AddCommGroup.

**Verdict**: FMP would need syntactic updates but no substantive proof changes if we keep TaskFrame with AddCommGroup.

## Gaps and Risks

### CRITICAL RISK: Removing AddCommGroup breaks MF and TF soundness
MF (□φ → □(Fφ)) and TF (□φ → F(□φ)) are the ONLY axioms whose soundness requires time_shift, which requires AddCommGroup. These axioms capture the fundamental interaction between S5 modality and temporal logic. They cannot be dropped without changing the logic.

### HIGH RISK: TaskFrame is unstatable without group operations
The converse axiom `task_rel w d u ↔ task_rel u (-d) w` requires negation. Forward_comp requires addition. Nullity_identity requires zero. These are not reformulable without group structure.

### MEDIUM RISK: WorldHistory.respects_task requires subtraction
The `t - s` duration computation in respects_task is essential to connecting time points with the task relation.

### LOW RISK: A parallel SimpleFrame semantics might diverge
If we create `SimpleFrame D [LinearOrder D]` alongside `TaskFrame D [AddCommGroup D]`, we need a representation theorem showing they validate the same formulas. Without this, we might prove completeness for a DIFFERENT logic.

## Questions That Should Be Asked

1. **Can MF and TF be proven sound WITHOUT time_shift?** MF says □φ → □(Fφ): if φ holds in all histories at t, then in every history there's a future time where φ holds. Is there a direct proof that doesn't use time_shift? (I believe not — the shifted history IS the witness for the future time.)

2. **Could we keep AddCommGroup in the semantics but bypass it in the completeness proof?** For example: build the countermodel on Rat (which has AddCommGroup) but avoid the Cantor iso. This preserves all semantics and soundness while only changing the completeness construction.

3. **Is there a "representation theorem" approach?** Define a `SimpleKripkeFrame D [LinearOrder D]` with direct temporal quantification (no task relation), prove completeness for SimpleKripkeFrame, then show that every SimpleKripkeFrame model can be represented as a TaskFrame model over some AddCommGroup. This would maintain both the TaskFrame semantics AND the LinearOrder completeness.

## Confidence Level

**HIGH** — The dependency analysis is based on direct reading of definitions and proof dependencies. The group operations are literally present in the TaskFrame axioms, WorldHistory.respects_task, and MF/TF soundness proofs. The risk assessment follows directly from these structural dependencies.

**Summary**: Removing AddCommGroup from the semantic infrastructure would break MF/TF soundness and make TaskFrame unstatable. The SAFE path is to keep the semantics unchanged and only modify the completeness construction. A representation theorem approach could bridge LinearOrder completeness with TaskFrame semantics.
