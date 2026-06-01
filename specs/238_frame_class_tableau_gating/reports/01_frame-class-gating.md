# Research Report: Frame-Class-Aware Tableau Expansion

**Task**: 238 -- Extend tableau with frame-class-specific rules for Dense and Discrete axiom layers
**Date**: 2026-06-01
**Session**: sess_1780339480_9di1

---

## 1. Current Tableau Architecture

### 1.1 Module Structure

The tableau decision procedure is implemented across five modules in `Theories/Bimodal/Metalogic/Decidability/`:

| Module | Purpose |
|--------|---------|
| `SignedFormula.lean` | Core types: `Sign`, `SignedFormula`, `Branch`, `Label`, `TimeOrdering` |
| `Tableau.lean` | Rule definitions (`TableauRule`), `applyRule`, `expandOnce`, `findApplicableRule` |
| `Closure.lean` | Branch closure detection (`findClosure`, `ClosedBranch`, `ClosureReason`) |
| `Saturation.lean` | Expansion loop (`expandBranchWithFuel`, `buildTableau`), termination |
| `DecisionProcedure.lean` | Top-level `decide` function, `DecisionResult` type |

Supporting modules:
- `ProofExtraction.lean` -- Extracts `DerivationTree` from closed tableaux
- `CountermodelExtraction.lean` -- Extracts countermodels from open branches
- `Correctness.lean` -- Decidability/completeness theorems via FMP

### 1.2 Data Flow

```
decide(phi)
  -> tryAxiomProof(phi)           [fast path: axiom match]
  -> bounded_search_with_proof    [fast path: proof search]
  -> buildTableau(phi, fuel)      [main path]
       -> expandBranchWithFuel(initialBranch, fuel)
            -> findClosure(branch)        [check: closed?]
            -> expandOnce(branch, timeOrd) [expand one formula]
                 -> findUnexpanded(branch) [pick unexpanded formula]
                 -> findApplicableRule(sf, branch, timeOrd)
                 -> applyRule(rule, sf, branch, timeOrd)
       -> ExpandedTableau.allClosed | .hasOpen
  -> DecisionResult.valid | .invalid | .timeout
```

### 1.3 Rule Application

`TableauRule` is an inductive type with 20 constructors covering propositional (8), modal S5 (4), and temporal (8) rules. Rules are applied via `applyRule` which takes a `TableauRule`, `SignedFormula`, `Branch`, and `TimeOrdering`, returning a `RuleResult` (linear, branching, persistent, or notApplicable).

The rule priority order is defined in `allRules : List TableauRule` (line 696 of Tableau.lean). `findApplicableRule` iterates this list to find the first applicable rule for a given signed formula.

### 1.4 Closure Detection

`findClosure` (Closure.lean) checks three conditions:
1. `checkBotPos` -- T(bot) present
2. `checkContradiction` -- T(phi) and F(phi) at same label
3. `checkAxiomNeg` -- F(phi) where phi matches an axiom pattern via `matchAxiom`

**Critical observation**: `checkAxiomNeg` currently uses `matchAxiom` which returns axiom witnesses for ALL 42 axiom constructors, including Dense-only (density, dense_indicator) and Discrete-only (prior_UZ, prior_SZ, z1) axioms. The closure check does NOT filter by frame class. This means the current tableau incorrectly treats Dense and Discrete axioms as universally valid for closure purposes.

### 1.5 Current buildTableau Signature

```lean
def buildTableau (phi : Formula) (fuel : Nat := 1000) : Option ExpandedTableau
```

No `FrameClass` parameter. The function operates as if all axioms are valid (Base-level logic only, since proof extraction gates by `ax.minFrameClass <= FrameClass.Base`).

### 1.6 Current decide Signature

```lean
def decide (phi : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult phi
```

Similarly lacks a `FrameClass` parameter. The `DecisionResult` type is parameterized only by the formula.

---

## 2. FrameClass Type and Hierarchy

### 2.1 Definition (Axioms.lean, lines 422-427)

```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited
```

### 2.2 Ordering

The `LE` instance defines a three-element partial order:
- `Base <= Base`, `Base <= Dense`, `Base <= Discrete` (Base is bottom)
- `Dense <= Dense`, `Discrete <= Discrete` (each is reflexive)
- `Dense` and `Discrete` are **incomparable** (neither `Dense <= Discrete` nor `Discrete <= Dense`)

```
    Dense     Discrete
      ^         ^
       \       /
        Base
```

This is a `PartialOrder` instance (with `DecidableRel` for `LE`).

### 2.3 minFrameClass for Axioms (Axioms.lean, lines 456-463)

```lean
def Axiom.minFrameClass {phi : Formula} : Axiom phi -> FrameClass
  | density _ => .Dense
  | dense_indicator => .Dense
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | _ => .Base
```

This is the single source of truth for axiom-frame-class compatibility. The constraint `ax.minFrameClass <= fc` in `DerivationTree.axiom` ensures only compatible axioms appear in derivations.

### 2.4 Usage in DerivationTree (Derivation.lean)

```lean
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type where
  | axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) (h_fc : h.minFrameClass <= fc)
      : DerivationTree fc Gamma phi
  ...
```

The `fc` parameter gates axiom usage. The `lift` function provides monotonicity: `fc1 <= fc2` implies any derivation at `fc1` can be coerced to `fc2`.

---

## 3. Frame-Class-Specific Axioms

### 3.1 Dense Axioms (2 constructors)

| Axiom | Formula | Purpose |
|-------|---------|---------|
| `density phi` | `GG(phi) -> G(phi)` | Dense transitivity: if phi holds at all times strictly after all strict-future times, it holds at all strict-future times (density fills the gap) |
| `dense_indicator` | `neg U(top, bot)` | No immediate successor: on dense orders, U(top, bot) is always false since for any s > t, density provides r with t < r < s |

### 3.2 Discrete Axioms (8 constructors)

**Uniformity axioms** (5, minFrameClass = Base):
| Axiom | Formula | Purpose |
|-------|---------|---------|
| `discrete_symm_fwd` | `U(top,bot) -> S(top,bot)` | Forward gap implies backward gap |
| `discrete_symm_bwd` | `S(top,bot) -> U(top,bot)` | Backward gap implies forward gap |
| `discrete_propagate_fwd` | `U(top,bot) -> G(U(top,bot))` | Gap propagates to all future times |
| `discrete_propagate_bwd` | `U(top,bot) -> H(U(top,bot))` | Gap propagates to all past times |
| `discrete_box_necessity` | `U(top,bot) -> box(U(top,bot))` | Gap propagates to all worlds |

**Note**: The uniformity axioms have `minFrameClass = .Base`, meaning they are valid on ALL ordered abelian groups (not just discrete ones). They are named "discrete" because they characterize discreteness witness behavior, but they do not require discreteness to hold.

**Prior axioms** (2, minFrameClass = Discrete):
| Axiom | Formula | Purpose |
|-------|---------|---------|
| `prior_UZ phi` | `F(phi) -> U(phi, neg phi)` | Nearest future phi-point reachable (discrete well-ordering) |
| `prior_SZ phi` | `P(phi) -> S(phi, neg phi)` | Nearest past phi-point reachable |

**Z1 axiom** (1, minFrameClass = Discrete):
| Axiom | Formula | Purpose |
|-------|---------|---------|
| `z1 phi` | `G(G(phi)->phi) -> (F(G(phi))->G(phi))` | IsSuccArchimedean characteristic: backward induction |

### 3.3 Frame Condition Typeclasses (FrameClass.lean)

The `FrameConditions/FrameClass.lean` module defines marker typeclasses:
- `LinearTemporalFrame D` -- base: AddCommGroup + LinearOrder + IsOrderedAddMonoid
- `SerialFrame D` -- adds Nontrivial + NoMaxOrder + NoMinOrder
- `DenseTemporalFrame D` -- adds DenselyOrdered
- `DiscreteTemporalFrame D` -- adds SuccOrder + PredOrder + IsSuccArchimedean

Standard instance: `Int` is a `DiscreteTemporalFrame`.

---

## 4. Analysis: What Needs to Change

### 4.1 Parameter Threading

The core change is adding a `FrameClass` parameter to the tableau pipeline:

1. **`buildTableau`** must accept `fc : FrameClass`
2. **`expandBranchWithFuel`** must thread `fc` through
3. **`findClosure`** and specifically **`checkAxiomNeg`** must filter axioms by `ax.minFrameClass <= fc`
4. **`decide`** must accept and forward `fc : FrameClass`
5. **`DecisionResult`** should track the frame class (or at least `decide` should be generic over it)

### 4.2 Closure Detection Gating (Critical Fix)

`checkAxiomNeg` currently calls `matchAxiom` without filtering. A Dense tableau should NOT close a branch by recognizing F(prior_UZ instance) as a negated axiom, because Prior-UZ is not valid on dense frames.

**Required change**: Add `fc : FrameClass` parameter to `checkAxiomNeg` and filter:
```lean
def checkAxiomNeg (b : Branch) (fc : FrameClass := .Base) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isNeg then
      match matchAxiom sf.formula with
      | some (phi, witness) =>
          if sf.formula = phi && witness.minFrameClass <= fc then
            some (.axiomNeg phi witness sf.label)
          else none
      | none => none
    else none
```

### 4.3 Frame-Class-Specific Tableau Rules (New Rules)

Currently the `TableauRule` enum has no frame-class-specific rules. For full Dense/Discrete decision procedures, we need additional rules:

**Dense rules:**
- **Density rule**: When T(G(phi)) is on the branch, and a fresh future time t' is introduced, also introduce an intermediate time between t and t' where phi holds. This captures the density property (for any two points, there is a point between them).
- **Dense indicator closure**: When T(U(top, bot)) appears on the branch with `fc = .Dense`, close the branch immediately (since `neg U(top, bot)` is an axiom). This is already handled by `checkAxiomNeg` if we gate properly, but could also be a dedicated rule.

**Discrete rules:**
- **Prior-UZ rule**: When T(F(phi)) is on the branch with `fc = .Discrete`, can add T(U(phi, neg phi)) (the nearest future phi-point is reachable).
- **Z1 rule**: When T(G(G(phi)->phi)) and T(F(G(phi))) are on the branch with `fc = .Discrete`, can derive T(G(phi)).

### 4.4 Approach Options

**Option A: Axiom-closure-only gating (minimal, recommended first step)**

Only change `checkAxiomNeg` to filter by `fc`, and thread `fc` through `buildTableau`/`decide`. This ensures the tableau does not incorrectly close branches using frame-class-incompatible axioms. No new tableau rules are added.

- Effort: small (2-3 hours)
- Benefit: Correctness fix -- tableau now respects frame class constraints
- Limitation: The tableau cannot exploit Dense/Discrete axioms to close branches that require them

**Option B: Full frame-class-specific rules (complete)**

Add new `TableauRule` constructors for Dense and Discrete rules, extend `applyRule` and `isApplicable`, and gate both rule application and axiom closure by `fc`.

- Effort: medium-large (6-10 hours)
- Benefit: Full decision procedure for each frame class
- Risk: New rules may affect termination guarantees; density rule is non-trivial to implement soundly

**Recommended approach**: Implement Option A first as a clean parameterization pass, then extend with Option B's rules in subsequent phases.

---

## 5. Key Files Requiring Modification

### 5.1 Primary Files (must change)

| File | Changes |
|------|---------|
| `Decidability/Closure.lean` | Add `fc` parameter to `checkAxiomNeg`, `findClosure`, `isClosed`; gate axiom closure by `ax.minFrameClass <= fc` |
| `Decidability/Saturation.lean` | Thread `fc` through `expandBranchWithFuel`, `expandBranchesWithFuel`, `buildTableau`, `buildTableauAuto` |
| `Decidability/DecisionProcedure.lean` | Add `fc` parameter to `decide`, `decideAuto`, `decideOptimized`; update `isValid`, `isSatisfiable` |
| `Decidability/Tableau.lean` | Potentially extend `TableauRule` with Dense/Discrete constructors; add `fc` to `allRules`, `findApplicableRule`, `expandOnce` |

### 5.2 Secondary Files (may need updates)

| File | Changes |
|------|---------|
| `Decidability/ProofExtraction.lean` | Thread `fc` through `tryAxiomProof`, `extractProof`, `findProofCombined`; gate `proofFromAxiom` by `fc` |
| `Decidability/CountermodelExtraction.lean` | May need `fc` for correct countermodel construction |
| `Decidability/Correctness.lean` | Frame-class-specific decidability theorems |
| `Automation/ProofSearch/Core.lean` | `matchAxiom` returns all axioms; no change needed (filtering is at call site) |
| `Decidability/FMP/DenseFMP.lean` | May need updates for Dense-specific FMP |
| `Decidability/FMP/DiscreteFMP.lean` | May need updates for Discrete-specific FMP |

### 5.3 Downstream Consumers

Files that call `buildTableau`, `decide`, or `isClosed` must be updated:
- `Decidability/Saturation.lean` (test section at bottom uses `buildTableau`/`buildTableauAuto`)
- `Automation/DatasetGenerator.lean`, `Automation/EnumBenchmark.lean` (if they call decision procedures)

---

## 6. Recommended Implementation Plan

### Phase 1: Parameter Threading (Priority)

1. Add `fc : FrameClass := .Base` parameter to `findClosure`, `checkAxiomNeg`, `isClosed`, `isOpen`, `classifyBranch` in `Closure.lean`
2. Add `fc : FrameClass := .Base` to `expandBranchWithFuel`, `expandBranchesWithFuel`, `buildTableau`, `buildTableauAuto`, `recommendedFuel` in `Saturation.lean`
3. Add `fc : FrameClass := .Base` to `decide`, `decideAuto`, `decideOptimized`, `isValid`, `isSatisfiable` in `DecisionProcedure.lean`
4. Update `tryAxiomProof`, `proofFromAxiom`, `extractProof`, `findProofCombined` in `ProofExtraction.lean` to accept and forward `fc`
5. Gate `checkAxiomNeg` with `witness.minFrameClass <= fc`
6. Default all parameters to `.Base` for backward compatibility
7. Update tests in `Saturation.lean`
8. Run `lake build` to verify

### Phase 2: Frame-Class-Specific Tableau Rules

1. Add `TableauRule` constructors:
   - `densityRule` -- intermediate point insertion for Dense
   - `denseIndicatorClosure` -- close T(U(top,bot)) on Dense branches
   - `priorUZ` -- Prior-UZ decomposition for Discrete
   - `priorSZ` -- Prior-SZ decomposition for Discrete
   - `z1Rule` -- Z1 induction for Discrete
2. Implement `applyRule` cases for each
3. Gate rule applicability by `fc` in `isApplicable` and `findApplicableRule`
4. Add rules to `allRules` (conditionally, based on `fc`)
5. Integration tests for Dense and Discrete validity

### Phase 3: Correctness and Integration

1. Frame-class-specific decidability theorems in `Correctness.lean`
2. Verify soundness: Dense tableau only closes using Dense-compatible axioms
3. Verify soundness: Discrete tableau only closes using Discrete-compatible axioms
4. Update FMP modules if needed
5. Full build verification

---

## 7. Risk Assessment

### Low Risk
- Parameter threading with defaults preserves backward compatibility
- The `minFrameClass` infrastructure is already well-established in Axioms.lean and Derivation.lean
- `matchAxiom` already returns `Axiom` witnesses that carry `minFrameClass`

### Medium Risk
- New tableau rules for Dense (density rule with intermediate points) affect the `TimeOrdering` structure and may require careful termination analysis
- The interaction between density intermediate points and Until/Since temporal rules needs careful design

### High Risk
- Z1 rule implementation is non-trivial (it involves a backward induction pattern that does not map cleanly to standard tableau decomposition)
- Full completeness proofs for frame-class-specific tableaux may require significant effort (beyond this task's scope)

---

## 8. Summary of Findings

- The current tableau operates without frame-class awareness: `buildTableau` and `decide` have no `FrameClass` parameter
- `checkAxiomNeg` in `Closure.lean` accepts all 42 axioms for branch closure, including Dense-only and Discrete-only axioms, regardless of the target frame class -- this is a correctness bug for frame-class-specific decision
- The `FrameClass` type, `minFrameClass` function, and `LE` ordering are already well-established and used extensively in `DerivationTree`, `Soundness.lean`, and related modules
- The implementation approach is clear: thread `fc : FrameClass` through the pipeline with `checkAxiomNeg` gating as the critical fix, followed by optional frame-class-specific tableau rules
- Dependencies (tasks 233-235) are completed and archived
- Backward compatibility is preserved via default parameter values (`fc := .Base`)
