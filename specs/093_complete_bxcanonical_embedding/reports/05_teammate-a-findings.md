# Teammate A Findings: Primary Strategy for forward_F/backward_P

**Task**: 93 - Complete BXCanonical embedding
**Artifact**: 05_teammate-a-findings.md
**Date**: 2026-04-13
**Angle**: Primary angle — most mathematically correct/elegant approach for forward_F/backward_P sorries

---

## Executive Summary

The `bx_fmcs_forward_F` and `bx_fmcs_backward_P` sorries (lines 493–503 of `CanonicalModel.lean`) cannot be closed as stated because they quantify over ALL formulas without a `root` parameter. However, `bx_bfmcs_restricted_tc` (line 603) delegates to these full-quantifier versions. The correct fix is to **bypass the unrestricted sorries entirely** by rewriting `bx_bfmcs_restricted_tc` to prove restricted temporal coherence directly without calling the unrestricted helpers. This approach is both mathematically correct and avoids touching the unsolvable unrestricted lemmas.

---

## Key Findings

### Finding 1: The Architecture Diagnosis

`bx_countermodel` (line 635) calls:
- `bx_bfmcs_restricted_tc` (for `restricted_temporally_coherent`)
- `bx_bfmcs_restricted_buc` (for `restricted_backward_until_since_coherent`)
- `bx_bfmcs_restricted_fuc` (for `restricted_forward_until_since_coherent`)

**Current `bx_bfmcs_restricted_tc` implementation** (lines 603–615) delegates to the UNRESTRICTED sorry-carrying lemmas:
```lean
theorem bx_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (bx_bfmcs M₀ h₀).restricted_temporally_coherent root := by
  intro fam hfam; obtain ⟨N, h_N, s, _, rfl⟩ := hfam
  constructor
  · intro t ψ _h_dc h_F
    have ⟨s', h_lt, h_ψ⟩ := bx_fmcs_forward_F N h_N (t - s) ψ h_F  -- calls SORRY
    ...
  · intro t ψ _h_dc h_P
    have ⟨s', h_lt, h_ψ⟩ := bx_fmcs_backward_P N h_N (t - s) ψ h_P  -- calls SORRY
    ...
```

The `_h_dc` arguments (the `ψ ∈ deferralClosure root` hypothesis) are discarded! This means the current code is simply delegating to an impossible full-quantifier statement and ignoring the key restriction that would make the proof tractable.

**Conclusion**: The unrestricted lemmas `bx_fmcs_forward_F` and `bx_fmcs_backward_P` are dead weight on the active proof path. The route forward is to prove `bx_bfmcs_restricted_tc` DIRECTLY, using the `h_dc` hypothesis properly.

### Finding 2: Why the Unrestricted Versions Cannot Be Proved

`bx_fmcs_forward_F` claims: for ALL formulas ψ, if F(ψ) ∈ chain(t), then ∃ s > t, ψ ∈ chain(s).

The chain at step n is built by:
- If F(schedule n) ∈ chain(n): use `forward_temporal_witness_seed` = `{schedule n} ∪ g_content`
- Otherwise: use `g_content ∪ f_carry` (preserves existing F-formulas)

At a resolving step, the seed `{ψ} ∪ g_content(M)` does NOT include `f_carry(M)`. The Lindenbaum extension may add anything consistent with `{ψ} ∪ g_content(M)`. Specifically, it may add `G(¬χ)` for any formula χ, which would kill `F(χ)`.

The counterexample pattern (from prior research, Report 02): M contains F(p), F(q), G(p → G(¬q)). Resolving p at step 0 produces seed {p} ∪ g_content(M). The Lindenbaum extension adds G(¬q) (it's compatible with the seed) killing F(q). Now F(q) may never be witnessed.

This is a fundamental obstruction: without scoping to a finite set where we can bound the F-nesting depth, the proof is blocked.

### Finding 3: The Restricted Version IS Provable via Deferral Semantics

`restricted_temporally_coherent root` requires:
```lean
∀ fam ∈ B.families, ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
  Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s
```

The key difference: the hypothesis `φ ∈ deferralClosure root` restricts attention to a FINITE set. For formulas in `deferralClosure root`, F-nesting depth is bounded by `closure_F_bound root`.

The proof approach requires a chain construction that preserves F-obligations for formulas in `deferralClosure root`. The mechanism is the **deferral seed** from `SuccExistence.lean`:

```lean
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u
-- where deferralDisjunctions u = {ψ ∨ F(ψ) | F(ψ) ∈ u}
```

This seed guarantees: for each F(ψ) ∈ u, the extension either contains ψ (resolved) or F(ψ) (deferred). Using `bounded_witness` from `CanonicalTaskRelation.lean` (proved sorry-free), F-nesting depth strictly decreases at each step for formulas within `deferralClosure root`, ensuring termination.

### Finding 4: The Current Chain Cannot Support a Direct Proof

The existing `int_chain` in `CanonicalModel.lean` uses `fwd_succ` which uses `forward_temporal_witness_seed = {ψ} ∪ g_content(M)` at resolving steps. This is NOT the deferral seed.

The proof of restricted forward_F for the current chain would require showing that for ψ ∈ deferralClosure(root) with F(ψ) ∈ chain(t), there exists s > t with ψ ∈ chain(s). Analysis of what happens at each step:

1. Step is resolving for χ = schedule(n), and χ = ψ: Then ψ ∈ chain(n+1) by `fwd_succ_resolves`. Done.
2. Step is resolving for χ ≠ ψ, and F(ψ) ∉ chain(n): Then we'd need F(ψ) to have entered the chain at some future step... but this requires a new induction. Actually: if F(ψ) ∉ chain(n), we cannot get F(ψ) ∈ chain(n+1) unless F(F(ψ)) ∈ chain(n) (then f_carry of chain(n) at a non-resolving step brings F(ψ) to chain(n+1)). This requires induction on the schedule covering ψ sufficiently often.
3. Step is non-resolving (F(schedule n) ∉ chain(n)): Then `fwd_succ_f_carry` gives f_carry(chain(n)) ⊆ chain(n+1). If F(ψ) ∈ chain(n), then F(ψ) ∈ f_carry(chain(n)) ⊆ chain(n+1). But this merely defers the problem one step.

**The schedule surjectivity**: `schedule_surjective_above` guarantees ∃ n ≥ k with schedule(n) = ψ. So eventually, a step resolves ψ directly IF F(ψ) ∈ chain at that step. The problem is: we need F(ψ) to still be in chain(n) when schedule(n) = ψ.

**At a non-resolving step**: f_carry is preserved (F(ψ) persists). Good.

**At a resolving step for χ ≠ ψ**: If F(ψ) ∈ chain(n), what happens? The seed is `{χ} ∪ g_content(chain(n))`. The Lindenbaum extension may or may not include F(ψ). This is NOT guaranteed.

So the current chain structure does NOT provably preserve F(ψ) through resolving steps for other formulas. The proof is blocked.

### Finding 5: Architectural Decision — Modify Chain vs. Prove Restricted Directly

There are two plausible routes:

**Route A: Modify the chain construction to use deferral seeds**

Replace `fwd_succ` with a `deferral_fwd_succ` that uses `successor_deferral_seed`. However:
- `successor_deferral_seed_consistent` requires `F(⊤) ∈ u` (see `SuccExistence.lean:811`)
- F(⊤) = `some_future ⊤` being in chain(t) for all t requires proof: G(⊤) ∈ M₀ → G(F(⊤)) ∈ M₀ (via seriality axiom) → F(⊤) ∈ chain(t) for t ≥ 0... Actually: F(⊤) ∈ M₀ follows from the seriality axiom (DF axiom: `⊢ F(⊤)` as a theorem). Since `⊢ F(⊤)`, it's in every MCS.
- **F(⊤) is a theorem**: The seriality axiom `F_top_mem_serialityFormulas` shows F(⊤) ∈ serialityFormulas ⊆ deferralClosure. This means F(⊤) is a theorem (it's in the axiom schema), so it belongs to EVERY MCS.
- Changing the chain construction is a larger refactor but would give a cleaner result. The modified chain would be more "honest" — it genuinely uses deferral semantics.

**Route B: Keep the current chain; prove restricted coherence by a different argument**

Use the schedule surjectivity + the f_carry preservation at non-resolving steps to argue: if F(ψ) ∈ chain(t), then either it's eventually resolved directly (when schedule hits ψ), or we can find an inductive argument based on f_carry.

However, as analyzed in Finding 4, the resolving steps for χ ≠ ψ break f_carry propagation. This argument cannot be completed without additional assumptions about the chain.

**Route C: Hybrid — prove a one-step forward_F for the existing chain, then iterate using schedule**

For the existing chain, we CAN show: if F(F(ψ)) ∈ chain(n), then F(ψ) ∈ chain(n+1). This is because:
- At a non-resolving step: f_carry of chain(n) includes F(F(ψ)) → F(ψ) ∈ f_carry ⊆ chain(n+1). WAIT — f_carry at a non-resolving step for the current step target preserves F-formulas in chain(n). So if F(ψ) ∈ f_carry(chain(n)) and step is non-resolving for schedule(n) ≠ ψ, then F(ψ) ∈ chain(n+1).

But at a RESOLVING step for schedule(n) ≠ ψ: f_carry is NOT preserved. The seed is {schedule(n)} ∪ g_content. F(ψ) is not guaranteed.

Conclusion: Route B and Route C are blocked. Route A (modify chain to use deferral seed) is the viable path.

### Finding 6: Why F(⊤) ∈ u Is Guaranteed for All Chain Elements

The seriality axiom for BX is: `⊢ F(⊤)` (the DF axiom / `temp_seriality_future`). Since every MCS contains all theorems, F(⊤) ∈ M for every MCS M. This means `successor_deferral_seed_consistent` applies to EVERY chain element, removing the precondition concern.

**Verification**: Looking at CanonicalModel.lean imports:
- `CanonicalChain.lean` is imported, which includes BX axioms
- The axiom `Axiom.temp_df` (or `DF: ⊢ F(⊤)`) should be a theorem

This needs verification: check if `theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.DF_future))` or similar exists to get F(⊤) ∈ any MCS.

### Finding 7: Until/Since Coherence — A Separate Problem

The `bx_bfmcs_restricted_buc` and `bx_bfmcs_restricted_fuc` sorries (lines 617–627) require:

For `restricted_backward_until_since_coherent`:
- Given ψ ∈ fam.mcs s, φ ∈ fam.mcs r for all t ≤ r < s, and (φ U ψ) ∈ subformulaClosure(root): prove (φ U ψ) ∈ fam.mcs t

For `restricted_forward_until_since_coherent`:
- Given (φ U ψ) ∈ fam.mcs t and (φ U ψ) ∈ subformulaClosure(root): produce witness s ≥ t with ψ ∈ fam.mcs s and φ ∈ fam.mcs r for t ≤ r < s

The backward direction uses `backward_until_from_step` from `UntilSinceCoherence.lean`, which requires a **step transfer hypothesis**: `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`.

For the current `int_chain`, this step transfer is available through the axiom `until_unfold_in_mcs` (or `or_until_in_mcs` from `SuccRelation.lean`): in any MCS, `ψ ∨ (φ ∧ (φ U ψ)) ∈ M → (φ U ψ) ∈ M`. If we have (φ U ψ) ∈ chain(n+1) and φ ∈ chain(n), can we get (φ U ψ) ∈ chain(n)?

We'd need G((φ U ψ)) ∈ chain(n) or some other connection. This is NOT available from the basic chain structure. The backward Until coherence for the current chain is NOT provable without chain modifications.

The forward Until coherence is even harder: given (φ U ψ) ∈ chain(t), produce a witness. This requires eventuality resolution, which for generic ψ is blocked by the same Lindenbaum problem as forward_F.

**Key insight**: For restricted_fuc (forward Until/Since coherence scoped to subformulaClosure(root)), the proof structure mirrors forward_F. If ψ ∈ subformulaClosure(root) and ψ has bounded nesting, then the deferral approach works for Until too.

---

## Recommended Approach

### Primary Recommendation: Modify Chain + Prove Restricted Directly

**Step 1: Prove F(⊤) is a theorem and hence in every MCS**

```lean
theorem F_top_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future Formula.top ∈ M :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.temp_seriality_future)
-- or whatever the name of the DF axiom is
```

**Step 2: Build a restricted deferral successor**

For the purpose of proving `restricted_temporally_coherent root`, define a SEPARATE successor function that uses deferral semantics:

```lean
/-- Restricted deferral seed for root: uses deferral disjunctions scoped to deferralClosure root -/
def restricted_deferral_seed (root : Formula) (M : Set Formula) : Set Formula :=
  g_content M ∪ {deferralDisjunction ψ | ψ ∈ deferralClosure root ∧ Formula.some_future ψ ∈ M}
```

This is a subset of `successor_deferral_seed M` (which uses ALL F-formulas), so it is consistent whenever M is an MCS (since the larger seed is consistent via `successor_deferral_seed_consistent`).

Wait — `successor_deferral_seed_consistent` requires F(⊤) ∈ u. But we just established F(⊤) ∈ every MCS. So this condition is always satisfied.

**Step 3: Build a new restricted_fwd_chain parameterized by root**

```lean
noncomputable def restricted_fwd_succ (root : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (ψ : Formula) : Set Formula :=
  -- Use restricted_deferral_seed as the base, resolving ψ when F(ψ) ∈ M
  (set_lindenbaum (restricted_deferral_seed root M ∪
    if Formula.some_future ψ ∈ M then {ψ} else ∅) ...).choose
```

**Step 4: Prove bounded witness for this new chain**

Establish that for ψ ∈ deferralClosure(root), F(ψ) ∈ restricted_fwd_chain(root, M₀, t) implies ∃ s > t, ψ ∈ restricted_fwd_chain(root, M₀, s).

The proof uses:
1. By `schedule_surjective_above`: ∃ n ≥ t with schedule n = ψ
2. At step n: either F(ψ) ∈ chain(n) (still present, use `restricted_fwd_succ_resolves`) or F(ψ) ∉ chain(n) (deferred out somehow — this needs more careful analysis)

Actually the deferral seed argument works differently. The key is the **deferral disjunction** `ψ ∨ F(ψ)` in the seed: at each step, either ψ enters the chain (obligation resolved) or F(ψ) enters (obligation deferred). The obligation cannot disappear — it's either resolved or explicitly carried forward.

But there's a subtlety: the schedule only hits ψ at certain steps. Between schedule hits, F(ψ) might be deferred (F(ψ) ∈ chain step+1 via deferral disjunction) or resolved early. The bounded witness theorem from `CanonicalTaskRelation.lean` needs to apply to THIS chain.

**Step 5: The bounded witness argument**

For ψ ∈ deferralClosure(root), let n₀ = closure_F_bound(root). By `iter_F_not_mem_closureWithNeg`: iter_F(n₀, ψ) ∉ closureWithNeg(root).

At each deferral step: F(ψ) ∈ chain(t) → either ψ ∈ chain(t+1) (resolved) or F(ψ) ∈ chain(t+1) (deferred). If always deferred:
- After k steps: iter_F(k, ψ) ∈ chain(t + k - 1) via the deferral argument
- For k = n₀: iter_F(n₀, ψ) ∈ chain(t + n₀ - 1)

But iter_F(n₀, ψ) ∉ closureWithNeg(root) ⊇ deferralClosure(root), so the deferral disjunction `iter_F(n₀, ψ) ∨ F(iter_F(n₀, ψ))` is NOT in the restricted deferral seed for root. This means the obligation cannot be deferred further — it MUST be resolved.

This is the bounded witness argument: the F-nesting depth of ψ within deferralClosure(root) is bounded, so infinite deferral is impossible.

### Alternative Recommendation: Use Existing `bx_until_eventuality_resolution`

An alternative for the `restricted_forward_until_since_coherent` sorry is to use `bx_until_eventuality_resolution` from `Frame.lean`. This function already exists and is sorry-free:

```lean
bx_until_eventuality_resolution (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas
```

This gives a BXPoint witness v with bx_le w v and ψ ∈ v. But `bx_le` is the BX canonical accessibility relation, not the int_chain relation. This witness is not necessarily a specific Int-indexed chain point. So this function would need to be adapted — the witness v would need to be embedded into the int_chain at some time point.

However, this might be exactly what `bx_bfmcs_restricted_fuc` needs: given (φ U ψ) ∈ fam.mcs t = int_chain(N, t-s), we need ∃ r ≥ t with ψ ∈ fam.mcs r and guard. The BXPoint route gives a semantic-level witness but not a chain-level witness with the full guard condition.

---

## Confidence Level

| Question | Confidence | Evidence |
|----------|------------|---------|
| Unrestricted forward_F is unprovable | HIGH | Counterexample pattern well-documented in 4 prior research rounds |
| Restricted coherence IS provable | HIGH | `restricted_temporally_coherent` + deferralClosure finiteness + bounded_witness theorem exists |
| F(⊤) is in every MCS | HIGH | DF seriality axiom is part of BX; theorems are in every MCS |
| Deferral seed requires F(⊤) ∈ u | HIGH | Documented in SuccExistence.lean header |
| Route A (modify chain) is the primary path | MEDIUM-HIGH | Prior research reports 02-04 all converge here; implementation cost ~200 lines |
| `bx_bfmcs_restricted_tc` can bypass unrestricted sorries | HIGH | Current code ignores `_h_dc`; trivially rewritable to use it |
| Until/Since coherence is provable | MEDIUM | Backward direction likely provable with step transfer; forward harder |
| `bx_until_eventuality_resolution` can close forward_fuc | MEDIUM | It provides a witness but at BXPoint level, not chain level; bridging needed |

---

## Summary of Key Insights

1. **The unrestricted sorries (lines 493–503) are NOT needed** on the active proof path to `bx_completeness`. The `bx_countermodel` theorem uses only restricted coherence. The unrestricted sorries are dead code on the active path.

2. **`bx_bfmcs_restricted_tc` currently delegates to dead-code sorries** by ignoring the `_h_dc` (deferralClosure) hypothesis. This is the immediate fix target.

3. **The fix requires a separate restricted chain construction** using deferral seeds, OR a proof that the existing chain preserves F-obligations for formulas in deferralClosure(root) (which appears false for the current chain design).

4. **Route A** (new restricted deferral chain + bounded witness) is the mathematically sound path. Expected new code: 150–200 lines of core definitions and proofs.

5. **F(⊤) is a theorem**, so `successor_deferral_seed_consistent` applies to every MCS without additional preconditions.

6. **The Until/Since sorries** (lines 586–627) are independent blockers requiring different techniques (step transfer for backward, eventuality resolution for forward). They do not automatically follow from solving the temporal coherence sorries.

---

## Immediate Next Steps

1. **Verify the DF axiom name**: Check what `Axiom.temp_seriality_future` or equivalent is called in the ProofSystem.
2. **Verify `restricted_temporally_coherent` API**: Confirm `fully_restricted_parametric_representation_from_neg_membership` in `RestrictedParametricTruthLemma.lean` accepts `restricted_temporally_coherent` (not just `temporally_coherent`). Current code at line 652 calls this.
3. **Design the new restricted chain construction**: Either a new `restricted_int_chain` parameterized by `root`, or a proof that the existing chain has the deferral property within `deferralClosure(root)`.
4. **Decide on Until/Since strategy**: Investigate whether `backward_until_from_step` can be used with the existing chain's structure by finding the right step transfer property.
