# Research Report: Task #645

**Task**: 645 - Port the translation-product proof device into the library
**Started**: 2026-09-22T06:52:20Z
**Completed**: 2026-09-22T07:40:00Z
**Effort**: ~50 minutes of agent time; three scratch compiles of the source probe against the live oleans, one axiom-profile run, tree survey
**Dependencies**: None (the source artifacts are read as established; task 625 shares `Semantics/Frames/README.md` and must not run concurrently)
**Sources/Inputs**: - `specs/624_translation_product_task_semantics_visibility/probes/01_translation-product-live.lean` (777 lines, the transcription source) and `reports/01_translation-product-visibility.md` (Recommendation 1 fixes the layout) - `specs/624_translation_product_task_semantics_visibility/probes/02_limit-idle-mirror.lean` (the zeroFix mirror, Mathlib-only) - Codebase: `FormalSystem/Semantics/HistoryMorphism.lean`, `HybridLanguage/HybridInvariance.lean`, `HybridLanguage/HybridRecurrence.lean`, `Semantics/Frames/{Standard.lean,README.md}`, `Semantics/Frames.lean`, `Semantics.lean`, `Semantics/README.md`, `Semantics/StateLocalTransfer.lean`, `Metalogic/Independence/{PastedCoarseModels.lean,CoarsenedModels.lean,README.md}`, `Metalogic/Independence.lean`, `lakefile.toml`, `FormalSystem/Init.lean` - Gates: `scripts/check-module-invariants.sh` (header, C9, C14, C15, C23, C26, C28, C29/C30, C33, INV), `scripts/check-metalogic-cycles.sh` and `scripts/measure-refactor-partitions.py` (layer tables), `scripts/warning-budget.py`, `scripts/check-evidence-probes.sh`, `docs/reference/paper-definitions-of-record.md`, `docs/theorem-index.md` - Manuscript `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, consulted only to replace the 624 report's line-number citations with labels and quotable phrases - Git history: the commits for tasks 628 (`HistoryMorphism.lean` landed) and 646 phase 4 (the documentation/pin surface a new module touches) - No web or Mathlib search was needed; every lemma the probe uses is already resolved (it compiles)
**Artifacts**: - `specs/645_port_translation_product_into_library/reports/01_port-translation-product.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The source still compiles, sorry-free and warning-free, against today's tree** with exactly
  two mechanical repairs: the imports `FormalSystem.Semantics.PlusLanguage.PlusValidity` and
  `FormalSystem.Semantics.StarLanguage.StarValidity` moved (language-extension merge) to
  `FormalSystem.PlusLanguage.PlusValidity` and `FormalSystem.StarLanguage.StarValidity`. With
  those two lines changed, and with the probe's `set_option linter.unusedSectionVars false`
  **removed**, `lake env lean` exits 0 with empty output. The port is a transcription, not a
  re-derivation; no proof needs to change.
- **Three probe declarations are already live and must not be re-declared**: `HistMap`,
  `HistMorphism` (with `mapH`, `pullM`) and `TaskFrame.RecurrenceFree` landed in
  `FormalSystem/Semantics/HistoryMorphism.lean` (task 628). The port imports that module, states
  the three `*ValidIn_iff_recurrenceFree` theorems against `TaskFrame.RecurrenceFree` (same
  statement, definitionally), and fills the slot two live docstrings leave open: HistoryMorphism's
  "the intended instance is the projection of a translation product … it lives with the
  translation product, not here" and HybridInvariance's "Not formalized: the class-level
  corollary … the translation product of a frame supplies [the morphism], and it is not part of
  this component."
- **Layering is clean for the single-module design the dispatch fixes**: `PlusTruth`,
  `PlusValidity`, `StarTruth`, `StarValidity` are layer 1, the same as `Semantics/`, and
  `Semantics/StateLocalTransfer.lean` already imports both language directories, so
  `Semantics/Frames/TranslationProduct.lean` importing `StarLanguage.StarValidity` adds no upward
  edge (assertion B of `check-metalogic-cycles.sh`) and no cycle (no language module imports the
  `Semantics` or `Semantics.Frames` aggregators). Splitting the invariances into the language
  directories instead would require new rows in `LANGUAGE_FILE_LAYERS`, whose lookup fails loudly
  on any unlisted file — avoid.
- **Module 2 should be a separate file**, `Metalogic/Independence/TranslationProductCoarse.lean`,
  not an addendum: `PastedCoarseModels.lean` is imported by the whole limit-closure chain
  (`LimitClosureCountermodel`, `PlusIncompleteness`), and an addendum would drag
  `StarLanguage.StarValidity` into that closure and force a `FrameOver D` section into a module
  written over a bare `TaskFrame`.
- **Axiom profiles are exactly the acceptance criterion**: the three `*ValidIn_iff_recurrenceFree`
  theorems, `star_invariance`, `c_refuted_lift`, the frame constructor and `colourClock` are all
  `[propext, Classical.choice, Quot.sound]` (the tree's `pcq`, provenance `TaskFrame.limit_of_shift`);
  `prodRel_saturation` is `[propext, Quot.sound]`. Recommend pinning the three flagship theorems
  under C14 with `docs/theorem-index.md` rows, which is what makes "standard axioms only" a
  durable gate rather than a one-off `lean_verify`.
- **Two docstring hazards the dispatch's wording would otherwise walk into**: (i) the abundant-models
  passage must be cited as `sub:AbsoluteTime` plus its quotable *Abundance* definition — the
  label `app:abundant` is NOT in the C15 pinned record; (ii) the "mirror record" (probe 02) cannot
  be cited by its `specs/624_…` path — C9's regex gates `specs/[0-9]{3}_` paths in `.lean` files,
  and the task directory is gitignored on archival. Copy probe 02 to the tracked, task-independent
  `specs/evidence/` tree (the repository's own convention for probes that outlive their task) and
  cite that path, or cite it in prose only.
- **Recommended approach**: two phases of transcription (Module 1 ≈ 470 lines, Module 2 ≈ 110
  lines), one phase of wiring (aggregators, READMEs, generated inventory, `mk_all`, theorem-index
  rows and C14 pins), one gate phase. A sorry-free path exists trivially — the proofs are compiled
  today — so no decomposition or escalation is needed.

## Context & Scope

The task ports a compiled research probe into the library as two modules. Its shape is fixed by
the dispatch (module paths, the declaration list, the docstring obligation, the constraints and the
acceptance gates) and by the 624 report's Recommendation 1. The research question is therefore
not "how to prove it" but "what has moved under the probe since it was written, and what does the
tree require of a new module that the probe, as a `specs/` file, never had to satisfy." The
answers are: two import paths; three declarations now live elsewhere; the header linter, C9 (no
task-number or `specs/NNN_` citations), C15 (paper anchors), C23/C26 (naming), C28 (warning
budget), C29/C30 (no unscoped `set_option linter.*`), C33 (generated root), INV (generated
inventory blocks), and the documentation surface that every module-adding task since the
publication refactor has touched.

Out of scope, per the dispatch: `HistMap`/`HistMorphism` (already live anyway), the categorical
reading, `Clock`/`clockedFactor`/`clockedFactorMorphism`/`stateClock`/`stateClock_not_joint`,
`histMorphism_invariance` (the `PlusTruthAt` invariance along an arbitrary morphism), any
manuscript edit, and anything about the stability modal beyond state-locality.

## Findings

### Codebase Patterns

**1. Tree drift since the probe was compiled (2026-09-19).** The language-extension merge moved
`Semantics/PlusLanguage/` and `Semantics/StarLanguage/` to top-level `FormalSystem/PlusLanguage/`
and `FormalSystem/StarLanguage/`. Nothing else the probe touches moved: `FrameOver`,
`FrameOver.ofReflective`, `FrameOver.ofReflective_taskRel`, `TaskFrame.limit_of_shift`,
`TaskFrame.saturation_of_finite`, `TaskFrame.Compositional/Serial/Saturation/IsFiber/IsSegment/Fib/Seg/DirectedFamily`,
`TaskFrame.exists_pos_of_nontrivial`, `FrameOver.trivialFrame(_taskRel)`, `WorldHistory.ofTotal`,
`WorldHistory.ext_state`, `TruthAt`, `PlusTruthAt`, `StarTruthAt`, `PlusTruth.allFuture_iff`,
`ValidIn/ValidOnFrames`, `PlusValidIn/PlusValidOnFrames`, `StarValidIn/StarValidOnFrames`,
`FrameClass.Sat`, `CoarseModel`, `CTruthAt`, `SameUnder`, `CoarseModel.PasteClosed`. Evidence:
the scratch copy with only the two import lines changed compiles with exit 0 and no diagnostics
(Appendix A).

**2. What is already live, and where the port plugs in.**

| Probe declaration | Live counterpart | Consequence for the port |
|---|---|---|
| `HistMap`, `HistMorphism`, `HistMap.mapH`, `HistMap.pullM`, `HistMorphism.surj_of_occurs` | `FormalSystem.Semantics.HistMap/HistMorphism/mapH/pullM` in `Semantics/HistoryMorphism.lean` (`surj_of_occurs` is not live) | do not re-declare; import the module |
| `RecurrenceFree` (probe-local) | `FormalSystem.Semantics.TaskFrame.RecurrenceFree`, same statement | state the class theorems with `G.RecurrenceFree`, matching `HybridRecurrence.recF_validOnFrames_recurrenceFree`'s predicate `fun G => fc.Sat G ∧ G.RecurrenceFree` |
| `prodProj : HistMorphism (prodFrame F) F` | not live; `HistoryMorphism.lean`'s docstring says the instance "lives with the translation product" | optional 5-line addition to Module 1 (see Recommendations, decision D3) |
| `histMorphism_invariance` (`PlusTruthAt` along any morphism) | not live for `PlusTruthAt`; `HybridInvariance.regFree_invariance` is the hybrid-embedded analogue | out of scope; the product's `plus_invariance` is transcribed directly, as the probe does |
| `frame_validity_not_reflected`, `p₀` | not live; `trivialFrame_not_recurrenceFree` in `HistoryMorphism.lean` uses the same `trivialFrame`/`Subsingleton Unit`/`exists_pos_of_nontrivial` idiom | port the theorem (the dispatch's docstring obligation names the example; the 624 report's risk table asks for a named theorem); inline the atom as `⟨"p", none⟩` (the tree's convention, e.g. `DiscreteNonCompactness.lean`) rather than a global `p₀` |

**3. Layering.** `scripts/measure-refactor-partitions.py`: `Semantics` = layer 1; per-file rows
give `PlusTruth`, `PlusValidity`, `StarTruth`, `StarValidity` = 1. `check-metalogic-cycles.sh`
assertion B asserts the upward-import set equals a 7-line allowlist; a layer-1 → layer-1 import is
not upward. Precedent: `Semantics/StateLocalTransfer.lean` imports
`PlusLanguage.PlusStateLocal` and `StarLanguage.StarStateLocal`; `Semantics/DeterministicBridge.lean`
imports `PlusLanguage.PlusDeterminism`. Cycle check: no module under `PlusLanguage/` or
`StarLanguage/` imports `FormalSystem.Semantics` or `FormalSystem.Semantics.Frames` (the
aggregators); `Frames.Standard` is imported directly only by `Correspondence/DurationFrames.lean`,
`Correspondence/RigiditySharpness.lean`, `Frames.lean` and `Semantics.lean`. `layer_of` matches
`Semantics/Frames/TranslationProduct` under the `Semantics` row and
`Metalogic/Independence/TranslationProductCoarse` under `Metalogic`; no table edit is needed.

**4. Module conventions the probe does not yet satisfy.**
- Copyright header (`check-copyright-headers.sh`), then imports, then the module docstring as the
  first command (`linter.style.header`, on under `weak.linter.mathlibStandardSet = true`; the
  build gate is `lake build --wfail`). No `import Mathlib`, no `import Lean`. `Standard.lean`
  imports `Mathlib.Tactic.Abel` explicitly; the port uses `abel` and should do the same.
- `set_option linter.unusedSectionVars false` must go: C29/C30 require every `set_option linter.*`
  to be declaration-scoped with a comment naming the linter. It is not needed — the probe compiles
  without it with zero warnings (Appendix A).
- C9: zero task-number citations under `FormalSystem/`. The probe's docstrings carry
  `Probe624`, "probe 559/04", "report 03 §3.2", "report 04 §3.3", "for 618"; every one must be
  rewritten as a durable anchor (declaration name, label, phrase). The regex also matches
  `specs/[0-9]{3}_…` paths.
- C15: every `def:|thm:|lem:|cor:|app:|rmk:` token in a `.lean` docstring must be in the pinned
  record. Resolved today: `def:frame`, `def:world-history`, `def:BL-semantics`,
  `def:BLstar-semantics`, `lem:nullity`, `cor:saturation-finite`, `def:deterministic`,
  `cor:no-characterization`, `thm:extension`, `cor:occurrence`, `app:discrete`. NOT resolved:
  `app:abundant`, `app:unbounded`. `sec:`/`sub:` labels are not gated.
- C23/C26 naming: no `lemma`, no `Uppercase_x`, no non-trailing underscore in `def` names,
  no outer-shadows-inner pair. `liftM` is a root-namespace core declaration (`MonadLiftT` lift);
  rename the model lift. Every other dispatch name is unused in `FormalSystem/` and `Tests/`
  (`prodRel`, `liftH`, `projH`, `clock_eq`, `no_recurrence`, `no_transposition`, `liftK`,
  `colourClock`, `c_invariance`, `truth_invariance`, `plus_invariance`, `star_invariance`,
  `validOn_of_prod`, `translationProduct`: all zero hits).
- C28: a new file with zero warnings needs no `warning-budget.txt` row (the check fails only on a
  count above baseline or a warning class/path pair absent from it).
- C33: the root `FormalSystem.lean` is regenerated with `lake exe mk_all --lib FormalSystem`,
  checked with `--check`.
- INV: `Semantics/Frames/README.md` and `Metalogic/Independence/README.md` carry generated
  inventory blocks; `--emit-inventory` rewrites every column except the trailing hand-written
  description, and also refreshes the `FormalSystem/README.md` aggregator line counts and the
  root `README.md` totals block (the task 628 and 646 diffs show exactly these files moving).

**5. The documentation surface a new module touches** (from the task 628 phase 1 and task 646
phase 4 commits):
- `FormalSystem/Semantics/Frames.lean`: add the import and a `## Modules` bullet.
- `FormalSystem/Semantics/Frames/README.md`: `## Key Definitions` bullet; the generated block's
  description column for the new row (the existing `Standard.lean` row still reads
  `<!-- TODO: add description -->`; fill both while there).
- `FormalSystem/Semantics/README.md` row 31: "`Frames/` | The standard-frame index: `Standard`
  (1 file)" becomes 2 files with a one-line mention of `TranslationProduct`.
- `FormalSystem/Semantics.lean` docstring (around "reaches much of L⁺ and L⋆ transitively, through
  `DeterministicBridge` and `StateLocalTransfer` — the two cross-language bridges"): the product
  is a third cross-language module, reached through the `Frames` aggregator; one clause.
- `FormalSystem/Metalogic/Independence.lean`: add the import and a `## Contents` bullet (its
  opening "Five results are carried here" is already stale against the README's eight; do not
  add a ninth — the device is not an underivability result).
- `FormalSystem/Metalogic/Independence/README.md`: generated-block description for the new row,
  and one sentence under the result-8 paragraph noting that coarse refutations and paste-closure
  transfer to the translation product (the dense-time route the device opens).
- `docs/theorem-index.md`: three rows (`—` label, `pcq pinned:C14`) for the
  `*ValidIn_iff_recurrenceFree` theorems, under "Characterization and definability" or a new
  "The translation product" subsection beside the hybrid/quantifier sections; the C15 second
  assertion then requires each of those three docstrings to carry a `Paper: — (reason)` line, in
  the exact style of `HistoryMorphism.lean`.
- `scripts/check-module-invariants.sh`: the C14 baseline heredoc and the `#print axioms` list
  (four-line additions in the 646 diff; three here).

**6. `specs/evidence/`.** Tracked, task-independent home for probes that outlive their task
(`scripts/check-evidence-probes.sh` header explains why: task directories move to the gitignored
`specs/archive/` on `/todo`). The header's rot-guard wiring is scoped to the bi-lasso layer and
need not be extended; the point is a citable, surviving path. Probe 02 is Mathlib-only, so a copy
there stays compilable independently of the library.

### External Resources

- Manuscript passages, now by label or quotable phrase (never by line): the unfolding remark is
  in `sub:Conclusion` — "the branching tree of states is not posited but may be recovered by
  unfolding the transitions that the task relation permits"; the recurrence/transposition passage
  is in `sec:Construction` — "nothing prevents a world state from occurring at many times in a
  single history" (already the phrase `HistoryMorphism.lean` quotes) and "nothing prevents two
  histories … from passing through the same world states in a different order"; the abundant
  two-dimensional models are `sub:AbsoluteTime`'s *Abundance*: "a two-dimensional model … is
  abundant iff for every `w ∈ W` and `x, y ∈ T`, there is some `w' ∈ W` that is time-shifted from
  `x` to `y`"; the world-state-vs-time stance is `sec:Construction`'s "the same semantic
  primitives included in a task frame generate an abundance of histories". Pinned labels for the
  frame-level facts: `def:frame`, `def:world-history`, `lem:nullity` (the zero loops Limit adds
  nothing beyond), `cor:saturation-finite` (`colourClock`'s Saturation), `def:deterministic`
  (`translationProduct_deterministic_iff`), `def:BL-semantics` (clock-independent valuations),
  `def:BLstar-semantics` (the register clauses are inert).
- Mathlib: `abel`, `sub_add_cancel`, `add_left_cancel`, `lt_trichotomy`, `add_lt_add`,
  `neg_add_cancel`, `add_neg_cancel`, `Set.mem_sInter`, `Prod.ext` — all resolved by the compile.

### Recommendations

**R1. Module 1 — `FormalSystem/Semantics/Frames/TranslationProduct.lean`, namespace
`FormalSystem.Semantics`, imports `Mathlib.Tactic.Abel`, `FormalSystem.StarLanguage.StarValidity`
(transitively `PlusValidity`, `Validity`, `TaskFrame`, `PartialHistory`) and
`FormalSystem.Semantics.HistoryMorphism`.** `Frames.Standard` is NOT needed: the probe imported it
only for `translationFrame`, used by the out-of-scope `stateClock`; the frame-level example uses
`FrameOver.trivialFrame` from `TaskFrame.lean`. Declaration map (probe → port; same proof unless
noted):

| Section | Probe | Port | Note |
|---|---|---|---|
| Bare relation `R : W → ↑D → W → Prop` | `prodRel` | `prodRel` | keep |
| | `prodRel_reflection`, `prodRel_comp`, `prodRel_serial`, `prodRel_limit` | same | keep |
| | `prodRel_const_clock`, `prodRel_fib_image`, `prodRel_seg_image` | same | helpers of `prodRel_saturation`; keep, private is acceptable |
| | `prodRel_saturation`, `saturation_of_prodRel` | same | keep |
| | `colourClock` | `colourClock` | keep (`[Finite W] [Nonempty W]`, no Limit hypothesis) |
| Live frame `F : FrameOver D` | `prodFrame` | `FrameOver.translationProduct` | the dispatch's name; dot-notation `F.translationProduct` |
| | `prodFrame_taskRel` | `FrameOver.translationProduct_taskRel` (`@[simp]`) | |
| | `prodFrame_sat` | `FrameOver.translationProduct_sat` | `cases fc <;> exact Iff.rfl` |
| | `prodFrame_deterministic_iff` | `FrameOver.translationProduct_deterministic_iff` | |
| Histories | `liftH`, `projH`, `liftH_state`, `projH_state`, `projH_liftH`, `clock_eq`, `liftH_projH`, `liftH_through` | same names | `liftH_through` is a helper the `stab` cases and the optional `proj` need |
| | `prod_no_recurrence`, `prod_no_transposition` | `no_recurrence`, `no_transposition` (dispatch names) or `translationProduct_no_recurrence`/`_no_transposition` | see D4 |
| | `prodFrame_recurrenceFree` | `translationProduct_recurrenceFree : F.translationProduct.toTaskFrame.RecurrenceFree` | against the live predicate |
| Invariance | `liftM` | `liftModel` | rename: `liftM` is core's monad lift |
| | `truth_invariance`, `plus_invariance`, `star_invariance` | same | transcribe verbatim |
| | `validOn_of_prod`, `plusValidOn_of_prod`, `starValidOn_of_prod` | same | |
| Class validity | `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree` | same, RHS predicate `fun G => fc.Sat G ∧ G.RecurrenceFree` | the three flagship theorems; `Paper: — (…)` line each; C14 pin |
| | `p₀`, `frame_validity_not_reflected` | `frame_validity_not_reflected`, atom inlined | recommended include (D2) |
| Morphism | `prodProj` | `FrameOver.translationProduct.proj : HistMorphism F.translationProduct F` | optional (D3) |
| Dropped | `Clock`, `prodClock`, `clockedFactor*`, `stateClock*`, `HistMap*`, `HistMorphism*`, `histMorphism_invariance` | — | out of scope / already live |

Estimated size: ~330 lines of declarations plus ~140 lines of docstrings ≈ 470 lines. Under the
1500-line `longFile` limit; no baseline `set_option` needed.

**R2. Module 2 — `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean`, namespace
`FormalSystem.Metalogic.Independence`, imports `FormalSystem.Semantics.Frames.TranslationProduct`
and `FormalSystem.Metalogic.Independence.PastedCoarseModels`; `open FormalSystem.Syntax`,
`FormalSystem.PlusLanguage`, `FormalSystem.Semantics`, `CTruth` as `PastedCoarseModels.lean`
does; `variable {D : TemporalOrder} (F : FrameOver D)`.** Declarations: `liftK`, `c_invariance`,
`pasteClosed_liftK`, `pasteClosed_of_liftK`, `c_refuted_lift`, unchanged. ≈ 110 lines with
docstrings. Rationale for a separate file rather than an addendum: (a) `PastedCoarseModels.lean`
is upstream of `LimitClosureCountermodel.lean` and `PlusIncompleteness.lean`, and an addendum
would put `StarLanguage.StarValidity` into their closure for no benefit; (b) its `variable
{F : TaskFrame}` is a bare frame, while `liftK` needs `FrameOver D`; (c) a separate module gets
its own inventory row and docstring, which is how every other Independence result is filed.

**R3. Module docstring content (Module 1)**, in the order the header linter and the tree's
modules use — title; the standing caveat in the first paragraph ("a proof device showing what
L, L⁺ and L⋆ cannot see of a task frame; never an intended model: a state carrying a clock reading
is not a world state in the manuscript's sense"); the construction as time-unfolding, citing
`sub:Conclusion`'s "recovered by unfolding the transitions that the task relation permits";
`## Main Definitions` / `## Main Results` lists; a `## Frame-level validity is not reflected`
paragraph carrying the example (`p → Gp` valid on the one-state frame, refuted on its product by
`V (u, e) p := e ≤ 0`; the extra valuations are `sub:AbsoluteTime`'s abundant two-dimensional
models, quoted by the *Abundance* clause — never `app:abundant`); a `## What the device does not
settle` paragraph (neutral on Saturation and determinism, silent on the stability modal beyond
state-locality); a `## Limit` note pointing to the mirror record — "Limit's contribution to
validity is nil beyond the zero loops of `lem:nullity`; a Mathlib-only mirror over the plain
history type records this outside the library, since no non-Limit frame type exists in the tree"
— with the path only if probe 02 is copied to `specs/evidence/` (R5); `## Paper correspondence`
in `HistoryMorphism.lean`'s style ("the manuscript defines no product of task frames; the
construction is formalization-native; …"). Every per-declaration docstring that the theorem
index will cite carries `Paper: — (formalization-native; the paper defines no product of task
frames)`. Zero task numbers, zero `specs/NNN_` paths, zero manuscript line numbers.

**R4. Wiring and gates, in one phase**: `Semantics/Frames.lean`, `Metalogic/Independence.lean`
(imports + bullets); `Semantics/Frames/README.md`, `Metalogic/Independence/README.md`,
`Semantics/README.md` row, `Semantics.lean` clause; `lake exe mk_all --lib FormalSystem`;
`bash scripts/check-module-invariants.sh --emit-inventory` (touches the two READMEs,
`FormalSystem/README.md`, root `README.md`); three `docs/theorem-index.md` rows and the matching
C14 baseline + `#print axioms` lines; then `lake exe mk_all --lib FormalSystem --check`,
`bash scripts/check-module-invariants.sh` (full), `bash scripts/check-metalogic-cycles.sh`, and
`lean_verify` on the three theorems. Run `check-module-invariants.sh --no-build` as soon as
Module 1 compiles, before Module 2: it surfaces C9/C15/C23/C26 findings on the docstrings cheaply.

**R5. The mirror record.** Copy `probes/02_limit-idle-mirror.lean` to
`specs/evidence/translation-product/limit-idle-mirror.lean` (tracked, task-independent, Mathlib-only
so it compiles with `lake env lean` regardless of the library) and cite that path from the Module 1
docstring. Do not cite the `specs/624_…` path (C9) and do not rely on the task directory surviving
archival. Optionally copy probe 01 beside it as the transcription source of record; not required.

**R6. Tests.** Not required by the acceptance criteria and not added by task 628 for
`HistoryMorphism.lean`. If the planner wants one, a 30-line
`Tests/BimodalTest/Semantics/TranslationProductTest.lean` instantiating
`FrameOver.translationProduct` at `translationFrame ℤ` and `#check`-ing the three flagship
theorems is the tree's style (`Tests/BimodalTest/Semantics/TaskFrameTest.lean`).

**R7. Phase decomposition** (each phase one agent run, each ends green and committed):
1. Module 1, sections Bare + Frame + Histories (through `translationProduct_recurrenceFree`),
   module docstring complete, scoped build of the module green under `--wfail`.
2. Module 1, invariances + `*ValidOn_of_prod` + the three class theorems +
   `frame_validity_not_reflected` (+ optional `proj`); scoped build green; `--no-build` invariants
   pass on the file's docstrings.
3. Module 2; scoped build green.
4. Wiring (R4, R5), regeneration, theorem-index rows and C14 pins; full `lake build --wfail`;
   full `check-module-invariants.sh`; `check-metalogic-cycles.sh`; `mk_all --check`;
   `lean_verify` on the three theorems.

A sorry-free path exists at every step because the proofs are compiled today; no `[BLOCKED]`
condition is foreseeable short of an unrelated tree breakage.

## Decisions

- **D1. Single Module 1 with all three invariances**, importing `StarLanguage.StarValidity` from
  `Semantics/Frames/` — following the `StateLocalTransfer.lean`/`DeterministicBridge.lean`
  precedent and the layer tables, rather than splitting by language (which would need
  `LANGUAGE_FILE_LAYERS` rows and three files for one device).
- **D2. Port `frame_validity_not_reflected` as a theorem**, with the atom inlined. The dispatch's
  docstring obligation names the example; the 624 report's risk table asks for the named theorem
  so that a later argument cannot transfer frame validity to the product unnoticed.
- **D3. `translationProduct.proj : HistMorphism` is recommended but optional.** It is five lines,
  it is the instance two live docstrings say belongs here, and it lets `regFree_invariance` and
  `lifted_invariance` be instantiated at the product by later work. It is not in the dispatch's
  declaration list; the planner decides. `Clock`/`clockedFactor`/`stateClock` stay out.
- **D4. Names**: keep the dispatch's `no_recurrence`/`no_transposition` unless the planner prefers
  the `translationProduct_` prefix for dot-notation and greppability; either passes C23/C26.
  `liftM` → `liftModel` is not optional.
- **D5. Module 2 is a separate file** (R2), which the dispatch permits.
- **D6. No `user_decision`**: every choice above is settled by the artifacts and the gates.

## Risks & Mitigations

- **Risk**: a docstring keeps a probe-era citation ("report 04 §3.3", "probe 559/04", a
  manuscript line number, `Probe624`). **Mitigation**: C9 fails the gate on task numbers; add a
  grep for `[0-9]{3,4}` inside the two new files' comments to the phase-2 checklist, since line
  numbers are not gated.
- **Risk**: `app:abundant` cited by label. **Mitigation**: C15 fails; cite `sub:AbsoluteTime` and
  the *Abundance* phrase (R3), or add a KNOWN-ANCHORS row if the label is wanted.
- **Risk**: `Semantics/Frames/README.md` is also touched by task 625. **Mitigation**: the dispatch
  already forbids concurrent runs; the planner should have the implementer re-read the README at
  phase 4 rather than apply a stored diff.
- **Risk**: `--emit-inventory` rewrites the root `README.md` totals and `FormalSystem/README.md`
  line counts, which other in-flight tasks also regenerate. **Mitigation**: regenerate last, in
  phase 4, immediately before the gate, and stage only the files the task touched.
- **Risk**: `Classical.choice` in the profile is read as Zorn. **Mitigation**: record in the
  docstring, as `TaskFrame.lean` does, that its provenance is `limit_of_shift`'s `exists_ne`;
  `prodRel_saturation` is `[propext, Quot.sound]`.
- **Risk**: the header linter rejects a `/-! -/` that is not the first command (e.g. a stray
  `set_option` or `namespace` before it). **Mitigation**: copy `Standard.lean`'s header shape
  exactly; no `set_option` at all in either module.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The task is a transcription of proofs that compile
  today; the only automation in the source is `abel` for clock arithmetic, `rintro`/`obtain`
  destructuring, and the `exists_congr`/`and_congr`/`forall_congr'`/`imp_congr` combinators in
  the temporal clauses, all closing on first try. `lean_multi_attempt` and `lean_hammer_premise`
  were not invoked; no goal called for tactic discovery.

## Context Extension Recommendations

- **Topic**: the module-adding checklist (aggregator bullet, README row, generated inventory,
  `mk_all`, theorem-index row + C14 pin, C15 anchor rules, C9/C29/C30 docstring rules).
- **Gap**: `context/project/lean4/` has no single page listing the surfaces a new `FormalSystem`
  module touches; this report re-derived it from two commits.
- **Recommendation**: add `context/project/lean4/patterns/new-module-checklist.md` after the
  port, naming the files and the two scripts, so the next module-adding task does not repeat the
  survey.
- **Topic** (carried over from the 624 report): the translation product and history-lifting
  morphisms as a standing proof pattern ("class validity = validity over recurrence-free/clocked
  members"; the two prohibitions: never an intended model, never frame-by-frame).

## Appendix

### A. Compile evidence (all via `lake env lean` against the repository's own oleans, 2026-09-22)

- `scratchpad/probe01_live.lean` = probe 01 with the two import lines repointed: exit 0, no
  output.
- `scratchpad/probe01_nosupp.lean` = the same minus `set_option linter.unusedSectionVars false`:
  exit 0, no output (zero warnings under the package's `mathlibStandardSet`).
- `scratchpad/probe01_axioms.lean` = the same plus `#print axioms`:
  `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`,
  `star_invariance`, `c_refuted_lift`, `prodFrame`, `colourClock`, `frame_validity_not_reflected`,
  `prod_no_transposition` — `[propext, Classical.choice, Quot.sound]`; `prodRel_saturation` —
  `[propext, Quot.sound]`.
- `#check @liftM` — `{m n : Type _ → Type _} [MonadLiftT m n] {α} : m α → n α` (core), hence the
  rename.

### B. Searches and greps

- Live-tree name collisions: `grep -rwn` for each dispatch name over `FormalSystem/` and `Tests/`
  (zero hits for all, except the three already-live morphism/recurrence names).
- Layering: `grep -rln '^import FormalSystem\.(PlusLanguage|StarLanguage|Metalogic|…)'
  FormalSystem/Semantics` → `DeterministicBridge.lean`, `StateLocalTransfer.lean`; no
  `PlusLanguage`/`StarLanguage` module imports `FormalSystem.Semantics` or
  `FormalSystem.Semantics.Frames`.
- C15 record: `def:frame`(10), `def:world-history`(4), `def:BL-semantics`(5),
  `def:BLstar-semantics`(1), `lem:nullity`(2), `cor:saturation-finite`(1), `def:deterministic`(1),
  `cor:no-characterization`(2), `thm:extension`(4), `cor:occurrence`(2), `app:discrete`(2);
  `app:abundant`(0), `app:unbounded`(0).
- C9 regex (`check-module-invariants.sh`): `\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_[A-Za-z0-9_]+`.
- Manuscript: `grep -n "recovered by unfolding"` → `sub:Conclusion`; `grep -n "occurring at many
  times"` → `sec:Construction`; `\label{sub:AbsoluteTime}` precedes the *Abundance* definition.
- No Mathlib search tool (`leansearch`/`loogle`/`leanfinder`/`state_search`) was needed.
