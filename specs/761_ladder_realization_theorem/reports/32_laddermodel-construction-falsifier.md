# Research Report: Task #761

**Task**: 761 - ladder_realization_theorem
**Started**: 2026-11-16T14:49:13-08:00
**Completed**: 2026-11-16T14:55:32-08:00
**Effort**: one research dispatch; one scratch probe compiled against the tree
**Dependencies**: `reports/31_gkwz-ptl-s5-quasimodels.md` (falsifier (4), the target); `reports/29_row-link-route-viability.md` (refutations taken as standing, not re-derived); `reports/30_quasimodel-abstraction-literature.md` (exact/existential split); decision 24 in `.decisions.json`
**Sources/Inputs**: - Codebase (`RaySummary/LadderModel.lean`, `CounterQuotient.lean`, `LadderRealize.lean`, `Realize.lean`, `AnchorLayer.lean`, `RunLayer.lean`, `Certificate.lean`), the wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`, the task record in `specs/state.json`, `grep` over `FormalSystem/`, `Tests/`, `specs/evidence/`, and `lake env lean` on one scratch file outside the repository. No Mathlib search tool and no literature source was needed or used.
**Artifacts**: - specs/761_ladder_realization_theorem/reports/32_laddermodel-construction-falsifier.md
**Standards**: report-format.md, subagent-return.md

**Marking convention.** **[VERIFIED]** = compiled this round or found by a `grep` this round, with the evidence named; **[INFERRED]** = follows from something verified, inference stated; **[UNSOURCED]** = neither. Every declaration name asserted to exist was checked with `grep -rnE '(theorem|lemma|def|abbrev|structure|instance) +<name>\b'` over `FormalSystem/`, `Tests/`, `specs/evidence/` (Ruling 25). Names found absent are stated as absent.

## Executive Summary

- **Verdict: falsifier (4) is NOT WELL-POSED as worded, and FAILS in the only form in which it could rescue the filed equation.** Both halves are established this round, the first by grep, the second by compilation.
- **Step 1 — the construction half over `Dmax` does not exist in the tree.** [VERIFIED by grep] No declaration builds a frame or a model from `Dmax`, from a `certAdmK`-certified set, or from `LadderCons`. The only certificate-to-model construction in `RaySummary/` is `frameOf`/`modelOf` (`Realize.lean:689`, `:725`), which takes a `Cons φ lab step` presentation, is proved only for `box`/`stab`-free `φ` (`presented_modelOf`, `Realize.lean:916`), and has no `K` coordinate. Two further preconditions of a GKWZ-style construction are also absent: `Dmax` is not known to be certified (`dmax_certStabK`, `dmax_certBoxK`, `dmax_certAdmK` do not exist; `CounterQuotient.lean:105-113` says why), and `ladderRealized` itself is declared nowhere.
- **Step 2 — the comparison is nevertheless decidable without inventing a construction, and it is negative.** Whatever the construction half turns out to be, its defining property (report 31, Q5 item 2) is its truth lemma: the cell at a point is the fibre of the set over the point's key `(q, κ)`. Compiled this round: **no model over any frame whose cells are a function of a key in `Q × CK` receives `ladderModel` by a key-respecting, cell-preserving map** (`Probe761F.no_keyed_cell_map`), with the instance at an arbitrary set `R` (`no_construction_receives_ladderModel`) and at `Dmax` (`no_dmax_construction_receives_ladderModel`), at the filed `ParamsOk` tuple (`paramsOk_filed`). [VERIFIED: `lake env lean`, exit 0, axioms `[propext, Classical.choice, Quot.sound]`]
- **The differing coordinate is the cell as a function of the gap `n - c`.** Any construction keyed by `(q, κ)` assigns one cell to all counter pairs of a `κ`-class; `ladderModel` assigns different cells to `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)`, which are one class. The identity instance is compiled too: `ladderModel`'s own cells are the `(q, κ)`-fibres of **no** set `R` at all (`ladderModel_realizes_no_set`).
- **A second, carrier-level coordinate** holds for the one construction idiom the tree has (`ofSlicedStep` over the certificate's own state set): the slice `LadderState Q pend` is infinite and a slice read off a subset of `Q × ClType φ × CK` is finite, so no slice-respecting injection exists (`no_slice_respecting_injection_into_set`). [VERIFIED, compiled] This one is conditional on the carrier choice and is secondary.
- **No re-sizing of the clip below `2 ^ (j + 1)` re-opens the comparison** (`no_keyed_cell_map_below_exponential`, on the tree's `dblC j` family). [VERIFIED, compiled]
- **Recommended approach**: proceed to the re-statement as the read-off / construction pair, with this compiled reason. The construction half is then a NEW model to be written, not `ladderModel`.

## Context & Scope

Decision 24 obliges "a compiled verdict on whether `ladderModel` is isomorphic to the model that the construction direction builds from `Dmax`", with the construction half "identified concretely in the project's own terms before the comparison is attempted, not assumed". This round does exactly those two things, in that order. Read-only: no `.lean` source, plan or record was edited. One scratch file was compiled outside the repository; its appended source is in the Appendix. Report 29's refutations were not re-derived; the wired probe they extend was recompiled only as the import base of this round's seven theorems.

## Findings

### Codebase Patterns

#### F1. Step 1 — what a "construction half over `Dmax`" would need, and what the tree has

The three components the dispatch asks for, each checked:

| Component of a construction from `Dmax` | Declaration in the tree | Status |
|---|---|---|
| Carrier (points carrying the key `(q, κ)` or a member of `Dmax`) | none | **absent** [VERIFIED] |
| Accessibility / step relation on it (`relK` lifted to a frame) | `relK` exists as a relation on `Q × ClType φ × CK` (`CounterQuotient.lean:1177`); no `FrameOver` is built from it | **relation only, no frame** [VERIFIED] |
| Valuation | none | **absent** [VERIFIED] |
| Truth lemma (cell at a point = fibre of the set over its key) | none | **absent** [VERIFIED] |

Evidence, all by grep this round:

- **Every `FrameOver`/`TaskModel` definition in `RaySummary/`** [VERIFIED: `grep -rnE '^(noncomputable )?(def|abbrev)' -A4 … | grep -E 'TaskModel|FrameOver'`]: `ofSlicedStepFinBranch` (`RunLayer.lean`, signature ending at l.171, the generic constructor), `ladderFrame` (`RunLayer.lean:528`), `ladderFrameAdm` (`LadderModel.lean:194`), `ladderModel` (`LadderModel.lean:225`), `frameOf` (`Realize.lean:689`), `modelOf` (`Realize.lean:725`). None takes `Dmax`, `certAdmK`, `relK` or `LadderCons` as input.
- **Every occurrence of `Dmax` outside `CounterQuotient.lean`** [VERIFIED: `grep -rnE '\bDmax\b'`] is a docstring, the definition of `LadderCons` (`LadderRealize.lean:249-252`), or a probe. No occurrence is the argument of a frame or model constructor.
- **`ladderRealized` is not declared.** [VERIFIED] The only hit is a quoted statement inside a docstring of `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean:19`.
- **`Dmax` is not known to be certified.** [VERIFIED] `dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK`, `dmax_certBwdK` exist (`CounterQuotient.lean:1267-1303`); `dmax_certStabK`, `dmax_certBoxK`, `dmax_certAdmK` return no hit. `CounterQuotient.lean:105-113` states the reason: conditions (5) and (6) are equalities between a letter's bit and a fibre of the candidate set, so they are not preserved by the union that defines `Dmax`. GKWZ's construction (Lemma 5.24 ⇐, as read in report 31) takes a set satisfying (qm1) as input; the project's `Dmax` has not been shown to be one. [INFERRED for the consequence: a GKWZ-style construction has no licensed input here yet]
- **`real_subset_dmax`, `real_certAdmK_of_paramsOk` do not exist** [VERIFIED: no hit]; `LadderRealize.lean` names both in docstrings as not claimed.

**Where the `Cons` machinery lives.** The dispatch's orientation says `Realize.lean` does not exist at `FormalSystem/Metalogic/Decidability/Realize.lean`. That is correct for that path; the module is `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (1004 lines). [VERIFIED] `Cons` is at `:573`, `cons_localRun` at `:643`, `frameOf` at `:689`, `modelOf` at `:725`, `presented_modelOf` at `:916`, `hitCl_modelOf_eq_hitOf` at `:992`.

**Why `frameOf`/`modelOf` is not the construction half over `Dmax`.** It is the only certificate-to-model construction in the tree, so it is the natural candidate, and it does not fit on four counts:
1. Its input is a `Cons φ lab step` bundle over a `[Fintype Q]` presentation, with universal no-deferral liveness fields `ulive`/`slive` (`Realize.lean:593`). `certAdmK` has existential discharge (`certFwdK`/`certBwdK`) instead. `LadderCons`'s docstring records the mismatch: "No liveness field of `Realize.lean`'s `Cons` survives as such" (`LadderRealize.lean:246-248`). [VERIFIED for both texts; INFERRED that `Cons` is not derivable from `certAdmK` — not compiled]
2. `presented_modelOf` carries `hφ : φ.BoxStabFree`. [VERIFIED] The filed equation is for all `φ`, `⊡`/`□` included.
3. Its slice is the finite presentation, and the task record cites `Probe747.modelOf_incomplete` (`specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean:131`) as the reason the ladder frame was chosen instead: `modelOf` on any `Cons` presentation validates a non-valid formula because `ofSlicedStep` on a `Fintype` has finite width. [VERIFIED that the theorem exists and that the task record says this; not recompiled]
4. It has no `K` coordinate and nothing relates its states to `kappa`.

**Result of Step 1.** The construction half over `Dmax` **does not exist in the tree**, in any of its four components, and one of its preconditions (`certAdmK` of `Dmax`) is open. Falsifier (4) as worded — "the model the construction half builds from `Dmax`" — therefore has no second relatum. That is the first half of the verdict.

#### F2. Step 2 — the comparison that can still be made, and its compiled answer

The negative result of Step 1 does not leave the question open, because the purpose of falsifier (4) fixes what any admissible construction half must satisfy, and that is enough to decide the comparison for every candidate at once.

**What the construction half must satisfy** [INFERRED from report 31, Q5 item 2, which is SOURCED there to Lemma 5.24 ⇐]: "From a certified set build a model whose points carry the certificate's key, so that the cell equation is the truth lemma plus (qm3)." Over `Dmax ⊆ Q × ClType φ × CK` the key of a point is forced by the carrier type: it is `(q, κ) ∈ Q × CK`. So a construction half is a model `M'` over some frame, with a key map `key : WorldState → Q × CK`, satisfying

`∀ u, cellAt M' φ u 0 = {T | ∃ S, typeOfCl S = T ∧ ((key u).1, S, (key u).2) ∈ Dmax}`.

**What an isomorphism must do to rescue the filed equation** [INFERRED]: the filed equation equates the cell of `ladderModel` at `(t, ⟨(q, c, n), h⟩)` with the `Dmax`-fibre over `(q, κ (c, n))`. An isomorphism `e` delivers that from the truth lemma above iff it (i) preserves cells and (ii) sends `(t, ⟨(q, c, n), h⟩)` to a point with key `(q, κ (c, n))`. An isomorphism that moved the key would transport a different fibre and prove a different equation. Preservation of cells by a model isomorphism is the standard invariance of truth; it is taken as a hypothesis below, not proved, and no notion of model isomorphism is declared in the tree to prove it against (`grep` for `FrameIso|ModelIso|Bisim` under `FormalSystem/`: no hit). [VERIFIED for the absence]

**Compiled** (scratch probe, Appendix; all at the two-state object `Qc`, the separating formula `thetaC`, and the periodicity fixpoint's own parameters `Tc0, Tn0, P0, B0`, at which `ParamsOk` holds — `paramsOk_filed`): [VERIFIED: `lake env lean`, exit 0, no `sorryAx`]

- `no_keyed_cell_map` — for ANY `F' : FrameOver intOrder`, ANY `M'`, ANY `key`, ANY `G : Qc × CK → Set (Finset PlusFormula)` with `∀ u, cellAt M' thetaC u 0 = G (key u)`: there is no map `e` of ladder world states into `F'.WorldState` with `key (e (0, stC c n)) = (0, kappa (c, n))` and `cellAt M' thetaC (e (0, stC c n)) 0 = cellAt MC thetaC (0, stC c n) 0`. Nothing is assumed of the frame, the carrier, the relation, the valuation, or of `e` beyond those two clauses (not injectivity, not surjectivity, not a homomorphism property).
- `no_construction_receives_ladderModel` — the same with `G` the fibre map of an arbitrary `R : Set (Qc × ClType thetaC × CK …)`.
- `no_dmax_construction_receives_ladderModel` — the same at `R := Dmax stepC pendC labC thetaC Tc0 Tn0 P0 B0`. This is the statement decision 24 names.
- `ladderModel_realizes_no_set` — the identity instance (`M' := ladderModel`, `e := id`): for every `R`, `ladderModel`'s cells are not the `(q, κ)`-fibres of `R`. `ladderModel` is not itself the output of the construction, for `Dmax` or any other set.
- `no_keyed_cell_map_below_exponential (j B Tc Tn P) (hB : B + 1 ≤ 2 ^ (j + 1))` — the first statement at the formula `dblC j` and EVERY threshold pair, modulus and clip `B < 2 ^ (j + 1)`.

All five reduce in one to three lines to theorems the wired probe already holds: `no_fibre_equation_over_kappa` (`ladder-cell-agreement-refutation.lean:2217`) and `gap_clip_below_exponential_refuted` (`:3295`). [VERIFIED] The round's contribution is not a new counterexample; it is the observation, now compiled, that the existing one quantifies over the construction half itself, so the comparison is settled before the construction is written.

**The differing coordinate.** The cell, as a function of the counter gap. `(Tc0 + 3, Tc0)` and `(Tc0 + 3 + (P0 + 1), Tc0)` have the same `kappa` (`kappa_collision_theta`, wired probe) and different cells at `thetaC` (`thetaC_cell_ne`, wired probe `:2160`). [VERIFIED: both names grep-found; recompiled as part of the import base] Any model keyed by `(q, κ)` gives the two images one cell; `ladderModel` gives the two sources different cells. In `kappa`'s terms it is the fifth coordinate (the clipped gap, `clipIdx`, `CounterQuotient.lean:160`).

**Non-vacuity, stated plainly.** The hypothesis `htruth` at `Dmax` might be unsatisfiable by every model — whether some model realizes the fibres of `Dmax` is exactly the unwritten construction half, and nothing this round decides it. That does not weaken the verdict: if no such model exists, falsifier (4) has no relatum; if one exists, the theorem says `ladderModel` is not it. The identity instance `ladderModel_realizes_no_set` has no such hypothesis and is unconditional.

#### F3. The carrier coordinate (secondary, conditional on the carrier choice)

The tree's one construction idiom takes the slice to be the certificate's own state set (`frameOf`: `FrameOver.ofSlicedStep` at `W := Q`, world states `ℤ × Q`). Read at a certified subset of `Q × ClType φ × CK`, that slice is finite. Compiled: [VERIFIED]

- `ladderState_not_finite` — `¬ Finite (LadderState Q pend)` for every nonempty `Q` (the tree's `Rlad_slice_infinite`, `RunLayer.lean:328`, is the statement one level down, on `Q × ℕ × ℕ`).
- `no_slice_respecting_injection` — for any finite `S`, no injection `ℤ × LadderState Q pend → ℤ × S` sends a time slice into a time slice.
- `no_slice_respecting_injection_into_set` — the instance at `S := ↥R` for any `R : Set (Q × ClType φ × CK Tc Tn P B)`, `[Finite Q]`; `Dmax` included.

Limits of this coordinate [INFERRED]: a bare bijection `ℤ × LadderState ≃ ℤ × S` exists (both carriers are countably infinite), so the time-slice clause is doing the work; and GKWZ's own carrier is `W × R` with `R` a set of RUNS, which is not finite. A runs-based construction would not be separated by cardinality. F2's coordinate is the robust one; F3 only says the `frameOf` idiom cannot be the construction half that matches `ladderModel`.

### External Resources

None consulted. Reports 30 and 31 are the literature record; this round deliberately does not appeal to them for the verdict. The one use made of report 31 is its sourced description of what the construction direction PROVES (truth lemma keyed by the quasistate), which fixes the hypothesis `htruth`; the refutation itself is compiled.

### Recommendations

1. **Record falsifier (4) as failed-with-a-compiled-reason and proceed to the re-statement** as the read-off / construction pair. The reason on record should be: "any model satisfying the construction direction's truth lemma over a `(q, κ)`-keyed set is not cell-and-key-isomorphic to `ladderModel` at the filed `ParamsOk`; `ladderModel` realizes the fibres of no set over `(q, κ)`", citing `no_dmax_construction_receives_ladderModel` and `ladderModel_realizes_no_set`. [VERIFIED: PASS -- scratch probe compiled with `lake env lean` from the repository root against the built tree, exit 0, `#print axioms` on all seven theorems gives `[propext, Classical.choice, Quot.sound]`. NOT run: `scripts/check-evidence-probes.sh`, which needs the file inside `specs/evidence/`; out of scope for a read-only round.]
2. **Wire the Appendix as an evidence probe** by appending its `Probe761F` namespace to `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` (which already holds every lemma it cites) and changing that probe's import from `RaySummary.LadderAgree` to `RaySummary.LadderRealize` (needed for `typeOfCl`, `LadderRealize.lean:202`; the probe compiled with that single import, so everything it used from `LadderAgree` is reached transitively). [VERIFIED: PASS -- the scratch file is exactly that wired form (the probe at commit `d57d016e8` with the one import line changed and the namespace appended) and compiles, exit 0. NOT run: `check-evidence-probes.sh` on the in-tree form.]
3. **In the re-statement, name the construction half as a new model, and state its carrier before anything else.** F3 shows the `frameOf` idiom (slice = certified set) gives a finite-width model, which the task record already excludes via `modelOf_incomplete`; a runs-based or ladder-shaped carrier is required, and "the model built from the certificate" is then not `ladderModel` unless proved so. This is the obligation Step 1 found unmet. [No compiled gate applicable]
4. **Carry `certAdmK` of the input set as an explicit hypothesis of the construction half; do not state it over `Dmax` until `certStabK`/`certBoxK` of `Dmax` are proved.** They are open (`CounterQuotient.lean:105-113`) and the union argument does not give them. [No compiled gate applicable]
5. **Do not re-pose falsifier (4) at a re-sized clip unless the clip is at least exponential in the backward depth.** [VERIFIED: PASS -- `no_keyed_cell_map_below_exponential` compiled; every clip `B < 2 ^ (j + 1)` fails at `dblC j`.] Whether an exponential clip survives is the open question report 29 (rank 4) already records; nothing here bears on it.

## Decisions

- Treated "the construction half does not exist" as the Step 1 result and did not define a model over `Dmax` to compare against.
- Decided the comparison by quantifying over every model satisfying the construction's truth lemma, rather than over one invented construction; the hypotheses `hkey` and `hcell` are what an isomorphism must supply for the rescue, and are stated as hypotheses, not derived from an isomorphism notion the tree does not have.
- Did not attempt to prove that a model isomorphism preserves `cellAt`; marked INFERRED.
- Did not recompile report 29's two scratch probes; they were recompiled independently before this dispatch and are taken as standing.
- Reproduced the appended source in the Appendix rather than writing into `specs/evidence/`.

## Risks & Mitigations

- **The probe is scratch-only and unwired.** `check-evidence-probes.sh` was NOT run on it. Mitigation: the Appendix is the complete appended text; the base file is tracked; wiring is one import line plus an append (Recommendation 2).
- **The verdict's second half depends on the reading of "isomorphic".** It is proved for maps that preserve cells and the `(q, κ)` key. An isomorphism that permutes keys is not excluded by F2 — but it would not yield the filed equation either, so it cannot rescue it. Stated in the verdict.
- **F2 is at one object and one formula** (plus the `dblC j` family). That suffices to refute a universally quantified rescue; it says nothing about objects or formulas on which `κ` happens to be complete.
- **"`Cons` is not derivable from `certAdmK`"** is inferred from the two docstrings and the liveness-shape mismatch, not compiled. Nothing in the verdict depends on it.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `False` from a keyed truth lemma plus a key/cell-preserving map | `apply no_fibre_equation_over_kappa; refine ⟨fun κ => G (0, κ), fun c n => ?_⟩; rw [← hcell c n, htruth, hkey]` | success | wired probe's `no_fibre_equation_over_kappa` |
| the same at `dblC j`, any clip below `2 ^ (j + 1)` | `obtain … := gap_clip_below_exponential_refuted …; apply hne; rw [← hcell c n, ← hcell c n', htruth, htruth, hkey, hkey, hk]` | success | N/A |
| `¬ Finite (LadderState Q pend)` | `Finite.of_injective` on `n ↦ ⟨(q, 0, n), fun _ => rfl⟩`, then `not_finite ℕ` | success | `not_finite ℕ (h := …)` fails: the instance argument is not named `h`; use `haveI` |
| `Finite ↥R` for `R : Set (Q × ClType φ × CK …)`, `[Finite Q]` | instance resolution | success | no hint needed |

## Context Extension Recommendations

- **Topic**: deciding a "is model A isomorphic to the output of construction C" question when C is unwritten.
- **Gap**: nothing in the Lean context says that such a question can be settled by quantifying over every model satisfying C's specification (its truth lemma), which avoids inventing C and avoids needing an isomorphism notion.
- **Recommendation**: a short pattern note under the logic or lean4 context (edited at its source store, not in the deployed tree): "compare against the specification, not an implementation; state what the isomorphism must transport as hypotheses".

## Verdict

**Does falsifier (4) hold, fail, or is it not yet well-posed?**

- **As worded: not yet well-posed.** "The model the construction half builds from `Dmax`" names no object in the tree: no carrier, no frame, no valuation, no truth lemma, and `Dmax` is not known to be a certified set. [VERIFIED by grep]
- **In the form that would rescue the filed equation: it FAILS.** For every model satisfying the construction direction's truth lemma over a `(q, κ)`-keyed set — `Dmax` or any other — there is no cell-preserving, key-respecting map from `ladderModel` into it, at the filed `ParamsOk`. [VERIFIED, compiled] **Differing coordinate: the cell as a function of the counter gap `n - c`** (`kappa`'s clipped-gap coordinate): one cell per `κ`-class in any such construction, two different cells at `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` in `ladderModel`.
- The filed equation is therefore not "supported by construction". It stays unsupported by the literature (report 31) and is refuted at the filed parameters (wired probe; restated this round against every right-hand set).

**What would overturn this verdict.**
1. The scratch probe failing to compile when wired — re-run it; it uses only the wired probe's own lemmas and library declarations.
2. A showing that the intended construction half is NOT keyed by `(q, κ)` — e.g. a certificate re-keyed by quasistates or by a finer, non-`CK` coordinate. Then `htruth` is the wrong specification and F2 does not apply; but that is the re-statement, not a rescue of the filed equation, whose right-hand side is keyed by `κ (c, n)`.
3. A re-parametrised `κ` with a clip at least `2 ^ (dBack φ + 1)` on which cells are proved constant on classes. F2's `thetaC` instance is at the filed `(K4)`; `no_keyed_cell_map_below_exponential` closes everything below exponential and nothing above it. At such a clip falsifier (4) could be re-posed — and would still need the construction half written first.
4. A showing that `ParamsOk` at `Tcof/Tnof/Pof/Bof` is not "the filed parameter conditions". `paramsOk_params` (`CounterQuotient.lean:938`) is the tree's own non-vacuity witness for `ParamsOk`, so this would be a finding about the library, not about this probe.

## Appendix

### Method

- Greps (all over `FormalSystem/`, `Tests/`, `specs/evidence/`, `--include=*.lean`): `\bDmax\b`; `dmax_`; frame/model definitions in `RaySummary/`; the absent-name list `dmax_certStabK|dmax_certBoxK|dmax_certAdmK|ladderRealized|real_subset_dmax|real_certAdmK_of_paramsOk|dmax_subset_real`; the present-name list `no_fibre_equation_over_kappa|cellAt_const_of_kappa_eq_schema_refuted|dblC_cell_ne|gap_clip_below_exponential_refuted|thetaC_cell_ne|paramsOk_params|typeOfCl|cellAt_eq_cellAt|stab_state_only|Rlad_slice_infinite|ParamsOk|Cons|cons_localRun|presented_modelOf|frameOf|modelOf|modelOf_incomplete`; `FrameIso|ModelIso|TaskModelIso|Bisim`.
- Compile: `lake env lean <scratch>/falsifier4_probe.lean` from the repository root, about 20 s, exit 0, no `error`, no `sorry`.
- Scratch file = `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` at commit `d57d016e8` (sha256 prefix `0ea071d1655ba4c1`), with line 68 changed from `import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` to `import FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize`, and the text below appended. Scratch location (not durable): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d795962e-60ab-47a6-9397-2d3f4a621ce2/scratchpad/falsifier4_probe.lean`.
- `scripts/check-evidence-probes.sh` was NOT run on the probe (scratch-only, unwired).

### Axiom output

```
'Probe761F.no_keyed_cell_map' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.no_construction_receives_ladderModel' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.no_dmax_construction_receives_ladderModel' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.ladderModel_realizes_no_set' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.no_keyed_cell_map_below_exponential' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection_into_set' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Appended source (complete)

```lean
namespace Probe761F

open Probe761C

/-- The periodicity fixpoint's own four parameter outputs at the separating formula: the tuple
`paramsOk_params` certifies `ParamsOk` at. -/
noncomputable abbrev Tc0 : ℕ := Tcof stepC pendC labC thetaC
noncomputable abbrev Tn0 : ℕ := Tnof stepC pendC labC thetaC
noncomputable abbrev P0 : ℕ := Pof stepC pendC labC thetaC
noncomputable abbrev B0 : ℕ := Bof stepC pendC labC thetaC

/-- The parameter tuple is the filed one: `ParamsOk` holds at it. -/
theorem paramsOk_filed : ParamsOk stepC pendC labC thetaC Tc0 Tn0 P0 B0 :=
  paramsOk_params stepC pendC labC thetaC

/-- **NO KEYED MODEL RECEIVES `ladderModel`.** Let `M'` be ANY model over ANY frame whose cells
at `thetaC` are a function `G` of a key in `Q × CK` (the truth lemma of a construction keyed by
object state and counter class). Then no map `e` of ladder world states into `M'` both respects
the key `(q, kappa (c, n))` and preserves cells. Nothing is assumed of the frame, the carrier,
the relation, the valuation or `G`. -/
theorem no_keyed_cell_map
    (F' : FrameOver intOrder) (M' : TaskModel F'.toTaskFrame)
    (key : F'.WorldState → Qc × CK Tc0 Tn0 P0 B0)
    (G : Qc × CK Tc0 Tn0 P0 B0 → Set (Finset PlusFormula))
    (htruth : ∀ u, cellAt M' thetaC u 0 = G (key u))
    (e : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState → F'.WorldState)
    (hkey : ∀ c n : ℕ, key (e (0, stC c n)) = ((0 : Qc), kappa Tc0 Tn0 P0 B0 (c, n)))
    (hcell : ∀ c n : ℕ, cellAt M' thetaC (e (0, stC c n)) 0
      = cellAt MC thetaC ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    False := by
  apply no_fibre_equation_over_kappa
  refine ⟨fun κ => G ((0 : Qc), κ), fun c n => ?_⟩
  rw [← hcell c n, htruth, hkey]

/-- **THE CONSTRUCTION-HALF INSTANCE, FOR EVERY CANDIDATE SET.** If a model `M'` satisfies the
construction direction's truth lemma for a set `R ⊆ Q × ClType φ × CK` — the cell at a point is
the fibre of `R` over the point's key — then `ladderModel` admits no key-respecting,
cell-preserving map into it. `R` is arbitrary: certified or not, `Dmax` or not. -/
theorem no_construction_receives_ladderModel
    (R : Set (Qc × ClType thetaC × CK Tc0 Tn0 P0 B0))
    (F' : FrameOver intOrder) (M' : TaskModel F'.toTaskFrame)
    (key : F'.WorldState → Qc × CK Tc0 Tn0 P0 B0)
    (htruth : ∀ u, cellAt M' thetaC u 0
      = {T | ∃ S : ClType thetaC, typeOfCl S = T ∧ ((key u).1, S, (key u).2) ∈ R})
    (e : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState → F'.WorldState)
    (hkey : ∀ c n : ℕ, key (e (0, stC c n)) = ((0 : Qc), kappa Tc0 Tn0 P0 B0 (c, n)))
    (hcell : ∀ c n : ℕ, cellAt M' thetaC (e (0, stC c n)) 0
      = cellAt MC thetaC ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    False :=
  no_keyed_cell_map F' M' key
    (fun k => {T | ∃ S : ClType thetaC, typeOfCl S = T ∧ (k.1, S, k.2) ∈ R})
    htruth e hkey hcell

/-- **AT `Dmax`.** The instance decision 24 names: no model realizing the fibres of the maximum
certified subset receives `ladderModel` by a key-respecting, cell-preserving map, at the filed
parameter conditions (`paramsOk_filed`). -/
theorem no_dmax_construction_receives_ladderModel
    (F' : FrameOver intOrder) (M' : TaskModel F'.toTaskFrame)
    (key : F'.WorldState → Qc × CK Tc0 Tn0 P0 B0)
    (htruth : ∀ u, cellAt M' thetaC u 0
      = {T | ∃ S : ClType thetaC, typeOfCl S = T ∧
          ((key u).1, S, (key u).2) ∈ Dmax stepC pendC labC thetaC Tc0 Tn0 P0 B0})
    (e : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState → F'.WorldState)
    (hkey : ∀ c n : ℕ, key (e (0, stC c n)) = ((0 : Qc), kappa Tc0 Tn0 P0 B0 (c, n)))
    (hcell : ∀ c n : ℕ, cellAt M' thetaC (e (0, stC c n)) 0
      = cellAt MC thetaC ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    False :=
  no_construction_receives_ladderModel _ F' M' key htruth e hkey hcell

/-- **`ladderModel` IS NOT ITSELF THE CONSTRUCTION, FOR ANY SET.** The identity instance: the
ladder model's own cells are the fibres of NO set `R` over `(q, kappa (c, n))` — in particular
not of `Dmax`. This is the filed fibre equation's instance at this object, refuted for every
right-hand set at once. -/
theorem ladderModel_realizes_no_set (R : Set (Qc × ClType thetaC × CK Tc0 Tn0 P0 B0)) :
    ¬ ∀ c n : ℕ,
      cellAt MC thetaC ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
        = {T | ∃ S : ClType thetaC, typeOfCl S = T ∧
            ((0 : Qc), S, kappa Tc0 Tn0 P0 B0 (c, n)) ∈ R} := by
  intro h
  apply no_fibre_equation_over_kappa
  exact ⟨fun κ => {T | ∃ S : ClType thetaC, typeOfCl S = T ∧ ((0 : Qc), S, κ) ∈ R}, h⟩

/-- **THE SAME AT EVERY SUB-EXPONENTIAL CLIP.** At every threshold pair, every modulus and every
gap clip `B < 2 ^ (j + 1)`, no model whose cells at `dblC j` are a function of a key in
`Q × CK` receives `ladderModel` by a key-respecting, cell-preserving map. So no re-sizing of the
clip below `2 ^ (j + 1)` re-opens the comparison. -/
theorem no_keyed_cell_map_below_exponential (j B Tc Tn P : ℕ) (hB : B + 1 ≤ 2 ^ (j + 1))
    (F' : FrameOver intOrder) (M' : TaskModel F'.toTaskFrame)
    (key : F'.WorldState → Qc × CK Tc Tn P B)
    (G : Qc × CK Tc Tn P B → Set (Finset PlusFormula))
    (htruth : ∀ u, cellAt M' (dblC j) u 0 = G (key u))
    (e : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState → F'.WorldState)
    (hkey : ∀ c n : ℕ, key (e (0, stC c n)) = ((0 : Qc), kappa Tc Tn P B (c, n)))
    (hcell : ∀ c n : ℕ, cellAt M' (dblC j) (e (0, stC c n)) 0
      = cellAt MC (dblC j)
          ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    False := by
  obtain ⟨c, n, n', -, hk, hne⟩ := gap_clip_below_exponential_refuted j B Tc Tn P hB
  apply hne
  rw [← hcell c n, ← hcell c n', htruth, htruth, hkey, hkey, hk]

/-! ### The carrier coordinate: a slice read off a certified set is finite -/

/-- The admissible ladder slice is infinite, for every nonempty object. -/
theorem ladderState_not_finite {Q : Type} [Nonempty Q] (pend : Q → Bool) :
    ¬ Finite (LadderState Q pend) := by
  intro hfin
  have hinj : Function.Injective
      (fun n : ℕ => (⟨(Classical.arbitrary Q, 0, n), fun _ => rfl⟩ : LadderState Q pend)) := by
    intro a b hab
    have := congrArg (fun x : LadderState Q pend => x.1.2.2) hab
    exact this
  haveI : Finite ℕ := Finite.of_injective _ hinj
  exact not_finite ℕ

/-- **NO SLICE-RESPECTING INJECTION INTO A FINITE-SLICE CARRIER.** For any finite slice `S` — in
particular a certified subset of `Q × ClType φ × CK`, or the state set of a `Cons` presentation —
no injection of the ladder world states `ℤ × LadderState Q pend` into `ℤ × S` sends a time slice
into a time slice. A bare bijection of the two countable carriers exists; what fails is one
compatible with the time coordinate, which any isomorphism of sliced frames must be. -/
theorem no_slice_respecting_injection {Q : Type} [Nonempty Q] (pend : Q → Bool)
    (S : Type) [Finite S] (e : ℤ × LadderState Q pend → ℤ × S)
    (hinj : Function.Injective e)
    (hslice : ∀ w w' : ℤ × LadderState Q pend, w.1 = w'.1 → (e w).1 = (e w').1) : False := by
  apply ladderState_not_finite pend
  refine Finite.of_injective (fun x : LadderState Q pend => (e (0, x)).2) ?_
  intro x y hxy
  have h1 : (e (0, x)).1 = (e (0, y)).1 := hslice _ _ rfl
  have : e (0, x) = e (0, y) := Prod.ext h1 hxy
  exact (Prod.mk.inj (hinj this)).2

/-- The instance at a candidate set: the slice `↥R` of any `R ⊆ Q × ClType φ × CK` is finite for
a finite object, so the previous theorem applies to the sliced frame over `R`, `Dmax` included. -/
theorem no_slice_respecting_injection_into_set {Q : Type} [Finite Q] [Nonempty Q]
    (pend : Q → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) (e : ℤ × LadderState Q pend → ℤ × R)
    (hinj : Function.Injective e)
    (hslice : ∀ w w' : ℤ × LadderState Q pend, w.1 = w'.1 → (e w).1 = (e w').1) : False :=
  no_slice_respecting_injection pend R e hinj hslice

end Probe761F

#print axioms Probe761F.no_keyed_cell_map
#print axioms Probe761F.no_construction_receives_ladderModel
#print axioms Probe761F.no_dmax_construction_receives_ladderModel
#print axioms Probe761F.ladderModel_realizes_no_set
#print axioms Probe761F.no_keyed_cell_map_below_exponential
#print axioms Probe761F.no_slice_respecting_injection
#print axioms Probe761F.no_slice_respecting_injection_into_set
```
