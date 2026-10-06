# Implementation Plan: Task #711

- **Task**: 711 - Universal-summary substrate for the `⊡` fibre check on the seam-gluing route
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours
- **Dependencies**: 732 (satisfied — E3 reported; the selection is carried in the task description and in `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`'s header)
- **Research Inputs**: specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md
- **Artifacts**: plans/01_universal-summary-substrate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build the universal-summary substrate E3 selected — candidate (d), the **time-axis
Ramsey-coloured summary**, framed by the MSO-over-`⟨ℤ,<⟩` quasimodel route (c) — as a generic
library cluster `FormalSystem/Metalogic/Decidability/RaySummary/` over an abstract per-time
alphabet, consumed downstream by the assembly record (task 735) and never absorbed into it. The
substrate is five deliverables in dependency order: **D1** the idempotent homogeneous colour
(compiled during research, from the in-tree `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`);
**D2** the segment-profile colouring of a per-time-alphabet presentation with its composition
law; **D3** the device theorem on one ray — a fulfilling run exists iff a homogeneous
self-looping profile is reachable — in both directions; **D4** the backward ray by reindexing;
and **D5** the `⊡` bridge, stated against an abstract realization hypothesis `Presents`, plus the
ultimately-periodic specialization that gives the summary its `Decidable` instance. Two evidence
probes close the record: the executability discrimination between (c) and (d) on the E1
infinite fibre, and the depth-2 stratification probe E2.

Definition of done: every module under `RaySummary/` compiles sorry-free on standard axioms
(`[propext, Classical.choice, Quot.sound]` or a subset), each headline theorem's axiom profile
is pinned in `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean`, both probes are wired into
`scripts/check-evidence-probes.sh` and the collection passes, and
`bash scripts/check-module-invariants.sh` is green (C24, C33 and the README checks included).

Constraints honoured throughout (from the task description, unchanged by research): no
complexity bound is claimed anywhere; the CTL* 2EXPTIME lower bound (argued, not proved) is a
sanity ceiling only; the probed `⊡(Fp)`/`⊡(Pp)` shapes do not discriminate devices and no phase
may claim they do; the two honest limits E3 recorded are carried (the `⊡(Pp)` real-formula bridge
stays at step-graph level in the library — D4 lifts the *abstract* backward ray only — and the
(c)/(d) shared-core claim is Medium after research's Thomas 1997 check, not settled); the
substrate is built here and consumed by 735, which is the sole consumer (712 is refuted and is
not one); this plan builds no decision procedure for `PlusValidZTime` and claims no decidability
of the logic.

### Research Integration

- **Device identity (report D-1, Executive Summary bullet 1).** Candidate (d) is Büchi's own
  Ramsey proof of the complementation step inside route (c) (Thomas 1997 §5.1 p. 30, read
  directly). Consequence adopted: the discrimination probe (Phase 9) records an
  **executability** discrimination with a hand-proved equivalence, never a truth-value split.
- **D1 is already compiled** (report "Tactic Survey Results", `#print axioms` = pcq for both
  the forward and backward lemmas). Phase 2 lands the two lemmas verbatim; zero proof risk.
- **Relocation of the Ramsey ingredient (report D-2, Recommendation 2).** Adopted as the
  primary route: `section Ramsey` of `RamseyFactorization.lean` moves to
  `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` under a Mathlib-style name,
  with a one-line alias at the old name so every durable anchor (ROADMAP, E3's probe header,
  `scripts/check-evidence-probes.sh`'s table, the report) keeps resolving. Rationale: it avoids a
  `Decidability → WeakCanonical.GroupModel` import (which would pull `MonoDiscrete` and
  `GoodGroupable` into the decidability side's graph) and is what `ForMathlib/README.md` exists
  for. The fallback (direct import of `RamseyFactorization`) is recorded under
  Risks & Mitigations and costs nothing if Phase 1's registrations prove more entangled than
  estimated.
- **D2–D5 Lean-ready shapes (report "The substrate, stated").** Adopted with one correction
  recorded as Decision D-6 below: the profile datum carries a **deficit set** in addition to the
  discharge set, because the `⇐` splice must secure fulfilment for every *intermediate* position
  of a period witness, which the discharge set alone cannot see.
- **The splice is independent choice, not dependent choice.** With the profile recording both
  endpoint types, every period witness starts and ends at the same type `b` with the same datum,
  so the `⇐` construction chooses each segment witness independently (`Classical.choose` per
  segment) and glues; `exists_seq_of_forall_finset_exists` (report "External Resources") is not
  needed. Recorded here so the implementer does not reach for it.
- **One-sided live sets (report D5, HWZ Def 12 / Lemma 17 hazard).** In this plan's
  `SeamPresentation`, the two one-sided live flags are exactly `fwd.ExistsFulfillingFrom a` and
  `bwd.ExistsFulfillingFrom a` — the device computes them, so the quasistate carries them by
  construction. The `Presents.complete` field is where the HWZ splice hazard is paid, and its
  docstring must say so (Phase 8).
- **E2 has no written specification** beyond the ranking's falsifier sentence (report claim 11).
  Phase 10 defines E2 from that sentence, on a fresh two-state fixture whose depth-1 `⊡`-value
  is state-dependent (the shared Bool fixture's is not, so it cannot exercise two layers).
- **Axiom pinning.** The report proposed a pin "in the invariants harness"; the C14 baseline is
  an inline `#print axioms` list in a 6,000-line script, so this plan pins through the
  sanctioned test pattern `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`
  (`#guard_msgs` + `#print axioms`) instead. Minor deviation, recorded in `issues.jsonl`.
- **Context-extension recommendations** (report "Context Extension Recommendations") target
  `.claude/context/**`, which is a deploy artifact in this repository
  (`.claude/rules/source-store-deploy-boundary.md`); they are out of scope here and listed under
  Non-Goals as a follow-up for the source store.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided and `roadmap_flag` is not set; no roadmap phases are included.
For orientation only (read, not modified): `specs/ROADMAP.md` Phase 1 names the critical path
**711 → 735**, lists this task's item ("Build the universal-summary substrate … Also carries the
depth-2 stratification probe E2"), and records that the evidence collection has three writers
(733, 734, this task) so probes are dispatched singly.

## Goals & Non-Goals

**Goals**:

- Land `exists_idempotent_homogeneous` and `exists_idempotent_homogeneous_bwd` (D1) in
  `RaySummary/Colour.lean`, verbatim from the compiled research proofs, on standard axioms.
- Relocate infinite Ramsey for pairs to `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`
  with the old name kept as an alias.
- Build D2 (`RaySummary/Profile.lean`), D3 (`RaySummary/Forward.lean`), D4
  (`RaySummary/Backward.lean`), the periodic specialization (`RaySummary/Periodic.lean`) and D5
  (`RaySummary/Stab.lean`), each sorry-free on standard axioms, with headline results
  `RaySummary.exists_fulfilling_iff`, `RaySummary.exists_fulfilling_bwd_iff`,
  `RaySummary.exists_fulfilling_iff_periodic`, `RaySummary.plusStab_iff_summary` and the
  decidability instance for the universal summary of an ultimately periodic seam presentation.
- Pin every headline axiom profile in `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean`.
- Write and wire two evidence probes: `ray-summary-discrimination-probe.lean` and
  `stab-depth-two-probe.lean`, and run the whole collection (the collection is the gate).
- Keep every durable anchor resolving: `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`,
  `FormalSystem.PlusLanguage.plusStab_iff_omega`,
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`.

**Non-Goals**:

- Discharging `Presents` for the sliced certificate or any concrete frame other than the probe
  fixtures; assembling `Decidable (PlusValidZTime φ)`; any statement that L⁺ is decidable. All of
  that is the consumer's (735's) work.
- Proving a real-formula `⊡(Pp)` bridge on the Bool fixture (E3's first honest limit stays).
- Formalizing Büchi's theorem, any ω-automaton, or any MSO decision procedure; `msoSentence` in
  Phase 9 is a specification `Prop`, never discharged mechanically.
- Any complexity claim, upper or lower.
- F4 for the sliced certificate's restricted fragment (task 709 instantiates D3/D4 there).
- Editing `.claude/context/**` (deploy artifact): the report's two context-extension
  recommendations (a "route (1)'s hard step" paragraph for `ztime-no-finite-carrier-fmp.md` §8;
  retagging HWZ 2000 / GKWZ 2003 provenance via `/literature --validate`) are left for the
  source store.
- Adding rows to `docs/theorem-index.md` (the ledger of flagship results; the substrate's
  headlines are pinned in the test module instead). The path stays in `file_scope` unused.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Relocation to `ForMathlib/` trips C24/C33/README checks in ways not listed in Phase 1 | M | M | Phase 1 lists every registration site found by grep; if a check still fails after the listed edits, take the recorded fallback: leave `section Ramsey` in place, import `RamseyFactorization` from `Colour.lean`, and record the cross-front dependency in `RaySummary/README.md`. Both routes are sorry-free; no later phase depends on which one was taken |
| `Profile.comp_assoc` and `profile_comp` are the fiddly `Finset` lemmas (report risk "low–medium") | M | M | Prove `mem_comp_iff` first and do associativity by `Finset.ext` through it; keep `Profile` a plain `Finset` of tuples (no quotient, no `Set`) so `decide`-style reasoning and `Finset.image`/`filter` lemmas apply |
| D3 `⇐` splice bookkeeping (the research's "risk R3") | H | M | Decision D-6's deficit set makes the splice uniform: every period witness realizes the same `(b, b, E, U)`, so witnesses are chosen independently and glued by a segment-index function; Phase 5 names the exact lemmas to prove in order |
| The `⇒` direction's sub-colouring fails the composition law at the edges | M | L | Discharge/deficit sets are defined on half-open segments (`[n, m)` for pending, `(n, m]` for discharge); Phase 3's `dischargeSet_union`/`deficitSet_comp` lemmas are stated for exactly those conventions and proved before D3 begins |
| The periodic bound (powers of a finite-semigroup element repeat within the carrier's cardinality) is awkward to state | M | M | Phase 7 proves the repeat lemma once by pigeonhole (`Finite.exists_ne_map_eq_of_infinite` on `m ↦ Q ^ m`) and quantifies over exponents `≤ Fintype.card (Profile Ty Ev)`; the `Decidable` instance is existence-level computable, with no performance claim |
| `Presents` is the wrong shape for 735's concrete presentation | M | M | `Presents` is a hypothesis bundle, not a procedure; its two fields are the two directions of HWZ Thm 14 for this semantics and the docstring names the one-sided-live obligation. 735 may generalize it; nothing here is lost |
| Evidence-collection contention (`scripts/check-evidence-probes.sh` is in 733's and 734's `file_scope`) | M | M | Dispatch singly, as the ROADMAP already instructs; Phases 9 and 10 each re-read the script before editing and append, never rewrite |
| `decide` on `Profile` values is infeasible for the probe's cross-checks | L | H | The probe proves verdict facts by hand against the library theorems and uses `#eval` + `#guard_msgs` (the axiom-test precedent) only as supplementary evidence; no probe claim rests on kernel evaluation |
| A phase runs past its context budget | M | M | Every phase is one agent run (~100–500 lines of output); on pressure, checkpoint with `bash .claude/scripts/git-snapshot.sh --no-revert 711` and write the continuation handoff per `context/contracts/wrap-up.md` |

## Decisions

- **D-6 Profile datum carries a deficit set.** `Profile Ty Ev := Finset (Ty × Ty × Finset Ev × Finset Ev)`,
  a tuple `(a, b, E, U)` meaning: a partial run from `a` at `n` to `b` at `m` exists whose
  **discharge set** over `(n, m]` is `E` and whose **deficit set** — eventualities pending at some
  position in `[n, m)` and not discharged at any later position `≤ m` — is `U`. Composition:
  `(a, c, E₁ ∪ E₂, (U₁ \ E₂) ∪ U₂)` from `(a, b, E₁, U₁)` and `(b, c, E₂, U₂)`. Why: with the
  discharge set alone, the `⇐` splice can only secure obligations pending at the junction type
  `b`; an obligation pending at an interior position of a period witness and not discharged
  inside that witness would be invisible. With `U`, the device condition `U ⊆ E` (every
  obligation carried out of a period is discharged in the next, identical, period) secures every
  live position at once — which is the content task 709's record calls the second `⊡` repair, and
  which the research attributed to idempotence. Idempotence is kept in the statement (it is what
  D1 delivers and what Büchi's `U · V^ω` form names) but the `⇐` direction uses only homogeneity
  on consecutive segments.
- **D-7 D4 by reindexing, not by mirroring code.** A backward ray out of the seam is an
  ω-sequence against time (`BwdSeq`), so a backward presentation *is* a `FwdPresentation` under
  `n ↦ t - n` with `suit` read in the reversed direction. `Backward.lean` therefore defines the
  reindexing and derives `exists_fulfilling_bwd_iff` as a corollary of D3; the ℤ-indexed
  `exists_idempotent_homogeneous_bwd` from D1 is its colour-level companion. No second copy of
  `Forward.lean`.
- **D-8 Axiom pins live in `BimodalTest`, not in C14.** See Research Integration.
- **D-9 Challenge statements pin D1 only.** D2–D5's statements depend on definitions
  (`Profile`, `FwdPresentation`, `SeamPresentation`) that this plan specifies but that the
  implementation phases fix in detail; pinning them as Challenge statements would turn every
  representation adjustment into a `[BLOCKED]` round trip on the critical path. Their intended
  signatures are given in the phases as the plan's contract under `.claude/rules/plan-compliance.md`
  (decomposition fidelity); the two D1 lemmas, compiled during research, are pinned exactly.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6, 7 | 5 |
| 7 | 8 | 6 |
| 8 | 9 | 7, 8 |
| 9 | 10 | 9 |

Phases within the same wave can execute in parallel. Under `--hard` each phase is one dispatch;
Phases 6 and 7 are independent (both consume Phase 5) but touch the shared aggregator and test
module, so if they are run in parallel each must append to those two files rather than rewrite
them. Phase 10 depends on Phase 9 only to serialize edits to `scripts/check-evidence-probes.sh`.

### Phase 1: Relocate infinite Ramsey for pairs to ForMathlib, alias kept [COMPLETED WITH EXCLUSIONS]

**Exclusions** (Phase 1): `bash scripts/check-module-invariants.sh` exits 1 on the single
pre-existing check C9 (a task-number citation at `scripts/check-phantom-citations.sh:145`,
committed by task 728 in `729dc345f`, a file outside this phase's territory and untouched here);
every other check is green (full run: C1 build, C24, C33, C5, C12/C13, C28, INV all PASS). The
phase's own gates — both `lean_verify`s, the no-`FormalSystem` import rule, the probe collection
(16/16 PASS) — are met in full.

**Goal**: Move `section Ramsey` (lines 65–170 of
`FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`: the private helpers
`ramsey_step_exists` … `ramseySeq_pair_col` and the theorem `infinite_ramsey_pairs`) into a new
Mathlib-namespace module, keep the old name as a one-line alias, and register the module at every
site the `ForMathlib/` convention requires, so that the decidability side can import the Ramsey
ingredient without importing `WeakCanonical.GroupModel`.

**Tasks**:

- [x] Re-verify the baseline before moving anything:
      `lean_verify FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` (expected axioms
      `[propext, Classical.choice, Quot.sound]`, no sorry), and grep every citation of the name
      outside `specs/`: `FormalSystem/Metalogic/WeakCanonical.lean`,
      `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`,
      `scripts/check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.
      None of these needs editing if the alias keeps the name; confirm after the move.
- [x] Create `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` with the copyright
      header, imports `Mathlib.Data.Set.Finite.Lattice`, `Mathlib.Logic.Denumerable`,
      `Mathlib.Data.Fintype.Pigeonhole` (exactly the three the section uses today; drop any the
      build shows unused), **no** `FormalSystem.*` import, `namespace Nat`, the moved section
      verbatim (private helpers unchanged), and the public theorem renamed
      `Nat.exists_strictMono_const_pair_colour` with the same statement
      `∀ {C : Type} [Finite C] (c : ℕ → ℕ → C), ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j, i < j → c (g i) (g j) = τ`.
      Module docstring: what it is (infinite Ramsey for pairs, absent from Mathlib at pin
      `v4.33.0-rc1`: `Combinatorics/Hindman.lean` and `HalesJewett.lean` mention it only), the
      Doets 1987 ch. 7 (pp. 89–93) provenance carried from the old header, and the Mathlib-shaped
      name rationale.
- [x] In `RamseyFactorization.lean`: delete the section, add
      `import FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs`, keep the docstring'd
      `theorem infinite_ramsey_pairs (c : ℕ → ℕ → C) : … := Nat.exists_strictMono_const_pair_colour c`
      at the same name in the same namespace (`FormalSystem.Metalogic.WeakCanonical`), and update
      the module docstring's "proved from scratch here" sentence to point at the new module. Keep
      the `variable {C : Type} [Finite C]` the alias needs.
- [x] Register the module: add the import and a Contents bullet to `FormalSystem/ForMathlib.lean`;
      add `` `FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs `` to `exceptions` in
      `scripts/CheckInitImportsMain.lean` (C24); update the exception sentence in
      `FormalSystem/Init.lean`'s docstring (it currently enumerates two `ForMathlib` modules);
      create `FormalSystem/ForMathlib/Combinatorics/README.md` on the `Order/README.md` pattern;
      add the `Combinatorics/` bullet to `FormalSystem/ForMathlib/README.md`'s Related
      Documentation and regenerate its inventory table with
      `bash scripts/check-module-invariants.sh --emit-inventory` (hand-write the trailing
      description cell); update the `RamseyFactorization.lean` row and the
      `infinite_ramsey_pairs` bullet in `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`
      and the mention in `FormalSystem/Metalogic/WeakCanonical.lean` to say "alias of". *(deviation: altered — `--emit-inventory` also rewrote the rollup blocks of `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `README.md`; staged with the phase)*
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem` (C33 requires
      `FormalSystem.lean` byte-current).
- [x] Build the two touched roots, detached and guarded:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.ForMathlib FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization`;
      then `lean_verify` both names (same axiom set as the baseline).
- [x] Run `bash scripts/check-module-invariants.sh` (full, with build) and
      `bash scripts/check-evidence-probes.sh` (E3's probe cites the alias). Both green. *(deviation: altered — probes green (16/16); the harness is green on every check except the pre-existing C9 named in the Exclusions above, which is out of this phase's territory)*
- [x] Commit via `git-commit-scoped.sh` (`task 711 phase 1: relocate infinite Ramsey for pairs to ForMathlib`),
      staging only the files listed below.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: Eleven files are touched and ~110 lines move with **zero** proof edits
beyond the namespace change and the alias. Confirm by `lean_verify` on both names after the
build; if any proof in the moved section needs editing, record it with `issue-record.sh`
(`--class "tooling bug or gap"` or the concrete class) because the section's only dependencies
were the three Mathlib imports.

**Files to modify**:

- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` - new; the moved section under `Nat.exists_strictMono_const_pair_colour`
- `FormalSystem/ForMathlib/Combinatorics/README.md` - new; subdirectory README on the `Order/README.md` pattern
- `FormalSystem/ForMathlib.lean` - import + Contents bullet
- `FormalSystem/ForMathlib/README.md` - inventory row (regenerated) + Related Documentation bullet
- `FormalSystem/Init.lean` - docstring's recorded-exception sentence
- `scripts/CheckInitImportsMain.lean` - C24 exception entry
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` - section removed, import added, alias theorem, header sentence
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md` - row and bullet wording
- `FormalSystem/Metalogic/WeakCanonical.lean` - mention wording
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify Nat.exists_strictMono_const_pair_colour` and
  `lean_verify FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` both report
  `[propext, Classical.choice, Quot.sound]`, no sorry.
- `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing.
- `bash scripts/check-module-invariants.sh` exits 0 (C24, C33, C5, C12/C13 among them);
  `bash scripts/check-evidence-probes.sh` exits 0.

---

### Phase 2: D1 — Colour.lean, the RaySummary aggregator and the axiom-pin test module [NOT STARTED]

**Goal**: Land the two compiled D1 lemmas in `FormalSystem/Metalogic/Decidability/RaySummary/Colour.lean`,
create the cluster's aggregator and README, wire the cluster into `Decidability.lean`, and create
the test module that pins the substrate's axiom profiles from this phase onward.

**Tasks**:

- [ ] Create `RaySummary/Colour.lean`: header; imports
      `FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs` (or, under Phase 1's fallback,
      `FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization`) and
      `FormalSystem.Init`; `namespace FormalSystem.Metalogic.Decidability.RaySummary`. Module
      docstring: what the colour step is (Büchi's complementation core, Thomas 1997 §5.1 p. 30),
      why the time axis and not states (`…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`
      forces infinite fibres; E3's `Probe732Device.not_lasso_sufficient_on_chain` refutes
      pigeonhole over states), and what it does NOT claim (no complexity bound; no adequacy
      beyond what D3 proves). Cite declaration names, never task numbers.
- [ ] Transcribe, verbatim from the report's Tactic Survey (the compiled proofs):
      `theorem exists_idempotent_homogeneous {C : Type} [Finite C] (comp : C → C → C) (c : ℕ → ℕ → C) (hc : ∀ i j k, i < j → j < k → c i k = comp (c i j) (c j k)) : ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧ ∀ i j, i < j → c (g i) (g j) = τ`
      (obtain from Ramsey; instances `hτ 0 1`, `hτ 1 2`, `hτ 0 2`; one `rw` with `hc`), and
      `theorem exists_idempotent_homogeneous_bwd {C : Type} [Finite C] (comp : C → C → C) (c : ℤ → ℤ → C) (t : ℤ) (hc : ∀ a b d : ℤ, a < b → b < d → c a d = comp (c a b) (c b d)) : ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧ ∀ i j, i < j → c (t - g j) (t - g i) = τ`
      (Ramsey on `fun i j => c (t - j) (t - i)`; casts by `exact_mod_cast`; do **not** insert the
      `simp only at …` the first research attempt used — it made no progress).
- [ ] Create the aggregator `FormalSystem/Metalogic/Decidability/RaySummary.lean` importing
      `RaySummary.Colour` (later phases append), and add
      `import FormalSystem.Metalogic.Decidability.RaySummary` to
      `FormalSystem/Metalogic/Decidability.lean` with a one-paragraph entry in its docstring's
      cluster list (the sliced certificate's paragraph is the model).
- [ ] Create `RaySummary/README.md` on the `PlusSlicedCertificate/README.md` pattern: why the
      cluster exists beside `PlusSlicedCertificate/` (finite width refuted → summaries over the
      time axis), the five deliverables D1–D5 with their modules (only `Colour.lean` landed at
      this phase; the rest listed as planned, to be updated as they land), the consumer relation
      (built here, consumed by the assembly), and the two carried limits. Add the two rows
      (`RaySummary.lean`, `RaySummary/`) to `FormalSystem/Metalogic/Decidability/README.md`'s
      module table.
- [ ] Create `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` on the
      `PeriodicExtensionAxiomTest.lean` pattern (permanent evidence, not a test; the "when a guard
      fires" rule), pinning with `#guard_msgs` + `#print axioms`:
      `Nat.exists_strictMono_const_pair_colour` (or the fallback name),
      `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`,
      `…RaySummary.exists_idempotent_homogeneous`, `…RaySummary.exists_idempotent_homogeneous_bwd`
      — all expected `[propext, Classical.choice, Quot.sound]`. Register it in
      `Tests/BimodalTest.lean` next to `PeriodicExtensionAxiomTest`.
- [ ] `lake exe mk_all --lib FormalSystem`; build detached and guarded:
      `… -- build FormalSystem.Metalogic.Decidability.RaySummary BimodalTest.Metalogic.RaySummaryAxiomTest`;
      `lean_verify` both D1 names.
- [ ] Run `bash scripts/check-module-invariants.sh`; commit
      (`task 711 phase 2: land D1 colour step and axiom pins`).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: `Colour.lean` is ~80 lines and both proofs compile unchanged from the
report. Confirm by `lean_verify`; if either proof needs more than cast repairs, stop and record
the divergence (the report states both compiled in `lean_run_code` against the same tree).

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Colour.lean` - new; D1
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - new; cluster aggregator
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - new; cluster README
- `FormalSystem/Metalogic/Decidability.lean` - import + docstring entry
- `FormalSystem/Metalogic/Decidability/README.md` - two module-table rows
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - new; axiom pins
- `Tests/BimodalTest.lean` - import registration
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify` on both D1 names: pcq, no sorry.
- `lake build BimodalTest.Metalogic.RaySummaryAxiomTest` (guarded) exits 0 with no
  `#guard_msgs` mismatch.
- `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 3: D2 — Profile.lean: segment profiles of a per-time-alphabet presentation [NOT STARTED]

**Goal**: Define the finite alphabet of per-time summaries and prove its composition law, so that
D1 applies to `c n m := P.profile n m`.

**Tasks**:

- [ ] Create `RaySummary/Profile.lean` (imports `RaySummary.Colour`, Mathlib `Finset` basics as
      needed). Section variables `{Ty Ev : Type} [Fintype Ty] [DecidableEq Ty] [Fintype Ev] [DecidableEq Ev]`.
- [ ] `structure FwdPresentation (Ty Ev : Type) … where real : ℕ → Finset Ty; suit : ℕ → Ty → Ty → Bool; pending : Ty → Finset Ev; discharged : Ty → Finset Ev`
      — HWZ Def 10's state function, time-indexed along one ray (index `n` is time `t + n` from
      the seam for the forward ray; Phase 6 reindexes the backward ray).
- [ ] `def FwdPresentation.IsRun (P) (r : ℕ → Ty) : Prop := (∀ n, r n ∈ P.real n) ∧ ∀ n, P.suit n (r n) (r (n+1)) = true`;
      `def Fulfilling (P) (r) : Prop := ∀ n, ∀ e ∈ P.pending (r n), ∃ m, n < m ∧ e ∈ P.discharged (r m)`;
      `def ExistsFulfillingFrom (P) (a : Ty) : Prop := ∃ r, P.IsRun r ∧ r 0 = a ∧ P.Fulfilling r`.
- [ ] `abbrev Profile (Ty Ev) := Finset (Ty × Ty × Finset Ev × Finset Ev)` with the `Fintype`
      instance inherited; `def Profile.comp (p q : Profile Ty Ev) : Profile Ty Ev` by
      `(p ×ˢ q).filter (fun x => x.1.2.1 = x.2.1) |>.image (fun x => (x.1.1, x.2.2.1, x.1.2.2.1 ∪ x.2.2.2.1, (x.1.2.2.2 \ x.2.2.2.1) ∪ x.2.2.2.2))`
      (shape per Decision D-6; write it with named projections if a `structure` tuple reads
      better, but keep it a `Finset` of a `Fintype`); `theorem mem_comp_iff`; `theorem comp_assoc`
      (by `Finset.ext` through `mem_comp_iff`, with the set identity
      `((U₁ \ E₂) ∪ U₂) \ E₃ ∪ U₃ = (U₁ \ (E₂ ∪ E₃)) ∪ ((U₂ \ E₃) ∪ U₃)`); `def Profile.id (S : Finset Ty) := S.image fun a => (a, a, ∅, ∅)`
      with `id_comp`/`comp_id` on profiles whose endpoint types lie in `S`.
- [ ] `def FwdPresentation.step (P) (n : ℕ) : Profile Ty Ev` — the one-step profile:
      `(a, b, P.discharged b, P.pending a \ P.discharged b)` for `a ∈ P.real n`, `b ∈ P.real (n+1)`,
      `P.suit n a b = true`; `def profile (P) (n m : ℕ) : Profile Ty Ev` by recursion on `m - n`
      with `profile n n = Profile.id (P.real n)` and `profile n (m+1) = (profile n m).comp (P.step m)`
      for `n ≤ m`.
- [ ] `theorem profile_comp (P) {n m k} (h₁ : n ≤ m) (h₂ : m ≤ k) : P.profile n k = (P.profile n m).comp (P.profile m k)`
      (induction on `k - m` using `comp_assoc`).
- [ ] Partial runs and the semantic reading: `def IsPartialRun (P) (w : ℕ → Ty) (n m : ℕ) : Prop`
      (`w i ∈ P.real i` and `P.suit i (w i) (w (i+1)) = true` for `n ≤ i < m`);
      `def dischargeSet (P) (w) (n m) : Finset Ev := (Finset.Ioc n m).biUnion fun i => P.discharged (w i)`;
      `def deficitSet (P) (w) (n m) : Finset Ev := (Finset.Ico n m).biUnion fun i => P.pending (w i) \ (Finset.Ioc i m).biUnion fun j => P.discharged (w j)`;
      `theorem mem_profile_iff (P) {n m} (h : n ≤ m) {a b E U} : (a, b, E, U) ∈ P.profile n m ↔ ∃ w, P.IsPartialRun w n m ∧ w n = a ∧ w m = b ∧ P.dischargeSet w n m = E ∧ P.deficitSet w n m = U`
      (induction on `m - n`; the step case is `mem_comp_iff` plus the two segment identities
      `dischargeSet_union` : `dischargeSet w n k = dischargeSet w n m ∪ dischargeSet w m k` and
      `deficitSet_comp` : `deficitSet w n k = (deficitSet w n m \ dischargeSet w m k) ∪ deficitSet w m k`
      for `n ≤ m ≤ k`; prove these two first, as standalone lemmas — they are also what Phase 4's
      sub-colouring needs).
- [ ] `instance : DecidableEq (Profile Ty Ev)` is inherited; add
      `instance (P) (n m) : Decidable ((a, b, E, U) ∈ P.profile n m)` only if not already
      synthesized. Add `#print axioms` for `profile_comp` and `mem_profile_iff` at the foot during
      development, remove before commit, and pin both in `RaySummaryAxiomTest.lean`.
- [ ] Append the import to `RaySummary.lean`; `mk_all`; guarded build of
      `FormalSystem.Metalogic.Decidability.RaySummary.Profile` and the test module; update the
      cluster README's D2 row; commit (`task 711 phase 3: segment profiles and composition law`).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: 250–350 lines; `comp_assoc` and `mem_profile_iff` are the two lemmas that
can run long. Confirm by line count at commit; if `mem_profile_iff` exceeds ~80 lines, split the
step case into `mem_profile_succ` (one-step extension of a partial run) and compose.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` - new; D2
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import appended
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - D2 row
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pins for `profile_comp`, `mem_profile_iff`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify` on `…RaySummary.FwdPresentation.profile_comp` and `…mem_profile_iff`: no sorry,
  axioms within pcq.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 4: D3 (⇒) — Forward.lean: a fulfilling run yields a homogeneous self-looping profile [NOT STARTED]

**Goal**: Prove the necessity direction of the device theorem on the forward ray by Ramsey on
the run's own segment colouring.

**Tasks**:

- [ ] Create `RaySummary/Forward.lean` (imports `RaySummary.Profile`). Module docstring: the
      device theorem's two directions and their sources (Thomas 1997 §5.1 p. 30 for the Ramsey
      form; HWZ 2000 Lemma 17 pp. 14–15 and Lemma 23 for the splice/periodic form it replaces),
      and the carried limit that this is the abstract ray, not a real-formula bridge.
- [ ] State the device condition once, as a definition, so both directions and Phase 7 share it:
      `def FwdPresentation.DeviceCondition (P) (a : Ty) : Prop := ∃ n b E₀ U₀ E U, (a, b, E₀, U₀) ∈ P.profile 0 n ∧ U₀ ⊆ E ∧ ∃ τ : Profile Ty Ev, τ.comp τ = τ ∧ (b, b, E, U) ∈ τ ∧ U ⊆ E ∧ ∃ g : ℕ → ℕ, StrictMono g ∧ ∀ i j, i < j → P.profile (n + g i) (n + g j) = τ`.
- [ ] Sub-colouring of a run: `def runColour (P) (r : ℕ → Ty) (i j : ℕ) : Profile Ty Ev := {(r i, r j, P.dischargeSet r i j, P.deficitSet r i j)}`;
      `theorem runColour_comp (hr : P.IsRun r) {i j k} (h₁ : i < j) (h₂ : j < k) : runColour P r i k = (runColour P r i j).comp (runColour P r j k)`
      (from `mem_comp_iff`, `dischargeSet_union`, `deficitSet_comp`);
      `theorem runColour_subset_profile (hr : P.IsRun r) {i j} (h : i ≤ j) : runColour P r i j ⊆ P.profile i j`
      (from `mem_profile_iff` with `w := r`).
- [ ] Fulfilment forces `U ⊆ E` on a homogeneous tail: with `g` strictly monotone and the colour
      constant `τ = {(b, b, E, U)}` on all `i < j`, every `e ∈ U` (pending at some position in
      `[g i, g (i+1))`, not discharged by `g (i+1)`) is discharged at some `u > g (i+1)` by
      `Fulfilling`; pick `k` with `g k > u` (`StrictMono.id_le`/`exists_gt`); then
      `e ∈ dischargeSet r (g (i+1)) (g k) = E`. Same argument for the prefix deficit `U₀` of
      `[0, g 0)`.
- [ ] Assemble `theorem deviceCondition_of_exists_fulfilling (P) (a) : P.ExistsFulfillingFrom a → P.DeviceCondition a`:
      apply `exists_idempotent_homogeneous` to `c i j := runColour P r i j` (composition law
      from `runColour_comp`; `Finite (Profile Ty Ev)` by instance); the homogeneous idempotent
      `τ` is a singleton `{(b, b, E, U)}` with `b = r (g 0)`; set `n := g 0` and reindex `g` to
      `g' i := g i - g 0` so the sequence starts at `0`. Note that the theorem's `τ` is the
      singleton, which is **not** `P.profile (n + g' i) (n + g' j)` in general — the condition
      requires equality of profiles, so either (a) state `DeviceCondition` with `τ ⊆ P.profile …`
      and membership, or (b) apply Ramsey to `c i j := P.profile (g i) (g j)` directly (composition
      law `profile_comp`) and then extract the run's triple by `runColour_subset_profile`. Take
      **(b)** — it keeps `DeviceCondition` as stated and the idempotent `τ` is then a genuine
      profile; the run's triple `(b, b, E, U)` lies in it by the subset lemma, and `U ⊆ E` follows
      from the fulfilment argument above applied to the run's own discharge sets, which are
      subsets of the profile-level data only through membership — so carry the run's triple, not
      an arbitrary element of `τ`. Record this choice in the docstring.
- [ ] `#print axioms`; pin `deviceCondition_of_exists_fulfilling` in the test module; append the
      import to `RaySummary.lean`; `mk_all`; guarded scoped build; README D3 row ("⇒ landed, ⇐
      next"); commit (`task 711 phase 4: device theorem, necessity direction`).

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: 250–400 lines. Confirm at commit; if the fulfilment-forces-`U ⊆ E` step
runs long, factor it as `deficit_subset_discharge_of_fulfilling` over an explicit pair of times
before touching the Ramsey assembly.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Forward.lean` - new; `DeviceCondition`, `runColour`, the ⇒ direction
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import appended
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - D3 row
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pin for the ⇒ theorem
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …RaySummary.FwdPresentation.deviceCondition_of_exists_fulfilling`: no sorry, pcq.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 5: D3 (⇐) — the splice: a homogeneous self-looping profile yields a fulfilling run [NOT STARTED]

**Goal**: Prove the sufficiency direction and close the device theorem on the forward ray as an
equivalence.

**Tasks**:

- [ ] Settled-design preamble (restate in the dispatch): strategy is construction; witnesses are
      chosen independently per segment (Decision D-6, "independent choice"); the glued run is
      indexed by a segment-lookup function; inherited sorries: none.
- [ ] Prefix witness: from `(a, b, E₀, U₀) ∈ P.profile 0 n` obtain `w₀` with
      `IsPartialRun w₀ 0 n`, `w₀ 0 = a`, `w₀ n = b`, deficit `U₀` (`mem_profile_iff`).
- [ ] Period witnesses: for each `i`, from `(b, b, E, U) ∈ τ = P.profile (n + g i) (n + g (i+1))`
      obtain `wᵢ` with `IsPartialRun wᵢ (n + g i) (n + g (i+1))`, endpoints `b`, discharge `E`,
      deficit `U`. Package as `w : ℕ → (ℕ → Ty)` by `Classical.choose` (no dependency between
      segments: all endpoints are `b` and all data are `(E, U)`).
- [ ] Segment lookup: `def segIdx (n : ℕ) (g : ℕ → ℕ) (m : ℕ) : ℕ := Nat.findGreatest (fun i => n + g i ≤ m) m`
      (well-defined since `StrictMono g` gives `i ≤ g i`); lemmas `segIdx_spec` (`n + g (segIdx m) ≤ m < n + g (segIdx m + 1)` for `m ≥ n + g 0`) and `segIdx_eq_of_mem`.
- [ ] The glued run: `def splice … (m : ℕ) : Ty := if m < n + g 0 then w₀ m else w (segIdx n g m) m`;
      prove `IsRun` (each position and each consecutive pair falls inside one witness's segment,
      or at a junction where both witnesses read `b`), and `splice 0 = a`.
- [ ] Fulfilment of the splice: for a position `m` with pending `e`: if `m` lies in witness `i`'s
      segment and `e` is discharged inside `(m, n + g (i+1)]`, done; else `e ∈ U` (by the
      deficit characterization, `mem_profile_iff` direction `→` applied to `wᵢ`), so `e ∈ E`
      (`U ⊆ E`), so `e` is discharged in `(n + g (i+1), n + g (i+2)]` (witness `i+1`'s discharge
      set is `E`). Prefix positions use `U₀ ⊆ E` and witness `0`. Factor as
      `fulfilling_splice`.
- [ ] `theorem exists_fulfilling_of_deviceCondition (P) (a) : P.DeviceCondition a → P.ExistsFulfillingFrom a`
      and the headline
      `theorem exists_fulfilling_iff (P : FwdPresentation Ty Ev) (a : Ty) : P.ExistsFulfillingFrom a ↔ P.DeviceCondition a`.
- [ ] `#print axioms`; pin `exists_fulfilling_iff` in the test module; README D3 row complete;
      guarded scoped build; commit (`task 711 phase 5: device theorem, sufficiency direction`).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: 250–400 lines added to `Forward.lean` (total ≤ 800, within the 1500-line
linter limit). The segment-lookup lemmas are hypothesized at ~60 lines; if `Nat.findGreatest`'s
API fights the proof, define `segIdx` by a bounded `Nat.rec` instead and record the switch.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Forward.lean` - the ⇐ direction and `exists_fulfilling_iff`
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - D3 row
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pin for `exists_fulfilling_iff`

**Verification**:

- `lean_verify …RaySummary.FwdPresentation.exists_fulfilling_iff`: no sorry, pcq.
- Guarded build of `…RaySummary.Forward` and the test module exits 0.

---

### Phase 6: D4 — Backward.lean: the backward ray by reindexing [NOT STARTED]

**Goal**: Deliver the device theorem for the backward ray out of the seam as a corollary of D3,
honouring the carried limit (abstract ray only; no real-formula `⊡(Pp)` bridge).

**Tasks**:

- [ ] Create `RaySummary/Backward.lean` (imports `RaySummary.Forward`). Docstring: the backward
      ray is an ω-sequence against time (`FormalSystem.PlusLanguage.BwdSeq`), so a backward
      presentation is a forward one under `n ↦ t - n` with `suit` read in the reversed direction;
      state the carried limit verbatim (the `⊡(Pp)` real-formula bridge is fixed only by
      `Probe719Backward.pastStab_iff_allBwdPathsMeet` on its fixture and is not lifted here).
- [ ] `structure BwdPresentation (Ty Ev) … where real : ℕ → Finset Ty; suit : ℕ → Ty → Ty → Bool; pending discharged : Ty → Finset Ev`
      with the reading "`suit n x y` relates the type `y` at index `n` (time `t - n`) to the type
      `x` at index `n+1` (time `t - n - 1`)"; `def BwdPresentation.toFwd (Q) : FwdPresentation Ty Ev`
      (`suit' n a b := Q.suit n b a`, everything else unchanged); `IsRun`, `Fulfilling`,
      `ExistsFulfillingFrom` for `BwdPresentation` defined through `toFwd` (or directly, with
      `toFwd_isRun_iff` etc. proved `Iff.rfl`-style).
- [ ] `theorem exists_fulfilling_bwd_iff (Q : BwdPresentation Ty Ev) (a) : Q.ExistsFulfillingFrom a ↔ Q.toFwd.DeviceCondition a`
      — a one-line corollary; plus the ℤ-indexed colour companion: a lemma showing that for a
      colouring `c : ℤ → ℤ → C` with the composition law, `exists_idempotent_homogeneous_bwd` is
      the `toFwd` reindexing of `exists_idempotent_homogeneous` (documentation value; keep it
      short).
- [ ] Pin `exists_fulfilling_bwd_iff` in the test module; append the import to
      `RaySummary.lean`; `mk_all`; guarded scoped build; README D4 row; commit
      (`task 711 phase 6: backward ray by reindexing`).

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 120–200 lines. Confirm at commit; if the reindexing needs more than the
`toFwd` transport lemmas, that is a signal the forward definitions baked in a direction and
should be reported, not worked around.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Backward.lean` - new; D4
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import appended
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - D4 row
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pin for `exists_fulfilling_bwd_iff`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …RaySummary.BwdPresentation.exists_fulfilling_bwd_iff`: no sorry, pcq.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 7: Periodic.lean — the ultimately periodic specialization and its Decidable instance [NOT STARTED]

**Goal**: Turn the device condition into a bounded, decidable check when the presentation is
ultimately periodic — the computational content the consumer assembles with.

**Tasks**:

- [ ] Create `RaySummary/Periodic.lean` (imports `RaySummary.Forward`). Docstring: this is the
      specialization HWZ Lemma 23 / Theorem 24 and GKWZ Lemma 11.29 reach by successive splicing;
      here it is the idempotent/periodic power of a finite-semigroup element. No performance
      claim: the instance is existence-level computable; its exponent bound is the carrier's
      cardinality.
- [ ] `def FwdPresentation.UltimatelyPeriodic (P) (k p : ℕ) : Prop := 0 < p ∧ ∀ n, k ≤ n → P.real (n + p) = P.real n ∧ P.suit (n + p) = P.suit n`;
      `theorem profile_shift (hP : P.UltimatelyPeriodic k p) {n m} (hn : k ≤ n) (h : n ≤ m) : P.profile (n + p) (m + p) = P.profile n m`;
      `theorem profile_period_pow (hP) (i : ℕ) : P.profile k (k + i * p) = (P.profile k (k + p)) ^ i`
      with `Monoid`-free power defined by recursion (`Profile.pow q 0 := Profile.id S` for the
      relevant `S = P.real k`, `pow q (i+1) := (pow q i).comp q`).
- [ ] Powers repeat: `theorem exists_pow_eq_pow_of_lt_card (q : Profile Ty Ev) (S) : ∃ i j, i < j ∧ j ≤ Fintype.card (Profile Ty Ev) ∧ pow q i = pow q j`
      (pigeonhole, `Finite.exists_ne_map_eq_of_infinite` or `Fintype.exists_ne_map_eq_of_card_lt`),
      hence `pow_mem_bounded : ∀ i, ∃ j ≤ Fintype.card (Profile Ty Ev), pow q i = pow q j` and, for
      `i ≥ 1`, with `1 ≤ j`.
- [ ] The bounded condition:
      `def PeriodicCondition (P) (k p a : ℕ-indexed data) : Prop := ∃ m₀ ≤ N, ∃ m, 1 ≤ m ∧ m ≤ N ∧ ∃ b E₀ U₀ E U, (a, b, E₀, U₀) ∈ (P.profile 0 k).comp (pow Q m₀) ∧ (b, b, E, U) ∈ pow Q m ∧ U ⊆ E ∧ U₀ ⊆ E`
      with `Q := P.profile k (k + p)` and `N := Fintype.card (Profile Ty Ev)`.
- [ ] `theorem exists_fulfilling_iff_periodic (hP : P.UltimatelyPeriodic k p) (a) : P.ExistsFulfillingFrom a ↔ P.PeriodicCondition k p a`.
      `⇐`: build `DeviceCondition` from the bounded data with `n := k + m₀ * p`, `τ := pow Q m`,
      `g i := i * m * p` (homogeneity by `profile_shift`/`profile_period_pow`; idempotence is
      **not** needed by Phase 5's `⇐`, but `DeviceCondition` demands `τ.comp τ = τ` — so either
      take `m` to be an idempotent exponent (exists by the repeat lemma: some `pow Q m` with
      `m ≥ 1` is idempotent) or weaken `DeviceCondition` to drop idempotence; take the former and
      state `exists_idempotent_pow` as its own lemma) then apply `exists_fulfilling_iff.mpr`.
      `⇒`: from a fulfilling run, apply `exists_idempotent_homogeneous` to the run's colouring
      restricted to times `k + i * p` (composition law from `runColour_comp`), read the
      homogeneous triple inside `pow Q (g 1 - g 0)` via `runColour_subset_profile` and
      `profile_period_pow`, bound the exponents with `pow_mem_bounded`, and get `U ⊆ E`, `U₀ ⊆ E`
      exactly as in Phase 4.
- [ ] `instance (hP : P.UltimatelyPeriodic k p) (a) : Decidable (P.ExistsFulfillingFrom a) := decidable_of_iff _ (exists_fulfilling_iff_periodic hP a).symm`
      — the bounded existentials over `Finset.range`/`Fintype` and `Finset` membership are
      decidable by instance search; if `Fintype.card (Profile Ty Ev)` does not reduce for
      instance search, state the bound as a `Nat` argument computed once by `Fintype.card`.
- [ ] Pin `exists_fulfilling_iff_periodic` and the instance (via a theorem naming it) in the
      test module; append the import; `mk_all`; guarded scoped build; README row; commit
      (`task 711 phase 7: periodic specialization and decidable instance`).

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 250–350 lines. The `⇒` direction re-runs Phase 4's argument on a coarser
time grid; if it cannot be obtained by instantiating Phase 4's lemmas (rather than copying them),
Phase 4's lemmas were stated too concretely — generalize them over an arbitrary strictly
monotone time grid there and record the refactor, rather than duplicating.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - new; periodic specialization and `Decidable`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import appended
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - row
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pins
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …RaySummary.FwdPresentation.exists_fulfilling_iff_periodic`: no sorry, pcq.
- The `Decidable` instance elaborates with no `noncomputable` marker needed; guarded scoped
  build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 8: D5 — Stab.lean: the `⊡` bridge against an abstract `Presents` hypothesis [NOT STARTED]

**Goal**: Connect the keystone `FormalSystem.PlusLanguage.plusStab_iff_omega` to the device:
under a stated realization hypothesis, `⊡φ` at a seam is the universal summary over seam types,
and that summary is decidable when both rays are ultimately periodic.

**Tasks**:

- [ ] Create `RaySummary/Stab.lean` (imports `RaySummary.Backward`, `RaySummary.Periodic`,
      `FormalSystem.PlusLanguage.PlusRayFibre`). Docstring: HWZ Thm 14 (p. 11) is the
      realization theorem whose two directions `Presents` names for *this* semantics; HWZ Def 12's
      quasistate is a bare set of types and its Lemma 17 splice can create a realised type the
      model lacked — lethal to a `⊡`-label — which is why `Presents.complete` demands that a type
      live on both rays be realized by one history through the seam (the one-sided-live
      requirement; the tree's finite-width analogue is `PlusSlicedCertificate.live_iff` and
      `PlusSlicedCertificate.stab_factors`). State explicitly that discharging `Presents` for a
      concrete presentation is the consumer's work and that the atomization licence
      (`FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize`) is what lets a consumer
      take `φ` `⊡`-free with a finite alphabet.
- [ ] `structure SeamPresentation (Ty Ev : Type) … where fwd : FwdPresentation Ty Ev; bwd : BwdPresentation Ty Ev; seam : Finset Ty; holds : Ty → Bool`;
      `def SeamPresentation.UniversalSummary (S) : Prop := ∀ a ∈ S.seam, S.fwd.ExistsFulfillingFrom a → S.bwd.ExistsFulfillingFrom a → S.holds a = true`.
- [ ] `structure Presents {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula) (S : SeamPresentation Ty Ev) : Prop where sound : ∀ bf : SeqPair F (τ.state t), ∃ a ∈ S.seam, S.fwd.ExistsFulfillingFrom a ∧ S.bwd.ExistsFulfillingFrom a ∧ (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ S.holds a = true); complete : ∀ a ∈ S.seam, S.fwd.ExistsFulfillingFrom a → S.bwd.ExistsFulfillingFrom a → ∃ bf : SeqPair F (τ.state t), PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ S.holds a = true`.
- [ ] `theorem plusStab_iff_summary (h : Presents M τ t φ S) : PlusTruthAt M τ t (.stab φ) ↔ S.UniversalSummary`
      from `plusStab_iff_omega` and the two fields.
- [ ] `instance (hf : S.fwd.UltimatelyPeriodic k p) (hb : S.bwd.toFwd.UltimatelyPeriodic k' p') : Decidable S.UniversalSummary`
      (finite `∀` over `S.seam` with Phase 7's instances), and the corollary
      `theorem decidable_plusStab_of_presents … : Decidable (PlusTruthAt M τ t (.stab φ))` via
      `decidable_of_iff`. Docstring: this decides the `⊡` clause **given** `Presents`; it is not
      a decision procedure for the logic.
- [ ] Pin `plusStab_iff_summary` in the test module (expected pcq, inherited from
      `plusStab_iff_omega`'s `Classical.choice` through `FrameOver.worldHistoryOfStepPath`; say so
      in the test's section docstring, as `PeriodicExtensionAxiomTest.lean` does for its
      choice-carrying row). Append the import; `mk_all`; guarded scoped build; README D5 row and
      "consumer" paragraph; commit (`task 711 phase 8: stab bridge against Presents`).

**Timing**: 1.5 hours

**Depends on**: 6, 7

**Verification Tier**: full

**Scope Hypothesis**: 200–300 lines, most of it docstring. The bridge theorem itself is short by
design; if the implementer finds `Presents.sound` needs a third field to make the `←` direction
go through, add it and record why — the hypothesis bundle is this plan's to shape, the discharge
is not.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Stab.lean` - new; D5
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import appended
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - D5 row, consumer paragraph
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` - pin for `plusStab_iff_summary`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …RaySummary.plusStab_iff_summary`: no sorry, pcq.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0 (C36
  non-vacuity reads C2's rows only; the substrate's non-trivial inhabitant is Phase 9's probe).

---

### Phase 9: Evidence probe (i) — executability discrimination on the E1 infinite fibre [NOT STARTED]

**Goal**: Record the first behavioural discrimination between the MSO frame (c) and the Ramsey
substrate (d) on a finitely presented infinite fibre with a per-time alphabet, stated honestly:
(d) computes a verdict from profiles; (c) yields an MSO `Prop` discharged only by hand; both
agree, and the probe exhibits a non-trivial inhabitant of `Presents`.

**Tasks**:

- [ ] Create `specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean`
      (`import FormalSystem` only — the collection's standing rule; `namespace Probe711Discrimination`).
      Transcribe (never import) E1's time-asymmetric step graph from
      `backward-dual-asymmetric-fixture.lean`: carrier `pre k / x k / post k j`, the four step
      rules, the frame by `FrameOver.ofReflectiveRegular` with saturation from finite fibres, `p`
      true exactly at the `x` states. Re-grep `Probe719Backward.pastStab_iff_allBwdPathsMeet`,
      `past_stab_at_post`, `not_past_stab_at_x` before citing.
- [ ] Type level: `Ty := Kind × Bool` (kind `pre/x/post` and the value of `Pp`), `Ev := Unit`
      (the single backward eventuality "`Pp` pending: a `p`-state must occur in the past");
      the backward presentation `bwdP : BwdPresentation Ty Ev` (constant in the index, hence
      `UltimatelyPeriodic 0 1`), `suit` enforcing kind-steps and `Pp`-propagation, `pending (_, true) = {()}`,
      `discharged (x, _) = {()}`; the forward presentation with no pending eventualities; the seam
      presentations for a `post` state and for an `x` state with `holds (_, v) = v`.
- [ ] The (d)-verdict: evaluate `UniversalSummary` for both seams via
      `exists_fulfilling_iff_periodic` — prove `summary_post : S_post.UniversalSummary` and
      `not_summary_x : ¬ S_x.UniversalSummary` by hand from the bounded condition (exhibit the
      period witness `(b, b, E, U)` with `U ⊆ E` for `post`; show no seam type with `holds = false`
      is doubly live for `post`, and that `(x, false)` is doubly live for `x`). Optionally add
      `#eval`/`#guard_msgs` evidence that the `Decidable` instance computes on these inputs; a
      claim rests on the hand proofs, never on evaluation.
- [ ] Discharge `Presents` on the fixture for `φ := Pp` at the two seams (the non-vacuity
      inhabitant): `sound` from the fixture's unique-predecessor structure (`step_inv_*`-style
      lemmas transcribed from E1) and `complete` by building the `SeqPair` from the two witness
      runs. Then cross-check: `plusStab_iff_summary` + `summary_post` recovers
      `past_stab_at_post`'s value, and `not_summary_x` recovers `not_past_stab_at_x`'s. State
      both as theorems `verdict_post`, `verdict_x` whose statements are `PlusTruthAt … (.stab (Pp))`
      and its negation, proved through the library, and note in the docstring that
      `Probe719Backward` proved the same facts by direct backward reachability.
- [ ] The MSO side: write `msoSentence (P : BwdPresentation Ty Ev) (a) : Prop` as GKWZ's `qm_φ`
      (Lemma 11.23, p. 478) for one ray — `∃ R : Ty → ℕ → Prop`, the `R` partition the index set,
      respect `real`, step by `suit`, start at `a`, and every pending eventuality is discharged
      later — and prove `msoSentence_iff_exists_fulfilling : msoSentence P a ↔ P.ExistsFulfillingFrom a`
      by hand. Header paragraph: (c) adds no verdict (d) lacks; its discharge theorem (Büchi,
      HWZ Thm 15 p. 13, "by a result of Büchi") has no Lean formalization, so on this fibre (d)
      is executable and (c) is a specification — the discrimination is executability, not truth
      value (report D-1).
- [ ] Header, in the collection's style: what is established (two seam verdicts through the
      substrate; a `Presents` inhabitant; the hand-proved MSO equivalence), what is NOT (no
      backward Bool-fixture bridge; no claim beyond this fixture and `⊡(Pp)`; no complexity
      bound; (c)/(d) coincide here by construction), axiom record, and the compile line
      `lake env lean specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean`.
      `#print axioms` foot for the four headline theorems.
- [ ] Wire: re-read `scripts/check-evidence-probes.sh`, append a `WIRED` table row and array
      entry in the existing style; run the **whole** collection (`bash scripts/check-evidence-probes.sh`),
      expected all wired probes PASS, exit 0. Commit (`task 711 phase 9: discrimination probe on the E1 fibre`),
      staging the probe and the script only.

**Timing**: 2 hours

**Depends on**: 7, 8

**Verification Tier**: local

**Scope Hypothesis**: 350–500 lines; the `Presents` discharge is the long part (E1's own
backward argument was ~100 lines with `Classical.choice`). If `Presents.sound` for the `x` seam
needs the full canonicity argument, prove `sound` for the `post` seam only, state the `x`-side
verdict through `not_summary_x` plus `complete` (which is the direction that matters for a
`False` verdict), and record the asymmetry in the header rather than overrunning.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean` - new; probe (i)
- `scripts/check-evidence-probes.sh` - WIRED row + entry (append only)

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean`
  exits 0, no warnings, `grep -c sorry` is 0, `#print axioms` within pcq.
- `bash scripts/check-evidence-probes.sh` exits 0 for the whole collection.

---

### Phase 10: Evidence probe (ii) — E2, the depth-2 stratification probe [NOT STARTED]

**Goal**: Define and run E2 from the ranking's falsifier sentence ("a `⊡`-depth-2 formula whose
`⊡`-value at a class is not a function of the class's summary state"): instantiate the
stratification theorem at depth 2 on a fixture whose depth-1 `⊡`-value is state-dependent, decide
the depth-2 value through two atomization layers, and record whether the falsifier appears.

**Tasks**:

- [ ] Create `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`
      (`import FormalSystem`; `namespace Probe711DepthTwo`). Fixture: two states `a, b` with
      `Rf _ a a`, `Rf _ a b`, `Rf _ b b` (bi-serial: `a` has predecessor `a`; `b` has
      predecessors `a, b`), built by `FrameOver.ofSlicedStep` with its `IsRegular` instance, `p`
      true at `b` only. Re-grep `FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize`
      and the probe twin `Probe718Stratification.plusTruthAt_iff_stratum_atomize` before citing.
- [ ] Depth 1: prove `stab_will_at_a : ¬ PlusTruthAt M τ t (.stab (F p))` for `τ.state t = a`
      (the history that stays at `a` forever) and `stab_will_at_b : PlusTruthAt … (.stab (F p))`
      for `τ.state t = b` (every successor of `b` is `b`, where `p` holds) — the state-dependent
      depth-1 value the Bool fixture cannot supply.
- [ ] Depth 2, two formulas: `⊡F(⊡Fp)` and `⊡(Fp → ⊡Fp)`. For each, (a) compute the value at
      `a` and at `b` directly from the semantics (`a`: both `False`; `b`: both `True` — confirm,
      do not assume), and (b) compute it through the stratification: atomize with a fresh atom
      `q` for `⊡Fp`, read `q` through the depth-1 stratum (`q(a) = false`, `q(b) = true`), and
      evaluate the resulting L-formula at depth 1 (`⊡F q`, `⊡(Fp → q)`) over the atomized model.
      Prove `(a) ↔ (b)` by `plusTruthAt_iff_atomize` applied twice (once per layer), as theorems
      `depth2_via_strata_1`, `depth2_via_strata_2`.
- [ ] The falsifier check: state and prove that on this fixture each depth-2 `⊡`-value at a
      state **is** a function of `(state, depth-1 stratum)` — `value_is_function_of_stratum` —
      and record in the header that this is a POSITIVE result on one fixture, not a proof that
      the falsifier cannot exist: what would kill stratification is a fixture where two states
      with equal depth-1 strata differ at depth 2, and this probe exhibits none.
- [ ] Header in the collection's style (what is established / NOT established / axiom record /
      compile line); `#print axioms` foot. Wire into `scripts/check-evidence-probes.sh` (append
      only; re-read first); run the whole collection; commit
      (`task 711 phase 10: depth-2 stratification probe E2`), staging the probe and the script.
- [ ] Close-out for the task: update `RaySummary/README.md`'s evidence paragraph to cite both
      probes by file name; run the unscoped final build
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached), the
      test library build (`… -- build BimodalTest`), `bash scripts/check-module-invariants.sh`
      and `bash scripts/check-evidence-probes.sh`; all green before the task is marked complete.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: 250–350 lines. Two `decide_will`-style layer lemmas took E3 ~100 lines for
one layer on one formula; if the second formula's depth-2 computation runs long, keep `⊡F(⊡Fp)`
as the probe's subject, record `⊡(Fp → ⊡Pp)`-shaped formulas as a follow-up in the header, and
do not overrun.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` - new; probe (ii), E2
- `scripts/check-evidence-probes.sh` - WIRED row + entry (append only)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - evidence paragraph

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` exits 0, no
  warnings, no sorry, axioms within pcq.
- `bash scripts/check-evidence-probes.sh` exits 0 for the whole collection.
- Final gates: unscoped guarded `lake build` exit 0; `lake build BimodalTest` exit 0;
  `bash scripts/check-module-invariants.sh` exit 0.

## Lean Challenge Statements

The two D1 lemmas, exactly as compiled during research (report "Tactic Survey Results"). Their
bodies are `sorry` here by the section's rule; Phase 2 lands the real proofs. See Decision D-9
for why D2–D5 are specified in the phases rather than pinned here.

```lean
import Mathlib.Data.Set.Finite.Lattice
import Mathlib.Logic.Denumerable
import Mathlib.Data.Fintype.Pigeonhole

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem exists_idempotent_homogeneous {C : Type} [Finite C] (comp : C → C → C)
    (c : ℕ → ℕ → C) (hc : ∀ i j k, i < j → j < k → c i k = comp (c i j) (c j k)) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧ ∀ i j, i < j → c (g i) (g j) = τ := sorry

theorem exists_idempotent_homogeneous_bwd {C : Type} [Finite C] (comp : C → C → C)
    (c : ℤ → ℤ → C) (t : ℤ) (hc : ∀ a b d : ℤ, a < b → b < d → c a d = comp (c a b) (c b d)) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧
      ∀ i j, i < j → c (t - g j) (t - g i) = τ := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Literature Proof Structure (H3 Tier 1 mapping, carried from the report and extended)

Reference-grounding tier: **Tier 1** (HWZ 2000, GKWZ 2003, Thomas 1997; Doets 1987 via the
Ramsey module), with Tier 3 inputs (the keystone, the sliced certificate's liveness and tail
modules, the probe collection). Page numbers as read in the corpus chunks (report "Lemma-level
mapping table"). Status: `transcribed` (proved in tree), `pending` (this plan's target, with the
owning phase), `blocked` (no Lean route under zero-debt; frame only). No row is `sorry`.

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Doets 1987 ch. 7, pp. 89–93 | infinite Ramsey for pairs | `Nat.exists_strictMono_const_pair_colour` (alias `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`) | `{C : Type} [Finite C] (c : ℕ → ℕ → C) : ∃ g, StrictMono g ∧ ∃ τ, ∀ i j, i < j → c (g i) (g j) = τ` | transcribed (relocated in Phase 1) |
| Thomas 1997 | §5.1, p. 30: complementation via finite-index segment congruence + Ramsey | `RaySummary.exists_idempotent_homogeneous` | as in Lean Challenge Statements | pending (Phase 2; compiled in research) |
| Thomas 1997 | §5.1, p. 30 (backward mirror) | `RaySummary.exists_idempotent_homogeneous_bwd` | as in Lean Challenge Statements | pending (Phase 2; compiled in research) |
| Thomas 1997 | Theorem 5.9 (Büchi's Theorem), p. 37 | — | — | blocked (frame only) |
| HWZ 2000 | Definition 10 (state function), p. 11 | `RaySummary.FwdPresentation` | `structure … real : ℕ → Finset Ty; suit : ℕ → Ty → Ty → Bool; pending discharged : Ty → Finset Ev` | pending (Phase 3) |
| HWZ 2000 | Definition 11 (run), p. 11 | `RaySummary.FwdPresentation.IsRun`, `.Fulfilling`, `.ExistsFulfillingFrom` | see Phase 3 | pending (Phase 3) |
| Thomas 1997 §5.1 p. 30 (congruence classes as segment types); this plan D-6 | segment profile with discharge and deficit sets | `RaySummary.Profile`, `.comp`, `.comp_assoc`, `FwdPresentation.profile`, `.profile_comp`, `.mem_profile_iff` | see Phase 3 | pending (Phase 3) |
| HWZ 2000 Lemma 17 pp. 14–15 / Lemma 23; Thomas 1997 p. 30 | device theorem, forward ray | `RaySummary.FwdPresentation.exists_fulfilling_iff` | `P.ExistsFulfillingFrom a ↔ P.DeviceCondition a` | pending (Phases 4–5) |
| HWZ 2000 p. 14 ("the case of `⟨ℤ,<⟩` is similar") | backward ray by reindexing | `RaySummary.BwdPresentation.exists_fulfilling_bwd_iff` | `Q.ExistsFulfillingFrom a ↔ Q.toFwd.DeviceCondition a` | pending (Phase 6) |
| HWZ 2000 Lemma 23 / Thm 24; GKWZ 2003 Lemma 11.29 | ultimately periodic specialization | `RaySummary.FwdPresentation.exists_fulfilling_iff_periodic` + `Decidable` instance | `P.UltimatelyPeriodic k p → (P.ExistsFulfillingFrom a ↔ P.PeriodicCondition k p a)` | pending (Phase 7) |
| HWZ 2000 Def 12, Remark 13, Thm 14, p. 11 | realization hypothesis with one-sided live flags | `RaySummary.SeamPresentation`, `RaySummary.Presents` | see Phase 8 | pending (Phase 8; discharge is the consumer's) |
| This tree, `PlusRayFibre.lean` | keystone | `FormalSystem.PlusLanguage.plusStab_iff_omega` | `PlusTruthAt M τ t (.stab φ) ↔ ∀ bf : SeqPair F (τ.state t), PlusTruthAt M (…) t φ` | transcribed |
| HWZ Thm 14 + keystone | the `⊡` bridge | `RaySummary.plusStab_iff_summary` | `Presents M τ t φ S → (PlusTruthAt M τ t (.stab φ) ↔ S.UniversalSummary)` | pending (Phase 8) |
| GKWZ 2003 Lemma 11.23, p. 478 | `qm_φ` as an MSO sentence | `Probe711Discrimination.msoSentence`, `msoSentence_iff_exists_fulfilling` | `msoSentence P a ↔ P.ExistsFulfillingFrom a` | pending (Phase 9; probe only, hand-proved) |
| HWZ 2000 Thm 15, p. 13; GKWZ Thm 1.28 p. 39, Thm 13.6 p. 568 | decidability by Büchi | — | — | blocked (frame only) |
| This tree, `Atomization.lean` | alphabet licence | `FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize` | `PlusTruthAt M τ t φ ↔ TruthAt (M.atomModel e) τ t (atomize e φ)` | transcribed (used by Phase 10) |
| This tree, `NoFiniteWidth.lean` | design constraint | `…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` | sliced-frame finite-width FMP refuted | transcribed (cited) |

**Divergence from the sources, with justification** (lean4 override, "Transcription
Discipline"): HWZ's quasistate is a bare set of types; this plan's seam presentation carries the
two one-sided live flags (computed by the device) and `Presents.complete` demands joint
realization — because `⊡` quantifies over histories through a *state*, which HWZ's language does
not have (report "Potential Formalization Challenges" 1; task 709's record names the same
repair). The profile datum carries a deficit set (Decision D-6) beyond Büchi's congruence class
because fulfilment here is per-eventuality rather than a single acceptance set; this is the
GNBA-to-NBA bookkeeping folded into the congruence, not a change of method.

## Testing & Validation

- [ ] Every new module under `RaySummary/` and the relocated Ramsey module: `lean_verify` on each
      headline name reports no sorry and axioms within `[propext, Classical.choice, Quot.sound]`.
- [ ] `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean` builds with every `#guard_msgs`
      block matching (guarded `lake build BimodalTest`).
- [ ] `bash scripts/check-module-invariants.sh` green after every module-adding phase (C24 for
      the `ForMathlib` exception, C33 for the regenerated root, C5/C12/C13 for README paths).
- [ ] `bash scripts/check-evidence-probes.sh` green for the whole collection after Phases 1, 9
      and 10 (E3's probe cites the alias; the two new probes are wired).
- [ ] Final: unscoped guarded `lake build` exit 0; `grep -rn sorry FormalSystem/Metalogic/Decidability/RaySummary FormalSystem/ForMathlib/Combinatorics` empty.
- [ ] No file outside `specs/` cites a task number (`bash scripts/check-task-references.sh` or
      the C9 check): docstrings cite declaration names and sources.

## Artifacts & Outputs

- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` (+ `README.md`), with the
  alias in `RamseyFactorization.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` and `RaySummary/{Colour,Profile,Forward,Backward,Periodic,Stab}.lean`, `RaySummary/README.md`
- `Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean`
- `specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean`,
  `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`, wired in
  `scripts/check-evidence-probes.sh`
- Registration edits: `FormalSystem.lean` (regenerated), `FormalSystem/ForMathlib.lean`,
  `FormalSystem/Init.lean`, `scripts/CheckInitImportsMain.lean`, `FormalSystem/Metalogic/Decidability.lean`,
  `FormalSystem/Metalogic/Decidability/README.md`, `FormalSystem/ForMathlib/README.md`,
  `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`, `FormalSystem/Metalogic/WeakCanonical.lean`,
  `Tests/BimodalTest.lean`
- `specs/711_universal_summary_substrate_stab_fibre/summaries/01_universal-summary-substrate-summary.md`
  (written by the implementation phase's close-out)

## Rollback/Contingency

- Every phase commits only green work through `.claude/scripts/git-commit-scoped.sh`, staging
  the phase's listed files; reverting a phase is `git revert` of its commits, which leaves the
  earlier phases intact because the dependency order is linear (Phases 6/7 excepted, and they are
  independent of each other).
- If Phase 1's relocation cannot be made green within its budget: leave `section Ramsey` where
  it is, have `Colour.lean` import `RamseyFactorization` directly, record the cross-front
  dependency in `RaySummary/README.md`, and remove the `ForMathlib` paths from the remaining
  phases' file lists. No later phase changes.
- If Phase 5's splice cannot be closed: `Forward.lean` keeps `deviceCondition_of_exists_fulfilling`
  (the `⇒` direction, committed green in Phase 4), the phase is marked `[BLOCKED]` with the
  exact goal state per `.claude/rules/plan-compliance.md`, and no `⇐`-dependent phase (7, 8, 9)
  starts. Under `--hard`, a strategic sorry for the `⇐` direction is admissible only under the
  five-condition test in `context/contracts/anti-analysis.md` and must be tracked in
  `sorry_inventory` with a follow-up task; it is not the default.
- If a genuine working-tree rollback is ever needed (a phase left the tree red and
  unrecoverable), follow `context/contracts/recovery.md`'s rollback rung:
  `bash .claude/scripts/git-snapshot.sh 711` first (with `--allow-out-of-scope` only if the
  refusal fires and a whole-tree revert is genuinely intended), then the destructive command.
  Never use the default snapshot form as a routine checkpoint; the defensive checkpoint before
  risky work is `bash .claude/scripts/git-snapshot.sh --no-revert 711`.
- The evidence collection is never weakened to make a probe pass: a probe that stops compiling
  is repaired by tracking the API (collection header rule), and a probe whose claim turns out
  false is rewritten to record the falsification, not deleted.
