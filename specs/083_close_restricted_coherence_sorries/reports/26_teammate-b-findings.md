# Teammate B Findings: Migration Catalog for Switching to Reflexive Semantics

## Executive Summary

Switching from strict semantics (`<`) to reflexive semantics (`<=`) affects **24-30 active Lean files** across 5 module groups. The change is decomposable into three categories:

- **Mechanical** (< to <=, ~60% of changes): Truth definition, FMCS coherence conditions, soundness lemma quantifiers
- **Structural** (proof strategy changes, ~30%): Axiom system refactoring, completeness construction simplification, CanonicalIrreflexivity elimination
- **New** (new proofs/recoveries from archive, ~10%): T-axiom validity, archived function restoration

The Boneyard archive contains 3 files with code that was **working** under reflexive semantics and can be directly restored. The switch would **eliminate** the `deterministic_forward_F` and `deterministic_backward_P` sorries (the two leaf blockers for completeness) because the T-axiom becomes valid, enabling the archived `forward_G`/`backward_H` propagation pattern.

**Total estimated scope**: ~1,500-2,000 lines modified, ~400 lines restored from archive, ~200 lines deleted (irreflexivity infrastructure).

---

## Detailed File Catalog

### Category 1: Core Semantic Definition (MUST change first)

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Semantics/Truth.lean` | 650 | Mechanical | Change `s < t` to `s <= t` and `t < s` to `t <= s` in `all_past`/`all_future`/`untl`/`snce` cases (lines 127-132). ~6 line changes in definition, ~50 lines in downstream lemmas. |
| `Syntax/Formula.lean` | 550 | Mechanical + Delete | Remove `weak_future`/`weak_past` derived operators (lines 337-352) -- they become redundant since G/H are now reflexive. Update `always` definition. ~30 lines removed. |

**Key change in Truth.lean** (line 127-132):
```
-- Current (strict):
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t < s ∧ ...
| Formula.snce φ ψ => ∃ s : D, s < t ∧ ...

-- Target (reflexive):
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ ...  (or keep t < s -- design choice)
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ ...  (or keep s < t -- design choice)
```

**Design decision for Until/Since**: Under reflexive G/H, Until/Since could use either `<=` or strict `<` for the witness. The choice affects the Until/Since axiomatization. Standard tense logic uses strict witness (`t < s`) even with reflexive G/H. This needs careful analysis.

### Category 2: Axiom System (MUST change second)

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `ProofSystem/Axioms.lean` | 928 | Structural | Add 2 T-axiom constructors, remove/modify comments, potentially change Until/Since axiom formulations. |

**Axiom additions (2 new constructors)**:
```lean
| temp_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)   -- G(φ) → φ
| temp_t_past (φ : Formula) : Axiom (φ.all_past.imp φ)       -- H(φ) → φ
```

**Axiom removals**: None strictly required. All existing axioms remain valid under reflexive semantics (they become easier to prove, not invalid).

**Axiom modifications** (potentially needed):
- `seriality_future` / `seriality_past`: Under reflexive semantics, `G(φ) → F(φ)` is trivially valid (take witness s = t). These become redundant but harmless to keep.
- `density` (`GGφ → Gφ`): Trivially valid under reflexive semantics (was only non-trivial under strict). Becomes redundant but harmless.
- Until/Since unfold/intro/induction: Depend on whether Until witness is strict or reflexive. If Until keeps strict witness, these axioms stay. If Until becomes reflexive, the X/Y-based formulations need revision.

**Classification changes**: `isBase` predicate in Axioms.lean needs updating. `temp_t_future` and `temp_t_past` become base axioms.

### Category 3: FMCS Coherence (parallel with Category 2)

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Metalogic/Bundle/FMCSDef.lean` | 127 | Mechanical | Change `t < t'` to `t ≤ t'` in `forward_G`/`backward_H` field types (lines 110, 117). ~6 lines. |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 1076 | Mechanical + Structural | Update all `t < s` to `t ≤ s` in coherence proofs. Restore archived `forward_G`/`backward_H` from Boneyard. ~100 lines changed. |
| `Metalogic/Bundle/TemporalCoherence.lean` | 481 | Mechanical | Update coherence field types and proofs. ~40 lines. |
| `Metalogic/Bundle/Construction.lean` | varies | Structural | Constant-family construction WORKS again under reflexive semantics (currently broken because `ExistsTask M M` requires T-axiom). |

**Critical simplification**: Under reflexive semantics, `forward_G` with `t ≤ t'` includes the case `t = t'`, which is exactly the T-axiom. The archived code in `CanonicalConstructionArchive.lean` uses this pattern and can be restored.

### Category 4: CanonicalIrreflexivity Module (DELETE or repurpose)

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` | 177 | Delete/Repurpose | The entire irreflexivity infrastructure (fresh atoms, `strict_of_formula_in_g_content_not_in_source`, per-construction strictness) becomes unnecessary. Under reflexive semantics, ExistsTask IS reflexive. |

**What to keep**: The `atoms_of_set` and `fresh_for_set` utilities (lines 60-129) are general-purpose and used by other modules. These should be extracted to a utility file.

**What to delete**: Lines 130-177 (per-construction strictness infrastructure). These are the workaround for strict semantics and become dead code.

### Category 5: Soundness Proofs

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Metalogic/Soundness.lean` | 1508 | Mechanical + New | Update temporal validity proofs to use `≤`. Add T-axiom validity proofs (~20 lines each). Simplify `temp_4_valid` etc. |
| `Metalogic/SoundnessLemmas.lean` | 1049 | Mechanical | Update `s < t` to `s ≤ t` in swap lemmas and duality infrastructure. ~80 lines. |
| `Metalogic/DiscreteSoundness.lean` | 51 | Mechanical | Minor comment updates. ~5 lines. |
| `Metalogic/DenseSoundness.lean` | varies | Mechanical | Minor updates. |
| `FrameConditions/Soundness.lean` | varies | Mechanical | Update frame-class validity proofs. |

**New T-axiom validity proofs** (trivial under reflexive semantics):
```lean
theorem temp_t_future_valid (φ : Formula) : ⊨ (φ.all_future.imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future
  exact h_future t (le_refl t)  -- reflexivity of ≤

theorem temp_t_past_valid (φ : Formula) : ⊨ (φ.all_past.imp φ) := by
  -- symmetric
```

### Category 6: Completeness / Chain Constructions

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 528 | Structural (Simplify) | `deterministic_forward_F` and `deterministic_backward_P` sorries may become **closeable** because the T-axiom is now available. |
| `Metalogic/Algebraic/DeterministicChain.lean` | 1044 | Mechanical | Update `t < s` conditions. Forward/backward G/H propagation becomes simpler with T-axiom. |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 582 | Mechanical | Update strict ordering to `≤` in truth lemma quantifiers. ~40 lines. |
| `Metalogic/Algebraic/DovetailedChain.lean` | ~1200 | Mechanical | Update ordering conditions. |
| `Metalogic/Algebraic/UltrafilterChain.lean` | varies | Mechanical | Update ordering. |
| `Metalogic/Bundle/SuccChainFMCS.lean` | varies | Mechanical | Update FMCS field signatures. |
| `Metalogic/Bundle/SuccChainTruth.lean` | varies | Mechanical | Update truth lemma ordering. |
| `Metalogic/Bundle/TargetedChain.lean` | varies | Structural | Restore T-axiom usage. |
| `Metalogic/Bundle/WitnessSeed.lean` | varies | Mechanical | Comments say "irreflexive-compatible, no T-axiom needed" -- these proofs still work but can be simplified. |

### Category 7: FMP / Decidability Path

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Metalogic/Decidability/FMP/TruthPreservation.lean` | 399 | Structural (Restore) | Can restore `mcs_all_future_closure` and `mcs_all_past_closure` from archive -- these become valid again with T-axiom. |
| `Metalogic/Decidability/FMP/Filtration.lean` | 323 | Mechanical | Update temporal ordering in filtration construction. |
| `Metalogic/Decidability/FMP/ClosureMCS.lean` | 279 | Mechanical | Minor updates. |
| `Metalogic/Decidability/FMP/FiniteModel.lean` | 177 | Mechanical | Minor updates. |
| `Metalogic/Decidability/Correctness.lean` | varies | Mechanical | Comment updates. |

### Category 8: Theorems / Examples (low priority)

| File | Lines | Change Type | Description |
|------|-------|-------------|-------------|
| `Theorems/TemporalDerived.lean` | varies | Simplify/Delete | `G_implies_X` becomes trivially derivable from T-axiom + temp_4. The elaborate derivation using Until machinery becomes unnecessary. |
| `FrameConditions/Completeness.lean` | 562 | Structural | Simplify; the isolated sorry in `bfmcs_from_mcs_temporally_coherent` may become closeable. |
| `Examples/*.lean` | varies | Mechanical | Update comments and proof strategies. |
| Various docstrings | varies | Mechanical | ~50 files have "strict semantics" or "irreflexive" in comments. |

---

## Axiom System Changes

### Additions
| Axiom | Formula | Justification |
|-------|---------|---------------|
| `temp_t_future` | `G(φ) → φ` | Valid under reflexive semantics (take s = t in ∀ s ≥ t) |
| `temp_t_past` | `H(φ) → φ` | Valid under reflexive semantics (take s = t in ∀ s ≤ t) |

### Removals (none required, but consider)
| Axiom | Formula | Status |
|-------|---------|--------|
| `seriality_future` | `G(φ) → F(φ)` | Becomes derivable from `temp_t_future` (G(φ)→φ, so F(φ) trivially) |
| `seriality_past` | `H(φ) → P(φ)` | Becomes derivable from `temp_t_past` |
| `density` | `GG(φ) → G(φ)` | Becomes derivable: GG(φ) → G(φ) by temp_t_future on inner G |

**Recommendation**: Keep redundant axioms for now (removing them would break downstream proofs that reference specific axiom constructors). Mark them as derivable in comments.

### Derived Theorem Changes
| Theorem | Under Strict | Under Reflexive | Notes |
|---------|-------------|-----------------|-------|
| `G(φ) → φ` | NOT valid | VALID (axiom) | Core change |
| `G(φ) → X(φ)` | Derivable (elaborate) | Trivially derivable | Simplifies |
| `X(φ) → G(φ)` | NOT valid | NOT valid | Unchanged |
| `G(φ) → X(G(φ))` | Derivable | Trivially derivable | From T-axiom + temp_4 |
| `φ U ψ` semantics | `∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)` | Design choice (see below) | Critical decision |

### Until/Since Axiomatization Under Reflexive Semantics

**Key design decision**: Does Until use strict or reflexive witness?

**Option A: Keep strict Until witness** (`∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)`):
- Until/Since axioms (unfold, intro, induction) stay as-is
- X/Y-based formulations remain natural
- Mismatch: G/H are reflexive but U/S are strict
- Standard in some formulations (e.g., Goldblatt)

**Option B: Reflexive Until witness** (`∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t,s), φ(r)`):
- `φ U ψ` becomes true when ψ holds NOW (s = t)
- Until/Since axioms need reformulation (G/H-based instead of X/Y-based)
- More uniform with reflexive G/H
- Standard in some formulations (e.g., Kamp)

**Recommendation**: Option A (keep strict Until) -- minimizes axiom changes and aligns with the X/Y discrete construction. The original reflexive codebase likely used this pattern too.

---

## Migration Ordering

### Phase 1: Core Definitions (blocks everything)
1. `Semantics/Truth.lean` -- change `<` to `≤` in truth_at definition
2. `Syntax/Formula.lean` -- mark weak_future/weak_past as deprecated

### Phase 2: Axiom System (blocks soundness/completeness)
3. `ProofSystem/Axioms.lean` -- add T-axiom constructors
4. `ProofSystem/Derivation.lean` -- no changes needed (generic over axioms)

### Phase 3: Soundness (independent of completeness)
5. `Metalogic/Soundness.lean` -- add T-axiom validity, update existing proofs
6. `Metalogic/SoundnessLemmas.lean` -- update ordering in swap lemmas
7. `Metalogic/DiscreteSoundness.lean` -- minor updates
8. `Metalogic/DenseSoundness.lean` -- minor updates

### Phase 4: FMCS Infrastructure (blocks completeness)
9. `Metalogic/Bundle/FMCSDef.lean` -- change `<` to `≤` in FMCS fields
10. `Metalogic/Bundle/CanonicalIrreflexivity.lean` -- extract utilities, delete rest
11. `Metalogic/Bundle/TemporalCoherence.lean` -- update coherence conditions
12. `Metalogic/Bundle/Construction.lean` -- simplify constant-family construction

### Phase 5: Completeness Constructions (the payoff)
13. `Metalogic/Bundle/CanonicalConstruction.lean` -- restore from archive
14. `Metalogic/Algebraic/DeterministicChain.lean` -- update ordering
15. `Metalogic/Algebraic/DeterministicFMCS.lean` -- close forward_F/backward_P sorries
16. `Metalogic/Algebraic/ParametricTruthLemma.lean` -- update truth lemma
17. `FrameConditions/Completeness.lean` -- close temporal coherence sorry

### Phase 6: FMP Path (parallel with Phase 5)
18. Restore from `TruthPreservationArchive.lean`
19. `Metalogic/Decidability/FMP/TruthPreservation.lean` -- integrate restored code
20. `Metalogic/Decidability/FMP/Filtration.lean` -- update ordering

### Phase 7: Cleanup
21. Update all docstrings and comments (~50 files)
22. `Theorems/TemporalDerived.lean` -- simplify or delete
23. `Examples/*.lean` -- update
24. `Metalogic/Metalogic.lean` -- update module map

---

## Recovery Plan from Boneyard Archives

### CanonicalConstructionArchive.lean
**Contains**: `restricted_tc_family_to_fmcs` with `forward_G` and `backward_H` implementations.
**Recovery**: Lines 18-69 can be adapted. The `forward_G` field used `temp_t_future` axiom to propagate G(ψ) → ψ at the target MCS. Under reflexive semantics, this becomes valid again.
**Effort**: ~50 lines, mostly mechanical restoration.

### TargetedChainArchive.lean
**Contains**: `targeted_forward_chain_forward_G`, `targeted_backward_chain_backward_H`, `targeted_fam_forward_G`, `targeted_fam_backward_H`, `TargetedFMCS`, `TargetedFMCS_at_zero`.
**Recovery**: All 6 functions (169 lines). The sorry markers at `/- was: temp_t_future phi -/` and `/- was: temp_t_past phi -/` would be replaced with actual T-axiom references.
**Effort**: ~169 lines, purely mechanical: replace `sorry` with axiom references.

### TruthPreservationArchive.lean
**Contains**: `mcs_all_future_closure`, `mcs_all_past_closure`, `filtration_all_future_forward`, `filtration_all_past_forward`.
**Recovery**: All 4 functions (80 lines). Under reflexive semantics, `Gψ ∈ S → ψ ∈ S` is derivable via T-axiom.
**Effort**: ~80 lines, mechanical restoration. The sorry placeholders become actual proofs using T-axiom + MCS closure.

---

## Effort Estimate

| Category | Files | Lines Changed | Lines New | Lines Deleted | Person-Hours |
|----------|-------|---------------|-----------|---------------|-------------|
| Core definitions (Phase 1) | 2 | ~80 | 0 | ~30 | 2-3 |
| Axiom system (Phase 2) | 1 | ~40 | ~20 | 0 | 1-2 |
| Soundness (Phase 3) | 4 | ~200 | ~40 | 0 | 4-6 |
| FMCS infrastructure (Phase 4) | 4 | ~100 | 0 | ~100 | 3-4 |
| Completeness (Phase 5) | 5 | ~300 | ~250 (restored) | ~50 | 6-10 |
| FMP path (Phase 6) | 3 | ~50 | ~80 (restored) | 0 | 3-4 |
| Cleanup (Phase 7) | ~50 | ~500 (comments) | 0 | 0 | 4-6 |
| **Total** | **~30** | **~1,270** | **~390** | **~180** | **23-35** |

---

## Confidence Level

**Overall: MEDIUM-HIGH**

| Aspect | Confidence | Rationale |
|--------|------------|-----------|
| File catalog completeness | HIGH | Systematic grep for `< t`, `t <`, `irrefl`, `strict`, `sorry` |
| Mechanical changes | HIGH | Well-understood substitution pattern (< to ≤) |
| Axiom system correctness | HIGH | Standard tense logic; T-axioms are textbook |
| Completeness unblocking | MEDIUM | The archived code worked, but the "restricted coherence sorries" that originally motivated the switch to strict need investigation -- they may resurface |
| FMP path unblocking | MEDIUM-HIGH | The archived filtration code directly used T-axiom; restoration is straightforward |
| Until/Since interaction | MEDIUM | Design decision (strict vs reflexive witness) has ripple effects not fully mapped |

### Key Risk: Why Did the Project Switch Away?

The Truth.lean docstring states: "reflexive semantics caused problems with the canonical completeness construction (restricted coherence sorries)." The CanonicalConstructionArchive.lean reveals the specific problem: **independent Lindenbaum extensions cannot propagate G/H across time points** (line 41-58 of archive).

Under reflexive semantics with T-axiom:
- `G(ψ) ∈ MCS(t)` implies `ψ ∈ MCS(t)` (by T-axiom, at SAME time point)
- But `G(ψ) ∈ MCS(t)` does NOT automatically imply `ψ ∈ MCS(t')` for independent MCS(t')

The T-axiom only gives the reflexive case (t = t'). For t' > t, you still need the chain construction to propagate G forward. The archive's sorry was specifically about this inter-MCS propagation.

**However**: The deterministic chain construction (DeterministicChain.lean) solves inter-MCS propagation using x_content/y_content stepping. The T-axiom handles the reflexive case (t = t'), and the chain handles strict cases (t < t'). Together they should close the FMCS `forward_G` field completely. This is exactly what `targeted_fam_forward_G` in the archive does -- it propagates G forward via chain stepping and applies T-axiom at the target. The sorry was in the T-axiom application, not in the chain propagation.

**Conclusion**: The original problem was that reflexive semantics requires T-axiom for `forward_G(t, t')` when `t = t'`, but the T-axiom wasn't available in the CanonicalConstruction path. Switching to strict semantics eliminated the `t = t'` case entirely (by using `<` instead of `≤`). But this created new problems: the `forward_F`/`backward_P` obligations became harder to discharge. Switching back to reflexive semantics re-enables T-axiom for the `t = t'` case while the deterministic chain handles `t < t'`, giving a complete path.
