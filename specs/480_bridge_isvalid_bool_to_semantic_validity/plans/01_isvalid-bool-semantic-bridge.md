# Implementation Plan: Bridge `isValid`'s `Bool` to Semantic Validity

- **Task**: 480 - bridge_isvalid_bool_to_semantic_validity
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/480_bridge_isvalid_bool_to_semantic_validity/reports/01_isvalid-bool-semantic-bridge.md`
- **Artifacts**: plans/01_isvalid-bool-semantic-bridge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task is routine engineering, and the research dispatch has already reduced it further: every
theorem in scope was written, compiled against the current tree with `lake env lean`, and checked
with `#print axioms` — all sorry-free, all depending only on `[propext, Classical.choice,
Quot.sound]`. What remains is transcription into the tree, the required narrowing of two module
docstrings that currently assert no `isValid`-shaped statement exists, and the final gate. Scope
is roughly 60 lines of Lean plus prose in two files. Definition of done: `sound_of_isValid` and
`isValid_sound` (plus the eight verified corollaries) land in `Correctness.lean` sorry-free,
`lake build` is green, `#print axioms` on each new theorem shows exactly
`[propext, Classical.choice, Quot.sound]`, and no docstring in the tree still claims the sound
direction is unwritten.

### Research Integration

Three findings from the report shape this plan and each of them *reduces* risk rather than
adding work:

1. **The core lemma is about `DecisionResult`, not `isValid`.** `sound_of_isValid
   (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ` covers every entry point at once —
   `decide`, `decideBlocking`, `decideAuto`, `decideAutoAdaptive` — because they all return the
   same result type. `isValid_sound` is then a one-line corollary. Proving directly against
   `isValid`'s unfolding would yield a weaker lemma needing re-proof for `decideBlocking`.
2. **The conclusion is unrelativized `⊨ φ`, forced by the types.** `DecisionResult.valid` carries
   `⊢ φ` = `DerivationTree FrameClass.Base [] φ` regardless of which `fc` was passed, so
   `isValid φ .Dedekind = true` yields validity over *all* task frames. The three
   frame-class-relativized forms are free corollaries via the already-landed
   `Validity.valid_implies_*` monotonicity lemmas.
3. **The docstring amendments are blocking, not polish.** `Correctness.lean:98-105` currently
   reads "No such statement is written here until it can be proved" and
   `Decidability.lean:144-147` says the `isValid`-shaped statement is open. Both refer to the
   *biconditional*; landing the sound direction makes that prose a self-contradicting tree unless
   it is narrowed to say the *completeness* direction alone remains owed.

The report also records the one real pitfall — an unrestricted `simp at h` on the `isSatisfiable`
hypothesis exceeds `maxRecDepth` because `simp` tries to evaluate the enclosed decision-procedure
call — and the verified workaround (`simp only [isSatisfiable, decide_eq_false_iff_not, not_not]
at h`). Raising `maxRecDepth` is explicitly not the fix.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Land `sound_of_isValid` as the core `DecisionResult`-level lemma, sorry-free.
- Land `isValid_sound` and the eight verified corollaries (`decide_isValid_sound`,
  `isTautology_sound`, `isContradiction_sound`, `not_isSatisfiable_sound`,
  `isValid_validDense`, `isValid_validDiscrete`, `isValid_validDedekindDense`,
  `decideBlocking_isValid_sound`, `decideAuto_isValid_sound`).
- Narrow the two module docstrings so the tree stops asserting that no `isValid`-shaped sound
  statement exists, while preserving the `validity_decidable` /
  `validity_has_decision_procedure` retirement narrative intact.
- Record the negative finding (`isKnownValid` is not a sound-direction hypothesis) as a docstring
  note at the point of use.
- Full gate: `lake build` green, `#print axioms` clean on all new theorems, no new `sorry` or
  `axiom` anywhere in the tree.

**Non-Goals**:
- The biconditional `isValid φ fc = true ↔ ⊨ φ`. That needs `valid_iff_allClosed` and is task
  430's obligation.
- Any of the four `Decidable (⊨ φ)` / `Decidable (ValidDense φ)` / … instances. Each needs the
  biconditional; only their sound halves are produced here.
- `isKnownValid = true → ⊨ φ`. Not provable today — `isKnownValid` is true on
  `extractionFailed`, which carries no `⊢ φ` witness. A phase proposing it would be proposing
  open mathematics under an engineering label.
- A `sound_of_getProof?` variant. It compiles but trips the `unusedVariables` linter and is
  subsumed by `sound_of_isValid`.
- Any change to `decide`, `decideBlocking`, `decideAuto`, or the tableau engine.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scope creep into task 430 (stating the biconditional or an `isKnownValid` variant) | H | M | Non-Goals above are explicit; Phase 3's gate checks that the added declaration set is exactly the ten named theorems |
| Docstring amendment skipped, leaving a self-contradicting tree | H | M | Phases 1 and 2 both carry the prose edits as checklist items; Phase 3's gate greps for the retired assertions |
| `simp at h` blow-up on `not_isSatisfiable_sound` | M | L | Report supplies the verified `simp only [...]` form; transcribe it verbatim, do not raise `maxRecDepth` |
| Transcription drift from the verified snippets (renaming, re-ordering hypotheses) | M | L | Copy the report's code blocks verbatim; any deviation must be re-verified with `#print axioms` before the phase closes |
| Prose edit crossing out of the `/-! … -/` module-docstring boundary | M | L | Lean parses module docstrings; both prose phases build the touched module rather than relying on diff read-through alone |
| `Decidability.lean` is outside the declared `file_scope` | L | H (certain) | Make the three-line prose edit and record the scope extension explicitly in the implementation summary, per the report's recommended handling |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2's
prose asserts what Phase 1 lands, and Phase 3 gates both.

---

### Phase 1: Land the bridge theorems and amend `Correctness.lean` prose [NOT STARTED]

**Goal**: The ten verified theorems exist in `Correctness.lean`, sorry-free, with docstrings, and
that file's own prose no longer contradicts them.

**Tasks**:
- [ ] Insert the theorems into `FormalSystem/Metalogic/Decidability/Correctness.lean` immediately
      after `decide_sound'` (after line 71), inside the existing
      `namespace FormalSystem.Metalogic.Decidability` and its existing `open` block. No new
      imports.
- [ ] Core lemma `sound_of_isValid {φ : Formula} (r : DecisionResult φ) (h : r.isValid = true) :
      ⊨ φ` — four-way `cases r`; `.valid proof => exact decide_sound φ proof`; the other three
      arms `simp [DecisionResult.isValid] at h`.
- [ ] Bool-API siblings: `isValid_sound`, `decide_isValid_sound`, `isTautology_sound`,
      `isContradiction_sound`, `not_isSatisfiable_sound`. Transcribe verbatim from the report,
      including the targeted `simp only [isSatisfiable, decide_eq_false_iff_not, not_not] at h`
      in `not_isSatisfiable_sound`.
- [ ] Frame-class-relativized corollaries: `isValid_validDense`, `isValid_validDiscrete`,
      `isValid_validDedekindDense`, each via the corresponding `Validity.valid_implies_*`.
- [ ] Alternate-entry-point corollaries: `decideBlocking_isValid_sound`,
      `decideAuto_isValid_sound`.
- [ ] Docstring on `sound_of_isValid` recording the negative finding: `isKnownValid` is **not** a
      sound-direction hypothesis, because `extractionFailed` carries no witness. This is the F1
      conflation guard, stated at the point of use.
- [ ] Amend `Correctness.lean:16-24` (module "Main Theorems" list): add `sound_of_isValid` /
      `isValid_sound` as the Bool-API bridge.
- [ ] Amend `Correctness.lean:98-105` ("What is still owed, and is deliberately not stated
      here"): narrow it so the **sound direction is recorded as landed** and what remains owed is
      the **completeness direction** (`⊨ φ → isValid φ fc = true`), hence the biconditional and
      the four `Decidable` instances. Keep the `validity_decidable` /
      `validity_has_decision_procedure` retirement narrative intact — it documents a different
      defect.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts exactly **ten** new theorems, **one** modified file, and
**no** new imports. Confirm at implementation time by (a) diffing the added declaration names
against the ten listed above, (b) `git status --short` showing only
`FormalSystem/Metalogic/Decidability/Correctness.lean` modified, and (c) grepping the diff for
`^import` — expect zero hits. The `interface` tier is chosen over `local` because this phase adds
public declarations to a namespace that a downstream module imports, so name-ambiguity breakage
is possible even though no existing signature changes; the enumerated direct-dependent set is a
single file, `FormalSystem/Metalogic/Decidability.lean` (verified: the only in-tree `import
FormalSystem.Metalogic.Decidability.Correctness`).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Correctness.lean` — add ten theorems after line 71 with
  docstrings; amend module docstring lines 16-24 and the "What is still owed" paragraph at
  98-105.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Correctness` succeeds.
- `lake build FormalSystem.Metalogic.Decidability` (the enumerated direct dependent) succeeds.
- `#print axioms` on each of the ten new theorems shows exactly
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
- `grep -c sorry FormalSystem/Metalogic/Decidability/Correctness.lean` is unchanged from baseline
  (1, the prose phrase "sorry-free" at line 96 — plus any new prose occurrences the amendment
  introduces, which must be confirmed to be prose).

---

### Phase 2: Narrow the `Decidability.lean` prose [NOT STARTED]

**Goal**: The parent module's docstring stops asserting that no `isValid`-shaped statement is
written, and the scope extension is recorded.

**Tasks**:
- [ ] Amend `FormalSystem/Metalogic/Decidability.lean:144-147`: narrow the bullet so that the
      **sound direction** (`isValid φ fc = true → ⊨ φ`) is recorded as landed in
      `Correctness.lean`, and only `valid_iff_allClosed`, the biconditional, and the four
      `Decidable (⊨ φ)` instances remain **open**. Preserve the existing cross-reference to
      `Correctness.lean`'s retirement section.
- [ ] Note in the working record that this file is **outside the declared `file_scope`**
      (`Correctness.lean`, `DecisionProcedure.lean`), so the implementation summary must state the
      scope extension explicitly. The alternative — leaving the contradiction in the tree — is not
      acceptable; the report treats this as required, not optional.

**Timing**: 15 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts a **prose-only** edit confined to **one** file and
roughly **three to five** lines. Confirm at implementation time with `git diff --stat` (one file)
and by reading the diff to check every changed hunk lies inside the `/-! … -/` module-docstring
block. `local` rather than `prose` is deliberate: Lean parses module docstrings, so a stray `-/`
is a compile error, and the phase therefore builds the module rather than resting on diff
read-through.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability.lean` — narrow the open-obligations bullet at 144-147.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability` succeeds.
- `git diff` confirms every changed hunk is inside the module docstring.
- No occurrence of a claim that the sound direction is unwritten remains in either amended file.

---

### Phase 3: Final gate and summary [NOT STARTED]

**Goal**: Whole-tree acceptance is demonstrated with evidence, and the deliverable plus its scope
extension is written up.

**Tasks**:
- [ ] `lake build` (full tree) green.
- [ ] `#print axioms` on all ten new theorems, output captured; each exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Tree-wide audit: no new `sorry` and no new `axiom` anywhere. Compare against the
      pre-change baseline rather than asserting an absolute count.
- [ ] Confirm the added declaration set is exactly the ten named theorems — no biconditional, no
      `isKnownValid` variant, no `Decidable` instance (Non-Goals check).
- [ ] Write the implementation summary under `summaries/`, explicitly recording (a) the ten
      theorems, (b) the docstring amendments, (c) the `Decidability.lean` **scope extension**
      beyond the declared `file_scope`, and (d) the carry-forward note for task 430: because
      `isValid φ .Dense = true` yields *unrelativized* `⊨ φ`, the eventual biconditional at
      `fc = .Dense` cannot take the naive form `isValid φ .Dense = true ↔ ⊨ φ`.

**Timing**: 30 minutes

**Depends on**: 1, 2

**Verification Tier**: full

**Files to modify**:
- `specs/480_bridge_isvalid_bool_to_semantic_validity/summaries/01_isvalid-bool-semantic-bridge-summary.md` — new.

**Verification**:
- Full `lake build` exit 0.
- Captured `#print axioms` output for all ten theorems, `sorryAx`-free.
- `sorry`/`axiom` diff against baseline shows no new occurrences.
- Summary file exists and names the scope extension.

---

## Testing & Validation

- [ ] `lake build` completes with exit 0 across the whole tree.
- [ ] `lake build FormalSystem.Metalogic.Decidability.Correctness` completes with exit 0.
- [ ] `#print axioms FormalSystem.Metalogic.Decidability.sound_of_isValid` (and the other nine)
      each report exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] No `sorryAx` in any `#print axioms` output.
- [ ] No new `sorry` or `axiom` occurrence anywhere in the tree relative to baseline commit.
- [ ] Neither `Correctness.lean` nor `Decidability.lean` still asserts that no `isValid`-shaped
      sound statement is written.
- [ ] The `validity_decidable` / `validity_has_decision_procedure` retirement narrative is still
      present and unmodified in substance.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Correctness.lean` — ten new sorry-free theorems plus
  amended module docstring.
- `FormalSystem/Metalogic/Decidability.lean` — narrowed open-obligations bullet (scope extension,
  to be recorded).
- `specs/480_bridge_isvalid_bool_to_semantic_validity/summaries/01_isvalid-bool-semantic-bridge-summary.md`
  — implementation summary including the scope-extension record and the task-430 carry-forward.

## Rollback/Contingency

All changes are additive within one already-built module plus a three-line prose edit in a second.
`git checkout -- FormalSystem/Metalogic/Decidability/Correctness.lean
FormalSystem/Metalogic/Decidability.lean` restores the baseline (take a snapshot via
`bash .claude/scripts/git-snapshot.sh 480` first if the tree is dirty). No downstream module
consumes the new theorems, so reverting cannot cascade. If a transcribed proof unexpectedly fails
to compile, the fallback is to land `sound_of_isValid` and `isValid_sound` alone — those two are
the acceptance criterion — and move the remaining corollaries to a follow-up, rather than
weakening a statement to make it go through.
