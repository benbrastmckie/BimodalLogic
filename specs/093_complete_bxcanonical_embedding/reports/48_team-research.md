# Research Report: Task #93 — Round 48

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1745103600_b8c2f1

## Summary

Round 48 deepens the irreflexive semantics switch analysis from Round 47 with exhaustive codebase impact, axiom redesign, and sorry-closure proof strategies. The decisive new finding: **the guard convention for strict Until is the single most consequential design choice**, and Sub-option A2 (strict witness s > t, half-open guard [t, s)) is recommended because it preserves BX9 while enabling the Until step transfer. A second critical finding: **`defect_step_early` (RootScopedChain.lean:524-529) internally uses `phi_in_mcs_imp_F_phi_early` (derived from φ → F(φ))**, which is INVALID under irreflexive semantics — meaning the entire `preserving_fwd_step` construction must be redesigned, not just the sorry sites. However, this is a **simplification**: under irreflexive semantics, resolved defects no longer need F-preservation, so `active_defects` naturally shrinks.

## Key Findings

### 1. Guard Convention: A2 (Half-Open) Resolves BX9 Conflict (HIGH confidence, 90%)

**Source**: Teammates A, B, C (conflict resolved)

The most consequential design decision is the guard convention for strict Until:

| Convention | Witness | Guard | BX8 valid? | BX9 valid? | Step transfer? |
|------------|---------|-------|------------|------------|----------------|
| Current (reflexive) | s ≥ t | [t, s) | YES | YES | Blocked |
| A1 (fully strict) | s > t | (t, s) | NO | NO | YES but complex |
| **A2 (strict witness, half-open guard)** | **s > t** | **[t, s)** | **NO** | **YES** | **YES (direct)** |

**Conflict**: Teammate C argued BX9 is INVALID under strict Until with countermodel (ψ at t+1, empty guard). Teammate B argued BX9 is VALID under A2. **Resolution**: C's countermodel assumes open guard (t, t+1) = {} (A1 convention). Under A2, the guard [t, t+1) = {t} requires φ(t), so the countermodel fails. BX9 **is valid under A2**.

**Recommendation**: A2 (strict witness, half-open guard [t, s)). This is the minimal semantic change — only the witness constraint changes from ≥ to >, the guard stays identical to the current code. BX9 survives, reducing blast radius significantly.

**Truth.lean changes under A2**:
- `all_future φ`: `t ≤ s` → `t < s`
- `all_past φ`: `s ≤ t` → `s < t`
- `untl φ ψ` witness: `t ≤ s` → `t < s` (guard `t ≤ r` stays as-is)
- `snce φ ψ` witness: `s ≤ t` → `s < t` (guard stays as-is)

### 2. Complete Axiom Disposition Table (HIGH confidence, 90%)

**Source**: Teammate B (primary), verified by A and C

| Axiom | Status | Reason |
|-------|--------|--------|
| BX1 `temp_t_future` G(φ)→φ | **REMOVE** | Unsound: G quantifies over s > t only |
| BX1' `temp_t_past` H(φ)→φ | **REMOVE** | Unsound: H quantifies over s < t only |
| BX2-BX7 (monotonicity, connect, accum, absorb, linear) | **KEEP** | All valid under strict semantics |
| BX8 `refl_intro_until` ψ→(φ U ψ) | **REMOVE** | Unsound: needs witness s > t with ψ(s), not guaranteed from ψ(t) |
| BX8' `refl_intro_since` | **REMOVE** | Symmetric |
| BX9 `until_elim` (φ U ψ)→(φ∨ψ) | **KEEP (under A2)** | Valid: guard [t, s) includes t, so φ(t) from guard when ¬ψ(t) |
| BX9' `since_elim` | **KEEP (under A2)** | Symmetric |
| BX10-BX12 (until_F, linearity, F_until) | **KEEP** | All valid under strict semantics |
| All S5 modal axioms | **KEEP** | Unaffected by temporal change |
| Modal-temporal interaction | **KEEP** | Unaffected |
| **NEW** `serial_future` ⊤→F(⊤) | **ADD** | Required: no max element (sound on ℤ, ℚ, ℝ) |
| **NEW** `serial_past` ⊤→P(⊤) | **ADD** | Required: no min element (sound on ℤ, ℚ, ℝ) |

**BX4/BX4' (connect_future/connect_past)**: φ→G(P(φ)) and φ→H(F(φ)). Under strict G and P: if φ at t, then for all s > t, P(φ) at s (because t < s and φ at t). **VALID and KEPT** under A2.

**New axiom candidate** (for sorry #4-5): `φ ∧ F(φ U ψ) → φ U ψ` (strict Until step-back). Valid under A2: if φ at t and ∃ s > t with (φ U ψ) at s, then ∃ u > s with ψ(u) and φ on [s, u), plus φ at t and φ on [t, s) is needed... Actually this needs more analysis — see Gap 2 below.

### 3. defect_step_early Uses φ→F(φ) — Chain Construction Breaks (HIGH confidence, 95%)

**Source**: Teammate D (critical unexpected finding, confirmed by A)

`RootScopedChain.lean:524-529` calls `phi_in_mcs_imp_F_phi_early` inside `defect_step_early` to prove that resolved defects remain F-preserved. Under irreflexive semantics, `φ → F(φ)` is INVALID (no BX1 to contrapose), so this line breaks.

**But this is a simplification, not a blocker**:
- Under reflexive: resolved φ automatically re-enters as F(φ) defect (defect count never decreases)
- Under irreflexive: resolved φ does NOT automatically generate F(φ) (defect count CAN decrease)
- The redesigned `defect_step_early` only preserves F-obligations for UNRESOLVED defects
- `active_defects` naturally shrinks with each resolution step

This is the architectural insight that motivated the irreflexive switch in the first place.

### 4. Sorry Site Closure Map Under Irreflexive A2 (HIGH confidence, 80%)

**Source**: Teammate D (primary), verified by B and C

| Sorry | Root Cause | Fix Under Irreflexive A2 | Needs IRR? | Confidence |
|-------|-----------|--------------------------|------------|------------|
| #1 `fwd_chain_forward_F` (line 1111) | φ→F(φ) re-entry | Redesign `defect_step_early` + finite defect induction | MAYBE (65%) | MEDIUM |
| #2 `restricted_tc` backward (line 1138) | No `preserving_bwd_step` | Build symmetric backward chain | NO | HIGH (90%) |
| #3 `restricted_tc` P-direction (line 1145) | Same as #2 | Same as #2 | NO | HIGH (90%) |
| #4 `restricted_buc` (line 1153) | Missing step transfer | Strict Until step transfer (direct) | NO | HIGH (85%) |
| #5 `restricted_fuc` (line 1160) | Depends on #1-4 | Follows once #1-4 close | NO | MEDIUM (70%) |

**Sorry #1 is the hardest**: Under irreflexive semantics, `F(φ)` can still reappear via independent Lindenbaum decisions (even though `φ → F(φ)` isn't derivable, `F(φ)` could appear from other axioms if some later chain position has φ). Two sub-paths:
- **Path B (direct)**: Finite defect induction + redesigned `defect_step_early`. Confidence: 65%.
- **Path A (IRR)**: Add IRR constructor to `ExtDerivationTree`, prove IRR soundness, use temporal induction. More infrastructure but mathematically cleaner. Confidence: 55%.

### 5. Codebase Impact — File-by-File (HIGH confidence, 90%)

**Source**: Teammate A (exhaustive analysis)

| File | Affected Items | Nature | Est. LOC |
|------|---------------|--------|----------|
| `Syntax/Axiom.lean` | Remove 4 axioms, add 2 seriality | Mechanical | 30-50 |
| `Semantics/Truth.lean` | 4 inequality flips + ~200 LOC TimeShift updates | Mechanical | 220 |
| `Metalogic/Soundness.lean` | Remove 4 validity proofs, add 2 | Mechanical | 60 |
| `BXCanonical/Frame.lean` | Delete `bx_le_refl`, rewrite `g_content_set_consistent` | Structural | 80 |
| `BXCanonical/CanonicalModel.lean` | 7 BX1/BX1' sites + enriched seed consistency | Structural | 60 |
| `BXCanonical/RootScopedChain.lean` | 10+ BX1 sites + redesign `defect_step_early` + close 5 sorries | Structural | 200+ |
| `Theorems/TemporalDerived.lean` | Delete 8 BX1-dependent theorems | Mechanical | 40 |
| `Quasimodel/` (Realization, Construction, OracleStep) | 6+ BX1/BX8 dependencies, `F_of_mem` breaks | Structural | 100+ |
| `Bundle/` (SuccRelation, SuccExistence) | 5 BX1 sites (not critical path) | Mechanical | 20 |

**Total estimated**: 800-1200 LOC (revised upward from report 47's 600-1000)

### 6. Quasimodel Is NOT Blast-Radius-Free (HIGH confidence, 85%)

**Source**: Teammate C (critical correction to report 47)

Report 47 described the quasimodel infrastructure as "887 sorry-free lines" with independent code. This is **wrong**:
- `F_of_mem` (Realization.lean:54-71) uses BX1 and is **fundamentally broken** under irreflexive G (φ → F(φ) is FALSE, not just unprovable)
- `refl_intro_until_mcs` (Construction.lean:157-162) uses BX8 directly
- `OracleStep.lean:363` calls `refl_intro_until_mcs`
- Enriched seed consistency proofs use BX1

However, the Quasimodel is NOT on the active completeness path (`dd_countermodel` goes through `RootScopedChain.lean`). These repairs are needed for code consistency but don't block the main completeness theorem.

### 7. F_of_mem Is Fundamentally Invalid (HIGH confidence, 90%)

**Source**: Teammates C, D

`F_of_mem` proves `ψ ∈ w → F(ψ) ∈ w` using BX1. Under irreflexive G, this is **FALSE** (not just unprovable): a model where ψ holds at t but ¬ψ at all s > t has F(ψ) false at t. This cannot be repaired — it must be deleted and call sites redesigned.

This is a **positive change** for the chain construction: the absence of `ψ → F(ψ)` means resolved defects cannot automatically re-enter. This is the core mechanism that unblocks sorry #1.

### 8. Density Loss Is Non-Blocking (HIGH confidence, 85%)

**Source**: Teammate A

Under strict G on ℤ: `G(G(φ)) → G(φ)` (density) is NOT derivable — there is no integer strictly between t and t+1. However:
- The current codebase derives `density_derivable` from BX1, which will be deleted
- Density is used in `TemporalDerived.lean` but NOT in the BXCanonical completeness path
- The completeness proof uses `temp_4` (G→GG), not density (GG→G)

**Impact**: `density_derivable` and `past_density_derivable` are deleted. No impact on the completeness proof.

### 9. ConservativeExtension/IRR Infrastructure Status (HIGH confidence, 95%)

**Source**: Teammate D

`ExtDerivationTree` has **NO IRR constructor** despite the directory name suggesting IRR support. The infrastructure implements:
- `ExtFormula` with fresh atom `freshAtom = Sum.inr ()`
- `embedDerivation` (base → extended)
- `substFormula` (replace fresh with ⊥)
- `liftFormula` / `lift_derivation_qfree` (extended → base)

This is conservative extension machinery (F+ → F lifting), NOT IRR. To use IRR proof-theoretically, a new constructor must be added:
```lean
| irr (φ : ExtFormula) (p_fresh_ctx : ...) (p_fresh_concl : ...)
    (d : ExtDerivationTree [{p ∧ H(¬p)}] φ) : ExtDerivationTree [] φ
```

IRR soundness under strict H: For any world w, set p := {w}. Then H_strict(¬p) holds at w (all s < w have s ≠ w). By d, φ holds at w. Since w arbitrary, φ is valid.

## Synthesis

### Conflicts Resolved

**Conflict 1: BX9 validity under strict Until**

| Position | Teammate | Evidence |
|----------|----------|---------|
| BX9 "needs careful analysis" | A | Guard convention unclear |
| BX9 VALID under A2 | B | Half-open guard [t, s) includes t |
| BX9 INVALID | C | Countermodel with open guard (t, s) |

**Resolution**: C's countermodel assumes A1 (open guard). Under A2 (half-open guard [t, s)), the guard includes t, making BX9 valid. **Decision: A2**. This is also the minimal change from the current semantics (only the witness constraint changes).

**Conflict 2: Whether IRR is needed for sorry #1**

| Position | Teammate | Confidence |
|----------|----------|------------|
| IRR needed for global termination | D | 60% |
| Finite defect induction suffices | D | 65% |
| defect_step_early redesign is key | D | 95% |

**Resolution**: Both paths remain open. The key prerequisite for either is redesigning `defect_step_early` to not use `φ → F(φ)`. Once that's done:
- If defect counts strictly decrease → finite induction closes sorry #1 without IRR
- If independent Lindenbaum re-entry proves resistant → IRR provides the global argument

**Decision**: Attempt Path B (direct) first. Build IRR infrastructure in parallel as fallback.

**Conflict 3: Blast radius estimate**

| Estimate | Source | Basis |
|----------|--------|-------|
| 600-1000 LOC | Report 47 | Initial estimate |
| 300-400 LOC affected | Teammate A | Lines changed/deleted |
| 800-1400 LOC | Teammate C | Including Quasimodel repairs |

**Resolution**: A counts affected existing lines; C includes new code for repairs. The realistic estimate for a complete switch (including Quasimodel consistency but excluding sorry closures) is **600-800 LOC of mechanical changes**. Sorry closures add **200-400 LOC of new proofs**. **Total: 800-1200 LOC**.

### Gaps Identified

1. **Strict Until step-back axiom**: `φ ∧ F(φ U ψ) → φ U ψ` — is this valid under A2? Under A2: if φ at t and ∃ s > t with (φ U ψ) at s, then ∃ u > s with ψ(u) and φ on [s, u). We need φ on [t, u): φ at t (given), φ on (t, s) (NOT given — we don't know what's between t and s). So `φ ∧ F(φ U ψ) → φ U ψ` is **NOT valid under A2** in general. It requires φ on the entire gap (t, s). The correct step transfer is the SEMANTIC argument: given φ U ψ at r+1 (with specific chain-level witness) and φ at r, the SAME witness works at r. This is a property of the chain construction, not a general axiom. **This gap must be addressed in the plan.**

2. **BX4/BX4' under strict semantics**: φ→G(P(φ)). Under strict G/P: for all s > t, P(φ) at s iff ∃ u < s with φ(u). Take u = t (since t < s). **Valid**. Confirmed.

3. **defect_step_early redesign**: Lines 524-529 use `phi_in_mcs_imp_F_phi_early`. The redesign must: (a) NOT preserve F for resolved defects; (b) still preserve F for unresolved defects via the enriched seed. The enriched seed consistency proof in CanonicalModel.lean also uses BX1, so it needs revision too.

4. **Backward chain infrastructure** (sorries #2-3): Entirely new code (~100-150 LOC). Uses BX11' (past linearity) symmetrically to forward chain's use of BX11. Well-defined engineering task.

5. **BX9 under A2 still needs formal verification**: The argument is sound but the exact Lean proof needs: from φ U ψ with witness s > t and guard [t, s), derive φ(t) (when s > t, t ∈ [t, s), so φ(t)). Then φ ∨ ψ by left disjunct. This should be straightforward.

### ROAD_MAP.md Updates Needed

1. Add dead end: "IRR under reflexive semantics" (unsound — H(¬p) ∧ p contradicts under reflexive H)
2. Update strategy: irreflexive semantics switch with A2 guard convention
3. Note: BX9 PRESERVED under A2 (reduces blast radius vs. A1)
4. Note: `defect_step_early` must be redesigned (uses invalid `φ → F(φ)`)

## Recommendations

### Primary Path: Irreflexive Semantics with A2 Guard Convention

**Phase 1** (Mechanical, ~300 LOC): Semantic + axiom layer
- Truth.lean: Change 4 inequality constraints (≤ to <)
- Axiom.lean: Remove BX1, BX1', BX8, BX8'. Add serial_future, serial_past
- Soundness.lean: Remove 4 validity proofs, add 2 seriality proofs
- TimeShift proofs: Mechanical ≤→< updates (~200 LOC)

**Phase 2** (Structural, ~200 LOC): Canonical frame repair
- Delete `bx_le_refl` from Frame.lean
- Rewrite `g_content_set_consistent` using seriality
- Fix enriched seed consistency proofs in CanonicalModel.lean
- Fix `fwd_chain_g_content_trans` base case

**Phase 3** (Structural, ~200 LOC): Chain construction redesign
- Redesign `defect_step_early` to NOT use `φ → F(φ)` for resolved defects
- Only preserve F-obligations for UNRESOLVED defects
- Verify `active_defects` count decreases
- Build `preserving_bwd_step` (symmetric to forward)

**Phase 4** (New proofs, ~200 LOC): Close sorry sites
- Sorry #1: Finite defect induction (if defect counts decrease under redesigned chain)
- Sorries #2-3: Backward chain P-resolution using `preserving_bwd_step`
- Sorries #4-5: Until step transfer (semantic argument at chain level under A2)

**Phase 5** (Cleanup, ~100 LOC): Non-critical-path repairs
- Delete broken derived theorems (TemporalDerived.lean)
- Fix Quasimodel BX1/BX8 dependencies
- Fix Bundle BX1 sites (if needed)

**Total**: ~1000 LOC
**Confidence**: 55-70% (higher than report 47's 55-65% due to A2 preserving BX9)

### Key Decision Point

After Phase 3 (chain construction redesign), verify:
- Does `active_defects` count strictly decrease under the new `defect_step_early`?
- If YES → Phase 4 sorry #1 closes via finite induction (Path B). Confidence: 65%.
- If NO (Lindenbaum re-entry problem) → Build IRR infrastructure (Path A). Add ~150 LOC for IRR constructor + soundness. Confidence: 55%.

### Fallback: IRR Infrastructure (if Path B fails at sorry #1)

Add IRR constructor to `ExtDerivationTree`:
```lean
| irr (φ : ExtFormula) (fresh_ctx : ...) (fresh_concl : ...)
    (d : ExtDerivationTree [{freshAtom_formula ∧ H(¬freshAtom_formula)}] φ)
    : ExtDerivationTree [] φ
```
Prove soundness: For any strict model M and world w, set p := {w}. H_strict(¬p) holds at w. By d, φ holds at w.

Use IRR temporal induction for sorry #1: mark "first time F(φ) holds" with fresh atom, derive resolution within finite steps, project away the marking via IRR.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Codebase impact | completed | high | Exhaustive file-by-file analysis; density loss identified; A2 guard question raised |
| B | Axiom redesign | completed | high (80%) | Complete axiom table; A2 recommendation; step transfer proof sketch; seriality formulation |
| C | Critic | completed | high (85%) | BX9 countermodel (under A1); Quasimodel BX1/BX8 dependencies; F_of_mem invalidity; revised blast radius |
| D | IRR proof strategy | completed | medium-high (75%) | Sorry closure map; defect_step_early φ→F(φ) finding; IRR constructor spec; Path A vs Path B analysis |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I: since and until." Notre Dame J. Formal Logic 23, 367-374
- Xu, M. (1988). "On some U,S-tense logics"
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects", Vol. 1
- Current codebase: `Theories/Bimodal/Semantics/Truth.lean`, `Syntax/Axiom.lean`, `BXCanonical/RootScopedChain.lean`
