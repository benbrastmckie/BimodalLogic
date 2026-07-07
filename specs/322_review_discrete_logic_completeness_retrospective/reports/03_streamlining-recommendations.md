# Streamlining Recommendations: Discrete-Logic Completeness (Dispatchable Guidance)

- **Task**: 322 - review_discrete_logic_completeness_retrospective
- **Date**: 2026-07-07
- **Type**: Streamlining-recommendations document (Phase 2 deliverable)
- **Derived from**: `reports/01_completeness-retrospective.md` (H4-verified research report,
  Recommendations 1-7) and `reports/02_completeness-retrospective-review.md` (retrospective
  review; section anchors §1-§8 cited throughout)
- **Status of design decisions**: D1-D3 and the strengthened Rec-1 framing are SETTLED (review
  §7); this document dispatches them, it does not re-argue them.

---

## 1. Dispatchable Recommendations (priority order preserved from the report)

Each entry carries the five required fields: What / Owner / Trigger-Gate / Concrete next
action / Citation. Priority order is the research report's.

### Rec 1 — Make the patch-vs-rebuild decision explicitly, in writing, before the next implementation dispatch [Strategic, do first]

- **What**: A written decision memo choosing between Option A (patch: b3 nested sub-bracket on
  the landed `fChainFrom`/`fChainPred` + `VVecEA2` assets, tasks 320/321 as scoped) and
  Option B (rebuild: interval-typed EA-formula datatype + Lemma 3.2(2) arity firewall +
  witness-count induction, ~700-1050 lines per `305/reports/37` §4.4). **Settled framing
  (strengthened Rec-1, review §7): Option A runs FIRST as a bounded, falsifiable probe
  (already de-risked by task 320's litmus), with Option B PRE-AUTHORIZED as the fallback if
  the b3 probe fails the litmus.** Do not enter a fifth carrier iteration.
- **Owner**: planner (task 321 plan / task 309 v8 re-point).
- **Trigger/Gate**: Blocks the next implementation dispatch — no k>0 proof work is dispatched
  until the memo exists.
- **Concrete next action**: Draft the memo as CANDIDATE task T-A below (or fold it into the
  next task-321 plan revision); the memo must state the probe's litmus criteria and the
  fallback authorization verbatim so an F5-style failure escalates to Option B without a new
  design debate.
- **Citation**: report Recommendations 1; `303/reports/20` §4 root cause #3;
  `305/reports/37` §4.4; review §7 (Rec-1 strengthened form).

### Rec 2 — Adopt the position-by-evaluation-point litmus as a hard design gate

- **What**: Reject on sight any candidate device that asserts a two-anchor positional
  identity inside a one-point formula. This single rule would have predicted F3→F4 a priori
  (review §4, F1-F4 table).
- **Owner**: planner.
- **Trigger/Gate**: Applied BEFORE machine-probing, as a GO gate (settled decision D3, review
  §7) — every proposed carrier/converter design passes or is rejected at plan time.
- **Concrete next action**: Copy the checklist block in §3 below into the guard set of the
  next task-321 / 309-v8 plan (it generalizes the existing G3/G5 guards).
- **Citation**: report Recommendations 2; `320/reports/01` Rec 2; review §5 (Divergence Map
  final row), §7 D3.

### Rec 3 — Run the faithfulness audit as a design gate, not a post-mortem

- **What**: Before any new carrier or converter is built, require a one-paragraph mapping of
  each proof step to a specific Rabinovich §5 result. Every past audit (303/20, 305/14,
  305/15, 305/22, 305/37, 305/40) found the same divergence — but only after ~10 failed
  dispatches (review §5).
- **Owner**: research/planner.
- **Trigger/Gate**: Precondition of dispatch: an implementation dispatch touching the k>0
  closure is not issued unless its plan phase carries the step-to-Rabinovich mapping (the G5
  discipline already exists; this moves it from reporting requirement to dispatch
  precondition).
- **Concrete next action**: Add "G5 mapping present" as a plan-format checklist item for k>0
  phases; the litmus checklist in §3 includes it as item 3.
- **Citation**: report Recommendations 3; report F-2.5/F-6.2 (`303/reports/20` §4:
  "stuck on this for 10+ dispatches"); review §5, §7.2.

### Rec 4 — Fix or replace the churn instrumentation

- **What**: Churn counters that read 0-5 against 18-40 real plan versions cannot enforce a
  three-strikes budget (`303/.orchestrator-churn-state.json`: `total_churn: 0,
  adversarial_triggers: 0` despite 18 plan versions and 8 refutations;
  `305/.orchestrator-churn-state.json`: `total_churn: 5` against ~40 plan versions). Count
  *plan versions targeting the same leaf* and *self-refuted intermediate lemmas*, not just
  orchestrator re-dispatches.
- **Owner**: orchestration/meta.
- **Trigger/Gate**: Trip escalation at three self-refutations on one target (the F4
  escalation — task 309 plan v7's "one-round uniformization budget", `309/plans/07:293-294` —
  is the model to institutionalize).
- **Concrete next action**: CANDIDATE task T-B below: extend the
  `.orchestrator-churn-state.json` counters and the `skill-orchestrate-hard` three-strikes
  logic to ingest the two new signals.
- **Citation**: report Recommendations 4; report F-2.6 (first-hand churn-state reads); review
  §4.6, §7.3.

### Rec 5 — Preserve the verdict-record house style and extend it

- **What**: The F1-F4 records and the landed NO-GO theorems
  (`f2_relativized_refutation`, `no_x_independent_formula_captures_future_zone_k1`) are the
  effort's best hygiene practice: no landed sorry on any live path, every NO-GO captured as a
  machine-checked obstruction or a cited prose verdict, all prior exhibits byte-preserved.
- **Owner**: implementer.
- **Trigger/Gate**: Standing practice on every dispatch — a failed attempt terminates in a
  verdict record, never in a silent revert or a landed sorry.
- **Concrete next action**: Carry the practice forward verbatim into the b3 probe (Rec 6):
  probe failure must land as a machine-checked counterexample or cited prose verdict in the
  same house style as `NfMultiAnchorBridge.lean:3884/:3957/:5204/:5532`.
- **Citation**: report Recommendations 5; report F-5 (house-style paragraph); review §6.

### Rec 6 — Scope the next b3 probe minimally

- **What**: A single nested-Until sub-bracket at k=2 using the codebase's own labelled
  Cor-5.4 shapes (`fChainFrom`/`fChainPred`, `EANegation.lean:552/:567`), evaluated at the
  honest point, tested against the **mandatory F4 ℤ counterexample**: `M=ℤ`, `p={0}`,
  `r={13}`, `x=10`, `t=20`, `σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` false. No
  full carrier surgery until the minimal probe passes the litmus.
- **Owner**: implementer (task 321).
- **Trigger/Gate**: Dispatched only after Rec 1's memo exists and the design passes the §3
  litmus checklist (D3 ordering: litmus before machine-probing).
- **Concrete next action**: CANDIDATE task T-A below re-points task 321's first
  implementation phase at exactly this probe with the counterexample data as the acceptance
  test.
- **Citation**: report Recommendations 6; `309/reports/06_spawn-analysis-f4.md:48-64` (F4
  counterexample data); review §3 (Recent row), §5 (Cor 5.4 row).

### Rec 7 — Do not reopen the barred routes

- **What**: The four refuted route families in the §2 register below stay CLOSED. The
  recommendations budget is spent on b3 (and, on litmus failure, the Option B rebuild) —
  never on re-litigating a barred route.
- **Owner**: all (planner, implementer, orchestrator alike).
- **Trigger/Gate**: Permanent; reopening requires a concrete counterexample to the recorded
  refutation, not an appetite for "one more variant."
- **Concrete next action**: Include the §2 register (or a pointer to it) in every future k>0
  plan's Postmortem Constraints section.
- **Citation**: report Recommendations 7; report F-2.1/F-3; review §4, §7 D2.

## 2. Barred Routes Register (all CLOSED)

Per report Rec 7 and settled decision D2 (review §7): these are refuted, not dormant. None is
an "option worth revisiting."

| Route | What it was | Refutation citation | Status |
|-------|-------------|---------------------|--------|
| Route a: provider-side pinning | Pin the joint content on the provider side of the bracket | F-A circularity (report Recommendations 7) | **CLOSED** |
| `nvar_transfer` / cross-structure-transfer family | Transfer NF agreement between structures M and N | 303 postmortem + 2 independent vacuity audits (report Recommendations 7); "the root architectural divergence" (`303/reports/20` §3 row 17) | **CLOSED** |
| Arity-tower descent | NF-depth induction forcing `(k+1,1)→(k,2)→…→(0,k+2)` | "artifact … NOT in Rabinovich" (`305/reports/14`, `305/reports/15` §3); Lemma 3.2(2) ≤2 cap (Rabinovich md:76-79); review §4.4 | **CLOSED** |
| Flat-carrier `kvE''` iterations (any fifth carrier) | Another single-point carrier channel atop `bracketEndChar_kv/kvE/kvE'` | F1-F4 refutation lineage (`NfMultiAnchorBridge.lean:3884/:3957/:5204/:5532`); F2 machine-checked `f2_relativized_refutation`; review §4 F1-F4 table | **CLOSED** |

Also barred by the same doctrine (review §5): routes **b1** (repair the pin to consume
`witnessZone`) and **b2** (structural-identity via `nf_eval_unique`) — "formalization-
engineering shortcuts with no counterpart in either Rabinovich or Gabbay"
(`320/reports/01:31-37`).

## 3. Litmus Design Gate (copy-pasteable checklist block)

Intended for direct inclusion in a future task-321 / 309-v8 plan guard set. Apply BEFORE any
machine-probing (D3, review §7).

```markdown
### Design Gate: k>0 candidate device checklist (all three must pass BEFORE dispatch)

- [ ] **Position-by-evaluation-point litmus** (`320/reports/01` Rec 2; generalizes G3/G5):
      the candidate carries every two-anchor positional identity by WHERE a formula is
      evaluated (nested Until evaluation point, Cor 5.4 F_{i-1} := α_{i-1} ∧ (β_i Until F_i),
      Rabinovich md:154-157; single-free-var nesting, Prop 3.5, md:87-94). REJECT ON SIGHT
      any device that asserts a two-anchor positional identity (e.g. `e 1 = w, e 2 = x`)
      inside a one-point formula.
- [ ] **Arity firewall** (Rabinovich Lemma 3.2(2), md:76-79): every ∃∀ formula in the design
      is (equivalent to) a conjunction of ∃∀ formulas with ≤2 free variables. REJECT any
      step that grows arity (`(k+1,1)→(k,2)→…`) — the tower is a formalization artifact
      (`305/reports/14`, `305/reports/15` §3).
- [ ] **G5 faithfulness-mapping precondition** (report Recommendations 3): the plan phase
      contains a one-paragraph mapping of each proof step to a specific Rabinovich §5 result
      (Lemma 5.1 md:134-135, Lemma 5.3 md:137-152, Cor 5.4 md:154-157, or an explicitly
      named substitute). No mapping, no dispatch.
```

## 4. Candidate Follow-Up Task Descriptions

All three are **CANDIDATE only** — creation is deferred to the orchestrator/user; no tasks
were created in `specs/state.json` by this document (plan Postmortem Constraint: no direct
task creation).

### T-A [CANDIDATE] — Patch-vs-rebuild decision memo + b3 minimal probe re-point (report Rec 1+6)

> Write the patch-vs-rebuild decision memo for the k>0 completeness closure and re-point task
> 321 (or a task-309 v8 plan) at the minimal b3 probe. The memo records the SETTLED framing
> (task 322 review §7): Option A — a single nested-Until sub-bracket at k=2 on the landed
> `fChainFrom`/`fChainPred` (`EANegation.lean:552/:567`) + `VVecEA2` assets — runs first as a
> bounded, falsifiable probe; Option B — the interval-typed EA-formula rebuild with
> witness-count induction and the Lemma 3.2(2) arity firewall, ~700-1050 lines per
> `305/reports/37` §4.4 — is pre-authorized as the fallback if the probe fails the litmus.
> The probe's mandatory acceptance test is the F4 ℤ counterexample: `M=ℤ`, `p={0}`, `r={13}`,
> `x=10`, `t=20`, `σ''=char[14,16,11,20]` (honest `char[14,15,10,20]` false;
> `309/reports/06_spawn-analysis-f4.md:48-64`). The plan must embed the task-322 litmus
> design-gate checklist (322/reports/03 §3) as a guard set and the barred-routes register
> (§2) as Postmortem Constraints. No full carrier surgery until the probe passes the litmus;
> probe failure lands as a verdict record in the F1-F4 house style, then escalates directly
> to Option B — no fifth carrier.

### T-B [CANDIDATE] — Churn-instrumentation fix: count plan versions and self-refuted intermediates (report Rec 4)

> Fix the orchestration churn instrumentation so the three-strikes guard can actually fire.
> Evidence: `303/.orchestrator-churn-state.json` read `total_churn: 0, adversarial_triggers:
> 0` against 18 plan versions and 8 refutations; `305/.orchestrator-churn-state.json` read
> `total_churn: 5` against ~40 plan versions (task 322 report F-2.6). Extend the
> `.orchestrator-churn-state.json` counters and the `skill-orchestrate-hard` three-strikes
> logic to count (a) plan versions targeting the same leaf goal and (b) self-refuted
> intermediate lemmas (counterexample-refuted devices, per the F1-F4 model), not just
> orchestrator re-dispatches. Trip escalation at three self-refutations on one target,
> institutionalizing the F4 escalation pattern (`309/plans/07:293-294`, the one-round
> uniformization budget). Meta task; touches `.claude/` orchestration scripts/skills only, no
> Lean tree changes.

### T-C [CANDIDATE] — Lean-extension context note: litmus + arity firewall (report Context Extension Recommendation)

> Capture the "position-by-evaluation-point litmus" and the "arity firewall (Rabinovich Lemma
> 3.2(2), md:76-79)" discipline as a reusable lean-extension context note (e.g. under
> `.claude/extensions/lean/context/`), so future k>0 dispatches gate on them by default
> instead of rediscovering them after ~10 dispatches (task 322 report F-2.5, F-6.2). Content:
> the copy-pasteable design-gate checklist from 322/reports/03 §3 (litmus, arity firewall, G5
> faithfulness-mapping precondition), plus the Rabinovich §5 anchor list (Def 3.1 md:61-74,
> Lemma 3.2(2) md:76-79, Prop 3.5 md:87-94, Prop 4.2 md:100-101, Lemma 5.1 md:134-135, Lemma
> 5.3 md:137-152, Cor 5.4 md:154-157 in
> `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`).
> Meta task; markdown only. (Context-gap task creation was disabled at report time; this
> candidate exists for manual review.)

## 5. Cross-Reference Map (recommendations ↔ review sections)

| Entry | Review-document anchor (`reports/02_completeness-retrospective-review.md`) |
|-------|------------------------------------------------------------------|
| Rec 1 (patch-vs-rebuild) | §1.4 (headline), §7 (D1 + Rec-1 strengthened form) |
| Rec 2 (litmus gate) | §5 (Divergence Map, Prop 3.5 row), §7 (D3) |
| Rec 3 (audit as gate) | §4.5 (late audit detection), §5 (six audits), §7.2 |
| Rec 4 (churn instrumentation) | §4.6 (instrumentation did not fire), §7.3 |
| Rec 5 (verdict-record style) | §4 (F1-F4 table), §6 (house-style paragraph) |
| Rec 6 (minimal b3 probe) | §3 (Recent row: flattening defect), §5 (Cor 5.4 row) |
| Rec 7 / §2 register | §4.1-§4.4 (failure modes), §5 (b1/b2/b3 verdict), §7 (D2) |
| §3 litmus checklist | §5 (Divergence Map rows 3, 5, 6), §7 (D3) |
| T-A/T-B/T-C candidates | §1.4, §4.6, §4.5 respectively |

---

## Provenance

Derived entirely from the H4-verified research report
(`reports/01_completeness-retrospective.md`, Recommendations 1-7, F-2, F-3, Rec 7 barred-route
list, Context Extension Recommendation) and the Phase 1 review
(`reports/02_completeness-retrospective-review.md`, §1-§8). No citation was weakened from the
report's file:line / md:NN anchor form; no new diagnostic claims were introduced; no follow-up
tasks were created (T-A/T-B/T-C are descriptions only, marked CANDIDATE). Settled decisions
D1-D3 and the strengthened Rec-1 framing are dispatched here as settled, per the plan's
Postmortem Constraints.
