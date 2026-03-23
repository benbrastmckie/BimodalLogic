# Teammate B Findings: canonicalR_irreflexive Usage Map and CanonicalTask Refactoring Assessment

## 1. Axiom Definition and Wrapper

### Source: `Bundle/CanonicalIrreflexivity.lean` (lines 1212-1230)

```
axiom canonicalR_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M

theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M :=
  canonicalR_irreflexive_axiom M h_mcs
```

### Re-export: `Canonical/CanonicalIrreflexivityAxiom.lean` (lines 76-99)

Re-exports the wrapper in the `Canonical` namespace and derives two corollaries:
- `canonicalR_irreflexive` (line 76): Direct re-export of `Bundle.canonicalR_irreflexive`
- `canonicalR_antisymmetric_strict` (line 85): If `CanonicalR M N` and `CanonicalR N M`, then `False` (via transitivity + irreflexivity)
- `canonicalR_strict` (line 95): If `CanonicalR M N`, then `¬CanonicalR N M`

---

## 2. Complete Usage Inventory (Non-Boneyard)

### File 1: `Algebraic/SaturatedChain.lean` — 8 uses

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 370 | `canonicalMCS_has_future` | Equality case: if N = M then CanonicalR M M, contradiction |
| 373 | `canonicalMCS_has_future` | Transitivity case: CanonicalR(M,W) + CanonicalR(W,M) -> CanonicalR(M,M) |
| 401 | `canonicalMCS_has_past` | Equality case (symmetric to 370) |
| 404 | `canonicalMCS_has_past` | Transitivity case (symmetric to 373) |
| 446 | `canonicalMCS_has_intermediate` | Equality case: W = M -> CanonicalR(M,M) |
| 449 | `canonicalMCS_has_intermediate` | Transitivity case: CanonicalR(M,W) + CanonicalR(W,M) -> CanonicalR(M,M) |
| 459 | `canonicalMCS_has_intermediate` | Equality case: N = W -> CanonicalR(W,W) |
| 462 | `canonicalMCS_has_intermediate` | Transitivity case: CanonicalR(N,W) + CanonicalR(W,N) -> CanonicalR(N,N) |

**Proof pattern**: All 8 uses follow the same template: proving strict `<` in the `CanonicalMCS` preorder by showing that equality or reverse CanonicalR would yield `CanonicalR M M`, contradicting irreflexivity. Used for `NoMaxOrder`, `NoMinOrder`, `DenselyOrdered` on saturated chains.

### File 2: `Bundle/FMCSTransfer.lean` — 2 uses

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 224 | `CanonicalMCS.lt_of_canonicalR` | Equality case (rfl): CanonicalR b.world b.world |
| 229 | `CanonicalMCS.lt_of_canonicalR` | Transitivity case: CanonicalR(a,b) + CanonicalR(b,a) -> CanonicalR(a,a) |

**Proof pattern**: Converting CanonicalR to strict `<` in CanonicalMCS preorder. This is a utility lemma used by F/P transfer proofs.

### File 3: `Canonical/CanonicalSerialFrameInstance.lean` — 2 uses (indirect via `canonicalR_strict`)

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 77 | `NoMaxOrder` instance | Equality case: if N = w then CanonicalR w w |
| 123 | `NoMinOrder` instance | Equality case: CanonicalR N N after substitution |

**Note**: Lines 54 and 100 also use `canonicalR_strict` (which itself depends on `canonicalR_irreflexive` via `canonicalR_antisymmetric_strict`). So these are indirect uses too.

### File 4: `StagedConstruction/TimelineQuotCanonical.lean` — 1 use

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 95 | `denseTimelineElem_mutual_le_implies_mcs_eq` | Transitivity case: mutual CanonicalR -> CanonicalR(p,p) |

**Proof pattern**: Proving that elements in the same equivalence class have the same MCS. Key structural lemma for the TimelineQuot construction.

### File 5: `StagedConstruction/ClosureSaturation.lean` — 2 uses

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 389 | density/saturation proof | Equality case: q.mcs = p.mcs -> CanonicalR(p,p) |
| 393 | density/saturation proof | Transitivity case: CanonicalR(p,q) + CanonicalR(q,p) -> CanonicalR(p,p) |

**Proof pattern**: Proving strict `<` in the TimelineQuot after obtaining a CanonicalR witness.

### File 6: `StagedConstruction/IncrementalTimeline.lean` — 1 use

| Line | Theorem | Usage Pattern |
|------|---------|---------------|
| 156 | `quot_same_class_same_mcs` | Transitivity case: mutual CanonicalR -> CanonicalR(p,p) |

**Proof pattern**: Same as TimelineQuotCanonical -- proving equivalence class implies same MCS.

### File 7: `StagedConstruction/CantorApplication.lean` — 0 direct code uses

Only docstring/comment references (lines 31, 139, 189). The actual proofs in this file use the instances (NoMaxOrder, NoMinOrder, DenselyOrdered) that are themselves proved using irreflexivity elsewhere.

### File 8: `Domain/CanonicalDomain.lean` — 0 direct code uses

Only docstring/comment references (lines 27, 41, 136, 180, 217, 250). Same as CantorApplication -- uses downstream instances.

### File 9: `Domain/DiscreteTimeline.lean` — 0 direct code uses

Only docstring/comment references (lines 127, 135).

---

## 3. Usage Pattern Summary

All 16 direct code uses of `canonicalR_irreflexive` follow exactly **two patterns**:

### Pattern A: Equality Contradiction (7 uses)
```
-- Given: CanonicalR X Y and (some equality implying X = Y)
-- Derive: CanonicalR X X
-- Apply: canonicalR_irreflexive X h_mcs
```

### Pattern B: Transitivity Contradiction (9 uses)
```
-- Given: CanonicalR X Y and CanonicalR Y X
-- Derive: CanonicalR X X (via canonicalR_transitive)
-- Apply: canonicalR_irreflexive X h_mcs
```

Pattern B is exactly what `canonicalR_antisymmetric_strict` already packages.

---

## 4. CanonicalTask Refactoring Assessment

### What is CanonicalTask?

`CanonicalTask` (defined in `Bundle/CanonicalTaskRelation.lean`) is an integer-indexed relation built inductively from `Succ`. Key facts:
- `CanonicalTask_forward u n v` = chain of n Succ steps from u to v
- `Succ u v` implies `CanonicalR u v` (by `Succ_implies_CanonicalR`)
- `Succ u v` is STRONGER than `CanonicalR u v` (adds f_content condition)

### Critical Observation: CanonicalR is NOT CanonicalTask

The `canonicalR_irreflexive` axiom operates at the level of `CanonicalR` (g_content subset). The `CanonicalTask` relation operates at the level of `Succ` chains. These are different levels:

- `Succ` implies `CanonicalR`, but `CanonicalR` does NOT imply `Succ`
- `CanonicalTask_forward u 1 v` requires `Succ u v`, which is stronger than `CanonicalR u v`
- The seriality witnesses (`canonical_forward_F`, `canonical_backward_P`) produce `CanonicalR`, NOT `Succ`

### File-by-File Refactoring Assessment

| File | Works with CanonicalR? | Refactorable to CanonicalTask? | Difficulty | Obstacle |
|------|----------------------|-------------------------------|------------|----------|
| `SaturatedChain.lean` | Yes, directly | **No** | N/A | Witnesses come from `canonical_forward_F`/`canonical_backward_P` which give `CanonicalR`, not `Succ`. Density frame condition also gives `CanonicalR`. |
| `FMCSTransfer.lean` | Yes, directly | **No** | N/A | `lt_of_canonicalR` is an interface converting CanonicalR to strict `<`. Must work with CanonicalR since callers provide CanonicalR. |
| `CanonicalSerialFrameInstance.lean` | Yes, via `canonicalR_strict` | **No** | N/A | Uses `executeForwardStep`/`executeBackwardStep` which produce `CanonicalR`, not `Succ`. |
| `TimelineQuotCanonical.lean` | Yes, directly | **No** | N/A | The preorder `StagedPoint.le` is defined as `mcs = mcs ∨ CanonicalR mcs mcs`. Irreflexivity of CanonicalR is structurally needed. |
| `ClosureSaturation.lean` | Yes, directly | **No** | N/A | Same as TimelineQuotCanonical -- the preorder uses CanonicalR. |
| `IncrementalTimeline.lean` | Yes, directly | **No** | N/A | Same as TimelineQuotCanonical -- StagedPoint.le uses CanonicalR. |

### Why CanonicalTask Cannot Replace CanonicalR Irreflexivity

The fundamental issue is that **all usage sites work at the CanonicalR level**, not the Succ/CanonicalTask level. The reason:

1. **The preorder on StagedPoint/CanonicalMCS** is defined using `CanonicalR`, not `Succ`. The `≤` relation is `eq ∨ CanonicalR`. To show `<` (strict), one must eliminate the reverse `CanonicalR` direction, which requires `canonicalR_irreflexive`.

2. **Seriality witnesses** (`canonical_forward_F`, `canonical_backward_P`) and the **density frame condition** produce `CanonicalR` witnesses, not `Succ` witnesses. Refactoring these to produce `Succ` would be a separate, much larger task.

3. **CanonicalTask irreflexivity** doesn't exist and wouldn't help even if it did, because the proofs need to eliminate `CanonicalR`, not `CanonicalTask`.

---

## 5. Alternative Approaches to Removing the Axiom

Since CanonicalTask refactoring is not a viable path, the real options for removing `canonicalR_irreflexive_axiom` are:

### Option A: Prove it from first principles
The legacy proof (preserved in CanonicalIrreflexivity.lean lines 1232-1248) used the T-axiom `H(phi) -> phi` under reflexive semantics. Under strict semantics, this approach doesn't work. A new proof strategy would need to be found -- potentially using atom freshness with a different atom type (the original approach failed because String atoms aren't fresh).

### Option B: Derive from Succ irreflexivity
If we could prove `¬Succ M M` (easier than `¬CanonicalR M M` because Succ has the extra f_content condition), and then show that CanonicalR M M implies Succ M M under some conditions, we might derive irreflexivity. However, `CanonicalR` does NOT imply `Succ` in general, so this path likely fails.

### Option C: Change the preorder definition
Redefine `StagedPoint.le` using `Succ` instead of `CanonicalR`. Then irreflexivity of `Succ` (if provable) would suffice. This would be a major refactor touching the entire staged construction pipeline.

### Option D: Keep the axiom
The axiom is mathematically well-justified (Goldblatt 1992, BdRV 2001). It represents a semantic truth about strict temporal logic that is not modally definable. This is the current approach.

---

## 6. Summary

- **16 direct code uses** across 6 files (plus 2 indirect via `canonicalR_strict`)
- **All follow two patterns**: equality contradiction or transitivity contradiction
- **CanonicalTask refactoring is NOT viable**: all usage sites work at the CanonicalR level, not Succ/CanonicalTask
- **The axiom is structurally embedded**: the preorder on CanonicalMCS/StagedPoint is defined via CanonicalR, making irreflexivity of CanonicalR (not CanonicalTask) the fundamental requirement
- **Boneyard files** (DovetailedTimelineQuot.lean) contain 10+ additional uses but are inactive code
