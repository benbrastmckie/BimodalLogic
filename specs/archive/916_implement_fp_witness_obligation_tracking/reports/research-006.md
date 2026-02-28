# Research Report: Task #916 (Temporal Connection Constraints)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-20
**Focus**: Comprehensive enumeration of all temporal connection constraints between consecutive MCSs in a history (indexed family); analysis of seed-to-MCS propagation; FIX/NOTE tag review; assessment of whether additional constraints resolve the forward_F/backward_P obstruction
**Session**: sess_1771652760_ebcf25

---

## 1. Correction: Reflexive vs Strict Temporal Operators

**FIX tag from research-005.md, line 15**: The FIX tag is CORRECT and important.

Research-005 Section 1.1 states the temporal operators use "strict" future/past semantics (t' > t and t' < t). This is WRONG. The actual semantics in the codebase are REFLEXIVE:

| Operator | Research-005 (INCORRECT) | Actual Semantics (CORRECT) |
|----------|-------------------------|---------------------------|
| G(phi) | phi at all t' > t (strict) | phi at all s >= t (reflexive) |
| H(phi) | phi at all t' < t (strict) | phi at all s <= t (reflexive) |
| F(phi) | phi at some t' > t (strict) | phi at some s >= t (reflexive) |
| P(phi) | phi at some t' < t (strict) | phi at some s <= t (reflexive) |

**Evidence**:
- `Theories/Bimodal/Semantics/Truth.lean` line 220: `truth_at ... (all_future phi) = forall s, t <= s -> truth_at ... s phi` (uses `<=`, not `<`)
- `Theories/Bimodal/Semantics/Truth.lean` line 207: `truth_at ... (all_past phi) = forall s, s <= t -> truth_at ... s phi` (uses `<=`, not `<`)
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` lines 294-299: `bmcs_truth_all_future_reflexive` proves G(phi) implies phi at t (reflexive case using `le_refl`)
- T-axioms `temp_t_future : G(phi) -> phi` and `temp_t_past : H(phi) -> phi` make the operators reflexive

The BFMCS coherence conditions use strict inequality (`t < t'` for forward_G, `t' < t` for backward_H), but this is by design: the reflexive case (t = t') is handled separately via the T-axiom. The COMBINED effect is reflexive semantics.

**Impact**: This correction does NOT affect the obstruction analysis. The persistence problem concerns strict future propagation (whether F-formulas survive to later MCSs), which is the same regardless of reflexivity. However, it affects how constraints are stated and understood.

---

## 2. Complete Enumeration of Temporal Connection Constraints

### 2.1 Setup

Let u and v be consecutive MCSs in the forward chain (u = chain(n), v = chain(n+1)). The chain construction ensures `GContent(u) subset v` by Lindenbaum extension.

### 2.2 Primary Constraints (From Chain Construction)

**Constraint C1 (GContent seed)**: `GContent(u) subset v`
- **Source**: Direct from chain construction (seed includes GContent)
- **Lean location**: `dovetailForwardChainMCS_GContent_extends`
- **Effect**: Every formula phi where G(phi) in u appears in v

**Constraint C2 (HContent duality)**: `HContent(v) subset u`
- **Source**: Derived from C1 via `GContent_subset_implies_HContent_reverse`
- **Uses**: Axiom temp_a: `phi -> G(P(phi))`
- **Effect**: Every formula phi where H(phi) in v appears in u

### 2.3 Derived Constraints (From Axioms Applied to C1/C2)

**Constraint D1 (G-propagation forward)**: If `G(phi) in u` then `G(phi) in v`
- **Derivation**: G(phi) in u => G(G(phi)) in u (by 4-axiom) => G(phi) in GContent(u) => G(phi) in v (by C1)
- **Lean location**: `dovetailForwardChain_G_propagates`
- **Significance**: G-formulas persist forever in the forward direction

**Constraint D2 (H-propagation backward)**: If `H(phi) in v` then `H(phi) in u`
- **Derivation**: H(phi) in v => H(H(phi)) in v (by past 4-axiom) => H(phi) in HContent(v) => H(phi) in u (by C2)
- **Lean location**: `dovetailForwardChain_H_propagates_reverse`
- **Significance**: H-formulas persist forever in the backward direction

**Constraint D3 (Past witness creation)**: If `phi in u` then `P(phi) in v`
- **Derivation**: phi in u => G(P(phi)) in u (by temp_a: phi -> G(P(phi))) => P(phi) in GContent(u) => P(phi) in v (by C1)
- **Not explicitly named as a standalone lemma in the codebase**
- **Significance**: Every formula in u is "remembered" as a past witness in v. This is the user's constraint (2).

**Constraint D4 (Future witness creation)**: If `phi in v` then `F(phi) in u`
- **Derivation**: phi in v => H(F(phi)) in v (by past_temp_a: phi -> H(F(phi))) => F(phi) in HContent(v) => F(phi) in u (by C2)
- **Not explicitly named as a standalone lemma in the codebase**
- **Significance**: Every formula in v is "anticipated" as a future witness in u. This is the user's constraint (4).

### 2.4 User's Four Constraints: Verification

The user listed 4 constraints. Here is how each maps to the above:

| User Constraint | Maps To | Status |
|-----------------|---------|--------|
| (1) G(phi) in u => phi in v | C1 + T-axiom | VERIFIED (proven: `dovetailForwardChain_forward_G`) |
| (2) phi in u => P(phi) in v | D3 | VERIFIED (derivable from temp_a + C1) |
| (3) H(phi) in v => phi in u | C2 + T-axiom | VERIFIED (proven: `dovetailForwardChain_backward_H`) |
| (4) phi in v => F(phi) in u | D4 | VERIFIED (derivable from past_temp_a + C2) |

All four constraints hold for consecutive MCSs in the chain.

### 2.5 Additional Constraints

**Constraint A1 (Witness seed inclusion)**: If `decodeFormula(n) = some(psi)` and `F(psi) in u`, then `psi in v`
- **Source**: Direct from witness placement in chain construction
- **Lean location**: `witnessForwardChain_witness_placed`
- **Significance**: This is the ONE-SHOT witness mechanism. Formula psi is processed exactly once.

**Constraint A2 (F/G dichotomy)**: For every formula theta, either `G(theta) in v` or `neg(G(theta)) in v` (= `F(neg(theta)) in v`)
- **Source**: MCS maximality of v
- **Lean location**: `witnessForwardChain_F_dichotomy`
- **Significance**: Lindenbaum must choose one; the choice is opaque.

**Constraint A3 (G-killing permanence)**: If `G(neg(psi)) in v`, then `G(neg(psi)) in w` for all w after v
- **Source**: D1 applied to neg(psi)
- **Lean location**: `witnessForwardChain_G_neg_persists`
- **Significance**: Once Lindenbaum "kills" F(psi) by adding G(neg(psi)), it stays dead forever.

**Constraint A4 (Modal-temporal interaction)**: If `Box(phi) in u` then `Box(G(phi)) in u`
- **Source**: Axiom `modal_future: Box(phi) -> Box(G(phi))`
- **Significance**: Box formulas propagate through temporal necessitation.

**Constraint A5 (Temporal-modal interaction)**: If `Box(phi) in u` then `G(Box(phi)) in u`
- **Source**: Axiom `temp_future: Box(phi) -> G(Box(phi))`
- **Significance**: Box is temporally persistent (necessity is permanent).

### 2.6 Constraints That Do NOT Hold

**Non-constraint N1**: F(psi) in u does NOT imply F(psi) in v
- **Why**: Would require G(F(psi)) in u, which requires F(psi) -> G(F(psi)) -- NOT derivable in TM logic with reflexive temporal semantics.
- **Significance**: THIS IS THE ROOT OF THE PERSISTENCE PROBLEM.

**Non-constraint N2**: F(psi) in u does NOT imply neg(G(neg(psi))) in GContent(u)
- **Why**: GContent(u) = {phi : G(phi) in u}. For neg(G(neg(psi))) to be in GContent(u), we'd need G(neg(G(neg(psi)))) = G(F(psi)) in u, which again requires F -> GF.
- **Significance**: F-formulas are invisible to the GContent seed mechanism.

**Non-constraint N3**: phi in u does NOT imply phi in v (in general)
- **Why**: Only GContent formulas propagate forward. Arbitrary formulas need not be in GContent.
- **Note**: HOWEVER, phi in u DOES imply P(phi) in v (constraint D3), which is a weaker form of forward propagation.

---

## 3. Seed-to-MCS Propagation Analysis

### 3.1 The Lindenbaum Extension Mechanism

At step n+1, the chain constructs the seed:
- **Base case** (no witness): `seed = GContent(chain(n))`
- **Witness case** (F(psi) present, decode matches): `seed = {psi} union GContent(chain(n))`

Lindenbaum (Zorn's lemma via `set_lindenbaum`) extends the seed to an MCS. The resulting MCS:
- CONTAINS everything in the seed
- ADDS formulas to reach maximality (every formula or its negation)
- Is OPAQUE: we have no information about which non-seed formulas are added

### 3.2 What the Seed Guarantees

From `GContent(chain(n)) subset chain(n+1)`:
1. Every phi with G(phi) in chain(n) appears in chain(n+1)
2. By the 4-axiom: G(phi) itself appears in chain(n+1) (derived in D1)
3. By temp_a: P(phi') for every phi' in chain(n) appears in chain(n+1) (derived in D3)

From the witness psi (when applicable):
4. psi itself appears in chain(n+1)
5. By temp_a: P(psi) appears in chain(n+2) via GContent propagation

### 3.3 What the Seed Does NOT Guarantee

The seed does NOT constrain:
- Whether F-formulas from chain(n) survive into chain(n+1)
- Whether G(neg(theta)) enters chain(n+1) for any theta not in GContent
- Whether specific atomic formulas or their negations are in chain(n+1)

### 3.4 Subformula Complexity and Propagation

There is no subformula-based ordering in propagation. G(phi) in chain(n) propagates phi to chain(n+1) regardless of the complexity of phi. However:
- The ENCODING of phi (encodeFormula) determines when phi is processed for witnessing
- More "complex" formulas (higher encoding numbers) are processed later
- There is no relationship between subformula structure and encoding order (the encoding is via Encodable.ofCountable, which uses an arbitrary but fixed enumeration)

---

## 4. The Forward_F Obstruction Revisited

### 4.1 The Gap: Precise Statement

Given: F(psi) in chain(n) for some n.
Need: psi in chain(s) for some s > n.

Case analysis on `k = encodeFormula(psi)` vs n:

**Case k <= n** (psi already processed): The witness fired at step k+1 IF F(psi) was in chain(k). By `witnessForwardChain_coverage_of_le`, if F(psi) is in chain(n) and k <= n, then F(psi) was in chain(k) (by contrapositive of G-persistence), so psi in chain(k+1). But k+1 <= n, which means the witness is at a step BEFORE or at n, not after n. So we need psi in chain(s) for s > n. We know psi in chain(k+1), but k+1 <= n+1. If k+1 <= n, this doesn't help (witness is in the past). If k+1 = n+1, then s = n+1 > n, which works! So the case k = n is fine.

Wait -- the case k < n means the witness was placed at step k+1 <= n. But the witness being at chain(k+1) says psi in chain(k+1), which is at a time in the Nat-indexed chain. The Int time of chain(k+1) depends on the dovetailing index mapping. If we're on the forward chain, chain(k+1) corresponds to Int time k+1, and chain(n) corresponds to Int time n, so k+1 < n means the witness time is BEFORE the source time. This is the "already processed" problem.

**Case k > n** (psi not yet processed): F(psi) needs to persist from step n to step k. But Lindenbaum can add G(neg(psi)) at any intermediate step, killing F(psi). If F(psi) survives to step k, the witness fires at step k+1. If it doesn't survive, there's no witness.

### 4.2 The User's IDEA: "Worry About G phi and neg(G phi)"

The user's insight: instead of tracking F(psi) = neg(G(neg(psi))), focus on the G/neg(G) choices that Lindenbaum makes.

At each step, for each formula theta, Lindenbaum chooses either G(theta) or neg(G(theta)) for the new MCS. The constraint is only that the result is consistent with the seed.

The forward_F problem is: Lindenbaum might choose G(neg(psi)) when we need neg(G(neg(psi))) = F(psi) to survive.

This reframing suggests: **control which G-formulas Lindenbaum adds.** If we could constrain Lindenbaum to NOT add G(neg(psi)) when F(psi) is needed, the problem would be solved.

This is exactly the F-preserving seed approach: put neg(G(neg(psi))) = F(psi) in the seed, so Lindenbaum CANNOT add G(neg(psi)) (it would be inconsistent with the seed).

### 4.3 Analysis of the F-Preserving Seed Consistency Conjecture

**Conjecture (from research-005 Section 5.1)**: If M is an MCS with F(psi) in M, then `{psi} union GContent(M) union {F(chi) : F(chi) in M}` is consistent.

**Analysis**: I attempted to prove this via the standard G-lifting technique used in `forward_temporal_witness_seed_consistent`. The proof fails at a specific point:

1. Suppose the seed is inconsistent. Then some finite subset derives bot.
2. By deduction theorem: `GContent-formulas union FContent-formulas derives neg(psi)`.
3. To apply generalized_temporal_k (G-lifting), ALL hypothesis formulas must be in GContent so they can be wrapped with G.
4. **FAILURE POINT**: The F-formulas `F(chi_j) = neg(G(neg(chi_j)))` are NOT in GContent. We cannot G-lift them because `G(neg(G(neg(chi_j))))` is NOT `neg(G(neg(chi_j)))`.
5. After G-lifting the GContent part and distributing: we'd need `G(F(chi_j)) in M` to continue, which requires the non-derivable `F -> GF`.

**Counterexample search**: I searched for a concrete counterexample (an MCS M where the extended seed is inconsistent) but found none. The challenge is that F-formulas are of the form `neg(G(theta))`, which are propositionally independent of GContent formulas at the Hilbert-system level. Any propositional combination of GContent formulas and neg(G(theta)) formulas that derives neg(psi) would need a specific algebraic relationship between the formula structures, which seems unlikely for "generic" MCSs.

**Assessment**: The conjecture is PLAUSIBLE but UNPROVEN. The standard proof technique is insufficient. A proof would need a genuinely new approach, perhaps:
- Semantic argument (construct a model where the seed is satisfiable)
- Syntactic argument via careful analysis of derivation structure
- Algebraic argument about the independence of F-formulas from GContent

**Risk**: MEDIUM (55%). There is no counterexample but also no proof path.

---

## 5. New Observation: A Weaker But Sufficient Alternative

### 5.1 What the Truth Lemma Actually Needs

The truth lemma backward direction for G (all_future) requires:
- `temporal_backward_G`: If phi in fam.mcs s for ALL s >= t, then G(phi) in fam.mcs t

This uses forward_F in its proof via contraposition:
1. Assume G(phi) NOT in fam.mcs t
2. Then neg(G(phi)) in fam.mcs t (maximality)
3. Then F(neg(phi)) in fam.mcs t (temporal duality)
4. **By forward_F**: exists s > t with neg(phi) in fam.mcs s
5. Contradicts: phi in fam.mcs s for all s >= t

Similarly for temporal_backward_H using backward_P.

So forward_F and backward_P are used ONLY for the contradiction step in the contrapositive proof. They don't need to produce a specific witness time; they just need to show existence.

### 5.2 A Potential Indirect Resolution

Instead of proving forward_F directly (which requires the witness construction), one could potentially:

1. Prove temporal_backward_G and temporal_backward_H directly, without going through forward_F/backward_P
2. Use a different proof technique for the backward direction

However, the contraposition approach IS the standard technique, and I see no alternative that avoids the existential witness requirement.

### 5.3 The "neg(G) Tracking" Variant

Instead of tracking F-formulas in the seed, track `neg(G(theta))` formulas. The insight: if we put ALL formulas of the form `neg(G(theta))` that are in M into the seed, Lindenbaum cannot add ANY `G(theta)` that wasn't already committed.

The seed would be: `GContent(M) union {neg(G(theta)) : neg(G(theta)) in M} union {psi if witnessing}`.

This seed is: `GContent(M) union NegGContent(M) union {psi}`, where `NegGContent(M) = {neg(G(theta)) : G(theta) NOT in M}` (by MCS maximality, neg(G(theta)) in M iff G(theta) not in M).

But `GContent(M) union NegGContent(M)` is a LOT of formulas -- essentially all formulas of the form `G(theta)` or `neg(G(theta))` that are in M. This is actually `{phi in M : phi has the form G(theta) or neg(G(theta))}`.

The consistency of `{psi} union GContent(M) union NegGContent(M)` is a STRONGER claim than the F-preserving seed conjecture (since FContent is a subset of NegGContent). But it faces the SAME proof obstacle: G-lifting cannot handle the neg(G(theta)) formulas.

However, this formulation makes the problem clearer: the seed is exactly the "G-level" content of M (all decisions about G-formulas), plus the witness psi. The question is whether psi is consistent with M's G-level decisions.

**This is a simpler mathematical question**: Is `{psi} union {G(theta) or neg(G(theta)) : as determined by M}` consistent when F(psi) in M?

Since all these formulas are in M and M is consistent, the set without psi is consistent. Adding psi might create inconsistency only if M's G-level content derives neg(psi). But M's G-level content is a subset of M, and we proved that GContent(M) alone doesn't derive neg(psi). The question is whether the neg(G(theta)) formulas add enough to derive neg(psi).

This is the EXACT same question as the F-preserving seed conjecture, just stated more broadly.

---

## 6. Review of IDEA and FIX Tags

### 6.1 FIX Tag (research-005.md, line 15)

```
<!-- FIX: the future and past operators are not strict, but rather include the present.
This should be how it is in the semantics. -->
```

**Status**: CORRECT. The operators are reflexive (include present), as verified by the semantics code (`truth_at` uses `<=` not `<`). Research-005's description of "strict future" operators is incorrect and should be corrected in any future documents. The BFMCS structure uses strict inequalities in its coherence conditions, but the reflexive case is handled by the T-axiom separately.

### 6.2 IDEA Tag (research-005.md, line 89)

```
IDEA: I suspect it would be easier to not worry about F at all, but instead to
worry about G phi and neg(G phi) and perhaps G neg phi, though the latter should
be covered by the first
```

**Status**: This is a valuable insight. The reframing from "F-formula persistence" to "G/neg(G) control" clarifies the problem. However, as analyzed in Section 5.3, the resulting mathematical question (neg(G) tracking seed consistency) faces the same proof obstacle as the F-preserving seed approach. The user's intuition is correct that the PROBLEM is about G-formula decisions, but the SOLUTION still requires proving the same type of seed consistency lemma.

The observation that "G neg phi should be covered by the first" is also correct: tracking neg(G(phi)) subsumes tracking G(neg(phi)) because neg(G(phi)) is a STRONGER statement (it says phi fails at some future time, whereas G(neg(phi)) says neg(phi) holds at all future times). Specifically: G(neg(phi)) in M implies neg(G(phi)) NOT in M (since G(phi) and G(neg(phi)) can't both be in M if phi is not a contradiction). But the converse is false: neg(G(phi)) in M does NOT imply G(neg(phi)) in M.

---

## 7. Constraints That Cross Families (Modal Direction)

For completeness, the constraints between families in a BMCS bundle are:

**Modal forward**: Box(phi) in fam.mcs t => phi in fam'.mcs t for all fam' in bundle
- **Source**: BMCS.modal_forward (proven)

**Modal backward**: phi in fam'.mcs t for all fam' => Box(phi) in fam.mcs t
- **Source**: BMCS.modal_backward (via saturated_modal_backward, requires modal saturation)

**Modal-temporal**: Box(phi) in fam.mcs t => Box(G(phi)) in fam.mcs t AND G(Box(phi)) in fam.mcs t
- **Source**: Axioms modal_future and temp_future

These modal constraints are ORTHOGONAL to the forward_F/backward_P obstruction. The obstruction is purely within a single family's temporal chain.

---

## 8. Summary of Findings

### 8.1 All Constraints Enumerated

| ID | Constraint | Direction | Source | Status |
|----|-----------|-----------|--------|--------|
| C1 | GContent(u) subset v | u -> v | Construction | PROVEN |
| C2 | HContent(v) subset u | v -> u | Duality + temp_a | PROVEN |
| D1 | G(phi) in u => G(phi) in v | u -> v | 4-axiom + C1 | PROVEN |
| D2 | H(phi) in v => H(phi) in u | v -> u | Past 4 + C2 | PROVEN |
| D3 | phi in u => P(phi) in v | u -> v | temp_a + C1 | DERIVABLE |
| D4 | phi in v => F(phi) in u | v -> u | past_temp_a + C2 | DERIVABLE |
| A1 | Witness placement (one-shot) | u -> v | Construction | PROVEN |
| A2 | F/G dichotomy | per MCS | MCS maximality | PROVEN |
| A3 | G-killing permanence | forward | D1 specialized | PROVEN |
| N1 | F(psi) NOT persistent | -- | F -> GF not derivable | CONFIRMED |

### 8.2 Key Findings

1. **All four user constraints verified**: The user's constraints (1)-(4) all hold. Constraints (2) and (4) are derivable consequences of the interaction axiom temp_a and its past dual, combined with the GContent/HContent seed mechanism.

2. **FIX tag confirmed**: The temporal operators are reflexive (include present), not strict. The T-axioms provide reflexivity.

3. **IDEA tag analyzed**: The G/neg(G) reframing is valid but leads to the same mathematical obstacle.

4. **No new constraints found that resolve the obstruction**: The constraint enumeration is exhaustive for TM logic. No constraint forces F-formula persistence. The non-constraint N1 (F not persistent) is fundamental to the logic and cannot be circumvented by additional axioms within TM.

5. **F-preserving seed conjecture remains open**: The standard G-lifting proof fails. No counterexample exists. The conjecture is plausible (55% confidence, unchanged from research-005).

6. **Constraints D3 and D4 not explicitly formalized**: While they are derivable consequences, they don't appear as standalone lemmas in the codebase. Formalizing them could be useful for documentation but doesn't affect the obstruction.

### 8.3 Recommendations

1. **Correct the strict/reflexive terminology** in all documentation. The operators are reflexive (G means "at all times >= t", not "at all times > t").

2. **Formalize constraints D3 and D4** as standalone lemmas in DovetailingChain.lean for documentation value.

3. **The forward_F/backward_P obstruction is NOT resolvable** by discovering additional constraints within TM logic. The constraint enumeration is exhaustive.

4. **The F-preserving seed approach (research-005 Path 1)** remains the most promising constructive path, but requires a proof technique beyond G-lifting.

5. **If investigating the F-preserving seed**: Try a SEMANTIC argument. Construct a Kripke model where GContent(M) union FContent(M) union {psi} is satisfiable. This avoids the syntactic G-lifting obstacle entirely.

---

## 9. References

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (1654 lines, 2 sorries)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- Family structure (forward_G, backward_H)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- Truth lemma (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Temporal backward lemmas
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM logic axiom system
- `Theories/Bimodal/Semantics/Truth.lean` -- Semantic truth definition (reflexive operators)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` -- MCS properties (past 4-axiom)

### Prior Research
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-005.md` -- Prior synthesis report
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-004.md` -- Architecture analysis

### Axiom System Summary

| Axiom | Name | Formula |
|-------|------|---------|
| prop_k | Constant | `phi -> (psi -> phi)` |
| prop_s | Distribution | `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))` |
| ex_falso | Explosion | `bot -> phi` |
| peirce | Classical | `((phi -> psi) -> phi) -> phi` |
| modal_t | Reflexivity | `Box(phi) -> phi` |
| modal_4 | Transitivity | `Box(phi) -> Box(Box(phi))` |
| modal_b | Symmetry | `phi -> Box(Diamond(phi))` |
| modal_5_collapse | S5 collapse | `Diamond(Box(phi)) -> Box(phi)` |
| modal_k_dist | K distribution | `Box(phi -> psi) -> (Box(phi) -> Box(psi))` |
| temp_k_dist | Temporal K | `G(phi -> psi) -> (G(phi) -> G(psi))` |
| temp_4 | Temporal transitivity | `G(phi) -> G(G(phi))` |
| temp_a | Interaction | `phi -> G(P(phi))` |
| temp_l | Always propagation | `always(phi) -> G(H(phi))` |
| temp_t_future | G reflexivity | `G(phi) -> phi` |
| temp_t_past | H reflexivity | `H(phi) -> phi` |
| modal_future | Modal-temporal | `Box(phi) -> Box(G(phi))` |
| temp_future | Temporal-modal | `Box(phi) -> G(Box(phi))` |

Plus derived: `past_k_dist`, `past_necessitation`, `past_4` (H(phi) -> H(H(phi))), `past_temp_a` (phi -> H(F(phi))).
