# Teammate C Findings: Risk Analysis and Critical Assessment

**Task**: 84 - Establish Until/Since Coherence for Bundle Completeness
**Focus**: Risks, blockers, edge cases, and critical analysis of the enriched seed approach
**Date**: 2026-04-07

## 1. Catalog of Prior Failures and Root Cause Analysis

### Failure Mode 1: X-vs-G Mismatch (Reports 28, 38, Plan v15)

**The specific mathematical step that broke**: Until unfolds via BX9 into `psi OR (phi AND X(phi U psi))`. The `X(phi U psi)` puts `phi U psi` into x_content(w_n), but chains propagate via g_content(w_n). Since `g_content != x_content` and `G(phi U psi)` is generally NOT in w_n (Until is existential, G is universal), the Until formula is lost at the Lindenbaum step. Concretely: `g_content(w_n) = {alpha : G(alpha) in w_n}`, and there is no reason for `G(phi U psi) in w_n`.

**Does enriched seed avoid this?** YES. Approach D explicitly adds `{phi U psi : (phi U psi) in w_n AND psi not in w_n}` to the seed, bypassing the x_content/g_content gap entirely. The Until formula enters the seed directly, not through g_content.

**Fundamental or incidental?** INCIDENTAL for the enriched seed approach. The X-vs-G mismatch is fundamental for g_content-only chains but is entirely sidestepped by seed enrichment.

### Failure Mode 2: forward_F/backward_G Circularity (Report 28)

**The specific mathematical step that broke**: Proving `F(psi) in chain(n) -> exists s > n, psi in chain(s)` requires showing F-obligations resolve. The standard argument uses `temporal_backward_G_with_fwd_F` which requires forward_F as a hypothesis -- circular.

**Does enriched seed avoid this?** PARTIALLY. The enriched seed with dovetailing provides forward_F directly (dovetailing schedules psi into the seed, so psi eventually appears). However, this relies on the dovetailed chain construction already proven sorry-free for restricted_temporally_coherent. The circularity is broken because forward_F comes from the scheduling mechanism, not from a backward_G argument.

**Fundamental or incidental?** INCIDENTAL. The circularity was specific to the proof strategy, not to the mathematical content.

### Failure Mode 3: Enriched Deferral Seed Inconsistency (Plan v2 Summary)

**The specific mathematical step that broke**: Plan v2 proposed seed = `{target} UNION g_content(M) UNION {chi OR F(chi) | F(chi) in M, chi in DC}`. This seed is INCONSISTENT when the target implies `G(neg(chi))` for some chi with `F(chi) in M`. Concrete example: `G(neg(p)) in g_content(M)` and `F(p) in M` makes `{p OR F(p)} UNION g_content(M)` inconsistent.

**Does enriched seed (Approach D) avoid this?** YES, because Approach D does NOT add deferral disjunctions. It adds `{phi U psi : (phi U psi) in w_n AND psi not in w_n}` -- formulas already present in w_n. The consistency argument is trivial: every element of the enriched seed is in w_n (which is consistent), so the seed is consistent.

**Fundamental or incidental?** INCIDENTAL. The v2 approach added formulas not in w_n. Approach D only adds formulas already in w_n.

### Failure Mode 4: BX4 Invalidity (Report 37)

**The specific mathematical step that broke**: BX4 (`G(phi -> X(psi)) -> phi U psi`) is semantically invalid under the project's reflexive Until semantics with half-open guards.

**Does enriched seed avoid this?** YES. Approach D does not use BX4 at all. It relies on BX5 (self-accumulation), BX8 (reflexive introduction), BX9 (elimination), and BX10 (eventuality extraction).

**Fundamental or incidental?** INCIDENTAL for approaches not relying on BX4.

### Failure Mode 5: Backward Until Derivation Invalid (Task 83 Summary 39)

**The specific mathematical step that broke**: `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))` is semantically INVALID. Countermodel: p true at 0, p false at 1, q false everywhere except q true at 2. Then `neg(p U q)` holds at 0 but neither `neg(p)` nor `G(neg(p U q))` holds.

**Does enriched seed avoid this?** This is the CRITICAL question. Approach D's synthesis claims backward Until can be proved "by contradiction using MCS properties of intermediate positions." But this failure mode shows that the obvious negation-unfolding approach does NOT work.

**Fundamental or incidental?** This is the HIGHEST RISK item. See Risk R1 below.

### Failure Mode 6: Multi-Target Seed Inconsistency (Plan v1 Summary)

**The specific mathematical step that broke**: Adding multiple F-targets simultaneously to the seed (`{chi_1, ..., chi_k} UNION g_content(M)`) is inconsistent when the targets contradict each other (e.g., `F(p)` and `F(neg(p))` both in M).

**Does enriched seed avoid this?** PARTIALLY. Approach D adds Until formulas (not their targets) to the seed. But the dovetailing mechanism adds ONE target at a time. The multi-target issue should not arise because the seed at each step contains Until formulas (consistent with w_n) plus ONE dovetailed target.

**Fundamental or incidental?** INCIDENTAL for single-target dovetailing.

## 2. Critical Analysis of the Backward Until Direction

### What the Definition Requires

`until_since_coherent` has FOUR conjuncts per family. The backward directions are:

- **Backward Until**: If `exists s >= t, psi in fam.mcs s AND forall r in [t,s), phi in fam.mcs r`, then `phi U psi in fam.mcs t`
- **Backward Since**: If `exists s <= t, psi in fam.mcs s AND forall r in (s,t], phi in fam.mcs r`, then `phi S psi in fam.mcs t`

### How h_uc Is Actually Used in the Truth Lemma

From `CanonicalConstruction.lean` lines 629-641, the Until case of the truth lemma:

```lean
| untl phi psi ih_phi ih_psi =>
    simp only [truth_at]
    obtain (h_fwd_U, h_bwd_U, _, _) := h_uc fam hfam
    constructor
    -- Forward: phi U psi in MCS -> semantic truth
    . intro h_U
      obtain (s, h_ts, h_psi_s, h_phi_guard) := h_fwd_U t phi psi h_U
      exact (s, h_ts, (ih_psi fam hfam s).mp h_psi_s,
        fun r h_tr h_rs => (ih_phi fam hfam r).mp (h_phi_guard r h_tr h_rs))
    -- Backward: semantic truth -> phi U psi in MCS
    . intro (s, h_ts, h_truth_psi_s, h_truth_phi_guard)
      exact h_bwd_U t phi psi (s, h_ts,
        (ih_psi fam hfam s).mpr h_truth_psi_s,
        fun r h_tr h_rs => (ih_phi fam hfam r).mpr (h_truth_phi_guard r h_tr h_rs))
```

**Yes, the backward direction IS used.** The truth lemma is a biconditional. The backward direction converts semantic truth of `phi U psi` (there exists a witness time with correct guards in the model) into syntactic membership `phi U psi in fam.mcs t`.

### Is Backward Until Provable?

The backward direction requires: given that psi is in some future MCS and phi holds at all intermediate MCS positions, show `phi U psi` is in the current MCS.

**Key insight**: This is NOT the same as the BX derivation that failed. The failed derivation was about negating Until in a SINGLE MCS. The backward property is about INTER-MCS relationships along a chain. The chain construction determines whether this holds.

**For the enriched chain**: If the chain is built so that (phi U psi) persists in the seed whenever psi has not yet appeared and phi holds, then by construction (phi U psi) remains in every intermediate MCS. When psi finally appears at time s, we have:
- psi in fam.mcs s (by construction)
- phi in fam.mcs r for all r in [t,s) (by Until unfolding via BX9 at each step)
- phi U psi in fam.mcs t (it was in the seed and preserved by Lindenbaum)

But wait -- the backward direction goes the OTHER way: given the semantic witness, show the formula is in the MCS. The question is: does the chain construction GUARANTEE that if a semantic witness exists, then `phi U psi` was placed in the MCS at time t?

**This requires BX8 (reflexive introduction)**: `psi -> phi U psi`. If the witness is at s = t, then psi in fam.mcs t implies phi U psi in fam.mcs t by BX8 and MCS closure.

For s > t: We need that the chain was built such that the existence of a future psi with intermediate phi forces phi U psi at time t. This is NOT guaranteed by the enriched seed construction, which only preserves Until formulas that are ALREADY in the MCS.

**This is the crux**: The backward direction cannot be guaranteed by construction alone. It requires a mathematical argument. Specifically, suppose phi U psi is NOT in fam.mcs t. Then neg(phi U psi) is in fam.mcs t (by MCS maximality). We need to derive a contradiction from:
1. neg(phi U psi) in fam.mcs t
2. psi in fam.mcs s for some s > t
3. phi in fam.mcs r for all r in [t,s)

From (1) and BX9 contrapositive: neg(phi U psi) -> neg(phi OR psi) -> neg(phi) AND neg(psi). So neg(psi) in fam.mcs t and neg(phi) in fam.mcs t. But from (3) with r = t (since t in [t,s) when s > t), phi in fam.mcs t. Contradiction with neg(phi) in fam.mcs t.

**Wait -- BX9 says `(phi U psi) -> (phi OR psi)`, NOT `(phi U psi) -> psi OR (phi AND X(phi U psi))`.**

Under reflexive semantics, BX9: `(phi U psi) -> phi OR psi`. Contrapositive: `neg(phi) AND neg(psi) -> neg(phi U psi)`. Equivalently: `neg(phi U psi) -> phi OR psi` (NO, that's the same direction).

Actually: BX9 gives `(phi U psi) -> phi OR psi`. So `neg(phi OR psi) -> neg(phi U psi)`. And `neg(phi U psi)` implies... we need the CONVERSE.

For backward Until: Assume neg(phi U psi) in fam.mcs t. Under reflexive semantics, `neg(phi U psi)` at t means: for all s >= t, either psi is false at s, or phi is false at some r in [t,s). This is exactly the negation of the hypothesis. So by contradiction, if the semantic witness exists, phi U psi must be in fam.mcs t.

**But this argument uses semantics, not axiomatics.** The truth lemma is supposed to ESTABLISH the correspondence between syntax and semantics. Using semantics to prove the backward direction is circular.

**The non-circular argument**: Suppose neg(phi U psi) in fam.mcs t and we have the syntactic witnesses (psi in fam.mcs s, phi in intermediate positions). The [t,s) guard condition with BX semantics means phi in fam.mcs t (when s > t). But we also have neg(phi U psi) in fam.mcs t. By BX9: (phi U psi) -> phi OR psi, contrapositive neg(phi) AND neg(psi) -> neg(phi U psi). This doesn't help directly.

Let me try BX8: psi -> phi U psi. So if psi in fam.mcs t, then phi U psi in fam.mcs t. But s may not equal t.

For s > t: We need to show phi U psi in fam.mcs t given phi in fam.mcs t and phi U psi in fam.mcs(t+1) (by induction from s down to t). But phi U psi in fam.mcs(t+1) does NOT imply phi U psi in fam.mcs t -- MCS at different times are independent except through the chain construction.

**This is the real problem.** The backward direction requires either:
(a) A chain construction where phi U psi is forced into fam.mcs t by the construction itself, OR
(b) An axiomatic argument that works purely within a single MCS

Neither is straightforward. The enriched seed only guarantees (a) for formulas that were ALREADY in the MCS. For formulas that should be there but aren't, the construction doesn't help.

### BX10 and Alternative Approaches

BX10: `(phi U psi) -> F(psi)`. Contrapositive: `G(neg(psi)) -> neg(phi U psi)`.

BX5 (self-accumulation): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`.

BX6 (absorption): `(phi U (phi AND (phi U psi))) -> (phi U psi)`.

None of these directly give the backward direction.

**The BX10 induction axiom** (from Burgess/Xu literature, not listed as a BX axiom in this project) would be: `(G(psi -> chi) AND G(phi -> chi OR X(chi))) -> (phi U psi -> chi)`. This is essentially Until induction. It COULD be used for the backward direction... but it's NOT in the axiom set (BX10 here is `(phi U psi) -> F(psi)`).

**Assessment**: The backward Until direction is provable IF we can establish that the chain construction places neg(phi U psi) only when the semantic witness is absent. This requires the FORWARD direction to be established first, then backward follows by MCS maximality: if phi U psi is not in the MCS, then neg(phi U psi) is, and forward gives us a semantic counterwitness that contradicts the hypothesis.

**Wait -- that IS circular for the truth lemma proof.** The truth lemma proves forward and backward simultaneously by structural induction on formulas. At the Until case, we CANNOT use the forward direction to prove the backward direction because they're being proved in the same step.

**Resolution**: Actually, looking at the code again, the truth lemma uses `h_uc` for BOTH directions. The `until_since_coherent` property is an ASSUMPTION, not something derived from the chain. So the backward direction of `until_since_coherent` must be established for the specific chain construction, independently of the truth lemma.

For a chain where fam.mcs t are MCS for each t: if there exists s >= t with psi in fam.mcs s and phi in fam.mcs r for all r in [t,s), we need phi U psi in fam.mcs t.

The correct argument: By MCS maximality, either phi U psi in fam.mcs t or neg(phi U psi) in fam.mcs t. Suppose neg(phi U psi) in fam.mcs t. The enriched seed construction guarantees that neg(phi U psi) propagates forward (via g_content, since we can derive G(neg(phi U psi)) from neg(phi U psi) when the guard holds). Actually NO -- we showed this derivation is INVALID.

**I believe backward Until is the single hardest sub-problem and may require a fundamentally new idea.**

## 3. Temporal Coherence Interaction with Enriched Seed

### Does g_content propagation still work?

The enriched seed is `g_content(w_n) UNION {active Until formulas in w_n}`. The g_content portion is unchanged, so forward_G propagation works exactly as before: if G(alpha) in w_n, then alpha in g_content(w_n) subset seed subset w_{n+1}.

**Verdict**: No interference. g_content propagation is unaffected.

### Does enriched seed interfere with forward_F/backward_P?

The dovetailed chain already provides sorry-free restricted_temporally_coherent. The enriched seed adds formulas to the Lindenbaum seed, making w_{n+1} a LARGER superset. Since Lindenbaum extension preserves supersets of the seed, adding Until formulas cannot remove formulas that would otherwise be in w_{n+1}.

However, adding formulas CAN change which MCS the Lindenbaum extension produces (Lindenbaum is non-deterministic; different seeds yield different extensions). Could this cause previously-resolved F-obligations to become unresolved?

**Analysis**: Forward_F for the dovetailed chain relies on the scheduling mechanism placing F-targets in the seed. If the enriched seed causes a different MCS that happens to not contain some previously-held formula, this could break F-resolution for other formulas.

**Verdict**: LOW RISK. The enriched seed is a superset of the non-enriched seed, and Lindenbaum extension of a superset produces an MCS that extends the superset. So every formula in the non-enriched seed's MCS is still derivable from the enriched seed's MCS. The F-resolution targets are in the seed by scheduling, and they remain in the seed.

### Could enriching make temporally_coherent harder?

The dovetailed chain's restricted_temporally_coherent is already sorry-free. An enriched chain would be a NEW construction, not a modification of the existing dovetailed chain. So the question is: can the new enriched chain also satisfy temporally_coherent?

**Yes, by design**: The enriched chain uses the same g_content propagation (forward_G, backward_H) and the same dovetailing (forward_F, backward_P). The Until formula additions are orthogonal.

## 4. Dovetailing Scheduling for Until: Guard Verification

### The dual obligation problem

Until `phi U psi` requires:
1. **Witness**: psi eventually holds at some s >= t
2. **Guard**: phi holds at ALL intermediate r in [t, s)

Dovetailing handles (1) by scheduling psi into the seed. But (2) must hold at EVERY intermediate step, which is a universal quantifier over steps, not an existential one.

### Is the guard guaranteed?

When (phi U psi) in w_n and psi not in w_n, BX9 gives phi OR psi in w_n. Since psi not in w_n, we get phi in w_n. Good -- the guard holds at step n.

But does the guard hold at step n+1, n+2, ..., up to the step where psi is scheduled?

If (phi U psi) persists in the chain (by enriched seed), then at each intermediate step r, (phi U psi) in w_r and psi not in w_r (until the scheduling step). By BX9, phi in w_r. So the guard holds at every intermediate step.

**The critical dependency**: phi guard verification depends ENTIRELY on Until persistence. If (phi U psi) drops out of the chain at any intermediate step, the guard may fail.

### Until persistence in the enriched chain

The enriched seed at step n is `g_content(w_n) UNION {phi_i U psi_i : (phi_i U psi_i) in w_n AND psi_i not in w_n}`. So if (phi U psi) in w_n and psi not in w_n, then (phi U psi) is in the seed for step n+1. Lindenbaum preserves the seed, so (phi U psi) in w_{n+1}.

At step n+1: if psi not in w_{n+1}, then (phi U psi) is again in the enriched seed for step n+2. This continues until psi enters w_s (when it's scheduled).

**This works.** Until persistence is guaranteed by the enriched seed construction, as long as psi is not in the MCS (which it won't be until the scheduling step places it there).

**Edge case**: What if Lindenbaum extension at step n+1 independently adds psi? Then psi in w_{n+1} without being the dovetailed target. In this case, the Until obligation is resolved at step n+1 (earlier than the scheduled step). This is FINE -- it means the witness s = n+1 with the guard holding at n (which it does, by the argument above).

### Conflicting Until formulas

What if w_n contains both `(phi1 U psi1)` and `(phi2 U psi2)` where psi1 and psi2 are incompatible (e.g., psi1 = neg(psi2))?

The enriched seed includes both Until formulas. Both are in w_n (which is consistent), so the seed is consistent. The Lindenbaum extension produces an MCS extending the seed. Both Until formulas are in w_{n+1}. This is fine -- MCS consistency of w_{n+1} only requires that {phi1 U psi1, phi2 U psi2} is consistent, which it is (both are in the consistent w_n, and the seed only adds formulas from w_n plus g_content of w_n, all of which are already consistent).

Dovetailing will schedule psi1 and psi2 at different times. When psi1 is scheduled, it enters the seed and Lindenbaum includes it. At that point, neg(psi2) may or may not be in the MCS -- the key question is whether (phi2 U psi2) still persists. It does, because it's in the enriched seed (as long as psi2 has not appeared yet).

**Verdict**: No conflict from simultaneously active Until formulas.

## 5. Type-Level Issues in Lean

### The Three Sorry Sites

| Line | Theorem | Chain Type |
|------|---------|------------|
| 322 | `bundle_validity_implies_provability` | `construct_bfmcs_bundle` (UltrafilterChain) |
| 356 | `restricted_bundle_validity_implies_provability` | `construct_bfmcs_bundle` (same, restricted TC) |
| 450 | `dovetailed_bundle_validity_implies_provability` | `construct_dovetailed_bfmcs_bundle` (DovetailedChain) |

All three have `have h_uc : B.until_since_coherent := sorry`.

### Chain type differences

- **Lines 322/356** use `construct_bfmcs_bundle` which builds from `boxClassFamilies` where each family is a `shifted_fmcs (SuccChainFMCS S) delta`. The SuccChainFMCS uses g_content seeds. **This construction does NOT support enriched seeds** without modification.

- **Line 450** uses `construct_dovetailed_bfmcs_bundle` which builds from `dovetailedBoxClassFamilies` where each family is a `shifted DovetailedFMCS`. The DovetailedFMCS already uses dovetailed scheduling for F-resolution. **This is the natural host for enriched seeds.**

### Can all three support enriched seeds?

- **Lines 322/356**: Would require creating a NEW enriched variant of `construct_bfmcs_bundle` or proving `until_since_coherent` for the existing SuccChain-based construction. The existing SuccChain does NOT have dovetailed scheduling, so Until resolution would need a different mechanism.

- **Line 450**: Natural fit. The DovetailedChain already schedules targets; extending it to also schedule Until targets is architecturally clean.

**Recommendation**: Focus on line 450 (dovetailed path) first. Lines 322/356 can potentially be closed by either (a) creating an enriched SuccChain variant, or (b) proving that SuccChain-based families happen to satisfy until_since_coherent (seems unlikely without explicit construction), or (c) making completeness_over_Int route through the dovetailed path only.

### Universe levels

The BFMCS and FMCS types are in `Type 0` (they use `Set Formula` which is in `Type 0`). No universe polymorphism issues.

### Decidability

The enriched seed construction requires checking `psi not in w_n` to decide which Until formulas are "active." Since w_n is a `Set Formula` (not `Finset`), this membership test is not decidable. However, this is fine for the noncomputable construction: the enriched seed is defined using classical logic (`if psi in w_n then ... else ...`), and Lean 4 supports noncomputable definitions.

The existing `targeted_successor` in SuccChainFMCS.lean is already noncomputable. The enriched chain would follow the same pattern.

### Finset vs Set

The chain constructions use `Set Formula` throughout. The subformula closure is a `Finset Formula`, and scheduling iterates over it. The enriched seed adds elements from `Set Formula` (the active Until formulas). No Finset/Set mismatch.

## 6. Effort Realism Assessment

### Has enriched seed been tried before?

YES, extensively. The term "enriched seed" appears in 42 files across task 83's reports and plans (searched above). Specifically:

- **Plan v2** (enriched deferral seed): BLOCKED on inconsistency of `{chi OR F(chi)} UNION g_content(M)` when targets contradict
- **Plan v6**: References "enriched seed" for Until formulas; 6/10 items blocked as unsound under reflexive semantics
- **Reports 38/39**: Enriched-Succ chain recommended as the primary approach, with the consistency argument from Approach D

**The KEY difference with Approach D**: Previous "enriched seed" attempts added formulas NOT in w_n (deferral disjunctions, x_content elements, multi-targets). Approach D ONLY adds formulas that are ALREADY in w_n (active Until formulas). The consistency argument is therefore trivially `g_content(w_n) UNION {active Untils in w_n} subset w_n` and w_n is consistent.

This is genuinely a novel framing. The synthesis (report 01) correctly identifies this distinction. However:

### What makes task 84 different from task 83?

1. **Task 83 had scope creep**: It started with restricted_temporally_coherent and ended up discovering the X-vs-G mismatch, changing axiom systems to BX, and refactoring the entire proof architecture. Task 84 has a MUCH more focused scope.

2. **The truth lemma sorries are already closed**: Task 83 closed 6 truth lemma sorries. Task 84 only needs to provide the `until_since_coherent` witness for the chain construction.

3. **The consistency argument is settled**: The "subset of w_n" argument for seed consistency is trivially correct. Previous task 83 attempts used seeds with elements NOT in w_n.

4. **The forward direction is straightforward**: Until persistence + dovetailed scheduling. The mathematics is clear.

5. **The backward direction is the wild card**: See Risk R1 below.

### Effort estimate

- **Forward Until + Forward Since**: 4-8 hours. Well-understood mathematics, clear implementation path.
- **Backward Until + Backward Since**: 4-20 hours. Depends entirely on finding the right mathematical argument.
- **Completeness wiring**: 2-4 hours. Mechanical once the coherence proof exists.
- **Total realistic estimate**: 10-32 hours, with high variance from the backward direction.

Task 83's repeated "12-18 hour" estimates were unrealistic because they assumed the mathematical obstacles were engineering problems. Task 84's obstacles are better characterized, but the backward direction remains genuinely uncertain.

## Risk Register

### R1: Backward Until Direction May Be Unprovable from BX Axioms Alone

**Likelihood**: MEDIUM-HIGH (45%)
**Impact**: HIGH (blocks 2 of 4 conjuncts of until_since_coherent)
**Description**: The backward Until direction requires showing: if psi appears at a future time s and phi holds at all intermediate times, then `phi U psi` is in the MCS at time t. The direct BX derivation was proven semantically INVALID (task 83, plan v39, phase 1). The MCS-maximality argument (either phi U psi or neg(phi U psi) is in the MCS) requires showing neg(phi U psi) leads to contradiction, but the propagation of neg(phi U psi) through the chain is exactly what was proven invalid.

**Mitigation options**:
1. **Weaken until_since_coherent**: Replace the backward direction with a weaker property that suffices for the truth lemma. However, the truth lemma code explicitly uses h_bwd_U.
2. **Restructure the truth lemma**: Prove the Until case of the truth lemma using only forward coherence plus an axiomatic argument for the backward direction at a SINGLE time point. BX8 handles s = t (psi -> phi U psi). For s > t, use BX5 (self-accumulation) and chain induction.
3. **Use BX axioms within a single MCS**: At time t, if phi in fam.mcs t (from guard) and we know the chain will eventually contain psi (from forward coherence of the Until formula at t+1, by induction), then use some BX axiom to derive phi U psi at t. This requires `phi AND F(psi) -> phi U psi` which is... not a BX axiom but might be derivable. Actually NO: `phi AND F(psi)` does not imply `phi U psi` because the guard must hold on the entire interval, not just at t.
4. **Build the chain to make backward Until hold by construction**: Ensure that whenever psi appears at a future time and phi holds on the interval, the chain construction ALREADY places phi U psi at time t. This means the seed at time t must include phi U psi. But at construction time, we don't know the future -- the chain is built incrementally.

**Assessment**: Mitigation 2 is most promising. The backward direction might be achievable by induction on (s - t): Base case s = t uses BX8. Inductive case: if phi U psi in fam.mcs(t+1) and phi in fam.mcs t, can we derive phi U psi in fam.mcs t? This would require something like `phi AND X(phi U psi) -> phi U psi`, which is... close to the definition of Until unfolding but in the REVERSE direction. Under reflexive semantics, `phi U psi` at t means there exists s >= t with psi at s and phi on [t,s). If phi at t and phi U psi at t+1 (which provides s >= t+1 with psi at s and phi on [t+1,s)), then combining gives s >= t+1 > t with psi at s and phi on [t,s). So phi U psi at t. This is semantically correct but needs an AXIOMATIC derivation.

The key question: is `phi AND (phi U psi) -> phi U psi` derivable? Yes, trivially (drop the phi). But we need `phi AND X(phi U psi) -> phi U psi`. This is NOT available because the axiom system has no X operator.

**However**: In the chain construction, "next step" corresponds to the successor MCS. We have phi in fam.mcs t and phi U psi in fam.mcs(t+1). We need phi U psi in fam.mcs t. By BX5 at time t+1: (phi U psi) -> ((phi AND (phi U psi)) U psi). So at t+1 we have (phi AND (phi U psi)) U psi, which means there exists s >= t+1 with psi at s and (phi AND (phi U psi)) at all r in [t+1, s). But this is about the MCS at t+1, not t.

I see no clean axiomatic path. **This risk is real.**

### R2: Enriched Seed Consistency Argument May Have Subtle Flaw

**Likelihood**: LOW (15%)
**Impact**: HIGH (blocks the entire approach)
**Description**: The consistency argument claims `g_content(w_n) UNION {active Untils in w_n} subset w_n`, therefore consistent. But g_content(w_n) is `{alpha : G(alpha) in w_n}`, and under reflexive G semantics (BX1: G(phi) -> phi), `g_content(w_n) subset w_n`. Wait -- does this project use reflexive or strict G?

Checking BX1: `G(phi) -> phi` (reflexive). This IS an axiom. So g_content(w_n) subset w_n by MCS closure with BX1. Combined with active Untils (already in w_n), the enriched seed is a subset of w_n and therefore consistent.

**Actually**: The code comment in SuccExistence.lean says "g_content(u) subset u: REQUIRES T-axiom G(phi) -> phi -- FALSE under strict semantics." But BX1 IS in the axiom set (temp_t_future). So under the current BX system with reflexive G, g_content subset MCS.

Wait, let me re-read SuccExistence.lean:476: `sorry` with comment "KNOWN FALSE under strict semantics." But the BX system uses REFLEXIVE semantics (BX1). So this sorry should actually be PROVABLE now?

This is interesting -- there may be a stale sorry from before the BX transition. The `g_content_subset_deferral_restricted_mcs` at SuccChainFMCS.lean:1226 also has this as sorry with comment about requiring T-axiom.

If g_content(u) subset u is provable under BX (via BX1), then the enriched seed consistency is even more trivial than claimed.

**Mitigation**: Verify that `g_content(u) subset u` is provable from BX1 for MCS u. If yes, this simplifies the entire approach and may close some existing sorries too.

### R3: Dovetailed Chain Modification Breaks Existing Sorry-Free Properties

**Likelihood**: MEDIUM (30%)
**Impact**: MEDIUM (requires re-proving restricted_temporally_coherent)
**Description**: The existing DovetailedChain has sorry-free `restricted_temporally_coherent`. Creating a new EnrichedDovetailedChain (or modifying the existing one) risks breaking these properties. The sorry-free proofs for forward_F and backward_P in DovetailedChain.lean depend on specific properties of the current chain construction.

**Mitigation**: Build the enriched chain as a NEW construction alongside (not replacing) the existing DovetailedChain. Prove `until_since_coherent` for the new construction. If it also satisfies `restricted_temporally_coherent` (likely, since the enriched seed is a superset), both properties are available.

### R4: Lean Formalization Overhead Exceeds Mathematical Complexity

**Likelihood**: HIGH (60%)
**Impact**: MEDIUM (time overrun, not blockage)
**Description**: Task 83 repeatedly demonstrated that mathematically straightforward steps require disproportionate Lean proof engineering. Type coercions, universe issues, noncomputable definitions, and Lindenbaum lemma infrastructure all add friction. Even with the mathematical approach settled, the Lean implementation may take 2-3x the estimated time.

**Mitigation**: Use `sorry` strategically during development to validate the proof structure before filling details. Budget 2x the mathematical estimate for Lean formalization. Reuse existing infrastructure (targeted_g_content_seed_consistent, deferral_restricted_lindenbaum, etc.) wherever possible.

### R5: g_content(u) subset u May Actually Be Provable (Opportunity/Risk)

**Likelihood**: HIGH (70%)
**Impact**: POSITIVE (simplifies approach, closes stale sorries)
**Description**: Under BX1 (G(phi) -> phi), for any MCS u and any alpha in g_content(u), we have G(alpha) in u, so by BX1 and MCS closure, alpha in u. This means g_content(u) subset u is a THEOREM under BX, not an assumption.

If this is correct, several "KNOWN FALSE under strict semantics" sorries in SuccExistence.lean become provable, and the enriched seed consistency becomes even more straightforward.

**Risk variant**: If this argument is flawed (e.g., there's a subtlety about BX1 application in MCS context), then the enriched seed consistency argument needs more care.

**Mitigation**: Prove `g_content_subset_mcs_under_bx1` as a standalone lemma first. This is a low-risk, high-reward de-risking step.

### R6: Definition of until_since_coherent May Need Weakening

**Likelihood**: MEDIUM (35%)
**Impact**: MEDIUM (requires modifying truth lemma signatures)
**Description**: If backward Until/Since cannot be established for the chain construction (R1), the definition of `until_since_coherent` may need to be split into `forward_until_since_coherent` (provable) and `backward_until_since_coherent` (potentially provable by a different method). The truth lemma would need to be restructured to handle forward and backward separately.

**Mitigation**: Before committing to a full implementation, verify whether the backward direction is achievable. If not, design the weakened definition and truth lemma restructuring upfront.

### R7: Task Scope Underestimation (Systemic)

**Likelihood**: MEDIUM (40%)
**Impact**: HIGH (task balloons like task 83)
**Description**: Task 83 started as "close restricted coherence sorries" and evolved into a fundamental architecture overhaul. Task 84 could similarly discover that the enriched seed approach has an unforeseen blocker, requiring yet another architecture change.

**Mitigation**: Set a hard time-box (e.g., 16 hours). If the backward Until direction is not resolved within that time, escalate to a research sub-task rather than continuing to iterate. Define clear go/no-go criteria at each phase.

## Summary Assessment

| Risk | Likelihood | Impact | Priority |
|------|-----------|--------|----------|
| R1: Backward Until unprovable | 45% | HIGH | CRITICAL -- de-risk FIRST |
| R2: Seed consistency flaw | 15% | HIGH | LOW -- likely fine under BX |
| R3: Chain modification breaks TC | 30% | MEDIUM | MEDIUM -- mitigated by new construction |
| R4: Lean formalization overhead | 60% | MEDIUM | MEDIUM -- budget 2x |
| R5: g_content subset u provable | 70% | POSITIVE | HIGH -- do first as de-risking |
| R6: Definition needs weakening | 35% | MEDIUM | MEDIUM -- contingency plan |
| R7: Scope underestimation | 40% | HIGH | MEDIUM -- time-box |

### Recommended Execution Order

1. **De-risk R5**: Prove `g_content(u) subset u` under BX1. This is low-risk, high-reward, and clears the path for everything else.
2. **De-risk R1**: Attempt the backward Until direction. Try the induction approach (BX8 for base case, chain induction for s > t). If it fails within 4 hours, pivot to R6 (weaken the definition).
3. **Build forward direction**: Enriched seed + dovetailing for forward Until/Since. This is the well-understood part.
4. **Wire completeness**: Pass until_since_coherent to the sorry sites.
5. **Assess lines 322/356**: Determine if the UltrafilterChain path can be closed or should be abandoned in favor of the dovetailed path.

### Honest Assessment

The enriched seed approach (Approach D) is the best available option. The forward direction is achievable with HIGH confidence (85%). The backward direction is achievable with MEDIUM confidence (55%). The overall probability of closing all 3 sorry sites with full until_since_coherent (all 4 conjuncts) is approximately 50%. The probability of closing at least the forward 2 conjuncts and making meaningful progress is approximately 80%.

The most likely outcome is: forward Until/Since coherence established, backward direction either resolved through a clever MCS argument or deferred via definition weakening, and at least the dovetailed completeness path (line 450) closed.
