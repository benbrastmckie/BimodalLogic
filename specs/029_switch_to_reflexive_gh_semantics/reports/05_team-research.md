# Research Report: Task #29 (Wave 2)

**Task**: Switch TM metalogic to reflexive G/H semantics
**Date**: 2026-03-22
**Mode**: Team Research (3 teammates)
**Session**: sess_1774165827_1e7491
**Focus**: Prerequisites for the switch, impact on open tasks, and refactoring strategy validation

---

## Executive Summary

Three teammates investigated complementary angles of the reflexive semantics switch: prerequisite ordering (A), completeness pipeline impact (B), and refactoring risk analysis (C). The unanimous finding is that **Task 29 should proceed BEFORE tasks 18, 22, and 24** — not after. The switch fundamentally changes which completeness work needs to be done, and work under strict semantics would be partially or entirely invalidated.

The most significant finding is a **conflict between teammates on Task 18's fate**:
- Teammate A says Task 18 should wait but remains relevant (sorries are semantics-independent)
- Teammate B argues Task 18 is **subsumed** — dense completeness collapses into base completeness under reflexive semantics

This conflict is resolved below in favor of **partial subsumption**: the separate dense completeness theorem is no longer needed (Teammate B is correct), but the DovetailedTimelineQuot infrastructure remains valuable as it provides the concrete `D = TimelineQuot ≃o ℚ` characterization from syntax — a mathematical result worth preserving even if not required for completeness.

The existing 7-phase plan is architecturally sound but **significantly underscoped**:
- Phase 5 has ~35 call sites across 11 files (plan assumed a small wrapper change)
- Phase 6 addresses only 1 of 8+ axioms added since the plan was written
- A new **Phase 0** (enumeration) is recommended before starting

---

## Key Findings

### 1. Task Ordering: Task 29 First (All Three Teammates Agree)

| Task | Recommendation | Rationale |
|------|---------------|-----------|
| **29** | **DO FIRST** | No prerequisites among open tasks; creates cleaner foundation |
| **26** | **ABANDON** (superseded) | Task 29 Phase 5 entirely subsumes Task 26's objective |
| **18** | AFTER or DEPRIORITIZE | Dense completeness collapses to base; TimelineQuot infra optional |
| **22** | AFTER (low priority) | FMCS signature changes require rebuild; `DirectMultiFamilyBFMCS` already deployed |
| **24** | AFTER (reduced scope) | `discreteImmediateSuccSeed_consistent_axiom` proven by Task 29 Phase 6; 2 axioms remain |
| **997** | AFTER | FMCS signature repair needed; core sorries unaffected by switch |

### 2. Frame Class Collapse (Teammate B, confirmed by A)

Under reflexive semantics, ALL four extension axioms become trivially valid on any linear order:

| Axiom | Trivial Proof Under Reflexive |
|-------|-------------------------------|
| DN: `GGφ → Gφ` | Take r = t in `∀ s ≥ t, ∀ r ≥ s, φ(r)` |
| DF: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` | s = t witnesses F(Hφ) |
| SF: `Gφ → Fφ` | T-axiom: φ(t) witnesses Fφ |
| SP: `Hφ → Pφ` | T-axiom: φ(t) witnesses Pφ |

**Consequence**: Three-variant completeness (Base/Dense/Discrete) reduces to ONE theorem. Tasks 18 and 24 lose their primary motivation.

### 3. FMCS Is Currently STRICT, Not Reflexive (Teammate B — corrects existing documentation)

The ROAD_MAP.md and FMCSDef.lean docstrings claim reflexive coherence, but the actual Lean code uses strict `<`:
```lean
forward_G : forall t t' phi, t < t' -> ...  -- STRICT
backward_H : forall t t' phi, t' < t -> ... -- STRICT
```
This is a code/documentation inconsistency from the Task 991 reversion. The switch to reflexive requires changing these to `≤`.

### 4. Phase 5 Blast Radius (Teammate C — critical finding)

`canonicalR_irreflexive` is called at **~35 sites across 11 files**. The proof pattern at each site proves `CanonicalR M M → False` to establish strict ordering. Under reflexive semantics, `CanonicalR M M` is TRUE (T-axiom), so these proofs must be **fundamentally rearchitected**, not just have a lemma swapped.

Most dangerous sites:
- `DovetailedTimelineQuot.lean` (~12 sites, also has 4 pre-existing sorries)
- `SaturatedChain.lean` (~6 sites)
- `CantorApplication.lean` (~4 sites)
- `FMCSTransfer.lean` (contains `lt_of_canonicalR` — critical for completeness pipeline)

### 5. Axiom Coverage Gap (Teammate C — critical finding)

The plan addresses 2 axioms. The codebase now has **10 axioms** total (3 existed at plan time + 7 added by tasks 23/28):

| Axiom | File | Plan Status | Under Reflexive |
|-------|------|-------------|-----------------|
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean | Phase 5: REMOVE | Becomes FALSE |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean | Phase 6: PROVE | Provable via T-axiom |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean | Accepted debt | Unaffected |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean | **NOT IN PLAN** | Possibly provable |
| `succ_chain_fam_p_step` | SuccChainFMCS.lean | **NOT IN PLAN** | Unaffected |
| `f_nesting_boundary` | SuccChainFMCS.lean | **NOT IN PLAN** | Unaffected |
| `p_nesting_boundary` | SuccChainFMCS.lean | **NOT IN PLAN** | Unaffected |
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean | **NOT IN PLAN** | Possibly provable via T-axiom |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean | **NOT IN PLAN** | Possibly provable via T-axiom |
| `predecessor_f_step_axiom` | SuccExistence.lean | **NOT IN PLAN** | Unaffected |

### 6. Sorry Impact (Teammate A — confirmed by C)

The dense completeness sorries (DovetailedTimelineQuot j>0 termination, ClosureSaturation forward_F/backward_P) are **semantics-independent**. The reflexive switch neither helps nor hinders them. They stem from termination/well-foundedness and modal saturation issues, not from strict vs reflexive semantics.

---

## Synthesis: Conflicts Resolved

### Conflict 1: Does Task 18 Become Irrelevant?

**Teammate A**: Task 18 should wait but remains relevant (sorries are semantics-independent)
**Teammate B**: Task 18 is subsumed — dense completeness collapses into base

**Resolution**: Teammate B is mathematically correct that a separate dense completeness theorem is no longer needed. However, Teammate A is correct that the TimelineQuot infrastructure has independent mathematical value (D-from-syntax characterization).

**Practical decision**: Task 18's primary goal (wire `valid_dense φ → ⊢_dense φ`) becomes unnecessary. The remaining value is the `TimelineQuot ≃o ℚ` result, which is already proven and doesn't need wiring. **Task 18 should be deprioritized or marked as reduced-scope** — the D-from-syntax result stands on its own.

### Conflict 2: Is Phase 5 Manageable?

**Plan (2.5 hours)** vs **Teammate C (4+ hours, HIGH risk)**

**Resolution**: Teammate C's analysis is compelling — 35 call sites across 11 files, each requiring proof restructuring (not just lemma swapping), is a significant undertaking. The plan should be revised to add Phase 0 (enumeration) and expand Phase 5 budget to 4-5 hours.

### No Conflict on: Task 26 Supersession

All three teammates agree Task 26 is entirely superseded by Task 29 Phase 5.

---

## Recommended Strategy

### Revised Plan: 9 Phases (Add Phase 0, Expand Phases 5-6)

**Phase 0: Enumeration and Pattern Catalog** (NEW, 2 hours)
- Enumerate all ~35 `canonicalR_irreflexive` call sites
- Categorize each: NoMaxOrder, NoMinOrder, DenselyOrdered, strict antisymmetry, other
- Draft replacement argument for each category under reflexive semantics
- Assess all 10 axioms for provability under T-axiom

**Phase 1: Core Semantic Change** (1.5 hours — as planned)
- Truth.lean: `<` → `≤`
- Axioms.lean: add `temp_t_future`, `temp_t_past`

**Phase 2: FMCS Structure Update** (1 hour — as planned)
- FMCSDef.lean: `forward_G`/`backward_H` to `≤`
- TemporalCoherence.lean: signature updates

**Phase 3: Soundness Proof Repairs** (2 hours — as planned)
- Fix `temp_4_valid`, `temp_a_valid`, `temp_l_valid`
- Add `temp_t_future_valid`, `temp_t_past_valid`
- Simplify `density_valid`, `discreteness_*_valid`

**Phase 4: Truth Lemma Adjustment** (1.5 hours — as planned, minor expansion)
- ParametricTruthLemma.lean: G/H forward cases handle `s = t`
- Check DenseInstantiation.lean for any strict-`<` logic

**Phase 5: Axiom Removal and Downstream Repair** (EXPANDED, 5 hours)
- Remove `canonicalR_irreflexive_axiom`
- Add `canonicalR_reflexive` and `canonicalR_antisymmetric`
- Fix all ~35 call sites across 11 files
- Critical: redesign `lt_of_canonicalR` in FMCSTransfer.lean
- Budget extra time for DovetailedTimelineQuot.lean (~12 sites)

**Phase 6: Additional Axiom Conversion** (EXPANDED, 2 hours)
- Prove `discreteImmediateSuccSeed_consistent_axiom` via T-axiom
- Assess and attempt `discreteImmediateSucc_covers_axiom`
- Assess `successor_deferral_seed_consistent_axiom` / `predecessor_deferral_seed_consistent_axiom`
- Document remaining axioms as semantics-independent (nesting bounds, discrete finiteness)

**Phase 7: Frame Class Simplification** (NEW, 1.5 hours)
- Collapse `FrameClass` enum or document degenerate state
- Update `isDenseCompatible`/`isDiscreteCompatible` predicates
- Simplify completeness theorem architecture (three → one)

**Phase 8: Documentation and Final Verification** (1 hour — former Phase 7)
- Resolve ROAD_MAP.md documentation conflict
- Update axiom count in TODO.md frontmatter
- Full `lake build` verification
- Create implementation summary

**Revised total estimate**: 17-18 hours (up from 12)

### Task Pipeline After Task 29

1. **Task 26**: Mark ABANDONED (superseded)
2. **Task 18**: Reduce scope to "preserve D-from-syntax result" or mark EXPANDED
3. **Task 24**: Reduce scope — only `discrete_Icc_finite_axiom` and `discreteImmediateSucc_covers_axiom` remain
4. **Task 997**: Resume with reflexive FMCS signatures
5. **Task 22**: Low priority, `DirectMultiFamilyBFMCS` already deployed

---

## Gaps Identified

1. **NoMaxOrder/NoMinOrder proof strategy under reflexive semantics**: This is the biggest unknown. Currently these use `canonicalR_irreflexive` to show seriality witnesses are strictly greater. Under reflexive semantics, a different approach is needed (likely: seriality gives `CanonicalR M N`, but the naming/blocking construction ensures `M ≠ N`). This needs investigation in Phase 0.

2. **`lt_of_canonicalR` redesign**: This critical function in FMCSTransfer.lean derives `a < b` from `CanonicalR a.world b.world` using irreflexivity. Under reflexive semantics it needs guards (`a ≠ b` hypothesis or separate handling of the `a = b` case). Impact on transfer_forward_F and transfer_backward_P is unclear.

3. **SuccChainFMCS axioms**: The 3 nesting/step axioms (`succ_chain_fam_p_step`, `f_nesting_boundary`, `p_nesting_boundary`) are semantics-independent but are unaddressed technical debt. They should be documented in the revised plan as out-of-scope.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Prerequisites | completed | high | Task 29 first; Task 26 superseded; sorries semantics-independent |
| B | Completeness pipeline | completed | high | Frame class collapse; Task 18 subsumed; FMCS is strict (corrects docs) |
| C | Risk analysis | completed | medium | Phase 5 has ~35 sites; 7 axioms not in plan; recommends Phase 0 |

---

## References

- specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-a-findings.md
- specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-b-findings.md
- specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-c-findings.md
- specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md (Wave 1)
- specs/029_switch_to_reflexive_gh_semantics/reports/02_historical-issues-analysis.md
- specs/029_switch_to_reflexive_gh_semantics/plans/01_reflexive-semantics-refactoring.md
