# Research Report: Metalogical Theorem Naming and Hygiene

**Task**: 166 -- Rename metalogical theorems to standard uniform names
**Session**: sess_1779136887_2711a9
**Date**: 2026-05-18

---

## 1. Frame Constraint Hierarchy

The codebase defines a four-level hierarchy of frame classes. Each level adds typeclass constraints on the temporal domain `D`:

### 1.1 Linear (Base)

**Constraints**: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
**Class**: `LinearTemporalFrame D` (marker typeclass in `FrameConditions/FrameClass.lean`)
**Axioms**: All 34 "base" axioms (Propositional + S5 Modal + BX Temporal + Interaction + Uniformity)

No soundness or completeness theorems target this level currently. The seriality axioms (serial_future, serial_past) are classified as base axioms but semantically require `Nontrivial` (which implies `NoMaxOrder`/`NoMinOrder` for ordered abelian groups). The `valid` definition already bundles `[Nontrivial D]`.

### 1.2 Serial

**Additional constraints**: `[Nontrivial D]` (which implies `NoMaxOrder D`, `NoMinOrder D` for abelian groups)
**Class**: `SerialFrame D` (marker typeclass)
**Axioms**: Same 34 base axioms. The seriality axioms (serial_future, serial_past) become sound at this level.
**Note on `valid`**: The definition `valid (phi : Formula) : Prop` already quantifies over `[Nontrivial D]`, so `valid` = validity on serial frames.

### 1.3 Dense

**Additional constraints**: `[DenselyOrdered D] [Nontrivial D]`
**Class**: `DenseTemporalFrame D` (marker typeclass)
**Axioms**: Same 34 base axioms plus the density axiom (DN = `F(phi) -> F(F(phi))`). Note: the density axiom is actually derivable from the BX system under the current semantics, but the frame restriction matters for completeness.
**Validity notion**: `valid_dense` in `Semantics/Validity.lean`

### 1.4 Discrete

**Additional constraints**: `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`
**Class**: `DiscreteTemporalFrame D` (marker typeclass)
**Axioms**: All 34 base axioms plus 3 discrete-only axioms: `prior_UZ`, `prior_SZ`, `z1`
**Validity notion**: `valid_discrete` in `Semantics/Validity.lean`

---

## 2. Current Theorem Inventory

### 2.1 Soundness Theorems (All SORRY-FREE)

| Current Name | File | Frame Level | Type Signature (key constraints) | Dense/Discrete Guard |
|---|---|---|---|---|
| `soundness` | `Metalogic/Soundness.lean:1089` | Serial | `(d : DerivationTree G phi) (h_dc : d.isDenseCompatible) ... [Nontrivial D] ...` | `isDenseCompatible` (excludes Prior-UZ/SZ/Z1) |
| `soundness_dense_valid` | `Metalogic/Soundness.lean:1192` | Dense | `(d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) : valid_dense phi` | `isDenseCompatible` |
| `soundness_dense` | `Metalogic/Soundness.lean:1264` | Dense | `... [DenselyOrdered D] [Nontrivial D] ... (h_dc : d.isDenseCompatible) ...` | `isDenseCompatible` |
| `soundness_discrete_valid` | `Metalogic/Soundness.lean:1364` | Discrete | `(d : DerivationTree [] phi) (h_dc : d.isDiscreteCompatible) : valid_discrete phi` | `isDiscreteCompatible` |
| `soundness_discrete` | `Metalogic/Soundness.lean:1421` | Discrete | `... [SuccOrder D] [PredOrder D] ... (h_dc : d.isDiscreteCompatible) ...` | `isDiscreteCompatible` |
| `axiom_base_valid` | `Metalogic/Soundness.lean:893` | Serial | `(h : Axiom phi) (h_base : h.isBase) : valid phi` | `isBase` |
| `axiom_valid_dense` | `Metalogic/Soundness.lean:943` | Dense | `(h : Axiom phi) (h_dc : h.isDenseCompatible) : valid_dense phi` | `isDenseCompatible` |
| `axiom_valid_discrete` | `Metalogic/Soundness.lean:993` | Discrete | `(h : Axiom phi) (h_dc : h.isDiscreteCompatible) : valid_discrete phi` | `isDiscreteCompatible` |

**FrameConditions wrappers** (in `FrameConditions/Soundness.lean`):

| Wrapper Name | Wraps | Additional Notes |
|---|---|---|
| `soundness_over` | `soundness` | Parameterized by specific D |
| `soundness_linear` | `soundness_over` | Uses `LinearTemporalFrame` typeclass |
| `FrameConditions.soundness_dense` | `soundness_over` | Uses `DenseTemporalFrame` typeclass |
| `FrameConditions.soundness_discrete` | `Metalogic.soundness_discrete` | Uses `DiscreteTemporalFrame` typeclass |
| `soundness_Int` | `Metalogic.soundness_discrete` | Concrete `Int` instantiation |

**DenseSoundness module** (`Metalogic/DenseSoundness.lean`):

| Name | Type |
|---|---|
| `density_sound_dense` | `valid_dense (phi.some_future.imp phi.some_future.some_future)` |
| `axiom_dense_valid` | `(h : Axiom phi) (h_dc : h.isDenseCompatible) -> valid_dense phi` |

**DiscreteSoundness module** (`Metalogic/DiscreteSoundness.lean`):

| Name | Type |
|---|---|
| `discreteness_forward_sound_discrete` | `valid_discrete (...)` |
| `axiom_discrete_valid` | `(h : Axiom phi) (h_dc : h.isDiscreteCompatible) -> valid_discrete phi` |

### 2.2 Completeness Theorems

| Current Name | File | Frame Level | Status | Notes |
|---|---|---|---|---|
| `bx_completeness` | `BXCanonical/Completeness.lean:131` | Serial (via `valid`) | Has sorries (via chronicle) | `valid phi -> Nonempty (DerivationTree [] phi)` |
| `bx_completeness'` | `BXCanonical/Completeness.lean:173` | Serial | Wrapper | Same as above |
| `dd_countermodel_chronicle_dense` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean:793` | Dense | Has sorries | Produces `exists D ... not (truth_at ...)` |
| `dd_countermodel_chronicle_discrete` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean:3288` | Discrete | Has sorries | Produces countermodel on Z |
| `dd_countermodel_chronicle_nondense_sorry` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean:831` | Non-dense | Placeholder sorry | Not used on critical path |
| `dd_countermodel_chronicle_mixed_sorry` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean:3366` | Mixed | Has sorries | Used in bx_completeness |
| `doets_countermodel_discrete` | `WeakCanonical/Transfer.lean:312` | Discrete | Has sorries | Reynolds/Doets pipeline |
| `dd_countermodel` | `BXCanonical/RootScopedChain.lean:202` | Serial | Dead code | Old approach, bypassed by chronicle |

### 2.3 Other Metalogical Theorems

| Current Name | File | Result |
|---|---|---|
| `decide` | `Decidability/DecisionProcedure.lean:119` | Decision procedure |
| `fmp_completeness` | `Decidability/Correctness.lean:100` | FMP completeness |
| `base_truth_lemma` | Boneyard (dead code) | Was in legacy strict semantics |

---

## 3. Naming Problems and Proposed Renames

### 3.1 Soundness

**Problem**: The current `soundness` theorem actually corresponds to the **serial** frame level (it requires `Nontrivial D` and excludes Prior-UZ/SZ via `isDenseCompatible`). Its name suggests it is the base/universal soundness, but it is not -- there is no soundness for `LinearOrder + AddCommGroup` alone (without `Nontrivial`).

**Key observation**: `valid` already quantifies over `[Nontrivial D]`, so `soundness` is inherently serial-level. There is no separate "linear" validity notion without `Nontrivial`.

**Proposed renames**:

| Current Name | Proposed Name | Rationale |
|---|---|---|
| `soundness` | `soundness_serial` | Matches the actual frame level (serial = Nontrivial) |
| `soundness_dense_valid` | `soundness_dense_valid` | Already correct |
| `soundness_dense` | `soundness_dense` | Already correct |
| `soundness_discrete_valid` | `soundness_discrete_valid` | Already correct |
| `soundness_discrete` | `soundness_discrete` | Already correct |
| `axiom_base_valid` | `axiom_serial_valid` | Valid on serial frames (needs Nontrivial) |
| `axiom_valid_dense` | `axiom_dense_valid` | Reorder for consistency |
| `axiom_valid_discrete` | `axiom_discrete_valid` | Reorder for consistency |

**Alternative considered**: Keep `soundness` as-is for the serial case (since serial is the "default" level). This is arguably cleaner because:
- The user's instruction says `soundness` = soundness for `LinearOrder + AddCommGroup` (the base)
- But `valid` already requires `Nontrivial`, making the base and serial levels identical in practice
- The tests use `soundness` as the default and it auto-resolves `h_dc` for base-axiom derivations
- Renaming to `soundness_serial` would break all test files (50+ call sites)

**Recommendation**: The user's instruction to name the plain `soundness` for "just LinearOrder + AddCommGroup (the base/linear frame constraints)" is semantically identical to the current `soundness` because `valid` already includes `Nontrivial`. The user's intent is likely: `soundness` = the version WITHOUT dense/discrete extension axioms, and `soundness_serial` = adding the explicit seriality axioms as extension axioms. However, since seriality axioms (serial_future, serial_past) are classified as BASE axioms in the current system and are already included in `soundness`, the cleanest approach is:

1. **Keep `soundness` as the name** for the current serial-level theorem (it IS the base soundness -- seriality is part of the base axiom system)
2. **No need for a separate `soundness_serial`** -- the serial axioms are base axioms
3. The `isDenseCompatible` guard already correctly captures that this soundness excludes discrete-only axioms

### 3.2 Completeness

**Problem**: The completeness theorem names are highly non-uniform:
- `bx_completeness` uses an axiom-system prefix (BX = Burgess-Xu)
- `dd_countermodel_chronicle_dense` uses an internal construction name (dd = defect/deduction)
- `doets_countermodel_discrete` uses an author name prefix

**Proposed renames**:

| Current Name | Proposed Name | Rationale |
|---|---|---|
| `bx_completeness` | `completeness_serial` | Parallel to `soundness`; it uses `valid` which is serial-level |
| `bx_completeness'` | `completeness_serial'` | Alternate form |
| `dd_countermodel_chronicle_dense` | `completeness_dense` (or keep as internal) | Parallel naming |
| `doets_countermodel_discrete` | `completeness_discrete` (or keep as internal) | Parallel naming |
| `dd_countermodel_chronicle_mixed_sorry` | (internal, keep as-is) | Dead-end / sorry'd placeholder |
| `dd_countermodel_chronicle_nondense_sorry` | (internal, keep as-is) | Not on critical path |
| `dd_countermodel` | (dead code, keep in Boneyard) | Not on critical path |

**Important nuance**: The countermodel theorems (`dd_countermodel_chronicle_dense`, `doets_countermodel_discrete`) are NOT completeness theorems in the standard form `valid_dense phi -> Nonempty (DerivationTree [] phi)`. They are **countermodel existence** theorems: given MCS A with specific properties, produce a model where phi fails. The actual completeness theorem (`bx_completeness`) calls these internally.

If the user wants top-level `completeness_dense` and `completeness_discrete` theorems in the standard form, these would need to be NEW wrapper theorems:

```lean
-- Proposed new theorem (does not currently exist)
theorem completeness_dense (phi : Formula) :
    valid_dense phi -> Nonempty (DerivationTree [] phi) := by
  sorry -- Would need to be factored out of bx_completeness
```

Currently, `bx_completeness` is the ONLY theorem of the form `valid phi -> Nonempty (DerivationTree [] phi)`. It handles all three cases (dense, discrete, mixed) internally via case split. There are NO separate `completeness_dense` or `completeness_discrete` at the top level.

### 3.3 Axiom Classifier Naming

| Current Name | Issue | Proposed |
|---|---|---|
| `Axiom.isBase` | Correct but note that "base" includes seriality axioms | Keep as-is |
| `Axiom.isDenseCompatible` | Means "not discrete-only" -- confusing | Consider `Axiom.isSerialCompatible` |
| `Axiom.isDiscreteCompatible` | Always True for all axioms | Consider removing or documenting |
| `Axiom.frameClass` | Returns `.Base` or `.Discrete` (no `.Dense` used) | Document |

---

## 4. Cross-Reference Map (Call Sites)

### 4.1 `soundness` (50+ call sites in Tests)

Files referencing `soundness` (via `open Bimodal.Metalogic`):
- `Tests/BimodalTest/Integration/EndToEndTest.lean` (lines 31, 56, 75, 90)
- `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` (40+ lines)
- `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean` (15+ lines)
- `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` (lines 269, 271)
- `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean`
- `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean`

Also referenced in:
- `Theories/Bimodal/FrameConditions/Soundness.lean` (line 57 -- `soundness_over` wrapper)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (docstring)

### 4.2 `soundness_dense` / `soundness_discrete`

- `Theories/Bimodal/FrameConditions/Soundness.lean` (wrappers)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (docstrings)

### 4.3 `bx_completeness`

- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (definition + `#print axioms`)
- `README.md` (line 146)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (re-export)

### 4.4 `dd_countermodel_chronicle_dense`

- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (line 155 -- called in `bx_completeness`)
- `#print axioms` (line 238)

### 4.5 `doets_countermodel_discrete`

- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (line 162 -- called in `bx_completeness`)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (definition)

---

## 5. README Alignment

The README's Result Details table (lines 141-148) currently reads:

| Frame Class | Additional Axioms | Soundness | Completeness |
|---|---|---|---|
| **Linear** | -- | -- | -- |
| **Serial** | `T -> FT`, `T -> PT` | `soundness` | `bx_completeness` |
| **Dense** | `Fphi -> FFphi` | `soundness_dense` | `dd_countermodel_chronicle_dense` |
| **Discrete** | `Fphi -> U(phi,neg phi)`, ... | `soundness_discrete` | active sorries |

**Issues**:
1. The "Linear" row has no theorems -- this accurately reflects the code since `valid` requires `Nontrivial`
2. "Serial" references `soundness` -- this is correct if we keep the name
3. "Dense" references `soundness_dense` -- this exists in both `Metalogic/Soundness.lean` and `FrameConditions/Soundness.lean`; the former is the primary definition
4. "Dense completeness" references `dd_countermodel_chronicle_dense` -- this is an internal countermodel theorem, not a proper completeness theorem
5. "Discrete completeness" says "active sorries" -- accurate

**After renaming**, the table should reflect the chosen names consistently.

---

## 6. Hygiene Improvements

### 6.1 Missing Theorems

1. **No standalone `completeness_dense` or `completeness_discrete`**: The user may want wrapper theorems of the form `valid_X phi -> Nonempty (DerivationTree [] phi)` for each frame class. Currently only `bx_completeness` (serial) exists in this form.

2. **No `soundness_serial_valid`**: There's `soundness_dense_valid` and `soundness_discrete_valid` (for empty-context derivations yielding frame-class validity), but no serial analogue. The serial analogue is trivially `soundness [] phi d h_dc` (empty context implies valid), but having it named would complete the pattern.

### 6.2 Inconsistent Naming Patterns

| Pattern | Instances | Issue |
|---|---|---|
| `axiom_X_valid` | `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` | Word order inconsistent: `base` before `valid`, but `valid` before `dense`/`discrete` |
| `soundness_X` | `soundness`, `soundness_dense`, `soundness_discrete` | Consistent (good) |
| `_valid` suffix | `soundness_dense_valid`, `soundness_discrete_valid` | No serial analogue |
| Countermodel names | `dd_countermodel_chronicle_dense`, `doets_countermodel_discrete` | Different author/method prefixes |

**Recommendation**: Standardize `axiom_X_valid` to consistent word order: `axiom_serial_valid`, `axiom_dense_valid`, `axiom_discrete_valid`.

### 6.3 Dead Code

| Item | Location | Status |
|---|---|---|
| `dd_countermodel` | `BXCanonical/RootScopedChain.lean:202` | Dead -- bypassed by chronicle |
| `dd_countermodel_chronicle_nondense_sorry` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean:831` | Not on critical path |
| `base_truth_lemma` | Boneyard | Already in Boneyard |
| `discrete_base_truth_lemma` | Boneyard | Already in Boneyard |

### 6.4 Sorry'd Theorems to Track

Active sorry sites on the critical path:

1. **`bx_completeness`** depends on `dd_countermodel_chronicle_dense` (1 sorry in CounterexampleElimination.lean:3570)
2. **`bx_completeness`** depends on `dd_countermodel_chronicle_mixed_sorry` (fully sorry'd)
3. **`doets_countermodel_discrete`** has 3+ sorries (chronicle truth lemma, nonempty sig, z_interval_countermodel bridge)
4. **`dd_countermodel_chronicle_discrete`** has sorries in chronicle modules

### 6.5 Module Organization

The current module structure for soundness is clean:
- `Soundness.lean` -- Main soundness theorem + frame-class variants
- `SoundnessLemmas.lean` -- Helper lemmas
- `DenseSoundness.lean` -- Dense-specific re-exports
- `DiscreteSoundness.lean` -- Discrete-specific re-exports

`DenseSoundness.lean` and `DiscreteSoundness.lean` are thin re-export modules (50 lines each). They could be folded into `Soundness.lean` or kept for API cleanliness.

The completeness structure is more fragmented:
- `BXCanonical/Completeness.lean` -- Main completeness theorem
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Dense countermodel
- `WeakCanonical/Transfer.lean` -- Discrete countermodel (Reynolds/Doets)

This fragmentation is justified by the very different proof strategies for dense vs discrete.

### 6.6 Docstring Improvements

Several key theorems have excellent docstrings. The main gaps:
- `axiom_valid_dense` and `axiom_valid_discrete` lack the detailed docstrings of `axiom_base_valid`
- The README table should match the actual theorem names after renaming

---

## 7. Proposed Naming Convention (Summary)

### Soundness

| Level | Theorem | Validity | Notes |
|---|---|---|---|
| Serial | `soundness` (keep) | `valid` | Excludes Prior-UZ/SZ/Z1 via `isDenseCompatible` |
| Dense | `soundness_dense` (keep) | `valid_dense` | Requires `DenselyOrdered D` |
| Discrete | `soundness_discrete` (keep) | `valid_discrete` | Requires `SuccOrder D` etc. |

**Rationale**: The current `soundness` name is appropriate because the serial level IS the default level in this system. Seriality axioms are base axioms.

### Completeness

| Level | Proposed Theorem | Current Name |
|---|---|---|
| Serial | `completeness_serial` | `bx_completeness` |
| Dense | `completeness_dense` (NEW wrapper) | `dd_countermodel_chronicle_dense` (internal) |
| Discrete | `completeness_discrete` (NEW wrapper) | `doets_countermodel_discrete` (internal) |

### Axiom Validity

| Level | Proposed | Current |
|---|---|---|
| Serial | `axiom_serial_valid` | `axiom_base_valid` |
| Dense | `axiom_dense_valid` | `axiom_valid_dense` |
| Discrete | `axiom_discrete_valid` | `axiom_valid_discrete` |

---

## 8. Implementation Considerations

### 8.1 Breaking Change Impact

Renaming `soundness` to `soundness_serial` would break 50+ test call sites. If the user's preference is to keep `soundness` as the serial-level name (matching the user's instruction that `soundness` = base/linear), this avoids all breakage.

Renaming `bx_completeness` to `completeness_serial` is lower impact (3-4 call sites).

### 8.2 New Wrapper Theorems Needed

To create proper `completeness_dense` and `completeness_discrete` theorems:

```lean
-- In a new file or Completeness.lean
theorem completeness_dense (phi : Formula) :
    valid_dense phi -> Nonempty (DerivationTree [] phi) := by
  -- Factor out from bx_completeness's dense case
  sorry

theorem completeness_discrete (phi : Formula) :
    valid_discrete phi -> Nonempty (DerivationTree [] phi) := by
  -- Factor out from bx_completeness's discrete case
  sorry
```

These would have the same sorry status as their underlying countermodel theorems.

### 8.3 FrameConditions Layer

The `FrameConditions/Soundness.lean` wrappers need updating to match any renames. The name `FrameConditions.soundness_dense` currently shadows `Metalogic.soundness_dense` -- after renaming, ensure no ambiguity.

---

## 9. Recommended Plan

### Phase 1: Completeness renames (low impact)
- Rename `bx_completeness` -> `completeness_serial`
- Rename `bx_completeness'` -> `completeness_serial'`
- Update README table
- Update docstrings in `Metalogic.lean`

### Phase 2: Axiom validity name normalization
- Rename `axiom_base_valid` -> `axiom_serial_valid`
- Rename `axiom_valid_dense` -> `axiom_dense_valid`
- Rename `axiom_valid_discrete` -> `axiom_discrete_valid`
- Update call sites in Soundness.lean (internal references)

### Phase 3: New completeness wrappers (optional)
- Create `completeness_dense` wrapper theorem
- Create `completeness_discrete` wrapper theorem
- These will carry the same sorry obligations as their backing countermodel theorems

### Phase 4: README and docstring updates
- Update the Result Details table
- Ensure all docstrings reference correct theorem names
- Document the frame hierarchy convention

### Phase 5: Cleanup thin re-export modules
- Consider whether `DenseSoundness.lean` and `DiscreteSoundness.lean` add value
- Rename `DenseSoundness.density_sound_dense` and `DenseSoundness.axiom_dense_valid` if they duplicate the standardized names
