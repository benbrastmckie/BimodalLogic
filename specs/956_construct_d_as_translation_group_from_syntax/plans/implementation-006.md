# Implementation Plan: K-Relational Pipeline with Seriality Axioms

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 20-25 hours
- **Dependencies**: None
- **Research Inputs**: research-024.md (seriality vs T-axioms), research-023.md (K-Relational pipeline), implementation-005.md (prior plan)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-005.md (blocked at Phase 5 due to missing T-axioms)

## Overview

This plan revises implementation-005 based on research-024 findings. The key change: **add seriality axioms** (`F(neg bot)`, `P(neg bot)`) instead of T-axioms, keeping irreflexive semantics.

### What Changed from v005

| Issue | v005 Assumption | v006 Fix |
|-------|-----------------|----------|
| Phase 5 blocker | `temp_a` gives `G(phi)->phi` | Wrong: `temp_a` is connectedness, not T-axiom |
| T-axioms | Present in axiom system | Removed in task 782; must add seriality instead |
| Downstream breakage | Not addressed | ~30 references to removed `temp_t_future/past` |
| FMCS coherence | Uses `<=` (reflexive) | Must align with `<` (irreflexive semantics) |

### Critical Path (Revised)

```
[0] FIX CODEBASE (seriality axioms + downstream fixes) <-- NEW PHASE
    |
[1] Verify Infrastructure ---> [2] RestrictedFragment ---> [3] LinearOrder
                                                                   |
[4] DenselyOrdered (BLOCKER) <-------------------------------------+
                                                                   |
[5] NoEndpoints (NOW UNBLOCKED with seriality) <-------------------+
                                                                   |
[6] Cantor isomorphism <-------------------------------------------+
    |
[7-10] TaskFrame -> Truth Lemma -> Completeness
```

## Goals & Non-Goals

**Goals**:
- Fix broken codebase: add seriality axioms, fix ~30 downstream references
- Complete K-Relational pipeline with non-trivial task_rel
- Achieve zero new sorries

**Non-Goals**:
- Re-add T-axioms (unsound for irreflexive semantics)
- Switch to reflexive semantics (breaks density proofs)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Downstream ~30 fixes more complex than expected | HIGH | MEDIUM | Research-024 analyzed patterns; most are simple replacements |
| FMCS coherence redesign needed | MEDIUM | MEDIUM | May need `<` instead of `<=` in coherence conditions |
| Density blocker (Phase 4) | HIGH | MEDIUM | Same as v005; single documented blocker acceptable |
| Strict separation argument in Phase 5 | MEDIUM | LOW | Seriality gives existence; separation follows from order |

## Implementation Phases

### Phase 0: Fix Codebase - Add Seriality Axioms [COMPLETED]

- **Dependencies:** None
- **Goal:** Fix broken build by adding seriality axioms and updating downstream references

**This is the NEW CRITICAL PHASE that unblocks Phase 5.**

#### Part A: Add Seriality Axioms to Axioms.lean

Add two new axiom constructors:
```lean
| seriality_future : Axiom (Formula.some_future (Formula.neg Formula.bot))
| seriality_past : Axiom (Formula.some_past (Formula.neg Formula.bot))
```

Update classification functions:
- `isDenseCompatible`: Add `seriality_future`, `seriality_past` -> `true`
- `isDiscreteCompatible`: Add `seriality_future`, `seriality_past` -> `true`
- `isBase`: Add `seriality_future`, `seriality_past` -> `true` (or dense-only?)

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean` (~30 lines)

#### Part B: Add Soundness Proofs

Add soundness cases in:
- `axiom_base_valid` (if `isBase = true`)
- `axiom_valid_dense` (for dense frames)
- `axiom_valid_discrete` (for discrete frames)

The soundness proof needs `NoMaxOrder D` and `NoMinOrder D` constraints, which follow from `AddCommGroup D` (every group has no max/min).

**Files to modify:**
- `Theories/Bimodal/Semantics/Soundness.lean` (~40 lines)

#### Part C: Fix ~30 Downstream References

**Pattern Analysis** (from research-024):

| Pattern | Files | Count | Fix Strategy |
|---------|-------|-------|--------------|
| `mcs_has_F_top` proof | CanonicalCompleteness | 2 | Rewrite using seriality axiom directly |
| `mcs_has_P_top` proof | CanonicalCompleteness | 2 | Rewrite using seriality axiom directly |
| T-axiom for coherence | DovetailingChain | ~20 | Analyze if truly needed; may need FMCS fix |
| T-axiom in ChainFMCS | ChainFMCS | 1 | Same as DovetailingChain |
| T-axiom in InteriorOperators | InteriorOperators | 4 | Likely for G(phi)->phi; may not be needed |

**Key insight**: With irreflexive semantics, the truth lemma does NOT require `G(phi) in M(t) -> phi in M(t)`. The quantification is `forall s > t`, not `forall s >= t`. So many of the T-axiom uses may be eliminable.

**FMCS Coherence Conditions**: If the FMCS definition uses `t <= t'` for `forward_G` coherence, change to `t < t'` to align with irreflexive semantics.

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` (~20 lines)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (~50 lines, analysis needed)
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` (~10 lines)
- `Theories/Bimodal/Metalogic/Bundle/InteriorOperators.lean` (~20 lines)
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (if coherence fix needed) (~10 lines)

**Timing:** 4-6 hours (most complex phase due to downstream analysis)

**Verification:**
- `lake build` passes for all modified files
- `grep -rn "temp_t_future\|temp_t_past" Theories/` returns empty (active code only; dead code refs remain)
- All axiom soundness proofs complete

**Progress:**

**Session: 2026-03-10, sess_1741536600_i956v6**
- Added: `seriality_future`, `seriality_past` axioms to Axioms.lean
- Added: `[Nontrivial D]` to `valid_dense` and `valid_discrete` in Validity.lean
- Added: `seriality_future_valid`, `seriality_past_valid` soundness proofs
- Added: seriality cases in `axiom_swap_valid`, `axiom_locally_valid`, `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete`
- Fixed: `GContent_consistent_of_fragment` using seriality + forward_F_stays_in_fragment
- Fixed: `HContent_consistent_of_fragment` using seriality + backward_P_stays_in_fragment
- Fixed: `mcs_has_F_top` simplified to 1-line axiom application
- Fixed: `mcs_has_P_top` simplified to 1-line axiom application
- Sorries: 0 -> 0 (no change, all proofs complete)

---

### Phase 1: Verify Existing Infrastructure [COMPLETED]

(Same as v005 - already completed in prior implementation)

- Stages 1-3 (Lindenbaum, BidirectionalFragment, LinearOrder) verified sorry-free
- `RestrictedFragment.lean` created with Countable instance

**Status**: Preserved from prior run

---

### Phase 2: Define Restricted Countable Fragment [COMPLETED]

(Same as v005 - already completed in prior implementation)

- `WitnessReachable` inductive type defined
- `RestrictedFragment` subtype defined
- `Countable RestrictedFragment` proven
- Forward/backward closure proven

**Status**: Preserved from prior run

---

### Phase 3: Prove Totality on Restricted Fragment [COMPLETED]

(Same as v005 - already completed in prior implementation)

- `LinearOrder RestrictedQuotient` proven via antisymmetrization

**Status**: Preserved from prior run

---

### Phase 4: Prove DenselyOrdered on Restricted Fragment [NOT STARTED]

- **Dependencies:** Phase 0, Phase 3
- **Goal:** Prove density using DN axiom

(Same strategy as v005 - this is still the hard blocker)

**Options:**
- Option A: MCS-level density (preferred)
- Option B: Double-seed approach (fallback)
- Option C: Mark [BLOCKED] if both fail

**Timing:** 4-6 hours

**Status:** Same risk as v005

---

### Phase 5: Prove No Endpoints [NOT STARTED] (NOW UNBLOCKED)

- **Dependencies:** Phase 0 (seriality axioms), Phase 3
- **Goal:** Prove `NoMinOrder` and `NoMaxOrder` for RestrictedQuotient

**Mathematical Argument (revised for seriality)**:
1. `seriality_future` is an axiom: `F(neg bot)`
2. Every MCS M contains all theorems, including `F(neg bot)`
3. Therefore `F(neg bot) in M` for all M in RestrictedFragment
4. By `forward_F_stays_in_restricted_fragment`, there exists M' with CanonicalR M M'
5. In the quotient, `[M] < [M']` (strict ordering)
6. This proves `NoMaxOrder`
7. Symmetric argument for past using `seriality_past`

**Key lemma to prove:**
```lean
lemma mcs_has_F_top (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.seriality_future)
```

**Tasks:**
- [ ] Verify `mcs_has_F_top` proof works with seriality axiom
- [ ] Verify `mcs_has_P_top` proof works with seriality axiom
- [ ] Prove `no_max_order_restricted : NoMaxOrder RestrictedQuotient`
- [ ] Prove `no_min_order_restricted : NoMinOrder RestrictedQuotient`

**Strict separation argument**: Even with `F(neg bot) in M`, we need the successor M' to be STRICTLY greater in the quotient ordering. This follows because:
- CanonicalR M M' with M != M' implies strict ordering in the antisymmetrization
- `F(neg bot)` gives a genuine F-witness, not the same MCS

**Timing:** 1-2 hours (was blocked, now straightforward)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (complete Phase 5 sorries)

**Verification:**
- `NoMinOrder RestrictedQuotient` and `NoMaxOrder RestrictedQuotient` instances
- `grep -n "\bsorry\b" RestrictedFragment.lean` returns empty for Phase 5 lemmas

---

### Phases 6-11: Same as v005

(Cantor isomorphism, TaskFrame, Truth Lemma, Completeness)

All depend on Phase 0 completion. Structure unchanged from v005.

---

## Summary of Changes from v005

| Aspect | v005 | v006 |
|--------|------|------|
| Phase 5 status | [BLOCKED] - temp_a misidentified | [NOT STARTED] - seriality axioms |
| New Phase 0 | N/A | Add seriality axioms + fix downstream |
| T-axiom assumption | Assumed present | Correctly identified as removed |
| Estimated total effort | 18-22h | 20-25h (Phase 0 adds ~4h) |
| Hard blockers | 2 (density + no-endpoints) | 1 (density only) |

## Artifacts & Outputs

**New Files:**
- Phase 0 modifies ~5 existing files

**Modified Files (from v005):**
- All Phase 0 targets
- `RestrictedFragment.lean` Phase 5 completion

**Summary:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Testing & Validation

### For Phase 0 (Critical)
- [ ] `lake build Bimodal.ProofSystem.Axioms` passes
- [ ] `lake build Bimodal.Semantics.Soundness` passes
- [ ] `lake build Bimodal.Metalogic.Bundle.CanonicalCompleteness` passes
- [ ] `grep -rn "temp_t_future\|temp_t_past" Theories/` returns empty
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms (only Axiom constructors)

### For Full Implementation
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty
- [ ] All proofs verified

## Rollback/Contingency

1. **Phase 0 harder than expected**: The ~30 downstream fixes may reveal deeper issues with the irreflexive semantics. If so, document and escalate.

2. **FMCS coherence needs full redesign**: If changing `<=` to `<` breaks fundamental FMCS properties, this may require more research.

3. **Phase 4 (density) still blocked**: Same as v005 - mark as single documented sorry.

## Philosophical Note

The seriality axioms (`F(neg bot)`, `P(neg bot)`) are the standard temporal logic approach for "no endpoints." This aligns with:
- Modal D-axiom tradition
- Goldblatt (1992) treatment
- Stanford Encyclopedia of Philosophy recommendation

The T-axiom approach (reflexive semantics) is the minority position and conflicts with the density proof architecture already built.
