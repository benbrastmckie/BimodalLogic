# Research Report: Task #1006

**Task**: Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
**Date**: 2026-03-19
**Mode**: Team Research (2 teammates)
**Focus**: Logic domain (modal logic, Kripke semantics, completeness proofs)

## Summary

The existing FlagBFMCS completeness proof uses a bespoke `satisfies_at` relation that mirrors `truth_at` but is type-theoretically disconnected from the official semantic layer. The parametric algebraic subsystem (`ParametricCanonical`, `ParametricHistory`, `ParametricTruthLemma`, `ParametricRepresentation`) already provides a sorry-free pipeline from `BFMCS D` to `valid`-based completeness. The task reduces to constructing a `BFMCS Int` from FlagBFMCS data, then applying the existing parametric infrastructure. The core technical challenge is embedding `ChainFMCSDomain F` (Flag chain positions) into `ℤ` while preserving temporal coherence properties.

## Key Findings

### 1. The Type Gap Between satisfies_at and truth_at

**Source**: Teammate A

`satisfies_at` (`FlagBFMCSTruthLemma.lean:135-146`) is a recursive relation that mirrors `truth_at` but operates on `(Flag, ChainFMCSDomain)` pairs without a duration group `D`. Key differences:

| Aspect | `satisfies_at` | `truth_at` |
|--------|---------------|-----------|
| Duration domain | No D; uses `x.val < x'.val` on CanonicalMCS | Explicit `D` with `AddCommGroup` |
| Box case | `MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world` | `∀ σ ∈ Omega` |
| Temporal case | Cross-Flag: `x.val < x'.val` across different Flags | `∀ s : D, t < s` over ALL times in D |
| Omega | Implicit (all Flags in `B.flags`) | Explicit `Set (WorldHistory F)` |

The existing `satisfies_at_iff_mem` truth lemma is sorry-free, establishing: `satisfies_at B F hF x φ ↔ φ ∈ (chainFMCS F).mcs x`.

### 2. The Parametric Algebraic Pipeline (Complete, Sorry-Free)

**Source**: Teammate B

Four files form a reusable pipeline:

1. **`ParametricCanonical.lean`**: `ParametricCanonicalWorldState`, `ParametricCanonicalTaskFrame D`, `parametric_canonical_task_rel` (using CanonicalR)
2. **`ParametricHistory.lean`**: `parametric_to_history` (FMCS → WorldHistory with `domain = True`), `ShiftClosedParametricCanonicalOmega`, shift-closure proofs
3. **`ParametricTruthLemma.lean`**: `parametric_canonical_truth_lemma` — `φ ∈ fam.mcs t ↔ truth_at ... (parametric_to_history fam) t φ` (sorry-free)
4. **`ParametricRepresentation.lean`**: `parametric_representation_from_neg_membership` — closes proof against `valid`

The closing pattern is demonstrated in `AlgebraicBaseCompleteness.lean:246-253`: specialize `valid` at the specific TaskFrame/TaskModel/Omega/history, then use the truth lemma for contradiction.

### 3. The Core Obstacle: ChainFMCSDomain Lacks AddCommGroup

**Source**: Both teammates (convergent finding)

`ChainFMCSDomain F = { M : CanonicalMCS // M ∈ F }` is a linearly ordered type but NOT an additive commutative group. The `truth_at`/`valid` framework requires `D` to carry `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`.

**Resolution**: Use `D = ℤ` (which has all required instances). Embed each Flag's positions into `ℤ` via an order-preserving map. This is possible because `CanonicalMCS` is countable (each MCS is a subset of a countable formula set).

### 4. FlagBFMCS Provides All Raw Material

**Source**: Both teammates

`FlagBFMCS` provides:
- `modally_saturated` — replaces `modal_forward`/`modal_backward` from BFMCS
- `temporally_complete` — via `allFlagsBFMCS` using `Set.univ` and `canonicalMCS_in_some_flag` (Zorn's lemma)
- `satisfies_at_iff_mem` — sorry-free truth lemma reducing to MCS membership

`ChainFMCS.lean` provides:
- `chainFMCS : Flag CanonicalMCS → FMCS (ChainFMCSDomain F)` — per-Flag FMCS
- `chainFMCS_forward_G`, `chainFMCS_backward_H` — temporal coherence facts

### 5. Why Task 997's Validity Bridge Was Superseded

**Source**: Teammate B

`FlagBFMCSValidityBridge.lean` documented the gap: `CanonicalMCS` lacks `AddCommGroup`, so FlagBFMCS cannot directly instantiate `TaskFrame CanonicalMCS`. The bridge tried to connect FlagBFMCS to the parametric frame via embedding. Task 1006 supersedes this by constructing the canonical TaskFrame starting from Flag chain data as the primary construction, avoiding the bridge entirely.

### 6. The Box Case Is the Hardest Correspondence

**Source**: Teammate A

The `satisfies_at` box condition (`MCSBoxContent ⊆ MCSBoxContent`) must correspond to `truth_at`'s `∀ σ ∈ Omega`. These are compatible if Omega is `{τ_F | F ∈ B.flags}` plus shift-closure, but establishing this precisely requires connecting BoxContent-based accessibility to history-based accessibility. The existing `parametric_canonical_truth_lemma` handles box via BFMCS `modal_forward`/`modal_backward` conditions, so `FlagBFMCS.modally_saturated` must be shown equivalent under the embedding.

## Synthesis

### Conflicts Resolved

No conflicts — both teammates converged on the same approach from different angles:
- **Teammate A** analyzed from the gap (what's needed to bridge satisfies_at → truth_at)
- **Teammate B** analyzed from the solution (what existing infrastructure provides)

Both independently concluded: use `D = ℤ`, reuse `ParametricCanonicalTaskFrame ℤ`, construct `BFMCS ℤ` from FlagBFMCS data, apply `parametric_canonical_truth_lemma`.

### Gaps Identified

1. **Countable order-embedding**: Need to construct an order-preserving map `ChainFMCsDomain F ↪o ℤ`. Requires showing Flags are countable (via countability of the formula language). No existing construction in the codebase.

2. **Modal coherence transfer**: Must show `FlagBFMCS.modally_saturated` implies `BFMCS.modal_forward`/`modal_backward` after the ℤ-embedding. The modal_forward condition says: if `M` is boxed in `fam.mcs t`, then `M` is in `fam'.mcs t'` for all `fam'` in the BFMCS. The `modally_saturated` condition on FlagBFMCS encodes this via BoxContent inclusion across Flags.

3. **Temporal coherence transfer**: Must show that `chainFMCS_forward_G`/`chainFMCS_backward_H` (F/P witnesses within a Flag) carry over to `FMCS ℤ`'s `forward_F`/`backward_P` fields after embedding.

4. **CanonicalFMCS.lean exploration**: `temporal_coherent_family_exists_CanonicalMCS` may already provide F/P witnesses at the `CanonicalMCS` level — this needs verification.

### Recommendations

**Recommended approach**: Construct `BFMCS ℤ` from `allFlagsBFMCS` and apply existing parametric infrastructure.

**Implementation steps**:

1. **Define countable order-embedding**: `embed_flag : ChainFMCSDomain F ↪o ℤ` for each Flag F. Leverage countability of the formula language.

2. **Define Int-indexed FMCS per Flag**: Use `embed_flag` to convert `chainFMCS F : FMCS (ChainFMCSDomain F)` to `FMCS ℤ`. Transfer `forward_G`/`backward_H` via the embedding.

3. **Bundle into BFMCS ℤ**: Collect all Int-indexed FMCS into a `BFMCS ℤ`, proving `modal_forward`/`modal_backward` from `FlagBFMCS.modally_saturated` and `temporally_coherent` from the Flag temporal completeness.

4. **Apply parametric pipeline**: `parametric_canonical_truth_lemma` → `parametric_representation_from_neg_membership` → completeness against `valid`.

5. **Clean up**: Remove `satisfies_at`, `FlagBFMCSValidityBridge.lean`, and task 997's bridging attempts.

**Alternative approach** (simpler but less general): If countable order-embedding proves difficult, use `D = ChainFMCSDomain F` for a single specific Flag F, and add `AddCommGroup` structure artificially. This is less clean but avoids the embedding problem.

**Key reusable components** (no modifications needed):
- `ParametricCanonicalTaskFrame ℤ` — ready to use
- `ParametricCanonicalTaskModel ℤ` — ready to use
- `parametric_to_history` — ready to use with ℤ-indexed FMCS
- `parametric_canonical_truth_lemma` / `parametric_shifted_truth_lemma` — ready to use
- `ShiftClosedParametricCanonicalOmega` + shift-closure proofs — ready to use
- `parametric_representation_from_neg_membership` — closes the proof

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approach | completed | high (architecture), medium (embedding feasibility) |
| B | Alternative patterns & prior art | completed | high |

## Key File References

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` | `satisfies_at` definition (135-146), `satisfies_at_iff_mem` (558-580), `temporally_complete` (57-79) |
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` | Current completeness theorem |
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean` | Task 997 bridge (superseded) |
| `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` | `chainFMCS`, `ChainFMCSDomain`, temporal coherence |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` | `ParametricCanonicalTaskFrame D`, WorldState, task_rel |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` | `parametric_to_history`, `ShiftClosedParametricCanonicalOmega` |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` | `parametric_canonical_truth_lemma` (174-184), `parametric_shifted_truth_lemma` (329-334) |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` | `parametric_representation_from_neg_membership` |
| `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` | Closing pattern against `valid` (246-253) |
| `Theories/Bimodal/Semantics/Truth.lean` | `truth_at` definition (115-122) |
| `Theories/Bimodal/Semantics/Validity.lean` | `valid` definition (72) |

## Next Steps

1. **Plan phase**: Create implementation plan with phases for (a) countable order-embedding, (b) FMCS ℤ construction per Flag, (c) BFMCS ℤ bundle, (d) completeness theorem
2. **Verify**: Check `CanonicalFMCS.lean` for existing F/P witness infrastructure
3. **Assess**: Whether `modally_saturated` → `modal_forward`/`modal_backward` transfer is straightforward or requires significant proof work
