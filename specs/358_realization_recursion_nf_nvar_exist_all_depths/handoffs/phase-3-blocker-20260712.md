# Task 358 — Phase 3 Blocker Handoff (2026-07-12)

## Immediate Next Action

Orchestrator: dispatch a **literature-grounded research pass** (Rabinovich 2014, Cor 5.4, §5 —
`~/Projects/Literature/sources/rabinovich_2014/` chunks 0013–0016) BEFORE any further Phase-3
implementation attempt, per the dispatch Recovery Discipline. The research pass must settle the
three questions in "What is needed" below. No code was changed in this dispatch; the tree remains
at the green Phase-2 state (HEAD `6453bee06`).

## Current State

- Phases 1–2 **[COMPLETED]** and committed green (`83fd80e78`, `6453bee06`).
- Phase 3 **[BLOCKED]** — no viable in-scope edit exists; no edit was made to KampPrior.lean.
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`: green as of the Phase-2 commit
  (unchanged tree).
- Sorries in task scope: KampPrior.lean:361 (`| 1 =>`), :364 (`| n+2 =>`) — both inherited,
  unchanged.

## The blocker, precisely (machine-grounded)

### Finding 1 — the four exterior `hbr*` obligations are undischargeable as stated (the pinning gap)

The plan's step-(a) map (report 01 §3: "`hbrFutReal` ← `kvE_futBundle_of_realizer hσ .1`") cannot
be executed. The obligations (`EndIntervalCorrectPrior`, EndIntervalConsumerK.lean:129–154;
mirrored at `kampPrior_site_rungK_gate_match`, KampPrior.lean:845–870) bind σ with
`qnf.2 σ = false` (UNMARKED σ) and quantify the exterior anchor `x1` universally with **no truth
antecedent** (`hbrFutReal`/`hbrPastReal`) or only the endpoint description (`hbr*Sat`). The
converter `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:208) requires as input a realizer
`hσ : nf_eval_nf M (m+1) 4 [x1,w,x,t] σ` — which, for unmarked σ, the site ambient REFUTES.

**Machine probe** (compiled green via `lean_run_code` against the verbatim binder shapes):
at the site with the strongest ⇐-direction ambient `h : nf_eval_nf M (m+2) 3 [w0,x,t] qnf`,
one derives

```
hno : ¬ ∃ x1', nf_eval_nf M (m+1) 4 (Fin.cons x1' (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ
```

from `(h.2 σ).mp` + `qnf.2 σ = false`, while the obligation goal
`∃ v, nf_eval_nf M m 5 [v,x1,w,x,t] s` (pinned fiber realization at an arbitrary `x1 > t`)
has no realizer-typed hypothesis in context. Semantic counterexample on a landed Prior model:
`P2M = (ℤ,<), P = {0,10,20}` (ExteriorFiberProbeK.lean) — take σ admissible whose atom layer
`σ.1` prescribes the predicate at the fresh (x1) slot and `x1` a non-predicate point above `t`;
no `v` realizes any on-fiber bit-true `s` pinned at `[v,x1,w,x,t]`.

**The interface authors' own concession**: task 356 summary
(`specs/356_discharge_depthk_hexclext_exterior_adjacency/summaries/01_…-summary.md:52-55`):
"This is **not derivable from `h`**: an unmarked σ (`qnf.2 σ = false`) is realized at NO `x1` …
so no realizer exists to feed `kvE_futBundle_of_realizer`." The obligations were threaded outward
(354 → 356 → 357 → 358) on the promise of discharge "one level up"; the KampPrior recursion body
is the outermost level — there is no further outward.

**Why the truth channels don't close it**: the obligations are consumed only inside
`kvE_extNeg{Fut,Past}_complete` (ExteriorConverterK.lean:126–137) at DESTRUCTOR-SELECTED anchors
under a local chain-firing ambient (`hpos : kvE_futPos …` truth) that the outward-threaded binder
shape does not carry. All landed truth channels (`kvE_futEnd` ExteriorNegationK.lean:395,
`kvE_futGapD`, chain items) deliver fiber realization with FREE outer env (`P.existF 4`-shaped,
`∃ env : Fin 4 → M.carrier`); the obligations demand realization PINNED to the site's `(w,x,t)`.
Deriving pinned from free is the un-landed **fiber-level existence converse** — exactly the
escalation atom the plan's Postmortem Constraints pre-named ("the fiber-level `HasAttainedINF`
existence converse (arity-5, general-depth mirror of EANegation.lean:571) — spawn THAT as the
isolated sub-task"). The Phase-2 realizer engine pins witnesses between bracket ENDPOINTS
(`kampPrior_fChain_realize_bracket`) but has no bridge from the `kvE_*` fiber-zone truth channel
to `BracketFormula` content one fiber level down.

**No vacuity escape**: the gate ⇐ half is vacuous for bit-false qnf (ambient `¬∃w` kills it),
but is genuinely needed for every REALIZED (bit-true) qnf in the `∀qnf` agreement — where the
same false `hbr*` instances arise (a realized qnf's unmarked σ population includes
atom-mismatched σ with bit-true fibers unrealizable at generic exterior points).

### Finding 2 — the carrier→formula arm assembly is not landed (independent gap)

Even with all eleven obligations discharged, retiring :361 requires folding the per-qnf
`VVecEA2` carrier biconditionals into the `| 1 =>` arm formula:
`∀qnf` agreement → `quantEnd`/`seg` hooks → `nf_char2_past_formula_correct` (Base.lean:1230) /
`A_diag_correct` (Base.lean:758) / `nf_char2_future_formula_correct` (Base.lean:1430) →
`kampPrior_case1_trichotomy_assemble` (KampPrior.lean:1133). No such fold exists:

- The task-349 `endCharRec`/`endChar` pipeline is docstring-frozen only (Base.lean:1521–1563 and
  :1954–1977 are inside `/-! -/` blocks; no declarations), and its base shape is machine-refuted
  (`endCharN0_correct_infeasible`, Base.lean:1779). Task 349 is [PLANNED], not done.
- The task-309 Phase-18/19 hooks are explicitly undischarged (KampPrior.lean:1123: "No hook is
  discharged here (that is the remaining frontier of Phase 18/19)").
- The old unconditional consumer `EndIntervalCorrect` is a dead branch (EndIntervalConsumerK
  header: "nothing external consumed it").
- The plan's "return `⟨endIntervalPrior atomMap h_surj charF Pfam k, proof⟩`" does not typecheck:
  `endIntervalPrior … k : BracketEndCharCarrierV sig k` (per-qnf `VVecEA2`), not a `Formula`;
  the `∀qnf` two-sided agreement (positives AND negatives) is not a `VVecEA2` disjunction.

Phase 3's "3–4 hours, mechanical" scoping (report 01 §3 "fall out mechanically") is therefore
mis-scoped on both counts.

## What is needed (research-pass questions)

Faithful technique: **Rabinovich 2014, Cor 5.4** (within-bracket realizer, §5) — the ⇐ argument
applied ONE fiber level down, plus Cor 5.4(2) re-anchoring in the existence direction.

1. **The pinned-realization converse (the true atom of difficulty)**: the faithful Lean statement
   deriving, from the chain/endpoint truth channel at a destructor-selected exterior anchor
   (`kvE_futEnd`/`kvE_futGapD` truth, free-env `P.existF 4` content), the PINNED fiber realization
   `∃ v, nf_eval_nf M m 5 [v,x1,w,x,t] s` — i.e., the arity-5, general-depth mirror of
   EANegation.lean:571 (`HasAttainedINF` converse), with `(w,x,t)` carried as bracket endpoints
   through the Phase-2 chain realizer.
2. **Interface restatement**: whether the `hbr*` binders in the chain
   (ExteriorConverterK.lean:126–134 → ExteriorBracketAssembleK.lean:181–191 →
   ExteriorGateAssembleK.lean:142–167 → KampPrior.lean:845–870 → EndIntervalConsumerK.lean:129–154)
   must carry the chain-firing truth antecedent under which they are actually consumed. This is an
   out-of-KampPrior-file-scope interface revision → new task or scope extension, per the task
   mandate ("out-of-file-scope escalation → [BLOCKED] + spawn, NOT an inline cross-file edit").
3. **The arm assembly route**: the carrier→formula fold for the `∀qnf` agreement (per-qnf
   positives via the carriers, negatives via their negation closure or by the ⇒-contrapositive),
   through the landed hook shapes (`h_quant`, Base.lean:1238–1241/:1438–1441) into
   `kampPrior_case1_trichotomy_assemble` — or a corrected endChar-style alternative. Relation to
   task 349's charter needs adjudication (the fold may BE task 349's deliverable).

## Key decisions of this dispatch

- No sorry-pass, no vacuous placeholder, no blind spawn — blocker reported for orchestrator
  escalation per dispatch Recovery Discipline.
- No code edit: the green Phase-2 state is preserved byte-identical (verified: clean git tree at
  `6453bee06` for `Theories/`).
- Settled-design re-open is justified: the anti-analysis contract permits re-opening a settled
  design decision on a concrete machine-documented counterexample; the `lean_run_code` probe +
  the task-356 written concession + the P2M semantic counterexample constitute it.

## Sorry Inventory

| file | line | statement | strategic | assumption | why_deferred | follow_up |
|------|------|-----------|-----------|------------|--------------|-----------|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `nf_nvar_exist_all_depths` `\| 1 =>` arm (n=1 critical) | yes (inherited, task-309 R1 scope) | arity-2 existential char formula at depth k+1 | Phase-3 blocker above (pinning gap + arm-assembly gap) | task 358 escalation (research pass, then revised Phase 3) |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `nf_nvar_exist_all_depths` `\| n+2 =>` arm (footprint) | yes (inherited) | arity-(n+1) existential at depth k+1 | Phase 4 deliverable, serialized after Phase 3 | task 358 Phase 4 |

No sorry introduced in this dispatch.

## References

- Plan (Phase 3 [BLOCKED] block): specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/02_realizer-recursion-implementation.md
- Phase-2 handoff: handoffs/phase-2-handoff-20260712.md
- Task 356 concession: specs/356_discharge_depthk_hexclext_exterior_adjacency/summaries/01_hexclext-discharge-exterior-gate-summary.md (lines 52–68)
- Rabinovich source: ~/Projects/Literature/sources/rabinovich_2014/ chunks 0013–0016 (Cor 5.4, Lemma 5.1/5.3, Def 7.5)
