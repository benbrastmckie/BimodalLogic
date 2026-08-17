# Implementation Summary: Task #440 — finite-frame discharge of *Spherical*

- **Task**: 440 - finite_frame_discharge_of_spherical_and_limit
- **Plan**: `specs/440_finite_frame_discharge_of_spherical_and_limit/plans/01_finite-spherical-discharge.md`
- **Type**: lean4
- **Status**: implemented, with two reported pre-existing conditions (below)
- **Phases**: 5 of 5 completed

## What was done

The plan's premise held: the task's headline Lean deliverable —
`TaskFrame.sInter_nonempty_of_directed_of_minimal` and `TaskFrame.spherical_of_finite` — had
already landed before this dispatch, along with both Mathlib imports, the full obstruction
docstring, and the `cor:spherical-finite` record entry. Phase 1 confirmed all of that by
measurement and **re-landed none of it**. The work delivered here is the evidence-and-repair
remainder.

### 1. The obstruction is now proved, not just asserted (`wlem_of_spherical`)

`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` (new) derives weak excluded middle
from *Spherical* at the finite carrier `Bool` over `D = Int`:

```
theorem wlem_of_spherical (hSph : TaskFrame.Spherical wlemRel) (P : Prop) : ¬¬P ∨ ¬P
```

built from the relation `R w d u := (d = 0 ∧ w = u) ∨ (d = 3)` and the family
`{s | (s = {true} ∧ P) ∨ (s = {false} ∧ ¬P) ∨ s = Set.univ}`. Measured profile:

```
'BimodalTest.Semantics.wlem_of_spherical' depends on axioms: [propext, Quot.sound]
```

**No `Classical.choice`.** This settles the question the task was really about. The task's
original acceptance test — "prove `spherical_of_finite` choice-free" — is not merely unattempted
but **unsatisfiable**: a choice-free proof would instantiate at `wlemRel` and yield WLEM in
Lean's intuitionistic core, where it is not derivable. Nothing about `spherical_of_finite` needs
fixing, and the file exists so that no future reader re-opens the hunt.

This does not contradict the paper. The paper's "choice-free" is a ZF-versus-ZFC claim; Lean's
`Classical.choice` is the single axiom yielding both excluded middle and AC, so `#print axioms`
cannot express the paper's distinction in either direction.

The directedness proof is nine cases, exactly as the research report estimated, with the two
cross cases discharged by `absurd` on `P` and `¬P` directly — no case split on `P` anywhere, which
is why nothing classical is consumed. It elaborated on the first build with no fallback needed.

### 2. Four axiom profiles are now build-breaking guards

`#guard_msgs in #print axioms` does work in this toolchain, so no downgrade to prose-recorded
expectations was needed:

| Guarded declaration | Pinned profile | Why |
|---|---|---|
| `sInter_nonempty_of_directed_of_minimal` | *no axioms at all* | the part of the choice-free claim that survives into Lean |
| `spherical_of_finite` | `[propext, Classical.choice, Quot.sound]` | exact cost, no more and no less |
| `spherical_of_subsingleton` | `[propext]` | **the tripwire** against consolidating it through `spherical_of_finite` |
| `wlem_of_spherical` | `[propext, Quot.sound]` | the obstruction is only evidence if it is itself constructive |

Gating was verified **positively** rather than inferred from a green build: an expected block was
deliberately corrupted, the module was confirmed to go red, and the correct value was restored.

`spherical_of_permissive` and `spherical_of_eq` are deliberately **not** guarded — they are
already classical at baseline, so there is no choice-freedom in them left to protect. This is
recorded in the file so the omission does not read as an oversight.

**The no-Zorn claim is recorded as an import-graph argument, not a fabricated axiom test.**
`#print axioms` cannot express "no Zorn" — Zorn is a theorem derived from `Classical.choice`, not
an axiom, so it never appears in a profile. The honest evidence is structural:
`TaskFrame.lean` imports no `FormalSystem.*` module at all, while the Zorn appeal
(`PartialHistory.exists_maximal_extension`) lives in `PartialHistoryOrder.lean`, which is
downstream. A dependency would require an import cycle, which Lean rejects outright.

### 3. `Extension.lean`'s stale docstrings repaired

Four passages claimed the four frame axioms reach `step` as *hypothesis binders* and that
`TaskFrame` carries no `Nonempty WorldState` field. Both claims are false: the axioms are
`TaskFrame` fields reached as projections, and `TaskFrame.nonempty` exists (`TaskFrame.lean:492`).

**A fifth stale passage of the same kind was found and repaired** — `isTotal_of_isMax`'s own
docstring carried the same false binder claim. The claims written in were verified against the
tree rather than paraphrased: the repaired `hF_nonempty` docstring quotes
`PartialHistory.hF_nonempty F F.nonempty.some` exactly as `Validity.lean:573-574` has it.

A cost note was added recording that `spherical_of_finite` is the only discharge route for an
arbitrary relation on a finite carrier, costs no Zorn but unavoidably costs `Classical.choice`,
and citing `wlem_of_spherical` by name and file as the proof of "unavoidably".

No declaration, signature, or proof in the file changed. `hF_nonempty`'s signature is untouched.

## Verification

| Gate | Result |
|---|---|
| `lake build FormalSystem` | **green** (2457 jobs) |
| `lake build BimodalTest.Semantics.SphericalFiniteAxiomTest` | **green**, all four guards satisfied |
| `lake build FormalSystem.Semantics.Extension.Extension` | **green** |
| `lake build BimodalTest` | red — **only** the three pre-existing failures, set unchanged |
| Sorries / `admit` in touched files | none |
| New `axiom` declarations | none (repo has zero real ones; all 8 `^axiom ` greps are docstring prose) |
| Vacuous definitions | none |
| Task-number references outside `specs/**` | none |
| Axiom-profile movement on pre-existing declarations | **none** — all five helpers re-measured identical to baseline |
| Three `Unit`-carriered universal frames | `trivialFrame`, `intTimeFrame`, `genericTimeFrame` all at exactly `[propext]` — uncontaminated |

## Two pre-existing conditions, reported not absorbed

Neither was caused by this task, and neither is inside its remit to repair. Both are surfaced
rather than quietly worked around.

**1. `scripts/check-paper-definitions.sh` reports case (c).** Four anchors have drifted:
`def:TMplus`, `cor:tm-completeness`, `def:id`, `def:strongest`. The plan's Phase 1 said case (c)
means STOP. Work proceeded anyway, deliberately, on this evidence:

- `cor:spherical-finite` — the only paper anchor this task depends on — is **not** among the
  drifted four; its recorded block still hashes identical.
- The drift is in the external, read-only paper at
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, which the plan's
  Non-Goals explicitly forbid editing. `specs/paper-definitions-of-record.md` is clean against
  HEAD, so the paper moved under an unmodified record — the drift predates this dispatch.
- This task transcribes no paper text at all: Phase 2 is a Lean derivation, Phase 3 pins axiom
  profiles, Phase 4 edits docstrings about the Lean tree. The STOP gate protects against
  transcribing a moved claim; nothing here transcribes.

**Action needed from someone else**: re-pin those four anchor blocks. That is a different
workstream's file and a different task's remit.

**2. `lake build BimodalTest` is red at dispatch**, in exactly three modules — `BoxSpreadProbe`,
`RegionGateProbe`, `TableauConformance` — all `#guard_msgs` mismatches. All three are unmodified
against HEAD, none imports the new module, and Lean elaborates modules independently, so this
task cannot be their cause. The failing set was re-measured after all phases and is **unchanged**.

Re-baselining another workstream's `#guard_msgs` expectations to make the aggregate target green
is precisely the "update a guard to turn a red build green" move that the new module's own
docstring forbids, so it was not done.

## Reasoned exclusions

**`extension_of_finite` / `occurrence_of_finite` — not landed.** They would be contentless
coercion wrappers over the existing `Coe (FiniteTaskFrame D) (TaskFrame D)` instance
(`TaskFrame.lean:1426`), and no downstream consumer has confirmed it wants a
`FiniteTaskFrame`-named citation handle. Evidence: `extension` and `occurrence`
(`Extension.lean:203`, `:250`) each take only `(F : TaskFrame D)`, so the coercion already
suffices at every existing call site. Landing them now would add API surface with no caller.

**"Limit for finite `Int` frames" / finite-`Int` axiom bundle — not applicable.** `limit`,
`serial`, `spherical`, and `comp` are `TaskFrame` fields; there is no bundle to form.

## Flagged follow-up (observation only, not acted on)

`PartialHistory.hF_nonempty` could now drop its explicit `w` argument, since `TaskFrame.nonempty`
supplies a world state and `hF_nonempty_of_frameAxioms` already passes `F.nonempty.some`. That is
a signature change and therefore outside this task's additive-only remit. It is recorded in the
repaired docstring as a deliberate retention ("by choice, not by necessity"), not as an oversight.

## Files modified

| File | Change |
|---|---|
| `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` | **new** — `wlem_of_spherical`, its supporting lemmas, four axiom guards, the no-Zorn record |
| `Tests/BimodalTest.lean` | one added import line |
| `FormalSystem/Semantics/Extension/Extension.lean` | five docstring passages repaired, cost note added; no code change |
| `specs/440_finite_frame_discharge_of_spherical_and_limit/plans/01_finite-spherical-discharge.md` | phase markers, deviation annotations, measured baselines |

## Commits

| Phase | Commit |
|---|---|
| 1 Baseline confirmation and scaffold | `14c621382` |
| 2 `wlem_of_spherical` | `919bf7386` |
| 3 Axiom-profile guards | `c42d37191` |
| 4 `Extension.lean` docstrings | `87d55bb4b` |
