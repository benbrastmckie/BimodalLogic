# Task 309 Phase 13.3 Handoff — k=2 correctness gate: **NO-GO (exclusion-encoding)** (2026-07-06)

## VERDICT: NO-GO, exclusion-content encoding (report 05 F-D gap materializes)

## Immediate Next Action (orchestrator routing)

Run the plan v6 NAMED FALLBACK: **`/revise 309` (v7) inserting Phase 13.2b — uniformization**
(uniform per-sub exclusion/pinning formulas as FINITE DISJUNCTIONS over the finitely-generated
candidate family: subs, arrangements, point-type sets — all finite per depth; report 05 §c
contingency; carrier-side realization of Lemma 5.3/5.1 + Prop 4.2 per the G5 v6 extension),
then re-run the 13.3 gate ONCE. Phases 13.4 and 14 MUST NOT be dispatched before the re-run
gate returns GO.

## Current State

- Phase 13.3 [COMPLETED — NO-GO, exclusion-encoding]; v6 heading count: **14 of 16** gates/
  phases resolved (1-5, 6.1, 9-12, 13.0-13.3). Remaining: 13.4, 14 — both gated on the v7
  13.2b + gate re-run.
- `lake build` full tree GREEN (1709 jobs). NO partial theorem, NO sorry landed — the phase's
  only Lean artifact is the verdict record (doc section after NfMultiAnchorBridge.lean:5201,
  ~79 lines). Probe material removed before commit per gate discipline.
- Live-path sorry baseline unchanged: KampPrior:351 (task-309 strategic), KampPrior:354
  (task 305), EANegation:1090/:1249 (untouched, pre-existing). New sorries: 0. New axioms: 0
  (baseline 2). Vacuous defs: 0 new (1 pre-existing, Examples/TemporalStructures.lean:269,
  untouched).

## The Finding (what the gate established)

1. **Machine crux (soundness, per-sub positive case)**: after full destructuring, the ONLY
   hypothesis carrying a positive sub σ's joint content is
   `he : nf_eval_nf M 1 4 (insertEnv e t) σ` from `P.correct 3 σ M h_UZ h_SZ t` — the
   provider's `∃ env : Fin 3 → M.carrier` rebinds the u/w/x positions (anchor LAST). The goal
   needs `[u, w, x, t]`. Transfer attempts leave residuals `e 1 = w`, `e 2 = x` with no
   pinning hypothesis. All other extracted hypotheses are fresh-channel UNARY families
   (`P.existF 0` over `nfk_projFresh`).
2. **Refuting counterexample (provider-independent)**: M = ℤ (Prior UZ/SZ trivially: nonempty
   subsets of ℤ bounded below/above have min/max), preds p={0}, r={13}, x=10, t=20.
   `σ'' := nf_characteristic M 1 4 [14,16,11,20]` (fake anchors sharing only t; on-fiber,
   zone zXW, fresh type = type(14)); q := honest w=15 assignment with q(char[14,15,10,20]) :=
   false, q(σ'') := true. Carrier HOLDS at (10,20); realization FAILS for every witness
   w' ∈ (10,20) (per-w' kill list in the verdict record). So the k=2 statement is FALSE for
   the current carrier under ANY correct provider bundle — not merely unprovable proof-side.
3. **Kind classification**: exclusion-encoding, NOT carrier-shape — the failing channel is
   precisely the one the 13.2 exclusion-literal design record deferred to proof-side
   (negative/joint pinning); gate, zones, slots, unary families, arrangements all behaved
   exactly as at k=1. The proof-side negation stack cannot close it because its lemmas are
   model-dependent existentials (`∃ v, v.holds`) with no link to the fixed σ — the F-D
   caveat verbatim.

## What 13.2b must supply (v7 revision authority)

Uniform (carrier-side) per-sub content that pins each positive sub's joint claim against the
honest anchor pair — Rabinovich's own device: Prop 4.2 (md:100-101) uniform negation closure
via Lemma 5.1 (md:134-135) / Lemma 5.3 INF splitting (md:137-152), with Cor 5.4's F_i as TL
formulas (md:154-157). Finite disjunction indices per depth make this a bounded concrete
construction, not "try harder". NOTE for the reviser: the counterexample shows the gap hits
POSITIVE subs (joint pinning), not only negative subs (exclusion) — 13.2b must cover both;
the uniform-backward EANegation sorries (:1090/:1249) become in-scope ONLY through the v7
revision if it elects to consume them.

## Artifacts

- Verdict record: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
  (final section, after :5201 — R2 GO-record house style, N3 Def-3.1 lead, F1/F2 defect bar).
- Plan: Phase 13.3 heading `[COMPLETED — NO-GO, ...]` + BLOCKER block
  (`specs/309_offdiag_two_anchor_fi_chain/plans/06_offdiag-fi-chain-plan.md:781`).
- Previous handoff: `handoffs/phase-13.2-handoff-20260706.md` (13.2 entry points — still valid
  for the 13.2b designer; line references unchanged, verdict record appended at end of file).

## Sorry Inventory (unchanged — inherited live-path baseline)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:351` — strategic (task-309
  target); discharge deferred pending v7 ladder.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:354` — owned by task 305.
- Pre-existing elsewhere: EANegation.lean:1090/:1249 + Boneyard — untouched.
