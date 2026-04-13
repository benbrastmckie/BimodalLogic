# Research Report: Task #93 — Close BXCanonical Embedding (Round 10)

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776115804_92a64f

## Summary

Fifth team research round. All 4 teammates converge on two critical findings that definitively kill Plan v8: (1) the resolving-seed-with-untilCarry counterexample is re-validated — it IS inconsistent and no BX axiom rescues it; (2) the BX12 reduction path (`F(phi) -> (top U phi)`) fails because `(top U phi)` is NOT in `subformulaClosure(root)` or `deferralClosure(root)`. This means **both** of Plan v8's core mechanisms (Phase 2 and Phase 5) are broken. Two new architectures emerge as viable replacements: (A) extend `deferralClosure` to include `(top U phi)` for each `F(phi)`, reducing forward_F entirely to forward Until via BX12, then prove forward Until using the existing sorry-free quasimodel defect-discharge infrastructure; (B) build a root-parameterized chain with finite round-robin schedule over `deferralClosure(root)`. The FMP Bridge remains banned per ROAD_MAP item 10.

## Key Findings

### Primary Approach Analysis (from Teammate A)

**Architecture C (full quasimodel replacement) is NOT recommended.**

A thorough analysis of the existing 1,931-line quasimodel infrastructure reveals a fatal gap documented at `Realization.lean:366-395`: G-formulas do NOT persist through the Hintikka chain, so lifting finite Hintikka chains to infinite Int-indexed MCS chains fails. Architecture C would hit the SAME realization obstacle that blocked the original quasimodel approach.

However, A confirms that the existing scheduling chain IS correct for g_content/h_content propagation (~400 lines of proved lemmas). The problem is exclusively in the coherence proofs, not the chain construction itself.

**Key insight**: The step-transfer circularity. To prove `(phi U psi) in chain(r)` from `(phi U psi) in chain(r+1)`, one needs `(phi U psi)` in the seed for `chain(r+1)`, which comes from `untilCarry(chain(r))`, which requires `(phi U psi) in chain(r)` — circular. A novel BX argument is needed for step transfer.

**Confidence**: LOW-MEDIUM for Architecture C; MEDIUM for Plan v8 Approach A (but see below for why v8 is dead).

### Alternative Approaches Analysis (from Teammate B)

**Restricted forward_F CANNOT be proved on the existing chain**, even with the restriction. The core issue: F-formulas are lost at resolving steps for OTHER formulas, and the restricted version faces the same gap as unrestricted.

**Exhaustive BX axiom check on the counterexample**: All of BX5, BX7, BX9, BX10, BX11, BX12 were systematically checked against the seed `{psi, neg(alpha), (alpha U neg(psi))}`. No axiom rescues the seed. The inconsistency is genuine and complete.

**BX12 reduction is NOT viable with current closures**: `(top U psi)` is never in `subformulaClosure(root)` or `deferralClosure(root)` unless syntactically present in the root. The `EnrichedClosure.lean` only adds `G/H(neg(bigconj T))` formulas, not Until formulas.

**Filtered untilCarry** (excluding Until formulas with right operand `neg(psi)`) avoids the known counterexample but lacks a consistency proof. The generalized temporal K technique cannot accommodate non-G-universalized Until formulas.

**Novel recommendation**: A root-parameterized chain with finite round-robin schedule over `deferralClosure(root)`, ensuring F-carry survives all steps within the restricted set. Estimated 200-300 lines.

**Confidence**: HIGH on counterexample validity; MEDIUM on root-parameterized chain.

### Critical Analysis (from Teammate C)

**Plan v8 has TWO fatal flaws:**
1. Phase 2 (resolving seed consistency with untilCarry) — REFUTED by concrete counterexample
2. Phase 5 (BX12 reduction from forward_F to forward Until) — BLOCKED by closure gap

**Counterexample independently re-verified** step-by-step:
- M = {F(psi), G(neg(alpha)), (alpha U neg(psi))} is consistent (model: psi at time 1, alpha false everywhere, neg(psi) at time 0)
- Seed = {psi, neg(alpha), (alpha U neg(psi))}
- BX9: `(alpha U neg(psi)) -> alpha v neg(psi)`. With neg(alpha): get neg(psi). With psi: bot.
- All BX axioms checked: BX10 gives F(neg(psi)) which coexists with F(psi); BX7 N/A (one Until formula); BX5/BX11 don't rescue.

**DeterministicFMCS (Boneyard) is NOT viable**: Has 6 sorries on removed axioms (x_det, y_det, etc.) plus its own forward_F sorry.

**f_carry in resolving seed investigated**: Initially promising (`f_carry(M) subset M` so seed is subset of `M union {psi}`), but consistency proof fails because f_carry can create inconsistency. Specifically (Report 07 Finding 2): when `psi = G(neg(chi))` and `F(chi) in f_carry(M)`, the seed contains both `G(neg(chi))` and `F(chi) = neg(G(neg(chi)))` — inconsistent.

**UntilSinceCoherence module is well-designed**: Provides parameterized backward Until/Since given step-transfer. The problem reduces to providing step-transfer.

**Confidence**: HIGH on counterexample and BX12 gap; MEDIUM on f_carry analysis.

### Strategic Analysis (from Teammate D)

**BX12 Reduction (Approach 2) is mathematically sound but needs closure extension.**

The axiom `F(phi) -> (top U phi)` (BX12) eliminates forward_F as an independent obligation by reducing it to forward Until. The blocker is purely that `(top U phi)` is not in current closures. Fix: extend `deferralClosure` to include `(top U phi)` for each `F(phi)`. This is ~20 lines of code.

**Quasimodel-based BFMCS (Approach 5) is the highest-potential creative approach.**

Instead of the scheduling chain, build the BFMCS directly from quasimodel chains:
1. Build quasimodel chain for `subformulaClosure(phi)` — existing sorry-free infrastructure
2. Realize as BXPoint chain — existing Realization.lean
3. Extend finite chain to Int with identity tail
4. Until/Since coherence follows from defect-discharge inherently
5. Forward_F reduced to forward Until via BX12

Estimated 300-500 lines. Best roadmap alignment (reusable for task 68 dense completeness).

**Reynolds 1996/2003 insight confirmed**: The enriched closure with `(top U phi)` for `F(phi)` targets is the standard textbook technique. The codebase already has BX12 as an axiom; only the closure definitions need updating.

**Strict vs non-strict inequality issue**: Forward_F needs `s > t` (strict), but forward Until allows `s >= t` (non-strict). The BX12 reduction gives a witness `s >= t` which only gives `s > t` when the reflexive case `s = t` produces `phi in fam.mcs(t)` — but then we need to find a STRICT future witness. This can be resolved: if `phi in fam.mcs(t)`, then `F(phi) in fam.mcs(t)` (from `phi -> F(phi)` via BX8+BX10), and the chain resolves F(phi) at some later step, giving `s' > t`.

**Confidence**: MEDIUM-HIGH on BX12 reduction; MEDIUM on quasimodel BFMCS.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is Plan v8 viable?**
- A: Yes, execute Plan v8 as-is with 4-hour cutoff
- B: No, resolving seed consistency WILL FAIL, need new chain construction
- C: No, BOTH Phase 2 and Phase 5 are broken
- D: No, Plan v8 is dead, need BX12 reduction + new construction
- **Resolution**: Plan v8 is DEAD. B, C, D all independently confirm the counterexample and BX12 closure gap. A's analysis is less definitive but A also gives only 40-50% success probability for the consistency proof, acknowledging the counterexample. **Verdict: ABANDON Plan v8.**

**Conflict 2: Best replacement architecture**
- A: Stick with seed enrichment approach (Approach A) with non-resolving-only untilCarry fallback
- B: Root-parameterized chain with finite round-robin schedule (200-300 lines)
- C: f_carry in resolving seed + UntilSinceCoherence for backward; fallback full quasimodel
- D: BX12 closure extension + quasimodel-based BFMCS (300-500 lines)
- **Resolution**: B and D propose structurally different approaches. B modifies the scheduling mechanism; D replaces it with quasimodel infrastructure. D's approach reuses more existing code (2,289 lines of sorry-free quasimodel infrastructure) and has better roadmap alignment (reusable for task 68). C's f_carry in resolving seed is blocked by the same inconsistency patterns (Report 07 Finding 2). **Verdict: D's approach (BX12 closure extension + quasimodel BFMCS) is primary; B's approach (root-parameterized chain) is secondary fallback.**

**Conflict 3: Effort estimate for Architecture C**
- Report 09: 500-800 lines, 15-25% risk
- A: Fatal gap (Realization.lean obstacle), NOT recommended at all
- C: 800-1200 lines realistic
- D: 300-500 lines via Approach 5 (different from traditional Architecture C)
- **Resolution**: A is correct that TRADITIONAL Architecture C (full Burgess 1984 replacement) is blocked by the Realization.lean G-persistence obstacle. D's Approach 5 is a DIFFERENT architecture that builds BFMCS from quasimodel chains without going through the problematic realization lifting. **Verdict: Traditional Architecture C is NOT viable; D's Approach 5 (quasimodel-based BFMCS) is the correct formulation, estimated 300-500 lines.**

### Gaps Identified

1. **BX12 strict inequality**: Forward_F needs `s > t` but BX12 gives `s >= t`. The resolution (via chain resolution of F(phi)) needs formalization. This is a proof obligation, not a blocker.

2. **Quasimodel-to-Int extension**: D's Approach 5 extends a finite quasimodel chain to Int with an identity tail. The identity tail's coherence properties need verification: does `chain(n) = chain(last)` for all `n > last` preserve all restricted coherence properties?

3. **Realization.lean interface**: D notes the current `Realization.lean` targets `Frame.lean`, not `BFMCS`. The interface adaptation is the main engineering challenge for Approach 5.

4. **Backward Until step-transfer**: All approaches need step-transfer for backward Until. The `UntilSinceCoherence` module provides the parameterized version, but the step-transfer hypothesis must be supplied. In the quasimodel approach, step-transfer comes from the Hintikka chain's defect-propagation property.

5. **Since direction**: All analysis focuses on Until. The Since direction (backward time) is symmetric but doubles the proof obligations. Needs explicit treatment.

### Recommendations

**Tier 1 — Immediate actions (before committing to architecture):**

1. **Extend deferralClosure** (~20 lines, 1 hour): Add `(top U phi)` for each `F(phi)` in `deferralClosure(root)`. This is a Reynolds-style enrichment that enables BX12 reduction. Verify downstream lemmas still compile.

2. **Verify identity-tail coherence** (~2 hours): For a constant chain segment `chain(n) = chain(last)` for `n > last`, verify that all 3 restricted coherence properties hold trivially (no pending F-obligations, all defects resolved in finite portion).

3. **Trace Realization.lean interface** (~2 hours): Map the gap between `Realization.lean`'s output (BXPoint chains) and `BFMCS`'s input (Int-indexed MCS families). Determine what adapter code is needed.

**Tier 2 — Execute primary approach:**

4. **Implement BX12 reduction + quasimodel BFMCS** (Approach 5, estimated 300-500 lines, 12-16 hours):
   - Extend deferralClosure with `(top U phi)` enrichment
   - Build `quasimodel_fmcs : Formula -> Set Formula -> FMCS Int` that:
     - Uses quasimodel defect-discharge for the finite portion
     - Extends with identity tail for the infinite portion
   - Prove restricted coherence from quasimodel properties
   - Wire into `bx_bfmcs` in place of current sorry-laden proofs

**Tier 3 — Fallback:**

5. **Root-parameterized chain** (Teammate B's approach, estimated 200-300 lines, 8-12 hours):
   - Modify chain construction with finite round-robin schedule
   - Prove F-carry survives through restricted-set-only resolving steps
   - Simpler but less reusable than Approach 5

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (Architecture C) | completed | LOW-MEDIUM | Identified Realization.lean G-persistence obstacle killing traditional Architecture C; confirmed scheduling chain is correct for g_content |
| B | Alternatives (restricted_tc refactoring) | completed | HIGH/MEDIUM | Exhaustive BX axiom check on counterexample; BX12 closure gap confirmed; root-parameterized chain design |
| C | Critic | completed | HIGH | Independent counterexample re-validation; Plan v8 double-fatality (Phase 2 + Phase 5); f_carry in resolving seed inconsistency; UntilSinceCoherence reuse |
| D | Strategic Horizons | completed | MEDIUM-HIGH | BX12 reduction architecture; quasimodel-based BFMCS (Approach 5); Reynolds enrichment insight; roadmap alignment analysis |

## Key Decision Points

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Plan v8? | Execute / Abandon | **ABANDON** — both core mechanisms refuted |
| Architecture C (traditional)? | Execute / Skip | **SKIP** — Realization.lean obstacle |
| BX12 closure extension? | Extend / Skip | **EXTEND** — ~20 lines, enables F→U reduction |
| Primary architecture? | Quasimodel BFMCS / Root-param chain / Fix scheduling | **Quasimodel BFMCS** (Approach 5) |
| Fallback? | Root-param chain / Full quasimodel / None | **Root-param chain** (Teammate B) |

## References

- Burgess 1984, "Basic Tense Logic" — quasimodel defect discharge
- Reynolds 1996/2003 — F-to-Until reduction via enriched closure (BX12)
- Xu 1988 — BX completeness over linear orders
- Verbrugge 2007 — completeness by construction
- Demri, Goranko, Kupferman 2016 — Temporal Logics in Computer Science
- Report 09 (team research) — counterexample, 3 architectures ranked
- Handoff 08 — two irreducible blockers documented
- Report 07 — enriched seed consistency gap, f_carry inconsistency
- `Realization.lean:366-395` — G-persistence obstacle documentation
