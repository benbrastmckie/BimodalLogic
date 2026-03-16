# Research Report: Task #971 - Eliminate bmcs_truth_at Layer

**Task**: 971 - Refactor to eliminate bmcs_truth_at layer
**Started**: 2026-03-15
**Completed**: 2026-03-15
**Effort**: 2-3 hours implementation
**Dependencies**: None (self-contained refactor)
**Sources/Inputs**: Task 970 research report, codebase exploration (Glob/Grep/Read)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

- The `bmcs_truth_at` layer in `BFMCSTruth.lean` is **explicitly documented as structurally redundant** (see `CanonicalConstruction.lean` line 20)
- The codebase already has `canonical_truth_lemma` and `shifted_truth_lemma` in `CanonicalConstruction.lean` that bypass `bmcs_truth_at` entirely
- The refactor path is straightforward: derive `bmcs_truth_lemma` as a corollary of `canonical_truth_lemma`, then mark `BFMCSTruth.lean` and `bmcs_truth_at` as deprecated
- **Estimated effort**: 2-3 hours for implementation
- **Risk level**: LOW - the replacement infrastructure already exists and is sorry-free

---

## Context & Scope

### What is `bmcs_truth_at`?

`bmcs_truth_at` is a truth predicate defined in `BFMCSTruth.lean` that evaluates formulas within a Bundle of Maximal Consistent Sets (BFMCS). It was created as an intermediate layer between MCS membership and standard Kripke semantics (`truth_at`).

### Why was it created?

The `bmcs_truth_at` layer was historically needed because:
1. It provides Henkin-style semantics where box quantifies over bundle families only (not all worlds)
2. This restriction made the truth lemma provable (the box case worked)
3. It served as a stepping stone from pure MCS theory to Kripke semantics

### Why is it now redundant?

The key insight from `CanonicalConstruction.lean` (line 20):

> "The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally identical to `truth_at` when canonical definitions are chosen correctly. Therefore we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate."

The `canonical_truth_lemma` in `CanonicalConstruction.lean` now directly proves:
```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

This is the **direct** connection we want, without the intermediate `bmcs_truth_at`.

---

## Findings

### Finding 1: Current Dependency Structure

The `bmcs_truth_at` layer has limited downstream dependencies:

| File | Uses `bmcs_truth_at` | Uses `bmcs_truth_lemma` |
|------|---------------------|------------------------|
| `BFMCSTruth.lean` | DEFINES it | N/A |
| `TruthLemma.lean` | USES (proves) | DEFINES |
| `CanonicalConstruction.lean` | Documentation only | Imports, doesn't use |
| `StagedConstruction/Completeness.lean` | References in docstring | Documentation only |
| `Boneyard/IntRepresentation/Representation.lean` | USES | USES |

**Key Observation**: Active code outside `BFMCSTruth.lean` and `TruthLemma.lean` does NOT use `bmcs_truth_at` directly. The codebase has already migrated to `canonical_truth_lemma` and `shifted_truth_lemma`.

### Finding 2: Parallel Truth Lemma Paths

The codebase currently has **two parallel truth lemma paths**:

**Path A (Legacy - via bmcs_truth_at)**:
```
BFMCSTruth.lean (def bmcs_truth_at)
  -> TruthLemma.lean (theorem bmcs_truth_lemma)
  -> bmcs_truth_lemma: phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**Path B (Modern - direct truth_at)**:
```
CanonicalConstruction.lean (def CanonicalTaskFrame, CanonicalTaskModel, etc.)
  -> canonical_truth_lemma: phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
  -> shifted_truth_lemma: (same but with ShiftClosedCanonicalOmega)
```

Path B is the **publication-ready** path. Path A is scaffolding.

### Finding 3: Definitions in BFMCSTruth.lean

`BFMCSTruth.lean` defines the following:

| Definition | Usage | Keep/Remove |
|------------|-------|-------------|
| `bmcs_truth_at` | Core definition | DEPRECATE |
| `bmcs_valid` | Never used in proofs | REMOVE |
| `bmcs_satisfiable_at` | Never used in proofs | REMOVE |
| `bmcs_satisfies_context` | Never used in proofs | REMOVE |
| `bmcs_truth_neg` | Used by TruthLemma | Can derive from truth_at |
| `bmcs_truth_and` | Used by TruthLemma | Can derive from truth_at |
| `bmcs_truth_or` | Used by TruthLemma | Can derive from truth_at |
| `bmcs_truth_diamond` | Used by TruthLemma | Can derive from truth_at |
| `bmcs_truth_box_*` | Internal to module | REMOVE |
| `bmcs_truth_all_future_transitive` | Internal | REMOVE |
| `bmcs_truth_all_past_transitive` | Internal | REMOVE |

### Finding 4: TruthLemma.lean Structure

`TruthLemma.lean` currently:
1. Imports `BFMCSTruth.lean`
2. Imports `TemporalCoherentConstruction.lean` for `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`
3. Proves `bmcs_truth_lemma` by structural induction, using `bmcs_truth_at` in the definition

The temporal coherence imports are valid mathematical content; only the `bmcs_truth_at` dependency is problematic.

### Finding 5: Equivalence Between bmcs_truth_at and truth_at

The `bmcs_truth_at` definition:
```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p in fam.mcs t
  | Formula.bot => False
  | Formula.imp phi psi => bmcs_truth_at B fam t phi -> bmcs_truth_at B fam t psi
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
  | Formula.all_past phi => forall s, s < t -> bmcs_truth_at B fam s phi
  | Formula.all_future phi => forall s, t < s -> bmcs_truth_at B fam s phi
```

The `truth_at` definition:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Structural differences**:
1. **Atom case**: `bmcs_truth_at` checks MCS membership; `truth_at` checks valuation
2. **Box case**: Both quantify over a set of histories/families
3. **Temporal cases**: `bmcs_truth_at` uses strict `<`; `truth_at` uses reflexive `<=`

The differences are resolved by:
- Defining `CanonicalTaskModel` with `valuation = MCS membership`
- Defining `CanonicalOmega` as `{ to_history fam | fam in B.families }`
- Using reflexive temporal semantics (Task 967 updated this)

### Finding 6: Refactoring Strategy Options

**Option A: Derive bmcs_truth_lemma as Corollary (RECOMMENDED)**

1. Keep `canonical_truth_lemma` as the primary theorem
2. Define a **definitional equivalence** between `bmcs_truth_at` and `truth_at` for canonical constructions
3. Derive `bmcs_truth_lemma` as a corollary using the equivalence
4. Mark `BFMCSTruth.lean` as deprecated, keep for backward compatibility

**Advantages**:
- Non-breaking change (existing imports still work)
- Clear migration path
- Minimal code changes to existing proofs

**Option B: Full Elimination (AGGRESSIVE)**

1. Delete `bmcs_truth_at` entirely
2. Rewrite `TruthLemma.lean` to prove directly at `truth_at` level
3. Update all downstream code

**Disadvantages**:
- Requires rewriting `TruthLemma.lean` (500+ lines)
- Potential for introducing bugs
- Higher risk

**Recommendation**: Option A for this task, with Option B as a future follow-up once Option A is validated.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| MCS-Membership Semantics (lines 816-828) | LOW | That dead end was about box checking MCS membership instead of recursive truth; this refactor keeps recursive truth |
| Int/Rat Import Constraint | MEDIUM | The refactor maintains D=Int in existing files; does not introduce new D imports |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | The `canonical_truth_lemma` uses CanonicalTaskFrame which is the correct publication path; refactor aligns with this strategy |
| Indexed MCS Family Approach | ACTIVE | The refactor preserves FMCS structure; no changes to family indexing |

---

## Implementation Plan

### Phase 1: Prove Equivalence Lemma (30 min)

Add to `CanonicalConstruction.lean`:

```lean
/-- Equivalence between bmcs_truth_at and truth_at for canonical constructions.
This bridges the legacy bmcs_truth_at definition to the standard truth_at. -/
theorem bmcs_truth_at_eq_canonical_truth
    (B : BFMCS Int) (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    bmcs_truth_at B fam t phi <->
    truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi := by
  -- Proof by structural induction on phi
  -- Uses: canonical_truth_lemma, bmcs_truth_lemma, and transitivity
  sorry -- PLACEHOLDER
```

### Phase 2: Derive bmcs_truth_lemma as Corollary (15 min)

Add to `CanonicalConstruction.lean`:

```lean
/-- bmcs_truth_lemma derived as a corollary of canonical_truth_lemma.
This establishes that the legacy bmcs_truth_at layer is redundant. -/
theorem bmcs_truth_lemma_from_canonical
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi :=
  (canonical_truth_lemma B h_tc fam hfam t phi).trans
    (bmcs_truth_at_eq_canonical_truth B fam hfam t phi).symm
```

### Phase 3: Add Deprecation Notices (15 min)

Update `BFMCSTruth.lean` header:
```lean
/-!
# BFMCS Truth Definition [DEPRECATED]

**DEPRECATION NOTICE**: This module defines the intermediate `bmcs_truth_at` layer
which is structurally redundant. New code should use `canonical_truth_lemma` or
`shifted_truth_lemma` from `CanonicalConstruction.lean` directly.

This module is preserved for backward compatibility. The `bmcs_truth_at` definition
is definitionally equivalent to `truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t`
when canonical constructions are used.

See `CanonicalConstruction.lean` for the direct truth lemma.
-/
```

### Phase 4: Remove Unused Definitions (30 min)

Delete from `BFMCSTruth.lean`:
- `bmcs_valid`
- `bmcs_satisfiable_at`
- `bmcs_satisfies_context`

These have zero usage outside their defining module.

### Phase 5: Update Documentation (30 min)

Update:
- `Metalogic.lean` - Remove `bmcs_truth_lemma` from publication-ready list, add `canonical_truth_lemma`
- `StagedConstruction/Completeness.lean` - Update docstrings
- `Bundle/README.md` - Document the deprecation

### Phase 6: Verify Build (15 min)

Run `lake build` to verify no regressions.

---

## Decisions

1. **Use Option A (Derive as Corollary)** rather than full elimination to minimize risk
2. **Keep BFMCSTruth.lean** with deprecation notice rather than deleting (backward compatibility)
3. **Focus on CanonicalConstruction.lean** as the publication-ready entry point
4. **Preserve TruthLemma.lean** structure but mark as legacy

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Semantic mismatch between bmcs_truth_at and truth_at | LOW | HIGH | The canonical_truth_lemma already proves equivalence for MCS membership; extend to full formula equivalence |
| Temporal semantics difference (strict vs reflexive) | MEDIUM | MEDIUM | The codebase was updated in Task 967 to use reflexive semantics consistently |
| Build breakage from removing definitions | LOW | LOW | Only remove definitions confirmed unused by Grep; run lake build to verify |

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| truth_at vs bmcs_truth_at equivalence | Finding 5 | Partial (in CanonicalConstruction.lean) | extension |
| Publication-ready vs legacy proof paths | Finding 2 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `publication-ready-theorems.md` | `domain/` | Document which theorems are publication-ready vs scaffolding | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Truth Evaluation | Note on bmcs_truth_at deprecation | Low | No |

### Summary

- **New files needed**: 0 (not high priority)
- **Extensions needed**: 1 (low priority)
- **Tasks to create**: 0
- **High priority gaps**: 0

---

## Appendix

### Search Queries Used

1. `Grep bmcs_truth_at *.lean` - 9 files found
2. `Grep bmcs_truth_lemma|canonical_truth_lemma Theories/` - Full usage map
3. `Grep import.*BFMCSTruth|import.*TruthLemma Theories/` - Import graph

### Key File Locations

| File | Purpose | Lines |
|------|---------|-------|
| `Bundle/BFMCSTruth.lean` | Defines bmcs_truth_at | 291 |
| `Bundle/TruthLemma.lean` | Proves bmcs_truth_lemma | 489 |
| `Bundle/CanonicalConstruction.lean` | Proves canonical_truth_lemma | 797 |
| `StagedConstruction/Completeness.lean` | Documents completeness pipeline | 189 |

### References

- Task 970 research report: `specs/970_review_metalogic_for_publication/reports/research-001.md`
- CanonicalConstruction.lean line 20: Explicit acknowledgment of redundancy
- ROAD_MAP.md: D Construction strategy (active), MCS-Membership Semantics (dead end)
