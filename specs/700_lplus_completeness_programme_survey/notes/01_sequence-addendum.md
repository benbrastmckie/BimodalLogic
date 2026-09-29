# Sequence Addendum: Edge Re-Check and Declaration-Name Corrections

**Date**: 2026-09-29
**Task**: 700 — lplus_completeness_programme_survey
**Purpose**: Phase 1 of the implementation plan (`plans/01_completeness-programme-sequencing.md`).
Re-checks the survey report's three provisional edges (E2, E5, E8) against task 695's, 698's and
699's now-landed research reports, corrects one fully-qualified declaration name, records the F7
consumer correction, and records the duplicate-coverage sweep — all before Phase 2 creates
anything.

**Soundness is not in question.** Every finding below is a completeness-side gap or a
sequencing/naming correction. `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched by
anything in this addendum, and nothing here revisits soundness.

## E2 — 699 Part A → task 696 (survey classification: SOFT gate)

**Source**: `specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md`,
Decisions and Findings §§ A5 (lines 303–366) and Follow-On Task Proposal (lines 593–648).

**Verdict: the edge strengthens from SOFT to HARD.** 699 Part A's headline finding is that task
696's own recommended redesign "does not repair the collapse — it relocates it": the proposed
`SharingSkeleton.trans_refl` field reproduces `clause_shape_collapse`'s hypothesis exactly, so
`tUntl_trans_congr` / `tSnce_trans_congr` (probe-checked against an external `trans`) still derive
the collapsing congruence on any family that hops (`trans ≠ eq`). Both of 696's own gate families
set `trans = eq`, so the gate is green and the defect is invisible to it — but it is live on
exactly the target class design T's generality exists to admit. 699 files a follow-on task
proposal, **`trans_reflexivity_residual_collapse`** (proposal payload at
`specs/699_invariance_clause_audit_and_ockhamist_grounding/proposals/01_trans-reflexivity-residual-collapse.md`,
not yet filed as a numbered task), which explicitly states: "**Blocks**: task 696 Phase 1 (the
additive data layer, where `trans_refl` would be declared). Best resolved *before* that phase,
since removing a field afterwards is more expensive than not adding it." A blocking relationship
stated by the finding itself is stronger than the survey's original "read the table before the
rewrite phase" framing, so E2 is recorded here as **HARD**, not SOFT.

**Does 699's follow-on proposal subsume anything the survey assigned elsewhere?** No. Its scope
(decide whether `trans_refl` is required by auditing ~25 `Thread.const` call sites; if not,
specify the replacement field and hand it to 696 Phase 1; record `untl_succ_congr` /
`snce_pred_congr` as the intended residual; optionally construct a hopping countermodel) is
entirely about task 696's own substrate design. It does not touch the L⁺ compression theorem
(Proposal 1 below) or the structural preventions (Proposal 2 below), and per this task's
Non-Goals, task 700 proposes no task for dropping `trans_refl` — 699 already proposes and owns
that one.

**Consequence for this plan's Phase 2**: entry A's (`lplus_compression_and_completeness`)
dependency text must state its substrate dependency against 696 "as finally corrected", including
699's `trans_refl` follow-on once that task is filed by the user — exactly as the plan's Risk
table already anticipates. No placeholder task number is invented.

## E8 — 699 Part B → the new compression task (survey classification: ADVISORY, not gating)

**Source**: same report, Findings §§ B1–B3 (lines 368–539) and Decisions (lines 541–547).

**Verdict: 699 Part B does not settle O4, and the edge stays ADVISORY.** O4, as the survey framed
it, asks specifically whether GKWZ-style product-undecidability results (negative results for
products with an S5 factor and a linear factor) bound the project's two-S5-like-modality
combination (`box` over all histories, `⊡` over state-agreeing histories). **699's landed report
does not mention GKWZ, Gabbay–Kurucz–Wolter–Zakharyaschev, or "product" logic at all** — a direct
`grep` for these terms over the report returns no hits. Part B instead answers three different,
adjacent questions it was actually asked: B1 (is the collapse a recognized consequence of the
Peircean option — no, the surveyed frame classes all impose a past/diagram-completion condition
the project's frames drop, so the past-directed instance is formalization-native, not a known
result); B2 (is `Liftable` a known history-closure condition — yes, exactly the "⊇" half of
Emerson–Halpern R-generability); B3 (does any known result bound what a finite periodic
certificate over moment-history pairs can decide — yes: limit closure needs an infinite axiom
schema (Reynolds 2003 §5), Kamp's own axiom system is incomplete for Kamp frames (Thomason 1984
§4), and a positive result — Gurevich–Shelah decidability of Ockhamist validity with second-order
quantification over maximal chains, and Burgess's decidability of Peircean validity — "bounds the
risk rather than the design").

**Does any of it predict unreachability?** No. B3's net verdict is explicit that "a failure of
*this* certificate class is not evidence of undecidability" and names the positive
Gurevich–Shelah/Burgess results as external support for `Incompleteness.lean`'s own docstring
("Stability-modal decidability is not refuted"). Nothing in Part B changes the survey's
reachability verdict ("reachable, not provably blocked").

**Consequence for this plan's Phase 2**: O4 remains an **open, unanswered obligation** — not
resolved by 699 Part B as landed, and not contradicted either. Entry A's description must state
this precisely: it should read 699 Part B's verdict (which grounds O1–O3's context and rules out
the specific unreachability risk this survey checked for) but must **not** claim 699 Part B
answered O4 as originally phrased. If the GKWZ-applicability question in O4 needs answering, it
falls to entry A's own research round, unclaimed by any landed report. E8 stays **ADVISORY**, as
the survey classified it: Part B cannot invalidate the already-elaborated `famA_tCertifies` /
`famB_tCertifies` constructions, so it cannot gate 696, and its bearing on entry A is informative
(context and partial de-risking) rather than blocking.

## E1 / E5 — 695's carrier-normalization declaration and its two dependent edges

**Source**: `specs/695_plus_carrier_normalization_int_transfer/reports/01_plus-carrier-normalization-transfer.md`,
Executive Summary and Recommendations (lines 24–29, 226–247); confirmed against the live tree.

**Task 695 has landed** (`specs/state.json` records `project_number: 695, status: "completed"`),
not merely researched as the survey read it. The declaration is live:

```
grep -rn "plusValidZTime_iff_plusValidInt" FormalSystem/
FormalSystem/PlusLanguage/PlusIntTransfer.lean:188:theorem plusValidZTime_iff_plusValidInt (φ : PlusFormula) :
docs/theorem-index.md:151: | ... | FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt | FormalSystem/PlusLanguage/PlusIntTransfer.lean | ZTime | pcq pinned:C2 |
```

The theorem lives under `namespace FormalSystem.PlusLanguage` in the new module
`FormalSystem/PlusLanguage/PlusIntTransfer.lean`, exactly as 695's report recommended and exactly
as this plan anticipated. **The hand-off list's item 1 is corrected**:

- Superseded name (do not use): `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt`
- Corrected, live, confirmed name: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`

**Effect on edge strength**: neither E1 (A → D, HARD — `Compression/Family.lean:165`'s
`rw [validZTime_iff_validInt]` is Step 0 of the target theorem and has no provable analogue
without this declaration) nor E5 (D → paired-repository #200, HARD — #200's fourth stated need is
the compression bound only D supplies) changes strength. Only the declaration name underlying
both was corrected, and it is now confirmed against the live tree rather than against a report
that had not yet landed.

**The extension-point hand-off is still outstanding, and still a note, not an edit.** 695's
landed report's Recommendations section (5 items, lines 226–247) does not mention the
general-consequence (`Γ ≠ []`) extension point at all. Per this plan's Non-Goals, task 700 does
not edit task 695's artifacts or entries; the extension-point sentence remains a hand-off note for
a future revision of 695's plan (695 has no plan artifact yet in this round), recorded in
`notes/02_cross-repo-handoff.md` below.

## F7 nine-file table consumer

**Source**: `specs/698_file_scope_declaration_hygiene/reports/01_file-scope-hygiene-audit.md`,
Item 3 (lines 185–217).

**Confirmed: 698 declines to widen any task's `file_scope` by inference, including 696's.** The
report's Item 3 explicitly checks every non-terminal task mentioning
`check-module-invariants.sh`/`axiom baseline`/`theorem-index` (700, 412, 481, 482, 563, plus
282/296/298/696/695) and states: "700, 481, 482, 563 reference the script only as a
*non-regression gate* … None describes editing the script's `AXIOM_BASELINE`/theorem-index content
itself. Per the same 'do not narrow/widen by guessing' principle, I am **not** recommending these
four be given `scripts/check-module-invariants.sh` in file_scope." 696's own `file_scope` (14
entries, confirmed live in `specs/state.json`) already declares both shared gates
(`scripts/check-module-invariants.sh`, `docs/theorem-index.md`) but not the F7 nine-file table
(the additional files 696's own round-2 report names as part of its 23-file real footprint).

**Consequence**: the F7 nine-file table's consumer is **task 696's own plan phase**, via
`scripts/plan-file-scope-harvest.sh` (harvests `file_scope` from a plan's `Files to modify` lines
at plan postflight), not task 698. This task records the obligation as a hand-off note in
`notes/02_cross-repo-handoff.md`; it does not edit task 696's `file_scope` itself, per this
task's Non-Goals.

## Duplicate-coverage sweep

**Query**: swept `specs/state.json` for any non-terminal task whose `project_name` or
`description` matches `Compression|non_vacuity|shape_gate|check-module-invariants` (case
insensitive).

**Result**: two superficial matches, both confirmed unrelated on inspection of their
descriptions:

- **412** (`prove_refutation_core_and_decidability_of_provability_with_completeness_corollaries`)
  — Track B of the TM tableau decidability programme (parent task 165); proves
  `allClosed_derivable` by induction over `allRulesForFC`. Different logic route entirely (TM
  tableau, not the L⁺ WitnessFamily/compression certificate route); mentions
  "completeness" but not L⁺ compression.
- **559** (`nondeterministic_canonical_model_tm_star_completeness`) — a canonical-model
  completeness route for TM★, explicitly research-only with no changes to `FormalSystem/`.
  Different proof method (canonical model, not certificate compression) and a different target
  logic.

**No existing non-terminal task covers either of this plan's two proposals.** The
"propose nothing where covered" constraint is satisfied against the live tree: both proposals in
Phase 2 remain justified.

## Summary table

| Edge | Survey classification | This addendum's verdict | Changed? |
|------|------------------------|--------------------------|----------|
| E1 (A→D) | HARD | HARD, declaration name confirmed live | No (name corrected, strength unchanged) |
| E2 (B→C) | SOFT gate | **HARD** — 699's follow-on proposal explicitly blocks 696 Phase 1 | **Yes, strengthened** |
| E5 (D→#200) | HARD | HARD, declaration name confirmed live | No (name corrected, strength unchanged) |
| E8 (B'→D) | ADVISORY, not gating | ADVISORY, not gating — O4 unanswered by 699 as landed, no unreachability signal | No |

**Declaration name correction**: hand-off item 1 corrected from
`FormalSystem.Semantics.plusValidZTime_iff_plusValidInt` to
`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`, confirmed live.

**Task-count verdict**: exactly two new task entries remain justified — `lplus_compression_and_completeness`
and `certificate_non_vacuity_and_shape_gates` — unchanged from the survey's conclusion. Phase 2
proceeds to create both.
