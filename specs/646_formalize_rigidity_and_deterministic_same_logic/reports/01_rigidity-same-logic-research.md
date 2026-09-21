# Research Report: Task #646

**Task**: 646 - Formalize rigidity (R2) and deterministic same-logic (R1)
**Started**: 2026-09-21T23:12:08Z
**Completed**: 2026-09-21T23:20:47Z
**Effort**: ~20 minutes research; implementation estimate 2-3 hours (both results are already proved in scratch)
**Dependencies**: None (imports `Semantics/ShiftSet.lean` read-only; independent of task 543)
**Sources/Inputs**: - Codebase at `61b2dc82e` (`Semantics/{TaskFrame,ShiftSet,Validity,FrameProperty,FrameClassValidity,LexCarrier}.lean`, `Semantics/Frames/Standard.lean`, `Semantics/Correspondence/*`, `Metalogic/Deterministic/*`, `Metalogic/Compactness.lean`, `scripts/check-module-invariants.sh`, `docs/reference/paper-definitions-of-record.md`); lean-lsp MCP (`lean_run_code`, 9 runs); literature source: the three reports under `/home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/` (03 §4.3.6 and §5.1, 04 §4.7, 05 §1.1 V6, §3 R1/R2, Appendix A.1/A.4); manuscript `JPL/possible_worlds.tex` (anchor grep only)
**Artifacts**: - specs/646_formalize_rigidity_and_deterministic_same_logic/reports/01_rigidity-same-logic-research.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Both results are true as intended and are fully proved in scratch in the current tree** (`lean_run_code`, no `sorry`, axioms `[propext, Classical.choice, Quot.sound]`; the R2 core chop lemma is choice-free, `[propext, Quot.sound]`). The proof text is reproduced verbatim in the Appendix; implementation is transcription plus documentation plumbing. A sorry-free, axiom-free path exists for everything in scope.
- **R2 (rigidity) stands, with two honest refinements to report 03's wording.** (i) Report 03 remark (a), "only Limit and Compositionality are used", is right for the direction `w ⇒_x u → w = u` but the *biconditional* "static (`w ⇒_x u` iff `w = u`)" also consumes **Seriality** (to produce `w ⇒_x w`) and the reflection law (for negative durations). (ii) The proof's real hypothesis is weaker than "dense Archimedean + cone radius": the chop needs only `[Archimedean D]`, interpolation, and a step bound `∀ y, 0 ≤ y ≤ ε → R w y u → u = w` for some `ε > 0`. Density is used exactly once, to get `0 < ε < x₀` under the *strict* cone bound `|y| < x₀`. Recommend stating the core lemma at that hypothesis and deriving the paper-shaped theorem as a corollary.
- **Both sharpness remarks of report 03 also compile** (scratch): density cannot be dropped (`permissiveFrame D so nm`, `W = Bool`, is never static, in particular over the Archimedean `ℤ`); the Archimedean property cannot be dropped (the two-state frame over `ℚ ×ₗ ℚ` with `w ⇒_d u ↔ d.1 ≠ 0 ∨ w = u` satisfies all four `def:frame` axioms, `ℚ ×ₗ ℚ` is `DenselyOrdered` and provably `¬ Archimedean`, and the frame is not static). These are optional but cheap (~90 lines) and are what makes "the hypotheses are sharp" a theorem rather than a remark.
- **R1: report 05's Appendix A.1 no longer elaborates; a corrected version does.** Two things moved since that report: `WorldHistory F` is now the carrier of *total* histories (no `IsTotal`, no subtype `⟨τ, hτ⟩`, no `Valid.of_forall_total`), and `ShiftSet.frame`'s relation is now presented through `TaskFrame.reflect`, so the helper's discharge `fun _ _ _ => Iff.rfl` fails with a type mismatch. The fix is `fun w d u => S.fibre_taskRel w d u`. With that, R1 elaborates.
- **The tree already contains a deterministic metatheory that R1 should be stated against.** `Metalogic/Deterministic/Validity.lean` defines `DetSat`, `ValidDetIn fc φ := ValidOnFrames (DetSat fc) φ` and proves `ValidIn.toDet` (one direction). The converse is not stated anywhere at the `Formula` level. R1's natural headline is therefore `validIn_iff_validDetIn (fc) (φ) : ValidIn fc φ ↔ ValidDetIn fc φ`, uniformly in the frame class, with the task description's `Valid φ ↔ ∀ deterministic F …` as its `.Base` corollary, and a frame-predicate-general form underneath. The siting `Metalogic/Deterministic/SameLogic.lean` is exactly right.
- **Paper-anchor constraint (C15)**: the manuscript has no rigidity theorem yet and `app:rigidity` is not in the record's MANIFEST or KNOWN-ANCHORS blocks, so **no docstring may cite `app:rigidity`**. Cite only existing anchors (`def:frame#Limit`, `def:frame#Compositionality`, `def:frame#Seriality`, `def:task-relation`, `def:deterministic`, `app:deterministic`, `def:logical-consequence`, `cor:saturation-finite`).

## Context & Scope

Researched: whether R1 and R2 are provable as stated against the *current* tree, what their exact Lean statements should be, which existing declarations they compose, what report 05's claims about the tree got stale, and what the acceptance gates (`--wfail`, header linter, `mk_all --check`, `check-module-invariants.sh`, `--emit-inventory`) require of two new modules. Out of scope and untouched: R3, R4, Theorem B, any edit to `ShiftSet.lean`. No file outside this task directory was written; every proof below lives only in `lean_run_code` scratch.

Working-tree fact verified: at the start of this dispatch `typst/chapters/ax-lean-appendix.typ`, `specs/TODO.md`, `specs/state.json` were modified by another session; by mid-dispatch they had been committed by that session (HEAD `61b2dc82e`). Nothing here touched them. `lake exe mk_all --lib FormalSystem --check` exits 0 at baseline.

## Literature Proof Structure

**Source**: report 03 §4.3.6 "Rigidity: finite state spaces admit no continuous-time dynamics" and its house-style draft §5.1; refinement in report 04 §4.7; roadmap and scratch statements in report 05 §3 R1/R2 and Appendix A.1/A.4.
**Strategy**: R2 — direct, by chopping a duration into steps below the dwell radius (induction on the Archimedean bound); finite half by a minimum over the carrier. R1 — direct, two-way truth transfer through the shift-set representation.

### Step Map (R2)
1. (⟹) A static frame has `(w)_x = {w}` for every `x > 0`; a positive `x₀` exists because `D` is nontrivial. -- report 03 "(⟹) trivial". Lean: `uniformDwell_of_static`, uses `exists_pos_of_nontrivial`.
2. Density: pick `0 < ε < x₀`. -- report 03 "By density pick". Lean: `exists_between`.
3. Archimedean: pick `n` with `x ≤ n • ε`. -- report 03 "pick `n ≥ 1` minimal". Lean: `Archimedean.arch x hε`. **Deviation, flagged**: the source takes `n` *minimal* and builds the whole chain `w₀ … w_n`; the Lean proof does induction on `n` generalizing `w, x` and peels one `ε`-step at a time, so neither minimality nor `Nat.find` nor a chain object is needed. Same argument, different bookkeeping; report 05 R2 already recommended this.
4. Interpolation half of Compositionality splits `x = ε + (x - ε)`. -- report 03 "Applying the interpolation half". Lean: `Interpolates R` (or `F.interpolates`).
5. Each step lies inside the cone of radius `x₀`, so the dwell hypothesis collapses it. -- report 03 "so `w_{i+1} ∈ (w_i)_{x₀} = {w_i}`".
6. Negative durations via the converse convention. -- implicit in the source ("`w ⇒_x u` with `x > 0`"). Lean: `F.reflection`.
7. **Unstated in the source**: `w ⇒_x w` for every `x`, needed for the "iff" in "static". Lean: `F.serial` + step 5's conclusion. This is the Seriality dependence noted in the Executive Summary.
8. Finite `W`: Limit gives a per-state radius; take the minimum. -- report 03 "cones … take finitely many values". Lean: `TaskFrame.exists_uniform_radius_of_finite` (per-`w`, existing) + one `Finset.inf'` over `w` (new, 12 lines).

### Step Map (R1)
1. Deterministic ⊆ all: monotonicity. -- `ValidOnFrames.mono` / existing `ValidIn.toDet`.
2. Given any `F, M, τ, t`: `reverse_repr F M τ t φ : ShiftTruth (ofModel F M) τ t φ ↔ TruthAt M τ t φ`.
3. `forward_repr (ofModel F M) τ t φ : TruthAt S.model (S.hist τ) t φ ↔ ShiftTruth S τ t φ`.
4. **Third fact (report 05 V6)**: `(ofModel F M).frame` is deterministic -- new one-line helper `ShiftSet.frame_deterministic`.
5. The frame-class condition survives `ofModel` (duration order untouched) -- `cases fc <;> exact h` (the body of `Compactness.lean`'s `sat_ofModel_frame`).

### Dependencies
- R2 step 5 depends on 2-4; step 7 depends on 5; the finite corollary depends on 1-8.
- R1 step 2-3 compose only with 4 and 5 in hand.

### Potential Formalization Challenges
- None open. The only trap is R1's helper: `Iff.rfl` no longer closes `S.frame.TaskRel w d u ↔ u = S.sh w d`; use `S.fibre_taskRel`.

## Findings

### Codebase Patterns

**Tree drift against report 05 (re-verified, as the task demands):**

| Report 05 claim | Current tree | Consequence |
|---|---|---|
| `exists_uniform_radius_of_finite` at `TaskFrame.lean:907` | `:1210`; signature unchanged: `[Finite W] (R) (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ R w y u) → u = w) (w) : ∃ x, 0 < x ∧ ∀ u y, \|y\| < x → R w y u → u = w` | usable as is; it is **per-`w`**, so R2 still needs a min over `w` |
| `Interpolates :455`, `cone :286`, `FrameOver :561-711` | `Interpolates :575`, `cone :398`, `Compositional :599`, `FrameOver :768` | names and shapes unchanged |
| `WorldHistory F` convex + `IsTotal` predicate; `reverse_repr F M ⟨τ,hτ⟩ t φ`; `Valid.of_forall_total`; `hist_isTotal` | `WorldHistory F` **is** the total-history type; `reverse_repr F M (τ : WorldHistory F) t φ`; `Valid.of_forall`, `Valid.apply`; no `IsTotal` in `ShiftSet.lean` | A.1 must be rewritten (done, Appendix A.2) |
| helper `fib_subsingleton_of_functional (f := S.sh) (fun _ _ _ => Iff.rfl)` "one line" | **fails**: `Iff.rfl … expected S.frame.TaskRel x✝² x✝¹ x✝ ↔ x✝ = S.sh x✝² x✝¹` — the fibre is now built from `PosRel` through `TaskFrame.reflect` | use `fun w d u => S.fibre_taskRel w d u`; still one line, axioms `[propext, Quot.sound]` |
| placement "beside `reverse_repr` in `ShiftSet.lean` or a new `Correspondence/DeterministicTheory.lean`" | `Metalogic/Deterministic/` exists with `Validity.lean` (`DetSat`, `ValidDetIn`, `ValidIn.toDet`, binder adapters) | site R1 there; state it against `ValidDetIn` |
| `sat_ofModel_frame` at `Compactness.lean:93` | `:97`, body `cases fc <;> exact h` | `Compactness.lean` imports the ultraproduct stack; do **not** import it for a one-liner — inline the `cases` (it is a proof term inside a lambda, not a duplicated declaration) |
| "no topology exists anywhere in this library" docstring nit (R8) | unchanged | out of scope (would edit `TaskFrame.lean`) |

**What exists that R1 must not duplicate.** `Metalogic/Deterministic/Engines.lean` proves `derivable_of_validDet fc φ : ValidDetIn fc φ → Derivable fc [] φ`. Composed with TM soundness this already yields `ValidDetIn fc φ → ValidIn fc φ` for the four tags — so R1 at the four classes is *derivable today by a completeness detour*. The shift-set route is still the right deliverable, for three reasons the docstring should state: it is **semantic and per-model** (each `(F, M, τ, t)` is matched by a deterministic `(F', M', τ', t)` with the same truth value for every formula — strictly more than equality of validity sets); it does not route through Lindenbaum/canonical models; and its general form covers **any** frame predicate stable under `ofModel` (e.g. `TaskFrame.IsComplete`, `IsQTime`), not only the four tags with a completeness engine. It also gives an independent check on the engine narrowing.

**No `Static` predicate exists.** `FrameOver.staticFrame` (`TaskFrame.lean:1912`) is a construction with `staticFrame_rel_iff`; `Metalogic/Independence/StaticFrame.lean` is its truth calculus. R2 needs a predicate on a bare relation. No name clash for `TaskFrame.Static` or `TaskFrame.UniformDwell` (grep clean).

**Witness frames for sharpness already half exist.** `permissiveFrame (D) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) : FrameOver D` with `W = Bool` and `@[simp] permissiveFrame_taskRel` (`Semantics/Frames/Standard.lean:117-131`, imports only `TaskFrame`). `Semantics/LexCarrier.lean` supplies the `×ₗ` instance imports (`Mathlib.Data.Prod.Lex`, `Mathlib.Algebra.Order.Monoid.Prod`, `Mathlib.Data.Rat.Cast.Order`) and proves `not_archimedean` for `α ×ₗ ℤ` only — not for `ℚ ×ₗ ℚ`, so that is a fresh 12-line lemma (Appendix A.3). `FrameOver.ofReflective` + `TaskFrame.saturation_of_finite` build the two-state lex frame with no new infrastructure. Note `Mathlib.Algebra.Order.Group.Prod` is **not** in this checkout's Mathlib build; `Mathlib.Algebra.Order.Monoid.Prod` is the one that works.

### External Resources (Mathlib, all verified by successful elaboration, none guessed)

- `Archimedean.arch : ∀ (x : M) {y : M}, 0 < y → ∃ n : ℕ, x ≤ n • y` — available from `Mathlib.Algebra.Order.Archimedean.Defs` (the lighter import suffices for the core lemma; `.Basic` is already used by `ShiftSet.lean` and `LexCarrier.lean`).
- `exists_between`, `succ_nsmul`, `sub_le_iff_le_add`, `add_sub_cancel`, `sub_nonneg`, `abs_of_nonneg`, `abs_lt`, `neg_nonneg`.
- `Finset.inf'`, `Finset.lt_inf'_iff`, `Finset.inf'_le`, `Fintype.ofFinite` — the same idiom `exists_uniform_radius_of_finite` uses internally.
- `Prod.Lex.lt_iff`, `Prod.Lex.le_iff`, `ofLex_add`, `ofLex_neg`, `Prod.fst_add`, `Prod.fst_neg`; instances `DenselyOrdered (ℚ ×ₗ ℚ)`, `IsOrderedAddMonoid (ℚ ×ₗ ℚ)`, `AddCommGroup`, `LinearOrder`, `Nontrivial` all synthesize under `LexCarrier`'s imports.
- Hölder's theorem is **not** needed (report 05 already said so); do not import it for the docstring's "dense subgroup of ℝ" gloss.

### Recommendations

**R2 — `FormalSystem/Semantics/Correspondence/Rigidity.lean`** (est. 160-260 lines with docstrings; imports `FormalSystem.Semantics.TaskFrame`, `Mathlib.Algebra.Order.Archimedean.Defs`; plus `FormalSystem.Semantics.Frames.Standard` and `FormalSystem.Semantics.LexCarrier` if the sharpness section is included).

Declarations, in order (all proved, Appendix A.1/A.3):
1. `TaskFrame.Static R : Prop := ∀ w x u, R w x u ↔ w = u` and `TaskFrame.UniformDwell R : Prop := ∃ x₀, 0 < x₀ ∧ ∀ w, cone R w x₀ = {w}` — the paper's "(w)_{x₀} = {w}" verbatim, using the existing `cone`.
2. `TaskFrame.eq_of_rel_of_step [Archimedean D] (hint : Interpolates R) (hε : 0 < ε) (hstep : ∀ w u y, 0 ≤ y → y ≤ ε → R w y u → u = w) : ∀ w u x, 0 ≤ x → R w x u → u = w` — **the theorem at the hypothesis the proof actually uses**: no density, no Limit, no Seriality, no `Nontrivial`; choice-free.
3. `TaskFrame.eq_of_rel_of_uniform_radius [DenselyOrdered D] [Archimedean D] (hint) (hx₀ : 0 < x₀) (hrad : ∀ w u y, |y| < x₀ → R w y u → u = w)` — report 05's `static_of_uniform_radius` shape; density enters here only.
4. `FrameOver.static_of_uniformDwell`, `FrameOver.uniformDwell_of_static`, and the headline **`FrameOver.static_iff_uniformDwell [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D) : Static F.TaskRel ↔ UniformDwell F.TaskRel`**.
5. `FrameOver.uniformDwell_of_finite (F) [Finite F.WorldState] : UniformDwell F.TaskRel` — needs **no** order hypothesis at all (Limit + finiteness only; over `ℤ` it holds with a vacuous radius, which is the point of the sharpness remark).
6. Headline **`FrameOver.static_of_finite [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D) [Finite F.WorldState] : Static F.TaskRel`**.
7. Optional one-line `TaskFrame`-bundled restatements (`F.toFibre`), if the planner wants `lean_verify` targets at the bundled level; and `[Finite]` rather than `[Fintype]` (report 05 wrote `Fintype`; `Finite` is what `FiniteFrameOver.finite_world` and `exists_uniform_radius_of_finite` use).
8. Sharpness section (recommended): `permissiveFrame_not_static` (any `D` with `SuccOrder`/`NoMaxOrder`, hence `ℤ`); `galaxyFrame : FrameOver (TemporalOrder.of (ℚ ×ₗ ℚ))` on `Bool`, `galaxyFrame_not_static`, `lexRat_not_archimedean`. If the planner prefers to keep `Rigidity.lean` import-light, put item 8 in a sibling `Correspondence/RigiditySharpness.lean`.

Docstring obligations (from the task description): state that for *time-indexed* frames the boundary is Dedekind completeness, not the Archimedean property (report 04 §4.7: over `ℝ` finite `W` + Limit alone forces constant histories by connectedness; over `ℚ` two-state time-indexed frames switching at irrational gaps are non-static) — as a scope note only, since no time-indexed frame type exists in this tree and nothing about them is proved here. Record that the biconditional uses Seriality and reflection while the collapse direction uses only interpolation + the dwell bound. Do not claim more.

**R1 — `FormalSystem/Metalogic/Deterministic/SameLogic.lean`** (est. 70-110 lines with docstrings; imports `FormalSystem.Semantics.ShiftSet`, `FormalSystem.Metalogic.Deterministic.Validity`). Declarations (all proved, Appendix A.2):
1. `ShiftSet.frame_deterministic (S : ShiftSet D) : S.frame.Deterministic` — in namespace `FormalSystem.Semantics.ShiftSet` but **declared in the new module** (the task forbids editing `ShiftSet.lean`; `FrameProperty` arrives through `Deterministic.Validity`'s import closure).
2. `validOnFrames_iff_deterministic {P} (hP : ∀ F M, P F → P (ShiftSet.ofModel F M).frame) (φ) : ValidOnFrames P φ ↔ ValidOnFrames (fun F => P F ∧ F.Deterministic) φ`.
3. Headline **`validIn_iff_validDetIn (fc : FrameClass) (φ : Formula) : ValidIn fc φ ↔ ValidDetIn fc φ`** — `DetSat fc` unfolds definitionally to the predicate in item 2, so this is a one-line application.
4. Headline **`valid_iff_valid_deterministic (φ) : Valid φ ↔ ∀ F, F.Deterministic → ∀ M τ t, TruthAt M τ t φ`** — the task description's statement, minus the retired `τ.IsTotal` hypothesis.
5. Optional: the per-model transfer as its own lemma (`∃` deterministic `F' M' τ'` with `TruthAt` agreeing on every `φ`), which is what distinguishes this route from the completeness detour; and an L⁺ corollary via `plusValidDetIn_iff_validDetIn_erasePlus` is **not** available in general (erasure is only truth-preserving on deterministic frames) — do not state one.

**Plumbing both modules need** (verified against `scripts/check-module-invariants.sh` and the READMEs):
- Aggregators: add one `import` line and one `## Modules` bullet each to `FormalSystem/Semantics/Correspondence.lean` and `FormalSystem/Metalogic/Deterministic.lean`.
- Directory READMEs: a table row in `Semantics/Correspondence/README.md` (columns File | Lines | Description — the `Lines` cell is part of a generated inventory, re-emit with `bash scripts/check-module-invariants.sh --emit-inventory`, verify with `--emit-inventory --check`) and in `Metalogic/Deterministic/README.md` (File | Role) plus a `## Key Results` bullet each.
- Parent READMEs carry counts/lists that will go stale: `FormalSystem/Semantics/README.md:59` says "`Galois`, …, `FwdRecBridge` (6 files)"; `FormalSystem/Metalogic/README.md:272-273` tabulates the Deterministic results. These two files are **not** in the task's declared `file_scope` — proposed as additions (see metadata `proposed_file_scope`).
- Root: `lake exe mk_all --lib FormalSystem`, then `--check`. Never hand-edit `FormalSystem.lean` (C33 compares it byte-for-byte).
- Header shape (C-linter under `--wfail`): copyright block, imports, then `/-! … -/` module docstring first; no `import Mathlib`. Lines ≤ 100 chars (the scratch runs tripped `linter.style.longLine` twice; the Appendix text is already wrapped).
- C9: no task numbers in either module or any README. C15: only recorded anchors (see Executive Summary). C19: every declaration needs a docstring (90% floor). C23/C26: `theorem` not `lemma`; no non-trailing underscores in `def` names (`UniformDwell`, `Static`, `galaxyFrame` comply). C17 dead-declaration scan: every helper above is consumed by a later declaration in the same module except the headlines; mention the headlines in a README (occurrence outside the defining file) to stay clear of it. C27: no stray `#print axioms` in the modules — axiom pinning, if wanted, belongs in a `Tests/BimodalTest/` module with `#guard_msgs` (pattern: `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`); optional.
- Optional: rows in `docs/theorem-index.md` (rigidity has no paper label yet → anchor column `—`; R1 under `app:deterministic` beside `logicDeterministicEqDeterminedValid`).

**Suggested phase decomposition**: (1) `SameLogic.lean` + aggregator + README + `mk_all`; (2) `Rigidity.lean` core (items 1-7) + aggregator + README + `mk_all`; (3) sharpness section; (4) parent READMEs, inventory re-emit, full `lake build --wfail`, `lean_verify` on the four headlines, `check-module-invariants.sh`. Phases 1 and 2 are independent.

## Decisions

- R2's statement in report 03 is **not false and needs no stronger hypothesis**; the deliverable is the theorem, with the Seriality dependence of the biconditional recorded and the core lemma stated at the weaker (density-free) hypothesis. Nothing is weakened.
- R1 is stated against the existing `ValidDetIn` vocabulary rather than the raw ∀-shape alone; the raw shape is kept as the `.Base` corollary because it is what the task description and the manuscript sentence use.
- `sat_ofModel_frame` is not imported (it would drag `Compactness.lean`'s ultraproduct closure into `Metalogic/Deterministic/`); its two-token body is inlined.
- `UniformDwell` uses the paper's cone-equality form `cone R w x₀ = {w}`; the bare-relation lemmas use the `⊆` form that `exists_uniform_radius_of_finite` concludes. The bridge between them is three lines inside `static_of_uniformDwell`.
- The induction-on-`n` reformulation of the chop is recorded as a flagged bookkeeping deviation from the source's minimal-`n` chain, not a different proof.
- No `user_decision` is raised: nothing here requires the user's judgment.

## Risks & Mitigations

- **`--wfail` lint noise** (long lines, unused variables in `rcases` patterns, `simp` flexibility). Mitigation: Appendix text is pre-wrapped; the `galR_limit` case split uses `simp only` with an explicit lemma list; run `lean_goal`/scoped guarded builds per phase.
- **`open`/namespace friction for `ShiftSet.frame_deterministic`** declared outside `ShiftSet.lean`. Mitigation: declare it inside `namespace FormalSystem.Semantics … end` within `SameLogic.lean` before opening `FormalSystem.Metalogic.Deterministic` (this exact layout compiled in scratch).
- **Task 543 may later want `frame_deterministic` inside `ShiftSet.lean`.** Mitigation: the name is already the one report 05 proposed; moving a one-line theorem upstream later is a rename-free relocation. Say so in its docstring without citing the task.
- **C18 duplicated-prose check** across READMEs. Mitigation: keep each README row to one sentence and do not paste the module docstring.
- **Concurrent sessions on `main`.** Mitigation: stage only the files in `file_scope` (+ the two proposed additions) by explicit path; regenerate `FormalSystem.lean` immediately before the commit that includes it and re-run `mk_all --check`, since another session adding a module would otherwise produce a root-file conflict.
- **`lean_run_code` elaborates without `--wfail` and without the project's linter set.** Mitigation: treat the Appendix as proved mathematics, not as lint-clean source.

## Tactic Survey Results

Proofs were written directly and compiled; no open goal remained to survey. Tactics that carried the load:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| chop induction step `x - ε ≤ n • ε` | `rw [succ_nsmul] at hn; exact sub_le_iff_le_add.mpr hn` | success | — |
| base case `x = 0` from `x ≤ 0 • ε` | `simpa using hn` | success | `zero_nsmul` via simp set |
| `0 < Finset.univ.inf' _ f` | `rw [Finset.lt_inf'_iff]` | success | — |
| `S.frame.TaskRel w d u ↔ u = S.sh w d` | `Iff.rfl` | **fail** (reflect-based fibre) | use `S.fibre_taskRel` |
| `fc.Sat F → fc.Sat (ofModel F M).frame` | `cases fc <;> exact h` | success | — |
| `(ofLex (n • x)).1 = n • (ofLex x).1` | `simp` | **fail** ("no progress") | induction on `n` with `succ_nsmul`, `ofLex_add`, `Prod.fst_add` |
| `galR` reflection law | `simp only [galR, ofLex_neg, Prod.fst_neg, ne_eq, neg_eq_zero]` | success | — |
| `¬ (1 ≤ 0)`-style lex contradictions | `simp at a; linarith` / `simp at a` | success | — |

## Context Extension Recommendations

- **Topic**: staleness of cross-repository research reports. **Gap**: nothing in `.claude/context/project/lean4/` tells an agent that a scratch proof quoted from an older report must be re-elaborated before it is planned against. **Recommendation**: a short pattern note ("re-run quoted scratch first; record what moved") under `context/project/lean4/patterns/`.
- **Topic**: reflect-presented frames. **Gap**: `fun _ _ _ => Iff.rfl` works for `ofReflective`-style class-membership hypotheses on the *presenting* relation but not against `F.TaskRel` of a literal `FrameOver` structure; the bridge lemmas (`fibre_taskRel`, `ofReflective_taskRel`, `permissiveFrame_taskRel`) are the supported route. **Recommendation**: one paragraph in the Semantics README or the lean4 context.

## Appendix

### A.1 R2 core, as elaborated (no `sorry`; headlines `[propext, Classical.choice, Quot.sound]`, `eq_of_rel_of_step` `[propext, Quot.sound]`)

```lean
import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Archimedean.Basic  -- `.Defs` suffices for `eq_of_rel_of_step`

namespace FormalSystem.Semantics
namespace TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

def Static {W : Type} (R : W → D → W → Prop) : Prop := ∀ w x u, R w x u ↔ w = u

def UniformDwell {W : Type} (R : W → D → W → Prop) : Prop :=
  ∃ x₀ : D, 0 < x₀ ∧ ∀ w, cone R w x₀ = {w}

theorem eq_of_rel_of_step [Archimedean D] {W : Type} {R : W → D → W → Prop}
    (hint : Interpolates R) {ε : D} (hε : 0 < ε)
    (hstep : ∀ w u y, 0 ≤ y → y ≤ ε → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := by
  intro w u x hx hR
  obtain ⟨n, hn⟩ := Archimedean.arch x hε
  induction n generalizing w x with
  | zero =>
    have h0 : x = 0 := le_antisymm (by simpa using hn) hx
    exact hstep w u x hx (by rw [h0]; exact hε.le) hR
  | succ n ih =>
    rcases le_total x ε with hle | hgt
    · exact hstep w u x hx hle hR
    · have hx' : 0 ≤ x - ε := sub_nonneg.mpr hgt
      have hR' : R w (ε + (x - ε)) u := by rwa [add_sub_cancel]
      obtain ⟨v, hwv, hvu⟩ := hint w u ε (x - ε) hε.le hx' hR'
      have hv : v = w := hstep w v ε hε.le le_rfl hwv
      subst hv
      refine ih v (x - ε) hx' hvu ?_
      rw [succ_nsmul] at hn
      exact sub_le_iff_le_add.mpr hn

theorem eq_of_rel_of_uniform_radius [DenselyOrdered D] [Archimedean D] {W : Type}
    {R : W → D → W → Prop} (hint : Interpolates R)
    {x₀ : D} (hx₀ : 0 < x₀) (hrad : ∀ w u y, |y| < x₀ → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := by
  obtain ⟨ε, hε, hεx⟩ := exists_between hx₀
  exact eq_of_rel_of_step hint hε fun w u y hy hyε hR =>
      hrad w u y (by rw [abs_of_nonneg hy]; exact lt_of_le_of_lt hyε hεx) hR

end TaskFrame

namespace FrameOver
open TaskFrame
variable {D : TemporalOrder}

theorem static_of_uniformDwell [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    (h : UniformDwell F.TaskRel) : Static F.TaskRel := by
  obtain ⟨x₀, hx₀, hcone⟩ := h
  have key := eq_of_rel_of_uniform_radius F.interpolates hx₀
    (fun w u y hy hR => by
      have : u ∈ cone F.TaskRel w x₀ := ⟨y, hy, hR⟩
      rw [hcone w] at this
      exact this)
  have fwd : ∀ w x u, F.TaskRel w x u → w = u := by
    intro w x u hR
    rcases le_total 0 x with hx | hx
    · exact (key w u x hx hR).symm
    · exact key u w (-x) (neg_nonneg.mpr hx) ((F.reflection w x u).mp hR)
  intro w x u
  refine ⟨fwd w x u, ?_⟩
  rintro rfl
  rcases le_total 0 x with hx | hx
  · obtain ⟨⟨u, hu⟩, _⟩ := F.serial w x hx
    have := fwd w x u hu
    subst this
    exact hu
  · obtain ⟨⟨u, hu⟩, _⟩ := F.serial w (-x) (neg_nonneg.mpr hx)
    have := fwd w (-x) u hu
    subst this
    exact (F.reflection w x w).mpr hu

theorem uniformDwell_of_static (F : FrameOver D) (h : Static F.TaskRel) :
    UniformDwell F.TaskRel := by
  obtain ⟨x₀, hx₀⟩ := exists_pos_of_nontrivial (D := ↑D)
  refine ⟨x₀, hx₀, fun w => ?_⟩
  ext u
  constructor
  · rintro ⟨y, _, hR⟩
    exact ((h w y u).mp hR).symm
  · rintro rfl
    exact ⟨0, by simpa using hx₀, (h u 0 u).mpr rfl⟩

theorem static_iff_uniformDwell [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D) :
    Static F.TaskRel ↔ UniformDwell F.TaskRel :=
  ⟨F.uniformDwell_of_static, F.static_of_uniformDwell⟩

theorem uniformDwell_of_finite (F : FrameOver D) [Finite F.WorldState] :
    UniformDwell F.TaskRel := by
  classical
  haveI := Fintype.ofFinite F.WorldState
  have hrad := fun w => exists_uniform_radius_of_finite F.TaskRel F.limit w
  choose f hf using hrad
  have huniv : (Finset.univ : Finset F.WorldState).Nonempty :=
    ⟨F.worldNonempty.some, Finset.mem_univ _⟩
  refine ⟨Finset.univ.inf' huniv f, ?_, fun w => ?_⟩
  · rw [Finset.lt_inf'_iff]; exact fun w _ => (hf w).1
  · ext u
    constructor
    · rintro ⟨y, hy, hR⟩
      exact (hf w).2 u y (lt_of_lt_of_le hy (Finset.inf'_le f (Finset.mem_univ w))) hR
    · rintro rfl
      refine ⟨0, ?_, F.nullity u⟩
      rw [abs_zero, Finset.lt_inf'_iff]; exact fun w _ => (hf w).1

theorem static_of_finite [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    [Finite F.WorldState] : Static F.TaskRel :=
  F.static_of_uniformDwell F.uniformDwell_of_finite

end FrameOver
end FormalSystem.Semantics
```

### A.2 R1, as elaborated (no `sorry`; headlines `[propext, Classical.choice, Quot.sound]`, helper `[propext, Quot.sound]`)

```lean
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Metalogic.Deterministic.Validity

namespace FormalSystem.Semantics
open FormalSystem.Syntax

theorem ShiftSet.frame_deterministic {D : TemporalOrder} (S : ShiftSet D) :
    S.frame.Deterministic :=
  fun w d => TaskFrame.fib_subsingleton_of_functional (f := S.sh)
    (fun w d u => S.fibre_taskRel w d u) w d

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Deterministic
open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.ProofSystem (FrameClass)

theorem validOnFrames_iff_deterministic {P : TaskFrame → Prop}
    (hP : ∀ (F : TaskFrame) (M : TaskModel F), P F → P (ShiftSet.ofModel F M).frame)
    (φ : Formula) :
    ValidOnFrames P φ ↔ ValidOnFrames (fun F => P F ∧ F.Deterministic) φ := by
  constructor
  · exact ValidOnFrames.mono (fun _ h => h.1)
  · intro h F hF M τ t
    have h3 := h _ ⟨hP F M hF, ShiftSet.frame_deterministic (ShiftSet.ofModel F M)⟩
      (ShiftSet.ofModel F M).model ((ShiftSet.ofModel F M).hist τ) t
    exact (ShiftSet.reverse_repr F M τ t φ).mp
      ((ShiftSet.forward_repr (ShiftSet.ofModel F M) τ t φ).mp h3)

theorem validIn_iff_validDetIn (fc : FrameClass) (φ : Formula) :
    ValidIn fc φ ↔ ValidDetIn fc φ :=
  validOnFrames_iff_deterministic (fun F M h => by cases fc <;> exact h) φ

theorem valid_iff_valid_deterministic (φ : Formula) :
    Valid φ ↔ ∀ (F : TaskFrame), F.Deterministic → ∀ (M : TaskModel F)
      (τ : WorldHistory F) (t : F.Duration), TruthAt M τ t φ := by
  rw [Valid, validIn_iff_validDetIn]
  exact ⟨fun h F hD M τ t => h.apply F trivial hD M τ t,
    fun h => ValidDetIn.of_forall fun F _ hD => h F hD⟩

end FormalSystem.Metalogic.Deterministic
```

### A.3 Sharpness witnesses, as elaborated (no `sorry`; standard axioms)

```lean
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.LexCarrier

open FormalSystem.Semantics

-- Density cannot be dropped: finite `W`, any successor order (so `ℤ`, which is Archimedean).
example {D : TemporalOrder} (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    ¬ ∀ w x u, (permissiveFrame D so nm).TaskRel w x u ↔ w = u := by
  intro h
  obtain ⟨d, hd⟩ := exists_ne (0 : ↑D)
  have := (h true d false).mp ((permissiveFrame_taskRel so nm _ _ _).mpr (Or.inl hd))
  exact Bool.noConfusion this

-- The Archimedean property cannot be dropped: two states over `ℚ ×ₗ ℚ`.
abbrev QQ : Type := ℚ ×ₗ ℚ

def galR (w : Bool) (d : QQ) (u : Bool) : Prop := (ofLex d).1 ≠ 0 ∨ w = u

theorem fst_nonneg {x : QQ} (hx : 0 ≤ x) : 0 ≤ (ofLex x).1 := by
  rcases (Prod.Lex.le_iff (x := (0 : QQ)) (y := x)).mp hx with h | h
  · exact le_of_lt h
  · exact le_of_eq h.1

theorem galR_refl : ∀ w d u, galR w d u ↔ galR u (-d) w := by
  intro w d u
  simp only [galR, ofLex_neg, Prod.fst_neg, ne_eq, neg_eq_zero]
  exact ⟨fun h => h.imp id Eq.symm, fun h => h.imp id Eq.symm⟩

theorem galR_comp : TaskFrame.Compositional galR := by
  intro w v x y hx hy
  have h1 := fst_nonneg hx
  have h2 := fst_nonneg hy
  simp only [galR, ofLex_add, Prod.fst_add]
  constructor
  · rintro (h | rfl)
    · by_cases hx0 : (ofLex x).1 = 0
      · refine ⟨w, Or.inr rfl, Or.inl ?_⟩
        rwa [hx0, zero_add] at h
      · exact ⟨v, Or.inl hx0, Or.inr rfl⟩
    · exact ⟨w, Or.inr rfl, Or.inr rfl⟩
  · rintro ⟨u, (h | rfl), (h' | rfl)⟩
    · left; exact ne_of_gt (add_pos_of_pos_of_nonneg (lt_of_le_of_ne h1 (Ne.symm h)) h2)
    · left; exact ne_of_gt (add_pos_of_pos_of_nonneg (lt_of_le_of_ne h1 (Ne.symm h)) h2)
    · left; exact ne_of_gt (add_pos_of_nonneg_of_pos h1 (lt_of_le_of_ne h2 (Ne.symm h')))
    · right; rfl

theorem galR_serial : TaskFrame.Serial galR :=
  fun w _ _ => ⟨⟨w, Or.inr rfl⟩, ⟨w, Or.inr rfl⟩⟩

theorem galR_limit : ∀ w u, (∀ x : QQ, 0 < x → ∃ y, |y| < x ∧ galR w y u) → u = w := by
  intro w u h
  have hpos : (0 : QQ) < toLex ((0 : ℚ), (1 : ℚ)) := by
    rw [Prod.Lex.lt_iff]; right; exact ⟨rfl, by norm_num⟩
  obtain ⟨y, hy, hR | hR⟩ := h _ hpos
  · exfalso
    apply hR
    have hy1 := (abs_lt.mp hy).1
    have hy2 := (abs_lt.mp hy).2
    rw [Prod.Lex.lt_iff] at hy1 hy2
    simp only [ofLex_neg, ofLex_toLex, Prod.fst_neg, neg_zero] at hy1 hy2
    rcases hy1 with a | a <;> rcases hy2 with b | b
    · exact absurd (lt_trans a b) (lt_irrefl _)
    · exact b.1
    · exact a.1.symm
    · exact b.1
  · exact hR.symm

noncomputable def galaxyFrame : FrameOver (TemporalOrder.of QQ) :=
  FrameOver.ofReflective Bool galR galR_refl galR_comp galR_serial galR_limit
    (TaskFrame.saturation_of_finite galR)

theorem galaxyFrame_not_static : ¬ ∀ w x u, galaxyFrame.TaskRel w x u ↔ w = u := by
  intro h
  have : galR true (toLex ((1 : ℚ), (0 : ℚ))) false := Or.inl (by simp)
  exact Bool.noConfusion ((h true _ false).mp (FrameOver.ofReflective_taskRel.mpr this))

theorem fst_nsmul (n : ℕ) (x : QQ) : (ofLex (n • x)).1 = n • (ofLex x).1 := by
  induction n with
  | zero => simp
  | succ n ih => rw [succ_nsmul, succ_nsmul, ofLex_add, Prod.fst_add, ih]

theorem qq_not_archimedean : ¬ Archimedean QQ := by
  intro h
  have hpos : (0 : QQ) < toLex ((0 : ℚ), (1 : ℚ)) := by
    rw [Prod.Lex.lt_iff]; right; exact ⟨rfl, by norm_num⟩
  obtain ⟨n, hn⟩ := h.arch (toLex ((1 : ℚ), (0 : ℚ))) hpos
  have hfst : (ofLex (n • (toLex ((0 : ℚ), (1 : ℚ)) : QQ))).1 = 0 := by
    rw [fst_nsmul]; simp
  rcases (Prod.Lex.le_iff).mp hn with a | a
  · rw [hfst] at a; simp at a; linarith
  · rw [hfst] at a; simp at a

example : DenselyOrdered QQ := inferInstance
```

Names in A.3 are scratch names; in the tree they need a namespace (`FormalSystem.Semantics.Rigidity` or similar), docstrings, and C26-compliant identifiers (`galR`/`QQ` are fine as `def`/`abbrev` names; consider `lexRatRel`, `LexRat`).

### A.4 Search and verification log

- `lean_run_code` ×9: R1 (pass, first run); R2 core with two `sorry` placeholders (pass) → found the Seriality dependence; R2 full (pass, first run); sharpness batch 1 (setup failure: `Mathlib.Algebra.Order.Group.Prod` absent from this checkout); batch 2 (two errors: `SuccOrder (TemporalOrder.of ℤ).carrier` not synthesized without `inferInstanceAs`; `Deterministic` needs `FrameProperty`); batch 3 (**`Iff.rfl` helper fails** — the stale-A.1 finding); generic `permissiveFrame` non-static (pass); `ℚ ×ₗ ℚ` frame (pass, one deliberate `sorry` for `¬ Archimedean`); `qq_not_archimedean` (fail on `simp`, then pass with `fst_nsmul`); `eq_of_rel_of_step` under `Archimedean.Defs` only (pass, choice-free).
- Greps: `Static`/`UniformDwell` name clashes (none); `frame_deterministic`/`valid_iff_valid_deterministic` (absent from the tree); `ValidDetIn` consumers; `sat_ofModel_frame`; `permissiveFrame`; `×ₗ` users; C15 record blocks; manuscript labels (`rigidity`: none; "same logic" appears only in commented-out text near `cor:no-characterization`).
- Baseline: `lake exe mk_all --lib FormalSystem --check` exit 0 at `61b2dc82e`.
- Not done: no `lake build` (nothing was written to the build graph); no `lean_verify` (it needs the declarations in a file); `lean_leansearch`/`lean_loogle` not needed — every Mathlib name was confirmed by elaboration.
