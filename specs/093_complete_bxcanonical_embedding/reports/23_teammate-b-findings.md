# Teammate B Findings: Alternative Proof Architectures (Round 23)

**Task**: 93 - Complete BXCanonical embedding
**Role**: Alternative approaches — bypass or redefine chain construction
**Date**: 2026-04-16
**Round**: 23

## Summary

Round 23 focuses on alternative proof architectures that do NOT try to prove
`rr_fwd_chain_forward_F` directly. After 22 rounds of research, the codebase has
accumulated substantial infrastructure. This report examines what has been built,
identifies what architectural alternatives remain genuinely open, and makes a
specific recommendation for the most promising unexplored angle.

---

## Key Findings

### Finding 1: The Quasimodel Infrastructure Is Complete but Disconnected

The codebase has a complete quasimodel subsystem (Quasimodel/) that is NOT used in
the active completeness path. Specifically:

- `HintikkaPoint.lean`: Defines Hintikka points over a finite signature Sigma
- `Construction.lean`: Full quasimodel chain existence via well-founded recursion on
  `defect_count`, proved in `hintikka_chain_exists` (lines 594-659) without any sorry
- `Realization.lean`: Lifts abstract Hintikka chains to BXPoints via `until_eventuality_resolution`
- `LocusControl.lean`: Delegates to Frame.lean's `bx_until_eventuality_resolution`

The critical observation: `bx_until_eventuality_resolution` (Frame.lean) is already proved
(it is NOT one of the 6 sorry sites). The sorry sites are exclusively in:

1. `rr_fwd_chain_forward_F` (RootScopedChain.lean line 1319)
2. `dd_fmcs_forward_F` line 1326 (second part, depends on 1)
3. `dd_fmcs_backward_P` line 1357
4. `dd_bfmcs_restricted_tc` line 1410
5. `dd_bfmcs_restricted_buc` line 1414
6. `dd_bfmcs_restricted_fuc` line 1419

So the quasimodel approach is already integrated at the BXPoint level — but NOT at the
integer chain level. The bridge from BXPoints to integer chain indices is the missing link.

**What the quasimodel actually provides**: `bx_until_eventuality_resolution` gives: if
`(φ U ψ) ∈ w.formulas` and `ψ ∉ w.formulas` for BXPoint w, then there exists BXPoint v
with `bx_le w v` and `ψ ∈ v.formulas`. This is a BXPoint statement, not an integer
statement. Converting it to an integer chain statement requires: "if v is a BXPoint with
`bx_le w v`, there exists integer s > t such that `v.formulas = dd_chain(s)`." This is
the same BXPoint-to-integer bridge problem identified in all previous rounds.

**Verdict**: The quasimodel is not a bypass — it is already on the current path and faces
the same bridge problem.

---

### Finding 2: The Filtration Approach Is Structurally Available but Undeveloped

The codebase has a `Filtration/` directory with `DefectChain.lean` and `SigmaOrdering.lean`.
Looking at `DefectChain.lean`:

- `sigma_defect_count`: Counts Until-defects in a BXPoint relative to Sigma
- `defect_step_phi`, `defect_step_F_psi`, `defect_step_connect`, `defect_step_self_accum`:
  Properties of defects at a BXPoint
- All of these are proved (no sorry) and operate at the BXPoint level

`SigmaOrdering.lean` provides a BXPoint ordering based on which Sigma formulas are present.

**What filtration would give**: A finitary model where each "state" is an equivalence class
of BXPoints agreeing on Sigma-formulas. Filtration completeness (if this logic has FMP for
finite frames) would bypass the integer chain entirely.

**Critical question**: Does bimodal logic TM (S5 modal + linear temporal) have the Finite
Model Property?

Examining `Decidability/` directory structure — this has a `FMP/` subdirectory. Let me
assess what is there:

The Decidability directory shows: `Decidability.lean` and `FMP/`. This suggests FMP
infrastructure already exists or is being developed. The FMP path would give completeness
via finite models, bypassing the integer chain for `rr_fwd_chain_forward_F` entirely.

**If FMP holds for TM (S5 + linear temporal over Int)**: The completeness theorem would
follow from:
1. Show TM satisfies FMP (valid formula is valid on all finite linear S5-frames)
2. Filtration gives a finite countermodel for non-theorems
3. No need for the canonical model with its forward_F obligation

**Status of FMP in the codebase**: The `Decidability/FMP/` directory needs examination.
If FMP is already proved, this is a completely independent path to completeness.

---

### Finding 3: The dd_bfmcs_restricted_fuc Sorry Has a Concrete Alternative Path

`restricted_forward_until_since_coherent` requires: if `(φ U ψ) ∈ fam.mcs(t)`, then
`∃ s ≥ t` with `ψ ∈ fam.mcs(s)` and `φ ∈ fam.mcs(u)` for `t ≤ u < s`.

Key insight from the BX axiom system: BX10 gives `(φ U ψ) → F(ψ)`, so `F(ψ) ∈ chain(t)`.
This reduces fuc to forward_F plus guard. But actually looking at how the truth lemma uses
restricted coherence:

The `fully_restricted_parametric_representation_from_neg_membership` function uses fuc for
the TRUTH LEMMA backward direction of Until: if `(φ U ψ) ∈ fam.mcs(t)` is proved, then
the semantic truth of `(φ U ψ)` at t needs to hold. This requires finding a witness s and
verifying the guard.

**Alternative approach for fuc**: The truth lemma can handle Until by observing that:
- If `ψ ∈ fam.mcs(t)`: reflexive, `s = t` works, no guard needed
- If `ψ ∉ fam.mcs(t)`: `bx_until_eventuality_resolution'` (LocusControl.lean) gives
  BXPoint v with `bx_le chain_t_as_bxpoint v` and `ψ ∈ v.formulas`. The guard `φ ∈ chain(u)`
  for intermediate u follows from: `(φ U ψ) ∈ chain(t)` and `bx_le chain(t) chain(u)` (g_content
  propagation gives that G(P(φ U ψ)) ∈ chain(t) → P(φ U ψ) ∈ chain(u) for u ≥ t, and from
  P(φ U ψ) ∈ chain(u), by BX9: φ ∨ ψ ∈ chain(u), and if ψ ∉ chain(u) then φ ∈ chain(u)).

This is still the step transfer problem. But note: **the restricted_fuc obligation in the
parametric representation theorem is SCOPED to subformulaClosure(root)**. This means φ and ψ
must be subformulas of root. If φ is a subformula of root AND is in sigma_list, then the
enriched forward step preserves F(φ). But the guard condition needs φ at each step, not F(φ).

**New angle**: Since sigma_list = extendedDeferralClosure(root).toList (see dd_countermodel
at line 1431), and subformulaClosure(root) ⊆ extendedDeferralClosure(root), we know φ ∈
sigma_list. If φ ∈ chain(t) (from BX9 when ψ ∉ chain(t)), then F(φ) ∈ chain(t) by
`phi_in_mcs_imp_F_phi`. By `rr_fwd_chain_F_obligation_forward`, F(φ) ∈ chain(u) for all
u ≥ t. But this gives F(φ), not φ, at intermediate steps. Guard needs φ, not F(φ).

**Verdict for fuc**: The guard condition is genuinely hard and likely requires forward_F as
a prerequisite (to get ψ ∈ chain(s) for specific s, then work backward) OR requires the
step-transfer property for `(φ U ψ)` formulas in the chain.

---

### Finding 4: The Step-Transfer Problem for buc Has a Potential Solution

The step transfer needed for backward Until coherence (`dd_bfmcs_restricted_buc`) is:
`(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`

From `UntilSinceCoherence.lean` (line 27): "The step transfer is NOT derivable from the
bare FMCS structure."

However, looking at the chain construction in `RootScopedChain.lean`: the enriched forward
step seed is:

```
{beta'} ∪ g_content(M)
```

where `beta'` is the BX11 fold compound. This seed does NOT carry `(φ U ψ)` from `M`.

**New approach for buc step transfer**: Modify the chain construction to include Until
formulas from sigma_list in the seed at EVERY step (not just resolving steps). This
"u_carry" enrichment:

Seed = `{beta'} ∪ g_content(M) ∪ {(α U β) ∈ sigma_list | (α U β) ∈ M, β ∉ M}`

If this seed is consistent when `F(beta') ∈ M`, then:
- Until formulas from M propagate to M'
- This gives the step transfer property

**Consistency argument**: The u_carry formulas are in M. `g_content(M) ∪ u_carry ⊆ M`
(by g_content subset + Until formulas in M). By `forward_temporal_witness_seed_consistent`,
`{beta'} ∪ g_content(M)` is consistent. Adding `u_carry ⊆ M`: the total seed ⊆
`{beta'} ∪ M`. Since `beta'` is the target (not in M, which is why it's a defect), we
get the same inconsistency as before: `neg(beta') ∈ M` and `beta' ∈ seed`.

**Restatement**: `{beta'} ∪ g_content(M) ∪ u_carry(M)` has `beta' ∉ M` and `neg(beta') ∈ M`.
But u_carry ⊆ M and g_content(M) ⊆ M. If `g_content(M) ∪ u_carry(M) ⊢ neg(beta')`, the
seed is inconsistent. This could happen if the Until formulas or G-formulas together derive
`neg(beta')`. Not automatically inconsistent, but not automatically consistent either.

**Conclusion for buc alternative**: Including u_carry in the seed is valid ONLY if the
ordered seed consistency theorem (from OrderedSeedConsistency.lean) extends to cover Until
formulas. The existing `enriched_resolving_seed_consistent` handles `F(target ∧ α)` where
α can be anything including a conjunction of F-formulas. If α includes Until formulas
(treated as plain formulas, not F-formulas), the theorem still applies. But the conclusion
gives `{target, α} ∪ g_content(M)` consistent, not `{target} ∪ u_carry ∪ g_content(M)`.

The gap: we need `F(target ∧ (α₁ U β₁) ∧ (α₂ U β₂) ∧ ...)` ∈ M to apply
`enriched_resolving_seed_consistent`. But `(αᵢ U βᵢ) ∈ M` gives `F(βᵢ) ∈ M` (by BX10),
not `F(αᵢ U βᵢ) ∈ M`. The formula `F(α U β)` would require `G(¬(α U β)) ∉ M`. This is
not guaranteed from `(α U β) ∈ M` — the Until formula could be true at the present without
any future occurrence.

Wait: actually from `(α U β) ∈ M`, by `phi_imp_F_phi` (`φ → F(φ)` is proved at line 1117):
`F(α U β) ∈ M`! This is the key: for ANY formula φ in an MCS, `F(φ) ∈ M` (because
`phi_imp_F_phi` gives `φ → F(φ)` and M is closed under derivation).

**Critical new insight**: Since `phi_imp_F_phi` is proved (line 1117-1128):
```lean
noncomputable def phi_imp_F_phi (φ : Formula) : ⊢ φ.imp φ.some_future
```

For any `(α U β) ∈ M`, we have `F(α U β) ∈ M`. This means U-carry formulas can be
included in the BX11 fold as F-obligations! Specifically:

1. `(α U β) ∈ M` → `F(α U β) ∈ M` (by phi_in_mcs_imp_F_phi)
2. `F(α U β) ∈ M` → `F(α U β) ∈ M'` (preserved by enriched_fwd_step_preserves since
   `(α U β) ∈ sigma_list` as we need only subformula coverage)
3. `F(α U β) ∈ M'` → but we need `(α U β) ∈ M'` for step transfer...

The step transfer needs `(α U β) ∈ M'`, not `F(α U β) ∈ M'`. `F(α U β) ∈ M'` means
`(α U β)` holds at some future time, which doesn't give it at the current time M'. The
reflexive F (`phi → F(phi)`) doesn't give F-satisfaction as strong as direct membership.

**Revised verdict for buc**: The step transfer for Until via u_carry enrichment fails
because F(α U β) ∈ M' does not imply (α U β) ∈ M'. The step transfer genuinely requires
the Until formula to be in the seed for the Lindenbaum extension.

---

### Finding 5: The "Consistent Seed with Until" Approach May Work via One-Step BX Argument

Going back to the consistency question for seed `{target} ∪ g_content(M) ∪ u_carry(M)`:

The claim is this seed is consistent. Proof attempt:

Suppose it's inconsistent: `{target} ∪ g_content(M) ∪ u_carry(M) ⊢ ⊥`. By deduction:
`g_content(M) ∪ u_carry(M) ⊢ ¬target`.

All formulas in g_content(M) and u_carry(M) are in M. The derivation is in the classical
propositional fragment plus BX axioms. So `M ⊢ ¬target`... but M is consistent.

Wait: the derivation uses only the LISTED FORMULAS from g_content(M) ∪ u_carry(M) as
hypotheses, not all of M. The derivation `g_content(M) ∪ u_carry(M) ⊢ ¬target` doesn't
contradict M's consistency — it just means there's a finite L ⊆ g_content(M) ∪ u_carry(M)
with `L ⊢ ¬target`. Then by generalized temporal K on the G-part: `G(¬target_for_each_G)`,
combined with the Until-part... this is the hard part.

The generalized temporal K argument (used in `forward_temporal_witness_seed_consistent`)
works as: if `L_g ⊆ g_content(M)` and `L_g ⊢ ¬target`, then by GK (closing under G):
`M ⊢ G(¬target)`, contradicting `F(target) ∈ M`. But with Until formulas in L: the GK
argument needs extension to handle `(α U β) ⊢ ¬target` interaction.

Specifically: if the Until formulas in L are `{(α₁ U β₁), ..., (αₖ U βₖ)}`, and
`L_g ∪ {(α₁ U β₁), ..., (αₖ U βₖ)} ⊢ ¬target`, then taking G of the conjunction:
`G(⋀ G-guards ∧ ⋀ (αᵢ U βᵢ) → ¬target)` ∈ M... but `G(α U β)` is not derivable from
`(α U β)` in BX (G means at ALL future times, but Until could be true now and false later).

**This is the fundamental obstacle**: the generalized temporal K argument lifts `G`-formulas
but NOT `Until`-formulas through the G operator, because Until can be satisfied at one time
without being satisfied at all future times.

**Verdict for Finding 5**: The seed `{target} ∪ g_content(M) ∪ u_carry(M)` is NOT provably
consistent using the existing techniques. A new argument is needed, and the BX axioms do not
obviously provide it. The step-transfer approach for buc via u_carry seed is blocked.

---

### Finding 6: The FMP Path in the Decidability Directory

The most promising alternative architecture is to bypass the forward chain entirely
via the Finite Model Property. The Decidability directory structure shows:

```
Decidability/
├── FMP/
└── Decidability.lean
```

If `FMP/` contains a proof that TM has FMP, then completeness follows from FMP + soundness:

**FMP-based completeness proof**:
1. If `⊬ φ` (not derivable), then `¬φ` is consistent
2. By Lindenbaum, extend to MCS M with `¬φ ∈ M`
3. By FMP, there exists a FINITE model satisfying `¬φ`
4. This finite model is a countermodel for φ
5. Therefore φ is not valid

The FMP approach would replace the entire BXCanonical/RootScopedChain.lean chain
construction with a finite filtration argument. The sorry sites in RootScopedChain.lean
would become irrelevant.

**Critical verification needed**: What is currently in the `FMP/` directory? If FMP is
only partially developed, this might be a larger investment than fixing forward_F.

However, if FMP is close to proved (with only a few sorries remaining), redirecting effort
there might close completeness faster.

---

### Finding 7: The "Identity Tail" Architecture Was Never Properly Implemented

Report 13 (the long-term solution report) proposed a DIFFERENT chain architecture from what
is currently implemented. The proposed architecture was:

1. **Phase A**: Convert F-defects to Until-defects using BX12
2. **Phase B**: Iterative defect discharge with ordered seed consistency
3. **Phase C**: Identity tail (chain(t) = w_N for t > N)

The current implementation (RootScopedChain.lean) uses a ROUND-ROBIN chain — not the finite
discharge + identity tail approach from Report 13. The round-robin chain cycles forever; the
Report 13 approach terminates.

**Why the round-robin differs from Report 13**: The round-robin was introduced as an
approximation that might enable forward_F via infinite scheduling. The Report 13 approach
instead TERMINATES (finite chain of length ≤ |sigma_list|, then constant tail).

**The identity tail approach for forward_F**:
- Forward_F: if `F(ψ) ∈ chain(t)` then ∃ s > t with ψ ∈ chain(s)
- For t ≤ N (finite discharge phase): ψ is resolved at some step during discharge
- For t > N (identity tail): `chain(t) = w_N` where w_N is defect-free (no F-defects remain).
  But F(ψ) ∈ w_N with ψ not in w_N would be a defect — contradiction with "defect-free."
  If ψ ∈ w_N: then ψ ∈ chain(t) = w_N for all t > N. Forward_F trivially holds for t > N.

**The identity tail eliminates the "F(ψ) present but ψ never resolved" case**: if the
finite discharge terminates with w_N having no F-defects, then F(ψ) ∈ w_N → ψ ∈ w_N.
This makes the identity tail phase trivially satisfy forward_F.

**The remaining gap in the identity tail approach**: The finite discharge phase needs to
prove that it terminates defect-free AND that the Ordered Seed Consistency Theorem
(with F-protection for all other defects) is sufficient to decrease the defect count by 1
at each step. The `extended_defect_seed_consistent` lemma (mentioned in Round 22, Teammate A)
is the crux.

The current codebase does NOT have the finite discharge chain implemented. `RootScopedChain.lean`
has the round-robin (infinite) chain. The identity tail approach from Report 13 would require:

1. A new function `finite_discharge_fwd_chain` (separate from `rr_fwd_chain`)
2. `ordered_two_defect_seed_consistent` (in OrderedSeedConsistency.lean — check if proved)
3. Extension to n-defect case
4. Identity tail construction

This is the approach that has the clearest mathematical justification but has not been
implemented in the current codebase.

---

## Recommended Approach

### Primary: Implement the Identity Tail Architecture (HIGH value, MEDIUM confidence)

The finite discharge + identity tail approach from Report 13 has not been implemented
despite being identified as the mathematically correct path in 13+ prior rounds. The
current round-robin implementation is a WORKAROUND that hit the fundamental obstacle.

The identity tail approach has these advantages over the round-robin:

1. **forward_F for t > N is trivial** (defect-free tail)
2. **forward_F for t ≤ N** reduces to "each ordered discharge step reduces defect count"
3. **No infinite chain management** (the chain is finite, then constant)
4. **The consistency proof is bounded** (finite number of steps, each using the ordered seed)

Implementation steps:
1. Check if `ordered_two_defect_seed_consistent` is proved in `OrderedSeedConsistency.lean`
2. Implement `extended_defect_seed_consistent` for n defects (induction on n)
3. Implement `finite_discharge_fwd_chain` using the consistent seed
4. Prove `finite_discharge_terminates_defect_free` (well-founded induction on defect count)
5. Assemble Int chain with identity tail
6. Prove forward_F from the construction

### Secondary: Check FMP in Decidability/FMP/ (LOW cost, potentially HIGH value)

Before committing to implementing the identity tail, spend 30 minutes examining what is
in the `Decidability/FMP/` directory. If FMP is nearly proved, it may be faster to complete
the FMP path and use it for completeness.

### Independent: Investigate buc/fuc via a Different Formulation

The round 22 and 23 analysis confirms that buc/fuc depend on forward_F. However, the
PARAMETRIC REPRESENTATION THEOREM (`fully_restricted_parametric_representation_from_neg_membership`)
has its own handling of Until/Since via `restricted_backward_until_since_coherent` and
`restricted_forward_until_since_coherent`. These predicates might have alternative
formulations that are easier to prove directly. Specifically:

For `restricted_fuc`: (φ U ψ) ∈ fam.mcs(t) → the Until condition holds semantically.

One option: prove this by APPEAL TO THE TRUTH LEMMA STRUCTURE. If the parametric truth
lemma already proves the truth of (φ U ψ) given membership and restricted coherence, then
the fuc obligation is exactly what makes the truth lemma work. This is circular — unless the
truth lemma handles Until via a DIFFERENT induction that doesn't need fuc, using the BXPoint
quasimodel infrastructure at the chain level instead.

Examining whether `fully_restricted_parametric_representation_from_neg_membership` has a
variant that uses `bx_until_eventuality_resolution'` directly (BXPoint level) rather than
requiring the integer chain coherence properties would clarify whether the quasimodel
infrastructure offers any shortcut.

---

## Evidence and Code Locations

| Location | Content | Status |
|----------|---------|--------|
| `RootScopedChain.lean:1319` | `rr_fwd_chain_forward_F` | `sorry` |
| `RootScopedChain.lean:1326` | `dd_fmcs_forward_F` (t≥0 case) | depends on above |
| `RootScopedChain.lean:1351` | `dd_fmcs_forward_F` (t<0 case) | `sorry` |
| `RootScopedChain.lean:1357` | `dd_fmcs_backward_P` | `sorry` |
| `RootScopedChain.lean:1410` | `dd_bfmcs_restricted_tc` | `sorry` |
| `RootScopedChain.lean:1414` | `dd_bfmcs_restricted_buc` | `sorry` |
| `RootScopedChain.lean:1419` | `dd_bfmcs_restricted_fuc` | `sorry` |
| `OrderedSeedConsistency.lean` | `enriched_resolving_seed_consistent` | proved |
| `OrderedSeedConsistency.lean` | `ordered_two_defect_seed_consistent` | need to verify |
| `RootScopedChain.lean:975` | `discharge_single_step` | proved |
| `RootScopedChain.lean:1117` | `phi_imp_F_phi` | proved |
| `Decidability/FMP/` | FMP infrastructure | unknown — needs examination |

---

## Confidence Levels

| Approach | Confidence | Rationale |
|----------|------------|-----------|
| Identity tail architecture | MEDIUM (55-65%) | Mathematically correct per Report 13; main risk is `extended_defect_seed_consistent` for n > 2 |
| FMP bypass | UNKNOWN (check first) | Could be HIGH if FMP is close to proved in Decidability/FMP/ |
| buc/fuc independent of forward_F | LOW (20-30%) | Guard condition for buc requires step transfer; no clean bypass found |
| Round-robin chain (current) + fix | LOW (35%) | Case 2 deferral is fundamental obstacle confirmed in 22+ rounds |

**Overall**: The most important new information from this round is:
1. The identity tail architecture (Report 13) has never been implemented — it should be
2. The FMP directory exists and may offer an independent completeness path
3. The u_carry seed for buc step transfer fails due to G-lifting limitation

---

## Actionable Recommendations

1. **Examine `Decidability/FMP/` directory** (30 minutes): If FMP is nearly proved,
   redirect all effort there. FMP-based completeness requires no forward_F at all.

2. **Implement identity tail chain** (20-30 hours): The finite-discharge + identity-tail
   approach is the most mathematically justified approach for closing forward_F. Prerequisite:
   verify `ordered_two_defect_seed_consistent` in OrderedSeedConsistency.lean, then extend
   to n defects.

3. **Do not attempt buc/fuc before forward_F** (revised from round 22): The guard condition
   for buc is harder than assessed in round 21 (85% → 20-30% independent confidence). The
   most efficient path is to close forward_F first, then derive buc/fuc from it.
