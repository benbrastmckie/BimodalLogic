# Teammate C Critical Analysis — Round 15

## Summary

After reading `RootScopedChain.lean` (all 1272 lines), `OrderedSeedConsistency.lean` (256 lines),
`CanonicalModel.lean` (lines 490–688), and `WitnessSeed.lean` (header), I find the proposed
"G(¬ψ) impossibility + discharge_single_step" approach to be **fatally flawed in multiple
independent ways**. Several of the argument's key steps cannot be supported by the existing
code, and the central claim rests on an equivocation between two different notions of "backward
propagation."

---

## Critical Gaps Found

### Gap 1: `discharge_single_step` does NOT avoid the core problem

`discharge_single_step` (lines 942–949, `RootScopedChain.lean`) is defined as:

```lean
theorem discharge_single_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ ψ ∈ M' ∧ g_content M ⊆ M' := ...
```

This uses the seed `{ψ} ∪ g_content(M)` — exactly the same seed as `fwd_succ` when
`F(ψ) ∈ M`. At each step, `M'` is determined by Lindenbaum extension: the result is
**existentially chosen** and **not functionally defined**. There is no guarantee that the
same `M'` is used consistently across calls. In the actual chain construction
(`rr_fwd_chain`), steps call `enriched_fwd_step`, which uses `resolving_enriched_fwd_exists`
— not `discharge_single_step`. The claim that "the chain is built using
`discharge_single_step`" misrepresents the actual code.

### Gap 2: The G(¬ψ) impossibility argument requires backward propagation that does not hold

The argument states: "If G(¬ψ) ∈ chain(n) for any n, then by backward propagation, G(¬ψ) ∈
chain(0) = M₀."

This claim requires that G(¬ψ) propagates **backward** through the chain. The only backward
propagation mechanism in the code is h_content: `H(φ) ∈ chain(n+1) → φ ∈ chain(n)` (via
`bwd_pred_h_content` and the g/h duality theorems). But G(¬ψ) is **not of the form H(...)**.

The correct form of backward propagation for G is: if `G(φ) ∈ chain(n)` for n ≥ 0, then
`GG(φ) ∈ M₀` (via g_content transitivity). But `GG(φ) ∈ M₀` only gives `G(φ) ∈ M₀` if you
have the T-axiom for G, i.e., `G(G(φ)) → G(φ)`. This is NOT temp_t; that axiom says `G(φ) →
φ`. The axiom `G(G(φ)) → G(φ)` is the **converse of temp_4**, which goes the other
direction: `G(φ) → G(G(φ))`. The converse is NOT an axiom of BX.

In sum: **there is no backward propagation path from G(¬ψ) ∈ chain(n) to G(¬ψ) ∈ M₀** through
any proved lemma in the codebase.

### Gap 3: The forward propagation of G(¬ψ) claim is also wrong for the forward chain

The argument states: "G(¬ψ) ∈ chain(n) → G(G(¬ψ)) ∈ chain(n) by temp_4, so G(¬ψ) ∈
g_content(chain(n)) ⊆ chain(n+1)."

This step IS valid for the forward chain. G(¬ψ) ∈ chain(n) implies G(G(¬ψ)) ∈ chain(n) (by
MCS closure under temp_4), and G(G(¬ψ)) ∈ g_content(chain(n)) ⊆ chain(n+1). So G(¬ψ) ∈
chain(n+1) holds. This forward direction is correct.

But the issue is: the argument uses this **only to show G(¬ψ) propagates forward**, and then
separately claims it propagates backward to M₀. The forward propagation in the positive
direction is irrelevant to proving G(¬ψ) ∉ chain(n) — it makes the situation worse, since if
G(¬ψ) gets into chain(n) it propagates forward to all later steps, permanently killing F(ψ).

### Gap 4: The backward chain is completely unaddressed

The sorry at `dd_fmcs_forward_F` (lines 1162–1170) handles `t < 0` — when F(ψ) ∈ backward
chain. The argument sketch says nothing about this case. The backward chain uses `bwd_pred`
with seeds `{ψ} ∪ h_content(M)` or `h_content(M) ∪ p_carry(M)`. The G(¬ψ) impossibility
argument cannot be applied symmetrically because the backward chain has a fundamentally
different seed structure. This sorry is explicitly labeled "depends on
rr_fwd_chain_forward_F being proved first," but the proposed G(¬ψ) argument gives no
indication of how to handle the backward case.

### Gap 5: The sorry structure is bigger than represented

The code has **three independent sorrys** in `RootScopedChain.lean`:
1. `rr_fwd_chain_forward_F` (line 1139) — the primary forward sorry
2. `dd_fmcs_forward_F` (line 1170) — backward case
3. `dd_fmcs_backward_P` (line 1177) — symmetric backward sorry

And **three more sorrys** in the restricted coherence theorems (lines 1230–1240):
4. `dd_bfmcs_restricted_tc` — uses dd_fmcs_forward_F/backward_P
5. `dd_bfmcs_restricted_buc` — Until/Since backward coherence
6. `dd_bfmcs_restricted_fuc` — Until/Since forward coherence

The proposed approach addresses only sorry #1. Sorrys #5 and #6 (Until/Since coherence) are
completely separate and are NOT addressed by any part of the G(¬ψ) argument.

### Gap 6: The defect set IS non-monotonic — the code says so explicitly

Lines 1109–1116 of `RootScopedChain.lean` state in comments:

> "The 'defect set' {χ | F(χ) ∈ chain(m) ∧ χ ∉ chain(m)} can fluctuate: formulas can be
> resolved (χ ∈ chain(m+1)) but then lost again at a later step (χ ∉ chain(m+2) while F(χ)
> persists)"

The correct statement `no_new_f_defects` (proved, `OrderedSeedConsistency.lean` lines
232–247) shows that if `G(¬α) ∈ M` then `F(α) ∉ M'` for any successor. This means the
F-OBLIGATION set `{α | F(α) ∈ chain(n)}` cannot grow, but the "resolved" set {α | α ∈
chain(n)} CAN fluctuate. A formula ψ can be in chain(n) but not in chain(n+1). So even if
discharge_single_step puts ψ in M' at the visit step, ψ may not persist.

But forward_F only needs **existence** of one s with ψ ∈ chain(s), not persistence. The visit
step does provide ψ ∈ chain(visit+1). The difficulty is: what if F(ψ) is killed before the
visit step? The enriched seed currently guarantees: at each resolving step for χ, F(ψ) ∈
chain(n) implies ψ ∈ chain(n+1) ∨ F(ψ) ∈ chain(n+1) (by `enriched_fwd_step_preserves`).
So F(ψ) never disappears unless ψ itself appears. This means F(ψ) persists until ψ appears —
but the existing code at lines 1133–1139 is exactly this sorry, and the proof attempt in the
comment (lines 1100–1132) says the defect count is not a valid well-founded measure.

---

## Validated Claims

1. `discharge_single_step` is defined and proved (lines 942–949), using seed `{ψ} ∪
   g_content(M)`, and it does guarantee ψ ∈ M' (NOT disjunctive).

2. `enriched_fwd_step_preserves` (lines 604–618) is proved: at each step, if F(ψ) ∈ chain(n)
   and ψ ∈ sigma_list, then ψ ∈ chain(n+1) ∨ F(ψ) ∈ chain(n+1). This is the key F-monotone
   propagation lemma.

3. `rr_fwd_chain_F_propagate` (lines 1071–1096) is proved: for any m ≥ n, either ψ ∈
   chain(s) for some n < s ≤ m+1, or F(ψ) ∈ chain(m+1). This reduces forward_F to: "F(ψ)
   cannot persist forever in the forward chain."

4. `no_new_f_defects` (proved in `OrderedSeedConsistency.lean`): the F-obligation set does
   not grow. If G(¬α) ∈ M and g_content(M) ⊆ M', then F(α) ∉ M'.

5. `enriched_resolving_seed_consistent`, `ordered_two_defect_seed_consistent`,
   `temp_linearity_mcs`, `two_defect_consistent_seed` — all proved sorry-free in
   `OrderedSeedConsistency.lean`.

6. `rr_fwd_chain_F_preserved` (line 1060–1066) is proved: one-step F-persistence holds.

---

## Unvalidated Assumptions in the Proposed Approach

### Assumption A: "G(¬ψ) impossibility implies F(ψ) persists for free"

**Status: UNVALIDATED AND LIKELY CIRCULAR.**

The claim is "G(¬ψ) cannot enter chain(n) for any n, so ¬G(¬ψ) = F(ψ) ∈ chain(n) for all n
by MCS completeness." But how do we show G(¬ψ) cannot enter chain(n)?

The argument says: "if G(¬ψ) ∈ chain(n) then by backward propagation G(¬ψ) ∈ M₀." But as
shown in Gap 2, this backward propagation does NOT hold. The code has no proved lemma
supporting this.

### Assumption B: "MCS completeness gives F(ψ) ∈ chain(n) when G(¬ψ) ∉ chain(n)"

**Status: CORRECT IN ISOLATION, but irrelevant without proving G(¬ψ) ∉ chain(n).**

Yes, in any MCS, ¬G(¬ψ) = F(ψ) ∈ M ↔ G(¬ψ) ∉ M. But establishing G(¬ψ) ∉ chain(n) for
all n is the difficult part, and it has no proof.

### Assumption C: "At ψ's visit step, discharge_single_step guarantees ψ ∈ chain(visit+1)"

**Status: CORRECT only if F(ψ) ∈ chain(visit).**

`discharge_single_step` requires F(ψ) ∈ M as a hypothesis. If F(ψ) has already been
"killed" before the visit step (which the enriched chain actually prevents by
`enriched_fwd_step_preserves`), then discharge_single_step cannot be applied.

The ACTUAL chain does NOT use discharge_single_step — it uses `enriched_fwd_step`. So this
entire argument is about a hypothetical chain, not the actual implemented chain.

### Assumption D: "The G(¬ψ) argument handles all cases"

**Status: UNVALIDATED.** The argument only addresses F(ψ) ∈ M₀. What if F(ψ) ∈ chain(n)
for n > 0 but F(ψ) ∉ M₀? Then G(¬ψ) ∉ M₀, but G(¬ψ) might still be absent from chain(n)
for reasons unrelated to M₀.

---

## Questions That Should Be Asked But Aren't

**Q1: What does `rr_fwd_chain_F_propagate` already give us, and what is the missing piece?**

The proved theorem says: for any m ≥ n, either ψ ∈ chain(s) for some s ≤ m+1, or F(ψ) ∈
chain(m+1). This means forward_F reduces to: "F(ψ) cannot persist in chain(m) for all m ≥ n
without ψ ever appearing." Nobody is asking: given `enriched_fwd_step_preserves`, can we
show that after sigma_list.length steps, F(ψ) must be discharged?

**Q2: Does `enriched_fwd_step_resolves_one` (line 622) provide the missing well-foundedness?**

This theorem guarantees that at each resolving step, at LEAST ONE formula with F-obligation
is directly resolved (enters M'). Can this be used to bound the "number of times ψ is
skipped"? If F(ψ) persists and every cycle resolves at least one formula, can we argue that
ψ must eventually be the one resolved? The answer depends on whether the "resolved" set is
monotone — which the code says it is not. But the F-OBLIGATION set IS monotone (non-growing).
Is there an argument from "F-obligation set is finite and non-growing" + "at each step at
least one formula is resolved" → "every formula with F-obligation is eventually resolved"?
No — because "resolved" means ψ ∈ chain(n+1), which is transient. The formula can be lost.

**Q3: Why not use `rr_fwd_chain_F_propagate` + a bound on the number of F-defects?**

The F-obligation set `{α | F(α) ∈ chain(n)}` is NON-GROWING (by no_new_f_defects). If F(ψ)
∈ chain(n), it stays. So if F(ψ) ∈ chain(n), then F(ψ) ∈ chain(m) for all m ≥ n. Then at
ψ's visit step (the first m ≥ n where rrSchedule visits ψ), `enriched_fwd_step` with target
= ψ gives: ψ ∈ chain(m+1) ∨ F(ψ) ∈ chain(m+1). If ψ ∈ chain(m+1), done. If F(ψ) ∈
chain(m+1) only... the disjunction is NOT resolved. This is exactly the sorry in the code.

**Q4: Why is `enriched_fwd_step_preserves` giving a DISJUNCTION for the target itself?**

At the resolving step for ψ, `enriched_fwd_step_preserves` gives ψ ∈ M' ∨ F(ψ) ∈ M'. But
`enriched_fwd_step_resolves_one` (which uses `enriched_fwd_fold_with_witness`) guarantees that
SOME formula with F-obligation is directly resolved. Could we show ψ itself is the direct
witness? Only in BX11 Case 3 (F-wrapping) is ψ not the direct witness. In Case 1 and Case 2,
ψ (as target) IS the direct witness. So ψ ∈ M' unless Case 3 fires. Nobody is asking: does
Case 3 fire at ψ's visit step, and if so, what does it mean?

**Q5: Are `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` (the Until/Since sorrys) being tracked separately?**

These are on the active completeness path (used by `dd_countermodel` at lines 1265–1268). The
G(¬ψ) argument is completely silent on these. Until coherence was previously identified as
having no syntactic proof. Has anyone reassessed this?

---

## Risk Assessment

### High-Severity Risks

1. **The G(¬ψ) backward propagation claim is false.** There is no code supporting backward
   propagation of G-formulas through the chain. This invalidates the central argument.

2. **The proposed approach addresses only 1 of 6 sorrys.** `dd_bfmcs_restricted_buc` and
   `dd_bfmcs_restricted_fuc` are completely unaddressed. The completeness proof requires all
   three restricted coherence conditions.

3. **Circular reasoning risk.** The argument might implicitly assume F(ψ) persists (which is
   what we want to prove) to establish G(¬ψ) ∉ chain(n).

### Medium-Severity Risks

4. **The actual chain does not use discharge_single_step.** The argument describes a
   hypothetical chain. The actual chain uses `enriched_fwd_step`. Whether discharge_single_step
   could replace enriched_fwd_step without breaking other proved properties (g_content
   propagation, box stability, etc.) has not been verified.

5. **Backward chain sorry (#2) is unaddressed.** `dd_fmcs_forward_F` has a second sorry for
   t < 0 (line 1170). The G(¬ψ) argument has no content for this case.

### Low-Severity Risks

6. **enriched_fwd_step_resolves_one may be the key.** This proved theorem (lines 622–633)
   guarantees at each resolving step that some formula with F-obligation is directly resolved.
   This is close to what is needed, but the "directly resolved" witness may not be ψ at ψ's
   visit step.

---

## What the Code Actually Shows (Not Acknowledged by the Proposal)

1. `rr_fwd_chain_F_propagate` is proved (lines 1071–1096). Forward_F for the rr chain
   reduces to showing F(ψ) cannot persist forever.

2. `enriched_fwd_step_preserves` is proved (lines 604–618). F(ψ) is never lost unless ψ is
   directly placed in the MCS. So F(ψ) ∈ chain(n) ∀n ≥ initial, or ψ ∈ chain(s) for some s.

3. The F-obligation set `{α | F(α) ∈ chain(n)}` is monotone non-growing (no_new_f_defects).
   So if F(ψ) ∈ chain(n), then F(ψ) ∈ chain(m) for all m ≥ n (by enriched_fwd_step_preserves
   + the fact that if ψ ∈ chain(s) then done, else F(ψ) ∈ chain(s+1)).

The MISSING PIECE is: at ψ's visit step, is `enriched_fwd_step` with target=ψ guaranteed
to put ψ directly in M' (not just ψ ∈ M' ∨ F(ψ) ∈ M')? This is the BX11 Case 3 problem:
`enriched_fwd_fold_with_witness` gives a DISJUNCTION for the original target when Case 3 fires.

A potentially viable approach (not the G(¬ψ) impossibility): use `discharge_single_step`
(which gives ψ ∈ M' non-disjunctively) INSTEAD OF `enriched_fwd_step` at ψ's visit step,
combined with `enriched_fwd_step_preserves` showing F(ψ) survives to the visit step. The seed
`{ψ} ∪ g_content(M)` is provably consistent by `forward_temporal_witness_seed_consistent`.
This approach was actually recognized as viable in the code comments (lines 1119–1132).

---

## Confidence Level: HIGH

The critical gaps above are based on direct code inspection:
- Gap 2 is conclusive: no proved lemma in the codebase supports backward propagation of
  G-formulas from chain(n) to M₀.
- Gap 5 is conclusive: lines 1230–1240 have 3 more sorrys not addressed by the proposal.
- Gap 1 is verified: the actual chain uses `enriched_fwd_step`, not `discharge_single_step`.
- The validated claims are verified against the proved code.

The most promising actual path (not proposed) is: prove that at ψ's scheduled visit step m,
`enriched_fwd_step` with target=ψ always places ψ directly in M' (not just disjunctively).
This requires showing BX11 Case 3 cannot fire when ψ is the designated target and F(ψ) ∈ M
(which was propagated by `enriched_fwd_step_preserves` through all prior steps). But this
seems unlikely to be uniformly true — Case 3 fires when some other formula "has an earlier
obligation" than ψ.

Alternatively, use `discharge_single_step` at the visit step (proven seed consistency, ψ ∈ M'
guaranteed) and accept that F-formulas for OTHER ψ' might not be explicitly protected in that
step's MCS — but argue they are restored at their own visit steps. This requires showing F(ψ')
∈ chain(visit_step_for_ψ) is preserved to chain(visit_step_for_ψ'), which again requires
`enriched_fwd_step_preserves` holding across all intermediate steps.

The ultimate issue: `enriched_fwd_step_preserves` IS proved, and it says F(ψ) is never lost.
So if F(ψ) ∈ chain(n), then either ψ ∈ chain(s) for some s > n, OR F(ψ) ∈ chain(m) for
all m > n. The latter is impossible once ψ visits its schedule slot... UNLESS the visit step
puts ψ in M' disjunctively (F(ψ) ∈ M' only). This is the BX11 Case 3 problem.

**The G(¬ψ) argument does not resolve this problem and introduces unfounded claims.**
