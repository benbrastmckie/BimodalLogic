# Teammate A Findings: Seed Unraveling Before Lindenbaum Maximization

**Task**: 81 -- F/P Witness Representation Theorem
**Focus**: Mathematical foundations of stepwise seed construction
**Date**: 2026-04-01

## Key Findings

### 1. The Problem Restated Precisely

The current construction builds a fixed Z-indexed chain where step n+1 is determined by `witness_forward_default_step` (targeting `neg bot`). Each step:

1. Extends DRM u to full MCS M via `set_lindenbaum`
2. Gets witness W from `temporal_theory_witness_exists` (with target, G-agree, box-agree)
3. Takes W intersect deferralClosure as seed
4. Applies `deferral_restricted_lindenbaum` (Zorn) to get DRM v

The problem: step 4 (Zorn/Lindenbaum maximization) is unconstrained within deferralClosure. It may add G(neg psi) for some formula psi that a DIFFERENT F-obligation needs resolved later. Once G(neg psi) enters the chain, it persists forward (by G-persistence), making psi permanently blocked.

This is NOT a problem for ONE targeted successor (build_targeted_successor is sorry-free). It becomes a problem when trying to satisfy ALL F-obligations along a FIXED chain.

### 2. Finite Enumeration Approach

deferralClosure(phi) is a `Finset Formula` (defined at `SubformulaClosure.lean:702`):

```
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
```

Since deferralClosure is finite, we can replace Zorn's lemma with finite induction over its elements. The construction becomes:

**Finite Lindenbaum for DeferralRestrictedMCS:**
Given a consistent seed S subset of deferralClosure(phi), enumerate deferralClosure(phi) as {chi_1, ..., chi_N}. Define:

```
S_0 = S
S_{i+1} = if (S_i union {chi_{i+1}} is consistent) then S_i union {chi_{i+1}} else S_i
```

The result S_N is:
- Consistent (each step preserves consistency)
- DeferralRestricted (only adds elements from deferralClosure)
- Maximal within deferralClosure (for any chi in deferralClosure, either chi in S_N or insert chi S_N is inconsistent)

This is equivalent to `deferral_restricted_lindenbaum` but constructive (no Zorn). In Lean 4, we would use `Finset.fold` or recursion over the list of elements.

**Key advantage**: The enumeration ORDER can be chosen strategically.

### 3. F-Preservation During Stepwise Construction

The user's insight is that we should control WHICH formulas get added during maximization. The critical constraint:

**F-Safe Maximization**: When deciding whether to add chi_{i+1}, reject it not only when it causes inconsistency, but also when it would block a future F-obligation.

Formally, given a set of "protected targets" T = {psi_1, ..., psi_k} (formulas that must eventually appear in some future chain element):

```
S_{i+1} = if (S_i union {chi_{i+1}} is consistent) AND
             (chi_{i+1} does not have the form G(neg psi_j) for any psi_j in T)
          then S_i union {chi_{i+1}}
          else S_i
```

**However, this is problematic.** The resulting S_N may not be maximal in the standard sense. If we skip G(neg psi_j), we need neg(G(neg psi_j)) to be in S_N for negation completeness. And neg(G(neg psi_j)) = F(psi_j) (by duality), which IS in the seed already (from F-obligations). So consistency is maintained, but we need to verify that the "skipping" doesn't leave the set sub-maximal in a way that breaks other properties.

**Better approach**: Rather than modifying the maximization, ensure the SEED already contains enough information to prevent harmful maximization. Specifically:

If we include F(psi) in the seed for every F-obligation we want to preserve, then maximality forces: either G(neg psi) or neg(G(neg psi)) = F(psi) is in the DRM. Since F(psi) is already in the seed (and hence in the DRM), the DRM cannot also contain G(neg psi) (by consistency). So G(neg psi) is automatically excluded.

**This is the crucial insight: including F-obligations in the seed prevents Lindenbaum from adding their G-negations.**

### 4. The Right Seed and Ordering

The seed for building the successor of DRM u should be:

```
seed(u) = W ∩ deferralClosure(phi)
```

where W is the full MCS witness from `temporal_theory_witness_exists`. This seed already contains:

- **target** (the specific F-obligation being resolved at this step)
- **All G(a) where G(a) in M** (by G-agree, and M extends u)
- **All G(a) from g_content(u)** (since u subset M, G(a) in u implies G(a) in M implies G(a) in W)

But critically, W is a FULL MCS. It has already made all consistency decisions. So W intersect deferralClosure contains ALL the formulas from deferralClosure that are true in W. This includes:

- All deferralDisjunctions that are theorems (since W is an MCS, it contains all theorems, hence all deferralDisjunctions that are provable)
- The correct choices for every formula in deferralClosure

**The key question**: Does W contain enough F-obligations?

W is obtained from `temporal_theory_witness_exists` applied to M (the Lindenbaum extension of u). W has:
- G-agree with M: G(a) in M implies G(a) in W
- target in W

But W may or may not contain F(psi) for other F-obligations psi. Since W is an arbitrary MCS extending {target} union temporal_box_seed(M), it might contain G(neg psi_2) for some other F-obligation F(psi_2) in u.

**This is exactly the original problem**, just pushed to the W level. The witness W from `temporal_theory_witness_exists` resolves ONE F-obligation (target) but may poison others.

### 5. The Real Solution: Enriched Witness Seed

The fundamental fix is to construct W from a RICHER seed that includes ALL F-obligations simultaneously. Instead of:

```
witness_seed = {target} ∪ temporal_box_seed(M)
```

Use:

```
enriched_seed = {psi | F(psi) ∈ u, psi ∈ deferralClosure(phi)} ∪ temporal_box_seed(M)
```

This enriched seed includes ALL the F-targets that are in u (restricted to deferralClosure). If this enriched seed is consistent, then its Lindenbaum extension W_enriched would contain ALL the F-targets, and W_enriched intersect deferralClosure would already have the F-obligations protected.

**Consistency of the enriched seed**: This is the critical proof obligation. We need:

```
Consistent({psi_1, ..., psi_k} ∪ temporal_box_seed(M))
```

where F(psi_i) ∈ M for all i, and temporal_box_seed(M) = {G(a) | G(a) ∈ M} ∪ {Box(b) | Box(b) ∈ M}.

**Proof technique**: Use M as a consistency witness. We need that M cannot derive a contradiction from these formulas. Since F(psi_i) ∈ M and M is an MCS, M is consistent. By temp_t_future: G(a) → a, so a ∈ M for all a in temporal_box_seed. But psi_i may NOT be in M (M contains F(psi_i), not psi_i).

This is where the proof gets delicate. The standard argument is:

Suppose {psi_1, ..., psi_k} ∪ temporal_box_seed(M) is inconsistent. Then:
  temporal_box_seed(M) ⊢ neg(psi_1 ∧ ... ∧ psi_k)

By necessitation and distribution:
  G(temporal_box_seed(M)) ⊢ G(neg(psi_1 ∧ ... ∧ psi_k))

Since G(x) ∈ M for all x in temporal_box_seed:
  M ⊢ G(neg(psi_1 ∧ ... ∧ psi_k))

But F(psi_i) ∈ M for all i, and by temporal logic:
  F(psi_1) ∧ ... ∧ F(psi_k) → F(psi_1 ∧ ... ∧ psi_k)

Wait -- this is FALSE. F distributes over disjunction, not conjunction. F(A) ∧ F(B) does NOT imply F(A ∧ B). We might satisfy F(A) at time 5 and F(B) at time 10, but never A ∧ B at any single time.

**Therefore, the enriched seed with ALL F-targets simultaneously is NOT necessarily consistent.**

### 6. The Correct Approach: One-at-a-Time Resolution with F-Inclusion

Since we cannot include all F-targets simultaneously, the correct approach is:

**Step-by-step chain construction with F-obligation tracking:**

Given DRM u_0 with F-obligations {F(psi_1), ..., F(psi_k)} (finite, since deferralClosure is finite):

1. At step 1: Build successor u_1 targeting psi_1. The seed for u_1 comes from W_1 (witness for psi_1). Include in the seed not just W_1 intersect deferralClosure, but also ensure all remaining F-obligations {F(psi_2), ..., F(psi_k)} are in the seed (they are in deferralClosure since F(psi_i) ∈ deferralClosure when F(psi_i) ∈ u_0 and u_0 is DeferralRestricted).

2. At step 2: u_1 may have new F-obligations. But the KEY PROPERTY of deferralClosure is that it is CLOSED under the deferral operation. If F(psi) ∈ u_1 and F(psi) ∈ deferralClosure, then either psi ∈ u_1 (resolved) or F(psi) ∈ u_1 (deferred). The deferralDisjunction psi ∨ F(psi) ensures this.

3. Since deferralClosure is finite, there are only finitely many possible F-obligations. The key insight from bounded F-nesting (`deferral_restricted_mcs_F_bounded` at RestrictedMCS.lean:1127) is that for each formula psi, the iteration F^d(psi) must eventually leave deferralClosure. So the "deferral" cannot continue indefinitely.

**But this is exactly the existing argument** (from SimplifiedChain.lean), which hits the same problem: Lindenbaum at each step can introduce G(neg psi_j) for future obligations.

### 7. The User's Actual Insight: Constructive Finite Maximization with Consistency Guard

Re-reading the user's statement: "the seed must be carefully unraveled before any maximization goes on, checking only consistency after each step unraveling the seed."

This suggests a DIFFERENT maximization procedure than standard Lindenbaum:

**Guarded Finite Lindenbaum**: Given consistent seed S within deferralClosure(phi), and a set of "protected formulas" P (the F-obligations and their consequences):

```
Enumerate deferralClosure as chi_1, ..., chi_N
S_0 = S
For i = 1 to N:
  if chi_i ∈ S_{i-1}: skip (already decided)
  if neg(chi_i) ∈ S_{i-1}: skip (negation already decided)
  if S_{i-1} ∪ {chi_i} is consistent:
    S_i = S_{i-1} ∪ {chi_i}
  else:
    S_i = S_{i-1} ∪ {neg(chi_i)}   -- if neg(chi_i) ∈ deferralClosure
    OR S_i = S_{i-1}               -- if neg(chi_i) ∉ deferralClosure
```

The "unraveling" happens by processing formulas in a SPECIFIC ORDER:

**Phase 1**: Add all g_content formulas {a | G(a) ∈ u}. These are guaranteed consistent with any seed derived from a G-agreeing witness.

**Phase 2**: Add all F-obligations we want to PRESERVE. For each F(psi) ∈ u with F(psi) ∈ deferralClosure, add F(psi) to the seed. Since F(psi) ∈ u and u is consistent, and g_content is already in the seed (and is consistent with u), this should be consistent step by step. The consistency witness is u itself: u contains both g_content elements and F(psi).

**Phase 3**: Add target psi (the specific formula being resolved at this step). Consistency: the witness W from temporal_theory_witness_exists contains psi, all G-formulas, and is consistent.

**Phase 4**: Add deferralDisjunctions. These are theorems (provable from F(chi) → chi ∨ F(chi)), so adding them to any consistent set preserves consistency.

**Phase 5**: Maximize remaining undecided formulas (standard Lindenbaum on what's left).

**The critical point**: After Phase 2, every F(psi) from u is already in the partially built set. When Phase 5 runs Lindenbaum, it CANNOT add G(neg psi) because that would be inconsistent with F(psi) (since F(psi) and G(neg psi) are contradictory: F(psi) says psi holds sometime in the future, G(neg psi) says neg psi holds at ALL future times).

**Formal contradiction**: F(psi) ∧ G(neg psi) is inconsistent. Proof:
- F(psi) ∧ G(neg psi) implies there exists a future time where psi holds AND neg psi holds at all future times
- The temp_k_future axiom gives: G(neg psi) → neg F(psi), i.e., G(a) → neg F(neg a) specialized to a = neg psi
- Actually: G(neg psi) ⊢ neg F(psi) is a theorem of minimal temporal logic
- So {F(psi), G(neg psi)} ⊢ bot

This means: **if F(psi) is in the seed, G(neg psi) can never be added by Lindenbaum** (it would create inconsistency).

### 8. Consistency of the Phased Seed

The critical proof obligation is that Phases 1-4 produce a consistent set. Let me analyze each:

**Phase 1** (g_content): Elements a where G(a) ∈ u. Since u is consistent and g_content(u) ⊆ u (via T-axiom G(a) → a), this is a subset of u, hence consistent.

**Phase 2** (F-obligations): Adding F(psi_1), ..., F(psi_k) where each F(psi_i) ∈ u. The set g_content(u) ∪ {F(psi_1), ..., F(psi_k)} is a subset of u (since each F(psi_i) ∈ u and g_content(u) ⊆ u). Hence consistent.

**Phase 3** (target): Adding psi where F(psi) ∈ u. The set g_content(u) ∪ {F(psi_1), ..., F(psi_k)} ∪ {psi} -- IS THIS consistent?

This is NOT necessarily a subset of u (psi may not be in u). But:
- W (from temporal_theory_witness_exists) contains psi and g_content(u) (by G-agree + T-axiom)
- W is consistent (it's an MCS)
- However, W may not contain all F(psi_i).

**This is the crux.** We need the set {psi, F(psi_2), ..., F(psi_k)} ∪ g_content(u) to be consistent. The consistency witness would need to be a set containing ALL of these. Neither u nor W is guaranteed to work:
- u contains F(psi_i) but not psi (the target)
- W contains psi but may not contain F(psi_i) for i >= 2

**Possible resolution**: We don't need target psi in the SEED. We need psi in the FINAL DRM. The MCS witness approach (build_targeted_successor) already handles this: W intersect deferralClosure contains psi, and Lindenbaum extends it. The issue was that Lindenbaum might add G(neg psi_2).

But with Phase 2 having already added F(psi_2) to the seed, Lindenbaum CANNOT add G(neg psi_2) -- contradiction with F(psi_2).

**So the correct decomposition is**:

- Seed = (W ∩ deferralClosure) ∪ {F(psi) | F(psi) ∈ u, F(psi) ∈ deferralClosure}
- This seed IS consistent because W ∩ deferralClosure is consistent (subset of consistent W), and adding F(psi_i) where F(psi_i) ∈ u:

Wait, F(psi_i) may not be in W. We need to show {formulas from W ∩ dC} ∪ {F-obligations from u} is consistent.

**Key lemma needed**: For any DRM u and witness W (from temporal_theory_witness_exists applied to Lindenbaum extension of u):

```
SetConsistent ((W ∩ deferralClosure(phi)) ∪ {F(psi) | F(psi) ∈ u ∧ F(psi) ∈ deferralClosure(phi)})
```

**Proof sketch**: Suppose this set is inconsistent. Then there exist formulas w_1, ..., w_m from W ∩ dC and F(psi_1), ..., F(psi_k) from u such that {w_1, ..., w_m, F(psi_1), ..., F(psi_k)} ⊢ bot.

Now, extend u to MCS M. M contains all F(psi_i). M extends to W via temporal witness. Consider the MCS M: it contains F(psi_i) for all i.

But we need w_j ∈ M too, which we DON'T know. The w_j are from W, not necessarily from M.

**This approach needs more work.** The fundamental difficulty is that W and u/M are different MCS with potentially conflicting decisions.

### 9. Alternative: Two-Phase Construction

A cleaner approach avoids enriching the seed and instead uses a TWO-PHASE construction:

**Phase A**: Build the successor DRM v using the standard construction (build_targeted_successor). v contains target and g_content(u).

**Phase B**: VERIFY that v preserves enough F-obligations. Specifically: for each F(psi) ∈ u with F(psi) ∈ deferralClosure, either psi ∈ v (resolved) or F(psi) ∈ v (deferred).

Phase B holds if v contains the deferralDisjunctions from u. The deferralDisjunction for F(psi) is: psi ∨ F(psi). Since this is a theorem (provable in the logic), and v is a DRM (hence contains all theorems restricted to deferralClosure), v DOES contain psi ∨ F(psi) whenever psi ∨ F(psi) ∈ deferralClosure.

By DRM maximality and the presence of the deferralDisjunction: either psi ∈ v or F(psi) ∈ v (since DRM has disjunction property for formulas in its closure, and psi ∨ F(psi) ∈ v implies one disjunct is in v by maximality).

**This means the existing construction ALREADY has the deferral property!**

The problem was never about individual steps -- each step correctly defers or resolves. The problem is about the FIXED chain: does the chain eventually resolve every F-obligation?

### 10. The Real Blocker: Fair Resolution in Fixed Chains

The actual mathematical issue is: in the fixed chain (witness_forward_chain), each step targets F(neg bot) = F_top. The deferral mechanism ensures that other F-obligations are deferred (F(psi) persists to the next step), but they are NEVER actively targeted.

The solution must be a chain that FAIRLY cycles through F-obligations. Since deferralClosure is finite, there are finitely many possible F-formulas. A fair chain would:

1. At step 0: Start with DRM u_0
2. At step 1: Target the first F-obligation in u_0 (by some enumeration of deferralClosure)
3. At step 2: Target the first unresolved F-obligation in u_1
4. Continue, cycling through obligations

Since there are finitely many F-formulas in deferralClosure, and each one either gets resolved or deferred, and the bounded F-nesting theorem (`deferral_restricted_mcs_F_bounded`) guarantees that deferral cannot continue indefinitely (F^d(psi) eventually leaves deferralClosure), every F-obligation is resolved within bounded steps.

**BUT**: This fair scheduling approach has been considered before (SuccChainFMCS.lean comment at line 51: "Fair-scheduling chain"). The challenge is that `build_targeted_successor` might introduce NEW F-obligations. However, since all formulas are in the finite deferralClosure, there are only finitely many possible F-obligations, and the bounded nesting theorem bounds how long each can defer.

**The question reduces to**: When we build a targeted successor resolving F(psi_1), does the successor's Lindenbaum step introduce G(neg psi_2) for some OTHER obligation F(psi_2)?

Answer: YES, it can. And THIS is what the "seed unraveling" is supposed to prevent.

## Recommended Approach

**Enriched-Seed Targeted Successor**: Modify `build_targeted_successor` to include ALL current F-obligations in the seed before Lindenbaum maximization.

The construction:
1. Given DRM u with F(psi_i) ∈ u (finitely many, all in deferralClosure)
2. Extend u to MCS M via set_lindenbaum
3. Get witness W from temporal_theory_witness_exists for specific target psi_1
4. Form enriched seed: (W ∩ deferralClosure) ∪ {F(psi) | F(psi) ∈ u ∧ F(psi) ∈ deferralClosure}
5. Prove enriched seed is consistent (KEY LEMMA -- see below)
6. Apply deferral_restricted_lindenbaum to enriched seed
7. Result: DRM containing psi_1 (from W) and all F(psi_i) (from enriched seed)
8. Lindenbaum CANNOT add G(neg psi_i) since F(psi_i) already present (contradiction)

**Key Lemma (consistency of enriched seed)**:

The enriched seed is a subset of:
- W (for the W ∩ deferralClosure part)
- u (for the {F(psi)} part, since F(psi) ∈ u)

We need: (W ∩ dC) ∪ {F(psi) | F(psi) ∈ u ∩ dC} is consistent.

**Proof strategy**: Suppose inconsistent. Then there exist L ⊆ enriched_seed with L ⊢ bot. Split L into L_W (from W) and L_u (F-formulas from u).

By deduction theorem: L_W ⊢ neg(conjunction(L_u)).

The elements of L_u are F(psi_i) formulas. Their conjunction's negation is: neg(F(psi_1) ∧ ... ∧ F(psi_k)) = G(neg psi_1) ∨ ... ∨ G(neg psi_k) (by temporal duality).

So: L_W ⊢ G(neg psi_1) ∨ ... ∨ G(neg psi_k).

Since L_W ⊆ W and W is an MCS: G(neg psi_1) ∨ ... ∨ G(neg psi_k) ∈ W.

By MCS disjunction property: G(neg psi_j) ∈ W for some j.

By G-agree (W G-agrees with M): this means... wait, G-agree goes M → W, not W → M. G(neg psi_j) ∈ W does not imply G(neg psi_j) ∈ M.

But: F(psi_j) ∈ u ⊆ M. And M is an MCS. So F(psi_j) ∈ M. But G(neg psi_j) → neg F(psi_j) is a theorem. If G(neg psi_j) ∈ M too, then neg F(psi_j) ∈ M, contradicting F(psi_j) ∈ M (M is consistent).

So G(neg psi_j) ∉ M. But G-agree says G(a) ∈ M → G(a) ∈ W. We have G(neg psi_j) ∈ W. This does NOT contradict anything -- G-agree is one-directional.

**However**: We can derive a contradiction within W itself. W contains F(psi_j)? Not necessarily. W was built to contain the target psi_1, not F(psi_j) for j >= 2.

**Updated assessment**: The consistency argument for the enriched seed does NOT go through easily with the current `temporal_theory_witness_exists`. The witness W is built for ONE target and has no obligation to be compatible with other F-formulas from u.

**Alternative approach**: Instead of enriching the seed with F-formulas from u, use u itself as partial consistency witness. Define:

```
f_preserved_seed(u) = {F(psi) | F(psi) ∈ u ∧ F(psi) ∈ deferralClosure(phi)}
```

Note that f_preserved_seed(u) ⊆ u. And g_content(u) ⊆ u. And target psi_1... is NOT in u (generally).

The set {psi_1} ∪ g_content(u) is consistent (by temporal_theory_witness_consistent, already proven sorry-free).

The set {psi_1} ∪ g_content(u) ∪ f_preserved_seed(u) -- is this consistent?

g_content(u) ∪ f_preserved_seed(u) ⊆ u (since both are subsets of u), so it is consistent. Adding psi_1: we need {psi_1} ∪ g_content(u) ∪ f_preserved_seed(u) consistent.

This is a SUPERSET of {psi_1} ∪ g_content(u) (which we know is consistent) and a SUPERSET of g_content(u) ∪ f_preserved_seed(u) ⊆ u (which is consistent). But supersets of consistent sets can be inconsistent.

**The needed lemma is essentially**: {psi_1} ∪ g_content(u) ∪ f_preserved_seed(u) is consistent, given F(psi_1) ∈ u.

This requires a GENERALIZATION of `temporal_theory_witness_consistent` to handle the enriched seed {psi_1} ∪ temporal_box_seed(M) ∪ {F(psi_2), ..., F(psi_k)}.

The G-lift argument works for {psi_1} ∪ temporal_box_seed(M). Adding F(psi_i) terms: these are in M. So any L ⊆ {psi_1} ∪ temporal_box_seed(M) ∪ {F(psi_2), ..., F(psi_k)} with L ⊢ bot would give (by separating the psi_1 part and G-lifting the temporal_box_seed part):

The G-lift gives: G(conjunction of temporal_box_seed elements) ∈ M. And F(psi_i) ∈ M. The issue is that F(psi_i) is not G-liftable (G(F(psi_i)) is NOT generally in M).

**This is exactly the obstruction identified in report 11.**

## Confidence Level

**MEDIUM** for the overall direction (enriching the seed with F-obligations is the right mathematical idea), **LOW** for having a complete consistency proof. The fundamental obstruction (non-G-liftability of F-formulas) means the standard proof technique fails, and a new consistency argument is needed.

## Evidence/Examples

The contradiction F(psi) ∧ G(neg psi) ⊢ bot is provable in the codebase:
- `temp_k_future` axiom: G(a) → neg F(neg a), i.e., G(neg psi) → neg F(neg neg psi)
- With double negation: G(neg psi) → neg F(psi)
- This is the standard temporal duality used in `RestrictedMCS.lean`

The finite nature of deferralClosure is established:
- `deferralClosure` returns `Finset Formula` (SubformulaClosure.lean:702)
- Bounded F-nesting: `deferral_restricted_mcs_F_bounded` (RestrictedMCS.lean:1127)

The existing sorry-free one-step construction:
- `build_targeted_successor` (MCSWitnessSuccessor.lean:221) -- resolves ONE obligation
- `temporal_theory_witness_exists` (UltrafilterChain.lean:2212) -- sorry-free witness

## Summary

1. **Finite enumeration**: Replacing Zorn with finite induction over deferralClosure is straightforward and gives control over ordering, but doesn't solve the problem by itself.

2. **F-preservation via seed inclusion**: Including F(psi_i) in the seed prevents Lindenbaum from adding G(neg psi_i). This is the CORRECT principle. The proof that F(psi) and G(neg psi) are contradictory is clean.

3. **Consistency of enriched seed**: This is the HARD part. The enriched seed {target} ∪ g_content(u) ∪ {F-obligations from u} mixes formulas from different sources (W and u). The standard G-lift technique fails because F-formulas are not G-liftable. A NEW consistency argument is needed.

4. **Relationship to literature**: This is closely related to the "step-by-step" or "systematic" Lindenbaum construction used in completeness proofs for temporal logics (e.g., Goldblatt's "Logics of Time and Computation," Reynolds' "An Introduction to Temporal Logic"). The standard technique there uses CANONICAL MODEL with ALL MCS simultaneously, avoiding the fixed-chain problem. Our DRM approach (working within finite deferralClosure) is non-standard and requires novel arguments.

5. **Most promising path**: The consistency argument might work by using u itself as witness. All elements of g_content(u) ∪ f_preserved_seed(u) are in u (consistent). The target psi_1 is consistent with g_content(u) (by temporal_theory_witness_consistent). The question is whether psi_1 is consistent with f_preserved_seed(u) given g_content(u) -- this might follow from a careful analysis of what `temporal_theory_witness_consistent` actually proves, potentially by generalizing its proof to include F-formulas in the seed.
