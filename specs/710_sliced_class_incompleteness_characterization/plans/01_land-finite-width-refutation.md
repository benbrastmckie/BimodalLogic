# Implementation Plan: Task #710

- **Task**: 710 - sliced_class_incompleteness_characterization
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 703 (landed `PlusSlicedCertificate` subtree, incl. `Check.lean`, `Sound.lean`, `EmbedComplete.lean`)
- **Research Inputs**: `specs/710_sliced_class_incompleteness_characterization/reports/01_sliced-class-incompleteness.md`
- **Artifacts**: plans/01_land-finite-width-refutation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: true

## Overview

The research round is complete and succeeded: the time-sliced certificate class is incomplete for
full L⁺ over ℤ-time, and the obstruction is exactly **finite width**. The refutation is already
machine-checked, sorry-free, in `specs/710_.../probes/NoFiniteWidthModel.lean` (1180 lines, five
headline declarations, axioms `[propext, Classical.choice, Quot.sound]`). This plan does one thing:
**land that probe as `FormalSystem/` library theorems**, under the user's 2026-10-03 ruling of
Option A (library landing), together with the docstring scope limits, the `docs/theorem-index.md`
rows, and the two in-library completeness restatements the report's Recommendation 2 asks for.

No mathematics is re-litigated. The proof bodies transfer verbatim from a compiled probe; the real
work is (a) narrowing `import FormalSystem` to a minimal import set, (b) renaming `Probe710` to a
library namespace, (c) removing the probe's task-number references (gate C9 bars them under
`FormalSystem/`), (d) replacing the probe's file-level `set_option linter.unusedSectionVars false`
with the per-declaration `omit [...] in` form (gate C30 bars blanket suppression; C28 lists that
linter class as **blocking**), (e) giving each indexed declaration a `/-- ... Paper: — (reason) -/`
docstring (gate C15's second assertion), and (f) regenerating the three generated surfaces a new
`.lean` file moves.

**Definition of done**: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`
exists, is in the build graph, is sorry-free, carries the five declarations with the verbatim
statements of Deliverable 2; `PlusSlicedCertificate.lean` and `EmbedComplete.lean` no longer call
the `⊡`-carrying case open; `docs/theorem-index.md` carries a row per landed theorem; and the full
gate set is green.

### Research Integration

Findings integrated, not re-derived (report §F1-F7, Decisions D1-D7):

- **F1/F2/F3 are the landed content.** The witness `Φ := (A' ∧ C') ∧ D`, the countable finitely
  branching regular ℤ-frame `F`/`M` with `path_eq_canon`, the combinatorial core `core_false`
  (pre/post classification, `preN_chain`, `val_chain`, `exists_backChain`, pigeonhole
  `exists_long`, the König step `long_step`/`longSeq`), the semantic layer
  (`box_transfer`, `someP_of_A'`, `onceP_of_C'`, `succP_of_D`), and the three corollaries.
- **D2 is a statement constraint, not a style note.** `no_finite_width_sat` must stay quantified
  over *every* model on *every* finite-`W` `ofSlicedStep` frame, with `not_certifies` derived
  through the landed soundness route (`biSerial_of_certifies`,
  `exists_fulfilling_run_at_targetTime`, `lab_eq_canLab`, `mem_canLab_iff_plusTruthAt`) keeping the
  frame rather than exporting through `PlusRefutes`, which forgets it. A refutation of `Certifies`
  alone would not survive a checker change; this one does.
- **F4 is recorded as ARGUED, never proved.** "Complete exactly on targets with a finite-width
  countermodel" — necessity is F2's shape, sufficiency is the Ramsey/periodicity sketch. Phase 8
  lands it as an argued characterisation; no phase of this plan attempts to prove it.
- **F6 settles the literature.** The bundled-trees precedent (Zanardo 1985; Reynolds 2007) was
  never acquired and proved unneeded. The corpus trap stands and is *not* cited anywhere by this
  plan: `reynolds_towards_a_ctl_star_tableau_draft` is an author-hosted draft about FULL CTL*, a
  different paper, and must not be cited for any bundled-versus-full claim.
- **Downstream relays are other tasks' business.** Recommendations 3-6 (re-scoping 709, the 708
  relay wording, the no-fourth-class rule, folding F2/F6 into the 707 context note) are owned by
  those tasks' own revisions. No phase here edits their records or artifacts.

### Prior Plan Reference

No prior plan. This is round 1's plan; `next_artifact_number` is 2, so `artifact_number` 1 is this
round. The only prior artifact is the research report above.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, so no ROADMAP phases are added (the
`roadmap_flag` path is not active). For the record, and consistent with the dispatch: the ruling
this plan executes is `specs/ROADMAP.md` Phase 0's CHECKED item "RULED 2026-10-03 by the user:
Option A — library landing", and the plan advances Phase 2's "Land the finite-width refutation as
library theorems under `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`" together with the
Success Metric "every refutation the programme has produced lives in `FormalSystem/` as a cited
theorem, not only under a task's `probes/`".

## Goals & Non-Goals

**Goals**:

- Land `no_finite_width_sat`, `not_sliced_complete`, `not_finite_width_fmp` and the two
  declarations they depend on — `not_plusValidZTime_neg_Φ` and `not_certifies` — in
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, sorry-free
  and inside the build graph.
- State the hypotheses and the witness **verbatim** as Deliverable 2 fixes them (see
  `### The landed statements, verbatim` below).
- Carry the two scope limits (ℤ/discrete only; `Φ` uses `⊡` so this half is an L⁺ result, not a
  result about base TM) and the README's two further disclaimers (nothing about an infinite
  carrier; nothing about soundness) into the landed docstrings.
- Add a `docs/theorem-index.md` row per landed theorem, **without** any `pinned:C2`/`pinned:C14`
  claim.
- Restate the class's completeness where the library asserts it: `PlusSlicedCertificate.lean`'s
  header and `EmbedComplete.lean`'s "What the flagship does and does not buy".
- Leave the full gate set green, including the generated surfaces a new `.lean` file moves.

**Non-Goals**:

- **Not** editing `scripts/check-module-invariants.sh`. It is task 706's declared `file_scope`, not
  this task's. Consequence: no `pinned:` claim on the new index rows, and no new
  `coverage-limit` row in `scripts/certificate-witness-inventory.txt` (a C36a row must be
  axiom-pinned by C2 or C14, and that pin cannot be written here).
- **Not** editing `scripts/check-evidence-probes.sh`, moving the probe file, or re-pointing
  `FormalSystem/Metalogic/Decidability/FMP/README.md`. That is task 720's scope; the probe stays
  exactly where it is and must keep compiling.
- **Not** proving F4 (finite width ⟹ eventually periodic). It is recorded as argued.
- **Not** building a generic `FrameOver.ofStepFib` constructor. The dispatch is explicit: the frame
  constructor is already in the library (`FrameOver.ofSlicedStep` and its regularity instance in
  `FormalSystem/Semantics/SlicedFrame.lean`; `TaskFrame.saturation_of_fib_finite` and
  `FrameOver.ofReflectiveRegular` for the positive half), so
  `FormalSystem/Semantics/IntNormalForm.lean` is expected to stay untouched despite being in
  `file_scope`. See Contingency C1.
- **Not** re-scoping task 709, rewording task 708's relay, or touching the 707 context note.
- **Not** adding the new declarations to `FormalSystem/MainResults.lean` (C21 would then demand an
  axiom pin this task cannot write), and not citing any task number in any file outside `specs/**`.

## The landed statements, verbatim

Deliverable 2 fixes these; they are reproduced here so the implementer does not re-derive them.
Under `variable {W : Type} (R : ℤ → W → W → Prop)`, `variable [Finite W] [Nonempty W]
(fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)`, and
`variable (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame)`:

```lean
theorem no_finite_width_sat (τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) (t0 : ℤ) :
    ¬ PlusTruthAt M τ t0 Φ

theorem not_sliced_complete :
    ¬ ∀ ψ : PlusFormula, ¬ PlusValidZTime ψ →
        ∃ G : PlusSlicedCertificate [] [ψ], G.Certifies

theorem not_finite_width_fmp :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
        ∃ (W : Type) (_ : Finite W) (_ : Nonempty W) (R : ℤ → W → W → Prop)
          (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
          (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame)
          (τ : WorldHistory (FrameOver.ofSlicedStep R fwd bwd)) (t : ℤ),
          ¬ PlusTruthAt M τ t φ
```

`[Finite W] [Nonempty W]` is the whole finiteness hypothesis. There is **no** hypothesis on the
succession relation beyond the bi-seriality carried by `fwd` and `bwd`. In `not_finite_width_fmp`
the two instances appear as the explicit anonymous binders `(_ : Finite W) (_ : Nonempty W)`.

The witness, which **bears the stability operator `⊡`** (`PlusFormula.stab`):

```lean
def pa : Atom := ⟨"p", none⟩
def p : PlusFormula := PlusFormula.atom pa
def Fp : PlusFormula := PlusFormula.untl PlusFormula.top p   -- ⊤ U p
def Pp : PlusFormula := PlusFormula.snce PlusFormula.top p   -- ⊤ S p
def Xp : PlusFormula := PlusFormula.untl PlusFormula.bot p   -- ⊥ U p, "p at the next time"
def A' : PlusFormula := PlusFormula.box (p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)))
def C' : PlusFormula := PlusFormula.box (p.imp (PlusFormula.stab Pp.neg))
def D  : PlusFormula := -- □(⊡Fp → ¬⊡¬Xp)
  PlusFormula.box ((PlusFormula.stab Fp).imp ((PlusFormula.stab Xp.neg).imp PlusFormula.bot))
def Φ : PlusFormula := (A'.and C').and D
```

`A'` and `C'` together are the "every history meets `p` exactly once" conjunction; `D` says every
pre state has a `p`-successor. Every `⊡` and `□` in `Φ` governs a state formula, which is why `Φ`
lies in the CTL-like fragment.

This section is deliberately **not** titled `## Lean Challenge Statements`: that section is gated
on `task_type` `lean`/`lean4` in plan-format.md and this task's type is `formal:logic`, so emitting
it would invite a snapshot tool to cross-validate a `- **Goals**:` identifier set this plan does
not state in that form.

## The gate constraints that shape the phases

Established by reading the gate scripts, not assumed. Each is a concrete landing obligation:

| Gate | Obligation on this landing |
|---|---|
| C9 (`check-module-invariants.sh`) | **Zero task-number citations under `FormalSystem/`.** The probe's header and several comments say "task 706's θ'", "task 706 §Q3". Every such reference must be re-anchored on a durable anchor — e.g. `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route is refuted, not merely open" section — before the text lands. `C9D` applies the same rule under `docs/`. |
| C15 (second assertion) | Every `docs/theorem-index.md` row's declaration must carry a doc comment **immediately above it** (modulo `@[...]` lines) containing `Paper: — (reason)`, since the Paper-label cell will be `—`. Five rows ⇒ five `/-- ... -/` docstrings. |
| C24 | Every module in the root closure must transitively import `FormalSystem.Init`. |
| C28 + `scripts/warning-budget.txt` | `linter.unusedSectionVars` is disposition **blocking**, "fix per declaration with the `omit [...] in` form Lean prints". The new file must reach **zero** warnings of every blocking class; adding a budget row is not an option (the file's counts are a ceiling that may only decrease, and `warning-budget.txt` is outside `file_scope`). |
| C30 | Blanket linter suppression is barred: the only admissible forms are declaration-scoped `set_option ... in` and the recorded `set_option linter.style.longFile N` length ceiling. The probe's line-626 `set_option linter.unusedSectionVars false` therefore **cannot** be transcribed. |
| C33 | `FormalSystem.lean` is generated by `lake exe mk_all --lib FormalSystem` and compared byte-for-byte. It must be regenerated, never hand-edited. |
| C36a | A `coverage-limit` row in `scripts/certificate-witness-inventory.txt` must be axiom-pinned by C2 or C14. Since this task cannot write that pin, **no row is added**; C36a validates the rows that exist and does not demand one per refutation. |
| `readme-lint.sh` check 1 (**gated**) | Every directory containing `.lean` files has a `README.md`. Creating `PlusSlicedCertificate/Limits/` therefore **requires** `Limits/README.md`. |
| `INV` | Inventory blocks are opt-in by marker. Three existing blocks move when a `.lean` file is added: `README.md` (`dir=FormalSystem rows=totals`), `FormalSystem/README.md` (`dir=FormalSystem rows=loose`, whose `../FormalSystem.lean` line count changes), and `FormalSystem/Metalogic/README.md` (`dir=FormalSystem/Metalogic rows=subdirs cols=files-lines`). The new `Limits/README.md` must **not** carry an inventory marker. |

### Declared-scope extensions, stated rather than taken quietly

`file_scope` names six paths. Four further files must change, each mechanically forced by a gate
above, and none of them a sibling's declared territory (siblings this cycle: 564 on
`FormalSystem/Semantics/Presheaf/Sheaf.lean`; 727 undeclared):

1. `FormalSystem.lean` — generated by `mk_all`; C33 fails without it.
2. `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` — new; gated
   `readme-lint.sh` check 1 fails without it.
3. `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated by
   `check-module-invariants.sh --emit-inventory`; `INV` fails without it.
4. `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` — one roster line for the
   new module. This one is **advisory only** (`readme-lint.sh` check 2 is reported, not gated); it
   is included because it is one line and leaves the subtree's roster honest. Drop it if a sibling
   is found editing that file.

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | The probe's `set_option linter.unusedSectionVars false` cannot be transcribed (C30), and the `Core` section's many section variables produce blocking warnings (C28) | H | H (certain) | Phase 3/4 fix each offending declaration with the `omit [...] in` form Lean itself prints, as `warning-budget.txt`'s disposition line directs. Budget ~20 min of the Phase 4 window for this alone; it is mechanical. Measure with `lake build` output, not by eye |
| R2 | Task-number references in the probe's prose land under `FormalSystem/` and fail C9 | H | H (certain) | Phase 1 rewrites every one to a durable anchor while writing the module docstring; Phase 9's gate run is the backstop. `grep -nE 'task [0-9]' <file>` before each commit |
| R3 | Narrowing `import FormalSystem` to a minimal set breaks an unnoticed dependency, or introduces an import cycle | M | M | Start from `PlusSlicedCertificate.Sound` (which transitively supplies `Check`, `Frame`, `Basic`, and the `Semantics`/`PlusLanguage` chain) plus `FormalSystem.Init`, add `Semantics.SlicedFrame`/`Semantics.IntNormalForm` only if the build asks. If narrowing stalls, fall back to the broader import that compiles and record it — a correct import list is not worth a phase. `Limits/` is imported *by* the subtree root and imports no root, so no cycle is possible; `scripts/check-metalogic-cycles.sh` confirms |
| R4 | Single-letter definitions (`p`, `D`, `F`, `M`, `Φ`, `A'`, `C'`) pollute the `PlusSlicedCertificate` namespace or collide | M | M | Nest them in `namespace NoFiniteWidth` inside `PlusSlicedCertificate` (decision D-N below). The three headline theorems are then `...PlusSlicedCertificate.NoFiniteWidth.{no_finite_width_sat, not_sliced_complete, not_finite_width_fmp}`, which is what the index rows cite |
| R5 | The landed docstrings are read as claiming more than the probe proves (dense duration, infinite carriers, soundness, a width bound) | H | M | Deliverable 3's two scope limits plus the FMP README's two further disclaimers are written into the module docstring **and** onto `not_finite_width_fmp`'s own docstring in Phase 1/6, before the theorem lands. Phase 9 re-reads them against `FMP/README.md`'s section to confirm no over-claim |
| R6 | A `pinned:` claim is added to the new index rows out of habit, repeating the known-ungrounded defect on three existing rows | M | M | Phase 9 writes the Axioms cell as `pcq (not yet in the C2/C14 baseline)` and amends the ledger's "Every declaration listed here is machine-pinned" sentence to admit the exception. No `pinned:` token is typed |
| R7 | The 1180-line transcription exceeds the `longFile` linter ceiling | L | M | Admissible fix: a recorded `set_option linter.style.longFile N` at the top (C30 explicitly permits this one form; `EmbedComplete.lean` already uses it). Set N to the smallest value that passes |
| R8 | A sibling task edits a shared file mid-phase | M | L | Territory discipline: re-read every file immediately before editing it; stage only this task's own hunks with an explicit file list (never `git add -A`, never a directory pathspec); treat an out-of-`file_scope` build failure as possibly a sibling's in-flight edit; stop and report any foreign commit or uncommitted modification after checking `git log` |
| R9 | The probe stops compiling after the landing (duplicate names, changed library surface) | M | L | The landed declarations live in a different namespace from `Probe710`, so no clash. Phase 9 runs `bash scripts/check-evidence-probes.sh` unchanged as a verification item; the probe file itself is not edited |
| R10 | `no_finite_width_sat`'s statement drifts from Deliverable 2 (e.g. a stray hypothesis on `R`, or `Finite W` demoted to an explicit argument) | H | L | The verbatim block above is the authority. Phase 5 diffs the landed signature against it character by character before committing; a stray hypothesis makes the theorem weaker than the refutation it records |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 8 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 9 | 7, 8 |

Phases within the same wave can execute in parallel. In practice Phases 1-7 all edit the single new
module and must run in document order; only Phase 8 (prose in two other files) is genuinely
parallel, and it needs nothing from Phase 1 but the witness's name and the landed module path.

---

### Phase 1: Module skeleton, the witness, the frame and the canonical-path structure [NOT STARTED]

**Goal**: `Limits/NoFiniteWidth.lean` exists, compiles, and carries the Deliverable 2 witness
definitions, the positive-half frame/model, and the canonical-path structure theorems through
`path_eq_canon`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/` and the module
      file with the repository copyright header (copy the four-line form from
      `PlusWitnessFamily/Limits/NoCertificate.lean`; `scripts/check-copyright-headers.sh` checks it)
- [ ] Write the minimal import list, **including `FormalSystem.Init`** (C24). Start from
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Sound`; add
      `FormalSystem.Semantics.SlicedFrame` / `FormalSystem.Semantics.IntNormalForm` and Mathlib
      imports only as the build demands
- [ ] Write the module docstring: what is refuted, the F2 argument in the probe header's six-step
      form, and **Deliverable 3's scope limits in full** — (i) scope is ℤ (discrete) frames only,
      the pumping argument needs discreteness and says nothing about a dense duration; (ii) `Φ`
      uses `⊡`, so this half is specifically an L⁺ result and **not** a result about base TM, in
      contrast with the `⊡`-free finite-carrier witness; (iii) nothing is claimed about an
      *infinite* carrier; (iv) nothing here touches soundness. Add a `## Tags` block in the
      subtree's style
- [ ] **Re-anchor every task-number reference** the probe's prose carries (C9): cite
      `FormalSystem/Metalogic/Decidability/FMP/README.md`'s section
      "The finite-carrier route is refuted, not merely open", or a declaration name, never "task N"
- [ ] Open `namespace FormalSystem.Metalogic.Decidability` / `namespace PlusSlicedCertificate` /
      `namespace NoFiniteWidth` (decision D-N: the single-letter definitions must not land in
      `PlusSlicedCertificate` itself)
- [ ] Transcribe the witness definitions `pa`, `p`, `Fp`, `Pp`, `Xp`, `A'`, `C'`, `D`, `Φ`
      **verbatim** from the probe (lines 48-62), each with a short docstring
- [ ] Transcribe the positive-half carrier and frame: `Node`, `Step` and its six inversion
      theorems, `step_fwd`/`step_bwd`, `fwdList`/`bwdList`/`mem_fwdList`/`mem_bwdList`,
      `fwd_finite`/`bwd_finite`, `iter_fwd_finite`/`iter_bwd_finite`, `fib_finite`, `F`,
      `F_isRegular`, `F_taskRel`, `F_step`, `M` (probe lines 64-228)
- [ ] Transcribe the canonical-path structure: `canon` and its four computation lemmas,
      `canon_step`, `canon_eq_x_iff`, and the `Struct` section through `path_eq_canon` (probe lines
      230-375)
- [ ] Build; fix any blocking-class warning at its own declaration (no file- or section-level
      `set_option`)
- [ ] Commit

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase is hypothesised to transcribe probe lines 44-375 (about 330 source
lines) into roughly 400 library lines once docstrings are added, with the only non-mechanical work
being the import narrowing and the C9 re-anchoring. Confirm at implementation time by building the
module alone and by `grep -c` on the landed declaration names against the probe's; if the import
narrowing resists, fall back per R3 rather than expanding the phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - new file: header, imports, module docstring, witness defs, `Node`/`Step`/`F`/`M`, canonical-path structure

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth`
  succeeds (fallback: `lake env lean FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`)
- Zero warnings in that build output
- `grep -nE 'task [0-9]' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`
  is empty
- `grep -n 'FormalSystem.Init' <file>` is non-empty
- No `sorry` in the file

---

### Phase 2: The positive half — truth lemmas and `not_plusValidZTime_neg_Φ` [NOT STARTED]

**Goal**: `Φ` is satisfied on the countable, finitely branching, time-homogeneous regular ℤ-frame,
and `not_plusValidZTime_neg_Φ` is landed with its `Paper: —` docstring.

**Tasks**:
- [ ] Transcribe `histOf`, `histOf_state`, `hist_canon` (probe lines 377-388)
- [ ] Transcribe the `Truth` section: `truth_p`, `truth_top`, `truth_Fp`, `truth_Pp`, `truth_Xp`
      (probe lines 390-436)
- [ ] Transcribe `lt_of_canon_eq_of_lt`, `gt_of_canon_eq_of_gt`, `eq_of_canon_eq_of_eq`, `Φ_true`,
      `F_isZTime` (probe lines 439-512)
- [ ] Land `not_plusValidZTime_neg_Φ` with a `/-- ... Paper: — (reason) -/` docstring stating that
      the model is **finitely branching** (so König's lemma is not what separates it from the
      sliced class) and of **infinite width** (at any time the post states have unbounded age and
      the pre states unbounded distance to go, and no two are two-way bisimilar) — the two facts
      that are the whole point of the model
- [ ] Build; fix warnings per declaration; commit

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 377-518 (about 140 source lines). Confirm by
building and by checking that `not_plusValidZTime_neg_Φ`'s statement is exactly
`¬ PlusValidZTime Φ.neg`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - append the truth lemmas, `Φ_true`, `F_isZTime`, `not_plusValidZTime_neg_Φ`

**Verification**:
- Module builds, zero warnings, no `sorry`
- `not_plusValidZTime_neg_Φ` carries a doc comment immediately above it whose text contains
  `Paper: — (`
- `#print axioms` on it reports `[propext, Classical.choice, Quot.sound]`

---

### Phase 3: The negative half, part I — path infrastructure and the pre/post classification [NOT STARTED]

**Goal**: the `NoFiniteWidth` section's path machinery and the pre/post state classification are
landed, with every section-variable warning fixed per declaration rather than suppressed.

**Tasks**:
- [ ] Open the section with `variable {W : Type} (R : ℤ → W → W → Prop)` and transcribe `IsPath`,
      `fwdSeq`/`fwdSeq_zero`/`fwdSeq_spec`, `bwdSeq`/`bwdSeq_zero`/`bwdSeq_spec`,
      `exists_path_through`, `glue`/`glue_of_le`/`glue_of_lt`/`glue_isPath` (probe lines 527-618)
- [ ] Transcribe the `Core` section preamble — `[Finite W] [Nonempty W]`, `val`, `PreN`, `PostN`,
      and the `someP`/`onceP`/`succP` hypothesis variables (probe lines 622-645) — **omitting the
      probe's line-626 `set_option linter.unusedSectionVars false`**
- [ ] Transcribe `not_val_of_postN`, `not_val_of_preN`, `preN_or_postN`, `postN_of_exists`,
      `preN_of_exists`, `postN_succ_of_val`, `postN_succ`, `preN_pred_of_val`, `preN_pred` (probe
      lines 647-764)
- [ ] For each declaration the build reports an unused section variable on, add the
      `omit [...] in` line Lean prints directly above it (`warning-budget.txt`'s own prescribed
      fix). Do **not** add a file- or section-level `set_option` (C30), and do **not** add a
      `warning-budget.txt` row
- [ ] Build; confirm zero warnings; commit

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 520-764 (about 245 source lines), with an unknown
number of `omit [...] in` insertions — the probe's blanket suppression hides the count. Confirm by
reading the first build's warning list and recording the actual number of insertions in the phase's
commit message; if it exceeds roughly 25, re-time Phase 4 rather than rushing the fixes.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - append the path infrastructure and the pre/post classification

**Verification**:
- Module builds with **zero** warnings (this is the phase where that is at risk)
- `grep -n 'set_option' <file>` shows no un-`in`-scoped option other than a possible
  `linter.style.longFile N`
- No `sorry`

---

### Phase 4: The negative half, part II — chains, pigeonhole, König, `core_false` [NOT STARTED]

**Goal**: `core_false` is landed: `someP`, `onceP` and `succP` are jointly unsatisfiable on a
finite `W`.

**Tasks**:
- [ ] Transcribe `preN_chain` and `val_chain` — `p` states at every earlier time (probe lines
      766-793)
- [ ] Transcribe `postN_fwdSeq`, `BackChain`, `backChain_mono`, `postN_of_backChain`,
      `exists_backChain`, and the pigeonhole `exists_long` (probe lines 795-865)
- [ ] Transcribe the König step `long_step` and the iterated `longSeq`/`longSeq_time`/
      `longSeq_step`/`longSeq_postN` (probe lines 867-916)
- [ ] Transcribe `core_false` (probe lines 918-975) with a docstring recording that **nothing**
      about tail-stability, periodicity, the window, labels or liveness enters the argument: the
      refutation is of the frame class
- [ ] Close the `Core` section; fix any remaining per-declaration warning with `omit [...] in`
- [ ] Build; commit

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 766-977 (about 210 source lines). Confirm by
building; `core_false`'s statement must remain exactly `False` under the section's hypotheses, with
no added hypothesis on `R`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - append the chain lemmas, the pigeonhole, the König step and `core_false`

**Verification**:
- Module builds, zero warnings, no `sorry`
- `core_false` takes exactly the three path-fact hypotheses (`someP`, `onceP`, `succP`) plus
  `[Finite W] [Nonempty W]` and the bi-seriality carried by the section's variables

---

### Phase 5: The semantic layer and `no_finite_width_sat` [NOT STARTED]

**Goal**: the headline core theorem is landed, with the Deliverable 2 signature character for
character.

**Tasks**:
- [ ] Transcribe `pathHist`, `pathHist_state`, `hist_offset`, `hist_offset_zero` (probe lines
      979-1019)
- [ ] Open the `Semantics` section with
      `variable (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame)` and transcribe
      `box_transfer`, `someP_of_A'`, `onceP_of_C'`, `succP_of_D` (probe lines 1021-1103)
- [ ] Land `no_finite_width_sat` with a `/-- ... Paper: — (reason) -/` docstring that names the
      hypothesis set plainly: `[Finite W] [Nonempty W]` is the whole finiteness hypothesis, and
      there is no hypothesis on the succession relation beyond the bi-seriality carried by `fwd`
      and `bwd`
- [ ] **Diff the landed signature against the verbatim block in this plan**, binder by binder,
      before committing (R10)
- [ ] Close the sections; build; commit

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 979-1120 (about 140 source lines). Confirm by
`lean_hover_info` (or `#check`) on the landed `no_finite_width_sat` and a character-level
comparison against this plan's verbatim block.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - append the history/offset lemmas, the three semantic extractions and `no_finite_width_sat`

**Verification**:
- Module builds, zero warnings, no `sorry`
- `#check` output for `no_finite_width_sat` matches the plan's verbatim statement
- `#print axioms` reports `[propext, Classical.choice, Quot.sound]`

---

### Phase 6: The certificate corollaries [NOT STARTED]

**Goal**: `not_certifies`, `not_sliced_complete` and `not_finite_width_fmp` are landed, each with
its `Paper: —` docstring, and the module is complete.

**Tasks**:
- [ ] Transcribe `not_certifies` (probe lines 1124-1152), routed through the landed `Certifies`
      checker and `PlusSlicedCertificate/Sound.lean`'s own `plusRefutes_of_certifies` argument,
      **keeping the frame** rather than exporting through `PlusRefutes`, which forgets it. Docstring
      records D2: the refutation is of the frame class, so it survives a change to the checker's
      clauses, the tail-stability mechanism or the wire format
- [ ] Transcribe `not_sliced_complete` (probe lines 1154-1162) with its `Paper: —` docstring
- [ ] Transcribe `not_finite_width_fmp` (probe lines 1164-1178). Its docstring carries
      **Deliverable 3 in full at the theorem itself**: ℤ/discrete only; `Φ` uses `⊡` so this is an
      L⁺ result and not a result about base TM; nothing about an infinite carrier; nothing about
      soundness; and no width bound for targets that *do* have finite-width countermodels
- [ ] Add a short closing record to the module docstring (or a trailing `/-! -/` section): the
      obstruction chain finite carrier ⊊ finite width ⊊ what the class needs, and the F4
      characterisation — complete exactly on targets with a finite-width countermodel — explicitly
      labelled **argued, not proved**
- [ ] Close the namespaces; build; commit

**Timing**: 45 minutes

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: hypothesised at probe lines 1124-1180 (about 55 source lines) plus the
closing record. Confirm by building and by `#print axioms` on all five headline declarations.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` - append the three corollaries and the closing record

**Verification**:
- Module builds, zero warnings, no `sorry`
- All five headline declarations report `[propext, Classical.choice, Quot.sound]`
- Each of the five has a doc comment immediately above it containing `Paper: — (`
- `not_finite_width_fmp`'s docstring contains both scope limits and both further disclaimers

---

### Phase 7: Wire the module into the build graph [NOT STARTED]

**Goal**: the new module is reachable from `lake build`, the new directory has its README, and the
whole library is green.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (territory
      discipline: task 706 also declares it), then add
      `import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth` to
      its import block, in the block's existing order
- [ ] Add a `## Submodules` bullet for `PlusSlicedCertificate.Limits.NoFiniteWidth` to that file's
      docstring, in the style of its siblings
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. **Never** hand-edit
      `FormalSystem.lean` (C33 compares byte for byte)
- [ ] Write `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` on the
      model of `PlusWitnessFamily/Limits/README.md`: purpose, the one-module table, the scope
      boundary (what the refutation does and does not claim), and a `*Last verified: <ISO date>*`
      footer. **No** `<!-- BEGIN GENERATED: inventory -->` marker — the block is opt-in and the
      route-ordered table this directory wants is not what the generator produces
- [ ] Add the new module to `PlusSlicedCertificate/README.md`'s module roster (advisory; drop if a
      sibling is editing that file)
- [ ] Full `lake build`
- [ ] Commit the batch

**Timing**: 45 minutes

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: hypothesised as exactly five files (the subtree root, the generated
`FormalSystem.lean`, the new `Limits/README.md`, the subtree `README.md`, and no other). Confirm
with `git status --short` before staging; any sixth path means something unplanned happened and
must be read before it is staged.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one import line plus one `## Submodules` bullet
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` (never by hand)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` - new directory README (gated by `readme-lint.sh` check 1)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` - one roster line (advisory)

**Verification**:
- `lake build` succeeds for the whole library
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/check-metalogic-cycles.sh` exits 0
- `git status --short` shows exactly the five planned paths

**Commit-mode note**: the import line, the regenerated root and the new README are one objective
because the intermediate states are genuinely red — an import added without regenerating the root
fails C33, and a new `.lean` directory without its README fails `readme-lint.sh` check 1. This is a
pre-declared batch, not a retroactively widened one.

---

### Phase 8: Restate the class's completeness where the library asserts it [NOT STARTED]

**Goal**: Deliverable 5. The two places the library states the sliced class's completeness status
no longer call the `⊡`-carrying case open.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (shared with task
      706 and with Phase 7), then rewrite its header's
      "### What is refuted, and what is open" section: the sentence "The **sliced** finite model
      property is **OPEN, not refuted**. No module here states it, implies it, or treats it as
      settled either way" is now false and must go. Replace with: the class is **complete on the
      `⊡`-free fragment** (the landed flagship, unchanged); it is **incomplete for L⁺ and for the
      CTL-like fragment**, with `Φ` named and `Limits/NoFiniteWidth.lean` cited; and the precise
      semantic characterisation — complete exactly on targets with a finite-width countermodel — is
      recorded as **argued, not proved**
- [ ] State in the same place that the obstruction is width alone: no change to tails, windows or
      stability can rescue the class, because `Φ` forbids every finite-width collapse at once
- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean`, then
      rewrite "What the flagship does and does not buy": the clause "whether a `⊡`-carrying target
      has a sliced certificate is the open Stage 3 question and nothing here bears on it" is now
      false. Replace with the refutation, naming `Φ` and the landed theorem, and keep the sentence
      that the flagship itself — the `⊡`-free embedding — is **unaffected**
- [ ] Carry the two scope limits into both restatements so neither reads as claiming more
- [ ] Check no task number entered either file (C9); build both modules; commit

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: hypothesised as exactly two files and two prose sections, with the stale
claims confined to the two sentences quoted above. Confirm at implementation time by grepping both
files for `open`/`not refuted`/`Stage 3` and reading every hit — if a third stale sentence turns up
in either header, fix it in this phase and say so; if one turns up in a file this plan does not
name, report it rather than editing outside the enumerated set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - header: rewrite "What is refuted, and what is open"
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` - header: rewrite "What the flagship does and does not buy"

**Verification**:
- `grep -n 'OPEN, not refuted' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` is empty
- `grep -n 'open Stage 3 question' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` is empty
- Both files name `Φ` and cite `Limits/NoFiniteWidth.lean`
- Both restatements label the F4 characterisation argued, not proved
- `grep -nE 'task [0-9]' ` on both files is empty
- Both modules build

---

### Phase 9: Theorem-index rows, generated-surface regeneration, and the full gate set [NOT STARTED]

**Goal**: Deliverable 4 plus a green gate set. Every landed theorem has a ledger row; every
generated surface the new file moved is current.

**Tasks**:
- [ ] Add one `docs/theorem-index.md` row per landed theorem — `not_plusValidZTime_neg_Φ`,
      `no_finite_width_sat`, `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp` —
      immediately after the existing `EmbedComplete` sliced row, in the same six-cell shape:
      `| — | <one-line statement> | `<fully qualified name>` | `<path, no line number>` |
      <frame class or —> | pcq (not yet in the C2/C14 baseline) |`
- [ ] Do **not** type a `pinned:C2` or `pinned:C14` token. Amend the ledger's
      "Every declaration listed here is machine-pinned" sentence to admit the exception, and say in
      one sentence that the axiom sets were read with `#print axioms` at landing time but are not
      yet asserted by a baseline line in `scripts/check-module-invariants.sh` — without naming any
      task number (`C9D` is enforced under `docs/`)
- [ ] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      then `bash scripts/check-module-invariants.sh --emit-inventory --check` to prove no byte
      would change. Expect `README.md`, `FormalSystem/README.md` and
      `FormalSystem/Metalogic/README.md` to move
- [ ] Run the full gate set and read the C9, C15, C24, C28, C30, C33, C36 and INV lines
      individually rather than only the exit code
- [ ] Re-read the landed docstrings against
      `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route is refuted,
      not merely open" section and confirm no landed claim exceeds it (R5)
- [ ] Commit

**Timing**: 1.25 hours

**Depends on**: 7, 8

**Verification Tier**: full

**Scope Hypothesis**: hypothesised as five new ledger rows plus one amended sentence in
`docs/theorem-index.md`, and exactly three regenerated inventory files. Confirm by counting the
added rows and by `git status --short` after `--emit-inventory`; a fourth regenerated file means an
inventory block was found that this plan's survey missed, and should be read before staging.

**Files to modify**:
- `docs/theorem-index.md` - five ledger rows plus the machine-pinned caveat sentence
- `README.md` - regenerated inventory totals (`dir=FormalSystem rows=totals`)
- `FormalSystem/README.md` - regenerated loose-file inventory (the `../FormalSystem.lean` line count moves)
- `FormalSystem/Metalogic/README.md` - regenerated subdirectory inventory (the `Decidability` row's files/lines move)

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with C15's second assertion passing on the
  five new rows
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no byte would change
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/check-evidence-probes.sh` exits 0 with the probe entry **unedited**
- `grep -n 'pinned:C' docs/theorem-index.md` shows no hit on any of the five new rows
- `lake build` green and the tree sorry-free in the new module

---

## Testing & Validation

- [ ] `lake build` succeeds for the whole library
- [ ] `grep -rn 'sorry' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/` returns
      nothing outside a comment
- [ ] `#print axioms` on each of the five landed declarations reports
      `[propext, Classical.choice, Quot.sound]`
- [ ] `no_finite_width_sat`, `not_sliced_complete` and `not_finite_width_fmp` match this plan's
      verbatim statements binder for binder
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (C9, C15, C24, C28, C30, C33, C36, INV read
      individually)
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no drift
- [ ] `bash scripts/readme-lint.sh` exits 0 (check 1 is gated; the new directory has its README)
- [ ] `bash scripts/check-copyright-headers.sh` exits 0
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0
- [ ] `bash scripts/check-evidence-probes.sh` exits 0, with
      `specs/710_.../probes/NoFiniteWidthModel.lean` still compiling and its `WIRED_REPO` entry
      untouched
- [ ] Zero task-number citations under `FormalSystem/` and `docs/` from this task's edits
- [ ] No file outside this plan's enumerated `Files to modify` lists is staged in any commit

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (new; the
  five landed declarations plus their supporting development)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` (new)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (import line, `## Submodules`
  bullet, rewritten "What is refuted, and what is open")
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` (rewritten "What
  the flagship does and does not buy")
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` (one roster line; advisory)
- `FormalSystem.lean` (regenerated by `lake exe mk_all --lib FormalSystem`)
- `docs/theorem-index.md` (five rows plus the machine-pinned caveat sentence)
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` (regenerated inventory
  blocks)
- `specs/710_sliced_class_incompleteness_characterization/summaries/01_land-finite-width-refutation-summary.md`
  (implementation summary, written at implement time)

**Not** produced, by design: no edit to `scripts/check-module-invariants.sh`, no edit to
`scripts/check-evidence-probes.sh`, no move or deletion of the probe file, no
`scripts/certificate-witness-inventory.txt` row, no edit to
`FormalSystem/Metalogic/Decidability/FMP/README.md`, and no edit to
`FormalSystem/Semantics/IntNormalForm.lean` (see Contingency C1).

## Contingencies

**C1 — `FormalSystem/Semantics/IntNormalForm.lean` is in `file_scope` but expected untouched.** The
report's Recommendation 1 priced a generic `FrameOver.ofStepFib` constructor into its 6-10 h
estimate; the dispatch removes it, because the constructors the probe actually uses
(`FrameOver.ofReflectiveRegular`, `TaskFrame.saturation_of_fib_finite`,
`FrameOver.ofSlicedStep`) are already landed. If Phase 1 discovers that the probe's `fib_finite`
route does not transfer without a library-side generalisation, add it to `IntNormalForm.lean` —
which `file_scope` already names — as a Phase 1 sub-step, and record the deviation in the summary.
Do not invent the constructor speculatively.

**C2 — The namespace decision (D-N).** The five headline theorems land in
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth`, nested so that the
single-letter definitions (`p`, `D`, `F`, `M`, `Φ`, `A'`, `C'`) do not land in
`PlusSlicedCertificate` itself. The alternative — following `PlusWitnessFamily/Limits/`'s
precedent of declaring straight into the subtree namespace — is rejected for exactly that reason.
If the implementer prefers to `export` the three headline names up one level for ergonomics, that
is admissible, but the index rows must then cite whichever fully qualified name actually resolves.

**C3 — If a gate cannot be made green without editing a forbidden file.** Stop and report rather
than editing `scripts/check-module-invariants.sh`, `scripts/warning-budget.txt` or
`scripts/check-evidence-probes.sh`. Record the blocker in `.return-meta.json` and in the
`.orchestrator-handoff.json` with `status: blocked`. A gate that demands a baseline edit is a
sequencing fact about tasks 710/706/720, not a licence to cross a declared territory boundary.

## Rollback/Contingency

The landing is additive and the risky part is one new file, so rollback is cheap: revert the
phase's commit. Each phase ends green and is committed on its own, so `git revert <sha>` of the last
phase restores a buildable tree without touching the earlier phases' work.

If a genuine whole-tree rollback of uncommitted work becomes necessary, take a snapshot **first**
per `context/contracts/recovery.md`'s rollback rung (which names the invocation shape, including
its out-of-scope override flag for the deliberate whole-tree case) and only then run the
destructive command. For an ordinary defensive checkpoint before a risky edit — not a rollback —
use `bash .claude/scripts/git-snapshot.sh 710 --no-revert`, which is durable without reverting the
working tree; never the bare reverting default as a routine start-of-phase precaution.

Two reversals are worth naming explicitly:

- **Phase 7's batch** must be reverted as a unit. Reverting the import line without the regenerated
  `FormalSystem.lean` leaves C33 red; reverting the root without the import leaves the module
  unreachable.
- **Phase 9's inventory regeneration** is reproducible, not hand-written: if its commit is
  reverted, re-run `bash scripts/check-module-invariants.sh --emit-inventory` rather than editing
  the numbers back.

Because sibling tasks may be running on this same working tree, never run a reverting
`git-snapshot.sh`, never stage a directory or glob pathspec, and stop and report any foreign commit
or uncommitted modification after checking `git log` to confirm the work is not this task's own.
