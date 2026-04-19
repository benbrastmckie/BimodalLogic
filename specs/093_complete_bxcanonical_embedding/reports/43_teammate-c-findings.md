# Teammate C: Critical Analysis — Round 43

**Task**: Complete BXCanonical embedding (Task 93)
**Role**: Critic — Challenge assumptions, identify blind spots
**Date**: 2026-04-19
**Focus**: Is the "control problem" real? What are the actual blockers? Are there simpler paths?

---

## Key Findings

### Finding 1: The "Control Problem" Is Partially Misframed — but the Core Is Real

The framing claims the blocker is that `preserving_fwd_step` uses BX11 fold (via
`defect_step_choice_early`) and "can't control which defect w is resolved."

**Critical observation from reading the code**: The code at
`RootScopedChain.lean:551-559` reveals the actual branching:

```lean
private noncomputable def preserving_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (sigma_list : List Formula) (n : Nat) : Set Formula :=
  let defects := active_defects M sigma_list
  if h : defects ≠ [] then
    defect_step_choice_early M h_mcs defects h (fun χ hχ => active_defects_F_mem hχ)
  else
    let target := if hl : sigma_list.length > 0
      then sigma_list.get ⟨n % sigma_list.length, Nat.mod_lt n hl⟩
      else Formula.bot
    fwd_succ M h_mcs target
```

The `defect_step_choice_early_spec` at line 539-546 explicitly guarantees:
1. Some `w ∈ defects` with `F(w) ∈ M` and `w ∈ M'`
2. `∀ χ ∈ defects, F(χ) ∈ M'`

**The actual question**: Given these guarantees, can we prove `fwd_chain_forward_F`?

The sorry at line 1111:

```lean
private theorem fwd_chain_forward_F ... :
    ∃ m, n < m ∧ φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val := by
  sorry
```

The comment (lines 1092-1110) says termination requires "well-founded induction on defect count or a pigeonhole argument" and notes we can recurse — but it's left `sorry`. The control problem is: we know SOME defect is resolved at each step, but we don't know WHICH one. If it's never φ, we need to argue why φ must eventually be the resolved defect.

**Real framing**: The "control problem" is a TERMINATION problem, not an existence problem. We have the right tools; we just lack a termination argument for the induction.

---

### Finding 2: The No-Defects Branch Is Dead Code — But This Doesn't Help

The prompt's critical observation is correct: once any F-obligation enters `sigma_list`, the `else` branch (round-robin fwd_succ) is **never reached**. Here is why:

`F(φ) ∈ chain(n)` for some `φ ∈ sigma_list`. By `fwd_chain_F_persistent` (line 1072-1083, fully proved), F-obligations are preserved at every step. So `active_defects chain(n) sigma_list` is non-empty at every step. The `if h : defects ≠ []` branch always fires.

**Consequence**: The round-robin target and `fwd_succ` are completely inert once any F-obligation exists. The entire chain is driven by `defect_step_choice_early`.

**Does this help?** Not directly. The real sorry is about `fwd_chain_forward_F`, not about which branch is taken. Knowing the no-defects branch is dead just clarifies the control flow — the BX11 fold path is the ONLY path, which means the termination argument must work entirely within it.

---

### Finding 3: The Termination Argument Is Available — It Uses Induction on Defect List Length

Reading `RootScopedChain.lean:1399-1430` closely, there is commentary that `bx11_earlier` is **non-transitive** (tournaments can have 3-cycles), so a global minimum need not exist. The infrastructure built in Phase 1/2 (`pick_bx11_earliest`, `defect_step_from_earliest`) only guarantees SOME defect is resolved — not which one.

**The termination approach that should work**:

`fwd_chain_F_persistent` (proved) shows `F(φ) ∈ chain(m) → F(φ) ∈ chain(n)` for `m ≤ n` (when `φ ∈ sigma_list`). So F-obligations never decrease for tracked formulas.

However, `defect_step_choice_early_spec` guarantees `∀ χ ∈ defects, F(χ) ∈ M'`. Since `M'` is a NEW MCS (Lindenbaum extension), `F(φ) ∈ M'` is NOT the same as showing F-obligations persist in a meaningful sense for termination.

**The critical gap**: We need `φ ∈ chain(m)` for some `m`. We know `F(φ) ∈ chain(n)` for all `n ≥ k` (by persistence). At each step, SOME `w` is directly resolved (`w ∈ chain(n+1)`). But `w` might never be `φ`.

**The resolution**: This IS provable via a Nat induction on the position of `φ` in some prioritized ordering of defects, using `resolving_enriched_fwd_exists`. The key insight is:

At each chain step, `resolving_enriched_fwd_exists` returns a `w` from the defect list. Whether `w = φ` or not:
- If `w = φ`: done, `φ ∈ chain(n+1)`.
- If `w ≠ φ`: we still have `F(φ) ∈ chain(n+1)` (by `preserving_fwd_step_F_preserved`). But also `w ∈ chain(n+1)` means `F(w) ∈ chain(n+1)` (by `phi_in_mcs_imp_F_phi_early`). So the defect `w` is now BOTH resolved AND has a new F-obligation.

**This is where the control problem is truly hard**: Even though `w` was resolved at step `n`, nothing prevents `w` from still having `F(w) ∈ chain(n+1)`, keeping it in `active_defects` forever. The resolved defect immediately re-acquires an F-obligation via `φ → F(φ)`.

So the defect count does NOT decrease. The prior analysis (round 42) was right: "F-obligations, once lost, never return" is the claim in the comment at line 1521, but the actual lemma `preserving_fwd_step_F_preserved` PRESERVES F-obligations, meaning they INCREASE from the resolution step's perspective. The "no new defects" claim is actually about the OTHER direction — once a formula is NOT a defect, it stays not a defect... but wait, that's not even guaranteed.

**Corrected analysis of the defect dynamics**:
- `active_defects M sigma_list = {χ ∈ sigma_list | F(χ) ∈ M}`.
- `preserving_fwd_step_F_preserved` says: if `F(χ) ∈ M`, then `F(χ) ∈ M'`.
- This means the set of active defects is MONOTONICALLY INCREASING, not decreasing.
- ALL defects persist. New defects can appear when a formula `χ ∈ sigma_list` gets resolved (χ ∈ M') and thus acquires F(χ) ∈ M' via `phi_in_mcs_imp_F_phi_early`.
- The defect set at `chain(n+1)` satisfies `active_defects(M, sigma_list) ⊆ active_defects(M', sigma_list)`.

**Consequence**: The defect count NEVER decreases. It can only grow or stay the same. This means induction on defect count is IMPOSSIBLE.

**This IS the genuine fundamental blocker**: The system is designed so that F-obligations are preserved, but this means the "defects discharged" count is always 0 — once a formula enters the defect list, it never leaves.

---

### Finding 4: The `self_resolving_fwd_step` Shows the Problem Clearly

The code at lines 1594-1629 defines `self_resolving_fwd_step` which, given `F(ψ) ∈ M`, produces `M'` with:
- `ψ ∈ M'`
- `F(ψ) ∈ M'`
- `g_content(M) ⊆ M'`

This is a single step that resolves `ψ` AND ensures `F(ψ)` persists. The problem is crystal clear here: after resolution, `ψ ∈ M'` means `F(ψ) ∈ M'` (by `phi_in_mcs_imp_F_phi`), and the seed explicitly includes `F(ψ)`. So even after "resolution," `ψ` remains an active defect in the next step.

**The problem is structural**: The chain construction's soundness (F-persistence) is exactly what makes termination fail. You can't have both:
1. "F-obligations are preserved" (needed for the chain to be useful for unrestricted coherence)
2. "Defects are eventually discharged" (needed for restricted_tc)

These are in tension. The current architecture makes (1) guaranteed and (2) impossible.

---

### Finding 5: The Backward Chain Has a DIFFERENT Structural Problem

The backward chain `bwd_chain_of_sigma` (line 597-605) uses `bwd_pred` at each step. Unlike the forward chain, there is NO `preserving_bwd_step` — the backward chain is a simple round-robin.

For `dd_bfmcs_restricted_tc` case 2 (backward, line 1134-1138):

```lean
· -- t - s < 0: backward chain.
  -- F(φ) ∈ backward chain needs to be resolved.
  -- The backward chain doesn't have F-preservation, so we need a
  -- different argument. For now, sorry this case.
  sorry
```

The claim that "F-preservation is the issue" is WRONG here. The backward chain doesn't have F-preservation, which is actually FINE for the backward coherence direction. F-formulas in `bwd_chain(k)` are about FUTURE eventualities, which should be handled by the FORWARD chain from `bwd_chain(0) = M₀`.

**The real argument for the backward case**: If `F(φ) ∈ bwd_chain(k)` (for the dd_chain), then since `bwd_chain(0) = M₀` and the g_content propagation for the backward chain satisfies `g_content(bwd_chain(k)) ⊆ bwd_chain(k-1) ⊆ ... ⊆ bwd_chain(0) = M₀`, we need:

Does `F(φ) ∈ bwd_chain(k)` imply `F(φ) ∈ M₀`?

**Answer: NO in general.** `bwd_chain(k)` can have F-formulas that are NOT in `M₀`. The backward chain goes EARLIER in time — it constructs predecessors. `bwd_pred M hM ψ` has `h_content(M) ⊆ bwd_pred(M)`, which means H-formulas propagate backward, but F-formulas (future-looking) are NOT preserved by h_content and may appear or disappear arbitrarily.

**So the backward case is genuinely stuck**: We have `F(φ)` at a past time point, and need to find `φ` at some future time. The backward chain doesn't help. The forward chain might help IF `F(φ) ∈ M₀` (since the forward chain resolves F-obligations in M₀). But we can't get from `F(φ) ∈ bwd_chain(k)` to `F(φ) ∈ M₀` without G-propagation, which doesn't hold.

---

### Finding 6: The `restricted_buc` and `restricted_fuc` Sorries Are Also Genuinely Hard

**`dd_bfmcs_restricted_buc`** (line 1147-1153): The comment says "backward Until/Since coherence requires the step transfer property which is blocked for Lindenbaum-based chains under reflexive semantics."

Reading `UntilSinceCoherence.lean` would reveal what `restricted_backward_until_since_coherent` requires, but from the context it seems this asks: if `φ U ψ ∈ chain(t)`, then either `ψ ∈ chain(t)` or there exist points `t < t₁ < ... < tₖ` with φ at intermediate points and ψ at `tₖ`. This is the FULL Until semantics on the chain.

The problem: `φ U ψ ∈ M` means there's a witness v with `ψ ∈ v` and φ along the way, but that v is some arbitrary BXPoint obtained by Lindenbaum extension — it may NOT be a chain member. So the Until coherence can't be proved by pointing to chain members.

**`dd_bfmcs_restricted_fuc`** (line 1155-1160): Forward Until coherence. The comment says it "depends on restricted_tc and Until propagation." So this is downstream of restricted_tc. If restricted_tc has the termination problem described above, restricted_fuc is also stuck.

---

### Finding 7: There Are Two Viable Alternative Architectures — But Both Require Significant Work

**Alternative 1: Non-preserving forward chain**

If the forward chain is built WITHOUT F-preservation (just using `fwd_succ` with round-robin targeting, the `else` branch that is currently dead), then:
- `fwd_chain_F_persistent` would NOT hold.
- But by schedule surjectivity (`schedule_surjective_above`), each `φ ∈ sigma_list` is eventually scheduled as target.
- At that scheduled step: if `F(φ) ∈ chain(n)`, then `fwd_succ_resolves` gives `φ ∈ chain(n+1)`.
- If `F(φ) ∉ chain(n)` when φ is scheduled... we have nothing.

The problem with this alternative: F-obligations may not persist to the scheduled step. `fwd_succ` at other steps (targeting other formulas) does NOT guarantee F-persistence.

`fwd_succ_f_carry` (line 100-107) shows: F-formulas persist at NON-RESOLVING steps (when `F(target) ∉ M`). At RESOLVING steps (when `F(target) ∈ M`), f_carry is NOT included (the seed is `{target} ∪ g_content(M)` only). So an F-formula can be killed at a resolving step targeting a different formula.

This is the core Lindenbaum non-determinism problem: after `fwd_succ M hM target`, the MCS M' is an ARBITRARY extension of `{target} ∪ g_content(M)`, and F(φ) for φ ≠ target may or may not be in M'.

**Alternative 2: Two-phase chain**

Phase 1 (finite): For each `φ ∈ sigma_list`, do a TARGETED resolution step to resolve `φ` specifically, producing a finite prefix chain. This is possible via `discharge_single_step` or `defect_fwd_step` with the right seed.

Phase 2 (infinite): After all defects are resolved in the first sweep, extend arbitrarily.

The problem: After Phase 1 resolves all sigma-formulas, new F-obligations may appear (since `φ → F(φ)`). This is exactly the same problem as before.

**Alternative 3: Restrict to formulas NOT implying their own F-versions**

This is the semantic heart of the issue. The axiom `φ → F(φ)` (derivable from `¬G(¬φ) ← φ` by T-axiom) means every true formula triggers an F-obligation in the SAME MCS. This reflexivity is the structural reason defect counts can't decrease.

For restricted_tc, one might try: work only with formulas `φ` where `F(φ) ∈ M` but `φ ∉ M` (strict F-obligations). After resolution (`φ ∈ M'`), the formula is no longer a strict defect even though `F(φ) ∈ M'`. If we define `sigma_defect_count` as counting strict defects (`F(φ) ∈ M ∧ φ ∉ M`), this might decrease.

**Checking this**: `defect_step_choice_early_spec` gives `w ∈ M'` for some `w ∈ defects`. If `w` was a strict defect (`F(w) ∈ M ∧ w ∉ M`), then after resolution `w ∈ M'`. Now `F(w) ∈ M'` (by F-preservation), but also `w ∈ M'`, so `w` is NO LONGER a strict defect in `M'`. This is progress!

**This is the key insight the 42 prior rounds may have missed**: Use STRICT defects (F-obligations where the formula itself is currently absent), not non-strict ones. The `sigma_defect_count` in `DefectChain.lean` (line 47-51) ALREADY uses this definition:

```lean
noncomputable def sigma_defect_count (w : BXPoint) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun f =>
    f ∈ w.formulas ∧
    ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas)).card
```

Wait — this counts Until-formulas, not F-formulas. And it checks `f ∈ w.formulas ∧ ψ ∉ w.formulas`. This is a DIFFERENT notion from what `active_defects` tracks.

**The critical distinction**:
- `DefectChain.lean` uses Until-defects: `(φ U ψ) ∈ M ∧ ψ ∉ M`
- `RootScopedChain.lean` uses F-defects: `F(φ) ∈ M` (whether or not `φ ∈ M`)

These are DIFFERENT. The Until-defect count CAN decrease (when ψ is resolved), while the F-defect count cannot.

**This suggests a completely different proof strategy for `fwd_chain_forward_F`**: Prove it by induction on the number of Until-defects, not F-defects.

---

### Finding 8: The Until-Defect Approach Is the Missing Key

`dd_bfmcs_restricted_tc` needs to show: if `F(φ) ∈ chain(t)`, then `φ ∈ chain(t')` for some `t' > t`.

`F(φ) ∈ M` means `¬G(¬φ) ∈ M`. By `F_imp_top_until_mcs` (CanonicalChain.lean:65-72), `F(φ) ∈ M` implies `(⊤ U φ) ∈ M` (axiom BX12). So the F-obligation is equivalent to an Until-obligation `(⊤ U φ) ∈ M`.

Now: `(⊤ U φ) ∈ M` with `φ ∉ M` is a STRICT Until-defect. If we use `bx_until_eventuality_resolution` from `Frame.lean` (line 623-644), it directly gives `∃ v : BXPoint, bx_le M v ∧ φ ∈ v.formulas`. But `v` is an arbitrary BXPoint, not a chain member.

The CHAIN-based approach must show that the chain itself contains such a `v`. This is the real gap.

**Concrete approach**: The backward direction for restricted_tc (currently the second sorry) might actually be easier than thought. If `F(φ) ∈ bwd_chain(k)`, then by BX12, `(⊤ U φ) ∈ bwd_chain(k)`. Since `(⊤ U φ)` is a temporal formula, we need BX4 to carry it forward through the g_content chain: `G(⊤ U φ) ∈ bwd_chain(k)` would give `(⊤ U φ) ∈ bwd_chain(k-1) ⊆ ... ⊆ M₀`. But `G(⊤ U φ) ∈ bwd_chain(k)` requires `(⊤ U φ) → G(⊤ U φ)` which is NOT valid.

---

## The Architecture Blind Spot: The `restricted_tc` Definition

Reading `UntilSinceCoherence.lean` or the BFMCS definition would clarify exactly what `restricted_temporally_coherent` means. Based on the proof structure in `dd_bfmcs_restricted_tc`, the definition appears to be:

```
F(φ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u    [forward]
P(φ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u    [backward]
```

where `φ` is in the `deferralClosure root`.

The restriction to `deferralClosure root` is CRUCIAL. The `deferralClosure` is a FINITE set of formulas. The sigma_list is built from this closure: `sigma_list = (extendedDeferralClosure φ).toList`.

**Has any prior round checked whether `deferralClosure` has special properties that prevent the defect-count problem?** Probably not, since the issue was framed as "control problem" rather than "strict vs non-strict defects."

If `φ ∈ deferralClosure root` implies `F(φ)` is not in `deferralClosure root` (i.e., if deferral closure doesn't contain F-versions of its own elements), then the self-persistence problem might not arise.

---

## Recommended Approach

### Primary Recommendation: Switch to Strict Defect Counting

Reframe `fwd_chain_forward_F` using STRICT defects:

**Strict F-defect**: `χ ∈ sigma_list ∧ F(χ) ∈ M ∧ χ ∉ M`

**Claim**: After one `preserving_fwd_step` (which resolves some `w` directly), the strict defect `w` is ELIMINATED from the strict defect list (even though `F(w)` persists, `w` now satisfies `w ∈ M'`).

**Proof of forward_F using this**:
- Induction on `|strict_defects(chain(n), sigma_list)| + rank(φ, sigma_list)` or similar well-founded measure.
- Base: if `φ ∉ chain(n)` and `F(φ) ∈ chain(n)`, then `φ` is a strict defect. By `defect_step_from_earliest`, some `w` is resolved with `w ∈ chain(n+1)`. The strict defect count for `w` drops to 0. The total strict defect count decreases.
- Eventually, `φ` itself must be the resolved witness (or the strict defect count reaches 0 before — impossible since F(φ) persists and φ not yet resolved means φ is always a strict defect).

Wait — can the strict defect count decrease? If `w ∈ chain(n+1)` and `w` was a strict defect in `chain(n)`, then in `chain(n+1)`: `w ∈ chain(n+1)` and `F(w) ∈ chain(n+1)` (by F-preservation). So `w` is NOT a strict defect in `chain(n+1)`. The strict defect count DECREASES by at least 1 per step.

**This is the key**: Strict defects decrease by ≥1 per step. Since `sigma_list` is finite, in at most `|sigma_list|` steps, ALL strict defects are resolved. After that, `φ ∈ chain(n + |sigma_list|)`.

**Why didn't prior rounds find this?** Because the framing as "control problem" (which defect is resolved) obscured the COUNT argument. The question was not "which defect is resolved" but "does any strict defect get resolved" — and the answer is YES by `defect_step_from_earliest`.

### Secondary Recommendation: Check deferralClosure Properties

Verify whether `deferralClosure` is closed under F-subformulas. If `F(φ) ∈ deferralClosure root → F(φ) ∈ sigma_list`, then F-persistence creates circular F-obligations. If NOT, then the strict defect counting works cleanly.

### Tertiary Recommendation: Bypass restricted_tc for backward case via forward chain

For the backward case (sorry at line 1138): `F(φ) ∈ bwd_chain(k)` where `k > 0`.

Key insight: `bwd_chain(0) = M₀`. If `F(φ) ∈ M₀` (which is NOT given), the forward chain resolves it. The backward case needs to either:
1. Show `F(φ) ∈ bwd_chain(k)` implies `F(φ) ∈ M₀` (false in general), OR
2. Construct a resolution in the backward chain itself, OR
3. Restructure `dd_chain` so backward points know about forward resolutions

Option 3 is the most promising: the dd_chain IS Int-indexed. If `F(φ) ∈ dd_chain(t)` for `t < 0`, the question is whether `φ ∈ dd_chain(t')` for some `t' > t`. This includes `t' = 0` or `t' > 0`. If `F(φ) ∈ M₀` (chain index 0), the forward resolving chain handles `t' > 0`. The missing piece is bridging from `t < 0` to `t = 0`.

**The bridge lemma needed**: `F(φ) ∈ bwd_chain(k)` for some `k > 0` implies `F(φ) ∈ bwd_chain(0) = M₀`.

This is FALSE in general (as shown in Finding 5), but it may hold for formulas in `deferralClosure root` if there's a persistence property specific to those formulas. This needs investigation.

---

## Evidence and Examples

### Evidence for Strict Defect Decrease

From `RootScopedChain.lean:505-529` (`defect_step_early`):

```lean
(∃ w ∈ defects, Formula.some_future w ∈ M ∧ w ∈ M') ∧
(∀ χ, χ ∈ defects → Formula.some_future χ ∈ M')
```

The `w ∈ M'` witness means `w` is no longer a strict defect in `M'` (since `w ∈ M'`). The `∀ χ, F(χ) ∈ M'` part means all OTHER defects retain their F-obligations. So:

- Defects that had `F(χ) ∈ M ∧ χ ∉ M` ("strict") either:
  - `χ = w`: now `w ∈ M'`, so `χ` is no longer a strict defect
  - `χ ≠ w`: `F(χ) ∈ M'` and `χ` may or may not be in `M'`
- The resolved `w` exits the strict defect list
- Others may enter (if some χ with `F(χ) ∈ M ∧ χ ∈ M` now has `F(χ) ∈ M' ∧ χ ∉ M'`... but this requires χ to be REMOVED from M to M', which can't happen since Lindenbaum extension is monotone and `g_content(M) ⊆ M'`)

Actually, **CAN a formula go from being in M to not being in M'?** Since `M' ⊇ g_content(M)` but NOT necessarily `M' ⊇ M`, YES — a formula `χ ∈ M` with `G(χ) ∉ M` may have `χ ∉ M'`. However, since `M` is MCS and `g_content(M) ⊆ M'`, only formulas NOT in g_content(M) can be dropped.

**This is the subtle point**: A formula `χ ∈ M \ g_content(M)` (not a G-formula) can be absent from `M'`. If such `χ ∈ sigma_list` with `F(χ) ∈ M'`, then `χ` becomes a new strict defect in `M'` even though it was NOT a strict defect in `M` (since `χ ∈ M` meant it wasn't a strict defect).

So strict defects can INCREASE from non-defects turning into defects, if their formulas are dropped by the Lindenbaum extension. This is a genuine problem.

**The strict defect count approach requires more care**: The increase in strict defects from dropped formulas must be bounded. Since sigma_list is finite, the total number of possible strict defects is bounded by `|sigma_list|`. The question is whether there's a well-founded measure that strictly decreases.

---

## Confidence Assessment

| Claim | Confidence | Evidence |
|-------|-----------|---------|
| No-defects branch is dead code | VERY HIGH | Code reading lines 551-559, F-persistence theorem |
| F-defect count never decreases | HIGH | F-preservation design, `phi_in_mcs_imp_F_phi_early` |
| Strict defect count decreases by ≥1 per step | MEDIUM-HIGH | `defect_step_early` gives w directly resolved; but new defects can appear from dropped formulas |
| Backward case is genuinely different | HIGH | h_content vs g_content propagation directions |
| Until-defect / BX12 bridge exists | MEDIUM | BX12 proven, but chain-member version unproven |
| Strict defect approach is the missing key | MEDIUM | The insight is new; the full argument needs verification |
| Backward case can be resolved via M₀ bridge | LOW | Would require F-persistence in backward chain, which doesn't exist |

---

## Summary

The "control problem" framing from 42 prior rounds is partially correct but misses the key insight. The real issue is:

1. **F-defect counts cannot decrease** because of F-persistence and φ→F(φ). This makes the proposed termination argument impossible.

2. **Strict F-defect counts CAN decrease** (by exactly 1 at each step), providing a viable termination argument — IF new strict defects from Lindenbaum extension can be controlled. This needs further investigation.

3. **The backward case (t-s < 0) is structurally different** and requires a separate argument. The most promising approach involves either the BX12 bridge or restructuring to always resolve from M₀ forward.

4. **The round-robin / no-defects branch is confirmed dead code** — but this is informational, not a blocker fix.

The recommended next step is to formalize the strict defect count argument and check whether the Lindenbaum extension can create new strict defects from previously-satisfied formulas, and if so, whether the well-founded measure still holds.
