# Research Report: Task #26 — CanonicalTask as Central Relation (Wave 6 Synthesis)

**Task**: remove_canonicalr_irreflexive_axiom
**Date**: 2026-03-21
**Mode**: Team Research (2 teammates)
**Session**: sess_1774125687_b9ad5b
**Focus**: CanonicalTask M n N with negative durations as the central relation; CanonicalR as a Kripke artifact

---

## Summary

This wave confirms with high confidence the user's key insight: **CanonicalTask M n N is the central relation for TaskFrame, and CanonicalR is a duration-agnostic existential projection that originates from Kripke semantics rather than TaskFrame semantics.**

The investigation reveals:

1. `CanonicalTask` already fully supports negative durations via the proven converse theorem (`CanonicalTask M n N ↔ CanonicalTask N (-n) M`)
2. `CanonicalTask` directly instantiates `TaskFrame Int` with all three axioms proven (no sorry)
3. `CanonicalR` is a derived concept (`∃ n > 0, CanonicalTask M n N`) being used as a primitive — this is the architectural "distraction"
4. The irreflexivity axiom reformulates cleanly as `∀ n > 0, ¬CanonicalTask M n M`
5. The critical blocker is the **backward sorry** in `CanonicalRecovery.lean`: `CanonicalR M N → ∃ n ≥ 1, CanonicalTask M n N`

---

## Key Findings

### 1. CanonicalTask Already Has Full Negative Duration Support (Teammate A)

The `CanonicalTask` definition in `CanonicalTaskRelation.lean:167` uses `Int` indexing with a proven converse theorem (lines 396–424):

```lean
theorem CanonicalTask_converse (u v : Set Formula) (n : Int) :
    CanonicalTask u n v ↔ CanonicalTask v (-n) u
```

No sorry. This is fully operational. The negative duration case (`Int.negSucc k`) maps to `CanonicalTask_backward`, which is the converse direction. **`CanonicalTask M n N` for negative n is exactly `CanonicalTask N (-n) M`** — the user's characterization is verified in code.

### 2. CanonicalTask Is the Native TaskFrame Concept (Teammate A)

`SuccChainTaskFrame.lean` instantiates `TaskFrame Int` with:

```lean
def CanonicalTaskTaskFrame : TaskFrame Int where
  WorldState := Set Formula
  task_rel := CanonicalTask
  nullity_identity := ...  -- proven, no sorry
  forward_comp := ...      -- proven, no sorry
  converse := ...          -- proven, no sorry
```

By contrast, the older `parametric_canonical_task_rel` in `ParametricCanonical.lean:85` uses CanonicalR:

```lean
if d > 0 then CanonicalR M.val N.val   -- duration lost
else if d < 0 then CanonicalR N.val M.val
else M = N
```

This collapses all positive durations to the same relation — the "duration shadow" that discards magnitude information.

### 3. CanonicalR Is a Kripke Artifact in a TaskFrame Setting (Teammate B)

**Diagnosis**: CanonicalR (`g_content M ⊆ N`) is the standard Kripke accessibility relation for tense modal logic. It captures "M sees N in the future" without encoding how far in the future. The TaskFrame interface requires a three-place relation with explicit duration. Using CanonicalR as the primitive creates an impedance mismatch:

```
Kripke modal logic:  M R N          (binary, no duration)
TaskFrame D:         M --d--> N     (ternary, duration explicit)
```

The `parametric_canonical_task_rel` attempts to bridge this gap via case-splitting on sign, but loses duration magnitude for all nonzero cases.

**Usage map across 69 files** (Teammate B's full codebase scan):

| Category | File count | Can be eliminated? |
|----------|-----------|-------------------|
| Primitive definition site | 1 | Keep as defined abbreviation |
| F/P witness extraction | ~25 | YES — replace with `∃ d > 0, CanonicalTask M d W` |
| Irreflexivity/antisymmetry | ~30 | YES — replace with `∀ d > 0, ¬CanonicalTask M d M` |
| Preorder definition (StagedPoint.le) | ~15 | YES — replace with `∃ n ≥ 0, CanonicalTask M n N` |

### 4. The Reformulated Irreflexivity Axiom

**Current axiom** (`CanonicalIrreflexivity.lean:1212`):
```lean
axiom canonicalR_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M
```

**CanonicalTask formulation** (equivalent):
```lean
axiom canonicalTask_irreflexive_axiom :
    ∀ (M : Set Formula) (n : Int), SetMaximalConsistent M → n ≠ 0 → ¬CanonicalTask M n M
```

The two are equivalent via the recovery theorem:
- **CanonicalTask form → CanonicalR form**: If `CanonicalR M M`, then (by backward sorry) `∃ n ≥ 1, CanonicalTask M n M`, contradicting the CanonicalTask axiom.
- **CanonicalR form → CanonicalTask form**: If `CanonicalTask M n M` with n > 0, then (by the **proven** forward direction) `CanonicalR M M`, contradicting the CanonicalR axiom.

The second direction (CanonicalR → CanonicalTask) uses only the forward direction of recovery, which is fully proven. Therefore **the CanonicalTask formulation can be derived from the current CanonicalR axiom without the backward sorry**.

### 5. The Backward Sorry: The Critical Blocker

**File**: `CanonicalRecovery.lean`

```lean
-- sorry: CanonicalR M N → ∃ n ≥ 1, CanonicalTask_forward M n N
theorem canonicalR_implies_canonicalTask_forward : sorry
```

This sorry blocks:
- Full equivalence between CanonicalR and ExistsTask
- Deriving the CanonicalR irreflexivity form from the CanonicalTask form
- Complete elimination of CanonicalR as a primitive

**Why it's hard** (Teammate B): The Lindenbaum witness produced by `canonical_forward_F` satisfies `g_content M ⊆ W` (G-persistence = CanonicalR) but does not obviously satisfy `f_content M ⊆ W ∪ f_content W` (F-step = full Succ condition). Showing Lindenbaum witnesses satisfy the F-step condition is a non-trivial obligation.

**Workaround**: The irreflexivity reformulation does NOT require the backward sorry. Using the forward direction alone:

```
¬CanonicalR M M  →  (∀ n > 0, CanonicalTask M n M → CanonicalR M M) →  ∀ n > 0, ¬CanonicalTask M n M
```

So the CanonicalTask form of irreflexivity can be derived as a **theorem** from the existing CanonicalR axiom.

### 6. CanonicalR_past Subsumed by Negative Duration

The converse symmetry eliminates `CanonicalR_past` entirely:

```
CanonicalR_past M N  :=  h_content M ⊆ N
                     ↔  ∃ n > 0, CanonicalTask N n M   (N reaches M in n forward steps)
                     ↔  ∃ n < 0, CanonicalTask M n N   (M reaches N in n backward steps)
```

In purely CanonicalTask terms: past direction = negative duration. `CanonicalR_past` as a named concept is unnecessary.

---

## Synthesis

### The User's Insight: Verified and Sharpened

The user's statement — "CanonicalTask M n N accepts negative values of n such that CanonicalTask M n N is the same as CanonicalTask N -n M. This is the central relation included in a TaskFrame. CanonicalR comes from Kripke semantics and is a distraction." — is precisely correct at every level:

1. **Verified**: The converse theorem is fully proven in code (no sorry).
2. **Verified**: CanonicalTask directly instantiates TaskFrame Int (no sorry anywhere in the three axioms).
3. **Verified**: CanonicalR originates from the Kripke tradition for binary modal accessibility.
4. **Verified**: The `parametric_canonical_task_rel` (the nominal "task relation" in the algebraic construction) delegates to CanonicalR, losing duration magnitude — this is the core of the distraction.

### The Irreflexivity Situation: Cleaner than Previously Thought

Prior waves concluded the axiom must be kept. This wave shows:

- **The axiom is needed** (confirmed — modal non-definability means it cannot be derived syntactically from TM axioms alone)
- **The axiom CAN be restated in CanonicalTask terms** without the backward sorry, using only the already-proven forward recovery direction
- **The CanonicalTask formulation is strictly more transparent**: it says exactly what TaskFrame irreflexivity means — no positive-duration self-loop

### Clean Architecture (What It Should Look Like)

```
Primary concept:   CanonicalTask M n N    (n ∈ ℤ, built from Succ-chains)

Derived concepts:
  ExistsTask M N    := ∃ n > 0, CanonicalTask M n N    (= current CanonicalR)
  (no name needed)  := ∃ n > 0, CanonicalTask N n M    (= current CanonicalR_past)
  M ≤ N (preorder)  := ∃ n ≥ 0, CanonicalTask M n N

Axiom (semantic, non-derivable):
  ∀ M n, SetMaximalConsistent M → n ≠ 0 → ¬CanonicalTask M n M

Derived theorem (from axiom via forward recovery):
  ∀ M, SetMaximalConsistent M → ¬ExistsTask M M    (= current canonicalR_irreflexive)
```

### Gaps Remaining

1. **Backward sorry in CanonicalRecovery.lean** — Needed for full equivalence but NOT needed for the irreflexivity reformulation.
2. **Succ condition for Lindenbaum witnesses** — The backward sorry requires showing `canonical_forward_F` witnesses satisfy the F-step condition. This is a proof obligation not yet attempted.
3. **`StagedPoint.le` migration** — The 15 files using CanonicalR for preorder definitions need migration to CanonicalTask-based preorders. Medium difficulty.
4. **`parametric_canonical_task_rel` refactoring** — The algebraic construction's task relation needs to be replaced with a duration-precise version. Requires careful handling of the truth lemma proofs.

---

## Recommendations

### Immediate (no blocking on the backward sorry)

1. **Add `canonicalTask_irreflexive` as a derived theorem** from the existing `canonicalR_irreflexive_axiom`:
   ```lean
   theorem canonicalTask_irreflexive (M : Set Formula) (n : Int)
       (h_mcs : SetMaximalConsistent M) (h_pos : 0 < n) :
       ¬CanonicalTask M n M := fun h_task =>
     canonicalR_irreflexive M h_mcs (canonicalTask_pos_implies_canonicalR h_task)
   ```

2. **Document CanonicalR as a derived concept** with docstring clarification that it is `ExistsTask` — the existential projection of CanonicalTask over positive durations.

3. **Accept the irreflexivity axiom** as a semantic axiom, now with dual formulation clarity: either `¬ExistsTask M M` or `∀ n > 0, ¬CanonicalTask M n M`.

### Medium-term (requires backward sorry)

4. **Rename CanonicalR → ExistsTask** across codebase (simple rename, definition unchanged).
5. **Reformulate `parametric_canonical_task_rel`** for D = ℤ to use CanonicalTask directly.
6. **Eliminate CanonicalR_past** as a named concept.

### Long-term (significant effort)

7. **Prove the backward sorry** — Show Lindenbaum witnesses satisfy the full Succ condition (not just G-persistence).
8. **Make `canonicalR_irreflexive_axiom` a theorem** derived from `canonicalTask_irreflexive_axiom` (once the backward sorry is filled, both formulations are interderivable).

---

## Teammate Contributions

| Teammate | Focus | Key Contribution | Confidence |
|----------|-------|-----------------|------------|
| A | CanonicalTask definition and converse | Verified negative duration support in code; confirmed CanonicalTask as native TaskFrame concept | High |
| B | Refactoring path and distraction diagnosis | Full 69-file usage map; concrete 4-phase refactoring strategy; identified backward sorry as critical blocker | High |

---

## References

### Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:167` — CanonicalTask definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:396` — Converse theorem (proven)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:63` — CanonicalR definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:71` — CanonicalR_past definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212` — Irreflexivity axiom
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean:91` — CanonicalTask as TaskFrame
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean:85` — Old CanonicalR-based task relation
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` — Recovery theorems (forward proven, backward sorry)
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` — NoMaxOrder/NoMinOrder via irreflexivity

### Prior Research
- `specs/026_remove_canonicalr_irreflexive_axiom/reports/05_team-research.md` — Wave 5 synthesis
- `specs/006_canonical_taskframe_completeness/reports/17_three-place-canonical-task-relation.md` — CanonicalTask mathematical development
- `specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md` — Succ-chain bypass strategy
