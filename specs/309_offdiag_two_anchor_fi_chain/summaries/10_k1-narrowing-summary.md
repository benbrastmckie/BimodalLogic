# Task 309 Implementation Summary — v10 k≤1 Narrowing (2026-07-14)

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Plan**: plans/10_offdiag-fi-chain-v10.md (Phases 20-21, both [COMPLETED])
- **Session**: sess_1784036998_a5fcb0
- **Commits**: da54fb9a0 (Phase 20), Phase-21 commit (this change set)

## Honest completion statement (V10-5 — binding scope language)

**k≤1 narrowing COMPLETE with a documented k≥2 residual.** The `KampPrior.lean:361`
blanket strategic sorry (the `| 1 =>` n=1 arm of `nf_nvar_exist_all_depths`) is NARROWED —
NOT fully retired — to a `match k` dispatch with the k=0 and k=1 arms discharged by name
and exactly ONE narrowed residual sorry at `| _k + 2 =>`:

- `| 0 =>` closed by `kampPrior_case1_arm_k0` (task 358, landed 8a7d504ec, over task 350's
  k=0 arm triple);
- `| 1 =>` closed by `kampPrior_case1_arm_k1` (NEW, task 309 Phase 20, over task 350's k=1
  arm triple `kampArm_{past,diag,future}_k1_correct`, assembled through the Phase-18a
  skeleton `kampPrior_case1_trichotomy_assemble`);
- `| _k + 2 =>` the pre-committed residual, carrying an inline successor note naming
  **task 358** and the Track-A blocker `P17-frozen-interface-gap` (hrealI/hrealB
  anchor-content interface gap), with the landed general-k machinery cited by its landed
  names (`endInterval_correct`, the kvE2Ext/kvExt gate stack) per V10-2.

`nf_nvar_exist_all_depths` remains `sorryAx`-dependent BY DESIGN
(`[propext, sorryAx, Classical.choice, Quot.sound]`) until task 358 lands the k≥2
realization recursion. No claim of full `:361` retirement or of a sorryAx-free recursion is
made. Task-307 Phase-7 impact: still gated on the k≥2 residual (no unconditional unblock).

## What was delivered

### Phase 20 — `kampPrior_case1_arm_k1` (commit da54fb9a0)

The ambient-k=1 arm closure (`sub_nf : NormalForm sig 2 2`), mirroring the landed k=0
recipe verbatim: witness `Formula.or (kampArm_past_k1 …) (Formula.or (kampArm_diag_k1 …)
(kampArm_future_k1 …))`, correctness by `kampPrior_case1_trichotomy_assemble atomMap M 1
sub_nf t` applied to the three task-350 `_correct` lemmas. The `1 + 1` vs `2` index was
accepted definitionally (no `show` needed, as the `ShapeCertificatesK1` machine
certification predicted). Sorry-free, axiom-clean, no warnings.

### Phase 21 — the `:361` k≤1 narrowing + hoist + verification

1. The match narrowing described above (count-neutral: ONE blanket sorry → ONE narrowed
   sorry, V10-4).
2. The `:352-360` task-348 transfer note gained the dated v10 record ("k≤1 arms discharged
   by task 309 v10 Phases 20-21 via task 349/350/358 deliverables; k+2 residual → task
   358").
3. The pre-authorized forward-reference hoist (see Plan Deviations).

## Verification record (v10 DoD)

| Bar | Result |
|---|---|
| Full-tree `lake build` | GREEN, 1751 jobs (baseline 1736-1751) |
| KampPrior sorry-token count | exactly 2 (narrowed `\| _k+2 =>` + the `\| n+2 =>` arm, former `:364`-region, byte-unchanged) |
| `lean_verify kampPrior_case1_arm_k1` | exactly `[propext, Classical.choice, Quot.sound]`, no warnings |
| `lean_verify kampPrior_case1_arm_k0` | exactly `[propext, Classical.choice, Quot.sound]` (unchanged by hoist) |
| `#print axioms nf_nvar_exist_all_depths` | `[propext, sorryAx, Classical.choice, Quot.sound]` — EXPECTED per V10-4 |
| `nf_nvar_exist_all_depths` signature | byte-unchanged (V9-4) |
| Frozen territory | git diff touches ONLY KampPrior.lean (+ spec artifacts) |
| Route V (V10-1) | no `h_quant`/`quantEnd` threading in new material |
| Name mapping (V10-2) | no `endChar_correct` identifier anywhere; residual cites `endInterval_correct` |
| Seam (V10-3) | pre-edit record: last KampPrior commit 8a7d504ec, `:361` still blanket; residual note names task 358; `kampPrior_case1_arm_k0` moved verbatim, no proof edit |
| Imports | unchanged (aggregator already imported) |
| Vacuous defs / new axioms | 0 / 0 |

## Plan Deviations

- **Altered (pre-authorized)**: the Phase-21 forward-reference hoist WAS taken — the plan's
  preferred contingency ("Prefer hoisting"). The five-lemma chain
  (`kampPrior_site_env_bridge`, `kampPrior_site_trichotomy`,
  `kampPrior_case1_trichotomy_assemble`, `kampPrior_case1_arm_k0`,
  `kampPrior_case1_arm_k1`) was moved VERBATIM (statements and proofs byte-identical) above
  `nf_nvar_exist_all_depths`, with hoist notes left at each original site. The hoist is
  strictly wider than the plan's headline text ("hoist the two arm closures") because the
  arm closures' proofs cite the assemble skeleton, which cites the trichotomy, which cites
  the env bridge — the minimal dependency-closed move. The task-358 lemma moved with no
  proof edit, as required.
- None otherwise (implementation followed plan).

## Residual and successor routing

- `| _k + 2 =>` residual (k≥2 arms): task 358 (realization recursion at the seam; task-349
  obligation-ledger rows 1-6/8-11; Track-A blocker `P17-frozen-interface-gap`).
- `| n + 2 =>` arm (former `:364`, off critical path): task 358 territory, untouched.
