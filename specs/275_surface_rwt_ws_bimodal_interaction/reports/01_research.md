# Research Report: Task 275 — Surface R/W/T/WS Bimodal Interaction

## 1. Executive Summary

Task 275 requires surfacing four existing derived temporal operators (Release R, Weak Until W, Trigger T, Weak Since WS) into the automation layer so they participate in dataset generation and bimodal-interaction detection. These operators are already defined in `Formula.lean` but are invisible to `hasBimodalInteraction`, `Formula.complexity`, and the formula enumerator. The work is purely automation-layer plumbing — no new axioms or proofs are required.

**Key finding**: `hasBimodalInteraction` and `hasDerivedTemporal` live in `FormulaEnumerator.lean` (not `DatasetGenerator.lean` as the task description states). All changes are localized to `Formula.lean` and `FormulaEnumerator.lean`, with minor test-file additions.

---

## 2. Existing R/W/T/WS Definitions

**File**: `Theories/Bimodal/Syntax/Formula.lean`  
**Lines**: 418–444

| Operator | Lean Name | Definition (primitive expansion) |
|----------|-----------|-------------------------------------|
| Release (R) | `Formula.release φ ψ` | `(Formula.untl φ.neg ψ.neg).neg` |
| Weak Until (W) | `Formula.weak_until φ ψ` | `(Formula.untl φ ψ).or ψ.all_future` |
| Trigger (T) | `Formula.trigger φ ψ` | `(Formula.snce φ.neg ψ.neg).neg` |
| Weak Since (WS) | `Formula.weak_since φ ψ` | `(Formula.snce φ ψ).or ψ.all_past` |

### Full primitive expansions (for pattern-matching)

1. **Release**: `imp (untl (imp φ bot) (imp ψ bot)) bot`
2. **Weak Until**: `imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot)`
   - Note: the right-hand side `imp (untl (imp ψ bot) (imp bot bot)) bot` is exactly the G pattern.
3. **Trigger**: `imp (snce (imp φ bot) (imp ψ bot)) bot`
4. **Weak Since**: `imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot)`
   - Note: the right-hand side `imp (snce (imp ψ bot) (imp bot bot)) bot` is exactly the H pattern.

---

## 3. Current `hasBimodalInteraction` / `hasDerivedTemporal`

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 1694–1716

```lean
private def hasDerivedTemporal : Formula → Bool
  | .atom _ => false
  | .bot => false
  | .box a => hasDerivedTemporal a
  -- Check for G/H patterns: ¬F(¬φ) or ¬P(¬φ)
  | .imp inner .bot =>
    match inner with
    | .untl (.imp _ .bot) (.imp .bot .bot) => true  -- G pattern
    | .snce (.imp _ .bot) (.imp .bot .bot) => true  -- H pattern
    | _ => hasDerivedTemporal inner
  | .imp a b => hasDerivedTemporal a || hasDerivedTemporal b
  -- Check for F/P patterns: untl/snce(φ, ⊤)
  | .untl _ (.imp .bot .bot) => true   -- F pattern
  | .untl a b => hasDerivedTemporal a || hasDerivedTemporal b
  | .snce _ (.imp .bot .bot) => true   -- P pattern
  | .snce a b => hasDerivedTemporal a || hasDerivedTemporal b

def hasBimodalInteraction (φ : Formula) : Bool :=
  hasBox φ && hasDerivedTemporal φ
```

**Problem**: The function only recognizes G, H, F, and P patterns. Formulas built with `release`, `weak_until`, `trigger`, or `weak_since` will return `false` for `hasDerivedTemporal`, making them invisible to bimodal interaction filtering.

### Required additions to `hasDerivedTemporal`

| Operator | Structural pattern to match |
|----------|---------------------------|
| Release (R φ ψ) | `imp (untl (imp φ bot) (imp ψ bot)) bot` |
| Trigger (T φ ψ) | `imp (snce (imp φ bot) (imp ψ bot)) bot` |
| Weak Until (W φ ψ) | `imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot)` |
| Weak Since (WS φ ψ) | `imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot)` |

---

## 4. Current `Formula.complexity` Pattern-Matching

**File**: `Theories/Bimodal/Syntax/Formula.lean`  
**Lines**: 170–184

```lean
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  -- G(φ) = imp (untl (imp φ bot) (imp bot bot)) bot → 1 + φ.complexity
  | imp (untl (imp φ bot) (imp bot bot)) bot => 1 + φ.complexity
  -- H(φ) = imp (snce (imp φ bot) (imp bot bot)) bot → 1 + φ.complexity
  | imp (snce (imp φ bot) (imp bot bot)) bot => 1 + φ.complexity
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  -- F(φ) = untl φ (imp bot bot) → 1 + φ.complexity
  | untl φ (imp bot bot) => 1 + φ.complexity
  | untl φ ψ => 1 + φ.complexity + ψ.complexity
  -- P(φ) = snce φ (imp bot bot) → 1 + φ.complexity
  | snce φ (imp bot bot) => 1 + φ.complexity
  | snce φ ψ => 1 + φ.complexity + ψ.complexity
```

### Complexity impact without pattern-matching (for atomic operands)

| Operator | Current complexity (atoms) | Target complexity (atoms) | Overhead reduction |
|----------|---------------------------|----------------------------|-------------------|
| `release p q` | 7 + 1 + 1 = **9** | 1 + 1 + 1 = **3** | 6 → 0 (fixed) |
| `trigger p q` | 7 + 1 + 1 = **9** | 1 + 1 + 1 = **3** | 6 → 0 (fixed) |
| `weak_until p q` | 5 + 1 + 2 = **8** | 1 + 1 + 1 = **3** | 5 → 0 (fixed) |
| `weak_since p q` | 5 + 1 + 2 = **8** | 1 + 1 + 1 = **3** | 5 → 0 (fixed) |

Note: The task description mentions "overhead from 5-8 to 1-2". The values above show the **total** complexity on atoms. The *additional* overhead beyond the base binary cost of 3 is what gets reduced. With pattern-matching to `1 + φ.complexity + ψ.complexity`, R/W/T/WS are treated as first-class binary temporal operators with the same cost as `untl`/`snce`.

### Recommended `complexity` additions

Insert the following cases **before** the generic `imp φ ψ` case and **before** the generic `untl φ ψ` / `snce φ ψ` cases:

```lean
  -- R(φ, ψ) = release φ ψ = (untl φ.neg ψ.neg).neg → 1 + φ.complexity + ψ.complexity
  | imp (untl (imp φ bot) (imp ψ bot)) bot => 1 + φ.complexity + ψ.complexity
  -- T(φ, ψ) = trigger φ ψ = (snce φ.neg ψ.neg).neg → 1 + φ.complexity + ψ.complexity
  | imp (snce (imp φ bot) (imp ψ bot)) bot => 1 + φ.complexity + ψ.complexity
  -- W(φ, ψ) = weak_until φ ψ = (untl φ ψ).or ψ.all_future → 1 + φ.complexity + ψ.complexity
  | imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot) => 1 + φ.complexity + ψ.complexity
  -- WS(φ, ψ) = weak_since φ ψ = (snce φ ψ).or ψ.all_past → 1 + φ.complexity + ψ.complexity
  | imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot) => 1 + φ.complexity + ψ.complexity
```

---

## 5. FormulaEnumerator Overhead Constants

### 5.1 Exact-complexity enumeration (`enumExactHelper`)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 152–249

The `enumExactHelper` function already generates F/P/G/H as derived unary operators with `overhead = 1` (lines 182–212). Binary `untl`/`snce` are generated in the `binaryFormulas` section (lines 213–245) by splitting `childBudget = n + 1` between left and right children.

**Recommendation**: Add R/W/T/WS generation inside the `binaryFormulas` section, alongside `untl`/`snce`. Since their pattern-matched complexity is `1 + left + right = sizeBudget`, they fit naturally into the existing binary cross-product loop without explicit overhead variables. The `temporalBudget > 0` guard already applies.

Specifically, around line 236–242, after generating `untls` and `snces`, add:

```lean
let releases := tLefts.foldl (fun (acc : Array Formula) l =>
  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.release l r)) acc
) (Array.mkEmpty (tLefts.size * tRights.size))
let weakUntils := tLefts.foldl (fun (acc : Array Formula) l =>
  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.weak_until l r)) acc
) (Array.mkEmpty (tLefts.size * tRights.size))
let triggers := tLefts.foldl (fun (acc : Array Formula) l =>
  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.trigger l r)) acc
) (Array.mkEmpty (tLefts.size * tRights.size))
let weakSinces := tLefts.foldl (fun (acc : Array Formula) l =>
  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.weak_since l r)) acc
) (Array.mkEmpty (tLefts.size * tRights.size))
```

And include them in the returned tuple.

### 5.2 Deterministic random sampling (`sampleOne`)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 399–414

The `sampleOne` function still uses **pre-task-274 overheads** for F/P/G/H:
- F/P: `sizeBudget - 4` (line 402)
- G/H: `sizeBudget - 8` (line 410)

These should be updated to `sizeBudget - 1` to match the post-task-274 reality.

For R/W/T/WS, add a new branch (e.g., `choice == 5 + ...`) that generates them with the same split budget as `untl`/`snce` (since they are binary). Alternatively, add them to the existing `hasTemporal` branch at `choice == 3`.

### 5.3 IO random sampling (`sampleOneRandom`)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 820–846

This function already uses the correct overhead of 1 for F/P/G/H. R/W/T/WS should be added similarly, perhaps by extending the branch at `| 5 =>` (F/P) or adding a new branch for binary derived temporals.

### 5.4 Legacy random subformula (`randomSubFormula`)

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 985–1000

Still uses stale pre-task-274 overheads:
- G/H: `maxSize - 8` (lines 986–992)
- F/P: `maxSize - 4` (lines 994–1000)

These must be updated to `maxSize - 1`.

R/W/T/WS should be added as new branches (e.g., choices 8–11) using the same split-budget logic as `untl`/`snce` (choices 7 and `_`).

### 5.5 `OperatorDistribution` / `countTopOperator`

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`  
**Lines**: 472–530

The `OperatorDistribution` structure (lines 472–487) counts F/P/G/H patterns but has no fields for R/W/T/WS. While not strictly required for the task, adding `releaseCount`, `weakUntilCount`, `triggerCount`, and `weakSinceCount` fields would give visibility into how often these operators appear in generated datasets.

Similarly, `countTopOperator` (lines 501–530) would need pattern-matching cases for R/W/T/WS to populate those counts.

---

## 6. Test Touchpoints

### 6.1 Complexity verification tests

**File**: `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean`  
**Lines**: 375–392

Currently tests:
- `φ.box.complexity = 1 + φ.complexity`
- `φ.all_past.complexity = 1 + φ.complexity`

**Should add** analogous tests for R/W/T/WS:
- `(Formula.release p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.weak_until p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.trigger p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.weak_since p q).complexity = 1 + p.complexity + q.complexity`

### 6.2 C5 smoke test

**File**: `Tests/BimodalTest/Automation/C5SmokeTest.lean`

This test does not directly exercise `hasBimodalInteraction`, but the dataset generation CLI (via `DatasetExport.lean`) uses `FormulaEnumerator` and `DatasetGenerator`. After the changes, regenerating the c5 dataset and verifying the ~3x bimodal formula count increase is the final acceptance criterion.

---

## 7. Files Requiring Modification

| # | File | Lines to touch | Nature of change |
|---|------|---------------|------------------|
| 1 | `Theories/Bimodal/Syntax/Formula.lean` | 170–210 | Add 4 `complexity` pattern-match cases; add `#eval` smoke tests |
| 2 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 1694–1716 | Extend `hasDerivedTemporal` with 4 new patterns |
| 3 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 236–245 | Add R/W/T/WS to `enumExactHelper` binary section |
| 4 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 399–414 | Update stale F/P/G/H overheads in `sampleOne`; add R/W/T/WS |
| 5 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 820–846 | Add R/W/T/WS to `sampleOneRandom` |
| 6 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 985–1020 | Update stale F/P/G/H overheads in `randomSubFormula`; add R/W/T/WS |
| 7 | `Theories/Bimodal/Automation/FormulaEnumerator.lean` | 472–530 | Optional: extend `OperatorDistribution` and `countTopOperator` |
| 8 | `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` | 380+ | Add complexity property tests for R/W/T/WS |

---

## 8. Implementation Scope Estimate

- **Formula.lean**: ~10 lines (4 pattern-match cases + 4 `#eval` tests)
- **FormulaEnumerator.lean** (`hasDerivedTemporal`): ~8 lines (4 new pattern branches)
- **FormulaEnumerator.lean** (`enumExactHelper`): ~20 lines (4 new derived operators in binary section)
- **FormulaEnumerator.lean** (`sampleOne`): ~15 lines (fix stale overheads + add R/W/T/WS)
- **FormulaEnumerator.lean** (`sampleOneRandom`): ~15 lines (add R/W/T/WS branches)
- **FormulaEnumerator.lean** (`randomSubFormula`): ~20 lines (fix stale overheads + add R/W/T/WS)
- **FormulaEnumerator.lean** (`OperatorDistribution` / `countTopOperator`): ~20 lines (optional but recommended)
- **FormulaPropertyTest.lean**: ~12 lines (4 test cases)

**Total**: approximately **4–6 files**, **100–130 lines** of additions/modifications.

---

## 9. Risks and Considerations

1. **Pattern-match ordering in `complexity`**: The new R/W/T/WS patterns must be placed **before** the generic `imp φ ψ`, `untl φ ψ`, and `snce φ ψ` cases, otherwise they will never match. This is the same discipline already used for F/P/G/H.
2. **Weak Until / Weak Since patterns overlap with G/H**: The right-hand side of `weak_until` contains `ψ.all_future`, which expands to the G pattern. If the `imp (untl (imp ψ bot) (imp bot bot)) bot` pattern is checked before the full `weak_until` pattern, `weak_until` might be counted as G. In Lean's `match`, patterns are tried top-to-bottom, so `weak_until` must appear **before** the G pattern.
3. **No proof breakage expected**: The changes are purely in `def`/`private def` automation functions and do not touch the proof system or semantics. The only risk is that `#eval` tests in `Formula.lean` and `FormulaPropertyTest.lean` must be updated/added.
4. **Dataset regeneration**: After code changes, running `lake exe dataset_generator -- --max-complexity 5` and checking bimodal formula counts is the acceptance test. A ~3x increase is expected because R/W/T/WS will now be recognized as derived temporal operators and will pass `hasBimodalInteraction` when combined with `box`.

---

## 10. Summary of Key Findings

- R/W/T/WS are fully defined in `Formula.lean` (lines 418–444) but completely invisible to the automation layer.
- `hasDerivedTemporal` / `hasBimodalInteraction` are in **FormulaEnumerator.lean**, not `DatasetGenerator.lean`.
- `Formula.complexity` needs 4 new pattern-match cases, inserted before the generic binary cases.
- The enumerator needs R/W/T/WS added to all three sampling paths (`enumExactHelper`, `sampleOne`, `sampleOneRandom`, `randomSubFormula`).
- **Stale overhead constants** for F/P/G/H still exist in `sampleOne` (4/8) and `randomSubFormula` (4/8) — these should be corrected to 1 as part of this task.
- Estimated effort: **4–6 files**, **~100–130 lines**, no proof risk.
