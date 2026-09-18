# Research Report: Task #607

- **Task**: 607 - Resync typst/FormalFoundations.typ with the current Lean tree and paper vocabulary
- **Started**: 2026-09-18T00:00:00Z
- **Completed**: 2026-09-18T00:00:00Z
- **Effort**: ~2-3 hours implementation (moderate: mostly text edits, one open structural question)
- **Dependencies**: 584 (done; deferred this exact follow-up)
- **Sources/Inputs**: `typst/FormalFoundations.typ` (full read, 1577 lines), `docs/reference/paper-definitions-of-record.md`, `docs/reference/axiom-reference.md`, `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/ProofSystem/Derivation.lean`, `FormalSystem/ProofSystem/DerivedAxioms.lean`, `specs/archive/584_reconcile_lean_tree_with_paper_vocabulary/{summaries,reports}/*`, `specs/archive/584_.../rename-map.tsv`
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- `typst/FormalFoundations.typ` has **no leftover renamed identifiers** (`swapTemporal`,
  `temporal_duality`, `TemporalDuality`, `temporalDuality` do not appear anywhere in the file) and
  its Some/All Past/Future operator labels already match `Syntax/Formula.lean`. Task 584's rename
  work is fully absorbed here already.
- The document **does** carry two classes of stale content task 584 explicitly deferred
  ("Resync `typst/FormalFoundations.typ` in full"):
  1. **A wrong axiom-count remark** (lines 1034-1045) that survived, or was introduced by, 584's
     partial fix: it claims the development states "all twenty-two [Since/Until axioms]
     explicitly, one pair per paper axiom" and that uniformity is "five constructors, NP's past
     mirror being explicit." Both counts are backwards against the current
     `FormalSystem/ProofSystem/Axioms.lean`: the BX temporal layer has **11** future-direction
     constructors only (past mirrors are TR-*derived theorems*, not explicit constructors), and
     the uniformity layer has exactly **4** constructors (NP, NF, NA, NB, one per paper key), with
     only **NP's** past mirror TR-derived (NF/NA/NB are each already stated in their own single
     direction as primitive, non-mirror axioms).
  2. **Two mislabeled axiom keys, used pervasively:** the document's `TB` should be the paper's
     current key `TS` (seriality), and `TA` should be `TC` (connectedness). These are not "old
     subscripts" covered by the document's own Naming Provenance disclaimer (that disclaimer only
     covers the `f/d/c` -> `z/d/r` subscript rename); `TB`/`TA` are plain wrong against
     `def:BX`'s live text and against `docs/reference/axiom-reference.md`'s Paper Key
     Correspondence table.
- A larger, **structural** finding, not previously flagged anywhere in the tree: the document's
  `definition("TM")` block (lines 576-618), which axiomatizes "TM, ... for `#BL`" directly with
  primitive `TK`, `T4`, `TB`, `TA`, `TL` (a primitive-tense-operator system, no Until/Since), has
  **no current paper counterpart at all**. Per
  `docs/reference/paper-definitions-of-record.md`'s "Language correspondence (2026-09-08)"
  section, the paper collapsed `BL^+` into `BL` and now has exactly one primitive-tense-operator-free
  system; the H/G-primitive fragment (what the repository elsewhere calls `L⁻`/`TM⁻`,
  i.e. `FormalSystem/Syntax/MinusLanguage/`) was **withdrawn from the paper** and has "no
  counterpart" — task 584 already de-attributed it on the Lean side
  (`MinusLanguage/Axioms.lean`'s docstring) but this typst document still presents that same
  system as a direct, unqualified paper transcription named bare `TM`. Compounding this, the
  document uses the **opposite** superscript convention from the current paper: it uses `TM`
  (no `+`) for the (non-paper) BL-level system and `TM^+` for the BL+-level system, whereas the
  current paper's single "TM" (`def:TMplus`, labelled `TMplus` for historical reasons but reads
  `TM`) *is* what this document calls `TM^+`.
- Recommended fix shape (for the plan phase, not attempted here): (a) fix the two count claims at
  lines 1034-1045 against the actual Lean numbers; (b) do a mechanical `TB`->`TS`, `TA`->`TC` swap
  everywhere in the file (7 sites); (c) resolve the `TM` vs `TM^+` naming collision — either by
  relabelling the `#BL`-level block as a clearly-marked repository-only construct (mirroring the
  Lean-side `MinusLanguage`/`TM⁻` de-attribution) with a provenance remark like the existing BX_f/d/c
  one, or by dropping/superseding the `TM`(BL) section and renaming the `TM^+` family to plain
  `TM` throughout to match `def:TMplus`. This last choice is large (the whole document's
  `op("TM")^+`, `op("TM")^+_f/d/c` notation and prose would need renaming) and is a genuine design
  decision the plan phase should make explicitly, not something research should decide
  unilaterally.

## Context & Scope

Task 607 asks to "audit every claim about the proof system, axiom counts, the TR (time
reflection) rule, renamed identifiers (`reflectTime`, `time_reflection`, `TimeReflection`), and
the Some/All Past/Future labels, and correct stale statements" in
`typst/FormalFoundations.typ` (1577 lines), following on from task 584 ("Reconcile the Lean tree
with the paper's renamed vocabulary"), which fixed one specific wrong remark (a claim that the
development "has no TR rule" and that uniformity counts "do not even match") but explicitly
deferred ("Follow-ups: Resync `typst/FormalFoundations.typ` in full (it still uses TB/TA,
`TM^+_f`, etc.)") a full pass over this document.

This is a research-only dispatch; no edits were made. The scope below is what the plan/implement
phases need to fix, organized by the four audit categories the dispatch names.

## Findings

### Renamed identifiers (`reflectTime`, `time_reflection`, `TimeReflection`) — clean

`grep -n -iE "swapTemporal|swap_temporal|temporal_duality|TemporalDuality|temporalDuality"
typst/FormalFoundations.typ` returns nothing. The document never names Lean identifiers by their
old pre-584 names. Where it names the rule at all, it correctly says `DerivationTree.time_reflection`
(line ~1040) and the abbreviation `TR`. No action needed here.

### The TR rule itself — mostly accurate, one count claim wrong

The document already states TR correctly as a metarule ("if `⊢φ` then `⊢φ⟨S|U⟩`" for BX, and the
`⟨P|F⟩`-swap form for TM) and cites it by its live Lean name. The one defect is in the "Machine-
Checked Status" remark (`typst/FormalFoundations.typ:1034-1045`):

> "the paper states eleven primary Since/Until axioms and derives their past mirrors by the rule
> TR, while the development states all twenty-two explicitly, one pair per paper axiom, and also
> has TR as a rule (`DerivationTree.time_reflection`). The uniformity layer reconciles too: the
> paper's four axioms appear as five constructors, NP's past mirror being explicit."

Cross-checked against the current, authoritative sources:

- `FormalSystem/ProofSystem/Axioms.lean`'s module docstring: "**BX Temporal** (11, future
  direction only; the past mirrors are TR-derived)" and "Total: 29 axiom constructors (19 core +
  4 uniformity + 1 prior + 1 Z1 + 2 density + 2 Reynolds Dedekind)".
- `docs/reference/axiom-reference.md`: "`inductive Axiom` now has exactly the paper's 29 schemata
  ... with TL, CN and TS stated verbatim ... Every former surplus constructor -- the TR mirrors,
  modal 4 and B, and the past forms of UZ and PU -- is a machine-checked derived theorem in
  `FormalSystem.ProofSystem.DerivedAxioms`" and its own "Derived schemata" table lists all 12
  TR-derived past mirrors (`serialPast`, `leftMonoSinceH`, `rightMonoSince`, `connectPast`,
  `enrichmentSince`, `selfAccumSince`, `absorbSince`, `sinceP`, `pSinceEquiv`, `discreteSymmBwd`,
  `priorSZ`, `priorSGap`) plus derived-form variants.
- `docs/reference/paper-definitions-of-record.md`: "**Constructor naming audit: closed.** ...
  `inductive Axiom` now has exactly the paper's 29 schemata ... The same closure corrected
  `typst/FormalFoundations.typ`'s remark that the development 'has no TR rule' and that the
  uniformity layer 'does not even match in count'. Both claims were wrong." This is task 584's
  fix, referenced by this task's description. **The remark it describes as fixed is not the
  current remark's content** — the corrected remark at lines 1034-1045 still asserts wrong counts
  (22 and 5), just in the opposite direction from the pre-584 wrong claims (previously: "no TR
  rule" / "counts don't match"; now: TR exists, but with fabricated matching counts of 22 and 5).

So the correct statement is: BX temporal layer = **11** constructors (future direction only, all
past mirrors TR-derived, not explicit — not "twenty-two explicitly, one pair per paper axiom").
Uniformity layer = **4** constructors (NP, NF, NA, NB — a literal 1-1 match with the paper's 4
uniformity keys, not "five constructors"), and of those four, **only NP's** past mirror is
TR-derived (`discreteSymmBwd`); NF, NA, and NB are each already single-direction primitives in
their own right (the Axioms.lean docstring is explicit that `discrete_propagate_bwd` "is the
paper's NA itself ... **not** the time-reflection mirror of NF"). The typst remark's claim "NP's
past mirror being explicit" also inverts this: NP's past mirror is exactly the one that is *not*
explicit (it is TR-derived).

### Axiom counts elsewhere in the document — largely consistent, one gap

- The `def:BX` footnote transcription (line 486, "Seventeen named keys: two rules (TN, TR), three
  ... axioms (TB, TL, CN), eight primary Since/Until axioms (TA, UE, UT, UI, UC, UF, UG, SU), and
  four uniformity axioms (NP, NF, NA, NB)") correctly totals 17 against the live
  `def:BX` paper text (TN, TR, TS, TL, TC, UE, UT, UI, UC, UF, UG, SU, CN, NP, NF, NA, NB = 17
  keys) — the *count* is right, only the two key names `TB`/`TA` are wrong (see below).
- Nowhere does the document state the Lean-side total of 29 constructors; the auto-generated
  `axiom-report-table` figure (from `generated/status.typ`) is the only place raw Lean axiom data
  appears, and that is regenerated mechanically, not hand-transcribed — no action needed there.

### Mislabeled axiom keys: `TB` should be `TS`, `TA` should be `TC`

`docs/reference/paper-definitions-of-record.md`'s pinned, live-verbatim quote of `def:BX`
(the Base Burgess-Xu Tense Logic) lists exactly: `TN`, `TR` (metarules) and `TS`, `TL`, `TC`,
`UE`, `UT`, `UI`, `UC`, `UF`, `UG`, `SU`, `CN`, `NP`, `NF`, `NA`, `NB` (axiom schemata). **`TB` and
`TA` do not occur anywhere in the current paper-definitions record.** `docs/reference/axiom-reference.md`'s
"Base Axiom Categories" table confirms the mapping: paper key **TS** -> `serial_future`
("Seriality"), paper key **TC** -> `connect_future` ("Connectedness"). `grep -n
"\bTA\b\|\bTB\b\|\bTC\b\|\bTK\b\|\bT4\b\|\bTS\b" typst/FormalFoundations.typ` found `TB` at lines
465, 481, 486, 591, 1233, 1386 and `TA` at lines 468, 481, 486, 592, 1236, 1241, 1388 — 7 sites
each (`TB`/`TA` are each used in the `def:BX` transcription, the `def:TM` transcription, the
algebra-derivation remark of §Algebras, and the ultrafilter-frame Lemma). Every one of these sites
is describing the same seriality axiom (`⊢ F⊤` / `somefuture top`) or the same connectedness
axiom (`φ → GPφ` / `allfuture(somepast phi)`) that the Lean tree and the paper key as `TS`/`TC`.
This is a straightforward, mechanical rename (not a meaning change) once the plan phase decides
whether to keep it purely textual or add a provenance note like the existing BX_f/d/c one.

### `TK` and `T4` — likely obsolete, not renamed keys

`TK` (line 589, "temp K distribution") and `T4` (line 590, "temp 4") appear only inside the
document's `definition("TM")` block (§1.3) and its one later cross-reference (§Algebras, line
1232). Neither `TK` nor `T4` appears anywhere in `docs/reference/paper-definitions-of-record.md`.
`docs/reference/axiom-reference.md` explicitly documents that the Lean-side analogues are *not*
axioms at all: "`temp_k_dist` and `temp_4` are **derived theorems**, not axioms --
they are `temporalKDistDerived` and `temporal4Derived` in
`FormalSystem/Theorems/TemporalDerived.lean`." There is no live paper key these could be a rename
target for (unlike `TB`/`TA`, which have unambiguous current-key replacements). This is a symptom
of the larger structural issue below, not a simple relabeling.

### Structural finding: the `definition("TM")` block (BL-level) has no current paper counterpart

This is the most consequential finding and needs a plan-phase decision, not just a text edit.

`docs/reference/paper-definitions-of-record.md`'s "Language correspondence (2026-09-08)" section
(added after 584's TR-rename wave) states, as a **permanent** fact about the paper: "The
manuscript has exactly two languages" (𝓛 and 𝓛⋆, an objective-modality extension unrelated to
tense), and gives this correspondence table:

| Repository | Manuscript |
|---|---|
| **L**, **TM** (with TM_z, TM_d, TM_r) | 𝓛 (`def:BLplus-language`), TM (`def:TMplus`) — the same systems under the same names |
| **L⁻**, **TM⁻** | **no counterpart.** The H/G fragment was withdrawn from the paper ... L⁻ is this repository's own language |

And `def:TMplus` itself (the record's pinned quote) reads: "The Base Logic of Tense and Modality
TM for `𝓛` extends S5 and the base logic BX to include all instances of the ... axiom MF ... The
discrete TM_z, dense TM_d, and dense and complete TM_r extensions of TM include the additional
axioms that distinguish BX_z, BX_d, and BX_r, respectively." I.e. the paper's *one* "TM" system is
built entirely on BX (an Until/Since-primitive system) plus MF — there is no separate,
primitive-tense-operator (`G`/`H`-primitive, no Until/Since) "TM" system in the current paper at
all. The BL^+ -> BL collapse (2026-09-07 wave, same record file) made Until/Since the *sole*
primitive: "`def:BL-semantics` absorbs the `\since`/`\until` truth clauses ... and drops the
`\Past`/`\Future` clauses, which are now defined rather than primitive."

`typst/FormalFoundations.typ`'s own footnote (line 163) already half-acknowledges this: "The
paper's base language `#BL` takes the one-place [`allpast`/`allfuture`] as primitive instead; it
embeds into `#BLplus` under @def-operators, and **is not used below**." But then
`definition("TM")` at line 576 immediately contradicts that footnote: "*TM*, the *Logic of Tense
and Modality* for `#BL`, extends CPL to include ... MP, MN, MK, MT, M5, MF, TR, TK, T4, TB, TA,
TL" — a full independent axiomatization *for* `#BL`, presented as if it is paper content. Per the
correspondence table above, this is exactly the repository's own `L⁻`/`TM⁻` construct (i.e. what
lives in `FormalSystem/Syntax/MinusLanguage/`), which task 584 already stopped attributing to the
paper on the Lean side (`MinusLanguage/Axioms.lean`'s docstring, per 584's summary: "TM⁻ is no
longer attributed to the paper"). This typst document was not updated to match.

Two further consequences of this same collapse, both currently live and load-bearing in the
document (not artifacts of the stale `TM`(BL) block, so not simply deletable along with it):

1. Sections 2-5 (Completeness, Decidability, the Completeness Construction, and even the
   Representation Theorem's remarks) repeatedly state results "for TM" using the *bare* name —
   e.g. `theorem("Soundness")`, `theorem("Incompleteness at the base level")`
   ("None of TM, `op("TM")_f`, ... is complete over its class") — where the surrounding notation
   macros make these statements about the `#BL`-level (primitive-tense) system, i.e. about what
   the document calls plain `TM`. If the plan phase confirms (per the correspondence table) that
   the paper's *single* "TM" is really the Until/Since-based system this document calls `TM^+`,
   these downstream sections need to be re-examined too, since "TM is not complete over its
   class" (line 677-680) is currently a claim about the wrong system relative to what the current
   paper calls "TM".
2. The document's own subscripting is internally consistent (`op("TM")_f/d/c` for the BL-level
   family, `op("TM")^+_f/d/c` for the BL+-level family) and is *also* internally consistent with
   `def:TMplus`'s `TM_z/TM_d/TM_r` naming only for the `+` family (once `f/d/c` is read as `z/d/r`
   per the already-present Naming Provenance remark). The mismatch is purely which family the bare
   name "TM" should denote.

This is a genuine design decision, not a typo fix: either (a) keep the document's current BL/BL+
split as an intentionally-broader, repository-motivated exposition and add an explicit provenance
disclaimer (mirroring the existing BX_f/d/c "Naming provenance" remark at lines 512-524) stating
that the `#BL`-level `TM`/`BX` material is the repository's own `L⁻`/`TM⁻` construct with no
current paper counterpart, keeping bare `TM` as this document's own name for it; or (b) rename the
whole `TM^+`/`op("TM")^+_f/d/c` family to bare `TM`/`TM_z`/`TM_d`/`TM_r` throughout (matching
`def:TMplus` exactly) and either delete or clearly demote the `#BL`-level `definition("TM")` block
to an explicitly-labelled appendix/aside. Option (b) is a much larger diff (every occurrence of
`op("TM")^+` in the ~1080 remaining lines after §1, plus the figure/table captions and footnotes
that currently distinguish "TM" from "TM^+"). This report does not recommend one over the other;
it flags the decision as the single largest scoping question for the implementation plan.

### Some/All Past/Future labels — clean

The document's own local notation layer (`bimodal-notation.typ`, imported at line 26) supplies
`#somepast`, `#somefuture`, `#allpast`, `#allfuture`, `#always`, `#sometimes` used consistently
throughout (`definition("Defined Operators")`, line 165-173, glosses them as "Some Past", "Some
Future", "All Past", "All Future" respectively). Per
`docs/reference/paper-definitions-of-record.md`'s rename-3 entry ("`\past`/`\future` labels
'Past'/'Future' -> 'Some Past'/'Some Future', with `\Past`/`\Future` now 'All Past'/'All Future'
... Adopted. The Lean names `somePast`/`someFuture`/`allPast`/`allFuture` already matched"), this
is already the current, correct convention on both the paper and Lean sides, and
`FormalFoundations.typ` already uses it. No action needed for this category.

### Other items checked and found current (no action needed)

- `def:BX-z`/`def:BX-d`/`def:BX-r` naming and their old-key f/d/c cross-reference: covered by the
  document's own "Naming provenance" remark (lines 512-524), which is accurate and current against
  the paper-definitions record's "z/d/r wave" section.
- DF/DN/CO (the `#BL`-level frame-property correspondence axioms, §1.3 lines 601-612 and §2.1):
  these are *not* stale — `DF`, `DN`, `CO` remain live, current paper keys (`app:discrete`,
  `def:frame-properties`, and the still-pinned `CO` anchor all confirm this), and they exist at
  the `#BL` (primitive-tense) level genuinely, independent of the `TM`(BL) axiomatization question
  above — `app:discrete`/`app:dense`/`app:complete` are current paper theorems about a temporal
  order's Discrete/Dense/Complete property, unrelated to whether the tense operators are primitive
  or defined.
- `#leansrc(...)` declaration-name citations (60 total scanned): none reference an old identifier;
  all match current module/declaration names seen in `FormalSystem/` during this research pass
  (`Metalogic.BXCanonical`, `Metalogic.WeakCanonical`, `Metalogic.Algebraic.LindenbaumQuotient`,
  etc.). A full per-citation existence check (confirming every `#leansrc` target still resolves
  to a live declaration) was not performed in this pass — the file is 1577 lines with ~60 such
  citations, and a targeted `typst-sync-check.sh`-style verification is better suited to the
  implementation phase's own verification step than to a read-only research pass.

## Decisions

- No text was edited in this research pass; task 607 is a research dispatch and the corrections
  above are queued for `/plan 607`.
- Scoped the audit to exactly the four categories the dispatch names (proof-system/axiom-count
  claims, the TR rule, renamed identifiers, Some/All Past/Future labels) plus the structural
  `TM`/`TM^+` naming question that the axiom-count investigation surfaced as a prerequisite to
  fixing the count remark correctly (the remark's wording depends on which system "the paper"
  means).

## Risks & Mitigations

- **Risk**: fixing `TB`->`TS`/`TA`->`TC` and the count remark without also resolving the
  `TM`/`TM^+` naming question would leave the document self-consistent on the small items but
  still structurally misleading about which system is "the paper's TM". **Mitigation**: the plan
  phase should decide the TM/TM^+ naming question first (Option (a) or (b) above), since it
  determines whether the mechanical `TB`/`TA` fix touches the `#BL`-level block, the `#BLplus`-level
  block, or (under option (b)) is subsumed by a larger rename.
  - **Update note (during this research pass)**: `TS` and `TC` are BX (`#BLplus`-level) keys, so
    the `TB`->`TS`/`TA`->`TC` rename is correct and needed regardless of how the TM/TM^+ question
    is resolved — both the `def:BX` transcription and the `definition("TM")` block use the same
    two axiom formulas under these wrong local names, and both should say `TS`/`TC` either way.
    Only the *disposition* of the surrounding `definition("TM")` block (keep-with-disclaimer vs.
    rename-and-demote) depends on the larger decision.
- **Risk**: a plan that only fixes the count remark risks re-transcribing the exact wrong-in-the-
  other-direction error 584 already made once. **Mitigation**: the corrected counts (11
  future-direction BX-temporal constructors with derived-not-explicit past mirrors; 4 uniformity
  constructors with only NP's mirror derived) are pinned in this report against
  `FormalSystem/ProofSystem/Axioms.lean`'s own module docstring and
  `docs/reference/axiom-reference.md`'s Paper Key Correspondence section — the plan/implement
  phases should quote those two files directly rather than re-deriving the counts from prose.
- **Risk**: `#leansrc` citation drift was not exhaustively checked (60 citations across 1577
  lines). **Mitigation**: recommend the implementation phase run (or the plan phase schedule) a
  `#leansrc`-target existence check, e.g. via `scripts/typst-sync-check.sh` if it covers this file,
  or a targeted grep-per-citation pass, before considering the resync complete.

## Context Extension Recommendations

- **Topic**: BL/BL+ collapse and the `L⁻`/`TM⁻` no-paper-counterpart fact.
- **Gap**: `docs/reference/paper-definitions-of-record.md`'s "Language correspondence
  (2026-09-08)" section is the only place this fact is recorded, and it is deep inside a
  chronological drift-correction log (line ~212 of a 2000+ line file) rather than in a
  discoverable, stable location. Anyone editing `typst/FormalFoundations.typ` or
  `FormalSystem/Syntax/MinusLanguage/` needs this fact but is unlikely to find it there.
- **Recommendation**: consider promoting the "Language correspondence" table (repository
  L/TM/L⁻/TM⁻/L⁺/TM⁺/L⋆ vs. manuscript 𝓛/TM/𝓛⋆) to a short, stable reference doc (e.g.
  `docs/reference/language-correspondence.md`) that both `typst/FormalFoundations.typ` and
  `FormalSystem/Syntax/MinusLanguage/Axioms.lean` can cite by a stable path, rather than only
  living inside the paper-definitions drift log. This is a suggestion for a separate task, not
  something to fold into 607's own scope.

## Appendix

### Search queries / commands used

```
find . -iname "FormalFoundations.typ" -not -path "*/.git/*"
find FormalSystem -iname "*.lean" | xargs grep -lE "reflectTime|time_reflection|TimeReflection|TR\b"
find specs -iname "*584*"
grep -n -iE "swapTemporal|swap_temporal|temporal_duality|TemporalDuality|temporalDuality" typst/FormalFoundations.typ
grep -n "leansrc" typst/FormalFoundations.typ
grep -rn "time_reflection\b" FormalSystem/ProofSystem/
grep -n -E "^\| (TB|TA|TL|CN|...)\b|DANGLING|PINNED_COMMIT|LINE_COUNT|FILE_CHECKSUM" docs/reference/paper-definitions-of-record.md
grep -n "^### " docs/reference/paper-definitions-of-record.md | grep -iE "BX|S5|TMplus"
grep -n "twenty-two\|five constructors\|29 axiom\|constructors" typst/FormalFoundations.typ
grep -n "\bTA\b\|\bTB\b\|\bTC\b\|\bTK\b\|\bT4\b\|\bTS\b" typst/FormalFoundations.typ
grep -n "\bDF\b" docs/reference/paper-definitions-of-record.md
```

### Key reference files for the plan/implement phases

- `typst/FormalFoundations.typ` (the file to edit)
- `docs/reference/paper-definitions-of-record.md` — authoritative pinned paper text; especially
  the "Language correspondence (2026-09-08)" and "Drift correction and rename absorption
  (2026-09-17): the time-reflection wave" sections
- `docs/reference/axiom-reference.md` — authoritative Lean-side axiom counts and Paper Key
  Correspondence table
- `FormalSystem/ProofSystem/Axioms.lean` — module docstring is the ground truth for constructor
  counts and layer structure
- `specs/archive/584_reconcile_lean_tree_with_paper_vocabulary/summaries/02_paper-vocabulary-reconciliation-summary.md`
  — prior task's Follow-ups list names this exact deferred work
