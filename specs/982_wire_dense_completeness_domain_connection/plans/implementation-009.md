# Implementation Plan: Wire Dense Completeness Domain Connection (v9)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours (4 phases)
- **Dependencies**: None (prior W/D separation work completed: SeparatedTaskFrame.lean, SeparatedHistory.lean exist)
- **Research Inputs**:
  - research-013.md (Comprehensive gap analysis - **primary**)
  - research-011.md (CanonicalMCS all-MCS analysis)
  - research-012.md (DN -> world history density)
- **Artifacts**: plans/implementation-009.md (this file), supersedes implementation-001 through 008.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v009 (2026-03-17)**: **STRATEGY PIVOT** based on research-013.md comprehensive gap analysis. Key insight:

The v8 approach failed because CanonicalMCS is only Preorder, not LinearOrder. The parametric truth lemma (ParametricTruthLemma.lean:49) REQUIRES `[LinearOrder D]`.

**New Strategy: Multi-Family BFMCS over TimelineQuot**

Use TimelineQuot (which HAS LinearOrder + AddCommGroup) as the domain D, but with multi-family BFMCS architecture that adds witness families on-demand to satisfy:
1. `forward_F` - witness families contain the F-witness MCSs
2. `backward_P` - symmetric witness families for P-witnesses
3. `modal_backward` - saturation gives `saturated_modal_backward` (proven axiom-free)

**Why This Works**:
- TimelineQuot provides LinearOrder + AddCommGroup (satisfies ParametricTruthLemma)
- Witness families add new FMCS structures (not new times) containing required witnesses
- Modal saturation is PROVEN in ModalSaturation.lean (no new sorries needed)
- Cantor isomorphism transfers to Rat for final theorem

**v008**: SUPERSEDED. CanonicalMCS-based approach blocked by LinearOrder constraint.
**v007**: SUPERSEDED. W/D separation was correct but didn't resolve BFMCS coherence.
**v006**: SUPERSEDED. Domain transfer analysis only.
**v005**: SUPERSEDED. Constant witness families flawed.

## Executive Summary

### The Key Insight (research-013)

From the comprehensive gap analysis:

1. **Total sorries on active path**: 18 sorries across 6 files
2. **Primary blocker**: TimelineQuot forward_F/backward_P witnesses (5 sorries in ClosureSaturation.lean)
3. **Secondary blocker**: Singleton BFMCS modal_backward (structural limitation)
4. **Root cause**: Singleton BFMCS is architecturally insufficient

The multi-family approach resolves BOTH blockers:
- Witness families add MCSs at the family level (not time level)
- Modal saturation gives modal_backward for free

### Architecture Diagram

```
valid_over D (D : LinearOrder + DenselyOrdered)
    |
    | instantiate D = TimelineQuot
    v
TimelineQuot (Cantor ≃o Rat, provides LinearOrder + AddCommGroup)
    |
    | build multi-family BFMCS
    v
TimelineQuotSaturatedBFMCS (multi-family with witness saturation)
    |   - Primary family: timelineQuotFMCS
    |   - Witness families: one per Diamond(psi) obligation
    |
    | forward_F via witness families
    | modal_backward via saturated_modal_backward
    v
ParametricTruthLemma (D = TimelineQuot satisfies [LinearOrder D])
    |
    | truth lemma proven
    v
dense_completeness_theorem
```

### What's Already Done

From previous implementation efforts:
- `SeparatedTaskFrame.lean` - D = TimelineQuot, W = ParametricCanonicalWorldState (EXISTS)
- `SeparatedHistory.lean` - WorldHistory with shift-closed Omega (EXISTS)
- `ParametricTruthLemma.lean` - D-parametric truth lemma (EXISTS, requires LinearOrder)
- `ModalSaturation.lean` - Modal saturation infrastructure (EXISTS, proven)
- `CantorApplication.lean` - TimelineQuot ≃o Rat (EXISTS, proven)
- `timelineQuotFMCS` - FMCS over TimelineQuot (EXISTS, forward_G/backward_H proven)

### What Needs to Be Done

1. **Build multi-family BFMCS over TimelineQuot** with witness saturation
2. **Prove forward_F/backward_P** via witness family structure (not time structure)
3. **Apply parametric truth lemma** (D = TimelineQuot satisfies LinearOrder)
4. **Wire dense completeness theorem** via Cantor isomorphism

## Goals & Non-Goals

**Goals**:
- Complete `dense_completeness_theorem` using multi-family BFMCS over TimelineQuot
- Prove forward_F/backward_P via witness family architecture
- Use existing `saturated_modal_backward` for modal_backward (no new proof needed)
- Apply ParametricTruthLemma with D = TimelineQuot
- Zero new sorries, zero new axioms

**Non-Goals**:
- Prove forward_F/backward_P at the time level (bypass via family structure)
- Build BFMCS over CanonicalMCS (blocked by LinearOrder constraint)
- Fix the m > 2k edge case directly (bypass via witness families)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness family FMCS construction is complex | Medium | Medium | Follow ModalSaturation.lean patterns exactly |
| Forward_F via families needs new proof architecture | Medium | Medium | Research-013 Section 5.2 outlines approach |
| Temporal coherence linking families to times | Medium | Low | Use `buildWitnessMCS` from WitnessChainFMCS.lean |
| Cantor transfer edge cases | Low | Low | Existing CantorApplication.lean handles order iso |

## Sorry Characterization

### Pre-existing Sorries (To Be Resolved)

| File:Line | Context | Resolution |
|-----------|---------|------------|
| `ClosureSaturation.lean:659` | `timelineQuotFMCS_forward_F` | Bypassed - use witness families |
| `ClosureSaturation.lean:679` | `timelineQuotFMCS_backward_P` | Bypassed - use witness families |
| `ClosureSaturation.lean:724` | `timelineQuotSingletonBFMCS.modal_backward` | Resolved - multi-family gives saturated_modal_backward |
| `TimelineQuotCompleteness.lean:127` | `timelineQuot_not_valid_of_neg_consistent` | Resolved in Phase 4 |
| `CanonicalEmbedding.lean:181,192,231` | Rat BFMCS sorries | May remain (alternative path) |

### Expected Resolution

Phase 1-2 bypasses forward_F/backward_P at time level by using family-level witnesses.
Phase 3 resolves modal_backward via multi-family saturation.
Phase 4 wires the completeness theorem.

### New Sorries

- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Document blocker in metadata

## Axiom Characterization

### Pre-existing Axioms (Not Introduced by This Task)

- `canonicalR_irreflexive_axiom` (CanonicalDomain.lean) - Required for bimodal logic

### New Axioms

- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 1: Define Multi-Family BFMCS Structure [BLOCKED]

**BLOCKER (sess_1773781597_89602a)**: Architectural flaw discovered — the multi-family approach
does NOT resolve the `forward_F`/`backward_P` problem.

**Root Cause**: `BFMCS.temporally_coherent` requires EACH family in B.families to have
`forward_F`/`backward_P` INTERNALLY (within that family). Specifically:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧  -- within same fam
    ...
```
This is NOT cross-family. Witness families added to the BFMCS must ALSO have
their own internal `forward_F`/`backward_P`. Since witness families are FMCSs
over TimelineQuot, they face the SAME m > 2k edge case as the primary family.

**What was explored**:
- `BFMCS` structure: families, modal_forward, modal_backward, eval_family (BFMCS.lean)
- `BFMCS.temporally_coherent`: requires strict `<` forward_F for ALL families (TemporalCoherence.lean)
- `parametric_canonical_truth_lemma`: requires `h_tc : B.temporally_coherent` (ParametricTruthLemma.lean:174)
- `timelineQuotFMCS_forward_F`: sorry at m > 2k edge case (ClosureSaturation.lean:659)
- `canonicalMCS_forward_F`: sorry-free but gives `≤` not `<` (CanonicalFMCS.lean:222)
- `ParametricTruthLemma` requires `[LinearOrder D]` + `[AddCommGroup D]` (line 49)
- `CanonicalMCS` is only Preorder (not LinearOrder) — same v8 blocker
- `saturated_modal_backward` works but doesn't help with temporal coherence gap
- `canonical_truth_lemma` for D=Int is sorry-free but Int is not DenselyOrdered

**Remaining options**:
1. Fix m > 2k edge case in `timelineQuotFMCS_forward_F` directly (15-20 hours, high risk)
2. Prove CanonicalMCS forward_F with STRICT `<` using `canonicalR_irreflexive` (see below)
3. Adapt `canonical_truth_lemma` (Int-based) to use with TimelineQuot via domain transfer

**Option 2 Analysis**:
- `canonical_forward_F` gives `CanonicalR w.world W.world`
- `canonicalR_irreflexive` (proven, no axiom) gives `¬CanonicalR W.world W.world`
- Therefore `w.world ≠ W.world`, so `w ≠ W_as_CanonicalMCS`
- Combined: `w < W_as_CanonicalMCS` (strict) — NEEDS asymmetry of CanonicalR
- CanonicalR asymmetry needs to be verified/proven
- BUT: Even with strict forward_F on CanonicalMCS, ParametricTruthLemma requires `[LinearOrder D]`
  and CanonicalMCS is only Preorder — so can't use ParametricTruthLemma with CanonicalMCS

**Conclusion**: Plan v9 is INCORRECT. The multi-family approach does not bypass the temporal
coherence requirement. The fundamental blocker remains:
- TimelineQuot FMCSs have sorry'd forward_F (m > 2k edge case)
- CanonicalMCS has sorry-free forward_F but requires separate truth lemma (no ParametricTruthLemma)
- No existing path resolves both constraints without new proof work

**Recommended next step**: Research task to find correct approach. Consider:
1. Fix timelineQuotFMCS_forward_F m > 2k case (requires dovetailing construction changes)
2. Build a CanonicalMCS-specific truth lemma that uses Preorder (not LinearOrder)

- **Dependencies**: None
- **Goal**: Define `TimelineQuotSaturatedBFMCS` using witness family pattern

**Key Design**:

Following ModalSaturation.lean patterns (lines 193-209 warn against constant families):

```lean
/-- Multi-family BFMCS over TimelineQuot with witness saturation.

The families set contains:
1. Primary family: timelineQuotFMCS (maps times to MCSs via staged construction)
2. Witness families: for each Diamond(psi) in subformula closure where psi
   is consistent at some time, add a witness family

Witness families are NOT constant - they follow the staged construction
rooted at the Lindenbaum extension of {psi} ∪ g_content(M) for some M. -/
structure TimelineQuotSaturatedBFMCS (phi : Formula) where
  /-- The target formula for completeness -/
  target : Formula := phi
  /-- Primary family from staged construction -/
  primary : FMCS TimelineQuot := timelineQuotFMCS root_mcs h_root_mcs
  /-- Witness families for Diamond subformulas -/
  witnesses : Subformula phi → Option (FMCS TimelineQuot)
  /-- Witness families are proper (when present) -/
  witness_proper : ∀ sf, ∀ w ∈ witnesses sf, ...
```

**Alternative (Simpler) Design**:

If the indexed structure is too complex, use a flat set of families:

```lean
/-- Saturated BFMCS with explicit family set -/
def timelineQuotSaturatedBFMCS (phi : Formula)
    (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs) :
    BFMCS TimelineQuot where
  families := {timelineQuotFMCS root_mcs h_mcs} ∪ witnessSet phi root_mcs h_mcs
  nonempty := ⟨timelineQuotFMCS root_mcs h_mcs, Or.inl rfl⟩
  modal_forward := by ...  -- From T-axiom (Box phi -> phi)
  modal_backward := saturated_modal_backward ...  -- From saturation
  eval_family := timelineQuotFMCS root_mcs h_mcs
  eval_family_mem := Or.inl rfl
```

**Tasks**:
- [ ] Define `witnessSet` : formula and root MCS to set of witness FMCS
- [ ] Each witness FMCS is rooted at Lindenbaum extension of witness MCS
- [ ] Prove `witnessSet` is finite (bounded by subformula count)
- [ ] Define `timelineQuotSaturatedBFMCS`
- [ ] Prove `nonempty` (primary family is in set)

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotSaturatedBFMCS.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotSaturatedBFMCS` passes
- Structure compiles without sorry

---

### Phase 2: Prove Temporal Coherence via Witness Families [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Prove `forward_F` and `backward_P` using witness family structure

**The Key Insight**:

Standard forward_F requires: `F(psi) ∈ mcs(t) → ∃ s > t, psi ∈ mcs(s)`

This is hard because the witness MCS might not be at any time in TimelineQuot (the m > 2k edge case).

**Family-Level Resolution**:

Instead of finding a witness TIME, we use a witness FAMILY:

```lean
/-- Forward F via witness families:
    F(psi) in family.mcs(t) implies there exists a witness family
    where psi is in the family.mcs at some time s > t -/
theorem timelineQuotSaturated_forward_F (B : BFMCS TimelineQuot)
    (hB : B = timelineQuotSaturatedBFMCS phi root_mcs h_mcs)
    (fam : FMCS TimelineQuot) (hfam : fam ∈ B.families)
    (t : TimelineQuot) (psi : Formula)
    (hF : Formula.futureF psi ∈ fam.mcs t) :
    ∃ fam' ∈ B.families, ∃ s > t, psi ∈ fam'.mcs s := by
  -- Case 1: Witness is in primary family at some later time
  -- Case 2: Witness is in a witness family (the family IS the witness)
  ...
```

**Construction Flow**:

1. From `F(psi) ∈ mcs(t)`, get witness MCS W via `canonical_forward_F`
2. W is an MCS containing psi
3. Either W appears in TimelineQuot at some time s > t (Case 1)
4. Or W is the root of a witness family, and psi appears at the root time (Case 2)

**Why This Works**:

The witness families are indexed by (psi, M) pairs where Diamond(psi) is in M.
Each such pair generates a witness family rooted at the Lindenbaum MCS containing psi.
So the witness EXISTS in some family - we just need to show it's at the right time relation.

**Tasks**:
- [ ] Prove `timelineQuotSaturated_forward_F` using two-case analysis
- [ ] Handle Case 1: witness in primary family (when m <= 2k)
- [ ] Handle Case 2: witness in witness family
- [ ] Prove symmetric `timelineQuotSaturated_backward_P`
- [ ] Combine into `timelineQuotSaturatedBFMCS_temporally_coherent`

**Timing**: 3-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotSaturatedBFMCS.lean` - MODIFY

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotSaturatedBFMCS.lean` returns empty
- Temporal coherence is proven

---

### Phase 3: Apply Parametric Truth Lemma [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Instantiate ParametricTruthLemma for D = TimelineQuot

**Why This Works Now**:

TimelineQuot satisfies all ParametricTruthLemma requirements:
- `[AddCommGroup TimelineQuot]` - Via Antisymmetrization of CanonicalMCS with additive structure
- `[LinearOrder TimelineQuot]` - Via Antisymmetrization (total order from antisymm)
- `[IsOrderedAddMonoid TimelineQuot]` - Inherited from CanonicalMCS

The multi-family BFMCS provides:
- `temporally_coherent` - Proven in Phase 2
- `modal_forward` - T-axiom (trivial)
- `modal_backward` - `saturated_modal_backward` from ModalSaturation.lean

**Instantiation**:

```lean
/-- Truth lemma for TimelineQuot saturated BFMCS -/
theorem timelineQuotSaturated_truth_lemma
    (B : BFMCS TimelineQuot) (hB : B = timelineQuotSaturatedBFMCS phi root_mcs h_mcs)
    (h_tc : B.temporally_coherent) :
    ∀ (fam : FMCS TimelineQuot), fam ∈ B.families →
    ∀ (t : TimelineQuot) (psi : Formula),
      psi ∈ fam.mcs t ↔ truth_at model Omega history t psi :=
  parametric_canonical_truth_lemma B h_tc
```

**Tasks**:
- [ ] Verify TimelineQuot has all required instances
- [ ] Build Omega (set of histories) from saturated BFMCS
- [ ] Apply `parametric_canonical_truth_lemma`
- [ ] Derive: `neg(phi) ∈ root_mcs → phi false in model`

**Timing**: 1-2 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotSaturatedBFMCS.lean` - MODIFY
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFY

**Verification**:
- Truth lemma instantiated without sorry
- `timelineQuot_not_valid_of_neg_consistent` becomes provable

---

### Phase 4: Wire Dense Completeness Theorem [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Complete `dense_completeness_theorem` and transfer via Cantor

**The Completeness Chain**:

```lean
-- Step 1: neg(phi) consistent implies neg(phi) in some MCS (Lindenbaum)
-- Step 2: Build saturated BFMCS with that MCS as root
-- Step 3: By truth lemma, phi is FALSE in the model
-- Step 4: Therefore phi is not valid over TimelineQuot
-- Step 5: By contraposition: valid over TimelineQuot implies provable

theorem timelineQuot_completeness (phi : Formula) :
    (∀ M : Model TimelineQuot, valid_in M phi) → Nonempty ([] ⊢ phi) := by
  intro h_valid
  by_contra h_not_prov
  obtain ⟨root_mcs, h_root, h_neg⟩ := lindenbaum_neg_of_not_provable h_not_prov
  let B := timelineQuotSaturatedBFMCS phi root_mcs h_root
  have h_tc := timelineQuotSaturatedBFMCS_temporally_coherent ...
  have h_truth := timelineQuotSaturated_truth_lemma B rfl h_tc
  -- neg(phi) in root_mcs means phi FALSE in model
  -- But h_valid says phi TRUE in all models - contradiction
  ...
```

**Transfer to General Dense D**:

```lean
theorem dense_completeness_theorem (phi : Formula)
    (h_valid : ∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [DenselyOrdered D]
                 [NoMinOrder D] [NoMaxOrder D], valid_over D phi) :
    Nonempty ([] ⊢ phi) := by
  -- TimelineQuot is dense, so h_valid applies
  have h_tq := h_valid TimelineQuot
  exact timelineQuot_completeness phi h_tq
```

**Tasks**:
- [ ] Prove `timelineQuot_completeness`
- [ ] Resolve `timelineQuot_not_valid_of_neg_consistent` sorry
- [ ] State and prove `dense_completeness_theorem`
- [ ] Verify Cantor isomorphism properties (TimelineQuot ≃o Rat)
- [ ] Optionally: transfer to Rat-based statement

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFY
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - MODIFY

**Verification**:
- `lake build` full project passes
- `grep -rn "\bsorry\b" TimelineQuotCompleteness.lean` returns empty
- `grep -rn "\bsorry\b" DenseCompleteness.lean` returns empty (for new theorems)
- `grep -n "^axiom " TimelineQuotSaturatedBFMCS.lean` shows no new axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <new files>` returns empty
- [ ] `grep -n "^axiom " <new files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] Multi-family BFMCS has proper modal saturation
- [ ] Witness families follow staged construction (not constant)
- [ ] Forward_F/backward_P use family-level witnesses correctly
- [ ] Truth lemma handles all formula constructors
- [ ] Completeness correctly uses Lindenbaum + truth lemma
- [ ] No circular dependencies between theorems

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotSaturatedBFMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - MODIFIED
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - CREATED

## Rollback/Contingency

If implementation fails:
1. New file `TimelineQuotSaturatedBFMCS.lean` can be deleted
2. Modifications to TimelineQuotCompleteness.lean and DenseCompleteness.lean can be reverted via git
3. The singleton BFMCS approach remains available as reference

## Why This Approach is Correct

### Multi-Family Resolves Both Blockers

1. **Forward_F/backward_P blocker**: The m > 2k edge case means witness MCSs might not be at any time in TimelineQuot. But multi-family BFMCS adds witness FAMILIES, not witness TIMES. The witness MCS is the ROOT of its own family, so it exists in the BFMCS structure.

2. **Modal_backward blocker**: Singleton BFMCS cannot prove modal_backward (phi in mcs → Box(phi) in mcs). Multi-family BFMCS gets `saturated_modal_backward` from ModalSaturation.lean - this is ALREADY PROVEN with no new sorries needed.

### TimelineQuot Satisfies LinearOrder

Unlike CanonicalMCS (only Preorder), TimelineQuot is constructed via Antisymmetrization which gives:
- LinearOrder (total order)
- DenselyOrdered (from CanonicalMCS density)
- NoMinOrder/NoMaxOrder (from CanonicalMCS)
- AddCommGroup (from quotient of additive structure)

This satisfies ParametricTruthLemma requirements (line 49).

### Cantor Isomorphism Preserves Everything

`CantorApplication.lean` proves `TimelineQuot ≃o Rat` (order isomorphism).
This means validity over TimelineQuot ↔ validity over Rat, so the dense completeness theorem applies to all countable dense linear orders without endpoints.
