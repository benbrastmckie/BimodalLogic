# Implementation Plan: Decidable `ValidZTime` — the compression half

- **Task**: 623 - Decidable `ValidZTime` via the quasimodel / ShiftSet witness-family route (the completeness/compression half)
- **Status**: [IMPLEMENTING]
- **Effort**: 63 hours
- **Dependencies**: 534, 645, 665, 680, 688 — all complete (the soundness half, `WitnessFamily/`, and the prerequisite-recording documentation task have all landed)
- **Research Inputs**: `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/02_compression-half-witness-family-route.md`; `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/01_stability-scope-decidability-findings.md`; `specs/623_decidable_validztime_quasimodel_shiftset_route/evidence/02_semantic-side-spike.lean` (compiled green)
- **Artifacts**: plans/02_compression-half-witness-family.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/state-management.md`
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build the completeness (compression) direction of the witness-family route: every ℤ-time
countermodel of `φ` compresses to a `WitnessFamily [] [φ]` with all three lasso segments bounded
by a computable function of the closure size, and that family is a member of a computable
candidate list. Composing that with the landed soundness half (`WitnessFamily.refutes_of_certifies`,
`WitnessFamily.decidableCertifies`) yields `Decidable (ValidZTime φ)`. The soundness half is
**consumed, never re-proved**: nothing in this plan redefines `LabelledLasso`, `WitnessFamily`,
`Certifies`, `WitnessFamily.std`, or the agreement theorem. Definition of done: `decidableValidZTime`
compiles with zero `sorry`, `bash scripts/check-module-invariants.sh` exits 0, and the new
declarations carry rows in `docs/theorem-index.md`.

### Research Integration

Report `02_compression-half-witness-family-route.md` is integrated in full. The findings that
shaped this plan's structure:

- **The semantic half is machine-checked already.** `evidence/02_semantic-side-spike.lean` compiles
  a presentation-free type map `typeAtM` at an arbitrary `FrameOver intOrder` model, and proves all
  five `LocalCoherentLab` clauses plus the `untl` half of `FulfillingLab`. Phase 1 is a
  transcription of that file with the `snce` fulfilment half added, not new mathematics.
- **The combinatorial core is transcribed, not imported.** `WitnessFamily/README.md` states as a
  directory invariant that "the only dependency on `../BiLasso/` is `Periodic.lean`". Importing
  `BiLasso/GoodCycle.lean` would break it, and instantiating that file at a one-state dummy
  `IntPresentation` would thread a semantically empty `P` through every new statement. Phases 2-5
  transcribe the pigeonhole/good-cycle core into a presentation-free form over
  `{S : Finset Formula // S ∈ C.powerset}`, each new module carrying the same named retirement
  trigger `WitnessFamily/Basic.lean` and `WitnessFamily/Decide.lean` already use.
- **Recurrence-freeness is a negative licence, and the task description inverts it.**
  `TranslationProduct.lean`'s `validIn_iff_recurrenceFree` says the countermodel may be taken so
  that *no world state ever recurs* — which forbids compressing the state sequence rather than
  licensing it. That is precisely why the certificate must be presentation-free and why the
  compression runs on the **type** sequence only. `validIn_iff_recurrenceFree` is therefore **not**
  on this plan's critical path and is not invoked by any phase; it is recorded here as the
  structural reason the route has the shape it does, and as independent corroboration of
  `Probe476.fmp_false`.
- **`bx` is a function on an infinite type**, so a family is not naively enumerable — the identical
  trap `BiLasso/Assembly.lean` records for `IntPresentation.val`. The escape: `bx` is read only at
  `χ` with `□χ ∈ closureOf (Γ ++ Del)`, so the compression theorem must *state* its conclusion with
  `bx = fun χ => decide (χ ∈ S)` for an explicit `S`. This is a constraint on the statement
  (Phase 8), not a lemma added afterwards.
- **The bound is a length grid, not a magnitude.** The consuming model checker folds `back`/`mid`/
  `fwd` bounds by exact modulus, so a search at bound `n` represents exactly the periods dividing
  `n` (measured: SAT at `(3,1,3)` and `(6,1,6)`, genuinely UNSAT at `(4,1,4)` and `(5,1,5)`).
  Every bound in this plan is stated as "segment lengths **at most** `B`", never "at least
  `f(|C|)`", and the enumeration sweeps every triple in `[0,B]³`.
- **`FragmentAxiomatization.lean` is dropped** from the tool list: it concerns the tense-only L⁻
  fragment (no `untl`/`snce`) and its ZTime completeness is not machine-checked (available only as
  the conditional `minusExt_sigmaZTime_iff_tmFrag_of_chainComplete`). Using it would import an
  unproved hypothesis into a chain this task must close unconditionally.
- **[GKWZ] 2003 supplies the structure, not the ℤ geometry.** Thm 11.26 and Thm 11.45 give the
  compression criterion and the `s₁·s₂·s₃^ω` lasso shape over `(ℕ,<)`; the book's only `(ℤ,<)`
  result (Thm 11.7/11.21) is the non-constructive MSO/Rabin route and is **not** on this path. The
  two-sided adaptation's template is in-tree: `BiLasso/Extraction.lean`'s `exists_annot_of_truth`.
  Per the corpus citation rule, cite by theorem number plus chunk file and transcribe no formula
  verbatim (the conversion has OCR noise).

### Prior Plan Reference

No prior plan. This is the task's first plan; `plans/` did not exist before this round.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context and `specs/ROADMAP.md` was not consulted.

### Declared file scope is stale

`specs/state.json`'s `file_scope` for this task still names the item-3 documentation targets
(`BiLasso/Assembly.lean`, `BiLasso/README.md`, `BiLasso.lean`, `Decidability/README.md`) that were
struck from the description and delivered by the prerequisite documentation task. The actual target
set for this plan is enumerated under **Artifacts & Outputs** below. `FormalSystem.lean`,
`docs/theorem-index.md` and `scripts/check-module-invariants.sh` remain in scope; the four
`BiLasso/` entries do not, and no phase edits them.

## Goals & Non-Goals

**Goals** (identifiers this plan commits to; signatures pinned under
`## Lean Challenge Statements`):

- `typeAtM`
- `LocalCoherentSeqLab`
- `FulfillingSeqLab`
- `typeAtM_localCoherentSeqLab`
- `typeAtM_fulfillingSeqLab`
- `exists_good_cycle_of_typeSeq`
- `fulfillingSeqLab_of_good_cycles`
- `compressionBound`
- `exists_labelledLasso_of_history`
- `exists_witnessFamily_of_not_validZTime`
- `cands`
- `mem_cands_of_bounded`
- `validZTime_iff_noCertifiedCandidate`
- `decidableValidZTime`
- `decidableSemanticConsequenceNil`

**Non-Goals**:

- **Re-proving or re-defining any part of the soundness half.** `WitnessFamily/{Basic, Closure,
  Predicates, Std, Agreement, Decide, Examples}.lean` are consumed as given.
- **Deciding general finite-premise consequence `SemanticConsequenceIn FrameClass.ZTime Γ σ` for
  non-empty `Γ`.** That needs a context-conjunction deduction theorem, and the tree has none (no
  `Context.conj`, `bigConj` or equivalent exists). `decidableSemanticConsequenceNil` covers the
  empty-premise case via the `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` bridge; the general
  case is out of scope and should be recorded as a follow-up.
- **A usable executable.** The candidate list is astronomically large (`~(2^k)^{3B(1+k)}`).
  `Decidable` is the deliverable. [GKWZ] §6.5 gives an EXPSPACE-hardness lower bound for
  `PTL × S5`, so no encoding does materially better; say so in the docstring rather than apologise
  for it.
- **The shared periodic-label abstraction** that would retire the `BiLasso/` ↔ `WitnessFamily/`
  duplication. Building it would put a large refactor under `BiLasso/`'s live `check`. Each new
  module records the retirement trigger instead.
- **Correcting `FormalSystem/Metalogic/Decidability/README.md`'s "outside the build graph" claim
  about the `BiLasso/` row.** Contradicted by `BiLasso/README.md` and the generated root, but
  already recorded as a follow-up by the soundness task's summary. Not this plan's work.
- **The stability modal `⊡`.** `ValidZTime` is stated for `FormalSystem.Syntax.Formula`, which has
  no `⊡`; the scope sentence already lives in `BiLasso/Assembly.lean`'s docstring.
- **Any edit to `BiLasso/`.** The directory is held stable.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The ℤ two-sided compression is not in the held literature (only the one-sided Thm 11.26/11.45) | H | H (certain) | `BiLasso/Extraction.lean`'s `exists_annot_of_truth` is the in-tree precedent for exactly this geometry, ~250 lines. Phases 6-7 transcribe its three-segment table (back cycle read outward from `-1`; mid walk shortened in two legs around the point of interest, first leg taking one real step before shortening; forward cycle from `nm`) rather than re-deriving it |
| Phase 6/7 (the only genuinely new geometry) proves harder than the precedent suggests | H | M | Already split into two phases with separate green gates. If it still overruns, split further (back cycle / mid walk / forward cycle as three units, each with its own gate) — **never** introduce a `sorry` placeholder. C3 gates zero structural `sorry` |
| `bx` is a function on an infinite type, so the family is not enumerable | H if missed, L if planned | M | The canonical-`bx` form is written into `exists_witnessFamily_of_not_validZTime`'s *statement* (Phase 8/9) and consumed by `mem_cands_of_bounded` (Phase 10). Discharged by `S := (boxedPart C).filter (fun χ => ∀ σ v, TruthAt M σ v χ)` with `Classical.dec`: `S` is a genuine `Finset`, so `fun χ => decide (χ ∈ S)` computes even though the filter predicate does not |
| A bound of the shape "segment lengths at least `f(|C|)`" is read as sufficient by the consuming model checker, whose registry folds bounds by exact modulus | M | M | Every bound stated as "at most `B`"; `cands` sweeps the whole grid `[0,B]³` via a `ListEnum.upTo`-style enumerator; one docstring sentence in `Compression/Assembly.lean` states that a bound alone does not transfer to a modulus-folding consumer. The correction already sits in `WitnessFamily/README.md` |
| Transcription volume of the `BiLasso/GoodCycle.lean` core (~550 lines across Phases 2-5) drifts from its original | M | M | Each new module's docstring records the duplication and the same named retirement trigger `WitnessFamily/Basic.lean` and `Decide.lean` already use ("once a shared periodic-label presentation lands, both should be redefined as its two instances") |
| Transcription volume overruns the phase budget | M | M | Documented contingency, in preference order: (a) split the phase; (b) relocate the compression modules to a **new sibling** directory `FormalSystem/Metalogic/Decidability/Compression/` which may import both `BiLasso/GoodCycle.lean` and `WitnessFamily/`, preserving `WitnessFamily/`'s stated invariant without duplication, and instantiate the core at a one-state `IntPresentation` — enabled by the compiled bridge `closureOf ([] ++ [φ]) = subformulaClosure φ` (`by simp [closureOf]`). Option (b) is a **last resort**: it restricts the compression to the single-formula closure and so forecloses the general context-indexed form |
| Siblings 684 and 690 edit `WitnessFamily.lean` and `WitnessFamily/README.md` concurrently, on the same working tree | M | H | Phase 12 is the single phase that touches either file. Re-read immediately before editing; stage only this task's hunks with an explicit file list (never a directory or glob `git add`); never run `git-snapshot.sh` in its reverting default mode. A foreign commit, foreign uncommitted modification, or a running build not started by this task is a STOP-and-report condition after checking `git log`, not noise |
| A new global `instance` for `Decidable (ValidZTime φ)` changes instance resolution repo-wide and slows or loops elaboration | H | M | Declare `decidableValidZTime` and `decidableSemanticConsequenceNil` as `def`s, not `instance`s — exactly as the landed `BiLasso/Assembly.lean` declares `decidableValidZTimeFamily`. No phase introduces a global `instance` or a `@[simp]` lemma; that is what keeps Phases 1-10 honestly at the `local` verification tier |
| New modules unreachable from the build graph, so `lake build` never compiles them | M | M | Every module-creating phase adds its own `import` line to `FormalSystem.lean` in alphabetical position as its final step (the file is hand-maintained; no generator exists). C4 and C6 gate this at Phase 12 |
| OCR noise in the [GKWZ] conversion (`QT L` for `QTL`, `Sb5` for `S5`) | L | H | Take structure only; transcribe no formula verbatim; cite theorem number plus chunk file |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1, 2 |
| 3 | 5, 6 | 3, 4 |
| 4 | 7 | 5, 6 |
| 5 | 8 | 7 |
| 6 | 9 | 8 |
| 7 | 10 | 9 |
| 8 | 11 | 10 |
| 9 | 12 | 11 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are independent (Phase 2 is
generic walk machinery over an arbitrary finite datum type and needs nothing from Phase 1). Phase 3
depends on Phase 2 only; Phase 4 on Phase 1 only — they are listed in one wave because both become
available together.

All new Lean modules live under
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`, mirroring how `Sharing/` sits
beside the core modules and is imported directly from `WitnessFamily.lean`. The subdirectory keeps
every compression module presentation-free, honours the directory's stated "only `Periodic.lean`"
dependency on `BiLasso/`, and confines cross-task territory contention to a single import line
added in Phase 12.

**A note on module naming**: the research report proposed `Type.lean`. `Type` is a Lean keyword and
a module path component spelled `Type` requires French-quote escaping at every import site. The
module is named `Types.lean` here for that reason and no other.

---

### Phase 1: `Compression/Types.lean` — the presentation-free type of a model position [COMPLETED]

**Goal**: Land the semantic half of compression: the type map `typeAtM` at an arbitrary
`FrameOver intOrder` model, the two sequence-level predicates the rest of the plan is stated
against, and the theorems that a genuine history's type sequence satisfies both.

**Tasks**:
- [ ] Create `Compression/Types.lean` with the standard copyright header and a module docstring
      recording: that this is the presentation-free counterpart of `BiLasso/SmallModel.lean`'s
      `typeAt`; that `LocalCoherentLab` drops `LocalCoherentSeq`'s atom clause, which is the only
      clause that ever needed a presentation, so nothing is lost; and the named retirement trigger
      for the duplication
- [ ] Transcribe `typeAtM` and `mem_typeAtM` from `evidence/02_semantic-side-spike.lean`
- [ ] Define `LocalCoherentSeqLab (Γ Del : Context) (bx : Formula → Bool) (lab : ℤ → Finset Formula)`
      as the five-clause conjunction of `WitnessFamily.LocalCoherentLab` at a bare label sequence
      (drop the `Fin W.lassos.length` index; keep `closureOf (Γ ++ Del)` as the guard)
- [ ] Define `FulfillingSeqLab (lab : ℤ → Finset Formula)` as the two-conjunct `untl`/`snce`
      fulfilment at a bare label sequence, matching `WitnessFamily.FulfillingLab` per lasso
- [ ] Prove `typeAtM_localCoherentSeqLab` by transcribing the spike's `typeAtM_clauses`
- [ ] Prove `typeAtM_fulfillingSeqLab`: the `untl` half transcribes the spike's
      `typeAtM_fulfilling`; add its `snce` mirror (the spike did not transcribe it)
- [ ] Prove `typeAtM_subset : typeAtM M Γ Del τ u ⊆ closureOf (Γ ++ Del)` (one line from
      `Finset.filter_subset`)
- [ ] Add the module's `import` line to `FormalSystem.lean` in alphabetical position

**Timing**: 3 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the module is asserted at ~170 lines, of which ~130 transcribe the compiled
spike verbatim. Confirm at implementation time by `wc -l` on the finished module and by checking
that the only non-spike content is the `snce` fulfilment mirror and the two predicate definitions;
if the spike does not transcribe cleanly (e.g. `Truth.imp_iff`/`Truth.box_iff` argument
explicitness differs from the spike's), record the delta rather than silently absorbing it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Types.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Types` exits 0
- Zero `sorry` in the new module (`grep -c sorry`)
- Two naming traps recorded by the research hold or are corrected in place: `Truth.imp_iff` and
  `Truth.box_iff` take their formula arguments **explicitly**; `closureOf_untl_left` returns the
  **event** and `closureOf_untl_right` the **guard**

---

### Phase 2: `Compression/Cycle.lean` (part A) — generic walk machinery [COMPLETED]

**Goal**: Transcribe, presentation-free, the walk and pigeonhole plumbing the good-cycle
construction stands on, over the type space `{S : Finset Formula // S ∈ C.powerset}`.

**Tasks**:
- [ ] Create `Compression/Cycle.lean` with header and a docstring recording the duplication against
      `BiLasso/GoodCycle.lean` and the named retirement trigger
- [ ] Introduce the datum space `TypeState C := {S : Finset Formula // S ∈ C.powerset}` (as an
      `abbrev`, so its `Fintype`/`DecidableEq`/`Finite` instances come for free, exactly as
      `PigeonState` does), with `typeOf`, `typeOf_subset`, and
      `natCard_typeState : Nat.card (TypeState C) = 2 ^ C.card`
- [ ] Transcribe the two fully generic pigeonhole helpers `exists_iter_lt_card_aux` /
      `exists_iter_lt_card` (`{W : Type} [Finite W] [Nonempty W]`), reusing
      `FormalSystem/Semantics/IntNormalForm.lean`'s `iter` and
      `FormalSystem/Semantics/Periodicity.lean`'s `exists_path_of_iter` directly — both are outside
      `BiLasso/` and may be imported
- [ ] Transcribe `joinPath` with `joinPath_left`, `joinPath_right`, `joinPath_steps`, generalised
      from `PigeonState P φ` to `TypeState C`
- [ ] Transcribe `exists_recurring_datum` at `TypeState C`
- [ ] Define `SeqStep (d : ℤ → TypeState C)` and prove `iter_seqStep`
- [ ] Prove `exists_base_cycle` (the unmarked cycle through a recurring datum, length in
      `[1, Nat.card (TypeState C)]`), preserving the original's reason for taking the first step
      from the sequence directly and shortening only the return leg: a cycle shortened as a whole
      could collapse to length zero, and `LabelledLasso.back_ne`/`fwd_ne` forbid empty segments
- [ ] Add the module's `import` line to `FormalSystem.lean`

**Timing**: 5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines, of which the generic pigeonhole helpers (~60) transcribe with
the type variable unchanged and the rest with `PigeonState P φ → TypeState C`. Confirm by diffing
the finished declarations against `BiLasso/GoodCycle.lean`'s corresponding block and recording
any statement that needed more than a mechanical substitution.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Cycle.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle` exits 0
- Zero `sorry`
- `natCard_typeState` proved, not asserted — it is the quantity every downstream bound is
  expressed in
- The module imports nothing from `BiLasso/` except (transitively) `Periodic.lean`

---

### Phase 3: `Compression/Cycle.lean` (part B) — good cycles [COMPLETED]

**Goal**: The root-saturated cycle of [GKWZ] Thm 11.45, presentation-free: a cycle through a
recurring type that realises the event of every eventuality that type carries.

**Tasks**:
- [ ] Transcribe `untlEvent` / `snceEvent` with their `@[simp]`-free projection lemmas
      `untlEvent_eq_some` / `snceEvent_eq_some` (keep the two `@[simp]` tags the original carries
      on `untlEvent_untl` / `snceEvent_snce`; they are local normalisation, not global rewrites)
- [ ] Define `cycleBoundC (C : Finset Formula) : ℕ := (2 * C.card + 1) * 2 ^ C.card` and prove
      `cycleBoundC_eq : cycleBoundC C = (2 * C.card + 1) * Nat.card (TypeState C)`
- [ ] Prove `exists_good_cycle_of_typeSeq` by transcribing `exists_good_cycle_of_seq`: induction
      over the type of `x` as a `Finset`, starting from `exists_base_cycle` and appending, per
      formula carrying an event, an out-and-back excursion `x ⟶ mark ⟶ x` whose two legs are
      separately shortened
- [ ] Record in the docstring the cross-check the research compiled: instantiating
      `BiLasso/GoodCycle.lean`'s `cycleBound` at a one-state `IntPresentation` gives
      `(2k + 1) · 2^k` with `k = subformulaClosureCard φ` — the same closed form as `cycleBoundC`
      at `C = subformulaClosure φ`. This is the cross-check that the transcribed bound is right,
      and is **not** the implementation route

**Timing**: 6 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: `exists_good_cycle_of_typeSeq` is asserted at ~180 lines, the single largest
transcription in the plan. Confirm by line count at implementation time; if it exceeds ~250 lines
or the `Finset.induction_on` step resists the substitution, split the marking induction into its
own lemma rather than growing the phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Cycle.lean` — extended

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- The bound in the conclusion reads `L ≤ cycleBoundC C`, i.e. **at most** — never a lower bound
- Statement matches the pinned signature under `## Lean Challenge Statements`

---

### Phase 4: `Compression/Fulfil.lean` (part A) — eventuality propagation [COMPLETED]

**Goal**: The two propagation lemmas and the two iterated-periodicity lemmas that turn "the cycles
are good" into "every eventuality is discharged".

**Tasks**:
- [ ] Create `Compression/Fulfil.lean` with header, docstring and retirement trigger
- [ ] Prove `untl_propagates_to_end`: an undischarged `untl` survives to the end of the stretch
      with its guard intact, by rightward ℤ-induction (`Int.rightInduction`,
      `BiLasso/Unfold.lean`) on `LocalCoherentSeqLab`'s `untl` clause
- [ ] Prove `snce_propagates_to_start`, its leftward mirror, by `Int.leftInduction` — stated
      separately rather than derived by duality, for the same reason the original gives (the tree
      has no `Formula` duality operation, and inventing one for a single use costs more than the
      twelve lines it saves)
- [ ] Transcribe `lab_add_mul_nf` and `lab_sub_mul_nb`. These are **already presentation-free** in
      `BiLasso/GoodCycle.lean` (`{lab : ℤ → Finset Formula}` only), so they transcribe with no
      change at all — record that in the docstring as the clearest instance of the duplication the
      retirement trigger is meant to retire
- [ ] Add the module's `import` line to `FormalSystem.lean`

**Timing**: 4 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: ~150 lines. The propagation lemmas consume only `LocalCoherentSeqLab`'s
temporal clauses; confirm at implementation time that neither proof reaches for the atom clause
(which does not exist here) or for a state sequence — if either does, the predicate definition in
Phase 1 is wrong and must be corrected there, not patched here.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Fulfil.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- `lab_add_mul_nf` / `lab_sub_mul_nb` are byte-comparable with their `BiLasso/` originals modulo
  namespace, confirming the "no change at all" claim

---

### Phase 5: `Compression/Fulfil.lean` (part B) — fulfilment from two good cycles [COMPLETED]

**Goal**: `fulfillingSeqLab_of_good_cycles` — the bridge from a bi-periodic locally coherent label
sequence with two good cycles to full `FulfillingSeqLab`.

**Tasks**:
- [ ] Prove `fulfillingSeqLab_of_good_cycles` by transcribing `fulfilling_of_good_cycles`. The
      original takes a `LocalCoherentSeq P φ bx lab st` but uses `st` **nowhere** — only the
      `untl`/`snce` clauses are consumed, via the two propagation lemmas — which is exactly why
      the transcription to `LocalCoherentSeqLab` is faithful. Record that observation in the
      docstring
- [ ] Preserve the original's two-step argument in both directions: (1) some delivery exists, by
      propagating the obligation past `t` through a multiple of `nf` and contradicting the cycle's
      goodness — the only place goodness is spent; (2) the interval guard is free, by taking `s`
      least (`Int.exists_least_of_bdd`) and re-running propagation to `s - 1`
- [ ] Record that this is the prescribed sequence-level propagation route, not the window-collapse
      fallback: `WitnessFamily/Decide.lean`'s collapses are stated for a `WitnessFamily`, whereas
      the assembly needs the conclusion at bare sequences, before any family exists

**Timing**: 5 hours

**Depends on**: 3, 4

**Verification Tier**: local

**Scope Hypothesis**: ~230 lines, mirroring the original's two symmetric halves. Confirm by line
count; the `snce` half should be within ~10% of the `untl` half's length, and a large asymmetry
signals a transcription error rather than a genuine difference.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Fulfil.lean` — extended

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- Statement matches the pinned signature under `## Lean Challenge Statements`
- The proof mentions no state sequence and no presentation

---

### Phase 6: `Compression/Extract.lean` (part A) — the three walks [COMPLETED]

**Goal**: The ℤ geometry. From a history's `typeAtM` sequence, produce the backward good cycle, the
forward good cycle, and the two-leg mid walk with the point of interest surviving as a marked
interior position.

**Tasks**:
- [ ] Create `Compression/Extract.lean` with header and a docstring carrying the three-segment
      table from `BiLasso/Extraction.lean` (lasso times `[-nb, -1]` = `back`, read outward from
      `-1`; `[0, nm)` = `mid`; `[nm, nm + nf)` = `fwd`) and the reason the witness is delivered at
      a position rather than at the origin — a `LabelledLasso`'s origin is pinned, so a two-sided
      pigeonhole forces the origin to sit at the backward repeat
- [ ] Define `midBoundC (C : Finset Formula) : ℕ := 2 * 2 ^ C.card` and
      `compressionBound (Γ Del : Context) : ℕ :=
       max (cycleBoundC (closureOf (Γ ++ Del))) (midBoundC (closureOf (Γ ++ Del)))`, with
      `cycleBoundC_le_compressionBound` / `midBoundC_le_compressionBound`. Take the `max`
      unconditionally, as `BiLasso/Extraction.lean`'s `bound` does, so no closure-cardinality
      lemma is needed here
- [ ] Obtain the forward recurring type and the forward good cycle via `exists_recurring_datum` +
      `exists_good_cycle_of_typeSeq` at `d := fun u => ⟨typeAtM M Γ Del τ u, _⟩`
- [ ] Obtain the backward good cycle by instantiating the same theorem at the reversed sequence
      `fun u => d (-u)` — the genericity in `d` is exactly what makes this reuse possible rather
      than a two-hundred-line mirror
- [ ] Build the mid walk: shorten in **two** legs (base-to-point, point-to-base) so the point of
      interest cannot be excised, with the first leg taking one real step before any shortening so
      the recorded position is never negative; join with `joinPath`
- [ ] Prove the marked-position lemma: the recorded index `i` satisfies `0 ≤ i` and `i ≤ nm`, and
      the datum there is the history's type at `t`

**Timing**: 6 hours

**Depends on**: 3, 1

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines, tracking `exists_annot_of_truth`'s ~250-line proof body plus the
bound definitions. This is the only genuinely new geometry in the plan; if it overruns, split into
three units (backward cycle / forward cycle / mid walk) each with its own green gate — never a
`sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Extract.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- Both cycle lengths are bounded **above** by `cycleBoundC`, the mid walk by `midBoundC`
- The marked position lemma is proved for the closed interval `[0, nm]`, not the half-open
  `[0, nm)`: the corner `i = nm` is exactly where the witness lands when the mid walk's second
  leg collapses, which is the defect `witness_pos_mem_cohWindow`'s docstring records

---

### Phase 7: `Compression/Extract.lean` (part B) — one history to one labelled lasso [COMPLETED]

**Goal**: `exists_labelledLasso_of_history` — package the three walks into a genuine
`LabelledLasso (closureOf (Γ ++ Del))` whose decoded label function is locally coherent, fulfilling,
bi-periodic, bounded, and carries the history's type at a position in `[0, nm]`.

**Tasks**:
- [ ] Build the three label lists by mapping `typeOf` over the three walks; discharge the structure
      fields `back_ne` and `fwd_ne` from the cycles' length-at-least-one, and `label_sub` from
      `typeOf_subset`
- [ ] Prove the decoding agreement: `Λ.lab` equals the spliced datum sequence's `typeOf` at every
      integer, by the `Periodic.unrollOf` case split (the analogue of
      `BiLasso/Extraction.lean`'s `stateOf_unrollOf`/`getD_map` plumbing)
- [ ] Prove `LocalCoherentSeqLab Γ Del bx Λ.lab` by the splice argument: every clause reads only
      the label at `t`, at `t + 1`, or at `t - 1`, no clause reaches two steps away and no clause
      mentions `t` itself, so a sequence assembled by jumping from `u` to `v + 1` whenever
      `d u = d v` still satisfies every clause — the seam edge is literally an edge the history
      realised. Transcribe `localCoherentSeq_of_edges`' reasoning with the atom clause deleted
- [ ] Derive the two periodicities from `LabelledLasso.lab_sub_back_length` /
      `lab_add_fwd_length` (landed, consumed as-is)
- [ ] Apply `fulfillingSeqLab_of_good_cycles` to obtain `FulfillingSeqLab Λ.lab`
- [ ] Assemble `exists_labelledLasso_of_history` with all three segment lengths bounded by
      `compressionBound Γ Del`

**Timing**: 7 hours

**Depends on**: 5, 6

**Verification Tier**: local

**Scope Hypothesis**: ~280 lines. The list-plumbing block (`getD_map`, `getD_range_map`, the
`unrollOf` projection) is asserted at ~60 of those and transcribes from
`BiLasso/Extraction.lean` with the state component deleted; confirm that deletion actually
simplifies rather than merely renames, and record the result.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Extract.lean` — extended

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- Statement matches the pinned signature under `## Lean Challenge Statements`
- The three bounds read `≤ compressionBound Γ Del`
- The lasso is a real `LabelledLasso`, constructed — not an existential over unpackaged lists

---

### Phase 8: `Compression/Family.lean` (part A) — canonical `bx` and the box witnesses [COMPLETED]

**Goal**: The box-faithfulness half of the family: a canonical, enumerable box guess and one extra
lasso per boxed closure member the guess sets false.

**Tasks**:
- [ ] Create `Compression/Family.lean` with header and a docstring stating the enumerability trap
      in full: `WitnessFamily.bx` is a function on the infinite type `Formula`, the identical trap
      `BiLasso/Assembly.lean` records for `IntPresentation.val`; the family route escapes it
      because `bx` is read **only** at `χ` with `□χ ∈ closureOf (Γ ++ Del)`, in
      `LocalCoherentLab`'s box clause and in `BoxFaithful` and nowhere else
- [ ] Define `boxedPart (C : Finset Formula) : Finset Formula` selecting the `χ` for which
      `Formula.box χ ∈ C`. No `Formula.boxArg?` helper exists in the tree — introduce one
      (`Formula.boxArg? : Formula → Option Formula`, `some χ` on `box χ` and `none` otherwise) in
      this module, or use a `Finset.filterMap`; either way it is new, and it is this phase's work
- [ ] Define the canonical guess `S := (boxedPart (closureOf (Γ ++ Del))).filter
      (fun χ => ∀ σ v, TruthAt M σ v χ)` with `Classical.dec`. `S` is a genuine `Finset`, so
      `fun χ => decide (χ ∈ S)` computes and is enumerated, even though the filter predicate does
      not compute — record that reasoning in the docstring, since it is the whole point
- [ ] For each `χ ∈ boxedPart C` with `χ ∉ S`, extract a witness history at which `χ` fails, and
      run `exists_labelledLasso_of_history` on it to obtain one extra lasso
- [ ] Prove `BoxFaithful` for the assembled lasso list: `bx χ = true` iff `χ` is labelled at every
      position of every lasso. The forward direction is `S`'s defining property carried through
      `typeAtM`; the reverse is the witness lasso, which labels `χ` nowhere at its witness position
- [ ] Prove the lasso-count bound `W.lassos.length ≤ (closureOf (Γ ++ Del)).card + 1` (the main
      lasso plus at most one per boxed closure member)

**Timing**: 6 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: ~250 lines, and the phase asserts that the lasso list is exactly
`main :: (witness lassos)`, i.e. length `≤ C.card + 1`. Confirm both at implementation time: the
count bound is load-bearing for Phase 10's enumeration and a looser true bound must be propagated
forward rather than quietly assumed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- The produced `bx` is **syntactically** `fun χ => decide (χ ∈ S)` for an explicit
  `S ⊆ closureOf (Γ ++ Del)` — this is a constraint on the statement, and a proof that merely
  produces *some* `bx` fails the phase
- `#print axioms` on the phase's main results is `[propext, Classical.choice, Quot.sound]`

---

### Phase 9: `Compression/Family.lean` (part B) — the compression theorem [COMPLETED]

**Goal**: `exists_witnessFamily_of_not_validZTime` — the completeness half, end to end.

**Tasks**:
- [ ] Prove the two micro-gaps the research identified and no lemma in the tree supplies:
      `closureOf ([] ++ [φ]) = subformulaClosure φ` (`by simp [closureOf]`, compiled) and
      `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` (six lines, compiled). Site them where they
      are used; the second belongs with Phase 11's corollary if it reads better there
- [ ] From `¬ ValidZTime φ`, rewrite by `IntTransfer.lean`'s `validZTime_iff_validInt` to get a
      refuting `F : FrameOver intOrder`, model, history and time. This is compression step 0 and
      it is free
- [ ] Run Phase 8's construction at `Γ := []`, `Del := [φ]` to obtain the family
- [ ] Prove `LocalCoherentLab` and `FulfillingLab` for the family by lifting the per-lasso
      `LocalCoherentSeqLab` / `FulfillingSeqLab` across the `Fin W.lassos.length` index
- [ ] Prove `Target t`: at the marked position of the main lasso, `φ ∉ W.main t` (there are no
      premises, so the first conjunct is vacuous)
- [ ] Assemble `W.Certifies t` and state `exists_witnessFamily_of_not_validZTime` with all four
      carried side conditions: the three segment bounds, the canonical-`bx` form, the lasso-count
      bound, and `0 ≤ t ≤ compressionBound [] [φ]` (the marked position lies in `[0, nm]` and
      `nm ≤ compressionBound`)
- [ ] Add a docstring sentence stating that the enumeration sweeps the whole length grid and that
      a bound alone does **not** transfer to a consumer that folds bounds by exact modulus —
      representability, not magnitude, is what the folding decides

**Timing**: 6 hours

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: ~200 lines. The phase asserts that exactly four side conditions ride along
with `Certifies`; confirm that Phase 10 consumes all four and that none is dead — a side condition
no consumer reads is a sign the statement was over-specified.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` — extended

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- Statement matches the pinned signature under `## Lean Challenge Statements`
- `WitnessFamily.refutes_of_certifies` applied to the produced `Certifies` type-checks — the round
  trip back to a countermodel closes

---

### Phase 10: `Compression/Enumerate.lean` — the candidate list [COMPLETED]

**Goal**: A computable `cands : Formula → List (WitnessFamily [] [φ])` covering every family the
compression theorem can produce, with the completeness lemma `mem_cands_of_bounded`.

**Tasks**:
- [ ] Create `Compression/Enumerate.lean` with header and docstring
- [ ] Define `closureSubsetsOf (C : Finset Formula) : List (Finset Formula)` computably, by
      sublists of the closure's underlying list mapped through `List.toFinset` —
      `Finset.powerset.toList` is noncomputable and would defeat the purpose, exactly as
      `BiLasso/Enumerate.lean`'s `closureSubsets` docstring records. Prove the soundness and
      completeness lemmas `closureSubsetsOf_sub` / `mem_closureSubsetsOf`
- [ ] Reuse `BiLasso/Enumerate.lean`'s `ListEnum.ofLen` / `ListEnum.upTo` if and only if they can
      be imported without violating the directory invariant; otherwise transcribe them — they are
      fully generic in `α` and ~40 lines. Decide this at implementation time and record the choice
- [ ] Define `boundedLassos C B : List (LabelledLasso C)` sweeping **every** triple
      `(kb, km, kf) ∈ [1,B] × [0,B] × [1,B]` via `upTo`, with `mem_boundedLassos` completeness
- [ ] Define `cands φ : List (WitnessFamily [] [φ])`: every `bx` of the canonical form
      `fun χ => decide (χ ∈ S)` for `S` a sublist-subset of `boxedPart (closureOf ([] ++ [φ]))`,
      crossed with every non-empty lasso list of length at most `(closureOf ([] ++ [φ])).card + 1`
      drawn from `boundedLassos`
- [ ] Prove `mem_cands_of_bounded`: any family meeting the three side conditions
      `exists_witnessFamily_of_not_validZTime` delivers is a member of `cands φ`
- [ ] Add the module's `import` line to `FormalSystem.lean`

**Timing**: 6 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ~280 lines; the enumeration is asserted to sweep the full grid `[0,B]³`
rather than the single triple `(B,B,B)`. Confirm by reading `mem_boundedLassos`' proof: it must
range over every length, not over a fixed one. This is the non-monotonicity correction's
load-bearing consequence and a single-triple enumeration would be silently incomplete.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build` of the module exits 0; zero `sorry`
- `cands` is computable — `#eval (cands (Formula.atom 0)).length` elaborates (it need not
  terminate quickly; that it elaborates without a `noncomputable` error is the check)
- Statement of `mem_cands_of_bounded` matches the pinned signature

---

### Phase 11: `Compression/Assembly.lean` — `Decidable (ValidZTime φ)` [COMPLETED]

**Goal**: Compose compression, enumeration and the landed `decidableCertifies` into the decision
procedure.

**Tasks**:
- [ ] Create `Compression/Assembly.lean` with header and a docstring that (a) states the
      procedure's shape, (b) states the complexity honestly — the candidate list is astronomically
      large and [GKWZ] §6.5 gives an EXPSPACE-hardness lower bound for `PTL × S5`, so the
      exponential cost is the literature's own, not an artefact of the Lean encoding — and
      (c) repeats the grid-sweep/modulus-folding sentence for the consuming side
- [ ] Prove `validZTime_iff_noCertifiedCandidate`, following
      `BiLasso/Assembly.lean`'s `validZTime_iff_checkFamily` shape: forward by contraposition
      through `exists_witnessFamily_of_not_validZTime` + `mem_cands_of_bounded`; reverse through
      `WitnessFamily.refutes_of_certifies`
- [ ] Define `decidableValidZTime φ : Decidable (ValidZTime φ)` by `decidable_of_iff`, as a **`def`
      and not an `instance`** — matching the landed `decidableValidZTimeFamily`, and avoiding a
      global instance that would change instance resolution repo-wide
- [ ] Define `decidableSemanticConsequenceNil σ : Decidable (SemanticConsequenceIn
      FrameClass.ZTime [] σ)` via the `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` bridge, also
      as a `def`. Record in the docstring that the non-empty-premise case is out of scope because
      the tree has no context-conjunction deduction theorem
- [ ] Add the module's `import` line to `FormalSystem.lean`

**Timing**: 4 hours

**Depends on**: 10

**Verification Tier**: interface

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` — new
- `FormalSystem.lean` — one import line

**Verification**:
- `lake build` of the module **and of its enumerated direct dependents** exits 0
- Zero `sorry`
- `#print axioms decidableValidZTime` is exactly `[propext, Classical.choice, Quot.sound]`
- Neither new declaration is an `instance` (`grep -c '^instance'` on the module is 0)
- Statements match the pinned signatures under `## Lean Challenge Statements`

---

### Phase 12: Documentation, aggregator wiring and the full gate [IN PROGRESS]

**Goal**: Wire the new subdirectory into the layer's documentation and aggregators, and pass the
repository's full invariant harness.

**Tasks**:
- [ ] Write `WitnessFamily/Compression/README.md`: the route, the [GKWZ] terminology map (type /
      suitable pair / root-saturated sequence / run / state function ↔ `LabelledLasso` /
      `CoherentEdge` / good cycle / `lab` / `WitnessFamily`), the module list, the duplication
      record with its retirement trigger, and the non-monotonicity sentence
- [ ] **Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` immediately before
      editing** (sibling task 684 declares it in its file scope), then add the seven
      `Compression.*` import lines and a `Compression/` row to its `## Submodules` list
- [ ] **Re-read `WitnessFamily/README.md` immediately before editing** (also 684's scope), then add
      the `Compression/` row. Correct its "completeness half is not here" sentence to point at the
      new subdirectory
- [ ] Add rows to `docs/theorem-index.md`'s `### Decidability` section for
      `decidableValidZTime`, `validZTime_iff_noCertifiedCandidate` and
      `exists_witnessFamily_of_not_validZTime` — fully qualified Lean names, path-only File column
      (no line numbers), Frame class `ZTime`, Axioms `pcq pinned:C14`, Paper label `—`
- [ ] Confirm every `FormalSystem.lean` import line added in Phases 1-11 is present and in
      alphabetical position
- [ ] Run `bash scripts/check-module-invariants.sh` and resolve every finding it gates: C1 (build),
      C3 (zero structural `sorry`), C4 (imports resolve), C5/C12/C13 (markdown paths and links),
      C14 (axiom baselines — the new declarations need baseline entries), C15 (theorem-index rows
      carry `Paper: —` plus a reason at the declaration), C17 (dead declarations), C20 (line
      citations). Reported-not-gated checks (C18, C19) need no action
- [ ] Commit with `task 623: complete implementation`, staging **only** this task's files by
      explicit list

**Timing**: 5 hours

**Depends on**: 11

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the phase asserts that exactly two files (`WitnessFamily.lean`,
`WitnessFamily/README.md`) are shared with sibling 684 and that `docs/theorem-index.md` gains
exactly three rows. Confirm the sharing by re-reading both files immediately before editing and
by `git log` on each; confirm the row count against what C15 actually requires for the
declarations this plan lands.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` — new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — imports + submodule row (shared with 684)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — submodule row (shared with 684)
- `docs/theorem-index.md` — three ledger rows
- `FormalSystem.lean` — confirm the seven import lines

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0
- `git status --short` and `git diff --staged` reviewed before the commit; no file outside this
  task's list is staged
- No foreign commit or foreign uncommitted modification is present; if one is, STOP and report
  rather than proceeding

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.BiLasso.Unfold
import FormalSystem.Semantics.IntTransfer
import FormalSystem.Semantics.TruthTransport
import FormalSystem.Semantics.Validity

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

/-- The type of a position of an arbitrary ℤ-frame model, at the `WitnessFamily` closure. -/
noncomputable def typeAtM {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (τ : WorldHistory F.toTaskFrame) (u : ℤ) : Finset Formula := sorry

/-- `WitnessFamily.LocalCoherentLab` at a bare label sequence, with the lasso index dropped. -/
def LocalCoherentSeqLab (Γ Del : Context) (bx : Formula → Bool)
    (lab : ℤ → Finset Formula) : Prop := sorry

/-- `WitnessFamily.FulfillingLab` at a bare label sequence, with the lasso index dropped. -/
def FulfillingSeqLab (lab : ℤ → Finset Formula) : Prop := sorry

theorem typeAtM_localCoherentSeqLab {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) :
    LocalCoherentSeqLab Γ Del bx (typeAtM M Γ Del τ) := sorry

theorem typeAtM_fulfillingSeqLab {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    (Γ Del : Context) (τ : WorldHistory F.toTaskFrame) :
    FulfillingSeqLab (typeAtM M Γ Del τ) := sorry

theorem exists_good_cycle_of_typeSeq (C : Finset Formula)
    (d : ℤ → {S : Finset Formula // S ∈ C.powerset}) (ev : Formula → Option Formula)
    (x : {S : Finset Formula // S ∈ C.powerset})
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x)
    (hful : ∀ (u : ℤ) (f e : Formula), f ∈ (d u).1 → ev f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d s).1) :
    ∃ (L : ℕ) (p : ℕ → {S : Finset Formula // S ∈ C.powerset}),
      1 ≤ L ∧ L ≤ (2 * C.card + 1) * 2 ^ C.card ∧ p 0 = x ∧ p L = x ∧
      (∀ j, j < L → ∃ u : ℤ, d u = p j ∧ d (u + 1) = p (j + 1)) ∧
      (∀ f e : Formula, f ∈ x.1 → ev f = some e → ∃ j, j < L ∧ e ∈ (p (j + 1)).1) := sorry

theorem fulfillingSeqLab_of_good_cycles {Γ Del : Context} {bx : Formula → Bool}
    {lab : ℤ → Finset Formula}
    (hco : LocalCoherentSeqLab Γ Del bx lab)
    (hsub : ∀ t : ℤ, lab t ⊆ closureOf (Γ ++ Del))
    {nb nf nm : ℤ} (hnb : 0 < nb) (hnf : 0 < nf)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t)
    (hgoodf : ∀ g e : Formula, Formula.untl g e ∈ lab nm →
      ∃ s : ℤ, nm < s ∧ s ≤ nm + nf ∧ e ∈ lab s)
    (hgoodb : ∀ g e : Formula, Formula.snce g e ∈ lab (-1) →
      ∃ s : ℤ, -1 - nb ≤ s ∧ s < -1 ∧ e ∈ lab s) :
    FulfillingSeqLab lab := sorry

/-- The enumeration bound: `max` of the cycle and mid bounds at the target closure. -/
def compressionBound (Γ Del : Context) : ℕ := sorry

theorem exists_labelledLasso_of_history {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ (Λ : LabelledLasso (closureOf (Γ ++ Del))) (i : ℤ),
      Λ.back.length ≤ compressionBound Γ Del ∧
      Λ.mid.length ≤ compressionBound Γ Del ∧
      Λ.fwd.length ≤ compressionBound Γ Del ∧
      0 ≤ i ∧ i ≤ Λ.nm ∧
      Λ.lab i = typeAtM M Γ Del τ t ∧
      LocalCoherentSeqLab Γ Del bx Λ.lab ∧ FulfillingSeqLab Λ.lab := sorry

theorem exists_witnessFamily_of_not_validZTime (φ : Formula) (h : ¬ ValidZTime φ) :
    ∃ (W : WitnessFamily [] [φ]) (t : ℤ),
      (∀ Λ ∈ W.lassos,
        Λ.back.length ≤ compressionBound [] [φ] ∧
        Λ.mid.length ≤ compressionBound [] [φ] ∧
        Λ.fwd.length ≤ compressionBound [] [φ]) ∧
      W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1 ∧
      (∃ S : Finset Formula, S ⊆ closureOf ([] ++ [φ]) ∧ W.bx = fun χ => decide (χ ∈ S)) ∧
      0 ≤ t ∧ t ≤ (compressionBound [] [φ] : ℤ) ∧
      W.Certifies t := sorry

/-- The computable candidate list: every canonical-`bx` family whose lassos are drawn from the
full length grid `[0, compressionBound]³`. -/
def cands (φ : Formula) : List (WitnessFamily [] [φ]) := sorry

theorem mem_cands_of_bounded (φ : Formula) (W : WitnessFamily [] [φ])
    (hlen : ∀ Λ ∈ W.lassos,
      Λ.back.length ≤ compressionBound [] [φ] ∧
      Λ.mid.length ≤ compressionBound [] [φ] ∧
      Λ.fwd.length ≤ compressionBound [] [φ])
    (hcount : W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1)
    (hbx : ∃ S : Finset Formula, S ⊆ closureOf ([] ++ [φ]) ∧ W.bx = fun χ => decide (χ ∈ S)) :
    W ∈ cands φ := sorry

theorem validZTime_iff_noCertifiedCandidate (φ : Formula) :
    ValidZTime φ ↔
      ∀ W ∈ cands φ, ∀ t ∈ Finset.Icc (0 : ℤ) (compressionBound [] [φ] : ℤ),
        ¬ W.Certifies t := sorry

/-- The decision procedure. A `def`, not an `instance`: a global `Decidable (ValidZTime φ)`
instance would change instance resolution repository-wide. -/
def decidableValidZTime (φ : Formula) : Decidable (ValidZTime φ) := sorry

/-- The empty-premise consequence corollary, via `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ`. -/
def decidableSemanticConsequenceNil (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime [] σ) := sorry

end FormalSystem.Metalogic.Decidability
```

## Testing & Validation

- [ ] `lake build` exits 0 with the full tree after every phase
- [ ] Zero `sorry` anywhere in `WitnessFamily/Compression/` — asserted by content, per C3, never by
      line number. A `sorry` is **not** an acceptable phase outcome; a phase that cannot close
      splits instead
- [ ] `#print axioms` on `decidableValidZTime`, `validZTime_iff_noCertifiedCandidate` and
      `exists_witnessFamily_of_not_validZTime` is exactly `[propext, Classical.choice, Quot.sound]`
- [ ] The `Decidable` produced **computes** (carries no `Classical.dec` in its data). Note, as
      `BiLasso/Assembly.lean` already does, that this is not choice-freedom and none is claimed:
      `wlem_of_saturation` shows no finite-carrier route to this result can be choice-free
- [ ] The round trip closes: `WitnessFamily.refutes_of_certifies` applied to the family the
      compression theorem produces yields `Refutes [] [φ]`
- [ ] `WitnessFamily/` still imports nothing from `BiLasso/` except `Periodic.lean` — check by
      `grep -rn 'import FormalSystem.Metalogic.Decidability.BiLasso' FormalSystem/Metalogic/Decidability/WitnessFamily/`
- [ ] No new global `instance` and no new `@[simp]` lemma escapes the new subdirectory
- [ ] `bash scripts/check-module-invariants.sh` exits 0
- [ ] Non-vacuity spot-check: the `Examples.lean` families already in the tree are unaffected, and
      `no_witnessFamily_of_validZTime` still holds — the new `cands` must reject where that
      theorem says it must

## Artifacts & Outputs

New Lean modules, all under `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`:

- `Types.lean` — `typeAtM`, `mem_typeAtM`, `typeAtM_subset`, `LocalCoherentSeqLab`,
  `FulfillingSeqLab`, `typeAtM_localCoherentSeqLab`, `typeAtM_fulfillingSeqLab`
- `Cycle.lean` — `TypeState`, the generic walk/pigeonhole plumbing, `cycleBoundC`,
  `exists_good_cycle_of_typeSeq`
- `Fulfil.lean` — `untl_propagates_to_end`, `snce_propagates_to_start`, the two iterated
  periodicities, `fulfillingSeqLab_of_good_cycles`
- `Extract.lean` — `midBoundC`, `compressionBound`, the three walks,
  `exists_labelledLasso_of_history`
- `Family.lean` — `Formula.boxArg?`/`boxedPart`, the canonical `bx`, `BoxFaithful`,
  `exists_witnessFamily_of_not_validZTime`
- `Enumerate.lean` — `closureSubsetsOf`, `boundedLassos`, `cands`, `mem_cands_of_bounded`
- `Assembly.lean` — `validZTime_iff_noCertifiedCandidate`, `decidableValidZTime`,
  `decidableSemanticConsequenceNil`
- `README.md` — route, terminology map, duplication record, non-monotonicity note

Existing files modified:

- `FormalSystem.lean` — seven import lines, alphabetical
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — seven imports plus a submodule row
  (**shared with sibling task 684**)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — submodule row and the corrected
  "completeness half" sentence (**shared with sibling task 684**)
- `docs/theorem-index.md` — three rows in `### Decidability`

Not modified, despite appearing in the task's stale `file_scope`: `BiLasso/Assembly.lean`,
`BiLasso/README.md`, `BiLasso.lean`, `FormalSystem/Metalogic/Decidability/README.md`.

## Rollback/Contingency

Every phase is independently green and separately committed, so rollback is per-phase: revert the
phase's commit. The new subdirectory is additive — nothing outside it changes until Phase 12 — so
reverting any of Phases 1-11 cannot break an existing module.

If a whole-tree rollback that discards uncommitted work is genuinely needed (not as a routine
precaution), take a snapshot first per `context/contracts/recovery.md`'s rollback rung, which is
what makes the destructive command admissible to `guard-destructive-git.sh`; that rung also names
the out-of-scope override flag the whole-tree case needs. For an ordinary defensive checkpoint
before risky work — the Phase 6/7 geometry is the likely candidate — use
`bash .claude/scripts/git-snapshot.sh 623 --no-revert`, which is durable and does **not** revert
the working tree. Never emit a bare, default-mode `git-snapshot.sh` as a start-of-phase
precaution, and never run it in reverting mode at all while sibling tasks 684 and 690 share this
working tree.

Contingency for the one structural risk — transcription volume — is recorded in **Risks &
Mitigations**: split the phase first; relocate to a sibling `Decidability/Compression/` directory
that may import `BiLasso/GoodCycle.lean` only as a last resort, accepting that it forecloses the
general context-indexed form.
