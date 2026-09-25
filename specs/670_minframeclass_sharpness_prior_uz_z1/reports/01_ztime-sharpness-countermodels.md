# Research Report: Task #670

**Task**: 670 - Machine-check the MINIMALITY half of `Axiom.minFrameClass` for the two `.ZTime` axioms, `prior_UZ` and `z1`
**Started**: 2026-09-24T00:00:00Z
**Completed**: 2026-09-24T00:00:00Z
**Effort**: Small-to-medium (the mathematics is done; the residual cost is repository hygiene and one full rebuild)
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/`), lean-lsp MCP (`lean_run_code` for end-to-end verification)
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/Semantics/Frames/Standard.lean`
- `FormalSystem/Metalogic/Conservativity/DenseObstructionTransfer.lean` (structural template)
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` (the frame-versus-model caveat)
- Literature: Reynolds 1992 §10 / Venema 1993 (W) for `prior_UZ`; Doets 1987 Claim 10 / Reynolds 1994 §10 for `z1` — cited in `Axioms.lean`, not re-derived here
**Artifacts**:
- `specs/670_minframeclass_sharpness_prior_uz_z1/reports/01_ztime-sharpness-countermodels.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The deliverable is already machine-verified.** A complete candidate module — 10 named
  declarations covering both axioms, the frame-level refutations, the `.Base` non-validity
  statements, the full `fc < .ZTime` minimality statements, and two underivability corollaries —
  was elaborated end to end through `lean_run_code` against the built tree with **zero errors,
  zero `sorry`, and zero new axiom declarations**. `#print axioms` on all four headline results
  reports exactly `[propext, Classical.choice, Quot.sound]`, the set `MainResults.lean` pins.
  The verbatim verified source is in the Appendix.
- **The route is not the one the dispatch anticipated, and is much cheaper.** Neither
  `Z1Countermodel.lean` nor `MinusLanguageSoundness.lean` nor `LexCarrier.lean` is needed. The
  countermodel for **both** axioms is the *translation frame over a densely ordered duration
  group* (`Semantics/Frames/Standard.lean`'s `translationFrame`, with
  `Correspondence/DurationFrames.lean`'s `translationHist` / `translationModel` /
  `translation_realizes` atom-realisation layer). This sidesteps the `tr_ne_untl` trap entirely:
  nothing is transferred from the L⁻ language, so there is no translation to get wrong.
- **Non-discreteness, not non-Archimedean-ness, is what refutes both axioms.** Each axiom fails
  over *any* dense carrier, so one lemma per axiom — stated at an arbitrary
  `(D : TemporalOrder) [DenselyOrdered ↑D]` — yields the `.Base` result at `D = ℚ` and (free of
  charge) the `.Dense` result from the same lemma at the same frame.
- **The `CoNotPriorU` obstruction does not bite.** It arises only because that theorem must
  *validate* `CO` while refuting `prior_U_gap`; a bare non-validity claim carries no such joint
  requirement, and the verified proofs are in fact **frame-level** (`¬ F.ValidOn φ`), stronger
  than the model-level form the dispatch allowed for.
- **`¬ ValidIn .Base` is the whole of minimality, not a fragment of it.** `FrameClass`'s `LE`
  instance makes `.Base` the unique class strictly below `.ZTime`, so the two `.Base` refutations
  discharge `∀ fc < .ZTime, ¬ ValidIn fc φ` outright. This is proved, not assumed
  (`eq_base_of_lt_ztime`).
- **Recommended approach**: one new module
  `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` carrying the verified content, plus
  the `Axiom.minFrameClass` docstring update, plus the repository-gate chores enumerated under
  Risks. A sorry-free path exists and is verified; no `[BLOCKED]` marking and no plan
  decomposition beyond ordinary phases is warranted.

## Context & Scope

`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean:610-617`) is a hand-assigned tag.
Its **upper** bound is machine-checked: `axiom_validIn_min` (`Metalogic/Soundness.lean:1228`)
gives `ValidIn ax.minFrameClass φ` for every constructor, lifted by `ValidIn.mono` in
`axiom_validIn` (`Soundness.lean:1278`). Its **minimality** — that `prior_UZ` and `z1` are *not*
valid at `FrameClass.Base` — is carried only by docstring literature citations
(`Axioms.lean:335-341`, `:347-356`). A repository-wide search confirms no negative validity
result names either axiom.

Researched: whether a sorry-free, axiom-free Lean proof of non-`Base`-validity exists for the two
`.ZTime` axioms at explicit atomic instances; which existing machinery supplies it; which
statement form to use; and what repository gates a new module must satisfy.

Out of scope, per the dispatch and honoured here: the `.Dense` and `.RTime` tags (recorded below
as observations for a follow-up), the compression/adequacy direction, and any ModelChecker-side
change.

## Findings

### Codebase Patterns

**1. `ValidIn` unfolds to an existential obligation that one model discharges.**

`ValidIn fc φ := ValidOnFrames fc.Sat φ := ∀ F : TaskFrame, fc.Sat F → F.ValidOn φ`
(`Semantics/Validity.lean:337,348`), and `TaskFrame.ValidOn F φ := ∀ M τ x, TruthAt M τ x φ`
(`Validity.lean:255`). `FrameClass.Sat .Base F` is `F.IsRegular` and nothing more
(`Semantics/FrameClassValidity.lean`). So `¬ ValidIn .Base φ` needs exactly one regular frame,
one model, one history and one time. No universal-valuation quantifier is in the way.

**2. Atoms are valued on world *states*, not times — and one existing frame closes that gap.**

`TruthAt`'s atom clause is `M.valuation (τ.state t) p` (`Semantics/Truth.lean:234`), so a
time-varying atom needs a history whose state varies with time. `translationFrame D`
(`Semantics/Frames/Standard.lean`) is `W = ↑D` with `w ⇒_x u ↔ u = w + x`; its reference history
`translationHist D` is the identity `t ↦ t`, and `translationModel D A` values every atom by
membership in an arbitrary `A ⊆ ↑D`. `translation_realizes` /
`translation_realizes_allFuture` (`Correspondence/DurationFrames.lean:141,153`) are the ready-made
bridges. `translationFrame_isRegular` is a global instance, so the `Sat .Base` side condition is
`inferInstance` — verified.

This is the same realisation layer the `app:discrete` and `app:complete` (T1) correspondences run
on (`validOn_df_iff_isDiscrete`, `validOn_co_iff_isComplete`), so the new results sit inside an
established idiom rather than introducing one.

**3. Ruled out: the clock frame and the static frame.**

- `clockFrame` (`Independence/ClockFrame.lean`, `W = ℚ⧸ℤ`) has period-1 truth, and a periodic
  truth set cannot be bounded above and nonempty, which both refutations require. Unusable.
- `FrameOver.staticFrame` has time-invariant truth, which makes `Gφ ↔ φ` trivially and **validates**
  `z1`; `LexIntWitness.lean` relies on exactly that (the static frame over `ℤ ×ₗ ℤ` is in
  `Mod (AxiomSet .Discrete)`). Unusable — and a live trap, since that module's presence makes the
  non-Archimedean carrier look like the obvious starting point.

**4. `Z1Countermodel.lean` is not needed, and the dispatch's caution about it is well-founded.**

`Conservativity.lean:113-145` records that `z1 φ` is *not* `tr (Z1 φ')` and cannot be
(`Formula.someFuture` is a top-level `untl`; `MinusLanguage.tr_ne_untl`), and
`not_minus_derivable_z1` is about **L⁻ derivability**, not `ValidIn` of the native formula. The
recommended route never enters that territory: the native formula is refuted natively. The
`ℚ ×ₗ ℤ` carrier and `minus_soundness_ztime_succ` play no part.

**5. `DenseObstructionTransfer.lean` is the structural template, in the neighbouring language.**

That module already refutes the **L⁻** schema `Z1` over `ℚ` (`q_gp_iff_p`, `q_F_Gp`, `q_not_Gp`,
`not_minusValidDense_z1`) with valuation `{x | 1 ≤ x}` on `multiFamTaskFrameGen`. The verified
`z1` proof below is that argument transposed into `Formula`/`TruthAt` on the translation frame,
generalized from `ℚ` to an arbitrary dense `D`. Two consequences worth recording: the mathematics
was never in doubt, and the new module should cite this one as its antecedent so the two read as
one story.

**6. The `CoNotPriorU` obstruction is specific to joint statements.**

`CoNotPriorU.lean:13-45`: "On a densely ordered flow rich enough to realize an arbitrary set of
times, frame-validity of `CO` already forces gap-freeness, and hence forces Prior-U valid too — so
no frame-level countermodel can exist." The binding constraint is *validating* `CO`. A plain
`¬ ValidIn .Base φ` validates nothing. Confirmed empirically: the frame-level form
`¬ (translationFrame D).toTaskFrame.ValidOn φ` elaborates for both axioms.

**7. `.Base` is the unique class strictly below `.ZTime`.**

`Axioms.lean:547-554`: `Base ≤ _` always; `Dense ≤ {Dense, RTime}`; `ZTime ≤ ZTime`;
`RTime ≤ RTime`. Hence `fc < .ZTime → fc = .Base`. Note `DecidableRel` is registered for `≤`
only, so `by decide` fails on a `<` goal; `eq_base_of_lt_ztime` is proved by a four-way case
split using `h.le` and `h.ne` (verified).

### External Resources

- Mathlib: `exists_between` (density), `exists_gt` (from `noMaxOrder_of_duration D`,
  `Correspondence/DurationFrames.lean:86`), `not_le`, `push Not`. Nothing new is needed from
  Mathlib, and no Mathlib search tool was required — every lemma was resolved locally.
- `docs/reference/paper-definitions-of-record.md` governs paper anchors (gate C15); the new
  module's docstring should cite `def:BX-z` (the narrowing `.ZTime` denotes) rather than inventing
  an anchor.
- The ModelChecker adequacy report at
  `~/Projects/ModelChecker/specs/187_establish_adequacy_theorem_bimodal_countermodels/reports/01_adequacy-theorem-bimodal-countermodels.md`
  exists and is readable; §8.2's A0 argument is the consumer of this result. No change to that
  repository belongs to this task; the new module's docstring can record the connection in prose.

### Recommendations

**R1 — One new module: `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`.**

`Independence/` is defined as "underivability results, established by exhibiting a model of the
assumptions in which the target formula fails" — and the recommended content additionally yields
two genuine underivability corollaries via `soundness_validIn`
(`Metalogic/Soundness.lean:1379`), so the fit is exact rather than approximate. Namespace
`FormalSystem.Metalogic.Independence`, matching `LexIntWitness.lean` and `RationalWitness.lean`.
Imports: `FormalSystem.Semantics.Correspondence.DurationFrames` and
`FormalSystem.Metalogic.Soundness` (both already in the `Independence/` neighbourhood's reach; no
cycle — `Semantics/` never imports `Metalogic/`).

Alternative considered and not recommended: a `Metalogic/SoundnessSharpness.lean` beside
`Soundness.lean`. It pairs the sharpness with `axiom_validIn_min` more legibly but abandons the
`Independence/` README's existing numbered-results ledger, which is where a reader looks for
refutations.

**R2 — Declaration inventory (all 10 verified; see Appendix for source).**

| Declaration | Statement | Role |
|---|---|---|
| `example` ×2 | `Axiom (…) := Axiom.prior_UZ φ` / `Axiom.z1 φ` | **Shape pins.** Type-check only if the transcribed formula is *exactly* the axiom's; the cheapest possible guard against transcription drift. Strongly recommended. |
| `eq_base_of_lt_ztime` | `fc < .ZTime → fc = .Base` | The order fact minimality rests on |
| `not_validOn_prior_UZ_dense` | `¬ (translationFrame D).toTaskFrame.ValidOn (Fp → U(¬p, p))`, any dense `D` | Frame-level refutation, generic |
| `not_validOn_z1_dense` | `¬ (translationFrame D).toTaskFrame.ValidOn (G(Gp→p) → (FGp → Gp))`, any dense `D` | Frame-level refutation, generic |
| `not_validIn_base_prior_UZ` | `¬ ValidIn .Base (Fp → U(¬p, p))` | **The mandated deliverable** |
| `not_validIn_base_z1` | `¬ ValidIn .Base (G(Gp→p) → (FGp → Gp))` | **The mandated deliverable** |
| `prior_UZ_minFrameClass_sharp` | `fc < .ZTime → ¬ ValidIn fc (…)` | Minimality, in full |
| `z1_minFrameClass_sharp` | `fc < .ZTime → ¬ ValidIn fc (…)` | Minimality, in full |
| `not_derivable_base_prior_UZ` | `¬ Derivable .Base [] (…)` | Free corollary via `soundness_validIn` |
| `not_derivable_base_z1` | `¬ Derivable .Base [] (…)` | Free corollary via `soundness_validIn` |

**R3 — The two countermodels, stated once.**

Both live on `translationFrame D` along `translationHist D`, at time `0`, with
`translationModel D A`:

- `prior_UZ` (`Fp → U(¬p, p)`): `A = {x | 0 < x}`. `Fp` holds at `0` (witness any `c > 0`, from
  `noMaxOrder_of_duration`). `U(¬p, p)` fails: any witness `s > 0` admits `r` with `0 < r < s` by
  `exists_between`, and `p` holds at `r`, so the guard `¬p` fails. *There is no first future
  `p`-point.*
- `z1` (`G(Gp→p) → (FGp → Gp)`): `A = {x | c ≤ x}` for any `c > 0`. The collapse
  `Gp at t ↔ c ≤ t` holds (`←` monotonicity; `→` by `exists_between` on `t < c`). Then
  `G(Gp→p)` holds vacuously-by-collapse, `FGp` holds at witness `c`, and `Gp` fails at `0`
  since `¬(c ≤ 0)`. *`c` is the infimum of the `Gp`-region and it is attained, so backward
  induction has nowhere to run.*

Both are refutations of **discreteness**, not of the Archimedean property — which is why a
dense carrier suffices and why `ℚ ×ₗ ℤ` is unnecessary.

**R4 — Docstring update in `Axioms.lean`, as the dispatch requires.**

Amend `Axiom.minFrameClass`'s docstring (`Axioms.lean:~589-609`) so the `ZTime (2 axioms:
prior_UZ, z1)` line cites `Independence.prior_UZ_minFrameClass_sharp` and
`Independence.z1_minFrameClass_sharp` alongside the existing literature citations, and states
explicitly that the tag is now proved minimal (not merely upper-bounded) for this row. Naming the
two theorems here also discharges gate C17 (dead-declaration scan) for them. Mirror the wording in
the `prior_UZ` and `z1` constructor docstrings at `:335-341` and `:347-356`.

**Cost warning**: `Axioms.lean` is imported (transitively) by essentially the whole tree, and Lean
invalidates on whole-file hash, so *a docstring-only edit there forces a full rebuild*. Plan for
exactly one such rebuild: land the `Axioms.lean` docstring edits in the same phase as the new
module, never as a separate "documentation" phase afterwards.

**R5 — Build discipline.**

Every `lake build` must be detached via `Bash(run_in_background: true)` and routed through the
build guard, per `context/project/lean4/operations/long-builds.md`; wait on the log per
`context/patterns/bounded-build-waiter.md`. Do not call `lean_diagnostic_messages` or
`lean_file_outline` (blocked). `lean_run_code` was sufficient for all verification in this
report and remains the cheapest inner loop.

**R6 — Optional, cheap, and explicitly not required by the dispatch.**

Because `not_validOn_*_dense` is generic in `D`, three extra corollaries cost one line each:

- `¬ ValidIn .Dense (…)` for both axioms — the *same* `ℚ` frame; `Sat .Dense` is
  `⟨inferInstance, inferInstance⟩`. Verified working for `prior_UZ` during this research.
- `¬ ValidIn .RTime (…)` — needs `D = ℝ` and a `TaskFrame.IsComplete` discharge
  (`∀ s, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`, `Semantics/FrameProperty.lean:207`) via
  `Real.exists_isLUB`; roughly five extra lines. `realOrder` already exists
  (`Metalogic/DedekindNonCompactness.lean:322`).

Together these would upgrade the result from "minimal" to "`ValidIn fc φ` holds at `.ZTime`
alone", a strictly sharper statement. Recommend offering it as a clearly-marked optional final
phase, since it is outside the dispatch's stated deliverable.

## Decisions

- **D1**: Refute natively on `Formula`/`TruthAt`; do **not** route through `MinusLanguage`. Reason:
  the `tr_ne_untl` gap makes any transfer a separate proof obligation, and the native proof is
  shorter than the transfer would be.
- **D2**: Carrier is the *dense* `ℚ` via `TemporalOrder.of ℚ`, not the non-Archimedean discrete
  `ℚ ×ₗ ℤ`. Reason: `.Base` requires only `IsRegular`, and both axioms already fail on dense
  carriers. Per the dispatch's instruction, the claim is **not** silently upgraded — the verified
  statements say `.Base` (and, in the generic lemmas, "any densely ordered `D`"), and no claim
  about ℚ-specific or non-Archimedean behaviour is made.
- **D3**: Frame is `translationFrame`, not `clockFrame` (periodic), `staticFrame` (validates
  `z1`), or `multiFamTaskFrameGen` (works, but `translationFrame` comes with the
  `translation_realizes*` bridges already proved).
- **D4**: State the deliverable as `¬ ValidIn FrameClass.Base φ` at an atomic instance
  (`Formula.atom p`, `p` universally quantified), **plus** the `fc < .ZTime` form. Rejected: a
  schematic `∀ φ` form — it is *false*, since `prior_UZ ⊥` has an unsatisfiable antecedent and is
  `Base`-valid. The atomic restriction is not a weakening of convenience; it is forced.
- **D5**: Prove the frame-level `¬ F.ValidOn` form, not the model-fixed form
  `CoNotPriorU.lean` was forced into. Verified admissible.
- **D6**: Include the two `Axiom (…) := Axiom.prior_UZ φ` shape-pin `example`s. Reason: the
  deliverable's correctness rests entirely on the transcribed formula matching the axiom, and
  these make that a compiler obligation.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **Formula transcription drift** — the whole result is vacuous if the written formula is not the axiom's | The two shape-pin `example`s (D6). Non-negotiable. |
| **`Axioms.lean` docstring edit triggers a full-tree rebuild** | Batch it with the new module in one phase (R4); detached guarded build (R5). Budget one full rebuild, not several. |
| **Gate C17 (dead-declaration scan)** — every new base identifier needs an occurrence outside its declaring line | Satisfied by the `Axioms.lean` docstring citations plus the `Independence/README.md` updates. Verify with `scripts/check-module-invariants.sh` before claiming completion. |
| **`Independence/README.md` says "Eight results are carried here"** with a numbered list and a `<!-- BEGIN GENERATED: inventory -->` table | Bump to nine, add the numbered entry and a Key Results bullet, and regenerate via `bash scripts/readme-inventory.sh`. Do not hand-edit inside the generated block. |
| **`FormalSystem.lean` is generated** by `lake exe mk_all --lib FormalSystem` | Regenerate it; also add the import line to `FormalSystem/Metalogic/Independence.lean` (which lists its children explicitly). Gate C4 checks resolution, C24 checks the `FormalSystem.Init` path. |
| **Gate C14/C21/C27 coupling if the theorems are added to `MainResults.lean`** | Adding `#print axioms` lines there requires (a) bumping `FormalSystem/MainResults.lean 54` in `scripts/debug-artifact-allowlist.txt`, and (b) adding matching lines to `C14_BASELINE` inside `scripts/check-module-invariants.sh` (~line 1772), since C21 requires every `MainResults.lean` name be pinned by C2 or C14. **Recommendation: do it** — the measured set is already `[propext, Classical.choice, Quot.sound]` — but treat it as a deliberate sub-step with its own gate run, not an afterthought. Skipping it is also defensible and cheaper. |
| **Gate C15 (paper anchors)** — an invented anchor fails | Cite `def:BX-z` only, per `docs/reference/paper-definitions-of-record.md`. |
| Other gates: copyright header, C8 aggregator convention, C26 (no non-trailing underscore in `def`/`abbrev` names — `ztimeSharpOrder` is clean), C23 naming | All satisfied by the Appendix source as written; confirm with one full `scripts/check-module-invariants.sh` run. |
| **Name collision**: `DenseObstructionTransfer.lean` already declares `qD` in `FormalSystem.Metalogic` | The Appendix uses `ztimeSharpOrder` in `FormalSystem.Metalogic.Independence` instead. Do not reintroduce `qD`. |
| `push_neg` is deprecated in this toolchain | The Appendix uses `push Not`, matching the repo's existing usage. |

**Zero-debt compliance**: a sorry-free path is not merely believed available, it is *verified
compiled*. No `sorry`, no new `axiom`, no deferral pattern is recommended anywhere in this report.

## Tactic Survey Results

Candidate tactics were exercised directly through `lean_run_code` on the real goals rather than
probed at a cursor position, since the proofs were written and checked end to end.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `fc < .ZTime → fc = .Base` | `decide` | **fail** | `DecidableRel` exists for `≤` only, not `<`; error is `failed to synthesize Decidable (…< …)` |
| `fc < .ZTime → fc = .Base` | `cases` + `decide` on `h.le` / `h.ne` | success | four-way split; `by decide` on the `≤` subgoals |
| `¬(Dense ≤ ZTime)`, `¬(RTime ≤ ZTime)` | `decide` | success | closed `≤` goals; `DecidableRel` instance |
| `Gp at t ↔ c ≤ t` (dense collapse) | `rw [translation_realizes_allFuture]` + `exists_between` | success | `push Not`, `not_le`, `exists_between` |
| `U(¬p, p)` refutation | `exists_between` on the witness interval | success | `translation_realizes`, `Truth.neg_iff` |
| Antecedent `Fp` at `0` | `rw [Truth.some_future_iff]` + `exists_gt` | success | `noMaxOrder_of_duration D` |
| `Sat .Base (translationFrame D).toTaskFrame` | `inferInstance` | success | `translationFrame_isRegular` global instance |
| `Sat .Dense` (ℚ) | `⟨inferInstance, inferInstance⟩` | success | reducible chain to `DenselyOrdered ℚ` |
| Whole-proof automation (`aesop`, `simp`, `omega`, `hammer`) | not attempted | — | The goals are multi-step model constructions with explicit witnesses; the `truth_norm` characterization family (`Truth.imp_iff`, `Truth.future_iff`, `Truth.some_future_iff`, `Truth.neg_iff`) is the repository's intended normal form and was sufficient. No premise search was needed. |

APOLLO-style decomposition was unnecessary: no sub-goal resisted a direct proof.

## Context Extension Recommendations

- **Topic**: The atom-realisation idiom for building L-countermodels
  (`translationFrame` + `translationHist` + `translationModel` + `translation_realizes*`).
  **Gap**: `.claude/context/project/lean4/` has no note on it, and the repository's own index
  (`Semantics/Frames/README.md`) frames these as *correspondence* witnesses rather than as the
  general-purpose countermodel kit they are — which is why the discrete non-Archimedean carrier
  looks like the natural starting point for a `.ZTime` refutation when it is not.
  **Recommendation**: add
  `.claude/context/project/lean4/patterns/countermodel-construction-kit.md` recording: atoms are
  valued on states so a countermodel needs a state-varying history; `translationFrame` is the
  frame that supplies one for an arbitrary `A ⊆ ↑D`; and the two frames that silently *validate*
  the target (`clockFrame`, periodic; `staticFrame`, time-invariant).
- **Topic**: The distinction between a *bare non-validity* claim and a *joint*
  validate-one/refute-another claim.
  **Gap**: `CoNotPriorU.lean`'s frame-versus-model caveat reads as a general obstruction to
  frame-level refutation, and the dispatch reasonably flagged it as possibly binding here. It is
  not.
  **Recommendation**: one paragraph in the same context file, or in
  `.claude/context/project/logic/domain/`, stating the rule: frame-level refutation is obstructed
  only when the statement must simultaneously validate something on a valuation-rich flow.

## Observations for a Follow-Up Task (dispatch SCOPE clause)

Recorded rather than acted on, as instructed. The `.Dense` and `.RTime` tags are indeed
unproved-sharp on the same grounds, and all four look **cheaper** than the `.ZTime` row just
closed:

- `density` (`GGφ → Gφ`, `.Dense`): `validOn_df_iff_isDiscrete`'s sibling
  `validOn_dn_iff_denselyOrdered` (`Correspondence/DurationFrames.lean:236`) is an *iff*; at
  `D = intOrder` (not densely ordered) its `→` direction yields the `.Base` refutation nearly
  free.
- `dense_indicator` (`¬U(⊤,⊥)`, `.Dense`): `Correspondence/Indicator.lean` proves
  `F ⊨ ¬X⊤ ↔ DenselyOrdered F.Duration` — same one-step route.
- `prior_U_gap` and `sep` (`.RTime`): minimality here needs refutations at **both** `.Base` and
  `.Dense` (both are `< .RTime`). For `prior_U_gap`,
  `Independence/CoNotPriorU.lean:288`'s `priorUGapFormula_false` already refutes the formula in a
  model over the clock frame at `ℚ` — which is dense — so a single `¬ ValidOn` extraction should
  discharge both classes at once. `sep` appears to have no existing witness.

A follow-up task covering all four would plausibly complete the sharpness ledger for
`Axiom.minFrameClass` end to end.

## Appendix

### A. Verified source (elaborated with zero errors, zero `sorry`, zero new axioms)

This is the exact text run through `lean_run_code` against the built tree. Docstrings, the module
header and the copyright block are omitted and must be added (gates: copyright checker, C19).

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

/-- Shape pin: the formula below is exactly `Axiom.prior_UZ`'s. -/
example (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ)) := Axiom.prior_UZ φ

/-- Shape pin: the formula below is exactly `Axiom.z1`'s. -/
example (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  Axiom.z1 φ

theorem eq_base_of_lt_ztime {fc : FrameClass} (h : fc < FrameClass.ZTime) :
    fc = FrameClass.Base := by
  cases fc with
  | Base => rfl
  | Dense => exact absurd h.le (by decide)
  | ZTime => exact absurd rfl h.ne
  | RTime => exact absurd h.le (by decide)

theorem not_validOn_prior_UZ_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := by
  intro h
  haveI := noMaxOrder_of_duration D
  obtain ⟨c, hc⟩ := exists_gt (0 : (D : Type))
  set A : Set (D : Type) := {x | 0 < x} with hA
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨c, hc, (translation_realizes D A p c).mpr hc⟩
  obtain ⟨s, h0s, _hps, hguard⟩ := hval hant
  obtain ⟨r, h0r, hrs⟩ := exists_between h0s
  have hne := hguard r h0r hrs
  rw [Truth.neg_iff] at hne
  exact hne ((translation_realizes D A p r).mpr h0r)

theorem not_validOn_z1_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := by
  intro h
  haveI := noMaxOrder_of_duration D
  obtain ⟨c, hc⟩ := exists_gt (0 : (D : Type))
  set A : Set (D : Type) := {x | c ≤ x} with hA
  have hG : ∀ t : (D : Type),
      TruthAt (translationModel D A) (translationHist D) t (Formula.atom p).allFuture
        ↔ c ≤ t := by
    intro t
    rw [translation_realizes_allFuture]
    refine ⟨fun hh => ?_, fun hh s hs => hh.trans hs.le⟩
    by_contra hcon
    push Not at hcon
    obtain ⟨s, hts, hsc⟩ := exists_between hcon
    exact absurd (hh s hts) (not_le.mpr hsc)
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      ((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture := by
    rw [Truth.future_iff]
    intro s _
    rw [Truth.imp_iff, hG]
    exact fun hs => (translation_realizes D A p s).mpr hs
  have hcons := hval hant
  rw [Truth.imp_iff] at hcons
  have hFGp : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture.someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨c, hc, (hG c).mpr (le_refl c)⟩
  exact absurd ((hG 0).mp (hcons hFGp)) (not_le.mpr hc)

noncomputable abbrev ztimeSharpOrder : TemporalOrder := TemporalOrder.of ℚ

theorem not_validIn_base_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense ztimeSharpOrder p (h _ inferInstance)

theorem not_validIn_base_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Base
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense ztimeSharpOrder p (h _ inferInstance)

theorem prior_UZ_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  eq_base_of_lt_ztime hfc ▸ not_validIn_base_prior_UZ p

theorem z1_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  eq_base_of_lt_ztime hfc ▸ not_validIn_base_z1 p

theorem not_derivable_base_prior_UZ (p : Atom) :
    ¬ Derivable FrameClass.Base []
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun ⟨d⟩ => not_validIn_base_prior_UZ p (soundness_validIn d)

theorem not_derivable_base_z1 (p : Atom) :
    ¬ Derivable FrameClass.Base []
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun ⟨d⟩ => not_validIn_base_z1 p (soundness_validIn d)

end FormalSystem.Metalogic.Independence
```

### B. Measured axiom footprint

```
'FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.z1_minFrameClass_sharp' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.not_derivable_base_prior_UZ' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.not_derivable_base_z1' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

Identical to the set `MainResults.lean` pins; no regression in the build-time audit.

### C. Searches and probes performed

- Repository greps: `prior_UZ|priorUZ` (all live `.lean`), `ValidOn|ValidIn|ValidOnFrames`,
  `IsComplete|IsRTime|IsDense`, `TemporalOrder` instances, `def Derivable`, `soundness*`,
  `Sat .RTime`, frame-class `LE`/`PartialOrder` instances.
- Files read in full or in relevant part: `ProofSystem/Axioms.lean` (:320-370, :540-620),
  `Semantics/Validity.lean` (:60-140, :220-400), `Semantics/FrameClassValidity.lean` (:1-200),
  `Semantics/Truth.lean` (:230-250, :318-470), `Semantics/Frames/Standard.lean` (whole),
  `Semantics/Correspondence/DurationFrames.lean` (:100-350),
  `Semantics/Correspondence/README.md`, `Semantics/Frames/README.md`,
  `Metalogic/Soundness.lean` (:1200-1300, :1380-1420),
  `Metalogic/Conservativity.lean` (:110-150),
  `Metalogic/Conservativity/DenseObstructionTransfer.lean` (whole),
  `Metalogic/Independence/README.md`, `Metalogic/Independence/CoNotPriorU.lean` (:10-50),
  `Metalogic/Independence.lean`, `Semantics/FrameProperty.lean` (:190-240),
  `scripts/check-module-invariants.sh` (checks list, C2/C14 baselines),
  `scripts/debug-artifact-allowlist.txt`, `scripts/module-invariants-manifest.txt`,
  `.claude/context/project/lean4/operations/long-builds.md`.
- Lean probes: four `lean_run_code` runs — the `prior_UZ` refutation at `ℚ`; the `z1` refutation at
  `ℚ`; the generic-over-dense-`D` pair with `.Base`/`.Dense` corollaries and `#print axioms`; the
  `fc < .ZTime` order lemma and the `minFrameClass = .ZTime` `rfl` pins; then the assembled
  module with all ten declarations. No rate-limited search tool was needed, and no MCP tool
  failed. Blocked tools (`lean_diagnostic_messages`, `lean_file_outline`) were not called.
