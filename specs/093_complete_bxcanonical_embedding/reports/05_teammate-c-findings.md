# Teammate C (Critic) — Critical Analysis of Proposed Approaches

- **Task**: 93 - Complete BXCanonical embedding
- **Role**: Critic (Teammate C)
- **Artifact**: 05
- **Date**: 2026-04-13

---

## Summary

This report critically examines the proposed "restricted temporal coherence + deferral seeds" approach (Plan 04, Phases 2–3) for closing the remaining 6 sorry sites in `CanonicalModel.lean`. The analysis covers seven specific questions about correctness, feasibility, and soundness. Several significant gaps and risks are identified, along with a previously unnoticed critical blocker.

---

## Key Findings

### 1. Is the Deferral Seed Modification Actually Necessary?

**Answer: Yes, but the plan's characterization is partly misleading.**

The question asks whether F-formulas might propagate automatically via the BX4 axiom `connect_future: φ → G(P(φ))`. This gives G(P(φ)) from φ, not G(φ ∨ F(φ)). There is no BX axiom giving `G(φ ∨ F(φ))` from `F(φ)`.

The candidate axiom would need to be: `⊢ F(χ) → G(χ ∨ F(χ))`. This is NOT a BX axiom (not listed in `Axioms.lean`). The closest is BX12 `F(φ) → (⊤ U φ)`, but this doesn't give G-propagation of the disjunction.

**However**, examining the existing `CanonicalModel.lean` more carefully reveals that the current `fwd_succ` already uses `f_carry` for non-resolving steps:
- At non-resolving steps: seed is `g_content(M) ∪ f_carry(M)`, preserving F-formulas
- At resolving steps (for F(ψ) ∈ M): seed is `forward_temporal_witness_seed M ψ = {ψ} ∪ g_content(M)`, which drops all *other* F-formulas

The current code (lines 72–114) already handles persistence at non-resolving steps via `f_carry`. The problem is exclusively at resolving steps, where f_carry is excluded. The deferral seed approach (using `deferralDisjunctions` everywhere) is the proposed fix for this.

**New critical concern found**: The `successor_deferral_seed_consistent` theorem in `SuccExistence.lean` (line 766–815) requires `h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u` as a precondition. This means every chain element must contain F(⊤). This requirement must be discharged, and it is NOT currently threaded through `fwd_succ`/`bwd_pred` in `CanonicalModel.lean`. See Finding 3 for analysis.

### 2. Circular Dependency Risk

**Finding: No circular dependency, but forward_F depends on a new ingredient not yet present.**

The dependency graph is:
- `restricted forward_F` requires: modified chain with deferral seeds (Phase 2) + well-founded induction on F-depth in `deferralClosure`
- `restricted_buc` (backward Until coherence) requires: step-transfer, which requires: `backward_until_from_step` (already in `UntilSinceCoherence.lean`, parameterized by step hypothesis)
- `restricted_fuc` (forward Until coherence) requires: forward_F for `F(ψ)` when `(φ U ψ) ∈ chain(t)` (via `until_F` axiom: `(φ U ψ) → F(ψ)`)

**The circular risk**: `restricted_fuc` for Until needs forward_F. Forward_F is in Phase 3. They are listed as parallel, but in the plan, Phase 3 covers both. The plan's Phase 3 tasks list these sequentially (forward_F first, then fuc), so there is no actual circular dependency — but the plan does not make this ordering explicit.

**Additional dependency concern**: `backward_until_from_step` requires a step-transfer hypothesis of the form:
```
(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)
```
This step does NOT follow from `g_content` propagation (which goes FORWARD). Proving this for the modified deferral chain requires a new argument not present in any of the infrastructure files. This is the most significant gap in the plan — see Finding 5.

### 3. F(⊤) Requirement for Deferral Seed Consistency

**Finding: F(⊤) is a theorem in BX, so it is in every MCS. The requirement is satisfiable.**

From `SuccChainFMCS.lean` (Boneyard), the proof that `F_top_theorem : [] ⊢ F_top` is:
1. BX1 (temp_t_future): `G(¬¬⊥) → ¬¬⊥`
2. Double negation elimination: `¬¬⊥ → ⊥`
3. Composition: `G(¬¬⊥) → ⊥`, i.e., `¬G(¬¬⊥)`, i.e., `F(¬⊥) = F_top`

This proof lives in the Boneyard module. It needs to be resurrected or reproduced in the main codebase for the BXCanonical chain. Specifically, any call to `successor_deferral_seed_consistent` requires `F_top ∈ u`, which requires the theorem `∀ M, SetMaximalConsistent M → F_top ∈ M` — analogous to `SetMaximalConsistent.contains_F_top` in the Boneyard.

**This theorem is NOT currently present in the main codebase** (confirmed by searching `Theories/Bimodal/Metalogic/BXCanonical/`). It must be added as a prerequisite to Phase 2. This is a gap in the plan.

**Propagation to negative times**: At backward chain steps, `successor_deferral_seed_consistent` would be replaced by the predecessor analog, requiring `P_top ∈ u`. Similarly, `P_top_theorem : [] ⊢ P_top` is provable by duality (in Boneyard), ensuring `P_top ∈ chain(t)` for all t.

### 4. The Schedule Interaction Problem

**Finding: Deferral seeds subsume the schedule mechanism, but the plan conflates two different chain architectures.**

The current chain uses a resolving/non-resolving dichotomy driven by `schedule n`. The plan's Phase 2 says to replace `fwd_succ` with a version using `successor_deferral_seed`. But:

1. `successor_deferral_seed(M) = g_content(M) ∪ deferralDisjunctions(M)` contains `φ ∨ F(φ)` for every `F(φ) ∈ M`.
2. The Lindenbaum extension of this seed picks, for each F(φ), either φ (resolve) or F(φ) (defer).
3. This is NON-DETERMINISTIC — the Lindenbaum lemma (`Classical.choice`) makes no guarantee about which branch is chosen.

If the deferral seed replaces the schedule entirely, we lose the property that every formula is eventually resolved. The deferral seed approach from `SuccExistence.lean` was designed for a SINGLE successor step (proving `successor_exists`), not for an infinite chain where every F-obligation must eventually be resolved.

**Critical gap**: The plan says to "modify fwd_succ to use successor_deferral_seed", but this replaces both the resolving AND non-resolving behavior. Without the schedule, F(φ) could be deferred forever (the Lindenbaum extension might always choose F(φ) over φ). The `successor_exists` theorem proves one successor exists; it does not prove forward_F.

The correct approach would be:
- Keep the schedule at resolving steps (to ensure eventual resolution)
- At non-resolving steps, use deferral seeds instead of `f_carry`

But the plan as written conflates these, and the prior research's recommendation to "replace forward_temporal_witness_seed with successor_deferral_seed" is ambiguous about whether this applies at resolving or non-resolving steps or both.

### 5. Until/Since Coherence Gap — The Backward Step Transfer

**Finding: The step transfer for backward Until is the hardest unresolved gap.**

`backward_until_from_step` (in `UntilSinceCoherence.lean`, lines 111–138) is parameterized by:
```
h_step : ∀ r : Int, (φ U ψ) ∈ fam.mcs (r+1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

This step does NOT follow from:
- `g_content` propagation (goes forward: `G(α) ∈ chain(r) → α ∈ chain(r+1)`)
- `h_content` duality (goes backward for H-formulas, not Until)
- Any BX axiom directly (the relevant axiom would be something like "φ U ψ ∈ v ∧ G(φ U ψ → φ) → φ U ψ ∈ predecessor", which doesn't exist)

The comment in `UntilSinceCoherence.lean` (lines 30–45) explicitly states this is NOT derivable from the bare FMCS structure and requires "additional chain properties." The plan (Phase 3) says to prove step-transfer "via the chain's g_content propagation" — but this direction is wrong. `g_content` gives forward transfer, not backward.

The plan's note says: "The step transfer for Until: `Until(phi, psi) in chain(t+1)` and `phi in chain(t)` implies `Until(phi, psi) in chain(t)` via `backward_until_from_step`." This is circular — it appeals to the theorem parameterized by the step, rather than providing the step itself.

**What would actually provide the step**: If the chain has a succ relation `Succ(chain(t), chain(t+1))` where `Succ(u,v)` requires `p_content(v) ⊆ u ∪ p_content(u)` (the P-step guarantee), then:
- `(φ U ψ) ∈ chain(t+1)` means F(ψ) ∈ chain(t+1)` (by `until_F`)
- If the chain is deterministic with a bot-Until linking, we'd have the step
- But under BX reflexive semantics, the deterministic chain collapses (as noted in UntilSinceCoherence.lean, line 32)

The constrained successor from `SuccExistence.lean` provides a P-step guarantee but that restricts **P-formulas** in the successor back to the predecessor, not Until formulas. Under BX reflexive semantics, `(φ U ψ) ∈ v` does NOT imply `(φ U ψ) ∈ predecessor(v)` without additional axioms or chain properties.

**Potential approach not discussed in prior research**: BX5 (self-accumulation): `(φ U ψ) → (φ ∧ (φ U ψ)) U ψ`. This enriches the guard to include `(φ U ψ)` itself. If `(φ U ψ) ∈ chain(t+1)`, then `G(φ U ψ → ...)` might be derivable... but this still requires showing the Until formula propagates backward, which is the same problem.

Another potential: BX4 `connect_future: φ → G(P(φ))`. If `(φ U ψ) ∈ chain(t+1)`, then `G(P(φ U ψ)) ∈ chain(t+1)`, so `P(φ U ψ) ∈ chain(t+1)`. Then by `h_content`: `(φ U ψ) ∈ chain(t)`. **This could work!** The proof:
1. `(φ U ψ) ∈ chain(t+1)` (hypothesis)
2. By BX4: `(φ U ψ) → G(P(φ U ψ))` is provable
3. MCS closure: `G(P(φ U ψ)) ∈ chain(t+1)`
4. By `h_content` (the reverse inclusion already proven): `P(φ U ψ) ∈ chain(t+1)` → ... wait, h_content goes the OTHER way: `H(α) ∈ chain(t+1) → α ∈ chain(t)`, not `P(α) ∈ chain(t+1) → ... ∈ chain(t)`.

More carefully: BX4 says `φ → G(P(φ))`. So `(φ U ψ) ∈ chain(t+1)` → `G(P(φ U ψ)) ∈ chain(t+1)`. The g_content propagation goes: if `G(α) ∈ chain(t+1)`, that does NOT mean `α ∈ chain(t)`. However, `fwd_chain_reverse_h`: if `g_content(chain(t)) ⊆ chain(t+1)`, then `h_content(chain(t+1)) ⊆ chain(t)`. And `G(P(φ U ψ)) ∈ chain(t+1)` means `P(φ U ψ) ∈ h_content(chain(t+1))` (wait: h_content(M) = {χ | H(χ) ∈ M}; but we have G(P(φ U ψ)) ∈ chain(t+1), which means P(φ U ψ) ∈ g_content(chain(t+1))).

So: `P(φ U ψ) ∈ g_content(chain(t+1))` means `G(P(φ U ψ)) ∈ chain(t+1)` ✓. g_content propagates forward, so this doesn't immediately give us chain(t).

Actually re-reading: `g_content(chain(t)) ⊆ chain(t+1)` is the forward direction. The reverse direction is `h_content(chain(t+1)) ⊆ chain(t)` (proven as `fwd_chain_reverse_h`). h_content(M) = {χ | H(χ) ∈ M}. So if `H(P(φ U ψ)) ∈ chain(t+1)`, then `P(φ U ψ) ∈ chain(t)`. But we have `G(P(φ U ψ)) ∈ chain(t+1)`, not `H(P(φ U ψ))`.

With BX1 (reflexive G): `G(P(φ U ψ)) → P(φ U ψ)`, so `P(φ U ψ) ∈ chain(t+1)`. That gives us P(φ U ψ) at t+1, not at t.

Using BX4' (connect_past: `φ → H(F(φ))`): This goes the other direction.

**Alternative via BX4**: `(φ U ψ) ∈ chain(t)` (this is what we want to show, not what we have). We have `(φ U ψ) ∈ chain(t+1)`. We need `(φ U ψ) ∈ chain(t)`. We also have `φ ∈ chain(t)`.

Apply BX4 at chain(t+1): `(φ U ψ) ∈ chain(t+1) → G(P(φ U ψ)) ∈ chain(t+1)`. Using temp_4 on chain(t+1): `G(P(φ U ψ)) ∈ chain(t+1) → G(G(P(φ U ψ))) ∈ chain(t+1)`. Using `fwd_chain_reverse_h` at step t: `G(P(φ U ψ)) ∈ chain(t)`. By BX1: `P(φ U ψ) ∈ chain(t)`. This says P(φ U ψ) holds at t. But from φ U ψ at t+1 and φ at t, we want φ U ψ at t.

P(φ U ψ) at t means "sometime in the past of t, φ U ψ held." If P(φ U ψ) ∈ chain(t), by backward_P coherence (if we had it), there exists s < t with (φ U ψ) ∈ chain(s). But this is not (φ U ψ) ∈ chain(t) — it's earlier!

**Conclusion**: The BX4 approach does NOT directly give the step transfer. The step transfer for backward Until is genuinely hard for the BX reflexive chain and has no straightforward proof. This is the deepest unresolved gap.

### 6. Existing Chain vs. New Chain — Is Modification Unavoidable?

**Finding: Chain modification is unavoidable for forward_F. The plan underestimates the complexity.**

For `bx_fmcs_forward_F` (line 495): If F(ψ) ∈ chain(t) where ψ ∈ deferralClosure(root), then we need ∃ s > t with ψ ∈ chain(s).

With the CURRENT chain (`f_carry` mechanism):
- If F(ψ) ∈ chain(t), it is preserved at non-resolving steps via f_carry
- At the resolving step for F(ψ) (which appears infinitely often in the schedule), ψ is placed in the successor
- So the current chain actually DOES give forward_F eventually

**Wait — this is a critical observation**: The f_carry mechanism already handles the case where F(ψ) ∉ M₀ initially — it preserves F-formulas through non-resolving steps until the resolving step fires. The issue mentioned in the plan summary ("at resolving steps for a different formula, F(ψ) may be dropped") is for the case where the resolving step is for F(χ) with χ ≠ ψ, and F(ψ) is in f_carry of M but the seed is `{χ} ∪ g_content(M)` (dropping f_carry).

Looking at the current `fwd_succ` code (lines 72–114): at resolving steps, the seed is `forward_temporal_witness_seed M ψ = {ψ} ∪ g_content(M)`, which does NOT include f_carry(M). So if F(φ) ∈ M for φ ≠ ψ, F(φ) is NOT in the seed at the resolving step for ψ.

But: `F(φ) ∈ M` and `g_content(M) ⊆ successor`. Does F(φ) ∈ M imply G(F(φ)) ∈ M? No, not in general. Does it imply G(φ ∨ F(φ)) ∈ M? Not by any BX axiom we have.

**However**: the schedule hits every formula infinitely often. So after the resolving step for F(ψ) at step n, we have ψ ∈ chain(n+1). If F(φ) was in chain(n) but not in chain(n+1) (dropped at the resolving step), then F(φ) needs to re-enter the chain. It will only re-enter if F(φ) or G(F(φ)) is in chain(n+1)'s seed.

If F(φ) ∉ chain(n+1), then chain(n+1) contains ¬F(φ) = G(¬φ), which means chain(n+2) contains ¬φ (by g_content → chain(n+2)). At that point, F(φ) ∈ chain(n+1) is false, and we have G(¬φ) propagating. This is the completeness failure — an F-obligation disappears permanently when dropped at a resolving step.

**Conclusion**: Chain modification IS necessary. But the modification must be surgical: only at resolving steps, we need to also preserve other F-formulas, not just the one being resolved.

### 7. Restricted Scope Sufficiency and Closure Compatibility

**Finding: The restricted scopes are compatible but the plan confuses which closure applies where.**

The plan uses:
- `deferralClosure(root)` for temporal coherence (forward_F/backward_P)
- `subformulaClosure(root)` for Until/Since coherence

From the code:
- `deferralClosure = closureWithNeg ∪ deferral disjunctions ∪ seriality formulas`
- `closureWithNeg ⊇ subformulaClosure`
- So `deferralClosure ⊇ subformulaClosure`

**Compatibility check**: Is every component of a Until subformula also in the appropriate closure?
- If `(φ U ψ) ∈ subformulaClosure(root)`, then both φ and ψ are in `subformulaClosure(root)` (by `closure_untl_left` and `closure_untl_right` in SubformulaClosure.lean)
- ψ ∈ subformulaClosure(root) ⊆ deferralClosure(root) ✓
- neg(ψ) ∈ closureWithNeg(root) ⊆ deferralClosure(root) ✓

**However**: The `restricted_forward_until_since_coherent` definition requires `(φ U ψ) ∈ subformulaClosure(root)`. From this we can derive `F(ψ) ∈ deferralClosure(root)` (since ψ ∈ subformulaClosure ⊆ deferralClosure, and F(ψ) = ¬G(¬ψ) = neg of an H-formula... actually F(ψ) may NOT be in deferralClosure directly).

**New gap identified**: `F(ψ)` where ψ ∈ subformulaClosure(root) — is `F(ψ)` in deferralClosure(root)?
- deferralClosure includes `{χ ∨ F(χ) | F(χ) ∈ closureWithNeg}`, NOT F(χ) itself (only the disjunction)
- F(ψ) ∈ closureWithNeg only if F(ψ) is a subformula of root or the negation of a subformula
- If ψ is a subformula but F(ψ) is NOT a subformula (i.e., F(ψ) doesn't appear in root), then F(ψ) ∉ deferralClosure

This means: when proving forward Until coherence for `(φ U ψ) ∈ chain(t)`, the plan needs F(ψ) ∈ deferralClosure(root) to apply restricted forward_F. But F(ψ) may not be in deferralClosure if the root formula doesn't contain F(ψ) as a subformula. The axiom `until_F: (φ U ψ) → F(ψ)` gives `F(ψ) ∈ chain(t)`, but then to get a witness for F(ψ), we need `F(ψ) ∈ deferralClosure(root)`, which requires `ψ ∈ subformulaClosure` AND `F(ψ) ∈ closureWithNeg`.

If root = `φ U ψ`, then `F(ψ)` IS in subformulaClosure only if it appears literally in the root. If root is more complex and `φ U ψ` is a subformula, `F(ψ)` may not be.

This is a potential soundness gap in the scoping of the restricted coherence definitions.

---

## Gaps Identified

1. **F(⊤) theorem not in main codebase**: `SetMaximalConsistent.contains_F_top` exists only in the Boneyard. Plan must add it to the main code before Phase 2 can proceed.

2. **Step transfer for backward Until is not proven and has no clear path**: The plan says step-transfer follows from "g_content propagation," which is false. The BX4 approach was analyzed above and does not directly provide the step transfer. This may require either: (a) a novel chain property, (b) a direct MCS-level argument using BX axioms that has not been identified, or (c) a different proof structure for backward Until that bypasses step transfer.

3. **Phase 2 description confuses complete replacement vs. targeted modification**: Using `successor_deferral_seed` uniformly (at every step) replaces the schedule mechanism. The schedule is needed for eventual F-resolution. The correct approach preserves the schedule at resolving steps while using deferral disjunctions at non-resolving steps (or additionally at resolving steps, supplementing the existing seed).

4. **`F(ψ)` may not be in deferralClosure when needed for forward Until coherence**: If `φ U ψ ∈ subformulaClosure(root)` but `F(ψ) ∉ subformulaClosure(root)`, the restricted temporal coherence may not apply to `F(ψ)`.

5. **The restricted forward Until coherence (fuc) plan is underdeveloped**: The plan (Phase 3 task "Prove bx_bfmcs_fuc") describes "use BX9 to get ψ ∈ chain(t) or φ ∈ chain(t)." But BX9 gives `φ ∨ ψ`, not a witness with guard. The full forward Until coherence requires:
   - If ψ ∈ chain(t): witness s = t (reflexive case, guard vacuously holds) ✓
   - If φ ∈ chain(t) but ψ ∉ chain(t): need s > t with ψ ∈ chain(s) and φ on [t,s). This requires propagating the Until obligation forward (using g_content? Only if G(φ U ψ) ∈ chain(t)), which requires G(φ U ψ) ∈ chain(t), which requires... another sorry.

6. **Plan does not address what happens to forward Until when only the "φ branch" of BX9 applies**: This case needs F(ψ) ∈ chain(t) (which requires ψ ∈ deferralClosure, gap 4), and then restricted forward_F to get the witness. The guard condition (φ at all intermediate points) then requires either additional chain properties or BX5/BX6 arguments that are not spelled out.

---

## Risk Assessment

| Gap | Severity | Blocking? |
|-----|----------|-----------|
| F(⊤) theorem missing from main codebase | Medium | Yes for Phase 2 deferral seeds |
| Backward Until step transfer not proven | High | Yes for bx_bfmcs_restricted_buc |
| Phase 2 conflates resolving/non-resolving modification | High | Yes — wrong approach could break existing proofs |
| F(ψ) ∉ deferralClosure for Until subformulas | Medium | Possibly for bx_bfmcs_restricted_fuc |
| Forward Until φ-branch case underdeveloped | High | Yes for bx_bfmcs_restricted_fuc |

---

## Confidence Assessment

- Finding 1 (deferral necessity): HIGH confidence. F(⊤) precondition gap is confirmed from code.
- Finding 2 (circular dependencies): HIGH confidence. No circularity, but ordering implicit.
- Finding 3 (F(⊤) in chain): HIGH confidence. F_top_theorem provable, but not in main codebase.
- Finding 4 (schedule interaction): HIGH confidence. Plan conflates two architectures.
- Finding 5 (backward step transfer): HIGH confidence. No proof strategy identified. Critical blocker.
- Finding 6 (existing vs new chain): HIGH confidence. Modification IS necessary.
- Finding 7 (closure compatibility): MEDIUM confidence. F(ψ) ∉ deferralClosure gap needs verification.

---

## Recommendations

1. **Preserve the schedule mechanism** at resolving steps. Modify Phase 2 to use deferral seeds only at non-resolving steps (replacing `g_content ∪ f_carry` with `successor_deferral_seed`), while keeping `forward_temporal_witness_seed` at resolving steps but ALSO including deferral disjunctions for other F-formulas (i.e., `{ψ} ∪ g_content(M) ∪ deferralDisjunctions(M)`). This ensures the resolved formula is witnessed AND other F-obligations are preserved.

2. **Add F_top_theorem to the main codebase** as a separate lemma in `CanonicalModel.lean` or a new `MCSSerialityProperties.lean`. This is a mechanical port from `SuccChainFMCS.lean` (Boneyard).

3. **Reconsider backward Until coherence strategy**. The parameterized approach in `UntilSinceCoherence.lean` requires a step transfer that appears genuinely hard. Consider instead a direct proof using BX4's `φ → G(P(φ))` applied to the Until formula itself: if `(φ U ψ) ∈ chain(t+1)`, then `G(P(φ U ψ)) ∈ chain(t+1)`, and by temp_4 on chain(t+1) we get `G(G(P(φ U ψ))) ∈ chain(t+1)`, then by `fwd_chain_reverse_h`, `G(P(φ U ψ)) ∈ chain(t)`, and by BX1, `P(φ U ψ) ∈ chain(t)`. Then by backward_P (which we have), there exists s < t with `(φ U ψ) ∈ chain(s)`... but this gives s < t, not s = t. Needs careful treatment.

4. **For forward Until coherence**, verify that F(ψ) ∈ deferralClosure(root) when (φ U ψ) ∈ subformulaClosure(root). Check whether deferralClosure includes F-formulas of subformulas.
