# Task 335 — Fragment Gate (v6) Implementation Summary — Phase D

- **Session**: sess_1783796165_b5b482_335 (Phase D dispatch; hard mode, single-phase focus)
- **Date**: 2026-07-11
- **Plan**: `plans/06_fragment-gate-v6.md` — ALL phases (1/2/3/A/B/C/D) now [COMPLETED]
- **Commit**: `147af2fbe` (task 335 phase D.1)

## Phase D — what landed

All Phase D code is in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` (additive;
`SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged — 341 frozen-file gate + 347 R1 intact).

1. **Provider obligation re-shaped to `kvE2_sepPosI`** (347 MUST-CHECK 2). The landed
   global/unbounded `hreal` of `bracketEndChar_kvE2_sound_two_prior_frag` is SPLIT into:
   - `hrealI` (`OuterGate.lean:288`): indexed by the interior list `kvE2_sepPosI qnf` (SW:211),
     interval-BOUNDED `∃ x1, (x < x1 ∧ x1 < t) ∧ nf_eval_nf …` — Rabinovich Cor 5.4 ⇐
     (p.9 l.263–273). The provider obligation 309 Phase 14 discharges and task 348 consumes.
   - `hrealB` (`OuterGate.lean:299`): the non-interior-marked remainder of `kvE2_sepPos`
     (boundary/at-point positives), landed unbounded fold shape.
   The fold's global channel is reassembled inside the proof by `by_cases` on the decidable
   interiority filter + `kvE2_sepPosI_mem` (plan deviation noted inline: a 10-line derivation,
   not a pure `show`/`change` defeq bridge — the interior index alone cannot feed the fold's
   boundary-positive realizations post-346).

2. **`bracketEndChar_kvE2_correct_two_prior_frag`** (`OuterGate.lean:359`) — the assembled
   interior+boundary k=2 gate: fragment-restricted (`hfrag`) `holds ↔ ∃ w` mirroring
   `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95); ⇒ = Phase B/D sound half,
   ⇐ = Phase 2 completeness (unconditional). The exterior-marked `hexclExt` binder is threaded
   OUTWARD verbatim as the named task-348 (`prop43_exterior_reflatten`) provider hand-off —
   never discharged in-335 (Prop 4.3 re-flatten / Lemma 7.6 adjacency).

3. **Docstrings finalized**: header delivered-items 4/5 → DELIVERED; stale Phase-C GO/NO-GO
   note corrected to the v6 disposition.

4. **Handoff note**: `handoffs/03_frag-gate-for-309-and-348.md` — records the
   `kvE2_sepPosI`-indexed provider obligation and the narrowed exterior `hexclExt` binder
   VERBATIM, the 309 consumption shape (interior+boundary gate + adjacent exterior bracket,
   seam at `x,t`), the deferred `On`/multi-positive case (321-N2), and the ∀k-lift composition
   flag for 309's reviser.

## Final verification

- `lake build …NfMultiAnchorBridge.OuterGate` green; **full `lake build` green** (1720 jobs).
- **Axioms** (`lake env lean` `#print axioms`): `_correct_two_prior_frag`,
  `_sound_two_prior_frag`, `_complete_two_prior` all exactly
  `{propext, Classical.choice, Quot.sound}` — no `sorryAx`.
- **Zero sorries introduced**; zero sorries in `NfMultiAnchorBridge/` (all grep hits are prose).
  Repo-wide census: 163 pre-existing sorries, all in other tasks' territory (Boneyard,
  BXCanonical, task-305 EANegation, Expressiveness/CaseAnalysis, EFGames) — untouched.
- **No vacuous definitions introduced** (single repo hit is task-969 legacy in
  `Examples/TemporalStructures.lean`, pre-existing). Axiom count 2, unchanged baseline.
- **Territory**: only `OuterGate.lean` + task-335 spec files changed.

## Sorry inventory (task 335)

Empty — no sorries on any 335 path, none introduced.

## Plan deviations

- Phase D task 1 *(altered)*: `hrealI` + `hrealB` split with a `by_cases` fold-channel
  reassembly instead of a single re-typed hypothesis with a `show`/`change` bridge (see plan
  inline annotation; anticipated by the plan's rollback contingency, resolved without
  re-pointing to global `kvE2_sepPos`).

## What 335 delivers downstream

- 309 Phases 13.4/14 (`KampPrior.lean:351`, follow-on R-B): the k=2 interior+boundary GO gate
  under `kvE2_sepFragment`, provider obligations `hrealI`/`hrealB`/`hexcl`.
- Task 348 (`prop43_exterior_reflatten`): the verbatim narrowed `hexclExt` binder + the
  `kvE2_sepPosI`-indexed provider contract (handoff note §2).
- Deferred (321-N2 successor): multi-positive / full `On` carrier redefinition.
