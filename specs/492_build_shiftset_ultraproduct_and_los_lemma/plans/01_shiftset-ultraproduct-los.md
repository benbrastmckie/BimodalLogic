# Implementation Plan: Build the ShiftSet Ultraproduct and the Łoś Lemma

- **Task**: 492 - Build shiftset ultraproduct and Łoś lemma
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: 491 (carrier route selection — settled, closed)
- **Research Inputs**: `specs/492_build_shiftset_ultraproduct_and_los_lemma/reports/01_shiftset-ultraproduct-and-los.md`
- **Artifacts**: `plans/01_shiftset-ultraproduct-los.md` (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/state-management.md`
  - `.claude/rules/plan-compliance.md`
  - `.claude/rules/lean4.md`
- **Type**: lean4

## Overview

Steps S2 (the ultraproduct of shift sets) and S3 (Łoś for `TruthAt`) are **already proved**. The
research phase compiled the entire mathematical content sorry-free against the live tree via
`lean_run_code`, with axiom profile `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
Two verified prototypes hold the result: a 216-line `prototype/UltraproductLos.lean`
(`exists_section`, `mk_surjective`, `mk_zero`, `mk_max`, `mk_abs`, `UT`, `uSep`, `uShiftSet`,
`los`, `los_truthAt`) and a 62-line `prototype/IndexFilter.lean` (`tailFilter`, `NeBot`, `idxUF`,
`eventually_mem`).

**This implementation is transcription and module layout, not discovery.** No phase below is
exploratory. Every declaration this plan asks for exists, in compiled form, in a file on disk;
the work is promoting it into four modules under `FormalSystem/Semantics/Ultraproduct/`, wiring
them into the `lean_lib FormalSystem` aggregator, and confirming under a real `lake build` what
`lean_run_code` could not confirm.

**Definition of done**: four new modules exist under `FormalSystem/Semantics/Ultraproduct/`, all
four are imported from `FormalSystem/Semantics.lean`, `lake build` is green, no `sorry` appears
anywhere in the new code, and `#print axioms los_truthAt` is recorded showing
`[propext, Classical.choice, Quot.sound]` with `sorryAx` absent.

### Source-to-Implementation Mapping (H3, Tier 2: verified in-repo prototypes)

Every load-bearing decision below cites a compiled source. There is no Tier 3 (unsourced)
content in this plan.

| Implementation target | Source | Verified how |
|---|---|---|
| `Carrier.lean` items 1-16 | `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean:80-256` | Compiles today under `lean_lib BimodalTest`, which carries the **same** `theoryLeanOptions` (`autoImplicit := false`) as `FormalSystem` (`lakefile.lean:10-24`) |
| `exists_section`, `mk_surjective`, `mk_zero`, `mk_max`, `mk_abs` | `prototype/UltraproductLos.lean:28-57` | `lean_run_code`, sorry-free |
| `IndexFilter.lean` | `prototype/IndexFilter.lean:20-60` | `lean_run_code`; `#print axioms eventually_mem` clean |
| `UT`, `uSep`, `uShiftSet` | `prototype/UltraproductLos.lean:69-109` | `lean_run_code`; `#print axioms uSep`, `uShiftSet` clean |
| `los`, `los_truthAt` | `prototype/UltraproductLos.lean:120-211` | `lean_run_code`; `#print axioms los`, `los_truthAt` clean |
| `ShiftSet` field shapes (`sep`, `Carrier`, `carrier_nonempty`) | `FormalSystem/Semantics/ShiftSet.lean:83,87,110` | Direct read this session |
| `ShiftTruth`, `forward_repr`, `hist_isTotal`, `total_eq_orbit`, `hist`, `model` | `FormalSystem/Semantics/ShiftSet.lean:261,278,226,245,215,229` | Direct read this session |
| Aggregator attachment point | `FormalSystem/Semantics.lean:21` (after `import FormalSystem.Semantics.ShiftSet`) | Direct read this session; `lakefile.lean:15-19` confirms `@[default_target] lean_lib FormalSystem` |

### Preserved Assets

The following work is complete and must not regress. No phase below may delete, rewrite, or
re-derive any of it.

| Component | File | Status | Verified |
|---|---|---|---|
| Research report (S2+S3 fully solved) | `specs/492_.../reports/01_shiftset-ultraproduct-and-los.md` | [COMPLETED] | 2026-08-31 |
| Verified prototype: ultraproduct + Łoś | `specs/492_.../prototype/UltraproductLos.lean` | [COMPLETED] | 2026-08-31 |
| Verified prototype: index ultrafilter | `specs/492_.../prototype/IndexFilter.lean` | [COMPLETED] | 2026-08-31 |
| Carrier construction (16 declarations) | `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` | [COMPLETED] | in-tree, builds today |
| `ShiftSet` representation layer (`forward_repr`, `reverse_repr`, `hist_isTotal`, `total_eq_orbit`) | `FormalSystem/Semantics/ShiftSet.lean` | [COMPLETED] | in-tree, builds today |

## Postmortem Constraints

Binding rules for all implementation dispatches on this task.

**Do NOT**:

- **Do NOT re-derive, re-explore, or "improve" any proof in the prototypes.** They are compiled
  and axiom-checked. If a transcribed proof fails, the cause is a transcription or environment
  difference (namespace, import, `variable` binder, library option) — fix that, do not rewrite
  the mathematics.
- **Do NOT import `Mathlib.Order.Filter.Germ` or `Mathlib.Order.Filter.FilterProduct`.**
  `Filter.Germ` is stated for a fixed `β`; the dependent `Filter.Product` carries only `coeTC`
  and `Inhabited`. Settled in the 491 decision record.
- **Do NOT use `Filter.atTop` for the index ultrafilter.** `Filter.atTop_neBot` requires a
  registered `Preorder` **instance** plus `IsDirectedOrder` and `Nonempty` on a `List` subtype
  (verified signature, report §2.1) — a global instance-graph commitment for a single-use order.
  The hand-built `tailFilter` is both shorter and instance-free. Do not import
  `Mathlib.Order.Filter.AtTopBot.*`.
- **Do NOT attack Łoś at `TruthAt` directly.** Prove it at `ShiftTruth` (whose `box` clause
  quantifies over `S.Carrier`, `ShiftSet.lean:261-265`) and transport by conjugating with
  `ShiftSet.forward_repr` (`:278`). The direct route re-opens risk R2 — a choice-function
  argument over total world-histories — which this route discharges by reuse.
- **Do NOT write `rw` where it must see through `uShiftSet`.** `uShiftSet` is semireducible;
  `(uShiftSet φ S).Carrier` will not reduce during motive typing and `omk f` is rejected as
  ill-typed. Use term-level `Iff.trans` / `exact` / `refine`, which check at default transparency.
- **Do NOT drop `@[reducible]` from `UT`.** Measured: a plain `noncomputable def` breaks both
  `rw [← mk_zero]` and `rw [mk_abs]` inside `uSep`.
- **Do NOT leave the probe holding a second copy of the carrier construction.** Two carrier
  constructions in one tree is exactly the forking hazard the task's sequencing note warns about.
- **Do NOT write any `sorry`, `sorryAx`, or `axiom` into the new modules.** This task has a
  zero-debt acceptance criterion. There are no planned strategic sorries; this is not a skeleton
  plan.
- **Do NOT write files under `.claude/**`.** Not applicable to this task's scope, but standing.

**MUST preserve**:

- The two prototype files under `specs/492_.../prototype/` — they are the transcription source
  and the audit trail. Leave them in place unmodified.
- `Tests/BimodalTest.lean:17`'s import of the probe. The probe becomes a consumer (Phase 4), not
  a deleted file, so the axiom-profile regression check survives.
- Every existing declaration in `FormalSystem/Semantics/ShiftSet.lean`. This task adds modules;
  it does not edit `ShiftSet.lean`.
- Green `lake build` at the end of every phase.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Carrier route (a)**: bespoke quotient of the Pi group `(∀ i, D i)` by its eventually-zero
  `AddSubgroup`. `AddCommGroup` inherited from `QuotientAddGroup.Quotient.addCommGroup`; only
  `LE`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` supplied by hand, plus `DenselyOrdered`
  on the Dense branch. Route (b) (carrier normalization first) is a NO-GO — the only
  normalization machinery in the tree is Discrete-only and `discrete_consequence_not_compact`
  refutes compactness exactly at Discrete.
- **The index ultrafilter is hand-built**: a 16-line up-set filter plus `Ultrafilter.of`.
- **Łoś is proved at `ShiftTruth`, then transported to `TruthAt`** by `forward_repr`.
- **Three cases need choice, not one.** The task description's "five are mechanical, the box case
  is the real content" is **wrong**, and the compiled prototype outranks it. `untl` and `snce`
  each carry both an `∃ s : D` and a bounded `∀ r : D` (`ShiftSet.lean:266-269`), so each needs a
  witness-section extraction in one direction and a counterexample-section extraction in the
  other. They are the two longest cases in the prototype. Size them accordingly.
- **All signatures are written against `T : I → TemporalOrder`**, not `D : I → Type` plus four
  binders. The 491 report's `SatisfiableBaseSet` and `ShiftSet` signatures are STALE; the live
  ones are `FormalSystem/Metalogic/SetConsequence.lean:225-228` and
  `FormalSystem/Semantics/ShiftSet.lean:83`.
- **Namespace**: `FormalSystem.Semantics.Ultraproduct` throughout the four new modules.

## Goals & Non-Goals

**Goals**:

- Four new modules under `FormalSystem/Semantics/Ultraproduct/`: `Carrier.lean`,
  `IndexFilter.lean`, `ShiftSetProduct.lean`, `Los.lean`.
- All four imported from `FormalSystem/Semantics.lean`, hence under `@[default_target]
  lean_lib FormalSystem` and covered by `lake build`. No lakefile change.
- `los` (Łoś for `ShiftTruth`, six cases) and `los_truthAt` (Łoś for `TruthAt`) proved sorry-free.
- The probe reduced to a consumer of the promoted modules, so the tree holds exactly one carrier
  construction.
- `#print axioms` recorded for `los_truthAt` (and the four supporting declarations) in the
  implementation summary.

**Non-Goals**:

- `ModelExistenceBase` / `ModelExistenceDense` (`SetConsequence.lean:238`, `:282`). That is S4, a
  separate task. It will need a new module under `FormalSystem/Metalogic/`. Nothing it consumes
  is missing after this task — report §5.4 enumerates the list.
- Any change to `FormalSystem/Semantics/ShiftSet.lean`, `Truth.lean`, or `SetConsequence.lean`.
- Any change to `lakefile.lean`.
- Generalizing `IndexFilter.lean` beyond the generic `α : Type u` form it already has, or
  specializing it to `Formula`. Either instantiation works; keep the generic form as written.

## Risks & Mitigations

- **Risk R-BUILD (the one open verification gap)**: no full `lake build` was ever run.
  `lean_run_code` elaborates against built oleans but does not exercise the aggregator import or
  `lean_lib FormalSystem`'s `leanOptions` — specifically `autoImplicit := false`
  (`lakefile.lean:10-13`). Any accidentally-implicit variable surfaces only under the library
  options. **Mitigation**: Phase 1 establishes a green `lake build` with the new modules wired in
  *before* any later phase adds content on top. **Partial pre-mitigation**: `lean_lib BimodalTest`
  carries the identical `theoryLeanOptions`, so the probe's 16 promoted declarations already
  compile under `autoImplicit := false` today; the residual exposure is the five new support
  lemmas plus the three later modules.
- **Risk R-NS (trap 1)**: `ShiftTruth` is declared inside `namespace ShiftSet`
  (`ShiftSet.lean:114`, def at `:261`), so its full name is
  `FormalSystem.Semantics.ShiftSet.ShiftTruth`. `open FormalSystem.Semantics` alone is not
  enough. **Symptom**: an error reading "Function expected at ShiftTruth but this term has type
  ?m.N". **Mitigation**: `open FormalSystem.Semantics.ShiftSet (ShiftTruth)` in `Los.lean`;
  surfaced in Phase 3.
- **Risk R-RED (trap 2)**: `UT` must be `@[reducible]` or two `rw`s inside `uSep` fail with
  "Application type mismatch … expected to have type `(UT φ T).carrier`". `TemporalOrder.of` is
  itself `@[reducible]` for the same reason (`TemporalOrder.lean:99-102`). **Mitigation**:
  Phase 2 writes the attribute and carries the load-bearing docstring explaining why.
- **Risk R-RW (trap 3)**: `rw [show … from Iff.rfl]` fails in the `imp` case because `uShiftSet`
  is semireducible. **Mitigation**: Phase 3 uses `(imp_congr (ihψ f x) (ihχ f x)).trans
  Ultrafilter.eventually_imp.symm` verbatim.
- **Risk R-NEBOT (trap 4)**: the `bot` case is **not** `Iff.rfl`; `∀ᶠ i in φ, False → False`
  needs `Eventually.exists`, which takes `[f.NeBot]`. It resolves automatically for an
  `Ultrafilter` coercion but the case is two lines, not zero. **Mitigation**: Phase 3 transcribes
  the prototype's `bot` case verbatim.
- **Risk R-IMPORT**: `Carrier.lean` needs `Mathlib.GroupTheory.QuotientGroup.Basic`, which the
  probe reaches transitively through `FormalSystem.Semantics.ShiftSet`. `Carrier.lean` imports
  only `FormalSystem.Semantics.TemporalOrder`, so the import must be stated explicitly.
  **Mitigation**: Phase 1 lists it in the import block; if `lake build` reports an unbuilt
  Mathlib module, that is a cache fetch, not a design problem.
- **Risk R-LINT**: both prototypes carry `set_option linter.unusedSectionVars false`. Without it,
  the promoted declarations emit unused-section-variable warnings. Warnings do not fail
  `lake build`, but the tree's convention is a warning-free build. **Mitigation**: carry the
  `set_option` line into each module that needs it, as the prototypes do.
- **Risk R-PROBE**: reducing the probe (Phase 4) could break `Tests/BimodalTest.lean`'s import or
  lose the axiom-profile regression check. **Mitigation**: Phase 4 keeps the file and its import,
  replacing only its body; `lake build` plus `lake test` are the gate.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

This plan is fully sequential: each phase's module imports the previous phase's module, and each
phase's `lake build` gate depends on the previous phase's modules existing and being green. There
are no parallel opportunities. Phase 1 contains two mutually independent files (`Carrier.lean`
and `IndexFilter.lean`) which a single dispatch writes in either order; that independence is
noted as a partial-completion checkpoint, not as a parallel wave.

### Phase 1: Ultraproduct leaf modules (Carrier.lean, IndexFilter.lean) wired to a green lake build [COMPLETED]

- **Goal:** Create `FormalSystem/Semantics/Ultraproduct/` holding the two leaf modules that
  depend on nothing else in this task, wire both into the aggregator, and establish the first
  green `lake build` under `lean_lib FormalSystem`'s `autoImplicit := false`. This is the phase
  that closes risk R-BUILD; nothing later may be built on an unverified aggregator wiring.
- **Files to modify:**
  - `FormalSystem/Semantics/Ultraproduct/Carrier.lean` (new)
  - `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` (new)
  - `FormalSystem/Semantics.lean` (add two import lines after `:21`)
- **Tasks:**
  - [x] Create `FormalSystem/Semantics/Ultraproduct/Carrier.lean` with the standard copyright
        header, namespace `FormalSystem.Semantics.Ultraproduct`, imports
        `FormalSystem.Semantics.TemporalOrder`, `Mathlib.GroupTheory.QuotientGroup.Basic`,
        `Mathlib.Order.Filter.Ultrafilter.Basic`, and `set_option linter.unusedSectionVars false`.
  - [x] Promote, verbatim, the 16 carrier declarations from
        `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`: `evZero` (`:80`),
        `mem_evZero` (`:90`), `UD` (`:94`), `mk` (`:97`), `mk_eq_mk` (`:99`), the `LE` instance
        (`:109`), `mk_le_mk` (`:118`), the `LinearOrder` instance (`:121`), the
        `IsOrderedAddMonoid` instance (`:153`), `not_eventually_false` (`:165`), `mk_lt_mk`
        (`:169`), the `Nontrivial` instance (`:181`), the `DenselyOrdered` instance (`:188`),
        `carrierSetoid` / `UOmega` / `omk` / `omk_eq_omk` / `omk_surjective` (`:206`-`:225`),
        `shU` / `shU_mk` (`:228` / `:236`), and `shU_zero` / `shU_add` (`:239` / `:246`).
        Keep the section `variable` block `{I : Type} {φ : Ultrafilter I} {D : I → Type}` with the
        three instance binders. Do **not** promote `shiftSetOnUD` (it stays in the probe until
        Phase 4 retargets it).
  - [x] Add the five new support lemmas from `prototype/UltraproductLos.lean`: `exists_section`
        (`:28`), `mk_surjective` (`:34`), `mk_zero` (`:43`), `mk_max` (`:45`), `mk_abs` (`:55`).
        `mk_zero`/`mk_max`/`mk_abs` need the `Order` section's `[∀ i, LinearOrder (D i)]` and
        `[∀ i, IsOrderedAddMonoid (D i)]` binders.
  - [x] Create `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` with the copyright header,
        namespace `FormalSystem.Semantics.Ultraproduct`, import
        `Mathlib.Order.Filter.Ultrafilter.Basic` only, and promote verbatim `Idx` (`:20`),
        `tailFilter` (`:23`), `mem_tailFilter` (`:40`), `tailFilter_neBot` (`:43`), `idxUF`
        (`:51`), `eventually_mem` (`:55`) from `prototype/IndexFilter.lean`. Keep the generic
        `universe u` / `variable {α : Type u}` form.
  - [x] Write a module docstring for each file to this tree's standard (see
        `FormalSystem/Semantics/ShiftSet.lean:1-61` for the register): what the module is, what it
        is not, and — for `IndexFilter.lean` — why `Filter.atTop` was rejected.
  - [x] Add to `FormalSystem/Semantics.lean` immediately after line 21
        (`import FormalSystem.Semantics.ShiftSet`):
        `import FormalSystem.Semantics.Ultraproduct.Carrier` and
        `import FormalSystem.Semantics.Ultraproduct.IndexFilter`. Add matching entries to the
        aggregator's `## Submodules` docstring list.
  - [x] Run `lake build`. Fix any `autoImplicit := false` fallout by naming the implicit binder
        explicitly — never by weakening the library options and never by editing `lakefile.lean`.
  - [x] Grep the two new files for `sorry`; expect zero hits.
- **Verification criteria:**
  - `lake build` exits 0 with no errors. (Standing gate for every phase.)
  - `grep -rn 'sorry' FormalSystem/Semantics/Ultraproduct/` returns nothing.
  - `#print axioms FormalSystem.Semantics.Ultraproduct.eventually_mem` reports
    `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.
  - `#print axioms FormalSystem.Semantics.Ultraproduct.exists_section` reports the same profile.
  - Both new modules appear in `FormalSystem/Semantics.lean`'s import list.
- **Estimated output:** ~320 lines across two new files plus 2 import lines and a docstring edit.
- **Scope Hypothesis:** "~320 lines, 21 promoted declarations + 5 new support lemmas + 6 filter
  declarations" is a hypothesis derived from arithmetic on the two prototypes (216 + 62 lines)
  plus module docstrings written to this tree's substantial standard. Confirm at implementation
  time by `wc -l` on the two created files and by counting `theorem`/`def`/`instance` headers
  against the enumerated list above. If the count runs materially higher than 320, that indicates
  docstring expansion, not scope creep — do not treat it as a signal to add content.
- **Partial-completion checkpoint:** `Carrier.lean` and `IndexFilter.lean` are mutually
  independent (neither imports the other). If the dispatch is running out of room after one of
  them is green, commit that file plus its single aggregator import line, mark this phase
  `[PARTIAL]`, and name the remaining file as the resume point. Do **not** leave the aggregator
  importing a module that does not exist.
- **Timing:** 2 hours
- **Depends on:** none
- **Verification Tier:** full
- **Commit Mode:** per-substep — commit `Carrier.lean` + its import line when green, then
  `IndexFilter.lean` + its import line when green.

### Phase 2: ShiftSetProduct.lean — UT, uSep, and the seven-field uShiftSet [COMPLETED]

- **Goal:** Build the ultraproduct temporal order and the ultraproduct shift set: `UT`, the `sep`
  field discharged on the ultraproduct (`uSep`), and `uShiftSet` with all seven `ShiftSet` fields
  and no hypotheses.
- **Files to modify:**
  - `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` (new)
  - `FormalSystem/Semantics.lean` (one import line)
- **Tasks:**
  - [x] Create `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean`, namespace
        `FormalSystem.Semantics.Ultraproduct`, importing
        `FormalSystem.Semantics.Ultraproduct.Carrier` and `FormalSystem.Semantics.ShiftSet`.
        Section variables `{I : Type} {φ : Ultrafilter I} {T : I → TemporalOrder}`.
  - [x] Transcribe `UT` from `prototype/UltraproductLos.lean:69`, **with `@[reducible]`** and with
        the docstring recording why the attribute is load-bearing (risk R-RED). Note that
        `∀ i, AddCommGroup ↑(T i)` and the other three binders synthesize because
        `TemporalOrder`'s four projections are instances (`TemporalOrder.lean:91`) — no binder
        list is needed on `T`.
  - [x] Transcribe `uSep` from `:72-94` verbatim: `haveI : ∀ i, Nonempty ↑(T i) := fun i => ⟨0⟩`,
        `omk_surjective` twice, `by_contra`, `Ultrafilter.eventually_not`, the `push_neg`
        contrapositive of `(S i).sep` (`ShiftSet.lean:110`), `exists_section` for the radius
        section, `rw [← mk_zero]`, `mk_surjective`, `rw [mk_abs]`, `rw [shU_mk]`, and
        `Eventually.exists` on the triple intersection.
  - [x] Transcribe `uShiftSet` from `:98-109`, all seven fields: `Carrier := UOmega φ (fun i =>
        (S i).Carrier)`, `carrier_nonempty` via `(S i).carrier_nonempty.some`, `sh := shU (fun i
        => (S i).sh)`, `sh_zero`, `sh_add`, `sep := uSep S`, and the `A` valuation with its
        `Quotient.liftOn` well-definedness obligation.
  - [x] Module docstring: what the module supplies and the explicit statement that `uShiftSet`
        discharges all seven fields with no hypotheses (contrast the probe's `shiftSetOnUD`,
        which takes `carrier_nonempty`, `sep` and `A` as hypotheses).
  - [x] Add `import FormalSystem.Semantics.Ultraproduct.ShiftSetProduct` to
        `FormalSystem/Semantics.lean` after the Phase 1 imports; extend the `## Submodules` list.
  - [x] Run `lake build`.
- **Verification criteria:**
  - `lake build` exits 0.
  - `grep -n 'sorry' FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` returns nothing.
  - `#print axioms FormalSystem.Semantics.Ultraproduct.uSep` and
    `#print axioms FormalSystem.Semantics.Ultraproduct.uShiftSet` both report
    `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
  - `UT` carries the `@[reducible]` attribute (grep the file).
  - `uShiftSet` elaborates with signature `(S : ∀ i, ShiftSet (T i)) → ShiftSet (UT φ T)` and no
    extra hypotheses — confirm with `#check @uShiftSet`.
- **Estimated output:** ~110 lines (one new file) plus 1 import line.
- **Scope Hypothesis:** "~110 lines, 3 declarations" is derived from
  `prototype/UltraproductLos.lean:60-109` (50 lines of proof) plus module header and docstrings.
  Confirm by `wc -l` and by `#check`ing all three declarations exist.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Verification Tier:** full
- **Commit Mode:** per-substep

### Phase 3: Los.lean — the Łoś lemma for ShiftTruth (six cases) and for TruthAt [NOT STARTED]

- **Goal:** Prove `los` (Łoś at `ShiftTruth`, by induction on `Formula`, all six cases) and
  `los_truthAt` (Łoś at `TruthAt`, by conjugating `los` with `ShiftSet.forward_repr`). This is
  the task's headline deliverable and the longest single transcription.
- **Files to modify:**
  - `FormalSystem/Semantics/Ultraproduct/Los.lean` (new)
  - `FormalSystem/Semantics.lean` (one import line)
- **Tasks:**
  - [ ] Create `FormalSystem/Semantics/Ultraproduct/Los.lean`, namespace
        `FormalSystem.Semantics.Ultraproduct`, importing
        `FormalSystem.Semantics.Ultraproduct.ShiftSetProduct`. **Open `ShiftTruth` explicitly**:
        `open FormalSystem.Semantics.ShiftSet (ShiftTruth)` — risk R-NS. `open FormalSystem.
        Semantics` alone is not enough; `ShiftTruth` lives inside `namespace ShiftSet`
        (`ShiftSet.lean:114`, def at `:261`).
  - [ ] State `los` with the **binder order from `prototype/UltraproductLos.lean:120-123`**:
        `(S : ∀ i, ShiftSet (T i)) (χ : Formula) : ∀ (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i)), …`.
        `χ` must come before `f` and `x`. An IH fixed at `f`, `x` closes none of `box`, `untl`,
        `snce`. Carry the docstring explaining this.
  - [ ] Install the carrier `Nonempty` instance **before** `induction`:
        `haveI : ∀ i, Nonempty ((S i).Carrier) := fun i => (S i).carrier_nonempty`.
  - [ ] `atom`: `intro f x; exact Iff.rfl`.
  - [ ] `bot`: **not** `Iff.rfl` (risk R-NEBOT). Transcribe
        `⟨fun h => h.elim, fun h => by obtain ⟨_, hi⟩ := h.exists; exact hi⟩` from `:127`.
  - [ ] `imp`: use `exact (imp_congr (ihψ f x) (ihχ f x)).trans Ultrafilter.eventually_imp.symm`
        (`:132`). **Do not** attempt `rw [show … from Iff.rfl]` — risk R-RW. Carry the inline
        comment recording why.
  - [ ] `box` (`:133-145`): `→` by `by_contra`, then `Ultrafilter.eventually_not.mpr` +
        `not_forall.mp` + `exists_section` over `(S i).Carrier`, then `.and`/`.exists`. `←` by
        `omk_surjective` and the IH — no choice, no ultrafilter property.
  - [ ] `untl` (`:146-171`): **two** `exists_section` calls, one per direction. `→` destructures
        `⟨s, hs, he, hg⟩`, recovers `σ` by `mk_surjective`, and proves the inner bounded `∀` by a
        nested `by_contra` whose chosen section `ρ` must satisfy **three** pointwise conditions at
        once (`x i < ρ i`, `ρ i < σ i`, and the negation) so that `mk ρ` lands strictly inside the
        open interval before `hg` applies. `←` extracts the witness section by `exists_section`,
        then handles the bounded `∀` by `mk_surjective` on the bound variable.
  - [ ] `snce` (`:172-197`): the mirror of `untl` with the two order comparisons swapped.
  - [ ] State and prove `los_truthAt` (`:205-211`) as the three-line term:
        `(ShiftSet.forward_repr _ _ _ _).trans ((los S χ f x).trans (eventually_congr
        (Eventually.of_forall fun i => (ShiftSet.forward_repr (S i) (f i) (x i) χ).symm)))`.
        Carry the docstring explaining that risk R2 is discharged by reuse: `forward_repr`'s own
        `box` case (`ShiftSet.lean:278`ff) already reconciles `TruthAt`'s quantifier over all
        total histories with `ShiftTruth`'s quantifier over the carrier, via `hist_isTotal`
        (`:226`) and `total_eq_orbit` (`:245`).
  - [ ] Module docstring covering the routing decision (why not `TruthAt` directly) and the
        three-cases-need-choice correction.
  - [ ] Add `import FormalSystem.Semantics.Ultraproduct.Los` to `FormalSystem/Semantics.lean`;
        extend the `## Submodules` list.
  - [ ] Run `lake build`.
- **Verification criteria:**
  - `lake build` exits 0.
  - `grep -n 'sorry' FormalSystem/Semantics/Ultraproduct/Los.lean` returns nothing.
  - **The acceptance criterion**: `#print axioms FormalSystem.Semantics.Ultraproduct.los_truthAt`
    reports exactly `[propext, Classical.choice, Quot.sound]`. `Classical.choice` is expected and
    acceptable; `sorryAx` MUST be absent. Record the literal tool output in the commit body and
    in the implementation summary.
  - `#print axioms FormalSystem.Semantics.Ultraproduct.los` reports the same profile.
  - `#check @los_truthAt` shows the `TruthAt` form from report §3.2 — the deliverable the task
    named.
  - All six `Formula` constructors are handled with no `admit`, no `native_decide`, no `axiom`.
- **Estimated output:** ~130 lines (one new file) plus 1 import line.
- **Scope Hypothesis:** "~130 lines, 2 declarations, 6 induction cases" is derived from
  `prototype/UltraproductLos.lean:111-211` (100 lines) plus docstrings. The `untl` and `snce`
  cases are each ~25 lines — roughly 20 lines longer than a "mechanical transport" estimate would
  give — because each carries two `exists_section` calls. Confirm by `wc -l` and by counting the
  six `| ... =>` case arms.
- **Timing:** 2 hours
- **Depends on:** 2
- **Verification Tier:** full
- **Commit Mode:** per-substep — `los` is committable green on its own, before `los_truthAt` is
  added.

### Phase 4: Retire the probe to a consumer and record the acceptance evidence [NOT STARTED]

- **Goal:** Eliminate the second carrier construction from the tree by reducing
  `DependentUltraproductProbe.lean` to a consumer of the promoted modules, and record the full
  acceptance evidence for the task.
- **Files to modify:**
  - `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` (replace body)
  - `FormalSystem/Semantics/README.md` (add the `Ultraproduct/` subdirectory entry, if the file
    enumerates submodules — check first; skip with a note if it does not)
  - `specs/492_build_shiftset_ultraproduct_and_los_lemma/summaries/01_shiftset-ultraproduct-los-summary.md` (new)
- **Tasks:**
  - [ ] Replace the probe's body: keep the copyright header, retarget the module docstring to say
        the carrier construction has been promoted to
        `FormalSystem/Semantics/Ultraproduct/Carrier.lean` and that this file is now the
        axiom-profile regression check. Replace `import FormalSystem.Semantics.ShiftSet` +
        `Mathlib.Order.Filter.Ultrafilter.Basic` with
        `import FormalSystem.Semantics.Ultraproduct.Los`.
  - [ ] Delete the 16 promoted declarations from the probe. Retarget `shiftSetOnUD` (`:262`) at
        `uShiftSet` — i.e. replace it with an elaboration check that `uShiftSet φ S :
        ShiftSet (UT φ T)` type-checks, which is the same measurement (`ShiftSet` accepts the
        ultraproduct carrier, and the quotient lands in `Type` not `Type 1`) now stated against
        the real construction rather than a hypothesis-laden stand-in.
  - [ ] Keep the `#print axioms` lines, retargeted at `uShiftSet`, `los`, `los_truthAt`, and
        `eventually_mem`, so the axiom-profile regression check survives under a build target.
  - [ ] Confirm `Tests/BimodalTest.lean:17`'s `import BimodalTest.Semantics.
        DependentUltraproductProbe` is untouched and still resolves.
  - [ ] Run `lake build` and `lake test`.
  - [ ] Verify the tree holds exactly one carrier construction:
        `grep -rn 'def evZero\|abbrev UD\|def carrierSetoid\|def UOmega' FormalSystem/ Tests/`
        must report hits only in `FormalSystem/Semantics/Ultraproduct/Carrier.lean`.
  - [ ] Write the implementation summary at
        `specs/492_.../summaries/01_shiftset-ultraproduct-los-summary.md`, pasting the literal
        `#print axioms` output for `los_truthAt`, `los`, `uShiftSet`, `uSep`, and
        `eventually_mem`, plus the `lake build` result and a `sorry` count of zero.
- **Verification criteria:**
  - `lake build` exits 0; `lake test` passes.
  - `grep -rn 'sorry' FormalSystem/Semantics/Ultraproduct/` returns nothing (final check).
  - Exactly one definition site for `evZero`, `UD`, `carrierSetoid`, `UOmega` across
    `FormalSystem/` and `Tests/`.
  - The probe still compiles, still imported from `Tests/BimodalTest.lean`, and its
    `#print axioms` lines still report `[propext, Classical.choice, Quot.sound]`.
  - The summary file exists and contains the pasted axiom output for `los_truthAt`.
- **Estimated output:** ~80 lines of edits (probe body replacement is mostly deletion) plus a
  summary artifact.
- **Scope Hypothesis:** "the probe shrinks from 289 lines to roughly 60" is a hypothesis; confirm
  by `wc -l` before and after. The list of declarations to delete is exactly the 21 enumerated in
  Phase 1 — if a declaration in the probe is not on that list and is not `shiftSetOnUD` or a
  `#print axioms` line, stop and report it rather than deleting it.
- **Timing:** 1.5 hours
- **Depends on:** 3
- **Verification Tier:** full
- **Commit Mode:** per-substep

## Testing & Validation

- [ ] `lake build` green after every phase (standing gate, `Verification Tier: full` throughout).
- [ ] `lake test` green after Phase 4.
- [ ] `grep -rn 'sorry\|sorryAx\|admit' FormalSystem/Semantics/Ultraproduct/` returns nothing.
- [ ] `#print axioms FormalSystem.Semantics.Ultraproduct.los_truthAt` reports
      `[propext, Classical.choice, Quot.sound]` — `Classical.choice` acceptable, `sorryAx` absent.
      This is the task's named acceptance criterion; the literal output is pasted into the
      implementation summary.
- [ ] Same axiom check for `los`, `uShiftSet`, `uSep`, `eventually_mem`.
- [ ] `#check @FormalSystem.Semantics.Ultraproduct.los_truthAt` matches report §3.2's `TruthAt`
      statement shape.
- [ ] `#check @FormalSystem.Semantics.Ultraproduct.uShiftSet` takes no hypotheses beyond
      `S : ∀ i, ShiftSet (T i)`.
- [ ] Single-carrier-construction check (Phase 4 verification criteria).
- [ ] No file under `.claude/**` was written; no change to `lakefile.lean`; no change to
      `FormalSystem/Semantics/ShiftSet.lean`.

## Artifacts & Outputs

- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` (new, ~250 lines)
- `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` (new, ~70 lines)
- `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` (new, ~110 lines)
- `FormalSystem/Semantics/Ultraproduct/Los.lean` (new, ~130 lines)
- `FormalSystem/Semantics.lean` (modified: four import lines + `## Submodules` docstring entries)
- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` (modified: reduced to a consumer)
- `specs/492_build_shiftset_ultraproduct_and_los_lemma/plans/01_shiftset-ultraproduct-los.md` (this file)
- `specs/492_build_shiftset_ultraproduct_and_los_lemma/summaries/01_shiftset-ultraproduct-los-summary.md`

## Rollback/Contingency

- Each phase ends at a green, committable milestone, so rollback is `git revert` of the last
  phase commit. The `Ultraproduct/` directory is additive: reverting Phases 1-3 means deleting
  the created files and removing the corresponding import lines from `FormalSystem/Semantics.lean`.
  Nothing outside that directory is touched until Phase 4.
- Phase 4 is the only phase that modifies pre-existing content
  (`DependentUltraproductProbe.lean`). If it fails, revert it alone: the probe's original body is
  in git history, and Phases 1-3 stand independently — the tree is green with a duplicated
  carrier construction, which is a known-tolerable interim state, not a broken one.
- If a transcribed proof fails to elaborate under `autoImplicit := false` and the fix is not
  obvious within the dispatch, the correct move is to name the failing declaration and its exact
  error in the handoff and stop — **not** to insert a `sorry`, **not** to weaken `lakefile.lean`,
  and **not** to re-derive the proof. The prototype is compiled evidence that the statement is
  provable; the failure is environmental.
