# Research Report: Task #93 - Round 40

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1776542705_d17119
**Focus**: Review v39 implementation failure and identify mathematically correct long-term solution

## Summary

After a definitive implementation failure in v39 and 39 prior research rounds, this round conducted a systematic review with 4 independent teammates. All teammates converge on three critical conclusions:

1. **The v39 obstacle is confirmed and irreducible**: The proposed derived rule `phi /\ F(phi U psi) -> phi U psi` is semantically invalid (explicit counter-model provided). No BX1-BX12 derivation can close this gap.

2. **The round-robin dd_chain architecture is fundamentally wrong**: All standard temporal logic completeness proofs (Goldblatt, Burgess, Reynolds) avoid the BX11 round-robin fold entirely. The perpetual deferral obstruction is an artifact of the wrong proof strategy, not a fundamental limitation of BX completeness.

3. **Two viable alternative paths exist**, both bypassing dd_chain:
   - **Path A: defect_fwd_chain induction** (~400 LOC, 40% confidence) - Prove `defect_fwd_chain_forward_F` by list induction. Base case is already proved (`defect_fwd_step_choice_singleton`).
   - **Path B: quasimodel-based BFMCS** (~800 LOC, 55% confidence) - Build a new `qm_bfmcs` bypassing `dd_fmcs` entirely. Restricted_tc holds BY CONSTRUCTION.

**Critical precondition for both paths**: Prove `until_defects_seed_consistent` -- that `g_content(M) U {Until-defects of M}` is consistent for MCS M.

**Novel insight from Teammate B**: For integer-indexed chains, restricted_fuc is simplified by the vacuous interval guard: there are no integers strictly between t and t+1, so the Until guard condition `forall r in [t, s), phi in mcs(r)` is vacuously true when s = t+1.

## Key Findings

### 1. V39 Obstacle CONFIRMED: Semantically Invalid Derived Rule (A, HIGH confidence)

The rule `phi /\ F(phi U psi) -> phi U psi` is NOT semantically valid on linear temporal orders.

**Counter-model**: Linear order Z. phi holds at 0 and 2, psi holds at 2, phi fails at 1.
- F(phi U psi) at t=0: witness t=2 where (phi U psi)(2) holds (psi at 2, empty guard)
- phi at t=0: true
- (phi U psi)(0): false (guard fails at t=1 for any witness >= 2)

Since BX1-BX12 is sound on all linear orders, this counter-model proves the rule is NOT derivable. The Boneyard proof works ONLY because the deterministic chain is constant (X(phi) = phi under reflexive Until), making backward Until reduce to BX8. The dd_chain is non-constant, making the proof inapplicable.

### 2. All Three Sorry Sites Are Equally Hard (A, HIGH confidence)

The v39 assessment of "buc=easy, tc=hard, fuc=medium" was wrong:
- **restricted_buc**: Requires backward Until step transfer, which needs `phi U psi in chain(t+1) /\ phi in chain(t) -> phi U psi in chain(t)`. This is blocked by the same gap as v39.
- **restricted_tc**: The known forward_F/BX11 perpetual deferral obstruction.
- **restricted_fuc**: Depends on restricted_tc via BX10.

All three are blocked by the fundamental tension: F-resolution requires chain changes, Until coherence requires formula persistence.

### 3. The Round-Robin Architecture Is Wrong (D, HIGH confidence)

Literature analysis confirms all standard completeness proofs for Until-Since temporal logic avoid the round-robin BX11 fold:
- **Burgess 1984**: Uses quasimodel chains with defect counting
- **Xu 1988**: Uses filtration + cycle detection
- **Reynolds 2003**: Uses constructive chain with explicit defect discharge

The quasimodel infrastructure in `Construction.lean` IS the correct approach -- it's sorry-free through `hintikka_chain_exists` and implements the Goldblatt-style defect counting. The gap is bridging from Hintikka chains to Int-indexed FMCS.

### 4. Vacuous Interval Guard for Integers (B, HIGH confidence 70%)

For integer-indexed chains, restricted_fuc simplifies dramatically:
- Given `phi U psi in fam.mcs(t)`, call `bx_until_eventuality_resolution` to get `v` with `bx_le fam(t) v` and `psi in v`.
- Set `s = t+1` and use `v` as `mcs(t+1)`.
- The guard `forall r, t <= r < t+1, phi in mcs(r)` is vacuously true (no integers in (t, t+1)).
- restricted_tc reduces to restricted_fuc via BX12 (`F(phi) -> top U phi`).

**This only works for a NEW BFMCS construction** where the chain uses `bx_until_eventuality_resolution` witnesses, NOT for the existing dd_bfmcs.

### 5. Quasimodel Bridge Has Alignment Problem (C, HIGH confidence)

The quasimodel's `hintikka_chain_exists` constructs a Hintikka chain, but dd_chain uses a round-robin schedule (`rr_fwd_chain`) that may never follow the Hintikka chain's trajectory. Using quasimodel properties to prove dd_chain properties requires showing alignment -- which has NEVER been analyzed.

**Resolution**: Don't prove dd_bfmcs coherence. Build a NEW BFMCS that mirrors the quasimodel structure directly. The alignment problem disappears.

### 6. BX6 Does NOT Give Until Introduction (D, HIGH confidence)

BX6 is `(phi U (phi /\ (phi U psi))) -> (phi U psi)` -- anti-infinite-regress, NOT `phi /\ F(phi U psi) -> phi U psi`. The round 39 plan's reliance on BX6 for the step case was misguided.

### 7. Research Process Failure Pattern (C, HIGH confidence)

Systematic pattern across rounds: identify "quick win" -> estimate LOC -> implement -> fail -> repeat. The missing step: validate proof strategies by semantic counter-model BEFORE implementation. Round 39's "quick win" prediction failed because the Until introduction rule was never checked for semantic validity.

### 8. The "False Blocker" Correction Remains Unverified (C, MEDIUM confidence)

Round 39's claim that Plan v37 was "abandoned on a false blocker" gives a corrected seed consistency argument. This argument is mathematically plausible but has NEVER been tested in Lean. The oracle must also produce valid `hintikka_step` successors, not just consistent seeds. The Until-defect clause for OTHER formulas (not the target) may fail through `bx_le`.

**Resolution (D)**: Design the oracle step to include `{Until-defects of M0}` in the Lindenbaum seed. The resulting MCS includes all Until defects, satisfying the `hintikka_step` Until-defect clause by construction.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate B proposes vacuous interval guard on existing dd_bfmcs vs. Teammate C says bridge doesn't escape alignment problem.
**Resolution**: Both are right. The vacuous interval guard insight applies to a NEW construction (not dd_bfmcs). Building a new BFMCS using `bx_until_eventuality_resolution` directly avoids the alignment problem.

**Conflict 2**: Teammate D recommends defect_fwd_chain first (40%) vs. Teammate C low confidence on all approaches (20%).
**Resolution**: defect_fwd_chain has a proved base case and is genuinely under-explored. Try it as a low-cost experiment (~400 LOC) before committing to full quasimodel BFMCS (~800 LOC). Teammate C's low confidence reflects uncertainty about dd_chain approaches; defect_fwd_chain is a DIFFERENT chain construction.

**Conflict 3**: Teammate A says until_intro requires x_content/y_content (dd_chain lacks this) vs. Teammate B says until_intro might provide step transfer.
**Resolution**: Need to verify actual signature of `until_intro` in TemporalDerived.lean. If it requires X(.) membership, it won't work on dd_chain but might work on quasimodel-based chain.

### Gaps Identified

1. **until_defects_seed_consistent**: Unproved. Critical for both paths. The subset-of-MCS argument is sound informally but needs Lean formalization.
2. **Alignment between defect_fwd_chain and rr_fwd_chain**: If pursuing Path A (defect_fwd_chain), need to show defect_fwd_chain can replace rr_fwd_chain in dd_fmcs.
3. **hintikka_step Until-defect clause**: For Path B (quasimodel BFMCS), the oracle step must propagate ALL Until defects, not just the target. Solvable by seed augmentation.
4. **Backward direction (restricted_tc for P, restricted_buc for Since)**: Symmetric arguments needed for Since/P, using `bx_since_eventuality_resolution`.

### Recommendations

**Immediate (before any implementation)**:
1. Verify the signature of `until_intro` / `since_intro` in TemporalDerived.lean
2. Prove or disprove `until_defects_seed_consistent` as a standalone lemma

**Primary path: defect_fwd_chain induction (Path A)**:
- Prove `defect_fwd_chain_forward_F` by induction on `defects.length`
- Base case proved. Inductive step: after head defect resolved (singleton case), recurse on tail
- If this works, restricted_tc closes with minimal architectural change (~400 LOC)

**Fallback path: quasimodel BFMCS (Path B)**:
- Build `qm_bfmcs` bypassing dd_fmcs
- Oracle step uses `g_content(M) U {Until-defects of M}` seed
- Restricted_tc holds BY CONSTRUCTION
- Literature-aligned, correct long-term architecture (~800 LOC)

**Process improvement**:
- Before ANY implementation, validate all derived rules by semantic counter-model
- State the key mathematical lemma precisely and attempt a pencil-and-paper proof before coding

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Obstacle validation | completed | high |
| B | Alternative constructions | completed | high (70% on vacuous guard) |
| C | Critical assessment | completed | high (process failures) |
| D | Literature & strategy | completed | medium-high (55% on qm_bfmcs) |

## Dead Ends Confirmed

- Direct backward Until on dd_chain via BX derivation: DEAD (semantically invalid)
- Boneyard deterministic chain adaptation: DEAD (requires sorry axioms)
- Seed augmentation with Until formulas: DEAD (G-necessitation fails)
- FiniteDeferral/filtration approach: DEAD (needs Until Induction not in BX)
- All 21+ approaches documented in Report 17: CONFIRMED DEAD
- Any approach proving dd_bfmcs coherence for the existing rr_fwd_chain: EXTREMELY UNLIKELY

## References

- Teammate A: `specs/093_complete_bxcanonical_embedding/reports/40_teammate-a-findings.md`
- Teammate B: `specs/093_complete_bxcanonical_embedding/reports/40_teammate-b-findings.md`
- Teammate C: `specs/093_complete_bxcanonical_embedding/reports/40_teammate-c-findings.md`
- Teammate D: `specs/093_complete_bxcanonical_embedding/reports/40_teammate-d-findings.md`
