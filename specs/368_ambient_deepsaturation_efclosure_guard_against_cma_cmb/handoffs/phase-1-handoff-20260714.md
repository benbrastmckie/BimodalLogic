# Task 368 — Phase 1 Handoff (2026-07-14, sess_1784066335_7eec2d)

## Immediate Next Action

Dispatch **Phase 2** (candidate ambient EF-closure guard design + exclusion gates, probe-only):
define `kvE_ambientDeepAnchorV0 (qnf : NormalForm sig (k+2) n) : Bool` in the SAME leaf
`ExteriorAmbientDeepAnchorProbe358K.lean` — no production file. Gates 2a/2b
(`kvE_probe368_cmA_ambient_rejected`, `kvE_probe368_cmB_ambient_rejected`) + 2c (`_zero`,
ideally `rfl`).

## Current State

- Phase 1 **[COMPLETED]**; phases 2-6 [NOT STARTED]. Baseline SHA `9f4f6302b78ae...`.
- New leaf `Theories/.../NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean`
  compiles green (scoped build, 1025 jobs); purely additive (`git diff --stat -- Theories/`
  empty).
- Gate 1a `kvE_probe368_cmA_row13_refuted` and Gate 1b `kvE_probe368_cmB_row5_refuted`:
  sorry-free, axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- Baseline spot-checks green at floor axioms: `kvE_probe367_tailDG_deep_rejected`,
  `kvE_probe367_real_slice_deep_anchored`, `kvE_probe358_tailDG_gapItem_pinned_fails`,
  `kvE_probe363_tau_admissible`.
- Sorry count 0; vacuous-def scan 0; new-axiom scan 0; guard-unfold scan 0.
- NO guard definition exists (`ExteriorAmbientDeepAnchorK.lean` intentionally absent).

## Key Decisions (Phase 1)

1. **CM-A cast at m = 1** over `(ℤ,<)`, `R = ∅`, anchors `[w,x,t] = [1,0,2]`:
   `qnfA := NormalForm.step (honest row) (marking = decide-disjunction over exactly
   {cA(-1), cA 0, cA 1, cA 2, cA 3})`, `sigmaA := cA 4 = char[t+2,w,x,t]`. The separator is
   the gap-point fiber `gapA := char[3; 4,1,0,2]`: `sigmaA.2 gapA = true` (witness 3) while
   `cA_gap_false : ∀ v ≤ 3, (cA v).2 gapA = false` (rows pin `2 < r < v ≤ 3`, empty in ℤ).
   Bit-false and guard-false both reduce to this ONE lemma (guard-false through
   `kvE_deepOnFiber_iff`, never unfolding). On-row via `nf_eval_nf0_cons_factor` +
   `nf_eval_unique` (the `_of_realized` row argument replayed) — NOT a funext block.
2. **CM-B cast** over `(ℤ,<)`, `R = {10}`: `qnfB := honest marking || plant subG` where
   `subG := char over [12,12,8,25]` (AtW-pinned over the 358TailK fake tail).
   Unrealizability via the marked R-point fiber `sG10 := char[10; 12,12,8,25]` — pred row
   pins the witness to 10, (fresh,w-slot) row demands `u < 5`. On-row via the VERBATIM
   358TailK funext block (same dropped tail (12,8,25) vs (5,2,30)).
3. **Lean gotchas solved** (reuse in later phases):
   - Inline `hr.1 (.order 0 ⟨1, by omega⟩ (by decide))` inside `.mpr` chains fails
     (postponed mvars poison unification). Use two-step `have hord := hr.1 (...)` then
     `have h : _ := hord.mpr (...)`, with `by decide` Fin proofs.
   - `omega` cannot see `<` at `MA.carrier` (structure-projection LT instance). Either
     ascribe `@LT.lt ℤ _ a b` in the `have`, put a ℤ literal FIRST (`(2:ℤ) < r`), or use
     the 367 manual `rw [hu10] at hlt; exact h105 hlt` ending.
4. Deviation (minor, annotated in plan): leaf imports add `ExteriorFiberConsistencyK`
   (read-only, for `kvE_fiberConsistent_of_realized`) beyond the 367-mirror import list.

## Sorry Inventory

`[]` (empty — no sorries introduced; KampPrior `:519`/`:522` are pre-existing task-358
territory, untouched and out of scope).

## References

- Plan: `specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/plans/01_ambient-deep-anchor-guard.md` (Phase 2 section)
- Countermodel source: `specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/06_deep-anchor-rekey-v06.md` Phase-4 BLOCKER record
- Consumption-site map: module docstring of the new leaf (authoritative Phase-5 edit boundary)
