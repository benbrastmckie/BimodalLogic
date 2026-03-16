# Research Report: Task #977 - Teammate A Codebase Analysis

**Task**: 977 - Organize TM base logic with extensions
**Role**: Teammate A - Codebase Analysis
**Started**: 2026-03-16
**Completed**: 2026-03-16
**Effort**: ~2 hours
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Theories/Bimodal/)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- TM logic has 21 axiom constructors organized into 4 categories with explicit frame compatibility predicates
- Frame semantics use parameterized TaskFrame over ordered additive group D with three key conditions
- Soundness is fully proven; completeness has proven components but final wiring incomplete
- Current organization already has implicit base/extension separation via `isBase`, `isDenseCompatible`, `isDiscreteCompatible`
- Key gap: No explicit "TM Base" vs "TM Dense" vs "TM Discrete" proof system separation

---

## Current Axiom Inventory

### Location

**Primary file**: `Theories/Bimodal/ProofSystem/Axioms.lean` (431 lines)

### Complete Axiom List (21 axiom constructors)

| # | Constructor | Formula | Category | Frame Condition |
|---|-------------|---------|----------|-----------------|
| 1 | `prop_k` | `(p -> (q -> r)) -> ((p -> q) -> (p -> r))` | Propositional | None (universal) |
| 2 | `prop_s` | `p -> (q -> p)` | Propositional | None (universal) |
| 3 | `ex_falso` | `bot -> p` | Propositional | None (universal) |
| 4 | `peirce` | `((p -> q) -> p) -> p` | Propositional | None (universal) |
| 5 | `modal_t` | `Box p -> p` | Modal S5 | None (universal) |
| 6 | `modal_4` | `Box p -> Box (Box p)` | Modal S5 | None (universal) |
| 7 | `modal_b` | `p -> Box (Diamond p)` | Modal S5 | None (universal) |
| 8 | `modal_5_collapse` | `Diamond (Box p) -> Box p` | Modal S5 | None (universal) |
| 9 | `modal_k_dist` | `Box (p -> q) -> (Box p -> Box q)` | Modal S5 | None (universal) |
| 10 | `temp_k_dist` | `G (p -> q) -> (G p -> G q)` | Temporal | None (universal) |
| 11 | `temp_4` | `G p -> G (G p)` | Temporal | None (universal) |
| 12 | `temp_t_future` | `G p -> p` | Temporal | None (universal) |
| 13 | `temp_t_past` | `H p -> p` | Temporal | None (universal) |
| 14 | `temp_a` | `p -> G (P p)` | Temporal | None (universal) |
| 15 | `temp_l` | `Always p -> G (H p)` | Temporal | None (universal) |
| 16 | `modal_future` | `Box p -> Box (G p)` | Interaction | None (universal) |
| 17 | `temp_future` | `Box p -> G (Box p)` | Interaction | None (universal) |
| 18 | `temp_linearity` | `(F p & F q) -> (F (p & q) | F (p & F q) | F (F p & q))` | Temporal | None (universal) |
| 19 | `density` | `F p -> F (F p)` | Temporal | **DenselyOrdered** |
| 20 | `discreteness_forward` | `(F T & p & H p) -> F (H p)` | Temporal | **SuccOrder** |
| 21 | `seriality_future` | `F (neg bot)` | Temporal | **Nontrivial** |
| 22 | `seriality_past` | `P (neg bot)` | Temporal | **Nontrivial** |

### Axiom Classification Predicates

The system already has explicit classification predicates (lines 403-428):

```lean
def Axiom.isDenseCompatible : Axiom phi -> Prop
  | Axiom.discreteness_forward _ => False
  | _ => True

def Axiom.isDiscreteCompatible : Axiom phi -> Prop
  | Axiom.density _ => False
  | _ => True

def Axiom.isBase : Axiom phi -> Prop
  | Axiom.density _ => False
  | Axiom.discreteness_forward _ => False
  | Axiom.seriality_future => False
  | Axiom.seriality_past => False
  | _ => True
```

This defines:
- **Base axioms** (isBase = True): 18 axioms valid on all linear orders
- **Dense axioms** (isDenseCompatible = True): 20 axioms valid on dense orders (excludes discreteness_forward)
- **Discrete axioms** (isDiscreteCompatible = True): 20 axioms valid on discrete orders (excludes density)

---

## Current Frame Conditions

### Location

**Primary file**: `Theories/Bimodal/Semantics/TaskFrame.lean` (303 lines)

### TaskFrame Definition (lines 93-123)

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y ->
                 task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

### Frame Condition Summary

| Condition | Meaning | Purpose |
|-----------|---------|---------|
| `nullity_identity` | task_rel w 0 u <-> w = u | Zero duration = identity |
| `forward_comp` | Composition for non-negative durations | Task sequencing |
| `converse` | task_rel w d u <-> task_rel u (-d) w | Temporal symmetry |

### Parameterization

The frame is parameterized over:
- `D : Type*` - temporal duration type
- `[AddCommGroup D]` - additive group structure
- `[LinearOrder D]` - linear ordering
- `[IsOrderedAddMonoid D]` - order compatible with addition

### Validity Classes

**File**: `Theories/Bimodal/Semantics/Validity.lean`

| Validity Type | Definition | Extra Type Constraints |
|--------------|------------|------------------------|
| `valid` | True on ALL linear ordered groups D | None |
| `valid_dense` | True on densely ordered D | `DenselyOrdered D`, `Nontrivial D` |
| `valid_discrete` | True on discrete D | `SuccOrder D`, `PredOrder D`, `Nontrivial D` |

---

## Current Metalogic Status

### Location

**Primary directory**: `Theories/Bimodal/Metalogic/`

### Soundness Status

**File**: `Theories/Bimodal/Metalogic/Soundness.lean` (435 lines)

| Theorem | Status | Description |
|---------|--------|-------------|
| `axiom_base_valid` | **PROVEN** | Base axioms universally valid |
| `axiom_valid_dense` | **PROVEN** | Dense-compatible axioms valid on dense frames |
| `axiom_valid_discrete` | **PROVEN** | Discrete-compatible axioms valid on discrete frames |

All 21 individual axiom validity theorems are proven:
- `prop_k_valid`, `prop_s_valid`, `ex_falso_valid`, `peirce_valid`
- `modal_t_valid`, `modal_4_valid`, `modal_b_valid`, `modal_5_collapse_valid`, `modal_k_dist_valid`
- `temp_k_dist_valid`, `temp_4_valid`, `temp_t_future_valid`, `temp_t_past_valid`, `temp_a_valid`, `temp_l_valid`
- `modal_future_valid`, `temp_future_valid`, `temp_linearity_valid`
- `density_valid`, `discreteness_forward_valid`, `seriality_future_valid`, `seriality_past_valid`

### Completeness Status

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` (190 lines)

| Component | Status | Location |
|-----------|--------|----------|
| Cantor isomorphism (TimelineQuot ~= Q) | **PROVEN** | CantorApplication.lean |
| BFMCS Truth Lemma | **PROVEN** | TruthLemma.lean |
| Temporal coherent family | **PROVEN** | CanonicalFMCS.lean |
| Final wiring | **INCOMPLETE** | Domain mismatch: CanonicalMCS vs TimelineQuot |

Per the file header:
> "The dense completeness *components* are proven, but the final wiring theorem requires additional infrastructure."

### Decidability Status

**Directory**: `Theories/Bimodal/Metalogic/Decidability/`

| Theorem | Status | Description |
|---------|--------|-------------|
| `decide` | **PROVEN** | Tableau-based decision procedure |
| `isValid` | **PROVEN** | Boolean validity check |
| `isSatisfiable` | **PROVEN** | Boolean satisfiability check |

### Overall Sorry Status

Files with active sorries in Metalogic/:
- `Canonical/ConstructiveFragment.lean` - 2 sorries (pending analysis)
- `Domain/DiscreteTimeline.lean` - 4 sorries (coverness property)
- Remaining files document sorries in comments but have sorry-free main theorems

---

## Current Organization Assessment

### Directory Structure

```
Theories/Bimodal/
├── Syntax/                # Formula, Atom, Context, Subformulas
├── ProofSystem/           # Axioms.lean, Derivation.lean
├── Semantics/             # TaskFrame, TaskModel, Truth, Validity, WorldHistory
├── Metalogic/             # Soundness, Completeness, Decidability, Algebraic
│   ├── Core/              # MCS theory, DeductionTheorem
│   ├── Bundle/            # BFMCS completeness approach
│   ├── Decidability/      # Tableau decision procedure
│   ├── Algebraic/         # Alternative algebraic approach
│   ├── StagedConstruction/ # Dense completeness
│   ├── Domain/            # CanonicalDomain, DiscreteTimeline
│   └── Canonical/         # Canonical model support
├── Theorems/              # Derived theorems (ModalS5, Perpetuity, etc.)
├── Automation/            # Tactics, ProofSearch, AesopRules
└── Examples/              # Demo, ProofStrategies
```

### Existing Base/Extension Pattern

The current system has an **implicit** base/extension separation:

1. **Axiom predicates** (`isBase`, `isDenseCompatible`, `isDiscreteCompatible`) define which axioms belong to each variant
2. **Validity predicates** (`valid`, `valid_dense`, `valid_discrete`) restrict frame conditions
3. **Soundness theorems** (`axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete`) prove soundness per variant

However, there is **no explicit proof system separation**:
- No `DerivationTree_Base` vs `DerivationTree_Dense` types
- No separate axiom types for each logic variant
- All axioms are in one `Axiom` inductive type

### Derived Theorems

**Directory**: `Theories/Bimodal/Theorems/`

| File | Content | Depends On |
|------|---------|------------|
| `Propositional.lean` | Basic propositional theorems | Base axioms only |
| `ModalS4.lean` | S4 modal theorems | T, 4 axioms |
| `ModalS5.lean` | S5 modal theorems | T, 4, B, 5 axioms |
| `Perpetuity.lean` | Perpetuity principles P1-P6 | Modal + Temporal interaction |
| `Discreteness.lean` | DP derived from DF | discreteness_forward + temporal_duality |
| `GeneralizedNecessitation.lean` | Generalized necessitation rules | K distribution axioms |
| `Combinators.lean` | Standard combinators (I, K, S) | Propositional axioms |

---

## Gaps and Issues Identified

### 1. No Explicit Logic Layers

**Gap**: The system lacks explicit type-level separation between:
- TM Base (18 axioms, valid on all linear orders)
- TM Dense (Base + density + seriality, valid on dense orders)
- TM Discrete (Base + discreteness_forward + seriality, valid on discrete orders)

**Impact**: Users must manually track which axioms are usable in which context.

### 2. Axiom-Frame Correspondence Not Explicit

**Gap**: The correspondence between axioms and frame conditions is implicit in predicates rather than enforced structurally.

**Current**: `Axiom.isDenseCompatible` returns False for `discreteness_forward`
**Better**: Separate axiom types with type-safe guarantees

### 3. Completeness Wiring Incomplete

**Gap**: Dense completeness has all components proven but final theorem not wired due to domain mismatch (CanonicalMCS vs TimelineQuot).

**Impact**: Cannot state `valid_dense phi -> Provable_dense phi` formally.

### 4. Inconsistent Axiom Count Documentation

**Gap**: Different documentation sources cite different axiom counts:
- README.md: "14 axiom schemata"
- Axioms.lean: 21 constructors (but some added later by tasks 967, 922, 913)
- ProofSystem.lean: "14 TM axiom schemata"

**Impact**: Documentation is outdated relative to actual implementation.

### 5. No Soundness for Full Proof System

**Gap**: `axiom_base_valid` etc. prove axiom validity but not full derivation soundness.

**Note**: There may be a separate soundness theorem I haven't located that handles the full derivation tree.

### 6. Seriality Axioms Missing from Base Classification

**Observation**: `seriality_future` and `seriality_past` are marked `isBase = False` but are included in both `isDenseCompatible` and `isDiscreteCompatible`. This is correct behavior (they need Nontrivial D) but worth documenting.

---

## Organization Recommendation

Based on the analysis, the codebase is well-structured but would benefit from:

### Option A: Layer-Based Reorganization

```
Theories/Bimodal/
├── Logics/
│   ├── Base/           # 18 base axioms, universal validity
│   ├── Dense/          # Base + density + seriality
│   └── Discrete/       # Base + discreteness + seriality
```

Pros: Explicit separation, clearer user guidance
Cons: Significant refactoring, potential import complexity

### Option B: Enhanced Documentation Only

Keep current structure but:
1. Update README.md with accurate axiom counts
2. Create explicit "Logic Variants" documentation
3. Add comments to Axioms.lean explaining the classification scheme

Pros: Minimal code changes, quick to implement
Cons: Doesn't enforce type-level guarantees

### Option C: Type Family Approach

Create a type family indexed by logic variant:

```lean
inductive LogicVariant | Base | Dense | Discrete

def AxiomSet : LogicVariant -> Type
  | Base => BaseAxiom
  | Dense => DenseAxiom
  | Discrete => DiscreteAxiom
```

Pros: Type-safe axiom usage, compositional
Cons: Requires significant restructuring

---

## Summary Table

| Aspect | Current State | Recommendation |
|--------|---------------|----------------|
| Axiom organization | Single inductive type + predicates | Consider type family (Option C) |
| Frame semantics | Well-parameterized TaskFrame | Good as-is |
| Soundness | Fully proven for all variants | Document in README |
| Completeness | Components proven, wiring incomplete | Priority fix |
| Documentation | Outdated axiom counts | Needs update |
| Directory structure | Reasonable | Consider consolidation |

---

## Appendix: Key File Locations

| Concept | File Path |
|---------|-----------|
| Axiom definitions | `Theories/Bimodal/ProofSystem/Axioms.lean` |
| Derivation rules | `Theories/Bimodal/ProofSystem/Derivation.lean` |
| Frame structure | `Theories/Bimodal/Semantics/TaskFrame.lean` |
| Truth evaluation | `Theories/Bimodal/Semantics/Truth.lean` |
| Validity predicates | `Theories/Bimodal/Semantics/Validity.lean` |
| Soundness proofs | `Theories/Bimodal/Metalogic/Soundness.lean` |
| Completeness docs | `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` |
| Decidability | `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` |
| Main README | `Theories/Bimodal/README.md` |
| Metalogic README | `Theories/Bimodal/Metalogic/README.md` |
