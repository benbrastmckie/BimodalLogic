# Implementation Plan: Proof-Producing check_certificate

- **Task**: 677 - Proof producing check certificate
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/677_proof_producing_check_certificate/reports/01_proof-producing-check-certificate.md
- **Artifacts**: plans/01_proof-producing-check-certificate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Make `lake exe check_certificate`'s accepting branch *be* the composition of the four decided
certificate conditions with `WitnessFamily.joint_countermodel`, rather than a status line printed
beside it. The work is additive and lands in dependency order: name the bundled four-condition
predicate and the joint existence statement in the library, prove the implication between them,
prove the same guarantee at the level of the serialized verdict the consumer reads, then
restructure `checkRaw` so the accepting branch cannot be written without the four hypotheses in
scope, extend the output line with an additive `acceptance` key, and correct the five disclaimer
sites to state what the change actually buys. Done means: the whole gate set is green, no new
axiom appears in `#print axioms` for any new declaration, `checkRaw`'s behavior on the existing
test corpus is unchanged, and the accepting branch's guarantee is a kernel-checked implication
rather than prose.

### Research Integration

Every proof obligation this plan contains was discharged in a `lean_run_code` probe during
research before the plan was written; the report's Tactic Survey table records the tactic and
premise set for each. The plan therefore carries no speculative proof step. Four research
decisions are load-bearing here and are not re-opened by any phase:

1. **Additive, not a rewrite.** `Refutes` and `refutes_of_certifies` land *alongside*
   `joint_countermodel`, whose signature is untouched; `Examples.lean:245,264` keep working
   unchanged.
2. **`refutes_of_countermodel` lands before the restructure** (Phase 2 before Phase 3). Proved
   against the *current, unmodified* `checkRaw`, it machine-checks the composition at the
   earliest possible commit and then acts as a regression guard that fails the build if the
   restructure ever loosens the accepting branch.
3. **Nested `dite` on the four conditions, not one `dite` on the bundle.** Preserves today's
   short-circuit order and cost and keeps each localization scan in the branch it already
   occupies; a bundled `dite` would force the rejecting path to re-decide the failing prefix.
4. **The output change is additive only.** `"acceptance":"entailment"` is added to the
   `countermodel` line; `rejected` and `error` are untouched, and **the input wire schema is not
   touched at all**. An absent `acceptance` field reads as `"decided"`, which is what makes the
   change non-breaking for old binaries, stored verdicts, and the consuming repository's
   pure-Python re-checker.

The report also corrects the task description's opening framing, and this plan adopts that
correction rather than the original wording: the deliverable is a **build-time kernel-checked
implication** whose per-certificate hypothesis is supplied by compiled `Decidable` instances. It
is not per-certificate kernel checking (which would need re-elaboration per certificate, and is
out of scope). This is a documented correction to the prose, not a reduction of the code
deliverable, which is exactly what the task asks for.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, and `specs/ROADMAP.md` contains no
certificate-, checker-, or trust-pipeline-related item (grep for `certificate`, `check_certificate`
and `trust` returns nothing). No roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `Certifies`
- `decidableCertifies`
- `Refutes`
- `refutes_of_certifies`
- `refutes_of_countermodel`

Beyond those five pinned declarations, the phases below also deliver the plumbing that makes the
accepting branch proof-producing (`Acceptance`, `CheckOutcome`, `checkCertified`,
`CheckOutcome.erase`), the additive output-contract field, and the disclaimer corrections. Those
are structural or documentary, carry no pinned statement, and are therefore not listed as Goals
identifiers.

**Non-Goals**:
- Per-certificate kernel checking by generated-file re-elaboration or in-process `addDecl`. Out
  of scope; needs a feasibility measurement of kernel whnf cost on a real fixture before it can
  be costed. The `Acceptance` enum deliberately leaves room for a future `kernel` value, which
  this task does not introduce.
- `native_decide` in any form. It moves the compiler into the trust base via
  `Lean.ofReduceBool` — a trust regression, and a violation of the zero-debt stance on axioms.
- Any change to the **input** wire schema, to `parseCertificate`, or to `RawCertificate`.
- Any change to `joint_countermodel`'s statement or to `checkLine`'s non-dependent type.
- Any edit inside `~/Projects/ModelChecker` (the consuming repository). Its follow-ups are
  recorded as a hand-off, never performed here.
- Any Typst chapter edit. Grep confirms no Typst source mentions `check_certificate` or its
  disclaimer; `p2-decidability-practice.typ:94` discusses `decide_sound`, a different guarantee.
- Creating the follow-up task for per-certificate kernel checking. Phase 6 records its scope for
  a human to file.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The restructure silently changes a verdict | H | M | Phase 2 (`refutes_of_countermodel`) lands before Phase 3; each localization scan stays in the branch it occupies; the existing `#guard` corpus plus a `checkRaw' = checkRaw` equality `#guard` is Phase 3's acceptance criterion. Verified to hold in research probe 2. |
| `deriving` breakage from a `Prop`-carrying constructor | M | L | The `Prop` field lives only on `CheckOutcome raw`, which derives nothing. `CheckResult` keeps `Repr, Inhabited, DecidableEq` and gains only an `Acceptance` field, which derives all three. Verified in probe 1. |
| Adding lines shifts declaration spans, so named `file.lean:NNN` citations pointing into the edited files drift out of the declaration they name (C20/C20_DECL in `scripts/check-module-invariants.sh`) | M | M | Run `bash scripts/check-module-invariants.sh --no-build` in every phase that adds lines; on a C20_DECL hit, repair with `python3 scripts/reanchor-lean-citations.py --by-name --files <target>` and read the diff. Never add a baseline key. New module prose must cite declaration **names**, never `file.lean:NNN`. |
| `--wfail` on `BimodalTools` / `BimodalToolsTest` turns any new warning into a build failure | M | M | Every new declaration carries a doc comment; run `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` in the phases that touch them, not only at the end. |
| Overclaiming in the corrected prose | M | M | Phase 5 states the level-2 guarantee explicitly (build-time kernel-checked implication; per-certificate hypothesis from compiled decision procedures; trust base = Lean's compiler plus this module's decoding) and names the residual, rather than deleting the disclaimers. |
| The consuming side and the Lean binary disagree on the new field | M | L | The absent-field-means-`"decided"` rule is written into `BimodalTools/README.md`'s protocol section in Phase 4, so the two repositories can land in either order. |
| Sibling-task collision on this shared working tree | M | M | Tasks 679 and 680 declare no `file_scope`; 681 declares `WitnessFamily/Std.lean`, `Semantics/FrameConstraintIndependence.lean`, `Semantics/ShiftSet.lean`, `scripts/check-module-invariants.sh`, `scripts/lib/lean_citations.py` — no overlap with this plan's targets, but `WitnessFamily/README.md` rows for `Std.lean` may move under 681. Re-read every target immediately before editing; stage only this task's own hunks with an explicit file list; never a directory or glob `git add`; never `git-snapshot.sh` in its reverting default mode. Treat a build failure outside this plan's file set as possibly a sibling's in-flight edit. See `context/contracts/territory.md`. |
| Cost regression on the rejecting path | L | L | Nested `dite`, recorded as research Decision 3; Phase 3's verification compares rejecting-path behavior on the existing rejection rows. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential.

### Phase 1: Library Additions — Certifies, Refutes, refutes_of_certifies [NOT STARTED]

**Goal**: Name the bundled four-condition predicate, its `Decidable` instance, and the joint
existence statement, and prove the implication between them — all additive, with
`joint_countermodel` untouched.

**Tasks**:
- [ ] In `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean`, add
      `Certifies (W : WitnessFamily Γ Del) (t : ℤ) : Prop :=
      W.LocalCoherentLab ∧ W.FulfillingLab ∧ W.BoxFaithful ∧ W.Target t`, with a doc comment
      saying why the bundle exists (it is the hypothesis an accepting branch must hold) and why
      the conjunction order matches the four instances' evaluation order.
- [ ] In `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean`, add
      `instance decidableCertifies (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) :=
      by dsimp only [Certifies]; infer_instance`. The four landed instances compose through
      `instDecidableAnd`; `decidableTarget` takes `t` explicitly and is still found.
- [ ] In `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean`, add
      `Refutes (Γ Del : Context) : Prop` — the joint existence statement, named once, matching
      `joint_countermodel`'s conclusion verbatim (frame, `FrameClass.ZTime.Sat`, model, history,
      duration, premises true, conclusions false). Explicit `Γ Del` binders, not the section
      `variable`s, because the consumer applies it at `raw.target.premises` /
      `raw.target.conclusions`.
- [ ] In the same file, add
      `refutes_of_certifies (W : WitnessFamily Γ Del) {t : ℤ} (h : W.Certifies t) : Refutes Γ Del`
      in term mode as
      `joint_countermodel W h.1 h.2.1 h.2.2.1 h.2.2.2`. Do not restate `joint_countermodel`'s
      type through `Refutes`, and do not touch its signature.
- [ ] Add module-header prose to `Agreement.lean` explaining that `Refutes` names the statement
      the checker's accepting branch inhabits, and that `refutes_of_certifies` is the composition
      the executable applies. Cite declaration **names**, never `file.lean:NNN` (C20).
- [ ] Update the inventory row for `Predicates.lean`, `Decide.lean` and `Agreement.lean` in
      `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (the `| Module | Lines | Role |`
      table, hand-maintained — no GENERATED markers) to name the new declarations and carry the
      new line counts.
- [ ] Update the `WitnessFamily/` row in `FormalSystem/Metalogic/Decidability/README.md` to name
      `Certifies`, `Refutes`, `refutes_of_certifies` and `decidableCertifies` alongside the four
      condition and four instance names it already lists.
- [ ] Confirm `#print axioms` on `refutes_of_certifies` is `[propext, Classical.choice, Quot.sound]`
      — no `sorryAx`, no `Lean.ofReduceBool`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly five target files (three `.lean`, two `README.md`)
and that the two README tables are hand-maintained rather than generator-owned. Confirm at
implementation time by `grep -n "BEGIN GENERATED: inventory"` in both READMEs before editing (a
hit means run `bash scripts/check-module-invariants.sh --emit-inventory` instead of hand-editing
that block), and by re-reading each `.lean` target immediately before the edit in case a sibling
task touched it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` - add `Certifies` + doc comment
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` - add `decidableCertifies`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` - add `Refutes`,
  `refutes_of_certifies`, module-header prose
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - three inventory rows
- `FormalSystem/Metalogic/Decidability/README.md` - the `WitnessFamily/` row

**Verification**:
- `lake build` green (the generated library root imports every module under `FormalSystem/`, so
  all seven WitnessFamily modules compile).
- `lake exe mk_all --lib FormalSystem --check` green (no new module file, so this should be a
  no-op; run it to confirm).
- `lake exe lint-style` green; `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`
  green.
- `bash scripts/check-module-invariants.sh --no-build` green, including C20/C20_DECL.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` green.
- `#print axioms FormalSystem.Metalogic.Decidability.WitnessFamily.refutes_of_certifies` reports
  only `[propext, Classical.choice, Quot.sound]`.
- `Examples.lean`'s two `joint_countermodel` call sites still compile untouched.

---

### Phase 2: refutes_of_countermodel Against the Unmodified checkRaw [NOT STARTED]

**Goal**: Machine-check the composition at the level of the serialized verdict the consumer
actually reads, *before* any restructure, so the guarantee is committed at the earliest point and
becomes a regression guard for Phase 3.

**Tasks**:
- [ ] Re-read `BimodalTools/CertificateImport.lean`'s `checkRaw` (currently the four-way
      `if ! @Decidable.decide …` chain) immediately before editing.
- [ ] Add
      `theorem refutes_of_countermodel {raw : RawCertificate} {t : Int}
      (h : checkRaw raw = .countermodel t) :
      WitnessFamily.Refutes raw.target.premises raw.target.conclusions`
      against the unmodified `checkRaw`. Proof shape verified in research probe 3: unfold, `split`
      the `if` chain (five splits, including the `mkFamily` match),
      `simp only [Bool.not_eq_true', decide_eq_false_iff_not, not_not]`, then `of_decide_eq_true`
      on each of the four conditions and `refutes_of_certifies`.
- [ ] Doc-comment the theorem with what it does and does not say: the implication is
      kernel-checked once at build time; the per-certificate hypothesis comes from compiled
      decision procedures.
- [ ] Confirm `#print axioms` on the new theorem is `[propext, Classical.choice, Quot.sound]`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - add `refutes_of_countermodel` (no existing declaration
  changes, no signature changes)

**Verification**:
- `lake build BimodalTools --wfail` green (the module builds and emits no warning).
- `#print axioms BimodalTools.CertificateImport.refutes_of_countermodel` reports only
  `[propext, Classical.choice, Quot.sound]`.
- No existing declaration in the file changed: `git diff` shows additions only.
- `bash scripts/check-module-invariants.sh --no-build` green (line-shift check for citations into
  this file).

---

### Phase 3: Restructure the Accepting Branch [NOT STARTED]

**Goal**: Make the accepting branch a term of the existence type that cannot be written without
the four hypotheses in scope, with `checkRaw`'s type, behavior and cost unchanged.

**Tasks**:
- [ ] Re-read the current `checkRaw` and `CheckResult` immediately before editing.
- [ ] Add `inductive CheckOutcome (raw : RawCertificate)` whose accepting constructor is
      `| countermodel (time : Int)
      (entails : WitnessFamily.Refutes raw.target.premises raw.target.conclusions)`, with
      `rejected` and `error` mirroring `CheckResult`. It derives nothing (it carries a `Prop`
      field).
- [ ] Add `def checkCertified (raw : RawCertificate) : CheckOutcome raw` as **nested `dite`** on
      the four conditions individually — the same order and short-circuit behavior as today, each
      localization scan left in its own branch — with the accepting branch applying
      `refutes_of_certifies` to the four hypotheses the `dite`s bind.
- [ ] Add `def CheckOutcome.erase : CheckOutcome raw → CheckResult`, the forgetful map to the
      serializable type.
- [ ] Redefine `checkRaw raw := (checkCertified raw).erase`. `CheckResult` itself is unchanged in
      this phase, and keeps `Repr, Inhabited, DecidableEq`.
- [ ] Re-prove `refutes_of_countermodel` in its now one-line form (`cases hco : checkCertified raw`,
      `rw [hco] at h; simp [CheckOutcome.erase] at h`), keeping the statement identical so the
      Phase 2 guarantee is preserved rather than restated.
- [ ] Add a temporary `#guard` asserting the restructured `checkRaw` agrees with the pre-change
      behavior on the example families (research probe 2 held `checkRaw' posRaw = checkRaw posRaw`);
      remove it, or keep it as a pinned row in the test file, before closing the phase — decide
      and record which.
- [ ] Update the `checkRaw` doc comment to describe the dependent layer and the erasure.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - `CheckOutcome`, `checkCertified`, `CheckOutcome.erase`,
  `checkRaw` redefinition, `refutes_of_countermodel` re-proof

**Verification**:
- `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` green.
- **Behavior preservation is the acceptance criterion**: every pre-existing `#guard` row in
  `Tests/BimodalToolsTest/CertificateImportTest.lean` passes unchanged — acceptance rows,
  rejection rows (each naming its obligation), error rows and round-trips — and the rejecting
  path still localizes the same failure for each rejection fixture.
- `#eval (checkRaw posRaw).toJson` still produces `{"status":"countermodel","time":0}` (the
  `acceptance` key arrives in Phase 4, not here).
- `#print axioms` on `checkRaw` and `refutes_of_countermodel`: `[propext, Classical.choice,
  Quot.sound]` only.
- `lake build` (defaults) green; `bash scripts/check-module-invariants.sh --no-build` green.

---

### Phase 4: Output Contract — the Additive acceptance Key [NOT STARTED]

**Goal**: Carry the decided-verdict / constructed-entailment distinction on the wire, additively,
with the absent-field default rule written into the protocol.

**Tasks**:
- [ ] Add `inductive Acceptance` with `| decided` and `| entailment`, `deriving Repr, Inhabited,
      DecidableEq`, doc-commented with what each value means and the reserved-for-future note that
      per-certificate kernel checking would warrant a third value (not added here).
- [ ] Change `CheckResult.countermodel (time : Int)` to
      `CheckResult.countermodel (time : Int) (acceptance : Acceptance)`; `rejected` and `error`
      unchanged. `CheckResult` keeps all three `deriving` classes.
- [ ] Update `CheckOutcome.erase` to emit `.countermodel t .entailment`.
- [ ] Extend `CheckResult.toJson`'s `countermodel` case to
      `{"status":"countermodel","time":<t>,"acceptance":"entailment"}`; leave the `rejected` and
      `error` cases byte-identical.
- [ ] Update the two `#guard` rows in `Tests/BimodalToolsTest/CertificateImportTest.lean` that
      mention `CheckResult.countermodel 0` to `CheckResult.countermodel 0 .entailment`, and add a
      row pinning the exact accepting JSON line.
- [ ] Rewrite `BimodalTools/README.md`'s "Certificate re-verification protocol" output section:
      the new key, that it appears on `countermodel` only, that `rejected`/`error` and **the input
      schema** are unchanged, and — the single most important line for the consuming side — that
      **an absent `acceptance` field must be read as `"decided"`**, so old binaries and stored
      verdicts remain valid. Follow the `"gates"` precedent the same file already records for the
      tableau bridge.
- [ ] Re-read `BimodalTools/CheckCertificateMain.lean` and update it if it pattern-matches the
      `countermodel` constructor.

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that `CheckResult.countermodel`'s only in-repo match sites
are the two `#guard` rows in `Tests/BimodalToolsTest/CertificateImportTest.lean` and
(possibly) `BimodalTools/CheckCertificateMain.lean`. Confirm at implementation time with
`grep -rn "CheckResult.countermodel\|\.countermodel" BimodalTools/ Tests/` before editing, and
treat any additional site found as part of this phase rather than a surprise.

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - `Acceptance`, `CheckResult.countermodel` arity,
  `CheckOutcome.erase`, `CheckResult.toJson`
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - two constructor rows plus one new JSON row
- `BimodalTools/README.md` - protocol output section
- `BimodalTools/CheckCertificateMain.lean` - only if it matches the constructor

**Verification**:
- Enumerated direct dependents build: `lake build BimodalTools --wfail` and
  `lake build BimodalToolsTest --wfail` green.
- `#eval (checkRaw posRaw).toJson` produces exactly
  `{"status":"countermodel","time":0,"acceptance":"entailment"}`.
- Every `rejected` and `error` JSON row in the test file is byte-identical to before.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` green;
  `bash scripts/check-module-invariants.sh --no-build` green.

---

### Phase 5: Honesty Pass on the Five Disclaimer Sites [NOT STARTED]

**Goal**: Replace "not a kernel-checked proof" with the correct, stronger-but-bounded statement at
every site that carries it, without deleting the one-sidedness disclaimer.

**Tasks**:
- [ ] `BimodalTools/CertificateImport.lean`'s module-header trust-model section: state that the
      accepting branch constructs a term of `WitnessFamily.Refutes …`; that the implication from
      the four conditions is kernel-checked at build time (`refutes_of_certifies`,
      `refutes_of_countermodel`); that the per-certificate hypothesis comes from the four compiled
      `Decidable` instances; and that the residual trust base is Lean's compiler plus this module's
      decoding. Keep "`rejected` is never a validity claim" verbatim.
- [ ] `BimodalTools/CertificateImport.lean`'s `checkRaw` doc comment: the same correction in one
      or two sentences.
- [ ] `BimodalTools/CheckCertificateMain.lean`'s "The trust model" section: same correction; keep
      the one-sidedness paragraph unchanged.
- [ ] `BimodalTools/README.md`'s "What acceptance means": same correction, and say plainly that
      this is **not** per-certificate kernel checking.
- [ ] Record, in `BimodalTools/README.md`, that the downstream payoff (the consuming repository's
      pure-Python re-checker becoming a pre-filter rather than part of the trust base) is
      **jointly gated** on this change *and* a Lean-side parse echo compared against the bytes
      sent, which is separate work.
- [ ] Do not introduce any `file.lean:NNN` citation in the new prose (C20); cite names.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly five disclaimer sites
(`CertificateImport.lean` module header, `CertificateImport.lean`'s `checkRaw` doc comment,
`CheckCertificateMain.lean`'s trust-model section, `BimodalTools/README.md`'s "What acceptance
means", and the consuming repository's `A2_GAP.md` section 9 — the last of which is out of scope
here and is handed over in Phase 6, so four are edited). Confirm the in-repo count at
implementation time with `grep -rn "kernel-checked proof" BimodalTools/ FormalSystem/ Tests/` and
treat any extra hit as part of this phase.

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - module header and `checkRaw` doc comment (comments only)
- `BimodalTools/CheckCertificateMain.lean` - trust-model section (comments only)
- `BimodalTools/README.md` - "What acceptance means" plus the jointly-gated payoff note

**Verification**:
- Diff read-through confirming every changed hunk lies inside a doc comment, a `/-! … -/` module
  block, or Markdown prose — no hunk crosses out of a comment boundary into code.
- `lake build BimodalTools --wfail` green (doc comments do elaborate; a malformed `/-!` block or a
  broken backtick reference is a real build surface here, which is why this runs despite the
  `prose` tier).
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` green (link and slash-path checks).
- `grep -rn "kernel-checked proof" BimodalTools/` returns no stale claim.

---

### Phase 6: Full Gate, Consuming-Side Hand-Off, and Follow-Up Scoping [NOT STARTED]

**Goal**: Close the task on a complete green gate set, and leave the coordination and follow-up
work written down rather than in the reader's head.

**Tasks**:
- [ ] Run the complete gate set (below) from a clean re-read of the working tree, confirming no
      sibling-task edit is mixed into this task's commits.
- [ ] Confirm the final axiom hygiene sweep: `#print axioms` on `refutes_of_certifies`,
      `refutes_of_countermodel`, `checkCertified` and `checkRaw` reports only
      `[propext, Classical.choice, Quot.sound]`; no `sorry` anywhere in the diff.
- [ ] Record the consuming-repository hand-off in the task summary (read-only findings; nothing
      in `~/Projects/ModelChecker` is edited): add `"acceptance": "decided"` to
      `_certificate_model.py`'s and `recheck`'s countermodel verdicts; keep
      `test_certificate_lean_agreement.py`'s status comparison and add an assertion that Lean
      reports `entailment` where Python reports `decided`; update `A2_GAP.md` section 9 ("The
      honesty point") and route (f), and `TRUST_PIPELINE.md`'s two "What remains" rows, to record
      the half that has landed.
- [ ] Record the follow-up scope for a human to file as a separate task: per-certificate kernel
      checking by generated-file re-elaboration (which is what would make an `acceptance` value of
      `kernel` real), gated on a feasibility measurement of kernel whnf cost on a real fixture;
      and note that the payoff is jointly gated on the canonical-wire / round-trip echo work.
- [ ] Record the two context-extension recommendations from the research report (a
      proof-carrying-verdicts pattern note, and the `decide` / `by decide` / `native_decide` /
      re-elaboration trust ladder) in the summary for a later `/learn` or `/meta` pass.

**Timing**: 0.5 hours

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (verification and recording only; the hand-off and follow-up text lives in this task's
  summary artifact under `specs/677_proof_producing_check_certificate/summaries/`)

**Verification**:
- The complete gate set, all green:
  - `lake build`
  - `lake build BimodalTools --wfail`
  - `lake build BimodalToolsTest --wfail`
  - `bash scripts/check-module-invariants.sh --no-build`
  - `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`
  - `bash scripts/readme-lint.sh FormalSystem BimodalTools`
  - `lake exe mk_all --lib FormalSystem --check`
  - `lake exe lint-style`
  - `bash scripts/check-metalogic-cycles.sh`
  - `bash scripts/check-evidence-probes.sh`
  - `bash scripts/typst-sync-check.sh` and `bash scripts/check-paper-definitions.sh` (expected
    no-ops: no Typst source is edited, and no new declaration is cited from a Typst chapter)
- `git log --oneline` shows this task's commits only, each scoped to an explicit file list.
- `git status --short` clean of unintended paths.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import BimodalTools.CertificateImport

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace WitnessFamily

variable {Gam Del : FormalSystem.Syntax.Context}

/-- The four certificate conditions, bundled at a target time. -/
def Certifies (W : WitnessFamily Gam Del) (t : ℤ) : Prop := sorry

/-- The joint existence statement a refuting certificate witnesses. -/
def Refutes (Gam Del : FormalSystem.Syntax.Context) : Prop := sorry

instance decidableCertifies (W : WitnessFamily Gam Del) (t : ℤ) :
    Decidable (W.Certifies t) := sorry

theorem refutes_of_certifies (W : WitnessFamily Gam Del) {t : ℤ}
    (h : W.Certifies t) : Refutes Gam Del := sorry

end WitnessFamily

end FormalSystem.Metalogic.Decidability

namespace BimodalTools.CertificateImport

open FormalSystem.Metalogic.Decidability

theorem refutes_of_countermodel {raw : RawCertificate} {t : Int}
    (h : checkRaw raw = .countermodel t) :
    WitnessFamily.Refutes raw.target.premises raw.target.conclusions := sorry

end BimodalTools.CertificateImport
```

Two notes on this block, both deliberate:

- `Certifies` and `Refutes` are pinned as *named* declarations rather than by their unfolded
  bodies, because the bodies are fixed by Phase 1's tasks (the four-way conjunction in the
  instances' evaluation order; `joint_countermodel`'s conclusion verbatim) and restating them
  here would duplicate a definition this plan already fixes in one place.
- `refutes_of_countermodel` is pinned in its **Phase 2 arrival form**, matching the current
  `CheckResult.countermodel (time : Int)`. Phase 4 widens that constructor, at which point the
  identical implication is stated as
  `(h : checkRaw raw = .countermodel t a) : WitnessFamily.Refutes …` with an added
  `{a : Acceptance}` binder. The guarantee is unchanged across that widening; only the
  constructor's arity moves.

## Testing & Validation

- [ ] Every pre-existing `#guard` row in `Tests/BimodalToolsTest/CertificateImportTest.lean`
      passes: acceptance rows, each rejection row still naming its own obligation, error rows, and
      the wire round-trips.
- [ ] The two `CheckResult.countermodel 0` rows are updated to `CheckResult.countermodel 0 .entailment`
      and pass, plus one new row pinning the exact accepting JSON line.
- [ ] `#eval (checkRaw posRaw).toJson` = `{"status":"countermodel","time":0,"acceptance":"entailment"}`.
- [ ] Rejecting-path localization is unchanged: each rejection fixture produces the same
      `failed[].condition` and the same position/formula fields as before Phase 3.
- [ ] `#print axioms` on `refutes_of_certifies`, `refutes_of_countermodel`, `checkCertified` and
      `checkRaw`: `[propext, Classical.choice, Quot.sound]` only — no `sorryAx`, no
      `Lean.ofReduceBool`.
- [ ] No `sorry` and no new axiom anywhere in the diff.
- [ ] The full gate set in Phase 6, all green.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` — `Certifies`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` — `decidableCertifies`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` — `Refutes`,
  `refutes_of_certifies`, module-header prose
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
  `FormalSystem/Metalogic/Decidability/README.md` — inventory rows
- `BimodalTools/CertificateImport.lean` — `Acceptance`, `CheckOutcome`, `checkCertified`,
  `CheckOutcome.erase`, `checkRaw` redefinition, `refutes_of_countermodel`, corrected trust-model
  prose
- `BimodalTools/CheckCertificateMain.lean` — corrected trust-model section
- `BimodalTools/README.md` — extended protocol section (new key, absent-field default rule,
  corrected acceptance meaning, jointly-gated payoff note)
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — updated and added `#guard` rows
- `specs/677_proof_producing_check_certificate/summaries/01_*-summary.md` — execution summary
  carrying the consuming-repository hand-off, the follow-up scope, and the two context-extension
  recommendations

## Rollback/Contingency

Every phase is a separate commit scoped to an explicit file list, so the natural rollback is
`git revert` of the phase commits in reverse order — no working-tree-discarding command is needed,
which matters on this shared tree where three sibling tasks are in flight.

Phase-specific fallbacks, in order of preference:

- **Phase 4 breaks a consumer expectation**: revert Phase 4 alone. Phases 1–3 stand on their own —
  `refutes_of_countermodel` already machine-checks the composition, and the wire is byte-identical
  to today's. The task's core deliverable survives without the output-contract extension.
- **Phase 3 cannot be made behavior-identical**: revert Phase 3 and keep Phases 1–2. The
  composition is still kernel-checked (against the unmodified `checkRaw`), which is why Phase 2
  is sequenced first. Report the divergence rather than shipping a changed verdict.
- **Phase 1 trips an unexpected instance-resolution or elaboration regression elsewhere**: revert
  and re-land `decidableCertifies` as a plain `def` plus a local `letI`/`haveI` at the single use
  site, rather than a global `instance`.

If a genuine working-tree rollback is ever required (rather than a revert), take the snapshot
first per `context/contracts/recovery.md`'s rollback rung, including its out-of-scope override
flag for the deliberate whole-tree case. Do not emit a bare default-mode `git-snapshot.sh` as a
routine start-of-phase checkpoint; an ordinary defensive checkpoint before risky work uses
`--no-revert`.
