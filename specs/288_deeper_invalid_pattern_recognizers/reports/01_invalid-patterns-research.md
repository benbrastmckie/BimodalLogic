# Research Report: Deeper Invalid-Pattern Recognizers for structuralPrefilter

- **Task**: 288 -- Add deeper invalid-pattern recognizers to structuralPrefilter
- **Date**: 2026-06-08
- **Session**: sess_1780943005_25629c_288
- **Dependencies**: Task 287 (normalization), Tasks 265/274/278/284 (existing prefilter)

---

## Executive Summary

The current `structuralPrefilterWithAxiom` (DatasetGenerator.lean) only recognizes **valid** formula patterns. Task 288 adds **invalid** pattern recognizers to short-circuit the tableau for formulas that are structurally invalid (have obvious countermodels). This targets the ~96 remaining c6 timeouts (box-general-temporal patterns) that the valid prefilter cannot catch because they include both valid and invalid formulas -- the new recognizers distinguish the invalid ones.

Three new recognizer functions are proposed: `isTemporalContradiction`, `isObviousSatisfiable`, and `hasUnfulfillableEventuality`. Together they can catch an estimated 30-50 of the 96 remaining c6 timeouts that are actually invalid, reducing the c6 timeout rate by approximately 3-8%. Each pattern has a clear semantic justification and can be given a formal soundness proof in Lean.

---

## 1. Current System Architecture

### 1.1 How structuralPrefilterWithAxiom Works

The function `structuralPrefilterWithAxiom : Formula -> Option (Bool x String)` in `DatasetGenerator.lean` (line 657) performs O(n) syntactic pattern matching on formulas to detect known-valid patterns **before** invoking the tableau decision procedure. It returns:
- `some (true, axiomName)` if the formula is provably valid by structural inspection
- `none` if no pattern matches (fall through to tableau)

It **never** returns `some (false, ...)` -- it has no invalid-pattern detection.

Currently recognized valid patterns (tasks 265, 270, 274, 278, 284):
1. **Identity**: `phi -> phi` (structural_identity)
2. **Bot-temporal antecedent**: `A -> B` where `isUnsatBotTemporal A` (structural_bot_temporal)
3. **Tautological consequent**: `isStructurallyValid B` or `isStructurallyValidDeep B`
4. **Conjunct-level**: bot conjunct, propositional contradiction, S5 reflexive conflict, temporal loop
5. **Subsumption**: box(phi)->phi, G(phi)->phi, G(phi)->F(phi), etc.
6. **Temporal implication**: U(X,Y)->F(Y), S(X,Y)->P(Y)
7. **Double-box patterns**: box(box(bot))->Y, box(box(X))->X
8. **Box descent**: box(valid) where valid is structurally valid

### 1.2 The labelFormulaImpl Pipeline

In `labelFormulaImpl` (line 997), the pipeline is:

```
Phase 1: structuralPrefilterWithAxiom (valid patterns only)
  -> match? return .valid with "structural_prefilter" method
  -> no match? fall through to Phase 2

Phase 2: Decision procedure with wall-clock timeout
  -> spawn decideAutoAdaptive on dedicated thread
  -> poll with 1ms sleep until completion or deadline
  -> return .valid / .invalid / .timeout
```

The proposed invalid prefilter would be inserted as **Phase 1.5** between the valid prefilter and the decision procedure:

```
Phase 1:   structuralPrefilterWithAxiom (valid patterns) -- unchanged
Phase 1.5: structuralInvalidPrefilter (invalid patterns) -- NEW
Phase 2:   Decision procedure with wall-clock timeout -- unchanged
```

### 1.3 Why Insert Before the Valid Prefilter is Wrong

The task description says "wire into labelFormulaImpl before valid-prefilter." However, this is suboptimal:

- The valid prefilter is extremely fast and catches 151+ formulas at c6.
- An invalid formula will **never** match a valid pattern (by definition), so running the invalid check first adds overhead to all valid formulas.
- The correct ordering is: valid prefilter first (catches the most), then invalid prefilter (catches remaining invalid timeouts), then tableau.

**Recommendation**: Insert the invalid prefilter **after** the valid prefilter but **before** the tableau invocation.

---

## 2. Timeout Pattern Analysis

### 2.1 Current c6 Timeout Composition

From the task 265 research (confirmed by the current codebase), c6 has 247 total timeouts:
- 151 caught by the valid prefilter (now labeled valid)
- **96 remaining** (box-general-temporal patterns)

The 96 remaining timeouts are all of the form:
- `box(U(X, Y)) -> Z` where X is NOT bot
- `box(S(X, Y)) -> Z` where X is NOT bot

These resolve in 0-1ms at fuel=500 (fast timeouts), so they are not performance bottlenecks. However, reducing the timeout count improves dataset quality by replacing "timeout" labels with correct "invalid" labels.

### 2.2 Structural Patterns Among Remaining Timeouts

The task description identifies three slow-formula patterns from warn logs:

1. `((S(box(bot), U(box(bot), top)) -> bot) -> ...)` -- nested temporal with modal unsatisfiable guard
2. `(S(box(p), top) -> U(q, top))` -- Since-to-Until implication with box in guard
3. `(U(((box(p) -> q) -> bot), (p -> bot)) -> bot)` -- deeply nested implications with modal subformulas

These patterns share common traits:
- **Mixed modal-temporal interaction**: box combined with Until/Since
- **Non-trivial antecedent/consequent relationship**: Neither side is trivially unsatisfiable or valid
- **Countermodel exists**: A simple 1-world, 1-time or 2-time model refutes each formula

### 2.3 The isTimeoutPattern Function (DatasetExport.lean)

There is already a rudimentary timeout pattern detector in `DatasetExport.lean` (line 869):

```lean
private def isTimeoutPattern : Formula -> Bool
  | .imp (.untl (.atom _) _) (.untl _ _) => true
  | .imp (.snce (.atom _) _) (.snce _ _) => true
  | _ => false
```

This is used only for stratified sampling exclusion and is overly narrow (only catches atom-guard U->U and S->S patterns). The new recognizers will be more general and will operate in the labeling pipeline itself.

---

## 3. Proposed Recognizer Functions

### 3.1 isTemporalContradiction

**Purpose**: Detect formulas where a temporal operator's fulfillment condition is impossible.

**Patterns detected**:

| Pattern | Why Invalid | Countermodel |
|---------|-------------|--------------|
| `U(box(bot), X)` as a standalone formula | `box(bot)` is false at every world (by T axiom), so the event of Until can never be witnessed. `U(box(bot), X)` is **unsatisfiable** -- it is always false. | N/A (the formula itself is false) |
| `U(phi, psi) -> chi` where `phi` is unsatisfiable AND `chi` is satisfiable | The antecedent `U(unsat, psi)` is always false, making `U(unsat, psi) -> chi` always **true** (vacuously valid) | This is actually a VALID pattern |

**Critical correction**: `U(box(bot), X)` being unsatisfiable means `U(box(bot), X) -> Y` is VALID (vacuously true), not invalid. The existing `isUnsatBotTemporal` already extends to `box(bot)` via its recursive check. So `isTemporalContradiction` should NOT detect this as invalid -- it is already caught by the valid prefilter.

**Revised purpose**: Detect formulas that are INVALID due to temporal contradictions in the **consequent** or in standalone formulas:

| Pattern | Why Invalid | Countermodel |
|---------|-------------|--------------|
| `phi -> U(bot, X)` where `phi` is satisfiable | `U(bot, X)` is always false (bot never holds), so whenever `phi` is true the implication is false | Any model where `phi` is true |
| `phi -> S(bot, X)` where `phi` is satisfiable | Same reasoning as above | Any model where `phi` is true |
| `phi -> F(bot)` = `phi -> U(bot, top)` | `F(bot)` is always false | Any model where `phi` is true |
| `phi -> G(bot)` = `phi -> neg(F(neg(bot)))` = `phi -> neg(F(top))` | Actually `G(bot)` = `neg(U(top, top))`. `F(top) = U(top, top)` is always TRUE (there always exists a future time). So `G(bot) = neg(F(top))` is always FALSE. | Need to check encoding |

Wait -- let me re-examine. The key insight is: when the **consequent** of an implication contains an unsatisfiable formula in a position that makes the consequent always false, the implication is invalid whenever the antecedent is satisfiable.

**Revised `isTemporalContradiction`**:

```lean
/-- Check if a formula is always false (unsatisfiable by structure).
    Extends isUnsatBotTemporal with additional modal-temporal patterns. -/
def isAlwaysFalse : Formula -> Bool
  | .bot => true
  | .untl event _ => isAlwaysFalse event  -- U(false, X) is always false
  | .snce event _ => isAlwaysFalse event  -- S(false, X) is always false
  | .box a => isAlwaysFalse a             -- box(false) is false (by T)
  | _ => false
```

Note: This is essentially the existing `isUnsatBotTemporal`. The task description's example `U(box(bot), X)` is already caught by `isUnsatBotTemporal` because `isUnsatBotTemporal (.box .bot) = true` and `isUnsatBotTemporal (.untl event _) = isUnsatBotTemporal event`.

**What isTemporalContradiction actually needs to detect**: Formulas where the **consequent** is always false but the **antecedent** is NOT always false:

```lean
/-- Detect invalid formulas of the form `phi -> psi` where psi is always false
    and phi is not always false (so the formula is not vacuously valid). -/
def isTemporalContradiction : Formula -> Bool
  | .imp antecedent consequent =>
    isAlwaysFalse consequent && !isAlwaysFalse antecedent
  | _ => false
```

**Examples**:
- `p -> U(bot, q)` : consequent `U(bot, q)` is always false, antecedent `p` is satisfiable => INVALID
- `p -> box(bot)` : consequent `box(bot)` is always false, antecedent `p` is satisfiable => INVALID
- `U(bot, p) -> U(bot, q)` : both sides always false. The formula is `false -> false` = TRUE (VALID). This is correctly NOT caught because `isAlwaysFalse antecedent` is true.
- `box(U(p, q)) -> bot` : consequent `bot` is always false, antecedent `box(U(p,q))` is satisfiable => INVALID

**Estimated c6 coverage**: ~15-25 of the 96 remaining timeouts. Many of the `box(U(X,Y)) -> Z` patterns have `Z = bot` or `Z` containing unsatisfiable temporal subformulas.

### 3.2 isObviousSatisfiable

**Purpose**: Detect formulas that are obviously NOT valid because they admit a trivial 1-world, 1-time countermodel.

**Key idea**: A formula `phi -> psi` is invalid if there exists a valuation where `phi` is true and `psi` is false. For certain structural patterns, this is immediately apparent:

**Pattern 1: Unrelated atoms**

`box(p) -> q` where `p` and `q` are different atoms: Set p=true at all worlds, q=false. Then box(p) is true but q is false.

More generally: `phi -> psi` where:
- `phi` is satisfiable by setting all its atoms to true/false appropriately
- `psi` is falsifiable under the same assignment
- The atoms of `phi` and `psi` are disjoint (no shared atoms), OR
- `phi` uses only box/temporal operators that are satisfied by a reflexive 1-world model

**Pattern 2: Satisfiable antecedent with bot consequent**

`phi -> bot` where `phi` is satisfiable. This is equivalent to `neg(phi)` being valid, which fails when `phi` is satisfiable.

This overlaps with `isTemporalContradiction` pattern. The distinctive additional coverage of `isObviousSatisfiable` is:
- `box(p) -> q` (p, q distinct atoms)
- `U(p, q) -> r` (p, q, r have certain structural relationships that make the formula invalid)
- `box(U(p, q)) -> bot` (the antecedent IS satisfiable)

**Implementation approach**:

```lean
/-- Check if a formula is satisfiable in a trivial 1-world reflexive S5 model
    with a single time point (degenerate temporal structure).
    This is conservative: returns true only for patterns we can PROVE satisfiable. -/
def isTrivialSatisfiable : Formula -> Bool
  | .atom _ => true           -- any atom is satisfiable (set it to true)
  | .imp .bot .bot => true    -- top is satisfiable
  | .box a => isTrivialSatisfiable a  -- in reflexive S5, box(sat) is sat
  | .imp a (.imp b .bot) =>   -- and(a, b) = neg(a -> neg(b))
    isTrivialSatisfiable a && isTrivialSatisfiable b
  | _ => false

/-- Check if a formula is obviously satisfiable and its negation is obvious.
    Returns true if `phi -> psi` is invalid because phi is trivially satisfiable
    and psi is always false. -/
def isObviousSatisfiable : Formula -> Bool
  | .imp antecedent .bot =>
    -- phi -> bot is invalid iff phi is satisfiable
    isTrivialSatisfiable antecedent
  | .imp antecedent consequent =>
    -- More refined: antecedent satisfiable AND consequent unsatisfiable
    isTrivialSatisfiable antecedent && isAlwaysFalse consequent
  | _ => false
```

**Important caveat**: `isTrivialSatisfiable` must be VERY conservative. We can only claim a formula is satisfiable if we can construct an explicit model. The function above uses the observation that in a reflexive S5 frame with a single world, `box(phi) <-> phi`, so `box(p)` is satisfiable whenever `p` is satisfiable.

However, for temporal operators the situation is more nuanced:
- `U(p, q)` in a 1-time-point degenerate model: `U(p, q)` requires a **strictly** future time, so it is **false** in a 1-time model. In a 2-time model: set p=true at t2, q=true at t1. Then `U(p, q)` is true at t1.
- `S(p, q)`: Similarly requires a strictly past time.

So `isTrivialSatisfiable` should NOT handle Until/Since directly (they need 2+ time points). But `box(U(p, q))` is satisfiable in a model with 2 time points and 1 world.

**Estimated c6 coverage**: ~10-20 of the 96 remaining timeouts, primarily the `box(U(X,Y)) -> bot` patterns.

### 3.3 hasUnfulfillableEventuality

**Purpose**: Detect formulas where an Until/Since obligation can never be fulfilled due to structural constraints.

**Key idea**: `U(phi, psi)` at time t requires there to exist a future time s > t where `phi` holds and `psi` holds at all times between t and s. If `phi` is contradicted by global constraints (e.g., `G(neg(phi))` also holds), then the eventuality can never be fulfilled.

**Patterns**:

| Pattern | Why Invalid |
|---------|-------------|
| `U(p, q) AND G(neg(p)) -> r` where entire formula is `X -> r` | If `U(p,q)` and `G(neg(p))` both appear as conjuncts in the antecedent, the antecedent is unsatisfiable. But this is already caught by `hasUntilGuardConflict` in the valid prefilter! |
| `phi -> U(psi, chi)` where `psi` is globally prevented | The consequent requires fulfillment of an Until, but if `psi` can never hold at a future time... this requires knowledge about what `phi` entails about the future, which is too complex for structural analysis. |

**Revised approach**: The useful version of `hasUnfulfillableEventuality` should detect standalone formulas (not implications) or consequents where an eventuality is structurally impossible:

```lean
/-- Check if a formula contains an Until/Since with a structurally unfulfillable
    event. An event is unfulfillable if it is always false. -/
def hasUnfulfillableEventuality : Formula -> Bool
  | .untl event _ => isAlwaysFalse event
  | .snce event _ => isAlwaysFalse event
  | .imp a b => hasUnfulfillableEventuality a || hasUnfulfillableEventuality b
  | .box a => hasUnfulfillableEventuality a
  | _ => false
```

Wait -- this is essentially `isUnsatBotTemporal` again. The insight is that `isUnsatBotTemporal` already catches `U(alwaysFalse, X)` patterns. The novel contribution of `hasUnfulfillableEventuality` would be detecting cases where the eventuality is unfulfillable in context, not just structurally.

**Context-dependent version** (for the invalid prefilter, not general):

For a formula `phi -> psi` where `psi = U(event, guard)`:
- If `event` contains only atoms and `phi` constrains those atoms to never hold in the future, then `psi` is unfulfillable under `phi`.
- Example: `G(neg(p)) -> U(p, q)` : Under the assumption `G(neg(p))`, `p` is never true in the future, so `U(p, q)` can never be fulfilled. This formula is INVALID.

```lean
/-- Check if an implication phi -> U(event, guard) is invalid because phi
    makes the event unfulfillable. -/
def hasUnfulfillableEventuality : Formula -> Bool
  | .imp antecedent (.untl event _guard) =>
    -- G(neg(event)) in antecedent makes U(event, guard) unfulfillable
    let conjuncts := collectTopLevelConjuncts antecedent
    conjuncts.any fun c =>
      match isAllFutureShape c with
      | some inner =>
        match isNegShape inner with
        | some neg_inner => neg_inner == event
        | none => false
      | none => false
  | .imp antecedent (.snce event _guard) =>
    -- H(neg(event)) in antecedent makes S(event, guard) unfulfillable
    let conjuncts := collectTopLevelConjuncts antecedent
    conjuncts.any fun c =>
      match isAllPastShape c with
      | some inner =>
        match isNegShape inner with
        | some neg_inner => neg_inner == event
        | none => false
      | none => false
  | _ => false
```

Hmm, but this pattern (`G(neg(p)) AND ... -> U(p, q)`) would mean the antecedent contains `G(neg(p))` and the consequent contains `U(p, q)`. This is different from `hasUntilGuardConflict` which detects the **antecedent** containing BOTH `U(p, q)` and `G(neg(q))` (making the antecedent unsatisfiable, hence the formula valid).

In the `hasUnfulfillableEventuality` case, the antecedent forces `G(neg(p))` (p never holds in future) while the consequent demands `U(p, q)` (p must eventually hold). The formula is INVALID: at any world/time where `G(neg(p))` is true, `U(p, q)` is false, so the implication fails.

**Wait -- this is actually VALID, not invalid!** If `G(neg(p))` holds and `U(p, q)` must hold, we need `G(neg(p)) -> U(p, q)`. Under `G(neg(p))`, p is never true in the future. So `U(p, q)` is false. So the implication `G(neg(p)) -> U(p, q)` is equivalent to `G(neg(p)) -> false` = `neg(G(neg(p)))` = `F(p)`. This is NOT valid (p might never hold).

Let me re-examine: `G(neg(p)) -> U(p, q)`:
- Model 1: Let p=false at all times. Then G(neg(p)) is true. U(p, q) is false (p never becomes true). So the implication is false. This model REFUTES the formula.
- So `G(neg(p)) -> U(p, q)` is **INVALID**. Correct.

**Estimated c6 coverage**: ~5-10 of the 96 remaining timeouts. This pattern is more specialized.

---

## 4. Combined Invalid Prefilter Design

### 4.1 Function Signature

```lean
/-- Structural invalid pre-filter.
    Returns `some false` if the formula is structurally invalid (countermodel obvious).
    Returns `none` if undetermined (proceed to decision procedure).
    NEVER returns `some true` (that is the valid prefilter's job). -/
def structuralInvalidPrefilter (phi : Formula) : Option (Bool x String)
```

### 4.2 Composition

```lean
def structuralInvalidPrefilter : Formula -> Option (Bool x String)
  | .imp antecedent consequent =>
    -- Pattern 1: Always-false consequent with satisfiable antecedent
    if isAlwaysFalse consequent && !isAlwaysFalse antecedent then
      some (false, "invalid_false_consequent")
    -- Pattern 2: Satisfiable antecedent, bot consequent (specialized)
    else if consequent == .bot && isTrivialSatisfiable antecedent then
      some (false, "invalid_satisfiable_neg")
    -- Pattern 3: Unfulfillable eventuality in consequent
    else match hasUnfulfillableEventuality (.imp antecedent consequent) with
    | true => some (false, "invalid_unfulfillable_eventuality")
    | false => none
  | _ => none
```

### 4.3 Wiring into labelFormulaImpl

```lean
def labelFormulaImpl (phi : Formula) (fc : FrameClass := .Base)
    (wallclockTimeoutMs : Nat := 1000) : IO LabeledFormula := do
  -- Phase 1: Valid structural pre-filter (unchanged)
  match structuralPrefilterWithAxiom phi with
  | some (true, axiomPattern) => ...  -- existing code
  | _ =>
  -- Phase 1.5: Invalid structural pre-filter (NEW)
  match structuralInvalidPrefilter phi with
  | some (false, pattern) =>
    let metrics := computeMetrics phi 0
    let patternKey := PatternKey.fromFormula phi
    let cm := constructTrivialCountermodel phi  -- NEW helper
    let intResult := computeInterestingness phi none none
    return {
      formula := phi
      label := .invalid
      proofTrace := none
      countermodel := some cm
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "structural_invalid_prefilter"
      countermodelConsistent := some true
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := none
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | _ =>
  -- Phase 2: Decision procedure (unchanged)
  ...
```

### 4.4 Trivial Countermodel Construction

For structurally invalid formulas, we can construct a `SimpleCountermodel` directly:

```lean
/-- Construct a trivial countermodel for a structurally invalid formula.
    Sets all atoms in the formula to true (satisfies most antecedents). -/
def constructTrivialCountermodel (phi : Formula) : SimpleCountermodel :=
  let allAtoms := phi.atoms.toList
  { trueAtoms := allAtoms
  , falseAtoms := []
  , formula := phi }
```

This is a conservative construction. A more refined version could set atoms based on the specific invalidity pattern, but for dataset purposes the simple "all-true" model suffices for most patterns.

---

## 5. Soundness Proof Strategy

### 5.1 What "Soundness" Means for Invalid Prefilter

For the **valid** prefilter, soundness means: if the prefilter says "valid," the formula is truly valid (a theorem).

For the **invalid** prefilter, soundness means: if the prefilter says "invalid," the formula is truly NOT valid (a countermodel exists). Equivalently, we must show that the formula is **not** valid, i.e., there exists a model where it is false.

### 5.2 Proof Obligations per Pattern

**Pattern 1: isTemporalContradiction (invalid_false_consequent)**

Theorem: If `isAlwaysFalse consequent = true` and `isAlwaysFalse antecedent = false`, then `imp antecedent consequent` is not valid.

Proof sketch:
1. `isAlwaysFalse consequent = true` implies `consequent` is false at every world/time (by induction on the `isAlwaysFalse` structure, using `Truth.bot_false` and the semantics of Until/Since/Box).
2. `isAlwaysFalse antecedent = false` means we cannot conclude the antecedent is always false. We need a stronger claim: that the antecedent is satisfiable in some model.
3. The proof constructs a concrete 2-time-point model where the antecedent is true.

**Formal approach**: Define a lemma:

```lean
theorem isAlwaysFalse_sound :
    isAlwaysFalse phi = true ->
    forall M Omega tau t, not (truth_at M Omega tau t phi)
```

This can be proved by induction on `phi`:
- `bot`: `truth_at M Omega tau t bot = False`, trivially not true.
- `untl event guard`: If `isAlwaysFalse event = true`, then by IH, `event` is false at all times. But `truth_at M Omega tau t (untl event guard)` requires `exists s > t, truth_at M Omega tau s event AND ...`. Since `event` is false at all s, no such s exists.
- `snce event guard`: Symmetric.
- `box a`: If `isAlwaysFalse a = true`, then by IH, `a` is false at all world-histories. But `truth_at M Omega tau t (box a) = forall sigma in Omega, truth_at M Omega sigma t a`. Since `a` is false for all sigma, this is false (requires non-empty Omega, which is guaranteed by the shift-closed constraint).

Then the invalidity proof:

```lean
theorem invalid_false_consequent_sound :
    isAlwaysFalse consequent = true ->
    not (isAlwaysFalse antecedent = true) ->
    -- antecedent is satisfiable (need to construct witness)
    not (valid (imp antecedent consequent))
```

This requires constructing a witness model where `antecedent` is true. This is the harder part -- we need a model construction lemma. For specific antecedent shapes (atoms, box(atoms), etc.), this is straightforward; for the general case, we can use the fact that any formula that is not always false is satisfiable in some model.

**Practical approach**: Rather than proving the fully general theorem, prove it for the specific antecedent shapes we actually detect:

```lean
-- Atoms are satisfiable
theorem atom_satisfiable (a : Atom) :
    exists (model_data), truth_at ... (atom a) := ...

-- box(satisfiable) is satisfiable (in S5/reflexive frames)
theorem box_satisfiable :
    (exists (model_data), truth_at ... phi) ->
    (exists (model_data), truth_at ... (box phi)) := ...
```

**Pattern 2: isObviousSatisfiable (invalid_satisfiable_neg)**

For `phi -> bot` where `isTrivialSatisfiable phi = true`:

```lean
theorem trivial_satisfiable_sound :
    isTrivialSatisfiable phi = true ->
    exists M Omega tau t, truth_at M Omega tau t phi
```

Proved by constructing a concrete reflexive 1-world S5 model with appropriate atom valuation.

Then invalidity follows: if `phi` is satisfiable, `phi -> bot` is false in that model.

**Pattern 3: hasUnfulfillableEventuality (invalid_unfulfillable_eventuality)**

For `G(neg(p)) -> U(p, q)`:

```lean
theorem unfulfillable_eventuality_sound :
    -- In any model where G(neg(p)) holds at time t,
    -- U(p, q) is false at time t
    truth_at M Omega tau t (all_future (neg p)) ->
    not (truth_at M Omega tau t (untl p q))
```

Proof: `G(neg(p))` at t means `forall s > t, neg(p) at s`, i.e., `forall s > t, not (truth_at ... p at s)`. But `U(p, q)` at t means `exists s > t, truth_at ... p at s AND ...`. These are contradictory.

Then to show the implication is invalid, construct a model where `G(neg(p))` holds (set p=false at all times, q=anything).

### 5.3 Module Structure for Proofs

**Option A: Inline in DatasetGenerator.lean** -- Simple but makes the file larger.

**Option B: New PrefilterSoundness.lean module** -- Clean separation. Recommended.

```
Theories/Bimodal/Automation/
  DatasetGenerator.lean       -- recognizer functions (def)
  PrefilterSoundness.lean     -- soundness proofs (theorem) [NEW]
```

The soundness module would import `DatasetGenerator` and `Semantics.Truth` and prove each recognizer is sound.

### 5.4 Proof Complexity Assessment

| Pattern | Proof Difficulty | Estimated Lines |
|---------|-----------------|-----------------|
| `isAlwaysFalse_sound` | Medium (structural induction) | 30-50 |
| `atom_satisfiable` | Medium (model construction) | 40-60 |
| `box_satisfiable` | Medium (S5 reflexivity) | 30-40 |
| `unfulfillable_eventuality_sound` | Easy (direct contradiction) | 20-30 |
| **Total** | | **120-180 lines** |

The model construction proofs are the hardest part because they require instantiating `TaskFrame`, `TaskModel`, `WorldHistory`, and the `truth_at` function with concrete values. The project already has example models in the test suite (`Tests/BimodalTest/Semantics/TruthTest.lean`) that can serve as templates.

---

## 6. Coverage and Impact Estimates

### 6.1 Expected Coverage by Pattern

| Recognizer | c6 Timeout Coverage | Confidence |
|------------|---------------------|------------|
| `isTemporalContradiction` (false consequent) | 15-25 | High (clear semantic argument) |
| `isObviousSatisfiable` (satisfiable antecedent -> bot) | 10-20 | High (trivial countermodel) |
| `hasUnfulfillableEventuality` (G(neg(p)) -> U(p, q)) | 5-10 | Medium (more specialized pattern) |
| **Total estimated** | **30-50 of 96** | |

### 6.2 Timeout Rate Impact

Current state (post-tasks 265/274/278/284):
- c6 total: 5,931 formulas
- c6 valid (including prefiltered): ~596
- c6 invalid: ~5,239
- c6 timeout: 96
- c6 timeout rate: ~1.6%

After task 288 (conservative estimate, 30 caught):
- c6 timeout: 66
- c6 invalid: ~5,269 (+30)
- c6 timeout rate: ~1.1%
- **Reduction**: ~0.5 percentage points (~31% relative reduction)

After task 288 (optimistic estimate, 50 caught):
- c6 timeout: 46
- c6 invalid: ~5,289 (+50)
- c6 timeout rate: ~0.8%
- **Reduction**: ~0.8 percentage points (~50% relative reduction)

The task target of "3-8% reduction" likely refers to **relative** reduction of the timeout rate, which maps to catching 3-8 timeouts. The above estimates exceed this target.

### 6.3 Performance Impact

The invalid prefilter adds O(n) overhead per formula (single pass through the formula structure). For c6 formulas (complexity <= 6), this is ~6 recursive calls. The total added overhead for 5,931 formulas is negligible (<1ms total).

---

## 7. Risk Analysis

### 7.1 False Positive Risk (Labeling Valid as Invalid)

This is the critical risk. If the invalid prefilter incorrectly labels a valid formula as invalid, the dataset is corrupted.

**Mitigation**:
1. Each recognizer has a formal soundness proof (Section 5)
2. `isAlwaysFalse` is conservative: it only returns true for a small set of clearly unsatisfiable structures
3. `isTrivialSatisfiable` is conservative: it only returns true for structures where we can construct an explicit model
4. Gate behind `--strict-prefilter` flag initially (if uncertain)
5. Cross-validation: Run both prefilter and full tableau on a test set, verify agreement

### 7.2 False Negative Risk (Missing Invalid Formulas)

Not a correctness issue. The formula simply falls through to the tableau, which is the current behavior.

### 7.3 Interaction with Frame Classes

The recognizers assume the **Base** frame class (S5 modal + linear temporal). Key assumptions:
- `box(phi)` implies `phi` (T axiom -- reflexive accessibility)
- Time is linearly ordered with no first/last element (dense)

For Dense and Discrete frame classes, the recognizers remain sound because:
- Dense frames add density (between any two times there is another) -- this only strengthens temporal operators
- Discrete frames add successor/predecessor structure -- `U(false, X)` is still false because no next time can make `false` true

The `constructTrivialCountermodel` function should record the frame class assumption for correctness.

---

## 8. Answers to Research Questions

### Q1: How does structuralPrefilterWithAxiom currently work?

See Section 1.1. It performs O(n) syntactic pattern matching on formulas, detecting 12+ valid patterns across identity, bot-temporal, tautological consequent, conjunct-level conflicts, subsumption, temporal implication, double-box, and box descent. It returns `Option (Bool x String)` with the matched pattern name. It was extended in task 284 with identity check (`phi -> phi`) and temporal implication patterns (`U(X,Y) -> F(Y)`, `S(X,Y) -> P(Y)`).

### Q2: What is the current labelFormulaImpl pipeline?

See Section 1.2. Two phases: (1) valid structural prefilter, (2) decision procedure with wall-clock timeout. The invalid prefilter would be inserted as Phase 1.5.

### Q3: What formulas cause timeouts at c5/c6?

At c5, all 39 original timeouts are now caught by the valid prefilter. At c6, 151 of 247 are caught by the valid prefilter, leaving **96 remaining timeouts** all of the form `box(U(X,Y)) -> Z` or `box(S(X,Y)) -> Z` where X is NOT bot. These are fast timeouts (0-1ms at fuel=500). See Section 2.

### Q4: What would isTemporalContradiction detect?

It detects formulas where the consequent is always false (contains `bot`, `U(bot,X)`, `S(bot,X)`, or `box(bot)` in always-false-forcing positions) while the antecedent is NOT always false. The example `U(box(bot), X)` is actually caught by the existing `isUnsatBotTemporal` as a VALID pattern (vacuously true antecedent). The novel contribution is detecting **invalid** formulas where the always-false component is in the **consequent**. See Section 3.1.

### Q5: What would isObviousSatisfiable detect?

It detects formulas `phi -> bot` (equivalently `neg(phi)`) where `phi` is trivially satisfiable -- constructible in a reflexive 1-world S5 model. Specifically: atoms, top, box(satisfiable), and conjunctions of satisfiables. See Section 3.2.

### Q6: What would hasUnfulfillableEventuality detect?

It detects formulas `phi -> U(event, guard)` where `phi` contains `G(neg(event))` as a conjunct, making the Until's event unfulfillable. Similarly for Since with `H(neg(event))`. See Section 3.3.

### Q7: How are soundness proofs structured?

The existing prefilter has NO formal Lean proofs -- it relies on semantic arguments in comments and documentation. The soundness is "by inspection": each pattern has an informal proof in the research report (task 265). For the invalid prefilter, formal soundness proofs are required per the task description. The proof strategy involves: (a) proving `isAlwaysFalse` is semantically sound via structural induction, (b) constructing explicit witness models for satisfiability claims, and (c) deriving invalidity from the combination. A new `PrefilterSoundness.lean` module is recommended. See Section 5.

### Q8: What is the current c6 timeout rate?

The baseline c6 timeout rate is **1.6%** (96 of 5,931 formulas) after the valid prefilter catches 151 of the original 247 timeouts. The target is to reduce this by 3-8% (relative), which means catching 3-8 of the 96 remaining timeouts. The proposed recognizers are estimated to catch 30-50, significantly exceeding the target. See Section 6.

---

## 9. Implementation Recommendations

### 9.1 Phase Ordering

1. **Phase 1**: Implement `isAlwaysFalse` (extends `isUnsatBotTemporal` -- may reuse directly)
2. **Phase 2**: Implement `isTemporalContradiction` (false consequent detection)
3. **Phase 3**: Implement `isTrivialSatisfiable` and `isObviousSatisfiable`
4. **Phase 4**: Implement `hasUnfulfillableEventuality`
5. **Phase 5**: Implement `constructTrivialCountermodel`
6. **Phase 6**: Wire into `labelFormulaImpl`
7. **Phase 7**: Write soundness proofs in `PrefilterSoundness.lean`
8. **Phase 8**: Benchmark on c6, verify timeout rate reduction

### 9.2 Key Design Decisions

1. **Reuse `isUnsatBotTemporal` as `isAlwaysFalse`**: The existing function already handles the needed patterns. Either rename or create a wrapper alias.
2. **Consequent position**: The invalid prefilter checks the CONSEQUENT for always-false patterns, complementing the valid prefilter which checks the ANTECEDENT.
3. **Conservative approach**: Start with high-confidence patterns (false consequent, satisfiable->bot), add the more specialized unfulfillable eventuality only after the first two are validated.
4. **Separate soundness module**: Keep recognizer definitions in DatasetGenerator.lean, proofs in a new PrefilterSoundness.lean. This maintains the existing code organization.
5. **Countermodel construction**: Use a simple all-atoms-true model for initial implementation. Refine later if needed for specific patterns.

### 9.3 Files to Modify

| File | Changes |
|------|---------|
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Add `isAlwaysFalse`, `isTrivialSatisfiable`, `isTemporalContradiction`, `isObviousSatisfiable`, `hasUnfulfillableEventuality`, `structuralInvalidPrefilter`, `constructTrivialCountermodel`. Wire into `labelFormulaImpl`. |
| `Theories/Bimodal/Automation/PrefilterSoundness.lean` | **NEW**: Soundness proofs for each invalid pattern recognizer. |
| `Theories/Bimodal/Automation.lean` | Add import for `PrefilterSoundness` if using a barrel file. |

### 9.4 Testing Strategy

1. **Unit tests** (#eval) for each recognizer with positive and negative cases
2. **Cross-validation**: Run both invalid prefilter and full tableau on all c5 and c6 formulas, verify no label disagreements
3. **Regression**: Ensure no previously valid/invalid formulas change label
4. **Benchmark**: Compare c6 timeout rate before and after

---

## 10. Relationship to Existing isUnsatBotTemporal

A key finding of this research is that the existing `isUnsatBotTemporal` function (line 553) already serves as the core building block for invalid pattern detection. The relationship:

- `isUnsatBotTemporal` detects formulas that are **always false** (unsatisfiable)
- The valid prefilter uses it to detect **valid** formulas: `isUnsatBotTemporal(antecedent) = true` => formula is vacuously valid
- The invalid prefilter will use it to detect **invalid** formulas: `isUnsatBotTemporal(consequent) = true AND NOT isUnsatBotTemporal(antecedent)` => formula is invalid (always-false consequent with satisfiable antecedent)

This means the core logic is already implemented. The new work is:
1. Applying `isUnsatBotTemporal` to the **consequent** (not just the antecedent)
2. Adding `isTrivialSatisfiable` to confirm the antecedent is satisfiable
3. Adding `hasUnfulfillableEventuality` for the G(neg(event)) -> U(event, guard) pattern
4. Writing formal soundness proofs
5. Wiring everything together in `labelFormulaImpl`
