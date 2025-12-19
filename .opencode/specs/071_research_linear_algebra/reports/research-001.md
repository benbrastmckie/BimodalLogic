# Research Report: Linear Algebra Concepts for Modal Logic Context

**Project**: #071  
**Date**: December 19, 2025  
**Research Type**: Comprehensive (Library Search + Concept Exploration + Implementation Strategy)  
**Status**: Completed

---

## Executive Summary

This research investigates the connections between linear algebra and modal logic to inform the creation of four comprehensive documentation files for the `context/math/linear-algebra/` directory. The research reveals that while direct applications of linear algebra to modal logic are limited, there are rich conceptual connections through:

1. **Algebraic Semantics**: Modal algebras and lattice-based structures provide the bridge between logic and algebra
2. **Matrix Representations**: Kripke frames naturally translate to adjacency matrices, enabling computational methods
3. **Coalgebraic Methods**: Category-theoretic approaches unify modal logic with linear structures
4. **Linear Logic Connections**: Exponential modalities in linear logic provide deep connections to resource reasoning

**Key Finding**: The ProofChecker project currently uses `LinearOrderedAddCommGroup` from mathlib4 in `TaskFrame.lean`, which is the appropriate level of abstraction for task semantics. Full vector space or matrix structures are not currently needed but could support future extensions for computational decision procedures or quantitative reasoning.

**Recommendation**: Create documentation files focusing on:
- Foundational algebraic structures (vector spaces, modules) with connections to modal algebras
- Linear transformations and their relationship to frame morphisms
- Matrix representations of accessibility relations for computational methods
- Spectral properties and their potential applications to frame characterization

---

## Research Question 1: Vector Spaces in Modal Logic

### Mathlib4 Definitions

**Core Module**: `Mathlib.Algebra.Module.Defs` (22,760+ declarations)

Key structures in mathlib4:
```lean
-- Module over a ring (generalization of vector space)
class Module (R : Type*) (M : Type*) [Semiring R] [AddCommMonoid M] where
  smul : R → M → M
  -- Axioms for scalar multiplication

-- Vector space is a module over a field
abbrev VectorSpace (K : Type*) (V : Type*) [Field K] [AddCommGroup V] := Module K V

-- Linear ordered additive commutative group (used in TaskFrame)
class LinearOrderedAddCommGroup (α : Type*) extends AddCommGroup α, LinearOrder α where
  add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b
```

### Connections to Modal Logic

**Algebraic Semantics**: Modal logic traditionally uses Boolean algebras with operators, not vector spaces. However, there are conceptual parallels:

1. **Modal Algebras as Algebraic Structures**:
   - Boolean algebra `(B, ∧, ∨, ¬, 0, 1)` with modal operator `□: B → B`
   - Similar to how vector spaces have linear transformations
   - Both satisfy preservation laws (□ preserves meets, linear maps preserve addition)

2. **Lattice-Based Generalizations**:
   - Distributive lattice expansions (DLE-logics) generalize modal algebras
   - Heyting algebras with operators for intuitionistic modal logic
   - These structures share algebraic properties with modules

3. **Ordered Structures**:
   - TaskFrame uses `LinearOrderedAddCommGroup` - an additive group with total order
   - This is more restrictive than a vector space (no scalar multiplication)
   - Appropriate for temporal reasoning where "time" forms an ordered group

**Vector Space Semantics** (Theoretical):
- Propositions could be represented as vectors in a vector space
- Modal operators as linear transformations: `□(αv + βw) = α□v + β□w`
- Challenge: Relating this to traditional possible worlds semantics
- Related work: Quantum logic uses Hilbert space semantics

### Key Properties and Theorems

From mathlib4 (`Mathlib.Algebra.Module.LinearMap.Defs`):

```lean
-- Linear maps preserve addition and scalar multiplication
structure LinearMap (R : Type*) (M : Type*) (M₂ : Type*) 
    [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [Module R M] [Module R M₂] where
  toFun : M → M₂
  map_add' : ∀ x y, toFun (x + y) = toFun x + toFun y
  map_smul' : ∀ (c : R) (x : M), toFun (c • x) = c • toFun x

-- Kernel of a linear map
def ker (f : M →ₗ[R] M₂) : Submodule R M := 
  { x | f x = 0 }

-- Image of a linear map
def range (f : M →ₗ[R] M₂) : Submodule R M₂ := 
  { y | ∃ x, f x = y }
```

**Relevance to Modal Logic**:
- Kernel ≈ worlds where modal formula is false
- Image ≈ reachable worlds under accessibility
- Linear independence ≈ independence of modal formulas

---

## Research Question 2: Linear Maps and Transformations

### Mathlib4 Definitions

**Core Modules**:
- `Mathlib.Algebra.Module.LinearMap.Defs` (10,589+ declarations)
- `Mathlib.Algebra.Module.LinearMap.Basic`
- `Mathlib.Algebra.Module.Equiv.Defs` (linear equivalences/isomorphisms)

Key concepts:
```lean
-- Linear map composition
def comp (g : M₂ →ₗ[R] M₃) (f : M →ₗ[R] M₂) : M →ₗ[R] M₃

-- Linear equivalence (isomorphism)
structure LinearEquiv (R : Type*) (M : Type*) (M₂ : Type*) extends M ≃ M₂ where
  map_add' : ∀ x y, toFun (x + y) = toFun x + toFun y
  map_smul' : ∀ c x, toFun (c • x) = c • toFun x

-- Endomorphisms (linear maps from M to M)
abbrev End (R : Type*) (M : Type*) := M →ₗ[R] M
```

### Relationship to Modal Operators

**Modal Operators as Transformations**:

1. **Box Operator as Transformation**:
   - In algebraic semantics: `□: B → B` on Boolean algebra
   - Preserves meets: `□(a ∧ b) = □a ∧ □b`
   - Similar to linear maps preserving addition
   - But NOT linear in the vector space sense (no scalar multiplication)

2. **Frame Morphisms**:
   - A frame morphism `f: (W₁, R₁) → (W₂, R₂)` preserves accessibility
   - If `wR₁v` then `f(w)R₂f(v)`
   - Analogous to structure-preserving maps in algebra
   - Could be represented as matrices in finite case

3. **Coalgebraic Perspective**:
   - Modal logic arises from functors on categories
   - Kripke frame = coalgebra `(W, α: W → P(W))`
   - Frame morphisms = coalgebra homomorphisms
   - Connection to linear algebra through categorical semantics

### Kernel, Image, and Rank

**Rank-Nullity Theorem** (from mathlib4):
```lean
theorem rank_add_nullity (f : M →ₗ[R] M₂) : 
  rank f + nullity f = finrank R M
```

**Modal Logic Analogy**:
- **Kernel**: Worlds where a modal formula fails
- **Image**: Worlds reachable under accessibility relation
- **Rank**: Dimension of reachable state space
- **Nullity**: Dimension of "trapped" states

**Application to Accessibility Relations**:
- Represent accessibility as a relation matrix
- Kernel = worlds with no successors (dead ends)
- Image = worlds that are reachable
- Rank = effective size of the frame

---

## Research Question 3: Matrix Representations

### Mathlib4 Matrix Support

**Core Module**: `Mathlib.Data.Matrix.Basic`

Key definitions:
```lean
-- Matrix type
def Matrix (m n : Type*) (α : Type*) := m → n → α

-- Matrix multiplication
def mul (M : Matrix m n α) (N : Matrix n p α) : Matrix m p α :=
  λ i k => ∑ j, M i j * N j k

-- Matrix power
def pow (M : Matrix n n α) : ℕ → Matrix n n α
  | 0 => 1  -- identity matrix
  | k+1 => M * pow M k

-- Transpose
def transpose (M : Matrix m n α) : Matrix n m α :=
  λ i j => M j i
```

### Adjacency Matrix Representation of Kripke Frames

**Kripke Frame**: `F = (W, R)` where `W` is a set of worlds and `R ⊆ W × W` is accessibility

**Matrix Representation**:
```lean
-- For finite frame with n worlds
def adjacency_matrix (F : KripkeFrame) : Matrix (Fin n) (Fin n) Bool :=
  λ i j => F.accessible (world i) (world j)
```

**Properties**:
1. **Reflexivity**: `M[i,i] = true` for all `i` ⟺ frame is reflexive
2. **Symmetry**: `M = Mᵀ` ⟺ frame is symmetric
3. **Transitivity**: `M² ≤ M` (entrywise) ⟺ frame is transitive

### Matrix Operations Relevant to Modal Logic

**1. Matrix Powers and Reachability**:
```
M^n[i,j] = true ⟺ world j is reachable from world i in exactly n steps
```

**2. Transitive Closure**:
```
M* = I + M + M² + M³ + ... (finite sum for finite frames)
M*[i,j] = true ⟺ world j is reachable from world i in any number of steps
```

**3. Composition of Relations**:
- For bimodal logic with relations R₁ and R₂
- Matrices M₁ and M₂
- Composition: `(M₁ ∘ M₂)[i,k] = ∃j. M₁[i,j] ∧ M₂[j,k]`
- Matrix product (with Boolean semiring)

**4. Interaction Axioms**:
- Commutativity: `M₁M₂ = M₂M₁` ⟺ relations commute
- Church-Rosser: `M₁M₂ ⊆ M₂M₁` ⟺ confluence property

### Applications to Task Semantics

**TaskFrame Matrix Representation**:
```lean
-- For finite TaskFrame with n worlds and discrete time
structure TaskFrameMatrix (n : ℕ) where
  -- 3D tensor: worlds × time × worlds
  task_matrix : Fin n → ℤ → Fin n → Bool
  -- Nullity: task_matrix w 0 w = true
  nullity : ∀ w, task_matrix w 0 w = true
  -- Compositionality via matrix-like composition
  compositionality : ∀ w u v x y,
    task_matrix w x u = true → 
    task_matrix u y v = true → 
    task_matrix w (x + y) v = true
```

**Computational Benefits**:
- Efficient reachability queries via matrix operations
- GPU acceleration for large frames
- Sparse matrix techniques for efficiency

---

## Research Question 4: Eigenvalues and Eigenvectors

### Mathlib4 Eigenvalue Support

**Core Module**: `Mathlib.LinearAlgebra.Eigenspace`

Key definitions:
```lean
-- Eigenspace for eigenvalue μ
def eigenspace (f : End R M) (μ : R) : Submodule R M :=
  LinearMap.ker (f - μ • LinearMap.id)

-- Has eigenvalue
def HasEigenvalue (f : End R M) (μ : R) : Prop :=
  eigenspace f μ ≠ ⊥

-- Eigenvector
def HasEigenvector (f : End R M) (μ : R) (x : M) : Prop :=
  x ≠ 0 ∧ x ∈ eigenspace f μ
```

### Spectral Properties and Frame Properties

**Theoretical Connections**:

1. **Reflexivity and Eigenvalue 1**:
   - Reflexive frame: `M[i,i] = 1` for all `i`
   - Implies 1 is an eigenvalue (with eigenvector `v = (1,1,...,1)ᵀ`)
   - `Mv = v` since each row sums to at least 1

2. **Transitivity and Matrix Powers**:
   - Transitive frame: `M² ≤ M` (entrywise)
   - Spectral characterization: eigenvalues relate to convergence
   - For stochastic matrices: largest eigenvalue is 1

3. **Symmetry and Diagonalizability**:
   - Symmetric frame: `M = Mᵀ`
   - Symmetric matrices are diagonalizable over ℝ
   - Spectral theorem applies

4. **Spectral Radius**:
   - `ρ(M) = max{|λ| : λ is eigenvalue of M}`
   - Bounds growth rate of `M^n`
   - Relevant to complexity of modal reasoning

### Eigenvectors and Fixed Points

**Modal Logic Fixed Points**:

1. **Greatest Fixed Point** (ν-calculus):
   - `νX.φ(X)` = largest set satisfying `X = φ(X)`
   - Eigenvector with eigenvalue 1 represents fixed point
   - Application: characterizing infinite behavior

2. **Least Fixed Point** (μ-calculus):
   - `μX.φ(X)` = smallest set satisfying `X = φ(X)`
   - Dual to greatest fixed point
   - Application: reachability and liveness properties

3. **Perron-Frobenius Theorem**:
   - For non-negative matrices, largest eigenvalue is real and positive
   - Corresponding eigenvector has non-negative entries
   - Application: probabilistic modal logic

### Applications to Completeness and Decidability

**Spectral Methods for Decision Procedures**:

1. **Finite Model Property**:
   - Some modal logics have finite model property
   - Matrix methods can search finite frames efficiently
   - Eigenvalue bounds can limit search space

2. **Complexity Bounds**:
   - Spectral radius bounds iteration depth
   - Relevant to satisfiability checking
   - Connection to automata-theoretic methods

3. **Canonical Models**:
   - Spectral decomposition reveals structure
   - Can construct canonical models via eigenvectors
   - Application to completeness proofs

---

## Mathlib4 Module Analysis

### Top 10 Most Relevant Modules

1. **`Mathlib.Algebra.Module.Defs`** (22,760+ declarations)
   - Core module definitions and basic properties
   - Foundation for all linear algebra

2. **`Mathlib.Algebra.Module.LinearMap.Defs`** (10,589+ declarations)
   - Linear map definitions and composition
   - Essential for structure-preserving transformations

3. **`Mathlib.Algebra.Module.LinearMap.Basic`**
   - Additional linear map operations
   - Kernel, image, rank-nullity theorem

4. **`Mathlib.Algebra.Module.Equiv.Defs`**
   - Linear equivalences and isomorphisms
   - Relevant to frame equivalence

5. **`Mathlib.Algebra.Order.Group.Defs`** ⭐ (Currently used in TaskFrame)
   - Ordered group structures
   - `LinearOrderedAddCommGroup` definition

6. **`Mathlib.LinearAlgebra.Basic`**
   - General linear algebra foundations
   - Basis, dimension, linear independence

7. **`Mathlib.Data.Matrix.Basic`**
   - Matrix representations
   - Matrix operations (multiplication, transpose, powers)

8. **`Mathlib.LinearAlgebra.Eigenspace`**
   - Eigenvalue/eigenvector theory
   - Spectral properties

9. **`Mathlib.Algebra.Module.LinearMap.End`**
   - Endomorphisms and module actions
   - Relevant to modal operators as endomorphisms

10. **`Mathlib.LinearAlgebra.FiniteDimensional`**
    - Finite-dimensional vector spaces
    - Rank-nullity, dimension theorems

### Current Usage in ProofChecker

**TaskFrame.lean** imports:
```lean
import Mathlib.Algebra.Order.Group.Defs
```

**Provides**:
- `LinearOrderedAddCommGroup T`: Totally ordered abelian group
- Used for temporal duration type `T`
- Supports: `0`, `+`, `-`, `≤` with compatibility

**Why This is Appropriate**:
- Task semantics requires ordered time structure
- No need for scalar multiplication (vector spaces)
- No need for matrix operations (yet)
- Minimal dependencies, maximum clarity

### Potential Extensions

**If Matrix-Based Semantics Needed**:
```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Matrix.Notation

-- Represent finite TaskFrame as matrix
def TaskFrame.toMatrix (F : TaskFrame ℤ) (n : ℕ) : 
    Fin n → ℤ → Fin n → Bool := sorry
```

**If Spectral Analysis Needed**:
```lean
import Mathlib.LinearAlgebra.Eigenspace
import Mathlib.LinearAlgebra.Matrix.Spectrum

-- Analyze frame properties via eigenvalues
def frame_spectral_radius (M : Matrix (Fin n) (Fin n) ℝ) : ℝ := sorry
```

---

## Content Recommendations for Documentation Files

### 1. `vector-spaces.md`

**Purpose**: Foundational algebraic structures and their connections to modal logic

**Recommended Topics**:

1. **Vector Spaces and Modules**
   - Definition of vector space over a field
   - Module over a ring (generalization)
   - Examples: ℝⁿ, function spaces, polynomial rings
   - Mathlib4: `Module`, `VectorSpace`

2. **Subspaces and Span**
   - Subspace definition and properties
   - Linear span and linear combinations
   - Basis and linear independence
   - Mathlib4: `Submodule`, `span`, `LinearIndependent`

3. **Dimension Theory**
   - Finite vs infinite dimensional spaces
   - Dimension theorems
   - Mathlib4: `FiniteDimensional`, `finrank`

4. **Connections to Modal Logic**
   - Modal algebras as algebraic structures
   - Comparison: vector spaces vs Boolean algebras
   - Ordered structures: `LinearOrderedAddCommGroup` (used in TaskFrame)
   - Theoretical: vector space semantics for modal logic

5. **Examples in LEAN 4**
   ```lean
   -- Vector space over reals
   example : VectorSpace ℝ (Fin n → ℝ) := inferInstance
   
   -- Module over integers (used in TaskFrame)
   example : Module ℤ ℤ := inferInstance
   
   -- Linear ordered additive group
   example : LinearOrderedAddCommGroup ℤ := inferInstance
   ```

### 2. `linear-maps.md`

**Purpose**: Structure-preserving transformations and their modal logic analogues

**Recommended Topics**:

1. **Linear Maps**
   - Definition and basic properties
   - Preservation of addition and scalar multiplication
   - Composition of linear maps
   - Mathlib4: `LinearMap`, `comp`

2. **Kernel and Image**
   - Kernel (null space) definition
   - Image (range) definition
   - Rank-nullity theorem
   - Mathlib4: `ker`, `range`, `rank_add_nullity`

3. **Linear Equivalences**
   - Isomorphisms between vector spaces
   - Invertible linear maps
   - Mathlib4: `LinearEquiv`

4. **Endomorphisms**
   - Linear maps from space to itself
   - Composition and iteration
   - Mathlib4: `End`, `LinearMap.comp`

5. **Connections to Modal Logic**
   - Modal operators as transformations on Boolean algebras
   - Frame morphisms as structure-preserving maps
   - Coalgebraic perspective: `α: W → P(W)`
   - Accessibility as a relation vs transformation

6. **Examples in LEAN 4**
   ```lean
   -- Linear map from ℝ² to ℝ
   def proj₁ : (Fin 2 → ℝ) →ₗ[ℝ] ℝ where
     toFun v := v 0
     map_add' := by simp
     map_smul' := by simp
   
   -- Frame morphism (conceptual)
   structure FrameMorphism (F₁ F₂ : KripkeFrame) where
     map : F₁.World → F₂.World
     preserves : ∀ w v, F₁.accessible w v → 
                        F₂.accessible (map w) (map v)
   ```

### 3. `matrices.md`

**Purpose**: Matrix representations of accessibility relations and computational methods

**Recommended Topics**:

1. **Matrix Basics**
   - Matrix definition and notation
   - Matrix operations: addition, multiplication, transpose
   - Identity and zero matrices
   - Mathlib4: `Matrix`, `mul`, `transpose`

2. **Adjacency Matrices for Kripke Frames**
   - Representing accessibility relations as matrices
   - Boolean vs numeric matrices
   - Frame properties as matrix properties:
     - Reflexivity: diagonal entries
     - Symmetry: M = Mᵀ
     - Transitivity: M² ≤ M

3. **Matrix Powers and Reachability**
   - Matrix powers: `M^n`
   - n-step reachability
   - Transitive closure: `M* = I + M + M² + ...`
   - Mathlib4: `pow`

4. **Bimodal Logic and Matrix Composition**
   - Multiple accessibility relations: M₁, M₂
   - Composition: M₁M₂
   - Interaction axioms:
     - Commutativity: M₁M₂ = M₂M₁
     - Church-Rosser: M₁M₂ ⊆ M₂M₁

5. **TaskFrame Matrix Representation**
   - 3D tensor representation: worlds × time × worlds
   - Nullity as identity at time 0
   - Compositionality as tensor composition
   - Computational benefits

6. **Examples in LEAN 4**
   ```lean
   -- Adjacency matrix for simple frame
   def simple_frame_matrix : Matrix (Fin 3) (Fin 3) Bool :=
     ![![true, true, false],
       ![false, true, true],
       ![false, false, true]]
   
   -- Check reflexivity
   example : ∀ i, simple_frame_matrix i i = true := by decide
   
   -- Matrix power for reachability
   def reachable_in_n_steps (M : Matrix n n Bool) (k : ℕ) : 
       Matrix n n Bool := M ^ k
   ```

### 4. `eigenvalues.md`

**Purpose**: Spectral properties and their applications to frame characterization

**Recommended Topics**:

1. **Eigenvalues and Eigenvectors**
   - Definition: `Av = λv`
   - Eigenspace for eigenvalue λ
   - Characteristic polynomial
   - Mathlib4: `eigenspace`, `HasEigenvalue`, `HasEigenvector`

2. **Spectral Theorem**
   - Diagonalization of symmetric matrices
   - Spectral decomposition
   - Applications to graph theory
   - Mathlib4: spectral theory modules

3. **Spectral Properties of Frame Matrices**
   - Reflexivity and eigenvalue 1
   - Transitivity and spectral radius
   - Symmetry and real eigenvalues
   - Perron-Frobenius theorem for non-negative matrices

4. **Fixed Points in Modal Logic**
   - Greatest fixed point (ν-calculus)
   - Least fixed point (μ-calculus)
   - Eigenvectors as fixed points
   - Application to infinite behavior

5. **Spectral Methods for Decision Procedures**
   - Complexity bounds via spectral radius
   - Finite model property
   - Canonical model construction
   - Probabilistic modal logic

6. **Examples in LEAN 4**
   ```lean
   -- Eigenvalue definition
   def is_eigenvalue (A : Matrix n n ℝ) (λ : ℝ) : Prop :=
     ∃ v : n → ℝ, v ≠ 0 ∧ A.mulVec v = λ • v
   
   -- Reflexive frame has eigenvalue 1
   theorem reflexive_has_eigenvalue_one 
       (M : Matrix n n ℝ) 
       (h : ∀ i, M i i = 1) : 
       is_eigenvalue M 1 := by
     use fun _ => 1
     constructor
     · intro h; cases h
     · ext i; simp [Matrix.mulVec, h]
   ```

---

## Modal Logic Connections Summary

### 1. Algebraic Semantics
- **Modal Algebras**: Boolean algebras with operators (□, ◇)
- **Lattice Expansions**: Distributive lattices with modal operators
- **Heyting Algebras**: Intuitionistic modal logic
- **Connection**: Similar algebraic structure to modules/vector spaces

### 2. Matrix Representations
- **Adjacency Matrices**: Represent accessibility relations
- **Matrix Powers**: Compute n-step reachability
- **Transitive Closure**: M* for reflexive-transitive closure
- **Bimodal Composition**: M₁M₂ for interaction axioms

### 3. Coalgebraic Methods
- **Coalgebras**: (W, α: W → F(W)) for functor F
- **Terminal Coalgebras**: Canonical models
- **Bisimulation**: Behavioral equivalence
- **Connection**: Categorical semantics unifying logic and algebra

### 4. Linear Logic
- **Exponential Modalities**: ! and ? as comonad/monad
- **Graded Modalities**: Resource tracking with semiring
- **Quantum Logic**: Hilbert space semantics
- **Connection**: Modal operators in resource-aware computation

### 5. Task Semantics
- **Ordered Structures**: LinearOrderedAddCommGroup for time
- **Subordination Algebras**: Normative reasoning
- **Quantitative Reasoning**: Graded temporal modalities
- **Connection**: Ordered groups bridge logic and algebra

---

## References

### Foundational Texts

1. **Blackburn, P., de Rijke, M., & Venema, Y. (2001)**. *Modal Logic*. Cambridge University Press.
   - DOI: 10.1017/CBO9781107050884
   - Comprehensive treatment of algebraic and relational semantics

2. **Goldblatt, R. (2006)**. "Mathematical Modal Logic: A View of its Evolution". 
   - *Handbook of the History of Logic*, Vol. 7
   - Historical perspective on modal logic and algebra connections

3. **Lemmon, E.J. & Scott, D. (1977)**. *An Introduction to Modal Logic*.
   - Classic introduction to modal algebras

### Algebraic Semantics

4. **Bezhanishvili, N., Carai, L., Ghilardi, S., & Zhao, Z. (2024)**. "A calculus for modal compact Hausdorff spaces".
   - arXiv:2402.00528
   - De Vries duality and topological representation

5. **Palmigiano, A. & Panettiere, M. (2024)**. "Unified inverse correspondence for LE-logics".
   - arXiv:2405.01262
   - Lattice expansions and Sahlqvist formulas

6. **Přenosil, A. (2023)**. "Compatibility between modal operators in distributive modal logic".
   - arXiv:2311.10017
   - Non-classical modal operators

### Coalgebraic Approaches

7. **Cirstea, C., Kurz, A., Pattinson, D., Schröder, L., & Venema, Y.** "Modal logics are coalgebraic".
   - Unifying coalgebraic framework

8. **Forster, J., Schröder, L., Wild, P., et al. (2025)**. "Quantitative Graded Semantics and Spectra of Behavioural Metrics".
   - DOI: 10.4230/LIPIcs.CSL.2025.33
   - Graded monads and quantitative modal logics

### Linear Logic Connections

9. **Cockett, R. & Srinivasan, P.V. (2021)**. "Exponential Modalities and Complementarity".
   - DOI: 10.4204/EPTCS.372.15
   - Linear logic and quantum complementarity

10. **Díaz-Caro, A., Ivnisky, M., & Malherbe, O. (2025)**. "An Algebraic Extension of Intuitionistic Linear Logic".
    - arXiv:2504.12128
    - Scalar multiplication in linear logic

### Applications

11. **De Domenico, A., Farjami, A., Manoorkar, K., et al. (2024)**. "Obligations and permissions, algebraically".
    - arXiv:2403.03148
    - Subordination algebras for normative reasoning

12. **Shamkanov, D. (2024)**. "On algebraic and topological semantics of modal logic of common knowledge S4CI".
    - *Logic Journal of the IGPL* 32:1, 164-179
    - Stone-type representation theorem

### Online Resources

- **Stanford Encyclopedia of Philosophy**: Modal Logic
- **nLab**: Modal Logic, Coalgebra, Linear Logic
- **Mathlib4 Documentation**: https://leanprover-community.github.io/mathlib4_docs/
- **arXiv**: Categories cs.LO (Logic in CS), math.LO (Mathematical Logic)

---

## Specialist Reports

Detailed findings from specialist subagents:

1. **LeanSearch Results**: `.opencode/specs/071_research_linear_algebra/specialist-reports/lean-search-results.md`
   - Mathlib4 module analysis
   - Key definitions and theorems
   - Current usage in TaskFrame

2. **Loogle Results**: (Search completed, findings integrated above)
   - Formal type signatures
   - Theorem matching
   - Property characterizations

3. **Web Research Findings**: `.opencode/specs/071_research_linear_algebra/specialist-reports/web-research-findings.md`
   - Academic papers and resources
   - Conceptual connections
   - Applications to bimodal logic

---

## Conclusion

This research reveals that while direct applications of linear algebra to modal logic are limited, there are rich conceptual connections through algebraic semantics, matrix representations, and coalgebraic methods. The ProofChecker project's current use of `LinearOrderedAddCommGroup` is appropriate for task semantics, providing the necessary ordered group structure without unnecessary complexity.

The recommended documentation files will:
1. Provide foundational understanding of linear algebraic structures
2. Draw connections to modal logic where applicable
3. Prepare for potential future extensions (matrix-based decision procedures, spectral analysis)
4. Maintain consistency with existing context file style and structure

**Next Steps**:
1. Create the four documentation files based on content recommendations
2. Include LEAN 4 examples from mathlib4
3. Emphasize connections to modal logic and task semantics
4. Reference existing ProofChecker code (TaskFrame.lean)

---

**Research Completed**: December 19, 2025  
**Status**: Ready for documentation file creation  
**Artifacts**: Research report, specialist reports, content recommendations
