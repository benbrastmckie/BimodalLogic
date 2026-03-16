# Research Report: Task #964 (Reflexive G/H Semantics Feasibility Analysis)

**Task**: 964 - resolve_atom_type_freshness_debt
**Started**: 2026-03-14T12:00:00Z
**Completed**: 2026-03-14T13:30:00Z
**Effort**: 1.5 hours focused analysis
**Dependencies**: research-005.md (blocker analysis), research-006.md (team proof analysis)
**Sources/Inputs**: Codebase (Truth.lean, Axioms.lean, Soundness.lean, DensityFrameCondition.lean, DenseTimeline.lean, CantorPrereqs.lean), ROAD_MAP.md, prior research reports
**Artifacts**: specs/964_resolve_atom_type_freshness_debt/reports/research-007.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

This report provides a fresh analysis of what would be required to switch G/H temporal semantics from irreflexive (strict <) to reflexive (non-strict ≤), per user request. The analysis focuses on specific implementation requirements and blockers.

**Key Findings**:

1. **Semantic change is trivial** (2 lines in Truth.lean)
2. **T-axiom addition is straightforward** (2 new axioms + 2 soundness proofs)
3. **Density axiom does NOT trivialize** under reflexive semantics (the "obvious" concern is unfounded)
4. **The real blockers are in density proof STRUCTURE**, not density axiom semantics
5. **ROAD_MAP.md Dead End is justified** - prior 3-month effort hit fundamental obstructions

**Recommendation**: DO NOT pursue reflexive refactoring. The blockers are real and the prior Dead End decision was correct. The current irreflexive architecture works; the `canonicalR_irreflexive` axiom is unused and documented.

## Context & Scope

### User Request

The user explicitly asked:
> "Research what it would take to revise the semantics to make G and H reflexive (changing the ROAD_MAP.md to avoid blocking this) in order to implement the Standard T-axiom path. Look to identify any potential blockers that would arise."

### What "Reflexive G/H" Means

**Current (irreflexive)**:
```lean
-- Truth.lean lines 118-119
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

**Proposed (reflexive)**:
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

This change makes:
- `G(φ)` mean "φ holds now AND at all future times"
- `H(φ)` mean "φ holds now AND at all past times"
- T-axioms `G(φ) → φ` and `H(φ) → φ` become valid

## Findings

### 1. What "Making G and H Reflexive" Specifically Requires

#### 1.1 Truth.lean Changes (Trivial)

Change two lines (118-119):
```lean
-- FROM:
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ

-- TO:
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

**Effort**: 5 minutes

#### 1.2 Axioms.lean: Add T-Axioms

Add two new axiom constructors:
```lean
/-- Temporal T-axiom (future): `G(φ) → φ` (reflexivity). -/
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)

/-- Temporal T-axiom (past): `H(φ) → φ` (reflexivity). -/
| temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)
```

**Effort**: 30 minutes (including doc comments)

#### 1.3 Soundness.lean: Add T-Axiom Soundness Proofs

```lean
/-- Temporal T-axiom (future) is valid under reflexive semantics: `⊨ G(φ) → φ`. -/
theorem temp_t_future_valid (φ : Formula) : ⊨ ((Formula.all_future φ).imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future
  exact h_future t (le_refl t)

/-- Temporal T-axiom (past) is valid under reflexive semantics: `⊨ H(φ) → φ`. -/
theorem temp_t_past_valid (φ : Formula) : ⊨ ((Formula.all_past φ).imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_past
  exact h_past t (le_refl t)
```

**Effort**: 1 hour (including testing)

### 2. What Would ROAD_MAP.md Changes Look Like

#### 2.1 Transitioning the Dead End

The current "Dead End: Reflexive G/H Semantics Switch" (lines 585-607) would need to be:
1. Moved to a new strategy entry "Strategy: Reflexive G/H Semantics"
2. Status changed from "ABANDONED" to "ACTIVE"
3. The "Why It Failed" section preserved as historical context

#### 2.2 New Dead End for Irreflexive Semantics

A new Dead End would document the current approach:
```markdown
### Dead End: Irreflexive G/H Semantics

**Status**: SUPERSEDED
**Tried**: 2026-03-09 to {current_date}
**Related Tasks**: Task 956, Task 964

*Rationale*: Attempted to avoid T-axioms by using strict temporal semantics.

**What We Tried**:
Irreflexive G/H semantics where G quantifies over t' > t (strict future). This made density proofs cleaner but created `canonicalR_irreflexive` obstruction.

**Why Superseded**:
canonicalR_irreflexive is unprovable without T-axiom. While the axiom is unused in practice, it represents a gap in the proof architecture. Switching to reflexive semantics eliminates this gap.

**Superseded By**: Reflexive G/H Semantics
```

#### 2.3 Density Proof Challenge

The key challenge would need to be documented as an "Active Investigation":
```markdown
### Investigation: Density Proof Under Reflexive Semantics

**Status**: ACTIVE
**Started**: {date}

*Challenge*: The density proof architecture in DensityFrameCondition.lean relies on strict ordering for distinguishing formulas. Under reflexive semantics, the case analysis structure changes.

**Approach**: ...
```

### 3. Blockers Analysis (The Core Question)

#### Blocker 1: Density Axiom `F(φ) → F(F(φ))` Under Reflexive Semantics

**Concern**: Does the density axiom trivialize when F is reflexive?

**Analysis**:
- `F(φ)` under IRREFLEXIVE semantics: `∃ s > t, φ(s)` - strict future witness
- `F(φ)` under REFLEXIVE semantics: `∃ s ≥ t, φ(s)` - non-strict future witness

**Key Insight**: The density axiom `F(φ) → F(F(φ))` does NOT trivialize:
- Premise: ∃ s ≥ t, φ(s) (some s at or after t has φ)
- Conclusion: ∃ u ≥ t, ∃ v ≥ u, φ(v) (some u at or after t has F(φ))

This is NOT trivially true. We need an intermediate witness u between t and s. The density frame condition (DenselyOrdered) is still required.

**However**: The Soundness.lean proof of `density_valid` (lines 271-284) uses:
```lean
obtain ⟨u, htu, hus⟩ := DenselyOrdered.dense t s hts
```
where `hts : t < s` (strict ordering). With reflexive semantics, the witness s might equal t (`s ≥ t` admits `s = t`), and there's no intermediate point between t and t.

**Impact**: The soundness proof structure changes. When the witness s = t, density is trivially satisfied (take u = t). When s > t, the existing proof works.

**Verdict**: NOT a mathematical impossibility, but soundness proof needs restructuring.

#### Blocker 2: Density Frame Condition Proof Structure

**Current proof** (DensityFrameCondition.lean, 40+ lines):

The `density_frame_condition` theorem uses this structure:
1. Get distinguishing formula δ with `G(δ) ∈ M'` and `δ ∉ M`
2. Case split on `G(δ) ∈ M`:
   - **Case A**: `G(δ) ∉ M` → `F(¬δ) ∈ M` → double-density trick
   - **Case B**: `G(δ) ∈ M` → sub-split on reflexivity of M'

**Under reflexive semantics with T-axiom**:

Case B becomes problematic:
- If `G(δ) ∈ M` and T-axiom is valid, then in any model satisfying TM, `δ` must hold wherever `G(δ)` holds
- At the MCS level: If M is "G-reflexive" (GContent(M) ⊆ M), then `G(δ) ∈ M` implies `δ ∈ M`
- But δ is the distinguishing formula with `δ ∉ M`
- So `G(δ) ∈ M` is impossible if M is G-reflexive

**Impact**: The case analysis simplifies because Case B disappears when M is reflexive. But the proof structure fundamentally changes.

**Verdict**: MAJOR rewrite required. The existing 40+ line proof needs complete restructuring.

#### Blocker 3: DenseTimeline Construction Witnesses

**Current behavior** (DenseTimeline.lean):
```lean
noncomputable def densityWitnessesForSet
    (S : Finset StagedPoint) (stage : Stage) : Finset StagedPoint :=
  S.biUnion fun a =>
    S.biUnion fun b =>
      if h : CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs then
        {densityIntermediatePoint a b h.1 h.2 stage}
      else ∅
```

The condition `CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs` identifies STRICTLY ordered pairs (a < b in the preorder sense).

**Under reflexive semantics**:
- `CanonicalR M M` becomes more common (any MCS satisfying GContent(M) ⊆ M is reflexive)
- The distinction between "reflexive" and "irreflexive" MCSs affects witness construction
- Current code handles this via `density_frame_condition_reflexive_source` variant

**Impact**: The construction logic may need adjustment, but the fundamental approach survives.

**Verdict**: MEDIUM effort - code adjustments, not fundamental restructuring.

#### Blocker 4: Seriality Proofs

**Current seriality axioms** (Axioms.lean lines 349, 366):
- `F(¬⊥)` - there exists a future time (NoMaxOrder)
- `P(¬⊥)` - there exists a past time (NoMinOrder)

**Under reflexive semantics**:
- `F(¬⊥)` becomes trivially true: take witness s = t, `¬⊥` holds at t
- Similarly for `P(¬⊥)`

**Impact**: Seriality axioms become tautological. The proofs for NoMaxOrder/NoMinOrder in CantorPrereqs.lean need different justification.

**BUT**: With reflexive semantics, seriality is NOT needed for the same purposes:
- T-axioms guarantee that G-obligations are satisfied at the current time
- The "endpoint" problem (no strict future/past) doesn't exist because reflexivity covers the current time

**Verdict**: Seriality axioms can be REMOVED from the axiom system. Proofs that used them need restructuring.

#### Blocker 5: The Original Reason (From ROAD_MAP.md)

ROAD_MAP.md (lines 596-597):
> "Reflexive semantics makes density proofs harder: between w₁ ≤ w₂, there may be no STRICTLY intermediate point when w₁ = w₂. The density axiom DN requires strict ordering to force intermediate MCS existence."

**Analysis**: This is the core issue. The density proof architecture was designed around:
1. Strict ordering for witness construction
2. Case analysis on whether MCSs are "reflexive" vs "irreflexive"
3. The "double-density trick" using F(F(¬δ)) to create intermediate points

Under reflexive semantics:
- All MCSs are trivially "G-reflexive" (GContent(M) ⊆ M by T-axiom)
- The case analysis collapses
- The distinction between "reflexive" and "irreflexive" MCSs disappears
- New proof structure needed

**Verdict**: This is the fundamental obstruction. Not impossible, but requires new proof architecture.

### 4. Benefit Analysis (What We'd Gain)

#### 4.1 canonicalR_irreflexive Becomes Provable

From research-006.md, the standard Gabbay IRR proof requires:
```
Step 6: H(¬p) ∈ M' --[T-axiom: H(φ)→φ]--> ¬p ∈ M'
```

With T-axiom added, this step becomes trivial. The 2 sorries in CanonicalIrreflexivity.lean would be resolved.

#### 4.2 Standard Literature Proof Techniques Become Available

All standard references (Gabbay 1981, Goldblatt 1992, BdRV 2001) use reflexive temporal semantics. With reflexive semantics:
- IRR rule becomes usable
- Naming set constructions work as in literature
- Existing proofs can be adapted directly

#### 4.3 Alignment with Standard Presentations

The TM logic would align with standard temporal logic presentations:
- G/H as universal quantifiers over non-strict future/past
- F/P as existential quantifiers
- T-axioms as fundamental modal-temporal axioms

### 5. Risk Assessment

| Risk | Probability | Impact | Analysis |
|------|-------------|--------|----------|
| Density proof restructure fails | LOW (20%) | BLOCKING | New proof structure exists in literature (Goldblatt Ch. 7) |
| Cascading breakage in staged construction | MEDIUM (50%) | HIGH | Extensive debugging required |
| New soundness gaps discovered | LOW (10%) | MEDIUM | T-axiom soundness is straightforward |
| Timeline construction produces wrong witnesses | LOW (15%) | MEDIUM | Logic is correct, just code adjustment |
| Effort exceeds estimate | HIGH (70%) | MEDIUM | Complex proof restructuring is unpredictable |

**Overall Risk**: MEDIUM-HIGH. The refactor is mathematically sound but practically challenging.

### 6. Comparison with Current Blockers

| Issue | Current (Irreflexive) | Reflexive Refactor |
|-------|----------------------|-------------------|
| canonicalR_irreflexive | Unprovable but UNUSED | Provable via T-axiom |
| Density axiom | Has semantic content | Still has content (witness may equal t) |
| Density frame condition | 40-line proof, complete | REQUIRES REWRITE |
| Seriality | Semantic content | TRIVIALIZES (T-axiom covers) |
| Literature alignment | Non-standard | Standard |
| Total effort to completion | 0 hours (architecture complete) | 40-100 hours |

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Reflexive G/H Semantics Switch | **DIRECT** | VALIDATES - 3 months of prior effort confirms difficulty |
| Single-History FDSM | Low | Orthogonal - would need similar T-axiom consideration |
| Relational Completeness Detour | Low | Orthogonal |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | **DIRECTLY AFFECTED** - density proof structure changes |
| Indexed MCS Family | ACTIVE | **AFFECTED** - coherence conditions use reflexive ≤ already |
| Representation-First Architecture | CONCLUDED | Would survive but proofs change |

### Key Historical Context

From ROAD_MAP.md lines 587-588:
> **Tried**: 2025-12-01 to 2026-03-09

This represents **over 3 months** of dedicated effort on reflexive semantics before abandonment. The Dead End decision was not made lightly.

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Reflexive vs irreflexive semantics trade-offs | Sections 1-5 | Partial (ROAD_MAP Dead End) | extension |
| T-axiom soundness under reflexive semantics | Section 1.3 | No | new insight |
| Density axiom non-trivialization | Blocker 1 | No | clarification |

### New Context File Recommendations

None needed. This report combined with ROAD_MAP.md Dead End and research-005/006 provides comprehensive documentation.

### Summary

- **New files needed**: 0
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **Reflexive refactor is NOT recommended** - While mathematically feasible, the effort (40-100 hours) vastly exceeds benefit (resolving an unused axiom)

2. **ROAD_MAP.md Dead End is justified** - The 3-month prior effort and this analysis confirm the density proof restructuring challenge

3. **Current architecture is complete** - The `canonicalR_irreflexive` axiom is documented as a frame property assumption, consistent with standard modal logic practice

4. **The "obvious" trivialization concern is unfounded** - Density axiom retains semantic content under reflexive semantics

## Final Recommendation

**DO NOT pursue reflexive G/H semantics refactoring.**

The analysis reveals:

1. **The implementation changes are straightforward** (Truth.lean: 2 lines, Axioms.lean: 2 axioms, Soundness.lean: 2 proofs)

2. **The blockers are in proof architecture**, not syntax:
   - DensityFrameCondition.lean: Complete 40+ line rewrite
   - DenseTimeline.lean: Construction logic adjustment
   - CantorPrereqs.lean: Seriality proof restructuring

3. **Prior 3-month effort validates the difficulty** - The ROAD_MAP.md Dead End decision was correct

4. **The current "problem" is not actually a problem**:
   - `canonicalR_irreflexive` is unused in the completeness chain
   - It's correctly documented as a frame property axiom
   - The architecture is sound and complete

5. **Cost-benefit is extremely unfavorable**:
   - Current path: 0 hours (done)
   - Reflexive refactor: 40-100 hours with 20% risk of failure

Maintain the current irreflexive semantics architecture.

## Appendix

### Search Queries Used

- File reads: Truth.lean, Axioms.lean, Soundness.lean, DensityFrameCondition.lean, DenseTimeline.lean, CantorPrereqs.lean
- Grep: `reflexiv|T.axiom|temp_t` in Theories/Bimodal/
- Prior reports: research-005.md, research-006.md

### Key Code Locations

| File | Purpose | Lines of Interest |
|------|---------|-------------------|
| `Theories/Bimodal/Semantics/Truth.lean` | Semantics definition | 118-119 (< vs ≤) |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | Axiom definitions | No T-axioms currently |
| `Theories/Bimodal/Metalogic/Soundness.lean` | Axiom soundness | Lines 271-284 (density_valid) |
| `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` | Density proof | Lines 198-239 (40+ lines) |
| `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` | Timeline construction | Lines 128-145 |
| `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` | Cantor prerequisites | Lines 60-68 (density iteration) |

### References

- Gabbay, D.M. (1981). *An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames*. Springer.
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge.
- ROAD_MAP.md Dead End: "Reflexive G/H Semantics Switch" (lines 585-607)
- research-005.md: Reflexive refactor blocker analysis
- research-006.md: Team proof strategy analysis
