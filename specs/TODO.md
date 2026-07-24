---
next_project_number: 387
---

# TODO

## Task Order

*Updated 2026-07-24. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 95,125,127,128,161,165,179,180,186,192,199,219,231,257,282,291,296,298,318,341,359,361,375,377,378,380,383,384,385,386 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 131,169,170,196,292,293,294 | 161,291,341,361 | formula-refactor, publication-quality, sorry-elimination, ... |
| 3 | 175,193,362 | 131,169,170,192,196,375 | formula-refactor, automation, strong_completeness |
| 4 | 177,178 | 131,193 | formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b
165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic

### Formula Refactor

161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theori
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Toolchain

291 [NOT STARTED] — Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to 

### Publication Quality

180 [NOT STARTED] — copyright_headers_universe_polymorphism_line_limits
292 [NOT STARTED] — Add Apache 2.0 copyright headers to all source files under Theori
293 [NOT STARTED] — Audit and fix Mathlib linter compliance across all sorry-free mod

### Sorry Elimination

294 [NOT STARTED] — Eliminate all sorry instances in Theorems/ModalS5.lean and Theore

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
186 [NOT STARTED] — unify_search_systems
192 [NOT STARTED] — master_tactic_dispatch
  └─ 193 [NOT STARTED] — codebase_tactic_refactor
199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)

### Dataset Enhancement

219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
257 [IMPLEMENTING] — large_data_storage_huggingface
282 [PARTIAL] — exhaustive_enumeration_by_default
296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt
298 [IMPLEMENTING] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor

### Reference Book

318 [NOT STARTED] — GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymo

### Kamp Theorem Formalization

341 [PLANNED] — Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier l
359 [NOT STARTED] — Boneyard ARCHIVE hygiene (NOT deletion — the Boneyard is a perman
375 [RESEARCHED] — Final assembly and axiom audit for the Kamp expressive-completene

### Kamp Completeness

377 [PARTIAL] — RESCOPED after research (report 01, machine-verified). The origin
378 [NOT STARTED] — DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding u
383 [BLOCKED] — FIRST, read the probe report produced by the adjudication task th

### Strong Completeness

361 [NOT STARTED] — Research + scoping for finite-context strong completeness (Contex
  └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet
  └─ 170 [NOT STARTED] — Dense (FrameClass.Dense) WEAK completeness green: make `completen
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet (see above)

### Repo Hygiene

380 [NOT STARTED] — Sweep ephemeral task-number pointers out of Theories/**/*.lean, r

### Documentation

384 [NOT STARTED] — Comment-only fix, ~6 sites (evidence: specs/reviews/review-2026-0

### Architecture

385 [NOT STARTED] — Triage the 21 non-Boneyard Metalogic files (4,837 LOC) outside th

### Metalogic

386 [NOT STARTED] — Re-point the general completeness theorem (Base) so all remaining

## Tasks

### 386. Repoint general completeness isolate base mcs debt
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: None

**Description**: Re-point the general completeness theorem (Base) so all remaining sorry debt is isolated in the one genuinely-hard branch (evidence: specs/reviews/review-2026-07-24-metalogic-cleanup.md, dimension 1). lean_verify findings (2026-07-24): completeness_dense is sorryAx-free (docstring stale — fixed by the flagship-docs task); the general completeness (Base) carries sorryAx, but two of its three branches can be re-pointed at existing clean fc-generic lemmas: mcs_mixed_case_absurd, and countermodel_dense_enriched (needs de-privatizing). After re-pointing, the Base-MCS discrete branch is the ONLY remaining debt — document it as such. Also fix the docstring/code mismatch at Completeness.lean :129 (docstring) vs :169 (code). Anchor by declaration name; verify with #print axioms before/after; no new sorries.

---

### 385. Orphan triage metalogic import closure
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: architecture
- **Dependencies**: None

**Description**: Triage the 21 non-Boneyard Metalogic files (4,837 LOC) outside the Bimodal import closure — compiled by nothing (inventory with file list: specs/reviews/review-2026-07-24-metalogic-cleanup.md, dimension 2). Three buckets, three different actions: (1) DELETE the dead duplicate aggregator Theories/Bimodal/Metalogic.lean (the live one is Theories/Bimodal/Metalogic/Metalogic.lean); (2) ARCHIVE the ~10 zeta-era probes and retired bridge modules to the appropriate Boneyard; (3) DECIDE re-import-vs-archive for the possibly-accidentally-dropped files: DenseSoundness, DiscreteSoundness, ConservativeExtension/ (x4), FMP/DenseFMP, DiscreteFMP — each needs an explicit verdict with rationale, not a blanket action. ALSO: reconcile the two Boneyards inconsistent build policies (top-level has a vacuous lake lib; Kamp/Boneyard/ has no glob at all) — pick one policy and apply to both. Coordinate with task 359 (decl-level archival) to avoid double-touching files.

---

### 384. Fix flagship status docs completeness discrete
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: documentation
- **Dependencies**: None

**Description**: Comment-only fix, ~6 sites (evidence: specs/reviews/review-2026-07-24-metalogic-cleanup.md, dimension 3). completeness_discrete is sorryAx-free (machine-verified 2026-07-24, axioms [propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]), but the library front door still misdocuments it: (1) the live aggregator Theories/Bimodal/Metalogic/Metalogic.lean:27-33 tables completeness_discrete as SORRY pointing at the retired KampPrior.lean:361/364 arms; (2) KampPrior.lean:946 and :1253 still assert those arms are open; (3) the completeness_dense docstring at BXCanonical/Completeness.lean:228 claims sorries remain but lean_verify shows it sorryAx-free. Correct all stale status tables/docstrings; anchor by DECLARATION NAME never line number (line anchors in this zone have rotted repeatedly); NO task-number references in Theories/**/*.lean. HIGH IMPACT, SMALL EFFORT — do before other cleanup so the library self-describes correctly.

---

### 383. Construct the phase 7 negationcase unblock per adjudication verdict
- **Effort**: 14-20 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: Task 382
- **Research**:
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/02_spawn-analysis.md]
  - [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/reports/02_rabinovich-faithfulness-crosscheck.md]
- **Plan**: [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/plans/01_phase7-negation-split.md]

**Description**: FIRST, read the probe report produced by the adjudication task this depends on, in full. Its GO/RECONCILE verdict determines which branch below applies -- do not skip this precondition check. If the verdict is GO: build, in dependency order, sub-decomposed into separate green committed sub-steps: (1) Native Lemma 3.2(1) on ExistsForallFormula -- conjInterleave + conjInterleave_iff (conjunction of two efSat iff disjunction via order-preserving chain interleavings, ~500-650 lines per the prior report unless the adjudication task corrected this estimate); (2) Native Lemma 3.4 ∧-closure -- veeConj + veeConj_iff (distribute ∧ over the two disjunct lists, apply step 1 pointwise, ~120-180 lines); (3) Arbitrary-pin Prop 4.2 negation bridge -- efSat_negation_general then prop42_veeSat_negation_general (De Morgan over the disjunct list, single-object negation by case analysis over order patterns, reassemble via step 2, ~250-400 lines); (4) Re-attempt Phase 7's negation case using the new engine. If the verdict is RECONCILE: build the smaller, concrete construction plan the adjudication task's report specifies instead (e.g. a re-targeted augTarget that always yields endpoint pins, or a direct transcription of Rabinovich's actual Prop 4.2 general-case proof from PDF pp.7-11) -- follow that report's own signatures/line estimates rather than the original report-06 proposal. If the adjudication report indicates neither branch cleanly resolves, do not force either construction; escalate this task to [BLOCKED] citing the specific unresolved question. Every deliverable lives in new file(s) under Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ (name provisional, e.g. ConjInterleave.lean, Prop42NegationGeneral.lean), off the live import path until Phase 7 rewires onto it, mirroring how Prop43.lean/Prop42ExistsForall.lean already sit off-path. lake build must stay EXIT 0 at the existing job count throughout; no new axiom/sorry may appear on completeness_discrete's axiom trace. No sorry, no vacuous placeholder, no Prop43Structural.lean hole. Cite Rabinovich by PDF page only. Durable-anchor headers only (no task-number references in Theories/ files). Once this task lands, resume the parent task at Phase 7 via /implement. Inherit topic kamp-completeness.

---

### 382. Adjudicate rabinovich faithfulness of the phase 7 negationcase unblock
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None
- **Research**: [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/02_spawn-analysis.md]
- **Plan**: [382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/plans/01_adjudicate-rabinovich-faithfulness.md]
- **Summary**: [382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/reports/01_go-reconcile-verdict.md]

**Description**: Re-derive, from Rabinovich's own text (cite by PDF page only; the companion .md transcription is corrupt), the actual proof methods of: Lemma 3.2(1) (conjunction of ∃∀-formulas iff disjunction of ∃∀-formulas, PDF p.4), Lemma 3.4's conjunction-closure step (PDF p.5, 'By (1) and (3) of Lemma 3.2'), and Prop 4.2's general (non-endpoint-restricted) negation-closure proof (Section 5, PDF pp.7-11, not just the p.6 statement). Cross-check each against: (1) Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ExistsForall.lean:1-90 (docstring + EndpointPinnedCapTrivial) to confirm/refute that this restriction is a repo-internal VecEA2-translation artifact ('we do not extend VecEA2 to carry caps -- that would be canonical-form machinery beyond Rabinovich', :23-28) rather than a feature of Rabinovich's own Prop 4.2 statement; (2) Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean (augTarget, augTarget_iff, augTarget_forward, augTarget_backward -- the Lemma 3.2(2) <=2-free-var reduction) to determine whether augTarget's reduction target could instead be re-stated to always land the 2 free variables at chain endpoints, eliminating the arbitrary-pin negation case entirely, and if so estimate that route's size; (3) the prior session's reports/06_phase4-unblock-construction.md sections 1-3 (the proposed order-preserving-interleaving construction, ~500-650 + 120-180 + 250-400 lines) to determine whether it matches Rabinovich's actual proof shape or is a heavier reinvention. Produce an explicit GO / RECONCILE verdict as the deliverable, written to this task's own specs/{NNN}_{SLUG}/reports/ directory (plus an optional small scratch .lean file in the same directory if needed to check a specific claim -- no Theories/ edits). GO: the prior report-06 construction (or a corrected version) is confirmed as faithful transcription of Rabinovich's own arguments, genuinely required at roughly the scoped size -- record corrected Lean signatures/line estimates if they differ. RECONCILE: the arbitrary-pin obligation is avoidable (e.g. augTarget re-targetable to endpoint pins, or Rabinovich's actual Prop 4.2 proof is materially smaller/differently shaped) -- record the concrete smaller construction plan with its own signatures and line estimate to be used instead by the dependent construction task. Cite Rabinovich by PDF page only. Do not edit Theories/. lake build must remain unaffected (read-only against the live spine; any scratch .lean lives under specs/, never imported). Inherit topic kamp-completeness.

---

### 381. Archive off faithful path kamp infra
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None
- **Research**: [381_archive_off_faithful_path_kamp_infra/reports/01_off-path-archival-map.md]
- **Plan**: [381_archive_off_faithful_path_kamp_infra/plans/02_off-path-archival.md]
- **Summary**: [381_archive_off_faithful_path_kamp_infra/summaries/02_off-path-archival-summary.md]

**Description**: Archive everything off the faithful Rabinovich path out of the LIVE build (into the permanent Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/ -- MOVE, never delete) BEFORE the k>=2 E[Sigma] re-architecture, so the workface contains only proof-term-live code plus confirmed reusable faithful assets. User directive: clear distractions first, then fill in what is actually needed.

BINDING CRITERION: per-DECLARATION proof-term reachability from completeness_discrete -- NEVER directory or filename. Three machine-observed traps make path heuristics unsafe: (1) Exterior* is mixed -- most of the 29 Exterior*.lean files are the dead arity-4 exterior program, but ExteriorNavPastK1/ExteriorNavFutK1 feed the live k=1 arm; (2) Separation/ is mixed -- Separation.KampTranslation is on the live spine while Separation.SeparationThm / ExpressiveCompleteness.* are the bit-rotted dead GHR alternative; (3) InteriorGateGeneralK has 3 live importers yet its Fib declarations are 0/5 proof-term reached (imported for its live parts) -- declaration-level extraction, not a file move.

CONFIRMED OFF-PATH (machine-established, archive after import-severing): the arity-4 Fib realization stack (charFib -- never a definition, 192 binders; kampPrior_hreal_supply -- 0 live non-probe importers, cleanly archivable; igFoldBitFib/igPtWFib/igEpLFib/igEpRFib -- circular + fiber-refuted, in a 3-live-importer file so split required); the standalone *Probe*/*Refutation* evidence files (~6k lines, incl. three *358*-named files that also violate no-task-references-in-deliverables); the bit-rotted GHR alternative Separation.SeparationThm / ExpressiveCompleteness.* (excluded from build, non-compiling, grep-0-sorries is meaningless -- archive LOUDLY because ExpressiveCompleteness/Theorem.lean has a signature-generalized outerIH that masquerades as the E[Sigma] solution).

MUST NOT ARCHIVE: the live chain completeness_discrete -> ... -> nf_nvar_exist_all_depths; the k=0/k=1 arms (kampPrior_case1_arm_k0/_k1, trichotomy_assemble, AggregateHookDischarge, AggregateOffDiagK1, ExteriorNav*K1); the reusable faithful assets (Prop 3.5 translateLeft/translateRight; contentful Prop 4.2 VVecEA2.negFix_iff; the consumed NfEFold vocabulary NormalFormEFold/EAtomDom/ZoneSpec/zoneHolds/efold_of_nf1 -- 7/14 reached); EANegation.lean:1090/:1249 (three-strikes, do not touch).

PROMOTE-NOT-DELETE: Kamp/Prop43.lean and NfMultiAnchorBridge/NavigatedEndChar.lean currently import from Kamp.Boneyard.* -- promote the needed decls OUT into live modules until no live file imports Kamp.Boneyard.* (overlaps the existing post-green Boneyard-hygiene task part 1; record which task lands it).

GUARDRAILS: full lake build stays EXIT 0 (baseline 1766 jobs) after EVERY batch; #print axioms completeness_discrete invariant (exactly the one permitted _k+2 sorry -- no new sorryAx, no lost live declaration -- the axiom check catches a silently-dropped dep a bare build might miss); the Boneyard is never emptied; archived files/decls get durable-anchor headers (declaration names, PDF pages, no task numbers). Verification-and-relocation ONLY: no new proof content, no sorry discharged.

DoD: every off-faithful-path declaration in scope archived; no live import into Kamp.Boneyard.*; k0/k1 arms + reusable assets unchanged in behavior; full-tree lake build GREEN at 1766 jobs; completeness_discrete axiom set identical to baseline; Boneyard contents intact. Detailed findings + phase plan + confirmed anchors: reports/01_off-path-archival-map.md.

---

### 380. Sweep stale task number pointers from lean sources
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: Sweep ephemeral task-number pointers out of Theories/**/*.lean, replacing them with durable anchors (declaration names, file:line, PDF pages). Enforces .claude/rules/no-task-references-in-deliverables.md, which ALREADY forbids these repo-wide outside specs/** -- this is backlog cleanup of pre-existing violations, not a new rule.

ROOT CAUSE, EVIDENCED: stale in-code pointers caused THREE separate rounds of wasted work in a single orchestration session of the Kamp completeness program: (1) a vacuity finding documented in-tree, dated, and read by nobody for 13 months; (2) an entire Rabinovich Section 5 that was already transcribed, live and sorry-free, while a plan was written to transcribe it; (3) the KampPrior.lean:507-518 note, which named task 358 as successor -- abandoned and superseded since 2026-07-14 -- AND mis-described the obstruction, making it actively misleading rather than merely dangling. That note is now corrected in place (durable anchors, residual recorded UNOWNED); ~10 more pointers remain in KampPrior.lean alone.

WHY IT KEEPS HAPPENING: task numbers are renumbered by vault operations and are meaningless to a future reader -- exactly the rationale no-task-references-in-deliverables.md already states. The advisory hook .claude/hooks/validate-no-task-references.sh (PostToolUse, non-blocking) surfaces a reminder but never blocks the write, so new pointers keep landing.

SCOPE: (1) inventory task-number citation patterns across Theories/**/*.lean (and any other non-specs/** deliverable); (2) replace each with a durable anchor -- follow the pattern Phase 9 established at KampPrior.lean:507-518, which cites declarations, file:line and PDF pages and records ownership status without naming a task; (3) where a pointer records genuine provenance with no durable equivalent, state the fact rather than the task number.

CONSIDER (raised, not decided): escalating validate-no-task-references.sh from advisory to blocking so new pointers cannot land. Evaluate false-positive risk before changing hook severity -- a blocking hook that misfires is worse than an advisory one that is read.

CONSTRAINTS: do not weaken, discharge or delete any declaration to remove a pointer -- comment/docstring edits only. Do not touch EANegation.lean:1090/:1249 or KampPrior.lean:520 proofs. Full lake build must stay EXIT 0 and the sorry census unchanged (baseline: 5 across Kamp/ -- 3 live, 2 dead in Boneyard).

EXEMPT (task numbers ARE permitted): specs/** artifacts, git commit messages, PR/branch metadata.

SIZING CORRECTION 2026-07-24 (metalogic cleanup review): this is much bigger than a light sweep — 1,362 live task-number-reference lines in Theories/**, 84% concentrated in Metalogic/, with SharedWitness.lean alone carrying 262. Plan accordingly (mechanical but large; consider scripted rewrite with per-file review rather than hand-editing). Durable-anchor replacements per .claude/rules/no-task-references-in-deliverables.md.

---

### 379. Rearchitect kampprior k2 onto unary esigma encoding
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: Task 381, Task 382, Task 383
- **Probe**:
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/01_arity-growth-sizing-probe.lean]
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/02_consumption-walk-probe.lean]
- **Research**:
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/07_faithful-esigma-negation-path.md]
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/18_readback-closed-finite-fl-rescope.md]
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/19_architecture-spike-A-vs-B.md]
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/20_plan19-format-faithfulness-remaining-work.md]
- **Plan**: [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md]

**Description**: CRITICAL PATH. Retire the k>=2 residual at KampPrior.lean:520 (tactic position; declaration head :346), the last blocker keeping sorryAx in completeness_discrete (Metalogic/BXCanonical/Completeness.lean:276). ADJUDICATED, DO NOT RE-LITIGATE (evidence: specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md, machine-checked).

THE OBSTRUCTION IS AN ARITY CAP, NOT AN INTERFACE GAP. The in-code note formerly called this the "P17-frozen-interface-gap" and assigned it to task 358; BOTH were wrong and the note has been corrected in place. The real defect in one line: the consumer binds charF : NormalForm sig j 1 -> Formula (unary), while the only producer (kampPrior_hreal_supply) binds charFib : NormalForm sig j 4 -> Formula (arity 4). The rungK gate (KampPrior.lean:948, general-k, landed, axiom-clean) CARRIES rather than discharges hreal: it needs (exists x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] sigma) -- an arity-4 joint type guarded only by a unary point type built from lossy projections.

RABINOVICH HAS NO ARITY-4 OBJECT IN 16 PAGES: Def 3.1 (PDF p.4) caps point types at ONE variable; Lemma 3.2(2) (p.4) caps at <=2 free variables; Def 4.1 (p.5) caps expansion atoms at unary. THE FROZEN PRODUCER UNARITY IS FAITHFULNESS, NOT A DEFECT -- the arity-4 CONSUMER is the off-paper party. This is the same defect that abandoned task 376 ("the engine was novel mathematics, and the refutations were the compiler correctly rejecting a false statement").

SCOPE: re-architect the k>=2 arms onto Def 4.1 unary E[Sigma]-atoms / Prop 4.3 (p.6) STRUCTURAL composition so the arity-4 obligation NEVER ARISES. Rabinovich needs no Feferman-Vaught because Prop 4.3 inducts over FORMULAS with processed depth folded into the signature as a unary E[Sigma]-atom, making composition structural rather than a theorem.

QUARANTINE BEFORE PLANNING (mandatory first step): kampPrior_hreal_supply, charFib, igPtWFib, igEpLFib, igEpRFib, igFoldBitFib are landed and READ AS NEARLY-WIRED-UP while being UNWIRED (consumed by no gate), machine-confirmed CIRCULAR (InteriorGateGeneralK.lean:1541) and fiber-refuted (ExteriorPinnedProbeM1K.lean:816). Their APPARENT completeness is precisely what sustained the 358 -> 374 -> 376 -> 377 chain: each successor saw a nearly-done supply and planned to consume it. Quarantine them before writing a plan or the cycle repeats a fifth time.

HARD PROHIBITIONS: (1) NO FEFERMAN-VAUGHT, NO NOVEL MATHEMATICS -- binding user constraint: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)." (2) chain_split is NON-APPLICABLE at ALL SEVEN zones -- do not retry it. Machine-checked both ways (reports/05_chain-split-arity4-nonapplicability-probe.lean, axiom-free, EXIT 0): its licensing precondition is a PATH constraint graph, but AtomKind.order (i j : Fin n) (h : i != j) gives an arity-4 NF the COMPLETE graph K4, so a cut at w leaves x1<->x, x1<->t, w<->t intact. nf2_pathShaped (faithful arity works) vs nf4_not_pathShaped (gate arity has no purchase). (3) THREE-STRIKES: EANegation.lean:1090/:1249 are the model-independent Prop 4.2 backward direction, ruled UNFIXABLE by two independent analyses -- do not touch. (4) Cite Rabinovich BY PDF PAGE ONLY (~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf); the companion .md is CORRUPT (inverts k!=m at md:199). (5) NO TASK-NUMBER POINTERS in Theories/**/*.lean -- use durable anchors.

GOOD NEWS, DE-RISKS THE RE-ARCHITECTURE: the assembly layer above is ALREADY general in k. kampPrior_case1_trichotomy_assemble (KampPrior.lean:250) takes (k : Nat) and NormalForm sig (k+1) 2, and both landed arms call it at concrete depth; kampPrior_site_rungK_gate_match (:948) is general-k and axiom-clean. ONLY the per-k arm triple is missing. If the arity-4 obligation is removed, the assembly layer should not need rework.

BUILD ON (landed, sorry-free, axiom-clean): Section5Correspondence.lean (page-cited Section 5 table + prop42_contentful_of_attained); lemma53 at the attained carrier; contentful Prop 4.2 = VVecEA2.negFix_iff (VecEANegFix.lean:164), already consumed at the k=1 arm (AggregateOffDiagK1.lean:1173-1205); kampPrior_case1_arm_k0/_k1; DedekindINF.lean; TemporalPred.disj.

AMENDED SORRY GATE: the only permitted live sorries are KampPrior.lean:520, EANegation.lean:1090, EANegation.lean:1249. Retiring :520 is this task DoD.

RELATION TO TASK 378: same program (faithful transcription), distinct scope -- 378 is Section 5 CARRIER work (fidelity-only, zero operational value); this task is Section 3/4 MACHINERY and is THE critical path. Deliberately NOT dependency-gated on 378 so the critical path is not blocked behind fidelity-only work. CAUTION: both touch Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ -- do not run them concurrently without checking file_scope overlap.

=== ADDED BY THE 2026-07-16 REVIEW (verified at HEAD; do not re-derive) ===

STALE ANCHORS IN THIS DESCRIPTION: `KampPrior.lean:520` has DRIFTED to `:562` (the note correction that landed with the adjudication added ~42 lines). The declaration head is `:346`, not the previously-cited `:212`. Anchor by DECLARATION NAME (`nf_nvar_exist_all_depths`, the `| _k + 2` arm), never by line -- every line-anchored pointer to this blocker in the repo has rotted at least once (:212/:351/:354/:361/:364/:520 all cited historically; all wrong now).

THE RESIDUAL IS LOAD-BEARING, NOT AN EDGE CASE: `kamp_prior_expressive_completeness` (:697) sets `k := psi.quantifier_depth` -- ARBITRARY -- and `nf_characterizable_temporal_prior` (:614) inducts over k, re-entering `nf_nvar_exist_all_depths ... k 1` at every successor step. So the k>=2 arm is value-reached for EVERY formula of quantifier depth >= 2, and CANNOT be domain-restricted away the way the n+2 arm was (`hn : n <= 1`, :571). As of today the Kamp theorem is formalized for quantifier depth <= 1 only.

OPEN SCOPE QUESTION -- RESOLVE THIS FIRST, BEFORE PLANNING: this charter says `re-architect the k>=2 arms`. The review found evidence that the arity-4 obligation is NOT local to the arms and that this framing may be UNDER-SCOPED. `nf_eval_nf` (NormalForm.lean:199-207) GROWS environment arity `n -> n+1` at every depth descent:
    | k+1, _, env, <atom_assignment, quant_assignment> => ... (forall sub_nf, (exists x, nf_eval_nf M k (_+1) (Fin.cons x env) sub_nf) <-> ...)
Descending from the live entry (arity 2) therefore manufactures arity 3, 4, ... So the arity-4 joint type at the rungK gate is GENERATED BY THE EVALUATOR THAT APPEARS IN THE STATEMENTS of every theorem on the chain (`nf_eval_nf` occurs 113x in KampPrior.lean alone, including in the statement of `nf_nvar_exist_all_depths` itself). Task 376s abandonment record reached the same conclusion independently and named it the TRUE ROOT DEFECT: `nf_eval_nf grows arity n->n+1 per depth descent, whereas Rabinovich never grows arity; the repos NormalForm sig k n is a Hintikka n-type, not Def 3.1s object (no ordered existential prefix, no alpha/beta interval layer), making Lemma 3.2(2) a theorem about the former and a NON-theorem about the latter.`

THE FAITHFUL SUBSTRATE ALREADY EXISTS AND IS UNADOPTED -- DO NOT REBUILD IT: `Kamp/NfEFold.lean` (688 lines, ZERO sorries, landed by task 310 Phase 1) lands the Def 4.1 E[Sigma]-fold TYPE and EVALUATOR. Its quant-assignment domain `EAtomDom sig k n := ZoneSpec n x NormalForm sig k 1` makes Lemma 3.2(2)s <=2-cap a TYPE-LEVEL INVARIANT -- `there is no slot for a joint (n+1)-ary sub-evaluation`. Its own docstring (NfEFold.lean:1-27) states the correct diagnosis verbatim and records that it was built to run alongside `nf_eval_nf` rather than replace it. Task 376s record: NfEFold.lean `states the correct diagnosis verbatim and was never adopted`. NOTE: NfEFold.lean IS now imported by ~22 live files (its docstring claim `Nothing in the existing development imports this file` is itself stale) -- establish whether it is merely imported or actually PROOF-TERM consumed before sizing.

SO THE FIRST RESEARCH DELIVERABLE IS A SIZING VERDICT, decided on evidence, between:
  (a) the arms can be re-architected onto Def 4.1/Prop 4.3 while KEEPING `nf_eval_nf` in the chains statements -- in which case this charters scope stands; or
  (b) retiring the arity-4 obligation requires MIGRATING the chain statements onto the NfEFold evaluator -- in which case this is a statement-level migration of `nf_nvar_exist_all_depths` -> `nf_characterizable_temporal_prior` -> `kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`, and the charter must be re-scoped (and `no_gaps_discrete_model_surgery`s consumption of US_expressively_complete_over_prior re-checked) BEFORE any proof work starts.
State which of (a)/(b) holds, with machine-checked evidence, before planning. Do not begin proof work under (a)s assumption without establishing it.

THIRD-ATTEMPT WARNING: 358 abandoned on this obligation; 376 abandoned on it FOR THIS EXACT DEFECT (`the engine was novel mathematics, and the refutations were the compiler correctly rejecting a false statement`). Set the GO/NO-GO gate early enough that a third abandonment is cheap. This repos strongest pattern is that decisive machine-checked refutations arrive FAST when the gate is set up front -- the 2026-07-15 adjudication is the model.

CONTEXT: full review at specs/reviews/review-2026-07-16.md. Tasks 303/305/307 abandoned as dead (targeted Boneyard-ed code / already answered); 95, 299, 375 now depend on this task.

---

### 378. Rebase section5 onto faithful dedekind carrier
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None

**Description**: DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding user directive: "If it's not on the critical path stub it out to leave behind for later when we do the dedicated complete proof system"). Re-base Rabinovich's Section 5 onto the FAITHFUL Dedekind carrier. THIS IS THE "dedicated complete proof system" WORK -- do not dispatch it as a side quest.

WHY IT WAS DEFERRED (do not re-litigate): fidelity-only, ZERO OPERATIONAL VALUE. The live goal chain runs on PRIOR STRUCTURES, where INF/SUP attainment holds outright via the UZ axiom (prior_hasAttainedINF, PriorINF.lean:224). Nothing in this tree ever evaluates against a non-attained Dedekind complete chain, so NO consumer can observe the difference between HasAttainedINF and HasDedekindINF. prior_hasDedekindINF/prior_hasDedekindSUP (DedekindINF.lean) already close that boundary: the faithful carrier is AVAILABLE on the live path whenever wanted. The value of this task is fidelity to the paper, not unblocking anything.

ALREADY LANDED AND GREEN -- BUILD ON THIS, DO NOT REBUILD IT:
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean -- LIVE and CI-protected (import edge from NfMultiAnchorBridge), sorry-free, all decls axiom-clean {propext, Classical.choice, Quot.sound}. Contains: HasDedekindINF/HasDedekindSUP (Rabinovich eq (5.2) stated faithfully as the disjunction of the paper's `Subcase r0 = z0` = K+(P1)(z0) and eq (5.2) verbatim, PDF p.8); the FOUR compatibility shims HasAttainedINF/HasDefinableINF.toHasDedekindINF + SUP duals (HasDefinableINF.toHasDedekindINF discharges the r0<=z1 vs r0<z1 reconciliation from the occurrence hypothesis rather than assuming it); prior_hasDedekindINF/prior_hasDedekindSUP; and the strictness delta hasDedekindINF_admits_kplus_shape + hasDefinableINF_incompatible_with_kplus. The shims are what a re-base needs FIRST -- they let the faithful carrier be consumed wherever the landed ones are supplied, so the re-base need NOT discard EANegationFix/.
- TemporalPred.disj (ExistsForallNF.lean) + TemporalPred.eval_at_disj (VecEAClosure.lean) -- the point-type primitive for eq (5.2)'s (P1(r0) v K+(P1)(r0)). Sorry-free, axiom-clean.
- Section5Correspondence.lean -- page-cited Section 5 correspondence table (PDF pp.7-11) + prop42_contentful_of_attained. Sorry-free, axiom-clean. READ THIS FIRST: Section 5 is ALREADY TRANSCRIBED in EANegationFix/ under names that mention neither Rabinovich nor lemma numbers. It was grep-discoverable for thirteen months and was STILL re-planned from scratch by successive agents, one of which marked six present, sorry-free rows ABSENT.
- lemma53 sorry-free at the attained carrier; hasDefinableINF_excludes_kplus (Lemma53.lean:282, axiom-clean) -- machine-proves HasDefinableINF DELETES the paper's disjunct (2); the whole reason the faithful carrier is needed.
- The EANegationFix/ tree -- live, correct at the attained carrier.

THE DEFERRED WORK (plan v2 Phases 6-8 carry full task breakdowns, verification gates, and a written GO/NO-GO kill criterion -- START THERE: specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md):
1. Lemma 5.3 (PDF p.8) -- negChainOnFaithful over HasDedekindINF, restoring the PRINTED THREE-disjunct O_n+1: (1) (Ay)^{<z1}_{>z0}-P1(y); (2) K+(P1)(z0) ^ O_n(P2..Pn,z0,z1) <-- DELETED by the landed attained simplification; (3) (Er0)^{<z1}_{>z0}(INF(z0,r0,z1,P1) ^ O_n(P2..Pn,r0,z1)). The landed negChainOn (EANegationFix/OnBuilder.lean:149) truncates to TWO. Result type MUST be VVecEA2, NOT VBracketFormula: disjunct (2) conjoins the endpoint predicate K+(P1) at z0, which VBracketFormula cannot carry. THIS PHASE IS THE GO/NO-GO GATE AND THE SIZING CANARY for the rest -- if it does not close in ONE dispatch, that is a sizing signal to RE-SPLIT, not grounds for a second dispatch on the same target.
2. Lemma 5.1 (PDF pp.9-10) -- re-base BracketFormula.negFix_iff (EANegationFix/NegFix.lean:669).
3. Prop 4.2 (PDF p.6) -- re-base VVecEA2.negFix_iff (EANegationFix/VecEANegFix.lean:164), hence prop42_contentful_of_attained, off the attained pin. LARGEST AND LEAST CERTAIN: negFixList (NegFix.lean:424) is a 681-line recursion whose Case 2/Case 3 gates are built around the ATTAINED pin; admitting the K+ limit case adds a third gate to each. Phase 8 does NOT dispatch until the Lemma 5.3 gate resolves GO.

BINDING CONSTRAINTS CARRIED FORWARD FROM 377:
- THREE-STRIKES PROHIBITION (standing): the model-INDEPENDENT Prop 4.2 backward direction at the BracketFormula level is ruled UNFIXABLE (task 377 report 18 sec 4.3; Boneyard/NegationIndep.lean:346-364). EANegation.lean:1090 and :1249 ARE that target -- DO NOT TOUCH THEM. BracketFormula.negFix_iff (NegFix.lean:669) is INF-ANCHORED and CONFIRMS the ruling; never cite it as license for a fourth bare attempt.
- AMENDED SORRY GATE (user-approved, committed e74f129d1): the ONLY live sorries permitted are KampPrior.lean:520, EANegation.lean:1090, EANegation.lean:1249. Add ZERO. KampPrior:520 is task 358's P17 frozen-interface gap by its own in-code note (:507-518 says "Do NOT discharge here").
- EXTENDED NON-VACUITY RULE: if you land a carrier, STATE WHAT IT EXCLUDES. An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous conclusion does -- that pattern recurred THREE times undetected on this task. The strengthening chain: Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF (landed).
- USER'S PRIMARY CONSTRAINT: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)."
- CITE RABINOVICH BY PDF PAGE ONLY: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf (Read supports PDFs via `pages`). The companion .md is CORRUPT (inverts k!=m at md:199) -- NEVER ground truth. No chunk_00NN-style citations.
- PRESERVE -- DO NOT DELETE FILES. ~29% of NfMultiAnchorBridge is load-bearing via kampArm_*_k0/_k1; frozen byte-identity surfaces sit INSIDE live files (surgical decl excision only, never file deletion). Do NOT delete hasDefinableINF_excludes_kplus, lemma53's Basis, or anything in EANegationFix/.
- LIVENESS: `lake build BoneyardArchive` passes VACUOUSLY (#exit line 5 precedes imports line 7) -- NEVER evidence of health. Kamp/Boneyard/* is covered by NO glob and compiled by NOTHING in CI. ONLY reachability from Theories/Bimodal.lean decides liveness. This is why DedekindINF.lean was landed LIVE rather than parked in Boneyard, and why the deferred targets were recorded as PROSE rather than as sorry-bodied theorems in a dead module.
- SORRY CENSUS MUST BE TACTIC-POSITION, never `grep -c`: use .claude/scripts/lean-sorry-census.sh. Baseline: 5 across Kamp/ -- 3 live (the amended gate), 2 dead in Boneyard (Boneyard/EndpointNegation.lean:160, Boneyard/FOToVEA.lean:118). NOTE: the script's --cross-check reports a structural MISMATCH when the target is a subdirectory (the stripper is scoped to the target; the compiler's `lake build` is always whole-project, and names DECLARATION start lines where the stripper names TACTIC positions). Within Kamp/ the compiler's 3 sorry-using decls (KampPrior.lean:346, EANegation.lean:834, EANegation.lean:1129) correspond exactly to the census's 3 live tactic positions. Not a defect.

BASELINE METRICS (post-377-phase-6): full `lake build` EXIT 0 at 1766 jobs / 239 live modules under Theories/. Every new live module adds exactly +1 to each.

DISPATCH GUIDANCE: --hard --lit. Expect to need its own plan; plan v2 Phases 6-8 are a strong starting point but were written before the carrier and shims landed, so their Phase 6 task list is now largely DONE -- re-scope to Phases 7-8 only.

---

### 377. Transcribe rabinovich faithful nf encoding
- **Effort**: large
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None
- **Research**: [377_transcribe_rabinovich_faithful_nf_encoding/reports/01_faithful-nf-encoding-ruling.md]
- **Plan**: [377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md]

**Description**: RESCOPED after research (report 01, machine-verified). The original charter's central premise -- "the faithful path stalled at Prop 4.2" -- is FALSE and has been retired. Binding user constraint UNCHANGED and now the primary driver: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)." Cite Rabinovich BY PDF PAGE only (~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf); the companion .md is CORRUPT (inverts k!=m at md:199).

VERIFIED FACTS (do not re-litigate):
- Prop 4.2 IS PROVED: neg_2var_vec_ea (Boneyard/KampNegationClosure/NegationClosureProp42.lean:159-169) is sorry-free, axiom-clean {propext, Classical.choice, Quot.sound}, NO sorryAx. Builds EXIT 0 after stripping ONLY the 4-line header and the #exit line. RabinovichNegation.lean (279L) also sorry-free.
- Lemma 3.2(2) PHASE 1 GATE: CLEARED. chain_split proved sorry-free AND axiom-free (not even propext) over a bare LinearOrder, no Dedekind completeness needed. Probe: reports/01_lemma32-anchor-split-probe.lean. Reusable as the Lemma 3.2(2) primitive.
- Sections 3-5 are LARGELY ALREADY TRANSCRIBED, live, sorry-free (~1,902 lines): VecEA2 + BracketFormula (VecEAFormula.lean:128,252) are Notation 5.2 (p.8) EXACTLY (pointTypes alpha + segmentTypes beta + PINNED endpoints); VecEATranslation.lean (translateLeft = Prop 3.5 Until, 566L); NfToVecEA.lean (translateRight = Prop 3.5 Since, 567L).
- Archive 302 was REACHABILITY-based ("no live importers"), never correctness-based. 93-module closure: 74 live, 21 boneyard, 0 ABSENT. Drift is PURELY module-path renames. Only 4 REAL sorries across 8 archived files (naive grep says ~40 -- nearly all docstring PROSE; DO NOT BUDGET FROM GREP COUNTS).

THE ONLY REMAINING GAP (entire scope of this task): the nf_eval_nf -> VecEA2 bridge ABOVE DEPTH 0. NfToVecEA.lean is DEPTH-0 ONLY by its own docstring, terminating at nf_2var_exist_depth0_tl (:503). Both paths stall at the same obstruction under two names: archived nf_exist_formula_nested_backward (NegationClosure.lean:1722, blocker comment names "the Feferman-Vaught composition theorem for linear orders" for non-interval zones 1,2,4,5; interval zone 3 already discharges from Since/Until) and live KampPrior.lean:519 ("goal needs arity 3, IH supplies arity 2"). Two independent derivations, one obstruction.

THE ENCODING RULING (mechanism pinned; the ORIGINAL CHARTER STATED THIS INVERTED): Lemma 3.2(2) is a THEOREM of Rabinovich's Def 3.1 (treewidth 1; proved here axiom-free) and a NON-THEOREM of the repo's nf_eval_nf (hyperedge; machine-proved UNPROVABLE in-repo at Base.lean:1779). NATURAL EXPERIMENT ALREADY RUN IN-REPO: NegationClosureProp42.lean is built on VVecEA2, has ZERO nf_eval_nf hits, PROVED Prop 4.2 axiom-clean; NegationClosure.lean is built on nf_eval_nf, has 42 hits, STALLED. The encoding boundary IS the proved/stalled boundary, zero exceptions. The FV gap is SELF-INFLICTED by a type-first architecture -- Rabinovich never needs FV because Prop 4.3 (p.6) inducts over FORMULAS with processed depth folded into the signature as a unary E[Sigma]-atom (Def 4.1 p.5), making composition STRUCTURAL, not a theorem.

PLAN MUST ENCODE (in this order):
1. SEQUENCE KampPrior.lean:522 FIRST -- mechanically retirable by RESTRUCTURING the declaration (unreachable: recursion resets arity to 1 at :407, live entry is n=1; sorryAx is tracked per-declaration not per-path, which is why DoD needs both :519 and :522). No encoding work, no Prop 4.2. Only DoD item obtainable independently; yields an early green commit and splits an all-or-nothing DoD into two milestones.
2. FORMULA-FIRST Prop 4.3 PROBE before ANY FV investment. This is the single most important item AND the research's LEAST CONFIDENT claim (Medium -- a design judgment, not a machine check). Can the FV requirement be DISSOLVED by inducting over formulas? Apply Prop 4.3 to the depth-k 1-type's Hintikka formula (itself an FO formula) and bridge to nf_eval_nf only at ARITY 1. Its Negation case consumes exactly Lemma 3.2(2) (CLEARED, probe landed) and Prop 4.2 (PROVED) -- both in hand for the first time. WARNING: Kamp/Prop43.lean AND Kamp/Boneyard/Prop43.lean BOTH exist and are BOTH UNBUILT -- Prop 4.3 was attempted twice and orphaned twice; FIND OUT WHY before a third attempt.
3. ADOPT VecEA2/BracketFormula (VecEAFormula.lean:128,252) as the Def 3.1 object -- NOT EAtomDom, NOT IntervalPattern. It is Notation 5.2 exactly INCLUDING pinned endpoints. BracketFormula.toIntervalPattern (:135) bridges if needed. Do NOT adopt NfEFold: its EAtomDom (:69) lacks Def 3.1's beta slot, its defense (:100) is REFUTED (zoneHolds constrains x only against ENV points, cannot express "no point in the open interval (x,t)"), and nf_eval_efold_k (:608) is a MIS-NAMED NON-FOLD that grows arity by its own docstring.
4. UN-ARCHIVE, DO NOT REWRITE: restore NegationClosureProp42.lean (+ NegationClosure5.lean) by stripping the 4-line header and #exit -- VERIFIED to build EXIT 0 axiom-clean with no other edit. Restoring NegationClosure.lean additionally pulls the KampBypassArchive cluster (~13,255 lines / 21 files) -- budget for it.
5. TRY chain_split (reports/01_lemma32-anchor-split-probe.lean) AGAINST NON-INTERVAL ZONES (1,2,4,5) before reaching for the FV literature theorem -- it is itself a composition/gluing theorem at a shared anchor over a bare LinearOrder, structurally the same shape as what the archived path wanted, and axiom-free.

DEFINITION OF DONE (unchanged): KampPrior.lean:519 AND :522 both retired (SAME declaration; sorryAx leaves completeness_discrete's closure only if BOTH go -- confirmed by two proof-term traces); full lake build green; no new axioms (exactly {propext, Classical.choice, Quot.sound}); every new declaration carries a page-cited source correspondence.

GOAL CHAIN: completeness_discrete (Metalogic/BXCanonical/Completeness.lean:276) <- nf_nvar_exist_all_depths <- nf_characterizable_temporal_prior <- kamp_prior_expressive_completeness <- US_expressively_complete_over_prior. LIVE chain needs only arity <=2.

PRESERVE / DO NOT DELETE: DO NOT SPAWN CLEANUP. ~29% of NfMultiAnchorBridge (11 files / 13,737 lines) is LOAD-BEARING via kampArm_*_k0/_k1 (AggregateHookDischarge.lean, AggregateOffDiagK1.lean). Frozen byte-identity surfaces (CarrierKv.lean:240-249; rfl bridges InteriorGateGeneralK.lean:339-351, CarrierKv.lean:294-351) sit INSIDE live files -- any reclamation must be surgical decl excision, never file deletion. Kamp/Boneyard/* is green-on-demand and KampNegationClosure holds a VERIFIED Prop 4.2.

LIVENESS RULE FOR THIS TREE: directory location, absence of #exit, and a green scoped build are ALL unreliable liveness signals -- only reachability from Theories/Bimodal.lean decides what CI protects. `lake build BoneyardArchive` passes VACUOUSLY (#exit at line 5 precedes imports at line 7; Lean parses an empty header and halts) -- NEVER cite it as evidence of health. Kamp/Boneyard/* is covered by NO glob and compiled by NOTHING in CI.

KNOWN TRAPS: (1) endInterval_correct (EndIntervalConsumerK.lean:268) is arity-1 charF machinery, NOT arity-4 charFib -- report 06's dead-leaf list mis-buckets it. (2) ExistsForallNF.lean's VEF.closed_conj/closed_ex/closed_disj are ADVERTISED in the docstring and NEVER DEFINED -- its zero-sorry count reflects unstated theorems, not proved ones. (3) 89 in-code citations in SharedWitness.lean dangle. (4) literature-search.sh throws fts5 syntax errors on period-containing queries.

PRIOR ART: reports/01_faithful-nf-encoding-ruling.md (this task, PRIMARY -- includes H3 21-row page-cited lemma table + H4 adversarial verification with contradiction log). specs/376_arity_general_zone_decomposed_char_engine/reports/ 04-08 (07 = source-fidelity adjudication: arity caps at Def 3.1 p.4 / Def 4.1 p.5; "Dedekind completeness is an ANCHOR FACTORY, not a model filter" p.8 eq 5.2; Rabinovich needs NO rigidity). NOTE: report 08 is SUPERSEDED on the Prop 4.2 stall claim and on the encoding-ruling direction.

---

### 376. Arity general zone decomposed char engine
- **Effort**: large
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [376_arity_general_zone_decomposed_char_engine/reports/01_zone-decomposed-seam-interface.md]
- **Probe**: [376_arity_general_zone_decomposed_char_engine/reports/01_zone-seam-probe.lean]
- **Plan**: [376_arity_general_zone_decomposed_char_engine/plans/01_zone-decomposed-char-engine.md]

**Description**: Build ONE arity-general, zone-decomposed char/provider engine for the M2 de-folded carrier, discharging KampPrior.lean:519 (as its n=1 instance) and KampPrior.lean:522 (n>=2 instances) together by Rabinovich 2014 Lemma 5.3's induction on n (doc_id rabinovich_2014, chunk_0014 lines 7-41; witness extraction per Cor 5.4(1), chunk_0015 lines 23-29 — order content structural, only unary content rides the formula). MACHINE-GROUNDED BASIS: the seam pair hcharFib (ExteriorGateAssembleK.lean:574-578) + hcharFibSoundP (:579-581) is jointly refuted (compiled probe: SeamPairRefutationProbe.lean); hcharFib alone is additionally uninstantiable at shift-homogeneous Prior models (task 374 report 01, Gap A) — so the seams must be RE-SIGNED, not proved. TARGET INTERFACE: anchor-contextual zone-decomposed hcharFibZone (sketch: task 374 report 01 §Q1 'Exact missing statement') — order atoms of nf_eval_nf reconstructed from zoneHolds + carrier-certified anchor 1-types (pattern: step_complete's hz' fold biconditional, InteriorGateGeneralK.lean:1775-1795; endpoint shape: bracketEndChar_kvFib_realize_futT, InteriorGateGeneralK.lean:1565), fiber layer discharged recursively from the arity-general provider engine, which also supplies existF 4 at lower depths (dissolves Gap C, greening kampPrior_existProviders_of_ih beyond depth 0). SCOPE ALSO INCLUDES (size these in the plan): general-m supplies for ledger rows 6/10/11 (Gap D — hexcl has no general-m supply; hexclSlice* exist only as _zero variants) and the general-k arm assembly scaffolding (Gap E — kampArm_*_kv analogs of AggregateHookDischarge/AggregateOffDiagK1). FROZEN (sibling-level, NOT file-level): bracketEndChar_kv body (CarrierKv.lean:240-249); both defeq bridges (InteriorGateGeneralK.lean:339-351; CarrierKv.lean:294-351); the carrier trio definitions (Base.lean / CarrierK1V.lean / CarrierKv.lean); kampPrior_site_rungK_gate_match (KampPrior.lean:941, live consumer EndIntervalConsumerK.lean:248). EDITABLE: the additive *Fib sibling chain — step_sound (InteriorGateGeneralK.lean:2101/2115), step_complete (:1733), bracketEndChar_kvExtFib_correct_prior (ExteriorGateAssembleK.lean:559-660), kampPrior_site_rungKFib_gate_match (KampPrior.lean:1058-1181) — classified freely-editable additive siblings disjoint from frozen defeq surfaces by task 370 report 02 §3. PRESERVE (re-consume, never discard): kampPrior_hreal_supply, kvE_hsliceFut/hslicePast supplies, kvE_hexclDeep* supplies, bracketEndChar_kvFib_realize_futT/_pastX, kampPrior_existProviders_zero, the landed k<=1 arms. Do NOT restate nf_nvar_exist_all_depths to n<=1 (route (b) refuted: ExistProviders.existF is all-arity; P.existF 4 consumed at 38 sites). Do NOT treat :522 as deferrable — Gap C entangles it with :519 at site depths >= 3. DEFINITION OF DONE (inherited from the adjudication task): zero sorries in KampPrior.lean, full lake build green, no new axioms. Expected to need its own multi-phase plan (dispatch with --hard --lit). ADJUDICATION ARTIFACT (Phase 1 final): Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean — sorry-free seamPair_joint_refutation at line 47, with concrete (Int, <) non-vacuity instance seamPair_joint_refutation_int at line 145.

---

### 375. Kamp completeness final assembly axiom audit
- **Effort**: small
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 379
- **Research**: [375_kamp_completeness_final_assembly_axiom_audit/reports/01_rabinovich-fidelity-audit.md]

**Description**: Final assembly and axiom audit for the Kamp expressive-completeness chain, after the k>=2 residual retirement task lands (the Def 4.1 / Prop 4.3 re-architecture; see the adjudication at KampPrior.lean:517-561). Confirm completeness_discrete (Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:276) is fully sorry-free; run lean_verify across the full dependency chain nf_nvar_exist_all_depths -> nf_characterizable_temporal_prior -> kamp_prior_expressive_completeness -> US_expressively_complete_over_prior, confirming the axiom set is exactly {propext, Classical.choice, Quot.sound}; run a fresh sorry/admit scan across Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ excluding Boneyard/; refresh specs/ROADMAP.md's Current state section (dated 2026-07-12, pre-M2) to reflect the landed state. Verification and documentation only — no new proof content. Standard dispatch (no --hard / --lit needed).

ADDED 2026-07-24 (post k>=2 residual retirement): completeness_discrete is NOW sorryAx-free (machine-checked twice). Its axiom set is [propext, Classical.choice, Lean.ofReduceBool, Quot.sound, Lean.trustCompiler] — the extra ofReduceBool/trustCompiler pair enters via a single native_decide in Theories/Bimodal/Syntax/Formula.lean (audit block at BXCanonical/Completeness.lean:344-374 classifies it acceptable). This task expected exactly {propext, Classical.choice, Quot.sound}: either update the expected set to include the two native_decide axioms with rationale, or swap that one native_decide for decide (verify compile-time cost first) to reach the pristine three-axiom set. Adjudicate explicitly; do not silently pass either way.

---

### 374. Retire kampprior 519 522 residual arms
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 370
- **Research**: [374_retire_kampprior_519_522_residual_arms/reports/01_m2-asset-sufficiency-adjudication.md]
- **Plan**: [374_retire_kampprior_519_522_residual_arms/plans/01_gap-b-adjudication-and-branch.md]
- **Summary**: [374_retire_kampprior_519_522_residual_arms/summaries/01_gap-b-adjudication-summary.md]

**Description**: Retire the two remaining KampPrior.lean sorries against the landed M2 de-folded carrier, superseding the abandoned realization-recursion task (358). PRIMARY (:519, the n=1, k>=2 residual arm): discharge the general-k Rabinovich Cor 5.4 F_i-chain converter inside nf_nvar_exist_all_depths using the M2 assets landed by task 370 — kampPrior_hreal_supply (InteriorHrealSupplyK.lean), the *Fib sibling carrier chain (bracketEndChar_kvFib and siblings), and kampPrior_site_rungKFib_gate_match. Phase 1 of the implementation plan MUST be a bounded feasibility adjudication (mirroring task 369's discipline) confirming the M2 assets suffice for the general-k arm BEFORE full proof construction; if refuted, stop and spawn a narrowly-scoped follow-up rather than re-opening the carrier design. SECONDARY (:522, the n>=2 arm, off the critical path — completeness_discrete only invokes n in {0,1}): first adjudicate route (a) prove it as a corollary of the :519 machinery vs route (b) restate nf_nvar_exist_all_depths so its call sites only require n in {0,1}; then execute the chosen route. If :519 consumes the full dispatch budget, land :519 first and /spawn the :522 residue — never leave this task [PARTIAL] indefinitely. GROUNDING: do NOT resume task 358's plan v09 (crux-first-interior-realizer) — it targets the pre-M2 folded-carrier interface. The authoritative diagnosis is specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md and the phase-5-crux-a handoff (directory may later move under specs/archive/). CONSTRAINTS: no refactor of InteriorGateGeneralK.lean or the carrier trio (Base/CarrierK1V/CarrierKv) before both sorries land; respect the frozen bracketEndChar_kv defeq bridge (CarrierKv.lean:246-249, InteriorGateGeneralK.lean:339-351). Definition of done: zero sorries in KampPrior.lean, full lake build green, no new axioms. Dispatch with --hard --lit (Rabinovich 2014, doc_id rabinovich_2014, Lemma 5.3 / Cor 5.4(1)).

---

### 373. Revise kamp theorem formalization tasks
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [373_revise_kamp_theorem_formalization_tasks/reports/01_kamp-task-decomposition.md]
- **Plan**: [373_revise_kamp_theorem_formalization_tasks/plans/01_kamp-task-list-revision.md]
- **Summary**: [373_revise_kamp_theorem_formalization_tasks/summaries/01_kamp-task-list-revision-summary.md]

**Description**: Investigate the most faithful-to-the-literature (Rabinovich, et al.) approach to complete all remaining work on the blocked Kamp theorem formalization (tasks 341, 358, 359), including a full refactor for long-term quality — starting with restructuring files that have grown too large or would benefit from an improved API and easier management. Revise or create the kamp_theorem_formalization tasks needed to complete the work to the highest standards, cutting no corners

---

### 372. Copyright bimodalreference pdf typst
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: None

**Description**: Ensure Theories/Bimodal/BimodalReference.pdf and its source Typst file are appropriately copyrighted

---

### 371. Revise bimodal reference bimodal only
- **Effort**: 4
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: bimodal reference typst — revise to present all and only the bimodal logic (retain Parts I+II, cut III+IV)
- **Dependencies**: None
- **Research**: [371_revise_bimodal_reference_bimodal_only/reports/01_cut-parts-iii-iv-bimodal-only.md]
- **Plan**: [371_revise_bimodal_reference_bimodal_only/plans/01_two-part-bimodal-reference.md]
- **Summary**: [371_revise_bimodal_reference_bimodal_only/summaries/01_two-part-bimodal-reference-summary.md]

**Description**: Completely revise the Bimodal Reference typst document (Theories/Bimodal/typst/BimodalReference.typ) to cleanly and clearly present ALL AND ONLY the bimodal logic. SCOPE DECISION (user-confirmed): RETAIN Part I (The Bimodal System, in full — syntax, semantics, proof theory, frame classes, metalogic, decidability, derived theorems, AND the neighboring temporal-modal logics: Vlach store/recall, the BL-star tower, LTL-to-TM, decidability frontier) AND Part II (Applications — proof automation tactics, dual-signal dataset pipeline, dual-verification worked examples). REMOVE Part III (Counterfactual Logic, chapters/p5-counterfactual.typ) and Part IV (Constitutive Logic, chapters/p5-constitutive.typ) entirely, since these are separate logics built over/beneath the bimodal system rather than the bimodal logic itself. CLEANUP OBLIGATIONS: (1) BimodalReference.typ — drop the Part III/IV part-dividers and their #include lines; rewrite the abstract (currently describes all four parts) and the title-page Sources block to reflect a two-part bimodal-focused document; verify the outline/Contents still renders. (2) chapters/00-introduction.typ — remove counterfactual/constitutive framing and any four-part roadmap. (3) notation/constitutive-notation.typ — remove if only used by the cut chapters; prune any constitutive-only symbols from notation/bimodal-notation.typ. (4) bibliography.bib — drop references cited only by the removed parts (keep shared refs). (5) chapters/p3-vlach-blstar.typ — strip any forward-references to the counterfactual/constitutive parts. (6) Update typst/README.md, SYNC-MAP.md, and sync-check-whitelist.txt to match the new structure. GOAL beyond deletion: improve the overall clarity and cleanliness of the retained presentation so the manual reads as a focused, self-contained bimodal-logic reference (consistent part/chapter framing, coherent cross-references, no dangling links to removed content). VERIFICATION: `typst compile Theories/Bimodal/typst/BimodalReference.typ` must succeed with no unresolved references or broken @-links; the compiled PDF must contain only Parts I and II. Ground all formal claims against the Lean source under Theories/Bimodal/ (the document already treats it as ground truth).

---

### 370. M2 defolded interior carrier redesign
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: task-358 Kamp NfMultiAnchorBridge render-cycle / M2 carrier redesign
- **Dependencies**: Task 369
- **Research**:
  - [370_m2_defolded_interior_carrier_redesign/reports/01_a-vs-b-frozen-boundary-adjudication.md]
  - [370_m2_defolded_interior_carrier_redesign/reports/02_phase7-divergence-audit.md]
- **Plan**: [370_m2_defolded_interior_carrier_redesign/plans/01_defolded-carrier-option-b.md]

**Description**: M2: de-folded interior carrier redesign — carry full arity-4 fiber (execute reports/02 scope). MANDATORY PHASE 0 GATE: Frozen-boundary A-vs-B architectural decision (reports/02 §2.3), MUST run before any carrier code lands: Option A = modify the frozen private carrier bracketEndChar_kv (CarrierKv.lean:246-249), which breaks the byte-for-byte defeq bracketEndChar_kv_succ_eq rfl (InteriorGateGeneralK.lean:339-351) the whole Phase 1-4 tree is locked to (unbounded blast radius); Option B = build a parallel non-folded carrier + re-prove the full correctness chain (igBody_holds_iff :359, step_sound :1043 + fiber delegation :1150-1165, igFoldBit_realize_iff :563 analog) with no defeq break but higher proof volume. SCOPE/DETAIL: Build the de-folded interior carrier (M2) per the authoritative scope in task 369's reports/02_m2-carrier-redesign-scope.md. M1 (kvE_futPos_supply_of_endpoint) is REFUTED (task 369 reports/01, HIGH confidence): the igFoldBit fold (InteriorGateGeneralK.lean:318-332) lossily projects the arity-4 fiber sub : NF sig k 4 down to the arity-1 pair (zone, nfk_projFresh sub), so the endpoint eval cannot rebuild the full arity-4 sigma-realizer the driver kampPrior_futRealizer_of_pos (KampPrior.lean:1662) demands. The paper-faithful fix (Rabinovich Cor 5.4(1), reports/01 finding #13) is to carry the whole ordered fiber and never fold. Re-key igEpL/igEpR/igPtW (InteriorGateGeneralK.lean:209/219/243) and replace/parallel igFoldBit (:318) with a non-projecting fiber-carrying selector, feed the de-folded carrier through igBody (:290) and igMkDisjunct (:276), replace the render-gated bridge igFoldBit_realize_iff (:563) with a de-folded endpoint->arity-4 realizer extraction, re-type the render production (ExteriorGateAssembleK.lean:337-338) and the row-5/6 hreal/hexcl binders (KampPrior.lean:955-1000), re-wire the realizer drivers kampPrior_{fut,past}Realizer_of_pos (KampPrior.lean:1662/1721), then discharge the downstream leaves (kampPrior_hreal_supply InteriorHrealSupplyK.lean:116 strategic sorry; the rows-12-13 general-m arms ExteriorDeepExclSupplyK.lean:105/133) sorry-free. Source of truth: specs/369_m1_endpoint_kvE_futPos_supply_break_render_cycle/reports/02_m2-carrier-redesign-scope.md (M1 refuted per 369 reports/01).

---

### 369. M1 endpoint kvE futPos supply break render cycle
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Plan**: [369_m1_endpoint_kvE_futPos_supply_break_render_cycle/plans/01_m2-scope-and-document.md]
- **Research**:
  - [369_m1_endpoint_kvE_futPos_supply_break_render_cycle/reports/01_m1-endpoint-firing-adjudication.md]
  - [358_realization_recursion_nf_nvar_exist_all_depths/reports/12_spawn-analysis.md]

**Description**: Break task 358's Plan v09 Phase 5 render/realizer/firing cycle (H5 divergence audit verdict C -- missing infrastructure; source of truth: specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md, and the circularity witness at specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-5-crux-a-handoff-20260714.md). MANDATORY PHASE 1 (must run first): bounded feasibility adjudication of M1's core obligation -- upgrading the 1-type Until witness igEpR@t provides (Until(charK chi, top), InteriorGateGeneralK.lean:219) to a full arity-4 sigma-witness using only hAmb (kvE_ambientDeepAnchor, a syntactic EF-closure guard with no M/carrier, ExteriorAmbientDeepAnchorK.lean:131) plus hcons (kvE_fiberConsistent) and the depth-(k+1) saturation of M. This upgrade is UNPROVEN as of the audit (H4 adversarial pass flagged it an unresolved risk) -- adjudicate with a bounded lean_multi_attempt-style check before committing to enrichment wiring. IF PROVABLE: build lemma M1 = kvE_futPos_supply_of_endpoint (+ past mirror kvE_pastPos_supply_of_endpoint using hepL/igEpL/Since) in a new leaf downstream of KampPrior (e.g. Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorEndpointFiringSupplyK.lean, following the InteriorHrealSupplyK.lean precedent of a leaf not added to the NfMultiAnchorBridge aggregator to avoid an import cycle but still built by default lake build). Target signature: theorem kvE_futPos_supply_of_endpoint (P : ExistProviders sig atomMap k) (M : ...) (hepR : (igEpR ... (igFoldBit qnf)).eval_at M atomMap t) (hAmb : kvE_ambientDeepAnchor qnf = true) (sigma : NormalForm sig (k+1) 4) (hmark : qnf.2 sigma = true) (hcons : kvE_fiberConsistent sigma = true) (hfut : kvE_futAdmissible sigma = true) : temporal_truth M atomMap t (kvE_futPos P sigma). This sources the firing from igEpR@t (NOT the render), so kampPrior_futRealizer_of_pos + P.correct then build the sigma-realizer with no cycle. Requires enriching bracketEndChar_kv_step_sound/step_correct binders (ExteriorGateAssembleK.lean:337-338, step_sound delegation InteriorGateGeneralK.lean:1150-1165) with the hepL/hepR endpoint evals they already destruct and currently discard. IF NOT PROVABLE: fall back to M2 -- a de-folded interior carrier (non-igFoldBit variant of igEpR/igPtW) keeping full arity-4 fiber content at the endpoints, a larger InteriorGateGeneralK.lean carrier-redesign refactor; scope and document it explicitly rather than attempting it speculatively. File sites: InteriorGateGeneralK.lean:563 (igFoldBit_realize_iff, render-gated bridge to route around), InteriorGateGeneralK.lean:209/219 (igEpL/igEpR endpoint firing defs), InteriorGateGeneralK.lean:243 (igPtW, lossy AtW-zone-only carrier, root cause F1), InteriorGateGeneralK.lean:1150-1165 (step_sound fiber-layer delegation), ExteriorPinnedConverseK.lean:252 (kvE_futPos_of_realizer, realizer-gated, other cycle edge to avoid), ExteriorGateAssembleK.lean:337-338 (render production site, binder to enrich), KampPrior.lean:964-970 (rows 5-6 hreal/hexcl obligations M1 discharges), PriorInterface.lean:38-46 (ExistProviders.correct, depth-k IH M1 threads). Definition of done: M1 (or a scoped-and-documented M2 plan if the Phase 1 gate refutes M1) lands sorry-free; bracketEndChar_kv_step_sound/step_correct binders enriched with hepL/hepR; lake build green; zero new vacuous defs/axioms beyond the existing floor (propext, sorryAx, Classical.choice, Quot.sound). Task 358 depends on this task: its Plan v09 Phase 5 (kampPrior_hreal_supply) must NOT be re-dispatched against the current interface (provably under-provisioned per the audit) and instead calls this task's M1 lemma by name once landed.

---

### 368. Ambient deepsaturation efclosure guard against cma cmb
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [358_realization_recursion_nf_nvar_exist_all_depths/reports/10_spawn-analysis.md]
- **Plan**: [368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/plans/01_ambient-deep-anchor-guard.md]

**Description**: Land a 367-style, probe-first, ambient-side deep-saturation/EF-closure guard that closes task 358's Phase-4 blocker (nf_nvar_exist_all_depths, KampPrior.lean:519/:522), one layer over task 367's fiber-side guard. Follow the PROVEN template used by tasks 363, 364, and 367 (all completed against this same consumer interface) with zero deviation from house style.

1. PROBE-FIRST (before any kernel/guard change): machine-probe CM-A and CM-B -- the two countermodels recorded in task 358's Phase-4 BLOCKER record (specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/06_deep-anchor-rekey-v06.md, Phase 4 section) -- over the ExteriorPinnedProbe358TailK.lean Z infra (Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/). Cast BOTH as additive, sorry-free probe certificates BEFORE writing any guard definition.
   - CM-A (kills row 13): homogeneous Z model, fake ambient qnf marks every honest 4-type over [v,w,x,t] except sigma := char[t+2,w,x,t] (deep-incomplete marking omitting one bucket-mate). All profile-level checks pass (rows 5/5a/6/10/11 hold) yet sigma is admissible, on-row, bit-false, and guard-false -- row 13 violated.
   - CM-B (kills row 5): Probe358TailK tail-doppelganger re-aimed at the AMBIENT -- same-bucket (AtW, chi_w), depth-0-indistinguishable, spacing-discrepant fake tail; on-row, fiber-consistent, igPtW-invisible, but [w,x,t]-unrealizable -- row 5's conclusion fails.
2. Land a NEW guard in a NEW leaf file (recommended: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean, mirroring ExteriorFiberDeepAnchorK.lean's module shape) implementing the EF-closure predicate on the ambient qnf: (i) inner-fiber-content re-appearance under fresh-rotation (kills CM-A) and (ii) deep-content-to-row anchoring (kills CM-B). The guard MUST carry an m=0-inertness lemma (_zero, ideally rfl, mirroring kvE_deepOnFiber_zero), a readback lemma (_iff, the ONLY sanctioned mate/witness-extraction direction, mirroring kvE_deepOnFiber_iff), and an honest-preservation crux (_of_realized) proven at a GENERAL model (anti-vacuity guarantee, mirroring kvE_deepOnFiber_of_realized).
3. Restate the guarded antecedents in the consumer binders the blocker names: rows 5, 6, 10-13 of EndIntervalConsumerK.lean, their mirrors in ExteriorGateAssembleK.lean and kampPrior_site_rungK_gate_match (KampPrior.lean:964-1030), and the matching gate-formula strengthening so the =>-reconstruction can consume the new guard. Add new m=0-vacuous ledger rows for guard-false residue if the restatement requires it (367 precedent: rows 12-13 were added this way) -- adjudicate during restatement, do not presuppose the row count.
4. Land NEW probe certificates in a NEW probe leaf (recommended: ExteriorAmbientDeepAnchorProbe358K.lean, mirroring ExteriorFiberDeepAnchorProbe367K.lean) certifying CM-A and CM-B are EXCLUDED by the new guard, an honest-preservation certificate (general-model realized ambient passes), and any hereditary re-plant variants an adversarial pass surfaces (mirror 367's depth-2 hereditary doppelganger and copy-plant checks, re-aimed at the ambient side).
5. RE-PROBE AS THE DEFINITION OF DONE: after landing, re-run CM-A/CM-B probes plus the FULL existing certificate inventory (kvE_probe367_* x4, kvE_probe364_* x4, kvE_probe363_* x3, kvE_probe358_* x3) at floor axioms [propext, Classical.choice, Quot.sound], no sorryAx.

ZERO-DEBT TERMINUS (binding, no exceptions): no sorry, no vacuous definition (def X := True family), no proof forced against a live countermodel. If the guard cannot land green against both CM-A and CM-B, return the task as [BLOCKED] with a structured escalation record (failing countermodel named, exact goal state, analytical gap) -- never a landed sorry or a weakened probe.

NEVER UNFOLD THE GUARD DIRECTLY (binding, matches task-358's GLOBAL ROUTING CONSTRAINT): all consumption of the new guard, and of every prior guard it composes with (kvE_deepOnFiber, kvE_fiberElemConsistent/kvE_fiberConsistent, kvE_futAdmissible/kvE_pastAdmissible), MUST route through byte-stable lemmas only (_of_realized, _zero, _iff, _row/analogues). A source scan for rw/unfold/simp only on any of these guard names outside their home modules must show zero occurrences.

PRESERVE BYTE-FOR-BYTE (frozen, do not edit, do not re-derive): ExteriorFiberConsistencyK.lean, ExteriorFiberConsistencyProbeK.lean, ExteriorFiberConsistencyProbe364K.lean (363/364); ExteriorFiberDeepAnchorK.lean, ExteriorFiberDeepAnchorProbe367K.lean (367); the m=0 _zero kernel family (ExteriorPinnedConverseK.lean/PastK.lean); the k<=1 rungs (kampPrior_case1_arm_k0, kampPrior_case1_arm_k1); task 360's m=0 supply; task 358 Phase 3's landing NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean (kvE_hsliceFut_supply/kvE_hslicePast_supply, kvE_deepMate_collapse, kvE_{fut,past}SliceEq_refl -- ambient-realization-guarded, survives ambient-side strengthening, must NOT be re-derived/weakened/discarded); ExteriorNegationK.lean/PastK.lean, ExteriorConverterK.lean/PastK.lean (363/364 guard + converter families); ExteriorPinnedProbe358K.lean, ExteriorPinnedProbeM1K.lean (historical regression records).

SCOPE BOUNDARY (explicit, binding -- this task refines the INTERFACE ONLY, exactly as 367 did): MUST NOT build the G2-B1 (rows 12-13 supply), G2-B2 (uniqueness kernel), or G2-B3 (rows 10-11 supply) theorems themselves -- only the guard/antecedent restatement they will consume. MUST NOT touch kampPrior_hreal_supply/kampPrior_hexcl_supply (Phase 5/6, hsigma production) or the converter-seam discharge. MUST NOT retire the KampPrior.lean:519 or :522 sorries (Phase 7/8 arm rewrites) -- those remain task 358's own responsibility after this task unblocks the interface. Deliverable: a new guard + its API + the restated binders/gate-formula + probe certificates that machine-exclude CM-A/CM-B -- nothing beyond the interface.

After completion: resume task 358 with /revise 358 (re-key Phases 4-8 against the new ambient guard) then /implement 358.

---

### 367. Deepanchor exterior fiber population against taildoppelganger
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [358_realization_recursion_nf_nvar_exist_all_depths/reports/09_spawn-analysis.md]
- **Plan**: [367_deepanchor_exterior_fiber_population_against_taildoppelganger/plans/01_deep-anchor-fiber-guard.md]

**Description**: Design and land a depth-recursive (hereditary) on-fiber/content guard that anchors the exterior fiber population to the ambient one layer deeper than the current depth-0 row check (nfk_dropFresh sigma = qnf.1), replacing that antecedent in the rows-8-9 binders (hsliceFut/hslicePast, Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:154-167). Candidate shapes (from the task-358 implementer handoff, not prescriptive -- select and justify one): (a) a recursive on-fiber guard requiring sigma's marked fibers' one-slot-dropped DEEP forms to be qnf-marked one level down (hereditary fiber anchoring); (b) restate the rows-8-9 antecedents with a deep on-fiber condition replacing nfk_dropFresh sigma = qnf.1 directly, following the ExteriorFiberConsistencyK.lean guard-and-_of_realized-lemma template task 364 landed, one layer down.

METHODOLOGY -- re-probe is the definition of done (per tasks 363/364): before any kernel/guard change, and again after landing it, machine-probe the candidate guard against (1) the NEW countermodel family this task exists to defeat -- kvE_probe358_tailDG_gapItem_pinned_fails and kvE_probe358_tailDG_sigma_in_population in Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean -- the tail-doppelganger must be provably EXCLUDED from the refined population (or provably pinned) after the change; and (2) ALL prior 358/363/364 fakes/probes (frozen reference layer: ExteriorFiberConsistencyProbeK.lean, ExteriorFiberConsistencyProbe364K.lean, and the historical kvE_probe358_eP_atomMate_present record) to confirm the refined guard does not reopen any previously-closed hole. The task is done only when the tail-doppelganger probe is machine-certified excluded (sorry-free, floor axioms [propext, Classical.choice, Quot.sound], zero guard-unfoldings) AND the 363/364 probes remain green.

PRESERVE byte-for-byte: m=0 kernels (_zero suffix family, e.g. kvE_futSliceId_of_end_zero), the k<=1 rungs (kampPrior_case1_arm_k0), task 360's m=0 supply, and ALL of task 363/364's guard/lemmas/probes (ExteriorFiberConsistencyK.lean, ExteriorFiberConsistencyProbeK.lean, ExteriorFiberConsistencyProbe364K.lean) -- zero edits to any of these files. Preserve the never-unfold-the-guard routing rule: discharge only via the byte-stable _of_realized / _admissible lemmas, never by unfolding kvE_fiberElemConsistent directly.

ZERO-DEBT TERMINUS: no sorry, no vacuous definition, no forcing a proof against a live countermodel. If the refined guard cannot be landed sorry-free and green against both probe families, return the task as [BLOCKED] with a structured escalation record rather than papering over the gap.

SCOPE BOUNDARY -- MUST NOT: attempt the general-m G1/G2 supply build-out itself (the four G2 supply theorems, G1 interior supply, or the :519/:522 sorry retirements in KampPrior.lean). That work remains task 358 Phase 2/3 and resumes via /revise 358 once this interface-refinement task lands and the rows-8-9 interface is re-keyed.

REFERENCES: specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-2-v05-handoff-20260714.md (full root-cause analysis and binder-level closure argument); specs/358_realization_recursion_nf_nvar_exist_all_depths/summaries/05_realizer-recursion-v05-summary.md (verification transcript, plan deviations); Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean (the two machine certificates this task must defeat); task 364's landed pattern in ExteriorFiberConsistencyK.lean (guard definition + _of_realized lemmas) as the structural template to follow one layer down; Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:154-167 (the rows-8-9 binders _hsliceFut/_hslicePast to be restated).

---

### 366. Repair or boneyard orphaned metalogic files
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Resolve pre-broken/orphaned Metalogic files excluded from the task-194 Nonempty->Derivable migration. (1) Metalogic/Core/RestrictedMCS/Deferral.lean and Metalogic/Algebraic/AlgebraicCompleteness.lean are broken for reasons unrelated to the migration and are orphaned from the default build target — either repair them or move them to a boneyard. (2) Clean up 3 orphaned aggregator modules noted during the migration. (3) Fix stale `ContextDerivable`/`ContextConsistent` prose in Theories/Bimodal/latex/subfiles/04-Metalogic.tex (those defs were deleted in task 194). Any repaired file must reach green under a scoped `lake build`; zero sorries.

---

### 365. Repair BimodalTest test suite
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: testing
- **Dependencies**: None

**Description**: Repair the BimodalTest test-suite root, which fails at baseline. Tests/BimodalTest/Automation/TacticsTest.lean has ~94 pre-existing errors from stale `DerivationTree [] φ` applications predating the frame-class generalization, and ~17 other files under the BimodalTest root (e.g. DerivationTest.lean) are broken for related reasons. Tasks 187/188/189 routed their new tests into fresh files to avoid this. Goal: bring `lake build BimodalTest` fully green (update stale DerivationTree applications to the frame-class-parameterized form), so the aggregate test target builds again. Zero sorries.

---

### 364. Strengthen fiberelemconsistent mate check against planted unrealizable mates
- **Effort**: 6-10 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 363
- **Research**: [358_realization_recursion_nf_nvar_exist_all_depths/reports/07_spawn-analysis.md]
- **Plan**: [364_strengthen_fiberelemconsistent_mate_check_against_planted_unrealizable_mates/plans/01_strengthen-fiber-mate-check.md]
- **Summary**: [364_strengthen_fiberelemconsistent_mate_check_against_planted_unrealizable_mates/summaries/01_strengthen-fiber-mate-check-summary.md]

**Description**: Task 358's Phase 2 G2 exterior slice supply (plan v04, rows 8-11) is machine-refuted against task 363's landed fiber-consistency interface. The sorry-free certificate kvE_probe358_eP_atomMate_present (Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean) shows kvE_fiberElemConsistent's mate check (ExteriorFiberConsistencyK.lean:52-55) is atom-row-only -- it compares only `mergeNF e.atom_assgn (1,_) = s'.atom_assgn` with no realizability or fresh-projection constraint on the mate s'. This lets a planted mate (mate := (mergeNF e_P.atom_assgn (1,_), fun _ => false)) -- unrealizable, vacuously elem-consistent (.2 constantly false), interior-zoned (fresh coordinate inside the doppelganger-sensitive bracket) -- supply exactly the atom row task 363 proved absent for the s* witness e_P (kvE_probe363_fake_elem_inconsistent), restoring the m=1 doppelganger countermodel one layer deeper and defeating the G2 hsliceFut conclusion.

Strengthen kvE_fiberElemConsistent's mate check (ExteriorFiberConsistencyK.lean:52-55) so it rejects this planted mate while continuing to accept every honestly realized fiber and continuing to reject task 363's original m=1 fake. Two candidate approaches to adjudicate in-task against the existing and new probes (either or a synthesis is acceptable):
(a) Fresh-projection-aware mate content: require the mate s''s fresh projection (nfk_projFresh) -- or its full .2 depth->=1 marking -- to match the inner witness e's corresponding content, not only the depth-0 atom row (.atom_assgn). The plant is projection-VISIBLE (its fresh coordinate sits inside the projection-read bracket), mirroring task 363's own G1 separation (kvE_probe363_qnfG1_antecedent_fails). This is the most promising direction per the phase-2 handoff.
(b) Realizability-anchored mate: require the mate s' to be a genuinely realizable fiber (derivable from some model/environment), directly excluding the plant's .2 = fun _ => false construction as unrealizable-by-fiat.

Follow task 363's re-probe-is-the-definition-of-done methodology (machine probe before/after, frozen reference layer). Definition of done:
1. Restate kvE_fiberElemConsistent's mate check per the chosen approach.
2. Re-run kvE_probe358_eP_atomMate_present (or a re-derived successor) against the new interface and confirm the plant no longer supplies an atom-mate for e_P -- the plant must now be correctly rejected.
3. Re-run all four of task 363's existing GO certificates (ExteriorPinnedProbeM1K.lean: kvE_probeM1_sliceId_NOGO, kvE_probeM1_interiorHreal_NOGO, kvE_probeM1_interiorGuard_identical, and the ExteriorFiberConsistencyProbeK.lean Phase-1 GO certificate) to confirm the strengthened guard still accepts every honestly realized fiber and still rejects the original m=1 doppelganger -- no regression.
4. MUST NOT touch or re-open k=0 layers (rung0/rung1, task 360's m=0 supply theorems, kampPrior_case1_arm_k0) -- unrefuted, must stay frozen.
5. MUST NOT attempt the general-m/general-depth G1/G2 supply build-out itself (kvE_futAdmissible sigma2 = true in full) -- that remains task 358 Phase 2/3, resumed after this task completes. Scope is the interface strengthening plus re-probe only.
6. Zero-debt terminus: no sorry, no vacuous def, no forcing a proof against a live countermodel. If neither candidate approach closes green, return [BLOCKED] with its own structured escalation rather than landing debt.

Reference: full analysis and u-class enumeration argument in specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-2-handoff-20260714.md and reports/07_spawn-analysis.md.

---

### 363. Restate depth1 fibermarking interface and reprobe g1g2
- **Effort**: 6-10 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [358_realization_recursion_nf_nvar_exist_all_depths/reports/05_spawn-analysis.md]

**Description**: The general-depth (m>=1) fiber-marking interface underlying task 358's G1 interior supply (rows 5-6, KampPrior.lean:835-846) and G2 exterior supply (rows 8-11, EndIntervalConsumerK.lean:141-162) is machine-refuted as FALSE by two sorry-free probe theorems in Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean: kvE_probeM1_sliceId_NOGO (exterior, rows 8-11) and kvE_probeM1_interiorHreal_NOGO + kvE_probeM1_interiorGuard_identical (interior, rows 5-6, same root cause one level up). The shared defect (D7): depth->=1 fiber marking is not pinned by free-env/projected rendering. The countermodel constructs a doppelganger-tail fake fiber s* = nf_characteristic 1 5 [22,25,15,2,21], sharing the honest pinned fiber [25,15,2,18]'s depth-0 atom 4-type but diverging in its tail. This fake passes the atom-level admissibility fiber guard, is free-env-realized but has NO pinned realization at any witness, and is projection-invisible through the igFoldBit (zone, nfk_projFresh) arity-1 F1 information-loss channel (InteriorGateGeneralK.lean:318) -- the doppelganger difference lives entirely in slots that projection discards. Both the exterior slice-equality keying (kvE_futSliceEq) and the interior igFoldBit fold-bit guard key their obligation hypothesis side to this same free-env/projected rendering, so the fake is indistinguishable from the honest fiber under BOTH legs' current binder shapes.

Task: restate the fiber-marking interface at the rungK binder / igFoldBit consumer seam (KampPrior.lean:835-846 binder shape as reference; InteriorGateGeneralK.lean:318 igFoldBit projection; ExteriorPinnedConverseK.lean / ExteriorPinnedConversePastK.lean slice kernels) so that depth->=1 fiber marking is pinned rather than free-env/projected. Two candidate approaches to adjudicate in-task against the existing countermodels (either or a synthesis): (a) anchored/pinned item rendering -- carry the depth->=1 fiber's full pinned coordinates through the binder instead of a free-env/projected summary; (b) a depth-graded fiber guard -- strengthen the admissibility/fold-bit guard so it distinguishes fibers by depth-graded content the current projection discards, defeating both m1_sstar fake constructions. Follow the task-360 slice re-key precedent for methodology (machine probe before landing, frozen reference layer). After restatement, re-run the EXISTING probes (kvE_probeM1_sliceId_NOGO, kvE_probeM1_interiorHreal_NOGO, kvE_probeM1_interiorGuard_identical in ExteriorPinnedProbeM1K.lean) against the new interface to confirm the doppelganger countermodel no longer applies to either leg -- this re-probe is the definition of done, not merely a restated signature. MUST NOT touch or re-open the k=0 layers (rung0/rung1, m=0 supply theorems from task 360, kampPrior_case1_arm_k0) -- these are unrefuted and must stay frozen. Zero-debt terminus: no sorry, no vacuous def, no forcing a proof against a live countermodel; if neither candidate approach closes green, the task returns [BLOCKED] with its own structured escalation rather than landing debt. Do NOT attempt the general-m/general-depth supply build-out itself (task 358 Phases 7-8) in this task -- scope is the interface restatement plus re-probe only; the supply theorems remain task 358's responsibility once this interface is fixed.

---

### 362. Main strong completeness finite context all frame classes
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement main_strong_completeness: finite-context strong completeness (Γ : Context = List Formula) for all three frame classes, with weak completeness re-exposed as the Γ=[] corollary. For each X ∈ {Base, Dense, Discrete}: prove strong_completeness_X : semantic_consequence_X Γ φ → Nonempty (DerivationTree FrameClass.X Γ φ), by (a) the semantic deduction lemma reducing Γ ⊨_X φ to ⊨_X (Γ.foldr Formula.imp φ), (b) the existing empty-context weak completeness theorem for X (completeness / completeness_dense / completeness_discrete, BXCanonical/Completeness.lean:135/234/276), and (c) iterated application of the syntactic deduction_theorem (Metalogic/Core/DeductionTheorem.lean) to move the finite premises into the context. Then derive weak_completeness_X as strong_completeness_X at Γ=[]. New file Theories/Bimodal/Metalogic/StrongCompleteness.lean (additive); update the Metalogic.lean tracking table. Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; sorry-free once the three weak termini (358/169/170) are green. This is the capstone the LaTeX names main_strong_completeness (04-Metalogic.tex:266). Depends on research 361 (architecture + per-class semantic_consequence definitions) and the three weak termini: 358 (discrete), 169 (base), 170 (dense).

---

### 361. Strong completeness architecture and weak terminus gap analysis
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: None

**Description**: Research + scoping for finite-context strong completeness (Context = List Formula) across all three frame classes (Base, Dense, Discrete). Deliverables: (1) Confirm the strong-completeness corollary architecture — per-class semantic_consequence_X (paralleling valid/valid_discrete in Semantics/Validity.lean; the current `⊨`/semantic_consequence quantifies over ALL ordered abelian groups D, so a Discrete/Dense restriction must be defined), the semantic deduction lemma (Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ), and iterated use of the existing syntactic deduction_theorem (Metalogic/Core/DeductionTheorem.lean) to derive Γ ⊢ φ from []⊢(Γ→φ). (2) Authoritative gap analysis of what still gates each WEAK terminus: Discrete = task 358 (KampPrior.lean:361/364) + supply (task 350/309); Base = the open sorries in `completeness` (BXCanonical/Completeness.lean:135 — dense arm countermodel_dense, deprecated countermodel_discrete Transfer.lean:1270 "unfixable Z+Z", dd_countermodel_chronicle_mixed_sorry); Dense = the chronicle dense-path sorries inherited by `completeness_dense` (:234) (ChronicleToCountermodel.lean, MCSMixedCase). For each, determine whether the current live architecture reaches green or needs rerouting, and produce a concrete sub-task decomposition + dependency graph for tasks 169 (base weak) and 170 (dense weak), spawning refinements as needed. (3) Confirm the LaTeX-documented main_strong_completeness (04-Metalogic.tex:266) finite-context shape and that weak completeness is exactly the Γ=[] instance. Reference: 04-Metalogic.tex §Completeness-as-Corollary; report 13 (discrete-completeness roadmap). Analysis/read task — no proof obligations to close here.

---

### 359. Boneyard archive hygiene no live imports
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 379

**Description**: Boneyard ARCHIVE hygiene (NOT deletion — the Boneyard is a permanent archive of retired/superseded proof infrastructure under Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/). Three-part aim: (1) NO LIVE IMPORTS INVARIANT — nothing outside Boneyard/ may import from Boneyard/. Roadmap report 13 flags ~3 remaining live imports into Boneyard (via Prop43 and NavigatedEndChar; verify the exact set at implementation time with a fresh grep for non-Boneyard files importing any Kamp.Boneyard.* module). For each live import, PROMOTE the still-needed declaration OUT of Boneyard into a live module (do NOT delete it), until no non-Boneyard file imports Boneyard/. (2) ARCHIVE UNNEEDED CODE INTO the Boneyard — move dead/superseded declarations from live modules into Boneyard/ rather than leaving them inline (e.g. the dead endIntervalStep placeholder at CarrierK1V.lean:2144 superseded by task 357's EndIntervalConsumerK; and any other retired-but-inline code surfaced during the green cleanup pass). (3) TIDY the Boneyard itself — organize/normalize the archive (consistent module headers marking archival status, no build-participation surprises) WITHOUT deleting its contents. The Boneyard is never emptied or removed. GATING: the archive-what-is-unneeded pass (2) is clearest post-green (you only know what is unneeded once completeness_discrete is sorry-free/axiom-clean — hence dependency on task 303, tail of the assembly chain); the sever-live-imports invariant (1) may be pulled earlier if convenient. Definition of done: no non-Boneyard file imports Boneyard/; identified dead inline code archived into Boneyard/; Boneyard tidied; full-tree lake build GREEN; axioms on completeness_discrete unchanged. Zero-debt: promote-not-delete for anything still live.

ADDED 2026-07-24 (post k>=2 residual retirement): also retire the two ORPHANED sorried theorems in Theories/Bimodal/Metalogic/WeakCanonical/EANegation.lean — neg_bracket_is_vbracket (decl at :834, sorry at :1090) and neg_partialBracketExist_is_vbracket (decl at :1129, sorry at :1249). Machine-verified: zero consumers across Theories/ (definition sites only); unprovable as stated (B.1 backward case is a genuine existential-vs-universal mismatch, report 18 sec 4, two independent analyses); superseded on the live path by sorry-free VVecEA2.negFix_iff (VecEANegFix.lean). Delete or Boneyard per this task conventions; keep the impossibility note (EANegation.lean:1047-1089) with the Boneyarded code so the refutation is not lost.

---

### 358. Realization recursion nf nvar exist all depths
- **Effort**: high
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 349, Task 357, Task 360, Task 363, Task 364, Task 367, Task 368, Task 369, Task 370
- **Research**: [358_realization_recursion_nf_nvar_exist_all_depths/reports/04_post-360-gap-map-and-route.md]
- **Plan**: [358_realization_recursion_nf_nvar_exist_all_depths/plans/11_deep-anchor-rekey-v07.md]

**Description**: Realization recursion: land the nf_nvar_exist_all_depths n>=1 arms (Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:361 for the |1=> arm and :364 for the |n+2=> arm, currently strategic sorries) to produce the genuine interior/exterior realizer hσ (Rabinovich 2014 Cor 5.4 inf/sup within-bracket bounded witness selection). This is the task-309 Phase-14 successor. Retiring these two sorries is what enables ACTUALLY DISCHARGING (rather than carrying) the eleven obligations threaded outward by task 357: the interior hreal/hexcl and the four task-356 exterior hbr* obligations. The discharge site for the exterior hbr* is kvE_{fut,past}Bundle_of_realizer (ExteriorConverterK.lean:208 / ExteriorConverterPastK.lean:177), which is a CONVERTER only: given a genuine realizer hσ : nf_eval_nf M (m+1) 4 [x1,w,x,t] σ it yields the hbr* conjuncts. The missing piece is PRODUCING hσ — the un-landed realization mathematics. Consumers ready and waiting (all green, obligation-carrying): task 357 endInterval_step_correct / EndIntervalCorrectPrior (EndIntervalConsumerK.lean) and kampPrior_site_rungK_gate_match (KampPrior.lean, general-k supply-site seam). Definition of done: nf_nvar_exist_all_depths sorry-free at all depths (:361/:364 retired); provider instantiation discharges hreal/hexcl/hbr* at the KampPrior recursion site; task 349 Phase 5 closes with FULL discharge (not merely carrying). Zero-debt: if a sub-piece cannot close green, mark [BLOCKED] and escalate rather than landing a sorry or vacuous def.

---

### 350. Build aggregate quantendseg construction and discharge armcorrectness hooks at k0 and k1
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 349
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md]
  - [350_build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1/reports/02_offdiag-k1-primitives.md]
- **Summary**: [350_build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1/summaries/01_aggregate-quantend-hook-discharge-summary.md]
- **Plan**:
  - [350_build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1/plans/02_offdiag-k1-aggregate-discharge.md]
  - [350_build_aggregate_quantendseg_construction_and_discharge_armcorrectness_hooks_at_k0_and_k1/plans/03_negfix-refactor-exterior-carriers.md]

**Description**: Build the aggregate forall-qnf quantEnd/seg construction -- a single TemporalPred/BracketFormula 0 encoding the population match `forall qnf : NormalForm sig k 3, ((exists w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) <-> sub_nf.2 qnf)` via 5-zone order-pattern routing (the existing `seg endChar qnf` at Base.lean:1127 is per-qnf, not an all-order-patterns aggregate; same house style as the landed zone-triage lemmas, e.g. nf_zone_exists_trichotomy_k1) -- and use it plus the recursive endChar_correct (consumed by name from the prerequisite task) to discharge the three arm-correctness lemma hooks as separate green lemmas at depth k=0 and k=1: h_quant past (nf_char2_past_formula_correct, Base.lean:1230, hook at 1238-1241), h_quant future (nf_char2_future_formula_correct, Base.lean:1430, hook at 1438-1441), and h_past/h_fut/h_diag (A_diag_correct, Base.lean:758, hooks at 765-773). Consume, do NOT rebuild: endChar_correct (from the prerequisite task), seg_holds_coupled (Base.lean:1150), nf_zone_flatten_navigable_correct (NfZoneFlattenNavigable.lean:709). Guards (binding, same set as the prerequisite task): G1-G5; FORBIDDEN nf_char3_deeper_split; do NOT edit the seven frozen provider files (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean, ExteriorNegationPast.lean); do NOT edit KampPrior.lean:352-364 (the :361/:364 sorry region and its transfer note stay task 309's own Phase 19 edit -- this task lands consumable lemmas only, in Base.lean or an additive 309-owned wiring file, never the sorry lines themselves); axioms exactly [propext, Classical.choice, Quot.sound]; sorry-free. Definition of done: lake build GREEN; all new lemmas sorry-free; lean_verify on each named hook-discharge lemma = exactly [propext, Classical.choice, Quot.sound]; no frozen-file edits; no edit inside the KampPrior.lean recursion body; task 309's Phase 18b/19 can cite the k=0/k=1 hook-discharge lemmas by name to instantiate the landed Phase-18a skeleton kampPrior_case1_trichotomy_assemble (KampPrior.lean:1056) and narrow :361. Literature grounding: orchestrator handoff blocker P18b-endChar-recursive-core-unbuilt (crux and resolution fields, second successor); report 02 Section 6 'Phase 9' decomposition (reports/02_endpoint-hook-discharge-research.md:272-279), adapted -- the :361 rewire itself stays task 309's own Phase 19, only the hook discharge is this task's deliverable.

---

### 343. Abort aware tableau cancellation
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [343_abort_aware_tableau_cancellation/reports/01_abort-aware-tableau.md]
- **Plan**: [343_abort_aware_tableau_cancellation/plans/01_abort-aware-tableau-plan.md]
- **Summary**: [343_abort_aware_tableau_cancellation/summaries/01_abort-aware-tableau-summary.md]

**Description**: Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

---

### 341. Structural refactor sharedwitness carrier layer
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 335, Task 337, Task 340, Task 346
- **Research**: [341_structural_refactor_sharedwitness_carrier_layer/reports/01_sharedwitness-declaration-survey.md]
- **Plan**: [341_structural_refactor_sharedwitness_carrier_layer/plans/02_module-split-refresh.md]

**Description**: Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier layer, now that it has grown to a large, intricate state. MEASURED CURRENT SIZE (2026-07-09, wc -l): SharedWitness.lean is ~9248 lines (NOT ~3540 as previously stated — 2.6x larger); SubBracket2V.lean ~2160; CarrierK1V.lean ~2097; the enclosing directory Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ totals ~18,100 lines across 11 files (Base 1478, CarrierK1V 2097, CarrierKv 482, NavigatedSpine 451, OuterGate 203, PriorInterface 105, RefutationF2 963, SharedWitness 9248, SubBracket 266, SubBracket2 647, SubBracket2V 2160). Any module-split proposal MUST be sized against the true ~9248-line SharedWitness, not the stale 3540 figure. CURRENT CARRIER STRUCTURE (post-task-334, post-task-342 — describe the split against THIS, not the old text): task 334 [COMPLETED] switched the carrier to kvE2_sepArr' (41 occ; decls kvE2_sepArr'_mem_modelOrder at 1888, kvE2_sepArr'_sound at 6918) plus kvE2_sepDisjValidOwner (def at 1733, 12 occ), DELETING kvE2_sepArrL / kvE2_sepArrR / kvE2_sepValid and the entire kvE2_sepSingleton block — all four now have 0 declarations; their surviving mentions are prose/comment only (kvE2_sepArrL 9, kvE2_sepArrR 2, kvE2_sepValid 17, kvE2_sepSingleton 0). Task 342 [COMPLETED] added the interior-restricted owner index kvE2_sepPosI (noncomputable def at line 211; now ~229 occurrences) plus tie-admitting weak orders, and deleted the global hLR hypothesis-carrying construction: hLR now survives ONLY as a local binder inside the certificate theorem kvE2_sepHonest_hLR_absurd (SharedWitness:5710), which proves the former hLR was inconsistent with every honest evaluation — there is no global hLR declaration. Name the split against the REAL current symbols — kvE2_sepArr', kvE2_sepDisjValidOwner, kvE2_sepPosI, kvE2_sepBody (def at 2328, 52 occ), kvE2_sepBody_extract (thm at 6328), kvE2_sepHonest_hLR_absurd — and NEVER against the deleted kvE2_sepArrL/R/Valid/Singleton/hLR. LITERATURE-CITATION HAZARD (record explicitly and respect): SharedWitness.lean carries 89 dangling md:NN citations in comments (md:77 x27, md:168 x24, md:154 x9, md:72 x8, md:61 x6, md:91 x3, md:218 x3, md:170 x3, and singletons md:78/74/66/207/137/100). These point into a Rabinovich markdown that was a hand-written paraphrase, replaced 2026-07-09 by a PDF text-extract that drops every displayed equation and inverts k!=m into k=m; the md:NN line references are therefore meaningless. By a deliberate user decision these are left UNFIXED for now — but this refactor, which will move those comments between modules, MUST NOT silently propagate them as if valid. This is a natural opportunity to re-cite to Rabinovich PDF page numbers if the refactor touches those comments (the codebase already uses this style, e.g. 'Rabinovich §5, p.7' at SharedWitness:6132). RULE: cite Rabinovich by PDF page only, never md:NN. GOALS (original intent preserved): (1) SPLIT the oversized SharedWitness.lean into cohesive modules along natural seams (e.g. slot/carrier types & enumeration; per-slot global-index + kvE2_ordRank kernel and the interior owner index kvE2_sepPosI; honest-order + membership/monotonicity; coincidence-fold/discharge; body/holds_iff/extract assembly via kvE2_sepBody / kvE2_sepBody_extract), preserving the public API and all import sites. (2) IMPROVE the API: consistent naming, clearer signatures, section structure, and comprehensive docstrings/comments explaining the value-faithful per-individual-slot design and its Rabinovich Def 3.1 grounding (cite PDF pages, and reports 05-09), correcting or dropping dangling md:NN comments wherever they are encountered. (3) ARCHIVE genuinely dead/superseded code to Theories/Bimodal/Boneyard/ (residual 339 region-primary machinery; obsolete owner-block tuple remnants after the task-340 v3 per-slot refinement; comment blocks referencing the deleted kvE2_sepArrL/R/Valid/Singleton/hLR constructions), WHILE preserving anything still uncertain or potentially load-bearing in place with clear NOTE:/QUESTION: comments rather than deleting it. (4) Keep the full lake build green and axiom-clean {propext, Classical.choice, Quot.sound} throughout; no sorries introduced; preserve F1-F7 faithfulness invariants and the LITMUS (NavigatedSpine:437, UNVERIFIED exact line). This is a code-health/maintainability pass, NOT a semantic change — behavior and proved theorems must be preserved exactly. SEQUENCING (hard constraint): MUST run AFTER the active carrier chain completes — dependencies 340 (per-slot refinement), 337 (holds builder), 335 (outer gate) — AND must NOT run concurrently with the H7 territory contract that currently assigns SharedWitness.lean to task 333 and OuterGate.lean to task 335; both 333 and 335 must land before this structural refactor is safe, to avoid churning files under active edit. Strongly recommend a survey/plan phase that maps the current declaration graph against the true ~9248-line structure and proposes the module split before moving any code. This is a description correction, not a re-scoping: overall scope and goals are unchanged. SEQUENCING ADDENDUM (2026-07-11, session sess_1783723095_edd5a7): task 346 (successor carrier redefinition, spawned from 335) added as an explicit dependency — it reworks NfMultiAnchorBridge carrier internals, so the code-move GATE must verify BOTH 335 COMPLETED AND 346 COMPLETED (or 346 abandoned by user decision) before moving code. Note for the GATE re-diff: tasks 344/345 grew SharedWitness.lean from 10,037 to ~12,600 lines (TASK 344/345 banner sections — pin-anchored fragment fold + symmetric gate); the five-seam cut lines and the md:NN inventory in plan 01 are stale and must be refreshed at the GATE as the plan already provides.

SIZING CORRECTION 2026-07-24 (metalogic cleanup review): SharedWitness.lean has grown again to 12,800 lines (this charter previously said ~12,600). Re-measure before planning; the growth trend itself strengthens the case for the shared-witness carrier-layer extraction.

---

### 321. Implement corrected k2 carrier and close the correctness gate f4 resolution
- **Effort**: 10-16 hours
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 320, Task 326, Task 330, Task 331, Task 335, Task 336
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md]
  - [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/06_faithful-separate-bracket-architecture.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/07_v7-consolidated-faithful-route.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/10_supersession-decision.md]
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/04_corrected-k2-carrier-gate-v4.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/05_corrected-k2-carrier-gate-v5.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/06_corrected-k2-carrier-gate-v6-redesign.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md]

**Description**: REDESIGN (v6, plan 06). Task 330's PDF-verified faithfulness audit (specs/330_.../reports/01_faithfulness-audit-fold-representation.md — the PRIMARY BASIS) determined the entire v1-v5 route rested on a MIS-CITATION: the "constant-arity E[Sigma]-fold (Def 4.1)" does not exist in Rabinovich 2014. Def 4.1 (p.5) is the E[Sigma] ALPHABET EXPANSION (TL-formulas-as-atoms), NOT a fold. The real fold is Prop 3.5 / Cor 5.4: NAVIGATED (nested Until/Since) over FLAT exists-forall blocks with QUANTIFIER-FREE point types (Lemma 5.1, p.7); higher FO depth is discharged by STRUCTURAL INDUCTION (Prop 4.3, p.6), never by nesting a depth-k characteristic. The static arity-1 E-atom (EAtomDom = ZoneSpec n x NormalForm sig k 1, NfEFold:69) is a CATEGORY ERROR at k>=1 — the recurring wall (G6 :1609-1641, F4 :5689-5765, k=2 NO-GO 327 :8760-8825) is ONE obstruction: an arity-1 monadic channel cannot carry an inner witness's joint coupling to multiple anchors (goal needs ZoneSpec 4, channel supplies ZoneSpec 1).\n\nv6 DROPS every phase depending on the refuted infrastructure (nfk_assemble/nfk_dropFresh/nfk_zoneSpec, nf_eval_nf1_cons_factor, efold_of_nfk, the constant-arity fold engine nf_quant_layer_fold_k2_gate). It CONSUMES the landed assets the audit identified: BracketCarrierCorrectV (NfMultiAnchorBridge:1881, the witness-growing carrier), neg_2var_vec_ea (EANegationClosure:722, the LANDED Prop 4.2 negation closure — the hardest piece), and the task-326 interior closers (kvE_subBracket2V_sound_of_outer/_complete). It ADDS the missing ingredient: the Prop 4.3 re-flatten structural-induction wiring. It FOLDS IN the redefined scope of the now-ABANDONED prerequisite tasks (NOT re-spawned): former 328 -> the navigated witness-growing fold (Prop 4.3 re-flatten induction over flat exists-forall blocks); former 329 -> the per-arrangement VVecEA2 non-interior dischargers (soundness + completeness) for the 5 non-interior zones (zPastX/zAtX/zAtW/zAtT/zFutT). v5 Phase 15 (F4 Z adversarial gate + verdict record) is preserved as the downstream consumer (now Phase 8).\n\nBINDING INVARIANT (the ONE thing v6 changes after 5 non-converging versions): reconstruction is NAVIGATED / witness-growing, NEVER a static arity-1 characteristic — inter-anchor coupling rides the EVALUATION POINT / structural position of nested Until/Since (Prop 3.5 / Cor 5.4). LITMUS: no x1 < e_i relative-position literal on any live path. CONSTRAINTS (preserved from v5): purely additive; DO-NOT-EDIT (byte-identical) task-325/326 landed lemmas, kvE2_body/bracketEndChar_kvE2 splice, kvE_subChain2V, BracketCarrierCorrectVPrior, EANegation, F1-F4 records; no provider-side pinning (Amendment F3); anchor cap 2; G5 citations at every chain step; axiom-clean [propext, Classical.choice, Quot.sound]; no sorry on any live path. RE-SCOPE fallback (audit-sanctioned) only if the navigated fold + induction wiring exceeds budget: narrow to the interior + boundary fragment via task 326 + epL/epR/ptW, deferring exterior-navigated completeness. GOAL STATE: v6 GO gate unblocks task 309 Phase 13.4 (general-k one-step correctness) + Phase 14 (hook rewire discharging KampPrior.lean:351's strategic sorry). LITERATURE GROUNDING: /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Def 3.1/4.1, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Lemma 5.3, Cor 5.4). SCOPE AMENDMENT (2026-07-07, plan v7 Phase 10 decision gate): O4 (carrier-side per-sigma hgate derivation) FAILED its one dedicated dispatch — forward-zone conjunct underdetermined at cross-sigma slot points (inert O4 CRUX RECORD, SharedWitness.lean). Verdict N2: task re-scoped to the single-positive-sub fragment (Appendix N2 promoted into Phases 11-12). The GO/NO-GO deliverable for task 309 Phase 13.4 + KampPrior.lean:351 is now fragment-scoped; the multi-positive case (bit-compatibility filtering of kvE2_sepArrL/R, a carrier re-definition) is deferred to a successor task.

---

### 318. Slot lk results into bimodalreference decidability
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319

**Description**: GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymous TACAS 2027 double-blind submission at ~/Philosophy/Papers/PossibleWorlds/Lk/) is accepted and the embargo (user decision 2 on task 313) lifts. Insert the Lk-specific content into chapters/p3-decidability-frontier.typ at the prepared // SLOT-IN: anchors, without renumbering chapters or sections: the BL-star ladder table (Lk 07-related-work.tex 32-104, tab:bl-star-ladder), the complexity map (L1 = PTL x S5 EXPSPACE-complete; L_k undecidable for k >= 2; alternation-freedom does not restore decidability, Theorem F-B; forall-AF-L_k PSPACE-complete flagship, Theorem F-A), and the hardware case study (constant-time as forall-forall, reset convergence, SVA/Logos-Hardware bridge, Lk 06-case-study.tex). Add the Lk bibliography entry with its final published citation. State openly, in plain prose, which results are established in print and which are new; note that none are Lean-formalized (Lk 08-conclusion.tex names Lean 4 formalization as future work). Include the honest trace-vs-task-semantics bridging caveats (Lk is discrete/future-only trace sets; TM is group-time/two-sided task frames). Sources: teammate A rows 15-18.

---

### 309. Offdiag two anchor fi chain
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 310, Task 311, Task 320, Task 333, Task 335, Task 346, Task 348, Task 349, Task 350
- **Plan**:
  - [309_offdiag_two_anchor_fi_chain/plans/05_offdiag-fi-chain-plan.md]
  - [309_offdiag_two_anchor_fi_chain/plans/08_offdiag-fi-chain-v8.md]
  - [309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md]
  - [309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md]
- **Research**: [309_offdiag_two_anchor_fi_chain/reports/07_unblock-assessment-post-333.md]

**Description**: Build the off-diagonal two-anchor navigated characteristic (Rabinovich Cor 5.4 non-trivial-segment F_i chain) for the KampPrior.lean:350 past/future arms (prerequisite spawned from task 307 Phase 7 blocker audit, reports/03_endpoint-hook-blocker-audit.md).

Off the live import path, sorry-free, axioms exactly [propext, Classical.choice, Quot.sound]. Deliverables (see task 307 report 03 SS4): (1) segment-carrying A_past/A_future + _correct in Kamp/NfZoneFlattenNavigable.lean (drop the forced `trivial top`; via bracketBuildLeft/Right_correct directly, ~80-120 lines); (2) nf_char2_past_formula / nf_char2_future_formula : NormalForm sig (k+1) 2 -> Formula with `temporal_truth M atomMap t (nf_char2_past_formula ... sub_nf) <-> exists x, x < t AND nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` (future dual with t < x) — the F_i chain: outer NON-trivial-segment bracket from t to x, endpoint at x = the arity-2 characteristic of sub_nf at [x,t], quant layer (per qnf : NormalForm sig k 3) flattened via nf_zone_flatten_navigable_brick, residual arity-3 zones discharged by the depth-k IH (exist_tl_fn_k / nf_nvar_exist_all_depths); ~300-500 lines, recursion on k — the load-bearing new object; (3) rewire KampPrior.lean:350 to A := nf_char2_past_formula ... OR A_diag ... OR nf_char2_future_formula ..., proven via nf_zone_exists_trichotomy_k1 disjunction-elim + the three _correct lemmas, replacing the :350 sorry (live-path sorries 2 -> 1, :353 remains downstream per task 305 scope).

CONSUME, DO NOT REBUILD (all sorry-free): all of task 308 (NfMultiAnchorBridge: nf_char2_formula deliverable 1, nf_zone_flatten_navigable(_brick) deliverable 2, nf_char2_zone_split5, nf_char2_atom_part(_correct), nf_quant_clause_tl); A_diag/_correct + the trichotomy nf_zone_exists_trichotomy_k1 (task 307 Phases 2-3); depth-0 bases diagDup/diagDup_eval_zero/renameNF_eval_diag0; bracketBuildLeft/Right(_correct) (Kamp/VecEATranslation.lean); the navigated pillars as the diagonal-only degenerate case. The import-cycle relocation is ALREADY LANDED (commit 69998c02d) — NfMultiAnchorBridge no longer imports KampPrior.

FORBIDDEN ROUTES (obstruction guards G1-G5, task 307 report 03 SS4): G1 no arity-1 collapse of the off-diagonal (refuted, report 02 SS1; NfDepth0Generalized:1691-1719). G2 no projection-based VecEA2 / third-free-anchor tower (refuted, specs/305 report 40; R2). G3 no trivial-top segment on the off-diagonal arms (report 03 SS1.2/SS2.3: a closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment). G4 w stays a bracket witness (env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap). G5 follow Cor 5.4 F_i chains step-by-step (F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)); no simp/omega/aesop shortcut of a chain step (literature-fidelity policy).

LITERATURE GROUNDING: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Lemma 5.1 md:134-152, Corollary 5.4 md:154-157).

GOAL STATE: lake build GREEN (full), top-level axioms unchanged (propext/Classical.choice/Quot.sound, 0 domain axioms), live-path sorries reduced 2 -> 1 (KampPrior.lean:350 closed, :353 remains), task 307 unblocked to finish Phase 7 wiring verification + Phase 8 wrap-up. Estimated ~400-700 lines total; run --hard --lit. v8 re-point (task-347 adjudication, verdict (b)): the KampPrior.lean:351 discharge consumes an interior+boundary gate PLUS a separate adjacent-exterior bracket with the interior/exterior seam at the anchors x,t (Rabinovich Prop 4.3 + Lemma 7.6 re-flatten) — NOT a single all-arrangement (x,t) gate (that target was an outer-existential globalization artifact with no §5 counterpart; F3/F4 refuted it). The adjacent-exterior bracket and the final KampPrior.lean:351 close are the task-348 prop43_exterior_reflatten deliverable; task 309 depends on 348. Phases 13.4/14 are GATED on task 348's definition-of-done (exterior-marked hexclExt residue discharged by the adjacent-exterior bracket; KampPrior.lean:351 strategic sorry retired). Plan: v8 (08_offdiag-fi-chain-v8.md).

v9 realignment (2026-07-11, providers landed): tasks 335 and 348 COMPLETE — the k=2 interior+boundary fragment gate (bracketEndChar_kvE2_correct_two_prior_frag, OuterGate.lean:359, commit 147af2fbe) and the enriched composed gate bracketEndChar_kvE2Ext_correct_two_prior_frag (ExteriorBracket.lean, hexclExt discharged INTERNALLY) are landed, axiom-clean. Per task 348's R1 scope decision the KampPrior.lean:351 strategic-sorry retirement (now at :361, the | 1 => arm of nf_nvar_exist_all_depths) transferred BACK to task 309 — retirement = consume 348's discharge theorem + discharge the 309-owned provider inventory (hfrag/hrealI/hrealB/hexcl + six order bits). The ∀k-lift composition flag (335 handoff §5) is RESOLVED: option (a) — fragment-scoped k=2 induction step, nf_nvar_exist_all_depths interface unchanged, non-fragment residue routed to the 321-N2 successor. v8 Phases 13.4/14 are RETIRED (superseded by the landed provider chain); open work is Phases 15-19 (site/coverage probe → provider shim → hrealI/hrealB/hexcl discharge → kvE2Ext gate consumption + hooks + depth-2 assembly → ∀k lift + :361 retirement). Plan: v9 (09_offdiag-fi-chain-v9.md).

---

### 307. Kamp cor54 bound anchor zone converter
- **Effort**: 6-10 hours
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 308, Task 309
- **Handoff**: [305_rabinovich_ea_formula_implementation/.orchestrator-handoff.json]
- **Summary**: [305_rabinovich_ea_formula_implementation/summaries/40_phase16-gate-no-go-summary.md]
- **Plan**:
  - [305_rabinovich_ea_formula_implementation/plans/40_prop43-negation-closure-route.md]
  - [307_kamp_cor54_bound_anchor_zone_converter/plans/01_bound-anchor-converter.md]
- **Research**:
  - [305_rabinovich_ea_formula_implementation/reports/40_phase11b-divergence-audit.md]
  - [307_kamp_cor54_bound_anchor_zone_converter/reports/01_bound-anchor-verdict.md]

**Description**: Kamp Cor 5.4 depth-k zone converter: resolve the multi-anchor single-point coupling when the second anchor is EXISTENTIALLY BOUND (residual spawned from task 305's Phase 16 GO/NO-GO gate, plan v40).

PRECISE MATHEMATICAL QUESTION: The live-path obligation KampPrior.lean:391 has the shape `temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` — the second anchor x is EXISTENTIALLY BOUND and navigated-to (not free). Determine whether there EXISTS a model-independent (uniform) Formula A, built from bracketBuildLeft/bracketBuildRight navigation (Until/Since chains) over the depth-k IH formula as the navigable endpoint TemporalPred type, such that the iff holds for every Prior model M satisfying h_UZ/h_SZ — i.e. CONSTRUCT the depth-k zone converter for the bound-anchor case — OR establish the definitive obstruction proving no such uniform navigable A exists (mirroring the free-anchor refutation already proven for the exterior/free case). The task must reach one of these two decisive outcomes; it may not defer or reframe.

THREE PROVEN OBSTRUCTIONS ANY APPROACH MUST RESPECT (all sorry-free counterexample machinery — do not re-attempt any of these three routes):
1. Projection VecEA2 non-injectivity: the coupled quant layer for the depth-(k+1) x=t diagonal case does NOT factor through per-variable projections; `liftIdx(totalUnskip)` is non-injective. Proven in Kamp/NfZoneDepthK.lean (Phase 10, `renameNF_eval_diag0` context) — do not re-attempt a projection-based VecEA2 bridge for x=t.
2. D1 flat-bracket interior-confinement: a `BracketFormula.holds M atomMap x t bf` with depth-0 atomic types is confined to the closed interval [x,t] and cannot capture exterior-w realizability (zones w<x, t<w). Proven sorry-free by `interior_bracket_cannot_realize_exterior_sub_k1` in Kamp/NfZoneDepthK1Probe.lean — do not re-attempt a flat single-interval atomic bracket absorption.
3. Phase-16 free-anchor identification obstruction: for a FREE anchor x, no x-independent formula A can satisfy the future-zone gate iff `temporal_truth M atomMap t A <-> exists y, t<y AND nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` in any non-degenerate model, because the RHS pins x's local monadic type (`future_zone_pins_x_pred`) while an x-independent formula at t has one fixed truth value (`gate_forces_x_independence`) — navigation can quantify over points but cannot NAME a specific free anchor. Proven sorry-free by `no_x_independent_formula_captures_future_zone_k1` in Kamp/NfZoneNavProbe.lean. This task's open question is whether the SAME obstruction recurs when x is existentially bound (not free) rather than assuming it automatically does or does not.

PRESERVED REUSABLE ASSETS (must not be rebuilt; consume, do not re-derive):
- `renameNF_eval_diag0` — depth-0 diagonal value-duplication congruence (NfDepth0Generalized.lean:1646), sorry-free, off-path; usable as the x=t diagonal arm base.
- Phase 11a/11b extraction and split lemmas in Kamp/NfZoneDepthK.lean: `nf_eval_atom_layer`, `zoneEnv3`, `nf3_order_*` (atom/order extraction); `nf_eval_quant_layer`, `nf_zone_exists_iff_char`, `exists_trichotomy_split`, `nf_zone_partition5`, `nf_zone_exists_partition5` (outer y-split); `nf_characteristic_atom_succ`, `nf_characteristic_quant_succ`, `nf_char_eq_iff_eval`, `exists_nested_split3`, `nf_characteristic_quant_split3`, `nf_char3_eq_succ_iff` (inner w-split + char interface). All sorry-free, off-path.
- `prior_hasAttainedINF` (Kamp/PriorINF.lean:224, sorry-free): `semantic_prior_UZ M atomMap -> HasAttainedINF M atomMap`, in scope on the live path via h_UZ; unlocks `neg_bounded_exists`/`neg_interval_formula`.
- `neg_interval_formula` (Lemma 5.1 forward, Kamp/EANegationClosure.lean:401) and `neg_bounded_exists` (Cor 5.4 forward, Kamp/EANegationClosure.lean:492) — model-dependent negation/INF closures, sorry-free.
- `existClosureLeft`/`existClosureLeft_correct`/`existClosureLeft_correct_rev`, `existClosure` (Kamp/VecEATranslation.lean, VecEA_m.lean:208) — Phase 7 leftward existential closure, sorry-free, off-path.
- Prop43.lean atomic blocks: `atomAt`/`ltAt`/`tt`/`ff` (+`_holds`), Kamp/Prop43.lean:45-109, sorry-free — faithful uniform Prop-4.3 atomic clauses; do NOT reopen the uniform-VecEA-negation framing (Prop43.lean's own BLOCKER note over-reaches the paper per plan v40's mitigated divergence risk).
- Bracket builders `bracketBuildLeft`/`bracketBuildRight` (+`_correct`), Kamp/VecEATranslation.lean:50,234, sorry-free — the navigation mechanism itself, arbitrary TemporalPred.
- Depth-k IH engine `exist_tl_fn_k`/`exist_tl_fn_k_correct` (Kamp/KampPrior.lean:334-344), in scope at :391.

LITERATURE GROUNDING: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Lemma 5.1, md:134-152; Corollary 5.4, md:154-157). KEY ARCHITECTURAL FACT (must not be violated): the paper's F_i chain (`F_n := alpha_n`, `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`) couples witnesses to the interval ENDPOINTS z_0, z_1 ONLY — never to a third free or bound anchor beyond the two endpoints already in scope. Rabinovich caps free variables at <= 2 (Lemma 3.2.2) and absorbs deeper quantifier structure as additional bracket witnesses within ONE interval, not as new anchors. Any candidate construction for this task must be checked against this fact: if the construction requires encoding a characteristic-type condition on a third anchor at a single navigable point (the arity-tower pattern already refuted in reports/40_phase11b-divergence-audit.md and reports/37/38 faithfulness audits), that is evidence the bound-anchor case shares the same obstruction as the free-anchor case, not a reason to build the tower anyway.

GOAL STATE: Either (a) close KampPrior.lean:391 sorry-free using the constructed converter, reducing the live-path sorry baseline from 2 to 1 (with :394 downstream, per task 305 Phase 19/20 scope), and hand a working rewire back to task 305; or (b) establish the definitive obstruction for the bound-anchor case (sorry-free counterexample machinery analogous to NfZoneNavProbe.lean's free-anchor proof) and document the resulting axiomatization/scope decision for :391 and :394 (e.g. whether the two sorries become a permanent documented gap, an axiom, or route to a different overall proof strategy for Kamp's theorem in this codebase). Either outcome must leave `lake build` GREEN with the top-level axiom set unchanged (2 axioms: propext/Classical.choice/Quot.sound style, per task 305 baseline) and record which of (a)/(b) was reached in a report/summary under specs/307_kamp_cor54_bound_anchor_zone_converter/.

---

### 305. Rabinovich ea formula implementation
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 307
- **Research**:
  - [305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md]
  - [305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/05_vecEA2-level-lemma51.md]
  - [305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/08_nf-eval-boost-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/14_constructive-eval-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/17_faithful-bridge-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/20_eanegation-sorry-analysis.md]
  - [305_rabinovich_ea_formula_implementation/reports/24_z-completeness-rabinovich.md]
  - [305_rabinovich_ea_formula_implementation/reports/14_faithfulness-audit.md]
  - [305_rabinovich_ea_formula_implementation/reports/15_arity-tower-deviation.md]
  - [305_rabinovich_ea_formula_implementation/reports/16_syntactic-vea-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/17_b2-construction-fix.md]
  - [305_rabinovich_ea_formula_implementation/reports/18_rabinovich-restructure-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/18_circularity-resolution-n1.md]
  - [305_rabinovich_ea_formula_implementation/reports/35_team-research.md]
  - [305_rabinovich_ea_formula_implementation/reports/36_phase0-regate-decision.md]
  - [305_rabinovich_ea_formula_implementation/reports/37_hard-findings-critical-audit.md]
  - [305_rabinovich_ea_formula_implementation/reports/38_prop43-unblock-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/39_depth-k1-bridge-design.md]
- **Plan**:
  - [305_rabinovich_ea_formula_implementation/plans/37_faithful-rabinovich-path.md]
  - [305_rabinovich_ea_formula_implementation/plans/38_lemma34-m1-rewire.md]
  - [305_rabinovich_ea_formula_implementation/plans/39_direct-nf-construction.md]

**Description**: Implement Rabinovich's proof of Kamp's theorem (Option A from report 20): faithful EA-formula formalization with negation closure via interval splitting. Define EAFormula type, prove closure properties (Lemma 3.2/3.4), V-EA to TL conversion (Prop 3.5), INF formula construction, Lemma 5.3/Corollary 5.4, full Lemma 5.1 (negation closure by induction on witness count n), and Propositions 4.2/4.3. Then rewire KampBypass k>0 to use the new single-structure path, eliminating all PriorComposition sorry. ~2200 lines across 8 new files. Depends on: existing CharPart/NormalForm infrastructure (sorry-free). Blocks: task 303 completion

---

### 303. K gt 0 depth induction
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 305
- **Research**:
  - [303_k_gt_0_depth_induction/reports/01_team-research.md]
  - [303_k_gt_0_depth_induction/reports/02_depth-induction-resolution.md]
  - [303_k_gt_0_depth_induction/reports/04_rabinovich-formula-analysis.md]
  - [303_k_gt_0_depth_induction/reports/05_recursive-formula-design.md]
  - [303_k_gt_0_depth_induction/reports/06_generalexistpart-redesign.md]
  - [303_k_gt_0_depth_induction/reports/07_literature-construction.md]
  - [303_k_gt_0_depth_induction/reports/09_interval-splitting-mapping.md]
  - [303_k_gt_0_depth_induction/reports/09_interval-splitting-mapping.md]
  - [303_k_gt_0_depth_induction/reports/10_blocker-resolution-path.md]
- **Summary**: [303_k_gt_0_depth_induction/summaries/02_depth-induction-summary.md]
- **Plan**:
  - [303_k_gt_0_depth_induction/plans/14_literature-grounded-plan.md]
  - [303_k_gt_0_depth_induction/plans/15_charpart-threading-plan.md]
  - [303_k_gt_0_depth_induction/plans/16_strong-d-induction-plan.md]
  - [303_k_gt_0_depth_induction/plans/17_reconstruction-induction-plan.md]
  - [303_k_gt_0_depth_induction/plans/18_nvar-transfer-plan.md]
  - [303_k_gt_0_depth_induction/plans/19_subsumption-closure-plan.md]

**Description**: Close existPart_succ_n1_bypass k>0 (KampBypass.lean) via Rabinovich Section 5 Lemma 5.1 interval-splitting induction. This is the SOLE remaining sorry blocking completeness_discrete. The k=0 infrastructure (complete and sorry-free, ~4400 lines) provides the template. Estimated effort: 200-400 lines. The key step: when negating an exists-forall formula with n witnesses at depth k+1, each insertion point creates sub-interval negation problems with fewer witnesses at depth k.

---

### 299. Refactor discrete game transfer
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 379

**Description**: Refactor DiscreteGameTransfer.lean to eliminate the wrapper pattern once the completeness chain is sorry-free. Inline discrete_ghr93_theorem6 by having StaviCompleteness.lean call ghr93_forward_to_backward directly with discrete typeclass instances. Convert discrete_rank_embed_eq_drc to a @[simp] lemma. Remove discrete_ghr93_theorem6_rank_varying if callers can use the general version. Clean up any dead code from the old fixed-pivot architecture that was deleted in task 273.

ABANDONED 2026-07-24: target file already archived; see completion_summary.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**: [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 294. Eliminate sorry in modals5 and perpetuity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: sorry-elimination
- **Dependencies**: Task 291

**Description**: Eliminate all sorry instances in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean. These files are needed for PR 4 (Derived Theorems) in cslib but contain 1-3 sorry each. Analysis suggests these are small enough to resolve: ModalS5.lean sorries likely require direct axiom application or simple combinatorial arguments; Perpetuity/Principles.lean sorries relate to fixpoint principles for G/H operators that should follow from the core axiom system. Complete both files to be fully sorry-free. Run lake build to verify zero errors and zero sorries.

---

### 293. Audit and fix mathlib linter compliance
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Audit and fix Mathlib linter compliance across all sorry-free modules scheduled for porting to cslib (Syntax, Semantics, ProofSystem, Theorems, FrameConditions, Soundness, MCS/Deduction, Completeness, Decidability, Separation, ConservativeExtension). Run the Mathlib linter (set_option linter.all true or use #check_lint). Fix: (1) Naming convention violations -- Mathlib uses descriptive snake_case names not opaque abbreviations (e.g., bfmcs, drm). (2) Missing docstrings on public declarations. (3) Universe polymorphism issues. (4) Line length violations (100 char limit). (5) Unused variable warnings. This task produces files ready for direct porting to cslib without linter failures.

---

### 292. Add copyright headers to all source files
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Add Apache 2.0 copyright headers to all source files under Theories/Bimodal/ (approximately 160 .lean files). cslib requires headers on all contributed files following the format: "-- Copyright (c) 2024 The Bimodal Logic Contributors. All rights reserved. -- Released under Apache 2.0 license as described in the file LICENSE. -- Authors: [author names]". Use a script to batch-add headers to files that lack them. Verify no duplicates are introduced. Run lake build to confirm no import errors.

---

### 291. Upgrade lean toolchain to v431 and mathlib
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: toolchain
- **Dependencies**: None

**Description**: Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to the same pin as cslib. This is a prerequisite for all porting tasks: cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly on 4.31. Steps: (1) Update lean-toolchain to v4.31.0-rc1 (or current cslib pin). (2) Run lake update to fetch compatible Mathlib. (3) Fix any API breakage caused by Lean/Mathlib version bump (expect ~50-200 lines of fixes across formula, tactic, and instance changes). (4) Run lake build to confirm zero errors. (5) Run existing tests to confirm no regressions. This task unlocks tasks 292, 293, 294 and all cslib porting tasks (2-13).

---

### 290. Improve tableau fuel allocation
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 288
- **Research**: [290_improve_tableau_fuel_allocation/reports/01_fuel-allocation-research.md]
- **Plan**: [290_improve_tableau_fuel_allocation/plans/01_fuel-allocation-plan.md]
- **Summary**: [290_improve_tableau_fuel_allocation/summaries/01_fuel-allocation-summary.md]

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [IMPLEMENTING]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 230. Benchmark refresh splits paraphrases schema
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 229
- **Research**: [230_benchmark_refresh_splits_paraphrases_schema/reports/01_benchmark-refresh.md]
- **Plan**: [230_benchmark_refresh_splits_paraphrases_schema/plans/01_benchmark-refresh-plan.md]

**Description**: After contamination resolution (task 229), regenerate all benchmark-derived artifacts. (1) Regenerate bmlogic-bench-splits.json for current record count — splits reference 727 records but benchmark now has 777. Run generate_splits.py and validate all IDs assigned to exactly one slice. (2) Restore NL paraphrase fields: benchmark was regenerated after paraphrases were added, losing nl_paraphrase and nl_paraphrase_method. Run generate_paraphrases.py and validate with validate_paraphrases.py. (3) Schema alignment: add formula_sexpr, formula_tokens, and pattern_features to benchmark records so evaluation uses the same representations as training. Extend finalize_benchmark.py or create enrichment script. (4) Decide whether to remove or keep the redundant max_modal_depth/max_temporal_depth fields in training data (they duplicate metrics.modalDepth/temporalDepth and pattern_key.modalDepth/temporalDepth — three copies of the same data). (5) Fill pattern_key for the 15 benchmark records where it is currently null.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 199. Grid order tactic
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [199_grid_order_tactic/reports/01_grid-order-tactic.md]
- **Plan**: [199_grid_order_tactic/plans/01_grid-order-tactic.md]

**Description**: Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Automation/) that automates the same_order_type grid dispatch in ghr93_case_II (Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean). The problem: after same_order_type_grid expands to intro i j; simp only [game_tuple]; split_ifs, it generates ~25 ordering goals per case. Each goal has shape (a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...). The available ordering lemmas (tau_sel_y, tau_sel_sel, sel_pn_ord, pn_sel_ord, tau_d_sel, hord_cd_en_pn, pivot_chain_order, fwd_x_b, fwd_b_y) are stated with Fin n but the goals use Fin (n+1), causing exact to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via convert ... using 3 <;> (congr 1; exact Fin.ext (by omega)), (2) handle the hab_eq rewrite for p_n cases (when not k < n, rewrite a_bwd to extendPoint p_n before applying sel_pn_ord/pn_sel_ord), (3) handle symmetry (y < sel goal uses tau_sel_y.symm), (4) fall back to sorry with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in ghr93_case_II: Case A sorry at line ~1631 and Case B sorry at line ~1940. These are the last fallthrough goals in the first | ... | sorry chains inside the same_order_type proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.

---

### 196. Codebase tactic survey
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 161
- **Research**: [196_codebase_tactic_survey/reports/01_team-research.md]

**Description**: Systematic survey of the entire Theories/Bimodal/ codebase to identify all tactic and automation opportunities. Produces a ranked inventory of tactic groups with effort estimates, line savings, and dependency relationships. Output: one new task per tactic group, replacing or refining existing tasks 185-195.

---

### 194. Migrate nonempty to derivable
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None
- **Research**:
  - [194_migrate_nonempty_to_derivable/reports/01_derivable-migration-seed.md]
  - [194_migrate_nonempty_to_derivable/reports/02_nonempty-derivable-migration.md]
- **Plan**: [194_migrate_nonempty_to_derivable/plans/02_migrate-nonempty-derivable.md]
- **Summary**: [194_migrate_nonempty_to_derivable/summaries/02_migrate-nonempty-derivable-summary.md]

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 189, Task 192, Task 196
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

---

### 192. Master tactic dispatch
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185, Task 187, Task 190, Task 191, Task 194
- **Research**: [192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]

---

### 191. Propositional decision procedure
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [191_propositional_decision_procedure/reports/01_decision-procedure-seed.md]
  - [191_propositional_decision_procedure/reports/02_decision-procedure-research.md]
- **Plan**: [191_propositional_decision_procedure/plans/02_reflection-kalmar-plan.md]
- **Summary**: [191_propositional_decision_procedure/summaries/02_reflection-kalmar-summary.md]

---

### 189. Deduction theorem tactic
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [189_deduction_theorem_tactic/reports/01_deduction-theorem-seed.md]
  - [189_deduction_theorem_tactic/reports/02_deduction-tactic-research.md]
- **Plan**: [189_deduction_theorem_tactic/plans/02_deduction-tactic-plan.md]
- **Summary**: [189_deduction_theorem_tactic/summaries/02_deduction-tactic-summary.md]

---

### 188. Weakening aware search
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 187
- **Research**:
  - [188_weakening_aware_search/reports/01_weakening-aware-seed.md]
  - [188_weakening_aware_search/reports/02_weakening-aware-search.md]
- **Plan**: [188_weakening_aware_search/plans/02_weakening-aware-search-plan.md]
- **Summary**: [188_weakening_aware_search/summaries/02_weakening-aware-search-summary.md]

---

### 187. Backward chaining lemma db
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 189
- **Research**:
  - [187_backward_chaining_lemma_db/reports/01_lemma-database-seed.md]
  - [187_backward_chaining_lemma_db/reports/02_backward-chaining-research.md]
- **Plan**: [187_backward_chaining_lemma_db/plans/02_backward-chaining-plan.md]
- **Summary**: [187_backward_chaining_lemma_db/summaries/02_backward-chaining-summary.md]

---

### 186. Unify search systems
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185
- **Research**: [186_unify_search_systems/reports/01_unify-search-seed.md]

---

### 180. Copyright headers universe polymorphism line limits
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: None

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 175. Naming convention and bridge cleanup
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131
- **Research**: [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

---

### 170. Complete dense extension completeness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Dense (FrameClass.Dense) WEAK completeness green: make `completeness_dense` (BXCanonical/Completeness.lean:234) genuinely sorry-free by retiring the inherited chronicle dense-path sorries (BXCanonical/Chronicle/ChronicleToCountermodel.lean succ_reaches_dom_N / chronicle_gap_contradiction; MCSMixedCase.lean). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_dense_extension_completeness".)

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:135, `valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)`) genuinely sorry-free by retiring or rerouting its open sorries — the dense-arm `countermodel_dense` (:159), the deprecated `countermodel_discrete` path (:166 → Transfer.lean:1270, the "unfixable Z+Z" succ_cofinal route; reroute through the clean countermodel_discrete_reynolds_v2 where the base case overlaps), and `dd_countermodel_chronicle_mixed_sorry` (:170). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_frame_extension_setup_and_soundness".)

---

### 165. Establish semantic finite model property
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in Decidability/FMP/ is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a canonical model where phi fails, quotient worlds by agreement on the subformula closure. (2) Prove the filtration lemma for all formula constructors including Until/Since (known to be problematic for naive filtration). (3) Prove the quotient model is a valid task frame. (4) Bound the model size by 2^|cl(phi)|. The result should be stated as: if phi is satisfiable in a task model, then phi is satisfiable in a finite task model of bounded size.

---

### 162. Enforce plan compliance rule
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None

**Description**: Add a .claude/rules/ rule enforcing strict plan compliance for lean-implementation-agent and other formal implementation agents. The rule should: (1) Prohibit agents from "assessing what's truly minimal" or inventing alternative approaches when a plan exists. (2) Require agents to follow the plan's exact task sequence step-by-step, in order. (3) Explicitly ban common divergence patterns: skipping intermediate theorems, inlining proofs instead of following the plan's decomposition, routing through different helper lemmas than specified, and "cleaner approach" rationalizations. (4) Be auto-applied via glob pattern to Theories/ and any formal proof files. (5) Reference the repeated failures in task 157 (8 plan versions, agents diverging every time) as motivation. The rule should be concise but firm -- agents must treat the plan as a contract, not a suggestion.

---

### 161. Rename theories bimodal to formalsystem
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 131. Refactor module organization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 341

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 379

**Description**: Verification pass on sorry status for completeness_discrete and bx_completeness. Updated scope after task 202 completion and task 155 re-scope: (1) Verify dd_countermodel_chronicle_dense and dd_countermodel_chronicle_mixed_sorry show no sorryAx (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case sorryAx: The BX chronicle path (dd_countermodel_chronicle_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal) is being bypassed. The correct fix is the WeakCanonical path: task 155 targets closing the no_gaps_discrete import cycle (GoodStructures.lean:855) by delegating to no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133), then rewiring completeness_discrete. Note: succ_cofinal remains the current root sorry on the BX chronicle path (ChronicleToCountermodel.lean), but this path is dead code -- the WeakCanonical route via no_gaps_discrete_model_surgery (already sorry-free) is the production path once the import cycle is resolved by task 155. (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report. Dependencies on tasks 93 and 109 removed (both completed).
