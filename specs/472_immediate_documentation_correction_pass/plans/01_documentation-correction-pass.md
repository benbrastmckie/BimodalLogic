# Implementation Plan: Immediate documentation-correction pass

- **Task**: 472 - Immediate documentation correction pass
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: 470 (recorded in state.json; not gating this ungated pass)
- **Research Inputs**: specs/472_immediate_documentation_correction_pass/reports/01_documentation-correction-verification.md
- **Artifacts**: plans/01_documentation-correction-pass.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Nine files carry verified-false or stale documentation claims: five stale/contradictory `.lean`
module docstrings, two `.lean` docstrings on specific declarations, and two markdown READMEs. Every
one of the nine reproduces, and six of them carry additional false claims inside the same block
being edited. This pass rewrites PROSE AND DOCSTRINGS ONLY — it proves nothing, closes no `sorry`,
and changes no declaration, signature, or import. Definition of done: both builds exit 0, C1-C11
pass, the diff is a subset of the nine-file `file_scope`, and no surviving claim names a
declaration or file that does not exist.

The governing rule for every replacement sentence: **a claim that cannot be reproduced by
`scripts/check-module-invariants.sh` (C2 axiom sets, C3 sorry inventory, C4/C5 reference
resolution, C7 file counts) or by a named-symbol grep must not be written.** The complementary
rule, equally binding: **do not retreat into vagueness to make a claim safe.** "Proven",
"sorry-free", and "axiom-clean" are three different properties and saying which one holds is the
entire point of this pass.

### Research Integration

The research report re-verified all nine items independently (by symbol grep and filesystem
existence, never by trusting in-place prose or line numbers) and drafted grounded replacement text
for each. This plan consumes it directly; the implementer should treat the report's per-item
"Correction shape" paragraphs as the specification for each phase, not as suggestions to re-derive.
Key inherited facts:

- **Baseline is green** at commit `1f192f3f8`: `lake build` exit 0 (2462 jobs), `lake build
  BimodalTest` exit 0 (2512 jobs), `check-module-invariants.sh --no-build` ALL CHECKS PASSED. Any
  red after an edit is attributable to that edit.
- **The tree has exactly one structural `sorry`**: `countermodel_discrete` in
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, asserted by C3 **by content**, never by line
  number. Consequence used throughout: for any *other* live declaration, "it exists" entails "it is
  sorry-free", which is what discharges items (f), (g) and (i) mechanically.
- **C2 records a real distinction**: `BXCanonical.completeness` depends on `sorryAx`;
  `completeness_dense` and `completeness_discrete` do not. Item (a) turns on preserving it.
- The report ships a **present-symbols list** (safe to cite, ~60 symbols) and an **absent-symbols
  list** (must not be cited by any surviving claim): `filtration_is_finite`,
  `truth_preserved_under_filtration`, `buildTableau_isSome`, `chronicle_is_good`,
  `irr_sound_dense_at_domain`, bare `finite_model_property`; absent files `IRRSoundness.lean`,
  `Verified/Internalize.lean`, `Verified/Refutation/`, `Verified/Bridge/Omega.lean`,
  `Verified/Provable.lean`.
- **Six extra in-scope defects** were found (in items (a), (c), (e), (f), (g), (h)), each inside the
  same docstring block being edited and of the same defect class. They are folded into the phases
  below; shipping a corrected block with a known-false line still in it is not an acceptable outcome.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` is an explicit non-goal for this task and was not consulted or loaded.

## Goals & Non-Goals

**Goals**:
- Correct the nine verified false/stale claims (a)-(i), plus the six additional in-scope defects the
  research phase found in the same blocks.
- Make the SUBJECT of every corrected claim explicit (proof system vs. tableau engine vs. this
  directory's decision procedure) and name the theorem that carries it.
- Preserve the proven / sorry-free / axiom-clean distinction wherever it holds, quoting C2's
  baseline rather than paraphrasing it.
- Give `Verified/README.md` a two-value, mechanically checkable status vocabulary so
  absent-by-design and not-yet-documented can never again share a register.
- Replace line-number citations with symbol references inside every rewritten passage, and fix the
  three live-wrong `PriorDefsDense.lean:372` citations.
- Keep both builds green and C1-C11 passing at every commit boundary.

**Non-Goals** (do not do any of these):
- Touching `specs/ROADMAP.md`.
- Touching `FormalSystem/Metalogic/Decidability/README.md` (its `Verified/` row is already accurate
  and out of scope).
- Deleting `neg_2var_vec_ea` or `reflatten_neg_step`.
- Altering the large gated documentation task's `file_scope`, dependencies, or status.
- Proving anything, closing any `sorry`, or changing any declaration, signature, import, or tactic.
- Widening scope to `FMP/FMP.lean` (its docstring names the nonexistent `finite_model_property`;
  recorded as a follow-up, not fixed here).
- Converting all 30 line-number citations in `PriorExpressivenessDense.lean` — only those inside
  rewritten passages plus the three wrong `:372` sites.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Malformed `/-!` … `-/` block breaks `lake build` (nested `/-` inside `/-!` is the usual culprit) | H | M | Edit one file at a time and rebuild that module before touching the next; baseline is green so any red is attributable to the current edit. The two longest restructured blocks are `Verified/Decidable.lean`'s untlNeg section and `PriorExpressivenessDense.lean`'s DISCHARGED section. |
| Careless rewrite of (e) deletes load-bearing counterexample prose | H | M | Retitle and re-tense; delete only claims about *current* status, never the measured refutations. The file's own convention ("Read Defect 1 below in the past tense") is the model. |
| Writing "sorry-free" where only "proven" holds (or vice versa) | H | M | C2's recorded baseline is the authority. `BXCanonical.completeness` is proved but `sorryAx`-dependent; `completeness_dense`/`completeness_discrete` are both proved and sorry-free. Quote the distinction. |
| (b) rebuilds a table against a tree other in-flight tasks may be changing | M | M | Chosen status values are re-derivable in one command (`test -f` plus the aggregator import block); re-run `check-module-invariants.sh` immediately before the final commit (Phase 10). |
| Reintroducing line-number citations (the observed failure mode) | M | M | Every phase's verification includes a grep of the diff for `\.lean:[0-9]` in added lines; prefer symbol names unconditionally. |
| Writing a task-number citation under `FormalSystem/` | M | L | C9 is enforced and fails the gate. `.claude/rules/no-task-references-in-deliverables.md` applies: cite symbols and filenames, never task numbers. |
| "Fixing" the FMP `TruthAt` count from zero to one | M | M | The single `grep` hit is the README's own self-referential sentence in `FMP.lean` prose. The claim "this directory contains zero occurrences of `TruthAt`" is TRUE of the code and must be kept as-is. |
| Scope creep beyond the nine files | M | M | Phase 10 audits `git diff --name-only` against `file_scope` and fails on any extra path. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7, 8, 9 | 1 |
| 3 | 10 | 2, 3, 4, 5, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel. Wave 2's eight phases own disjoint files
(territory is one file per phase, except Phase 2 which owns two), so they are parallel-safe by
ownership; a single-agent implementer will run them sequentially, which is equally valid — the
per-file rebuild discipline is what matters, not the ordering.

---

### Phase 1: Baseline confirmation and scope lock [COMPLETED]

**Goal**: Reconfirm the green baseline on the current HEAD and re-validate the research report's
present/absent symbol lists, so every later red is attributable to an edit made in this pass.

**Tasks**:
- [x] Confirm the working tree is clean for the nine `file_scope` paths (`git status --short`).
- [x] Run `lake build` — must exit 0.
- [x] Run `lake build BimodalTest` — must exit 0.
- [x] Run `bash scripts/check-module-invariants.sh` — must report ALL CHECKS PASSED.
- [x] Re-verify the six ABSENT symbols still have zero declaration hits:
      `filtration_is_finite`, `truth_preserved_under_filtration`, `buildTableau_isSome`,
      `chronicle_is_good`, `irr_sound_dense_at_domain`, bare `finite_model_property`, using
      `grep -rnE '^(theorem|lemma|def|noncomputable def|abbrev|instance|structure|class) NAME\b' --include='*.lean' FormalSystem/ | grep -v Boneyard`.
- [x] Re-verify the five ABSENT files still do not exist (`Verified/Internalize.lean`,
      `Verified/Refutation/`, `Verified/Bridge/Omega.lean`, `Verified/Provable.lean`,
      `IRRSoundness.lean` anywhere).
- [x] Spot-check the present-symbols list for the symbols each phase will cite; record any symbol
      that has since moved or been renamed and adjust that phase's replacement text before writing it.
- [x] Record the C3 sole-sorry location and the C2 axiom baseline verbatim for use in Phases 6 and 2.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The report asserts a green baseline (both builds exit 0, C1-C11 pass) at
commit `1f192f3f8`, exactly one structural `sorry`, six absent symbols and five absent files.
Confirm all of these at the actual HEAD this pass runs against — if any has changed, update the
affected phase's replacement text before writing it, and record the divergence in the summary.

**Files to modify**: none (verification-only phase).

**Verification**:
- Both builds exit 0; `check-module-invariants.sh` reports ALL CHECKS PASSED.
- All six absent symbols return zero declaration hits; all five absent files return no match.
- Any divergence from the report's baseline is written down before any edit is made.

---

### Phase 2: (a) `Decidability.lean` Status block and (d) `decideAuto` termination claim [NOT STARTED]

**Goal**: Make the subject of every claim in `Decidability.lean`'s `## Status` block explicit
(proof-system result vs. tableau result), and replace `decideAuto`'s unsupported "ensures
termination for all formulas" with what is actually guaranteed. These two items are one corrective
framing — what the tableau does and does not prove — so they are corrected together.

**Tasks**:
- [ ] (a) Rewrite the `## Status` block in `FormalSystem/Metalogic/Decidability.lean` so each claim
      names its subject and its theorem:
      - Soundness of the **proof system**: `Metalogic.soundness` (`Γ ⊢[fc] φ → Γ ⊨ φ`), with
        `Decidability.decide_sound` the corollary at the empty context that `decide`'s `.valid`
        witness consumes.
      - Completeness of the **proof system**: `BXCanonical.completeness_dense` and
        `completeness_discrete` (proved AND sorry-free per C2); `BXCanonical.completeness` at
        `.Base` (proved, `sorryAx`-dependent per C2). Do not collapse this distinction.
      - Attribute "BFMCS" correctly: it names the `Metalogic/Bundle/` canonical-frame construction,
        which is not part of `Decidability/`.
      - **This directory's own decision procedure**: the rule half of `allClosed → valid` is
        `ruleSound_of_mem_allRulesForFC`; the `isValid φ fc = true ↔ ⊨ φ` biconditional and the
        `Decidable (⊨ φ)` instances for the four frame classes are OPEN, per `Correctness.lean`'s
        "Retired as vacuous" section.
- [ ] (a, extra defect) Correct "Proof extraction: Partial (axiom instances only)" — `extractProof`
      runs five strategies (`tryAxiomProof`, `matchDerived`, the closure-based `.axiomNeg` filter,
      `buildCompositionalProof`, `enhancedSearch`) before returning `.incomplete`. Keep "Partial";
      drop the "axiom instances only" parenthetical.
- [ ] Rebuild: `lake build` after the `Decidability.lean` edit; commit before starting (d).
- [ ] (d) Rewrite the `decideAuto` docstring in
      `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`:
      - State the real guarantee: `decideAuto` terminates because it is a total function at a finite
        fuel figure — every path returns a `DecisionResult`, with `.fuelExhausted` a first-class
        outcome — NOT because any theorem rules out `.fuelExhausted`.
      - State what is bounded and under which hypotheses:
        `expandBranchWithFuel_isSome_of_stock` (formula stock `C`, label set `L`, `NoSplit P fc`,
        fuel `> 2 * C.card * L.card`, `branchesUsed + fuel ≤ maxBranches`) and
        `expandBranchWithFuel_isSome_of_noSplit`. Name all three hypothesis families.
      - Record that `soundFuel` is a capped runtime default (`min (n * 2^n) 100000`) dominated by
        `soundFuel'` (`soundFuel_le_soundFuel'`), and that `soundFuel'` is itself only the
        single-world figure (`chain_le_soundFuel'` needs `hL`, not dischargeable in general).
      - Keep subset blocking as a **measured** behaviour with its witness named (`Fuel.lean` measures
        `buildTableau ((G p) → □(G p)) n .Base` as `none` for every `n ≤ 24`, `hasOpen` for every
        `n ≥ 25`), never as a universally quantified guarantee.
      - Do not cite `buildTableau_isSome` — it does not exist, and `Fuel.lean` records it as false as
        stated.
- [ ] Rebuild: `lake build` after the `DecisionProcedure.lean` edit; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts it touches exactly two files
(`Decidability.lean`, `Decidability/DecisionProcedure.lean`) and that `extractProof` runs exactly
five strategies. Confirm the strategy count by reading `ProofExtraction.lean`'s `extractProof` body
before writing "five"; if the count differs, write the count the code shows.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability.lean` - rewrite `## Status` block; fix proof-extraction parenthetical
- `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` - rewrite `decideAuto` docstring

**Verification**:
- `lake build` exits 0 after each of the two file edits.
- Every symbol cited in the new text resolves via the declaration grep; `buildTableau_isSome` appears
  nowhere.
- The C2 proven-vs-sorry-free distinction is present in the completeness claim, not collapsed.
- Added lines contain no `\.lean:[0-9]` line-number citation and no task-number citation.

---

### Phase 3: (b) Rebuild `Verified/README.md` against the live tree [NOT STARTED]

**Goal**: Replace the Layout table with one built from the live tree, using a two-value,
mechanically checkable status vocabulary that gives absent-by-design a distinct marker from
landed-but-undocumented.

**Tasks**:
- [ ] Enumerate the live `.lean` files under `FormalSystem/Metalogic/Decidability/Verified/` and
      cross-check each against the import block of the `FormalSystem/Metalogic/Decidability.lean`
      aggregator.
- [ ] Rebuild the Layout table with the two-value vocabulary decided by research:
      - `landed` — file exists AND is imported by the `Decidability.lean` aggregator (checkable by
        `test -f` plus a grep of the aggregator import block; C4 keeps the import resolvable).
      - `not built` — no such path exists (checkable by `test -e`).
      Neither value asserts schedule or intent. Do not reintroduce `planned` or `deferred`.
- [ ] Move the absent rows (`Internalize.lean`, `Refutation/Core.lean`, `Refutation/Rules/*.lean`,
      `Bridge/Omega.lean`, `Provable.lean`) under their own subheading with the `not built` marker,
      so the two registers cannot be confused. Keep them visible — they record a designed-but-unbuilt
      route.
- [ ] Add rows for every currently omitted live file, including `Termination/MintBound.lean` (the
      largest file in the subtree and entirely absent from the current table).
- [ ] Fill the Contents column by **lifting** the per-file descriptions already in
      `Decidability.lean`'s aggregator docstring rather than composing new ones — it covers every
      live file, is written against current code, and keeps the two files in agreement.
- [ ] Where a successor is known, say so in the Contents column rather than inventing a third status
      (e.g. `Bridge/Omega.lean`'s history construction and shift-closure is covered by
      `Bridge/RegionFrame.lean`).
- [ ] Fix the false sentence under the table ("Nothing in this table is a placeholder file — a path
      exists here only once its contents do") — it is false in both directions as written.
- [ ] Add a "Related Documentation" section and a `Last verified` stamp to match the convention of
      the sibling `FMP/README.md` and `Decidability/README.md`.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` (C4/C5/C7); commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Research counted 21 live `.lean` files under `Verified/`, all imported by the
aggregator; 8 existing files wrongly marked `planned`; 11 live files omitted entirely; 5 table rows
naming absent paths. Re-derive all four figures from the live tree at implementation time and build
the table from what the tree actually shows — never from these numbers.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/README.md` - rebuild Layout table, split registers, add omitted files, fix the placeholder sentence, add Related Documentation and `Last verified`

**Verification**:
- Every `landed` row passes `test -f` and appears in the aggregator's import block.
- Every `not built` row fails `test -e`.
- Row count equals the live file count plus the absent-by-design rows; no live file is unrowed.
- `check-module-invariants.sh --no-build` passes (C4 imports resolve, C5 markdown paths resolve).

---

### Phase 4: (c) `FMP/README.md` — replace nonexistent Key Results [NOT STARTED]

**Goal**: Remove the two Key Results that do not exist, replace them with what the directory
actually proves, and correct the three additional defects in the same file.

**Tasks**:
- [ ] Delete `filtration_is_finite` and `truth_preserved_under_filtration` from Key Results (zero
      occurrences in the tree, as declarations or as prose).
- [ ] Replace with verified-present results, each with its file and what it says: `fmp_contrapositive`,
      `mcs_finite_model_property`, `assignmentSpace_card`, `filtered_world_bound`, `fmp_size_bound`
      (`FMP.lean`); `FilteredWorld.finite`, `filteredCharacteristicSet_injective`
      (`FiniteModel.lean`); `filtration_lemma_membership`, `filtration_imp_forward`,
      `filtration_box_forward`, `filtration_lemma_bot` (`TruthPreservation.lean`);
      `exists_lt_iter_of_card_le`, `exists_bounded_iter` (`Periodicity.lean`, already correct — keep
      verbatim).
- [ ] State explicitly that the four `filtration_*` theorems are **MCS membership** facts, not
      `TruthAt` facts — this makes the README's existing "about MCS membership, not about truth"
      section checkable instead of merely asserted.
- [ ] KEEP the claim that the directory contains **zero** occurrences of `TruthAt`. It is true of the
      code; the single `grep` hit is the README's own self-referential sentence in `FMP.lean` prose.
      Do not "correct" the count to 1.
- [ ] KEEP the `refinedFilteredTaskRel` permissiveness note — `def refinedFilteredTaskRel` exists in
      `Filtration.lean` and the quoted body is accurate.
- [ ] (extra defect) Replace the Modules table's Lines column with a **declaration count** —
      `grep -cE '^(theorem|lemma|def|abbrev|instance|noncomputable def|structure) '` — re-derived at
      implementation time. All six current line figures are wrong; a declaration count is
      re-derivable by one command and rots an order of magnitude slower.
- [ ] (extra defect) Rename the Dependencies section's pre-rename `Bimodal.*` module paths to
      `FormalSystem.*`. This both fixes the claim and brings them under C5's guard (a stale
      `Bimodal.*` path is invisible to C5, which only resolves `FormalSystem.*`-shaped paths).
- [ ] (extra defect) Refresh the stale `*Last verified:*` footer.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build`; commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts six modules in the table and a specific declaration count
per module. Re-derive every count with the grep above at implementation time; do not copy the
report's figures into the file without re-running it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/README.md` - replace Key Results, add MCS-membership framing, swap Lines for declaration counts, fix `Bimodal.*` paths, refresh footer

**Verification**:
- Neither `filtration_is_finite` nor `truth_preserved_under_filtration` appears anywhere in the file.
- Every replacement symbol resolves via the declaration grep.
- The zero-`TruthAt` claim survives unchanged.
- Zero `Bimodal.` occurrences remain; `check-module-invariants.sh --no-build` passes C5.

---

### Phase 5: (e) `Verified/Decidable.lean` Status block and the stale BLOCKED section [NOT STARTED]

**Goal**: Rewrite the `## Status` block as a landed/open split (every item it lists as owed is in
fact proved), and retitle/re-tense the stale `untlNeg`/`snceNeg` BLOCKED section without losing its
counterexample material.

**Tasks**:
- [ ] Rewrite `## Status` as a landed/open split:
      - **Landed**: all `RuleSound` instances in this file, listed by carrier (the bulk at
        `carrierBase` via `ruleSound_base_mono`, `ruleSound_densityRule` at `carrierDense`, the
        discrete rules at `carrierDiscrete`, the Dedekind rules at `carrierDedekind`), plus the
        sub-phase 7.2 assembly `ruleSound_of_mem_allRulesForFC`. Sorry-free per C3.
      - **Not landed**: `valid_iff_allClosed` (sub-phase 7.3), which additionally needs the
        fuel/termination side and the truth-lemma gate; and the two rules scheduled outside
        `allRulesForFC` — `serialityRule` and `timeLinearity`, stages 2 and 3 of `expandOnce` —
        which need their own obligations where `expandOnce`, not `applyRule`, is the object.
      - Lift the "not landed" wording from `ruleSound_of_mem_allRulesForFC`'s own docstring, which
        already states it correctly, rather than composing new text.
- [ ] Delete (or retain explicitly as a past-tense record with the closure noted) the "blocked on a
      defect in `RuleSound`'s own statement" paragraph and its two escalated remedies. The file's own
      convention ("Read Defect 1 below in the past tense") supports the past-tense-record option.
      Note the retraction that already exists in-file: `OrdWithin` is in `RuleSound` and the four
      fresh-time existentials are proved against it.
- [ ] (extra defect) Retitle the section header
      ``## `untlNeg` and `snceNeg` — BLOCKED, two independent engine defects`` so it no longer says
      BLOCKED, and convert its body to past tense — `ruleSound_untlNeg` and `ruleSound_snceNeg` are
      proved earlier in this same file.
- [ ] PRESERVE the counterexample material in that section verbatim: it is load-bearing (it explains
      why the PASSIVE arm was retired, as `exists_gt_not_untl_disj`'s docstring records). Delete only
      claims about *current* status, never the measured refutations.
- [ ] Rebuild `lake build`; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Research counted 34 `ruleSound_*` instances, 27 of them riding
`ruleSound_base_mono`, in a 3,171-line file whose two stale blocks sit ~2,750 lines apart. Re-derive
the instance count and the per-carrier split by declaration grep before writing any number; if the
count differs, write what the grep shows.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` - rewrite `## Status`; retitle and re-tense the `untlNeg`/`snceNeg` section

**Verification**:
- `lake build` exits 0 (this file is 3,171 lines with a large restructured docstring — check the
  `/-!` … `-/` delimiters first if it fails).
- No surviving sentence describes any proved rule as owed, blocked, or unproved.
- The counterexample material is still present (diff shows retitle/re-tense, not deletion).
- The new `## Status` does not contradict `Correctness.lean`'s statement about
  `ruleSound_of_mem_allRulesForFC`.

---

### Phase 6: (f) `WeakCanonical.lean` — five nonexistent sorries [NOT STARTED]

**Goal**: Replace the five-bullet sorry list with the single true statement about the subtree's sole
structural `sorry`, and fix the two stale architecture lines and the stale fallback paragraph.

**Tasks**:
- [ ] Delete the five "documented sorries" bullets (Truth lemma G/H backward; Truth lemma
      Until/Since; `KEquivalenceFramework`; Table correctness; One-class theorem / `chronicle_is_good`
      — the last of which names a symbol that is not in the tree at all).
- [ ] Replace with the grounded statement: the subtree carries exactly one structural `sorry`,
      `countermodel_discrete` in `WeakCanonical/Transfer.lean`, which check C3 asserts **by content**
      (it locates the enclosing declaration by scanning backwards, never by line number). Do not cite
      a line number for it.
- [ ] Note that `completeness_discrete` — the result a consumer wants — routes around it via
      `countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`) and is
      sorry-free.
- [ ] (extra defect) Fix architecture line 2: "**TruthLemma**: … (atom/bot/imp proved, rest sorried)"
      — `G_backward_mcs` and `H_backward_mcs` exist in `WeakCanonical/TruthLemma.lean` and the file
      has no `sorry`.
- [ ] (extra defect) Fix architecture line 7: "**Table**: … (deferred)" — `table`,
      `table_depth_bound`, `TemporalTruth` and `table_correctness` are all landed in `Table.lean`.
- [ ] (extra defect) Delete the interim-fallback paragraph ("Currently delegates to the chronicle
      construction as interim fallback … activation when the Phase 3-5 sorries are resolved"): the
      chronicle chain is archived (this same docstring says so eight lines earlier) and there are no
      Phase 3-5 sorries left.
- [ ] KEEP the `## Main Export` block verbatim — it is the one current part of this docstring.
- [ ] Rebuild `lake build`; commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly one structural `sorry` in the `WeakCanonical/`
subtree and five bullets to delete. Re-run the C3-shaped structural-sorry scan over
`FormalSystem/Metalogic/WeakCanonical/` (Boneyard excluded) at implementation time and write what it
returns.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical.lean` - replace the five-bullet sorry list; fix architecture lines 2 and 7; delete the interim-fallback paragraph

**Verification**:
- `lake build` exits 0.
- `chronicle_is_good` appears nowhere in the file.
- The sole-sorry statement names `countermodel_discrete` and `Transfer.lean` with no line number.
- `## Main Export` is byte-identical to before.

---

### Phase 7: (g) `ShuffleReal.lean` — proved lemma called a strategic sorry [NOT STARTED]

**Goal**: Rewrite the module docstring's "What is landed here, and what is not" section so it agrees
with the theorem docstrings 165 lines below it, which already record the correct state.

**Tasks**:
- [ ] Replace "`doets_lemma_1_5` is stated but not proved … carried as a documented strategic
      `sorry`" with: `doets_lemma_1_5` is proved, via `kEquiv_orderedSum_of_kEquiv_colour`, with
      `BackAndForth.lean`'s `BackForth`/`kEquiv_iff_backForth` and `MixedSum.lean`'s
      `Mixed`/`backForth_of_mixed` supplying the engine (all named in the theorem's own docstring).
- [ ] (extra defect) Replace the second false paragraph: the coloured-index `≡ₖ` fact is NOT carried
      as an explicit hypothesis — it is proved by `kEquiv_colourStructure` (`ColourOrders.lean`), and
      `kEquiv_shuffle_shuffleReal`'s signature no longer takes `hcol`.
- [ ] (extra defect) Delete the trailing "The only thing this theorem is still conditional on is
      `doets_lemma_1_5` itself" sentence — vacuous now that `doets_lemma_1_5` is proved.
- [ ] State that the module is sorry-free and unconditional (C3: the sole tree `sorry` is in
      `Transfer.lean`).
- [ ] KEEP the Doets/Reynolds provenance prose — it is accurate and is the module's value.
- [ ] Rebuild `lake build`; commit.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `doets_lemma_1_5`'s body is
`kEquiv_orderedSum_of_kEquiv_colour …` (a term, not a `sorry`) and that
`kEquiv_shuffle_shuffleReal`'s signature has no `hcol` argument. Read both declarations before
writing the replacement text.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` - rewrite the "What is landed here, and what is not" section; delete the vacuous conditional sentence

**Verification**:
- `lake build` exits 0.
- The words "strategic `sorry`" and "not proved" no longer appear about `doets_lemma_1_5`.
- The module docstring and `doets_lemma_1_5`'s own docstring make the same claim.

---

### Phase 8: (h) `Soundness.lean` — IRR rule and `IRRSoundness.lean` do not exist [NOT STARTED]

**Goal**: Remove every reference to a nonexistent IRR rule, a nonexistent file, and a nonexistent
declaration; fix the broken relative documentation link in the same block.

**Tasks**:
- [ ] Delete numbered list item 6 ("**IRR rule**: Sound by construction (see IRRSoundness.lean)").
      There is nothing to replace it with: `inductive DerivationTree` has exactly seven constructors
      (`axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`,
      `temporal_duality`, `weakening`) and no IRR among them.
- [ ] Ensure the numbered list enumerates the constructors the soundness induction actually cases on;
      re-derive the constructor list from `ProofSystem/Derivation.lean` before writing it.
- [ ] Delete the `[IRRSoundness.lean](./IRRSoundness.lean)` link from `## References`.
- [ ] Remove or rewrite the three `irr_sound_dense_at_domain` prose notes (attached to
      `soundness_dense_valid` and `soundness_dense`) — the symbol does not exist as a declaration and
      the derivation type has no constructor for the case they describe.
- [ ] (extra defect) Fix the link depth: `[architecture.md](../../../docs/user-guide/architecture.md)`
      resolves one level above the repository root from `FormalSystem/Metalogic/`. The correct target
      is `../../docs/user-guide/architecture.md`. (C5 lints markdown files only, so this `.lean`
      docstring link is invisible to it — verify by hand.)
- [ ] KEEP untouched: "All soundness theorems are sorry-free" and the three `(sorry-free)`
      annotations on `soundness` / `soundness_dense` / `soundness_discrete` — C3 confirms them.
      `derivable_implies_swap_valid` and `derivable_implies_swap_valid_discrete` also stay.
- [ ] Rebuild `lake build`; commit.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts seven `DerivationTree` constructors, two `IRRSoundness.lean`
citation sites, and three `irr_sound_dense_at_domain` prose sites. Re-derive the constructor list
from `ProofSystem/Derivation.lean` and re-grep both citation counts in the file before editing.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` - delete IRR list item and reference link; remove/rewrite the `irr_sound_dense_at_domain` notes; fix the `architecture.md` link depth

**Verification**:
- `lake build` exits 0.
- `grep -c 'IRRSoundness\|irr_sound_dense_at_domain'` over the file returns 0.
- The fixed `architecture.md` link resolves from the file's own directory (verify with
  `test -f FormalSystem/Metalogic/../../docs/user-guide/architecture.md`).
- The sorry-free annotations are unchanged.

---

### Phase 9: (i) `PriorExpressivenessDense.lean` — resolve the self-contradiction [NOT STARTED]

**Goal**: Remove the "this module's only sorry" claim (the later "now sorry-free" claim is the
correct one), update the three further sites stale for the same reason, and preserve/strengthen the
Reynolds Theorem 3 pinning point.

**Tasks**:
- [ ] Fix the "What this module lands" bullet claiming `uSExpressivelyCompleteOverDensePrior`
      "carries this module's only `sorry`, isolated in `kampFaithfulExpressiveCompleteness_open`".
      The DISCHARGED section ~130 lines later is correct: the module is sorry-free.
      `kampFaithfulExpressiveCompleteness_open` is now a retained alias for
      `kampFaithfulExpressiveCompleteness` at the same type with no weakening, contributing no
      `sorryAx` downstream.
- [ ] (stale site 1) Fix the first "What this module lands" bullet:
      `KampFaithfulExpressiveCompleteness` is no longer "stated as a type rather than proved" — it is
      proved in four sorry-free rungs the DISCHARGED section enumerates
      (`Kamp.kampArm_zeta_faithful`, `Kamp.aggOdPopFold_iff_faithful`, the bridge/trichotomy files,
      and `Kamp/KampPriorFaithful.lean`).
- [ ] (stale site 2) Fix `uSExpressivelyCompleteOverDensePrior`'s docstring: delete "**Rests on one
      open obligation**, `kampFaithfulExpressiveCompleteness_open`".
- [ ] (stale site 3) Fix `uSExpressivelyCompleteOverDensePrior_at_denseWindow`'s docstring: it no
      longer "does not inherit the open obligation's `sorry`", and the anti-vacuity statement is no
      longer qualified by "while the obligation is open".
- [ ] KEEP AND STRENGTHEN the pinning point already in the file:
      `uSExpressivelyCompleteOverDensePrior` **is** Reynolds' Theorem 3, whereas
      `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean`), pinned at the strictly stronger
      `SemanticPriorUZ`/`SemanticPriorSZ`, is NOT. Add that
      `uSExpressivelyCompleteOverDensePrior` is now unconditional — which is what makes it Theorem 3
      outright rather than Theorem 3 modulo an obligation. Keep the supporting citations
      (`semanticPriorU_not_implies_semanticPriorUZ` exhibiting `denseRayFlow`;
      `uSExpressivelyCompleteOverDensePrior_not_by_reuse`).
- [ ] Replace all three `PriorDefsDense.lean:372` citations with a symbol reference —
      ``semanticPriorU_not_implies_semanticPriorUZ` (`PriorDefsDense.lean`)`` — the cited line is
      wrong (the theorem is one line later), which is the exact rot mode this task exists to retire.
- [ ] Convert line-number citations to symbol references **inside rewritten passages only**; do not
      convert the rest of the file's citations.
- [ ] Rebuild `lake build`; commit.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts one contradiction pair, three further stale sites, three
wrong `:372` citations, and 30 line-number citations file-wide. Re-grep `PriorDefsDense.lean:372`
and the "open obligation" phrasing at implementation time; fix every occurrence found, not a fixed
count.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` - remove the "only sorry" claim and the three stale open-obligation sites; strengthen the Theorem 3 pinning note; replace the three wrong line citations with symbol references

**Verification**:
- `lake build` exits 0 (the DISCHARGED section is one of the two longest restructured blocks — check
  `/-!` … `-/` delimiters first if it fails).
- No surviving sentence claims the module carries a `sorry` or rests on an open obligation.
- `grep -c 'PriorDefsDense.lean:372'` returns 0.
- The Theorem 3 / `SemanticPriorUZ`-pinning distinction is present and explicit.

---

### Phase 10: Final gate and scope audit [NOT STARTED]

**Goal**: Run the complete gate set, confirm the diff is confined to `file_scope`, and confirm no
surviving claim in any touched file names a nonexistent declaration or file.

**Tasks**:
- [ ] `lake build` — must exit 0.
- [ ] `lake build BimodalTest` — must exit 0.
- [ ] `bash scripts/check-module-invariants.sh` — C1-C11 must all pass (C1 build, C2 axiom baseline
      unchanged, C3 sole sorry unchanged, C4/C5 references resolve, C7 inventory, C9 no task-number
      citations under `FormalSystem/`).
- [ ] `git diff --name-only` against the merge base — every path must be one of the nine `file_scope`
      files (plus `specs/472_*` artifacts). Any other path is a failure to be reverted.
- [ ] Nonexistent-declaration sweep: extract every backticked identifier added by this pass from
      `git diff` and confirm each resolves via
      `grep -rnE '^(theorem|lemma|def|noncomputable def|abbrev|instance|structure|class) NAME\b' --include='*.lean' FormalSystem/ | grep -v Boneyard`,
      or is a deliberate absence statement (e.g. `Verified/README.md`'s `not built` rows).
- [ ] Confirm the six ABSENT symbols appear in no surviving claim across the nine files.
- [ ] Line-citation sweep: `git diff` added lines contain no newly introduced `\.lean:[0-9]`
      citation.
- [ ] Confirm C2's axiom baseline is byte-identical to Phase 1's recording (this pass changes no
      proof, so any C2 movement means something non-documentation was touched).
- [ ] Write the implementation summary at
      `specs/472_immediate_documentation_correction_pass/summaries/01_documentation-correction-summary.md`,
      recording per-item what was corrected, which extra defects were fixed, and any divergence from
      the research report's baseline found in Phase 1.
- [ ] Final commit.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4, 5, 6, 7, 8, 9

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the diff is exactly the nine `file_scope` files plus task
artifacts. Confirm by `git diff --name-only`; if any extra path appears, revert it before the final
commit rather than widening the declared scope.

**Files to modify**:
- `specs/472_immediate_documentation_correction_pass/summaries/01_documentation-correction-summary.md` - new implementation summary

**Verification**:
- Both builds exit 0; `check-module-invariants.sh` reports ALL CHECKS PASSED.
- `git diff --name-only` is a subset of `file_scope` plus `specs/472_*`.
- Zero surviving claims naming a nonexistent declaration or file.
- C2 axiom baseline unchanged from Phase 1; C3 sole sorry unchanged.

## Testing & Validation

- [ ] `lake build` exits 0 after every individual file edit, and at the final gate.
- [ ] `lake build BimodalTest` exits 0 at Phase 1 and Phase 10.
- [ ] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED at Phase 1 and Phase 10
      (C1-C11), and `--no-build` passes after each markdown phase.
- [ ] `git diff --name-only` is a subset of the nine `file_scope` paths plus `specs/472_*`.
- [ ] No surviving claim in any touched file names any of: `filtration_is_finite`,
      `truth_preserved_under_filtration`, `buildTableau_isSome`, `chronicle_is_good`,
      `irr_sound_dense_at_domain`, bare `finite_model_property`, `IRRSoundness.lean`.
- [ ] Every backticked identifier added by this pass resolves by declaration grep, or is an explicit
      absence statement.
- [ ] The proven / sorry-free / axiom-clean distinction is preserved wherever it holds — in
      particular `BXCanonical.completeness` (proved, `sorryAx`-dependent) vs.
      `completeness_dense`/`completeness_discrete` (proved and sorry-free).
- [ ] No newly introduced `.lean:NNN` line-number citation in any added line.
- [ ] No task-number citation under `FormalSystem/` (C9, enforced).

## Artifacts & Outputs

- `specs/472_immediate_documentation_correction_pass/plans/01_documentation-correction-pass.md` (this file)
- `specs/472_immediate_documentation_correction_pass/summaries/01_documentation-correction-summary.md`
- Nine corrected files (the exact `file_scope`):
  - `FormalSystem/Metalogic/Decidability.lean`
  - `FormalSystem/Metalogic/Decidability/Verified/README.md`
  - `FormalSystem/Metalogic/Decidability/FMP/README.md`
  - `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`
  - `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
  - `FormalSystem/Metalogic/WeakCanonical.lean`
  - `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean`
  - `FormalSystem/Metalogic/Soundness.lean`
  - `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`

## Rollback/Contingency

- Every phase commits its own file(s) separately (`Commit Mode: per-substep`), so a bad correction is
  reverted with a single `git revert` of that phase's commit without disturbing the others.
- If `lake build` goes red after a docstring edit, the fault is in that edit (Phase 1 established a
  green baseline): check the `/-!` … `-/` delimiters first — a nested `/-` inside `/-!` is the usual
  culprit — then the backticked Lean syntax and Unicode (`⊨`, `≡ₖ`, `→`, `∀`). Fix forward; never
  discard uncommitted work to reach a passing build.
- If a phase cannot be grounded — a replacement claim turns out unsupported by any check — leave the
  original text in place, mark that phase `[BLOCKED]` with the reason, and complete the remaining
  phases. Shipping fewer corrected claims is acceptable; shipping an ungrounded new claim is not.
- If the tree has drifted such that Phase 1's baseline does not reproduce, stop and record the
  divergence before editing: the whole pass depends on attributing any red to the current edit.
