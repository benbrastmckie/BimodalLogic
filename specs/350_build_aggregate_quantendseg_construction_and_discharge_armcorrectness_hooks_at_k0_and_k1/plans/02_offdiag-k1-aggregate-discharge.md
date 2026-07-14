# Implementation Plan: Task #350 (v2 — off-diagonal k=1 primitives integrated)

- **Task**: 350 - build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1
- **Status**: [IN PROGRESS] (Phases 1-6 completed — v1 delivered scope, 4/6 DoD lemmas green; Phases 7-17 not started)
- **Effort**: 25 hours (~8 delivered in v1 scope + ~17 remaining across Phases 7-17)
- **Dependencies**: Task 349 (COMPLETED — `endInterval_correct` stack). COORDINATION: task 358 is
  concurrently implementing in `KampPrior.lean` and `ExteriorPinnedConverseK.lean` /
  `ExteriorPinnedConversePastK.lean` — NO phase of this plan may touch those three files (guard G6).
- **Research Inputs**: specs/350_.../reports/02_offdiag-k1-primitives.md (this revision's driver);
  specs/309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md;
  specs/309_offdiag_two_anchor_fi_chain/reports/02_endpoint-hook-discharge-research.md (§6 Phase 9);
  specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json (P18b-endChar-recursive-core-unbuilt)
- **Artifacts**: plans/02_offdiag-k1-aggregate-discharge.md (this file; supersedes
  plans/01_aggregate-quantend-hook-discharge.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v1 delivered 4 of the 6 DoD hook-discharge lemmas green (`kampArm_past_k0`, `kampArm_diag_k0`,
`kampArm_future_k0`, `kampArm_diag_k1`, plus the k=0 aggregate carriers and the gated depth-1
anchor-collapse seam), commits d0f3a4484..e8e86b419 (+05d183fd6). The remaining pair
`kampArm_past_k1`/`kampArm_future_k1` was blocked (blk-350-p4-offdiag-k1-aggregate) on three
missing primitives. Hard-mode research (report 02, Rabinovich-2014 Tier-1 grounded) has adjudicated
all three as buildable:

- **P1** `VVecEA2.conjFull` — Lemma 3.2(1)/3.4 conjunction closure in FULL IFF form, via a
  snoc-recursive construction (`BracketFormula.snoc` + `snoc_holds_iff` + last-witness trichotomy
  recursion); merged point types conjoined with the OTHER bracket's ambient segment type. Order-
  generic, no model hypotheses. ~400-700 lines.
- **P2** syntactic negation closure — RESTATED (H4) to the full general-n gated Lemma 5.1/5.3/
  Cor 5.4 stack over attained-INF/SUP structures (the `Cond_i` case gates are load-bearing; the
  gate-free form has a ℤ counterexample worth landing as a Lean `example`). Includes the missing
  `HasAttainedSUP` mirror (~50 lines). ~1,200-1,800 lines, split across Phases 8-11.
- **P3** per-qnf k=1 zone carriers — interior channel already green
  (`bracketEndChar_kv_correct_one_prior`, instantiation-only); point channels via new (0,1)/(0,2)
  merge variants of the delivered gated-collapse; exterior channels via a new 7-zone-fiber
  Since/Until-navigated kv_body-style module (~800-1,200 lines + mirror).

Dependency chain: P1 → P2 → P3 → `aggPop1` (conjFull-fold over `Finset.univ` with `negFix` on
bit-false qnf) → `kampArm_past_k1`/`kampArm_future_k1` via `translateRight`/`Left`, exactly like
the delivered Phase 3 glue. Phases 7 (conjFull) and 12 (point-channel merges) are file-disjoint
and parallelizable (H7 territory). Definition of done: all six `kampArm_*` lemmas green, axioms
exactly `[propext, Classical.choice, Quot.sound]`, sorry-free, zero-debt, full tree builds.

### Research Integration

- **reports/02_offdiag-k1-primitives.md** (integrated in this v2, 2026-07-13): H3 5-column
  Rabinovich lemma mapping table with exact proposed Lean signatures; root cause per primitive
  (conj_struct designed one-directional; Boneyard NegationIndep backward failure = missing
  `Cond_i` gates, not a mathematical obstruction; k=1 members must be carried per-qnf whole,
  split by w-zone channel); worked n=1 gate-complete negation disjunct list {A, B1, B2, B3, B4,
  B4′} with the ℤ counterexample refuting the gate-free 4-list; 6-phase A-F wave shape adopted
  below (with P2 split for H8 phase sizing); refuted-route check confirming none of the four
  machine-refuted v1 routes is re-proposed.
- v1's research inputs (309 reports 08/02, handoff blocker) remain integrated; the delivered-name
  map and binding guards carry over unchanged.

`reports_integrated`: `["02_offdiag-k1-primitives.md"]` (v1 integrated the 309-side inputs).

### Prior Plan Reference

Supersedes `plans/01_aggregate-quantend-hook-discharge.md` (v1). All v1 completed work is
preserved as Phases 1-6 below (content carried over verbatim-in-substance, including deviation
annotations). v1's blocked Phase-4/5 off-diagonal remainder is re-planned as Phases 7-17 per
report 02. Effort calibration: v1's six phases delivered ~2,170 lines in AggregateHookDischarge
across 7 commits; the remaining primitives total ~3,100-4,900 lines, so phases below are sized to
one agent run each (~100-500 lines output, pre-declared H8 seams where an estimate straddles the
bound).

### Roadmap Alignment

No roadmap_path provided in the delegation context. This task advances the Kamp's theorem
formalization track (parent task 309, topic `kamp_theorem_formalization`).

### Literature Grounding (--lit)

Per-repo sub-index resolved (SUBINDEX_PRESENT). Ground truth, navigate on demand:
- **Rabinovich 2014, "A Proof of Kamp's Theorem"** —
  `/home/benjamin/Projects/Literature/sources/rabinovich_2014/` (1 chunk, ~2,721 tokens).
- **Kamp 1968** — `/home/benjamin/Projects/Literature/sources/kamp_1968_tense-logic-linear-order/`
  (background only; Rabinovich 2014 is the implementation source).
- Search: `bash .claude/scripts/literature-search.sh "<query>"`.

**Rabinovich grounding table** (carried from report 02, H3 Tier 1; G5 applies — no
simp/omega/aesop shortcut of any chain step):

| Paper source | Content | Lean target (phase) |
|---|---|---|
| Lemma 3.2(1) (chunk_0009 md:11-13) | Conjunction of →∃∀-formulas ≡ disjunction of →∃∀-formulas; interleavings-with-coincidences; merged points take conjoined point types PLUS the other bracket's ambient segment type | `BracketFormula.snoc(_holds_iff)`, `BracketFormula.conjFull(_iff)` (Phase 7) |
| Lemma 3.4 (chunk_0010 md:3-5) | ∨→∃∀ closed under ∨, ∧, ∃ | `VVecEA2.conjFull(_iff)` (Phase 7) |
| Dedekind inf/sup, attained surrogate | Codebase replaces Dedekind completeness by `HasAttainedINF` (from `semantic_prior_UZ`); K+ limit disjuncts vacuous | `HasAttainedSUP` + `prior_hasAttainedSUP` mirror (Phase 8) |
| Lemma 5.3 (chunk_0014 md:3-41) | ¬∃-chain On-builder; induction on n; disjuncts = never-P / K+ (vacuous here) / attained-inf pin | `negChainOn(_iff)` (Phase 8) |
| Cor 5.4(1)/(2) (chunk_0014 md:49, chunk_0015 md:3-43) | ¬(∃z∈(z0,z1))[…](z0,z) ≡ ∨→∃∀ + mirror; F_i Until/Since-definable predicates; mirror needs attained SUP | `negBounded{Right,Left}Fix(_iff)` (Phase 9) |
| Prop 4.2 / Lemma 5.1 (chunk_0012 md:3, chunk_0013 md:29-33, chunk_0016 md:5) | Fixed-formula negation: output is `∨_i (Cond_i ∧ Form_i)` — the case gates RIDE IN the disjuncts | `BracketFormula.negFix(_iff)` (Phase 10), `VecEA2/VVecEA2.negFix(_iff)` (Phase 11) |
| Def 4.1 canonical expansion E[Σ] (chunk_0011 md:5,15-17) | →∃∀ atoms may be TL-definable predicates | Already structurally present (`TemporalPred` = arbitrary `Formula`; `temporal_truth` natively interprets `.untl`/`.snce`, Table.lean:182-194) — architectural note only |
| Lemma 3.2(2) + Prop 3.5 (chunk_0010 md:11-15) | ≤2-free-variable split; ∃-witness → Until/Since folding | P3 carriers: point merges (Phase 12), exterior navigated package (Phases 13-15) |
| Cor 5.4 "all order patterns" clause | The aggregate population match | `aggPop1(_correct)` + arm assembly (Phase 16) |

## Delivered-Name Map (BINDING — consume by these names)

Carried from v1 unchanged. Task 349 delivered the endpoint recursion under these names (the
`CarrierK1V.lean` pair `endIntervalStep`/`EndIntervalCorrect` is superseded dead code — do NOT
cite it):

| Task-description name | Delivered name | Location |
|---|---|---|
| `endChar_correct` (DoD alias) | `endInterval_correct` | EndIntervalConsumerK.lean:220 |
| recursion consumer | `endInterval_step_correct` | EndIntervalConsumerK.lean:185 |
| recursion carrier | `endIntervalPrior` | EndIntervalConsumerK.lean:70 |
| correctness motive | `EndIntervalCorrectPrior` | EndIntervalConsumerK.lean:97 |
| k=0 interior rung | `bracketEndChar_kv_correct_zero_prior` | PriorInterface.lean:80 |
| k=1 interior rung (`h0` only) | `bracketEndChar_kv_correct_one_prior` | PriorInterface.lean:95 |
| `seg_holds_coupled` | `seg_holds_coupled` (unchanged) | Base.lean:1182 |
| `nf_zone_flatten_navigable_correct` | same (current line) | Base.lean:687 |
| zone-triage house style | `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable.lean:188 |

**v1-delivered names now also binding** (task-350 assets, consume — never rebuild):

| Asset | Location |
|---|---|
| `agg2Past`/`agg2Fut`/`agg2Diag` + `agg2Past_holdsRight_iff`/`agg2Fut_holdsLeft_iff`/`agg2Diag_iff` | AggregateHookDischarge.lean |
| `kampArm_{past,diag,future}_k0(_correct)`, `kampArm_diag_k1(_correct)` + shape certificates | AggregateHookDischarge.lean |
| gated collapse: `agg_rename_fixpoint_of_eval` (:1853), `agg_diag_collapse_k1` (:1907), `aggMerge32`, `aggDiagGateK1`/`aggPosDiagK1(_correct)` | AggregateHookDischarge.lean |
| depth-1 fold engine (arity-generic, lossless iff) | `nf_eval_depth1_fold_iff`, CarrierKv.lean:466 |
| translation glue | `VVecEA2.translateRight(_correct)` NfToVecEA.lean:447/451; `VVecEA2.translateLeft(_correct)` VecEATranslation.lean:541/549 |
| attained INF | `HasAttainedINF` (PriorINF.lean:202), `prior_hasAttainedINF` (:226, from `semantic_prior_UZ`) |
| Boneyard salvage (forward plumbing only) | `Boneyard/NegationIndep.lean` (disjunct plumbing + forward correctness; contents change by adding gates) |

At k=0 and k=1 the 349 recursion reduces by `rfl` (EndIntervalConsumerK.lean:266-271); the k=1 arm
carries ONLY `h0 : charF 0 = nf_depth0_char_formula atomMap h_surj`, dischargeable by construction
by choosing `charF 0 := nf_depth0_char_formula atomMap h_surj` at instantiation. No m+2-arm
obligation enters this task's scope.

## Goals & Non-Goals

**Goals**:
- Land the three missing primitives P1-P3 exactly as adjudicated by report 02 (signatures in the
  H3 mapping table are the binding statement shapes; deviations must be recorded inline).
- Build the off-diagonal k=1 aggregate `aggPop1(_correct)` (conjFull-fold over
  `(Finset.univ : Finset (NormalForm sig 1 3)).toList` with `negFix` on bit-false qnf).
- Discharge the final two DoD lemmas `kampArm_past_k1(_correct)` / `kampArm_future_k1(_correct)`
  in the skeleton shape (`temporal_truth M atomMap t A ↔ <trichotomy disjunct>` under
  `h_UZ`/`h_SZ` at most), with shape certificates, mirroring the delivered Phase-3 glue.
- Keep everything additive: new leaf modules + aggregator import lines + docstring-only doc-hooks;
  task 309 Phase 18b/19 can cite every deliverable by name.

**Non-Goals**:
- NO edit to `KampPrior.lean` (any part — task 358 territory AND task 309's Phase 19 edit).
- NO edit to `ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean` (task 358 is
  implementing there concurrently — guard G6).
- NO edits to the seven frozen provider files: SharedWitness.lean, SubBracket2V.lean,
  OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation(K).lean,
  ExteriorNegationPast(K).lean (read/consume only).
- NO rebuild of `endInterval_correct`, `seg_holds_coupled`, `nf_zone_flatten_navigable_correct`,
  the v1-delivered agg2/kampArm assets, or any 355/356/357/360 stack asset.
- NO modification of the delivered `AggregateHookDischarge.lean` lemmas/definitions (additive
  appends to that file are allowed ONLY if a phase below explicitly says so; default is new
  modules).
- NO k≥2 arm work (m+2 obligations route to task 358 / 309 Phase 14 per the 349 ledger).
- NO use of `nf_char3_deeper_split` (FORBIDDEN — Base.lean:603; refuted tower).
- NO re-attempt of the four machine-refuted v1 routes: `conj_struct`-based aggregation,
  `neg_2var_vec_ea` for syntactic use, depth-2 fold re-fibering (F1), gated anchor-collapse at
  the x/t pair off-diagonal. (Report 02's refuted-route check: `conjFull` is a different object;
  `negFix` is a fixed formula with model hypotheses only in the correctness proof; `fold_iff` is
  used only at depth 1; the collapse is used only for w=x/w=t where the duplicated anchor
  genuinely exists.)

## Binding Guards (inherited from v1 + G6)

- **G1** — no arity-1 collapse: every population obligation stays the honest arity-3
  `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` on the full env.
- **G2/G4** — anchors strictly `{x, t}` (≤2 cap); `w` and every interior point are bracket
  witnesses, never a third free anchor.
- **G3** — non-trivial segments: reuse the landed `seg`/carrier bracket content; never
  `TemporalPred.top` as the off-diagonal interval type.
- **G5** — no `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step; manual bridges
  (`constructor`/`intro`/`exact`) at every Lemma 3.2/3.4/5.1/5.3/Cor 5.4 step.
- **G6 (NEW — task-358 territory)** — zero hunks in `KampPrior.lean`,
  `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean` in any commit of this task.
  Verified per phase via `git diff --stat`.
- **FORBIDDEN**: `nf_char3_deeper_split`; resurrection of retired interfaces (`hbr*` family,
  `bracketEndChar_kvE'_correct*`, the dead `CarrierK1V` `endIntervalStep`/`EndIntervalCorrect`).
- **Axioms**: every new lemma `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`.
- **Sorry-free / zero-debt**: no sorry, no vacuous defs (`def X := True` etc.); if a sub-piece
  cannot close green, mark the phase [BLOCKED] with the exact obstruction and escalate — do not
  land debt.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: `conjFull` recursion (on `n1+n2`, `termination_by`, 3-way last-witness trichotomy) is combinatorially fiddly; base cases `(0,n)`/`(n,0)` must conjoin the 0-bracket's segment type into ALL point AND segment types (exactly where `conj_struct` diverges from the paper) | H | M | Phase 7 starts with the self-contained probes report 02 recommends: `snoc_holds_iff` (~60 lines) and the segment-gluing lemma before any recursion; the recursion cases follow Lemma 3.2(1) verbatim (G5) |
| R2: P2 backward-cover proofs (the `Cond_i` gate device) are the report's Medium-High-confidence claim — the one non-machine-checked pillar | H | M | Phase 10 lands the ℤ B4-counterexample `example` AND one gated-disjunct backward lemma as its FIRST probes; if the n=1 gate-complete list {A,B1,B2,B3,B4,B4′} cover proof fails, mark [BLOCKED] with the failing disjunct and escalate — the general recursion is not attempted before the n=1 instance is green |
| R3: Exterior navigated carrier (Phases 13-15) rests on a structural argument (fiber partition by w-dependence; t-reads peeled to endpointRight before folding) that is verified by file reads, not machine-checked (report confidence: Medium) | H | M | Phase 13's first task is an adjudication probe: encode ONE bit-true and ONE bit-false fiber end-to-end for a single concrete qnf before generalizing; on failure, mark [BLOCKED] with the exact fiber and qnf pattern |
| R4: Disjunct-count growth in conjFull folds (Delannoy-like) → elaboration blowup at Phase 16's `Finset.univ` fold | M | M | Carriers are noncomputable proof objects (k=0 precedent); fold induction over `conjFull_iff` never normalizes disjunct lists; raise `maxHeartbeats` locally (EndIntervalConsumerK.lean:174 precedent 1600000) |
| R5: Merge conflicts / build breakage from concurrent task 358 | M | M | G6 file territory (three no-touch files); all new code in new leaf modules under `Kamp/` and `Kamp/NfMultiAnchorBridge/`; rebase before each phase commit; scoped `lake build` per phase catches interface drift early |
| R6: Phase overrun vs. H8 sizing (P2 total 1,200-1,800 lines; exterior 800-1,200 + mirror) | M | M | P2 pre-split across Phases 8-11 at the report's 2a/2b/2c/2d seams; exterior pre-split across Phases 13-15; further in-phase seams declared per phase; resume with `/implement 350` |
| R7: Statement-shape churn (H5 history on this target: 4 strikes in 309, 1 blocker in v1) | H | M | The H3 mapping-table signatures ARE the statements; Phase 7/8/9/10/11 each land their statements as full-statement stubs first (v1 Phase-1 discipline); any alteration requires an inline deviation note in this plan |
| R8: `HasAttainedSUP` mirror diverges from the INF original (PriorINF.lean:226-240) and breaks the Cor 5.4(2) mirror | L | L | It is a ~50-line mechanical mirror of `prior_hasAttainedINF` consuming `semantic_prior_SZ` (:168-176); Phase 8 lands it first as an independent probe |

## Design (carried and extended)

**Assembly (Phase 16, consumes P1-P3), from report 02:**

```
noncomputable def aggPop1 (atomMap) (h_surj) (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then C qnf else (C qnf).negFix).foldr VVecEA2.conjFull trivialTrue

theorem aggPop1_correct … (h_UZ) (h_SZ) (x t) (h_lt : x < t) :
    (aggPop1 atomMap h_surj sub_nf).holds M atomMap x t ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true)
```

with `h_INF := prior_hasAttainedINF … h_UZ`, `h_SUP := prior_hasAttainedSUP … h_SZ`;
`Fintype (NormalForm sig 1 3)` at NormalForm.lean:167. Then
`kampArm_past_k1 := (atom-layer endpoints ∧ aggPop1 sub_nf).translateRight` with
`VVecEA2.translateRight_correct` supplying the `∃ x, x < t ∧ …` navigation exactly as the
delivered Phase 3; future arm via `translateLeft`.

**Per-qnf dispatcher `C(qnf)`** (P3): split by qnf's w-zone channel (order bits at pairs
(0,1),(0,2) of `qnf.1` — the arity-3 analog of the delivered `agg2Mk` classifier):
- **3-int (x<w<t)**: `bracketEndChar_kv_correct_one_prior` instantiated with
  `charF 0 := nf_depth0_char_formula atomMap h_surj`, `h0 := rfl` (cite `endInterval_correct`
  as the 349 DoD name in the docstring).
- **3-pt (w=x / w=t)**: (0,1)/(0,2) rename-merge variants of the delivered gated collapse →
  fixed-anchor `nf_eval_nf M 1 2 [x,t]` → `nf_eval_depth1_fold_iff` at n=2 → delivered agg2 kit.
  Non-fixpoint qnf gate to the `bot` carrier exactly as `aggPosDiagK1` does.
- **3-ext (w<x / t<w)**: 7-zone-fiber inner-navigation carrier (Phases 13-15): fold w-dependent
  fibers (atoms at w; zones v<w, v=w, w<v<x) into a single Since-navigated
  `endpointLeft : TemporalPred` at x (Prop 3.5 device); w-independent parts distribute out of
  the `∃w` (v=x char → endpointLeft conjunct; x<v<t fibers → (x,t) bracket slots + exclusion
  segment; v=t, t<v, atoms at t → endpointRight). Future side is the Since/Until mirror.
- **3-bot** (order-channel inconsistent with ambient): `bot` carrier + falsity lemma (delivered
  `agg2_zone_consistent_*` technique).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 (done) | 1, 2, 3, 4, 5, 6 | -- (v1 delivered scope) |
| 1 | 7, 12 | -- (file-disjoint, parallelizable — H7) |
| 2 | 8 | 7 |
| 3 | 9 | 8 |
| 4 | 10 | 7, 9 |
| 5 | 11 | 10 |
| 6 | 13 | 11 |
| 7 | 14 | 13 |
| 8 | 15 | 14 |
| 9 | 16 | 7, 11, 12, 15 |
| 10 | 17 | 16 |

Phases within the same wave can execute in parallel. Territory (H7): Phase 7 owns
`Kamp/VecEAConjFull.lean`; Phase 12 owns `Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean`;
no shared files in wave 1.

---

### Phase 1: Shape adjudication, zone classifier, and target statements [COMPLETED]

Preserved from v1 (delivered; commit history d0f3a4484..). Summary of record: leaf module
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`
created + aggregator import (plus additive `Kamp.NfToVecEA` import); per-qnf order-bit zone
classifier realized at the `ZoneSpec 2` fiber level (`agg2Z*` zone-spec constants +
`agg2_zone_consistent_lt`/`_gt`/`_diag` ambient-order consistency lemmas) after the Phase-1
aggregation verdict that `VVecEA2.conj_struct` is one-directional; the six target statements
frozen in the module header; R1 verdict = Route V for all arms (a `BracketFormula 0` has no
point slots); R2 verdict = additive diag variant (world-locality refutation applies to a fixed
`pastEnd`); scoped build green (1032 jobs, zero warnings).

- **Timing**: 1.5 hours (spent)
- **Depends on**: none

---

### Phase 2: k=0 aggregate population carrier + correctness [COMPLETED]

Preserved from v1 (delivered; commits d0f3a4484, bb854aa8d, e9e558099 + phase-end). Summary of
record: the depth-1 fold engine `nf_eval_depth1_fold_iff` (CarrierKv.lean:466) re-fibers the k=0
population into zone-monadic `(ZoneSpec 2 × NF 0 1)` fibers; bit-false fibers encoded by the
`agg2Lit` negated-literal device + uniform interior exclusion segment (`aggBracket`); aggregation
via `formula_conjList` over `(zone, χ)` fibers + arrangement disjunction over `S.permutations`,
all within ONE VVecEA2. Delivered as `agg2Past`/`agg2Fut`/`agg2Diag` with
`agg2Past_holdsRight_iff`/`agg2Fut_holdsLeft_iff`/`agg2Diag_iff` (strictly stronger than the
planned aggPop0 shape — they fuse population match + atom layer + laid-witness existential).
`lean_verify` on all three iffs = exactly `[propext, Classical.choice, Quot.sound]`.

- **Timing**: 2 hours (spent)
- **Depends on**: 1

---

### Phase 3: k=0 hook discharge — three arm lemmas [COMPLETED]

Preserved from v1 (delivered). Summary of record: `kampArm_past_k0(_correct)` via
`(agg2Past …).translateRight` + `VVecEA2.translateRight_correct` + `agg2Past_holdsRight_iff`
(Route V; Route P unused per R1 verdict); `kampArm_future_k0(_correct)` exact dual via
`translateLeft` (flipped origin guard consumed inside `agg2EpFutL`/`agg2Fut_holdsLeft_iff`);
`kampArm_diag_k0(_correct)` as the additive diag variant (`kampArm_diag_k0 := agg2Diag`,
correctness `agg2Diag_iff`). Three shape-certificate `example`s at generic-site index `0 + 1`
(`ShapeCertificatesK0` section). All axiom checks clean.

- **Timing**: 2 hours (spent)
- **Depends on**: 2

---

### Phase 4: k=1 DIAGONAL seam carrier + gated anchor-collapse machinery [COMPLETED]

Re-scoped from v1's blocked Phase 4 to its delivered green sub-scope (commits 3334dccb5,
e8e86b419). Summary of record: `agg_rename_fixpoint_of_eval` (AggregateHookDischarge.lean:1853)
+ `agg_diag_collapse_k1` (:1907, the gated depth-1 anchor-collapse — the conditional lift of
`renameNF_eval_diag0` that NfDepth0Generalized.lean:1693-1719 records as blocked unconditionally)
+ `aggDiagGateK1`/`aggPosDiagK1(_correct)` (per-qnf diagonal population clause via the k=0 arms +
`exists_trichotomy_split`). The off-diagonal remainder (v1's `aggPop1` for the past/future seams)
was BLOCKED as blk-350-p4-offdiag-k1-aggregate; that remainder is now Phases 7-16 of this plan,
grounded in report 02.

- **Timing**: 2 hours (spent)
- **Depends on**: 2

---

### Phase 5: k=1 DIAGONAL arm lemma [COMPLETED]

Re-scoped from v1's blocked Phase 5 to its delivered green sub-scope. Summary of record:
`kampArm_diag_k1` + `kampArm_diag_k1_correct` (DoD lemma 4/6) green with the k=1 shape
certificate (generic-site index `1 + 1`), landed with the Phase-4 diag-seam machinery (commit
e8e86b419); `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`. The past/future
k=1 arms (thin translateRight/Left wrappers over the then-missing `aggPop1`) are now Phase 16.

- **Timing**: 2 hours (spent, shared with Phase 4)
- **Depends on**: 3, 4

---

### Phase 6: v1 wrap-up — verification, citability doc-hooks, summary [COMPLETED]

Preserved from v1 (delivered). Summary of record: full `lake build` green (1737 jobs);
`lean_verify` clean on the FOUR delivered arm lemmas + three aggregate iffs; guard audit passed
(seven frozen files + KampPrior untouched; KampPrior sorry count exactly 2 at :361/:364; zero
term-level `nf_char3_deeper_split`; zero live sorry); three docstring-only citability hooks in
Base.lean naming the four delivered lemmas and recording the k=1 past/future blocker; summary
`summaries/01_aggregate-quantend-hook-discharge-summary.md`; handoff status "blocked" with the
structured blocker. NOTE: this audited the v1 4/6 sub-scope; the full-DoD audit is Phase 17.

- **Timing**: 1 hour (spent)
- **Depends on**: 5

---

### Phase 7: (A / P1) conjFull kit — snoc, BracketFormula.conjFull, VVecEA2 lift [COMPLETED]

- **Goal:** Rabinovich Lemma 3.2(1)/3.4 conjunction closure in full iff form, order-generic (no
  model hypotheses), in new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAConjFull.lean`.
- **Tasks:**
  - [x] Create `Kamp/VecEAConjFull.lean` importing the VecEA stack (VecEAClosure/VecEAFormula);
    register additively wherever the existing VecEA modules are aggregated (import-line only).
    *(registered in NfMultiAnchorBridge.lean with cycle-free NOTE, task-357/350-Phase-1 precedent)*
  - [x] Probe 1 (report-recommended first move): `BracketFormula.snoc {n} (bf : BracketFormula n)
    (p s : TemporalPred) : BracketFormula (n+1)` + `snoc_holds_iff` — decomposition at the last
    witness: `(bf.snoc p s).holds M atomMap z0 z1 ↔ ∃ x, z0 < x ∧ x < z1 ∧ bf.holds M atomMap z0 x
    ∧ p.eval_at M atomMap x ∧ ∀ y, x < y → y < z1 → s.eval_at M atomMap y` (~60 lines;
    one-directional cousin `existsBounded_right` at VecEAClosure.lean:265 for reference).
    *(deviation: altered — proved via a reusable `BracketFormula.front` + `holds_succ_iff`
    last-witness decomposition built on the delivered `leftPart_holds`/`splitAt_combine` kit
    (VecEAFormula.lean:375/478) instead of a from-scratch witness-vector construction;
    `snoc_holds_iff` then follows by rewriting `snoc_front`/`snoc_*_last`)*
  - [x] Segment gluing lemma: `s on (a,x) → s(x) → s on (x,z1) → s on (a,z1)` (trichotomy on `y`
    vs `x`). *(delivered as `TemporalPred.eval_at_glue`)*
  - [x] `BracketFormula.conjFull {n1 n2} : BracketFormula n1 → BracketFormula n2 →
    VBracketFormula` — recursion on `n1 + n2` (`termination_by`), 3-way last-witness trichotomy:
    (coincide) merged point `(p1.conj p2)`, final segment `(s1.conj s2)`, recurse on both drops;
    (bf1-last greater) merged point `(p1.conj s2last)` — the other bracket's ambient segment type
    on the merged point, THE paper ingredient — final segment `(s1last.conj s2last)`, recurse
    `conjFull bf1' bf2` on `(z0, x)`; (bf2-last greater) mirror. Base cases `(0,n)`/`(n,0)`:
    conjoin the 0-bracket's segment type into ALL point types and all segment types; iff via the
    interval trichotomy. *(base cases unified in one `conjEverywhere` def + iff lemma; interval
    trichotomy delivered as `witness_position_trichotomy`)*
  - [x] `BracketFormula.conjFull_iff : (conjFull bf1 bf2).holds M atomMap z0 z1 ↔
    bf1.holds M atomMap z0 z1 ∧ bf2.holds M atomMap z0 z1` (G5: manual bridges at every step).
  - [x] Lift: `VVecEA2.conjFull (v1 v2 : VVecEA2) : VVecEA2` (Cartesian product of disjunct lists,
    endpoint conjunction via `TemporalPred.eval_at_conj` — VecEAClosure.lean:22, already iff —
    per-pair `conjFull` bracket lists flattened) + `VVecEA2.conjFull_iff` from `disj_holds` +
    per-pair `conjFull_iff`. Also a `trivialTrue` neutral element lemma for the Phase-16 fold.
    *(both left and right neutrality lemmas provided)*
  - [x] Scoped build green; `lean_verify` on `conjFull_iff` (both levels) = exactly
    `[propext, Classical.choice, Quot.sound]`; commit per green sub-step.
    *(commits 5c04425b5 + c7082617b; full `lake build` also green, 1738 jobs)*
- **Timing:** 2 hours. H8 seam if overrun: 7a = snoc kit + gluing + `BracketFormula.conjFull`
  def + iff (~300-500 lines); 7b = VVecEA2 lift (~100-200 lines).
- **Depends on:** none (wave 1; parallel with Phase 12 — disjoint files)
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAConjFull.lean` (new)
  - one aggregator import line

---

### Phase 8: (B / P2a) HasAttainedSUP mirror + negChainOn [COMPLETED]

- **Goal:** The attained-SUP surrogate and the Lemma 5.3 fixed-formula On-builder, in new file
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean` (+ PriorINF.lean append).
- **Tasks:**
  - [x] Append to `PriorINF.lean` (NOT frozen; additive):
    `structure HasAttainedSUP … : Prop where last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 → (∃ x, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) → ∃ r0, z0 < r0 ∧ r0 < z1 ∧
    (∀ y, r0 < y → y < z1 → ¬temporal_truth M atomMap y P) ∧ temporal_truth M atomMap r0 P` +
    `theorem prior_hasAttainedSUP … (h_SZ : semantic_prior_SZ M atomMap) : HasAttainedSUP M
    atomMap` — mechanical mirror of `prior_hasAttainedINF` (PriorINF.lean:226-240), consuming
    `semantic_prior_SZ` (:168-176) in place of the un-attained `HasDefinableSUP.last_occ` (:125).
    ~50 lines. Land and commit FIRST (independent probe, R8).
    *(landed 59d05c427; mirror was fully mechanical as predicted — R8 risk retired)*
  - [x] Create `Kamp/EANegationFix.lean` (imports VecEAConjFull + PriorINF + Boneyard-salvage
    targets as needed); module header records the Def 4.1 architectural note (`TemporalPred` =
    arbitrary `Formula`; `temporal_truth` interprets `.untl`/`.snce` natively — no expansion
    machinery). *(imports VecEAConjFull + EANegation — EANegation transitively supplies
    PriorINF; the mainline `BracketFormula.prepend`/`VBracketFormula.prependAll` kit in
    EANegation.lean made the Boneyard salvage unnecessary)*
  - [x] `def negChainOn : List TemporalPred → VBracketFormula` — list recursion per Lemma 5.3
    with the attained simplification (K+ disjunct vacuous, PriorINF.lean:195-199): nil ↦
    trivialTrue; P :: rest ↦ disj of [never-P 0-bracket ¬P] and prependAll-with-gate (¬P-segment,
    P-point) applied to `negChainOn rest`. Reuse `exists_permutation_cons_head`
    (EANegationClosure.lean:757) and `VBracketFormula.prependAll` (Boneyard) where sound.
    *(deviation: altered — nil ↦ `⟨[]⟩` (empty disjunction = False), NOT trivialTrue: the empty
    chain always exists (`orderedPointsExist_zero`), so its negation is False; trivialTrue is
    machine-refuted by the stated iff and by the n=0 base of `neg_orderedPointsExist_is_vbracket`
    (EANegation.lean:356-361). Reused mainline `VBracketFormula.prependAll` (EANegation.lean:333),
    not the Boneyard copy; `exists_permutation_cons_head` not needed for this construction)*
  - [x] `theorem negChainOn_iff (h_INF) (Ps) (z0 z1) (h_lt) : (negChainOn Ps).holds M atomMap
    z0 z1 ↔ ¬∃ (increasing witnesses in (z0,z1) satisfying Ps pointwise)` — phrased against
    `BracketFormula.holds` of the all-top-segment bracket built from `Ps`.
    *(phrased as `¬ (chainAllTrue Ps).holds` with `chainAllTrue Ps = BracketFormula.allTrue
    Ps.length Ps.get` + definitional bridge `chainAllTrue_holds_iff` to `orderedPointsExist`;
    proof = list-induction refactor of `neg_orderedPointsExist_is_vbracket` reusing
    `prepend_holds`, `prepend_holds_inv`, `orderedPointsExist_decompose`, plus newly extracted
    standalone `orderedPointsExist_combine`)*
  - [x] Scoped build green; axiom checks; commit per green sub-step.
    *(commits 59d05c427 + 68abf5178 + c3d360d08; full `lake build` green, 1739 jobs;
    `lean_verify` on `prior_hasAttainedSUP`, `negChainOn_iff`, `orderedPointsExist_combine` =
    exactly [propext, Classical.choice, Quot.sound]; zero sorries in touched files)*
- **Timing:** 1.5-2 hours (~300-400 lines)
- **Depends on:** 7
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` (additive append)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean` (new)
  - one aggregator import line

---

### Phase 9: (B / P2b) negBoundedRightFix + negBoundedLeftFix [NOT STARTED]

- **Goal:** Cor 5.4(1)/(2) in fixed-formula iff form, both mirrors.
- **Tasks:**
  - [ ] `def negBoundedRightFix {n} (bf : BracketFormula n) : VBracketFormula` +
    `negBoundedRightFix_iff (h_INF) (h_SUP) … : … ↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap
    z0 z` — F_i predicates as `TemporalPred` via native `.untl`/`.snce` (Table.lean:191-194);
    ⇐ direction by induction with the Until-witness y2 ≤/> x_{n+1} case split (chunk_0015).
  - [ ] `negBoundedLeftFix(_iff)` — the mirror (consumes `HasAttainedSUP` via the last-occurrence
    walk).
  - [ ] Scoped build green; axiom checks; commit per green sub-step.
- **Timing:** 2 hours (~300-500 lines). H8 seam if overrun: 9a = Right, 9b = Left mirror.
- **Depends on:** 8
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`

---

### Phase 10: (C / P2c) BracketFormula.negFix — gated Cases 1-3 + ℤ counterexample [NOT STARTED]

- **Goal:** Lemma 5.1 fixed-formula negation with the load-bearing `Cond_i` gates
  (`∨_i (Cond_i ∧ Form_i)`, chunk_0016 md:5).
- **Tasks:**
  - [ ] FIRST PROBE (R2 gate): land the ℤ counterexample as a Lean `example` — carrier ℤ,
    `(z0,z1) = (0,10)`, `p` true exactly at {2,8}, `¬s1` exactly at {3}, `¬s0` exactly at {7}:
    `¬bf.holds` for `bf = [s0, p, s1]` yet gate-free disjuncts A,B1,B2,B3 all false; B4 holds
    with (3,7). This machine-checks that the gates are required.
  - [ ] SECOND PROBE: one gated-disjunct backward lemma for the n=1 instance (each of
    A `[¬p]`, B1 `[¬p, (¬s0 ∧ ¬p), ⊤]`, B2 `[⊤, (¬s1 ∧ ¬p), ¬p]`, B3 `[⊤, ¬s0, ⊤, ¬s1, ⊤]`,
    B4 `[⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`, B4′ `[⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` individually
    implies `¬bf.holds`); then the n=1 cover (⇒: with `y1*` = last ¬s1-point and `y0*` = first
    ¬s0-point, show `y1* ≤ y0*` and `¬p` on `[y1*, y0*]`, yielding B4/B4′ — consumes attained
    INF/SUP).
  - [ ] `def BracketFormula.negFix {n} (bf : BracketFormula n) : VBracketFormula` — the general
    recursion per the paper's Cases 1-3 with attained gates (the INF gate is the plain
    first-occurrence pin `[¬P-segment, P-point]`); Case 2 consumes `negBoundedRightFix`; salvage
    the Boneyard forward plumbing (disjunct skeleton + forward correctness; only disjunct
    CONTENTS change by adding gates).
  - [ ] `theorem BracketFormula.negFix_iff (h_INF) (h_SUP) (bf) (z0 z1) (h_lt : z0 < z1) :
    (negFix bf).holds M atomMap z0 z1 ↔ ¬bf.holds M atomMap z0 z1`.
  - [ ] Scoped build green; axiom checks; commit per green sub-step. If the cover proof fails at
    any disjunct: [BLOCKED] + exact failing case (do NOT proceed to Phase 11).
- **Timing:** 2 hours (~400-600 lines). H8 seam if overrun: 10a = probes + n=1 instance,
  10b = general recursion + iff.
- **Depends on:** 7, 9
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`
  - (optional) `Tests/BimodalTest/` for the ℤ example if house style prefers tests there

---

### Phase 11: (C / P2d) VecEA2/VVecEA2.negFix — De Morgan fold [NOT STARTED]

- **Goal:** Prop 4.2 at the disjunction-of-→∃∀ level: negation of a whole VVecEA2.
- **Tasks:**
  - [ ] `def VecEA2.negFix` — per-disjunct 3-way split `¬el ∨ ¬er ∨ ¬bracket` (reuse the Boneyard
    endpoint-negation skeleton), bracket leg via `BracketFormula.negFix`.
  - [ ] `def VVecEA2.negFix (v : VVecEA2) : VVecEA2` — De Morgan fold over the disjunct list via
    `VVecEA2.conjFull` (P1) + `theorem VVecEA2.negFix_iff (h_INF) (h_SUP) (v) (z0 z1)
    (h_lt : z0 < z1) : (v.negFix).holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1`.
  - [ ] Scoped build green; axiom checks; commit.
- **Timing:** 1.5 hours (~200-300 lines)
- **Depends on:** 10
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`

---

### Phase 12: (D / P3-pt) point-channel merge variants (0,1)/(0,2) [NOT STARTED]

- **Goal:** Per-qnf k=1 carriers for the w=x and w=t channels, via new rename-merge variants of
  the delivered gated collapse. File-disjoint from Phases 7-11 (parallelizable, wave 1).
- **Tasks:**
  - [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/
    AggregatePointMergeK1.lean` importing `AggregateHookDischarge` (reuses the agg2 kit + gate
    lemma); aggregator import line.
  - [ ] Merge variants of positions (0,1) and (0,2): the delivered `aggMerge32` merges (1,2);
    `renameNF` (NfDepth0Generalized.lean:373) and `agg_rename_fixpoint_of_eval`
    (AggregateHookDischarge.lean:1853) are rename-generic — new instances, same technique
    (~150-300 lines each).
  - [ ] Per-channel carrier + iff: result of each merge is fixed-anchor
    `nf_eval_nf M 1 2 [x,t] (collapsed qnf)`; characterize via `nf_eval_depth1_fold_iff` at n=2
    (CarrierKv.lean:466) — fibers are zone-bounded monadic `(ZoneSpec 2 × NormalForm sig 0 1)`
    clauses, exactly the shape the delivered k=0 agg2 kit encodes (Since/Until lits at endpoints,
    plain chars at point zones, exclusion segment + arrangement slots for the single interior
    zone). Non-fixpoint qnf gate to the `bot` carrier exactly as `aggPosDiagK1` does.
  - [ ] Scoped build green; axiom checks; commit per green sub-step (one commit per merge
    variant is the natural seam).
- **Timing:** 2 hours (~400-700 lines). H8 seam if overrun: 12a = (0,1) variant, 12b = (0,2)
  variant.
- **Depends on:** none beyond delivered Phases 4-5 machinery (wave 1; parallel with Phase 7)
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean` (new)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (import line)

---

### Phase 13: (E / P3-ext) past-exterior navigated carrier — fiber kit [NOT STARTED]

- **Goal:** The w<x channel per-qnf carrier, first half: 7-zone fiber partition + the
  Since-navigated w-package, in new module
  `Kamp/NfMultiAnchorBridge/AggregateExteriorK1.lean`.
- **Tasks:**
  - [ ] ADJUDICATION PROBE (R3 gate, first task): for ONE concrete qnf with w<x channel, encode
    one bit-true and one bit-false inner fiber end-to-end through the intended device and prove
    its clause iff. On failure: [BLOCKED] + exact fiber and qnf pattern — do not generalize.
  - [ ] Apply `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]`: fiber the depth-1 layer into
    monadic clauses over the 7 order-consistent zones of w<x<t (v<w, v=w, w<v<x, v=x, x<v<t,
    v=t, t<v).
  - [ ] Partition fibers by w-dependence; build the Since-navigated kv_body-style w-package
    folding the w-dependent parts (atoms at w; zones v<w, v=w, w<v<x) into a single
    `endpointLeft : TemporalPred` at x (Prop 3.5 device; bit-true inner fibers = arrangement
    slots inside the fold; bit-false = exclusion segments / negated Since-lits — all fixed
    formulas via native `.snce`). May consume Phase-11 `negFix` for bit-false inner handling if
    the exclusion-segment device is insufficient at any fiber (record which device each fiber
    uses).
  - [ ] w-independent distribution lemmas: v=x char → endpointLeft conjunct; x<v<t fibers →
    (x,t) bracket arrangement slots + exclusion segment; v=t, t<v, atoms at t → endpointRight.
    (This peeling is what avoids both refutations: no monadic re-fibering of joint depth-1
    content (F1), no single predicate carrying t-reads (world-locality).)
  - [ ] Scoped build green; axiom checks; commit per green sub-step.
- **Timing:** 2 hours (~400-600 lines)
- **Depends on:** 11
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateExteriorK1.lean` (new)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (import line)

---

### Phase 14: (E / P3-ext) past-exterior carrier — correctness iff [NOT STARTED]

- **Goal:** Assemble the Phase-13 kit into the per-qnf past-exterior carrier with its full iff.
- **Tasks:**
  - [ ] Per-qnf carrier `CExtPast (qnf) : VVecEA2` (endpointLeft = w-package ∧ v=x char;
    bracket = (x,t) slots; endpointRight = t-side fibers) + correctness:
    `(CExtPast qnf).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3
    (Fin.cons w (Fin.cons x (fun _ => t))) qnf` under ambient x < t.
  - [ ] 3-bot falsity lemmas for order-channel-inconsistent qnf (delivered
    `agg2_zone_consistent_*` technique, arity-3 instance).
  - [ ] Scoped build green; axiom checks; commit.
- **Timing:** 1.5-2 hours (~300-500 lines)
- **Depends on:** 13
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateExteriorK1.lean`

---

### Phase 15: (E / P3-ext) future-exterior mirror [NOT STARTED]

- **Goal:** The t<w channel: Since/Until mirror of Phases 13-14.
- **Tasks:**
  - [ ] Mirror the w-package and distribution lemmas (Until-navigated, endpointRight side);
    reuse the Phase-13/14 proof shapes — where a genuine duality lemma exists, consume it rather
    than duplicating (record choice).
  - [ ] `CExtFut (qnf)` + correctness iff (mirror statement) + 3-bot falsity lemmas.
  - [ ] Scoped build green; axiom checks; commit.
- **Timing:** 2 hours (~400-600 lines)
- **Depends on:** 14
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateExteriorK1.lean`

---

### Phase 16: (F) assembly — dispatcher, aggPop1, kampArm_past_k1 / kampArm_future_k1 [NOT STARTED]

- **Goal:** The final two DoD lemmas, assembled exactly like delivered Phase 3.
- **Tasks:**
  - [ ] New module `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (imports VecEAConjFull,
    EANegationFix, AggregatePointMergeK1, AggregateExteriorK1, AggregateHookDischarge);
    aggregator import line.
  - [ ] Zone-classifier totality for arity 3 (order bits at pairs (0,1),(0,2) of `qnf.1` —
    arity-3 analog of `agg2Mk`): every qnf routes to exactly one of 3-int / 3-pt(w=x) /
    3-pt(w=t) / 3-ext(w<x) / 3-ext(t<w) / 3-bot given ambient x < t; mirror classification for
    the future arm.
  - [ ] Per-qnf dispatcher `C (qnf) : VVecEA2` + clause iff, casing on the classifier: interior
    via `bracketEndChar_kv_correct_one_prior` with `charF 0 := nf_depth0_char_formula atomMap
    h_surj`, `h0 := rfl` (cite `endInterval_correct` as the 349 DoD name in the docstring);
    points via Phase-12 carriers; exteriors via Phase-14/15 carriers; 3-bot via falsity lemmas.
  - [ ] `aggPop1` (conjFull-fold over `(Finset.univ : Finset (NormalForm sig 1 3)).toList` with
    `negFix` on bit-false qnf; `Fintype` at NormalForm.lean:167) + `aggPop1_correct` (statement
    verbatim from report 02 / Design section; `h_INF := prior_hasAttainedINF … h_UZ`,
    `h_SUP := prior_hasAttainedSUP … h_SZ`; fold induction over `conjFull_iff` + per-qnf
    `C`-iff / `negFix_iff`; local `maxHeartbeats` raise if needed, R4). Mirror `aggPop1F` for
    the future arm if the classifier mirror requires a distinct carrier (record decision).
  - [ ] `kampArm_past_k1(_correct)`: atom-layer endpoints ∧ aggPop1, enter via
    `VVecEA2.translateRight_correct` (NfToVecEA.lean:451). Conclusion:
    `temporal_truth M atomMap t … ↔ ∃ x, x < t ∧ nf_eval_nf M 2 2 (Fin.cons x (fun _ => t))
    sub_nf`. `kampArm_future_k1(_correct)`: exact dual via `translateLeft_correct`
    (VecEATranslation.lean:549), flipped origin guard as in `agg2Fut`.
  - [ ] Shape certificates: `example`s matching each conclusion against the corresponding
    `kampPrior_site_trichotomy` disjunct SHAPE at generic-site index `1 + 1` (statements copied
    verbatim; no KampPrior import — delivered Phase-3/5 technique).
  - [ ] Scoped build green; `lean_verify` on both `_correct` lemmas = exactly
    `[propext, Classical.choice, Quot.sound]`; commit per green sub-step.
- **Timing:** 2 hours (~300-500 lines). H8 seam if overrun: 16a = classifier + dispatcher +
  aggPop1, 16b = arm lemmas + certificates.
- **Depends on:** 7, 11, 12, 15
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (new)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (import line)

---

### Phase 17: (G) full-DoD verification, citability doc-hooks, wrap-up [NOT STARTED]

- **Goal:** Definition-of-done audit for ALL SIX lemmas and downstream citability for 309
  Phase 18b/19; close blk-350-p4-offdiag-k1-aggregate.
- **Tasks:**
  - [ ] Full `lake build` GREEN (whole tree; v1 baseline 1737 jobs).
  - [ ] `lean_verify` on all six `kampArm_{past,diag,future}_{k0,k1}_correct` (fully qualified
    names) = exactly `[propext, Classical.choice, Quot.sound]`; record transcript in the summary.
  - [ ] Guard audit: `git diff --stat` over the task's commits shows NO changes to the seven
    frozen files, NO `KampPrior.lean` changes, and (G6) NO `ExteriorPinnedConverseK.lean` /
    `ExteriorPinnedConversePastK.lean` changes; KampPrior sorry count still exactly 2 (:361,
    :364); grep: zero term-level `nf_char3_deeper_split`, zero live `sorry` in all new modules.
  - [ ] Update the Base.lean citability doc-hooks (docstring-only, v1 Phase-6 pattern): replace
    the k=1 past/future blocker note with the two new lemma names, so all six are findable by
    name from 309 Phase 18b.
  - [ ] Write summary `summaries/02_offdiag-k1-aggregate-discharge-summary.md`: name map
    (deliverable ↔ consuming site, incl. P1/P2 primitives now available codebase-wide),
    axiom-check transcript, 309 Phase-18b consumption instructions, blocker-resolution record.
  - [ ] Final commit; orchestrator handoff JSON → status reflecting full DoD (blockers []);
    task status update.
- **Timing:** 1 hour
- **Depends on:** 16
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` (docstring-only)
  - `specs/350_.../summaries/02_offdiag-k1-aggregate-discharge-summary.md` (new)

## Testing & Validation

- [ ] `lake build` (full tree) exits 0 after each phase (scoped) and at Phase 17 (full).
- [ ] `lean_verify` on all six `kampArm_*_correct` lemmas + `conjFull_iff` (both levels) +
  `negFix_iff` (both levels) + `negChainOn_iff` + `negBounded{Right,Left}Fix_iff` +
  `aggPop1_correct` = exactly `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- [ ] The ℤ B4 counterexample `example` compiles (machine-checks gate necessity).
- [ ] Shape certificates: each k=1 `_correct` conclusion matches the corresponding
  `kampPrior_site_trichotomy` disjunct verbatim (local `example`s compile, no KampPrior import).
- [ ] `git diff` across all task commits contains no hunk in the seven frozen files, in
  `KampPrior.lean`, or (G6) in `ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean`;
  KampPrior sorry count exactly 2.
- [ ] `grep -n "nf_char3_deeper_split"` over new modules: only docstring prohibition notes.
- [ ] `grep -c "sorry"` over new modules = 0 (code); no `def X := True`-style vacuities.
- [ ] Delivered v1 assets unmodified: `git diff` on `AggregateHookDischarge.lean` shows additive
  hunks only if a phase explicitly allowed them (default: none).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAConjFull.lean` (Phase 7 — P1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean` (Phases 8-11 — P2) +
  additive `HasAttainedSUP` append to `PriorINF.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean`
  (Phase 12 — P3 points)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateExteriorK1.lean`
  (Phases 13-15 — P3 exteriors)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean`
  (Phase 16 — aggPop1 + the final two DoD lemmas + certificates)
- Aggregator import lines; docstring-only doc-hook update in `Base.lean` (Phase 17)
- `plans/02_offdiag-k1-aggregate-discharge.md` (this plan)
- `summaries/02_offdiag-k1-aggregate-discharge-summary.md` (Phase 17)
- Orchestrator handoff JSON updates at every phase-end commit

## Rollback/Contingency

- All Lean changes are additive (new modules + import lines + one additive PriorINF append +
  docstring edits): rollback = `git revert` of the task's commits or removal of modules +
  import lines; no landed asset is modified, so rollback cannot break v1's four delivered
  lemmas or any downstream consumer.
- Commit-per-green-substep keeps every green milestone recoverable; run
  `bash .claude/scripts/git-snapshot.sh` before any intentional rollback.
- Probe-gated escalation points (do NOT proceed past a failed probe): Phase 10's ℤ example +
  n=1 gated cover (R2); Phase 13's single-fiber adjudication probe (R3). On failure mark the
  phase [BLOCKED] with the exact obstruction (disjunct/fiber + qnf pattern) and escalate —
  never land a vacuous or sorry'd encoding.
- If task 358's concurrent work creates upstream interface drift, rebase, re-run the scoped
  build, and record the drift; if drift invalidates a statement shape, record an inline
  deviation note (R7 discipline) before altering it.
- If a phase overruns its H8 budget, split at the pre-declared seams (7a/7b, 9a/9b, 10a/10b,
  12a/12b, 16a/16b) and resume with `/implement 350`.
