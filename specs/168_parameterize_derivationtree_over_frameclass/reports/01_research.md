# Research Report: Parameterize DerivationTree over FrameClass

## 1. Current State Inventory

### 1.1 FrameClass Type

**Location**: `Theories/Bimodal/ProofSystem/Axioms.lean`, lines 380-384

```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited
```

Three constructors. No `PartialOrder` instance exists. No `LE` instance. The type is only referenced in `ProofSystem/Axioms.lean` itself and `FrameConditions.lean` (which re-exports). **No other file in the codebase directly uses `FrameClass`.**

### 1.2 Axiom Inductive

**Location**: `Theories/Bimodal/ProofSystem/Axioms.lean`, lines 74-373

40 constructors organized into 7 layers:
- **Propositional** (4): `prop_k`, `prop_s`, `ex_falso`, `peirce`
- **S5 Modal** (5): `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`
- **BX Temporal** (20): 10 future + 10 past-mirrors (`serial_future/past`, `left_mono_until_G/since_H`, `right_mono_until/since`, `connect_future/past`, `enrichment_until/since`, `self_accum_until/since`, `absorb_until/since`, `linear_until/since`, `until_F/since_P`, `temp_linearity/past`, `F_until_equiv/P_since_equiv`)
- **Modal-Temporal Interaction** (1): `modal_future`
- **Uniformity** (5): `discrete_symm_fwd/bwd`, `discrete_propagate_fwd/bwd`, `discrete_box_necessity`
- **Prior** (2): `prior_UZ`, `prior_SZ` -- discrete-only
- **Z1** (1): `z1` -- discrete-only

**Current classification**: `Axiom.frameClass` maps `prior_UZ/prior_SZ/z1` to `.Discrete` and everything else to `.Base`. **Nothing maps to `.Dense`** -- the density axiom has no constructor.

Referenced in 93 files across the codebase.

### 1.3 DerivationTree Inductive

**Location**: `Theories/Bimodal/ProofSystem/Derivation.lean`, lines 69-149

```lean
inductive DerivationTree : Context -> Formula -> Type where
  | axiom (G : Context) (f : Formula) (h : Axiom f) : DerivationTree G f
  | assumption ...
  | modus_ponens ...
  | necessitation ...
  | temporal_necessitation ...
  | temporal_duality ...
  | weakening ...
```

7 constructors. **Not parameterized by FrameClass.** The `axiom` constructor accepts any `Axiom f` without frame-class restrictions.

Referenced in **71 live files** and **20 Boneyard files** (91 total), with **2768 total references**.

### 1.4 Ad-Hoc Compatibility Predicates

#### On Axiom (in Axioms.lean, lines 394-428):
- `Axiom.isBase`: Returns `False` for `prior_UZ/prior_SZ/z1`, `True` for everything else
- `Axiom.isDenseCompatible`: Same as `isBase` (identical behavior)
- `Axiom.isDiscreteCompatible`: Returns `True` for ALL axioms

#### On DerivationTree (in Derivation.lean, lines 266-289):
- `DerivationTree.isDenseCompatible`: Recursively checks all axiom nodes are dense-compatible
- `DerivationTree.isDiscreteCompatible`: Recursively checks all axiom nodes are discrete-compatible

#### Supporting theorems (in Axioms.lean, lines 415-431):
- `Axiom.frameClass_eq_base_iff_isBase`
- `Axiom.isDiscreteCompatible_iff_frameClass`
- `Axiom.isBase_implies_both_compatible`
- `Axiom.minimalFrameClass` (abbreviation for `Axiom.frameClass`)

### 1.5 Compatibility Predicate Reference Counts (Live Files Only)

| Predicate | Files | Total References |
|-----------|-------|-----------------|
| `isDenseCompatible` | 6 | 65 |
| `isDiscreteCompatible` | 6 | 24 |
| `isBase` | 4 | 24 |
| `h_dc` (compatibility-related) | 5 | 105 |

**Files using `isDenseCompatible`** (live):
1. `ProofSystem/Axioms.lean` -- definition
2. `ProofSystem/Derivation.lean` -- definition
3. `Metalogic/Soundness.lean` -- 49 uses as `h_dc`
4. `Metalogic/SoundnessLemmas.lean` -- 38 uses as `h_dc`
5. `Metalogic/DenseSoundness.lean` -- 2 uses
6. `FrameConditions/Soundness.lean` -- 14 uses

**Files using `isDiscreteCompatible`** (live):
1. `ProofSystem/Axioms.lean` -- definition
2. `ProofSystem/Derivation.lean` -- definition
3. `Metalogic/Soundness.lean` -- in `soundness_discrete`
4. `Metalogic/SoundnessLemmas.lean`
5. `Metalogic/DiscreteSoundness.lean` -- 2 uses
6. `FrameConditions/Soundness.lean`

**Note**: `h_dc` in `Metalogic/WeakCanonical/EFGames.lean` (31 uses) refers to "downward closed" set property, NOT the compatibility predicate. This is not affected by the refactor.

### 1.6 Density Validity (No Axiom Constructor)

**Location**: `Metalogic/Soundness.lean`, lines 364-377

```lean
theorem density_valid (f : Formula) :
    valid_dense ((f.all_future.all_future).imp f.all_future)
```

This proves `GGf -> Gf` is valid on dense orders. There is no corresponding `Axiom` constructor, so derivation trees cannot use density as a proof step. `FrameClass.Dense` exists but nothing maps to it via `Axiom.frameClass`.

The `DenseSoundness.lean` re-exports this as `density_sound_dense`.

### 1.7 Soundness Architecture

Three parallel soundness theorems exist:

1. **`soundness`** (lines 1005-1081): Takes `h_dc : d.isDenseCompatible`, works on arbitrary frames
2. **`soundness_dense`** (lines 1177-1255): Takes `h_dc : d.isDenseCompatible`, works on dense frames
3. **`soundness_discrete`** (lines 1331-1363): Takes `h_dc : d.isDiscreteCompatible`, works on discrete frames

Plus two "valid" variants for empty-context derivations:
- `soundness_dense_valid` (lines 1105-1160)
- `soundness_discrete_valid` (lines 1274-1322)

Each soundness theorem contains a **40-branch case split** on `Axiom` constructors, duplicating validity proofs across frame classes. This is the primary code smell: 3 copies of essentially the same 40-case match, differing only in frame-class constraints.

### 1.8 Completeness Architecture

**Location**: `Metalogic/BXCanonical/Completeness.lean`

Three completeness theorems:
1. **`completeness`** (line 134): `valid f -> Nonempty (DerivationTree [] f)` -- produces unparameterized trees
2. **`completeness_dense`** (line 241): `valid_dense f -> Nonempty (DerivationTree [] f)` -- same return type
3. **`completeness_discrete`** (line 270): `valid_discrete f -> Nonempty (DerivationTree [] f)` -- same return type

All return `Nonempty (DerivationTree [] f)` without frame-class annotation. After this refactor, they would need to produce `DerivationTree fc [] f` for the appropriate `fc`.

### 1.9 FrameConditions/ Module

**`FrameConditions/FrameClass.lean`**: Defines `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame` typeclasses. These are marker typeclasses for semantic frame conditions, separate from the syntactic `FrameClass` enum.

**`FrameConditions/Soundness.lean`**: Wraps `Metalogic.soundness` variants using typeclass API. 14 `h_dc` references.

**`FrameConditions/Compatibility.lean`**: Defines `AxiomLinearCompatible`, `AxiomDenseCompatible`, `AxiomDiscreteCompatible` typeclasses. Uses `isBase`. This module would be largely superseded by the parameterized approach.

**`FrameConditions/Validity.lean`**: Defines `valid_over D f` and frame-class validity.

## 2. Downstream Impact Map

### 2.1 Files by Impact Category

**Category A: Core definitions (must change)** -- 2 files
| File | DerivationTree refs | Compatibility refs | Impact |
|------|--------------------|--------------------|--------|
| `ProofSystem/Axioms.lean` | 0 | 24 (isBase) + 12 (isDense/isDiscrete) | Add density axiom, add PartialOrder, refactor predicates |
| `ProofSystem/Derivation.lean` | 37 | 24 (isDense/isDiscrete defs) | Add `fc` parameter to `DerivationTree`, remove predicate defs |

**Category B: Soundness (heavy changes)** -- 4 files
| File | DerivationTree refs | h_dc refs | Impact |
|------|--------------------|-----------| -------|
| `Metalogic/Soundness.lean` | 24 | 49 | 3 soundness theorems with 40-case splits each; remove h_dc, restructure |
| `Metalogic/SoundnessLemmas.lean` | 28 | 38 | Swap-validity lemmas; remove h_dc guards |
| `Metalogic/DenseSoundness.lean` | 0 | 2 | Thin wrapper; may be deleted/simplified |
| `Metalogic/DiscreteSoundness.lean` | 0 | 2 | Thin wrapper; may be deleted/simplified |

**Category C: Frame conditions (moderate changes)** -- 3 files
| File | DerivationTree refs | h_dc refs | Impact |
|------|--------------------|-----------| -------|
| `FrameConditions/Soundness.lean` | 0 | 14 | Remove h_dc from wrappers |
| `FrameConditions/Compatibility.lean` | 0 | 0 (uses isBase) | Largely superseded; simplify or delete |
| `FrameConditions/Validity.lean` | 0 | 0 | Minor; valid_over unchanged |

**Category D: Completeness (moderate changes)** -- 1 file
| File | DerivationTree refs | Impact |
|------|--------------------| -------|
| `Metalogic/BXCanonical/Completeness.lean` | 10 | Return `DerivationTree .Base []` / `.Dense` / `.Discrete`; adjust countermodel proofs |

**Category E: Metalogic (type signature updates only)** -- 37 live files
These files reference `DerivationTree` in type signatures or pass derivation trees around but do not use compatibility predicates. They need mechanical updates to add the `fc` parameter.

Top files by reference count (live, excluding Cat A-D):
| File | Refs | Description |
|------|------|-------------|
| `BXCanonical/Chronicle/PointInsertion.lean` | 430 | Chronicle proof construction |
| `Theorems/Propositional.lean` | 135 | Propositional derived theorems |
| `Algebraic/UltrafilterMCS.lean` | 103 | Ultrafilter MCS properties |
| `BXCanonical/Chronicle/RRelation.lean` | 105 | R-relation chronicle |
| `Core/RestrictedMCS.lean` | 74 | Restricted MCS operations |
| `Completeness.lean` | 67 | MCS modal properties |
| `Theorems/Perpetuity/Bridge.lean` | 63 | Perpetuity bridge lemmas |
| `Theorems/Combinators.lean` | 58 | Proof combinator library |
| `ConservativeExtension/Lifting.lean` | 58 | CE lifting theorems |
| `Theorems/Perpetuity/Principles.lean` | 55 | Perpetuity principles |

**Category F: Boneyard (low priority)** -- 20 files
These are archived/dead code. The Boneyard files with h_dc references (7 files, ~30 refs) can be updated mechanically or left as-is.

### 2.2 Total Change Scope

| Category | Files | Estimated Lines Changed | Difficulty |
|----------|-------|------------------------|------------|
| A: Core definitions | 2 | 100-150 | High (design) |
| B: Soundness | 4 | 600-900 (mostly deletion) | Medium (repetitive) |
| C: Frame conditions | 3 | 50-100 | Low |
| D: Completeness | 1 | 30-50 | Medium |
| E: Type signature updates | 37 | 200-400 (mechanical) | Low (tedious) |
| F: Boneyard | 20 | 100-200 (optional) | Low |
| **Total (live)** | **47** | **980-1600** | |

## 3. Risks and Ordering Constraints

### 3.1 Compilation Dependency Order

The import chain is:
```
Syntax/Formula.lean
  |
  v
ProofSystem/Axioms.lean  <-- FrameClass, Axiom defined here
  |
  v
ProofSystem/Derivation.lean  <-- DerivationTree defined here
  |
  +---> ProofSystem/Derivable.lean
  +---> ProofSystem/Substitution.lean
  +---> Metalogic/Core/DeductionTheorem.lean --> Core/MaximalConsistent.lean
  +---> Metalogic/SoundnessLemmas.lean --> Metalogic/Soundness.lean
  +---> Theorems/Propositional.lean --> Theorems/Combinators.lean --> ...
  +---> all other files
```

**Critical path**: `Axioms.lean` -> `Derivation.lean` -> everything else.

Changing `DerivationTree`'s type signature in `Derivation.lean` will cause a cascade through **all 91 files** that reference it. This is unavoidable but the changes are mostly mechanical (adding `fc` parameter).

### 3.2 No Circular Dependencies

The import graph is a DAG. No circular dependencies exist between any files.

### 3.3 What Breaks First

When `DerivationTree`'s signature changes from `Context -> Formula -> Type` to `FrameClass -> Context -> Formula -> Type`:

1. **Immediate breakage**: Every file that constructs or pattern-matches on `DerivationTree` will fail to typecheck. This includes:
   - All `Theorems/*.lean` files (construct trees)
   - All `Metalogic/Core/*.lean` files (manipulate trees)
   - All `Metalogic/BXCanonical/*.lean` files (construct countermodels)
   - The `Automation/*.lean` files (proof search)

2. **Notation breakage**: `G |- f` and `|- f` are notation for `DerivationTree G f` and `DerivationTree [] f`. These need updating to `DerivationTree fc G f`.

### 3.4 Key Risks

1. **Lift function complexity**: The `lift` function `fc1 <= fc2 -> DerivationTree fc1 G f -> DerivationTree fc2 G f` requires recursion over all 7 constructors. For `axiom`, the key obligation is `ax.minFrameClass <= fc1 <= fc2` which gives `ax.minFrameClass <= fc2` by transitivity. This should be straightforward.

2. **Notation ergonomics**: Currently `|- f` is convenient. With parameterization, users would need `DerivationTree .Base [] f` or similar. Consider keeping `|- f` as `DerivationTree .Base [] f` (base = default).

3. **Theorems/ module ergonomics**: The ~600 theorems in `Theorems/Propositional.lean`, `Combinators.lean`, etc. all construct `DerivationTree`. They all use only base axioms, so they would become `DerivationTree .Base`. The parameter adds noise but carries information.

4. **MCS properties**: `Core/MaximalConsistent.lean` and `Core/MCSProperties.lean` use `Nonempty (DerivationTree G Formula.bot)` for consistency. This becomes `Nonempty (DerivationTree fc G Formula.bot)` -- need to decide if consistency is frame-class-indexed.

5. **Deduction theorem**: `Core/DeductionTheorem.lean` proves deduction theorem by recursion on `DerivationTree`. The `fc` parameter threads through uniformly -- no risk.

## 4. Existing Infrastructure Check

### 4.1 PartialOrder on FrameClass
**Does not exist.** No `LE`, `Preorder`, or `PartialOrder` instance on `FrameClass`.

### 4.2 Lift Function
**Does not exist.** No function converts `DerivationTree` between frame classes.

### 4.3 Prior Attempts
**None found.** No prior attempt at this refactor exists in the codebase or Boneyard.

### 4.4 Existing Axiom.frameClass
**Exists but incomplete.** `Axiom.frameClass` maps 3 axioms to `.Discrete` and 37 to `.Base`. Nothing maps to `.Dense`. The `Axiom.minimalFrameClass` abbreviation is ready to use.

### 4.5 FrameConditions/Compatibility.lean
**Partially overlapping.** This file defines `AxiomLinearCompatible`, `AxiomDenseCompatible`, `AxiomDiscreteCompatible` typeclasses that bundle validity proofs with axioms. After the refactor, these become derivable from the parameterized structure and can likely be simplified or removed.

## 5. Proposed Refactor Design

### 5.1 PartialOrder on FrameClass

```
Base <= Dense
Base <= Discrete
Dense and Discrete incomparable (neither Dense <= Discrete nor Discrete <= Dense)
```

This is a partial order (reflexive, transitive, antisymmetric). It forms a diamond-minus lattice (diamond without top).

### 5.2 Axiom.minFrameClass

- `prior_UZ`, `prior_SZ`, `z1` -> `.Discrete`
- New `density` constructor -> `.Dense`
- All other 37 axioms -> `.Base`

### 5.3 Parameterized DerivationTree

```lean
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type where
  | axiom (G : Context) (f : Formula) (h : Axiom f) (h_fc : h.minFrameClass <= fc)
      : DerivationTree fc G f
  | assumption ...  -- unchanged except fc parameter
  | modus_ponens ... -- unchanged
  | necessitation ... -- unchanged
  | temporal_necessitation ... -- unchanged
  | temporal_duality ... -- unchanged
  | weakening ... -- unchanged
```

Only the `axiom` constructor changes substantively (adds `h_fc` proof obligation). All other constructors thread `fc` uniformly.

### 5.4 Lift Function

```lean
def DerivationTree.lift {fc1 fc2 : FrameClass} (h : fc1 <= fc2)
    {G : Context} {f : Formula} : DerivationTree fc1 G f -> DerivationTree fc2 G f
```

Recursion over the 7 constructors. For `axiom`, use `le_trans h_fc h`.

### 5.5 Soundness Simplification

The three soundness theorems collapse into one:

```lean
theorem soundness (fc : FrameClass) (G : Context) (f : Formula)
    (d : DerivationTree fc G f) : ...
```

The 40-branch case split on axiom constructors reduces to a single call dispatching on `ax.minFrameClass <= fc`. The `h_dc` parameter disappears entirely.

## 6. Effort Estimates

| Step | Description | Estimated Hours | Complexity |
|------|-------------|----------------|------------|
| 1 | Add density axiom constructor | 1-2h | Medium |
| 2 | Add PartialOrder on FrameClass | 1h | Low |
| 3 | Define Axiom.minFrameClass update | 0.5h | Low |
| 4 | Parameterize DerivationTree | 2-3h | High (design, notation) |
| 5 | Add lift function | 1-2h | Medium |
| 6 | Remove ad-hoc predicates | 1h | Low (deletion) |
| 7 | Update soundness theorems | 4-6h | Medium-High (large files, 40-case splits) |
| 8 | Update completeness theorems | 2-3h | Medium |
| 9 | Update downstream references | 6-10h | Low (mechanical, tedious) |
| 10 | Connect density_valid | 0.5h | Low |
| 11 | Update documentation | 1h | Low |
| **Total** | | **20-30h** | |

**Critical path**: Steps 1-4 are sequential (each depends on the previous). Steps 5-6 depend on 4. Steps 7-10 depend on 4 and can be partially parallelized. Step 11 is last.

### 6.1 Recommended Phase Structure

**Phase 1** (Core): Steps 1-4 (density axiom, PartialOrder, parameterize DerivationTree)
**Phase 2** (Lift + Cleanup): Steps 5-6 (lift function, remove predicates)
**Phase 3** (Soundness): Step 7 (rewrite soundness theorems)
**Phase 4** (Completeness + Downstream): Steps 8-9 (completeness + mechanical updates)
**Phase 5** (Polish): Steps 10-11 (density connection, documentation)

## 7. Key Observations

1. **The blast radius is large but shallow.** 71 live files reference `DerivationTree`, but only ~10 files use the compatibility predicates. The vast majority of changes are mechanical parameter threading.

2. **The soundness code shrinks significantly.** Three near-duplicate 40-case matches collapse into one. `SoundnessLemmas.lean` (2422 lines) has 4 near-duplicate blocks that become 1. This aligns with the task 174 goal of splitting oversized files -- after this refactor, `SoundnessLemmas.lean` may shrink below the split threshold.

3. **The density axiom gap is real.** `FrameClass.Dense` exists, `density_valid` proves the axiom is sound, but there is no `Axiom` constructor for it. This means dense derivations cannot be constructed syntactically. Adding the constructor is the cleanest fix.

4. **`Axiom.isDenseCompatible` and `Axiom.isBase` are currently identical.** Both return `False` for `prior_UZ/prior_SZ/z1` and `True` for everything else. This is because there is no density axiom constructor -- once added, they would diverge (density would be dense-compatible but not base).

5. **`Axiom.isDiscreteCompatible` is trivially `True` for all axioms.** This makes `DerivationTree.isDiscreteCompatible` always `True` -- it serves no filtering purpose. Once the density axiom is added, `isDiscreteCompatible` would correctly return `False` for density.

6. **The Boneyard can be deferred.** 20 Boneyard files reference `DerivationTree` but they are dead code. They can be updated later or left broken (they are already archived).

7. **Notation needs careful design.** The current `G |- f` and `|- f` notation is clean. Options:
   - `G |-[fc] f` for parameterized, `G |- f` defaults to `.Base`
   - `G |-_dense f`, `G |-_disc f` for specific frame classes
   - Keep `G |- f` as universe-polymorphic (using `.Base` as default)

8. **Consistency definition needs decision.** Currently `Consistent G := not Nonempty (DerivationTree G bot)`. Options:
   - Index by frame class: `Consistent fc G := not Nonempty (DerivationTree fc G bot)`
   - Keep unparameterized: `Consistent G := not Nonempty (DerivationTree .Base G bot)` (base consistency implies frame-class consistency via lift)
   - The second option is cleaner -- if `G` is Base-consistent, it is consistent in any frame class (by lift: if `DerivationTree fc G bot` existed, we could... wait, lift goes the wrong direction. Lift goes from weaker to stronger frame class. Consistency is about non-derivability of bot, so Base-inconsistency (derivable from base axioms) implies fc-inconsistency for fc >= Base (which is all fc). So Base-consistency is the weakest notion.)

   Actually: if `DerivationTree .Base G bot` exists, then by `lift`, `DerivationTree fc G bot` exists for any `fc >= .Base`. Since `.Base <= fc` for all `fc`, if `G` derives `bot` in Base, it derives `bot` everywhere. Conversely, if `G` is Base-consistent, it might still be fc-inconsistent (using fc-specific axioms). So the right notion depends on context. For completeness, we need fc-indexed consistency.
