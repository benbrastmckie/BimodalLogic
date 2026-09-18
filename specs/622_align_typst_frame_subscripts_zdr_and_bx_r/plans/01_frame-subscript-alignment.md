# Implementation Plan: Task #622

- **Task**: 622 - Align typst frame-class subscripts (z/d/r) and BX_r with the paper
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None (task 607's TM/TM⁻ resync already landed)
- **Research Inputs**: specs/622_align_typst_frame_subscripts_zdr_and_bx_r/reports/01_frame-subscript-alignment.md
- **Artifacts**: plans/01_frame-subscript-alignment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Two typst files still use the paper's retired `f/d/c` frame-class subscripts. This plan moves
them to the paper's current `z/d/r` names (`def:BX-z`, `def:BX-d`, `def:BX-r`, as recorded in
`docs/reference/paper-definitions-of-record.md`). The `f -> z` change is a pure relabel. The
`c -> r` change is a real redefinition: `BX_r` now extends `BX_d` (DN, NN, Prior-U, Sep), so its
soundness class is R-time (`Dur = RR`) only, which matches Lean's `FrameClass.RTime`
(`Dense <= RTime`, `IsRTime := IsDense ∧ IsComplete`). The plan also fixes the swapped `#leansrc`
citations between the section 2 "Soundness" theorem and the section 5 "Algebraic soundness"
proposition, rewrites the "Naming provenance" remark, drops the footnote asking whether CO alone
gives the same logic, and updates the decidability chapter's one DF/CO sentence. All edits are
typst prose. No Lean changes are needed.

### Research Integration

- The paper side is settled. The source-of-record file already holds the live
  `def:BX-z/-d/-r`/`def:TMplus` text, so no research questions remain open.
- The site inventory is complete for both files. I re-checked it during planning with
  `grep -nE '"BX"_[fdc]|op\("TM"\)_[fdc]'`. `p2-decidability-practice.typ` has exactly one site, at
  line 27. `typst/chapters/03-proof-theory.typ:362` is a `//` comment that already uses z/d/r, so it
  needs no change.
- There is an existing inconsistency: line ~1295 says "`TM_c`-algebra when `Dur in {ZZ, RR}`" but
  line ~1478 says a `TM_c`-algebra's `D_k` is "elementarily equivalent to `RR`". Redefining the
  class as `TM_r` (R-time only) resolves it.
- The citation swap is confirmed against the Lean source. `Metalogic.Soundness.soundness*` is typed
  over `Formula`, the TM level. `Metalogic.Conservativity.MinusLanguageSoundness.minus_soundness*`
  is typed over `MinusFormula`, the TM⁻ level. Planning confirmed that the §2 theorem (TM⁻) cites
  the `soundness*` family and the §5 proposition (TM-algebras) cites the `minus_soundness*` family,
  so the two are swapped.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted. No roadmap_path was provided for this dispatch.

## Goals & Non-Goals

**Goals**:
- Rename `"BX"_f` -> `"BX"_z` and `op("TM")_f` -> `op("TM")_z` at every non-minus site.
- Rename `"BX"_c`/`op("TM")_c` -> `"BX"_r`/`op("TM")_r`, and redefine the system as an extension
  of `"BX"_d`/`op("TM")_d`. Recheck every downstream claim against R-time semantics.
- Fix the §2/§5 `#leansrc` citation swap.
- Rewrite the "Naming provenance" remark so it describes the document's new state. Drop the
  CO-alone footnote.
- Update `p2-decidability-practice.typ` line 27.
- Pass all three gates (typst compile for both documents, `typst-sync-check.sh`,
  `check-paper-definitions.sh`).

**Non-Goals**:
- Renaming the TM⁻ family's own subscripts (`op("TM")^-_f`, `_d`, `_c`, `_(d c)`). The document
  states that TM⁻ "has no paper counterpart", and its `f`/`c` letters name DF- and CO-axiomatized
  systems, not UZ+Z1 or PU+SEP ones. The dispatch limits the rename to TM⁻ variants "where they
  track the paper", and these do not track it. On the mixed lines (~708 and ~1053–1054), only the
  non-minus tokens change.
- Any edit to `docs/reference/paper-definitions-of-record.md`, the Lean tree, `BimodalReference.typ`,
  or `p2-frame-classes.typ`. All four have zero affected sites.
- Rederiving the DF/CO non-theorem arguments. They still hold unchanged under the narrower `TM_r`.

## Decisions

- **Drop the CO-alone footnote, don't move it.** The conjecture only ever appeared in the retired,
  already-commented-out `def:TMplus-c` LaTeX block. It was never live paper text, and the live
  `def:BX-r` has no such footnote. Keeping it would credit the paper with an open question the
  paper does not pose.
- **Keep a short "Naming provenance" remark rather than deleting it.** This follows the document's
  practice of brief provenance notes. It will record that the section now uses the paper's current
  z/d/r names, and that `c -> r` was a substantive redefinition, not a relabel. The stale "still
  uses the old subscripts" and "not transcribed here" caveats will be removed.
- **State `TM_r` as "extends `TM_d` with Prior-U and Sep"** in the TM-level sentence, the summary
  table, and the algebra definition. This mirrors `def:TMplus` and keeps the dependency on `BX_d`
  visible, instead of flattening the axioms into a four-item list.
- **Leave the CO-derivation clause alone ("from Prior-U and the base BX axioms").** Per `def:BX-r`,
  CO's derivation uses only PU and the BX axioms. Only the system name in that clause changes.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `_c -> _r` relabelled without narrowing its content leaves a new self-contradiction (the label says R-time but the text says `{ZZ, RR}`) | H | M | Phase 2 treats the redefinition as one coherent edit set. The closing grep checks both that no `_c` token remains and that no `{ZZ, RR}` claim is attached to `TM_r` |
| Renaming TM⁻ tokens by accident on mixed lines (~708, ~1053) | M | M | Use targeted edits, not a global sed. After Phase 1, a grep confirms the count of `op("TM")^-_[fc]` tokens is unchanged |
| The swapped `#leansrc` targets fail `typst-sync-check.sh` name resolution | M | L | Both symbol families exist today, so the fix only swaps valid argument pairs. The sync check runs right after Phase 1 |
| Line numbers drift after the first edit | L | H | Every phase finds its sites by re-grepping patterns, not by fixed line numbers |
| `check-paper-definitions.sh` reports paper drift unrelated to this task | L | L | Record it in the summary as an upstream observation. It is not a defect of these edits |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

The phases run in sequence because Phases 1–3 all edit `typst/FormalFoundations.typ`.

### Phase 1: Pure relabels, decidability chapter, and citation swap [NOT STARTED]

**Goal**: Make every change that needs no semantic judgment: the `f -> z` relabels, the one-line
decidability-chapter update, and the §2/§5 `#leansrc` swap.

**Tasks**:
- [ ] Record the baseline token count: `grep -c 'op("TM")^-_' typst/FormalFoundations.typ`. It must
      be unchanged at the end of this phase.
- [ ] In `typst/FormalFoundations.typ`, change `"BX"_f` -> `"BX"_z` inside the `#definition($"BX"_f$)`
      block, including the definition title. Leave the `"BX"_f` mentions inside the Naming provenance
      remark for Phase 3.
- [ ] Change `op("TM")_f` -> `op("TM")_z` at the non-minus sites: the TM-level "Similarly" sentence,
      the summary-table row, the "paper attributes them to" sentence (~708), the remark at ~1053–1054,
      the TM-algebra definition (~1243), the Algebraic soundness proposition (~1294), the Per-class
      remark (~1477), and the representation remark (~1563).
- [ ] In `typst/chapters/p2-decidability-practice.typ` line 27, change `op("TM")_c` -> `op("TM")_r`
      and `op("TM")_f` -> `op("TM")_z`. Recheck the wording: "sound over a class containing a dense
      or `RR` member" still holds for the narrowed `TM_r`, and the `ZZ times_lex ZZ` witness for
      `TM_z` is unaffected.
- [ ] Citation swap. Retarget the §2 "Soundness" theorem's four `#leansrc` lines to
      `Metalogic.Conservativity.MinusLanguageSoundness` with `minus_soundness`,
      `minus_soundness_dense`, `minus_soundness_ztime`, and `minus_soundness_rtime`. Retarget the §5
      "Algebraic soundness" proposition's four `#leansrc` lines to `Metalogic.Soundness` with
      `soundness`, `soundness_dense`, `soundness_ztime`, and `soundness_rtime`.
- [ ] Run `bash scripts/typst-sync-check.sh` and `typst compile` on both documents.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Research found about 9 `_f` sites in `FormalFoundations.typ` and 1 line in
`p2-decidability-practice.typ`, and planning re-verified that inventory. Confirm it at
implementation time with `grep -nE '"BX"_f|op\("TM"\)_f' typst/FormalFoundations.typ typst/chapters/*.typ`.
After this phase, the only hits should be in the Naming provenance remark.

**Files to modify**:
- `typst/FormalFoundations.typ`: f->z relabels and the §2/§5 `#leansrc` swap
- `typst/chapters/p2-decidability-practice.typ`: line 27 subscripts

**Verification**:
- The grep for `_f` finds hits only inside the Naming provenance remark.
- The `op("TM")^-_` token count matches the baseline.
- The §2 theorem cites `minus_soundness*` and the §5 proposition cites `soundness*`.
- `typst-sync-check.sh` passes and both documents compile.

---

### Phase 2: Redefine BX_c/TM_c as BX_r/TM_r extending BX_d/TM_d [NOT STARTED]

**Goal**: Replace the old complete-order system with the paper's dense-and-complete `BX_r`/`TM_r`,
and bring every downstream claim into line with R-time (`Dur = RR`) semantics.

**Tasks**:
- [ ] Update the `#definition($"BX"_c$)` block:
  - Rename it to `"BX"_r` everywhere in the block.
  - Change the title "*Complete Burgess--Xu Tense Logic*" to "*Dense and Complete Burgess--Xu Tense Logic*".
  - Change "extends BX to include all instances of" to "extends $"BX"_d$ to include all instances of".
  - Change "derived theorem of `"BX"_c`" to "derived theorem of `"BX"_r`", keeping the clause "from
    Prior-U and the base BX axioms".
  - Leave the `K^+`/`K^-` definitions and the Prior-U/Sep statements verbatim.
- [ ] Rewrite the TM-level "Similarly" sentence as "`op("TM")_z`, `op("TM")_d`, and `op("TM")_r`
      extend `op("TM")` with the additional axioms that distinguish `"BX"_z`, `"BX"_d`, and `"BX"_r`
      respectively: `op("TM")_z` adds UZ and Z1, `op("TM")_d` adds DN and NN, and `op("TM")_r`
      extends `op("TM")_d` with Prior-U and Sep." Remove the CO-alone `#footnote[...]` from this
      sentence.
- [ ] Change the summary-table row to `[$op("TM")_r$], [Prior-U, Sep over $op("TM")_d$ (so DN, NN,
      Prior-U, Sep); CO is a derived theorem, not a further axiom]`. Wording may vary, but the row
      must show the dependency on `TM_d`. Check whether the table caption or intro says "extensions
      of TM" in a way that implies all three are flat extensions, and adjust it if so.
- [ ] In the TM-algebra definition, change "a `op("TM")_c`-algebra additionally satisfies Prior-U and
      Sep" to "a `op("TM")_r`-algebra is a `op("TM")_d`-algebra that additionally satisfies Prior-U
      and Sep". The claim "All four classes are varieties" stays true because the classes are still
      defined by equations.
- [ ] In the Algebraic soundness proposition, change "a `op("TM")_c`-algebra when `Dur in {ZZ, RR}`"
      to "a `op("TM")_r`-algebra when `Dur` is dense and Dedekind complete (`Dur = RR`)". Check this
      against Lean: `soundness_rtime` requires the RTime class (`IsDense ∧ IsComplete`). Confirm by
      reading its signature in `FormalSystem/Metalogic/Soundness.lean`.
- [ ] In the Per-class remark (~1478), relabel `_c -> _r` only. Its content ("elementarily
      equivalent to `RR`") is already right for R-time.
- [ ] In the representation remark (~1565), relabel `_c -> _r` only (Reynolds 1992, `RR`-flows).
- [ ] On the mixed lines ~708 and ~1053–1054, relabel `op("TM")_c -> op("TM")_r` only. Leave the TM⁻
      tokens alone.
- [ ] Recheck every other claim that cites the old complete class. Grep `FormalFoundations.typ` for
      `Dedekind`, `complete`, `{ZZ, RR}`, `RTime`, `rtime`, and `Reynolds`. For each hit that
      concerns the non-minus TM/BX family, confirm it is consistent with an R-time-only class; any
      claim that still admits `ZZ` must be narrowed or corrected. TM⁻_c claims (the CO-axiomatized
      TM⁻ extension) are out of scope because that system's semantics do not change.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch (every `_c -> _r` site encodes the same narrowing to R-time; a
partial commit would leave the document self-contradictory)

**Scope Hypothesis**: Research and planning found about 8 non-minus `_c` sites in
`FormalFoundations.typ`, plus those inside the Naming provenance remark. Confirm with
`grep -nE '"BX"_c|op\("TM"\)_c' typst/FormalFoundations.typ`. After this phase, only hits inside the
Naming provenance remark should remain.

**Files to modify**:
- `typst/FormalFoundations.typ`: the BX_r definition, the TM-level sentence and its footnote, the
  summary table, the TM-algebra definition, the Algebraic soundness proposition, the Per-class and
  representation remarks, and the mixed lines

**Verification**:
- `grep -nE '"BX"_c|op\("TM"\)_c'` finds hits only inside the Naming provenance remark.
- `grep -n 'ZZ, RR'` finds no claim attached to `TM_r`/`BX_r`.
- The Algebraic soundness proposition (`Dur = RR`) and the Per-class remark (`D_k` equivalent to
  `RR`) now agree.
- `typst compile typst/FormalFoundations.typ` succeeds, and `typst-sync-check.sh` passes.

---

### Phase 3: Rewrite the Naming provenance remark, final sweep, and full gates [NOT STARTED]

**Goal**: Make the provenance remark describe the document as it now stands, confirm no stale
subscript remains, and run the full gate set.

**Tasks**:
- [ ] Rewrite the `#remark[*Naming provenance.* ...]` block that follows the `BX_z` definition as a
      short historical note. It should cover these points:
  - The paper's 2026-09 revision merged `BL^+` into BL and dropped the `+` superscript. This
    document's `#BL`/`op("TM")` macros follow that change, in line with `def:TMplus`.
  - The extensions formerly named `BX_f`/`BX_d`/`BX_c` (anchors `def:TMplus-f/-d/-c`, now
    recorded as `DANGLING`) are now `BX_z`/`BX_d`/`BX_r` (`def:BX-z`, `def:BX-d`, `def:BX-r`; see
    `docs/reference/paper-definitions-of-record.md`). This section uses the current names.
  - `f -> z` was a relabel. `c -> r` was a redefinition: `BX_r` extends `BX_d`, so its class is
    R-time rather than all Dedekind-complete orders.
  - Optionally, one remaining presentational difference: the live paper definitions cite the
    Extensions section for their axioms, while this section displays them. Keep this only if it is
    still true.

  Remove the "subscripts ... are nonetheless still the paper's *old* ones" and "*not* transcribed
  here" sentences.
- [ ] Do not mention task numbers anywhere in the typst deliverables. They must be clean under
      `no-task-references-in-deliverables.md`.
- [ ] Final sweep: `grep -nE '"BX"_[fc]|op\("TM"\)_[fc]' typst/FormalFoundations.typ typst/chapters/*.typ typst/*.typ`
      may only return hits inside the provenance remark's historical mention of the old names. Any
      `op("TM")^-_` tokens must match the Phase 1 baseline count.
- [ ] Run the gates in order:
  - `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf`
  - `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf`, the compiled book,
    which `#include`s the decidability chapter
  - `bash scripts/typst-sync-check.sh`
  - `bash scripts/check-paper-definitions.sh`
- [ ] Run `bash .claude/scripts/check-task-references.sh` (or the equivalent task-reference lint) on
      the two edited files, if it is available.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ`: the Naming provenance remark

**Verification**:
- All four gate commands exit 0. `check-paper-definitions.sh` may neutral-skip if the external paper
  is unreachable; record that outcome.
- The final sweep grep is clean apart from the historical mentions.
- The provenance remark no longer says the document uses the old subscripts.

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` succeeds
- [ ] `typst compile typst/BimodalReference.typ` succeeds
- [ ] `bash scripts/typst-sync-check.sh` passes, including resolution of the swapped `#leansrc` targets
- [ ] `bash scripts/check-paper-definitions.sh` passes (or neutral-skips)
- [ ] No non-minus `_f`/`_c` frame-class subscripts remain outside the historical provenance note
- [ ] The count of TM⁻ subscript tokens is unchanged from the baseline
- [ ] The Algebraic soundness proposition's `TM_r` class agrees with the Per-class remark (R-time only)

## Artifacts & Outputs

- Modified `typst/FormalFoundations.typ`
- Modified `typst/chapters/p2-decidability-practice.typ`
- `specs/622_align_typst_frame_subscripts_zdr_and_bx_r/summaries/01_frame-subscript-alignment-summary.md`

## Rollback/Contingency

All changes are prose edits to two tracked typst files. Revert them with
`git checkout -- typst/FormalFoundations.typ typst/chapters/p2-decidability-practice.typ`, or
revert the phase commits. If a gate fails because of something outside these edits (for example,
paper drift reported by `check-paper-definitions.sh`), record it in the summary and do not widen
the scope.
