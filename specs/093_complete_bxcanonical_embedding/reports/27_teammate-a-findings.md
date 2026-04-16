# Teammate A Findings: Direct Axiom-Level Argument for forward_F

## Research Focus

Find a direct axiom-level argument that derives a contradiction from perpetual deferral of F(psi) along the enriched round-robin chain.

## Key Findings

### 1. The Chain Structure Already Guarantees F-Preservation

**Confidence: HIGH**

The `enriched_fwd_step` at `RootScopedChain.lean:583` uses `resolving_enriched_fwd_exists` which folds ALL sigma_list formulas through BX11. This gives the critical property (`enriched_fwd_step_preserves` at line 626):

```
F(psi) in chain(n) AND psi in sigma_list
  ==> psi in chain(n+1) OR F(psi) in chain(n+1)
```

And the obligation constancy theorems (lines 1160-1220) show F-obligations are **completely constant** -- once F(psi) appears, it persists forever; once absent, it stays absent.

### 2. BX12 Bridge: F(psi) -> (top U psi)

**Confidence: HIGH**

BX12 (`Axioms.lean:258`): `F(phi) -> (top U phi)` where `top = bot -> bot`.

If F(psi) is in chain(m) for all m >= 0, then by BX12 (MCS closure), `(top U psi)` is also in chain(m) for all m >= 0. However, this alone does NOT help because:

- `(top U psi)` at the axiomatic level only tells us there EXISTS a witness time where psi holds -- but this is precisely the semantic content of F(psi), not new information
- BX12 goes F -> Until direction; the reverse (Until -> F) is BX10, giving `(top U psi) -> F(psi)` -- circular

The Until formulas obtained from BX12 live in the same MCS states as the F(psi) they came from. They do not interact productively with the chain construction.

### 3. BX5 Self-Accumulation on (top U psi)

**Confidence: HIGH (that it does NOT help)**

BX5: `(phi U psi) -> ((phi AND (phi U psi)) U psi)`.

Applied to `(top U psi)`:
```
(top U psi) -> ((top AND (top U psi)) U psi)
```

Since `top AND (top U psi)` is logically equivalent to `(top U psi)` (in an MCS, top is always present), this simplifies to:
```
(top U psi) -> ((top U psi) U psi)
```

This is a "strengthening" -- the guard now includes the Until formula itself. But iterating this just produces nested Until formulas:
```
((top U psi) U psi) -> (((top U psi) U psi) AND ((top U psi) U psi)) U psi) = ...
```

These are all provably equivalent in the axiom system. No new information emerges.

### 4. BX6 Absorption: Does NOT Prevent Infinite Deferral

**Confidence: HIGH (that it does NOT help directly)**

BX6: `(phi U (phi AND (phi U psi))) -> (phi U psi)`.

This prevents a specific syntactic pattern of infinite deferral -- if the witness of `phi U psi` is itself a point where `phi AND (phi U psi)` holds (i.e., the deferral hasn't resolved), then the two-step Until collapses to the original. This is an absorption/idempotency property.

However, BX6 works at the **formula level within a single MCS**, not across chain steps. It cannot force psi into a chain state. The formula `(phi U (phi AND (phi U psi)))` being in an MCS M does not tell us anything about what happens in chain successors of M.

### 5. BX7 Linearity of Until Witnesses: Already Exploited

**Confidence: HIGH**

BX7 is the Until-level version of BX11. The codebase already fully exploits BX11 (the F-level linearity) via `temp_linearity_mcs` and the enriched fold machinery. BX7 would be relevant if we were tracking Until-formulas in the chain seed, but the current construction works with F-formulas and g_content, not Until-formulas.

### 6. G(neg(psi)) Propagation: Cannot Be Derived from Chain Properties Alone

**Confidence: HIGH (negative result)**

If neg(psi) is in chain(m) for all m > n, can we derive G(neg(psi)) in chain(n+1) using ONLY chain properties?

**No.** The chain guarantees:
- `g_content(chain(m)) ⊆ chain(m+1)` (forward G-propagation)
- F-obligation constancy

But having neg(psi) in every chain state does NOT give G(neg(psi)) in any chain state. The chain is constructed by Lindenbaum extension of seeds, and the seeds only contain:
- {target} (at resolving steps)
- g_content(M) (G-formulas from predecessor)
- f_carry(M) (F-formulas from predecessor, only at non-resolving steps)

neg(psi) being in chain(m) just means the Lindenbaum extension happened to include it, not that it was in the seed. G(neg(psi)) would require neg(psi) to be derivable from the seed at every future step, which is exactly what we're trying to prove.

This is the core circularity problem.

### 7. BX4/BX4' Connectedness: Interesting But Insufficient

**Confidence: HIGH**

BX4: `phi -> G(P(phi))` -- if phi holds now, then at all future times, P(phi) holds.
BX4': `phi -> H(F(phi))` -- if phi holds now, then at all past times, F(phi) holds.

If neg(psi) is in chain(m), then G(P(neg(psi))) is in chain(m) (by MCS closure of BX4).
This means P(neg(psi)) propagates to all future chain states via g_content.

So for all s > m: P(neg(psi)) in chain(s).

This tells us that from any chain state after m, the past contains a point where neg(psi) holds. But this does NOT help us derive G(neg(psi)) -- it only says the past has neg(psi), not the future.

Similarly, BX4' gives: if neg(psi) in chain(m), then H(F(neg(psi))) in chain(m), which propagates backward. This tells us F(neg(psi)) holds in all past chain states -- i.e., at every past time, neg(psi) will eventually hold in the future. This is consistent with psi holding sometimes but neg(psi) also holding later.

### 8. The Real Problem: Enriched Seed Already Resolves F-Defects

**Confidence: HIGH**

The crucial theorem is `enriched_fwd_step_resolves_one` (line 644):

At each resolving step where the target has an F-obligation, at least one formula with F-obligation is **directly resolved** (placed in M', not just F-protected).

Combined with `rr_fwd_chain_F_preserved` (line 1242), at each step:
- F(psi) in chain(n) ==> psi in chain(n+1) OR F(psi) in chain(n+1)

The question is: can we get stuck in the "F(psi) in chain(n+1)" branch forever?

### 9. The Defect-Count-Decrease Argument Fails Due to Re-Entry

**Confidence: HIGH**

The doc at line 1290-1298 explicitly states the problem:

> The F-obligation set is STABLE: it never grows and never shrinks.
> The "defect set" {chi | F(chi) in chain(m) AND chi not in chain(m)} can fluctuate:
> formulas can be resolved (chi in chain(m+1)) but then lost again at a later step.
> So the defect count is NOT a valid well-founded measure.

This is correct. The issue is that `enriched_fwd_step_resolves_one` guarantees SOME formula is resolved, but not WHICH one. If psi gets resolved at step m+1 (psi in chain(m+1)), it might be lost at step m+2 while some other formula gets resolved.

### 10. Proposed Solution: Fixed {target} ∪ g_content(M) ∪ {all F-obligations as F-formulas}

**Confidence: MEDIUM**

The approach documented at lines 1300-1313 suggests proving consistency of `{target} ∪ g_content(M) ∪ f_carry(M)`. But this is already done! `rr_nonresolving_seed_consistent` (line 466) proves:

```
g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀) is consistent when modal_fix(M₀) ⊆ M
```

The problem is that at RESOLVING steps, the seed is `{target} ∪ g_content(M)` (from the enriched fold), NOT `{target} ∪ g_content(M) ∪ f_carry(M)`.

**Key insight**: The `enriched_fwd_step` DOES protect all F-formulas via the BX11 fold. The issue is that the protection is DISJUNCTIVE: either chi in M' or F(chi) in M'. We need to show that for the specific psi we care about, the disjunction eventually resolves to the left (psi in M').

### 11. The Correct Proof Strategy: Pigeon-hole on BX11 Case 3

**Confidence: MEDIUM-HIGH**

Consider the BX11 fold at a step where psi's schedule fires (target = psi):

The fold processes psi against each other F-defect chi_1, chi_2, ..., chi_k. At each fold step, BX11 gives three cases:
1. F(psi AND chi_i) -- psi and chi_i will both be direct
2. F(psi AND F(chi_i)) -- psi will be direct, chi_i will be F-protected
3. F(F(psi) AND chi_i) -- psi will be F-protected, chi_i will be direct

Case 3 is the ONLY case that causes psi to lose its direct witness. After the fold, the `enriched_fwd_fold_with_witness` theorem (line 259) tracks a "witness" formula that is guaranteed to be directly in M'. In case 3, the witness changes to chi_i.

The final witness (the formula guaranteed to be direct in M') is:
- psi, if case 3 never fires during the fold
- chi_j (the last formula for which case 3 fired), otherwise

So psi fails to be directly resolved ONLY when some chi_j "wins" the BX11 ordering -- i.e., case 3 fires, meaning F(F(psi) AND chi_j) in M, which (by conjunction commutativity) means chi_j is bx11_earlier than psi.

**The key question**: Can there always be such a chi_j? If the BX11 ordering on the F-defect set is well-founded (no infinite descending chains), then eventually psi must be the "earliest" defect and get resolved.

But the BX11 ordering is on formulas in the CURRENT MCS, and the MCS changes at each step. The ordering can shift between steps. A formula that was bx11_earlier at step m might not be at step m+k.

### 12. Alternative: Prove the Extended Seed {target} ∪ g_content(M) ∪ f_carry(M) is Consistent at Resolving Steps

**Confidence: MEDIUM**

If we could show `{psi} ∪ g_content(M) ∪ f_carry(M)` is consistent when F(psi) in M, then the Lindenbaum extension M' would contain:
- psi (directly resolved)
- g_content(M) (G-propagation)
- f_carry(M) = all F-formulas from M

This would give forward_F immediately: at psi's scheduled visit, F(psi) persists (by F-obligation constancy), so the enriched seed resolves psi and preserves all F-formulas for the next step.

The obstacle (from lines 1303-1313): proving consistency requires showing g_content(M) cannot derive G(neg(chi)) for any F(chi) in f_carry(M). This would need G(F(chi)) in M (i.e., F(chi) holding at all future times), which is NOT guaranteed.

However, there is a subtlety: `f_carry(M) ⊆ M`, and `g_content(M) ⊆ M` (via BX1). So `{psi} ∪ g_content(M) ∪ f_carry(M) ⊆ {psi} ∪ M`. The question is whether `{psi} ∪ M` is consistent. By `forward_temporal_witness_seed_consistent`, `{psi} ∪ g_content(M)` is consistent when F(psi) in M. But `{psi} ∪ M` need not be (psi might contradict some formula in M -- e.g., neg(psi) in M is possible if F(psi) in M means psi holds in the future but not now).

Wait -- f_carry(M) is a SUBSET of M. And g_content(M) is also a subset of M (via BX1: G(phi) -> phi). So g_content(M) ∪ f_carry(M) ⊆ M. And {psi} ∪ g_content(M) is consistent (from seed consistency). The question is whether adding f_carry(M) \ g_content(M) breaks consistency.

An F-formula F(chi) in f_carry(M) satisfies F(chi) in M. Since g_content(M) ∪ f_carry(M) ⊆ M and M is consistent, g_content(M) ∪ f_carry(M) is consistent. The question is whether adding {psi} to this set breaks consistency.

Suppose {psi} ∪ g_content(M) ∪ f_carry(M) is inconsistent. Then there exist L ⊆ g_content(M) ∪ f_carry(M) with psi :: L ⊢ bot, i.e., L ⊢ neg(psi).

The standard argument (from forward_temporal_witness_seed_consistent) would lift L to G-context: if all of L were in g_content(M), then G(L) ⊢ G(neg(psi)) and G(neg(psi)) in M, contradicting F(psi) in M.

But L may contain f_carry elements F(chi). We CANNOT lift F(chi) to G(F(chi)) -- that's the obstruction.

**This approach is stuck** unless we can show G(F(chi)) in M for relevant chi, which requires F(chi) to hold at all future times. But that's exactly what forward_F would give us -- circular.

### 13. The Most Promising Direction: Finite Defect Set + Round-Robin Guarantees

**Confidence: MEDIUM**

The sigma_list is FINITE (it's a list). The F-obligation set FO = {chi in sigma_list | F(chi) in chain(n)} is constant for all n (by F-obligation constancy). Let |FO| = k.

At each resolving step for some target in FO, `enriched_fwd_step_resolves_one` guarantees at least one member of FO is directly resolved (placed in M'). The round-robin schedule visits each member of FO at least once every |sigma_list| steps.

The question is: does the round-robin guarantee that EACH specific member of FO eventually gets its turn as the "winner" of the BX11 ordering?

**No direct guarantee exists.** The BX11 fold might consistently put some fixed chi ahead of psi in the ordering. The ordering can vary between MCS states, but we have no control over which case BX11 picks (it's a classical disjunction -- the Lindenbaum extension picks one branch nondeterministically).

This is where the proof appears to genuinely require a new idea beyond what the current infrastructure provides.

## Overall Assessment

**The direct axiom-level approach -- using BX axioms alone to derive a contradiction from perpetual non-resolution of F(psi) -- appears to be BLOCKED.**

The fundamental obstacle is that:
1. F(psi) in every chain state does NOT imply G(F(psi)) in any chain state
2. Without G(F(psi)), we cannot propagate F(psi) through g_content to control the successor seeds
3. The BX11 fold gives only disjunctive guarantees (psi in M' OR F(psi) in M')
4. The round-robin schedule does not control which disjunct the Lindenbaum extension picks
5. BX5, BX6, BX7, BX12 all operate at the formula level within a single MCS and cannot force formulas into chain successors

**The most promising direction** that might bypass this obstacle is to change the chain construction itself rather than trying to prove forward_F about the current one. Specifically:

(a) **Modify the seed at resolving steps** to include f_carry(M) in addition to g_content(M) and {target}. This requires proving `{target} ∪ g_content(M) ∪ f_carry(M)` is consistent -- which seems blocked by the G(F(chi)) gap.

(b) **Use the target_resolving_fwd_exists_strong theorem** (line 1143) which gives target directly resolved AND all other F-obligations preserved as F-formulas (not disjunctive) -- but this requires the target to be bx11_earlier than all others, which we cannot guarantee for a specific psi.

(c) **Build the chain with an omega-squared or dovetailing strategy** where each F-defect gets resolved along a separate subsequence, using individual forward_temporal_witness_seed_consistent for each defect independently. This avoids the BX11 interaction entirely but requires a fundamentally different chain construction.

Direction (c) appears most viable and is consistent with the comment in `TemporalContent.lean` lines 47-49:

> Resolution of F-obligations requires a non-linear construction (e.g., omega-squared) rather than relying on linear g_content propagation.
