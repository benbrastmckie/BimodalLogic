# Implementation Plan: Task #350 (v3 — Rabinovich §7 grounding + EANegationFix split + H8 exterior re-division)

- **Task**: 350 - build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1
- **Status**: [IN PROGRESS] (Phases 1-10 COMPLETED — negFix recursion core landed sorry-free, commits f38a5563c..41c182a1f; refactor R1 + Phases 11-17 NOT STARTED)
- **Effort**: 25 hours (~19 delivered across Phases 1-10a/10b-i/10b-ii-1 + ~6 remaining across Phase 10 tail, R1, and Phases 11-17)
- **Dependencies**: Task 349 (COMPLETED — `endInterval_correct` stack). COORDINATION: task 358 is
  concurrently implementing in `KampPrior.lean` and `ExteriorPinnedConverseK.lean` /
  `ExteriorPinnedConversePastK.lean` — NO phase of this plan may touch those three files (guard G6).
  The Phase 10 negFix recursion core (10b-ii units 2+) is landing in a SEPARATE concurrent dispatch
  (commit `f38a5563c` = seam 1 landed); R1 and everything downstream is gated on that core being green.
- **Research Inputs**:
  - specs/350_.../reports/03_rabinovich-grounding-and-api-division.md (this revision's driver — §7
    exterior grounding upgrade, EANegationFix split DAG, E1-E6 decomposition, H8 phase re-cut);
  - specs/350_.../reports/02_offdiag-k1-primitives.md (v2 driver — P1-P3 adjudication, H3 mapping table);
  - specs/309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md;
  - specs/309_offdiag_two_anchor_fi_chain/reports/02_endpoint-hook-discharge-research.md (§6 Phase 9);
  - specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json (P18b-endChar-recursive-core-unbuilt)
- **Artifacts**: plans/03_negfix-refactor-exterior-carriers.md (this file; supersedes
  plans/02_offdiag-k1-aggregate-discharge.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v2 delivered five of the six DoD hook-discharge lemmas' supporting stack green through Phase 9
and Phase 10 sub-parts 10a/10b-i/10b-ii-1, and the four k=0/k=1-diagonal arm lemmas
(`kampArm_{past,diag,future}_k0`, `kampArm_diag_k1`). The remaining pair
`kampArm_past_k1`/`kampArm_future_k1` still routes through the pending `negFix` recursion core, the
De Morgan fold, the point-channel merges, and the exterior navigated carriers.

This v3 revision folds in **report 03** (hard-mode, Rabinovich-2014 Tier-1 grounded), which delivers
three concrete changes over v2:

1. **Exterior anchor upgrade (§1.5 / §2).** v2's exterior carriers (old Phases 13-15) cited only a
   bare "Prop 3.5 device". Report 03 grounds the exterior work in **Rabinovich Section 7**:
   Lemma 7.10 / Prop 3.5 (one-free-variable fold to a single TL(Since/Until) predicate at x/t),
   Lemma 7.6 (the `(∃z1)_{z0}^{z2}(ϕ1 ∧ ϕ2)` ∃w pin-gluing closure), and Lemma 7.8 (the Since/Until
   past↔future duality). The old two-phase exterior block is re-cut into **six named, dependency-ordered
   sub-lemmas E1→E2→E3→E4→E5→E6**, each a single bounded dispatch.

2. **EANegationFix.lean split refactor (§3.1) — new Phase R1.** The negation-kit file (now 2,629 ln,
   still growing ~1,000 for the negFix recursion + De Morgan fold) has exactly ONE downstream consumer
   (`NfMultiAnchorBridge.lean:78`). Report 03 shows the split into a `Kamp/EANegationFix/` subdirectory
   DAG + a re-export shim is **zero-churn** (pure relocation of already-green proofs) and MUST be applied
   as its own mechanical phase BEFORE the ~1,000 pending lines land — otherwise they land into an
   already-oversized file and the move becomes a larger job later.

3. **H8 phase re-cut (§4).** Phases 11-17 are re-divided into ~100-500-line bounded units
   (12a/12b, 13, 14a/14b/14c, 15, 16a/16b, 17) with per-phase Rabinovich anchors.

A two-sided `B_i` nuance surfaced in report 03's H4 verification is carried into the negFix / De Morgan /
merge phases: `B_i = Bi⁻ ∧ Bi⁺`, so `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` is a **two-sided disjunction** across the pin,
which the `concatPin` builder handles per side, with boundary cases (d)/(e) collapsing the pin-adjacent
factor.

Definition of done (unchanged): all six `kampArm_*` lemmas green, axioms exactly
`[propext, Classical.choice, Quot.sound]`, sorry-free, zero-debt, full tree builds.

### What Changed From v2

- **NEW Phase R1 (mechanical refactor)** inserted between the negFix recursion core (Phase 10 tail)
  and the De Morgan fold (Phase 11): split `EANegationFix.lean` → `Kamp/EANegationFix/` 7-leaf DAG +
  re-export shim. Pure move of green proofs; `lake build` green before and after; the single downstream
  import (`NfMultiAnchorBridge.lean:78`) is untouched by the shim.
- **Exterior carriers re-cut** from v2's two phases (old 13-15) into **E1-E6** (Phases 13, 14a, 14b,
  14c, 15) on a small pre-built file DAG (`ExteriorFiberKitK1.lean`, `ExteriorNavPastK1.lean`,
  `ExteriorNavFutK1.lean`) instead of one ~1,500-line `AggregateExteriorK1.lean`.
- **Exterior Rabinovich anchor upgraded** from "Prop 3.5 device" to the named Section-7 lemmas
  **7.6 (gluing), 7.8 (Since/Until duality), 7.10 (one-sided fold)** — added to the grounding table.
- **Phase 11 retargeted** onto the post-R1 file `EANegationFix/VecEANegFix.lean`.
- **Phase 12 pre-split** into 12a (0,1) / 12b (0,2); **Phase 16 pre-split** into 16a (dispatcher +
  aggPop1) / 16b (arm lemmas + certificates); exterior phases pre-split at E-seams.
- **Two-sided `B_i` nuance** (`B_i = Bi⁻ ∧ Bi⁺`; `¬B_i` two-sided; (d)/(e) collapse pin factor) made
  explicit in the negFix recursion, De Morgan fold, and (where relevant) point-merge phases.
- **New H4 flags carried** (report 03 §"Could-not-ground"): displayed-equation typography is
  extract-lossy → the implementer MUST read the Rabinovich PDF for the exact `INF^{¬β1}` gate shape
  before encoding Case 3; E6 duality and `renameNF` genericity are NOT re-verified this dispatch →
  both marked probe-gated.
- All v2 completed phases (1-9, 10a, 10b-i, 10b-ii-1) preserved verbatim-in-substance as
  [COMPLETED]; Phase 10 marked [PARTIAL] per its live status.

### Research Integration

- **reports/03_rabinovich-grounding-and-api-division.md** (integrated in this v3, 2026-07-13):
  §1 per-construction Rabinovich anchor map (Lemma 5.1 Cases 1-3 + A_i/B_i split chunk_0015-0017;
  Prop 4.2/4.3 De Morgan chunk_0012; Lemma 3.2(2) point merges chunk_0009; Section-7 exterior
  Lemmas 7.6/7.8/7.10 chunks 0021-0023); §2 E1-E6 exterior decomposition table; §3 EANegationFix
  split DAG + exterior file DAG + naming convention; §4 H8 phase re-cut with R1 inserted; H4
  self-verification table (all structural mappings High; equation typography + E6 duality + renameNF
  genericity flagged). Report 03 is the PRIMARY source for the re-division.
- v2's research inputs (report 02, 309-side inputs, handoff blocker) remain integrated; the
  delivered-name map and binding guards carry over unchanged.

`reports_integrated`: `["03_rabinovich-grounding-and-api-division.md", "02_offdiag-k1-primitives.md"]`

### Prior Plan Reference

Supersedes `plans/02_offdiag-k1-aggregate-discharge.md` (v2), which superseded
`plans/01_aggregate-quantend-hook-discharge.md` (v1). All landed work (Phases 1-9, Phase 10 sub-parts
10a/10b-i/10b-ii-1) is preserved below as [COMPLETED]; Phase 10's negFix recursion core is preserved as
[PARTIAL] per its live status (commit `f38a5563c` = seam 1). No already-green proof is re-planned beyond
being relocated between files by the R1 refactor.

### Roadmap Alignment

No roadmap_path provided in the delegation context. This task advances the Kamp's theorem
formalization track (parent task 309, topic `kamp_theorem_formalization`).

### Literature Grounding (--lit)

Per-repo sub-index resolved (SUBINDEX_PRESENT). Ground truth, navigate on demand:
- **Rabinovich 2014, "A Proof of Kamp's Theorem"** —
  `/home/benjamin/Projects/Literature/sources/rabinovich_2014/` (chunks 0009-0023).
- **Kamp 1968** — `/home/benjamin/Projects/Literature/sources/kamp_1968_tense-logic-linear-order/`
  (background only; Rabinovich 2014 is the implementation source).
- Search: `bash .claude/scripts/literature-search.sh "<query>"`.
- **Citation rule (sub-index hazard note):** cite the PDF **by chunk / paper page**, never the
  paraphrase `md:NN` lines. Displayed equations are dropped in the extract — see H4 flag below.

**Rabinovich grounding table** (v3 — extends report 02's H3 table with report 03's Section-7 upgrade;
G5 applies — no simp/omega/aesop shortcut of any chain step):

| Paper source | Content | Lean target (phase) |
|---|---|---|
| Lemma 3.2(1) (chunk_0009) | Conjunction of →∃∀-formulas ≡ disjunction of →∃∀; merged points take conjoined point types PLUS the other bracket's ambient segment type | `BracketFormula.snoc/conjFull(_iff)`, `VVecEA2.conjFull(_iff)` (Phase 7 — DONE) |
| Lemma 3.4 (chunk_0010) | ∨→∃∀ closed under ∨, ∧, ∃ | `VVecEA2.conjFull(_iff)` (Phase 7 — DONE); aggPop1 fold (Phase 16b) |
| Dedekind inf/sup attained surrogate | `HasAttainedINF`/`HasAttainedSUP`; K+ limit disjuncts vacuous | `HasAttainedSUP` + `prior_hasAttainedSUP` (Phase 8 — DONE) |
| Lemma 5.3 (chunk_0014) | ¬∃-chain On-builder; induction on n; attained-inf pin | `negChainOn(_iff)` (Phase 8 — DONE) |
| Cor 5.4(1)/(2) (chunks 0014-0015) | ¬(∃z∈(z0,z1))[…] ≡ ∨→∃∀ + mirror; Until/Since-definable F_i; mirror needs attained SUP | `negBounded{Right,Left}Fix(_iff)` (Phase 9 — DONE) |
| Cor 5.4 anchored (chunk_0016 Case 2) | moving-endpoint α-parametrized fix (peeled point type α as anchor) | `negBounded{Right,Left}FixAnchored(_iff)` (Phase 10b-i — DONE) |
| Lemma 7.6 / Case-3 pin (chunks 0017, 0021) | pinned concatenation `(∃z1)_{z0}^{z2}(ϕ1∧ϕ2)` closure | `BracketFormula/VBracketFormula.concatPin(_holds_iff)` (Phase 10b-ii-1 — DONE) |
| Lemma 5.1 Cases 1-3 + A_i/B_i split (chunks 0015-0017) | fixed-formula negation `∨_i (Cond_i ∧ Form_i)`; gates ride in disjuncts; `B_i = Bi⁻ ∧ Bi⁺` (two-sided); (d)/(e) collapse pin factor | `BracketFormula.negFix(_iff)` (Phase 10 tail — PARTIAL) |
| Prop 4.2 / 4.3 (chunk_0012) | ¬(disjunction of →∃∀) ≡ conjunction of ¬ϕ_i via Lemma 3.4; ≤2-free-var split (Lemma 3.2(2)) per conjunct | `VecEA2.negFix`, `VVecEA2.negFix(_iff)` (Phase 11) |
| Lemma 3.2(2) (chunk_0009) | coincident-witness collapse to ≤2 free variables (conjunction of tied types) | point merges `AggregatePointMergeK1` (Phases 12a/12b) |
| Lemma 3.2(2) + Def 7.13 (chunks 0009, 0023) | 7-zone fiber partition; multi-anchor `(z0,…,zk,∞)-∨→∃∀` conjunction form | E1 `extZoneFiber_k1` (Phase 13) |
| **Lemma 7.10 / Prop 3.5** (chunks 0023, 0010) | one-free-variable fold to a single TL(Since/Until) predicate `endpointLeft/Right` at x/t | E2 `navPackLeft` (Phase 14a); E5 mirror (Phase 15) |
| **Lemma 7.6** (chunk_0021) | ∃w gluing across the pin at x: distribute w-independent parts out, glue w-package to (x,t) content | E3 `navDistribLeft` (Phase 14b); E4 `CExtPast` ∃w glue (Phase 14c) |
| **Lemma 7.8(1)/(2)** (chunk_0022) | past-exterior = Since / TL(Since,K⁺); future-exterior = Until / TL(Until,K⁻) duality | E4 `CExtPast` (14c); E5 `CExtFut` (15); optional E6 `extDuality` |
| Cor 5.4 "all order patterns" (chunks 0014-0015) | aggregate population match | `aggPop1(_correct)` + arm assembly (Phase 16) |

**H4 grounding flags (report 03 §"Could-not-ground", binding on the implementer):**
- **Equation typography is extract-lossy.** Displayed formulas are dropped from the text extract
  (e.g. `INF^{¬β1}` is mangled). Structural mappings above are High confidence, but the **exact
  quantifier decorations** of `[α0,β1,…](z0,z1)` and the Case-3 `INF^{¬β1}` gate CANNOT be lifted
  verbatim — the implementer MUST read `Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` for the precise
  displayed equation before encoding the Case-3 gate. (Medium confidence on typography only.)
- **E6 `extDuality` is probe-gated / optional.** No clean `M`-order-reversal lemma is confirmed to
  exist; chunk_0022 only says the dual is "proved similarly", which in Lean often means duplication.
  Land E6 only if a clean reversal is available; otherwise E5 duplicates the E1-E4 shapes.
- **`renameNF` gated-collapse genericity (Phases 12a/12b) NOT re-verified this dispatch.** The
  "same technique, new instances" claim for (0,1)/(0,2) rests on `agg_rename_fixpoint_of_eval` being
  rename-generic (inherited from plan/report-02, not re-opened). Medium confidence; Phase 12a's first
  task is a genericity probe (below).

## Delivered-Name Map (BINDING — consume by these names)

Carried from v2 unchanged. Task 349 delivered the endpoint recursion under these names (the
`CarrierK1V.lean` pair `endIntervalStep`/`EndIntervalCorrect` is superseded dead code — do NOT cite it):

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

**v1/v2-delivered names now binding** (task-350 assets, consume — never rebuild):

| Asset | Location |
|---|---|
| `agg2Past`/`agg2Fut`/`agg2Diag` + `_holdsRight_iff`/`_holdsLeft_iff`/`_iff` | AggregateHookDischarge.lean |
| `kampArm_{past,diag,future}_k0(_correct)`, `kampArm_diag_k1(_correct)` + shape certs | AggregateHookDischarge.lean |
| gated collapse: `agg_rename_fixpoint_of_eval` (:1853), `agg_diag_collapse_k1` (:1907), `aggMerge32`, `aggDiagGateK1`/`aggPosDiagK1(_correct)` | AggregateHookDischarge.lean |
| depth-1 fold engine (arity-generic, lossless iff) | `nf_eval_depth1_fold_iff`, CarrierKv.lean:466 |
| translation glue | `VVecEA2.translateRight(_correct)` NfToVecEA.lean:447/451; `VVecEA2.translateLeft(_correct)` VecEATranslation.lean:541/549 |
| attained INF/SUP | `HasAttainedINF` (PriorINF.lean:202), `prior_hasAttainedINF` (:226); `HasAttainedSUP` + `prior_hasAttainedSUP` (Phase 8 append) |
| **P1 conjFull kit** | `BracketFormula.snoc/conjFull(_iff)`, `VVecEA2.conjFull(_iff)`, `trivialTrue` neutrals — `Kamp/VecEAConjFull.lean` |
| **P2 negation stack (pre-R1)** | `negChainOn(_iff)`, `negBounded{Right,Left}Fix(_iff)`, `negBounded{Right,Left}FixAnchored(_iff)`, `BracketFormula/VBracketFormula.concatPin(_holds_iff)`, `bracketOne(_holds_iff)`, `negFix1*`, `negFixOne_cover/_iff`, `NegFixGateProbe.*` — `Kamp/EANegationFix.lean` (relocated by R1) |

At k=0 and k=1 the 349 recursion reduces by `rfl` (EndIntervalConsumerK.lean:266-271); the k=1 arm
carries ONLY `h0 : charF 0 = nf_depth0_char_formula atomMap h_surj`, dischargeable by construction. No
m+2-arm obligation enters this task's scope.

## Goals & Non-Goals

**Goals**:
- Complete the pending `negFix` recursion core (Phase 10 tail) per the settled design (Cases 1-3 with
  gates, Case 2 via anchored fixes, Case 3 via `concatPin` + `conjFull`, boundary (d)/(e)), landing
  `BracketFormula.negFix(_iff)`.
- Apply the EANegationFix split refactor (R1) as a pure mechanical move BEFORE the ~1,000 pending
  De Morgan/exterior lines land.
- Build the De Morgan fold (`VecEA2/VVecEA2.negFix`), the point-channel merges (0,1)/(0,2), and the
  Section-7-grounded exterior navigated carriers (E1-E6).
- Assemble `aggPop1(_correct)` and discharge the final two DoD lemmas
  `kampArm_past_k1(_correct)` / `kampArm_future_k1(_correct)` in the skeleton shape, with shape
  certificates, mirroring the delivered Phase-3 glue.
- Keep everything additive: new leaf modules + import lines + docstring-only doc-hooks (R1 is the one
  exception — a relocation of already-green code, still additive at the module-DAG level).

**Non-Goals**:
- NO edit to `KampPrior.lean` (any part — task 358 territory AND task 309's Phase 19 edit).
- NO edit to `ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean` (task 358 concurrent — G6).
- NO edits to the seven frozen provider files: SharedWitness.lean, SubBracket2V.lean, OuterGate.lean,
  ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation(K).lean, ExteriorNegationPast(K).lean
  (read/consume only). `SharedWitness.lean` (12,800 ln, 89 dangling cites) is a SEPARATE later concern,
  NOT task-350 territory.
- NO rebuild of `endInterval_correct`, `seg_holds_coupled`, `nf_zone_flatten_navigable_correct`, the
  v1/v2-delivered agg2/kampArm/negation assets, or any 355/356/357/360 stack asset. R1 RELOCATES the
  negation assets between files but rewrites NO proof.
- NO modification of the delivered `AggregateHookDischarge.lean` lemmas/definitions (additive appends
  allowed ONLY where a phase below explicitly says so; default is new modules).
- NO k≥2 arm work (m+2 obligations route to task 358 / 309 Phase 14 per the 349 ledger).
- NO use of `nf_char3_deeper_split` (FORBIDDEN — Base.lean:603; refuted tower).
- NO re-attempt of the four machine-refuted v1 routes: `conj_struct`-based aggregation,
  `neg_2var_vec_ea` for syntactic use, depth-2 fold re-fibering (F1), gated anchor-collapse at the
  x/t pair off-diagonal.

## Binding Guards (inherited verbatim from v1/v2 + G6)

- **G1** — no arity-1 collapse: every population obligation stays the honest arity-3
  `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` on the full env.
- **G2/G4** — anchors strictly `{x, t}` (≤2 cap); `w` and every interior point are bracket witnesses,
  never a third free anchor.
- **G3** — non-trivial segments: reuse the landed `seg`/carrier bracket content; never
  `TemporalPred.top` as the off-diagonal interval type.
- **G5** — no `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step; manual bridges
  (`constructor`/`intro`/`exact`) at every Lemma 3.2/3.4/5.1/5.3/Cor 5.4/§7 step.
- **G6 (task-358 territory)** — zero hunks in `KampPrior.lean`, `ExteriorPinnedConverseK.lean`,
  `ExteriorPinnedConversePastK.lean` in any commit of this task. Verified per phase via `git diff --stat`.
- **FORBIDDEN**: `nf_char3_deeper_split`; resurrection of retired interfaces (`hbr*` family,
  `bracketEndChar_kvE'_correct*`, the dead `CarrierK1V` `endIntervalStep`/`EndIntervalCorrect`).
- **Axioms**: every new lemma `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`.
- **Sorry-free / zero-debt**: no sorry, no vacuous defs (`def X := True` etc.); if a sub-piece cannot
  close green, mark the phase [BLOCKED] with the exact obstruction and escalate — do not land debt.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1 (was R2): negFix recursion core Case-3 A_i/B_i cover proof (the one non-machine-checked pillar) fails at a disjunct | H | M | Landing concurrently per the settled design (handoffs/phase-10-recursion-core-settled-design.md); the n=1 `negFixOne` shapes {A,B1,B2,B3,B4,B4′} are the specialization templates; on failure mark Phase 10 [BLOCKED] with the failing disjunct — do NOT proceed to R1/Phase 11 |
| R2 (NEW): the R1 split re-import breaks a proof via a lost transitive import or a namespace-open ordering change | M | L | R1 is pure relocation with green-before/green-after gates; move one leaf at a time, `lake build` after each; the shim `import`s all leaves so downstream sees the identical surface; leaves never import the shim or any `NfMultiAnchorBridge/*` (acyclicity, §3.1) |
| R3 (was R3): exterior navigated carrier (E1-E5) rests on a structural argument verified by file reads, not machine-checked (report confidence: Medium) | H | M | E1 (Phase 13) lands the single-fiber R3 probe (one bit-true + one bit-false inner fiber, one concrete qnf, end-to-end) BEFORE E2 generalizes; on failure [BLOCKED] with the exact fiber + qnf pattern |
| R4: disjunct-count growth in conjFull folds (Delannoy-like) → elaboration blowup at Phase 16b's `Finset.univ` fold | M | M | Carriers are noncomputable proof objects; fold induction over `conjFull_iff` never normalizes disjunct lists; raise `maxHeartbeats` locally (precedent 1600000) |
| R5: merge conflicts / build breakage from concurrent task 358 AND the concurrent Phase-10-core dispatch | M | M | G6 file territory; all new code in new leaf modules; the negFix-core dispatch owns `EANegationFix.lean` until R1 — DO NOT start R1 until that dispatch reports green; rebase before each phase commit; scoped `lake build` per phase |
| R6: Case-3 `INF^{¬β1}` gate encoded with wrong quantifier decoration (H4 typography flag) | H | M | Implementer reads the Rabinovich PDF displayed equation before encoding the gate; the landed `negFixOne` n=1 gate list is the checked specialization the general gate must reduce to at n=1 |
| R7: two-sided `B_i` mishandled — `¬B_i` treated as one-sided, dropping the `Bi⁻`/`Bi⁺` split | H | M | Explicit in Phase 10-tail and Phase 11 tasks: `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺`, concatPin handles each side, (d)/(e) collapse the pin-adjacent factor; the n=1 `negFix1B*` backward lemmas are the pattern |
| R8: E6 duality assumed available; no clean `M`-reversal exists (H4 flag) | M | M | E6 is optional/probe-gated; E5 duplicates E1-E4 shapes as the fallback (report §2, §"Could-not-ground") |
| R9: `renameNF` gated-collapse not rename-generic for (0,1)/(0,2) (H4 flag) | M | L | Phase 12a's FIRST task is a genericity probe encoding the (0,1) merge end-to-end for one qnf; on failure [BLOCKED] with the failing rename before generalizing to (0,2) |
| R10: phase overrun vs. H8 sizing | M | M | Pre-declared seams (12a/12b, 14a/14b/14c, 15a/15b, 16a/16b); further in-phase seams declared per phase; resume with `/implement 350` |
| R11: statement-shape churn (H5 history: 4 strikes in 309, 1 blocker in v1) | H | M | The grounding-table signatures ARE the statements; each phase lands full-statement stubs first; any alteration requires an inline deviation note |

## Design (carried and extended)

**Assembly (Phase 16, consumes P1-P3), from report 02/03:**

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
`VVecEA2.translateRight_correct`; future arm via `translateLeft`.

**Per-qnf dispatcher `C(qnf)`** (P3): split by qnf's w-zone channel (order bits at pairs (0,1),(0,2)
of `qnf.1`):
- **3-int (x<w<t)**: `bracketEndChar_kv_correct_one_prior` with `charF 0 := nf_depth0_char_formula
  atomMap h_surj`, `h0 := rfl`.
- **3-pt (w=x / w=t)**: (0,1)/(0,2) rename-merge variants of the delivered gated collapse (Phases
  12a/12b) → fixed-anchor `nf_eval_nf M 1 2 [x,t]` → `nf_eval_depth1_fold_iff` at n=2 → delivered
  agg2 kit. Non-fixpoint qnf gate to `bot`.
- **3-ext (w<x / t<w)**: 7-zone-fiber inner-navigation carriers (E1-E5): fold w-dependent fibers into
  a single Since/Until-navigated `endpointLeft/Right : TemporalPred` at x/t (Lemma 7.10/Prop 3.5);
  distribute w-independent parts out of the `∃w` (Lemma 7.6 gluing); past/future via Lemma 7.8 duality.
- **3-bot** (order-channel inconsistent): `bot` carrier + falsity lemma.

**Two-sided `B_i` nuance (report 03 §1.1, H4-verified High):** in the Case-3 A_i/B_i split at the pin
`r0`, `B_i` factors as `B_i = Bi⁻ ∧ Bi⁺` (a left/right product across the pin), so
`¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` is a **disjunction over the two sides**. The `concatPin` builder must handle each
side; boundary simplifications (d) `INF^{¬β1}(z) ∧ ¬B1⁺(z,z1) ≡ INF^{¬β1}(z)` and (e)
`INF^{¬β1}(z) ∧ ¬Bn+1⁻(z0,z) ≡ INF^{¬β1}(z) ∧ (β1 on (z0,z) ∧ ¬Bn+1⁻(z0,z))` collapse the pin-adjacent
factor. This nuance is load-bearing in Phase 10-tail (negFix) and mirrored in Phase 11 (De Morgan).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 (done) | 1-9, 10a, 10b-i, 10b-ii-1 | -- (delivered) |
| 1 (in progress) | 10 (negFix recursion core tail) | 7, 9 (done); concurrent dispatch |
| 2 | R1 (refactor), 12a | 10 green (R1); delivered agg machinery (12a — parallel) |
| 3 | 11, 12b | R1 (11); 12a (12b) |
| 4 | 13 (E1) | 11 |
| 5 | 14a (E2) | 13 |
| 6 | 14b (E3) | 14a |
| 7 | 14c (E4) | 14b |
| 8 | 15 (E5) | 14c |
| 9 | 16a | 11, 12b, 15 |
| 10 | 16b | 16a |
| 11 | 17 | 16b |

Territory (H7): the negFix-core dispatch owns `EANegationFix.lean` through R1; Phase 12a owns
`AggregatePointMergeK1.lean` (file-disjoint, parallelizable with the negation stack). No shared files
within a wave. **R1 is the serialization point**: it must land after the negFix core is green and before
Phase 11, and it must not overlap the negFix-core dispatch (R5).

---

### Phase 1: Shape adjudication, zone classifier, and target statements [COMPLETED]

Preserved from v1 (delivered; commit history d0f3a4484..). Leaf module `AggregateHookDischarge.lean`
created + aggregator import; per-qnf order-bit zone classifier at the `ZoneSpec 2` fiber level
(`agg2Z*` + `agg2_zone_consistent_{lt,gt,diag}`); six target statements frozen in the module header;
R1 verdict = Route V for all arms; scoped build green (1032 jobs).

- **Timing**: 1.5 hours (spent) — **Depends on**: none

---

### Phase 2: k=0 aggregate population carrier + correctness [COMPLETED]

Preserved from v1. Depth-1 fold engine `nf_eval_depth1_fold_iff` re-fibers the k=0 population into
zone-monadic `(ZoneSpec 2 × NF 0 1)` fibers; delivered as `agg2Past`/`agg2Fut`/`agg2Diag` with
`_holdsRight_iff`/`_holdsLeft_iff`/`_iff`. Axioms exactly `[propext, Classical.choice, Quot.sound]`.

- **Timing**: 2 hours (spent) — **Depends on**: 1

---

### Phase 3: k=0 hook discharge — three arm lemmas [COMPLETED]

Preserved from v1. `kampArm_past_k0(_correct)` via `translateRight` + `translateRight_correct` +
`agg2Past_holdsRight_iff`; `kampArm_future_k0(_correct)` dual via `translateLeft`;
`kampArm_diag_k0(_correct)` additive diag variant. Three shape-certificate `example`s. Axioms clean.

- **Timing**: 2 hours (spent) — **Depends on**: 2

---

### Phase 4: k=1 DIAGONAL seam carrier + gated anchor-collapse machinery [COMPLETED]

Re-scoped from v1's blocked Phase 4 to its delivered green sub-scope (commits 3334dccb5, e8e86b419).
`agg_rename_fixpoint_of_eval` (:1853) + `agg_diag_collapse_k1` (:1907) + `aggDiagGateK1`/
`aggPosDiagK1(_correct)`. The off-diagonal remainder became Phases 7-16.

- **Timing**: 2 hours (spent) — **Depends on**: 2

---

### Phase 5: k=1 DIAGONAL arm lemma [COMPLETED]

Re-scoped from v1's blocked Phase 5. `kampArm_diag_k1` + `_correct` (DoD lemma 4/6) green with the k=1
shape certificate (commit e8e86b419); axioms exactly `[propext, Classical.choice, Quot.sound]`.

- **Timing**: 2 hours (spent, shared with Phase 4) — **Depends on**: 3, 4

---

### Phase 6: v1 wrap-up — verification, citability doc-hooks, summary [COMPLETED]

Preserved from v1. Full `lake build` green (1737 jobs); axiom checks clean on the four delivered arm
lemmas + three aggregate iffs; guard audit passed; three docstring-only citability hooks in Base.lean;
summary `summaries/01_...-summary.md`. (Audited the v1 4/6 sub-scope; full-DoD audit is Phase 17.)

- **Timing**: 1 hour (spent) — **Depends on**: 5

---

### Phase 7: (A / P1) conjFull kit — snoc, BracketFormula.conjFull, VVecEA2 lift [COMPLETED]

Preserved from v2 (delivered; commits 5c04425b5, c7082617b, 8180495e4). Rabinovich Lemma 3.2(1)/3.4
conjunction closure in full iff form, order-generic, in `Kamp/VecEAConjFull.lean`. Delivered:
`BracketFormula.snoc(_holds_iff)` (via `front`/`holds_succ_iff` last-witness decomposition),
`TemporalPred.eval_at_glue`, `BracketFormula.conjFull(_iff)` (n1+n2 recursion, `conjEverywhere` base +
`witness_position_trichotomy`), `VVecEA2.conjFull(_iff)`, `trivialTrue` neutrals (both sides). Axioms
exactly `[propext, Classical.choice, Quot.sound]`; full `lake build` green (1738 jobs).

- **Timing**: 2 hours (spent) — **Depends on**: none
- **Files**: `Kamp/VecEAConjFull.lean` (new); one aggregator import line

---

### Phase 8: (B / P2a) HasAttainedSUP mirror + negChainOn [COMPLETED]

Preserved from v2 (delivered; commits 59d05c427, 68abf5178, c3d360d08, aa0319a23). Additive
`HasAttainedSUP` + `prior_hasAttainedSUP` append to `PriorINF.lean` (R8 mechanical mirror);
`Kamp/EANegationFix.lean` created; `negChainOn` (Lemma 5.3 On-builder; nil ↦ empty-disjunction = False
per the machine-checked iff, deviation from v2's `trivialTrue`) + `negChainOn_iff` (via `chainAllTrue`
+ `orderedPointsExist_combine`). Axioms clean; full `lake build` green (1739 jobs).

- **Timing**: 1.5-2 hours (spent) — **Depends on**: 7
- **Files**: `PriorINF.lean` (additive append); `Kamp/EANegationFix.lean` (new); one import line

---

### Phase 9: (B / P2b) negBoundedRightFix + negBoundedLeftFix [COMPLETED]

Preserved from v2 (delivered; commits b0e106288, d85e8c466). Cor 5.4(1)/(2) in fixed-formula iff form,
both mirrors. `negBoundedRightFix(_iff)` (h_INF only; first-witness peel with the `le_or_gt y c`
relink) + `negBoundedLeftFix(_iff)` (h_INF + h_SUP via last-occurrence walk). Endpoint-free encoding
note carried (brackets carry no endpoint point types; `¬F_0(z0)` delivered as the attained first-`¬β_0`
pin bracket). Axioms exactly `[propext, Classical.choice, Quot.sound]`; EANegationFix.lean sorry-free.

- **Timing**: 2 hours (spent) — **Depends on**: 8
- **Files**: `Kamp/EANegationFix.lean`

---

### Phase 10: (C / P2c) BracketFormula.negFix — gated Cases 1-3 + ℤ counterexample [COMPLETED]

- **Goal:** Lemma 5.1 fixed-formula negation with the load-bearing `Cond_i` gates
  (`∨_i (Cond_i ∧ Form_i)`, chunk_0016), carrying the two-sided `B_i = Bi⁻ ∧ Bi⁺` nuance.
- **Live seam status (verified 2026-07-13):**
  - **10a COMPLETE and green** (commits a928ccf3f, 53d7f123e, 138c03fda): ℤ B4 counterexample
    (`NegFixGateProbe.*`, R2 GATE = GO), n=1 gate-complete list {A,B1,B2,B3,B4,B4′}
    (`bracketOne(_holds_iff)`, `negFix1*`, six `_backward` lemmas, `negFixOne_cover`, `negFixOne_iff`).
  - **10b-i COMPLETE and green** (commit 054818233, +475 lines): anchored Cor 5.4 mirrors
    (`untilFoldAnchored`/`sinceFoldAnchored`, `untilChainPredsAnchored`/`sinceChainPredsAnchored`,
    `exists_bracketOf_right_anchored_iff`/`exists_bracketSnocOf_left_anchored_iff`,
    `negBoundedRightFixAnchored(_iff)`/`negBoundedLeftFixAnchored(_iff)`).
  - **10b-ii unit 1 COMPLETE and green** (commit 37e24dce2, +112 lines): pinned-concatenation builder
    (`bracketOf_append_pin_holds_iff`, `BracketFormula.concatPin(_holds_iff)`,
    `VBracketFormula.concatPin(_holds_iff)`).
  - **10b-ii units 2+ (negFix recursion core) IN PROGRESS in a SEPARATE concurrent dispatch.** Commit
    `f38a5563c` ("negFix seam 1 — V-level helpers + first-neg pin dichotomy") has landed;
    `BracketFormula.negFix` / `negFix_iff` are NOT yet present in the file (verified: grep empty; file
    at 2,629 ln, sorry-free). **This phase remains [PARTIAL] until that dispatch lands
    `negFix(_iff)` green.**
- **Remaining tasks (the concurrent dispatch's scope; settled design in
  handoffs/phase-10-recursion-core-settled-design.md — do NOT re-derive):**
  - [ ] "First pin" well-ordering lemma (Classical.byCases on pin attainment; `INF^{¬β0}` first-point).
  - [ ] Case-3 A_i/B_i builders at the attained first-`¬β0` pin r0 (chunk_0017): A_i = failure inside
    the β0-prefix before the pin; `B_i = Bi⁻ ∧ Bi⁺`, so `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` — the negation is a
    **two-sided disjunction**, glued by `concatPin` per side (left leg on `(z0,r0)`, right leg on
    `(r0,z1)`) + `conjFull` (Phase 7) for the `Cond_i ∧ Form_i` products; boundary (d)/(e) collapse the
    pin-adjacent factor. Recurse by IH on strictly smaller brackets.
  - [ ] `def BracketFormula.negFix {n} (bf : BracketFormula n) : VBracketFormula` — Cases 1-3 with
    gates: Case 1 via `negFixOne_iff` (n=1 base); Case 2 via the ANCHORED
    `negBoundedRightFixAnchored`/`negBoundedLeftFixAnchored`; Case 3 via the A_i/B_i split above.
  - [ ] `theorem BracketFormula.negFix_iff (h_INF) (h_SUP) (bf) (z0 z1) (h_lt : z0 < z1) :
    (negFix bf).holds M atomMap z0 z1 ↔ ¬bf.holds M atomMap z0 z1` — constructor/rcases + classical
    case-split on pin attainment, rewriting with `negFixOne_iff`, `negBounded*FixAnchored_iff`,
    `concatPin_holds_iff`, `conjFull_iff`. General disjuncts MUST specialize to the six n=1 shapes.
  - [ ] **H4 typography gate:** before encoding the Case-3 `INF^{¬β1}` gate, read
    `Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` for the exact displayed equation (extract-lossy).
  - [ ] Scoped build green; axiom checks; commit per green sub-step. If the cover proof fails at any
    disjunct: [BLOCKED] + exact failing case (do NOT proceed to R1 / Phase 11).
- **Robustness note (v3):** R1 and Phase 11 are GATED on `negFix(_iff)` being green. If this phase is
  still [PARTIAL] when the orchestrator reaches wave 2, R1 does not dispatch — the orchestrator resumes
  Phase 10 first. If the concurrent dispatch has already landed `negFix(_iff)` green (phase flips to
  [COMPLETED]), wave 2 proceeds directly to R1. Either marker is handled by the wave gate; no plan edit
  is required to switch.
- **Timing:** ~2 hours remaining (~500-900 lines). Seam: 10b-ii-2a (Cases 1-2), 10b-ii-2b (Case 3 + iff).
- **Depends on:** 7, 9 (both done)
- **Files:** `Kamp/EANegationFix.lean` (pre-R1)

---

### Phase R1: (refactor) split EANegationFix.lean → Kamp/EANegationFix/ DAG + re-export shim [COMPLETED]

- **Goal:** MECHANICAL relocation of the already-green, sorry-free negation kit out of the monolithic
  `EANegationFix.lean` (~2,900 ln after the negFix core lands) into a subdirectory module DAG, leaving
  the old path as a thin re-export shim so the single downstream consumer
  (`NfMultiAnchorBridge.lean:78`) is untouched. **No proof is rewritten — only declarations move.** This
  phase MUST land BEFORE the ~1,000 pending De Morgan/exterior lines (§3.1 sequencing constraint).
- **Precondition (hard gate):** Phase 10 `negFix(_iff)` green ([COMPLETED]); the concurrent
  negFix-core dispatch has released `EANegationFix.lean` (R5 — no overlapping edit). `lake build` green
  before the move.
- **Tasks:**
  - [x] Create `Kamp/EANegationFix/` subdirectory. Relocate declarations into seven leaves in the exact
    linear, cycle-free import order below (line ranges are the report's estimates against the 2,237-ln
    snapshot — RECOMPUTE against the live file via `/-! -/` section headers at move time; the DAG
    structure, not the numeric ranges, is binding): *(recomputed against the live 2,907-ln file:
    OnBuilder 1-253, BoundedFix 254-1102, BoundedFixAnchored 1103-1577, ConcatPin 1578-1689,
    NegFixOne 1690-2236 incl. NegFixGateProbe, NegFix 2237-2906)*

    | New file | Exports | Rabinovich layer | Imports |
    |----------|---------|------------------|---------|
    | `EANegationFix/OnBuilder.lean` | witness-combination kit + `negChainOn(_iff)`, `orderedPointsExist_combine` | Lemma 5.3 (chunk_0014) | `VecEAConjFull`, `EANegation`, `EANegationClosure` |
    | `EANegationFix/BoundedFix.lean` | temporal-pred Until/Since builders, `chainAllTrue`, Until/Since folds, list-form bracket bridges, `negBounded{Right,Left}Fix(_iff)` | Cor 5.4(1)/(2) (chunks 0014-0015) | `OnBuilder` |
    | `EANegationFix/BoundedFixAnchored.lean` | anchored folds + `negBounded{Right,Left}FixAnchored(_iff)` | Cor 5.4 anchored / Case 2 (chunk_0016) | `BoundedFix` |
    | `EANegationFix/ConcatPin.lean` | `bracketOf_append_pin_holds_iff`, `BracketFormula.concatPin(_holds_iff)`, `VBracketFormula.concatPin(_holds_iff)` | Lemma 7.6 gluing / Case-3 pin (chunks 0017, 0021) | `BoundedFix` |
    | `EANegationFix/NegFixOne.lean` | `bracketOne(_holds_iff)`, `negFix1*`, `negFixOne_cover/_iff`, `NegFixGateProbe.*` (ℤ counterexample) | Lemma 5.1 n=1 + gate necessity (chunks 0015-0016) | `BoundedFixAnchored`, `ConcatPin` |
    | `EANegationFix/NegFix.lean` | `BracketFormula.negFix(_iff)` (Cases 1-3, A_i/B_i split, (d)/(e)) — the Phase-10-tail deliverable | Lemma 5.1 full (chunks 0016-0017) | `NegFixOne`, `ConcatPin`, `BoundedFixAnchored`, `VecEAConjFull` |
    | `EANegationFix.lean` (**shim**) | `import`s all six leaves above; keeps the namespace | — | all leaves |

  - [x] **Import DAG (acyclic, linear):**
    `OnBuilder → BoundedFix → {BoundedFixAnchored, ConcatPin} → NegFixOne → NegFix → (shim)
    EANegationFix → NfMultiAnchorBridge`.
  - [x] **Acyclicity invariants (must hold after every leaf move):** (a) the shim is import-only —
    leaves NEVER import the shim; (b) no `EANegationFix/*` leaf imports any `NfMultiAnchorBridge/*`
    aggregate module (the negation kit is order-generic and stays upstream of the aggregate carriers).
    *(verified: zero `import ...EANegationFix$` and zero `NfMultiAnchorBridge` imports in leaves)*
  - [x] Move one leaf at a time, `lake build` after each; verify `NfMultiAnchorBridge.lean:78` import
    line is unchanged (shim keeps the aggregator line stable). *(6 leaf moves, each committed on a
    green full build: f4ab474b6 OnBuilder, R1.2 BoundedFix, R1.3 BoundedFixAnchored, R1.4 ConcatPin,
    R1.5 NegFixOne, R1.6 NegFix+shim; NfMultiAnchorBridge.lean:78 byte-identical)*
  - [x] Post-move: full `lake build` green; `lean_verify` on a representative export from each leaf =
    exactly `[propext, Classical.choice, Quot.sound]` (identical to pre-move); `git diff` shows only
    file moves + import lines, NO proof-body changes; commit. *(1745 jobs green; all 6 representative
    exports verified at exactly [propext, Classical.choice, Quot.sound]; reconstructed concatenation of
    the six leaves diffs byte-for-byte clean against the pre-split 2,907-ln file)*
- **Note (VecEANegFix leaf):** the seventh leaf `EANegationFix/VecEANegFix.lean` (Prop 4.2 De Morgan
  fold) is created and populated by **Phase 11**, NOT R1 — its content does not exist yet, so R1 only
  wires it into the shim if Phase 11 is folded in later; default is R1 creates the six above and Phase 11
  adds `VecEANegFix.lean` + its shim import line.
- **Timing:** ~1 hour (~0 net lines; relocate ~2,900). Seam: one commit per leaf move is the natural seam.
- **Depends on:** 10 green
- **Files:** 6 new `Kamp/EANegationFix/*.lean` leaves + the `Kamp/EANegationFix.lean` shim; NO change to
  `NfMultiAnchorBridge.lean`

---

### Phase 11: (C / P2d) VecEA2/VVecEA2.negFix — De Morgan fold [COMPLETED]

- **Goal:** Prop 4.2 / 4.3 (chunk_0012) at the disjunction-of-→∃∀ level: negation of a whole VVecEA2 via
  the De Morgan fold `¬(∨ ϕ_i) ≡ ∧ ¬ϕ_i` closed under conjunction (Lemma 3.4).
- **Tasks:**
  - [x] Create `EANegationFix/VecEANegFix.lean` (imports `NegFix`, `VecEAConjFull`); add its import line
    to the R1 shim. *(done; shim docstring updated to list the seventh leaf)*
  - [x] `def VecEA2.negFix` — per-disjunct 3-way split `¬el ∨ ¬er ∨ ¬bracket` (Lemma 3.2(2) two-free-var
    split composed with Prop 4.2): endpoint legs `¬el`/`¬er` are one-free-variable negations (atomic in
    the canonical TL expansion, chunk_0011); the bracket leg is `BracketFormula.negFix`. **Carry the
    two-sided `B_i` nuance** where the bracket leg surfaces `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺`. *(endpoint legs =
    `neg`-endpoint disjuncts with trivial `top` brackets; bracket leg maps `negFix.disjuncts` under
    `top` endpoints, consuming the two-sided Case-2/Case-3 gate structure opaquely via `negFix_iff`;
    plus `VecEA2.negFix_iff`)*
  - [x] `def VVecEA2.negFix (v : VVecEA2) : VVecEA2 := foldr VVecEA2.conjFull` over the per-disjunct
    `VecEA2.negFix` + `theorem VVecEA2.negFix_iff (h_INF) (h_SUP) (v) (z0 z1) (h_lt : z0 < z1) :
    (v.negFix).holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1`. *(fold with `trivialTrue` neutral
    element; list-form helper `vecEANegFixFold_iff` by induction, cons step = `conjFull_iff` +
    `VecEA2.negFix_iff`)*
  - [x] Scoped build green; axiom checks exactly `[propext, Classical.choice, Quot.sound]`; commit.
    *(full `lake build` green, 1746 jobs; `lean_verify` on both `VecEA2.negFix_iff` and
    `VVecEA2.negFix_iff` = exactly `[propext, Classical.choice, Quot.sound]`; sorry census in scope: 0)*
- **DoD shape:** `VVecEA2.negFix_iff` green; the fold reduces per-disjunct to `BracketFormula.negFix_iff`.
- **Timing:** ~1.5 hours (~200-300 lines) — **Depends on:** R1
- **Files:** `EANegationFix/VecEANegFix.lean` (new) + R1 shim import line

---

### Phase 12a: (D / P3-pt) point-channel merge variant (0,1) + genericity probe [COMPLETED]

- **Goal:** Per-qnf k=1 carrier for the w=x channel via a new rename-merge variant of the delivered
  gated collapse. File-disjoint from the negation stack (parallelizable, wave-2).
- **Tasks:**
  - [x] Create `Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean` importing `AggregateHookDischarge`;
    aggregator import line. *(388-line leaf module; aggregator NOTE + import after
    `AggregateHookDischarge`, commit 7167eb83e)*
  - [x] **R9 GENERICITY PROBE (first task):** encode the (0,1) merge end-to-end for ONE concrete qnf and
    prove its clause iff, confirming `renameNF` + `agg_rename_fixpoint_of_eval` are rename-generic at
    position (0,1). On failure: [BLOCKED] + the exact failing rename — do NOT generalize to (0,2).
    *(PASSED: `aggPm01Probe_clause_iff` for the all-false probe qnf, end-to-end through
    `renameNF_eval_diag0` (row + lifted-sub level) and `agg_rename_fixpoint_of_eval` at the new
    rename pair `aggPmExpand01` (0↦0, 1↦2) / `aggPmMerge01` (0,1↦0, 2↦1) with duplicated-head env
    `[x,x,t]`. All three engines rename-generic at (0,1); R9 retired. Landed in the same green
    commit as its supporting general collapse lemma — the probe was the first PROVED item; nothing
    generalized beyond (0,1).)*
  - [x] (0,1) merge variant (Lemma 3.2(2) coincident-witness collapse, chunk_0009): result is
    fixed-anchor `nf_eval_nf M 1 2 [x,t] (collapsed qnf)`; characterize via `nf_eval_depth1_fold_iff` at
    n=2; non-fixpoint qnf gate to `bot` exactly as `aggPosDiagK1`. *(`agg_pm01_collapse_k1` gated
    collapse; `aggPm01GateK1` + gate forcing `aggPm01_gate_of_eval`; clause iff `aggPm01_clause_iff`;
    dite carrier `aggPm01ClauseK1(_iff)` with off-gate `⊥` mirroring `aggPosDiagK1`; n=2 fold
    characterization `aggPm01_fold_iff` + end-to-end `aggPm01_clause_fold_iff`)*
  - [x] Scoped build green; axiom checks; commit. *(scoped 1033 jobs + aggregator 1044 jobs + full
    `lake build` 1747 jobs green; `lean_verify` on `aggPm01Probe_clause_iff`, `aggPm01ClauseK1_iff`,
    `aggPm01_clause_fold_iff` = exactly `[propext, Classical.choice, Quot.sound]`; sorry count in
    module: 0; commits 0ae5ff87c + 7167eb83e)*
- **DoD shape:** (0,1) carrier + clause iff green; the genericity probe passed.
- **Timing:** ~1.5 hours (~200-350 lines) — **Depends on:** delivered Phases 4-5 machinery (wave-2 parallel)
- **Files:** `Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean` (new); one import line

---

### Phase 12b: (D / P3-pt) point-channel merge variant (0,2) [COMPLETED]

- **Goal:** The w=t channel carrier, the (0,2) mirror of 12a.
- **Tasks:**
  - [x] (0,2) merge variant + per-channel carrier + clause iff (same technique as 12a, position (0,2)).
    *(rename pair `aggPmExpand02` (0↦1, 1↦2) / `aggPmMerge02` (0↦1, 1↦0, 2↦1) per the 12a-handoff
    orientation — env `[t,x,t]`, collapsed env `[x,t]` with anchor order kept; retraction by
    `decide`; wrappers `aggPm02{CollapseRow,DupRow,CollapseSub,DupSub,CollapseK1}`; gated collapse
    `agg_pm02_collapse_k1`; gate `aggPm02GateK1` + forcing `aggPm02_gate_of_eval`; clause iff
    `aggPm02_clause_iff`; dite carrier `aggPm02ClauseK1(_iff)` off-gate `⊥`; n=2 fold
    `aggPm02_fold_iff` + end-to-end `aggPm02_clause_fold_iff`. No new probe — R9 retired in 12a;
    all `hcomp`/`hcomp2`/`hE3` compatibilities closed by `rfl` at literal indices as predicted.)*
  - [x] Scoped build green; axiom checks; commit. *(scoped 1033 jobs + full `lake build` 1747 jobs
    green on FIRST build; `lean_verify` on `aggPm02ClauseK1_iff` and `aggPm02_clause_fold_iff` =
    exactly `[propext, Classical.choice, Quot.sound]`, no warnings; sorry count in module: 0;
    vacuous/axiom counts unchanged from HEAD baseline)*
- **DoD shape:** (0,2) carrier + clause iff green.
- **Timing:** ~1.5 hours (~200-350 lines) — **Depends on:** 12a
- **Files:** `Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean`

---

### Phase 13: (E1) exterior fiber kit + single-fiber R3 probe [COMPLETED]

- **Goal:** The 7-zone fiber partition kit for the exterior channels + the R3 adjudication probe, in new
  module `Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean`.
- **Rabinovich anchor:** Lemma 3.2(2) split (chunk_0009); Def 7.13 multi-anchor
  `(z0,…,zk,∞)-∨→∃∀` conjunction form (chunk_0023).
- **Tasks:**
  - [x] **R3 ADJUDICATION PROBE (first task):** for ONE concrete qnf with the w<x channel, encode one
    bit-true and one bit-false inner fiber end-to-end through the intended device and prove its clause
    iff. On failure: [BLOCKED] + the exact fiber + qnf pattern — do NOT generalize (E2 does not dispatch).
    *(PASSED: `extProbe_clause_iff` — probe qnf = w<x-channel order row `extProbeRow` + Classical
    single-true-bit quant layer `extProbeQuant` targeted at `nf0_assemble extZBelowW extProbeChi
    extProbeRow`. Bit-TRUE fiber (zone v<w, `extProbeChi`) realized (`extProbe_bitTrue_realized`);
    bit-FALSE interior fiber (zone x<v<t, same χ) excluded (`extProbe_bitFalse_excluded`). End-to-end
    through `nf_eval_depth1_fold_iff` at n=3 + the `nf0_{zoneSpec,projFresh,dropFresh}_assemble`
    round-trips + the per-zone readings. First PROVED item, committed green before the general kit
    landed (commit 8b4cafcc0). R3 retired for the E1 device.)*
  - [x] `extZoneFiber_k1`: apply `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]`, partitioning the
    depth-1 layer into monadic clauses over the 7 order-consistent zones of w<x<t
    (`v<w, v=w, w<v<x, v=x, x<v<t, v=t, t<v`).
    *(Landed: 7 zone constants `extZBelowW/extZAtW/extZIntWX/extZAtX/extZIntXT/extZAtT/extZAboveT`
    via `ext3Mk` over the delivered `agg2Ltz/Eqz/Gtz` pairs; arity-3 cons reading
    `ext3_zoneHolds_cons_iff` + builder `ext3_zs_ext`; 7 per-zone `extZ_*_holds_iff` monadic readings;
    `extZoneFiber_k1` = atom layer + 7 per-zone biconditional fiber clauses + inconsistent-zone
    falsity conjunct + off-fiber honesty clause, manual G5 bridges both directions.)*
  - [x] `extZone_consistent_*` falsity lemmas for order-channel-inconsistent qnf (delivered
    `agg2_zone_consistent_*` technique, arity-3 instance).
    *(`extZone_consistent_lt` routing lemma — realized zone spec is one of the 7 consistent zones,
    nested `lt_trichotomy` + `k1v_bool_eq_false`/`ext3_zs_ext`, exact agg2 technique at arity 3 —
    plus `extZone_inconsistent_false` — fold bit of every inconsistent fiber forced false under any
    realizer, via the fold engine.)*
  - [x] Scoped build green; axiom checks; commit.
    *(Scoped 1033 jobs + aggregator 1045 jobs + full `lake build` 1748 jobs green; `lean_verify` on
    `extProbe_clause_iff`, `extZoneFiber_k1`, `extZone_consistent_lt`, `extZone_inconsistent_false` =
    exactly `[propext, Classical.choice, Quot.sound]`, no warnings; sorry census over
    NfMultiAnchorBridge/: 0; module 631 lines; aggregator import + NOTE added after
    AggregatePointMergeK1; no frozen-file / KampPrior / task-358 edits.)*
- **DoD shape:** the single-fiber probe iff green; `extZoneFiber_k1` + consistency falsity landed.
- **Timing:** ~1.5 hours (~250-350 lines) — **Depends on:** 11
- **Files:** `Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean` (new); one import line

---

### Phase 14a: (E2) Since-navigated w-package `navPackLeft` [COMPLETED]

- **Goal:** Fold the w-dependent fibers (atoms at w; zones v<w, v=w, w<v<x) into a single
  `endpointLeft : TemporalPred` at x, in new module `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`.
- **Rabinovich anchor:** **Lemma 7.10 / Prop 3.5** one-free-variable fold to TL(Since,K⁺)
  (chunks 0023, 0010). This is the exact device replacing v2's bare "Prop 3.5 device".
- **Tasks:**
  - [x] `navPackLeft`: bit-true inner fibers = arrangement slots inside the fold; bit-false = exclusion
    segments / negated Since-lits (native `.snce`). May consume Phase-11 `negFix` for bit-false inner
    fibers if the exclusion-segment device is insufficient at any fiber (record which device each fiber
    uses).
    *(Landed: `navPackLeft σ : TemporalPred` = disjunction over `(navLBitTrueList σ).permutations` of
    the nested-Since chain `navLChain` (the `buildLeft` technique of Translation.lean, anchored at the
    w-point package `navLAtWPack` instead of `H`), guarded by the exclusion segment `navLSegGuard`.
    Fold iff `navPackLeft_correct`: predicate at x ↔ ∃ w < x with the four w-dependent clause groups
    of `extZoneFiber_k1` verbatim (atoms-at-w position-0 layer; v=w, v<w, w<v<x fiber biconditionals) —
    NO ambient hypothesis needed (the fold itself introduces w). DEVICE RECORD per fiber class:
    atoms-at-w = `nf_depth0_char_formula` on position-0 projection `navLProjW`; v=w bit-true/false =
    characteristic literal / negated characteristic; v<w bit-true/false = native Since-lit
    `S(charF χ, ⊤)` / negated Since-lit; w<v<x bit-true = arrangement slots (permutation-disjunct
    nested-Since chain, witnesses threaded by maximum extraction `navL_listMax` + profile uniqueness),
    w<v<x bit-false = exclusion segment (guard = disjunction of bit-TRUE characteristics; profiles
    exhaustive+exclusive force every interior point bit-true). Phase-11 `negFix` NOT needed at any
    fiber — exclusion-segment device sufficient everywhere.)*
  - [x] Scoped build green; axiom checks; commit.
    *(Scoped module 1034 jobs + aggregator 1046 jobs + full `lake build` 1749 jobs green;
    `lean_verify` on `navPackLeft_correct` = exactly `[propext, Classical.choice, Quot.sound]`, no
    warnings; sorry census over NfMultiAnchorBridge/: 0; module 488 lines; aggregator import + NOTE
    added after ExteriorFiberKitK1; no frozen-file / KampPrior / task-358 edits; vacuous/axiom counts
    unchanged from HEAD baseline.)*
- **DoD shape:** `navPackLeft` + its fold iff green for the probed fiber shapes generalized.
- **Timing:** ~1.5-2 hours (~300-400 lines) — **Depends on:** 13
- **Files:** `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean` (new); one import line

---

### Phase 14b: (E3) w-independent distribution `navDistribLeft` [COMPLETED]

- **Goal:** Distribute the w-independent parts out of the `∃w`.
- **Rabinovich anchor:** **Lemma 7.6** gluing decomposition (chunk_0021).
- **Tasks:**
  - [x] `navDistribLeft`: v=x char → `endpointLeft` conjunct; x<v<t fibers → (x,t) bracket arrangement
    slots + exclusion segment; v=t, t<v, atoms at t → `endpointRight`. (This peeling is what avoids both
    refutations: no monadic re-fibering of joint depth-1 content (F1); no single predicate carrying
    t-reads (world-locality).)
    *(Landed in ExteriorNavPastK1.lean: `navDistribLeft` — under ambient x<t,
    `∃ w < x, nf_eval [w,x,t] σ` ↔ `navPackLeft`@x ∧ `navDAtXPack`@x ∧ (x,t)-arrangement disjunct ∧
    `navDAtTPack`@t ∧ `navDOrderRow` ∧ inconsistent-zone falsity ∧ off-fiber honesty. Slot components:
    `navDAtXPack` = position-1 projection char + extZAtX char bitGroup (endpointLeft conjunct);
    `navDXTBracket` = BracketFormula.snoc-recursive arrangement (one witness slot per bit-true
    extZIntXT profile, head = slot nearest t) with `navDXTSegGuard` exclusion segment on EVERY gap,
    fiber iff `navDXTBracket_arrangements_iff` via sound/complete list inductions crossing the
    Fin bridge through `BracketFormula.snoc_holds_iff`/`trivial_holds` (VecEAConjFull import added);
    `navDAtTPack` = position-2 projection char + extZAtT char bitGroup + extZAboveT future
    Until-lit bitGroup (`navDFutLit` = `U(charF χ, ⊤)`, dual of `navLPastLit`) — every t-read at its
    own pin (world-locality); `navD_atomLayer_iff` splits the arity-3 atom layer into the three
    per-position predicate layers + the w-independent order row `navDOrderRow`.)*
  - [x] Scoped build green; axiom checks; commit.
    *(Scoped module 1035 jobs + aggregator 1046 + full `lake build` 1749 green; `lean_verify` on
    `navDistribLeft` and `navDXTBracket_arrangements_iff` = exactly
    `[propext, Classical.choice, Quot.sound]`, no warnings; sorry census over NfMultiAnchorBridge/: 0
    (compiler cross-check: all 30 project-wide sorry warnings pre-existing, outside territory);
    vacuous/axiom counts unchanged from HEAD baseline; no frozen-file / KampPrior / task-358 edits.)*
- **DoD shape:** `navDistribLeft` distribution lemmas green.
- **Timing:** ~1.5 hours (~200-300 lines) — **Depends on:** 14a
- **Files:** `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`

---

### Phase 14c: (E4) past carrier `CExtPast(_correct)` + ∃w pin glue + 3-bot falsity [COMPLETED]

- **Goal:** Assemble E1-E3 into the per-qnf past-exterior carrier with its full iff.
- **Rabinovich anchor:** **Lemma 7.6** `(∃z1)_{z0}^{z2}(ϕ1∧ϕ2)` closure (chunk_0021) for the ∃w glue at
  the pin x; **Lemma 7.8(1)** TL(Since,K⁺) (chunk_0022).
- **Tasks:**
  - [x] `CExtPast (qnf) : VVecEA2` (endpointLeft = `navPackLeft` ∧ v=x char; bracket = (x,t) slots;
    endpointRight = t-side fibers) + correctness:
    `(CExtPast qnf).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3
    (Fin.cons w (Fin.cons x (fun _ => t))) qnf` under ambient x < t — the **∃w glue across the pin at x**.
    *(Landed in ExteriorNavPastK1.lean: `navDGate` — the three pure σ-side conjuncts of
    `navDistribLeft` (order row, inconsistent-zone falsity, off-fiber honesty) as the carrier gate;
    `CExtPast` — `@dite _ (navDGate σ) (Classical.dec _)` (agg2Past pattern), on-gate one VecEA2
    disjunct per `L ∈ (navDXTBitTrueList σ).permutations` with shared endpoints
    `endpointLeft = ⟨(navPackLeft σ).formula.and (navDAtXPack σ)⟩`, `endpointRight = ⟨navDAtTPack σ⟩`,
    `bracket = navDXTBracket σ L`; off-gate the empty disjunction; `CExtPast_correct` — pure plumbing:
    `rw [navDistribLeft]` + dite split; on-gate the shared endpoints distribute over the arrangement
    ∃L via `temporal_truth_and`; off-gate both sides False.)*
  - [x] 3-bot falsity lemmas for order-channel-inconsistent qnf (arity-3 `agg2_zone_consistent_*`).
    *(`navD_inconsistent_eval_false` — eval-side: ¬navDOrderRow σ → no w<x<t triple realizes σ, via the
    extZoneFiber_k1 atom layer + navD_atomLayer_iff; `CExtPast_offGate_false` — carrier-side: off-gate
    holds is False at EVERY pin pair, no ambient; `CExtPast_inconsistent_false` — the order-row
    specialization, agreeing with CExtPast_correct as False ↔ False.)*
  - [x] Scoped build green; axiom checks; commit.
    *(Scoped module 1035 jobs green + full `lake build` 1749 green; `lean_verify` on `CExtPast_correct`,
    `navD_inconsistent_eval_false`, `CExtPast_inconsistent_false` = exactly
    `[propext, Classical.choice, Quot.sound]`, no warnings; sorry census over NfMultiAnchorBridge/: 0
    (compiler cross-check: all 30 project-wide sorry warnings pre-existing, outside territory); no new
    vacuous defs or axioms; diff = ExteriorNavPastK1.lean only (+118 lines); no frozen-file /
    KampPrior / task-358 edits; `nf_char3_deeper_split` not referenced.)*
- **DoD shape:** `CExtPast_correct` green (the w<x channel per-qnf carrier iff).
- **Timing:** ~1.5-2 hours (~300-400 lines) — **Depends on:** 14b
- **Files:** `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`

---

### Phase 15: (E5 + optional E6) future-exterior mirror `CExtFut(_correct)` [IN PROGRESS]

- **Goal:** The t<w channel: Until-navigated mirror of E2-E4, in new module
  `Kamp/NfMultiAnchorBridge/ExteriorNavFutK1.lean`; plus the optional shared `extDuality` (E6).
- **Rabinovich anchor:** **Lemma 7.8(2)** TL(Until,K⁻) duality (chunk_0022).
- **Tasks:**
  - [ ] (E5) Mirror `navPackRight`/`navDistribRight` (Until-navigated, `endpointRight` side) +
    `CExtFut (qnf)` + correctness iff (mirror statement) + 3-bot falsity lemmas.
  - [ ] (E6, OPTIONAL / probe-gated) `extDuality`: a genuine order-reversal lemma so E5 consumes E1-E4
    by duality rather than duplicating. **Land ONLY if a clean `M`-reversal is available** (H4 flag: not
    confirmed to exist; chunk_0022 says only "proved similarly"). If no clean reversal: E5 duplicates the
    E1-E4 shapes (the fallback) — record the decision.
  - [ ] Scoped build green; axiom checks; commit.
- **DoD shape:** `CExtFut_correct` green (t<w channel carrier iff); E6 landed or explicitly deferred to
  duplication with a recorded decision.
- **Timing:** ~2 hours (~350-450 lines). Seam: 15a = package (navPack/navDistribRight), 15b = carrier.
- **Depends on:** 14c
- **Files:** `Kamp/NfMultiAnchorBridge/ExteriorNavFutK1.lean` (new); one import line

---

### Phase 16a: (F) zone classifier + per-qnf dispatcher `C(qnf)` + clause iff [NOT STARTED]

- **Goal:** The arity-3 zone classifier and the per-qnf dispatcher over all channels, in new module
  `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean`.
- **Rabinovich anchor:** Cor 5.4 "all order patterns" (chunks 0014-0015).
- **Tasks:**
  - [ ] Create `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (imports `VecEAConjFull`,
    `EANegationFix` (shim), `AggregatePointMergeK1`, `ExteriorNavPastK1`, `ExteriorNavFutK1`,
    `AggregateHookDischarge`); aggregator import line.
  - [ ] Zone-classifier totality for arity 3 (order bits at pairs (0,1),(0,2) of `qnf.1`): every qnf
    routes to exactly one of 3-int / 3-pt(w=x) / 3-pt(w=t) / 3-ext(w<x) / 3-ext(t<w) / 3-bot given
    ambient x < t; mirror classification for the future arm.
  - [ ] Per-qnf dispatcher `C (qnf) : VVecEA2` + clause iff, casing on the classifier: interior via
    `bracketEndChar_kv_correct_one_prior` (`charF 0 := nf_depth0_char_formula atomMap h_surj`,
    `h0 := rfl`; cite `endInterval_correct` in the docstring); points via Phase-12a/12b carriers;
    exteriors via Phase-14c/15 carriers; 3-bot via falsity lemmas.
  - [ ] Scoped build green; axiom checks; commit.
- **DoD shape:** classifier totality + `C(qnf)` clause iff green for every channel.
- **Timing:** ~2 hours (~300-400 lines) — **Depends on:** 11, 12b, 15
- **Files:** `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (new); one import line

---

### Phase 16b: (F) aggPop1 + kampArm_past_k1 / kampArm_future_k1 + shape certs [NOT STARTED]

- **Goal:** The final two DoD lemmas, assembled exactly like delivered Phase 3.
- **Rabinovich anchor:** Lemma 3.4 closure under ∧/∃ (chunk_0010).
- **Tasks:**
  - [ ] `aggPop1` (conjFull-fold over `(Finset.univ : Finset (NormalForm sig 1 3)).toList` with `negFix`
    on bit-false qnf; `Fintype` at NormalForm.lean:167) + `aggPop1_correct` (statement verbatim from the
    Design section; `h_INF := prior_hasAttainedINF … h_UZ`, `h_SUP := prior_hasAttainedSUP … h_SZ`; fold
    induction over `conjFull_iff` + per-qnf `C`-iff / `VVecEA2.negFix_iff`; local `maxHeartbeats` raise
    if needed, R4). Mirror `aggPop1F` for the future arm if the classifier mirror requires a distinct
    carrier (record decision).
  - [ ] `kampArm_past_k1(_correct)`: atom-layer endpoints ∧ aggPop1, enter via
    `VVecEA2.translateRight_correct` (NfToVecEA.lean:451). `kampArm_future_k1(_correct)`: exact dual via
    `translateLeft_correct` (VecEATranslation.lean:549), flipped origin guard as in `agg2Fut`.
  - [ ] Shape certificates: `example`s matching each conclusion against the corresponding
    `kampPrior_site_trichotomy` disjunct SHAPE at generic-site index `1 + 1` (verbatim; no KampPrior
    import — delivered Phase-3/5 technique).
  - [ ] Scoped build green; `lean_verify` on both `_correct` lemmas = exactly
    `[propext, Classical.choice, Quot.sound]`; commit per green sub-step.
- **DoD shape:** `kampArm_past_k1_correct` and `kampArm_future_k1_correct` green (DoD lemmas 5/6, 6/6);
  shape certificates compile.
- **Timing:** ~2 hours (~250-400 lines) — **Depends on:** 16a
- **Files:** `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean`

---

### Phase 17: (G) full-DoD verification, citability doc-hooks, wrap-up [NOT STARTED]

- **Goal:** Definition-of-done audit for ALL SIX lemmas + downstream citability for 309 Phase 18b/19;
  close blk-350-p4-offdiag-k1-aggregate.
- **Tasks:**
  - [ ] Full `lake build` GREEN (whole tree; v2 baseline 1739 jobs).
  - [ ] `lean_verify` on all six `kampArm_{past,diag,future}_{k0,k1}_correct` (fully qualified) = exactly
    `[propext, Classical.choice, Quot.sound]`; record transcript in the summary.
  - [ ] Guard audit: `git diff --stat` over the task's commits shows NO changes to the seven frozen
    files, NO `KampPrior.lean` changes, and (G6) NO `ExteriorPinnedConverseK.lean` /
    `ExteriorPinnedConversePastK.lean` changes; KampPrior sorry count still exactly 2 (:361, :364); grep:
    zero term-level `nf_char3_deeper_split`, zero live `sorry` in all new modules. **R1 audit:** `git
    diff` on the EANegationFix move shows only relocations + import lines, no proof-body edits.
  - [ ] Update the Base.lean citability doc-hooks (docstring-only): replace the k=1 past/future blocker
    note with the two new lemma names + the EANegationFix/ module DAG map, so all six lemmas and the
    P1/P2/P3 primitives are findable by name from 309 Phase 18b.
  - [ ] Write summary `summaries/03_negfix-refactor-exterior-carriers-summary.md`: name map
    (deliverable ↔ consuming site, incl. the post-R1 module DAG), axiom-check transcript, 309 Phase-18b
    consumption instructions, blocker-resolution record.
  - [ ] Final commit; orchestrator handoff JSON → status reflecting full DoD (blockers []); task status update.
- **Timing:** ~1 hour — **Depends on:** 16b
- **Files:** `Kamp/NfMultiAnchorBridge/Base.lean` (docstring-only);
  `specs/350_.../summaries/03_negfix-refactor-exterior-carriers-summary.md` (new)

## Testing & Validation

- [ ] `lake build` (full tree) exits 0 after each phase (scoped) and at Phase 17 (full); green before
  AND after the R1 move.
- [ ] `lean_verify` on all six `kampArm_*_correct` + `conjFull_iff` (both levels) + `negFix_iff` (both
  levels) + `negChainOn_iff` + `negBounded{Right,Left}Fix(Anchored)_iff` + `concatPin_holds_iff` +
  `VVecEA2.negFix_iff` + `aggPop1_correct` + `CExtPast_correct`/`CExtFut_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- [ ] The ℤ B4 counterexample (`NegFixGateProbe.caseB4_holds`) still compiles (gate necessity).
- [ ] Two-sided `B_i`: the Case-3 negation exercises both `¬Bi⁻` and `¬Bi⁺` legs (the n=1 `negFix1B*`
  backward lemmas specialize the general two-sided disjuncts).
- [ ] R1 acyclicity: no `EANegationFix/*` leaf imports the shim or any `NfMultiAnchorBridge/*`;
  `NfMultiAnchorBridge.lean:78` import line unchanged.
- [ ] Probes passed: Phase 10 ℤ example + n=1 cover (R1-risk); Phase 12a (0,1) genericity probe (R9);
  Phase 13 single-fiber adjudication probe (R3).
- [ ] Shape certificates: each k=1 `_correct` conclusion matches the `kampPrior_site_trichotomy` disjunct
  verbatim (local `example`s compile, no KampPrior import).
- [ ] `git diff` across all task commits: no hunk in the seven frozen files, `KampPrior.lean`, or (G6)
  `ExteriorPinnedConverse{K,PastK}.lean`; KampPrior sorry count exactly 2.
- [ ] `grep -n "nf_char3_deeper_split"` over new modules: only docstring prohibition notes.
- [ ] `grep -c "sorry"` over new modules = 0 (code); no `def X := True`-style vacuities.
- [ ] Delivered v1/v2 assets unmodified except by the R1 relocation (which changes location, not proof body).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAConjFull.lean` (Phase 7 — P1, DONE)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean` → post-R1: re-export **shim** +
  `Kamp/EANegationFix/{OnBuilder,BoundedFix,BoundedFixAnchored,ConcatPin,NegFixOne,NegFix,VecEANegFix}.lean`
  (Phases 8-11 content + R1 relocation) + additive `HasAttainedSUP` append to `PriorINF.lean`
- `Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean` (Phases 12a/12b — P3 points)
- `Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean` (Phase 13 — E1)
- `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean` (Phases 14a/14b/14c — E2/E3/E4)
- `Kamp/NfMultiAnchorBridge/ExteriorNavFutK1.lean` (Phase 15 — E5/E6)
- `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (Phases 16a/16b — aggPop1 + final two DoD lemmas + certs)
- Aggregator import lines; docstring-only doc-hook update in `Base.lean` (Phase 17)
- `plans/03_negfix-refactor-exterior-carriers.md` (this plan)
- `summaries/03_negfix-refactor-exterior-carriers-summary.md` (Phase 17)
- Orchestrator handoff JSON updates at every phase-end commit

## Rollback/Contingency

- All Lean changes are additive (new modules + import lines + one additive PriorINF append + docstring
  edits) EXCEPT R1, which relocates already-green code between files with green-before/green-after gates;
  rollback of R1 = `git revert` of the move commits (restores the monolithic file); rollback of any other
  phase = removal of the module + import line. No landed proof body is modified, so rollback cannot break
  the four+two delivered lemmas or any downstream consumer.
- Commit-per-green-substep keeps every green milestone recoverable; run
  `bash .claude/scripts/git-snapshot.sh` before any intentional rollback.
- **Probe-gated escalation points** (do NOT proceed past a failed probe): Phase 10's ℤ example + n=1
  gated cover (R1-risk); Phase 12a's (0,1) genericity probe (R9); Phase 13's single-fiber adjudication
  probe (R3). On failure mark the phase [BLOCKED] with the exact obstruction (disjunct/rename/fiber +
  qnf pattern) and escalate — never land a vacuous or sorry'd encoding.
- **R1 serialization:** do NOT dispatch R1 until the concurrent negFix-core dispatch reports Phase 10
  green AND has released `EANegationFix.lean` (R5). If Phase 10 is still [PARTIAL] at wave 2, resume
  Phase 10 first.
- **H4 typography:** if the Case-3 `INF^{¬β1}` gate cannot be reconciled with the PDF displayed equation,
  mark Phase 10 [BLOCKED] with the ambiguity rather than guessing the quantifier decoration.
- If task 358's concurrent work creates upstream interface drift, rebase, re-run the scoped build, and
  record the drift; if drift invalidates a statement shape, record an inline deviation note (R11).
- If a phase overruns its H8 budget, split at the pre-declared seams (10b-ii-2a/2b, 12a/12b, 14a/14b/14c,
  15a/15b, 16a/16b, R1 per-leaf) and resume with `/implement 350`.
