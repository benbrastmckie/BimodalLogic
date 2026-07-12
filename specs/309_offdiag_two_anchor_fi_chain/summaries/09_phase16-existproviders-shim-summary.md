# Task 309 Phase 16 Summary — ExistProviders Instantiation Shim

- **Date**: 2026-07-11
- **Session**: sess_1783796165_b5b482_309
- **Plan**: plans/09_offdiag-fi-chain-v9.md, Phase 16 (single-phase hard-mode dispatch)
- **Commit**: 14608ddc7

## Phase Executed

Phase 16 only (per dispatch contract): the `ExistProviders` instantiation shim from the
recursion at the `KampPrior.lean:361` site. Marked [COMPLETED] in the plan with an in-plan
completion record and deviation note.

## Declarations Delivered (KampPrior.lean, 185 lines appended; :361/:364 preserved)

| Declaration | Role |
|---|---|
| `kampPrior_existProviders_of_ih` | Generic depth-`j` provider bundle from the recursion's IH shape (the `ih_exist_1` pattern generalized across arities; `existF` = choose, `correct` = choose_spec) |
| `kampPrior_existProviders_of_ih_correct` | Named `P.correct` availability (raw `insertEnv` shape) |
| `kampPrior_existProviders_of_ih_existF0_char` | `existF 0` arity-1 characteristic bridge — the `kvE2_sepPtW … (fun χ => P.existF 0 χ)` feed shape (OuterGate:374/:380/:387 positions) |
| `kampPrior_existProviders_of_ih_exist1` | `existF 1` arity-2 `Fin.cons` bridge — the `ih_exist_1` seam at arbitrary depth |
| `kampPrior_existProviders_one_of_ih` | The depth-1 bundle: THE gate parameter `P` of `bracketEndChar_kvE2Ext_correct_two_prior_frag` / `kampPrior_site_rung2_gate_match` (consumed at the k=2 arm, Phase-15 corrected indexing) |
| `kampPrior_existProviders_zero` | Concrete GREEN depth-0 instantiation from the sorry-free Phase-2 converter (`nf_nvar_exist_depth0_tl_fn`), unconditional |

## Final Verification Results

- Scoped build `Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`: GREEN (1021 jobs)
- Full `lake build`: GREEN (1724 jobs)
- `lean_verify` on all 6 declarations: exactly `[propext, Classical.choice, Quot.sound]`
- Sorry census (Kamp/): 6, all pre-existing (2 Boneyard off-path; EANegation :1090/:1249
  untouched per blocker criterion; KampPrior :361/:364 — the tracked strategic targets).
  Zero new sorries.
- Vacuous-definition check: 0 introduced (single repo hit is a pre-existing `Examples/` item)
- Axiom check: 0 introduced (grep hits are prose in Boneyard comments)
- Frozen provider files (V9-1): byte-unchanged; no `hexclExt` in new material (V9-2);
  `nf_nvar_exist_all_depths` statement untouched (V9-4)

## Plan Deviations

- **Altered (documented, pre-sanctioned)**: converters threaded as the `ih` HYPOTHESIS (the
  13.1 surgery pattern the phase Goal itself names) instead of a top-level by-name call to
  `nf_nvar_exist_all_depths`. Reasons (machine-checked): (1) a by-name reference inherits
  `sorryAx` from the open `:361`/`:364` arms, violating the phase's own axiom acceptance bar;
  (2) an in-arm edit now would shift the `:361` citation the Phase-15 verdict and provider
  handoffs are keyed to. The site instantiation
  `kampPrior_existProviders_of_ih atomMap j (fun n sub => nf_nvar_exist_all_depths atomMap
  h_surj j n sub)` type-checks at the `| k+1 =>` body for every structurally available
  `j ≤ k` (F-A) and lands WITH the Phase-18 arm rewrite. Rationale recorded in-plan and
  in-file (Phase-16 section comment).

## Sorry Inventory

Unchanged from Phase 15: KampPrior :361 (strategic; Phases 18-19) and :364 (strategic;
task 305). See `.orchestrator-handoff.json` / `handoffs/phase-16-handoff-20260711.md`.
