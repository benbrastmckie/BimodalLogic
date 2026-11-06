# Research Report: Task #880

**Task**: 880 - Reposition L^▷ in the READMEs and record the Logos reading of the stability modal
**Started**: 2026-11-06T01:58:00Z
**Completed**: 2026-11-06T02:35:00Z
**Effort**: ~1 dispatch, read-only (markdown task, no `.lean` edits)
**Dependencies**: 856 (complete — confirmed by `git log`, including its final "ledger surfaces and
the full gate" phase), 871 (complete)
**Sources/Inputs**:
- `specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md`
  (the "`OpenLanguage/README.md` now contradicts the tree" finding named by the dispatch)
- `FormalSystem/OpenLanguage/README.md`, `FormalSystem/PlusLanguage/README.md`,
  `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Conservativity/Open/README.md`,
  top-level `README.md` — read in full or by targeted grep
- `~/Projects/Logos/Theory/typst/manual/chapters/03-dynamics.typ` (2444 lines) — the necessity,
  stability, and open-future/open-past definitions and lemmas
- `git log --oneline --all` (task 856 and 871 completion state)
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md
**Task Type**: markdown
**Tree state**: current working tree, `main` branch, HEAD at `7d001a6d6` at report time

---

## Executive Summary

- **Items (1) and (2) of the dispatch are already satisfied by the tree.** Task 856's final
  phase ("the ledger surfaces and the full gate") already rewrote `OpenLanguage/README.md` to
  state exactly what the dispatch asks for — sound proof system, bidirectional conservativity
  over TM⁺, class-split definability, no completeness claim — and already corrected the
  inventory-count and six-vs-nine-file discrepancy the 872 ledger flagged. The 872 report's
  findings were pinned at commit `4c52993c1`, nine commits before 856's phase 15 and completion
  commits; none of the contradictions it enumerates survive in the current tree.
- `Metalogic/Conservativity/Open/README.md`, `Metalogic/README.md`, and the top-level `README.md`
  already avoid presenting L^▷ as an end state or L⁺ as a mere internal layer: `Metalogic/README.md`
  marks TM⁺ completeness and decidability **OPEN** (the pursuit target), and the top-level
  `README.md`'s L^▷ row already states "no completeness claim," the class-split, and gestures at
  the ZTime/RTime translation via "notational variant." What is missing is not a contradiction to
  fix but an **explicit cross-link**: none of the three files states in one place that the
  pursuit target is TM⁺ and that L^▷ inherits a landed TM⁺ result at `.ZTime`/`.RTime` through the
  conditional reductions of `Metalogic/Expressiveness/OpenFutureElimination.lean`. Recommend
  adding one short sentence to each of the three files making this link explicit, satisfying the
  dispatch's instruction as an **additive clarification** rather than a correction.
- **One stale surface remains, outside the dispatch's three "end state" files**:
  `PlusLanguage/README.md`'s generated inventory row for `Subformulas.lean` still reads
  `<!-- TODO: add description -->`. It sits inside the file's `BEGIN GENERATED` block, so it must
  not be hand-edited (per the dispatch's own constraint) — flagging it here for the plan to route
  through the inventory generator rather than a direct edit, or to leave out of scope if the
  generator needs a separate dispatch.
- **Item (3) is genuinely new content, confirmed against the Logos manual.** `03-dynamics.typ`
  defines $\Box\varphi := \top \,\Box\!\to\, \varphi$ and $\mathrm{stably}\,\varphi := \neg\bot
  \,\Box\!\to\, \varphi$ (`def-derived-operators-dyn`, line 69), and separately proves
  (`lem-stability-semantics`, confirmed by its proof at lines 1746–1753) that the only verifier of
  $\neg\bot$ is the null state, so the stability counterfactual's quantifier collapses to exactly
  the world-histories agreeing with the evaluation history at the evaluation time — i.e., `⊡` in
  this repository's vocabulary. The manual's own gloss (line 1756) extends this to "any true
  sentence whose unique verifier is the null state," naming a true propositional identity as
  another instance — confirming the dispatch's "or any true identity" clause. Open future/open
  past (`def-open-future-past`, lines 1773–1788) are built "by the identical construction" (line
  1762) — point-agreement generalized to ray-agreement — but are **not** routed through the
  counterfactual operator at all: they get their own primitive truth/falsity clauses because no
  Constitutive-Foundation antecedent (the class `prop-cf-conservativity`'s state-level shortcut
  needs) can express agreement over a whole ray of times rather than a single state at the
  evaluation time. A full reading, with the exact mechanism, is in Findings below and is written
  to be dropped into `PlusLanguage/README.md` largely as-is.

---

## Context & Scope

Task 880 is a markdown-only repositioning task across five README surfaces, gated on tasks 856
and 871 because 856's final phase edits the same `OpenLanguage/README.md` surface this task also
targets. This research phase's job is to (a) re-verify the 872 ledger's enumerated contradictions
against the *current* tree (872 was pinned at an older commit and explicitly warned that 856's
phase 15 was "observed actively in progress, uncommitted, already rewriting this exact README
passage" at the time of that audit), (b) check whether `Metalogic/Conservativity/Open/README.md`,
`Metalogic/README.md`, and the top-level `README.md` still present L^▷ as an end state or L⁺ as
an internal layer, and (c) ground the Logos-reading addition to `PlusLanguage/README.md` in the
actual manual text rather than from memory, since the dispatch names a specific chapter and a
specific pair of semantic facts to verify.

No `.lean` files are touched by this task (confirmed: nothing in the recommended edits below
names a Lean declaration that does not already exist, and no new Lean theorem is proposed — the
dispatch is explicit that the Logos reading is prose, "not a formalized theorem").

## Findings

### (1) `OpenLanguage/README.md` — the 872 ledger's contradictions, re-verified

The 872 report (`specs/872_.../reports/01_open-language-transfer-ledger.md`, "`OpenLanguage/
README.md` now contradicts the tree", lines 492–521) enumerated three problems, pinned at
`4c52993c1`:

| 872's finding (at `4c52993c1`) | Current tree state (verified by reading the live file) |
|---|---|
| README states "L^▷ is **semantic only**: it has no proof system" | **Fixed.** Current README (line 17): "L^▷ has a proof system, and its scope is exactly this: `OpenAxiom` … the seven-rule `OpenDerivationTree`, and the erasure `eraseOpen`." |
| generated inventory lists 6 files; directory holds 9 | **Fixed.** The current `<!-- BEGIN GENERATED --> … <!-- END GENERATED -->` table lists all 9 files (`Formula.lean`, `OpenAxioms.lean`, `OpenClasses.lean`, `OpenDerivation.lean`, `OpenErasure.lean`, `OpenOckhamist.lean`, `OpenReversal.lean`, `OpenTruth.lean`, `OpenValidity.lean`), each with a substantive description. |
| the two surfaces (README vs. `Metalogic/Conservativity/Open.lean` docstring) disagreed with each other | **Resolved** — the README now matches: "**No completeness claim is made for L^▷, at any frame class, in any form**," soundness at every class, conservativity over TM⁺ both directions, over TM at all four classes, collapse under `Determined`, and the explicit class-split (ZTime/RTime definable, Base/Dense not). |

`git log --oneline` shows this happened in task 856's phase 15 commits
(`9a1165793 task 856 phase 15: the ledger surfaces, the axiom pins and the gate for the L^open
proof system`; `5d741bc8c task 856 phase 15: the C5 allowlist entries and four out-of-file_scope
semantic-only corrections`), both landed after `4c52993c1` and before the two "complete
implementation" commits that close task 856. **No further edit to `OpenLanguage/README.md` is
needed for item (1).** The one lower-stakes stale item 872 also flagged — `PlusLanguage/
README.md`'s `Subformulas.lean` inventory row reading `<!-- TODO: add description -->` — is
confirmed still present in the current tree (see the standalone finding below); it is a different
file than the one item (1) names, and is inside a generated block, so the dispatch's "do not
hand-edit inside `BEGIN GENERATED`" constraint applies to it directly.

### (2) The "end state" / "internal layer" framing, checked across the three named files

None of the three files currently presents L^▷ as an end state or L⁺ as a mere internal layer.
Specifically:

- **`Metalogic/Conservativity/Open/README.md`** opens by naming L^▷ as "the third language layer
  of the same shape as `Conservativity/Plus/` and `Conservativity/Star/`" and states directly:
  "**No completeness is claimed here, at any frame class, in any form.** The component delivers a
  sound system that is conservative over TM⁺ in both directions and over TM at all four classes,
  and nothing more." This already refuses end-state framing. It does *not*, however, state the
  forward-looking inheritance relationship the dispatch's positive instruction describes — there
  is no mention of `.ZTime`/`.RTime` translation or of TM⁺ as the pursuit target anywhere in this
  file.
- **`Metalogic/README.md`** does not mention `OpenLanguage` or L^▷ at all (confirmed by a
  whole-file grep). Its "TM⁺ metatheory rows" table (lines ~273–297) already marks "completeness
  of any extension of the TM⁺ axiom set, at any class" and "TM⁺ decidability" as **OPEN** — i.e.,
  L⁺ (TM⁺) is already presented as the thing being pursued, not as a layer subordinate to
  something else. There is nothing to *correct* here, but there is also no explicit statement
  tying L^▷'s fate to these two OPEN rows.
- **Top-level `README.md`**'s "seven object languages" table and the prose bullet below it
  (lines 268–283) already state: L^▷ is "formalization-native," "**No completeness is claimed for
  it, at any frame class**," and its "novelty is class-split: ▷ is L⁺-definable over integer and
  real time and not definable over the base and dense classes, so the system extends TM⁺
  genuinely at the first two classes and is a notational variant of it at the last two." This
  gestures at the ZTime/RTime relationship ("notational variant") but does not use the dispatch's
  own framing — that completeness/decidability are *pursued for L⁺* and that L^▷ *inherits* a
  landed result there *by translation*. The mechanism this sentence would cite,
  `Metalogic/Expressiveness/OpenFutureElimination.lean`'s conditional reductions, is linked from
  `OpenLanguage/README.md` (already) but not from here.

**Conclusion for item (2)**: there is no contradiction left to fix in any of the three files —
872's finding and the "end state" framing the dispatch warns against are both already absent from
the current tree, most likely because task 856's own final phase and prior work (task 833,
`stab_definable_from_open_modals`, listed as a `covered-by-closed` duplicate-audit hit against
this very task, and task 562's language-naming sweep) already pushed the correct framing through.
What remains is purely additive: one short, explicit sentence in each of the three files stating
that TM⁺ is the pursuit target and that L^▷ inherits a landed `.ZTime`/`.RTime` result by
translation through `OpenFutureElimination.lean`'s reductions. This fulfills the dispatch's
instruction in substance (the reader now sees the relationship stated, not merely inferable from
three separately-read files) without requiring any correction of an existing false claim.
Suggested insertion points and draft language (for the plan phase — not applied here):

- `Metalogic/README.md`: one sentence immediately after the TM⁺ metatheory table's two OPEN rows,
  e.g. "Because L^▷ is conservative over TM⁺ and a notational variant of it at `.ZTime` and
  `.RTime` (`FormalSystem/OpenLanguage/README.md`), a landed TM⁺ result at either class transfers
  to L^▷ validity there through the conditional reductions of `Metalogic/Expressiveness/
  OpenFutureElimination.lean` — the pursuit target above is TM⁺, not a separate L^▷ engine."
- `Metalogic/Conservativity/Open/README.md`: one sentence after the existing "No completeness is
  claimed here…" paragraph, naming the same reduction file and stating that `.Base`/`.Dense` have
  no such route because `▷` is not L⁺-definable there.
- Top-level `README.md`: tighten the existing L^▷ bullet's final clause to name the pursuit
  target and the reduction file explicitly, rather than leaving "notational variant" to carry the
  inheritance claim implicitly.

### (3) The Logos reading, grounded in `03-dynamics.typ`

All of the following is confirmed by reading the cited lines of
`~/Projects/Logos/Theory/typst/manual/chapters/03-dynamics.typ` directly (2444 lines; no other
chapter was needed).

**Necessity and stability as degenerate counterfactuals** (`def-derived-operators-dyn`, line 69,
and its surrounding grammar note):

$$\Box\varphi := \top \,\Box\!\to\, \varphi \qquad \mathrm{stably}\,\varphi := \neg\bot
\,\Box\!\to\, \varphi$$

(`$\Diamond\!\to$` and `$\Diamond$` are the dual/might-counterfactual abbreviations, not needed
here.) The manual is explicit that these "already unfold to combinations of $\Box\!\to$, $\neg$,
$\top$, and $\bot$" and that "$\top$ and $\neg\bot$ are Constitutive Foundation formulas" — i.e.
non-dynamical, non-tensed formulas, which is what licenses the shortcut below.

- **Necessity's clause collapses because every state verifies $\top$** (line 94: "Every state
  verifies $\top$ … so imposing its verifiers on the current world state reaches every world
  state, and $\Box$ quantifies over every world-history," `lem-necessity-semantics`). This is
  exactly the dispatch's "necessity is the counterfactual with antecedent top, which every state
  verifies."
- **Stability's clause collapses because the null state is the *only* verifier of $\neg\bot$**
  (`lem-stability-semantics`, proved at lines 1746–1753): "$\neg\bot$ is a Constitutive Foundation
  formula, so `prop-cf-conservativity` gives the counterfactual its state-level clause … A state
  verifies $\neg\bot$ just in case it falsifies $\bot$, and the unique falsifier of $\bot$ is the
  null state, so $s = \text{nullstate}$ … imposing the null state on a world state returns that
  world state exactly" (restated plainly at line 95), so the quantifier "ranges over exactly the
  world-histories $\beta$ with $\beta(x) = \tau(x)$" — precisely this repository's `stabClass`
  / `⟨τ⟩_x`. The manual then immediately generalizes (line 1756): "The antecedent matters only
  through its verifiers: any true sentence whose unique verifier is the null state would serve,
  and a true propositional identity is another" — this is the exact source of the dispatch's "or
  any true identity" clause; `prop-cf-conservativity`'s own sanity check (cited at line 1418) runs
  this computation for a true $\varphi \equiv \psi$ and confirms $(\varphi \equiv \psi)\,\Box\!\to\,
  \chi$ reads as $\mathrm{stably}\,\chi$.

**So L⁺ (`⊡`) is, under this reading, the fragment of the counterfactual whose antecedent is one
of these two "trivial" Constitutive-Foundation antecedents** — $\top$ (reaching all
world-histories) or $\neg\bot$/a true identity (reaching exactly the world-histories agreeing at
the evaluation state) — rather than a modality built from new primitive structure. This is the
dispatch's framing exactly, and it is a reading *of* the manual's own derivation, not an
independent claim: the manual proves both collapses as lemmas from the general counterfactual
semantics plus `prop-cf-conservativity`'s state-level shortcut for Constitutive Foundation
antecedents.

**Open future and open past need the event-level clause, rather than inheriting the same
shortcut** (`def-agreement-classes` and `def-open-future-past`, lines 1760–1788):

$$|\tau\rangle_x := \{\alpha : \alpha(y) = \tau(y) \text{ for all } y \le x\} \qquad
\langle\tau|_x := \{\alpha : \alpha(y) = \tau(y) \text{ for all } y \ge x\}$$

with $\triangleright\varphi$ (open future) and $\triangleleft\varphi$ (open past) quantifying
over these two classes exactly as `stably` quantifies over $\langle\tau\rangle_x$ (line 1762:
"support two further operators by the identical construction"). The crucial asymmetry: `stably`
is an **abbreviation** of a counterfactual, discharged entirely by `def-counterfactual-truth`
plus `prop-cf-conservativity`'s shortcut (line 1467: "is an abbreviation, exactly as `□φ` is …
no separate clause is stated or needed"); open future and open past are **not** routed through
the counterfactual at all — `def-open-future-past` gives them their own primitive truth and
falsity clauses directly in terms of world-histories, with an explicit note (line 1780) that
"Neither falsity clause is the negation of its truth clause … so both are authored here." The
reason the shortcut is unavailable is structural, not an oversight: `prop-cf-conservativity`'s
state-level clause only fires for a Constitutive-Foundation antecedent, and a Constitutive
Foundation formula's event-verifiers are singleton families pinned to the single evaluation time
(line 1524: "$\mathrm{dom}(\pi) = \{x\}$"). Open future/open past's agreement condition ranges
over a whole ray of times ($y \le x$ or $y \ge x$), which no state-level, single-time verifier can
express — there is no "trivial tensed antecedent" whose Constitutive-Foundation-style verifier
set would reach a ray rather than a point. That is the sense in which "the open-future and
open-past modals correspond to trivial tensed antecedents and need the event-level clause": the
construction generalizing `stably`'s point-agreement to ray-agreement is the same idea, but
cashing it out requires the manual's own full event-verification machinery
(`def-counterfactual-truth`'s event layer, or here a bespoke primitive clause), not the
state-level shortcut that happens to make `stably` free.

**Suggested content for `PlusLanguage/README.md`'s new section** (a short prose section, not a
theorem; names from the current manual, not restated as a Lean claim):

> ## Logos Reading
>
> In the Logos theory's dynamical layer (`03-dynamics.typ`), necessity and the stability modal
> are both abbreviations of the one primitive counterfactual operator at a Constitutive-Foundation
> (non-dynamical, non-tensed) antecedent: `□φ := ⊤ □→ φ`, and `stably φ := ¬⊥ □→ φ`
> (`def-derived-operators-dyn`). Necessity's clause collapses to a quantifier over every
> world-history because every state verifies `⊤`; stability's collapses to a quantifier over
> exactly the world-histories agreeing with the evaluation history at the evaluation state —
> this repository's `⊡` — because the null state is the *unique* verifier of `¬⊥`
> (`lem-stability-semantics`), and the manual observes that any true sentence with that same
> unique-null-state verifier works as well, naming a true propositional identity as another
> instance. Read this way, `⊡` is the fragment of the counterfactual whose antecedent is one of
> these two trivial Constitutive-Foundation antecedents, rather than a modality built from new
> frame structure.
>
> The open-future and open-past modals of `FormalSystem/OpenLanguage/` are the tensed analogue of
> the same idea — ray-agreement in place of point-agreement — but the manual does not reach them
> through the counterfactual's shortcut: no Constitutive-Foundation antecedent pins down agreement
> over a whole ray of times rather than a single evaluation-time state, so
> `def-open-future-past` gives `▷`/`◁` their own primitive truth and falsity clauses directly,
> rather than unfolding them from `□→`. This is a reading of the manual's clauses offered for
> cross-reference; no claim here is a formalized theorem of either system.

## Decisions

- **No edit to `OpenLanguage/README.md` is recommended.** Re-verification against the current
  tree shows every contradiction the 872 ledger enumerated was already corrected by task 856's
  final phase; re-applying the same fix would be a no-op at best and risks reintroducing drift if
  applied against stale assumptions from the 872 pin.
- **The `Subformulas.lean` row in `PlusLanguage/README.md`'s generated inventory is out of scope
  for a hand-edit.** It sits inside `<!-- BEGIN GENERATED -->`/`<!-- END GENERATED -->`, which the
  dispatch explicitly forbids hand-editing. Recommend the plan either route this through whatever
  script populates that table's description column, or explicitly defer it as a separately-owned
  cleanup (it is not part of the "end state" framing this task is about).
- **Items (1) and (2) as literal corrections are complete; treat them as additive clarification
  instead.** The plan should add one short cross-reference sentence to each of
  `Metalogic/README.md`, `Metalogic/Conservativity/Open/README.md`, and the top-level `README.md`
  (draft language above) rather than attempting to "fix" text that does not currently contradict
  anything. This still satisfies the dispatch's substantive intent — making the pursuit-target/
  inheritance relationship explicit and visible from each of the three files — without inventing
  a problem to solve.
- **Item (3) is the one substantive new-content change**, confirmed word-for-word against
  `03-dynamics.typ`'s `def-derived-operators-dyn`, `lem-stability-semantics` (with its proof), and
  `def-agreement-classes`/`def-open-future-past`. The drafted "Logos Reading" section above is
  ready to be inserted into `PlusLanguage/README.md` by the implementation phase with minimal
  further editing; it cites manual anchors by their Typst label, matching this repository's own
  convention in `OpenLanguage/README.md`'s paper-label correspondence table, and makes no Lean
  claim.
- **No Lean files, and no edit inside a `BEGIN GENERATED` block, are proposed anywhere above** —
  consistent with the task's `markdown` type and its explicit constraint.

## Risks & Mitigations

- **Risk**: a plan or implementation agent re-reads the 872 ledger without re-checking the tree
  and re-applies its now-stale fix to `OpenLanguage/README.md`, producing a spurious diff or
  reverting correct text. **Mitigation**: this report's table above is the re-verification; the
  plan should cite this report rather than the 872 ledger directly for `OpenLanguage/README.md`'s
  current state.
- **Risk**: the three "end state" files are edited more heavily than needed, on the assumption
  that the dispatch's instruction implies an existing violation. **Mitigation**: this report
  records that no violation was found and scopes the recommended edit to one sentence per file.
- **Risk**: the Logos reading drifts from the manual if `03-dynamics.typ` is revised before the
  implementation phase runs (it is a live, actively-edited file in a sibling repository — its
  mtime at research time was the same day as this dispatch). **Mitigation**: the quoted anchors
  (`def-derived-operators-dyn`, `lem-stability-semantics`, `def-agreement-classes`,
  `def-open-future-past`) are stable Typst labels; the implementation phase should re-grep them
  rather than trusting this report's line numbers if the chapter has since changed.

## Context Extension Recommendations

- **Topic**: cross-repository reading sections (a BimodalLogic README citing a specific Logos
  manual chapter by Typst label, as a prose "reading" rather than a formalized correspondence).
- **Gap**: no existing context file documents the convention for this kind of cross-reference
  (as distinct from the in-tree "paper-label correspondence" tables that cite the JPL manuscript's
  `\label`s, which `.claude/context/` likely does document via the language-component READMEs
  themselves).
- **Recommendation**: if this pattern recurs (a second task citing Logos chapters as readings
  rather than formalization targets), consider a short context note under
  `context/project/logic/` or `context/project/lean4/` recording the convention: cite by Typst
  label, state as a reading not a theorem, and re-verify the label still names the same content
  before quoting it, given the Logos manual's own active-development state observed here.

## Appendix

- Files read in full: `FormalSystem/OpenLanguage/README.md`, `FormalSystem/PlusLanguage/
  README.md`, `~/Projects/Logos/Theory/typst/manual/chapters/03-dynamics.typ` (targeted reads of
  lines 60–100, 1740–1830).
- Files searched by grep (no full read needed, given negative/targeted results):
  `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Conservativity/Open/README.md`,
  top-level `README.md` — for `L^▷`, `L⁺`, `OpenLanguage`, `PlusLanguage`, `open-future`,
  `L-plus`, `end state`, `internal layer`, `Logos`, `future work`, `roadmap`, `pursu`.
- Git log checked for task 856 and 871 completion: `git log --oneline --all | grep "task 856"` /
  `"task 871"`.
- `jq` query against `specs/state.json` confirmed task 880's `file_scope` and dependency list
  (`[856, 871]`), used to scope which files this report covers.
