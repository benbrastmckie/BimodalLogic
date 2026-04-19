# Research Report: Task #93 — Round 46

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1776640395_183145

## Summary

All four teammates confirm the "irreducible Lindenbaum opacity" diagnosis is correct for the current chain architecture (`dd_chain` via iterated `preserving_fwd_step`/`bwd_pred`). However, three critical corrections emerge: (1) the obstruction is architecture-specific, not mathematically irreducible — standard completeness proofs (Burgess/Xu, Goldblatt, GHR) use different architectures that avoid it; (2) the claimed dependency chain (`fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc`) is incorrect — the three restricted coherence theorems are independent at the type level; (3) the backward chain has received almost zero attention despite being responsible for 2 of the 5 sorry sites.

The team converges on recommending a **fundamental architecture change** rather than further attempts within the current framework. The two most promising directions are: (A) the **IRR (irreflexivity) rule** from GHR 1994, an admissible rule providing temporal induction without changing the logic (70% confidence, 200-400 LOC), and (B) a **Goldblatt-style restructure** using the full canonical frame instead of a single Int-indexed chain (45-55% confidence, 800-1200 LOC). A quasimodel chain concatenation approach using existing sorry-free infrastructure is also identified as unexplored.

## Key Findings

### 1. Current Architecture Is Definitively Blocked (HIGH confidence, 90%)

All 5 blocking conclusions from the Plan v44 Path B evaluation are confirmed correct by tracing through actual Lean code:

- **Sorry #1** (`fwd_chain_forward_F`): The BX11 fold in `resolving_enriched_fwd_exists` resolves an opaque witness `w`. Active defect count is constant (resolved defects immediately regain F-obligations via `phi_imp_F_phi`). No pigeonhole argument works.
- **Sorry #2-3** (forward/backward `restricted_tc`): The backward chain lacks symmetric infrastructure. No `preserving_bwd_step` exists.
- **Sorry #4-5** (`restricted_buc`/`restricted_fuc`): Genuine axiom gap — BX1-BX12 lack an Until unfolding axiom (`phi AND F(phi U psi) -> phi U psi`).

### 2. The "Irreducible Core" Claim Is Overstated (MEDIUM confidence, 75%)

The Lindenbaum opacity obstruction is real for the current architecture, but the conclusion that it blocks ALL approaches is wrong. Standard completeness proofs for Since/Until tense logics use fundamentally different architectures:

- **Burgess/Xu (1982/1988)**: Prove truth lemma SIMULTANEOUSLY with model construction via formula-complexity induction
- **Goldblatt (1992)**: Use the FULL canonical frame (all MCSs as worlds), not a single chain
- **GHR (1994)**: Use priority-based step-by-step construction with IRR rule

None of these build a fixed Int-indexed chain and then prove coherence. The current approach is novel and the 36 dead ends suggest it is fundamentally flawed.

### 3. Dependency Chain Claim Is Incorrect (HIGH confidence, 95%)

The ROAD_MAP states `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc`. In the code, `restricted_tc`, `restricted_buc`, and `restricted_fuc` are three independent arguments to `dd_countermodel`:

```lean
exact fully_restricted_parametric_representation_from_neg_membership
    (dd_bfmcs M h_mcs sigma_list) phi
    (dd_bfmcs_restricted_tc ...)   -- independent argument 1
    (dd_bfmcs_restricted_buc ...)  -- independent argument 2
    (dd_bfmcs_restricted_fuc ...)  -- independent argument 3
```

This means each could in principle be closed with a different strategy or even a different chain construction.

### 4. Massive Unused Sorry-Free Infrastructure (HIGH confidence, 95%)

Over 2,000 lines of sorry-free infrastructure have been built for this problem but are NOT used in the chain construction:

| Infrastructure | Location | Status | Used? |
|---------------|----------|--------|-------|
| `bx_forward_witness` | Frame.lean:164 | Sorry-free | No (only truth lemma) |
| `bx_backward_witness` | Frame.lean:176 | Sorry-free | No (only truth lemma) |
| Quasimodel chain construction | Construction.lean | Sorry-free (887 lines) | No |
| Hintikka defect-discharge | Construction.lean | Sorry-free | No |
| `hintikka_step_for_sigma_sig` | OracleStep.lean:188 | Sorry-free | No |
| `backward_until_from_step` | UntilSinceCoherence.lean:111 | Sorry-free | No (needs step hypothesis) |
| Sigma-restricted ordering | SigmaOrdering.lean | Sorry-free | No |

### 5. Backward Chain Is a Blind Spot (HIGH confidence, 90%)

The backward chain (`bwd_chain_of_sigma`) uses bare `bwd_pred` with round-robin targets. It has NO defect-discharge, NO P-preservation, NO enriched seed. All 36 dead ends focus exclusively on the forward chain. Sorry sites #2-3 (backward F/P resolution) have been assumed symmetric but never independently investigated.

## Synthesis

### Conflicts Resolved

**Conflict 1: Which alternative approach is best?**

| Approach | Teammate | Confidence | Effort | Risk |
|----------|----------|------------|--------|------|
| IRR rule (admissible) | B (primary) | 70% | 200-400 LOC | Soundness under reflexive semantics unverified |
| Goldblatt full canonical frame | D (primary), C (gap 1) | 45-55% | 800-1500 LOC | Major rewrite; new Lean formalization obstacles possible |
| Quasimodel chain concatenation | C (gap 3) | 45-55% | 500-800 LOC | Periodic extension to Int unexplored |
| Semantic truth lemma refactor | A (priority 1), B (direction 2) | 40-60% | 800-1200 LOC | Restructuring parametric truth lemma |
| Formula-complexity induction | B (direction 4) | 35-50% | 600-1000 LOC | May be equivalent to Goldblatt |
| Deterministic chain hybrid | B (direction 1) | 5% | N/A | Dead: `bot U alpha = alpha` under reflexive semantics |

**Resolution**: The IRR rule is the lowest-cost, highest-confidence approach. If it works, it closes the gap with minimal disruption. If it fails (soundness issue under reflexive semantics), the Goldblatt restructure or quasimodel concatenation are the fallbacks. The deterministic chain hybrid is definitively dead.

**Recommended investigation order**: IRR rule → quasimodel chain concatenation → Goldblatt restructure

**Conflict 2: Is the Until axiom gap real?**

- Teammate A (90% confidence): BX1-BX12 lack Until unfolding; gap is real
- Teammate B (70% confidence for IRR): The IRR rule provides temporal induction without adding a new axiom, because it is admissible (does not change the theorem set)

**Resolution**: Both are correct. The gap in the AXIOM SYSTEM is real — there is no Until step-transfer derivable from BX1-BX12 alone. But the IRR RULE (which is admissible, not an axiom) provides the missing induction principle without changing the logic. These are compatible: the rule is needed precisely because the axioms alone are insufficient.

**Conflict 3: Continue current architecture or restructure?**

- All teammates agree: 5% confidence that the current `dd_chain` architecture can close the sorries
- Teammates A, C, D: recommend restructure
- Teammate B: recommends IRR rule first (cheaper), restructure as fallback

**Resolution**: Try IRR rule first (minimal cost). If it fails, restructure. The IRR rule is the only approach that could close the sorries WITHOUT major architectural changes.

### Gaps Identified

1. **IRR rule soundness under reflexive semantics**: Most literature covers strict temporal operators. Under reflexive semantics, `G(p) -> p` (BX1) interacts with the fresh atom in IRR. This needs verification before committing.

2. **Quasimodel chain periodic extension**: The sorry-free quasimodel produces finite BXPoint chains resolving all Until-defects. Since sigma-signatures are finite (bounded by 2^|Sigma|), the chain must eventually cycle. A periodic extension would give an Int-indexed chain satisfying coherence. This has NEVER been tried.

3. **`self_resolving_fwd_step` as building block**: This (line 1594) resolves a specific target AND preserves its F-obligation AND maintains g_content. Cannot replace `preserving_fwd_step` alone, but could be part of a hybrid chain architecture.

4. **Backward chain infrastructure parity**: Building `preserving_bwd_step` (symmetric to `preserving_fwd_step`) could independently address sorry sites #2-3.

5. **Whether `phi AND (top U (phi U psi)) -> phi U psi` is derivable from BX8-BX12**: BX12 bridge `F(alpha) -> top U alpha` combined with BX11 linearity might allow derivation. Worth focused investigation.

### ROAD_MAP.md Corrections Needed

1. **Dependency chain**: Change from `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` to note these are independent at the type level
2. **Dead end #25 reassessment**: The BXPoint-to-Int bridging gap is overstated; finite quasimodel chains CAN be embedded into Int
3. **Dead end #26 reassessment**: The circularity claim may be based on earlier code state; the restricted truth lemma is now sorry-free
4. **Current strategy**: Should recommend IRR investigation, then restructure, not continued chain-fixing

## Recommendations

### Priority 1: Investigate IRR Rule Viability (1-2 days)

1. Verify IRR rule soundness under reflexive semantics (most critical unknown)
2. If sound: add `irr_rule` constructor to `DerivationTree` (~10 lines)
3. Prove soundness (~50-100 lines)
4. Use IRR to close Until step-transfer → closes sorry #4, #5
5. Use IRR temporal induction to close F-eventuality → closes sorry #1
6. Sorry #2-3 would follow from #1 with symmetric backward infrastructure

### Priority 2: Quasimodel Chain Concatenation (if IRR fails, 1 week)

1. Take the sorry-free finite quasimodel chains from Construction.lean
2. Embed into Int by sigma-signature cycling (periodic extension)
3. Prove restricted coherence on the periodic chain
4. Wire into `dd_bfmcs` replacing current `fwd_chain_of_sigma`/`bwd_chain_of_sigma`

### Priority 3: Goldblatt Restructure (if both fail, 2-4 weeks)

1. Replace BFMCS-based canonical model with full canonical frame approach
2. Use all BXPoints as worlds with bx_le ordering
3. Prove truth lemma by formula-complexity induction with on-demand witness construction
4. Major rewrite but aligns with proven mathematical technique

### Fallback: Accept Sorries

If all approaches fail within a reasonable timeframe, mark task 93 as [BLOCKED] and proceed with other roadmap items. The 4,318 lines of sorry-free infrastructure remain valuable. Tasks 104, 105 can proceed immediately regardless.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary evaluation audit | completed | high (90%) | Confirmed all 5 blocking conclusions; identified `self_resolving_fwd_step` as overlooked building block |
| B | Alternative approaches | completed | high | IRR rule as primary recommendation (70%); deterministic hybrid dead (5%); semantic approach viable (45%) |
| C | Critic | completed | high | Dependency chain correction; backward chain blind spot; unused infrastructure inventory; dead end reassessments |
| D | Horizons | completed | high | Literature survey; codebase audit (67% sorry-free); strategic options analysis; Goldblatt restructure recommendation |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I: since and until"
- Xu, M. (1988). "On some U,S-tense logics"
- Goldblatt, R. (1992). "Logics of Time and Computation"
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects", Vol. 1
- Reynolds, M. (2003). "An Introduction to Temporal Logic"
