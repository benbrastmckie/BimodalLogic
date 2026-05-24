# Research Report: Task #155 — Formula C Literature Alignment

**Task**: 155 - reynolds_pipeline_activation
**Date**: 2026-05-24
**Mode**: Team Research (5 teammates)
**Session**: sess_1779610495_46c9e0

## Summary

Five teammates investigated the alignment gap between GHR93's formula C and the Lean formalization's `cont_holds` predicate. All five converge on the same root diagnosis: `cont_holds` encodes the SEMANTIC content of GHR93's interval-type formula C but cannot participate SYNTACTICALLY in the proof (cannot appear in C' = ¬C ∨ K⁻(¬C), cannot be transferred through game positions). This encoding choice accounts for 7 of the 14 critical-path sorry sites. The circularity previously attributed to materializing C as a StaviFormula is narrower than reported — it affects only the NormalForm→StaviFormula inversion path (Approach B), not the direct enumeration path (Approach A). However, Approach A requires `Fintype` infrastructure that may be blocked by the atom type's cardinality. Two resolution strategies emerge: (1) the case-split approach bypasses formula materialization entirely, (2) `Fintype (BoundedStaviFormula r)` enables GHR93-verbatim proof.

## Key Findings

### 1. GHR93's Formula C: Exact Definition and Role (Teammate A)

GHR93 Definition 8.8 defines C = X_{(alpha_{n-1}, y')} as the conjunction of all rank-r temporal formulas holding at every mu-point in the interval (alpha_{n-1}, y'). Since there are finitely many inequivalent rank-r formulas (finite signature), this is a FINITE conjunction — a concrete syntactic formula of rank ≤ r, not a predicate.

C is constructed at the BEGINNING of the inductive step, BEFORE the induction hypothesis is invoked. The IH enters only at Claim 2 and Cases I-IV. There is no circularity in the induction structure itself.

### 2. The Predicate-vs-Formula Gap Is the Root Cause (All 5 Teammates)

The Lean code defines `cont_holds a_n y' t` as: "for ALL StaviFormulas A with stavi_depth ≤ r, if A holds at all mu-points in (a_n, y'), then A holds at t." This is semantically correct but syntactically opaque. The consequence:

- GHR93 forms C' = ¬C ∨ K⁻(¬C) as a formula of rank r+1 → the Lean code cannot
- GHR93 transfers C' through game positions → the Lean code cannot
- GHR93's Claim 1 is 5 lines → the Lean version has 7 sorry sites

### 3. Rank Off-by-One Confirmed (Teammate A, New Finding)

C' = ¬C ∨ K⁻(¬C) has:
- GHR93 rank: r+1 (one temporal connective K⁻)
- Lean stavi_depth: r+2 (because `std_snce` adds +2, not +1)

This means `h_fwd_r1` must provide a game at rank r+2 (not r+1) for C' to be within the game budget. The forward hypothesis at rank r+4(n+1) ≥ r+4 easily accommodates this. This requires changing 6 signature locations (~30 lines).

### 4. The Circularity Is Narrower Than Previously Claimed (Teammates A, B, C, D)

**Circular (Approach B)**: NormalForm → MonadicFormula → StaviFormula. This inversion IS the expressive completeness theorem.

**Non-circular (Approach A)**: Enumerate StaviFormulas of bounded depth directly, take conjunctions by truth at mu-points. This constructs C without touching NormalForm.

**Non-circular (Approach C, case-split)**: Don't materialize C at all. Split on whether `cont_holds` holds at the infimum. In each case, a specific formula is available without universal materialization.

### 5. The Atom Type May Block Approach A (Teammate E, Critical Caveat)

Teammate E discovered that the `Atom` type is `Countable + Infinite`, making `Fintype { A : StaviFormula // stavi_depth A ≤ r }` impossible over the full atom type.

**Resolution**: This depends on whether StaviFormula is parameterized by `Atom` (infinite) or instantiated with `muSig sig` (finite). GHR93 works with a finite signature. If the relevant StaviFormulas use `muSig sig` atoms (which is `Fintype`), then Approach A works. If they use the abstract infinite `Atom`, Approach A is blocked and the case-split (Approach C) is the only viable path.

**This is the key question the synthesis cannot resolve without checking the code.** The next implementation session must verify whether `stavi_temporal_truth_mu` uses a `Fintype` atom set.

### 6. Case-Split Fix Targets May Be Outdated (Teammate C, Critical Warning)

Reports 38/39 designed the case-split against sorry sites at lines 2307, 2331, 2792, 2806, 2825. The current sorry inventory (report 30) shows lines 3901, 3935, 4412, 4424, 4468, 4483, 4508. The code has been substantially restructured since reports 38/39 were written. The case-split approach is logically sound but must be verified against the CURRENT sorry sites before implementation.

### 7. Position-Tracking Sorries Need a Separate Fix (Teammates A, C)

Lines 4483/4508 (position constraint after `rank_down`) are structurally different from the formula C cluster. `rank_down` projects from rank r+2 to rank r but loses position-level tracking. Neither the case-split nor Approach A addresses this. Fix: either inline `rank_down`'s projection (~200 lines) or prove `rank_embed_project_eq` (~50-100 lines).

### 8. The Same Discovery Was Made 5+ Times (Teammate E, Historical Pattern)

The predicate-vs-formula root cause was independently identified in reports 29, 36, 38, 39, 40, and the formula-materialization handoff. Each time, a partial fix was proposed but not fully implemented, causing the next session to re-derive the same conclusion. This pattern suggests any fix must be carried through to completion in a single focused session.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Approach A feasibility (B/C/D: works; E: blocked by infinite Atom) | Depends on atom type parameterization. Must check if `stavi_temporal_truth_mu` uses `Fintype` atoms. If yes, Approach A works. If no, use Approach C (case-split). |
| Case-split targets (E: reports 38/39 approach; C: targets outdated sites) | The LOGIC of the case-split is sound. The specific LINE NUMBERS need re-verification against current code. The approach must be re-mapped to current sorry sites before implementation. |
| Rank of h_fwd_r1 (A: needs r+2; prior code: uses r+1) | Teammate A is correct. `std_snce` adds +2 to stavi_depth. C' has depth r+2. h_fwd_r1 must be at rank r+2. |

### Gaps Identified

1. **Atom type cardinality**: Is `StaviFormula` parameterized by `Fintype` atoms in the context where C is needed? This determines whether Approach A is feasible.
2. **Current sorry site mapping**: The case-split approach from reports 38/39 must be re-mapped to the current sorry locations (3901, 3935, 4412, 4424, 4468, 4483, 4508).
3. **Truth at gaps**: For the gap sub-case (S2, line 3935), does `stavi_temporal_truth_mu` at a gap inherit from surrounding carrier points? This determines whether S2 closes via the case-split alone.
4. **Position tracking**: Lines 4483/4508 need a separate fix (rank_down inlining or rank_embed_project_eq). No report has analyzed this in detail.

### Recommended Attack Order

**Immediate (always required regardless of approach):**
1. Change h_fwd_r1 from rank r+1 to r+2 across 6 signature locations (~30 lines)

**Then, choose ONE of two paths:**

**Path A — If atoms are Fintype (preferred, aligns with GHR93):**
1. Build `Fintype { A : StaviFormula // stavi_depth A ≤ r }` (~150-200 lines)
2. Define `interval_type_formula : StaviFormula` using the enumeration (~50 lines)
3. Prove `cont_holds ↔ stavi_truth interval_type_formula` (~100 lines)
4. Close all 7 Claim 1 sorries via GHR93's 5-line proof (~80 lines)
5. Delete ~360 lines of pigeonhole machinery

**Path B — If atoms are infinite (pragmatic, proven sound):**
1. Re-map case-split from reports 38/39 to current sorry sites (~60 lines of analysis)
2. Implement case-split on `cont_holds` at infimum (~240 lines, closes S1/S2)
3. Build truth-at-gap lemma for S2 gap sub-case (~80 lines)
4. Close S3 (mechanical multi-round adaptation, ~65 lines)
5. Close S5 (multi-round gap case, ~255 lines)

**Independent of path choice:**
- Close position-tracking sorries S6/S7 via rank_embed_project_eq (~100 lines)
- Close mechanical sorry S8 (cross-boundary ordering, ~50 lines)

**Strategic (after completeness achieved):**
- Take the OrderIso bypass for sorry-free `bx_completeness` (~310-510 lines, independent of GHR93 pipeline)
- Continue GHR93 formalization as a standalone mathematical contribution

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | GHR93 deep read | completed | high | Rank off-by-one (r+2, not r+1); S1 closure via witness point; traced C through full proof |
| B | Alternative approaches | completed | high | Non-circular Fintype construction; case-split mechanics; tiered attack order |
| C | Critic | completed | high | Case-split targets outdated sorry sites; position-tracking is separate problem; Approach A is fastest |
| D | Strategic horizons | completed | high | OrderIso bypass recommendation; Fintype as separate task; GHR93 has standalone value |
| E | Retrospective review | completed | high | Same root cause rediscovered 5x; handoff-b was wrong; infinite Atom type blocks direct enumeration |

## References

- GHR93 Section 8, Definition 8.8 (p.113): interval-type formula definition
- GHR93 Section 8, Claim 1 (p.116): C' = ¬C ∨ K⁻(¬C) proof
- Report 29 (d-consistency-architecture): definitive infimum necessity proof
- Report 35 (phase1-blocker-prior-art): comprehensive GHR93 deep read
- Reports 38-39 (pigeonhole/remove-pigeonhole): case-split approach
- Report 30 (forward-inventory): current sorry map
- Report 30 (critical-path-wiring): OrderIso bypass analysis
- Report 40 (literature-crossref): comprehensive sorry-to-GHR93 mapping
