# Implementation Plan: Galois-closure implementation for the frame-class layer

- **Task**: 513 - Uniform frame faithfulness predicate
- **Status**: [NOT STARTED]
- **Effort**: 18 hours (15 hours excluding the two optional phases 10-11)
- **Dependencies**: Task 512, Task 507 (both landed)
- **Research Inputs**: specs/513_uniform_frame_faithfulness_predicate/reports/01_galois-closure-implementation.md
- **Artifacts**: plans/01_galois-closure-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build the frame-class Galois-closure layer: a single `Th`/`Mod` adjunction over bundled
`TaskFrame`s, indicator-axiom exactness for the Dense and paper-Discrete classes, the
duration-level (T1) correspondence statements with their witness frames, and the two non-closure
witnesses that show `Sat .Discrete` and `Sat .Dedekind` are strictly smaller than the model
classes of their axiom sets. Every load-bearing lemma below was compiled sorry-free during
research; the implementation is transplant-and-restate plus glue, not discovery. Definition of
done: all phases green under `lake build`, no `sorry`/`admit`/`native_decide`, every theorem
stated over bundled frames with `FrameClass.Sat` from the indexed-validity work.

### Research Integration

The report (`reports/01_galois-closure-implementation.md`) probed all eight construction risks
against the live tree with `lean_run_code`; seven compiled sorry-free. Integrated directly:

- The `Galois.lean` module body, including the extra `galoisClosed_of_indicator` lemma that
  collapses both closure corollaries to one-liners (report §2).
- IND-D / IND-F at ~10 lines each, with no ordered-group homogeneity argument —
  `DenselyOrdered` is the falsity condition of `¬X⊤` on the nose (report §3.2).
- `LoopingDuration.truthAt_add_period` (`Metalogic/Independence/LoopingDuration.lean:98`)
  instantiated at `π := s - t` as the whole of static-frame time-invariance, and the
  constant-truth `untl` calculus built on it that collapses deliverable (5)'s axiom-by-axiom
  check into rewriting (report §4.1-4.2).
- The complete translation-frame `FrameOver` value, all seven obligations, via
  `TaskFrame.limit_of_shift` and ClockFrame's spherical argument (report §6.2).
- `rat_not_complete` (25 lines; Mathlib has no off-the-shelf statement) and the `ℤ ×ₗ ℤ` facts:
  all four `TemporalOrder` instances resolve by `inferInstance`, least positive element is
  `toLex (0,1)`, non-Archimedean via `(1,0)` dominating every `n • (0,1)` (report §4.3).
- The `Mod`-of-axiom-set vs `Mod`-of-theorem-set decision, resolved in favour of `AxiomSet`
  with a semantic upper bound (report §5).

### Corrections to the dispatch, carried into every phase

1. **`FrameClass.Complete` does not exist.** The class is `FrameClass.Dedekind`
   (`Semantics/FrameClassValidity.lean:112`). The indexed-validity work declined the rename and
   recorded a naming deviation of record in two docstrings, because "complete" is reserved for
   proof-theoretic completeness. Read every `.Complete` in the task brief as `.Dedekind`. Do not
   rename as part of this task.
2. **The paper-Discrete closure corollary is stated over `IsDiscrete`, not `Sat .Discrete`.**
   `Sat .Discrete` is `IsSuccArchDiscrete` (the ℤ-time narrowing), which is strictly stronger and
   is *not* Galois-closed — that is exactly what phase 6's witness refutes. Stating the corollary
   over `Sat .Discrete` would contradict phase 6.
3. **The probe files are pre-512.** Porting is a mechanical rename pass:
   `TaskFrame D` -> `FrameOver D`, `TaskFrame.staticFrame` -> `FrameOver.staticFrame`,
   `nonempty` -> `worldNonempty`. This is what "transplant and restate" means in the acceptance
   criteria; it is not re-proof.
4. **Do not use `Semantics.ValidDedekind`** anywhere in this task — it is `ValidOnFrames
   TaskFrame.IsComplete` (the bare clause), not `ValidIn .Dedekind`. Both docstrings warn about
   the mismatch.

### Design decision, already resolved — do not reopen

`Mod(TM⁺_f)` was ambiguous between `Mod (AxiomSet fc)` and `Mod` of the theorem set. **Both
sandwiches are stated over `AxiomSet`, and the upper bound is obtained semantically.** Do not
plan or attempt the theorem reading: it requires a single-frame
`F.ValidOn φ → F.ValidOn φ.swapTemporal` for the `temporal_duality` rule, which does not exist
and is false in general (a frame need not be closed under time reversal). Since
`AxiomSet fc ⊆ {φ | Derivable fc [] φ}`, the `AxiomSet` sandwiches are the *stronger* statements
anyway. **If any phase finds itself needing that lemma, stop and report a blocker rather than
attempting it.**

### Two defects found in the research decomposition, corrected here

The research proposed nine phases anchored to already-compiled lemmas. Two of its anchors are
already partly in the tree, and following it verbatim would create duplicates:

1. **`succIndicator` already exists.** `Theorems/DiscreteUnfolding.lean:90` is
   `def succIndicator : ⊢[FrameClass.Discrete] Formula.next Formula.top`, proved by exactly the
   `serial_future` + `prior_UZ` + `guardMono` route the report describes as a new 12-line
   `nextTopThm` (including the `guardMono` step the original dispatch's "prior_UZ +
   serial_future" phrasing omits — `prior_UZ` at `⊤` yields guard `⊤.neg`, not `⊥`). Phase 3
   therefore **generalizes the existing declaration in place** to `{fc}` with
   `(h : FrameClass.Discrete ≤ fc)` rather than adding a second copy.
2. **Do not define a third `nextTop`.** `Formula.next Formula.top` is the Syntax-level spelling
   (`Syntax/Formula.lean:511`: `def next (φ) := Formula.untl Formula.bot φ`), and the tree
   already carries two Metalogic-local copies (`Chronicle/ChronicleToCountermodelBasic.lean:180`
   and `WeakCanonical/ReflexiveCanonical.lean:694`). Use `Formula.next Formula.top` directly in
   all new code. The pre-existing duplication is out of scope and must not be refactored here.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context and `roadmap_flag` is absent, so no roadmap
review/update phases are included. `specs/ROADMAP.md` exists but was not consulted as an input;
this plan neither reads it as authority nor modifies it.

## Goals & Non-Goals

**Goals**:
- One `Th`/`Mod` adjunction pair over bundled `TaskFrame`s, with antitonicity, the closure
  identities, `GaloisClosed`, and the `galoisClosed_of_indicator` factoring — no per-class copies.
- Indicator exactness: `F.ValidOn (Formula.next Formula.top).neg ↔ DenselyOrdered F.Duration`,
  its `X⊤`/discrete dual, and `↔ F.IsDiscrete`; plus the two closure corollaries.
- The `Derivable`-level `X⊤` result available `{fc}`-polymorphically at `.Discrete ≤ fc`.
- Duration-level (T1) correspondence for DF/DN/CO, with the translation frame and the two-state
  permissive frame as (⇒) witnesses, and the (T0) refutation recorded next to it.
- Both non-closure witnesses and both sandwich corollaries, over `AxiomSet`.
- The FwdRec port: atomic half at arbitrary `D` (required), schema half at ℤ (optional).
- Deliverable (6)'s non-goals recorded as a module docstring section.

**Non-Goals** (deliverable (6), preserved verbatim from the task brief):
- "closed-form characterizations of Mod(TM+_f) and Mod(TM+_c) are OPEN and not promised —
  evidence: no variable-free BL+ sentence separates Z from Z ×ₗ Z or Q from R, and sep has no
  correspondent."

**Additional non-goals** (scope fences, not deliverable (6)):
- Renaming `FrameClass.Dedekind` to `FrameClass.Complete`.
- Any general `Derivable → ValidOn` single-frame bridge, or any single-frame `swapTemporal`
  closure lemma.
- Consolidating the two pre-existing Metalogic-local `nextTop` definitions.
- Any change to `FormalSystem/Semantics/TaskFrame.lean` beyond what phase 7's frame
  constructions strictly require (prefer a new module).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3's generalization of `succIndicator` breaks its two in-file call sites (`DiscreteUnfolding.lean:125`, `:463`) | M | H | Generalize the body once into the `{fc}` form and redefine `succIndicator` as the `le_rfl` instantiation, so call sites are untouched. Verify with `lake env lean` on that one file before the full build. |
| An implementer reaches for `Mod` of a theorem set and hits the `temporal_duality` wall | H | M | Explicitly forbidden above and restated in phases 5, 6. Contract: stop and report a blocker; do not attempt a single-frame `swapTemporal` lemma. |
| The paper-Discrete corollary is accidentally stated over `Sat .Discrete` | H | M | Correction 2 above; phase 2's verification step requires grepping the new file for `Sat .Discrete` and confirming zero hits in the closure corollary. |
| New module placement violates `scripts/check-module-invariants.sh` (unreachable module / aggregator registration) | M | M | Every new-module phase registers the module in its enclosing aggregator (`Semantics.lean`, `Metalogic/Independence.lean`) in the same phase and runs the invariant script before closing. |
| Phase 7 declares `SuccOrder`/`NoMaxOrder` glue as global instances and perturbs elaboration tree-wide | M | M | Phase 7 carries verification tier `full`. Prefer `local instance` or plain lemmas returning the structure; only promote to a global instance with an explicit justification in the docstring. |
| Phase 10's `Walk`/`MinCyc` transcription (~300 lines) overruns one agent run | M | M | Phase 10 and 11 are OPTIONAL and split from each other; either may close `[PARTIAL]` and resume without blocking phases 1-9. |
| `ℚ` incompleteness proof drags in unexpected Mathlib API | L | L | Compiled during research at 25 lines with axioms `[propext, Classical.choice, Quot.sound]`; the witness set and both Mathlib lemmas (`Nat.Prime.irrational_sqrt`, `exists_rat_btwn`) are named in the report. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4, 7, 9 | -- |
| 2 | 2, 10 | 1 (for 2); 9 (for 10) |
| 3 | 5, 6, 8, 11 | 1, 2, 4 (for 5 and 6); 2, 7 (for 8); 1, 9, 10 (for 11) |

Phases within the same wave can execute in parallel.

---

### Phase 1: Galois module [NOT STARTED]

**Goal**: `FormalSystem/Semantics/Correspondence/Galois.lean` exists, is registered, and carries
the whole `Th`/`Mod` adjunction plus the reified axiom and schema sets.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Correspondence/Galois.lean` importing
      `FormalSystem.Semantics.Validity` (which transitively supplies `TaskFrame.ValidOn`,
      `FrameClass.Sat`, and `ProofSystem.Axioms` — this opens no new import seam, since
      `FrameClassValidity.lean` is already the single documented `Semantics → ProofSystem` edge).
- [ ] `def Th (K : Set TaskFrame) : Set Formula` and `def Mod (S : Set Formula) : Set TaskFrame`.
- [ ] `th_anti`, `mod_anti`, `subset_mod_th`, `subset_th_mod`, `mod_th_mod`, `th_mod_th` — each
      one term.
- [ ] `def GaloisClosed (K : Set TaskFrame) : Prop := Mod (Th K) = K` and `galoisClosed_mod`.
- [ ] `galoisClosed_of_indicator (φ) (hmem : φ ∈ Th K) (hback : ∀ F, F.ValidOn φ → F ∈ K)` — the
      indicator mechanism factored exactly once. This is what "no per-class copies" means.
- [ ] `def AxiomSet (fc : FrameClass) : Set Formula := {φ | ∃ h : Axiom φ, h.minFrameClass ≤ fc}`
      (`Axiom` is an inductive family indexed by `Formula`, so the spec's set-builder must be
      reified this way).
- [ ] `def densitySchema : Set Formula :=
      {φ | ∃ ψ, φ = ψ.allFuture.allFuture.imp ψ.allFuture}`.
- [ ] Module docstring section recording deliverable (6)'s non-goals verbatim (see Non-Goals
      above), citing the `sep` docstring's Reynolds quotation in `ProofSystem/Axioms.lean`.
- [ ] Add `import FormalSystem.Semantics.Correspondence.Galois` to
      `FormalSystem/Semantics.lean`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: ~120 lines including docstrings; the one enumerated direct dependent is
`FormalSystem/Semantics.lean`. Confirm at implementation time by `lake build` and by checking
that no other module needs an import edit; if a second dependent appears, record it before
proceeding.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Galois.lean` - new module (whole content above)
- `FormalSystem/Semantics.lean` - one import line

**Verification**:
- `lake build` green; `lake env lean FormalSystem/Semantics/Correspondence/Galois.lean` reports
  no errors and no new warnings.
- `bash scripts/check-module-invariants.sh` shows no new unreachable module.
- `grep -n "sorry\|admit\|native_decide"` on the new file returns nothing.
- `Set TaskFrame` elaborates without universe trouble (`TaskFrame : Type 1`, so
  `Set TaskFrame : Type 1`; nothing needs a `Type`-valued frame class).

---

### Phase 2: Indicator exactness and the two closure corollaries [NOT STARTED]

**Goal**: The `¬X⊤`/`X⊤` indicator biconditionals, and `Sat .Dense` and `{F | F.IsDiscrete}` shown
Galois-closed as one-liners over `galoisClosed_of_indicator`.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Correspondence/Indicator.lean` importing phase 1's module.
- [ ] `validOn_neg_nextTop_iff (F) : F.ValidOn (Formula.next Formula.top).neg ↔
      DenselyOrdered F.Duration`. Mechanism: `TruthAt M τ t (untl ⊥ ⊤)` unfolds to
      `∃ s, t < s ∧ True ∧ ∀ r, t < r → r < s → False`, which mentions no atom — the valuation is
      never consulted, and `DenselyOrdered` is that falsity condition on the nose. No
      ordered-group homogeneity argument. `Nonempty (TaskFrame.HF F)` for the (⇒) reading comes
      from `TaskFrame.hF_nonempty_of_frameAxioms` (`Validity.lean:236`); the model witness is
      `TaskModel.allFalse`.
- [ ] `validOn_nextTop_iff (F) : F.ValidOn (Formula.next Formula.top) ↔
      ∀ x : F.Duration, ∃ y, IsLeast {z | x < z} y`.
- [ ] `validOn_nextTop_iff_isDiscrete (F) : F.ValidOn (Formula.next Formula.top) ↔ F.IsDiscrete`.
      This needs one step past the raw statement: `TaskFrame.IsDiscrete`
      (`FrameProperty.lean:89`) carries the paper's guard `(∃ y, x < y) →`, discharged by
      `TaskFrame.exists_pos_of_nontrivial` (`TaskFrame.lean:957`), available because `Nontrivial`
      is a *field* of `TemporalOrder` (`TemporalOrder.lean:86`). Without that step the two are
      inequivalent on a trivial carrier.
- [ ] Corollary `GaloisClosed (FrameClass.Sat FrameClass.Dense)`: instantiate
      `galoisClosed_of_indicator` at `φ := (Formula.next Formula.top).neg`, `hmem` from `.mpr`,
      `hback` from `.mp`. Note in the docstring that no proof theory is involved — the
      dependence on `dense_indicator` being an axiom is rhetorical only.
- [ ] Corollary `GaloisClosed {F : TaskFrame | F.IsDiscrete}`: same, at
      `φ := Formula.next Formula.top`, via `validOn_nextTop_iff_isDiscrete`. Docstring must state
      explicitly that this is the **paper-Discrete** class and NOT `Sat .Discrete`, which is
      `IsSuccArchDiscrete` and is refuted as Galois-closed by phase 6.
- [ ] Register in `FormalSystem/Semantics.lean`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: ~90 lines; three biconditionals at roughly 10 lines of proof each plus two
one-line corollaries and docstrings. Confirm at implementation time; if any biconditional exceeds
~25 lines, stop and re-read report §3.1-3.2 before improvising — the compiled versions are short.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Indicator.lean` - new module
- `FormalSystem/Semantics.lean` - one import line

**Verification**:
- `lake build` green; new file sorry-free.
- `Axiom.dense_indicator`'s `minFrameClass` is `.Dense` by `rfl` (spot-check, since the
  corollary's framing depends on it).
- `grep -n "Sat FrameClass.Discrete\|Sat .Discrete" FormalSystem/Semantics/Correspondence/Indicator.lean`
  returns nothing — the paper-Discrete corollary must not be stated over the ℤ-time narrowing.

---

### Phase 3: `{fc}`-polymorphic `X⊤` at `.Discrete ≤ fc` [NOT STARTED]

**Goal**: The existing `succIndicator` is available at any `fc` with `FrameClass.Discrete ≤ fc`,
with no duplicated proof and no call-site churn.

**Tasks**:
- [ ] Read `FormalSystem/Theorems/DiscreteUnfolding.lean:88-97` and confirm the current shape:
      `def succIndicator : ⊢[FrameClass.Discrete] Formula.next Formula.top`, proved from
      `Axiom.serial_future` + `Combinators.topThm` (step 1), `Axiom.prior_UZ Formula.top`
      (step 2), and `Combinators.guardMono` with `topNegImpBot` (step 3, which closes the
      `⊤.neg` vs `⊥` guard gap).
- [ ] Generalize the body once into
      `def succIndicatorAt {fc : FrameClass} (h : FrameClass.Discrete ≤ fc) :
      ⊢[fc] Formula.next Formula.top`, replacing each `(by decide)` side condition with a
      transitivity through `h`.
- [ ] Redefine `succIndicator := succIndicatorAt le_rfl` so the two existing in-file call sites
      (`:125`, `:463`) are untouched.
- [ ] Update the file's `## Main results` docstring block and the "Why `FrameClass.Discrete` is
      essential here" section to describe both declarations, preserving the existing argument
      that a `{fc}`-*uniform* version (with no `h`) would make the dense system inconsistent —
      `succIndicatorAt` is guarded by `h`, so it does not.
- [ ] Update `FormalSystem/Theorems.lean:36`'s summary line if it enumerates the declarations.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: exactly two call sites of `succIndicator` inside
`DiscreteUnfolding.lean` (`:125`, `:463`), plus five docstring mentions in that file and one in
`Theorems.lean`. Confirm at implementation time with
`grep -rn "succIndicator" --include=*.lean FormalSystem/ Tests/` before editing; if a call site
outside `DiscreteUnfolding.lean` appears, enumerate it and widen the dependent set.

**Files to modify**:
- `FormalSystem/Theorems/DiscreteUnfolding.lean` - generalize `succIndicator`, update docstrings
- `FormalSystem/Theorems.lean` - summary line, if it enumerates declarations

**Verification**:
- `lake env lean FormalSystem/Theorems/DiscreteUnfolding.lean` clean before the full build.
- `lake build` green.
- `#print axioms succIndicatorAt` shows a clean profile (research measured `[propext]` for the
  equivalent standalone lemma).
- No new declaration named `nextTop` was introduced anywhere (see Defect 2 above).

---

### Phase 4: Static-frame kit and the constant-truth `untl` calculus [NOT STARTED]

**Goal**: Static-frame time-invariance at arbitrary `D`, and the constant-truth calculus that
turns every later axiom check into a rewrite.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/StaticFrame.lean`, importing
      `FormalSystem.Metalogic.Independence.LoopingDuration`.
- [ ] `staticFrame_looping (W) [Nonempty W] {π : D} (hπ : π ≠ 0) :
      LoopingDuration (FrameOver.staticFrame W (D := D)) π := ⟨hπ, fun _ _ => ⟨Eq.symm, Eq.symm⟩⟩`.
      For `staticFrame`, `TaskRel w d u ↔ w = u` at *every* `d`, so every nonzero `π` loops.
- [ ] `static_time_invariant`: instantiate `LoopingDuration.truthAt_add_period`
      (`Metalogic/Independence/LoopingDuration.lean:98`) at `π := s - t`. It carries no
      positivity hypothesis on `π`, so this is three lines.
- [ ] `static_untl_iff (W) [Nonempty W] (M) (τ) (hτ : τ.IsTotal) (ψ φ) (t) :
      TruthAt M τ t (Formula.untl ψ φ) ↔
      (TruthAt M τ t φ ∧ (TruthAt M τ t ψ ∨ ∃ y, IsLeast {z : D | t < z} y))`.
- [ ] `static_untl_iff_dense [DenselyOrdered D] : … ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ)`.
- [ ] `static_untl_iff_disc (hdisc : ∀ x : D, ∃ y, IsLeast {z : D | x < z} y) : … ↔ TruthAt M τ t φ`.
- [ ] The three `snce` mirrors — same proofs with the order reversed.
- [ ] `static_validates_z1`, which needs only `static_time_invariant`, not the calculus.
- [ ] Docstring recording the scoping finding: the ~400-line `Walk`/`MinCyc`/`periodic`
      apparatus of `03_probes.lean` exists to handle frames whose histories have *different*
      periods; `staticFrame` needs none of it. The right pattern is `02_probes.lean`'s Probe F
      (`density_of_loopingDuration`), not `03_probes`' `density_of_hist_periodic`.
- [ ] Register in `FormalSystem/Metalogic/Independence.lean`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: ~140 lines; three `untl` lemmas plus three `snce` mirrors plus two
invariance lemmas. Confirm at implementation time. If the `snce` mirrors do not fall out of the
same proof skeleton with the order reversed, record why before writing a second skeleton.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/StaticFrame.lean` - new module
- `FormalSystem/Metalogic/Independence.lean` - one import line

**Verification**:
- `lake build` green; new file sorry-free.
- Each of the six calculus lemmas is stated at arbitrary `D`, not at a fixed carrier — grep the
  file for hard-coded `ℚ`, `ℤ`, or `ℝ` and confirm zero hits.
- `bash scripts/check-module-invariants.sh` shows no new unreachable module.

---

### Phase 5: Witness (a) — `staticFrame` over ℚ, and the Dedekind sandwich [NOT STARTED]

**Goal**: `staticFrame ℚ ∈ Mod (AxiomSet .Dedekind) \ Sat .Dedekind`, and
`Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind) ⊆ Sat .Dense`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/RationalWitness.lean`.
- [ ] `rat_not_complete : ¬ (∀ s : Set ℚ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)` — witness
      `{q : ℚ | (q:ℝ) < √2}`, via `Nat.Prime.irrational_sqrt` and `exists_rat_btwn`. Mathlib has
      no off-the-shelf statement; this must be written.
- [ ] Membership in `Mod (AxiomSet .Dedekind)`: work axiom-by-axiom **through the calculus**, not
      by hand. `DenselyOrdered ℚ` is an instance, so `b(U(ψ,φ)) = b(φ) ∧ b(ψ)`, hence
      `b(K⁺φ) = b(K⁻φ) = b(φ)` and `b(Gφ) = b(φ)`, and: `density` (`GGφ→Gφ`) reduces to
      `b(φ) → b(φ)`; `dense_indicator` is immediate from phase 2's IND-D; `prior_U_gap`'s
      antecedent `U(φ,⊤) ∧ F(¬φ)` reduces to `b(φ) ∧ ¬b(φ)` and is vacuous, `prior_S_gap`
      dually; `sep`'s `b(U(¬φ,φ)) = b(φ) ∧ ¬b(φ) = ⊥` makes the second conjunct of the antecedent
      `⊤`, so the whole axiom reduces to `b(φ) → b(φ)`. Base axioms need no argument — they are
      sound on every task frame, so `validOn_of_valid` (`Validity.lean:387`) applies.
- [ ] Non-membership in `Sat .Dedekind`: `Sat .Dedekind = IsDedekind = IsDense ∧ IsComplete`, and
      `rat_not_complete` kills the second conjunct.
- [ ] Sandwich: `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)` from the witness, and
      `Mod (AxiomSet .Dedekind) ⊆ Sat .Dense` because `dense_indicator ∈ AxiomSet .Dedekind`
      (its `minFrameClass` is `.Dense ≤ .Dedekind`), so phase 2's `validOn_neg_nextTop_iff` gives
      `DenselyOrdered`.
- [ ] Register in `FormalSystem/Metalogic/Independence.lean`.

**Timing**: 2 hours

**Depends on**: 1, 2, 4

**Verification Tier**: interface

**Scope Hypothesis**: ~180 lines, of which ~25 are `rat_not_complete`. The axiom-membership check
is asserted to be *rewriting through the phase 4 calculus*, not a per-axiom manual argument;
confirm at implementation time by measuring the membership proof — if it exceeds ~60 lines the
calculus is not being used and the phase should stop and re-read report §4.2.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/RationalWitness.lean` - new module
- `FormalSystem/Metalogic/Independence.lean` - one import line

**Verification**:
- `lake build` green; sorry-free.
- `#print axioms rat_not_complete` — research measured `[propext, Classical.choice, Quot.sound]`;
  anything beyond that is a signal to investigate.
- The sandwich is stated over `AxiomSet .Dedekind`, never over a theorem set. If a step appears
  to need `F.ValidOn φ → F.ValidOn φ.swapTemporal`, **stop and report a blocker**.
- No occurrence of `ValidDedekind` in the new file.

---

### Phase 6: Witness (b) — `staticFrame` over ℤ ×ₗ ℤ, and the Discrete sandwich [NOT STARTED]

**Goal**: `staticFrame (ℤ ×ₗ ℤ) ∈ Mod (AxiomSet .Discrete) \ Sat .Discrete`, and
`Sat .Discrete ⊊ Mod (AxiomSet .Discrete) ⊆ {F | F.IsDiscrete}`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/LexIntWitness.lean`.
- [ ] `TemporalOrder.of (ℤ ×ₗ ℤ)`: all four instances (`AddCommGroup`, `LinearOrder`,
      `IsOrderedAddMonoid`, `Nontrivial`) resolve by `inferInstance`. Declare no new instances.
- [ ] Discreteness: `IsLeast {x | 0 < x} (toLex (0,1))`.
- [ ] `¬ Archimedean (ℤ ×ₗ ℤ)`: `(1,0)` dominates every `n • (0,1) = (0,n)`.
- [ ] Non-membership in `Sat .Discrete`: go through `DurationClassification.intIso`
      (`DurationClassification.lean:260`, `[SuccOrder D] [IsSuccArchimedean D] → D ≃+o ℤ`), so
      `IsSuccArchDiscrete D → Nonempty (D ≃+o ℤ)`, refuted by the non-Archimedean fact.
      **Do not attempt to refute the `∃ (_ : SuccOrder D)` existential directly** even though
      `Subsingleton (SuccOrder (ℤ ×ₗ ℤ))` is an instance — the `intIso` route is shorter and uses
      tree assets.
- [ ] Membership in `Mod (AxiomSet .Discrete)` through the phase 4 calculus: discreteness gives
      `b(U(ψ,φ)) = b(φ)`, hence `b(Fφ) = b(Gφ) = b(φ)`; `prior_UZ` (`Fφ → U(¬φ,φ)`) reduces to
      `b(φ) → b(φ)`, `prior_SZ` dually; `z1` is `static_validates_z1` from phase 4. Base axioms
      via `validOn_of_valid`.
- [ ] `validOn_nextTop_of_mem_mod_discrete {F} (hF : F ∈ Mod (AxiomSet .Discrete)) :
      F.ValidOn (Formula.next Formula.top)` — replay phase 3's three syntactic steps at the
      `ValidOn` level, which is trivially closed under modus ponens and
      `temporal_necessitation`. This is the semantic route; it does **not** depend on phase 3,
      and that independence is deliberate.
- [ ] Sandwich: `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)` from the witness, and
      `Mod (AxiomSet .Discrete) ⊆ {F | F.IsDiscrete}` from the previous item plus phase 2's
      `validOn_nextTop_iff_isDiscrete`.
- [ ] Register in `FormalSystem/Metalogic/Independence.lean`.

**Timing**: 2 hours

**Depends on**: 1, 2, 4

**Verification Tier**: interface

**Scope Hypothesis**: ~160 lines, with zero new `instance` declarations (all four `TemporalOrder`
components resolve by `inferInstance`). Confirm at implementation time by grepping the new file
for `^instance` and `^ *instance` — a hit means the research's instance finding did not hold and
the tier must be raised to `full`.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean` - new module
- `FormalSystem/Metalogic/Independence.lean` - one import line

**Verification**:
- `lake build` green; sorry-free.
- Upper bound is `{F | F.IsDiscrete}`, not `Sat .Discrete` — the two are different and the phase
  proves they are different.
- The sandwich is stated over `AxiomSet .Discrete`, never a theorem set. If a step appears to
  need `F.ValidOn φ → F.ValidOn φ.swapTemporal`, **stop and report a blocker**.

---

### Phase 7: (T1) witness frames — translation frame and permissive frame [NOT STARTED]

**Goal**: Both (⇒) witness frames exist as bundled `FrameOver` values, with the two glue lemmas
they need.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Correspondence/DurationFrames.lean`.
- [ ] The translation frame (`W = D`, `w ⇒_x u ↔ u = w + x`), for `app:discrete`/`app:complete`.
      All seven `FrameOver` obligations: `comp` via `TaskFrame.comp_of`
      (`TaskFrame.lean:481`) with interpolant `w + x`; `limit` via `TaskFrame.limit_of_shift id`
      (`TaskFrame.lean:846` — its docstring names exactly this flow-style shape as its intended
      use); `spherical` by copying `ClockFrame.clockRel_spherical`'s argument
      (`sInter_nonempty_of_directed_of_univ_or_singleton` plus fibre-subsingleton), which
      transfers because the translation relation is deterministic and so has singleton fibres.
- [ ] The two-state permissive frame (`W = Bool`, `w ⇒_d u ↔ d ≠ 0 ∨ w = u`), for `app:dense` —
      this is `03_probes.lean`'s `freeFrame` at `W = Bool`, already generic in `D`. Apply the
      pre-512 rename pass (`TaskFrame D` -> `FrameOver D`, `nonempty` -> `worldNonempty`) and
      give it a `natFrame`-style docstring.
- [ ] Glue lemma: `NoMaxOrder D` from `Nontrivial` + ordered group, via
      `TaskFrame.exists_pos_of_nontrivial` (~8 lines).
- [ ] Glue lemma: `SuccOrder D` from non-density, via
      `Semantics.duration_dense_or_least_pos` (`DurationClassification.lean:283`, already in the
      tree: `DenselyOrdered D ∨ ∃ d, IsLeast {x | 0 < x} d`) fed into
      `SuccOrder.ofSuccLeIff (fun x => x + p)` (~8 lines). Both are needed because
      `TaskFrame.limit_of_permissive` (`TaskFrame.lean:1180`) carries
      `[SuccOrder D] [NoMaxOrder D]`, and for the (T1)-DN (⇒) direction the hypothesis "`D` is
      not dense" supplies both.
- [ ] Prefer `local instance` or plain lemmas for the two glue results; promote to a global
      instance only with an explicit justification in the docstring.
- [ ] Register in `FormalSystem/Semantics.lean`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~200 lines: ~35 for the translation frame's seven obligations (compiled
during research), ~100 for the `freeFrame` port, ~16 for the two glue lemmas, rest docstrings.
Confirm at implementation time. The `full` tier is chosen because the glue lemmas have global
elaboration surface if declared as instances; if the implementation keeps both `local`, record
that and the tier's blind-spot exposure is unchanged (the final gate still runs in full).

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - new module
- `FormalSystem/Semantics.lean` - one import line

**Verification**:
- `lake build` green, full job count (do not accept a scoped replay); sorry-free.
- No global `instance` added without a docstring justification; `grep -n "^instance"` on the new
  file reviewed explicitly.
- Both frames elaborate as `FrameOver D` values with `worldNonempty`, confirming the pre-512
  port landed.

---

### Phase 8: (T1) duration-level biconditionals and the (T0) refutation record [NOT STARTED]

**Goal**: The three duration-level correspondence statements for DF/DN/CO in the paper's proven
(T1) form, with the (T0) refutation recorded beside them.

**Tasks**:
- [ ] Append to `FormalSystem/Semantics/Correspondence/DurationFrames.lean`.
- [ ] Statement shape, for each of DF/DN/CO:
      `(D : TemporalOrder) : (∀ F : FrameOver D, F.toTaskFrame.ValidOn ax) ↔ P D`. Quantify over
      the fibre, not over bundled frames with a `Duration` equation:
      `FrameOver.toTaskFrame` is `@[reducible]` with `(F.toTaskFrame).Duration = D` by `rfl`
      (`TaskFrame.lean:1633`), so this needs no transport; a `F.Duration = D` formulation would.
- [ ] DF (discrete) and CO (complete) (⇒) directions via the translation frame; DN (dense) (⇒)
      via the permissive frame with the phase 7 glue lemmas. (⇐) directions reuse phase 2's
      `validOn_nextTop_iff` / `validOn_neg_nextTop_iff` where they apply.
- [ ] Record the (T0) adjudication explicitly in a docstring section, since it must not be
      silently dropped: the per-frame reading (T0) `F ⊨ ax ↔ P F.Duration` is **false** in its
      (⇒) direction — `staticFrame` over ℤ validates the whole density schema while ℤ is not
      dense. Only (T1) is true, and it is what the paper's proofs actually conclude. State (T1);
      record the refutation of (T0) next to it, citing report §2.4 of the definitional review.

**Timing**: 1.5 hours

**Depends on**: 2, 7

**Verification Tier**: local

**Scope Hypothesis**: ~150 lines across three biconditionals, i.e. three separate (⇒) arguments;
this is the phase's medium-risk element. Confirm at implementation time — if any single (⇒)
direction exceeds ~80 lines, close the phase `[PARTIAL]` with the completed biconditionals rather
than overrunning.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - append (already registered by
  phase 7, so no aggregator edit)

**Verification**:
- `lake build` green; sorry-free.
- All three statements use the fibre-quantified (T1) shape; grep the file for `Duration =` and
  confirm no transport-style formulation crept in.
- The (T0) refutation docstring is present and names the `staticFrame`-over-ℤ counterexample.

---

### Phase 9: FwdRec port — atomic half at arbitrary `D` [NOT STARTED]

**Goal**: `TaskFrame.FwdRec` defined over bundled frames, the `ValidOn` bridge, and the atomic
correspondence at arbitrary `D`.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Correspondence/FwdRec.lean`.
- [ ] `def TaskFrame.FwdRec (F : TaskFrame) : Prop := ∀ (τ : F.HF) (t s : F.Duration), t < s →
      (∀ r, t < r → r < s → False) → ∀ A : F.WorldState → Prop,
      (∀ r, s < r → A (τ.val.states r (τ.property r))) → A (τ.val.states s (τ.property s))`.
- [ ] `validOn_iff_total (F) (φ) : F.ValidOn φ ↔ ∀ M (τ : WorldHistory F), τ.IsTotal → ∀ t,
      TruthAt M τ t φ := ⟨fun h M τ hτ t => h M ⟨τ, hτ⟩ t, fun h M τ t => h M τ.val τ.property t⟩`
      — one term, because `TaskFrame.HF` is a subtype (`WorldHistory.lean:512`). This bridges the
      probes' validity shape to `ValidOn`.
- [ ] Port `Corr.density_iff_fwdRec` (`02_probes.lean:162`) — **atomic instances only, at
      arbitrary `D`** — applying the pre-512 rename pass. Transplant and restate; do not re-prove.
- [ ] Docstring stating the strength distinction that phase 11 depends on: the atomic version
      generalizes to arbitrary `D`; the schema version does not and is ℤ-only. **State them
      separately; do not merge.**
- [ ] Register in `FormalSystem/Semantics.lean`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: ~150 lines, essentially transcription. Confirm at implementation time; if
the port requires new proof steps rather than renames, that contradicts the acceptance criterion
"the FwdRec port must not re-prove what the probes proved" — record the discrepancy before
continuing.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/FwdRec.lean` - new module
- `FormalSystem/Semantics.lean` - one import line

**Verification**:
- `lake build` green; sorry-free.
- `TaskFrame.FwdRec` elaborates over a bundled frame (no free carrier parameter).
- The atomic statement carries no ℤ hypothesis.

---

### Phase 10: OPTIONAL — `Walk`/`MinCyc` periodicity apparatus at ℤ [NOT STARTED]

**Goal**: The periodicity machinery `03_probes.lean` Probe H needs, ported into the tree.

**Rationale for optionality**: this apparatus is needed ONLY by deliverable (3)'s schema half at
ℤ. Nothing else in the task uses it, and it is the single largest line-count item. Phases 1-9
deliver the rest of the task without it. If phases 10-11 do not land, close them
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record, or leave them
`[NOT STARTED]` and note the descope in the task summary.

**Tasks**:
- [ ] Append to `FormalSystem/Semantics/Correspondence/FwdRec.lean`, or split into
      `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` if the file grows past a
      comfortable size (implementer's call; register the new module if split).
- [ ] Port `03_probes.lean` Probe H: walks in a digraph, `MinCyc`, `succ_unique`, `periodic`,
      and `truthAt_add_hist_period` (per-history periods, which is what distinguishes this from
      phase 4's uniform-period `staticFrame` case). Apply the pre-512 rename pass.
- [ ] Transcription only — do not re-derive; the probes are the evidence of record.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines of bulk transcription out of `03_probes.lean`'s ~400-line
apparatus. Confirm at implementation time by measuring the probe source region before starting;
if it exceeds ~350 lines, plan to close `[PARTIAL]` mid-transcription at a green boundary rather
than overrunning one agent run.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/FwdRec.lean` (or a new `FwdRecPeriodicity.lean`)
- `FormalSystem/Semantics.lean` - import line, only if split into a new module

**Verification**:
- `lake build` green at every committed sub-step; sorry-free.
- Each ported declaration's statement matches its `03_probes.lean` counterpart modulo the three
  documented renames — diff-read each against the probe source.

---

### Phase 11: OPTIONAL — FwdRec schema half at ℤ and `Mod densitySchema` [NOT STARTED]

**Goal**: `Bridge.density_schema_iff_fwdRec` in the tree, and the deliverable-(3) statement
`Mod densitySchema = {F | F.FwdRec}` at ℤ.

**Tasks**:
- [ ] Port `03_probes.lean:626`'s `Bridge.density_schema_iff_fwdRec` — the **full schema, at
      `D = ℤ` only** — over the phase 10 apparatus, applying the pre-512 rename pass.
- [ ] State `Mod densitySchema = {F : TaskFrame | F.FwdRec}` at ℤ, using phase 1's
      `densitySchema` and `Mod`.
- [ ] Docstring stating the ℤ restriction explicitly and why it is not removable: the ℤ
      restriction is exactly what the `Walk`/`MinCyc` apparatus buys, and the open question
      (does FwdRec give full-schema density over a general non-dense `D`, with "periodic"
      weakened to shift-recurrence under a history-preserving order automorphism?) remains open,
      with the sum of ℤ/nℤ over ℤ ×ₗ ℤ as the candidate counterexample.

**Timing**: 1.5 hours

**Depends on**: 1, 9, 10

**Verification Tier**: local

**Scope Hypothesis**: ~150 lines: the bridge port plus the `Mod`-level corollary. Confirm at
implementation time.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/FwdRec.lean` (or `FwdRecPeriodicity.lean`) - append

**Verification**:
- `lake build` green; sorry-free.
- The `Mod densitySchema` statement is scoped to ℤ and its docstring says so; it is not stated at
  arbitrary `D`.

## Testing & Validation

- [ ] `lake build` exits 0 with a genuine full job count (a scoped result can replay and present
      as a full pass — force a full build and confirm the count).
- [ ] `lake test` green.
- [ ] `grep -rn "sorry\|admit\|native_decide" FormalSystem/Semantics/Correspondence/
      FormalSystem/Metalogic/Independence/` returns nothing new.
- [ ] `#print axioms` clean on the headline results: `galoisClosed_mod`,
      `validOn_neg_nextTop_iff`, `validOn_nextTop_iff_isDiscrete`, `succIndicatorAt`,
      `static_time_invariant`, `rat_not_complete`, and both sandwich theorems. No new axiom is
      introduced anywhere; research confirmed no step in this plan requires one.
- [ ] `bash scripts/check-module-invariants.sh` — no new unreachable modules; every new module
      registered in `FormalSystem/Semantics.lean` or `FormalSystem/Metalogic/Independence.lean`.
- [ ] Every theorem in the task's deliverables is stated over bundled frames (`TaskFrame` /
      `FrameOver D`), never over a bare carrier with a separate frame argument.
- [ ] No declaration in the new code is named `nextTop`; `Formula.next Formula.top` is used
      throughout.
- [ ] The paper-Discrete closure corollary (phase 2) is over `{F | F.IsDiscrete}` and the
      Discrete sandwich's upper bound (phase 6) is over `{F | F.IsDiscrete}` — neither over
      `Sat .Discrete`.
- [ ] Deliverable (6)'s non-goals appear verbatim in `Galois.lean`'s module docstring.
- [ ] No new linter warnings of any class; no linter disabled anywhere.

## Artifacts & Outputs

- `FormalSystem/Semantics/Correspondence/Galois.lean` — `Th`/`Mod` adjunction, closure operator,
  `GaloisClosed`, `galoisClosed_of_indicator`, `AxiomSet`, `densitySchema`, non-goals docstring
- `FormalSystem/Semantics/Correspondence/Indicator.lean` — indicator exactness and the two
  closure corollaries
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — translation frame, permissive
  frame, glue lemmas, the three (T1) biconditionals, the (T0) refutation record
- `FormalSystem/Semantics/Correspondence/FwdRec.lean` (+ optional `FwdRecPeriodicity.lean`) —
  `FwdRec`, `validOn_iff_total`, atomic correspondence, and the optional schema half at ℤ
- `FormalSystem/Metalogic/Independence/StaticFrame.lean` — static-frame kit and constant-truth
  calculus
- `FormalSystem/Metalogic/Independence/RationalWitness.lean` — `rat_not_complete` and the
  Dedekind sandwich
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean` — ℤ ×ₗ ℤ facts and the Discrete
  sandwich
- Edits: `FormalSystem/Theorems/DiscreteUnfolding.lean`, `FormalSystem/Theorems.lean`,
  `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic/Independence.lean`
- `specs/513_uniform_frame_faithfulness_predicate/summaries/01_galois-closure-implementation-summary.md`

## Rollback/Contingency

Every phase is additive except phase 3, and every new module is registered in an aggregator by a
single import line. Rollback of any phase is: revert that phase's commit(s) and remove the
aggregator import line. Phase 3 is the only in-place edit; its rollback restores
`succIndicator`'s original non-polymorphic body, which no other phase depends on (phase 6's
semantic upper bound is deliberately independent of it).

Contingency by failure mode:
- **A phase overruns one agent run**: close it `[PARTIAL]` at the last green sub-step and resume.
  Phases 8, 10, and 11 explicitly permit this.
- **Phases 10-11 do not land**: they are OPTIONAL by design. Close them
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the
  `Walk`/`MinCyc` transcription as the excluded item and phases 1-9 as the delivered scope. The
  task's remaining deliverables are unaffected.
- **Any phase needs a single-frame `swapTemporal` closure lemma**: stop, do not attempt it, and
  report a blocker. This is a hard contract, not a preference.
