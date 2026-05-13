# Implementation Plan: Task #129

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Status**: [NOT STARTED]
- **Effort**: 40 hours
- **Dependencies**: Task 123 (Z1 axiom + soundness infrastructure, completed)
- **Research Inputs**: specs/129_weak_reflexive_completeness_conservative_extension/reports/01_weak-reflexive-findings.md
- **Artifacts**: plans/01_weak-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Develop the Doets-style weak/reflexive completeness proof for the integer temporal logic TM. The strict semantics remains primary and unchanged; the weak canonical model is an intermediate proof technique. The approach builds a standard Henkin canonical model for the weak system (reflexive R, standard truth lemma), applies Doets compression (quotient, expand to Z-shapes, compress via Z1 maximum principle) to produce a countermodel on Z with strict `<`, and then uses a 10-line model-theoretic transfer to establish strict completeness. The final deliverable is closing the sorry at `limitDomSubtype_isSuccArchimedean` in `ChronicleToCountermodel.lean`.

### Research Integration

Key findings from `reports/01_weak-reflexive-findings.md`:
- The weak canonical model bypasses the definability gap that blocks the chronicle approach (Section 8). Each canonical model point is a distinct MCS, so all non-trivial subsets are approximated by definable ones, making Z1 yield full IsSuccArchimedean.
- Doets compression (Claims 9-11) produces a model on Z with strict `<` directly, making the conservative extension a 10-line observation (Section 4).
- G_w(phi) -> phi is valid under reflexive semantics, so Z1 collapses to FG_w(phi) -> G_w(phi) -- trivially true (Section 5).
- Existing infrastructure (SetMaximalConsistent, set_lindenbaum, DerivationTree, Axiom type with Z1/Prior-UZ) is reusable.
- Only the discrete/integer completeness path is affected; all soundness theorems, dense completeness, and FMP completeness are untouched.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the critical-path sorry in the discrete completeness branch (ROADMAP.md: "1 sorry remains (task 122)" which depends on task 123/129). Closing `limitDomSubtype_isSuccArchimedean` unblocks:
- Task 122 (nondense BFMCS)
- Task 130 (Boneyard archival of dead-end proofs)
- Full `bx_completeness` sorry-free status

## Goals & Non-Goals

**Goals**:
- Define weak temporal operators (G_w, H_w, F_w, P_w) as derived operators on the existing Formula type
- Prove weak axioms are derivable in the strict system
- Build a standard Henkin canonical model for the weak system with a sorry-free truth lemma
- Implement Doets compression (quotient + Z-shape expansion + Z1 maximum principle) to produce a Z-model with strict `<`
- Prove the model-theoretic transfer: strict validity implies provability
- Close the sorry at `limitDomSubtype_isSuccArchimedean` in `ChronicleToCountermodel.lean`

**Non-Goals**:
- Modifying the Formula type, Axiom type, or truth_at definitions
- Changing any soundness theorems
- Altering the dense completeness branch
- Replacing the chronicle construction (it remains as-is; the weak approach supplements it)
- Full formalization of Doets Claim 11 (we need only the restriction to the target formula's quantifier rank)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Henkin truth lemma for Until/Since in weak system may require non-trivial witnessing | H | M | Follow Blackburn-de Rijke-Venema 2002 standard construction; Until/Since witnesses exist by Lindenbaum in the reflexive setting |
| n-characteristic / quantifier rank infrastructure is novel Lean code (~300 lines) | M | M | Define minimally: only what Doets compression needs, not a full Ehrenfeucht framework |
| Doets expansion (Claim 9) requires Z-shape model construction with careful order management | H | M | Keep the construction concrete: Z-indexed sequences with explicit successor/predecessor, not abstract order embeddings |
| Integration with existing `ChronicleToCountermodel.lean` may require refactoring sorry site signature | M | L | The sorry site accepts `SetMaximalConsistent A`; the transfer theorem produces the same type |
| Compilation time may increase significantly with ~1500 new lines of Lean | L | M | Use separate files in `Metalogic/WeakCanonical/` directory; import only what is needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel (this plan is fully sequential).

---

### Phase 1: Weak Sub-Language Definition [NOT STARTED]

**Goal**: Define the weak temporal operators G_w, H_w, F_w, P_w as derived (definitional) operators on the existing Formula type, along with weak Until/Since if needed.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/`
- [ ] Create `WeakCanonical/WeakOperators.lean` defining:
  - `G_w (φ : Formula) : Formula := φ.conj (Formula.all_future φ)` (i.e., `φ ∧ Gφ`)
  - `H_w (φ : Formula) : Formula := φ.conj (Formula.all_past φ)` (i.e., `φ ∧ Hφ`)
  - `F_w (φ : Formula) : Formula := φ.disj (Formula.some_future φ)` (i.e., `φ ∨ Fφ`)
  - `P_w (φ : Formula) : Formula := φ.disj (Formula.some_past φ)` (i.e., `φ ∨ Pφ`)
- [ ] Prove basic equivalences: `G_w φ ↔ φ ∧ G φ`, `F_w φ ↔ φ ∨ F φ`, etc. (trivial by definition)
- [ ] Prove semantic characterization: `truth_at M t (G_w φ) ↔ ∀ s, t ≤ s → truth_at M s φ` for reflexive frames (and dually for H_w, F_w, P_w)
- [ ] Create `WeakCanonical.lean` root import file

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakOperators.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` - NEW (root import)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.WeakOperators` compiles without errors
- All weak operator definitions type-check and basic lemmas proven

---

### Phase 2: Weak Axiom System [NOT STARTED]

**Goal**: Establish that all axioms needed for the weak system are derivable in the strict system. This includes showing weak BX axioms (with G_w replacing G, etc.) are strict theorems.

**Tasks**:
- [ ] Create `WeakCanonical/WeakAxioms.lean` defining the set of weak axioms
- [ ] Prove `G_w φ → φ` is a strict theorem (propositional tautology: `(φ ∧ Gφ) → φ`)
- [ ] Prove weak K axiom: `G_w(φ → ψ) → (G_w φ → G_w ψ)` is a strict theorem
- [ ] Prove weak temporal linearity axioms (BX11 weak variants) are strict theorems
- [ ] Prove weak Z1: `FG_w φ → G_w φ` is a strict theorem (since Z1 + reflexivity gives this)
- [ ] Prove weak Prior-UZ variants are strict theorems
- [ ] Create `weak_axioms_are_strict_theorems` -- master lemma stating all weak axioms derive from the strict axiom set
- [ ] Prove the consistency transfer: if `S` is consistent in the strict system and only contains weak axiom instances, then `S` is consistent in the weak system

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakAxioms.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.WeakAxioms` compiles without errors
- Each weak axiom has a corresponding strict derivation tree

---

### Phase 3: Weak Henkin Canonical Model [NOT STARTED]

**Goal**: Build the standard Henkin canonical model for the weak axiom system. This is the main construction phase. The model has reflexive R, and the truth lemma works by standard Henkin arguments with no witness-distinctness issues.

**Tasks**:
- [ ] Create `WeakCanonical/WeakMCS.lean`:
  - Define `WeakConsistent (S : Set Formula)` using the weak derivation notion
  - Define `WeakMaximalConsistent (S : Set Formula)` (MCS for the weak system)
  - Prove weak Lindenbaum lemma: every weakly consistent set extends to a weak MCS (reuse `set_lindenbaum` infrastructure from `Core/MaximalConsistent.lean`)
  - Prove standard MCS properties: membership iff derivability, negation dichotomy, conjunction/disjunction distribution
- [ ] Create `WeakCanonical/WeakCanonicalModel.lean`:
  - Define the domain: `WeakCanDomain := { S : Set Formula // WeakMaximalConsistent S }`
  - Define the accessibility relation: `x R y ↔ ∀ φ, G_w φ ∈ x.val → φ ∈ y.val` (reflexive by `G_w φ → φ` axiom)
  - Define the valuation: `V(p) = { x | Formula.atom p ∈ x.val }`
  - Prove R is a reflexive preorder (reflexive from T axiom, transitive from 4-like axiom `G_w φ → G_w(G_w φ)`)
  - Prove R is linear (from weak BX11 linearity axioms)
- [ ] Create `WeakCanonical/WeakTruthLemma.lean`:
  - Prove the truth lemma by structural induction on formulas:
    - Atom case: by definition of valuation
    - Bot case: by MCS consistency
    - Imp case: by MCS maximality + modus ponens
    - Box case: by S5 canonical model construction (reuse existing infrastructure)
    - G_w case forward: `G_w φ ∈ x → ∀ y ≥ x, φ ∈ y` (by definition of R)
    - G_w case backward: `G_w φ ∉ x → ∃ y ≥ x, φ ∉ y` (by Lindenbaum: extend `{ψ | G_w ψ ∈ x} ∪ {¬φ}` to weak MCS)
    - H_w case: symmetric to G_w
    - F_w, P_w cases: dual to G_w, H_w
    - Until case: forward by MCS membership + R witnesses; backward by Lindenbaum
    - Since case: symmetric to Until
  - Verify truth lemma is sorry-free
- [ ] Prove the canonical frame satisfies weak Z1 (Sahlqvist canonicity argument: Z1 is Sahlqvist, canonical frame validates all axioms including Z1)

**Timing**: 12 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonicalModel.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakTruthLemma.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.WeakTruthLemma` compiles without errors
- Truth lemma is sorry-free
- Canonical frame validates Z1 (sorry-free)

---

### Phase 4: Doets Compression to Z [NOT STARTED]

**Goal**: Implement the Doets compression pipeline that transforms the weak canonical model (reflexive preorder on weak MCS) into a model on Z with strict `<`. This follows Doets 1987 Claims 9-11.

**Tasks**:
- [ ] Create `WeakCanonical/NCharacteristic.lean`:
  - Define quantifier rank / formula depth for the target formula
  - Define n-characteristic (the propositional type at depth n): `n_char (n : Nat) (x : WeakCanDomain) := { φ : Formula | depth φ ≤ n ∧ φ ∈ x.val }`
  - Prove n-characteristics form a finite partition of the domain (finiteness from bounded formula depth)
  - Prove: two points with the same n-characteristic satisfy the same formulas of depth ≤ n
- [ ] Create `WeakCanonical/DoetsQuotient.lean` (Doets Claim 9, Step 1-2):
  - Define equivalence relation: `x ~ y ↔ x R y ∧ y R x`
  - Quotient the canonical model by ~
  - Prove the quotient order is a strict linear order on equivalence classes
  - Prove truth of formulas (up to relevant depth) depends only on the equivalence class
- [ ] Create `WeakCanonical/DoetsExpansion.lean` (Doets Claim 9, Step 3):
  - Define Z-shape expansion: replace each equivalence class `[x]` with a Z-indexed copy preserving all n-characteristics that occur cofinally
  - Prove the expanded model `N = Σ [x]*` has order type "sum of Z's and singletons"
  - Prove formula preservation: formulas up to depth n are preserved from the quotient model to the expanded model
- [ ] Create `WeakCanonical/DoetsCompression.lean` (Doets Claim 10-11, Step 4):
  - Use Z1 (maximum principle) to eliminate singleton cells between Z-cells
  - Prove the compressed result is a single Z-shaped model
  - Prove the compressed model has domain isomorphic to Z with strict `<`
  - Prove formula preservation through compression for the target formula

**Timing**: 10 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NCharacteristic.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsQuotient.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsExpansion.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsCompression.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.DoetsCompression` compiles without errors
- The compression pipeline produces a `TaskModel` on Z with strict `<` ordering
- Formula preservation theorem is sorry-free for the target quantifier rank

---

### Phase 5: Model-Theoretic Transfer [NOT STARTED]

**Goal**: Prove the 10-line conservative extension argument: strict validity implies provability, using the Doets compression output as the countermodel construction.

**Tasks**:
- [ ] Create `WeakCanonical/Transfer.lean`:
  - State the transfer theorem: `∀ φ, valid_discrete φ → Nonempty (DerivationTree ∅ φ)`
  - Prove by contrapositive:
    1. Assume `¬ Nonempty (DerivationTree ∅ φ)` (not provable)
    2. Then `{¬φ}` is consistent in the strict system
    3. Since all weak axioms are strict theorems (Phase 2), `{¬φ}` is consistent in the weak system
    4. By weak completeness (Phases 3-4): Doets compression produces model M on Z falsifying φ
    5. M is a discrete IsSuccArchimedean frame (Z with `<`)
    6. M falsifies φ under strict semantics (Doets output is already strict)
    7. Contradiction with `valid_discrete φ`
  - Prove each step corresponds to existing infrastructure
- [ ] Prove auxiliary lemma: Z with standard `<` satisfies `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean`, `Nontrivial` (these are standard Mathlib instances for Z)
- [ ] Prove the Doets Z-model is a valid `TaskModel` under the strict semantics definitions

**Timing**: 4 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` compiles without errors
- Transfer theorem is sorry-free
- The theorem's type matches what the integration in Phase 6 requires

---

### Phase 6: Integration [NOT STARTED]

**Goal**: Wire the transfer theorem into the existing completeness pipeline so that the discrete completeness path uses the new proof.

**Tasks**:
- [ ] Update `WeakCanonical.lean` root import to export the transfer theorem
- [ ] Create `WeakCanonical/Integration.lean` that provides the bridge:
  - Define a wrapper that takes `SetMaximalConsistent A` and `h_discrete` hypotheses (matching the sorry site signature) and produces `IsSuccArchimedean` via the transfer theorem
  - This may require packaging the Doets pipeline into a single entry point: given a consistent set, produce a Z-model
- [ ] Verify the wrapper's type signature matches `limitDomSubtype_isSuccArchimedean`'s requirements in `ChronicleToCountermodel.lean`
- [ ] Add import of `WeakCanonical` to `ChronicleToCountermodel.lean` (or the appropriate completeness file)
- [ ] Update `lakefile.lean` if needed to include the new module in the build

**Timing**: 3 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Integration.lean` - NEW
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` - MODIFY (add exports)
- `Theories/Bimodal/Metalogic/Metalogic.lean` - MODIFY (add import if needed)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Integration` compiles without errors
- The integration wrapper has the correct type to replace the sorry

---

### Phase 7: Close the Sorry [NOT STARTED]

**Goal**: Replace the sorry at `limitDomSubtype_isSuccArchimedean` in `ChronicleToCountermodel.lean` with the proof from the weak canonical model pipeline.

**Tasks**:
- [ ] Read the sorry site at `ChronicleToCountermodel.lean` line ~1885 (`succ_cofinal`) and line ~1893 (`limitDomSubtype_isSuccArchimedean`)
- [ ] Replace the `sorry` in `succ_cofinal` (or `limitDomSubtype_isSuccArchimedean`) with a call to the integration wrapper from Phase 6
- [ ] If the sorry site's type does not directly match, add adapter lemmas in `Integration.lean`
- [ ] Run `lake build` on the full project to verify no regressions
- [ ] Verify `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` shows only the `dd_countermodel_chronicle_nondense_sorry` sorry (which is task 122's responsibility) and the mixed-case stub
- [ ] Update comments at the sorry site to reference the weak canonical model proof

**Timing**: 2 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - MODIFY (close sorry)

**Verification**:
- `lake build` succeeds with no new errors
- The `limitDomSubtype_isSuccArchimedean` definition is sorry-free
- `succ_cofinal` is sorry-free (or bypassed by the new proof)
- Total sorry count in the critical path is reduced by 1

---

## Testing & Validation

- [ ] `lake build` succeeds on the full project with no new errors or warnings
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` returns zero results
- [ ] The sorry at `limitDomSubtype_isSuccArchimedean` is closed
- [ ] All existing tests in `Tests/BimodalTest/` continue to pass
- [ ] The transfer theorem type-checks: `valid_discrete φ → Nonempty (DerivationTree ∅ φ)`
- [ ] No changes to `Syntax/`, `ProofSystem/Axioms.lean`, `Semantics/`, or `Soundness*.lean`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/WeakOperators.lean` - Weak operator definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakAxioms.lean` - Weak axiom derivability proofs
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakMCS.lean` - Weak MCS infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonicalModel.lean` - Canonical model construction
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakTruthLemma.lean` - Truth lemma
- `Theories/Bimodal/Metalogic/WeakCanonical/NCharacteristic.lean` - n-characteristic definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsQuotient.lean` - Quotient construction
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsExpansion.lean` - Z-shape expansion
- `Theories/Bimodal/Metalogic/WeakCanonical/DoetsCompression.lean` - Z1 compression
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Conservative extension transfer
- `Theories/Bimodal/Metalogic/WeakCanonical/Integration.lean` - Pipeline bridge to sorry site
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` - Root import file

## Rollback/Contingency

All new code is in the new `WeakCanonical/` directory. The only existing file modified is `ChronicleToCountermodel.lean` (Phase 7, replacing a sorry). If the approach fails:
1. Delete `Theories/Bimodal/Metalogic/WeakCanonical/` entirely
2. Revert the single change to `ChronicleToCountermodel.lean` via `git checkout`
3. The sorry returns to its original state; no other code is affected
4. Alternative: fall back to strengthening the chronicle construction directly (the approach task 123 was exploring before identifying the architectural limitation)
