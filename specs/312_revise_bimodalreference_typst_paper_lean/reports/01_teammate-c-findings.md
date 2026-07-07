# Teammate C (Critic) Findings — Task 312 Scoping Review

## Key Findings

### 1. Scope ambiguity is real and load-bearing

`BimodalReference.typ` is titled "Bimodal Reference Manual," subtitled "A Logic for Tense and
Modality," with a title-page link to the paper labeled **"Primary Reference"** — i.e. the paper is
context/citation, not a template to mirror line-for-line. Its own README describes it as a
"parallel port" of `Theories/Bimodal/latex/`, both supposedly "produc[ing] visually similar
output." The abstract says it documents the logic "as implemented in the #proofchecker project."

The paper (`possible_worlds.tex`, 3473 lines) is a philosophy-journal submission: ~1150 lines of
philosophical prose (Introduction, Primitive Worlds, Possible Worlds, Tense and Modality,
§1262–1544) followed by a formal Appendix (§1545–3473) that itself contains two subsections with
**no Lean counterpart at all**: "Objective Modality" (§1563, higher-order propositional identity,
operator comprehension, Russell–Myhill) and "Two-Dimensional Semantics" (§1742, Thomason's ⊠
"necessarily always" operator, 2D models). `grep -rli "objective\|two-dimensional"` across
`Theories/Bimodal/*.lean` returns nothing — this material is philosophical/expository and
deliberately unformalized.

The current typst chapters (Intro/Syntax/Semantics/Proof-Theory/Metalogic/Theorems/Notes) already,
correctly, track only the formalized subset (Task Semantics / Soundness / Proof Theory appendix
sections) and omit Objective Modality / 2D Semantics. **This is the right instinct but it is
nowhere stated as a decision.** A planner must explicitly pin down: BimodalReference.typ = a
technical companion documenting *only* what is formalized in Lean, using the paper's terminology
and notation as the target vocabulary — not a full mirror of the paper. Otherwise "systematically
revise ... to align with the paper" invites scope creep into unformalizable philosophy sections.

Also unresolved: the paper itself does **not** contain a completeness *proof* — its completeness
result (`cor:tm-completeness`, line 202/3286) is stated as a corollary that explicitly defers to
"the Lean 4 repository" for the actual proof of `TM^+` completeness (line 3292: "established in
the Lean 4 repository"). This means for completeness/decidability content, the Lean source **is**
the primary source, not a secondary check on the paper — reinforcing that Lean-priority is not
just a tie-breaker but the actual epistemic relationship for this material.

### 2. The Metalogic chapter (04) is not merely stale — it documents a directory structure and
   theorem that no longer exist in the active codebase

Chapter 04 (`typst/chapters/04-metalogic.typ`, 574 lines) names `semantic_weak_completeness` in
`FMP/SemanticCanonicalModel.lean` as "the primary sorry-free completeness theorem," and describes
top-level directories `Representation/`, `FMP/`, `Completeness/`, `Soundness/` (as a directory),
`Compactness/`.

Actual current `Metalogic/` layout: `Algebraic/`, `Bundle/`, `BXCanonical/`, `ConservativeExtension/`,
`Core/`, `Decidability/`, `Relational/`, `SoundnessLemmas/`, `WeakCanonical/`, plus loose files
`Completeness.lean`, `Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`,
`Metalogic.lean`, `WeakCanonical.lean`. **None of `Representation/`, `FMP/`, `Soundness/` (dir)
exist.** `grep -rn "semantic_weak_completeness" Theories/Bimodal --include=*.lean` returns hits
**only inside `Boneyard/`** (`ChainCompleteness/`, `StrictSemanticsLegacy/`) — the theorem the
whole chapter calls "primary" has been archived/superseded.

`Theories/Bimodal/Metalogic/README.md` (the Lean-side README, last verified 2026-05-29, itself
flags: *"This README was last verified before task 131 (module reorg) — verify file list is still
current"*) states the actual primary completeness route is **`Bundle/` (BFMCS)**:
`bmcs_weak_completeness`, `bmcs_strong_completeness`. It further lists **four** parallel
completeness constructions as "Active": `Bundle/` (BFMCS, primary), `BXCanonical/` (Burgess 1982
chronicle completeness), `WeakCanonical/` (Henkin canonical model, includes EF-games,
expressiveness/separation results, and the in-progress Kamp-theorem work), and `Algebraic/`
(Lindenbaum quotient / ultrafilter-MCS, sorry-free). Chapter 04 knows only two (Representation
deprecated, "contrapositive" primary) and neither of those two names matches any of the four real
ones. **This chapter needs a structural rewrite, not an edit pass**, and the planner must decide
which of the four approaches is "the" one to present as primary (recommend following the Lean
README's own designation: Bundle/BFMCS) while giving BXCanonical/WeakCanonical/Algebraic
appropriately scoped secondary treatment — not silently dropping them.

### 3. Frame-class parametrization is entirely missing from the reference manual

Chapter 03 states "The TM proof system has 14 axiom schemata" (a single, unparametrized system).
But `Theories/Bimodal/Metalogic/README.md` states soundness covers **"42 TM axiom constructors
(covering Base, Dense, and Discrete frame classes)."** There is a dedicated
`Theories/Bimodal/FrameConditions/` directory (`FrameClass.lean`, `Validity.lean`, `Soundness.lean`,
`Compatibility.lean`) plus `Metalogic/DenseSoundness.lean` and `Metalogic/DiscreteSoundness.lean` —
**zero** matches for `FrameClass` or `FrameConditions` anywhere under `Theories/Bimodal/typst/`.
This directly corresponds to the paper's `TM`, `TM^+`, `TM_F` (discrete), `TM_D` (dense), `TM_C`
(complete/continuous), `TM_DC` hierarchy (§`cor:tm-completeness`, §1243 `app:ProofTheory`) — a
whole axis of the formalization (and of the paper) is absent from the current typst doc. This is
plausibly the single largest content gap, and it's easy to miss because it doesn't show up as
"changed" prose — it shows up as **absence**.

### 4. Recent Lean churn is concentrated in unstable, actively-blocked research territory

`git log --oneline -40` shows the last ~25 commits are task 309/310/311 work: an in-progress,
still partially-blocked "Kamp theorem" / Rabinovich E[Σ]-fold normal-form encoding effort
(`Metalogic/WeakCanonical/Kamp/`, `NfMultiAnchorBridge.lean`) with explicit "NO-GO" gate results
recorded in commit messages (`8fd4340b1 ... NO-GO`, `2bca78463 ... orchestration halted at R2 gate
(NO-GO)`). This is deep, unfinished, adversarially-gated work — not a settled result. A revision
that treats this as a clean, citable "Kamp's theorem, proven" entry in the reference manual would
be actively wrong; at most it merits a brief "in progress" note, if it belongs in a *reference*
manual at all (arguably it's research-notes material, out of scope until it lands).

Other high-churn files in `Metalogic`/`Semantics` (via `git log --since="60 days ago" --stat`):
`SoundnessLemmas.lean` (22 touches), `Soundness.lean` (22), `Bundle/WitnessSeed.lean` (12),
`Semantics/Truth.lean` (9), `Core/MCSProperties.lean` (8), `BXCanonical/Frame.lean` (8),
`Decidability/Saturation.lean` (6), `Semantics/Validity.lean` (5), `WeakCanonical/EFGames.lean` (5).
Chapter 02 (Semantics) and Chapter 04 both need line-level review against these files, not just
the Metalogic-wide restructuring already documented above.

### 5. Easy-to-overlook directories, confirmed present but plausibly out of scope

- `Theories/Bimodal/Boneyard/` — ~19 archived subdirectories (e.g. `BXCanonicalQuasimodel`,
  `KampBypassArchive`, `DeadCanonicalModel`, `ChainCompleteness`). Danger: exactly this directory
  is where the "primary" theorem chapter 04 currently cites now lives, unmarked as archived. Any
  revision must explicitly grep-exclude `Boneyard/` when verifying a cited name is "live," since a
  hit there is evidence of *deprecation*, not currency.
- `Theories/Bimodal/Automation/` and `Theories/Bimodal/Examples/` — not referenced anywhere in the
  typst doc. Likely legitimately out of scope for a "reference manual" (they're tooling/pedagogy,
  not the logic itself), but this should be an explicit, stated exclusion rather than a silent gap,
  since a reader could reasonably expect a "reference manual for the #proofchecker project" to
  mention tactics/examples somewhere (even the LaTeX README claims "as implemented in the Bimodal/
  directory," unqualified).
- The `Theories/Bimodal/latex/` mirror is *also* stale relative to Lean (last non-README commit
  touching it: 2026-03-16 vs. typst's 2026-06-16 vs. Metalogic's continuous churn through
  2026-07-06) and the task only names the typst file. If only typst is fixed, the "parallel port,
  visually similar" invariant the typst README asserts becomes false. Not necessarily in scope, but
  the plan needs to say so rather than leave it implicit.

### 6. No existing accuracy-verification mechanism for this document

No doc-lint exists for `typst/` (the only doc-lint found, `.claude/scripts/check-extension-docs.sh`,
covers extension READMEs/manifests, unrelated). There is no script that cross-checks a
backtick-quoted Lean identifier in the typst prose against an actual `theorem`/`def` declaration.
This is precisely how the `semantic_weak_completeness` and directory-name drift above were found —
by hand, via targeted `grep`. A planner should budget an explicit verification phase, not just
content edits:
- `typst compile BimodalReference.typ` succeeds (baseline smoke test; currently untested by CI as
  far as this investigation found).
- A full inventory pass: extract every backtick-quoted identifier/filename across all 7 chapters,
  and for each, `grep -rn` it under `Theories/Bimodal` **excluding `Boneyard/`** to confirm it
  exists and is not itself deprecated/re-exported-only. Any hit that resolves *only* inside
  `Boneyard/` should be treated as a documentation bug.
- Axiom-count cross-check: count actual `Axiom.*` constructors (and their frame-class
  parametrization) vs. the "14 axiom schemata" / "15 axiom schemata" (inconsistent between ch03 and
  ch04 already — ch03 says 14, ch04's abstract table has 15 rows) claims in prose.
- Sorry-count cross-check: chapter 04 claims "20 sorry statements, all deprecated" for
  `Metalogic/`; this number should be regenerated via the verification command the Lean README
  itself provides (`grep -c` for `sorry`), not copied forward.

## Recommended Approach

1. Treat this as (at minimum) a two-phase task, and consider whether it should be split via
   `/task --expand` given the scale of drift found: Phase A = ground-truth inventory (grep every
   backticked name/dir claim in all 7 typst chapters against live Lean source, excluding Boneyard;
   produce a mapping table of claim → verified/stale/not-found); Phase B = content rewrite driven
   by that table, chapter by chapter, heaviest first (04-metalogic, then 03-proof-theory for the
   frame-class gap, then 02-semantics for recent Truth/Validity churn).
2. Explicitly scope the paper-alignment axis: BimodalReference.typ documents the Lean-formalized
   core (Task Semantics/Soundness/Proof Theory/Decidability), using the paper's Definitions/Theorem
   numbering and notation as the terminological target — not the paper's Objective Modality or
   Two-Dimensional Semantics appendix sections, which have no Lean counterpart. State this as a
   named decision in the plan's scope section, don't leave it implicit.
3. Resolve, and record, the "which completeness approach is primary" question up front (recommend:
   follow `Metalogic/README.md`'s own designation of `Bundle/`(BFMCS) as primary) before touching
   chapter 04 prose — this decision determines nearly the whole chapter.
4. Decide and record whether frame-class parametrization (Base/Dense/Discrete, TM/TM^+/TM_F/TM_D/
   TM_C/TM_DC) is in scope for this pass or deferred to a follow-up task — given it touches ch03
   axioms table, ch04 soundness table, and potentially a new chapter/section, it may be too large
   to fold into "systematically revise" without exploding scope.
5. Decide and record whether `Theories/Bimodal/latex/` is in scope (kept in sync) or explicitly
   declared to diverge going forward.
6. Add a lightweight verification step (even just a documented grep recipe, not necessarily a new
   script) to the plan's Definition of Done: typst compiles, and every cited Lean name resolves
   outside `Boneyard/`.
7. Treat the active task-309/310/311 Kamp-theorem work as explicitly out of scope / "not yet a
   citable result" for this pass, to avoid documenting an in-flux, NO-GO-gated proof attempt as
   settled.

## Evidence/Examples

- `Theories/Bimodal/typst/chapters/04-metalogic.typ:118-122,304,337,478`: cites
  `Representation/TruthLemma.lean`, `FMP/SemanticCanonicalModel.lean`, `semantic_weak_completeness`
  as primary/live.
- `grep -rn "semantic_weak_completeness" Theories/Bimodal --include=*.lean -l` →
  `Boneyard/ChainCompleteness/Completeness/SuccChainCompleteness.lean`,
  `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean`,
  `Boneyard/ChainCompleteness/Bundle/SuccChainTruth.lean` (Boneyard only).
- `ls Theories/Bimodal/Metalogic/` → `Algebraic Bundle BXCanonical Completeness.lean
  ConservativeExtension Core Decidability Decidability.lean DenseSoundness.lean
  DiscreteSoundness.lean Metalogic.lean README.md Relational Soundness.lean SoundnessLemmas
  WeakCanonical WeakCanonical.lean` — no `Representation/`, `FMP/` (as top dir), or `Soundness/`
  (as dir).
- `Theories/Bimodal/Metalogic/README.md:11-13,23-28,109-114`: states primary completeness is
  `Bundle/` BFMCS (`bmcs_weak_completeness`, `bmcs_strong_completeness`), and lists BXCanonical/
  WeakCanonical/Algebraic as additional active approaches; line 21 states "42 TM axiom
  constructors (covering Base, Dense, and Discrete frame classes)."
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ:12`: "The TM proof system has 14 axiom
  schemata" (single frame class, no parametrization); `grep -rn "FrameClass\|FrameConditions"
  Theories/Bimodal/typst/` → no matches.
- `possible_worlds.tex:202-210,3286-3294`: Completeness corollary defers proof to "the Lean 4
  repository"; `possible_worlds.tex:1563` "Objective Modality", `:1742` "Two-Dimensional Semantics"
  — no Lean or typst counterpart (`grep -rli "objective\|two-dimensional"` empty).
- `git log --oneline -25`: dominated by task 309/310/311 (`NO-GO`, "orchestration halted at R2 gate
  (NO-GO)") Kamp-theorem/E[Σ]-fold work under `Metalogic/WeakCanonical/Kamp/`.
- `git log` dates: `Theories/Bimodal/latex/` last substantive touch 2026-03-16; `typst/` last touch
  2026-06-16 (comment cleanup only); `Metalogic/` continuous churn through 2026-07-06.

## Confidence Level

High confidence on all factual claims above (each backed by direct grep/read/git output, not
inference). Medium confidence on recommendations for how to *resolve* the scoping questions (e.g.,
which completeness approach to designate primary, whether frame-class work is in-scope) — these
are judgment calls for the task owner/planner, not facts this investigation can settle
unilaterally. This report deliberately does not propose an implementation plan or phase
breakdown beyond high-level sequencing; that is the planner's job once these decision points are
acknowledged.
