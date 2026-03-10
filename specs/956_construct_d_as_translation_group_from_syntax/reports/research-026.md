# Research Report: Reflexive G/H -- Consequence Analysis

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773116400_8307
**Run**: 026
**Effort**: Medium
**Dependencies**: research-024 (seriality analysis), research-025 (G-closed MCS analysis)
**Sources/Inputs**: Codebase (Truth.lean, Soundness.lean, Axioms.lean, Validity.lean, Formula.lean), research-024, Goldblatt 1992, Prior 1967, Blackburn/de Rijke/Venema 2001
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- Making G/H reflexive (using `<=` instead of `<`) would **solve the single-MCS history problem** for the truth lemma. With reflexive semantics, `G(phi)` at `(m, q)` means `phi` at all `(m', q')` with `(m, q) <= (m', q')`, which includes `(m, q)` itself. Since truth depends only on the MCS component, constant-MCS histories `tau(t) = (m, t)` work correctly.
- However, making G/H reflexive causes **severe collateral damage** across the codebase: the density axiom becomes trivially valid (losing its content), temp_4 becomes redundant, temp_a changes meaning, the seriality axioms become unnecessary, and approximately 6-8 soundness proofs need revision.
- The reflexive switch would also **contradict the deliberate architectural decision** documented in Truth.lean and analyzed in research-024, which chose irreflexive semantics specifically to support the density proof architecture.
- **Recommendation**: Do NOT switch to reflexive G/H. The product domain approach (implementation-007) already solves the singleton problem without changing the semantics. The remaining truth lemma blocker for G/H is a **history construction problem**, not a semantics problem, and should be solved by constructing multi-MCS histories within the product domain.

## Context & Scope

### The Question

The truth lemma (Phase 6) for the product domain `TemporalDomain := RestrictedQuotient x Q` is blocked on the G/H cases. With simple single-MCS histories `tau(t) = (m, t)`:

- `G(phi)` true at `(m, q)` means `phi` true at ALL `(m', q')` with `(m, q) < (m', q')` (irreflexive)
- This includes points like `(m, q+1)` where truth depends on `m`, AND points `(m', q')` where `m' != m` in the quotient ordering
- The backward direction (truth implies MCS membership) requires: if `phi` holds at all strictly future points, then `G(phi) in m`
- The problem: "all strictly future points" includes points with DIFFERENT MCS components, but MCS membership of `G(phi)` relates only to the current MCS `m`

Would making G/H reflexive (using `<=`) solve this?

### Current Semantics (Irreflexive)

```lean
-- Truth.lean, lines 118-119
| Formula.all_past phi => forall (s : D), s < t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t < s -> truth_at M Omega tau s phi
```

### Proposed Semantics (Reflexive)

```
| Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

## Findings

### Finding 1: Reflexive Semantics Does Solve the Single-MCS History Problem

With reflexive `G(phi)` meaning "phi at all s >= t":

**Forward direction** (`G(phi) in m => truth of G(phi) at (m, q)`):
If `G(phi) in m`, we need `phi` true at all `(m', q')` with `(m, q) <= (m', q')`. In the product domain with single-MCS histories `tau(t) = (m, t)`, all future points have the same MCS `m`. Since `G(phi) in m` and `m` is G-closed (or by the FMCS coherence conditions), `phi in m`. Then truth at `(m, q')` for any `q' >= q` is just `phi in m`, which holds.

**Backward direction** (`truth of G(phi) at (m, q) => G(phi) in m`):
If `phi` true at all `(m', q')` with `(m, q) <= (m', q')`, in particular `phi` true at `(m, q)` itself (taking `q' = q`). But this gives `phi in m`, not `G(phi) in m`. We would still need a deduction from "phi holds at all future times" to "G(phi) in m".

**Wait -- the reflexive case includes the present time, which gives `phi in m` for free.** But we still need `G(phi) in m`, not just `phi in m`. The backward direction argument is the same for both reflexive and irreflexive: we need to show that if `phi` holds at all (reflexive/strictly) future points, then `G(phi)` is in the MCS. This requires the same contraposition argument using the F-witness / canonical successor structure.

**Refined analysis**: The reflexive semantics does NOT directly solve the backward direction of the truth lemma for G/H. The core issue remains: the backward direction requires showing that if a formula holds at all future points (reflexive or strict), then the corresponding "all future" formula is in the MCS. This requires constructing witnesses (F-witnesses for the contrapositive argument) that are at points with DIFFERENT MCS components.

**However**, the reflexive semantics does make the truth lemma **simpler** in one respect: the T-axiom `G(phi) -> phi` becomes valid, which means the FMCS coherence conditions can use `<=` instead of `<`, and the forward direction for the "current time" case is automatic.

### Finding 2: Density Axiom Becomes Trivially Valid (Loss of Content)

The density axiom is: `F(phi) -> F(F(phi))`.

With reflexive semantics, `F(phi)` means `exists s >= t, phi(s)`. Then `F(F(phi))` means `exists s >= t, exists u >= s, phi(u)`. Given a witness `s >= t` for `F(phi)`, take the same `s` as witness for the outer `F`, and `s` itself as witness for the inner `F`. Done.

**The density axiom becomes valid on ALL frames, not just dense ones.** It conveys no frame condition whatsoever. This means:

- The current `density_valid` proof (Soundness.lean line 271) which crucially uses `DenselyOrdered.dense` would need to be replaced with a trivial proof
- The `valid_dense` frame class distinction becomes meaningless for this axiom
- The axiom system loses its ability to distinguish dense from non-dense temporal orders
- The entire density proof architecture (DenseQuotient.lean, density-specific instances) becomes vacuous

### Finding 3: temp_4 Becomes Redundant

The temp_4 axiom is: `G(phi) -> G(G(phi))`.

With reflexive semantics on a reflexive, transitive order (which `<=` is):
- `G(phi)` at `t` means: `phi` at all `s >= t`
- `G(G(phi))` at `t` means: for all `s >= t`, `G(phi)` at `s`, i.e., for all `s >= t` and `u >= s`, `phi(u)`
- Given `G(phi)` at `t`: for any `s >= t` and `u >= s`, we have `u >= t` (by transitivity), so `phi(u)` by the hypothesis.

**temp_4 follows directly from transitivity of `<=`.** It is derivable from the T-axiom alone on reflexive transitive orders. Including it as an axiom is harmless but redundant, and the soundness proof changes from using `lt_trans` to using `le_trans`.

### Finding 4: temp_a Changes Meaning

The temp_a axiom is: `phi -> G(P(phi))`.

With irreflexive semantics, this says: if `phi` at `t`, then for all `s > t`, there exists `r < s` with `phi(r)` (namely `r = t`). This is the "present was in the past of any future" connection.

With reflexive semantics, `P(phi)` at `s` means `exists r <= s, phi(r)`. So `G(P(phi))` at `t` means: for all `s >= t`, exists `r <= s`, `phi(r)`. Since `phi` holds at `t` and `t <= s`, take `r = t`. This is trivially valid.

**temp_a becomes trivially valid with reflexive semantics.** Again, it loses its distinguishing content -- it no longer encodes any interesting frame condition. The current soundness proof (line 174) which uses the strict ordering structure would be replaced with a trivial proof.

### Finding 5: Seriality Axioms Become Unnecessary

The seriality axioms `F(neg bot)` and `P(neg bot)` say: there exists a strict future/past time.

With reflexive semantics, `F(neg bot)` means `exists s >= t, neg bot(s)`. Take `s = t`. Since `neg bot` is always true, `F(neg bot)` is trivially valid on all frames. No need for `NoMaxOrder` or `NoMinOrder`.

**The seriality axioms (recently added in research-024/implementation-006) would become completely pointless.** The work to add them, prove their soundness, and integrate them into the axiom system would be wasted.

### Finding 6: Impact on Completeness Theorem Target

The completeness theorem states: if `phi` is valid on all dense/discrete/etc. frames, then `phi` is derivable.

With reflexive semantics:
- `valid` quantifies over all frames with `<=` (reflexive) temporal orders
- The class of models changes: we are now looking at reflexive, transitive, linear orders (i.e., total orders with reflexivity)
- The canonical model construction changes: G-closed MCSes are no longer problematic because G-closure (`G(phi) in M -> phi in M`) is EXPECTED (it corresponds to the T-axiom, which is now valid)
- The frame class is different: we would be proving completeness for a DIFFERENT logic

**This is a fundamental change in what theorem is being proved.** The current project proves completeness for TM logic with irreflexive temporal semantics (following the JPL paper). Switching to reflexive semantics changes the target logic entirely.

### Finding 7: Which Axioms Change Validity?

| Axiom | Irreflexive | Reflexive | Notes |
|-------|-------------|-----------|-------|
| prop_k | Valid | Valid | No change |
| prop_s | Valid | Valid | No change |
| ex_falso | Valid | Valid | No change |
| peirce | Valid | Valid | No change |
| modal_t | Valid | Valid | No change (modal, not temporal) |
| modal_4 | Valid | Valid | No change |
| modal_b | Valid | Valid | No change |
| modal_5_collapse | Valid | Valid | No change |
| modal_k_dist | Valid | Valid | No change |
| temp_k_dist | Valid | Valid | Proof unchanged |
| **temp_4** | Valid | **Redundant** | Derivable from T + transitivity |
| **temp_a** | Valid | **Trivially valid** | Loses frame condition content |
| **temp_l** | Valid | Valid | Proof simplifies |
| modal_future | Valid | Valid | Proof unchanged (uses time-shift) |
| temp_future | Valid | Valid | Proof unchanged (uses time-shift) |
| temp_linearity | Valid | Valid | Proof unchanged |
| **density** | Valid on dense | **Trivially valid** | Loses density frame condition |
| discreteness_fwd | Valid on discrete | Changes | Needs analysis |
| **seriality_future** | Valid on no-max | **Trivially valid** | Loses no-max frame condition |
| **seriality_past** | Valid on no-min | **Trivially valid** | Loses no-min frame condition |
| **T-axiom (new)** | UNSOUND | **Would be needed** | `G(phi) -> phi` becomes valid and needed |

**New axioms that become valid with reflexive semantics:**
- `G(phi) -> phi` (temporal T-axiom for future)
- `H(phi) -> phi` (temporal T-axiom for past)

These would need to be ADDED to the axiom system for completeness.

### Finding 8: Impact on Existing Soundness Proofs

The following soundness proofs in `Soundness.lean` would need revision:

1. **temp_4_valid** (line 167): Currently uses `lt_trans`. Would use `le_trans`. Minor change.
2. **temp_a_valid** (line 174): Currently uses strict ordering. Would become trivial. Simplification.
3. **temp_l_valid** (line 183): Currently uses `lt_trichotomy`. Would simplify but still work.
4. **density_valid** (line 271): Currently uses `DenselyOrdered.dense`. Would become trivial. Major change.
5. **discreteness_forward_valid** (line 290): Uses `Order.succ`. Would need careful revision.
6. **seriality_future_valid** (line 325): Uses `exists_gt`. Would become trivial.
7. **seriality_past_valid** (line 343): Uses `exists_lt`. Would become trivial.

Additionally, two NEW soundness proofs would be needed:
- `temp_t_future_valid`: `G(phi) -> phi` is valid (trivial with `<=`)
- `temp_t_past_valid`: `H(phi) -> phi` is valid (trivial with `<=`)

### Finding 9: Impact on the Product Domain Truth Lemma

Returning to the original question: does reflexive semantics solve the truth lemma blocker in the product domain?

**For the forward direction (MCS membership implies truth):**
- `G(phi) in m` implies `phi in m` (by T-axiom, now valid)
- Need: `phi` true at all `(m', q')` with `(m, q) <= (m', q')`
- For `(m, q')` with `q' >= q`: truth at `(m, q')` = `phi in m`. Holds by above.
- For `(m', q')` with `m' > m` in quotient: truth at `(m', q')` = `phi in m'`. Need `phi in m'` for all `m' > m`.
- **This STILL requires the coherence structure** linking G-membership in `m` to membership in future MCSes `m'`.

**For the backward direction (truth implies MCS membership):**
- Truth of `G(phi)` at `(m, q)` means `phi` at all `(m', q') >= (m, q)`
- In particular `phi` at `(m, q)` (taking `q' = q`), so `phi in m`
- But we need `G(phi) in m`, not just `phi in m`
- **The backward direction STILL requires the contrapositive argument**: if `G(phi) not_in m`, then `F(neg phi) in m`, and we need a witness point where `neg phi` holds

**Conclusion**: Reflexive semantics does NOT eliminate the need for multi-MCS histories in the truth lemma. It makes the forward direction slightly easier (T-axiom gives `phi in m` for free) but does NOT solve the backward direction.

### Finding 10: The Real Problem and Its Real Solution

The truth lemma blocker for G/H in the product domain is NOT about reflexive vs irreflexive semantics. It is about the relationship between:

1. The universal quantifier in `G(phi)` ranging over ALL future points in the temporal domain
2. The MCS-based syntactic characterization of `G(phi)` membership

With single-MCS histories `tau(t) = (m, t)`, the temporal semantics only sees points with MCS `m`. But the G/H backward direction needs to relate truth at points with DIFFERENT MCSes.

The solution is to construct multi-MCS histories that traverse different quotient classes, OR to show that the truth lemma can be stated in a way that only requires same-MCS points. Neither of these requires changing the reflexivity of the temporal ordering.

The product domain approach (implementation-007) addresses the structural issue (NoMaxOrder, DenselyOrdered) but leaves the truth lemma's G/H case as the remaining challenge. This challenge is about HISTORY CONSTRUCTION, not about reflexive vs irreflexive semantics.

## Recommendation

**Do NOT switch to reflexive G/H semantics.** The costs far outweigh the benefits:

**Costs:**
1. Loss of density axiom content (becomes trivially valid)
2. Loss of seriality axiom content (recently added, now wasted)
3. Redundancy of temp_4 and temp_a (axiom system becomes bloated with trivial axioms)
4. Revision of 7+ soundness proofs
5. Addition of 2 new axioms (temporal T-axioms)
6. Contradiction of documented architectural decision
7. Change in the completeness theorem target (different logic)
8. Potential breakage of DenseQuotient.lean density proofs
9. Research-024's analysis and seriality implementation become obsolete

**Benefits:**
1. Slightly simpler forward direction for truth lemma (T-axiom gives phi in m for free)
2. G-closed MCSes are no longer "anomalous" (they correspond to the T-axiom)

**The benefits do not justify the costs**, especially since the reflexive switch does NOT solve the backward direction of the truth lemma, which is the actual blocker.

**Instead**: Focus on solving the truth lemma's G/H backward direction within the irreflexive product domain framework. This requires constructing appropriate multi-MCS histories or reformulating the truth lemma to use a different witness structure.

## Decisions

- **D1**: Do not switch to reflexive G/H semantics
- **D2**: The truth lemma blocker is a history construction problem, not a semantics problem
- **D3**: The product domain approach remains the correct framework; the G/H truth lemma case needs a multi-MCS history construction or a reformulated truth lemma statement

## Next Steps

1. Analyze what multi-MCS history construction would look like in the product domain
2. Consider whether the truth lemma can be reformulated to use a "point-wise" rather than "history-based" truth definition
3. Investigate the relationship between the BFMCS truth lemma (already proven, uses BFMCS coherence) and the TaskFrame truth lemma (product domain, needs history construction)

## Confidence Assessment

| Finding | Confidence | Notes |
|---------|------------|-------|
| Reflexive semantics does NOT solve backward direction | High | Mathematical analysis clear |
| Density axiom becomes trivially valid | High | Direct proof |
| temp_4 becomes redundant | High | Direct proof |
| temp_a becomes trivially valid | High | Direct proof |
| Seriality becomes unnecessary | High | Direct proof |
| Overall recommendation (do not switch) | High | Cost-benefit analysis strongly favors status quo |
