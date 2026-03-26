# Research Report: Direct Proof Strategies for temporal_backward_G

**Task**: Investigate whether Strategy A (direct proof of `temporal_backward_G` without `forward_F`) can be made to work.
**Date**: 2026-03-26
**Researcher**: Teammate A

## Executive Summary

After thorough investigation of four potential direct proof strategies for `temporal_backward_G`, I conclude with **HIGH confidence** that no direct proof exists that avoids the `forward_F` property. The fundamental obstruction is that MCS membership is determined by syntactic consistency, while the hypothesis provides semantic information about formula membership at all future times. Converting this infinite semantic condition into the syntactic assertion `G(psi) in fam.mcs t` fundamentally requires producing a witness (via contraposition through F), because the only way to derive a contradiction from the negation `F(neg psi) in fam.mcs t` is to exhibit a time `s > t` where `neg psi` would need to be in `fam.mcs s`, contradicting the hypothesis.

## Strategy Analysis

### Strategy A1: Lindenbaum/Compactness Arguments

**Approach**: Exploit that MCS inconsistency is witnessed by finite subsets.

**Attempt**:
1. If `G(psi) not in fam.mcs t`, then by MCS maximality: `neg(G(psi)) = F(neg psi) in fam.mcs t`
2. The hypothesis gives: `forall s > t, psi in fam.mcs s`
3. Consider `{F(neg psi)} union {psi}` -- is this derivably inconsistent?

**Analysis**: The formula `F(neg psi)` asserts "there exists some future time where `neg psi` holds." The formula `psi` (at time t) is compatible with `F(neg psi)` at time t -- they concern different times. The inconsistency comes from:
- `F(neg psi) in fam.mcs t` requires a **witness**: some `s > t` with `neg psi in fam.mcs s`
- The hypothesis `psi in fam.mcs s` for all `s > t` contradicts any such witness

By compactness (`SetConsistent` uses finite witnessing), the inconsistency `{F(neg psi), psi at all s > t}` cannot be derived from any finite subset without producing the specific witness time. The compactness theorem tells us inconsistency is witnessed finitely, but it does not tell us that we can avoid producing a semantic witness -- the finite derivation that witnesses inconsistency would have to mention the specific time `s`.

**Verdict**: FAILS. Compactness does not provide a syntactic escape route; it merely relocates the witness production problem.

### Strategy A2: G-Persistence (forward_G) + MCS Properties

**Approach**: Use the available `fam.forward_G` property which gives `G(psi) in fam.mcs t -> psi in fam.mcs s` for `s >= t`.

**Analysis**: This is the **forward** direction only:
```
G(psi) in MCS(t) --> psi in MCS(s) for all s >= t
```

We need the **backward** direction:
```
(forall s >= t, psi in MCS(s)) --> G(psi) in MCS(t)
```

The forward direction is a consequence of the T-axiom (`G(psi) -> psi`) and the temp_4 axiom (`G(psi) -> G(G(psi))`). The backward direction is NOT a consequence of these axioms -- it requires showing that a universal semantic property forces MCS membership.

**Key insight**: The forward direction is purely syntactic (axiom-based). The backward direction requires converting an infinitary semantic condition into a finitary syntactic assertion.

**Verdict**: FAILS. forward_G only gives the wrong direction.

### Strategy A3: Chain Construction Properties of SuccChainFMCS

**Approach**: Investigate whether the specific construction of `SuccChainFMCS` guarantees the backward property structurally.

**Chain Construction Analysis**:
From `SuccChainFMCS.lean` and `UltrafilterChain.lean`:

1. **Forward chain construction**: `fam.mcs(n+1)` is built as a Lindenbaum extension of the "successor deferral seed" containing:
   - `g_content(fam.mcs n)` = {chi | G(chi) in fam.mcs n}
   - `deferralDisjunctions(fam.mcs n)` = {chi or F(chi) | F(chi) in fam.mcs n}

2. **G_theory propagation**: If `G(psi) in fam.mcs n`, then `psi in seed(n+1)`, so `psi in fam.mcs(n+1)`.

3. **The backward question**: If `psi in fam.mcs(n+1)` for all `n+1 > t`, does this force `G(psi) in fam.mcs t`?

**Critical observation**: The Lindenbaum construction is **non-constructive** -- it extends the seed to a maximal consistent set, but the extension is via Zorn's lemma (or equivalent). There is no guarantee that `G(psi)` appears in `fam.mcs t` just because `psi` appears everywhere in the future.

**Counterexample sketch**: Consider an MCS M0 where:
- `psi not in M0` (so M0 doesn't assert psi at time 0)
- `G(psi) not in M0` (consistent with psi not in M0 by T-axiom contrapositive)
- `F(psi) in M0` (possible without contradiction if psi "eventually" holds)

Then the SuccChain construction starting from M0:
- `fam.mcs 0 = M0` with `G(psi) not in fam.mcs 0`
- The successor at time 1 contains `psi or F(psi)` (from deferral disjunctions)
- The Lindenbaum extension COULD choose `F(psi)` over `psi` at every step

This shows the chain construction does not FORCE `psi` into future MCSes -- it only forces the disjunction `psi or F(psi)`. Without additional constraints, the construction can perpetually defer.

**Verdict**: FAILS. The chain construction allows perpetual deferral of witnesses.

### Strategy A4: Algebraic/Temporal Axiom Exploitation

**Approach**: Use the temporal axioms (temp_4, mix, etc.) to build a direct proof.

**Axiom Inventory**:
- `temp_4`: `G(psi) -> G(G(psi))` (G is idempotent/transitive)
- `temp_t_future`: `G(psi) -> psi` (reflexivity under reflexive semantics)
- `temp_k_dist`: `G(psi -> chi) -> (G(psi) -> G(chi))` (K-distribution)
- `mix`: `G(G(psi) -> psi) -> (F(psi) -> psi)` (Loeb-like principle)

**Attempt using mix**: The `mix` axiom is:
```
G(G(psi) -> psi) -> (F(psi) -> psi)
```
This says: if "G(psi) implies psi" holds at all future times, then F(psi) implies psi now.

Could we use this? We have:
- Hypothesis: `psi in fam.mcs s` for all `s > t`
- Need: `G(psi) in fam.mcs t`

By contraposition with mix:
- `neg psi -> neg G(G(psi) -> psi)` (contrapositive, fails -- psi at t is not our hypothesis)

The mix axiom relates F to G in a specific way, but requires `G(G(psi) -> psi)` which we don't have.

**Attempt using temp_4**: From `G(psi) -> G(G(psi))`, we get idempotence. But this doesn't help with the backward direction.

**Attempt using induction principle**: Is there an "induction principle" for G in the axiom system? Something like:
```
(psi at t) and (forall s >= t, psi at s -> psi at s+1) -> G(psi) at t
```
This would be a temporal induction principle. **No such axiom exists in TM**. The TM axiom system does not include any form of temporal induction.

**Theoretical observation**: Temporal induction is valid semantically over well-founded ordinals, but over Int (or any dense order), there is no well-founded induction. The integers have no "next" element in a universal sense, and the density of real completions prevents induction arguments.

**Verdict**: FAILS. No combination of TM axioms yields the backward G property without witness production.

## Mathematical Arguments

### The Fundamental Asymmetry

The key mathematical insight is the **asymmetry between syntax and semantics**:

**Syntactic side (MCS membership)**:
- `G(psi) in MCS` is a finitary assertion
- It can be checked against the MCS membership predicate
- It implies (by axioms) `psi in MCS` at the same time, and via forward_G, at all future times

**Semantic side (truth at all future times)**:
- "psi holds at all future times" is an infinitary assertion
- It cannot be directly checked -- it's a universal quantification over an infinite domain
- Converting this to `G(psi) in MCS` requires showing that NOT having `G(psi)` leads to contradiction

**The contraposition bottleneck**: The ONLY known way to convert "forall s > t, P(s)" to a syntactic MCS membership is:
1. Assume the desired formula is NOT in the MCS
2. Get its negation (existential dual) IS in the MCS
3. The existential assertion provides a WITNESS
4. Use the universal hypothesis to contradict the witness

This is exactly the `temporal_backward_G` proof via `forward_F`.

### Why No Alternative Exists

Consider what a "direct" proof would need to accomplish:
1. Take the hypothesis `forall s > t, psi in fam.mcs s`
2. WITHOUT assuming `G(psi) not in fam.mcs t`
3. Directly derive `G(psi) in fam.mcs t`

This would require one of:
- A rule that universally closes membership: "if phi is in all future MCSes, then G(phi) is in this MCS"
- Such a rule is NOT part of MCS theory -- MCS closure is under DERIVATION, not under semantic quantification
- An axiom connecting universal semantic truth to syntactic membership
- No such axiom exists in TM or classical modal logic

The Lindenbaum lemma builds MCSes from consistent sets, but consistency is a FINITE property (every finite subset is non-contradictory). Universal semantic truth over an infinite domain cannot be directly converted to finite consistency statements without producing witnesses.

### Analogy to Completeness Proofs

This situation parallels the standard completeness proof structure:
- **Soundness** (syntax to semantics): Direct, compositional, no witnesses needed
- **Completeness** (semantics to syntax): Indirect, requires Lindenbaum construction, witnesses emerge from MCS maximality

The backward direction of the truth lemma is a "mini-completeness" statement within the completeness proof. It inherits the same structural requirements.

## Conclusion

**Verdict**: Strategy A (direct proof of `temporal_backward_G` without `forward_F`) **CANNOT** be made to work.

**Reasons**:
1. **Compactness doesn't help**: Finite witnessing of inconsistency still requires a witness time
2. **Forward_G is wrong direction**: Only gives membership preservation, not membership creation
3. **Chain construction allows deferral**: SuccChainFMCS can perpetually defer obligations
4. **No temporal induction in TM**: The axiom system lacks induction principles for G
5. **Fundamental syntax/semantics asymmetry**: Converting infinite semantic conditions to finite syntactic assertions requires witness production

**The mathematical obstruction is real**: The `forward_F` property (existential witness existence) is genuinely needed for the backward G lemma. This is not a Lean engineering problem -- it reflects the fundamental structure of canonical model constructions for temporal logics.

## Confidence Level

**HIGH** (95%)

**Justification**:
- Exhaustive analysis of four distinct proof strategies
- Each strategy fails for clear, principled reasons
- The obstruction reflects fundamental modal logic theory (syntax/semantics gap)
- Consistent with standard completeness proof literature (Goldblatt, Burgess, Blackburn et al.)
- The plan document (08_corrected-truth-lemma.md) independently reached the same conclusion

**Remaining uncertainty** (5%):
- Some exotic axiom combination I haven't considered
- A completely novel proof technique not in the modal logic literature
- A specific property of SuccChainFMCS that I've overlooked

Given the extensive analysis and alignment with established theory, these possibilities are unlikely.

## Implications for Implementation

Since direct proofs are not viable, the implementation must either:

1. **Prove `forward_F` for SuccChainFMCS** (Phase 3 of the plan): Investigate whether the omega dovetailing construction provides F-witnesses within the same family.

2. **Use bundle-level coherence** (Approach B): If `forward_F` cannot be proven for individual families, restructure the completeness argument to use cross-family witnesses, as explored in the "forward-only truth lemma" approach from report 17.

3. **Accept the sorry** with documentation: If neither approach works, document the mathematical obstruction precisely and leave the sorry as a known limitation.

The plan's Phase 2-3 focus on investigating omega dovetailing is the right next step.
