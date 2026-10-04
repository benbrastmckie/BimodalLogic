# Implementation Plan: Task #706

- **Task**: 706 - L⁺ finite model property and completeness — the library landing of the finite-carrier refutations
- **Status**: [IMPLEMENTING]
- **Effort**: 8.25 hours
- **Dependencies**: 695, 696, 703 (all completed and archived; the dependency gate is clear)
- **Research Inputs**: `specs/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md`
- **Artifacts**: plans/01_land-finite-carrier-refutation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round is finished and it succeeded: the finite-carrier finite model property is
machine-checked **false** for L⁺ over regular ℤ-frames, and false already on the `⊡`-free
fragment (so already about the base language TM) and on the CTL-like fragment. The whole
refutation family is sorry-free in
`specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
(349 lines, compiled outside the build graph). This plan lands that family as `FormalSystem/`
theorems, pins their axiom sets, uncomments the four inventory rows that have been reserved for
them, gives each landed theorem a ledger row, and replaces the unanchored prose claim in the
sliced subtree's root header with the landed names.

Nothing here is a new proof. Every argument is already compiled; what the phases do is
transcription under the repository's gate discipline (namespace, imports, docstrings, zero
warnings, no task-number citations, no `#print axioms` in library code), plus the five
bookkeeping surfaces a landing of this shape has to move.

### Research Integration

The report's Recommendation 2 is the direct input, and the user's 2026-10-03 ruling (Option A,
library landing) settles the scope question the report left open. Six findings shape the plan
rather than being re-litigated:

1. **The refutation, both halves.** `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` holds on the ℤ-carrier
   shift set, so `θ.neg` is a genuine ℤ-time non-validity; and no regular ℤ-frame with a
   `Finite` world-state carrier satisfies `θ` at any history and time (pigeonhole left of a
   `p`-time, then the repeat-cycle pumped bi-infinitely into a step path, hence a history by
   `mem_HF_iff_adjacent`, which never meets `p`).
2. **`θ` is `⊡`-free**, witnessed by `θ_eq_ofFormula : θ = ofFormula ψL`. That is what makes this
   half a result about TM itself rather than an L⁺-specific one, and it is the statement's scope,
   not a decoration on it.
3. **The fragment does not rescue the shape** (`not_finite_carrier_fmp_fragment`), so the
   `⊡`-bearing twins must land beside the main witness.
4. **Scope limits**: ℤ (discrete) frames only; nothing claimed about an infinite carrier; nothing
   touched in soundness, in either direction.
5. **Superseded, recorded so it is not re-read as live**: the report's risk R3 has materialized —
   the sliced class is incomplete too, at finite *width*, landed by task 710. Any prose this
   landing writes about the sliced class's completeness follows 710's landed text, not R3's.
6. **No bound is committed.** The report's Q4 finding (nothing proved for L⁺ beyond
   `plusCompressionBound`; doubly exponential is the honest expectation) means no width or
   carrier bound appears anywhere in this landing.

### Prior Plan Reference

No prior plan exists for this task. The calibration source used instead is task 710's landed
plan and summary (`specs/710_sliced_class_incompleteness_characterization/plans/01_land-finite-width-refutation.md`),
which landed the *sibling* refutation in the same subtree nine days of work earlier and is the
closest precedent available: same subtree, same probe-to-library transcription shape, same gate
set. Three things were taken from it:

- **Effort calibration.** 710 transcribed ~1180 probe lines in six content phases at 1-1.5 h
  each. This probe is 349 lines, so four content phases at ~1-1.25 h is the proportionate
  estimate rather than a guess.
- **The gate inventory.** 710's "gate constraints that shape the phases" table was re-derived
  against the current scripts rather than copied; where this task's `file_scope` differs (it
  declares `scripts/check-module-invariants.sh`, which 710 did not) the obligation changes, and
  that difference is this plan's Phase 7.
- **Two risks that materialized for 710 and will materialize here**: blocking linter warnings on
  section variables, and task-number citations in probe prose landing under `FormalSystem/`.

No phase is copied. 710's phase boundaries follow its own proof structure, which is a König
argument this probe does not contain.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only. Three entries bear on this plan:

- **Phase 0** carries the settled ruling as a checked item: "RULED 2026-10-03 by the user: Option
  A — library landing", naming `Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp`
  as the two theorems to land. This plan advances the first.
- **Phase 2**'s narrative already records that 710 landed the width half into
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` and that
  "task 706 lands the carrier half" — which is a direct input to decision D-1 below.
- **Phase 2**'s unchecked item for this task names exactly `no_finite_carrier_sat`
  (`[Finite F.WorldState]`), `no_ofStep_sat`, `not_finite_carrier_fmp` and `θ_eq_ofFormula`, and
  states the reason for the last one in the same terms Deliverable 2 does.
- The Success Metric "every refutation the programme has produced lives in `FormalSystem/` as a
  cited theorem, not only under a task's `probes/`" is what this landing discharges for the
  carrier half. ROADMAP.md is **not** edited by this plan (no `roadmap_flag` on this dispatch).

## Goals & Non-Goals

**Goals**:

- Land the whole `no_finite_carrier_sat` family — `θ_eq_ofFormula`, `not_plusValidZTime_neg_θ`,
  `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp` — plus the `⊡`-bearing
  fragment twins `not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'` and
  `not_finite_carrier_fmp_fragment`, at the home decision D-1 chooses, with the statements
  character-for-character as the verbatim block below records them.
- Carry Deliverable 2 (the `⊡`-free status, in TM terms, with both halves of the contrast with
  the finite-width landing) and Deliverable 3 (ℤ-discrete scope; nothing about an infinite
  carrier; nothing about soundness) into the landed docstrings, so no landed theorem is readable
  as claiming more than the probe proves.
- Pin the landed declarations' axiom sets in `scripts/check-module-invariants.sh`, uncomment the
  four reserved `scripts/certificate-witness-inventory.txt` rows with their recorded path
  corrected, and add rows for the fragment twins.
- Give each landed theorem a `docs/theorem-index.md` row in the file's six-column format, with a
  `pinned:` token only where the baseline line is added in the same change.
- Replace the two unanchored prose claims in `PlusSlicedCertificate.lean`'s "The carrier is
  infinite, with finite fibres, and that is forced" section with citations of
  `not_finite_carrier_fmp` and `not_finite_carrier_fmp_fragment` by name.
- Leave the tree green on the full gate set, sorry-free, warning-free, with no new axioms.

**Non-Goals**:

- **The original headline.** The finite model property for L⁺ over integer time with a computable
  state bound, and full completeness of a finite-graph certificate class derived from it, is
  refuted in its finite-carrier form by `not_finite_carrier_fmp`. It is not re-planned.
- **Any bound.** No carrier bound, no width bound, no order for the tail periods. Report
  Recommendation 6 stands.
- **Soundness.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their statements; this
  landing touches soundness in neither direction and uses it in no direction.
- **Moving, converting or deleting the probe file**, and re-pointing the `FMP/README.md` and
  `scripts/check-evidence-probes.sh` citations from `Probe706.*` to the landed names. That is
  task 720's scope and 720 runs after this task. The probe file is not edited here, and
  `check-evidence-probes.sh` must keep exiting 0 with its `WIRED_REPO` entry unchanged.
- **Weakening or restating `PlusSlicedCertificate.lean`'s "What is refuted, and what is open"
  verdicts about the sliced class.** Those are 710's landed deliverable. This plan edits only the
  "carrier is infinite" section's two paragraphs and leaves that later section byte-identical.
- **The three existing `pinned:C14` index rows whose claim is ungrounded.** That repair is the
  separately specified follow-up H2 of
  `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` Section H2. This
  plan neither fixes nor extends them, and adds no fourth ungrounded token.
- **The fragment's own finite model property** (report Recommendation 4) and the full-L⁺ FMP,
  which remains open-with-an-infeasible-known-route rather than refuted. Recorded, not pursued.
- **Editing `Limits/NoFiniteWidth.lean`.** It is outside this task's `file_scope` and is task
  710's landed territory. Decision D-2's reuse-by-import is chosen partly because it needs no
  edit there.

## Decisions this plan makes

### D-1: the home is `PlusSlicedCertificate/Limits/FiniteCarrier.lean`

The dispatch leaves the home to the plan and records two defensible candidates. The chosen home
is

```
FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean
```

with the declarations in the nested namespace `PlusSlicedCertificate.FiniteCarrier`, inside
`namespace FormalSystem.Metalogic.Decidability`.

Verified facts behind the choice:

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FiniteCarrier.lean` does **not**
  exist (confirmed: the directory holds 25 `.lean` files plus `README.md`).
- `PlusSlicedCertificate/Limits/` **does** now exist and holds `NoFiniteWidth.lean` (56 KB) and
  `README.md`, landed 2026-10-03. The dispatch anticipated this ("by the time this task runs that
  directory will exist"); it has happened.
- `NoFiniteWidth.lean`'s declarations live in `PlusSlicedCertificate.NoFiniteWidth`, **not** in a
  `Limits` namespace: the directory name is a path component only. So `FiniteCarrier.lean` under
  `Limits/` keeps the namespace `PlusSlicedCertificate.FiniteCarrier` that the four reserved
  inventory rows already pre-commit to, and the four fully qualified names
  (`PlusSlicedCertificate.FiniteCarrier.{no_finite_carrier_sat, no_ofStep_sat,
  not_finite_carrier_fmp, not_plusValidZTime_neg_θ}`) land **byte-identical** to the reserved
  rows' second field.
- C36a checks a `coverage-limit` row's *recorded anchor path* against the file the declaration is
  actually found in, and fails on a mismatch. So the four reserved rows' **fourth** field must be
  edited from `.../PlusSlicedCertificate/FiniteCarrier.lean` to
  `.../PlusSlicedCertificate/Limits/FiniteCarrier.lean`. That edit is four one-field changes, and
  the dispatch explicitly sanctions it ("if it departs from the inventory's reserved path, EDIT
  THOSE FOUR ROWS rather than leave them naming a path nothing lands at").
- `specs/ROADMAP.md` Phase 2 narrates the two halves as one story and names 710's `Limits/` path
  in the sentence that says "task 706 lands the carrier half".

Why not the report's alternative ("beside `PlusWitnessFamily/Incompleteness.lean`"): that subtree
is the *retired* sharing-witness class's territory, and the finite-carrier refutation is the
reason the **sliced** class's carrier is `ℤ × Fin n` — which is exactly what
`PlusSlicedCertificate.lean`'s header argues in the paragraph Deliverable 6 repairs. Putting the
two obstruction axes (carrier, width) in one directory with one `README.md` is the layout that
makes the asymmetry readable; `PlusWitnessFamily/Limits/` is the precedent for the shape, not the
destination.

One honest cost, stated rather than hidden: `Limits/README.md` opens "The **limits** of the
`PlusSlicedCertificate` class", and the finite-carrier refutation is a limit of a *different*,
rejected class shape. Phase 5 widens that README's framing sentence to cover both axes rather
than leaving the directory's stated purpose narrower than its contents.

### D-2: `θ'` is **reused** from the finite-width landing, not re-defined

The dispatch requires that "the two landings must agree on its definition rather than each
defining a private copy". Verified: `NoFiniteWidth.lean` defines `pa`, `p`, `Fp`, `Pp`, `A'`,
`C'` and `Φ := (A'.and C').and D`, and defines no `θ'`. So the no-copy reading is implementable:

- `FiniteCarrier.lean` imports `...PlusSlicedCertificate.Limits.NoFiniteWidth` and takes `pa`,
  `p`, `Fp`, `Pp`, `A'`, `C'` **from it**, defining only `A`, `C`, `θ`, `ψL`, `θ'` and the shift
  set `S` locally.
- `def θ' : PlusFormula := NoFiniteWidth.A'.and NoFiniteWidth.C'`, with
  `theorem noFiniteWidth_Φ_eq : NoFiniteWidth.Φ = θ'.and NoFiniteWidth.D := rfl` landing the
  extension relation mechanically, so a future edit to either side that breaks the agreement
  breaks the build.

This also removes a correctness hazard that a private copy would introduce: `θ'_of_θ` and
`no_finite_carrier_sat'` both read the valuation at the *same* atom that `A'`/`C'` are built
from, so two syntactically distinct `pa` definitions would force `show`/`change` plumbing for no
gain. Sharing one `pa` makes those proofs transcribe unchanged.

The import direction is sound and creates no cycle: `NoFiniteWidth` imports
`PlusSlicedCertificate.Sound` and nothing under `FiniteCarrier`; both are imported *by*
`PlusSlicedCertificate.lean`. A docstring sentence records why the import exists — to share
`A'`/`C'` with the width landing — and that `θ` itself uses nothing from it, so the `⊡`-free half
is not quietly coupled to L⁺-specific machinery.

**Fallback** (take it only if the build asks): define `pa`/`p`/`Fp`/`Pp`/`A'`/`C'` locally and
keep the agreement mechanical with `theorem noFiniteWidth_Φ_eq : NoFiniteWidth.Φ = θ'.and
NoFiniteWidth.D := by decide`. That is a copy plus a proof that it is not a drifting copy — worse
than reuse, acceptable if reuse stalls, and it must be recorded as a deviation if taken.

### D-3: one supporting lemma must be renamed, because C23 forbids its probe name

`Probe706.S_hist_unique` cannot land under that name. C23's second assertion fails any
`Uppercase_x` name (regex `^[A-Z][A-Za-z0-9']*_`) that is neither in the tense-operator prefix
set `(F|P|G|H|A|FF|HF)_` nor in the recorded `UPPER_ALLOW`, **unless** the suffix after the first
underscore is itself a live base identifier. Verified mechanically: `S_` is not a tense prefix,
and no live declaration named `hist_unique` exists under `FormalSystem/`. The landed name is
therefore `shift_hist_unique`; `stab_iff_S` and `θ'_of_θ` are unaffected (neither starts with an
ASCII uppercase letter).

Also verified mechanically, so that the single-letter definitions are not a hazard: none of
`pa`, `p`, `Fp`, `Pp`, `A`, `C`, `S`, `mk`, `steps`, `θ`, `ψL`, `A'`, `C'`, `θ'` is declared in
any **ancestor** namespace of `PlusSlicedCertificate.FiniteCarrier` (`FormalSystem`,
`FormalSystem.Metalogic`, `...Decidability`, `...Decidability.PlusSlicedCertificate`), so C23's
third assertion (outer-shadows-inner) is clean. `NoFiniteWidth` is a sibling, not an ancestor, so
its `p`/`A'`/`C'` create no pair either. Even so, `mk` is renamed to `histOfStepPath` because
`PlusSlicedCertificate` is a structure and `PlusSlicedCertificate.mk` is its auto-generated
constructor: a reader-facing collision, not a gate one.

## The landed statements, verbatim

This block is the authority for Phases 1-4. A landed signature that differs from it is a
different, weaker theorem, and the difference must be reported rather than absorbed.

```lean
theorem θ_eq_ofFormula : θ = ofFormula ψL

theorem not_plusValidZTime_neg_θ : ¬ PlusValidZTime θ.neg

variable {F : FrameOver intOrder} [F.IsRegular]

theorem no_finite_carrier_sat [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ

theorem no_ofStep_sat {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop)
    (fwd : ∀ w, ∃ u, R w u) (bwd : ∀ w, ∃ v, R v w)
    (M : TaskModel (FrameOver.ofStep R fwd bwd).toTaskFrame)
    (τ : WorldHistory (FrameOver.ofStep R fwd bwd).toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ

theorem not_finite_carrier_fmp :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ

theorem not_plusValidZTime_neg_θ' : ¬ PlusValidZTime θ'.neg

theorem no_finite_carrier_sat' [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ'

theorem not_finite_carrier_fmp_fragment :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ
```

Three features of these signatures are load-bearing and must not drift:

1. `[Finite F.WorldState]` is the **whole** finiteness hypothesis on `no_finite_carrier_sat`, and
   there is no hypothesis on the succession relation beyond the regularity carried by
   `[F.IsRegular]`. A stray hypothesis makes the landed theorem weaker than the refutation it
   records.
2. In `not_finite_carrier_fmp` and its fragment twin, finiteness and regularity appear as the
   **explicit anonymous binders** `(_ : F.IsRegular) (_ : Finite F.WorldState)` inside the `∃`,
   not as instance arguments.
3. `no_ofStep_sat`'s relation is the **time-independent** `R : W → W → Prop`, because
   `FrameOver.ofStep` (`FormalSystem/Semantics/IntNormalForm.lean:323`, with
   `FrameOver.ofStep_isRegular` beside it) is not `FrameOver.ofSlicedStep`, whose relation is
   `ℤ → W → W → Prop`. Confusing the two silently restates task 710's theorem.

## The gate constraints that shape the phases

Re-derived against the current scripts, not inherited. Each row is a concrete landing obligation.

| Gate | Obligation on this landing |
|---|---|
| C1 | `lake build` exits 0, whole library. |
| C2 | The baseline is compared as one **exact string**, and the pass message hard-codes the spelled-out row count ("all thirty-four pinned axiom sets match baseline"). Adding rows means: one `#print axioms` line per row in the scratch heredoc, one baseline line in the same order, and the count message updated. A declaration that reports `does not depend on any axioms` is **dropped** by the `grep 'depends on axioms'` filter, so adding its `#print axioms` line without a baseline line would still pass, but adding a baseline line for it would fail — measure before writing (Phase 7). |
| C3 | Zero structural `sorry`, asserted by content. The probe is sorry-free; the transcription must stay so. |
| C9 | **Zero task-number citations under `FormalSystem/`**, pattern `\b(tasks?\s+#?[0-9]+\|task-[0-9]+)\b\|specs/[0-9]{3}_[A-Za-z0-9_]+` over `*.lean`/`*.md`/`*.sh`/`*.toml`. The probe's prose says "task 703's plan v2", "task 703 plan v2, Phase 13" and "Phase 17's hypotheses"; every one must be re-anchored on a durable anchor before it lands. **Verified**: `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean` does **not** match the pattern (the digits follow `archive/`, not `specs/`), and that file exists — so the `ψL` provenance may be cited by path, but never as "task 476". `C9D` applies the same rule under `docs/`, so no task number in the ledger rows either. `scripts/check-module-invariants.sh` is excluded from C9 by name, so the baseline edit cannot trip it; `scripts/certificate-witness-inventory.txt` is not in C9's include list at all. |
| C13 | Relative markdown links under `docs/` must resolve. The ledger's File cell is a path, checked separately by C15. |
| C15, second assertion | Every `docs/theorem-index.md` row's declaration must carry, immediately above it (walking back past `@[...]` lines), a `/-- ... -/` block containing `Paper: — (reason)`, since every Paper cell here is `—`. Eight rows ⇒ eight such docstrings. **Verified good news**: this check's identifier class is now Unicode (`((?:[^\W\d]\|[.\'])[\w.\']*)`), with a comment in the script explaining the Greek-letter fix — so `not_plusValidZTime_neg_θ` and `not_plusValidZTime_neg_θ'` are visible to it. The exclusion task 710 had to take no longer applies and must **not** be re-taken. |
| C19 | Docstring-coverage floor 90%. Every landed `def` and headline `theorem` gets a docstring; the supporting lemmas get one too, which the C15 obligation already forces for the eight indexed ones. |
| C23 | Three assertions. (i) zero live `lemma` — the probe uses `theorem` throughout. (ii) no `Uppercase_x` name outside the recorded classes — forces decision D-3's rename of `S_hist_unique`. (iii) no outer-shadows-inner pair — verified clean for every candidate base name. |
| C24 | Every module in the root closure transitively imports `FormalSystem.Init`. Import it explicitly. |
| C26 | No live `def`/`abbrev` with an underscore inside its own name component. None of the landed definitions has one. |
| C27 | No live `#check`/`#eval`/`#print`/`#reduce`/`dbg_trace` in library code, and `linter.hashCommand` is **blocking** in the warning budget. The probe's seven `#print axioms` lines therefore **cannot** be transcribed; the axiom sets are measured in a scratch file and recorded in the C2 baseline and the `Limits/README.md` prose instead. |
| C28 + `scripts/warning-budget.txt` | **Baseline total: 0 warnings across 0 files.** Every observed linter class is `blocking` — including `unusedSectionVars`, `unusedVariables`, `unusedTactic`, `style.multiGoal`, `style.cdot`, `style.longLine`, `deprecated` and `hashCommand`. The new file must reach **zero** warnings; adding a budget row is not an option (counts are a ceiling that may only decrease, and the budget file is outside `file_scope`). |
| C30 | No blanket linter suppression. Only declaration-scoped `set_option ... in`, the per-declaration `omit [...] in` form Lean prints, and a recorded `set_option linter.style.longFile N` at the file head are admissible. |
| C32 | Relative markdown links inside live `.lean` comments must resolve on disk. Prefer bare prose anchors over links in the module docstring. |
| C33 | `FormalSystem.lean` is generated by `lake exe mk_all --lib FormalSystem` and compared byte-for-byte. **Verified**: it lists `...PlusSlicedCertificate.Limits.NoFiniteWidth` explicitly, so adding a module under that directory moves it. Regenerate, never hand-edit. |
| C36a | For each `coverage-limit` row: the declaration must exist under `FormalSystem/`, must be pinned by C2 or C14, and the file it is found in must **equal** the row's recorded anchor path. Hence Phase 7 before Phase 8, and hence D-1's four path-field edits. A row naming a vanished declaration fails as stale, so no row may be uncommented before its declaration is in the tree. C36's own declaration regex is Unicode-aware (`\w` over `str`), so `not_plusValidZTime_neg_θ` is findable. |
| `readme-lint.sh` check 1 (**gated**) | Every directory containing `.lean` files has a `README.md`. **Already satisfied** — `Limits/README.md` exists. Check 3 (broken relative references) is also gated, so README edits must keep every link resolving. Checks 2 and 4 are reported only. |
| `INV` | Three inventory blocks move when a `.lean` file is added under `FormalSystem/Metalogic/Decidability/`: `README.md`, `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md`. Regenerate with `--emit-inventory`, then prove idempotency with `--emit-inventory --check`. `Limits/README.md` must **not** gain an inventory marker. |
| `check-evidence-probes.sh` | Must keep exiting 0 with the `WIRED_REPO` entry for `NoFiniteCarrierModel.lean` **unedited**. The landed declarations are in a different namespace from `Probe706`, so the probe keeps compiling. |

### Declared-scope extensions, stated rather than taken quietly

`file_scope` names five paths. It names `PlusSlicedCertificate/FiniteCarrier.lean`; D-1 lands at
`PlusSlicedCertificate/Limits/FiniteCarrier.lean` instead, which the dispatch authorizes
explicitly. Five further files must change, each mechanically forced by a gate above:

1. `FormalSystem.lean` — generated by `mk_all`; C33 fails without it.
2. `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` — one `Modules`
   row, a widened purpose sentence, and the two-axis scope paragraph. Its check-3 links must
   keep resolving.
3. `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated by
   `check-module-invariants.sh --emit-inventory`; `INV` fails without it.
4. `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` — one roster row beside
   the existing `Limits/NoFiniteWidth.lean` row. Advisory only (`readme-lint.sh` check 2 is
   reported, not gated); included because it is one row and leaves the subtree roster honest.
   Drop it if a sibling is found editing that file.

**Sibling collisions, so staging stays narrow.** This task declares
`scripts/check-module-invariants.sh` (also declared by task 705 and by follow-up H2 of
`specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md`),
`scripts/certificate-witness-inventory.txt` (also task 716) and `docs/theorem-index.md` (also
task 710, which has landed). The mandated order is 710 → **706** → 720, with 705 after. Never
stage with `git add -A` or a directory pathspec; always an explicit file list.

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | A landed signature drifts from the verbatim block — a stray hypothesis on `R`, `[Finite F.WorldState]` demoted to an explicit argument, or `ofSlicedStep` substituted for `ofStep` | H | L | The verbatim block is the authority. Phases 3 and 4 diff the landed signature against it character by character before committing. Any difference is reported, not absorbed |
| R2 | The landed docstrings read as claiming more than the probe proves — a dense duration, an infinite carrier, a soundness consequence, or a bound | H | M | Deliverable 3's two scope limits plus the two further disclaimers go into the module docstring **and** onto `not_finite_carrier_fmp`'s and `not_finite_carrier_fmp_fragment`'s own docstrings in Phases 1, 3 and 4, before the theorems land. Phase 9 re-reads them against `FMP/README.md`'s "The finite-carrier route is refuted, not merely open" section and confirms no over-claim |
| R3 | The `⊡`-free / `⊡`-bearing asymmetry gets blurred, so the landed text reads as if both halves were L⁺-specific, or as if the carrier refutation were the stronger one | H | M | Deliverable 2 requires **both** halves on record: `θ` is `⊡`-free (hence already about TM), 710's `Φ` uses `⊡` (hence L⁺-only); and the obstruction chain runs the other way — finite carrier is strictly **weaker** than finite per-time width, since a finite carrier forces finite width, so 710's is the stronger refutation on the hypothesis axis and this one on the language axis. Both sentences go in the module docstring in Phase 1 and are re-checked in Phase 9 against `FMP/README.md`'s wording |
| R4 | Blocking linter warnings: the budget baseline is **zero** and every class is blocking, so a single `unusedSectionVars`, `unusedVariables` (e.g. `set L := y - x with hL`, whose `hL` may go unused), `unusedTactic`, `style.multiGoal` or `deprecated` hit (e.g. `Int.abs_lt_one_iff`) fails C28 | H | H (near-certain) | Each content phase ends by reading the `lake build` output for its own file and driving the count to zero with the per-declaration `omit [...] in` / `_`-prefixed-binder / `·`-focused form the budget's disposition rows direct. Budget ~15 min of each content phase for this. Measure from build output, never by eye. If a deprecation is hit, use the replacement the warning names |
| R5 | The probe's seven `#print axioms` lines get transcribed, failing C27 and `linter.hashCommand` | M | M | They are deliberately dropped. The axiom sets are measured once, in Phase 7, in a scratch file compiled with `lake env lean`, and recorded in the C2 baseline and in `Limits/README.md` prose. Phase 9 greps the landed file for `#` directives as a backstop |
| R6 | Task-number citations in the probe's prose land under `FormalSystem/` and fail C9 | H | H (certain) | Phase 1 rewrites every one to a durable anchor while writing the module docstring — `FMP/README.md`'s section name, `PlusSlicedCertificate.lean`'s carrier section, the archived evidence file's path (verified not to match C9's pattern). `grep -nE 'task[s]? [0-9]\|specs/[0-9]{3}_' <file>` before each commit |
| R7 | A declaration reports `does not depend on any axioms` (likely for `θ_eq_ofFormula := by decide`), and a baseline line is written for it anyway, breaking C2's exact-string comparison | M | M | Phase 7 **measures first** and writes the baseline from the measured output, in the measured order. A declaration with no axioms gets no baseline line, and its ledger Axioms cell is written literally rather than as `pcq pinned:C2` |
| R8 | A `pinned:C2` token is written for a row whose baseline line does not land in the same change, repeating the known-ungrounded defect on three existing rows | M | M | Phase 9 writes the Axioms cells **after** Phase 7 has landed green, and only for declarations whose baseline line is in the diff. `grep -n 'pinned:C' docs/theorem-index.md` is a Phase 9 verification item |
| R9 | D-2's reuse-by-import stalls (elaboration, import narrowing, or an unexpected coupling) | M | L | The recorded fallback is local definitions plus `noFiniteWidth_Φ_eq := by decide`. Take it after one honest attempt, record it as a deviation, and do not spend a phase on the import |
| R10 | Narrowing `import FormalSystem` to a minimal set breaks an unnoticed dependency or stalls | M | M | The target set is verified by declaration site: `FormalSystem.Init` (C24), `FormalSystem.Semantics.ShiftSet` (`ShiftSet` at line 97, with `frame`, `frame_isRegular`, `hist`, `model`, `total_eq_orbit`, `ShiftTruth`, `forward_repr`), `FormalSystem.Semantics.IntNormalForm` (`worldHistoryOfStepPath` at 323, `mem_HF_iff_adjacent` at 348, `FrameOver.ofStep`), `FormalSystem.PlusLanguage.PlusValidity` (`PlusValidZTime`, `plusTruthAt_ofFormula` at 168, `ofFormula`), `...Limits.NoFiniteWidth` (D-2), and `Mathlib.Tactic.Ring` (the probe uses `ring`). `intOrder` is `Semantics/TemporalOrder.lean:152` and `isZTime_of_instances` is `Semantics/FrameProperty.lean:279`, both reached transitively — add explicitly only if the build asks. If narrowing stalls, fall back to the broader import that compiles and record it; a minimal import list is not worth a phase |
| R11 | C2's spelled-out row count in the pass message is missed, so C2 fails on a cosmetic mismatch | M | M | Phase 7's verification counts the baseline lines and asserts the message's spelled-out numeral matches, before running the gate |
| R12 | An inventory row is uncommented before its declaration is in the tree, or with the old path, and C36a fails as stale | M | L | Phase 8 depends on Phase 7 (which depends on the module being in the build graph). Each uncommented row's fourth field is edited to the `Limits/` path in the same edit that uncomments it |
| R13 | A sibling task edits a shared file mid-phase (`check-module-invariants.sh` with 705/H2, the inventory with 716, the ledger with 710) | M | L | Territory discipline: re-read every shared file immediately before editing it; stage only this task's hunks with an explicit file list; treat an out-of-`file_scope` build failure as possibly a sibling's in-flight edit; stop and report any foreign commit or uncommitted modification found by `git log` / `git status --short` |
| R14 | The prose repair in `PlusSlicedCertificate.lean` drifts into the "What is refuted, and what is open" section and restates a sliced-class verdict that is 710's deliverable | M | M | Phase 6 edits only the two paragraphs of "The carrier is infinite, with finite fibres, and that is forced" and verifies with `git diff` that the later section is byte-identical |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5 |
| 7 | 8 | 7 |
| 8 | 9 | 6, 8 |

Phases within the same wave can execute in parallel. In practice Phases 1-4 all write the single
new module and must run in document order; Phase 6 (prose in the subtree root) is the one
genuinely parallel phase, needing only the landed names from Phases 3 and 4.

---

### Phase 1: Module skeleton, the witness, and the `⊡`-free status [COMPLETED]

**Goal**: `Limits/FiniteCarrier.lean` exists, compiles, carries the module docstring with
Deliverables 2 and 3 in it, and lands `θ`, `ψL` and `θ_eq_ofFormula`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean`
      with the four-line Apache copyright header every sibling carries
- [ ] Write the import block: `FormalSystem.Init`, `FormalSystem.Semantics.ShiftSet`,
      `FormalSystem.Semantics.IntNormalForm`, `FormalSystem.PlusLanguage.PlusValidity`,
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth`,
      `Mathlib.Tactic.Ring`. Add nothing else unless the build asks (R10)
- [ ] Write the `/-! -/` module docstring on the model of `Limits/NoFiniteWidth.lean`'s:
      the witness and what it says; the argument in numbered steps (history meets `p` at `a`;
      `p`-free left of `a` by the second conjunct read at every time; pigeonhole on the finite
      carrier; the repeat-cycle pumped bi-infinitely is a step path hence a history by
      `mem_HF_iff_adjacent`, and never meets `p`); the consequence for a finite-carrier
      certificate shape; a `## Main results` list; a `## Tags` line
- [ ] **Deliverable 2, in the docstring, in these terms**: `θ` contains no `⊡`;
      `θ_eq_ofFormula` proves it by exhibiting `θ` as `ofFormula ψL`; **that is what makes this
      half a result about the base language TM itself**, not an L⁺-specific result. Record both
      halves of the contrast with the finite-width landing: that witness **does** use `⊡`, so
      that half is specifically an L⁺ result and says nothing about TM; and the obstruction chain
      runs the other way — a finite carrier **forces** finite per-time width, so finite carrier
      is the strictly **weaker** hypothesis and the width refutation is the stronger one on the
      hypothesis axis while this one is stronger on the language axis
- [ ] **Deliverable 3, in the docstring**: scope is ℤ (discrete) frames only — the pumping
      argument needs discreteness and says nothing about a dense duration; **nothing** is claimed
      about an infinite carrier; **nothing** touches soundness — `plusTruth_iff_mem` and
      `plusRefutes_of_certifies` keep their statements and are unused in the refuting direction.
      Add a "Not claimed" line: no carrier bound of any kind
- [ ] Re-anchor every task-number reference from the probe's prose onto a durable anchor (R6);
      `FMP/README.md`'s "The finite-carrier route is refuted, not merely open" section and
      `PlusSlicedCertificate.lean`'s "The carrier is infinite, with finite fibres, and that is
      forced" section are the two anchors to use. Keep the `ψL` provenance as the archived
      evidence path (verified C9-safe), never as a task number
- [ ] Open `namespace FormalSystem.Metalogic.Decidability`, then `PlusSlicedCertificate`, then
      `FiniteCarrier`, with a comment recording why the single-letter definitions are nested
      (the `NoFiniteWidth` precedent)
- [ ] Per D-2, take `pa`, `p`, `Fp`, `Pp` from `NoFiniteWidth`; define only `A`, `C`, `θ` and
      `ψL` here, each with a docstring. Add the sentence recording that the `NoFiniteWidth`
      import exists to share definitions with the width landing and that `θ` uses nothing from it
- [ ] Land `θ_eq_ofFormula` with a `/-- ... Paper: — (reason) -/` docstring (C15)
- [ ] Drive this file's `lake build` warning count to **zero** (R4)
- [ ] Verify no task-number citation and no `#` directive in the file; commit

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: hypothesised to transcribe probe lines 1-62 (the header, `pa`/`p`/`Fp`/`Pp`/`A`/`C`/`θ`/`ψL`/`θ_eq_ofFormula`, about 60 source lines) into roughly 150 landed
lines once the docstrings are written, with `pa`/`p`/`Fp`/`Pp` **not** transcribed (D-2 reuses
them). Confirm by reading the probe's actual line span before transcribing; a materially larger
span means the probe is not what this plan read and the phase should stop and report.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` - new module: header, imports, module docstring, witness definitions, `θ_eq_ofFormula`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.FiniteCarrier`
  succeeds with **zero** warnings
- `θ_eq_ofFormula` type-checks, confirming the `⊡`-free status mechanically rather than in prose
- `grep -nE 'task[s]? +#?[0-9]+|task-[0-9]+|specs/[0-9]{3}_' <file>` returns nothing
- `grep -nE '^\s*#(print|eval|check|reduce)' <file>` returns nothing
- The docstring contains both scope limits, both further disclaimers, and both halves of the
  `⊡`-free / `⊡`-bearing contrast

---

### Phase 2: The positive half — the shift set and `not_plusValidZTime_neg_θ` [COMPLETED]

**Goal**: `θ.neg` is landed as a genuine ℤ-time non-validity of L⁺.

**Tasks**:
- [ ] Transcribe the shift set `S : ShiftSet intOrder` (`sh w d := w + d`, carrier `ℤ`, `A _ w :=
      w = 0` so `p` is true only at state `0`), with a docstring recording that the valuation is
      atom-independent by construction
- [ ] Transcribe `shiftTruth_psiL : ∀ w t, S.ShiftTruth w t ψL`
- [ ] Land `not_plusValidZTime_neg_θ`, routed as the probe routes it — `θ_eq_ofFormula`, then
      `plusTruthAt_ofFormula`, then `S.forward_repr` — with a
      `/-- ... Paper: — (reason) -/` docstring (C15)
- [ ] Record in the docstring that this is the **positive** half and that it is what makes the
      negative half a coverage limit rather than a validity
- [ ] Drive this file's warning count back to zero (R4)
- [ ] Commit

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 64-104 (the `abbrev S` block,
`shiftTruth_psiL`, `not_plusValidZTime_neg_θ`; about 40 source lines). The `sep` field's
`by decide` and the `omega`-driven trichotomy in `shiftTruth_psiL` are the two places most likely
to need a tactic adjustment under the narrowed import set; confirm by building, and if `decide`
stalls, report rather than re-proving.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` - the shift set, `shiftTruth_psiL`, `not_plusValidZTime_neg_θ`

**Verification**:
- The module builds with zero warnings
- `not_plusValidZTime_neg_θ`'s statement is character-identical to the verbatim block
- The declaration carries a `Paper: — (reason)` line in its own `/--` block

---

### Phase 3: The negative half — `no_finite_carrier_sat` and its two corollaries [COMPLETED]

**Goal**: the core refutation and its two consequences are landed, under the exact hypotheses the
verbatim block records.

**Tasks**:
- [ ] Open `section Finite` with `variable {F : FrameOver intOrder} [F.IsRegular]`
- [ ] Transcribe the step-path-to-history helper as `histOfStepPath` (D-3's rename of the probe's
      `mk`), built on `FrameOver.worldHistoryOfStepPath`, with a docstring
- [ ] Transcribe `steps` with its per-declaration `omit [F.IsRegular] in`, exactly the form the
      budget's `unusedSectionVars` disposition directs
- [ ] Land `no_finite_carrier_sat`, with a docstring that states `[Finite F.WorldState]` is the
      **whole** finiteness hypothesis and that there is no hypothesis on the succession relation
      beyond the regularity `[F.IsRegular]` carries, plus `Paper: — (reason)`
- [ ] Land `no_ofStep_sat`, with a docstring recording that `FrameOver.ofStep`'s relation is
      time-independent (`R : W → W → Prop`) and is **not** `FrameOver.ofSlicedStep`, whose
      relation is `ℤ → W → W → Prop`, plus `Paper: — (reason)`
- [ ] Land `not_finite_carrier_fmp`, with a docstring carrying Deliverable 3's two scope limits
      and two further disclaimers in full (this is the theorem most likely to be over-read), plus
      `Paper: — (reason)`
- [ ] Diff all three landed signatures against the verbatim block, character by character (R1)
- [ ] Drive the warning count back to zero; `set L := ... with hL` and the `Int.emod` lemma names
      are the likely sites (R4)
- [ ] Commit

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 106-200 (the `Finite` section plus
`no_ofStep_sat` and `not_finite_carrier_fmp`; about 95 source lines), with the pigeonhole step
(`Finite.exists_ne_map_eq_of_infinite`) and the `Int.emod` cycle arithmetic as the two
transcription-risk spots. Confirm the span by reading the probe; confirm the hypothesis set by
`lean_hover_info` or the build's own signature echo on each of the three, not by eye.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` - `histOfStepPath`, `steps`, `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`

**Verification**:
- The module builds with zero warnings and no `sorry`
- Each of the three signatures matches the verbatim block exactly, including binder forms:
  `[Finite F.WorldState]` as an instance argument on `no_finite_carrier_sat`, and
  `(_ : F.IsRegular) (_ : Finite F.WorldState)` as explicit anonymous binders inside
  `not_finite_carrier_fmp`'s `∃`
- `no_ofStep_sat` mentions `FrameOver.ofStep`, never `FrameOver.ofSlicedStep`
- Each of the three carries a `Paper: — (reason)` line

---

### Phase 4: The fragment twins, and the agreement with the finite-width witness [COMPLETED]

**Goal**: the `⊡`-bearing CTL-like fragment fails the same way, with `θ'` shared rather than
copied.

**Tasks**:
- [ ] Per D-2, define `θ' : PlusFormula := NoFiniteWidth.A'.and NoFiniteWidth.C'`, with a
      docstring recording that `A'` and `C'` are the width landing's own definitions and that
      the width witness extends `θ'` by one conjunct
- [ ] Land `noFiniteWidth_Φ_eq : NoFiniteWidth.Φ = θ'.and NoFiniteWidth.D := rfl`, so the
      agreement between the two landings is mechanical rather than asserted. If `rfl` does not
      close it, use `by decide`; if neither does, take D-2's fallback and record the deviation
- [ ] Transcribe `shift_hist_unique` (D-3's rename of `S_hist_unique`), `stab_iff_S` and
      `θ'_of_θ`, each with a docstring; `stab_iff_S`'s should record that `⊡` collapses on the
      shift set because histories through a state are unique there
- [ ] Land `not_plusValidZTime_neg_θ'` with a `Paper: — (reason)` docstring
- [ ] Open `section Finite'` with the same `variable` line and land `no_finite_carrier_sat'`,
      with a docstring stating the same whole-finiteness-hypothesis fact and `Paper: — (reason)`
- [ ] Land `not_finite_carrier_fmp_fragment` with a docstring that (a) carries the scope limits
      and disclaimers, (b) says the fragment does **not** rescue the finite-carrier shape, and
      (c) states plainly that this twin **does** bear `⊡`, so unlike `θ` it is an L⁺ result and
      not a TM one — the asymmetry R3 guards
- [ ] Add a closing docstring note that the fragment's **own** finite model property is a
      separate, research-first question this landing neither answers nor assumes
- [ ] Diff the three landed signatures against the verbatim block (R1)
- [ ] Drive the warning count to zero; close the two sections with `end`; commit

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 202-340 (the fragment section: `A'`/`C'`/`θ'`,
`S_hist_unique`, `stab_iff_S`, `θ'_of_θ`, `not_plusValidZTime_neg_θ'`, the `Finite'` section and
`not_finite_carrier_fmp_fragment`; about 140 source lines, of which the `no_finite_carrier_sat'`
body duplicates Phase 3's almost exactly). Confirm the span by reading the probe. Whether the
duplicated body can be factored is **not** this phase's question: transcribe it as the probe has
it and note any factoring opportunity for a successor rather than inventing one here.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` - `θ'`, `noFiniteWidth_Φ_eq`, `shift_hist_unique`, `stab_iff_S`, `θ'_of_θ`, `not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment`

**Verification**:
- The module builds with zero warnings and no `sorry`
- `noFiniteWidth_Φ_eq` type-checks, proving the two landings agree on `θ'` rather than asserting it
- The three signatures match the verbatim block exactly
- Each of the three carries a `Paper: — (reason)` line
- `grep -n "def A'\|def C'" <file>` returns nothing (D-2: reused, not copied) — or, if the
  fallback was taken, `noFiniteWidth_Φ_eq` is present and the deviation is recorded in the commit

---

### Phase 5: Wire the module into the build graph [COMPLETED]

**Goal**: the new module is reachable from `lake build`, the directory's README covers it, and
the whole library is green.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` first (territory
      discipline; task 710 touched it this cycle), then add
      `import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.FiniteCarrier`
      to the import block, beside the `Limits.NoFiniteWidth` line
- [ ] Add a `## Submodules` bullet for `PlusSlicedCertificate.Limits.FiniteCarrier` in the style
      of its siblings
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. **Never** hand-edit
      `FormalSystem.lean` (C33 compares byte for byte)
- [ ] Edit `PlusSlicedCertificate/Limits/README.md`: widen the opening sentence so the directory's
      stated purpose covers **both** obstruction axes (the sliced class's finite *width* and the
      rejected finite-*carrier* shape) rather than only the first; add a `Modules` table row for
      `FiniteCarrier.lean`; add the `⊡`-free / `⊡`-bearing asymmetry and the
      weaker-hypothesis/stronger-language direction to its "What is refuted, and what is not"
      section; add a Provenance sentence naming the probe with the `specs/.../probes/` ellipsis
      form the sibling uses (C9); update `*Last verified: <ISO date>*`. Add **no** inventory
      marker
- [ ] Add one roster row for `Limits/FiniteCarrier.lean` to
      `PlusSlicedCertificate/README.md`'s module table, beside the `Limits/NoFiniteWidth.lean`
      row (advisory; drop if a sibling is editing that file)
- [ ] Full `lake build`
- [ ] Commit the batch

**Timing**: 45 minutes

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: hypothesised as exactly four files (the subtree root, the generated
`FormalSystem.lean`, `Limits/README.md`, and the subtree `README.md`). Confirm with
`git status --short` before staging; a fifth path means something unplanned happened and must be
read before it is staged.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one import line plus one `## Submodules` bullet
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` (never by hand)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` - widened purpose, one `Modules` row, the asymmetry paragraph, provenance, date
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` - one roster row (advisory)

**Verification**:
- `lake build` succeeds for the whole library, with zero warnings
- `bash scripts/readme-lint.sh` exits 0 (checks 1 and 3)
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/check-metalogic-cycles.sh` exits 0
- `lake exe mk_all --lib FormalSystem` run a second time reports no update necessary
- `git status --short` shows exactly the four planned paths

**Commit-mode note**: the import line, the regenerated root and the README row are one objective
because the intermediate states are genuinely red — an import added without regenerating the root
fails C33. This is a pre-declared batch, not a retroactively widened one.

---

### Phase 6: Replace the subtree root's unanchored prose with the landed names [COMPLETED]

**Goal**: Deliverable 6. `PlusSlicedCertificate.lean`'s header argues the finite-carrier point by
name instead of in unanchored prose.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`'s section
      "The carrier is infinite, with finite fibres, and that is forced" in full before editing
- [ ] In its first paragraph, replace the unanchored claim — "A certificate whose presented frame
      has a **finite carrier** cannot certify a `⊡`-free ℤ-time non-validity that the landed
      `Formula`-side witness family already certifies" — with a citation of
      `Limits.FiniteCarrier.not_finite_carrier_fmp` by name, in the same citation style the
      section below already uses for `Limits.NoFiniteWidth.not_sliced_complete`
- [ ] In its second paragraph, replace the fragment claim — "Restricting the language to the
      CTL-like fragment does **not** rescue the finite-carrier shape" — with a citation of
      `Limits.FiniteCarrier.not_finite_carrier_fmp_fragment` by name, keeping the closing
      sentence that the fragment's own finite model property is a separate, research-first
      question
- [ ] Add one sentence recording the `⊡`-free status by name (`Limits.FiniteCarrier.θ_eq_ofFormula`),
      so the TM-level scope is on record at the subtree root too
- [ ] Verify with `git diff` that the later section "What is refuted, and what is open" is
      **byte-identical** — its sliced-class verdicts are task 710's deliverable (R14)
- [ ] Verify no task-number citation entered the file; commit

**Timing**: 30 minutes

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: hypothesised as exactly two paragraphs plus one added sentence, inside one
file, at roughly lines 239-252. Confirm by `git diff --stat` (one file) and by reading the diff
hunks: a hunk outside that section means the edit overreached and must be reverted before
committing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - the two paragraphs of the carrier section, plus one sentence naming `θ_eq_ofFormula`

**Verification**:
- `lake build` green
- `git diff FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` touches only the
  carrier section (the `## Submodules` bullet from Phase 5 is already committed)
- The two named theorems appear in the section; the phrases "cannot certify a `⊡`-free ℤ-time
  non-validity" and "does **not** rescue the finite-carrier shape" no longer stand alone without
  a name beside them
- `grep -nE 'task[s]? +#?[0-9]+|specs/[0-9]{3}_' <file>` returns nothing

---

### Phase 7: Pin the axiom sets in the C2 baseline [NOT STARTED]

**Goal**: every landed declaration that an inventory row or a ledger row cites has its axiom set
asserted on every build, measured rather than assumed.

**Tasks**:
- [ ] Re-read `scripts/check-module-invariants.sh`'s C2 block first (territory discipline: task
      705 and follow-up H2 both declare this file)
- [ ] **Measure first.** Compile a scratch file with `lake env lean` containing
      `import FormalSystem` and one `#print axioms` line for each of the eight landed
      declarations — `θ_eq_ofFormula`, `not_plusValidZTime_neg_θ`, `no_finite_carrier_sat`,
      `no_ofStep_sat`, `not_finite_carrier_fmp`, `not_plusValidZTime_neg_θ'`,
      `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` — fully qualified. Record the
      exact output lines (R7)
- [ ] Add one `#print axioms` line per declaration to C2's `AX_SRC` heredoc, after the existing
      sliced-certificate lines, **and** the matching measured baseline line to `AXIOM_BASELINE`,
      in the identical order. A declaration whose output reads `does not depend on any axioms`
      gets **no** baseline line and **no** `#print axioms` line — that output is dropped by the
      `grep 'depends on axioms'` filter and a baseline line for it would fail C2 outright (R7)
- [ ] Update C2's `pass` message so its spelled-out numeral equals the new baseline row count
      (currently "thirty-four"); count the lines, do not estimate (R11)
- [ ] Extend the C2 header comment with one short paragraph saying what the new rows pin and why
      — a finite-carrier refutation whose axiom set silently changed would make a claim about the
      base language rest on a new foundation — without naming a task number (C9 excludes this
      file by name, but the convention is worth keeping)
- [ ] **Optional, and droppable.** The ledger currently records a standing exception: the five
      `PlusSlicedCertificate.NoFiniteWidth` rows read `pcq (not yet in the C2/C14 baseline)`
      because adding the pin was "a different task's `file_scope`" — this task's. If the eight-row
      edit above is already green, measure those five the same way and add them too, in the same
      hunk. **Drop this item and report** if any of the five measures differently from `pcq`
      (that is a finding, not a rewrite job), or if `git log`/`git status` shows another writer
      in this file. Do not adjust anything in `Limits/NoFiniteWidth.lean` either way
- [ ] Run `bash scripts/check-module-invariants.sh` and read the C2 line individually
- [ ] Commit

**Timing**: 45 minutes

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: hypothesised as eight new baseline rows and eight new `#print axioms`
lines, all eight measuring `[propext, Classical.choice, Quot.sound]` **except**
`θ_eq_ofFormula`, which is proved `by decide` and is hypothesised to report no axioms at all and
therefore to get no row. Both halves of that hypothesis are to be **confirmed by the measured
output** before a single line is typed; the measured output wins over this hypothesis in every
case.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C2's `AXIOM_BASELINE` heredoc, C2's `AX_SRC` heredoc, C2's pass-message numeral, and one header paragraph

**Verification**:
- `bash scripts/check-module-invariants.sh` prints `PASS  C2` with the new numeral
- The baseline rows and the `#print axioms` lines are in the same order and the same count
- The two heredocs' new lines are byte-identical to the measured output
- C21 and C36 still pass (both read these baselines)
- `git diff --stat` shows exactly one file

---

### Phase 8: The inventory rows [NOT STARTED]

**Goal**: Deliverable 5. The reserved rows name a path something actually lands at, are
uncommented, and the fragment twins get rows of their own.

**Tasks**:
- [ ] Re-read `scripts/certificate-witness-inventory.txt` first (territory discipline: task 716
      declares it too)
- [ ] Uncomment the four reserved `coverage-limit` rows, editing each one's **fourth** field from
      `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FiniteCarrier.lean` to
      `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean`
      (D-1). Leave the second field — the fully qualified declaration name — **unchanged**
- [ ] Add three new `coverage-limit` rows for the fragment twins
      (`...FiniteCarrier.not_plusValidZTime_neg_θ'`, `...FiniteCarrier.no_finite_carrier_sat'`,
      `...FiniteCarrier.not_finite_carrier_fmp_fragment`) in the same four-field grammar, each
      with the same anchor path and a one-clause "what it refutes"
- [ ] Rewrite the block's heading comment: it currently reads "RESERVED ... pending the refutation
      module (FiniteCarrier.lean) landing under FormalSystem/" with the instruction to uncomment
      each row when its declaration is in the tree. That block is now discharged, so replace the
      heading with a live one naming the finite-carrier axis beside the existing
      coverage-limit rows, and delete the now-false "until then C36 counts them in its census and
      asserts nothing about them" sentence
- [ ] Add **no** row for `θ_eq_ofFormula`: the grammar admits `witness` and `coverage-limit` rows
      only, and a language-scope identity is neither
- [ ] Run `bash scripts/check-module-invariants.sh` and read the C36 census and the `C36a` line
      individually: the reserved count should drop to zero and the coverage-limit count should
      rise by seven
- [ ] Commit

**Timing**: 30 minutes

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: hypothesised as exactly one file, four rows uncommented-and-repathed, three
rows added, and one comment block rewritten — seven live `coverage-limit` rows added in total,
all seven pinned by Phase 7. Confirm by counting `coverage-limit` rows before and after
(5 → 12) and by reading C36's census line; a different delta means a row was missed or
double-counted.

**Files to modify**:
- `scripts/certificate-witness-inventory.txt` - four rows uncommented with corrected anchors, three new rows, one comment block rewritten

**Verification**:
- `bash scripts/check-module-invariants.sh` prints `PASS  C36a`, with no "stale row", no "not
  found under FormalSystem/", no "lives in ..., not the recorded anchor" and no "pinned by
  neither C2 nor C14" problem
- C36's census line reports `0 reserved (commented) row(s)`
- Every new row's fourth field is the `Limits/FiniteCarrier.lean` path and resolves on disk
- `git diff --stat` shows exactly one file

---

### Phase 9: Ledger rows, generated surfaces, and the full gate set [NOT STARTED]

**Goal**: Deliverable 4 plus a green gate set. Every landed theorem has a ledger row; every
generated surface the new file moved is current; no landed claim exceeds the record.

**Tasks**:
- [ ] Re-read `docs/theorem-index.md`'s row format and its five `NoFiniteWidth` rows first
      (territory discipline: task 710 wrote them this cycle)
- [ ] Add one row per landed theorem — `θ_eq_ofFormula`, `not_plusValidZTime_neg_θ`,
      `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
      `not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` —
      immediately after the five `NoFiniteWidth` rows, in the six-cell shape:
      six cells in this order: an em-dash Paper cell, a one-line statement, the fully
      qualified Lean name in backticks, the path in backticks with **no** line number, the frame
      class, and the axioms cell. Copy the cell shape from the two existing
      `PlusWitnessFamily/Limits/` refutation rows (`not_plusValidZTime_pumpTarget`,
      `not_exists_plusCertifies_pumpTarget`), which Deliverable 4 names as the format precedent
- [ ] Frame class: `ZTime` where the statement is at ℤ-time, `—` where class-generic. Decide per
      row from the statement, not by pattern
- [ ] Axioms cells: `pcq pinned:C2` **only** for rows whose baseline line landed in Phase 7. For
      any declaration Phase 7 measured as axiom-free, write the measured value out literally and
      say in the cell that it is not in the baseline — never a `pinned:` token (R8, and
      Deliverable 4's prohibition)
- [ ] If Phase 7's optional item landed the five `NoFiniteWidth` pins, update those five rows'
      Axioms cells to `pcq pinned:C2` and **delete** the ledger's now-false standing-exception
      paragraph. If it did not, leave both untouched and leave the paragraph as written
- [ ] Use no task number anywhere in the ledger edit (`C9D`)
- [ ] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      then `bash scripts/check-module-invariants.sh --emit-inventory --check` to prove no byte
      would change. Expect `README.md`, `FormalSystem/README.md` and
      `FormalSystem/Metalogic/README.md` to move
- [ ] Run the **full** gate set and read C1, C2, C3, C9, C9D, C15 (both assertions), C19, C23,
      C24, C27, C28, C30, C33, C36 and INV individually rather than only the exit code
- [ ] Re-read the landed docstrings against
      `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route is refuted,
      not merely open" section and confirm no landed claim exceeds it, and that the
      `⊡`-free / `⊡`-bearing asymmetry and the weaker-hypothesis direction are stated as that
      section states them (R2, R3)
- [ ] Confirm `bash scripts/check-evidence-probes.sh` exits 0 with the `WIRED_REPO` entry for
      `NoFiniteCarrierModel.lean` **unedited** (moving or converting it is task 720's scope)
- [ ] Commit

**Timing**: 1.25 hours

**Depends on**: 6, 8

**Verification Tier**: full

**Scope Hypothesis**: hypothesised as eight new ledger rows and exactly three regenerated
inventory files, with the ledger's standing-exception paragraph moving only if Phase 7's optional
item landed. Confirm by counting the added rows and by `git status --short` after
`--emit-inventory`; a fourth regenerated file means an inventory block this plan's survey missed,
and must be read before it is staged.

**Files to modify**:
- `docs/theorem-index.md` - eight ledger rows (plus, conditionally, five amended Axioms cells and one deleted paragraph)
- `README.md` - regenerated inventory totals
- `FormalSystem/README.md` - regenerated loose-file inventory
- `FormalSystem/Metalogic/README.md` - regenerated subdirectory inventory

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with **both** C15 assertions passing on all
  eight new rows — in particular the two Greek-named ones, which the current Unicode-aware
  identifier class can see
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no byte would change
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/check-evidence-probes.sh` exits 0 with the probe entry unedited
- `grep -n 'pinned:C' docs/theorem-index.md` shows a token only on rows whose baseline line exists
- `lake build` green, zero warnings, and the new module sorry-free

---

## Testing & Validation

- [ ] `lake build` exits 0 for the whole library, with zero compiler warnings (C28's baseline is
      zero across zero files; every class is blocking)
- [ ] The new module contains no `sorry` and no `#print`/`#eval`/`#check`/`#reduce` directive
- [ ] All eight landed signatures match the verbatim block character for character, with
      `[Finite F.WorldState]` the whole finiteness hypothesis on the two `sat` theorems and
      `(_ : F.IsRegular) (_ : Finite F.WorldState)` the explicit binders in the two `fmp` theorems
- [ ] `θ_eq_ofFormula` and `noFiniteWidth_Φ_eq` both type-check, so the `⊡`-free status and the
      agreement with the finite-width landing are machine-checked rather than asserted
- [ ] Every landed docstring carries Deliverable 3's two scope limits and two further
      disclaimers, and the module docstring carries both halves of Deliverable 2's contrast
- [ ] `bash scripts/check-module-invariants.sh` exits 0, with C2, C9, C15 (both assertions), C23,
      C27, C28, C30, C33, C36a and INV read individually
- [ ] `bash scripts/readme-lint.sh`, `bash scripts/check-copyright-headers.sh`,
      `bash scripts/check-metalogic-cycles.sh` and `bash scripts/check-evidence-probes.sh` each
      exit 0
- [ ] `grep -rnE 'task[s]? +#?[0-9]+|task-[0-9]+|specs/[0-9]{3}_[A-Za-z0-9_]+'` finds nothing new
      under `FormalSystem/` or `docs/`
- [ ] `PlusSlicedCertificate.lean`'s "What is refuted, and what is open" section is byte-identical
      to its pre-task state
- [ ] `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched, in statement and in proof
- [ ] The probe file `specs/.../probes/NoFiniteCarrierModel.lean` is unedited, and
      `check-evidence-probes.sh`'s `WIRED_REPO` entry for it is unchanged

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier.lean` — new
  module: eight landed theorems plus the shift set, the step-path helper and the three fragment
  support lemmas
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one import, one `## Submodules`
  bullet, and the carrier section's two paragraphs replaced by name citations
- `FormalSystem.lean` — regenerated
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` — widened purpose,
  one `Modules` row, the two-axis asymmetry paragraph, provenance
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` — one roster row
- `scripts/check-module-invariants.sh` — up to eight (conditionally thirteen) new C2 baseline
  rows and `#print axioms` lines, plus the pass-message numeral
- `scripts/certificate-witness-inventory.txt` — four reserved rows uncommented and repathed,
  three new rows, one comment block rewritten
- `docs/theorem-index.md` — eight ledger rows
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated
  inventory blocks
- `specs/706_lplus_finite_model_property_and_completeness/summaries/01_land-finite-carrier-refutation-summary.md`
  — execution summary

## Contingencies

- **C1 — `decide` stalls on `θ_eq_ofFormula`.** Report the timing and try `by native_decide`?
  **No**: `native_decide` adds an axiom, which the hard constraints forbid. Instead prove the
  identity by `rfl` or by `simp [θ, ψL, ofFormula]`, and if none closes it, stop and report —
  the `⊡`-free status is Deliverable 2's whole content and must not be downgraded to prose.
- **C2 — D-2's reuse-by-import does not elaborate.** Take the recorded fallback (local
  definitions plus `noFiniteWidth_Φ_eq`), record the deviation in the phase commit, and do not
  spend further time on the import.
- **C3 — a gate outside `file_scope` fails.** Report it; do not edit the gate script to quiet it.
  The one exception is `scripts/check-module-invariants.sh`, which this task declares, and there
  only the C2 block (Phase 7) is in scope — never an `ENFORCE_*` flag flipped to 0.
- **C4 — a sibling's in-flight edit is found in a shared file.** Stop, report the foreign commit
  or uncommitted modification, and do not stage over it. The admission gate exists to prevent
  exactly this, so its appearance is a finding.
- **C5 — Phase 7's measurement shows an unexpected axiom** (anything beyond
  `[propext, Classical.choice, Quot.sound]` or an empty set). Do **not** write the surprising
  value into the baseline and move on: an unexpected axiom under a refutation about the base
  language is a finding about the landed proof. Record it, land the baseline line that matches
  the measurement, and report the divergence in the summary.
- **C6 — the transcription exceeds the `longFile` ceiling.** The one admissible fix is a recorded
  `set_option linter.style.longFile N` at the file head (C30 permits this form; `EmbedComplete.lean`
  uses it). Set `N` to the smallest value that passes; do not split the module to satisfy it.

## Rollback/Contingency

Each phase commits independently, so rollback is per phase. Before any intentional rollback that
would discard uncommitted work, run `bash .claude/scripts/git-snapshot.sh 706` first, then the
destructive command.

- **Phases 1-4** (the new module only): `git revert` the phase commit, or delete
  `Limits/FiniteCarrier.lean`. Nothing else imports it until Phase 5, so the library stays green
  with no other edit.
- **Phase 5** is an atomic batch and must be reverted as one commit: reverting the import without
  reverting the regenerated `FormalSystem.lean` fails C33.
- **Phase 6** is prose in one file; revert the commit.
- **Phases 7-8** must be rolled back **together or in reverse order** (8 then 7): an uncommented
  inventory row whose C2 pin has been reverted fails C36a as unpinned. Reverting 7 alone leaves
  the tree red.
- **Phase 9** is ledger rows plus regenerated inventory blocks; revert the commit and re-run
  `--emit-inventory` to confirm the blocks are current again.

Full abandonment leaves the tree exactly as it is today: the refutation family stays sorry-free in
the probe, `check-evidence-probes.sh` keeps it compiling as a `WIRED_REPO` entry, and the four
inventory rows stay commented and reserved. Nothing in the library depends on this landing, so
there is no partial state that breaks an existing result.
