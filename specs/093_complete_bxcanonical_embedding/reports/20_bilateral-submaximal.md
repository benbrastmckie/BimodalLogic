# Research Report: Task #93

**Task**: 93 - Close remaining BXCanonical sorries (bilateral sub-maximal proposal analysis)
**Started**: 2026-04-14T18:00:00Z
**Completed**: 2026-04-14T19:30:00Z
**Effort**: ~2 hours deep mathematical analysis
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis (TruthLemma.lean, Frame.lean, RootScopedChain.lean, Completeness.lean, Axioms.lean, MCSProperties.lean, ParametricTruthLemma.lean)
- Report 19 (team research on bilateral pairs -- assumed MCS; user clarifies otherwise)
- Report 18 (earlier research on forward_F blocker)
- Mathematical analysis of sub-maximal consistent sets in completeness proofs
**Artifacts**: - specs/093_complete_bxcanonical_embedding/reports/20_bilateral-submaximal.md
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The user's clarification is a genuinely different proposal from what Report 19 analyzed: work with sub-maximal consistent pairs (V, F) without Lindenbaum extension, producing a DETERMINISTIC chain construction.
- **The proposal faces a fundamental showstopper**: the truth lemma for implication requires negation completeness (line 271 of ParametricTruthLemma.lean), which is equivalent to maximality. Without it, the backward direction of the truth lemma for `imp` formulas cannot be proved.
- Balanced pairs with gaps (phi not in V and phi not in F) correspond to a **partial valuation** / **strong Kleene** semantics. This is genuinely different from MCS -- Report 19 was wrong that bilateral pairs are "just MCS under another name" *given the user's actual proposal*. However, a partial-valuation completeness proof would require redesigning the entire semantics, proof system, and soundness theorem.
- The determinism benefit is real: if we could avoid Lindenbaum, the forward_F problem vanishes. But avoiding Lindenbaum requires abandoning the classical truth lemma, which is load-bearing for every connective's backward direction.
- **Net assessment**: The sub-maximal bilateral approach solves forward_F but creates 5+ new equally hard problems. It is not a viable path for closing task 93.

## Context & Scope

Report 19 concluded that bilateral pairs are isomorphic to MCS. The user objects: the proposal is NOT to maximize. Instead:

1. Pairs (V, F) where V = verified formulas, F = falsified formulas
2. Balanced: phi in F iff neg(phi) in V
3. Closed under MP: if (phi -> psi) in V and phi in V then psi in V
4. Implication closure: if neg(phi) in V or psi in V then (phi -> psi) in V
5. Sub-maximal: there exist phi where phi not in V and phi not in F (gaps allowed)
6. No Lindenbaum: chain steps are deterministic (add phi directly to V' when F(phi) in V)

This research analyzes whether this genuinely different proposal can support a completeness proof.

## Findings

### 1. Report 19's Analysis Was Based on a Different Proposal

Report 19 was correct *given its assumption* that bilateral pairs would be maximally consistent. The user's clarification makes the proposal fundamentally different. A balanced pair (V, F) with the stated closure properties but WITHOUT the totality requirement (for all phi, phi in V or phi in F) is NOT an MCS. It is a proper sub-structure.

Specifically: MCS S satisfies `for all phi, phi in S or neg(phi) in S` (negation completeness). The user's balanced pair satisfies `phi in F iff neg(phi) in V` but allows gaps where `phi not in V and neg(phi) not in V` (equivalently, `phi not in V and phi not in F`). These are genuinely different objects.

### 2. The Truth Lemma Showstopper for Implication

The completeness proof's truth lemma states: `phi in w.formulas iff M,tau,t |= phi` for every formula phi. This is proved by structural induction on phi. The **implication case** is where maximality is indispensable.

**Backward direction** (truth implies membership): We must show that if `(M,tau,t |= psi implies M,tau,t |= chi)` then `(psi -> chi) in V`.

In the current codebase (ParametricTruthLemma.lean, lines 269-301), this proceeds by contradiction:
1. Assume `(psi -> chi) not in V`.
2. By `negation_complete`: `neg(psi -> chi) in V`.
3. From `neg(psi -> chi)`, derive `psi in V` and `neg(chi) in V`.
4. By IH forward: `M,tau,t |= psi`.
5. By hypothesis: `M,tau,t |= chi`.
6. By IH backward: `chi in V`.
7. Contradiction: `chi in V` and `neg(chi) in V`.

**Step 2 is the showstopper**. Without maximality, when `(psi -> chi) not in V`, we cannot conclude `neg(psi -> chi) in V`. In a sub-maximal set, we might have a gap: `(psi -> chi) not in V` AND `neg(psi -> chi) not in V`. The argument collapses.

This is not a minor technical issue. The backward implication case is used by EVERY other connective's truth lemma (since all connectives are defined in terms of implication and negation in this logic). Without it, the entire truth lemma fails.

### 3. What the Balanced Property Actually Provides

The user's balanced property gives:
- `phi in F iff neg(phi) in V` (biconditional)
- This allows gaps (phi not in V and phi not in F) -- symmetric gaps
- This forbids gluts (phi in V and phi in F) -- would give `phi in V` and `neg(phi) in V`, contradicting consistency

This is precisely a **partial bilateral valuation** in the sense of strong Kleene logic or Scott's information ordering. The pair (V, F) partitions formulas into three classes:
- **True**: phi in V (equivalently neg(phi) in F)
- **False**: phi in F (equivalently neg(phi) in V)
- **Undetermined**: phi not in V and phi not in F

For the truth lemma to work with such partial pairs, we would need a THREE-VALUED semantics:
- `M,tau,t |=+ phi` iff `phi in V` (positive truth)
- `M,tau,t |=- phi` iff `phi in F` (positive falsity)
- Neither, for undetermined formulas

The existing two-valued `truth_at` definition (Truth.lean, lines 120-131) is incompatible with this. It returns `Prop` (true or false), with no third value. A formula is either true or not true in the current semantics.

### 4. The Determinism Advantage Is Real But Insufficient

The user correctly identifies that avoiding Lindenbaum makes the chain construction deterministic:

**Current approach**: When `F(psi) in M`, construct `{psi} union g_content(M)`, verify consistency (`forward_temporal_witness_seed_consistent`), then call `set_lindenbaum` to get an MCS M' containing psi. The `.choose` in Lindenbaum is unconstrained -- it may or may not put other F-obligations directly into M'. This is the forward_F blocker.

**Proposed approach**: When `F(psi) in V`, set `V' = deductive_closure({psi} union g_content(V))` -- deterministic, no .choose. Then psi in V' by construction.

This is correct and would indeed solve the forward_F problem. BUT:
- `V'` is not an MCS (deductive closure of a consistent set is consistent but not maximal in general)
- The truth lemma for V' fails at the implication backward direction (Finding 2)
- Even the FORWARD direction has issues: `(psi -> chi) in V'` should imply `(M |= psi implies M |= chi)`, which needs IH backward for psi -- circular dependency on the broken backward direction

### 5. G and H Operators: The Partial Valuation Problem

For the G (all_future) operator with sub-maximal sets:

**Forward** (G(phi) in V implies phi in V_s for all s >= t): This works if `g_content(V) subset V_s`, which follows from the chain construction.

**Backward** (phi in V_s for all s >= t implies G(phi) in V): This is the `bx_G_backward` direction (Frame.lean, line 132). The current proof uses contradiction:
1. Assume `G(phi) not in V`.
2. By negation completeness: `neg(G(phi)) = F(neg(phi)) in V`.
3. By `bx_forward_witness`: there exists `v >= w` with `neg(phi) in v`.
4. But `phi in v` (from hypothesis), contradiction.

Again, **step 2 requires negation completeness** (maximality). Without it, `G(phi) not in V` does not give `F(neg(phi)) in V` -- there may be a gap.

### 6. Box/Diamond: Modal Witnesses Require Lindenbaum

The Box truth lemma (TruthLemma.lean, lines 151-206) uses `bx_modal_witness` in the backward direction. This function (Frame.lean, line 164) calls `set_lindenbaum` to construct modal witnesses. Without Lindenbaum, there is no mechanism to construct modal witnesses at all.

The user's proposal focuses on temporal operators but modal operators have the same Lindenbaum dependency. Avoiding Lindenbaum for the temporal chain but keeping it for modal witnesses would be inconsistent -- the modal witnesses would still be MCS while the chain points would be sub-maximal. The `bx_modal_equiv` relation (Frame.lean, line 67) is defined between BXPoints (which wrap MCS). Mixing MCS and non-MCS points would require a heterogeneous equivalence relation.

### 7. Implication Closure vs. Maximality

The user proposes: "if neg(phi) in V or psi in V then (phi -> psi) in V." This is the FORWARD direction of the implication truth lemma (if semantics says phi -> psi is true, then phi -> psi in V). But the proof needs BOTH directions.

For the BACKWARD direction (phi -> psi in V implies phi in V -> psi in V), we need: given `(phi -> psi) in V` and `phi in V`, conclude `psi in V`. This follows from MP closure -- the user includes this, so the forward direction of the MCS implication property survives.

But the backward direction of the TRUTH LEMMA (not the implication property) is the problem. We need: if `(truth(phi) implies truth(chi))` then `(phi -> chi) in V`. The user's implication closure gives: if `neg(phi) in V or chi in V` then `(phi -> chi) in V`. But the semantics may give `truth(phi) implies truth(chi)` even when `phi not in V and neg(phi) not in V` (gap on phi) -- in which case the implication closure condition does not fire, and we cannot conclude `(phi -> chi) in V`.

**Concrete counterexample**: Suppose phi is undetermined (phi not in V, neg(phi) not in V) and chi is false (chi in F, neg(chi) in V). Then:
- Semantically: In any three-valued completion, phi could be true or false. If we assign phi = false, then `phi -> chi` is true. If phi = true, then `phi -> chi` is false.
- The truth lemma cannot determine the status of `phi -> chi` because phi is undetermined.
- This is exactly the gap problem.

### 8. Could a Modified Semantics Work?

To make the sub-maximal approach viable, one would need:

1. **Three-valued semantics**: Define `truth_at_pos` (positive truth) and `truth_at_neg` (positive falsity) as mutually recursive functions on formulas. This is a complete redesign of Truth.lean.

2. **Bilateral truth lemma**: `phi in V iff M,tau,t |=+ phi` AND `phi in F iff M,tau,t |=- phi`. This requires the three-valued semantics to be sound and complete with respect to the bilateral proof system.

3. **Bilateral proof system**: The current proof system is classical (Peirce's law, Axioms.lean line 81). A bilateral system would need separate introduction/elimination rules for assertion and denial. This is a complete redesign of ProofSystem/.

4. **Bilateral soundness**: Re-prove all 37 axioms sound under the new three-valued semantics.

5. **Bilateral completeness**: Re-prove the entire completeness argument.

This is not a repair of the current approach -- it is a ground-up redesign of the entire formalization. Estimated effort: 500+ hours.

### 9. Comparison with Standard Literature

The standard completeness proofs for classical modal/tense logics (Burgess 1984, Goldblatt 1992, Blackburn-de Rijke-Venema 2001) ALL use maximally consistent sets. The reasons are fundamental:
- Classical logic with excluded middle requires the truth lemma to establish `phi in w iff M,w |= phi`.
- The "iff" requires both directions, and the backward direction (truth implies membership) needs negation completeness.
- Negation completeness IS maximality (in the presence of consistency and deductive closure).

Sub-maximal constructions appear in:
- **Intuitionistic logic**: Kripke models use prime filters (not MCS). But the truth lemma is only `phi in w implies M,w |= phi` (forward only). Completeness works because intuitionistic semantics uses forcing (monotone truth), not classical truth.
- **Many-valued logics**: Use prime filters in lattices. Truth lemma connects to multi-valued semantics, not two-valued.
- **Nelson's N3/N4**: Uses bilateral prime theories. But these are for PARACONSISTENT logics, not classical.

None of these are applicable to a classical tense logic with Peirce's law.

### 10. What Would Actually Help with forward_F

The forward_F problem is NOT caused by maximality itself. It is caused by the NONDETERMINISM of the Lindenbaum extension (`.choose` picks an arbitrary MCS extension). The fix needs to either:

(a) **Constrain the choice**: Define a canonical extension that always includes target formulas. This is Plan v18's ordered-discharge approach.

(b) **Prove the property holds regardless of choice**: Show that for ANY MCS extension of `{psi} union g_content(M)`, eventually psi appears in the chain. This is the strategy the enriched_fwd_step tries (and currently fails at).

(c) **Eliminate the need for the property**: Use the quasimodel or filtration approach to bypass forward_F entirely. The quasimodel approach (already partially implemented in the codebase) tracks defects explicitly.

(d) **Use a deterministic successor function**: Define a canonical/computable successor that always extends consistently AND resolves the target. This requires showing that the deductive closure `Cn({psi} union g_content(M))` can be extended to MCS in a way that preserves all F-obligations. This IS achievable within the current MCS framework -- it does not require sub-maximal sets.

Option (d) is the most promising and does not require abandoning maximality. The key insight: instead of calling `set_lindenbaum` (which uses Zorn/choice), construct the MCS extension using an enumeration of formulas and a deterministic priority order that resolves F-obligations before processing other formulas.

## Decisions

1. **Report 19 was partially wrong**: It was correct that balanced (V,F) pairs with TOTALITY (for all phi, phi in V or neg(phi) in V) are isomorphic to MCS. But the user's proposal explicitly avoids totality (allows gaps). Report 19 did not analyze this genuinely different proposal.

2. **The sub-maximal proposal does not work for classical completeness**: The truth lemma's backward implication direction requires negation completeness, which is maximality. This is not a codebase limitation but a mathematical necessity for classical two-valued logic.

3. **The determinism insight is valuable but misapplied**: The user correctly identifies that determinism solves forward_F. But determinism should be pursued WITHIN the MCS framework (deterministic Lindenbaum extension with priority ordering) rather than by abandoning maximality.

## Recommendations

1. **Do not pursue sub-maximal bilateral pairs for task 93**. The mathematical obstacles (truth lemma failure, semantics redesign, proof system redesign) make this approach unviable for closing the existing sorry sites.

2. **Investigate deterministic Lindenbaum within MCS**: The user's core intuition -- that removing nondeterminism fixes forward_F -- is correct. A deterministic Lindenbaum extension that processes F-obligation targets with highest priority would achieve the same goal while preserving the entire existing infrastructure. This could be formalized as:
   ```
   def priority_lindenbaum (seed : Set Formula) (priorities : List Formula) : Set Formula
   ```
   where `priorities` are processed first in the enumeration, ensuring they enter the MCS before BX11 Case 3 can displace them.

3. **Continue with Plan v18 (ordered-discharge chain)** as the primary approach, which already embodies the deterministic chain construction idea within the MCS framework.

4. **Consider the bilateral framework as a separate future project**: A proper bilateral/three-valued formalization of TM would be mathematically interesting (potentially publication-worthy) but is a 500+ hour endeavor orthogonal to task 93.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Sub-maximal approach attempted despite analysis | 100+ hours wasted, all existing infrastructure abandoned | This report documents 5+ independent mathematical obstacles |
| Priority Lindenbaum harder than expected | 20-40 hours additional work | Falls back to Plan v18 ordered-discharge |
| User disbelieves truth lemma argument | Continued investigation of dead end | The argument is mechanical: line 271 of ParametricTruthLemma.lean uses negation_complete, which IS maximality |

## Appendix

### Key Code References

| File | Lines | Relevance |
|------|-------|-----------|
| ParametricTruthLemma.lean | 269-301 | Backward implication truth lemma uses negation_complete |
| MCSProperties.lean | 174-217 | negation_complete definition and proof |
| Frame.lean | 47-68 | BXPoint wraps SetMaximalConsistent |
| Frame.lean | 164-171 | bx_forward_witness uses set_lindenbaum |
| RootScopedChain.lean | 383 | set_lindenbaum call with .choose nondeterminism |
| RootScopedChain.lean | 1269-1275 | forward_F sorry site |
| Axioms.lean | 81 | Peirce's law (classical logic) |
| Truth.lean | 120-131 | Two-valued truth_at definition |

### Mathematical Argument Summary

The following chain of dependencies shows why sub-maximal sets cannot support the completeness proof:

```
completeness theorem
  <- truth lemma (phi in w iff M,w |= phi)
    <- backward implication case (truth implies membership)
      <- negation_complete (either phi or neg(phi) in w)
        <- maximality (w cannot be properly extended while remaining consistent)
          <- Lindenbaum's lemma (Zorn's lemma / AC)
```

Removing maximality breaks the chain at the third level. Every link below it depends on the links above.

### What Sub-Maximal Sets CAN Do

For completeness:
- Forward truth lemma (membership implies truth): Works for all connectives
- Backward truth lemma for atoms: Works (atoms are put in explicitly)
- Backward truth lemma for negation: Works (via balanced property)
- Backward truth lemma for implication: FAILS (needs negation completeness)
- Backward truth lemma for G/H: FAILS (needs negation completeness for the contrapositive argument)
- Backward truth lemma for box: FAILS (needs modal witness construction via Lindenbaum)
- Backward truth lemma for Until/Since: May work if temporal witnesses are in the chain, but depends on G/H backward
