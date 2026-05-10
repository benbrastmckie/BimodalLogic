# Teammate C Findings: Codebase Architecture Mapping

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Focus**: Architecture mapping against Reynolds/Venema completeness hierarchy
- **Round**: 5
- **Date**: 2026-05-10
- **Session**: sess_1778454477_cdc6ef

## 1. Current Axiom Hierarchy

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean` (415 lines)

The `Axiom` inductive type has 43 constructors organized in 5 layers:

| Layer | Count | Content |
|-------|-------|---------|
| 1. Propositional | 4 | prop_k, prop_s, ex_falso, peirce |
| 2. S5 Modal | 5 | modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist |
| 3. BX Temporal | 28 | BX1-BX14 (future/past pairs), temp_k_dist, temp_4 |
| 4. Modal-Temporal | 2 | modal_future, temp_future |
| 5. Uniformity | 4 | discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd |

**Axiom Classification System**: A `FrameClass` enum exists with constructors `Base`, `Dense`, `Discrete`, but the `Axiom.frameClass` function currently maps ALL axioms to `.Base`. The `isDenseCompatible` and `isDiscreteCompatible` predicates both return `True` for all axioms. This means the frame class system is present as an extension point but is NOT actively used for separation.

**Key Observation**: There is NO density axiom (GGphi -> Gphi) and NO explicit discreteness axiom (like DF/DP) in the current axiom set. The uniformity axioms (Layer 5) encode discreteness properties but are valid on ALL ordered abelian groups, not just discrete ones. The docstring for `Axiom.frameClass` explicitly states "All BX axioms have frame class Base (valid on all linear orders)."

**Separation Assessment**: The axiom system does NOT cleanly separate base/dense/discrete/complete. All 43 axioms are "base" axioms valid on all ordered abelian groups. Dense vs discrete is currently handled by the MODEL construction (Cantor iso vs Z-iso) rather than by the axiom system.

## 2. Current Completeness Structure

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (229 lines)

`bx_completeness` proves: `valid phi -> Nonempty (DerivationTree [] phi)`.

**Proof structure (contrapositive)**:
1. Assume phi not derivable
2. `neg_consistent_of_not_derivable`: {neg phi} is consistent
3. Lindenbaum extension to MCS M containing neg phi
4. **Case split** on `box(F'T)` membership in M (where F'T = neg(U(T,bot))):
   - **Dense case** (`box(F'T) in M`): Routes to `dd_countermodel_chronicle_dense` -- builds countermodel over Rat via Cantor iso
   - **Non-dense case** (`neg box(F'T) in M`): Routes to `dd_countermodel_chronicle_nondense_sorry` -- **SORRY**

**Location of sorries on the critical path**:
- `dd_countermodel_chronicle_nondense_sorry` at ChronicleToCountermodel.lean:833 -- the entire non-dense case is sorry
- `limitDomSubtype_isSuccArchimedean` at ChronicleToCountermodel.lean:1068 -- the Z-iso prerequisite

**The case split criterion**: The completeness proof splits on whether `box(neg(U(top,bot)))` is in M. This checks whether ALL box-equivalent MCSs lack immediate successors (dense case) or whether SOME box-equivalent MCS has an immediate successor (non-dense case). The non-dense case is NOT purely "discrete" -- it includes mixed cases where some modal worlds are dense and some are discrete.

## 3. Current Validity Definitions

**File**: `Theories/Bimodal/Semantics/Validity.lean` (315 lines)

Three validity notions exist:

| Definition | Constraints on D | Signature |
|------------|------------------|-----------|
| `valid` | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D` | All ordered abelian groups |
| `valid_dense` | Above + `DenselyOrdered D` | Dense ordered abelian groups |
| `valid_discrete` | Above + `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D`, `IsPredArchimedean D` | Discrete Archimedean ordered abelian groups |

**The AddCommGroup requirement**: `valid` quantifies over `(D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`. This means validity is restricted to ordered abelian groups -- NOT all linear orders. This is by design (see Paper Alignment section: "JPL paper defines validity as truth at all task frames with totally ordered abelian group D").

**Why AddCommGroup?**: The `ShiftClosed` condition and `time_shift_preserves_truth` theorem require additive group structure. `ShiftClosed Omega` says `forall sigma in Omega, forall Delta : D, time_shift sigma Delta in Omega`. The `time_shift` operation uses `D`'s addition. The soundness proofs for MF (`box phi -> box(G phi)`) and TF (`box phi -> G(box phi)`) axioms depend on this.

**Implication for the hierarchy**:
- Base TM completeness = `valid phi -> derivable phi` (needs countermodels over arbitrary ordered abelian groups)
- Dense completeness = `valid_dense phi -> derivable phi` (needs countermodels over dense ordered abelian groups, e.g., Rat)
- Discrete completeness = `valid_discrete phi -> derivable phi` (needs countermodels over Archimedean discrete ordered abelian groups, i.e., Int)

## 4. The AddCommGroup Coupling Analysis

### Where AddCommGroup enters the construction

1. **Semantics layer** (`Truth.lean`, `Validity.lean`): `truth_at` requires `[AddCommGroup D]` via the `TaskFrame D` dependency. The `time_shift` operation on `WorldHistory` uses `D`'s addition.

2. **Soundness layer** (`Soundness.lean`): The uniformity axiom soundness proofs (discrete_symm_fwd_valid etc.) use `D`'s group operations for translation arguments (e.g., "if there's a gap (t, s), then (t-(s-t), t) is also empty").

3. **Parametric canonical model** (`ParametricCanonical.lean`): The task relation uses `D`'s addition to define forward/backward accessibility. The `ParametricCanonicalTaskModel` requires `[AddCommGroup D]`.

4. **Truth lemma** (`ParametricTruthLemma.lean`): Uses `time_shift_preserves_truth` in the shifted truth lemma for the box case. This is the deepest coupling point.

5. **Representation theorem** (`ParametricRepresentation.lean`): Instantiates the construction with specific D values. The table in the header states: Base=Int, Dense=Rat, Discrete=Int.

### Where AddCommGroup is NOT needed

The chronicle construction itself (`ChronicleConstruction.lean`, `CounterexampleElimination.lean`, `PointInsertion.lean`) operates entirely over `Rat` and does NOT use `AddCommGroup`. It produces:
- `limit_dom : Set Rat` (the domain)
- `limit_f : Rat -> Set Formula` (the MCS assignment)
- `limit_forward_G`, `limit_backward_H` (temporal coherence)
- `limit_satisfies_c5_strong`, `limit_satisfies_c5'_strong` (Until/Since coherence)
- `limit_satisfies_c4`, `limit_satisfies_c4'` (counterexample elimination)

The chronicle output is a countable linear order with MCS labels -- no group structure.

### The coupling bottleneck

The conversion from chronicle to countermodel goes through:
```
Chronicle (on Rat subtype) --[iso]--> FMCS on D --[parametric representation]--> TaskModel on D
```

The isomorphism step requires:
- Dense case: `LimitDomSubtype ≃o Rat` (Cantor's theorem) -- works because LimitDomSubtype is dense, countable, without endpoints
- Discrete case: `LimitDomSubtype ≃o Int` (orderIsoIntOfLinearSuccPredArch) -- requires IsSuccArchimedean

The parametric representation step requires D to be an AddCommGroup because `valid` quantifies over AddCommGroup.

## 5. What Exists for the Reynolds/Venema Approach

### Expressive completeness (Kamp's theorem)
**Nothing in the codebase.** No Kamp's theorem, no Stavi connectives, no FO-TL equivalence.

### Monadic first-order logic
**Nothing in the codebase.** No encoding of monadic second-order or first-order temporal formulas.

### Ehrenfeucht-Fraisse games
**Nothing in Mathlib or the codebase.** No game-theoretic equivalence results.

### Doets transfer theorem
**Nothing.** No results on transferring satisfiability between k-equivalent structures.

### Contemporaneous equivalence / definable well-ordering
**Nothing.** No machinery for definability theory within temporal structures.

**Assessment**: Implementing the full Reynolds/Venema approach from scratch would require building ALL of the above infrastructure. None of it exists.

## 6. What Would Need to Change for Prior-UZ

### Adding the axiom

Adding `Fp -> U(p, neg p)` (and its mirror `Pp -> S(p, neg p)`) to `Axioms.lean` would require:

1. **New constructors** in `Axiom`: Two new cases (axiom_W, axiom_W_mirror). Straightforward, ~10 lines.

2. **Soundness on Int**: Proving `Fp -> U(p, neg p)` valid on Int. This requires well-ordering of `{u : Int | u > t}`, which is standard. ~30 lines.

3. **Soundness on valid_discrete**: Proving it valid on all D with `IsSuccArchimedean`. The well-ordering follows from IsSuccArchimedean + discrete. ~30 lines.

4. **NOT sound on valid**: Prior-UZ is NOT valid on all ordered abelian groups (countermodel: Z x Z lex). So it CANNOT be added as a base axiom.

5. **Frame class update**: `FrameClass` would need a new variant or Prior-UZ would need to be classified as `Discrete`-only. The current system where `Axiom.frameClass` returns `.Base` for everything would need restructuring.

6. **Propagation through soundness**: All `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` match clauses would need new cases. ~15 lines per soundness theorem.

**Total for adding the axiom alone: ~100-150 lines across 3-4 files.**

### What this would NOT solve

Adding Prior-UZ as an axiom does not by itself close the sorry. The sorry is at `limitDomSubtype_isSuccArchimedean`, which is about the CONSTRUCTED limit_dom, not about validity on a given frame. Prior-UZ being an axiom means it's in every MCS (including limit_f values), but translating "Prior-UZ holds in every MCS label" into "the underlying linear order is succ-Archimedean" is the content of Reynolds's Theorem 4 + Doets Theorem 9, which are not formalized.

## 7. The ShiftClosed / AddCommGroup Decoupling Question

### Can we restructure to avoid AddCommGroup in the truth lemma?

The truth lemma (`ParametricTruthLemma.lean`) uses AddCommGroup in exactly one place: the box case of `parametric_shifted_truth_lemma`, where `time_shift_preserves_truth` is applied. This theorem requires `ShiftClosed Omega` which requires the additive group structure.

**If we built the model directly on limit_dom (as a countable linear order)**:

- `truth_at` would need a version without `AddCommGroup`. Currently `truth_at` is defined in `Truth.lean` with `[AddCommGroup D]` in the variable declaration. The actual recursive definition does NOT use group operations -- it only uses `<` comparisons. The AddCommGroup is needed ONLY for the `time_shift` operation in `WorldHistory` and the `ShiftClosed` condition.

- The box modality currently quantifies over `sigma in Omega`. If we dropped ShiftClosed and used `Omega = Set.univ`, the box case simplifies to "true at all histories" and no group structure is needed.

- BUT: The soundness of MF and TF axioms (`box phi -> box(G phi)` and `box phi -> G(box phi)`) fundamentally requires ShiftClosed + time_shift. Without it, these axioms are not valid.

**Conclusion**: AddCommGroup is structurally required for soundness. You CANNOT have a sound proof system for TM logic without time-shift invariance (which requires group structure). The Burgess/chronicle construction must eventually produce a model over an ordered abelian group.

### Alternative: Build the model on limit_dom with a TRANSFER step

Conceptually possible:
1. Chronicle produces limit_dom (countable linear order)
2. Truth lemma proved on limit_dom using only `<` (no group structure, no box)
3. Transfer to Rat (dense) or Int (discrete) via isomorphism
4. Re-prove truth on the transferred model (where AddCommGroup applies)

But step 2 fails because the truth lemma needs the box case, and the box case requires histories/Omega.

### The current approach is essentially correct

The current architecture (build on limit_dom, iso to D, parametric representation on D) is the right approach. The problem is specifically at the iso step for the discrete case: proving `LimitDomSubtype ≃o Int` requires IsSuccArchimedean.

## 8. Refactoring Scope Estimate

### If pursuing Reynolds/Venema fully

| Component | Files Changed | New Files | Lines (est.) |
|-----------|--------------|-----------|-------------|
| Axiom W + soundness | Axioms.lean, Soundness.lean, FrameClass.lean, FrameConditions/*.lean | - | 150 |
| Stavi connectives (U', S') definition | - | StaviConnectives.lean | 200 |
| Definable well-ordering (Venema 4.1) | - | DefinableWellOrdering.lean | 300 |
| EF games infrastructure | - | EFGames.lean | 400 |
| Doets transfer (discrete) | - | DoetsTransfer.lean | 500 |
| k-equivalence machinery | - | KEquivalence.lean | 300 |
| Integration with completeness | ChronicleToCountermodel.lean, Completeness.lean | - | 200 |
| **Total** | **~4 files** | **~5 new files** | **~2050** |

This is a substantial effort -- approximately 3-4% of the current 62,000-line codebase (excluding Boneyard).

### If pursuing direct IsSuccArchimedean proof

| Component | Files Changed | Lines (est.) |
|-----------|--------------|-------------|
| birth_stage infrastructure | ChronicleToCountermodel.lean | 80 |
| Birth-monotonicity lemma | ChronicleToCountermodel.lean | 100 |
| Main IsSuccArchimedean proof | ChronicleToCountermodel.lean | 50 |
| **Total** | **1 file** | **~230** |

This is < 0.5% of the codebase. The plan (`01_lex-pair-proof.md`) estimates 5 hours. However, prior attempts (task 118) have failed, suggesting the proof may be harder than the line count implies.

### If adding Axiom W + direct application (minimal Venema)

A middle path: add Axiom W, prove soundness on Int, then prove IsSuccArchimedean for limit_dom using Prior-UZ membership in the MCS labels (without full Doets/EF machinery):

| Component | Files Changed | Lines (est.) |
|-----------|--------------|-------------|
| Axiom W + soundness | Axioms.lean, Soundness.lean, FrameClass.lean | 100 |
| Prior-UZ => well-ordering above point | ChronicleToCountermodel.lean | 150 |
| Well-ordering => IsSuccArchimedean | ChronicleToCountermodel.lean | 80 |
| **Total** | **~3 files** | **~330** |

This path is worth investigating further -- if Prior-UZ membership in MCS labels directly implies that the succ-chain reaches every element, it would be the most efficient approach.

## 9. Sorry Inventory (Active Code, Excluding Boneyard)

### Critical-path sorries (block completeness)

| File | Line | Description |
|------|------|-------------|
| ChronicleToCountermodel.lean | 833 | `dd_countermodel_chronicle_nondense_sorry` -- entire non-dense case |
| ChronicleToCountermodel.lean | 1068 | `limitDomSubtype_isSuccArchimedean` -- Z-iso prerequisite |

### Non-critical-path sorries

| Category | Count | Files |
|----------|-------|-------|
| TemporalDerived.lean | 18 | Derived temporal theorem stubs |
| Examples | 10 | Example/demo proofs |
| Bundle modules | 5 | SuccExistence, SuccRelation |
| Frame.lean | 1 | bx_le_refl (reflexivity under irreflexive semantics) |
| TruthLemma.lean (old) | 2 | Until/Since cases in non-restricted truth lemma |
| Filtration/Quasimodel | 8 | Alternative construction attempts |
| ConservativeExtension | ~12 | Axiom mapping between old/new systems |

**Total active sorries: ~56** (of which only 2 are on the critical completeness path).

## 10. Summary Assessment

**Current architecture is sound for the target hierarchy.** The layered design (Axioms -> Soundness -> Chronicle -> Iso -> Representation -> Completeness) is well-structured. The `valid`/`valid_dense`/`valid_discrete` separation exists and is correctly defined.

**The sole blocker for discrete completeness is the IsSuccArchimedean sorry at ChronicleToCountermodel.lean:1068.** Everything else in the discrete pipeline is built out (SuccOrder, PredOrder, discrete_iso, discrete_fmcs, transport lemmas).

**The Reynolds/Venema approach (full formalization) is estimated at ~2000 lines across ~5 new files.** This is feasible but represents a major infrastructure investment that goes well beyond the immediate IsSuccArchimedean problem.

**Adding Axiom W alone does not close the sorry** -- it just gives a stronger hypothesis to work with. The mathematical content of "Prior-UZ in MCS labels implies succ-chain reachability" still needs to be proved.

**The direct lex-pair approach (existing plan, ~230 lines) remains the shortest path** if the birth-monotonicity lemma can be proved. The key question is whether the C5 walk's sealing property provides sufficient control over where new domain points appear.

**Dedekind-complete (Real) completeness is not attempted and requires density completeness as a prerequisite.** The density completeness has its own sorry (the `dd_countermodel_chronicle_dense` path is NOT fully sorry-free; the sorry at ChronicleToCountermodel.lean:833 covers both dense and non-dense through the nondense_sorry stub; but the dense-specific path `dd_countermodel_chronicle_dense` IS sorry-free based on the code comments at line 786).
