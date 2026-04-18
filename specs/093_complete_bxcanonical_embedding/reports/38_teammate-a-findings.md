# Teammate A Findings: S/U and Strict/Weak Semantics Analysis

**Round**: 38
**Focus**: Primary analysis of how S/U and strict/weak G/H semantics affect the sorry sites

---

## Key Findings

### 1. Current Language and Axiom System

The Formula type (`Theories/Bimodal/Syntax/Formula.lean:66-83`) has 8 constructors:
- `atom`, `bot`, `imp` (propositional base)
- `box` (S5 modal)
- `all_past` (H), `all_future` (G) (universal tense)
- `untl` (U), `snce` (S) (Until/Since)

The BX axiom system (`Theories/Bimodal/ProofSystem/Axioms.lean`) has 37 constructors. The U/S-specific axioms are BX2-BX12 (22 of the 37). Key BX axioms:
- **BX1/BX1'**: `G(φ) → φ` / `H(φ) → φ` (REFLEXIVITY — marks G/H as weak/reflexive)
- **BX5**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` (self-accumulation)
- **BX6**: `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` (absorption)
- **BX11**: `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` (linearity)
- **BX12**: `F(φ) → (⊤ U φ)` (F-Until bridge)

Current semantics (`Theories/Bimodal/Semantics/Truth.lean:127`):
```
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```
This is **weak/reflexive** G (quantifies over `t ≤ s`, including `s = t`).

### 2. The Three Sorry Sites

All three sorrys are in `RootScopedChain.lean` around lines 1516-1527:

```lean
theorem dd_bfmcs_restricted_tc (M₀ ...) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_temporally_coherent root := by
  sorry  -- Line 1517

theorem dd_bfmcs_restricted_buc (M₀ ...) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_backward_until_since_coherent root := by
  sorry  -- Line 1522

theorem dd_bfmcs_restricted_fuc (M₀ ...) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_forward_until_since_coherent root := by
  sorry  -- Line 1527
```

These are called from `dd_countermodel` (line 1550-1556) which is the leaf used by `bx_completeness`.

**What each sorry requires**:

- **`dd_bfmcs_restricted_tc`** (restricted temporal coherence): For every family in `dd_bfmcs`, for every formula `φ ∈ deferralClosure(root)`, if `F(φ) ∈ fam.mcs t` then `∃ s > t, φ ∈ fam.mcs s`, and dually for P. The deep obstruction is `rr_fwd_chain_forward_F` at `RootScopedChain.lean:1386-1413`, which has a depth-0 sorry because the round-robin chain can perpetually defer φ via BX11 choosing a different formula at each step.

- **`dd_bfmcs_restricted_buc`** (backward Until/Since coherence): Given witness pattern (ψ at s ≥ t, φ on guard [t,s)), derive `(φ U ψ) ∈ fam.mcs t`. Requires step-transfer: `(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`. The comment at `UntilSinceCoherence.lean:28-36` explains this is NOT derivable from the bare chain structure.

- **`dd_bfmcs_restricted_fuc`** (forward Until/Since coherence): Given `(φ U ψ) ∈ fam.mcs t`, produce witness s ≥ t with ψ at s and φ on [t,s). This depends on `defect_fwd_chain_forward_F` at line 2195 which is also sorry'd for the same fundamental reason: the chain cannot guarantee resolution of a specific φ when BX11 allows perpetual deferral to other formulas.

### 3. Blocker Analysis: Impact of Removing Until/Since

**What would change if U/S were removed from the language** (reducing to G, H, F, P, □, ◇ only):

**`dd_bfmcs_restricted_tc` (temporal coherence)**: This sorry would potentially become **provable**. Without U/S:
- `deferralClosure(root)` would not contain Until/Since formulas or their F-inner extractions
- The round-robin chain construction (`rr_fwd_chain`) would only need to resolve F(φ) where φ is a G/H/atom formula
- BX12 (`F(φ) → ⊤ U φ`) would be vacuous since `⊤ U φ` isn't a subformula of anything in the language
- The BX11 fold in the enriched seed construction would not need to handle Until/Since goals
- The f_nesting_depth argument would be simpler: F(F(ψ)) → F(ψ) is still needed for the induction, but the depth-0 base case (the sorry) would be: just an MCS containing F(φ) where φ is a non-F formula — the forward_F witness construction would be simpler without U/S interaction

However, the **fundamental obstruction** (BX11 perpetual deferral) would still apply even without U/S: the chain at a resolving step for target α could still "use up" the BX11 witness for a different F-formula β, preventing ψ from being resolved at that step.

**Net assessment**: Removing U/S would **simplify** the construction substantially but would NOT by itself make the depth-0 sorry trivially provable. The BX11 perpetual deferral problem is intrinsic to any round-robin construction on the natural numbers — it is about F-formulas (G/H-negations), not specifically about U/S.

**`dd_bfmcs_restricted_buc` (backward Until/Since coherence)**: This sorry would **disappear entirely** if U/S were removed from the language. The predicate `restricted_backward_until_since_coherent` quantifies only over `φ U ψ ∈ subformulaClosure(root)` and `φ S ψ ∈ subformulaClosure(root)`. With no U/S constructors in Formula, `subformulaClosure(root)` contains no Until or Since formulas, making this vacuously true.

**`dd_bfmcs_restricted_fuc` (forward Until/Since coherence)**: Same — this sorry would **disappear entirely** without U/S. The predicate is vacuously satisfied when the language has no Until/Since.

**Conclusion on removing U/S**: Removing U/S would eliminate 2 of 3 sorrys immediately (buc and fuc become vacuous). The remaining sorry (tc) would still exist but would be simpler — it would reduce to the pure F-resolution problem without the complication of Until/Since formulas appearing in deferralClosure.

### 4. Blocker Analysis: Impact of Strict vs. Weak G/H

**Current semantics**: G is weak/reflexive (`t ≤ s`). BX1 (`G(φ) → φ`) is an axiom.

**What would change with strict/irreflexive G** (`t < s` only):

**Canonical ordering**: `bx_le` is defined as `g_content(w) ⊆ v.formulas` where `g_content(S) = {φ | G(φ) ∈ S}`. Under strict G, `G(φ)` only forces `φ` at strictly later times. The BX1 axiom would be **dropped** (since `G(φ) → φ` is not valid under strict semantics).

**Impact on the sorry sites**:

1. **`dd_bfmcs_restricted_tc`**: Under strict G semantics, the canonical chain uses `bx_G_forward` as `G(φ) ∈ fam.mcs t → φ ∈ fam.mcs (t+1)` (not at `t` itself). This would make the chain **strictly progressing** — `fam.mcs t` and `fam.mcs (t+1)` are genuinely different MCS elements. The key question is whether the F-resolution problem becomes easier: with strict G, `F(φ) = ¬G(¬φ)` means "there exists s > t with φ at s". The BX11 fold might behave differently, but the fundamental perpetual deferral obstruction does NOT depend on reflexivity — it arises from BX11 allowing choice between multiple F-formulas, regardless of whether G is strict or reflexive.

2. **`dd_bfmcs_restricted_buc`**: Under strict semantics, the backward Until coherence condition changes: `φ U ψ` at `t` (strict) requires `∃ s > t, ψ(s) ∧ ∀ r, t < r < s → φ(r)` (or possibly `∃ s ≥ t` with strict guard). The BX8 `ψ → φ U ψ` axiom would be replaced by a version that only works when `s = t` under reflexive... Under strict Until semantics, the base case (t = s) may fail. This could make the backward Until coherence **harder** to prove, not easier.

3. **`dd_bfmcs_restricted_fuc`**: The forward coherence under strict semantics would require: from `φ U ψ ∈ fam.mcs t`, find `s > t` with `ψ(s)` and `φ` on `(t, s)`. Under reflexive Until (current), BX8 gives `ψ → φ U ψ` so the t=s case works. Under strict Until, BX8 would not be an axiom and the construction would need to use BX12 (`F(φ) → ⊤ U φ`) and BX10 (`φ U ψ → F(ψ)`) more carefully.

**Assessment of strict vs. weak**: Switching to strict semantics would:
- Require dropping BX1 axiom (G is no longer reflexive)
- Require modifying BX8 (reflexive Until introduction `ψ → φ U ψ` may fail)
- Require significant restructuring of both the axiom system AND the semantics
- Would NOT remove the fundamental F-resolution obstruction
- Would likely make backward Until coherence **harder** (no reflexive base case)

### 5. What the Current Proof Already Has Sorry-Free

The quasimodel infrastructure is partially sorry-free:
- `Quasimodel/Construction.lean`: Hintikka points, one-step relation, defect discharge structure — all sorry-free
- `Quasimodel/LocusControl.lean`: `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` — proved via BX9+BX10+`bx_forward_witness` (see `CanonicalChain.lean:21-22`)
- `Frame.lean`: `bx_G_backward`, `bx_H_backward`, `bx_modal_witness`, `box_preserved_along_bx_le` — all sorry-free
- `RootScopedChain.lean`: The F(F(ψ)) → F(ψ) lemma (`FF_imp_F`), forward_F for depth ≥ 1 — sorry-free
- The backward_P chain construction (`defect_bwd_chain`) and its `P_obligation_persists` properties — sorry-free
- The step-by-step enriched chain properties (g_content propagation, F-obligation persistence) — sorry-free

**What depends on Until/Since**: The `defect_fwd_chain_forward_F` (line 2190-2196) and `defect_bwd_chain_backward_P` (line 2283-2289) are both sorry'd. Both sorrys have the same root cause: the enriched chain preserves F/P obligations but cannot guarantee resolution. The comment at line 2279 explicitly states "This sorry represents the backward analog of the BX11 perpetual deferral obstruction."

The Until/Since formulas appear in `extendedDeferralClosure` (line 812-814) which is what `dd_countermodel` uses as `sigma_list`. The Until/Since deferral sets (`untilDeferralSet`, `sinceDeferralSet`) are included in `sigma_list`, meaning the round-robin chain must handle them. Without U/S in the language, `extendedDeferralClosure` would reduce to `baseDeferralClosure`, substantially shrinking `sigma_list`.

### 6. g_content and Until/Since Propagation

The `g_content(M) = {φ | G(φ) ∈ M}` definition (Frame.lean:62) does NOT include Until/Since formulas in any structural way. The canonical ordering `bx_le` is defined purely via g_content.

The key incompatibility identified in `UntilSinceCoherence.lean:28-36` is:
- `bx_le` links MCS elements via G-content: `G(φ) ∈ w → φ ∈ v`
- Until/Since formulas `φ U ψ` are NOT G-formulas and have no `bx_le` propagation rule
- Therefore, `(φ U ψ) ∈ chain(n)` provides no mechanism to pull `(φ U ψ) ∈ chain(n-1)` backward

This is the precise reason why backward Until/Since coherence requires a special "step transfer" property that the current chain construction cannot prove.

**Removing U/S eliminates this incompatibility entirely** because there are no Until/Since formulas to propagate.

---

## Analysis Details

### Why the Depth-0 Sorry Is the Core Blocker

The `rr_fwd_chain_forward_F` sorry (line 1413) is labeled "the irreducible depth-0 obstruction." The comment at line 1368-1384 provides exhaustive analysis:

> "The f_nesting_depth induction resolves depth ≥ 1 trivially via FF_imp_F. The depth-0 base case is the core mathematical challenge: at resolving steps for other targets, the Lindenbaum extension of {target} ∪ g_content(M) can choose G(¬ψ) over F(ψ), permanently killing the F-obligation. Extended seed consistency ({target} ∪ g_content(M) ∪ f_carry(M)) fails in general when F(G(¬ψ)) ∈ M (Case 4 analysis, Section 24)."

This obstruction has NOTHING to do with U/S or with strict vs. weak semantics. It is about the nature of the Lindenbaum extension for the enriched seed: the MCS extending `{target} ∪ g_content(M)` is free to contain `G(¬ψ)` (which excludes F(ψ)), and BX11 cannot force all F-obligations to be resolved at every step.

### The Three Viable Paths Forward (Without Language Change)

From the analysis in the file:
1. **Non-linear chain** (omega-squared interleaving): Dovetail over all pairs (m, n) ensuring each formula is targeted infinitely often with sufficient "momentum"
2. **Quasimodel bridge** (800-1200 new LOC): Convert the finite quasimodel to a BFMCS; the finite case is easier because Sigma is finite and defect_count decreases
3. **Counting argument**: sigma_list membership + F-obligation persistence implies eventual resolution via pigeonhole on a finite closure

---

## Recommended Approach

### If the question is "which language is easier to prove complete?"

**Without U/S (G/H/F/P + Box only)**:
- 2 of 3 sorrys (buc, fuc) disappear immediately (vacuous)
- 1 sorry (tc) remains but with simpler structure (no U/S in deferralClosure)
- The depth-0 forward_F obstruction persists but sigma_list is smaller
- Posterior assessment: **substantially easier** — completing the language-restricted case is a realistic 2-3 week project

**With U/S but strict G/H**:
- All 3 sorrys remain, with different (possibly harder) proof obligations
- Backward Until coherence loses its reflexive base case (BX8 fails under strict Until)
- The axiom system requires redesign (remove BX1, modify BX8)
- Posterior assessment: **harder overall**, not recommended

**With current language (U/S + reflexive G/H) — recommended**:
- The buc and fuc sorrys require the step-transfer property, which is the cleanest approach
- The tc sorry requires a new chain construction strategy
- The quasimodel-based approach (Quasimodel/ directory already partially exists) is the most principled path

### Specific Recommendation

The most productive path for closing all 3 sorrys without language change is:

**For buc**: Implement the step-transfer lemma `(φ U ψ) ∈ chain(n+1) ∧ φ ∈ chain(n) → (φ U ψ) ∈ chain(n)` using the BX5 + BX6 axiom pair (self-accumulation + absorption). The enriched seed can be designed to maintain this invariant.

**For fuc**: Use the quasimodel bridge. The `Quasimodel/Construction.lean` already has the finite defect-discharge machinery. The key missing piece is `defect_fwd_chain_forward_F` — implementing this via the singleton-defect analysis (which can use `defect_fwd_step_choice_singleton` already proved at line 2161-2170) is the most direct path.

**For tc**: The depth-0 sorry for `rr_fwd_chain_forward_F` is the hardest. The most tractable approach is to use `defect_fwd_chain` (with defects = [ψ]) instead of `rr_fwd_chain`, since `defect_fwd_chain_forward_F` already has the needed `defect_fwd_step_choice_singleton` result providing the base case. The issue is bridging from `defect_fwd_chain` back to `dd_fmcs`.

---

## Confidence Level

**High confidence** on:
- Current language has U/S as primitive constructors (verified in Formula.lean)
- Current semantics is reflexive/weak for G/H (verified in Truth.lean:127)
- Removing U/S would make buc and fuc vacuously true (verified by inspecting the predicate definitions)
- The BX11 perpetual deferral obstruction is language-independent
- The depth-0 sorry is the binding constraint for temporal coherence

**Medium confidence** on:
- Whether `defect_fwd_chain_forward_F` with singleton [ψ] can close the sorry using `defect_fwd_step_choice_singleton`
- Whether the step-transfer for buc follows from BX5+BX6 in the enriched seed

**Lower confidence** on:
- The exact difficulty of strict-vs-weak changes to the axiom system
- Whether removing U/S simplifies the depth-0 obstruction enough to make it trivial
