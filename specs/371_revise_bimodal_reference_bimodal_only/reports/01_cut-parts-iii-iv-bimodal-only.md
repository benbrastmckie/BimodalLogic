# Research Report: Revise BimodalReference.typ to Present All and Only the Bimodal Logic

**Task**: 371 | **Type**: typst | **Date**: 2026-07-15

## Goal

Cut Part III (Counterfactual Logic) and Part IV (Constitutive Logic) from
`Theories/Bimodal/typst/BimodalReference.typ` entirely, leaving a focused two-part
document (Part I: The Bimodal System, Part II: Applications), with all cross-references,
framing prose, notation, bibliography, and sync tooling brought into agreement with the
new scope. This report is grounding for a phased implementation plan; it does not edit
any files.

## 1. Structural Map

### 1.1 `#include` order in `BimodalReference.typ` (lines 167-246)

```
Front matter:
  169  #include "chapters/00-introduction.typ"

Part I divider (173-185) -- KEEP, but scope paragraph (176-184) already only
  describes Part I content; no III/IV leakage in the divider text itself.
  187  #include "chapters/01-syntax.typ"
  188  #include "chapters/02-semantics.typ"
  189  #include "chapters/03-proof-theory.typ"
  190  #include "chapters/p2-frame-classes.typ"
  191  #include "chapters/04-metalogic.typ"
  192  #include "chapters/p2-decidability-practice.typ"
  193  #include "chapters/05-theorems.typ"
  194  #include "chapters/p3-ltl-to-tm.typ"
  195  #include "chapters/p3-vlach-blstar.typ"
  196  #include "chapters/p3-decidability-frontier.typ"

Part II divider (200-209) -- KEEP, self-contained scope paragraph.
  211  #include "chapters/p4-proof-automation.typ"
  212  #include "chapters/p4-dataset-pipeline.typ"
  213  #include "chapters/p4-dual-verification.typ"

Part III divider (217-224) -- REMOVE (part-divider call + include)
  226  #include "chapters/p5-counterfactual.typ"          -- REMOVE (504 lines)

Part IV divider (230-239) -- REMOVE (part-divider call + include)
  241  #include "chapters/p5-constitutive.typ"             -- REMOVE (382 lines)

Back matter:
  245  #include "chapters/06-notes.typ"
  246  #include "chapters/ax-machine-appendix.typ"
```

Note the naming: despite being "Part III/IV" chapters, their files are prefixed `p5-`
(a historical numbering artifact from task 313's five-part restructure -- there is no
`p5-` sibling for parts I/II, whose chapters use `01-`/`02-`/... and `p2-`/`p3-`/`p4-`
prefixes). This is cosmetic only; no functional import depends on the `p5-` prefix.

### 1.2 Chapter file roles (all 17 files under `chapters/`)

| File | Part | Role | Action |
|---|---|---|---|
| `00-introduction.typ` | front matter | Roadmap, "What TM Is", outline, project structure | **REVISE** (4-part -> 2-part framing) |
| `01-syntax.typ` | I | Formula syntax | keep unchanged |
| `02-semantics.typ` | I | Task frames, truth conditions | keep unchanged |
| `03-proof-theory.typ` | I | BX axioms, inference rules | keep unchanged |
| `p2-frame-classes.typ` | I | Frame classes and extensions | keep unchanged |
| `04-metalogic.typ` | I | Soundness, completeness | keep unchanged |
| `p2-decidability-practice.typ` | I | Decidability in practice | keep unchanged |
| `05-theorems.typ` | I | Perpetuity, derived theorems | keep unchanged |
| `p3-ltl-to-tm.typ` | I | LTL-to-TM positioning | keep unchanged |
| `p3-vlach-blstar.typ` | I | Vlach store/recall, BL⋆ tower | keep, **1 cosmetic word choice to review** (§3) |
| `p3-decidability-frontier.typ` | I | Decidability frontier | keep unchanged |
| `p4-proof-automation.typ` | II | Proof tactics | keep unchanged |
| `p4-dataset-pipeline.typ` | II | Dual-signal training pipeline | keep unchanged |
| `p4-dual-verification.typ` | II | Dual-verification worked examples | keep unchanged |
| `p5-counterfactual.typ` | III | Tensed counterfactual logic | **DELETE** (504 lines) |
| `p5-constitutive.typ` | IV | Constitutive structure | **DELETE** (382 lines) |
| `06-notes.typ` | back matter | Implementation status, discrepancy notes | keep unchanged (no III/IV mentions found) |
| `ax-machine-appendix.typ` | back matter | Machine-readable appendix wrapper | keep unchanged (no III/IV mentions found) |

Total: 3,231 lines across all chapters; deleting `p5-counterfactual.typ` +
`p5-constitutive.typ` removes 886 lines (27%).

### 1.3 Part-divider structure

Four `part-divider(number, title, scope)` calls in `BimodalReference.typ`
(function defined in `template.typ:202-217`, a generic full-page block taking a
part number, title, and scope paragraph -- no part-specific logic to change).
Two of the four (`"III"`, `"IV"`) must be deleted along with their `#include`:

- Lines 217-224: Part III divider (`"III"`, `"Counterfactual Logic"`, scope paragraph)
- Lines 228-239: Part IV divider (`"IV"`, `"Constitutive Logic"`, scope paragraph)

### 1.4 Abstract, Sources block, Contents/outline

- **Sources block** (title page, lines 111-119): item 2 links "Counterfactual Worlds"
  (the Part III paper), item 3 links "Identity and Aboutness" (the Part IV paper).
  Item 1 ("The Construction of Possible Worlds") and item 4 (the ProofChecker repo)
  are the bimodal-system sources and should stay. Items 2-3 should be dropped or the
  block reframed, since neither paper is a source for retained content.
- **Abstract** (lines 135-141): paragraph 2 (line 139-140) describes Parts I-II
  correctly and can stay largely as-is; paragraph 3 (line 141) describes Part
  III/IV and must be deleted or the paragraph restructured into a 2-part close.
- **Contents/outline** (line 156, `#outline(title: none, indent: auto)`): this is a
  mechanical Typst outline generated from headings -- it self-updates once the
  III/IV `#include`s are removed. No manual edit needed; verify post-compile that no
  stray heading numbering "III"/"IV" survives (part dividers are `page(numbering:
  none)` blocks with plain text "PART #number", not headings, so they do not feed the
  outline at all -- confirmed via `template.typ:202-217`).

## 2. Exhaustive Removal Inventory

Grep-grounded (`grep -rniI "counterfactual\|constitutive"` across
`Theories/Bimodal/typst/**/*.{typ,md,txt,bib}`, plus targeted checks below).
Every hit is enumerated; nothing is inferred.

### 2.1 `BimodalReference.typ` (main file)

| Line(s) | Content | Action |
|---|---|---|
| 115-117 | Sources block: "Counterfactual Worlds" and "Identity and Aboutness" links | Remove items 2-3 (renumber list) |
| 139-141 | Abstract: Part I/II sentence (139-140, keep/lightly edit), Part III/IV sentence (141, delete) | Edit |
| 162-164 | Header comment: "Four-Part Textbook" / "Order: bimodal system -> applications -> counterfactual -> constitutive." | Edit comment to two-part |
| 215-224 | Part III divider block | Delete |
| 226 | `#include "chapters/p5-counterfactual.typ"` | Delete |
| 228-239 | Part IV divider block | Delete |
| 241 | `#include "chapters/p5-constitutive.typ"` | Delete |

### 2.2 `chapters/00-introduction.typ`

| Line(s) | Content | Action |
|---|---|---|
| 15 | "Two further extensions are presented in the book's closing parts: a tensed counterfactual logic ... @brastmckie2025counterfactualworlds, and the constitutive structure ... @brastmckie2021identity." | Delete or replace with a bimodal-only closing sentence |
| 91 | Figure caption: "...genuine cross-history counterfactual structure is the subject of Part III." | Edit -- Part III no longer exists; either drop the clause or reword to note this is out of scope for the book rather than deferred to a later part |
| 113-120 | `== Outline` -- "The book proceeds in four parts" + 4 numbered items (Part I, II, III, IV descriptions) | Rewrite to "two parts" + 2 items |
| 124-130 | `== How to Read This Book` -- bulleted reading paths, including the "*The philosophical extensions.* Parts III and IV develop..." bullet (130) | Delete that bullet; keep the other 4 (core system, metatheory, comparative positioning, applications) |

This is the chapter with the most rewriting: the roadmap (§Outline) and reading-guide
(§How to Read This Book) sections are structurally four-part and need restructuring,
not just deletion of a sentence. The opening paragraph (line 15) and the closing
bullet (line 130) are the two citation sites for `@brastmckie2025counterfactualworlds`
and `@brastmckie2021identity` outside the removed chapters themselves (confirmed by
grep -- see §3 below); once both are edited, those two bib keys become uncited
everywhere in the retained document.

### 2.3 `notation/constitutive-notation.typ`

Entire file (67 lines). Its own header comment (lines 4-7) states it is "Imported
ONLY by chapters/p5-counterfactual.typ and chapters/p5-constitutive.typ ... NOT by
template.typ." Confirmed by grep: the only two `#import "../notation/constitutive-notation.typ"`
sites are exactly those two files (`p5-constitutive.typ:13`, `p5-counterfactual.typ:13`).
**Safe to delete entirely** once both chapters are removed -- no other file imports it.

### 2.4 `notation/bimodal-notation.typ`

Not deleted, but contains stale cross-references that should be cleaned for
consistency (comments only, not executable, so leaving them would not break the
build, but they actively mislead about the post-cut structure):

| Line(s) | Content | Action |
|---|---|---|
| 13, 17-18 | Header comment: "...The Logos constitutive layer's own transition notation is NOT imported here -- it lives in `notation/constitutive-notation.typ`." | Remove/reword -- file no longer exists |
| 22-25 | Header comment: "...vs Logos triangle usage in constitutive/counterfactual chapters..." | Reword (informational only) |
| 89-92 | Comment above `store`/`recall` defs: "Part I owns the operators -- p3-vlach-blstar.typ -- and Part III's tensed-counterfactual section reuses them." | Reword -- Part III gone |
| 95-96 | `#let store(i) = ...` / `#let recall(i) = ...` | **Dead code after the cut** -- see §3, flag for planner decision (delete vs. keep as public API) |

None of these four items block a green typst compile (they are comments or unused
`#let` bindings, and Typst does not error on unused definitions); they are
clarity/cleanliness items per the task's "cleanly and clearly present" mandate, not
correctness blockers.

### 2.5 `bibliography.bib`

Exhaustively checked: every citation key used in `p5-counterfactual.typ` or
`p5-constitutive.typ` was grepped against the rest of the tree (excluding those two
files and `bibliography.bib` itself) to classify as shared vs. removed-only.

**Removed-only block** (used exclusively inside the two deleted chapters, verified
zero hits elsewhere): a single contiguous, self-labeled block, lines 429-563:

```
% ----------------------------------------------------------------------------
% Entries below imported for the Part III/IV counterfactual and constitutive
% chapters (task 317). ...
% ----------------------------------------------------------------------------
```
followed by 12 entries: `fine1975critical`, `fine2012counterfactuals`,
`fine2012difficulty`, `fine2017truthmakercontent1`, `fine2017truthmakersemantics`,
`lewis1973counterfactuals`, `lewis1979timesarrow`, `stalnaker1968theory`,
`jackson1977causal`, `kripke1963semantical`, `goodman1947problem`. **Safe to delete
the whole block (comment + 12 entries, lines 429-563).**

**Orphaned-after-intro-rewrite** (currently cited only by the two removed chapters
*and* by `00-introduction.typ`'s soon-to-be-edited sentences -- see §2.2 lines 15 and
130):
- `brastmckie2025counterfactualworlds` (lines 21-30, "Counterfactual Worlds")
- `brastmckie2021identity` (lines 33-43, "Identity and Aboutness")

These are **not** in the "Entries below..." block (they sit near the top, next to
`brastmckie2026possibleworlds`, the primary/shared reference) and are not
mechanically detectable as removed-only by file position alone -- they became
removed-only only once `00-introduction.typ`'s Part III/IV citations are edited out.
**Planner decision point**: once the introduction no longer cites them, drop these two
entries as well to satisfy "cited only by the removed parts, keep shared refs" --
unless the implementer decides the introduction should retain a one-line forward
pointer to the companion papers as related, non-bimodal work (the task description's
scope decision says REMOVE III/IV "entirely," which argues for dropping the
citations too, not just the chapters).

**Shared/keep**: `brastmckie2026possibleworlds` (the primary paper, cited
throughout Part I) and everything else in the file not in the above two categories
(all LTL/CTL/hybrid-logic/model-checking citations used by `p3-ltl-to-tm.typ`,
`p3-vlach-blstar.typ`, `p3-decidability-frontier.typ`, etc.) is untouched.

Typst's `#bibliography(..., style: "ieee")` (default, non-`full`) only prints *cited*
entries, so leaving orphaned `.bib` entries in place would not break the compile or
change the rendered References section -- this is a cleanliness-only edit, never a
build-correctness one.

### 2.6 `chapters/p3-vlach-blstar.typ`

One incidental use of the word "counterfactual" (line 27): *"The same phenomenon
arises in the world dimension: counterfactual and modal discourse refers back to the
world of evaluation from within the scope of a modal."* This is **not** a
cross-reference (no `@ch:counterfactual` link, no "see Part III" pointer) -- it is a
linguistic example naming a category of natural-language discourse, structurally
identical to how the same section cites "modal discourse." Grep confirms this file
has zero `@ch:counterfactual`/`@ch:constitutive` labels and zero `#include`/`#import`
of the removed material. **No dangling reference here.** Flag only as an optional
wording tweak for the planner (e.g., swap the example to avoid the word entirely,
purely for topical cleanliness) -- not a correctness requirement.

### 2.7 `README.md` (typst/)

Describes the "four-part textbook" throughout and must be revised:
- Line 5: "...its counterfactual and constitutive extensions" (intro sentence)
- Lines 30-35: table listing all 4 parts, incl. rows for III ("Counterfactual Logic
  (in progress)") and IV ("Constitutive Logic (in progress)")
- Lines 44, 69-70: directory-tree listing showing `p5-counterfactual.typ` /
  `p5-constitutive.typ` under "Part III"/"Part IV" comments
- Line 116: Follow-Up Tasks table, row for task 317 ("Part III/IV chapters...")
  -- this row documents a *now-superseded* follow-up; should be struck or annotated
  as superseded by task 371 rather than silently deleted (preserves task history)

### 2.8 `SYNC-MAP.md`

This file is explicitly a **historical development record**, not a governing
document (its own banner: "this file is a repo-side development document... It no
longer governs the compiled PDF"). It documents claim-verification history for task
312/313, including chapters that (at verification time) were still four-part. No
mechanical check depends on it (confirmed: `typst-sync-check.sh` reads only
`sync-check-whitelist.txt` and `generated/status.typ`, never `SYNC-MAP.md`).
**Recommendation**: append a short dated note at the top (matching the file's own
convention, e.g. the existing "Status (task 319)" banner) stating that task 371 cut
Parts III/IV and that the file's per-chapter tables below (which still list
`p5-counterfactual.typ`/`p5-constitutive.typ` implicitly via the "five-part" Phase-12
narrative, lines 319-337) describe a superseded structure. Do **not** rewrite the
historical tables themselves -- they are a record of what was verified at the time,
and rewriting them would falsify history. This is lower priority than the
build-governing files.

### 2.9 `sync-check-whitelist.txt`

Line 34: `notation/constitutive-notation.typ`, under the comment "Planned notation
file (referenced in a bimodal-notation.typ comment)." This whitelist entry exists
solely to let `typst-sync-check.sh` Check 1 (backtick name resolution) pass when it
encounters the backtick span `` `notation/constitutive-notation.typ` `` inside
`bimodal-notation.typ`'s comment (line 18, see §2.4). Two consistent options:
1. Delete the whitelist line **and** the backtick reference in `bimodal-notation.typ`
   together (since the file itself is being deleted, per §2.3) -- recommended, keeps
   whitelist minimal.
2. Leave both if the planner prefers to retain the historical comment -- but then the
   whitelist entry must stay too, or Check 1 will report a violation (a backtick span
   `notation/constitutive-notation.typ` that resolves to a now-nonexistent path).

**Recommend option 1**: delete both together, since `notation/constitutive-notation.typ`
is being deleted as a file (§2.3) and the comment in `bimodal-notation.typ` needs
rewording anyway (§2.4).

### 2.10 Files checked and found clean (no action needed)

- `chapters/README.md` -- already stale relative to the *current* four-part structure
  (lists only the original 7 task-312 chapters, not the 12 files added since task
  313), so it does not mention Parts III/IV or the p5- files by name. Pre-existing
  staleness, out of this task's scope but worth flagging to the planner as a
  drive-by opportunity (low cost, since the table needs a full pass regardless).
- `notation/README.md` -- same situation: lists only `bimodal-notation.typ` /
  `shared-notation.typ`, predates `constitutive-notation.typ` entirely. No edit
  strictly required (nothing to remove), but a drive-by refresh would improve
  accuracy if the planner wants to fully modernize `notation/README.md` at the same
  time as `constitutive-notation.typ`'s deletion.
- `chapters/06-notes.typ`, `chapters/ax-machine-appendix.typ`, all `p2-*.typ`,
  `p3-ltl-to-tm.typ`, `p3-decidability-frontier.typ`, all `p4-*.typ`,
  `01-syntax.typ` through `05-theorems.typ` -- zero hits for
  "counterfactual"/"constitutive" (case-insensitive). Confirmed clean.
- `generated/status.typ`, `generated/machine-appendix.typ`,
  `generated/machine-appendix.jsonl` -- zero hits. These are generated purely from
  Lean source counts (axiom/rule/sorry counts, axiom-constructor table) and are
  entirely independent of the typst chapter structure; **no regeneration needed**
  for this task.
- `template.typ` -- `part-divider(number, title, scope)` (lines 202-217) is a
  generic, part-number-agnostic function; no III/IV-specific logic to remove.
  `chapter-header`, theorem environments, etc. are likewise generic.

## 3. Dependency / Cross-Reference Analysis

**Question**: does any retained chapter `@`-reference labels/figures/definitions
defined inside the two removed chapters or inside `constitutive-notation.typ`?

**Answer: No.** Full verification:

- `grep -rn "@ch:counterfactual\|@ch:constitutive"` across all `.typ` files shows
  every hit for both labels is confined to `p5-counterfactual.typ` and
  `p5-constitutive.typ` themselves (mutual cross-references between the two removed
  chapters -- e.g. `p5-constitutive.typ` cites `@ch:counterfactual` 8 times,
  `p5-counterfactual.typ` cites `@ch:constitutive` 6 times). **Zero references from
  any retained file.**
- The reverse direction is fine too: `p5-counterfactual.typ:19` cites
  `@ch:vlach-blstar` (defined in the *retained* `p3-vlach-blstar.typ:12`) and reuses
  its `store`/`recall` notation (`p5-counterfactual.typ:416-448`). This is a
  one-directional dependency (removed chapter depends on retained chapter), which is
  exactly what deletion is supposed to sever -- and severing it is safe, since
  nothing in the retained chapter depends back on the removed one.
- Consequence for `notation/bimodal-notation.typ`'s `store(i)`/`recall(i)` helper
  functions (lines 95-96): after the cut, their *only* call sites
  (`p5-counterfactual.typ:418-448`, 6 uses) are gone.
  `p3-vlach-blstar.typ` itself never calls `store(...)`/`recall(...)` -- it writes
  the underlying glyphs directly (`arrow.t^i`, `arrow.b^i`, etc., in its own
  `#definition` block, lines 34-44). **These two functions become fully dead code**
  after the cut. Not a compile error (Typst doesn't warn on unused `#let`s), but
  worth flagging: planner should decide whether to (a) delete them since nothing
  calls them, or (b) keep them as a documented public part of the notation module's
  API in case a future chapter wants the shorthand. Recommend (a) for strict "all and
  only" cleanliness, but this is a judgment call, not a correctness requirement.
- Citation keys: see §2.5 above (bibliography, not `@ch:`/`@sec:` labels) --
  `brastmckie2025counterfactualworlds` and `brastmckie2021identity` are cited from
  `00-introduction.typ` (already being edited for other reasons) plus the two removed
  chapters; no other retained chapter cites either key.
- No `#include` of either removed chapter, or of `constitutive-notation.typ`, exists
  anywhere outside `BimodalReference.typ`'s own two `#include` lines (226, 241) and
  the two removed chapters' own `#import` lines respectively -- confirmed exhaustive
  via the include/import greps in §1.4 / §2.3.

**Conclusion**: this is a clean cut. There is no case of "delete the file, fix a
dangling reference in a *retained* chapter" anywhere in the tree -- every
cross-reference into the removed material originates *from* the removed material
itself, or from `00-introduction.typ`'s roadmap prose (already scheduled for rewrite).
The only genuine "dependency to fix, not just delete" work is the *comment-level*
staleness in `notation/bimodal-notation.typ` (§2.4) and the dead-code question for
`store`/`recall` -- both cosmetic/clarity items, not broken links.

## 4. Clarity/Cleanliness Opportunities

The task asks for a document that "cleanly and clearly presents" the bimodal logic,
not merely one with Parts III/IV mechanically deleted. Concrete, file-grounded
opportunities:

1. **`00-introduction.typ` needs real rewriting, not just deletion.** The `==
   Outline` section (113-120) is structurally "the book proceeds in four parts" with
   4 enumerated items; a naive deletion of items 3-4 leaves "the book proceeds in
   four parts" above only 2 items. The `== How to Read This Book` section (122-130)
   has 5 bullets, one of which (130) is entirely about the two removed parts; the
   other 4 remain accurate as written and should be kept verbatim (they describe the
   spine, metatheory, comparative-positioning, and applications reading paths, all
   Part I/II content).
2. **Title-page Sources block** (lines 111-119): currently 4 numbered sources. Once
   items 2-3 (the counterfactual/constitutive papers) are dropped, item 4 (the
   ProofChecker repo) should be renumbered to item 2, and the block re-reads as "two
   papers + the Lean repo" -- a tighter, more accurate framing for a book that is now
   entirely about the bimodal system.
3. **Abstract**: paragraph 1 (system description, lines 135-137) and the Part I/II
   sentence (139-140) already read as an accurate two-part abstract with the Part
   III/IV sentence (141) simply excised -- minimal rewrite needed here, this is the
   easy case compared to the introduction chapter.
4. **`00-introduction.typ:91` figure caption** currently ends "...genuine
   cross-history counterfactual structure is the subject of Part III" -- once Part
   III doesn't exist, this reads as a dangling forward-reference to nothing. Options:
   drop the clause entirely (the sentence works fine as "Dotted paths are *not*
   alternative histories in *TM*'s formalization"), or reword to state plainly that
   cross-history counterfactual structure is out of scope for this book (rather than
   "deferred to a later part").
5. **`README.md` Follow-Up Tasks table** (line 116): rather than silently deleting
   the task-317 row ("Part III/IV chapters"), mark it superseded/closed by task 371 --
   preserves the audit trail that task 317 was intentionally abandoned/redirected,
   not merely forgotten.
6. **Book-wide framing language**: several files use "five-part" or "four-part"
   language describing the book's macrostructure (`BimodalReference.typ:162-164`
   comment; `README.md` throughout; `SYNC-MAP.md:319` "five-part... living
   monograph"). A consistent terminology pass ("two-part reference manual" or
   similar) across the *governing* files (`BimodalReference.typ`, `README.md`) would
   make the cut feel deliberate rather than partial. `SYNC-MAP.md` is a historical
   record and should keep its "five-part" language describing what existed at
   verification time (§2.8), with a dated note added instead of a rewrite.

## 5. Build / Verification Setup

### 5.1 Compile commands

```bash
cd Theories/Bimodal/typst
typst compile BimodalReference.typ build/BimodalReference.pdf   # production
typst watch   BimodalReference.typ build/BimodalReference.pdf   # live preview
```

`typst` binary confirmed present at `/run/current-system/sw/bin/typst`, version
`0.14.2`. **Baseline compile verified clean during this research** (read-only `typst
compile` run to a scratch output path, not the repo's `build/`): exit code 0, only
pre-existing warnings unrelated to this task (unknown "new computer modern sans" font
family substitution from the `thmbox` package, and two `angle.l`/`angle.r` deprecation
warnings in `shared-notation.typ:44`). No errors, no unresolved references, in the
*current* (pre-cut) four-part document.

### 5.2 Package dependencies (auto-downloaded on first compile)

- `@preview/thmbox:0.3.0` -- theorem environments
- `@preview/cetz:0.3.4` -- diagrams (introduction light-cone figure)
- `@preview/fletcher:0.5.8` -- diagrams (part-divider/extension-node helpers in
  `template.typ`, though `part-divider` itself does not currently use fletcher
  primitives directly -- only `extension-node` does, unused by any current chapter
  per a quick grep; not in this task's scope to investigate further)

None of these are Part III/IV-specific; no dependency changes needed.

### 5.3 Detecting unresolved references / broken `@`-links

Typst itself is the primary detector: an unresolved `@label` reference or a
`#include` of a deleted file causes a **hard compile error** (exit non-zero), not a
silent gap -- so `typst compile` exiting 0 is sufficient evidence that no `@ch:`/
`@sec:`/`@thm:`/citation-key reference is dangling. Given §3's finding that no
retained chapter references the removed material, the expected failure mode after
naive deletion is low; the main risk is a leftover `#include` line (forgetten
deletion) or a typo in the rewritten `00-introduction.typ`/abstract prose, both of
which `typst compile` catches directly.

Beyond the compiler's own hard errors, two repo scripts provide additional
mechanical checks (`Theories/Bimodal/typst/README.md:75-90`, confirmed by reading
both scripts in full):

```bash
# Regenerate volatile counts (unaffected by this task -- Lean-source-driven, not
# chapter-driven; re-run only if convenient, not required by the III/IV cut)
bash scripts/typst-status-counts.sh

# Mechanical drift detector -- 3 checks: backtick name resolution (Check 1),
# count freshness (Check 2), machine-appendix freshness (Check 3)
bash scripts/typst-sync-check.sh
```

Both scripts run from the **repository root** (they resolve `REPO_ROOT` via
`dirname "${BASH_SOURCE[0]}"/..`), not from `Theories/Bimodal/typst/`.

- **Check 1 (backtick resolution)** scans every backtick span in `typst/**/*.typ`
  (excluding `generated/`) and requires each to either resolve as a live Lean
  identifier/path under `Theories/Bimodal/` (excl. `Boneyard/`) or appear in
  `sync-check-whitelist.txt`. Relevant to this task only via the
  `notation/constitutive-notation.typ` whitelist entry (§2.9) -- deleting the file
  and its comment reference together keeps Check 1 clean; deleting the file but
  leaving the comment reference would still pass Check 1 (the whitelist entry
  covers it) but would be misleading, not mechanically broken.
- **Check 2 (count freshness)** and **Check 3 (machine-appendix freshness)** compare
  `generated/status.typ` and `generated/machine-appendix.{typ,jsonl}` against a live
  regeneration from Lean source counts (axiom constructors, rules, sorries). Both are
  entirely independent of which typst *chapters* are included -- **unaffected by this
  task**, no regeneration needed, should still pass after the cut exactly as before.

### 5.4 Definition of "green bar" for this task

1. `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 from
   `Theories/Bimodal/typst/`, with no new warnings/errors beyond the pre-existing
   font-substitution/deprecation ones documented in §5.1.
2. The compiled PDF's outline/table-of-contents contains only Parts I and II (no
   "PART III"/"PART IV" text -- verifiable via `pdftotext build/BimodalReference.pdf -
   | grep -i "PART III\|PART IV"` returning empty, or visual inspection).
3. `bash scripts/typst-sync-check.sh` (from repo root) exits 0 (all 3 checks pass).
4. Grep-level self-check: `grep -rniI "counterfactual\|constitutive"
   Theories/Bimodal/typst/` should return only the handful of *intentionally
   retained* hits identified in §2 (namely: any residual "verify before print"-style
   bib entries the planner decides to keep, if any; and `p3-vlach-blstar.typ:27`'s
   incidental "counterfactual discourse" phrase if the planner decides not to reword
   it) -- not the structural/roadmap/divider/include hits enumerated above, all of
   which should be gone.

## Summary for the Planner

This is a **clean, well-bounded cut** with one genuinely substantial rewrite
(`00-introduction.typ`'s Outline and How-to-Read sections) and a long tail of small,
independent, easily-phased edits:

- **Phase-sized units**: (1) `BimodalReference.typ` dividers/includes/abstract/sources;
  (2) `00-introduction.typ` roadmap rewrite; (3) delete
  `chapters/p5-counterfactual.typ`, `chapters/p5-constitutive.typ`,
  `notation/constitutive-notation.typ`; (4) `notation/bimodal-notation.typ` comment
  cleanup (+ `store`/`recall` dead-code decision); (5) `bibliography.bib` prune (12
  removed-only entries unconditionally, 2 orphaned-after-intro-edit entries as a
  planner decision); (6) `README.md`, `SYNC-MAP.md` (append-only note),
  `sync-check-whitelist.txt` sync; (7) compile + `typst-sync-check.sh` verification
  pass.
- **Zero dangling-reference risk** from retained chapters into removed ones (§3) --
  the plan does not need a "fix forward references" phase, only a "delete + rewrite
  the two files that talk about the removed parts" phase.
- **One explicit decision the plan should surface to the user/implementer**: whether
  `brastmckie2025counterfactualworlds`/`brastmckie2021identity` bib entries and the
  `store`/`recall` notation functions should be deleted (strict "all and only") or
  retained (minimal footprint) -- both are defensible, framed in §2.5 and §3.
