# Implementation Plan: Paper / Lean / Docs Alignment

- **Task**: 488 - align_lean_code_and_docs_with_possible_worlds_paper
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: None
- **Research Inputs**: `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/01_paper-code-docs-alignment.md` (including its "Addendum: Orchestrator Verification Pass", which overrides the main body on D25, adds D28, and sharpens D20/D21)
- **Artifacts**: plans/02_paper-code-docs-alignment.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research report carries a 28-item discrepancy inventory (D1-D28) across three artifacts: the
JPL paper `possible_worlds.tex`, the Lean tree, and the documentation. This plan covers **only the
repo-side work**. The paper is read-only from this repository and is never edited here; the four
items whose only correct resolution is a paper change (D1-D4, plus the paper-side option on D5 and
the D6/D24 questions) are collected into a single author-facing memo instead of being silently
dropped.

D5's repo-side resolution -- giving the paper's `thm:TM-soundness` a direct Lean counterpart -- was
originally a phase here and has been split out into task 489, which proves `BaseLanguage` soundness
at `FrameClass.Base` and then extends it to the Dense, Discrete, and Dedekind extensions. That is a
proof-architecture decision, not a documentation correction, and it is the only item that would have
added a proof term to this sweep. With it gone, **this plan changes no Lean definition, proof, or
declaration -- every `.lean` edit it makes is inside a docstring.**

Definition of done: `scripts/check-paper-definitions.sh` exits 0, `scripts/typst-sync-check.sh`
passes, `scripts/check-module-invariants.sh` passes with C14 extended and a new C15 anchor check
in place, `lake build` is still clean and sorry-free, and the author memo exists under
`specs/488_align_lean_code_and_docs_with_possible_worlds_paper/`.

Two facts govern the whole plan and are not footnotes:

1. **`lake build` is clean and sorry-free today** (report F1: exit 0, 2493 jobs, zero
   `declaration uses 'sorry'`, C3 sorry inventory zero outside `Boneyard/`). Any phase that
   breaks it is a regression, not a trade-off.
2. **`README.md` has uncommitted working-tree changes from a concurrent session.** The diff
   (-10/+2) **deletes** the strong-completeness precision block that separates *refuted*
   (Discrete) from *open* (Base, Dense) from *not stated* (Dedekind), replacing it with the flat
   and false sentence "Completeness results are proven for all four frame classes". The report
   flags that flattening as a new SUBSTANTIVE regression. The same diff independently fixes the
   line-243 citation URL to `publications/possible_worlds.pdf`, which is a genuine partial fix for
   D19 and must be **kept**. Every phase touching `README.md` must reconcile with this diff first;
   Phase 6 owns that reconciliation and no other phase may edit `README.md` before it.

### Research Integration

- **Addendum overrides the main body in three places** and the plan is written against the
  addendum: D25 is *not* an open design question (A1 proves `nullity_identity` is derivable from
  `serial` + `limit` and supplies the verified Lean proof, so the "strictly stronger than the
  paper / OPEN DESIGN QUESTION" language at `FormalSystem/Semantics/TaskFrame.lean:501-509` is
  false and must be retired); D28 is new (README's box clause quantifies over partial histories
  where the paper and Lean both quantify over *total* world-histories); D20 is worse than the main
  body states (the three constraints README names are the two non-axioms, and *Spherical* — the
  condition the entire `def:constraints` -> `thm:extension` -> `cor:occurrence` chain consumes —
  is among the three omitted).
- **The pinned record must be re-baselined first.** `scripts/check-paper-definitions.sh` exits 1
  with 32 drifted definitions and 6 dangling anchors. Every phase that re-quotes paper text quotes
  from the re-pinned record produced by Phases 1 and 5, never from the live paper directly.
- **Explicitly not attempted**: proving `CompactBase` / `CompactDense` to make D1/D2 true. Strong
  completeness for Base and Dense is a genuine open research problem, already refuted for
  Discrete. The correct resolution is a paper correction, recorded in the memo.
- **Explicitly deferred**: D24's retirement of `F_until_equiv` / `P_since_equiv` (a 45 -> 43
  change touching every axiom count in the tree). It is recorded in the memo as an owner decision
  and must not be bundled with Phase 3's 42 -> 45 docstring fix.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` Phase 5 ("Publication and Documentation", Medium Priority) is the front this
work advances -- specifically the retained half of its README/docs/module-docstring polish row and
its C5/C9 check grounding. This plan does not mark any roadmap item complete; `roadmap_flag` was
not set for this dispatch, so `specs/ROADMAP.md` is read-only here.

## Goals & Non-Goals

**Goals**:

- Re-baseline `specs/paper-definitions-of-record.md` so `scripts/check-paper-definitions.sh` exits 0.
- Correct every documentation and docstring claim the report found false, in `README.md`,
  `FormalSystem/README.md`, `.lean` docstrings, and the typst manual.
- Repair all dangling paper-anchor citations in live (non-`Boneyard/`) scope.
- Regenerate `typst/generated/status.typ` so `scripts/typst-sync-check.sh` passes.
- Add mechanical guards (C14 extension, new C15) so both classes of drift are caught at write time.
- Collect the paper-side and owner-decision items into one author-facing memo.

**Non-Goals**:

- Editing `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. Read-only.
- Proving strong completeness for Base or Dense (D1/D2).
- Proving the completeness direction of decidability (D3).
- Formalizing `app:ObjectiveModality`, `app:TwoDimensional`, or the topology/presheaf/Conduche
  appendix block (D4) -- roughly 1,500 paper lines with no Lean counterpart.
- Retiring `F_until_equiv` / `P_since_equiv` (D24) or deleting the `nullity_identity` field (the
  ergonomic half of D25). Both are owner decisions, documented not made.
- Proving `BaseLanguage` soundness (D5). Split out into its own task, which establishes
  soundness at `FrameClass.Base` first and then extends it to the Dense, Discrete, and Dedekind
  extensions -- the same Base-then-extensions shape `Metalogic/Soundness.lean` already uses for
  TM+. That structure is a proof-architecture decision in its own right and does not belong inside
  a documentation-alignment sweep.
- Auditing `latex/BimodalReference.tex`, `Tests/BimodalTest/` against the paper, or the paper's
  bibliography -- named as out of scope by the report.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The paper drifts again mid-implementation (it has drifted at least six times, twice while a dispatch was in flight) | H | M | Re-run `scripts/check-paper-definitions.sh` at the start and end of every phase; Phase 5 re-pins the checksum so later phases have a fresh baseline |
| A phase edits `README.md` before the working-tree diff is reconciled, silently re-deleting the strong-completeness precision block | H | M | Phase 6 owns the reconciliation and is the sole entry point to `README.md`; Phase 7 is its only successor on that file |
| Mass verbatim-quote edits (Phases 8-11) silently change a docstring's meaning | M | M | Quote only from the re-pinned record; run `scripts/check-module-invariants.sh` after each such phase |
| A docstring edit crosses out of a Lean `/-- -/` block and breaks elaboration | H | L | Lean doc comments are elaborated, so every `.lean` phase carries tier `local` or higher (never `prose`) and builds the touched modules |
| Phase 3's 42 -> 45 fix collides with D24's deferred 45 -> 43 retirement | M | L | D24 is a Non-Goal here and is recorded in Phase 2's memo as an owner decision; the two must never be in the same plan |
| Fixing the CI badge URL exposes a genuinely failing or nonexistent workflow | M | M | Phase 7 verifies `.github/workflows/` exists and the badge target resolves before committing |
| The frame -> task frame sweep (Phase 11) collides with earlier per-file phases | M | M | Phase 11 depends on Phases 8, 9, and 10 so it runs after every file-scoped phase has closed |
| The new C15 check fires on `specs/**` or `Boneyard/` and blocks the gate | M | M | Phase 12 scopes C15 to live non-`specs/`, non-`Boneyard/` paths and resolves against the re-pinned record's DANGLING entries |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6 | 1, 2 |
| 3 | 7, 8, 9, 10 | 5, 6 |
| 4 | 11 | 5, 8, 9, 10 |
| 5 | 12 | 3, 5, 9, 10, 11 |
| 6 | 13 | 1-12 |

Phases within the same wave can execute in parallel. File territories are disjoint within every
wave; see each phase's "Files to modify" list.

---

### Phase 1: Re-pin the record -- dangling anchors and substantive drift [COMPLETED]

- **Goal**: Resolve the 6 dangling anchors and re-quote the 7 anchors whose mathematics or claim
  actually changed, so later phases have a correct baseline for the substantive items.
- **Tasks**:
  - [x] Run `bash scripts/check-paper-definitions.sh` and capture the current failure output as
        the phase's starting evidence. *(completed: exit 1, 32 drifted, 6 dangling — matches the plan's asserted counts exactly)*
  - [x] Fix the four `def:frame#*` item anchors (`Compositionality`, `Seriality`, `Limit`,
        `Spherical`): the paper changed `\item[\it X:]` to `\item[\bf X:]` and the `\aitem`/item
        resolver keys on the markup. Re-resolve against `\bf`. *(deviation: altered — re-resolving "against `\bf`" alone would only move the brittleness one markup wave along, so the `item` resolver in `scripts/check-paper-definitions.sh` was made markup-agnostic (tries `\it`, `\bf`, `\em`, `\itshape`, `\bfseries`, bare; first match wins, still literal `grep -F`). The hash still covers the resolved line verbatim, so a markup change is still reported as drift — only resolution is agnostic. This adds `scripts/check-paper-definitions.sh` to the phase's file set.)*
  - [x] Retire `thm:s4` and `thm:sym` as DANGLING (removed from the paper, folded into a single
        `thm:s5` at paper line 2158) and add `thm:s5` following the record's own convention for
        new anchors. *(completed: `\label{thm:s5}` confirmed at live paper line 2158; it states S4, B and T as three conjuncts of one theorem)*
  - [x] Re-quote and re-hash the 7 substantive anchors: `def:directed` (split into
        `⊇-Directed` / `⊆-Directed`), `def:frame` (Spherical now reads "`⊇`-directed family",
        plus the new `S₁ᵈ` ball-space footnote), `def:frame-properties` (Deterministic clause
        removed, now standalone `def:deterministic` at 2868), `cor:tm-completeness` (new Lean
        attribution footnote), `def:strongest` / `thm:exist` ("normal" dropped), `def:id`
        (expanded), `thm:extension` (footnote no longer says "and hence to the axiom of choice").
  - [x] For each of the 7, record in the record file what changed and whether it has Lean impact,
        so Phases 8-11 can quote from it rather than from the live paper. *(completed in the Phase-1 drift-correction section; the per-anchor Lean-impact column is written there)*
  - [x] Re-run `bash scripts/check-paper-definitions.sh`; confirm the dangling count has gone
        6 -> 0 and only terminological/cosmetic drift remains. *(completed: dangling 6 -> 0, drift 32 -> 24; the 24 residual are Phase 5's terminological/cosmetic set)*
- **Timing**: 1.5 hours
- **Depends on**: none
- **Verification Tier**: prose
- **Scope Hypothesis**: The report asserts exactly 6 dangling anchors and 7 substantive drifted
  anchors. Confirm at implementation time by reading the live output of
  `bash scripts/check-paper-definitions.sh` before editing, and by re-reading it after. If the
  counts differ from 6 and 7, record the actual counts in the phase's progress notes and treat the
  script output, not this plan, as authoritative.
- **Files to modify**:
  - `specs/paper-definitions-of-record.md` - re-resolve 4 item anchors, retire 2, add `thm:s5`,
    re-quote and re-hash 7 substantive anchors
- **Verification**:
  - `bash scripts/check-paper-definitions.sh` reports 0 unresolved anchors (drift count may still
    be non-zero; Phase 5 closes it)
  - Every re-quoted block matches the live paper verbatim at the cited line

---

### Phase 2: Author-facing memo for paper-side and owner-decision items [COMPLETED]

- **Goal**: Collect every item this repository cannot resolve into one written deliverable, so
  nothing is silently dropped and no phase mistakes a paper correction for a repo edit.
- **Tasks**:
  - [x] Create the memo under
        `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/`.
  - [x] Section "Paper corrections requested", one entry per item with the exact paper line and
        the exact Lean counter-evidence:
        - D1: TM⁺ strong completeness attributed to this repository (`:4661`, `:4668`) vs.
          `strongCompletenessBase_of_compact` being conditional on the unproved `CompactBase`
          (`FormalSystem/Metalogic/StrongCompleteness.lean:305`).
        - D2: same for TM⁺_d (`:4662`) vs. `CompactDense`
          (`FormalSystem/Metalogic/StrongCompleteness.lean:331`).
        - D3: "making TM⁺ decidable as implemented in the Lean 4 repository" (`:1706`)
          contradicting the paper's own commented-out `cor:tm-decidability` proof (`:4683`) and
          the tree's one-directional soundness result.
        - D4: "The results throughout are formalized in Lean 4" (`:1801`) scoping over
          `app:ObjectiveModality`, `app:TwoDimensional`, and the topology/presheaf/Conduche block
          (~1,500 lines with no Lean counterpart).
        - D5 (both resolutions): `thm:TM-soundness` (`:4484`, attributed at `:4311`, `:4494`)
          has no direct Lean counterpart today. The repo-side resolution is split out into its own
          task, which proves `BaseLanguage` soundness at `FrameClass.Base` and extends it to the
          Dense, Discrete, and Dedekind extensions. Record that the obligation is tracked there,
          and ask whether the author additionally wants the paper-side fix (narrowing the
          attribution to TM+ soundness) as a hedge until that task lands.
  - [x] Section "Owner decisions required", stating the question and the options without making
        the call:
        - D6: `def:TMplus-c` bases BX_c on `TMP-PU` + `TMP-SEP` with no density axiom, while
          `FrameClass.Dedekind` carries 42 axioms including `density` and `dense_indicator`.
          Either the paper adds the density axioms to BX_c, or the tree records that
          `completeness_dedekind` proves a stronger-premise statement.
        - D24: `F_until_equiv` and `P_since_equiv` are definitionally `X → X` (verified by `rfl`).
          Retiring them is a 45 -> 43 change touching every axiom count in the tree and is
          deliberately not attempted here.
        - D25 (ergonomic half): with `nullity_identity` now known to be derivable from `serial` +
          `limit`, whether to delete the field (breaking every construction site) or keep it as
          documented redundancy is an ergonomic call, not a mathematical one. Phase 8 keeps it and
          corrects the docstring; the deletion question stays open here.
        - D27: `▽φ` is `¬△¬φ` in Lean vs. the paper's explicit disjunction. Classically
          equivalent, term-distinct; no change recommended.
  - [x] State plainly at the top of the memo that the paper is read-only from this repository and
        that none of these items was edited into the `.tex`.
- **Timing**: 1 hour
- **Depends on**: none
- **Verification Tier**: prose
- **Scope Hypothesis**: The memo asserts specific paper line numbers (`:1706`, `:1801`, `:4484`,
  `:4622`, `:4661`, `:4662`, `:4668`, `:4683`). Confirm each by reading the live paper at that
  line before writing it into the memo; if a line has moved, cite the anchor and the new line.
- **Files to modify**:
  - `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md` -
    new file (the memo)
- **Verification**:
  - Every paper line cited in the memo resolves to the claimed text in the live `.tex`
  - Every Lean counter-claim cites a file and declaration that exists
  - `git status` shows no modification under `/home/benjamin/Philosophy/`

---

### Phase 3: Correct the stale axiom-count docstrings [COMPLETED]

- **Goal**: Replace every in-tree "42 axiom constructors" claim with the verified 45, and correct
  the layer count and the arithmetic in the `Axioms.lean` header.
- **Tasks**:
  - [x] *(completed: `axiom_count 45`, `base 37`, `dense 2`, `discrete 3`, `dedekind 3`, all as predicted; independently cross-checked by counting constructors per layer in `Axioms.lean` — 4+5+18+4+1+5+2+1+2+3 = 45 across nine layers)* Re-derive the authoritative counts before editing: `bash scripts/typst-status-counts.sh`
        (expect `axiom_count 45`, `base 37`, `dense 2`, `discrete 3`, `dedekind 3`) and the
        `Axiom.minFrameClass` routing in `FormalSystem/ProofSystem/Axioms.lean`.
  - [x] *(completed: now 45, with the parenthetical `32 core + 5 uniformity + 2 prior + 1 Z1 + 2 density + 3 Reynolds Dedekind` which does add to 45, plus a by-frame-class restatement. The header's `### Layers` list also stopped at layer 4 and omitted the BX13/BX13' `enrichment_until/since` pair, so its own BX enumeration did not add to its stated 22; layers 5-9 and the missing pair were added.)* `FormalSystem/ProofSystem/Axioms.lean:58` - "42 axiom constructors (32 base + 5 uniformity
        + 2 prior + 1 Z1 + 2 density)": correct the total to 45 and correct the parenthetical so
        the summands actually add to the total.
  - [x] `FormalSystem/ProofSystem/Axioms.lean:84` - "42 constructors organized into eight layers"
        -> 45 constructors, nine layers. *(completed, with the Reynolds Dedekind layer added to the bulleted list and to the closing frame-class sentence)*
  - [x] *(deviation: altered — see the note below; corrected to "42 of the 45 axiom schemata" rather than to "45")* `FormalSystem/Metalogic/Decidability/ProofExtraction.lean:27` - "all 42 axiom schemata".
  - [x] `FormalSystem/Automation/ProofSearch/Core.lean:322` - "all 42 axioms are implications or
        negations". *(deviation: altered — see the note below. A SECOND site was found in the same file at `:696` ("any of the 42 TM axiom schemata") and corrected too.)*
  - [x] `FormalSystem/Automation/Tactics/Helpers.lean:33` and `:1103` - "All 42 axiom constructors
        across 8 layers" / "(42 constructors)". *(deviation: altered — see the note below. A THIRD site was found in the same file at `:564` (`-- Try each axiom constructor (all 42)`) and corrected too.)*
  - [x] *(deviation: altered — see the note below)* `FormalSystem/Automation/Tactics/Commands.lean:454` - "resolve all 42 axiom constructors".
  - [x] Do **not** touch `F_until_equiv` or `P_since_equiv`; D24 is a Non-Goal and would move the
        count to 43. *(completed: neither was touched; both are still listed as BX12/BX12' in the header)*

**Phase 3 finding — the automation "42"s were not simply stale.** The plan assumed all six sites
were stale copies of an old total. Two of them were, in `Axioms.lean`, and were corrected to 45.
The other four were not: `Automation/Tactics/Helpers.lean`'s `axiomCtors` list contains **exactly
42 entries**, and `Automation/ProofSearch/Core.lean`'s `matchAxiom` matches **exactly the same 42**
— both genuinely omit the three Layer-9 Reynolds Dedekind constructors `prior_U_gap`,
`prior_S_gap` and `sep`. `Metalogic/Decidability/ProofExtraction.lean` delegates to `matchAxiom`,
so it inherits the same coverage. Rewriting those four (plus the three extra sites found by grep)
to say "45" would have replaced a stale number with a **false** one. Each was instead corrected to
state coverage honestly — "42 of the tree's 45" — and to name the three omitted axioms, and
`Helpers.lean:33` additionally warns that a Dedekind-class goal needing one of them will not be
closed by `tryAxiomMatch`. Closing the coverage gap itself is a code change (adding three entries
to `axiomCtors`), which this plan's Overview explicitly forbids: every `.lean` edit here is inside
a comment. It is left for a follow-on.

The phase's `grep -rn '42 axiom\|42 constructors\|all 42'` gate is satisfied: the corrected
sentences were phrased as "42 of the tree's 45", which matches none of the three patterns.
- **Timing**: 45 minutes
- **Depends on**: none
- **Verification Tier**: full
- **Scope Hypothesis**: The report asserts exactly six stale "42" sites across six files. Confirm
  with `grep -rn '\b42\b' FormalSystem/ --include='*.lean'` filtered to axiom-count context before
  editing, and re-run it after; any additional site found is in scope for this phase. Also confirm
  45 is still the live count via `scripts/typst-status-counts.sh` rather than trusting this plan.
- **Files to modify**:
  - `FormalSystem/ProofSystem/Axioms.lean` - header count and layer count
  - `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` - schema count
  - `FormalSystem/Automation/ProofSearch/Core.lean` - axiom count
  - `FormalSystem/Automation/Tactics/Helpers.lean` - two sites
  - `FormalSystem/Automation/Tactics/Commands.lean` - one site
- **Verification**:
  - `lake build` exits 0 with no new warnings and no `declaration uses 'sorry'`
  - `bash scripts/check-module-invariants.sh --no-build` still passes, C14 included
  - `grep -rn '42 axiom\|42 constructors\|all 42' FormalSystem/ --include='*.lean'` returns nothing
- **Justification for tier**: `full` because this phase edits `FormalSystem/ProofSystem/Axioms.lean`,
  the module every proof script and tactic in the tree elaborates against. Lean doc comments are
  elaborated, so a malformed edit here is a whole-tree build failure, not a comment typo.

---

### Phase 4: Regenerate the typst status counts [COMPLETED]

- **Goal**: Bring `typst/generated/status.typ` back in sync with the tree so
  `scripts/typst-sync-check.sh` passes.
- **Tasks**:
  - [x] Run `bash scripts/typst-sync-check.sh` and capture the three current mismatches
        (`sorry-total` committed 5 / live 4; `sorry-total-excl-boneyard` committed 1 / live 0;
        `sorry-table[WeakCanonical/]` committed 5 / live 4). *(completed: exactly those three, confirmed by the resulting diff; checks 1 and 3 were already green, so the scope-hypothesis escape hatch did not fire)*
  - [x] Regenerate via `bash scripts/typst-status-counts.sh` and write the result to
        `typst/generated/status.typ` using whatever mechanism the script documents; do not
        hand-edit the generated numbers. *(completed: the script writes `typst/generated/status.typ` itself as a side effect, so no separate write step was needed; nothing was hand-edited)*
  - [x] Confirm the regenerated file's provenance stamp updates (it is currently stamped
        `08927bc5e (2026-08-17)`). *(completed: now `dfea0264b (2026-08-26)`)*
- **Timing**: 15 minutes
- **Depends on**: none
- **Verification Tier**: local
- **Scope Hypothesis**: The report asserts exactly three count mismatches, all sorry-related.
  Confirm by reading the live `scripts/typst-sync-check.sh` output before regenerating. If check 1
  (backtick name resolution) or check 3 (machine appendix freshness) has since gone red, that is
  outside this phase and must be reported, not silently absorbed.
- **Files to modify**:
  - `typst/generated/status.typ` - regenerated in full by the script
- **Verification**:
  - `bash scripts/typst-sync-check.sh` exits 0 with `MISMATCH_COUNT=0`
  - `git diff typst/generated/status.typ` shows only count and stamp changes, no structural edits
- **Justification for tier**: `local` rather than `prose` because the file is a compiled typst
  source, and the verification is a real command (`typst-sync-check.sh`) confined to the typst
  subtree, not a diff read-through.

---

### Phase 5: Re-pin the record -- terminological drift and checksum re-baseline [COMPLETED]

- **Goal**: Close the remaining drift so `scripts/check-paper-definitions.sh` exits 0, giving
  every downstream phase a fresh, trustworthy quote source.
- **Tasks**:
  - [x] *(deviation: altered — the actual residual after Phase 1 was 24 drifted anchors, not ~25: 17 carry the rename (not ~20), 7 are cosmetic-only (not 5), and three of the 17 carry a second, non-terminological change the plan did not anticipate — `lem:constraint` gained the `⊇`-directed qualifier, `def:constraints` contracted its frame-tuple expansion, and `thm:BLplus-NextPrevious` was split into three sentences. `lem:constraint` was not on the plan's list at all. All 24 re-quoted and re-hashed; the per-anchor accounting is in the record's "Drift correction (2026-08-25), part 2" section.)* Re-quote and re-hash the ~20 anchors whose only change is the global `frame` -> `task frame`
        rename: `def:task-relation`, `lem:nullity`, `def:world-history`, `thm:extension`,
        `cor:occurrence`, `def:constraints`, `lem:nesting`, `lem:nonempty`, `lem:admissible`,
        `lem:step`, `def:BL-semantics`, `def:time-shift-histories`, `def:frame-validity`,
        `app:discrete`, `app:dense`, `app:complete`, `cor:spherical-finite`, and the partial
        overlaps already handled in Phase 1.
  - [x] Re-quote and re-hash the 5 cosmetic-only anchors (`def:S5`, `def:BX`,
        `def:BLplus-semantics`, `def:TMplus-c`, `def:TMplus-f`): `\vspace` retuning, `\it` -> `\bf`,
        `\mathrm{Th}` -> `\Th` macro.
  - [x] *(completed: checksum `5d700a2f…`, 4856 lines, paper repo HEAD `94f850f69f34…` (file dirty against it, dirty-pin caveat applies))* Re-pin `FILE_CHECKSUM`, `LINE_COUNT`, and `PINNED_COMMIT` sentinels against the live paper
        (currently 4856 lines, sha256 `5d700a2f05999bb6…`; the record pins
        `f134fd7d460c08aaf94c5b1c09571ab2663c509d1ee32f2d31b89ee640281381` at 4213 lines).
  - [x] Write a new "Drift correction (2026-08-25)" section following the file's own established
        convention for prior drift waves. *(completed as two sections, part 1 (Phase 1) and part 2 (Phase 5), because the correction was executed as two waves)*
  - [x] *(completed: all twelve confirmed present in the live paper, none cited anywhere in this repository; the decision not to pin them, with each one's live line number, is recorded in part 2)* Do **not** add the paper's new appendix anchors (`def:task-topology`, `app:topology-t1`,
        `app:topology-r0`, `app:gluing`, `def:interval-site`, `def:behavior-presheaf`,
        `lem:factorization-linear`, `lem:interval-twisted-arrow`, `app:presheaf-dictionary`,
        `def:path-category`, `def:conduche`, `cor:path-fibration`) unless they become load-bearing;
        record the decision not to pin them.
  - [x] Add `def:deterministic` (paper line 2868), which *is* load-bearing -- Phase 8 repoints
        `TemporalStructures.lean` at it. *(completed: `\label{def:deterministic}` confirmed at live line 2868)*
- **Timing**: 1.5 hours
- **Depends on**: 1
- **Verification Tier**: prose
- **Scope Hypothesis**: The report asserts 32 drifted anchors total, of which Phase 1 handles 7,
  leaving ~25 here (20 terminological + 5 cosmetic). Confirm by diffing the drift list in the live
  `scripts/check-paper-definitions.sh` output against Phase 1's closing output; the residual list,
  not this plan's enumeration, is the work item.
- **Files to modify**:
  - `specs/paper-definitions-of-record.md` - re-quote and re-hash the residual anchors, re-pin the
    checksum sentinels, add the drift-correction section, add `def:deterministic`
- **Verification**:
  - `bash scripts/check-paper-definitions.sh` **exits 0** -- this is the phase's gate
  - The new drift-correction section matches the file's existing convention for prior waves

---

### Phase 6: Reconcile README.md and correct its semantics section [COMPLETED]

- **Goal**: Resolve the concurrent-session working-tree diff and fix the three semantics-section
  errors (D28, D20, D21).
- **Tasks**:
  - [x] *(deviation: altered — the premise no longer held. `git diff README.md` was EMPTY at implementation time: the concurrent session's edit had been committed as `dfea0264b "update"`, and inspecting that commit shows it is -1/+1 on a single "Related Projects" line (dropping "AlphaZero-style" from the BimodalHarness description), NOT the -10/+2 deletion the plan describes. The strong-completeness precision block is INTACT in `README.md` at lines 146-152 — Discrete refuted, Base/Dense open, Dedekind not stated, plus the `ValidDedekindDense` sentence — and the citation URL at line 246 is already `publications/possible_worlds.pdf`. Nothing needed restoring; the reconciliation was a verification, and both halves the plan cared about were verified present rather than repaired.)* **Precondition, not a footnote**: run `git diff README.md` and reconcile before any edit.
        **Restore** the strong-completeness precision block the diff deletes (the block separating
        Discrete = refuted, Base/Dense = open, Dedekind = not stated, and the
        `ValidDedekindDense` sentence) -- the report verifies all of it correct against
        `DiscreteNonCompactness.lean:280`, `SetConsequence.lean`, and
        `StrongCompleteness.lean:469`, and its replacement ("Completeness results are proven for
        all four frame classes") is false for the infinitary reading. **Keep** the diff's change of
        the citation URL to `publications/possible_worlds.pdf`; it is a genuine partial D19 fix
        that Phase 7 completes.
  - [x] *(completed: verified against `FormalSystem/Semantics/Truth.lean:164`, `| Formula.box φ => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ`)* D28 (box clause): the `□` clause currently reads "for all world-histories `σ`", but the
        README's own world-history definition is a map from a convex subset of `D`, i.e. partial.
        The paper's `def:BL-semantics` quantifies over `H_F` (total) and Lean does too
        (`FormalSystem/Semantics/Truth.lean:166`, `∀ σ, σ.IsTotal → …`;
        `Validity.lean:94-97` binds `τ.IsTotal`). Change to "for all **total** world-histories
        `σ`". This is not cosmetic: atoms are false off-domain, so a `□` ranging over partial
        histories would falsify `□p` almost everywhere and break the S5 fragment.
  - [x] *(completed: rewritten as a four-axiom bulleted list — Compositionality (biconditional), Seriality, Limit, Spherical (`⊇`-directed, `S₁ᵈ`) — plus nonempty `W` and the converse convention, with an explicit note that Nullity is derived and that `converse`/`nullity_identity` are ergonomic fields adding no content. Axiom text quoted from the Phase-1 re-pinned `def:frame`.)* D20 (task-frame constraints): the sentence naming "three constraints: nullity,
        compositionality, and reflection" names the two non-axioms and omits Seriality, Limit, and
        Spherical. Rewrite it to state the paper's four `def:frame` axioms (Compositionality,
        Seriality, Limit, Spherical) plus the nonempty `W` and the converse convention, and note
        that `converse` and `nullity_identity` are carried as `structure TaskFrame` fields for
        construction ergonomics rather than as independent content. Quote the axiom names from the
        record re-pinned in Phase 1, not from the live paper.
  - [x] *(completed: `untl ψ φ` / `snce ψ φ`; verified against `FormalSystem/Semantics/Truth.lean:165`, whose `Formula.untl ψ φ` clause puts the existential witness on `φ` and the interval condition on `ψ`. The argument-order note was placed under the Primitive table rather than in the surrounding prose, so it sits adjacent to the column it explains.)* D21 (operator table): the "Lean Constructor" column is the only wrong part -- `U(φ,ψ)`
        maps to `untl ψ φ` and `S(φ,ψ)` to `snce ψ φ`, because README's `U(…)`/`S(…)` notation is
        event-first while both the paper's `φ ▷ ψ` and Lean's `untl guard event` are guard-first.
        Leave the notation column and the truth clauses alone; they are internally consistent. Add
        one sentence noting that README's `U(φ,ψ)` and the paper's `φ \until ψ` take their
        arguments in opposite orders, so a reader cross-referencing the two does not silently
        invert every temporal clause.
- **Timing**: 1 hour
- **Depends on**: 1
- **Verification Tier**: prose
- **Scope Hypothesis**: This phase cites README line numbers (66, 42-43, 74-77, 146-152) taken
  against committed `git HEAD` `36da86ead`. The working-tree diff already shifts them. Locate each
  site by its text, never by the line number in this plan, and record the actual lines edited.
- **Files to modify**:
  - `README.md` - restore the precision block, fix the box clause, rewrite the constraints
    sentence, fix the Lean Constructor column
- **Verification**:
  - `git diff README.md` shows the precision block restored and the URL fix retained
  - The box clause says "total world-histories"; the constraints sentence names all four paper
    axioms plus nonempty `W` and converse
  - The Lean Constructor column reads `untl ψ φ` / `snce ψ φ`
  - `bash scripts/check-module-invariants.sh --no-build` still passes (C5, C12, C13, C14)
- **Justification for tier**: `prose` -- `README.md` is pure markdown with no compile or
  elaboration surface. The residual blind spot (broken cross-references) is covered by the C5/C12/C13
  run in the verification list and again by the final gate in Phase 13.

---

### Phase 7: README.md and FormalSystem/README.md remaining corrections [COMPLETED]

- **Goal**: Fix the repository URL everywhere it appears and retire the stale TM⁺_c "gap" claim.
- **Tasks**:
  - [x] *(completed: all three README sites corrected — CI badge (line 3), clone instruction (line 149), `@software` citation `url` (line 269))* D19: `git remote -v` resolves to `git@github.com:benbrastmckie/BimodalLogic.git`, and the
        paper cites `BimodalLogic` in 8 places, but `README.md` says `ProofChecker` in the CI
        badge, the `git clone` instruction, and the `@software` citation `url`. Correct all three.
  - [x] *(completed: `.github/workflows/ci.yml` exists and the badge path `actions/workflows/ci.yml` matches its filename, so the badge was corrected rather than removed)* Verify the CI badge actually resolves: confirm a workflow file exists under
        `.github/workflows/` and that the badge path matches its filename. If no workflow exists,
        remove the badge rather than shipping a corrected-but-still-broken one, and say so in the
        phase notes.
  - [x] *(completed: all three now read `https://benbrastmckie.com/publications/possible_worlds.pdf`. Note the header link (line 11) was a FOURTH variant the plan did not name — `publications/possible-worlds.pdf`, hyphenated — not merely a third form of the other two.)* Reconcile the three different paper URLs in `README.md` (the header link, the
        `wp-content/uploads/2026/07/possible_worlds.pdf` link, and the citation URL Phase 6
        retained) to one canonical form.
  - [x] *(completed: both passages rewritten against the Phase-1 re-pinned `cor:tm-completeness` ("TM⁺_c — Weakly complete over the dense-and-complete class") and the live `def:TMplus-c`, whose `{ℤ,ℝ}` / `Th(ℤ)∩Th(ℝ)` footnote is confirmed commented out. Both now state that `FrameClass.Dedekind` IS TM⁺_c and that there is no gap, and both cross-reference the residual BX_c axiom-basis question as an author decision rather than resolving it.)* D7: `README.md` and `FormalSystem/README.md` both assert the paper's TM⁺_c is
        "completeness *simpliciter*", that its models are exactly `{ℤ, ℝ}`, and that no element of
        `FrameClass` picks that class out. All three are stale: the live `cor:tm-completeness`
        (paper line 4664) reads "TM⁺_c Weakly complete over the dense-and-complete class", and the
        `{ℤ,ℝ}` / `Th(ℤ)∩Th(ℝ)` footnote in `def:TMplus-c` is commented out (`:4635-4640`). Under
        the paper's current text `FrameClass.Dedekind` **is** TM⁺_c. Rewrite both passages against
        the Phase 1 re-pinned `cor:tm-completeness`, and cross-reference the memo's D6 entry for
        the residual BX_c axiom-basis question rather than resolving it here.
- **Timing**: 45 minutes
- **Depends on**: 6
- **Verification Tier**: prose
- **Scope Hypothesis**: The report asserts the `ProofChecker` string appears at three README sites
  and the TM⁺_c claim at two (README plus `FormalSystem/README.md`). Confirm with
  `grep -rn 'ProofChecker' README.md docs/ FormalSystem/README.md` before editing; every hit in
  documentation prose is in scope. Note that the Lean namespace and project name may legitimately
  remain `ProofChecker` -- only repository-URL and clone-target occurrences change.
- **Files to modify**:
  - `README.md` - CI badge, clone instruction, citation URL, paper-URL reconciliation, TM⁺_c passage
  - `FormalSystem/README.md` - TM⁺_c passage
- **Verification**:
  - `grep -n 'benbrastmckie/ProofChecker' README.md` returns nothing
  - The badge URL's workflow file exists on disk (or the badge is removed)
  - Exactly one paper URL form appears in `README.md`
  - `bash scripts/check-module-invariants.sh --no-build` still passes

---

### Phase 8: Semantics core docstrings -- retire the false nullity claim [COMPLETED]

- **Goal**: Retire the "strictly stronger than the paper / OPEN DESIGN QUESTION" language the
  addendum disproves, and correct the three other semantics docstring claims in these files.
- **Tasks**:
  - [x] *(completed: the whole "Strictly stronger than the paper -- OPEN DESIGN QUESTION" block and its three-options/joint-decision framing are gone. Both proofs the addendum supplies were INDEPENDENTLY TYPECHECKED before being written into the docstring, via a standalone snippet against `FormalSystem.Semantics.FrameAxioms` -- `inj_at_zero_of_limit` (injectivity-at-zero from `limit` alone, instantiating the cone witness at `y := 0`) and `nullity_iff_of_serial_limit` (the full `↔`, composing that with `TaskFrame.nullity_of_serial_limit`, confirmed to exist at `Semantics/FrameAxioms.lean:149`). Both compile clean; they are reproduced in the docstring as a `lean` fence rather than as live `example`s, since the plan's Overview forbids adding declarations. `FrameAxioms.lean`'s own closing note, which repeated the "strictly stronger" claim, was corrected to match.)* D25 (the addendum's correction, which overrides the main report): at
        `FormalSystem/Semantics/TaskFrame.lean:501-509`, replace the "Strictly stronger than the
        paper -- OPEN DESIGN QUESTION" block and its three-options/joint-decision framing. The
        question is **settled, not deferred**: injectivity-at-zero follows from the `limit` field
        alone by instantiating the cone witness at `y := 0`, and reflexivity is
        `TaskFrame.nullity_of_serial_limit` (`FormalSystem/Semantics/FrameAxioms.lean:149`), i.e.
        `serial` at `x = 0` composed with the same `limit`. Together they give the field's full
        `↔`. The addendum supplies both proofs verbatim (`inj_at_zero_of_limit`,
        `nullity_iff_of_serial_limit`); reproduce them in the docstring, or as `example`s, only if
        they typecheck under the phase's build.
  - [x] *(completed: the corrected docstring states the inter-derivability of the Lean field set and the paper's axioms explicitly, and states that the `⊇` half of Limit's `⋂_{x>0}(w)_x = {w}` is supplied by reflexivity-at-zero rather than assumed)* State positively in the corrected docstring that the Lean frame class is **extensionally
        exactly the paper's** -- `{nullity_identity, comp, converse, serial, limit, spherical}` and
        the paper's four `def:frame` axioms plus nonempty `W` plus the converse convention are
        inter-derivable -- and that the `⊇` half of `⋂_{x>0}(w)_x = {w}` follows from
        reflexivity-at-zero, closing F10's separate worry.
  - [x] *(completed: field untouched; the docstring records it as retained documented redundancy and refers the deletion question to the author memo)* Keep the `nullity_identity` field. The keep-versus-delete call is an owner decision
        recorded in Phase 2's memo; note in the docstring that the field is retained as documented
        redundancy for construction ergonomics.
  - [x] *(completed: added as a dedicated "Where this sits in the ball-space hierarchy" paragraph, quoting the Phase-1 re-pinned `def:frame` footnote, and warning that "Spherical" is not a synonym for "spherically complete")* D10: add the paper's new `S₁ᵈ` ball-space characterization to the `Spherical` docstring
        (`TaskFrame.lean:343`) -- it sits in the Cmiel-Kuhlmann-Kuhlmann ball-space hierarchy and
        is strictly stronger than "spherically complete" (`S₁`). Quote from the Phase 1 re-pinned
        `def:frame`.
  - [x] *(completed: repointed to `def:deterministic`. Note the sentence was not simply a wrong citation -- it argued that `app:deterministic` does not exist and that determinism lives inside `def:frame-properties`. The first half is still true, the second no longer is, so the sentence was rewritten rather than having one anchor swapped.)* D11: `FormalSystem/Examples/TemporalStructures.lean:219` says `Deterministic` is a clause
        inside `def:frame-properties`. The paper removed it; it is now standalone
        `def:deterministic` (paper line 2868, pinned in Phase 5). Repoint the citation.
  - [x] *(completed, and wider than the plan anticipated: the sweep found 6 quotations of the Spherical text needing the `⊇` qualifier in `TaskFrame.lean` alone (not just `:39`/`:343`), 2 of `cor:spherical-finite`'s "Every frame", and 5 sites in `FrameAxioms.lean`. `def:constraints`'s in-tree verbatim quote had drifted on THREE counts, not one -- "over a frame $\F = \tuple{...}$" -> "over a task frame $\F$", "constraints imposed on $z$" -> "constraints on $z$", and `\Fib(...)` -> `\fib{...}` -- and the paper also added a "when both $t,s \in X$" clause. The `DirectedFamily` definition docstring quoted an undifferentiated "directed" from before the paper split `def:directed`; it now quotes the `$\supseteq$` clause and records the split. Five lines that the qualifier pushed past 100 columns were reflowed.)* Within these three files only, update verbatim quotes of `lem:nullity` and `def:frame` to
        the re-pinned text (the `frame` -> `task frame` rename and the `⊇`-directed qualifier),
        including `TaskFrame.lean:39` and `FrameAxioms.lean:129`. Sites in other files are
        Phase 11's territory.
- **Timing**: 1 hour
- **Depends on**: 5
- **Verification Tier**: local
- **Scope Hypothesis**: This phase asserts specific line anchors (`TaskFrame.lean:39`, `:343`,
  `:501-509`; `FrameAxioms.lean:129`, `:149`; `TemporalStructures.lean:219`). Locate each by its
  text, not its line number, and confirm the `nullity_of_serial_limit` declaration exists at the
  claimed name before citing it in a docstring.
- **Files to modify**:
  - `FormalSystem/Semantics/TaskFrame.lean` - nullity docstring, Spherical docstring, quote refresh
  - `FormalSystem/Semantics/FrameAxioms.lean` - quote refresh
  - `FormalSystem/Examples/TemporalStructures.lean` - `def:deterministic` repoint
- **Verification**:
  - `lake build` exits 0, no new warnings, no `declaration uses 'sorry'`
  - No occurrence of "OPEN DESIGN QUESTION" or "Strictly stronger than the paper" remains in
    `TaskFrame.lean`
  - `bash scripts/check-paper-definitions.sh` still exits 0
- **Justification for tier**: `local` rather than `prose` because Lean `/-- -/` doc comments are
  parsed and attached to declarations -- an unbalanced delimiter or a stray `-/` breaks
  elaboration. The edits change no signature, so `interface` is not warranted; building the three
  touched modules plus the closing `lake build` is the right granularity.

---

### Phase 9: Extension cluster -- lem:fibers and the Zorn footnote [COMPLETED]

- **Goal**: Repair the largest dangling-anchor cluster and the stale axiom-of-choice quotation.
- **Tasks**:
  - [x] *(completed: 17 occurrences across exactly the 6 files the plan names, confirmed by grep before and after. Strategy decided once and applied uniformly: NO live anchor covers `lem:fibers`' content -- `lem:admissible` states the extension criterion in terms of "belongs to every member of the constraints", which is `lem:fibers`' left-hand side, not its fiber-condition equivalence -- so every site keeps the name and is annotated as a RETIRED anchor resolving against the record's DANGLING entry. `Admissible.lean` carries the full retirement note; each other file carries a one-clause marker at its own citation; `Semantics.lean` carries a short paragraph. The two "verbatim" quotations are now attributed "as last resolved before the paper retired the anchor", which is why they alone correctly keep the pre-rename "over a frame" wording.)* D16: `lem:fibers` was removed from the paper (retired 2026-08-17 wave 2, per the record)
        and is cited 17 times across `FormalSystem/Semantics.lean` and
        `FormalSystem/Semantics/Extension/{README.md, Constraint.lean, Step.lean, Admissible.lean,
        Extension.lean}`. Repoint each citation to a live anchor if one covers the same content, or
        to the record's DANGLING entry with a note that the paper retired it. Decide once and apply
        uniformly; do not mix strategies across the 17 sites.
  - [x] *(deviation: altered -- the plan says three sites; grep found TWO, `Extension.lean:30` and the test file. `Extension.lean:190` quotes the footnote but was a second copy in the theorem docstring rather than a third distinct site; both `Extension.lean` copies plus the test were re-quoted, so three quotations across two files. The re-quote is not a deletion of six words: the paper also WIDENED the choice-free contrast class to name `cor:spherical-finite` alongside `lem:nullity`, which the test file's "no-Zorn claim" section turns on, so its sentence was rewritten rather than trimmed.)* D12: `thm:extension`'s footnote no longer says the proof appeals to Zorn's lemma "and
        hence to the axiom of choice"; the paper restructured the sentence. Three sites quote the
        old text verbatim -- `Semantics/Extension/Extension.lean:30`, `:190`, and
        `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean:290`. Re-quote all three from
        the Phase 5 re-pinned `thm:extension`.
  - [x] *(deviation: skipped -- already correct, no change needed. `grep -rn 'thm:occurrence\|app:nonempty'` over live scope returns exactly ONE site, `Extension.lean:96`, and that site already reads "The anchors that carried it (`thm:occurrence`, `app:nonempty`) no longer exist; the paper merged them into the single, strictly stronger `cor:occurrence`" -- which is exactly the repoint the plan asks for, already performed by earlier work. Both anchors were instead given explicit DANGLING rows in the record's new KNOWN-ANCHORS block so C15 resolves them.)* D18 (the two Extension-cluster members): `thm:occurrence` was renamed `cor:occurrence`,
        and `app:nonempty` was merged into `cor:occurrence`. Both citations are in
        `Semantics/Extension/Extension.lean`; repoint both to `cor:occurrence`.
- **Timing**: 1.25 hours
- **Depends on**: 5
- **Verification Tier**: local
- **Scope Hypothesis**: The report asserts `lem:fibers` appears 17 times across 6 files and the
  Zorn quote at 3 sites. Confirm with `grep -rn 'lem:fibers' FormalSystem/ Tests/ --include='*.lean'
  --include='*.md'` and a grep for "axiom of choice" before editing; re-run both after. The actual
  match count governs.
- **Files to modify**:
  - `FormalSystem/Semantics.lean` - `lem:fibers` citations
  - `FormalSystem/Semantics/Extension/README.md` - `lem:fibers` citations
  - `FormalSystem/Semantics/Extension/Constraint.lean` - `lem:fibers` citations
  - `FormalSystem/Semantics/Extension/Step.lean` - `lem:fibers` citations
  - `FormalSystem/Semantics/Extension/Admissible.lean` - `lem:fibers` citations
  - `FormalSystem/Semantics/Extension/Extension.lean` - `lem:fibers`, Zorn footnote,
    `thm:occurrence`, `app:nonempty`
  - `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` - Zorn footnote
- **Verification**:
  - `lake build` exits 0, no new warnings, no `declaration uses 'sorry'`
  - `grep -rn 'lem:fibers\|thm:occurrence\|app:nonempty' FormalSystem/ Tests/` returns only
    deliberate DANGLING-entry references, if the repoint strategy chose that route
  - `bash scripts/check-module-invariants.sh --no-build` passes
- **Justification for tier**: `local` -- comment-only edits across one module cluster, but inside
  elaborated Lean doc comments, so a build of the touched modules is required rather than a diff
  read-through.

---

### Phase 10: Remaining dangling anchors and typst prose alignment [COMPLETED]

- **Goal**: Repair the dangling citations outside the Extension cluster and qualify the typst
  manual's "directed family" wording.
- **Tasks**:
  - [x] *(deviation: skipped -- already correct. Live-scope grep returns 4 sites, not 5, and every one already annotates the anchor as non-existent: `Conservativity.lean` says "`\label{thm:ConservativeExtension}` **no longer exists** in the paper. Cite it only as..." and "Do **not** cite `thm:ConservativeExtension` as a live anchor"; `typst/SYNC-MAP.md:411` whitelists it as a deliberate negative-resolution citation; `p2-frame-classes.typ:182` is a comment recording the deletion. Given a DANGLING row in the record instead, so C15 resolves it.)* D18: `thm:ConservativeExtension` was never a paper label and is cited 5 times, in
        `FormalSystem/Metalogic/Conservativity.lean`, `typst/chapters/p2-frame-classes.typ`, and
        `typst/SYNC-MAP.md`. It appears to be an invented anchor; replace each citation with a
        reference to the in-tree theorem it actually names, or drop the anchor form.
  - [x] *(completed, and worse than the plan states. Both sites cited `app:valid` at "line 1984" -- reading the live paper at 1984 gives an unrelated `Ddef` about operator interpretation, so the line number was bogus too. The surrounding prose also named the wrong paper ("The Perpetuity Calculus of Agency" rather than "The Construction of Possible Worlds"). Repointed to the live `cor:perpetuity-valid` (paper line 4497, "The perpetuity principles P1 -- P6 are all valid"), the paper title corrected, and the bogus citation recorded at the site so it is not reintroduced.)* D18: `app:valid` does not exist and is cited twice in
        `FormalSystem/Metalogic/Soundness.lean`. Repoint or drop.
  - [x] *(completed: 4 sites confirmed. Two (`p2-decidability-practice.typ:21`, `p3-decidability-frontier.typ:88`) are already `// CONFIRM(paper):` markers flagging it as unconfirmed, and `typst/SYNC-MAP.md:411` already whitelists it as a negative-resolution citation -- all three left alone. `BiLasso/README.md:7` was the one site presenting it as a published corollary; it now states that the label is commented out in the live paper, cites it as an unpublished remark, and records that its own commented text agrees with this tree that no decidability theorem is machine-checked.)* D17: `cor:tm-decidability` is fully commented out in the paper (`:4672-4688`) and is cited
        4 times, in `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, `typst/SYNC-MAP.md`,
        `typst/chapters/p3-decidability-frontier.typ`, and
        `typst/chapters/p2-decidability-practice.typ`. Cite the paper's commented text as an
        unpublished remark, or drop the citation; do not present it as a published corollary. Note
        that the paper's own commented-out proof says no decidability theorem is machine-checked at
        present -- consistent with the tree.
  - [x] *(completed: 8 sites, not 5 -- 4 in `02-semantics.typ` as the plan says, but 4 in `FormalFoundations.typ` rather than 1. Rendered as `$supset.eq$-directed` in typst. `typst-sync-check.sh` re-run after: still PASS, all 3 checks green, so Phase 4's gate did not regress.)* D9 (typst half): `typst/chapters/02-semantics.typ` (four sites) and
        `typst/FormalFoundations.typ` quote "directed family" without the `⊇` qualifier the paper's
        re-pinned `def:directed` now carries. Add the qualifier.
- **Timing**: 1 hour
- **Depends on**: 5
- **Verification Tier**: local
- **Scope Hypothesis**: The report asserts 11 dangling citations here (5 + 2 + 4) across 7 files,
  plus 5 typst "directed family" sites across 2 files. Confirm each count by grep before editing
  and again after; the greps govern, not this enumeration.
- **Files to modify**:
  - `FormalSystem/Metalogic/Conservativity.lean` - `thm:ConservativeExtension`
  - `FormalSystem/Metalogic/Soundness.lean` - `app:valid`
  - `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - `cor:tm-decidability`
  - `typst/SYNC-MAP.md` - `thm:ConservativeExtension`, `cor:tm-decidability`
  - `typst/chapters/p2-frame-classes.typ` - `thm:ConservativeExtension`
  - `typst/chapters/p3-decidability-frontier.typ` - `cor:tm-decidability`
  - `typst/chapters/p2-decidability-practice.typ` - `cor:tm-decidability`
  - `typst/chapters/02-semantics.typ` - `⊇`-directed qualifier
  - `typst/FormalFoundations.typ` - `⊇`-directed qualifier
- **Verification**:
  - `lake build` exits 0, no new warnings, no `declaration uses 'sorry'`
  - `bash scripts/typst-sync-check.sh` still exits 0 (Phase 4's gate must not regress)
  - `grep -rn 'thm:ConservativeExtension\|app:valid\|cor:tm-decidability' FormalSystem/ typst/`
    returns only deliberate, annotated references

---

### Phase 11: frame -> task frame verbatim-quote sweep [COMPLETED]

- **Goal**: Bring every remaining verbatim paper quotation in the tree in line with the paper's
  global `frame` -> `task frame` rename.
- **Tasks**:
  - [x] *(completed -- concrete enumeration below)* Enumerate the residual sites: for each of the ~20 anchors re-pinned in Phase 5 for the
        rename, grep the live tree (excluding `Boneyard/` and `specs/`) for quotations of the old
        text. Phases 8, 9, and 10 have already handled the sites in their own territories, so this
        phase's work is exactly the complement.
  - [x] Update each quotation to the re-pinned text. Quote from
        `specs/paper-definitions-of-record.md`, never from the live paper directly -- the record is
        the baseline the gate checks against.
  - [x] Where a docstring paraphrases rather than quotes, leave it alone unless the paraphrase is
        now wrong; this phase is a fidelity sweep, not a rewording pass.
  - [x] Apply the `⊇`-directed qualifier (D9) to any remaining Lean docstring quotation of
        `def:directed` outside Phase 8's and Phase 10's territories.

**Phase 11 enumeration (produced by grep, as the phase requires).** The complement was **not**
empty -- 15 residual sites across 7 files outside Phases 8-10's territories:

| File | Sites | Quotation |
|---|---|---|
| `FormalSystem/Examples/TemporalStructures.lean` | 5 | `def:frame#Spherical`, `⊇` qualifier |
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 2 | `def:frame#Spherical`, `⊇` qualifier |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 2 | `def:frame#Spherical`, `⊇` qualifier |
| `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` | 1 | `def:frame#Spherical`, `⊇` qualifier |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | 1 | `def:frame#Spherical`, `⊇` qualifier |
| `Tests/BimodalTest/Semantics/TaskFrameTest.lean` | 1 | `def:frame#Spherical`, `⊇` qualifier |
| `FormalSystem/Semantics/Validity.lean` | 2 | `def:frame-validity`, `frame` -> `task frame` (both the LaTeX and the ASCII rendering of the same quote) |
| `FormalSystem/Semantics/PartialHistory.lean` | 1 | `def:world-history`, `frame` -> `task frame` |

Two sites were deliberately **left** on the pre-rename wording: `Extension/Admissible.lean:27`
and `:135`, the two `lem:fibers` quotations. That anchor is retired, the record's DANGLING entry
preserves its last-resolved text, and both sites are now attributed "as last resolved before the
paper retired the anchor" -- so updating them to the paper's current terminology would make them
quote text the paper never contained.

The `⊇` insertion pushed 12 Lean lines past the tree's observed 100-column convention (`TaskFrame.lean`
and `Semantics.lean` had zero over-long lines before this task). All were rewrapped, and a
before/after check confirms no `.lean` line over 100 columns is new to this task.
- **Timing**: 1 hour
- **Depends on**: 5, 8, 9, 10
- **Verification Tier**: local
- **Scope Hypothesis**: The report estimates "~20 other quote sites" for the rename without
  enumerating them, and this plan does not either. The enumeration is the first task of the phase:
  produce the concrete list by grep, record it in the phase notes, and treat any divergence from
  "~20" as expected rather than as an error. If the grep returns zero residual sites because
  Phases 8-10 covered them all, close the phase as `[COMPLETED WITH EXCLUSIONS]` with the grep
  output as evidence.
- **Files to modify**:
  - Determined by the phase's own enumeration; expected to be Lean docstrings under
    `FormalSystem/Semantics/` and `FormalSystem/Metalogic/` plus typst chapters, excluding every
    file already owned by Phases 8, 9, and 10
- **Verification**:
  - `lake build` exits 0, no new warnings, no `declaration uses 'sorry'`
  - `bash scripts/check-paper-definitions.sh` exits 0
  - `bash scripts/check-module-invariants.sh --no-build` passes
  - The phase notes carry the concrete before-and-after site list

---

### Phase 12: Extend C14 and add the C15 anchor-integrity check [COMPLETED]

- **Goal**: Make both classes of drift mechanically detectable at write time, so neither recurs.
- **Tasks**:
  - [x] *(completed. C14's two existing responsibilities are untouched -- the markdown pattern is byte-identical and the `#print axioms` HARD STOP half is unchanged. The `.lean` half is a new, separate grep, excluding `Boneyard/`, with a trailing `grep -i axiom` PRECISION guard: without it the tripwire fires on `EnrichedFormula`'s legitimate "21 constructors" in `Automation/Normalization.lean`, which is a true statement about a different type. **The widening immediately caught seven further stale claims no gate had ever seen** -- all of an axiom count of 21, a figure older than the 42 this task was chartered to fix: `ProofSystem.lean:16`, `FormalSystem.lean:29`, `Automation.lean:90`, `Tactics/Commands.lean:102`, `FrameConditions/Compatibility.lean:19`, `FrameConditions/Soundness.lean:33` and `:181`. All seven were corrected. Two of them (`Compatibility.lean`, `Soundness.lean`) were not number swaps: they carried hand-maintained axiom ENUMERATIONS naming `temp_k_dist`, `temp_4`, `temp_a`, `temp_a_dual`, `temp_l`, `temp_future`, `discreteness_forward`, `seriality_future` and `seriality_past`, none of which is a constructor of `Axiom` any more. Both were replaced with the by-frame-class counts and an explicit statement that the theorems cover their class BY QUANTIFICATION (`ax : Axiom φ`), not by enumeration -- the enumeration is what went stale, so it was not rebuilt.)* Extend C14's content scan from `docs/` + `README.md` to `FormalSystem/**/*.lean`
        docstrings. C14's current scope is exactly why six "42 axiom constructors" claims survived
        a 42 -> 45 change. Preserve C14's existing two responsibilities (the stale-count tripwire
        and the axiom-baseline HARD STOP) unchanged; this is a scope widening, not a rewrite.
  - [x] *(completed: C15 added, PASS on all 46 paper-anchor citations in live scope)* Add a C15 check: every `(def|thm|lem|cor|app|rmk):slug` citation in live, non-`specs/`,
        non-`Boneyard/` scope must resolve to a live `\label{}` in the pinned paper, or to an
        explicit DANGLING entry in `specs/paper-definitions-of-record.md`. This is the mechanism
        that would have caught all 30 dangling citations at write time.
  - [x] *(completed, with one design addition the plan did not specify. Resolving "against the re-pinned record" needed a machine-readable target for anchors the manifest does not pin: 10 anchors the tree cites are LIVE in the paper but deliberately unpinned (`app:deterministic`, `cor:perpetuity-valid`, `def:BL-language`, the topology-appendix block, ...), and 4 more are cited only inside prose recording that they do NOT exist (`app:valid`, `thm:ConservativeExtension`, `thm:occurrence`, `app:nonempty`). A new `<!-- KNOWN-ANCHORS:BEGIN/END -->` block in the record enumerates all 18 such anchors with a status of `LIVE-UNPINNED` or `DANGLING` and a one-line reason each, so C15 resolves against manifest rows OR known-anchor rows and every citation in the tree is a recorded decision. `Boneyard/` is excluded via `--exclude-dir` (required: `grep -h -o` discards the path, so a post-hoc path filter is unavailable on that pipeline) and `specs/**` is simply never walked.)* Scope C15 deliberately: `Boneyard/` and `specs/**` are excluded; the resolution source is
        the re-pinned record, not the live `.tex`, so C15 does not go red merely because the author
        edited the paper.
  - [x] *(deviation: altered -- the prescribed target does not exist in this repository. There is no `agent-system/` directory here at all: `.claude/` is deployed from a source store that lives in a DIFFERENT repository, so there was no source-store path to write to, and writing to `.claude/**` is forbidden by `.claude/rules/source-store-deploy-boundary.md` (the file would be wiped by the next regeneration). The note was written to the durable in-repo home instead, which is arguably where it belonged anyway: the paper-anchor citation convention is specific to THIS repository's relationship with one paper, not a general Lean-language convention. `docs/development/MODULE_INVARIANTS.md` gains a C15 row, an updated C14 row, and a new companion-file section documenting the two-status resolution model and why the resolution source is the record and not the live `.tex`; the record itself carries the convention at its `KNOWN-ANCHORS` block.)* Add a short context note under `.claude/context/project/lean4/` describing the paper-anchor
        citation convention and the new check. **Write it to the source store**
        (`agent-system/extensions/lean/context/project/lean4/` or the equivalent extension path),
        never to `.claude/**` directly -- `.claude/` is a regenerated deploy artifact and a
        hand-authored file there is wiped by the next regeneration.
  - [x] *(completed: C15 added to the header inventory, C14's entry updated to name its widened scope, and the record added to the header's companion-files list)* Register both checks in the script's own header inventory so
        `scripts/check-module-invariants.sh`'s documented check list stays accurate.
- **Timing**: 1.5 hours
- **Depends on**: 3, 5, 9, 10, 11
- **Verification Tier**: full
- **Scope Hypothesis**: This phase asserts that C14 currently scans only `docs/` + `README.md` and
  that no anchor-integrity check exists. Confirm both by reading `scripts/check-module-invariants.sh`
  before editing -- the check numbering and scope in that file govern, not this plan.
- **Files to modify**:
  - `scripts/check-module-invariants.sh` - widen C14, add C15, update the header inventory
  - `agent-system/extensions/lean/context/project/lean4/` (path to be confirmed against the
    extension layout) - new context note on the citation convention
- **Verification**:
  - `bash scripts/check-module-invariants.sh` passes in full, with C14 and C15 both reporting PASS
  - C15 deliberately fails when a known-bad anchor is injected into a scratch file, then passes
    again when removed (prove the check actually fires)
  - `lake build` exits 0

**Negative test performed, as the phase requires.** A scratch file citing an anchor absent from
the record was written to `docs/`, the gate was run and reported `FAIL C15  1 paper-anchor
citation(s) resolve to nothing`, naming the anchor and the file; the scratch file was deleted and
the gate re-run, reporting `PASS C15  all 46 paper-anchor citation(s) resolve`. The check fires.

**Both new checks then fired on this task's own documentation**, which is the same self-reference
hazard `docs/development/MODULE_INVARIANTS.md` already warns about for C12 and C14: describing
C15's negative test spelled a literal unresolvable anchor into `docs/`, and describing C14's
widening quoted the stale counts in the exact shape the tripwire matches. Both sentences were
reworded to name the shape rather than spell an instance, and that page's "A note on this file"
section was extended to record the C15 case for the next author.

- **Justification for tier**: `full` because this phase changes the repository's own gate
  machinery. A check that silently passes on everything is worse than no check, so the verification
  must be the complete gate set plus a deliberate negative test.

---

### Phase 13: Final gate sweep and stamp refresh [IN PROGRESS]

- **Goal**: Prove every gate green simultaneously at the end, and refresh the staleness stamps so
  their dates reflect the verification actually performed.
- **Tasks**:
  - [ ] Run the complete gate set in one pass and record the output: `lake build`;
        `bash scripts/check-module-invariants.sh`; `bash scripts/check-paper-definitions.sh`;
        `bash scripts/typst-sync-check.sh`; `bash scripts/typst-status-counts.sh`.
  - [ ] Confirm `lake build` is still clean and sorry-free -- it was clean before this task began,
        so anything else is a regression introduced here.
  - [ ] Confirm `scripts/check-paper-definitions.sh` exits 0 and
        `scripts/typst-sync-check.sh` passes. If the paper drifted again mid-implementation, do not
        paper over it: re-run Phase 5's re-pin against the new paper state and record that a second
        re-pin was needed.
  - [x] *(completed: `FormalSystem/README.md` -> 2026-08-25, with the specific gates it stands on named inline rather than a bare date; `latex/README.md` -> 2026-08-25)* D26: refresh the stale stamps now that verification has actually happened --
        `FormalSystem/README.md`'s "Last verified: 2026-05-29" and `latex/README.md`'s
        "Last Updated: 2026-03-16". Use the date of this sweep, not a guess.
  - [x] *(completed via the README's own documented `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` command. Confirmed: 539 files, 170,898 code, 413 live `.lean` under `FormalSystem/`, 156 archived, and the axiom figures 45 / 37 / 39 / 40 / 42 (Dense 37+2, Discrete 37+3, Dedekind 37+2+3, per `scripts/typst-status-counts.sh`). **One figure was stale**: comment lines are 96,423, not 96,290 — corrected. Re-verifying rather than copying the report's figures forward is what caught it.)* Re-verify the README numeric claims the report validated (539 files, 170,898 LOC / 96,290
        comment, 413 live, 156 archived, 45 / 37 / 39 / 40 / 42) via `cloc` and
        `scripts/typst-status-counts.sh`, so the refreshed stamp is honest.
  - [x] Write the implementation summary under
        `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/summaries/`.
- **Timing**: 30 minutes
- **Depends on**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
- **Verification Tier**: full
- **Scope Hypothesis**: This phase asserts two stale stamps and a specific set of README numeric
  claims. Confirm the stamps by grep and each numeric claim by re-running the command that
  produces it, rather than copying the report's figures forward.
- **Files to modify**:
  - `FormalSystem/README.md` - Last verified stamp
  - `latex/README.md` - Last Updated stamp
  - `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/summaries/03_paper-code-docs-alignment-summary.md` - new
- **Verification**:
  - All five commands above green in a single recorded pass
  - `git status` shows no unintended modification outside the plan's declared file set, and none
    under `/home/benjamin/Philosophy/`

---

## Testing & Validation

- [x] `lake build` exits 0, zero `error:`, zero `declaration uses 'sorry'`
- [x] `bash scripts/check-module-invariants.sh` passes, including C3 (sorry inventory zero outside
      `Boneyard/`), the widened C14, and the new C15
- [x] `bash scripts/check-paper-definitions.sh` **exits 0** (currently exits 1: 32 drifted,
      6 dangling) *(now the quiet case-(a) pass: the re-pinned checksum matches the live paper)*
- [x] `bash scripts/typst-sync-check.sh` passes with `MISMATCH_COUNT=0` (currently FAIL, 3
      mismatches)
- [x] `#print axioms` spot-check on the flagship metatheorems still returns exactly
      `[propext, Classical.choice, Quot.sound]` *(covered by C2 and C14's `#print axioms` half in the full, non-`--no-build` gate run)*
- [x] No dangling paper-anchor citation remains in live non-`Boneyard/`, non-`specs/` scope, as
      proven by the new C15 rather than by a manual grep *(C15: all 46 citations resolve)*
- [x] `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` is unmodified *(sha256 `5d700a2f…` unchanged throughout; its single uncommitted edit predates this task by four days)*
- [x] The author memo exists and covers D1-D4, the D5 paper-side option, D6, D24, the D25
      field-deletion question, and D27

## Artifacts & Outputs

- `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/plans/02_paper-code-docs-alignment.md` (this plan)
- `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md` (Phase 2)
- `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/summaries/03_paper-code-docs-alignment-summary.md` (Phase 13)
- Re-pinned `specs/paper-definitions-of-record.md` (Phases 1, 5)
- Corrected `README.md`, `FormalSystem/README.md` (Phases 6, 7, 14)
- Corrected Lean docstrings across `FormalSystem/Semantics/`, `FormalSystem/ProofSystem/`,
  `FormalSystem/Metalogic/`, `FormalSystem/Automation/`, `FormalSystem/Examples/` (Phases 3, 8, 9,
  10, 11)
- Regenerated `typst/generated/status.typ` and corrected typst chapters (Phases 4, 10)
- Widened C14 and new C15 in `scripts/check-module-invariants.sh`, plus a source-store context
  note on the citation convention (Phase 12)

## Rollback/Contingency

- Every phase is a separate commit; revert a single phase with `git revert` on its commit rather
  than resetting the branch. The working tree carries concurrent-session changes to `README.md`,
  so destructive git on a dirty tree is blocked by `guard-destructive-git.sh` and must not be
  attempted -- take `bash .claude/scripts/git-snapshot.sh 488` first if a rollback is genuinely
  needed.
- Phases 1-2, 4-7, and 9-11 are text-only and carry no build risk; reverting any of them restores
  the prior documentation state with no effect on proofs.
- Phases 3, 8, 12, and 13 touch elaborated Lean or the gate machinery. If `lake build` goes red,
  fix forward -- never discard uncommitted changes to reach a passing build, and never introduce a
  `sorry` to close a phase. The tree's sorry inventory is zero outside `Boneyard/` and that is a
  hard invariant here.
- D5 carries no rollback risk in this plan: no phase here touches it. If its own task finds the
  composite does not close mechanically, that is a finding to record there, and this plan's memo
  entry for D5 stands unchanged.
- If the paper drifts again mid-implementation, re-run Phase 5's re-pin before continuing; do not
  let later phases quote from a stale record.
