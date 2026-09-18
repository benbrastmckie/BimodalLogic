# Implementation Plan: Task #605

- **Task**: 605 - Reconcile Burgess A7a provenance and add axiom-source footnote
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None (the research's dependency on 588 is informational only; no code from it is needed)
- **Research Inputs**: specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/reports/01_burgess-a7a-provenance.md
- **Artifacts**: plans/01_burgess-a7a-provenance.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true (Lean files touched, but only comments and docstrings)

## Overview

The research settled the contradiction. The paper is right: CN (`linear_until`) is Burgess 1982
axiom A7a, and it is sound under Burgess's own strict/open-guard semantics. `linear_until_valid`
already proves this. The NOTE in `FormalSystem/ProofSystem/Axioms.lean` blames A7a, but the formula
it found unsound came from an earlier constructor, `linear_until_a7a`. That constructor copied
Burgess's `U(event, guard)` argument positions into the guard-first `untl` without swapping them,
so Burgess's fixed guard became a fixed event. This plan makes documentation edits only, in four
places:

- replace the wrong NOTE;
- add Burgess/Xu source tags to the attributed constructors' docstrings, and add a module-level
  "Axiom Sources" section;
- disambiguate the three Chronicle mentions of Burgess 1984's (different) A7a;
- close the "Open opportunity" paragraph in `docs/reference/paper-definitions-of-record.md`, add
  a paper-footnote errata list, and add a source column to `docs/reference/axiom-reference.md`.

No statement, proof or axiom changes. Done means `lake build` is green, the task-reference lint
and paper-definitions checks pass, and every quoted Burgess formula matches his §1.3 printing.

### Research Integration

- Verified attribution map (report § External Resources): TN = TG (G half), TS = B82 §1.6 "No
  Last Element", UC = A1a/Xu (1), UG = A2a/Xu (1), SU = A3a/Xu (3) (already present), UF =
  A5a/Xu (7), UI = A6a/Xu (9), CN = A7a/Xu (10)/(11), TL = Burgess 1984 §0.3 A2a, UE = derivable.
  Past mirrors use the `b` variants (A1b, A2b, A3b, A5b, A6b, A7b) and Xu (2)/(4)/(8)/(11).
- The corrected NOTE text is Recommendation 1 of the report. The `enrichment_until` docstring is
  the pattern to copy: an `(Burgess A3a, Xu axiom (3))` tag, then a `Burgess:` line in Burgess's
  own order, then a guard-first line.
- The paper footnote has two errors: UE follows from UG with χ = ⊤, not from UC with ψ = ⊤; and
  Xu has no class `𝖵₃`, so TL should be cited to Burgess 1984 §0.3 A2a, with Xu (13) as the
  nearest Xu formula. **User decision (resolved by the orchestrator):** record these errata in
  `docs/reference/paper-definitions-of-record.md` only. Do not edit the external paper source.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation was requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- Replace the wrong `linear_until` NOTE in `Axioms.lean` with a corrected provenance note that
  explains the transcription error.
- Tag the docstrings of the attributed constructor pairs with their Burgess/Xu sources:
  `serial_future`, `right_mono_*`, `left_mono_*`, `self_accum_*`, `absorb_*`, `linear_*`,
  `temp_linearity`, `until_F`.
- Add a module-docstring `## Axiom Sources` subsection summarising the map (the paper's
  axiom-source footnote, reconciled). Correct the header sentence that says "reflexive
  semantics", which contradicts the file's own "irreflexive" statement.
- In the three Chronicle files, disambiguate Burgess 1984 A7a (Dedekind completeness) from
  Burgess 1982 A7a.
- Close the "Open opportunity" paragraph in `paper-definitions-of-record.md` and record the
  paper-side errata there.
- Add a "Burgess / Xu source" column to the Paper Key Correspondence table in
  `axiom-reference.md`.

**Non-Goals**:
- Any change to an axiom statement, proof, constructor name, or soundness lemma.
- Editing the external paper source (`possible_worlds.tex`), or the verbatim pinned `def:BX`
  footnote block quoted in the record file.
- Editing `FormalSystem/Boneyard/**` (it is an unbuilt archive, and the standing policy is to
  leave it alone).
- Quoting Xu (1)'s printed text. The transcription has an OCR slip, so cite the formula number
  only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Argument-order swap when writing a `Burgess:` line (the same error that caused the bad NOTE) | H | M | Quote Burgess exactly as printed in §1.3, in `U(event, guard)` order. Keep the guard-first rendering on a separate line, as `enrichment_until` does. Before closing Phase 1, check every quoted line against the report's Step Map, symbol by symbol. |
| Malformed doc-comment breaks elaboration | M | L | Run `lake build FormalSystem.ProofSystem.Axioms` after the edits, and build each Chronicle module. |
| Task numbers or commit hashes leak into deliverables | M | M | Name the removed constructor only by its identifier. Run `.claude/scripts/check-task-references.sh` on the changed files. |
| The record-file edit disturbs a pinned or checked block | M | L | Leave the quoted `def:BX` block (around line 1330) byte-identical, and run `scripts/check-paper-definitions.sh`. |
| The Xu "defines linear frames" wording is overstated | L | M | Use the report's precise wording: (10) is in Σ₄, which is complete for 𝒞₄ (linear frames). By itself, (10) defines the condition (10)*. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Their file sets are disjoint.

### Phase 1: Axioms.lean provenance note, docstring tags, Axiom Sources section [NOT STARTED]

**Goal**: Make `FormalSystem/ProofSystem/Axioms.lean` carry the reconciled Burgess/Xu provenance.

**Tasks**:
- [ ] Replace the NOTE block after `linear_since` (it begins "NOTE: BX7a/BX7a' ... removed --
      unsound under open guard") with the corrected note from the report's Recommendation 1. The
      new note must say that `linear_until`/`linear_since` ARE Burgess 1982 A7a/A7b (Xu (10)/(11)),
      and that A7a's disjuncts share a fixed GUARD `q∧s`. It must also say the removed
      `linear_until_a7a`/`linear_since_a7a` pair transcribed A7a without swapping to guard-first
      order, which produced an unsound fixed-event variant, and that Burgess's 1982 §1.2 semantics
      is the same strict/open-guard semantics used here.
- [ ] `linear_until` docstring: add "(Burgess 1982 A7a, Xu 1988 (10))" and the line
      `Burgess: U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`, and point to
      `linear_until_valid` for soundness. `linear_since`: "(Burgess A7b, Xu (11))".
- [ ] `right_mono_until` "(Burgess A1a, Xu (1))" / `right_mono_since` "(Burgess A1b, Xu (2))".
- [ ] `left_mono_until_G` "(Burgess A2a, Xu (1))" / `left_mono_since_H` "(Burgess A2b, Xu (2))".
- [ ] `self_accum_until/since` "(Burgess A5a/A5b, Xu (7)/(8))"; `absorb_until` "(Burgess A6a,
      Xu (9))"; `absorb_since` "(Burgess A6b)".
- [ ] `serial_future` "(Burgess 1982 §1.6, No Last Element)"; `temp_linearity` "(Burgess 1984
      §0.3 axiom A2a)"; `until_F` "(the paper's UE; derivable from UG with χ = ⊤ plus TN)".
- [ ] Module docstring: add a `## Axiom Sources` subsection. It should give a compact table
      mapping each paper key to the Lean constructor, the Burgess number (1982 or 1984, labeled
      explicitly) and the Xu number. It should note that Burgess A4a/A4b is the one omitted 1982
      pair, and that TC/UT/NP/NF/NA/NB are original.
- [ ] Correct the header "Under reflexive semantics ... (G/H use ≤/≥, U/S use ≤/≥ ...)" sentence
      in `## Axiom System` so it agrees with the file's irreflexive/open-guard statement.
- [ ] Check every quoted Burgess formula against report Step Map items 2-3, symbol by symbol.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 8 attributed constructor pairs plus `serial_future`, `temp_linearity`, and
`until_F` need tags. `enrichment_*` is already tagged. Confirm the pairs by grepping the
`| <name>` constructor lines before editing.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - docstring and comment edits only

**Verification**:
- `lake build FormalSystem.ProofSystem.Axioms` is green.
- `git diff` shows changes only inside `/-- -/`, `/-! -/`, or `--` comment regions. No
  constructor signature line changes.
- `grep -n "closed-guard semantics" FormalSystem/ProofSystem/Axioms.lean` returns nothing.

---

### Phase 2: Disambiguate Burgess 1984 A7a in Chronicle files [NOT STARTED]

**Goal**: Stop the three Burgess 1984 A7a citations from being read as the 1982 Until-linearity
axiom.

**Tasks**:
- [ ] At the first A7a mention in each file, append "(Burgess 1984's Dedekind-completeness
      axiom `Fp ∧ FG¬p → F(HFp ∧ G¬p)`, not the 1982 Until-linearity axiom of the same number)",
      or an equivalent shorter parenthetical.

**Timing**: 20 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: exactly three files carry the ambiguous mention, per
`grep -rn "A7a" FormalSystem/Metalogic`. Re-run the grep to confirm, and exclude Boneyard.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean`

**Verification**:
- Build each of the three modules (`lake build <Module>`) green.
- The diff touches comment/docstring text only.

---

### Phase 3: Close the record-file opportunity; add the source column [NOT STARTED]

**Goal**: Record the reconciliation and the paper errata in the reference docs.

**Tasks**:
- [ ] `docs/reference/paper-definitions-of-record.md`: rewrite the "Open opportunity: `def:BX`'s
      Burgess/Xu provenance footnote" paragraph as a closed record. It should give the verdict
      (the paper is correct: CN is A7a; the tree NOTE was a transcription artifact, now
      corrected), point to the `Axioms.lean` `## Axiom Sources` section, and state Xu's result
      precisely (Σ₄ / 𝒞₄, (10) defines (10)*).
- [ ] Add a "Paper footnote errata (outside this repository)" list with two items: (i) UE follows
      from UG with χ = ⊤ (plus TN), not from UC with ψ = ⊤; (ii) Xu has no class `𝖵₃`, so TL is
      Burgess 1984 §0.3 A2a verbatim, and its nearest Xu formula is (13) (§4 Thm 4.3). State
      that the paper source is not edited here.
- [ ] Leave the verbatim quoted `def:BX` footnote block byte-identical.
- [ ] `docs/reference/axiom-reference.md` § Paper Key Correspondence: add a "Burgess / Xu
      source" column populated from the verified map. Label Burgess 1982 and Burgess 1984
      explicitly. Mark TC/UT/NP/NF/NA/NB as "original"; TR has no source listed.

**Timing**: 40 minutes

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md`
- `docs/reference/axiom-reference.md`

**Verification**:
- Read the diff: the quoted block is unchanged and every table row has the new column.
- `bash scripts/check-paper-definitions.sh` passes.

---

### Phase 4: Final gate [NOT STARTED]

**Goal**: Run the full gate set over the combined change.

**Tasks**:
- [ ] `lake build` (full) is green, with no new warnings in touched modules.
- [ ] `bash .claude/scripts/check-task-references.sh` is clean on all changed files.
- [ ] `bash scripts/check-paper-definitions.sh` and `bash scripts/check-module-invariants.sh`
      pass.
- [ ] `git diff --stat` lists only the six planned files.

**Timing**: 30 minutes

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Files to modify**:
- none (verification only; fix-ups go back to the owning phase's files)

**Verification**:
- All gates above pass.

## Lean Challenge Statements (not applicable: no statements added or changed)

This task changes only comments and docstrings. It adds no declaration and changes no statement,
so there is nothing to pin. The heading suffix is deliberate: `lean-challenge-snapshot.sh`
recognizes only the exact heading `## Lean Challenge Statements`, so it treats this section as
absent. The Goals list names existing constructors only to say whose documentation is edited.

## Testing & Validation

- [ ] `lake build` is green (full).
- [ ] Every quoted Burgess formula matches Burgess 1982 §1.3 in `U(event, guard)` order.
- [ ] No constructor signature, proof, or statement changed (diff audit).
- [ ] Task-reference lint, paper-definitions check, and module-invariants check pass.

## Artifacts & Outputs

- `FormalSystem/ProofSystem/Axioms.lean` (provenance NOTE, docstring tags, Axiom Sources section)
- Three Chronicle files (A7a disambiguation)
- `docs/reference/paper-definitions-of-record.md` (closed record plus errata)
- `docs/reference/axiom-reference.md` (source column)
- `specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/summaries/01_burgess-a7a-provenance-summary.md`

## Rollback/Contingency

All edits are text-only and committed per phase, so `git revert` of a phase commit undoes it
cleanly. If a docstring edit breaks elaboration, fix the comment delimiter in place and do not
revert the whole phase. A whole-tree rollback of uncommitted work follows
`context/contracts/recovery.md`'s rollback rung.
