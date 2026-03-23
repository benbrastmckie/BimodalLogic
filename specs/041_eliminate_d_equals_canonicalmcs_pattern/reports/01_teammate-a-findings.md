# Task 41: D=CanonicalMCS Pattern - Teammate A Findings

## Key Findings

### 1. What "D=CanonicalMCS" means architecturally

The FMCS type is `FMCS D` where `D` is the temporal indexing type. The `D=CanonicalMCS` pattern appears in:
- `CanonicalFMCS.lean`: defines `canonicalMCSBFMCS : FMCS CanonicalMCS` and `temporal_coherent_family_exists_CanonicalMCS`
- `StagedConstruction/Completeness.lean`: documents the existence of `FMCS CanonicalMCS`
- `DenseCompleteness.lean`: calls out `FMCS CanonicalMCS` as the proven component (lines 65, 144)
- `MultiFamilyBFMCS.lean`: defines `AllCanonicalMCS_FMCS : FMCS CanonicalMCS` (line 135), `singletonCanonicalBFMCS : BFMCS CanonicalMCS` (line 213)
- `ModallyCoherentBFMCS.lean`: references `FMCS CanonicalMCS` with identity mcs (line 95)

The **identity mapping** `mcs(w) = w.world` is the defining feature. `CanonicalMCS` is a structure wrapping `(world : Set Formula, is_mcs : SetMaximalConsistent world)`. When used as D, every element IS its own MCS, so `mcs(w) = w.world` trivially.

### 2. How temporal_coherent_family_exists_CanonicalMCS depends on the conflation

The theorem in `CanonicalFMCS.lean:325` is:
```lean
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS), ...
```

**Why F/P witnesses are trivial with D=CanonicalMCS**:
- `canonical_forward_F w.world w.is_mcs phi h_F` produces a witness `W : Set Formula` which is an MCS
- Wrap it as `s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }` - the witness is IN the domain because the domain IS all MCSes
- Same for `canonical_backward_P`

This is the conflation: by making the domain = all MCSes, every Lindenbaum-produced witness automatically lands in the domain. No construction needed.

### 3. The architectural error described in task 41

The task says "D should be a timeline type (Int, Rat, TimelineQuot) and W should be world states (MCS). The D=CanonicalMCS pattern conflates these."

**Evidence the codebase ALREADY understands this is problematic**:

From `MultiFamilyBFMCS.lean` lines 19-40 (dated 2026-03-21):
> **STATUS**: DEAD END - W=D CONFLATION
> This module conflates world states (W = CanonicalMCS) with the duration domain (D),
> which is **mathematically impossible** for the BFMCS modal coherence properties.

From `ModallyCoherentBFMCS.lean` lines 59:
> **WARNING**: Using CanonicalMCS as D conflates world states with time indices.

From `FMCSDef.lean` lines 20-31:
> **Proof-Theoretic Special Case**: The construction `FMCS CanonicalMCS` ...
> - Is mathematically valid and sorry-free
> - Trivializes forward_F and backward_P witness obligations
> - Has only Preorder structure (not the LinearOrder needed for TaskFrame semantics)

### 4. What F/P witness obligations actually need to be proven for proper D

For `D = Int` (discrete) - **blocked**:
- `DovetailedBuild` + `DovetailedFMCS` constructs `FMCS DovetailedTimelineQuot` with sorry-free F/P
- But the `dovetailedTimelineQuot_forward_F` / `backward_P` are in `DovetailedTimelineQuotBFMCS.lean`
- The `FMCSTransfer` pattern (`FMCSTransfer.lean`) would transfer these to D via embed/retract bijection
- Blocker: no concrete `FMCSTransfer` instance for `Int` exists yet

For `D = TimelineQuot` (dense) - **partially solved**:
- `DovetailedFMCS.lean` provides `dovetailedFMCS : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)`
- `DovetailedTimelineQuotBFMCS.lean` has `dovetailedTimelineQuotFMCS_forward_F/backward_P` (referenced but check sorries)
- Gap: connecting this to `TaskFrame TimelineQuot`

### 5. What the chain construction currently does

The existing sorry-free path for FMCS D where D≠CanonicalMCS:
1. **DovetailedBuild** (StagedConstruction): Builds a countably-indexed set of MCS points with Dovetailed coverage
2. **DovetailedTimelineQuot**: Takes antisymmetrization quotient to get a partial order
3. **DovetailedFMCS**: Constructs `FMCS DovetailedTimelineQuot` - forward_G and backward_H proven via `dovetailedTimelineQuot_lt_implies_canonicalR`
4. **DovetailedTimelineQuotBFMCS**: Modal saturation via `closedFlags`, forward/backward proven

The `FMCSTransfer` infrastructure exists to transfer D=CanonicalMCS sorry-free F/P witnesses to any domain D that has an embedding/retraction pair with CanonicalMCS.

### 6. The actual task 41 scope (re-reading TODO.md)

**Crucial clarification**: Task 41's description in TODO.md is actually about a DIFFERENT set of changes:
> (1) Remove 3 axioms: discrete_Icc_finite_axiom, discreteImmediateSuccSeed_consistent_axiom, discreteImmediateSucc_covers_axiom
> (2) Fix stale docstrings in AlgebraicBaseCompleteness.lean
> (3) Remove dead code: singleFamilyBFMCS and construct_bfmcs_from_mcs
> (4) Update Bundle/README.md
> (5) Update TODO.md metadata

This is a **cleanup/refactoring** task (remove dead code, remove axioms, fix docs), NOT a mathematical proof task about replacing D=CanonicalMCS with D=Int everywhere.

The **team lead's description** ("Remove the architectural error where FMCS type parameter D is instantiated with CanonicalMCS") appears to be the higher-level goal, with task 41 as one component step.

## Recommended Approach

### If task 41 is the cleanup as described in TODO.md:

1. **Phase 1**: Remove the 3 sorry axioms from DiscreteTimeline.lean and DiscreteSuccSeed.lean (these can only be removed if `discrete_representation_unconditional` is proven sorry-free - need to check)
2. **Phase 2**: Remove dead code `singleFamilyBFMCS` and `construct_bfmcs_from_mcs` from AlgebraicBaseCompleteness.lean
3. **Phase 3**: Fix stale docstrings in AlgebraicBaseCompleteness.lean
4. **Phase 4**: Update README and metadata

### If task 41 is eliminating D=CanonicalMCS systematically:

The mathematically correct approach is:
1. The `FMCSTransfer` infrastructure already exists and is the right tool
2. Build a concrete `FMCSTransfer` for `DovetailedTimelineQuot` using the existing `dovetailedFMCS`
3. The `transferredFMCS T` then gives `FMCS D` with sorry-free F/P for any D with an FMCSTransfer
4. `MultiFamilyBFMCS.singletonCanonicalBFMCS` (marked as DEAD END) should be deleted
5. `temporal_coherent_family_exists_CanonicalMCS` remains valid as a proof-theoretic lemma for the TruthLemma, but should NOT be used as the primary completeness witness

**Key constraint**: `temporal_coherent_family_exists_CanonicalMCS` is legitimately sorry-free and useful for TruthLemma. It should NOT be deleted, just not used as the final completeness argument.

## Evidence/Examples

### Currently sorry-free F/P with D≠CanonicalMCS

`DovetailedFMCS.lean` has the FMCS structure over DovetailedTimelineQuot where:
- `dovetailedFMCS.mcs t = dovetailedTimelineQuotMCS root_mcs root_mcs_proof t`
- forward_G proven via `dovetailedTimelineQuot_lt_implies_canonicalR` + `canonical_forward_G`
- backward_H proven similarly

This demonstrates the pattern works for proper D ≠ CanonicalMCS.

### Dead code markers already in place

`MultiFamilyBFMCS.lean` header (lines 17-40) explicitly marks dead ends with the note "cannot be eliminated." These are candidates for deletion.

### FMCSTransfer as the bridge

`FMCSTransfer.lean:352-358`:
```lean
theorem fmcs_domain_transfer (T : FMCSTransfer D) :
    ∃ (fam : FMCS D),
      (∀ d : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs d →
        ∃ s : D, d < s ∧ φ ∈ fam.mcs s) ∧ ...
```
This is sorry-free and is THE mechanism to transfer from CanonicalMCS to proper D.

## Confidence Level: **High**

The codebase is well-documented with explicit markers for dead ends and architectural problems. The pattern is clear:
1. `FMCS CanonicalMCS` is a legitimate proof-theoretic tool (sorry-free TruthLemma support)
2. Using it as the final semantic domain for completeness is the error
3. The fix infrastructure (`FMCSTransfer`, `DovetailedFMCS`) already exists
4. The actual task 41 cleanup work (per TODO.md) is about removing 3 axioms and dead code, not a full mathematical refactor
