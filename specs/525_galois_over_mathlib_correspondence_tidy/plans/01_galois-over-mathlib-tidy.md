# Implementation Plan: Task #525

- **Task**: 525 - Galois over Mathlib + correspondence tidy (WAVE 3, theorem layer)
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: None blocking. Task 523 (frame kit / `Semantics/Frames/Standard.lean`) already landed and is the reason `DurationFrames.lean` is 409 lines rather than 563.
- **Research Inputs**: specs/525_galois_over_mathlib_correspondence_tidy/reports/01_galois-over-mathlib-correspondence-tidy.md
- **Artifacts**: plans/01_galois-over-mathlib-tidy.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Re-base the frame-class `Th`/`Mod` layer on Mathlib's polarity API (`Mathlib.Order.Concept`) so the
six connection theorems become one-line projections rather than hand-rolled `Set.Subset.antisymm`
arguments, then tidy four adjacent correspondence concerns: an iff-shaped indicator entry point, a
named atom-realisation step that makes the three (T1) proofs visibly parallel, deletion of a private
Archimedean copy, and repair of the documentation those changes falsify. Every Lean edit in this plan
was compile-verified during research against the pinned toolchain (Lean v4.33.0-rc1, Mathlib
`79d0395a`) via four `lake env lean` probe files, all exiting clean — this plan is transcription of
verified code plus one genuine proof-surgery phase. Definition of done: `Galois.lean`'s theorem bodies
are Mathlib projections, the free lemmas exist as named theorems, the three (T1) proofs are visibly
parallel, zero private Archimedean copies remain, `lake build` is green, and
`scripts/check-module-invariants.sh` reports the C2 baseline unchanged.

### Research Integration

The research report is the primary input and it corrected the task premises in three places. All
three corrections are load-bearing for this plan:

1. **The `abbrev`s elaborate.** The `Type 1` universe risk C-06 flagged is discharged:
   `abbrev Th := upperPolar validOnRel` typechecks and is `rfl`-defeq to the current `Th`. Concept's
   `variable {α β : Type*}` gives independent universes, so `α := TaskFrame : Type 1`,
   `β := Formula : Type` is fine. **No `theorem th_eq_upperPolar` fallback is planned or needed.**
2. **Do not implement via `GaloisConnection`.** G-ecosystem §3.2's mapping table routes `mod_th_mod`
   through `mod_th_gc.dual.u_l_u_eq_u` with `OrderDual` simp cleanup. Measured: Concept's
   `lowerPolar_upperPolar_lowerPolar` gives it directly, with no dual anywhere. Likewise
   `Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂` is `lowerPolar_union` (a plain `@[simp]` lemma), **not**
   `GaloisConnection.l_sup`. §3.2 is motivation for including `mod_th_gc` as a discoverable name; it
   is not the implementation.
3. **Item (4) resolves against relocation, on measured evidence.** `RationalWitness.lean` and
   `LexIntWitness.lean` genuinely need `Metalogic/Soundness.lean` (`axiom_dense_valid` :1352,
   `axiom_dedekind_valid` :1491, `axiom_discrete_valid` :1360, `axiom_valid`); StaticFrame's
   constant-truth calculus covers only the non-`Base` branches. Moving them would create a
   `Semantics → Metalogic.Soundness` edge that `Metalogic/Decidability/Verified/Decidable.lean:2758`
   explicitly refuses. C-21's Lean-side half is already done at `Metalogic/Independence.lean:20-31`;
   only `Independence/README.md:6` still carries the stale singular framing. **This plan repairs the
   README and moves no file.**

Two further findings shape phase sizing:

- **Item (3) has a gap the review missed.** `validOn_dn_iff_denselyOrdered` uses `permissiveFrame`,
  not `translationFrame`, so `translation_realizes` alone leaves one of the three proofs untouched
  and the parallelism criterion unmet. The report supplies a verified permissive twin
  (`permissiveHF` / `permissive_realizes`); it is mandatory, not optional. The report also rejects
  C-18's proposed existential signature in favour of the direct equational form, because an
  existential forces an `obtain` that discards the model identity both (⇒) proofs need.
- **The "209 → ~110" budget is stale.** It assumed C-05 (`@[simp]` on the model-atom lemmas) and
  C-12 (`WorldHistory.ofTotal`) were still outstanding; both are already in the tree. Current
  measured body size is 207 lines (64/65/78). **Realistic target: ~150-160 lines.** Acceptance is
  the parallelism criterion, not the line count.

Line-number drift: the task's anchors `:354`, `:419`, `:485` for the three (T1) proofs are stale.
Current anchors, re-confirmed at plan time: `:199` (`validOn_dn_iff_denselyOrdered`), `:264`
(`validOn_df_iff_isDiscrete`), `:330` (`validOn_co_iff_isComplete`). Locate by declaration name, not
by line.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no `roadmap_flag` is set, so no roadmap
phases are added. `specs/ROADMAP.md` was consulted read-only for the C2 baseline question only:
`galoisClosed_*` are not C2 entries (C2 covers `BXCanonical.completeness`, `.completeness_dense`,
`.completeness_discrete`, `.Chronicle.countermodel_dense`, plus two checked separately in
`scripts/check-module-invariants.sh`), and `grep -rn galoisClosed scripts/` returns nothing. The C2
baseline is therefore expected to be unaffected; Phase 6 re-runs the check to confirm rather than
assume.

## Goals & Non-Goals

**Goals**:
- `Th`, `Mod`, `GaloisClosed` are defined over `Mathlib.Order.Concept`'s `upperPolar` / `lowerPolar` /
  `Order.IsExtent`, with the six existing theorem names retained as one-line re-exports keeping their
  docstrings.
- `mod_th_gc` exists as the explicit `GaloisConnection`, and the free corollaries
  (`galoisClosed_iInter`, `galoisClosed_inter`, `galoisClosed_univ`, `mod_union`, `mod_iUnion`,
  `mod_empty`, `th_empty`) exist as named theorems.
- `galoisClosed_iff` exists as the compatibility bridge back to the fixed-point equation.
- `galoisClosed_of_indicator_iff` is the primary entry point and both `Indicator.lean` corollaries are
  one-line applications of it.
- `translation_realizes` and its permissive twin name the atom-realisation step, and the three (T1)
  proofs open with them in visibly parallel form.
- `private def corrAtom` is deleted; the realisation lemmas carry a `(p : Atom)` binder and the proofs
  instantiate at `Atom.mkBase "p"`.
- Zero private Archimedean copies: `Separability.lean`'s `arch_of_lub` is deleted in favour of
  `Semantics.archimedean_of_lub`.
- Every docstring falsified by the above is repaired in the same phase that falsifies it.
- `lake build` green; `scripts/check-module-invariants.sh` C2 baseline unchanged.

**Non-Goals**:
- **The `ClosureOperator` step (G-ecosystem §3.3).** Not taken. Mathlib does offer `extentClosure`
  (`Concept.lean:159`), but the `OrderDual` coercions cost more than they save, and the `IsExtent`
  corollaries deliver the same value dual-free.
- **Replacing `Walk` / `MinCyc` (C-14).** Not in Mathlib. `FwdRecPeriodicity.lean` is untouched.
- **U8 (`LexInt` namespace generalisation to `α ×ₗ ℤ`).** A `Semantics/LexCarrier.lean` +
  `LexIntWitness.lean` refactor discharging C-16, not one of the six work items, and it collides with
  the item-(4) decision to leave `LexIntWitness.lean` in place. Defer to its own task.
- **Relocating `RationalWitness.lean` / `LexIntWitness.lean`.** Resolved against; see Research
  Integration point 3.
- **`GaloisConnection.lt_iff_lt`.** Available only through the dualised connection and buys nothing
  here. Dropped from the deliverable list on the report's recommendation.
- **`axiomSet_mono` and the `AxiomSet` union decomposition at `RationalWitness.lean:118`.** A genuine
  but separable win (`mod_union` only pays off if `AxiomSet` is decomposed as a union). Explicitly out
  of scope to keep phases sized; the enabling one-liner is recorded in the report §1.6 for a future
  task.
- **`NOTE:` tags on the re-inlined `⟨"p", none⟩` / `⟨"q", none⟩` at
  `Metalogic/DiscreteNonCompactness.lean:253,282` and `Metalogic/DedekindNonCompactness.lean:426,454`.**
  Same smell, but `Metalogic/` is adjacent to task 524's concurrent territory. Raise via `/fix-it`
  later rather than editing foreign files mid-flight.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Mathlib.Order.Concept`'s `@[simp]` lemmas (`lowerPolar_union`, `lowerPolar_empty`, …) enter the default simp set for every module downstream of `Galois.lean` and break an unrelated `simp` call | H | M | Phase 1 carries **Verification Tier `full`** precisely for this: a complete `lake build`, not a single-module build. Any breakage surfaces there and is fixed forward in Phase 1 before the phase closes. |
| `GaloisClosed` changes meaning (fixed-point equation -> `Order.IsExtent` range membership; equivalent by `Order.isExtent_iff`, not defeq) and a consumer the audit missed uses it as an equation | H | L | The repo-wide audit found `GaloisClosed` **produced** only in `Indicator.lean` (twice) and otherwise only mentioned in docstrings (`Metalogic.lean`, `LexIntWitness.lean`, `Correspondence/README.md`) — nothing consumes it as an equation. Ship `galoisClosed_iff : GaloisClosed K ↔ Mod (Th K) = K := Order.isExtent_iff` in the same phase so the equation stays reachable and the docstring stays true; re-run the grep in Phase 1 before closing. |
| Phase 4's proof surgery lands the lemmas but the three proofs still do not read as parallel | M | M | The permissive twin (`permissiveHF` / `permissive_realizes`) is mandatory, not optional — without it one of three proofs is untouched. Phase 4's verification is an explicit side-by-side read of the three (⇒) openings, not a line count. |
| Line-number anchors in the task description and report drift further during Phases 1-5 | M | H | Every phase locates targets by declaration name. Phase 6 (READMEs, line counts) runs **last**, after all `.lean` edits, and regenerates counts with `scripts/readme-inventory.sh` rather than reusing any number written in this plan. |
| Task 524 is concurrently working `Metalogic/` (StrongCompleteness, Compactness, Conservativity); Phase 5 touches `Metalogic/SoundnessLemmas/Separability.lean` and `Metalogic/Decidability/Verified/Decidable.lean` | M | L | Territory is disjoint by file, but adjacent by directory. Before starting Phase 5, run `git status --short` and confirm neither file is foreign-modified; if either is, stop and report rather than editing. |
| The new `Semantics.DurationClassification` import into `Metalogic/SoundnessLemmas/Separability.lean` introduces a cycle or a build-cost regression | M | L | Measured: the transitive `FormalSystem` closure of `DurationClassification` is exactly three modules (`Semantics.DurationClassification`, `Semantics.TaskFrame`, `Semantics.TemporalOrder`) and contains no `FormalSystem.Metalogic` module. `scripts/check-metalogic-cycles.sh` exists and is run in Phase 5. |
| The C2 axiom baseline shifts because of the new Mathlib import | H | L | `Mathlib.Order.Concept`'s own imports are `Mathlib.Data.Set.Lattice` and `Mathlib.Order.Closure`, neither of which can introduce an axiom beyond `propext` / `Classical.choice` / `Quot.sound`. Phase 6 re-runs `scripts/check-module-invariants.sh` to confirm rather than assume. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 5 | -- |
| 2 | 2, 4 | 1 (for 2), 3 (for 4) |
| 3 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Territory ownership is disjoint across each
wave: Wave 1 owns `Correspondence/Galois.lean` (P1), `Correspondence/DurationFrames.lean` (P3), and
`Metalogic/SoundnessLemmas/Separability.lean` + `Semantics/DurationClassification.lean` +
`Metalogic/Decidability/Verified/Decidable.lean` (P5). Wave 2 owns `Correspondence/Indicator.lean`
(P2) and `Correspondence/DurationFrames.lean` + `Correspondence/FwdRec.lean` (P4). Note that a
parallel wave-1 dispatch shares one `lake build`; if run in parallel, serialise the builds.

---

### Phase 1: Re-base the Galois layer on `Mathlib.Order.Concept` [NOT STARTED]

- **Goal:** `Galois.lean`'s connection theorems become one-line Mathlib projections; the explicit
  `GaloisConnection`, the free corollaries, the compatibility lemma, and the iff-shaped indicator
  entry point all exist and typecheck.

- **Tasks:**
  - [ ] Add `import Mathlib.Order.Concept` to `Galois.lean` (verified to import cleanly into this
        legacy, non-`module` tree despite Concept being a `module`-system file with
        `@[expose] public section`).
  - [ ] Add `Order` to the `open` line — `open FormalSystem.Syntax FormalSystem.ProofSystem Order` —
        or fully qualify `Order.IsExtent`. Probes used `open Order` with no clash.
  - [ ] Introduce the relation and re-base the two maps, keeping both docstrings verbatim:
        `def validOnRel (F : TaskFrame) (φ : Formula) : Prop := F.ValidOn φ`;
        `abbrev Th : Set TaskFrame → Set Formula := upperPolar validOnRel`;
        `abbrev Mod : Set Formula → Set TaskFrame := lowerPolar validOnRel`.
  - [ ] Re-base `GaloisClosed`: `abbrev GaloisClosed : Set TaskFrame → Prop := Order.IsExtent validOnRel`.
  - [ ] Replace the six theorem **bodies** only, keeping every name and docstring:
        `th_anti h := upperPolar_anti _ h`; `mod_anti h := lowerPolar_anti _ h`;
        `subset_mod_th K := subset_lowerPolar_upperPolar _ K`;
        `subset_th_mod S := subset_upperPolar_lowerPolar _ S`;
        `mod_th_mod S := lowerPolar_upperPolar_lowerPolar _ S`;
        `th_mod_th K := upperPolar_lowerPolar_upperPolar _ K`;
        and `galoisClosed_mod S := Order.isExtent_lowerPolar`.
  - [ ] Add the compatibility lemma with its docstring:
        `theorem galoisClosed_iff {K : Set TaskFrame} : GaloisClosed K ↔ Mod (Th K) = K := Order.isExtent_iff`.
  - [ ] Adjust `galoisClosed_of_indicator` to wrap its result in `Order.isExtent_iff.mpr` (its body
        currently produces the equation via `Set.Subset.antisymm`). Keep the two-argument form — C-24
        says keep it, and the iff form below is defined in terms of it.
  - [ ] Add `galoisClosed_of_indicator_iff` as the primary entry point (item 2's Lean half; the
        `Indicator.lean` retarget is Phase 2):
        `theorem galoisClosed_of_indicator_iff {K : Set TaskFrame} (φ : Formula) (h : ∀ F : TaskFrame, F.ValidOn φ ↔ F ∈ K) : GaloisClosed K := galoisClosed_of_indicator φ (fun F hF => (h F).mpr hF) (fun F hv => (h F).mp hv)`.
  - [ ] Add the explicit connection with its docstring:
        `theorem mod_th_gc : GaloisConnection (α := Set Formula) (β := (Set TaskFrame)ᵒᵈ) (OrderDual.toDual ∘ Mod) (Th ∘ OrderDual.ofDual) := gc_lowerPolar_upperPolar validOnRel`.
        Include it for discoverability (it satisfies G-06's "zero `GaloisConnection` occurrences
        repo-wide"), but **derive nothing from it** — the polar lemmas above are dual-free and shorter.
  - [ ] Add the free corollaries as named theorems with docstrings: `galoisClosed_iInter`
        (`Order.IsExtent.iInter f hf`), `galoisClosed_inter` (`h.inter h'`), `galoisClosed_univ`
        (`Order.IsExtent.univ`), `mod_union` (`lowerPolar_union _ S₁ S₂`), `mod_iUnion`
        (`lowerPolar_iUnion _ f`), `mod_empty` (`lowerPolar_empty _`), `th_empty` (`upperPolar_empty _`).
  - [ ] Rewrite the module header's **## Import seam** section. It currently asserts the module imports
        `Semantics/Validity.lean` **only**; that sentence becomes false. The new Mathlib edge opens no
        `Semantics → ProofSystem`-style seam, so the seam claim itself survives — change the wording,
        not the claim.
  - [ ] Update the header's **## Main results** narration with the new names.
  - [ ] Re-run the consumer grep for `GaloisClosed` across the repo and confirm nothing consumes it as
        an equation before closing the phase.

- **Timing:** 1.5 hours

- **Depends on:** none

- **Verification Tier:** full

- **Scope Hypothesis:** This phase asserts 6 re-based theorem bodies + `galoisClosed_mod` + 7 free
  corollaries + `mod_th_gc` + `galoisClosed_iff` + `galoisClosed_of_indicator_iff` = 17 declarations
  touched or added, and asserts that `Th`/`Mod`/`GaloisClosed`'s only equation-shaped consumers are
  inside `Galois.lean` and `Indicator.lean`. Confirm at implementation time by (a) elaborating each
  declaration and (b) re-running `grep -rn 'GaloisClosed' FormalSystem/ specs/` and reading every hit
  before closing. If the grep surfaces an equation-consuming site the audit missed, `galoisClosed_iff`
  is the repair and the extra site is in scope for this phase.

- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/Galois.lean` — new import, `open Order`, `validOnRel`,
    re-based `Th`/`Mod`/`GaloisClosed`, 7 re-based bodies, 10 added declarations, header seam and
    main-results rewrite.

- **Verification:**
  - `lake build` green across the whole tree (this is the phase that can perturb the global simp set).
  - `example (K : Set TaskFrame) : Th K = {φ | ∀ F ∈ K, F.ValidOn φ} := rfl` and the `Mod` analogue
    close by `rfl`, confirming the re-based definitions are defeq to what they replaced.
  - `galoisClosed_iff` typechecks, and `Order.isExtent_iff.mpr` accepts an equation-shaped proof.
  - No `sorry` introduced.

---

### Phase 2: Retarget `Indicator.lean` to the iff entry point [NOT STARTED]

- **Goal:** Both closure corollaries are one-line applications of `galoisClosed_of_indicator_iff`, and
  the module header states the full four-part closed/not-closed picture in one place.

- **Tasks:**
  - [ ] Rewrite `galoisClosed_sat_dense` as
        `galoisClosed_of_indicator_iff _ validOn_neg_nextTop_iff` (3 lines -> 1). The defeq
        `F ∈ {F | FrameClass.Sat FrameClass.Dense F}` ≡ `DenselyOrdered F.Duration` holds, as the
        existing docstring already asserts, so no bridging lemma is needed.
  - [ ] Rewrite `galoisClosed_isDiscrete` as
        `galoisClosed_of_indicator_iff _ validOn_nextTop_iff_isDiscrete` (3 lines -> 1).
  - [ ] Update both corollary docstrings, which currently narrate "one application of
        `galoisClosed_of_indicator` at `φ := …`, with `hmem` the `.mpr` and `hback` the `.mp`" — that
        two-argument framing is exactly what the iff form absorbs, so the narration must change.
  - [ ] Add the `RationalWitness.lean` half to the module header. It already names
        `LexIntWitness.lean` (at `:41` and `:147`); adding `RationalWitness.lean` completes the
        four-part picture in one place: dense closed / paper-discrete closed / `Sat .Discrete` not
        closed / `Sat .Dedekind` not closed.

- **Timing:** 0.5 hours

- **Depends on:** 1

- **Verification Tier:** local

- **Scope Hypothesis:** This phase asserts exactly two corollaries in `Indicator.lean` produce
  `GaloisClosed` and both retarget cleanly. Confirm by `grep -n 'galoisClosed' FormalSystem/Semantics/Correspondence/Indicator.lean`
  and reading every hit; a third producer, if one appears, is in scope for this phase.

- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/Indicator.lean` — two proof bodies, two docstrings, header
    pointer.

- **Verification:**
  - `lake build FormalSystem.Semantics.Correspondence.Indicator` green.
  - Both corollary bodies are a single line.
  - No `sorry` introduced.

---

### Phase 3: Add the atom-realisation layer to `DurationFrames.lean` [NOT STARTED]

- **Goal:** The named realisation lemmas exist, carry a `(p : Atom)` binder, and typecheck. Purely
  additive — no existing proof is touched in this phase, so the tree stays green throughout.

- **Tasks:**
  - [ ] Add `def translationHF (D : TemporalOrder) : (translationFrame D).toTaskFrame.HF := ⟨translationHist D, translationHist_isTotal D⟩`
        with a docstring naming it the translation frame's reference total history.
  - [ ] Add `theorem translation_realizes (D : TemporalOrder) (A : Set ↑D) (p : Atom) (t : ↑D) : TruthAt (translationModel D A) (translationHF D).val t (Formula.atom p) ↔ t ∈ A := translationModel_atom D A p t`,
        docstringed as **Atom realisation**: the translation frame realises an arbitrary `A ⊆ ↑D` as
        the truth set of an atom along its reference history.
  - [ ] Add `translation_realizes_allPast` and `translation_realizes_allFuture` (the `rw [Truth.past_iff]`
        / `rw [Truth.future_iff]` then `forall_congr'` twice form from report §3.1). Note
        `translation_realizes_allPast` is the real payload: it is *exactly* the 11-line inline `hHiff`
        currently hand-built inside `validOn_co_iff_isComplete`, and the same step
        `validOn_df_iff_isDiscrete` performs twice ad hoc.
  - [ ] Add the permissive twin the review missed:
        `def permissiveHF (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) (f : ↑D → Bool) : (permissiveFrame D so nm).toTaskFrame.HF := ⟨permissiveHist D so nm f, permissiveHist_isTotal D so nm f⟩`.
  - [ ] Add `theorem permissive_realizes (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) (f : ↑D → Bool) (p : Atom) (t : ↑D) : TruthAt (permissiveModel D so nm) (permissiveHF D so nm f).val t (Formula.atom p) ↔ f t = true := permissiveModel_atom D so nm f p t`.
  - [ ] Add the new names to the module header's inventory list (which currently enumerates
        `translationFrame`, `permissiveFrame`, and the three (T1) biconditionals).
  - [ ] **Optional stretch, droppable and not part of acceptance:** `translationHist` and
        `permissiveHist` still build the `domain := fun _ => True` record literally, which
        `WorldHistory.ofTotal` (`Semantics/WorldHistory.lean:143`, with `ofTotal_isTotal` :152 and
        `@[simp] ofTotal_domain` :166) exists to replace — its docstring at `:130` explicitly says
        "Use `ofTotal` in preference to a literal `domain := fun _ => True` record." Take this **only**
        if the mainline above is green and budget remains; drop it silently otherwise.

- **Timing:** 0.75 hours

- **Depends on:** none

- **Verification Tier:** local

- **Scope Hypothesis:** This phase asserts 6 new declarations (`translationHF`, `translation_realizes`,
  `translation_realizes_allPast`, `translation_realizes_allFuture`, `permissiveHF`,
  `permissive_realizes`), all compile-verified in research probe B. Confirm by elaborating each; the
  count is exact and any deviation means a probe transcription error, not a scope change.

- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — 6 added declarations, header
    inventory line.

- **Verification:**
  - `lake build FormalSystem.Semantics.Correspondence.DurationFrames` green.
  - All six declarations elaborate with no `sorry` and no `@[simp]` loop.
  - Nothing existing in the file was modified (diff is additions plus the one header line).

---

### Phase 4: Rewrite the three (T1) proofs; delete `corrAtom` [NOT STARTED]

- **Goal:** The three (T1) proofs open with the realisation lemmas and read as visibly parallel
  arguments; the private `corrAtom` is gone and the atom idiom is `Atom.mkBase "p"` throughout.

- **Tasks:**
  - [ ] Rewrite `validOn_co_iff_isComplete`'s (⇒) branch first — it has the largest, most mechanical
        win: replace the 11-line inline `hHiff` block with `translation_realizes_allPast`, and the
        `set τ := ⟨translationHist D, translationHist_isTotal D⟩ with hτ` block with `translationHF D`.
        Drop the now-dead `simp only [hτ, hM, translationModel_atom]` incantations.
  - [ ] Rewrite `validOn_df_iff_isDiscrete`'s (⇒) branch: replace the `set τ` block with
        `translationHF D` and the two ad hoc realisation steps (the `Hφ` antecedent and the
        consequent readback) with `translation_realizes_allPast` / `translation_realizes`.
  - [ ] Rewrite `validOn_dn_iff_denselyOrdered`'s (⇒) branch using the permissive twin: replace the
        `set τ := ⟨permissiveHist D so nm f, permissiveHist_isTotal D so nm f⟩ with hτ` block with
        `permissiveHF D so nm f` and the `simp only [hτ, permissiveModel_atom]` steps with
        `permissive_realizes`.
  - [ ] Delete `private def corrAtom : Atom := ⟨"p", none⟩` and its preceding comment. Replace every
        `Formula.atom corrAtom` with `Formula.atom (Atom.mkBase "p")` — `Atom.mkBase`
        (`Syntax/Atom.lean:117`) already exists and is the idiomatic spelling of `⟨"p", none⟩`.
        Rationale for parameterising rather than promoting (C-25): the file's own comment already says
        "any atom would do"; `CoNotPriorU.lean` and `DiscreteNonCompactness.lean` already take
        `(a : Atom)` parameters, so this is the established repo idiom; and a promoted public
        `Semantics.corrAtom` would be a new public name with no mathematical content.
  - [ ] Replace `FwdRec.lean`'s two `Atom.mk "p" none` inlines (at `:88` and `:97`, inside the (⇒)
        branch of `validOn_atomic_density_iff_fwdRec`, where the theorem's own `∀ p : Atom` binder at
        `:81` is not in scope) with `Atom.mkBase "p"`.
  - [ ] Read the three (⇒) openings side by side and confirm they are visibly parallel. If they are
        not, the phase is not done — adjust until they are.

- **Timing:** 1.5 hours

- **Depends on:** 3

- **Verification Tier:** local

- **Commit Mode:** per-substep — each of the three proof rewrites is an independently green sub-step
  and is committed as it lands.

- **Scope Hypothesis:** This phase asserts three (T1) proofs totalling 207 lines (64 / 65 / 78) at
  declarations `validOn_dn_iff_denselyOrdered`, `validOn_df_iff_isDiscrete`,
  `validOn_co_iff_isComplete`, targeting ~150-160 lines after rewrite, and asserts exactly two
  `Atom.mk "p" none` inlines in `FwdRec.lean`. **Confirm all of these at implementation time by
  declaration name, not line number** — the task description's anchors (`:354`, `:419`, `:485`) are
  already stale by ~155 lines. The line target is an expectation, not an acceptance criterion: the
  criterion is that the three (⇒) openings read as parallel. If the rewrite lands parallel proofs at
  180 lines, that passes; if it lands 140 non-parallel lines, it does not.

- **Files to modify:**
  - `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — three proof bodies, `corrAtom`
    deletion, ~13 `Formula.atom corrAtom` call-site rewrites.
  - `FormalSystem/Semantics/Correspondence/FwdRec.lean` — two `Atom.mk "p" none` inlines.

- **Verification:**
  - `lake build` green for both modules and their dependents.
  - `grep -n corrAtom FormalSystem/` returns nothing.
  - `grep -n 'Atom.mk "p" none' FormalSystem/Semantics/Correspondence/` returns nothing.
  - Side-by-side read of the three (⇒) openings confirms parallel shape.
  - No `sorry` introduced.

---

### Phase 5: Delete the private Archimedean copy and repair its three docstrings [NOT STARTED]

- **Goal:** Zero private Archimedean copies in the tree; the new import edge is in place and measured;
  and the three docstrings the deletion falsifies are corrected in the same change.

- **Tasks:**
  - [ ] **Territory check first:** run `git status --short` and confirm
        `Metalogic/SoundnessLemmas/Separability.lean` and `Metalogic/Decidability/Verified/Decidable.lean`
        carry no foreign modification (task 524 is concurrently active in `Metalogic/`). If either is
        foreign-modified, stop and report rather than editing.
  - [ ] Add `import FormalSystem.Semantics.DurationClassification` to `Separability.lean` (currently
        imports only `Mathlib.Algebra.Order.Archimedean.Basic` and `Mathlib.Data.Set.Countable`).
  - [ ] Retarget the single call site — inside `exists_countable_order_dense` — from `arch_of_lub` to
        `Semantics.archimedean_of_lub`. The call site has `[Nontrivial D]` in scope; the public lemma
        simply does not need it, so the extra binder on the private copy is discharged by being
        unnecessary. The public lemma is otherwise a character-level match and strictly more general.
  - [ ] Delete `private theorem arch_of_lub` together with its docstring paragraph ("Deliberate
        duplicate of `FormalSystem.Semantics.archimedean_of_lub` … This copy stays `private` and stays
        here"), which goes with the theorem.
  - [ ] Repair `Metalogic/Decidability/Verified/Decidable.lean`'s "**On the import.**" paragraph, which
        asserts `SoundnessLemmas/Separability.lean` imports **only** Mathlib and "mentions neither
        formulas nor truth". Rewrite it to state the new transitive closure — exactly three
        `Semantics` modules (`DurationClassification`, `TaskFrame`, `TemporalOrder`) and **no**
        `FormalSystem.Metalogic` module — preserving the acyclicity claim, which still holds and is now
        measured rather than asserted. **The adjacent sentence refusing the edge to
        `Metalogic/Soundness.lean` is unaffected and must stay verbatim** — it is the same sentence
        item (4) relies on.
  - [ ] Delete or rewrite `Semantics/DurationClassification.lean`'s "## Relation to
        `Metalogic/SoundnessLemmas/Separability.lean`" header section. It says the duplication "is
        deliberate and is noted in both places rather than resolved by moving the helper, which would
        drag `Metalogic` proofs into a rebase" — the duplication is now resolved, and the measured
        3-module closure refutes the stated reason for keeping it.

- **Timing:** 0.75 hours

- **Depends on:** none

- **Verification Tier:** interface

- **Scope Hypothesis:** This phase asserts exactly one call site of `arch_of_lub` and exactly three
  docstrings falsified by its deletion. Confirm at implementation time with
  `grep -rn 'arch_of_lub' FormalSystem/` (expect the definition plus one use, both in
  `Separability.lean`) and `grep -rn 'Separability' FormalSystem/ --include=*.lean` to re-enumerate
  the prose that describes this file's imports. Any additional falsified docstring found is in scope
  for this phase — the whole point of the phase is that the deletion must not leave a documentation
  defect behind.

- **Files to modify:**
  - `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` — new import, retargeted call site,
    deleted private theorem and its docstring.
  - `FormalSystem/Semantics/DurationClassification.lean` — deleted/rewritten header section.
  - `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` — rewritten "On the import."
    paragraph, refusal sentence preserved.

- **Verification:**
  - `lake build` green for `Separability.lean` and its dependents.
  - `scripts/check-metalogic-cycles.sh` passes (no cycle introduced by the new edge).
  - `grep -rn 'arch_of_lub' FormalSystem/` returns nothing.
  - The `Metalogic/Soundness.lean` refusal sentence in `Decidable.lean` is byte-identical to before.

---

### Phase 6: Repair the two READMEs and confirm the baselines [NOT STARTED]

- **Goal:** Both READMEs describe the tree as it now is, and the C2 axiom baseline is confirmed
  unchanged.

- **Tasks:**
  - [ ] `Metalogic/Independence/README.md`: rewrite the opening paragraph. It currently reads "The
        result carried here is that the paper's `CO` principle does **not** derive Reynolds's
        `Axiom.prior_U_gap`…" — singular, and two witnesses out of date. Rewrite to the three result
        families over six modules, **mirroring `Metalogic/Independence.lean:20-31`'s wording**, which
        is already correct and already narrates its own repair. Do not modify `Independence.lean`.
  - [ ] `Metalogic/Independence/README.md`: regenerate the module table's Lines column with
        `scripts/readme-inventory.sh FormalSystem/Metalogic/Independence`. Note the script emits
        `<!-- TODO: add description -->` placeholders — use it for **line counts only** and preserve
        every existing Description cell verbatim.
  - [ ] `Semantics/Correspondence/README.md`: regenerate the module table's Lines column the same way,
        with `scripts/readme-inventory.sh FormalSystem/Semantics/Correspondence`, **after** Phases 1-5
        have landed so the counts are final.
  - [ ] `Semantics/Correspondence/README.md`: fix the `DurationFrames.lean` Description cell, which
        still claims the file contains the translation and permissive frames. Those now live in
        `Semantics/Frames/Standard.lean`; the file retains only the histories and models.
  - [ ] `Semantics/Correspondence/README.md`: add the reciprocal "See also" to the **Key Results**
        section naming `sat_dedekind_ssubset_mod_axiomSet` and `sat_discrete_ssubset_mod_axiomSet` as
        the non-closure complement of `galoisClosed_sat_dense` / `galoisClosed_isDiscrete`. The
        **Related Documentation** section already points at the Independence README; Key Results does
        not.
  - [ ] `Semantics/Correspondence/README.md`: update the `Galois.lean` and `Indicator.lean` Description
        cells to name the new declarations added in Phases 1-2.
  - [ ] Update the **Last verified** date on both READMEs.
  - [ ] Run `scripts/readme-lint.sh` if it applies to these paths.
  - [ ] Run `scripts/check-module-invariants.sh` and confirm the C2 baseline is unchanged.
  - [ ] Run a final full `lake build`.

- **Timing:** 0.5 hours

- **Depends on:** 1, 2, 3, 4, 5

- **Verification Tier:** prose — every edit in this phase is confined to Markdown README prose and
  tables, with zero compile or elaboration surface. The two shell checks at the end are the task-level
  gate, not this phase's edit class.

- **Scope Hypothesis:** This phase asserts that `Correspondence/README.md`'s module table is stale in
  four of six rows and `Independence/README.md`'s in four of six. These counts were measured before
  Phases 1-5 ran and **all of them will have moved** — do not transcribe any number from this plan.
  Regenerate both tables from `scripts/readme-inventory.sh` against the post-Phase-5 tree and diff
  against what is written.

- **Files to modify:**
  - `FormalSystem/Metalogic/Independence/README.md`
  - `FormalSystem/Semantics/Correspondence/README.md`

- **Verification:**
  - Every Lines cell in both tables matches `wc -l` on the post-Phase-5 tree.
  - No Description cell was replaced by a `<!-- TODO -->` placeholder.
  - `scripts/check-module-invariants.sh` reports the C2 baseline unchanged.
  - `lake build` green.

---

## Testing & Validation

- [ ] `lake build` green across the whole tree, with zero `sorry` introduced by any phase.
- [ ] `scripts/check-module-invariants.sh` passes and the C2 baseline is unchanged (C2 covers
      `BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`,
      `.Chronicle.countermodel_dense` plus two checked separately; `galoisClosed_*` are not C2 entries,
      so "unchanged" is the expected result and a change is a defect).
- [ ] `scripts/check-metalogic-cycles.sh` passes (Phase 5's new import edge).
- [ ] `Galois.lean`'s six connection theorem bodies are each a single Mathlib projection.
- [ ] `galoisClosed_iInter`, `galoisClosed_inter`, `galoisClosed_univ`, `mod_union`, `mod_iUnion`,
      `mod_empty`, `th_empty`, `mod_th_gc`, `galoisClosed_iff` and `galoisClosed_of_indicator_iff` all
      exist as named declarations.
- [ ] `Th K = {φ | ∀ F ∈ K, F.ValidOn φ}` closes by `rfl` (re-based definitions are defeq to what they
      replaced).
- [ ] Both `Indicator.lean` closure corollaries are one-liners.
- [ ] The three (T1) proofs' (⇒) openings read as visibly parallel.
- [ ] `grep -rn corrAtom FormalSystem/` and `grep -rn arch_of_lub FormalSystem/` both return nothing.
- [ ] Both README module tables match `wc -l` on the final tree.
- [ ] `git status --short` shows no modification outside this task's declared file set (task 524 is
      concurrently active).

## Artifacts & Outputs

- `FormalSystem/Semantics/Correspondence/Galois.lean` (re-based on `Mathlib.Order.Concept`)
- `FormalSystem/Semantics/Correspondence/Indicator.lean` (retargeted corollaries, header pointer)
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` (realisation layer, rewritten (T1)
  proofs, `corrAtom` deleted)
- `FormalSystem/Semantics/Correspondence/FwdRec.lean` (atom idiom)
- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` (private copy deleted, new import)
- `FormalSystem/Semantics/DurationClassification.lean` (stale duplication section removed)
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` (import paragraph repaired)
- `FormalSystem/Semantics/Correspondence/README.md`
- `FormalSystem/Metalogic/Independence/README.md`
- `specs/525_galois_over_mathlib_correspondence_tidy/summaries/01_galois-over-mathlib-tidy-summary.md`

## Rollback/Contingency

Every phase is an independent green commit, so rollback is per-phase `git revert` of that phase's
commit range. Specific contingencies:

- **Phase 1 perturbs the global simp set.** If `Mathlib.Order.Concept`'s `@[simp]` lemmas break
  downstream `simp` calls beyond what Phase 1 can fix forward inside its own budget, the containment
  move is to keep `validOnRel` and the projections but demote the affected Concept lemmas at the
  offending call sites with `simp only`/`-lemma`, rather than reverting the re-basing. Reverting
  Phase 1 forces reverting Phase 2 as well.
- **Phase 4 fails to reach visible parallelism.** Phases 3 and 4 are separable by design: Phase 3 is
  purely additive and valuable on its own (it names the realisation step and removes the inline
  `hHiff` duplication as soon as any proof uses it). If Phase 4 stalls, keep Phase 3, mark Phase 4
  `[PARTIAL]` with the proofs it did convert, and record the remainder — do not revert Phase 3.
- **Phase 5 hits a cycle or a foreign modification.** Revert the import edge alone; the three
  docstring repairs must revert with it, since they describe the edge.
- **No strategic sorries are planned.** Nothing in this plan requires a proof that was not compiled
  during research. A `sorry` appearing anywhere is a deviation to be flagged, not an expected outcome.
