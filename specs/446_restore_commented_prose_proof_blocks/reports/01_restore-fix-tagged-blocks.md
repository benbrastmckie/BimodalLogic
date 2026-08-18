# Research Report: Task #446

**Task**: 446 - Address 6 bare `// FIX:` tags in `typst/FormalFoundations.typ`
**Started**: 2026-08-18T00:00:00Z
**Completed**: 2026-08-18T00:00:00Z
**Effort**: small (single-file, 6 well-scoped sites, no external dependencies)
**Dependencies**: None
**Sources/Inputs**: `typst/FormalFoundations.typ`, `typst/bibliography.bib`, live `typst compile` baseline
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All 6 bare `// FIX:` tags should be **restored** (uncommented) essentially verbatim, with the
  tag line deleted. None require rewriting or deletion — each block is mathematically correct,
  internally consistent with the current (live) definitions/theorems it sits beside, and uses the
  same markup conventions (`*Name*` emphasis for named axioms/theorems, `#proof[...]`/plain-prose
  paragraphs, `@label` cross-references, backticked Lean-identifier footnote pointers) already in
  active use throughout the rest of the document.
- Every cross-reference used inside the 6 blocks resolves against a real target in the current
  file: `@sec:representation`, `@sec:objective-modality`, `@sec:histories` (labels exist), the
  bibliography keys `@brastmckie2026possibleworlds`, `@blackburnderijkevenema2001` (both defined in
  `typst/bibliography.bib`), and the axiom names `*Seriality*`, `*Limit*`, `*Spherical*`,
  `*Compositionality*` (all defined in the "Frame" definition, lines 209-224).
- I independently re-derived the two restored proofs (Nullity and Separation/T1) against the
  Frame, Cone/Fiber, and converse-convention definitions currently in the file — both are correct.
- One adjacent, thematically-continuous block (the `#remark[...]` at lines 304-315, following the
  Separation-proof FIX site) is *also* commented out but carries **no FIX tag of its own** — it is
  strictly outside this task's enumerated 6 sites. I flag it as a judgment call for the
  implementation phase rather than deciding it here (see Context & Scope).
- Baseline `typst compile typst/FormalFoundations.typ` currently succeeds (exit 0, only harmless
  "unknown font family" warnings from the `thmbox` package). This is the pre-change baseline the
  implementation phase's verification step should still pass after restoring the 6 blocks.

## Context & Scope

The task asked me to locate 6 **bare** `// FIX:` tags (i.e. `// FIX:` with no trailing
explanation text) in `typst/FormalFoundations.typ`, read the commented-out content at each site,
and determine restore/rewrite/delete for each, without editing the file (research dispatch only).

`grep -n "FIX:" typst/FormalFoundations.typ` currently returns 12 matches. Of these, exactly 6 are
bare (`// FIX:` with nothing else on the line, matching the task's count); the other 6 carry
explanatory text after the colon (e.g. `// FIX: this proof is inadequate and should be fixed by
including the lemmas it needs to cite, drawing on .../possible_worlds.tex...` at line 261, `// FIX:
indent the axioms...` at line 381, etc.) and are **out of scope** for this task — they describe
different problems (an admittedly-inadequate proof needing citation work, readability/expansion
requests, a missing section introduction) that are not "commented-out prose/proof text to be
restored verbatim." I did not analyze those in depth beyond confirming they are distinct from the
6 in scope; they should be left untouched by this task's implementation phase.

Line numbers have drifted modestly from the task description (~+14 by the last site) but the
six bare tags map unambiguously one-to-one onto the task's six described locations, by content
match:

| Task's `:N` | Current line | Site |
|---|---|---|
| `:214` | `228` | Nullity lemma proof (Seriality at x=0) |
| `:257` | `275` | Step Lemma / Spherical localization prose + `lem:step` footnote |
| `:263` | `281` | "cones are a basis... separated" prose |
| `:277` | `295` | Separation theorem proof (T1, hence R0) |
| `:323` | `345` | Block following the Truth/`square.stroked`-clause definition |
| `:342` | `370` | Block following the Validity-and-Consequence definition |

`typst/FormalFoundations.typ` is 1152 lines. Baseline compile (`typst compile
typst/FormalFoundations.typ`) succeeds today with exit 0 and only two harmless `thmbox`-package
font warnings ("unknown font family: new computer modern sans") — unrelated to this task and safe
to ignore.

## Findings

### Codebase Patterns

The live (non-commented) document already exercises every convention the 6 commented blocks use,
which is strong evidence these blocks are original, intentional content that got commented out
(e.g. mid-draft) rather than deliberately superseded material:

- `#proof[...]` immediately follows a `#theorem(...)`/`#lemma(...)` block with no blank line, body
  indented 2 spaces, e.g. the live `Dichotomy` proof (line ~613-621) and `Necessity of temporal
  structure` proof (line ~869-873).
- `*Name*` bold-asterisk emphasis is the document's standing convention for referring to a named
  axiom/theorem in prose — used live for `*Spherical*` (lines 532, 720, 1113, 1127, 1143, 1147)
  and `*Compositionality*` (line 1127), exactly matching the emphasis style inside the 6 commented
  blocks.
- Backticked Lean-identifier-style pointers inside footnotes (e.g. `` `multiFamGen_spherical` ``,
  `` `cor:spherical-finite` ``, `` `thm:extension` `` at live line 723) match the `` `lem:step` ``
  and `` `cor:spherical-finite` `` pointers used inside the commented footnote at line 278 —
  the *same* label strings are reused live at line 723 ("the finite-carrier discharge
  (`cor:spherical-finite`) and the Zorn route through the Step Lemma (`thm:extension`)"), which is
  strong direct evidence the commented block at 275-279 is the passage that *introduces* those
  same pointers and is meant to be live.
- `@sec:representation`, `@sec:objective-modality`, `@sec:histories` are all real, currently-defined
  section labels (`= Toward a Representation Theorem <sec:representation>` at line 981; `==
  The Strongest Objective Modality <sec:objective-modality>` at line 928; `== Histories and the
  Task Topology <sec:histories>` at line 238) — every forward-reference inside the 6 blocks
  resolves.
- `@brastmckie2026possibleworlds`, `@blackburnderijkevenema2001`, `@scott1970advice` are all real
  entries in `typst/bibliography.bib` (confirmed via grep), and `#bibliography("bibliography.bib")`
  is wired at line 1152, so citations inside the restored blocks will resolve at compile time.

### Per-site analysis

**1. Line 228 — Nullity lemma proof.**
```
#proof[
  *Seriality* at $x = 0$ gives $u$ with $w arrow.r.double.long_(0) u$. Since $|0| < x$ for every
  $x > 0$, $u in (w)_x$ for every such $x$, so $u in inter.big_(x>0)(w)_x = {w}$ by *Limit*, whence
  $u = w$.
]

Nullity is derived, not postulated, and its derivation uses no choice. The distinction matters
below: two of the three results in @sec:histories are theorems of ZFC.
```
Verified against the Frame definition (lines 209-224): *Seriality* at `x=0` gives `u` with
`w ⇒_0 u`. Since `Fib(w,0) ⊆ (w)_x` for every `x>0` (as `|0|<x`), `u ∈ (w)_x` for every `x>0`,
hence `u ∈ ∩_{x>0}(w)_x = {w}` by *Limit*, so `u = w`. This is a correct, complete proof
consistent with the current Cone/Fiber/Limit definitions (lines 193-224). It uses no choice, as
claimed. The forward pointer to `@sec:histories` ("two of the three results ... are theorems of
ZFC") is corroborated by the restored line-275 block, which explicitly says "Extension and
Occurrence are theorems of ZFC, in contrast with Nullity" — i.e. Extension/Occurrence require the
Axiom of Choice (via Zorn's Lemma, used in the — out-of-scope — Extension proof at line 260),
while Separation (the third result of `@sec:histories`, alongside Extension and Occurrence) does
not, matching "two of the three." This cross-block consistency is a strong signal both were
written together and belong live.
**Decision: RESTORE verbatim** (delete the `// FIX:` line, uncomment, keep the blank line that
currently appears as `//` alone between the proof and the following prose paragraph).

**2. Line 275 — Step Lemma / Spherical localization + line 281 — cones/basis prose (two adjacent bare tags, both under task's `:257`/`:263`).**
```
The Step Lemma is the sole application site of *Spherical* in the paper, and Extension is the sole
consumer of the Step Lemma; every appeal to *Spherical* in the semantics passes through this one
point.#footnote[`lem:step`. @brastmckie2026possibleworlds *Spherical* is not needed when the
directed family has a $subset.eq$-least member, and on a finite carrier it holds outright and
choice-free (`cor:spherical-finite`).] Extension and Occurrence are theorems of ZFC, in contrast
with Nullity. That localization is what makes *Spherical* the identified obstruction of
@sec:representation.

The cones are a basis for a topology on world states, and that topology is separated.
```
These are two separate bare `// FIX:` tags at 275 and 281, corresponding to the task's two
described locations `:257` and `:263` respectively (which sit only 6 lines apart in the task
description's own numbering, confirming they were always two adjacent short paragraphs, not one
block). Both are plain prose (no `#proof[...]`/`#remark[...]` wrapper), matching their un-commented
neighbors stylistically.

- The first paragraph's claim ("Step Lemma is the sole application site of *Spherical*... Extension
  is the sole consumer... every appeal to *Spherical* passes through this one point") is corroborated
  by the rest of the document: `@sec:representation` (line 1113) independently states "*Spherical*
  is the one [axiom] that resists" among the four frame axioms, and lists exactly the same "three
  discharge patterns" vocabulary (finite carrier / Zorn route through the Step Lemma / deterministic-
  fiber argument) that this restored paragraph sets up. The `` `cor:spherical-finite` `` and
  `` `thm:extension` `` backticked pointers this paragraph's footnote defines are reused live at
  line 723. This is the passage the rest of the document's "Spherical is the obstruction" narrative
  depends on — restoring it is necessary for that narrative's setup, not just decorative.
- The second paragraph ("cones are a basis... topology is separated") is a one-line preview
  correctly describing the `Task Topology` definition immediately below it (line 284: cones
  `(w)_x` closed under arbitrary union and finite intersection = a basis, by definition) and the
  `Separation` theorem two blocks later (line 294: T1, hence R0 = "separated" in the informal sense
  used here).
**Decision: RESTORE both verbatim** (delete both `// FIX:` lines; keep the blank line separating
the two paragraphs, matching the current blank `// FIX:`-tag-separated layout).

**3. Line 295 — Separation theorem proof (T1, hence R0).**
```
#proof[
  ${u} subset.eq overline({u})$ is immediate. Conversely let $w in overline({u})$. By Nullity
  every basic open $(w)_x$ contains $w$, so $u in (w)_x$ for every $x > 0$.
  Hence for each such $x$ there is $y$ with $|y| < x$ and $w arrow.r.double.long_(y) u$, so $u arrow.r.double.long_(-y) w$
  by the converse convention and $w in (u)_x$.
  Thus $w in inter.big_(x>0)(u)_x = {u}$ by *Limit*, and so R0 follows.
]
```
I independently re-derived this proof against the current definitions and it is correct:
- `closure({u}) := {w : O∩{u}≠∅ for every open O∋w}` (Task Topology definition, line 289).
- `{u} ⊆ closure({u})` is immediate (u is in every open set containing it, trivially including {u}
  itself as a witness... more precisely u trivially satisfies the closure membership condition for
  itself).
- Conversely, take `w ∈ closure({u})`. By Nullity (`w ⇒_0 w`), `w ∈ Fib(w,0) ⊆ (w)_x` for every
  `x>0`, so every basic open `(w)_x` is an open neighborhood of `w`; since `w ∈ closure({u})`, each
  such `(w)_x` must meet `{u}`, i.e. `u ∈ (w)_x` for every `x>0`.
- `u ∈ (w)_x = ∪_{|y|<x} Fib(w,y)` gives, for each `x>0`, some `y` with `|y|<x` and `w ⇒_y u`.
- The converse convention (`w ⇒_{-z} u := u ⇒_z w` for `z≥0`) is symmetric in the sense needed: for
  any `y` (positive or negative), `w ⇒_y u ⟺ u ⇒_{-y} w` — this holds by direct substitution into
  the convention's defining biconditional in both the `y≥0` and `y<0` cases. So `u ⇒_{-y} w`, giving
  `w ∈ Fib(u,-y) ⊆ (u)_x` since `|-y| = |y| < x`.
- Since this holds for every `x>0`, `w ∈ ∩_{x>0}(u)_x = {u}` by *Limit* (applied to `u`), so `w=u`.
- Hence `closure({u}) ⊆ {u}`, giving `closure({u}) = {u}`, i.e. T1. "and so R0 follows" correctly
  invokes the standard general-topology fact that T1 ⟹ R0 (not something specific to this space) —
  appropriately left as a one-clause remark rather than re-proved.
**Decision: RESTORE verbatim.** Minor optional polish (not required, noted for the implementation
phase's discretion): "the converse convention" is referenced in plain text here, whereas the
document's convention elsewhere is to bold-emphasize a defined term on first use per proof (e.g.
"by *Limit*" is emphasized twice in this very proof); the term was originally defined as "the
*converse convention*" at line 189. Emphasizing it here (`*converse convention*`) would match style
more closely, but the content is correct as-is and this is cosmetic, not a defect.

**Out-of-scope adjacent block (flag only, no decision made):** Immediately following this FIX site
(lines 304-315), a `#remark[...]` block is *also* commented out but carries no FIX tag of its own:
it discusses how Extension + Separation jointly bear on whether a partial history should be
*defined* as a restriction of a possible world (this is exactly the framing the document's own
abstract, line 119-121, promises: "the separation result that bear[s] on whether a partial history
should be identified with a restriction of a possible world"). Since it has no FIX tag, it is
strictly outside this task's enumerated 6 sites, and I have not decided restore/rewrite/delete for
it. I flag it because restoring the Separation proof immediately above it, while leaving this
thematically-continuous remark commented with no tag, will read as an odd editorial gap — the
implementation phase (or a follow-up task) should consider whether it needs its own FIX tag added
rather than silently restoring or silently ignoring it without a decision trail.

**4. Line 345 — block following the Truth/`square.stroked`-clause definition.**
```
The semantic clause for $square.stroked$ quantifies over all possible worlds of the frame.
It is not a relational modality with an accessibility relation to be tuned: the frame fixes $H_(#taskframe)$, and $square.stroked$ ranges over that set entire.
Its logic is correspondingly S5, and @sec:objective-modality takes up what else, beyond being S5, is needed to single it out.
```
Directly and correctly summarizes clause 4 of the `Truth` definition (line 334-335: "`M,τ,x⊨□φ` iff
`M,σ,x⊨φ` for every `σ∈H_F`") — a universal (S5-style) modality over the frame's whole set of
possible worlds, not a binary accessibility relation. `@sec:objective-modality` is a real,
currently-defined label (line 928) whose content (title: "The Strongest Objective Modality") is
exactly the follow-up the sentence promises.
**Decision: RESTORE verbatim** as plain prose (delete the `// FIX:` line, uncomment).

**5. Line 370 — block following the Validity-and-Consequence definition.**
```
By Occurrence $H_(#taskframe)$ is never empty, so frame validity is never vacuous and
$#taskframe #notsatisfies bot$ for every frame. Fixing $H_(#taskframe)$ with the frame does not
make $#taskframe$ a *general frame* in the sense of Blackburn, de Rijke, and Venema
@blackburnderijkevenema2001: a general frame restricts the admissible valuations to a designated
subalgebra, whereas here every $|p_i| subset.eq #worldstate$ is admissible. What the frame
constrains is the points of evaluation, not the propositions.
```
"By Occurrence, `H_F` is never empty" directly matches the live `Occurrence` corollary (line
269-272: "there is some possible world... In particular `H_F ≠ ∅`"). The general-frame
contrast citation `@blackburnderijkevenema2001` is a real bibliography key already used live
elsewhere in the wider `typst/` tree (`typst/chapters/06-notes.typ` cites the same key for the
same Blackburn-de Rijke-Venema textbook, confirming both the key and the substantive point —
general frames restrict admissible valuations to a subalgebra — are used consistently across the
project).
**Decision: RESTORE verbatim** as plain prose (delete the `// FIX:` line, uncomment).

Note: inside the *live* `Validity and Consequence` definition itself (lines 362-363, immediately
above this FIX site), there is a separate, untagged commented-out fragment (an earlier phrasing of
frame validity, apparently superseded by the "Γ⊨φ, φ valid when ⊨φ" phrasing that is now live). It
carries no FIX tag and is likewise out of scope; flagged only for awareness since it sits one
definition-block above site 6.

## Decisions

- All 6 bare `// FIX:` sites: **restore verbatim**, deleting only the `// FIX:` tag line and the
  `//` comment markers, preserving existing blank-line paragraph breaks. No rewriting or deletion
  of any of the 6 is warranted — every block is mathematically sound (the two proofs were
  independently re-derived and check out) and consistent with the live document's definitions,
  labels, bibliography keys, and stylistic conventions.
- The one optional cosmetic improvement noted (bold-emphasizing "converse convention" in the
  Separation proof) is left to the implementation phase's discretion — not required for
  correctness or consistency.
- The two adjacent, untagged, still-commented blocks (the `#remark[...]` at lines 304-315 following
  the Separation proof, and the two-line fragment inside the live Validity-and-Consequence
  definition at lines 362-363) are explicitly **out of scope** for this task and should not be
  touched by its implementation phase; the remark-block one is flagged as worth a follow-up
  decision (possibly its own FIX tag) since it is thematically continuous with what this task
  does restore.

## Risks & Mitigations

- **Risk**: Restoring text verbatim reintroduces a stale forward-reference if a referenced label
  (`@sec:representation`, `@sec:objective-modality`, `@sec:histories`) or bibliography key
  (`@brastmckie2026possibleworlds`, `@blackburnderijkevenema2001`) were ever renamed/removed.
  **Mitigation**: I confirmed all five resolve against the current file/bibliography (see Findings)
  — the implementation phase's `typst compile` verification step will also catch any label/citation
  resolution failure immediately (Typst raises a hard error, not a silent gap, for an unresolved
  `@label` or `@citekey`).
- **Risk**: The commented Lean source-file identifiers referenced only informally in backticks
  (`` `lem:step` ``, `` `cor:spherical-finite` ``, `` `thm:extension` ``) are not `#leansrc(...)`
  calls and are not compile-checked against `FormalSystem/` — if these Lean-side names have since
  changed, the restored footnote would silently reference a stale identifier.
  **Mitigation**: This is a pre-existing characteristic of the surrounding live document too (e.g.
  line 723 already uses the identical backticked-identifier convention without compile-time
  checking), so it is not a new risk introduced by restoring these 6 blocks; out of scope to
  resolve here. The implementation phase could optionally grep `FormalSystem/` for these names as
  a sanity check but this is not required by the task.
- **Risk**: The un-tagged adjacent remark block (lines 304-315) being left commented after its
  neighbor is restored could read as inconsistent/incomplete work.
  **Mitigation**: Flagged explicitly above; implementation phase or a follow-up task should make an
  explicit decision on it rather than silently restoring or silently leaving it.

## Context Extension Recommendations

None — this is a self-contained content-restoration task within a single document; no gaps in
`.claude/context/` documentation were identified.

## Appendix

### Search queries / commands used

```
grep -n "FIX:" typst/FormalFoundations.typ
wc -l typst/FormalFoundations.typ
grep -n "Step Lemma\|lem:step\|Spherical\|sec:representation\|sec:construction\|sec:dichotomy\|sec:contingency\|sec:objective-modality\|sec:histories" typst/FormalFoundations.typ
grep -n "cor:spherical-finite\|thm:extension\b\|<lem" typst/FormalFoundations.typ
grep -n '\*Seriality\*\|\*Limit\*\|\*Spherical\*\|\*Compositionality\*' typst/FormalFoundations.typ
grep -rn "blackburnderijkevenema2001\|brastmckie2026possibleworlds\|scott1970advice" typst/ --include="*.bib" --include="*.yml" --include="*.typ"
grep -n "bibliography\|#cite\|@brastmckie2026\|@blackburnderijkevenema2001\|@scott1970advice" typst/FormalFoundations.typ
grep -n "#proof\[\|#remark\[" typst/FormalFoundations.typ
typst compile typst/FormalFoundations.typ /tmp/ff-baseline.pdf   # baseline: exit 0
```

### Full raw content of the 6 bare-tagged blocks (as currently in the file, comment markers included)

Site 1 (line 228, task `:214`):
```
// FIX:
// #proof[
//   *Seriality* at $x = 0$ gives $u$ with $w arrow.r.double.long_(0) u$. Since $|0| < x$ for every
//   $x > 0$, $u in (w)_x$ for every such $x$, so $u in inter.big_(x>0)(w)_x = {w}$ by *Limit*, whence
//   $u = w$.
// ]
//
// Nullity is derived, not postulated, and its derivation uses no choice. The distinction matters
// below: two of the three results in @sec:histories are theorems of ZFC.
```

Site 2a (line 275, task `:257`):
```
// FIX:
// The Step Lemma is the sole application site of *Spherical* in the paper, and Extension is the sole
// consumer of the Step Lemma; every appeal to *Spherical* in the semantics passes through this one
// point.#footnote[`lem:step`. @brastmckie2026possibleworlds *Spherical* is not needed when the directed family has a $subset.eq$-least member, and on a finite carrier it holds outright and choice-free (`cor:spherical-finite`).] Extension and Occurrence are theorems of ZFC, in contrast with Nullity. That
// localization is what makes *Spherical* the identified obstruction of @sec:representation.
```

Site 2b (line 281, task `:263`):
```
// FIX:
// The cones are a basis for a topology on world states, and that topology is separated.
```

Site 3 (line 295, task `:277`):
```
// FIX: 
// #proof[
//   ${u} subset.eq overline({u})$ is immediate. Conversely let $w in overline({u})$. By Nullity
//   every basic open $(w)_x$ contains $w$, so $u in (w)_x$ for every $x > 0$.
//   Hence for each such $x$ there is $y$ with $|y| < x$ and $w arrow.r.double.long_(y) u$, so $u arrow.r.double.long_(-y) w$
//   by the converse convention and $w in (u)_x$.
//   Thus $w in inter.big_(x>0)(u)_x = {u}$ by *Limit*, and so R0 follows.
// ]
```

Site 4 (line 345, task `:323`):
```
// FIX:
// The semantic clause for $square.stroked$ quantifies over all possible worlds of the frame.
// It is not a relational modality with an accessibility relation to be tuned: the frame fixes $H_(#taskframe)$, and $square.stroked$ ranges over that set entire.
// Its logic is correspondingly S5, and @sec:objective-modality takes up what else, beyond being S5, is needed to single it out.
```

Site 5 (line 370, task `:342`):
```
// FIX:
// By Occurrence $H_(#taskframe)$ is never empty, so frame validity is never vacuous and
// $#taskframe #notsatisfies bot$ for every frame. Fixing $H_(#taskframe)$ with the frame does not
// make $#taskframe$ a *general frame* in the sense of Blackburn, de Rijke, and Venema
// @blackburnderijkevenema2001: a general frame restricts the admissible valuations to a designated
// subalgebra, whereas here every $|p_i| subset.eq #worldstate$ is admissible. What the frame
// constrains is the points of evaluation, not the propositions.
```
