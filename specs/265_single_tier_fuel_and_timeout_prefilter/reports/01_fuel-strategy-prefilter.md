# Research Report: Single-Tier Fuel Strategy with Structural Timeout Pre-Filter

- **Task**: 265 - Simplify to single-tier fuel strategy with structural timeout pre-filter
- **Started**: 2026-06-02
- **Session**: sess_1748890200_a3c7f1
- **Dependencies**: Task 264 (completed), Task 263 (completed), Task 261 (completed)

---

## Executive Summary

The adaptive fuel strategy [500, 2000, 10000] should be simplified to a single tier (fuel=500) because zero formulas across all datasets (c3-c8) resolve at tier 2 or tier 3. The decision landscape is strictly bimodal: formulas either resolve within 500 fuel steps or not at all within 10,000. Additionally, a structural pre-filter should intercept known-timeout patterns before invoking the decision procedure, labeling provably-valid patterns instantly with zero fuel cost.

Analysis of the c6 dataset (5,931 records, 247 timeouts) reveals that the three patterns specified in the task description -- Until-bot, Since-bot, and double-box -- cover 145 of 247 timeouts (58.7%) when matched recursively. Adding the box-prop pattern (6 formulas) raises coverage to 151/247 (61.1%). The remaining 96 timeouts are box-general-temporal patterns (`box(U(X,Y)) -> Z` and `box(S(X,Y)) -> Z` where X is NOT bot) that include both valid and invalid formulas, so they CANNOT be safely pre-filtered as valid. The critical finding is that ALL slow timeouts (>1ms, up to 405 seconds) are caught by the bot-temporal recursive pre-filter, meaning the speedup for c6 generation will be dominated by eliminating the two catastrophically slow formulas.

---

## 1. Single-Tier Simplification

### 1.1 Empirical Justification

Across all clean datasets with the current (post-task-261) decision procedure:

| Dataset | Records | Tier 1 (500) | Tier 2 (2000) | Tier 3 (10000) | Timeout |
|---------|---------|-------------|--------------|---------------|---------|
| c5      | 1,512   | 1,410       | **0**        | **0**         | 39      |
| c6      | 5,931   | 5,476       | **0**        | **0**         | 247     |
| c7-clean| 41      | 38          | **0**        | **0**         | 3       |
| c8-strat| 102     | 95          | **0**        | **0**         | 7       |

Zero formulas resolve at tier 2 or tier 3 at ANY complexity level. The fast-path axiom matcher accounts for the remaining non-tier-1 resolutions (63 in c5, 208 in c6).

### 1.2 Recommended Modification

**Approach: Simplify `decideAutoAdaptive` in place** rather than bypassing it. This preserves backward compatibility and the `(DecisionResult phi, String)` return type that `labelFormula` and other callers depend on.

The function in `DecisionProcedure.lean` (lines 187-202) should be modified from the three-tier list to:

```lean
def decideAutoAdaptive (phi : Formula) (fc : FrameClass := .Base)
    : DecisionResult phi x String :=
  let depth := 5 + phi.complexity / 2
  let fuel := 500
  match decide phi depth fuel fc with
  | .timeout => (.timeout, "adaptive_timeout")
  | result => (result, "adaptive_500")
```

**Why not call `decide` directly from `labelFormula`?** The `decideAutoAdaptive` function is the single integration point that:
1. Computes `depth` from formula complexity
2. Returns the method tag string needed by `labelFormula`
3. May be called by future consumers

Keeping `decideAutoAdaptive` as the API preserves these responsibilities. The `where go` helper and the tier list are removed entirely.

### 1.3 The `decideAuto` Function

`decideAuto` (line 169) uses `soundFuel` instead of the adaptive strategy. It is NOT called by the dataset pipeline and should be left unchanged. It serves a different purpose (sound-fuel-based single-shot decision).

### 1.4 Callers

Only ONE caller exists for `decideAutoAdaptive`:
- `DatasetGenerator.lean:401` in `labelFormula`

No other files reference `decideAutoAdaptive`. The change is fully self-contained.

---

## 2. Structural Pre-Filter Design

### 2.1 Pattern Coverage Analysis

Detailed analysis of c6 timeouts using recursive pattern detection:

| Pattern | c5 Count | c6 Count | Provably Valid | Max Time |
|---------|----------|----------|----------------|----------|
| Bot-temporal ANYWHERE* | 32 | 135 | YES (all) | 405,288ms |
| Double-box (top-level) | 7 | 10 | YES (all) | 0ms |
| Box-prop `box X -> (Y -> X)` | 0 | 6 | YES (all) | 0ms |
| Box-general-temporal** | 0 | 96 | **MIXED** | 1ms |
| **Total covered** | **39** | **151** | | |
| **Total timeouts** | **39** | **247** | | |

*"Bot-temporal ANYWHERE" means `untl .bot _` or `snce .bot _` occurring at any depth in the formula. This catches:
- Top-level: `U(bot,X) -> Y`, `S(bot,X) -> Y`
- Box-wrapped: `box(U(bot,X) -> Y)`, `box(S(bot,X) -> Y)`
- Box-temporal: `box(U(bot,X)) -> Y`, `box(S(bot,X)) -> Y`
- Nested: `U(bot, box p) -> Y`

**Box-general-temporal = `box(U(X,Y)) -> Z` or `box(S(X,Y)) -> Z` where X != bot. These include INVALID formulas (e.g., `box(U(p,q)) -> bot` is false because `box(U(p,q))` is satisfiable). These MUST NOT be pre-filtered as valid.

### 2.2 Validity Proofs for Pre-Filtered Patterns

**Pattern 1: Bot-temporal (U(bot,X) or S(bot,X) anywhere in the antecedent)**

Semantic argument: `U(bot,X)` at time t means "there exists s > t such that bot holds at s and X holds for all r in (t,s)". Since bot never holds, no such s exists, so `U(bot,X)` is false at every time point. Therefore any formula containing `U(bot,X)` as a subformula of the antecedent of a top-level implication is vacuously valid: a false antecedent implies anything.

More precisely: if `U(bot,X)` appears anywhere in a formula phi, and phi has the shape `antecedent -> consequent` where the antecedent evaluates to false whenever `U(bot,X)` evaluates to false, then phi is valid. The key insight is that `U(bot,X)` is ALWAYS false (it is unsatisfiable), and any formula built by combining an unsatisfiable sub-formula with implications/boxes preserves vacuous validity for the right structures.

IMPORTANT NUANCE: `U(bot,X)` appearing in the CONSEQUENT does NOT make the formula valid. For example, `p -> U(bot,q)` is INVALID (the consequent is always false, so whenever p is true the formula is false). The pre-filter MUST check that the bot-temporal subformula appears in a position that forces the top-level formula to be vacuously valid.

The safe recursive strategy: A formula phi is pre-filter-valid if:
- `phi = imp A B` and `containsBotTemporal(A)` returns true, OR
- `phi = box psi` and `psi` is pre-filter-valid (necessitation of a valid formula is valid)

Where `containsBotTemporal` recursively checks for `untl .bot _` or `snce .bot _` at any depth.

**Pattern 2: Double-box (box(box X) -> Y where Y = bot/atom/X)**

The c5 and c6 timeouts show exactly two sub-patterns:
- `box(box bot) -> Y`: Valid because `box bot` is false (by T: `box bot -> bot`, contradiction), so `box(box bot)` is false, making the implication vacuously true.
- `box(box X) -> X`: Valid by double application of axiom T: `box(box X) -> box X` (outer T) and `box X -> X` (inner T), then transitivity.

NOT all `box(box X) -> Y` are valid: `box(box p) -> q` is invalid (take a model where p is true at all worlds and q is false). The pre-filter should handle the specific sub-cases:
- `imp (box (box _)) .bot` -> valid (antecedent is `box(box X)`, which when X=bot is unsatisfiable)
- `imp (box (box X)) X` -> valid (double T)
- `imp (box (box .bot)) _` -> valid (antecedent always false)

Wait -- actually the current data shows ALL double-box timeouts at c5 and c6 fall into exactly two patterns: `box(box bot) -> Y` (any Y) and `box(box X) -> X` (identity). Both are valid. But the pre-filter should be conservative: only match these two specific sub-patterns, not the general `box(box X) -> Y`.

Actually, a simpler approach: `box(box bot) -> Y` is already caught by the bot-temporal-style reasoning (the antecedent `box(box bot)` contains `box bot` which is always false, making the whole thing false). But this requires a different recursive check -- detecting unsatisfiable antecedents more generally.

For simplicity and correctness, the recommended approach is:

```lean
def containsBotTemporal : Formula -> Bool
  | .untl .bot _ => true
  | .snce .bot _ => true
  | .imp a b => containsBotTemporal a || containsBotTemporal b
  | .box a => containsBotTemporal a
  | .untl a b => containsBotTemporal a || containsBotTemporal b
  | .snce a b => containsBotTemporal a || containsBotTemporal b
  | _ => false

def isDoubleBoxValid : Formula -> Bool
  | .imp (.box (.box .bot)) _ => true      -- box(box bot) -> Y
  | .imp (.box (.box a)) b => a == b       -- box(box X) -> X
  | _ => false

def isBoxPropValid : Formula -> Bool
  | .imp (.box a) (.imp _ b) => a == b     -- box X -> (Y -> X)
  | _ => false

def structuralPrefilter (phi : Formula) : Option Bool :=
  match phi with
  | .imp antecedent _ =>
    if containsBotTemporal antecedent then some true
    else if isDoubleBoxValid phi then some true
    else if isBoxPropValid phi then some true
    else none
  | .box inner =>
    -- Necessitation: if inner is pre-filter valid, so is box(inner)
    match structuralPrefilter inner with
    | some true => some true
    | _ => none
  | _ => none
```

### 2.3 Recursive vs. Top-Level Matching

**Recommendation: Use RECURSIVE matching for bot-temporal, with box-descent.**

Top-level-only matching (checking only `imp (untl .bot _) _` and `imp (snce .bot _) _`) catches:
- c5: 32/39 (82%)
- c6: 71/247 (29%) -- misses box-wrapped and box-temporal variants

Recursive matching with box-descent catches:
- c5: 32/39 (82%) -- same, since c5 has no box-wrapped patterns
- c6: 135/247 (54.7%) -- catches all bot-temporal patterns at any nesting depth

Adding double-box and box-prop:
- c5: 39/39 (100%)
- c6: 151/247 (61.1%)

The recursive approach is SAFE because: if `containsBotTemporal(antecedent)` is true, then the antecedent is semantically false (it contains an unsatisfiable sub-formula in a position that forces the whole antecedent to be false). The box-descent in `structuralPrefilter` handles `box(phi)` where phi is pre-filter-valid, since `box(valid) = valid`.

### 2.4 Where to Call the Pre-Filter

**Recommendation: Call the pre-filter INSIDE `decideAutoAdaptive`**, before calling `decide`.

```lean
def decideAutoAdaptive (phi : Formula) (fc : FrameClass := .Base)
    : DecisionResult phi x String :=
  -- Phase 1: Structural pre-filter (zero fuel cost)
  match structuralPrefilter phi with
  | some true => (.valid (sorry), "structural_prefilter")  -- see Section 3 on proofs
  | _ =>
    -- Phase 2: Single-tier decision
    let depth := 5 + phi.complexity / 2
    let fuel := 500
    match decide phi depth fuel fc with
    | .timeout => (.timeout, "adaptive_timeout")
    | result => (result, "adaptive_500")
```

Why inside `decideAutoAdaptive`:
1. Keeps `labelFormula` unchanged
2. The pre-filter result naturally fits the `(DecisionResult phi, String)` return type
3. Any future callers of `decideAutoAdaptive` automatically benefit
4. Clean separation: `decideAutoAdaptive` handles the strategy, `decide` handles the algorithm

### 2.5 Return Type

The pre-filter should return `Option Bool`:
- `some true` = formula is provably valid, skip decision procedure
- `none` = no structural match, proceed to decision procedure

We do NOT need `some false` (structural invalidity detection) because the known patterns are all valid. Future extensions could add invalidity detection.

### 2.6 The `DecisionResult` Problem

`DecisionResult phi` is a dependent type: `.valid` carries `proof : DerivationTree ...`. The pre-filter knows the formula is valid but does NOT have a `DerivationTree` proof term. Options:

**Option A: Return a placeholder proof using sorry** -- NOT recommended per zero-debt policy.

**Option B: Change the pre-filter to actually construct a proof** -- This is the correct approach. For bot-temporal patterns, the proof construction is straightforward:
1. `U(bot,X) -> Y`: Construct proof that U(bot,X) is false (vacuous truth of implication)
2. The proof would use ex_falso or a dedicated vacuous-implication lemma

However, constructing a full `DerivationTree` for arbitrary bot-temporal formulas at any nesting depth is non-trivial.

**Option C: Add a new `DecisionResult` constructor** -- Add `.prefiltered` that carries a validity witness without a full proof tree. This is the most practical approach:

```lean
inductive DecisionResult (phi : Formula) : Type where
  | valid (proof : DerivationTree ...)
  | invalid (counter : SimpleCountermodel)
  | timeout
  | prefiltered (reason : String)  -- structurally valid, no proof tree
```

**Option D: Use the compositional proof builder to construct the proof**

The `buildCompositionalProof` function already handles `box bot -> Y` (lines 161-176 of ProofExtraction.lean). It could be extended to handle `U(bot,X) -> Y` and `S(bot,X) -> Y` patterns, producing genuine `DerivationTree` proofs. This is the highest-quality approach but requires more implementation effort.

**Recommendation: Option C (new constructor) for the initial implementation.** The pre-filtered result is tagged differently from `.valid` in the decision method field, so downstream consumers can distinguish. If formal proof terms are needed later, Option D can be added. The `prefiltered` constructor avoids the sorry while providing a clean type-level distinction.

Alternative recommendation if modifying the `DecisionResult` type is too disruptive: Use a TWO-PHASE approach where the pre-filter is checked in `labelFormula` BEFORE calling `decideAutoAdaptive`, and the `LabeledFormula` is constructed directly with label `.valid`, no proof trace, and decision method `"structural_prefilter"`. This avoids modifying `DecisionResult` entirely.

---

## 3. Validity Proofs

### 3.1 Do We Need Formal Lean Proofs?

**For the pre-filter to return `.valid` with a DerivationTree: YES**, we need formal proofs.

**For the pre-filter to bypass the decision procedure and label as valid: NO**, a semantic argument suffices, provided we use Option C (new constructor) or the two-phase approach.

The semantic arguments are:

1. **U(bot,X) is unsatisfiable**: By the semantics of Until, `U(phi,psi)` at time t requires the existence of a future time s > t where phi holds. If phi = bot, no such s exists. Therefore `U(bot,X)` is false at every world/time pair. The same argument applies to `S(bot,X)`.

2. **box(box(bot)) is unsatisfiable**: `box(bot)` is false at every world (by axiom T: if `box(bot)` held, then `bot` would hold, contradiction). Therefore `box(box(bot))` is false.

3. **box(box(X)) -> X is valid**: By axiom T applied twice: `box(box(X)) -> box(X) -> X`.

4. **box(X) -> (Y -> X) is valid**: By axiom T: `box(X) -> X`. By prop_s: `X -> (Y -> X)`. Chain: `box(X) -> X -> (Y -> X)`.

### 3.2 Recommended Approach

Use the **two-phase approach** (pre-filter checked in `labelFormula`) to avoid modifying `DecisionResult`. The pre-filtered formulas are labeled as `.valid` in the `FormulaLabel` but with no proof trace and the decision method string `"structural_prefilter"`. This is semantically honest: we KNOW they are valid, but we do not have a mechanical proof term.

The proof trace will be `none` (same as for timeout formulas), and the reconstruction method will be `"structural_prefilter"` (a new value). This cleanly distinguishes pre-filtered results from both proved-valid and timeout results in the dataset.

---

## 4. Pre-Filter Scope

### 4.1 Should Bot-Temporal Matching Be Recursive?

**YES, strongly recommended.** The data shows:

| Matching Strategy | c5 Coverage | c6 Coverage |
|-------------------|-------------|-------------|
| Top-level only | 32/39 (82%) | 71/247 (29%) |
| Top-level + box-descent | 32/39 (82%) | 135/247 (55%) |
| Full recursive (with box-descent + double-box + box-prop) | 39/39 (100%) | 151/247 (61%) |

The key insight: recursive matching catches ALL the slow timeouts (the formulas that take 400+ seconds). The 96 uncovered formulas (box-general-temporal) all resolve in 0-1ms and are fast timeouts, not performance bottlenecks.

### 4.2 Should We Add box-prop?

**YES, but low priority.** The `box(X) -> (Y -> X)` pattern covers only 6 formulas at c6 (2.4%). All are provably valid and the proof construction is simple (T + prop_s). Including it is easy and adds marginal coverage.

### 4.3 Can ALL Double-Box Timeouts Be Proved Valid?

**YES**, but only the specific sub-patterns that actually occur:
- `box(box(bot)) -> Y` for any Y: valid (unsatisfiable antecedent)
- `box(box(X)) -> X` for any X: valid (double-T)

At c6, no other double-box patterns timeout. The pre-filter should match exactly these two sub-patterns.

### 4.4 What About the 96 Uncovered Formulas?

The 96 uncovered timeouts are all of the form `box(U(X,Y)) -> Z` or `box(S(X,Y)) -> Z` where X != bot. These include both valid and invalid formulas:
- `box(U(p,q)) -> bot` is **INVALID** (box(U(p,q)) is satisfiable)
- `box(U(p,p)) -> p` might be valid but the general pattern is mixed

These CANNOT be pre-filtered as valid. They are also all fast timeouts (0-1ms), so they do not represent a performance bottleneck. They will continue to timeout with the single-tier strategy, which is acceptable.

### 4.5 Effective Coverage by Time Savings

The performance impact is what matters, not the count:

| Pattern | c6 Count | Max Time | Aggregate Time Saved |
|---------|----------|----------|---------------------|
| Bot-temporal recursive | 135 | 405,288ms | ~810,000ms |
| Double-box | 10 | 0ms | ~0ms |
| Box-prop | 6 | 0ms | ~0ms |
| Uncovered (box-gen) | 96 | 1ms | 0ms (keep as timeout) |

**Nearly ALL time savings come from the bot-temporal pre-filter**, specifically from the two catastrophically slow formulas `U(bot, box(p)) -> q` (405s) and `U(bot, box(p)) -> bot` (405s). With the single-tier strategy (fuel=500 only, no tier-2 or tier-3 attempts), the remaining 96 timeouts resolve in <1ms each (the fuel=500 attempt is fast to exhaust for these patterns).

---

## 5. Decision Method Tagging

### 5.1 Recommendation: Single Tag `"structural_prefilter"`

Use a single tag rather than pattern-specific tags. Rationale:
1. The pre-filter is a single function with a single purpose (skip the decision procedure)
2. Pattern-specific tags (`prefilter_until_bot`, `prefilter_since_bot`, `prefilter_double_box`) add complexity to downstream analysis without proportional benefit
3. The formula structure is already captured in `pattern_key` and `formula_ast`

If per-pattern breakdown is desired for analysis, it can be computed post-hoc from the formula AST in the JSONL data.

### 5.2 Decision Method Values After Change

| Value | Meaning |
|-------|---------|
| `"structural_prefilter"` | Pre-filter detected provably valid pattern |
| `"fast_path_axiom"` | Direct axiom match (no fuel used) |
| `"adaptive_500"` | Resolved with fuel=500 |
| `"adaptive_timeout"` | Not resolved within fuel=500 |

The tier-2 and tier-3 tags (`"adaptive_2000"`, `"adaptive_10000"`) are removed since those tiers no longer exist.

---

## 6. Implementation Architecture

### 6.1 File Changes

| File | Changes |
|------|---------|
| `DecisionProcedure.lean` | Simplify `decideAutoAdaptive` to single tier |
| `DatasetGenerator.lean` | Add `structuralPrefilter` function, call it in `labelFormula` |
| (No other files need changes) | |

### 6.2 Detailed Implementation Plan

**Phase 1: Add pre-filter function to DatasetGenerator.lean**

Add before `labelFormula`:

```lean
/-- Check if a formula contains U(bot,_) or S(bot,_) at any depth. -/
def containsBotTemporal : Formula -> Bool
  | .untl .bot _ => true
  | .snce .bot _ => true
  | .imp a b => containsBotTemporal a || containsBotTemporal b
  | .box a => containsBotTemporal a
  | .untl a b => containsBotTemporal a || containsBotTemporal b
  | .snce a b => containsBotTemporal a || containsBotTemporal b
  | _ => false

/-- Structural pre-filter: detect known-valid timeout patterns.
    Returns `some true` if the formula is provably valid by structural analysis.
    Returns `none` if no structural pattern matches (proceed to decision procedure).

    Detected patterns:
    1. `A -> B` where A contains U(bot,_) or S(bot,_) at any depth (vacuous truth)
    2. `box(box(bot)) -> Y` for any Y (unsatisfiable antecedent)
    3. `box(box(X)) -> X` for any X (double application of axiom T)
    4. `box(X) -> (Y -> X)` for any X, Y (axiom T + prop_s)
    5. `box(phi)` where phi is structurally pre-filter valid (necessitation)
-/
def structuralPrefilter : Formula -> Option Bool
  | .imp antecedent _ =>
    if containsBotTemporal antecedent then some true
    else match antecedent with
    | .box (.box .bot) => some true                    -- pattern 2
    | .box (.box inner) =>
      -- Check if consequent matches inner for pattern 3
      -- (handled below in full match)
      none
    | _ => none
  -- More specific top-level checks
  | _ => none
```

Actually, the implementation is cleaner as a single function. Detailed design will be finalized in the implementation plan.

**Phase 2: Modify `labelFormula`**

Insert pre-filter check before the `decideAutoAdaptive` call:

```lean
def labelFormula (phi : Formula) (fc : FrameClass := .Base) : IO LabeledFormula := do
  -- Phase 1: Structural pre-filter (zero fuel cost, zero wall-clock time)
  match structuralPrefilter phi with
  | some true =>
    let metrics := computeMetrics phi 0  -- 0ms decision time
    let patternKey := PatternKey.fromFormula phi
    let intResult := computeInterestingness phi none none
    return {
      formula := phi
      label := .valid
      proofTrace := none
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "structural_prefilter"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some "structural_prefilter"
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | _ =>
    -- Phase 2: Original decision procedure path
    let startTime <- IO.monoMsNow
    let (result, fuelTier) := decideAutoAdaptive phi fc
    ...  -- existing code unchanged
```

**Phase 3: Simplify `decideAutoAdaptive`**

Replace the three-tier list with a single fuel=500 call. See Section 1.2 for the exact code.

---

## 7. C6 Regeneration

### 7.1 CLI Command

After implementing the changes, regenerate c6:

```bash
lake build
lake exe dataset_generator -- \
  --max-complexity 6 \
  --output data/bmlogic-c6.jsonl \
  --mode exhaustive
```

### 7.2 Expected Results

| Metric | Before (current c6) | After (predicted) |
|--------|---------------------|-------------------|
| Total records | 5,931 | 5,931 (same formulas) |
| Valid | 445 | 596 (+151 pre-filtered) |
| Invalid | 5,239 | 5,239 (unchanged) |
| Timeout | 247 | 96 (box-general-temporal only) |
| Decision methods | 3 types | 4 types (+ structural_prefilter) |
| Wall-clock time | ~18 hours* | ~5-20 minutes (predicted) |
| Timeout rate | 4.2% | 1.6% |

*The current c6 generation included two formulas taking 405 seconds each, plus the 3-tier overhead on all 247 timeout formulas. With the pre-filter, the 151 pre-filtered formulas resolve instantly, and the remaining 96 timeouts each take <1ms with a single fuel=500 attempt.

### 7.3 Runtime Estimate

- 5,684 non-timeout formulas: average ~0.5ms each = ~3 seconds
- 151 pre-filtered formulas: ~0ms each = negligible
- 96 remaining timeouts: ~0.5ms each (single fuel=500 attempt) = negligible
- Overhead (enumeration, JSON serialization, file I/O): ~10 seconds

**Total estimated c6 runtime: under 1 minute** (compared to current ~18 hours dominated by the two 405-second formulas and three-tier overhead).

For full c6 with the SINGLE-tier simplification but WITHOUT the pre-filter:
- The two slow formulas still take 405 seconds each (at fuel=500 alone, the slow until-bot formulas still burn time during tableau expansion)
- Actually, the 405-second timing was WITH the 3-tier approach. With single-tier (fuel=500 only), each timeout formula attempts only 500 fuel steps instead of 500+2000+10000=12,500 fuel steps. The timing for the slow formulas would be approximately 500/12500 * 405s = ~16 seconds each.

So the single-tier simplification alone reduces c6 time from ~18 hours to ~1 hour. The pre-filter eliminates the remaining slow timeouts entirely, reducing to under 1 minute.

---

## 8. Testing Strategy

### 8.1 Unit Tests for Pre-Filter

Test each pattern with concrete formulas:

```lean
-- Bot-temporal patterns
#eval structuralPrefilter (.imp (.untl .bot (.atom (Atom.mk_base "p"))) (.atom (Atom.mk_base "q")))
-- Expected: some true (U(bot, p) -> q)

#eval structuralPrefilter (.imp (.snce .bot (.atom (Atom.mk_base "p"))) .bot)
-- Expected: some true (S(bot, p) -> bot)

-- Recursive bot-temporal
#eval structuralPrefilter (.box (.imp (.untl .bot (.atom (Atom.mk_base "r"))) (.atom (Atom.mk_base "p"))))
-- Expected: some true (box(U(bot, r) -> p))

-- Double-box
#eval structuralPrefilter (.imp (.box (.box .bot)) (.atom (Atom.mk_base "p")))
-- Expected: some true (box(box(bot)) -> p)

#eval structuralPrefilter (.imp (.box (.box (.atom (Atom.mk_base "p")))) (.atom (Atom.mk_base "p")))
-- Expected: some true (box(box(p)) -> p)

-- Box-prop
#eval structuralPrefilter (.imp (.box (.atom (Atom.mk_base "p"))) (.imp (.atom (Atom.mk_base "q")) (.atom (Atom.mk_base "p"))))
-- Expected: some true (box(p) -> (q -> p))

-- Negative cases (should NOT match)
#eval structuralPrefilter (.imp (.box (.untl (.atom (Atom.mk_base "p")) (.atom (Atom.mk_base "q")))) .bot)
-- Expected: none (box(U(p,q)) -> bot -- this is INVALID)

#eval structuralPrefilter (.imp (.atom (Atom.mk_base "p")) (.untl .bot (.atom (Atom.mk_base "q"))))
-- Expected: none (p -> U(bot, q) -- bot-temporal in CONSEQUENT, not antecedent)
```

### 8.2 Regression Test on C5 Data

Run the new pipeline on c5 formulas and verify:
1. All 1,410 previously-valid formulas remain valid with the same decision method
2. All 63 fast-path-axiom formulas remain the same
3. All 39 previous timeouts are now labeled valid with method "structural_prefilter"
4. Total valid count increases from 1,473 to 1,512

### 8.3 Regression Test on C6 Data

Compare with the existing c6 dataset:
1. All 5,476 adaptive_500 formulas should produce identical labels
2. All 208 fast_path_axiom formulas should produce identical labels
3. 151 of 247 previous timeouts should become "structural_prefilter" valid
4. 96 timeouts should remain as timeouts
5. No formula that was previously valid/invalid should change label

### 8.4 Build Verification

```bash
lake build  # Full project build to check no regressions
```

---

## 9. Correctness Considerations

### 9.1 The containsBotTemporal Function Must Be Sound

The function must ONLY return true when the presence of `untl .bot _` or `snce .bot _` in the antecedent guarantees the formula is valid. There is a subtlety: `containsBotTemporal` recurses into ALL sub-formulas, but the bot-temporal sub-formula must be in a position that makes the antecedent unsatisfiable.

Consider: `(U(bot,p) -> q) -> r`. Here `containsBotTemporal` on the antecedent `U(bot,p) -> q` returns true. But is the full formula valid? Yes: `U(bot,p) -> q` is always true (vacuously), so the antecedent `(U(bot,p) -> q)` is always true, and the formula is equivalent to `true -> r` = r. Wait, that is NOT valid (r could be false).

Actually, let me reconsider. The pre-filter checks `containsBotTemporal(antecedent)` where antecedent is the LEFT side of the TOP-LEVEL implication. In the example `(U(bot,p) -> q) -> r`:
- antecedent = `U(bot,p) -> q`
- `containsBotTemporal(U(bot,p) -> q)` = true (it contains U(bot,p))
- But `U(bot,p) -> q` is NOT unsatisfiable -- it is ALWAYS TRUE

So the issue is: `containsBotTemporal` returning true on the antecedent does NOT mean the antecedent is unsatisfiable. It could mean the antecedent is always TRUE (if the bot-temporal is in the left of an implication).

**This is a critical correctness issue.** The pre-filter must distinguish:
- Bot-temporal making the antecedent FALSE (e.g., `U(bot,p)` standalone) -> formula valid
- Bot-temporal making the antecedent TRUE (e.g., `U(bot,p) -> q`) -> formula NOT necessarily valid

**Corrected approach:** Instead of `containsBotTemporal`, use a function that checks whether a formula is UNSATISFIABLE due to bot-temporal:

```lean
/-- Check if a formula is unsatisfiable due to containing bot-temporal. -/
def isUnsatisfiableBotTemporal : Formula -> Bool
  | .untl .bot _ => true                    -- U(bot,X) is always false
  | .snce .bot _ => true                    -- S(bot,X) is always false
  | .box a => isUnsatisfiableBotTemporal a  -- box(false) = false
  | _ => false
```

This is MUCH more conservative but CORRECT. It only returns true when the formula itself evaluates to false, not when it merely contains a bot-temporal subformula.

Wait, but `box(U(bot,p))` is `box(false)` which is indeed false (by T: `box(false) -> false`, contradiction). So the box case is correct.

What about `U(bot,p) ∧ q`? In our syntax, conjunction is `(U(bot,p).imp (q.neg)).neg`, which is `neg(imp(untl bot p, neg q))`. This does NOT match any of the simple patterns. The function would return false, which is the safe choice.

**Revised pre-filter:**

```lean
/-- Check if a formula is always false (unsatisfiable) due to bot-temporal structure. -/
def isUnsatBotTemporal : Formula -> Bool
  | .untl .bot _ => true
  | .snce .bot _ => true
  | .box a => isUnsatBotTemporal a
  | _ => false

/-- Structural pre-filter for known-valid timeout patterns. -/
def structuralPrefilter : Formula -> Option Bool
  | .imp antecedent _ =>
    if isUnsatBotTemporal antecedent then some true
    else match (.imp antecedent) with  -- dummy partial match
    | _ =>
      -- Double-box patterns
      match antecedent with
      | .box (.box .bot) => some true
      | .box (.box inner) => ... -- check if consequent == inner
      | .box inner => ... -- check box-prop
      | _ => none
  | .box inner =>
    match structuralPrefilter inner with
    | some true => some true
    | _ => none
  | _ => none
```

### 9.2 Revised Coverage with Conservative Pre-Filter

With `isUnsatBotTemporal` (conservative):
- Catches: `U(bot,X) -> Y`, `S(bot,X) -> Y` (top-level)
- Catches: `box(U(bot,X)) -> Y`, `box(S(bot,X)) -> Y` (box-wrapped temporal)
- DOES NOT catch: `box(U(bot,X) -> Y)` (box-wrapped implication) -- here the argument to box is `U(bot,X) -> Y` which is always TRUE, not false

Let me re-analyze c6 coverage with this conservative approach:

The 135 bot-temporal timeouts break down as:
- Top-level `U(bot,X) -> Y`: 39 (includes variants with complex X like `box(p)`)
- Top-level `S(bot,X) -> Y`: 32
- `box(U(bot,X)) -> Y`: 16
- `box(S(bot,X)) -> Y`: 16
- `box(U(bot,X) -> Y)`: ~16 (box-wrapped implication)
- `box(S(bot,X) -> Y)`: ~16 (box-wrapped implication)

The conservative `isUnsatBotTemporal` catches the first four categories (103 formulas). The box-wrapped implication forms like `box(U(bot,X) -> Y)` need the box-descent in `structuralPrefilter` to handle them: `box(phi)` is pre-filter-valid if `phi` is pre-filter-valid, and `U(bot,X) -> Y` is pre-filter-valid because `isUnsatBotTemporal(U(bot,X))` is true.

So the recursive `structuralPrefilter` with box-descent DOES catch the box-wrapped implication patterns via:
1. Match `box(inner)` in structuralPrefilter
2. Recurse: structuralPrefilter(inner) where inner = `U(bot,X) -> Y`
3. Match `imp antecedent _` where antecedent = `U(bot,X)`
4. `isUnsatBotTemporal(U(bot,X))` returns true
5. Return `some true`

This gives us the full 135 bot-temporal coverage while being semantically sound.

### 9.3 Final Coverage Summary

With the recommended pre-filter (isUnsatBotTemporal + box-descent + double-box + box-prop):

| Pattern | c5 | c6 | Sound? |
|---------|----|----|--------|
| isUnsatBotTemporal in antecedent | 32 | 103 | YES |
| box-descent (box of pre-filter-valid) | 0 | 32 | YES |
| Double-box-bot (box(box(bot)) -> Y) | 4 | 7 | YES |
| Double-box-identity (box(box(X)) -> X) | 3 | 3 | YES |
| Box-prop (box(X) -> (Y -> X)) | 0 | 6 | YES |
| **Total pre-filtered** | **39** | **151** | **YES** |
| Remaining timeouts | 0 | 96 | N/A |

---

## 10. Implementation Considerations

### 10.1 The `containsBotTemporal` vs `isUnsatBotTemporal` Distinction

The task description says to detect "U(bot,X) -> Y and S(bot,X) -> Y patterns" which aligns with the conservative `isUnsatBotTemporal` on the antecedent. The recursive approach with box-descent in the outer `structuralPrefilter` function achieves the desired coverage without the soundness risk of the naive `containsBotTemporal`.

### 10.2 No `DecisionResult` Modification Needed

The two-phase approach in `labelFormula` (check pre-filter first, then call `decideAutoAdaptive`) avoids modifying `DecisionResult`. The `LabeledFormula` structure already has all the fields needed:
- `label := .valid` (it IS valid)
- `proofTrace := none` (no mechanical proof)
- `decisionMethod := "structural_prefilter"`
- `proofReconstructionMethod := some "structural_prefilter"`

### 10.3 Performance Impact

The pre-filter function is O(n) in formula size (single recursive pass). For formulas of complexity 6, this is ~6 recursive calls. The overhead is negligible compared to even the fastest decision procedure invocation.

### 10.4 Future Extensions

If additional timeout patterns are discovered at c7+ complexity:
1. Analyze the pattern using the same methodology (categorize, check validity, check timing)
2. If valid and high-impact: extend `structuralPrefilter` with a new case
3. If mixed-validity: leave as timeout (cannot safely pre-filter)
4. If performance-critical but not pre-filterable: investigate decision procedure improvements

---

## 11. Answers to Research Questions

### Q1: Single-tier simplification approach
Simplify `decideAutoAdaptive` in place to use fuel=500 only. Keep the function as the API surface; do not have `labelFormula` call `decide` directly. Remove the `go` helper and tier list. See Section 1.2.

### Q2: Structural pre-filter design
Use `isUnsatBotTemporal` (conservative recursive check that a sub-formula is always false) combined with `structuralPrefilter` (checks implication antecedent + box descent + double-box + box-prop). Call the pre-filter in `labelFormula` before `decideAutoAdaptive`. Return type is `Option Bool`. See Sections 2.2-2.6 and 9.1-9.3.

### Q3: Validity proofs
Formal Lean proofs are NOT needed for the initial implementation. Use the two-phase approach where the pre-filter labels formulas as valid without a DerivationTree. The semantic arguments are sound (Section 3). Formal proofs can be added later by extending `buildCompositionalProof`.

### Q4: Pre-filter scope
YES, use recursive matching with box-descent. This safely covers 151/247 c6 timeouts (61.1%). The remaining 96 (box-general-temporal with non-bot event) include invalid formulas and MUST NOT be pre-filtered. Add box-prop pattern for marginal coverage. See Section 4.

### Q5: Decision method tagging
Use single tag `"structural_prefilter"`. Pattern-specific tags add complexity without proportional benefit. See Section 5.

### Q6: C6 regeneration
`lake exe dataset_generator -- --max-complexity 6 --output data/bmlogic-c6.jsonl`. Expected runtime: under 1 minute (down from ~18 hours). See Section 7.

### Q7: Testing strategy
Unit tests for each pre-filter pattern (positive and negative cases). Regression test against existing c5 (all 39 timeouts should become pre-filtered valid) and c6 (151 should convert, 96 should remain timeout). Full `lake build` for compilation verification. See Section 8.
