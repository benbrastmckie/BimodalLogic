# Research Report: Post-270-272 Bottleneck Sweep

- **Task**: 274 — Run dataset generation at increasing complexity to find new bottleneck after tasks 270-272
- **Date**: 2026-06-03
- **Session**: sess_1748987036_e8b4c8
- **Status**: Research complete

## Executive Summary

Tasks 270-272 introduced a **severe timeout regression**: the c7 timeout rate jumped from 4.8% (pre-270-272) to 41.7% (post-270-272), an 8.7x increase. The root cause is task 271's active until-negative rule, which creates fresh time points for standalone temporal formulas where the pre-271 code returned `notApplicable`. Additionally, the derived temporal operators (G/H) from task 272 have **prohibitive complexity overhead** (8 per operator), making bimodal interaction formulas (box + G/H) require complexity >= 11 — far beyond the practical c5-c9 generation range. Zero valid proofs exercise temporal axioms at any complexity level tested.

## Methodology

### Runs Executed

| Run | Complexity | Duals | Records | Source |
|-----|-----------|-------|---------|--------|
| sweep-c5-noduals | 5 | No | 395 | Fresh, post-270-272 |
| sweep-c5 | 5 | Yes | 395 | Fresh, post-270-272 |
| sweep-c7 (partial) | 7 | No | 10,876 of ~50K | Fresh, post-270-272 (killed at 29min) |
| bmlogic-c5 | 5 | No | 395 | Existing, pre-270-272 (June 3 09:01) |
| bmlogic-c7-clean | 7 | No | 49,865 | Existing, pre-270-272 (June 2) |
| bmlogic-c8-clean | 8 | No | ~252K | Existing, pre-270-272 (June 2) |
| bmlogic-c9-stratified-100k | 9 | No | 80,005 | Existing, pre-270-272 (June 2) |
| generateBimodalSlice c5-c9 | 5-9 | N/A | 8,144 bimodal | Enumeration only (no labeling) |

### Pre- vs Post-270-272 Baseline Comparison

| Metric | Pre-270-272 (c5) | Post-270-272 (c5) | Pre-270-272 (c7) | Post-270-272 (c7) |
|--------|-------------------|-------------------|-------------------|-------------------|
| Total records | 395 | 395 | 49,865 | 10,876 (partial) |
| Timeout rate | 0.0% | 24.8% | 4.8% | 41.7% |
| Valid rate | 13.2% | 13.2% | 8.4% | 11.5% |
| Wallclock timeouts | 0 | 6 | 0 | 392 |
| Adaptive timeouts | 0 | 92 | 2,410 | 4,147 |
| Structural prefilter | 13 | 44 | 1,360 | 1,105 |

## Finding 1: Severe Timeout Regression from Task 271

### Evidence

The active until-negative rule (task 271) creates fresh time points when `futureOf l.time` or `pastOf l.time` is empty. For standalone temporal formulas (not inside implications), the initial time has no future/past times, so the active rule fires immediately and creates a chain of fresh times that terminates only via subset blocking.

**98 formulas at c5 that previously resolved in 1-3ms now time out.** Examples:

| Formula | Pre-271 | Post-271 |
|---------|---------|----------|
| `X(box(bot))` | invalid, 1ms | timeout, 66ms |
| `U(box(p), q)` | invalid, 2ms | timeout, 58ms |
| `X(p -> q)` | invalid, 1ms | timeout, 1000ms (wallclock) |
| `S(neg(p), q)` | invalid, 1ms | timeout, 613ms |
| `Y(box(p))` | invalid, 1ms | timeout, 132ms |

### Pattern Analysis (c7, 4,539 timeouts)

| Timeout Category | Count | Percentage |
|-----------------|-------|------------|
| U/S standalone (temporal only) | 2,745 | 60% |
| U/S + box (bimodal) | 1,279 | 28% |
| box standalone (modal) | 335 | 7% |
| Other | 180 | 4% |

Of the 4,539 timeouts: 91% are `adaptive_timeout` (fuel exhaustion at 500), 8% are `wallclock_timeout` (>1s wall clock).

### Root Cause

In `Tableau.lean`, the active rule at lines 741-801:

```lean
| .untlNeg, .neg, φ =>
    ...
    if futureTimes.isEmpty then
      -- ACTIVE: create fresh future time
      let freshTime := branch.nextTime
      ...
```

For a formula like `U(box(p), q)` at time 0 with no existing future times:
1. Active rule fires, creates time 1
2. Reynolds decomposition at time 1: Branch 2 includes `F(U(box(p), q))` at time 1
3. At time 1, `futureOf 1 = []`, so active rule fires again, creates time 2
4. Chain continues until subset blocking terminates it
5. Each step doubles the branch count (2 branches per application)

The exponential branching exhausts fuel=500 quickly. Pre-271, these formulas returned `notApplicable` immediately when no future times existed, allowing the countermodel to be extracted from the existing branch.

### Impact Quantification

- At c5: 98/395 = 24.8% timeout rate (was 0%)
- At c7: estimated 4,539/10,876 = 41.7% timeout rate for the first ~20% of records (was 4.8%)
- Processing speed dropped from ~300 formulas/sec to ~6 formulas/sec at c7 (each timeout costs ~1s wallclock)

## Finding 2: Derived Temporal Operators Have Prohibitive Complexity

### Complexity Overhead

| Operator | Expansion | Complexity Cost |
|----------|-----------|----------------|
| F(phi) | `U(phi, top)` | 4 + complexity(phi) |
| P(phi) | `S(phi, top)` | 4 + complexity(phi) |
| G(phi) | `neg(F(neg(phi)))` | 8 + complexity(phi) |
| H(phi) | `neg(P(neg(phi)))` | 8 + complexity(phi) |

### Minimum Bimodal Interaction Formula Complexity

| Pattern | Minimum Complexity | Available At |
|---------|-------------------|-------------|
| box(F(atom)) | 2 + 4 + 1 = 7 | c7+ |
| box(P(atom)) | 2 + 4 + 1 = 7 | c7+ |
| F(atom) -> box(atom) | 4 + 1 + 1 + 2 + 1 = 9 | c9+ |
| box(G(atom)) | 2 + 8 + 1 = 11 | c11+ |
| box(H(atom)) | 2 + 8 + 1 = 11 | c11+ |
| box(atom) -> G(box(atom)) | 3 + 1 + 8 + 3 = 15 | c15+ |

### generateBimodalSlice Results

| Complexity Range | Bimodal Formulas | G/H Formulas |
|-----------------|------------------|--------------|
| c5 | 0 | 0 |
| c5-c7 | 80 | 0 |
| c5-c9 | 8,144 | 0 |

**Even at c9, zero formulas contain G/H combined with box.** The only bimodal formulas at c5-c9 use F/P (cost 4) combined with box (cost 2). G/H (cost 8) plus box (cost 2) requires at least complexity 11.

### Axiom Seeding Impact

The 22 axiom schemata (task 272) do produce bimodal interaction formulas via `instantiateAxiom` (e.g., `modal_future: box(phi) -> G(box(phi))`), but these have high complexity and are filtered out by `maxComplexity` bounds. The axiom seeds that survive deduplication and complexity filtering do not produce enough bimodal formulas to significantly affect the dataset composition.

## Finding 3: Zero Temporal Axiom Usage in Valid Proofs

### Evidence

Across all tested complexity levels:

| Dataset | Valid Formulas | With Proof Trace | Temporal Axioms Used |
|---------|---------------|------------------|---------------------|
| c5 (post-271) | 52 | 8 | 0 |
| c7 (post-271, partial) | 1,246 | 141 | 0 |
| c7 (pre-271, full) | 4,198 | 4,198 | 0 |

Axioms appearing in valid proofs: `prop_s`, `prop_k`, `ex_falso`, `modal_t`, `modal_4`, `peirce`. Zero temporal axioms (`modal_future`, `connect_future`, `serial_future`, `right_mono_until`, etc.) appear in any proof.

### Root Cause

1. **Valid temporal formulas time out** — the decision procedure exhausts fuel on formulas that need temporal reasoning, so they never produce proof traces
2. **Structural prefilter catches some** — 44 formulas at c5 are caught by the structural prefilter as valid, but this doesn't produce proof traces with axiom attribution
3. **Axiom-seeded formulas are deduplicated away** — the valid-seed pool generates temporal axiom instances, but after atom-permutation deduplication, the unique formulas that survive are mostly propositional/modal

## Finding 4: Interestingness Score Distribution

| Tier | c5 (post-271) | c7 (post-271, partial) |
|------|--------------|----------------------|
| trivial (score 0) | 227 (57%) | 4,061 (37%) |
| routine (score 1-199) | 166 (42%) | 6,213 (57%) |
| basic (score 200-299) | 0 | 594 (5%) |
| moderate (score 300-499) | 2 (1%) | 8 (0.1%) |
| interesting (score 500+) | 0 | 0 |

Score range: 0-347 (c7). Average: 77.3. No formulas reach the "interesting" tier (500+), which requires both syntactic complexity and proof-structural features. Since temporal formulas time out, they get no proof traces, and hence no proof-structural scoring.

## Finding 5: Processing Speed Regression

| Level | Pre-271 Rate | Post-271 Rate | Slowdown |
|-------|-------------|---------------|----------|
| c5 | ~395/0.5s = 790/sec | 395/13s = 30/sec | 26x |
| c7 | ~50K/33s = 1,500/sec | ~10.9K/29min = 6.3/sec | 238x |
| c9 (projected) | feasible in ~2h | infeasible (days) | N/A |

The c9 generation is now infeasible in a reasonable time window. Each timeout formula costs ~1s wall clock, and with 40%+ timeout rates and hundreds of thousands of formulas, the pipeline stalls.

## Bottleneck Identification

### Previous Bottleneck (pre-270-272)
The enumerator producing uninteresting formulas (high invalid rate, low valid rate) and combinatorial explosion at c9+.

### Current Bottleneck (post-270-272)
**The active until-negative rule (task 271) causing timeout regression.** This is now the dominant bottleneck, overwhelming all other factors:

1. **Primary**: Active untlNeg/snceNeg creates exponential branching for standalone temporal formulas that should resolve quickly as invalid
2. **Secondary**: G/H complexity overhead (8) prevents bimodal interaction formulas from appearing below c11
3. **Tertiary**: No temporal axiom usage in proofs means the dataset lacks the most interesting proof patterns

## Recommendations

### Priority 1: Fix the Active Rule Regression (Critical)

The active until-negative rule needs a guard to prevent firing on standalone temporal formulas. Two approaches:

**Option A: Context-aware activation** — Only fire the active rule when the formula appears inside a negated implication (i.e., when trying to falsify `phi -> psi`). Standalone temporal formulas (which are being tested for satisfiability, not validity) should use the passive rule.

**Option B: Depth-limited active rule** — Add a fuel parameter to the active case that limits the number of fresh time points created per time label to 1 or 2, then fall back to `notApplicable`. This preserves the benefit for validity proofs while preventing runaway chains.

**Option C: Exclude standalone temporal formulas from the active path** — If the signed formula is `F(U(event, guard))` and the current branch has no other formulas requiring future time exploration, return `notApplicable`. This is the most surgical fix.

Expected impact: Restore timeout rates to pre-271 levels (0% at c5, ~5% at c7), re-enabling c9 generation.

### Priority 2: Reduce G/H Complexity Overhead (Important)

The current complexity function counts primitives, so `G(p) = neg(F(neg(p))) = neg(U(neg(p), top))` costs 8. Options:

**Option A: Treat G/H/F/P as primitive operators in the complexity function** — Add cases for the derived patterns that return overhead of 2 (matching box). This requires modifying `Formula.complexity` and re-validating all downstream code.

**Option B: Add G/H/F/P as primitive Formula constructors** — This is a larger change but eliminates the encoding overhead entirely. Requires extending the syntax, semantics, tableau rules, and proof system.

**Option C: Accept high overhead, target c11+** — Generate at c11 using stratified sampling specifically for bimodal formulas. Use `generateBimodalSlice` with c11-c13 to get formulas with G/H + box.

Expected impact: G(atom) drops from complexity 9 to 3, enabling bimodal G/H formulas at c5-c7.

### Priority 3: Wire Temporal Axiom Attribution (Nice to have)

The structural prefilter short-circuits valid formulas without producing proof traces. Adding axiom attribution to the prefilter output (e.g., recording which structural pattern was matched) would allow temporal validity to be tracked in the dataset.

## Files Analyzed

| File | Purpose |
|------|---------|
| `scripts/run_dataset_generation.sh` | CLI orchestration for dataset generation |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Formula enumeration with derived temporal operators |
| `Theories/Bimodal/Automation/DatasetExport.lean` | JSONL export and CLI main |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Labeling pipeline with structural prefilter |
| `Theories/Bimodal/Automation/InterestingnessMetrics.lean` | Scoring architecture |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | Active untlNeg/snceNeg rules (task 271) |

## Data Artifacts

All sweep data written to `data/sweep-c5.jsonl`, `data/sweep-c5-noduals.jsonl`, `data/sweep-c7.jsonl` (partial, 10,876 records). These are temporary research artifacts and can be deleted after review.
