# Teammate C Findings: ROADMAP Updates and Progress Assessment

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Focus**: Sorry census, completeness dependency graph, ROADMAP assessment, publication readiness
**Confidence Level**: HIGH for sorry census and dependency tracing; MEDIUM for publication readiness

## 1. Sorry Census

### 1.1 Total Count

| Metric | Value |
|--------|-------|
| Total Lean files (excl. Boneyard) | 125 |
| Files with sorry (any reference) | 35 |
| Files without any sorry token | 90 |
| Percentage sorry-free (by file) | 72.0% |
| Total lines of Lean code | ~59,844 |
| Actual sorry call sites | ~76 (as of latest summary), ~85 by current grep |

Note: The count discrepancy is due to some sorry sites being in comments that describe the gap vs actual `sorry` tactic calls. The grep-based count of ~85 includes some comment-adjacent sorries. The implementation summary from plan v12 counted 76 sorry tokens.

### 1.2 Sorry Sites by Category

#### Category A: Soundness -- Frame-Class Restricted (19 sites, INTENTIONAL)

**File**: `Metalogic/Soundness.lean` (lines 977-994, 1018)

| Axiom Group | Count | Nature |
|-------------|-------|--------|
| Density axiom | 1 | Requires DenselyOrdered constraint |
| Discreteness axioms | 2 | Requires SuccOrder/PredOrder |
| Seriality axioms | 2 | Requires NoMaxOrder/NoMinOrder |
| Disc_next/disc_prev | 2 | Requires SuccOrder/PredOrder |
| Until axioms (6) | 6 | Require Until/Since frame-class spec |
| Since axioms (4) | 4 | Require Until/Since frame-class spec |
| temporal_duality | 1 | Intentional -- documents frame-class restriction |

**Assessment**: These are architecturally intentional. The general `soundness` theorem cannot handle frame-class-restricted axioms without additional type constraints. The `soundness_dense` theorem (verified sorry-free) handles the dense frame class properly. These 19 sorries are NOT on the completeness critical path and are semantically correct documentation of the frame-class separation.

**lean_verify result**: `soundness` has `sorryAx`; `soundness_dense` is sorry-free (propext, Classical.choice, Quot.sound only).

#### Category B: Completeness Critical Path (26+ sites, BLOCKING)

These are the sorries that prevent `completeness_over_Int` from being sorry-free. Currently `lean_verify` confirms it depends on `sorryAx`.

| File | Sites | Issue |
|------|-------|-------|
| CanonicalConstruction.lean | 8 | Until/Since truth lemma (forward + backward, both directions); restricted_tc for Until/Since |
| DovetailedChain.lean | 6 | Forward_F strict witness (line 1240), Backward_P strict witness (line 1247), Until/Since persistence through chain steps |
| SuccChainFMCS.lean | ~11 | g_content_subset (T-axiom gone), seed consistency, temp_t_future/past removal gaps, cross-chain forwarding |
| UltrafilterChain.lean | 2 | succ_chain_restricted_forward_F, succ_chain_restricted_backward_P |
| SuccRelation.lean | 1 | Succ relation property |
| SuccExistence.lean | 3 | Seed consistency proofs |
| TargetedChain.lean | 4 | temp_t_future/past removal gaps (was: axiom call sites) |
| WitnessSeed.lean | 2 | Until/since witness seed |
| SimplifiedChain.lean | 1 | G-lift for restricted seed |

**Root cause**: The strict semantics refactor (plan v11, phases 1-4 completed) changed `<=` to `<` everywhere, removed the T-axioms (`G(phi) -> phi`, `H(phi) -> phi`), and replaced Until/Since axioms with X/Y-based versions. This broke the `g_content(u) subset u` pattern used throughout the chain infrastructure. The fix requires X-content propagation infrastructure (X(alpha) in mcs(t) gives alpha in mcs(t+1)).

#### Category C: Algebraic Path (13 sites, NON-CRITICAL)

| File | Sites | Issue |
|------|-------|-------|
| RestrictedTruthLemma.lean | 3 | Phase 4 restructuring pending |
| ParametricTruthLemma.lean | 4 | Parametric Until/Since cases |
| DovetailedChain.lean | (counted in B above) | Shared with critical path |

**Assessment**: The algebraic path was an experimental alternative approach. Not on any publication path.

#### Category D: FMP / Decidability (2 sites, NEAR-READY)

**File**: `Decidability/FMP/TruthPreservation.lean` (lines 263, 281)

These are `mcs_all_future_closure` and `mcs_all_past_closure`. Task 82 is dedicated to closing these. The FMP completeness theorem (`fmp_completeness`) is verified sorry-free by `lean_verify`. These 2 sorries would give weak completeness via the FMP path.

**lean_verify result**: `fmp_completeness` has NO `sorryAx` -- it is already sorry-free.

#### Category E: Derived Theorems (4 sites, MEDIUM)

**File**: `Theorems/TemporalDerived.lean` (lines 240, 247, 263, 271)

These are `X_bot_absurd`, `Y_bot_absurd`, `until_implies_some_future`, `since_implies_some_past`. Created during the strict semantics refactor. Semantically valid but syntactic derivation appears non-trivial.

#### Category F: Examples (14 sites, NON-CRITICAL)

| File | Sites |
|------|-------|
| Demo.lean | 1 (completeness direction) |
| ModalProofs.lean | 5 |
| ModalProofStrategies.lean | 5 |
| TemporalProofs.lean | 2 |

**Assessment**: Pedagogical examples with placeholder sorry for exercises. Not blocking any formal result.

### 1.3 Custom Axioms

| Axiom | Location | Status |
|-------|----------|--------|
| `discrete_Icc_finite_axiom` | Task 60 | Scheduled for removal |

One custom axiom remains. Task 60 is dedicated to removing it. Goal: zero custom axioms.

## 2. Completeness Dependency Graph

### 2.1 Main Completeness Theorem

```
completeness_over_Int  [HAS sorryAx]
  |
  +-- dovetailed_bundle_validity_implies_provability  [HAS sorryAx]
       |
       +-- not_provable_implies_neg_consistent         [CLEAN]
       +-- neg_consistent_gives_mcs_without_phi        [CLEAN]
       +-- construct_dovetailed_bfmcs_bundle           [CLEAN]
       +-- dovetailed_bundle_to_bfmcs                  [CLEAN]
       +-- dovetailed_bfmcs_restricted_temporally_coherent  [HAS sorryAx]
       |    |
       |    +-- shifted_restricted_forward_F            [CLEAN? - separate from DovetailedFMCS]
       |    +-- DovetailedFMCS_forward_F               [HAS sorryAx] *** KEY SORRY ***
       |    |    reason: gives s >= t but needs s > t (strict semantics)
       |    +-- DovetailedFMCS_backward_P              [HAS sorryAx] *** KEY SORRY ***
       |         reason: gives s <= t but needs s < t (strict semantics)
       |
       +-- shiftClosedCanonicalOmega_is_shift_closed   [CLEAN]
       +-- canonicalOmega_subset_shiftClosed           [CLEAN]
       +-- restricted_shifted_truth_lemma              [HAS sorryAx]
            |
            +-- Until/Since cases                      [HAS sorryAx] *** KEY SORRY ***
                 reason: need X-content propagation for strict Until semantics
```

### 2.2 Alternative Completeness Paths

```
[PATH 1: Dovetailed Canonical]  <-- CURRENT FOCUS
  completeness_over_Int -> dovetailed chain
  Status: HAS sorryAx
  Blockers: DovetailedFMCS_forward_F/backward_P (strict witness gap)
            + Until/Since truth lemma cases in CanonicalConstruction

[PATH 2: FMP Weak Completeness]
  fmp_completeness -> tableau decision procedure
  Status: CLEAN (no sorryAx!)
  Note: Already sorry-free, gives weak completeness for propositional fragment

[PATH 3: Old Bundle Path]
  bundle_validity_implies_provability -> bfmcs_from_mcs_temporally_coherent
  Status: HAS sorryAx (different sorry -- family-level coherence)
  Note: Superseded by dovetailed path

[PATH 4: Dense Completeness]
  dense_completeness_fc
  Status: HAS sorryAx (separate sorry, task 68)
  Note: Int is not dense; requires Rat canonical model
```

### 2.3 Soundness Status

```
soundness (general)           [HAS sorryAx] -- frame-class restricted axioms
soundness_dense               [CLEAN]       -- sorry-free for dense frames
soundness_dense_valid          [CLEAN]       -- bridge theorem
```

### 2.4 Key Theorems -- Axiom Audit

| Theorem | sorryAx? | Custom Axioms? |
|---------|----------|----------------|
| `soundness_dense` | NO | NO |
| `fmp_completeness` | NO | NO |
| `completeness_over_Int` | YES | NO |
| `discrete_completeness_fc` | YES | NO |
| `dense_completeness_fc` | YES | NO |
| `shifted_truth_lemma` | YES | NO |
| `restricted_shifted_truth_lemma` | YES | NO |

## 3. Current State Assessment

### 3.1 What Has Been Achieved

The strict semantics refactor (plan v11) completed phases 1-4 and partial phase 5:

- **Phase 1 [COMPLETED]**: Syntax foundation -- Next/Prev operators, 33 axioms (was 34), axiom classifications
- **Phase 2 [COMPLETED]**: Semantic truth -- all `<=` changed to `<` in truth_at
- **Phase 3 [COMPLETED]**: Soundness validity proofs for all new/replaced axioms
- **Phase 4 [COMPLETED]**: Soundness lemmas, algebraic layer (TenseS5Algebra, InteriorOperators)
- **Phase 5 [PARTIAL]**: FMCS and chain infrastructure partially updated

Additional work completed:
- `G(a) -> X(a)` and `H(a) -> Y(a)` derived theorems proven
- Enriched seed approach validated (g_content in seed directly)
- R_G/R_H reflexivity deleted (correct under strict semantics)
- Build compiles with 0 errors (all sorry sites are type-checked)
- 12 research rounds with team synthesis completed
- 7 plan versions explored, converging on strict semantics as the correct approach

### 3.2 What Remains for Sorry-Free Completeness

Phases 6-9 of plan v11 remain:

1. **Phase 6**: DovetailedChain + SuccExistence -- g_content/h_content propagation via seed membership, X-content propagation
2. **Phase 7**: UltrafilterChain, MCSWitnessSuccessor, TargetedChain -- remove remaining T-axiom dependencies
3. **Phase 8**: CanonicalConstruction + RestrictedTruthLemma -- close Until/Since truth lemma via contrapositive
4. **Phase 9**: Integration, cleanup, full build verification

**Estimated remaining effort**: ~10-12 hours (phases 6-9 at ~2-3h each)

### 3.3 The Core Theoretical Gap

The key unresolved question: **X-content propagation**. Under strict semantics:
- `X(alpha) = bot U alpha` is not a G-formula and not an F-formula
- The Succ relation only propagates g_content and f_content
- X(alpha) in mcs(t) should give alpha in mcs(t+1) semantically, but the chain doesn't enforce this

Resolution options (from report 12):
1. Extend Succ to propagate X-content (structural change)
2. Derive F(alpha) from X(alpha) via until_induction, then use F-content propagation (proof-theoretic)
3. Specialized truth lemma cases for X-formulas (induction-based)

## 4. ROADMAP Assessment

### 4.1 Existing TODO.md Metrics (as stated)

```yaml
sorry_count: 20  # OUTDATED -- actual is ~76-85
publication_path_sorries: 4  # OUTDATED -- actual critical path is ~26
axiom_count: 1  # CORRECT (discrete_Icc_finite_axiom)
build_errors: 0  # CORRECT
```

The sorry counts in TODO.md metadata are stale. They predate the strict semantics refactor which introduced new sorry sites while fixing the architectural approach.

### 4.2 Milestones Achieved

| Milestone | Status | Notes |
|-----------|--------|-------|
| Axiom system formalization (33 axioms) | DONE | Strict semantics, X/Y-based Until/Since |
| Semantic truth definition (strict <) | DONE | All temporal quantification strict |
| Soundness (dense frames) | DONE | `soundness_dense` is sorry-free |
| Soundness (general) | PARTIAL | Frame-class sorries are intentional |
| FMP completeness | DONE | `fmp_completeness` is sorry-free |
| Decidability (tableau) | DONE | Decision procedure with proof/countermodel extraction |
| Perpetuity principles P1-P6 | DONE | All sorry-free |
| Propositional theorems | DONE | 8 theorems, zero sorry |
| Combinators | DONE | 15+ combinators, zero sorry |
| Canonical completeness (Int) | IN PROGRESS | sorryAx via strict witness gap |
| Discrete completeness | BLOCKED | Reduces to Int completeness |
| Dense completeness | NOT STARTED | Requires separate Rat model (task 68) |
| Custom axiom removal | NOT STARTED | Task 60 |
| S5 modal theorems | PARTIAL | Some exercises with sorry |

### 4.3 Milestones Remaining for Publication-Ready

| Priority | Milestone | Task | Effort | Blocking? |
|----------|-----------|------|--------|-----------|
| P0 | Sorry-free canonical completeness over Int | 83 (phases 6-9) | 10-12h | YES |
| P0 | Remove `discrete_Icc_finite_axiom` | 60 | 2-4h | YES |
| P1 | Close FMP TruthPreservation sorries | 82 | 1-2h | NO (already sorry-free) |
| P1 | Wire discrete completeness | 58 | 2-4h | Blocked on 83 |
| P2 | Dense completeness | 68 | 8-12h | NO |
| P2 | Clean up examples | 949 | 2-4h | NO |
| P3 | Algebraic path cleanup | 18, 20, 21 | Defer | NO |

## 5. Proposed ROADMAP Updates

### 5.1 Update Sorry Count Metadata

```yaml
technical_debt:
  sorry_count: 85
  sorry_count_note: "Post strict-semantics refactor (2026-04-03): 19 soundness (intentional frame-class), ~26 completeness critical path (strict witness gap + X-content), 13 algebraic (non-critical), 2 FMP (task 82), 4 temporal derived, 14 examples, ~7 misc chain. Task 83 phases 6-9 will close critical path."
  publication_path_sorries: 26
  axiom_count: 1
  axiom_count_note: "discrete_Icc_finite_axiom (task 60)"
  build_errors: 0
  status: good
```

### 5.2 Updated Critical Path

```
83 (phases 6-9) → 58 (wire completeness) → 60 (remove axiom)
                ↘ 82 (FMP, parallel)
```

### 5.3 Proposed New Milestones

**M1: Sorry-Free Canonical Completeness** (task 83, ~10-12h remaining)
- Close DovetailedFMCS_forward_F/backward_P (strict witness)
- Close Until/Since truth lemma cases
- X-content propagation infrastructure
- lean_verify confirms completeness_over_Int has no sorryAx

**M2: Zero Custom Axioms** (task 60, ~2-4h)
- Remove discrete_Icc_finite_axiom
- Prove Fintype for Icc in Int via Int.toNat + Finset.range

**M3: Full Discrete Completeness** (task 58, ~2-4h, depends on M1)
- Wire discrete_completeness_fc through typeclass API
- Verify sorry-free end-to-end

**M4: FMP Weak Completeness Documentation** (task 82, ~1-2h, parallel)
- Close mcs_all_future_closure and mcs_all_past_closure
- Document that FMP path is already sorry-free

**M5: Dense Completeness** (task 68, ~8-12h)
- Build Rat canonical model
- Prove dense_completeness_fc

**M6: Publication Polish** (new task needed, ~8-12h)
- Update all module docstrings
- Clean up examples (close sorry exercises or mark explicitly)
- Theorem naming audit
- README and documentation refresh

## 6. Publication Readiness Scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| **Core Formalization** | 8/10 | Axiom system, semantics, soundness all solid |
| **Completeness** | 5/10 | FMP done, canonical has sorryAx |
| **Custom Axioms** | 8/10 | Only 1, with clear removal path |
| **Module Organization** | 9/10 | Well-structured: Syntax, ProofSystem, Semantics, Metalogic, Theorems |
| **Docstring Coverage** | 8/10 | 125 files, 100% have module docstrings (/-!) |
| **Naming Conventions** | 7/10 | Generally consistent but some legacy names (e.g., BFMCS, FMCS) |
| **Example Coverage** | 5/10 | 4 example files but many exercises have sorry |
| **Test Coverage** | 6/10 | Tests/ directory exists but coverage unknown |
| **Theorem Coverage** | 7/10 | Perpetuity, propositional, combinators complete; S5 partial |
| **Build Health** | 10/10 | Zero build errors, clean compilation |
| **Overall** | 7.3/10 | Strong foundation, needs completeness and polish |

### What Reviewers Would Expect

For a publication-quality Lean 4 formalization of bimodal TM logic, reviewers would expect:

1. **Sorry-free soundness and completeness**: Soundness_dense is clean. Completeness needs ~10-12h more work (task 83).
2. **Zero custom axioms**: One remains (task 60, low effort).
3. **Decidability**: Already done and sorry-free.
4. **Standard metatheorems**: Soundness, completeness, decidability, FMP -- all present.
5. **Derived theorems**: Perpetuity P1-P6 all proven. Combinators complete.
6. **Clean axiom audit**: `lean_verify` should show only standard Lean axioms. Currently blocked by sorryAx.
7. **Examples demonstrating the system**: Present but need sorry cleanup.

### Missing Standard Results

- **Conservative extension theorem**: Present but not fully developed
- **Compactness**: Not formalized (would be a separate contribution)
- **Interpolation**: Not formalized (very complex, not expected for initial publication)

## 7. Recommended Priority Ordering

1. **IMMEDIATE**: Task 83 phases 6-9 -- This is the single most important remaining work. Closing the strict witness gap and X-content propagation unblocks everything else.

2. **SHORT-TERM** (after 83):
   - Task 60: Remove discrete_Icc_finite_axiom (quick win, zero custom axioms)
   - Task 82: Close FMP TruthPreservation sorries (quick win, weak completeness documentation)
   - Task 58: Wire discrete completeness through typeclass API

3. **MEDIUM-TERM**:
   - Task 68: Dense completeness via Rat canonical model
   - New task: Publication polish (docstrings, examples, naming audit)
   - Task 949: Update Demo.lean

4. **DEFER**:
   - Tasks 18, 20, 21: Algebraic path cleanup (not on publication path)
   - Tasks 74-76: Strict temporal extensions research (future work section)
   - Task 953: Bilateral proof system (separate contribution)

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| X-content propagation intractable | LOW | HIGH | Option 2 (derive F from X) validated in report 12 |
| Contrapositive backward truth lemma has gap | LOW | MEDIUM | Direct induction fallback documented |
| dense_completeness_fc harder than expected | MEDIUM | LOW | Not blocking publication path |
| Strict semantics creates new sorry cascades | LOW | MEDIUM | Build currently clean; remaining work is localized |
| Publication timeline pressure | MEDIUM | MEDIUM | FMP completeness is already done; could publish with FMP + canonical-in-progress |

## Summary

The formalization is in strong shape with a clear path to completion. The strict semantics refactor was a significant architectural improvement that temporarily increased sorry count but put the project on a mathematically correct foundation. The critical path to sorry-free canonical completeness is well-understood (task 83, phases 6-9, ~10-12 hours). FMP completeness is already sorry-free. One custom axiom remains with a clear removal plan. Publication readiness is estimated at 7.3/10 with 20-30 hours of remaining work to reach 9/10.
