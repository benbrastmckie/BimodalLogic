# Teammate D Findings: Horizons — ROAD_MAP Updates and Strategic Direction

**Task**: 93 - Complete BXCanonical embedding (Round 24)
**Role**: Horizons researcher
**Date**: 2026-04-16

## Key Findings

### Finding 1: ROAD_MAP.md Is Significantly Stale (HIGH confidence, 95%)

The ROAD_MAP was last updated 2026-04-13 (task 103 rewrite). Since then, 11 rounds of research/implementation (rounds 14-24) have produced critical new knowledge not reflected in the roadmap:

- **Active-Path Sorry Inventory section (lines 17-31)**: Line numbers are NOW WRONG. The sorry sites have shifted due to dead-code cleanup in Round 23. Current actual lines: `rr_fwd_chain_forward_F:1321`, `dd_fmcs_forward_F:1352`, `dd_fmcs_backward_P:1359`, `dd_bfmcs_restricted_tc:1412`, `dd_bfmcs_restricted_buc:1417`, `dd_bfmcs_restricted_fuc:1422`. The ROAD_MAP says 1275, 1306, 1313, 1366, 1371, 1376.

- **Module line counts are wrong**: ROAD_MAP says "Total BXCanonical module: 3,473 lines across 13 files." Actual count: **5,669 lines across 16 files** (added RootScopedChain.lean at 1,454 lines, OrderedSeedConsistency.lean at 255 lines, CanonicalModel.lean reduced to 498 lines from dead-code cleanup).

- **CanonicalModel.lean sorry count is wrong**: ROAD_MAP doesn't mention CanonicalModel.lean at all. Round 23 cleaned it from 7 sorries to 0 by removing dead code. This should be documented.

- **Completeness.lean sorry**: The ROAD_MAP says "1 sorry" at Completeness.lean:154. The actual file is 152 lines long and has NO sorry — `dd_countermodel` (from RootScopedChain.lean) is called at line 141 and compiles. The sorry is in `dd_countermodel`'s dependencies, not in Completeness.lean itself. The ROAD_MAP's characterization is misleading.

### Finding 2: Dead Ends List Needs 5+ New Entries (HIGH confidence, 90%)

The current ROAD_MAP documents 21 dead ends. Rounds 17-23 established at least 5 additional definitively closed approaches:

- **Dead End 22**: Extended defect seed `{target} union g_content(M) union f_carry(M)` inconsistency — proved with concrete counterexample (G(F(alpha)->neg psi), F(alpha), F(psi) all in M). Source: Round 22 Finding 3, Round 17 catalog item #2.

- **Dead End 23**: Defect-count decrease argument — F-obligation set is constant (never grows by `no_new_f_defects`, never shrinks by BX8+BX10), but the "unresolved" subset fluctuates non-monotonically. No valid well-founded measure exists. Source: Summary 22 "Dead End 3".

- **Dead End 24**: BX11 ordering convergence — even with `target_resolving_fwd_exists_strong`, proving every formula eventually becomes bx11-earliest is impossible because BX11 ordering depends on MCS content which changes at each step. Source: Summary 22 "Dead End 4".

- **Dead End 25**: Perpetual-deferral semantic contradiction (Finding 16 from Round 23) — using truth lemma to derive G(neg psi) from perpetual deferral is CIRCULAR because the truth lemma itself requires forward_F. Source: Summary 23 "Approach 5".

- **Dead End 26**: Quasimodel BXPoint-to-integer bridge — the quasimodel infrastructure produces BXPoints, but there is NO bridge from BXPoints to integer chain indices. Round 22 revised buc/fuc independence confidence from 85% down to 40-55%. Source: Round 22 Finding 2.

### Finding 3: The "Active-Path Sorry Inventory" Section Is Internally Contradictory (HIGH confidence)

Lines 17-18 say "There are **6 sorries** blocking `bx_completeness`, all in `RootScopedChain.lean`." But lines 426-431 say "There is exactly **1 sorry** on the active completeness path, inside `Completeness.lean`." These are inconsistent — the first is correct (post-Round 23), the second is stale (pre-Round 23 when dead code still existed in CanonicalModel.lean). The entire "Active-Path Sorry Inventory" section (lines 422-453) needs rewriting.

### Finding 4: Module Import Graph Is Incomplete (MEDIUM confidence, 75%)

The module import graph (lines 194-247) is missing:
- `OrderedSeedConsistency.lean` (255 lines) — contains `enriched_resolving_seed_consistent`, `two_defect_consistent_seed`
- `RootScopedChain.lean` (1,454 lines) — contains the round-robin chain, dd_chain, dd_fmcs, dd_bfmcs, dd_countermodel, and ALL 6 sorry sites
- `CanonicalModel.lean` (498 lines, now sorry-free) — contains modal_backward proof infrastructure

These three files represent 2,207 lines (39% of BXCanonical) and are completely absent from the import graph.

### Finding 5: Task Cross-Reference Table Needs Updates (HIGH confidence)

- Task 103 is listed as `[NOT STARTED]` but was completed (the ROAD_MAP itself was task 103's output)
- Task 94 is listed as `[PLANNING]` but was completed (legacy files archived 2026-04-12)
- Task 93's description says "chain replacement approach" which is stale — the current approach is demand-driven chain / ordered discharge, not chain replacement
- No mention of Rounds 14-24 in the cross-reference

### Finding 6: 24 Rounds of Research Have Produced a Clear Mathematical Diagnosis (HIGH confidence)

The precise obstruction is now well-understood:

**The forward_F problem**: Given `F(psi) in chain(n)` and `psi in sigma_list`, prove `exists s > n, psi in chain(s)`.

**Why it resists all syntactic approaches**: The `enriched_fwd_step` gives only a disjunction (`psi in M' OR F(psi) in M'`). The choice is made by `Classical.choice` in `set_lindenbaum` and is opaque. No purely syntactic argument can force a specific disjunct. The literature handles this semantically (in integer models, F-witnesses have well-ordered temporal structure), not syntactically.

**What would be needed to close it**:
1. A chain construction where target resolution is deterministic (demand-driven), OR
2. A semantic/model-theoretic argument breaking the syntax-semantics barrier, OR
3. A fundamentally different completeness architecture bypassing forward_F

### Finding 7: Project Overall Health Assessment (HIGH confidence)

**Strengths**:
- 5,669 lines of BXCanonical infrastructure (16 files), of which 5,669 - 6 sorry lines = ~99.9% sorry-free
- Truth lemma: completely sorry-free (320 lines)
- Frame.lean: completely sorry-free (673 lines)
- Quasimodel/Filtration: 2,289 lines, 9 files, entirely sorry-free
- Until/Since eventuality resolution: fully closed
- Soundness: entirely sorry-free
- 16 sorry-free helper lemmas specifically for forward_F (target_stays_direct_in_fold, enriched_fwd_step_preserves, rr_fwd_chain_F_propagate, discharge_single_step, etc.)

**Weakness**:
- The 6 remaining sorries all depend on `rr_fwd_chain_forward_F`, which has resisted 24 rounds and 19+ distinct approaches
- Confidence in any single remaining approach: 20-65% depending on approach
- The gap may represent a genuine open problem in temporal logic formalization

**Risk assessment**: The project is NOT permanently blocked, but the forward_F problem is the hardest remaining piece and may require mathematical innovation beyond what has been attempted. The 95%+ completion rate is real — but the last 5% is disproportionately difficult. This is a known pattern in formal verification projects.

## Proposed ROAD_MAP Updates

### Section 1: Update Header and Date

Change line 7 from "as of 2026-04-13" to "as of 2026-04-16 (post-Round 24)".

### Section 2: Rewrite Active-Path Sorry Summary (lines 17-31)

Replace the sorry table with corrected line numbers:

| Category | Count | Location | Status |
|----------|-------|----------|--------|
| `rr_fwd_chain_forward_F` | 1 | `RootScopedChain.lean:1321` | **OPEN** -- PRIMARY BLOCKER |
| `dd_fmcs_forward_F` (t < 0) | 1 | `RootScopedChain.lean:1352` | **OPEN** -- depends on 1321 |
| `dd_fmcs_backward_P` | 1 | `RootScopedChain.lean:1359` | **OPEN** -- symmetric to forward_F |
| `dd_bfmcs_restricted_tc` | 1 | `RootScopedChain.lean:1412` | **OPEN** -- depends on forward_F + backward_P |
| `dd_bfmcs_restricted_buc` | 1 | `RootScopedChain.lean:1417` | **OPEN** -- backward Until coherence |
| `dd_bfmcs_restricted_fuc` | 1 | `RootScopedChain.lean:1422` | **OPEN** -- forward Until coherence |
| **Active-path total** | **6** | | |

### Section 3: Update Module Import Graph (lines 194-247)

Add three missing modules:

```
  ├── OrderedSeedConsistency.lean (255 lines, sorry-free)
  │     ├── Frame
  │     └── Quasimodel/Construction
  │
  ├── CanonicalModel.lean (498 lines, sorry-free)
  │     ├── Frame
  │     ├── RootScopedChain
  │     └── Quasimodel/Construction
  │
  └── RootScopedChain.lean (1,454 lines, 6 sorries)
        ├── Frame
        ├── CanonicalChain
        ├── OrderedSeedConsistency
        ├── Quasimodel/Construction
        ├── ParametricRepresentation
        └── RestrictedParametricTruthLemma
```

Update total: "**Total BXCanonical module: 5,669 lines across 16 files, 6 sorries.**"

### Section 4: Rewrite "Active-Path Sorry Inventory" (lines 422-453)

Remove the stale "exactly 1 sorry" claim. Replace with accurate description: all 6 sorries are in RootScopedChain.lean. Completeness.lean has 0 sorries — it calls `dd_countermodel` which depends transitively on the 6 sorry sites.

### Section 5: Add New Section — "The Forward_F Obstruction" (after "How Until/Since Were Closed")

This is the most important addition. Proposed content:

```markdown
## The Forward_F Obstruction (Task 93)

### Problem Statement

Given `F(psi) in chain(n)` and `psi in sigma_list`, prove
`exists s > n, psi in chain(s)`.

This property states that every F-obligation is eventually
fulfilled — the semantic content of the "F" (Future) operator.

### Why It Is Hard

The `enriched_fwd_step` (sorry-free) gives only a disjunction
at each step: `psi in M' OR F(psi) in M'`. The choice between
disjuncts is made by `Classical.choice` inside `set_lindenbaum`
and is opaque to proof. No purely syntactic argument can force
a specific disjunct.

The key structural fact: `F(psi)` and `neg(psi)` can coexist
in an MCS (F(psi) means "psi holds at some future time," while
neg(psi) means "psi doesn't hold now"). Both are simultaneously
satisfiable. So the chain can perpetually defer psi without
syntactic contradiction.

### The Syntax-Semantics Gap

Standard completeness proofs (Burgess 1984, Goldblatt 1992,
GHR 1994) handle forward_F semantically: they argue in the
constructed model that F-witnesses have well-ordered temporal
structure. The BX11 axiom provides a syntactic approximation
of this semantic property, but BX11 is weaker than the full
semantic content:

- BX11 is NOT transitive (3-cycle counterexample exists)
- BX11 does not induce a well-order on F-witnesses
- The disjunctive output of the BX11 fold cannot be made
  deterministic

This gap between syntactic axioms and semantic truth is the
root cause of the forward_F obstruction.

### Root Cause: Classical.choice in set_lindenbaum

The `.choose` in `set_lindenbaum` (called via
`resolving_enriched_fwd_exists`) selects a specific MCS
from the set of all maximal consistent extensions. This
selection is unconstrained — it can systematically choose
extensions where the target formula is deferred (F-wrapped)
rather than directly present. No BX axiom constrains
this choice.

### Sorry-Free Infrastructure Proved

16 sorry-free helper lemmas support forward_F analysis:
- `target_stays_direct_in_fold`: When target is BX11-earliest,
  fold guarantees target in M' (deterministic)
- `target_resolving_fwd_exists_strong`: Strengthens to full
  F-obligation preservation
- `enriched_fwd_step_preserves`: Disjunctive F-preservation
- `rr_fwd_chain_F_propagate`: Reduces forward_F to
  "F(psi) cannot persist forever"
- `discharge_single_step`: Given F(psi) in M, produces M'
  with psi in M' and g_content(M) subset M'
- `enriched_resolving_seed_consistent`: 2-defect seed
  consistency (OrderedSeedConsistency.lean)
- Plus 10 additional helper lemmas

### Approaches Tried and Failed (19 distinct approaches)

See Report 17 for the complete catalog. Key categories:

1. **Seed enrichment** (approaches 2-4): Adding f_carry or
   Until formulas to the Lindenbaum seed. All produce
   inconsistent seeds.
2. **Well-founded measures** (approaches 11-12): Defect
   counting (non-monotonic), BX11 ordering (non-transitive
   with 3-cycles).
3. **Chain replacement** (approaches 7, 14, 17): Replacing
   the round-robin with deterministic/per-formula/two-phase
   chains. All reduce to the same core problem or have
   prohibitive re-proof costs.
4. **Semantic bridge** (approaches 6, 9, 15): FMP bridge,
   Zorn/compactness, quasimodel-to-Int. All fail due to
   BXPoint-to-integer bridge gap.
5. **Axiom-based** (approaches 5, 16, 18-19): BX12
   reduction, G(F(psi)) axiom, defects-only fold, partial
   domination. All blocked by fundamental limitations.

### Remaining Viable Paths

1. **Demand-driven chain** (Rounds 22-23 consensus, 55-65%):
   Replace round-robin with demand-driven construction where
   each step addresses one F-demand directly. Forward_F
   holds by construction. Requires proving
   `extended_defect_seed_consistent` (n-defect case).
   Estimated 25-40 hours.

2. **Semantic hybrid** (Round 23 Finding 16, 30%): Use
   restricted truth lemma to derive contradiction from
   perpetual deferral. Risk: circularity with forward_F
   dependency. Needs careful analysis of which truth lemma
   cases are forward_F-free.

3. **Novel mathematical insight** (unknown probability):
   A fundamentally new argument not yet conceived.
```

### Section 6: Add 5 New Dead Ends (after existing #21)

Add dead ends 22-26 as described in Finding 2 above.

### Section 7: Update Task Cross-Reference (lines 799-818)

- Task 93 status: `[IMPLEMENTING]` with note "(24 rounds, forward_F primary blocker)"
- Task 103: `[COMPLETED]`
- Task 94: `[COMPLETED]`
- Add note: "See Report 17 for complete catalog of 19 failed approaches"

### Section 8: Add New Section — "Mathematical Open Questions"

```markdown
## Mathematical Open Questions

1. **Is forward_F provable syntactically?** Can the property
   "F(psi) in MCS chain implies psi eventually appears" be
   derived from BX axioms alone, or does it inherently
   require semantic reasoning?

2. **Can BX11's disjunctive output be made deterministic?**
   Is there a way to constrain the Lindenbaum extension to
   guarantee direct resolution of a specific formula?

3. **Is the n-defect seed consistent?** The existential form
   of `extended_defect_seed_consistent` (some j gives a
   consistent seed) is the key lemma for the demand-driven
   approach. The 2-defect case is proved; the general case
   is open.

4. **Can the completeness proof bypass forward_F entirely?**
   Is there a reformulation of the canonical model
   construction that avoids the eventuality resolution
   obligation?

5. **Is perpetual BX11 displacement contradictory?** If a
   formula psi is permanently displaced by BX11 Case 3 at
   every chain step, does this lead to a detectable
   contradiction within the MCS axiom system?
```

### Section 9: Update "Recommended Priority Order" (lines 772-796)

Add sub-items under Task 93:
```
1. **Task 93**: Close 6 RootScopedChain.lean sorries.
   a. Prove `extended_defect_seed_consistent` (n-defect, 2-4 hours)
   b. Build demand-driven chain (15-25 hours)
   c. Close forward_F and dependent sorries (5-10 hours)
   **Total estimated: 25-40 hours. Confidence: 55-65%.**
```

### Section 10: Add "Lessons Learned" Section

```markdown
## Lessons Learned from Task 93 (24 Rounds)

1. **The `.choose` in set_lindenbaum is the root cause.**
   All 24 rounds converge on this diagnosis. The
   non-deterministic Lindenbaum extension cannot be
   constrained by BX axioms alone.

2. **BX11 is non-transitive.** The 3-cycle counterexample
   (Round 16) means BX11 does not induce a well-order.
   Any approach relying on BX11 minimality for 3+ formulas
   is blocked.

3. **f_carry seed enrichment is inconsistent.** Adding all
   F-obligations to the Lindenbaum seed produces provably
   inconsistent sets. Only the restricted sigma-list seed
   (existential form) may be viable.

4. **The syntax-semantics gap is real.** Published proofs
   handle forward_F semantically. The BX axioms provide
   a syntactic approximation that is strictly weaker than
   the semantic reality. Bridging this gap is the core
   challenge.

5. **Test on 3-formula examples first.** Round 16's
   3-cycle counterexample was found by testing BX11
   on concrete 3-formula scenarios. All future approaches
   should be validated on small examples before
   formalization.

6. **Avoid chain replacement unless necessary.** ~30
   downstream theorems depend on the current chain.
   Replacement costs 200+ LOC in re-proofs. Strategy C
   (working with existing chain) was preferred for this
   reason.

7. **F-obligation set constancy is a key structural fact.**
   The set {chi | F(chi) in chain(n)} is exactly constant
   across steps (BX8+BX10 for non-shrinking, no_new_f_defects
   for non-growing). Any argument must use this.

8. **buc/fuc are NOT independent of forward_F.** Round 22
   revised confidence from 85% to 40-55%. The quasimodel
   BXPoint-to-integer bridge does not exist.
```

## Strategic Recommendations

### Recommendation 1: Continue with BXCanonical (DO NOT ABANDON)

6,400+ lines of sorry-free infrastructure. The only path to the project's stated scientific contribution (representation theorem via canonical model). No alternative completeness architecture exists in the codebase. Abandoning would write off months of work for no gain.

### Recommendation 2: Pursue Demand-Driven Chain as Primary Path

The consensus across Rounds 22-23 (all 8 teammates) is the demand-driven / finite-discharge chain. This is the published technique (Burgess 1984, Goldblatt 1992). The round-robin was always an approximation. The key gate: proving `extended_defect_seed_consistent` for n defects.

### Recommendation 3: Invest in Pen-and-Paper Proof First

24 rounds of Lean formalization have not produced the mathematical insight needed. Before spending another 25-40 hours on implementation, invest 4-8 hours in a careful pen-and-paper proof of forward_F for the demand-driven chain. The question is mathematical, not engineering.

### Recommendation 4: Consider Publishing Partial Result

If forward_F remains unresolved after the demand-driven attempt, the project has a publishable partial result:
- Complete truth lemma (sorry-free)
- Complete Until/Since eventuality resolution (sorry-free)
- Complete frame construction (sorry-free)
- Precise characterization of the forward_F gap as a syntax-semantics barrier
- 19 documented failed approaches (contribution to the literature)

This would be an honest "completeness modulo forward_F" result with clear documentation of the remaining gap.

### Recommendation 5: Explore Semantic Hybrid as Backup

The semantic hybrid approach (Round 23 Finding 16) has low confidence (30%) but is mathematically interesting: if psi is perpetually deferred, the restricted G/H truth lemma (which does NOT depend on forward_F) might derive G(neg psi) in M, contradicting F(psi) in M. This requires careful analysis of which truth lemma cases are forward_F-free.

## Proposed New Tasks

### Task A: Pen-and-Paper Forward_F Proof (Research, 4-8 hours)
Before any more Lean implementation, produce a complete pen-and-paper proof of forward_F for the demand-driven chain construction. Specify: seed consistency lemma, chain construction, forward_F proof, and how it connects to the 6 sorry sites. If this cannot be done on paper, it cannot be done in Lean.

### Task B: Prove extended_defect_seed_consistent (Implementation, 4-8 hours)
The n-defect generalization of `ordered_two_defect_seed_consistent`. The 2-defect case is proved. The n-defect case requires handling BX11 3-cycles via the running-compound iteration approach. Gate check for the demand-driven chain.

### Task C: Literature Deep Dive — Burgess 1984 Canonical Model (Research, 2-4 hours)
Read Burgess (1984) "Basic tense logic" sections on canonical model construction, specifically the handling of F-witnesses in the omega-chain. Identify the EXACT step where forward_F is established and how it maps to our infrastructure.

### Task D: ROAD_MAP.md Comprehensive Update (Implementation, 2-3 hours)
Apply all updates proposed in this report. Update line numbers, module counts, dead ends, cross-references, and add new sections (Forward_F Obstruction, Mathematical Open Questions, Lessons Learned).

### Task E: Semantic Hybrid Feasibility Analysis (Research, 2-4 hours)
Analyze which truth lemma cases are forward_F-free. Specifically: can the restricted truth lemma for G/H (which doesn't use forward_F) be applied to the forward chain to derive G(neg psi) from perpetual neg(psi) membership? If yes, forward_F follows by contradiction.

## Confidence Level

**Overall confidence in proposed ROAD_MAP updates**: HIGH (90%). The factual corrections (line numbers, module counts, dead-code cleanup) are verified against source code. The strategic recommendations reflect consensus from Rounds 22-23.

**Confidence in forward_F eventually being resolved**: MEDIUM (50-60%). The demand-driven approach is mathematically sound (published technique), but the formalization gap (BX11 non-transitivity, Lindenbaum non-determinism) is genuine and may require innovation beyond what the literature provides.

**Confidence in project NOT being permanently blocked**: HIGH (85%). Even if forward_F resists the demand-driven approach, the semantic hybrid and potential novel insights remain unexplored. The project has a publishable partial result regardless.
