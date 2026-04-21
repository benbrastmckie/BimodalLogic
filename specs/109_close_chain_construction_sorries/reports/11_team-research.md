# Research Report: Task #109

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Mode**: Team Research (4 teammates)
**Session**: sess_1776789868_57d306

## Summary

Four teammates systematically surveyed both the `until` branch (reflexive semantics) and `irr_until` branch (irreflexive semantics) to identify the best path toward completeness for irreflexive G/H. The key findings are:

1. **The `until` branch is dramatically closer to complete**: exactly 5 sorry sites remain, all in one file (`RootScopedChain.lean`), with the entire rest of the completeness pipeline sorry-free. Estimated 5-11 days of focused Lean work.

2. **No clean conservative extension exists for the Until/Since language**: Strict Until cannot be defined from reflexive Until. The valid formulas differ between the two semantics. There is no standard transfer theorem in the literature.

3. **The recommended strategy is a two-phase approach**: (Phase 1) Complete reflexive completeness on the `until` branch. (Phase 2) Prove irreflexive completeness separately but reusing shared infrastructure, using either the B1 convention (irreflexive G/H with reflexive U/S) from report 10, or a fully independent proof via the enriched-seed chain.

## Key Findings

### 1. The `until` Branch: 5 Sorries from Complete (Teammate A, VERY HIGH confidence)

The `until` branch has a fully-developed defect-discharge chain construction (1681 lines) with exactly 5 sorry sites:

| # | Line | Theorem | What It Needs | Difficulty |
|---|------|---------|---------------|------------|
| 1 | 1111 | `fwd_chain_forward_F` | Pigeonhole: finite defects, one resolved/step → all eventually resolved | MEDIUM |
| 2 | 1138 | `dd_bfmcs_restricted_tc` (bwd case) | Propagate F from backward chain to origin, then use #1 | LOW-MEDIUM |
| 3 | 1145 | `dd_bfmcs_restricted_tc` (P-direction) | Symmetric P-resolution (dual of forward) | MEDIUM |
| 4 | 1153 | `dd_bfmcs_restricted_buc` | Backward Until coherence — step transfer property | HARD |
| 5 | 1160 | `dd_bfmcs_restricted_fuc` | Forward Until coherence — BX10 + F-resolution + guard | MEDIUM |

**Everything else is sorry-free**: OrderedSeedConsistency.lean (255 lines, 0 sorries), Frame.lean (673 lines, 0 sorries), CanonicalModel.lean (498 lines, 0 sorries), TruthLemma.lean (320 lines, 0 sorries), Completeness.lean (152 lines, 0 sorries), Soundness.lean (sorry-free), TemporalDerived.lean (526 lines, 0 sorries — BX8 and BX1 are axioms).

The mathematical arguments for all 5 sorries are understood. The gap is formalization, not conceptual breakthrough.

### 2. No Conservative Extension for Until/Since Language (Teammate B, HIGH confidence)

The literature is clear on several points:

- **For basic tense logic (G/H only)**: Irreflexive and reflexive validities are identical. Completeness for one immediately gives completeness for the other.
- **For Until/Since**: The operators are genuinely different. Reflexive U is definable from strict U (`φ U_ref ψ := ψ ∨ (φ ∧ φ U ψ)`), but strict U CANNOT be defined from reflexive U. The valid formulas differ.
- **No standard conservative extension theorem exists** for the Until/Since language between reflexive and irreflexive temporal logic.
- **Venema (1993)** extended the Burgess-Xu axiomatization to strict orderings, but this was an independent axiom system modification, not a transfer from the reflexive proof.

**Implication**: Irreflexive completeness for the full language requires a separate proof, not a corollary of reflexive completeness. However, shared infrastructure (canonical model machinery, MCS properties, parametric truth lemma) can be reused.

### 3. Branch Divergence Is Concentrated and Manageable (Teammate C, HIGH confidence)

- **36 files changed** between branches, but **~130/166 files are identical**
- The divergence is concentrated in: Truth.lean (≤ vs <), Axioms.lean (37 vs 35 constructors), RootScopedChain.lean (1681 vs 229 lines), Soundness/SoundnessLemmas.lean
- The `irr_until` branch **increased** the total sorry count (broke ParametricTruthLemma, SigmaOrdering, TruthLemma, Realization, SuccExistence during the irreflexive switch)
- Soundness improvements from `irr_until` are semantics-specific and NOT portable back
- **Recommendation**: Switch to `until` branch and continue there. The defect-discharge chain infrastructure exists and works under reflexive semantics.

### 4. Concrete Two-Phase Implementation Plan (Teammate D, HIGH confidence)

**Phase 1: Reflexive Completeness (on `until` branch, 28-43 hours)**

| Step | Task | Hours | Dependencies |
|------|------|-------|-------------|
| 1.1 | Prove F-Defect Monotonicity (|defects| strictly decreases) | 3-4 | None |
| 1.2 | Close sorry #1 via well-founded induction on defect count | 5-8 | 1.1 |
| 1.3 | Close sorry #2 by F-propagation from backward chain to origin + #1 | 4-6 | 1.2 |
| 1.4 | Close sorry #3 by symmetric P-resolution (dual construction) | 4-6 | Independent |
| 1.5 | Close sorry #4: backward Until coherence via BX8 + step transfer | 5-8 | Independent |
| 1.6 | Close sorry #5: forward Until coherence via BX10 + #1 + BX5/BX9 | 5-8 | 1.2 |
| 1.7 | Integration testing (`lake build`, axiom audit) | 2-3 | All above |

**Phase 2: Irreflexive Completeness (25-41 hours, three options)**

**Option 2A: B1 Convention (irreflexive G/H, reflexive U/S)** — RECOMMENDED for minimal divergence
- Fork from `until` after Phase 1
- Change only G/H from ≤ to < in Truth.lean
- Replace BX1 (T-axiom) with seriality
- Replace BX10 with BX10' ((φ U ψ) → ψ ∨ F(ψ))
- Adapt chain construction with enriched seeds (report 10 analysis)
- ~25-35h

**Option 2B: Independent Proof (fully irreflexive, current A2 convention)**
- Build separate completeness for the `irr_until` semantics
- Can reuse parametric infrastructure but needs different chain construction
- May need quasimodel approach or Venema-style axioms
- ~30-50h

**Option 2C: Parametric Completeness (prove both simultaneously)**
- Parametrize the chain construction over reflexive/irreflexive
- Cleanest for formalization but highest upfront cost
- ~35-55h

## Synthesis

### Conflicts Resolved

**Conflict: Should we derive irreflexive completeness from reflexive, or prove independently?**

- Teammate B recommends AGAINST going through reflexive first (no clean transfer for U/S)
- Teammates A, C, D recommend completing reflexive first because the `until` branch is much closer

**Resolution**: Both positions are correct for different reasons. Teammate B is right that no *automatic* transfer exists — completing reflexive completeness does not hand you irreflexive completeness for free. But Teammates A/C/D are right that the `until` branch is 5 sorries from done while `irr_until` is structurally blocked.

The reconciliation: **Complete reflexive completeness first because it's achievable (Phase 1). Then prove irreflexive completeness as a separate proof reusing shared infrastructure (Phase 2).** The reflexive work is not wasted — it establishes the infrastructure and resolves the hard problems (F-resolution, Until coherence) in a setting where they're tractable. Phase 2 adapts these solutions to the irreflexive setting.

**Conflict: Which U/S convention for irreflexive semantics?**

- Report 10 analyzed the B1 convention (reflexive U/S with irreflexive G/H) and found it viable
- Teammate B notes strict U cannot be defined from reflexive U
- The user said they're "flexible on conventions for S and U"

**Resolution**: The B1 convention (Option 2A) minimizes divergence from the reflexive proof and makes the adaptation tractable. The only axiom changes are BX1→seriality and BX10→BX10'. The enriched-seed chain from report 10 handles F-resolution under irreflexive G. This is the "most natural" choice that honors the user's flexibility on U/S while achieving irreflexive G/H.

### Gaps Identified

1. **Sorry #4 (backward Until coherence) is genuinely hard** even under reflexive semantics. The step transfer property needs careful treatment. BX8 handles the base case but the inductive step may need chain-specific infrastructure.

2. **The enriched-seed chain for Phase 2 (irreflexive G) has not been prototyped.** The mathematical analysis in report 10 is sound, but Lean formalization may surface unexpected issues.

3. **The Since guard convention on `until`** uses (s, t] (half-open), not [s, t] (closed). This matches BX9' soundness requirements. Verify this is consistent throughout.

4. **The `until` branch Lean version** may be behind `irr_until`. Check if a `lake build` succeeds.

### Recommendations

**Immediate next step**: Switch to `until` branch and attempt to `lake build` to verify it compiles. If it does, start Phase 1.1 (F-Defect Monotonicity).

**Branch strategy**: Work on `until` directly for Phase 1. After sorry-free completeness, create a new branch (e.g., `irr_g_completeness`) for Phase 2 with the B1 convention.

**Do NOT attempt to merge `irr_until` into `until`** — the semantic changes are incompatible and the soundness work is not portable.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | `until` branch survey | completed | very high | 5 sorries identified, all in one file; sorry-free infrastructure confirmed; 5-11 day estimate |
| B | Literature survey | completed | high | No conservative extension for U/S language; strict U not definable from reflexive U; Venema's approach was independent |
| C | Branch diff comparison | completed | high | 130/166 files identical; irr_until increased sorry count; merge not recommended |
| D | Implementation plan | completed | high | 6-phase plan (28-43h Phase 1); three Phase 2 options with effort estimates |

## References

### Codebase (until branch — read via `git show until:path`)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 5 sorry sites (1681 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` — sorry-free (255 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — sorry-free (152 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — sorry-free (673 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — sorry-free (498 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — sorry-free (320 lines)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — sorry-free (526 lines)

### Literature
- Burgess (1982/1984): Complete axiom system for reflexive U/S on all linear orders
- Xu (1988): Simplified Burgess system, reflexive conventions
- Venema (1993): Extension to strict orderings — independent modification, not transfer from reflexive
- Reynolds (1992): Strict U/S over reals without IRR rule
- Blackburn-de Rijke-Venema (2001): Irreflexivity not modally definable; no new validities for basic ML

### Prior Research
- Reports 09-10 (this task): A2 convention non-standard, enriched-seed chain viable under irreflexive G
- Task 93 Report 13: Ordered Seed Consistency theorem (proved sorry-free on `until`)
