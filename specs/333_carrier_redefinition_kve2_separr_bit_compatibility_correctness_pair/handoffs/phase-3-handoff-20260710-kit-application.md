# Task 333 — Phase 3 Handoff (kit application COMPLETED)

- **Dispatch**: sess_1783679696_817168, lean-implementation-hard-agent, phase_number=3
- **Date**: 2026-07-10
- **Status**: Phase 3 [COMPLETED] — green + axiom-clean, committed

## Immediate Next Action

Dispatch Phase 4 (`kvE2_outer_fold`, THE make-or-break): reassemble
`∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations now delivered by
`kvE2_sepBody_kit_sound` (file tail of `SharedWitness.lean`) + `ExistProviders.correct` +
the navigated sub-chain (`NavigatedSpine.lean:445`, consume-only). Honor the binding escape
hatch: if the fold has no viable route, STOP, capture `lean_goal`, `/spawn` — never fabricate.

## Current State

- Phases 1, 2, 3 of 4 [COMPLETED]. Build green
  (`lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`,
  1013 jobs, pre-existing warnings only).
- Commits this dispatch: `0e156a7a8` (phase 3.1, left-class applier), `163d6b700`
  (phase 3.2, right-class mirror + aggregate).
- Three new theorems at the tail of `SharedWitness.lean`, all
  `lean_verify` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`:
  - `kvE2_sepBundleL_sound` — left bundle + `w < t` + explicit `hgate` (verbatim left-closer
    shape) → `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`. Pure composition:
    `kvE2_sepBundleL_parts` → `kvE_subBracket2V_sound_of_parts` (5-tuple unifies with no
    coercion at `charBase = nf_depth0_char_formula atomMap h_surj`).
  - `kvE2_sepBundleR_sound` — the plan-anticipated kit-application lemma for the MEDIUM-risk
    right-interior residual. Direct feed into the landed closer REFUTED by signature reads
    (see plan Phase 3 task 3 annotation): `hgate` concludes `a < w` (SubBracket2V:1305) vs
    bundle's `w < x1`; `_parts` drops the below-clause; bundle witnesses live in
    `kvE2_sep_zWX1`, not `kvE_sub2_zXU`. Mirror proved against `nf_eval_depth1_fold_iff`
    (CarrierKv:466); gate-backward exempts `kvE2_sep_zWX1`. The left closer's
    `a < w ∧ w < t` head conjuncts are intentionally NOT mirrored (right geometry carries
    `w < a`, `a < t` as gate antecedents; `x < w` is the lemma hypothesis).
  - `kvE2_sepBody_kit_sound` — aggregate: realized `kvE2_sepBody` + per-class gate families
    (quantified over the extracted pivot `w`) → `EpL ∧ EpR ∧ ∃ w, x<w ∧ w<t ∧ ptW ∧
    (∀ σ left-class, ∃ x1, nf_eval) ∧ (∀ σ right-class, ∃ x1, nf_eval)` — the exact
    Phase 4 input shape.

## Key Decisions

1. **Right class via mirrored closer in SharedWitness** (the plan's own mitigation), not by
   filter weakening, not by assuming `hgate`, not by editing SubBracket2V. `hgate` stays an
   explicit threaded hypothesis (Amendment F3) in all three lemmas; its assembly is Phase 4 /
   task 335 territory (carrier-derivable pieces live in the Phase 9 (O4) section, SW:6528ff).
2. **Right gate shape is 4-conjunct** (nf_eval σ.1, off-fiber, forward, backward-except-zWX1)
   — leaner than the left 6-conjunct gate because the order facts are antecedents in right
   geometry. Phase 4's gate provider must supply BOTH shapes.
3. **All bits self-owned**: every `σ.2 (nf0_assemble … χ σ.1) = true` in the new code is an
   antecedent of that same σ's implication (hbelow / gate clauses) — never a goal (task-321
   R3 trap avoided).

## Verification Record

- `sorry_count` (territory file, census script): **0**; live-sorry grep: 0 (3 prose hits,
  pre-existing).
- LITMUS: **0 live hits; zero-delta vs pre-session baseline** even counting prose.
- Vacuous defs: 0. New axioms: 0. `md:NN` citations added: 0.
- Diff scope: Lean diff touches ONLY `SharedWitness.lean`; carrier structure and all
  do-not-edit assets byte-identical.

## Sorry Inventory

(empty — no sorries anywhere on the territory file)

## References

- Plan: `plans/06_route-a-grouped-extraction.md` (Phase 3 marked [COMPLETED] with per-task
  annotations; Phase 4 section is the authority for the next dispatch)
- Consume-only kit: `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1290),
  `kvE_subBracket2V_sound_of_outer` (SubBracket2V:1481, the composition pattern mirrored)
