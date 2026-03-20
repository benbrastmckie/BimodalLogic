# Implementation Plan: Task #1006 (v2)

- **Task**: 1006 - canonical_taskframe_completeness
- **Version**: 02 (streamlined approach)
- **Status**: [NOT STARTED]
- **Effort**: 5 hours (reduced from 6h via simplification)
- **Dependencies**: None (supersedes task 997)
- **Research Inputs**:
  - `01_team-research.md` - Initial research (BFMCS construction approach)
  - `02_direct-construction.md` - Streamlined approach (global enumeration)
  - `03_dense-discrete-compatibility.md` - D-polymorphism analysis
- **Artifacts**: `plans/02_streamlined-bfmcs-plan.md` (this file)
- **Type**: lean4

## Overview

Replace the FlagBFMCS `satisfies_at` relation with a canonical TaskFrame construction using `truth_at`. The **streamlined approach** from supplemental research uses:

1. **Global countable enumeration**: Single `enum_mcs : CanonicalMCS -> Int` (not per-Flag)
2. **Root MCS fallback**: Out-of-range times map to `root_mcs` (evaluation point)
3. **Maximum parametric reuse**: `ParametricCanonicalTaskFrame`, `parametric_to_history`, `parametric_canonical_truth_lemma`
4. **D-polymorphic design**: Construction generalizes to Rat/Int for dense/discrete

### Key Changes from v1

| Aspect | v1 (Original) | v2 (Streamlined) |
|--------|---------------|------------------|
| Embedding | Per-Flag order-preserving | Global countable enumeration |
| Complexity | O(|Flags|) embeddings | Single global embedding |
| Fallback | Boundary handling per-Flag | Root_mcs for all out-of-range |
| D-polymorphism | Fixed to Int | Designed for generalization |
| Estimated effort | 6 hours | 5 hours |

## Goals & Non-Goals

**Goals**:
- Construct `BFMCS Int` from `FlagBFMCS` using global enumeration
- Prove completeness using `valid` (not `satisfies_at`)
- Design with D-polymorphism for future dense/discrete reuse (90%+ code sharing)
- Eliminate `satisfies_at` from the completeness proof path

**Non-Goals**:
- Implement dense (D=Rat) or discrete (D=Int+SuccOrder) — those are separate tasks
- Remove `satisfies_at` definition entirely (may be useful elsewhere)
- Modify existing parametric infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Countable CanonicalMCS proof | M | L | Use `Countable Formula` transitively; or axiomatize initially |
| Modal coherence transfer | M | L | `modally_saturated` is semantically equivalent to `modal_forward/backward` |
| Root_mcs fallback breaks temporal coherence | M | L | `temporally_complete` ensures witnesses exist; fallback is type-correctness only |

## Implementation Phases

### Phase 1: Global Countable Enumeration [COMPLETED]

**Goal**: Define single global injection `enum_mcs : CanonicalMCS -> Int`.

**Tasks**:
- [ ] Create `FlagBFMCSIntBundle.lean` in `Theories/Bimodal/Metalogic/Bundle/`
- [ ] Establish `Countable CanonicalMCS` instance (via `Countable Formula`)
- [ ] Define `enum_mcs : CanonicalMCS -> Int` using `Encodable.encode` or enumeration
- [ ] Prove `enum_mcs` is injective: `enum_mcs M = enum_mcs N -> M = N`
- [ ] Define inverse partial function for lookup

**Implementation Sketch**:
```lean
-- Option A: Direct from Encodable
instance : Countable CanonicalMCS := Countable.of_equiv _ (...)
noncomputable def enum_mcs : CanonicalMCS -> Int := fun M => Encodable.encode M

-- Option B: Via decidable enumeration
noncomputable def enum_mcs : CanonicalMCS -> Int :=
  fun M => Nat.find (exists_encode_canonical M)
```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean` - new file

**Verification**:
- `enum_mcs` is injective
- `lake build` passes with no `sorry`

---

### Phase 2: Per-Flag FMCS Int Construction [BLOCKED]

**Goal**: Convert `chainFMCS F : FMCS (ChainFMCSDomain F)` to `FMCS Int` using global enumeration.

**Tasks**:
- [ ] Define `domain_image F : Set Int := { enum_mcs M.val | M : ChainFMCSDomain F }`
- [ ] Define `mcs_at : Int -> Set Formula` with root_mcs fallback
- [ ] Prove `is_mcs : SetMaximalConsistent (mcs_at t)` for all `t : Int`
- [ ] Transfer `forward_G` from `chainFMCS.forward_G` through embedding
- [ ] Transfer `backward_H` from `chainFMCS.backward_H` through embedding
- [ ] Bundle into `fmcs_from_flag : Flag CanonicalMCS -> CanonicalMCS -> FMCS Int`

**Implementation Sketch**:
```lean
def mcs_at (F : Flag CanonicalMCS) (root : CanonicalMCS) (t : Int) : Set Formula :=
  if h : t ∈ domain_image F
  then (inverse_enum F t h).val.world
  else root.world

def fmcs_from_flag (F : Flag CanonicalMCS) (root : CanonicalMCS) : FMCS Int where
  mcs := mcs_at F root
  is_mcs := fun t => by cases (decidable t ∈ domain_image F) <;> simp [mcs_at] <;> exact ...
  forward_G := ...  -- transfer from chainFMCS
  backward_H := ...  -- transfer from chainFMCS
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean`

**Verification**:
- `fmcs_from_flag F root` is valid `FMCS Int`
- `forward_G` and `backward_H` hold
- `lake build` passes

---

### Phase 3: BFMCS Int Bundle with Modal Coherence [NOT STARTED]

**Goal**: Bundle all FMCS Int from FlagBFMCS into `BFMCS Int` with modal coherence.

**Tasks**:
- [ ] Define `bfmcs_from_flagbfmcs : FlagBFMCS -> BFMCS Int`
- [ ] Define `families := { fmcs_from_flag F B.root | F ∈ B.flags }`
- [ ] Prove `families_nonempty` from `B.flags_nonempty`
- [ ] Prove `modal_forward` from `B.modally_saturated`:
  - When `◇φ ∈ M.world` and M is in Flag F
  - `modally_saturated` gives Flag F' with witness W
  - Map W through `fmcs_from_flag F'` to get the Int-indexed witness
- [ ] Prove `modal_backward` from completeness of Flag coverage
- [ ] Prove `temporally_coherent` from `chainFMCS` properties

**Implementation Sketch**:
```lean
def bfmcs_from_flagbfmcs (B : FlagBFMCS) : BFMCS Int where
  families := { fmcs_from_flag F B.root | F ∈ B.flags }
  families_nonempty := by obtain ⟨F, hF⟩ := B.flags_nonempty; exact ⟨_, F, hF, rfl⟩
  modal_forward := fun fam hfam t M hM phi h_diamond => by
    -- Use B.modally_saturated to find witness
    obtain ⟨F, hF, fam_eq⟩ := hfam
    subst fam_eq
    obtain ⟨F', hF', W, hW, h_box⟩ := B.modally_saturated ...
    exact ⟨fmcs_from_flag F' B.root, ..., enum_mcs W, ...⟩
  modal_backward := ...
  -- temporally_coherent follows from chainFMCS properties
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean`

**Verification**:
- `bfmcs_from_flagbfmcs` produces valid `BFMCS Int`
- Modal forward/backward hold
- `temporally_coherent` satisfied
- `lake build` passes

---

### Phase 4: Canonical Completeness Theorem [NOT STARTED]

**Goal**: State and prove completeness using `valid` via parametric pipeline.

**Tasks**:
- [ ] Create `FlagBFMCSCanonicalCompleteness.lean`
- [ ] Wire: `allFlagsBFMCS M0` -> `bfmcs_from_flagbfmcs` -> `parametric_to_history` -> `parametric_shifted_truth_lemma` -> `parametric_representation_from_neg_membership`
- [ ] State main theorem matching `AlgebraicBaseCompleteness` pattern:
  ```lean
  theorem flagbfmcs_canonical_completeness (phi : Formula) :
      valid phi -> Nonempty (DerivationTree [] phi)
  ```
- [ ] Prove by contrapositive using existing machinery

**Implementation Sketch**:
```lean
theorem flagbfmcs_canonical_completeness (phi : Formula)
    (h_valid : valid phi) : Nonempty (DerivationTree [] phi) := by
  by_contra h_not_prov
  -- Get MCS with neg(phi)
  obtain ⟨M, hM, h_neg⟩ := not_provable_implies_neg_extends_to_mcs phi h_not_prov
  let M0 : CanonicalMCS := ⟨M, hM⟩
  -- Construct FlagBFMCS
  let B := allFlagsBFMCS M0
  -- Convert to BFMCS Int
  let bfmcs := bfmcs_from_flagbfmcs B
  -- Get family containing M0
  obtain ⟨F, hF, hM0_in_F⟩ := canonicalMCS_in_some_flag M0
  let fam := fmcs_from_flag F M0
  let t := enum_mcs M0
  -- Apply parametric truth lemma
  have h_truth : phi.neg ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel Int)
               (ShiftClosedParametricCanonicalOmega bfmcs)
               (parametric_to_history fam) t phi.neg :=
    parametric_shifted_truth_lemma bfmcs ... fam ... t phi.neg
  -- Specialize valid
  have h_valid_spec := h_valid Int (ParametricCanonicalTaskFrame Int) ...
  -- Derive contradiction
  exact absurd (h_truth.mp h_neg) (h_valid_spec ...)
```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCanonicalCompleteness.lean` - new file
- `Theories/Bimodal/Metalogic/Metalogic.lean` - add import

**Verification**:
- Completeness theorem compiles without `sorry`
- Uses `valid` in statement (not `satisfies_at`)
- `lake build` passes

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `lean_verify FlagBFMCS_canonical_completeness` confirms no sorries
- [ ] New completeness theorem matches `valid` type signature
- [ ] Parametric pipeline components unchanged
- [ ] All new theorems importable from `Bimodal.Metalogic.Metalogic`

## Future Extensions (Post-Task 1006)

This plan is designed for D-polymorphic extension:

| Extension | Change Required | Estimated Effort |
|-----------|-----------------|------------------|
| Dense (D=Rat) | Change `enum_mcs` codomain to Rat | 2-3 hours |
| Discrete (D=Int) | Add SuccOrder proofs (separate task) | Task 989 |

The parametric infrastructure handles both via type parameter change.

## Artifacts & Outputs

| File | Description |
|------|-------------|
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean` | Enumeration, FMCS Int, BFMCS Int |
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCanonicalCompleteness.lean` | Main theorem |

## Rollback/Contingency

1. **Countable proof difficult**: Axiomatize `Countable CanonicalMCS` initially; eliminate later
2. **Modal coherence complex**: The `modally_saturated` -> `modal_forward` transfer is direct; may need explicit witness construction
3. **Partial completion**: Mark incomplete phases `[PARTIAL]`; all changes are additive

## Success Criteria

1. `FlagBFMCS_canonical_completeness` proven without `sorry`
2. Uses `valid` (not `satisfies_at`) in theorem statement
3. Uses parametric pipeline (`ParametricCanonicalTaskFrame`, `parametric_to_history`, `parametric_shifted_truth_lemma`)
4. Full Lake build succeeds
5. Design supports future D=Rat (dense) extension with minimal changes
