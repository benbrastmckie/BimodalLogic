# Implementation Plan: Land the one-sided count-move refutation as a wired evidence probe

- **Task**: 855 - Probe the one-sided ▷/◁ type transport against the refuted two-sided shape
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None (but see CONTENTION under Risks: must run in a cycle of its own)
- **Research Inputs**: `specs/855_one_sided_open_modal_type_transport_probe/reports/01_one-sided-open-modal-transport.md`
- **Artifacts**: plans/01_one-sided-count-move-evidence-probe.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/plan-compliance.md`
  - `.claude/rules/state-management.md`
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round returned a **NEGATIVE verdict** and it is a complete outcome, not a gap: the
one-sided factorization given by ▷/◁ does not crack the transport condition. This round does no
new mathematics. It converts the two compiled facts the research produced into the only form this
repository treats as durable — a `sorry`-free probe under `specs/evidence/seam-gluing-ray-product/`
that is wired into `scripts/check-evidence-probes.sh` in the same round, so it cannot rot
unwatched — and it discharges in-file the one thing the prototype left inherited: non-vacuity of
the refutation's hypotheses.

The probe to be landed is self-contained by construction, not by preference. A probe is compiled
with `lake env lean` and sits outside the Lake module graph, so **no probe can import another**.
The two-state object the non-vacuity instantiation needs therefore has to be re-derived verbatim
from `ladder-cell-agreement-refutation.lean` inside the new file; the convention and its rationale
are already recorded in the gate's own header block for
`seam-gluing-ray-product/ladder-idle-past-interface-decision`, which did the same thing.

### Research Integration

The plan executes the report's Recommendation 2 and nothing beyond it. Four findings shape it:

1. **The ◁ side is the compiled refutation.** `futAtomPreservingCountMove_refuted` carries exactly
   the hypotheses the landed `atomPreservingCountMove_refuted` carries and refutes the strictly
   weaker ◁-shaped schema; `atomPreservingCountMove_refuted_via_fwd` recovers the recorded
   two-sided refutation from it through the relaxation. That composition — the two-sided fact as a
   *corollary* of the one-sided one — is the precise content of "the ◁ projection removes nothing",
   and it is what the wired file must exhibit.
2. **The ▷ side is attributed, never re-proved** (report Decision 4). The ▷-shaped count move is
   already landed as `exists_spliced_ladderPath_of_pend_past`, and
   `Probe761S.splice_type_invariance_refuted` already says it does not preserve the realized type.
   Re-deriving a second witness would add a probe and no information. The ▷ side is recorded in the
   new file's header prose, with its probe named, and is not a proof obligation of this round.
3. **Non-vacuity is the one real gap.** The prototype's hypotheses are discharged on a compiled
   object *elsewhere*; the report flags that a reader could mistake the prototype for a vacuous
   refutation. Phase 2 closes this by instantiating at `Probe761C`'s two-state object, where
   admissibility is free: `Adm pend q = {c | pend q = false → c = 0}` and `pendC 0 = true`, so
   **every** countdown is admissible at the pending state (`admZeroC`).
4. **The half-line test is the reusable product** (report Recommendations 4 and 5). The new file's
   header states it: name the half-line the counter is read from and the half-line the formula is
   read from; if both are forward, `cntAt_eq_of_pend_eq_fwd` plus `splice_type_invariance_refuted`
   already decide the proposal. Recording it in the probe header is in scope; recording it under
   `FormalSystem/` or `.claude/` is not (see Non-Goals).

### Prior Plan Reference

No prior plan. This is the task's first plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases are requested, so no
ROADMAP.md consultation or update is part of this plan. The ROADMAP's own framing of this task —
"a conjecture recorded as one cheap probe's worth of work, not a result and not a route" — is
satisfied by a negative verdict landed as evidence, which is what this plan produces.

## Goals & Non-Goals

**Goals**:
- The two-state object, re-derived verbatim (probes cannot import each other): `pendC`, `stepC`,
  `pC`, `labC`, `labC_pC`, `pendFactorsLabC`, `admZeroC`, `wC`, `cC`, `gC`, `gC_isPath`,
  `gC_objAt_zero`, `gC_cntAt_zero`
- The two one-sided relaxations and their relaxation lemmas: `PastAtomPreservingCountMove`,
  `FutAtomPreservingCountMove`, `futAtomPreservingCountMove_of_twoSided`,
  `pastAtomPreservingCountMove_of_twoSided`
- The forward sharpening: `cntAt_eq_of_pend_eq_fwd`, `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab`
- The schematic refutation and its two-sided corollary: `futAtomPreservingCountMove_refuted`,
  `atomPreservingCountMove_refuted_via_fwd`
- The in-file non-vacuity instantiation, new this round: `admissible_shift_at_zero`,
  `cntAt_ne_shift_at_zero`, `exists_one_sided_refuting_instance`,
  `futAtomPreservingCountMove_refutedO`, `atomPreservingCountMove_refutedO`
- Goals stated in prose (not Challenge-pinned; no backticks here by design, since a snapshot tool
  reads every backticked token in this block as an identifier): the probe file at its declared
  path, carrying a collection-style header that states the negative verdict, names the two
  projections and which half-line each fixes, attributes the one-sided move to the landed splice
  and its type refutation by probe name, records the half-line test, and records the axiom profile
  and the compile-check line; the gate wiring, as one header table block plus one WIRED entry; the
  file staged so the gate's tracked-ness test can see it; a full green gate run with no regression
  on the other wired probes; scoped commits of exactly the declared paths; and the task summary

**Non-Goals**:
- **No edit under `FormalSystem/` or `Tests/`** (task guardrail). In particular the refutation
  table in `FormalSystem/Metalogic/Decidability/RaySummary/README.md` is **not** amended with this
  verdict, and `cntAt_eq_of_pend_eq_fwd` is **not** added to `LadderAgree.lean` even though it is a
  strict sharpening of a landed theorem that would be a legitimate library addition later. Both are
  recorded as follow-ups in the summary instead.
- No note under `.claude/context/project/lean4/` for the half-line test (the report's
  context-extension recommendation). That is a source-store edit governed by
  `.claude/rules/source-store-deploy-boundary.md`, outside this task's declared scope, and it
  carries its own resolution step; the test is recorded in the probe header instead and the note is
  left as a follow-up.
- No re-derivation of the ▷-side refutation, and no new witness for it. It is attributed to
  `Probe761S.splice_type_invariance_refuted` in prose (report Decision 4).
- No edit to `ladder-cell-agreement-refutation.lean`, `ladder-splice-type-refutation.lean`, or any
  other already-wired probe `.lean` file. The object is copied out of the first; neither is
  re-signed, repaired, or re-run as a source of truth.
- No deletion or relocation of `probes/01_one-sided-count-move.lean`. It is the research round's
  cited artifact (named in the report's Artifacts block and linked from `.return-meta.json`), and
  a task-record prototype living on beside a wired probe is the established local pattern —
  `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` is live
  on disk today, and `RaySummary/README.md` records both it and `tight-chain-regime-b.lean` as
  task-record prototypes rather than wired probes.
- **No decidability consequence claimed**, in either direction. No finite-fibre and no
  finite-width assumption; `not_finite_width_fmp` stands untouched. No recorded Challenge statement
  weakened anywhere. `CellLEZeroConstOfKappaEq`'s status is unchanged and
  `cellLE_zero_const_of_kappa_eq` remains claimed by nothing.
- No `sorry`, no new axiom, no vacuous definition (`def X := True` and relatives are prohibited
  outright by `.claude/rules/lean4.md`).
- No re-planning of the owed model-level `tpOf` pumping-lemma record. The report is explicit that
  this measurement does not change the terms under which that lemma can be stated, so that record
  proceeds unchanged and this round is not an input to it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **CONTENTION.** `specs/evidence/seam-gluing-ray-product/` and `scripts/check-evidence-probes.sh` are declared by the live ladder-realization task; a concurrent dispatch would collide on both | H | M | The overlap gate serializes this task against it, which is correct and must not be worked around. Run this in a cycle of its own, never concurrently with that task's dispatch. The declared `file_scope` is exactly the three paths below, so the gate can see the overlap |
| The gate's tracked-ness test fails the new probe: `check_probe` runs `git ls-files --error-unmatch` *after* the presence test, and reports `FAIL (untracked: ...)` for a file that is on disk but not in the index | M | H if unhandled | Stage the new probe (`git add -- <path>`, an explicit single-file pathspec) **before** the first gate run. `git ls-files` reads the index, so staged-but-uncommitted already counts as tracked. Phase 3 makes this an explicit step, not an afterthought |
| A `lake env lean` read races a concurrent guarded `lake build` and reports `object file '...' does not exist` | M | M | That is `FAIL (environment: ...)`, never probe rot — the gate's own triage rule says so and says the response is to re-run once any concurrent build has finished, never to touch a probe. Every compile in this plan goes through `flock .lake/build-guard.lock`, the same lock the gate itself takes for its whole run |
| The transcribed object drifts from `ladder-cell-agreement-refutation.lean`, so the two files silently disagree about what the two-state object is | M | L | Transcribe verbatim, keeping the source names (`pendC`, `stepC`, `labC`, `gC`, …) so a `diff` against the source probe's corresponding block is the check. The namespace differs (`Probe855O`), and since probes are never co-loaded there is no collision |
| A reader mistakes the landed probe for a vacuous refutation, as the report flags for the prototype | M | L once Phase 2 lands | `exists_one_sided_refuting_instance` exhibits the discharged hypotheses as a compiled existential at the concrete object, and `futAtomPreservingCountMove_refutedO` is the hypothesis-free headline. Both are in-file |
| Someone later reads this round as closing the decidability question, or as re-opening it | H | L | The header states the verdict as a *measurement* with no decidability consequence either way, and reproduces the report's Recommendation 5: the live route is the one `LadderChain.lean` already occupies, and its gap to `CellLEZeroConstOfKappaEq` is **not** a one-sidedness gap and is untouched here |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully serial: each phase's
verification consumes the previous phase's file state.

---

### Phase 1: Re-derive the two-state object and port the one-sided content [COMPLETED]

**Goal**: `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` exists and
compiles `sorry`-free, carrying the two-state object transcribed verbatim from
`ladder-cell-agreement-refutation.lean` and the prototype's one-sided content ported under the new
namespace. No new mathematical content yet — this phase is transcription, and its value is that the
file compiles as a self-contained unit.

**Tasks**:
- [ ] Create the file with `import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree`
      (the prototype's import, which is also `ladder-cell-agreement-refutation.lean`'s), a
      placeholder header block to be written in Phase 2, `namespace Probe855O`, and
      `open FormalSystem.Syntax`, `open FormalSystem.Metalogic.Decidability.RaySummary`
- [ ] Transcribe the two-state object verbatim from `ladder-cell-agreement-refutation.lean`
      (lines 77-205 of that file are the source range), keeping the source names: `Qc`, `pendC`,
      `stepC`, `pC`, `labC`, `pendC_zero`, `pendC_one`, `not_pendC_zero_false`, `admZeroC`,
      `labC_pC`, `pendFactorsLabC`, `wC`, `cC`, `pendC_wC_of_le`, `pendC_wC_of_gt`, `admC`, `gC`,
      `gC_objAt`, `gC_cntAt`, `gC_nxtAt`, `gC_isPath`, `gC_zero`, `gC_objAt_zero`, `gC_cntAt_zero`
- [ ] Omit the object's seriality lemmas `fwdC` and `bwdC`: they exist in the source probe to build
      a model and establish cell membership, and nothing in this file's refutation needs a frame.
      Omit `mem_cell_of_gC`, `chiC`, `paramsOkC`, `kappa_collisionC` and the rest of the source
      probe's parameter apparatus for the same reason
- [ ] Port the prototype `probes/01_one-sided-count-move.lean` verbatim under the new namespace:
      `PastAtomPreservingCountMove`, `FutAtomPreservingCountMove`,
      `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided`,
      `cntAt_eq_of_pend_eq_fwd`, `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab`,
      `futAtomPreservingCountMove_refuted`, `atomPreservingCountMove_refuted_via_fwd`. Keep the
      `variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}` block for these, so the
      schematic statements stay general and the object-specific instantiation in Phase 2 is visibly
      an application of them, not a specialization baked into them
- [ ] Carry the `#print axioms` block for every ported headline
- [ ] Compile and confirm exit 0, no warnings, and no `sorryAx` on any headline

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The covering check is one command —
`flock .lake/build-guard.lock lake env lean specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`
— and it is complete for this phase: the file is outside the Lake module graph, so it has no
consumer anywhere in the library whose build this edit could affect, and no other file is touched.

**Scope Hypothesis**: The two-state object is hypothesized to need exactly the 24 declarations
listed above, drawn from lines 77-205 of `ladder-cell-agreement-refutation.lean`, with `fwdC`,
`bwdC` and the parameter apparatus genuinely unnecessary. Confirm by compiling: if the omitted
seriality or parameter declarations turn out to be load-bearing, the compile names the missing
identifier and they are transcribed too. Do not substitute a different object or weaken a
statement to make the omission work.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` - new file:
  transcribed object plus ported one-sided content, placeholder header

**Verification**:
- `flock .lake/build-guard.lock lake env lean specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`
  exits 0 with no warnings
- `grep -c sorry` on the new file returns 0
- The `#print axioms` output shows a subset of `[propext, Classical.choice, Quot.sound]` on every
  headline, and `no axioms` on the two relaxation lemmas (matching the prototype's recorded
  profile); no `sorryAx`, no custom axiom, no `native_decide`
- `diff` of the transcribed object block against lines 77-205 of
  `ladder-cell-agreement-refutation.lean` shows only the namespace change and the omissions this
  phase declares

---

### Phase 2: Discharge non-vacuity in-file and write the collection-style header [NOT STARTED]

**Goal**: The refutation is non-vacuous *in this file*, not by inheritance, and the file's header
states the negative verdict in the form the probe collection uses — so that a reader arriving at
the file alone learns the verdict, which half-line each projection fixes, why the ▷ side needed no
new witness, and the two-line test that decides the next proposal of this shape.

**Tasks**:
- [ ] Prove `admissible_shift_at_zero (c₀ n₀ : ℕ) : (c₀ + 1) ∈ Adm pendC (objAt (gC c₀ n₀) 0)`.
      Route: rewrite with `gC_objAt_zero` and apply `admZeroC`. Admissibility is free at the
      pending state because `Adm pend q = {c | pend q = false → c = 0}` and `pendC 0 = true`
- [ ] Prove `cntAt_ne_shift_at_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 ≠ c₀ + 1`, from
      `gC_cntAt_zero` by `omega`
- [ ] Prove `exists_one_sided_refuting_instance`: a compiled existential exhibiting the discharged
      hypotheses at the concrete object — a ladder path, a position, and an admissible target
      countdown differing from the path's own. This is the artifact that answers the report's
      recorded risk that a reader could mistake the refutation for a vacuous one
- [ ] Prove `futAtomPreservingCountMove_refutedO : ¬ FutAtomPreservingCountMove stepC pendC labC`
      by applying the schematic `futAtomPreservingCountMove_refuted` at `pendFactorsLabC`,
      `gC c₀ n₀`, `gC_isPath`, `z := 0`, `c' := c₀ + 1`, `admissible_shift_at_zero`,
      `cntAt_ne_shift_at_zero`. Hypothesis-free in its own statement: this is the headline
- [ ] Prove `atomPreservingCountMove_refutedO : ¬ AtomPreservingCountMove stepC pendC labC` by
      composing `futAtomPreservingCountMove_refutedO` with
      `futAtomPreservingCountMove_of_twoSided`. State it **through the one-sided relaxation**, not
      by re-deriving `Probe761C.atomPreservingCountMove_refutedC`: the two-sided fact arriving as a
      corollary of the one-sided one is the measurement, and a direct re-proof would lose it
- [ ] Write the header block in the collection's style, stating: the **NEGATIVE verdict**; the two
      projections, with ▷ fixing the past and varying the future (`AgreeUpTo`) and ◁ fixing the
      future and varying the past (`AgreeFrom`); that both quantifiers fix the full ladder state at
      the evaluation point, so the measured condition is the **atom-row relaxation on a half-line**
      and why that is the strongest honest reading (report Decision 1); the ◁ side refuted here,
      with the two-sided refutation as its corollary; the ▷ side **attributed, not re-proved** —
      `exists_spliced_ladderPath_of_pend_past` already is a ▷-shaped count move
      (`spliceObj_eq_of_le` holds the object row at every `v ≤ a`, `spliced_at_region` moves the
      countdown) and `Probe761S.splice_type_invariance_refuted` says it does not preserve the
      realized type; the pincer in one sentence (the counter and the closure's eventualities read
      the same forward half-line, so freezing the future leaves nothing to transport and freeing it
      loses the type); the half-line test; the explicit statement that **no decidability
      consequence** is claimed and that the live `LadderChain.lean` route's gap to
      `CellLEZeroConstOfKappaEq` is not a one-sidedness gap and is untouched; that the object is
      re-derived verbatim from `ladder-cell-agreement-refutation.lean` because probes cannot import
      each other, and that file is not edited or re-signed; the axiom profile; and the
      compile-check line
- [ ] Extend the `#print axioms` block to the five new declarations
- [ ] Compile and confirm exit 0, no warnings, no `sorryAx`

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The covering check is the same single-file guarded `lake env lean`
invocation as Phase 1, and it is complete for the same reason: the file is outside the Lake module
graph and no other file is touched, so a green single-file compile is the whole blast radius.

**Scope Hypothesis**: Five new declarations are hypothesized to suffice for in-file non-vacuity,
with `admissible_shift_at_zero` discharging by `gC_objAt_zero` + `admZeroC` and
`cntAt_ne_shift_at_zero` by `gC_cntAt_zero` + `omega`. Confirm by compiling each as its own step.
If `admZeroC`'s triple-projection statement form does not rewrite cleanly against
`objAt (gC c₀ n₀) 0`, add the clean restatement `d ∈ Adm pendC (0 : Qc)` as a further transcribed
helper — not by weakening `admissible_shift_at_zero`'s statement.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` - the five
  non-vacuity declarations, the header block replacing the Phase 1 placeholder, the extended
  `#print axioms` block

**Verification**:
- The guarded single-file compile exits 0, no warnings
- `futAtomPreservingCountMove_refutedO` and `atomPreservingCountMove_refutedO` carry **no**
  hypotheses in their statements, so the refutation is visibly non-vacuous without reading another
  file
- `atomPreservingCountMove_refutedO`'s proof term mentions
  `futAtomPreservingCountMove_of_twoSided`, confirming the two-sided fact is derived *through* the
  relaxation rather than re-proved
- `#print axioms` on all thirteen headlines shows a subset of
  `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no custom axiom, no `native_decide`
- The header names every probe it attributes a fact to, by filename and declaration

---

### Phase 3: Wire into the evidence gate [NOT STARTED]

**Goal**: The new probe is guarded. It has a header table block recording what it holds in place
and a `WIRED` entry, and it is staged so the gate's tracked-ness test can see it. This is the step
the task's guardrail requires **in the same round** as the probe's addition.

**Tasks**:
- [ ] Add a header table block for `seam-gluing-ray-product/one-sided-count-move-refutation` in the
      established two-column comment style, immediately after the
      `seam-gluing-ray-product/ladder-idle-past-interface-decision` block and before `WIRED=(`.
      Content: the negative verdict; the ◁-shaped relaxation refuted and the two-sided one as its
      corollary; the ▷ side attributed to `ladder-splice-type-refutation`; the explicit note that
      the object is re-derived from `ladder-cell-agreement-refutation` because probes cannot import
      each other and that file is not edited; the in-file non-vacuity instance (pending state,
      `z = 0`, target `c₀ + 1` admissible because every countdown is admissible where the pending
      bit is set); no bound and no decidability claim; the axiom profile
- [ ] Append `"seam-gluing-ray-product/one-sided-count-move-refutation"` to the `WIRED` array,
      after the `ladder-idle-past-interface-decision` entry
- [ ] Confirm the label fits the gate's `printf '  %-62s '` column (the entry is 55 characters, so
      it does not disturb the aligned output)
- [ ] `git add -- specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` so
      that `check_probe`'s `git ls-files --error-unmatch` test passes. An unstaged new file reports
      `FAIL (untracked: ...)` and the probe's content is never measured
- [ ] `bash -n scripts/check-evidence-probes.sh` to confirm the edit left the script parseable
- [ ] Run the gate and confirm the new label reports `PASS`

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: The edited script is consumed by CI as step id `evidence-probes` in
`.github/workflows/ci.yml`, so the blast radius is that gate's own contract rather than one file;
`bash -n` plus a gate run that reports the new label `PASS` and the array a one-greater count
covers exactly that interface, and no Lean module's build is reachable from a comment block and an
array append.

**Scope Hypothesis**: The insertion anchors are hypothesized to be the end of the
`ladder-idle-past-interface-decision` header block (ending just before `WIRED=(` at line 2010) and
the `ladder-idle-past-interface-decision` array entry (line 2059), with the array holding 49
`WIRED` plus 1 `WIRED_REPO` entries before this edit and 50 plus 1 after. Line numbers drift;
confirm by grepping for the two literal anchors
(`^WIRED=\(` and `"seam-gluing-ray-product/ladder-idle-past-interface-decision"`) rather than by
seeking the recorded line numbers, and confirm the counts by re-counting after the edit.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one header table block, one `WIRED` array entry

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0
- The `WIRED` array holds exactly one more entry than before (50), and `WIRED_REPO` is unchanged
  at 1
- `bash scripts/check-evidence-probes.sh` reports `PASS` on the line labelled
  `seam-gluing-ray-product/one-sided-count-move-refutation`
- No other probe's line changes verdict, and the aligned column is undisturbed

---

### Phase 4: Full gate, axiom audit, scope confirmation, and summary [NOT STARTED]

**Goal**: The round is closed with the full gate green, the axiom profile recorded, the declared
scope confirmed against the working tree, and the negative verdict written up as the task's
durable record — stated as the result it is, not as a gap.

**Tasks**:
- [ ] Run `bash scripts/check-evidence-probes.sh` to completion and confirm all 51 entries (50
      `WIRED` + 1 `WIRED_REPO`) pass, with zero failures and zero environment failures. If an
      `environment:` failure appears, re-run once any concurrent `lake build` has finished — the
      gate's own triage rule forbids repairing, restating, or retiring a probe on that evidence
- [ ] Record the axiom profile of every headline of the new probe from the compile's own
      `#print axioms` output
- [ ] Confirm the declared scope: `git status --short` shows changes to exactly the planned paths
      and **nothing** under `FormalSystem/` or `Tests/`
- [ ] Confirm no recorded Challenge statement was weakened and no already-wired probe `.lean` file
      was edited
- [ ] Write `summaries/01_one-sided-open-modal-transport-summary.md`: the negative verdict as the
      result; the pincer; what was landed and where; the half-line test; and the three follow-ups
      this task's scope forbade — the `RaySummary/README.md` refutation-table row, the possible
      `LadderAgree.lean` addition of `cntAt_eq_of_pend_eq_fwd` as a strict sharpening, and the
      `context/project/lean4/` half-line-test note — each with the reason it is out of scope here
- [ ] Commit with targeted, explicit-file-list staging (never `git add -A`, `.`, a directory
      pathspec, or `git commit -am`), reviewing `git status --short` and `git diff --staged` first

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: The full gate is hypothesized to hold 51 entries after Phase 3 (50 `WIRED` +
1 `WIRED_REPO`), all passing. Confirm by re-counting both arrays and reading the gate's own
summary line rather than by trusting this number; another round may have wired a probe
concurrently, in which case the count is higher and that is not a defect. What must hold is that
every entry passes and that the only verdict this round changed is the new probe's.

**Files to modify**:
- `specs/855_one_sided_open_modal_type_transport_probe/summaries/01_one-sided-open-modal-transport-summary.md` -
  new file: the task's durable record of the negative verdict

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with all 51 entries `PASS`, no `does not compile`,
  no `untracked`, no `environment` failures
- `bash -n scripts/check-evidence-probes.sh` exits 0
- `flock .lake/build-guard.lock lake env lean specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`
  exits 0 with no warnings
- `grep -rn "sorry\|axiom " specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`
  finds no `sorry` and no custom `axiom` declaration
- `git status --short` lists exactly the declared paths, with nothing under `FormalSystem/` or
  `Tests/`
- The summary exists, states the verdict as a result, and names all three out-of-scope follow-ups

---

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe855O

/-! ## The two one-sided relaxations of the refuted two-sided schema -/

section Schematic
variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- The `▷`-shaped relaxation: past fixed, future free. The atom row is preserved only on the
half-line at or below the compared position. -/
def PastAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop := sorry

/-- The `◁`-shaped relaxation: future fixed, past free. The atom row is preserved only on the
half-line at or above the compared position. -/
def FutAtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop := sorry

/-- Both one-sided forms are genuine relaxations: the two-sided schema implies the `◁`-shaped
one, so refuting the latter is strictly stronger than the recorded refutation. -/
theorem futAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    FutAtomPreservingCountMove step pend lab := sorry

/-- …and the `▷`-shaped one. -/
theorem pastAtomPreservingCountMove_of_twoSided (lab : Q → Atom → Bool)
    (h : AtomPreservingCountMove step pend lab) :
    PastAtomPreservingCountMove step pend lab := sorry

/-- **The countdown is a function of the forward pend profile alone.** The sharpening of the
landed `cntAt_eq_of_pend_eq` that the one-sided measurement needs: the landed theorem's own proof
reads its hypothesis only at positions AT OR ABOVE the compared one. The landed theorem is left
exactly as it stands; nothing is weakened. -/
theorem cntAt_eq_of_pend_eq_fwd (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hpend : ∀ v : ℤ, u ≤ v → pend (objAt g v) = pend (objAt g' v)) :
    cntAt g u = cntAt g' u := sorry

/-- The atom-row reading: agreement of the atom row on the half-line at or above `u` already
forces the countdown at `u`. -/
theorem cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hlab : ∀ (v : ℤ), u ≤ v → ∀ p : Atom, lab (objAt g v) p = lab (objAt g' v) p) :
    cntAt g u = cntAt g' u := sorry

/-- **The `◁`-shaped one-sided count move is refuted**, under exactly the hypotheses the landed
`atomPreservingCountMove_refuted` carries. Freeing the whole PAST buys nothing: the obstruction is
entirely forward. -/
theorem futAtomPreservingCountMove_refuted (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ FutAtomPreservingCountMove step pend lab := sorry

/-- **The two-sided refutation is a corollary of the one-sided one** — the precise sense in which
the `◁` projection removes nothing. -/
theorem atomPreservingCountMove_refuted_via_fwd (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ AtomPreservingCountMove step pend lab := sorry

end Schematic

/-! ## The object, re-derived verbatim from `ladder-cell-agreement-refutation.lean`

Probes are compiled with `lake env lean` outside the Lake module graph, so no probe can import
another. `Qc` is `abbrev` scaffolding and is not a pinned identifier (the snapshot regex matches
`theorem|lemma|def|instance` only). -/

abbrev Qc : Type := Fin 2

/-- One pending state (`0`) and one idle state (`1`). -/
def pendC : Qc → Bool := sorry

/-- The step relation is total. -/
def stepC : Qc → Qc → Bool := sorry

/-- The pending bit is carried as this atom. -/
def pC : Atom := sorry

/-- The labelling: `pC` holds exactly at the pending state. -/
def labC : Qc → Atom → Bool := sorry

/-- The pending bit IS one of the atoms of the labelling. -/
theorem labC_pC (q : Qc) : labC q pC = pendC q := sorry

/-- **The pending bit factors through the atom row at this object.** -/
theorem pendFactorsLabC : PendFactorsLab pendC labC := sorry

/-- Admissibility of EVERY countdown at the pending state: `Adm`'s clause has a false hypothesis
there. -/
theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 := sorry

/-- The walk: pending at every position at or below `c₀`, idle above it. -/
def wC (c₀ : ℕ) : ℤ → Qc := sorry

/-- Its forced countdown: the distance up to the region's last pending position. -/
def cC (c₀ : ℕ) : ℤ → ℕ := sorry

/-- The ladder path through the walk, with constant register `n₀`. -/
def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC := sorry

theorem gC_isPath (c₀ n₀ : ℕ) : IsLadderPath stepC pendC (gC c₀ n₀) := sorry

theorem gC_objAt_zero (c₀ n₀ : ℕ) : objAt (gC c₀ n₀) 0 = 0 := sorry

theorem gC_cntAt_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 = c₀ := sorry

/-! ## Non-vacuity, discharged IN THIS FILE -/

/-- A countdown different from the path's own is admissible at the comparison position, because
the position is pending and every countdown is admissible there. -/
theorem admissible_shift_at_zero (c₀ n₀ : ℕ) :
    (c₀ + 1) ∈ Adm pendC (objAt (gC c₀ n₀) 0) := sorry

/-- …and it differs from the path's own countdown there. -/
theorem cntAt_ne_shift_at_zero (c₀ n₀ : ℕ) : cntAt (gC c₀ n₀) 0 ≠ c₀ + 1 := sorry

/-- **The refutation's hypotheses are inhabited at a compiled object**, so the refutation below is
not vacuous. -/
theorem exists_one_sided_refuting_instance :
    ∃ (g : ℤ → LadderState Qc pendC) (z : ℤ) (c' : ℕ),
      IsLadderPath stepC pendC g ∧ c' ∈ Adm pendC (objAt g z) ∧ cntAt g z ≠ c' := sorry

/-- **THE HEADLINE: the `◁`-shaped one-sided count move is refuted at this object**, with no
hypotheses left standing. -/
theorem futAtomPreservingCountMove_refutedO :
    ¬ FutAtomPreservingCountMove stepC pendC labC := sorry

/-- **The recorded two-sided schema is refuted THROUGH the one-sided relaxation** at the same
object — the two-sided fact arriving as a corollary of the one-sided one. -/
theorem atomPreservingCountMove_refutedO :
    ¬ AtomPreservingCountMove stepC pendC labC := sorry

end Probe855O
```

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with all 51 entries `PASS` (50 `WIRED`, 1
      `WIRED_REPO`), no `does not compile`, no `untracked`, no `environment` failures
- [ ] `bash -n scripts/check-evidence-probes.sh` exits 0
- [ ] The new probe compiles `sorry`-free under
      `flock .lake/build-guard.lock lake env lean …`, exit 0, no warnings
- [ ] `#print axioms` on every headline shows a subset of
      `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no custom axiom, no `native_decide`
- [ ] `futAtomPreservingCountMove_refutedO` and `atomPreservingCountMove_refutedO` are
      hypothesis-free, so non-vacuity is visible in-file
- [ ] `git status --short` touches exactly the declared paths; nothing under `FormalSystem/` or
      `Tests/`
- [ ] No already-wired probe `.lean` file is edited; no recorded Challenge statement weakened;
      `not_finite_width_fmp` untouched
- [ ] No decidability claim appears anywhere in the new probe, the gate block, or the summary

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` - the wired,
  self-contained, `sorry`-free probe: the ◁-shaped refutation with the two-sided one as its
  corollary, the forward sharpening of the countdown rigidity, and non-vacuity discharged in-file
- `scripts/check-evidence-probes.sh` - one header table block and one `WIRED` entry, so the probe
  is guarded against rot and a red CI run names it
- `specs/855_one_sided_open_modal_type_transport_probe/summaries/01_one-sided-open-modal-transport-summary.md` -
  the negative verdict as the task's durable record, with the three out-of-scope follow-ups named

`file_scope` for this round is exactly those three paths.

## Rollback/Contingency

Every phase is additive, and the only pre-existing file touched is `scripts/check-evidence-probes.sh`,
where the change is one comment block and one array element.

- **Phase 1 or 2 fails to compile**: fix forward. Never discard uncommitted changes to reach a
  passing compile. If a transcribed statement genuinely cannot be reproduced, mark the phase
  `[BLOCKED]` and raise it — `.claude/rules/plan-compliance.md` makes a would-be deviation on a
  `.lean` file a blocker to raise, not something to annotate and proceed past, and
  `.claude/rules/lean4.md` prohibits a vacuous placeholder outright.
- **Phase 3 or 4 shows a gate failure on another probe**: read the label before touching anything.
  `FAIL (environment: ...)` is an I/O failure of the build tree and is never probe rot — re-run
  once any concurrent `lake build` has finished. `FAIL (does not compile)` on a probe this round
  did not touch is pre-existing rot from another round; record it and do not repair it here, since
  every other probe `.lean` file is a declared non-goal.
- **Full revert**: remove the new probe file, remove the two edits to
  `scripts/check-evidence-probes.sh`, and the tree is back to its pre-round state. The research
  round's artifacts (`reports/01_…md`, `probes/01_one-sided-count-move.lean`) are untouched by this
  plan and survive any rollback, so the measurement itself is never at risk.
- **If a rollback with uncommitted work is genuinely needed**: `bash .claude/scripts/git-snapshot.sh 855`
  first, then the destructive command. For an ordinary defensive checkpoint before risky work, use
  `--no-revert` instead.
