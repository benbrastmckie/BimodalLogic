# Loogle Fuel Pattern Search Report

**Search Pattern:** `"fuel"` (name-based search)  
**Search Date:** 2025-12-21  
**Total Matches:** 38  
**API Endpoint:** https://loogle.lean-lang.org/json?q=%22fuel%22

## Executive Summary

This search identified 38 fuel-related functions across Lean 4's standard library and core modules. The fuel pattern is primarily used for:
1. **Depth-limited recursion** - Preventing infinite recursion in algorithms
2. **Termination guarantees** - Providing structural proof of termination
3. **Resource-bounded computation** - Controlling computational complexity

The most relevant patterns for ProofChecker are found in:
- Grind tactic automation (CommRing solver, AC matching)
- Linear arithmetic solvers
- Plausible random generation
- Contradiction search

## Exact Matches

### Functions with Nat Fuel Parameters

#### 1. **Nat.div_rec_fuel_lemma** : `{x y fuel : ℕ} (hy : 0 < y) (hle : y ≤ x) (hfuel : x < fuel + 1) : x - y < fuel`
   - **Library**: Core
   - **Module**: Init.Prelude
   - **Description**: Lemma for division recursion fuel consumption. Proves that subtraction decreases fuel.

#### 2. **Lean.Grind.CommRing.Mon.revlexFuel** : `(fuel : ℕ) (m₁ m₂ : Lean.Grind.CommRing.Mon) : Ordering`
   - **Library**: Core
   - **Module**: Init.Grind.Ring.CommSolver
   - **Description**: Fuel-bounded reverse lexicographic ordering for commutative ring monomials. Uses fuel to limit recursive comparison depth.

#### 3. **Lean.Grind.AC.Seq.unionFuel** : `(fuel : ℕ) (s₁ s₂ : Lean.Grind.AC.Seq) : Lean.Grind.AC.Seq`
   - **Library**: Core
   - **Module**: Init.Grind.AC
   - **Description**: Fuel-bounded union operation for AC (associative-commutative) sequences. Critical for AC matching automation.

#### 4. **Lean.Grind.AC.Seq.unionFuel_k** : `(fuel : ℕ) : Lean.Grind.AC.Seq → Lean.Grind.AC.Seq → Lean.Grind.AC.Seq`
   - **Library**: Core
   - **Module**: Init.Grind.AC
   - **Description**: Continuation-style fuel-bounded union. Alternative formulation for proving properties.

#### 5. **Lean.Meta.Contradiction.Config.searchFuel** : `(self : Lean.Meta.Contradiction.Config) : ℕ`
   - **Library**: Core
   - **Module**: Lean.Meta.Tactic.Contradiction
   - **Description**: Configuration parameter specifying the number of goals to visit when checking for empty types during contradiction search.

#### 6. **Plausible.ArbitraryFueled.arbitraryFueled** : `{α : Type} [self : Plausible.ArbitraryFueled α] : ℕ → Plausible.Gen α`
   - **Library**: Std
   - **Module**: Plausible.ArbitraryFueled
   - **Description**: Takes a Nat fuel parameter and produces a random generator dependent on fuel (amount to use before failing).

### Functions with ADT Fuel Types

#### 7. **Lean.Elab.Tactic.Do.Fuel** : `Type`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: ADT representing fuel for the `do` tactic verification condition generator. Supports both limited and unlimited fuel.

#### 8. **Lean.Elab.Tactic.Do.Fuel.unlimited** : `Lean.Elab.Tactic.Do.Fuel`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: Constructor for unlimited fuel in do-tactic VC generation.

#### 9. **Lean.Elab.Tactic.Do.Fuel.limited** : `(n : ℕ) : Lean.Elab.Tactic.Do.Fuel`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: Constructor for limited fuel (n iterations) in do-tactic VC generation.

#### 10. **Lean.Elab.Tactic.Do.State.fuel** : `(self : Lean.Elab.Tactic.Do.State) : Lean.Elab.Tactic.Do.Fuel`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: Field accessor for fuel in do-tactic VC generator state.

### Functions Returning Option/Except

#### 11. **Plausible.Gen.Gen.outOfFuel** : `Plausible.GenError`
   - **Library**: Std
   - **Module**: Plausible.Gen
   - **Description**: Error raised when a fueled generator fails due to insufficient fuel. Used in error handling for fuel-bounded random generation.

### Constant Fuel Values

#### 12. **Nat.Linear.hugeFuel** : `ℕ`
   - **Library**: Core
   - **Module**: Init.Data.Nat.Linear
   - **Description**: Large constant fuel value for Nat linear arithmetic solver.

#### 13. **Int.Linear.hugeFuel** : `ℕ`
   - **Library**: Core
   - **Module**: Init.Data.Int.Linear
   - **Description**: Large constant fuel value for Int linear arithmetic solver.

#### 14. **Lean.Grind.CommRing.hugeFuel** : `ℕ`
   - **Library**: Core
   - **Module**: Init.Grind.Ring.CommSolver
   - **Description**: Large constant fuel value for commutative ring solver.

#### 15. **Lean.Grind.AC.hugeFuel** : `ℕ`
   - **Library**: Core
   - **Module**: Init.Grind.AC
   - **Description**: Large constant fuel value for AC matching.

### Helper Functions and Theorems

#### 16. **Lean.Grind.CommRing.Mon.eq_of_revlexFuel** : `{fuel : ℕ} {m₁ m₂ : Lean.Grind.CommRing.Mon} : Lean.Grind.CommRing.Mon.revlexFuel fuel m₁ m₂ = Ordering.eq → m₁ = m₂`
   - **Library**: Core
   - **Module**: Init.Grind.Ring.CommSolver
   - **Description**: Theorem proving that if fuel-bounded comparison returns equality, the monomials are equal.

#### 17. **Lean.Grind.AC.Seq.denote_unionFuel** : `{α : Sort u_1} (ctx : Lean.Grind.AC.Context α) {inst₁ : Std.Associative ctx.op} {inst₂ : Std.Commutative ctx.op} (fuel : ℕ) (s₁ s₂ : Lean.Grind.AC.Seq) : Lean.Grind.AC.Seq.denote ctx (Lean.Grind.AC.Seq.unionFuel fuel s₁ s₂) = ctx.op (Lean.Grind.AC.Seq.denote ctx s₁) (Lean.Grind.AC.Seq.denote ctx s₂)`
   - **Library**: Core
   - **Module**: Init.Grind.AC
   - **Description**: Correctness theorem: fuel-bounded union preserves semantics.

#### 18. **Lean.Grind.AC.Seq.unionFuel_k_eq_unionFuel** : `(fuel : ℕ) (s₁ s₂ : Lean.Grind.AC.Seq) : Lean.Grind.AC.Seq.unionFuel_k fuel s₁ s₂ = Lean.Grind.AC.Seq.unionFuel fuel s₁ s₂`
   - **Library**: Core
   - **Module**: Init.Grind.AC
   - **Description**: Equivalence between continuation-style and direct formulations.

#### 19. **Lean.Elab.Tactic.Do.ifOutOfFuel** : `{α : Type} (x k : Lean.Elab.Tactic.Do.VCGenM α) : Lean.Elab.Tactic.Do.VCGenM α`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: Conditional execution based on fuel exhaustion in VC generator monad.

#### 20. **Lean.Elab.Tactic.Do.VCGen.genVCs** : `(goal : Lean.MVarId) (ctx : Lean.Elab.Tactic.Do.Context) (fuel : Lean.Elab.Tactic.Do.Fuel) : Lean.MetaM Lean.Elab.Tactic.Do.VCGen.Result`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen
   - **Description**: Main VC generation function taking fuel parameter to bound computation.

### Typeclass Instances

#### 21. **Plausible.ArbitraryFueled** : `(α : Type) : Type`
   - **Library**: Std
   - **Module**: Plausible.ArbitraryFueled
   - **Description**: Typeclass for fueled random generation. Equivalent to Rocq QuickChick's arbitrarySized.

#### 22. **Plausible.instArbitraryOfArbitraryFueled** : `{α : Type} [Plausible.ArbitraryFueled α] : Plausible.Arbitrary α`
   - **Library**: Std
   - **Module**: Plausible.ArbitraryFueled
   - **Description**: Every ArbitraryFueled instance gives rise to an Arbitrary instance.

#### 23. **Lean.Elab.Tactic.Do.instDecidableEqFuel** : `DecidableEq Lean.Elab.Tactic.Do.Fuel`
   - **Library**: Core
   - **Module**: Lean.Elab.Tactic.Do.VCGen.Basic
   - **Description**: Decidable equality instance for Fuel type.

### Equation Lemmas and Unfolding Theorems

#### 24-38. **Multiple equation lemmas** for `revlexFuel` and `unionFuel`:
   - **revlexFuel.eq_1 through eq_5**: Pattern matching equations for monomial comparison
   - **unionFuel.eq_def**: Complete definition unfolding
   - **revlexFuel.induct_unfolding**: Induction principle for fuel-bounded comparison
   - **unionFuel.induct_unfolding**: Induction principle for fuel-bounded union
   - **Limited.injEq, unlimited.sizeOf_spec, etc.**: Infrastructure for reasoning about fuel values

## Analysis

### Total Matches: 38

### Fuel-Based Recursion Patterns Identified

1. **Structural Recursion with Explicit Fuel**
   - Pattern: `fuel : ℕ` parameter decremented on recursive calls
   - Examples: `revlexFuel`, `unionFuel`
   - Benefit: Explicit termination proof via fuel consumption

2. **ADT-Based Fuel Management**
   - Pattern: Custom `Fuel` type with `limited n | unlimited` constructors
   - Example: `Lean.Elab.Tactic.Do.Fuel`
   - Benefit: Distinguishes bounded vs unbounded computation at type level

3. **Configuration-Based Fuel**
   - Pattern: Fuel stored in configuration record
   - Example: `Contradiction.Config.searchFuel`
   - Benefit: Allows user-controlled resource bounds

4. **Huge Fuel Constants**
   - Pattern: Large constant `hugeFuel : ℕ` values
   - Examples: `Nat.Linear.hugeFuel`, `Grind.AC.hugeFuel`
   - Benefit: Practical "unlimited" fuel for most use cases

### Common Usage Patterns

1. **Match with Fuel Decrement**
   ```lean
   def fuelRecursion (fuel : ℕ) (args) : Result :=
     match fuel with
     | 0 => baseCase
     | fuel.succ => recursiveCase (fuelRecursion fuel)
   ```

2. **Fuel as Termination Witness**
   - Fuel parameter provides decreasing measure
   - Enables recursive functions that would otherwise fail termination check
   - Used extensively in Grind tactic automation

3. **Conditional Fuel Checking**
   - `ifOutOfFuel` pattern for monadic fuel management
   - Error handling via `outOfFuel` exception

4. **Correctness Preservation**
   - Theorems like `denote_unionFuel` prove fuel doesn't affect semantics
   - Fuel is purely for termination, not correctness

## Recommendations for ProofChecker

### 1. Adopt Fuel Pattern for Depth-Limited Proof Search

**Rationale**: ProofChecker's modal and temporal proof search needs bounded recursion to prevent infinite loops.

**Implementation**:
```lean
-- In Logos/Core/Automation/ProofSearch.lean
def searchWithFuel (fuel : ℕ) (goal : Formula) : ProofSearchM (Option Proof) :=
  match fuel with
  | 0 => return none  -- Out of fuel
  | fuel.succ => do
    -- Try direct axioms/theorems
    if let some proof ← tryDirectProof goal then
      return some proof
    -- Try decomposition
    match goal with
    | Formula.and p q => do
      let some pf1 ← searchWithFuel fuel p | return none
      let some pf2 ← searchWithFuel fuel q | return none
      return some (andIntro pf1 pf2)
    | Formula.modal op p => 
      -- Modal recursion with fuel decrement
      searchWithFuel fuel p
    | _ => return none

-- Default high fuel value
def defaultSearchFuel : ℕ := 1000
```

### 2. Use ADT-Based Fuel for Configuration

**Rationale**: Following `Lean.Elab.Tactic.Do.Fuel` pattern allows both bounded and unbounded search.

**Implementation**:
```lean
inductive SearchFuel where
  | limited (n : ℕ)
  | unlimited

structure ProofSearchConfig where
  fuel : SearchFuel
  maxDepth : ℕ
  useAesop : Bool
```

### 3. Prove Fuel-Independent Correctness

**Rationale**: Following `denote_unionFuel` pattern, prove that fuel doesn't affect proof validity.

**Implementation**:
```lean
theorem search_fuel_sound : 
  ∀ fuel goal proof, 
  searchWithFuel fuel goal = some proof → 
  Provable goal :=
  -- Proof by induction on fuel
```

### 4. Integrate with Existing Automation

**Locations to Add Fuel**:
- `Logos/Core/Automation/ProofSearch.lean:112` - Main search function
- `Logos/Core/Automation/Tactics.lean:245` - Modal prove tactic
- `Archive/BimodalProofStrategies.lean` - Bimodal search strategies
- `Archive/TemporalProofStrategies.lean` - Temporal induction

### 5. Fuel Constants for Different Domains

```lean
-- In Logos/Core/Automation/ProofSearch.lean
def hugeFuel : ℕ := 10000  -- For general proof search

-- In Logos/Epistemic
def epistemicSearchFuel : ℕ := 500  -- Epistemic proofs are typically shorter

-- In Archive/TemporalProofStrategies.lean  
def temporalInductionFuel : ℕ := 2000  -- Temporal induction may need more steps
```

### 6. Error Handling

```lean
-- Custom error type
inductive ProofSearchError where
  | outOfFuel
  | unprovable
  | timeout

-- Monadic fuel checking
def checkFuel : ProofSearchM Unit := do
  let config ← getConfig
  match config.fuel with
  | .limited 0 => throw .outOfFuel
  | .limited n => setConfig { config with fuel := .limited (n - 1) }
  | .unlimited => pure ()
```

### 7. Testing and Benchmarking

- Add fuel consumption metrics to proof search
- Test with varying fuel levels to find optimal defaults
- Document fuel requirements for different proof patterns
- Use in `LogosTest/Core/Automation/TacticsTest.lean`

## Technical Insights

### Pattern 1: Fuel as First-Class Termination Argument

The Grind tactic's use of fuel is sophisticated:
- Fuel is not just a counter but a first-class termination witness
- Equation lemmas (`.eq_1`, `.eq_2`, etc.) enable precise reasoning about fuel consumption
- Induction principles (`induct_unfolding`) allow proving properties by fuel induction

### Pattern 2: Huge Fuel as Pragmatic Infinity

Multiple modules define `hugeFuel : ℕ` constants:
- Avoids performance overhead of `Option` wrapper
- Provides "practically unlimited" fuel for most cases
- Simpler than monadic fuel management

### Pattern 3: Fuel-Correctness Separation

Key insight from `denote_unionFuel` theorem:
- Fuel affects **whether** computation completes
- Fuel does **not** affect **what** result is computed
- This separation is crucial for soundness

## References

- **Grind AC Matching**: `Init.Grind.AC` - Shows production fuel usage in tactic automation
- **Do Tactic VC Gen**: `Lean.Elab.Tactic.Do.VCGen.Basic` - Shows ADT-based fuel management
- **Plausible Testing**: `Plausible.ArbitraryFueled` - Shows typeclass-based fuel integration
- **Linear Arithmetic**: `Init.Data.Nat.Linear` - Shows fuel in decision procedures

## Next Steps for ProofChecker Integration

1. **Immediate** (Phase 1):
   - Add `SearchFuel` ADT to `Logos/Core/Automation/ProofSearch.lean`
   - Refactor main search function to accept fuel parameter
   - Define `defaultSearchFuel` and `hugeFuel` constants

2. **Short-term** (Phase 2):
   - Add fuel to modal and temporal proof strategies
   - Implement fuel checking in monadic search
   - Add fuel consumption metrics

3. **Medium-term** (Phase 3):
   - Prove fuel-independence theorems for search correctness
   - Benchmark optimal fuel values for different proof types
   - Document fuel requirements in tactics

4. **Long-term** (Phase 4):
   - Adaptive fuel based on proof complexity
   - Fuel-aware caching and memoization
   - Integration with RL-based proof search (see `Archive/RL_TRAINING.md`)
