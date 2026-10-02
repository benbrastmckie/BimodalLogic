# Implementation Summary: Task #703

- **Task**: 703 - L⁺ compression and completeness
- **Status**: [COMPLETED]
- **Started**: 2026-10-01T18:00:00Z
- **Completed**: 2026-10-02T01:50:00Z
- **Effort**: ~8 hours across dispatches 52, 53 and 54 (this file is the round's single summary)
- **Dependencies**: tasks 695, 696 (substrate as finally corrected), 699, 700, 706
- **Artifacts**: plans/06_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Round 7 closed the task. Dispatch 52 and 53 executed the user's option-1 ruling (mirror the
liveness filter) through sub-phases 20.3, 20.4 and 20.5, landing the flagship
`WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`: every ℤ-time
non-validity of an embedded `Formula` admits an accepted time-sliced L⁺ certificate. Dispatch 54
executed Phase 21 — the documentation rows, the four C2 axiom pins, the closing record, the
paired-repository read, and the full gate set — and closed the task with every gate green.

The task's own acceptance criteria are met: zero sorries, no new axiom, `docs/theorem-index.md`
rows, and C2 `AXIOM_BASELINE` pins for the new theorems. The soundness interface named in the task
description (`PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies`) is
untouched, with both statements unchanged.

## What Changed

### Phases 20.3-20.5 (dispatches 52-53) — the mirror filter and the flagship

- `PlusSlicedCertificate/Bridge.lean` — `bwdVertFold` and its five structural lemmas,
  `foldB_sub_nat`, `foldB_bwdOrbit_fold`, and **`mem_bwdLiveT_of_bwdLive_fold`**, the mirror
  filter's one unproved input. The "Why there is no backward counterpart" paragraph was rewritten
  (heading included) as "Why the forward filter is one-directional": its true claim about the right
  tail is retained; its false implication that no backward fold lemma exists is gone.
- `PlusSlicedCertificate/Stable.lean` — `bwdLiveAt`, `L₀bwd` and their soundness chain;
  **`TailStable`'s backward conjunct swapped to the filtered form**, residue indexing preserved,
  `decidableTailStable` still synthesized; `tailStable_of_raw` re-proved on both sides; the
  asymmetry note deleted.
- `PlusSlicedCertificate/Tail.lean`, `.../EmbedComplete.lean`, `.../FixtureStable.lean`,
  `.../Position.lean` — the restatements, the candidate `TailStableMirror`'s retirement, the
  `BotTargets` `⊥ U ⊥` / `⊥ S ⊥` regression pair, and the `⊆`/`⊇` dichotomy record.
- `PlusSlicedCertificate/EmbedComplete.lean` (20.5) — `Embedded.sliced_run_st_const`,
  `sliced_run_pos_fst`, the live-position identification, the one-directional liveness from an
  explicit half-run, `slicedCanon_tailStable` / `sliced_tailStable` at **every** residue,
  `exists_certifies_mem_winTimes`, and the two flagships
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and
  `plusRefutes_of_not_plusValidZTime_ofFormula`.

### Phase 21 (dispatch 54) — gates and the closing record

- `docs/theorem-index.md` — **four** added rows in the Decidability section, for
  `PlusSlicedCertificate.decidableCertifies`, `...plusRefutes_of_certifies`,
  `...exists_plusSlicedCertificate_of_tailStable_countermodel` and
  `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`: paper label `—`,
  frame class `ZTime`, axioms `pcq pinned:C2`.
- `scripts/check-module-invariants.sh` — four `#print axioms` lines in `AX_SRC` and four matching
  `AXIOM_BASELINE` lines in the same relative order, the C2 pass-message number word moved
  twenty-two → twenty-six, and a comment paragraph saying why these four are pinned (notably: an
  axiom leaking into `decidableCertifies` would make a `Decidable` instance noncomputable in
  substance while still elaborating, which no other check in the script would see).
- Four `Paper: — (reason)` lines added, in the declarations' own `/-- -/` blocks, satisfying C15's
  second assertion (`Check.lean`, `Sound.lean`, `Complete.lean`, `EmbedComplete.lean`).
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — the **closing record** as a
  header section: what the class is; that the carrier is infinite with finite fibres and why; what
  is proved (soundness, relative completeness, the embedding); that the **finite-carrier** finite
  model property is refuted while the **sliced** one is open, not refuted; that the doubly
  exponential expected slice width is a research finding and not a theorem of this tree; the
  **corrected nine-conjunct** condition set with the two corrections and their reasons; what (C3b)
  costs; what `TailStable` costs; and where the real asymmetry lies.
- Gate disposals, each a **fix** rather than a waiver — no allow-list entry was added for any:
  `Cl_untl_eq`/`Cl_no_{imp,box,snce,stab}` → the dotted form `Cl.untl_eq` / `Cl.no_*` (C23
  Uppercase_x); `NM_add_NF_ne` / `NM_add_NF_mem_winTimes` → `nmAddNF_ne` / `nmAddNF_mem_winTimes`
  (C23 Uppercase_x, and the dotted form was genuinely unwritable because `G.NM` is a live field-style
  `def` on the same structure); the `PlusGraphPath.datum` family → `decoded` (C23 shadowing against
  the outer `Decidability.datum` in `BiLasso/Realized.lean`); `Φ_back` / `Φ_fwd` → `ΦBack` / `ΦFwd`
  (C26); and `import FormalSystem.Init` added at `PlusSlicedCertificate/Fixpoint.lean`, its own
  minimal element (C24).
- Four surviving probe citations **by declaration name** under `FormalSystem/**` removed and
  replaced by the mathematical claim (`Splice.lean`, `Frame.lean`, `PlusSlicedCertificate.lean`,
  `Semantics/SlicedFrame.lean`), per the 2026-09-30 user ruling, which forbids naming a probe as
  well as citing its path.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — generated inventory
  blocks regenerated (`--emit-inventory`), twice, the second time after the final docstring edits
  moved the line counts again.
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix`, twice, for the
  same reason. Task 650's status was re-read from `specs/state.json` (`completed`) rather than
  trusted from the plan line.
- `FormalSystem.lean` — `lake exe mk_all --lib FormalSystem` reported "No update necessary"; this
  phase added no module.

## The paired-repository read (Phase 12's amendment, and Phase 12 exclusion 2 discharged)

Read at `/home/benjamin/Projects/ModelChecker`. **Nothing was written there**, confirmed below.
Phase 12 closed with this read only partially discharged — the five points were recorded off this
repository's own artifacts rather than off that repository. It is now discharged against the
repository itself. What was found, and what it means for each of the amendment's points:

The canonical documents are
`code/src/model_checker/theory_lib/bimodal/docs/{ADEQUACY,TRUST_PIPELINE,SEARCH_COVERAGE,SETTINGS,A2_GAP}.md`,
`.../semantic/certificate.py` (the sole authoritative serializer and the Python re-checker), and
`oracle/bimodal_logic/README.md`.

1. **The finite graph is withdrawn as a contract — and the paired repository had already
   independently withdrawn it.** There is no finite-graph or countermodel-graph export schema
   anywhere in that repository. A fixed-frame finite-digraph checking mode is an explicit non-goal
   (`docs/ARCHITECTURE.md`), and the finite-presentation small-model route is recorded there as
   *machine-refuted* (`docs/ADEQUACY.md`). So this point needs no correction on their side; it is
   already their position.
2. **The time-sliced graph is the target.** Their current wire contract is the three-segment
   **bi-lasso certificate** — `{"target": {...,"time":t}, "bx": [[φ,bool],...], "lassos":
   [{"back":[...],"mid":[...],"fwd":[...]},...]}`, canonical bytes, on stdin to
   `lake exe check_certificate`, one JSON line out. `docs/ADEQUACY.md` names `back`, `mid`, `fwd`,
   `bx`, `lassos` and `target` as an export contract whose field names cannot be renamed without a
   breaking change, and names **this** repository (`BimodalTools/README.md`'s certificate
   re-verification protocol) as the authority for it. The sliced shape is a **strict extension** of
   that: the lasso family is the special case of `k` lassos with edges `i → i` only, so a sliced
   wire format would add a per-slice edge matrix and a slice width, not rename or remove anything.
   **This task did not change the wire format and added no wire field**; the sliced certificate is
   not yet an interchange format.
3. **The search bound is the tuple `(n, nb, nm, nf)`, with no bound on `n` proved.** Their search is
   configured by a **triple** `(back, mid, fwd)` and they have already recorded the shape mismatch
   against the upstream single `n` as a named open item (`docs/ADEQUACY.md` §7.1(iii-e),
   `docs/A2_GAP.md`). The L-side closed-form bound they expect,
   `max ((2k+1)·2^k) (2·2^k)` at `k = |closure|`, remains available for `⊡`-free targets. For L⁺
   sliced targets **no bound on `n` is proved** and none should be configured from a formula; their
   period-divisibility caveat (`docs/SETTINGS.md`: a true back-period `nb'` is representable at a
   configured `back = nb` iff `nb'` divides `nb`) carries over to `nb`/`nf` unchanged, and
   `docs/SEARCH_COVERAGE.md` is their own decision record for that gap.
4. **(iv, replacing the amendment's false fourth point) Tail-stability is a rejection criterion on
   the frame-together-with-its-closure, not a re-presentation requirement.** `exists_tailStable_repr`
   is false and is stated nowhere: sub-phase 16.2c proved the forward demand unsatisfiable at a
   named certificate for every member of the re-presentation family. The forward conjunct is
   **liveness-filtered** (`ΦFwd R₀ ∩ R₀fwd = R₀`) and the backward conjunct carries the mirror
   filter (`ΦBack L₀ ∩ L₀bwd = L₀`), so reachable-but-dead positions are filtered out rather than
   required to be live. **New information about their side**: the paired repository documents **no**
   tail-stability concept at all — zero occurrences of `tail.{0,3}stab` repo-wide across `*.md`,
   `*.py`, `*.json` — and zero occurrences of "re-presentation". So point (iv) is not a correction
   of something they hold; it is a demand they have not yet heard of, and it is the one that will
   change their search's accept/reject logic. Their nearest existing concepts are *representability*
   of a compressed family at the configured lengths and the wire-level `error`-versus-`rejected`
   distinction, neither of which is the same thing; this record deliberately does not equate them.
5. **The never-report-validity discipline stands, and is already theirs.** It is their decision
   **D8**, with dedicated sections in `docs/ADEQUACY.md` §7.4 and `docs/ARCHITECTURE.md`, structural
   enforcement in `semantic/{model,core,proposition}.py`, and unit tests pinning the literal string
   "not a validity claim". For L⁺ targets containing `⊡` an empty search licenses nothing, and will
   until a finite model property is proved — which is exactly the still-open sliced finite model
   property.
6. **(vi) The demand is residue-indexed**, a bounded quantifier over each period's residues, which
   is what the `⊡` clause of the truth lemma requires. The checker's tail-stability cost is
   therefore `G.NBnat + G.NFnat` `Φ` applications rather than two, each over a live-position set
   that is itself a fixpoint. These are **measured cost figures, not complexity claims**, and no
   bound changes: there is still no bound on `n`.

## Decisions

- **Four pins, not eight.** The plan's "Artifacts & Outputs" and "Testing & Validation" sections say
  "eight added rows" / "eight new pinned declarations"; its Phase 21 task list, its Scope Hypothesis
  and its Verification block all say four and state the 22 → 26 arithmetic. Four is what was done,
  and `grep -c 'depends on axioms'` over the heredoc returns 26. The "eight" figures are stale from
  an earlier revision and were not followed.
- **The closing record went into the aggregator header, not a new subtree README.** The plan
  expressly permits either. A new `PlusSlicedCertificate/README.md` would acquire an INV
  hand-maintained-table obligation covering all 24 modules; the aggregator already carries the
  per-module list, so the record sits beside it.
- **Every inherited gate failure was fixed rather than waived.** The plan offered an allow-list
  entry for the C23 Uppercase_x names and a `nolint` with a reason for `Φ_back`/`Φ_fwd`. Neither was
  taken: renaming was available in every case and costs the gate script nothing. The one place the
  dotted form was genuinely unwritable (`G.NM` is a live field-style `def`, so
  `G.NM.add_NF_mem_winTimes` would resolve the field and then look for a nonexistent `Int` lemma)
  was resolved by a lowerCamelCase prefix instead of by an exemption.
- **`PlusGraphPath.datum` renamed to `decoded`, not the outer `Decidability.datum`.** Both members
  of the C23 shadowing pair are live and both predate this phase; the inner one is this task's own
  and the subtree is the one place where every `datum` identifier referred to the same declaration,
  so the rename was mechanically safe there and not in `BiLasso/`. English-prose uses of the word
  "datum" in docstrings were deliberately left alone.
- **The probe-citation cleanup was not in the plan and was done anyway.** Plan v12 asks only that
  this be *confirmed*; confirmation found four violations, so they were fixed in this phase rather
  than reported.

## Plan Deviations

- **Phase 21**, the subtree README, **altered**: written as a header section in
  `PlusSlicedCertificate.lean`, which the task line permits, for the INV reason above.
- **Phase 21**, the pin count, **altered**: four, per the phase's own arithmetic, against the stale
  "eight" in two later sections of the same plan.
- **Phase 21**, the probe-citation confirmation, **altered**: it was a fix, not a confirmation, because
  four citations by declaration name were still present.
- **Phase 21, additional work not in the plan**: C24 (`import FormalSystem.Init` at
  `Fixpoint.lean`) and C26 (`ΦBack`/`ΦFwd`) were disposed of here. Both were named in the phase's
  own GATE-STATE table as this task's to dispose of, so this is the phase's scope, not a widening.
- Phase 21 otherwise followed its task list exactly.

## Verification

- Build: **Success** — full `lake build` through `lake-build-guard.sh`, detached: guard exit 0,
  "Build completed successfully (2806 jobs)", zero `error:` lines over both captured streams, and
  every module this task touched carries an `.olean` newer than its source (Check, Sound, Complete,
  EmbedComplete, Basic, Stable and the aggregator all checked individually).
- Sorry count: **0** (`lean-sorry-census.sh` over every root `lean-src-roots.sh` resolves).
- Vacuous count: **0 new**. The single-line grep's one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`), is
  pre-existing, untouched by this task, and a genuine theorem rather than a placeholder.
- Axiom count: **unchanged**. The naive `^axiom ` census reads 14 over all source roots and reads
  the same 14 at `main`'s HEAD; every one of the 14 is a docstring line-continuation beginning with
  the word "axiom", not a declaration.
- `#print axioms` on each of the four new pins — `decidableCertifies`, `plusRefutes_of_certifies`,
  `exists_plusSlicedCertificate_of_tailStable_countermodel`,
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` — reports exactly
  `[propext, Classical.choice, Quot.sound]`, measured directly and then re-asserted by C2's
  whole-string equality. `plusRefutes_of_not_plusValidZTime_ofFormula` was measured too and reports
  the same, though it is not among the four pinned.
- `bash scripts/check-module-invariants.sh`: **exit 0, ALL CHECKS PASSED**. C2 reports
  "all twenty-six pinned axiom sets match baseline"; C15 passes both assertions (61 anchors, 235
  theorem-index rows); C23 passes all three; C24, C26, C33 and INV pass. B0 and C9 were already
  passing when this phase opened.
- `bash scripts/typst-sync-check.sh`: **PASS, all 4 checks green**. No `--no-verify` bypass was used
  or needed.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc: **26**. Scope Hypothesis
  **CONFIRMED** — seven line-groups, and the baseline moved 22 → 26 as asserted.
- `WitnessFamily/Compression/Family.lean`, `PlusWitnessFamily/Agreement.lean` and
  `Semantics/IntNormalForm.lean`: no task-703 commit touches any of them. Family.lean stayed closed,
  which is what the option-1 ruling buys; `plusTruth_iff_mem` and `plusRefutes_of_certifies` survive
  with their statements unchanged.
- `FrameOver.ofStep` is called by **no** Stage 2 module; every occurrence is prose.
- The presented frame's carrier is confirmed infinite by a proved theorem
  (`Frame.frame_worldState_not_finite`), not by a comment.
- `grep -rn 'Probe706|Probe703' FormalSystem/` is **empty** across `.lean` and `.md`; no `specs/**`
  path and no probe declaration name introduced by this task remains under `FormalSystem/**`.
- The five probe files under `specs/703_lplus_compression_and_completeness/probes/` and
  `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` are
  unmodified (`git status --short` over both directories is empty).
- `git -C /home/benjamin/Projects/ModelChecker status --porcelain` is **byte-identical before and
  after the read**: only its pre-existing ` M specs/events.jsonl`. No file there was created, edited
  or staged.
- Zero lines over the 100-character limit in any touched file; three long lines the `datum` →
  `decoded` rename introduced were re-broken.
- Tests: N/A — this phase adds no test; `lake build` covers the whole library including `Tests/`.
- Files verified: Yes

## Impacts

- **The task's flagship exists and is pinned.** `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`
  is the L⁺ twin the task description asked for, on `⊡`-free embedded targets, and it is in the
  theorem index, in C2's baseline, and in `MainResults`-adjacent reach through the aggregator.
- **The decidable checker is pinned as a decision procedure.** C2 now guards
  `decidableCertifies`, which closes a gap no other check covered: an axiom leaking into a
  `Decidable` instance elaborates silently.
- **The condition set is recorded correctly for the first time.** Earlier passes recorded four and
  then five clauses; the landed `Certifies` carries nine, and the aggregator header now says so with
  both corrections and their reasons.
- **The paired repository's hand-off record is complete and content-only.** Their finite-graph
  withdrawal and their D8 discipline turn out to match this repository's position independently;
  the one genuinely new demand for them is residue-indexed, doubly-filtered tail-stability, which
  they document nowhere and which changes their accept/reject logic rather than their bounds.
- **Four gate groups are permanently clean** rather than exempted, so a future Uppercase_x,
  shadowing, underscore-def or missing-`Init` regression in this subtree fails loudly.

## Follow-ups

- The **option-3 successor** the user's ruling calls for — evaluate whether the obstruction can be
  removed at its root by carrying full labels in the certificate so `posAt` becomes a singleton,
  refactoring as needed, the known cost being the decidable search `Check.lean` is built around — is
  specified under the plan's "The option-3 successor, specified and deliberately not filed" and is
  **still not filed**. This dispatch did not file it.
- The **sliced** finite model property is **open, not refuted**, and is separate work. Until it is
  settled, the never-report-validity discipline is load-bearing for every `⊡`-carrying L⁺ target.
- The **CTL-like fragment's own finite model property** is a separate research-first successor that
  this task does not plan. What is settled is only that the fragment does not rescue the
  finite-carrier shape.
- A **sliced wire format** for the paired repository is unwritten. The extension shape is recorded
  (per-slice edge matrix plus slice width, on top of the existing `back`/`mid`/`fwd`/`bx`/`lassos`
  fields) but nothing in `BimodalTools/` emits or parses it, and their `(back, mid, fwd)`-triple
  versus upstream-`n` mismatch is still open on their side.
- `prevTime_le_left` landed in Phase 20.4 as the plan's named mirror of `nextTime_ge_right` and has
  no consumer; it is harmless and reporting-only under C17.

## References

- `specs/703_lplus_compression_and_completeness/plans/06_lplus-sliced-certificate-and-completeness.md`
  (plan v12; Phases 20.3-20.5 and 21)
- `specs/703_lplus_compression_and_completeness/.decisions.json` entries 3-7
- `specs/703_lplus_compression_and_completeness/reports/06_tailstable-backward-conjunct-repair.md`
- `specs/703_lplus_compression_and_completeness/handoffs/phase-21-handoff-20261002T014500Z.md`
- `/home/benjamin/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`,
  `.../TRUST_PIPELINE.md`, `.../SEARCH_COVERAGE.md`, `.../SETTINGS.md`, `.../A2_GAP.md`,
  `.../semantic/certificate.py` (read-only)
