# Task 358 Phase 8 Handoff — G1 independence probe verdict (2026-07-13)

Session: sess_1783988294_843145 (hard-mode per-phase dispatch, phase_number=8)

## Immediate Next Action

Orchestrator: fold Phase 8 into the interface-restatement spawn already recommended by the
Phase-6 NO-GO. The spawn's scope MUST cover BOTH legs:
- exterior rows 8-11 (Phase 7): slice-equality keying admits doppelgänger-tail fakes at m ≥ 1
  (`kvE_probeM1_sliceId_NOGO`);
- interior rows 5-6 (Phase 8): the `igFoldBit` arity-1 projection channel (F1) admits the
  SAME fake one level up (`kvE_probeM1_interiorHreal_NOGO`,
  `kvE_probeM1_interiorGuard_identical`).

Repair class (both legs): rungK obligation binders / `igFoldBit` consumer seam must render
fiber marking at depth ≥ 1 PINNED (anchored item rendering or a depth-graded fiber guard),
then re-probe. Do NOT dispatch Phase 9 (depends on 5, 7, 8 — all blocked); Phase 10 is
serialized after 9.

## Current State

- Phase 8: **[BLOCKED]** — NO-GO, shared root cause with Phase 6/7. Verdict + structured
  blocker recorded in plans/03 Phase-8 section.
- Probe landed: 2 public theorems + 8 private lemmas appended to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean`
  (purely additive; zero production edits; reuses the Phase-6 countermodel cast).
- Build: full-tree `lake build` GREEN (1739 jobs).
- Axiom closure of both head theorems: exactly `[propext, Classical.choice, Quot.sound]`
  (lean_verify), no sorryAx.
- No new sorry introduced; no vacuous defs; no new axioms.
- Phase statuses: 1,2,3,6 COMPLETED; 5 partially closed (k=0 arm only); 4,7,8 BLOCKED
  (all three on the same 350/interface primitives + restatement); 9,10 NOT STARTED.

## Key Decisions

1. **Probe-first, no build-out** (dispatch mandate): established the shared root cause with
   a ~180-line additive probe instead of attempting the G1 supply — zero churn on
   KampPrior.lean.
2. **Probe design**: fold-bit invisibility. Rows 5-6 read the qnf only through `qnf.1` +
   `igFoldBit qnf`; `igFoldBit` reads fibers only through `(zone, nfk_projFresh)`. Proved
   `igFoldBit (m1qnf ⊕ (τ ⊕ s*)) = igFoldBit m1qnf` via `nfk_projFresh (τ ⊕ s*) =
   nfk_projFresh τ` (take-level: `nfk_take (2≤5) s* = nfk_take (2≤5) s°`, both realized at
   the shared prefix `[22, 25]`, identified by `nf_eval_unique`). Conclusion failure:
   `∀ x1, ¬ nf_eval_nf M1M 2 4 [x1,15,2,18] (τ ⊕ s*)` from `m1_sstar_not_pinned`.
   This is STRONGER than the Phase-6 semantic-facts form: the fake and honest hypothesis
   sides are literally EQUAL for every rendering, so no provider instantiation question
   remains open.
3. **Lean technicality** (for future probe work in this file): `decide_eq_decide.mpr` as a
   term against goals containing `nfk_take`-unfolded pair projections hits
   maxRecDepth-resistant unification blowup; the working pattern is
   `refine Prod.ext rfl (funext fun χ' => ?_); rw [decide_eq_decide]; exact <iff>` with the
   iff proved as a standalone decide-free lemma.
4. `k = 0` layers untouched and unrefuted (C8(c) upgrade pins depth-0 fibers): rung0/rung1,
   the m=0 supply theorems, and `kampPrior_case1_arm_k0` all remain valid consumption
   targets after the restatement.

## Sorry Inventory

Unchanged from dispatch start (nothing added, nothing resolved):

| file | line | statement | strategic | why deferred | follow-up |
|---|---|---|---|---|---|
| Theories/.../Kamp/KampPrior.lean | 361 | `nf_nvar_exist_all_depths`, `\| 1 =>` arm | yes | Phases 4-8 blocked on 350 primitives + interface restatement | task 358 Phase 9 after restatement spawn |
| Theories/.../Kamp/KampPrior.lean | 364 | `nf_nvar_exist_all_depths`, `\| n+2 =>` arm | yes | serialized strictly after :361 (G4) | task 358 Phase 10 |

Off-path quarantined (plan Non-Goals, not in scope): EANegation.lean:1090/:1249,
NfDepth0Generalized.lean:751; Boneyard legacy sorries.

## References

- Plan: specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/03_post-360-gap-closure.md
  (Phase 8 VERDICT + BLOCKER section is authoritative)
- Probe evidence: ExteriorPinnedProbeM1K.lean, section "Task 358 Phase 8 probe"
- Phase-6 companion verdict: same file, `kvE_probeM1_sliceId_NOGO`
