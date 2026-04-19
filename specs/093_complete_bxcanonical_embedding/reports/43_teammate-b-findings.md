# Teammate B: Alternative Approaches - Round 43

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Alternatives (Novel chain constructions)
**Session**: sess_43_teammate_b

---

## Key Findings

### The Three Sorry Sites (Precise Characterization)

After reading the actual code, the three sorry sites are:

1. **`fwd_chain_forward_F`** (RootScopedChain.lean:1090-1111)
   `F(φ) ∈ chain(n) ∧ φ ∈ sigma_list → ∃ m > n, φ ∈ chain(m)`
   The comment (lines 1093-1111) correctly identifies the problem: at each step, some defect `w` is resolved (w ∈ chain(n+1)), F(φ) is preserved, but there is no guarantee that **φ specifically** is ever the resolved defect.

2. **`dd_bfmcs_restricted_tc` backward direction** (line 1138)
   When `t - s < 0`: F(φ) is in the backward chain `bwd_chain_of_sigma`. The backward chain uses `bwd_pred` (not `preserving_fwd_step`), so has no F-preservation guarantee. A symmetric `preserving_bwd_step` is needed.

3. **`dd_bfmcs_restricted_buc`** (line 1153) and **`dd_bfmcs_restricted_fuc`** (line 1160)
   Backward/Forward Until-Since coherence. The comment for `restricted_buc` correctly identifies the step transfer problem: to pull `φ U ψ` from `chain(r+1)` back to `chain(r)`, we need `φ U ψ ∈ chain(r+1) ∧ φ ∈ chain(r) → φ U ψ ∈ chain(r)`. This rule is NOT a theorem of BX.

---

## Rigorous Analysis of Approach #1: Enriched Resolving Seed

### Question: Is `{target} ∪ g_content(M) ∪ f_carry(M)` consistent when `F(target) ∈ M`?

**Answer: NO.** The G-lift argument does NOT extend to f_carry(M).

**The existing proof** (`forward_temporal_witness_seed_consistent`) works because:
- If L ⊆ {target} ∪ g_content(M) is inconsistent, we use G-lift:
  - For χ ∈ L ∩ g_content(M): by definition, G(χ) ∈ M
  - Apply generalized temporal K: G(L_filt) ⊢ G(¬target)
  - So G(¬target) ∈ M, contradicting F(target) ∈ M

**Why f_carry breaks this:** For `F(χ) ∈ f_carry(M)`, we have `F(χ) ∈ M`, but we do NOT have `G(F(χ)) ∈ M` in general. The G-lift requires that for each element χ of the inconsistent subset L, we have `G(χ) ∈ M`. For elements from g_content(M), this holds by definition. For elements from f_carry(M), i.e., formulas of the form `F(α)`, we have `F(α) ∈ M` but NOT `G(F(α)) ∈ M` in general.

**The G-lift would require**: Given L ⊆ {target} ∪ g_content(M) ∪ f_carry(M), inconsistent, and target ∈ L, we need each χ ∈ L \ {target} to satisfy G(χ) ∈ M. But for χ = F(α) ∈ f_carry(M), we only know F(α) ∈ M, not G(F(α)) ∈ M. The G-lift fails.

**The BX12 angle** (`F(ψ) → ⊤ U ψ`): This transforms `F(target) ∈ M` to `(⊤ U target) ∈ M`. But this doesn't rescue the consistency of the enriched seed — it just provides a different Until-witness argument.

**Conclusion**: The enriched seed `{target} ∪ g_content(M) ∪ f_carry(M)` is NOT provably consistent in general. The team task description correctly identifies this — the G-lift argument does not extend.

However, the code already has `enriched_seed_consistent` which proves `SetConsistent (g_content M ∪ f_carry M)`. So the non-resolving case is handled. The problem is exclusively in the **resolving case**.

### What IS Already Proved (The Current Code)

Reading `CanonicalModel.lean` carefully:

- **Non-resolving case** (`F(ψ) ∉ M`): `fwd_succ` uses `g_content M ∪ f_carry M`, which is consistent (proved: `enriched_seed_consistent`). F-formulas in M are preserved via `fwd_succ_f_carry`.
- **Resolving case** (`F(ψ) ∈ M`): `fwd_succ` uses `{ψ} ∪ g_content M` (the standard forward witness seed). F-formulas from `f_carry(M)` may be LOST.

And in `RootScopedChain.lean`, `preserving_fwd_step` uses `defect_step_choice_early`:
- When defects exist: uses `resolving_enriched_fwd_exists` which builds compound β' via BX11 fold, such that for ALL defects, either the defect itself or its F-version is in M'
- When no defects: falls through to `fwd_succ`

The BX11 fold (lines 162-402) is the core innovation. The issue identified in the comment at lines 1093-1111 is correct: the fold guarantees `∀ χ ∈ sigma_list, χ ∈ M' ∨ F(χ) ∈ M'`, but NOT that φ specifically is in M' (only SOME defect w is guaranteed directly in M').

---

## The Real Problem for `fwd_chain_forward_F`

The sorry is at lines 1090-1111. The comment says:

> "Termination argument requires well-founded induction on defect count or a pigeonhole argument."

This is correct. The key mathematical question is:

**Does the defect count ever decrease?**

At each step with active defects, `resolving_enriched_fwd_exists` guarantees `∃ w ∈ defects, w ∈ M'`. But:
- w ∈ M' implies F(w) ∈ M' (by `phi_in_mcs_imp_F_phi_early`)
- So w REMAINS in active_defects of M'

The defect count NEVER decreases from this step alone. This is the "perpetual deferral obstruction" described over 42 rounds.

**But wait**: Can we use the BX11 ORDERING to force φ to eventually be the direct witness?

Looking at `bx11_earlier_total` (line 862): BX11 gives a total preorder on F-defects. The code at lines 959-995 (`target_stays_direct_in_fold`) proves: if target is bx11_earlier than ALL others, then there exists M' with `target ∈ M'` (not just disjunctive).

But φ being the BX11-earliest defect at time n doesn't mean it stays earliest. After resolving it once and getting F(φ) ∈ M', the ordering at M' might be different.

---

## Approach #2: Two-Phase Argument (Indirect F-Preservation)

### Can we prove `fwd_chain_forward_F` by an indirect argument?

The key insight missed in previous rounds: **F-persistence is already proved**.

`fwd_chain_F_persistent` (lines 1071-1083) proves:
```
F(χ) ∈ chain(m) ∧ χ ∈ sigma_list → m ≤ n → F(χ) ∈ chain(n)
```

This holds for ALL χ ∈ sigma_list, forever. So F(φ) ∈ chain(n) for all n ≥ the initial time.

Now the question is: does φ ever appear DIRECTLY (not via F-protection)?

**Claim**: `target_stays_direct_in_fold` (lines 959-995) is the key tool. It says: if target is bx11_earlier than all others at step n, then `target ∈ chain(n+1)`.

**The problem**: At step n, φ might not be bx11_earlier than all other defects. So we need to argue that eventually φ IS the earliest.

### A Potential Approach: BX11 Ordering is Finite and Must Hit φ

Here is a new mathematical angle not in the prior 42 rounds:

**Observation**: sigma_list is finite, say of length k. The BX11 ordering on active defects induces a quasi-minimum (at least one defect is "earlier than or equal to" all others). The `target_stays_direct_in_fold` machinery shows that when φ IS the minimum, it gets resolved.

**Question**: Can the same formula always be the BX11-minimum forever, preventing φ from ever being minimum?

In an MCS M, BX11 gives: `F(ψ₁) ∧ F(ψ₂) → F(ψ₁ ∧ ψ₂) ∨ F(ψ₁ ∧ F(ψ₂)) ∨ F(F(ψ₁) ∧ ψ₂)`.

After step n (resolving w), in M' we have `w ∈ M'` and `F(w) ∈ M'`. The BX11 order at M' may change because the MCS has changed. There is NO guarantee that the ordering at M' is related to the ordering at M in a useful way.

**Conclusion**: This approach requires showing that the BX11 minimum cycles through all defects, which is NOT provable from the BX axioms alone. The non-determinism of Lindenbaum extension prevents any such control argument.

---

## Approach #3: Modified Backward Chain for Restricted_TC Second Sorry

The second sorry (line 1138) is in the backward direction of `restricted_tc`:
```
t - s < 0: F(φ) ∈ bwd_chain(-(t-s)) → ∃ m > t, φ ∈ dd_chain m
```

The forward chain `fwd_chain_of_sigma` has `fwd_chain_forward_F` (sorry). The backward chain uses `bwd_pred` without F-preservation. So BOTH sorry sites for `restricted_tc` depend on the same core obstruction.

**New observation**: The forward sorry (line 1111) and the backward sorry (line 1138) are NOT independent. If we fix `fwd_chain_forward_F`, we need a symmetric proof for the backward direction, which requires a `preserving_bwd_step` with P-preservation. The current code has `bwd_chain_of_sigma` using plain `bwd_pred`, which lacks P-preservation.

---

## Approach #4: Restricted_BUC via BX9 (Until Induction)

The `dd_bfmcs_restricted_buc` sorry (line 1153) needs:
```
φ U ψ ∈ chain(r+1) ∧ φ ∈ chain(r) → φ U ψ ∈ chain(r)  [step transfer]
```

BX9 (until induction): `G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → (φ U ψ → χ)`.
BX9': `H(ψ → χ) ∧ H((φ ∧ χ) → H(χ)) → (φ S ψ → χ)`.

None of these derive the step transfer rule directly. The step transfer is:
`(φ U ψ) → G((φ U ψ) → (φ ∨ ψ)) → ...`

Actually: BX9 with χ = `φ U ψ` gives: `G(ψ → (φ U ψ)) ∧ G((φ ∧ (φ U ψ)) → G(φ U ψ)) → (φ U ψ → (φ U ψ))`. Tautological. The BX unfolding axiom (BX4/BX5): `φ U ψ ↔ ψ ∨ (φ ∧ G(φ U ψ))`.

**Crucial observation**: The `or_until_in_mcs` approach exists in `SuccRelation.lean`. Let me check what `or_until_in_mcs` says and whether it gives the step transfer.

`backward_until_from_step` in `UntilSinceCoherence.lean:111-138` provides the full backward Until proof, parameterized by the step hypothesis:
```
∀ r : Int, (φ U ψ) ∈ fam.mcs (r+1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

**The mathematical question for BUC**: Is there ANY property of `dd_chain` that gives this step?

**BX4 unfolding**: `φ U ψ ↔ ψ ∨ (φ ∧ G(φ U ψ))` (if this axiom is in BX, it gives: `φ U ψ ∈ M ↔ ψ ∈ M ∨ (φ ∈ M ∧ G(φ U ψ) ∈ M)`).

Checking the axiom names: BX5 in the system is likely the unfolding axiom (step unfolding). Let me check what `bx_until_eventuality_resolution` uses — it uses `BX9 + BX10 + bx_forward_witness` (per CanonicalChain.lean comment).

**If BX has `G(φ U ψ) → (φ U ψ)` (T-axiom for G, i.e., temp_t_future)**: Then G(φ U ψ) ∈ M' implies (φ U ψ) ∈ M'. The BX5 unfolding `(φ U ψ) ↔ ψ ∨ (φ ∧ G(φ U ψ))` plus `g_content(chain(r)) ⊆ chain(r+1)` gives:
- If φ U ψ ∈ chain(r+1): NOT immediately ψ ∈ chain(r) or φ ∈ chain(r) ∧ G(φ U ψ) ∈ chain(r)

Wait, but `h_content` propagation goes BACKWARDS: if G(φ U ψ) ∈ chain(r), then φ U ψ ∈ g_content(chain(r)) ⊆ chain(r+1). The reverse is not given by g_content alone.

**The step transfer can be derived IF we have the BX unfolding axiom**:
- BX5: `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))` (unfolding)
- Suppose φ U ψ ∈ chain(r+1), φ ∈ chain(r)
- Want: φ U ψ ∈ chain(r)

From φ U ψ ∈ chain(r+1), by BX5: `ψ ∈ chain(r+1) ∨ (φ ∈ chain(r+1) ∧ G(φ U ψ) ∈ chain(r+1))`.
- If ψ ∈ chain(r+1): By `h_content_subset(chain(r+1)) ⊆ chain(r)`: only if H(ψ) ∈ chain(r+1). But ψ ∈ chain(r+1) doesn't give H(ψ) ∈ chain(r+1).
- If G(φ U ψ) ∈ chain(r+1): By `fwd_chain_reverse_h`: h_content(chain(r+1)) ⊆ chain(r). G(φ U ψ) ∈ chain(r+1) means φ U ψ ∈ g_content(chain(r+1))... no, G(φ U ψ) ∈ chain(r+1) means φ U ψ ∈ g_content(chain(r+1)) ⊆ ... NO. g_content(M) = {α | G(α) ∈ M}. So φ U ψ ∈ g_content(chain(r+1)) iff G(φ U ψ) ∈ chain(r+1). And g_content(chain(r+1)) ⊆ chain(r+2), NOT chain(r).

h_content(chain(r+1)) ⊆ chain(r) means: H(α) ∈ chain(r+1) → α ∈ chain(r). So from G(φ U ψ) ∈ chain(r+1): this means H(φ U ψ) ∈ chain(r+1) would be needed to pull it back. G(φ U ψ) ∈ chain(r+1) only goes FORWARD, not backward.

This direction is genuinely blocked by the chain construction.

---

## Approach #5: Structural Fix — Use `discharge_single_step` for Singleton Defect

Reading the code more carefully: when `active_defects` has exactly ONE formula χ = φ, `defect_step_choice_early` resolves it directly via `discharge_single_step` (line 906-912):
```
theorem discharge_single_step (M) (h_mcs) (ψ) (h_F : F(ψ) ∈ M) :
    ∃ M', M' MCS ∧ ψ ∈ M' ∧ g_content M ⊆ M'
```

This resolves ψ directly without BX11. But then after resolution, `F(ψ) ∈ M'` (by `phi_in_mcs_imp_F_phi`), so ψ remains in active_defects. The defect count doesn't decrease.

**The core mathematical obstruction**: `φ ∈ M → F(φ) ∈ M` (via `phi_imp_F_phi`). This means every resolved defect immediately re-enters the defect set. The defect count is MONOTONE NON-DECREASING, never decreasing.

Therefore, NO argument based on defect count can terminate. The sorry at line 1111 CANNOT be proved using a defect-count decrease.

---

## Approach #6: PIGEON-HOLE / Infinite Resolution

The only viable approach for `fwd_chain_forward_F` is an argument of the form:

**F(φ) ∈ chain(n) → φ ∈ chain(n+1) for some appropriate n**

If we can arrange the chain step so that the SPECIFIC φ (not just some defect) is resolved at step n, we're done.

This requires: at step n, `φ` IS the formula that `defect_step_choice_early` resolves. But `defect_step_choice_early` resolves an ARBITRARY defect from the BX11 fold — not necessarily φ.

**Insight from `resolving_enriched_fwd_exists`**: The resolved formula `w` satisfies `w = target ∨ w ∈ others`. The fold picks `target = defects.head!` (the head of the list). So at each step, the "resolved" formula is determined by the HEAD of `active_defects`.

If we arrange `sigma_list` so that φ is at a SPECIFIC position, and `active_defects` returns the list in a predictable order, we can argue:

At step n, if φ ∈ active_defects then at SOME step n' ≥ n, φ is the head of active_defects.

But `active_defects M sigma_list` is defined as `sigma_list.filter (...)`, so the ORDER is determined by sigma_list. If sigma_list = [φ₁, φ₂, ..., φₖ] and ALL are defects, then the head is always φ₁. This means φ₂, ..., φₖ might NEVER be resolved as the head.

**The Round-Robin Fix**: If we change `preserving_fwd_step` to use a ROTATING head (the current step number n modulo the defect count), then at step n ≡ i (mod k), we try to resolve the i-th defect. This is exactly the original round-robin approach (now archived).

The round-robin approach was archived because it LOST F-obligations at resolving steps. But the BX11 fold approach (`resolving_enriched_fwd_exists`) PRESERVES F-obligations. The question is: can we combine these?

**New idea**: Use `defect_step_choice_early` but with the HEAD of active_defects being a SCHEDULED formula (rotating by step number n). Currently, `defect_step_choice_early` takes `defects` as input and uses `defects.head!`. If we pass `active_defects` in a ROTATED order (rotating by n), we'd get a round-robin that ALSO preserves F-obligations.

Let `rotated_defects M sigma_list n = rotate active_defects by (n mod |active_defects|)`.

At each step n, the head of `rotated_defects` cycles through all active defects. After at most |sigma_list| steps, each original defect must have appeared as head at least once. When φ appears as head:
- `resolving_enriched_fwd_exists` targets φ and guarantees `φ ∈ M' ∨ F(φ) ∈ M'`
- The BX11 fold guarantees ALL other defects have `χ ∈ M' ∨ F(χ) ∈ M'`

But `φ ∈ M' ∨ F(φ) ∈ M'` — we still get the DISJUNCTIVE result for the head.

**UNLESS we use `target_stays_direct_in_fold`**: If φ is BX11-earlier than all others at step n, then `φ ∈ M'` directly (not disjunctive). So:

At step n, among active defects, find the BX11-earliest one (use `bx11_earlier_total` for totality). Call it φ_min. Then `target_stays_direct_in_fold` gives φ_min ∈ M'.

If we could show that each φ ∈ sigma_list is BX11-earliest at some step n, we'd be done. But again, BX11 minimum might never be φ.

**Mathematical obstruction summary**: The BX11 ordering is determined by the CURRENT MCS, not by sigma_list ordering. After any Lindenbaum extension, the new MCS can have an arbitrary BX11 ordering. There is NO mechanism to force φ to become the minimum.

---

## Approach #7: Accept the Sorry / Alternative Completeness Path

The existing code at `dd_countermodel` (line 1164) calls all three sorry theorems. They are necessary for `dd_countermodel`, which is the only completeness path (`bx_completeness` → `dd_countermodel`).

Reading `Completeness.lean`:

```
bx_completeness:
  dd_countermodel → ...
```

**Alternative approach**: Bypass the temporal coherence chain entirely and use the Decidability/FMP path already proved.

The code has:
- `Theories/Bimodal/Metalogic/Decidability.lean`
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean`

The FMP proof uses filtration (finite models), which avoids the infinite chain construction entirely. If BX completeness can be derived from the decidability/FMP results, the chain construction may be unnecessary.

However, reading `Completeness.lean` (line `bx_completeness`) — the proof path needs investigation. If `dd_countermodel` is the ONLY path to `bx_completeness`, then the sorry sites must be addressed.

---

## Critical Assessment of Enriched Resolving Seed Approach

**Summary of Approach #1 analysis:**

The question was: Is `{target} ∪ g_content(M) ∪ f_carry(M)` consistent when `F(target) ∈ M`?

**Definitive answer: NO (not in general, and not provably so).**

The G-lift argument requires G(χ) ∈ M for each χ in the inconsistent subset. For χ ∈ g_content(M), we have G(χ) ∈ M by definition. For χ = F(α) ∈ f_carry(M), we have F(α) ∈ M but G(F(α)) ∈ M is NOT guaranteed (this would require G(F(φ)) for some φ, which requires the 4-axiom direction G(φ) → G(G(φ)) applied backwards — impossible).

**But this doesn't matter**: The code ALREADY uses the non-resolving seed `g_content(M) ∪ f_carry(M)` for non-resolving steps (correct, provably consistent). The issue is ONLY the resolving steps. For resolving steps, the standard `{target} ∪ g_content(M)` is used, which IS consistent. The problem is that f_carry formulas may be lost.

The enriched resolving seed approach would require proving `{target} ∪ g_content(M) ∪ f_carry(M)` consistent, which fails as shown above.

---

## Recommended Approach: Scheduled Resolution via `target_stays_direct_in_fold`

### Core Idea

The BX11 minimum at each step CAN be forced to be the desired target IF we construct the chain with a specific scheduling policy that goes THROUGH the BX11 ordering.

**Lemma (key)**: Given M (MCS) with F-defects {φ₁, ..., φₖ}, there EXISTS an ordering of the defects such that there is a sequence of MCSs M = M₀, M₁, ..., Mₖ where:
- Each Mᵢ₊₁ extends g_content(Mᵢ)
- φᵢ₊₁ ∈ Mᵢ₊₁ (each defect is resolved in some step)

This is exactly what `resolving_enriched_fwd_exists` and `defect_step_early` provide when called for EACH defect separately (not all at once).

But the dd_chain is an Int-indexed chain, so we can't do k steps per "one" step. We need a single forward chain that resolves each defect within a BOUNDED number of steps.

**Revised proposal**: Change `fwd_chain_of_sigma` to:
1. Build a "discharge block" of k steps (one per defect in sigma_list)
2. Each block guarantees ALL defects are resolved at least once
3. Use `discharge_single_step` for each defect in order

The discharge block of k steps:
- Step 1: Use `forward_temporal_witness_seed` with seed `{φ₁} ∪ g_content(M)`. Resolve φ₁.
- Step 2: Use `forward_temporal_witness_seed` with seed `{φ₂} ∪ g_content(M₁)`. Resolve φ₂. But F(φ₁) may NOT be in M₁.

Wait — we're back to the same problem. After resolving φ₁, the next step doesn't necessarily have F(φ₂) anymore.

**Unless**: F(φ₂) ∈ M₀ implies G(F(φ₂)) ∈ M₀ is false. But G(F(φ)) → F(F(φ)) → F(φ). So F(φ) ∈ chain(0) → F(φ) ∈ chain(n) for all n (via `fwd_chain_F_persistent`). So F-persistence IS available for all defects simultaneously.

So at step 1 (building M₁):
- F(φ₁) ∈ M₀ → use `discharge_single_step` → φ₁ ∈ M₁, g_content(M₀) ⊆ M₁
- F(φ₂) ∈ M₀ → need F(φ₂) ∈ M₁. We have: g_content(M₀) ⊆ M₁. Is G(G(F(φ₂))) = G(G(¬G(¬φ₂))) ∈ M₀? This requires G(F(φ₂)) ∈ g_content(M₀), i.e., G(G(F(φ₂))) ∈ M₀. By temp_4 applied to G(¬φ₂): G(G(¬φ₂)) → G(G(G(¬φ₂))). Contrapositive: ¬G(G(G(¬φ₂))) → ¬G(G(¬φ₂)), i.e., F(G(¬φ₂)) → F(¬φ₂)... this is getting circular.

The point is: F(φ₂) ∈ M₀ does NOT imply G(F(φ₂)) ∈ M₀ in general. So F(φ₂) is NOT in g_content(M₀), and after building M₁ using `{φ₁} ∪ g_content(M₀)`, we do NOT know F(φ₂) ∈ M₁.

HOWEVER, via `fwd_chain_F_persistent`: F(φ₂) ∈ chain(0) → F(φ₂) ∈ chain(n) for all n ≥ 0. But this lemma requires that the chain is built with `preserving_fwd_step` which preserves F-obligations! The `discharge_single_step` step does NOT have F-preservation — it only uses `{ψ} ∪ g_content(M)`.

So `discharge_single_step` LOSES F(φ₂).

This means the "discharge block" approach also fails for the same reason.

---

## Fundamental Obstruction (Definitive)

After careful analysis of all approaches, the obstruction is:

**There is no Lindenbaum-based step that simultaneously (a) resolves a specific target φ directly AND (b) preserves F(χ) for all other χ ∈ sigma_list.**

The BX11 fold (`resolving_enriched_fwd_exists`) provides the best of both worlds ONLY DISJUNCTIVELY: for any χ ∈ sigma_list, EITHER χ ∈ M' OR F(χ) ∈ M'. This is NOT sufficient to prove that F(χ) ∈ M' when χ ∉ M'. The disjunction means sometimes the fold "resolves" χ directly (deleting F(χ) from next-step defects), but we cannot control which.

**The sorry at line 1111 is genuinely hard.** It requires either:
1. A proof that the BX11 fold minimum cycles through all defects (uncontrolled, likely false)
2. A different chain construction that provides controlled resolution
3. A bypass via FMP/decidability results that avoids this chain entirely

---

## Evidence/Examples

### Code Evidence

1. `CanonicalModel.lean:51-72` — `enriched_seed_consistent` proves `g_content(M) ∪ f_carry(M)` consistent. This is already used. The enriched RESOLVING seed `{target} ∪ g_content(M) ∪ f_carry(M)` is NOT proved consistent and likely fails for the reasons described.

2. `RootScopedChain.lean:505-529` — `defect_step_early` guarantees `∃ w ∈ defects, w ∈ M' ∧ F(w) ∈ M'` and `∀ χ ∈ defects, F(χ) ∈ M'`. The ALL F-preservation IS proved. But the target φ may equal w or not.

3. `RootScopedChain.lean:1071-1083` — `fwd_chain_F_persistent` proves F-persistence. This is a COMPLETED proof. It confirms F(φ) stays in the chain forever.

4. `RootScopedChain.lean:1090-1111` — The sorry. The comment correctly identifies the issue.

5. `UntilSinceCoherence.lean:111-138` — `backward_until_from_step` reduces BUC to the step transfer property. The step transfer is the only unproved piece.

### Mathematical Evidence for Obstruction

**Counterexample sketch** for enriched resolving seed:

Consider an MCS M containing: `F(p)`, `F(q)`, and suppose the underlying model has `G(¬G(¬q)) = G(F(q))` ABSENT from M (which is consistent with `F(q) ∈ M` since F(q) ↔ ¬G(¬q) and G(F(q)) = G(¬G(¬q)) is a stronger statement).

Then f_carry(M) ∋ F(q). The enriched resolving seed `{p, F(q)} ∪ g_content(M)`.

Suppose p → ¬q is provable (or in g_content(M)). Then p ∈ M' → ¬q ∈ M', so q ∉ M'. But F(q) ∈ M' and F(q) → ¬G(¬q). Actually this doesn't immediately give inconsistency.

The G-lift argument needs: for any L ⊆ {p, F(q)} ∪ g_content(M) with L ⊢ ⊥, we need G(each element of L) ∈ M. For F(q) ∈ L, we'd need G(F(q)) ∈ M. If G(F(q)) ∉ M (consistent), the proof fails.

---

## Confidence Level

- **Approach #1 (enriched resolving seed) analysis**: 95% confidence it CANNOT work as stated. The G-lift failure is definitive.
- **`fwd_chain_forward_F` is genuinely hard**: 90% confidence. The perpetual deferral obstruction holds for all Lindenbaum-based constructions.
- **`restricted_buc` step transfer**: 85% confidence no BX-derivable rule gives the step. The semantic counterexample from Round 40 confirms this.
- **FMP/decidability bypass**: 70% confidence this is the most promising alternative path. The BX completeness proof may be derivable from the FMP theorem using the completeness-via-FMP pattern from Blackburn/Venema.

---

## Priority Recommendation

1. **Immediate**: Verify whether `bx_completeness` has an alternative proof path via the `Decidability/FMP` infrastructure already in the codebase. Reading `Completeness.lean` carefully to see if there is another route.

2. **Medium term**: Investigate whether the restricted sorry sites can be proved using the `or_until_in_mcs` property from `SuccRelation.lean` combined with the BX5 unfolding axiom. The step transfer for BUC may be derivable if BX includes the Until-unfolding axiom `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))` (not just BX9-BX12 but the full LTL-style unfolding).

3. **Long term**: Consider whether the sigma_list scheduling approach can be implemented with a FIFO queue where each defect is forced to the head at regular intervals — this changes `preserving_fwd_step` from set-based to position-based scheduling.
