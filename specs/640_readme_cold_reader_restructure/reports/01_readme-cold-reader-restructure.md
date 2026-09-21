# Research Report: Task #640

**Task**: 640 - Readme cold reader restructure
**Started**: 2026-09-20T00:00:00Z
**Completed**: 2026-09-20T00:00:00Z
**Effort**: Medium (prose restructuring across 2 files, no code changes)
**Dependencies**: Task 639 (completed — README accuracy/entry-point fixes already landed)
**Sources/Inputs**: Codebase (`README.md`, `docs/reference/paper-definitions-of-record.md`,
`docs/development/MODULE_INVARIANTS.md`, `docs/theorem-index.md`, `FormalSystem/MainResults.lean`,
`CONTRIBUTING.md`, `docs/README.md`), `scripts/readme-lint.sh`, `scripts/check-module-invariants.sh`
(C12–C15, C18, C21), `.github/workflows/ci.yml`, `.gitignore`, live baseline runs of both gate
scripts
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The five acceptance items are all achievable with prose-only edits to `README.md` plus one new
  dated section in `docs/reference/paper-definitions-of-record.md`. No `.lean`, no anchor pin, no
  manifest row, no `scripts/check-paper-definitions.sh` re-pin is required.
- **The line budget for item 1 is tight and must be actively managed.** As of this baseline,
  `README.md` lines 1–40 run title → badges → 3 intro paragraphs → 4 link lines (Paper /
  Reference Manual / Main Results / Demo) → the generated inventory block (already 10 lines,
  protected) → its one explanatory paragraph (wraps 3 source lines) → `---` → `## Operators`
  starts exactly at line 40. There is currently zero slack; a results summary cannot simply be
  appended, something existing in lines 1–40 must be tightened or reflowed to make room.
- **Two of the three named revision-history passages are movable with no new research needed on
  the destination side**: the aside about the saturation footnote's pre-2026-09 "strictly
  stronger" wording is **already fully documented** at `docs/reference/paper-definitions-of-record.md`
  lines 969–980 (`def:frame#Saturation`'s "2026-09-07 wave" note). The README's aside is therefore
  redundant today; item 2's move for that clause is a **deletion** from README, not new content in
  the record. The other two paragraphs (about the paper's TM_r naming and the axiom-basis
  question) are about the *README's own past text*, not the paper's, and have no existing
  counterpart in the record — a new dated, prose-only section following the file's own
  "Language correspondence (2026-09-08): permanent, prose only, no re-pin" precedent is the
  right destination shape.
- **The Tags footer's "TM-plus" is stale against the repository's own current naming.** Every
  live surface (`docs/README.md`, `docs/theorem-index.md`, `FormalSystem/README.md`) now writes
  the since/until stability-modal system as `TM⁺` (superscript plus), not `TM-plus` or `TM+`; the
  repository's naming-migration record (`docs/README.md`'s language-correspondence paragraph)
  explicitly states "Earlier revisions also called the since/until system `TM⁺`... those names
  have been retired" for the *H/G* system, but `TM⁺` itself remains the live name for the
  stability-modal fragment. Rename to match, or drop the footer — `## Tags` is a repository
  convention CI does not enforce for the root README (only `.lean` doc-comment Tags sections are
  covered by the publication-refactor decision to keep `## Tags`), so dropping it is also safe.
- Both acceptance gates are green at baseline: `bash scripts/check-module-invariants.sh --no-build`
  → `ALL CHECKS PASSED`; `bash scripts/readme-lint.sh` → `RESULT: PASS` (0 missing READMEs, 0
  broken references). The plan/implementation should re-run both after every edit, not just at
  the end, because several gates (C13, C14, C15) read `README.md` directly and a partial edit can
  transiently break a link or an anchor.

## Context & Scope

Task 640 restructures `README.md` for a "cold" reader (arrives with no context, budgets two
minutes) without changing any factual claim task 639 already corrected. The five numbered items
in the task description are additive/organizational: move a results summary up, move stale
revision-narration out, add a new short section, fix one footer token, and preserve every
generated/harness-checked element. No Lean source is in scope. `docs/reference/paper-definitions-of-record.md`
is in scope only for the item-2 destination; its MANIFEST/KNOWN-ANCHORS machinery must not be
touched (no anchor is added or removed by this task).

Task 639 (dependency, completed) already fixed axiom-count consistency, the MinusLanguage/PlusLanguage
tree-placement, the MainResults.lean link, and other factual defects in the same README — this
task is purely about ordering/placement/pruning of already-correct prose, not re-verifying facts
task 639 settled.

## Findings

### Codebase Patterns

**Current `README.md` structure (478 lines total)**:

| Lines | Content |
|---|---|
| 1 | `# A Bimodal Logic for Tense and Modality` |
| 3–7 | Badges (CI, API docs, License, Lean, Mathlib) |
| 9 | Opening paragraph ("This repository implements the **bimodal fragment**...") |
| 11 | "Whereas dynamical systems theory..." paragraph |
| 13 | "The repository implements the syntax..." paragraph |
| 15 | **Paper** link line |
| 17 | **Bimodal Reference Manual** link line |
| 19 | **Main Results**: `FormalSystem/MainResults.lean` link line |
| 21 | **Demo**: `FormalSystem/Examples/BimodalProofs.lean` link line |
| 23–31 | `<!-- BEGIN GENERATED: inventory ... -->` ... `<!-- END GENERATED -->` block (protected — rewritten by `check-module-invariants.sh --emit-inventory`, checked by its `INV` gate) |
| 34–36 | One explanatory paragraph about the generated table (wraps across 3 hard-wrapped source lines) |
| 38 | `---` |
| 40 | `## Operators` (section start) |
| ... | Operators, Task Semantics, Project Structure, Installation sections |
| 169–345 | `## Metalogical Results` through `## Documentation` — **this is where the actual proof results live today** (soundness/completeness table, mermaid diagram, axiom systems table, the four-object-language mapping, decidability, characterization/definability) |
| 386–429 | `## Verifying the main theorems` — the two verification commands (`#print axioms` snippet and `check-module-invariants.sh`), the "105 pinned declarations" figure, and the `docs/theorem-index.md` pointer |
| 476–478 | `## License` / `## Tags` footer, `bimodal-logic · TM-plus · soundness · completeness · compactness · decidability · lean4` |

**Item 1 — results summary, exact facts to state** (all verified live against
`## Metalogical Results`, lines 169–345, and `## Verifying the main theorems`, lines 386–429):
- Soundness and weak completeness are proved at **all four** frame classes: Base, Dense, ZTime,
  RTime (`soundness`/`completeness`, `soundness_dense`/`completeness_dense`,
  `soundness_ztime`/`completeness_ztime`, `soundness_rtime`/`completeness_rtime`).
- Strong completeness (infinitary-premise-set consequence) is a **separate, three-way-split**
  claim: **proved** at Base and Dense (`strongCompletenessBase`, `strongCompletenessDense`, via
  an ultraproduct compactness argument), **machine-refuted** at ZTime and RTime
  (`notStrongCompletenessZTime`/`notCompactZTime`, `notStrongCompletenessRTime`/`notCompactRTime`).
  The refutations are as load-bearing a fact as the proofs — they are theorems, not gaps.
- Every flagship result is `sorryAx`-free with axioms exactly `[propext, Classical.choice,
  Quot.sound]` — the repository's own phrasing is "zero sorry and zero custom axioms" (only
  Lean/Mathlib's own standard classical axioms, never a project-specific one).
- The harness (`scripts/check-module-invariants.sh`) pins the axiom set of **105** declarations
  (4 via check C2's exact-string baseline, the rest via C14's baseline pair; C21 asserts every
  name `MainResults.lean` advertises is among them) — this is the number already stated in the
  existing "Verifying the main theorems" section (line 415) and should be reused, not
  re-derived.
- Correct link targets: `FormalSystem/MainResults.lean` (already exists as a README link at line
  19, "Main Results") and `docs/theorem-index.md` (already the "single ledger" pointer used
  throughout the file, e.g. lines 261–263, 428–429).

**Line-budget mechanics for the first-40-lines acceptance bar**: the generated inventory block
(lines 23–31) and its one explanatory paragraph (34–36) are both **protected** — item 5 requires
keeping the generated block intact, and `check-module-invariants.sh`'s `INV` check regenerates
and diffs the exact table content, not merely its presence, so the paragraph immediately below it
that explains the regeneration command is also effectively load-bearing (removing it would strand
an unexplained table for a cold reader, working against this task's own goal). That leaves the
badges (fixed, 5 lines), the 3 intro paragraphs (9, 11, 13 — currently ~3 lines), and the 4 link
lines (15, 17, 19, 21 — currently ~4 lines) as the only compressible material before line 38's
`---`. A compact results-summary (a short paragraph or 4–6 short bullets, referencing the same
Main Results / theorem-index links already at lines 19 and 261) fits only if something in that
same span is shortened by a comparable number of lines — e.g., merging the two background
paragraphs (11, 13) into one, or converting the four link lines into a denser inline form. This
is a placement/compression decision for planning, not something this report should pre-decide,
but the arithmetic is exact enough that the plan should budget line-by-line rather than treat "add
a paragraph" as free.

**Item 2 — the three passages to move, located and cross-checked against the destination file**:

1. `README.md:88` — the saturation-footnote aside: "— the footnote said *strictly stronger* until
   the paper's 2026-09 revision withdrew the strictness claim." **Already recorded** at
   `docs/reference/paper-definitions-of-record.md:969-980`, under the `def:frame#Saturation`
   entry's "2026-09-07 wave" note: "The ball-space footnote was softened from 'strictly stronger'
   to 'at least as strong as'... The strictness claim was withdrawn, not merely reworded... (The
   2026-08-25 narrative table below records the *old*, strict wording; it is historical and is
   deliberately left as written.)" This is the authoritative, more precise version of the same
   fact. **Action for this passage is deletion from README, not addition to the record** — the
   record does not need this content written to it a second time. Whether the README's saturation
   sentence should point to the record instead of narrating the history at all (e.g. "...at least
   as strong as 'spherically complete' (`S₁`); see `docs/reference/paper-definitions-of-record.md`
   for the definition's revision history.") is an optional refinement in scope of "no paragraph
   describes a previous state" — a bare pointer states a fact about where history lives, it does
   not itself narrate that history.

2. `README.md:211` — "Earlier revisions of this README described the paper's complete-order
   system as completeness *simpliciter* with models `{ℤ, ℝ}` and theory `Th(ℤ) ∩ Th(ℝ)`, and
   concluded that no element of `FrameClass` picks the class out. That is stale on both counts:
   the `{ℤ, ℝ}` / `Th(ℤ) ∩ Th(ℝ)` footnote is commented out in the live `def:BX-r`, and the class
   the paper names is dense-and-complete, not complete-simpliciter."

3. `README.md:213` — "The axiom-basis question this README used to record as open is answered as
   well: `def:BX-r` bases BX_r on the **dense** logic BX_d extended by `TMP-PU` and `TMP-SEP`, so
   the density axioms are present on the paper's side too, and `completeness_rtime` proves the
   corollary's own statement rather than a stronger-premise variant. CO is derived rather than
   assumed on both sides."

   Passages 2 and 3 have **no existing counterpart** in `paper-definitions-of-record.md` — they
   narrate the README's own prior claims, not the paper's revision history, so they are not
   "resolution data" the C15 exclusion already covers. The both anchors they cite
   (`cor:tm-completeness` at README line 211/234, `def:BX-r` at 211/213/233) remain cited
   elsewhere in README (lines 233–234) after these two paragraphs are removed, so **C15's
   paper-anchor-resolution gate is unaffected by deleting them** — verified live: `grep -noE`
   over README shows both anchors also appear outside lines 211–213.

   The record file's own structure gives a direct precedent for where this content belongs:
   "### Language correspondence (2026-09-08): permanent, prose only, no re-pin" (lines 265–314)
   is a dated section that states a fact about the *repository's naming history* relative to the
   paper, explicitly marked "prose only, no re-pin" (no MANIFEST row, no anchor, no checksum
   change) — the exact category passages 2 and 3 fall into. A new dated section
   (e.g. "### README claim retired (2026-09-2X): TM_r naming and the BX_r axiom basis") following
   that section's format — stating what the README used to say, and pointing at
   `def:BX-r`/`cor:tm-completeness`'s entries (lines 1560–1567, 1713–1733) for the current text —
   is a faithful placement. An equally valid alternative is a short "Note:" appended directly to
   the `def:BX-r` and/or `cor:tm-completeness` entries themselves (the file already uses that
   pattern, e.g. `def:frame-properties`'s "Note: promoted into coverage by this task..." at line
   1678). Either placement keeps `scripts/check-paper-definitions.sh`'s verdict unchanged (prose
   change only, no anchor added or re-hashed).

**Item 3 — "How this repository is developed" section, grounding facts**:
- `specs/` is git-tracked (confirmed via `git ls-files specs/`) and visible to any reader browsing
  the repository on GitHub; task directories under `specs/{NNN}_{SLUG}/` are present in the
  tracked tree today (e.g. `specs/627_.../`, `specs/629_.../`).
- `CLAUDE.md` at the repository root is **gitignored** (`.gitignore:80` — `/CLAUDE.md`; confirmed
  absent from `git ls-files`). A cold reader browsing GitHub will **not** see it; it exists only
  in a local working tree (e.g. one cloned before task 631's untracking, or authored locally).
  The new section should therefore frame `CLAUDE.md` as something a *local contributor* opens,
  not something visible on the GitHub page — the task description's "a reader who opens specs/ or
  CLAUDE.md" already reads consistently with that (specs/ is the GitHub-visible half, CLAUDE.md
  the local-clone half).
- `CONTRIBUTING.md` already carries a "## 10. AI-Assisted Development" section (lines 376–422)
  describing the command-driven workflow (`/research`, `/plan`, `/lean`, `/meta`) and pointing out
  that `.claude/` itself is gitignored and regenerable. That section does **not** state the trust
  model this task's item 3 asks for (correctness resting on the Lean kernel + invariant harness,
  not on review of agent output) — it describes the workflow, not the epistemics. The new README
  section should be a short pointer complementary to, not a duplicate of, that CONTRIBUTING.md
  section; consider whether the new section should also link `CONTRIBUTING.md`'s section
  alongside `docs/development/MODULE_INVARIANTS.md`.
- `docs/development/MODULE_INVARIANTS.md` (the task's named link target) opens with exactly the
  framing this section needs: "`scripts/check-module-invariants.sh` answers one question
  mechanically: did a change to the module structure break anything? It exists so that 'nothing
  broke' is a command with an exit code rather than a judgement call," followed by a 30-row table
  of what each check (C1–C30) asserts. This is the right single link target; no other doc states
  the trust model as directly.
- No existing prose in `README.md`, `docs/`, or `CONTRIBUTING.md` currently states "correctness
  rests on the Lean kernel... not on review of agent output" in those or similar words — this is
  new content to author, not content to relocate.

**Item 4 — Tags footer**: `bimodal-logic · TM-plus · soundness · completeness · compactness ·
decidability · lean4` (README.md:478). `TM-plus` does not occur as a live naming convention
anywhere else in the tree (`grep -rn "TM-plus"` outside `specs/` and this one README line returns
nothing under `docs/` or `FormalSystem/`). The live convention, confirmed in `docs/README.md`
(lines 30-58), `docs/theorem-index.md` (multiple headers, e.g. "### TM⁺ over the deterministic
frames"), and `README.md` itself (the "four object languages" table, lines 217–260) is `TM⁺`
(Unicode superscript plus). `## Tags` as a heading is a Mathlib/doc-gen4 convention this
repository has decided to keep for `.lean` module docstrings
(`docs/development/PUBLICATION_REFACTOR.md:220`: "`## Tags` stays (Mathlib-legal)"), but that
decision is about `.lean` files' doc comments, not the root `README.md`'s own footer — nothing
gates or requires the root README to carry a `## Tags` section at all, so dropping it is a
available, harness-neutral option alongside renaming.

**Item 5 — protected elements, enumerated**:
- The generated inventory block, lines 23–31 (`<!-- BEGIN GENERATED: inventory ... -->` /
  `<!-- END GENERATED -->`), regenerated by `check-module-invariants.sh --emit-inventory` and
  diffed by its `INV` gate — must not be hand-edited, and its surrounding position relative to any
  reflow should keep the begin/end markers and the explanatory paragraph together.
- Every paper anchor citation (`def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:` forms) currently in
  README — `cor:tm-completeness` (211, 234), `def:BX-r` (211, 213), `def:BLplus-language` (233),
  `def:TMplus` (233), `app:deterministic-future` (242), `def:BLstar-semantics` (243),
  `def:frame-properties` (328) — checked by C15. Removing the two revision-history paragraphs at
  211/213 removes two of the eight *occurrences* but zero of the underlying *anchors* (each still
  cited at least once elsewhere in the file), so C15 stays green; this was verified directly
  rather than inferred.
- Every relative markdown link and slash-shaped source path in README — checked by C12/C13 (in
  `check-module-invariants.sh`) and by `readme-lint.sh`'s own Check 3 only when the script is
  pointed at a non-Lean root (its default root is `FormalSystem`, so root `README.md`'s own links
  are actually gated by C12/C13, not by a default `readme-lint.sh` invocation — CI's
  "Check README health" step runs `bash scripts/readme-lint.sh` with no root argument, i.e.
  `FormalSystem` only. `check-module-invariants.sh` is therefore the check that actually covers
  root `README.md`'s links; this distinction matters for verification instructions in the
  eventual plan/summary — do not rely on `readme-lint.sh` alone to catch a broken README.md link).
- Every documented axiom/sorry count claim in README, checked by C14. No numeric axiom count
  (29/37/40/39/42/45) needs to appear in the new results summary or the new "How this repository
  is developed" section — the task's own item-1 wording ("zero sorry and zero custom axioms")
  needs no digit-then-word-order phrase that could trip C14's regex. One existing fragility is
  worth flagging for anyone editing nearby prose: the phrase "the 45 TM schemata" at README lines
  274–275 currently escapes C14's stale-count regex only because it is split across two source
  lines ("...the 45 TM" ends line 274, "schemata re-declared..." begins line 275) — the regex
  matches per line. This is far from the sections item 1–4 touch, but any *unrelated* rewrap of
  that paragraph during this task should preserve the line break, or the phrase should be
  reworded, to avoid an accidental C14 failure that has nothing to do with this task's own edits.

### External Resources

None consulted — this is a purely internal restructuring task; no external documentation or
tutorial is relevant to the content decisions involved.

### Recommendations

1. **Do item 5 verification-first**: before any edit, run `bash scripts/check-module-invariants.sh
   --no-build` and `bash scripts/readme-lint.sh` and record both as green baselines (already
   confirmed green in this research pass), then re-run both after each of items 1–4 rather than
   only once at the end — C12/C13/C14/C15 all read `README.md` directly and a half-completed
   paragraph move is exactly the shape of edit that trips a link or an anchor-count check
   transiently.
2. **Order the edits 2 → 1 → 4 → 3** (or any order that does items 2 and 4 first): items 2 and 4
   are pure deletions/renames with no line-budget interaction, so doing them first shrinks the
   file and gives item 1's line-budget arithmetic more headroom before the hardest edit (fitting
   a summary in the first 40 lines) is attempted. Item 3 (a wholly new section) can go anywhere
   convenient — e.g. immediately after "Installation" and before "Metalogical Results", or as
   part of the "Related Projects" / "Documentation" neighborhood — since it carries no line-40
   constraint.
3. **For item 1, reuse rather than duplicate the existing "Main Results" (line 19) and "Demo"
   (line 21) link lines** — the task's own wording asks for links to `MainResults.lean` and
   `docs/theorem-index.md`, both already present as top-of-file links or as the file's declared
   "single ledger." A tight summary can read as a short paragraph or bullet list situated between
   the opening paragraph (9) and the Paper/Reference Manual/Main Results/Demo link block (15–21),
   or the four link lines can be folded into the summary itself (e.g. "Main Results" and "Demo"
   become the summary's own closing links) rather than kept as a separate block — either keeps the
   total addition small enough to land inside line 40.
4. **For item 2's passages 2 and 3, prefer appending a short dated note to the existing
   `def:BX-r`/`cor:tm-completeness` entries** in `paper-definitions-of-record.md` over authoring a
   free-standing new section, since the file already has a "Note:" convention at the entry level
   (`def:frame-properties`, line 1678) for exactly this kind of "here is a fact worth recording
   near this anchor" addition, and it keeps the corrected content co-located with the anchor it
   is about rather than requiring a reader to jump between a dated changelog section and the
   entry itself. A new top-level dated section (matching "Language correspondence
   (2026-09-08)") is the sound alternative if the note grows long enough to want its own heading.
5. **For item 4, rename rather than drop**, unless the plan finds a repository-wide reason to
   retire `## Tags` from the root README specifically — `TM⁺` (matching every other live surface)
   is the direct fix and costs nothing; dropping the footer removes searchable metadata
   (`bimodal-logic`, `soundness`, `completeness`, `compactness`, `decidability`, `lean4`) that
   currently has no other home in the README.
6. **State the "How this repository is developed" section's link as
   `docs/development/MODULE_INVARIANTS.md`** per the task description, and consider a secondary
   pointer to `CONTRIBUTING.md`'s existing "AI-Assisted Development" section for the *workflow*
   half (what the commands do), keeping the new README section itself focused on the *trust
   model* half (kernel + harness, not review) that no existing doc currently states.

## Decisions

- No anchor, MANIFEST row, or `check-paper-definitions.sh` re-pin is needed for the
  `paper-definitions-of-record.md` addition — it is prose-only, matching the file's own
  "Language correspondence (2026-09-08): permanent, prose only, no re-pin" precedent.
- The saturation-footnote aside (item 2's third passage) requires no new content in the
  destination file — it is already recorded there; the README-side action is a deletion (or a
  pointer replacement), not a migration of new text.
- `readme-lint.sh` alone does not gate root `README.md`'s links under its default (CI) invocation
  — `check-module-invariants.sh`'s C12/C13 are the actual link/path gate for the root file. Both
  should be run, but neither should be treated as redundant with the other for this file.

## Risks & Mitigations

- **Risk**: the item-1 line budget is genuinely tight (0 lines of slack today), and an
  implementer who treats "add a summary" as purely additive will blow past line 40. **Mitigation**:
  budget line-by-line during planning (see Findings' exact line inventory above); compress the
  two background paragraphs and/or the four link lines before adding the summary, and count the
  final result before calling item 1 done.
- **Risk**: deleting the two README revision-history paragraphs (lines 211, 213) could be
  (wrongly) assumed to also require deleting their cited anchors, which would break C15 if those
  anchors were not cited elsewhere. **Mitigation**: this report already verified both anchors
  (`cor:tm-completeness`, `def:BX-r`) recur outside lines 211–213, so no anchor-citation cleanup
  is needed; re-verify with `grep -noE '\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*'
  README.md` after the edit as a cheap confirmation.
- **Risk**: editing prose near README lines 274–275 (unrelated to this task) could accidentally
  join "45 TM" and "schemata" onto one source line, tripping C14's stale-axiom-count regex for a
  reason unconnected to this task's own changes. **Mitigation**: this task's edits do not touch
  that region; simply avoid reflowing paragraph 274–276 as a side effect of a global find/replace
  or markdown reformatter.
- **Risk**: `docs/reference/paper-definitions-of-record.md` is a 2113-line file with a strict
  "never restates, re-derives, or improves any definition it records" charter — an implementer
  drafting the new dated note could accidentally invent or paraphrase paper text rather than
  quoting/pointing at the already-pinned `def:BX-r`/`cor:tm-completeness` entries. **Mitigation**:
  the new note should describe the *README's* prior claim and point at the existing entries
  (already-quoted paper text) for the current fact, never re-quote or re-derive paper text itself.

## Context Extension Recommendations

None. `docs/development/MODULE_INVARIANTS.md`, `docs/reference/paper-definitions-of-record.md`,
and `docs/theorem-index.md` already document everything this task's new prose needs to point at;
no new context file is warranted.

## Appendix

**Search queries / commands used**:
- `sed -n` over `README.md` (full file, in three passes) to enumerate exact line numbers for
  every item this task names.
- `grep -rn "TM-plus\|TM_plus\|TMPlus"` and `grep -rn "TM⁺"` across `docs/`, `README.md`,
  `specs/` to establish current vs. stale naming.
- `grep -noE '\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*' README.md` to enumerate every
  paper anchor citation in scope for C15, and to confirm which occurrences survive the item-2
  deletions.
- `grep -n -i "saturation\|spherically complete"` over `paper-definitions-of-record.md` to locate
  the existing record of the footnote's strictness-claim withdrawal.
- `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/readme-lint.sh` (both run
  live during this research pass): `ALL CHECKS PASSED` / `RESULT: PASS` baselines.
- `git ls-files specs/`, `grep -n "CLAUDE" .gitignore` to establish specs/ tracked vs. CLAUDE.md
  gitignored, for item 3's audience framing.

**References**:
- `scripts/check-module-invariants.sh` — C12 (slash-path resolution), C13 (markdown link
  resolution), C14 (axiom/sorry count tripwires), C15 (paper-anchor resolution), C18
  (paragraph-duplication census, reporting-only), C21 (MainResults axiom-pin closure).
- `scripts/readme-lint.sh` — Check 1–4; default root `FormalSystem`, so root `README.md` links
  are NOT in its default (CI) scope.
- `docs/development/PUBLICATION_REFACTOR.md:220` — `## Tags` keep-decision (scoped to `.lean`
  docstrings).
- `docs/reference/paper-definitions-of-record.md:265-314` — "Language correspondence
  (2026-09-08): permanent, prose only, no re-pin" (placement precedent for item 2).
- `docs/reference/paper-definitions-of-record.md:969-980` — existing record of the saturation
  footnote's strictness-claim withdrawal.
