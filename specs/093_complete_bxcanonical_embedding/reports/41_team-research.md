# Research Report: Task #93 - Round 41

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1776547511_361857
**Focus**: Systematic study of Plan v40 implementation attempt; identify mathematically correct long-term solution

## Summary

After 40 rounds and a partial implementation (Plan v40), this round conducted a systematic, no-shortcuts analysis with 4 independent teammates. Three critical breakthroughs emerged:

1. **The Hintikka chain machinery is DEAD CODE**: The elaborate `hintikka_chain_exists` / `HintikkaStepOracle` / `WitnessedHintikka` infrastructure (OracleStep.lean, Construction.lean) is never called by the actual completeness proof path (`dd_countermodel` → `dd_bfmcs`). The defect_count decrease sorry in OracleStep.lean is therefore **irrelevant** to closing the live sorry sites. This eliminates Blocker 1 from the critical path.

2. **Enriched backward oracle seed solves backward Until coherence BY CONSTRUCTION**: Modifying `qm_oracle_seed_bwd` to include Until-formulas from the successor (`{φ U ψ | φ U ψ ∈ w.formulas ∧ φ U ψ ∈ Sigma}`) gives the backward step transfer for free. The enriched seed is consistent (subset of w.formulas). This eliminates Blocker 2.

3. **restricted_tc is provable for dd_bfmcs using EXISTING infrastructure**: The scheduling chain (`defect_fwd_step_choice_spec`) already provides F-persistence: `F(χ) ∈ M'` for all `χ ∈ defects`. Combined with the schedule's surjectivity, this gives eventual F-resolution without any new mathematical machinery.

**Recommended approach**: A 3-phase hybrid construction that closes all sorry sites using existing infrastructure plus one targeted modification (enriched backward seed).

## Key Findings

### 1. Dead Code Identification (Teammate C, HIGH confidence)

The actual completeness proof path is:
```
bx_completeness (Completeness.lean)
  → dd_countermodel (RootScopedChain.lean:967)
    → dd_bfmcs_restricted_tc    [SORRY at line 953]
    → dd_bfmcs_restricted_buc   [SORRY at line 958]
    → dd_bfmcs_restricted_fuc   [SORRY at line 963]
```

The `qm_bfmcs_restricted_*` theorems (lines 1866-1961) are a second construction that ALSO has sorry sites but is NOT on the active path. The `hintikka_chain_exists` machinery and `HintikkaStepOracle` (all of OracleStep.lean) are entirely disconnected from the live proof.

**Implication**: The defect_count decrease problem (Blocker 1 in all previous rounds) is a RED HERRING for closing the live sorry sites. We should focus on `dd_bfmcs_restricted_*`, not `qm_bfmcs_restricted_*`.

### 2. Backward Step Transfer is Semantically Invalid (ALL teammates, HIGH confidence)

The formula `φ ∧ F(φ U ψ) → φ U ψ` is semantically invalid on linear temporal orders.

**Counterexample** (confirmed by all teammates): φ at t=0, ¬φ at t=1, φ U ψ at t=2 (with ψ at t=2). Then F(φ U ψ) at t=0 (witnessed by t=2) and φ at t=0, but φ U ψ does NOT hold at t=0 (guard fails at t=1).

No combination of BX1-BX12 can derive this. The extensive attempts via BX5 (self-accumulation), BX6 (absorption), BX7 (linearity), BX4 (connectedness), and `until_intro` (TemporalDerived.lean) all fail for the same semantic reason.

### 3. Enriched Backward Oracle Seed (Teammates A, D; HIGH confidence)

**The solution to backward Until coherence**: Modify the backward oracle seed to include Until-formulas from the current point (which serves as the successor in the backward direction):

```
qm_oracle_seed_bwd_enriched(w, Sigma) :=
  h_content(w.formulas)
  ∪ {φ S ψ | φ S ψ ∈ w.formulas ∧ ψ ∉ w.formulas ∧ φ S ψ ∈ Sigma}   -- Since-defects
  ∪ {φ U ψ | φ U ψ ∈ w.formulas ∧ φ U ψ ∈ Sigma}                      -- Until carry-back
```

**Consistency**: All three components are subsets of `w.formulas`:
- `h_content(w) ⊆ w` by BX1' (H(χ) → χ, i.e., `temp_t_past`)
- Since-defects are in `w` by definition
- Until-formulas are in `w` by definition

Hence the seed is a subset of an MCS, therefore consistent.

**Step transfer BY CONSTRUCTION**: If `φ U ψ ∈ mcs(r+1)` and `φ U ψ ∈ Sigma`, then `φ U ψ` is in the enriched backward seed for building `mcs(r)`. After Lindenbaum extension, `φ U ψ ∈ mcs(r)`. The backward step transfer holds automatically.

### 4. F-Persistence in the Scheduling Chain (Teammate D, MEDIUM-HIGH confidence)

The `dd_fmcs` scheduling chain uses `defect_fwd_step_choice` which provides:
- `F(χ) ∈ M'` for all `χ ∈ defects` (F-persistence, from `defect_fwd_step_choice_spec` ~line 1472-1482)

This means F-obligations are preserved at EVERY chain step. Combined with:
- Schedule surjectivity (`schedule_surjective_above`): every formula is scheduled infinitely often
- At the scheduled step, the defect is resolved (psi enters the chain)

This gives `restricted_tc` for `dd_bfmcs`: F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s).

**Status**: This appears to be a "haven't gotten to it yet" sorry rather than a fundamental gap. The infrastructure exists; the remaining work is proof engineering to connect the pieces.

### 5. Enhanced Seed Prevents New Defect Introduction (Teammate B, MEDIUM-HIGH confidence)

For the oracle chain (if needed), adding negations of non-present Until-formulas to the seed:
```
enhanced_seed(w, Sigma) :=
  g_content(w)
  ∪ {Until-defects at w in Sigma}
  ∪ {¬(α U β) | α U β ∈ Sigma ∧ α U β ∉ w.formulas}
  ∪ {β | α U β ∈ Sigma ∧ α U β ∈ w.formulas ∧ β ∈ w.formulas}
```

This achieves **defect monotonicity**: `untilDefectSet(oracle_step) ⊆ untilDefectSet(w)`.

Proof: If α U β is a defect at oracle_step (α U β ∈ oracle_step, β ∉ oracle_step):
- If α U β ∉ w: ¬(α U β) is in seed, hence in oracle_step — contradiction
- If α U β ∈ w and β ∈ w: β is in seed, hence in oracle_step — contradiction
- If α U β ∈ w and β ∉ w: α U β was already a defect at w ✓

### 6. Lindenbaum Non-Determinism is the Root Cause (ALL teammates, HIGH confidence)

All 40+ rounds of research hit variations of the same obstacle: Lindenbaum extension (`Classical.choice` on Zorn's lemma) produces non-deterministic MCS extensions that cannot be controlled. Specifically:
- It can add new Until-formulas (breaking defect count arguments)
- It can drop resolution formulas (preventing defect discharge)
- It cannot be directed to resolve specific obligations

The standard literature avoids this by working with finite Hintikka sets (subsets of Sigma) rather than full MCS. The BXCanonical codebase's approach of using full BXPoints (infinite MCS) and projecting to Sigma via `sigma_signature` is novel but creates the Lindenbaum non-determinism gap.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate A says blockers are "solvable within current architecture" vs. Teammate C says "architecture fundamentally flawed."

**Resolution**: Both are partially right. The `qm_bfmcs` (oracle) architecture IS fundamentally limited by Lindenbaum non-determinism (C is right). But the `dd_bfmcs` (scheduling) architecture may already have the infrastructure to close restricted_tc (A's spirit is right — the problem IS tractable, just via a different route). The key insight (from C) is that the live sorry sites are on `dd_bfmcs`, not `qm_bfmcs`.

**Conflict 2**: Teammate B's enriched seed approach for backward Until vs. Teammate D's enriched backward oracle seed.

**Resolution**: These target different things. Teammate B enriches the FORWARD seed (gives forward persistence — wrong direction for backward Until). Teammate D enriches the BACKWARD seed (gives backward Until BY CONSTRUCTION — correct). Teammate D's approach is the viable one.

**Conflict 3**: Whether defect_count decrease needs to be solved.

**Resolution**: NO — for the live sorry sites. The defect_count decrease in OracleStep.lean is for the Hintikka chain machinery, which is dead code on the active completeness path. For `dd_bfmcs`, the F-persistence mechanism in the scheduling chain provides eventual resolution without defect_count arguments.

### Gaps Remaining

1. **F-persistence proof engineering**: The `defect_fwd_step_choice_spec` provides F-persistence informally, but the formal proof connecting it to `dd_bfmcs_restricted_tc` needs to be written. This involves tracing through the shifted family construction.

2. **Enriched backward seed integration**: The `qm_oracle_seed_bwd` needs to be modified to include Until-formulas. This affects `qm_bwd_chain` and requires re-verifying h_content backward propagation and box stability.

3. **restricted_fuc depends on restricted_tc**: Forward Until coherence requires finding a witness (via restricted_tc/BX10), then proving the guard holds at intermediate points (via BX9 Until elimination + oracle chain propagation).

4. **Two BFMCS constructions**: There are two parallel constructions (`dd_bfmcs` and `qm_bfmcs`) with overlapping sorry sites. A decision is needed: work with `dd_bfmcs` (active path) or rewire `dd_countermodel` to use `qm_bfmcs`.

### Recommendations

**Phase 1: Close restricted_tc for dd_bfmcs** (HIGHEST priority)
- Use the scheduling chain's F-persistence from `defect_fwd_step_choice_spec`
- The infrastructure exists; this is proof engineering
- Estimated: 3-5 hours of careful Lean work
- If this FAILS: investigate whether `dd_fmcs` actually has F-persistence (verify the claim from Teammate D)

**Phase 2: Implement enriched backward oracle seed** (HIGH priority)
- Modify `qm_oracle_seed_bwd` to include `{φ U ψ | φ U ψ ∈ w.formulas ∧ φ U ψ ∈ Sigma}`
- Prove enriched seed consistency (trivial: subset of w.formulas)
- Prove backward Until step transfer from the construction
- Wire through to close `dd_bfmcs_restricted_buc` (or rewire dd_bfmcs to use the enriched backward chain)
- Estimated: 4-6 hours

**Phase 3: Close restricted_fuc** (HIGH priority, depends on Phase 1)
- Given restricted_tc: F(ψ) → eventual ψ witness
- Guard argument: oracle chain Until-propagation + BX9 gives φ at intermediate points
- Estimated: 2-3 hours

**Phase 4: Cleanup** (LOW priority)
- Remove or mark qm_bfmcs_restricted_* as non-critical
- Document that OracleStep.lean sorry sites are off the active path
- Consider whether to close them for mathematical completeness

**Total estimated effort**: 9-14 hours across 3-4 implementation phases.

### Key Decision Required

Before implementation, verify:
1. Does `dd_countermodel` actually use `dd_bfmcs`? (Teammate C says yes, but trace the full path)
2. Does `dd_bfmcs` use the scheduling chain (`fwd_chain_of_sigma`) or the oracle chain (`qm_fwd_chain`)? These are different constructions with different properties.
3. If dd_bfmcs uses the scheduling chain, does `defect_fwd_step_choice_spec` actually provide F-persistence for all F-obligations, or only for the scheduled formula?

These questions can be answered by reading ~100 lines of code. They determine whether Phase 1 is feasible.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Discovery |
|----------|-------|--------|------------|---------------|
| A | Primary blocker analysis | completed | high (85%) | Targeted defect-discharge oracle; enriched backward seed (H(φ U ψ) variant) |
| B | Alternative architectures | completed | medium-high | Enhanced seed v2 achieves defect monotonicity; pigeonhole strategy |
| C | Critical assessment | completed | high | Hintikka chain is DEAD CODE; Lindenbaum non-determinism is root cause |
| D | Literature-aligned design | completed | high | F-persistence in scheduling chain; enriched backward oracle seed (Until carry-back) |

## Dead Ends Confirmed (Cumulative)

- All 21+ approaches from Report 17: CONFIRMED DEAD
- Direct backward step transfer `φ ∧ F(φ U ψ) → φ U ψ`: SEMANTICALLY INVALID
- BX4-based backward reasoning `P(φ U ψ) ∧ φ → φ U ψ`: SEMANTICALLY INVALID
- BX7 linearity for backward Until: DOES NOT CLOSE THE GAP
- BX5+BX6 self-accumulation/absorption for backward: OPERATES ON SAME MCS, NOT ACROSS STEPS
- Forward seed enrichment for backward Until: WRONG DIRECTION
- Defect count decrease for general oracle: BLOCKED BY LINDENBAUM NON-DETERMINISM
- Any approach proving qm_bfmcs coherence via defect_count: IRRELEVANT (dead code on active path)

## References

- Teammate A: `specs/093_complete_bxcanonical_embedding/reports/41_teammate-a-findings.md`
- Teammate B: `specs/093_complete_bxcanonical_embedding/reports/41_teammate-b-findings.md`
- Teammate C: `specs/093_complete_bxcanonical_embedding/reports/41_teammate-c-findings.md`
- Teammate D: `specs/093_complete_bxcanonical_embedding/reports/41_teammate-d-findings.md`
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes No. 7.
- Burgess, J.P. (1984). Basic tense logic. *Handbook of Philosophical Logic*, Vol. II.
