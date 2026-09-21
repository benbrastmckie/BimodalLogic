# Research Report: Fix Reference-Book Defects Found in Appendix Review

**Task**: Fix the defects found in `typst/BimodalReference.typ` and its surroundings during the
accuracy-and-formatting review of `typst/chapters/ax-lean-appendix.typ`, all lying outside that
appendix file.
**Started**: 2026-09-21
**Completed**: 2026-09-21
**Effort**: Medium-high (9 items across typst/, two Lean docstring files, one whitelist and one
sync-map file; one additional blocking finding discovered during verification)
**Dependencies**: Depends on the appendix-extension task, which has landed (status `completed`,
final commit `a171dc67e`)
**Sources/Inputs**: Live repository source (`typst/`, `FormalSystem/`, `BimodalTools/`,
`lakefile.toml`, `Boneyard/RetiredTactics/README.md`), a full `typst compile` + `pdftotext`
render, `lake env lean` elaboration of four scratch probes, `scripts/typst-sync-check.sh`
**Artifacts**: — this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All nine dispatch items were re-verified against live source. Eight reproduce essentially as
  described (one, the `@machine-appendix` half of item 1, does **not** currently reproduce and
  should be closed as not-reproducing for that specific sub-claim). One item (3) needed
  additional forensic work to establish the true figures, since the dispatch's own named
  omitted-axiom set was itself partly wrong.
- **New, unflagged blocker discovered**: `scripts/typst-sync-check.sh` currently **FAILS** (5
  Check-1 violations, all inside `typst/chapters/ax-lean-appendix.typ`). The violating text is a
  currently **uncommitted** working-tree diff to that file (two `// TODO:` comments, not part of
  any committed task on this appendix) that this task is forbidden from editing. The correct,
  in-scope remedy is whitelist additions to `typst/sync-check-whitelist.txt` (a file this task
  **is** permitted to edit) — this must be done or the ACCEPTANCE criterion "`scripts/typst-sync-check.sh`
  PASS" cannot be met. Flagged prominently below; re-verify at implementation time since the
  working tree is not stable (see "Live Working-Tree Caveat").
- Recommended fix for item 1: give both appendices real letter numbering ("Appendix A: …",
  "Appendix B: …") and make the `#show ref` rule in `BimodalReference.typ` use the heading's own
  `el.supplement`/`el.numbering` dynamically instead of hardcoding `"Chapter"` — this both fixes
  the bug and is future-proof against any other unnumbered level-1 heading.
- Item 5's chapter/docstring claim ("Axiom is Prop-valued, DerivationTree is Type-valued") is
  simply false — both are `Type`-valued, confirmed from `Axioms.lean:152` and
  `Derivation.lean:91`. The authoritative, already-correct explanation of why Aesop fails and
  `TacticM` is used lives in `Boneyard/RetiredTactics/README.md:88-95` and should be the source
  the corrected text is grounded in.
- Item 6 needed elaboration-verified correction: `apply_axiom` genuinely leaves **both** side
  goals (`h : Axiom _`, `h_fc`) open (confirmed by two `lake env lean` probes below); `modal_t`'s
  Lean docstring is fiction (its macro body is byte-identical to `apply_axiom`'s, contrary to its
  own claimed "detects…applies modal T axiom and modus ponens…Applies Axiom.modal_t directly").
  The **chapter's own `modal_t` item is already correct**; only its `apply_axiom` item needs the
  same "unifies/infers" language removed.

## Context & Scope

Nine numbered items from the dispatch, all outside `typst/chapters/ax-lean-appendix.typ`'s
content (that file may only have its title changed, per item 1, since a prior task owns its
content). Every item was re-verified against live source rather than trusted from the dispatch
text, per the dispatch's own instruction ("Re-verify each item against live source before
acting: a finding that no longer reproduces is closed with a one-line note, never 'fixed'
anyway").

### Live Working-Tree Caveat

At research time, `git status --porcelain` shows `typst/chapters/ax-lean-appendix.typ` as
**modified but uncommitted** relative to `HEAD` (`a171dc67e`, the prior task's final commit). The
diff adds two `// TODO:` comments (after the `Atom` `#leansrc` block, and after the "Three Kinds
of Binder" table) containing generic Lean-syntax illustrations in backticks. These are the exact
source of the 5 Check-1 violations reported below. This diff is **not** attributable to any
currently-locked task (`specs/state.json` shows the appendix-extension task as `completed`, and
the only active lock at research time is a different, unrelated task's `implement` lock). Its
origin is unclear — possibly an interrupted or stray session. **The implementer must re-run
`git status`/`git diff` on this file and `scripts/typst-sync-check.sh` at the start of
implementation**, since this working-tree state may have changed (committed, reverted, or grown)
by the time implementation begins. The whitelist-based remedy recommended below (Check 2 of
"Item 1…") resolves the violations **as currently observed**; if the uncommitted diff is gone by
implementation time, re-run Check 1 first and skip the whitelist addition if it no longer fails.

---

## Findings, Item by Item

### Item 1 — Broken cross-references to the appendices (HIGH, rendering bug)

**Reproduces (partially).** Compiled `pdftotext -layout` output of a fresh `typst compile --root
.. BimodalReference.typ` confirms:

```
386: assistant (Chapter 1534), and a machine-readable appendix cross-refer­
417: start with Chapter 1534, which builds up from what Lean is to reading
```

Both are `@lean-appendix` references in `typst/chapters/00-introduction.typ` (lines 139, 151, per
the source `grep`). **The `@machine-appendix` half of the claim does not reproduce**: no
`@machine-appendix` (`@`-ref syntax) exists anywhere in `typst/` today. Both real references to
`<machine-appendix>` (`typst/chapters/p4-dataset-pipeline.typ:108` and
`typst/chapters/ax-lean-appendix.typ:1262`) use `#link(<machine-appendix>)[explicit text]`, which
bypasses the `#show ref` rule entirely (that rule only intercepts the `ref` element, not
`link`). Close this sub-claim as "not reproducing — already uses explicit-text `#link`, not a
bare `@`-ref" while still fixing the underlying rule (below), since a future bare `@machine-appendix`
would hit the same bug.

**Root cause** (`typst/BimodalReference.typ:57-64`):
```typst
#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading and el.level == 1 {
    link(it.target)[Chapter~#numbering("1", ..counter(heading).at(el.location()))]
  } else { it }
}
```
Both appendix titles are unnumbered level-1 headings (`#heading(numbering: none)[Appendix: …]` —
`ax-lean-appendix.typ:20`, `ax-machine-appendix.typ:17`). An unnumbered heading does not reset or
step the shared `counter(heading)`, so by the time the appendices are reached the counter has
accumulated every heading in the document (1534 at the Lean appendix), which the hardcoded
`numbering("1", ...)` call dutifully renders in full.

**Recommended fix** (design direction; final code is the implementer's call):
1. Give both appendix titles real, letter-based numbering instead of `none`:
   `Appendix A: Reading the Lean Formalization` and `Appendix B: The Machine-Readable
   Axiomatization` — matching the dispatch's own suggested end state and the section-numbering
   scheme `ax-lean-appendix.typ` already uses (`A.1`–`A.14`, file-local counter reset +
   `#set heading(numbering: (..n) => "A." + numbering("1.1", ..n.pos().slice(1)))` at lines
   29-30; NOTE the dispatch text says "A.1 to A.9" — stale, the prior task extended this to
   A.1–A.14, but the fix is agnostic to the exact count).
2. Give each appendix file a local `#show heading.where(level: 1): set heading(supplement:
   "Appendix")` override (mirroring the existing global `supplement: "Chapter"` rule), so
   `el.supplement` is correct per-heading.
3. Rewrite the `#show ref` rule to use the heading's own `el.supplement` and `el.numbering`
   dynamically instead of hardcoding `"Chapter"` and `numbering("1", ...)`:
   ```typst
   #show ref: it => {
     let el = it.element
     if el != none and el.func() == heading and el.level == 1 {
       if el.numbering == none { it } else {
         link(it.target)[#el.supplement~#numbering(el.numbering, ..counter(heading).at(el.location()))]
       }
     } else { it }
   }
   ```
   This both fixes the two appendices (once they carry real numbering + the right supplement)
   and satisfies the dispatch's explicit ask to "handle `el.numbering == none`" defensively for
   any future unnumbered level-1 heading.
4. "Reconsider" the machine appendix's three unnumbered level-2 headings (`ax-machine-appendix.typ:59,85,110`)
   for consistency: recommend numbering them `B.1`/`B.2`/`B.3` using the same file-local
   counter-reset pattern `ax-lean-appendix.typ` already established (that file is off-limits, but
   `ax-machine-appendix.typ` is not). No internal cross-references target these three headings
   today, so this is cosmetic consistency, not a correctness fix — the implementer may reasonably
   defer it, but should record the decision either way.
5. Update the two explicit-text `#link(<machine-appendix>)[...]` call sites if the title changes
   to include "Appendix B": `p4-dataset-pipeline.typ:108` (freely editable) and
   `ax-lean-appendix.typ:1262` (arguably within "item (1)'s title change" scope since it is
   keeping the *other* appendix's title reference in sync with the same renaming decision, but
   flag this judgment call to the user/plan phase rather than assuming it).

**Acceptance grep** (`Chapter 1` followed by 3+ digits) currently matches twice; must be zero
after the fix, and the TOC (currently plain "Appendix: …", confirmed still readable/correct as
unnumbered entries at `pdftotext` lines 185, 215) should pick up the new "Appendix A"/"Appendix
B" prefixes automatically once the headings carry real titles.

### Item 2 — Stale records about the Lean appendix (MEDIUM)

**Partially already fixed; one genuine defect remains, plus a rule-violation.**

- `typst/SYNC-MAP.md`'s 2026-09-17 entry (`byte-exact`, scratch-file path) already carries a
  corrective parenthetical inserted by the prior task at lines 532-534: "two claims in this
  paragraph are superseded by the 2026-09-21 entry below: the `#leansrc` policy is verbatim up to
  whitespace... and the scratch file named here has since been archived and no longer exists at
  that path". The 2026-09-21 entry itself (lines 586-658) restates the policy correctly at line
  622-626 ("verbatim up to whitespace... not byte-exact... 2026-09-17 entry above saying
  otherwise is superseded") and never re-asserts byte-exactness. **No further SYNC-MAP.md text
  fix is strictly required for the byte-exact claim**, though the 2026-09-21 entry's "New
  coverage" bullets (lines 594-620) do not mention the `A.n` section-numbering mechanism itself
  (the `#counter(heading).update`/`#set heading(numbering: ...)` pair, confirmed via
  `git log -S"counter(heading).update"` to have been introduced in that same task, commit
  `78ef65d6f`) — this is undocumented and worth a short addition to that entry for completeness,
  per the dispatch's explicit ask to describe "A.n section numbering... in the SYNC-MAP.

- `typst/sync-check-whitelist.txt:160-164` **still cites the ephemeral task-directory path**:
  ```
  # --- Lean appendix: appendix-local didactic identifiers, defined only in
  # ax-lean-appendix.typ's own example code blocks (verified against the
  # current toolchain in
  # specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean),
  # never claimed as FormalSystem/ library declarations ---
  ```
  This is a genuine, live violation of `.claude/rules/no-task-references-in-deliverables.md` in
  a shipped deliverable file (`typst/` is not under `specs/**`). Fix: drop the `specs/620_.../…`
  path citation; the 2026-09-21 SYNC-MAP entry already models the right phrasing ("that file is a
  session scratch artifact and is deliberately not named by path here, since the previous
  entry's named path has since been archived out of existence" — line 632-634). Reuse that
  wording rather than inventing new phrasing.

- **Whitelist-pruning check** (dispatch: "may be pruned only after confirming no other chapter
  uses them"). I checked every entry under the "Lean appendix" category comments
  (`typst/sync-check-whitelist.txt:141-190`) against current `ax-lean-appendix.typ` content and
  the rest of `typst/chapters/`:
  - `boxPImpP`, `dBoxP : ⊢ □p`, `h : Axiom _` — still used (`ax-lean-appendix.typ:168,176,180,186,630,615`). Keep.
  - `/-! # Title ... -/`, `/-- ... -/`, `1 + 1 = 2`, `DerivationTree .Base [] φ`,
    `DerivationTree .Dense [] φ`, `FrameClass → Context → Formula → Type`, `Std.HashMap Formula _`,
    `Valid φ ↔ Derivable FrameClass.Base [] φ`, `lake build FormalSystem`, `lake env lean FILE.lean`,
    `[[require]]`, `srcDir = "Tests"`, `lean-toolchain`, `elan`, `file:line`,
    `lean_declaration_file` — each still occurs exactly once in `ax-lean-appendix.typ`. Keep.
  - **`leanprover/lean4` is unused** — 0 occurrences anywhere in `typst/chapters/`. The appendix
    now cites the toolchain pin via the generated value `#text(size: 8pt, raw(lean-toolchain-pin))`
    (`ax-lean-appendix.typ:879`) rather than a literal backtick span, so Check 1 (which scans
    literal backtick source spans) would never have matched this entry in the current file even
    before this task. Confirmed unused repo-wide via `grep -rn "leanprover/lean4" typst/chapters/`
    (no hits). Safe to prune per the dispatch's own stated confirmation bar.
  - The two new 2026-09-21 entries (`searchDepth := 10`, `tableauFuel := 1000`, lines 653-657 of
    SYNC-MAP.md's description) still occur in the appendix's decision-procedure section; not
    checked exhaustively here since they are outside the "Lean appendix (2026-09-17)" category
    block this item's cleanup targets, but nothing suggests they are stale.

- **Describing the revised appendix** (dispatch's list: A.n numbering, turnstile-notation table,
  naming-convention table, directory tour incl. `*Language/` dirs, `Tactic/`, `MainResults.lean`,
  `#print axioms`): all of this content already exists in the live appendix (turnstile table at
  `ax-lean-appendix.typ:124`; naming/documentation-conventions section at line 813; directory
  tour at lines 976-991 including `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/`,
  `OpenLanguage/`, `ForMathlib/`, `Tactic/`, `MainResults.lean`; `#print axioms` discussed at
  lines 743, 1226). The only gap is that SYNC-MAP.md's record of it is incomplete (doesn't
  mention the `A.n` numbering mechanism, per above). Recommend folding a short paragraph into the
  existing 2026-09-21 entry rather than writing a new dated entry — the content described is not
  new work, just an undocumented mechanism from already-landed work.

### Item 3 — Axiom-schema count disagreement (MEDIUM, Lean docstrings)

**Reproduces, and the dispatch's own named omitted-axiom set for the chapter was itself
partly wrong — this needed independent verification, not a copy of the dispatch text.**

Ground truth, machine-counted:
- `Axiom` inductive (`FormalSystem/ProofSystem/Axioms.lean:152-460`) has **29** constructors
  (counted by extracting every `| name` line in the `inductive...deriving Repr` block — list
  confirmed constructor-by-constructor). Matches `typst/generated/status.typ:14`
  (`#let axiom-count = 29`).
- `tryAxiomMatch`'s `axiomCtors` list (`FormalSystem/Automation/Tactics/Search.lean:96-138`) has
  **27** entries (counted directly from the `List Name` literal), omitting exactly
  `Axiom.prior_U_gap` and `Axiom.sep` — the two Layer-9 "Reynolds Dedekind" constructors
  (`Axioms.lean:377-459`, comment: "Layer 9: Reynolds Dedekind Axioms (2: PU, SEP...)").
- `FormalSystem/Automation/Tactics/Commands.lean:100-101`'s `modal_search` docstring **already
  says this correctly**: "27 of the 29 axiom schemata (`tryAxiomMatch`'s list omits the two
  Layer-9 Reynolds Dedekind axioms)". **No fix needed here** — this docstring is the accurate one
  and should be the template the other two are corrected to match.
- `FormalSystem/Automation/Tactics/Search.lean:563-564`'s own docstring says "42 of the tree's
  45" — wrong on both numbers; no live mechanism in the codebase currently produces "45" as any
  meaningful total (not the axiom count, not `tryAxiomMatch`'s list size, not a `@[tmLemma]`
  count — there are 66 `@[tmLemma]`-adjacent occurrences across the tree by a raw grep, which
  doesn't cleanly resolve to 45 either without a defined counting rule). Treat as simply stale;
  replace with the same "27 of the 29" language Commands.lean already uses.
- `typst/chapters/p4-proof-automation.typ:69` says "`tryAxiomMatch` (42 of the 45 axiom
  schemata; the three Layer-9 Reynolds Dedekind axioms `prior_U_gap`, `prior_S_gap` and `sep` are
  outside its list)". **This names a THIRD, nonexistent axiom**: there is no `prior_S_gap`
  constructor in `Axiom` at all. What exists under that similar name is
  `DerivedAxioms.priorSGap` — a **derived theorem** (the time-reflection mirror of the RTime axiom
  `prior_U_gap`), reached by a *different* search strategy, `tryGatedDerivedMatch`
  (`Search.lean:164-176`, tried as "Strategy 1a" right after `tryAxiomMatch` in
  `searchProof`, `Search.lean:598-605`), not by `tryAxiomMatch` at all. This is presumably where
  the chapter's confusion originated: a real, correctly-omitted-from-`tryAxiomMatch` name
  (`priorSGap`) got conflated with a nonexistent primitive-axiom constructor
  (`prior_S_gap`). The corrected chapter text should name exactly two omitted axioms
  (`prior_U_gap`, `sep`), matching Commands.lean.

**Fix**: bring `Search.lean`'s docstring and the chapter into agreement with Commands.lean's
already-correct "27 of the 29... omits the two Layer-9 Reynolds Dedekind axioms" framing, naming
only `prior_U_gap` and `sep`. Per the dispatch's instruction, prefer the generated value for the
"29": `p4-proof-automation.typ` does not currently import `axiom-count` from
`../generated/status.typ` (only `p2-decidability-practice.typ` and others import status.typ
fields; `p4-proof-automation.typ`'s only import is
`../generated/automation-module-map.typ:1-11`) — add that import and use `#axiom-count` in place
of a typed "29"/"45". The "27" (tryAxiomMatch's own list length) has no existing generator; it
remains a typed numeral unless a new generator is built, which is out of this task's apparent
scope — note this as a residual manual-maintenance risk for a future task, not something to build
here.

### Item 4 — `DecisionResult` constructors (MEDIUM)

**Reproduces exactly.** `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:80-90`
declares four constructors: `valid (proof : ⊢ φ)`, `invalid (counter : SimpleCountermodel)`,
`fuelExhausted`, `extractionFailed`. The module's own docstring (lines 70-78) explains the R7
split in detail: the former single `timeout` constructor conflated "fuel ran out, nothing
decided" (`fuelExhausted`) with "every tableau branch closed — the formula genuinely *is* valid —
but proof-term reconstruction failed" (`extractionFailed`); `isUndecided` (line 123-125) holds of
`fuelExhausted` only, never `extractionFailed`.

`typst/chapters/p2-decidability-practice.typ:82` currently says: "`DecisionResult`
(`Decidability/DecisionProcedure.lean`) is one of `valid` (carries a `DerivationTree`), `invalid`
(carries a `SimpleCountermodel`), or `timeout` — the `tableauFuel` parameter (default 1000
steps) is the source of the timeout branch, guaranteeing termination without guaranteeing an
answer." Also line 122: "an exhausted budget surfaces as the `timeout` outcome rather than as a
wrong answer." Both need the three-way `valid`/`invalid`/`timeout` split replaced by the true
four-way `valid`/`invalid`/`fuelExhausted`/`extractionFailed` split, explaining what
distinguishes the two non-verdict outcomes (fuel exhaustion = genuinely undecided; extraction
failure = tableau closed, formula is valid, proof term just wasn't recoverable).

**Why the sync check doesn't catch this**: the literal string "timeout" is *also* the name of a
real, distinct constructor on a *different* type, `CertOutcome`
(`Decidability/TraceCertificate.lean:96-100`: `validProof`/`countermodel`/`timeout`/`blocked`),
which the chapter correctly cites at line 89 (`CertOutcome (...: validProof/countermodel/timeout/blocked)`).
A grep-based sync check matching the bare word "timeout" against source finds this legitimate
occurrence and cannot distinguish it from the erroneous `DecisionResult` claim. No sync-check
change is proposed here — the dispatch item is about the prose, not the check.

**Other statements checked against source** (dispatch's follow-up ask): `decide`
(`DecisionProcedure.lean:176-215`)'s five-step algorithm description at chapter line 82 (axiom
shortcut → compositional shortcut → bounded search → tableau) matches the function body order
exactly. `isValid`/`isSatisfiable` (lines 323-329) and `getProof?`/`getCountermodel?` (lines
138-145) match the chapter's descriptions at lines 83-84 with no changes needed.

### Item 5 — `Axiom` is Type-valued, not Prop-valued (MEDIUM)

**Reproduces, and the stated rationale is factually backwards in three places, not just the
chapter.** Confirmed: `inductive Axiom : Formula → Type` (`Axioms.lean:152`) — `Axiom` **is**
`Type`-valued, exactly like `DerivationTree` (`inductive DerivationTree (fc : FrameClass) :
Context → Formula → Type`, `Derivation.lean:91`). There is no Prop/Type mismatch *between* these
two types at all; both are `Type`-valued.

The false claim appears in three places, worded almost identically each time:
- `Search.lean:21-24` (module docstring): "`Axiom` is `Prop`-valued while `DerivationTree` is
  `Type`-valued, so a `find_axiom_witness : Formula → Option (Axiom φ)` cannot be written, and
  the same mismatch is why Aesop's proof reconstruction does not work over these goals."
- `Commands.lean:107-109` (`modal_search` docstring): "avoiding the Axiom Prop vs Type issue by
  constructing proof terms directly via `mkAppM`".
- `typst/chapters/p4-proof-automation.typ:59,117`: "`Axiom` is `Prop`-valued while
  `DerivationTree` is `Type`-valued" (twice, once in prose, once in the module-map table).

**Authoritative, already-correct source for the real reason**, found in the archive rather than
the live docstrings: `Boneyard/RetiredTactics/README.md:88-95`, documenting why the retired
`TMLogic` Aesop rule set never worked: "Aesop's proof reconstruction fails on
`DerivationTree`-valued goals, which are `Type`-valued rather than `Prop`-valued." This is a
single-type claim (only about `DerivationTree`), not a two-type mismatch claim, and it is the
correct one — Aesop's whole reconstruction machinery targets `Prop`-valued goals (leaning on
proof irrelevance to search/backtrack cheaply, since any two proofs of the same proposition are
interchangeable); `DerivationTree` goals are `Type`-valued *data*, where the specific term
produced matters downstream (`.height`, structural recursion in the metalogic, the decision
procedure returning a `DerivationTree` as its validity certificate), so Aesop-style reconstruction
does not apply and a hand-written meta-level search (`TacticM`, `mkAppM`, `observing?` to avoid
corrupting metavariable state across failed candidate attempts) is used instead.

**Recommended fix**: correct all three occurrences to state the single true fact — `DerivationTree`
(not `Axiom`) is `Type`-valued, which is why Aesop-style automation doesn't apply and why the
search is hand-written at the meta level — grounding the language in the
`Boneyard/RetiredTactics/README.md` explanation rather than inventing a new "why" from scratch.
`Axiom` being *also* `Type`-valued can be mentioned (it's true and relevant background — it's why
a witness has computational content), but not framed as contrasting with `DerivationTree`.

### Item 6 — `apply_axiom` and `modal_t` descriptions (LOW, elaboration-verified)

**Reproduces, with a nuance the dispatch text doesn't fully capture: the chapter's `modal_t` item
is already correct; only `apply_axiom`'s framing (in both the docstring and the chapter) is
wrong, and the docstring examples for both macros are demonstrably broken.**

Ground truth (`FormalSystem/Automation/Tactics/UserTactics.lean:72-73,89-90`):
```lean
macro "apply_axiom" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
macro "modal_t" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
```
Byte-identical expansions. Neither macro does any unification against a specific axiom schema;
both simply apply the generic `axiom` constructor
(`h : Axiom φ`, `h_fc : h.minFrameClass ≤ fc` — `Derivation.lean:98`) and leave its two argument
goals open for the caller.

**Elaboration verification** (three `lake env lean` probes, all reproduced in a scratch file
outside `FormalSystem/`/`Tests/`, none committed):
1. `apply_axiom` alone on `⊢ (Formula.box p |>.imp p)` leaves **both** goals unsolved:
   `case h ⊢ Axiom (p.box.imp p)` and `case h_fc ⊢ Axiom.minFrameClass ?h ≤ FrameClass.Base`.
   This directly falsifies `UserTactics.lean:60`'s docstring example comment
   ("`apply_axiom  -- Finds and applies Axiom.modal_t`") — nothing is found or applied
   automatically.
2. The correct usage pattern — `apply_axiom; case h => exact Axiom.modal_t _; case h_fc =>
   trivial` — elaborates cleanly with no errors, confirming the description already recorded in
   `SYNC-MAP.md`'s 2026-09-17 entry ("one live-source correction found during verification", line
   545-553) and already reflected in the appendix's own tactic-mode example.
3. `UserTactics.lean:76-90`'s `modal_t` docstring example (`example (p : Formula) : [p.box] ⊢ p
   := by modal_t; assumption`) **does not compile as documented**: with `assumption` present, the
   error is `Tactic assumption failed` on the `h_fc` goal (`⊢ Axiom.minFrameClass ?h ≤
   FrameClass.Base`); with `sorry` in place of `assumption`, one goal is silently absorbed and
   `case h ⊢ Axiom p` (an unprovable bare-atom axiom-membership goal — no axiom concludes a bare
   propositional variable) remains unsolved. Either way the example is broken, and its own
   comment ("Applies: □p → p (from modal_t axiom)") doesn't even match its stated goal (`⊢ p`,
   not `⊢ □p → p`). The docstring's claimed implementation ("Detects goals of form `Γ ⊢ φ` where
   `□φ ∈ Γ`... applies modal T axiom and modus ponens... Applies Axiom.modal_t directly") is
   pure fiction relative to the actual macro body.

**Chapter state** (`typst/chapters/p4-proof-automation.typ:42-43`):
- Line 42 (`apply_axiom`): "...unifying the goal with an axiom schema and letting Lean infer the
  axiom's formula parameters via `refine`." — **wrong**, same defect as the Lean docstring:
  nothing is unified or inferred; the goals are left open. Needs correcting to describe the
  generic-constructor-application-with-open-side-goals behavior.
- Line 43 (`modal_t`): "...its macro body expands identically to `apply_axiom`'s (`apply
  DerivationTree.axiom; refine ?_`), so it applies to any axiom-shaped goal." — **this is already
  correct** and matches the verified ground truth. No chapter change needed for `modal_t`.

**Recommended fix**: rewrite `UserTactics.lean`'s `apply_axiom` docstring (lines 52-70, including
its now-stale "Supported Axioms" bullet list, which names `modal_4`, `modal_b`, `temp_4`,
`temp_a`, `temp_l` — **none of which are current `Axiom` constructors**, some being derived
theorems reached by a different mechanism) and `modal_t`'s docstring (lines 76-90) to both
describe the true, shared, generic behavior — apply the axiom constructor, leave `h`/`h_fc` open
for the caller — using a corrected worked example matching the verified `case h => exact
Axiom.modal_t _; case h_fc => trivial` pattern instead of the broken `assumption`-based one.
Correct the chapter's `apply_axiom` item (line 42) to match; leave the chapter's `modal_t` item
(line 43) as-is.

### Item 7 — Introduction's project-structure list (LOW)

**Reproduces exactly**, and reveals a matching, out-of-scope defect in the appendix itself worth
flagging.

`typst/chapters/00-introduction.typ:155-161` lists only `Syntax/`, `ProofSystem/`, `Semantics/`,
`Metalogic/`, `Theorems/`, `Automation/`, `Examples/` — omitting `MinusLanguage/`,
`PlusLanguage/`, `StarLanguage/`, `OpenLanguage/`, `ForMathlib/`, `Tactic/`, and
`MainResults.lean`, all present and directory-toured in `ax-lean-appendix.typ:976-991,987,989,991`.
Line 161 also says "`Automation/`, `Examples/` — Proof tactics, the training-data pipeline, and
worked examples, covered in Part II" — but `lakefile.toml:65-158` places every dataset/ML/
benchmark executable (`dataset_generator`, `dataset_validator`, `proof_extractor`,
`enum_benchmark`, `benchmark_anchors`, `benchmark_oracle`, `contrastive_generator`,
`tableau_bridge`, etc.) under the separate `BimodalTools` library (confirmed: `BimodalTools/`
directory at repo root, `[[lean_lib]] name = "BimodalTools"` at `lakefile.toml:66`), never under
`Automation/` or `Examples/`.

**Important nuance for the fix**: the dispatch says "Align it with the directory tour in the Lean
appendix" — but the Lean appendix's own directory tour (`ax-lean-appendix.typ:986`) makes the
*exact same* mis-attribution: "`Automation/`, `Examples/` — the proof tactics and worked examples
of Part II... **and the dataset pipeline** of @sec:dataset-pipeline" — directly contradicting
that same file's own, correct statement two subsections earlier (line 856: "The dataset and
benchmark tooling of Part II is a separate library, `BimodalTools`, built only on request.").
Since `ax-lean-appendix.typ` is off-limits to this task, **do not copy line 986's wrong
attribution forward into the introduction** — instead align the introduction's *structure and
directory coverage* with the appendix's directory tour while independently stating the correct
`BimodalTools` attribution that the same appendix already gets right at line 856. This
self-contradiction inside `ax-lean-appendix.typ` (lines 856 vs. 986) is itself a real defect but
is out of this task's file-edit scope; recommend flagging it for whatever future task next
touches that file (e.g. the define-before-use audit already queued and dependent on this task).

### Item 8 — Machine appendix metavariable letters (LOW)

**Reproduces exactly.** `typst/chapters/ax-machine-appendix.typ:40-41`'s illustrative JSON-shape
table writes:
```
[`untl`], [`{"tag": "untl", "event": <φ>, "guard": <ψ>}`],
[`snce`], [`{"tag": "snce", "event": <φ>, "guard": <ψ>}`],
```
This literally follows `BimodalTools/DataExport.lean:106-107,118-121`'s own internal
pattern-match variable naming (`| .untl ψ φ => ...event: φ, guard: ψ...`, i.e. Lean's
`ψ`=first-positional-arg=guard, `φ`=second-positional-arg=event). But the book's *own* notation,
stated explicitly and used pervasively (`typst/chapters/01-syntax.typ:22`: "in
`untlOp(φ,ψ)` the *guard* is `φ`... and the *event* is `ψ`"), is the **opposite** assignment:
guard=φ, event=ψ. The table (lines 40-41) is therefore internally consistent with the Lean
source's own variable names but inconsistent with every other φ/ψ occurrence in the book,
inviting exactly the misreading the dispatch describes. The explanatory paragraph at line 47
("keyed by *role*, not by argument position... whichever position each occupies in the Lean
constructor") is accurate and does not itself need to change.

**Recommended fix**: swap the two placeholder letters so the table reads `"event": <ψ>, "guard":
<φ>`, matching the book's global convention (this is a hand-authored illustrative table, not
generated from `machine-appendix.jsonl`, so the swap is purely cosmetic/safe — confirmed by its
location under "Schemas and definitions are given over the six-constructor primitive basis"
rather than any `#import`ed generated data). The `// CONFIRM(lean)` comment at line 24 ("the
machine appendix JSONL's since/until argument fields reflect guard-first constructor order")
makes no greek-letter-specific claim and needs no change either way.

### Item 9 — Template and build hygiene (LOW)

**(a) `#items`/`#item` hanging indent — reproduces.** `typst/template.typ:137-139`:
```typst
#let item(body) = block(spacing: 0.65em)[
  -- #body
]
```
This manually prepends a dash inside a plain `block` with no indent/hanging-indent configuration
at all — unlike Typst's native `list`, it gets no automatic wrap-alignment. Confirmed in the
compiled PDF: `#item[...]` call sites in the Tactics subsection of `p4-proof-automation.typ`
(lines 41-45) render with wrapped lines flush to the left margin (`pdftotext -layout` output,
lines 3022-3029), while native-list-based content elsewhere in the same PDF (e.g. lines
4467-4469) shows correct hanging indent. `#items` (lines 128-135) *does* configure `list`/`enum`
indent/body-indent, but `#item` never routes through either — it is plain block markup imitating
a bullet. Fix: give `#item` a `block(..., inset: (left: ...))`-plus-`par(hanging-indent: ...)`
treatment (or simplest: replace its body with an actual `list(marker: [--])` item so it inherits
`#items`' `set list(...)` styling for free) — 12 call sites across `typst/chapters/*.typ` use
`#items[ #item[...] ]`, all of which should render correctly once the definition is fixed, with
no call-site changes needed.

**(b) `thmbox` font warning — reproduces.** Confirmed via `typst compile`: two warnings,
"unknown font family: new computer modern sans" at `thmbox.typ:148` (title-fonts) and `:169`
(sans-fonts). The `thmbox` package (`@preview/thmbox:0.3.0`) defaults `sans-fonts =
("New Computer Modern Sans",)` (`thmbox.typ:6`), a font not present in this environment (`typst
fonts` lists "New Computer Modern" and "New Computer Modern Math" but no "...Sans" variant; no
sans font is referenced anywhere else in `typst/`, so there is no established precedent to
match). `template.typ:70-91` constructs every environment export (`theorem`, `lemma`, `axiom`
via `theorem-style`/`axiom-style`; `definition` via `definition-style`; `remark`, `example`,
`proposition`, `corollary`, `notation-env` via `remark-style`/`example-style`/reused
`theorem-style`) via `thmbox.X.with(..style-dict)`, none of which currently sets `sans-fonts`/
`title-fonts`, so all fall through to the package default. `proof` (line 75) is exported directly
(`thmbox.proof`, no `.with()` at all) and is equally exposed. Fix: add
`sans-fonts: (<available-font>,), title-fonts: (<available-font>,)` to each of the five style
dicts (`theorem-style`, `definition-style`, `axiom-style`, `remark-style`, `example-style` — this
covers every re-exported environment since `proposition`/`corollary`/`notation-env` reuse these
same dicts) and to the `proof` export's own `.with(...)`. No installed font is an obvious
metric-compatible match for "New Computer Modern Sans" in this environment; recommend "Noto Sans"
(broadest coverage, present) unless the implementer finds a closer match.

**(c) Code-block presentation — explicitly out of scope**, confirmed: the dispatch text itself
defers this to a separate, dependent task that owns `template.typ` and
`p2-decidability-practice.typ` next. No action here beyond noting the ordering dependency already
stated in the dispatch (this task must land first).

---

## Additional Finding (not in the dispatch's 9 items): `scripts/typst-sync-check.sh` currently FAILS

Running the full sync check against the live working tree (`bash scripts/typst-sync-check.sh`)
produces:
```
== Check 1: backtick name resolution ==
VIOLATION: `[inst : DecidableEq α]` -- ... (in: typst/chapters/ax-lean-appendix.typ)
VIOLATION: `name : Type` -- ... (in: typst/chapters/ax-lean-appendix.typ)
VIOLATION: `structure ... where` -- ... (in: typst/chapters/ax-lean-appendix.typ)
VIOLATION: `{ base := ..., .. }` -- ... (in: typst/chapters/ax-lean-appendix.typ)
VIOLATION: `⦃x : T⦄` -- ... (in: typst/chapters/ax-lean-appendix.typ)
TOTAL_VIOLATIONS=5
...
typst-sync-check.sh: FAIL
```
Checks 2, 2b, and 3 (generated-file freshness) all pass cleanly — only Check 1 fails. As
described under "Live Working-Tree Caveat" above, the five violations trace to two currently
**uncommitted** `// TODO:` comments in `ax-lean-appendix.typ` (lines 272-278, 303-314 of the
working-tree diff), each containing generic Lean-syntax illustrations inside backticks (e.g.
`` `structure ... where` ``, `` `name : Type` ``, `` `⦃x : T⦄` ``) that are exactly the kind of
non-declaration-citing illustrative span the existing "Lean appendix: generic Lean tooling
illustrations" whitelist category (`sync-check-whitelist.txt:141-148`) already exists to cover —
they are simply not yet added to it.

Since `ACCEPTANCE` for this task requires `scripts/typst-sync-check.sh PASS`, and since
`ax-lean-appendix.typ`'s content is off-limits, the correct remedy — assuming these violations
are still present at implementation time — is a new whitelist category in
`typst/sync-check-whitelist.txt` (which this task **is** permitted to edit) covering these five
exact spans, following the existing pattern (a category comment explaining they are illustrative
Lean syntax in editorial TODO comments, not declaration citations). **Re-verify this finding
first**: re-run `git status`/`git diff` on `ax-lean-appendix.typ` and `bash
scripts/typst-sync-check.sh` at the start of implementation, since the working tree may have
changed.

---

## Decisions

- Item 1: use letter-based real numbering ("Appendix A"/"Appendix B") plus a dynamic
  `el.supplement`/`el.numbering`-driven `#show ref` rule, rather than a narrower `if
  appendix-detected` branch — future-proofs against any other unnumbered level-1 heading.
- Item 1: close the `@machine-appendix` sub-claim as not-reproducing (no bare `@`-ref exists);
  still fix the rule since the underlying bug is real and would bite a future bare reference.
- Item 3: trust the machine-counted figures (29 axioms, 27 in `tryAxiomMatch`, omitted =
  `{prior_U_gap, sep}`) over the dispatch's own three-name list, which included a nonexistent
  constructor (`prior_S_gap`) confused with an actually-existing but differently-reached derived
  theorem (`priorSGap`).
- Item 6: preserve the chapter's already-correct `modal_t` item verbatim; only its `apply_axiom`
  item and both Lean docstrings need correction.
- Item 7: align structure/coverage with the appendix's directory tour, but do NOT copy forward
  the appendix's own latent `BimodalTools`-attribution error (lines 856 vs. 986 self-contradict);
  use the appendix's own correct statement (line 856) instead.
- New: whitelist (not appendix-content) is the sanctioned fix for the currently-failing Check 1,
  contingent on re-verification at implementation time given the live/uncommitted working tree.

## Risks & Mitigations

- **Working-tree instability** (see caveat above): the sync-check failure and its exact violating
  spans are a snapshot; re-verify before acting. Mitigation: explicit re-verification step
  documented above.
- **Item 1 is the highest-complexity change** (shared document-wide `#show ref` rule plus two
  appendix files' local heading setup): risk of regressing chapter (non-appendix) `@`-references,
  which must continue rendering "Chapter N" unchanged. Mitigation: the recommended rule reads
  `el.supplement` dynamically rather than branching on file/level, so ordinary chapters (which
  keep the existing global `supplement: "Chapter"` rule and non-`none` `"1.1"` numbering) are
  unaffected by construction; verify by re-running the full `pdftotext` chapter-reference grep
  after the change, not just the two appendix references.
- **Item 9(b)'s font choice** has no established precedent in this codebase; pick one that
  renders correctly and confirms zero warnings, note the choice in the implementation summary so
  it's easy to revisit.
- **Lean docstring edits are docstring-only per the CONSTRAINTS** (no statement/proof changes):
  items 3, 5, 6 all touch only `/-- ... -/` doc comments, never declarations — confirmed by
  re-reading each target span; no risk of crossing that line as scoped above.

## Context Extension Recommendations

- **Topic**: appendix-authoring TODO comments and Check 1. **Gap**: nothing in
  `.claude/context/project/typst/` (or wherever Typst domain context lives) currently documents
  that Check 1 scans `//` comments too, which makes a routine "leave a TODO for later" edit in a
  Typst chapter a silent sync-check hazard. **Recommendation**: a short note in the Typst domain
  context (or `SYNC-MAP.md`'s own header) that illustrative backtick spans inside comments need
  the same whitelist treatment as prose spans.

## Appendix

**Verification commands used**:
- `typst compile --root .. BimodalReference.typ /tmp/br-check.pdf` (2 font warnings, 0 errors)
- `pdftotext -layout /tmp/br-check.pdf /tmp/br-check.txt` + `grep` for `Chapter [0-9]{3,}`,
  `Appendix`, the `#item` wrapped-text region
- `bash scripts/typst-sync-check.sh` (baseline: FAIL, 5 Check-1 violations, Checks 2/2b/3 pass)
- `lake env lean` on four scratch probes (not committed, outside `FormalSystem/`/`Tests/`):
  `apply_axiom` alone (2 open goals), the verified correct `case h`/`case h_fc` pattern (0
  errors), `modal_t; assumption` (fails on `h_fc`), `modal_t; sorry` (leaves `h : Axiom p`
  unprovable)
- `awk`/`grep` constructor extraction over `Axioms.lean`'s `inductive Axiom` block (29),
  `Search.lean`'s `axiomCtors` list (27)
- `git log -S"counter(heading).update" -- typst/chapters/ax-lean-appendix.typ` (confirms the A.n
  numbering mechanism's introduction commit, `78ef65d6f`)
- `git status --porcelain` / `git diff -- typst/chapters/ax-lean-appendix.typ` (confirms the live
  uncommitted TODO-comment diff)
