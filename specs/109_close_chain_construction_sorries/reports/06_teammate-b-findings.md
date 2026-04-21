# Teammate B Findings: Step-Indexed Forced Resolution

**Task**: Task 109 — Close chain construction sorries for sorry-free `bx_completeness`
**Focus**: Step-indexed forced resolution approach for `fwd_chain_forward_F`
**Date**: 2026-04-20

---

## Summary

The keystone sorry is `fwd_chain_forward_F` (RootScopedChain.lean:1134): given
`F(φ) ∈ chain(n)` with `φ ∈ sigma_list`, produce `m > n` with `φ ∈ chain(m)`.

The current `preserving_fwd_step` construction already has all the pieces except one:
it resolves *some* defect at each step (via `resolving_enriched_fwd_exists`) and
preserves all F-obligations (via `defect_step_choice_early`), but the resolved defect
`w` is *not controlled* — in BX11 case 3 the resolved element is the *last* formula
in the BX11-ordering, which may not be `φ`.

The existing code already proves:
1. `fwd_chain_F_obligation_monotone`: F-obligations never return once lost (key descent property).
2. `fwd_chain_F_set_nonincreasing`: the F-obligation set is non-increasing.
3. `preserving_fwd_step_defect_preserved`: each step, every F-obligation either resolves or persists.
4. `singleton_defect_resolved`: when exactly one defect remains, it is guaranteed resolved.

The **step-indexed forced resolution** approach is: redesign (or augment) the chain so that
at bounded intervals, a *scheduled* defect receives a targeted `discharge_single_step` call,
ensuring every defect eventually gets its turn. The mathematical core is a round-robin descent
argument showing the F-obligation count eventually reaches 1 (just `φ`), at which point
`singleton_defect_resolved` closes the case.

After careful analysis, I conclude the step-indexed approach is **mathematically valid** but
with a critical subtlety: "resolution by absence of F-obligation" must be handled separately
from "resolution by direct presence". The approach works but requires a hybrid chain
construction that maintains a commitment invariant.

---

## Key Findings

### 1. The Core Obstruction (Why the Current Chain Fails)

`preserving_fwd_step` resolves *at least one* defect per step, but in BX11 case 3
(`F(F(β) ∧ χ)` fired), the resolved element `χ` is the *last* element in BX11-order, not the target `φ`.
Moreover, after `χ ∈ M'`:
- `F(χ) ∈ M'` may still hold (from `g_content(M) ⊆ M'` and `F(F(χ))→F(χ)` via FF_imp_F).
- This means `χ` remains in `active_defects(M')`, so the defect count does not decrease.

This is the "BX11 perpetual deferral" obstruction mentioned in the code comment (line 452–458).
The archived round-robin approach (`Boneyard/QuasimodelOracle/RoundRobinChain.lean`) hit this
same obstruction. **The current `preserving_fwd_step` does not escape it either**: at each step
some `w ∈ M'` and `F(w) ∈ M'` (BX11 case 2 preserves F-obligation), so the defect count may
stay constant forever.

### 2. What `fwd_chain_F_obligation_monotone` Actually Gives

This theorem (lines 1057–1091) states: if `F(χ) ∉ chain(n)`, then `F(χ) ∉ chain(m)` for all
`m ≥ n`. Combined with `fwd_chain_defect_one_step`, the F-obligation set is non-increasing.

**Key corollary**: If we can *force* `F(φ) ∉ chain(n)` at some step `n`, then `φ` cannot
be an active defect ever again. But of course, the goal is to prove `φ ∈ chain(m)`, which is
stronger — we want direct resolution, not just absence of F-obligation.

However, here is the crucial semantic point:

> **Is "resolution by absence of F-obligation" valid for `forward_F`?**
>
> The goal `fwd_chain_forward_F` is to provide `m > n` with `φ ∈ chain(m)`.
> "Absence of F-obligation" (`F(φ) ∉ chain(m)`) does NOT directly give `φ ∈ chain(m)`.
> In a strict/irreflexive model, `F(φ) ∉ chain(m)` means `G(¬φ) ∈ chain(m)` (by MCS completeness),
> which would mean `φ ∉ chain(m')` for all `m' > m` — the opposite of what we need!

Therefore: **"resolution by absence" is INVALID**. If we lose `F(φ)` from the chain, that
means `G(¬φ)` entered the chain, which is a contradiction with the original assumption
`F(φ) ∈ chain(n)` combined with `fwd_chain_F_obligation_monotone` (which says
`F(φ) ∈ chain(k)` for all `k ≥ n`).

### 3. The Crucial Observation: F(φ) Persists Forever

From `fwd_chain_F_obligation_monotone` (contrapositive): since we start with `F(φ) ∈ chain(n)`,
`F(φ) ∈ chain(m)` for **all** `m ≥ n`. (Assuming `F(φ)` never leaves — let's verify.)

Actually the monotonicity theorem says: if `F(φ) ∉ chain(n)`, then `F(φ) ∉ chain(m)` for all
`m ≥ n`. The contrapositive is: if `F(φ) ∈ chain(m)` for some `m`, then `F(φ) ∈ chain(k)` for
all `n ≤ k ≤ m`.

Wait — the theorem gives monotone *absence*, meaning once `F(φ)` is absent it stays absent.
But it does NOT say `F(φ)` stays present. `F(φ)` can be absent at step `n` but we start with
`F(φ) ∈ chain(n)`, and from step `n` onward, either `φ ∈ chain(n+1)` or `F(φ) ∈ chain(n+1)`
(by `fwd_chain_defect_one_step`). If `φ ∈ chain(n+1)`, we're done. If `F(φ) ∈ chain(n+1)`,
we continue.

The problem is that `F(φ) ∈ chain(k)` does NOT force `F(φ) ∈ chain(k+1)` — it forces only
`φ ∈ chain(k+1) ∨ F(φ) ∈ chain(k+1)`.

So actually: **`F(φ)` may eventually leave the chain** (the preserved step may place `φ ∈ chain(k+1)`
and then `F(φ) ∉ chain(k+1)` because `F` is strict/irreflexive). Once `F(φ)` leaves the chain,
by `fwd_chain_F_obligation_monotone`, it never returns. BUT: if `φ ∈ chain(k+1)` for some `k ≥ n`,
we are DONE — that's precisely the goal. So the only "bad" scenario is `F(φ)` persisting forever
without `φ` ever directly appearing.

**Therefore**: `fwd_chain_forward_F` is equivalent to showing:

> It is impossible for `F(φ) ∈ chain(k)` and `φ ∉ chain(k)` to hold for ALL `k ≥ n`.

(Because if `φ ∈ chain(k+1)` for some `k`, we're done. If `F(φ)` eventually leaves the chain
without `φ` appearing, then `G(¬φ) ∈ chain(k)` at that point, which would have propagated back
via g_content to give `G(¬φ) ∈ chain(n)`, contradicting `F(φ) ∈ chain(n)` in the MCS.)

### 4. The Step-Indexed Construction: Precise Design

The step-indexed approach works as follows:

**Setup**:
- `sigma_list = [χ₁, ..., χ_L]` with `|sigma_list| = L`
- `F_defects(k) = { χ ∈ sigma_list | F(χ) ∈ chain(k) }` (the active defect set at step `k`)

**Chain construction**: Replace `preserving_fwd_step` with a two-mode step:

```
fwd_chain_indexed M₀ h₀ sigma_list n :
  let M = chain(n)
  let defects = F_defects(M)
  -- Mode 1 (preserving): resolve SOME defect, preserve ALL F-obligations
  if defects = [] then fwd_succ M hM (round_robin_target n sigma_list)
  else defect_step_choice_early M hM defects h_ne (F_defects_spec)
```

This is exactly the current `preserving_fwd_step`. The problem is mode 1 does not control
WHICH defect `w` gets resolved.

**Step-indexed augmentation**: We need to interleave with "forced" steps that target a
specific defect `φ`. The design is:

```
fwd_chain_si M₀ h₀ sigma_list (phi : Formula) (n : Nat) : { M // MCS M }
  -- Standard chain, but at step n = k*(L+1) + i for each defect φᵢ ∈ sigma_list,
  -- use discharge_single_step targeting phi_i.
  -- Between forced steps, use preserving_fwd_step to maintain F-obligations.
```

**Round-Robin Schedule**: For defects `[χ₁, ..., χ_L]`, the schedule assigns step `k*L + i`
as the "forced discharge" step for `χᵢ` (1-indexed). All other steps use `preserving_fwd_step`.

At a forced step for `χᵢ`:
- If `F(χᵢ) ∈ chain(k*L+i)`: apply `discharge_single_step` to get `M'` with `χᵢ ∈ M'`
  and `g_content(chain(k*L+i)) ⊆ M'`.
- If `F(χᵢ) ∉ chain(k*L+i)`: just use `preserving_fwd_step` (defect already gone).

**CRITICAL PROBLEM**: `discharge_single_step` does NOT preserve F-obligations for other
defects. The seed `{χᵢ} ∪ g_content(M)` does not include `χⱼ` or `F(χⱼ)` for `j ≠ i`.
So after a forced step for `χᵢ`, `F(χⱼ) ∉ chain(k*L+i+1)` is possible for other `j`.

By `fwd_chain_F_obligation_monotone`, if `F(χⱼ)` is lost at step `k*L+i+1`, it never
returns. This means we cannot use the forced steps naively without risking permanent loss
of other F-obligations.

### 5. Resolution of the "Loss by Force" Issue

Here is the key mathematical resolution:

**Claim**: If `F(χⱼ)` is lost after a forced step for `χᵢ` (i ≠ j), then by
`fwd_chain_F_obligation_monotone`, `F(χⱼ) ∉ chain(k)` for all later `k`. Since
`χⱼ ∈ sigma_list`, this means `G(¬χⱼ) ∈ chain(k*L+i+1)` (MCS completeness), and by
g_content propagation, `G(¬χⱼ) ∈ chain(k)` for all `k > k*L+i`. By g_content going backward
(via `fwd_chain_F_set_nonincreasing`), `F(χⱼ)` was ALREADY ABSENT from `chain(n)` for the
starting `n`.

Wait, that's not right. `fwd_chain_F_obligation_monotone` is one-directional (absence
propagates forward), so `F(χⱼ) ∈ chain(n)` does not contradict `F(χⱼ) ∉ chain(k*L+i+1)`
for `k*L+i+1 > n`. The F-obligation CAN be lost at a forced step.

**The actual resolution**: The forced step for `χᵢ` may lose `F(χⱼ)`, but this only means
`χⱼ`'s defect is "killed by force-discharge" rather than "resolved by direct presence".
Since `fwd_chain_forward_F` asks for `∃ m, n < m ∧ φ ∈ chain(m)`, we need DIRECT presence.

**The correct invariant** for the step-indexed construction is:

> **Invariant I(k)**: `F(φ) ∈ chain(k)` or `∃ m ≤ k, φ ∈ chain(m)`.

The step-indexed approach must maintain that either `φ`'s F-obligation is preserved to
the next round (using `preserving_fwd_step` for the non-target steps) OR `φ` was already
directly resolved at some step `≤ k`.

At `φ`'s scheduled forced step (say step `k*L + i_φ`):
- If `F(φ) ∈ chain(k*L + i_φ)`: apply `discharge_single_step` to get `φ ∈ chain(k*L + i_φ + 1)`.
  Done — direct resolution witnessed.
- If `F(φ) ∉ chain(k*L + i_φ)`: already gone, but invariant I requires either
  `φ ∈ chain(m)` for some earlier `m` (from a prior preserving step that resolved `φ`) or
  this case is impossible because `F(φ) ∈ chain(n)` and monotone non-increase guarantees
  `F(φ) ∈ chain(k*L + i_φ)` if we ensure the preserving steps between rounds preserve F(φ).

**Here is the gap**: Between forced steps, `preserving_fwd_step` is used (for steps
not scheduled for `φ`). `preserving_fwd_step` guarantees each F-obligation persists
(`χ ∈ M' ∨ F(χ) ∈ M'`). But if `χ ∈ M'` (resolved) and `F(χ) ∈ M'` also (from the MCS),
then the F-obligation persists anyway. This is the "BX11 case 2 perpetual deferral": the
resolved `χ` carries `F(χ)` with it.

**The core mathematical question**: Can `F(φ) ∈ chain(k)` for ALL `k ≥ n` without
`φ ∈ chain(m)` for any `m > n`?

The answer from semantics: **YES, under irreflexive F-semantics**. Consider a chain where
every MCS contains `G(¬φ)` and `F(φ)`. This is a contradiction in any MCS (since
`G(¬φ) ∈ M` and `F(φ) ∈ M` means `¬F(φ) ∈ M` and `F(φ) ∈ M`, inconsistent). So:

**Key lemma**: `F(φ) ∈ M` and `G(¬φ) ∈ M` cannot both hold in a consistent MCS.

Since `F(φ) ∈ chain(k)` for all `k ≥ n`, we have `G(¬φ) ∉ chain(k)` for all `k ≥ n`.
By MCS completeness, `¬G(¬φ) = F(φ) ∈ chain(k)`, confirmed.

Now: `F(φ) ∈ chain(k)` means `¬G(¬φ) ∈ chain(k)`, i.e., there EXISTS a future witness
for `φ`. By `preserving_fwd_step_defect_preserved`, at each step `k`, either
`φ ∈ chain(k+1)` or `F(φ) ∈ chain(k+1)`.

If `F(φ)` persists forever in the chain (for all `k ≥ n`, `F(φ) ∈ chain(k)`), then by
the one-step preservation, at each step `k`, either `φ ∈ chain(k+1)` or `F(φ) ∈ chain(k+1)`.
The chain cannot be periodic (infinite), so it is possible (within the current construction)
for `F(φ) ∈ chain(k)` for all `k` without `φ` ever appearing.

**This is the fundamental obstruction**: the current construction does not force direct
resolution because `preserving_fwd_step` can always choose the case `F(φ) ∈ chain(k+1)`
(via Classical.choice, the Lindenbaum extension might produce either branch).

### 6. The Step-Indexed Solution: Extended Preserving Step

The correct step-indexed approach uses a **modified step that targets `φ` specifically**
once per round, while preserving ALL other F-obligations.

The key theorem needed (which IS provable from existing infrastructure) is:

```lean
-- When F(φ) ∈ M and φ is bx11_earlier than all other active defects,
-- there exists M' with φ ∈ M' AND F(χ) ∈ M' for all other active defects χ.
theorem discharge_target_preserving_others
    {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F_phi : F(phi) ∈ M)
    (others : List Formula) (h_F_others : ∀ χ ∈ others, F(χ) ∈ M)
    (h_earliest : ∀ χ ∈ others, bx11_earlier M phi chi) :
    ∃ M', SetMaximalConsistent M' ∧ phi ∈ M' ∧
          (∀ χ ∈ others, F(χ) ∈ M') ∧ g_content M ⊆ M'
```

This would use `target_stays_direct_in_fold` (lines 948–984), which already exists!
But it requires `phi` to be bx11_earlier than ALL others.

**Is `phi` always bx11_earlier than all others?** Not necessarily — BX11 gives a total
preorder but not a fixed minimum. However, the key insight is:

**We do not need phi to be earliest.** The correct construction is:

At the scheduled step for `φ`, use `bx11_earlier_total` (line 851) to find the ACTUAL
earliest element `φ*` among `{φ} ∪ others`. Apply `target_stays_direct_in_fold` with
`φ*` as the target. Then:
- If `φ* = φ`: done, `φ ∈ M'` and all F-obligations preserved.
- If `φ* ≠ φ`: `φ*` is resolved and all F-obligations (including `F(φ)`) are preserved.
  We have made "progress" in the BX11 ordering (or reduced the defect count eventually).

The descent argument then follows from the fact that the BX11-minimum of the defect set
changes over time. Specifically:

1. The defect set `F_defects(k)` is non-increasing (by `fwd_chain_F_set_nonincreasing`).
2. When `discharge_target_preserving_others` is applied with `φ*` (the BX11-minimum):
   - `φ* ∈ chain(k+1)` directly.
   - All F-obligations are preserved: `F(χ) ∈ chain(k+1)` for all other `χ`.
3. Since `φ* ∈ chain(k+1)`, what about `F(φ*) ∈ chain(k+1)`?
   - This is the residual issue: `F(φ*)` may or may not be in `chain(k+1)`.
   - If `F(φ*) ∉ chain(k+1)`: by monotonicity, `F(φ*)` never returns. Defect count decreases.
   - If `F(φ*) ∈ chain(k+1)`: `φ*` is still an active defect at step `k+1`.

**The BX11 perpetual deferral obstruction strikes again**: If BX11 case 2 fires for `φ*`
infinitely often, `φ* ∈ chain(k)` and `F(φ*) ∈ chain(k)` for all `k`. This is not
contradictory in an irreflexive model (the chain may be infinite with `φ*` always true
and F(φ*) always satisfied by later steps).

### 7. The Correct Descent Argument

The descent argument must be at the level of the **TOTAL** F-defect count across all rounds,
not at individual step counts. Here is the correct structure:

**Theorem**: For each `φ ∈ sigma_list` with `F(φ) ∈ chain(n)`, there exists `m > n`
with `φ ∈ chain(m)`.

**Proof structure** (working argument):

Fix `φ ∈ sigma_list` with `F(φ) ∈ chain(n)`. Let `D = F_defects(n) ⊆ sigma_list`.

We induct on `|D|` (the number of active defects at step `n`).

Base case `|D| = 1`: `D = {φ}`. By `singleton_defect_resolved` (lines 1104–1113),
at the next step, `φ ∈ chain(n+1)`. QED.

Inductive case `|D| > 1`: Use `resolving_enriched_fwd_exists` (lines 368–403) to get
`M'` with `g_content(chain(n)) ⊆ M'`, some `w ∈ D` with `w ∈ M'`, and all
`χ ∈ D` with `χ ∈ M' ∨ F(χ) ∈ M'`.

The resolved element `w` satisfies `w ∈ chain(n+1)`.

If `w = φ`, done. If `w ≠ φ`:

Can `F(w) ∈ chain(n+1)`? Yes, if `F(w) ∈ M'` (the Lindenbaum extension may include it).
In this case `|F_defects(n+1)| ≤ |D|` but may equal `|D|`.

**The gap is here**: Without controlling `F(w)`, the induction does not close.

**Resolution via `discharge_single_step`**: Instead of using `preserving_fwd_step`,
at step `n` use `discharge_single_step(chain(n), φ)` (lines 894–901):
- Seed: `{φ} ∪ g_content(chain(n))`
- Result: `M'` with `φ ∈ M'` and `g_content(chain(n)) ⊆ M'`.
- This is consistent because `F(φ) ∈ chain(n)` (by `forward_temporal_witness_seed_consistent`).

We get `φ ∈ chain(n+1)` DIRECTLY. But what about other F-obligations?

`discharge_single_step` does NOT guarantee `F(χ) ∈ chain(n+1)` for other `χ ∈ D`.
By `fwd_chain_F_obligation_monotone`, if `F(χ) ∉ chain(n+1)`, it never returns.
The forward_F property for `χ` is then either:
(a) Already satisfied by some step `≤ n+1` (if `χ ∈ chain(k)` for some `k ≤ n+1`)
(b) Violated — `F(χ)` left the chain permanently without `χ` ever appearing.

Case (b) is the problem. If the forced step for `φ` causes `F(χ)` to leave permanently
without `χ` having appeared, `forward_F` for `χ` is broken.

**However**: `fwd_chain_forward_F` is stated for a FIXED `φ`. It does not need to
simultaneously provide forward witnesses for all defects. Each call to `fwd_chain_forward_F`
is for a specific `φ`. So we are free to use `discharge_single_step` for the specific `φ`
we care about.

**THE KEY INSIGHT**: `fwd_chain_forward_F` is called with a specific `φ` and the chain
is used only to produce a witness for THAT `φ`. The chain is a single fixed construction
`fwd_chain_of_sigma`, so we cannot change it per `φ`. But `fwd_chain_forward_F` only needs
to show `∃ m > n, φ ∈ chain(m)` for this fixed chain.

### 8. The Actual Proof Strategy That Works

Looking at this more carefully, the proof needs to show: for the FIXED chain `fwd_chain_of_sigma`
(which uses `preserving_fwd_step`), every F-defect is eventually resolved.

The existing infrastructure already gives us:
- F-obligations are preserved at each step (or resolved).
- The defect set is non-increasing.
- When only one defect remains, it is resolved.

The gap is showing the defect set eventually reaches size 1 (for the target `φ`).

**Approach via BX11-minimum reduction**:

Claim: At each "round" of `|sigma_list|` steps, the defect count STRICTLY decreases.

Proof attempt: In a round of `L` steps, the preserving step resolves at least one `w` per step
(from `resolving_enriched_fwd_exists`). But `w ∈ chain(n+1)` and `F(w) ∈ chain(n+1)` is
possible (BX11 case 2).

This approach is BLOCKED by the perpetual deferral obstruction. The existing code comment
(lines 1125–1129) explicitly acknowledges this and notes it requires either (a) chain redesign
or (b) proof that BX11 case 2 cannot fire indefinitely.

**What makes the step-indexed approach different**: It FORCES `discharge_single_step`
for the SPECIFIC target `φ` on its scheduled step, regardless of the BX11-ordering.
This guarantees `φ ∈ chain(n+1)` at the forced step.

The challenge: `fwd_chain_forward_F` is proved for the FIXED `fwd_chain_of_sigma` construction,
not a modified chain. To use step-indexed forcing, we would need to REDESIGN `fwd_chain_of_sigma`.

### 9. Recommended Redesign of `fwd_chain_of_sigma`

The correct approach is to redesign `fwd_chain_of_sigma` to use alternating steps:

```lean
-- NEW: Step-indexed forced chain
-- At step n, if n ≡ i (mod L+1) where L = sigma_list.length:
--   if i < L: use discharge_single_step targeting sigma_list[i]
--   if i = L: use preserving_fwd_step (to recover F-obligations)
-- The "recovery step" is needed to restore F-obligations lost during forced steps.

noncomputable def si_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (sigma_list : List Formula) (n : Nat) : Set Formula :=
  let L := sigma_list.length
  if h_L : L = 0 then fwd_succ M h_mcs Formula.bot
  else
    let i := n % (L + 1)
    if h_i : i < L then
      let φ_i := sigma_list.get ⟨i, h_i⟩
      if h_F : Formula.some_future φ_i ∈ M then
        -- Forced discharge: {φ_i} ∪ g_content(M)
        (set_lindenbaum ({φ_i} ∪ g_content M)
          (forward_temporal_witness_seed_consistent M h_mcs φ_i h_F)).choose
      else
        -- No defect at this index: standard step
        fwd_succ M h_mcs φ_i
    else
      -- Recovery step: use preserving_fwd_step to restore F-obligations
      preserving_fwd_step M h_mcs sigma_list n
```

**But this has the same issue**: the forced discharge step for `φ_i` loses F-obligations
for other `φ_j`. During the next round's forced discharge for `φ_j`, `F(φ_j)` may be
absent (lost during `φ_i`'s forced step), so `discharge_single_step` cannot be applied.

**What saves us**: `fwd_chain_F_obligation_monotone`. If `F(φ_j)` was lost during step `k`,
then `F(φ_j)` was already absent from `chain(k)`. But we assumed `F(φ) ∈ chain(n)` for
all `φ ∈ F_defects(n)`. After a forced step for `φ_i`, `F(φ_j)` may be absent from
`chain(k+1)`. In that case, `φ_j` is no longer a defect from step `k+1` onward.

If `φ_j` is not a defect from `k+1` onward, and `φ_j ≠ φ` (our target), then we don't
need to worry about `φ_j`.

For our fixed target `φ = φ` (in `fwd_chain_forward_F`), the question is: can the forced
step for some OTHER `φ_i` eliminate `F(φ)` permanently (without `φ` appearing)?

If `F(φ) ∉ chain(k+1)` after a forced step for `φ_i`, then `G(¬φ) ∈ chain(k+1)` (MCS),
and by g_content propagation forward, `G(¬φ) ∈ chain(m)` for all `m > k+1`. This means
`F(φ) ∉ chain(m)` for all `m > k+1`. But we started with `F(φ) ∈ chain(n)`, and the
forced discharge at step `k ≥ n` uses seed `{φ_i} ∪ g_content(chain(k))`.

Does `G(¬φ) ∈ g_content(chain(k))`? `G(¬φ) ∈ g_content(chain(k))` iff `G(G(¬φ)) ∈ chain(k)`.
If `G(¬φ) ∉ chain(k)`, then `G(¬φ) ∉ g_content(chain(k))`, so `G(¬φ)` is NOT forced into
the seed. So the Lindenbaum extension MIGHT or might not include `G(¬φ)`.

Since `F(φ) ∈ chain(k)` (by F-persistence from step `n`), the MCS `chain(k)` contains `F(φ) = ¬G(¬φ)`.
The seed `{φ_i} ∪ g_content(chain(k))` does not contain `G(¬φ)` (since `G(G(¬φ)) ∉ chain(k)`
— this would require `G(¬φ) ∈ g_content(chain(k))` which requires `G(G(¬φ)) ∈ chain(k)`
which requires... it's consistent for `G(G(¬φ)) ∉ chain(k)` when `F(φ) ∈ chain(k)`).

Actually: `F(φ) ∈ chain(k)` means `¬G(¬φ) ∈ chain(k)`. By MCS consistency, `G(¬φ) ∉ chain(k)`.
So `G(¬φ) ∉ g_content(chain(k)) = {ψ | G(ψ) ∈ chain(k)}`. Therefore `G(¬φ)` is NOT in the
forced step seed. The Lindenbaum extension of `{φ_i} ∪ g_content(chain(k))` may or may not
include `G(¬φ)` — it's a free choice of Classical.choice.

**If Classical.choice includes `G(¬φ)` in the extension**, then `chain(k+1)` contains `G(¬φ)`,
making `F(φ) ∉ chain(k+1)` permanently. This violates `fwd_chain_forward_F` for `φ`.

**Conclusion**: The step-indexed approach with bare `discharge_single_step` for non-phi
steps CAN BREAK `fwd_chain_forward_F` for `φ`. The chain construction must guarantee
`F(φ)` is preserved until `φ`'s own forced step.

### 10. The Hybrid Solution: F(φ)-Preserving Forced Steps

The correct hybrid construction:

At each step, use the SEED `{φ_i, φ (as F-guard)} ∪ g_content(M)`:

Actually, the correct fix is: at every step (including forced steps for `φ_i ≠ φ`),
include `F(φ)` in the G-content via a modified seed. But `F(φ)` is already in `chain(k)`,
and `g_content(chain(k))` contains things of the form `G(ψ)`. `F(φ) = ¬G(¬φ)` is NOT in
`g_content(chain(k))` (it's not of the form `G(ψ)` directly). So we cannot include it
via `g_content`.

The REAL solution from the existing infrastructure:

Use `enriched_fwd_exists` / `resolving_enriched_fwd_exists` which EXPLICITLY passes
`phi` in the `others` list, ensuring `phi ∈ M' ∨ F(phi) ∈ M'` at each step. This is
exactly what `preserving_fwd_step` does! And `preserving_fwd_step_defect_preserved`
proves this.

**The insight we missed**: `preserving_fwd_step` ALREADY preserves `F(φ)` at each step
(either directly resolving `φ` or carrying `F(φ)` forward). The problem is not preservation
of `F(φ)` — that's already guaranteed. The problem is that `F(φ)` can be preserved forever
(via BX11 case 2) without `φ` ever appearing directly.

### 11. The Correct Proof of `fwd_chain_forward_F` (Key Theorem)

The correct approach is an **induction on the BX11-minimum position of `φ`** in the
active defect set, NOT on the defect count.

Let `D_k = F_defects(chain(k))`. We know `D_k` is non-increasing.

At each step using `preserving_fwd_step`, `resolving_enriched_fwd_exists` guarantees
some `w ∈ D_k` is resolved (with `w ∈ chain(k+1)`).

**Key question**: Is it possible that `w ∈ D_k` and `F(w) ∈ chain(k+1)` simultaneously?

Answer: Yes, if `G(F(w)) ∈ chain(k)` (which means `F(w) ∈ g_content(chain(k))`), then
`F(w) ∈ chain(k+1)` for all successors. This happens when `G(F(w)) ∈ chain(k)`.

But `G(F(w)) ∈ chain(k)` means `F(w) ∈ chain(k+j)` for all `j ≥ 0`. This is a strong
assumption about the structure of the chain.

Actually, from BX semantics: `G(F(w)) ∈ M` means "always in the future, sometime in the future,
`w`". This is consistent with `w` never appearing directly if the model is non-terminating.

**The Dedicated Step-Index Approach (Final Form)**:

The proof of `fwd_chain_forward_F` requires showing: if `F(φ) ∈ chain(n)` persistently
(never resolved), we get a contradiction with MCS consistency of some chain element.

Specifically: if `φ ∉ chain(k)` for all `k > n`, then (by F-persistence and the
preserving step) `F(φ) ∈ chain(k)` for all `k ≥ n`. Consider the Hintikka-style model
built from the chain: the chain satisfies `F(φ)` at every point but `φ` never appears.
This means `G(F(φ))` is satisfied everywhere. From `G(F(φ)) ∈ chain(n)` (derivable from
persistence + temp_4), the FMCS satisfies the `F(φ)` obligation... but does this lead to
a semantic contradiction?

In an irreflexive linear model: `G(F(φ))` means at every future time, there is a strictly
later time where `φ` holds. This requires `φ` to appear at infinitely many times (or cofinally).
The chain is an ω-chain starting at time `n`. For `φ` to be cofinally present but never
in the chain after `n` is a contradiction: if `φ` is cofinally present, then `φ ∈ chain(m)`
for some `m > n`.

**This is the kernel of the proof**: In an ω-chain with `F(φ) ∈ chain(k)` for all `k ≥ n`,
if `φ ∉ chain(k)` for all `k > n`, then the chain models `G(¬φ)` from some point forward...
wait, that's not what persistence gives us.

Actually: persistence says `φ ∈ chain(k+1) ∨ F(φ) ∈ chain(k+1)`. If `φ ∉ chain(k+1)`,
then `F(φ) ∈ chain(k+1)`. This can continue forever in the chain. The chain is NOT a
semantic model — it's just an ω-sequence of MCS's. The BX axioms hold at each MCS point
but do not by themselves force `φ` to appear.

The key is: **the chain construction must force direct resolution of each `φ`**. The
current `preserving_fwd_step` does not guarantee this. The only way to prove
`fwd_chain_forward_F` with the current construction is if the "resolving" step HAPPENS
to choose `φ` as the directly resolved defect.

---

## Recommended Approach

### Primary Recommendation: Redesign with Explicit Per-Formula Resolution

The step-indexed approach IS the right approach but requires a FUNDAMENTALLY different
chain structure. The recommended design:

```lean
-- For a FIXED target formula phi, build a chain that resolves phi directly.
-- Each step either:
-- (a) phi is already in the current MCS (base case handled separately), or
-- (b) F(phi) ∈ current MCS → use discharge_single_step for phi → phi ∈ next MCS.
-- This produces a FINITE sequence ending at a step where phi ∈ chain.

-- The key: fwd_chain_forward_F does not need a SINGLE chain that works for all phi.
-- Instead, for each phi, we can use a DIFFERENT chain (or show the fixed chain works
-- by a counting argument).
```

Actually, re-reading `fwd_chain_forward_F` signature:

```lean
private theorem fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (φ : Formula) (h_phi : φ ∈ sigma_list)
    (h_F : Formula.some_future φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list n).val) :
    ∃ m, n < m ∧ φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val
```

This is about the FIXED `fwd_chain_of_sigma`. For this chain to satisfy this theorem,
the construction must guarantee that each `φ ∈ sigma_list` with `F(φ) ∈ chain(n)` is
eventually directly resolved.

### The Concrete Lean 4 Proof Sketch

The proof hinges on the following lemma:

```lean
-- Lemma A: F(phi) persists until phi appears.
-- Proof: induct on defect count at step n.
lemma fwd_chain_forward_F_aux (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (φ : Formula) (h_phi : φ ∈ sigma_list)
    (h_F : Formula.some_future φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list n).val)
    (D : Finset Formula) (h_D : D = active_defects_finset sigma_list (fwd_chain_of_sigma M₀ h₀ sigma_list n).val)
    : ∃ m, n < m ∧ φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val := by
  induction h_D.card using Nat.strong_induction_on with
  | _ k ih => ...
```

But the induction requires the defect count to STRICTLY decrease per round, which requires
the step function to guarantee this.

### The Definitive Fix

After thorough analysis, the most viable approach is:

**Replace `preserving_fwd_step` with a step that uses `target_stays_direct_in_fold`** (already proved,
lines 948–984). This theorem guarantees: if target is `bx11_earlier` than all others, then
target ∈ M' directly AND F(χ) ∈ M' for all other χ.

The chain construction uses the BX11-minimum as the target at each step. The descent argument:

1. Let `φ*` = BX11-minimum of `D_n` (the active defect set at step `n`).
2. Apply `target_stays_direct_in_fold` with target `φ*`.
3. `φ* ∈ chain(n+1)` directly.
4. All other F-obligations preserved: `F(χ) ∈ chain(n+1)` for `χ ≠ φ*`.
5. If `F(φ*) ∉ chain(n+1)`: `|D_{n+1}| < |D_n|` (φ* is gone). By induction, eventually
   `φ ∈ chain(m)` (since `φ ∈ D_n` and F-obligations for `φ` are preserved).
6. If `F(φ*) ∈ chain(n+1)`: `|D_{n+1}| = |D_n|`. However, now φ* ∈ chain(n+1).
   On the next step, using `target_stays_direct_in_fold` with the SAME or NEW minimum...

Case 6 is the BX11 perpetual deferral: `F(φ*) ∈ chain(n+1)` means `φ*` remains a defect.
BUT: the newly obtained `F(φ*) ∈ chain(n+1)` comes from `g_content(chain(n)) ⊆ chain(n+1)`
containing `G(F(φ*)) ∈ chain(n)`. So `G(F(φ*)) ∈ chain(n)` is required. But this implies
`F(φ*) ∈ g_content(chain(n))`, and `F(F(φ*)) ∈ chain(n)` which reduces to `F(φ*) ∈ chain(n)`
by `FF_imp_F`.

Actually: `G(F(φ*)) ∈ chain(n)` would mean `F(φ*)` propagates forward forever. But
`G(F(φ*)) ∈ chain(n)` is logically equivalent to `¬F(G(¬φ*)) ∈ chain(n)` (by De Morgan-like
reasoning). This is a non-trivial formula.

**The BX11 deferral obstruction is REAL and cannot be avoided without a different chain design.**

### Practical Recommendation for Lean 4

Given the complexity, the most tractable approach for closing the sorry is:

**Use `discharge_single_step` to build a SEPARATE chain for each `φ`** and then appeal to
a chain-comparison argument. Specifically:

For each `φ ∈ sigma_list` with `F(φ) ∈ chain(n)`, build a ONE-STEP auxiliary chain:
- `chain_phi(n+1) = discharge_single_step(chain(n), φ)` gives `φ ∈ chain_phi(n+1)`.

This `chain_phi` is a DIFFERENT chain (not `fwd_chain_of_sigma`). The theorem
`fwd_chain_forward_F` is about `fwd_chain_of_sigma`, so this does not directly help.

**The True Gap**: `fwd_chain_forward_F` is UNPROVABLE for the current `fwd_chain_of_sigma`
construction because the construction does not guarantee direct resolution of `φ`. The
chain must be redesigned.

---

## Confidence Level

**Low-to-Medium confidence** that the step-indexed approach can close the sorry in its
current form. Specifically:

- **High confidence** (0.9): The "resolution by absence of F-obligation" is INVALID and
  cannot be used.
- **High confidence** (0.9): The current `fwd_chain_of_sigma` construction is insufficient
  for `fwd_chain_forward_F` without redesign.
- **Medium confidence** (0.6): The `target_stays_direct_in_fold` theorem (already proved)
  provides the right building block for a redesigned chain.
- **Low confidence** (0.3): The BX11 perpetual deferral can be escaped within the step-indexed
  framework without a fundamentally different argument.

The step-indexed approach is the RIGHT DIRECTION but the descent argument requires more
care than the prior research suggests.

---

## Evidence and Examples

### Evidence 1: `target_stays_direct_in_fold` is Already Proved

Lines 948–984 of RootScopedChain.lean prove:

> When target is bx11_earlier than every formula in others, there exists M' extending
> g_content(M) with target ∈ M' (guaranteed, not disjunctive) AND F(χ) ∈ M' ∨ χ ∈ M'
> for all others χ.

This is NOT `F(χ) ∈ M'` (it's disjunctive for others), but it does guarantee `target ∈ M'` directly.

### Evidence 2: `singleton_defect_resolved` Works for Size-1 Defect Set

Lines 1104–1113 prove that when `active_defects M [φ] = [φ]` (only one defect), the
`defect_step_choice_early` resolves it directly. This closes the base case of the induction.

### Evidence 3: The Perpetual Deferral Obstruction is Documented

The code comment at lines 1125–1129 explicitly states:
> "Closing this requires either: (a) A chain redesign that forces F(w) ∉ chain(k+1) for
> resolved w, or (b) An argument that BX11 case 2 cannot fire indefinitely for a fixed pair."

This confirms the obstruction is known and the fix direction is redesign.

---

## Gaps and Risks

### Gap 1: Perpetual Deferral

BX11 case 2 (`F(β ∧ F(χ)) ∈ M`) can fire indefinitely for a fixed pair, maintaining
`F(χ)` in the chain even after `χ` is directly resolved. No existing lemma prevents this.

### Gap 2: The Backward Chain Case

`dd_bfmcs_restricted_tc` has a sorry (line 1161) for the `t - s < 0` case. The backward
chain (`bwd_chain_of_sigma`) uses `bwd_pred` which targets a specific formula but does not
preserve P-obligations analogously. A symmetric `preserving_bwd_step` would be needed.

### Gap 3: `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc`

Lines 1176 and 1183 sorry the backward-until-since and forward-until-since coherence.
These depend on `restricted_tc` and additional chain properties not yet established.

### Gap 4: Cannot "Resolve by Absence"

As established in Section 2, losing an F-obligation means `G(¬φ)` entered the chain,
which is a contradiction with the original `F(φ) ∈ chain(n)` combined with monotonicity.
Therefore, IF `F(φ) ∈ chain(n)`, then `F(φ) ∈ chain(k)` for ALL `k ≥ n` (by the forward
one-step preservation: each step either resolves `φ` directly or maintains `F(φ)`).

Wait — this IS the right argument! Let me re-examine:

Starting with `F(φ) ∈ chain(n)`. At step `n → n+1`, `preserving_fwd_step_defect_preserved`
gives `φ ∈ chain(n+1) ∨ F(φ) ∈ chain(n+1)`. If `φ ∈ chain(n+1)`, done. If
`F(φ) ∈ chain(n+1)`, continue. This is an ω-sequence of choices. In constructive math,
we cannot prove "eventually `φ` is chosen" without a descent argument.

**The descent argument requires showing** that the sequence `D_n ⊇ D_{n+1} ⊇ ...` of
active defect sets eventually reaches a point where `D_k = {φ}` (or smaller), after which
`singleton_defect_resolved` closes the case. For this, SOME defect must be PERMANENTLY
eliminated at each "round", requiring `F(w)` to leave the chain without `w` re-entering as
an obligation.

**Risk**: This may require a non-trivial semantic argument about the axiom system,
specifically that BX11 case 2 cannot apply infinitely for a fixed pair of formulas in
any chain of MCS's satisfying the BX axioms.

### Gap 5: `refl_intro_until_mcs` in Construction.lean

Lines 158–161 and 203–207 have sorries for reflexive introduction, noted as non-critical path.
These affect the Until/Since coherence proofs but not `fwd_chain_forward_F` directly.

---

## Summary of Recommended Next Steps

1. **Attempt to prove**: `¬(∃ M (h_mcs : SetMaximalConsistent M), F(φ) ∈ M ∧ G(F(φ)) ∈ M → G(¬φ) ∈ M)`.
   Actually this is FALSE — `G(F(φ))` is consistent with `F(φ)` always holding. The right
   statement is that `G(F(φ)) ∈ M` forces `φ` to appear at some future chain step.

2. **Use `target_stays_direct_in_fold`** to redesign `preserving_fwd_step` as follows:
   - Find the BX11-minimum of the defect set.
   - Apply `target_stays_direct_in_fold` to resolve the minimum directly while
     preserving all other F-obligations.
   - Track whether the minimum was resolved to extinction (no longer a defect)
     or just directly present (still an active defect via `F(min) ∈ chain(n+1)`).

3. **For the specific `fwd_chain_forward_F` sorry**: Consider whether it can be closed
   by showing that in the modified chain (using BX11-minimum targeting), each BX11
   position of `φ` in the ordering decreases monotonically across rounds. This requires
   new infrastructure about BX11 ordering across multiple MCS's.

4. **Alternative**: Accept that `fwd_chain_forward_F` requires a different chain construction
   entirely and redesign `fwd_chain_of_sigma` to use the `discharge_single_step` targeting
   the BX11-minimum at each step, with a proof that this minimum changes (or `φ` is resolved
   within `|sigma_list|` rounds).
