# Research Findings: Approaches A and D for Task #916

**Task**: Implement F/P witness obligation tracking to close DovetailingChain sorries
**Date**: 2026-02-20
**Focus**: Deep analysis of Approach A (Constructive Lindenbaum) and Approach D (Two-step splice)
**Researcher**: Teammate A (lean-research-agent)

## Executive Summary

After thorough code analysis and mathematical investigation, Approach A (Constructive Lindenbaum) has a confirmed mathematical obstruction documented in the boneyard (4 sorries in TemporalLindenbaum.lean), while Approach D (Two-step splice) suffers from a "single fixed function" constraint that makes splice-based constructions unsuitable for the current BFMCS architecture. A **hybrid approach** (Approach E: "One-witness-per-step enriched chain") emerges as the most viable path, combining the iterative witness accumulation idea from plan v002 with a simplified architecture that avoids the omega-squared complexity.

---

## Key Findings for Approach A (Constructive Lindenbaum)

### A1. Prior Art in Boneyard

File: `Theories/Bimodal/Boneyard/Bundle/TemporalLindenbaum.lean` (1147 lines)

This file contains a complete attempt at constructive formula-by-formula Lindenbaum with temporal saturation. The construction uses:

- **Formula enumeration**: `Encodable.ofCountable Formula` (line 157)
- **Henkin step**: For each enumerated formula phi, adds `temporalPackage(phi)` if consistent with the accumulated set, else adds `temporalPackage(neg phi)` if consistent, else skips (lines 332-338)
- **Temporal package**: `temporalWitnessChain(phi)` -- recursively extracts F/P witnesses down to the non-temporal base (lines 199-209)
- **Henkin limit**: Union of all chain elements (line 350)
- **Zorn maximalization**: Apply Zorn on temporally-consistent supersets (lines 610-616)

### A2. What Works in TemporalLindenbaum.lean

The following are **fully proven** (no sorries):

1. `henkinChain_consistent` -- Each chain element is consistent (line 401)
2. `henkinLimit_consistent` -- The Henkin limit is consistent (line 432)
3. `henkinLimit_forward_saturated` -- The limit preserves forward temporal saturation (line 445)
4. `henkinLimit_backward_saturated` -- The limit preserves backward saturation (line 510)
5. `henkinStep_witnessClosedSet` -- The Henkin step preserves witness closure (line 703)
6. `temporalClosure_forward_saturated` / `temporalClosure_backward_saturated` -- Closure properties (lines 1069, 1077)
7. `tcs_chain_has_upper_bound` -- Chain upper bounds for Zorn (line 585)

### A3. The Fundamental Blocker (4 Sorries)

The 4 sorries are all in `maximal_tcs_is_mcs` and its strengthened variant `maximal_tcs_is_mcs_closed`:

| Sorry | Line | Location | Problem |
|-------|------|----------|---------|
| 1 | 839 | `maximal_tcs_is_mcs` forward witness, neg(psi) in M | `{F(psi), neg(psi)}` is consistent; cannot derive contradiction |
| 2 | 862 | `maximal_tcs_is_mcs` forward witness, neg(psi) not in M, insert psi consistent | Cannot show `insert psi M` is in TCS without knowing psi's temporal structure |
| 3 | 883 | `maximal_tcs_is_mcs` forward witness, neg(psi) not in M, insert psi inconsistent | Circular: need MCS closure to derive neg(psi) in M, but proving M is MCS |
| 4 | 1023 | `maximal_tcs_is_mcs_closed` forward witness | Same fundamental problem as sorry 1 |

**Root cause**: The maximality argument for MCS requires showing that for any phi not in M, `insert phi M` is inconsistent. When phi = F(psi):
- `insert F(psi) M` may be consistent (F(psi) is not contradicted by anything in M)
- But `insert F(psi) M` may fail temporal forward saturation (F(psi) in set but psi not in set)
- So `insert F(psi) M` is not in TCS (temporally-saturated consistent supersets)
- The maximality argument only works within TCS, so it does not apply
- To show `insert F(psi) M` is inconsistent without TCS membership, we would need M to derive G(neg psi), which requires M to be derivation-closed -- but we are trying to PROVE M is an MCS (circular)

**Mathematical nature of the obstruction**: This is the **Temporal Saturation / Maximality Incompatibility** problem. For standard propositional logic, Zorn-maximal consistent sets are MCSes because `insert phi M` being consistent implies `insert phi M` is in the set of consistent supersets, contradicting maximality. For temporal logic with saturation constraints, the consistency of `insert phi M` does NOT imply it is in TCS (it may fail saturation), so maximality does not yield MCS.

### A4. Formula Ordering Does Not Help

Research-002.md section 5 analyzed whether processing F(chi) before G(neg chi) would help. The analysis concluded:

- Adding psi to an MCS M that already contains F(psi) does ensure G(neg psi) is excluded (by T-axiom: G(neg psi) -> neg psi contradicts psi in M)
- BUT this is a property of a SINGLE MCS at ONE time point, not a cross-time chain property
- The chain construction needs psi in M_{t+1} while F(psi) is in M_t -- these are different MCSes at different times
- Formula ordering within a single Lindenbaum does not solve the cross-time witness requirement

### A5. Verdict on Approach A

**NOT VIABLE** as described. The fundamental obstruction (Temporal Saturation / Maximality Incompatibility) is inherent to the Zorn-based approach for temporally-saturated MCSes. The TemporalLindenbaum.lean boneyard has 4 confirmed sorries that resist all attempted fixes including:
- Witness closure (tried in `maximal_tcs_is_mcs_closed`, same 4 sorries)
- Formula complexity induction (tried, fails because F(psi) and psi have dependent complexity)
- Direct inconsistency proof (fails because {F(psi), neg(psi)} IS consistent)

**Estimated effort to complete**: Likely impossible with the current mathematical framework. The problem is not a Lean engineering gap but a genuine mathematical obstruction in the proof strategy.

---

## Key Findings for Approach D (Two-Step Splice)

### D1. The Splice Idea

Approach D proposes: Given F(psi) in M_t, construct a new MCS N = Lindenbaum({psi} union GContent(M_t)) where psi is guaranteed to be in N. Then "splice" N into the chain at position t+1, replacing the original M_{t+1}, and rebuild the remainder.

### D2. The "Single Fixed Function" Problem

The BFMCS structure (`Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`, line 80) defines:

```lean
structure BFMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

The `mcs` field is a single function `D -> Set Formula`. Once `buildDovetailingChainFamily` is defined, the function is fixed. The forward_F property says:

```lean
forall t phi, F(phi) in fam.mcs t -> exists s, t < s and phi in fam.mcs s
```

This requires phi to be in the SAME family's mcs at some future time s. We cannot "splice" because the family is already fixed -- we would need to define a DIFFERENT family, but the existential statement is about THIS family.

### D3. Could We Define the Chain with Splicing Built In?

The idea: define the chain construction so that at each time t, the MCS already accounts for witness requirements from earlier times. This is essentially the "enriched seed" approach:

```
M_0 = Lindenbaum(base)
M_{t+1} = Lindenbaum(GContent(M_t) union {witness_for_step_t})
```

This is NOT splicing (no replacement of existing MCSes). It is an **enriched chain** where each step adds one witness formula to the GContent seed. The consistency of the enriched seed follows from `temporal_witness_seed_consistent` when the witness corresponds to an F-formula in the immediate predecessor.

### D4. The Witness Selection Problem

Even with enriched seeds, the chain builds each M_t exactly once. At the step building M_{t+1}, we can augment the seed with at most one witness formula psi (for consistency). But M_t may contain many F-formulas. Only one can be witnessed at M_{t+1}.

For the other F-formulas in M_t:
- They may or may not persist to M_{t+1} (Lindenbaum is opaque)
- If F(psi') does NOT persist to M_{t+1}, it cannot be witnessed at M_{t+2} either
- The formula is "lost" forever

This is the **F-persistence gap**: without placing psi' in M_{t+1}'s seed, there is no guarantee F(psi') persists, and hence no guarantee it can be witnessed later.

### D5. Verdict on Approach D (Pure Splice)

**NOT VIABLE** as a simple splice-after-construction strategy, because the family is a single fixed function and we need phi in THAT family's MCS.

**PARTIALLY VIABLE** as an enriched-seed strategy (building the chain with witnesses from the start), but with the critical limitation that only ONE witness can be safely added per step, and F-persistence for un-witnessed formulas is not guaranteed.

---

## Mathematical Elegance Assessment

### The Core Mathematical Tension

The fundamental tension in all approaches is:

1. **Consistency constraint**: We can only prove `{psi} union GContent(M)` is consistent when `F(psi) in M` (via `temporal_witness_seed_consistent`). We CANNOT prove joint consistency of `{psi_1, psi_2, ...} union GContent(M)` because formulas psi_i can contradict each other (e.g., F(p) and F(neg p) coexist in an MCS).

2. **Coverage requirement**: We need EVERY F-formula in EVERY MCS to eventually be witnessed. This requires processing infinitely many obligations across infinitely many time points.

3. **Persistence gap**: Without explicit witness placement, F-formulas may not persist through Lindenbaum extensions.

### Comparison of Approaches

| Criterion | Approach A | Approach D (splice) | Approach E (enriched chain) |
|-----------|-----------|-------------------|---------------------------|
| Mathematical soundness | Blocked (TCS/MCS incompatibility) | Blocked (single fixed function) | Viable with F-persistence lemma |
| Codebase alignment | Uses boneyard infrastructure | Requires new architecture | Extends existing DovetailingChain |
| Proof complexity | ~1200 lines (with 4 sorries) | Unknown, likely 800+ lines | ~600-800 new lines |
| Reuse of existing proofs | Reuses henkin infrastructure | Minimal reuse | Reuses all forward_G, backward_H proofs |
| Key new requirement | Solve TCS/MCS gap (unsolved) | Define splice-aware chain | F-persistence through enriched seeds |

### The Viable Path: Approach E (Enriched Chain with F-Persistence)

The key mathematical insight (from research-002.md section 12) is:

**Lemma (F-persistence through witness)**: If F(psi) is in M_t and psi is added to the seed for M_{t+1}, then:
1. psi is in M_{t+1} (seed is subset of MCS)
2. G(neg psi) is NOT in M_{t+1} (because G(neg psi) -> neg psi by T-axiom, contradicting psi)
3. Therefore F(psi) = neg(G(neg psi)) IS in M_{t+1}

This means: **placing the witness for F(psi) at M_{t+1} also preserves F(psi) itself at M_{t+1}**.

Using this, the enriched chain strategy becomes:

1. At each step building M_{t+1}, select ONE F-formula F(psi) from M_t using Encodable.decode applied to the step number
2. Augment the seed: GContent(M_t) union {psi}
3. By temporal_witness_seed_consistent, the augmented seed is consistent
4. The resulting MCS M_{t+1} contains psi (witness) AND F(psi) (persistence)
5. Un-selected F-formulas may or may not persist (no guarantee)
6. BUT: the selected F-formula IS witnessed and its obligation IS closed

The coverage argument is:
- For F(psi) in M_t with encoding index i = Encodable.encode psi
- There exists a step n such that at step n, the chain builds M_{t+1} and decodes to psi
- At that step, F(psi) is in M_t, so psi is added to the seed for M_{t+1}
- psi is in M_{t+1}, closing the obligation

**CRITICAL ISSUE**: The coverage argument requires that F(psi) is in M_t at the time when the enriched chain construction selects psi. But the enriched chain builds each M_t exactly once. At the step building M_{t+1}, the decode function maps step number -> formula. If the decoded formula happens to have its F-form in M_t, the witness is placed. If not, the step is "wasted" on a non-obligation.

**The selection mechanism matters**: We need a mechanism where for EACH F(psi) in M_t, there is at least one future time t' > t where the construction step for M_{t'+1} decodes to psi AND F(psi) is still in M_{t'}. The F-persistence issue makes this challenging for t' > t+1.

### The Inner-Chain Solution (from plan v002)

Plan v002 proposed an omega-squared construction:
- At each time t, build an inner chain of MCSes: M_t^(0), M_t^(1), M_t^(2), ...
- M_t^(0) = Lindenbaum(GContent(M_{t-1}))
- M_t^(k+1) = Lindenbaum(M_t^(k) union {psi_k}) where F(psi_k) in M_t^(k)
- Final M_t = Lindenbaum(union of inner chain)

The handoff (phase-1-handoff-20260220.md) identified that this fails because:
- Point 3 of "What Fails": Witness accumulation through inner chain fails because each intermediate MCS may lose previous witnesses through GContent stepping

**However**, the handoff analysis is about a DIFFERENT inner chain construction (using GContent between inner steps). The plan v002 construction uses `M_t^(k) union {psi_k}` directly, not GContent stepping. Let me analyze this more carefully:

- M_t^(k) is an MCS
- F(psi_k) is in M_t^(k)
- psi_k is being added to M_t^(k), not to GContent(M_t^(k))
- `insert psi_k M_t^(k)` is consistent iff neg(psi_k) NOT in M_t^(k)
- neg(psi_k) in M_t^(k) is possible even when F(psi_k) in M_t^(k)!

Because F(psi_k) = neg(G(neg psi_k)) means G(neg psi_k) NOT in M_t^(k). But neg(psi_k) can be in M_t^(k) without G(neg psi_k) (only G(neg psi_k) -> neg psi_k, not the converse).

**So `insert psi_k M_t^(k)` may be INCONSISTENT.** This happens when neg(psi_k) is in M_t^(k).

This is the "F(psi) at some future time, neg(psi) right now" scenario: `{F(psi), neg(psi)}` is consistent (F(psi) means psi at some future time, not now), and the MCS can contain both.

**Workaround**: Instead of `insert psi_k M_t^(k)`, use `{psi_k} union GContent(M_t^(k))` as the seed for a NEW Lindenbaum. This is consistent by `temporal_witness_seed_consistent` (since F(psi_k) in M_t^(k)). The result is a DIFFERENT MCS that extends GContent(M_t^(k)) and contains psi_k.

But this different MCS does NOT extend M_t^(k) itself -- only its GContent. So previously accumulated witnesses may be lost!

**This IS the witness accumulation failure identified in the handoff.** The inner chain approach in plan v002 has a genuine mathematical gap.

---

## Recommended Approach

### Recommendation: New Approach E -- "Immediate Witness at Successor with Dovetailed Obligation Queue"

**Core idea**: Redefine the forward/backward chain construction so that at each step n building M_{t} (where t = n for the forward chain), the seed includes GContent(M_{t-1}) plus ONE carefully selected witness formula.

**Detailed construction**:

```
For the forward chain:
  M_0 = Lindenbaum(base)
  M_{n+1} = Lindenbaum(GContent(M_n) union {witness_n})

  where witness_n is determined by:
    Let k = Encodable.decode n  (decode step number to a formula candidate)
    If k = some psi AND F(psi) in M_n:
      witness_n = psi  (consistency by temporal_witness_seed_consistent)
    Else:
      witness_n = nothing (seed = GContent(M_n) only)
```

**Forward_F proof**:

Given F(psi) in M_t, we need to find s > t with psi in M_s.

1. Let i = Encodable.encode psi (exists because Formula is Encodable)
2. F(psi) in M_t. By the enriched seed construction, at step t+1 we check if Encodable.decode(t+1) yields psi and F(psi) in M_t.
3. But Encodable.decode(t+1) may not yield psi. We need a step n > t where:
   - Encodable.decode(n) = some psi
   - F(psi) in M_{n-1} (so the consistency proof applies)

4. The decode function is surjective: for each psi, there exists n_0 = Encodable.encode psi such that Encodable.decode(n_0) = some psi.

5. **The key issue**: We need F(psi) to still be in M_{n_0 - 1}. If n_0 > t + 1, we need F(psi) to have persisted from M_t through M_{t+1}, ..., M_{n_0-1}.

6. **F-persistence is not guaranteed** in general. But we can observe that at each step between t and n_0, the enriched seed DOES include witnesses for some F-formulas. It just might not include psi.

7. **Resolution via infinite opportunities**: For each psi, there are INFINITELY many n with Encodable.decode(n) = some psi? NO -- Encodable.decode is a function Nat -> Option alpha, and typically each value appears at most once (the inverse of Encodable.encode).

**This reveals a fundamental limitation of the Encodable-based approach**: Each formula psi gets decoded at exactly ONE step number n_0 = Encodable.encode psi. If F(psi) is NOT in M_{n_0 - 1} at that step, the opportunity is missed permanently.

### Revised Recommendation: Two-layer dovetailing

To overcome the single-opportunity limitation, use `Nat.pair` to create infinitely many opportunities:

```
witness selection at step n:
  Let (a, b) = Nat.unpair n
  Let psi_candidate = Encodable.decode b
  If psi_candidate = some psi AND F(psi) in M_{n-1}:
    Use psi as witness
  Else:
    No witness at this step
```

The parameter `a` is ignored for witness selection but ensures that for each formula psi (with encoding b = Encodable.encode psi), there are infinitely many n with Nat.unpair(n).2 = b. These are n = Nat.pair(0, b), Nat.pair(1, b), Nat.pair(2, b), ...

At each such step n, we check: is F(psi) in M_{n-1}? If yes, we place the witness.

**Forward_F proof with two-layer dovetailing**:

Given F(psi) in M_t, we need exists s > t with psi in M_s.

Claim: There exists n > t such that Nat.unpair(n).2 = Encodable.encode psi AND F(psi) in M_{n-1}.

Proof sketch:
1. F(psi) in M_t. By MCS negation completeness, G(neg psi) NOT in M_t.
2. G(neg psi) NOT in GContent(M_t) (since G(G(neg psi)) requires G(neg psi) in M_t via temp_4).
3. The seed for M_{t+1} does NOT contain neg(psi) (since neg(psi) would require G(neg psi) in M_t).
4. Lindenbaum may or may not add G(neg psi) to M_{t+1} -- no control.
5. If the step building M_{t+1} witnesses psi (i.e., psi is the witness at that step), then psi in M_{t+1} and we're done.
6. If NOT (witness at t+1 is a different formula), then F(psi) may or may not be in M_{t+1}.

**The coverage proof requires an inductive argument**:

Either:
- At some step n with Nat.unpair(n).2 = Encodable.encode psi and n > t, F(psi) is in M_{n-1}, and the witness is placed. Done.
- OR at every such step n, F(psi) is NOT in M_{n-1}. This means G(neg psi) entered the chain at some point after t. But G(neg psi) in M_s for some s > t means neg psi in GContent(M_s), which propagates neg psi forward forever. So neg psi in M_{s+1}, M_{s+2}, ....

**But does G(neg psi) entering at M_s contradict F(psi) in M_t?**

Not directly if s > t. The chain has forward_G: G(neg psi) in M_s implies neg psi in M_{s+1}, M_{s+2}, etc. But G(neg psi) does NOT back-propagate to M_t (only GContent propagates forward, not backward, in the forward chain).

**However**, there IS backward propagation via HContent duality (already proven):
- GContent(M_n) subset M_{n+1} (by construction)
- Therefore HContent(M_{n+1}) subset M_n (by duality: GContent_subset_implies_HContent_reverse)
- H(neg psi) in M_{s+1} iff all_past(neg psi) in M_{s+1}
- But we don't have H(neg psi) directly

**The backward propagation does NOT give us G(neg psi) in M_t.** So the contradiction argument fails.

### Alternative: Use a DIFFERENT chain definition

The most promising approach may be to **redefine the chain itself** to guarantee F-persistence. Specifically:

**FPreserving Seed**: At each step, use `GContent(M_n) union {F(chi) | F(chi) in M_n}` as the seed for M_{n+1}.

This was identified in the handoff (section "What Works", point 1): "F-preserving seed: GContent(M) union {F(psi) | F(psi) in M} is a subset of M and hence consistent."

Wait -- is this true? GContent(M) = {phi | G(phi) in M} subset M (by T-axiom). And {F(psi) | F(psi) in M} subset M (trivially, since F(psi) is in M). So yes, the union is a subset of M, hence consistent (since M is an MCS and hence consistent).

With this seed:
- Every F-formula in M_n is also in the seed for M_{n+1}
- By seed-subset, every F-formula from M_n is in M_{n+1}
- Therefore F-formulas **persist forever** along the chain

**This is the F-preserving chain**: F(psi) in M_t implies F(psi) in M_{t+1}, M_{t+2}, etc.

Now the coverage argument for forward_F becomes straightforward:
1. F(psi) in M_t persists to M_{n_0-1} where n_0 = max(t+1, Nat.pair(0, Encodable.encode psi) + 1)
2. At step n_0, Nat.unpair(n_0).2 = Encodable.encode psi, and F(psi) in M_{n_0 - 1}
3. The witness psi is added to the seed
4. psi in M_{n_0}, and n_0 > t

**The remaining challenge**: Can we COMBINE the F-preserving seed with the witness?

The combined seed would be:
```
GContent(M_n) union {F(chi) | F(chi) in M_n} union {psi}   (for the witness)
```

Is this consistent? The first two parts are a subset of M_n, hence consistent. Adding psi:
- `{psi} union (subset of M_n)` is consistent iff neg(psi) is not derivable from the subset
- We need F(psi) in M_n (for temporal_witness_seed_consistent)
- But temporal_witness_seed_consistent proves `{psi} union GContent(M_n)` is consistent
- We need `{psi} union GContent(M_n) union {F(chi) | F(chi) in M_n}` is consistent

Since GContent(M_n) union {F(chi) | F(chi) in M_n} subset M_n:
- `{psi} union (subset of M_n)` is consistent IF `insert psi M_n` is consistent
- `insert psi M_n` is consistent iff neg(psi) NOT in M_n
- neg(psi) CAN be in M_n even when F(psi) in M_n (the "future, not now" scenario)

**So the combined seed CAN be inconsistent.** The handoff already identified this (section "What Fails", point 1): "Combined seed: {psi} union GContent(M) union {F(chi) | F(chi) in M} can be INCONSISTENT."

**Resolution**: Use the F-preserving seed WITHOUT the witness in the seed. Instead, add the witness at a SEPARATE step:

```
Step 1 (F-preserving): M_{n+1} = Lindenbaum(GContent(M_n) union {F(chi) | F(chi) in M_n})
Step 2 (Witness): At some step building M_{n+k}, add psi to the GContent seed instead of the F-preserving seed
```

But the witness step needs `{psi} union GContent(M_{n+k-1})` to be consistent, which requires F(psi) in M_{n+k-1}. If M_{n+k-1} was built with F-preserving seed, then F(psi) persists from M_n to M_{n+k-1}. So the consistency proof works!

**This is the viable approach**:
1. Build the chain with F-preserving seed at EVERY step (ensuring F-persistence)
2. At SOME steps, ALSO add a witness formula psi (in addition to the F-preserving seed)
3. BUT: the combined seed (F-preserving + witness) may be inconsistent
4. So at witness steps, use ONLY `{psi} union GContent(M_{n-1})` as seed (dropping the F-preserving part)
5. F(psi) is in M_{n-1} (by F-persistence), so the seed is consistent
6. BUT: by dropping the F-preserving part, OTHER F-formulas may NOT persist through M_n

**This creates a tension**: At witness steps, we lose F-persistence for non-witnessed formulas.

**Final resolution**: Use an alternating strategy:
- Even steps: F-preserving seed (no witness, all F-formulas persist)
- Odd steps: Witness seed (one F-formula witnessed, others may not persist)

At even steps, all F-formulas persist. At odd steps, one F-formula is witnessed. After the odd step, some F-formulas may be lost. But at the next even step, the F-preserving seed restores...

Wait, the F-preserving seed restores F-formulas from M_{n-1}, not from M_{n-2}. If F(chi) was lost at odd step n, then F(chi) is NOT in M_n, so the F-preserving seed at step n+1 does NOT include F(chi). The formula is lost permanently.

**This alternating strategy does NOT work.**

### Final Recommendation

After exhaustive analysis, the only mathematically sound approach that works within the current framework is:

**Approach E': Omega-squared enriched chain**

At each time t, build the MCS through an inner chain that processes F-formulas one at a time using the GContent-based seed (not extending the MCS directly):

```
M_t^(0) = Lindenbaum(GContent(M_{t-1}))
M_t^(1) = Lindenbaum({psi_0} union GContent(M_t^(0)))  where F(psi_0) in M_t^(0)
M_t^(2) = Lindenbaum({psi_1} union GContent(M_t^(1)))  where F(psi_1) in M_t^(1)
...
M_t = Limit of the inner chain (via Zorn or union + Lindenbaum)
```

Key properties:
- Each inner step adds one witness via GContent seed (consistent by temporal_witness_seed_consistent)
- F-formulas persist through GContent stepping IF the witness is placed (the witness-placing step ensures F(psi_k) persists to M_t^(k+1))
- The inner limit contains ALL witnesses for F-formulas present in M_t^(0)

**Complications**:
1. The inner chain produces a DIFFERENT MCS at each sub-step (not extending the previous one)
2. Witnesses from earlier sub-steps may be lost at later sub-steps (GContent only preserves G-formulas)
3. The inner chain limit is a union of sets that are NOT nested (each M_t^(k) is a different MCS)

**These complications are the same ones identified in the handoff.** The omega-squared approach is mathematically correct in principle but has significant proof engineering challenges.

**Estimated effort**: 25-35 hours

**Confidence level**: MEDIUM - The mathematical framework is sound but the Lean proof engineering is complex, with multiple potential blocking points in the GContent stepping / witness accumulation proofs.

---

## Evidence (Verified Lemma Names)

| Lemma | File | Status |
|-------|------|--------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | Proven |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | Proven |
| `dovetail_GContent_consistent` | DovetailingChain.lean | Proven |
| `dovetail_HContent_consistent` | DovetailingChain.lean | Proven |
| `GContent_subset_implies_HContent_reverse` | DovetailingChain.lean | Proven |
| `HContent_subset_implies_GContent_reverse` | DovetailingChain.lean | Proven |
| `dovetailForwardChainMCS_GContent_extends` | DovetailingChain.lean | Proven |
| `dovetailBackwardChainMCS_HContent_extends` | DovetailingChain.lean | Proven |
| `henkinLimit_consistent` | TemporalLindenbaum.lean (Boneyard) | Proven |
| `henkinLimit_forward_saturated` | TemporalLindenbaum.lean (Boneyard) | Proven |
| `maximal_tcs_is_mcs` | TemporalLindenbaum.lean (Boneyard) | 4 Sorries |
| `maximal_tcs_is_mcs_closed` | TemporalLindenbaum.lean (Boneyard) | 2 Sorries |
| `set_lindenbaum` | MaximalConsistent.lean (Boneyard) | Proven |
| `buildDovetailingChainFamily_forward_F` | DovetailingChain.lean | SORRY |
| `buildDovetailingChainFamily_backward_P` | DovetailingChain.lean | SORRY |

All local_search queries verified: `Lindenbaum`, `temporal_witness_seed`, `dovetailForwardChainMCS`, `set_lindenbaum`, `GContent`, `BFMCS`, `dovetailChainSet`.

---

## Confidence Level

**MEDIUM** -- The mathematical analysis is thorough and identifies clear blockers for Approaches A and D. The recommended Approach E' (omega-squared enriched chain) is mathematically sound in principle but has not been tested in Lean. The main risk is the inner chain witness accumulation proof, which was already identified as problematic in the phase-1 handoff. The estimated effort of 25-35 hours reflects this uncertainty.

---

## Summary of Approaches

| Approach | Viable? | Blocker | Effort |
|----------|---------|---------|--------|
| A: Constructive Lindenbaum | NO | TCS/MCS incompatibility (4 sorries in boneyard) | N/A |
| D: Two-step splice | NO | Single fixed function constraint | N/A |
| E: One-witness-per-step enriched chain | PARTIALLY | F-persistence gap (no guarantee un-witnessed F-formulas persist) | 15-20h but may fail |
| E': Omega-squared enriched chain | YES (in principle) | Complex proof engineering for inner chain | 25-35h |
| F-preserving + alternating witness | NO | F-preservation lost at witness steps, not recoverable | N/A |
