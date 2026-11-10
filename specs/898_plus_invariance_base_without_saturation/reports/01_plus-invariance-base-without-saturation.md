# Research Report: Task #898

**Task**: 898 - plus_invariance base without saturation
**Started**: 2026-11-10T00:55:00Z
**Completed**: 2026-11-10T01:05:00Z
**Effort**: ~1 dispatch (research only); implementation estimated at 1 small phase for
`HistoryMorphism.lean` plus 1 for the `UniversalCover.lean`/`IntNormalForm.lean` downstream
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/Semantics/HistoryMorphism.lean`, `TaskFrame.lean`, `IntNormalForm.lean`,
  `IntNormalFormEffective.lean`, `UniversalCover.lean`, `StateTopology/ConstraintWitnesses.lean`,
  `FrameClassValidity.lean`, `Metalogic/NamingRules.lean`)
- Two compiled Lean probes (`lake env lean`, exit 0), saved as evidence (see Artifacts)
- No Mathlib search was needed: the question is entirely about this project's own constraint
  bookkeeping, and every ingredient already exists locally
**Artifacts**:
- `specs/898_plus_invariance_base_without_saturation/reports/01_plus-invariance-base-without-saturation.md`
- `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean`
- `specs/evidence/history-morphism-saturation-audit/non-saturated-frameover-witness.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Saturation is consumed nowhere in the lifting chain.** Mechanically verified: the whole chain
  (`exists_preimage_step_neg`, `bwdSeq_spec`, `chain_spec`, `chain_step`, `chain_rel`,
  `exists_histMorphism_of_isZTime`, `plus_invariance_of_isZTime`) was transplanted verbatim into a
  probe file with `[F'.IsRegular] [F.IsRegular]` replaced by explicit constraint hypotheses, and
  compiles clean (`lake env lean`, exit 0, no errors, no `sorry`).
- **The result is strictly stronger than the task hypothesised.** The task asked for a base
  carrying "reflection, Compositionality, Seriality and Limit". The probe shows the **base frame
  `F` needs no `def:frame` constraint at all** — not Saturation, not Limit, not Seriality, not
  Compositionality. Only the **source** frame `F'` needs anything, and it needs exactly
  *Compositionality*, *Seriality* and *Limit*.
- **Why the base needs nothing**: the base's only use of `[F.IsRegular]` is `F.reflection` inside
  `exists_preimage_step_neg`, and the chain only ever invokes it at the step duration
  `δ = intIso.symm 1`, which is **nonzero**. At a nonzero duration reflection is definitional
  content of `TaskFrame.reflect` (`reflect_reflection_of_ne`), not a consequence of *Limit*.
- **Recommended shape**: follow the house style already used for `reflection_of_limit`,
  `eq_of_taskRel_zero_of_limit` and `nullity_identity_of_serial_limit` — land the
  explicit-hypothesis form as the general theorem and keep each `[IsRegular]` form as a thin
  wrapper with its statement unchanged. No new typeclass, no call-site churn, zero sorries.
- **The downstream payoff is real but needs two more weakenings**: the completeness programme's
  actual entry point is `UniversalCover.exists_orientedForest_cover`, whose base `[F.IsRegular]`
  flows through `FrameOver.taskRel_eq_iter`. That too is Saturation-free (it consumes
  *Compositionality*, *Seriality*, *Limit* only), so the headline can be restated over a base
  carrying those three.
- **A concrete non-saturated base frame over ℤ-time exists and is three lines away.**
  `StateTopology.SeparatingFrame.srel` (unit-speed drift on ℚ over ℤ-time) is *Serial*,
  *Compositional*, *Limit* and provably **not** *Saturated*; a second probe wraps it as a
  `FrameOver intOrder` via `FrameOver.ofReflective`, the reflection law being `abs_sub_comm` plus
  `abs_neg`. This supplies the non-vacuity witness the weakened theorems need.
- **One recorded claim elsewhere is affected**: `Metalogic/NamingRules.lean`'s "*Saturation* is the
  obstruction" passage, about presenting the Reynolds-style unravelling as a `FrameOver`, rests on
  `ofReflectiveRegular` demanding all four constraints. Since the lift chain needs only three of
  them of the unravelling, that obstruction dissolves **for this consumer** (details and the
  caveat that survives are in Findings).

## Context & Scope

**Researched**: whether *Saturation* of the base frame is consumed anywhere in the
`HistoryMorphism.lean` lifting chain, and if not, what the chain's minimal hypothesis set is and
how to restate it.

**Why it matters**: the completeness programme's countermodel of record is the universal cover of
the canonical quotient digraph of the Reynolds-style construction. The quotient has infinite fibres
and is not known saturated, so none of the three available Saturation routes
(`TaskFrame.saturation_of_finite`, `saturation_of_fib_finite`, `saturation_of_deterministic`)
applies to it. If truth transfer demands `[F.IsRegular]` of the base, the programme is blocked at
the last step; if it does not, the cover (which *is* saturated, being an oriented forest) carries
the refutation and the quotient never has to be saturated.

**Constraints observed**:
- Zero-debt policy: no approach below introduces a `sorry`, an axiom, or a vacuous definition. The
  probes are sorry-free and compile.
- No literature source is cited by this task, so the Literature Extraction Protocol does not
  apply. First-principles mode.
- Blocked MCP tools (`lean_diagnostic_messages`, `lean_file_outline`) were not called. Evidence tier
  is **compiled probe** throughout, which is strictly above LSP-index lookup; `lean-lsp` search
  tools were not needed because no external lemma was sought.

**Out of scope**: the dense-time case. The chain's docstrings already record that the walk has no
next step to take over dense time and that lifting a whole history would need a fibre-relative
saturation property; nothing in this research changes that, and the dense case stays unattempted.

## Findings

### Codebase Patterns

#### 1. Exactly where `[IsRegular]` is touched, and by what

`HistoryMorphism.lean` carries `[F'.IsRegular] [F.IsRegular]` on seven declarations (lines 306,
382, 434, 445, 469, 530, 590). Tracing each to the projection it actually uses:

| Declaration | Base `F` uses | Source `F'` uses |
|---|---|---|
| `exists_preimage_step_neg` (306) | `F.reflection` | `F'.reflection` |
| `bwdSeq_spec` (382) | via `exists_preimage_step_neg` | via `exists_preimage_step_neg` |
| `chain_spec` (434) | via `bwdSeq_spec` | via `bwdSeq_spec` |
| `chain_step` (445) | via `bwdSeq_spec` | via `bwdSeq_spec` |
| `chain_rel` (469) | via `chain_step` | `F'.nullity`, `F'.forward_comp`, `F'.reflection` |
| `exists_histMorphism_of_isZTime` (530) | via the above | via the above |
| `plus_invariance_of_isZTime` (590) | via the above | via the above |

`HistMorphism.plus_invariance` and `HistMorphism.plusValidOn` already carry **no** instance binder,
so the L⁺ invariance layer itself was never the problem.

The three source-side projections resolve to:

- `FrameOver.reflection` = `reflection_of_limit F F.limit` — ***Limit* alone**
  (`TaskFrame.lean:1421`, docstring: "*Limit* is the sole constraint consumed").
- `FrameOver.nullity` = `TaskFrame.nullity_of_serial_limit F.serial F.limit` — ***Seriality* +
  *Limit***.
- `FrameOver.forward_comp` = `forward_of_comp F.comp` — ***Compositionality***.

**`FrameOver.saturation` is reached by none of them.** The four "Constraints consumed:
Compositionality, Seriality, Limit, Saturation" docstrings in `HistoryMorphism.lean` (lines 468,
525, 586, and the corresponding line in `UniversalCover.lean:441`) therefore **over-report**: they
record the binder that is present, not the constraints the proof consumes. That is a documentation
defect independent of whether the signatures are changed.

#### 2. The base frame needs no constraint whatsoever (stronger than hypothesised)

`exists_preimage_step_neg` is the single site where the base's `IsRegular` does any work:

```lean
obtain ⟨c, hc, hfc⟩ := h.step a (-x) u ((F.reflection u x (f a)).1 hu)
```

Inside the chain, this is only ever called at `x := δ`, where `δ := intIso.symm 1`. Since `intIso`
is an `OrderAddMonoidIso` and `intIso.symm 0 = 0`, `δ ≠ 0`. `FrameOver.TaskRel` is definitionally
`TaskFrame.reflect F.PosRel`, and `TaskFrame.reflect_reflection_of_ne` (`TaskFrame.lean:369`)
gives `reflect P w d u ↔ reflect P u (-d) w` from `d ≠ 0` with **no constraint on the relation at
all**. So the base-side reflection step costs nothing.

The probe therefore carries a `δ ≠ 0` hypothesis through the chain in place of the base's *Limit*
and compiles. The base frame is an arbitrary `FrameOver D`.

#### 3. The minimal hypothesis set, verified

Compiled target signatures (probe, exit 0, no `sorry`, no errors; one unused-binder linter warning
on `fwdSeq_spec`, which does not need the `δ ≠ 0` binder the patch threaded uniformly):

```lean
theorem exists_histMorphism_of_isZTime_of_constraints
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) :
    ∃ g : HistMorphism F' F, g.toFun = f

theorem plus_invariance_of_isZTime_of_constraints
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) (M : TaskModel F.toTaskFrame) :
    ∃ g : HistMorphism F' F, g.toFun = f ∧
      ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
        PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ
```

No `[F.IsRegular]`, no `[F'.IsRegular]`, no *Saturation* on either side. Every proof body is the
existing one with the three projections replaced by their explicit-hypothesis counterparts
(`F'.reflection_of_limit hlim'`, `TaskFrame.nullity_of_serial_limit hser' hlim'`,
`TaskFrame.forward_of_comp hcomp'`) and `F.reflection` replaced by
`TaskFrame.reflect_reflection_of_ne (P := F.PosRel) hδne`. **No tactic was changed, no step was
re-derived.**

#### 4. The house style for exactly this weakening already exists

`TaskFrame.lean` repeatedly lands the minimal-hypothesis form as the general theorem and keeps the
`[IsRegular]` form as a thin wrapper with its original statement unchanged:

- `reflection_of_limit` / `reflection`
- `eq_of_taskRel_zero_of_limit` / `eq_of_taskRel_zero`
- `nullity_identity_of_serial_limit` / `nullity_identity`
- `reflection_int_of_limit` / `reflection_int` (in `IntNormalFormEffective.lean`)

The convention is stated explicitly at `TaskFrame.lean:872`, about `PartialHistory.Completion`:
"`PartialHistory.extension_of_completion`, which elaborates with **no `[F.IsRegular]` instance
binder** — and that is exactly where the minimality is recorded: in `thm:extension`'s hypothesis,
not in `def:frame`'s axiom list." This task is the same move at `HistoryMorphism.lean`.

#### 5. Downstream: `UniversalCover.exists_orientedForest_cover`

Only two modules outside `HistoryMorphism.lean` touch the chain:

- `Frames/TranslationProduct.lean:713` — supplies a `TwoWayBounded` instance only; no chain
  consumption, so unaffected.
- `UniversalCover.lean` — the real consumer, via `endpt_twoWayBounded` and
  `exists_orientedForest_cover`, both `[F.IsRegular]`.

`UniversalCover.lean`'s base-side uses are:

| Site | Base `F` uses | Resolves to |
|---|---|---|
| `coverFrame` (443) | `F.serial w 1 zero_le_one` (twice) | *Seriality* |
| `endpt_twoWayBounded` (465) | `F.taskRel_eq_iter` | *Comp* + *Serial* + *Limit* |

`FrameOver.taskRel_eq_iter` (`IntNormalForm.lean:232`) uses `F.taskRel_natCast_iff_iter` (which
uses `F.nullity_identity` = *Serial* + *Limit*, and `F.comp` = *Compositionality*) plus
`F.reflection` (*Limit*). **No *Saturation*.** `coverStep_isOrientedForest` and
`saturation_of_orientedForest` are statements about `CoverStep F.step` alone and take no base
constraint at all, so the cover's own regularity is unaffected.

So `exists_orientedForest_cover` restates over a base carrying *Compositionality*, *Seriality* and
*Limit*, with no *Saturation*. This requires one additional explicit-hypothesis variant pair in
`IntNormalForm.lean` (`taskRel_natCast_iff_iter_of_constraints`, `taskRel_eq_iter_of_constraints`)
— the same mechanical pattern, same proof bodies.

#### 6. A concrete non-saturated base frame over ℤ-time

`StateTopology/ConstraintWitnesses.lean` carries `SeparatingFrame.srel : ℚ → ℤ → ℚ → Prop`,
`srel w x v := |v - w| ≤ |(x : ℚ)|` — unit-speed drift on ℚ over **ℤ**-time — with
`srel_serial`, `srel_compositional`, `srel_limit`, `srel_completion` and
`not_srel_saturation` all proved. Its module docstring records a "packaging asymmetry": the
*Saturation* row is certified "at the **bare-relation** level only: neither
`RationalTwoOrigins.rel` nor `SeparatingFrame.srel` carries a `FrameOver` wrapper, because
wrapping either would need a reflection law for its carrier that this module does not prove."

For `srel` that reflection law is three lines. The second probe compiles:

```lean
theorem srel_reflective (w : ℚ) (d : ℤ) (u : ℚ) : srel w d u ↔ srel u (-d) w := by
  rw [srel_iff, srel_iff, abs_sub_comm]
  norm_num

def sepFrame : FrameOver intOrder := FrameOver.ofReflective ℚ srel srel_reflective
```

together with `sepFrame_comp`, `sepFrame_serial`, `sepFrame_limit` and
`sepFrame_not_saturation` (each a `rw [sepFrame_taskRel]` onto the existing bare-relation
theorem). This is a `FrameOver intOrder` satisfying *Compositionality*, *Seriality* and *Limit*
and provably failing *Saturation* — exactly the non-vacuity witness for the weakened theorems, and
exactly the shape of base the completeness programme's quotient digraph is expected to have.

Caveat worth recording: `ConstraintWitnesses.lean` is a declared **leaf** (nothing under
`FormalSystem/` imports it, per `docs/ARCHITECTURE.md`'s "The state topology is a leaf, on
purpose"). A witness must therefore live in that leaf or in the test library, never be imported
into the chain's own module.

#### 7. What the recorded obstruction elsewhere does and does not say

`Metalogic/NamingRules.lean:74` records, about the Reynolds *Auxiliary Atoms* unravelling:

> The first three are reachable over discrete time ... and composing single steps into the task at
> an arbitrary pair of times is what `TwoWayBounded.exists_histMorphism_of_isZTime` already does.
> *Saturation* is the obstruction.

That passage is about the **unravelled preimage** (the `F'` side), not the base, and it reasons
from `FrameOver.ofReflectiveRegular` demanding all four constraints. Two consequences:

1. **It dissolves for this consumer.** `FrameOver.ofReflective` (no `Regular`) presents a frame
   from a reflective relation with **no** constraints, and the weakened chain needs only
   *Compositionality*, *Seriality* and *Limit* of `F'`. So an unravelling can be presented as a
   `FrameOver` and fed to the chain without ever discharging *Saturation* for a path-recording
   relation. The three failing routes the passage enumerates become irrelevant to the lift.
2. **What survives.** `ProofSystem.FrameClass.Sat` is where *Saturation* is genuinely
   unavoidable: `Sat .Base F = F.IsRegular` and `Sat .ZTime F = F.IsRegular ∧ F.IsZTime`
   (`FrameClassValidity.lean:153-156`). A frame only counts as a member of the frame class — and so
   only refutes frame validity — if it is regular, Saturation included. **This is why the
   base/source asymmetry is the right place to spend the weakening**: the programme needs the
   *cover* to be class-regular (it is, via `saturation_of_orientedForest`) and needs the *base*
   only as the thing truth transfers from. `HistMorphism.plusValidOn` runs source → image, so a
   countermodel on a constraint-light base lifts to a countermodel on the regular cover, which is
   a bona fide `.ZTime` frame. The weakening is exactly what makes that argument go through.

### External Resources

No Mathlib search was required. The two Mathlib-side ingredients the chain already uses were
re-confirmed in place at this pin: `SuccOrder`/`IsSuccArchimedean` (via `intIso` in
`Semantics/DurationClassification.lean`) and `OrderAddMonoidIso`. The only Mathlib lemmas the new
witness needs are `abs_sub_comm` and `abs_neg`, both resolved by the compiled probe rather than by
name search.

### Recommendations

A **sorry-free path exists and has been compiled end to end.** Recommended decomposition, in the
house style, each step independently verifiable:

1. **`HistoryMorphism.lean` — the chain.** Add explicit-hypothesis forms and keep the
   `[IsRegular]` forms as wrappers:
   - `TwoWayBounded.exists_preimage_step_neg_of_ne` (source *Limit* + `x ≠ 0`; no base
     constraint), with `exists_preimage_step_neg` as the `[IsRegular]` wrapper, statement
     unchanged.
   - `bwdSeq_spec`, `chain_spec`, `chain_step`, `chain_rel` reparameterised over
     `hcomp' / hser' / hlim' / hδne`. These are `private`, so there is no external statement to
     preserve and no wrapper is owed.
   - `exists_histMorphism_of_isZTime_of_constraints` and
     `plus_invariance_of_isZTime_of_constraints` as the general theorems;
     `exists_histMorphism_of_isZTime` and `plus_invariance_of_isZTime` as `[IsRegular]` wrappers
     with their current statements **verbatim**, so no call site changes.
2. **Correct the four over-reporting docstrings.** Replace "Constraints consumed: Compositionality,
   Seriality, Limit, Saturation" with the audited set, and say on which side each lands (source:
   *Comp* + *Serial* + *Limit*; base: none). Same correction at `UniversalCover.lean:441` once
   step 4 lands.
3. **`IntNormalForm.lean` — the decomposition theorem.** Add
   `taskRel_natCast_iff_iter_of_constraints` and `taskRel_eq_iter_of_constraints` (hypotheses
   *Comp*, *Serial*, *Limit*), keeping `taskRel_natCast_iff_iter` / `taskRel_eq_iter` as wrappers.
   Optional companion in `IntNormalFormEffective.lean` for the choice-free `taskRel_eq_iter_int`
   if the ℤ-specific route is wanted too.
4. **`UniversalCover.lean` — the headline.** Add `endpt_twoWayBounded_of_constraints` and
   `exists_orientedForest_cover_of_constraints` over a base carrying *Comp* + *Serial* + *Limit*,
   keeping the `[F.IsRegular]` forms as wrappers. This is the declaration the completeness
   programme actually calls.
5. **Non-vacuity witness.** Land `srel_reflective` and the `sepFrame` wrapper in
   `StateTopology/ConstraintWitnesses.lean` (the leaf), plus the `example`/`theorem` applying
   `exists_orientedForest_cover_of_constraints` at `sepFrame` to show the weakened headline is not
   vacuous. Update that module's "packaging asymmetry" paragraph, which currently records that no
   `FrameOver` wrapper exists for `srel`.
6. **Prose surfaces.** Re-read `Metalogic/NamingRules.lean`'s "Not formalized" section against
   Finding 7 and `FormalSystem/Semantics.lean`'s `UniversalCover` / `HistoryMorphism` bullets
   ("every **regular** frame over `intOrder` has a regular cover frame"), plus any
   `docs/theorem-index.md` rows for the five touched declarations.

**Ordering note for the planner**: steps 1–2 are self-contained and verifiable by a scoped build of
`FormalSystem.Semantics.HistoryMorphism`. Steps 3–4 are a second, separately verifiable unit.
Step 5 touches a leaf and cannot break anything upstream. Step 6 is prose only.

**On introducing a typeclass instead** (e.g. a `FrameOver.IsPreRegular` bundling *Comp* +
*Serial* + *Limit*): not recommended. It would be a fifth way to say the same thing, would not
match any of the four existing `_of_limit` / `_of_serial_limit` precedents, and would not capture
the actual finding — which is **asymmetric** (base: nothing; source: three constraints) and so is
not one class anyway.

## Decisions

- **Evidence tier: compiled probe, not proof-term inspection.** `#print axioms` cannot answer
  "which `IsRegular` field is projected" (see
  `context/project/lean4/patterns/dependency-tracing.md` on why), and `lean_minimal_hypotheses`
  reports explicit hypotheses, not instance binders. Transplanting the chain and compiling it is
  the decisive test, and it also doubles as a feasibility proof for the implementation.
- **The probes were kept as durable evidence** under
  `specs/evidence/history-morphism-saturation-audit/`, following the existing
  `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean` precedent,
  rather than left in a session-scoped scratchpad.
- **Base-side weakening taken all the way to zero constraints**, rather than stopping at the
  *Limit* the task description anticipated. The `δ ≠ 0` route is one extra hypothesis threaded
  through four `private` lemmas and costs nothing; stopping at *Limit* would leave an unexplained
  binder in the public signature.
- **`[IsRegular]` forms are preserved verbatim as wrappers**, so no existing call site changes and
  the diff is additive. This is what makes the whole change low-risk.
- **The dense-time case stays unattempted**, as the existing docstrings already record.

## Risks & Mitigations

| Risk | Assessment | Mitigation |
|---|---|---|
| The restatement breaks an existing call site | Low. Only two external modules touch the chain, and both go through signatures that step 1 preserves verbatim | Keep every `[IsRegular]` form with its statement unchanged; verify with a scoped build of `FormalSystem.Semantics.UniversalCover` and `FormalSystem.Semantics.Frames.TranslationProduct` |
| `taskRel_eq_iter` weakening (step 3) ripples further than expected | Low–moderate. `taskRel_eq_iter` has several consumers (`Nomic/ZTime.lean`, `IntNormalFormEffective.lean`, `Periodicity`) | Additive only: add the `_of_constraints` form, leave `taskRel_eq_iter` untouched as the wrapper. No consumer is re-routed |
| The `sepFrame` witness pulls `StateTopology` into the chain's import closure | Real, and it would violate a recorded architectural decision | Land the witness **inside** the leaf `ConstraintWitnesses.lean`, or in `Tests/BimodalTest/`. Never import it from `Semantics/` |
| The weakened headline looks stronger than it is, because `FrameClass.Sat` still demands `IsRegular` | Real presentational risk | State in the docstring that the weakening is on the **transfer-from** side only, and that class membership of the countermodel still requires *Saturation* — which the cover has by `saturation_of_orientedForest`. Finding 7 has the wording |
| Correcting the four "Constraints consumed" lines is forgotten | Moderate; they are the reason the question looked open | Make step 2 an explicit plan objective with its own verification, not a drive-by edit |
| `ConstraintWitnesses.lean`'s docstring correction (step 5) is read as a record-versioning edit | Low | State the current fact (`srel` does carry a `FrameOver` wrapper, via this reflection law) without narrating the prior draft |

## Tactic Survey Results

No `lean_multi_attempt` tactic search was performed: the implementation re-uses the existing proof
bodies unchanged, so there was no open goal to search for. What was surveyed instead was whether
each `[IsRegular]` projection has an explicit-hypothesis replacement that type-checks in situ —
verified by compiling the transplanted chain.

| Goal | Tactic / term | Result | Premises/Config |
|---|---|---|---|
| base-side reflection at `δ ≠ 0` | `TaskFrame.reflect_reflection_of_ne (P := F.PosRel) hδne` | success | no frame constraint |
| source-side reflection | `F'.reflection_of_limit hlim'` | success | *Limit* |
| `F'.nullity` replacement | `TaskFrame.nullity_of_serial_limit hser' hlim'` | success | *Seriality* + *Limit* |
| `F'.forward_comp` replacement | `TaskFrame.forward_of_comp hcomp'` | success | *Compositionality* |
| `δ ≠ 0` for `δ = intIso.symm 1` | `congrArg intIso` + `OrderAddMonoidIso.apply_symm_apply` + `one_ne_zero` | success | — |
| `srel` reflection law | `rw [srel_iff, srel_iff, abs_sub_comm]; norm_num` | success | — |
| whole chain, no `IsRegular` | `lake env lean` on the probe | exit 0, no errors, no `sorry` | one unused-binder linter warning |

## Context Extension Recommendations

- **Topic**: auditing which `IsRegular` field a declaration actually projects.
- **Gap**: `context/project/lean4/patterns/dependency-tracing.md` covers mechanical dependency
  tracing and explains why `#print axioms` cannot answer it, but nothing records the specific,
  repeatable technique that settled this task: *transplant the declaration chain into a scratch
  file with the instance binder replaced by explicit constraint hypotheses and compile with
  `lake env lean`*. That technique is cheap (two iterations here), decisive, and doubles as the
  implementation's feasibility proof.
- **Recommendation**: add a short "Instance-binder audit by transplant" section to
  `context/project/lean4/patterns/dependency-tracing.md`, citing
  `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean` as the
  worked example, and noting the companion repo convention that a declaration's
  "Constraints consumed:" docstring line is an *assertion to be audited*, not evidence.

## Appendix

### Probe commands

```
lake env lean /tmp/.../scratchpad/Probe898.lean     # exit 0 (3 iterations)
lake env lean /tmp/.../scratchpad/Probe898b.lean    # exit 0
```

Saved as:
- `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean`
- `specs/evidence/history-morphism-saturation-audit/non-saturated-frameover-witness.lean`

### Search queries used

`lean_local_search` / `lean_leansearch` / `lean_loogle` / `lean_leanfinder` were **not** called: no
external or unknown lemma was sought, and every ingredient was located by `grep` over
`FormalSystem/` and confirmed by compilation. Per the dispatch's `<lean-readiness-context>`, the
evidence tier is therefore compiled-probe rather than LSP-index, which is the stronger of the two.
Greps used: `IsRegular`, `Saturation`, `reflection`, `nullity`, `forward_comp`,
`taskRel_eq_iter`, `TwoWayBounded`, `exists_histMorphism_of_isZTime`, `not_srel_saturation`,
`FrameClass.Sat`.

### Key source references

- `FormalSystem/Semantics/HistoryMorphism.lean:306,382,434,445,469,530,590` — the seven binders
- `FormalSystem/Semantics/TaskFrame.lean:369` — `reflect_reflection_of_ne` (no constraint)
- `FormalSystem/Semantics/TaskFrame.lean:1189` — `class IsRegular` (`comp`, `serial`, `limit`,
  `saturation`)
- `FormalSystem/Semantics/TaskFrame.lean:1275,1356,1403,1421` — `nullity`, `forward_comp`,
  `reflection_of_limit`, `reflection`
- `FormalSystem/Semantics/TaskFrame.lean:872` — the recorded minimality convention
- `FormalSystem/Semantics/TaskFrame.lean:1479` — `FrameOver.ofReflective` (constraint-free)
- `FormalSystem/Semantics/IntNormalForm.lean:204,232` — `taskRel_natCast_iff_iter`,
  `taskRel_eq_iter`
- `FormalSystem/Semantics/UniversalCover.lean:443,465,507` — `coverFrame`,
  `endpt_twoWayBounded`, `exists_orientedForest_cover`
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean:1041-1290` — `SeparatingFrame`
- `FormalSystem/Semantics/FrameClassValidity.lean:153-156` — `FrameClass.Sat`
- `FormalSystem/Metalogic/NamingRules.lean:64-95` — the recorded Saturation obstruction
