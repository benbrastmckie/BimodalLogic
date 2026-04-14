# Research Report: Task #93 — Close BXCanonical Embedding (Round 12)

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates, 3 completed)
**Session**: sess_1776124230_b9ee33

## Summary

Round 12 team research with focused validation of Plan v11 (quasimodel BFMCS via defect-discharge). Three of four teammates completed. The Critic (Teammate C) identified a **FATAL FLAW in the identity tail construction**: F(psi) in M_last does NOT imply psi in M_last, so the constant-value tail cannot witness F-eventualities. This invalidates Plan v11's core architecture. Teammate A confirmed the quasimodel infrastructure is complete but disconnected from `int_chain` — the BXPoint-to-integer-position bridge is missing. Teammate B found that `restricted_buc` (line 649) may be independently addressable via Until-carry seed enrichment, without requiring forward_F. The four sorry sites decompose into two independent groups with different proof strategies needed.

## Key Findings

### Finding 1: FATAL — Identity Tail Cannot Witness F-Eventualities (Teammate C)

Plan v11 claims the identity tail (constant chain beyond quasimodel segment) trivially satisfies all FMCS properties. This is **FALSE for forward_F**.

- Forward_G works: G(phi) in M_last → phi in M_last by BX T-axiom `G(phi) → phi` ✓
- Forward_F FAILS: F(psi) in M_last does NOT imply psi in M_last. F(psi) means psi holds at some STRICTLY LATER time. The constant tail chain(s) = M_last for all s > k provides no strictly later position where psi could hold unless psi is already in M_last. But F(psi) → psi does not hold in BX (it would make F reflexive, contradicting strict future semantics).

**Impact**: The quasimodel chain + identity tail architecture cannot close forward_F unless the chain endpoint provably has ALL F-obligations discharged (psi in the last point for every F(psi) in deferralClosure). This is a much stronger requirement than Plan v11 assumes — it means the quasimodel chain must resolve ALL defects before the identity tail begins.

**Resolution path**: The quasimodel chain must be extended until ALL defects in deferralClosure(root) are discharged. Since the defect count strictly decreases at each step (via `hintikka_step_target_decrease`), this terminates in at most |deferralClosure(root)| steps. The identity tail then starts from a defect-free point where every F(psi) has psi already present. But this requires proving: (a) the chain can discharge ALL Until defects, not just one; (b) the final point has no remaining F-defects; (c) the final point is "temporally saturated" — F(psi) in it implies psi in it.

### Finding 2: hintikka_step_g_prop Covers Sigma-Bounded Formulas Only (Teammates A, C)

`hintikka_step_g_prop` (Realization.lean:419-424):
```lean
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    (h_step : hintikka_step h1 h2) {chi : Formula}
    (h_Gchi : Formula.all_future chi ∈ h1.formulas) :
    chi ∈ h2.formulas
```

It provides G(chi) in h1 → chi in h2 for any chi, BUT h1.formulas ⊆ Sigma. So G(chi) must be in Sigma.

**Scope issue**: deferralClosure(root) contains seriality formulas (F_top, P_top, G_neg_neg_bot, etc.) that are NOT in SubformulaClosure(root) for arbitrary root. If Sigma = SubformulaClosure(root) (the quasimodel Sigma), then deferralClosure(root) ⊄ Sigma in general.

**Resolution**: Choose Sigma = deferralClosure(root) (or a larger set containing it) instead of SubformulaClosure(root) for the quasimodel construction. This requires verifying the quasimodel machinery works with this larger Sigma.

### Finding 3: restricted_buc May Be Independently Closable (Teammate B)

Teammate B identified that `restricted_buc` (line 649) reduces to a step transfer property via `backward_until_from_step` (UntilSinceCoherence.lean:111):

> Given (φ U ψ) ∈ fam.mcs(r+1), φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)

This does NOT require forward_F. It requires Until-formula propagation through chain steps. Currently, neither f_carry (only F-formulas) nor g_content (only G-formulas) carry Until formulas. A new "u_carry" mechanism could address this:

- Define `u_carry(M) = {φ U ψ ∈ M | ψ ∉ M}` (defective Until formulas)
- Enrich non-resolving seed: `g_content(M) ∪ f_carry(M) ∪ u_carry(M)`
- Consistency: u_carry(M) ⊆ M (since these are formulas IN M), and the enriched seed is a subset of M, so it is consistent by M's consistency

However, Teammate B notes that at resolving steps, the seed `{chi} ∪ g_content(M)` still drops Until formulas. So step transfer fails at resolving steps unless the resolving seed is also enriched.

**Verdict**: Promising but requires enriching BOTH resolving and non-resolving seeds with u_carry. The consistency of `{chi} ∪ g_content(M) ∪ u_carry(M)` needs verification — unlike f_carry enrichment, u_carry ⊆ M, so `{chi} ∪ g_content(M) ∪ u_carry(M)` is consistent if `{chi} ∪ g_content(M) ∪ (M ∩ {defective Until formulas})` is consistent, which follows from `{chi} ∪ g_content(M)` being consistent (proved) plus u_carry ⊆ M.

### Finding 4: BXPoint-to-Integer Bridge Is the Core Obstacle (Teammate A)

The quasimodel produces `v : BXPoint` with `bx_le w v` and `ψ ∈ v.formulas`. But `bx_fmcs_forward_F` needs `∃ s : Int, t < s ∧ ψ ∈ (bx_fmcs M₀ h₀).mcs s`. Converting `bx_le w v` to an integer `s > t` requires showing `v` appears as a chain member — which is false for the current scheduling chain (v is an arbitrary BXPoint, not necessarily a chain member).

**This confirms**: No overlay approach (using quasimodel results on top of the existing scheduling chain) can work. The chain itself must be rebuilt or the sorry must be rewritten to use a different FMCS construction.

### Finding 5: Both Until and Since Defect Infrastructure Exist (Teammates A, C)

- `sinceDefectSet`, `since_defect_count`, `HintikkaStepOracleSince` — all defined
- `hintikka_chain_exists_since` (Construction.lean:769-824) — proved (backward chain)
- But `hintikka_step` itself has NO Since-defect propagation clause (only Until)
- The backward chain uses a reversed oracle that produces predecessors

The backward direction is architecturally different: it extends LEFT (snoc construction) while the forward extends RIGHT. Mapping both to Int-indexed MCS requires two separate adapter paths.

### Finding 6: Strict vs Non-Strict Gap Is Real but Fixable (Teammate C)

The sorry requires `t < s` (strict). If psi ∈ M_t already, the quasimodel may give s = t. Fix: case split on whether psi ∈ M_t:
- If psi ∈ M_t: F(psi) in M_t, so by the scheduling chain, there exists a resolving step for psi at some n > t (via `schedule_surjective_above`). The resolving step gives psi in chain(n+1), providing s = n+1 > t.
- If psi ∉ M_t: the quasimodel chain from (⊤ U psi) gives a non-trivial chain with psi at a strictly later position.

Wait — the first case still requires F(psi) persistence to the resolving step, which is the original obstacle. So the case split doesn't fully resolve the strict gap.

### Finding 7: deferralClosure Extension Breaks Downstream Proofs (Teammate C)

Adding `(⊤ U ψ)` formulas to deferralClosure:
- Breaks `baseDeferralClosure_eq_deferralClosure` (currently `rfl`)
- Breaks `max_F_depth_deferralClosure_eq` (SubformulaClosure.lean:1062) — used in active-path RestrictedMCS.lean
- Breaks `max_P_depth_deferralClosure_eq` (SubformulaClosure.lean:1146)
- Risk to `DeferralRestrictedMCS` pattern-matching

The values of the depth theorems are unchanged (Until has f_nesting_depth 0), but the proofs fail because they unfold `deferralClosure = baseDeferralClosure` via rfl. Fixable but requires re-derivation.

**Alternative**: Use `extendedDeferralClosure` (already defined at SubformulaClosure.lean:812-814) instead of modifying `deferralClosure`. This preserves all downstream lemmas.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is the identity tail correct?**
- Report 11 (round 11): "Identity tail is trivially correct" for all FMCS properties
- Teammate C (round 12): REFUTED — forward_F fails for identity tail
- **Resolution**: Teammate C is correct. F(psi) → psi is not a BX theorem. The identity tail only works for G/H properties (via T-axiom), not for F/P properties. This is a FATAL FLAW in Plan v11.

**Conflict 2: Can restricted_buc be closed independently of forward_F?**
- Prior research: All 4 sorries are interconnected through forward_F
- Teammate B: restricted_buc reduces to step transfer, which is independent of forward_F
- **Resolution**: Teammate B is correct for the step transfer APPROACH, but the step transfer itself is blocked by the same seed enrichment problem (Until formulas are dropped at resolving steps). However, Teammate B's u_carry enrichment proposal is novel and may work because u_carry ⊆ M (unlike f_carry enrichment which adds formulas potentially contradicting the resolving target).

### Gaps Identified

1. **Chain replacement architecture**: The existing int_chain cannot support forward_F or restricted_fuc. A replacement chain must be built that either (a) uses quasimodel construction for the entire chain, or (b) splices quasimodel segments into the scheduling chain. Neither approach has been fully designed.

2. **Full defect discharge requirement**: The identity tail flaw means the quasimodel chain must discharge ALL F-defects before terminating. This requires iterating defect discharge for all F-formulas in deferralClosure(root), not just one. The termination argument (strictly decreasing defect count) supports this, but the construction is more complex than Plan v11 assumed.

3. **Backward chain adapter**: Separate engineering needed for Since/P direction using `hintikka_chain_exists_since` with reversed orientation.

4. **u_carry consistency at resolving steps**: The novel proposal to enrich resolving seeds with defective Until formulas needs formal consistency verification.

### Recommendations

**REVISE Plan v11** to address the identity tail flaw. Two options:

**Option 1: Full chain replacement (quasimodel-only FMCS)**
Replace `int_chain` entirely with a quasimodel-constructed chain:
1. Start from M₀ (the root MCS)
2. Forward direction: iteratively discharge ALL F-defects and Until-defects using `hintikka_chain_exists`, concatenating finite chains
3. Backward direction: symmetrically using `hintikka_chain_exists_since`
4. No identity tail — the chain is the full concatenation of finite defect-discharge segments
5. Map the finite chain to Int by concatenation + periodic extension (or prove the chain covers all of Int)

Risk: The concatenation of multiple defect-discharge chains may reintroduce defects (discharging one F(psi) may create new F(chi) obligations). Need to verify the defect count argument works for the concatenation.

**Option 2: Modified scheduling chain with u_carry enrichment (partial fix)**
1. Add `u_carry(M)` to both resolving and non-resolving seeds in `fwd_succ`/`bwd_pred`
2. Prove consistency of enriched seeds
3. Close restricted_buc via step transfer
4. Forward_F and restricted_fuc remain blocked — defer to quasimodel approach

This gives a partial win (1 of 4 sorries) with lower risk.

**Option 3: Redefine BFMCS using quasimodel families**
Instead of shifted scheduling chains as BFMCS families, use quasimodel-constructed chains directly. This avoids the int_chain ↔ BXPoint bridge entirely.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (quasimodel adapter) | completed | MEDIUM | Mapped full quasimodel API; confirmed BXPoint-to-Int bridge is the core gap; found both Until and Since infrastructure exist |
| B | Alternatives | completed | MEDIUM | Found restricted_buc may be independent of forward_F; proposed u_carry enrichment; decomposed 4 sorries into two groups |
| C | Critic | completed | HIGH | FATAL FLAW: identity tail cannot witness F-eventualities; deferralClosure extension breaks downstream; strict gap analysis |
| D | Strategic horizons | incomplete | N/A | Agent did not produce output file |

## Key Decision Points

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Identity tail approach? | Use / Abandon | **ABANDON** — F(psi) not witnessed by constant tail |
| Chain architecture? | Overlay on int_chain / Full replacement / Redefine BFMCS | **Full replacement** or **Redefine BFMCS** |
| Close restricted_buc independently? | Yes (u_carry) / No (wait for full fix) | **YES** — lower risk, tangible progress |
| deferralClosure modification? | Modify / Use extendedDeferralClosure | **Use extendedDeferralClosure** (preserves downstream) |
| Continue quasimodel path? | Continue / Abandon / Descope | **CONTINUE** with revised architecture (no identity tail) |

## References

- CanonicalModel.lean lines 491-510 (obstacle analysis)
- Realization.lean lines 419-424 (hintikka_step_g_prop)
- Construction.lean lines 594-659 (hintikka_chain_exists)
- Construction.lean lines 769-824 (hintikka_chain_exists_since)
- UntilSinceCoherence.lean line 111 (backward_until_from_step)
- SubformulaClosure.lean lines 809-814 (deferralClosure, extendedDeferralClosure)
- CanonicalChain.lean lines 65-72 (F_imp_top_until_mcs / BX12)
- DefectChain.lean (defect step infrastructure)
