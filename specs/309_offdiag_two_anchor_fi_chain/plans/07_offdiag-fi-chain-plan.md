# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v7

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IMPLEMENTING]
- **Effort**: ~14-20 hours (Phases 1-5, 6.1, 9-12, 13.0, 13.1, 13.2 landed; 13.3 gate completed = NO-GO; 4 open phases 13.25/13.35/13.4/14, ~610-900 lines Lean incl. one bounded gate RE-RUN)
- **Dependencies**: 310 (COMPLETE — `Kamp/NfEFold.lean` E[Σ]-fold landed sorry-free); 311 (COMPLETE — k=1 V-carrier `bracketEndChar_k1v_correct` GO, sorry-free)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1; source for the outer wrapper + import DAG)
  - reports/02_endpoint-hook-discharge-research.md (background only — "build the collapse brick / endChar" recommendation SUPERSEDED and adversarially OVERTURNED by report 03)
  - reports/03_rabinovich-faithful-path-research.md (Path B carrier reformulation; R1-R4 decomposition; the two-anchor bracket carrier authority)
  - reports/04_spawn-analysis.md (v4 revision authority — R2 k=1 NO-GO root-cause; spawned tasks 310 + 311)
  - reports/05_k2-vocab-enrichment-redesign.md (v6 revision authority — H4-verified k≥2 redesign after finding F1; route (a)-(d); the **§c contingency (finite-disjunction uniformization)** is the construction 13.25 realizes)
  - handoffs/phase-13.3-handoff-20260706.md (**REVISION AUTHORITY for v7** — the 13.3 NO-GO verdict, machine crux goal, provider-independent ℤ counterexample, and the explicit note that the gap hits POSITIVE subs (joint pinning) as well as negative-sub exclusion)
  - NfMultiAnchorBridge.lean Phase-13.3 verdict record (finding **F3**; final section after :5201 — R2 house style, N3 Def-3.1 lead, F1/F2 defect bar)
- **Artifacts**:
  - plans/01_offdiag-fi-chain-plan.md (v1, superseded)
  - plans/02_offdiag-fi-chain-plan.md (v2, superseded — endChar/seg route [ABANDONED ROUTE])
  - plans/03_offdiag-fi-chain-plan.md (v3, superseded — Phase 10 R2 NO-GO handoff superseded by v4)
  - plans/05_offdiag-fi-chain-plan.md (v4/v5, superseded — Phase 13 target refuted by F1)
  - plans/06_offdiag-fi-chain-plan.md (v6, superseded — Phase 13.3 gate returned NO-GO (F3); superseded by this v7 along v6's OWN pre-named fallback routing)
  - plans/07_offdiag-fi-chain-plan.md (this file, v7)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md, 04_spawn-analysis.md, 05_k2-vocab-enrichment-redesign.md

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Prop 3.5 /
Cor 5.4 `F_i` chain — so `KampPrior.lean:351` can be discharged (live sorries 2 → 1; `:354` stays,
task 305 scope). Definition of done: full `lake build` GREEN, `#print axioms` on the rewired
live-path theorem `nf_nvar_exist_all_depths` = exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

**Plan lineage (v1 → v2 → v3 → v4/v5 → v6 → v7).**
- **v1** — original outer-wrapper + navigated-characteristic route (Phases 1-5, 6.1 landed).
- **v2** — navigated arity-3 endpoint characteristic `endChar` (Phases 6-8); Phase 8 went [BLOCKED]
  on an arity-4 → arity-3 re-bounding obstruction. [ABANDONED ROUTE], code retained off the live path.
- **v3** — Path B pivot (report 03): two-anchor VecEA2 bracket carrier; R1 landed (Phase 9); k=1 gate
  (Phase 10, R2) returned NO-GO, root-caused (report 04) to `nf_eval_nf` per-depth arity growth.
- **v4/v5** — folded the spawned prerequisites (tasks 310 + 311, both COMPLETE) back into 309:
  E[Σ]-fold + k=1 V-carrier GO. Phase 12 (R3a) landed. Phase 13 (R3b) went [BLOCKED] on finding F1
  (unconditional ∀k `↔` FALSE at k=2 for the fiber-existential carrier).
- **v6** — report 05's redesign: statement surgery (`ExistProviders` + `BracketCarrierCorrectVPrior`,
  Phase 13.1 landed), F2 probe (Phase 13.0 landed — F2 CONFIRMED, machine-checked), per-sub enriched
  carrier `bracketEndChar_kvE` (Phase 13.2 landed), k=2 correctness gate (Phase 13.3).
  **Phase 13.3 completed with verdict NO-GO, exclusion-content encoding (finding F3)**: the k=2
  correctness statement for the 13.2 carrier is FALSE — machine-refuted by a provider-independent
  ℤ counterexample (verdict record, NfMultiAnchorBridge.lean final section after :5201). The F-D
  gap of report 05 materialized: the carrier's ONLY per-sub joint channel is the `t`-anchored
  provider literal `P.existF 3 σ`, whose `∃ env : Fin 3` REBINDS the non-`t` positions (crux
  residuals `e 1 = w`, `e 2 = x` with no pinning hypothesis); every other channel is fresh-channel
  unary; the proof-side negation stack is model-dependent (`∃ v, v.holds`) with no link to the
  fixed σ.
- **v7 (this revision)** — executes plan v6's OWN pre-named NO-GO fallback, transcribed into plan
  form and NOTHING beyond it (bounded scope): insert the uniformization phase the 13.3 routing
  named "Phase 13.2b" (here **Phase 13.25** — numeric sub-phase numbering keeps the orchestrator
  heading-scan dispatchable, exactly as v6 did for 13.0-13.4), then re-run the k=2 gate ONCE
  (v6-named "13.3-re", here **Phase 13.35**). **CRITICAL v7 correction carried from the 13.3
  finding**: the counterexample shows the gap hits POSITIVE subs (joint pinning — the crux
  residuals) as well as negative subs (exclusion — the original F-D subject). Phase 13.25
  therefore supplies TWO uniform channel families: (i) positive-sub joint PINNING formulas and
  (ii) negative-sub exclusion formulas, both as FINITE DISJUNCTIONS over the finitely-generated
  candidate family (subs, arrangements, point-type sets all finite per depth — report 05 §c
  contingency), realized CARRIER-SIDE per Rabinovich's own device (Prop 4.2 via Lemma 5.1 /
  Lemma 5.3 INF splitting; Cor 5.4's `F_i` are TL formulas). **Design choice (a): carrier channel
  extension** — a NEW `bracketEndChar_kvE'` extending `kvE_body`'s literal lists additively (the
  landed `bracketEndChar_kvE` is NOT edited; see Phase 13.25 for the (a)-vs-(b) justification).
  On a second NO-GO at 13.35 the routing is NOT another uniformization round: defect record +
  escalation to the orchestrator blocker ladder (see Phase 13.35).

  **Note on what F3 did and did not refute**: the 13.2 carrier `bracketEndChar_kvE` was NOT
  refuted as a definition — its k=2 CORRECTNESS STATEMENT was, via the missing pinning/exclusion
  channels. Phase 13.25 ADDS channels alongside the landed construction; all 13.2 deliverables
  (gate, zones, slots, unary families, arrangement machinery, `nf_eval_depth1_fold_iff`) behaved
  exactly as at k=1 and are consumed by name.

  **Retired deliverable names (carried from v6)**: the v5 unconditional deliverables
  `bracketEndChar_kv_correct` / `_sound` / `_complete` remain RETIRED (F1). NEWLY closed by F3:
  the 13.3 targets `bracketEndChar_kvE_correct_two` / `bracketEndChar_kvE_sound_two` /
  `_complete_two` **against the UNEXTENDED `bracketEndChar_kvE`** are refuted — do NOT restate
  them for that carrier; the 13.35 targets are the primed (`kvE'`) forms.

### Research Integration

reports/05_k2-vocab-enrichment-redesign.md integrated in plan version 6 (2026-07-06) and remains
the standing redesign authority; its §c contingency ("if 13.II-b NO-GOes on the exclusion-content
encoding … the fallback is a dedicated uniformization phase (finite disjunction over the
finitely-generated candidate family) before retrying — bounded, since all index sets
(`NormalForm sig k m`) are finite") is the construction Phase 13.25 realizes. The v6 findings
F-A/F-B/F-C/F-D/F-E and guard amendments A1/A2 are carried unchanged (transcribed in the v6
Research Integration section, plans/06_offdiag-fi-chain-plan.md:78-112 — not re-litigated here).

**New in v7 — finding F3 (2026-07-06, machine-refuted; NO new research report — the revision
authority is the Phase-13.3 handoff + the in-file verdict record):**

1. **F3 (machine-refuted)**: the k=2 correctness of the 13.2 carrier `bracketEndChar_kvE` is
   FALSE. Machine crux (soundness, per-sub positive case): the only hypothesis carrying a positive
   sub σ's joint content is `he : nf_eval_nf M 1 4 (insertEnv e t) σ` from
   `P.correct 3 σ M h_UZ h_SZ t` — the provider's `∃ env : Fin 3 → M.carrier` rebinds the u/w/x
   positions (anchor LAST); the goal needs `[u,w,x,t]`; transfer attempts leave residuals
   `e 1 = w`, `e 2 = x` with NO pinning hypothesis. Refuting counterexample
   (provider-independent): `M = ℤ` (Prior UZ/SZ trivially), preds `p = {0}`, `r = {13}`,
   `x = 10`, `t = 20`, dishonest positive sub `σ'' := nf_characteristic M 1 4 [14,16,11,20]`
   (fake anchors sharing only `t`; on-fiber; zone zXW; fresh type = type(14)) with the honest
   `char [14,15,10,20]` set false — LHS holds at `(10,20)`, RHS fails for EVERY `w' ∈ (10,20)`
   (full per-w' kill list in the verdict record). The failure survives ANY correct depth-1
   provider bundle, including Phase 14's.
2. **Kind classification**: exclusion-encoding, NOT carrier-shape — the failing channel is
   precisely the one the 13.2 exclusion-literal design record (:4956-4967) deliberately deferred
   to proof-side; gate, zones, slots, unary families, arrangements all behaved exactly as at k=1.
   The proof-side negation stack cannot close it (model-dependent existentials — F-D verbatim).
3. **What 13.25 must supply (verdict record + handoff, transcribed)**: uniform CARRIER-SIDE
   per-sub content pinning each positive sub's joint claim against the honest anchor pair —
   Rabinovich's own device: Prop 4.2 (md:100-101) uniform negation closure via Lemma 5.1
   (md:134-135) / Lemma 5.3 INF splitting (md:137-152), with Cor 5.4's `F_i` as TL formulas
   (md:154-157). Finite disjunction indices per depth make this a bounded concrete construction,
   not "try harder". The gap hits POSITIVE subs (joint pinning), not only negative subs
   (exclusion) — 13.25 must cover BOTH. The uniform-backward EANegation sorries (:1090/:1249)
   become in-scope ONLY through this revision if it elects to consume them — **this v7 elects NOT
   to consume them** (see Phase 13.25's blocker criterion).

reports/01 remains the source for the outer wrapper (Phases 1-5) and the import DAG (Phase 6.1).
reports/02 is retained for background only. reports/03 remains the Path B / carrier-reformulation
authority. reports/04 remains the v4 revision authority. v7 does not re-open any prior verdict.

### Corrected Anchor-Cap Statement (CARRIED FORWARD; still binding)

**The hook-discharge path MUST keep the anchor set at `{x,t}` (≤2, Rabinovich cap; G2/G4) by the
bracket-witness mechanism (report 03 §3 Path B, as amended by task 311's witness-growth), NOT by
`nf_char3_deeper_split`.** `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642) grows arity 3→4 and
anchors `{x,t}→{y,x,t}` (its statement, :628-637); composing it at each depth-descent builds the
forbidden anchor tower. The v1 route-audit comments at NfMultiAnchorBridge:661,:676-678
("arity ≤3, anchor `{x,t}`") are false and MUST NOT be trusted. Interior witnesses stay **bracket**
witnesses (now possibly several per qnf, per the witness-growth amendment, the v6 per-sub
flattening, and the v7 pin-slot extension), recursion is on `k`; anchors strictly `{x,t}` (2,
fixed) at every depth.

> **Task 347 adjudication (2026-07-11, consumer record — Phases 13.4/14 + `KampPrior.lean:351`).**
> Source: `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md`
> (verdict (b) SUBSTANTIVE, H4-verified) + report 01 §7 Consumer guidance / §"MUST-CHECK (1)".
> **Phases 13.4/14 and the `KampPrior.lean:351` discharge must consume an interior+boundary gate PLUS
> a separate ADJACENT EXTERIOR bracket, with the interior/exterior seam at the anchors `x,t` — NOT a
> single monolithic all-arrangement `(x,t)` gate.** Rabinovich 2014 §5 brackets only **strictly
> interior** witnesses (`z0<x1<…<xn<z1`, Notation 5.2 / Lemma 5.3) under a **bounded** outer
> existential (Cor 5.4, `(∃z)^{<z1}_{>z0}`); it has **no exterior-completeness case** (Lemma 5.1 proof
> cases 1/2/3, pp.9–11 are interior/boundary only). Exterior arrangements `x1<x` / `x1>t` belong to the
> **adjacent intervals** `(−∞,x)` / `(t,∞)`, characterized by their own brackets and composed with the
> interior `(x,t)` bracket by adjacency (Prop 4.3 p.6 + Lemma 7.6 p.13 re-flatten), NOT by an
> exterior-exclusion proof on the interior bracket. **R1 has landed** (task 347, commits
> d370d438e/3b8aee3c4): the interior slice of the old monolithic residue is discharged from the depth-0
> order atoms, and the deferred `hexclExt` binder is now narrowed to **exterior-marked σ only**
> (`kvE2_outer_fold_frag`, `SharedWitness.lean:12665`; mirrored `OuterGate.lean:280` — the binder now
> additionally requires `¬(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`). **Do not expect** the
> 335 fragment gate to deliver a single all-arrangement `(x,t)` characterization; the exterior slice is
> the `prop43_exterior_reflatten` successor route
> (`specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`).
> The `KampPrior.lean:351` sorry stays DEFERRED to that successor (recorded here only — no Lean edit in
> task 347).

## Preserved / Live Assets (consume — do NOT rebuild)

Complete, sorry-free, MUST NOT regress. Every open phase (13.25, 13.35, 13.4, 14) consumes from
this list and does not rebuild or edit these.

| Component | File:line | Status | Role in v7 |
|-----------|-----------|--------|------------|
| `A_past` / `A_future` (segment-carrying) + `_correct` | NfZoneFlattenNavigable:335/:386 | Landed P1 | non-trivial-segment outer arms (consumed in Phase 14 or_congr) |
| `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | Landed P2 | off-diagonal atom layer; depth-0 atom decomposition in Phase 14 |
| `nf_char3_endpoint_tl` / `_correct` | NfMultiAnchorBridge:891/:907 | Landed P3 | arity-3 endpoint `TemporalPred` shape (hook-parametric; NOT the carrier) |
| `nf_char2_past_formula` / `_correct` | NfMultiAnchorBridge:992/:1015 | Landed P4 | past-arm F_i wrapper; `h_quant` (:1023-1026) discharged in Phase 14 |
| `nf_char2_future_formula` / `_correct` | NfMultiAnchorBridge:1185/… | Landed P5 | future-arm F_i wrapper; dual `h_quant` (:1223-1226) discharged in Phase 14 |
| `A_diag` / `_correct` | NfMultiAnchorBridge:763/:808 | Landed (task 307 P2) | diagonal `[t,t]` arm; `h_past`/`h_fut`/`h_diag` (:787-795) discharged in Phase 14 |
| `nf_zone_flatten_navigable(_brick)` / `_correct` | NfMultiAnchorBridge:689/:709 | Landed (task 308) | 5-zone `∃w` flatten |
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future — the Phase 14 three-way `or_congr` seam |
| `nf_3var_bracket_xyt` / `_correct` | VecEADecomp:233/:244 | Landed, sorry-free | the depth-0 witness collapse (atom layer) |
| `char_k1` / `_correct` | KampPrior:307/:310 | Landed, sorry-free | depth-`k` arity-1 point characteristic (E[Σ]-atom, Def 4.1) |
| E[Σ]-fold: `nf_eval_efold` | NfEFold:102 | Landed (task 310) | fixed-arity monadic fold evaluation (Def 4.1) |
| `efold_of_nf1` | NfEFold:472 | Landed (task 310) | fold-of-nf1 transport |
| `nf_eval_nf1_iff_efold` | NfEFold:490 | Landed (task 310) | k=1 whole-eval bridge |
| `nf_quant_layer_fold_k1_gate` | NfEFold:525 | Landed (task 310) | gate corollary (k=1) |
| **general fold engine `nf_quant_layer_fold_iff`** | **NfEFold:391** | **Landed (task 310)** | **consumed at each inner round of the per-sub flattening (13.25/13.35/13.4); never redefined** |
| zone semantics + split kit (`zoneHolds`/`EAtomDom`/`nf0_split_assemble`) | NfEFold:58/69/153-235 | Landed (task 310) | `nf0_split_assemble` is stated at general `n` (arity-5 use in the gate) |
| `BracketEndCharCarrierV` (abbrev) | NfMultiAnchorBridge:1855 | Landed 309 P9 / amended 311 P3 | the carrier TYPE (unchanged in v7) |
| `BracketCarrierCorrectV` | NfMultiAnchorBridge:1864 | Landed 311 P3 | unconditional predicate — kept for k≤1 statements |
| `bracketFromLists` (private) | NfMultiAnchorBridge:1883 | Landed 311 P3 | disjunct builder |
| `bracketEndChar_k1v` (k=1 V-carrier) | NfMultiAnchorBridge:1923 | Landed 311, sorry-free | depth-1 template + proof machinery |
| `bracketEndChar_k1v_correct` (R2 = GO) | NfMultiAnchorBridge:3378 | Landed 311, sorry-free; GO record :3394-3434 | k=1 correctness `↔` |
| `bracketEndChar_k1v_sound` / `_complete` (private) | NfMultiAnchorBridge:2325/:2966 | Landed 311 | direction templates |
| k1v helper kit | NfMultiAnchorBridge:2028/2052/2137/2255/2682-2825 | Landed 311 | reusable proof machinery (`k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`/`k1v_bracket_extract`/`k1v_reconstruct_nf3`/extract clones/`k1v_sorted_insert`/`k1v_sorted_realization`/`k1v_bracket_construct`) |
| `bracketEndChar_k0` / `_correct` | NfMultiAnchorBridge:1563/1577 | Landed 309 P9 | depth-0 base (six k0-mirror order hypotheses :1581-1594) |
| `bracketEndChar_kv` (Phase-12 def) + helpers (`nfk_take` :3480, `nfk_projFresh` :3499, `kv_body` :3530, `bracketEndChar_kv_one_eq` :3711) | NfMultiAnchorBridge:3438-3776 | Landed 309 P12 | stays as the landed k≤1 instance and F1 exhibit; NOT edited, NOT consumed at k≥2 |
| `bracketEndChar_kv_correct_zero` / `_one` | NfMultiAnchorBridge:3783/:3811 | Landed 309 P13 seam, sorry-free | k≤1 instances (lifted to the relativized predicate in 13.1) |
| `bracketEndChar_kv_factors` + F1 record | NfMultiAnchorBridge:3838/:3871-3934 | Landed 309 P13 seam, sorry-free | permanent defect exhibit |
| **F2 probe material + `f2_relativized_refutation`** | **NfMultiAnchorBridge, F2 section after the F1 record** | **Landed 309 P13.0, sorry-free** | **machine-checked F2 defect exhibit (UZ/SZ relativization does not rescue the kv carrier); read-only** |
| **`ExistProviders` + `BracketCarrierCorrectVPrior` + `bracketEndChar_kv_correct_zero_prior`/`_one_prior`** | **NfMultiAnchorBridge:4831-4918 region** | **Landed 309 P13.1, sorry-free** | **the A1 provider bundle + corrected R3b target predicate — 13.35's target predicate UNCHANGED (KD3)** |
| **13.2 kvE kit: `kvE_consistent` (:5000), `kvE_gate` (:5015), `kvE_body` (:5036), `kvE_body_gate_fail` (:5130), `bracketEndChar_kvE` (:5150), `bracketEndChar_kvE_two_eq` (:5167), `nf_eval_depth1_fold_iff` (:5187)** | **NfMultiAnchorBridge:5000-5201** | **Landed 309 P13.2, sorry-free (commit 22334d430)** | **NOT refuted as definitions (F3 refuted the k=2 correctness STATEMENT); `kvE'_body` (13.25) EXTENDS these literal lists additively — `kvE_body`/`bracketEndChar_kvE` themselves NOT edited; `nf_eval_depth1_fold_iff` is the A2 per-sub decomposition consumed at 13.35** |
| **Phase-13.3 verdict record (finding F3)** | **NfMultiAnchorBridge, final section after :5201 (~79 lines)** | **Landed 309 P13.3 (doc record; no code)** | **permanent defect exhibit: crux goal state + provider-independent ℤ counterexample + per-w' kill list — 13.25's PRIMARY design input and 13.35's adversarial test case** |
| `bracketBuildLeft/Right` / `_correct` | VecEATranslation:273/:503, :50/:234 | Landed | Prop 3.5 chain builders — VALID ONLY at fixed-endpoint literals `epL`/`epR` (rule N4) |
| `BracketFormula.existsBounded_right`, `VecEAClosure`, `VBracketFormula.existsBounded_right` | VecEAClosure:265/:371 | Landed | Lemma 3.4 bounded ∃-closure / witness-append (13.25/13.35/14) |
| `VVecEA2` structure + holds + disj | VecEAFormula:271/276/282/286 | Landed | witness-growing carrier codomain (two-point `holds` = anchor-cap TYPE invariant) |
| `nf_eval_unique` / `nfPred_correct` | NormalForm:245 / NfToVecEA:69 | Landed | distinctness of realizing points (use `nfPred_correct`, NOT KampPrior:168) |
| `nf_depth0_pair_cycle_empty'` | NfDepth0Generalized:93 | Landed | inconsistent-zone falsity pattern |
| `nf_succ_char_formula` / `_correct` | KampPrior:67/:81 | Landed, sorry-free | the architectural template: provider-conditional per-sub enrichment at arity 1 |
| `nf_nvar_exist_all_depths` (`char_k1` local, `n=0` arm) | KampPrior:211/307/339 | Landed except `:351`/`:354` | outer recursion; the rewire target; supplies `h_UZ`/`h_SZ` (:216-223) and recursive converters at all depths ≤ k (:273 pattern) |
| `HasAttainedINF` | PriorINF:202 | Landed, sorry-free | attained first occurrence for TL-definable P on subintervals |
| `prior_hasAttainedINF : semantic_prior_UZ M atomMap → HasAttainedINF M atomMap` | PriorINF:224 | Landed, sorry-free | bridge from `h_UZ` to the negation stack's key |
| `neg_interval_formula` (Lemma 5.1 fwd) | EANegationClosure:401 | Landed; file 0 sorries | proof-side obligations at 13.35 — MODEL-DEPENDENT (F-D constraint) |
| `neg_bounded_exists` (Cor 5.4 fwd) | EANegationClosure:492 | Landed | same |
| `neg_vecEA2` / `neg_2var_vec_ea` (Prop 4.2) | EANegationClosure:646/:720 | Landed | same |
| `neg_orderedPointsExist_is_vbracket` (Lemma 5.3) | EANegation:347 | Landed (EANegation's :1090/:1249 sorries are in uniform-backward variants, documented non-blocking — 13.25/13.35 MUST NOT consume them; see the blocker criterion) | INF splitting base |
| F-chain construction (`fChainFrom`/`fChainPred`) | EANegation:552/:567 | Landed | Cor 5.4 `F_i` builders — candidate shape source for the 13.25 pin/exclusion disjuncts |
| Import edge `…Kamp.NfMultiAnchorBridge` in KampPrior | KampPrior:4 | Landed P6.1 | cycle-safe; do NOT re-add/move (D1) |
| Import edge `…Kamp.NfEFold` in NfMultiAnchorBridge | NfMultiAnchorBridge:2 | Landed (311 P1) | cycle-free; do NOT re-add/move |
| Import edge `…Kamp.EANegationClosure` in NfMultiAnchorBridge | NfMultiAnchorBridge (13.1) | Landed 309 P13.1, compile-verified cycle-free | negation-stack access; do NOT re-add/move |

### Source-to-Implementation Mapping (H3, Tier 1)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (md chunk refs from report 05).

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|------------------------------|-----------|-------------|-------|
| Def 3.1: α/β over the CURRENT (per-round enriched) vocabulary; **every existentially chosen point pinned by the bracket's own interval decomposition (α_j + β_j on BOTH adjacent sub-intervals)** | p.4 (md:61-74) | `TemporalPred` slots (landed :1886/:1955); **v7: pin slots + segment conjuncts of `kvE'_body`** | 13.2 (landed) / **13.25** |
| Lemma 3.2(2): ≤2 free ANCHORS (not witnesses) | p.4 (md:76-79) | `VVecEA2.holds` two-point signature = TYPE invariant | all |
| Prop 3.5: `∃x_i` → Until/Since bracket witness (mechanism) | p.5 (md:87-94) | `bracketEndChar_k1v_correct` (k=1 template); kvE/kvE' step | 13.25/13.35 |
| Def 4.1 + p.6 note: E[Σ] atom = monadic fold, inside-out iteration | p.5-6 | `nf_quant_layer_fold_iff` (NfEFold:391) consumed per inner round; `nf_eval_depth1_fold_iff` (:5187) | 13.25/13.35/13.4 |
| Prop 4.3 fold round | p.6 | cited ONLY for "residual is ∨∃∀ over E[Σ] atoms" (rule N2) | 13.25-13.4 |
| **Prop 4.2 (negation closure): per-round joint/negative content at round k+1 carried by uniform negation-closure formulas — CARRIER-SIDE finite disjunctions** | **p.6 (md:100-101)** | **`kvE_exclConj` (negative-sub exclusion) — 13.25 NEW** | **13.25** |
| **Lemma 5.1 (bracket negation)** | **md:134-135** | **exclusion-formula construction template (carrier-side); `neg_interval_formula` (EANegationClosure:401) stays proof-side at 13.35** | **13.25/13.35** |
| **Lemma 5.3 (INF splitting base)** | **md:137-152** | **pin/exclusion disjunct shape (per-interval splitting); `neg_orderedPointsExist_is_vbracket` (EANegation:347) stays proof-side** | **13.25/13.35** |
| **Cor 5.4: `F_i` are TL formulas (the uniformity license)** | **p.7/p.9 (md:154-157)** | **`kvE_pinDisjuncts`/`kvE_exclConj` as fixed `Formula`s over finite index families; `fChainFrom`/`fChainPred` (EANegation:552/:567) candidate shapes** | **13.25** |
| Per-round provider threading | p.7/p.9 (md:154-157) | `nf_succ_char_formula(_correct)` pattern; `ExistProviders` (landed 13.1) | landed |
| §5 bracket `[α_0,…,α_n](z_0,z_1)` | p.7 (md:127-132) | `VVecEA2` / `bracketFromLists` (landed, reused) | 13.25 |
| Lemma 3.4: ∨∃∀ closed under bounded `∃x` (witness joins prefix) | p.5 (md:84-85) | `existsBounded_right` (VecEAClosure:265); pin-slot witness growth license | 13.25/14 |
| Dedekind completeness (attained INF over Prior structures) | — | `semantic_prior_UZ/SZ` (PriorDefs:22/:33); `prior_hasAttainedINF` (PriorINF:224) | 13.35 hypotheses |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | p.9 | `A_past`/`A_future`/`_correct` (P1 landed) | 14 or_congr |
| **Navigated arity-3 endpoint char (endChar route)** | **no paper counterpart** | `endChar`/`seg` | **ABANDONED ROUTE (v2 P6-P8)** |
| **`nf_eval_nf` per-depth arity growth `n→n+1`** | **no paper counterpart** | `NormalForm.lean:198-207` | **ENCODING artifact — routed around by the E[Σ]-fold (task 310)** |
| **Fiber-existential fold-bit read at k≥2** | **no paper counterpart** | `bracketEndChar_kv` successor case | **REFUTED at k=2 (F1)** |
| **Single-anchor (`t`-only) per-sub joint literal as the ONLY joint channel** | **no paper counterpart (Def 3.1 never produces this configuration — F3 record N3 lead)** | `P.existF 3 σ` in `epR` alone | **REFUTED at k=2 (F3); supplemented by the 13.25 pin/exclusion channels** |

## Postmortem Constraints

Binding rules for all implementation dispatches. Guards G1-G6 + Corrected Anchor-Cap + amendments
A1/A2 are carried from v6 VERBATIM (plans/06_offdiag-fi-chain-plan.md:207-346); rules N1-N5 are
carried VERBATIM from task 311 plan v3 / 309 v5/v6. They are restated here in full so this file is
self-contained.

**Guards G1-G6 + Corrected Anchor-Cap:**

- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial segment
  is model-independent and cannot re-identify the distinct origin `t`, so the hook is unsatisfiable
  off-diagonal. The `(x,t)` coupling MUST ride the non-trivial Rabinovich `β_i` segment (a real
  interval type, not `⊤`/trivial). Scoped: applies to `A_past`/`A_future` and the carrier interval
  types ONLY — the inner brick's trivial-top exterior brackets are sound and MUST stay untouched.
- **G4** — `w` stays a **bracket witness**. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor
  set is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 / Prop 3.5 `F_i` chains step-by-step (`F_n := α_n`,
  `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`). No `simp`/`omega`/`aesop` shortcut of a chain step
  (literature-fidelity policy). Cite Rabinovich PDF p.4-5 (Def 3.1 / Lemma 3.2(2) / Prop 3.5 / Def 4.1)
  at every chain step, using the N1/N2 splits. **v6 extension (report 05 §d)**: chain steps at k≥2
  must additionally cite Lemma 5.3/5.1 + Prop 4.2 (md:100-152) for exclusion content, keeping the N2
  discipline. **v7 note**: the 13.25 pin/exclusion builders are chain-step material — each cited
  per this extension.
- **G6** — The recursion carrier MUST be the **two-anchor bracket characteristic** with **fixed
  endpoints** `z_0, z_1` (Prop 3.5, PDF p.5), NOT an **arity-1 navigated point characteristic**
  (refuted report 03 §2; NfMultiAnchorBridge:1058-1069), nor an **interior-existential-witness
  evaluation of `alpha_0`** (EANegation.lean:1077-1080). G2 bars a projection tower with a third
  free anchor; G6's carrier is a two-anchor fixed-endpoint bracket, anchor count ≤2 (Lemma 3.2(2)),
  `{x,t}` fixed.

**G6 Amendment (BINDING; carried from task 311 plan v3 / 309 v4)**: G6's carrier SHAPE is unchanged
(two-anchor bracket, FIXED endpoints `{x,t}`, `w` a bracket WITNESS). Amended is ONLY the codomain:
`VecEA2 1` becomes witness-growing `VVecEA2` (refutation: dense-order counterexample
NfMultiAnchorBridge:1782-1796; Rabinovich license: Lemma 3.2(2) caps ANCHORS not witnesses; §5
bracket p.7; Lemma 3.4 ∃-closure). **G2/G4 survive unamended: no third ANCHOR ever.** The v7
pin slots are more witness growth under the same license — never anchors.

**v6 Amendment A1 (report 05 §d; realized by landed Phase 13.1):** the correctness *predicate*
carries `(h_UZ, h_SZ)` hypotheses and provider conditionality (`ExistProviders`): the target at
k≥2 is `BracketCarrierCorrectVPrior`, NOT the unconditional `BracketCarrierCorrectV`. This amends
the TARGET STATEMENT only, not G6's carrier shape. The unconditional predicate remains valid and
landed at k≤1. **v7 note (KD3 discipline, held at 13.3)**: the 13.1 predicate is UNCHANGED by this
revision — 13.35 targets the SAME `BracketCarrierCorrectVPrior`, applied to the extended carrier.

**v6 Amendment A2 (report 05 §d):** at k≥2 the per-sub read makes `NormalForm sig k 4` subs appear
as *indices/data* and as *per-sub proof obligations*. Rule: every per-sub obligation must be
discharged by inside-out application of `nf_quant_layer_fold_iff` at its innermost (depth-0) layer
with witnesses flattened into the bracket; NO NAVIGATED arity-3/4 characteristic, NO third anchor,
NO raw `nf_eval_nf M (k+1)` split that leaves a joint (n+1)-ary existential standing undischarged.
**v7 note**: the pin channels give the soundness direction exactly the per-interval data this
inside-out discharge needs — A2 is how the 13.35 re-run consumes them.

**v7 Amendment F3 (NEW — the 13.3 finding, added to the postmortem/risk register):**
**Positive-sub joint pinning gap.** A per-sub joint channel whose ONLY anchor is a single
evaluation point (the `t`-anchored provider literal `P.existF 3 σ`) is REFUTED at k=2: the
provider existential rebinds the non-`t` positions (crux residuals `e 1 = w`, `e 2 = x`), so a
dishonest positive sub with fake anchors sharing only `t` is carrier-indistinguishable from honest
content (machine-refuted, provider-independent ℤ counterexample — verdict record after :5201).
Required behavior (Def 3.1, N3 lead): per-sub joint claims pinned by the bracket's OWN interval
decomposition — point type AND both adjacent interval types at every chosen point, uniformized as
finite disjunctions (Prop 4.2 / Cor 5.4). Binding consequences:
- Do NOT re-attempt a design whose only per-sub joint channel is a single-anchor provider literal.
- Do NOT attempt provider-side pinning ("pinned-anchor converters"): a single-anchor TL formula
  evaluated at one point cannot uniformly express the relative positions `e 1 = w`, `e 2 = x`; a
  multi-anchor converter is not something the outer recursion supplies
  (`nf_nvar_exist_all_depths` produces single-anchor converters only — F-A) and demanding one is
  circular with the two-anchor characteristic under construction. (This is the (b)-route
  rejection; see Phase 13.25.)
- **Uniformization budget: ONE round.** Phase 13.25 + ONE gate re-run (13.35). A second NO-GO
  does NOT trigger a 13.2c — it escalates (see Phase 13.35 routing).
- The uniformization derives uniformity from FINITENESS of the candidate family (report 05 §c),
  NOT from the uniform-backward negation lemmas: EANegation :1090/:1249 stay out-of-scope; a
  construction or proof found to REQUIRE them is a BLOCKER finding to record and escalate, never
  a silent consumption.

**Rules N1-N5 (VERBATIM from task 311 plan v3):**

- **N1 (caveat C1)** — In every NEW doc-comment and chain-step comment, do NOT cite Prop 3.5 alone for
  the two-fixed-endpoint bracket. Required split: **Prop 3.5 (p.5)** = the one-free-variable
  ∃-witness→Until/Since folding *mechanism*; **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)** = the
  two-fixed-endpoint `(z_0,z_1)` framing.
- **N2 (caveat C2)** — For fold rewrite steps, cite the **Def 4.1 p.6 note** for the "innermost fold /
  iteration" reading and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over E[Σ] atoms"; the
  comment must note that the codebase realizes Prop 4.3's content locally via the fold, not via
  literal structural induction (305 report 14).
- **N3 (caveat C4)** — Any verdict/milestone doc-comment MUST lead with the Def 3.1 evidence: α_j/β_j
  are one-variable quantifier-free formulas, so the arity-4 residual `[x_1,w,x,t]` had no Rabinovich
  counterpart — a Lean `nf_eval_nf` arity-growth artifact; the fold restores Def-4.1 fidelity.
- **N4 (from the NO-GO record :1767-1796)** — Interior-positive content MUST be encoded as bracket
  WITNESSES ordered between the fixed endpoints, NEVER as `bracketBuildLeft`/`bracketBuildRight`
  chains anchored at an existential point of an endpoint TYPE. `bracketBuildLeft/Right` remain valid
  ONLY where the anchor genuinely is the fixed endpoint (the zPastX/zFutT endpoint literals in
  `epL`/`epR`).
- **N5 (arrangement disjunction)** — The model-dependent ORDER of interior witnesses is handled by a
  FINITE DISJUNCTION over linear arrangements inside `VVecEA2.disjuncts` — never by asserting a
  fixed order and never by an order-erasing shortcut. Distinctness of realizing points for DISTINCT
  complete types comes from `nf_eval_unique` (NormalForm:245); same-type multiplicity is NOT encoded.
  **v7 note**: the 13.25 pin family multiplies the SAME finite disjunction (old arrangements × pin
  arrangements per positive sub) — N5's mechanism, larger index, still finite at every depth.

**Do NOT:**
- Do NOT resurrect the plan-v2 `endChar`/`EndCharCarrier`/`seg`/`seg_holds_*` route or report 02's
  "collapse brick" recommendation. Code retained OFF the live path, MUST NOT be built on.
- **Do NOT restate the RETIRED v5 deliverables** `bracketEndChar_kv_correct` / `bracketEndChar_kv_sound`
  / `bracketEndChar_kv_complete` (unconditional forms) — refuted at k=2 (F1).
- **Do NOT restate the F3-refuted 13.3 targets against the UNEXTENDED carrier**: any dispatch
  attempting `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE atomMap h_surj P)` at k≥2
  for the 13.2 carrier as landed is a defect — the statement is FALSE (F3). The 13.35 targets are
  the primed (`bracketEndChar_kvE'`) forms only.
- **Do NOT edit `bracketEndChar_kv`** (:3630) or its helpers; **do NOT edit `bracketEndChar_kvE` /
  `kvE_body` / `kvE_gate` / `kvE_consistent` / `nf_eval_depth1_fold_iff`** (:5000-:5199) — the v7
  extension `bracketEndChar_kvE'` / `kvE'_body` is NEW alongside them (additive-only diff).
- Do NOT attempt gate strengthening on the `bracketEndChar_kv` carrier (refuted, F1 item 4).
- Do NOT attempt one-jump enriched-signature re-indexing (rejected, F-E.2).
- Do NOT use `nf_eval_efold` as the depth-k semantics (D7, NfEFold:373-375).
- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume all NfEFold assets
  BY NAME.
- Do NOT route hook discharge through `nf_char3_deeper_split` (grows the anchor set 3→4).
- Do NOT trust the v1 route-audit comments at NfMultiAnchorBridge:661,:676-678.
- Do NOT edit `nf_zone_flatten_navigable` inner-`w` trivial-top exterior brackets or
  `nf_char2_diag_exist_tl` (:190) exterior brackets (D4 — sound as-is).
- **Do NOT grow the ANCHOR count.** `VVecEA2.holds` stays two-point (VecEAFormula:276); endpoints
  `{x,t}` FIXED. Witness growth is licensed (G6 amendment + A2 + the 13.25 pin slots); anchor
  growth is not.
- **Do NOT encode interior-positive bits as type-anchored chains** (rule N4 — refuted device).
- Do NOT modify `bracketEndChar_k1v`/`_correct`, `bracketEndChar_k0`/`_correct`,
  `bracketEndChar_kv_correct_zero`/`_one` (or their `_prior` lifts), `bracketEndChar_kv_factors`,
  the F1/F2/F3 records, either R2 record, or any task-310/311 landed asset.
- Do NOT use EANegationClosure's model-dependent lemmas as if they were uniform formula
  equivalences: carrier construction (a fixed formula chosen before `M`) consumes them only
  (i) proof-side (per-model direction obligations at 13.35) or (ii) via the 13.25 finite-disjunction
  uniformization over the finitely-generated candidate family (report 05 F-D caveat + §c).
- **Do NOT consume EANegation :1090/:1249 (uniform-backward variants, pre-existing sorries)**:
  needing them is a BLOCKER criterion (record + escalate), not a license (v7 Amendment F3).
- **Do NOT attempt provider-side pinning / pinned-anchor converters** (v7 Amendment F3 — the
  rejected (b)-route).
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it
  (sole exception: an explicitly documented strategic-sorry + `follow_up_task`).
- Do NOT reintroduce an import cycle. The `EANegationClosure → Bridge` edge is LANDED cycle-free
  (13.1); all new material is additive in NfMultiAnchorBridge.lean / KampPrior.lean.

**MUST preserve:**
- All Preserved/Live Assets above (sorry-free, axiom-clean), including Phases 1-5, P6.1, Phases
  9-12, the 13.0 F2 probe material, the 13.1 interface, the 13.2 kvE kit, the F1/F2/F3 records,
  and all task-310/311 material byte-identical.
- The `:354` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green (1709 jobs baseline).

**Design decisions SETTLED (do not re-open without a concrete counterexample):**
- The constructive `A` is the Rabinovich Prop 3.5 / Cor 5.4 bracket `F_i` chain (report 03 VERDICT).
- The carrier is the two-anchor witness-growing `VVecEA2` bracket characteristic (G6 as amended).
- The quant layer is discharged ONLY via the E[Σ]-fold engine, applied inside-out per sub (A2).
- The k≤1 story is CLOSED. Not re-run, not re-proved.
- The v6 direction (report 05 route (a)-(d)) stands; F2 is CONFIRMED (machine-checked, 13.0);
  the 13.1 interface and 13.2 carrier body are landed and unchanged.
- **NEW (v7)**: the k≥2 joint/negative per-sub content is CARRIER-SIDE uniform finite-disjunction
  pinning/exclusion (report 05 §c contingency; F3 required behavior) — design choice (a), carrier
  channel extension. Provider-side pinning is REJECTED (F3 amendment). Do not re-litigate.
- The `:351` rewire (Phase 14) is live (D1); Phases 1-5 stay off the live import path except as
  Phase 14 consumers.

## Goals & Non-Goals

**Goals:**
- Land the uniformization (Phase 13.25, the v6-named "Phase 13.2b"): uniform per-sub PINNING
  formulas for positive subs AND exclusion formulas for negative subs, as finite disjunctions over
  the finitely-generated candidate family, realized as a carrier channel extension
  `bracketEndChar_kvE'` (additive alongside the landed `bracketEndChar_kvE`).
- Re-run the k=2 correctness GO/NO-GO gate ONCE against the extended carrier (Phase 13.35, the
  v6-named "13.3-re"), with the F3 counterexample as the adversarial test case.
- On GO: the general-k one-step correctness `bracketEndChar_kvE'_correct` (Phase 13.4, carried
  from v6 with consumables re-pointed).
- Discharge the four hooks, rewire `KampPrior:351` with providers instantiated from the outer
  recursion, close the `:351` sorry (live sorries 2 → 1), full `lake build` GREEN, axioms exactly
  `[propext, Classical.choice, Quot.sound]` (Phase 14, carried from v6 re-pointed).

**Non-Goals:**
- Closing `:354` (task 305 scope).
- Building or repairing the abandoned `endChar`/`seg` route.
- Re-encoding or re-deriving the E[Σ]-fold (task 310 deliverable — consumed by name).
- Re-running the k=1 gate, the 13.0 F2 probe, or the completed 13.3 gate against the UNEXTENDED
  carrier (F3 is settled; the re-run targets the EXTENDED carrier only).
- Proving the RETIRED unconditional ∀k theorem (F1) or the F3-refuted unprimed k=2 targets.
- Any `nf_char3_deeper_split`-based discharge (anchor-tower forbidden).
- Same-type witness multiplicity encoding (N5).
- **A second uniformization round ("13.2c") — BARRED.** A second NO-GO at 13.35 escalates
  (Phase 13.35 routing); it does not iterate.
- **Closing or consuming the uniform-backward EANegation sorries (:1090/:1249)** — out of scope;
  needing them is a blocker finding (v7 Amendment F3).
- Redesigning beyond the named v6 fallback (this revision's scope is BOUNDED to 13.2b + one gate
  re-run + re-pointing 13.4/14).

## Risks & Mitigations

- **Risk (High; the v7 concentration — pin-formula adequacy)**: the pin channel must be STRONG
  enough to kill fake-anchored positive subs (soundness — F3's `σ''` must fail the extended LHS)
  while staying WEAK enough that honest realizations satisfy it (completeness). **Mitigation**:
  the construction follows Def 3.1's own pinning discipline (point type + BOTH adjacent interval
  types per chosen point, per arrangement), which is exactly what the honest realization
  instantiates and exactly what `σ''`'s fake tuple cannot (the F3 kill list shows every
  arrangement fails at `(10,20)`); Phase 13.25 lands an honest-safety lemma
  (`kvE'_pin_honest`-shape) as an in-phase smoke check before the gate re-run; the F3
  counterexample is 13.35's mandated adversarial test.
- **Risk (Medium-High; combinatorial size of the pin family)**: the finite disjunction ranges over
  old arrangements × per-positive-sub pin arrangements × per-slot type assignments — index sets
  are finite per depth (report 05 §c) but their product can be large, risking elaboration
  blow-ups. **Mitigation**: represent index families as explicit `List` enumerations built by
  `flatMap`/`map`/`filter` (the landed `S_L.permutations.flatMap …` house pattern, kvE_body
  :5036); no `Fintype`/`decide` machinery on the carrier path; if the k=2 instance's unfolding
  becomes too heavy for the gate proof, 13.35's H8 split note applies (direction seam), not a
  carrier redesign.
- **Risk (Medium; symbolic-k channel depth)**: at symbolic `k`, σ's inner witnesses carry
  depth-(k-1) content, while the 13.1 bundle supplies depth-k converters only. **Mitigation**:
  `kvE'_body` stays PARAMETRIC in its formula-family channels (the Phase-12 KD1 `charF`-parameter
  house move): the pin channels take explicit formula-family parameters, instantiated at k=2 from
  `charBase`/`charK` (both depth-0/depth-1 available — no new provider needed at the gate), and
  at Phase 14 from the outer recursion (which supplies ALL depths ≤ k, all arities — F-A). If
  elaboration at 13.4 forces a depth-indexed bundle, that is a DOCUMENTED deviation confined to a
  NEW structure (e.g. `ExistProvidersLE`) — never an edit of the landed 13.1 `ExistProviders`,
  and never the pinning mechanism itself (which stays carrier-side, choice (a)).
- **Risk (Medium; second NO-GO)**: the uniformization might still not close a direction.
  **Mitigation**: the routing is pre-committed (Phase 13.35): defect record (F4 candidate) in the
  F1/F2/F3 house style + [BLOCKED] + escalation to the orchestrator blocker ladder — bounded loss
  (one definition phase + one gate re-run), no churn.
- **Risk (Medium; hidden dependence on the uniform-backward lemmas)**: a direction might appear
  to need EANegation :1090/:1249. **Mitigation**: pre-committed blocker criterion (v7 Amendment
  F3): STOP, record, escalate — never absorb; the 13.25 construction derives uniformity from
  finiteness, so no step should cite them.
- **Risk (Medium; provider availability claim at Phase 14)**: carried from v6 unchanged —
  `ExistProviders` instantiation from recursive calls is Medium-High confidence; fallback is
  threading converters as extra hypotheses through `nf_nvar_exist_all_depths` (surgery confined
  to KampPrior.lean, documented).
- **Risk (recurring; the churn root)**: a dispatch re-attempts a refuted device — now including
  the F3-refuted `t`-only joint channel and provider-side pinning. **Mitigation**: the Do-NOT
  list enumerates each refuted device with its refutation citation; v7 Amendment F3 adds the two
  new ones.
- **Risk**: Phase 14 puts the carrier on the live path and surfaces a latent axiom leak.
  **Mitigation**: Phase 14 runs full-tree build + `lean_verify` as explicit criteria; the
  newly-live subtree is grep-verified sorry-free.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each chain step
  (now including the pin/exclusion builders) cites Rabinovich with the N1/N2 splits and the G5
  v6 extension; no simp/omega/aesop on a chain step.

## Implementation History (landed / abandoned / retired — NOT open work)

These sections are history. None match the orchestrator open-phase heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`). Do not re-dispatch them.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

Landed, commit f4b9600a1. Segment-carrying `A_past`/`A_future` (NfZoneFlattenNavigable:335/:386) via
`bracketBuildLeft/Right_correct` (Rabinovich `β_i`). Sorry-free. Live consumer in Phase 14. History only.

### Phase 2: Off-diagonal atom layer for [x,t] [COMPLETED]

Landed, commit 762ea60da. `nf_char2_atom_offdiag_{origin,endpoint,correct}`
(NfMultiAnchorBridge:364/:375/:391), `order 0 1 = true`. Sorry-free; axioms clean. Consumed in
Phase 14 depth-0 atom decomposition. History only.

### Phase 3: Arity-3 endpoint-hook construction [COMPLETED]

Landed, commit 010ab616d. `nf_char3_endpoint_tl` + `_correct` (NfMultiAnchorBridge:891/:907), the
hook-parametric endpoint SHAPE (NOT the carrier). Sorry-free. History only.

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

Landed, commit fed9fcd8e. `nf_char2_past_formula` + `_correct` (NfMultiAnchorBridge:992/:1015), RHS
under `h_quant` (:1023-1026). Sorry-free. `h_quant` discharged in Phase 14 via the carrier. History only.

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

Landed, commit b60c63b1a. `nf_char2_future_formula` + `_correct` (NfMultiAnchorBridge:1185/…), dual RHS
under dual `h_quant` (:1223-1226). Sorry-free. Discharged in Phase 14. History only.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]

Landed, commit f3827e255. `import …Kamp.NfMultiAnchorBridge` in `KampPrior.lean` (D1, cycle-safe).
Full-tree GREEN. History only — do not re-add/move.

### Plan-v2 Phases 6-8 (endChar0 / EndCharCarrier / seg / seg_holds_*) [ABANDONED ROUTE — code retained, off live path]

Commits 131615736, 88a785d96, 901484b9c, f663811bb, 310ab8652, 8d8ce7dbf. The navigated arity-3
endpoint route. **Plan-v2 Phase 8 went [BLOCKED]** on the arity-4 → arity-3 re-bounding obstruction —
root-caused (report 04) to `nf_eval_nf`'s per-depth arity growth, an ENCODING artifact. Per report
03: do NOT delete this code, do NOT build on it, do NOT resurrect the "build the collapse brick"
recommendation. Inert, off-live-path. History only.

### Phase 9: Two-anchor VecEA2 bracket carrier reformulation + interface (R1) [COMPLETED]

Landed (309 P9). `BracketEndCharCarrier`/`BracketCarrierCorrect`/`bracketEndChar_k0`/`_correct`
(NfMultiAnchorBridge:1542/1552/1563/1577), the two-anchor carrier interface + depth-0 base with six
k0-mirror order hypotheses (:1581-1594). Sorry-free. The R1 SHAPE — carried forward and amended to the
witness-growing V-variant in Phase 11 (via task 311). History only.

### Phase 10: k=1 de-risking probe — DECISION GATE (R2) [COMPLETED — NO-GO, superseded by Phase 11]

Landed (309 P10; session sess_1783359214_93fd70). The decision-gate probe of the fixed `VecEA2 1`
carrier at `k=1` **completed** and returned **R2 = NO-GO**: the `k=1` fold left an irreducible arity-4
residual `[x_1,w,x,t]` (the plan-v2 Phase-8 obstruction, falsified at k=1 in one bounded dispatch). The
gate did its job — it root-caused the obstruction and triggered a `/spawn` (report 04). **This NO-GO is
SUPERSEDED by Phase 11**: report 04 established the residual is an `nf_eval_nf` ENCODING artifact (not a
carrier-shape defect); spawned tasks 310 (E[Σ]-fold) + 311 (k=1 re-probe) then re-closed the gate as
**R2 = GO** under the fixed-arity fold + the witness-growing V-carrier. The probe left
NfMultiAnchorBridge.lean sorry-free and green; no partial/vacuous carrier was committed. History only —
the NO-GO verdict is closed, not open work.

### Phase 11: Prerequisite gate closure via tasks 310 + 311 (E[Σ]-fold + k=1 V-carrier GO) [COMPLETED]

Landed via the two spawned prerequisite tasks (both COMPLETE), folded into 309 by the v4 revision.
This is the integration record; the code exists in the working tree, sorry-free, off the 309 live path
until wired by Phase 14.

- **Task 310** — `Kamp/NfEFold.lean` (the E[Σ]-fold encoding, Rabinovich Def 4.1): a fixed-arity monadic
  fold defined alongside `nf_eval_nf`, proved equivalent for the arity-3 two-anchor shape `[w,x,t]`.
  Load-bearing: `nf_eval_efold` (:102), `efold_of_nf1` (:472), `nf_eval_nf1_iff_efold` (:490),
  `nf_quant_layer_fold_k1_gate` (:525), general engine `nf_quant_layer_fold_iff` (:391), split kit
  (:153-235). Sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`.
- **Task 311** — the G6-AMENDED witness-growing carrier + the k=1 GO. `BracketEndCharCarrierV` (:1855),
  `BracketCarrierCorrectV` (:1864), `bracketFromLists` (:1883), `bracketEndChar_k1v` (:1923),
  `bracketEndChar_k1v_sound` (:2325), `bracketEndChar_k1v_complete` (:2966), the k1v helper kit
  (:2028/2052/2137/2255/2682-2825), and the assembled **`bracketEndChar_k1v_correct` (:3378)** with the
  **R2 = GO** verdict record (:3394-3434). The k=1 correctness `↔` closed with NO arity-4 residual and
  NO navigated arity-3 characteristic; anchors `{x,t}` (TYPE invariant of `VVecEA2.holds`). The fixed
  `VecEA2 1` codomain was refuted (dense-order counterexample :1750-1823) and amended to `VVecEA2`.
  Sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`; full tree GREEN (1705 jobs).
- **Integration effect on 309**: the R2 decision gate is now **GO**. Path B is viable at `k=1` under the
  fold + witness-growing carrier. History only — do not re-dispatch tasks 310/311.

### Phase 12: Depth-k V-carrier definition `bracketEndChar_kv` (R3a) [COMPLETED]

*(Landed 2026-07-06, NfMultiAnchorBridge.lean:3438-3776. Two documented realization deviations,
both within the phase's settled shape: (1) the depth-`k` char provider is a PARAMETER family
`charF : (j : Nat) → NormalForm sig j 1 → Formula` rather than a by-name consumption of
`char_k1` — `char_k1`/`nf_characterizable_temporal_prior` live in KampPrior.lean, which IMPORTS
NfMultiAnchorBridge (KampPrior.lean:4), so by-name consumption would re-create the import cycle
removed by task 307 P7; Phase 14 instantiates `charF` at the KampPrior call site (the
`nf_succ_char_formula`/`exist_tl_fn` parameterization pattern). (2) The depth-`k` fold bit is
read FIBER-EXISTENTIALLY (`b zs χ = decide (∃ sub, qnf.2 sub = true ∧ zoneSpec = zs ∧
nfk_projFresh sub = χ)`) rather than via a pointwise depth-`k` assemble — no such assemble
exists at `k ≥ 1` (D7, NfEFold:373: deeper joint quant layers are not determined by
`(zs, χ, qnf.1)`); under the gate's off-fiber conjunct this agrees with the `efold_of_nf1`
pointwise read at k=1 (split-kit bijection), discharged by the documented bridge lemma
`bracketEndChar_kv_one_eq` (pointwise EQUALITY, the acceptance's simp-bridge branch). New
helpers: `nfk_take` (depth-`k` prefix restriction), `nfk_projFresh`, private shared successor
body `kv_body` with `bracketEndChar_k1v_eq_kv_body : … = kv_body … := rfl`. Verification: full
tree GREEN (1705 jobs); 0 new sorries; `lean_verify` on `bracketEndChar_kv` AND
`bracketEndChar_kv_one_eq` = exactly `[propext, Classical.choice, Quot.sound]`;
`bracketEndChar_k1v` untouched.)*

**v6 status note**: `bracketEndChar_kv` remains landed and preserved as the k≤1 instance and the
F1 exhibit. Its successor-depth fiber-existential read is REFUTED at k≥2 (finding F1) — the k≥2
role is taken over by `bracketEndChar_kvE` (Phase 13.2), extended at k≥2 by `bracketEndChar_kvE'`
(Phase 13.25). History only.

### Phase 13 (v5): Depth-k V-carrier correctness `bracketEndChar_kv_correct` (R3b) [BLOCKED — RETIRED; superseded by Phases 13.0-13.4]

**RETIRED by the v6 revision — do not re-dispatch, do not restate.** The v5 target
`bracketEndChar_kv_correct` (unconditional ∀k `↔` for the Phase-12 carrier) is FALSE at k=2 —
finding F1 (2026-07-06), full record NfMultiAnchorBridge.lean:3871-3934:

- **Counterexample**: `M = (ℚ, <)`, `P = {q, p, r}`, `q < x < u₂ < p < u₁ < w < t < r`; `u₁, u₂`
  share their complete depth-1 1-type but `[u₁,w,x,t]` / `[u₂,w,x,t]` have distinct depth-1
  arity-4 types in one fiber `(zXW, χ, qnf.1)`. With `qnf :=` characteristic depth-2 3-type of
  `[w,x,t]` and `qnf' := qnf` with `sub₂` un-marked, the machine-checked
  `bracketEndChar_kv_factors` (:3838) gives carrier equality while no `w'` realizes `qnf'` in `M`
  — the two instances of the target `↔` are jointly contradictory. `qnf'` is realizable in a
  discrete chain, so no consistency side-hypothesis rescues the statement.
- **Why**: at k≥2 the fiber-existential fold-bit read discards joint deeper structure of the fresh
  witness relative to the anchors; the depth-0 split-kit bijection (NfEFold:235) has no k≥2 analog
  (D7, NfEFold:373). Rabinovich avoids this by ENRICHING the α_j/β_j vocabulary at every Prop-4.3
  fold round (Def 3.1 p.4; Cor 5.4's `F_i` are TL formulas, p.7).
- **NOT refuted**: the completeness direction at all k, and the k≤1 instances.
- **Landed green from the 13a seam (sorry-free, preserved)**: `bracketEndChar_kv_correct_zero`
  (:3783), `bracketEndChar_kv_correct_one` (:3811), `bracketEndChar_kv_factors` (:3838); full tree
  GREEN; `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]` on all three. Commits
  e5924f492, 0f1826739.

The corrected work was decomposed as Phases 13.0-13.4 by v6 (report 05 §c ladder). History only.

## Implementation Phases (13.0-13.3 completed records + Open — 13.25 / 13.35 / 13.4 / 14)

**Dependency Analysis (v7)**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 13.25 (uniformization — the v6-named "Phase 13.2b") | — (consumes landed 13.1/13.2 material + the F3 verdict record) |
| 2 | 13.35 (k=2 gate RE-RUN, ONCE — the v6-named "13.3-re") | 13.25 |
| 3 | 13.4 (general k, re-pointed at `kvE'`) | 13.35 = GO |
| 4 | 14 (hooks + :351 rewire, re-pointed at `kvE'`) | 13.4 |

Phases are strictly sequential (each consumes the previous phase's declarations by name; all edit
`NfMultiAnchorBridge.lean` / `KampPrior.lean` single-file territory, one owner per dispatch). One
agent run per phase (H8). The orchestrator dispatches exactly one open phase per cycle by
heading-scan.

**Numbering note**: the v6-named fallback phases "13.2b" and "13.3-re" are numbered **13.25** and
**13.35** here because the orchestrator heading-scan (`^### Phase [0-9]+(\.[0-9]+)?: …`) and the
numeric `phase_number` dispatch field require purely numeric sub-phase numbers (the same reason v6
used 13.0-13.4 for report 05's 13.0/13.I/13.II-a/13.II-b/13.III). 13.25/13.35 sort correctly
between the completed 13.2/13.3 records and the open 13.4.

**Branch discipline (pre-committed)**: the 13.35 verdict routes exactly two ways — GO → dispatch
13.4; NO-GO (either kind, second occurrence) → record the defect (F4 candidate) in the F1/F2/F3
house style, mark Phase 13.35 heading **[BLOCKED]**, and ESCALATE to the orchestrator blocker
ladder (defect-record + AskUserQuestion territory / `/spawn` — per the v6 escalation fence, audit
caveat C3). **NOT another uniformization round**: the orchestrator MUST NOT dispatch 13.4/14 and
MUST NOT run `/revise 309` for a "13.2c" — task 309 leaves autonomous orchestration at that point
and awaits a user decision.

### Phase 13.0: F2 decision probe — is the relativized statement still false for the CURRENT carrier at k=2? [COMPLETED]

*(Carried verbatim from v6 — completed record. Report 05 label: Phase 13.0.)*

**VERDICT (2026-07-06): F2 CONFIRMED — fully machine-checked, exceeding the deliverable bar.**
`f2_relativized_refutation` (NfMultiAnchorBridge.lean, F2 probe section after the F1 record;
axioms exactly `[propext, Classical.choice, Quot.sound]`) refutes the UZ/SZ-relativized k=2
statement for `bracketEndChar_kv` for EVERY provider family `charF`, in the Prior model
`M* = (ℤ, <)`, `P = {0,10,20}` with `f2_UZ`/`f2_SZ` machine-checked. The report-05 F-B caveat
resolved affirmatively: the per-entry type-match check SUCCEEDS on `12 ≤ w' ≤ 16`
(`f2_sub2_transfer`), with the discrete-gap type `τ` covering `w' = 17`. NO analysis-only
residue — the counterexample itself is checked, not prose. **Routing: proceed to Phase 13.1
and the FULL ladder 13.2 → 13.3 → 13.4 → 14** (do NOT collapse to surgery-only; do NOT
strengthen the kv gate). Additive-only diff verified (822 insertions, 0 deletions, one file).

History only — verdict record preserved byte-identical; probe inputs and routing text in
plans/06_offdiag-fi-chain-plan.md:575-641.

### Phase 13.1: Statement surgery — `ExistProviders` bundle + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts [COMPLETED]

*(Carried verbatim from v6 — completed record. Report 05 label: Phase 13.I.)*

> **COMPLETED (2026-07-06, sess_1783391112_643ec1)**: All deliverables landed additively after
> the F2 verdict material in NfMultiAnchorBridge.lean (97 insertions, 0 deletions).
> `ExistProviders` and `BracketCarrierCorrectVPrior` carry the exact report-05 Pillar 1
> signatures; the six order hypotheses are stated uniformly via `NormalForm.atom_assgn`
> (defeq to `qnf` at k=0 / `qnf.1` at k+1 — the only binder adjustment, documented in the
> doc-comments; no elaboration-forced deviation otherwise). Both `_prior` lifts are
> drop-hypotheses term-mode delegations to :3788/:3816; `lean_verify` axioms exactly
> `[propext, Classical.choice, Quot.sound]`. Import edge `import …Kamp.EANegationClosure`
> LANDED cycle-free (compile-verified, full tree GREEN 1709 jobs) — the explicit-Props
> fallback was NOT needed. 0 new sorries; no preserved asset modified.

History only — the 13.1 interface is a Preserved/Live Asset; 13.35 targets the SAME predicate
(KD3). Full deliverable spec in plans/06_offdiag-fi-chain-plan.md:643-701.

### Phase 13.2: Per-sub enriched carrier `bracketEndChar_kvE` — definition + concrete k=2 instance [COMPLETED]

*(Carried verbatim from v6 — completed record. Report 05 label: Phase 13.II-a.)*

> **COMPLETED (2026-07-06, sess_1783391112_643ec1)**: All deliverables landed additively in
> NfMultiAnchorBridge.lean (283 insertions, 0 deletions; commit `22334d430`). Landed:
> `kvE_consistent` (:5000), `kvE_gate` (:5015), `kvE_body` (:5036, per-sub successor body),
> `kvE_body_gate_fail` (:5130), `bracketEndChar_kvE` (:5150, codomain
> `BracketEndCharCarrierV sig (k+1)` = `VVecEA2`-valued), `bracketEndChar_kvE_two_eq` (:5167,
> rfl bridge — the concrete k=2 instance), `nf_eval_depth1_fold_iff` (:5187, the A2 inside-out
> per-sub obligation decomposition for 13.3, wrapping `nf_quant_layer_fold_iff` with the
> arity-5 split inside). `lean_verify` on all three public names = exactly
> `[propext, Classical.choice, Quot.sound]`; full tree GREEN (1709 jobs); 0 new sorries; no
> `VecEA2 1` in the new block; per-sub criterion met (every read of `qnf.2` is `q σ` at
> individual subs — `pos` filter, per-sub gate, per-sub `epR` literals, per-sub slots).
> **Design decisions (this phase's design deliverable)**: (1) per-sub joint literals
> `P.existF 3 σ` anchor at `epR`/`t` — `insertEnv` places the provider anchor at the LAST
> position, and `t` is position 3 of the per-sub obligation env `[u,w,x,t]`; (2) exclusion
> literals are the honest-safe unary families ONLY (`hasPos`-guarded, computed from the
> per-sub positive lists) — a uniform `¬(P.existF 3 σ)` for negative σ would over-exclude
> (the F-D model-dependent-negation gap), so negative-sub joint content is 13.3 proof-side
> work per plan; (3) *(deviation: altered — interpretation)* "σ's inner existentials
> flattened as further bracket witnesses" is realized THROUGH the provider formula
> `P.existF 3 σ` (the Phase-14 instantiation is the Lemma-3.4 flattened TL form), NOT as
> additional slots of this bracket: the A1 bundle supplies depth-`k` converters only, so
> slot-level flattening of depth-(k-1) content is outside provider scope and would break
> uniformity in symbolic `k` (13.3/13.4 target the SAME definition). Witness growth in this
> bracket is per-positive-sub, which also encodes the multiplicity the fiber read collapsed.

**v7 status note**: F3 refuted the k=2 CORRECTNESS STATEMENT of this carrier, not the
construction (gate, zones, slots, unary families, arrangement machinery all behaved exactly as at
k=1 — F3 isolation clause). The missing content is exactly what design decisions (2) and (3)
deferred: (2)'s proof-side deferral of joint/negative content is where F-D materialized; Phase
13.25 supplies the deferred content CARRIER-SIDE, additively. All 13.2 deliverables are
Preserved/Live Assets. History only — full deliverable spec in
plans/06_offdiag-fi-chain-plan.md:703-779; entry points in handoffs/phase-13.2-handoff-20260706.md
(still valid for the 13.25 designer).

### Phase 13.3: k=2 correctness GO/NO-GO gate for `bracketEndChar_kvE` [COMPLETED — NO-GO, exclusion-encoding — routed to /revise 309 (v7) Phase 13.2b]

*(Carried verbatim from v6 — completed gate record; the routing it names is EXECUTED by this v7.)*

**BLOCKER (Phase 13.3 — NO-GO verdict, exclusion-content encoding; gate completed 2026-07-06)**:
- **What failed**: the soundness direction at k=2. Machine probe drove the carrier's `holds`
  through `bracketEndChar_kvE_two_eq` + `k1v_bracket_extract` to the per-sub positive
  obligation; the joint literal + `P.correct 3 σ M h_UZ h_SZ t` yield only
  `he : nf_eval_nf M 1 4 (insertEnv e t) σ` (provider-chosen `e`), against goal
  `∃ u, nf_eval_nf M 1 4 (Fin.cons u (Fin.cons w (Fin.cons x fun _ => t))) σ`.
- **What was tried**: `exact ⟨e 0, he⟩` (type mismatch `insertEnv e t ≠ Fin.cons (e 0)
  [w,x,t]`); `simpa [insertEnv, Fin.cons]` (same); funext bridge (residuals `e 1 = w`,
  `e 2 = x` — no hypothesis relates `e` to the honest anchors); negation-stack consumption
  (each lemma concludes a model-dependent `∃ v, v.holds` with no link to the fixed σ).
- **Why stuck**: report 05's F-D gap materializes — and the statement is FALSE, not merely
  hard: counterexample M = ℤ (Prior), p={0}, r={13}, x=10, t=20, with
  `σ'' := nf_characteristic M 1 4 [14,16,11,20]` positive and the honest
  `char [14,15,10,20]` set false — LHS holds, RHS fails for every w' (full record in
  NfMultiAnchorBridge.lean Phase-13.3 verdict section, after :5201). Provider-independent
  (only `P.correct` consumed), so it survives any correct depth-1 bundle.
- **What is needed**: plan v6's NAMED FALLBACK — `/revise 309` (v7) inserting Phase 13.2b
  (uniformization: uniform per-sub exclusion/pinning formulas as finite disjunctions over
  the finitely-generated candidate family — carrier-side Lemma 5.3/5.1 + Prop 4.2), then
  re-run this gate ONCE.
- **Prohibited**: no sorry, no partial theorem landed (verdict record only); 13.2 carrier
  and 13.1 predicate unchanged (KD3); no anchor growth (C3); EANegation :1090/:1249
  untouched.

**v7 status note**: this is finding **F3**. The named fallback is realized as Phase 13.25 below;
the "re-run this gate ONCE" instruction is Phase 13.35. The verdict record (NfMultiAnchorBridge
final section after :5201) is a Preserved/Live Asset and 13.25's primary design input. History
only — full original phase spec (goal, deliverables, GO/NO-GO routing, consumables, acceptance)
in plans/06_offdiag-fi-chain-plan.md:781-868.

### Phase 13.25: Uniformization — finite-disjunction pinning/exclusion formulas + carrier channel extension (the v6-named "Phase 13.2b") [COMPLETED]

**13.25 landed (construction green, additive, sorry-free).** Deliverables in
`NfMultiAnchorBridge.lean` after the F3 record (:5282-5531): `kvE_PinArrangement`,
`kvE_consistentZones`, `kvE_pinArrangements`, `kvE_pinDisjunct` (channel (i)), `kvE_exclConj`
(channel (ii)), `kvE'_body` + `kvE'_body_gate_fail`, `bracketEndChar_kvE'`,
`bracketEndChar_kvE'_two_eq`. Full tree GREEN (1709 jobs); `lean_verify` on
`bracketEndChar_kvE'` and `bracketEndChar_kvE'_two_eq` = exactly
`[propext, Classical.choice, Quot.sound]`; additive-only (250 insertions, 0 deletions —
`kvE_body`/`bracketEndChar_kvE` byte-identical); 0 new sorries/axioms; :1090/:1249 NOT consumed
(doc-comment discipline held; only the required non-consumption statement references them).
*(deviation: `kvE'_pin_honest` honest-safety smoke lemma DEFERRED per H8 budget — it is the
FIRST obligation of Phase 13.35, per this phase's own routing.)* **13.35 primary risk (flagged
for the gate):** the discriminating per-sub JOINT content (σ's inner-witness structure vs the
honest anchors) rides `σ.2`, not parametrically expressible in `kvE'_body` at symbolic k; the
landed channels carry σ.1-level positional content (zone + fresh type) + finite-disjunction
exclusion. Whether this suffices for the k=2 soundness direction is 13.35's machine
determination — if the F3 crux residual recurs, that is the legitimate (machine-probed)
escalation, NOT an armchair claim.

*(This phase transcribes plan v6's Phase-13.3 "NO-GO, exclusion-content encoding" named fallback
into plan form — report 05 §c contingency, executed. Scope is BOUNDED to that fallback.)*

- **Goal:** Construct uniform per-sub formulas as FINITE DISJUNCTIONS over the finitely-generated
  candidate family (subs, arrangements, point-type sets — all finite at each depth; report 05 §c),
  and extend the carrier with them: the carrier-side realization of Lemma 5.3 (INF splitting,
  md:137-152) / Lemma 5.1 (bracket negation, md:134-135) + Prop 4.2 (negation closure,
  md:100-101), with Cor 5.4's `F_i` as TL formulas (md:154-157) per the G5 v6 extension. **Two
  channel families (the 13.3 finding — the gap hits POSITIVE subs too):**
  - **(i) Positive-sub joint PINNING formulas** — the crux fix. For each positive interior sub
    `σ` (`qnf.2 σ = true`), pin σ's joint claim against the honest anchor pair by the bracket's
    OWN interval decomposition (Def 3.1, the F3 record's N3 lead: every existentially chosen
    point carries its point type α_j AND the interval types β_j, β_{j+1} on BOTH adjacent
    sub-intervals): σ's witness `u` and σ's flattened inner witnesses appear as EXTRA bracket
    witness slots with per-slot point types and per-interval segment conjuncts, disjoined over
    the finite family of arrangements — so the provider existential's residuals `e 1 = w`,
    `e 2 = x` are replaced by structural facts of the bracket extraction. This closes exactly
    the crux goal state recorded at F3 (`he : nf_eval_nf M 1 4 (insertEnv e t) σ` with rebound
    non-`t` positions).
  - **(ii) Negative-sub exclusion formulas** — the original F-D subject. For each negative
    interior sub `σ` (`qnf.2 σ = false`), a uniform exclusion formula: the negation of the
    finite disjunction of σ's realization patterns over the same candidate family (Lemma 5.1 /
    Prop 4.2 carrier-side), conjoined into the segment/endpoint literal lists, guarded so honest
    realizations stay true (the `hasPos`-guarded house pattern of the 13.2 unary exclusions).
- **Design choice — (a) carrier channel extension (SETTLED here; do not re-litigate):** the new
  channels land as new `TemporalPred` slots + extended literal lists in an extended carrier body
  (`bracketEndChar_kvE'`, additive alongside the landed `bracketEndChar_kvE` — NOT an edit),
  **NOT** as (b) a strengthened `ExistProviders` bundle with pinned-anchor converters.
  **Justification from the crux goal shape:** the crux residuals `e 1 = w`, `e 2 = x` are
  RELATIVE-POSITION claims tying σ's realization to the bracket's own structural points. A
  provider formula is a single-anchor TL formula — `temporal_truth M t (P.existF …)` sees only
  its one evaluation point, and its `∃ env` necessarily rebinds the rest: that IS the refuted F3
  configuration, so no strengthening of a single-anchor bundle can express the pinning. A
  multi-anchor "pinned converter" is not producible by the outer recursion
  (`nf_nvar_exist_all_depths` supplies single-anchor converters only — F-A), so a (b)-bundle
  could never be instantiated at Phase 14 — it is circular with the two-anchor characteristic
  under construction. Choice (a) is also Rabinovich's own device: Def 3.1 pins chosen points
  through the interval decomposition, and Prop 4.2/Lemma 5.1/5.3 place per-round joint/negative
  content CARRIER-SIDE as finite disjunctions (Cor 5.4's `F_i` are TL formulas) — the F3 verdict
  record's lead evidence verbatim.
- **Deliverables (exact names; signatures binding up to elaboration-forced binder adjustments,
  documented per house style; all additive in NfMultiAnchorBridge.lean after the F3 record):**
  - `structure kvE_PinArrangement (sig : MonadicSignature) (k : Nat)` (private) — one pinned
    placement of a positive sub: the σ-witness's zone relative to `(x, w, t)`, the placements of
    σ's flattened inner-witness slots among the bracket sub-intervals, and the per-slot type
    assignments. Exact field representation is this phase's design deliverable; it MUST be
    finitely enumerable by construction (explicit `List` builders — see next item), with the
    finiteness argument (report 05 §c: index sets `NormalForm sig k m`, zones, and arrangements
    are finite per depth) stated in the doc-comment.
  - `def kvE_pinArrangements {sig} {k} (σ : NormalForm sig k 4) : List (kvE_PinArrangement sig k)`
    — computable enumeration via `flatMap`/`map`/`filter` over the generated family (the landed
    `S_L.permutations.flatMap …` house pattern, kvE_body :5036); no `Fintype`/`decide` machinery
    on the carrier path.
  - `noncomputable def kvE_pinDisjunct {sig} {k} (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula) (σ : NormalForm sig k 4)
    (a : kvE_PinArrangement sig k) : List TemporalPred × List TemporalPred` (shape may split into
    point/segment builders) — per-arrangement EXTRA witness slots (point types) and segment-type
    conjuncts realizing σ's joint claim positionally within the honest bracket (channel (i)); at
    k=2 instantiated with `charBase = nf_depth0_char_formula …` and `charK = P.existF 0` — no
    new provider is needed at the gate. Chain-step citations: Def 3.1 (md:61-74) + Lemma 5.3
    (md:137-152) per disjunct, N1 split.
  - `noncomputable def kvE_exclConj {sig} {k} (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula) (σ : NormalForm sig k 4) : Formula` — channel (ii):
    the uniform exclusion formula for a negative sub (negated finite disjunction of realization
    patterns over `kvE_pinArrangements σ`; Lemma 5.1 md:134-135 + Prop 4.2 md:100-101,
    carrier-side; guarded honest-safe on insertion).
  - `noncomputable def kvE'_body` — same parameter shape as `kvE_body` (:5036)
    (`charBase charK exF r q`, plus any explicit pin-channel formula-family parameters the
    symbolic-k analysis forces — see the Risks entry; parametric, never depth-baked): kvE_body's
    construction with (1) the disjunct family extended per positive interior sub by
    `kvE_pinArrangements`/`kvE_pinDisjunct` (old arrangements × pin arrangements — N5's finite
    disjunction, larger index), (2) segment/endpoint literal lists extended with `kvE_exclConj`
    conjuncts for negative interior subs, (3) ALL existing 13.2 channels retained verbatim
    (gate, unary families, the `t`-anchored joint literal `exF σ`, per-sub slots) — an ADDITIVE
    extension of the literal lists; `kvE_body` itself is NOT edited.
  - `noncomputable def bracketEndChar_kvE' {sig} (atomMap …) (h_surj …) {k}
    (P : ExistProviders sig atomMap k) : BracketEndCharCarrierV sig (k + 1)` — the extended
    carrier: `kvE'_body` applied with the same instantiation pattern as :5150
    (`charBase = nf_depth0_char_formula …`, `charK = P.existF 0`, `exF = P.existF 3`).
  - `theorem bracketEndChar_kvE'_two_eq` — the k=2 instance bridge (rfl/simp mirror of :5167),
    the 13.35 entry point.
  - `theorem kvE'_pin_honest` (honest-safety smoke lemma; SHOULD-level, in-budget): for an
    honest realization env, each pin disjunction has a true disjunct and each exclusion conjunct
    is true (completeness-direction de-risk). If the H8 budget forces deferral, record it in the
    handoff as the FIRST obligation of 13.35 — do not silently drop it.
  - Section doc-comment / design record: N3 Def-3.1 lead; G5 v6-extension citations
    (Lemma 5.3/5.1 + Prop 4.2 + Cor 5.4 with md refs); the F3 statement + this phase's
    channel-(i)/(ii) response; the finiteness argument; and the EXPLICIT statement that the
    construction consumes neither EANegation :1090 nor :1249.
- **EANegation :1090/:1249 (uniform-backward sorries) — blocker criterion, stated explicitly:**
  these pre-existing sorries are OUT OF SCOPE. The 13.25 construction derives uniformity from
  FINITENESS of the candidate family (report 05 §c), not from uniform-backward negation lemmas —
  no deliverable above may cite them. If at any point the construction (or, later, the 13.35
  proof) is found to REQUIRE :1090 or :1249, the dispatch STOPS, records that as a blocker
  finding in the F1/F2/F3 house style (candidate F4), marks the phase heading [BLOCKED], and
  escalates per the Branch discipline — the sorries are NEVER silently absorbed onto the live
  path.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after the F3
  verdict record).
- **Consume, do NOT rebuild:** the F3 verdict record (final section after :5201 — read-only
  design input: crux goal, counterexample, kill list); the 13.2 kvE kit (`kvE_consistent` :5000,
  `kvE_gate` :5015, `kvE_body` :5036 as the structural template, `kvE_body_gate_fail` :5130,
  `bracketEndChar_kvE` :5150, `bracketEndChar_kvE_two_eq` :5167, `nf_eval_depth1_fold_iff`
  :5187); `ExistProviders`/`BracketCarrierCorrectVPrior` (13.1 — predicate UNCHANGED, KD3);
  `bracketFromLists` (:1883); `VVecEA2` (VecEAFormula:271); `existsBounded_right`
  (VecEAClosure:265 — pin-slot witness-growth license); `nf0_split_assemble` (NfEFold:235) +
  `nf_quant_layer_fold_iff` (NfEFold:391) for shaping the pin content against the per-sub
  obligation decomposition; `fChainFrom`/`fChainPred` (EANegation:552/:567 — Cor 5.4 candidate
  shapes, read-only); `nfk_projFresh` (:3499); `nf_eval_unique` (NormalForm:245). Do NOT edit
  `bracketEndChar_kvE`/`kvE_body` or ANY preserved asset; do NOT read `qnf.2`
  fiber-existentially (F1); do NOT touch EANegation :1090/:1249; do NOT attempt provider-side
  pinning (v7 Amendment F3).
- **Acceptance criteria:** `lake build` GREEN full tree; all new definitions typecheck sorry-free
  with codomain `VVecEA2` where applicable (grep confirms no `VecEA2 1` regression); anchors
  provably `{x,t}` (two-point `VVecEA2.holds` — G4/G6; pin slots are WITNESSES); both channel
  families present and verifiably per-sub (code-review criterion: every read of `qnf.2` is `q σ`
  at individual subs); 0 new sorries; 0 new axioms; `lean_verify` on `bracketEndChar_kvE'` and
  `bracketEndChar_kvE'_two_eq` = exactly `[propext, Classical.choice, Quot.sound]`; additive-only
  diff (git diff confirms no deletion/edit of any preserved asset — in particular
  `bracketEndChar_kvE`/`kvE_body` byte-identical); the doc-comment discipline above incl. the
  :1090/:1249 non-consumption statement; grep confirms no reference to the :1090/:1249 lemma
  names in the new block.
- **Estimated lines:** 150-250 (one agent run; H8). If the pin-family enumeration alone overruns,
  split at the channel seam (13.25a = channel (i) pinning + kvE'_body/carrier; 13.25b = channel
  (ii) exclusion + two_eq + honest-safety), mirroring the 13.4 split note — do not inflate a
  single dispatch.
- **Guards enforced:** G2, G4, G6-as-amended, A1 (provider parameter unchanged), A2, v7 Amendment
  F3 (this phase realizes its required behavior), N1, N4, N5 (extended finite disjunction),
  G5 + v6 extension (chain-step citations on every pin/exclusion builder).
- **Commit:** `task 309 phase 13.25: uniformization — kvE' pinning/exclusion channels + carrier extension (v6-named 13.2b)`

### Phase 13.35: k=2 correctness gate RE-RUN for `bracketEndChar_kvE'` — ONCE (the v6-named "13.3-re") [COMPLETED — NO-GO, carrier-shape defect (13.25 channels do not carry the discriminating per-sub joint content; F4)]

**BLOCKER (Phase 13.35 — NO-GO verdict, finding F4; the second-and-LAST gate attempt):**
- **What failed**: the k=2 soundness direction of `BracketCarrierCorrectVPrior atomMap
  (bracketEndChar_kvE' atomMap h_surj P)` — the per-sub positive obligation. Captured crux (probe
  B): after `P.correct 3 σ`, `he : nf_eval_nf M 1 (3+1) (insertEnv e t) σ`
  (`insertEnv e t = [e 0, e 1, e 2, t]`, `u/w/x` rebound by `e : Fin 3 → M`) against goal
  `nf_eval_nf M 1 (3+1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) σ`; the funext residual
  is `w = e 1`, `x = e 2` with no pinning hypothesis — the F3 crux verbatim.
- **What was tried (machine-probed, not armchair)**: probe A (`rfl`-confirmed) — channel (i)
  `kvE_pinDisjunct` collapses over all seven consistent zones to the IDENTICAL `charK
  (nfk_projFresh σ)` (the `witnessZone` field is discarded); channel content is a function of the
  σ.1-level fresh type ALONE. probe B — transfers `exact ⟨e 0, he⟩` / `⟨u, he⟩` fail with type
  mismatch `insertEnv e t ≠ [·, w, x, t]`; the channel-(i) deliverable (a `nfk_projFresh σ`
  fresh-type witness in `(x,w)`) is a separate existential unrelated to `e 1 = w`, `e 2 = x`.
- **Why stuck (root cause)**: the discriminating per-sub JOINT content (the sub's inner-witness
  structure vs the honest anchors) rides `σ.2`; the landed 13.25 channels carry σ.1-level content
  (channel (i): `nfk_projFresh σ`, positionally vacuous) plus a negative-only, fiber-guarded
  exclusion (channel (ii), inert here — the dishonest positive `σ''` occupies the fiber and
  collapses the guard to `⊤`). The F3 provider-independent ℤ counterexample (`M = ℤ`, `p={0}`,
  `r={13}`, `x=10`, `t=20`, `σ'' = char [14,16,11,20]`) survives verbatim → the k=2 statement is
  FALSE for `bracketEndChar_kvE'` under ANY correct depth-1 provider bundle.
- **What is needed**: NOT another uniformization round (one-round budget exhausted, v7 Amendment
  F3). Per the pre-committed Phase 13.35 routing (below): defect record F4 landed → orchestrator
  ESCALATES the 309 blocker ladder (user decision / `/spawn 309` with F4 as blocker). Phases 13.4
  and 14 MUST NOT be dispatched; do NOT `/revise` for a "13.2c"; do NOT weaken the 13.25 carrier
  or the 13.1 predicate.
- **Prohibited (honored)**: no `sorry`, no `def X := True`, no partial theorem landed. The only
  Lean artifact is the F4 verdict record (NfMultiAnchorBridge.lean, final section after :5533 —
  R2 house style). Full tree GREEN (1709 jobs).

*(The single gate re-run the 13.3 routing licenses. DECISION GATE — the task-311 Phase-5 /
13.0 / 13.3 verdict-record pattern: machine-probe, record the verdict either way, land no partial
theorem, no sorry.)*

- **Goal:** Re-run the k=2 GO/NO-GO gate against the 13.25-extended carrier: prove
  `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE' atomMap h_surj P)` at `k + 1 = 2`
  (`P : ExistProviders sig atomMap 1` — the 13.1 predicate and bundle UNCHANGED, KD3), via
  private direction lemmas mirroring the k1v split (:2325/:2966). The soundness crux that F3
  refuted is now discharged STRUCTURALLY: the pinned arrangement disjunct places σ's witness and
  σ's inner witnesses in explicit sub-intervals relative to the bracket's own points, so the
  extraction (`k1v_bracket_extract` :2150 clones) yields per-interval data from which the honest
  env `[u,w,x,t]` obligation is reconstructed via `nf_eval_depth1_fold_iff` (:5187) at `n = 4` +
  `nf0_split_assemble` (arity 5) — A2 inside-out; the `t`-anchored provider literal is no longer
  the only joint channel. Negative-sub content: the carrier-side `kvE_exclConj` conjuncts carry
  it; residual per-model direction obligations may still consume the forward negation stack
  (`prior_hasAttainedINF h_UZ` PriorINF:224 + EANegationClosure :401/:492/:646/:720 +
  `neg_orderedPointsExist_is_vbracket` EANegation:347) proof-side ONLY (F-D discipline).
- **Adversarial test (mandated):** the F3 counterexample configuration (ℤ, p={0}, r={13}, x=10,
  t=20, `σ'' = char [14,16,11,20]`, honest `char [14,15,10,20]` false) MUST fail the EXTENDED
  carrier's LHS — every pin arrangement for `σ''` dies at `(10,20)` (the F3 kill-list content,
  now carrier-visible). The verdict record must state where each kill lands in the new channels
  (machine-checked if cheap; otherwise the explicit per-arrangement analysis in the record).
- **Deliverables:**
  - `theorem bracketEndChar_kvE'_correct_two` — the k=2 instance of
    `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE' atomMap h_surj P)`, via
    `bracketEndChar_kvE'_sound_two` / `bracketEndChar_kvE'_complete_two` (private, mirroring the
    k1v `_sound`/`_complete` split :2325/:2966).
  - A GO/NO-GO verdict record in the file + handoff (house style of the R2 GO record :3394-3434
    and the F1/F2/F3 records), leading with the N3 Def-3.1 evidence and citing Lemma 5.3/5.1 +
    Prop 4.2 per the G5 v6 extension, INCLUDING the adversarial-test disposition above.
- **GO/NO-GO routing (explicit; PRE-COMMITTED — this is the second and LAST gate attempt):**
  - **GO** (k=2 `↔` closed sorry-free): proceed to Phase 13.4.
  - **NO-GO (either kind — exclusion-encoding residue OR carrier-shape defect): NOT another
    uniformization round.** Record the defect (candidate **F4**) in the F1/F2/F3 house style with
    the goal state and (if found) counterexample; land NO partial theorem, NO sorry; mark this
    phase heading **[BLOCKED]**; then ESCALATE to the orchestrator blocker ladder per v6's
    escalation fence (audit caveat C3): defect-record → orchestrator halts the 309 ladder →
    AskUserQuestion territory (user decision) and/or `/spawn 309` with the F4 record as blocker
    description. The orchestrator MUST NOT dispatch 13.4/14, MUST NOT run `/revise 309` for a
    "13.2c", and MUST NOT weaken the 13.25 carrier or the 13.1 predicate. Autonomous
    orchestration of task 309 ENDS at this branch.
  - **UNSETTLED within budget** (neither direction closes nor a refutation is found in one H8
    run): land only green material, record the exact stuck obligations in the verdict comment +
    handoff, and allow ONE bounded follow-up dispatch of THIS phase with the recorded states
    (H8 split at the direction seam: 13.35a soundness / 13.35b completeness + assembly); if still
    unsettled after that, treat as NO-GO routing above.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after 13.25).
- **Consume, do NOT rebuild:** `bracketEndChar_kvE'` + `bracketEndChar_kvE'_two_eq` +
  `kvE_pinArrangements`/`kvE_pinDisjunct`/`kvE_exclConj` (+ `kvE'_pin_honest` if landed) (13.25);
  `BracketCarrierCorrectVPrior`/`ExistProviders` (13.1); `nf_eval_depth1_fold_iff` (:5187);
  `nf0_split_assemble` (NfEFold:235, arity 5); `nf_quant_layer_fold_iff` (NfEFold:391); the k1v
  proof kit (:2028-2825) and direction templates (:2325/:2966); `kvE_body_gate_fail` (:5130)
  pattern for the off-gate branch; `prior_hasAttainedINF` (PriorINF:224) + `HasAttainedINF`
  (PriorINF:202); the EANegationClosure stack (:401/:492/:646/:720) +
  `neg_orderedPointsExist_is_vbracket` (EANegation:347) — proof-side ONLY; `nf_eval_unique`
  (NormalForm:245) / `nfPred_correct` (NfToVecEA:69); `existsBounded_right` (VecEAClosure:265);
  the F3 verdict record (read-only — the adversarial test). Do NOT touch EANegation :1090/:1249
  (needing them = blocker finding, 13.25 criterion); do NOT redefine any fold or negation asset;
  do NOT silently change the 13.25 carrier or the 13.1 predicate (KD3); do NOT re-run the gate
  against the UNEXTENDED `bracketEndChar_kvE` (F3 settled).
- **Acceptance criteria:** `lake build` GREEN full tree; on GO: k=2 `↔` + both direction lemmas
  sorry-free, `lean_verify` on each = exactly `[propext, Classical.choice, Quot.sound]`, verdict
  record present with the adversarial-test disposition; on NO-GO: verdict/defect record (F4) with
  goal state + the pre-committed escalation routing named, NO partial theorem, NO sorry landed,
  tree still GREEN, phase heading [BLOCKED]; 0 new live-path sorries either way; every chain step
  cites Rabinovich per G5 + v6 extension (no simp/omega/aesop on a chain step); per-sub
  obligations discharged inside-out per A2 (no raw `nf_eval_nf M (k+1)` split leaving a joint
  existential standing); no reference to EANegation :1090/:1249.
- **Estimated lines:** 200-250 (one agent run; H8; split note in the routing above).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2, v7 Amendment F3
  (one-round budget), N1-N5.
- **Commit:** `task 309 phase 13.35: k=2 gate RE-RUN bracketEndChar_kvE'_correct_two (GO/NO-GO, one re-run)`

### Phase 13.4: General-k one-step correctness `bracketEndChar_kvE'_correct` [NOT STARTED]

*(Carried from v6 with consumables RE-POINTED at the 13.25-extended objects — sizing and
acceptance shapes unchanged. Report 05 label: Phase 13.III. Dispatch ONLY after 13.35 records GO.)*

- **Goal:** Prove the general one-step correctness (report 05 Pillar 3, re-pointed):
  `theorem bracketEndChar_kvE'_correct {sig} (atomMap …) (h_surj …) (P : ExistProviders sig
  atomMap k) : BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE' atomMap h_surj P)` — ONE
  successor step with symbolic `k`, conditional on providers at depth `k`. NOT a ∀k induction
  inside the Bridge: the ∀k recursion is KampPrior's existing `Nat.rec` (F-A; Phase 14
  instantiates). Template = the 13.35 k=2 re-run proof with the depth-0 innermost layer replaced
  by provider-mediated obligations: where 13.35 used `nf0_split_assemble` directly on depth-0
  inner layers, the symbolic-k step consumes `P.correct` for the flattened inner existentials and
  applies `nf_quant_layer_fold_iff` at the innermost layer of each per-sub obligation (A2
  inside-out discipline). **Symbolic-k channel-depth note (v7)**: if the pin channels' inner
  formula families force depth-(j<k) converters beyond what `kvE'_body`'s parameters carry,
  thread them as explicit hypotheses / a NEW documented bundle (e.g. `ExistProvidersLE`) — the
  13.1 surgery pattern; instantiable at Phase 14 (F-A: recursion supplies all depths ≤ k, all
  arities); NEVER an edit of the landed `ExistProviders`, and if even that fails, a recorded
  blocker + escalation, not silent absorption.
- **Deliverables:**
  - `bracketEndChar_kvE'_correct` (signature above) + general direction lemmas
    `bracketEndChar_kvE'_sound` / `_complete` (private), with the k=2 instance lemmas of 13.35
    either subsumed (re-derived as instances) or kept alongside — do not delete the 13.3 or 13.35
    verdict records either way.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after 13.35).
- **Consume, do NOT rebuild:** everything 13.35 consumed, plus the 13.35 proof itself as template
  (read-only); `P.correct` (the provider hypothesis — the ONLY channel to inner-existential
  semantics at symbolic depth). Do NOT re-open the k=2 verdict; do NOT restate the retired
  unconditional names or the F3-refuted unprimed targets; do NOT introduce a ∀k induction over
  the carrier inside the Bridge; do NOT touch EANegation :1090/:1249.
- **Acceptance criteria:** `lake build` GREEN full tree; `bracketEndChar_kvE'_correct` + direction
  lemmas sorry-free — or ONE explicitly documented strategic-sorry + `follow_up_task` if a
  bounded, named residual obligation survives (documented per the Do-NOT exception; NOT silent);
  `lean_verify bracketEndChar_kvE'_correct` = exactly `[propext, Classical.choice, Quot.sound]`;
  anchors provably `{x,t}` at the symbolic depth (G4/G6); A2 discipline grep-verifiable
  (`nf_quant_layer_fold_iff` at every innermost per-sub layer; no raw successor split); chain-step
  citation discipline (G5 + v6 extension, N1/N2).
- **H8 split note:** if it overruns one agent run, split at the direction seam (13.4a = soundness;
  13.4b = completeness + assembled `↔`), mirroring the task-311 5.1/5.2 split.
- **Estimated lines:** 150-250 (one agent run; H8).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2, v7 Amendment F3,
  N1-N5.
- **Commit:** `task 309 phase 13.4: general-k one-step correctness bracketEndChar_kvE'_correct`

### Phase 14: Discharge four hooks + KampPrior:351 rewire + full-tree axiom check (R4) [NOT STARTED]

*(Carried from v6 with consumables RE-POINTED at the 13.25-extended carrier and its 13.4
correctness — sizing and acceptance shapes unchanged. Dispatch ONLY after 13.4 lands green. The
hook-discharge SHAPE survives from v5/v6 — only the carrier name and correctness interface it
consumes changed. This phase delivers the task goal.)*

- **Goal:** Use the depth-`k` witness-growing enriched-and-pinned V-carrier to **discharge the
  four deferred hooks** — `h_quant` (past, NfMultiAnchorBridge:1023-1026), `h_quant` (future,
  :1223-1226), and `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, :787-795) — then rewire
  `KampPrior.lean:351` to the three-way disjunction `A := nf_char2_past_formula … ∨ A_diag … ∨
  nf_char2_future_formula …` via `nf_zone_exists_trichotomy_k1` and a three-way `or_congr`,
  closing the `:351` sorry (live sorries 2 → 1; `:354` stays, task 305). Mechanically: at `:351`
  the goal is `∃ A, temporal_truth t A ↔ ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t)
  sub_nf`, with `h_UZ`/`h_SZ` in scope (KampPrior:216-223) — exactly the
  `BracketCarrierCorrectVPrior` hypotheses (A1). **Provider instantiation (report 05 Pillar 3):**
  build `P : ExistProviders sig atomMap j` at each needed depth `j ≤ k` from the recursive calls
  `nf_nvar_exist_all_depths atomMap h_surj j n'` (the KampPrior:273 `ih_exist_1` pattern
  generalized across arities — structural on the first Nat argument; compile-check flagged by
  report 05 as Medium-High: if some arity is not structurally available, thread the needed
  converters as extra hypotheses through the theorem statement, same surgery pattern as 13.1,
  confined to KampPrior.lean, and document the deviation). If 13.4 introduced a documented
  extended bundle (`ExistProvidersLE`-shape), instantiate it from the same recursive calls (F-A
  licenses all depths ≤ k). Also instantiate `charF` per the Phase-12 KD1 pattern
  (`nf_characterizable_temporal_prior`, KampPrior:397) where k≤1 kv instances are consumed.
  Bridge `env : Fin 1` to `∃x` (existing `h_env_eq` shape, KampPrior:277-291); decompose
  `nf_eval_nf M (k+1) 2 [x,t]` into its depth-0 atom layer (`nf_char2_atom_offdiag_correct`, P2)
  and, per arity-3 sub `qnf`, the inner existential closed by **`bracketEndChar_kvE'_correct`
  (13.4)** + Lemma 3.4 / `existsBounded_right` (VecEAClosure:265); assemble and feed the three
  arms through the `or_congr` with `nf_char2_past_formula_correct` / `A_diag_correct` /
  `nf_char2_future_formula_correct`.
- **Deliverables:**
  - Proofs of the four hooks at the call site, discharged via the extended carrier +
    `existsBounded_right` + `nf_zone_flatten_navigable_correct`.
  - The provider-instantiation shim (`ExistProviders` — and the extended bundle if 13.4
    introduced one — built from recursive calls) at the KampPrior call site.
  - The three-way disjunction `A` and the closed `:351` arm of `nf_nvar_exist_all_depths`.
- **File targets:** `Theories/Bimodal/.../Prior/KampPrior.lean` (`:351` arm; local hook wiring
  KampPrior:264-320). The import edge is already landed (P6.1) — do NOT re-add it.
- **Consume, do NOT rebuild:** Phases 4/5 `nf_char2_{past,future}_formula`/`_correct`;
  `A_diag`/`_correct` (:763/:808); `A_past`/`A_future`/`_correct` (P1);
  `nf_char2_atom_offdiag_correct` (P2); `nf_zone_exists_trichotomy_k1`
  (NfZoneFlattenNavigable:188); `nf_zone_flatten_navigable(_brick)`/`_correct` (:689/:709);
  **`bracketEndChar_kvE'` (13.25) + `bracketEndChar_kvE'_correct` (13.4)** +
  `ExistProviders`/`BracketCarrierCorrectVPrior` (13.1); the k≤1 kv instances via the `_prior`
  lifts (13.1); `existsBounded_right` (VecEAClosure:265); the E[Σ]-fold assets (NfEFold); local
  `char_k1` / `ih_exist_1` / `nf_characterizable_temporal_prior` (KampPrior:264-320/:397). The
  landed `bracketEndChar_kvE` (unprimed) is NOT the k≥2 live-path consumable — superseded by
  `kvE'` (it stays landed as the 13.2 record). Do NOT consume the abandoned `endChar`/`seg`; do
  NOT consume `nf_char3_deeper_split`; do NOT consume the retired unconditional kv theorems or
  the F3-refuted unprimed k=2 targets.
- **Acceptance criteria (definition of done):**
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem
    = exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms).
  - Live-path sorry count reduced 2 → 1: `:351` closed; `:354` deliberately remains (task 305).
  - `grep "sorry"` across all new v6+v7 material (13.0-13.4, 13.25, 13.35, 14) shows only
    docstring/comment hits (no code sorries; sole exception: an explicitly documented
    strategic-sorry with a `follow_up_task`).
  - Task 307 Phase 7 wiring verification is unblocked (report the unblock; do not execute it here).
- **Estimated lines:** 80-150 (one agent run; H8).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2, v7 Amendment F3;
  D1 (import edge already landed); final sorry + axiom discipline; N1-N5.
- **Commit:** `task 309 phase 14: discharge hooks + rewire KampPrior:351 + axiom check (R4)`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Per-phase axiom check (`#print axioms` / `lean_verify`) on the phase's new lemma(s): exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Anchor-cap check (every phase)**: every new `holds` obligation is at the two-point signature
  `(x, t)`; witness growth (incl. 13.25 pin slots) occurs only inside `BracketFormula n` /
  `Σ n, VecEA2 n` (G2/G4/G6-amended).
- **A2 discipline check (13.25/13.35/13.4)**: per-sub obligations discharged by inside-out
  `nf_quant_layer_fold_iff` / `nf_eval_depth1_fold_iff` at the innermost layer (grep confirms
  usage); no navigated arity-3/4 characteristic; no raw `nf_eval_nf M (k+1)` split leaving a
  joint (n+1)-ary existential standing; no fiber-existential `qnf.2` read at k≥2.
- **Gate-phase check (13.35)**: verdict record present in-file + handoff, with the explicit
  routing consequence stated (incl. the pre-committed second-NO-GO escalation); NO partial
  theorem, NO sorry landed on a NO-GO.
- **F3-kill check (13.35, mandated)**: the recorded ℤ counterexample configuration fails the
  EXTENDED carrier's LHS; the verdict record states where each per-arrangement kill lands.
- **Honest-safety check (13.25)**: the new pin/exclusion conjuncts are honest-true
  (`kvE'_pin_honest`-shape lemma landed, or its deferral recorded in the handoff as 13.35's
  first obligation).
- **Uniformization-provenance check (13.25/13.35)**: uniformity comes from finiteness (explicit
  `List` enumerations), NOT from uniform-backward negation lemmas — grep confirms no reference to
  EANegation :1090/:1249 material in any new block; forward EANegationClosure lemmas appear only
  inside proofs (13.35), never in a definition.
- **Additivity check (every phase)**: git diff confirms additive-only; in particular
  `bracketEndChar_kvE`/`kvE_body` (:5000-:5199), the 13.1 interface, and all F1/F2/F3 records
  byte-identical.
- Phase 14 gate (definition of done): as in the phase — full-tree GREEN; rewired live-path theorem
  axioms exactly `[propext, Classical.choice, Quot.sound]`; live sorries 2 → 1; new-material sorry
  grep clean; task 307 Phase 7 unblock reported.

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — landed: F2 verdict record (13.0);
  `ExistProviders` + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts (13.1);
  `bracketEndChar_kvE` + kvE kit (13.2); F3 verdict record (13.3). NEW in v7:
  `kvE_PinArrangement`/`kvE_pinArrangements`/`kvE_pinDisjunct`/`kvE_exclConj`/`kvE'_body`/
  `bracketEndChar_kvE'`/`bracketEndChar_kvE'_two_eq` (+ `kvE'_pin_honest`) (13.25); 13.35 gate
  verdict + `bracketEndChar_kvE'_correct_two` + direction lemmas (13.35); general
  `bracketEndChar_kvE'_correct` + direction lemmas (13.4). The abandoned `endChar`/`seg` defs,
  both NO-GO records, the F1/F2/F3 defect records, `bracketEndChar_kv`, `bracketEndChar_kvE`,
  and all task-310/311 landed material remain byte-identical.
- `Theories/Bimodal/.../Prior/KampPrior.lean` — provider-instantiation shim + hook discharge +
  rewired `:351` arm (Phase 14).
- Per-phase handoffs under `specs/309_offdiag_two_anchor_fi_chain/handoffs/`.
- Up to four scoped commits (`task 309 phase 13.25/13.35/13.4/14: …`), continuing the
  P1-P5 + P6.1 + P9-P12 + P13.0-P13.3 history.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without
  disturbing earlier green milestones (H9 incremental-commit discipline).
- Phases 1-5, P6.1, Phases 9-12, 13.0-13.2 material, the F1/F2/F3 records, and all task-310/311
  material are landed and green; the abandoned-route code is inert. If a later phase surfaces an
  unexpected build or axiom problem, roll back to the prior green commit — the `:351` sorry
  simply remains until the carrier lands, with no downstream regression.
- **13.25 contingency**: if the pin-family enumeration or the extended body overruns the H8
  budget, split at the channel seam (13.25a pinning / 13.25b exclusion) — do not inflate a single
  dispatch and do not land a partial (non-green) body. If the construction is found to REQUIRE
  EANegation :1090/:1249, STOP + record + escalate (blocker criterion in the phase).
- **13.35 contingency (pre-committed; the ONE re-run)**: GO → 13.4. Second NO-GO of either kind →
  defect record (F4) + [BLOCKED] + escalation to the orchestrator blocker ladder
  (AskUserQuestion / `/spawn 309` territory) — NO 13.2c, NO carrier/predicate weakening, NO
  further autonomous dispatch of 13.4/14. Unsettled-in-budget → one bounded follow-up at the
  direction seam, then the NO-GO routing.
- If 13.4 overruns the H8 dispatch budget, split at the direction seam (13.4a/13.4b) rather than
  inflating a single dispatch. If symbolic-k forces a bundle-shape extension, it lands as a NEW
  documented structure (never editing 13.1's `ExistProviders`); failing that, blocker + escalate.
- The escalation fence (audit caveat C3) bars any implementer-level anchor growth; anchors stay
  `{x,t}` (2, fixed) under all circumstances.
