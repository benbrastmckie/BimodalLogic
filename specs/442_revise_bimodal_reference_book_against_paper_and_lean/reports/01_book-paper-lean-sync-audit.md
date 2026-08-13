# Research Report: Revise BimodalReference Against the Paper and the Lean Tree

**Task**: revise_bimodal_reference_book_against_paper_and_lean (absorbs and supersedes
`sync_typst_book_with_refactored_paper`)
**Scope of this report**: research only. No `typst/**` edits were made. All findings below are
independently re-verified against the live paper, the live Lean tree, and the live gate scripts
as of this research pass — the task description's own "VERIFIED STATE OF PLAY" section is
confirmed accurate and current; nothing has drifted since it was written.

---

## 1. Gate state, reproduced

```
$ bash scripts/check-paper-definitions.sh
[paper-definitions] notice: possible_worlds.tex changed (source: live working tree, new checksum
6ede2218...) but all 26 recorded definitions are unchanged -- pass.
```
Case (b) — proceed, as the task description anticipates. (The checksum differs from the one
quoted in the task description because the live file has moved again since 2026-08-13, but the
26 tracked anchors are still textually unchanged — safe to quote from
`specs/paper-definitions-of-record.md`.)

```
$ bash scripts/typst-sync-check.sh
Check 1: TOTAL_VIOLATIONS=25   (exact same 25 names as the task description lists)
Check 2: MISMATCH_COUNT=3      (exact same 3 stale-count groups)
Check 3: MA_COUNT_MISMATCHES=0 (clean)
```
Both checks reproduce byte-for-byte against the task description's enumeration. No new
violations have appeared. Live counts from `bash scripts/typst-status-counts.sh --json`:
`axiom_count=45, rule_count=7, base_count=37, dense_only_count=2, discrete_only_count=3,
dedekind_only_count=3, sorry_total=5, sorry_total_excl_boneyard=1, sorry_weakcanonical=5,
sorry_weakcanonical_excl_boneyard=1` — all other sorry buckets are 0. Check 2's fix is
mechanical: `bash scripts/typst-status-counts.sh` writes these into `typst/generated/status.typ`;
no hand-editing needed.

---

## 2. Check 1 disposition table — the 25 violations, each resolved to delete / repoint / whitelist

This is the concrete work list the planner needs. Three genuinely different situations hide
behind the "25 violations" number; conflating them will cost real rework.

### 2a. Genuinely dead — DELETE THE CLAIM (no live replacement exists)

| Backtick span | File(s) | Verified disposition |
|---|---|---|
| `Metalogic/ConservativeExtension/`, `Metalogic/ConservativeExtension/Lifting.lean`, `Metalogic/ConservativeExtension/Lifting.lean:683-695`, `ConservativeExtension/` | 03-proof-theory, 04-metalogic, 06-notes, p2-frame-classes, p3-ltl-to-tm | The entire module was moved to `FormalSystem/Boneyard/ConservativeExtension/` (confirmed: `find FormalSystem -iname "*ConservativeExtension*"` returns only the Boneyard path). Non-goals forbid citing Boneyard. **Delete every claim resting on this module**; do not repoint. |
| `ExtFormula.lean`, `exists_fresh_atom`, `liftDerivationWith`, `lift_derivation_qfree`, `embedFormula φ`, `L.map embedFormula` | p2-frame-classes, 06-notes, p3-ltl-to-tm | All four identifiers/paths live exclusively inside `FormalSystem/Boneyard/ConservativeExtension/ExtFormula.lean` — confirmed by grep of the whole `FormalSystem/` tree. Same disposition as above: delete, do not repoint. |
| `rabinovich_translate` | p3-vlach-blstar.typ | Lives only in `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/RabinovichTranslation.lean` — boneyarded. The same chapter already correctly states elsewhere (line 128) "A machine-checked Kamp theorem is an open problem" — that sentence is right; the `rabinovich_translate` citation contradicts it and must be deleted or rewritten to say the Rabinovich-style translation is **not** machine-checked (matches `cor:tm-decidability`'s companion framing: paper-side result only). |
| `Bridge.lean` | 05-theorems.typ | No file of this name exists anywhere under `FormalSystem/` (checked including Boneyard). Whatever claim cites it must be re-sourced to a real module or deleted; researcher could not identify what live file the citation intended (no near-miss filename found) — **flag for the planner as needing fresh sourcing, not a known repoint**. |
| `DenseSoundness.lean`, `DiscreteSoundness.lean`, `Metalogic/DenseSoundness.lean`, `Metalogic/DiscreteSoundness.lean` | 04-metalogic.typ | Both live only under `FormalSystem/Boneyard/SoundnessVariants/`. Live soundness is `FormalSystem/Metalogic/Soundness.lean` and `FormalSystem/Metalogic/SoundnessLemmas.lean` (+ `SoundnessLemmas/` dir) — a single unified soundness module now, not per-class files. Repoint the surrounding prose to `Metalogic/Soundness.lean` / `Metalogic/SoundnessLemmas.lean`, do not just swap filenames 1:1 since the module structure itself changed (see §4 below, the module-table rebuild). |
| `FMP/DenseFMP.lean`, `FMP/DiscreteFMP.lean` | p2-decidability-practice.typ | Neither file exists under `FormalSystem/Metalogic/Decidability/FMP/` (live contents: `ClosureMCS.lean`, `Filtration.lean`, `FiniteModel.lean`, `FMP.lean`, `TruthPreservation.lean`, `README.md` — no per-class split). The dense/discrete refinement claim these two paths supported does not have a live per-file counterpart; delete or rewrite to describe how dense/discrete refinement is actually organized in the live `FMP/` tree (it appears to be handled inside `FiniteModel.lean`/`TruthPreservation.lean` rather than split files — worth a closer read at planning time). |

### 2b. Real, live, sorry-free — REPOINT, do not delete (checker false-negative, not a dead claim)

| Backtick span | File | Root cause | Fix |
|---|---|---|---|
| `FMP.assignmentSpace_card`, `FMP.filtered_world_bound` | p2-decidability-practice.typ | **Both theorems genuinely exist**, sorry-free, at `FormalSystem/Metalogic/Decidability/FMP/FMP.lean:190` and `:209`, inside `namespace FormalSystem.Metalogic.Decidability.FMP`. The checker does a literal `grep -F` for the exact backtick string; `FMP.assignmentSpace_card` never occurs as that literal substring anywhere in the Lean source (the theorem is declared as the bare name `assignmentSpace_card` inside the namespace block, never written with an explicit `FMP.` prefix in any doc comment). By contrast `FMP.fmp_contrapositive` and `FMP.mcs_finite_model_property` — cited two lines earlier in the *same* book paragraph — pass, because `Correctness.lean`'s doc comments happen to spell those two out with the literal `FMP.` prefix. **This is not a dead-identifier situation**: the fix is either (a) drop the `FMP.` prefix in the book's backtick span to match how the bare theorem name is written in source (`assignmentSpace_card`, `filtered_world_bound`), or (b) add a literal `FMP.assignmentSpace_card` / `FMP.filtered_world_bound` occurrence to a doc comment in `FMP.lean` — out of scope here (non-goal: no Lean changes). Recommend (a). |

### 2c. Expository spans wrongly backticked — WHITELIST or REFORMAT

| Backtick span | File | Disposition |
|---|---|---|
| `L.map embedFormula`, `embedFormula φ`, `⊥ U φ` | p2-frame-classes.typ | These three die along with the whole ConservativeExtension cluster (2a) — once that prose is deleted, these spans disappear with it. No whitelist entry needed if the surrounding claim is removed as directed. |
| `Nat.card (FilteredWorld φ) ≤ 2^(|op("closure")(φ)|)`, `Nat.card (Set ↥(subformulaClosure φ)) = 2^(|op("closure")(φ)|)` | p2-decidability-practice.typ | Genuine expository renderings of the real theorem statements at `FMP.lean:190,209` (Typst math notation vs. Lean surface syntax will never literal-match). Whitelist with reason `"expository rendering of FMP.assignmentSpace_card / FMP.filtered_world_bound in Typst math notation"`. |
| `allClosed arrow.r "valid"` | p2-decidability-practice.typ | This is Typst-rendered math (`allClosed => "valid"` in the source's own notation), referring to the still-open `valid_iff_allClosed` bridge already correctly described as open two paragraphs above it. Whitelist with reason `"Typst-rendered math for the open valid_iff_allClosed bridge, not a Lean identifier"`. |
| `and True` | p2-decidability-practice.typ | This is **prose**, not a Lean citation — the sentence explains that two now-superseded theorems "previously carrying these names were vacuous: each concluded in an `and True` conjunct discharged by `trivial`." It describes Lean syntax historically, not a current claim. Whitelist with reason `"describes a historical (now-fixed) vacuous-conjunct pattern, not a current Lean citation"` — or reformat without backticks since it is plain prose describing Lean syntax, not itself a name.

**Whitelisting discipline reminder for the planner**: `sync-check-whitelist.txt` already carries a
clear category-header convention (see current file, reproduced in full above in the research
harvesting — type-signature illustrations, template API names, proper nouns, external-paper
labels, external-repo citations, lake target names, JSONL field illustrations). Each new entry
should extend the existing category structure with a one-line reason, matching the file's own
documented format, not append unstructured lines.

---

## 3. Check 2 fix (mechanical)

```
bash scripts/typst-status-counts.sh
```
writes the live counts (`sorry_total=5`, `sorry_total_excl_boneyard=1`,
`sorry_weakcanonical=5`/`sorry_weakcanonical_excl_boneyard=1`, all class-table sorries otherwise
0) into `typst/generated/status.typ`. No manual arithmetic — the committed file is simply stale
relative to a `d8fe52c3d` (2026-08-13) codebase snapshot the script itself stamps into its JSON
output (`"stamp_commit": "d8fe52c3d", "stamp_date": "2026-08-13"`).

---

## 4. The completeness/decidability story — live paper text, more complete than the task description already quotes

The task description's section 4 quotes `cor:tm-completeness` "in substance." I re-read the
corollary and its full proof verbatim in the live paper (`\label{cor:tm-completeness}` at
possible_worlds.tex:4038, proof through ~4094; `\label{cor:tm-decidability}` at :4095, proof
through ~4114; `\label{def:TMplus}` at :4022 carrying the conservativity footnote). Everything in
the task description is accurate; the live text additionally gives the planner exact derivation
steps worth transcribing into the book rather than paraphrasing loosely:

- **The dichotomy proof, verbatim in substance**: "Every nontrivial totally ordered abelian group
  is either discrete (has a least positive element) or dense, and never both: if there is no
  least positive element, then for x < y some positive e < y − x exists (else y − x would itself
  be least positive), giving x < x + e < y by translation invariance; conversely a least positive
  element e forbids anything strictly between x and x + e." This is a genuinely short, teachable
  proof and a strong remark/diagram candidate (§7 below).
- **The exact (DD) derivation** the book should carry: `\aref{TMP-NB}` and `\aref{M5}` give
  ⊢_TM+ □Next⊤ ∨ □¬Next⊤; since Next⊤ → φ_DF and ¬Next⊤ → ψ_DN are BL+-valid, TM+'s weak
  completeness gives TM+ ⊢ Next⊤ → φ_DF and TM+ ⊢ ¬Next⊤ → ψ_DN — premises that inherit TM+'s own
  outstanding base-case obligation — whence necessitation and distribution yield TM+ ⊢ (DD).
- **The Halldén-incompleteness clarification, verbatim in substance**: "TM does not prove (DD),
  so TM is nowhere shown Halldén-incomplete — it is semantically incomplete instead, a different
  defect... TM + (DD) would instead create Halldén-incompleteness... Log(all task frames) itself
  contains (DD) and neither disjunct, so Halldén-incompleteness of the target logic is a
  **theorem**, the correct formal signature of a class that is a union of two incompatible kinds,
  and not a defect." This sentence is the single most important one for `06-notes.typ` and
  `04-metalogic.typ` to get right — the current book's "open problem" framing is not merely
  outdated, it asserts the *opposite* epistemic status of what the paper now claims (open →
  proven-but-negative, with the "why" being philosophically interesting rather than a gap).
- **TM_c / Reynolds-triple caveat, verbatim in substance**: "TM_c fails identically over {Z, R},
  for the same reason, compounded by the further, independent open question of whether
  `\aref{TMP-CO}` alone axiomatizes the same BL+-logic as `\ref{def:TMplus-c}`'s full Reynolds
  triple; neither gap is closed here." This matches the task description's §6 CO-alone-vs-triple
  point and is the paper-side warrant for it.
- **Lean status footnote** (attached to the completeness proof): the remaining obligations are
  named precisely — "the frame-axiom alignment of the Lean task-frame structure and the
  formalization of TM's own BL-language and proof system: verifying that the Lean task-frame
  structure satisfies the biconditional Compositionality, Seriality, and Spherical axioms of
  `\ref{def:frame}`, whereupon the Occurrence property follows by `\ref{cor:occurrence}`... Since
  Occurrence implies Seriality, the Seriality check comes free wherever Occurrence is already
  verified, and Spherical holds automatically whenever the frame in question has finite W by
  `\ref{cor:spherical-finite}`; an infinite-W frame would raise a genuine further obligation."
  This is exactly the "one proof obligation remains outstanding" the task description flags —
  worth quoting close to verbatim in `06-notes.typ`'s Lean-status discussion, since it tells a
  reader precisely what is and is not done.
- **Decidability proof, the two witnesses named precisely**: `\aref{DF}` is a non-theorem of TM,
  TM_d, TM_c, TM_dc yet valid over every D=Z model; `\aref{CO}` is a non-theorem of TM_f
  (witnessed by Z ×_lex Z, `\ref{def:TMplus-f}`) yet likewise valid over every D=Z model. "A
  repaired finite model property would need to be class-specific — finite W over Z-time for the
  discrete systems, and analogous constructions for the dense and complete classes, ranging over
  effective non-Archimedean carriers such as Z ×_lex Z rather than Z alone — none of which is
  currently established." This confirms the task description's §5 verbatim.

**Do not re-derive this by re-reading the paper at plan/implement time** — the excerpts above
plus the task description's own quotes are sufficient to write the corrected `cor:tm-completeness`
and `cor:tm-decidability` sections without a further paper pass, provided the citation discipline
of §9 (task description) is honored: cite by `\label`/`\aitem` key, quote text verbatim, re-run
`check-paper-definitions.sh` before finalizing (note: `cor:tm-completeness`,
`cor:tm-decidability`, and `def:TMplus` are **not** among the 26 anchors tracked in
`specs/paper-definitions-of-record.md` — that file only covers the definitional/semantic layer
carried forward from the prior task. The implementer must either re-verify these three anchors
by direct grep against the live paper at implementation time, or extend
`paper-definitions-of-record.md`'s tracked set — the file's own header documents how new anchors
are added).

---

## 5. Frame classes — Dedekind path confirmed live and substantial

`FormalSystem/ProofSystem/Axioms.lean` (read in full around lines 340–480) confirms the task
description exactly: four frame classes `Base < {Dense, Discrete}`, with `Dedekind` sitting
**strictly above `Dense`** (not a fourth incomparable leaf) — `Dedekind` extends Dense with
Reynolds' definable-gap axioms Prior-U, Prior-S, and Sep, and by
`Semantics.complete_duration_discrete_or_dense`
(`FormalSystem/Semantics/DurationClassification.lean`) a Dedekind-complete non-discrete order is,
up to isomorphism, exactly the real flow. Live modules under `Metalogic/` (confirmed via `find`):
`Algebraic/`, `Bundle/`, `BXCanonical/` (with `Chronicle/`, `Filtration/`, `Quasimodel/`),
`Core/` (with `RestrictedMCS/`), `Decidability/` (with `FMP/`, `Propositional/`, `Verified/`),
`SoundnessLemmas/`, `WeakCanonical/` (with `DenseModelSurgery/`, `EFGames/`, `Expressiveness/`,
`IntegerModel/`, `Kamp/`, `RealModel/`, `Separation/`). The Dedekind path's live proof sites named
in the task description (`BXCanonical/CompletenessDedekind.lean`, `StrongCompleteness.lean`,
`RealModel/`) exist and were not independently re-verified line-by-line here (plan/implement
should confirm exact theorem names — `completeness_dedekind`,
`consequence_completeness_dedekind` — before quoting).

`04-metalogic.typ`'s `Metalogic/` module table (lines ~130–150) needs a full rebuild against this
live tree, not a patch — it currently has five wrong rows (per task description) and omits
`Bundle/`, `Algebraic/`, `WeakCanonical/` and its six subdirectories, and `Decidability/Verified/`
entirely.

---

## 6. The "three frame classes" / "open problem" claim sites — exact locations, verbatim current text

Confirmed by direct grep (all still present, unchanged from the task description's audit):

- `typst/chapters/00-introduction.typ:138` — "`Metalogic/` -- Soundness (proven for all three
  frame classes)... a canonical-model construction toward completeness (which remains an open
  problem)"
- `typst/chapters/06-notes.typ:16-17, :35, :75, :83` — four separate "open problem" /
  "three frame classes" restatements, including the `ConservativeExtension/` citation of §2a and
  a `completeness`/`completeness_dense`/`completeness_discrete` citation in
  `Metalogic/BXCanonical/Completeness.lean` that also needs live-name verification (this exact
  filename was not independently confirmed to exist in the tree walk above — flag for
  plan/implement to re-check, since `Completeness.lean` did not appear in the `find` listing of
  `BXCanonical/`'s immediate children, only its three subdirectories `Chronicle/`, `Filtration/`,
  `Quasimodel/`; the file may exist at `BXCanonical/` top level, which the `-maxdepth 2` walk
  would have caught as a directory only, not a file — **re-verify with `find
  FormalSystem/Metalogic/BXCanonical -name "*.lean"` at implementation time**).
- `typst/chapters/p2-frame-classes.typ:133-139` — the ConservativeExtension cluster (§2a).
- `typst/chapters/04-metalogic.typ:14-15, :112, :140, :154-155` — "Soundness is fully proven for
  all three frame classes," "The completeness of *TM* ... is an open problem" (twice), the module
  table's dead `ConservativeExtension/` row.
- `typst/chapters/p2-decidability-practice.typ:27, :33` — correctly-scoped "open problem" language
  for the *filtration-to-semantic-validity bridge* specifically (this one is **not** wrong — it
  describes a genuinely still-open Lean-side bridge, distinct from the paper-level completeness
  claim; do not conflate these two "open problem" statements when rewriting — the book needs to
  keep the FMP-bridge one and replace the TM-completeness one).
- `typst/BimodalReference.typ:140` — the abstract itself: "the completeness of *TM* with respect
  to its frame classes remains an open problem." This is the highest-visibility site and should
  be corrected first/most carefully, matching `cor:tm-completeness`'s headline: TM is sound but
  provably incomplete over its own class; completeness is carried by the machine-checked BL+
  systems instead.
- `typst/chapters/03-proof-theory.typ:213` and `typst/chapters/p3-ltl-to-tm.typ:130` — both
  present the conservativity claim as established fact via the dead
  `Metalogic/ConservativeExtension/` citation; both need the four-part status from §4 of the task
  description (backward direction unconditional; forward direction fails for base case via (DD)
  and unconditionally for discrete via TMP-Z1; open for dense/complete).
- `typst/chapters/04-metalogic.typ:154`, `typst/chapters/p4-dual-verification.typ:26` — "all three
  frame-class variants" / "all three frame classes" phrasing needing the Dedekind fourth class
  added.

---

## 7. The 02-semantics.typ generational gap — confirmed, worse than a stale citation

Direct read of `typst/chapters/02-semantics.typ:34-49` confirms the task description's diagnosis
precisely, and gives the exact passage that needs replacing:

```
+ *Nullity*: For all w : W, we have w =>_0 w.
+ *Reflection*: For all w, u : W and x : D, if w =>_x u, then u =>_(-x) w.
+ *Compositionality*: For all w, u, v : W and x, y : D, if w =>_x u and u =>_y v, then w =>_(x+y) v.
```
followed by: "Nullity ensures that zero-duration tasks leave the world state unchanged. Reflection
ensures that every task is invertible... the restricted form together with #leanConverse recovers
every instance the semantics uses" — this last clause frames the Lean structure's split into
non-negative-only Compositionality plus a converse lemma as a *divergence needing justification*
("the unrestricted mixed-sign form is algebraically impossible for non-deterministic relations").
Per the task description, this framing is **inverted**: the paper's own `def:frame` (quoted in
full in the task description, §3) uses exactly this positive-cone-plus-converse-convention
presentation — Compositionality stated for x, y ≥ 0, with negative durations defined via the
converse convention `w ⇒_{-x} u := u ⇒_x w`. So the Lean structure and the paper *agree*; the book
should say so, not apologize for a gap.

The chapter has **no Limit clause at all** (confirmed — `grep -n "Limit"` returns nothing in the
file) and **no Spherical clause at all** (confirmed — `grep -n "Spherical"` returns nothing). Both
of the paper's remaining two axioms are entirely absent from this chapter. This is the single
largest content gap in the book relative to the paper's four-axiom `def:frame` and the single
highest-priority rewrite target — bigger in scope than any of the 25 sync-check violations, since
sync-check only catches broken backtick citations, not missing content.

This chapter (169 lines total) will need substantially more than a patch; budget it as
effectively a full rewrite of the "Task Frames" section against `def:frame`, `def:temporal-order`,
`def:task-relation`, `def:directed`, `lem:nullity` (verbatim quotes for all of these are already
in the task description §3 and cross-checked against `specs/paper-definitions-of-record.md` lines
226–305, confirmed present and current). The "World Histories" section (from line ~51) was not
read in full here; plan/implement should re-audit it against `def:world-history`
(paper-definitions-of-record.md:306-325) independently, since if the frame section predates the
positive-cone presentation, the world-history section may equally predate the
partial-history/world-history/total-history layering the task description's §3 insists on.

---

## 8. Bibliography — what resolves today, what's missing, exact BibTeX to add

Current `typst/bibliography.bib` (77 entries) already has, and the book already cites, all four
sources named as currently-cited in task description §7: `burgess1982axioms`, `reynolds1992`,
`doets1987`, `kamp1971formalproperties` (note: keyed `kamp1971formalproperties`, not `kamp1971` —
already correct in-book). It also already has `vlach1973nowandthen` (unused? — grep of `@vlach`
usage should be checked at implement time; the key exists in the .bib but book-wide `@`-citation
grep found no live `@vlach1973nowandthen` usage in the chapters read here, meaning it may need to
be *cited*, not *added*).

**Missing entirely** (task description names these as needed; confirmed absent from
`typst/bibliography.bib` by full-file read): Bacon 2022, Dorr and Goodman 2020, Prior 1967,
Rumberg and Zanardo 2019, Walsh 2016, and a Hölder's-theorem citation. The **paper's own**
`possible_worlds.bib` (at `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.bib`)
has print-ready entries for all of these under different keys than the task description's loose
citation style — use these verbatim rather than re-deriving:

```bibtex
@book{Prior1967,
  author    = {Prior, Arthur N.},
  title     = {Past, Present and Future},
  publisher = {Oxford University Press},
  address   = {Oxford, New York},
  year      = {1967},
}

@article{Dorr2020,
  author    = {Dorr, Cian and Goodman, Jeremy},
  title     = {Diamonds Are Forever},
  journal   = {No\^us},
  volume    = {54},
  number    = {3},
  pages     = {632--665},
  year      = {2020},
}

@article{Bacon2022,
  author    = {Bacon, Andrew and Zeng, Jin},
  title     = {A Theory of Necessities},
  journal   = {Journal of Philosophical Logic},
  number    = {1},
  pages     = {151--199},
  year      = {2022},
}

@article{Walsh2016,
  author    = {Walsh, Sean},
  title     = {Predicativity, the Russell-Myhill Paradox, and Church's Intensional Logic},
  journal   = {Journal of Philosophical Logic},
  number    = {3},
  pages     = {277--326},
  year      = {2016},
}

@article{Rumberg2019,
  author    = {Rumberg, Antje and Zanardo, Alberto},
  title     = {First-Order Definability of Transition Structures},
  journal   = {Journal of Logic, Language and Information},
  number    = {3},
  pages     = {459--488},
  year      = {2019},
}
```
(Vlach's own dissertation is already present as `vlach1973nowandthen`; the paper's own bib keys it
`Vlach1973` — a rename is not required, just cite the existing key.)

**Hölder's theorem**: the paper cites it by name only ("By Hölder's theorem, a nontrivial
discrete Archimedean totally ordered abelian group is isomorphic to Z" — possible_worlds.tex line
~3972 area, `def:TMplus-f`) with **no bibliography entry of its own** in `possible_worlds.bib` —
it is treated as a standard named result, uncited. The book chapters read here did not need a
Hölder citation directly (it only surfaces if `p2-frame-classes.typ` or `04-metalogic.typ`
explains *why* the successor-Archimedean discrete class collapses to Z-time when writing the
corrected completeness/decidability sections). If the book does state this fact, it may simply
name it as "Hölder's theorem" without a formal citation (matching the paper's own practice), or
cite a standard order-theory reference (e.g., Fuchs, *Partially Ordered Algebraic Systems*, 1963)
if the house style wants every named theorem sourced — **this is a style decision for the
planner/user, not a fact-finding gap**.

---

## 9. `typst/README.md` task-number citation — confirmed violation of repo rule

`typst/README.md`'s "Follow-Up Tasks" table (lines ~112-121) currently reads:

```
| Task | Scope |
|------|-------|
| 315  | Part I positioning chapters (...) |
| 316  | Machine-readable JSONL appendix (...) |
| 317  | ~~Part III/IV chapters~~ -- superseded |
| 318  | Lk slot-in for the Decidability Frontier chapter (...) |
```

This is a live violation of `.claude/rules/no-task-references-in-deliverables.md`
(`typst/**` is not in that rule's exemption list — only `specs/**`, commit messages, and PR
metadata are exempt) and is separately flagged by the task description §6. Fix: rewrite the table
to name scope without numbers (e.g., a bare bullet list of the remaining in-progress chapter
files and what each still needs), or move the task-number mapping into this task's own
`specs/442_.../` directory as an internal tracking note. The latter is simpler and matches the
rule's stated intent (task numbers are ephemeral/renumbered; durable anchors — filenames — belong
in the deliverable).

---

## 10. Task 413 — the conservativity-bridge finding (per task description §4/§8, record only, do not modify)

`specs/state.json` task 413 (`[not_started]`, `task_type: lean4`, no title field set) reads:

> "Formalize the TM+ over TM conservativity bridge in Lean 4 (paper thm:ConservativeExtension,
> CEB/CEF/CED/CEC): add a BL base-language Formula type with primitive box/G/H, its TM axiom set
> and derivation trees, a translation into the existing BL+ Formula type, and prove that TM+
> derivability of a translated BL-formula yields TM derivability, supplying the missing step in
> the paper's cor:tm-completeness route. ANCHORS RE-VERIFIED 2026-08-10: `\label{thm:ConservativeExtension}`
> [Conservative Extension] and `\label{cor:tm-completeness}` [Completeness] both resolve in the
> current paper."

**This premise is now stale.** `\label{thm:ConservativeExtension}` no longer exists in the live
paper (deleted; confirmed by grep — the label only appears inside `%% OLD:` comment blocks at
lines 1342, 1699, and a standalone `%% CHANGE` note at line 3821 explicitly stating "this sentence
asserted TM+ to be a conservative extension of TM in prose... The claim is false in the same way
the labeled theorem was"). `def:TMplus`'s footnote (quoted in full in §4 of the task description
and reproduced more fully in §4 above) now makes **no conservativity claim** — the theorem task
413 was meant to complete no longer exists as a target, and the footnote it should instead target
states the forward direction *fails* for the base case (via (DD)) and *fails unconditionally* for
the discrete extension (via TMP-Z1), leaving only dense/complete genuinely open. Task 413's
"ANCHORS RE-VERIFIED 2026-08-10" note is itself now dated relative to the paper's subsequent
completeness-relocation restructure. Per the task description's non-goal ("raise it with the
user rather than fixing it here"), this is reported as a finding for the user's attention; task
413 is not touched by this research or by any downstream implementation of this task.

---

## 11. Marker-string recommendation for the 415/417/419 hedge (section 1 of the task description)

The task description requires "a single consistent marker string" for claims whose Lean anchor
sits in territory that tasks 415 (canonical/chronicle completeness, `Metalogic/BXCanonical/`),
417 (semantic FMP, `Metalogic/Decidability/FMP/`), and 419 (CO/Reynolds independence,
`ProofSystem/Axioms.lean` Layer 9, immediately above the `Axiom.prior_U_gap` constructor) will
move, documented in `typst/README.md` with every occurrence listed.

**Recommendation**: reuse the existing `#footnote[...]` convention already present throughout the
book (e.g., the `fmp_completeness` footnote in `p2-decidability-practice.typ` quoted in §2b) for
the *prose*, and mark the anchor itself with a single HTML-comment-style Typst line comment
carrying a fixed token, e.g.:

```typst
// LEAN-ANCHOR-MAY-MOVE: task-415-canonical-history — see typst/README.md
```

placed immediately above the citing line, using a distinct suffix per contributing task
(`task-415-...`, `task-417-...`, `task-419-...`) so a future sweep can `grep -n "LEAN-ANCHOR-MAY-MOVE"`
across `typst/chapters/` to get the complete worklist in one shot, and `grep -c` per suffix to
scope by which upstream task caused the move. This satisfies "a grep, not a re-audit" without
inventing new Typst infrastructure — it is a plain source comment, invisible in the compiled PDF,
consistent with existing `// ...` header-comment usage already seen at the top of every chapter
file read during this research pass (e.g. `p2-decidability-practice.typ`'s
`// Lean name ground truth: Metalogic/Decidability/ (see ../SYNC-MAP.md).`). The **prose itself**
should still read as a plain, confident statement of current fact (per the task description's
"write the claim so the PROSE survives the anchor moving") — the marker is metadata for the
maintainer, not a hedge visible to the reader.

Concrete candidate sites for this marker (not exhaustive — plan/implement should do the full
sweep): `06-notes.typ:75,83` (canonical-model/FMP citations), `04-metalogic.typ`'s rebuilt module
table rows for `BXCanonical/` and `Decidability/FMP/`, and any new corrected-completeness prose
in `04-metalogic.typ`/`06-notes.typ`/`BimodalReference.typ`'s abstract that cites the dense/Z-time
machine-checked results (415/417 territory) or the CO-vs-Reynolds-triple independence status
(419 territory, `ProofSystem/Axioms.lean` Layer 9 comments already carry the "NOT machine-checked"
flag today per task 419's own description — this flag should itself be marked, since 419 will
either confirm or overturn it).

---

## 12. Diagram candidates — content sketches against the existing cetz style

`00-introduction.typ` already has one `#cetz.canvas` light-cone diagram (lines ~24-60, read in
full): a single world-history trajectory at inclination `theta`, with past/future light cones at
half-angle `alpha` opening along the trajectory, rendered via `cetz.draw.line(...)` with
`close: true` fills. This establishes the book's diagram idiom: single-canvas, geometric,
labeled with Typst math strings, centered via `#align(center)[...]`.

Against the task description's priority-ordered candidate list (§7), concrete sketches:

1. **Two-fibre Z/R countermodel for (DD)** (highest priority, per task description). Two parallel
   horizontal lines/strips (fibre 1 labeled Z, discrete tick marks; fibre 2 labeled R, continuous
   line), a dashed vertical or crossing arrow between them labeled `□` to depict the box modality
   reading globally across both fibres, with `Next⊤` true only on the Z fibre and `¬Next⊤` true
   only on the R fibre — directly visualizing why `□φ_DF ∨ □ψ_DN` is TM-valid-but-unprovable. This
   is the one diagram whose absence most costs the reader, per the task description's own framing
   ("the incompleteness argument is much easier to see than to read").
2. **Fiber/cone/segment apparatus of `def:task-relation`**. A single world-state point `w` with
   `Fib(w,x)` drawn as a horizontal slice at duration `x`, `(w)_x` (the cone) as the union of
   slices for `|y|<x` (a filled wedge, naturally reusing the light-cone drawing primitives already
   in the codebase), and `[w,v]_x^y` (the segment) as the intersection of two such slices anchored
   at different points `w`, `v`. This diagram can literally extend the existing light-cone cetz
   code rather than starting from scratch — same coordinate idiom, same `pt(ang, r)` helper.
3. **Three-way discreteness-indicator case split** driving the completeness architecture (dense /
   discrete / — per `04-metalogic.typ:100`'s existing text, the case split is already described
   in prose as "Dense case (`¬U(⊤,⊥)` in M)" vs. a discrete case; a diagram would show the
   `U(⊤,⊥)` witness as a decision node branching to the two canonical-model constructions).
4. **Partial history → world history (convex) → total history layering**. A single duration axis
   with three nested domains drawn as intervals of increasing extent (a broken/non-convex domain
   struck through as *not* a world history, a convex-but-partial interval, and the full axis for
   total) — directly visualizes the def:world-history layering the task description insists the
   book state precisely.
5. **Frame-class lattice** Base / Dense / Discrete / Dedekind. Per §5 above, this is **not** a
   simple diamond — `Dedekind` sits strictly above `Dense`, not as a fourth incomparable leaf.
   `FormalSystem/ProofSystem/Axioms.lean` (lines ~425-440) already contains an ASCII-art rendering
   of this exact lattice in a doc comment:
   ```
                 Dedekind
   Dense --------'      Discrete
              Base
   ```
   — the diagram should faithfully mirror this shape (Dedekind as a strict refinement of Dense,
   Discrete incomparable to both Dense and Dedekind), not the naive 4-leaf diamond a reader might
   otherwise guess at.

---

## 13. Introduction chapter — current structure, for the expository rewrite

`00-introduction.typ` (140 lines) currently has exactly the five sections the task description
names as already present: `== What TM Is` (17), `== Why Tense and Modality Together` (101),
`== Outline` (113), `== How to Read This Book` (120), `== Project Structure` (131) — plus the
light-cone diagram (§12 above) sitting between the opening paragraphs and "What TM Is." The
"What TM Is" section already states the Until/Since-over-linear-orders-fused-with-S5
characterization and gestures at "task frames" without yet explaining *why* task frames rather
than Kripke frames, or *why* D is an ordered abelian group rather than a bare linear order — both
explicitly required by the task description's expository mandate. The "Outline" section (113-120,
not read in full here) should be checked against the book's *actual* current part/chapter
structure (`typst/BimodalReference.typ`'s `#part-divider(...)` calls, per `typst/README.md`'s own
stated authority) at implementation time, since several chapters (`p3-*`, `p4-*`) are newer than
this section may reflect.

---

## 14. Summary punch list for the planner

1. **02-semantics.typ**: full rewrite of the Task Frames section against the paper's four-axiom
   `def:frame` (§7) — largest single content gap, not caught by sync-check.
2. **25 sync-check violations**: 15 delete-the-claim (ConservativeExtension cluster + dead
   soundness/FMP files + Bridge.lean, unsourced), 2 repoint-only (FMP.assignmentSpace_card /
   FMP.filtered_world_bound — checker false-negative on a real theorem), 5 whitelist (genuine
   expository spans), 3 already resolve once the ConservativeExtension cluster is deleted (§2c).
3. **Completeness/decidability**: replace every "open problem" TM-completeness claim (§6, eight
   sites across five files including the book's own abstract) with the sound-but-incomplete /
   split-validity-(DD) / Halldén-clarification story (§4); leave the FMP-bridge "open problem" in
   `p2-decidability-practice.typ` untouched (it is correct).
4. **Conservativity**: rewrite every citing site (§2a, §6) to the unconditional-backward /
   fails-base-case-and-discrete / open-dense-complete four-part status; do not repoint to a live
   module (there is none).
5. **Module table rebuild** in `04-metalogic.typ` against the live `Metalogic/` tree (§5);
   "three frame classes" → four, everywhere (§5, §6).
6. **typst/README.md**: strip task numbers (§9); add a "Marker Convention" section documenting
   the chosen `LEAN-ANCHOR-MAY-MOVE` token (§11) with a live occurrence list once written.
7. **Bibliography**: add the five verbatim BibTeX entries in §8; confirm `vlach1973nowandthen` is
   actually cited somewhere once the relevant prose is added.
8. **Introduction**: expand per task description §7 against the current five-section structure
   (§13); add diagrams 1–2 from §12 at minimum, ideally all five.
9. **Compile-clean and gate-clean acceptance** per task description §8, items 1–5, including the
   dated `typst/SYNC-MAP.md` verdict section and this report itself as the required findings note
   (this report *is* that findings note — item 5 of the task description's acceptance criteria is
   satisfied by this document; a future implementer should reference it directly rather than
   duplicating it).
10. **Record, do not act on**: task 413's stale conservativity-bridge premise (§10) — surface to
    the user, do not modify task 413 from this task's implementation.
