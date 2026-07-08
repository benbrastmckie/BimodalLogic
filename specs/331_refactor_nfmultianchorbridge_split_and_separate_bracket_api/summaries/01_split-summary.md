# Task 331 Implementation Summary: NfMultiAnchorBridge Split and Separate-Bracket API

- **Task**: 331 — refactor_nfmultianchorbridge_split_and_separate_bracket_api
- **Date**: 2026-07-07
- **Session**: sess_1783475175_afdf09
- **Status**: COMPLETED (8/8 phases)
- **Baseline pin**: ORIG_SHA = `2146e9c05d144b54495f566169a08a7e734bf645`
  (`specs/331_.../.orig-sha`, gitignored)

## What Was Done

The 9,249-line monolith `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
was split into 10 content modules plus an import-only umbrella, entirely by byte-identical slab
relocation against ORIG_SHA (zero token edits except the 11 sanctioned de-privatizations and one
sanctioned block relocation). The umbrella keeps the original path, so the single code consumer
`KampPrior.lean:4` is unchanged.

### Module Inventory

| File | Lines | Orig slab(s) | Role |
|------|-------|--------------|------|
| `NfMultiAnchorBridge.lean` (umbrella) | 88 | :1-:28 imports + :30-:79 docstring | Import-only umbrella; ZERO declarations |
| `NfMultiAnchorBridge/Base.lean` | 1,478 | :88-:1522 | Shared foundations (zones, brackets, seg/holds layer) |
| `NfMultiAnchorBridge/CarrierK1V.lean` | 2,097 | :1523-:3603 | k=1 variable-endpoint carrier |
| `NfMultiAnchorBridge/CarrierKv.lean` | 482 | :3604-:4040 + relocated :5333-:5358 | k=v carrier + `nf_eval_depth1_fold_iff` |
| `NfMultiAnchorBridge/RefutationF2.lean` | 963 | :4041-:4987 | QUARANTINE — F2 relativized-refutation record |
| `NfMultiAnchorBridge/PriorInterface.lean` | 105 | :4988-:5076 | Prior-interface glue |
| `NfMultiAnchorBridge/MergedQuarantine.lean` | 1,026 | :5077-:5332, :5360-:5856, :8586-:8826 | QUARANTINE/DEAD-CODE — merged-route kvE/kvE'/kvE2 bodies |
| `NfMultiAnchorBridge/SubBracket.lean` | 266 | :5857-:6106 | Sub-bracket layer 1 |
| `NfMultiAnchorBridge/SubBracket2.lean` | 644 | :6107-:6733 | Sub-bracket layer 2 (zone specs) |
| `NfMultiAnchorBridge/SubBracket2V.lean` | 1,893 | :6734-:8585 | FAITHFUL SEPARATE-BRACKET API (Rabinovich 2014) |
| `NfMultiAnchorBridge/NavigatedSpine.lean` | 451 | :8827-:9249 | FAITHFUL — spine + Prop 4.3 engine (`reflatten_prop43`) |
| **Total** | **9,493** | | |

The +244 line delta vs the 9,249-line monolith is additive-only scaffolding (banners, module
docstrings, import lines, namespace open/close) reproduced per module; every original content
line is accounted for (see reconstruction gate below).

Import DAG (acyclic, build-proven): Base ← CarrierK1V ← CarrierKv ← {RefutationF2,
PriorInterface}; PriorInterface ← SubBracket ← SubBracket2 ← SubBracket2V ←
{MergedQuarantine (also ← PriorInterface), NavigatedSpine}; umbrella imports all 10.
No faithful module imports a quarantine module.

## Plan Amendments (2)

1. **Phase-4 option-(i) deferral** (commit 804c1aedf): the original Phase 4 planned
   `MergedQuarantine` part 1 as its own extraction, but part 2 (orig :8586-:8826) consumes
   part 1's file-scoped `private` helpers (`kvE_gate`, `kvE_body`, `kvE_pinArrangements`,
   `kvE_pinDisjunct`, `kvE_exclConj`, `kvE'_body`), and de-privatizing them was forbidden by
   the binding constraints. Resolution: Phase 4 rescoped to PriorInterface-only; the ENTIRE
   MergedQuarantine (parts 1+2 in ONE file) moved to Phase 7, after SubBracket2V exists.
   Same-module `private` reuse preserved; zero extra de-privatizations.
2. **Phase-6 boundary :8586** (binding, annotated inline in the plan): the SubBracket2V slab
   cut is :6734-:8585, not the planned :6734-:8607 — orig :8586-:8607 is `open Classical in`
   plus the `kvE2_body` doc comment, which cannot dangle at the end of SubBracket2V.lean; it
   moved with its declaration into MergedQuarantine (part 2 = :8586-:8826, not :8608-:8826).
   Partition change only; every line stays byte-identical to ORIG_SHA.

## Sanctioned Token Edits (11 de-privatizations + 1 relocation, nothing else)

De-privatizations (removal of leading `private `; orig line numbers):

| # | Declaration | Orig line | Now in |
|---|-------------|-----------|--------|
| 1 | `bracketFromLists` | :1896 | CarrierK1V.lean |
| 2 | `k1v_bool_eq_false` | :2032 | CarrierK1V.lean |
| 3 | `k1v_bracket_extract_mono` | :2274 | CarrierK1V.lean |
| 4 | `getElem_append3_mid` | :2300 | CarrierK1V.lean |
| 5 | `k1v_not_of_iff_false` | :2465 | CarrierK1V.lean |
| 6 | `k1v_sorted_realization` | :2954 | CarrierK1V.lean |
| 7 | `atomKind_castLE` | :3640 | CarrierKv.lean |
| 8 | `kvE_sub2_zXU` | :6213 | SubBracket2.lean |
| 9 | `kvE_sub2_zUW` | :6217 | SubBracket2.lean |
| 10 | `kvE_sub2_zWT` | :6221 | SubBracket2.lean |
| 11 | `kvE_sub2_zoneHolds_cons_iff` | :6628 | SubBracket2.lean |

Relocation: the `nf_eval_depth1_fold_iff` block (orig :5333-:5358 + trailing blank :5359) moved
out of the quarantine region into `CarrierKv.lean:455-480`, byte-identical, so that no faithful
module imports the quarantine (SETTLED decision 5, primary branch — the Risk-2 contingency never
fired).

## Settled Divergences Carried Forward (3, from research)

1. `bracketFromLists_flatMap_subchain_below_pin` (:7793) lives in `SubBracket2V.lean` (faithful),
   NOT the quarantine, despite task text item 1(f) — its only consumers are the task-326
   `_of_outer` closers in the same module and it stays `private`.
2. "Quarantining `slotsFor`" = quarantining `kvE'_body` (:5562) and `kvE2_body` (:8608);
   `slotsFor` is a local `let` inside those bodies, not a top-level def.
3. The task's "VVecEA2.conj" is `VVecEA2.conj_struct` (`VecEAClosure.lean:195`, external to the
   monolith) — cross-referenced in the SubBracket2V API banner, not relocated.

## Phase 8 Gate Results

| # | Gate | Result | Evidence |
|---|------|--------|----------|
| 1 | Full `lake build` exit 0 | PASS | `Build completed successfully (1719 jobs).` EXIT=0 |
| 2 | Axiom check, 4 flagship theorems | PASS | `lean_verify` on `kvE_subBracket2V_correctness_pair` (SubBracket2V.lean:1855), `reflatten_prop43` (NavigatedSpine.lean:193), `bracketEndChar_kvE2_two_eq` (MergedQuarantine.lean:926), `f2_relativized_refutation` (RefutationF2.lean:859) — each exactly `["propext","Classical.choice","Quot.sound"]`, no warnings |
| 3 | Sorry parity vs ORIG_SHA | PASS | `grep -rn "sorry"` over umbrella + module dir = 47 occurrences; `git show $ORIG_SHA:...NfMultiAnchorBridge.lean | grep -c "sorry"` = 47; all hits are prose in docstrings/decision records ("sorry-free", historical records); zero `sorry` terms/tactics |
| 4 | Consumer gate (KampPrior untouched) | PASS | `git diff $ORIG_SHA -- .../KampPrior.lean` empty (0 lines); exactly 1 import site (`KampPrior.lean:4`); all other `NfMultiAnchorBridge` mentions in Theories/Tests are pre-existing prose comments (EANegationClosure, NfDepth0Generalized, NfEFold, NfZoneFlattenNavigable) |
| 5 | Line-count reconciliation | PASS | Table above; total 9,493; largest module 2,097 <= ~2,100 bound; per-slab `wc -l` sums match orig slab extents exactly |
| 6 | De-privatization audit (exactly 11) | PASS | Per-module body-vs-slab diffs: EMPTY everywhere except exactly 6 private-removals (CarrierK1V) + 1 (CarrierKv) + 4 (SubBracket2). Whole-file reconstruction of the 9,249-line original from the relocated bodies diffs at exactly 22 lines = the 11 `private `-removal pairs, nothing else |
| 7 | Umbrella zero declarations | PASS | 88 lines; declaration-pattern grep finds nothing (imports + docstring only) |

## Explicitly NOT Done (per plan Non-Goals)

- Stale comment line-refs (docstrings citing orig monolith `:NNNN` coordinates) remain
  byte-identical — fixing them is an explicit plan Non-Goal; each module's provenance header
  records its orig slab range, which is the coordinate mapping.
- No new lemmas, no proof changes, no renames, no namespace changes, no lakefile edits, no
  deletion of merged-route code.

## Handoff Notes for Task 321 (k=2 gate)

- **The faithful separate-bracket API now lives in**: `SubBracket2V.lean` (kvE sub-chain 2V
  layer, `kvE_subBracket2V_correctness_pair`, the task-326 `_of_outer` closers, and the
  FAITHFUL SEPARATE-BRACKET API banner with the Rabinovich 2014 references,
  `neg_2var_vec_ea` / `VVecEA2.conj_struct` cross-refs, and the shared-interior-witness note)
  and `NavigatedSpine.lean` (spine + Prop 4.3 engine, `reflatten_prop43`).
- **What is quarantined**: `MergedQuarantine.lean` (merged-route `kvE_gate`/`kvE_body`/
  `kvE'_body`/`kvE2_body` region incl. `bracketEndChar_kvE2_two_eq` and the R2 GO/NO-GO
  records) and `RefutationF2.lean` (F2 relativized-refutation record) — dead code off the
  faithful import path; nothing faithful imports them.
- Task 321's blocked `kvE2_outer_fold` engine work should build against SubBracket2V +
  NavigatedSpine only; RefutationF2 is reachable only via the umbrella.

## Commits

Phases 1-7: ba1bc0829 (P1), P2, P3+P4 f1cae4b57, plan amendment 804c1aedf, P5 fadbbea31,
P6 d35ab2714, P7 18225840a; build green (exit 0) at every phase commit. Phase 8 adds the
verification-and-summary commit (no source changes).
