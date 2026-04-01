# Research Report: Task #81 — F/P Witness (Run 2: Truth Lemma Analysis)

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-04-01
**Mode**: Team Research (2 teammates)
**Session**: sess_1775002322_8d6caa
**Focus**: Does ParametricTruthLemma require same-family forward_F witnesses?

## Summary

**Answer: YES — same-family forward_F is required. The problem is genuinely hard.**

Both teammates independently confirmed that the G backward case in ParametricTruthLemma uses `forward_F` from `TemporalCoherentFamily`, requiring witnesses within the SAME family. Cross-family witnesses cannot substitute because the induction hypothesis evaluates along `to_history fam` — a different family would produce a different history and break the contraposition argument.

## The Proof Structure (F/G Case)

F(φ) is not a primitive constructor — it's `¬G(¬φ)`. So the F-case is handled through the neg and G cases of the truth lemma. The critical path is:

### G Forward (G(φ) ∈ MCS → truth at all s ≥ t)
- Uses only `fam.forward_G` (FMCS struct field)
- **No temporal coherence needed**

### G Backward (truth at all s ≥ t → G(φ) ∈ MCS) — THE CRITICAL CASE
1. Assume `G(ψ) ∉ fam.mcs t`
2. By MCS maximality: `¬G(ψ) ∈ fam.mcs t`
3. Since `F(¬ψ) = ¬G(¬(¬ψ))`, derive `F(¬ψ) ∈ fam.mcs t` (via temporal duality)
4. Apply **`forward_F`**: ∃ s ≥ t with `¬ψ ∈ fam.mcs s` — **SAME family**
5. By backward IH: `¬(truth_at ... (to_history fam) s ψ)`
6. Contradiction with the assumption that ψ is true at all s ≥ t

**Step 4 is why same-family is essential**: The IH in step 5 evaluates along `to_history fam`. A witness in `fam'` would need `to_history fam'` (a different WorldHistory), and the contradiction would not follow.

### H Cases
Exactly symmetric, using `backward_P`.

## Architecture Confirmation

### BFMCS.temporally_coherent (TemporalCoherence.lean:218)
Requires **every** `fam ∈ B.families` to independently satisfy:
- `forward_F`: F(φ) ∈ fam.mcs(t) → ∃ s ≥ t, φ ∈ fam.mcs(s)
- `backward_P`: P(φ) ∈ fam.mcs(t) → ∃ s ≤ t, φ ∈ fam.mcs(s)

No cross-family witnesses. Each family must be self-contained.

### canonical_forward_F (CanonicalFrame.lean:139)
Operates on raw MCS sets, NOT FMCS timelines. Constructs a fresh Lindenbaum witness MCS W with `ExistsTask M W` and `ψ ∈ W`. This is for the canonical frame's accessibility relation, not for placing witnesses within a specific FMCS family's timeline. **Cannot solve the problem.**

### bundle_forward_F (UltrafilterChain.lean:~3445)
The existing `BFMCS_Bundle` structure provides only bundle-level coherence — witnesses in SOME family `fam'`, not necessarily the same family. The gap is explicitly documented at UltrafilterChain.lean:3590-3592.

## Implications

### What This Rules Out
- **Weakening to bundle-level coherence**: Would require rewriting the truth lemma's G backward case. The contraposition argument fundamentally needs same-family witnesses.
- **canonical_forward_F as solution**: Operates at wrong abstraction level (raw MCS, not FMCS timelines).
- **Cross-family witness strategies**: The `to_history fam` evaluation prevents any cross-family approach.

### What Remains Viable

1. **Dovetailed SuccChain construction** (UltrafilterChain.lean:3685-3711): Fair scheduling via `Nat.unpair` to interleave F-obligation resolution within a single chain. Each family is a shifted SuccChainFMCS built with enough F-witnesses dovetailed in. This is the approach already sketched in the codebase.

2. **Zorn on partial temporal families**: Define partial order on "partial FMCS" (functions from finite subsets of ℤ to MCS with coherence on the domain). Use single-step witness theorems as the finite consistency engine. Maximal elements should be total and temporally coherent.

3. **CanonicalMCS as domain D**: The ParametricRepresentation is D-polymorphic. If CanonicalMCS can be given `AddCommGroup` + `LinearOrder` + `IsOrderedAddMonoid` structure, it could serve as D directly. The "temporal shift" on CanonicalMCS (moving along R_G chains) would provide the group operation. This bypasses ℤ-embedding entirely.

### The Specific Open Obligation
`temporal_coherent_family_exists_CanonicalMCS` referenced in ParametricRepresentation.lean is the exact function that needs to be provided. It must produce a BFMCS over some concrete D where every family independently satisfies forward_F and backward_P.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | ParametricTruthLemma F-case proof trace | completed | high |
| B | Bundle architecture and canonical_forward_F | completed | high |

## Teammate Reports
- [02_teammate-a-findings.md](02_teammate-a-findings.md) — Truth lemma proof structure analysis
- [02_teammate-b-findings.md](02_teammate-b-findings.md) — Bundle architecture analysis

## Next Steps

1. **Read the dovetailed construction sketch** at UltrafilterChain.lean:3685-3711 to assess feasibility
2. **Formalize the Zorn approach** on partial temporal families as an alternative
3. **Investigate CanonicalMCS as domain**: Check if it can carry the required algebraic structure
4. **Plan implementation**: Choose the most tractable approach and create an implementation plan
