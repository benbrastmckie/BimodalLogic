# Teammate C Findings: Publication Readiness, Code Quality, and Risk Assessment

## Key Findings

1. **The `completeness_over_Int` claim of being "sorry-free" is FALSE.** It transitively depends on `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` in `DovetailedChain.lean` (lines 1258, 1266), both of which are `sorry`. The dependency chain is:
   `completeness_over_Int` -> `dovetailed_bundle_validity_implies_provability` -> `dovetailed_bfmcs_restricted_temporally_coherent` -> `DovetailedFMCS_forward_F/backward_P` (sorry).

2. **No custom `axiom` declarations exist.** All occurrences of "axiom" in Lean files are in comments/docstrings. The formalization uses only standard Lean axioms (`propext`, `Classical.choice`, `Quot.sound`). This is excellent for soundness.

3. **The core sorry bottleneck is intra-family F/P witness resolution.** Every completeness path (SuccChain, Dovetailed, Deterministic) converges on the same fundamental gap: given `F(psi)` in an MCS at time `t`, prove `psi` exists at some `s > t` within the same chain. This is mathematically correct but technically challenging due to Until/Since persistence.

4. **~61,000 lines of Lean code across 134 files** (including ~1,450 lines in Boneyard). Non-trivial formalization scope.

## Architecture Assessment

**Score: 8/10**

The architecture is well-organized with clear separation:

- **Syntax/ProofSystem/Semantics**: Clean, well-documented foundational layers.
- **Metalogic**: Good modular decomposition (Core, Bundle, Algebraic, Decidability, ConservativeExtension).
- **Multiple completeness paths**: SuccChain, Dovetailed, Deterministic -- demonstrates thorough exploration of proof strategies.
- **FrameConditions**: Clean abstraction for frame-class validity (dense, discrete, base).
- **Boneyard**: Archived dead code is properly isolated (good practice).

**Weaknesses**:
- The Metalogic/Bundle directory has accumulated 20+ files, some with overlapping concerns (SuccChainFMCS.lean alone is likely very large given 23 sorry references in the count).
- The FrameConditions/Completeness.lean comments claim "sorry-free" for `completeness_over_Int` when it is not. This is misleading and should be corrected.
- Three parallel completeness approaches (SuccChain, Dovetailed, Deterministic) create maintenance overhead; only one is needed for publication.

## Axiom Audit (Safety Check)

**PASS -- No soundness concerns.**

- Zero `axiom` declarations in the codebase (all occurrences are in comments).
- Standard Lean axioms only: `propext`, `Classical.choice`, `Quot.sound`.
- The proof system axioms (modal K, T, 4, B, 5; temporal K, 4, A, L; Until/Since axioms) are declared as constructors of an inductive type `Axiom`, not as Lean `axiom`s. This is the correct approach.
- The `sorry` usages are honest gaps, not disguised axioms.

## Representation Theorem Status

**Two representation theorems exist:**

1. **Algebraic Representation Theorem** (`AlgebraicRepresentation.lean`):
   - `algebraic_representation_theorem`: `AlgSatisfiable phi <-> AlgConsistent phi`
   - **SORRY-FREE.** Both directions (`consistent_implies_satisfiable`, `satisfiable_implies_consistent`) are fully proven.
   - This is a syntactic/algebraic result about ultrafilters of the Lindenbaum algebra. It does NOT directly give semantic completeness over TaskFrame models.

2. **D-Parametric Representation Theorem** (`ParametricRepresentation.lean`):
   - `parametric_algebraic_representation_conditional`: Given a BFMCS construction callback, non-provable formulas have countermodels.
   - **SORRY-FREE as stated** -- but conditional on the callback providing a temporally coherent BFMCS.
   - The callback implementations (`construct_bfmcs_callback` in `DeterministicFMCS.lean`) depend on sorry-bearing `forward_F`/`backward_P`.

## ParametricRepresentation Status

**Report 17 concern resolved: ParametricRepresentation.lean is NOT broken.**

The file is 303 lines, well-documented, and contains:
- `not_provable_implies_neg_set_consistent` -- fully proven
- `parametric_algebraic_representation_relative` -- fully proven
- `parametric_representation_from_neg_membership` -- fully proven
- `not_provable_implies_neg_extends_to_mcs` -- fully proven
- `parametric_algebraic_representation_conditional` -- fully proven (conditional)
- `countermodel_implies_not_provable` -- fully proven

Zero sorry in this file. It was likely confused with a different file in report 17.

The `h_uc : B.until_since_coherent` parameter was added (visible in the signatures), suggesting recent work to thread Until/Since coherence through the representation theorem. This is correctly done.

## Dead Code / Cleanup Needed

### Boneyard (properly archived, ~1,450 lines)
- `BundleTemporalCoherence/` -- Old bundle temporal coherence code
- `TAxiomDependentCode/` -- Archived functions depending on removed T-axiom variants
- `UltrafilterDeadCode/` -- Superseded ultrafilter chain approaches

### Active code with dead code markers
- `RestrictedTruthLemma.lean`: Two theorems explicitly marked "DEAD CODE" (`restricted_chain_G_propagates`, `restricted_chain_H_step`) -- should be removed or moved to Boneyard.
- `UltrafilterChain.lean`: Large file (~3900+ lines) with multiple approach attempts accumulated over time. Contains `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` (sorry) that are now superseded by the Dovetailed approach.

### Debug artifacts (#check/#eval)
- 45+ `#check` and `#eval` statements across the codebase.
- Most are in appropriate locations (Examples/, Theorems.lean, Demo.lean) serving as documentation.
- Some in `Automation/Tactics.lean` (lines 171-256) and `FrameConditions/FrameClass.lean` (lines 205-207) could be cleaned up for publication.

### Comments claiming sorry-free that are not
- `FrameConditions/Completeness.lean` line 428: "sorry-free path from validity to provability" is incorrect.
- `FrameConditions/Completeness.lean` line 470: "Sorry-free via the dovetailed chain construction" is incorrect.
- Multiple doc-comments in this file should be updated to accurately reflect the sorry dependency.

## Publication Readiness Score: 6/10

**Justification:**

**Strengths (what earns 6):**
- Algebraic representation theorem is fully proven (sorry-free)
- Soundness for base axioms (17 axioms) is fully proven
- Decidability via FMP/tableau is fully proven
- Deduction theorem fully proven
- Proof system infrastructure is solid and well-tested
- Good documentation quality throughout
- No unsound axioms
- Clean proof system design (inductive Axiom type)
- 15+ combinator theorems and propositional theorems proven

**What prevents 7+:**
- The central completeness theorem still has sorry (intra-family F/P witnesses)
- Soundness has 28 sorry statements (Until/Since axioms, discrete axioms, density axiom, temporal duality)
- Misleading "sorry-free" claims in FrameConditions/Completeness.lean
- Until/Since axiom soundness not yet proven (this is a significant gap)
- Dense completeness is entirely sorry (`dense_completeness_fc`)

## Minimum Viable Publication Assessment

**YES, publishable with remaining sorries, under specific framing.**

### Option A: "Formalized Modal Logic Infrastructure" (highest confidence)
- **Scope**: Soundness + decidability for base TM logic (F/P temporal operators only, no Until/Since)
- **Sorry-free content**: 17 base axiom validity lemmas, decidability, algebraic representation, deduction theorem, MCS theory, Lindenbaum lemma
- **Value**: This would be among the most comprehensive Lean 4 formalizations of bimodal (S5 + linear temporal) logic
- **Comparison**: Existing Lean 4 modal logic formalizations (e.g., iehality/lean4-modal-logic) cover propositional modal logic K/S4/S5 but not temporal operators. This project significantly extends the scope.

### Option B: "Towards Completeness for TM Logic" (medium confidence)
- **Scope**: Full formalization including the completeness architecture with admitted lemmas
- **Admitted items**: `forward_F`/`backward_P` (clearly stated as admitted), Until/Since soundness
- **Value**: The architectural contribution (D-parametric representation, BFMCS framework, multiple completeness strategies) is novel and publishable even with admitted lemmas
- **Risk**: Reviewers may question whether the admitted lemmas are actually provable

### Option C: "Complete Formalization" (current goal, low confidence of near-term completion)
- **Scope**: Zero sorry
- **Blocker**: Intra-family F/P witness resolution (the same blocker across all three completeness paths)
- **Timeline risk**: This has been the blocker for many tasks; could take significant additional effort

**Recommendation**: Option A is publication-ready NOW. Option B is publishable with honest framing.

## Critical Risks

1. **The F/P witness gap may be deeper than expected.** Three independent proof strategies (SuccChain, Dovetailed, Deterministic) all hit the same wall. This suggests the gap is not a matter of proof engineering but may require a novel mathematical insight (e.g., a different chain construction, or a fundamentally different approach to temporal coherence).

2. **Until/Since axiom soundness gap.** 14 Until/Since axioms have sorry in soundness. If any of these axioms is actually unsound (unlikely but possible), it could invalidate the completeness theorem even if proven. These should be prioritized for soundness verification.

3. **Misleading documentation could erode trust.** The "sorry-free" claims in FrameConditions/Completeness.lean are factually incorrect. If a reviewer runs `lean_verify` or checks dependencies, this will immediately undermine credibility.

4. **Dense completeness is entirely blocked.** `dense_completeness_fc` is a bare `sorry` with no infrastructure connecting it to the D-parametric framework for D = Rat. This is a separate major effort.

5. **Temporal duality soundness** has a sorry in both the general and discrete soundness theorems. This is described as an "architectural limitation" requiring `DenselyOrdered` constraints, but it affects the discrete case too.

## Confidence Level: **High**

The analysis is based on direct reading of all key files and tracing dependency chains through the sorry graph. The key finding (that `completeness_over_Int` is NOT sorry-free) is verified by reading the actual proof and tracing through `DovetailedFMCS_forward_F` -> sorry. The axiom audit is complete (grep for `^axiom ` across all .lean files). The sorry count methodology is conservative (matching actual sorry tactic/term usage, not comments).
