# Teammate C (Critic) Findings — Task 93 Round 11

**Focus**: Find what could go wrong with the proposed approach (deferralClosure extension + BX12 reduction + BFMCS from quasimodel chains).

---

## Key Findings

### Finding 1: The 6-Sorry Count Is Confirmed, But the Active Path Is 4 Sorries

Actual sorry locations in `CanonicalModel.lean`:
- Line 497: `bx_fmcs_forward_F` — sorry
- Line 503: `bx_fmcs_backward_P` — sorry
- Line 586: `bx_bfmcs_buc` (unrestricted backward Until/Since) — sorry
- Line 591: `bx_bfmcs_fuc` (unrestricted forward Until/Since) — sorry
- Line 621: `bx_bfmcs_restricted_buc` — sorry (ACTIVE PATH)
- Line 627: `bx_bfmcs_restricted_fuc` — sorry (ACTIVE PATH)

The active path consumed by `bx_countermodel` (line 635) calls:
- `bx_bfmcs_restricted_tc` (line 603) — already proved (no sorry!)
- `bx_bfmcs_restricted_buc` (line 617) — sorry at line 621
- `bx_bfmcs_restricted_fuc` (line 623) — sorry at line 627

Wait — re-reading the restricted_tc proof: it calls `bx_fmcs_forward_F` (line 610) and `bx_fmcs_backward_P` (line 614), which are BOTH sorry'd. So `bx_bfmcs_restricted_tc` is NOT actually proved — it just delegates to the two core sorries at lines 497 and 503. The active path has 4 sorries, not 2.

**Critical**: `bx_bfmcs_restricted_tc` at line 603 compiles without a top-level `sorry` keyword but is structurally sorry-dependent. Closing just lines 621 and 627 is insufficient.

### Finding 2: forward_F Sorry Is the True Root Cause — Not Bypassed by BX12

The proposed plan states "Use BX12 axiom `F(φ) → (⊤ U φ)` to reduce forward_F to forward_Until." The plan's own risk table (line 66) identifies: "`(⊤ U φ)` not in `subformulaClosure(root)` when `F(φ)` is, blocking BX12 reduction."

Examining the data flow:
1. `bx_bfmcs_restricted_tc` needs `∃ s, t < s ∧ ψ ∈ fam.mcs s` given `F(ψ) ∈ fam.mcs t` and `ψ ∈ deferralClosure(root)`.
2. `bx_fmcs_forward_F` at line 493 is the direct implementation — it is sorry'd.
3. The int_chain builds a scheduling chain via `fwd_succ`/`bwd_pred`, where `fwd_succ` resolves exactly one formula per step (via `schedule n`).
4. For `F(ψ) ∈ int_chain(M₀, t)`, the chain will eventually reach step `n` where `schedule n = ψ`. At that step, `fwd_succ` (line 74-80) checks `if Formula.some_future ψ ∈ M` and resolves. **But the F-formula must still be in the chain at step n**, not just at step 0.

The fundamental gap: F-formulas are NOT guaranteed to persist through resolving steps for OTHER formulas. The `fwd_succ` non-resolving branch (line 79-80) includes `f_carry(M)` (all F-formulas currently in M), but when resolving ψ' ≠ ψ, the new successor MCS might lose `F(ψ)` if the Lindenbaum extension chose not to include it. There is no axiom that forces `F(ψ)` to persist into a successor that resolves a different formula.

BX12 reduction to `(⊤ U ψ)` has the same persistence problem: `(⊤ U ψ) ∈ chain(t)` must persist through intermediate chain steps until the scheduling step resolves ψ. The Until formula is not guaranteed to persist without Until-carry infrastructure.

### Finding 3: forward_Until Is Also Sorry'd

`bx_bfmcs_restricted_fuc` at line 623 is sorry'd — this is the forward Until/Since coherence on the BFMCS. The plan claims BX12 reduces forward_F to forward_Until, but forward_Until itself needs to be proved. These are not two different names for the same sorry; they are distinct goals:

- `forward_F`: Given `F(ψ) ∈ fam.mcs t`, find `s > t` with `ψ ∈ fam.mcs s`
- `forward_Until`: Given `(φ U ψ) ∈ fam.mcs t`, find `s ≥ t` with `ψ ∈ fam.mcs s` and `φ ∈ fam.mcs r` for all `t ≤ r < s`

The BX12 reduction proposes: `F(ψ) → (⊤ U ψ)`, so from `(⊤ U ψ) ∈ fam.mcs t`, apply forward_Until to get a witness `s ≥ t` with `ψ ∈ fam.mcs s`. But forward_Until requires the GUARD condition: `⊤ ∈ fam.mcs r` for all intermediate `r`. The guard `⊤ ∈ MCS` is trivially true (⊤ is a theorem), so this part works. However, forward_Until gives `s ≥ t` (non-strict), but forward_F requires `s > t` (strict). The semantics of `F(ψ)` is strict future (`∃ s > t`). The Until semantics is reflexive (`∃ s ≥ t`). When `ψ ∈ fam.mcs t` already (the `s = t` case of Until), forward_F cannot use this as its witness.

**The strict/non-strict gap is real and unresolved.** When `ψ ∈ fam.mcs t`, then `(⊤ U ψ) ∈ fam.mcs t` (by BX8: `ψ → φ U ψ`), and forward_Until produces `s = t`, but this does NOT satisfy forward_F's requirement `s > t`.

### Finding 4: The Proposed deferralClosure Extension Would Break the max_F_depth Theorem

If we extend `deferralClosure` to include `(⊤ U φ)` for each `F(φ)`, the finiteness bounds in `SubformulaClosure.lean` break. Specifically:

- `max_F_depth_deferralClosure_eq` (line 1062) proves that the max F-nesting depth in `deferralClosure` equals the max in `closureWithNeg` (or 1 for F_top). This theorem is used by `iter_F_not_mem_deferralClosure` and `iter_P_not_mem_deferralClosure` in `RestrictedMCS.lean` to prove termination of the chain construction.
- The Until formula `(⊤ U φ)` has no F-nesting depth issue (U is not F), so the depth theorem would not break directly.
- However, `RestrictedMCS.lean` uses `deferralClosure` for the MCS restriction domain. Every formula added to `deferralClosure` enlarges the candidate set for MCS construction. The `DeferralRestrictedMCS` construction depends on `deferralClosure` being a specific, well-characterized set.

More concretely: `some_past_in_deferralClosure_cases` (around line 944) pattern-matches on whether `P(psi)` is in the closure and reasons about what P-formulas can appear. Adding Until formulas changes this reasoning. Any lemma that case-splits on membership in `deferralClosure` may need updating.

**The plan proposes NOT extending `deferralClosure`** but instead proving coherence directly via chain scheduling and Until-carry enrichment. But if Until formulas are not in `deferralClosure`, they cannot be tracked by `DeferralRestrictedMCS`, and the BX12 reduction argument needs them in the closure for the MCS-level reasoning to work.

### Finding 5: The Quasimodel Realization Obstacle at Lines 366-395 Is Not Avoided

The plan mentions "Build BFMCS from quasimodel chains instead of the scheduling chain." The Realization.lean comments at lines 366-395 identify two obstacles:

1. **Obstacle 1**: `g_content(v_i) ⊆ w_{i+1}.formulas` fails for `G(χ) ∈ v_i` with `G(χ) ∉ Sigma`. The Hintikka chain only propagates G-formulas within Sigma.

2. **Obstacle 2**: G-persistence through the Hintikka chain fails. `G(χ) ∈ h_i` does not guarantee `G(χ) ∈ h_{i+1}`.

The comment at line 394 is explicit: "Chain realization requires either (a) G-persistence in the Sigma-closure (not available for the enriched closure), or (b) a completely different approach."

Approach 5 (BFMCS from quasimodel chains) does NOT avoid these obstacles — it changes the outer construction but still requires realizing quasimodel chains as BXPoint chains, which hits the same G-persistence wall.

### Finding 6: The Since Direction Is Symmetric But Equally Unproved

All analysis focuses on the Until direction. The Since direction has:
- `bx_fmcs_backward_P` (line 499) — sorry (equivalent to forward_F for past)
- Backward Until/Since coherence in `bx_bfmcs_restricted_buc` (line 617) — sorry at line 621

The backward direction has symmetric proofs to the forward direction. `bx_since_eventuality_resolution` in `Frame.lean` (line 650) IS proved (not sorry'd) — it uses `bx_backward_witness` + BX9' + BX10'. But `bx_fmcs_backward_P` is still sorry'd: it needs `P(ψ) ∈ int_chain(M₀, t) → ∃ s < t, ψ ∈ int_chain(M₀, s)`, and the scheduling chain has the same persistence problem in the backward direction. The `bwd_pred` with `p_carry` enrichment parallels `fwd_succ` with `f_carry`, but the parallel sorry remains.

### Finding 7: Task 92 Truth Lemma — Status Check

The plan header claims "tasks 90, 92, 98, 102 already completed." Let me verify for task 92. Looking at `TruthLemma.lean` line 37: "The completeness theorem is stated with sorry for the TaskModel construction." Looking at `Completeness.lean` line 29: "The sorry at the proof site has been replaced with a proof using the BXCanonical..." — this suggests Completeness.lean's sorry was closed.

The truth lemma file (`TruthLemma.lean`) itself has no sorry in its proof content. The `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` functions in `Frame.lean` are proved. So task 92 (truth lemma) appears sorry-free in the sense that the truth lemma for atom, bot, imp, box, G, H is proved. The Until/Since eventuality resolution is proved. However, the truth lemma's correctness depends on `bx_bfmcs_restricted_fuc` and `bx_bfmcs_restricted_buc` (the sorry'd coherence properties), so the full completeness is not sorry-free even if task 92's nominal deliverables are done.

---

## Gaps and Shortcomings in the Proposed Approach

### Gap 1: BX12 Does Not Bridge strict-F to reflexive-Until

The reduction `F(ψ) → (⊤ U ψ)` is valid (BX12), but using it to prove `forward_F` from `forward_Until` is blocked by:
- The `s = t` case where `ψ ∈ fam.mcs t` already: forward_Until correctly returns `s = t`, but forward_F needs `s > t`.
- This is not a minor technicality: it requires either (a) showing `¬(ψ ∈ fam.mcs t)` as a precondition to forward_F (not how it's stated), or (b) showing that `F(ψ) ∈ fam.mcs t` and `ψ ∈ fam.mcs t` leads to contradiction (false: both can hold simultaneously — `F(ψ)` doesn't exclude `ψ ∈ fam.mcs t`), or (c) accepting the `s = t` witness for forward_Until is acceptable by weakening forward_F's requirement.

Actually (c) might work: the `restricted_parametric_shifted_truth_lemma` uses `restricted_temporally_coherent` which at line 210 converts `h_forward_F`'s strict output to non-strict: `exact ⟨s, le_of_lt h_lt, h_s⟩`. So the truth lemma only needs non-strict forward_F output from its perspective. But the sorry'd `bx_fmcs_forward_F` signature at line 493 returns `t < s` (strict). If we could weaken this to `t ≤ s`, the `s = t` case becomes valid but trivial. However, the `all_future` case in the truth lemma at `RestrictedParametricTruthLemma.lean` line 410 uses forward_F to disprove `G(ψ)` membership, which requires a STRICT future witness (otherwise we can't separate `G(ψ)` from `F(ψ)` in the chain at equal times). The strict requirement is mathematically necessary.

### Gap 2: Until-Carry Enrichment Resolving-Branch Consistency Is Unverified

The plan's critical unknown (60% probability, per Plan 08 line 25): proving consistency of `{ψ} ∪ g_content(M) ∪ untilCarry(M, root)`. The concern is BX9 gives `(φ U ψ') → φ ∨ ψ'`. If `ψ' = neg(ψ)` (a Until formula with right operand being the negation of the resolving target), then `{ψ} ∪ {(φ U neg(ψ))} ⊢ φ ∨ neg(ψ)`, but `ψ` is already in the seed, so `neg(ψ)` can be derived inconsistently. The plan proposes excluding such Until formulas from untilCarry, but this exclusion creates a gap: those Until formulas won't persist through the resolving step, potentially breaking backward Until coherence for those formulas.

### Gap 3: BX11 Linearity Argument Is Uncharted Territory

The plan states "A novel BX/BX7 linearity argument is needed" for the resolving-branch consistency. BX11 is `linear_until`, which is the key axiom governing Until interaction. No previous research round has produced this argument — it appears in the plan as a hypothesis, not an established approach. This represents the highest-risk element of the plan.

### Gap 4: Forward_F Is Used in restricted_tc Which Is Already "Proved"

`bx_bfmcs_restricted_tc` at line 603 appears to be proved (no top-level sorry), but it delegates directly to `bx_fmcs_forward_F` at line 610 via `have ⟨s', h_lt, h_ψ⟩ := bx_fmcs_forward_F N h_N (t - s) ψ h_F`. This means `bx_bfmcs_restricted_tc` is axiom-transparent: it would pass `#check` but fail `#print axioms`. The active path therefore has 4 sorry dependencies, not 2.

---

## Risk Assessment

| Risk | Severity | Probability | Evidence |
|------|----------|-------------|----------|
| BX12 strict/non-strict gap blocks forward_F reduction | HIGH | HIGH | Semantic analysis: forward_F requires `s > t`; forward_Until gives `s ≥ t` |
| Until-carry resolving-branch consistency fails | HIGH | MEDIUM | 10 rounds of research; BX9 counterexample pattern identified |
| BX11 linearity argument doesn't exist | HIGH | MEDIUM | No previous research produced this; plan treats it as a "novel" approach |
| G-persistence obstacle in quasimodel approach not avoided | HIGH | HIGH | Realization.lean lines 366-395 explicitly document this as blocking |
| `bx_bfmcs_restricted_tc` is structurally sorry-dependent | HIGH | CERTAIN | Lines 610, 614 directly call the sorry'd forward_F and backward_P |
| The forward_Until sorry (line 627) requires its own proof | HIGH | CERTAIN | forward_Until has a guard condition (all intermediate times); not trivial |
| Since direction requires separate proof infrastructure | MEDIUM | CERTAIN | bx_fmcs_backward_P line 499 is sorry'd; symmetric to forward_F |

---

## Confidence Level

**High** confidence in the following findings:
1. The active path has 4 sorry dependencies (not 2), because `bx_bfmcs_restricted_tc` delegates to the sorry'd `bx_fmcs_forward_F`.
2. The strict/non-strict gap (forward_F needs `s > t`, BX12 + forward_Until gives `s ≥ t` with no strict guarantee) is a genuine semantic obstacle.
3. The quasimodel realization obstacle (G-persistence) at `Realization.lean:366-395` is not avoided by building BFMCS from quasimodel chains — the same obstacle appears in any chain-realization attempt.
4. `until_persists_through_succ` in `SuccRelation.lean:542` is sorry'd and explicitly blocked, which directly bears on Until persistence through scheduling chain steps.

**Medium** confidence in:
5. The BX11 linearity argument not existing — it might be constructible but has not been found across 10 research rounds.
6. The resolving-branch consistency gap (BX9 counterexample) being fatal — the plan's exclusion of problematic Until formulas might be workable.

**Low** confidence in:
7. The deferralClosure extension being necessary — the plan proposes NOT extending it, and this might be correct.

---

## Summary Verdict

The proposed approach faces three independent blocking obstacles:

1. **forward_F strict/non-strict gap**: BX12 reduces `F(ψ)` to `(⊤ U ψ)`, and forward_Until gives a witness `s ≥ t`. But when `ψ ∈ fam.mcs t` (i.e., `s = t`), this witness is invalid for forward_F. The semantic requirement `s > t` is built into the `all_future` truth lemma case. This is not a proof engineering issue; it is a mathematical gap.

2. **forward_Until is also sorry'd**: Closing forward_F via BX12 + forward_Until does not help unless forward_Until itself is proved. forward_Until is the direct sorry at line 627.

3. **G-persistence wall remains**: Any approach that builds BXPoint chains from Hintikka chains hits the G-persistence obstacle at `Realization.lean:366-395`. The quasimodel approach does not bypass this.

The most actionable path would be: directly prove `bx_fmcs_forward_F` using the scheduling chain's surjectivity property (`schedule_surjective_above`) combined with `fwd_succ_resolves`, with Until-carry or f_carry ensuring F-formula persistence through intermediate steps. This is what Plan 08 essentially proposes (via restrictedUntilCarry), but the consistency of the enriched resolving seed remains the critical unverified claim.
