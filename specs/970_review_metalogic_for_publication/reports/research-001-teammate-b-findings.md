# Teammate B Findings: Alternative Approaches and Prior Art

**Task**: 970 — Review Metalogic for Publication Readiness
**Focus**: Historical scaffolding, redundant definitions, naming inconsistencies, prior art
**Date**: 2026-03-15
**Confidence**: High

---

## Executive Summary

The metalogic has accumulated several layers of scaffolding from the proof development process that are now safe to remove or simplify. The primary opportunities are:

1. **`bmcs_truth_at` is a redundant intermediate** — documented as such in `CanonicalConstruction.lean` line 20, never used outside `BFMCSTruth.lean` and `TruthLemma.lean`. The `canonical_truth_lemma` in `CanonicalConstruction.lean` was specifically designed to bypass it entirely.
2. **`FMCS.at` and `BFMCS.mcs_at` are unused accessors** — defined in `FMCSDef.lean` and `BFMCS.lean`, never referenced in the active codebase.
3. **Multiple BFMCS convenience lemmas are never used externally** — `FMCS.consistent`, `FMCS.maximal`, `FMCS.G_implies_future_phi`, `FMCS.H_implies_past_phi`, `FMCS.GG_to_G`, `FMCS.HH_to_H`, `FMCS.theorem_mem`, `IsConstantFamily`.
4. **`dne_theorem'` is a pointless alias** — defined in `TemporalCoherentConstruction.lean:94` as a re-export of `dne_theorem`, never called anywhere.
5. **`diamondFormula` wrapper is redundant** — `ModalSaturation.lean` defines `diamondFormula (phi) := phi.diamond`, which is just `Formula.diamond`. The alias adds no value.
6. **`asDiamond` in `ModalSaturation.lean` is duplicated** — `Decidability/Tableau.lean:157` defines `asDiamond?` independently with the same purpose.
7. **`bmcs_valid` and `bmcs_satisfiable_at` are never used in proofs** — only appear in README/comment documentation, not in any `.lean` proof.
8. **`TemporalCoherentConstruction.lean` contains a live sorry in `temporal_coherent_family_exists_Int`** that the active proof chain no longer uses (superseded by `CanonicalFMCS.lean`).

---

## Key Findings

### Finding 1: `bmcs_truth_at` Is a Documented Redundant Intermediate

The `CanonicalConstruction.lean` module docstring (line 20) explicitly states:

> "The intermediate `bmcs_truth_at` is structurally redundant — it is definitionally identical to `truth_at` when canonical definitions are chosen correctly."

The `canonical_truth_lemma` (line 467) proves MCS membership ↔ `truth_at` **directly**, bypassing `bmcs_truth_at`. Yet `bmcs_truth_at` remains as a separate definition in `BFMCSTruth.lean`, and `TruthLemma.lean` still proves `bmcs_truth_lemma` in terms of it.

**The proof path is now doubled**: there are two truth lemmas (`bmcs_truth_lemma` and `canonical_truth_lemma`) that establish the same mathematical content at different abstraction levels. The `bmcs_truth_at` layer exists only because `bmcs_truth_lemma` was proven first and is still referenced in `StagedConstruction/Completeness.lean`.

**Evidence**:
- `BFMCSTruth.lean` defines `bmcs_truth_at`, `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`, and ~10 derived lemmas (`bmcs_truth_neg`, `bmcs_truth_and`, etc.)
- None of these derived lemmas are referenced outside `BFMCSTruth.lean` or `TruthLemma.lean`
- `bmcs_valid` and `bmcs_satisfiable_at` appear only in documentation (README, comments), never in proofs
- `CanonicalConstruction.lean` was designed specifically to eliminate `bmcs_truth_at`

### Finding 2: Unused Accessor Definitions

Both `FMCSDef.lean` and `BFMCS.lean` define accessor convenience methods that are never referenced outside their defining files:

| Definition | File | Used Externally? |
|------------|------|-----------------|
| `FMCS.at` | `FMCSDef.lean:109` | No |
| `BFMCS.mcs_at` | `BFMCS.lean:175` | No |
| `BFMCS.is_mcs` | `BFMCS.lean:179` | No (delegates to `fam.is_mcs t`) |
| `BFMCS.consistent` | `BFMCS.lean:184` | No |
| `BFMCS.phi_from_box` | `BFMCS.lean:254` | No |
| `BFMCS.box_from_universal` | `BFMCS.lean:245` | No |

These are bridge-building scaffolding: defined during proof development to abstract repeated patterns, but the actual proofs never adopted them (they call `fam.mcs t`, `fam.is_mcs t` etc. directly).

### Finding 3: FMCS Derived Lemmas Are Never Used

`FMCSDef.lean` (lines 133–207) defines several derived lemmas that are wrappers around the basic `forward_G`/`backward_H` fields:

| Lemma | Content | Used? |
|-------|---------|-------|
| `FMCS.forward_G_chain` | alias of `family.forward_G` | No |
| `FMCS.backward_H_chain` | alias of `family.backward_H` | No |
| `FMCS.GG_to_G` | special case | No |
| `FMCS.HH_to_H` | special case | No |
| `FMCS.G_implies_future_phi` | alias of `forward_G` | No |
| `FMCS.H_implies_past_phi` | alias of `backward_H` | No |
| `FMCS.consistent` | trivial wrapper | No |
| `FMCS.maximal` | trivial wrapper | No |
| `FMCS.theorem_mem` | `theorem_in_mcs` wrapper | No |
| `IsConstantFamily` | predicate (never instantiated in active code) | No |

All active proofs call `fam.forward_G` and `fam.backward_H` directly.

### Finding 4: `dne_theorem'` Is a Pointless Alias

`TemporalCoherentConstruction.lean:94`:
```lean
noncomputable def dne_theorem' (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  dne_theorem phi
```

This is a one-liner that wraps `dne_theorem` from `ModalSaturation.lean`. It is defined in `TemporalCoherentConstruction.lean` but never called anywhere in the codebase (grep confirms zero usage). It was likely a workaround during proof development when there was a namespace conflict, now resolved.

### Finding 5: `diamondFormula` Wrapper Is Redundant

`ModalSaturation.lean:63` defines:
```lean
def diamondFormula (phi : Formula) : Formula := phi.diamond
```

This is an alias for `Formula.diamond`. In active code (`ChainFMCS.lean`), it is used in multiple places — but `phi.diamond` is already a first-class method on `Formula`. The wrapper adds no mathematical content and could be replaced with `phi.diamond` directly throughout.

### Finding 6: `asDiamond` Is Duplicated Across Files

Two separate files define essentially the same function:
- `ModalSaturation.lean:70`: `def asDiamond : Formula → Option Formula`
- `Decidability/Tableau.lean:157`: `def asDiamond? : Formula → Option Formula`

The `ModalSaturation.lean` version is only used within `ModalSaturation.lean` itself (for `is_modally_saturated_iff_no_needs_witness`). The `Tableau.lean` version is for the decision procedure. These diverged independently. The `ModalSaturation` version could be eliminated or the shared definition extracted.

### Finding 7: `TemporalCoherentConstruction.lean` Contains Obsolete Sorry

The file contains `temporal_coherent_family_exists_Int` (line 413) with a live sorry. This function existed to provide the connection between consistent contexts and temporally coherent families. However:

- `CanonicalFMCS.lean` now provides `temporal_coherent_family_exists_CanonicalMCS` (sorry-free, proven)
- `StagedConstruction/Completeness.lean` uses the CanonicalMCS version, NOT the Int version
- The Int version is referenced only in `TemporalCoherentConstruction.lean` itself and in `fully_saturated_bfmcs_exists_int` (also sorry-backed)
- Both `fully_saturated_bfmcs_exists_int` and `construct_saturated_bfmcs_int` (also sorry-backed) are not used on the publication path

This means the entire `TemporalCoherentConstruction.lean` sorry infrastructure (2 functions with sorries) is dead code relative to the active completeness chain.

### Finding 8: `BFMCS.temporally_coherent` Is Defined in the Deprecated File

`BFMCS.temporally_coherent` (used by `TruthLemma.lean`) is defined in `TemporalCoherentConstruction.lean:322`. Since `TemporalCoherentConstruction.lean` is marked DEPRECATED, this definition needs extraction to a dedicated file before `TemporalCoherentConstruction.lean` can be archived.

This is the concrete import refactoring identified in research-001:
- `TruthLemma.lean` imports `TemporalCoherentConstruction` only for `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`, and `BFMCS.temporally_coherent`
- These four items are sound mathematical content that should survive the deprecation

---

## Recommended Approach

### Priority 1: Extract `BFMCS.temporally_coherent` from Deprecated File

Before archiving `TemporalCoherentConstruction.lean`, create a minimal extraction:

**New file**: `Bundle/TemporalCoherence.lean`
- Move: `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`, `BFMCS.temporally_coherent`
- Move: supporting infrastructure: `neg_all_future_to_some_future_neg`, `neg_all_past_to_some_past_neg`, `mcs_double_neg_elim`, `G_dne_theorem`, `H_dne_theorem`
- The sorry-backed content (`temporal_coherent_family_exists_Int`, `fully_saturated_bfmcs_exists_int`, `construct_saturated_bfmcs_int`) stays in `TemporalCoherentConstruction.lean` for archival

This allows `TruthLemma.lean` to import `Bundle/TemporalCoherence.lean` instead of the deprecated file.

### Priority 2: Remove `bmcs_truth_at` Layer (or Mark as Legacy)

The `bmcs_truth_at` intermediate can be eliminated if the proof of `bmcs_truth_lemma` is merged into `canonical_truth_lemma`. However, this is a substantial refactor.

**Intermediate option**: Mark `BFMCSTruth.lean` and `TruthLemma.lean` as "legacy path — use `canonical_truth_lemma` for new proofs" with a comment explaining the redundancy. This preserves the working proof while signaling the simplification direction.

**Full elimination**: Prove `canonical_truth_lemma` directly (it is already proven in `CanonicalConstruction.lean` for `D = Int`), then derive `bmcs_truth_lemma` as a corollary, and eliminate `BFMCSTruth.lean`'s intermediate definitions.

### Priority 3: Remove Dead Convenience Definitions

Low-risk removals (each has no external usage, confirmed by grep):
- `dne_theorem'` alias in `TemporalCoherentConstruction.lean:94`
- `FMCS.at` in `FMCSDef.lean:109`
- `BFMCS.mcs_at` in `BFMCS.lean:175`
- `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` in `BFMCSTruth.lean:106-121` (if `bmcs_truth_at` layer is kept, these can still be removed)
- `IsConstantFamily` in `FMCSDef.lean:218` (never instantiated in active code)

### Priority 4: Consolidate Diamond Definitions

Replace `diamondFormula (phi)` with `phi.diamond` directly in `ChainFMCS.lean` and `ModalSaturation.lean`. Eliminate `asDiamond` from `ModalSaturation.lean` (it is only used internally in that file for the `is_modally_saturated_iff_no_needs_witness` theorem).

---

## Evidence/Examples

### Example 1: `bmcs_truth_at` Redundancy

From `CanonicalConstruction.lean:18-25`:
```
## Key Insight (research-006)

The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally
identical to `truth_at` when canonical definitions are chosen correctly. Therefore
we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate.
```

### Example 2: `dne_theorem'` Alias (Zero Usage)

```lean
-- TemporalCoherentConstruction.lean:94
noncomputable def dne_theorem' (phi : Formula) : [] ⊢ ... :=
  dne_theorem phi
-- grep for "dne_theorem'" in Theories/: 0 results outside this file
```

### Example 3: `temporal_coherent_family_exists_Int` Is Dead Code

The active completeness chain:
```
StagedConstruction/Completeness.lean
  -> temporal_coherent_family_exists_CanonicalMCS (CanonicalFMCS.lean) [PROVEN]
  -> cantor_iso (CantorApplication.lean) [PROVEN]
  -> bmcs_truth_lemma (TruthLemma.lean) [PROVEN]
```

The deprecated chain (not used):
```
temporal_coherent_family_exists_Int (TemporalCoherentConstruction.lean) [SORRY]
  -> fully_saturated_bfmcs_exists_int (TemporalCoherentConstruction.lean) [SORRY]
  -> construct_saturated_bfmcs_int (TemporalCoherentConstruction.lean)
```

### Example 4: FMCS Accessor vs Direct Field Access

Active proof style (`TruthLemma.lean:99`):
```lean
fam.forward_G t s φ hts hG  -- calls structure field directly
```

Never used (`FMCSDef.lean:133`):
```lean
lemma FMCS.forward_G_chain (family : FMCS D) {t t' : D} (htt' : t < t') (phi : Formula)
    (hG : Formula.all_future phi ∈ family.mcs t) : phi ∈ family.mcs t' :=
  family.forward_G t t' phi htt' hG  -- nobody calls this lemma
```

---

## Prior Art from Boneyard Analysis

The Boneyard reveals a clear historical pattern of accumulation and removal:

| Removed Structure | Reason for Removal | Lesson |
|------------------|---------------------|--------|
| `constantBFMCS` | Constant families can't satisfy `forward_G` with irreflexive semantics | Semantic clarity prevents dead definitions |
| `singleFamilyBFMCS` | Modal backward not provable for single family | Architecture must match proof structure |
| `EvalBFMCS` truth lemma | 4 sorries, structural limitation | Simpler structures (BFMCS) are more complete |
| `TemporalForwardSaturated/BackwardSaturated` | Impossible for consistent sets (`{F(psi), neg psi}`) | Mathematical impossibility → remove predicate |
| `construct_bmcs` / `construct_bmcs_from_set` | Dead code | Remove when no longer used |
| `singleFamily_modal_backward_axiom` | Mathematically FALSE axiom | Axioms must be provable |

The pattern: definitions created to support one proof strategy are often left behind when a better strategy is found. The current codebase still has scaffolding from the BFMCS development era that predates the `CanonicalFMCS`/`CanonicalConstruction` approach.

---

## Confidence Level

**High**

Evidence gathered by:
- Reading all Bundle/*.lean files (full file scan)
- Grep-based usage analysis for all identified candidates
- Cross-referencing import dependencies
- Comparing active proof chain vs deprecated chain
- Reviewing Boneyard deprecation notices for historical pattern

The findings are based on concrete, verifiable code evidence, not speculation.

---

## Appendix: Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/specs/929_prepare_metalogic_for_publication/reports/research-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/929_prepare_metalogic_for_publication/reports/research-001-teammate-b-findings.md`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean`
