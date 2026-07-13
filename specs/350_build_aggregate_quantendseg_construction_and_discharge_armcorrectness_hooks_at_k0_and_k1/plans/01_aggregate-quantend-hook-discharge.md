# Implementation Plan: Task #350

- **Task**: 350 - build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1
- **Status**: [IMPLEMENTING]
- **Effort**: 10.5 hours
- **Dependencies**: Task 349 (COMPLETED — recursive endpoint primitive delivered as `endInterval_correct` stack)
- **Research Inputs**: specs/309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md; specs/309_offdiag_two_anchor_fi_chain/reports/02_endpoint-hook-discharge-research.md (§6 Phase 9, lines 272-279); specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json (blocker P18b-endChar-recursive-core-unbuilt)
- **Artifacts**: plans/01_aggregate-quantend-hook-discharge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Task 309's Phase-18a skeleton `kampPrior_case1_trichotomy_assemble` (KampPrior.lean:1146) reduces
the `:361` `| 1 =>` arm retirement to supplying, per depth `k`, three arm formulas whose
`temporal_truth` at `t` realizes the past / diagonal / future disjuncts of
`kampPrior_site_trichotomy` (KampPrior.lean:677). Each disjunct, unfolded through
`kampPrior_site_perQnf_seam` (KampPrior.lean:694), is an atom layer plus the aggregate ∀-qnf
population match `∀ qnf : NormalForm sig k 3, ((∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔
sub_nf.2 qnf = true)`. This task builds that aggregate population encoding via per-qnf 5-zone
order-pattern routing and lands six green, citable hook-discharge lemmas — past/diag/future at
match arms k=0 and k=1 — consuming (never rebuilding) the task-349 recursion stack, the landed
segment/coupling lemmas, and the zone-flatten brick. No KampPrior.lean recursion-body edit is
made; task 309's Phase 18b/19 then instantiates the skeleton by name.

### Research Integration

- Report 08 (spawn analysis) fixes the deliverable split: (a) the aggregate ∀-qnf quantEnd/seg
  construction; (b) discharge of `h_quant` (past `Base.lean:1270`, future `Base.lean:1470`) and
  `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, `Base.lean:765-773`) as separate green lemmas at
  k=0 and k=1. (Line refs updated to current Base.lean; the task description's :1230/:1430/:758
  refs pre-date the task-349 doc-hook edits.)
- Report 02 §6 "Phase 9" (309/reports/02:272-279) is the adapted decomposition: instantiate the
  hooks and prove the arm correctness facts; the `:361` rewire itself stays task 309's Phase 19.
- Orchestrator handoff blocker `P18b-endChar-recursive-core-unbuilt` (crux + resolution, second
  successor): even the k=0 arm needs BOTH the aggregate construction AND the discharge of the
  base-case anchor residual through the enclosing bracket segment; the k=1 arm additionally needs
  the (now-delivered) recursive endpoint primitive.

### Prior Plan Reference

No prior plan for task 350. Effort calibration from adjacent tasks: 349's consumer reshape
(EndIntervalConsumerK.lean, ~280 lines) took one green dispatch once statement shapes were fixed;
309's Phase 15 site-lemma cycle showed that landing NAMED seam lemmas first prevents shape churn.
This plan front-loads statement-shape adjudication (Phase 1) for the same reason.

### Roadmap Alignment

No ROADMAP.md consultation was requested in the delegation context (no roadmap_path provided).
This task advances the Kamp's theorem formalization track (parent task 309, topic
`kamp_theorem_formalization`).

### Literature Grounding (--lit)

Per-repo sub-index resolved (SUBINDEX_PRESENT). Ground-truth sources, navigate on demand:
- **Rabinovich 2014, "A Proof of Kamp's Theorem"** —
  `/home/benjamin/Projects/Literature/sources/rabinovich_2014/` (1 chunk). Cor 5.4 (the F_i
  chain and the all-order-patterns clause D_j), Lemma 7.6 (adjacent-bracket composition),
  Prop 3.5 (∃-witness → Until/Since folding), Prop 4.2 (negation closure). The aggregate
  population match IS Cor 5.4's "for every order pattern" clause; follow it step-by-step (G5:
  no simp/omega/aesop shortcut of a chain step).
- **Kamp 1968, "Tense Logic and the Theory of Linear Order"** —
  `/home/benjamin/Projects/Literature/sources/kamp_1968_tense-logic-linear-order/` (background
  only; Rabinovich 2014 is the implementation source).
- Search: `bash .claude/scripts/literature-search.sh "<query>"`.

## Delivered-Name Map (BINDING — consume by these names)

The task description names `endChar_correct` as the prerequisite deliverable. Task 349 delivered
it under the following names (349 completion summary + Base.lean:966-995 doc-hook, "Downstream
citability ... task 350"); the `CarrierK1V.lean` pair `endIntervalStep`/`EndIntervalCorrect` is
superseded dead code — do NOT cite it:

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

At k=0 and k=1 the recursion reduces by `rfl` (EndIntervalConsumerK.lean:266-271):
`endIntervalPrior … 0 = fun qnf => VVecEA2.singleton (bracketEndChar_k0 …)` and
`endIntervalPrior … 1 = bracketEndChar_kv atomMap h_surj charF 1`. The k=0 arm of
`EndIntervalCorrectPrior` is obligation-free; the k=1 arm carries ONLY
`h0 : charF 0 = nf_depth0_char_formula atomMap h_surj`, dischargeable by construction by
choosing `charF 0 := nf_depth0_char_formula atomMap h_surj` at instantiation. No m+2-arm
obligation (`P`/`hcharK`/`hreal`/`hexcl`/slice family) enters this task's scope.

## Goals & Non-Goals

**Goals**:
- Build the aggregate ∀-qnf population encoding (the "quantEnd/seg construction") for the
  off-diagonal seam at x < t and its diagonal (x = t) analog, via per-qnf 5-zone order-pattern
  routing (`nf_char2_zone_split5`, Base.lean:584; house style `nf_zone_exists_trichotomy_k1`).
- Discharge the three arm-correctness hooks as SIX separate green citable lemmas: past/diag/
  future at match arm k=0 (sub_nf : NormalForm sig 1 2) and at k=1 (sub_nf : NormalForm sig 2 2),
  each concluding in the skeleton shape `temporal_truth M atomMap t A ↔ <trichotomy disjunct>`
  under `h_UZ`/`h_SZ` at most.
- Keep everything additive: new leaf module + optional additive doc-hooks; task 309 Phase 18b/19
  can cite every deliverable by name.

**Non-Goals**:
- NO edit to `KampPrior.lean:352-364` (the `:361`/`:364` sorry region and its transfer note —
  task 309's own Phase 19 edit). Safest posture adopted by this plan: no KampPrior.lean edits at
  all.
- NO edits to the seven frozen provider files: SharedWitness.lean, SubBracket2V.lean,
  OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation(K).lean,
  ExteriorNegationPast(K).lean (read/consume only).
- NO rebuild of `endInterval_correct`, `seg_holds_coupled`, `nf_zone_flatten_navigable_correct`,
  or any 355/356/357/360 stack asset.
- NO k≥2 arm work (m+2 obligations route to task 358 / 309 Phase 14 per the 349 ledger).
- NO use of `nf_char3_deeper_split` (FORBIDDEN — anchor growth to 4, refuted tower; report 02
  §4.1). It exists at Base.lean:603; it must not appear in any new proof term.

## Binding Guards (inherited, same set as task 349)

- **G1** — no arity-1 collapse: every population obligation stays the honest arity-3
  `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` on the full env.
- **G2/G4** — anchors strictly `{x, t}` (≤2 cap); `w` and every interior point are bracket
  witnesses, never a third free anchor.
- **G3** — non-trivial segments: reuse the landed `seg`/carrier bracket content; never
  `TemporalPred.top` as the off-diagonal interval type.
- **G5** — no `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step; manual bridges
  (`constructor`/`intro`/`exact`) at every Cor 5.4 step.
- **FORBIDDEN**: `nf_char3_deeper_split`; resurrection of retired interfaces (`hbr*` family,
  `bracketEndChar_kvE'_correct*`, the dead `CarrierK1V` `endIntervalStep`/`EndIntervalCorrect`).
- **Axioms**: every new lemma `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`.
- **Sorry-free**: no sorry, no vacuous defs (`def X := True` etc. — prohibited per lean4 rules);
  if a sub-piece cannot close green, mark the phase [BLOCKED] and escalate — do not land debt.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: The literal `(quantEnd : TemporalPred) × (seg : BracketFormula 0)` pair of the P4/P5 `h_quant` binders cannot host interior-POSITIVE population clauses (a `BracketFormula 0` lays no witness; a closed TemporalPred at x cannot bound a laid witness by t) | H | H | Primary route (Route V, below) assembles the arm at the VecEA2/VVecEA2 level and enters the skeleton via `VVecEA2.translateRight_correct` (NfToVecEA.lean:451) / `translateLeft_correct` (VecEATranslation.lean:549) instead of forcing the pair shape. The DoD binds only the skeleton-shaped conclusions, which Route V produces directly. Phase 1 adjudicates and records the decision |
| R2: `A_diag_correct`'s per-point hooks (`h_past`: `(pastEnd qnf).eval_at w ↔ nf_eval_nf … (Fin.cons w (fun _ => t)) qnf` for ALL w < t) are undischargeable for a fixed syntactic `pastEnd` — same free-anchor obstruction machine-established by the `endChar0_correct` counterexample (Base.lean:1068-1079: a closed navigated-w TemporalPred cannot read the carrier anchor t) | H | H | Diag arm assembled at the origin t instead (Since/Until brackets FROM t laying w, t-locus factor conjoined AT t — the diagonal converter stack `nf_char2_diag_exist_tl`/`_correct`, Base.lean:183, plus the depth-0 all-arity converter). If `A_diag_correct` cannot be applied, land an additive diag-arm variant lemma with the same skeleton-shaped conclusion; the hooks are thereby "discharged" in the sense that binds (Phase 18b consumes the conclusion, not the binder) |
| R3: k=1 per-qnf population members contain a NESTED depth-0 arity-4 population (qnf.2 over NormalForm sig 0 4) | M | H | Consume the k=1 rung `bracketEndChar_kv_correct_one_prior` (interior zone) and the depth-0 all-arity converter `nf_nvar_exist_depth0_tl_fn(_correct)` (NfDepth0Generalized:1615) for point/exterior zones; never hand-roll the nested layer |
| R4: Exterior zones (w < x, t < w) per-qnf at k∈{0,1} need navigated endpoint characterizations with anchor coupling | M | M | Route each exterior clause through `nf_zone_flatten_navigable_correct` (Base.lean:687) whose h_past/h_fut hooks bottom out at k=0 in `nf_zone_flatten_navigable_zero` and at k=1 in the depth-0 converters; order-bit routing (Phase 1 classifier) kills 4 of 5 zones per qnf so each clause has ONE live locus. If a genuinely unbuildable exterior case survives adjudication, mark [BLOCKED] and escalate with the exact qnf pattern — do not encode vacuously |
| R5: Import cycle when consuming both Base.lean arm lemmas and EndIntervalConsumerK | M | L | All new Lean code goes in a NEW leaf module importing EndIntervalConsumerK (which transitively imports Base); register it in the NfMultiAnchorBridge.lean aggregator (additive; only KampPrior imports the aggregator — cycle-free, same pattern as task 357 Phase 1) |
| R6: Elaboration blowup aggregating over `Finset.univ.toList : List (NormalForm sig k 3)` | M | M | Follow the landed house pattern exactly (`nf_char2_formula`, Base.lean:454: per-qnf clause lemma + `formula_conjList_iff` + `List.mem_map`); keep per-qnf lemmas parametric and aggregate only at the last step; raise `maxHeartbeats` locally (precedent: EndIntervalConsumerK.lean:174 uses 1600000) |
| R7: Statement-shape churn (the 309 H5 divergence history: 4 strikes on this target) | H | M | Phase 1 lands the six target statements as named, compiling stubs-with-full-statements (proved where trivial, otherwise phase-gated — never sorry'd) BEFORE construction begins; later phases may not alter a Phase-1 statement without recording a deviation note in this plan |

## Design: the two sanctioned assembly routes

**Route V (primary — VecEA2-level aggregate, then translate).** For the past arm at match arm k:
target `∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`. By
`kampPrior_site_perQnf_seam` this is `∃ x < t, atomLayer(x,t) ∧ Pop(x,t)` where
`Pop(x,t) := ∀ qnf, ((∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf = true)`.
Encode the per-x content as an aggregate `VVecEA2` built by:
1. per-qnf 5-zone routing (`nf_char2_zone_split5` + the Phase-1 order-bit classifier: for fixed
   qnf and x < t, at most ONE zone is consistent with qnf's order bits; inconsistent-pattern qnf
   have `¬∃ w`);
2. per-zone per-qnf encodings — interior via the k-rung carriers
   (`bracketEndChar_kv_correct_zero_prior`/`_one_prior`, whose `.holds x t` IS the interior
   existential); point zones via diagonal collapse/depth-0 converters; exterior zones via
   `nf_zone_flatten_navigable_correct`'s navigated brackets;
3. bit-false clauses via the landed negation closure (Prop 4.2 stack, EANegationClosure —
   imported by Base.lean for exactly this); conjunction across the qnf population via
   `VVecEA2.conj_struct` (VecEAClosure.lean:195) or the `formula_conjList` pattern at the
   endpoint-predicate level, following `nf_char2_formula` (Base.lean:454) house style;
4. enter the skeleton with `VVecEA2.translateRight_correct` (past arm; `holdsRight t` =
   endpointRight@t ∧ ∃ z0 < t, endpointLeft@z0 ∧ bracket.holds z0 t — exactly the required
   shape) and `VVecEA2.translateLeft_correct` (future arm, dual).

**Route P (secondary — discharge the literal P4/P5 `h_quant` binder).** Only where Phase 1's
probes show the `(quantEnd, seg)` pair suffices (e.g., populations whose bit-true clauses are all
non-interior at the given depth), instantiate `nf_char2_past_formula_correct` /
`nf_char2_future_formula_correct` directly. Route P is a bonus, not the critical path; if the
probe confirms R1 binds, record it and proceed on Route V without further Route-P effort.

Either way, the DoD deliverable is the six skeleton-shaped lemmas; the "aggregate quantEnd/seg
construction" deliverable is realized by the aggregate carrier + its correctness lemma
(Phases 2/4), which is exactly the population-match encoding the task description names.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel (Phase 3 and Phase 4 touch disjoint
sections of the new module).

---

### Phase 1: Shape adjudication, zone classifier, and target statements [COMPLETED]

**Goal**: Fix the six target statements and the per-qnf routing infrastructure before any
aggregate construction; kill statement churn (R7) and adjudicate R1/R2 with compiling probes.

**Tasks**:
- [x] Create leaf module
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`
  with `import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.EndIntervalConsumerK`;
  add `import ...NfMultiAnchorBridge.AggregateHookDischarge` to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (additive; cycle-free
  — only KampPrior imports the aggregator, task-357 precedent). *(completed; one extra additive
  import `Kamp.NfToVecEA` for `VVecEA2.holdsRight`/`translateRight` — cycle-free, recorded in
  the aggregator import note)*
- [x] Land the per-qnf order-bit zone classifier: a decidable function/predicate classifying
  `qnf : NormalForm sig k 3` (via `qnf.atom_assgn` on the six order atoms among positions
  {0=w, 1=x, 2=t}, uniform over k — the `BracketCarrierCorrectVPrior` k0-mirror form,
  PriorInterface.lean:62-68) into: interior (x<w<t), pointX (w=x), pointT (w=t), pastExt (w<x),
  futExt (t<w), or inconsistent-given-x<t. *(deviation: altered — the k=0 aggregate routes
  through the depth-1 fold engine `nf_eval_depth1_fold_iff` (CarrierKv.lean:466), so the
  classifier is realized at the `ZoneSpec 2` fiber level: named zone-spec constants `agg2Z*` +
  ambient-order consistency lemmas. Reason: `VVecEA2.conj_struct` is ONE-directional (its
  `n1+1,n2+1` case discards the second bracket), so the plan's per-qnf-VVecEA2 conjunction
  cannot yield a biconditional aggregate; the fold re-fibering is lossless
  (`nf0_split_assemble`) and needs no conjunction combinator. Recorded in the module-header
  "Aggregation verdict".)*
- [x] Prove the routing lemmas: for x < t and each classification, `∃ w, nf_eval_nf M k 3
  (zoneEnv3 w x t) qnf` collapses to the single live zone disjunct of `nf_char2_zone_split5`
  (Base.lean:584), and to `False` for inconsistent patterns (the order-atom layer refutes the
  other zones). Diagonal analog at x = t (3 zones: w<t, w=t, t<w). *(deviation: altered — the
  routing lemmas are `agg2_zone_consistent_lt`/`_gt`/`_diag` (realized zone spec is one of the
  5/5/3 consistent zones; contrapositive = False-for-inconsistent) at the fold fiber level,
  replacing the `nf_char2_zone_split5` route; same Def 3.1 content, fewer moving parts.)*
- [x] Write the SIX target statements as named theorem stubs WITH full final statements and
  docstrings, phase-gated bodies (each stub proved in Phases 3/5; until then the file contains
  only the statements as commented blocks or the statements of already-provable reductions —
  NEVER `sorry`): `kampArm_past_k0`/`kampArm_diag_k0`/`kampArm_future_k0` +
  `_correct` companions at k=0, and the three `_k1` analogs. Conclusion shape (past, k=0
  example): `∀ M h_UZ h_SZ t, temporal_truth M atomMap t (kampArm_past_k0 atomMap h_surj sub_nf)
  ↔ ∃ x, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`. *(completed — frozen as
  the module-header "six target statements" block, per the plan's commented-block option)*
- [x] R1/R2 adjudication probes: (i) attempt a typecheck-level fit of the interior-positive
  clause into the `(quantEnd, seg : BracketFormula 0)` pair; (ii) restate the `endChar0_correct`
  counterexample argument (Base.lean:1068-1079) against `A_diag_correct`'s per-point hook for a
  fixed syntactic `pastEnd`. Record verdicts as docstring adjudication notes in the module header
  (Route V vs Route P per arm). *(completed — header records: R1 = Route V for all arms (a
  `BracketFormula 0` has no point slots — `IntervalPattern.holds` at n=0 is segment-only — so
  Route P cannot host interior-positive fibers); R2 = additive diag variant (the
  `endCharN0_correct_infeasible` world-locality refutation applies verbatim to a fixed
  `pastEnd`).)*
- [x] Scoped build green: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
  *(completed — `lake build ...NfMultiAnchorBridge.AggregateHookDischarge` green, 1032 jobs,
  zero warnings in the new module)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean` (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (one import line)

**Verification**:
- Scoped `lake build` green; zone classifier + routing lemmas sorry-free; no frozen-file edits;
  module header records the R1/R2 adjudication verdicts and the fixed statements.

---

### Phase 2: k=0 aggregate population carrier + correctness [COMPLETED]

**Goal**: The "aggregate quantEnd/seg construction" at depth 0: a single aggregate object
(VVecEA2 per Route V, or TemporalPred/BracketFormula-0 pair where Route P was adjudicated
viable) encoding `Pop(x,t)` for `sub_nf : NormalForm sig 1 2`, with its correctness lemma.

**Tasks**:
- [x] Per-qnf clause encodings at k=0, one lemma per zone class (parametric over qnf, following
  the `nf_quant_clause_tl` clause pattern): interior via
  `bracketEndChar_kv_correct_zero_prior` (PriorInterface.lean:80; its `.holds x t` ↔
  `∃ w, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` under the six interior
  order bits — `zoneEnv3 w x t` is definitionally this env, NfZoneDepthK:207); pointX/pointT via
  the depth-0 atom-layer characteristics (`nf_depth0_char_formula_correct`, `endChar0` w-locus +
  residual discharged by the pinned anchors — handoff crux item (B)); exteriors via
  `nf_zone_flatten_navigable_correct` at k=0 (hooks bottom out in
  `nf_zone_flatten_navigable_zero`); inconsistent patterns via the Phase-1 `False` routing.
  *(deviation: altered — the depth-1 fold engine re-fibers the whole population into
  zone-monadic `(ZoneSpec 2 × NF 0 1)` fibers, so the per-zone encodings are Since/Until/char
  literals at the two anchors + interior arrangement slots, with no per-qnf lemmas and no
  k=0-rung/zone-flatten consumption needed. Inconsistent patterns via the gate + Phase-1
  consistency lemmas as planned.)*
- [x] Bit-false clauses: negation closure of the positive encodings (Prop 4.2 stack /
  EANegationClosure assets; for the interior zone the negative is the universal-over-interval
  form, which DOES ride a `BracketFormula 0` interval type via `seg_holds_coupled`,
  Base.lean:1182). *(deviation: altered — Prop 4.2's `neg_2var_vec_ea` is model-dependent
  (existential `∃ v'`), unusable in a fixed syntactic construction; bit-false fibers are
  encoded by the `agg2Lit` negated-literal device at the anchors and the uniform interior
  exclusion segment (which IS the universal-over-interval form the plan named, realized as
  `aggBracket`'s uniform `segmentTypes`).)*
- [x] Aggregate across `(Finset.univ.toList : List (NormalForm sig 0 3))` following the
  `nf_char2_formula` house pattern (Base.lean:454-518: `formula_conjList` + `List.mem_map`
  membership + per-clause rewrite), at the VecEA2 endpoint/bracket level per Route V
  (`VVecEA2.conj_struct`, VecEAClosure.lean:195, for cross-disjunct conjunction).
  *(deviation: altered — `conj_struct` is one-directional (Phase-1 aggregation verdict);
  aggregation is `formula_conjList` over the `(zone, χ)` fibers inside the endpoint
  predicates/segment (house pattern as planned, at the endpoint level) + the arrangement
  disjunction over `S.permutations` for interior positives, all within ONE VVecEA2.)*
- [x] Land `aggPop0` (def) + `aggPop0_correct`: for all Prior M (h_UZ h_SZ) and x < t, the
  aggregate's holds/eval ↔ `∀ qnf : NormalForm sig 0 3, ((∃ w, nf_eval_nf M 0 3 (zoneEnv3 w x t)
  qnf) ↔ sub_nf.2 qnf = true)`. Plus the diagonal-seam analog `aggPop0_diag(_correct)` at x = t
  (3-zone routing, env `Fin.cons w (fun _ => t)`). *(deviation: altered — delivered as
  `agg2Past`/`agg2Fut`/`agg2Diag` with `agg2Past_holdsRight_iff`/`agg2Fut_holdsLeft_iff`/
  `agg2Diag_iff`, which FUSE the population match with the atom layer and the laid-witness
  existential: `holdsRight t ↔ ∃ x < t ∧ nf_eval_nf M 1 2 [x,t] sub_nf` etc. — strictly
  stronger than the planned aggPop0 shape and exactly the Phase-3 input. The future-arm
  carrier (planned Phase-3 dual work) landed here for symmetry. No `h_UZ`/`h_SZ` needed at
  the carrier level (matching the k≤1 rungs); the arm lemmas carry them for skeleton shape.)*
- [x] Scoped build green; commit per green sub-step (commit-per-green-substep mandate).
  *(completed — commits d0f3a4484, bb854aa8d, e9e558099 + this phase-end commit; `lean_verify`
  on all three iff theorems = exactly `[propext, Classical.choice, Quot.sound]`)*

**Timing**: 2 hours (H8 seam if overrun: split 2a = positive clauses + interior, 2b = negation
closure + aggregation, at the per-clause/aggregation boundary)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`

**Verification**:
- `aggPop0_correct` + `aggPop0_diag_correct` sorry-free; `lean_verify` axioms exactly
  `[propext, Classical.choice, Quot.sound]`; no `nf_char3_deeper_split` reference (grep).

---

### Phase 3: k=0 hook discharge — three arm lemmas [NOT STARTED]

**Goal**: The three green citable k=0 lemmas in the skeleton shape, discharging the arm hooks at
match arm k=0 (`sub_nf : NormalForm sig 1 2`).

**Tasks**:
- [ ] `kampArm_past_k0` + `kampArm_past_k0_correct`: assemble atom layer
  (`nf_char2_atom_offdiag_correct`, Base.lean:399-region) + `aggPop0` per witness x, enter via
  `VVecEA2.translateRight_correct` (NfToVecEA.lean:451) [Route V] or via
  `nf_char2_past_formula_correct` (Base.lean:1262) with the h_quant binder [Route P, only if
  Phase-1 verdict allows]. Conclusion: `temporal_truth M atomMap t … ↔ ∃ x, x < t ∧
  nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`.
- [ ] `kampArm_future_k0` + `_correct`: exact dual via `VVecEA2.translateLeft_correct`
  (VecEATranslation.lean:549) / `nf_char2_future_formula_correct` (Base.lean:1462) with the
  flipped origin guard (`nf_char2_atom_offdiag_origin_future`, Base.lean:1340).
- [ ] `kampArm_diag_k0` + `_correct`: diagonal disjunct `nf_eval_nf M 1 2 (Fin.cons t (fun _ =>
  t)) sub_nf` via the diagonal converter stack (`nf_char2_diag_exist_tl_correct`, Base.lean:183;
  `A_diag_correct` applied per Phase-1 R2 verdict, else the additive diag variant) + the
  diagonal-seam aggregate `aggPop0_diag`.
- [ ] Sanity certificate: an `example` applying `kampPrior_case1_trichotomy_assemble`
  (KampPrior.lean:1146) shape against the three conclusions is NOT possible here (KampPrior
  imports the aggregator, not vice versa) — instead land a local `example` matching each
  conclusion against the corresponding `kampPrior_site_trichotomy` disjunct SHAPE (statement
  copied verbatim; certifies drop-in citability without importing KampPrior).
- [ ] Scoped build green; commit.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`

**Verification**:
- Three k=0 lemmas sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`
  (`lean_verify` each by fully qualified name); shape certificates compile.

---

### Phase 4: k=1 aggregate population carrier + correctness [NOT STARTED]

**Goal**: The depth-1 aggregate: `aggPop1(_correct)` and `aggPop1_diag(_correct)` for
`sub_nf : NormalForm sig 2 2` (population `qnf : NormalForm sig 1 3`).

**Tasks**:
- [ ] Instantiate the k=1 interior rung: fix `charF` with `charF 0 := nf_depth0_char_formula
  atomMap h_surj` (discharging `h0` by `rfl`/definitional agreement) and consume
  `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95) — equivalently the k=1 arm of
  `endInterval_correct` (EndIntervalConsumerK.lean:220), which reduces to it by `rfl`; cite
  `endInterval_correct` in the docstring as the task-349 DoD name.
- [ ] Depth-1 per-qnf clause encodings for point/exterior zones: the nested depth-0 arity-4
  layer inside each `qnf : NormalForm sig 1 3` routes through the depth-0 all-arity converter
  `nf_nvar_exist_depth0_tl_fn(_correct)` (NfDepth0Generalized:1615) — never hand-rolled (R3);
  exteriors via `nf_zone_flatten_navigable_correct` at k=1 with hooks discharged by the depth-0
  converters.
- [ ] Reuse the Phase-2 aggregation combinators verbatim (they are depth-parametric where
  possible; otherwise mirror with the depth-1 instances).
- [ ] Land `aggPop1(_correct)` + `aggPop1_diag(_correct)`; scoped build green; commit.

**Timing**: 2 hours (H8 seam if overrun: 4a = interior rung instantiation + point zones,
4b = exterior zones + aggregation)

**Depends on**: 2 (aggregation combinators; can run parallel to Phase 3 — disjoint module
sections)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`

**Verification**:
- `aggPop1_correct` + `aggPop1_diag_correct` sorry-free; axioms clean; `h0` discharged by
  construction (no residual hypothesis beyond `h_UZ`/`h_SZ` in the correctness statements).

---

### Phase 5: k=1 hook discharge — three arm lemmas [NOT STARTED]

**Goal**: `kampArm_past_k1`, `kampArm_diag_k1`, `kampArm_future_k1` + `_correct` companions,
mirroring Phase 3 one depth up (`sub_nf : NormalForm sig 2 2`).

**Tasks**:
- [ ] Past arm at k=1 (consume `aggPop1` + translateRight / Route-P binder per Phase-1 verdict).
- [ ] Future arm at k=1 (dual).
- [ ] Diag arm at k=1 (diagonal-seam aggregate `aggPop1_diag`).
- [ ] Shape certificates against the `kampPrior_site_trichotomy` disjunct statements (verbatim
  copies, as in Phase 3).
- [ ] Scoped build green; commit.

**Timing**: 2 hours

**Depends on**: 3 (assembly glue precedent), 4 (the k=1 aggregate)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`

**Verification**:
- Three k=1 lemmas sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 6: Full-tree verification, citability doc-hooks, wrap-up [NOT STARTED]

**Goal**: Definition-of-done audit and downstream citability for 309 Phase 18b/19.

**Tasks**:
- [ ] Full `lake build` GREEN (whole tree; 349 baseline was 1736 jobs).
- [ ] `lean_verify` on each of the six named hook-discharge lemmas (fully qualified names) =
  exactly `[propext, Classical.choice, Quot.sound]`; record outputs in the summary.
- [ ] Guard audit: `git diff --stat` shows NO changes to the seven frozen files and NO
  KampPrior.lean changes; grep confirms zero references to `nf_char3_deeper_split` and zero
  live `sorry` in the new module; sorry count in KampPrior.lean unchanged at exactly 2
  (:361, :364).
- [ ] Additive doc-hook edits in `Base.lean` (the "Downstream citability" pattern task 349
  used, Base.lean:990-995): point the P4/P5 `h_quant` docstrings and the `A_diag_correct` hook
  docstring at the six delivered lemma names so 309 Phase 18b finds them by name. Docstring-only
  edits; no statement or proof changes.
- [ ] Write summary artifact `summaries/01_aggregate-quantend-hook-discharge-summary.md` with
  the name map (deliverable ↔ consuming site), axiom-check transcript, and the 309 Phase-18b
  consumption instructions.
- [ ] Final commit; orchestrator handoff JSON update.

**Timing**: 1 hour

**Depends on**: 5 (and transitively all)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` (docstring-only)
- `specs/350_.../summaries/01_aggregate-quantend-hook-discharge-summary.md` (new)

**Verification**:
- Full build green; all six axiom checks clean; frozen-file/no-edit-region audit passes;
  summary written.

## Testing & Validation

- [ ] `lake build` (full tree) exits 0.
- [ ] `lean_verify` on `kampArm_past_k0_correct`, `kampArm_diag_k0_correct`,
  `kampArm_future_k0_correct`, `kampArm_past_k1_correct`, `kampArm_diag_k1_correct`,
  `kampArm_future_k1_correct` = exactly `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- [ ] Shape certificates: each `_correct` conclusion matches the corresponding
  `kampPrior_site_trichotomy` disjunct verbatim (local `example`s compile).
- [ ] `git diff` contains no hunk in SharedWitness.lean, SubBracket2V.lean, OuterGate.lean,
  ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation(K).lean,
  ExteriorNegationPast(K).lean, or KampPrior.lean (code); KampPrior sorry count still exactly 2.
- [ ] `grep -n "nf_char3_deeper_split" AggregateHookDischarge.lean` returns only (at most)
  docstring prohibition notes, never a term-level use.
- [ ] `grep -cn "sorry" AggregateHookDischarge.lean` = 0 (code).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`
  (new leaf module: zone classifier, aggregate carriers `aggPop0/1(_diag)` + correctness, six
  hook-discharge lemmas + shape certificates)
- One import line in `NfMultiAnchorBridge.lean`; docstring-only citability hooks in `Base.lean`
- `plans/01_aggregate-quantend-hook-discharge.md` (this plan)
- `summaries/01_aggregate-quantend-hook-discharge-summary.md` (Phase 6)
- Orchestrator handoff JSON at task completion

## Rollback/Contingency

- All Lean changes are additive (new module + one import line + docstring edits): rollback =
  `git revert` of the task's commits, or removal of the module + import line; no landed asset
  is modified, so no downstream breakage is possible from rollback.
- Commit-per-green-substep (git-workflow mandate) keeps every green milestone recoverable; use
  `bash .claude/scripts/git-snapshot.sh` before any intentional rollback.
- If Phase 1 adjudication finds a hard wall beyond R1/R2's mitigations (e.g., an exterior-zone
  clause at k=1 that provably cannot be encoded with the landed stack), mark the phase
  [BLOCKED], record the exact obstruction (qnf pattern + failing statement), and escalate per
  the lean4 escalation rule — recommend `/spawn 350` for the missing primitive rather than
  landing a vacuous or sorry'd encoding.
- If a phase overruns its H8 budget, split at the pre-declared seams (2a/2b, 4a/4b) and resume
  with `/implement 350`.
