# Research Report: Task 280 — Contrastive Minimal Pair Generation

## Session Information
- **Task**: 280 — contrastive_minimal_pair_generation
- **Session ID**: sess_1780676132_88a3d2
- **Date**: 2026-06-05
- **Agent**: lean-research-agent
- **Dependencies**: Task 275 (completed), Task 276 (completed)

---

## 1. Executive Summary

Task 280 requires extending the existing formula mutation infrastructure to generate **contrastive minimal pairs** — (valid, invalid) formula pairs that differ by exactly one structural change. A comprehensive codebase audit reveals that `FormulaMutator.lean` already implements a basic mutation framework (from Task 206), but it **lacks the specific single-structural-change mutations** requested in this task. In particular, the existing mutator does not support:

1. **Targeted operator swaps** (□↔◇, U↔R, F↔G, W↔M, T↔ST, etc.) — only has global box→diamond and G→F/H→P
2. **Conjunct removal** — no mutation for removing a single conjunct from `φ.and ψ`
3. **Implication direction flip** — no mutation for flipping `φ → ψ` to `ψ → φ`
4. **Fine-grained temporal operator substitution** — replacing one specific occurrence rather than all occurrences

The implementation path is clear: extend `FormulaMutator.lean` with new mutation functions, add corresponding `MutationType` constructors, and integrate with the existing `DatasetGenerator.labelFormula` pipeline. No new axioms or proof-system changes are required.

---

## 2. Existing Codebase Analysis

### 2.1 Formula Structure

**File**: `Theories/Bimodal/Syntax/Formula.lean`

The `Formula` inductive type has 6 primitive constructors:

| Constructor | Arity | Notation |
|-------------|-------|----------|
| `atom` | 0 | Propositional variable |
| `bot` | 0 | ⊥ (falsity) |
| `imp` | 2 | φ → ψ |
| `box` | 1 | □φ |
| `untl` | 2 | U(φ, ψ) — "φ until ψ" |
| `snce` | 2 | S(φ, ψ) — "φ since ψ" |

Derived operators (relevant to mutations):

| Operator | Definition | Primitive Expansion |
|----------|-----------|---------------------|
| `neg φ` | `φ.imp bot` | `imp φ bot` |
| `and φ ψ` | `(φ.imp ψ.neg).neg` | `imp (imp φ (imp ψ bot)) bot` |
| `or φ ψ` | `φ.neg.imp ψ` | `imp (imp φ bot) ψ` |
| `diamond φ` | `φ.neg.box.neg` | `imp (box (imp φ bot)) bot` |
| `some_future φ` | `untl φ top` | `untl φ (imp bot bot)` |
| `some_past φ` | `snce φ top` | `snce φ (imp bot bot)` |
| `all_future φ` | `(some_future φ.neg).neg` | `imp (untl (imp φ bot) (imp bot bot)) bot` |
| `all_past φ` | `(some_past φ.neg).neg` | `imp (snce (imp φ bot) (imp bot bot)) bot` |
| `release φ ψ` | `(untl φ.neg ψ.neg).neg` | `imp (untl (imp φ bot) (imp ψ bot)) bot` |
| `weak_until φ ψ` | `(untl φ ψ).or ψ.all_future` | `imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot)` |
| `trigger φ ψ` | `(snce φ.neg ψ.neg).neg` | `imp (snce (imp φ bot) (imp ψ bot)) bot` |
| `weak_since φ ψ` | `(snce φ ψ).or ψ.all_past` | `imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot)` |
| `strong_release φ ψ` | `untl (and ψ φ) ψ` | `untl (imp (imp ψ (imp φ bot)) bot) ψ` |
| `strong_trigger φ ψ` | `snce (and ψ φ) ψ` | `snce (imp (imp ψ (imp φ bot)) bot) ψ` |

**Key insight for mutations**: All derived operators are `def` abbreviations. Mutations must operate on the **primitive AST** to guarantee exactly one structural change. For example, flipping `□` to `◇` at a specific occurrence means finding a `box` constructor and replacing it with `diamond` (which expands to `imp (box (imp φ bot)) bot`). However, for "exactly one structural change" semantics, it is cleaner to define mutations that work at the derived-operator level when possible.

### 2.2 Existing Mutation Infrastructure

**File**: `Theories/Bimodal/Automation/FormulaMutator.lean`

Already defines:

#### Core Types
- `MutationType` — 8 constructors: `atomSubBot`, `boxToDiamond`, `allFutureToSomeFuture`, `allPastToSomePast`, `subformulaDeletion`, `modalDepthReduction`, `temporalDepthReduction`, `temporalDuality`
- `ContrastivePair` — records original, mutated, labels, countermodel, proof trace

#### Existing Mutation Functions
| Function | Behavior | Maps to Task 280 requirement? |
|----------|----------|------------------------------|
| `mutateAtomToBot` | Replace one atom with ⊥ | Not requested (task wants structural, not atom-level) |
| `weakenBoxToDiamond` | Replace **ALL** `box` with `diamond` globally | Partial — task wants replacing **one** □ with ◇ |
| `weakenAllToSome` | Replace **ALL** G→F and H→P globally | Partial — task wants single-occurrence swaps |
| `deleteSubformula` | Replace a subformula with top/bot | Partial — task wants removing one conjunct |
| `reduceModalDepth` | Strip ALL outermost boxes | Not requested |
| `reduceTemporalDepth` | Strip ALL outermost untl/snce | Not requested |
| `swap_temporal` | Swap past/future globally | Partial — task wants temporal duality as one mutation |

#### Pipeline Functions
- `generateMutations φ` — produces all applicable mutations for a formula
- `classifyMutation` — runs `decideAuto` (with `decideOptimized` fallback) on mutated formula
- `generateContrastivePairs` — for valid formulas, generates all mutations and classifies; for invalid, tries temporal duality
- `filterContrastive` — keeps pairs where labels differ, no timeouts, mutated complexity ≥ 3
- `writeContrastiveJSONL` — exports to JSONL with auto-incrementing IDs

#### Current Gaps vs Task 280 Requirements
| Task 280 Requirement | Current Status | Gap |
|---------------------|---------------|-----|
| (1) Replace one □ with ◇ | `weakenBoxToDiamond` replaces ALL | Need **single-occurrence** box→diamond |
| (2) Replace one temporal op with another (U↔R, F↔G, etc.) | Only G→F and H→P globally | Need U↔R, F↔G, W↔M, T↔ST, etc. |
| (3) Remove one conjunct | `deleteSubformula` replaces entire subformula | Need to recognize `and` pattern and remove one side |
| (4) Flip one implication direction | Not implemented | Need `imp φ ψ` → `imp ψ φ` at one occurrence |
| (5) Swap derived operator (W↔M, T↔ST) | Not implemented | Need operator swap mutations |

### 2.3 Tableau Prover Integration

**File**: `Theories/Bimodal/Automation/TableauBridge.lean`

The decision procedure is `decideAuto` (and `decideAutoAdaptive`) from `Bimodal.Metalogic.Decidability.DecisionProcedure`.

- `decideAuto φ fc` returns `.valid proof`, `.invalid cm`, or `.timeout`
- The `DatasetGenerator.labelFormula` function already wraps this with wall-clock timeouts, structural pre-filtering, proof trace extraction, countermodel extraction, and interestingness metrics
- `FormulaMutator.classifyMutation` currently calls `decideAuto` directly (without the wall-clock timeout and pre-filter pipeline)

**Critical integration note**: The existing `classifyMutation` bypasses the richer `labelFormula` pipeline (no pre-filter, no interestingness, no wall-clock timeout). For Task 280, it is recommended to **reuse `labelFormula`** instead of calling `decideAuto` directly, to benefit from structural pre-filters and timeouts.

### 2.4 Dataset Export Pipeline

**Files**: `Theories/Bimodal/Automation/DatasetExport.lean`, `DataExport.lean`

Already supports:
- `DatasetRecord` with full fields (formula_str, formula_ast, formula_sexpr, formula_tokens, formula_folded_*, pattern_key, metrics, augmentation, etc.)
- `LabeledFormula` with proof traces, countermodels, enriched countermodels, semantic countermodels, interestingness scores
- JSONL streaming with split assignment (train/val/test)
- `writeContrastiveJSONL` for contrastive pair export

For Task 280, the existing `ContrastivePair.toJson` and `writeContrastiveJSONL` are sufficient, but should be extended with new fields for the specific mutation type and occurrence path.

### 2.5 Formula Enumeration (Dependency Tasks 275, 276)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`

Tasks 275 and 276 added:
- `release`, `weak_until`, `trigger`, `weak_since` to complexity pattern-matching and enumeration
- `strong_release`, `strong_trigger` to complexity and enumeration
- All 6 derived binary temporal operators are now generated in `enumExactHelper`, `sampleOne`, `sampleOneRandom`, `randomSubFormula`
- `hasDerivedTemporal` recognizes all derived temporal patterns

This means the formula corpus now contains all the operators needed for Task 280 mutations.

---

## 3. Mutation Strategy Research

### 3.1 What Mutations Are Likely to Flip Validity Labels?

Based on the logic (TM = S5 modal + linear temporal), the following single-structural-change mutations have high probability of flipping validity:

**High-yield mutations** (likely to flip validity for valid formulas):
1. **□ → ◇**: Validity of □φ → φ (T axiom) does not imply ◇φ → φ. Replacing □ with ◇ often invalidates formulas.
2. **G → F**: Universal temporal quantification is stronger than existential. `Gφ` valid does not imply `Fφ` valid in the same context (though both are valid if φ is tautological).
3. **U → R**: Until requires the event to eventually occur; Release does not. This is a fundamental semantic difference.
4. **W → M**: Weak Until allows the guard to hold forever; Strong Release requires the event. This is the dual relationship.
5. **Implication flip**: `φ → ψ` vs `ψ → φ` — only one direction is typically valid.
6. **Conjunct removal**: Removing a conjunct from `φ ∧ ψ` weakens the formula. If the original was valid because both conjuncts were needed, the weakened version may be invalid.

**Medium-yield mutations**:
- **F → G**: Strengthening existential to universal rarely preserves validity.
- **H → P**: Similar to G→F for past operators.
- **T → ST**: Trigger vs Strong Trigger — dual relationship.

**Low-yield mutations** (often preserve validity):
- **Temporal duality** (`swap_temporal`) — preserves validity for theorems but not for arbitrary formulas.
- **Modal depth reduction** — stripping □ from a valid formula may or may not preserve validity.

### 3.2 Single-Occurrence vs Global Mutations

The existing mutator applies mutations **globally** (e.g., `weakenBoxToDiamond` replaces ALL `box` constructors). For "minimal pairs that differ by exactly one structural change," we need **single-occurrence** mutations.

**Design**: A single-occurrence mutation function takes a formula and a "path" or occurrence index, and applies the mutation at exactly one position. Alternatively, it can generate all possible single-occurrence mutations.

**Approach for Lean**:
```lean
def mutateSingleOccurrence (φ : Formula) (mutation : Formula → Option Formula) : List Formula :=
  -- Generate all formulas where mutation is applied at exactly one occurrence
```

Since `Formula` is an inductive type, we can implement this by structural recursion that:
1. At each constructor, tries applying the mutation to the current node
2. If the mutation applies, returns the mutated version plus all mutations in children
3. Deduplicates results

### 3.3 How to Avoid Duplicate Mutants

**Sources of duplication**:
1. **Symmetric mutations**: `U↔R` and then `R↔U` on the same occurrence produce the same pair
2. **Multiple paths to same formula**: Mutating `φ` at position A then B may equal mutating at B then A (though with single-occurrence mutations this is less of an issue)
3. **Identity mutations**: A mutation that produces the same formula (e.g., flipping `p → p`)

**Deduplication strategy**:
- Use `List.eraseDups` on the mutated formulas before running the decision procedure
- The existing `generateMutations` already filters `m != φ`
- For single-occurrence mutations, each occurrence produces a distinct formula by construction (assuming the mutation is non-identity)

### 3.4 Conjunct Removal Mutation

Since `and φ ψ = (φ.imp ψ.neg).neg`, removing one conjunct means:
- `and φ ψ` → `φ` (remove right conjunct)
- `and φ ψ` → `ψ` (remove left conjunct)

**Pattern recognition in primitive AST**:
```lean
-- φ ∧ ψ = imp (imp φ (imp ψ bot)) bot
-- Remove right conjunct: replace with φ
-- Remove left conjunct: replace with ψ
```

However, implementing this at the primitive level is fragile. A cleaner approach:
1. Check if the formula matches the `and` pattern
2. If so, generate mutations that replace the `and` node with each conjunct
3. Recurse into subformulas to find all `and` occurrences

### 3.5 Implication Direction Flip

For `imp φ ψ`, flipping to `imp ψ φ` is straightforward at the primitive level. However, we must be careful:
- `imp` is used for both implication AND negation (`neg φ = imp φ bot`)
- We should only flip genuine implications, not negations

**Pattern**: Match `imp φ ψ` where `ψ != bot` (to exclude negation patterns).

### 3.6 Operator Swap Mutations

The task requests specific operator swaps. We need mutation functions for each pair:

| Swap | Pattern A | Pattern B |
|------|-----------|-----------|
| □↔◇ | `box φ` | `diamond φ` |
| U↔R | `untl φ ψ` | `release φ ψ` |
| F↔G | `some_future φ` | `all_future φ` |
| H↔P | `all_past φ` | `some_past φ` |
| W↔M | `weak_until φ ψ` | `strong_release φ ψ` |
| T↔ST | `trigger φ ψ` | `strong_trigger φ ψ` |

**Implementation note**: Since derived operators are `def` abbreviations, we can pattern-match on both the primitive expansion AND the derived pattern. For reliability, it is best to match on primitive expansions (as done in `complexity` and `hasDerivedTemporal`).

---

## 4. Implementation Pattern Recommendations

### 4.1 Recommended Architecture

Extend the existing `FormulaMutator.lean` module rather than creating a new one. The existing structure is sound:

```
FormulaMutator.lean
├── MutationType (extend with new constructors)
├── ContrastivePair (reuse existing)
├── Local substitution helpers (reuse existing)
├── New: Single-occurrence mutation engine
│   ├── mutateAtOneOccurrence
│   ├── swapBoxDiamond
│   ├── swapUntilRelease
│   ├── swapFutureGlobally / swapGloballyFuture
│   ├── swapPastHistorically / swapHistoricallyPast
│   ├── swapWeakUntilStrongRelease / swapStrongReleaseWeakUntil
│   ├── swapTriggerStrongTrigger / swapStrongTriggerTrigger
│   ├── flipImplication
│   └── removeOneConjunct
├── generateMutations (extend to call new mutation functions)
├── classifyMutation (upgrade to use labelFormula)
├── generateContrastivePairs (reuse)
├── filterContrastive (reuse)
├── JSON serialization (extend with new mutation type strings)
└── Batch/export functions (reuse)
```

### 4.2 New MutationType Constructors

Add to the existing `MutationType` inductive:

```lean
inductive MutationType where
  -- Existing constructors...
  | boxToDiamondAtOccurrence (occurrenceIdx : Nat)
  | diamondToBoxAtOccurrence (occurrenceIdx : Nat)
  | untilToReleaseAtOccurrence (occurrenceIdx : Nat)
  | releaseToUntilAtOccurrence (occurrenceIdx : Nat)
  | futureToGloballyAtOccurrence (occurrenceIdx : Nat)
  | globallyToFutureAtOccurrence (occurrenceIdx : Nat)
  | pastToHistoricallyAtOccurrence (occurrenceIdx : Nat)
  | historicallyToPastAtOccurrence (occurrenceIdx : Nat)
  | weakUntilToStrongReleaseAtOccurrence (occurrenceIdx : Nat)
  | strongReleaseToWeakUntilAtOccurrence (occurrenceIdx : Nat)
  | triggerToStrongTriggerAtOccurrence (occurrenceIdx : Nat)
  | strongTriggerToTriggerAtOccurrence (occurrenceIdx : Nat)
  | flipImplicationAtOccurrence (occurrenceIdx : Nat)
  | removeLeftConjunctAtOccurrence (occurrenceIdx : Nat)
  | removeRightConjunctAtOccurrence (occurrenceIdx : Nat)
```

The `occurrenceIdx` parameter enables tracking which specific occurrence was mutated, important for minimal-pair identification.

### 4.3 Single-Occurrence Mutation Engine

A generic engine that applies a transformation at exactly one occurrence:

```lean
def mutateSingleOccurrence (φ : Formula) (transform : Formula → Option Formula)
    : List (Formula × Nat) :=
  -- Returns list of (mutatedFormula, occurrenceIndex) pairs
```

Implementation via structural recursion with an occurrence counter:

```lean
partial def mutateSingleOccurrenceAux (φ : Formula) (transform : Formula → Option Formula)
    (occCounter : Nat) : List (Formula × Nat) × Nat :=
  -- Try transform at current node
  let direct := match transform φ with
    | some mutated => [(mutated, occCounter)]
    | none => []
  let occCounter' := occCounter + 1
  -- Recurse into children
  let children := match φ with
    | .imp a b =>
      let (aMut, occ1) := mutateSingleOccurrenceAux a transform occCounter'
      let (bMut, occ2) := mutateSingleOccurrenceAux b transform occ1
      aMut ++ bMut.map (fun (m, i) => (.imp a m, i)) ++ bMut.map ...
    | .box a => ...
    | .untl a b => ...
    | .snce a b => ...
    | _ => []
  (direct ++ children, occCounter')
```

*Note*: The exact recursion must preserve unmutated siblings. For example, if mutating the left child of `imp a b`, the result is `imp a' b` where `a'` is the mutated version.

### 4.4 Integration with labelFormula

**Current**: `classifyMutation` calls `decideAuto` directly.

**Recommended**: Change `classifyMutation` to call `labelFormula` instead:

```lean
def classifyMutation (original : Formula) (originalLabel : FormulaLabel)
    (originalProofTrace : Option ProofTrace)
    (mutated : Formula) (mutationType : MutationType) : IO ContrastivePair := do
  let labeled ← labelFormula mutated .Base 1000  -- use 1s wall-clock timeout
  match labeled.label with
  | .valid => ...
  | .invalid => ...  -- use labeled.countermodel, labeled.enrichedCountermodel
  | .timeout => ...
```

Benefits:
- Reuses structural pre-filter (catches ~60% of valid formulas instantly)
- Reuses wall-clock timeout protection
- Reuses enriched countermodel extraction
- Reuses interestingness metrics

### 4.5 JSONL Export Fields

The existing `ContrastivePair.toJson` exports:
- `original`: formula_str, formula_ast, label, proof_trace
- `mutation`: formula_str, formula_ast, label, countermodel, enriched_countermodel
- `mutation_type`: string name
- `mutation_detail`: JSON object with parameters

**Recommended additions** for Task 280:
- `occurrence_index`: which occurrence was mutated
- `mutation_family`: e.g., "modal_swap", "temporal_swap", "structural_flip", "conjunct_removal"
- `original_operator`: e.g., "box", "until", "and"
- `mutated_operator`: e.g., "diamond", "release", "left_conjunct_removed"

This extra metadata is extremely high-signal for model training, as it tells the model exactly what structural feature distinguishes the valid from the invalid formula.

### 4.6 Performance Considerations

**Challenge**: For each valid formula, single-occurrence mutations may generate O(n) mutants where n = number of matching constructors. Running `decideAuto` on each mutant is expensive.

**Mitigation strategies**:
1. **Prioritize high-yield mutations**: Run □↔◇, imp-flip, and conjunct-removal first. Only run temporal swaps if the high-yield mutations don't produce enough pairs.
2. **Batch wall-clock timeouts**: The existing `labelFormula` already uses 1ms polling with 1s deadline.
3. **Skip duplicate mutants**: Use `HashSet` deduplication before labeling.
4. **Parallel labeling**: Reuse the parallel thread infrastructure from `DatasetExport.lean`.
5. **Complexity gate**: Only mutate formulas with complexity ≥ 3 (already in `filterContrastive`).

**Expected yield**:
- For a typical valid formula with complexity 5-7 containing modal/temporal operators, there may be 3-8 applicable single-occurrence mutations.
- Based on the existing mutator's yield rate (~15-30% of mutations produce contrastive pairs), expect 1-3 contrastive pairs per valid formula.

---

## 5. Files Requiring Modification

| # | File | Nature of Change | Estimated Lines |
|---|------|-----------------|-----------------|
| 1 | `Theories/Bimodal/Automation/FormulaMutator.lean` | Add single-occurrence mutation engine, new MutationType constructors, operator swap functions, implication flip, conjunct removal | ~300 |
| 2 | `Theories/Bimodal/Automation/DatasetGenerator.lean` | Potentially export `labelFormula` internals if `classifyMutation` needs access | ~10 |
| 3 | `Theories/Bimodal/Automation/DataExport.lean` | Add new JSON fields for occurrence index, mutation family, operator names | ~30 |
| 4 | `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` *(new)* | Unit tests for each mutation type | ~150 |

---

## 6. Detailed Implementation Plan

### Phase 1: Single-Occurrence Mutation Engine

1. Implement `mutateSingleOccurrence` generic function
2. Implement specific transformation functions:
   - `trySwapBoxDiamond : Formula → Option Formula`
   - `trySwapDiamondBox : Formula → Option Formula`
   - `trySwapUntilRelease : Formula → Option Formula`
   - `trySwapReleaseUntil : Formula → Option Formula`
   - `trySwapFutureGlobally : Formula → Option Formula`
   - `trySwapGloballyFuture : Formula → Option Formula`
   - `trySwapPastHistorically : Formula → Option Formula`
   - `trySwapHistoricallyPast : Formula → Option Formula`
   - `trySwapWeakUntilStrongRelease : Formula → Option Formula`
   - `trySwapStrongReleaseWeakUntil : Formula → Option Formula`
   - `trySwapTriggerStrongTrigger : Formula → Option Formula`
   - `trySwapStrongTriggerTrigger : Formula → Option Formula`
   - `tryFlipImplication : Formula → Option Formula`
   - `tryRemoveLeftConjunct : Formula → Option Formula`
   - `tryRemoveRightConjunct : Formula → Option Formula`

3. Add new `MutationType` constructors for each

### Phase 2: Integrate with Existing Pipeline

1. Extend `generateMutations` to call the new single-occurrence functions
2. Upgrade `classifyMutation` to use `labelFormula` instead of raw `decideAuto`
3. Extend `MutationType.toString`, `toJson`, and `detailJson` for new constructors
4. Extend `ContrastivePair.toJson` with new fields

### Phase 3: Export and Testing

1. Update `writeContrastiveJSONL` if needed
2. Add `computeContrastiveStats` breakdowns for new mutation types
3. Create unit tests verifying:
   - Each mutation produces exactly one structural change
   - Mutated formula differs from original
   - No duplicate mutants within a batch
   - Correct JSON serialization

---

## 7. Zero-Debt Compliance Assessment

This task is **purely automation-layer** — no new axioms, no changes to the proof system or semantics. All mutations are `def` abbreviations operating on the existing `Formula` type.

- **No sorry required**: All mutation functions are computable `def`s
- **No new axioms**: Operator swaps are structural transformations, not logical axioms
- **Decidable equality**: `Formula` derives `DecidableEq` and `BEq`, enabling duplicate detection
- **Proof extraction**: Reuses existing `extractProofTrace` and countermodel infrastructure

The only risk is that `decideAuto` may timeout on some mutants. This is handled by the existing wall-clock timeout in `labelFormula`.

---

## 8. References

- `Theories/Bimodal/Syntax/Formula.lean` — Formula definitions and derived operators
- `Theories/Bimodal/Automation/FormulaMutator.lean` — Existing mutation framework (Task 206)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — Labeling pipeline with pre-filters and timeouts
- `Theories/Bimodal/Automation/DatasetExport.lean` — JSONL export and streaming
- `Theories/Bimodal/Automation/DataExport.lean` — JSON serialization primitives
- `Theories/Bimodal/Automation/TableauBridge.lean` — REPL interface to decision procedure
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — Enumeration with R/W/T/WS/M/ST (Tasks 275, 276)
- `specs/275_surface_rwt_ws_bimodal_interaction/reports/01_research.md`
- `specs/276_strong_release_trigger_operators/reports/01_research.md`
