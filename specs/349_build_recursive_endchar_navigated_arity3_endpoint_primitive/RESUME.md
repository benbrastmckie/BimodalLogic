# Task 349 — Resume Brief (fresh-context handoff)

**Session:** sess_1783841542_df767b · **Date:** 2026-07-12 · **Status:** `implementing`, v7 plan, Phase 1/6 GREEN · tree clean

## One-line state
endChar is being (re)built on its **final carrier** (enriched-segment bracket `kvE2Ext`) after 4 ruled-out carriers; v7 Phase 1 (the load-bearing fold bridge) landed green/sorry-free. Resume at **v7 Phase 2**.

## Why endChar matters (the finish path)
`completeness_discrete` (BXCanonical/Completeness.lean:336) still carries `sorryAx`. Its SOLE on-path obligation is `nf_nvar_exist_all_depths` (KampPrior.lean:212, n=1 arm :361). Route to close it:
```
349 endInterval (v7, in progress) → 350 arm-hooks (k0/k1) → 309 Phase 14/18-19 wires KampPrior:361 → retire n+2 arm → task 95 #print axioms audit → completeness_discrete GREEN
```
(ROADMAP's "task 303 / KampBypass.lean sole sorry" is STALE — that file is Boneyard'd. Fixed in this session.)

## The carrier decision (settled — do NOT re-litigate)
Carrier 3 = **enriched-segment bracket `bracketEndChar_kvE2Ext`**: interior read at FULL arity 4 (no `nfk_projFresh` projection), GREEN at k=2 (`bracketEndChar_kvE2Ext_correct_two_prior_frag`, ExteriorBracket.lean:1069), F1/F2-immune, downstream-matched (309/350 want a closed Formula under Prior). Chosen by a 5-report research team + synthesis (reports 09_*) + GO probe (report 10). **Four DEAD alternatives (do NOT revisit):** single-point `→TemporalPred` (v4/v5, non-theorem); syntactic VVecEA2 (v6, contradictory); `kv_body` C′ (machine-refuted by F2, RefutationF2.lean:859); pure Prop-valued D (core `navMultiAnchorForm` unbuilt + downstream-mismatched).

## v7 plan: `plans/07_enriched-bracket-carrier.md` (6 phases)
1. ✅ **DONE** General-k fold bridge `nf_eval_nfk_iff_efold` (NfEFold.lean tail, green, `6b6ef2196`). NOTE: implemented as a **full-arity fiber-split** — the literal arity-1 re-encoding is false at k≥1 (lossy collapse); off-fiber determinacy via `nf_eval_unique`. Phase-2 input `habove` is a sound one-directional exclusion, NOT a lossless projection.
2. ⏭ **NEXT** k-generalized exterior brackets (Prop-4.2 pinning at depth k)
3. `endIntervalStep` general-k body + `EndIntervalCorrectPrior` freeze
4. Step correctness — soundness + completeness (generalize the green k=2 gate to depth k)
5. Recursion close — `endInterval_correct` by induction on k
6. Axiom audit + whole-project build

## How to resume
`/orchestrate 349 --hard` (or dispatch v7 Phase 2 directly via `lean-implementation-hard-agent`, plan_path above, phase_number 2). Per-phase: green+sorry-free, `lean_verify = [propext, Classical.choice, Quot.sound]`, scoped `lake build`. Guards G1–G5 + the 8 "Do NOT" rules in the plan postmortem. Frozen (additive-only, no proof edits): SharedWitness, SubBracket2V, OuterGate, ExteriorBracket, ExteriorZoneTriage, ExteriorNegation, ExteriorNegationPast; also KampPrior, Lemma32Reduction, `nf_nvar_exist_all_depths` signature.

## Parallel / deferred tracks (this session's decisions)
- **Wave 1 cleanup**: ✅ DONE — archived ~2,100 lines of off-path Kamp probes to `Kamp/Boneyard/`; fixed 3 stale finish-line refs. Boneyard-correctness audit (report 09) confirmed archival correct, nothing important buried.
- **Task 341 SharedWitness refactor**: DEFERRED to post-completeness (per user). Strategy synthesized: `specs/341_.../reports/03_refactor-strategy-evaluation.md` (privatize-first → 10 modules + hub, ~41 phases). File-disjoint from endChar. Dependency chain encoded: `349→350→341→131→175`.
- **Minor follow-ups** (fold into end-stage cleanup): `Prop43.lean` name-collision (live vs Boneyard dupe); n+2-arm retirement (restrict `nf_nvar_exist_all_depths` domain n≤1) — belongs with task 95, edits KampPrior so out of 349 scope.

## Key artifacts
- Plan: `plans/07_enriched-bracket-carrier.md`
- Carrier research: `reports/09_carrier-synthesis.md` (decision), `09_teammate-{a,b,c,d}-*.md`, `09_boneyard-correctness-audit.md`, `reports/10_q3-uniform-k-probe.md` (GO)
- Prior refutations (context): `reports/04` (arity-4 non-theorem), `06` (Phase-3 adjudication), `07` (faithfulness), `08` (design resolution)
- Finish-line map: `specs/REVIEW_codebase-restructure/00_synthesis-and-recommendation.md` (+ §4b breakthrough, corrections)
- Usage note: weekly limit was hit mid-session; resets 3am America/Los_Angeles. All work committed & resumable.
