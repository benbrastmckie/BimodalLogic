# Task 309 Phase 15 Handoff — Site/Coverage Probe VERDICT (DECISION GATE)

- **Date**: 2026-07-11
- **Session**: sess_1783796165_b5b482_309
- **Status**: Phase 15 [COMPLETED]; verdict **GO-k1** (with corrected arm indexing, below)
- **Commits**: 765054d5a (probe lemmas green + axiom-clean)

## Immediate Next Action (Phase 16 dispatch)

Build the `ExistProviders sig atomMap 1` instantiation shim at the `| 1 =>` site from the
recursion (`ih_exist_1` pattern, KampPrior:264-321), per the plan's Phase 16 — noting from this
verdict that the providers feed TWO consumers: rung-1's `charF`/`h0` (the k=1 arm, unconditional)
and the kvE2Ext gate's `P` + `hrealI`/`hrealB`/`hexcl` (the k=2 arm, fragment-scoped).

## DECISION-GATE VERDICT: GO-k1

**F-i (fragment coverage): COVERED at the k=1 arm — vacuously/unconditionally.**
Machine-established (via `kampPrior_site_perQnf_seam`, an `Iff.rfl` against
`nf_eval_nf`'s own recursion, NormalForm.lean:198-207): the per-`qnf` obligation at
match-arm `k` of the `| 1 =>` site is

```
∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf      (qnf : NormalForm sig k 3)
```

— depth `k`, ONE LESS than `sub_nf : NormalForm sig (k+1) 2`. At the k=1 arm (depth-2
instance) the population is `NormalForm sig 1 3`: `kvE2_sepFragment` (typed `NormalForm sig
2 3 → Prop`) does not apply, and the obligations are served by the UNCONDITIONAL
`bracketEndChar_kv_correct_one_prior` (certificate: `kampPrior_site_rung1_match`). No
fragment condition arises at the depth-2 instance at all.

**F-ii (depth ladder): rung-index = arm-index; depths ≥ 3 unserved → GO-k1 residual.**

| match arm k | per-qnf depth | rung | conditionality | Phase-15 certificate |
|---|---|---|---|---|
| 0 | 0 | `bracketEndChar_kv_correct_zero_prior` | unconditional | `kampPrior_site_rung0_match` |
| 1 | 1 | `bracketEndChar_kv_correct_one_prior` | `h0` only | `kampPrior_site_rung1_match` |
| 2 | 2 | `bracketEndChar_kvE2Ext_correct_two_prior_frag` (348) | `hfrag` + `hrealI`/`hrealB`/`hexcl` + 6 order bits | `kampPrior_site_rung2_gate_match` |
| ≥3 | ≥3 | NONE (kvE' retired, V9-3) | — | absence recorded in verdict comment |

**Corrected arm indexing (supersedes the plan's informal labels; binding on Phases 16-19):**
1. Phase 18's depth-2 instance closes via rung-1 + trichotomy/arm assets; the kvE2Ext gate is
   NOT consumed at the k=1 arm (it does not type there).
2. The gate + Phases 16-17 provider work pay at the k=2 arm (depth-3 obligations),
   fragment-scoped per the settled option-(a) decision; non-fragment residue → 321-N2
   successor (exhibits: `kampPrior_site_fragment_qnf_exists` /
   `kampPrior_site_nonfragment_qnf_exists`).
3. Phase 19's residual is arms k ≥ 3 (per-qnf depth ≥ 3): the pre-escalated narrowed strategic
   sorry + spawned symbolic-k successor on the kvE2Ext template.

## Current State

- Phase 15 of v9 (15-19) complete: 5 open phases → 4 remaining (16, 17, 18, 19).
- 7 new sorry-free site lemmas at the end of `KampPrior.lean` (line refs :361/:364 PRESERVED —
  material appended after the previous EOF): `kampPrior_site_env_bridge`,
  `kampPrior_site_trichotomy`, `kampPrior_site_perQnf_seam`, `kampPrior_site_rung0_match`,
  `kampPrior_site_rung1_match`, `kampPrior_site_rung2_gate_match`,
  `kampPrior_site_fragment_qnf_exists`, `kampPrior_site_nonfragment_qnf_exists` (8 declarations).
- All axiom-checked: exactly `[propext, Classical.choice, Quot.sound]`.
- Scoped build green (1021 jobs); frozen provider files byte-unchanged (V9-1 honored);
  no reference to `hexclExt` in any new material (V9-2 honored).

## Key Decisions

- Probe lemmas placed ADDITIVELY at end of `KampPrior.lean` (not a new wiring file) to keep the
  `:361`/`:364` citations stable; a wiring file remains available for Phases 16-18 if shims
  outgrow the call site.
- `kampPrior_site_rung2_gate_match` restates the gate's hypothesis inventory VERBATIM (no
  strengthening/weakening) and holds by `exact` — the machine certificate that
  `zoneEnv3 w x t` is definitionally the gate's env.
- The F-i negative exhibit uses the 346 realizability-witness template with a SECOND interior
  positive (zXW3 + zWT3) — two distinct members of `kvE2_sepPosI` refute the singleton.

## Sorry Inventory

| file | line | statement | strategic | assumption | why_deferred | follow_up_task |
|---|---|---|---|---|---|---|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `\| 1 =>` arm of `nf_nvar_exist_all_depths` | true | depth-(k+1) arity-2 existential characterizable | pre-existing retirement target; Phases 16-19 discharge it (348 R1 transfer) | task 309 Phases 18-19 |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `\| n+2 =>` arm of `nf_nvar_exist_all_depths` | true | off critical path | task 305 scope — untouched by design | task 305 |

No new sorries introduced by Phase 15 (probe material 100% sorry-free).

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md` (Phase 15 now
  [COMPLETED] with the in-plan verdict block)
- In-file verdict record: `KampPrior.lean` §"Task 309 Phase 15" (immediately after
  `nf_characterizable_temporal_prior` material, end of file)
- Provider handoffs: 335 `03_frag-gate-for-309-and-348.md`; 348 `02_enriched-gate-for-309.md`
