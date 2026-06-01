# Research Report: Frame-Class-Aware Tableau Expansion

**Task**: 238 -- Extend tableau with frame-class-specific rules for Dense and Discrete axiom layers
**Date**: 2026-06-01
**Session**: sess_1780339480_9di1

---

## 1. Current FrameClass Definition and Usage

### 1.1 FrameClass Inductive Type (Axioms.lean:422-426)

```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited
```

Three-element partial order with `Base` as bottom:
```
    Dense     Discrete
      ^         ^
       \       /
        Base
```

`Dense` and `Discrete` are incomparable -- neither `Dense <= Discrete` nor `Discrete <= Dense` holds. This is enforced by the `LE` instance and `PartialOrder` instance (lines 428-442).

### 1.2 minFrameClass (Axioms.lean:456-463)

Single source of truth for axiom-frame-class compatibility:

```lean
def Axiom.minFrameClass {phi : Formula} : Axiom phi -> FrameClass
  | density _ => .Dense
  | dense_indicator => .Dense
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | _ => .Base
```

The wildcard catch-all maps all 37 other axioms (propositional, S5 modal, BX temporal, modal-temporal interaction, uniformity) to `.Base`.

### 1.3 Usage in DerivationTree (Derivation.lean:85-92)

```lean
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type where
  | axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) (h_fc : h.minFrameClass <= fc)
      : DerivationTree fc Gamma phi
```

The `h_fc : h.minFrameClass <= fc` constraint ensures only axioms compatible with the derivation's frame class can appear. The `lift` function (lines 190-198) provides monotonicity: `fc1 <= fc2` implies any derivation at `fc1` can be coerced to `fc2`.

### 1.4 Notation

- `Gamma |- phi` defaults to `FrameClass.Base`
- `Gamma |-[fc] phi` for explicit frame class
- `|-[FrameClass.Dense] phi` for dense-class theorems

### 1.5 Frame Condition Typeclasses (FrameConditions/FrameClass.lean)

Marker typeclasses for semantic frame conditions:

| Typeclass | Requirements | Instance |
|-----------|-------------|----------|
| `LinearTemporalFrame D` | AddCommGroup + LinearOrder + IsOrderedAddMonoid | Base |
| `SerialFrame D` | + Nontrivial + NoMaxOrder + NoMinOrder | Base |
| `DenseTemporalFrame D` | + DenselyOrdered | Dense |
| `DiscreteTemporalFrame D` | + SuccOrder + PredOrder + IsSuccArchimedean | Discrete |

Standard instance: `Int` is `DiscreteTemporalFrame`.

---

## 2. Existing Axiom Layers (Dense, Discrete)

### 2.1 Dense Axioms (2 constructors, minFrameClass = Dense)

| Axiom | Formula | Semantic Meaning |
|-------|---------|-----------------|
| `density phi` | `GG(phi) -> G(phi)` | If phi holds at all times strictly after all strict-future times, it holds at all strict-future times. Density fills the gap: for any t' > t, density provides t'' with t < t'' < t', and GG(phi) at t gives G(phi) at t'', which gives phi at t'. |
| `dense_indicator` | `neg U(top, bot)` | On dense orders, `U(top,bot)` is always false since for any s > t, density provides r with t < r < s, so the interval (t,s) is never empty. |

### 2.2 Discrete Axioms

**Uniformity axioms (5 constructors, minFrameClass = Base)**:

These are valid on ALL ordered abelian groups, not just discrete ones. They encode translation-invariance properties of the discreteness witness `U(top,bot)`.

| Axiom | Formula |
|-------|---------|
| `discrete_symm_fwd` | `U(top,bot) -> S(top,bot)` |
| `discrete_symm_bwd` | `S(top,bot) -> U(top,bot)` |
| `discrete_propagate_fwd` | `U(top,bot) -> G(U(top,bot))` |
| `discrete_propagate_bwd` | `U(top,bot) -> H(U(top,bot))` |
| `discrete_box_necessity` | `U(top,bot) -> box(U(top,bot))` |

**Prior axioms (2 constructors, minFrameClass = Discrete)**:

| Axiom | Formula | Semantic Meaning |
|-------|---------|-----------------|
| `prior_UZ phi` | `F(phi) -> U(phi, neg phi)` | Nearest future phi-point reachable via well-ordering of definable sets on discrete orders |
| `prior_SZ phi` | `P(phi) -> S(phi, neg phi)` | Past dual of Prior-UZ |

**Z1 axiom (1 constructor, minFrameClass = Discrete)**:

| Axiom | Formula | Semantic Meaning |
|-------|---------|-----------------|
| `z1 phi` | `G(G(phi)->phi) -> (F(G(phi))->G(phi))` | IsSuccArchimedean characteristic: backward induction from any reachable G(phi)-witness yields G(phi) everywhere |

### 2.3 Soundness Verification

Frame-class-specific soundness theorems exist:
- `Metalogic/DenseSoundness.lean`: `axiom_dense_valid` -- all axioms with `minFrameClass <= .Dense` are valid over dense temporal orders
- `Metalogic/DiscreteSoundness.lean`: `axiom_discrete_valid` -- all axioms with `minFrameClass <= .Discrete` are valid over discrete temporal orders

Both use the centralized `Metalogic/Soundness.lean` which dispatches by frame class variant.

---

## 3. Current buildTableau and decide Function Architecture

### 3.1 Module Dependency Chain

```
SignedFormula.lean  -->  Tableau.lean  -->  Closure.lean  -->  Saturation.lean
                                                                     |
                                                              ProofExtraction.lean
                                                              CountermodelExtraction.lean
                                                                     |
                                                              DecisionProcedure.lean
                                                                     |
                                                              Correctness.lean
```

### 3.2 buildTableau (Saturation.lean:157-166)

```lean
def buildTableau (phi : Formula) (fuel : Nat := 1000) : Option ExpandedTableau :=
  let initialBranch : Branch := [SignedFormula.neg phi Label.initial]
  match expandBranchWithFuel initialBranch fuel with
  | none => none  -- Out of fuel
  | some (.inl closedBr) => some (.allClosed [closedBr])
  | some (.inr openBr) =>
      match h : findUnexpanded openBr with
      | none => some (.hasOpen openBr h)
      | some _ => none  -- Should be saturated but isn't
```

**Key observation**: No `FrameClass` parameter. `expandBranchWithFuel` calls `findClosure` which calls `checkAxiomNeg` without frame class filtering.

### 3.3 expandBranchWithFuel (Saturation.lean:92-118)

```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty) : Option (ClosedBranch + Branch) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
      match findClosure b with
      | some reason => some (.inl (closedBranch_mk b reason))
      | none =>
          match expandOnce b timeOrd with
          | (.saturated, _) => some (.inr b)
          | (.extended newBranch, newOrd) => expandBranchWithFuel newBranch fuel newOrd
          | (.split branches, newOrd) =>
              -- Check if ALL branches close
              ...
```

The loop is: findClosure -> expandOnce -> recurse. Frame class is missing from both findClosure and expandOnce.

### 3.4 decide (DecisionProcedure.lean:120-157)

```lean
def decide (phi : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult phi :=
  -- Fast path: direct axiom proof
  match tryAxiomProof phi with
  | some proof => .valid proof
  | none =>
    -- Try proof search
    match bounded_search_with_proof [] phi searchDepth with
    | (some proof, _, _) => .valid proof
    | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau phi tableauFuel with
      | none => .timeout
      | some (.allClosed closedBranches) =>
          -- Try to extract proof with frame class gate
          let axiomProofs := closedBranches.filterMap fun cb =>
            match cb.reason with
            | .axiomNeg psi ax _ =>
                if h : phi = psi then
                  if h_fc : ax.minFrameClass <= FrameClass.Base then
                    some (h |> DerivationTree.axiom [] psi ax h_fc)
                  else none
                else none
            | _ => none
          ...
```

**Key observation**: `decide` does gate proof extraction by `ax.minFrameClass <= FrameClass.Base`, but `buildTableau` does not gate branch closure. This means the tableau may close branches using Dense/Discrete axioms and then fail to extract proofs because the frame class check rejects them.

### 3.5 Closure Detection (Closure.lean)

```lean
def checkAxiomNeg (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isNeg then
      match matchAxiom sf.formula with
      | some (phi, witness) =>
          if sf.formula = phi then
            some (.axiomNeg phi witness sf.label)
          else none
      | none => none
    else none
```

**BUG**: No frame class filtering. `matchAxiom` returns witnesses for all 42 axiom constructors. A branch containing `F(GG(p) -> G(p))` would close via `density` axiom recognition even at `FrameClass.Base`.

### 3.6 Rule Application (Tableau.lean)

`TableauRule` has 20 constructors: 8 propositional, 4 modal S5, 8 temporal. No Dense or Discrete specific rules exist. The `allRules` list and `applyRule` function are frame-class-agnostic.

---

## 4. Design for Parameterizing buildTableau by FrameClass

### 4.1 Parameter Threading Strategy

Add `fc : FrameClass := .Base` to each function in the pipeline:

| Function | File | Change |
|----------|------|--------|
| `checkAxiomNeg` | Closure.lean | Add `fc` param, gate `witness.minFrameClass <= fc` |
| `findClosure` | Closure.lean | Add `fc`, forward to `checkAxiomNeg` |
| `isClosed` | Closure.lean | Add `fc`, forward to `findClosure` |
| `isOpen` | Closure.lean | Add `fc`, forward to `isClosed` |
| `classifyBranch` | Closure.lean | Add `fc`, forward to `findClosure` |
| `expandBranchWithFuel` | Saturation.lean | Add `fc`, forward to `findClosure` |
| `expandBranchesWithFuel` | Saturation.lean | Add `fc`, forward to `expandBranchWithFuel` |
| `buildTableau` | Saturation.lean | Add `fc`, forward to `expandBranchWithFuel` |
| `buildTableauAuto` | Saturation.lean | Add `fc`, forward to `buildTableau` |
| `decide` | DecisionProcedure.lean | Add `fc`, forward to `buildTableau` + `tryAxiomProof` |
| `decideAuto` | DecisionProcedure.lean | Add `fc`, forward to `decide` |
| `decideOptimized` | DecisionProcedure.lean | Add `fc`, forward to `decide` |
| `isValid` | DecisionProcedure.lean | Add `fc`, forward to `decide` |
| `isSatisfiable` | DecisionProcedure.lean | Add `fc`, forward to `isValid` |
| `tryAxiomProof` | ProofExtraction.lean | Add `fc`, gate `ax.minFrameClass <= fc` |
| `proofFromAxiom` | ProofExtraction.lean | Change `FrameClass.Base` to `fc` |
| `extractProof` | ProofExtraction.lean | Add `fc`, thread through |
| `findProofCombined` | ProofExtraction.lean | Add `fc`, thread through |

### 4.2 Backward Compatibility

All new `fc` parameters default to `.Base`, preserving existing call sites without modification. Existing tests that call `buildTableau phi 50` or `buildTableauAuto phi` continue to work at `FrameClass.Base`.

### 4.3 DecisionResult Type

The `DecisionResult` type currently carries the formula `phi` as a parameter. It should also carry `fc`:

```lean
inductive DecisionResult (fc : FrameClass) (phi : Formula) : Type where
  | valid (proof : |-[fc] phi)
  | invalid (counter : SimpleCountermodel)
  | timeout
```

This ensures proof terms are correctly typed at the appropriate frame class.

**Alternative (simpler)**: Keep `DecisionResult` parameterized only by `phi`, and existentially quantify over `fc` in the proof field. The current approach already does this implicitly since `tryAxiomProof` gates by `FrameClass.Base`. Extending it to accept `fc` is straightforward.

### 4.4 Proof Search Integration

`bounded_search_with_proof` in ProofSearch/Core.lean currently produces `DerivationTree FrameClass.Base [] phi`. For frame-class-aware decision, it should be parameterized by `fc`. However, this is a larger change (proof search constructs `DerivationTree.axiom` calls). The minimal approach: keep proof search at Base, and only use it when `fc = .Base` or when `FrameClass.Base <= fc` (always true).

---

## 5. Rule Gating Strategy: minFrameClass <= fc

### 5.1 Axiom Closure Gating (Critical Fix)

The central gating mechanism for `checkAxiomNeg`:

```lean
def checkAxiomNeg (b : Branch) (fc : FrameClass := .Base) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isNeg then
      match matchAxiom sf.formula with
      | some (phi, witness) =>
          if sf.formula = phi && decide (witness.minFrameClass <= fc) then
            some (.axiomNeg phi witness sf.label)
          else none
      | none => none
    else none
```

The `decide (witness.minFrameClass <= fc)` check uses the `DecidableRel` instance for `LE` on `FrameClass` (Axioms.lean:435-436), which evaluates in O(1).

### 5.2 Gating Behavior Matrix

| Axiom | minFrameClass | Closes at Base | Closes at Dense | Closes at Discrete |
|-------|--------------|----------------|-----------------|-------------------|
| prop_k, prop_s, etc. (37) | Base | Yes | Yes | Yes |
| density phi | Dense | **No** | Yes | **No** |
| dense_indicator | Dense | **No** | Yes | **No** |
| prior_UZ phi | Discrete | **No** | **No** | Yes |
| prior_SZ phi | Discrete | **No** | **No** | Yes |
| z1 phi | Discrete | **No** | **No** | Yes |

The **No** entries represent the correctness fix: Dense axioms should not close branches in Base or Discrete tableaux, and Discrete axioms should not close branches in Base or Dense tableaux.

### 5.3 TableauRule Gating

For frame-class-specific rules (Phase 2), add a `minFrameClass` function on `TableauRule`:

```lean
def TableauRule.minFrameClass : TableauRule -> FrameClass
  | .densityRule => .Dense
  | .denseIndicator => .Dense
  | .priorUZRule => .Discrete
  | .priorSZRule => .Discrete
  | .z1Rule => .Discrete
  | _ => .Base
```

And gate `findApplicableRule`:

```lean
def findApplicableRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option (...) :=
  (allRules fc).findSome? fun rule => ...

def allRules (fc : FrameClass := .Base) : List TableauRule :=
  baseRules ++ (if fc = .Dense then denseRules else [])
             ++ (if fc = .Discrete then discreteRules else [])
```

---

## 6. Dense-Specific Rules

### 6.1 Density Rule (Intermediate Points)

**Semantic basis**: On a dense order, for any t < t', there exists u with t < u < t'. This means every strict future time has intermediate times.

**Tableau rule**: When an existential temporal rule introduces a fresh time t' in the future of t (e.g., from `F(GA)` creating t' > t with `F(A)` at t'), the density rule can introduce an intermediate time u between t and t'. At u, all universal G-formulas from t propagate (since u > t), and all universal F-neg formulas propagate.

**Implementation sketch**:

```lean
| .densityRule => -- When creating fresh future time t' > t
    -- For each pair (t, t') in timeOrd.constraints where t < t':
    --   Introduce fresh time u with t < u < t'
    --   Propagate T(GA) from t to u
    --   Propagate F(FA) from t to u
    --   Also propagate T(GA) from u to t' (since u < t')
```

**Termination concern**: Unrestricted density rule application would create infinite intermediate points. The rule must be applied lazily, only when needed to close a branch (e.g., when `T(GG(phi))` and `F(G(phi))` are present, density provides the intermediate point needed to derive `T(G(phi))` from `T(GG(phi))`).

**Practical approach**: Rather than a general density rule, implement density as a specific rule for the density axiom pattern: when `T(GG(phi))` is on the branch, also add `T(G(phi))` (since `GG(phi) -> G(phi)` is a Dense axiom). This is handled by axiom closure gating (recognizing `F(GG(phi) -> G(phi))` as a negated axiom), so the density rule may not need a separate `TableauRule` constructor.

### 6.2 Dense Indicator

**Semantic basis**: On dense orders, `U(top, bot)` is always false (no immediate successors).

**Tableau rule**: When `T(U(top, bot))` appears on a Dense branch, close immediately (since `neg U(top, bot)` is a Dense axiom, the branch is inconsistent).

**Implementation**: Already handled by axiom closure gating. When `F(neg U(top, bot))` is on the branch (i.e., `T(U(top, bot))`), this is `T(U(top,bot))`, and the axiom `dense_indicator : neg U(top, bot)` means `F(dense_indicator)` = `F(neg U(top, bot))` = `T(U(top, bot))` which is the dual. Actually, more precisely:

- `dense_indicator` has formula `neg U(top, bot)` = `U(top, bot).imp bot`
- `checkAxiomNeg` looks for `F(phi)` where `phi` matches an axiom
- So it looks for `F(U(top, bot).imp bot)` = `F(neg U(top, bot))`
- This means the branch must contain the signed formula `F(neg U(top, bot))`

For `T(U(top, bot))` to close, we need a different mechanism: a contradiction between `T(U(top, bot))` and the Dense axiom `neg U(top, bot)`. The axiom closure approach detects `F(axiom)`, not `T(neg axiom)`. So we need either:
1. A propositional decomposition step that converts `T(U(top, bot))` into something that contradicts `neg U(top, bot)`, or
2. A dedicated rule that recognizes `T(U(top, bot))` as inconsistent on Dense frames

**Recommended**: Add a dedicated check in `findClosure` for Dense frames that detects `T(U(top, bot))` directly.

---

## 7. Discrete-Specific Rules

### 7.1 Prior-UZ Rule

**Semantic basis**: On discrete orders, `F(phi) -> U(phi, neg phi)`. If phi holds somewhere in the future, the nearest future phi-point is reachable.

**Tableau rule**: When `T(F(phi))` appears on a Discrete branch, add `T(U(phi, neg phi))` (the Until formula guaranteeing nearest-witness access).

**Implementation**:

```lean
| .priorUZRule, .pos, phi =>
    match asSomeFuture? phi with
    | some psi =>
        -- T(F(psi)) -> add T(U(psi, neg psi))
        (.linear [SignedFormula.pos (.untl psi psi.neg) l], timeOrd)
    | none => (.notApplicable, timeOrd)
```

The Until formula `U(psi, neg psi)` is then handled by existing `untlPos` rule decomposition.

### 7.2 Prior-SZ Rule

**Symmetric past dual**: When `T(P(phi))` appears on a Discrete branch, add `T(S(phi, neg phi))`.

```lean
| .priorSZRule, .pos, phi =>
    match asSomePast? phi with
    | some psi =>
        -- T(P(psi)) -> add T(S(psi, neg psi))
        (.linear [SignedFormula.pos (.snce psi psi.neg) l], timeOrd)
    | none => (.notApplicable, timeOrd)
```

### 7.3 Z1 Rule

**Semantic basis**: `G(G(phi)->phi) -> (F(G(phi))->G(phi))`. If the induction step `G(phi)->phi` holds at all future times, and `G(phi)` holds at some future time, then `G(phi)` holds now.

**Tableau rule**: This is complex because it involves detecting two premises on the branch:
1. `T(G(G(phi)->phi))` -- induction step holds universally
2. `T(F(G(phi)))` -- base case exists

When both are present, add `T(G(phi))`.

**Implementation sketch**:

```lean
| .z1Rule, .pos, phi =>
    -- This rule is triggered by scanning for matching pairs
    -- Not easily expressed as single-formula decomposition
    -- May need a multi-formula trigger mechanism
```

**Practical approach**: Z1 is more naturally handled by axiom closure. When `F(G(G(phi)->phi) -> (F(G(phi))->G(phi)))` appears on the branch, `checkAxiomNeg` with `fc = .Discrete` recognizes it as a negated Z1 axiom and closes the branch. The decomposition approach via propositional rules eventually produces this negated axiom form.

### 7.4 Uniformity Axioms

The 5 uniformity axioms have `minFrameClass = .Base` so they are already active in all frame classes via `checkAxiomNeg`. No special handling needed.

---

## 8. Integration Points and Modification Plan

### 8.1 Phase 1: Parameter Threading and Axiom Closure Gating

**Files to modify (in dependency order)**:

1. **Closure.lean** (11 functions):
   - `checkAxiomNeg`: Add `fc`, gate by `witness.minFrameClass <= fc`
   - `findClosure`: Add `fc`, forward
   - `isClosed`: Add `fc`, forward
   - `isOpen`: Add `fc`, forward
   - `classifyBranch`: Add `fc`, forward
   - Monotonicity lemmas: Thread `fc` through `checkBotPos_mono`, `checkContradiction_mono`, `checkAxiomNeg_mono`, `closed_extend_closed`, `add_neg_causes_closure`

2. **Saturation.lean** (5 functions):
   - `expandBranchWithFuel`: Add `fc`, forward to `findClosure`
   - `expandBranchesWithFuel`: Add `fc`, forward
   - `buildTableau`: Add `fc`, forward
   - `buildTableauAuto`: Add `fc`, forward
   - Update test `#eval` blocks at bottom

3. **ProofExtraction.lean** (5 functions):
   - `proofFromAxiom`: Change hardcoded `FrameClass.Base` to `fc`
   - `extractFromClosureReason`: Add `fc`, gate
   - `tryAxiomProof`: Add `fc`, gate by `fc`
   - `extractProof`: Add `fc`, thread
   - `findProofCombined`: Add `fc`, thread

4. **DecisionProcedure.lean** (7 functions):
   - `DecisionResult`: Consider adding `fc` parameter for typed proofs
   - `decide`: Add `fc`, thread to `buildTableau` and `tryAxiomProof`
   - `isValid`: Add `fc`
   - `isSatisfiable`: Add `fc`
   - `decideAuto`: Add `fc`
   - `decideOptimized`: Add `fc`
   - `decideBatch`: Add `fc`

5. **CountermodelExtraction.lean**: May need `fc` for countermodel metadata

6. **Correctness.lean**: Frame-class-specific decidability theorems

**Estimated scope**: ~100-150 LOC changes, primarily mechanical parameter threading with the critical fix being the 2-line gating check in `checkAxiomNeg`.

### 8.2 Phase 2: Frame-Class-Specific Tableau Rules

1. Add 4 new `TableauRule` constructors: `densityTransit`, `denseIndicatorClose`, `priorUZRule`, `priorSZRule`
2. Extend `applyRule` with 4 new cases
3. Extend `isApplicable` with 4 new cases
4. Modify `allRules` to accept `fc` and conditionally include rules
5. Modify `findApplicableRule` to thread `fc`
6. Modify `expandOnce` and `findUnexpanded` to thread `fc`
7. Add dedicated Dense closure check for `T(U(top, bot))`

**Estimated scope**: ~150-200 LOC, primarily in Tableau.lean

### 8.3 Phase 3: Correctness and Testing

1. Frame-class-specific decidability theorems in Correctness.lean
2. Test suite: Dense validity/invalidity examples
3. Test suite: Discrete validity/invalidity examples
4. Verify existing Base tests still pass
5. Verify `lake build` succeeds

### 8.4 Downstream Impact Assessment

| File | Impact | Reason |
|------|--------|--------|
| `Automation/DatasetGenerator.lean` | Medium | Calls tableau functions; needs `fc` parameter |
| `Automation/EnumBenchmark.lean` | Medium | Calls tableau functions |
| `Automation/DataExport.lean` | Low | May call decision procedures |
| `Decidability/FMP/DenseFMP.lean` | Low | MCS-based, frame-class independent |
| `Decidability/FMP/DiscreteFMP.lean` | Low | MCS-based, frame-class independent |
| Tests throughout Saturation.lean | Medium | Existing `#eval` tests need update |

### 8.5 Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Backward compatibility | Low | Default `fc := .Base` preserves all existing call sites |
| Termination (density rule) | Medium | Lazy application only when needed; fuel bound prevents divergence |
| Proof extraction correctness | Low | Frame class gating in extraction already partially exists |
| Z1 rule complexity | High | Defer to axiom closure rather than dedicated decomposition rule |
| Test coverage | Medium | Add Dense and Discrete specific test formulas |

---

## 9. Summary

The current tableau decision procedure (buildTableau, decide) operates without frame-class awareness. The critical bug is in `checkAxiomNeg` (Closure.lean), which accepts all 42 axioms for branch closure without filtering by frame class -- Dense-only axioms (density, dense_indicator) and Discrete-only axioms (prior_UZ, prior_SZ, z1) are incorrectly treated as universally valid.

The fix is well-scoped: the `FrameClass` type, `minFrameClass` function, `LE` ordering, and `DecidableRel` instance are already established. The implementation requires threading an `fc : FrameClass` parameter through ~25 functions across 6 files, with the critical change being a 2-line gating check in `checkAxiomNeg`.

Frame-class-specific tableau rules (density, Prior-UZ/SZ) are optional extensions that enhance the decision procedure's power for Dense and Discrete frames. The Prior rules are straightforward (linear rule adding Until/Since formulas). The density rule requires careful termination analysis. The Z1 rule is best handled by axiom closure rather than decomposition.
