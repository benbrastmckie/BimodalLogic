# Teammate A Findings: Bundle Architecture Improvement via Burgess's Ideas

- **Task**: 83 - Close Restricted Coherence Sorries
- **Angle**: FMCS-as-chain correspondence, enriched-Succ seed fix, truth evaluation at (FMCS, time), concrete file changes
- **Date**: 2026-04-07

## Key Findings

### 1. FMCS-as-Chain Correspondence: Already Exact

The `FMCS Int` structure in `FMCSDef.lean` (lines 99-117) is **precisely** Burgess's Z-indexed chain construction. The correspondence is:

| Burgess Concept | Lean Implementation |
|-----------------|-------------------|
| Z-indexed chain of MCS | `mcs : D -> Set Formula` (D = Int) |
| Temporal forward coherence | `forward_G : t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')` |
| Temporal backward coherence | `backward_H : t' <= t -> H(phi) in mcs(t) -> phi in mcs(t')` |
| Bundle of chains | `BFMCS.families : Set (FMCS Int)` |
| Modal coherence | `modal_forward` / `modal_backward` on BFMCS |

**Critical point the user emphasized**: An FMCS is NOT a point. It is an entire time-indexed family `(w_t)_{t in Z}`. The structure already captures this correctly -- `FMCS Int` bundles the entire function `mcs : Int -> Set Formula` together with coherence proofs.

### 2. Truth Evaluation at (FMCS, time, model): Already Correct

The canonical construction in `CanonicalConstruction.lean` evaluates sentences at an FMCS AND a time, precisely as the user described:

```lean
-- CanonicalConstruction.lean line 491-496
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

The `to_history` function (line 290) converts an FMCS to a WorldHistory:
- `domain := fun _ => True` (total history)
- `states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩`

So truth is evaluated at `(fam, t, CanonicalTaskModel)` -- exactly the triple (FMCS, time, model).

### 3. The Core Problem: forward_F and backward_P

The FMCS structure provides `forward_G` and `backward_H` (universal temporal coherence). The truth lemma's **backward direction** for G/H cases requires `TemporalCoherentFamily` which adds:

```lean
-- TemporalCoherence.lean lines 147-153
forward_F : forall t phi, F(phi) in mcs(t) -> exists s > t, phi in mcs(s)
backward_P : forall t phi, P(phi) in mcs(t) -> exists s < t, phi in mcs(s)
```

The current `SuccChainFMCS` construction (line 994) builds a valid `FMCS Int` but **cannot prove forward_F**. The reason documented at line 42-49: `f_nesting_is_bounded` is **mathematically false** for arbitrary MCS. An MCS can contain `{F^n(p) | n in Nat}` and still be consistent.

Additionally, the truth lemma has `sorry` at lines 628-629 for the Until/Since cases:
```lean
| untl phi psi ih_phi ih_psi => sorry
| snce phi psi ih_phi ih_psi => sorry
```

### 4. Enriched-Succ Seed Fix: Concrete Design

The fix requires modifying the chain construction so that at each step, the seed includes not just `g_content(w_i)` but also **active eventuality formulas** that need resolution:

**Enriched seed at step i (forward direction):**
```
enriched_seed(w_i, i) = g_content(w_i)
                       ∪ deferralDisjunctions(w_i)       -- existing F-step
                       ∪ scheduled_target(w_i, i)        -- NEW: dovetailed resolution
```

Where `scheduled_target(w_i, i)` picks one active F-formula or Until-formula from `w_i` using round-robin scheduling over the finite subformula closure (step `i mod k` where k = |closure|), and places its **witness** directly into the seed.

**Why this works:**
1. **Seed consistency**: `{target} ∪ g_content(w_i)` is consistent when `F(target) ∈ w_i` -- this is already proven as `targeted_g_content_seed_consistent` (line 2040-2044).
2. **F-resolution**: By dovetailing, every F-formula `F(phi) ∈ w_0` is eventually scheduled. At that step, `phi` enters the seed, so `phi ∈ w_j` for some j > 0.
3. **Until resolution**: For `phi U psi ∈ w_i`, BX9 gives `phi ∈ w_i` (guard). BX5 self-accumulation gives `(phi ∧ (phi U psi)) U psi ∈ w_i`. When `psi` is scheduled, it enters the seed; consistency follows from seed arguments using BX10.

**The `targeted_successor` infrastructure (lines 2054-2103) already exists** and provides exactly the right building block: it constructs a DeferralRestrictedMCS successor that resolves a single target while maintaining g_content persistence.

### 5. Concrete Bundle File Changes

#### A. `FMCSDef.lean` -- No Changes Needed

The structure is already correct. `FMCS Int` with `mcs : Int -> Set Formula` plus `forward_G`/`backward_H` is the right abstraction.

#### B. `SuccChainFMCS.lean` -- New Enriched Chain Construction

**Add** (approximately 300-400 LOC):

1. **`EnrichedForwardChainElement`** structure:
```lean
structure EnrichedForwardChainElement (phi : Formula) where
  world : Set Formula
  is_drm : DeferralRestrictedMCS phi world
  has_F_top : F_top ∈ world
  step_index : Nat  -- for dovetail scheduling
```

2. **`enriched_forward_step`** function:
```lean
noncomputable def enriched_forward_step (phi : Formula) (e : EnrichedForwardChainElement phi) :
    EnrichedForwardChainElement phi :=
  -- Pick target from subformula enumeration at e.step_index
  -- Use targeted_successor to build next DRM
  -- Maintain g_content persistence
```

3. **`enriched_forward_chain`** and **`enriched_succ_chain_fam`**: Analogous to existing `forwardChainAt`/`succ_chain_fam` but using enriched steps.

4. **`enriched_succ_chain_forward_F`**: The key theorem, provable because:
   - Given `F(phi) ∈ enriched_chain(t)`, there exists step `j > t` where `phi` is scheduled
   - At step j, `phi` is in the seed, so `phi ∈ enriched_chain(j)`
   - The dovetailing guarantees every formula is eventually scheduled

5. **`enriched_succ_chain_backward_P`**: Symmetric for the past direction.

#### C. `TemporalCoherence.lean` -- No Changes Needed

The `TemporalCoherentFamily` structure and backward lemmas (`temporal_backward_G`, `temporal_backward_H`) are already correct. They just need `forward_F` and `backward_P` to be provided, which the enriched chain construction will supply.

#### D. `BFMCS.lean` -- No Changes Needed

The bundle structure and modal coherence conditions are already correct.

#### E. `CanonicalConstruction.lean` -- Until/Since Cases

The `canonical_truth_lemma` needs the Until/Since cases filled in (lines 628-629). This requires:

1. **Until forward**: `phi U psi ∈ fam.mcs t` implies truth of Until at `(fam, t)`. Need to find witness `s >= t` with `psi ∈ fam.mcs s` and `phi ∈ fam.mcs r` for `t <= r < s`. The enriched chain construction guarantees this witness exists.

2. **Until backward**: Truth of Until at `(fam, t)` implies `phi U psi ∈ fam.mcs t`. Use BX8 (`psi -> phi U psi`) at the witness, then backward induction using BX5/BX6, or the contradiction approach via `neg(phi U psi) -> neg(psi) ∧ (neg(phi) ∨ G(neg(phi U psi)))`.

3. **Since**: Symmetric to Until using past operators.

### 6. Relationship Between Existing Constructions

| Construction | Location | Status | Reuse |
|-------------|----------|--------|-------|
| `SuccChainFMCS` | Bundle/SuccChainFMCS.lean | G/H OK, F/P sorry | Keep for G/H; replace chain builder |
| `DovetailedChain` | Algebraic/DovetailedChain.lean | DEPRECATED (X-vs-G mismatch) | Scheduling idea reusable |
| `DeterministicFMCS` | Boneyard/ | Archived | Avoided restricted MCS pitfalls |
| `targeted_successor` | Bundle/SuccChainFMCS.lean:2054 | Working, sorry-free | **Direct reuse** for enriched chain |

## Recommended Approach

1. **Create `EnrichedChainFMCS.lean`** in `Theories/Bimodal/Metalogic/Bundle/` (new file, ~400 LOC):
   - Uses `DeferralRestrictedMCS` as the MCS type for each chain element
   - Uses `targeted_successor` as the step function (already proven consistent)
   - Adds dovetail scheduling via `Nat.unpair` (reuse pattern from DovetailedChain.lean)
   - Proves `forward_F` and `backward_P` from the scheduling guarantee

2. **Wire enriched chain into `CanonicalConstruction.lean`**:
   - Provide `TemporalCoherentFamily` from enriched chain
   - Fill Until/Since cases using BX5-BX10 axioms
   - Close all remaining sorries in the truth lemma

3. **Do NOT modify existing working constructions**:
   - `FMCSDef.lean`, `BFMCS.lean`, `TemporalCoherence.lean` are architecturally sound
   - `SuccChainFMCS` continues to work for G/H coherence
   - The enriched chain is a NEW construction that wraps the existing one

## Evidence / Examples

**Existing targeted_successor proves the pattern works:**
```lean
-- SuccChainFMCS.lean line 2040-2044
theorem targeted_g_content_seed_consistent (phi : Formula) (u : Set Formula) (target : Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_target : Formula.some_future target ∈ u) :
    SetConsistent (targeted_g_content_seed u target) :=
  single_target_with_g_content_consistent phi u h_drm target h_F_target
```

This is sorry-free and directly usable for the enriched chain's step function.

**Dovetail scheduling pattern (from DovetailedChain.lean):**
```lean
-- Uses Nat.unpair for fair enumeration
-- At step n, Nat.unpair n = (i, j) targets formula j at position i
```

The scheduling idea is sound; only the chain step mechanism (X-vs-G mismatch) was broken.

## Risks

1. **Until backward direction complexity**: The backward case of the Until truth lemma is the subtlest part. The contradiction approach (report 38, section 1.5 Approach B) is cleanest but requires verifying that `neg(phi U psi) -> neg(psi) ∧ (neg(phi) ∨ G(neg(phi U psi)))` is derivable from BX1-BX10. **Mitigation**: This is a standard modal logic derivation; teammate reports 37-38 confirm it should hold.

2. **DeferralRestrictedMCS vs SetMaximalConsistent**: The enriched chain uses `DeferralRestrictedMCS` (bounded by closure), not full `SetMaximalConsistent`. The truth lemma currently expects `SetMaximalConsistent`. **Mitigation**: For the restricted completeness proof, working within a finite closure is standard (filtration/FMP). The `RestrictedMCS` infrastructure already supports this.

3. **BX axiom derivability**: Several proofs use `sorry` for BX axiom derivations (e.g., `temp_4` at SuccChainFMCS.lean line 420, seriality at lines 125/135). These are separate from the chain construction issue but must eventually be resolved. **Mitigation**: These are independent tasks; the chain construction can proceed assuming these axioms.

4. **Since symmetry**: Every construction must be duplicated for the past direction. This is mechanical but doubles the code. **Mitigation**: Use uniform naming and parallel structure.

## Confidence Level

**HIGH (85%)**

The architecture is already well-aligned with Burgess's construction. The `FMCS Int` type IS the Z-indexed chain family. The `to_history` function IS the conversion to a world-history. The `targeted_successor` IS the sorry-free building block for enriched steps. The main work is:
1. Wiring dovetail scheduling into targeted_successor calls (~200 LOC)
2. Proving forward_F/backward_P from scheduling guarantees (~150 LOC)
3. Filling Until/Since truth lemma cases using BX axioms (~200 LOC)

The DovetailedChain.lean failure is well-understood (X-vs-G mismatch) and the targeted_successor approach avoids it entirely by working at the g_content level. The remaining risk is in the backward Until derivation, which has two viable approaches identified in report 38.
