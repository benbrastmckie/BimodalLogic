# Metalogic Cleanup + Refactoring Evaluation — Discrete Completeness Proof and Metalogic/ Generally

**Date**: 2026-07-24 | **Session**: `sess_1784869380_2459bd` | **Mode**: read-only survey, `--hard`
**Scope**: `Theories/Bimodal/Metalogic/` (269 `.lean` files, ~179,600 lines incl. both Boneyards)
**Baseline trusted from mission + fidelity audit** (`specs/375_kamp_completeness_final_assembly_axiom_audit/reports/01_rabinovich-fidelity-audit.md`):
`completeness_discrete` sorryAx-free, axioms `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.
**Method**: every load-bearing claim below is grounded in a `file:line` read, a scripted
import-graph computation, a grep sweep, or a `lean_verify`/`lean_hover_info`/`lean_loogle` check.
No builds were run.

---

## 1. Executive Summary

The Kamp zone is in better shape than the rest of Metalogic/. The fidelity audit's picture
(2 dead sorries, motivated deviations, ζ-wire landed) is confirmed; the new findings of this
survey are almost all *outside* the audited zone:

1. **The flagship result is misdocumented in the live aggregator.** The live
   `Metalogic/Metalogic.lean` publication table (lines 27–33) still lists
   `completeness_discrete` as **SORRY** with a pointer to retired sorry arms
   ("KampPrior.lean:361/364"). Anyone reading the library's own front door concludes the
   headline theorem is unfinished. Two further live files carry the same retired-arms claim
   (`KampPrior.lean:946`, `:1253`).
2. **`completeness_dense` is sorryAx-free but its docstring says otherwise.** Verified this
   session via `lean_verify`: axioms identical to `completeness_discrete`, no `sorryAx` —
   while `BXCanonical/Completeness.lean:228` states "**Sorry Status**: Inherits sorries from
   `countermodel_dense`". Two of the three top-level completeness theorems are now clean and
   neither file says so.
3. **21 non-Boneyard files (4,837 lines) are import-orphans** — not transitively imported by
   the `Bimodal` root, therefore compiled by nothing and capable of silent rot. They split
   into deliberate ζ-era probes (archive), a dead duplicate aggregator
   (`Theories/Bimodal/Metalogic.lean`), and several files that look like they were *meant* to
   be live (`DenseSoundness.lean`, `DiscreteSoundness.lean`, `ConservativeExtension/` ×4,
   `Decidability/FMP/DenseFMP.lean`, `DiscreteFMP.lean`) — a per-file re-import-vs-archive
   decision is needed.
4. **Task 359 got cheap.** Its hardest stated obligation — "no live imports into Boneyard" —
   is *already satisfied* (scripted check: zero live→Boneyard import edges; the two files that
   do import `Kamp/Boneyard/*`, `Prop43.lean` and `NfMultiAnchorBridge/NavigatedEndChar.lean`,
   are themselves orphans). What remains is decl-level archival: the 2 EANegation sorries plus
   a newly inventoried set of ~17 dead sorried declarations in live files (§2.1).
5. **The only load-bearing sorry chain in Metalogic** is the deprecated
   `WeakCanonical.countermodel_discrete` (`Transfer.lean:1277`) consumed by the *general*
   `completeness` (`BXCanonical/Completeness.lean:165`). Two of `completeness`'s three
   branches could be re-pointed at existing clean, fc-generic lemmas
   (`mcs_mixed_case_absurd`, `countermodel_dense_enriched`), shrinking its sorry surface to
   the genuinely-hard Base-MCS discrete branch (§3.5).
6. **Refactoring**: of the four candidate abstractions, accept one now (a Fin-environment
   reindexing kit — the repo has **two competing `insertEnv` definitions** and Mathlib already
   provides `Fin.insertNth`/`Fin.snoc`), defer two until task 378 lands (attained-INF
   packaging; naming-seam interface), reject one (canonical-expansion API — it already
   exists in lemma form). The dual-evaluator statement migration is **not worth chartering**
   (§5.1).

Live-Metalogic sorry census (grep, statement-position patterns; the authoritative census is
`.claude/scripts/lean-sorry-census.sh`): **38 sorries in 11 non-Boneyard files**, of which 2
are the audited Kamp pair, 1 is load-bearing (for general `completeness` only), and the
remaining 35 sit on dead or bypassed declarations (§2.1).

---

## 2. Dimension 1 — Proof-Level Cleanup

### 2.1 Sorry inventory: live (non-Boneyard) Metalogic

Method: grep for statement-position patterns (`^\s*sorry$`, `:= sorry`, `by sorry`) excluding
both Boneyards; enclosing declaration recovered by backward scan; consumer status by repo-wide
reference grep with same-file and Boneyard references discounted (and the
`BXCanonical/TruthLemma.lean` hits verified to be *same-named local declarations*, i.e. name
shadowing, not consumption — `BXCanonical/TruthLemma.lean:279,294`).

| File | Decl (sorry lines) | Consumers (live) | Verdict |
|---|---|---|---|
| `WeakCanonical/Kamp/EANegation.lean` | `neg_bracket_is_vbracket` (:1090), `neg_partialBracketExist_is_vbracket` (:1249) | 0 | **Boneyard** — already chartered, task 359 addendum; keep impossibility note `:1047–1089` with the archived code |
| `WeakCanonical/Transfer.lean` | `countermodel_discrete` (:1277, marked DEPRECATED at :1256) | 1: `BXCanonical/Completeness.lean:165` (general `completeness`) | **KEEP** — only load-bearing sorry in Metalogic; removable only via the §3.5 re-base of general `completeness` |
| `WeakCanonical/TruthLemma.lean` | `truth_lemma` (:540,:556), `until_backward_mcs` (:431), `since_forward_mcs` (:497), `since_backward_mcs` (:483), +1 (:448) | 0 (BXCanonical hits are shadows) | **Boneyard decls** — superseded by the parametric truth lemma route (file's own docstrings at :433–443 say "non-critical-path"); file has other content, so decl-level excision |
| `WeakCanonical/OrderedSum.lean` | `doets_lemma_1_5` (:57) | 0 (`doets_lemma_1_4` in the same file IS consumed: `ShiftAndGlue.lean`, `GoodStructures.lean`) | **Boneyard decl** |
| `WeakCanonical/EFGames/StaviCompleteness.lean` | `nf_2var_existential_transfer` (:2428,:2510), `nf_exist_sf_guarded_backward` (:2884) | 0 live (only top-level `Boneyard/StaviDiscretePath/`) | **Boneyard decls** — the bypassed Stavi chain (`PriorExpressiveness.lean:24` documents the bypass) |
| `WeakCanonical/Expressiveness/CaseAnalysis.lean` | `ghr93_cases_III_IV` (:3376–:3417, 6 sorries) | 0 (`ghr93_case_I`/`_II` in same file ARE live: `Transfer.lean:833,:841`) | **Boneyard decl** — dead arm of an otherwise-live file |
| `BXCanonical/Frame.lean` | `bx_le_refl` (:205) | 0 | **Boneyard decl** |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | `chronicle_gap_contradiction` (:221,:377,:513,:527), `succ_reaches_dom_N` (:768,:788) | 0 code consumers (all external refs are comments: `MCSMixedCase.lean:11`, `ReynoldsBridge.lean:23,:736`, `Completeness.lean:364`) | **Boneyard decls** — `Completeness.lean:364` already declares them dead |
| `Bundle/SuccRelation.lean` | 7 sorries: `g/h_content_subset_mcs`, `or_until/since_in_mcs`, `until_persists_through_succ`, `until/since_unfold_in_mcs` (:558–:648) | `until/since_unfold_in_mcs` → `Bundle/TemporalCoherence.lean` (live); rest 0–1 (within sorried Bundle files) | **KEEP + audit** — legacy Bundle spine; consumed only inside Bundle/Chronicle territory that feeds sorry-tainted general `completeness`; decl-level audit belongs to the 131 reorganization |
| `Bundle/SuccExistence.lean` | 3 sorries (:446,:749,:823): `constrained_successor_seed_consistent`, `*_deferral_seed_consistent_axiom` | 0 | **Boneyard decls** |
| `Bundle/UntilSinceCoherence.lean` | `backward_until_reflexive` (:85), `backward_since_reflexive` (:96) | 0 | **Boneyard decls** |

Total: 38. None of these (except the KEEP rows) blocks anything; none touches
`completeness_discrete` or `completeness_dense` (both verified sorryAx-free this session).

### 2.2 Import-orphaned files (not transitively imported by the `Bimodal` root)

Scripted computation (module graph from `import` lines, root `Bimodal`, `srcDir Theories`):
**198 live / 50 Kamp-Boneyard (excluded by design) / 21 non-Boneyard orphans, 4,837 lines**.
Precedent: `Prop35VeeLift.lean` deletion; `ZetaUniformExtract.lean` (now live — confirmed on
the import closure).

| Orphan | Lines | Classification / recommended fate |
|---|---|---|
| `Theories/Bimodal/Metalogic.lean` | 55 | **Dead duplicate aggregator** — shadowed by live `Metalogic/Metalogic.lean` (root imports `Bimodal.Metalogic.Metalogic` via `Bimodal/Bimodal.lean:4`); carries its own stale status table ("Completeness \| SORRY (chronicle)"). Delete or fold into the live aggregator (route: 131) |
| `DenseSoundness.lean`, `DiscreteSoundness.lean` | 50+52 | **Probably meant to be live** (named results advertised in docs). Decide re-import vs archive |
| `ConservativeExtension/{ExtDerivation,ExtFormula,Lifting,Substitution}.lean` | 1,600 | Whole subsystem off the build. Decide re-import vs archive (131 charter already lists 7 subdirs incl. this one) |
| `Decidability/FMP/DenseFMP.lean`, `DiscreteFMP.lean` | 112+117 | FMP variants off the build while the rest of `FMP/` is live. Decide |
| `Decidability/TraceExport.lean` | 221 | Check `lake exe trace_exporter` root (`Automation/TraceExporter`) — if unused there, archive |
| `Bundle/CanonicalIrreflexivity.lean` | 177 | Dead Bundle leaf. Archive |
| `Kamp/{HCaptureDischarge,InfAlphabetProbe,OptionBLocalityProbe,PerFormulaRenderProbe,ZetaAtomMapReconcile}.lean` | 1,104 | **ζ-era probes/scaffolding** (spike files; `PerFormulaRenderProbe` even redefines `efSatFin` locally, :188). Archive to Kamp/Boneyard |
| `Kamp/Prop43.lean` | 192 | Orphan AND imports `Kamp.Boneyard.{VecEA_m,EAVecNegationClosure}` — the "live imports into Boneyard" flagged in the 359 charter are located here; since the file is itself an orphan, wholesale archival simultaneously satisfies invariant (1) |
| `Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` | 292 | Same pattern: orphan importing `Boneyard.NavigatedEndCharSinglePoint`. Archive |
| `Kamp/NfMultiAnchorBridge/{ExteriorDeepExclSupplyK,ExteriorDeepSliceSupplyK,Lemma32Reduction}.lean` | 865 | Orphaned bridge modules (the k≥2 per-depth escalation path retired by the ζ wire). Archive — but per the 378 charter's PRESERVE constraint, verify no frozen-interface surface first |

**Correction to the 359 charter**: "~3 remaining live imports into Boneyard (via Prop43 and
NavigatedEndChar)" is no longer accurate — those importers are now *outside the live import
closure*, so the no-live-imports invariant already holds. 359's remaining work is decl-level
archival (§2.1) + orphan archival + Boneyard tidying.

### 2.3 Redundant pairs / superseded variants

- **Fin/non-Fin twins that survived the switchover** (scripted decl-name diff over live Kamp):
  exactly three pairs — `efSat` (`ExistsForallFormula.lean:125`) / `efSatFin`
  (`PerFormulaExistsForall.lean:74`), `veeSat` (`VeeExistsForall.lean:39`) / `veeSatFin`
  (`ExistsForallLemmas.lean:223`), `intervalHolds` (`ExistsForallFormula.lean:93`) /
  `intervalHoldsFin` (`PerFormulaType.lean:104`). The non-Fin totals still carry live
  consumers (the k=0/k=1 legacy arms); consolidation is the Drift-Register-#7 work owned by
  359 and should NOT be done casually (plan-compliance: landed proofs).
- **Per-k arms vs general-k**: `kampPrior_case1_arm_k0` (`KampPrior.lean:272`) and `_k1`
  (`:302`) remain live alongside the general `kampArm_zeta`; used at `:491–:492`. Same 359
  ownership; consolidation optional.
- **Deprecated-wrapper pattern (task 299)**: `DiscreteGameTransfer.lean` is already archived
  at `Theories/Bimodal/Boneyard/StaviDiscretePath/DiscreteGameTransfer.lean` — **task 299 as
  chartered appears moot** (its target already left the live tree); recommend closing or
  re-scoping 299 after a one-line verification that no live wrapper remains. The only live
  DEPRECATED marker in Metalogic is `Transfer.lean:1256` (`countermodel_discrete`, §2.1).
- **Superseded by more general landed versions**: the `EFSatNegation.lean` /
  `EFSatNegationGeneral.lean` / `ZetaUniformExtract`-`_uniformFin` stack is three
  generations of the same negation chain; the first two still have live consumers on the
  per-`N` layer, so this is a documentation problem (say which layer is current — the
  ZetaUniformExtract header does) more than a deletion problem.

### 2.4 Proof hygiene (sampled, not exhaustive)

Longest single proofs (decl-gap approximation, live files):

| Lines | Location | Note |
|---|---|---|
| ~4,543 | `Expressiveness/SplitPoint.lean:150` `obtain_split_point_props` | single proof, bypassed GHR93 zone |
| ~3,203 | `BXCanonical/Chronicle/CounterexampleElimination.lean:284` | chronicle zone |
| ~1,896 / ~1,743 | `EFGames/GapDetection.lean:3161 / :1131` | bypassed zone |
| ~948 / ~920 | `Kamp/NfMultiAnchorBridge/SharedWitness.lean:11632 / :10605` (`kvE2_sepGateAtPin_fragR/L`) | live k=0/1 carrier; task 341 territory |

Bare `simp` (no `only`) density is highest in `SharedWitness.lean` (455 occurrences), then
`CaseAnalysis.lean` / `StaviCompleteness.lean` (250 each). Recommendation: do NOT lint-fix
these in place; the two live hotspots (`SharedWitness`, `NfDepth0Generalized` at 184) are
exactly task 341's split territory — fold hygiene into that split. The bypassed-zone
monsters (`SplitPoint`, `GapDetection`) should be left untouched unless/until the GHR93 zone
is archived — polishing dead code is negative-value work.

---

## 3. Dimension 2 — Architecture

### 3.1 The dual-evaluator situation (`nf_eval_nf` vs the faithful E[Σ]/∨∃∀ layer)

Facts (verified): `nf_eval_nf` is defined at `WeakCanonical/NormalForm.lean:202`; it appears
in the *statement* of `nf_nvar_exist_all_depths` (`Kamp/KampPrior.lean:348`, a
`noncomputable def` whose ∃-conclusion mentions `nf_eval_nf`, arity-capped by `hn : n ≤ 1`)
and in `nf_characterizable_temporal_prior`; the faithful `NfEFold`/E[Σ] machinery
(`nf_eval_efold`, `NfEFold.lean:102`) is imported only by the `NfMultiAnchorBridge` k=0/k=1
subtree (5 files). The top statements (`kamp_prior_expressive_completeness`,
`US_expressively_complete_over_prior`) are already evaluator-free (audit §3.3.1).

**Assessment — do not charter a statement-level migration now.**
- *What it would buy*: the intermediate spine statements would read in Def-3.1 vocabulary;
  one Hintikka-type indirection removed from the story a referee reads.
- *What it would cost*: `nf_eval_nf` is referenced across **61 live files** (grep); the
  boundary conversion (`nf_to_formula`) is exactly where plan 24's recorded resolution
  ("RESOLVED to (b)") put it, deliberately, for zero consumer churn; and every candidate
  consumer is a landed proof protected by the plan-compliance rule. The paper-facing content
  is already carried by the evaluator-free top statements.
- *Fidelity*: the audit classifies the current state MOTIVATED (Drift Register #6). A
  migration would convert a documented interface decision into a multi-dispatch churn risk
  for zero change in what is proved.
- Revisit trigger: publication-polish under task 131, or if 378's re-base forces statement
  edits in the same region anyway.

### 3.2 Import-graph health

- **Depth**: longest chain root→leaf is **50 modules** deep, 40 of which are inside
  `WeakCanonical/Kamp/` (the `NfMultiAnchorBridge` Exterior* ladder contributes ~25
  single-file links). No cycles (reachability DFS completes; Lean would reject cycles
  anyway). The ladder is an artifact of one-file-per-dispatch development; a 359/341-era
  consolidation could flatten it, but depth alone breaks nothing.
- **Two aggregators for one namespace** (§2.2): `Theories/Bimodal/Metalogic.lean` (dead)
  vs `Metalogic/Metalogic.lean` (live). One must go (131).
- **Two Boneyards with different build treatment**: top-level
  `Theories/Bimodal/Boneyard/` (73 files, 48,372 lines) is covered by the `BoneyardArchive`
  lake lib (vacuous build — `#exit` before imports, per the 378 charter's LIVENESS note);
  `Metalogic/WeakCanonical/Kamp/Boneyard/` (50 files, 23,953 lines) is covered by **no glob
  at all**. Policy inconsistency: either give Kamp/Boneyard the same `BoneyardArchive`-style
  declaration or record in the Boneyard README that reachability-from-`Bimodal` is the only
  liveness criterion (the 378 charter already states this; it belongs in-tree). Route: 359
  part (3) tidying.
- **Misplaced files**: the Kamp expressive-completeness zone lives under `WeakCanonical/`
  though nothing about it is "weak canonical" — it is the expressiveness input to the
  Reynolds pipeline. A `Metalogic/Expressiveness/Kamp/` or `Metalogic/Kamp/` home is more
  honest; this is exactly task 131's charter (do it there, not piecemeal).

### 3.3 Boneyard status

- Zero live imports into either Boneyard (scripted check, §2.2) — 359 invariant (1) done.
- The WeakCanonical/Kamp zone **should get its archival sweep now**: the re-architecture has
  settled (ζ wire landed, residual retired), the audit has already adjudicated what is dead,
  and §2.1/§2.2 provide the concrete inventory. This is the natural moment: verdicts are
  fresh and the 378 re-base has not yet started moving carrier code.

### 3.4 BXCanonical vs WeakCanonical duplication; the sharedwitness layer (task 341)

- Verified decl-name overlap between `BXCanonical/TruthLemma.lean` and
  `WeakCanonical/TruthLemma.lean`: `bot_not_in_mcs`, `until_forward_mcs`,
  `since_forward_mcs` — parallel MCS/truth-lemma developments for the BX-canonical vs
  reflexive-canonical constructions. This is *structural* duplication (different carriers,
  same lemma shapes), best resolved by the 131 reorganization deciding which construction is
  the story and archiving the other's dead parts — not by a shared abstraction.
- Task 341's sharedwitness split is **intra-Kamp** (`SharedWitness.lean`, measured this
  session at **12,800 lines** — grown again past the charter's "~12,600" note; two ~950-line
  proofs; 455 bare simps). It would NOT deduplicate the BXCanonical/WeakCanonical overlap —
  different layer entirely. Its sequencing gates (333/335/340/346) should be re-checked
  against current state before dispatch, per its own charter.

### 3.5 The general `completeness` re-point opportunity (new finding)

`lean_verify` this session: `completeness` (Base) carries `sorryAx`;
`completeness_dense` and `completeness_discrete` do not. Reading
`BXCanonical/Completeness.lean:135–171`, `completeness`'s three branches use:
dense → `Chronicle.countermodel_dense` (sorried chain); discrete →
`WeakCanonical.countermodel_discrete` (deprecated sorry, `Transfer.lean:1277`); mixed →
`Chronicle.dd_countermodel_chronicle_mixed_sorry`. But the file already contains clean,
applicable replacements for two branches:

- **Mixed**: `mcs_mixed_case_absurd` (`MCSMixedCase.lean:34`) is **fc-generic**
  (`(fc : FrameClass)`, axiom availability discharged by `trivial`) and sorry-free (it is
  what `completeness_discrete:339` uses). Direct drop-in.
- **Dense**: `countermodel_dense_enriched` (`Completeness.lean:186`) is `{fc : FrameClass}`
  generic and sorryAx-free (it is `completeness_dense`'s only nontrivial dependency);
  currently `private` — de-privatize and re-point.
- **Discrete**: NOT re-pointable — `countermodel_discrete_reynolds_v2`
  (`ReynoldsBridge.lean:724–726`) requires `SetMaximalConsistent (fc := FrameClass.Discrete)`,
  and a Base-MCS is not automatically Discrete-consistent. This branch is the genuine
  mathematical residue.

Re-pointing shrinks `completeness`'s sorry surface from three sorried dependencies to one
(`countermodel_discrete`), concentrates the debt in one named place, and makes the
`completeness` docstring (`:129`, which *already claims* the mixed case uses
`mcs_mixed_case_absurd` — currently false, the code at `:169` uses the `_sorry` variant)
true. Small, well-bounded new task; also unlocks archiving
`dd_countermodel_chronicle_mixed_sorry` and possibly a chunk of the Chronicle gap chain.

---

## 4. Dimension 3 — Comments / Documentation

### 4.1 Stale line-anchored comments

- **≥568 `.lean:NNN`-style anchors** in comments across live Metalogic (grep
  `\.lean:[0-9]+`, Boneyard excluded, 60+ files) — a lower bound, since bare `:NNN` anchors
  (the historically rotting `:212/:351/:520/:562` style) are not countable without false
  positives.
- **Actively misleading instances found by reading** (worse than dangling — they assert
  retired facts):
  - `KampPrior.lean:946`: "discharging `hreal`/`hexcl` requires the un-landed realization
    recursion (the `:361`/`:364` sorry arms)" — those arms were retired by the ζ wire.
  - `KampPrior.lean:1253`: "any top-level reference to `nf_nvar_exist_all_depths` inherits
    `sorryAx` from the open `:361`/`:364` arms" — now **false**; the decl is sorry-free and
    downstream of it `completeness_discrete` is sorryAx-free.
  - `Metalogic/Metalogic.lean:32` (live aggregator): `completeness_discrete` "SORRY
    (`nf_nvar_exist_all_depths`, KampPrior.lean:361/364 …)" — the flagship misdocumented.
- Recommendation: anchor by declaration name, not line (the repo's own established fix, cf.
  the corrected `KampPrior.lean:507–518` note). Route: fold the *stale-fact* fixes into a
  small immediate task; the mass `.lean:NNN`→decl-name conversion can ride along with 380's
  sweep since both are mechanical comment-only edits over the same files.

### 4.2 Stale audit blocks (sorry/axiom status claims)

Grep for status-claim phrases across live Metalogic:

| Site | Claim | Reality | Fix |
|---|---|---|---|
| `Metalogic/Metalogic.lean:27–33` | table: all three completeness rows SORRY | `completeness_discrete` AND `completeness_dense` sorryAx-free (lean_verify) | rewrite table |
| `BXCanonical/Completeness.lean:228` | `completeness_dense` "Inherits sorries from `countermodel_dense`" | sorryAx-free | rewrite |
| `BXCanonical/Completeness.lean:39,:131` | "Remaining leaf sorries are in the Chronicle/ modules" | true only for general `completeness`; header should note the clean discrete/dense flagships | qualify |
| `BXCanonical/Completeness.lean:129` vs `:169` | docstring says mixed case uses `mcs_mixed_case_absurd`; code uses `dd_countermodel_chronicle_mixed_sorry` | doc/code mismatch | fix via §3.5 re-point (or correct the docstring) |
| dead `Theories/Bimodal/Metalogic.lean:30–32` | same stale table | file is an orphan | delete file (§2.2) |

The `completeness_discrete` in-file audit block (`Completeness.lean:344–374`) is current and
correct — it was fixed this week and matches the lean_verify result exactly.

### 4.3 ζ-wire docstring coverage — GOOD, no action

Checked all four new files. Module headers carry Rabinovich PDF-page citations and design
rationale; declaration-level docstring counts match declaration counts:
`ESigmaExpansion.lean` (14 page-cites, 12 docstrings / 11 decls), `PerFormulaRender.lean`
(9 / 9 / 9), `ZetaUniformExtract.lean` (15 / 12 / 12), `ESigmaCapture.lean` (10 / 5 / 5).
Each header also states the corrupt-markdown warning and the deleted-machinery record
(`ESigmaCapture` "Where the old finite-alphabet capture machinery went"). This is the
documentation standard the rest of Metalogic should be held to.

### 4.4 Task-number references in `Theories/**/*.lean` (sizing for task 380)

Grep `task [0-9]{2,3}` (case-insensitive, incl. `task-NNN`):

- Whole `Theories/Bimodal/`: **1,558 lines** (incl. Boneyards); **1,362** excluding Boneyards.
- `Metalogic/` non-Boneyard alone: **1,147 lines** — i.e. 84% of the live debt is in
  Metalogic.
- Top offenders: `SharedWitness.lean` (262), `NfMultiAnchorBridge/Base.lean` (84),
  `InteriorGateGeneralK.lean` (57), `SubBracket2V.lean` (50), `KampPrior.lean` (50),
  `EndIntervalConsumerK.lean` (43), `OuterGate.lean` (40).
- Sizing consequence for 380: this is NOT a small sweep; recommend batching per-directory
  with the `NfMultiAnchorBridge/` tree last (it is also 341's split territory — coordinate:
  doing 380 *before* 341 moves comments 341 will then relocate; doing it *inside* 341's
  moves is cheaper for that subtree). Boneyard files should be explicitly exempted or
  deferred (196 lines there).

---

## 5. Dimension 4 — Abstractions / Refactoring

### 5.1 Verdicts on the candidate abstractions

| Candidate | Verdict | Reasoning |
|---|---|---|
| (a) Typeclass/structure packaging ordered-monadic-structure + attained-INF/SUP (+ Nonempty) | **DEFER (reject now)** | 116 occurrences across 28 live files would churn; task 378 is chartered to *replace* the attained carrier with the Dedekind one via already-landed shims (`DedekindINF.lean`) — bundling now means rewriting the bundle again during 378. Package (if still wanted) as part of 378's landing, when the final hypothesis set is known. |
| (b) Unify render/naming seam (`nameOf`/`hName`) into one interface | **DEFER (reject now)** | 271 `hName` occurrences across 12 files, but the seam is *internally consistent* (single premise shape, discharged at exactly two sites: `nameOfSurj_hName`, `canonExpand_atom_named`/`zetaNameOf_hName`). A `NamingScheme` structure would be cosmetic; the chain is landed, stable, and 378-adjacent. Reconsider at publication polish (131). |
| (c) Canonical-expansion API so consumers stop touching `canonExpand` internals | **REJECT** | The API already exists in lemma form — consumers observed (11 files) go through `atom_eval_new`/`atom_eval_old` (`ESigmaExpansion.lean:124/134`), `temporal_truth_canonExpand`, `canonExpand_atom_named` (`ESigmaCapture.lean`); no internals-poking site surfaced in the survey. Adding an opaque wrapper would only distance the code from Def 4.1, which the current transparent definition transcribes. |
| (d) Consolidate Fin/Vector environment reindexing (insertEnv/Fin.cons bridges) into a kit | **ACCEPT** | The repo has **two competing `insertEnv` definitions with different semantics**: positional insert (`WeakCanonical/MonadicFO.lean:345`, hover-verified `(c : Fin (n+1)) (x) (env)`) vs append-at-last (`Kamp/NfDepth0Generalized.lean:42`, with `insertEnv_last/_init/_zero` bridges) — a real confusion hazard (same name, different behavior, both live). Mathlib already provides the general objects: `Fin.insertNth` (loogle-verified, `Mathlib.Data.Fin.Tuple.Basic`, with `insertNth_apply_same/succAbove`, `insertNth_last' = snoc`) and `Fin.snoc`/`Fin.cons`. Kit = one module defining the repo's two idioms as abbreviations over Mathlib + the `insertEnv env t = Fin.cons x (fun _ => t)`-style two-way bridges currently re-proved inline (e.g. the `.imp` adapter at `KampPrior.lean:505–521`). Effort M, mechanical; route with 175 (it is naming/bridge cleanup) or a small standalone task. |

### 5.2 Additional abstraction/refactoring findings

- **General-`completeness` branch re-point** (§3.5) — the highest proof-value/effort ratio
  item found by this survey.
- **Mathlib upstreaming**: **no strong candidates.** The order-theoretic material
  (`HasAttainedINF`, Dedekind shims) is bespoke to the Rabinovich carrier discipline and
  slated for rework (378); the Fin-environment lemmas are *downstream* migrations onto
  existing Mathlib API, not upstream contributions; `doets_lemma_1_4`-style ordered-sum
  facts are signature-specific. Nothing here clears the "genuinely general" bar.
- **Naming-convention debt in the Metalogic zone (task 175 sizing)**: substring counts in
  live Metalogic — `temp_` 471, `dd_` 119, `bfmcs` 67, `cud` 54, `sdc` 10 (`drm`/`tc_`/
  `fuc_`/`buc_` now 0 — partially already cleaned). So a substantial share of 175's
  expansion targets lives here, but the `temp_`→`temporal_` rename crosses ~everything;
  175 should sequence Metalogic after the 341 split to avoid renaming inside a file about
  to be dismembered.

---

## 6. Prioritized Recommendation Table

| # | Item | Dim | Impact | Effort | Routing |
|---|---|---|---|---|---|
| 1 | Fix stale flagship-status docs: `Metalogic/Metalogic.lean:27–33` table, `Completeness.lean:228/:39/:131`, `KampPrior.lean:946/:1253` retired-arms claims | 3 | **High** (misrepresents the library's headline result) | **S** | **New small task** (comment-only, ~6 sites); do first |
| 2 | Orphan triage: delete dead aggregator `Theories/Bimodal/Metalogic.lean`; per-file re-import-vs-archive decision for the other 20 orphans (4,837 LOC), ζ-probes → Kamp/Boneyard | 1/2 | **High** (silent-rot surface; CI compiles none of it) | **M** | **New task** (probe-archival half can fold into 359; DenseSoundness/ConservativeExtension/FMP decisions need user input; structure half → 131) |
| 3 | Execute task 359 with §2.1 inventory: archive 2 EANegation sorries + ~17 dead sorried decls (TruthLemma ×6, ghr93_cases_III_IV, chronicle_gap pair, bx_le_refl, doets_lemma_1_5, Stavi ×3, Bundle dead ×5); note invariant (1) already holds; unify Boneyard build policy | 1/2 | **High** (live sorry census 38 → ~2–3; clean publication story) | **M** | **Existing task 359** (attach this review's §2.1–2.2 as inventory) |
| 4 | Re-point general `completeness` mixed branch → `mcs_mixed_case_absurd`, dense branch → de-privatized `countermodel_dense_enriched`; fixes `:129` doc/code mismatch; isolates debt to the Base-discrete branch | 2 | **High** | **S–M** | **New task proposal** (§3.5) |
| 5 | Task 380 execution with sizing data (1,362 live lines, 84% in Metalogic; batch per-directory; coordinate `NfMultiAnchorBridge/` with 341; fold `.lean:NNN`→decl-name anchor conversion in) | 3 | Med | **L** | **Existing task 380** |
| 6 | Fin-environment kit: consolidate the two `insertEnv`s onto Mathlib `Fin.insertNth`/`Fin.snoc` + bridge lemmas | 4 | Med | **M** | **Fold into existing task 175** (or small standalone) |
| 7 | Task 341 SharedWitness split (12,800 lines — refresh charter figure again; two ~950-line proofs; 455 bare simps; 262 task-refs) | 2/1 | Med-High | **L** | **Existing task 341** (re-verify sequencing gates first) |
| 8 | Close or re-scope task 299 (DiscreteGameTransfer already Boneyarded; target gone from live tree) | 1 | Low | **S** | **Existing task 299** → verify + close |
| 9 | Task 175 Metalogic share: sequence after 341; counts in §5.2 | 4 | Med | **L** | **Existing task 175** |
| 10 | Dual-evaluator statement migration onto faithful evaluator | 2 | Low (fidelity already motivated; zero operational value) | L | **Not worth chartering now**; revisit under 131/publication |
| 11 | Attained-INF packaging & naming-seam interface | 4 | Low now | M | **Defer until 378 lands** |
| 12 | `native_decide` → `decide` hardening (`Syntax/Formula.lean:265`) to drop the compiler axiom pair | 2 | Low-Med | S | **Existing task 375** (already recorded there; repeated for completeness) |
| 13 | Metalogic/ reorganization (Kamp zone out of WeakCanonical/, aggregator unification, import-ladder flattening) | 2 | Med | L | **Existing task 131** |

---

## 7. Adversarial Self-Verification

Stance:每 load-bearing claim re-checked against a second source or the primary artifact.

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `completeness_dense` is sorryAx-free (axioms = the completeness_discrete set) | contradicts its own docstring `:228` | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_dense`, this session | High |
| `completeness` (Base) carries `sorryAx` | consistent with call-site read `:165/:169` | `lean_verify` on `...BXCanonical.completeness`, this session | High |
| 21 non-Boneyard Metalogic files are import-orphans; zero live→Boneyard import edges | first scripted run wrongly reported 269 orphans (module-name bug: `Theories.` prefix vs `srcDir`); re-run with `srcDir=Theories`, root `Bimodal` per `lakefile.lean` (`roots := #[`Bimodal]`) | scripted import-closure DFS, corrected; lakefile read | High |
| The dead aggregator is `Theories/Bimodal/Metalogic.lean`, the live one `Metalogic/Metalogic.lean` | `Bimodal/Bimodal.lean:4` imports `Bimodal.Metalogic.Metalogic`; only Tests/ import `Bimodal.Metalogic` (test lib, separate root) | grep of importers both ways | High |
| 38 statement-position sorries in live Metalogic, per-decl mapping and consumer counts of §2.1 | patterns may miss exotic forms; repo's own census script is tactic-position authoritative; BXCanonical "consumers" of TruthLemma sorries verified to be same-named local decls (`BXCanonical/TruthLemma.lean:279,:294`), not imports | grep sweep + backward decl scan + per-name reference grep + shadow check | Medium-High (grep-based; recommend `lean-sorry-census.sh` re-run at 359 dispatch) |
| `chronicle_gap_contradiction`/`succ_reaches_dom_N` have zero code consumers | external refs read individually: `MCSMixedCase.lean:11` (comment), `ReynoldsBridge.lean:23,:736` (comments), `Completeness.lean:364` (audit block) | per-site read | High |
| `countermodel_discrete` (deprecated sorry) is consumed by general `completeness` | `BXCanonical/Completeness.lean:165` read in full context | Read | High |
| `mcs_mixed_case_absurd` is fc-generic and applicable to the Base mixed branch | signature read `MCSMixedCase.lean:34–36` (`(fc : FrameClass)`, axiom side-conditions by `trivial`); used with `FrameClass.Discrete` at `Completeness.lean:339` | Read | High |
| `countermodel_discrete_reynolds_v2` cannot serve the Base branch as-is | signature read `ReynoldsBridge.lean:726`: requires `SetMaximalConsistent (fc := FrameClass.Discrete)` | Read | High |
| `countermodel_dense_enriched` is clean and fc-generic but `private` | `Completeness.lean:186` (`private theorem`, `{fc : FrameClass}`); cleanliness follows from `completeness_dense`'s verified axiom set, of which it is the only nontrivial dependency | Read + lean_verify inference | Medium-High (inference, not direct lean_verify on the private decl) |
| Two `insertEnv` defs with different semantics; Mathlib has the general API | hover on `MonadicFO.lean:345` (positional insert, doc quoted); `NfDepth0Generalized.lean:42–54` read (append-last + bridges); `Fin.insertNth` + `insertNth_last' = snoc` returned by loogle from `Mathlib.Data.Fin.Tuple.Basic` | lean_hover_info + Read + lean_loogle | High |
| Task-ref counts (1,558 / 1,362 / 1,147) and line-anchor count (≥568) | regex `task [0-9]{2,3}` may catch prose like "multi-task"; spot-check of top files shows the hits are genuine task-number pointers; `.lean:NNN` count excludes bare `:NNN` anchors (undercount, stated as lower bound) | grep sweeps + spot reads | Medium-High |
| `KampPrior.lean:946/:1253` claims about "open :361/:364 arms" are now false | mission + audit: k≥2 residual retired sorry-free; `completeness_discrete` sorryAx-free re-verified via the audit's lean_verify and this session's `completeness_dense`/`completeness` checks; KampPrior grep shows no remaining sorry at those arms (only `EANegation` sorries remain in Kamp/) | Read + grep + audit cross-check | High |
| Task 299 target already archived | `find`: only match is `Theories/Bimodal/Boneyard/StaviDiscretePath/DiscreteGameTransfer.lean` | find | High |
| `SharedWitness.lean` is 12,800 lines (charter says ~12,600) | `wc -l` this session | wc | High |
| ζ-wire docstring coverage adequate | headers read in full; docstring/decl counts scripted | Read + grep counts | High |

### Contradiction Log

- **359 charter vs current state**: charter says "~3 remaining live imports into Boneyard
  (via Prop43 and NavigatedEndChar)". Scripted check finds those import edges still exist in
  the files but the *importing files are no longer in the live closure*. Resolution: both
  true at different times — the roadmap-13 claim predates the ζ re-wire orphaning those
  files. Charter should be annotated at dispatch; recorded in §2.2.
- **`completeness` docstring vs code** (`Completeness.lean:129` claims `mcs_mixed_case_absurd`,
  code `:169` uses `dd_countermodel_chronicle_mixed_sorry`): resolved as a doc/code mismatch
  by reading both; fix proposed in recommendation #4.
- **Audit's "exactly 2 dead sorries in the Kamp zone" vs this survey's 38**: no
  contradiction — the audit scoped the live *Kamp* zone; this survey scopes all of
  Metalogic. The two Kamp sorries reconcile exactly (`EANegation.lean:1090/:1249`).
- **Not re-run**: the audit's `lean_verify` of `completeness_discrete` itself (trusted per
  mission "CURRENT STATE (trust; do not re-derive)"); this session independently verified
  its two siblings, which exercise the same pipeline.

### Recommendations modified after verification

- Initially drafted "re-point all three branches of general `completeness`"; downgraded to
  two after reading `countermodel_discrete_reynolds_v2`'s Discrete-MCS hypothesis — the
  discrete branch is genuine mathematics, not wiring.
- Initially classified `Decidability/TraceExport.lean` as plainly dead; softened to
  "check the `trace_exporter` exe root first" after re-reading the lakefile's exe targets
  (they root in `Automation/`, but a transitive use could not be excluded without tracing
  that closure, which is outside Metalogic).
- Initially counted 7 sorries in `ChronicleToCountermodel.lean`; corrected to 6 on recount
  of the grep output.
