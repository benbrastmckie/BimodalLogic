# Team Research Report: Task 273 Phase 5 Blocker Resolution

- **Task**: 273 — chronicle_gap_contradiction_proof
- **Date**: 2026-06-12
- **Mode**: Team Research (4 teammates)
- **Session**: sess_1781280732_3c7cfe
- **Status**: [RESEARCHED]
- **Type**: lean4

## Summary

Four teammates investigated the Phase 5 blocker from complementary angles. All four confirm that **Path B (Rabinovich Lemma 3.2.2 + Prop 4.3) is the correct resolution strategy**, and no alternative source provides an easier path. However, the critic (Teammate C) discovered a potentially game-changing shortcut: **`p2_from_p1_succ` in FoToVecEA.lean is sorry-free but orphaned** — nothing imports it — and a restructured two-phase induction could bypass both Path A and Path B entirely if `nf_char_kp1_from_2var` uses only the forward direction of P2(k). This is the highest-priority question to investigate before committing to Path B.

## Key Findings

### 1. The P1/P2 Circularity is Real and Structural (All teammates agree)

The master mutual induction at NegationClosure.lean:1394 proves P1(k) ∧ P2(k) by induction on k. At step k+1:
- P1(k+1) = `nf_char_kp1_from_2var(P1(k), P2(k))` — **sorry-free**
- P2(k+1) = `nf_exist_formula_nested_backward` — **SORRY at line 1371**

The circularity: P2(k+1) requires composition of 3-var NFs from pairwise 2-var NFs (witness merging), which has failed 5 times. The composition theorem is necessary but not sufficient because the formula `nf_exist_formula_nested` encodes only positive interval conditions, not negative ones.

### 2. Critical Discovery: `p2_from_p1_succ` is Sorry-Free but Orphaned (Teammate C)

**This is the most important finding.** FoToVecEA.lean contains three sorry-free, complete proofs:
- `nf_exist_iff_char_quant` — semantic bridge between NF existence and characteristic NF
- `nf_exist_iff_nf1_disjunction` — NF existence as disjunction over depth-(k+1) 1-var NFs
- `p2_from_p1_succ` — **P2(k) directly from P1(k+1), no composition lemma needed**

**Nothing imports FoToVecEA.lean.** These theorems are dead code.

`p2_from_p1_succ` gives P2(k) from P1(k+1). In the master_induction at step k+1, P1(k+1) is already proven (sorry-free). So `p2_from_p1_succ` applied at k gives P2(k) from P1(k+1). But we need P2(k+1), not P2(k).

**However**: at step k+1, the master_induction constructs P1(k+1), so at step k+2 it would have P1(k+2). If we apply `p2_from_p1_succ` at k+1, we get P2(k+1) from P1(k+2). But P1(k+2) needs P2(k+1) — still circular in the current structure.

**The potential escape**: If `nf_char_kp1_from_2var` uses only the **forward direction** of P2(k) (formula-truth → NF-existence, which is already sorry-free), then:
1. Prove P1(k) for all k using only forward-P2(k) (which is sorry-free)
2. Derive full P2(k) from P1(k+1) via `p2_from_p1_succ`

This would require ~50-100 lines of restructuring instead of 480-630 lines for full Path B.

### 3. KEY UNRESOLVED QUESTION: Does `nf_char_kp1_from_2var` Use Both Directions of P2(k)?

This question was raised by Teammate C but not definitively answered by any teammate. It is the **single most important question** for determining the optimal resolution path:

- **If only forward P2(k) is used**: Restructured two-phase induction, ~50-100 lines, HIGH confidence
- **If both directions are used**: Full Path B (Lemma 3.2.2 + Prop 4.3), ~480-630 lines, MEDIUM-HIGH confidence

**Recommendation**: Before committing to any implementation, read `nf_char_kp1_from_2var` in NegationClosure.lean carefully and trace exactly how `p2_k` is used.

### 4. Path B Architecture (Teammates A + D)

If full Path B is needed, the implementation requires:

| Component | Lines | Hours | Source |
|-----------|-------|-------|--------|
| `vecEAFormula_holds` (general evaluation) | ~30 | 1 | Rabinovich Def 3.1 |
| Lemma 3.2.2 (n-var EA → conjunction of 2-var EA) | ~150-200 | 4-6 | Rabinovich p.4 |
| `nf_to_monadicFormula` bridge | ~100-150 | 3-5 | Formalization-specific |
| Prop 4.3 structural induction | ~100-150 | 3-5 | Rabinovich p.6 |
| Connection to `kamp_prior_expressive_completeness` | ~100 | 2-3 | Formalization-specific |
| **Total** | **480-630** | **13-20** | |

**Critical gap identified by Teammate A**: The `VecEAFormula` type in VecEAFormula.lean has no semantic evaluation function (`vecEAFormula_holds`). Only `BracketFormula` and `VecEA2` have `holds`. This must be added before Lemma 3.2.2 can be stated.

**Key insight from Teammate B**: The master_induction uses NF **depth** induction (k : Nat) while Rabinovich's Prop 4.3 uses **formula structure** induction (MonadicFormula.rec). This mismatch is the root cause of the circularity. Path B resolves it by replacing the NF-depth induction with structural induction.

### 5. No Alternative Sources Provide an Easier Path (Teammate B)

| Source | Approach | Estimated Effort | Verdict |
|--------|----------|-----------------|---------|
| Doets 1989 Lemma 1.5 | EF game composition | 200-300 lines + game infrastructure | More work than Path B |
| GHR93 Prop 7 | Backward game theorem | 400-600 lines + game infrastructure | Valid fallback, more work |
| GHR94 Ch10 | Syntactic separation | 600-800 lines (12 elimination cases) | Much more work |
| Thomas 1997 | MSO composition | PDF unavailable | Cannot assess |
| **Rabinovich Prop 4.3** | **Structural induction** | **480-630 lines** | **Recommended** |

### 6. Strategic Value (Teammate D)

- `kamp_prior_expressive_completeness` has **6+ callsites** in `GoodStructuresModelSurgery.lean`
- Task 273 is a **strict prerequisite** for task 202 (Reynolds bypass)
- Both chains must close for `completeness_discrete`
- The vec-EA framework (2400+ lines from phases 1-4) is **general-purpose reusable infrastructure** for dense completeness, Doets Lemma 1.5, and future work
- Path B represents ~10% more work on top of existing sorry-free infrastructure to complete the main theorem

## Synthesis

### Conflicts Resolved

**Conflict 1: Is `p2_from_p1_succ` useful or circular?**
- Handoff says: "CIRCULAR" and dismisses it
- Critic says: Potentially game-changing shortcut
- **Resolution**: Both are correct in their scope. Within the current mutual induction, using `p2_from_p1_succ` is circular. But with a restructured induction (if forward-only P2(k) suffices for P1(k+1)), it becomes a shortcut. The question is empirical — read `nf_char_kp1_from_2var` to determine which directions of P2(k) it uses.

**Conflict 2: Effort estimates for Path B**
- Teammate A: 480-630 lines (13-20 hours)
- Teammate D: 400-600 lines
- Handoff: 400-600 lines
- Teammate C: "Likely underestimate" due to NF-to-FO bridge
- **Resolution**: 480-630 lines is the most carefully derived estimate (Teammate A's component breakdown). The NF-to-FO bridge (`nf_to_monadicFormula`) is the main uncertainty — if it already exists in the codebase, effort drops by ~150 lines.

**Conflict 3: Does Path B directly close the sorry at NegationClosure.lean:1371?**
- Teammate C says: No — Prop 4.3 is about FO formulas, not NF backward direction
- Teammate A says: Path B requires restructuring the proof, not filling the sorry directly
- **Resolution**: Correct — Path B does NOT fill the sorry at line 1371. It **replaces** the master_induction with a structural induction that doesn't need that sorry. The sorry becomes dead code.

### Gaps Identified

1. **FoToVecEA.lean build status**: Nobody verified whether it actually builds. It's an orphan file — could have silent type errors.
2. **`nf_to_monadicFormula` existence**: Nobody confirmed whether this bridge function already exists in the codebase. Search needed.
3. **Which directions of P2(k) does `nf_char_kp1_from_2var` use**: The single most important unresolved question.
4. **`parent_atoms` compatibility**: Risk 3 from Teammate C — Prop 4.3 output must be conditioned on `parent_atoms` to match the P2(k) interface.

### Recommendations (Priority Order)

**Step 0 (Pre-implementation verification, ~1 hour)**:
1. Verify FoToVecEA.lean builds: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.FoToVecEA`
2. Read `nf_char_kp1_from_2var` to determine which direction(s) of P2(k) it uses
3. Search for `nf_to_monadicFormula` or equivalent in the codebase

**If forward-only P2(k) suffices (optimistic path, ~100 lines)**:
- Restructure master_induction into two phases
- Wire `p2_from_p1_succ` for backward P2(k)
- This is dramatically simpler than Path B

**If both directions needed (Path B, ~480-630 lines)**:
Following the hard-mode orchestration approach:
- Phase 5a: Add `vecEAFormula_holds` + Lemma 3.2.2 (~200 lines)
- Phase 5b: Add `nf_to_monadicFormula` + Prop 4.3 structural induction (~250 lines)
- Phase 5c: Restructure `kamp_prior_expressive_completeness` to use Prop 4.3 (~100 lines)
- Phase 6-8: Wire downstream sorries + verification (existing plan)

**Orchestration guidance** (from hard-mode approach):
- Dispatch each sub-phase to a focused agent (per-phase dispatch, H1)
- Include anti-analysis contract (H2): read budget ≤15-20%, first file edit early
- Include prior-art grounding mandate (H3): cite Rabinovich page numbers
- Verify architecture before implementing (H4/H5): the Step 0 verification IS the adversarial pre-check

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Primary: Lemma 3.2.2 formalization | completed | vecEAFormula_holds missing; nf_to_monadicFormula needed; 480-630 lines | high on viability, medium on effort |
| B | Alternatives from literature | completed | No easier path exists; induction mismatch is root cause | high |
| C | Critic: verify analysis | completed | p2_from_p1_succ orphaned but potentially critical; Path B doesn't directly close sorry | high |
| D | Horizons: strategic direction | completed | 6+ callsites depend on this; prerequisite for task 202; vec-EA is reusable | high |

## References

- Rabinovich 2014, pp. 3-6: Lemma 3.2, Def 3.3, Lemma 3.4, Prop 3.5, Prop 4.2, Prop 4.3
- Doets 1989, p. 227: Lemma 1.4/1.5 (ordered sum composition)
- GHR93, pp. 113-114: Proposition 7 (m-tuple composition via EF games)
- GHR94 Ch10: Syntactic separation (12 elimination cases)
- Hard-mode orchestration report: H1 (per-phase dispatch), H2 (anti-analysis), H3 (prior-art grounding), H4/H5 (adversarial verification)

## Next Steps

1. **Immediate**: Investigate the unresolved question (Step 0 above)
2. **Then**: Either restructure induction (optimistic) or implement Path B (sub-phases 5a-5c)
3. **After Phase 5**: Phases 6-8 from plan v21 (wire downstream sorries, full build verification)
4. **After task 273**: Task 202 (Reynolds bypass) becomes unblocked
