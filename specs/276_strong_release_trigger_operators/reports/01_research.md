# Research Report: Task 276 — Strong Release (M) and Strong Trigger (ST) Derived Operators

## Session Information
- **Task**: 276 — strong_release_trigger_operators
- **Session ID**: sess_1780632398_38c2de
- **Date**: 2026-06-04
- **Agent**: lean-research-agent

## 1. Executive Summary

Task 276 requires adding two derived temporal operators to the BimodalLogic TM formalization:
- **Strong Release (M)**: `M(φ,ψ) := ψ U (ψ ∧ φ)`
- **Strong Trigger (ST)**: `ST(φ,ψ) := ψ S (ψ ∧ φ)`

These operators complete the classical LTL operator quartets `{U, W, R, M}` (future) and `{S, WS, T, ST}` (past) used in positive normal form. Research identified 5 primary files requiring changes, with an additional 2-3 files for semantic characterization and axiom schemata.

## 2. Mathematical Definitions

### 2.1 Strong Release — M(φ, ψ)
In standard LTL literature, the strong release operator `M` is the dual of weak until `W`:
```
M(φ, ψ) = ¬W(¬φ, ¬ψ) = (ψ R φ) ∧ F(φ) = ψ U (ψ ∧ φ)
```
In Burgess convention (`untl event guard`), where `untl φ ψ` means "ψ holds until φ becomes true":
```lean
def strong_release (φ ψ : Formula) : Formula := Formula.untl (Formula.and ψ φ) ψ
```
**Primitive expansion**: `untl (imp (imp ψ (imp φ bot)) bot) ψ`

### 2.2 Strong Trigger — ST(φ, ψ)
The past dual of strong release:
```
ST(φ, ψ) = ¬WS(¬φ, ¬ψ) = (ψ T φ) ∧ P(φ) = ψ S (ψ ∧ φ)
```
In Burgess convention (`snce event guard`):
```lean
def strong_trigger (φ ψ : Formula) : Formula := Formula.snce (Formula.and ψ φ) ψ
```
**Primitive expansion**: `snce (imp (imp ψ (imp φ bot)) bot) ψ`

## 3. Files Requiring Changes

### 3.1 Core Syntax: `Theories/Bimodal/Syntax/Formula.lean`
**Changes needed** (after existing `weak_since` definition, around line 452):

1. **Add operator definitions** (~2 lines):
   ```lean
   /-- Strong Release operator M(φ, ψ) — ψ U (ψ ∧ φ). Dual of weak until. -/
   def strong_release (φ ψ : Formula) : Formula := Formula.untl (Formula.and ψ φ) ψ
   
   /-- Strong Trigger operator ST(φ, ψ) — ψ S (ψ ∧ φ). Past dual of strong release. -/
   def strong_trigger (φ ψ : Formula) : Formula := Formula.snce (Formula.and ψ φ) ψ
   ```

2. **Add complexity pattern-matching** (~2 lines, in `complexity` function after weak_since pattern):
   ```lean
   -- M(φ, ψ) = strong_release φ ψ = untl (ψ.and φ) ψ → 2 + φ.complexity + ψ.complexity
   | untl (imp (imp ψ (imp φ bot)) bot) ψ2 => 2 + φ.complexity + ψ.complexity
   -- ST(φ, ψ) = strong_trigger φ ψ = snce (ψ.and φ) ψ → 2 + φ.complexity + ψ.complexity
   | snce (imp (imp ψ (imp φ bot)) bot) ψ2 => 2 + φ.complexity + ψ.complexity
   ```
   *Note: Using `ψ2` for the guard position because Lean pattern matching does not support repeated variable names to enforce equality (consistent with the `weak_until`/`weak_since` patterns which use `ψ2`).*

3. **Add complexity verification #eval tests** (~4 lines, after WS test):
   ```lean
   -- M(atom, atom) should be 4
   #eval (Formula.strong_release p_cmplx2 q_cmplx2).complexity  -- 4
   -- ST(atom, atom) should be 4
   #eval (Formula.strong_trigger p_cmplx2 q_cmplx2).complexity  -- 4
   ```

4. **Add swap_temporal lemmas** (~2 theorems, after swap_temporal_prev):
   ```lean
   /-- swap_temporal distributes over strong_release/strong_trigger: swap(M(φ,ψ)) = ST(swap(φ),swap(ψ)). -/
   theorem swap_temporal_strong_release (φ ψ : Formula) :
       (Formula.strong_release φ ψ).swap_temporal = Formula.strong_trigger φ.swap_temporal ψ.swap_temporal := by
     simp [strong_release, strong_trigger, and, swap_temporal]
   
   theorem swap_temporal_strong_trigger (φ ψ : Formula) :
       (Formula.strong_trigger φ ψ).swap_temporal = Formula.strong_release φ.swap_temporal ψ.swap_temporal := by
     simp [strong_release, strong_trigger, and, swap_temporal]
   ```

### 3.2 Normalization: `Theories/Bimodal/Automation/Normalization.lean`
**Changes needed**:

1. **Add unfold lemmas** (~2 theorems, in `UnfoldLemmas` section):
   ```lean
   /-- Unfold strong_release: `strong_release φ ψ = untl (and ψ φ) ψ` expanded to primitives -/
   @[simp] theorem strong_release_unfold (φ ψ : Formula) :
       Formula.strong_release φ ψ = Formula.untl (Formula.and ψ φ) ψ := rfl
   
   /-- Unfold strong_trigger: `strong_trigger φ ψ = snce (and ψ φ) ψ` expanded to primitives -/
   @[simp] theorem strong_trigger_unfold (φ ψ : Formula) :
       Formula.strong_trigger φ ψ = Formula.snce (Formula.and ψ φ) ψ := rfl
   ```

2. **Update tactic macros** to include new unfold lemmas (~2 tactics):
   - `modal_norm`, `modal_norm_at`, `modal_norm_all`, `modal_fold`

3. **Add EnrichedFormula constructors** (~2 constructors):
   ```lean
   | strong_release : EnrichedFormula → EnrichedFormula → EnrichedFormula
   | strong_trigger : EnrichedFormula → EnrichedFormula → EnrichedFormula
   ```

4. **Update `toPrimitive`** (~2 cases):
   ```lean
   | .strong_release φ ψ => Formula.strong_release φ.toPrimitive ψ.toPrimitive
   | .strong_trigger φ ψ => Formula.strong_trigger φ.toPrimitive ψ.toPrimitive
   ```

5. **Update `foldFormula` / `recognizeComposites`** (~2 cases):
   Since M/ST expand to `untl (and ...) _` and `snce (and ...) _`, and `and` is already recognized in `foldImp`, the fold algorithm may need explicit cases in `recognizeComposites` or `foldFormula` to recognize the `untl/snce` patterns with `and` children.
   *Recommendation*: Add recognition in `recognizeComposites` for:
   - `untl (and_ ψ φ) ψ` → `strong_release φ ψ`
   - `snce (and_ ψ φ) ψ` → `strong_trigger φ ψ`

6. **Update serialization** (~2 cases each in `toJson`, `prettyPrint`, `toSExpr`):
   ```lean
   | .strong_release φ ψ => "M(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
   | .strong_trigger φ ψ => "ST(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
   ```

### 3.3 Formula Enumeration: `Theories/Bimodal/Automation/FormulaEnumerator.lean`
**Changes needed** in ~5 functions:

1. **`enumExactHelper`** (exact enumeration, line ~242): Add `strongReleases` and `strongTriggers` arrays alongside existing `releases`/`triggers`:
   ```lean
   let strongReleases := tLefts.foldl (fun acc l =>
     tRights.foldl (fun acc' r => acc'.push (Formula.strong_release l r)) acc) ...
   let strongTriggers := tLefts.foldl (fun acc l =>
     tRights.foldl (fun acc' r => acc'.push (Formula.strong_trigger l r)) acc) ...
   ```
   Update the result tuple to include them.

2. **`sampleOne`** (LCG-based sampling, line ~446): Expand the `rtwsChoice` from 4 to 6 options:
   ```lean
   let rtwsChoice ← IO.rand 0 5
   match rtwsChoice with
   | 0 => return .release left right
   | 1 => return .weak_until left right
   | 2 => return .trigger left right
   | 3 => return .weak_since left right
   | 4 => return .strong_release left right
   | _ => return .strong_trigger left right
   ```
   *Note: This pattern appears in at least 4 locations (lines ~879, ~902, ~920, ~1107).*

3. **`sampleOneRandom`** (random generation): Same expansion in at least 3 branches (lines ~873, ~896, ~914).

4. **`randomSubFormula`** (line ~1100): Expand from 4 to 6 options.

5. **`hasDerivedTemporalBinary`**: This predicate already covers all derived binary temporal operators. No change needed unless specifically scoped.

### 3.4 Interestingness Metrics: `Theories/Bimodal/Automation/InterestingnessMetrics.lean`
**Changes needed**:

The `OperatorProfile` structure and `extractOperatorProfile` function do **not** currently have explicit fields for `release`, `weak_until`, `trigger`, `weak_since`. These derived binary operators are implicitly counted as `hasUntil` / `hasSince` because they expand to primitive `untl`/`snce`. The same applies to M/ST.

*Recommendation*: **No change required** unless the task explicitly wants to track M/ST as distinct operator types. Since M/ST are derived from `untl`/`snce`, they naturally fall under the existing `hasUntil`/`hasSince` classification.

### 3.5 Proof System Axioms: `Theories/Bimodal/ProofSystem/Axioms.lean`
**Changes needed** (if bimodal interaction schemata are required per task description):

The task description mentions: "(5) Add axiom schemata for M/ST interactions with modal operators."

However, looking at the existing axiom system, there are **no** operator-specific axioms for `release`, `weak_until`, `trigger`, or `weak_since`. The temporal axioms (BX1-BX12) are phrased in terms of primitive `untl`/`snce`. Since M/ST are derived operators, their interaction properties (e.g., `□φ → G(M(φ,ψ))`) are theorems that can be derived from existing axioms + the definitions.

*Recommendation*: **Defer adding new axiom schemata to the implementation phase** and instead derive the interaction theorems in `Theorems/` using existing axioms. If the task specifically requires new constructors in the `Axiom` inductive type, they can be added as derived operator axioms, but this is unusual since the existing system avoids operator-specific axioms for derived operators.

### 3.6 Semantics / Truth: `Theories/Bimodal/Semantics/Truth.lean`
**Changes needed**:

Add `@[simp]` characterization theorems for the truth conditions of M and ST (~2 theorems):
```lean
@[simp] theorem strong_release_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (φ ψ : Formula) :
    truth_at M Omega τ t (Formula.strong_release φ ψ) ↔
      ∃ s : D, t < s ∧ truth_at M Omega τ s (Formula.and ψ φ) ∧
        ∀ r : D, t < r → r < s → truth_at M Omega τ r ψ := by
  simp [Formula.strong_release, Formula.and, truth_at]
```

Similarly for `strong_trigger_iff` with past-directed inequalities.

*Note*: Since M/ST are `def` abbreviations, these theorems are technically derivable from existing lemmas via `simp`, but having explicit `@[simp]` lemmas improves automation performance and clarity.

### 3.7 Other Files to Review
- `Theories/Bimodal/Automation/DatasetExport.lean` / `DataExport.lean`: If these export formula structures, they may need updates for new constructors.
- `Tests/BimodalTest/`: Test suite should add coverage for M/ST complexity, normalization, and enumeration.

## 4. Pattern Analysis: How R/WU/T/WS Were Integrated

The existing operators (`release`, `weak_until`, `trigger`, `weak_since`) are integrated in the following pattern:

1. **Syntax**: `def` abbreviations in `Formula.lean` (lines 417-452)
2. **Complexity**: Pattern-matched cases in the `complexity` function with overhead ~1 (lines 173-184)
3. **Enumeration**: Added to exact enumeration, random sampling, and `randomSubFormula` in `FormulaEnumerator.lean`
4. **Normalization**: Not added to `Normalization.lean` (no unfold/fold lemmas, no EnrichedFormula constructors)
5. **Semantics**: No explicit `@[simp]` lemmas in `Truth.lean`
6. **Axioms**: No dedicated axiom schemata in `Axioms.lean`
7. **Metrics**: No explicit tracking in `InterestingnessMetrics.lean`

*Key insight*: Task 275 appears to have done a "light" integration — adding syntax, complexity, and enumeration — but **not** adding full normalization (EnrichedFormula) or semantic characterization lemmas. Task 276 should follow the same pattern for consistency, with optional additions if time permits.

## 5. Implementation Recommendations

### 5.1 Minimal Viable Implementation (matches Task 275 pattern)
1. `Formula.lean`: Add `strong_release`, `strong_trigger` definitions + complexity patterns + eval tests + swap lemmas
2. `FormulaEnumerator.lean`: Add to exact enumeration and all random sampling functions
3. `Normalization.lean`: Add unfold lemmas + update tactic macros (optional but recommended)

### 5.2 Full Implementation (recommended for completeness)
Add the above plus:
4. `Normalization.lean`: Add EnrichedFormula constructors, fold recognition, serialization
5. `Truth.lean`: Add `@[simp]` characterization theorems
6. `Theorems/`: Add derived theorems for M/ST properties (e.g., duality, interaction with box)
7. `Tests/`: Add unit tests

### 5.3 Zero-Debt Compliance
- All definitions should be `def` abbreviations (no new inductive constructors in `Formula`)
- Complexity must be verified with `#eval` tests
- No `sorry` placeholders — all lemmas should be provable from existing infrastructure
- If bimodal interaction theorems are too complex, derive them from existing axioms using the definitions rather than adding new axiom constructors

## 6. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Complexity pattern ambiguity | Low | Test with `#eval` to verify pattern matches correctly |
| EnrichedFormula fold recognition interference | Medium | Add M/ST recognition in `recognizeComposites` after `and_` recognition to avoid ambiguity |
| Enumeration blowup from 4→6 binary operators | Low | The enum functions already scale with cross-product size; adding 2 more operators increases output by ~50% at each temporal level, which is acceptable |
| Missing file updates | Medium | Use grep for `release\|weak_until\|trigger\|weak_since` to find all locations needing parallel updates |

## 7. Verification Plan

After implementation, verify:
1. `#eval (Formula.strong_release p q).complexity` returns 4 for atoms p, q
2. `#eval (Formula.strong_trigger p q).complexity` returns 4 for atoms p, q
3. `lake build` succeeds with no errors
4. `generateBimodalSlice` at complexity 5 produces formulas containing M/ST operators
5. Round-trip tests: `Formula.foldFormulaFull` correctly recognizes M/ST patterns

## 8. References

- `Theories/Bimodal/Syntax/Formula.lean` — Existing operator definitions (lines 417-452)
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — Enumeration and sampling (lines 242-254, 446-451, 873-923, 1100-1110)
- `Theories/Bimodal/Automation/Normalization.lean` — Normalization and folding (full file)
- `Theories/Bimodal/Semantics/Truth.lean` — Truth characterization (lines 214-287)
- `specs/TODO.md` — Task 276 description (line 188)
