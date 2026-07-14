# Phase 14c Summary — (E4) past carrier `CExtPast(_correct)` + ∃w pin glue + 3-bot falsity

**Task**: 350 | **Session**: `sess_1784009176_e5245f` | **Dispatch**: single-phase (14c), hard mode
**Plan**: `plans/03_negfix-refactor-exterior-carriers.md` (v3), Phase 14c now [COMPLETED]

## Phases Executed

Phase 14c only (per `phase_number` contract; Phase 15 not started).

## Delivered (all in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`, +118 lines, no new imports)

| Name | Kind | Content |
|---|---|---|
| `navDGate` | def (Prop) | the three pure σ-side conjuncts of `navDistribLeft`: `navDOrderRow` ∧ inconsistent-zone falsity ∧ off-fiber honesty |
| `CExtPast` | noncomputable def (VVecEA2) | per-qnf past-exterior carrier: on-gate one `VecEA2` per arrangement `L ∈ (navDXTBitTrueList σ).permutations` with shared endpoints (`endpointLeft = ⟨(navPackLeft σ).formula.and (navDAtXPack σ)⟩`, `endpointRight = ⟨navDAtTPack σ⟩`, `bracket = navDXTBracket σ L`); off-gate `⟨[]⟩`. Gate via `@dite _ (navDGate σ) (Classical.dec _)` (agg2Past pattern) |
| `CExtPast_correct` | theorem | under ambient `x < t`: `(CExtPast σ).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ` — the ∃w glue across the pin at x (Rabinovich Lemma 7.6 closure) |
| `navD_inconsistent_eval_false` | theorem | eval-side 3-bot falsity: ¬`navDOrderRow σ` → no `w < x < t` realizes σ |
| `CExtPast_offGate_false` | theorem | carrier-side falsity off-gate, at EVERY pin pair (no ambient hypothesis) |
| `CExtPast_inconsistent_false` | theorem | order-row specialization of the above |

## Proof Architecture

`CExtPast_correct` is pure plumbing against the Phase-14b distribution, exactly as the 14b
handoff designed: `rw [navDistribLeft]` converts the ∃w side to the seven-conjunct RHS; the
dite `split` then gives (on-gate) the collapse of `∃ vea ∈ map …` to
`epL@x ∧ epR@t ∧ (∃ L ∈ perms, bracket L holds)` — the shared endpoints split by one
`temporal_truth_and` — and (off-gate) False ↔ False since the RHS contains the three gate
conjuncts verbatim. No re-peeling; no nonemptiness argument needed (the arrangement ∃L appears
on both sides).

## Final Verification

- Scoped build: 1035 jobs green. Full `lake build`: 1749 jobs green.
- `lean_verify` on `CExtPast_correct`, `navD_inconsistent_eval_false`,
  `CExtPast_inconsistent_false`: exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- Sorry census (`lean-sorry-census.sh` over `NfMultiAnchorBridge/`, `--cross-check`):
  stripper 0; compiler 30 project-wide, all pre-existing outside territory (14b baseline).
- Vacuous defs: 0 new (1 pre-existing grep false positive in `Examples/TemporalStructures.lean`).
- Axioms: 0 declarations (grep hits are Boneyard prose). Guards honored: no frozen-file /
  KampPrior / task-358 edits; `nf_char3_deeper_split` not referenced.

## Sorry Inventory

Empty.

## Plan Deviations

None — all three checklist items landed as specified. One toolchain note recorded for
successors (Lean 4.27: `List.not_mem_nil` now takes the membership proof directly).

## Handoff

`handoffs/phase-14c-handoff-20260714.md` (Phase-15 mirror recipe + delivered-names table).
