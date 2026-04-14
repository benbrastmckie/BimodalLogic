# Teammate A Findings — Wave 15

**Task 93: Close BXCanonical Embedding**
**Role: Primary Approach Researcher — Approach 1 (discharge_single_step + G(¬ψ) impossibility)**

---

## Summary

Approach 1 is **mathematically flawed**. The core argument that "G(¬ψ) ∈ chain(n) implies G(¬ψ) ∈ M₀" does not hold for the forward chain. G-formulas propagate **forward** (g_content(chain(m)) ⊆ chain(n) for m ≤ n), not backward. There is no reverse g_content lemma for the forward chain. Approach 1 cannot be salvaged without a fundamentally different chain construction.

The `discharge_single_step` infrastructure is correct and useful, but it alone cannot prove `forward_F` for the round-robin chain. The problem is not the step function but the chain's inability to guarantee F-preservation across resolving steps for other formulas.

---

## Key Findings

### 1. The Forward Chain Only Has Forward g_content Propagation

`rr_fwd_chain_g_content_trans` (RootScopedChain.lean, line 689–710):

```
theorem rr_fwd_chain_g_content_trans ... {m n : Nat} (h : m ≤ n) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list m).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list n).val
```

This goes **forward only**: G(φ) ∈ chain(m) implies φ ∈ chain(n) for m ≤ n. There is **no** theorem asserting g_content(chain(n)) ⊆ chain(m) for m ≤ n. The backward direction fails because each chain step uses Lindenbaum extension, which produces an arbitrary MCS extension — it does not preserve any reverse relationship.

### 2. The Approach 1 Argument Has a Fatal Gap

Approach 1 claims: "If G(¬ψ) ∈ chain(n) for some n, then G(G(¬ψ)) ∈ chain(n) by temp_4, so G(¬ψ) ∈ g_content(chain(n)), and... G(¬ψ) propagates to chain(0) = M₀."

**This is false.** g_content propagates FORWARD. G(¬ψ) ∈ chain(n) does NOT imply G(¬ψ) ∈ chain(m) for m < n. The Lindenbaum extension steps go forward in time; backward propagation would require H (past) content, not G (future) content.

The bwd_chain has the reverse property (`bwd_chain_reverse_g` in CanonicalModel.lean, line 306), but the **forward** chain (rr_fwd_chain) has no such reverse lemma, and cannot have one — the forward Lindenbaum steps are irreversible.

### 3. The Correct Direction of Propagation

For the **backward chain** (rr_bwd_chain): g_content(chain(n)) ⊆ chain(m) for m ≤ n. This is proved via `h_content_subset_implies_g_content_reverse` (WitnessSeed.lean line 541), using `past_temp_a`.

For the **forward chain** (rr_fwd_chain): g_content(chain(m)) ⊆ chain(n) for m ≤ n. This uses `all_future_all_future` (temp_4) to push G-formulas forward.

Approach 1 confuses these two directions.

### 4. The discharge_single_step Infrastructure

`discharge_single_step` (RootScopedChain.lean, line 942–949) is correct: given F(ψ) ∈ M for MCS M, it produces M' with ψ ∈ M' and g_content(M) ⊆ M'. However, it gives NO guarantee that F(χ) ∈ M' for any other χ with F(χ) ∈ M. So using discharge_single_step at every step gives: at step n (visiting ψ), ψ ∈ chain(n+1) and g_content(chain(n)) ⊆ chain(n+1), but F(χ) may be lost for other χ.

### 5. What Would Make Approach 1 Work

The Approach 1 argument **would** work if:
- We could prove: if G(¬ψ) appears in any chain step, then G(¬ψ) ∈ M₀, OR
- We could build the chain so that G(¬ψ) never enters any chain step when F(ψ) ∈ M₀.

The first condition fails because forward propagation only goes forward. The second condition is essentially what the f_carry/enriched seed approach was trying to achieve — and is exactly what causes the seed inconsistency problem.

### 6. The Actual State of the Sorry Sites

The 7 sorry sites all ultimately depend on proving `rr_fwd_chain_forward_F`. The comment at line 1118–1132 in RootScopedChain.lean explicitly describes the failed f_carry enrichment approach and its counterexample:

> The consistency proof likely requires showing that g_content(M) cannot derive G(¬χ) for any F(χ) ∈ f_carry(M), combined with the target consistency from forward_temporal_witness_seed_consistent. The standard generalized_temporal_k argument does not directly extend to seeds containing F-formulas alongside G-formulas, because G(F(χ)) ∈ M is not guaranteed from F(χ) ∈ M.

---

## Analysis of Each Sub-Claim of Approach 1

### Sub-claim A: G(¬ψ) cannot propagate to chain(0)

**FALSE.** G-formulas propagate forward in the chain. G(¬ψ) appearing in chain(n) does NOT imply G(¬ψ) in chain(m) for any m < n.

### Sub-claim B: F(ψ) ∈ chain(0) = M₀ contradicts G(¬ψ) ∈ M₀

**TRUE.** This is standard MCS consistency: F(ψ) = ¬G(¬ψ), so both cannot be in M₀. This part is sound and is already proved in `no_new_f_defects` (OrderedSeedConsistency.lean, line 232–247), which shows: if G(¬α) ∈ M, then F(α) ∉ any M' extending g_content(M).

### Sub-claim C: Therefore G(¬ψ) ∉ chain(n) for all n

**CANNOT BE CONCLUDED.** The backward propagation gap makes this unprovable.

### Sub-claim D: So F(ψ) ∈ chain(n) forever, and visit step resolves it

**UNPROVED.** Even if G(¬ψ) ∉ chain(n), this alone does not mean F(ψ) ∈ chain(n) (an MCS can contain neither F(ψ) nor G(¬ψ) — wait, actually in an MCS, exactly one of {F(ψ), G(¬ψ)} holds by negation completeness). So actually sub-claim C DOES imply F(ψ) ∈ chain(n) for all n!

**CRITICAL REVISION:** In an MCS, G(¬ψ) ∉ chain(n) implies F(ψ) ∈ chain(n) by negation completeness. So if sub-claim A could be proved (G(¬ψ) never enters forward chain states after F(ψ) ∈ M₀), then forward_F would follow: F(ψ) persists to every visit step, and discharge_single_step at the visit step gives ψ ∈ chain(visit+1).

**The ONLY gap is Sub-claim A.** If G(¬ψ) backward propagation to M₀ could be proved, the rest works.

---

## Re-evaluation: Can Sub-claim A Be Salvaged?

The backward propagation of G(¬ψ) from chain(n) to chain(0) fails for the forward Lindenbaum chain. However, there is another way to think about this:

**Alternative argument**: At each resolving step using `enriched_fwd_step`, the seed used is determined by `resolving_enriched_fwd_exists`. The BX11 fold produces F(β') ∈ M for some compound β'. The Lindenbaum extension of {β'} ∪ g_content(M) produces M'.

Can G(¬ψ) enter M' even though F(ψ) ∈ M? The seed {β'} ∪ g_content(M) is a subset of M'. If G(¬ψ) ∉ g_content(M) (i.e., G(G(¬ψ)) ∉ M, i.e., GG(¬ψ) ∉ M), then G(¬ψ) is not forced into M' by the seed. But the Lindenbaum extension can freely add G(¬ψ) if it is consistent with the seed.

Since F(ψ) ∈ M and g_content(M) ⊆ M', can F(ψ) ∈ M' hold? Note: F(ψ) = ¬G(¬ψ). If G(¬ψ) ∈ M', then F(ψ) ∉ M'. But F(ψ) ∈ M does NOT force F(ψ) into M' unless F(ψ) ∈ g_content(M) — which requires G(F(ψ)) = G(¬G(¬ψ)) ∈ M. This is not guaranteed from F(ψ) ∈ M alone.

**So G(¬ψ) can legitimately enter chain(n+1) even when F(ψ) ∈ chain(n)**, because the seed only forces g_content(chain(n)) formulas into chain(n+1), and F(ψ) ∈ g_content(chain(n)) would require G(F(ψ)) ∈ chain(n), not just F(ψ) ∈ chain(n).

---

## Recommended Approach

Approach 1 fails. The correct path is **Approach 2 (Dovetailing / ω²-indexed chain)** which addresses the core problem by ensuring ψ gets resolved at infinitely many steps, so even if F(ψ) is lost at some steps, it gets resolved at the infinitely many dedicated steps.

However, the dovetailing approach has its own challenge: it requires F(ψ) to survive to each dedicated step, which is the same preservation problem.

The most promising alternative is to reframe the argument around **what forces F(ψ) to be "eventually" in the chain**. The existing infrastructure `rr_fwd_chain_F_propagate` (line 1071–1096) shows: if F(ψ) ∈ chain(n), then either ψ gets resolved between n and m+1, or F(ψ) ∈ chain(m+1). This is the DISJUNCTIVE preservation that the enriched_fwd_step provides.

The sorry at line 1139 requires ruling out the second case (F(ψ) always in chain, never resolved). This requires showing the "F(ψ) forever" scenario is impossible. The missing ingredient: **why can't F(ψ) persist forever without ψ ever being resolved?**

In classical Burgess/Goldblatt completeness: the schedule visits ψ infinitely often, and at each visit either F(ψ) → ψ (direct) or F(ψ) → F(ψ) (preserved). The "F(ψ) forever, ψ never" scenario is ruled out by BX11's total ordering + the fact that the direct witness must be chosen infinitely often by the fold's witness-tracking property (`enriched_fwd_fold_with_witness`). The witness w directly resolved at each fold IS either target or some other formula — but the fold gives that w ∈ M' directly.

**The key missing lemma**: If F(ψ) ∈ chain(n) for all n ≥ n₀, then at the visit step k (rrSchedule k = ψ, k ≥ n₀), we have F(ψ) ∈ chain(k) and the enriched_fwd_step at k MUST resolve ψ directly (not just F-protect it), because ψ is the TARGET at that step and the fold's witness can only be the target or an earlier formula, but the current enriched_fwd_step_resolves_one (line 622) guarantees SOME formula is resolved — not necessarily ψ.

This is the precise gap: `enriched_fwd_step_resolves_one` guarantees a witness w is resolved, but w might not be ψ.

---

## Evidence

- `rr_fwd_chain_g_content_trans`: RootScopedChain.lean:689 — forward g_content propagation only
- `bwd_chain_reverse_g`: CanonicalModel.lean:306 — backward g_content propagation is for `bwd_chain` ONLY
- `h_content_subset_implies_g_content_reverse`: WitnessSeed.lean:541 — duality between h_content and g_content (uses past axiom past_temp_a)
- `no_new_f_defects`: OrderedSeedConsistency.lean:232 — G(¬α) ∈ M implies F(α) ∉ successors
- `enriched_fwd_step_resolves_one`: RootScopedChain.lean:622 — only guarantees SOME formula is resolved per step
- `discharge_single_step`: RootScopedChain.lean:942 — correct for single-target, no cross-formula protection
- Sorry at line 1139: the primary blocker with comment explaining the difficulty
- Comment lines 1098–1132: explicit statement that "defect count is NOT a valid well-founded measure"

---

## Gaps and Risks

### Gap 1: No backward g_content for forward chain (FATAL for Approach 1)

There is no `rr_fwd_chain_g_content_reverse` and there cannot be one — the Lindenbaum extension goes forward and is irreversible.

### Gap 2: enriched_fwd_step_resolves_one does not guarantee target resolution

The witness w from `enriched_fwd_fold_with_witness` can be ANY formula from tracked ∪ others with F-obligation — not necessarily the target ψ. When ψ is the scheduled target but BX11 fold case 3 fires (F(β) ∧ ψ), a DIFFERENT formula (ψ itself, since it gets the right conjunct) is resolved. Actually wait — in case 3, χ (the new formula being folded in) becomes the direct witness. So if ψ = target is folded first, and then another formula χ triggers case 3, then χ becomes the witness and ψ may only have F-protection.

### Gap 3: Round-robin visits but no guaranteed F-persistence to visit step

Even with enriched_fwd_step_preserves (F(ψ) ∈ chain(n) → ψ ∈ chain(n+1) ∨ F(ψ) ∈ chain(n+1)), reaching the visit step with F(ψ) still present is not guaranteed because the resolving steps for OTHER formulas might place ψ in case 2 (F-protected → F(ψ) survives) or case 3 (F-protected → F(ψ) survives). Actually, checking: in all three BX11 cases, either ψ ∈ M' or F(ψ) ∈ M' is guaranteed by `enriched_fwd_step_preserves`. So F(ψ) DOES persist (as ψ or F(ψ)) to every future step!

**CRITICAL INSIGHT**: The `rr_fwd_chain_F_propagate` theorem (line 1071) says: if F(ψ) ∈ chain(n), then for all m ≥ n, EITHER ψ is in some chain(s) with n < s ≤ m+1, OR F(ψ) ∈ chain(m+1). This IS proved. The sorry in `rr_fwd_chain_forward_F` is about ruling out "F(ψ) ∈ chain(m+1) for ALL m" — i.e., showing the "F(ψ) forever" branch must terminate.

The "F(ψ) forever" scenario needs to be contradicted. The visit step argument: at step k where rrSchedule k = ψ, ψ is the TARGET of enriched_fwd_step. If F(ψ) ∈ chain(k), then by `enriched_fwd_step_spec`, target ∈ M' ∨ F(target) ∈ M'. But we need the LEFT disjunct. The spec only gives disjunction.

However, `enriched_fwd_step_resolves_one` says: ∃ w, w ∈ sigma_list ∧ F(w) ∈ chain(k) ∧ w ∈ chain(k+1). But w might NOT be ψ = target. So at ψ's visit step, some OTHER formula w gets directly resolved, and ψ might only get F-protected.

**This is the precise obstruction**. The fold's witness tracking gives a direct witness, but that witness is NOT guaranteed to be the scheduled target.

---

## Confidence Level

**Confidence: HIGH** that Approach 1 fails for the reasons stated.

**Confidence: HIGH** that the precise obstruction is: `enriched_fwd_step_resolves_one` guarantees a direct witness but not specifically the scheduled target ψ.

**Confidence: MEDIUM** on what the fix should be: Approach 1 needs a modification where the scheduled target ψ is ALWAYS the direct witness when F(ψ) ∈ M. This would require changing the fold to PRIORITIZE the target over other formulas.

**Confidence: HIGH** that if we can prove: "when ψ = target and F(ψ) ∈ M, then ψ ∈ enriched_fwd_step M h_mcs ψ sigma_list" (i.e., the target is always directly resolved when scheduled), then `rr_fwd_chain_forward_F` follows immediately from `rr_fwd_chain_F_propagate` + visit step structure.

---

## New Lemma Needed

The key missing lemma:

```
theorem enriched_fwd_step_resolves_target (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (sigma_list : List Formula)
    (h_target_mem : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ M) :
    ψ ∈ enriched_fwd_step M h_mcs ψ sigma_list
```

This says: when the target IS ψ and F(ψ) ∈ M, then ψ (not just F(ψ)) is directly in the successor MCS.

**This lemma is PROVABLE** because:
1. `resolving_enriched_fwd_exists` with target = ψ produces M' with (target ∈ M' ∨ F(target) ∈ M').
2. But we need LEFT disjunct specifically.
3. The issue: the fold MIGHT put ψ in right disjunct (F-protected).

**Current state**: The fold in `enriched_fwd_fold_with_witness` tracks a direct witness. With target=ψ as initial tracked formula, ψ IS the initial direct witness. In case 1 (F(ψ ∧ χ)) and case 2 (F(ψ ∧ F(χ))), the witness remains ψ (line 291: "Witness stays the same"). In case 3 (F(F(ψ) ∧ χ)), the witness changes to χ (line 338: "Witness CHANGES to χ").

So ψ is the direct witness UNLESS some case 3 fires when ψ is in the left position. Case 3 fires when BX11 gives F(F(ψ) ∧ χ), i.e., χ is "BX11-earlier" than ψ. The enriched_fwd_fold starts with β = target = ψ, and folds in others. If some χ fires case 3 (χ is BX11-earlier than ψ), then χ becomes the witness and ψ only gets F-protection.

**So `enriched_fwd_step_resolves_target` fails when some χ in sigma_list has F(χ) ∈ M and χ is BX11-earlier than ψ** (BX11 gives F(F(ψ) ∧ χ)). In this case, the fold produces χ as direct witness and ψ has only F-protection in M'.

This cannot be fixed without reordering the fold or using a different seed construction.

**CONCLUSION**: To prove forward_F, we need a chain construction where the SCHEDULED target is guaranteed to be directly resolved. The current `enriched_fwd_step` with BX11 fold does not guarantee this. A fix would be to use `discharge_single_step` (which only resolves the target directly with g_content seed) at visit steps — but this loses F-protection for other formulas.

The correct solution is likely: use `discharge_single_step` at visit steps BUT first separately prove that F(ψ) ∈ chain(visit_step) by showing F(ψ) persists. The persistence is guaranteed by `rr_fwd_chain_F_propagate` which shows F(ψ) ∈ chain(m+1) whenever ψ ∉ chain(m+1). So if we run the chain long enough that ψ gets visited while F(ψ) is still present (which is guaranteed by propagation), discharge_single_step at that step resolves ψ.

But the problem is: can we run discharge_single_step at visit steps while running enriched_fwd_step at other steps? This is a hybrid chain that has not been formalized. The existing `rr_fwd_chain` uses `enriched_fwd_step` uniformly. Switching to `discharge_single_step` at visit steps would break F-preservation at non-visit steps (since `discharge_single_step` uses `{ψ} ∪ g_content(M)`, losing other F-formulas).

**FINAL DIAGNOSIS**: The forward_F problem requires the following incompatible properties at each step:
1. When resolving target ψ: ψ ∈ M' (guaranteed by discharge_single_step)
2. When not resolving ψ: F(ψ) ∈ M' (guaranteed by f_carry in non-resolving steps)
3. At both types of steps: F(χ) preserved for ALL χ with F(χ) ∈ M

Property 3 is what causes the seed inconsistency problem documented in the task description. The enriched_fwd_step attempts to solve this via BX11 fold but gives only disjunctive guarantees.

The ONLY known general solution is the dovetailing/ω²-indexed approach (Approach 2), or the quasimodel bridge (Approach 3).
