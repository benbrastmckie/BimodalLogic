# Research Report: Task #93 — Close BXCanonical Embedding (Round 9)

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776111737_2e444d

## Summary

Fourth team research round on the BXCanonical embedding blockers. After 8 prior rounds and a failed implementation attempt, all 4 teammates converge on a key conclusion: **the scheduling chain architecture cannot be patched to prove forward_F or backward Until step transfer**. Three alternative architectures were identified, with a novel FMP Bridge approach emerging as the most promising. Critical new findings include: (1) an architectural blind spot where restricted_tc unnecessarily delegates to unrestricted forward_F, (2) a concrete counterexample definitively showing untilCarry in the resolving seed IS inconsistent in some models, and (3) the FMP/Decidability path already provides sorry-free completeness that may bridge to full semantic completeness with 200-400 lines.

## Key Findings

### Primary Approach Analysis (from Teammate A)

**Path A (temporal K + untilCarry consistency) is DEFINITIVELY REFUTED.**

The temporal K argument does NOT extend to untilCarry because `(phi_j U psi_j) in M` does NOT imply `G(phi_j U psi_j) in M`. The chain breaks at step 4 of the temporal K unwrapping.

**Concrete counterexample** for resolving seed inconsistency with untilCarry:

Let M be a BX-MCS containing:
- `F(psi) in M` (triggers the resolving branch)
- `G(neg(alpha)) in M` (gives `neg(alpha) in g_content(M)`)
- `(alpha U neg(psi)) in M` with `(alpha U neg(psi)) in subformulaClosure(root)`

Then the seed `{psi} union g_content(M) union untilCarry(M, root)` contains `{psi, neg(alpha), (alpha U neg(psi))}`. By BX9: `(alpha U neg(psi)) -> alpha v neg(psi)`. Combined with `neg(alpha)`, we get `neg(psi)`. Combined with `psi`, we get `bot`.

**This M is consistent**: G(neg(alpha)) forces alpha=false everywhere. (alpha U neg(psi)) holds because neg(psi) holds NOW (s=t, guard vacuously satisfied). F(psi) is compatible (psi at some future time). BX10 gives F(neg(psi)) from the Until, compatible with everything.

**Confidence**: HIGH. This counterexample is verified and definitive.

### Alternative Approaches Analysis (from Teammate B)

- **Path B (quasimodel chain replacement)**: Infeasible under 300 lines. Report 08 explored 5 variants; all collapse back to forward_F blocker except full Burgess 1984 at 800-1200 lines.
- **Path C (Lindenbaum extension analysis)**: NOT viable. Zorn's lemma is non-deterministic; "could include F(psi)" is not "must include F(psi)".
- **Novel idea: `set_lindenbaum_preserving`**: A custom Lindenbaum that biases toward including a specified finite set. Mathematically sound in principle, ~150-250 lines new infrastructure, but untested.
- **Key precision**: Both `F(chi)` and `G(neg(chi))` are individually consistent with the resolving seed `{psi} union g_content(M)`, but mutually exclusive. Lindenbaum picks one non-deterministically.

### Critical Analysis (from Teammate C)

**Three critical blind spots identified:**

1. **Architectural blind spot**: `bx_bfmcs_restricted_tc` (line 603) DIRECTLY CALLS `bx_fmcs_forward_F` (line 497, unrestricted sorry), throwing away the `deferralClosure(root)` restriction. The restricted version should be re-proved directly exploiting the restriction.

2. **Counterexample nuance**: C attempted a counterexample `(neg(psi) U chi)` with `G(neg(chi))` — but BX10 gives `F(chi)` from the Until, which contradicts `G(neg(chi))`. So THAT specific counterexample fails. However, A's counterexample uses different formula structure `(alpha U neg(psi))` where BX10 gives `F(neg(psi))`, not conflicting with `G(neg(alpha))`. A's counterexample survives.

3. **DeterministicChain in Boneyard**: Reduces the problem from 3 sorry sites to 1 (just forward_F) since it already has sorry-free backward Until. Deserves investigation.

**Revised probability**: C estimates untilCarry consistency at 55-60% (up from 40% in Handoff 08), but this is pre-counterexample. Post A's counterexample, the probability drops to ~0% — the seed IS inconsistent in some models.

### Strategic Analysis (from Teammate D)

**Critical discovery: The FMP/Decidability path is entirely sorry-free** (0 sorries across all files) and proves:

```lean
theorem fmp_completeness (phi : Formula) :
    (forall (S : ClosureMCSBundle phi), phi in S.carrier) ->
    Nonempty (DerivationTree [] phi)
```

**Three alternative architectures ranked**:

| Architecture | Effort | Risk | Description |
|-------------|--------|------|-------------|
| B: FMP Bridge | 200-400 lines | 20-30% | Bridge sorry-free FMP completeness to full semantic completeness |
| C: Quasimodel | 500-800 lines | 15-25% | Full Burgess 1984 chain replacement |
| A: Root-param chain | 300-500 lines | 40-60% | Modify scheduling chain with untilCarry (REFUTED by counterexample) |

**Reynolds' enriched closure insight**: Reynolds 1996/2003 solves the `(top U psi)` closure gap by defining an enriched closure including `(top U psi)` for each `F(psi)`. The codebase already has `EnrichedClosure.lean` (158 lines) that may serve this purpose. If applicable, BX12 reduction eliminates forward_F as an independent obligation.

## Synthesis

### Conflicts Resolved

**Conflict 1: untilCarry consistency probability**
- Teammate A: definitively inconsistent (concrete counterexample)
- Teammate C: 55-60% provable (counterexample attempts fail)
- **Resolution**: A's counterexample uses `(alpha U neg(psi))` with `G(neg(alpha))`, which survives C's BX10 analysis because BX10 gives `F(neg(psi))` (not `F(alpha)`), which doesn't conflict with `G(neg(alpha))`. C's BX10 argument applies to a DIFFERENT formula class. **Verdict: A is correct; the seed CAN be inconsistent. Path A is DEAD.**

**Conflict 2: Best path forward**
- A/B: Quasimodel replacement (Path B/C)
- C: Try untilCarry with better arguments + DeterministicChain
- D: FMP Bridge (Architecture B)
- **Resolution**: A's definitive counterexample eliminates the untilCarry approach. Between quasimodel and FMP Bridge, the FMP Bridge is lower effort and lower risk IF the truth preservation gap is narrow. **Verdict: FMP Bridge is primary recommendation; quasimodel is fallback.**

### Gaps Identified

1. **FMP Bridge viability**: Nobody has verified whether `TruthPreservation.lean` bridges closure MCS membership to full semantic truth. This is the critical unknown for Architecture B.

2. **EnrichedClosure.lean scope**: Does it include `(top U psi)` for `F(psi)` targets? If yes, it solves the BX12 closure gap for Architecture C. Nobody verified this.

3. **DeterministicChain compilation status**: C notes it may reduce the problem to 1 sorry, but nobody checked if it compiles with current dependencies.

4. **Architectural refactoring**: restricted_tc delegates to unrestricted forward_F unnecessarily. This should be fixed regardless of which architecture is pursued.

### Recommendations

**Tier 1 — Investigate immediately (before committing to an architecture):**

1. **Examine the FMP Bridge gap** (~2 hours): Read `Decidability/TruthPreservation.lean` and `Decidability/Completeness.lean` to determine if `valid phi -> forall S, phi in S.carrier` is provable. If yes, Architecture B closes completeness in ~200 lines.

2. **Check EnrichedClosure.lean** (~1 hour): Verify if it includes `(top U psi)` for `F(psi)` targets. If yes, the BX12 reduction is viable and eliminates forward_F for Architecture C.

3. **Refactor restricted_tc** (~2 hours): Rewrite `bx_bfmcs_restricted_tc` to NOT delegate to unrestricted `bx_fmcs_forward_F`. This is needed regardless and may reveal new proof opportunities.

**Tier 2 — Execute (after Tier 1 findings):**

4. **If FMP Bridge viable**: Implement Architecture B (200-400 lines, 8-12 hours)
5. **If FMP Bridge fails but EnrichedClosure works**: Implement Architecture C with enriched closure (500-800 lines, 15-25 hours)
6. **If both fail**: Full quasimodel construction (Burgess 1984) as final fallback

**Architecture A (root-parameterized chain with untilCarry) is ELIMINATED** based on A's definitive counterexample.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach (Path A) | completed | HIGH | Definitive counterexample killing untilCarry in resolving seed |
| B | Alternative approaches | completed | HIGH | Confirmed Path B/C infeasibility under 300 lines; novel set_lindenbaum_preserving idea |
| C | Critic | completed | MEDIUM | Architectural blind spot (restricted_tc delegation); DeterministicChain suggestion |
| D | Strategic/Horizons | completed | MEDIUM-HIGH | FMP Bridge architecture; Reynolds enriched closure insight; sorry-free Decidability discovery |

## References

- Burgess 1984, "Basic Tense Logic" — quasimodel defect discharge
- Reynolds 1996/2003 — F-to-Until reduction via enriched closure
- Xu 1988 — BX axiom completeness over linear orders
- Verbrugge 2007 — completeness by construction philosophy
- Report 08 (quasimodel approach) — 10 construction approaches analyzed
- Handoff 08 (analysis) — two irreducible blockers documented
- Report 07 — forward_F deep analysis, enriched seed consistency gap
