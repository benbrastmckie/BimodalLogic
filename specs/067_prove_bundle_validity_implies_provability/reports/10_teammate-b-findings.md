# Task 67: Teammate B Findings — Alternative Proof Architectures

**Session**: sess_1774755166_research-b
**Date**: 2026-03-28
**Focus**: Alternative proof architectures for bundle_validity_implies_provability; detailed analysis of the F_top blocker and its resolutions

---

## Key Findings

### 1. The Blocker Is Precisely Identified: F_top ∉ deferralClosure(phi) for General phi

The current plan (04_bypass-z-chain-plan.md, Phase 1) is blocked because:

- `DeferralRestrictedSerialMCS phi` requires `has_F_top : F_top ∈ world` AND `is_drm : DeferralRestrictedMCS phi world`
- `DeferralRestrictedMCS phi world` requires `world ⊆ deferralClosure phi`
- Together these imply `F_top ∈ deferralClosure phi`
- But `deferralClosure phi = closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi`
- `F_top = F(neg bot)` is in closureWithNeg(phi) ONLY IF `neg bot` is a subformula of phi
- For general phi (e.g., `box p`), F_top is NOT in deferralClosure(phi)

This is NOT a gap in the proof — it is a structural impossibility. The `DeferralRestrictedSerialMCS` structure is self-contradictory for formulas phi where F_top ∉ deferralClosure.

**Confirmed by**: `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919), which proves that ANY F-formula in deferralClosure must be in closureWithNeg. Since F_top ∉ closureWithNeg(phi) for general phi, F_top ∉ deferralClosure(phi).

### 2. Existing Sorry-Free Infrastructure Survey

| Component | File | Status | Relevance |
|-----------|------|--------|-----------|
| `parametric_canonical_truth_lemma` | ParametricTruthLemma.lean:207 | **Sorry-free** | Requires B.temporally_coherent |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean:367 | **Sorry-free** | Requires B.temporally_coherent |
| `construct_bfmcs_bundle` | UltrafilterChain.lean:2853 | **Sorry-free** | Bundle-level coherence only |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean:2966 | **Sorry-free** | Core contrapositive setup |
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean:2887 | **Sorry-free** | F-witnesses in forward chain |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean:4238 | **Sorry-free** | P-witnesses in backward chain |
| `build_restricted_tc_family` | SuccChainFMCS.lean:4642 | **Sorry-free** (body) | RestrictedTCFamily constructor |
| `deferral_restricted_lindenbaum` | RestrictedMCS.lean:714 | **Sorry-free** | DRM extension lemma |
| `neg_consistent_gives_mcs_without_phi` | RestrictedTruthLemma.lean:412 | **Sorry-free** | Direct completeness lemma |
| `bundle_completeness_contradiction` | UltrafilterChain.lean:2947 | **Sorry-free** | Shows not all MCSes have phi |
| `MCS_to_SerialMCS` | SuccChainFMCS.lean:154 | **Sorry-free** | Every MCS has F_top, P_top |
| `Z_chain_forward_F` | UltrafilterChain.lean:2424 | **HAS SORRY** | Fundamental gap (confirmed) |
| `boxClassFamilies_temporally_coherent` | UltrafilterChain.lean:1816 | **HAS SORRY** | Family-level coherence (blocked) |

### 3. The Gap: From Bundle-Level to Family-Level Temporal Coherence

The existing `construct_bfmcs_bundle` is sorry-free and provides **bundle-level** coherence:
```
bundle_forward_F: F(phi) in fam.mcs(t) → ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs(s)
```

The `parametric_canonical_truth_lemma` requires **family-level** coherence:
```
B.temporally_coherent: ∀ fam ∈ families, (∀ t φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s)
```

The truth lemma backward G case is:
```
G(psi) ∉ fam.mcs(t) → F(neg psi) ∈ fam.mcs(t) → ∃ s > t, neg psi ∈ fam.mcs(s)
```
The witness s must be in the SAME family fam because the semantic hypothesis `∀ s ≥ t, truth_at ... (parametric_to_history fam) s psi` is evaluated along a fixed history derived from fam, not from other families.

### 4. Why the Restricted Chain Needs DeferralRestrictedSerialMCS

The restricted chain construction provides same-chain F-witnesses by bounding F-nesting:
- `restricted_forward_chain_forward_F` works because `iter_F k psi` for k > max_F_depth eventually falls outside deferralClosure
- This means `iter_F k psi ∉ restricted_chain(n)` for k large, so the inductive witness argument terminates
- This bounding REQUIRES the seed to be a DeferralRestrictedMCS (whose world ⊆ deferralClosure)

If we use a full MCS as seed, F-nesting is unbounded, and the witness argument might never terminate.

### 5. The `neg_consistent_gives_mcs_without_phi` Path (Near-Complete)

`RestrictedTruthLemma.lean` already contains `neg_consistent_gives_mcs_without_phi` (line 412), which is **sorry-free** and directly gives:
```lean
∃ M : Set Formula, SetMaximalConsistent M ∧ neg(phi) ∈ M ∧ phi ∉ M
```

This uses direct Lindenbaum (full MCS, not DRM). The full MCS M HAS F_top and P_top. The gap remaining: we need to connect `phi ∉ M` to `phi is semantically false` using a **truth lemma for a model built from M**.

Building a model from M using `construct_bfmcs_bundle` is sorry-free, but the truth lemma for the bundle still requires `B.temporally_coherent`.

---

## Alternative Approaches Identified

### Approach A: Extend deferralClosure to Always Include Seriality Formulas

**Idea**: Redefine `deferralClosure phi = closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ {F_top, P_top}`.

**Why it would work**:
- F_top ∈ deferralClosure phi for ALL phi
- DRM Lindenbaum of `{neg phi}` (now deferral-restricted since neg phi ∈ old deferralClosure ⊆ new) would have F_top by DRM maximality (F_top is a theorem, so excluding it would be inconsistent)
- F-nesting bound still holds: max F-depth of F_top = 1, which only increases the bound by 1 if phi has no F-formulas
- The restricted chain construction would work

**What breaks**:
- `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919) becomes FALSE for F_top: F_top ∈ deferralClosure but F_top ∉ closureWithNeg for general phi
- This theorem is used in `constrained_successor_seed_restricted_subset_deferralClosure` and related places
- Needs to be replaced with: "F(chi) ∈ deferralClosure phi → F(chi) ∈ closureWithNeg phi ∨ F(chi) ∈ {F_top, P_top}"
- The F-nesting bound theorems `max_F_depth_deferralClosure_eq` would need updating for the new seriality formulas

**Estimated work**: 50-150 lines of changes in SubformulaClosure.lean and RestrictedMCS.lean. Moderate risk.

**Recommendation**: This is the cleanest fix but requires careful threading of the new case.

### Approach B: New Structure SerialDRM (without requiring F_top ∈ closure)

**Idea**: Define a new structure `SerialDRM phi` that has `world = DRM ∪ {F_top, P_top}` where DRM ⊆ deferralClosure phi. Modify `constrained_successor_restricted` to work with `SerialDRM`.

**Why it might work**:
- The restricted chain logic only uses F_top as a WITNESS for "there exists a next step"
- The F-nesting bound argument only needs to bound nesting of formulas WITHIN the closure
- F_top at the seed level doesn't add unbounded nesting

**What's needed**:
- New `SerialDRM` structure definition (or a modified `DeferralRestrictedSerialMCS` allowing F_top ∉ deferralClosure as a special case)
- Prove that `constrained_successor_seed_restricted` works for SerialDRM seeds
- The successor still stays within deferralClosure (not including F_top unless it was in the seed)
- F_top propagation: `F_top_in_restricted_successor` at line 2300 requires `F_top ∈ u ⊆ deferralClosure`. If F_top ∈ u but F_top ∉ deferralClosure, the proof breaks.

**Critical blocker**: `F_top_in_restricted_successor` at line 2300 uses:
```lean
have h_F_top_in_dc : Formula.some_future ψ ∈ (deferralClosure phi : Set Formula) :=
    h_drm.1.1 h_F_top  -- uses DeferralRestricted: world ⊆ deferralClosure
```
So the proof of F_top propagation itself relies on F_top ∈ deferralClosure. This approach would require rewriting this proof to handle the case F_top ∉ deferralClosure separately.

**The proof for F_top ∉ deferralClosure case**: Since F_top is a THEOREM, if F_top ∉ successor, then by DRM maximality of successor (applied to formulas IN deferralClosure), inserting F_top is inconsistent. But F_top is a theorem — contradiction. However, this argument only works if we can invoke DRM maximality on F_top... which requires F_top ∈ deferralClosure! The argument goes circular.

**Alternative argument for F_top ∉ deferralClosure case**: The DRM maximality doesn't apply. But: the successor is consistent, and F_top is a theorem. Can we prove F_top ∈ successor directly? The successor is built by `deferral_restricted_lindenbaum` applied to the seed. The seed contains `deferralDisjunctions(u)` which includes `(neg bot) ∨ F(neg bot) = (neg bot) ∨ F_top` when `F(neg bot) ∈ u`. But if F_top ∈ u, this disjunction is in the seed, and by DRM negation completeness within deferralClosure...

Wait, there's a subtlety: `deferralDisjunction(neg bot) = (neg bot) ∨ F(neg bot)`. If F_top = F(neg bot) ∈ u, then this disjunction IS in the successor. But the DRM negation completeness only applies to formulas IN deferralClosure. If `(neg bot) ∨ F_top ∉ deferralClosure`, then DRM doesn't tell us how the disjunction resolves.

Actually, from the existing `F_top_in_restricted_successor` proof (lines 2408-2533), the proof already handles the case via a complex argument using deferralDisjunctions. The proof USES `h_F_top_in_dc : F_top ∈ deferralClosure phi` at line 2420. If we remove this requirement, we need to redo this argument.

**The argument without deferralClosure membership**: The successor is built by Lindenbaum extending the seed. The seed contains `(neg bot) ∨ F_top` (from deferralDisjunctions when F_top ∈ u). By Lindenbaum, the MCS extension either contains neg bot or F_top (by negation completeness of the FULL Lindenbaum MCS, not just the DRM!). If neg bot is in the successor, then since neg bot is a theorem (⊢ neg bot), the successor also has neg bot as a theorem... which is fine. We need F_top specifically.

Actually: the Lindenbaum construction gives a DRM, not a full MCS. The DRM may or may not contain `(neg bot) ∨ F_top` if this disjunction is not in deferralClosure.

**This approach is viable but complex**. It would require rewriting `F_top_in_restricted_successor` to handle the case F_top ∉ deferralClosure using a different argument (e.g., showing the full MCS extension of the successor contains F_top, and then using some transfer argument).

**Estimated work**: 100-200 lines. High complexity.

### Approach C: Completeness via Alternative Semantic Argument

**Idea**: Instead of the full bidirectional truth lemma, use a more direct semantic argument. The completeness proof needs to show: if phi is valid over Int, then phi is provable.

The core of the argument: if phi is not provable, construct a TaskModel (over Int) where phi is false.

**Alternative construction**:
1. Not provable → neg(phi) consistent (sorry-free)
2. Lindenbaum: full MCS M with neg(phi) (sorry-free)
3. Build BFMCS_Bundle from M (sorry-free via `construct_bfmcs_bundle`)
4. The eval_family is `SuccChainFMCS(MCS_to_SerialMCS M)`

For the contradiction: we need to show phi is FALSE at (eval_family, 0) in the canonical model. The FORWARD direction of the truth lemma (MCS membership → truth) IS available even with bundle-level coherence only. What's blocked is the BACKWARD direction (truth → MCS membership).

But for the specific formula phi (not neg phi), we only need the FORWARD direction applied to neg phi:
```
neg(phi) ∈ M.world = eval_family.mcs(0) → neg(phi) is true → phi is false at time 0
```

The forward truth direction for neg(phi) = phi.imp.bot requires:
- Forward imp: (phi → ⊥) ∈ MCS, truth(phi) ⊢ truth(⊥) = False
- This uses BACKWARD IH for phi
- Backward IH for phi is: truth_at(phi) → phi ∈ MCS
- For temporal subformulas of phi, this requires forward_F

So we're back to needing temporal coherence. This confirms the fundamental bidirectionality requirement.

**However**: there's a special case! If phi is a PROPOSITIONAL formula (no temporal operators), the backward IH for phi never needs forward_F. For purely propositional phi, the truth lemma is bidirectional without temporal coherence.

More generally: for phi of bounded F/H-depth, we only need forward_F for formulas of depth < depth(phi). This is exactly the closure restriction argument. But the closure still needs F_top for the DRM construction.

**Verdict**: This approach doesn't help bypass the F_top blocker.

### Approach D: Construct a Custom Omega with Restricted History

**Idea**: Instead of using the full ParametricCanonicalOmega (all families), use only the single-family omega from the restricted chain. This singleton-Omega approach would avoid the box backward issue (since box's Omega-quantification is trivially over one history).

**Why it fails** (already documented in previous research): The box backward case requires:
```
∀ sigma ∈ Omega, truth_at sigma t psi → box psi ∈ MCS
```
With singleton Omega containing only the restricted family history, this requires:
```
truth_at (restricted_history) t psi → box psi ∈ restricted_chain(t)
```
This doesn't hold without modal saturation (box psi ∈ chain(t) is NOT implied by psi being true in a single history).

Confirmed impossible by `SuccChainTruth.lean:35-43`.

### Approach E: Completeness via Truth Lemma Scoped to phi-Subformulas (No DRM)

**Idea**: Prove a truth lemma specifically for the chain built from the FULL Lindenbaum MCS M, but scoped to subformula(phi). The key observation: we only need forward_F for formulas in subformulaClosure(phi), and within subformulaClosure, F-nesting is bounded.

**The construction**:
1. Lindenbaum gives full MCS M with neg(phi) (sorry-free)
2. M is a SerialMCS (F_top, P_top in M)
3. Build SuccChainFMCS from M — but this has the unbounded forward_F problem
4. Restrict the truth lemma to subformulaClosure(phi): for psi ∈ subformulaClosure(phi), prove psi ∈ SuccChainFMCS.mcs(0) ↔ truth_at...

The problem remains: the BACKWARD G direction needs forward_F for `neg(psi)` where psi ∈ subformulaClosure(phi). Forward_F must be SAME-CHAIN. For SuccChainFMCS (full MCS chain), forward_F is NOT proven (it depends on the false `f_nesting_is_bounded`).

**Why not bounded within subformulaClosure**: Even though F-nesting depth of psi ∈ subformulaClosure(phi) is bounded, the FULL MCS chain might contain iter_F^100(neg psi) for some psi, requiring 100 successor steps before witnessing neg psi. This is different from the restricted chain which only has iter_F^k(chi) for k bounded by the closure depth.

**Verdict**: This approach hits the same fundamental blocker as the restricted chain approach (why same-family forward_F requires DRM), just packaged differently.

---

## Recommended Approach

### Primary Recommendation: Approach A — Extend deferralClosure

**Rationale**: This is the minimal, mathematically justified fix. The seriality formulas F_top and P_top are provable theorems that hold in EVERY consistent set. Including them in the closure is semantically correct and only requires:
1. Updating the `deferralClosure` definition
2. Updating `some_future_in_deferralClosure_is_in_closureWithNeg` (currently states ALL F-formulas in closure are in closureWithNeg — becomes: all EXCEPT the two seriality formulas)
3. Checking downstream uses of this theorem

**Critical changes needed**:
- `SubformulaClosure.lean:649` — extend deferralClosure definition to `∪ {F_top, P_top}`
- `SubformulaClosure.lean:919` — add exception case for F_top in `some_future_in_deferralClosure_is_in_closureWithNeg`
- `SubformulaClosure.lean:752` — update `max_F_depth_deferralClosure_eq` to account for F_top having depth 1

**Why this doesn't break the key arguments**:
- F-nesting bound: F_top has depth 1. The max_F_depth_in_closure is already ≥ 0. After extending, max_F_depth is max(original, 1) which is fine for the termination argument.
- DRM maximality: F_top is a theorem, so inserting it is consistent. DRM maximality will guarantee F_top ∈ DRM (since excluding it would allow consistent insertion, contradicting maximality).
- The restricted chain construction works because F-nesting within deferralClosure is still bounded.

**Risk**: Moderate. Changes to core syntax infrastructure need care. The `some_future_in_deferralClosure_is_in_closureWithNeg` update is the most delicate.

### Secondary Recommendation: Approach B — SerialDRM Structure

If Approach A proves too disruptive to existing proofs, define `SerialDRM phi` as a lightweight wrapper that bundles:
- `core_drm : DeferralRestrictedMCS phi core_world` where `core_world ⊆ deferralClosure phi`
- `world = core_world ∪ {F_top, P_top}`
- `has_F_top : F_top ∈ world` — trivially true
- `has_P_top : P_top ∈ world` — trivially true

Then prove `F_top_in_restricted_successor_serial` for SerialDRM using the consistency argument:
- The successor's Lindenbaum extension (full MCS) contains F_top
- The successor's DRM core must contain F_top IF F_top ∈ deferralClosure, else F_top is added separately

This separates the DRM logic from the seriality requirement cleanly.

---

## Evidence and Code References

### The F_top Membership Proof Chain

```
DeferralRestrictedSerialMCS.has_F_top : F_top ∈ world
DeferralRestrictedSerialMCS.is_drm : DeferralRestrictedMCS phi world
DeferralRestrictedMCS (line RestrictedMCS.lean:676):
  = DeferralRestrictedConsistent phi S ∧ (maximality condition)
DeferralRestrictedConsistent:
  = DeferralRestricted phi S ∧ SetConsistent S
DeferralRestricted phi S (line RestrictedMCS.lean:~):
  = S ⊆ deferralClosure phi (and S closed under derivation within closure)
```
Therefore: `F_top ∈ world` AND `world ⊆ deferralClosure phi` → `F_top ∈ deferralClosure phi`.

### `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919)
This theorem states: if `F(chi) ∈ deferralClosure phi`, then `F(chi) ∈ closureWithNeg phi`. The proof uses:
1. F-formulas can only be in deferralClosure via closureWithNeg (not via deferralDisjunctionSet, which produces depth-0 disjunctions with depth < 1 for F-formulas)
2. This means F_top = F(neg bot) ∈ deferralClosure phi iff F_top ∈ closureWithNeg phi

**Usage scope**: This theorem is called at 16 locations: SuccChainFMCS.lean (14 times) and SuccExistence.lean (2 times). Approach A would need ALL these call sites updated to handle the F_top/P_top special case. The key pattern used is: `F(chi) ∈ deferralClosure → F(chi) ∈ closureWithNeg → chi ∈ subformulaClosure → chi ∈ deferralClosure`. With Approach A, when F(chi) = F_top, the intermediate step `F_top ∈ closureWithNeg` would fail. These sites would need to be updated to add a branch: `if F(chi) ∈ {F_top, P_top} then chi = neg bot ∈ subformulaClosure`.

Note: `neg bot` (which equals `⊤`) IS always in subformulaClosure of any formula because it appears as the base case of Formula.bot which is in the syntax. Let me clarify: `neg bot = bot.imp bot`, which requires `bot ∈ subformulaClosure` (true by closure self-mem for bot). So `neg bot ∈ subformulaClosure(phi)` requires that `bot` has been added... Actually `bot` is always in subformulaClosure since it's `Formula.bot`, so `neg bot = Formula.neg Formula.bot` is in closureWithNeg. But `F_top = some_future (neg bot)` requires `neg bot ∈ subformulaClosure` for `F_top ∈ closureWithNeg`. This requires `bot.neg ∈ subformulaClosure(phi)` which requires `bot ∈ subformulaClosure(phi)`... which is NOT automatically true (subformulaClosure is the closure of SUBFORMULAS of phi, not all formula atoms).

### `F_top_in_restricted_successor` (SuccChainFMCS.lean:2300)
The proof at line 2420 uses:
```lean
have h_F_top_in_dc : Formula.some_future ψ ∈ (deferralClosure phi : Set Formula) :=
    h_drm.1.1 h_F_top
```
This is the exact point where F_top ∈ deferralClosure is required. Fixing this is the key to Approach B.

### Current Sorry Counts (Task-Relevant Files)
- `FrameConditions/Completeness.lean`: 2 sorries (`dense_completeness_fc`, `bundle_validity_implies_provability`)
- `RestrictedTruthLemma.lean`: 2 sorries (`restricted_chain_G_propagates:116`, `restricted_chain_H_step:158`)
- `SuccChainFMCS.lean`: 19 sorries (most in deprecated code)
- `UltrafilterChain.lean`: 6 sorries (Z_chain approach, construct_bfmcs old approach)

### Sorry-Free Infrastructure Ready to Use
- `neg_consistent_gives_mcs_without_phi` (RestrictedTruthLemma.lean:412) — direct path to MCS without phi
- `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2887) — same-chain F-witnesses
- `build_restricted_tc_family` (SuccChainFMCS.lean:4642) — packages TC family with coherence
- `parametric_canonical_truth_lemma` (ParametricTruthLemma.lean:207) — full truth lemma if given `B.temporally_coherent`

---

## Confidence Level

**HIGH** on:
- The precise identification of the F_top blocker
- Why the `DeferralRestrictedSerialMCS` structure is self-contradictory for general phi
- Why Approaches C, D, E fail (confirmed independently of previous research)
- The correctness of Approach A (extending deferralClosure)

**MEDIUM** on:
- Exact scope of downstream changes needed for Approach A
- Whether `F_top_in_restricted_successor` can be repaired for the case F_top ∉ deferralClosure (Approach B)
- Whether all 19 sorry lines in SuccChainFMCS.lean that touch restricted chain are on the critical path or deprecated

**LOW** on:
- Any alternative architecture that doesn't go through the DRM/restricted chain path
- Whether the FMP filtration approach (TruthPreservation.lean:263,281) could be fixed to provide an independent completeness path

---

## Actionable Next Steps

### Immediate (lowest risk, high value):
1. **Check `deferral_restricted_lindenbaum` for `{neg phi}` with new seriality formulas**: Can `{neg phi, F_top, P_top}` be passed directly to `deferral_restricted_lindenbaum`? This requires `{neg phi, F_top, P_top} ⊆ deferralClosure phi` — not currently true, but would be with Approach A.

2. **Prototype Approach A**: Try adding `F_top, P_top` to `deferralClosure` and check if `lake build Bimodal.Syntax.SubformulaClosure` still passes (updating the failing theorems). This gives a concrete feasibility estimate.

### Investigation items:
3. **Check the `restricted_chain_G_propagates` sorry** (RestrictedTruthLemma.lean:116): This is already marked as NOT needed for the main path. Confirm it's truly not needed for the completeness proof (since we only need truth at t=0).

4. **Verify `restricted_chain_H_step` sorry** (RestrictedTruthLemma.lean:135): Same question — is H-step needed for the truth lemma at t=0?

5. **Impact of Approach A is now mapped**: `some_future_in_deferralClosure_is_in_closureWithNeg` is used at 16 locations (14 in SuccChainFMCS.lean, 2 in SuccExistence.lean). Each use follows the pattern: derive chi ∈ subformulaClosure from F(chi) ∈ deferralClosure. For the F_top special case (chi = neg bot = ⊤), `neg bot ∈ subformulaClosure(phi)` must be shown differently — it's in subformulaClosure(phi) only if `bot ∈ subformulaClosure(phi)`, which holds only if phi contains `bot` as a subformula. For formulas without bot, `neg bot ∉ subformulaClosure(phi)`. However, we may not need `neg bot ∈ subformulaClosure` for these proofs — we may only need `neg bot ∈ deferralClosure(phi)` (weaker). With Approach A, neg bot would be in deferralClosure via: neg bot ∈ closureWithNeg IF neg bot ∈ subformulaClosure OR neg bot = neg(something in subformulaClosure). Since neg bot = bot → bot, we need bot ∈ subformulaClosure(phi). This may not hold for all phi. **This suggests Approach A needs to also include neg bot in the extended closure**, making it: `extendedDeferralClosure = deferralClosure ∪ {F_top, P_top, neg_bot}` or similar. The exact scope needs more analysis.
