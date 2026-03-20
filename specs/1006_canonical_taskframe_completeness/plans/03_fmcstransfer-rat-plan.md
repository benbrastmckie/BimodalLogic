# Implementation Plan: Task #1006 (v3)

- **Task**: 1006 - canonical_taskframe_completeness
- **Version**: 03 (FMCSTransfer Rat approach)
- **Status**: [PARTIAL]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**:
  - `01_team-research.md` - Initial research (BFMCS construction approach)
  - `02_direct-construction.md` - Streamlined approach (failed: global enumeration)
  - `03_dense-discrete-compatibility.md` - D-polymorphism analysis
  - `04_team-research.md` - Order-preserving embedding (FMCSTransfer Rat recommendation)
- **Artifacts**: `plans/03_fmcstransfer-rat-plan.md` (this file)
- **Type**: lean4

## Overview

Replace the FlagBFMCS `satisfies_at` relation with a canonical TaskFrame construction using `truth_at`. This revision addresses the **Phase 2 blocker** from v2: the global `enum_mcs : CanonicalMCS -> Int` enumeration is not order-preserving, breaking `forward_G`/`backward_H`.

### Key Architectural Insight

An `FMCS D` is a **schedule** — a time-indexed sequence of MCSes. It does NOT embed all CanonicalMCS into D. Only ONE Flag's elements need scheduling at a time.

### Solution: FMCSTransfer with D = Rat

The existing `FMCSTransfer` infrastructure (`FMCSTransfer.lean`) provides sorry-free transfer of `forward_G`/`backward_H` given an order-preserving bijection. We use D = Rat because:

1. **Any countable linear order without endpoints embeds into Rat** (Cantor's theorem)
2. **Flags are totally ordered** (`chainFMCS_pairwise_comparable`)
3. **FMCSTransfer is sorry-free** (lines 162-173)
4. **Parametric infrastructure is D-polymorphic** (works for Rat as well as Int)

### Changes from v2

| Aspect | v2 (Blocked) | v3 (FMCSTransfer Rat) |
|--------|--------------|----------------------|
| Domain D | Int | Rat |
| Embedding | Global `enum_mcs` (non-order-preserving) | Per-Flag order-embedding via Cantor |
| Transfer | Direct FMCS construction (failed) | FMCSTransfer (sorry-free infrastructure) |
| forward_G/backward_H | BLOCKED (ordering mismatch) | Inherited via transfer |
| forward_F/backward_P | Not applicable (blocked earlier) | Cross-Flag via multi-family BFMCS |

## Goals & Non-Goals

**Goals**:
- Construct `FMCSTransfer Rat` for each Flag using order-preserving embedding
- Build `BFMCS Rat` with families from all Flags
- Prove completeness using `valid` via parametric pipeline
- Reuse existing sorry-free infrastructure maximally

**Non-Goals**:
- Implement dense (D=Rat) or discrete (D=Int+SuccOrder) as separate tasks
- Remove `satisfies_at` definition entirely
- Modify existing FMCSTransfer infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cantor embedding construction complex | M | M | Mathlib may have `CountableOrderedSet ↪o Rat`; else hand-construct |
| `retract` function for out-of-image | M | L | Map to nearest Flag element (exists by seriality) |
| `embed_retract_eq` (surjectivity) hard | M | M | Restrict to Flag-image subset of Rat, or use Subtype |
| Cross-Flag temporal coherence | L | L | `canonicalMCS_in_some_flag` guarantees witnesses exist in some Flag |

## Implementation Phases

### Phase 1: Cantor Order-Embedding Infrastructure [COMPLETED]

**Goal**: Establish that Flags embed order-preservingly into Rat.

**Tasks**:
- [ ] Create `FlagBFMCSRatBundle.lean` in `Theories/Bimodal/Metalogic/Bundle/`
- [ ] Define `FlagChain F := ChainFMCSDomain F` as a Subtype of CanonicalMCS
- [ ] Prove `FlagChain F` is a countable total order without endpoints
- [ ] Define or locate `countable_total_order_embed_rat : FlagChain F ↪o Rat`
- [ ] Construct embedding using Mathlib's `Rat.denseRange` and enumeration

**Implementation Sketch**:
```lean
-- The chain domain as a subtype
abbrev FlagChain (F : Flag CanonicalMCS) : Type := ChainFMCSDomain F

-- The chain is totally ordered (from ChainFMCS.lean:550)
instance (F : Flag CanonicalMCS) : LinearOrder (FlagChain F) := inferInstance

-- Countable (inherited from CanonicalMCS)
instance (F : Flag CanonicalMCS) : Countable (FlagChain F) := Subtype.countable

-- Cantor embedding: countable linear order without endpoints -> Rat
-- Option A: Use Mathlib's OrderIso.ratBijective or similar
-- Option B: Construct via dovetailed enumeration
noncomputable def embed_flag (F : Flag CanonicalMCS) : FlagChain F ↪o ℚ := ...
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean` - new file

**Verification**:
- `embed_flag` is a well-typed `OrderEmbedding`
- Compilation succeeds

---

### Phase 2: FMCSTransfer Rat Construction [COMPLETED]

**Goal**: Build `FMCSTransfer Rat` for each Flag using the Cantor embedding.

**Key Challenge**: `FMCSTransfer` requires `embed_retract_eq : embed (retract d) = d`, which implies surjectivity. But `embed_flag` is only injective into Rat, not surjective.

**Resolution Options**:
1. **Restrict domain**: Use `Set.range (embed_flag F)` as the actual domain
2. **Subtype construction**: Work with `{ q : Rat // q ∈ Set.range (embed_flag F) }`
3. **Dense fallback**: For `d` outside image, `retract d` maps to nearest Flag element

**Recommended Approach**: Option 3 (Dense fallback)

For any `d : Rat`, define `retract d` as the Flag element whose embedding is closest to `d`. Since Flags are totally ordered and have no endpoints, such an element exists.

**Tasks**:
- [ ] Define `retract_flag : Rat -> FlagChain F` (nearest element to `d`)
- [ ] Prove `retract_left_inverse : retract (embed w) = w`
- [ ] Prove `embed_retract_eq : embed (retract d) = d` (only for d in image)
- [ ] Handle out-of-image case: extend definition to make `embed ∘ retract = id`
- [ ] Prove `retract_lt` and `embed_lt` (strict monotonicity)
- [ ] Bundle into `FMCSTransfer Rat`

**Alternative**: If `embed_retract_eq` is too difficult for out-of-image points, use the **image subtype** approach:

```lean
-- Work with the image directly
abbrev FlagTimeDomain (F : Flag CanonicalMCS) : Type := Set.range (embed_flag F)

-- FMCSTransfer works on FlagTimeDomain (which IS all of D for this construction)
noncomputable def fmcsTransfer_flag (F : Flag CanonicalMCS) :
    FMCSTransfer (FlagTimeDomain F) := ...
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean`

**Verification**:
- `fmcsTransfer_flag` is a valid `FMCSTransfer`
- All FMCSTransfer axioms proved without sorry

---

### Phase 3: Multi-Family BFMCS Rat [COMPLETED]

**Goal**: Bundle transferred FMCSes from all Flags into `BFMCS Rat`.

**Key Insight**: The second blocker (forward_F/backward_P across Flags) is resolved by the multi-family structure. `temporally_complete` ensures cross-Flag witnesses exist.

**Tasks**:
- [ ] Define `transferred_fmcs_from_flag : Flag CanonicalMCS -> FMCS Rat`
  - Use `transferredFMCS (fmcsTransfer_flag F)`
- [ ] Define `bfmcs_from_flagbfmcs : FlagBFMCS -> BFMCS Rat`
  - `families := { transferred_fmcs_from_flag F | F ∈ B.flags }`
- [ ] Prove `families_nonempty` from `B.flags_nonempty`
- [ ] Prove `modal_forward` from `B.modally_saturated`:
  - When `◇φ ∈ M.world` with M in Flag F
  - `modally_saturated` gives witness Flag F' with W
  - W maps through `transferred_fmcs_from_flag F'`
- [ ] Prove `modal_backward` from completeness of Flag coverage
- [ ] Prove `temporally_coherent`:
  - forward_F/backward_P: Use `canonical_forward_F`/`canonical_backward_P`
  - Witness lands in some CanonicalMCS, hence some Flag, hence some family

**Implementation Sketch**:
```lean
noncomputable def transferred_fmcs_from_flag (B : FlagBFMCS) (F : Flag CanonicalMCS)
    (hF : F ∈ B.flags) : FMCS ℚ :=
  transferredFMCS (fmcsTransfer_flag F)

noncomputable def bfmcs_from_flagbfmcs (B : FlagBFMCS) : BFMCS ℚ where
  families := { transferred_fmcs_from_flag B F hF | F ∈ B.flags ∧ hF : F ∈ B.flags }
  families_nonempty := by
    obtain ⟨F, hF⟩ := B.flags_nonempty
    exact ⟨transferred_fmcs_from_flag B F hF, F, hF, rfl⟩
  modal_forward := ...  -- from B.modally_saturated
  modal_backward := ... -- from Flag completeness
  temporally_coherent := ... -- from canonical_forward_F/backward_P + canonicalMCS_in_some_flag
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean`

**Verification**:
- `bfmcs_from_flagbfmcs` produces valid `BFMCS Rat`
- All coherence properties proved
- No sorry in BFMCS construction

---

### Phase 4: Canonical Completeness Theorem [PARTIAL]

**Goal**: State and prove completeness using `valid` via parametric pipeline.

**Pipeline**:
```
allFlagsBFMCS M0
  -> bfmcs_from_flagbfmcs
  -> parametric_to_history
  -> parametric_shifted_truth_lemma
  -> parametric_representation_from_neg_membership
```

**Tasks**:
- [ ] Create `FlagBFMCSCanonicalCompleteness.lean`
- [ ] Wire the pipeline components
- [ ] State main theorem:
  ```lean
  theorem flagbfmcs_canonical_completeness (phi : Formula) :
      valid phi -> Nonempty (DerivationTree [] phi)
  ```
- [ ] Prove by contrapositive:
  1. Assume ¬provable phi
  2. Get MCS M0 with neg(phi) ∈ M0 (Lindenbaum)
  3. Construct FlagBFMCS via `allFlagsBFMCS M0`
  4. Convert to BFMCS Rat via `bfmcs_from_flagbfmcs`
  5. Get family containing M0's image
  6. Apply parametric truth lemma
  7. Derive ¬valid phi, contradicting hypothesis

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
  -- Convert to BFMCS Rat
  let bfmcs := bfmcs_from_flagbfmcs B
  -- Get the containing family and time for M0
  obtain ⟨F, hF, hM0_in_F⟩ := canonicalMCS_in_some_flag M0
  let fam := transferred_fmcs_from_flag B F hF
  let t : ℚ := embed_flag F ⟨M0, hM0_in_F⟩
  -- Apply parametric pipeline
  have h_truth := parametric_shifted_truth_lemma bfmcs ... fam ... t phi.neg
  -- Specialize valid and derive contradiction
  have h_valid_spec := h_valid ℚ (ParametricCanonicalTaskFrame ℚ) ...
  exact absurd (h_truth.mp h_neg) (h_valid_spec ...)
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCanonicalCompleteness.lean` - new file
- `Theories/Bimodal/Metalogic/Metalogic.lean` - add import

**Verification**:
- Completeness theorem compiles without `sorry`
- Uses `valid` in statement (not `satisfies_at`)
- Uses parametric pipeline
- `lake build` passes

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `lean_verify flagbfmcs_canonical_completeness` confirms no sorries
- [ ] New completeness theorem matches `valid` type signature
- [ ] Parametric pipeline components unchanged
- [ ] All new theorems importable from `Bimodal.Metalogic.Metalogic`

## Alternative Approach (If Phase 1-2 Blocked)

If the Cantor embedding construction proves difficult:

**Path B: Direct satisfies_at bridge**

1. Keep `FlagBFMCS_completeness` (already sorry-free) as core theorem
2. Prove `satisfies_at` corresponds to `truth_at` for specifically constructed TaskFrame
3. Bridge: `satisfies_at -> truth_at -> not valid`

This bypasses BFMCS entirely but requires proving the correspondence directly.

## Dependencies on Existing Infrastructure

| Component | Location | Usage |
|-----------|----------|-------|
| FMCSTransfer | `FMCSTransfer.lean` | Sorry-free transfer of forward_G/backward_H |
| transferredFMCS | `FMCSTransfer.lean:194` | FMCS from transfer |
| transfer_forward_F/P | `FMCSTransfer.lean:244,295` | F/P witness transfer |
| chainFMCS_pairwise_comparable | `ChainFMCS.lean:550` | Flags are totally ordered |
| canonicalMCS_in_some_flag | `FlagBFMCS.lean` | Every MCS is in some Flag |
| canonical_forward_F/backward_P | `CanonicalFMCS.lean` | F/P witnesses exist |
| allFlagsBFMCS | `FlagBFMCS.lean` | Construct FlagBFMCS from root MCS |
| parametric_shifted_truth_lemma | `ParametricTruthLemma.lean` | Truth lemma for parametric model |

## File Cleanup

The following file from v2 can be removed or deprecated:
- `FlagBFMCSIntBundle.lean` - blocked approach, superseded by Rat construction

## Success Criteria

1. `flagbfmcs_canonical_completeness` proven without `sorry`
2. Uses `valid` (not `satisfies_at`) in theorem statement
3. Uses FMCSTransfer infrastructure (not direct construction)
4. Uses parametric pipeline (`ParametricCanonicalTaskFrame`, `parametric_shifted_truth_lemma`)
5. Full Lake build succeeds
6. Design provides foundation for future dense/discrete completeness
