# Implementation Plan: Land the Saturation-vs-Completion verdict in the library

- **Task**: 661 - Settle the Saturation vs Completion question by probe, and judge the outcome against a primitives-level foundation criterion
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: 660 (completed); 657 (frame-constraint audit, R1/R4 origin)
- **Research Inputs**: `specs/661_settle_saturation_vs_completion_foundation/reports/01_saturation-vs-completion-verdict.md`
- **Artifacts**: plans/01_settle-saturation-vs-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research settled the mathematics and the user settled the editorial call: *Completion* is a
**strict** weakening of *Saturation* (machine-checked separating frame), and `def:frame`'s fourth
constraint should become the `Fib`-free *Completion* clause (R4). Manuscript edits are explicitly
out of scope for this task, so what this plan lands is the **Lean-side and ledger-side** half:
state *Completion* at exactly the primitives level `def:frame`'s other three constraints are
stated at, promote the two sorry-free probes out of `specs/` and into the library beside the
existing independence matrix, correct every docstring that still records the converse as open,
and discharge the one ARGUED step (finitary *Completion* from *Compositionality* + *Seriality*).
Done means: `lake build` green and sorry-free, both witnesses compiling warning-free under the
package linter set, no in-tree prose asserting the converse is open, and the full gate set
passing with `check-paper-definitions.sh` confirming no pinned anchor moved.

### Research Integration

The report supplies two probes already compiled end-to-end against the built library
(`lake env lean`, exit 0) and re-run warning-free under
`-D weak.linter.mathlibStandardSet=true -D autoImplicit=false`, with `#print axioms` reporting
only `propext`, `Classical.choice`, `Quot.sound`. This plan therefore **transcribes verified
proofs**, it does not propose candidate proofs. Five findings shape the phase structure:

- **The primary probe answered negatively and the converse was settled anyway.** The rational
  carrier fails *Completion* too (`not_rel_coherentCompletion`), so it is not the separator; a
  different frame — `W = ℚ`, `D = ℤ`, `w ⇒_x v` iff `|v − w| ≤ |x|` — satisfies *Seriality*,
  *Compositionality*, *Limit* and *Completion* and fails *Saturation*. Both results are wanted in
  the library, for opposite reasons: one stops the next reader re-running a dead probe, the other
  is the theorem.
- **Both probes transcribe `CoherentCompletion` locally as a `CoherentCompletionRel`**, because
  neither relation carries a `FrameOver` wrapper. Promoting that local transcription twice would
  duplicate the condition a third time. Phase 1 removes the need by landing the bare-relation form
  in the library, beside `TaskFrame.Saturation`/`Serial`/`Compositional`/`Limit` — which is also
  precisely what the foundation criterion asks for, so the phase is the criterion's payoff and not
  merely a refactor.
- **`completion_iff_coherentCompletion` is a recognition lemma** (two constructor applications,
  zero frame constraints), so the `PartialHistory`-shaped form carries no definitional dependency
  on histories. Nothing in Phase 1 needs to move that lemma; it survives the redefinition
  unchanged because the redefinition is definitional.
- **The one vocabulary mismatch is `Fib`.** The Lean conclusion is already `Fib`-free; R4's drafted
  LaTeX is not. Restating the LaTeX is a manuscript edit and therefore a NON-GOAL here — but the
  Lean-side docstring must record that the bare form is the recommended clause, so the manuscript
  pass has an in-tree anchor to cite.
- **Finding 4's middle step is ARGUED, not CHECKED.** `completion_of_hasNearest` consumes its `hN`
  hypothesis at exactly one place (`obtain ⟨hlow, hhigh⟩ := hN τ.domain z`), so a pointwise
  hypothesis-weakening plus a `Set.Finite → nearest` lemma discharges it. Phase 4 does exactly
  that and nothing more; it is a hypothesis weakening, not new mathematics.

### Prior Plan Reference

No prior plan for this task. Task 657's audit is a research input, not a plan: its R1
recommendation was explicitly conditioned on the converse being unknown, and that condition no
longer holds, so its recommendation is superseded rather than inherited.

### Roadmap Alignment

No `roadmap_path` was provided with this dispatch and no roadmap flag was set; `specs/ROADMAP.md`
was not consulted.

### Settled Decision Carried Into This Plan

`specs/661_settle_saturation_vs_completion_foundation/.decisions.json` records the cycle-4 answer:
**R4** — replace `def:frame`'s fourth constraint with the `Fib`-free *Completion* clause, delete
the opening directed-family clause, and demote *Saturation* to a remark that keeps the ball-space
footnote. That decision governs the manuscript, which this task does not touch. Its consequence
for this plan is narrow and specific: the Lean tree must make R4's clause **statable and
witnessed** at the primitives level, and must stop asserting that the strictness question is open.
Do not re-ask this question.

## Goals & Non-Goals

**Goals**:

- State *Completion* over a bare task relation, in `TaskFrame`'s own "frame axioms in
  bare-relation form" section, so that `def:frame`'s candidate fourth constraint mentions nothing
  but `W`, `D` and `⇒` — no `Fib`, no `PartialHistory`, no fiber/segment classification.
- Land both probes in the library as permanent witnesses, stated against that library predicate
  rather than against a locally re-transcribed copy of it.
- Leave no in-tree prose asserting `Completion → Saturation` is open, and leave the strictness
  verdict recorded where the next reader of `Extension/Completion.lean` will meet it.
- Discharge the report's one ARGUED step: finitary *Completion* from *Compositionality* +
  *Seriality*, so the claim "the infinitary quantifier is essential" rests on two machine-checked
  endpoints rather than one.
- Keep the tree green, sorry-free and warning-free at every phase boundary, with the theorem
  index, module READMEs and invariant gates updated.
- Declarations pinned by `## Lean Challenge Statements`: `TaskFrame.Completion`,
  `PartialHistory.NearestAt`, `PartialHistory.completion_of_nearest_at`,
  `PartialHistory.completion_of_finite_domain`,
  `StateTopology.RationalTwoOrigins.not_rel_completion`, `StateTopology.SeparatingFrame.srel`,
  `StateTopology.SeparatingFrame.srel_serial`,
  `StateTopology.SeparatingFrame.srel_compositional`,
  `StateTopology.SeparatingFrame.srel_limit`, `StateTopology.SeparatingFrame.srel_completion`,
  `StateTopology.SeparatingFrame.not_srel_saturation`.

**Non-Goals**:

- **Any manuscript edit.** The task description says so outright, and `def:frame` is a pinned
  anchor with a recorded checksum in `docs/reference/paper-definitions-of-record.md`. Nothing in
  this plan may touch a `verbatim:` block or a `sha256:` line; Phase 7 runs
  `scripts/check-paper-definitions.sh` to prove it did not.
- **Adopting R4 inside the Lean frame API.** Turning `FrameOver.IsRegular`'s `saturation` field
  into a `completion` field, and supplying *Completion* analogues at the five transport sites the
  report enumerates (`FrameOver.rev_isRegular`, `FrameOver.map`, `FrameOver.translationProduct`,
  `regionFrame_saturation`, `zTaskFrameV2_saturation`), is a separate, larger change that the task
  description does not ask for. It is a follow-up task; Phase 7 records the recommendation.
- **Searching for a dense-time separator.** Finding 1's pinching argument kills the whole family;
  the separation is a discreteness phenomenon. The reason is recorded in a docstring (Phase 2) so
  the search is not re-run, and that is the entire treatment it gets.
- **Weakening or restating any existing theorem.** Phase 1 redefines `CoherentCompletion` to be
  *definitionally* the bare form; no statement changes, and any edit that would change one is out
  of scope, not a judgement call.
- **Wrapping either witness as a `FrameOver`.** Neither relation carries the reflection law a
  wrapper needs. The witnesses are bare-relation certificates, which is exactly the level
  `def:frame` states its constraints at, and the existing packaging-asymmetry note is extended to
  cover them rather than being quietly outgrown.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `TaskFrame.Completion` collides with `PartialHistory.Completion` at a site that has both in scope | M | L | Verified against the Lean 4 resolver during planning: the enclosing namespace wins over an `open`ed namespace, and `PartialHistory.Completion` is referenced outside its own module only in docstrings (`Extension.lean`, `Extension/Step.lean`). If an ambiguity error does appear, qualify at the site — do NOT rename the predicate, since the name is the point |
| Adding a `def` to `FormalSystem/Semantics/TaskFrame.lean` triggers a whole-library rebuild | M | H | Expected and accepted, not avoided: TaskFrame's bare-relation axiom section is the honest home for the fourth constraint, and its docstring's claim that "all four live here" would become false if the fifth were sited downstream. Phase 1 is budgeted for the rebuild and does nothing else, so the cost is paid once |
| `ConstraintWitnesses.lean` importing `Extension/Completion.lean` introduces an instance diamond with the topology imports (`Preorder ℤ` has bitten this tree twice — see `docs/ARCHITECTURE.md`) | M | L | The import is needed only for `hasNearest_int`. If any diamond or elaboration slowdown appears, fall back to inlining the ℤ nearest-times argument from `Int.exists_greatest_of_bdd`/`exists_least_of_bdd` (~12 lines, one Mathlib import, no intra-library edge) — the fallback is pre-authorised, so Phase 3 does not stall on it |
| `ConstraintWitnesses.lean` crosses the 1500-line `longFile` limit set in `lakefile.toml` | L | M | Measured hypothesis, confirmed in Phase 3 (see its Scope Hypothesis). If crossed, add an in-source `set_option linter.style.longFile N` baseline after the module docstring, exactly as `StateTopology/Counterexamples.lean` does — the sanctioned form under invariant C30. Do NOT split into a new sibling module: `docs/ARCHITECTURE.md` records that nothing under `FormalSystem/` imports these four modules, and a new sibling importing `ConstraintWitnesses` would falsify that |
| A promoted probe carries its own now-stale prose into the library | M | H | `CompletionRationalTwoOrigins.lean`'s module docstring literally says "`Completion → Saturation` stays open", which the separating frame refutes. Phase 2 rewrites that paragraph as part of the promotion, and Phase 5 sweeps for the sentence pattern across the tree rather than trusting per-phase memory |
| A new theorem-index row fails invariant C15 | L | M | C15's second assertion requires the named declaration's own `/--` doc comment to carry a `Paper:` line whose value is the row's anchor or `—` plus a one-clause reason. Phase 6 writes the `Paper:` line and the row in the same sub-step, never the row alone |
| `unusedSectionVars` fires on the new `TaskFrame.Completion` because it uses only `Sub D` | L | L | It is a `def`, not a theorem, and `Saturation` sits in the same variable block. If the linter does fire, scope an `omit` exactly as the neighbouring `Fib`/`Seg` lemmas already do — never a blanket `set_option`, which invariant C30 forbids |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 8 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5, 6 | 3, 4 |
| 5 | 7 | 5, 6 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are deliberately serialised
although both are witness promotions: they edit the same file.

### Phase 1: State *Completion* over a bare task relation [NOT STARTED]

**Goal**: Make `def:frame`'s candidate fourth constraint expressible in the primitives `W`, `D`
and `⇒` alone, at the same level the other three are already stated, and make
`PartialHistory.CoherentCompletion` definitionally equal to it so nothing downstream changes.

**Tasks**:

- [ ] In `FormalSystem/Semantics/TaskFrame.lean`, inside the `## The frame axioms in bare-relation
      form` section (the block containing `Saturation`, `Serial`, `Interpolates`, `Compositional`,
      `Limit`), add `def Completion {W : Type} (R : W → D → W → Prop) : Prop` with the body
      transcribed from `PartialHistory.CoherentCompletion`: quantify over `X : D → Prop`, a
      nonemptiness witness `∃ t, X t`, a family `w : (t : D) → X t → W`, the coherence hypothesis
      `∀ s t hs ht, R (w s hs) (t - s) (w t ht)`, and a target `z : D`, concluding
      `∃ u : W, ∀ t ht, R (w t ht) (z - t) u`.
- [ ] Give it a docstring in the idiom of its four neighbours, recording: (a) that this is the
      `Fib`-free form of R4's proposed fourth constraint, mentioning only `W`, `D` and `⇒`; (b)
      that a coherent family indexed by a nonempty `X` **is** a partial history
      (`def:world-history`), so the condition is extensionally about partial histories while
      naming none — which is what lets it precede `def:world-history` without a forward reference;
      (c) that it is strictly weaker than *Saturation*, citing
      `StateTopology.SeparatingFrame.not_srel_saturation` as the witness (a forward citation in
      prose only, landed in Phase 3); and (d) a `Paper:` line — `def:frame#Saturation` is the
      wrong anchor, so use `—` plus the one-clause reason that the clause is a proposed
      replacement not yet in the pinned `def:frame`.
- [ ] Update the section docstring that currently reads "All four live here" so it remains true
      once a fifth predicate is present — it should say the four `def:frame` constraints plus the
      proposed replacement for the fourth.
- [ ] In `FormalSystem/Semantics/Extension/Completion.lean`, redefine
      `PartialHistory.CoherentCompletion (F : TaskFrame) : Prop := TaskFrame.Completion F.TaskRel`
      and confirm `completion_iff_coherentCompletion` still compiles unchanged (it should: the
      redefinition is definitional and the proof is two constructor applications per direction).
      Do not restate or reprove it.
- [ ] Add `theorem coherentCompletion_iff_rel : CoherentCompletion F ↔ TaskFrame.Completion
      F.TaskRel := Iff.rfl`, so the bridge is citable by name rather than by unfolding.
- [ ] Update the module docstring's two-form paragraph (`## The two forms of *Completion*`, and
      the `## What this module establishes` list) to name the new bare predicate and say where it
      lives.
- [ ] Run `lake build`; record the job count and confirm zero `error:` and zero `warning:` lines.

**Timing**: 1.5 hours (most of it the rebuild)

**Depends on**: none

**Verification Tier**: full

**Files to modify**:

- `FormalSystem/Semantics/TaskFrame.lean` — add `TaskFrame.Completion` and its docstring; adjust
  the "all four live here" section docstring
- `FormalSystem/Semantics/Extension/Completion.lean` — redefine `CoherentCompletion` in terms of
  it, add `coherentCompletion_iff_rel`, update the module docstring

**Verification**:

- `lake build` exits 0, zero errors, zero warnings.
- `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false
  FormalSystem/Semantics/Extension/Completion.lean` is silent.
- `#print axioms FormalSystem.Semantics.PartialHistory.completion_iff_coherentCompletion` is
  unchanged from its pre-phase value.

---

### Phase 2: Promote the rational-carrier *Completion* failure [NOT STARTED]

**Goal**: Record in the library that the rational two-origin relation fails *Completion* as well
as *Saturation* — the primary probe's answer — together with the dense-time pinching argument that
makes it a general obstruction rather than one dead end.

**Tasks**:

- [ ] Transcribe `specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean`
      into `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, into the existing
      `namespace RationalTwoOrigins`, immediately after `not_rel_saturation`.
- [ ] **Drop the probe's local `CoherentCompletionRel` definition entirely** and state the result
      as `theorem not_rel_completion : ¬ TaskFrame.Completion rel`, against Phase 1's library
      predicate. The rename from `not_rel_coherentCompletion` is deliberate: it matches
      `not_rel_saturation`'s naming and the library predicate's name.
- [ ] Carry over the supporting declarations unchanged in content: `nt`, `nt_succ`, `nt_inv`,
      `nt_one_le`, `nt_sq_gt`, `nt_err`, `nt_succ_le`, `nt_antitone`, `nt_le_start`, `nt_step`,
      `tm`, `phi`, `phi_le_succ`, `phi_mono`, `phi_pos`, `pow_half_inj`, `key`, `stateAt`.
- [ ] Add whatever Mathlib import the transcription needs that the target module lacks (the probe
      carries `Mathlib.Algebra.Order.Archimedean.Basic`); add nothing it does not need.
- [ ] **Rewrite the stale paragraph.** The probe's module docstring says the rational carrier is
      not a separator "and `Completion → Saturation` stays open". The second clause is false. The
      promoted docstring must instead say: the rational carrier is not the separator because it
      fails both constraints; the converse is settled negatively by `SeparatingFrame` (Phase 3);
      and — the load-bearing part — over a **dense** temporal order, any coherent family whose
      times accumulate at `z` forces the witness position to the single real number `lim φ(t)`,
      because `φ` nondecreasing and `φ − id` nonincreasing pinch the admissible interval shut, so
      **no dense-time frame with a continuous-drift relation can separate the two conditions** and
      searching for one is wasted effort.
- [ ] Record the `3/2` Newton seed decision in a short comment: with seed `2` the first Newton
      step exactly equals the first time gap, leaving no slack in `phi`'s monotonicity.
- [ ] Add a `Paper:` line to `not_rel_completion`'s docstring (see Phase 6's C15 obligation).
- [ ] Run `lake build` and the linted single-file check; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: the transcription is expected to add roughly 230 lines to
`ConstraintWitnesses.lean` and to introduce exactly one new Mathlib import and zero intra-library
imports. Confirm at implementation time with `git diff --stat` on the file and by diffing the
module's `import` block against its pre-phase state; if an intra-library import turns out to be
needed, say so in the phase record rather than adding it silently.

**Files to modify**:

- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — new declarations in
  `RationalTwoOrigins`, new module-docstring paragraph, possibly one new Mathlib import

**Verification**:

- `lake build` exits 0 with zero errors and zero warnings.
- `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false
  FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` is silent.
- `#print axioms FormalSystem.Semantics.StateTopology.RationalTwoOrigins.not_rel_completion`
  reports exactly `propext`, `Classical.choice`, `Quot.sound`.
- `grep -n "stays open" FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` returns
  nothing.

---

### Phase 3: Promote the separating frame [NOT STARTED]

**Goal**: Land the theorem — a relation satisfying *Seriality*, *Compositionality*, *Limit* and
*Completion* while failing *Saturation* — so that "*Completion* is strictly weaker" is a
machine-checked library fact rather than a claim in a `specs/` report.

**Tasks**:

- [ ] Transcribe `specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean`
      into `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` as a new
      `namespace SeparatingFrame`, sited after `RationalTwoOrigins` and before the void frame.
- [ ] Drop the probe's local `CoherentCompletionRel` and state the positive result as
      `theorem srel_completion : TaskFrame.Completion srel` (renamed from
      `srel_coherentCompletion`, for the same reason as Phase 2's rename).
- [ ] Carry over `srel`, `srel_iff`, `srel_of_nonneg`, `srel_serial`, `srel_compositional`,
      `srel_limit`, `mem_sseg`, `straddle`, `lt_of_straddle`, `not_srel_saturation`, `TotalComp`
      and `not_srel_totalComp`.
- [ ] Add `import FormalSystem.Semantics.Extension.Completion` for `hasNearest_int`, with an
      import-block comment naming exactly what it is for and noting that this module is a leaf so
      the edge adds weight to nothing else. **If** the import produces an instance diamond or a
      measurable elaboration slowdown, take the pre-authorised fallback instead: inline the ℤ
      nearest-times argument from `Int.exists_greatest_of_bdd` / `Int.exists_least_of_bdd` and
      import `Mathlib.Data.Int.LeastGreatest` only. Record which route was taken.
- [ ] Write the namespace docstring to carry the three facts a reader needs: (a) *Completion*
      holds by the nearest-times argument and needs no completeness of the carrier at all; (b)
      *Saturation* fails because fibres and segments are **not indexed by times**, so a
      `⊇`-directed family of them can shrink onto a Dedekind cut even though the durations are
      integers; (c) the separation is realised over ℤ-time, precisely the region where
      `extension_of_isZTime` already shows *Saturation* is redundant for `thm:extension` — so
      *Saturation* excludes ordinary discrete-time frames with a dense state space, and
      `thm:extension` has no need of that exclusion.
- [ ] Record the `1 ≤ b` guard in a comment on `straddle`: without it `2 < b²` admits `b ≤ −2` and
      the member is empty rather than a nonempty segment. `not_rel_saturation`'s analogous family
      is protected by its `{t : ℚ // 0 < t}` subtype instead, so the guard is easy to lose when
      porting the argument to a bare-`ℚ` carrier.
- [ ] Note in the same docstring why `not_srel_totalComp` is present: `saturation_of_completion`
      (the `specs/evidence/frame-constraints-audit/` probe) proves the converse under `TotalComp` +
      *Limit*, so a separating frame **must** fail `TotalComp`; this theorem is the consistency
      check, not a stray result.
- [ ] Extend the module docstring's **packaging asymmetry** paragraph to cover the new witnesses:
      they are bare-relation certificates with no `FrameOver` wrapper, genuine at exactly the level
      `def:frame` states its constraints, and must not be read as claiming a `FrameOver` witness
      they do not have.
- [ ] Extend the module docstring's independence-matrix section with the new, fifth row: the
      *Saturation*/*Completion* separation, naming `srel_completion` and `not_srel_saturation`.
- [ ] Add `Paper:` lines to `srel_completion` and `not_srel_saturation`.
- [ ] Run `lake build` and the linted single-file check; commit.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: the transcription is expected to add roughly 250 lines, bringing
`ConstraintWitnesses.lean` to roughly 1,250–1,300 lines — under `lakefile.toml`'s `longFile` limit
of 1,500, but not by a wide margin. Confirm with `wc -l` after the edit. If the file crosses 1,500,
add an in-source `set_option linter.style.longFile N` baseline after the module docstring (the
form `StateTopology/Counterexamples.lean` already uses and invariant C30 explicitly excepts), and
do not split the module.

**Files to modify**:

- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — new `SeparatingFrame`
  namespace, one new import, extended module docstring

**Verification**:

- `lake build` exits 0 with zero errors and zero warnings.
- `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false
  FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` is silent.
- `#print axioms` on each of `srel_serial`, `srel_compositional`, `srel_limit`, `srel_completion`,
  `not_srel_saturation`, `not_srel_totalComp` reports exactly `propext`, `Classical.choice`,
  `Quot.sound`.
- `wc -l FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` is recorded, and a
  `longFile` baseline is present if and only if the count exceeds 1,500.

---

### Phase 4: Discharge the finitary-*Completion* claim [NOT STARTED]

**Goal**: Turn the report's one ARGUED step into a machine-checked one, so the claim that
*Completion*'s infinitary quantifier is essential rests on two checked endpoints: the finitary
form follows from *Compositionality* + *Seriality*, and the rational carrier satisfies
*Compositionality* while failing *Completion*.

**Tasks**:

- [ ] In `FormalSystem/Semantics/Extension/Completion.lean`, add the pointwise predicate
      `def NearestAt {D : Type} [LinearOrder D] (X : D → Prop) (z : D) : Prop` carrying the two
      conjuncts currently written inline inside `HasNearest`.
- [ ] Redefine `HasNearest D := ∀ (X : D → Prop) (z : D), NearestAt X z`. Confirm `hasNearest_int`
      and `hasNearest_of_succPred` still compile with their existing proofs — the redefinition is
      definitional, so `intro X z; constructor` should continue to work. If either breaks, insert
      an `unfold NearestAt` rather than restating the theorem.
- [ ] Add `theorem completion_of_nearest_at (τ : PartialHistory F) (z : F.Duration)
      (hN : NearestAt τ.domain z) (hcomp : TaskFrame.Compositional F.TaskRel)
      (hser : TaskFrame.Serial F.TaskRel) : ∃ u : F.WorldState, ∀ (t : F.Duration)
      (ht : τ.domain t), F.TaskRel (τ.states t ht) (z - t) u`, by lifting
      `completion_of_hasNearest`'s body verbatim and replacing its single
      `obtain ⟨hlow, hhigh⟩ := hN τ.domain z` with `obtain ⟨hlow, hhigh⟩ := hN`.
- [ ] Re-derive `completion_of_hasNearest` from it in one line
      (`fun τ z => completion_of_nearest_at τ z (hN τ.domain z) hcomp hser`), so the existing
      theorem keeps its exact statement and there is one proof, not two.
- [ ] Add `theorem nearestAt_of_finite {D} [LinearOrder D] {X : D → Prop} (hfin :
      {t | X t}.Finite) (z : D) : NearestAt X z`, from the finiteness of `{t | X t ∧ t ≤ z}` and
      `{t | X t ∧ z ≤ t}` in a linear order.
- [ ] Add `theorem completion_of_finite_domain (τ : PartialHistory F)
      (hfin : {t | τ.domain t}.Finite) (z : F.Duration)
      (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
      ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u` as the composition of the two.
- [ ] Add a short module-docstring subsection recording the payoff: the finitary form is a
      consequence of *Compositionality* + *Seriality*, the rational two-origin relation satisfies
      *Compositionality* and fails *Completion* (`RationalTwoOrigins.not_rel_completion`), hence
      **no condition implied by *Compositionality* can be equivalent to *Completion*** — in
      particular no finitary or two-point form can be, and the infinitary quantifier carries all
      the completeness content. Note that the two-point case for `s ≤ z ≤ t` is
      `TaskFrame.Interpolates`.
- [ ] Add `Paper:` lines to the new declarations.
- [ ] Run `lake build` and the linted single-file check; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: `HasNearest`'s redefinition is asserted to break no existing proof, on the
grounds that it is definitional and its two consumers (`hasNearest_int`,
`hasNearest_of_succPred`) open with `intro X z; constructor`. Confirm by building
`FormalSystem/Semantics/Extension/Completion.lean` and then the whole library; a single `unfold`
insertion is the sanctioned repair, a restatement is not.

**Files to modify**:

- `FormalSystem/Semantics/Extension/Completion.lean` — `NearestAt`, redefined `HasNearest`,
  `completion_of_nearest_at`, re-derived `completion_of_hasNearest`, `nearestAt_of_finite`,
  `completion_of_finite_domain`, module-docstring subsection

**Verification**:

- `lake build` exits 0 with zero errors and zero warnings.
- `completion_of_hasNearest`, `extension_of_hasNearest` and `extension_of_isZTime` are unchanged
  in statement (`git diff` shows edits to the proof body of the first only).
- `#print axioms FormalSystem.Semantics.PartialHistory.completion_of_finite_domain` reports no
  `sorryAx`.

---

### Phase 5: Retire every "the converse is open" claim [NOT STARTED]

**Goal**: Leave no in-tree prose asserting the strictness question is open, and record the settled
verdict where the next reader of the extension chain will meet it.

**Tasks**:

- [ ] Rewrite `FormalSystem/Semantics/Extension/Completion.lean`'s module-docstring section
      currently headed `## This module does **not** propose changing def:frame`. Its final
      sentence ("Whether the replacement would be a *strict* weakening is the converse
      `Completion → Saturation`, which is left open") is now false. Replace the section with one
      that records: the converse is **false**, witnessed by
      `StateTopology.SeparatingFrame.not_srel_saturation` together with `srel_completion`;
      *Completion* is therefore a strict weakening of *Saturation*; the primitives-level reading
      favours the bare `TaskFrame.Completion` clause (R4) as `def:frame`'s fourth constraint; and
      the manuscript change and the `FrameOver.IsRegular` field swap are deliberately **not** made
      here — name them as follow-up work rather than leaving the reader to infer it.
- [ ] Rewrite `FormalSystem/Semantics/Extension/Step.lean`'s `## What step actually consumes:
      *Completion*` section to match: keep its "sole elimination site" measurement (which Phase 7
      relies on and which nothing has invalidated), and update any sentence that presents the
      relative strength of the two conditions as unknown.
- [ ] Sweep the whole tree for the claim in any phrasing, not only at the three known sites:
      `grep -rn "left open\|stays open\|not known to be a strict\|strictly stronger"
      FormalSystem/ docs/ --include=*.lean --include=*.md`. Evaluate every hit; most will be
      unrelated (there are several about other open questions) — change only those about
      *Saturation* vs *Completion*, and leave a note in the phase record for any hit deliberately
      left alone.
- [ ] Specifically check `docs/reference/paper-definitions-of-record.md` for the ball-space
      footnote language ("at least as strong as", and the standing instruction not to restore
      "strictly stronger"). That instruction is about the `S₁ᵈ ⇒ S₁` ball-space claim, **not**
      about *Saturation* vs *Completion*, and it is a pinned-anchor file: do **not** edit it.
      Confirm in the phase record that it was read and left unchanged.
- [ ] Run `lake build`; commit.

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: local

**Scope Hypothesis**: the report names "three docstrings that record the converse as open"
(`Extension/Completion.lean`, `Extension/Step.lean`, and the promoted probe text handled in Phase
2). That count is a hypothesis; the tree-wide grep above is how it is confirmed or corrected, and
a fourth site found by the grep is a finding to act on, not an overrun to defend.

**Files to modify**:

- `FormalSystem/Semantics/Extension/Completion.lean` — module-docstring verdict section
- `FormalSystem/Semantics/Extension/Step.lean` — `## What step actually consumes` section
- Any further site the sweep identifies

**Verification**:

- `lake build` exits 0 with zero errors and zero warnings.
- The grep above returns no remaining hit that asserts `Completion → Saturation` is open.
- `docs/reference/paper-definitions-of-record.md` is byte-identical to its pre-phase state.

---

### Phase 6: Update the ledgers [NOT STARTED]

**Goal**: Put the new results into the repository's per-theorem ledger and module READMEs, so the
gates that read them stay green and the results are discoverable without grepping Lean source.

**Tasks**:

- [ ] Add `docs/theorem-index.md` rows for `RationalTwoOrigins.not_rel_completion`,
      `SeparatingFrame.srel_completion`, `SeparatingFrame.not_srel_saturation`,
      `PartialHistory.completion_of_finite_domain` and `TaskFrame.Completion`, following the exact
      column shape of the neighbouring `ConstraintWitnesses.lean` rows (Paper label, statement,
      backticked fully-qualified name, backticked file, `—`, axiom cell).
- [ ] For each new row, confirm the declaration's own `/--` doc comment carries the matching
      `Paper:` line — this is invariant C15's second assertion, and a row without it fails the
      gate. Rows whose anchor is `—` need the `—` plus a one-clause reason at the declaration.
- [ ] Update `FormalSystem/Semantics/StateTopology/README.md` and
      `FormalSystem/Semantics/Extension/README.md` for the new declarations, and refresh their
      `Last verified` dates.
- [ ] Run `bash scripts/readme-lint.sh` and `bash scripts/readme-inventory.sh`; fix anything
      gated (checks 1 and 3 of readme-lint affect the exit code; checks 2 and 4 are reported only
      and need not be driven to zero).
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm C15 passes with the new rows.
      Consider whether the new witnesses warrant C14 axiom pinning alongside the existing
      `ConstraintWitnesses` entries; if yes, add them, and if no, say why in the phase record.
- [ ] Commit.

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: local

**Scope Hypothesis**: five new theorem-index rows and two README updates are expected. Confirm by
re-reading the phase's own `git diff` against the declaration set actually landed in Phases 1–4 —
if a declaration landed under a different name, the row must follow the code, not this plan.

**Files to modify**:

- `docs/theorem-index.md`
- `FormalSystem/Semantics/StateTopology/README.md`
- `FormalSystem/Semantics/Extension/README.md`
- Possibly `scripts/check-module-invariants.sh` (C14 axiom-pin block only)

**Verification**:

- `bash scripts/check-module-invariants.sh` passes C15 with the new rows counted.
- `bash scripts/readme-lint.sh` exits 0.
- `bash scripts/readme-inventory.sh` runs clean.

---

### Phase 7: Full gate and recorded verdict [NOT STARTED]

**Goal**: Prove the tree is green end to end, prove no pinned anchor moved, and leave the R1/R4
verdict and its remaining follow-up work stated in one place.

**Tasks**:

- [ ] Run the full gate set and record each result verbatim: `lake build`;
      `bash scripts/check-module-invariants.sh`; `bash scripts/check-paper-definitions.sh`;
      `bash scripts/check-evidence-probes.sh`; `bash scripts/check-metalogic-cycles.sh`;
      `bash scripts/check-copyright-headers.sh`; `bash scripts/readme-lint.sh`.
- [ ] Confirm `check-paper-definitions.sh` reports no anchor moved — this is the concrete evidence
      for the no-manuscript-edits non-goal, not a formality.
- [ ] Re-run both source probes under the linted invocation as a cross-check that the promoted
      copies say what the probes said:
      `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false
      specs/661_settle_saturation_vs_completion_foundation/probes/*.lean`. Leave the probe files
      in place; they are the reproduction record, and the report's Appendix cites them.
- [ ] Confirm the tree is sorry-free: `grep -rn "\bsorry\b" FormalSystem/ --include=*.lean`
      returns nothing new relative to the pre-task baseline.
- [ ] Write the execution summary at
      `specs/661_settle_saturation_vs_completion_foundation/summaries/01_settle-saturation-vs-completion-summary.md`,
      stating the verdict (R4, on the strictness result plus the primitives criterion), what
      landed, and the two pieces of follow-up work this task deliberately did not do: the
      manuscript pass implementing R4 (including restating the clause `Fib`-free and moving the
      ball-space footnote onto a *Saturation* remark), and the `FrameOver.IsRegular` field swap
      with its five transport sites.
- [ ] Commit.

**Timing**: 1 hour

**Depends on**: 5, 6

**Verification Tier**: full

**Files to modify**:

- `specs/661_settle_saturation_vs_completion_foundation/summaries/01_settle-saturation-vs-completion-summary.md`

**Verification**:

- Every gate above exits 0, with its output recorded in the summary.
- `check-paper-definitions.sh` explicitly confirms no pinned anchor moved.
- Both probe files still compile warning-free.

---

### Phase 8: Record the time-indexed vs ball-indexed distinction [NOT STARTED]

**Goal**: Capture the load-bearing intuition behind three separate results — that time-indexed
quantifiers collapse over orders with nearest times while ball-indexed ones never do — which is
currently recorded only inside Lean docstrings.

**Tasks**:

- [ ] Resolve the source store per `.claude/rules/source-store-deploy-boundary.md`: read
      `.claude-extensions.json`, take the `formal` extension's `source_dir`, and confirm it exists
      on disk. **Do not hand-author anything under `.claude/`** — that tree is a disposable deploy
      artifact and the edit would be wiped by the next regeneration. If the source store does not
      resolve, file a `/task` describing the needed file instead and mark this phase
      `[COMPLETED WITH EXCLUSIONS]` with that task as the evidence.
- [ ] Write `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` recording:
      the time-indexed/ball-indexed distinction; the four `def:frame` constraints' independence
      matrix with its witnesses; and the two separations — *Saturation* vs *Completion*, and dense
      vs discrete time. Cite the Lean declarations by fully-qualified name.
- [ ] Add a matching entry to `<source_dir>/index-entries.json`, following the shape of the
      existing `project/logic/domain/*` entries exactly: `path`, `summary`, `category: "domain"`,
      `line_count`, `load_when.agents` (`logic-research-agent`, `formal-research-agent`),
      `load_when.task_types` (`logic`, `formal`), `domain: "project"`, `subdomain: "logic"`.
- [ ] Validate the JSON (`python3 -m json.tool` on the edited file) before finishing.
- [ ] Do **not** redeploy as part of this phase; note in the phase record that the deployed
      `.claude/` tree is already flagged stale for `core` and that redeployment is the user's call.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:

- `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` (new)
- `<source_dir>/index-entries.json`

**Verification**:

- The new file exists under the resolved `source_dir`, and nothing was written under
  `.claude/context/**`.
- `python3 -m json.tool <source_dir>/index-entries.json` succeeds.
- The new entry's `path` matches the file's actual relative path.

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.Extension.Completion
import FormalSystem.Semantics.StateTopology.ConstraintWitnesses

namespace FormalSystem.Semantics

/-- *Completion*, over a bare task relation: `def:frame`'s candidate fourth constraint in the
primitives `W`, `D` and `⇒` alone. No `Fib`, no fiber/segment classification, no notion of
history. Strictly weaker than *Saturation*. -/
def TaskFrame.Completion {W D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop := sorry

/-- The pointwise form of `HasNearest`: the set `X` has a nearest member on each side of `z`. -/
def PartialHistory.NearestAt {D : Type} [LinearOrder D] (X : D → Prop) (z : D) : Prop := sorry

/-- `completion_of_hasNearest`, weakened to the single instance of the nearest-times hypothesis
its proof actually consumes. -/
theorem PartialHistory.completion_of_nearest_at {F : TaskFrame} (τ : PartialHistory F)
    (z : F.Duration) (hN : PartialHistory.NearestAt τ.domain z)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u := sorry

/-- **Finitary *Completion*** is a consequence of *Compositionality* and *Seriality*: a finite
domain has a nearest time on each side of `z`. With `RationalTwoOrigins.not_rel_completion`, this
shows no condition implied by *Compositionality* can be equivalent to *Completion*. -/
theorem PartialHistory.completion_of_finite_domain {F : TaskFrame} (τ : PartialHistory F)
    (hfin : {t : F.Duration | τ.domain t}.Finite) (z : F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u := sorry

/-- **The rational two-origin relation also fails *Completion***, so the rational carrier is not
the separator. Over dense time, a coherent family accumulating at `z` pinches the witness onto a
single real number, so no dense-time drift frame can separate *Completion* from *Saturation*. -/
theorem StateTopology.RationalTwoOrigins.not_rel_completion :
    ¬ TaskFrame.Completion StateTopology.RationalTwoOrigins.rel := sorry

/-- Unit-speed drift on `ℚ` over `ℤ`-time: `w ⇒_x v` iff `|v - w| ≤ |x|`. -/
def StateTopology.SeparatingFrame.srel (w : ℚ) (x : ℤ) (v : ℚ) : Prop := sorry

theorem StateTopology.SeparatingFrame.srel_serial :
    TaskFrame.Serial StateTopology.SeparatingFrame.srel := sorry

theorem StateTopology.SeparatingFrame.srel_compositional :
    TaskFrame.Compositional StateTopology.SeparatingFrame.srel := sorry

theorem StateTopology.SeparatingFrame.srel_limit :
    TaskFrame.Limit StateTopology.SeparatingFrame.srel := sorry

/-- *Completion* holds: `ℤ` has nearest times, so the `⊆`-least constraint is the one imposed by
the nearest domain time on each side of `z`, and no completeness of the carrier is demanded. -/
theorem StateTopology.SeparatingFrame.srel_completion :
    TaskFrame.Completion StateTopology.SeparatingFrame.srel := sorry

/-- **The separation.** *Saturation* fails, although *Seriality*, *Compositionality*, *Limit* and
*Completion* all hold: fibres and segments are not indexed by times, so a `⊇`-directed family of
them shrinks onto the cut `{q : q² < 2} | {q : 2 < q²}`, which has no rational point. Hence
`Completion → Saturation` is **false**, unconditionally. -/
theorem StateTopology.SeparatingFrame.not_srel_saturation :
    ¬ TaskFrame.Saturation StateTopology.SeparatingFrame.srel := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build` exits 0 with zero `error:` and zero `warning:` lines, at every phase boundary.
- [ ] Every modified `FormalSystem/**` module is silent under
      `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false` — the package's
      own linter set, which plain `lake env lean` does not apply (the hazard recorded in task
      659's summary).
- [ ] `#print axioms` reports exactly `propext`, `Classical.choice`, `Quot.sound` for each of the
      eleven pinned declarations, and no `sorryAx` anywhere.
- [ ] `bash scripts/check-module-invariants.sh` passes, including C15 with the new theorem-index
      rows and C30 with any `longFile` baseline added in Phase 3.
- [ ] `bash scripts/check-paper-definitions.sh` reports no pinned anchor moved, and
      `docs/reference/paper-definitions-of-record.md` is unmodified.
- [ ] `bash scripts/check-evidence-probes.sh` still passes all five wired probes (task 660's
      repair must not regress).
- [ ] `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-copyright-headers.sh` and
      `bash scripts/readme-lint.sh` all exit 0.
- [ ] Both files under `specs/661_settle_saturation_vs_completion_foundation/probes/` still
      compile warning-free.
- [ ] `git diff` across the task's commits touches only: `FormalSystem/Semantics/TaskFrame.lean`,
      `FormalSystem/Semantics/Extension/Completion.lean`,
      `FormalSystem/Semantics/Extension/Step.lean`,
      `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, the two module READMEs,
      `docs/theorem-index.md`, possibly `scripts/check-module-invariants.sh` (C14 block only),
      `specs/661_settle_saturation_vs_completion_foundation/**`, and the resolved source-store
      paths from Phase 8.

## Artifacts & Outputs

- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.Completion`, the bare-relation fourth
  constraint
- `FormalSystem/Semantics/Extension/Completion.lean` — `CoherentCompletion` redefined over it,
  `coherentCompletion_iff_rel`, `NearestAt`, `completion_of_nearest_at`, `nearestAt_of_finite`,
  `completion_of_finite_domain`, and the corrected verdict section
- `FormalSystem/Semantics/Extension/Step.lean` — corrected relative-strength prose
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` —
  `RationalTwoOrigins.not_rel_completion` and the `SeparatingFrame` namespace, plus the extended
  independence matrix and packaging-asymmetry notes
- `docs/theorem-index.md` — five new rows
- `FormalSystem/Semantics/StateTopology/README.md`, `FormalSystem/Semantics/Extension/README.md`
- `specs/661_settle_saturation_vs_completion_foundation/summaries/01_settle-saturation-vs-completion-summary.md`
- `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` and the matching
  `index-entries.json` entry (Phase 8, resolved source store — never `.claude/`)

## Rollback/Contingency

Each phase commits on green, so the natural rollback is `git revert` of the offending phase
commit — no working-tree destruction, and no snapshot needed.

If a phase must be abandoned mid-edit with a dirty tree, take a durable checkpoint first with
`bash .claude/scripts/git-snapshot.sh 661 --no-revert`, which is non-reverting and preserves the
work. Only a genuine whole-tree rollback uses the default reverting mode, and then per
`context/contracts/recovery.md`'s rollback rung, with `--allow-out-of-scope` if the dirty tree
carries tracked modifications outside the task's declared `file_scope`.

Phase-specific contingencies, each already authorised above so no phase stalls on them:

- **Phase 1** — if `TaskFrame.Completion` collides at a call site, qualify the reference; do not
  rename the predicate.
- **Phase 3** — if the `Extension/Completion` import misbehaves, inline the ℤ nearest-times
  argument instead; if the file crosses 1,500 lines, add a `longFile` baseline rather than
  splitting the module.
- **Phase 4** — if `HasNearest`'s redefinition breaks a consumer, insert `unfold NearestAt`; do not
  restate the consumer.
- **Phase 8** — if the source store does not resolve, file a `/task` and close the phase as
  `[COMPLETED WITH EXCLUSIONS]` with that task as evidence. Never hand-author under `.claude/`.

Phases 1–4 are independent enough to be reverted individually: Phases 2 and 3 add new
declarations only, Phase 4 is a hypothesis weakening whose original theorem keeps its statement,
and only Phase 1 touches a core module. Reverting Phase 1 requires reverting 2, 3 and 4 with it,
since all three state results against its predicate.
