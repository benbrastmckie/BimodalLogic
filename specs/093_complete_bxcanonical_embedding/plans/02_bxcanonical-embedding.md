# Implementation Plan: Close BXCanonical TaskModel Embedding Sorry

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 92 (truth lemma)
- **Research Inputs**: reports/01_taskmodel-embedding.md, reports/02_team-research.md
- **Artifacts**: plans/02_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sole remaining active-path sorry at `BXCanonical/Completeness.lean:154` by constructing a BFMCS from BXCanonical witnesses and bridging to the existing parametric canonical infrastructure. The approach (Strategy B, unanimously confirmed by team research) builds a dovetailed Int-indexed chain of BXPoints as an FMCS, packages it into a BFMCS with modal saturation, and applies `parametric_algebraic_representation_conditional` to derive a countermodel contradicting `valid phi`. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Two research reports were integrated:

- **01_taskmodel-embedding.md**: Identified Strategy B (bridge to parametric infrastructure) as preferred approach. Established that BXPoint is structurally identical to ParametricCanonicalWorldState, that all BXCanonical witnesses are sorry-free, and that `Denumerable Formula` is available for dovetailing. Identified the constant-history anti-pattern and showed non-constant FMCS chains are required.

- **02_team-research.md** (4 teammates): Unanimously confirmed Strategy B. Corrected the guard-interval "vacuity" claim (guard is non-vacuous but trivially satisfied via BX9). Identified multi-obligation Until interleaving as hidden difficulty. Confirmed parametric infrastructure is fully D-generic and sorry-free. Revised line estimate to 550-850.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical

## Goals & Non-Goals

**Goals**:
- Close the sorry at `Completeness.lean:154` with a verified proof
- Construct a BFMCS from BXCanonical witnesses for `D = Int`
- Bridge BXCanonical and parametric canonical infrastructure
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Dense time completeness (`D = Rat`), which is a separate task (68)
- Closing sorries in the Algebraic module outside the parametric path (TenseS5Algebra, LindenbaumQuotient, InteriorOperators)
- Refactoring the parametric infrastructure
- Performance optimization of the proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-obligation Until interleaving complexity exceeds estimate | H | M | Use priority-based chain: resolve Until at t+1 (guard trivially satisfied since `[t, t+1)` in Int contains only `r = t`), then F/P via standard dovetailing. Seed unresolved Until formulas into Lindenbaum extensions. |
| Modal saturation requires more boilerplate than estimated | M | M | The BXPoint-to-PCWS bridge is definitional (both wrap MCS). Focus on packaging, not re-proving. |
| Forward/backward Until/Since coherence proofs are harder than expected | H | L | BX8 (`refl_intro_until`) handles base case. BX5 (`self_accum_until`) propagates. The Int guard trick makes forward coherence tractable. |
| Task 92 (truth lemma) not yet complete, blocking dependency | H | M | Phase 1 (FMCS chain) and Phase 2 (BFMCS packaging) can proceed independently. Only Phase 4 (bridge proof) needs the truth lemma from the parametric side, which is already proved. The dependency on task 92 is for the BXCanonical-level truth lemma, which feeds into the BFMCS coherence proofs. |
| Axiom contamination from unexpected sorry in import chain | H | L | Team research verified zero sorry in Frame.lean, ParametricCanonical.lean, ParametricTruthLemma.lean, ParametricHistory.lean, ParametricRepresentation.lean. Run `#print axioms` after each phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Dovetailed FMCS Chain Construction [NOT STARTED]

**Goal**: Build an `Int -> BXPoint` chain from a starting MCS, satisfying `forward_G` and `backward_H`, with temporal coherence (`forward_F`, `backward_P`) and Until/Since forward coherence.

**Tasks**:
- [ ] Create `BXCanonical/CanonicalModel.lean` with appropriate imports
- [ ] Define the obligation enumeration using `Denumerable Formula` (enumerate F-obligations, P-obligations, Until-obligations, Since-obligations)
- [ ] Define the priority-based chain step function: at each positive step, resolve the highest-priority obligation (Until first via `bx_until_eventuality_resolution`, then F via `bx_forward_witness`); at each negative step, resolve Since/P obligations similarly
- [ ] Construct the `FMCS Int` structure from the chain, with `forward_G` proved via `bx_le` transitivity along the chain
- [ ] Prove `backward_H` via reverse `bx_le` transitivity
- [ ] Prove `forward_F`: every `F(psi)` obligation is eventually resolved by dovetailing
- [ ] Prove `backward_P`: every `P(psi)` obligation is eventually resolved
- [ ] Prove `forward_until_since_coherent`: for `phi U psi in fam.mcs t`, the chain places `psi` at some `s >= t` with `phi` on the guard interval `[t, s)`. Use the Int guard trick: place witness at `t+1`, guard reduces to `phi in fam.mcs t` which is given by BX9 (`until_elim`)
- [ ] Prove `backward_until_since_coherent`: given witness pattern, derive Until/Since membership using BX8 (`refl_intro_until`)
- [ ] Seed unresolved Until formulas into Lindenbaum extensions at each chain step to handle multi-obligation interleaving

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - New file: dovetailed chain construction, FMCS structure, coherence proofs

**Verification**:
- `lake build` compiles the new file without errors
- FMCS structure type-checks with all required fields (forward_G, backward_H, forward_F, backward_P, forward_until_since_coherent, backward_until_since_coherent)

---

### Phase 2: BFMCS Packaging with Modal Saturation [NOT STARTED]

**Goal**: Construct a `BFMCS Int` from the FMCS chain by adding modal witness families, satisfying modal saturation and all coherence conditions.

**Tasks**:
- [ ] Define the BXPoint-to-ParametricCanonicalWorldState coercion (definitional: `fun w => ⟨w.formulas, w.is_mcs⟩`)
- [ ] For each Diamond obligation `Diamond psi in fam.mcs t`, use `bx_modal_witness` to get a witness BXPoint, then build a new FMCS chain from that witness using Phase 1's chain construction
- [ ] Package all families into the BFMCS structure with modal saturation proof
- [ ] Prove `box_coherent`: Box formulas are preserved across modal-equivalent families, using `box_preserved_along_bx_le`
- [ ] Verify temporal coherence is inherited by each new witness family (each uses the same chain construction)
- [ ] Define `construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M -> BFMCS Int` as the top-level constructor

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Add BFMCS construction, modal saturation, coherence proofs

**Verification**:
- `construct_bfmcs` type-checks and returns a `BFMCS Int` with all coherence fields satisfied
- No sorry in the file

---

### Phase 3: Bridge Proof Infrastructure [NOT STARTED]

**Goal**: Connect `construct_bfmcs` to `parametric_algebraic_representation_conditional` to produce a concrete TaskModel where MCS membership corresponds to semantic truth.

**Tasks**:
- [ ] Verify that `construct_bfmcs` satisfies the preconditions of `parametric_algebraic_representation_conditional` (temporally coherent, backward/forward Until/Since coherent)
- [ ] Apply `parametric_algebraic_representation_conditional` to get: for any formula `psi`, `psi in M` iff `truth_at (ParametricCanonicalTaskModel Int) Omega tau 0 psi`, where `tau` is the parametric history of the starting family and `Omega` is the shift-closed set
- [ ] Prove the contrapositive: if `phi not_in M`, then `not truth_at ... phi` at the evaluation point
- [ ] Package this as a lemma: `bxcanonical_countermodel : SetMaximalConsistent M -> phi not_in M -> exists (D : Type) (F : TaskFrame D) (M_model : TaskModel D F) (Omega : Set (WorldHistory D F.WorldState)) (tau : WorldHistory D F.WorldState) (t : D), ShiftClosed Omega /\ tau in Omega /\ not (truth_at M_model Omega tau t phi)`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Add bridge lemma connecting BFMCS to parametric representation

**Verification**:
- `bxcanonical_countermodel` type-checks without sorry
- The lemma produces a concrete TaskModel, Omega, history, and time witnessing `not truth_at ... phi`

---

### Phase 4: Close the Sorry at Completeness.lean:154 [NOT STARTED]

**Goal**: Replace the sorry with a proof that derives `False` from `valid phi` and `phi not_in M`.

**Tasks**:
- [ ] Import `BXCanonical.CanonicalModel` in `Completeness.lean`
- [ ] At the sorry site (line 154), apply `bxcanonical_countermodel` to get a TaskModel where `phi` is false
- [ ] Instantiate `valid phi` (which quantifies over ALL TaskModels, Omega, histories, times) at the specific model/Omega/history/time from the countermodel
- [ ] Derive contradiction: `valid phi` gives `truth_at ... phi`, countermodel gives `not truth_at ... phi`
- [ ] Remove the sorry
- [ ] Run `lake build` to verify zero active-path sorry
- [ ] Run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound` appear

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Replace sorry at line 154 with proof using `bxcanonical_countermodel`

**Verification**:
- `lake build` succeeds with no errors
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches

## Testing & Validation

- [ ] `lake build` completes successfully with zero errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] `#print axioms completeness_over_Int` (if it exists) lists only the same three axioms
- [ ] No regressions in existing tests: `lake build` for the full project

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - New file: FMCS chain construction, BFMCS packaging, bridge lemma (estimated 550-750 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Modified: sorry replaced with proof (estimated 5-15 lines changed)
- `specs/093_complete_bxcanonical_embedding/summaries/02_bxcanonical-embedding-summary.md` - Implementation summary

## Rollback/Contingency

- The only modified existing file is `Completeness.lean` (a few lines). Revert with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.
- The new file `CanonicalModel.lean` can be deleted entirely without affecting existing code.
- If the BFMCS construction proves too complex for Int, fall back to a simpler construction using restricted coherence conditions (`restricted_forward_until_since_coherent`) which narrows the Until/Since burden to subformulas of the target formula.
- If modal saturation is unexpectedly difficult, consider a single-family approach where the starting MCS is already modally saturated (this is true for any MCS in S5, since Box formulas are preserved by `bx_modal_equiv`).
