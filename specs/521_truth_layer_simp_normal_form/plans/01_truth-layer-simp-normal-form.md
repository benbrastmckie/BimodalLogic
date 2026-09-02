# Implementation Plan: Truth Layer Simp Normal Form

- **Task**: 521 - Truth layer simp normal form
- **Status**: [IMPLEMENTING]
- **Effort**: 13.5 hours
- **Dependencies**: Task 517 (landed), Task 518 (landed, verified), Task 519 (landed)
- **Research Inputs**: specs/521_truth_layer_simp_normal_form/reports/01_truth-layer-simp-normal-form.md
- **Artifacts**: plans/01_truth-layer-simp-normal-form.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/Semantics/Truth.lean` gives `TruthAt` no `@[simp]` characterization API, while its
base-language mirror `BLTruth.lean` has had one since it was written. This plan builds that API,
registers the `truth_norm` / `swap_norm` simp sets, and then **rewrites the call sites that the
API makes rewritable**. The call-site rewrite is the work; the attribute is only what enables it.

**The research reframes the task, and this plan is built on the reframing, not on the charter's
surface reading.** The researcher verified by compiling probes (not by asserting) that `@[simp]`
tagging alone buys nothing at any existing site: 199 of the ~209 live sites are `simp only [...]`,
which ignore the attribute entirely, and *adding* the new lemma names to an existing `simp only`
list **without removing** `Formula.and` / `Formula.or` / `Formula.neg` from that list is a no-op —
simp rewrites bottom-up, so the syntax-unfolding lemmas fire on the argument before the
`TruthAt`-headed characterization lemma can match. The researcher reproduced the stranded goal.
Every sweep edit in this plan therefore **deletes** `Formula.and`/`or`/`neg` (and usually
`TruthAt`) from the list it touches. A phase that only adds attributes and declares victory
produces zero measurable movement.

Definition of done: the `Truth.*_iff` normal form exists and is documented in `Truth.lean`'s
module docstring; `truth_norm`/`swap_norm`/`truth_simp` are registered; the duplicate helpers are
consolidated to zero copies **within the file scope**; the eleven named soundness proofs are
rewritten against the API; `lake build` green; `check-module-invariants.sh` ALL PASS; C2 baseline
unchanged; the restated reduction criterion (below) is met and recorded with before/after counts.

### Research Integration

Findings carried into this plan, all research-verified:

- **The whole proposed lemma set compiles** (`lean_run_code` against the oleans at `2bd4dfba2`),
  is confluent, and terminates. Twelve alternative spellings were each shown to converge on the
  same normal form under bare `simp`. This evidence is the safety argument for Phase 3.
- **Only ONE `always` form may carry `@[simp]`** (orchestrator decision 2). Registering both was
  reproduced as verified-broken: simp applies whichever was declared first and silently strands
  every proof written against the other. The **collected `∀ s` form** is the normal form; the
  three-conjunct form exists as plain, untagged `always_iff_tri`.
- **`untl_iff` / `snce_iff` are required** and are not in the charter. Without them nothing
  reduces a raw `Formula.untl` / `snce` head once `TruthAt`'s equations are no longer reached by
  an explicit `simp only [TruthAt]`.
- **`strong_release_iff` / `strong_trigger_iff` keep their attribute** (orchestrator decision 3).
  Once `untl_iff` is `@[simp]` they are the only lemmas reducing a `strongRelease` head, and that
  operator appears 87 times. Zero uses today is evidence they were unreachable, not unwanted.
- **Blast radius is small**: 48 bare `simp`/`simp_all`/`aesop` lines across all files that mention
  `TruthAt` at all, none of the eight scoped files carrying more than 2. This is what lets the
  attribute phase land early and keeps the rest independently buildable.
- **A-17 holds**: `truthAt_atomFree_history_indep` and `truthAt_gap_shift` were both proven, and
  three of the five uniformity proofs (17, 17, 9 lines) collapse to a single term each.
- **The 50% length target is demonstrated**: `linear_until_valid` compiles at 15 tactic lines
  against 30 (51% of the whole declaration).
- **`Soundness.lean` line numbers are NOT stale** despite task 519's rewrite. `linear_until_valid`
  :715, `linear_since_valid` :752, the comment at :779 are exact; drift elsewhere is ≤5 lines.
  Only the `DenseValidity.lean:302` validation anchor is void (that file was deleted); the
  researcher re-established the equivalent claim live at `Soundness.lean:723`.

Charter corrections carried in:

| Charter says | Truth | Consequence for this plan |
|---|---|---|
| four `truth_and_iff` copies | **three** + one *variant* | `Decidable.lean:1408` is `truthAt_and`, an introduction lemma, not a biconditional. It is also out of scope (decision 1). Do not plan to delete it. |
| `Formula.neg` in 144 simp lists | **270** | Sweep scope is larger than charted; this plan does not attempt the sweep. |
| nine `swap_temporal_*` lemmas | **eleven** (4 already `@[simp]`) | `swap_norm` is additive for the other seven. |
| `strong_*_iff`: drop or delete | keep, with attribute | Decision 3. |
| 279 live `simp only [...TruthAt...]` | **199** | 519 deleted `DenseValidity.lean` + `Core.lean`. |

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no `specs/ROADMAP.md` was consulted.

## The restated acceptance criterion (orchestrator decision 1)

The charter's "`simp only [...TruthAt...]` sites in the touched files down by at least 80%" is
**unreachable under the charted file scope**, and the user chose to keep the scope rather than
widen it. The research mapped the distribution: the eleven named declarations hold 14 of
`Soundness.lean`'s 67 sites, and the two largest reservoirs — `FrameClassVariants.lean` (37) and
`Decidable.lean` (27) — are outside the file scope entirely. The gate is therefore restated as
two honest, checkable measurements:

**(A) Relative, within the rewritten declarations.** `simp only [...TruthAt...]` occurrences
inside the eleven named soundness declarations fall by ≥80%: **baseline 14 → target ≤2**.

**(B) Absolute, per touched file, measured before and after.** Recorded as a table in the
implementation summary. Binding target: `Soundness.lean` **67 → ≤50**; `CoValidity.lean`
**1 → 0**.

**`Semantics/Truth.lean`'s own count is expected to RISE** (baseline 19, expect ~25) and this is
correct, not a regression: those sites *are* the characterization proofs — you cannot prove
`and_iff` without unfolding `TruthAt` — and each new lemma adds one. Report the rise; do not
suppress it. `BLTruth.lean`'s 5 sites are irreducible for the same reason and are not touched.

**Not in scope, and stated rather than silently left:** `FrameClassVariants.lean` (37 sites) and
`Decidable.lean` (27 sites) are untouched. The mechanical sweep across them is a separate task's
charter. Consequently **one `and_of_not_imp_not` copy survives**, at
`Decidability/Verified/Decidable.lean:2570` (spelled `and_of_not_imp_not'`, 3 call sites), and
`Decidable.truthAt_and` (:1408) survives. The zero-copies criterion below is scoped to the eight
files, not the tree.

## Goals & Non-Goals

**Goals**:
- A complete, confluent, terminating `@[simp]` characterization API for `TruthAt` in the `Truth`
  namespace, with the chosen normal form stated in `Truth.lean`'s module docstring.
- `register_simp_attr truth_norm` and `swap_norm`, plus the `truth_simp` macro, available at every
  soundness-layer use site.
- Zero private copies of `truth_and_iff` and `and_of_not_imp_not` **within the eight scoped
  files**, each deletion landing with its call sites converted in the same phase.
- The eleven named soundness proofs rewritten against the API, each at most half its current
  length.
- A-17's history-independence and gap-shift lemmas, with the uniformity proofs that follow from
  them collapsed.
- `lake build` green at every phase boundary; `check-module-invariants.sh` ALL PASS; C2 baseline
  unchanged.

**Non-Goals**:
- The mechanical sweep of `Soundness.lean`'s remaining ~43 sites, `FrameClassVariants.lean` (37)
  or `Decidable.lean` (27). Separate task.
- Exact `Truth`/`BLTruth` attribute parity. The research shows it is already unachievable and not
  worth chasing; aligning `BLTruth.always_iff` to the collected form is explicitly a nice-to-have,
  not a prerequisite (it has zero uses outside its own file).
- Touching `WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean:77`
  `temporal_truth_and_iff`. It is stated for a *different* truth relation (monadic-signature
  temporal models) and must not be folded in.
- Any edit under `Metalogic/Bundle/`, `Syntax/SubformulaClosure/`, `Theorems/` or `Boneyard/` —
  sibling task 520's concurrent territory.

## Scope deviations (flagged, not assumed)

Three phases touch files outside the eight-file scope. Each is called out at its phase and is a
deliberate, minimal deviation, not scope creep:

| Phase | File outside scope | Edit | Why unavoidable |
|---|---|---|---|
| 1 | `FormalSystem/Automation/TruthNormAttr.lean` (**new file**) | 2 `register_simp_attr` + the `truth_simp` macro | `register_simp_attr` is unusable in its own compilation unit, so the declarations must live in a separate module that `Truth.lean` imports — but that constraint forces "a separate module", not "*that* module". A sibling in `FormalSystem/Automation/` follows the pattern `NormalizationAttr.lean` already established (its own "Why this is a separate module" docstring documents the identical constraint) and honours that file's "It must not acquire any other content" instruction instead of amending it. |
| 2 | `FormalSystem/Syntax/Formula.lean` | 1 import + 7 `@[swap_norm]` tags | The eleven `swap_temporal_*` lemmas live there (`:681-758`); tagging in the declaring file is what guarantees set membership at every use site. |
| 5 | `Semantics/Validity.lean`, `Correspondence/FwdRec.lean`, `Correspondence/FwdRecBridge.lean` | move `validOn_iff_total`, update 3 references | Charter step (3) explicitly asks for this move; source and destination are both outside the eight files by construction. |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| The `@[simp]` batch reddens files outside the scope | H | M | Phase 3 is alone in its own phase, `Commit Mode: atomic-batch`, `Verification Tier: full`. The 48 bare-`simp` lines are the pre-computed audit list; regenerate it before tagging and check every hit after. |
| An `always_iff` regression re-introduces the non-confluent pair | H | L | Only the collected form is tagged. `always_iff_tri` must be introduced *untagged* and the phase-3 checklist re-greps for a second `@[simp]` on an `always` LHS. |
| Adding lemma names to the widely-opened `Truth` namespace causes downstream ambiguity | M | L | Phase 2 is `interface` tier; close it on a full `lake build`, not on a single-module check. |
| `CoValidity.lean` breaks silently | M | **H** | `FormalSystem.Metalogic.SoundnessLemmas.CoValidity` is in `scripts/module-invariants-manifest.txt` as a known-unreachable module: **plain `lake build` never compiles it.** Any phase touching it MUST additionally run `check-module-invariants.sh` (or `lake env lean` on the module) before claiming green. Phases 4 and 10 carry this. |
| Sweep edits add the new names without removing `Formula.and`/`or`/`neg` | H | M | Verified no-op (§3.5 of the report). Every rewrite phase's checklist states the deletion explicitly, and the reduction metric (A) will not move if it is skipped. |
| `swap_norm` tagging forces a `Syntax → Automation` import edge | M | L | `TruthNormAttr.lean` imports only `Lean` (same as `NormalizationAttr.lean`), so no cycle is possible. Confirm with `check-module-invariants.sh` (C4) in the same phase. Fallback: tag the swap lemmas from a module that already imports both `TruthNormAttr` and `Syntax/Formula.lean` — `Semantics/Truth.lean` after Phase 2 qualifies — and confirm that tagging module is transitively reachable from every use site, since simp-set membership is an environment extension. |
| The new module is judged unreachable by C6 | L | L | `TruthNormAttr.lean` is imported by `Truth.lean` and `Syntax/Formula.lean` in Phase 2, both deeply reachable from the Lake roots, so it enters the build graph and must **not** be added to `scripts/module-invariants-manifest.txt`. Phase 2's verification confirms this. Between Phase 1 and Phase 2 the module has no importer; if C6 objects at the Phase 1 boundary, land the Phase 2 imports rather than manifesting it. |
| The `truth_simp` macro fails to elaborate in its declaring module | L | M | The macro body is syntax, resolved at expansion, so co-locating it with `register_simp_attr` should work. If it errors with `Unknown identifier truth_norm`, move the macro alone into `Truth.lean` (which imports `TruthNormAttr` from Phase 2) and record the move. |
| `discrete_symm_fwd/bwd` need a dual `truthAt_cogap` the researcher did not prove | M | M | Phase 7 budgets it. If it does not land inside the phase, leave those two proofs unchanged and record a `#### Reasoned Exclusions` entry — they are not among the eleven named proofs and metric (A) does not depend on them. |
| Concurrent task 520 conflicts | L | L | 520's territory (`Metalogic/Bundle/`, `Metalogic/Core/RestrictedMCS/`, `Syntax.lean`, `Syntax/SubformulaClosure/`) is disjoint. Note `Syntax.lean` ≠ `Syntax/Formula.lean`; the Phase 2 deviation does not collide. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 7 | 3 |
| 5 | 6, 8 | 4, 7 |
| 6 | 9 | 8 |
| 7 | 10 | 4, 5, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel. Same-wave pairs were chosen to be
**file-disjoint**: wave 4's Phase 4 touches DurationFrames/Dedekind/CoNotPriorU/CoValidity while
Phase 7 touches Truth.lean/Soundness.lean; wave 5's Phase 6 touches
DurationFrames/CoNotPriorU/DiscreteNonCompactness while Phase 8 touches Soundness.lean only.
Phases 8 and 9 both edit `Soundness.lean` and are therefore deliberately sequential.

---

### Phase 1: Baseline capture and simp-set registration [COMPLETED]

- **Goal:** Freeze the "before" measurement that the restated acceptance criterion is scored
  against, and declare the two named simp sets plus the `truth_simp` macro. Purely additive;
  nothing can break.
- **Tasks:**
  - [ ] Record the pre-edit baseline to `specs/521_truth_layer_simp_normal_form/baseline.txt`:
        per-file `grep -c "simp only \[[^]]*TruthAt"` for all eight scoped files; the same count
        restricted to the eleven named declarations; the 48-line bare-simp audit list
        (`grep -rnE "(^|[[:space:]])(simp|simp_all|aesop)([[:space:]]|$|\[)"` over every live file
        that mentions `TruthAt`); the current line count of each of the eleven named declarations.
  - [ ] Create `FormalSystem/Automation/TruthNormAttr.lean` — a new sibling of
        `NormalizationAttr.lean`, with the standard copyright header, `import Lean` and nothing
        else. Its module docstring states the same compilation-unit constraint
        `NormalizationAttr.lean` documents (`register_simp_attr` expands to an `initialize` block;
        neither the attribute nor the simp-set identifier is usable in the module that declares
        it), records that this is a *second* declaration module rather than an extension of the
        first, and carries the same "attribute and simp-set declarations only" invariant.
  - [ ] In it, add `register_simp_attr truth_norm` (docstring: the `TruthAt` equations plus every
        `Truth.*` characterization lemma) and `register_simp_attr swap_norm` (the eleven
        `Formula.swap_temporal_*` lemmas).
  - [ ] Add `macro "truth_simp" loc?:(location)? : tactic => `(tactic| simp only [truth_norm] $(loc?)?)`
        in the same module. If it fails to elaborate there, move the macro alone to `Truth.lean`
        in Phase 2 and record the move (see Risks). *(deviation: altered — the bare `(location)?`
        parser category is not in scope under `import Lean` alone; the macro was written as
        `loc?:(Lean.Parser.Tactic.location)?` and elaborates in its declaring module. No move
        was needed.)*
  - [ ] **Do not modify `NormalizationAttr.lean`.** The research recommended amending its
        "It must not acquire any other content." sentence to host these two sets; the user's scope
        decision supersedes that recommendation. A separate module honours the instruction as
        written and needs no amendment.
  - [ ] Do **not** add the new module to `scripts/module-invariants-manifest.txt`. It gains
        importers in Phase 2 and is reachable thereafter; C6 fails on an entry naming a reachable
        module.
- **Timing:** 0.75 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** The baseline figures asserted in this plan (Soundness.lean 67 sites;
  14 sites and 366 lines across the eleven named declarations; CoValidity.lean 1; Truth.lean 19;
  BLTruth.lean 5; the other four scoped files 0; 199 live sites tree-wide) are hypotheses measured
  at plan time. Confirm each by re-running the greps above and write the confirmed values into
  `baseline.txt`. If any differs, the confirmed value supersedes and metric (A)'s ≤2 target is
  recomputed as `ceil(0.2 * confirmed baseline)`.
- **Files to modify:**
  - `FormalSystem/Automation/TruthNormAttr.lean` — **new file**: two `register_simp_attr` and the
    `truth_simp` macro (**outside the eight-file scope — flagged deviation**)
  - `specs/521_truth_layer_simp_normal_form/baseline.txt` — new
  - Not modified: `FormalSystem/Automation/NormalizationAttr.lean`
- **Verification:**
  - `lake build` green.
  - `baseline.txt` exists and its numbers are reproducible by the commands it records.

---

### Phase 2: The untagged `Truth` API and the named-set tags [COMPLETED]

- **Goal:** Add every new characterization lemma to the `Truth` namespace **without `@[simp]`**,
  tag them into `truth_norm`, tag the swap lemmas into `swap_norm`, and state the chosen normal
  form in the module docstring. Purely additive: no attribute in this phase reaches the default
  simp set, so no existing proof can change behaviour.
- **Tasks:**
  - [ ] Add `import FormalSystem.Automation.TruthNormAttr` to `FormalSystem/Semantics/Truth.lean`.
  - [ ] In `namespace Truth` (`Truth.lean:177-343`), add, all **untagged** for now:

        | Lemma | Normal form (RHS) | Proof shape (verified by the researcher) |
        |---|---|---|
        | `neg_iff` | `¬ TruthAt M τ t φ` | `Iff.rfl` |
        | `top_true` | `True` | `id` |
        | `and_iff` | `A ∧ B` | `simp only [Formula.and, Formula.neg, TruthAt]; tauto` |
        | `or_iff` | `A ∨ B` | same shape |
        | `diamond_iff` | `∃ σ, σ.IsTotal ∧ TruthAt M σ t φ` | classical `¬∀¬` step |
        | `untl_iff` | the `untl` clause | `Iff.rfl` |
        | `snce_iff` | the `snce` clause | `Iff.rfl` |
        | `always_iff` | `∀ s, TruthAt M τ s φ` | via `always_iff_tri` + `lt_trichotomy` |
        | `kPlus_iff` | `∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TruthAt M τ r φ` | `push Not` |
        | `kMinus_iff` | `∀ s, s < t → ∃ r, s < r ∧ r < t ∧ TruthAt M τ r φ` | `push Not` |

  - [ ] Add `always_iff_tri` (the three-conjunct form `BLTruth` uses) as a plain lemma. It is the
        introduction form and the proof route to `always_iff`. **It must never be tagged `@[simp]`**
        — see decision 2.
  - [ ] Use `push Not`, not `push_neg`, to match `BLTruth`'s house style and avoid the deprecation
        warning the researcher observed.
  - [ ] Tag every lemma in the table plus `bot_false`, `imp_iff`, `box_iff`, `future_iff`,
        `past_iff`, `some_future_iff`, `some_past_iff`, `strong_release_iff`, `strong_trigger_iff`
        and the `TruthAt` equations with `@[truth_norm]`.
  - [ ] In `FormalSystem/Syntax/Formula.lean`, add `import FormalSystem.Automation.TruthNormAttr`
        and tag the seven not-already-`@[simp]` `swap_temporal_*` lemmas (`involution` :681,
        `diamond` :703, `neg` :713, `next` :742, `prev` :747, `strong_release` :752,
        `strong_trigger` :758) with `@[swap_norm]`; also add `@[swap_norm]` to the four already
        carrying `@[simp]` (`some_future` :719, `some_past` :725, `all_future` :731,
        `all_past` :737) so the set is complete at eleven.
  - [ ] Extend `Truth.lean`'s module docstring with a "Simp-normal form" section reproducing the
        table above, naming the collected `∀ s` `always` form as the normal form and
        `always_iff_tri` as the untagged introduction form, and recording *why* only one may carry
        the attribute.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Verification Tier:** interface
- **Files to modify:**
  - `FormalSystem/Semantics/Truth.lean` — import, ~10 new lemmas + `always_iff_tri`,
    `@[truth_norm]` tags, module docstring
  - `FormalSystem/Syntax/Formula.lean` — import + 11 `@[swap_norm]` tags
    (**outside the eight-file scope — flagged deviation**)
- **Verification:**
  - `lake build` green. Because names enter a widely-opened namespace, close on a **full** build,
    not a single-module check.
  - `check-module-invariants.sh` C4 passes (confirms the new `Syntax → Automation` import edge
    resolves and introduces no cycle).
  - `grep -n "@\[simp\]" FormalSystem/Semantics/Truth.lean` shows **no new** `@[simp]` — this
    phase adds none.
  - A scratch `example` confirms `simp only [truth_norm]` and `truth_simp` both resolve at a
    `Soundness.lean` position. If `truth_norm` is not in scope there, the tagging module is not
    transitively reachable — resolve before Phase 3.

---

### Phase 3: Register the `@[simp]` attributes [NOT STARTED]

- **Goal:** The one globally disruptive change, isolated. Move the normal form into the default
  simp set and repair anything it reddens.
- **Tasks:**
  - [ ] Regenerate the bare-`simp` audit list from `baseline.txt` (48 lines across all files
        mentioning `TruthAt`; concentrations `Verified/Decidable.lean` 17, `BiLasso/Extraction.lean`
        8, `CountermodelExtraction.lean` 4; **no scoped file has more than 2**). This is the
        complete set of sites the attribute can reach.
  - [ ] Add `attribute [simp] bot_false imp_iff box_iff` (or move the tags onto the declarations)
        and `@[simp]` to `neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff`, `untl_iff`,
        `snce_iff`, `always_iff` (collected form **only**), `kPlus_iff`, `kMinus_iff`.
  - [ ] **Keep** `strong_release_iff` / `strong_trigger_iff` tagged (decision 3). Verify they still
        compose: `TruthAt (strongRelease φ ψ)` must reduce, with `and_iff` firing on the nested
        conjunction, to `∃ s, t < s ∧ (TruthAt M τ s ψ ∧ TruthAt M τ s φ) ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ`.
  - [ ] Re-run the confluence probes as `example`s in a scratch file before committing: the raw
        `imp φ bot` / `neg φ` convergence; the double-negation spelling of `and`; the
        `neg (someFuture (neg φ))` / `allFuture φ` convergence and its past dual; `untl top φ` vs
        `someFuture φ`; `bot.imp bot` → `True`; `untl bot (bot.imp bot)`; and the nesting
        termination case `always (always (and φ ψ))`. Delete the scratch file before the commit.
  - [ ] Walk the audit list and repair every reddened site by *fixing forward* (adding the
        now-needed `simp only`/`rw` step), never by removing an attribute.
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Verification Tier:** full
- **Commit Mode:** atomic-batch — the tag set is one pre-declared objective; intermediate
  per-lemma states are expected red and must not be committed.
- **Scope Hypothesis:** "48 bare `simp`/`simp_all`/`aesop` lines, none of the eight scoped files
  carrying more than 2." Confirm by regenerating the list from `baseline.txt`'s recorded command
  before tagging, and by diffing the post-tag `lake build` failure set against it. A build failure
  at a site **not** on the list means the blast-radius model is wrong — stop and re-measure rather
  than patching through.
- **Files to modify:**
  - `FormalSystem/Semantics/Truth.lean` — attribute additions only
  - any file on the audit list that the change reddens (repair in place)
- **Verification:**
  - `lake build` green.
  - `grep -c "@\[simp\]" ` on the `always` lemmas confirms exactly **one** tagged `always` form.
  - `check-module-invariants.sh` ALL PASS; C2 axiom baseline unchanged.

---

### Phase 4: Consolidate the duplicate truth helpers [NOT STARTED]

- **Goal:** Delete the three private `truth_and_iff` copies and the two `always` helpers,
  converting every call site in the same phase. `and_of_not_imp_not` is deliberately **not** in
  this phase — its call sites live inside proofs Phases 8-9 rewrite, so it is deleted in Phase 10.
- **Tasks:**
  - [ ] `Semantics/Correspondence/DurationFrames.lean:298` — delete `truth_and_iff`; convert its
        six call sites (:312, :314, :321, :323, :432, :454) to `Truth.and_iff`.
  - [ ] `Metalogic/DedekindNonCompactness.lean:158` — delete `truth_and_iff'` **and the :155
        docstring that justifies the duplication**; convert :173 and :176 to `Truth.and_iff`.
  - [ ] `Metalogic/Independence/CoNotPriorU.lean:180` — delete `truth_and_iff`; convert :246.
  - [ ] `Semantics/Correspondence/DurationFrames.lean:309,318` — delete `truth_always_of_forall`
        and `truth_of_always`; convert :526 and :556 to `(Truth.always_iff _).mpr` /
        `(Truth.always_iff _).mp _ u`. The hand-rolled trichotomy inside `truth_of_always` is what
        decision 2's collected form exists to remove.
  - [ ] `Metalogic/SoundnessLemmas/CoValidity.lean:72` — delete `always_elim`; convert :108 to
        `(Truth.always_iff _).mp h_tri`; update the file docstring's bullet at :47.
  - [ ] Do **not** touch `ExteriorBracket.lean:77` `temporal_truth_and_iff` (different truth
        relation) or `Decidable.lean:1408` `truthAt_and` (out of scope, and not a biconditional).
- **Timing:** 1.5 hours
- **Depends on:** 3
- **Verification Tier:** interface
- **Scope Hypothesis:** "Three `truth_and_iff` copies with 6 + 2 + 1 call sites; two DurationFrames
  `always` helpers with 2 call sites; `CoValidity.always_elim` with 1." Confirm with
  `grep -rn "truth_and_iff\|truth_always_of_forall\|truth_of_always\|always_elim" FormalSystem/ --include=*.lean | grep -v Boneyard`
  before deleting. A call site outside the enumerated set means the count is wrong — convert it or
  record why not.
- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
  - `FormalSystem/Metalogic/DedekindNonCompactness.lean`
  - `FormalSystem/Metalogic/Independence/CoNotPriorU.lean`
  - `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`
- **Verification:**
  - `lake build` green **AND** `check-module-invariants.sh` ALL PASS — `lake build` alone does not
    compile `CoValidity.lean` (it is a manifested known-unreachable module), so a break there is
    silent without C6.
  - `grep -rn "truth_and_iff" FormalSystem/ --include=*.lean | grep -v Boneyard` returns only the
    `ExteriorBracket.lean` `temporal_truth_and_iff` lines.

---

### Phase 5: Move `validOn_iff_total` to `Semantics/Validity.lean` [COMPLETED]

- **Goal:** Charter step (3)'s relocation (finding C-17). Fully independent of Phases 1-4 and 6-9.
- **Tasks:**
  - [ ] Move `validOn_iff_total` from `Semantics/Correspondence/FwdRec.lean:75` to
        `Semantics/Validity.lean`, beside `TaskFrame.ValidOn`, renamed `TaskFrame.validOn_iff_total`.
  - [ ] Update the internal use at `FwdRec.lean:96` and the doc bullet at `FwdRec.lean:41`.
  - [x] Update the one external caller, `Correspondence/FwdRecBridge.lean:158`. *(deviation:
        altered — the lemma now lives inside `namespace TaskFrame`, so all three references are
        spelled `TaskFrame.validOn_iff_total`, not the bare name.)*
  - [x] Confirm `FwdRec.lean` still needs its remaining imports; drop any that only served the
        moved lemma. *(deviation: skipped the drop — `FwdRec.lean` has exactly one import,
        `Correspondence.Galois`, still required by the rest of the file.)*
- **Timing:** 0.75 hours
- **Depends on:** none
- **Verification Tier:** interface
- **Files to modify:**
  - `FormalSystem/Semantics/Validity.lean` (**outside the eight-file scope — flagged deviation**)
  - `FormalSystem/Semantics/Correspondence/FwdRec.lean` (**outside scope — flagged**)
  - `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean` (**outside scope — flagged**)
- **Verification:**
  - `lake build` green.
  - `grep -rn "validOn_iff_total" FormalSystem/ --include=*.lean` shows the declaration only in
    `Validity.lean` and exactly three references.

---

### Phase 6: Atom-truth lemmas and the `rw [show … from rfl]` idiom [NOT STARTED]

- **Goal:** Charter step (4) / finding C-05. Tag the four frame-constant atom-truth lemmas
  `@[simp]` and add `τ.val`-normalised forms so the eight-site `rw [show τ.val = … from rfl, …]`
  idiom collapses to `simp`.
- **Tasks:**
  - [ ] Tag `@[simp]`: `DurationFrames.translationModel_atom` (:196),
        `DurationFrames.permissiveModel_atom` (:287), `CoNotPriorU.clock_atom_truth` (:120),
        `DiscreteNonCompactness.zTruth_atom` (:171).
  - [ ] Add the `τ.val`-normalised companion forms (stated directly about
        `(translationHist D : WorldHistory _)` / `permissiveHist D so nm f` rather than requiring
        the `show … from rfl` coercion step).
  - [ ] Convert the eight sites in `DurationFrames.lean` at :385, :394, :436, :438, :451, :503,
        :505, :534 to `simp`.
  - [ ] Check the `clock_atom_truth` sites (`CoNotPriorU.lean` :226, :239, :272, :277, :290) and
        `zTruth_atom` sites (`DiscreteNonCompactness.lean` :206, :216) for the same collapse; where
        the `@[simp]` tag alone already closes the step, delete the explicit `rw`.
- **Timing:** 1.25 hours
- **Depends on:** 4
- **Verification Tier:** full — this adds four lemmas to the **default** simp set, so its reach is
  global, exactly as Phase 3's.
- **Scope Hypothesis:** "Exactly 8 `rw [show τ.val = … from rfl, …]` sites in `DurationFrames.lean`
  at 385-534." Confirm with `grep -n "from rfl" FormalSystem/Semantics/Correspondence/DurationFrames.lean`
  before editing; the charter's stated range (409-531) is stale and the count, not the range, is
  the anchor.
- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
  - `FormalSystem/Metalogic/Independence/CoNotPriorU.lean`
  - `FormalSystem/Metalogic/DiscreteNonCompactness.lean`
- **Verification:**
  - `lake build` green; `check-module-invariants.sh` ALL PASS.
  - `grep -c "from rfl" FormalSystem/Semantics/Correspondence/DurationFrames.lean` drops from 8
    toward 0; any survivor is justified in the commit message.

---

### Phase 7: A-17 — history-independence and gap shift [NOT STARTED]

- **Goal:** Charter step (5). Add the two A-17 lemmas beside `Truth.box_const` and collapse the
  uniformity block that currently re-derives them by hand five times.
- **Tasks:**
  - [ ] Add beside `Truth.box_const` (`Truth.lean:733`), in the second `namespace Truth` block:
        - `truthAt_atomFree_history_indep (M) (φ) (hφ : φ.atoms = ∅) : ∀ τ σ t, TruthAt M τ t φ ↔ TruthAt M σ t φ`
          — by induction on `Formula`, splitting `hφ` with `Finset.union_eq_empty`; the `box` case
          is `rfl` (the clause does not mention `τ`); temporal cases via `exists_congr` /
          `and_congr` / `forall_congr'`.
        - `truthAt_gap : TruthAt M τ t (Formula.untl .bot (.bot.imp .bot)) ↔ ∃ s, t < s ∧ ∀ r, t < r → r < s → False`
          — the intermediate whose RHS mentions neither `M` nor `τ`. This is the whole content of
          the uniformity block.
        - `truthAt_gap_shift` — moves a gap witness by translation (`sub_sub_cancel`,
          `add_sub_sub_cancel`).
  - [ ] Rewrite the three verified one-liners in `Soundness.lean` (block 825-910):
        - `discrete_box_necessity_valid` (:902, 9 lines) → `fun σ _ => (truthAt_atomFree_history_indep M _ rfl τ σ t).mp h`
        - `discrete_propagate_fwd_valid` (:863, 17 lines) → `(Truth.future_iff _).mpr fun u _ => truthAt_gap_shift M τ t u h`
        - `discrete_propagate_bwd_valid` (:882, 17 lines) → `(Truth.past_iff _).mpr fun u _ => truthAt_gap_shift M τ t u h`
  - [ ] Attempt the dual `truthAt_cogap` plus its symmetry lemma and rewrite
        `discrete_symm_fwd_valid` (:825) and `discrete_symm_bwd_valid` (:844). The researcher did
        not prove these but reports the argument is the mirror image with no visible obstruction
        (marked `[reasoned]`, not verified).
  - [ ] If the dual does not land inside this phase's budget, leave those two proofs unchanged,
        mark the phase `[COMPLETED WITH EXCLUSIONS]` and add a `#### Reasoned Exclusions` table
        naming both, the reason, and the compile evidence. They are outside the eleven named
        declarations and metric (A) does not depend on them.
- **Timing:** 2.0 hours
- **Depends on:** 3
- **Verification Tier:** interface
- **Scope Hypothesis:** "Five uniformity proofs at `Soundness.lean` 825-910, of lengths 17, 17, 17,
  17 and 9, holding 5 `simp only [...TruthAt...]` sites." Confirm by re-reading the block before
  editing; the research's stated range 825-912 is one line long.
- **Files to modify:**
  - `FormalSystem/Semantics/Truth.lean` — three new lemmas near `:733`
  - `FormalSystem/Metalogic/Soundness.lean` — the uniformity block only
- **Verification:**
  - `lake build` green; C2 baseline unchanged.
  - The three named proofs are each a single term.

---

### Phase 8: Rewrite the seven smaller named soundness proofs [NOT STARTED]

- **Goal:** The first half of charter step (6). Rewrite against the new API, using the researcher's
  compiled `linear_until_valid` as the pattern.
- **Tasks:**
  - [ ] Rewrite, in `Soundness.lean`: `temp_l_valid` (:297, 25 lines, 2 sites),
        `temp_linearity_valid` (:347, 38 lines, 1), `discreteness_forward_valid` (:473, 21, 1),
        `enrichment_until_valid` (:605, 20, 1), `enrichment_since_valid` (:625, 22, 1),
        `absorb_until_valid` (:668, 20, 1), `absorb_since_valid` (:690, 22, 1).
  - [ ] **In every rewritten `simp only` list, DELETE `Formula.and`, `Formula.or`, `Formula.neg`
        and (where the characterization lemmas cover it) `TruthAt`, replacing them with the
        `Truth.*_iff` names.** Adding without deleting is a verified no-op — the syntax lemmas
        unfold the argument bottom-up before the characterization lemma can match.
  - [ ] Remove the `by_contra` / `exfalso; apply h_neg` scaffolds these proofs use to route around
        the missing `and_iff`, and the explanatory proof comments those scaffolds needed (e.g. the
        `-- Goal: (((D1→F)→D2)→F) → D3` comment at :779 becomes noise once the goal is a
        conjunction). `temp_l_valid` and `discreteness_forward_valid` use `and_of_not_imp_not` at
        :310, :313, :482, :484 — convert those uses to `(Truth.and_iff _ _).mp`, but leave the
        private helper itself in place; Phase 10 deletes it once every caller is gone.
  - [ ] Each rewritten declaration must end at **at most half** its recorded baseline length.
- **Timing:** 1.5 hours
- **Depends on:** 3, 7
- **Verification Tier:** local — proof bodies only; no signature, name or arity changes. Iterate
  with `lake env lean FormalSystem/Metalogic/Soundness.lean`; close the phase on a full
  `lake build`.
- **Scope Hypothesis:** "Seven declarations, 168 lines, 8 `simp only [...TruthAt...]` sites."
  Confirm against `baseline.txt`; re-measure both after the rewrite and record the deltas.
- **Files to modify:**
  - `FormalSystem/Metalogic/Soundness.lean`
- **Verification:**
  - `lake build` green; C2 baseline unchanged.
  - Each of the seven is ≤50% of its baseline length; the 8 sites reduce to ≤1.

---

### Phase 9: Rewrite the four large named soundness proofs [NOT STARTED]

- **Goal:** The second half of charter step (6) — the four proofs the review named worst.
- **Tasks:**
  - [ ] Rewrite `linear_until_valid` (:715, 36 lines, 1 site). The researcher's version **compiles**
        at 15 tactic lines against 30; lift it from report §4.2 rather than re-deriving. Its
        `simp only` line becomes exactly
        `simp only [Truth.and_iff, Truth.or_iff, Truth.untl_iff, Truth.imp_iff]` and the three
        trichotomy branches become three `exact .inl (.inr ⟨…⟩)`-style terms. This rewrite is also
        the live re-establishment of the void `DenseValidity.lean:302` anchor: it replaces the
        `simp only [Formula.and, Formula.or, Formula.neg, TruthAt]` at `Soundness.lean:723`.
  - [ ] Rewrite `linear_since_valid` (:752, 41 lines, 1 site) — the mirror image; expect the same
        shape and the same reduction.
  - [ ] Rewrite `prior_U_gap_valid` (:1010, 50 lines, 2 sites) and `prior_S_gap_valid` (:1060,
        71 lines, 2 sites). Convert their `and_of_not_imp_not` uses at :1016 and :1066 to
        `(Truth.and_iff _ _).mp`; leave the helper for Phase 10.
  - [ ] Same deletion rule as Phase 8: `Formula.and`/`or`/`neg` come **out** of every list touched.
- **Timing:** 1.5 hours
- **Depends on:** 8
- **Verification Tier:** local — proof bodies only. Same iterate/close split as Phase 8.
- **Scope Hypothesis:** "Four declarations, 198 lines, 6 `simp only [...TruthAt...]` sites; the
  researcher's `linear_until_valid` rewrite compiles at 15 tactic lines." Confirm against
  `baseline.txt` and by compiling the lifted proof before adapting the other three.
- **Files to modify:**
  - `FormalSystem/Metalogic/Soundness.lean`
- **Verification:**
  - `lake build` green; C2 baseline unchanged.
  - Each of the four is ≤50% of its baseline length; combined with Phase 8, metric (A) reaches
    ≤2 sites across all eleven declarations.

---

### Phase 10: `and_of_not_imp_not` consolidation and final measurement [NOT STARTED]

- **Goal:** Delete the two in-scope `and_of_not_imp_not` copies now that every caller is converted,
  and close the task against the restated acceptance criterion with recorded numbers.
- **Tasks:**
  - [ ] Convert the two remaining `and_of_not_imp_not` callers in `Soundness.lean` that are **not**
        among the eleven named proofs: `sep_valid` (:1131, use at :1140) and `sep_swap_valid`
        (:1198, use at :1207). Each is a local edit: delete `Formula.and`/`Formula.neg` from the
        `simp only` list, add `Truth.and_iff`, replace the helper call with
        `(Truth.and_iff _ _).mp`. These two declarations carry 5 further sites between them; take
        whichever of those the rewrite naturally collapses and leave the rest — they belong to the
        deferred sweep.
  - [ ] Delete `Soundness.lean:153` `private theorem and_of_not_imp_not` and
        `CoValidity.lean:60`'s copy (plus its "the same helper appears in
        `Metalogic/Soundness.lean`" docstring, now false).
  - [ ] Verify `grep -rn "and_of_not_imp_not" FormalSystem/ --include=*.lean | grep -v Boneyard`
        returns **only** the `Decidable.lean:2570` `and_of_not_imp_not'` declaration and its three
        call sites, and **say so in the summary**: that copy survives because `Decidable.lean` is
        out of scope by orchestrator decision 1, not by oversight.
  - [ ] Re-measure everything in `baseline.txt` and write the before/after table into the
        implementation summary: per-file absolute counts for the eight scoped files, the
        within-named-declarations count, and the eleven declaration lengths.
  - [ ] Score both halves of the restated criterion and state plainly whether each is met. Report
        `Truth.lean`'s expected *increase* explicitly rather than omitting it.
- **Timing:** 1.25 hours
- **Depends on:** 4, 5, 6, 7, 8, 9
- **Verification Tier:** full
- **Scope Hypothesis:** "`and_of_not_imp_not` has 8 call sites in `Soundness.lean` (:310, :313,
  :482, :484, :1016, :1066, :1140, :1207) and 2 in `CoValidity.lean` (:79, :80); all but :1140 and
  :1207 are converted by Phases 4, 8 and 9." Confirm by grep immediately before deleting either
  declaration — a surviving caller means an earlier phase left work behind.
- **Files to modify:**
  - `FormalSystem/Metalogic/Soundness.lean`
  - `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`
- **Verification:**
  - `lake build` green **AND** `check-module-invariants.sh` ALL PASS (again: `CoValidity.lean` is
    not compiled by `lake build`).
  - C2 axiom baseline unchanged.
  - Metric (A): ≤2 sites across the eleven named declarations (from 14).
  - Metric (B): `Soundness.lean` ≤50 (from 67); `CoValidity.lean` 0 (from 1).
  - Zero `truth_and_iff` and zero `and_of_not_imp_not` in the eight scoped files.

---

## Testing & Validation

- [ ] `lake build` green at every phase boundary, and after every green sub-step within a phase
      (except Phase 3, which is `atomic-batch`).
- [ ] `bash scripts/check-module-invariants.sh` ALL PASS after Phases 3, 4, 6 and 10. **Mandatory
      after any phase touching `CoValidity.lean`** — that module is in
      `scripts/module-invariants-manifest.txt` as known-unreachable, so `lake build` never compiles
      it and a break there is silent without C6.
- [ ] C2 axiom baseline for the four flagship theorems unchanged throughout. This work is a proof
      refactor; any C2 movement means a proof was rerouted through a different axiom and must be
      investigated, not accepted.
- [ ] Exactly one `@[simp]`-tagged `always` characterization lemma in `Truth.lean`.
- [ ] The confluence probes of Phase 3 all close under bare `simp`.
- [ ] Metric (A): `simp only [...TruthAt...]` inside the eleven named declarations, 14 → ≤2.
- [ ] Metric (B): per-file before/after table recorded; `Soundness.lean` 67 → ≤50;
      `CoValidity.lean` 1 → 0; `Truth.lean`'s increase reported, not suppressed.
- [ ] Each of the eleven named declarations at most half its baseline length.
- [ ] Zero `truth_and_iff` / `and_of_not_imp_not` copies in the eight scoped files; the two
      out-of-scope survivors named explicitly in the summary.
- [ ] No edits under `Metalogic/Bundle/`, `Syntax/SubformulaClosure/`, `Theorems/`, `Boneyard/`,
      `SoundnessLemmas/FrameClassVariants.lean` or `Decidability/Verified/Decidable.lean`.

## Artifacts & Outputs

- `specs/521_truth_layer_simp_normal_form/plans/01_truth-layer-simp-normal-form.md` (this file)
- `specs/521_truth_layer_simp_normal_form/baseline.txt` (Phase 1)
- `specs/521_truth_layer_simp_normal_form/summaries/NN_truth-layer-simp-normal-form-summary.md`
  including the before/after measurement table and the scored acceptance criterion
- Modified: the eight scoped Lean files, plus the four flagged out-of-scope files
  (new `Automation/TruthNormAttr.lean`, `Syntax/Formula.lean`, `Semantics/Validity.lean`,
  `Correspondence/FwdRec.lean`, `Correspondence/FwdRecBridge.lean`)

## Rollback/Contingency

Every phase commits on green, so rollback is `git revert` of the phase's commit(s) in reverse
order. Two ordering facts make partial rollback safe:

- **Phases 1, 2 and 5 are purely additive** and can stand alone indefinitely. Reverting Phase 3
  alone (the attribute registration) returns the tree to "the API exists, nothing uses it by
  default" — a coherent, buildable state.
- **Phases 4, 6, 8, 9 and 10 depend on Phase 3's attributes.** Reverting Phase 3 without reverting
  them will not build. Revert them first.

If Phase 3 reddens sites outside the pre-computed 48-line audit list, do not patch through: the
blast-radius model is wrong, so revert the tag batch, re-measure, and re-plan the tagging. If the
Phase 7 dual lemma proves harder than the researcher's `[reasoned]` estimate, mark the phase
`[COMPLETED WITH EXCLUSIONS]` with the two `discrete_symm_*` proofs recorded rather than blocking —
they are outside the acceptance metric.
