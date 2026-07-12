# Blocker Analysis: Task #309

**Parent Task**: #309 - offdiag_two_anchor_fi_chain
**Generated**: 2026-07-11
**Blocker**: Phase 18b (hook discharge for the `KampPrior.lean:361` `| 1 =>` arm) is blocked because
the recursive navigated arity-3 endpoint primitive `endChar : EndCharCarrier sig k` (+
`endChar_correct`, recursion on `k`) that the three arm-correctness lemmas' hooks (`h_quant` past/
future, `h_past`/`h_fut`/`h_diag`) depend on was never built — only its `k = 0` base (`endChar0`)
and the non-trivial interior segment (`seg`) exist.

## Root Cause

**Category: Missing prerequisite (structural, not a budget overrun).** The orchestrator handoff
(`.orchestrator-handoff.json`, blocker `P18b-endChar-recursive-core-unbuilt`, confidence "high —
grep-confirmed") records a decisive single-owner audit cycle that made zero code edits after
confirming a hard wall:

1. **The three arm-correctness lemmas Phase 18b must consume have ZERO dischargers anywhere in
   `Theories/`** (grep-confirmed, referenced only in docstrings):
   `nf_char2_past_formula_correct` (`Base.lean:1230`), `A_diag_correct` (`Base.lean:758`),
   `nf_char2_future_formula_correct` (`Base.lean:1430`). Their `h_quant`/`h_past`/`h_fut`/`h_diag`
   hooks (deferred exactly as Phases 4/5 designed them to be, per `Base.lean:1117` and the
   `seg_holds_coupled` docstring at `Base.lean:1144-1149`) have never been discharged.

2. **Those hooks bottom out at the unbuilt recursive `endChar` primitive.** Confirmed by direct
   read of `Base.lean:927-1163` ("Phase 6/7/8 (task 309)" docstrings):
   - **Phase 6 (landed, sorry-free)**: `endChar0` (`Base.lean:995`) — the depth-0 base, a genuine
     non-vacuous `w`-locus atom characteristic. Its full navigated correctness (`endChar0_correct`,
     `Base.lean:1056`) needed a Phase-8 correction: the Phase-6 free-anchor statement was **provably
     false** (a closed navigated-`w` `TemporalPred` cannot read arbitrary carrier anchors `a,b` —
     concrete counterexample in-file, `Base.lean:1036-1047`). The corrected `endChar0_correct` adds
     an anchor+order **residual hypothesis** `h_res` and is sorry-free under it.
   - **Phase 7 (landed, sorry-free)**: `seg` (`Base.lean:1127`) — the Rabinovich `β_i` non-trivial
     interior segment, `seg_holds_correct` and the hook-parametric `seg_holds_coupled`
     (`Base.lean:1150`, hook `h_endChar`).
   - **Phase 8 (NEVER DISPATCHED)**: the *recursive* primitive `endChar : NormalForm sig k 3 →
     TemporalPred` + `endChar_correct` by recursion on `k` (base = `endChar0`, step = navigable-
     brick flatten of each sub's `∃w'` with Phase-7 segments for the interior and Phase-6/8
     endpoints for the exteriors). `Base.lean:958-969` states explicitly: *"the `nf_eval_nf` quant
     layer at depth `k+1` structurally needs arity-4 sub-evaluations ... which the fixed arity-3
     `EndCharCarrier` interface cannot recursively consume without the brick-witness-collapse core
     (report 02 §4.1/§4.2, ~300-500 lines; anchor-management, NOT `nf_char3_deeper_split`)."* This
     is a structural gap, not a proof-search difficulty: the interface exists (`EndCharCarrier`,
     `Base.lean:1007`), but no term of type `(k : Nat) → EndCharCarrier sig k` satisfying
     `endChar_correct` has been constructed.

3. **Even the `k=0` arm needs an additional, not-yet-built aggregation step.** The orchestrator
   handoff's audit found that discharging the hooks requires BOTH (A) an aggregate
   `quantEnd`/`seg` construction — a single `TemporalPred`/`BracketFormula 0` encoding ALL order
   patterns via 5-zone routing (the existing `seg endChar qnf` is per-`qnf`, not an
   all-order-patterns aggregate) — AND (B) discharge of `endChar0`'s `h_res` residual through the
   enclosing bracket segment. The `k=1` arm additionally needs the unbuilt recursive `endChar`
   from point 2.

**Independent confirmation**: report 02 (`reports/02_endpoint-hook-discharge-research.md`,
§6, "route (a) phase decomposition") independently proposed this exact split before any of it was
built — Phase 6 (base), Phase 7 (segment), **Phase 8 (recursive `endChar` assembly, ~120-200
lines)**, Phase 9 (hook discharge + `:351` rewire, ~60-120 lines). Phases 6-7 landed as designed;
Phase 8 was skipped in the plan's own re-decomposition into v9 Phases 15-19 (Phase 18 conflated
Phase-8's "build the recursion" with Phase-9's "discharge the hooks + rewire", and the recursion
build was never separately dispatched) — which is why 18b hits the wall report 02 called out four
dispatches ago (H5 divergence count: 4 strikes on this single target — 305 P11b, 307 P3, 307 P7,
309 P6).

**Independent (out-of-scope) blocker noted for completeness**: the orchestrator handoff also
records a second, structurally unrelated blocker — `hrealI`/`hrealB` (`OuterGate.lean:374/:380`)
need `x`/`t` anchor content that the frozen provider chain drops before calling `hreal`
(Track A, Phase 17). This is independent of the Phase-18b endChar wall, already has a named
successor recommendation (`~task 349`) in the handoff, and is explicitly NOT part of this
blocker_prompt's scope — it is not re-proposed here.

## Proposed New Tasks

### New Task 1: Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Effort**: high (6-10 hours; ~300-500 lines per the in-file Phase-8 estimate, `Base.lean:967-968`)
- **Task Type**: lean4
- **Rationale**: This is the hard structural prerequisite the orchestrator handoff and report 02
  both name as the true blocker. Nothing downstream (the aggregate hook discharge, Phase 18b/19)
  can proceed without a term `endChar : (k : Nat) → EndCharCarrier sig k` satisfying
  `endChar_correct`. It is fully self-contained: it consumes only already-landed, sorry-free
  assets (`endChar0`/`endChar0_correct` at `Base.lean:995/1056`, `seg`/`seg_holds_correct`/
  `seg_holds_coupled` at `Base.lean:1127-1162`, `nf_zone_flatten_navigable(_brick)/_correct` at
  `NfZoneFlattenNavigable.lean:689/709`) and does not touch `KampPrior.lean` at all.
- **Deliverables**: `endChar : (k : Nat) → EndCharCarrier sig k` defined by recursion on `k`
  (base case = `endChar0`; step case = navigable-brick flatten of each sub's `∃w'` composed with
  Phase-7 `seg`-shaped interior segments and Phase-6/8-shaped endpoint characteristics for the
  exteriors, arity capped at 3 per G4) plus `endChar_correct : ∀ k qnf w a b, (endChar k qnf).eval_at
  M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` under whatever residual/order hypotheses the
  recursion structurally requires (mirroring the `h_res` pattern `endChar0_correct` already
  established at the base — NOT a weaker or vacuous form).
- **Grounding**: `Base.lean:927-1163` (Phase 6/7/8 docstrings, the interface and both landed
  pieces); report 02 §6 "Phase 8" (`reports/02_endpoint-hook-discharge-research.md:266-270`);
  orchestrator handoff blocker `P18b-endChar-recursive-core-unbuilt` (`resolution` field).
- **Guards** (binding, inherited from the v9 plan's carried postmortem constraints): G1 (no
  arity-1 collapse), G2/G4 (anchors strictly `{a,b} ⊆ {x,t}`, ≤2, `w` never a third free anchor),
  G3 (non-trivial segment — reuse the landed `seg`, never `TemporalPred.top`), G5 (no
  `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step; manual bridges); no
  `nf_char3_deeper_split` (refuted route, report 02 §4.1: it grows the anchor set to 4, forbidden
  tower); no edits to the seven frozen provider files (`SharedWitness.lean`, `SubBracket2V.lean`,
  `OuterGate.lean`, `ExteriorBracket.lean`, `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`,
  `ExteriorNegationPast.lean`); do NOT touch `KampPrior.lean` or `nf_nvar_exist_all_depths`'s
  signature (this task's scope is `Base.lean` only, additive); axioms exactly
  `[propext, Classical.choice, Quot.sound]`; sorry-free (if a sub-piece cannot close green, mark
  `[BLOCKED]` and escalate per the lean4 vacuous-definitions/escalation rule — do not land a
  vacuous or `sorry`'d `endChar`).
- **Definition of done**: `lake build` GREEN (scoped `Base` module at minimum, full tree
  recommended); `endChar`/`endChar_correct` sorry-free; `lean_verify` on `endChar_correct` =
  exactly `[propext, Classical.choice, Quot.sound]`; no frozen-file edits; task 309's Phase 18/19
  can cite `endChar_correct` by name.
- **Depends on**: None.

### New Task 2: Build the aggregate `∀`-qnf `quantEnd`/`seg` construction and discharge the three arm-correctness hooks at k=0 and k=1
- **Effort**: high (6-10 hours)
- **Task Type**: lean4
- **Rationale**: Completes the prerequisite chain the orchestrator handoff's audit identified:
  even with `endChar`/`endChar_correct` in hand (New Task 1), the three arm-correctness lemmas'
  hooks are stated over an **aggregate** `∀ qnf` population match (`∀ qnf : NormalForm sig k 3,
  ((∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf)` via 5-zone routing), not the
  existing per-`qnf` `seg endChar qnf`. This aggregation, plus discharging `endChar0`'s `h_res`
  residual through the enclosing bracket segment, is what actually closes `h_quant`
  (`nf_char2_past_formula_correct`/`_future_formula_correct`) and `h_past`/`h_fut`/`h_diag`
  (`A_diag_correct`) at the two depths (`k=0`, `k=1`) task 309's Phase 18/19 needs. Building the
  k=0 and k=1 instances together (rather than as two separate tasks) is correct under the Task
  Minimization Principle: the aggregate `quantEnd`/`seg` machinery is generic over `k` and would be
  built once regardless of how many depth-instances consume it — splitting it into per-depth tasks
  would duplicate the aggregation work without any implementation-choice independence between the
  two instances.
- **Deliverables**: (a) the aggregate `quantEnd`/`seg`-shaped construction (a single
  `TemporalPred`/`BracketFormula 0` encoding the `∀`-qnf population match via 5-zone order-pattern
  routing — same house style as the landed per-arm zone triage, e.g.
  `nf_zone_exists_trichotomy_k1`); (b) discharge of `h_quant` (past, `Base.lean:1238-1241`;
  future, `Base.lean:1438-1441`) and `h_past`/`h_fut`/`h_diag` (`A_diag_correct`,
  `Base.lean:765-773`) as separate green lemmas for `k=0` and `k=1`, consuming
  `endChar_correct` (New Task 1) + `seg_holds_coupled` (`Base.lean:1150`) +
  `nf_zone_flatten_navigable_correct` (`NfZoneFlattenNavigable.lean:709`).
- **Grounding**: orchestrator handoff blocker `P18b-endChar-recursive-core-unbuilt` (`crux` and
  `resolution` fields, second successor); report 02 §6 "Phase 9" (`reports/
  02_endpoint-hook-discharge-research.md:272-279`, adapted — the `:361` rewire itself stays task
  309's own Phase 19, only the hook discharge is this task's deliverable).
- **Guards**: identical guard set to New Task 1 (G1-G5, no `nf_char3_deeper_split`, no frozen-file
  edits, sorry-free, axioms exactly `[propext, Classical.choice, Quot.sound]`); additionally V9-2
  (no `hexclExt` resurrection — this task's territory does not touch the `kvE2Ext` chain at all,
  so this is a non-issue but stated for completeness) and: do NOT edit `KampPrior.lean:352-364`
  (the sorry region itself and its transfer note stay task 309's own Phase 19 edit — this task
  lands consumable lemmas only, in `Base.lean` or an additive 309-owned wiring file, never the
  `:361`/`:364` sorry lines themselves).
- **Definition of done**: `lake build` GREEN; all new lemmas sorry-free; `lean_verify` on each
  named hook-discharge lemma = exactly `[propext, Classical.choice, Quot.sound]`; no frozen-file
  edits; no edit inside the `KampPrior.lean` recursion body; task 309's Phase 18b/19 can cite the
  k=0/k=1 hook-discharge lemmas by name to instantiate `kampPrior_case1_trichotomy_assemble`
  (`KampPrior.lean:1056`, the landed Phase-18a skeleton) and narrow `:361`.
- **Depends on**: New Task 1, because the `k=1` arm's hook discharge structurally requires
  `endChar_correct` at `k=1` — a term that does not exist until New Task 1 lands the recursive
  `endChar` primitive. (The `k=0` arm's discharge only needs the already-landed `endChar0`, but
  the aggregate `quantEnd`/`seg` construction is shared machinery across both depths, so splitting
  the k=0 portion into an independent task would fragment the aggregation work — see Rationale.)

## Dependency Reasoning

- **New Task 2 depends on New Task 1**: New Task 1 delivers `endChar_correct`, a specific
  recursively-defined term whose exact statement shape (in particular, what residual/order
  hypotheses it carries beyond the base case's `h_res`, per the `endChar0_correct` precedent) is
  not yet fixed by any existing artifact — it is a genuine implementation choice New Task 1 makes.
  New Task 2's `k=1` hook-discharge proof must consume `endChar_correct` by name at `k=1` and its
  proof structure (how it invokes `seg_holds_coupled`'s `h_endChar` hypothesis) is dictated by
  whatever hypothesis shape New Task 1 lands. This is a dependency on implementation details, not
  merely on completion: New Task 2 cannot even be *drafted* correctly until New Task 1's exact
  `endChar_correct` signature is fixed. (File-scope overlap check: both tasks list
  `Base.lean` in `file_scope`; the dependency above already serializes them, so no additional
  auto-dependency is needed — noted per the Component 4a overlap-check contract.)

## After Completion

Once both spawned tasks are complete, resume the parent task #309 with `/implement 309`. The plan
(`plans/09_offdiag-fi-chain-v9.md`) already carries the Phase-18a skeleton
(`kampPrior_case1_trichotomy_assemble`, landed green) ready to consume the hook-discharge lemmas
New Task 2 delivers; Phase 18b becomes a wiring/instantiation step rather than a from-scratch
proof, and Phase 19 can then execute the option-(a) `∀k`-lift case split and narrow `:361`
(closing the `k≤1` depths fully, per the Phase-15 GO-k1 verdict, with the `k≥2` residue routed to
its own pre-committed successor exactly as the v9 plan's Phase-19 routing already specifies).

The blocker will be resolved because: the recursive `endChar` primitive (New Task 1) and the
aggregate hook-discharge lemmas (New Task 2) are exactly the two missing pieces the orchestrator's
audit identified between the landed Phase-15/16/18a assets and a working Phase 18b — no other gap
was found. Task 309 itself does not need to build either piece in-task; it only needs to consume
them by name once landed.
