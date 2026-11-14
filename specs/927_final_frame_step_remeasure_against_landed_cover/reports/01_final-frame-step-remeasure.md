# Research Report: Task #927

**Task**: 927 - Final frame step: remeasure against the landed cover
**Started**: 2026-11-13T00:00:00Z
**Completed**: 2026-11-13T00:00:00Z
**Effort**: medium (one dispatch, measurement only; three compiled probes, no library change)
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Semantics/UniversalCover.lean` (read, signatures at 591-624, construction at 440-500)
- `FormalSystem/Semantics/HistoryMorphism.lean` (read, 116-250, 530-716)
- `FormalSystem/Semantics/IntNormalForm.lean` (read, 492-652)
- `FormalSystem/Semantics/OrientedForest.lean` (read, 820-882)
- `FormalSystem/Semantics/TaskFrame.lean` (read, 1072-1560)
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` (read, 1590-1662)
- `FormalSystem/PlusLanguage/PlusIntTransfer.lean` (read, 140-200)
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` (read, §13.1, §15, ingredient table, Risks)
- lean-lsp MCP `lean_run_code` (three compiled probes, all sorry-free)
- git history (landing timestamps)
**Artifacts**:
- `specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The final-frame step of the paper proof's §15 is DISCHARGED by landed declarations.** A
  compiled, sorry-free probe composes `exists_orientedForest_cover_of_constraints` (whose
  *Saturation* comes from `saturation_of_orientedForest` internally) with
  `HistMorphism.onto` and carries satisfiability off an arbitrary nonempty carrier with a
  bi-serial one-step relation onto a genuine `FrameClass.Sat .ZTime` member. Axiom profile:
  `[propext, Classical.choice, Quot.sound]`. No finiteness, no base *Saturation*, no further
  hypothesis.
- **The source-side obligation is already met, and is smaller than anticipated.** Of the three
  constraints the cover theorem demands of the chronicle quotient, *Compositionality* and *Limit*
  are **free** for any `ofStepRel`-generated relation over `ℤ` (from `iter_add` and
  `limit_of_succOrder` respectively), and *Seriality* reduces **exactly** to the double seriality
  of `R` that §13.1 establishes from chronicle clause L1. None of the three is doubtful; the
  quotient's countably infinite slices are irrelevant to all three.
- **One real gap, and it is packaging, not mathematics.** The three constraint proofs and the
  reflection law for `ofStepRel R₁` exist in the library only as **inline anonymous lambdas
  inside `FrameOver.ofStepSat`'s body** (`IntNormalForm.lean:563-595`), not as named theorems.
  Consequently there is no landed constructor presenting an infinite, non-saturated carrier as a
  `FrameOver intOrder` with those three constraints citable: `ofStepSat` demands *Saturation* as
  a hypothesis and `ofStep` demands `[Finite W]`. All four proofs reproduce verbatim and compile.
- **901's `missing` ingredient row and its "weakest link" Risks paragraph are STALE, not
  wrong-at-the-time.** The report landed 2026-11-09 11:40; `UniversalCover.lean` first landed
  15:48 the same day and the *Saturation*-free headline at 17:56. Amendment text for both
  surfaces is supplied below; neither surface is edited here.
- **This closes the paper proof's one acknowledged gap. It does not make T3 complete.** Rows 17-21
  remain paper, (O1)/(O3) are untouched, and the automata work is unmoved.

## Context & Scope

The question: given that both Lean pieces the paper proof named as missing for its final-frame
step have since landed, is that step still open?

Measurement only. No Lean file in the repository was written or edited; the three probes were run
through `lean_run_code` and are reproduced in the Appendix as text. No part of §§7-15 was
formalized, and no completeness claim is made. Every declaration signature below was read from
source, never from a report's description of it — 901's own stale row is the cautionary case the
dispatch names, and it is confirmed stale below.

## Findings

### Codebase Patterns

**The landed cover headline, read from `UniversalCover.lean:591-606`:**

```lean
theorem exists_orientedForest_cover_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (M : TaskModel F.toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' F, g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ
```

No `[F.IsRegular]`, no `[Finite F.WorldState]`, no *Saturation* on `F`. The cover `F'` is
`coverFrameOfSerial F hser`, regular by `coverFrameOfSerial_isRegular`, whose *Saturation* field
is `saturation_of_orientedForest coverStep_isOrientedForest` (`UniversalCover.lean:480`) — so the
trio's second member is consumed **inside** the headline, not alongside it.

**A naming precision worth stating.** The dispatch calls the chronicle quotient "the source
side". In `plus_invariance_of_isZTime_of_constraints` the quotient is in fact the **target** `F`
and the cover is the source `F'`; it is there that the quotient genuinely contributes nothing.
But `exists_orientedForest_cover_of_constraints` takes the three constraints on `F` — the
quotient — because `endpt_twoWayBounded_of_constraints F hcomp hser hlim` reads all three and
`coverFrameOfSerial F hser` reads *Seriality* at duration `1`. So the dispatch's substance is
exactly right (the obligation that remains is *Compositionality*, *Seriality*, *Limit* on the
quotient) even though the "source" label belongs to the cover.

**The invariance theorem, read from `HistoryMorphism.lean:681-692`:** `hcomp'`, `hser'`, `hlim'`
are all on `F'` (the source/cover); `F` (the base) carries **no binder at all** beyond
`FrameOver D`. The `[F.IsRegular]` binder survives only on the specialised forms
(`plus_invariance_of_isZTime`, `exists_histMorphism_of_isZTime`), each carrying
`@[nolint unusedArguments]` with an explicit comment that the binder is genuinely unread and
retained only for signature stability. **901's named negative evidence is therefore directly
answered in source.**

**`HistMorphism` bundles `onto`** (`HistoryMorphism.lean:122-125`): every history of the base is
the image of a history of the source. This is the field the completeness direction needs, and the
cover headline hands back a full `HistMorphism`, not a bare `HistMap`.

**The non-vacuity witness is landed too.** `SeparatingFrame.exists_nonSaturated_base_orientedForest_cover`
(`ConstraintWitnesses.lean:1647-1659`) exhibits a concrete `FrameOver intOrder` that is
*Compositional*, *Serial*, *Limit* and **provably not** *Saturated*
(`sepFrame_not_saturation`), to which the headline applies. So the weakening is not a cosmetic
restatement of a theorem whose hypotheses were already met.

**The one structural gap.** The only landed step-relation-to-frame constructors are:

| Constructor | Site | What it demands |
|---|---|---|
| `FrameOver.ofStepSat` | `IntNormalForm.lean:563` | `TaskFrame.Saturation (ofStepRel R₁)` as a hypothesis |
| `FrameOver.ofStep` | `IntNormalForm.lean:633` | `[Finite W]` (consumed solely to get *Saturation*) |
| `FrameOver.ofReflective` | `TaskFrame.lean:1479` | the reflection law only — **but yields no constraints** |

The three constraint proofs `ofStepSat` supplies to `ofReflectiveRegular` are inline anonymous
lambdas in its body; a grep for `Compositional (ofStepRel`, `Serial (ofStepRel`,
`Limit (ofStepRel` across `FormalSystem/` returns nothing. The chronicle quotient has a countably
infinite carrier and unknown *Saturation*, so it can use neither `ofStepSat` nor `ofStep`, and
`ofReflective` leaves the three constraints to be re-proved at the call site.

### External Resources

No Mathlib search was needed: every ingredient is project-local. The `--lit` corpus was not
consulted — the question is about landed Lean signatures, and the literature (Reynolds 2001 §14.1)
stops at "(S,R,g) is a Kripke structure", which is precisely why the cover step has no source to
be faithful to.

### Finding (1): Do the three landed declarations discharge the final-frame step as §15 states it?

**Yes, as stated, with the quotient presented through `FrameOver.ofReflective`.**

§15.3 states the step as: replace `S` by its universal cover `S̃`, which is an oriented forest
hence saturated by `saturation_of_orientedForest`, doubly serial, and carries a surjective
two-way-bounded covering map `π : S̃ → S`; transfer truth along `π`. Every clause of that
sentence is a conclusion of `exists_orientedForest_cover_of_constraints`:

| §15.3 clause | Landed conclusion |
|---|---|
| cover `S̃` is a frame over `ℤ` | `∃ F' : FrameOver intOrder` |
| …saturated by `saturation_of_orientedForest` | `F'.IsRegular`, whose `saturation` field *is* that theorem |
| …doubly serial | bundled in `F'.IsRegular`'s `serial` field |
| surjective covering map `π` | `Function.Surjective f` |
| two-way bounded | `TwoWayBounded f` |
| transfer truth along `π` | the `PlusTruthAt` biconditional, plus `HistMorphism.onto` for the direction completeness uses |

Compiled gate, probe A in the Appendix: for an arbitrary `W` with `[Nonempty W]` and an arbitrary
bi-serial `R₁ : W → W → Prop`, the full conclusion is produced. `#print axioms` reports
`[propext, Classical.choice, Quot.sound]` — sorry-free, no project axiom.

Probe C strengthens this to the shape completeness actually consumes: from
`PlusTruthAt M τ t φ` on the quotient, it produces `G : TaskFrame` with
`FrameClass.Sat FrameClass.ZTime G`, a model, a history and a time at which `φ` holds. Also
sorry-free, same axiom profile. The `.ZTime` membership goes through
`⟨hreg, TaskFrame.isZTime_of_instances _⟩`, the same bridge `plusValidZTime_iff_plusValidInt`
uses.

**The one qualification.** The composition is available *given a `FrameOver intOrder` presentation
of the quotient*. Producing that presentation costs four small lemmas that are not currently
named (see Finding (2)); every one of them compiles, transcribed verbatim from `ofStepSat`'s body.

### Finding (2): The source-side obligation, stated precisely

The obligation is: `TaskFrame.Compositional F.TaskRel`, `TaskFrame.Serial F.TaskRel`,
`TaskFrame.Limit F.TaskRel`, where `F` is the chronicle quotient presented as a
`FrameOver intOrder` with `F.TaskRel = ofStepRel R` and `R` the quotient's one-step relation
(§13.1: `R := {([x],[y]) : ∃ x' ≡ x with (x')⁺ ≡ y}`).

**What each requires, and whether the quotient satisfies it.**

**(a) *Compositionality* — `∀ w v x y, 0 ≤ x → 0 ≤ y → (R w (x+y) v ↔ ∃ u, R w x u ∧ R u y v)`,
the paper's biconditional whole.** For `ofStepRel R`, this is `iter_add` plus
`Int.natAbs` arithmetic. It is a theorem about iterates, **wholly independent of `R`** — true for
every relation on every carrier. It reads nothing about slices, fibres, or cardinality.
**Satisfied, free.** Verified: probe A's `ofStepRel_compositional`.

**(b) *Seriality* — at every state and every nonnegative duration, a forward and a backward
witness.** For `ofStepRel R` this reduces, through `exists_iter_fwd`/`exists_iter_bwd`, **exactly
and only** to `(∀ w, ∃ u, R w u)` and `(∀ w, ∃ v, R v w)` — double seriality of the one-step
relation, nothing more. §13.1 establishes precisely that: "By L1, `R` is **doubly** serial: every
state has an `R`-successor and an `R`-predecessor." **Satisfied, from the chronicle clause the
paper proof already cites.** Verified: probe A's `ofStepRel_serial`.

**(c) *Limit* — `∀ w u, (∀ x > 0, ∃ y, |y| < x ∧ R w y u) → u = w`.** Over `ℤ` this is
`TaskFrame.limit_of_succOrder`: the only `y` with `|y| < Order.succ 0 = 1` is `y = 0`, and
`ofStepRel R w 0 u` forces `u = w` by `iter` at `0`. Again **wholly independent of `R`**, and
specifically independent of discreteness of the *carrier* — it is discreteness of the *duration
order* that pays. **Satisfied, free.** Verified: probe A's `ofStepRel_limit`.

**Which of the three is not evidently satisfied: none.** The dispatch's expectation that this
finding would carry the most content is not borne out, and the reason is structural and worth
recording: all three constraints are conditions on the **task relation generated by iterating
`R`**, and iteration is what makes two of them automatic. The quotient's awkward features — a
countably infinite carrier, countably infinite slices, states with many predecessors and many
successors — are exactly the features that bear on *Saturation*, which is the one constraint the
cover theorem no longer asks of it.

**What is actually missing is API packaging, and it is precisely bounded.** To present the
quotient as a `FrameOver intOrder` without *Saturation*, a consumer needs four declarations that
do not exist by name:

1. `ofStepRel_reflective : ∀ w d u, ofStepRel R₁ w d u ↔ ofStepRel R₁ u (-d) w` — the reflection
   law `FrameOver.ofReflective` demands (inline at `IntNormalForm.lean:567-575`).
2. `ofStepRel_compositional : TaskFrame.Compositional (ofStepRel R₁)` (inline at `:576-585`).
3. `ofStepRel_serial : (∀ w, ∃ u, R₁ w u) → (∀ w, ∃ v, R₁ v w) → TaskFrame.Serial (ofStepRel R₁)`
   (inline at `:586-592`).
4. `ofStepRel_limit : TaskFrame.Limit (ofStepRel R₁)` (inline at `:593-595`).

Plus one constructor, `ofStepPlain R₁ := FrameOver.ofReflective W (ofStepRel R₁) ofStepRel_reflective`,
whose `TaskRel` equation is `FrameOver.ofReflective_taskRel_eq` verbatim. All five compile
exactly as transcribed (probe A). This is a refactor of `ofStepSat`'s body into named lemmas it
would then cite, not new mathematics — `ofStepSat` would become `ofStepPlain` plus the
`ofReflectiveRegular` wrapper, and no existing signature need change.

**No blocker under guardrail (f).** §15.1 and §13.1 state the quotient precisely enough for this
check: the check needs only that `R` is doubly serial and that the frame is generated from `R` by
`ofStepRel`/`iter`, both of which §15.1 asserts explicitly. Nothing further about the chronicle
had to be invented.

### Finding (3): Verdict on 901's ingredient row and Risks paragraph

**Verdict: STALE, both of them — and stale rather than wrong-at-the-time.**

Measured landing times (git, `--date=iso`):

| Event | Timestamp |
|---|---|
| 901's report committed (`task 901: complete research`) | 2026-11-09 11:40:12 -0800 |
| `UniversalCover.lean` first added (`task 897 phase 3`) | 2026-11-09 15:48:11 -0800 |
| Saturation-free lift chain (`task 898 phase 1`) | 2026-11-09 17:32:33 -0800 |
| Saturation-free cover headline (`task 898 phase 3`) | 2026-11-09 17:56:31 -0800 |

The report preceded both pieces by four to six hours on the same day. The row was accurate when
written; it has been stale since 17:56 that evening. The line-number citations in the adjacent
row have also drifted (`OrientedForest.lean:134` → `:880`; `HistoryMorphism.lean:589` → `:681`
for the `_of_constraints` form, `:707` for the regular form).

**Amendment for the ingredient table row** (`reports/01_two-sided-reynolds-engine-paper-proof.md`,
the final row of the table at line 110). Replace:

```
| universal cover; invariance with no *Saturation* on the base | **missing** | the two Lean pieces the final-frame step needs |
```

with:

```
| `exists_orientedForest_cover_of_constraints`; `plus_invariance_of_isZTime_of_constraints` | **compiled** | `UniversalCover.lean:591`, `HistoryMorphism.lean:681` — both landed 2026-11-09, after this report |
```

and update the preceding row's drifted citations to
`` `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:880`, `HistoryMorphism.lean:707` ``.

**Amendment for the Risks paragraph** (line 1001). Replace the paragraph beginning
"**Risk: the final-frame step is the weakest link and is inherited rather than advanced.**" with:

> **Amended 2026-11-13.** Both pieces this risk named as missing landed later the same day, and
> the lifting chain was audited. `exists_orientedForest_cover_of_constraints`
> (`UniversalCover.lean:591`) supplies the cover with its forest, double-seriality and
> two-way-boundedness properties; `plus_invariance_of_isZTime_of_constraints`
> (`HistoryMorphism.lean:681`) supplies invariance over a base carrying **no** `def:frame`
> constraint. The negative evidence recorded here — that `plus_invariance_of_isZTime` demands
> `[F.IsRegular]` on the base — is answered: that binder is now carried only on the specialised
> form, is marked `@[nolint unusedArguments]` with a comment recording that it is genuinely
> unread, and the general form takes no base binder at all. *Saturation* is consumed nowhere in
> the lifting chain on either side. The positive evidence recorded here (`exists_preimage_step_neg`
> using only `reflection`) is likewise discharged: at the nonzero step duration that use is
> `TaskFrame.reflect_reflection_of_ne`, a fact about how `FrameOver.TaskRel` extends `PosRel`
> rather than a constraint on the frame. What remains for §15 is API packaging, not mathematics —
> see Finding (2) of the remeasurement report.

**Amendment for the companion Risks paragraph** (line 1002, "this report is read as a
completeness proof of T3"). This one is **still accurate and needs no amendment**, with one
word's worth of correction: "one step (the final frame) resting on two unlanded pieces" should
read "one step (the final frame), now resting on landed pieces". The paragraph's substantive
claim — that the whole rests on no machine checking — survives intact and is the reason finding
(4) below is not a completeness claim.

**Section 15.3's own prose** ("**The two missing pieces, named.**") is stale by the same measure;
its replacement text is the Risks amendment above, and 15.2's assessment of *why* the quotient's
own *Saturation* is doubtful (countably infinite slices, many predecessors and successors) remains
correct and load-bearing — it is the reason the cover is needed at all, and it is untouched.

Per guardrail (e), nothing above was applied: these are amendment texts for a successor.

### Finding (4): Is the final-frame step discharged?

**CONDITIONALLY DISCHARGED. The condition is a named, compiled, four-lemma API refactor, not an
open mathematical question.**

Precisely:

- **The mathematics is done.** Every substantive ingredient §15.3 names is landed and compiles,
  and their composition is sorry-free at the standard axiom profile for an arbitrary nonempty
  carrier with a bi-serial one-step relation (probes A, B, C).
- **The condition.** The chronicle quotient must be presented as a `FrameOver intOrder`. The only
  landed presentations from a step relation demand either *Saturation* (`ofStepSat`) or
  `[Finite W]` (`ofStep`), neither of which the quotient has. The `ofReflective` route needs the
  four constraint lemmas named in Finding (2), which exist in the library only as inline lambdas.
  All four compile verbatim.
- **What is NOT claimed.** This does not make T3 complete. The paper proof's §§7-14 remain paper;
  rows 17-21 of the ingredient table remain paper; (O1) — `Muller.toRabin_exists` is a
  `proof_wanted` — and (O3) — determinization arrives as an existential over `Type`, not as the
  syntax the Auxiliary-Atoms rule needs — are untouched by anything here, as is (O4). The gap
  this closes is the one §15 itself acknowledged, and no other.
- **What the step buys, stated exactly.** Satisfiability of an L⁺ formula on the chronicle
  quotient transfers to satisfiability at a `FrameClass.Sat .ZTime` member. The weakening is on
  the transfer-*from* side only: `FrameClass.Sat` still demands `FrameOver.IsRegular` of a
  frame-class member, and the cover is the frame-class member of record — its *Saturation* comes
  from `saturation_of_orientedForest`, not from the quotient.

### Recommendations

- **Land the four `ofStepRel` constraint lemmas plus an `ofStepPlain` constructor as named
  declarations in `IntNormalForm.lean`, and rewrite `ofStepSat`'s body to cite them.** Statements
  and proofs are given verbatim in the Appendix. `ofStepSat` becomes `ofStepPlain` wrapped by
  `ofReflectiveRegular`, so no existing signature changes and no proof is duplicated.
  [VERIFIED: PASS — all four lemmas plus the constructor and its `TaskRel` equation elaborated via
  `lean_run_code` against `FormalSystem.Semantics.UniversalCover`; `#print axioms` on the
  downstream composition reports `[propext, Classical.choice, Quot.sound]`, sorry-free]
- **Record `final_frame_step_ztime` (probe C's statement) as the paper proof's §15 obligation in
  its compiled form**, in whatever record tracks §15's status. It is the smallest statement that
  says what §15 needs: quotient satisfiability ⇒ `.ZTime` frame-class satisfiability.
  [VERIFIED: PASS — elaborated sorry-free; `.ZTime` membership via
  `⟨hreg, TaskFrame.isZTime_of_instances _⟩`]
- **Apply the three amendment texts of Finding (3) to the 901 report**, as a successor task. Do
  not re-measure: the timestamps and signatures are recorded above.
  [No compiled gate applicable]
- **Do not read finding (4) as licensing a formalization of §§7-15.** Recommendation 8 of the 901
  report stands; nothing here moves (O1), (O3) or (O4).
  [No compiled gate applicable]
- **Do not restate §15.2 as stale.** Its assessment that the quotient's own *Saturation* is
  doubtful is correct and is the reason the cover route exists; only §15.3's "two missing pieces"
  paragraph and the ingredient row are stale.
  [No compiled gate applicable]

## Decisions

1. **The composition is reported as a finding with declaration names, not landed.** Guardrail (b).
   The probes ran through `lean_run_code`; no `.lean` file in the repository was created or
   modified, and the probe text lives in this report's Appendix rather than in a repository probe
   file.
2. **The verdict is "conditionally discharged", not "discharged".** The condition is real — no
   landed route presents the quotient as a `FrameOver intOrder` today — even though it is small
   and compiled. Reporting it as flatly discharged would overstate what a consumer can cite.
3. **The dispatch's "source side" label is corrected in passing, not adopted.** The quotient is
   the *target* of the morphism; the cover is the source. The dispatch's substance (the obligation
   is the three constraints on the quotient) is correct and is what Finding (2) answers.
4. **Finding (2) is reported as smaller than anticipated rather than padded.** The dispatch
   expected it to carry the most content. Two of the three constraints are relation-independent
   theorems about iterates; saying so briefly and showing the compiled proofs is the honest
   report.
5. **No `user_decision` is raised.** The dispatch names a measurement and four findings; all four
   are delivered, and the one downstream choice (whether to land the API refactor) is an ordinary
   implementation decision with no external cost or preference the artifacts cannot infer.

## Risks & Mitigations

- **Risk: the probes prove the composition for `ofStepRel R` at an abstract carrier, not for the
  chronicle quotient itself.** The quotient is not formalized and this task does not formalize it
  (guardrail c). *Mitigation*: the probes' hypotheses are exactly `[Nonempty W]` plus double
  seriality of `R`, and §13.1 asserts both for the quotient (L1 gives double seriality; the
  quotient is non-empty since `T` is). Universal quantification over `W` and `R₁` means no
  property of the quotient beyond those two can be needed. If §13.1's double-seriality claim were
  wrong, *Seriality* would fail — but that claim is 901's own, is Reynolds' own, and is not
  re-opened here.
- **Risk: the four inline-lambda proofs are transcribed, so a future change to `ofStepSat` could
  diverge from them.** *Mitigation*: the recommendation is to refactor `ofStepSat` to cite the
  named lemmas rather than to duplicate them, which makes divergence impossible.
- **Risk: "conditionally discharged" is read as "discharged" downstream.** *Mitigation*: the
  condition is named in the Executive Summary, in Finding (4), and in Decision 2, and the
  amendment text of Finding (3) states it as "API packaging, not mathematics" rather than as
  closure.
- **Risk: this is read as advancing T3 completeness.** *Mitigation*: stated in the Executive
  Summary, in Finding (4)'s "What is NOT claimed", and in the recommendation that explicitly
  declines to license a §§7-15 formalization. Rows 17-21 remain paper and (O1)/(O3)/(O4) are
  untouched.

## Tactic Survey Results

The protocol was invoked only insofar as the three probes are themselves goal-closing attempts;
no tactic portfolio was surveyed against an open goal, because no goal here was open — each probe
either elaborated on the first attempt or failed on a transparency issue with a mechanical fix.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `TaskFrame.Compositional ((ofStepPlain R₁).TaskRel)` via `rw [ofStepPlain_taskRel]` | `rw` then `omega`/`iter_add` | fail | `rw` could not match: after rewriting, states have type `(ofStepPlain R₁).WorldState`, not syntactically `W`; the `IntNormalForm.lean:1525` docstring records this exact trap for `ofReflective` |
| same, restated as a bare-relation lemma then transported by `▸` | `intro`/`rw [ofStepRel_of_nonneg]`/`iter_add`/`exists_congr` | success | `iter_add`, `ofStepRel_of_nonneg`, `omega` |
| `TaskFrame.Serial (ofStepRel R₁)` from `fwd`/`bwd` | `intro`/`obtain`/`exact` | success | `exists_iter_fwd`, `exists_iter_bwd`, `ofStepRel_of_nonneg` |
| `TaskFrame.Limit (ofStepRel R₁)` | term-mode | success | `TaskFrame.limit_of_succOrder`, `ofStepRel_of_nonneg`, `simpa [eq_comm]` |
| `FrameClass.Sat FrameClass.ZTime F'.toTaskFrame` for regular `F' : FrameOver intOrder` | `exact?` | fail | the bridge is `⟨inferInstance, TaskFrame.isZTime_of_instances _⟩`, an anonymous constructor `exact?` does not reach; found by reading `plusValidZTime_iff_plusValidInt` |

The one transferable lesson: at a frame built by `FrameOver.ofReflective`, prove constraints as
bare-relation lemmas and transport with `▸`, never by rewriting the frame's `TaskRel` in place.

## Context Extension Recommendations

- **Topic**: presenting a non-saturated infinite carrier as a `FrameOver intOrder`.
- **Gap**: `context/project/lean4/` documents the MCP toolchain and the build contract, but
  nothing records the frame-presentation decision tree (`ofStep` vs `ofStepSat` vs `ofReflective`
  vs `ofReflectiveRegular`), nor the `▸`-transport idiom the Tactic Survey above isolates. A
  consumer reaching for `ofStepSat` and finding it demands *Saturation* currently has no pointer
  to the `ofReflective` route.
- **Recommendation**: a short `context/project/lean4/patterns/frame-presentation.md` carrying the
  four-constructor table of this report's "Codebase Patterns" section plus the transport idiom.
  Worth writing only if the API refactor recommended above is NOT done; if it is, `ofStepPlain`
  becomes the obvious answer and the context file is redundant.

## Appendix

### Probe A — the composition, end to end (compiled, sorry-free)

Run via `lean_run_code`. Axiom profile of `final_frame_step`:
`[propext, Classical.choice, Quot.sound]`.

```lean
import FormalSystem.Semantics.UniversalCover
open FormalSystem FormalSystem.Semantics FormalSystem.PlusLanguage
variable {W : Type} [Nonempty W]

theorem ofStepRel_reflective (R₁ : W → W → Prop) :
    ∀ w d u, ofStepRel R₁ w d u ↔ ofStepRel R₁ u (-d) w := by
  intro w d u
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
           fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩
  · rintro ⟨h1, h2⟩
    exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
           fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩

theorem ofStepRel_compositional (R₁ : W → W → Prop) :
    TaskFrame.Compositional (ofStepRel R₁) := by
  intro w v x y hx hy
  change (0 : ℤ) ≤ x at hx
  change (0 : ℤ) ≤ y at hy
  rw [ofStepRel_of_nonneg (add_nonneg hx hy)]
  have hnat : (x + y).natAbs = x.natAbs + y.natAbs := by omega
  rw [hnat, iter_add]
  exact exists_congr fun u => by
    rw [ofStepRel_of_nonneg hx, ofStepRel_of_nonneg hy]

theorem ofStepRel_serial (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) :
    TaskFrame.Serial (ofStepRel R₁) := by
  intro w x hx
  constructor
  · obtain ⟨u, hu⟩ := exists_iter_fwd fwd x.natAbs w
    exact ⟨u, (ofStepRel_of_nonneg hx w u).mpr hu⟩
  · obtain ⟨v, hv⟩ := exists_iter_bwd bwd x.natAbs w
    exact ⟨v, (ofStepRel_of_nonneg hx v w).mpr hv⟩

theorem ofStepRel_limit (R₁ : W → W → Prop) :
    TaskFrame.Limit (ofStepRel R₁) :=
  TaskFrame.limit_of_succOrder fun w u h => by
    rw [ofStepRel_of_nonneg (le_refl (0 : ℤ))] at h
    simpa [eq_comm] using h

def ofStepPlain (R₁ : W → W → Prop) : FrameOver intOrder :=
  FrameOver.ofReflective W (ofStepRel R₁) (ofStepRel_reflective R₁)

theorem ofStepPlain_taskRel (R₁ : W → W → Prop) :
    (ofStepPlain R₁).TaskRel = ofStepRel R₁ :=
  FrameOver.ofReflective_taskRel_eq

theorem final_frame_step (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w)
    (M : TaskModel (ofStepPlain R₁).toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular)
      (f : F'.WorldState → (ofStepPlain R₁).WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' (ofStepPlain R₁), g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ :=
  exists_orientedForest_cover_of_constraints (ofStepPlain R₁)
    ((ofStepPlain_taskRel R₁) ▸ ofStepRel_compositional R₁)
    ((ofStepPlain_taskRel R₁) ▸ ofStepRel_serial R₁ fwd bwd)
    ((ofStepPlain_taskRel R₁) ▸ ofStepRel_limit R₁) M
```

### Probe B — satisfiability transfer to a regular cover (compiled, sorry-free)

Same preamble as probe A; axiom profile `[propext, Classical.choice, Quot.sound]`.

```lean
theorem sat_transfer_to_regular_cover (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w)
    (M : TaskModel (ofStepPlain R₁).toTaskFrame)
    (τ : WorldHistory (ofStepPlain R₁).toTaskFrame) (t : ↑intOrder) (φ : PlusFormula)
    (hsat : PlusTruthAt M τ t φ) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (M' : TaskModel F'.toTaskFrame)
      (τ' : WorldHistory F'.toTaskFrame), PlusTruthAt M' τ' t φ := by
  obtain ⟨F', hreg, f, _hb, _hs, g, _hgf, hinv⟩ :=
    exists_orientedForest_cover_of_constraints (ofStepPlain R₁)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_compositional R₁)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_serial R₁ fwd bwd)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_limit R₁) M
  obtain ⟨τ', hτ'⟩ := g.onto τ
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  exact ⟨F', hreg, g.pullM M, τ', (hinv φ τ' t).mpr (by rw [hm]; exact hsat)⟩
```

### Probe C — the `.ZTime` frame-class form (compiled, sorry-free)

Adds `import FormalSystem.PlusLanguage.PlusIntTransfer` and
`open FormalSystem.ProofSystem`; axiom profile `[propext, Classical.choice, Quot.sound]`.

```lean
theorem final_frame_step_ztime (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w)
    (M : TaskModel (ofStepPlain R₁).toTaskFrame)
    (τ : WorldHistory (ofStepPlain R₁).toTaskFrame) (t : ↑intOrder) (φ : PlusFormula)
    (hsat : PlusTruthAt M τ t φ) :
    ∃ (G : TaskFrame) (_ : FrameClass.Sat FrameClass.ZTime G) (M' : TaskModel G)
      (τ' : WorldHistory G) (t' : G.Duration), PlusTruthAt M' τ' t' φ := by
  obtain ⟨F', hreg, f, _hb, _hs, g, _hgf, hinv⟩ :=
    exists_orientedForest_cover_of_constraints (ofStepPlain R₁)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_compositional R₁)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_serial R₁ fwd bwd)
      ((ofStepPlain_taskRel R₁) ▸ ofStepRel_limit R₁) M
  obtain ⟨τ', hτ'⟩ := g.onto τ
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  exact ⟨F'.toTaskFrame, ⟨hreg, TaskFrame.isZTime_of_instances _⟩, g.pullM M, τ', t,
    (hinv φ τ' t).mpr (by rw [hm]; exact hsat)⟩
```

### Searches and reads

- `grep -rn "Compositional (ofStepRel\|Serial (ofStepRel\|Limit (ofStepRel\|Saturation (ofStepRel"
  --include=*.lean FormalSystem/` — only `Saturation` hits; no named `Compositional`/`Serial`/`Limit`
  lemma at `ofStepRel`. This is the grep behind Finding (2)'s gap claim.
- `grep -rn "FrameOver.ofReflective \|ofReflective W" --include=*.lean FormalSystem/` — three call
  sites, all in `ConstraintWitnesses.lean`, none from a step relation.
- `git log --format='%ad | %s' --date=iso` on the 901 report path, `UniversalCover.lean`, and the
  two 898 phase commits — the staleness timestamps of Finding (3).
- No rate-limited Mathlib search tool was called; no MCP failure or rate limit occurred.
  `lean_run_code` was used three times and succeeded on the second, third and fourth attempts
  (the first failed on the transparency issue recorded in the Tactic Survey).

### Evidence tier by claim

| Claim | Tier |
|---|---|
| `exists_orientedForest_cover_of_constraints`'s signature; no base `IsRegular`/`Finite`/Saturation | compiled, read from source (`UniversalCover.lean:591-606`) |
| The cover's *Saturation* is `saturation_of_orientedForest` | compiled, read (`UniversalCover.lean:480`) |
| `plus_invariance_of_isZTime_of_constraints` takes constraints on the source only | compiled, read (`HistoryMorphism.lean:681-692`) |
| The `[F.IsRegular]` base binder is genuinely unread on the specialised forms | compiled, read (`HistoryMorphism.lean:652-663`, `702-714`, `@[nolint unusedArguments]`) |
| `HistMorphism` bundles `onto` | compiled, read (`HistoryMorphism.lean:122-125`) |
| A non-saturated base witness exists for the headline | compiled, read (`ConstraintWitnesses.lean:1647-1659`) |
| The four `ofStepRel` constraint lemmas are inline, not named | measured (grep, above) |
| The composition discharges §15.3 as stated | compiled this dispatch (probes A, B, C), sorry-free |
| The quotient satisfies all three constraints | derived (probes A/C at an arbitrary carrier, plus §13.1's double seriality) |
| 901's row and Risks paragraph are stale, not wrong-at-the-time | measured (git timestamps, above) |
| §13.1's double seriality of `R` from L1 | carried (901, not re-verified) |
| (O1), (O3), (O4) unmoved | carried (901 §17, not re-measured) |
