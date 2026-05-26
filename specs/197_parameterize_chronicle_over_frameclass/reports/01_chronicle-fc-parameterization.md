# Research Report: Parameterize Chronicle Construction over FrameClass

**Task**: 197 -- Parameterize chronicle construction over FrameClass
**Date**: 2026-05-26
**Status**: Complete

## 1. Executive Summary

Task 168 parameterized `DerivationTree` over `FrameClass`, introducing a gate `h_fc : ax.minFrameClass <= fc` on every axiom usage. The chronicle construction pipeline (6 files, ~14,270 lines in `BXCanonical/Chronicle/`) was left hardcoded at `fc := FrameClass.Base`. This creates an impossible proof obligation when the discrete completeness pipeline needs to use axioms `z1`, `prior_UZ`, and `prior_SZ` (whose `minFrameClass = .Discrete`) inside a `FrameClass.Base` context, producing 6 sorry workarounds. The fix is to thread an `fc` parameter through the chronicle pipeline, allowing instantiation with `.Discrete` for the discrete case.

## 2. FrameClass Hierarchy and Constraints

### Definition (ProofSystem/Axioms.lean:410)

```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
```

### Partial Order (Axioms.lean:416-430)

```
    Base
   /    \
Dense  Discrete
```

- `Base <= Dense` (True)
- `Base <= Discrete` (True)
- `Base <= Base` (True)
- `Dense <= Dense` (True)
- `Discrete <= Discrete` (True)
- `Dense <= Discrete` = False (incomparable)
- `Discrete <= Dense` = False (incomparable)
- `Dense <= Base` = False
- `Discrete <= Base` = False

### Axiom.minFrameClass (Axioms.lean:444)

```lean
def Axiom.minFrameClass : Axiom phi -> FrameClass
  | density _ => .Dense
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | _ => .Base
```

### Gate Constraint

The `DerivationTree` axiom constructor requires `h_fc : ax.minFrameClass <= fc`. For base axioms, `Base <= fc` is `True` for any `fc`, so `trivial` works. For discrete axioms, the obligation `Discrete <= fc` is only satisfiable when `fc = .Discrete`.

## 3. The 6 Sorry Locations -- Exact Proof Obligations

All 6 sorries have identical structure:

```lean
DerivationTree.axiom [] _ (Axiom.{z1|prior_UZ|prior_SZ} param) sorry
```

where `sorry : ({z1|prior_UZ|prior_SZ} param).minFrameClass <= FrameClass.Base`, i.e., `sorry : FrameClass.Discrete <= FrameClass.Base`, which is `False`.

### Sorry 1: FrameProperties.lean:25

```lean
theorem z1_in_frame (x : ReflCanDomain) (psi : Formula) :
    {z1_formula_body} in x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.z1 psi) sorry)
```

**Obligation**: `(Axiom.z1 psi).minFrameClass <= FrameClass.Base` = `Discrete <= Base` = `False`

**Context**: `ReflCanDomain` is defined as `{ S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S }`. The `theorem_in_mcs` function is already generic over `fc`, but `x.property` provides `SetMaximalConsistent (fc := .Base)`, so the derivation must be at `.Base`.

### Sorry 2: FrameProperties.lean:34

```lean
theorem prior_UZ_in_frame (x : ReflCanDomain) (psi : Formula) :
    Formula.imp (Formula.some_future psi) (Formula.untl psi psi.neg) in x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_UZ psi) sorry)
```

**Obligation**: Same -- `Discrete <= Base` = `False`

### Sorry 3: FrameProperties.lean:41

```lean
theorem prior_SZ_in_frame (x : ReflCanDomain) (psi : Formula) :
    Formula.imp (Formula.some_past psi) (Formula.snce psi psi.neg) in x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_SZ psi) sorry)
```

**Obligation**: Same -- `Discrete <= Base` = `False`

### Sorry 4: ChronicleExtraction.lean:62

```lean
theorem prior_UZ_in_limit_domain (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (x : Rat) (hx : x in limit_dom A h_mcs) (psi : Formula) :
    ... in limit_f A h_mcs x :=
  theorem_in_mcs (limit_c0 A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_UZ psi) sorry)
```

**Obligation**: Same -- `Discrete <= Base` = `False`

### Sorry 5: ChronicleExtraction.lean:73

```lean
theorem prior_SZ_in_limit_domain (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    ... :=
  theorem_in_mcs (limit_c0 A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_SZ psi) sorry)
```

**Obligation**: Same -- `Discrete <= Base` = `False`

### Sorry 6: ChronicleToCountermodel.lean:1529

```lean
private def z1_derivation (phi : Formula) :
    DerivationTree FrameClass.Base [] (z1_formula phi) :=
  DerivationTree.axiom [] _ (Axiom.z1 phi) sorry
```

**Obligation**: Same -- `Discrete <= Base` = `False`

### Resolution Pattern

Once the chronicle pipeline is parameterized over `fc`, all 6 sorries become:

```lean
DerivationTree.axiom [] _ (Axiom.{z1|prior_UZ|prior_SZ} param) trivial
```

because when `fc = .Discrete`, the obligation is `Discrete <= Discrete` = `True`.

## 4. Current ChronicleConstruction.lean Structure

### File Summary

- **Lines**: 1,510
- **Hardcoded `FrameClass.Base` references**: 71 (explicit) + 19 via `SetMaximalConsistent` implicit param
- **Hardcoded `SetMaximalConsistent` references**: 73

### Key Definitions and Their FrameClass Dependencies

| Definition | Line | fc-Dependent? | Notes |
|---|---|---|---|
| `singleton_chronicle` | 64 | No (data only) | Pure data, no derivation |
| `singleton_c0` | 72 | Yes | Takes `h_mcs : SetMaximalConsistent (fc := .Base)` |
| `singleton_invariant` | 96 | Yes | Same |
| `omega_chain_val` | ~350 | Yes | Iterates chronicle with `h_mcs` |
| `limit_dom` | 551 | Yes | Takes `h_mcs : SetMaximalConsistent (fc := .Base)` |
| `limit_f` | 560 | Yes | Same |
| `limit_c0` | 590 | Yes | Proves MCS at `.Base` |
| `limit_f_zero` | ~600 | Yes | Same |
| `limit_satisfies_c5_strong` | ~700+ | Yes | Same |

### How fc is Used

The `fc` parameter flows through the construction in two ways:

1. **SetMaximalConsistent constraints**: Every function that takes `h_mcs` carries `fc` implicitly. The Chronicle's `c0` condition states `SetMaximalConsistent (fc := FrameClass.Base) (chi.f x)`.

2. **DerivationTree construction**: Lemmas like `cud_contains_theorems`, `dcs_contains_theorems`, and `theorem_in_mcs` build `DerivationTree FrameClass.Base L phi` terms. These only use base axioms (prop_k, prop_s, ex_falso, peirce, modal_k_dist, etc.), which have `minFrameClass = .Base`, so the `trivial` proofs work for any `fc >= .Base`.

### Critical Observation

**Almost all derivation trees in the chronicle use only base axioms.** The chronicle construction builds its proofs from propositional logic, modal K-distribution, temporal K-distribution, connect_future, until_F, since_P, etc. -- all base axioms. The ONLY places where discrete axioms appear are the 6 sorry locations listed above. This means parameterization is structurally straightforward: replace `FrameClass.Base` with a variable `fc`, and the existing `trivial` proofs for base axiom gates remain valid for any `fc`.

## 5. ChronicleTypes.lean -- The Foundation

### Hardcoded fc References: 17

Key types that hardcode `FrameClass.Base`:

| Type/Definition | Line | Impact |
|---|---|---|
| `ClosedUnderDerivation` | 69-71 | `DerivationTree FrameClass.Base L phi` |
| `SetDeductivelyClosed` | 82-83 | `SetConsistent (fc := .Base) S` |
| `mcs_is_dcs` | 86 | `SetMaximalConsistent (fc := .Base)` |
| `Chronicle.c0` | 385-386 | `SetMaximalConsistent (fc := .Base) (chi.f x)` |
| Various consistency lemmas | 642-685 | `SetConsistent (fc := .Base)` |

### Parameterization Strategy for ChronicleTypes

The `Chronicle` structure itself is purely data (no fc dependency). The conditions (`c0`, `c1`, etc.) reference `SetMaximalConsistent` and `ClosedUnderDerivation` which currently hardcode `.Base`. These must be parameterized.

**Option A (recommended)**: Add `variable (fc : FrameClass)` and make `ClosedUnderDerivation`, `SetDeductivelyClosed`, `Chronicle.c0`, etc. take `fc` as a parameter. The `Chronicle` data structure stays unchanged.

**Option B**: Parameterize the `Chronicle` structure itself with `fc`. This is unnecessary since `Chronicle` is pure data -- only the conditions/predicates need `fc`.

## 6. Downstream Consumer Analysis

### File: ChronicleToCountermodel.lean (3,378 lines, 167 fc-refs)

**Purpose**: Converts the limit chronicle to semantic countermodels.

**Key types affected**:
- `LimitDomSubtype` (line 76): takes `h_mcs : SetMaximalConsistent (fc := .Base)`
- `limitDomSubtype_succOrder` etc.: all take `.Base` MCS
- `z1_derivation` (line 1527): the fc-mismatch sorry
- `z1_in_mcs` (line 1533): depends on z1_derivation
- `cantor_bfmcs_discrete` and `rooted_succ_discrete_fmcs`: use `.Base` MCS throughout
- `dd_countermodel_chronicle_discrete` (line 3289): the final discrete countermodel theorem

**Impact**: ~167 `FrameClass.Base` / `SetMaximalConsistent` references to update. Most are mechanical (change `FrameClass.Base` to `fc`).

### File: FrameProperties.lean (55 lines, 0 explicit fc-refs but 3 sorries)

**Purpose**: Proves z1, prior_UZ, prior_SZ are in every MCS of the canonical model.

**Impact**: Must parameterize `ReflCanDomain` usage. Currently:
```lean
theorem z1_in_frame (x : ReflCanDomain) ...
```
where `ReflCanDomain = { S // SetMaximalConsistent (fc := .Base) S }`.

**Fix**: Either parameterize `ReflCanDomain` itself over `fc`, or create the discrete theorems alongside the existing base ones. Since `FrameProperties.lean` is only 55 lines, the cleanest approach is to parameterize `ReflCanDomain` over `fc`.

### File: ChronicleExtraction.lean (259 lines, 6 explicit fc-refs)

**Purpose**: Extracts the chronicle as a `ChronicleAsPriorModel` for the Reynolds pipeline.

**Impact**:
- `DiscreteHypothesis` (line 44): takes `h_mcs : SetMaximalConsistent (fc := .Base)`
- `prior_UZ_in_limit_domain` (line 53): fc-mismatch sorry
- `prior_SZ_in_limit_domain` (line 67): fc-mismatch sorry
- `ChronicleAsPriorModel.root_mcs` (line 94): `SetMaximalConsistent (fc := .Base)`
- `ChronicleAsPriorModel.fmcs_is_mcs` (line 118): `SetMaximalConsistent (fc := .Base)`
- `extract_chronicle_as_prior` (line 173): takes `.Base` MCS

### File: ReflexiveCanonical.lean (760 lines, 24 fc-refs)

**Purpose**: Defines the reflexive canonical model used by FrameProperties and the truth lemma.

**Key type**: `ReflCanDomain = { S : Set Formula // SetMaximalConsistent (fc := .Base) S }`

**Impact**: Parameterizing `ReflCanDomain` over `fc` cascades to all 760 lines. All helper functions (`g_content`, `g_w_content`, `reflCanR`, `tempR_fwd`, etc.) carry `ReflCanDomain` in their types.

### File: TruthLemma.lean (565 lines, 29 fc-refs)

**Purpose**: The truth lemma for the canonical model.

**Impact**: All derivation trees are built with base axioms (prop_k, etc.), so parameterizing over `fc` with `h_base_le : FrameClass.Base <= fc` allows all existing `trivial` proofs to continue working. No base axiom usages would break.

## 7. Full Dependency Chain

```
ChronicleTypes.lean  (foundation: Chronicle type, DCS, conditions)
   |
   +-- RRelation.lean  (r-relation, deductive closure)
   |    |
   |    +-- PointInsertion.lean  (insert points into chronicle)
   |    |    |
   |    |    +-- CounterexampleElimination.lean  (eliminate C5/C5' counterexamples)
   |    |         |
   |    |         +-- ChronicleConstruction.lean  (omega-chain, limit chronicle)
   |    |              |
   |    |              +-- ChronicleToCountermodel.lean  (countermodels)
   |    |                   |
   |    |                   +-- Completeness.lean (BXCanonical, imports ChronicleToCountermodel)
   |    |                   +-- Transfer.lean (WeakCanonical, imports ChronicleToCountermodel)
   |    |
   |    +-- ChronicleConstruction.lean (also imports RRelation)
   |
   +-- ChronicleConstruction.lean (also imports ChronicleTypes)
   |
ReflexiveCanonical.lean  (ReflCanDomain, canonical relations)
   |
   +-- TruthLemma.lean  (truth lemma)
        |
        +-- FrameProperties.lean  (z1, prior_UZ, prior_SZ in MCS)
             |
             +-- ChronicleExtraction.lean  (imports FrameProperties + ChronicleConstruction + ChronicleToCountermodel)
                  |
                  +-- IntegerModel.lean  (imports ChronicleExtraction)
                  +-- NEquivalence.lean  (imports ChronicleExtraction)
                  +-- WeakCanonical.lean  (imports FrameProperties + ChronicleExtraction)
```

## 8. Cascading Change Impact Assessment

### Tier 1: Must Change (Contains Sorries)

| File | Lines | fc-refs | Sorries | Effort |
|---|---|---|---|---|
| FrameProperties.lean | 55 | 3 (sorry) | 3 | Small |
| ChronicleExtraction.lean | 259 | 6 | 2 | Small |
| ChronicleToCountermodel.lean | 3,378 | 167 | 1 | Large (mechanical) |

### Tier 2: Must Change (Foundation Dependencies)

| File | Lines | fc-refs | Effort |
|---|---|---|---|
| ChronicleTypes.lean | 694 | 17 | Medium |
| RRelation.lean | 1,674 | ~25 (via grep) | Medium-Large |
| PointInsertion.lean | 3,527 | ~60 (via grep) | Large (mechanical) |
| CounterexampleElimination.lean | 3,487 | ~50 (via grep) | Large (mechanical) |
| ChronicleConstruction.lean | 1,510 | 71 | Large (mechanical) |

### Tier 3: Must Change (WeakCanonical Layer)

| File | Lines | fc-refs | Effort |
|---|---|---|---|
| ReflexiveCanonical.lean | 760 | 24 | Medium |
| TruthLemma.lean | 565 | 29 | Medium |

### Tier 4: Downstream Consumers (Signature Change Propagation)

| File | Change Type |
|---|---|
| Transfer.lean | Update `countermodel_discrete` signature (1 line) |
| Completeness.lean (BXCanonical) | Update `dd_countermodel_chronicle_discrete` call |
| WeakCanonical.lean | Update imports/calls |
| IntegerModel.lean | Update `ChronicleAsPriorModel` usage |
| NEquivalence.lean | Update `ChronicleAsPriorModel` usage |

### Total Estimated Scope

- **Files to modify**: 12-14
- **Total lines in scope**: ~16,000
- **Total FrameClass.Base references to update**: ~450+
- **Nature of changes**: ~95% mechanical (replace `FrameClass.Base` with `fc`), ~5% structural (add `variable`, update type signatures)

## 9. Parameterization Strategy

### Approach: Add `variable (fc : FrameClass)` with `h_base_le : FrameClass.Base <= fc`

The cleanest approach is:

1. **ChronicleTypes.lean**: Parameterize `ClosedUnderDerivation`, `SetDeductivelyClosed`, `Chronicle.c0`, `Chronicle.c1`, etc. over `fc`. The `Chronicle` data type stays unchanged (pure data).

2. **RRelation.lean, PointInsertion.lean, CounterexampleElimination.lean, ChronicleConstruction.lean**: Replace all `FrameClass.Base` with `fc` in function signatures. Since all derivation trees in these files use only base axioms, the `h_fc : h.minFrameClass <= fc` obligation reduces to `Base <= fc`, which follows from `h_base_le`.

3. **ChronicleToCountermodel.lean**: Same mechanical replacement. The `z1_derivation` becomes:
   ```lean
   private def z1_derivation (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (phi : Formula) :
       DerivationTree fc [] (z1_formula phi) :=
     DerivationTree.axiom [] _ (Axiom.z1 phi) h_fc
   ```
   When the discrete pipeline instantiates with `fc = .Discrete`, the proof is `le_refl .Discrete` or `trivial`.

4. **ReflexiveCanonical.lean**: Parameterize `ReflCanDomain` over `fc`:
   ```lean
   def ReflCanDomain (fc : FrameClass) : Type :=
     { S : Set Formula // SetMaximalConsistent (fc := fc) S }
   ```

5. **TruthLemma.lean**: Add `variable (fc : FrameClass)` and thread through.

6. **FrameProperties.lean**: Now `ReflCanDomain fc` has `x.property : SetMaximalConsistent (fc := fc)`, so:
   ```lean
   theorem z1_in_frame (fc : FrameClass) (h_fc : .Discrete <= fc) (x : ReflCanDomain fc) (psi : Formula) :
       ... in x.val :=
     theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.z1 psi) h_fc)
   ```
   The sorry becomes `h_fc`.

7. **ChronicleExtraction.lean**: Same pattern -- `h_fc` replaces sorry.

### Key Insight: Base Axiom Proofs Are Preserved

The constraint `h_base_le : FrameClass.Base <= fc` (which is `True` for any `fc`) ensures that all existing base axiom usages (`trivial` proofs) remain valid. This is because:
- For `fc = .Base`: `Base <= Base` is `True`
- For `fc = .Dense`: `Base <= Dense` is `True`
- For `fc = .Discrete`: `Base <= Discrete` is `True`

So the 450+ mechanical replacements of `FrameClass.Base -> fc` do not break any existing proofs. Only the 6 sorry locations need new proof terms.

### Alternative: Do NOT Require `h_base_le` Everywhere

Since `FrameClass.Base <= fc` is `True` for all `fc`, we do not need to carry `h_base_le` as an explicit hypothesis. Instead, the proof obligation `h.minFrameClass <= fc` where `h.minFrameClass = .Base` is always `True`, and `trivial` continues to work. We only need `h_fc : .Discrete <= fc` at the 6 sorry locations.

This simplifies the parameterization: most functions just get `(fc : FrameClass)` in their signature with no additional hypothesis. The `trivial` proofs for base axiom gates work unchanged.

## 10. Instantiation Sites

### Dense Pipeline (fc = .Base or .Dense)

The dense countermodel construction (`countermodel_dense`, `cantor_bfmcs_dense`, etc.) never uses discrete axioms. It can be instantiated with `fc = .Base` (preserving current behavior) or `fc = .Dense` if density axiom usage is needed in the future.

### Discrete Pipeline (fc = .Discrete)

The discrete countermodel construction (`dd_countermodel_chronicle_discrete`, `cantor_bfmcs_discrete`, `extract_chronicle_as_prior`) uses z1, prior_UZ, prior_SZ. Instantiate with `fc = .Discrete` and supply `le_refl .Discrete` or `trivial` for the `h_fc` proof.

### Mixed Case (fc = .Base)

The mixed case (`dd_countermodel_chronicle_mixed_sorry`) is vacuously true via `False.elim`. It can stay at `fc = .Base`.

## 11. Patterns from Task 168 (Prior Parameterization)

Task 168 established the pattern for this work:

1. **Phase 1**: Core type changes (Axioms.lean, Derivation.lean) -- already done.
2. **Phases 2-7**: Cascade through downstream files, replacing hardcoded `FrameClass.Base` with the parameter.
3. **h_fc proof style**: For base axioms, `trivial` works universally. For discrete axioms, explicit `h_fc` hypotheses are needed.
4. **Notation**: `G |- f` defaults to `.Base`, `G |-[fc] f` uses explicit fc.

Task 197 follows the same pattern, but scoped to the Chronicle pipeline rather than the global DerivationTree infrastructure.

## 12. Risk Areas and Potential Complications

### Risk 1: Typeclass Resolution with Parameterized ReflCanDomain

Parameterizing `ReflCanDomain` over `fc` changes its type from a concrete type to a family of types. Existing typeclass instances and coercions (e.g., `CoeSort ReflCanDomain (Set Formula)`) must be updated. This is a modest risk since the instances are simple.

### Risk 2: ChronicleAsPriorModel Structure

`ChronicleAsPriorModel` has fields `root_mcs` and `fmcs_is_mcs` that hardcode `fc := .Base`. Parameterizing this structure over `fc` changes its public API, affecting `IntegerModel.lean` and `NEquivalence.lean`.

### Risk 3: Build Time

Modifying 12-14 files in a 14,270-line directory requires careful incremental compilation. Each file change triggers recompilation of all downstream files.

**Mitigation**: Work bottom-up (ChronicleTypes -> RRelation -> PointInsertion -> CounterexampleElimination -> ChronicleConstruction -> ChronicleToCountermodel) and verify each layer compiles before proceeding.

### Risk 4: The succ_cofinal Sorry

The `succ_cofinal` sorry at ChronicleToCountermodel.lean:1508 is a SEPARATE sorry (genuine mathematical gap in the Doets gap elimination argument). It is NOT one of the 6 fc-mismatch sorries. Parameterizing over `fc` does not fix it, and it must not be accidentally disturbed.

### Risk 5: Scope Creep into WeakCanonical TruthLemma

`TruthLemma.lean` (565 lines, 29 fc-refs) builds derivation trees using only base axioms. Parameterizing it over `fc` is safe but adds to the scope. If scope must be minimized, an alternative is to keep `TruthLemma.lean` at `.Base` and only parameterize the discrete-facing consumers (`FrameProperties.lean`, `ChronicleExtraction.lean`, `ChronicleToCountermodel.lean`).

**However**, this would require maintaining TWO versions of the truth lemma (one at `.Base`, one at `fc`) or using `DerivationTree.lift` to convert. The cleaner approach is to parameterize uniformly.

### Risk 6: Implicit fc in Namespace-Level Variables

If `variable (fc : FrameClass)` is used at the namespace level, it becomes an implicit parameter in all definitions within the namespace. This can interact subtly with Lean's elaboration. The task 168 pattern used explicit parameters rather than namespace-level variables, and this task should follow the same approach.

## 13. Recommended Phase Structure for Implementation

### Phase 1: ChronicleTypes.lean Foundation (Small, ~1h)

Parameterize `ClosedUnderDerivation`, `SetDeductivelyClosed`, `Chronicle.c0`, `Chronicle.c1`, and helper lemmas over `fc`. The `Chronicle` data type stays unchanged.

### Phase 2: RRelation.lean (Medium, ~2h)

Thread `fc` through the r-relation, deductive closure, and related lemmas.

### Phase 3: PointInsertion.lean (Large mechanical, ~3h)

Thread `fc` through all point insertion functions and lemmas (~425 references).

### Phase 4: CounterexampleElimination.lean (Large mechanical, ~3h)

Thread `fc` through all elimination functions (~86 references).

### Phase 5: ChronicleConstruction.lean (Large mechanical, ~2h)

Thread `fc` through the omega-chain, limit chronicle, and all limit lemmas (~90 references).

### Phase 6: ChronicleToCountermodel.lean (Large mechanical, ~4h)

Thread `fc` through LimitDomSubtype, discrete infrastructure, z1_derivation, and all countermodel theorems (~167 references). Fix sorry #6 (z1_derivation).

### Phase 7: WeakCanonical Layer (Medium, ~3h)

Parameterize ReflexiveCanonical.lean, TruthLemma.lean, FrameProperties.lean (fix sorries #1-3), ChronicleExtraction.lean (fix sorries #4-5), and downstream consumers.

### Phase 8: Integration and Verification (Small, ~1h)

Update Transfer.lean, Completeness.lean, WeakCanonical.lean. Run `lake build`. Verify all 6 sorries eliminated, no new sorries introduced.

**Total estimated effort**: 18-22 hours across 8 phases.

## 14. Key Design Decisions for Planner

1. **Parameterize uniformly vs. minimally**: Recommend uniform parameterization (all files get `fc`). Minimal approach (only sorry-containing files) creates technical debt and maintenance burden.

2. **Chronicle data type**: Leave `Chronicle` as pure data (no `fc`). Only conditions and predicates get `fc`.

3. **h_base_le hypothesis**: Do NOT carry as explicit parameter. Since `Base <= fc` is `True` for all `fc`, `trivial` works everywhere. Only carry `h_fc : .Discrete <= fc` where discrete axioms are used.

4. **Phase order**: Bottom-up through the Chronicle dependency chain, then WeakCanonical layer. Each phase should compile independently.

5. **Instantiation convention**: Dense pipeline instantiates at `.Base` (unchanged behavior). Discrete pipeline instantiates at `.Discrete` (fixes the 6 sorries). Mixed pipeline instantiates at `.Base` (vacuously true via `False.elim`).
