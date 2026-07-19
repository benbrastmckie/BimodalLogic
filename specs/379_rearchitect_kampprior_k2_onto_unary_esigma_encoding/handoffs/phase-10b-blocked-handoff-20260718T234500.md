# Phase 10b Handoff — BLOCKED on arity-2 → arity-r lift (encoding gap)

**Dispatch:** lean-implementation-hard-agent, single-phase focus (Phase 10b, hard mode).
**Status:** Phase 10b **[BLOCKED]**. Two precursor lemmas landed green + axiom-clean; the final
`efSat_negation_general` is not stated (stating it with a hole would require `sorry`, prohibited).
Phase 10 is NOT complete — Phase 11+ must not advance until 10b closes.

## What landed this dispatch (green, sorry-free, axiom-clean)

New file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (orphan, off the live
import path — nothing imports it). Both lemmas verify `[propext, Classical.choice, Quot.sound]`
(no `sorryAx`):

1. **`efSat_negation_pair`** (plan task 2, per-pair half) — composes the arbitrary-pin engine
   `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean`, `VVecEA2`-valued) with the landed
   collapse bridge `vvecea2_collapse_bridge` (`VVecEA2Collapse.lean`, 10a). For any
   `ξ : ExistsForallFormula sig F 2`:
   `∃ Φ : VeeExistsForall sig F 2, ∀ env, env 0 < env 1 → (veeSat N env Φ ↔ ¬ efSat N env ξ)`.
   Signature threads `atomMap / h_surj / h_INF / h_SUP / hCapture`. Trivial three-line composition
   (`(hΦ env henv).trans (hv' env henv)`).
2. **`efSat_negation_demorgan`** (plan task 1) — De Morgan of `augTarget_iff`:
   `¬ efSat N env ψ ↔ (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2) ∨
   ¬ efSat N ![] (existenceSentence ψ)`. Pure classical propositional (`push_neg` over the list-∀);
   no capture hypothesis, no arity lift.

## The blocker (verified, precise) — arity-2 → arity-r lift is an unplanned encoding gap

**Not** a plumbing defect and **not** `hCapture`-related. Root cause is the `ExistsForallFormula`
encoding vs. Rabinovich's logic:

- The final target is `∃ Φ : VeeExistsForall sig F r, ∀ env, StrictMono env →
  (¬ efSat N env ψ ↔ veeSat N env Φ)`. `veeSat_append` flattens only same-arity `r` disjuncts, so
  every per-pair disjunct (arity 2, from `efSat_negation_pair`) and the existence disjunct (arity 0)
  must be lifted to `VeeExistsForall sig F r`. No `liftPair`/dummy-variable lemma exists.
- **Rabinovich (PDF p.6, Prop 4.3 ¬-case):** "by Lemma 3.2(2) φ ≡ conjunction of ∃∀-formulas *with
  at most two free variables*; hence ¬φ ≡ disjunction of ¬ψ_i; by Prop 4.2 each ¬ψ_i ≡ disjunction
  of ∃∀-formulas." His ψ_i are ≤2-free-variable formulas over z₀…z_m — non-occurring variables are
  simply absent.
- **Lean:** `ExistsForallFormula sig F r` has a **total** `pin : Fin r → Fin (n+1)` — every free
  variable is pinned to an existential point, so a dummy variable becomes a real constraint
  `env k' = x (pin k')`. Verified for the engine's endpoint-pinned negation object `ξ`
  (`env k = x 0`, `env l = x last`, negation content on the interior, `intervalTop` trivial caps):
  variables `k' < k`, `k' > l` fall in trivial caps (fine); a variable `k < k' < l` is forced by
  `StrictMono` into `ξ`'s non-trivial interior. A trivial inserted point gives forward but not
  reverse; assigning the interior interval type as the point's type would fix reverse but `ξ`'s
  interior points are existentially chosen (which sub-interval `env k'` lands in is not static). The
  final iff needs forward (soundness) AND reverse (completeness) on the same lift — genuinely stuck.

## What is needed to unblock (needs planner/design input)

1. **Encoding primitive:** a partial-pin `ExistsForallFormula` (pin on a subset of `Fin r`) + a lift
   lemma; OR
2. **Completion-expansion `liftPair` sub-phase (~several hundred lines):** for pair `(k,l)`, disjoin
   over interleavings of `{k' : k < k' < l}` with `ξ`'s interior points and all `IntervalType`
   completions (in the `collapseEF` style), with its own correctness proof; OR
3. **Restate the target** so per-pair negations need not become total-pin arity-r objects.

Recommend `/revise` on plan 11 to insert a `liftPair` sub-phase (option 2) or an encoding change
(option 1) between the landed precursors and the `efSat_negation_general` assembly.

## Verification at handoff

- Full `lake build` **EXIT 0 at 1770 jobs** (baseline).
- `completeness_discrete` axioms **byte-identical to baseline**:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (sole `sorryAx` = pre-existing `KampPrior.lean:562`, Phase 13; untouched).
- `efSat_negation_pair`, `efSat_negation_demorgan` = `[propext, Classical.choice, Quot.sound]`.
- No new `sorry`, no vacuous defs, no new axioms. `EFSatNegation.lean` is an orphan (grep-audited).

## Reuse anchors (verified this dispatch)

- `efSat_negation_pair`, `efSat_negation_demorgan` (`EFSatNegation.lean`) — consume in the resuming
  dispatch; do NOT re-prove.
- `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean:989`); `vvecea2_collapse_bridge`
  (`VVecEA2Collapse.lean`); `augTarget_iff` / `pairwiseProjections` / `pairProject` / `conjSat` /
  `existenceSentence` / `augConjSat` (`ExistsForallLemmas.lean`); `veeSat` / `veeSat_append`
  (`VeeExistsForall.lean:72`).
- Positive backward gluing (the dual to build against): `loPos` / `hiPos` / `chainOf` /
  `augTarget_backward` (`ExistsForallLemmas.lean:411-703`).
- Faithfulness: Rabinovich 2014 Prop 4.3 ¬-case (PDF p.6), Lemma 3.2(2) (p.4), Def 3.3/Lemma 3.4
  (p.4-5). Companion `.md` corrupt — cite PDF page.
