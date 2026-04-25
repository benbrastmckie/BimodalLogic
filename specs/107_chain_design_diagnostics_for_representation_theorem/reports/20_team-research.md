# Research Report: Task #107 — Burgess Paper Study + Deterministic Chain Assessment

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Session**: sess_1777078993_7b41d6

## Summary

Breakthrough findings from reading Burgess 1982 in full. The g_content_chain_property blocker arises from a **fundamental misunderstanding of Burgess's construction**: C3 is a DEFINITION (not a property to prove), the r-relation must be THREE-argument (not two), and point insertion must construct g values (the codebase leaves g unchanged). The deterministic chain path is confirmed DEAD under irreflexive semantics (14+ sorries, 3 independent blockers). The chronicle path has exactly 1 root-cause sorry that cascades to all 12.

## Key Findings

### 1. BREAKTHROUGH: C3 Is a Definition, Not a Property to Prove (Teammate A — HIGH confidence)

From the actual paper text (Burgess 1982, p. 372):

> **(C3)** Whenever x, y, z in dom f and x < y < z, then g(x,y) = g(x,z) intersect g(y,z).

C3 is part of the MEMBERSHIP CONDITION for the set F of valid chronicles. It defines g on non-adjacent pairs in terms of adjacent-pair values. When inserting a new point z, g'(w,z) for non-adjacent w is **defined by C3**, not computed or proved. The codebase's `g_content_chain_property` sorry attempts to PROVE a property that Burgess takes as definitional.

**Implication**: The limit_g should be defined as: for x < y, limit_g(x,y) = intersection over the C3 decomposition chain. This is well-defined because g is maintained as an invariant at every finite stage.

### 2. The r-Relation Must Be Three-Argument (Teammate A — HIGH confidence)

Burgess's r-relation (Lemma 2.3, p. 370):

> r(A, B, C) means: for all beta in B, for all gamma in C, U(gamma, beta) in A

The codebase uses `rRelation A B` — a TWO-argument version involving only the left endpoint. Burgess uses `r(A, B, C)` involving BOTH endpoints. The three-argument version is essential because:
- Lemma 2.4 produces (B, C) satisfying r(A, B, C)
- R-maximality R(A, B, C) maximizes B subject to BOTH A and C
- The truth lemma needs r(f(x), g(x,y), f(y)) for the Until case

### 3. Lemma 2.6 Is the Key Missing Construction (Teammate A — HIGH confidence)

Burgess Lemma 2.6 (p. 371):

> Suppose R(A, B, C) and ~delta not in B. Then there exist B', D, B'' such that ~delta in D and R(A, B', D), R(D, B'', C) and B = B' intersect D intersect B''.

This three-way DCS DECOMPOSITION is the workhorse of C4 elimination (Lemma 2.9). It produces:
- f'(z) = D (the new MCS with ~delta)
- g'(x,z) = B' (satisfying R(f(x), B', D))
- g'(z,y) = B'' (satisfying R(D, B'', f(y)))

The codebase is completely missing this construction. The existing C4 elimination assigns f(z) = f(x) or f(z) = f(y) directly, without constructing new g values.

### 4. The Seed Does NOT Include g_content (Teammate A — HIGH confidence)

Burgess Lemma 2.4 seed (C5 elimination):

> C_0 = {gamma} union {S(alpha, beta) : alpha in A}

The seed includes the guard gamma and Since-derivatives — NOT g_content(f(x)). The g_content propagation happens through C3 and the r-relation, not through seeds. The codebase's `lemma_2_4` uses seed `{beta} union g_content(f(x))`, which is a different (non-Burgess) construction.

### 5. Deterministic Chain Is DEAD (Teammates B, C, D — unanimous HIGH confidence)

**The "4 sorry" count was a systematic undercount.** Actual sorry inventory:

| File | Claimed | Actual | Blockers |
|------|---------|--------|----------|
| DeterministicFMCS.lean | 4 | 4 leaf + 6 hidden (x_det/y_det) | forward_F circularity, BX8 removal |
| DeterministicChain.lean | 0 | 5+ (temp_4) + 4 (x_det/y_det) | BX8 removal, stale comments |
| FiniteDeferral.lean | 0 | 2 | Circular dependency, until_induction removed |
| **Total** | **4** | **14+** | **3 independent structural blockers** |

Three independent blockers make the deterministic chain unrecoverable:
1. **BX8 removal kills XY-roundtrip**: `x_det`, `y_det` axioms don't exist in BX
2. **Forward F/P circularity**: Finite deferral needs backward G, which needs forward F (the thing being proved)
3. **x_content cannot resolve F-obligations**: F(psi) in M does NOT imply psi in x_content^n(M) for any n

**One correction**: The `temp_4` sorries (5 instances marked "removed in BX") are FALSE ALARMS — `Axiom.temp_4` IS live in BX (Axioms.lean:112). These could be closed for ~2 hours of free progress.

### 6. Chronicle Has 1 Root-Cause Sorry, Not 12 Independent Ones (Teammates C, D)

The 12 chronicle sorries decompose into:

**Root cause** (1 sorry):
- `g_content_chain_property` (ChronicleConstruction.lean:748)

**Independent** (2 sorries):
- C4 sub-case 1a forward/backward (CounterexampleElimination.lean:289, 355) — likely cascade from root cause via C3 invariant

**Downstream** (9 sorries — cascade automatically when root is closed):
- G/H coherence (2): via `limit_forward_G` / `limit_backward_H`
- Box stability (1): via forward_G/backward_H
- F/P resolution (2): via `limit_F_resolution` / `limit_P_resolution` (already sorry-free!)
- Backward Until/Since (2): pattern from DeterministicFMCS `backward_until_chain` (sorry-free)
- Forward Until/Since (2): via `limit_satisfies_c5_weak` (already sorry-free!)

### 7. Extensive Sorry-Free Infrastructure Exists (Teammate D)

Ready-to-use building blocks:
- PointInsertion.lean (558 lines) — lemmas 2.4-2.7, G_implies_F_mcs — sorry-free
- RRelation.lean (345 lines) — rMaximal_extension_exists — sorry-free
- OrderedSeedConsistency.lean (255 lines) — BX11, enriched seeds — sorry-free
- g/h duality bridge — sorry-free
- limit_F/P_resolution — sorry-free
- limit_satisfies_c5/c5'_weak — sorry-free
- Backward Until/Since chain induction — sorry-free in DeterministicFMCS

## Synthesis

### Conflicts Resolved

1. **"Is the deterministic chain viable?"** — Report 19 (yes, 4 sorries) vs Reports 20-B,C,D (no, 14+ sorries, dead under irreflexive semantics). **Resolution: DEAD. Unanimous across 3 teammates with code-level evidence.** The "4 sorry" count was a systematic undercount that biased cost-benefit analysis.

2. **"Does the seed include g_content?"** — Codebase lemma_2_4 (yes) vs Burgess paper (no, uses {gamma} union {S(alpha, beta)}). **Resolution: The codebase diverges from Burgess.** The codebase's seed is not wrong per se (it may work for a different construction), but it is not Burgess's construction. The Burgess construction routes g_content through C3 and the r-relation instead.

3. **"Is g_content_chain_property the right thing to prove?"** — All prior reports (yes) vs Teammate A (no, C3 is definitional). **Resolution: The property IS needed for the truth lemma, but it should emerge from the construction (C3 invariant + limit), not be proved as a standalone lemma.** The current sorry site is asking the right question in the wrong way.

4. **"Should we continue researching?"** — Teammate C (no, 20 reports is a dead end pattern) vs research findings (breakthrough from paper reading). **Resolution: This round produced genuinely new information (paper text). But Teammate C is correct that the next step MUST be implementation, not more research.**

### Gaps Identified

1. **Lemma 2.6 implementation**: The three-way DCS decomposition is completely missing from the codebase. This is the single most important new construction to implement.
2. **Three-argument r-relation**: The codebase has `rRelation A B` (two-argument). Burgess needs `r(A, B, C)` (three-argument). This is a foundational change.
3. **Truth lemma's "by C3" step**: Teammate A found the paper's terse claim "g(x,y) subset f(z)" on p. 374 requires working through the three-argument r-relation. The exact derivation is not fully extracted yet (MEDIUM confidence).
4. **BX axiom mapping**: Burgess uses axioms A1a-A4a and A1b-A4b. The codebase uses BX1-BX12. The exact correspondence needs verification, especially for the BX9 guard axiom.

## Recommendations

### Priority 1: Implement the Burgess Construction Correctly (plan v8)

A new plan should:
1. **Define three-argument r-relation**: r(A, B, C) per Burgess 2.3
2. **Implement Lemma 2.6**: DCS three-way decomposition — the key missing construction
3. **Maintain C0-C3 as omega-chain invariants**: Modify `eliminate_potential_counterexample` to produce chronicles satisfying C0+C1+C2+C3 (not just C0)
4. **Define g values at insertion time**: When inserting z between x and y, construct g'(x,z), g'(z,y) via Lemma 2.6, and define all other g' values via C3
5. **Define limit_g correctly**: limit_g(x,y) = intersection over C3 decomposition, not `deductiveClosure(g_content(limit_f(x)))`

### Priority 2: Fix temp_4 False Alarms (1-2 hours, free progress)

The 5 `sorry /- temp_4 removed in BX -/` in DeterministicChain.lean are based on stale comments. `Axiom.temp_4` IS in BX. Even though the deterministic chain is dead for completeness, fixing these sorries is free progress.

### Priority 3: Abandon Deterministic Chain Path

The deterministic chain should NOT be investigated further for completeness. It has 14+ sorries and 3 structural blockers under irreflexive semantics. The backward Until/Since proof pattern is reusable but the chain itself is dead.

### Priority 4: Stop Researching, Start Implementing

Teammate C's critique is valid: 20 reports and 7 plan versions indicates a research-accumulation pattern. The Burgess paper has now been read and the construction extracted. The next step MUST be a plan revision (v8) incorporating the three-argument r-relation and Lemma 2.6, followed immediately by implementation.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Burgess paper extraction | completed | HIGH | Read full paper; C3 definitional, 3-arg r-relation, Lemma 2.6 |
| B | Deterministic chain F-witness | completed | HIGH | Circularity confirmed, ordered seeds inapplicable |
| C | Critical evaluation | completed | HIGH | 14+ sorries (not 4), temp_4 false alarm, "stop researching" |
| D | Codebase deep dive | completed | HIGH | Sorry dependency map, x_content analysis, minimum path |

## References

- Burgess 1982, "Axioms for Tense Logic I: Since and Until", NDJFL Vol. 23 No. 4, pp. 367-374 — [Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870149) — **read in full**
- Verbrugge et al., "Completeness by Construction" — different method (no Until/Since), not applicable
- Gabbay, Hodkinson, Reynolds 1994 — quasimodel approach (fallback if chronicle stalls)
