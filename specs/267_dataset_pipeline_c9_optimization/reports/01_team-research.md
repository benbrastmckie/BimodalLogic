# Research Report: Task #267

- **Task**: 267 - Optimize dataset pipeline for exhaustive c9 generation and beyond
- **Date**: 2026-06-02
- **Session**: sess_1748903400_e7g1b5
- **Mode**: Team Research (4 teammates)

---

## Executive Summary

The c8 dataset reveals that 487 wall-clock timeout formulas (0.19% of total) account for roughly 40 of 43 total generation minutes — a near-total throughput collapse caused by a single, structurally homogeneous pattern class (`U(atom, X) → U(Y, Z)` and `S(atom, X) → S(Y, Z)`). The first and highest-ROI fix is reducing the wall-clock timeout from 5s to 1s, saving ~205 minutes at c9 scale with zero code changes. After that, atom-permutation deduplication reduces the labeling workload by a measured 4.58x (not the theoretical 6x), and parallel batch labeling can provide a further ~4-8x throughput gain — but only after write serialization is correctly implemented.

The more consequential finding, with strong consensus across all four teammates, is that exhaustive c9 generation has questionable marginal value. The valid formula fraction, proof axiom combination diversity, and label distribution are all stable from c6 onward; c9 adds scale, not new structure. The external literature (SATBench, LASER, 3D-Prover, and others) converges on stratified sampling with diversity quotas as the standard approach once labeling cost exceeds a few minutes. A 100K-record interestingness-stratified c9 sample, generated in under 30 minutes, would likely outperform a 1.6M exhaustive run for any ML training use case.

The team also identifies two concrete, low-effort, high-value opportunities that are currently unaddressed: (1) generating Dense and Discrete frame-class variants of existing c7/c8 datasets using the infrastructure already in place, and (2) creating interestingness-stratified slices from existing data without any new generation. These actions diversify the dataset along the most semantically meaningful axes of the logic and strengthen its position as a publishable research artifact.

---

## Key Findings

### 1. Throughput Analysis and Bottleneck Characterization

The c8 effective throughput collapses from ~1,511 formulas/sec (c7) to ~98 formulas/sec effective. The cause is entirely the 487 wall-clock timeout formulas:

| Level | Records | Effective Rate | Generation Time | Bottleneck |
|-------|---------|---------------|-----------------|------------|
| c6 | 7,412 | ~1,200 f/sec | ~6s | None |
| c7 | 49,865 | ~1,511 f/sec | ~33s | None |
| c8 | 252,900 | ~98 f/sec effective | ~43 min | 487 wall-clock timeouts @ 5s each |
| c9 (projected) | 1,593,620 | ~98 f/sec effective | ~4.5 hr | ~3,075 wall-clock timeouts |

The 252,413 non-timeout c8 formulas complete at ~0.6ms each — the same rate as c7. The 487 timeout formulas each consume the full 5-second budget, totaling ~40.6 minutes. This is not a scaling problem; it is a fixed-overhead problem that can be addressed without touching the decision procedure itself.

### 2. Exhaustive vs. Stratified: The Field Has Spoken

Four independent lines of evidence converge on the same conclusion: exhaustive c9 enumeration is not the right target.

**Diminishing structural returns (Teammate C, measured):** Structural diversity plateaus sharply at each complexity level. C7 introduced 9 unique axiom combinations; c8 added exactly 1 new one. The valid formula fraction is stable at 8-9% from c5 onward. Exhaustive c9 adds ~1.13M invalid formulas for every ~112K valid ones, worsening an already severe class imbalance.

**Prior art consensus (Teammate B):** SATBench generates only 2,100 puzzles despite unlimited formula supply. LASER selective sampling consistently outperforms exhaustive datasets on downstream tasks. The 3D-Prover (ICLR 2025) uses Determinantal Point Processes for diversity and shows 50K diverse formulas outperform 500K redundant ones. The existing `bmlogic-c9-sample.jsonl` (50K records) already demonstrates stratified c9 sampling is operational.

**Quality over quantity (Teammate D):** The existing interestingness scoring infrastructure (7 tiers from trivial to remarkable) is computed for every formula but not used for filtering or weighting. A 10K-record "interesting" slice (tier >= moderate, score >= 300) likely provides more training signal than the full exhaustive run.

**Timeout validity problem (Teammate C):** The 487 c8 wall-clock timeouts and their c9 counterparts carry "timeout" as a label, which is a property of the decision procedure, not of the logic. These records provide no ground-truth validity information for ML training. The c9 exhaustive run would produce proportionally more such records (estimated 2,500–6,400).

**Recommendation:** Make stratified c9 sampling the primary goal. A 100K-record c9 dataset with per-pattern quotas, interestingness-weighted sampling, and known-hard-timeout-pattern exclusion would be generated in under 30 minutes and would exceed the ML training value of the exhaustive alternative.

### 3. Implementation Optimizations (Ordered by ROI)

**Tier 1 — Immediate, near-zero risk:**

**Wall-clock timeout reduction (5s → 1s):** Timeout formulas time out regardless of the limit; the limit only determines how long to wait. Reducing from 5s to 1s saves 4s per formula: 32 minutes at c8 scale, 205 minutes at c9 scale. Implementation is a single CLI flag change or default update in `DatasetExport.lean:CLIArgs`. Expected c9 sequential time: 1.1 hours (down from 4.5 hours). This is the single highest-ROI change available.

**Tier 2 — Structural improvement:**

**Atom-permutation deduplication (4.58x reduction):** Teammate C directly measured canonical form reduction on all 49,865 c7 formulas and a 50K c8 sample. The result is stable at 4.58–4.59x across both levels (not the theoretical 6x maximum, because ~5% of formulas are fully symmetric and ~12% form size-3 rather than size-6 orbits). For c9, this reduces ~1.59M formulas to approximately 347K canonical representatives. The integration point is `DatasetExport.lean:main` between checkpoint write (line 883) and labeling loop (line 908). Labels are semantically invariant under atom permutation; records for non-canonical formulas can be synthesized by applying the inverse permutation to the canonical result.

**Tier 3 — Parallel labeling with required write serialization:**

**Parallel batch labeling (~4-8x throughput, with caveat):** The `decideAutoAdaptive` function and all pure computation paths are thread-safe. However, Teammate C identifies a critical gap: `IO.FS.Handle` in Lean 4 does not provide atomic-line writes. Concurrent writes to a single JSONL file handle will produce interleaved or garbled records. The implementation **must** include a single-writer serialization layer (sequential write queue or mutex-protected writer). With this in place, 24-core batch parallelism can achieve ~4.9x speedup when combined with the 1s wall-clock timeout reduction.

Teammate B provides empirical support from Kimina Lean Server (arXiv:2504.21230), which achieves near-linear CPU scaling for Lean 4 verification (8→60 CPUs yields 5.2x improvement). Teammate A notes that nested `Task.spawn` (outer batch task spawning inner timeout task) is supported but 24-48 concurrent threads should be benchmarked for memory pressure at c9 formula complexity.

**Tier 4 — Architectural fix (high impact, significant effort):**

**Global caching in the tableau procedure:** The fundamental cause of hard timeouts is tree-shaped tableau expansion that revisits the same branch state repeatedly. Teammate B identifies global caching (Goré & Nguyen 2007+) as the standard fix: maintain a visited-state cache indexed by sorted multiset of signed formulas; short-circuit on revisit. This changes the per-formula cost for temporal-modal feedback loop formulas from minutes to milliseconds. Risk: requires careful implementation to preserve soundness and completeness; may require formal verification.

**Combined projected c9 generation times:**

| Strategy | Sequential Time | Notes |
|----------|----------------|-------|
| Status quo (5s wc-timeout) | ~4.5 hours | Baseline |
| 1s wc-timeout only | ~1.1 hours | Single CLI change |
| 1s wc-timeout + 4.58x dedup | ~14-17 min | No parallelism needed |
| All three (+ 24-core parallel) | ~4-6 min | Full optimization stack |

### 4. Timeout Quality Problem

Teammate C finds that all 487 c8 wall-clock timeout formulas share a single structural pattern:

- Complexity: exactly 8 (all 487)
- Pattern: `U(atom, X) → U(Y, Z)` or `S(atom, X) → S(Y, Z)` where one side mixes modal operators with temporal operators
- Labels: all "timeout" — no countermodels found, validity unknown
- Partition: 240 Until-antecedent, 247 Since-antecedent

This is not a resolved edge case; it is a deferred validity question. These 487 formulas (and their ~2,500–6,400 c9 counterparts) are included in training data with a label that reflects decision procedure behavior, not logical truth. For ML training purposes, this is a meaningful flaw: a model trained on these records learns the wrong thing.

The structural pre-filter from task 265 handles `U(⊥, X)` patterns. Whether it can be extended to cover this `U(atom, X) → U(Y, Z)` pattern class requires formal decidability analysis that was not attempted in this task. If the extension is not feasible, these records should be excluded from training datasets (labeled "exclude" or omitted) rather than included with a "timeout" label.

### 5. Strategic Opportunities Beyond c9

**Multi-frame-class datasets (highest immediate value):** The `labelFormula` function already accepts a `fc : FrameClass` parameter with three variants: `Base` (current), `Dense` (densely ordered), and `Discrete` (discretely ordered). All existing datasets use only `Base`. Generating Dense and Discrete variants of c7 takes ~30 seconds each using existing infrastructure. These datasets have different validity distributions for the same formulas — a formula valid over Base may be invalid over Dense — creating a richer training signal and a distinctive benchmark covering three frame classes. This is the highest-value, lowest-cost action currently available.

**Interestingness-stratified dataset slices:** The 7-tier interestingness scoring system is computed for every record but not used for filtering. Three targeted slices can be derived from existing data (no new generation required):
- "Hard formulas" slice: interestingness tier >= "interesting" (score >= 700)
- "Bimodal interaction" slice: SNT=3 AND `interaction_axiom_dep=true`
- Curriculum slice: one representative per tier per complexity level

**Benchmark publication path:** Teammate D identifies a clear publication gap. The project has Croissant 1.0 metadata, an HF dataset card, and a working upload pipeline (task 257). What is missing is a companion paper. The strongest positioning would be: (1) formally verified decision procedure as ground truth, (2) multi-frame-class labeled data, (3) interestingness metric as a difficulty model. This combination is unique in the ML-for-formal-reasoning space.

---

## Conflicts and Resolutions

| Conflict | Teammate A | Teammate C | Resolution |
|----------|-----------|-----------|------------|
| Atom-permutation reduction factor | Estimates 4.05x from 10K c7 sample | Measures 4.58x from all 49,865 c7 formulas and 50K c8 sample | **Use 4.58x** — C's figure is empirical on the full dataset vs. A's estimate on a 10K sample; the stable c8 result (4.59x) confirms it |
| Exhaustive vs. stratified sampling | Proceeds from exhaustive c9 as the given goal | Challenges the assumption, cites structural plateau evidence | **Recommend stratified sampling as primary goal** — B and D independently reach the same conclusion; prior art is unanimous; the existing `bmlogic-c9-sample.jsonl` demonstrates the approach works |
| Parallel labeling safety | Proposes batch parallelism, identifies IO as bottleneck | Identifies write-concurrency hazard as unaddressed critical gap | **Parallel labeling is viable with write serialization** — A correctly identifies the IO bottleneck; C correctly identifies that the proposed design does not include serialization. The fix is required before implementation, not optional |
| Wall-clock timeout formulas | Treats as known-quantity residual from task 266 | Challenges: these are unresolved validity questions, not a "resolved edge case" | **C is correct** — "timeout" is not a logical label; these records should be excluded from or flagged in ML training data |

---

## Synthesis: Recommended Strategy

The team's findings support a three-track strategy ordered by impact-per-effort:

**Track A — Immediate (< 1 day, no code changes to core logic):**
1. Reduce wall-clock timeout to 1s (single CLI default change)
2. Generate Dense and Discrete frame-class datasets for c7 using existing `--frame-class` flag
3. Create interestingness-stratified slices from existing c8 data (scripted filter, no new generation)

These three actions diversify the dataset significantly, reduce the per-run bottleneck by 4x, and require essentially no new engineering.

**Track B — Short-term (2-3 days):**
4. Implement atom-permutation canonicalization and deduplication in `DatasetExport.lean` (integration point: between checkpoint write at line 883 and labeling loop at line 908)
5. Implement parallel batch labeling with a mandatory write-serialization layer; benchmark memory pressure at c9 complexity before committing to batch size
6. Run an interestingness-stratified c9 sample of 100K records targeting per-pattern quotas, excluding known-timeout-pattern formulas, and weighting toward higher interestingness tiers

With tracks A and B complete, c9 exhaustive generation (if still desired) would run in approximately 14-17 minutes sequentially, or 4-6 minutes with 24-core parallelism.

**Track C — Medium-term (optional, architectural):**
7. Add global caching to `buildTableau`/`expandBranchWithFuel` to eliminate the root cause of temporal-modal feedback loop timeouts. This is the only fix that addresses the hard timeout problem rather than working around it. Required before any attempt at c10+ exhaustive generation.
8. Add checkpoint-JSONL cross-validation to the resume mechanism (Teammate C documented a 7-record gap in the c8 run indicating the current manual `--resume-from N` has no safety check)

---

## Gaps Identified

- **No stated use case for exhaustive c9**: The task description does not articulate what downstream application requires 1.6M formulas rather than a stratified sample. Exhaustive generation should only proceed once this is established.
- **Timeout record validity is unknown**: 487 c8 formulas labeled "timeout" have unknown logical validity. Their c9 counterparts will number in the thousands. These should be either excluded from training data or formally resolved.
- **Checkpoint-JSONL integrity gap**: The c8 run produced a 7-record discrepancy between checkpoint and JSONL. The resume mechanism has no automatic validation, creating silent duplicate/gap risk for c9 runs.
- **Memory pressure under parallelism uncharacterized**: At c9 complexity, concurrent tableau constructions may produce significant peak memory usage. This should be benchmarked before setting the parallelism degree.
- **Extended pre-filter scope unclear**: Whether the 487-formula pattern class (`U(atom, X) → U(Y, Z)`) admits a structural decidability rule was not analyzed; this is a prerequisite for eliminating the timeout class rather than timing it out faster.

---

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|-----------------|------------|
| A | Primary approaches | completed | Throughput baseline from c8 data; ROI-ordered 3-phase optimization plan; `canonicalizeAtoms` implementation sketch; 14-min c9 projection | High |
| B | Alternative approaches and prior art | completed | External literature consensus that sampling dominates exhaustive enumeration; global caching as tableau fix; Kimina Lean Server parallel scaling evidence (near-linear); phase-transition targeting insight | High |
| C | Critic | completed | Measured 4.58x dedup factor (vs. A's estimated 4.05x); write-concurrency hazard identification; timeout homogeneity analysis (487/487 share identical pattern); checkpoint-JSONL gap documentation | High |
| D | Horizons and strategy | completed | Multi-frame-class opportunity (Dense/Discrete datasets via existing infrastructure); interestingness metric underutilization; publication gap analysis; dataset factory concept | Medium-High |
