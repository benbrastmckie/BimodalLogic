# Teammate C Findings: Plan v11 Validation

## Key Findings

1. **FATAL FLAW in identity tail (forward_F)**: F(psi) in M_last does NOT imply psi in M_last. The BX T-axiom gives `G(phi) -> phi`, not `F(psi) -> psi`. An identity tail at M_last with F(psi) in M_last but psi not in M_last has no future successor where psi holds — the constant chain never witnesses psi. This is not a minor gap; it invalidates the entire identity tail construction for forward_F.

2. **CONFIRMED: hintikka_step has NO Since-backward clause**. The `hintikka_step` definition (Construction.lean:45-52) has only (a) G-propagation, (b) H-backward, (c) Until defect propagation. Since defect propagation is absent. The `HintikkaStepOracleSince` (line 701) goes backwards (oracle produces a predecessor), but Plan v11's Phase 3 says "backward chain construction" relying on symmetric infrastructure — and the `hintikka_step` itself does not carry Since forward. The backward_P proof requires an FMCS construction where the chain grows to the LEFT, which is architecturally different from the forward chain.

3. **deferralClosure extension will break `max_F_depth_deferralClosure_eq`**: Adding `(top U psi)` formulas (Until formulas) to deferralClosure changes the sup of `f_nesting_depth`. A formula `(top U psi)` has `f_nesting_depth = 0` if psi has no F-nesting, but it contains an Until, which is not measured by `f_nesting_depth`. However `max_F_depth_deferralClosure_eq` at SubformulaClosure.lean:1062 is proved by case analysis on the components of `deferralClosure = baseDeferralClosure` (a `rfl`). If deferralClosure is changed, the entire proof must be re-derived.

4. **CONFIRMED: `hintikka_step_g_prop` scope issue**: The lemma at Realization.lean:419-424 has type: `hintikka_step h1 h2 -> G(chi) in h1.formulas -> chi in h2.formulas`. It works for any chi that appears in `h1.formulas` as `G(chi)`. Since Hintikka points are subsets of Sigma, G(chi) must be in Sigma for it to be in h1.formulas. Plan v11 claims restricted G-persistence works because `deferralClosure(root) ⊆ Sigma` — but this depends on the Sigma chosen for the quasimodel construction. If Sigma = SubformulaClosure(root) (the quasimodel Sigma), then deferralClosure(root) ⊆ Sigma is NOT guaranteed because deferralClosure contains seriality formulas (F_top, P_top, etc.) and deferral disjunctions that need not be subformulas of root.

5. **Strict vs non-strict gap is REAL**: The sorry at CanonicalModel.lean:518 requires `t < s` (strict). The quasimodel chain produces a point where psi holds, but if psi already holds at h0 (the starting point), the chain is the singleton h0 and no strictly later position is produced. The plan implicitly assumes F(psi) at t means psi NOT currently in M_t; but by the `F_of_mem` theorem (Realization.lean:54-71), if psi were in M_t, then F(psi) would also be in M_t — so this case can occur. The quasimodel chain may give s = t (same position) when psi is already present.

---

## Validation Results

### 1. Restricted G-persistence
**Verdict: UNCERTAIN**

`hintikka_step_g_prop` (Realization.lean:419-424) has type:
```lean
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    (h_step : hintikka_step h1 h2) {chi : Formula}
    (h_Gchi : Formula.all_future chi ∈ h1.formulas) :
    chi ∈ h2.formulas
```
This provides `G(chi) in h1 => chi in h2` for any chi, PROVIDED `G(chi) in h1.formulas`. Since `HintikkaPoint.formulas ⊆ Sigma`, this requires `G(chi) ∈ Sigma`.

**The critical question**: Is `deferralClosure(root) ⊆ SubformulaClosure(root)` (the quasimodel Sigma)?

SubformulaClosure (Quasimodel/SubformulaClosure.lean) is:
- subformulas(target) + G/H-enrichment + negation pairing

deferralClosure (Syntax/SubformulaClosure.lean:809) is:
- closureWithNeg(phi) + deferralDisjunctionSet(phi) + backwardDeferralSet(phi) + serialityFormulas

The `serialityFormulas` (line 791-793) includes: F_top, P_top, neg_bot, neg_neg_bot, G_neg_neg_bot, H_neg_neg_bot, neg_G_neg_neg_bot, neg_H_neg_neg_bot, F_top_deferral, P_top_deferral.

These are NOT subformulas of arbitrary root formulas. For example, `G(neg_neg_bot)` is not in `SubformulaClosure(root)` when root = `p` (an atom). So `deferralClosure(p)` is NOT a subset of `SubformulaClosure(p)`.

**Conclusion**: The claim that `hintikka_step_g_prop` covers all formulas in `deferralClosure(root)` is FALSE in general. For restricted forward_G to work, either (a) Sigma must be chosen as something larger than SubformulaClosure, or (b) only SubformulaClosure-formulas actually appear in the restricted coherence obligation. This is uncertain without seeing how the adapter maps deferralClosure to Sigma.

### 2. Identity tail properties
**Verdict: REFUTED (FATAL FLAW)**

Plan v11 claims: "forward_G at boundary: G(phi) in chain.last -> phi in chain.last by BX T-axiom."

This is CONFIRMED for forward_G: `Axiom.temp_t_future` (`G(phi) -> phi`) exists and is proved at the BX axiom level (used explicitly at CanonicalModel.lean:540-547 in `bx_bfmcs`).

But Plan v11 also needs forward_F for the identity tail: F(psi) in M_last implies exists s > k with psi in chain(s). For the constant tail chain(s) = M_last for all s > k:
- We need psi in M_last.
- But F(psi) in M_last means psi holds at SOME future time.
- F(psi) does NOT imply psi in M_last; it requires a separate witness.

The `F_of_mem` theorem (Realization.lean:54-71) shows that `psi in w.formulas => F(psi) in w.formulas`, i.e., the implication goes the other way. There is no BX theorem `F(psi) -> psi` (that would make time reflexive for F, which conflicts with discrete temporal logic semantics where strict future is possible).

**This is a FATAL FLAW**: The identity tail cannot witness F(psi) in M_last unless psi is ALSO in M_last. But for F(psi) in a maximal consistent set to actually have a future witness, we need a genuinely later point. The constant tail provides no such point.

**Implication**: forward_F CANNOT be closed by the quasimodel adapter + identity tail architecture unless the chain produced by the quasimodel construction is guaranteed to end at a point where ALL F-obligations in deferralClosure are already discharged (psi in the last point). This is a much stronger requirement than the plan assumes.

### 3. deferralClosure extension safety
**Verdict: REFUTED (will break downstream)**

`deferralClosure` is currently defined as exactly `baseDeferralClosure phi` (SubformulaClosure.lean:809-810), and `baseDeferralClosure_eq_deferralClosure` is proved as `rfl` (line 817-818).

The theorem `max_F_depth_deferralClosure_eq` (line 1062-1063) and `max_P_depth_deferralClosure_eq` (line 1146-1147) are proved by unfolding the rfl-equality and doing case analysis on the components. This theorem is used at:
- RestrictedMCS.lean:1072, 1149
- Boneyard/SuccChainFMCS.lean:2981 (dead code but still compiles)

If `(top U psi)` formulas are added to `deferralClosure`, then `max_F_depth_deferralClosure_eq` breaks because Until formulas are not measured by `f_nesting_depth` (they're a separate syntactic category). The theorem computes max F-nesting depth; Until formulas do not contribute to F-nesting, so the VALUE of the theorem is unchanged — but the PROOF fails because it can no longer unfold `deferralClosure` to just `baseDeferralClosure`.

Also: `DeferralRestrictedMCS` and seed construction in Bundle/SuccExistence.lean uses `deferralClosure` by name, with pattern-matching on the structure. Adding Until formulas (which have the `Formula.untl` constructor) to the closure means Until-formulas can now appear in `DeferralRestrictedMCS` chains, potentially triggering Until-defect handling code that was not designed to run in this context.

Specifically, `p_step_blocking_formulas_restricted` (SuccExistence.lean:200) checks `Formula.some_past chi ∈ deferralClosure phi`. Since we'd be adding Until formulas, no P-formulas are newly introduced, so this specific path is safe. However, other pattern-matching on whether formulas in `deferralClosure` are Until-formulas could be affected.

**Risk is HIGH** for `max_F_depth_deferralClosure_eq` and `max_P_depth_deferralClosure_eq` — both need proof updates, and these are used in active-path lemmas (RestrictedMCS.lean).

### 4. Strict vs non-strict gap
**Verdict: REFUTED (gap is real but fixable)**

The sorry at CanonicalModel.lean:518 (bx_fmcs_forward_F) requires:
```
∃ s : Int, t < s ∧ psi ∈ (bx_fmcs M0 h0).mcs s
```

The quasimodel construction `hintikka_chain_exists` (Construction.lean:594-601) produces a chain with `psi ∈ c.last.formulas`. If we start at t and the chain is just the singleton (because psi ∈ h0.formulas already), then the "witness position" is t itself (not t+1 or later).

This is actually provable for the singleton case as follows: if psi ∈ h0 and F(psi) ∈ h0, then by the BX axiom `psi -> F(psi)` (or rather, the chain can step to a successor where psi holds). But the problem is different: we need a STRICTLY LATER position in the Int-indexed chain, not just the same position.

For forward_F, the argument "psi ∈ M_t already => F(psi) ∈ M_t by F_of_mem" just shows F is consistent, not that there's a strict future witness. The actual F-semantics requires STRICT future. In BX, `F(psi)` means there exists a strictly later time — it does NOT mean `psi` holds now.

The fix is: when psi ∈ current point, use `bx_le w v` with `bx_le` strict (i.e., `w ≠ v`) to find a strictly later MCS via eventuality resolution. But this requires constructing a non-identity step in the chain, which is exactly the hard part.

**Assessment**: The strict-vs-non-strict gap is real, but the case `psi ∈ M_t already` can be handled by the `F_of_mem`-to-`until_eventuality_resolution` path if one invokes `bx_until_eventuality_resolution` (which requires psi NOT in w). So the case split would be: if psi ∈ M_t, do NOT apply quasimodel (use `F_of_mem` approach differently); if psi ∉ M_t, apply quasimodel chain. The quasimodel then gives `s ≥ t+1`. This is fixable but requires careful case analysis not mentioned in the plan.

### 5. Backward direction
**Verdict: REFUTED (symmetric construction is incomplete)**

The `hintikka_step` definition (Construction.lean:45-52) has exactly three clauses:
1. G-propagation: `G(chi) in h1 => chi in h2`
2. H-backward: `H(chi) in h2 => chi in h1`
3. Until defect propagation: `(phi U psi) in h1 and psi not in h1 => phi in h1 and (phi U psi) in h2`

**There is no Since-defect propagation clause in `hintikka_step`.**

The infrastructure that does exist for Since:
- `SinceDefect` (line 62-63): defined
- `sinceDefectSet` (line 302-307): defined
- `since_defect_count` (line 310-311): defined
- `HintikkaStepOracleSince` (line 701-707): defined as "oracle produces a PREDECESSOR"
- `hintikka_chain_exists_since` (line 769-824): proved — builds a chain ending at h0 with head containing psi

The Since backward chain construction EXISTS as a theorem (`hintikka_chain_exists_since`). The direction is reversed: it builds a chain extending LEFT (snoc construction), ending at the given point, with psi at the head (past witness).

**However**: The FMCS adapter needs to map this backward chain to Int-indexed MCS. The forward chain maps to chain(t), chain(t+1), ..., chain(t+k). The backward chain maps to chain(t-k), ..., chain(t-1), chain(t). This requires the adapter to also handle backward chains — a separate construction.

More critically: Plan v11 says "symmetric Since construction for backward_P" implies the infrastructure is "built in." It is NOT built into `hintikka_step` itself (no Since-propagation clause). The `HintikkaStepOracleSince` provides the oracle interface, but invoking it requires a backward-step construction that is architecturally different from the forward adapter.

**Estimate for extra work**: The backward direction needs (a) a `QuasimodelChainSince`-to-FMCS adapter that extends backward in time, (b) proof that the backward chain from `hintikka_chain_exists_since` can be realized in the FMCS, (c) handling the identity tail for the PAST direction (P(psi) in M_last => exists s < t with psi in chain(s) — same fatal flaw as forward: identity tail in the past direction fails for the same reason). Roughly 60-80 extra lines at minimum, but conceptually blocked by the same identity tail flaw.

---

## Gaps and Risks

Ranked by severity:

### SEVERITY: FATAL (blocks the plan entirely)

1. **Identity tail forward_F flaw**: F(psi) in M_last does not imply psi in M_last. The constant-value tail construction produces NO future witness for F-obligations. The forward_F sorry (line 518) cannot be closed by any quasimodel chain + identity tail unless the chain endpoint provably contains psi AND the FMCS maps the chain endpoint to a strict future time. This is circular: we need a strictly later position, but the identity tail provides only the same position.

2. **Identity tail backward_P flaw**: The symmetric flaw for backward_P (line 525). P(psi) in M_last of a backward identity tail does not imply psi is in any strictly earlier position.

### SEVERITY: HIGH (requires significant rework)

3. **deferralClosure extension breaks `max_F_depth_deferralClosure_eq`**: This theorem is used in active-path proofs (RestrictedMCS.lean). Plan v11 mentions checking this but underestimates the work. The proof at SubformulaClosure.lean:1062 will need complete re-derivation.

4. **Since infrastructure incomplete in hintikka_step**: `hintikka_step` has no Since-defect propagation clause. Plan v11 claim that "backward direction is symmetric" is not accurate — the backward chain construction exists (`hintikka_chain_exists_since`) but uses a different oracle interface (`HintikkaStepOracleSince`) that goes BACKWARDS. Mapping this to Int-indexed MCS requires separate adapter work.

### SEVERITY: MEDIUM (uncertainty, may be addressable)

5. **Restricted G-persistence Sigma scope**: deferralClosure contains seriality formulas not in SubformulaClosure. The quasimodel Sigma must be chosen to contain deferralClosure(root) for hintikka_step_g_prop to cover restricted coherence. This likely requires using a larger Sigma (e.g., deferralClosure itself as Sigma for the quasimodel), which changes what SubformulaClosure lemmas are available.

6. **Strict vs non-strict gap**: Addressable with careful case split (if psi ∈ M_t use different path; otherwise quasimodel chain gives strict future), but not mentioned in the plan.

### SEVERITY: LOW (nuisance-level, likely fixable)

7. **`baseDeferralClosure_eq_deferralClosure` rfl breakage**: After extension, this is no longer `rfl`. Multiple downstream lemmas use this. Easy to fix but requires touching ~5 files.

---

## Confidence Level

**High** — conclusions are based on direct code reading of the exact type signatures and definitions in question, with no speculation. The fatal flaws (identity tail and F(psi) not implying psi) are elementary logical observations that do not depend on subtle proof-theoretic details.

**Specific uncertainties**:
- The exact Sigma used in the quasimodel adapter is not yet specified (Plan v11 doesn't commit to it). If Sigma is taken as deferralClosure(root) rather than SubformulaClosure(root), the restricted G-persistence issue may resolve. This requires investigation.
- The BX axiom `F(psi) -> psi` would fix the identity tail issue if it existed, but it doesn't (it would make time reflexive for F, contradicting discreteness/seriality). This is certain.
