# Teammate C (Critic) Findings -- Task 109

## Key Findings

### 1. Sorry Count Is Accurate for the Named Files, But the Report Misses the Full Picture

**Confidence: HIGH**

The report correctly identifies 6 sorries in CanonicalModel.lean and 5 in RootScopedChain.lean (11 total). I verified this by grep:

- CanonicalModel.lean: lines 56, 101, 117, 167, 207, 213
- RootScopedChain.lean: lines 1065, 1092, 1099, 1107, 1114

However, there are **additional sorries on adjacent files** that the report does not discuss:

| File | Line | Theorem | On Critical Path? |
|------|------|---------|-------------------|
| TruthLemma.lean | 293 | `until_backward_refl_mcs` | **NO** -- not referenced elsewhere |
| TruthLemma.lean | 317 | `since_backward_refl_mcs` | **NO** -- not referenced elsewhere |
| Frame.lean | 205 | `bx_le_refl` | **NO** -- not referenced elsewhere |
| Quasimodel/Construction.lean | 161, 207 | 2 sorries | **NO** -- not imported |
| Quasimodel/Realization.lean | 67, 73, 197, 249 | 4 sorries | **NO** -- not imported |
| Filtration/SigmaOrdering.lean | 82, 99, 143 | 3 sorries | **NO** -- not imported |

None of these extras are on the active completeness path (`bx_completeness` -> `dd_countermodel` -> RootScopedChain). The report's 11 are the correct set of blocking sorries.

### 2. The "Genuinely False" Claims for #5 and #6 Are Correct

**Confidence: HIGH**

`g_content_subset_self` claims `g_content M ⊆ M`, i.e., `G(phi) in M => phi in M`. This is exactly the T-axiom `G(phi) -> phi`. Under irreflexive semantics, G is strict-future ("for all t' > t"), so `G(phi)` at time t says nothing about phi at t itself. The axiom system has `serial_future` (T -> F(T)) instead of the reflexivity axiom `G(phi) -> phi`. So **these theorems are genuinely false** -- there exist MCS containing G(phi) but not phi.

Note: the axiom system DOES still have `modal_t: Box(phi) -> phi` for the modal operator, but NOT for the temporal G operator. This is a crucial distinction.

### 3. The "Genuinely Unprovable" Claims for #2 and #4 Are Correct But Misleadingly Stated

**Confidence: HIGH**

`fwd_succ_f_carry` (line 98-101) states that when `F(psi) not in M`, then `f_carry(M) ⊆ fwd_succ M h_mcs psi`. The non-resolving branch seeds with `g_content(M)` alone (line 68-69). Since `g_content(M) = {phi | G(phi) in M}` and `f_carry(M) = {phi in M | exists chi, phi = F(chi)}`, there is no reason F-formulas would appear in a Lindenbaum extension of g_content(M). The F-formulas are existential claims that g_content (universal content) cannot guarantee.

**However**, this theorem is also **dead code**. `fwd_succ_f_carry` is not called anywhere in the active completeness path. The active path uses `preserving_fwd_step` (RootScopedChain.lean:533) which handles F-preservation through the defect-discharge mechanism, NOT through f_carry. The only references to `fwd_succ_f_carry` are in Boneyard files. Same for `bwd_pred_p_carry`.

Similarly, `enriched_seed_consistent` (#1) and `enriched_past_seed_consistent` (#3) are only used... let me verify:

Grep shows `enriched_seed_consistent` and `enriched_past_seed_consistent` are defined at CanonicalModel.lean:54 and :113 but **never called** from RootScopedChain.lean or anywhere on the active path. The active path uses `defect_resolving_seed_consistent` (RootScopedChain.lean:1175) and `resolving_enriched_fwd_exists` instead.

**This means sorries #1-#4 are NOT on the critical path.** They are vestigial from the old `int_chain`/`bx_countermodel` approach (which was superseded by `dd_countermodel`). The report's dependency diamond showing them as blocking `fwd_chain_forward_F` is **incorrect**.

### 4. g_content_subset_self IS on the Critical Path (Indirectly)

**Confidence: HIGH**

While #1-#4 are dead code, #5 and #6 (`g_content_subset_self`, `h_content_subset_self`) ARE on the critical path. They are called from:

- `fwd_chain_g_content_trans` base case (CanonicalModel.lean:231, 234)
- `bwd_chain_h_content_trans` base case (CanonicalModel.lean:253, 256)
- `sigma_fwd_g_content_trans` base case (RootScopedChain.lean:632, 635)
- `sigma_bwd_h_content_trans` base case (RootScopedChain.lean:660, 663)

These transitive propagation lemmas are used by `dd_chain_g_content` (RootScopedChain.lean:671) which is used for the FMCS `forward_G` property.

The base case `m = n = 0` requires `g_content(chain(0)) ⊆ chain(0)`, which is exactly `g_content_subset_self`. Under irreflexive semantics, this is false.

**However**, the base case can potentially be **avoided entirely**. The proof by induction on n splits into:
- `m = n`: needs `g_content(X) ⊆ X` (the sorry)
- `m < n+1`: uses `g_content(chain(m)) ⊆ chain(n)` then the step lemma

The `m = n` case is used for the identity case of the ordering. If we could change the FMCS `forward_G` requirement from `t <= t'` to `t < t'` (strict), the `m = n` case would vanish. But FMCS requires non-strict ordering for the truth lemma to work (G means "for all t' >= t" under reflexive G, or "for all t' > t" under irreflexive G).

**Wait** -- under irreflexive semantics, G means "for all t' > t". So the FMCS `forward_G` property should use strict `<`, not `<=`. If the FMCS definition already uses `<=` but semantics uses `>`, there is a **mismatch** that `g_content_subset_self` is papering over.

### 5. The Real Critical Sorry Count Is 7, Not 11

**Confidence: HIGH**

On the active `bx_completeness` path:
- **#5** `g_content_subset_self` (CanonicalModel.lean:207) -- called from g_content_trans base cases
- **#6** `h_content_subset_self` (CanonicalModel.lean:213) -- called from h_content_trans base cases
- **#7** `fwd_chain_forward_F` (RootScopedChain.lean:1065)
- **#8** `dd_bfmcs_restricted_tc` fwd/negative-t case (RootScopedChain.lean:1092)
- **#9** `dd_bfmcs_restricted_tc` backward direction (RootScopedChain.lean:1099)
- **#10** `dd_bfmcs_restricted_buc` (RootScopedChain.lean:1107)
- **#11** `dd_bfmcs_restricted_fuc` (RootScopedChain.lean:1114)

Sorries #1-#4 (`enriched_seed_consistent`, `fwd_succ_f_carry`, `enriched_past_seed_consistent`, `bwd_pred_p_carry`) are **dead code** -- not used on the `dd_countermodel` path.

### 6. The fwd_chain_forward_F Termination Argument Has a Real Gap

**Confidence: MEDIUM**

The proof sketch at RootScopedChain.lean:1044-1065 claims termination via defect counting. The key issue: `defect_step_choice_early` resolves at least one defect w (making `w in chain(n+1)`), but we need w to eventually be phi. The proof needs:

1. At each step with active defects, at least one is resolved (proven: `defect_step_early` guarantees `exists w in defects, w in M'`)
2. Once resolved (chi in chain(k)), chi stays resolved OR F(chi) re-enters. But the `preserving_fwd_step_defect_preserved` only says `chi in M' OR F(chi) in M'`. If chi gets "unresolved" (chi not in chain(k+1) but F(chi) in chain(k+1)), we're back to square one.
3. The argument needs: once chi is directly resolved at step k (chi in chain(k)), does chi persist? Not necessarily -- chi is not in g_content so it may not propagate.

The real argument should be: sigma_list is finite with |sigma_list| = K formulas. At each step, at least one defect is directly resolved. Even if it "un-resolves" at the next step, we need a pigeonhole/well-founded argument. This is non-trivial because the same formula can bounce between resolved/unresolved states.

A cleaner approach: at step n, BX11 (temp_linearity) picks some earliest F-witness. If F(phi) and F(w) are both pending, F(phi & w) or F(phi & F(w)) or F(F(phi) & w) holds. The resolved w satisfies w in chain(n+1). For the specific phi we want:
- If `|sigma_list| = 1`, phi must be resolved at step 1.
- If `|sigma_list| > 1`, we need at most K steps before phi's turn.

But this "round-robin guarantee" is not how the current code works. The `.choose` in `defect_step_early` is non-deterministic -- it does not guarantee round-robin resolution.

### 7. The Backward Chain Lacks Symmetric P-Preservation

**Confidence: HIGH**

The backward chain `bwd_chain_of_sigma` (RootScopedChain.lean:582-590) does NOT use a preserving step. It uses plain `bwd_pred` with round-robin scheduling. This means:
- P-formulas are NOT preserved across backward steps
- The backward direction of `dd_bfmcs_restricted_tc` (sorry #9) needs P(phi) in bwd_chain to give phi at some earlier point
- Without P-preservation, this is genuinely hard

This is a **structural asymmetry** the report does not highlight. The forward chain has the defect-discharge mechanism; the backward chain does not.

### 8. Axiom System Appears Complete for Intended Semantics

**Confidence: MEDIUM**

The BX axiom system (35 constructors) covers:
- Propositional (4): standard classical
- S5 Modal (5): T, 4, B, 5-collapse, K-dist
- BX Temporal (24): seriality, mono, connect, accum, absorb, linearity, elim, eventuality, F-Until bridge, temp-linearity
- Interaction (2): modal-future, temp-future

This matches standard Burgess-Xu axiomatizations for linear temporal orders with irreflexive G/H. I see no obviously missing axioms. The system has BX9 (until_elim: phi U psi -> phi v psi) which is the half-open guard axiom, BX10 (until_F: phi U psi -> F(psi)), and BX12 (F(phi) -> T U phi). These together with BX5 (self-accumulation) and BX6 (absorption) should give Until completeness.

One concern: there is no explicit **induction axiom** for Until (the standard "if phi & G(phi -> phi') then phi U phi'" type scheme). The absorption axiom BX6 partially serves this role, but it's unclear if it's sufficient for all inductive arguments needed in the chain construction.

## Gaps Identified

### Gap 1: Dead Code Inflation

The report claims 11 sorry sites but only 7 are on the critical path. Sorries #1-#4 are dead code from the superseded `bx_countermodel` approach. Working on these wastes effort. The task should focus on the 7 actual blocking sorries.

### Gap 2: FMCS Ordering Mismatch

Under irreflexive semantics, `forward_G` should use strict `<` not `<=`. The current FMCS definition uses `h_le : t <= t'` for `forward_G` and `backward_H`. If semantics uses strict `>` for G, the `t = t'` case of forward_G is exactly `g_content_subset_self` -- which is false.

**This suggests the FMCS definition needs to change**, not just the proofs. If `forward_G` used `t < t'`, the base case vanishes and #5/#6 become irrelevant. But this requires checking that the truth lemma still works with strict ordering in FMCS.

### Gap 3: No Symmetric Backward Defect Discharge

The backward chain uses plain `bwd_pred` without P-preservation. This makes sorry #9 (backward temporal coherence) structurally harder than #7/#8. A symmetric `preserving_bwd_step` would be needed.

### Gap 4: The fwd_chain_forward_F Termination Argument Is Sketched But Not Proven

The defect counting argument has a real gap: resolved defects can "un-resolve" at the next step. The proof needs either:
(a) Show that once resolved, a formula stays resolved (unlikely given MCS construction)
(b) A well-founded measure that strictly decreases (e.g., "first step at which phi is resolved" exists by some argument)
(c) A deterministic scheduling argument that guarantees each formula gets resolved within K steps

### Gap 5: Until/Since Coherence (#10, #11) Has No Clear Proof Strategy

The report mentions these are "blocked" but doesn't propose a concrete approach. These require showing that U(phi, psi) in chain(t) implies psi at some later t' with phi holding on [t, t'). This is a substantially different kind of coherence from F-resolution and may require Until-specific chain construction.

## Risk Assessment

### What Could Go Wrong With Proposed Approaches

1. **Enriched seed approach** (from the report): If sorries #1-#4 are dead code, this approach is solving the wrong problem. The real issue is #5/#6 (g/h_content_subset_self) and the chain coherence sorries #7-#11.

2. **Fixing g_content_subset_self by changing FMCS definition**: This is the most promising approach for #5/#6, but carries risk:
   - The `RestrictedParametricTruthLemma.lean` truth lemma takes `forward_G` with `<=`. Changing to `<` requires re-checking the G-case of the truth lemma.
   - Every use of `forward_G` and `backward_H` throughout the codebase needs audit.
   - The `g_content_subset_implies_h_content_reverse` duality may break.

3. **Defect-discharge for #7**: The termination argument is genuinely hard. The `.choose` non-determinism means we can't control which defect gets resolved. A possible fix: change `defect_step_early` to resolve the **first** defect in the list deterministically, then use list position as a well-founded measure.

4. **Backward coherence for #8/#9**: Without a symmetric backward defect-discharge mechanism, there's no clear path. Building one requires the same infrastructure as the forward case but for P-formulas.

5. **Until/Since coherence for #10/#11**: These are the deepest sorries. Standard completeness proofs handle Until coherence through the axioms BX5 (self-accumulation), BX6 (absorption), and BX7 (linearity). The proof typically works by showing that if phi U psi holds at chain(t), then by BX10, F(psi) holds at chain(t), and by F-resolution (sorry #7), psi appears at some chain(t'). The guard phi on [t, t') follows from BX2 (left monotonicity) and BX5 (self-accumulation). **So #10/#11 may reduce to #7 once F-resolution is proven.**

## Summary

| Finding | Impact | Confidence |
|---------|--------|------------|
| Only 7 of 11 sorries are on critical path | HIGH -- 4 can be ignored | HIGH |
| g_content_subset_self is genuinely false | HIGH -- needs FMCS redesign | HIGH |
| FMCS ordering mismatch (<=  vs <) is root cause of #5/#6 | HIGH -- fix definition, not proof | MEDIUM |
| fwd_chain_forward_F termination gap is real | MEDIUM -- needs careful argument | MEDIUM |
| Backward chain lacks P-preservation | HIGH -- structural gap | HIGH |
| Until/Since coherence may reduce to F-resolution | MEDIUM -- optimistic but plausible | MEDIUM |
| Axiom system appears complete | LOW -- no missing axioms found | MEDIUM |
| Enriched seed approach targets dead code | HIGH -- misdirected effort | HIGH |
