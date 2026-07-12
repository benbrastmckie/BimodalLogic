# Task 309 Phase 16 Handoff — ExistProviders Instantiation Shim

- **Date**: 2026-07-11
- **Session**: sess_1783796165_b5b482_309
- **Status**: Phase 16 [COMPLETED]
- **Commits**: 14608ddc7 (shim green + axiom-clean)

## Immediate Next Action (Phase 17 dispatch)

Discharge the three 309-owned provider obligations (`hrealI`/`hrealB`/`hexcl`) at exactly the
gate's binder shapes (OuterGate:374/:380/:387, restated verbatim at the kvE2Ext signature in
`kampPrior_site_rung2_gate_match`), for the fragment-certified `qnf` population, with
`P := kampPrior_existProviders_one_of_ih atomMap ih` as the abstract provider parameter.
Phase 17 lemmas should quantify over `P : ExistProviders sig atomMap 1` (or over the `ih`
hypothesis) — `P.correct` and the Phase-16 bridges below give the provider literal semantics.

## Current State

- Phase 16 of v9 (15-19) complete: 2 of 5 open phases done (15, 16); remaining 17, 18, 19.
- 6 new declarations at the end of `KampPrior.lean` (185 lines appended; `:361`/`:364`
  citations PRESERVED — no edit inside the recursion body), all sorry-free, each
  `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`:
  1. `kampPrior_existProviders_of_ih` — generic depth-`j` bundle from the recursion's IH
     shape (the exact `∃`-statement of `nf_nvar_exist_all_depths atomMap h_surj j`);
     `existF` = choose, `correct` = choose_spec — the `ih_exist_1` pattern generalized
     across arities.
  2. `kampPrior_existProviders_of_ih_correct` — named `P.correct` (raw `insertEnv` shape).
  3. `kampPrior_existProviders_of_ih_existF0_char` — `existF 0` arity-1 characteristic bridge
     (`Fin 0` env eliminated): the shape the gate's `kvE2_sepPtW … (fun χ => P.existF 0 χ)`
     positions evaluate at the pivot `w`.
  4. `kampPrior_existProviders_of_ih_exist1` — `existF 1` arity-2 `Fin.cons` bridge (the
     `ih_exist_1` seam, at arbitrary depth `j`).
  5. `kampPrior_existProviders_one_of_ih` — the depth-1 bundle: THE gate parameter `P` of
     `bracketEndChar_kvE2Ext_correct_two_prior_frag` / `kampPrior_site_rung2_gate_match`,
     consumed at the k=2 arm (depth-3 obligations) per the Phase-15 corrected arm indexing.
  6. `kampPrior_existProviders_zero` — concrete GREEN depth-0 instantiation from the
     sorry-free Phase-2 converter `nf_nvar_exist_depth0_tl_fn` (unconditional; `h_UZ`/`h_SZ`
     dropped) — machine-certifies the bundle instantiates from landed converters.
- Full `lake build` green (1724 jobs); frozen provider files byte-unchanged (V9-1); no
  `hexclExt` reference anywhere in new material (V9-2); `nf_nvar_exist_all_depths`'s
  statement untouched (V9-4).

## Key Decisions

- **Of-`ih` hypothesis form (recorded plan deviation, pre-sanctioned by the phase Goal's
  "thread the needed converters as extra hypotheses — the 13.1 surgery pattern")**: a
  top-level by-name reference to `nf_nvar_exist_all_depths` inherits `sorryAx` from the open
  `:361`/`:364` arms (fails the phase's own axiom bar), and an in-arm edit now would shift
  the `:361` citation the Phase-15 verdict and provider handoffs are keyed to. The site
  instantiation `kampPrior_existProviders_of_ih atomMap j (fun n sub =>
  nf_nvar_exist_all_depths atomMap h_surj j n sub)` type-checks inside the `| k+1 =>` body
  for every structurally available `j ≤ k` (F-A) and lands WITH the Phase-18 arm rewrite —
  the edit that retires the sorry itself. Rationale also recorded in-file (Phase-16 section
  comment in `KampPrior.lean`).
- **Depth-1 availability at the k=2 arm**: the gate's `P` is at depth 1 = (arm k=2) − 1;
  nested-pattern access (`| (j+1)+1 =>` refinement) makes the depth-1 IH structurally
  available at every arm the gate serves (k ≥ 2) — Phase 18/19's arm rewrite should match
  `k` deep enough to expose it (noted in the shim's doc comment).
- Material appended after the Phase-15 block, before the namespace `end` — same
  line-citation-preserving discipline as Phase 15.

## Sorry Inventory

| file | line | statement | strategic | assumption | why_deferred | follow_up_task |
|---|---|---|---|---|---|---|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `\| 1 =>` arm of `nf_nvar_exist_all_depths` | true | depth-(k+1) arity-2 existential characterizable | pre-existing retirement target; Phases 17-19 discharge it (348 R1 transfer) | task 309 Phases 18-19 |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `\| n+2 =>` arm of `nf_nvar_exist_all_depths` | true | off critical path | task 305 scope — untouched by design | task 305 |

No new sorries introduced by Phase 16 (shim material 100% sorry-free).

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md` (Phase 16 now
  [COMPLETED] with in-plan completion record + deviation note)
- Phase-15 verdict handoff: `handoffs/phase-15-handoff-20260711.md` (corrected arm indexing —
  binding on Phases 17-19)
- Provider handoffs: 335 `03_frag-gate-for-309-and-348.md`; 348 `02_enriched-gate-for-309.md`
