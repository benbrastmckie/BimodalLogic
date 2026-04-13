# Teammate C (Critic) Findings: Task 93 Round 10

**Date**: 2026-04-13
**Role**: Critic -- gaps, errors, blind spots
**Focus**: Validate counterexample, scrutinize Architecture C, find overlooked approaches

---

## Key Findings

1. **The counterexample from Report 09 is VALID** -- the resolving seed with untilCarry IS inconsistent in some models. Plan v8 proceeds anyway with this approach.

2. **Plan v8 is building on a REFUTED foundation** -- it proposes proving consistency of `{psi} union g_content(M) union restrictedUntilCarry(M, root)`, but Report 09's own synthesis declared this approach "DEAD" based on the counterexample. The plan acknowledges 40% failure likelihood but the actual probability is closer to 100%.

3. **The BX12 closure gap is a confirmed blocker** -- `(top U psi)` is NOT in `subformulaClosure(root)` when `F(psi)` is.

4. **The DeterministicFMCS in Boneyard is NOT a viable shortcut** -- it has its OWN sorry on forward_F plus 6 additional sorries on deprecated axioms (x_det, y_det, x_k_dist, y_k_dist removed from BX).

5. **The UntilSinceCoherence module provides exactly what is needed** -- parameterized backward Until/Since given a step-transfer hypothesis. The problem reduces entirely to providing this step-transfer property.

6. **An overlooked approach exists**: directly proving restricted forward Until coherence without forward_F, using BX9+BX10 at the MCS level (already done in `bx_until_eventuality_resolution` in Frame.lean for BXPoints).

---

## Counterexample Validation

### Setup

Consider a BX-MCS M containing:
- `F(psi)` (some future time has psi)
- `G(neg(alpha))` (alpha is false at all future times)
- `(alpha U neg(psi))` with `(alpha U neg(psi)) in subformulaClosure(root)`

### Step 1: Is M consistent?

**Yes.** Construct a model: let psi hold at time 1, alpha false everywhere, neg(psi) hold at time 0. Then:
- `F(psi)` holds at time 0 (witness: time 1)
- `G(neg(alpha))` holds at time 0 (alpha false everywhere)
- `(alpha U neg(psi))` holds at time 0: BX8 gives reflexive semantics, so the witness is time 0 itself (neg(psi) holds at time 0, guard on [0,0) is vacuous). BX9 gives `(alpha U neg(psi)) -> alpha v neg(psi)`, and indeed `neg(psi)` holds at time 0.

All three formulas coexist in a consistent MCS. The key: `neg(psi)` at time 0 and `psi` at time 1 is perfectly fine.

### Step 2: What is in the resolving seed?

When `fwd_succ` targets F(psi), the resolving seed is:
```
{psi} union g_content(M) union untilCarry(M, root)
```

- `psi` is the resolution target
- `g_content(M)` = `{phi | G(phi) in M}` includes `neg(alpha)` (from `G(neg(alpha)) in M`)
- `untilCarry(M, root)` includes `(alpha U neg(psi))` (it is in M and in `subformulaClosure(root)`)

So the seed contains: `{psi, neg(alpha), (alpha U neg(psi))}`

### Step 3: Is this seed consistent?

**No.** By BX9: `(alpha U neg(psi)) -> alpha v neg(psi)`. In any MCS extension of the seed, either `alpha` or `neg(psi)` must hold. But `neg(alpha)` is in the seed, so `alpha` cannot hold. Therefore `neg(psi)` must hold. But `psi` is also in the seed. So `psi` and `neg(psi)` both hold, giving `bot`.

More precisely: from `{neg(alpha), (alpha U neg(psi))}` we can derive `neg(psi)`:
1. `(alpha U neg(psi)) -> alpha v neg(psi)` (BX9)
2. Modus ponens gives `alpha v neg(psi)`
3. `alpha v neg(psi)` = `neg(alpha) -> neg(psi)` (definition of disjunction)
4. From `neg(alpha)`, modus ponens gives `neg(psi)`
5. From `psi` and `neg(psi)`: `bot`

The derivation is: `[psi, neg(alpha), (alpha U neg(psi))] derives bot`. The seed is INCONSISTENT.

### Verdict

The counterexample is **VALID**. The set `{psi} union g_content(M) union untilCarry(M, root)` CAN be inconsistent. Plan v8 Phase 2 cannot succeed for all MCS.

**Important nuance**: The inconsistency depends on the specific formulas in M. Not ALL M will produce inconsistent seeds -- only those with an Until formula whose right operand is `neg(psi)` and whose left operand is negated by something in `g_content(M)`. But the proof obligation is to show consistency for ALL MCS M with `F(psi) in M`, and this counterexample shows that is impossible.

---

## Architecture C Skeptical Analysis

### Is 500-800 lines realistic?

**No.** The existing quasimodel infrastructure is 1816 lines across 6 files:
- `Construction.lean`: 887 lines
- `Realization.lean`: 444 lines
- `HintikkaPoint.lean`: 166 lines
- `EnrichedClosure.lean`: 158 lines
- `SubformulaClosure.lean`: 114 lines
- `LocusControl.lean`: 47 lines

A "replacement" approach would need to:
1. Connect quasimodel chains (finite) to FMCS chains (infinite over Int)
2. Handle the Since direction (mirror of Until) -- roughly doubling the effort
3. Wire through the parametric representation theorem
4. Prove the 3 restricted coherence properties specifically

The Realization.lean file already delegates to Frame.lean and has been noted as having sorry root causes in CanonicalChain.lean. The quasimodel infrastructure builds finite defect-discharge chains but does NOT currently produce FMCS Int chains.

**Realistic estimate**: 800-1200 lines of net-new code to bridge quasimodel chains to BFMCS Int coherence properties. The 500-800 estimate from Report 09 is optimistic.

### Does Architecture C solve all 3 sorry sites?

Architecture C targets forward Until coherence, which would close `bx_bfmcs_restricted_fuc`. But:
- `bx_bfmcs_restricted_tc` (restricted forward_F/backward_P) would also need closing. If forward Until is solved, BX12 reduction gives forward_F... but ONLY IF `(top U psi) in subformulaClosure(root)`, which it is NOT (see below).
- `bx_bfmcs_restricted_buc` (backward Until/Since) needs step transfer. The UntilSinceCoherence module provides parameterized backward proofs, but needs a step-transfer hypothesis. Architecture C does not obviously provide this.

### Finite-to-infinite gap

The quasimodel builds a FINITE chain. The BFMCS needs an Int-indexed chain. How does finite extend to infinite?

The standard approach (Burgess 1984) is: given `(phi U psi) in M`, build a finite quasimodel chain from M to a point satisfying psi. Then concatenate these finite segments along the infinite chain. But each concatenation point must be an MCS satisfying the chain linking properties (g_content inclusion, etc.), and the concatenation itself requires non-trivial Lean formalization.

---

## BX12 Closure Gap (Critical Finding)

### The claim

Plan v8 and Report 08 claim: "Restricted forward_F reduces to restricted forward Until via BX12: `F(psi) -> (top U psi)`."

### Verification

BX12 says: `F(phi) -> (bot.imp bot) U phi`. This means `top U phi` where top = `bot -> bot`.

For the restricted truth lemma, forward Until coherence is only needed for Until formulas in `subformulaClosure(root)`. So the BX12 reduction works IF AND ONLY IF:

```
F(psi) in subformulaClosure(root) implies (top U psi) in subformulaClosure(root)
```

where `top = Formula.bot.imp Formula.bot`.

**This is FALSE.** `subformulaClosure` only contains actual subformulas of `root`. If `root = F(psi)` (which unfolds to `G(neg(psi)).imp bot`), the subformulas include `G(neg(psi))`, `neg(psi)`, `psi`, `bot`, and `G(neg(psi)).imp bot` -- but NOT `(bot.imp bot) U psi`. The formula `(top U psi)` is NOT a subformula of any formula containing `F(psi)`.

**Consequence**: The BX12 reduction from restricted forward_F to restricted forward Until DOES NOT WORK. The restricted forward Until coherence quantifies over `Formula.untl phi psi in subformulaClosure(root)`, but `(top U psi)` is not in this set.

This means either:
1. Forward_F must be proved independently (not via BX12), or
2. The subformula closure must be extended to include `(top U psi)` for each `F(psi)` -- i.e., a Reynolds-style enriched closure

The EnrichedClosure.lean file does NOT include `(top U psi)`. It only adds `G(neg(bigconj T))` and `H(neg(bigconj T))` formulas.

**This is a HIGH-severity gap in Plan v8.** Phase 5 depends entirely on the BX12 reduction.

---

## Overlooked Approaches

### 1. DeterministicFMCS (Boneyard) -- NOT viable

I read `DeterministicFMCS.lean` in full. Key findings:
- It has sorry-free backward Until AND backward Since (lines 341-505) using a deterministic chain with `x_mem_chain_general` (the `bot U phi` linking property)
- BUT the `YX_round_trip` and `XY_round_trip` proofs contain 6 sorries on axioms that were REMOVED from BX: `x_det`, `y_det`, `x_k_dist`, `y_k_dist`. These are NOT available in the current axiom system.
- It still has sorry on `deterministic_forward_F` and `deterministic_backward_P`
- It reduces the problem to 2 leaf sorries (forward_F and backward_P) instead of the current 6, but at the cost of depending on axioms that no longer exist

**Verdict**: NOT usable as-is. Would require re-proving YX/XY round-trip without the removed axioms, which may be impossible (they were removed for good reason -- they are not sound under BX reflexive Until semantics).

### 2. Frame.lean's bx_until_eventuality_resolution

`CanonicalChain.lean` line 21 states:
```
bx_until_eventuality_resolution: Forward Until (proved via BX9 + BX10 + bx_forward_witness)
```

This is a sorry-free proof of forward Until eventuality resolution for BXPoints. The question is: can this be lifted to the FMCS chain level?

The BXPoint approach uses the `bx_le` preorder (between BXPoints), not the integer ordering. The challenge is that `bx_le` is not total -- two BXPoints may be incomparable. This is precisely why the Frame.lean approach was abandoned for the chain-based approach.

However, for the RESTRICTED case, we only need to resolve Until formulas in `subformulaClosure(root)`. Each FMCS family IS a chain of MCS over Int, and within a single family, the ordering is total. Could we lift the BXPoint-level eventuality resolution to the family level?

The obstacle: `bx_forward_witness` produces a BXPoint that may not be on the same family's chain. The chain construction does not guarantee that the witness MCS is the next element in the chain.

### 3. Direct restricted forward Until proof

The simplest overlooked approach: prove restricted forward Until directly from BX9 + BX10 at the chain level.

Given `(phi U psi) in fam.mcs t` where `fam` is a BX-FMCS family:
- BX9: `(phi U psi) -> phi v psi` (reflexive disjunction)
- Case 1: `psi in fam.mcs t`. Witness is `t` itself. Done (with `t <= t`).
- Case 2: `phi in fam.mcs t` and `psi not in fam.mcs t`.
  - BX10: `(phi U psi) -> F(psi)` (eventuality). So `F(psi) in fam.mcs t`.
  - Now we need `psi` to appear at some future `s > t` on the chain.
  - This is... exactly forward_F for psi. We are back to the same problem.

So restricted forward Until reduces to restricted forward_F for the right operand. And restricted forward_F is the core unsolved problem. No shortcut here.

### 4. Use the existing f_carry mechanism

The non-resolving branch of `fwd_succ` already includes `f_carry(M)` -- the set of all F-formulas in M. When the scheduling step does NOT resolve F(psi), the F-formula persists to the next step. Eventually (by the schedule surjectivity), F(psi) WILL be targeted for resolution. At that point, the resolving branch constructs a successor MCS containing `{psi} union g_content(M)`, which guarantees `psi` in the successor.

This means `F(psi)` IS eventually resolved -- the scheduling chain DOES produce a witness for any F-formula. The problem is that between the time `F(psi)` first appears and the time it is resolved, the chain may be arbitrarily long, and during that time, the F-formula must be preserved.

**The f_carry mechanism already does this.** The F-formula is in the seed of every non-resolving step. So `F(psi)` persists until it is resolved.

The REAL problem is: `F(psi)` at time `t` needs a witness at time `s > t`. The resolution happens at time `r >= t` (where `r` is the scheduling step). But `r` might be very large. The witness `psi` appears at time `r + 1`. But we need `s > t`, and `r + 1 > t` is guaranteed since `r >= t`. So the witness IS at a strictly later time.

**Wait -- I need to check this more carefully.** The restriction is `restricted_temporally_coherent root`, which requires `F(psi) in fam.mcs t` with `psi in deferralClosure(root)` implies `exists s > t, psi in fam.mcs s`.

The scheduling chain argument goes: F(psi) persists via f_carry until the schedule resolves it. At resolution, psi enters the chain. So the witness exists. But formalizing "F(psi) persists via f_carry" requires showing that the Lindenbaum extension of the non-resolving seed preserves F(psi).

`fwd_succ_f_carry` (line ~105 area of CanonicalModel.lean) shows `f_carry(M) subset fwd_succ(M, ...)` for the non-resolving branch. So if `F(psi) in M`, then `F(psi) in fwd_succ(M, chi)` for any chi that is NOT psi. This means F(psi) persists through all non-resolving steps.

When the schedule finally targets psi, `fwd_succ_resolves` gives `psi in fwd_succ(M, psi)`. Combined with the chain indexing, this gives the witness.

**This is actually the argument for proving restricted forward_F directly.** It does not need untilCarry at all. The f_carry mechanism already suffices for F-formula persistence.

But wait -- if this argument works, why hasn't it been proved in 9 rounds of research? Let me check whether `fwd_succ_f_carry` actually exists and what its precise statement is.

---

## Mathematical Rigor Issues

### 1. Forward_F vs Forward Until boundary conditions

The restricted coherence conditions use different inequality directions:
- `restricted_temporally_coherent`: `F(psi) in fam.mcs t` implies `exists s, t < s and psi in fam.mcs s` (STRICT inequality)
- `restricted_forward_until_since_coherent`: `(phi U psi) in fam.mcs t` implies `exists s, t <= s and psi in fam.mcs s` (NON-STRICT inequality)

This difference matters: forward Until allows the reflexive case (witness at t itself, via BX8), but forward_F requires a STRICTLY later witness.

The BX12 reduction `F(psi) -> (top U psi)` would give a witness `s >= t` for `(top U psi)`, but forward_F needs `s > t`. So even if the closure gap were fixed, we would need `s > t` from the Until witness. By BX9, `(top U psi) -> top v psi`, so either `psi in fam.mcs t` (reflexive case, gives `s = t`) or there exists `s > t`. The reflexive case gives `psi in fam.mcs t`, and then `F(psi) in fam.mcs t` and `psi in fam.mcs t` -- can we get a STRICT witness from this? Yes: `psi in fam.mcs t` and the chain has `fam.mcs (t+1)` which includes `g_content(fam.mcs t) supset {psi}` (since `G(psi)` follows from... no, `psi in M` does NOT give `G(psi) in M`).

Actually, if `psi in fam.mcs t`, we can derive `F(psi) in fam.mcs t` trivially (from `psi -> F(psi)`). But we need a STRICT future witness. We do NOT have `psi in fam.mcs (t+1)` just from `psi in fam.mcs t`. So the reflexive case of Until does not help for the strict forward_F requirement.

This is a genuine issue with the BX12 reduction approach even if the closure gap were fixed.

### 2. No circular dependencies detected

The proposed proof structure is linear: carry sets -> seed consistency -> chain construction -> persistence -> step transfer -> coherence. No circularity.

### 3. Discrete vs Dense

All coherence conditions use Int (discrete). The BX axioms are valid on both discrete and dense orders. The construction is specific to Int. No issue for the current task, but worth noting that the approach does not generalize to dense time without modification.

---

## Confidence Level

**HIGH** on the following:
- The counterexample is valid (resolving seed with untilCarry IS inconsistent)
- The BX12 closure gap is real (`(top U psi)` is NOT in `subformulaClosure(root)`)
- Plan v8 Phase 2 (resolving seed consistency) WILL FAIL
- Plan v8 Phase 5 (BX12 reduction) WILL FAIL due to the closure gap
- DeterministicFMCS is NOT viable with current axioms

**MEDIUM** on:
- The f_carry-based argument for restricted forward_F (needs careful formalization)
- Architecture C line count estimate being 800-1200 (could be less with reuse)

**LOW** on:
- Whether any approach can close the sorry in under 500 lines of new code

---

## Recommendations

### Immediate Action: Abandon Plan v8

Plan v8 is built on two approaches that are both broken:
1. Phase 2 (resolving seed consistency with untilCarry) is refuted by the counterexample
2. Phase 5 (BX12 reduction) fails due to the closure gap

### Investigate: f_carry argument for restricted forward_F

The scheduling chain has `fwd_succ_f_carry` preserving F-formulas through non-resolving steps. However, upon closer examination, **this argument is INSUFFICIENT** for proving restricted forward_F:

- `fwd_succ_f_carry` only applies when `F(psi) NOT IN M` (the non-resolving branch)
- When the resolving branch fires for some OTHER formula chi, the seed is `{chi} union g_content(M)` -- which does NOT include `f_carry(M)`
- So `F(psi)` can be LOST when the schedule resolves a different F-formula
- Once lost, `F(psi)` may never reappear in the chain
- The schedule will eventually target psi, but if `F(psi)` is no longer in the current MCS, the non-resolving branch fires and psi does not appear

This is precisely WHY restricted forward_F has resisted proof for 9 rounds. The f_carry mechanism only preserves F-formulas when NOTHING is being resolved. At resolving steps, all non-target F-formulas can vanish.

**Possible fix**: Include f_carry in the resolving branch seed too. The resolving seed would become `{psi} union g_content(M) union f_carry(M)`. Since `f_carry(M) subset M`, the seed `{psi} union g_content(M) union f_carry(M)` is consistent when `F(psi) in M` -- this is a SUBSET of M plus `{psi}`, and the existing `forward_temporal_witness_seed_consistent` proof already handles `{psi} union g_content(M)`. Adding more elements of M to a consistent seed that is already a subset of M still yields a consistent set (since the whole thing is still a subset of `M union {psi}`, and `M union {psi}` is consistent because `neg(psi) not in M` since `F(psi) in M` implies... wait, F(psi) in M does NOT imply neg(psi) not in M. F(psi) means psi at some FUTURE time, not at the current time.)

Actually, `f_carry(M) subset M`, and `g_content(M) subset M` (via BX1), so `g_content(M) union f_carry(M) subset M`. And `{psi} union S` with `S subset M` is consistent iff `neg(psi)` is not derivable from S. The existing `forward_temporal_witness_seed_consistent` proves exactly this for `S = g_content(M)`. Enlarging S to `g_content(M) union f_carry(M)` makes the consistency HARDER to prove (more formulas to potentially derive neg(psi) from). So this is not trivially a fix.

**However**, the key insight is: `g_content(M) union f_carry(M) subset M`, and since M is consistent, any subset of M is consistent. And `{psi} union (subset of M)` is consistent iff `neg(psi)` is not derivable from the subset. The existing proof uses the temporal K argument on g_content(M). With f_carry(M) added, we need temporal K to work on f_carry too. Since F-formulas in f_carry are of the form `F(chi)`, and `G(neg(psi))` combined with the temporal K machinery... this needs careful analysis.

**This is worth investigating as a new approach**: modify the resolving branch to include f_carry, prove the enlarged seed is still consistent. If successful, this would give F-formula persistence through ALL steps (not just non-resolving ones), solving restricted forward_F.

### Investigate: Backward Until via UntilSinceCoherence

The backward Until obligation (`bx_bfmcs_restricted_buc`) can use `backward_until_from_step` from UntilSinceCoherence.lean, which only needs a step-transfer hypothesis. If a step-transfer property can be proved for the scheduling chain (independently of untilCarry), this closes backward Until.

### Fallback: Full quasimodel approach

If the above fail, Architecture C (full quasimodel replacement) at 800-1200 lines remains the fallback.
