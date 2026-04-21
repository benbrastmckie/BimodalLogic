# Teammate C: Critical Analysis of Both Approaches

**Task 109 — Close Chain Construction Sorries**
**Role: Critic**
**Date: 2026-04-20**

---

## Summary

After reading `RootScopedChain.lean` in full (1556 lines) and `Axioms.lean`, `CanonicalModel.lean`, and `Construction.lean`, I find that neither proposed approach is ready to close `fwd_chain_forward_F` in its current form. Both proposals contain errors or unjustified assumptions that are either fatal or require substantial revision before they can be implemented.

**Approach 1 (Sigma-restricted defect tracking)** is mathematically coherent in the sense that it correctly identifies the key monotonicity property (`fwd_chain_F_obligation_monotone`, which is already proved in the code). However, the claim that "phi ∈ M' ∩ Sigma clears the defect regardless of F(phi)" is FALSE under the current `defect_step_choice_early` semantics. The step gives `w ∈ M'` where `F(w) ∈ M`, but it gives NO guarantee that `F(phi) ∉ M'` for the resolved formula `w`. Without this, "the defect is cleared" does not mean the F-obligation count decreases.

**Approach 2 (Step-indexed forced resolution)** has a more fundamental flaw: the claim that "resolution by absence of F-obligation is valid" has not been checked against the actual code. The `fwd_chain_forward_F` statement (line 1132) requires `∃ m > n, phi ∈ chain(m)`. It does NOT state that vacuous resolution (phi never forced, but eventually F(phi) ∉ chain(k)) is sufficient. Vacuous resolution proves nothing — we need `phi ∈ chain(m)` for an explicit witness `m`. The descent argument is therefore unsound as stated.

The core obstacle — the "BX11 perpetual deferral obstruction" cited in comments at line 450-458 — has been described as blocking the round-robin approach after 40 rounds of research. The current `preserving_fwd_step` construction was designed to replace round-robin, but the gap in `fwd_chain_forward_F` (line 1134) is explicitly acknowledged in the code comment at lines 1120-1129.

---

## Key Findings

### Critical Flaws in Approach 1 (Sigma-Restricted Defect Tracking)

**Flaw 1.1: "Cleared defect" does not mean F-obligation is removed.**

The claim "phi ∈ M' ∩ Sigma clears the defect regardless of F(phi)" requires that after the step, F(phi) ∉ M'. But `defect_step_choice_early` gives ONLY:
- Some `w ∈ defects` with `w ∈ M'` (resolved)
- `∀ chi ∈ defects, chi ∈ M' ∨ F(chi) ∈ M'` (F-preserved or resolved)

There is no guarantee that `F(w) ∉ M'` for the resolved `w`. In fact under BX (with S5-style modal axioms but no special F-termination axiom), we could consistently have `w ∈ M'` AND `F(w) ∈ M'` simultaneously (w holds now, and still holds in some strict future). This is perfectly consistent with MCS laws.

So `active_defects(M', sigma_list)` might STILL contain `w` even after `w ∈ M'`, because `F(w) ∈ M'` as well. The "cleared" defect is NOT removed from the active set in the next step.

**Flaw 1.2: The Sigma closure does not internalize the oracle.**

The proposal says "internalizes quasimodel oracle at MCS level" and "Resolution of phi where phi ∈ M' ∩ Sigma clears the defect regardless of F(phi)." But clearing from Sigma-restricted defect tracking requires knowing what holds at ALL future steps, not just the next one. The Sigma closure is finite, but whether `phi`'s F-obligation will eventually be discharged depends on the entire future of the chain. The finite sigma closure has no special power to answer this question.

**Flaw 1.3: Circular definition risk.**

The proposal mentions "tracking defects within the finite Sigma closure." But `sigma_list` is already the given parameter to `fwd_chain_of_sigma`. Redefining a "Sigma-restricted defect set" differently from `active_defects` (which already uses sigma_list as filter) just renames the problem. There is no new content here unless the definition of "cleared" is changed — which requires knowing when `F(phi)` is permanently gone, which is exactly what `fwd_chain_forward_F` must prove.

**Flaw 1.4: The needed property is already available but not sufficient.**

`fwd_chain_F_obligation_monotone` (lines 1057-1091) already proves that once `F(chi) ∉ chain(n)`, it never returns. This is the foundation of the "Sigma-restricted" approach. But this is already in the codebase. The missing piece is showing the F-obligation DOES disappear for phi. The approach needs to show the defect set STRICTLY DECREASES, not just that it is non-increasing. The code comment at line 1095-1100 already records `fwd_chain_F_set_nonincreasing` (non-increasing), but the strict-decrease step is what is sorry'd.

---

### Critical Flaws in Approach 2 (Step-Indexed Forced Resolution)

**Flaw 2.1: The goal is NOT vacuous resolution.**

The theorem `fwd_chain_forward_F` (line 1132) states:
```
∃ m, n < m ∧ phi ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val
```
This requires a CONCRETE witness `m` with `phi ∈ chain(m)`. The step-indexed approach attempts to argue that "if F(phi) ∉ chain(k) for all k ≥ n, then the eventuality is vacuously satisfied." But this vacuous satisfaction of F(phi) says NOTHING about whether `phi ∈ chain(m)` for some explicit `m`. These are completely different statements:
- `¬∃ k ≥ n, F(phi) ∈ chain(k)` is about F-formulas.
- `∃ m > n, phi ∈ chain(m)` is about phi itself.

Even if F(phi) ∉ chain(k) for all k ≥ N, it could be the case that phi never appears directly in any chain element — the chain might simply "forget" about phi entirely. This is not prohibited by the chain construction.

**Flaw 2.2: The descent argument for "total F-defect count strictly decreases every L² steps" is unsound.**

The code at lines 1524-1554 provides a detailed strategy for Phase 2, stating:
> "If F(ψ) is killed at step s by a resolving step for χ: then F(χ) was also in chain(n) (since it was in chain(s) and F-obligations only decrease). After χ's resolution, F(χ) may or may not persist, but the total number of other defects whose resolving steps could kill F(ψ) in a FUTURE round strictly decreases."

This argument has a logical gap: killing F(ψ) at step s (i.e., F(ψ) ∉ chain(s+1)) does NOT follow from "a resolving step for χ" unless it can be shown that such a resolving step causes F(ψ) to be excluded from the successor MCS. But `defect_step_choice_early` only guarantees `w ∈ M'` for some resolved `w` — it does NOT force `F(ψ) ∉ M'` for other formulas ψ. The word "killed" in this strategy assumes a property that is not guaranteed by the construction.

**Flaw 2.3: Can discharge_single_step introduce new F-formulas?**

`discharge_single_step` (lines 894-901) constructs M' from seed `{ψ} ∪ g_content(M)` via Lindenbaum extension when `F(ψ) ∈ M`. The result is a general MCS extending this seed. A general MCS can contain ANY consistent formula. In particular, if `ψ` has some `F(θ)` derivable from it (e.g., by some axiom like BX4: `phi → G(P(phi))`), then `F(θ)` might be in M' even if it was not in M. More concretely: the Lindenbaum extension is completely unconstrained beyond the seed. New F-formulas for formulas NOT in sigma_list may enter M', but since `active_defects` only checks sigma_list formulas, this does not affect the defect count. For sigma_list formulas, the preserving step guarantees `chi ∈ M' ∨ F(chi) ∈ M'` for all chi ∈ defects, so no NEW F-obligations for sigma_list formulas enter unless they were already there. This part of Approach 2 appears correct.

**Flaw 2.4: The "L steps between force-resolve steps" framing does not match the actual code.**

The current `preserving_fwd_step` (lines 533-542) uses `defect_step_choice_early` when active defects exist and `fwd_succ` with round-robin when no defects exist. There is no "alternating between preserving steps and forced discharge steps every L steps." The code is a pure defect-driven chain, not a step-indexed alternation. The Approach 2 proposal describes an architecture that is different from what is already implemented, so any argument based on "L steps" must be validated against the actual chain definition.

---

### Derivability Results

**BX12 analysis: Is `F(phi) → (⊤ U phi)` derivable?**

Yes. BX12 (`F_until_equiv`) is axiom constructor:
```
F_until_equiv (φ : Formula) :
  Axiom ((Formula.some_future φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))
```
This IS the axiom `F(φ) → (⊤ U φ)` where ⊤ = (⊥ → ⊥). So this direction is derivable by direct axiom application. The converse `(⊤ U φ) → F(φ)` follows from BX10 (`until_F`). So `F(phi) ↔ (⊤ U phi)` is derivable.

**Is `P(F(phi)) → P(phi) ∨ F(phi)` derivable?**

This is not a direct BX axiom. It would require: if some past point saw a future phi, then either phi is now in the past or in the future. This is a temporal connectedness property. BX4 gives `phi → G(P(phi))` and BX4' gives `phi → H(F(phi))`. These do not directly yield the stated formula. BX9 (`until_elim`) gives `(phi U psi) → (phi ∨ psi)`. The formula `P(F(phi)) → P(phi) ∨ F(phi)` has the flavor of "temporal connectedness" but requires careful derivation. At the MCS level, the evidence from `connect_future_mcs` and related lemmas suggests this is provable via BX4/BX4' but not trivially. This is unlikely to be directly useful for the F-forward problem.

**Key negative result: No BX axiom forces phi into a successor when F(phi) is present.**

Looking at all 35 BX axioms, none states "if F(phi) ∈ M and M' is a g_content-extending MCS, then phi ∈ M'." The F-forward property is an EXISTENCE claim (there exists SOME future MCS containing phi), not a persistence claim about every future step. This is precisely why the round-robin approach was "archived" — `fwd_succ` resolves EXACTLY the formula it targets, and there is no axiom forcing other formulas to be resolved.

---

### active_defects Analysis

**Current definition (lines 470-486):**
```lean
private noncomputable def active_defects (M : Set Formula)
    (sigma_list : List Formula) : List Formula :=
  sigma_list.filter (fun chi => decide (Formula.some_future chi ∈ M))
```

This tracks `chi ∈ sigma_list` with `F(chi) ∈ M`. It does NOT require `chi ∉ M`.

**The claimed correction: add `chi ∉ M` condition.**

If we add the condition `chi ∉ M`, then `active_defects(M, sigma_list) = {chi ∈ sigma_list | F(chi) ∈ M ∧ chi ∉ M}`. The intent is to exclude "already-resolved" formulas from the defect set. This is mathematically motivated: if `chi ∈ M`, the eventuality is already satisfied at M (under reflexive F semantics). But under the project's IRREFLEXIVE semantics (`A2 guard convention`, `BX8/BX8' REMOVED` as noted in the axioms file), `chi ∈ M` does NOT satisfy `F(chi)` because the irreflexive future excludes the current time. So `chi ∈ M` and `F(chi) ∈ M` can coexist: chi holds now AND in some strict future.

**Verdict: The `chi ∉ M` correction is WRONG for irreflexive semantics.**

Under irreflexive F (which is the project's semantics as confirmed by `serial_future` replacing reflexivity and BX8 being removed), we need a FUTURE point containing chi, not just the current MCS. Having `chi ∈ M` does not discharge `F(chi) ∈ M` in any way. The "correction" would remove defects from the active set prematurely, making `active_defects` UNDERCOUNT the true defects. This would corrupt the proof.

**Would the corrected definition help anyway?**

Even if the correction were semantically valid, it would only help if it caused the active defect count to strictly decrease. But the real problem is that `defect_step_choice_early` produces `w ∈ M'` for some resolved `w`, and SIMULTANEOUSLY (under the irreflexive semantics) the next chain MCS might have `F(w) ∈ chain(n+1)` again (since g_content propagation and Lindenbaum extension are unconstrained). The `chi ∉ M` correction addresses the "chi is resolved at M" question, not the "F(chi) leaves the chain" question.

---

## Confidence Level

**High** for the specific code-level observations (what the theorems say, what the construction does).

**Medium** for the claim that the "descent argument" in Approach 2 is fundamentally broken — the argument has the shape of an argument that should work for a well-designed chain, but it does not apply to the current chain without new lemmas showing that resolving `w` at step `s` forces `F(w) ∉ chain(s+1)`.

**Low** for the claim that there exists NO approach that closes `fwd_chain_forward_F` with the current chain design — this may be too pessimistic; a careful "stabilization + singleton-defect" argument could still work.

---

## Recommendations

1. **Reject the `active_defects` correction** (adding `chi ∉ M`). It is wrong under irreflexive semantics and would break existing theorems that depend on the current definition.

2. **For Approach 2**, the descent argument needs a new lemma: given `w ∈ M'` (resolved at step n) via `defect_step_choice_early`, show that `F(w) ∉ M'`. This requires restricting the Lindenbaum extension seed to EXCLUDE `F(w)`, or proving a MCS-level consequence from `w ∈ M'` that blocks `F(w) ∈ M'`. Under irreflexive semantics, `w ∈ M` and `F(w) ∈ M` are not contradictory, so this cannot be an MCS-level fact alone. The forward temporal witness seed would need to be redesigned to produce a "non-revisiting" successor where `w` holds but `F(w)` is forced out.

3. **The cleanest path** is what the code comment at lines 1543-1554 describes for Phase 2: induction on "number of OTHER active defects at step n." This is the right shape, but it requires the new lemma in point 2 above. Without it, the induction step cannot show the count is decreasing.

4. **Consider the singleton-defect case as the base.** `singleton_defect_resolved` (lines 1102-1113) correctly handles the single-defect case: when `active_defects M [phi] = [phi]`, the step resolves phi. The gap is showing we eventually REACH the singleton case. This requires a strict-decrease lemma for the defect count — which requires point 2 above.

5. **For Approach 1 specifically**: the Sigma-restricted framing cannot replace the need for the strict-decrease lemma. It is a renaming of the same problem unless the Lindenbaum seed is redesigned to exclude F-obligations for already-resolved formulas.

---

## Summary of Sorry Sites

Based on the code:

| Sorry Site | Location | Can This Approach Close It? |
|------------|----------|-----------------------------|
| `fwd_chain_forward_F` | RootScopedChain.lean:1134 | Neither approach closes it as stated |
| Backward case of `dd_bfmcs_restricted_tc` | RootScopedChain.lean:1161 | Needs symmetric preserving backward step |
| `dd_bfmcs_restricted_tc` backward-P direction | RootScopedChain.lean:1168 | Same |
| `dd_bfmcs_restricted_buc` | RootScopedChain.lean:1176 | Separate problem (Until/Since coherence) |
| `dd_bfmcs_restricted_fuc` | RootScopedChain.lean:1183 | Separate problem |
| `refl_intro_until_mcs` | Construction.lean:161 | Separate problem (irreflexive semantics) |
| `refl_intro_since_mcs` | Construction.lean:207 | Separate problem |

The keystone `fwd_chain_forward_F` blocks the forward-F part of `dd_bfmcs_restricted_tc`. The BUC/FUC sorries are independent.
