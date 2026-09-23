# Implementation Summary: Task #659

- **Task**: 659 - Settle saturation witnesses and R0 without Limit
- **Status**: [COMPLETED]
- **Started**: 2026-09-23
- **Completed**: 2026-09-23
- **Effort**: ~4 hours
- **Dependencies**: Task 658 (same module; already complete)
- **Artifacts**: plans/01_promote-saturation-r0-witnesses.md, reports/01_saturation-witnesses-r0-limit.md, probes/*.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

A promotion round: the research phase had already settled every question this task posed and left
six sorry-free probes, so the work was transcribing that mathematics into the library and
propagating the resulting certification changes. All eleven plan phases closed. The headline
outcome is that the two real witnesses — the half-line with two origins and the hedgehog — now
prove *Saturation* and are `FrameOver.IsRegular` instances, so the manuscript's topology appendix
may say **task frame** where it previously had to say "structure satisfying three of the four
constraints". R0 without *Limit* was settled negatively by a new compiled witness (the ghost ray),
replacing an `UNVERIFIED` sketch that could not have worked.

## Per-question verdicts

### Q1 — *Saturation* for the two witness frames: **SETTLED, positively, for both.**

| Frame | Relation level | Frame level | What it licenses |
|---|---|---|---|
| Two-origin half-line | `TwoOrigins.rel_saturation` | `TwoOrigins.frame_saturation`, `instance : frame.IsRegular` | `TwoOrigins.taskFrame_t1_not_t2`: **some task frame is T1 and not Hausdorff** |
| Hedgehog | `Hedgehog.rel_saturation` | `Hedgehog.frame_saturation`, `instance : frame.IsRegular` | `Hedgehog.taskFrame_t1Space`: the `𝒩_F`-vs-final-topology separation is now about a **task frame** |

The paper's shadow argument survived contact in full. The one gap it left implicit — why the
`{o true} ∩ {o false} = ∅` case of a segment cannot arise — is discharged explicitly in
`TwoOrigins.seg_band`'s docstring and proof: a fibre carrying only one origin is bounded above by
its own (nonpositive) duration, so the intersection would be empty, contradicting nonemptiness.

The reusable content was extracted as planned, and sited beside `DirectedFamily` in
`Semantics/TaskFrame.lean` rather than in `ForMathlib/`:

- `TaskFrame.exists_mem_image_of_directedFamily` — a `⊇`-directed family of nonempty sets whose
  images under `φ` are compact and closed has a common image point.
- `TaskFrame.exists_mem_image_of_directedFamily_Icc` — the `Set.Icc` specialisation both witnesses
  (and the metric frame) actually call.

Both *Saturation* proofs consume the extracted lemma rather than re-inlining the
Cantor-intersection step, which is what the extraction was for.

### Q1′ — the ℚ/ℝ contrast: **SETTLED, and it is load-bearing.**

`RationalTwoOrigins.not_rel_saturation`. The two-origin relation transcribed verbatim over `ℚ`
keeps *Seriality*, *Compositionality* and *Limit* (`rel_serial`, `rel_compositional`, `rel_limit`)
and **fails *Saturation***: the rational intervals straddling `{q : q² < 2} | {q : 2 < q²}` form a
`⊇`-directed family of nonempty segments with empty intersection. So the appendix may say the real
witness is over `ℝ` *because* the shadow argument consumes Dedekind completeness — with a compiled
fact behind the claim rather than an intuition. This is the only statement in the collection
exhibiting a frame constraint failing for a completeness reason.

### Q2 — R0 without *Limit*: **SETTLED, negatively, by replacement.**

`GhostRay.frame_not_r0Space` (relation level: `GhostRay.not_r0Space_nbhdTopology`). The carrier is
a ghost `γ` and a two-sided ray; `γ` loops at every duration and reaches every strictly positive
ray point in every strictly positive duration, and nothing reaches `γ` forward. *Seriality* and
*Compositionality* hold, *Limit* fails, and the specialization order is asymmetric: `r 0 ∈ cl{γ}`
while `γ ∉ cl{r 0}`.

The previously recorded modified-hedgehog-with-tips sketch was **replaced, not patched**, and the
module docstring records why it could not have worked: the asymmetry it needed is between the
extra state and a ray's *endpoint*, and the hedgehog's rays have no endpoint but the centre, which
every ray already reaches.

**Verdict for the appendix: R0 is exactly as fragile as T1.** Both fail as soon as *Limit* is
dropped, with the other two constraints in force. `app:topology-r0`'s derivation from
`app:topology-t1` is therefore already optimal and was deliberately left untouched — no manuscript
file was edited by this task.

### Q3.1 — a frame condition for `𝒩_F` = the final topology: **partially settled.**

- Certified **positive criterion**: `TaskFrame.finalTopology_eq_of_surjective_open_history` — a
  *single* surjective open history collapses the final topology onto `𝒩_F`, with no relation-level
  hypothesis at all.
- Certified **negative constraint**: the hedgehog separating the two is now a **task frame**
  (`Hedgehog.frame_saturation`), so any answer to the open question must be strictly stronger than
  regularity. This is the fact a sibling task's Q4 consumes.
- The candidate "every escape net admits a coherent thread" condition stays `UNVERIFIED` in the
  research report and was **not** promoted (declared Non-Goal).

### Q3.2 — do the two topologies coincide on the metric frame: **SETTLED, positively.**

`MetricFrame.finalTopology_eq_nbhdTopology`. Settling it required first *naming* the metric frame,
which the library did not have as a declared object — it existed only as prose in
`StateTopology.lean`'s `Triangle` docstring, and what the library carried was the real-carrier
*bridge* (`nbhdTopology_eq_real`), a hypothesis shape rather than a frame. What the appendix gains:
the hedgehog's separation of `𝒩_F` from the final topology is a feature of **branching**, not of
the cone construction; on the frame the paper's own intuition is built from, the two agree.

### Q3.3 — a rational-carrier T1-non-Hausdorff frame: **narrowed, not settled.**

The literal ℚ transcription is not a task frame (*Saturation* fails, above). The positive half —
constructing a ℚ-carrier witness — would need a spherically complete non-order carrier with a dense
duration type, which is a different construction and was a declared Non-Goal.

### Bonus outcome, beyond the plan's timebox

Phase 8's timeboxed *Saturation* attempt for the metric frame **succeeded**, so the fallback
branch was never taken. `MetricFrame.rel_saturation` holds unconditionally (no speed hypothesis);
the shadow argument degenerates because the carrier is already `ℝ`, so the identity is its own
shadow map and no lifting step is needed. `MetricFrame.isRegular` assembles all four constraints at
any positive speed, and `instMetricFrameOneIsRegular` pins the unit-speed case for synthesis.

## What Changed

- `FormalSystem/Semantics/TaskFrame.lean` — `exists_mem_image_of_directedFamily` and its `Set.Icc`
  specialisation, beside `DirectedFamily`; one import (`Mathlib.Topology.Order.Compact`);
  `linter.style.longFile` 2600 → 2700.
- `FormalSystem/Semantics/StateTopology.lean` — `finalTopology_eq_of_surjective_open_history`,
  immediately after `finalTopology_le_nbhdTopology`. No import added.
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — the `TwoOrigins` and `Hedgehog`
  *Saturation* developments, both `IsRegular` instances, `taskFrame_t1_not_t2`,
  `taskFrame_t1Space`; the docstring sweep (five "*Saturation* not claimed" paragraphs and four
  "not an `IsRegular` instance" sentences deleted, not softened); `longFile` 1700 → 2200.
  1,510 → 2,047 lines.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — **new**, 572 lines. The
  ghost-ray R0 witness and the rational two-origin *Saturation* failure.
- `FormalSystem/Semantics/StateTopology/MetricFrame.lean` — **new**, 287 lines. The named metric
  frame, its four constraints, `finalTopology_eq_nbhdTopology`.
- `FormalSystem/Semantics/StateTopology/README.md` — **new**. Required by `readme-lint.sh` once the
  directory grew past one `.lean` file.
- `FormalSystem.lean` — regenerated; exactly two new imports, beside `...StateTopology.Counterexamples`.
- `FormalSystem/Semantics/README.md`, `FormalSystem/README.md`, `README.md` — the `StateTopology/`
  and `StateTopology.lean` rows, and the generated inventory/metric blocks.
- `docs/ARCHITECTURE.md` — the "state topology is a leaf" paragraph now names all three siblings.
- `docs/reference/state-topology-appendix-support.md` — flags 1, 3 and 4 flipped to `certified`;
  the `pending-sibling` status vocabulary row retired; the "R0 can fail without *Limit*" row filled
  in; four "(see flag 3)" qualifications dropped; four new certified rows added.
- `docs/theorem-index.md` — the "does not claim *Saturation*" parenthetical deleted; eleven new
  rows for the promoted declarations.
- `scripts/check-module-invariants.sh` — twelve declarations appended to `C14_BASELINE` and to the
  `C14LEAN` `#print axioms` heredoc, in the same order in both.

## Decisions

- **The shadow lemma sits in `TaskFrame.lean`, not `ForMathlib/`.** Following the research
  recommendation: it is a two-line wrapper around
  `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed` whose only content is the
  `DirectedFamily → Directed (· ⊇ ·)` translation, and a `ForMathlib/` module would cost a C24
  exception entry, a `FormalSystem/ForMathlib.lean` entry and two generated README rows for no
  upstreamable content.
- **Both *Saturation* proofs call the extracted lemma** rather than re-inlining the probes'
  Cantor-intersection blocks. The probes were written standalone; consuming the lemma is what
  Phase 1 existed for.
- **The three new frames went into new leaf modules, not into `Counterexamples.lean`.** That
  module's standing instruction is to raise its length ceiling only when a witness it already hosts
  genuinely grows — which the two *Saturation* proofs are, and the three new frames are not.
- **`MetricFrame.isRegular` is a theorem taking `0 < c`, plus one `instance` at `c = 1`.** The
  positivity hypothesis cannot be synthesised, so a bare instance is impossible; pinning unit speed
  gives synthesis something to find without inventing a default speed.
- **`RationalTwoOrigins` carries no `TemporalOrder.of ℚ`.** `TaskFrame.Saturation` is a
  bare-relation predicate needing only `[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid]
  [Nontrivial]`, all of which `ℚ` has. A frame-level form would need one; that was not investigated
  and the docstring says so.
- **`sq_ne_two` stays derived from `Rat.num_pow`.** `Mathlib.NumberTheory.Real.Irrational` is not
  in this checkout's build, so `irrational_sqrt_two` would add a dependency the tree does not carry.

## Plan Deviations

- **Phase 1** altered: one import (`Mathlib.Topology.Order.Compact`) was needed, and
  `TaskFrame.lean`'s `linter.style.longFile` had to be raised 2600 → 2700 — the addition pushed the
  file to 2,626 lines and `--wfail` treats the warning as fatal. The plan anticipated neither.
- **Phases 2 and 3** altered: `rel_saturation` in each consumes
  `TaskFrame.exists_mem_image_of_directedFamily_Icc` instead of re-inlining the probe's
  Cantor-intersection block. This realises Phase 1's stated goal rather than departing from it.
- **Phase 7** altered: the probe's `set_option maxHeartbeats 2000000` was **not** carried over. The
  landed module elaborates at the default budget, so the bump was probe-local.
- **Phase 8** fallback branch not taken: the timeboxed *Saturation* attempt succeeded, so the
  "*Saturation* is not claimed" docstring wording was never written. Exactly one of the two
  verification alternatives holds, as required.
- **Phase 8** altered: the probe's eleven tactic-mode `show`s became `change` in the landed
  module. `lakefile.toml` enables Mathlib's standard syntax-linter set package-wide
  (`weak.linter.mathlibStandardSet`), which rejects `show` used to change a goal definitionally,
  and `--wfail` makes that fatal. `lake env lean` does **not** apply package `leanOptions`, so
  neither the probe nor the first standalone elaboration surfaced it — the full build did. Worth
  recording as a transcription hazard: a probe that elaborates under `lake env lean` is not
  thereby lint-clean under `lake build --wfail`.
- **Phase 9** altered: `scripts/readme-inventory.sh` is a deprecated shim; inventories are emitted
  by `scripts/check-module-invariants.sh --emit-inventory`. Growing `StateTopology/` from one to
  three `.lean` files surfaced `readme-lint.sh`'s missing-README check on that directory, so
  `FormalSystem/Semantics/StateTopology/README.md` was created — a file the plan did not list.
  `docs/ARCHITECTURE.md` was likewise updated, since its leaf paragraph enumerated the modules by
  name.
- **Phase 10** skipped one item: "change the `Frame class` column from `—` to the regular class on
  the `TwoOrigins.*` and `Hedgehog.*` rows". That column is defined at `docs/theorem-index.md:17`
  as the `FrameClass` the result is stated at — vocabulary `Base | Dense | ZTime | RTime`, with `—`
  meaning class-generic. "Regular" is not a member of that vocabulary and these results *are*
  class-generic, so writing it there would corrupt the column. Regularity is recorded in the
  Statement column of the new `frame_saturation` / `taskFrame_t1_not_t2` rows instead.
- **Phase 10** reconciled against its Scope Hypothesis: exactly 4 "(see flag 3)" qualified rows
  existed, against the estimated ~5. The `pending-sibling` legend row was additionally retired,
  since nothing carries that status any more — which is what the phase's own verification criterion
  allowed for.
- **Phase 2/3 Scope Hypotheses** reconciled: `Counterexamples.lean` grew 1,510 → 1,778 (+268) for
  `TwoOrigins`, then → 2,033 (+255) for `Hedgehog`, both within the ~300-line bound. Final size
  2,047 after the docstring sweep, under the 2,200 ceiling.
- **Phase 6/7 Scope Hypothesis** reconciled: `ConstraintWitnesses.lean` landed at 572 lines against
  the ~500 estimate and the ~600 split threshold — no split needed.

## Verification

- Build: `lake build --wfail` — **green**, 2,724 jobs, 0 errors, 0 warnings. Every touched
  module's `.olean` is newer than its source
- Sorry count: 0 across `FormalSystem/Semantics/TaskFrame.lean`,
  `FormalSystem/Semantics/StateTopology.lean` and all of `FormalSystem/Semantics/StateTopology/`
- Vacuous count: 0 (no `:= True`/`:= trivial`/`:= Unit` placeholder)
- Axiom count: 0 new `axiom` declarations
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED** (B0-B3, C1-C6, C8-C15, C20,
  C21, C24, C27, C33, INV, C9D). C14 now pins the twelve new declarations; C33 confirms
  `FormalSystem.lean` is byte-for-byte the generated root
- Every promoted headline declaration reports `[propext, Classical.choice, Quot.sound]`, machine-
  checked by C14 rather than recorded by hand:
  `TaskFrame.exists_mem_image_of_directedFamily`, `...exists_mem_image_of_directedFamily_Icc`,
  `TaskFrame.finalTopology_eq_of_surjective_open_history`, `TwoOrigins.frame_saturation`,
  `TwoOrigins.taskFrame_t1_not_t2`, `Hedgehog.frame_saturation`, `Hedgehog.taskFrame_t1Space`,
  `GhostRay.frame_not_limit`, `GhostRay.frame_not_r0Space`,
  `RationalTwoOrigins.not_rel_saturation`, `MetricFrame.finalTopology_eq_nbhdTopology`,
  `MetricFrame.isRegular`
- Two gate failures surfaced by the first full-gate run and closed, both consequences of adding
  new namespaces rather than defects in the mathematics: **C5** (the namespace prefixes
  `...StateTopology.GhostRay` and `...StateTopology.RationalTwoOrigins` are not module paths —
  added to `scripts/module-invariants-allowlist.txt` beside the identical pre-existing
  `TwoOrigins`/`Hedgehog` entries) and **C15** (every theorem-index row's declaration must carry a
  matching `Paper:` line in its own `/--` block — eight added or reformatted; the
  `exists_mem_image_of_directedFamily` row was additionally split in two, since a row naming two
  declarations in one cell is silently unparseable and so silently unchecked)
- Non-Goals confirmed: no `R w 0 w`-from-*Seriality*+*Compositionality* claim anywhere; no
  manuscript file touched (`git status` clean of `.tex`/`.typ`); no `ForMathlib/Topology/` module
  added by this task (the pre-existing `Sierpinski.lean` from a sibling task is byte-unchanged);
  the `funnelFrame` "must never be given one" paragraphs are byte-identical
- Neither new module is reachable from `FormalSystem/Semantics.lean` or any aggregator other than
  the generated root — verified by `grep -rn` over `FormalSystem/`, which finds only docstring
  cross-references

## Impacts

- The topology appendix may now assert, as certified: "there is a **task frame** that is T1 and not
  Hausdorff"; "R0 fails without *Limit*"; "the cone topology and the final topology of all
  histories coincide on the metric frame"; and "the real carrier is not decorative — the ℚ
  transcription fails *Saturation*". The former "structure satisfying three of the four
  constraints" hedge is retired everywhere and should not be reintroduced.
- `app:topology-r0`'s derivation from `app:topology-t1` is confirmed optimal and needs no
  frame-level argument of its own.
- Two new `FrameOver.IsRegular` instances enter instance resolution
  (`T1Space` via `instT1SpaceOfRegular`, `r0Space_coneTop`, `iInter_cone_eq_singleton`,
  `coneTop_le_stateTopology`). The full build is green, including
  `Tests/BimodalTest/Semantics/StateTopologyTest.lean`.
- A sibling task's Q4 can now cite `Hedgehog.frame_saturation` as the certified *negative*
  constraint: any frame condition equivalent to `𝒩_F` = the final topology must be strictly
  stronger than regularity.

## Follow-ups

- The positive half of Q3.1 — the "every escape net admits a coherent thread" candidate condition —
  remains `UNVERIFIED` in `reports/01_saturation-witnesses-r0-limit.md`. It was a declared Non-Goal
  here.
- The positive half of Q3.3 — a ℚ-carrier T1-non-Hausdorff frame — is narrowed to "a spherically
  complete non-order carrier with a dense duration type" and belongs to a follow-up task.
- The `UNVERIFIED` observation that `R w 0 w` follows from *Seriality* + *Compositionality* is not
  promoted and is claimed nowhere in this output. If wanted, it is a short probe beside
  `nullity_of_serial_limit`.
- `readme-lint.sh` still reports pre-existing STALE DATE stamps across many READMEs and 89
  not-listed files; those are unrelated to this task and were left alone.

## References

- `specs/659_settle_saturation_witnesses_and_r0_without_limit/plans/01_promote-saturation-r0-witnesses.md`
- `specs/659_settle_saturation_witnesses_and_r0_without_limit/reports/01_saturation-witnesses-r0-limit.md`
- `specs/659_settle_saturation_witnesses_and_r0_without_limit/SEED.md`
- `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/` — the six sorry-free probes,
  the authoritative compiled source for every transcription above
- `docs/reference/state-topology-appendix-support.md` — the manuscript-facing view of what is now
  certified
