# Implementation Plan: Task #349 (v9 — consume the general-`k` interior gate and its delivered consumer stack)

- **Task**: 349 - Build the recursive navigated endpoint primitive as
  `endInterval : (k) → BracketEndCharCarrierV sig k` + its Prior-guarded correctness
  (`EndIntervalCorrectPrior` biconditional) on the enriched-segment bracket carrier (carrier 3)
- **Status**: [COMPLETED]
- **Effort**: ~4 hours (remaining open work; Phases 1-4 landed green under v7/v8, and the
  former Phases 5-7 construction scope has been DELIVERED by spawned tasks 355/356/357/360 —
  the residual is adoption, integration, and audit)
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction`); Task 352 (LANDED — depth-`k`
  exterior-negation clause layer); Task 354 (LANDED — reverse `_complete` converters + bundle
  templates); **Task 355 (COMPLETED — general-`k` interior gate correctness
  `bracketEndChar_kv_correct_prior`, `InteriorGateGeneralK.lean:1288`)**; **Task 356 (COMPLETED —
  exterior-composed gate `bracketEndChar_kvExt_correct_prior` with `hexclExt` discharged
  internally, `ExteriorGateAssembleK.lean:180`)**; **Task 357 (COMPLETED — obligation-carrying
  consumer reshape `endIntervalPrior`/`EndIntervalCorrectPrior`/`endInterval_step_correct`,
  `EndIntervalConsumerK.lean`)**; **Task 360 (COMPLETED — faithful slice-keyed exterior
  interface; D1-D4 re-keyed and re-proved; `hbr*` eliminated repo-wide; four m=0 supply
  theorems)**. Task 358 ([BLOCKED], downstream — realization recursion retiring
  `KampPrior:361/364`; NOT a 349 dependency: 349 threads obligations, never discharges them.)
- **Research Inputs**:
  - `specs/355_build_depthk_interior_gate_correctness/summaries/02_interior-gate-deliverable-reshape-summary.md`
    (AUTHORITATIVE for the interior-gate consumable: `InteriorGateAllK` k-cased motive, the
    seven-obligation consumer interface `P`/`hcharK`/`h_UZ`/`h_SZ`/`hreal`/`hexcl`/`hexclExt`)
  - `specs/355_.../summaries/01_depthk-interior-gate-correctness-summary.md` (F1 rationale for the
    obligation-carrying shape; Lemma-7.6 faithfulness of the `hexclExt` hand-off)
  - `specs/356_discharge_depthk_hexclext_exterior_adjacency/summaries/01_hexclext-discharge-exterior-gate-summary.md`
    (the exterior-composed gate; `hexclExt` internalization; exterior realization obligations
    threaded outward)
  - `specs/357_reshape_endinterval_consumer_obligation_carrying/summaries/01_endinterval-consumer-reshape-summary.md`
    (the delivered 349 Phase-5-7 consumer: relocation-to-leaf decision, 3-arm motive, carry-not-
    discharge discipline, task-358 spawn for the full discharge)
  - `specs/360_restate_exterior_hbr_pinned_converse/summaries/01_faithful-slice-repair-summary.md`
    (slice-keyed exterior interface replacing the machine-refuted `hbr*`; m=0 supply theorems)
  - `specs/349_.../reports/12_spawn-analysis.md` (why 355 was spawned — the interior-gate blocker
    this revision retires)
  - `specs/349_.../reports/09_carrier-synthesis.md` (carrier decision — still authoritative for
    carrier type §3.1; the v7 architecture the delivered stack realizes)
  - `specs/349_.../reports/11_recent-completion-consumption.md` (the v8 consumption mapping for
    Phases 3-4, preserved)
- **Artifacts**: plans/09_consume-interior-gate-general-k.md (this file); supersedes
  plans/08_consume-depthk-clause-layer.md (v8; Phases 5-7 scope note stale)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md;
  lean4 extension rules; reference-grounding.md (H3 Tier-1 lean4 override);
  plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [12_spawn-analysis.md, 11_recent-completion-consumption.md,
  09_carrier-synthesis.md, 355/01, 355/02, 356/01, 357/01, 360/01]

## Overview

**Supersedes v8 because**: v8 Phases 5-7 carry a RESUME POINT scope note (v8 lines 446-461)
instructing the implementer to BUILD the general-`k` interior gate correctness (~700-1300 new
proof lines), stating it is "NOT delivered by 351/352/354". That was true when v8 was written;
it is now FALSE **four times over**. The spawned blocker-resolution chain has since landed:

1. **Task 355** delivered exactly that lemma — `bracketEndChar_kv_correct_prior :
   ∀ k, InteriorGateAllK atomMap h_surj charF k` (`InteriorGateGeneralK.lean:1288`), with the
   k-cased motive `InteriorGateAllK` (`:1239`; k=0 clean/obligation-free, k=n+1
   obligation-carrying) and the k→k+1 step biconditional `bracketEndChar_kv_step_correct`
   (`:1165`). The `## Phase 8 — consumability shape` doc-comment (`:1299-1327`) records the
   seven-obligation consumer interface: `P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`,
   `hexclExt`.
2. **Task 356** delivered the 355 follow-up (b) — the general-`k` `hexclExt` exterior-adjacency
   discharge, as the exterior-composed gate `bracketEndChar_kvExt` + `_holds_iff` +
   `_correct_prior` (`ExteriorGateAssembleK.lean:119/:135/:180`), Rabinovich Lemma-7.6 adjacent-
   bracket composition via `enrichEndpoints`; `hexclExt` is discharged INTERNALLY (⇒-side guard
   split → per-side Phase-3 `kvE_extBracket{Past,Fut}_sound`).
3. **Task 357** delivered the 355 follow-up (a) — the consumer reshape itself:
   `endIntervalStepPrior` / `endIntervalPrior` / `EndIntervalCorrectPrior` /
   `endInterval_step_correct : ∀ k, EndIntervalCorrectPrior …` in the new leaf
   `EndIntervalConsumerK.lean` (relocated below `ExteriorGateAssembleK` to break the
   `CarrierK1V` import cycle — a pre-planned contingency), all green, sorry-free, axioms exactly
   `[propext, Classical.choice, Quot.sound]`, full-tree GREEN.
4. **Task 360** repaired the exterior interface faithfully — the four machine-refuted `hbr*`
   obligations (356's Phase-4 deviation) were eliminated repo-wide and replaced by the
   slice-keyed pairs `hslice{Past,Fut}` / `hexclSlice{Past,Fut}`; D1-D4 were re-keyed and
   re-proved; four m=0 supply theorems (`kvE_h{slice,exclSlice}{Fut,Past}_supply_zero`) landed.

Dispatching implement against v8 verbatim would therefore rebuild the completed work of FOUR
tasks — an H5 divergence. v9 re-points Phases 5-7 from BUILD to **CONSUME + INTEGRATE + AUDIT**:
adopt the delivered stack as the task-349 deliverable, wire the naming/doc/citability residue
that only task 349 owns, and run the definition-of-done audit. The remaining work is small and
bounded (~4 hours): no open mathematics remains in 349 scope.

**What v9 changes vs v8** (nothing else): Phases 1-4 are preserved [COMPLETED] verbatim in
substance (with a post-v8 provenance note recording the 360 re-key of the D1-D4 statements).
Phases 5-7 are re-authored as consumption/integration/audit phases. Phase 8 is unchanged in
intent, with the `lean_verify` target list updated to record `bracketEndChar_kv_correct_prior`
and `bracketEndChar_kvExt_correct_prior` as CONSUMED (not rebuilt) dependencies, and the
`hreal`/`hexcl`/`hexclExt`/slice-obligation disposition recorded.

**Definition of done** (v8 shape preserved, names bound to the delivered stack): the recursion
carrier `endIntervalPrior` (the sanctioned realization of `endInterval`) + the Prior-guarded
obligation-carrying correctness `endInterval_step_correct : ∀ k, EndIntervalCorrectPrior …`
(+ the thin DoD-named alias `endInterval_correct`, Phase 5) adopted as the task-349 deliverable;
sorry-free; `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`; whole-tree
`lake build` GREEN; zero edits to frozen files; the deliverable top-level citable **by name** by
task 309 Phase 18/19 and task 350, with the stale "NOT YET BUILT" doc-hook in `Base.lean`
(:958-969 region) re-pointed at the delivered stack. If any residual item cannot close green,
mark `[BLOCKED]` + exact evidence + `/spawn 349` — never a fake green.

### Consumed Stack (the delivered chain v9 adopts — verify names against source, do not rebuild)

```
InteriorGateGeneralK.lean  (355)  bracketEndChar_kv_correct_prior : ∀ k, InteriorGateAllK … k
        │                          (k-cased motive :1239; step biconditional :1165)
        ▼
ExteriorGateAssembleK.lean (356)  bracketEndChar_kvExt / _holds_iff / _correct_prior
        │                          (hexclExt discharged internally; Lemma 7.6 adjacency)
        ▼
EndIntervalConsumerK.lean  (357)  endIntervalStepPrior / endIntervalPrior /
                                   EndIntervalCorrectPrior (3-arm) / endInterval_step_correct
             (obligations slice-keyed by 360; m=0 supply theorems in ExteriorPinnedConverse{,Past}K)
```

### Preserved Assets

Complete, green, sorry-free — **consume by name, do NOT rebuild or regress.**

| Component | File:line | Status | Role in v9 |
|-----------|-----------|--------|------------|
| **Phase 1 — general-`k` fold bridge** `nf_eval_nfk_iff_efold` (+ index plumbing, k=1 recovery) | NfEFold.lean:627 | [COMPLETED] (preserved) | fold characterization beneath every consumed layer |
| **Phase 2 determinacy core** (`nfk_truncD` … `kvE_futAnyBit_zero`) | ExteriorBracketK.lean | [COMPLETED] (preserved, FROZEN) | depth-`k` determinacy pins beneath the bracket layer |
| **Phases 3-4 — D1-D4 bracket layer** `kvE_extBracket{Fut,Past}` + `_iff`/`_sound`/`_complete` | ExteriorBracketAssembleK.lean:90/104/115/138/168/190/224/261 | [COMPLETED] (preserved; **re-keyed slice-wise + re-proved by task 360 Phase 3b** — current statements are the 360 versions) | exterior residue consumed via the 356 gate |
| `bracketEndChar_kv` (depth-`k` interior carrier) | CarrierKv.lean:238 | [COMPLETED] FROZEN | the interior carrier the gate characterizes |
| **`InteriorGateAllK` (k-cased motive) / `bracketEndChar_kv_step_correct` / `bracketEndChar_kv_correct_prior`** | InteriorGateGeneralK.lean:1239/1165/1288 | [COMPLETED] task 355 | **THE interior-gate correctness v8 Phases 5-7 were scoped to build — consume by name** |
| `interiorGateTarget_zero`/`_one`, `interiorGate_hck`/`_hcb` | InteriorGateGeneralK.lean:89/102 + Phase 2 | [COMPLETED] task 355 | base rungs + provider/char bridges |
| **`bracketEndChar_kvExt` / `_holds_iff` / `_correct_prior`** (exterior-composed gate; `hexclExt` internalized) | ExteriorGateAssembleK.lean:119/135/180 | [COMPLETED] task 356 | the 355 follow-up (b) — Lemma-7.6 adjacency composition, consumed by the 357 consumer |
| **`endIntervalStepPrior` / `endIntervalPrior` / `EndIntervalCorrectPrior` / `endInterval_step_correct`** | EndIntervalConsumerK.lean:55/70/97/185 | [COMPLETED] task 357 | the 355 follow-up (a) — **the task-349 Phase-5-7 deliverable itself**; v9 adopts it |
| `kampPrior_site_rungK_gate_match` (general-`k` supply-site certificate) | KampPrior.lean (357) | [COMPLETED] task 357 | downstream seam; KampPrior stays NO-EDIT for 349 |
| Slice-keyed exterior interface: `kvE_{fut,past}SliceMarked`(+`_iff`), `kvE_{fut,past}SliceEq`, `kvE_{fut,past}SliceId_of_end_zero`, `kvE_{fut,past}SliceUnique_zero` | ExteriorBracketAssembleK.lean:67 + ExteriorPinnedConverseK.lean:891/1114 / PastK:530/356 | [COMPLETED] task 360 | the faithful replacement of the machine-refuted `hbr*` |
| m=0 supply theorems `kvE_h{slice,exclSlice}{Fut,Past}_supply_zero` | ExteriorPinnedConverseK.lean:1301/1242 / PastK:822/769 | [COMPLETED] task 360 | discharge the slice obligations at m=0; feed task 358's KampPrior:361 site |
| 352/354 clause layer (`kvE_extNeg{Fut,Past}_sound/_complete`, bundle templates, fiber machinery) | ExteriorNegation{,Past}K / ExteriorConverter{,Past}K | [COMPLETED] 352/354 | beneath the bracket layer; consume-only |
| `nfEval_le2_reduction` (Rabinovich Lem 3.2(2)) | Lemma32Reduction.lean:535 | [COMPLETED] task 351 | interior arity reduction; FROZEN |
| `ExistProviders`/`existF`; `nf_eval_unique`; `BracketEndCharCarrierV`; k1v family; `bracketEndChar_k0`+`_correct`; `VVecEA2.singleton_holds` | PriorInterface.lean:38-40; NormalForm.lean:245; CarrierK1V.lean:365/433-2041/73/87/2127 | [COMPLETED] | interface + carrier substrate (all FROZEN or consume-only) |
| `f2_relativized_refutation` / `endCharN0_correct_infeasible` | RefutationF2.lean:859 / Base.lean:1779 | [COMPLETED] | machine-checked negative guardrails |
| Aggregator threading (`ExteriorGateAssembleK` + `EndIntervalConsumerK` in the root build) | NfMultiAnchorBridge.lean:55-56 | [COMPLETED] task 357 | reachability — the deliverable is in the build tree |

**Dead code, adjudicated (do not "fix")**: the `CarrierK1V.lean` pair `endIntervalStep` (`:2144`,
the `⟨[]⟩` placeholder) and unconditional `EndIntervalCorrect` (`:2179`) are superseded by the
relocated 357 consumer and are referenced only within `CarrierK1V` (357 Phase-1 finding: filling
in place creates an import cycle). `CarrierK1V.lean` is byte-frozen (355/356/357 baseline);
v9 leaves both declarations untouched — the supersession is already documented in
`EndIntervalConsumerK.lean`'s module header and is re-documented at the `Base.lean` doc-hook
(Phase 6). Their presence is NOT debt (genuine total defs, no sorry, no vacuous pattern).

### FROZEN / consume-only files — byte-identical at every v9 commit (do NOT edit)

1-7. The seven original frozen providers (SharedWitness, SubBracket2V, OuterGate,
ExteriorBracket, ExteriorZoneTriage, ExteriorNegation, ExteriorNegationPast).
8. `ExteriorBracketK.lean` 9. `KampPrior.lean` (NO-EDIT for 349 — 357's sanction does NOT
transfer) 10. `Lemma32Reduction.lean` 11. `CarrierK1V.lean` 12. `CarrierKv.lean`
13. `PriorInterface.lean` 14. `InteriorGateGeneralK.lean` (355, consume-only)
15. `ExteriorGateAssembleK.lean` (356, consume-only) 16. `ExteriorBracketAssembleK.lean` +
the 360 modules (`ExteriorPinnedConverse{,Past}K`, `ExteriorFiberProbeK`, `ExteriorPinnedProbeK`)
and the 352/354 clause modules — consume-only. `nf_nvar_exist_all_depths`'s signature untouched.

**v9-editable (additive only)**: `EndIntervalConsumerK.lean` (Phase-5 alias tail),
`Base.lean` (Phase-6 doc-hook update — doc-comment edits at the 349-owned :958-1010 region are
sanctioned; no signature changes), `NavigatedEndChar.lean` (only if a doc pointer is needed).

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

Source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Status |
|--------------------------|---------------|-----------------|--------|
| Lemma 3.2(2) — ≤2-free reduction | md:119 (p.4) | `nfEval_le2_reduction` | transcribed (351) |
| Prop 4.3 — innermost ∃-fold | PDF p.6 | `nf_eval_nfk_iff_efold` (NfEFold:627) | transcribed (v7 Phase 1) |
| Prop 4.2 — exterior exclusion clause layer + bracket wrapper | md:165 (p.7) | `kvE_extNeg…` (352/354) / `kvE_extBracket…` (v8 Phases 3-4, re-keyed 360) | transcribed |
| Cor 5.4 — single-bracket `[x,t]` interior characterization (∨→∃∀ converter; within-bracket witness + exclusions) | md:255 (§5) | `InteriorGateAllK` / `bracketEndChar_kv_correct_prior` (355) | **transcribed (355) — CONSUMED, not rebuilt** |
| Lemma 7.6 — adjacency composition (exterior witnesses via adjacent brackets, never within one bracket) | md:413 (§7) | `bracketEndChar_kvExt` + `_correct_prior` (356, via `enrichEndpoints`) | **transcribed (356) — CONSUMED** |
| Def 7.13 — multi-anchor bracket family | md:451 (§7) | `BracketEndCharCarrierV` / VVecEA2 | transcribed |
| Cor 5.4 — endpoint characteristic chain (THE recursion this task delivers) | md:255 (§5) | `endIntervalPrior` / `endInterval_step_correct` (357) + Phase-5 alias `endInterval_correct` | **transcribed (357) — CONSUMED + adopted; audited GREEN (v9 Phases 5-8 complete; Phase-8 whole-tree gate 1736 jobs, all 12 verify targets axiom-clean)** |

## Goals & Non-Goals

**Goals**:
- Adopt the delivered 355/356/357/360 stack as the task-349 deliverable: machine-verify the
  consumer (`endInterval_step_correct`) against the v8 DoD shape, add the thin DoD-named alias
  `endInterval_correct` (one theorem, additive tail of `EndIntervalConsumerK.lean`).
- Re-point the stale `Base.lean` doc-hook (:958-969 region: "the recursive primitive … is NOT
  built here") at the delivered stack, recording the settled `EndCharCarrier` →
  `BracketEndCharCarrierV` carrier mapping so downstream consumers (309 Phase 18/19, 350) cite
  the right names.
- Produce the obligation-disposition ledger: which of the 11 threaded obligations remain
  hypothesis-side and where each is discharged (356 internalized `hexclExt`; 360 m=0 supply for
  the slice pairs; task 358 for `hreal`/`hexcl` + general-m slices at KampPrior:361/364;
  309 Phase 14 for the provider family against `nf_nvar_exist_all_depths`).
- Final audit: whole-tree GREEN, axiom checks (consumed deps included), guards G1-G5, FORBIDDEN
  grep, frozen-file diffs EMPTY; completion summary.

**Non-Goals**:
- Rebuilding ANY part of the delivered stack: the interior gate (355), the `hexclExt` discharge /
  exterior-composed gate (356), the consumer reshape (357), or the slice-keyed exterior
  interface (360). Every one of these is landed, green, axiom-clean — consumption is by name.
- Discharging `hreal`/`hexcl` or the general-m slice obligations (task 358's realization
  recursion, KampPrior:361/364 — [BLOCKED] downstream, out of 349 scope, KampPrior NO-EDIT).
- Instantiating the provider family against `nf_nvar_exist_all_depths` (task 309 Phase 14).
- Editing any FROZEN/consume-only file; filling the dead `CarrierK1V` `endIntervalStep`
  placeholder (adjudicated dead code — see Preserved Assets); the top-level ≤1-free extraction
  (Prop 3.5 / Thm 4.4, downstream 350/309); restoring any Boneyard file.
- Any single-point `→ TemporalPred` recursion carrier, `navPieceForm`, `h_res` threading,
  arity-1 interior projection, arity-4 collapse, per-pair `∀ij∃w`, flat `extF4`, or the
  machine-refuted `hbr*` pinned-converse route (360 refutation: `kvE_futPinned_of_end_zero_refuted`).

## Postmortem Constraints

Binding rules for all implementation dispatches. Carried forward from v7/v8 (the FOUR carrier
strikes remain machine-grounded) plus new rules from the 355-360 deliveries. **Landing any
forbidden construct is a `[BLOCKED]` escalation, never a silent workaround.**

**Do NOT** (violation = STOP + `[BLOCKED]` + evidence + `/spawn 349`):
1. Rebuild or re-derive any 355/356/357/360 deliverable (the H5 divergence this revision
   corrects). If a verification probe fails against a delivered name, that is a DEFECT report
   routed to a spawn — never an in-place re-proof.
2. Re-open the IH-threading question. **SETTLED (355 Phase 7 / 357 Phase 2)**: the recursion
   step does NOT consume the arity-3 inductive hypothesis — interior content is provider-
   realized (`P.existF`), and `endIntervalStepPrior` intentionally discards `_rec`. This is the
   faithful Rabinovich shape (Cor 5.4 converter), not vacuity: each depth's carrier
   (`bracketEndChar_k0` / `bracketEndChar_kv 1` / `bracketEndChar_kvExt`) is a genuine
   construction and the three `Nat.rec` reductions hold by `rfl`.
3. Attempt to discharge `hreal`/`hexcl`/`hslice*`/`hexclSlice*` in 349 scope (task 358 /
   309 Phase 14 territory; KampPrior NO-EDIT — 357's KampPrior sanction does not transfer to 349).
4. Re-introduce the single-point `→ TemporalPred` carrier, any single-point closed-formula `↔`
   goal, `h_res` threading, `nfk_projFresh` interior reads, `kv_body` resurrection, arity
   collapse, or per-pair `∀ij∃w` (strikes 1-3 + G1; unchanged from v8).
5. Resurrect the eliminated `hbr*` obligations or the pinned-converse route (360:
   machine-refuted; `hbr*` grep must stay 0 repo-wide).
6. Fake green: no `sorry`, no vacuous def, no `simp`/`omega`/`aesop` chain-step shortcut (G5).
7. Edit any FROZEN/consume-only file (list above). All v9 Lean edits are additive tails of
   `EndIntervalConsumerK.lean` or doc-comment edits in the 349-owned `Base.lean` region.
8. `nf_char3_deeper_split` — FORBIDDEN, grep-clean in all new code.

**Guards (binding, restated — checked every phase)**:
- **G1** — no arity-1 interior collapse; interior obligations at FULL arity 4 (already true of
  the delivered `EndIntervalCorrectPrior` binders — Phase 5 verifies, Phase 7 audits).
- **G2/G4** — free anchors strictly ⊆ {x,t}, ≤2; `w`, `x1`, `v` bound witnesses only.
- **G3** — non-trivial segments (never `TemporalPred.top`).
- **G5** — manual bridges on Rabinovich chain steps; `simp` only for trivial membership/Bool goals.
- **Axioms** — exactly `[propext, Classical.choice, Quot.sound]` on every headline decl.

**Design decisions are SETTLED** (do not re-open without a machine-checked counterexample):
- Carrier 3 (`BracketEndCharCarrierV`, enriched-segment bracket) is the carrier; interior reads
  at FULL arity 4; correctness is Prior-guarded and OBLIGATION-CARRYING (the clean unconditional
  shape is F1-refuted at k ≥ 2 — `bracketEndChar_kv_factors`, CarrierKv.lean:422).
- The deliverable realization is the RELOCATED consumer (`EndIntervalConsumerK.lean` leaf), not
  an in-place `CarrierK1V` fill (import-cycle finding, 357 Phase 1).
- The exterior interface is SLICE-KEYED (360); the depth-cased motive is 3-arm
  (0 / 1 / m+2 — 357: the exterior-composed gate exists only at interior depths ≥ 2).
- Obligations are THREADED OUTWARD, discharged downstream (358 / 309 Phase 14) — for v9's audit
  this is a documented interface, never debt.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A verification probe (Phase 5) fails against a delivered name — signature drift between what v8 prescribed and what 357/360 landed | M | L | The probes are read-only (`lean_verify`, `example`-checks). On failure: record the exact mismatch, adjudicate whether it is a naming/doc issue (fix in 349's additive scope) or a semantic gap (DEFECT → `[BLOCKED]` + `/spawn 349`). Never re-prove in place. |
| The DoD alias `endInterval_correct` collides or misleads (a doc heading at CarrierK1V.lean:2097 already uses the name in prose) | L | L | The name is unclaimed as a declaration (grep-verified: no `theorem endInterval_correct` exists). Docstring the alias as the task-349 DoD name delegating to `endInterval_step_correct`; cross-reference both directions. |
| `Base.lean` doc edit accidentally changes semantics (it is a live module) | M | L | Doc-comment-only edits in the :958-1010 region; no declaration touched; scoped `lake build` of Base after the edit; `git diff` reviewed to be comment-only. |
| Downstream naming churn: 309/350 artifacts cite `endInterval_correct`/`endChar_correct` while the stack delivers `endInterval_step_correct` | M | M | Phase 6 makes the citable-name mapping explicit in `Base.lean` + the alias; Phase 8 name-level grep confirms reachability. Task-309/350 plan updates are THEIR revisions, not 349 scope — record the pointer in the summary. |
| Audit finds a guard violation inside a CONSUMED module | M | L | Consumed modules were audited green by their own tasks (355 Ph 8, 356, 357 Ph 6, 360 Ph 6). v9's Phase-7 audit is at the consumer seam (new v9 code + statement shapes). A defect in a consumed module is a DEFECT report → `/spawn`, never an in-place fix. |
| Fake green under pressure | H | L | PROHIBITED (Do-NOT 6); `[BLOCKED]` + evidence + `/spawn 349`. |

## Implementation Phases

**Dependency Analysis (wave map)**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2, 3, 4 | — (**preserved, COMPLETED**) |
| 1 | 5 | 1-4 (+ delivered 355/356/357/360) |
| 2 | 6, 7 | 5 (**parallel opportunity, H7**: Phase 6 edits `Base.lean` only; Phase 7 is read-only audit + plan/ledger — file-disjoint territories; an orchestrator MAY dispatch them concurrently under a territory contract) |
| 3 | 8 | 6, 7 |

**Per-phase hard bar (every open phase)**: ends GREEN + sorry-free (scoped `lake build` of any
touched module; whole-tree at Phase 8); `lean_verify` on the phase's headline decl(s) = exactly
`[propext, Classical.choice, Quot.sound]`; zero frozen-file diffs; guards + FORBIDDEN grep clean
in new code; commit per green sub-step (`task 349 phase {P}.{O}: …`); bounded-unit stop
condition stated per phase — on failure `[BLOCKED]` + exact evidence (`lean_goal` where
applicable) + `/spawn 349`, never fake green.

### Phase 1: General-`k` fold bridge `nf_eval_nfk_iff_efold` [COMPLETED]

- **Preserved asset — DONE + committed under v7. Do not re-plan or regress.** Green, sorry-free,
  axiom-clean at `NfEFold.lean:627` with index plumbing + k=1 recovery. The load-bearing fold
  characterization every consumed layer sits on.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` (frozen by convention).

### Phase 2: Depth-`k` bracket determinacy core (ExteriorBracketK.lean) [COMPLETED]

- **Preserved asset — DONE + committed under v7; FROZEN NO-EDIT file.** The determinacy core
  (`nfk_truncD` … `kvE_futAnyBit_zero`) consumed by the bracket layer. v7's in-module bracket
  attempt correctly failed; the clause layer was delivered by 352/354 and consumed in Phases 3-4.
- **Files:** `.../NfMultiAnchorBridge/ExteriorBracketK.lean` (FROZEN).

### Phase 3: Bracket `_sound` layer — D1 `kvE_extBracketFut_sound` + D2 `kvE_extBracketPast_sound` [COMPLETED]

- **Preserved asset — DONE + committed under v8** in `ExteriorBracketAssembleK.lean`, consuming
  the 352 `_sound` clause halves over `kvE_futAdmissible`, axiom-clean, frozen diffs empty.
- **Post-v8 provenance note:** task 360 Phase 3b subsequently RE-KEYED the bracket layer
  slice-wise (range = admissible ∧ fiber; `kvE_{fut,past}SliceMarked` marking) and RE-PROVED
  D1-D4 + gate/consumer/seam green (commit 51771ee42). The CURRENT statements
  (`ExteriorBracketAssembleK.lean:168/:190`) are the 360 versions — the completed work stands,
  under the faithful slice-keyed interface. The v8 "sanity interderivation with frozen k=2"
  deviation was retired by 360's Phase-6 k=2 audit (commit ac99927c6).
- **Files:** `.../NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` (now consume-only for v9).

### Phase 4: Bracket `_complete` layer — D3 `kvE_extBracketFut_complete` + D4 `kvE_extBracketPast_complete` [COMPLETED]

- **Preserved asset — DONE + committed under v8**, consuming the 354 `_complete` converters
  (bit-false arm) + 352 `_sound` (bit-true arm), threading the exterior realization interface
  outward; axiom-clean.
- **Post-v8 provenance note:** same 360 re-key as Phase 3 (current statements at `:224/:261`).
  The v8 `hreal`/`hsat` disclosure stands in updated form: the exterior realization obligations
  were restated slice-keyed by 360 and their m=0 instances are DISCHARGED by the 360 supply
  theorems; the general-m discharge is task 358's scope. Phase 7 records the full disposition.
- **Files:** `.../NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` (consume-only for v9).

### Phase 5: Adopt the delivered consumer stack — verification probes + DoD-name alias [COMPLETED]

> **RESUME POINT (v9).** The v8 Phases 5-7 RESUME POINT ("general-`k` interior correctness NOT
> delivered … ~700-1300 new proof lines") is STALE and superseded: tasks 355/356/357/360
> delivered that entire scope (see Overview + Consumed Stack). Phase 5 is now a bounded
> adoption/verification dispatch, NOT a construction dispatch.

- **Goal:** Machine-verify that the delivered stack satisfies the v8 Phase-5-7 DoD, and land the
  one-line DoD-named alias so the task-description name `endInterval_correct` is a real,
  citable declaration.
- **Verification probes (read-only; each a checklist item):**
  - [x] `lean_verify` (warm) on `endInterval_step_correct`, `EndIntervalCorrectPrior` (sorry
        scan), `endIntervalPrior`, `endIntervalStepPrior` — all sorry-free, axioms exactly
        `[propext, Classical.choice, Quot.sound]`.
  - [x] `lean_verify` on the CONSUMED dependencies `bracketEndChar_kv_correct_prior` (355,
        InteriorGateGeneralK.lean:1288) and `bracketEndChar_kvExt_correct_prior` (356,
        ExteriorGateAssembleK.lean:180) — cheap positive re-confirmation, recorded as CONSUMED.
  - [x] `example`-check the three `rfl` reductions of `endIntervalPrior` (k=0 singleton base;
        k=1 `bracketEndChar_kv … 1`; k=m+2 `bracketEndChar_kvExt … (Pfam m)`) — confirms the
        recursion is genuine and the dead `CarrierK1V` placeholder is NOT on the live path.
  - [x] Shape-match `EndIntervalCorrectPrior`'s m+2 arm against the v8 Phase-5 prescription:
        Prior-guarded (`h_UZ`/`h_SZ`); six order bits on `qnf.1`; provider threading
        (`P : ExistProviders`, `hcharK`); interior obligations `hreal`/`hexcl` at FULL arity 4
        (G1); anchors {x,t}, all witnesses bound (G2/G4); conclusion
        `holds ↔ ∃ w, nf_eval_nf M (m+2) 3 [w,x,t] qnf`. Record the delta vs the 355
        seven-obligation interface: `hexclExt` INTERNALIZED (356); exterior residue carried as
        the four slice-keyed obligations (360). Confirm the k=2 rung is the m=0 member (no
        special case needed — the 360 Phase-6 k=2 audit is the standing witness).
- **Build (additive, ~10-30 lines):**
  - [x] Append the DoD-named alias to `EndIntervalConsumerK.lean`:
        `theorem endInterval_correct … : ∀ k, EndIntervalCorrectPrior atomMap h_surj charF Pfam k := endInterval_step_correct …`
        with a docstring binding it to the task-349 definition of done and cross-referencing
        `endInterval_step_correct` (grep-verified unclaimed as a declaration name; the
        CarrierK1V.lean:2097 occurrence is prose in a doc heading, not a decl).
  - [x] `lean_verify endInterval_correct` axiom-clean; scoped `lake build` of
        `EndIntervalConsumerK` GREEN.
- **Reuse vs rebuild:** REUSE everything (the entire stack). BUILD only the alias + probe
  `example`s (which may live in the additive tail as documented `example`s or be run ephemerally
  via `lean_multi_attempt`/`lean_run_code` — implementer's choice; if landed, keep ≤ ~40 lines).
- **Bounded-unit stop condition:** all probes pass + alias green, OR a probe fails → record the
  exact mismatch (`lean_goal`/hover evidence), adjudicate doc-vs-semantic, and either fix within
  349's additive scope (naming/doc) or `[BLOCKED]` + `/spawn 349` (semantic). Fixed, finite
  attempt surface: the probe list above is exhaustive; no open-ended proving.
- **Estimated output:** ~30-80 lines (alias + optional landed examples + probe log).
- **Timing:** ~1.5 hours.
- **Done when:** all probes recorded green; `endInterval_correct` landed, sorry-free,
  axiom-clean; frozen diffs EMPTY; scoped build GREEN.
- **Depends on:** 1-4 (preserved) + delivered 355/356/357/360.
- **Files:** `.../NfMultiAnchorBridge/EndIntervalConsumerK.lean` (additive tail only).

### Phase 6: Re-point the `Base.lean` doc-hook + downstream citability [COMPLETED]

- **Goal:** Retire the stale "NOT YET BUILT" documentation that task 349's own mission statement
  points at, so downstream consumers cite the delivered names.
- **Tasks:**
  - [x] Update the `Base.lean` :958-969 doc block ("The remaining Phase-8 deliverable, the
        *recursive* primitive `endChar` … is NOT built here") — doc-comment-only edit: record
        that the recursive primitive is DELIVERED as `endIntervalPrior` +
        `endInterval_correct`/`endInterval_step_correct`
        (`EndIntervalConsumerK.lean`), via the consumed chain
        `bracketEndChar_kv_correct_prior` (355) → `bracketEndChar_kvExt_correct_prior` (356) →
        consumer (357), under the slice-keyed exterior interface (360). *(deviation: altered —
        also re-tensed the adjacent :950 "Phase 7 … is not yet built" sentence in the same doc
        block to past tense with a pointer to the delivery, so no stale not-built claim about
        the 349 deliverable remains; and dropped the old text's `nf_char3_deeper_split` mention
        so the rewritten block adds zero occurrences of the FORBIDDEN name)*
  - [x] Record the settled carrier mapping at the `EndCharCarrier` abbrev (Base.lean:1007
        region, doc-comment): the original `NormalForm sig k 3 → TemporalPred` interface was
        superseded by `BracketEndCharCarrierV` (carrier 3, VVecEA2-valued, two fixed anchors
        {x,t}) — the report-09 adjudication — and `endChar0` remains the k=0 atom-layer
        ingredient consumed via `bracketEndChar_k0`.
  - [x] Name-level citability grep for task 309 Phase 18/19 / task 350: confirm
        `endInterval_correct`, `endInterval_step_correct`, `EndIntervalCorrectPrior`,
        `endIntervalPrior` resolve from the root build (aggregator already threads
        `EndIntervalConsumerK` — NfMultiAnchorBridge.lean:56). *(verified: declarations at
        EndIntervalConsumerK.lean:220/:185/:97/:70; aggregator import at
        NfMultiAnchorBridge.lean:56; aggregator module builds green)*
  - [x] Scoped `lake build` of Base (+ anything importing the edited region) GREEN; `git diff`
        on Base.lean reviewed comment-only. *(verified: `lake build
        Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` GREEN, 1033 jobs; diff
        touches zero declaration/import lines; new `nf_char3_deeper_split` occurrences in
        added lines = 0; `hbr*` grep clean)*
- **Bounded-unit stop condition:** doc edits land + build green, OR `[BLOCKED]` (doc edits
  cannot semantically block; any build breakage means a non-comment edit slipped in — revert
  and redo).
- **Estimated output:** ~40-100 lines (doc-comment text).
- **Timing:** ~1 hour.
- **Done when:** no stale "NOT built" claim about the 349 deliverable remains in Base.lean;
  citable names documented; build GREEN; frozen diffs EMPTY.
- **Depends on:** 5. **Parallel with 7 (H7 territory: Base.lean is Phase 6's exclusive file).**
- **Files:** `.../NfMultiAnchorBridge/Base.lean` (doc-comment edits only).

### Phase 7: Obligation-disposition ledger + consumer-seam guards audit [COMPLETED]

- **Goal:** Produce the binding record of which obligations remain hypothesis-side (and where
  each is discharged), and run the guards/route audit over the v9 seam. This realizes the v8
  Phase-7 "document precisely which obligations remain hypothesis-side" item — the recursion
  close itself is delivered (357).
- **The 11-obligation ledger (drafted here; implementer verifies each row against source and
  records it in the summary + a doc-comment near the Phase-5 alias):**

  | # | Obligation (m+2 arm) | Status in the deliverable | Discharge site |
  |---|---------------------|---------------------------|----------------|
  | 1 | `P : ExistProviders … (m+1)` | hypothesis-side | 309 Phase 14 (`nf_nvar_exist_all_depths`, KampPrior NO-EDIT) |
  | 2 | `hcharK` (char/provider agreement) | hypothesis-side | 309 Phase 14 |
  | 3-4 | `h_UZ` / `h_SZ` (Prior) | hypothesis-side | Prior-guarded by design (KampPrior supplies) |
  | 5 | `hreal` (interior realization, arity 4) | hypothesis-side | task 358 (realization recursion, KampPrior:361/364) |
  | 6 | `hexcl` (within-`[x,t]` exclusion) | hypothesis-side | task 358 |
  | 7 | `hexclExt` | **DISCHARGED INTERNALLY** (356, `bracketEndChar_kvExt_correct_prior` ⇒-side guard split) | n/a — not a binder of `EndIntervalCorrectPrior` |
  | 8-9 | `hslicePast` / `hsliceFut` (⇐-side slice honesty, fiber-guarded) | hypothesis-side | m=0: DISCHARGED (360 `kvE_h{slice…}_supply_zero`); general m: task 358 |
  | 10-11 | `hexclSlicePast` / `hexclSliceFut` (⇒-side slice exclusion residue) | hypothesis-side | m=0: DISCHARGED (360); general m: task 358 |

  Also record: the v8-era `hreal`/`hsat` EXTERIOR interface and the 356-era `hbr*` binders are
  RETIRED — replaced by rows 8-11 (360 re-key; `hbr*` grep = 0 repo-wide is an audit item).

  *(Phase 7 execution note: all 11 rows verified against source binder-by-binder
  (EndIntervalConsumerK.lean:97-170 — rows 1-6 at :114/:115/:117/:119/:125; row 7 confirmed NOT
  a binder at the 16-argument call site :205-207; rows 8-11 at :141/:148/:155/:162 with fiber
  guards `nfk_dropFresh σ = qnf.1` at :144/:151) and all four m=0 supply theorems confirmed at
  their exact sites (ExteriorPinnedConverseK.lean:1301/:1242, ExteriorPinnedConversePastK.lean:
  822/:769). The ledger is RECORDED as a doc-comment immediately after the Phase-5 alias
  `endInterval_correct` in EndIntervalConsumerK.lean (task 349 Phase 7 section), with row-5/6
  discharge pointers recording BOTH the in-source KampPrior:352-360 fencing (309 Phase 14
  provider instantiation) and the 358 realization-recursion assignment as complementary inputs
  to the same retirement. Scoped build GREEN post-edit (1031 jobs); diff comment-only.)*
- **Guards/route audit (read-only over v9 seam + new code):**
  - [x] FORBIDDEN grep over all v9-touched files: `nf_char3_deeper_split` = 0; new
        `nfk_projFresh` = 0; `hbr` identifiers = 0 repo-wide; no Boneyard import.
        *(verified: 0 new `nf_char3_deeper_split` in v9-added lines — EndIntervalConsumerK = 0
        total; Base.lean's 7 occurrences are pre-existing historical documentation, count went
        8→7 across v9; `nfk_projFresh` = 0 in both v9-touched files; eliminated `hbr*` binder
        family (`hbrFut`/`hbrPast`/`hbrFutSat`/`hbrPastSat`) = 0 live binders repo-wide, 2
        doc-prose retirement mentions only — matches 360's audit criterion verbatim; no Boneyard
        import in either v9-touched file — the pre-existing Boneyard importers Prop43.lean /
        NavigatedEndChar.lean are unimported dead leaves, unchanged by v9)*
  - [x] G1-G5 spot-audit of the alias + `EndIntervalCorrectPrior` statement (arity-4 interior
        binders; anchors {x,t}; bound witnesses; non-trivial segments; no chain-step shortcut in
        any v9 code). *(verified: `hreal`/`hexcl`/`hexclSlice*` interior obligations at FULL
        arity 4 — `NormalForm sig (m+1) 4` over the 4-anchor `Fin.cons x1 (Fin.cons w (Fin.cons
        x (fun _ => t)))` vector (G1); free anchors of the m+2 conclusion exactly {x,t}, `w`
        existentially bound, `x1`/`σ`/`σ'` bound within obligation binders (G2/G4); no
        `TemporalPred.top` in EndIntervalConsumerK.lean (G3); v9-added code is term-mode +
        `rfl` only — zero tactics, no `simp`/`omega`/`aesop` chain-step (G5); `lean_verify
        endInterval_correct` re-run post-ledger: axioms exactly `[propext, Classical.choice,
        Quot.sound]`, no warnings)*
  - [x] `git diff` on all FROZEN/consume-only files EMPTY across the whole v9 range;
        `nf_nvar_exist_all_depths` signature untouched. *(verified: committed v9 range
        `fb6e5b7af^..HEAD` touches exactly the two v9-editable files — Base.lean +
        EndIntervalConsumerK.lean; working-tree Theories/ diff = the Phase-7 ledger doc-comment
        only, 27 inserted comment lines, zero non-comment changed lines; 0 diff hits on
        `nf_nvar_exist_all_depths`)*
  - [x] Sorry census: the only in-tree sorries on the Kamp path remain `KampPrior.lean:361/364`
        (+ the :639-adjacent documented strategic site), all fenced to task 358 / their
        follow-up tasks — NONE attributable to 349; zero sorries in any v9-touched file.
        *(deviation: altered — census-precision correction. Actual census (script +
        grep-confirmed): FOUR non-Boneyard sorry tokens on the Kamp path — `KampPrior.lean:361`
        (in-source :352-360 fencing note binds retirement to task 309 Phase 14's provider
        instantiation consuming the 348 gate; the realization-recursion component is task 358
        per the 349/357/358 chain — complementary inputs to the same retirement),
        `KampPrior.lean:364` (n≥2 arm, off the critical path; GO-k1 routing note :628-643 —
        the ":639-adjacent site" is that prose routing note, not an additional sorry token),
        PLUS the pre-existing pair `EANegation.lean:1090/:1249` — both present at the v9 base
        commit, documented in-file as non-blocking inherent BracketFormula-level limitations
        ("does NOT block completeness"; resolution via `neg_bounded_exists` in
        EANegationClosure), on the live import path via Base.lean:4 but in no 349-touched file
        of any plan version. The binding Phase-7 bar holds unweakened: NONE attributable to
        349; ZERO sorries in any v9-touched file.)*
- **Bounded-unit stop condition:** ledger verified row-by-row + audit greps clean, OR a RED
  finding → route to the owning task as a DEFECT (`/spawn 349` if it blocks 349's DoD), never
  patched ad hoc.
- **Estimated output:** ~20-60 lines (doc-comment ledger + audit log in the summary).
- **Timing:** ~1 hour.
- **Done when:** ledger recorded (doc-comment + summary); all audit items green.
- **Depends on:** 5. **Parallel with 6 (H7: no file overlap — Phase 7's only possible write is
  the `EndIntervalConsumerK.lean` doc-comment ledger, coordinated with the Phase-5 tail it
  extends; if dispatched concurrently with 6, declare that file Phase 7's territory).**
- **Files:** `.../NfMultiAnchorBridge/EndIntervalConsumerK.lean` (doc-comment ledger, additive)
  + this plan + audit log.

### Phase 8: Final whole-tree gate + summary [COMPLETED]

- **Goal:** Confirm every definition-of-done gate on the assembled result; wrap up. No new
  source code.
- **Tasks:**
  - [x] Whole-project `lake build` GREEN. *(verified: `Build completed successfully
        (1736 jobs)`, exit 0; pre-existing `sorryAx` dependence in
        `Bimodal.Metalogic.BXCanonical.completeness` is off the Kamp path, in no 349-touched
        file — not a 349 gate)*
  - [x] `lean_verify` (warm) final list — 349 deliverables: `endInterval_correct` (alias),
        `endInterval_step_correct`, `endIntervalPrior`, `endIntervalStepPrior`,
        `EndIntervalCorrectPrior`; CONSUMED (not rebuilt) dependencies:
        **`bracketEndChar_kv_correct_prior`** (355), `bracketEndChar_kv_step_correct` (355),
        `bracketEndChar_kvExt_correct_prior` (356), D1-D4
        (`kvE_extBracket{Fut,Past}_{sound,complete}`, 360-re-keyed) — all exactly
        `[propext, Classical.choice, Quot.sound]`, no sorry, no new axiom. *(verified: all 12
        targets returned exactly `["propext","Classical.choice","Quot.sound"]` with zero
        warnings; new-axiom count 0 — the two `^axiom` grep hits are prose lines in Boneyard
        files, unchanged since the v9 base)*
  - [x] Record the `hreal`/`hexcl`/`hexclExt`/slice disposition (the Phase-7 ledger) in the
        summary — obligations are a documented THREADED interface with named discharge sites
        (356 internal / 360 m=0 / 358 / 309 Phase 14), never debt. Explicitly note the v8-era
        `hsat` and `hbr*` names are retired (360). *(recorded in the summary §Obligation
        disposition, mirroring EndIntervalConsumerK.lean:228-253)*
  - [x] FORBIDDEN grep + frozen-file `git diff` EMPTY re-check across the whole v9 range.
        *(verified: `nf_char3_deeper_split` = 0 in EndIntervalConsumerK (Base.lean's 7 are
        pre-existing historical prose); `nfk_projFresh` = 0 in both v9 files; eliminated
        `hbr{Fut,Past}(Sat)` family = 0 live binders repo-wide (1 doc-prose retirement
        mention); no Boneyard import; `git diff fb6e5b7af^..HEAD` over all 16+ frozen/
        consume-only files EMPTY; `nf_nvar_exist_all_depths` (KampPrior.lean:212) untouched —
        all 13 range-diff mentions are plan/doc prose; working tree clean)*
  - [x] Finalize the H3 mapping STATUS column (all rows transcribed/consumed); confirm
        `endInterval_correct` reachable/citable for 309 Phase 18/19 / 350 (name-level grep from
        the root build). *(verified: H3 final row updated above; reachability chain
        `EndIntervalConsumerK` → `NfMultiAnchorBridge.lean:56` → `KampPrior.lean` → root
        build (whole-tree job set); `Base.lean:991` doc-hook cites the alias by name)*
  - [x] Write `summaries/09_consume-interior-gate-general-k-summary.md`; hand off the
        completion pointer set for 309/350 (which names to cite, which obligations they must
        supply, and that 358 is the discharge task). *(written)*
- **Bounded-unit stop condition:** verification-only; any RED finding routes back to the owning
  phase (or task) as a defect — never patched ad hoc here.
- **Estimated output:** ~0-40 lines (docstring/plan edits) + summary artifact.
- **Timing:** ~0.5 hours.
- **Done when:** all gates pass; summary written; task 349 completable.
- **Depends on:** 6, 7.
- **Files:** none (verification) + this plan + summary.

## Testing & Validation

- [x] Scoped `lake build` GREEN after every open phase; whole-tree GREEN at Phase 8.
      *(Phase 8: whole-tree `Build completed successfully (1736 jobs)`)*
- [x] `lean_verify` on every 349 headline decl AND the consumed 355/356 gates = exactly
      `[propext, Classical.choice, Quot.sound]`; zero sorries in v9-touched files; no new axiom.
      *(all 12 targets clean, zero warnings; Kamp-path census unchanged from Phase 7: 4 tokens,
      all fenced to 358 / 309 P14 / EANegation pre-existing — none attributable to 349)*
- [x] The three `endIntervalPrior` `rfl` reductions confirmed (`example`-checked) — the
      recursion is genuine; the dead `CarrierK1V` `⟨[]⟩` placeholder is off the live path.
      *(landed as documented `example`s, EndIntervalConsumerK.lean:255-277; compile in the
      green whole-tree build)*
- [x] `EndIntervalCorrectPrior` m+2 arm shape-matched to the v8 prescription: Prior-guarded, six
      order bits, provider-threaded, interior obligations at FULL arity 4 (G1), anchors strictly
      {x,t} with all witnesses bound (G2/G4), non-trivial segments (G3); `hexclExt` internalized
      (356); exterior residue slice-keyed (360). *(Phase 5 verified; Phase 7 audited G1-G5)*
- [x] Obligation ledger verified row-by-row with named discharge sites; recorded in doc-comment
      + summary; never presented as debt. *(EndIntervalConsumerK.lean:228-253 + summary §3)*
- [x] FORBIDDEN greps clean: `nf_char3_deeper_split` = 0 in new code; new `nfk_projFresh` = 0;
      `hbr` identifiers = 0 repo-wide; no Boneyard import. *(Phase 8 re-check: eliminated
      `hbr{Fut,Past}(Sat)` family 0 live binders repo-wide, 1 doc-prose mention)*
- [x] `git diff` EMPTY on all FROZEN/consume-only files across the whole v9 range;
      `nf_nvar_exist_all_depths` signature unchanged; KampPrior untouched by 349.
      *(range `fb6e5b7af^..HEAD` touches exactly Base.lean + EndIntervalConsumerK.lean)*
- [x] `endInterval_correct` (+ `endInterval_step_correct`) top-level citable from the root build
      for task 309 Phase 18/19 / task 350; `Base.lean` doc-hook carries no stale "NOT built"
      claim about the deliverable. *(import chain to root confirmed; Base.lean:991 doc-hook
      re-pointed by Phase 6)*
- [x] No single-point `↔` goal shape, no `h_res`, no arity collapse anywhere in v9 code (the
      standing STOP signals). *(Phase 7 seam audit; no v9 code added since)*

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean`
  — additive tail: the DoD alias `endInterval_correct` + optional probe `example`s (Phase 5) +
  the obligation-disposition doc-comment ledger (Phase 7).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — doc-comment
  edits re-pointing the stale "NOT YET BUILT" hook at the delivered stack (Phase 6).
- `specs/349_.../plans/09_consume-interior-gate-general-k.md` (this plan; supersedes v8
  plans/08).
- `specs/349_.../summaries/09_consume-interior-gate-general-k-summary.md` (on completion —
  includes the obligation ledger + downstream citation pointers for 309/350/358).

## Rollback/Contingency

- All v9 work is additive (an alias/doc tail + doc-comment edits); no green asset can be lost by
  a v9 rollback. Snapshot before any intentional rollback
  (`bash .claude/scripts/git-snapshot.sh` first).
- Commit-per-green-substep mandate: every verified-green sub-step is committed as it lands.
- **Per-phase feasibility gate**: any residual item that cannot close green without a forbidden
  construct is `[BLOCKED]` + exact evidence + `status: partial` + `requires_user_review: true`
  + `/spawn 349` — never a fake green. Because the entire construction scope is DELIVERED
  (355/356/357/360, all committed at or before HEAD 9d59c9716), every plausible v9 block is a
  naming/doc/audit issue or a defect in a consumed module (→ DEFECT report + spawn), never open
  mathematics.
- If a Phase-5 probe reveals the delivered consumer does NOT satisfy 349's DoD in a semantic way
  (not naming/doc), 349 goes `[BLOCKED]` with the exact probe evidence and a `/spawn 349`
  scoping the minimal repair — the consumed modules are not edited in 349 scope.
