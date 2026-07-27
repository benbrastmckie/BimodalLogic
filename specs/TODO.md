---
next_project_number: 404
---

# TODO

## Task Order

*Updated 2026-07-27. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 95,125,127,128,165,179,193,231,257,298,318,361,377,378,390 | -- | completeness, frame-extensions, algebraic-representation, ... |
| 2 | 169,170,177,178,219,282,296,391 | 193,231,298,361,390 | completeness, formula-refactor, dataset-enhancement, ... |
| 3 | 362 | 169,170 | strong_completeness |

**Grouped by Topic** (indented = depends on parent):

### Completeness

95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me
165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
390 [NOT STARTED] — Research task: determine how a Dedekind-complete carrier can be p
  └─ 391 [NOT STARTED] — Design and land the frame-class scaffolding for a Dedekind-comple

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Reference Book

318 [NOT STARTED] — GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymo

### Kamp Completeness

377 [PARTIAL] — RESCOPED after research (report 01, machine-verified). The origin
378 [NOT STARTED] — DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding u

### Strong Completeness

361 [NOT STARTED] — Research + scoping for finite-context strong completeness (Contex
  └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet
  └─ 170 [NOT STARTED] — Dense (FrameClass.Dense) WEAK completeness green: make `completen
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet (see above)

## Tasks

### 403. Sweep literature corpus combining mark corruption
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: Task 389
- **Research**: [403_sweep_literature_corpus_combining_mark_corruption/reports/01_sweep-combining-mark-corruption.md]
- **Plan**: [403_sweep_literature_corpus_combining_mark_corruption/plans/01_sweep-combining-mark-corruption.md]
- **Summary**: [403_sweep_literature_corpus_combining_mark_corruption/summaries/01_sweep-combining-mark-corruption-summary.md]

**Description**: Corpus-wide follow-up from task 389's Rabinovich 2014 repair. Task 389 Phase 9's cheap detection sweep for bare U+0338 (COMBINING LONG SOLIDUS OVERLAY) survivors across ~/Projects/Literature/sources/**/*.md found 667 documents with surviving bare combining marks in the U+0300-U+036F range (not just Rabinovich, and not limited to U+0338 -- the sweep counted the whole combining-diacritics block). This means the Rabinovich-class defect (PyMuPDF's PRIMARY pymupdf4llm tier silently dropping a combining overlay mark, producing a semantically-inverted but readable '=' instead of '≠') may recur across a wide swath of the corpus wherever the same TeX-descended PDF toolchain produced the source. Task 389 Phase 2 already added a `compose_combining_overlays()` fix to the shared `.claude/scripts/literature-convert.sh` normalizer, but that only protects FUTURE conversions -- it does not retroactively repair the 667 already-converted documents. This task should: (1) re-run the sweep with a narrower U+0338-specific filter (the 667 figure sweeps the whole combining-diacritics block, which includes benign combining marks on accented Latin letters -- e.g. 'e'+U+0301 in Rabinovich's corrected doc; the true blast radius for the DANGEROUS negation-specific defect is likely much smaller and needs isolating); (2) for documents in the narrowed set, determine via spot-check whether the combining mark survives bare (relatively benign, just a rendering nuisance) or was silently dropped/inverted (dangerous, Rabinovich-class); (3) prioritize re-conversion (using the now-fixed `literature-convert.sh`) for any genuinely affected, load-bearing documents; (4) as a related but distinct improvement recorded by task 389's research: `literature-fidelity-audit.sh`'s word-ratio heuristic is structurally blind to character-level semantic inversions (it is what mis-certified Rabinovich as 'verified_conversion' in the first place) -- consider whether a cheap combining-mark/glyph-substitution detector could be added to that audit tool as a targeted, low-cost second signal, without expanding its scope into a full corpus-wide re-conversion.

---

### 402. Systematic mathlib naming upgrade
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 341, Task 131, Task 394
- **Research**: [402_systematic_mathlib_naming_upgrade/reports/01_mathlib-naming-upgrade-mechanism.md]
- **Plan**: [402_systematic_mathlib_naming_upgrade/plans/01_mathlib-naming-upgrade-migration.md]
- **Summary**: [402_systematic_mathlib_naming_upgrade/summaries/01_mathlib-naming-upgrade-summary.md]

**Description**: Systematically upgrade the repository to Mathlib naming conventions. This task COMBINES two previously-separate renames because they rewrite the SAME reference graph and must share one tooling pass, one verification strategy, and one set of green-build checkpoints. Doing them separately means paying a 24,000+ site rewrite and its verification twice, with each pass invalidating the other's baseline.

  PART A (absorbed from the former standalone directory-rename task): move `Theories/Bimodal/` to `FormalSystem/`; rename the root namespace `Bimodal` to `FormalSystem`; update `lakefile.lean` (`srcDir` Theories -> FormalSystem, `roots` Bimodal -> FormalSystem); update every `import` and every fully-qualified reference; update `README.md`, `Tests/`, and any other path references.

  PART B: migrate snake_case `def` names to lowerCamelCase so `defsWithUnderscore` reaches zero by genuine conformance, and delete the interim `scripts/nolints.json` suppression as the migration lands.

  PART C (absorbed from the former standalone naming-convention/bridge-cleanup task, which reached [RESEARCHED]): SEMANTIC renaming -- replace opaque abbreviations with descriptive Mathlib-style names, and clean up bridge/wrapper indirection.

PART C IS ALREADY RESEARCHED. Its team-research reports survive at `specs/175_naming_convention_and_bridge_cleanup/reports/` (four teammate reports plus `01_team-research.md`) and MUST be read before planning this part -- they audited all 152 active Lean files (91,153 lines) and CORRECTED several claims that the original charter asserted. Do not re-derive, and do not resurrect the corrected claims:
  - `Bridge.lean` is NOT a pure forwarding wrapper. Two teammates independently read the whole file and agree it holds 25-34 SUBSTANTIVE definitions (duality lemmas, monotonicity proofs, the P6 theorem). Only 3-4 are trivial: `dne` (wraps `Propositional.double_negation`, 7 refs), and `local_efq`/`local_lce`/`local_rce` (local re-implementations that exist to avoid circular imports), plus `lce_imp`/`rce_imp` duplicating Propositional versions. **Do NOT delete Bridge.lean wholesale.** Inline the 3-4 trivial wrappers; the substantive proofs stay or move to natural homes. Renaming the file to something descriptive (e.g. `MonotonicityDuality.lean`) is worth considering.
  - `bx_completeness` DOES NOT EXIST in source. The real theorem is `completeness_discrete` in `BXCanonical/Completeness.lean`; `bx_completeness` appears only in documentation. The existing `{result}_{frame_class}` pattern (`soundness_dense`, `completeness_discrete`) is already consistent and Mathlib-aligned -- no source rename, documentation references only.
  - The charter OVER-SCOPED the abbreviation list. Measured: `drm` and `tc_` are Boneyard-only; `fuc_` and `buc_` have ZERO occurrences anywhere; `cud` and `sdc` appear in comments only. **Only `bfmcs`, `dd_`, and `temp_` need active code changes.**
  - The real Part C work is concentrated in ~13 propositional abbreviation renames (257+ references), ~22 `temp_` -> `temporal_` renames, tombstone-comment purging, and a few trivial alias removals.

WHY PART C IS FOLDED IN RATHER THAN RUN SEPARATELY: a declaration's final name is a single decision combining THREE dimensions -- its semantics (Part C), its casing (Part B), and whether it is a `def` or a `theorem` (which determines which casing Mathlib demands). Deciding these in separate tasks means renaming the same declarations twice and re-verifying a 24,000-site reference graph twice. Concretely: Part C's proposed `ecq -> bot_of_and_neg` is correct for a `theorem` and WRONG for a `def`; the correct target for a `def` is `botOfAndNeg`. **Derive each target name once, from all three dimensions together, and rewrite once.**

Parts A and B touch DIFFERENT COMPONENTS of the same qualified identifier -- Part A changes the namespace prefix, Part B changes the final component -- so a single resolved-reference rewrite can apply both at once. Research must decide whether to apply them in one atomic pass or stage them, but the tooling and reference resolution MUST be shared.

PREREQUISITE STATE (established by the predecessor naming task; re-measure, since counts drift):
  - 38 `linter.defProp` declarations were already converted `def` -> `theorem`, removing 28 findings automatically.
  - The residual ~860 `defsWithUnderscore` findings are suppressed by a filtered `scripts/nolints.json`. Those rows are a CHECKPOINT, not an asset -- they are expected to be DELETED as this migration lands, not maintained.
  - `docs/development/NAMING_CONVENTION_DEVIATION.md` documents the interim state, is explicitly framed as having a known successor (this task), and carries the cost figures below.

COSTING FOR PART B, measured from resolved `.ilean` references, NOT grep:
  - 24,364 resolved usages across 258 of 300 modules (86% of the project)
  - 398 of 873 names (45.6%) are PROPER PREFIXES of another project identifier
  - a naive substring pass would touch 68,076 sites, of which 46.4% would be WRONG
  - churn is concentrated in DATA names, not the `Theorems/` layer: `Syntax/Formula.lean`'s 12 data names carry 4,929 usages, roughly 5x the entire `Theorems/` layer. Sizing this task from the `Theorems/` findings would badly understate it.

THE CENTRAL HAZARD is identifier-prefix collision. Position-anchored replacement driven by RESOLVED REFERENCES is mandatory; global substring replace is disqualified. A sibling task demonstrated the failure mode concretely: replacing `List.take_succ` silently corrupted `List.take_succ_cons`, a distinct non-deprecated lemma, surfacing as a `rewrite` failure a line away. At 45.6% prefix overlap that is the norm here, not an edge case. Part A carries the same hazard at namespace level.

DEPRECATION SHIMS MEASURABLY BACKFIRE: adding one `@[deprecated]` alias raised `defsWithUnderscore` 860 -> 861, because the alias is itself a snake_case def. Backward-compatibility aliases need their own suppression story or a different mechanism.

ROOT CAUSE CONTEXT FOR PART B: `DerivationTree` is Type-valued (`ProofSystem/Derivation.lean`), so derived theorems must be `def` rather than `theorem`, and Mathlib demands lowerCamelCase for defs while allowing snake_case for theorems. Only 184 of 888 findings (20.7%) are actually `DerivationTree`-valued -- but within tier-1 it is 135/189, all in `Theorems/`. The other 753 are 554 ordinary data defs, 121 `-> Prop` predicates, 29 proofs. A `Prop` wrapper already exists (`ProofSystem/Derivable.lean`, `Nonempty (DerivationTree ...)`) but restating against it removes only 135 findings and permanently doubles the combinator API, because `Automation/` consumes those combinators to BUILD trees and needs `DerivationTree.height` (68 references). Rejected as a substitute for renaming.

RESEARCH MUST DETERMINE (the naming POLICY is settled -- full Mathlib conformance. These are mechanism questions):
  - The rewrite MECHANISM. Assess Lean/Mathlib's own rename facilities against an `.ilean`-driven resolved-reference rewriter. The VERIFICATION story matters more than the edit story: how do we prove a 24,000+ site rewrite is complete and correct?
  - Whether Parts A and B land in one atomic pass or are staged, and whether staging can keep `lake build` green at every commit. A partial rename leaving dangling references is worse than no rename.
  - Ordering: if staged, Part A (namespace, mechanical) should precede Part B (declaration casing, expensive), never the reverse -- a namespace rename applied after the casing rewrite churns straight back through all 24,364 sites.
  - Whether `Tests/` and `Boneyard/` are in or out. `Boneyard/` is unbuilt and inert; renaming it buys nothing, but leaving it stale costs nothing either. Decide deliberately, not by accident.
  - The 121 `-> Prop` predicates: some may be convertible to `theorem` on their own merits (as the 38 already were), which removes them from the linter's scope ENTIRELY and is strictly better than renaming them. Establish how many.

SEQUENCING AGAINST STRUCTURAL WORK (hard constraint, user decision): this task runs AFTER the structural refactoring completes -- the SharedWitness carrier-layer split and the module-organization restructure. Rationale: both MOVE FILES AND DECLARATIONS. Renaming first and restructuring second would churn the expensive 24,000-site rewrite a second time and invalidate its verification baseline. Rename ONCE, over a settled structure.

VERIFICATION BAR: `lake build` green with no new errors, `BimodalTest` green, and the sole live `sorry` count unchanged -- locate it BY CONTENT in `Metalogic/WeakCanonical/Transfer.lean`, never by line number, it drifts. NOTE `defsWithUnderscore` emits NOTHING during `lake build`, and CI runs `lean-action` with `lint: false`, so a green build is NOT evidence for this category. Every count must come from an explicit `lake exe runLinter Bimodal`. As `nolints.json` rows are deleted the count must reach 0 by genuine conformance, not because the file still masks them.

TOOLING: reuse the gated harnesses at `specs/400_clear_lean_v433_deprecation_warnings/tools/` (`lintlib.py`, `fixers.py`, `gate.py`) and `runlinter.py` from `specs/399_mathlib_linter_compliance_tier3_metalogic/tools/`. Solved traps: raw `lean` emits `PATH:L:C: severity: msg` while lake emits `severity: PATH:L:C: msg`; `LINTER FAILED` comes in two row shapes (positioned + positionless `#check`) and appears mid-message; `run_lint` needs `-DautoImplicit=false` or it elaborates more permissively than `lake build`.

SCOPE DISCIPLINE: do not re-open the naming policy -- full Mathlib conformance is decided. Research the mechanism, the staging, and the TARGET-NAME DERIVATION RULE (semantics + casing + def/theorem status, resolved together per declaration), not whether to do it.

---

### 391. Frameclass dedekind scaffolding
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 390, Task 291

**Description**: Design and land the frame-class scaffolding for a Dedekind-complete extension, once the carrier-construction research resolves GO.

PROBLEM 1 -- the frame-class order does not admit a Dedekind tier. Theories/Bimodal/ProofSystem/Axioms.lean:424-427 defines "inductive FrameClass where | Base | Dense | Discrete". The LE instance at :430 gives Base <= everything, with Dense and Discrete reflexive-only and mutually incomparable; PartialOrder is at :440. A Dedekind-complete order is a fortiori DENSE, so it validates both the density axiom (Axioms.lean:387) and dense_indicator (:399). A Dedekind constructor therefore sits ABOVE Dense, which the current three-element order does not anticipate: adding it is not a fresh incomparable leaf but a genuine change to the order's shape. FrameClass is referenced 1649 times across 118 live files, and the gate ax.minFrameClass <= fc is enforced structurally in DerivationTree's axiom constructor (ProofSystem/Derivation.lean:92), upstream of every derivation and soundness proof. Expect the LE and PartialOrder proofs to need real work, not just an extra case; the existing proofs are "cases <;> simp_all" and may or may not survive.

PROBLEM 2 -- there is no axiom characterizing Dedekind completeness. Axiom.minFrameClass (Axioms.lean:458) is the single source of truth for axiom-frame-class compatibility and currently maps only density and dense_indicator to Dense, and prior_UZ / prior_SZ / z1 to Discrete. No candidate Dedekind axiom exists in the Axiom inductive. The characterizing axiom comes out of the carrier-construction research; this task lands it.

SCOPE (each item is a phase boundary, size accordingly):
1. FrameClass.Dedekind constructor plus reworked LE / DecidableRel / PartialOrder instances, preserving the minFrameClass <= fc invariant. Full build green.
2. The characterizing axiom in the Axiom inductive plus its minFrameClass row.
3. valid_dedekind in Theories/Bimodal/Semantics/Validity.lean alongside valid (:73), valid_dense (:162), valid_discrete (:180), plus the valid -> valid_dedekind bridge mirroring :193 and :200.
4. Optionally a DedekindTemporalFrame marker class in Theories/Bimodal/FrameConditions/FrameClass.lean alongside LinearTemporalFrame (:82), SerialFrame (:97), DenseTemporalFrame (:118), DiscreteTemporalFrame (:142). NOTE these marker classes are a side-car: the live completeness and soundness theorems do NOT consume them, they consume the raw instance-binder validity predicates in Semantics/Validity.lean. Do not mistake the side-car for the load-bearing layer.
5. soundness_dedekind plus per-axiom validity lemmas in Theories/Bimodal/Metalogic/Soundness.lean, alongside soundness (:1023), soundness_dense (:1193), soundness_discrete (:1338). axiom_swap_valid_general (SoundnessLemmas/FrameClassVariants.lean:34) is frame-class-free and directly reusable.
The completeness theorem itself is NOT in this task's scope -- it depends on the countermodel construction, which the research task must deliver first.

TEMPLATE TO FOLLOW. All three live completeness theorems sit in Metalogic/BXCanonical/Completeness.lean (completeness :181, completeness_dense :247, completeness_discrete :288) and share one five-move contrapositive: by_contra into neg_consistent_of_not_derivable (:66, generic in fc); set_lindenbaum to an MCS; split on box(not U(top,bot)) via negation_complete; a frame-class-specific countermodel in the matching branch; and a frame-class-specific proof-theoretic elimination of the non-matching branch. Step 5 is where a frame class "pays for itself" -- completeness_dense closes its branch from dense_indicator (:263-268), completeness_discrete derives U(top,bot) from prior_UZ plus left_mono_until_G plus Modal-T (:300-342). Note discrete_box_necessity is a BASE axiom, which is what lets mcs_mixed_case_absurd work at any frame class -- a Dedekind class inherits it free.

---

### 390. Dedekind carrier construction research
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 389

**Description**: Research task: determine how a Dedekind-complete carrier can be produced for the canonical-model construction. This is the mathematical crux of the Dedekind-complete completeness effort and MUST resolve before any implementation plan is written.

THE OBSTRUCTION. specs/ROADMAP.md:1477 describes the chronicle limit domain X as a COUNTABLE linear order (sparse X subset of Rat for Base, Rat for Dense, order-isomorphic to Int for Discrete). But a Dedekind-complete, densely ordered, unbounded linear order is order-isomorphic to the reals, hence uncountable. So the existing chronicle / canonical-model route cannot directly yield a Dedekind-complete carrier.
Corroborating anchors: specs/ROADMAP.md:317-320 warns that dense domains such as Rat are WRONG for general completeness (GGp -> Gp is valid on Rat but not derivable in BX; Burgess uses a sparse X subset of Rat). specs/ROADMAP.md:1414's "Representation Theorem Goal" enumerates D' = Rat (base), Rat (dense), Int (discrete) and has NO reals row. Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean:44 states flatly that no reals OrderedMonadicStructure is constructed here or anywhere in this tree.

QUESTIONS TO ANSWER, with literature grounding (see the Dedekind literature-remediation task):
1. Does the intended semantics quantify over Dedekind-complete ORDERS, or over Dedekind-complete orders arising as duration groups? The live validity predicates take instance binders on a duration type D (Theories/Bimodal/Semantics/Validity.lean:73 valid, :162 valid_dense, :180 valid_discrete). Establish what the Dedekind analogue's binder list must be.
2. Is a Dedekind completion of the countable limit domain sound for the truth lemma -- i.e. does adding limit points preserve the coherence conditions the BFMCS bundle requires? If not, why not, and what is the obstruction precisely.
3. What does the literature actually do? Reynolds 1992 axiomatizes Until/Since over the reals; GHR94 Ch.10 section 10.3 treats separation over Dedekind-complete flows. Extract the construction each uses for the carrier and state whether it is a completion, a direct construction, or a representation argument.
4. Is the target completeness result even true for the intended axiom set, and what axiom characterizes Dedekind completeness? No candidate exists in the Axiom inductive today.

CONSTRAINTS. Standing ROADMAP anti-patterns apply: do NOT attempt a direct IsSuccArchimedean proof bypassing chronicle_gap_contradiction; do NOT attempt the "discrete bypass"; decidability-based completeness is explicitly excluded as a path to the representation theorem.
Reusable scaffolding that a solution must plug into (all live, sorry-free, generic in the duration type D and the frame class fc): ParametricCanonicalTaskFrame (Algebraic/ParametricCanonical.lean:200), ParametricCanonicalTaskModel (Algebraic/ParametricTruthLemma.lean:101), parametric_canonical_truth_lemma (:226), restricted_parametric_shifted_truth_lemma (Algebraic/RestrictedParametricTruthLemma.lean:109), and the single funnel both live countermodels go through, fully_restricted_parametric_completeness_from_neg_membership (:394). Also neg_consistent_of_not_derivable (Metalogic/BXCanonical/Completeness.lean:66, generic in fc) and mcs_mixed_case_absurd (Chronicle/MCSMixedCase.lean:34, takes fc explicitly). structure Gap (Metalogic/WeakCanonical/EFGames/Defs.lean:230) is the existing object with the right shape for phrasing "no Dedekind gaps" as a frame condition.
Related warning from the existing tree: Metalogic/BXCanonical/Completeness.lean:168-179 documents why the general completeness theorem still carries sorryAx -- a Base-MCS is not automatically Discrete-consistent, so the sorry-free Reynolds pipeline cannot be reused. A Dedekind variant will hit the structurally identical problem and must build a countermodel from an MCS of its own class.
DELIVERABLE: a research report with a GO / NO-GO recommendation and, if GO, the carrier construction to be formalized. Dispatch with --lit.

---

### 378. Rebase section5 onto faithful dedekind carrier
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: Task 341

**Description**: DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding user directive: "If it's not on the critical path stub it out to leave behind for later when we do the dedicated complete proof system"). Re-base Rabinovich's Section 5 onto the FAITHFUL Dedekind carrier. THIS IS THE "dedicated complete proof system" WORK -- do not dispatch it as a side quest.

GOAL AND VALUE (supersedes the original deferral framing; do not re-litigate the deferral itself -- the reasoning below was correct for the goal in force when this task was written, and is now superseded by a changed project goal, not refuted). The project goal is now a genuine Dedekind-complete FRAME CLASS with its own completeness theorem, with this Rabinovich Section 5 re-base as a FIDELITY PREREQUISITE FEEDING that frame-class completeness work -- i.e. 378 is upstream of, and blocks, the frame-class theorem, not a side branch of it. Under this goal the value calculus inverts: a Dedekind-complete frame class has consumers that CAN observe the difference between HasAttainedINF and HasDedekindINF, because attained INF/SUP is NOT free on a general Dedekind-complete chain the way it is on Prior structures (prior_hasAttainedINF, PriorINF.lean:224, via the UZ axiom). hasDefinableINF_excludes_kplus (Kamp/Lemma53.lean:282, axiom-clean, machine-checked) proves the currently-landed HasDefinableINF carrier DELETES the paper's disjunct (2) -- exactly the content a Dedekind-complete class cannot afford to lose. This re-base is therefore load-bearing for the frame-class theorem, not fidelity-only.

ALREADY LANDED AND GREEN -- BUILD ON THIS, DO NOT REBUILD IT:
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean -- LIVE and CI-protected (import edge from NfMultiAnchorBridge), sorry-free, all decls axiom-clean {propext, Classical.choice, Quot.sound}. Contains: HasDedekindINF/HasDedekindSUP (Rabinovich eq (5.2) stated faithfully as the disjunction of the paper's `Subcase r0 = z0` = K+(P1)(z0) and eq (5.2) verbatim, PDF p.8); the FOUR compatibility shims HasAttainedINF/HasDefinableINF.toHasDedekindINF + SUP duals (HasDefinableINF.toHasDedekindINF discharges the r0<=z1 vs r0<z1 reconciliation from the occurrence hypothesis rather than assuming it); prior_hasDedekindINF/prior_hasDedekindSUP; and the strictness delta hasDedekindINF_admits_kplus_shape + hasDefinableINF_incompatible_with_kplus. The shims are what a re-base needs FIRST -- they let the faithful carrier be consumed wherever the landed ones are supplied, so the re-base need NOT discard EANegationFix/.
- TemporalPred.disj (ExistsForallNF.lean) + TemporalPred.eval_at_disj (VecEAClosure.lean) -- the point-type primitive for eq (5.2)'s (P1(r0) v K+(P1)(r0)). Sorry-free, axiom-clean.
- Section5Correspondence.lean -- page-cited Section 5 correspondence table (PDF pp.7-11) + prop42_contentful_of_attained. Sorry-free, axiom-clean. READ THIS FIRST: Section 5 is ALREADY TRANSCRIBED in EANegationFix/ under names that mention neither Rabinovich nor lemma numbers. It was grep-discoverable for thirteen months and was STILL re-planned from scratch by successive agents, one of which marked six present, sorry-free rows ABSENT.
- lemma53 sorry-free at the attained carrier; hasDefinableINF_excludes_kplus (Lemma53.lean:282, axiom-clean) -- machine-proves HasDefinableINF DELETES the paper's disjunct (2); the whole reason the faithful carrier is needed.
- The EANegationFix/ tree -- live, correct at the attained carrier.

THE DEFERRED WORK (plan v2 Phases 6-8 carry full task breakdowns, verification gates, and a written GO/NO-GO kill criterion -- START THERE: specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md. Phase 6's task list is now LARGELY DONE -- the carrier and shims above have landed since the plan was written; RE-SCOPE DISPATCH TO PHASES 7-8 ONLY):
1. Lemma 5.3 (PDF p.8) -- negChainOnFaithful over HasDedekindINF, restoring the PRINTED THREE-disjunct O_n+1: (1) (Ay)^{<z1}_{>z0}-P1(y); (2) K+(P1)(z0) ^ O_n(P2..Pn,z0,z1) <-- DELETED by the landed attained simplification; (3) (Er0)^{<z1}_{>z0}(INF(z0,r0,z1,P1) ^ O_n(P2..Pn,r0,z1)). The landed negChainOn (EANegationFix/OnBuilder.lean:149) truncates to TWO. Result type MUST be VVecEA2, NOT VBracketFormula: disjunct (2) conjoins the endpoint predicate K+(P1) at z0, which VBracketFormula cannot carry. THIS PHASE IS THE GO/NO-GO GATE AND THE SIZING CANARY for the rest -- if it does not close in ONE dispatch, that is a sizing signal to RE-SPLIT, not grounds for a second dispatch on the same target.
2. Lemma 5.1 (PDF pp.9-10) -- re-base BracketFormula.negFix_iff (EANegationFix/NegFix.lean:669).
3. Prop 4.2 (PDF p.6) -- re-base VVecEA2.negFix_iff (EANegationFix/VecEANegFix.lean:164), hence prop42_contentful_of_attained, off the attained pin. LARGEST AND LEAST CERTAIN: negFixList (NegFix.lean:424) is a 681-line recursion whose Case 2/Case 3 gates are built around the ATTAINED pin; admitting the K+ limit case adds a third gate to each. Phase 8 does NOT dispatch until the Lemma 5.3 gate resolves GO.

BINDING CONSTRAINTS CARRIED FORWARD FROM 377 (unchanged, do not weaken):
- THREE-STRIKES PROHIBITION (standing): the model-INDEPENDENT Prop 4.2 backward direction at the BracketFormula level is ruled UNFIXABLE (task 377 report 18 sec 4.3; Boneyard/NegationIndep.lean:346-364). EANegation.lean:1090 and :1249 ARE that target -- DO NOT TOUCH THEM. BracketFormula.negFix_iff (NegFix.lean:669) is INF-ANCHORED and CONFIRMS the ruling; never cite it as license for a fourth bare attempt.
- AMENDED SORRY GATE (user-approved, committed e74f129d1): the ONLY live sorries permitted are KampPrior.lean:520, EANegation.lean:1090, EANegation.lean:1249. Add ZERO. KampPrior:520 is task 358's P17 frozen-interface gap by its own in-code note (:507-518 says "Do NOT discharge here"). [STALENESS NOTE, preserved for the record, not a license to weaken this gate unilaterally: as of this task's last research pass (2026-07-25), none of these three sites contain a live sorry -- KampPrior.lean's k>=2 residual was retired by task 379 Phase 5 (kampArm_zeta, 2026-07-24) and EANegation.lean:1090/:1249 were retired to Boneyard/EANegationVBracketBackward.lean by task 359 phase 2 (2026-07-24). `lean-sorry-census.sh` on Kamp/ reports zero live sorries. If this task dispatches and finds the same, treat the gate as vacuously satisfied (zero live sorries is trivially "no more than the permitted three"), not as evidence the gate was violated, and flag the state.json wording for a follow-up correction rather than re-deriving the history above.]
- EXTENDED NON-VACUITY RULE: if you land a carrier, STATE WHAT IT EXCLUDES. An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous conclusion does -- that pattern recurred THREE times undetected on this task. The strengthening chain: Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF (landed).
- USER'S PRIMARY CONSTRAINT: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)."
- CITE RABINOVICH BY PDF PAGE ONLY: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf (Read supports PDFs via `pages`). The companion .md is CORRUPT (inverts k!=m at md:199) -- NEVER ground truth. No chunk_00NN-style citations.
- PRESERVE -- DO NOT DELETE FILES. ~29% of NfMultiAnchorBridge is load-bearing via kampArm_*_k0/_k1; frozen byte-identity surfaces sit INSIDE live files (surgical decl excision only, never file deletion). Do NOT delete hasDefinableINF_excludes_kplus, lemma53's Basis, or anything in EANegationFix/.
- LIVENESS: `lake build BoneyardArchive` passes VACUOUSLY (#exit line 5 precedes imports line 7) -- NEVER evidence of health. Kamp/Boneyard/* is covered by NO glob and compiled by NOTHING in CI. ONLY reachability from Theories/Bimodal.lean decides liveness. This is why DedekindINF.lean was landed LIVE rather than parked in Boneyard, and why the deferred targets were recorded as PROSE rather than as sorry-bodied theorems in a dead module.
- SORRY CENSUS MUST BE TACTIC-POSITION, never `grep -c`: use .claude/scripts/lean-sorry-census.sh. [Baseline note superseded: at last check (2026-07-25) the census reports 0 live sorries in Kamp/ (4 dead, all in Boneyard/). Re-run the script at dispatch time rather than trusting either this count or the plan's original "5 across Kamp/" baseline -- both are point-in-time snapshots.] NOTE: the script's --cross-check reports a structural MISMATCH when the target is a subdirectory (the stripper is scoped to the target; the compiler's `lake build` is always whole-project, and names DECLARATION start lines where the stripper names TACTIC positions). Within Kamp/ the compiler's 3 sorry-using decls (KampPrior.lean:346, EANegation.lean:834, EANegation.lean:1129) correspond exactly to the census's 3 live tactic positions. Not a defect.

BASELINE METRICS (HISTORICAL, post-377-phase-6; re-measure at dispatch): full `lake build` EXIT 0 at 1766 jobs / 239 live modules under Theories/. Every new live module adds exactly +1 to each.

DISPATCH GUIDANCE: --hard --lit. Expect to need its own plan; plan v2 Phases 6-8 are a strong starting point but were written before the carrier and shims landed, so their Phase 6 task list is now largely DONE -- re-scope to Phases 7-8 only.

---

### 377. Transcribe rabinovich faithful nf encoding
- **Effort**: large
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None
- **Research**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/reports/01_faithful-nf-encoding-ruling.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md]
- **Plan**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/plans/01_contentful-prop42-section5.md]
- **Summary**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/summaries/02_section5-correspondence-guard-summary.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/summaries/02_section5-exists-carrier-rebase-summary.md]

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
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/02_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/03_divergence-audit-joint-channel.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/04_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/05_remaining-k2-gate-architecture.md]
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/04_corrected-k2-carrier-gate-v4.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/05_corrected-k2-carrier-gate-v5.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/06_corrected-k2-carrier-gate-v6-redesign.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/01_corrected-k2-carrier-fi-chain.md]
- **Summary**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/01_corrected-k2-carrier-fi-chain-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/06_corrected-k2-carrier-gate-v6-redesign-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase11-n2-singleton-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase7-sepbody-carrier-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/08_phase8-joint-extraction-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/09_phase9-o4-verdict-summary.md]

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

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
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
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
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

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 402
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

**Description**: Apply validity-intro and truth-simp macros to the soundness layer.

RE-SCOPED 2026-07-26 by the codebase tactic survey (specs/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.3). The original charter targeted Theorems/ using tm_prove. Theorems/ is 7,017 lines - 3.8% of the tree, half the relative share the 2026-05 research assumed - and is sorry-free and stable; tm_prove (task 192) is abandoned; and the search-family tactics it would have fallen back on have zero adoption. The task keeps its kind (an application pass that reduces existing proof text) and replaces its target and its instrument.

Define a small family of syntactic macros and apply them mechanically to the three files that concentrate the codebase two highest-frequency verbatim proof repetitions. This is an APPLICATION task: the deliverable is measured reduction in existing proof text at named files, not the existence of a macro.

Macros to define (single-line `macro ... : tactic` declarations - no elaboration, no goal inspection):
  - intros_validity           for `intro F M Omega _h_sc τ _h_mem t`
  - intros_validity_framed    for the frame-condition-prefixed variant
  - simp_truth                for the recurring `simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` bundle
  - unfold_validity           composing intros_validity with simp_truth, for sites where the two appear consecutively

Measured target sites (2026-07-26, Boneyard/ excluded):
  - Metalogic/SoundnessLemmas/DenseValidity.lean      - 92 `intro F M Omega`, 54 `simp only [truth_at`
  - Metalogic/SoundnessLemmas/FrameClassVariants.lean - 56 `intro F M Omega`, 30 `simp only [truth_at`
  - Metalogic/Soundness.lean                          - 47 `simp only [truth_at`

DO BOTH MACRO GROUPS AS ONE PASS over the same files, not two. Splitting them edits the same two files twice and forfeits the unfold_validity collapse.

COMPLETION CRITERION: `intro F M Omega` occurrences in the two SoundnessLemmas/ files reach zero; `simp only [truth_at` occurrences across the three files fall by at least 80%; lake build green; executable sorry count unchanged at 1, located BY CONTENT in Metalogic/WeakCanonical/Transfer.lean, never by line number. A task that ends with working macros and unchanged proof text has FAILED.

EXPLICITLY OUT OF SCOPE: Theorems/ refactoring, tm_prove, modal_search and every other search-family tactic, and any new elaborated tactic. See the survey report section 5 for the measured evidence (38 real proof-site invocations across ~5,800 lines of proof automation, all 38 in one file).

WHY THE DEPENDENCY ON THE SYSTEMATIC MATHLIB NAMING UPGRADE: this task rewrites proof bodies at roughly 330 sites, and that task rewrites the same reference graph at 24,364 sites while moving every file from Theories/Bimodal/ to FormalSystem/. A mass proof rewrite must not race a mass rename; run this after it lands, never concurrently. (Post-upgrade the file_scope paths live under FormalSystem/.)

Inventory groups drawn on: survey report section 4.2 groups 2 (intros_validity, score 153) and 3 (simp_truth, score 72.7).

---

### 180. Line limit compliance and publication residue
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 292, Task 402
- **Research**: [180_line_limit_compliance_and_publication_residue/reports/01_line-limit-compliance-residue.md]
- **Plan**: [180_line_limit_compliance_and_publication_residue/plans/01_line-limit-compliance-residue.md]
- **Summary**: [180_line_limit_compliance_and_publication_residue/summaries/01_line-limit-compliance-residue-summary.md]

**Description**: Close out the publication-quality residue: line-length compliance in Automation/, plus a post-rename re-verification sweep.

THIS TASK WAS RE-SCOPED 2026-07-26 AFTER MEASUREMENT. It was originally chartered as three items -- copyright headers, universe polymorphism, and line limits. Two of the three are already resolved, and asserting otherwise would send an agent looking for work that does not exist:

  COPYRIGHT HEADERS -- DONE. Measured: 277 of 277 live .lean files carry a
  Copyright line in their first three lines. Its predecessor task completed
  this. NOTHING TO DO. Verify the count still holds; do not re-add headers.

  UNIVERSE POLYMORPHISM -- EMPTY SET. Established by the naming-convention
  research: there are no universe-polymorphism findings at all. No universe
  linter exists in this toolchain, Semantics/ already uses `(D : Type*)`
  consistently, and Validity.lean documents its single monomorphization as a
  deliberate choice. NOTHING TO DO. Do not manufacture findings here.

  LINE LIMITS -- THE ONLY REAL WORK. Measured: ZERO violations (>100 chars)
  anywhere outside Automation/. The sibling linter-compliance tasks took
  tier-1, tier-2 and tier-3 to zero and hold them there. Automation/ was
  explicitly out of scope for every one of them and carries 312 violations:
    ProofStepExport 65, DatasetGenerator 51, FormulaMutator 44,
    FormulaEnumerator 42, DatasetExport 30, ProofFirstBenchmark 15,
    Tactics/Commands 14, TableauProofStepPipeline 13, and a tail.

SCOPE:
  (1) Clear the 312 Automation/ line-length violations.
  (2) RE-VERIFY line limits across the whole live tree afterwards. This is why
      the task is sequenced after the naming upgrade: renaming a declaration
      changes its length at every use site, so `box_conj_iff` -> `boxConjIff`
      can push previously-compliant lines over the limit. A tree that was at
      zero before the rename is not necessarily at zero after it.
  (3) Confirm the copyright-header count and the empty universe-polymorphism
      finding still hold, and record both as verified rather than as work.

TOOLING: reuse the gated harnesses at specs/400_clear_lean_v433_deprecation_warnings/tools/ (lintlib.py, fixers.py, gate.py). Their fixers already encode the line-breaking hazards learned the hard way: never leave `return`/`pure`/`throw`/`yield` last on a line (do-notation's `return` takes an optional argument and silently reparses); never split a clause keyword from its operand in either direction (`simp only [...]` then `at h`, or `by rw` then `[...]`, both close the tactic block); never break inside an `at h1 h2 ...` location clause; a continuation inside a tactic block opened mid-line by `by` must be indented past the `by`'s own column, not indent+4; `/--` and `-- ` both contain a literal `--`, so a naive trailing-comment guard refuses to wrap any comment line. Mathlib's scripts/fix_long_lines.py only cuts at commas and was measured at 25.1% applicability here -- expect to hand-fix roughly three quarters.

VERIFICATION: `lake build` green with no new errors, `BimodalTest` green, sole live `sorry` count unchanged (locate BY CONTENT). Note `linter.style.longLine` is NEVER reported by `lake build` -- gating on its linter category count is vacuous. Count violations directly from source (`awk 'length>100'`) or via `-Dlinter.mathlibStandardSet=true`.

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-a-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-b-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-c-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-d-findings.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 175. Naming convention and bridge cleanup
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 402
- **Research**:
  - [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-a-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-b-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-c-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-d-findings.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

CASING CONSTRAINT (added after the systematic Mathlib naming upgrade was scoped): the target names listed above are SNAKE_CASE, which is correct for `theorem`s but WRONG for `def`s under Mathlib convention -- and this repository has ~860 declarations that are forced to be `def` because `DerivationTree` is Type-valued. Any declaration that remains a `def` must receive a lowerCamelCase semantic name (`botOfAndNeg`, not `bot_of_and_neg`), or this task will reintroduce exactly the `defsWithUnderscore` violations its predecessor eliminated. Do not choose a target name without first establishing whether the declaration is a `def` or a `theorem`; where a `-> Prop` declaration can legitimately become a `theorem`, doing so is strictly better than renaming it, because it leaves the linter's scope entirely.

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

### 161. Rename theories bimodal to formalsystem
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 291

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 131. Refactor module organization
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 341
- **Research**: [131_refactor_module_organization/reports/01_module-reorganization-research.md]
- **Plan**: [131_refactor_module_organization/plans/01_module-reorganization.md]
- **Summary**: [131_refactor_module_organization/summaries/01_module-reorganization-summary.md]

**Description**: Restructure the Lean source hierarchy for clean APIs and documentation.

MEASURED STRUCTURE 2026-07-26 (this charter previously stated "130 live .lean files across 7 top-level directories" and enumerated a Metalogic/ layout that no longer exists -- both were wrong; drive from the figures here and RE-MEASURE at start, since predecessors move files):

  277 live .lean files (excluding Boneyard/), i.e. 2.1x the stale 130.

  Top-level under Theories/Bimodal/ -- 12 entries, not 7:
    Automation, Boneyard, Examples, FrameConditions, Metalogic, ProofSystem,
    Semantics, Syntax, Theorems, plus the non-Lean docs, latex, typst.

  Metalogic/ subdirectories -- 8:
    Algebraic, Bundle, BXCanonical, Core, Decidability, Relational,
    SoundnessLemmas, WeakCanonical.
    NOTE: `ConservativeExtension` no longer exists -- do not plan around it.
    NOTE: `WeakCanonical` is the LARGEST subtree in the repository (the entire
    Kamp/ development, including the 41,565-line NfMultiAnchorBridge/) and the
    previous charter omitted it entirely. Any reorganization proposal that does
    not account for WeakCanonical is not a proposal for this codebase.
    NOTE: `SoundnessLemmas` is now a DIRECTORY, not the loose file the old
    charter listed.

  Metalogic/ loose files -- 5: Completeness.lean, Decidability.lean,
    Metalogic.lean, Soundness.lean, WeakCanonical.lean.
    The old charter's DenseSoundness.lean and DiscreteSoundness.lean are gone.

GOALS (unchanged in intent, restated against the real structure):
  (1) Reorganize Metalogic/ into a clearer hierarchy -- group soundness files, group completeness files, and clarify the relationship between BXCanonical (chronicle approach), WeakCanonical (Kamp/Reynolds approach), and Algebraic (parametric approach). This three-way relationship, not the two-way one the old charter described, is the central organizing question.
  (2) Add module-level documentation: docstrings on namespace declarations, module descriptions at file tops.
  (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory.
  (4) Evaluate whether FrameConditions/ should merge into Metalogic/ or remain separate.
  (5) Audit Boneyard/ organization -- note it has grown to 92 files / 58,476 lines following recent archival work, not the 45 files the old charter stated.
  (6) Decide whether docs/, latex/, and typst/ remain under the Lean source root or move to the project root.

COORDINATION WITH THE NAMING UPGRADE (hard constraint): the systematic Mathlib naming upgrade depends on THIS task and runs after it, because renaming 24,000+ reference sites over a structure that is about to change would churn the rewrite twice. Two consequences: (a) goal (6) above overlaps that task's directory rename -- decide the docs/latex/typst placement HERE and leave the source-root rename to that task; (b) do not rename declarations under this task. Move files, not names.

VERIFICATION: `lake build` green with no new errors at every phase boundary, `BimodalTest` green, and the sole live `sorry` count unchanged -- locate it BY CONTENT in Metalogic/WeakCanonical/Transfer.lean, never by line number. Import updates must be complete: a partial move leaving dangling imports is worse than no move.

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
- **Dependencies**: None

**Description**: Verify and record the final axiom/sorry status of the headline metalogical results, then close.

RE-SCOPED 2026-07-26. Most of this task's original content has been ANSWERED by the archivable-sorry review, which resolved the question definitively rather than partially. Do not re-derive it:

  - The discrete-case sorryAx trace is COMPLETE. `WeakCanonical.countermodel_discrete`
    (Metalogic/WeakCanonical/Transfer.lean) is the SOLE sorryAx source reaching
    `BXCanonical.completeness`. This was established by a whole-environment
    `Lean.collectAxioms` scan, not by inference from names or file locations.
  - The tainted set is exactly 3 declarations: countermodel_discrete,
    completeness, completeness'. It was 47 before the archival.
  - `completeness_dense` and `completeness_discrete` are CLEAN.
  - The BX chronicle path named in the original charter
    (dd_countermodel_chronicle_discrete -> succ_embed_surjective ->
    chronicle_gap_contradiction) was dead code and has been ARCHIVED to
    Theories/Bimodal/Boneyard/DeadChronicleGapElimination/. It is no longer in
    the build, so there is nothing left to trace along that path.
  - The dense and mixed chronicle countermodels were already confirmed
    sorry-free.

WHAT REMAINS -- a narrow confirmation pass, not an investigation:
  (1) Re-run `#print axioms` (or lean_verify) on the headline theorems and
      confirm the state above still holds. Record the result.
  (2) Confirm the live sorry count is exactly 1, located BY CONTENT in
      Metalogic/WeakCanonical/Transfer.lean -- never by line number, it drifts
      with every edit to that file.
  (3) Record, in a durable location, that discharging countermodel_discrete is a
      genuine open construction rather than an oversight: the clean
      `countermodel_discrete_reynolds_v2` requires a Discrete-MCS, and the old
      BX route is PROVABLY unavailable (succ_cofinal is refuted by the Z+Z
      counterexample). Proving it belongs to its own task.

METHODOLOGY WARNING, established the hard way: do NOT build a reverse-dependency
graph over `ConstantInfo.value?` to decide what depends on what. Under Lean
4.33's module system imported THEOREM bodies are unavailable, so such a graph
silently under-reports -- it wrongly showed countermodel_discrete as having zero
consumers, which would have led to archiving the one sorry that breaks
completeness. Use `Lean.collectAxioms` plus textual analysis instead.

EXPECTED OUTCOME: this task most likely closes as verified-complete. If step (1)
or (2) diverges from the state above, that divergence IS the finding and should
be reported prominently rather than silently reconciled.
