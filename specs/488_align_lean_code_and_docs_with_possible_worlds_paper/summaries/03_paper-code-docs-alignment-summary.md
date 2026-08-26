# Implementation Summary: Paper / Lean / Docs Alignment

- **Task**: 488 - align_lean_code_and_docs_with_possible_worlds_paper
- **Plan**: `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/plans/02_paper-code-docs-alignment.md`
- **Phases**: 13 of 13 completed
- **Type**: lean4 (documentation-only: no Lean definition, proof, or declaration changed)

## What Was Done

The JPL paper `possible_worlds.tex` had drifted through a further editing wave (4213 → 4856 lines)
since the repository last pinned it, and the tree's documentation had drifted independently. This
sweep re-baselined the pinned record, corrected every false documentation and docstring claim the
research report found, repaired every dangling paper-anchor citation in live scope, and added two
mechanical guards so both classes of drift are caught at write time instead of accumulating.

Every item whose only correct resolution is a change to the paper, or an owner decision about the
Lean tree, was collected into an author-facing memo rather than silently dropped or unilaterally
decided.

**Not one Lean definition, proof, or declaration changed.** Every `.lean` edit is inside a comment
or docstring. `lake build` was clean and sorry-free before this task and is clean and sorry-free
after.

## Gate Results

| Gate | Before | After |
|---|---|---|
| `lake build` | exit 0, sorry-free | exit 0, sorry-free, no new warnings |
| `scripts/check-paper-definitions.sh` | **exit 1** — 32 drifted, 6 unresolvable | **exit 0** (quiet case-(a) pass) |
| `scripts/typst-sync-check.sh` | **FAIL** — 3 count mismatches | **PASS** — all 3 checks green |
| `scripts/check-module-invariants.sh` | ALL PASSED (13 checks) | ALL PASSED (14 checks: C14 widened, C15 new) |
| Sorry inventory outside `Boneyard/` | 0 | 0 |
| New axioms | — | 0 |

## Phase-by-Phase

| Phase | Outcome |
|---|---|
| 1. Re-pin: dangling + substantive drift | Unresolvable anchors 6 → 0; 11 anchors re-quoted and re-hashed; `thm:s4`/`thm:sym` retired, `thm:s5` added |
| 2. Author memo | `reports/02_author-memo.md`: D1-D5 as paper corrections, D6/D24/D25/D27 as owner decisions, plus a verification record |
| 3. Stale axiom-count docstrings | 9 sites corrected across 6 files; total 42 → 45, eight layers → nine |
| 4. Typst status counts | `typst/generated/status.typ` regenerated; 3 mismatches → 0 |
| 5. Re-pin: terminological drift + checksum | 24 residual anchors re-quoted; sentinels re-pinned; `def:deterministic` added; 12 new appendix anchors deliberately not pinned, decision recorded |
| 6. README semantics section | Box clause now quantifies over **total** world-histories; task-frame constraints rewritten as the paper's four axioms; operator table's Lean Constructor column corrected |
| 7. README + FormalSystem/README | Repository URL corrected in 3 README sites + 2 docs files; 4 paper-URL variants reconciled to 1; the stale TM⁺_c "gap" claim retired in both READMEs |
| 8. Semantics core docstrings | The "OPEN DESIGN QUESTION" nullity block retired and replaced with two typechecked derivations; `S₁ᵈ` ball-space characterization added; `def:deterministic` repointed |
| 9. Extension cluster | 17 `lem:fibers` citations annotated as a retired anchor, one uniform strategy; the Zorn footnote re-quoted at 3 sites |
| 10. Remaining anchors + typst prose | `app:valid` repointed to the live `cor:perpetuity-valid`; `cor:tm-decidability` recast as an unpublished remark; 8 typst `⊇`-directed qualifiers |
| 11. `frame` → `task frame` sweep | 15 residual sites across 7 files, enumerated by grep and recorded in the plan |
| 12. C14 widened, C15 added | C14 now scans Lean docstrings and caught 7 further stale claims; C15 added with a passing negative test |
| 13. Final gate sweep + stamps | All five gates green in one pass; two staleness stamps refreshed against verification actually performed |

## Findings Worth Keeping

**The automation's "42" was not a stale number — it was an accurate count of an incomplete
matcher.** `Automation/Tactics/Helpers.lean`'s `axiomCtors` list holds exactly 42 entries and
`Automation/ProofSearch/Core.lean`'s `matchAxiom` matches exactly the same 42; both omit the three
Layer-9 Reynolds Dedekind constructors `prior_U_gap`, `prior_S_gap` and `sep`, and
`Metalogic/Decidability/ProofExtraction.lean` inherits that coverage by delegation. Rewriting these
to "45" would have replaced a stale number with a false one. They were corrected to state coverage
honestly ("42 of the tree's 45") and to name the omission. **Closing the coverage gap is a code
change and remains open** — a Dedekind-class goal needing one of those three axioms will not be
closed by `tryAxiomMatch`.

**Widening C14 was worth more than the change that prompted it.** C14 scanned only `docs/` and
`README.md`, which is precisely why six docstrings carrying an axiom-constructor count of 42
survived a 42 → 45 change untouched. Widening it to `FormalSystem/**/*.lean` immediately surfaced
seven *further* stale claims, all of an axiom count of 21 — a figure older than the one this task
was chartered to fix, and one no gate had ever seen. Two of them were hand-maintained axiom
enumerations naming nine constructors that no longer exist.

**`nullity_identity` is derivable, and the docstring claiming otherwise was wrong.** Injectivity-
at-zero follows from the `limit` field alone (instantiate its cone witness at `y := 0`), and
reflexivity is `TaskFrame.nullity_of_serial_limit`. Both proofs were typechecked against the live
tree before being written into the docstring. The Lean frame class is therefore extensionally
exactly the paper's, and the "strictly stronger than the paper / OPEN DESIGN QUESTION" framing that
stood at `Semantics/TaskFrame.lean` is retired.

**`FrameClass.Dedekind` *is* the paper's TM⁺_c.** The live `cor:tm-completeness` reads "TM⁺_c —
Weakly complete over the dense-and-complete class", and the `{ℤ, ℝ}` / `Th(ℤ) ∩ Th(ℝ)` footnote
both READMEs relied on is commented out in the paper. The "gap worth naming" they described does
not exist.

**`app:valid` never existed.** Two sites in `Metalogic/Soundness.lean` cited it at "line 1984",
which in the live paper is an unrelated definition about operator interpretation, under a paper
title that is not this paper's. Repointed to the live `cor:perpetuity-valid`.

## Plan Deviations

- **Phase 1** — *altered*: re-resolving the four `def:frame#*` anchors "against `\bf`" would only
  move the brittleness one markup wave along, so `scripts/check-paper-definitions.sh`'s `item`
  resolver was made markup-agnostic instead. This adds that script to Phase 1's file set.
- **Phase 3** — *altered* at four of six sites: see "Findings Worth Keeping". Three additional
  sites were found by grep and are in scope per the phase's own Scope Hypothesis.
- **Phase 5** — *altered*: the residual was 24 anchors (17 rename, 7 cosmetic), not the ~25
  (20 + 5) the plan projected, and three of the 17 carried a second, non-terminological change the
  plan did not anticipate. `lem:constraint` was not on the plan's list at all.
- **Phase 6** — *altered*: the premise no longer held. `git diff README.md` was empty; the
  concurrent session's edit had been committed as `dfea0264b`, and it is a one-line change to a
  "Related Projects" description, not the -10/+2 deletion the plan describes. The
  strong-completeness precision block was intact and the citation URL fix already present. The
  reconciliation was a verification, not a repair.
- **Phase 7** — *altered*: the header paper link was a **fourth** URL variant
  (`publications/possible-worlds.pdf`, hyphenated), not a third form of the other two.
- **Phase 9** — *altered* on D12 (2 files, 3 quotations, not 3 files); *skipped* on the D18
  Extension-cluster members, which were already correct.
- **Phase 10** — *skipped* on `thm:ConservativeExtension`, already correctly annotated at every
  live site; *completed and worse than stated* on `app:valid`; the typst `⊇` half was 8 sites, not 5.
- **Phase 12** — *altered*: the prescribed source-store path does not exist in this repository.
  There is no `agent-system/` directory here; `.claude/` is deployed from a store in a different
  repository, and hand-authoring `.claude/**` is forbidden by
  `.claude/rules/source-store-deploy-boundary.md`. The context note was written to
  `docs/development/MODULE_INVARIANTS.md` and the record's own `KNOWN-ANCHORS` block instead —
  arguably where it belonged, since the convention is specific to this repository's relationship
  with one paper rather than a general Lean-language convention.
- **Phase 8** — one self-inflicted error caught and corrected mid-task: the first draft of the
  `TemporalStructures.lean` repoint asserted "there is no `app:deterministic` anchor at all",
  which is false — `\label{app:deterministic}` is live at paper line 4102. It is the determinism
  *correspondence* theorem, so the sentence's conclusion held but its premise did not; both were
  rewritten.

## Explicitly Not Done (Non-Goals, unchanged)

- The paper was **not** edited. `/home/benjamin/Philosophy/` is untouched; its single uncommitted
  edit predates this task by four days and its checksum is unchanged.
- Strong completeness for Base or Dense (D1/D2) is not proved — a genuine open problem, already
  refuted for Discrete.
- `BaseLanguage` soundness (D5) is split out into its own follow-on task.
- `F_until_equiv` / `P_since_equiv` are not retired (D24) and `nullity_identity` is not deleted
  (D25 ergonomic half) — both are owner decisions, documented in the memo, not made here.
- Closing `tryAxiomMatch`'s 3-axiom coverage gap is a code change and is left open.

## Artifacts

- `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md`
- `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/summaries/03_paper-code-docs-alignment-summary.md` (this file)
- Re-pinned `specs/paper-definitions-of-record.md` (new drift-correction sections, new
  `KNOWN-ANCHORS` block)
- `scripts/check-module-invariants.sh` (C14 widened, C15 added),
  `scripts/check-paper-definitions.sh` (markup-agnostic `item` resolver)
- `docs/development/MODULE_INVARIANTS.md` (C15 documented, C14 row updated)
