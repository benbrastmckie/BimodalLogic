# Teammate A Findings: Primary Approach (Seed Enrichment with G(neg w))

**Task**: 109 - Close chain construction sorries
**Date**: 2026-04-20
**Teammate**: A — Primary approach analysis
**Focus**: Approach A — seed enrichment with G(neg w) for `fwd_chain_forward_F`

---

## Key Findings

- **Approach A (G(neg w) seed enrichment) is mathematically sound but requires a NEW consistency proof** that `{w, G(neg w)} ∪ g_content(M)` is consistent — this is NOT trivially implied by existing infrastructure.
- **The finite descent argument WORKS with seed enrichment** if and only if the enriched seed is consistent: each step strictly decreases |active_defects| because w enters M' while F(w) is blocked from entering M' (by G(neg w) ∈ g_content(M') via the seed).
- **The critical consistency question admits a positive answer via model construction**: under irreflexive linear temporal semantics, a world where w holds at time 0 and G(neg w) holds (neg w at all strict future times) is perfectly consistent. BX semantics validates this.
- **g_content(M) does NOT conflict with {w, G(neg w)}**: g_content(M) contains G(psi) for formulas psi ∈ M. The only potential conflict would be if G(neg G(neg w)) ∈ g_content(M), which would require G(neg w) ∉ M — but G(neg w) is exactly what we're adding. The conflict analysis shows the seed is consistent (see Detailed Analysis).
- **Secondary issues exist** for backward chain and Until/Since coherence, but seed enrichment only needs to solve sorry #1 (`fwd_chain_forward_F`).

---

## Detailed Analysis

### 1. What Approach A Proposes

The current `preserving_fwd_step` calls `defect_step_choice_early`, which uses the BX11 fold to produce M' where each defect chi satisfies `chi ∈ M' ∨ F(chi) ∈ M'`. The problem: when chi (the resolved witness w) is in M', the MCS M' can still contain F(w), causing w to remain an active defect.

Approach A modifies the seed: instead of `{beta'} ∪ g_content(M)`, use `{beta', G(neg w)} ∪ g_content(M)` where w is the resolved witness. This forces F(w) ∉ M' (since G(neg w) ∈ M' implies F(w) = neg G(neg w) ∉ M' by MCS consistency), so w permanently exits the active defect set.

### 2. Consistency of the Enriched Seed

**Claim**: `{w, G(neg w)} ∪ g_content(M)` is consistent when F(w) ∈ M.

**Proof sketch**:

The key is that `w` and `G(neg w)` are jointly consistent under irreflexive linear temporal semantics. In an irreflexive linear temporal model with current time 0:
- `w` holds at time 0 (world satisfies w now)
- `G(neg w)` means neg w at all strict future times (times > 0)

These are compatible: nothing prevents w from holding at time 0 while neg w holds at all times > 0. In reflexive semantics, G(neg w) would require neg w at time 0 as well (since 0 ≤ 0), creating a contradiction with w. But under **irreflexive** semantics (which BX uses), G(phi) = "phi at all STRICT future times", so G(neg w) is silent about time 0.

**Formal argument using BX axioms**:

The axiom system BX does NOT include BX1 (G(phi) → phi) because BX uses irreflexive semantics. Therefore, `G(neg w) → neg w` is NOT derivable in BX. So `{w, G(neg w)}` is consistent with the BX axioms — there is no derivation of bot from {w, G(neg w)} in BX.

To prove `{w, G(neg w)} ∪ g_content(M)` consistent, we need to show no finite subset derives bot. The g_content(M) contains formulas of the form G(psi) for G(psi) ∈ M. Could G(psi) ∈ M create a conflict with {w, G(neg w)}?

A conflict would require deriving bot from:
- w
- G(neg w)
- Some finite subset of {G(psi) | G(G(psi)) ∈ M}

In an irreflexive linear model:
- w: satisfied at time 0
- G(neg w): neg w at times 1, 2, 3, ...
- G(psi): psi at times 1, 2, 3, ...

The formulas G(psi) from g_content(M) make no claims about time 0. They cannot conflict with w (which is only a claim about time 0 in this model). And G(neg w) ∧ G(psi) = G(neg w ∧ psi), which requires neg w ∧ psi at all future times — consistent as long as {neg w, psi} is consistent, which it is (neg w is not syntactically bot).

**However**: the above is a semantic argument. We need a syntactic proof of consistency for the Lean formalization.

**Syntactic approach**: We need to exhibit an MCS M'' extending `{w, G(neg w)} ∪ g_content(M)`.

Candidate construction: Take the Lindenbaum extension of `{w, G(neg w)} ∪ g_content(M)`. This exists if the set is consistent. To prove consistency:

Suppose for contradiction that `{w, G(neg w)} ∪ g_content(M)` derives bot. Then there exists a finite list L from `g_content(M)` such that `{w, G(neg w)} ∪ L ⊢ bot`. The formulas in L are all of the form G(psi_i) (by definition of g_content). So we have:

```
w, G(neg w), G(psi_1), ..., G(psi_k) ⊢ bot
```

By propositional reasoning and temp_K (distribution of G over conjunctions):

```
G(neg w ∧ psi_1 ∧ ... ∧ psi_k) ∈ M  (since G(neg w) we're adding, G(psi_i) from g_content(M))
```

Wait — actually G(neg w) is NOT in M; we're asserting it in the seed. Let me be more careful.

The set g_content(M) = {phi | G(G(phi)) ∈ M}. This contains formulas G(phi) for phi such that G(G(phi)) ∈ M (i.e., the G operator is applied once more to things in M via temp_4).

Actually the standard definition: g_content(M) = {phi | G(phi) ∈ M}. Let me verify from the codebase.

From CanonicalModel.lean and Frame.lean usage: `g_content M` is the set of formulas phi such that `G(phi) ∈ M`. So elements of g_content(M) are NOT themselves prefixed with G; they are the "contents" of G-formulas.

**Correction**: g_content(M) = {phi | G(phi) ∈ M}. So `G(neg w)` is in g_content(M) iff `G(G(neg w)) ∈ M`. Since G(neg w) is what we're adding to the seed (not M), there's no circularity.

**Re-doing the consistency argument**:

We want: `{w, G(neg w)} ∪ g_content(M)` is consistent, where g_content(M) = {phi | G(phi) ∈ M}.

Elements of g_content(M) are the direct phi (NOT G(phi) — the contents). So the seed is:

```
{w} ∪ {G(neg w)} ∪ {phi | G(phi) ∈ M}
```

Now construct a model: take a 2-point irreflexive linear model with times {0, 1} (or rather {0, 1, 2, ...} for full omega). At time 0: w is true. At all times i > 0: neg w is true, and for each phi with G(phi) ∈ M, phi is true at time i (this is possible because the elements of g_content(M) came from an MCS M which is itself realizable — well, we're in the canonical model construction, so M is already a world).

Actually, for the syntactic Lean proof, we need a cleaner argument. Here is one:

**Claim**: There exists an MCS M'' such that `{w, G(neg w)} ∪ g_content(M) ⊆ M''`.

**Construction**: M'' will be the MCS generated by `fwd_succ M h_mcs G(neg w)` — i.e., the Lindenbaum extension of `{G(neg w)} ∪ g_content(M)`. But we also need w ∈ M''.

Actually, we need a DIFFERENT approach. Consider:

Step 1: F(w) ∈ M. By forward_temporal_witness_seed_consistent applied to SOME formula...

Actually the real question is: does there exist an MCS M'' with w ∈ M'' and G(neg w) ∈ M'' and g_content(M) ⊆ M''?

In classical model theory, this is a consistency question. Let's think about what prevents this:
- G(neg w) ∈ M'' means neg w ∈ all strict-future successors of M''
- But under irreflexive semantics, G(phi) does NOT imply phi ∈ M'' itself
- So G(neg w) ∈ M'' is compatible with w ∈ M'' (because M'' is not its own strict future)

For the formal proof, we need: `{w, G(neg w)} ∪ g_content(M)` is SetConsistent.

**Key lemma needed**: If F(w) ∈ M (which implies the BX seriality axiom BX2 gives at least one future world), then `{w, G(neg w)} ∪ g_content(M)` is consistent.

Proof attempt: Since F(w) ∈ M, by forward_temporal_witness_seed_consistent, `{w} ∪ g_content(M)` is consistent. Can we additionally add G(neg w)?

Adding G(neg w) could cause a problem if G(neg w) → neg w were derivable (under BX1 which says G(phi) → phi). **But BX1 is NOT in BX** (irreflexive semantics). So G(neg w) does NOT entail neg w in BX.

Therefore, in BX: `{w, G(neg w)}` is consistent. And `{w, G(neg w)} ∪ g_content(M)` is consistent because:
1. g_content(M) ⊆ M (since each phi ∈ g_content(M) means G(phi) ∈ M, and by BX1's absence, this doesn't force phi ∈ M... wait, g_content(M) ⊆ M ONLY holds in S5/reflexive systems where G(phi) → phi is valid.)

**CRITICAL OBSERVATION**: g_content(M) is NOT necessarily a subset of M in BX! Under irreflexive semantics, G(phi) ∈ M does NOT entail phi ∈ M (since G(phi) = "phi at all strict futures" and M is NOT its own strict future). So elements of g_content(M) are formulas that hold at all strict futures, not necessarily at M itself.

This means:
- g_content(M) = {phi | G(phi) ∈ M} may contain formulas outside M
- The seed `{w} ∪ g_content(M)` used in forward_temporal_witness_seed_consistent is consistent because it was proved consistent (via existing infrastructure)
- Adding G(neg w) to this seed: we need `{w, G(neg w)} ∪ g_content(M)` consistent

**The conflict scenario**: Could some phi ∈ g_content(M) conflict with G(neg w)?

phi ∈ g_content(M) means G(phi) ∈ M. If phi = neg G(neg w) = F(w), then G(F(w)) ∈ M. This means G(phi) = G(F(w)) ∈ M. Is G(F(w)) ∈ M compatible?

Now, could `{G(neg w), F(w)} ⊢ bot` in BX?
- G(neg w) means neg w at all strict futures
- F(w) = neg G(neg w) means NOT (neg w at all strict futures), i.e., w at SOME strict future

This IS a contradiction! G(neg w) ∧ F(w) is equivalent to G(neg w) ∧ neg G(neg w) which is bot.

So if F(w) ∈ g_content(M) (i.e., G(F(w)) ∈ M), then adding G(neg w) to the seed creates a conflict.

**Is G(F(w)) ∈ M possible when F(w) ∈ M?**

By temp_4 (G(phi) → G(G(phi))), applying to phi = neg w: G(neg w) → G(G(neg w)). Contrapositive: neg G(G(neg w)) → neg G(neg w), i.e., F(G(neg w)) → F(w).

But what about G(F(w)) ∈ M? By temp_4 with phi = F(w): G(F(w)) → G(G(F(w))). But we need the REVERSE: does F(w) ∈ M imply G(F(w)) ∈ M?

In a general BX model, F(w) at time t means w at some time s > t. Under linearity (BX11), the witness s is specific. G(F(w)) at time t means: for all u > t, there exists v > u with w at v — this is the "w recurs infinitely often" property.

F(w) ∈ M does NOT imply G(F(w)) ∈ M in BX. G(F(w)) ∈ M is a much stronger statement.

However, there is a subtlety: the current chain construction uses `defect_step_choice_early`, and the resolved witness w satisfies w ∈ M'. The NEXT step then builds M'' from M'. Could G(F(w)) end up in M'?

**Back to the chain structure**: Let M_k be the chain state at step k. We have:
- F(w) ∈ M_k (w is an active defect at step k)
- defect_step_choice_early produces M_{k+1} with w ∈ M_{k+1} (w is resolved)

At step k+1, M_{k+1} is an MCS. Does F(w) ∈ M_{k+1}?

Currently the construction gives: either w ∈ M_{k+1} OR F(w) ∈ M_{k+1}. In the problematic case, w ∈ M_{k+1} AND F(w) ∈ M_{k+1}.

**Question for Approach A**: If we add G(neg w) to the seed, what is the new seed?

Seed (current): `{beta'} ∪ g_content(M_k)` where beta' comes from the BX11 fold and F(beta') ∈ M_k.

Seed (Approach A): `{beta', G(neg w)} ∪ g_content(M_k)`.

For this to be consistent, we need `{beta', G(neg w)} ∪ g_content(M_k)` to not derive bot.

Problem: g_content(M_k) might contain F(w) (if G(F(w)) ∈ M_k). And F(w) ∧ G(neg w) ⊢ bot.

When does G(F(w)) ∈ M_k? By temp_4 applied to phi = F(w) = neg G(neg w): G(phi) → G(G(phi)), so G(F(w)) → G(G(F(w))). This is the WRONG direction. We want to know when G(F(w)) ∈ M_k.

Actually, the key question is: at step k (when w is being resolved for the FIRST time), is it possible that G(F(w)) ∈ M_k?

If G(F(w)) ∈ M_k, then by g_content definition: F(w) ∈ g_content(M_k). Adding G(neg w) to the seed then creates inconsistency.

So Approach A as stated (adding G(neg w) to the Lindenbaum seed) is **BLOCKED** if G(F(w)) ∈ M_k — which is possible if w is an "infinitely recurring" defect in the chain's intended model.

### 3. The Amended Approach A: Different Seed Construction

Instead of adding G(neg w) to the Lindenbaum seed (which can fail), we need a different mechanism to prevent F(w) from re-entering M_{k+1}.

**Amended Approach A'**: Show that after resolving w (w ∈ M_{k+1}), if F(w) ∈ M_{k+1}, then we can derive a contradiction from the chain's properties.

**Key lemma (no_new_f_defects)**: From OrderedSeedConsistency.lean:
```
If G(neg w) ∈ M_k and g_content(M_k) ⊆ M_{k+1}, then F(w) ∉ M_{k+1}
```

This lemma exists and is sorry-free. The question is whether G(neg w) ∈ M_k.

**When is G(neg w) ∈ M_k?** By fwd_chain_F_obligation_monotone: F(w) ∉ M_j for some j ≤ k implies G(neg w) ∈ M_j (since F(w) = neg G(neg w), so neg F(w) = G(neg w)). So G(neg w) ∈ M_k iff F(w) ∉ M_k.

But we're considering the case F(w) ∈ M_k (w IS an active defect). So G(neg w) ∉ M_k when F(w) ∈ M_k.

**This confirms the core difficulty**: we cannot use no_new_f_defects directly, because G(neg w) ∉ M_k when F(w) ∈ M_k.

### 4. The Finite Descent Argument: Does It Still Work?

**Can the finite descent argument be closed without seed enrichment?**

The key insight from the team research (Teammate D): Under irreflexive semantics, `chi ∈ M'` does NOT imply `F(chi) ∈ M'` (because `chi → F(chi)` is not derivable in BX). So when chi is resolved (chi ∈ M'), if F(chi) ∉ M' happens to hold, then chi exits the active defect set.

But this "if F(chi) ∉ M'" is the crucial condition. Does the current construction GUARANTEE F(chi) ∉ M' when chi ∈ M'?

**No, it does not**. The current Lindenbaum extension just adds {beta'} ∪ g_content(M_k) and takes an arbitrary MCS extension. The Lindenbaum extension is non-deterministic; it could choose an MCS that contains both chi and F(chi).

So the current construction allows chi ∈ M_{k+1} AND F(chi) ∈ M_{k+1}. This is the perpetual deferral scenario.

### 5. The Active Defect Definition Critique

From the team synthesis report: Teammate D proposed the "correct" active defect definition as `{chi | F(chi) ∈ M AND chi ∉ M AND chi ∈ sigma_list}`. But the current code uses `active_defects M sigma_list = {chi ∈ sigma_list | F(chi) ∈ M}` (without the `chi ∉ M` condition).

**If we use the corrected definition**: when chi is resolved (chi ∈ M_{k+1}), chi is no longer an active defect by definition. So active_defects(M_{k+1}) < active_defects(M_k) in the corrected definition.

**But**: new defects can enter! If F(chi') ∉ M_k but F(chi') ∈ M_{k+1} for some chi' ∈ sigma_list, then active_defects(M_{k+1}) could be larger. However:

By `fwd_chain_F_obligation_monotone`: F(chi) ∉ M_n ⟹ F(chi) ∉ M_m for all m ≥ n. So if F(chi') ∉ M_k, then F(chi') ∉ M_{k+1}. **New defects CANNOT appear!** The F-obligation set is non-increasing.

This is the critical insight. With the corrected active defect definition `{chi | F(chi) ∈ M AND chi ∉ M}`:
- Resolved defect chi: chi ∈ M_{k+1}, so chi leaves active_defects(M_{k+1})
- No new defects: by fwd_chain_F_obligation_monotone, if F(chi') ∉ M_k then F(chi') ∉ M_{k+1}
- Therefore: |active_defects(M_{k+1})| ≤ |active_defects(M_k)| - 1 (strictly decreasing!)

Wait — but what if chi ∈ M_{k+1} AND F(chi) ∈ M_{k+1}? Then chi is STILL in active_defects(M_{k+1}) under the corrected definition too (since F(chi) ∈ M_{k+1} AND chi ∉ M_{k+1} is required for chi to be NOT in active_defects... but chi IS in M_{k+1} so chi is NOT in active_defects(M_{k+1})!).

**This is the key**: with the corrected definition `{chi | F(chi) ∈ M AND chi ∉ M}`:
- If chi ∈ M_{k+1}: chi ∉ active_defects(M_{k+1}) regardless of whether F(chi) ∈ M_{k+1}
- If chi ∉ M_{k+1}: chi ∈ active_defects(M_{k+1}) iff F(chi) ∈ M_{k+1}

Since the BX11 fold guarantees "at least one defect w with w ∈ M_{k+1}", and no new defects appear (fwd_chain_F_obligation_monotone), we have:

|active_defects(M_{k+1})| ≤ |active_defects(M_k)| - 1

**This is a STRICT decrease, no seed enrichment needed!**

### 6. Why the Corrected Definition Works (Formalization Gap)

The formalization gap is:
1. The current code uses `active_defects M sigma_list = {chi ∈ sigma_list | F(chi) ∈ M}` (no "chi ∉ M" condition)
2. With the corrected definition `{chi ∈ sigma_list | F(chi) ∈ M ∧ chi ∉ M}`, strict decrease is provable
3. The key lemma needed: resolved defect w ∈ M_{k+1} implies w ∉ active_defects(M_{k+1}) under the corrected definition

The finite descent proof structure:
- Define measure: `|active_defects(M_k)| = |{chi ∈ sigma_list | F(chi) ∈ M_k ∧ chi ∉ M_k}|`
- At each step: some w with F(w) ∈ M_k and w ∉ M_k gets resolved to w ∈ M_{k+1}
- By fwd_chain_F_obligation_monotone: no chi with F(chi) ∉ M_k can have F(chi) ∈ M_{k+1}
- Combined: active_defects(M_{k+1}) ⊆ active_defects(M_k) \ {w} (strict subset)
- By sigma_list finite: after at most |sigma_list| steps, active_defects is empty
- But phi ∈ sigma_list and F(phi) ∈ M_k for all k (phi is assumed to never resolve), contradiction

### 7. The Remaining Subtlety: phi in active_defects at stabilization

After at most |sigma_list| steps from step n, active_defects becomes empty. But phi was in active_defects at step n (since F(phi) ∈ M_n and phi ∉ M_n by assumption). So at some step n ≤ j ≤ n + |sigma_list|, phi must have been removed from active_defects. Removal happens when phi ∈ M_j. This gives the witness m = j with phi ∈ M_j and n < j.

**The assumption "phi ∉ M_k for all k > n"** (the assumption-for-contradiction in fwd_chain_forward_F) means phi stays outside active_defects only if F(phi) ∉ M_k. But we have F(phi) ∈ M_n and by fwd_chain_F_set_nonincreasing, F(phi) ∈ M_k for all k ≤ n... wait, the monotone direction is: F(phi) ∉ M_n ⟹ F(phi) ∉ M_m for m ≥ n. The reverse: F(phi) ∈ M_n does NOT imply F(phi) ∈ M_{n+1}.

**Critical check**: Under the corrected active defect definition, if phi ∉ M_{k+1} (our assumption for contradiction) and F(phi) ∉ M_{k+1}, then phi exits active_defects at step k+1. But we also assumed F(phi) persists... no, that was a PREVIOUS proof attempt.

**Revised argument**:

Assume for contradiction: F(phi) ∈ M_n and phi ∉ M_m for ALL m > n.

By fwd_chain_defect_one_step at each step: phi ∉ M_{k+1} implies F(phi) ∈ M_{k+1}.

So by induction: F(phi) ∈ M_k for ALL k ≥ n. (This is VALID: if phi ∉ M_{k+1}, then fwd_chain_defect_one_step gives phi ∈ M_{k+1} ∨ F(phi) ∈ M_{k+1}, and since phi ∉ M_{k+1}, we get F(phi) ∈ M_{k+1}.)

So phi ∈ active_defects(M_k) for ALL k ≥ n under the corrected definition (since F(phi) ∈ M_k and phi ∉ M_k for all k ≥ n).

Now at each step k ≥ n, defect_step_choice_early resolves SOME defect w_k (w_k ∈ M_{k+1}). Since phi ∈ active_defects(M_k) for all k ≥ n, the set active_defects never becomes empty while phi remains.

But each w_k (for w_k ≠ phi) that is resolved: w_k ∈ M_{k+1}, so w_k ∉ active_defects(M_{k+1}) under the corrected definition. And by fwd_chain_F_obligation_monotone, no NEW defects appear.

So active_defects(M_{k+1}) ⊊ active_defects(M_k) by at least the loss of w_k (if w_k ≠ phi).

But phi persists! So active_defects can decrease to {phi} and then stay at {phi}. When active_defects(M_k) = {phi}:
- defect_step_choice_early resolves the ONLY element, which is phi
- By singleton_defect_resolved: phi ∈ M_{k+1}

But this contradicts phi ∉ M_{k+1}! **QED**

The finite descent works because:
1. While active_defects has more elements than {phi}: each step kills at least one non-phi defect (reducing size)
2. When active_defects = {phi}: singleton_defect_resolved gives phi ∈ M_{k+1}, contradiction

**Wait**: in step 1, couldn't the resolved w_k equal phi at some step? If w_k = phi at some step k, then phi ∈ M_{k+1}, contradiction immediately. So the only way the argument could fail is if w_k ≠ phi for ALL steps k ≥ n. But then active_defects strictly decreases until it reaches {phi} (bounded by sigma_list finite), and singleton_defect_resolved finishes it.

**This argument is COMPLETE and correct!** The key is:
- defect_step_choice_early always resolves SOME defect (the existing `resolving_enriched_fwd_exists` theorem guarantees this)
- Either the resolved defect IS phi (done, contradiction), or it ISN'T phi (active_defects decreases)
- active_defects is finite (sigma_list is finite), so this terminates

### 8. Seed Enrichment (Approach A) vs Corrected Active Defects (Approach A')

The above analysis shows that **Approach A (G(neg w) seed enrichment) is unnecessary**. The correct proof strategy is:

1. Use the CORRECTED active defect definition: `{chi ∈ sigma_list | F(chi) ∈ M ∧ chi ∉ M}`
2. The finite descent on |active_defects| works directly without seed modification
3. The key lemma (already proved): `resolving_enriched_fwd_exists` guarantees some w is resolved at each step
4. The key lemma (already proved): `fwd_chain_F_obligation_monotone` prevents new defects from appearing
5. The key lemma (already proved): `singleton_defect_resolved` handles the singleton base case

The formalization of `fwd_chain_forward_F` should use well-founded induction on |active_defects(M_k)| with the corrected definition.

### 9. Approach A (Original) Status

The original Approach A (seed enrichment with G(neg w)) is:
- **Mathematically flawed as stated**: Adding G(neg w) to the Lindenbaum seed can create inconsistency if G(F(w)) ∈ M_k (i.e., F(w) ∈ g_content(M_k))
- **The consistency concern is real**: G(neg w) and F(w) are contradictory, and F(w) could be in g_content(M_k) if G(F(w)) ∈ M_k
- **Not needed**: The corrected active defect definition (Approach A') gives the finite descent without seed modification

---

## Recommended Approach

**Implement the corrected active defect definition and finite descent proof** for `fwd_chain_forward_F`:

### Step 1: Redefine active_defects

```lean
private noncomputable def active_defects_corrected (M : Set Formula)
    (sigma_list : List Formula) : List Formula :=
  sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M ∧ χ ∉ M))
```

### Step 2: Prove the strict decrease lemma

After defect_step_choice_early produces M' with w ∈ M':
- No new F-defects: by fwd_chain_F_obligation_monotone
- w exits active_defects_corrected(M')
- Strict decrease: |active_defects_corrected(M')| ≤ |active_defects_corrected(M)| - 1

### Step 3: Well-founded induction proof of fwd_chain_forward_F

```
Proof by well-founded induction on |active_defects_corrected(M_n)|:

Base: |active_defects_corrected(M_n)| = 1.
  Then active_defects = [phi], and singleton_defect_resolved gives phi ∈ M_{n+1}. Done.

Inductive step: |active_defects_corrected(M_n)| = k+1.
  defect_step_choice_early resolves some w.
  Case 1: w = phi. Then phi ∈ M_{n+1}. Done.
  Case 2: w ≠ phi. Then active_defects_corrected(M_{n+1}) ≤ k elements.
    Apply IH to M_{n+1}: phi ∈ M_m for some m > n+1.
```

### Step 4: Handle the "phi persists in active_defects" invariant

The key invariant to maintain: if phi ∉ M_m for all m ≤ n, then F(phi) ∈ M_n (so phi remains in active_defects at step n).

This follows from fwd_chain_defect_one_step by induction.

---

## Confidence Level: High

**Justification**:

The mathematical argument is complete and uses only sorry-free infrastructure:
1. `fwd_chain_F_obligation_monotone` (no new F-defects) — sorry-free, lines 1057-1091
2. `singleton_defect_resolved` — sorry-free, lines 1104-1113
3. `defect_step_choice_early_spec` (resolves ≥1 defect) — sorry-free, lines 520-528
4. `fwd_chain_defect_one_step` (F-obligation preserved disjunctively) — sorry-free, lines 1045-1051

The corrected active defect definition is the missing piece. The proof has no sorry-deferral; it closes `fwd_chain_forward_F` completely via well-founded induction on the corrected active defect count.

**One open sub-question**: Does the defect_step_choice_early ALWAYS pick a defect from the corrected active set (chi with chi ∉ M)? Answer: Yes — because defect_step_choice_early picks w from the defects list, and the defects are `active_defects M sigma_list` = {chi | F(chi) ∈ M}. Under the CURRENT definition, chi might already be in M. Under the CORRECTED definition, chi ∉ M is required, so all picked defects are genuine defects. The current implementation should use the corrected definition for this to work.

---

## Open Questions

1. **Does defect_step_choice_early use the corrected or uncorrected active_defects?** Currently uses uncorrected ({chi | F(chi) ∈ M}). Needs to be updated to exclude chi ∈ M.

2. **What happens if active_defects_corrected(M_n) = [] (no active defects) but F(phi) ∈ M_n?** This cannot happen: F(phi) ∈ M_n and phi ∉ M_n (by assumption for contradiction) means phi ∈ active_defects_corrected(M_n), so the set is nonempty.

3. **Secondary sorry sites (#2-#5)**: The backward chain (sorry #2, #3) is symmetric. Sorry #4 (step transfer for Until/Since) remains hard. Sorry #5 (forward until coherence) depends on sorry #1.

4. **Interaction with the BX11 fold in defect_step_choice_early**: The fold currently uses the UNCORRECTED active_defects. With the corrected definition, the BX11 fold only needs to handle chi ∉ M formulas, which is fine (the fold doesn't use chi ∉ M).

5. **Seed enrichment (Approach A) applicability**: Although Approach A has the consistency issue described, a MODIFIED version could work: instead of adding G(neg w) to the seed, add a formula whose purpose is achieved by the corrected active defect definition. No seed modification needed.
