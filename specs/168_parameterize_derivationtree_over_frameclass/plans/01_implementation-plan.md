# Implementation Plan: Parameterize DerivationTree over FrameClass

- **Task**: 168 - Parameterize DerivationTree over FrameClass
- **Status**: [NOT STARTED]
- **Effort**: 24 hours
- **Dependencies**: None
- **Research Inputs**: specs/168_parameterize_derivationtree_over_frameclass/reports/01_research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Refactor the TM bimodal logic proof system so that `DerivationTree` is parameterized by `FrameClass`, making frame-class validity a structural invariant enforced by Lean's type system rather than by ad-hoc Boolean predicates (`isBase`, `isDenseCompatible`, `isDiscreteCompatible`). The refactor adds a density axiom constructor, equips `FrameClass` with a `PartialOrder`, gates the `axiom` constructor with `ax.minFrameClass <= fc`, provides a `lift` function for coercing derivations between compatible frame classes, and removes all compatibility predicates and their ~200 references across soundness/completeness theorems. The 71 live files referencing `DerivationTree` are updated in compilation-dependency order so that `lake build` passes at the end of each phase.

### Research Integration

The research report (01_research.md) provided:
- Complete inventory of 40 Axiom constructors, 7 DerivationTree constructors, 3 ad-hoc predicates
- File-by-file impact map: 2 core, 4 soundness, 3 frame-conditions, 1 completeness, 37 mechanical, 20 Boneyard
- Compilation dependency DAG: Axioms.lean -> Derivation.lean -> everything else
- Confirmation that no circular dependencies exist
- Key insight: `isDenseCompatible` and `isBase` are currently identical (no density axiom exists)
- Key insight: `isDiscreteCompatible` is trivially `True` for all axioms

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Single source of truth: `ax.minFrameClass <= fc` replaces all ad-hoc predicates
- Clean partial order on `FrameClass`: Base <= Dense, Base <= Discrete, Dense/Discrete incomparable
- Density axiom constructor (GGf -> Gf) mapped to `FrameClass.Dense`
- `DerivationTree fc : Context -> Formula -> Type` with structural frame-class enforcement
- `lift` function for `fc1 <= fc2` derivation coercion
- Complete removal of `isBase`, `isDenseCompatible`, `isDiscreteCompatible` and `h_dc` threading
- Soundness theorems without compatibility side-conditions
- Ergonomic notation: `G |-[fc] f` for parameterized, `G |- f` defaults to `.Base`
- `lake build` passes at the end of each phase

**Non-Goals**:
- Updating Boneyard files (20 files, dead code -- can be done later or left broken)
- Changing the axiom set beyond adding density (no axiom removals or renaming)
- Refactoring soundness into fewer files (task 174 scope)
- Mathlib-style naming normalization (task 175 scope)
- Changing the `Consistent` definition's frame-class semantics beyond what is forced

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type parameter cascades through 71 files at once | H | H | Phase 2 uses universe-polymorphic `variable (fc : FrameClass)` and lean-lsp to verify each file compiles before moving to the next batch |
| Notation `|- f` breakage in 60+ files | M | H | Phase 2 redefines notation to default to `.Base`, so most downstream files compile unchanged |
| Soundness 40-case splits need per-constructor `minFrameClass <= fc` proofs | M | M | Use `decide` or `Decidable` instance on the LE relation; all 37 base cases discharge by `le_refl` |
| `Derivable` / `Consistent` definitions need frame-class parameter decisions | M | M | Keep `Derivable` and `Consistent` unparameterized (defaulting to `.Base`); add `Derivable.fc` variant |
| ExtDerivation in ConservativeExtension mirrors Axiom/DerivationTree | M | L | ExtAxiom/ExtDerivationTree are independent inductives -- update in Phase 5 if needed, or defer |
| Completeness theorems have sorry sites that may interact | L | M | Completeness return types change minimally (add `fc` parameter); sorry sites are orthogonal |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Core Type Definitions [COMPLETED]

**Goal**: Add density axiom, equip FrameClass with PartialOrder, update Axiom.minFrameClass, parameterize DerivationTree with fc, add lift function, define new notation. This phase touches only Axioms.lean and Derivation.lean -- the two root files of the compilation DAG. After this phase, `lake build` will fail on downstream files (expected), but the two modified files themselves must compile.

**Tasks**:
- [x] **1.1** Add density axiom constructor to `Axiom` inductive in Axioms.lean: *(completed)*
  ```lean
  | density (φ : Formula) :
      Axiom ((φ.all_future.all_future).imp φ.all_future)
  ```
  Place after `z1` and before `deriving Repr`. This makes constructor count 41.

- [x] **1.2** Define `LE` and `PartialOrder` instances on `FrameClass` in Axioms.lean: *(completed)*
  ```lean
  instance : LE FrameClass where
    le a b := match a, b with
      | .Base, _ => True
      | .Dense, .Dense => True
      | .Discrete, .Discrete => True
      | _, _ => False

  instance : DecidableRel (LE.le : FrameClass -> FrameClass -> Prop) :=
    fun a b => by cases a <;> cases b <;> simp [LE.le] <;> infer_instance

  instance : PartialOrder FrameClass where
    le := (. <= .)
    le_refl := by intro a; cases a <;> simp [LE.le]
    le_trans := by intro a b c hab hbc; cases a <;> cases b <;> cases c <;> simp_all [LE.le]
    le_antisymm := by intro a b hab hba; cases a <;> cases b <;> simp_all [LE.le]
  ```

- [x] **1.3** Update `Axiom.frameClass` (renamed to `Axiom.minFrameClass`) to handle the new `density` constructor: *(completed)*
  ```lean
  def Axiom.minFrameClass {φ : Formula} : Axiom φ → FrameClass
    | density _ => .Dense
    | prior_UZ _ => .Discrete
    | prior_SZ _ => .Discrete
    | z1 _ => .Discrete
    | _ => .Base
  ```
  Remove the old `frameClass` def and the `minimalFrameClass` abbreviation (replace with the renamed def).

- [x] **1.4** Remove `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible` and all supporting theorems (`frameClass_eq_base_iff_isBase`, `isDiscreteCompatible_iff_frameClass`, `isBase_implies_both_compatible`, `discreteness_forward_not_dense_compatible`) from Axioms.lean. *(completed)*

- [x] **1.5** Parameterize `DerivationTree` in Derivation.lean: *(completed)*
  ```lean
  inductive DerivationTree (fc : FrameClass) : Context → Formula → Type where
    | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
        : DerivationTree fc Γ φ
    | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree fc Γ φ
    | modus_ponens (Γ : Context) (φ ψ : Formula)
        (d1 : DerivationTree fc Γ (φ.imp ψ))
        (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ
    | necessitation (φ : Formula)
        (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.box φ)
    | temporal_necessitation (φ : Formula)
        (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.all_future φ)
    | temporal_duality (φ : Formula)
        (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.swap_temporal
    | weakening (Γ Δ : Context) (φ : Formula)
        (d : DerivationTree fc Γ φ)
        (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
  ```

- [x] **1.6** Add `DerivationTree.lift` function in Derivation.lean: *(completed)*
  ```lean
  def DerivationTree.lift {fc1 fc2 : FrameClass} (h_le : fc1 ≤ fc2)
      {Γ : Context} {φ : Formula} : DerivationTree fc1 Γ φ → DerivationTree fc2 Γ φ
    | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
    | .assumption Γ φ h => .assumption Γ φ h
    | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
    | .necessitation φ d => .necessitation φ (d.lift h_le)
    | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
    | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
    | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h
  ```

- [x] **1.7** Remove `DerivationTree.isDenseCompatible` and `DerivationTree.isDiscreteCompatible` from Derivation.lean (lines 266-290). *(completed)*

- [x] **1.8** Update notation in Derivation.lean. Replace old notation: *(completed)*
  ```lean
  -- Old:
  notation:50 Γ " ⊢ " φ => DerivationTree Γ φ
  notation:50 "⊢ " φ => DerivationTree [] φ

  -- New:
  notation:50 Γ " ⊢[" fc "] " φ => DerivationTree fc Γ φ
  notation:50 "⊢[" fc "] " φ => DerivationTree fc [] φ
  notation:50 Γ " ⊢ " φ => DerivationTree FrameClass.Base Γ φ
  notation:50 "⊢ " φ => DerivationTree FrameClass.Base [] φ
  ```

- [x] **1.9** Update `height` function and any other `DerivationTree` methods in Derivation.lean to account for the new `h_fc` parameter in the `axiom` constructor and the `fc` parameter on the type. Verify that the example derivations at the end of Derivation.lean still compile (they use base axioms, so `h_fc` discharges by `le_refl`). *(completed — examples use `trivial` for h_fc since Base ≤ Base is True)*

- [x] **1.10** Verify Axioms.lean and Derivation.lean compile individually via lean-lsp or `lake build Bimodal.ProofSystem.Axioms` and `lake build Bimodal.ProofSystem.Derivation`. *(completed — both compile cleanly)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Add density constructor, PartialOrder, remove ad-hoc predicates
- `Theories/Bimodal/ProofSystem/Derivation.lean` -- Parameterize DerivationTree, add lift, update notation

**Verification**:
- `lake build Bimodal.ProofSystem.Axioms` passes
- `lake build Bimodal.ProofSystem.Derivation` passes
- `Axiom.minFrameClass` correctly classifies all 41 constructors
- `DerivationTree.lift` compiles
- `FrameClass.Base <= FrameClass.Dense` and `FrameClass.Base <= FrameClass.Discrete` are provable
- `FrameClass.Dense <= FrameClass.Discrete` is unprovable (as expected)

---

### Phase 2: ProofSystem Layer and Derivable [COMPLETED]

**Goal**: Update all files in `ProofSystem/` that import Derivation.lean, plus the `Derivable` wrapper. After this phase, all of `ProofSystem/` compiles. The key decision is how `Derivable` handles the `fc` parameter.

**Tasks**:
- [x] **2.1** Update `Derivable` in `ProofSystem/Derivable.lean`: *(completed)*
  ```lean
  def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop :=
    Nonempty (DerivationTree fc G p)
  ```
  Update all constructor-mirroring lemmas (`ax`, `assume`, `mp`, `weaken`, `nec`, `temp_nec`, `temp_dual`) to thread `fc`. The `ax` lemma needs an `h_fc` argument:
  ```lean
  theorem Derivable.ax (fc : FrameClass) (G : Context) (p : Formula)
      (h : Axiom p) (h_fc : h.minFrameClass ≤ fc) : Derivable fc G p
  ```
  Add a `Derivable.lift` that wraps `DerivationTree.lift`.

- [x] **2.2** Update notation in Derivable.lean: *(completed)*
  ```lean
  notation:50 G " |-![" fc "] " p => Derivable fc G p
  notation:50 "|-![" fc "] " p => Derivable fc [] p
  notation:50 G " |-! " p => Derivable FrameClass.Base G p
  notation:50 "|-! " p => Derivable FrameClass.Base [] p
  ```

- [x] **2.3** Update `ProofSystem/Substitution.lean` to thread `fc` through all substitution lemmas. The `subst_derivation` function recurses on `DerivationTree` and builds a new one -- add `fc` parameter. *(completed -- also added density case to axiom_subst and axiom_subst_minFrameClass lemma)*

- [x] **2.4** Update `ProofSystem/LinearityDerivedFacts.lean` to thread `fc`. These prove derived theorems using base axioms only, so they become `DerivationTree .Base`. *(completed -- added trivial for h_fc proof)*

- [x] **2.5** Update `ProofSystem.lean` (aggregator) if needed. *(completed -- no changes needed, aggregator only re-exports)*

- [x] **2.6** Verify all of `ProofSystem/` compiles: `lake build Bimodal.ProofSystem`. *(completed -- 661 jobs, passes cleanly)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivable.lean` -- Parameterize Derivable, update notation and lemmas
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- Thread `fc` through substitution
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- Thread `fc`
- `Theories/Bimodal/ProofSystem.lean` -- Update aggregator if needed

**Verification**:
- `lake build Bimodal.ProofSystem` passes
- `Derivable.ax` requires `h_fc` proof
- `Derivable.lift` compiles
- All aesop/simp examples in Derivable.lean still work

---

### Phase 3: Theorems Layer (Mechanical, Base-Only) [COMPLETED]

**Goal**: Update all files in `Theorems/` to use `DerivationTree .Base`. These files construct derivation trees using only base axioms, so the `h_fc` obligation is always `le_refl`. This is the largest batch of files by count (10 files) but the changes are mechanical: add `(fc := .Base)` or let Lean infer it from the `le_refl` proofs.

**Tasks**:
- [x] **3.1** Update `Theorems/Propositional.lean` (135 DerivationTree refs). *(completed -- added trivial to all DerivationTree.axiom calls)*

- [x] **3.2** Update `Theorems/Combinators.lean` (58 refs). *(completed -- added trivial to 30 axiom calls)*

- [x] **3.3** Update `Theorems/TemporalDerived.lean`. *(completed -- added trivial to 12 axiom calls)*

- [x] **3.4** Update `Theorems/GeneralizedNecessitation.lean`. *(completed -- added trivial to 3 axiom calls)*

- [x] **3.5** Update `Theorems/ModalS4.lean` and `Theorems/ModalS5.lean`. *(completed -- 9 and 11 axiom calls respectively)*

- [x] **3.6** Update `Theorems/Perpetuity/Bridge.lean` (63 refs), `Theorems/Perpetuity/Helpers.lean`, and `Theorems/Perpetuity/Principles.lean` (55 refs). *(completed -- Helpers.lean: axiom_in_context, apply_axiom_to, apply_axiom_in_context made fc-polymorphic with h_fc parameter)*

- [x] **3.7** Update `Syntax/BigConj.lean` (if it references DerivationTree -- check). *(completed -- no DerivationTree refs, only a comment)*

- [x] **3.8** Verify: `lake build Bimodal.Theorems`. *(completed -- all Theorems files compile, also Metalogic/Core/DeductionTheorem.lean made fc-polymorphic as a dependency)* *(deviation: altered -- DeductionTheorem.lean was updated here instead of Phase 5 because it's a transitive dependency of Propositional.lean)*

**Pattern for all files**: For axiom invocations `DerivationTree.axiom G f h`, add the `h_fc` proof. Since all axioms used in Theorems/ are base axioms, the proof is `le_refl` or `by decide`. If the `|- f` notation defaults to `.Base`, most type signatures are unchanged. Where functions are polymorphic in the derivation tree, decide whether they should be polymorphic in `fc` (e.g., a function that only uses modus ponens and weakening can be `{fc : FrameClass} -> ...`).

**Design Decision**: Theorems proved from only structural rules (no axioms) should be universe-polymorphic in `fc` (e.g., deduction theorem, weakening lemmas). Theorems that use specific axioms should fix `fc` to the minimum required frame class. This maximizes reusability: a propositional tautology proved at `.Base` can be lifted to `.Dense` or `.Discrete` via `lift`.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Theorems/Propositional.lean` -- Thread `fc`, add `le_refl` proofs
- `Theories/Bimodal/Theorems/Combinators.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/ModalS4.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/ModalS5.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean` -- Thread `fc`
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` -- Thread `fc`
- `Theories/Bimodal/Syntax/BigConj.lean` -- Thread `fc` if needed

**Verification**:
- `lake build Bimodal.Theorems` passes
- All derived theorem signatures reflect correct frame class

---

### Phase 4: Soundness Refactor [NOT STARTED]

**Goal**: Rewrite the soundness theorems to use the parameterized `DerivationTree fc`. This is the highest-value phase: three near-duplicate 40-case splits collapse into a single dispatch, and all `h_dc` parameters are removed. The key insight is that `DerivationTree fc G f` structurally guarantees that every axiom node satisfies `ax.minFrameClass <= fc`, so no runtime check is needed.

**Tasks**:
- [ ] **4.1** Add `density_valid` soundness proof for the new density axiom constructor in Soundness.lean. The existing `density_valid` theorem (line 367) proves validity on dense frames. Wire it into the axiom case split: `| density _ => exact density_valid ...`.

- [ ] **4.2** Create a unified `axiom_valid` dispatch lemma. For any `(ax : Axiom φ)` and frame class `fc` with `ax.minFrameClass <= fc`, dispatch to the appropriate validity proof based on `fc`:
  ```lean
  theorem axiom_valid_fc {φ : Formula} (ax : Axiom φ) (fc : FrameClass)
      (h_fc : ax.minFrameClass ≤ fc)
      -- frame constraints depending on fc ...
      : truth_at M Omega τ t φ
  ```
  This replaces the three separate 40-case matches.

- [ ] **4.3** Rewrite `soundness` to remove `h_dc`:
  ```lean
  theorem soundness (fc : FrameClass) (Γ : Context) (φ : Formula)
      (d : DerivationTree fc Γ φ)
      -- appropriate frame constraints for fc --
      : truth_at M Omega τ t φ
  ```
  The axiom case uses `h_fc` from the constructor directly, passing it to `axiom_valid_fc`. No more `absurd h_dc` for excluded axioms -- they cannot appear by construction.

- [ ] **4.4** Rewrite `soundness_dense` and `soundness_discrete` as corollaries of the unified `soundness`:
  ```lean
  theorem soundness_dense := soundness .Dense
  theorem soundness_discrete := soundness .Discrete
  ```
  Or define them as thin wrappers that instantiate the unified theorem.

- [ ] **4.5** Rewrite `soundness_dense_valid` and `soundness_discrete_valid`:
  ```lean
  theorem soundness_dense_valid {φ : Formula}
      (d : DerivationTree .Dense [] φ) : valid_dense φ
  ```
  No more `h_dc` parameter.

- [ ] **4.6** Update `SoundnessLemmas.lean`. The 4 near-duplicate blocks (axiom_locally_valid, axiom_swap_valid, axiom_locally_valid_general, axiom_swap_valid_general) each contain 40-case splits with `h_dc` guards. Restructure:
  - Replace `h_dc : h.isDenseCompatible` with the structural `h_fc : h.minFrameClass <= fc` from the DerivationTree.
  - The `prior_UZ/prior_SZ/z1 => absurd h_dc ...` branches become unreachable (they cannot appear in a `.Dense` tree). For a unified version, dispatch on `fc`.
  - The `derivable_valid_and_swap_valid` mutual induction removes `h_dc` threading.

- [ ] **4.7** Update `DenseSoundness.lean` and `DiscreteSoundness.lean` (thin wrappers):
  - Remove `h_dc` from re-exported theorems
  - May simplify to trivial aliases or be candidates for deletion

- [ ] **4.8** Verify: `lake build Bimodal.Metalogic.Soundness`, `lake build Bimodal.Metalogic.SoundnessLemmas`, `lake build Bimodal.Metalogic.DenseSoundness`, `lake build Bimodal.Metalogic.DiscreteSoundness`.

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Rewrite 3 soundness theorems, remove h_dc
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Collapse 4 duplicate blocks, remove h_dc
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` -- Simplify or remove h_dc wrappers
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` -- Simplify or remove h_dc wrappers

**Verification**:
- All 4 soundness files compile
- `soundness` no longer takes `h_dc` parameter
- `density_valid` is wired to the `density` axiom constructor
- The 40-case axiom match appears only once (or is factored into a dispatch lemma)
- No `isDenseCompatible` or `isDiscreteCompatible` references remain in these files

---

### Phase 5: Metalogic Core and Completeness [NOT STARTED]

**Goal**: Update the MCS/consistency infrastructure, deduction theorem, completeness theorems, and all remaining Metalogic/ files. The `Consistent` and `MaximalConsistent` definitions use `DerivationTree` and need the `fc` parameter. The completeness theorems need to produce `DerivationTree fc [] f` for appropriate `fc`.

**Tasks**:
- [ ] **5.1** Update `Core/MaximalConsistent.lean`:
  - Parameterize `Consistent`:
    ```lean
    def Consistent (fc : FrameClass) (Γ : Context) : Prop :=
      ¬Nonempty (DerivationTree fc Γ Formula.bot)
    ```
  - Similarly parameterize `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`.
  - The default for backwards compatibility: keep `Consistent` defaulting to `.Base` if possible, or require explicit `fc` everywhere.
  - **Design choice**: Since Base-inconsistency implies fc-inconsistency (via lift: if `DerivationTree .Base G bot` exists, then `DerivationTree fc G bot` exists for any fc >= .Base), and all fc >= .Base, we have: Base-inconsistent => fc-inconsistent for all fc. But the completeness proofs need fc-indexed consistency. Therefore parameterize `Consistent` by `fc`.

- [ ] **5.2** Update `Core/MCSProperties.lean` to thread `fc` through all MCS lemmas. This file has 40+ lemmas about MCS properties (negation, disjunction, membership). Thread `fc` as an implicit parameter.

- [ ] **5.3** Update `Core/RestrictedMCS.lean` (74 refs). Thread `fc`.

- [ ] **5.4** Update `Core/DeductionTheorem.lean`. The deduction theorem is structural (no axiom-specific reasoning), so it should be polymorphic in `fc`:
  ```lean
  theorem deduction_theorem {fc : FrameClass} ...
  ```

- [ ] **5.5** Update `BXCanonical/Completeness.lean`:
  - `completeness` returns `Nonempty (DerivationTree .Base [] φ)` (base completeness)
  - `completeness_dense` returns `Nonempty (DerivationTree .Dense [] φ)` (dense completeness)
  - `completeness_discrete` returns `Nonempty (DerivationTree .Discrete [] φ)` (discrete completeness)
  - The `neg_consistent_of_not_derivable` lemma needs to use fc-indexed consistency.

- [ ] **5.6** Update `Metalogic/Completeness.lean` (67 refs, MCS modal properties).

- [ ] **5.7** Update all BXCanonical/ files (Frame.lean, CanonicalChain.lean, CanonicalModel.lean, TruthLemma.lean, OrderedSeedConsistency.lean, Quasimodel/*.lean, Filtration/*.lean). These use `DerivationTree` via `Consistent`/`MCS` -- once 5.1-5.2 are done, these files need `fc` threading.

- [ ] **5.8** Update all Chronicle/ files (ChronicleTypes.lean, ChronicleConstruction.lean, ChronicleToCountermodel.lean, CounterexampleElimination.lean, PointInsertion.lean, RRelation.lean). These construct countermodels using MCS -- thread `fc`.

- [ ] **5.9** Update Bundle/ files (Construction.lean, ModalSaturation.lean, SuccRelation.lean, TemporalCoherence.lean, TemporalContent.lean, WitnessSeed.lean). Thread `fc`.

- [ ] **5.10** Update WeakCanonical/ files (ChronicleExtraction.lean, FrameProperties.lean, ReflexiveCanonical.lean, TruthLemma.lean). Thread `fc`.

- [ ] **5.11** Update Algebraic/ files (AlgebraicCompleteness.lean, BooleanStructure.lean, InteriorOperators.lean, LindenbaumQuotient.lean, ParametricCompleteness.lean, ParametricTruthLemma.lean, RestrictedParametricTruthLemma.lean, UltrafilterMCS.lean). Thread `fc`.

- [ ] **5.12** Verify: `lake build Bimodal.Metalogic`.

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` -- Parameterize Consistent/MCS
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` -- Thread `fc`
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` -- Thread `fc`
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` -- Thread `fc`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Update return types
- `Theories/Bimodal/Metalogic/Completeness.lean` -- Thread `fc`
- `Theories/Bimodal/Metalogic/BXCanonical/*.lean` (6 files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/*.lean` (6 files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/*.lean` (3 files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/*.lean` (1+ files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/Bundle/*.lean` (6 files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/WeakCanonical/*.lean` (4 files) -- Thread `fc`
- `Theories/Bimodal/Metalogic/Algebraic/*.lean` (8 files) -- Thread `fc`

**Verification**:
- `lake build Bimodal.Metalogic` passes
- Completeness theorems return correctly parameterized DerivationTree
- Consistent/MCS are parameterized by fc

---

### Phase 6: FrameConditions, Decidability, Automation, and ConservativeExtension [NOT STARTED]

**Goal**: Update all remaining modules outside Metalogic/ and Theorems/. This includes FrameConditions (remove h_dc wrappers), Decidability (FMP, decision procedure, proof extraction), Automation (proof search, tactics, aesop rules), and ConservativeExtension (ExtDerivation). After this phase, `lake build` passes for the entire project.

**Tasks**:
- [ ] **6.1** Update `FrameConditions/Soundness.lean` (14 h_dc refs):
  - Remove `h_dc` from `soundness_over`, `soundness_linear`, `soundness_dense_fc`, `soundness_discrete_fc`
  - These become thin wrappers over the unified soundness theorem

- [ ] **6.2** Update `FrameConditions/Compatibility.lean`:
  - Remove `AxiomLinearCompatible`, `AxiomDenseCompatible`, `AxiomDiscreteCompatible` typeclasses
  - These are superseded by the structural `minFrameClass <= fc` constraint
  - File may be deleted entirely or reduced to a compatibility shim

- [ ] **6.3** Update `FrameConditions/Validity.lean` and `FrameConditions/FrameClass.lean` if needed.

- [ ] **6.4** Update `Decidability/*.lean` files:
  - `Decidability/DecisionProcedure.lean` -- proof search constructs DerivationTree; add fc
  - `Decidability/ProofExtraction.lean` -- extracts proofs; thread fc
  - `Decidability/Correctness.lean` -- thread fc
  - `Decidability/FMP/*.lean` (ClosureMCS.lean, DenseFMP.lean, DiscreteFMP.lean, FMP.lean, TruthPreservation.lean) -- thread fc through MCS usage
  - `Decidability.lean` aggregator

- [ ] **6.5** Update `Automation/*.lean`:
  - `Automation/ProofSearch.lean` -- builds DerivationTree; add fc parameter, likely defaults to `.Base` since proof search uses base axioms
  - `Automation/Tactics.lean` -- tactic infrastructure; thread fc
  - `Automation/AesopRules.lean` -- aesop integration; thread fc

- [ ] **6.6** Update `ConservativeExtension/ExtDerivation.lean` (26 refs) and `ConservativeExtension/Lifting.lean` (58 refs):
  - `ExtDerivationTree` mirrors `DerivationTree` -- add `fc` parameter
  - `embedDerivation` maps base DerivationTree to ExtDerivationTree -- thread fc
  - `ExtAxiom` mirrors `Axiom` -- add `density` constructor and `minFrameClass`

- [ ] **6.7** Update `Examples/` files if any reference DerivationTree directly.

- [ ] **6.8** Verify: `lake build` (full project).

**Timing**: 4 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Soundness.lean` -- Remove h_dc
- `Theories/Bimodal/FrameConditions/Compatibility.lean` -- Remove/simplify
- `Theories/Bimodal/FrameConditions/Validity.lean` -- Minor updates
- `Theories/Bimodal/FrameConditions/FrameClass.lean` -- Minor updates
- `Theories/Bimodal/Metalogic/Decidability/*.lean` (7 files) -- Thread fc
- `Theories/Bimodal/Automation/*.lean` (3 files) -- Thread fc
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` -- Mirror changes
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` -- Thread fc
- `Theories/Bimodal/Examples/*.lean` -- Thread fc if needed

**Verification**:
- `lake build` passes (full project, zero errors)
- No `isDenseCompatible`, `isDiscreteCompatible`, `isBase`, or `h_dc` references remain in live code
- Decision procedure still works with fc parameter

---

### Phase 7: Documentation and Cleanup [NOT STARTED]

**Goal**: Update README, add module docstrings, verify no ad-hoc predicate references remain, and run final validation.

**Tasks**:
- [ ] **7.1** Update `README.md`:
  - Rename "Serial" frame class references to "Base" where appropriate
  - Document the three axiom systems as additive extensions of Base:
    - Base (37 axioms): valid on all linear orders
    - Dense (38 axioms = Base + density): valid on densely ordered frames
    - Discrete (40 axioms = Base + prior_UZ + prior_SZ + z1): valid on discrete frames
  - Document the `FrameClass` partial order
  - Update axiom counts (41 total constructors now)

- [ ] **7.2** Add module-level docstrings explaining the design intent:
  - On `FrameClass`: explain the partial order and its semantic meaning
  - On `DerivationTree`: explain why `fc` is a parameter and what `h_fc` enforces
  - On `DerivationTree.lift`: explain the monotonicity principle
  - On the notation: explain `|- f` vs `|-[fc] f`

- [ ] **7.3** Search for any remaining references to removed definitions:
  ```bash
  grep -rn "isBase\|isDenseCompatible\|isDiscreteCompatible\|h_dc.*isDense\|h_dc.*isDiscrete" Theories/
  ```
  Fix any stragglers.

- [ ] **7.4** Final full build and verify no sorry regressions:
  ```bash
  lake build
  ```

- [ ] **7.5** Run `#print axioms` on key theorems to verify no sorry leakage:
  - `#print axioms Bimodal.Metalogic.soundness`
  - `#print axioms Bimodal.Metalogic.completeness`
  - `#print axioms Bimodal.Metalogic.Decidability.validity_decidable`

**Timing**: 2 hours

**Depends on**: 5, 6

**Files to modify**:
- `README.md` -- Update documentation
- Various `.lean` files -- Add/update docstrings

**Verification**:
- `lake build` passes
- `grep` for removed definitions returns no hits in live code
- README accurately reflects new architecture
- No sorry regressions

---

## Testing & Validation

- [ ] `lake build` passes after each phase (incremental correctness)
- [ ] No `isDenseCompatible`, `isDiscreteCompatible`, `isBase` references remain in live files after Phase 6
- [ ] No `h_dc` compatibility parameter threading remains in soundness theorems
- [ ] `DerivationTree.lift` correctly lifts Base derivations to Dense and Discrete
- [ ] `density` axiom constructor maps to `FrameClass.Dense` via `minFrameClass`
- [ ] `density_valid` is connected to the density axiom constructor in soundness
- [ ] `completeness`, `completeness_dense`, `completeness_discrete` produce correctly parameterized trees
- [ ] `#print axioms` on soundness/completeness shows no sorry regressions from this refactor
- [ ] Notation `|- f` still works for base derivations (backwards compatibility)
- [ ] `|-[.Dense] f` notation works for dense derivations
- [ ] All 41 axiom constructors have correct `minFrameClass` classification
- [ ] `FrameClass` partial order satisfies: Base <= Dense, Base <= Discrete, Dense /= Discrete

## Artifacts & Outputs

- `specs/168_parameterize_derivationtree_over_frameclass/plans/01_implementation-plan.md` (this file)
- Modified files across `Theories/Bimodal/` (47 live files, ~1000-1600 lines changed)
- Updated `README.md`
- Module docstrings on `FrameClass`, `DerivationTree`, `lift`, notation

## Rollback/Contingency

Git provides full rollback capability. Since each phase is designed to leave `lake build` passing (except Phase 1 which intentionally breaks downstream files), reverting the most recent phase's commits restores a buildable state. For a full rollback, revert all commits tagged with `task 168:`.

If the refactor proves too disruptive mid-execution:
- **Phase 1 partial**: Revert Axioms.lean and Derivation.lean changes
- **Phase 2-3 partial**: These are mechanical; any partially applied changes leave specific files broken but others unaffected
- **Phase 4 partial**: Soundness files are self-contained; revert soundness changes independently
- **Phase 5 partial**: MCS/completeness changes cascade but follow the same import DAG as the forward direction
