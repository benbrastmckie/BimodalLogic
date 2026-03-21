# Research Report: Historical Issues with Reflexive G/H Semantics

**Task**: 29 - Switch TM metalogic to reflexive G/H semantics
**Date**: 2026-03-21
**Focus**: What went wrong before with reflexive semantics? Are those difficulties still relevant?
**Session**: sess_1774129542_033abf

---

## Executive Summary

Reflexive G/H semantics (`≤` instead of `<`) has been adopted, abandoned, and re-adopted across three major task cycles. The history reveals **three distinct issues** that caused the reversion to strict semantics (Task 991). Two of these are now understood to be **non-problems**, and the third has a **known resolution** under reflexive semantics. The current codebase also contains a documentation/code inconsistency: ROAD_MAP.md says reflexive semantics is "ADOPTED", but Truth.lean uses strict semantics.

**Bottom line**: The historical difficulties with reflexive semantics are either resolved or were misidentified. Switching back is viable.

---

## 1. Complete Timeline

| Date | Task | Action | Semantics After |
|------|------|--------|-----------------|
| 2025-12-01 | (initial) | Reflexive semantics used in original codebase | Reflexive (`≤`) |
| 2026-03-09 | Task 956 | Abandoned reflexive — perceived density proof obstruction | Strict (`<`) |
| 2026-03-14 | Task 967 | Re-adopted reflexive — density concern shown unfounded | Reflexive (`≤`) |
| 2026-03-18 | Task 991 | Reverted to strict — frame class separation motivation | Strict (`<`) |
| 2026-03-21 | Task 29 | Researching switch back to reflexive | (pending) |

---

## 2. Historical Issue #1: Perceived Density Proof Obstruction

### When It Arose

Task 956 (2026-03-09) abandoned reflexive semantics based on the concern that density proofs would be harder: "between w₁ ≤ w₂, there may be no STRICTLY intermediate point when w₁ = w₂."

### What Actually Happened

Task 967's research-002.md (2026-03-14) demonstrated this concern was **unfounded**:

> "Density does NOT trivialize under reflexive semantics — DN axiom still forces intermediate MCSs."

The density axiom DN (`GGφ → Gφ`) operates on strict ordering BETWEEN distinct MCSs. Whether the temporal operators use `≤` or `<` is independent of whether there exists a distinct MCS M'' between M and M' in the canonical model.

### Current Relevance: **NON-ISSUE**

This concern was thoroughly debunked. The ROAD_MAP.md documents the lesson:

> "Initial analysis of semantic consequences was incomplete. The density axiom DN operates on strict ordering BETWEEN MCSs, which is independent of whether temporal operators use reflexive or irreflexive quantification."

**Source**: ROAD_MAP.md lines 724-748 ("Revised Approach: Reflexive G/H Semantics")

---

## 3. Historical Issue #2: Frame Class Collapse

### When It Arose

Task 991 (2026-03-18) identified that under reflexive semantics, the three-variant TM logic structure (Base / Dense / Discrete) collapses to a single logic because extension axioms become trivially valid.

### Technical Detail

Under reflexive semantics, ALL four extension axioms are trivially valid on any linear order:

| Axiom | Current Frame Requirement | Under Reflexive | Proof |
|-------|--------------------------|-----------------|-------|
| DN: `GGφ → Gφ` | DenselyOrdered | Universal | Take r = t in `∀s ≥ t. ∀r ≥ s. φ(r)` |
| DF: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` | SuccOrder | Universal | s = t witnesses F(Hφ) |
| SF: `Gφ → Fφ` | NoMaxOrder | Universal | T-axiom: φ(t) witnesses Fφ |
| SP: `Hφ → Pφ` | NoMinOrder | Universal | T-axiom: φ(t) witnesses Pφ |

Task 991's synthesis report concluded:

> "The temporal logic literature predominantly uses strict semantics as the mathematical standard... For mathematical logic and representation theorems, strict semantics is correct."

### Why Task 991 Considered This Fatal

The motivation was to preserve **genuine frame class separation**: density, seriality, and discreteness should characterize distinct frame classes with distinct mathematical content. Under reflexive semantics, these distinctions collapse at the axiom level.

### Current Assessment: **SURMOUNTABLE**

The axiom-level collapse is real but **does not prevent the canonical model construction from working**. The key insight from Task 29's research:

1. **Frame class conditions operate at the canonical model level**, not the axiom level. Even if DN is trivially valid as an axiom schema, the density property of the canonical timeline (existence of intermediate MCSs) is still established by the construction.

2. **The quotient ordering remains non-trivial.** Under reflexive semantics:
   - `CanonicalR M M` holds for all MCS M (reflexive)
   - But `M < N` in the quotient iff `CanonicalR M N ∧ ¬CanonicalR N M`
   - Distinct MCSs with different formula content are genuinely strictly ordered

3. **The BFMCS/FMCS infrastructure already uses reflexive coherence conditions.** FMCSDef.lean's `forward_G` and `backward_H` are documented for reflexive semantics per the "Indexed MCS Family Approach" strategy (ROAD_MAP.md line 64).

**Trade-off**: The three-variant `FrameClass` enum becomes degenerate. All current axiom classification by frame class (`isDenseCompatible`, `isDiscreteCompatible`) would collapse. This is an architectural simplification, not a mathematical problem.

**Source**: Task 29 teammate A findings (01_team-research.md lines 28-39)

---

## 4. Historical Issue #3: Irreflexivity Proof Failure Under Strict Semantics

### When It Arose

Task 991 Phase 4 (2026-03-18) discovered that switching to strict semantics made `canonicalR_irreflexive` unprovable.

### Technical Detail

The Gabbay IRR proof (1254 lines in `CanonicalIrreflexivity.lean`) requires Step 7:

```
7. Apply T-axiom: H(¬p) → ¬p, so ¬p ∈ M'
```

Under strict semantics, the T-axiom `H(φ) → φ` is **invalid** because "φ at all strictly past times" does not entail "φ now." The naming set `{p, H(¬p)}` is semantically consistent under strict semantics (it models "p is true for the first time").

### Resolution Attempts Under Strict Semantics

| Attempt | Result | Source |
|---------|--------|--------|
| temp_a + linearity proof | FAILED — produces closure, not contradiction | 991 revised plan, blocking issue |
| Seriality fallback | FAILED — P(¬p) ≠ ¬p | 991 revised plan line 126-129 |
| van Benthem non-definability | CONFIRMED — irreflexivity not modally definable | 991 report 06 |
| Axiom declaration | ADOPTED — mathematically justified but unsatisfying | Current codebase |

The rigorous analysis (991 report 06) established definitively:

> **Irreflexivity is NOT derivable from the TM axioms under strict semantics.** This is a consequence of the modal non-definability theorem (van Benthem, Blackburn-de Rijke-Venema).

### Current State: 3 Axioms Required Under Strict Semantics

| Axiom | File | Lines | Justification |
|-------|------|-------|---------------|
| `canonicalR_irreflexive_axiom` | `Bundle/CanonicalIrreflexivity.lean:1212` | 1254 total | Semantically true under strict |
| `discreteImmediateSuccSeed_consistent_axiom` | `StagedConstruction/DiscreteSuccSeed.lean:284` | — | Seriality argument |
| `discreteImmediateSucc_covers_axiom` | `StagedConstruction/DiscreteSuccSeed.lean:414` | — | Covering property |

### Current Relevance: **RESOLVED UNDER REFLEXIVE SEMANTICS**

Under reflexive semantics:
- **Axiom 1 (`canonicalR_irreflexive_axiom`)**: Becomes **FALSE and must be removed**. `CanonicalR M M` is TRUE (g_content M ⊆ M by T-axiom). The irreflexivity concept is replaced by **antisymmetry**: `CanonicalR M N ∧ CanonicalR N M → M = N`.
- **Axiom 2 (`discreteImmediateSuccSeed_consistent_axiom`)**: Becomes **PROVABLE**. The blocking formula Case 2 proof completes because g_content(M) ⊆ M (T-axiom enables it).
- **Axiom 3 (`discreteImmediateSucc_covers_axiom`)**: **Needs analysis** — may still require the covering lemma independent of semantic choice, but T-axiom availability may enable the proof.

**Source**: Task 29 teammate B findings (01_teammate-b-findings.md sections 5, 9)

---

## 5. Documentation/Code Inconsistency

The codebase currently has a conflict between documentation and implementation:

### ROAD_MAP.md Says Reflexive

```
### Decision: Reflexive G/H Semantics (Revised)
Date: 2026-03-09 (original decision: irreflexive), 2026-03-14 (revised: reflexive)
Decision: Temporal operators G and H use REFLEXIVE semantics (≤ ordering)
Current Status: Reflexive G/H semantics adopted per Task 967
```

(ROAD_MAP.md lines 245-748)

### Truth.lean Says Strict

```
Strict Temporal Semantics: As of Task #991, temporal operators G (all_future)
and H (all_past) use STRICT semantics (< instead of ≤)
```

(Truth.lean lines 10-15)

### CanonicalIrreflexivityAxiom.lean Says Reflexive

```
The proof uses the Gabbay Irreflexivity Rule (IRR) contrapositively with the
T-axiom for past (H(φ) → φ), which is valid under the reflexive temporal semantics.
```

But it imports from `CanonicalIrreflexivity.lean` which declares an **axiom** (not a theorem) under strict semantics.

### Assessment

Task 967 updated documentation and some structural files to reflexive semantics. Task 991 then reverted the core semantic definitions (Truth.lean) to strict but did not fully update all documentation. The ROAD_MAP.md architectural decision section still reflects the Task 967 decision. This inconsistency should be resolved regardless of which direction Task 29 takes.

---

## 6. Full Inventory: What Changes Under Reflexive Semantics

### Axioms Eliminated (2, possibly 3)

| Axiom | Status Under Reflexive | Confidence |
|-------|----------------------|------------|
| `canonicalR_irreflexive_axiom` | **FALSE** — must be removed | HIGH |
| `discreteImmediateSuccSeed_consistent_axiom` | **PROVABLE** via T-axiom | HIGH |
| `discreteImmediateSucc_covers_axiom` | **Possibly provable** — needs analysis | MEDIUM |

### Axiom Unchanged (1)

| Axiom | Status | Reason |
|-------|--------|--------|
| `discrete_Icc_finite_axiom` | UNCHANGED | Addresses interval finiteness of quotient — independent of temporal semantics |

### New Requirements

| Requirement | Description | Difficulty |
|-------------|-------------|------------|
| Add T-axioms to proof system | `temp_t_future : Axiom (φ.all_future.imp φ)`, `temp_t_past : Axiom (φ.all_past.imp φ)` | LOW |
| Prove T-axiom soundness | `temp_t_valid_future`, `temp_t_valid_past` (trivial: `le_refl`) | LOW |
| Replace irreflexivity with antisymmetry | `CanonicalR M N ∧ CanonicalR N M → M = N` | MEDIUM |
| Update all `<` to `≤` in temporal quantification | Truth.lean, FMCSDef.lean, TemporalCoherence.lean | LOW (mechanical) |
| Repair soundness proofs | `lt_trans` → `le_trans`, add `le_refl` cases | LOW-MEDIUM |
| Handle CanonicalR reflexivity downstream | NoMaxOrder/NoMinOrder/DenselyOrdered use antisymmetry instead of irreflexivity | MEDIUM |

### Files Requiring Changes

| Category | Files | Change Type |
|----------|-------|-------------|
| Core semantic | `Semantics/Truth.lean` | `<` → `≤` (2 lines) |
| Proof system | `ProofSystem/Axioms.lean` | Add T-axioms |
| Soundness | `Metalogic/Soundness.lean` | Repair ~6 proofs |
| FMCS structure | `Bundle/FMCSDef.lean` | `<` → `≤` in coherence fields |
| Temporal coherence | `Bundle/TemporalCoherence.lean` | Signature changes |
| Irreflexivity | `Bundle/CanonicalIrreflexivity.lean` | Major: axiom → antisymmetry theorem |
| Axiom wrapper | `Canonical/CanonicalIrreflexivityAxiom.lean` | Repurpose or remove |
| Truth lemma | `Algebraic/ParametricTruthLemma.lean` | Add s = t case |
| Discrete seed | `StagedConstruction/DiscreteSuccSeed.lean` | Prove axiom |
| Staged construction | Multiple files in `StagedConstruction/` | Use antisymmetry |

---

## 7. Key Insight: The Antisymmetry Pattern

Under reflexive semantics, the entire irreflexivity infrastructure transforms into an **antisymmetry** pattern:

### Old Pattern (Strict Semantics)

```
canonicalR_irreflexive: ¬CanonicalR M M
↓
If CanonicalR M N, then M ≠ N (immediate from irreflexivity + identity)
↓
Quotient ordering is strict
```

### New Pattern (Reflexive Semantics)

```
canonicalR_reflexive: CanonicalR M M (via T-axiom: g_content M ⊆ M)
canonicalR_antisymmetric: CanonicalR M N ∧ CanonicalR N M → M = N
↓
If CanonicalR M N and M ≠ N, then ¬CanonicalR N M
↓
Quotient ordering is strict for DISTINCT equivalence classes
```

The `CanonicalIrreflexivityAxiom.lean` docstring (lines 46-48) already describes this pattern:

> "If `CanonicalR M N` and `CanonicalR N M` both hold, then `CanonicalR M M` by T4 composition, contradicting irreflexivity."

Under reflexive semantics, this becomes: both `CanonicalR M N` and `CanonicalR N M` imply M and N are T4-equivalent, and the Gabbay IRR argument shows M = N as MCSes. The existing 1170-line Gabbay IRR infrastructure in `CanonicalIrreflexivity.lean` would be **reactivated** for this antisymmetry proof rather than deleted.

---

## 8. Risk Assessment

### Low Risk

| Risk | Assessment |
|------|------------|
| Core semantic change (`<` → `≤`) | Mechanical — 2 lines in Truth.lean |
| T-axiom soundness | Trivial — `le_refl` |
| Seriality trivialization | Acceptable — seriality was always trivial for unbounded orders |

### Medium Risk

| Risk | Assessment |
|------|------------|
| Soundness proof repairs | Several proofs need `le_refl` case handling |
| Antisymmetry proof | Reuses existing Gabbay infrastructure, but "reactivation" may uncover bit rot |
| Downstream consumers of irreflexivity | Need systematic grep for `canonicalR_irreflexive` usage |
| Frame class architecture | `FrameClass` enum becomes degenerate — design decision needed |

### High Risk

| Risk | Assessment |
|------|------------|
| `discreteImmediateSucc_covers_axiom` | May remain unprovable even under reflexive semantics |
| Undiscovered T-axiom interactions | Could introduce new proof obligations in currently sorry-free code |

---

## 9. Recommendations

### 9.1 Proceed with Switch to Reflexive Semantics

The historical difficulties are understood and addressable:
1. **Density obstruction** — was a misconception, thoroughly debunked
2. **Frame class collapse** — real but architecturally manageable (simplification, not a problem)
3. **Irreflexivity** — transforms to antisymmetry, using existing 1170-line infrastructure

### 9.2 Fix Documentation Inconsistency

Regardless of Task 29's outcome, the ROAD_MAP.md / Truth.lean conflict must be resolved. Either:
- Update ROAD_MAP.md to say "Strict semantics adopted per Task 991" (if staying strict), or
- Update Truth.lean to reflexive semantics (if Task 29 proceeds)

### 9.3 Implementation Order

If proceeding:
1. **Phase 1**: Core semantic change (Truth.lean, 2 lines) + T-axiom addition
2. **Phase 2**: Soundness proof repairs
3. **Phase 3**: FMCS/coherence structure updates
4. **Phase 4**: Antisymmetry proof (reactivate Gabbay infrastructure)
5. **Phase 5**: Downstream repairs (staged construction, algebraic modules)
6. **Phase 6**: Axiom elimination (`discreteImmediateSuccSeed_consistent_axiom`)

---

## 10. References

### Task History

| Task | Title | Relevance |
|------|-------|-----------|
| 956 | D from syntax construction | Originally abandoned reflexive semantics |
| 967 | Change atom type for freshness | Re-adopted reflexive semantics, T-axiom approach |
| 991 | Temporal algebraic representation | Reverted to strict semantics, irreflexivity blocker |
| 26 | Remove canonicalR irreflexive axiom | Explored axiom removal options |
| 29 | Switch to reflexive G/H semantics | Current task |

### Key Research Reports

- `specs/vault/01-vault/archive/991_temporal_algebraic_representation/reports/06_irreflexivity-rigorous-analysis.md` — Definitive analysis of why irreflexivity is not derivable under strict semantics
- `specs/vault/01-vault/archive/991_temporal_algebraic_representation/reports/04_synthesis.md` — Team research on strict vs reflexive trade-offs
- `specs/vault/01-vault/archive/991_temporal_algebraic_representation/plans/02_revised-irreflexive-semantics.md` — Failed attempt at temp_a + linearity proof
- `specs/vault/01-vault/archive/967_change_atom_type_for_freshness/reports/research-001.md` — Task 967 implementation readiness
- `specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md` — Task 29 axiom analysis
- `specs/029_switch_to_reflexive_gh_semantics/reports/01_teammate-b-findings.md` — Task 29 file-by-file impact

### ROAD_MAP.md Sections

- Lines 60-80: "Indexed MCS Family Approach" strategy (reflexive coherence)
- Lines 245-258: "Reflexive G/H Semantics" architectural decision
- Lines 724-748: "Revised Approach: Reflexive G/H Semantics" dead-end-then-adopted entry

### Codebase Files

- `Theories/Bimodal/Semantics/Truth.lean` — Current strict semantics definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — 1254-line file with axiom + historical Gabbay infrastructure
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` — Wrapper theorem with reflexive-semantics docstring
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` — Two axioms dependent on strict semantics
- `Theories/Bimodal/ProofSystem/Axioms.lean` — Axiom definitions (T-axioms to be added)
