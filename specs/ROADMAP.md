# Roadmap

*Open work only, derived from `specs/state.json` (2026-10-05). Completed work is recorded in
`specs/CHANGE_LOG.md` and `specs/archive/`; reference material — the BX axiom layers, the
irreflexive truth semantics, the canonical-model and quasimodel constructions — lives in
`README.md`, the module docstrings and `typst/BimodalReference.typ`. Each phase below is one or
more `/orchestrate` batches. Phase numbers are stable identifiers cited from task records, so
they are not a run order; the priority on each heading is.*

**The programme's aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.**
Phase 1 is that front and owns it end to end. Everything else is subordinate to it.

Contended files force several phases to run as sequences rather than one batch — a batch whose
members share a declared file is deferred every cycle by the admission gate
(`.claude/context/patterns/batch-orchestration-guardrails.md`). Live collisions:
`scripts/check-evidence-probes.sh` and `specs/evidence/seam-gluing-ray-product/` (720, 725, 732,
733, 734 — five writers, so Phase 1's probes run singly), `README.md` (177, 543),
`MintBound.lean` (464, 465), `data/README.md` (282, 257). Two more are invisible to the gate:
every task adding a module needs a line in the aggregator
`FormalSystem/Semantics/Presheaf.lean`, and every one of them regenerates `FormalSystem.lean` and
the READMEs via `lake exe mk_all` and `--emit-inventory`. A task with no declared `file_scope` is
invisible to the gate as well — 27 of 51 non-terminal tasks, which `validate-state.sh` reports.

---

## Phase 0: User Decisions (High Priority)

User-only rulings; no agent may transition these. The 2026-10-03 rulings on tasks 710, 711, 712
and 713 are recorded in those task records and in `specs/CHANGE_LOG.md`.

- [ ] Rule on tasks 127 and 128, the object-language extensions (time addition, interior
      operator): long-standing abandonment candidates, antagonistic to the termination work the
      tableau spine depends on (Task 127, Task 128)
- [ ] Supply the Hugging Face account and token task 257 is blocked on (Task 257)

```
# user-only; no orchestration command applies
```

---

## Phase 1: The Gluing Route to Decidability (Highest Priority)

A possible world is a way of **gluing** a backward ray to a forward ray at a seam — a reading of the
landed semantics, not a new one. The aim is OPEN by every route; this is the ranked-first route to
it, and the only one with an end-to-end owner.

**Proved (the keystone).** The `⊡` quantification domain *is* the fibre product of the past-ray and
future-ray spaces over the seam state: `plusStab_iff_rays` (general task frame) and
`plusStab_iff_omega` (ω-sequence form over ℤ), with `seamOmegaEquiv` and `pathFibreEquiv`, across
`Semantics/Presheaf/Ray.lean` and `PlusLanguage/PlusRayFibre.lean`. Under **`[F.IsRegular]`**, never
unconditionally; axioms pinned in the C2 harness. Carrier normalization is landed too
(`plusValidZTime_iff_plusValidInt`).

**Owed.** One device, then the assembly. A universal, complementation-shaped summary device is
proved NECESSARY and a nondeterministic one proved UNSOUND — but *which* device is unselected, and
that single unrun experiment is what gates the whole front.

Three cautions. Gluing does **not** bound the fibre — the route concedes infinite fibres and seeks
a finite *presentation*, the only move `not_finite_width_fmp` leaves open. The binary seam case is
choice-free while the *directed* case needs Saturation, so an ω-ray built by iterated gluing is a
directed colimit. No upper bound is claimed anywhere; the ARGUED ceiling in task 713 is a citable
anchor, never an upper-bound source.

Critical path: **732 → 711 → 735**. Everything else in this phase is evidence or fallback.

- [ ] Run experiment **E3**, the device-selection probe, on the `⊡(Fp)`/`⊡(Pp)` shapes. Four live
      candidates, none selected: Safra/Piterman (no formalization exists in *any* proof assistant),
      Safraless (Kupferman–Vardi 2005), MSO over ⟨ℤ,<⟩ plus Büchi (Hodkinson–Wolter–Zakharyaschev
      2000 route 1 — covers ⟨ℤ,<⟩, needs no Safra construction), a Ramsey colour. Run with `--lit`;
      two candidates rest on sources the corpus lacks (Task 732)
- [ ] Build the universal-summary substrate once E3 selects a device. `[BLOCKED]` on 732 by its own
      recorded reason; also carries the depth-2 stratification probe E2 (Task 711)
- [ ] Assemble the decidable stab check on the ray-product presentation — `Decidable
      (PlusValidZTime φ)`, or a recorded verdict that the presentation cannot deliver it. Depends
      on 711. `file_scope` is deliberately absent and MUST be set at plan time (Task 735)
- [ ] Probe the backward dual on a backward-**nondeterministic** mirror fixture. E1 came out
      POSITIVE and is wired, so the two-factor presentation stands — but on a backward-*deterministic*
      fixture, whose backward factor is a singleton. The finite-width obstruction lives in the
      backward factor, so that is the one region where it cannot appear. A failure here is a
      falsifier for the two-factor presentation (Task 733)
- [ ] Rule on task 725 as close-as-subsumed: task 719 landed E1 first, which is the subsumption
      condition 725's own record names (Task 725)
- [ ] Run experiment **E4** for route R2 (mosaics): decide `StabSaturated` on mixed germ states,
      not the same-state corner it is proved in, and acquire the Hodkinson–Reynolds Handbook §§5.10–5.11
      bodies the corpus lacks. R2 cannot be promoted on textual grounds until both land (Task 734)
- [ ] Finite width ⇒ eventually periodic, as R1's **summary step** rather than a route of its
      own; closes as a reasoned exclusion, with its restrict-to-safety fallback recorded, if E3
      picks an automaton acceptance condition over a Ramsey colour (Task 709)

Routes closed, not to be re-attempted: **filtration** (R4) for ℤ-time, by
`Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` — residue is dense durations
only. **Translation to a decidable FO fragment** (R5) is low: the monodic decidability proof *is*
the quasimodel method, routing back to R1/R2. Do not file a fourth certificate class — any class
with finite fibres is already refuted.

`app:gluing` is live and proved in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`,
its seam case written as `ρ ⌢_z σ` but commented out; `app:Structure` and
`app:presheaf-dictionary` are **cut** from the paper. Treat a cut clause as a specification to
implement, never as a theorem to cite.

```
/orchestrate 732 --lit --hard   # the gate: nothing on the critical path moves until this reports
/orchestrate 733                # singly -- five writers contend on the evidence collection
/orchestrate 734 --lit          # singly, same contention; R2 fallback
/orchestrate 725                # the subsumption ruling
/orchestrate 709 --hard         # R1's summary step, not a phase capstone
# 711 then 735 follow, in that order, once 732 reports a selection
```

---

## Phase 2: L⁺ Sliced Certificates (High Priority)

The time-sliced certificate class is incomplete for full L⁺ **and** for the CTL-like fragment,
and no certificate class presenting finite per-time fibres is complete whatever its clauses. The
obstruction is finite *width* — limit closure plus finite fibres contradicts König — strictly
stronger than the earlier finite-*carrier* failure. Both halves are now landed: the width half in
`PlusSlicedCertificate/Limits/NoFiniteWidth.lean` and the finite-carrier family in
`PlusSlicedCertificate/Limits/FiniteCarrier.lean`, the latter with `θ_eq_ofFormula` recording the
`⊡`-free status of the witness. Do not file a fourth certificate class: any class
with finite fibres is already refuted.

- [ ] Fix the `liveT`/`liveAt` non-termination: the landed fixpoint does not return in 300s on a
      4-position total-edge certificate while being instant on self-loop ones. A defect in
      shipped, gated code, not an unbuilt feature (Task 716)
- [ ] Re-point the `FMP/README.md` and `scripts/check-evidence-probes.sh` citations from the
      `WIRED_REPO` probe paths to the landed library names, or close as subsumed if the landings
      leave no probe to move (Task 720)
- [ ] Evaluate carrying full labels in the certificate, which would make `posAt` a singleton and
      delete both liveness filters; the question is whether decidability of the check survives
      (Task 714)
- [ ] Close task 712 as a refutation record now that 710 has landed, **first verifying that the
      library theorem IS 712's statement** — a weaker or differently shaped result would make
      "refuted" an overclaim. `[ABANDONED]` was rejected by ruling: the question was asked and
      definitively answered no, and a future reader deserves that answer rather than silence
      (Task 712)

```
/orchestrate 716              # owns PlusSlicedCertificate/{Live,Check,Examples}
/orchestrate 714 --research   # beside it: declares no file_scope, research-only
/orchestrate 720              # the citation re-point, now that both refutation halves have landed
/orchestrate 712              # the closure, once 710's statement is checked against it
```

---

## Phase 3: The Behavior Presheaf (High Priority)

Each item is a clause of `app:presheaf-dictionary` and each has a proved hook already in the tree,
which is why the cluster is bounded rather than open. The skeleton and the Sheaf, Totality,
Directed Gluing and Determinism clauses have all landed
(`FormalSystem/Semantics/Presheaf/{Site,Behavior,Sheaf,Directed}.lean`, with
`Beh.germEquiv : Beh F 0 ≃ F.WorldState`); four clauses remain. **Run this
front in batches of at most two, or singly** — never as one wide wave: every task here needs a
one-line import in the aggregator `FormalSystem/Semantics/Presheaf.lean`, which no remaining task
declares and which is deliberately outside the other scopes, so the gate cannot see the
collision. Re-run `lake build` after each
aggregator edit.

- [ ] Prove the Reflection clause: `Beh(F) ≅ Beh(F⁻) ∘ ref` (Task 617)
- [ ] Formalize the duration monoid `BD⁺`, its twisted-arrow category, and
      `lem:interval-twisted-arrow` (Task 616)
- [ ] Prove the Possible Worlds clause `H_F ≅ lim Beh(F)(2x)`, via the existing
      `FrameOver.mem_HF_iff_adjacent` (Task 566)
- [ ] Formalize the path category `Path(F)` and `cor:path-fibration`: `len` is a discrete
      Conduché fibration whose presheaf is `Beh(F)` (Task 618)

```
/orchestrate 616,617
/orchestrate 566          # the Possible Worlds clause
/orchestrate 618          # after 616
```

---

## Phase 4: Examples, Dataset Pipeline and Final Docs (Medium Priority)

Independent of every other phase. Task 177 runs last in the programme — it carries 26
dependencies including the whole tableau spine — and is listed here only because it owns the
documentation territory.

- [ ] Expand `Examples/` with the publication-quality worked pipeline: soundness and completeness
      on a concrete formula, plus decidability of the propositional fragment, the fragment that is
      genuinely decidable today (Task 178)
- [ ] Fix the c7 labeling bug at formula ~13750 that causes unbounded memory growth in the
      decision procedure's timeout handling, then regenerate the c7 dataset (Task 298)
- [ ] Re-add the six derived binary temporal operators to the enumerator so they survive
      deduplication (Task 296)
- [ ] Flip complexity-9 generation from stratified to exhaustive by default (Task 282)
- [ ] Add zstd-compressed `.jsonl` support across the pipeline (c7 is already 17G → 153M on disk
      as `.jsonl.zst`) (Task 604)
- [ ] Build the regeneration automation so every dataset rebuild updates its downstream artifacts
      and documentation fields (Task 231)
- [ ] Run the Hugging Face upload the prior round left unexecuted, then confirm
      `data/hf-dataset/PUBLISHING.md`'s Migration Status; blocked on the Phase 0 credential
      (Task 257)
- [ ] Calibrate baseline difficulty by running bmlogic-bench through at least three LLMs
      (Task 219)
- [ ] Final README, `docs/` and module-docstring polish (Task 177)

Before treating 298 as blocked, re-check the line and metadata counts: a long c7 regeneration was
observed running and may have completed.

```
/orchestrate 178,604        # neither touches the dataset files
/orchestrate 298            # alone: owns DatasetGenerator.lean + data/bmlogic-c7.jsonl
/orchestrate 282,296        # after 298; disjoint scopes
/orchestrate 231
/orchestrate 219
/orchestrate 257            # once the token exists; shares data/README.md with 282
/orchestrate 177            # last in the programme
```

---

## Phase 5: Metalogic Questions and Literature (Medium Priority)

All four are runnable today. Two are research-only by their own classification and land no
library change.

- [ ] Machine-check the principal MF frame-correspondence rigidity results researched in the
      PossibleWorlds paper repository; six external reports exist and must be read first
      (Task 543)
- [ ] Run further verdict-first rounds on the nondeterministic canonical model for TM⋆
      completeness — reports and probes only, no changes to `FormalSystem/` (Task 559)
- [ ] Settle the C3 question: is the domain-restricted consequence relation's logic Burgess–Xu
      without unboundedness, plus S5? An open research question, not an implementation task
      (Task 570)
- [ ] Acquire and ingest the Cmiel–Kuhlmann–Kuhlmann ball-space paper; the corpus has no copy
      (Task 664)

```
/orchestrate 664                      # first: 543 and 559 use --lit
/orchestrate 543 --hard               # declares README.md; a different cycle from 177
/orchestrate 559 --research --lit     # verdict-first; stops after research
/orchestrate 570 --research
```

---

## Phase 6: The TM Tableau Spine (Low Priority)

Nine waves from 464 to 482, the longest chain in the programme, three of whose links are open
mathematics. Deprioritized relative to Phases 1 and 2.

Three facts bound the front. Two must not be re-attempted: the unconditional
`buildTableau_isSome` is FALSE by construction at the engine's `maxBranches := 50000` guard, at
any fuel; and the whole decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`,
`regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch that
mints a world — so task 429 is a redesign, not a repair. The tombstone list is the C9 register in
`MintBound.lean`. The third bounds what the front may claim: ℤ-time validity of L is **already
decided** by the witness-family route (`Compression.decidableValidZTime`; `FrameClass.ZTime`,
`Formula` with no `⊡`, empty premises), so the deliverable here is the four-class `isValid`
biconditional, not the first decidability theorem.

- [ ] Design and land `gapPotential`, the density coordinate of the termination measure — the one
      genuinely open mathematical question on the totality terminus (Task 464)
- [ ] Repair or replace the `UnorderedSuccessorLabelClosed` residual, refuted in-tree at a
      nonempty universe; a C9 register entry is a complete, valid outcome (Task 481)
- [ ] Complete the terminus restatement family at the repaired residuals: the fourteen
      restatements recorded as a reasoned exclusion (Task 465)
- [ ] Prove engine totality at a quantified branch budget, via the amortized mint-bound route
      (Task 428)
- [ ] Redesign the truth-lemma side conditions — propagate `T(□φ)` to the freshly minted world,
      with its own `RuleSound` obligation (Task 429)
- [ ] Internalize tableau branches and prove the routine rule admissibilities (Task 410)
- [ ] Prove the hard admissibility lemmas for the Until/Since trichotomy and the
      discrete/Dedekind rules (Task 411)
- [ ] The semantic lift `valid_iff_allClosed`, and with it the `isValid φ fc = true ↔ ⊨ φ`
      biconditional and the four `Decidable (⊨ φ)` instances. Only the sound direction has landed
      (`isValid_sound`); no `isValid`-shaped `iff` is written until it can be proved, and the
      ZTime instance must agree with `Compression.decidableValidZTime` (Task 430)
- [ ] Prove the refutation core and decidability of provability with its completeness corollaries
      (Task 412)
- [ ] Discharge proof-extraction completeness, eliminating `.extractionFailed` on a genuinely
      closed tableau. `Verified/Refutation/` does not exist and no verifier declaration exists in
      `ProofExtraction.lean`, so 482 must re-verify its own anchors first. OPEN MATHEMATICS,
      multi-month; must not be re-described as engineering (Task 482)

Task 481 is `[BLOCKED]` with no recorded reason while its own description classifies it as a
runnable repair-or-replace: lift the block or force the dispatch. Tasks 410, 411 and 412 declare
no `file_scope`.

```
/orchestrate 464 --hard --lit   # the open measure question; research-heavy
/orchestrate 481 --hard         # parallel entry; 464 and 465 share MintBound.lean
/orchestrate 465                # then strictly in chain order, one per cycle:
/orchestrate 428 --hard
/orchestrate 429 --hard
/orchestrate 410
/orchestrate 411
/orchestrate 430 --hard
/orchestrate 412
/orchestrate 482 --hard --lit
```

---

## Phase 7: Algebraic Representation (Low Priority)

Five waves to the Jónsson–Tarski capstone, gated on the front's own literature verdict. Every task
here declares an empty `file_scope`; scope them before running any wave concurrently.

- [ ] Ground the front in Goldblatt and BRV **before** the STSA axiom set is fixed; this gates
      everything below it transitively (Task 502)
- [ ] Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap;
      the seed is 361 lines behind `#exit` in `Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
      (Task 497)
- [ ] Reconcile the ShiftSet representation, landed for the compactness route, with the STSA
      route, so two parallel representation theorems are not developed and then reconciled
      (Task 500)
- [ ] Build the complex algebra `Cm(F)`: the powerset STSA over a `TaskFrame` (Task 498)
- [ ] Build the ultrafilter frame `Uf(A)` and prove it is a `TaskFrame`; HARD — the seed is 1189
      lines behind `#exit` with 4 sorry hits (Task 499)
- [ ] Prove the Jónsson–Tarski representation theorem: `η(a) = {U | a ∈ U}` is an injective STSA
      homomorphism `A → Cm(Uf(A))` — the capstone (Task 125)
- [ ] Extend STSA with the binary Until and Since operators, which the live object language has as
      primitives (Task 501)

```
/orchestrate 502 --research --lit   # the literature gate; nothing below it starts first
/orchestrate 497
/orchestrate 498,499,500 --hard
/orchestrate 125 --hard
/orchestrate 501
```

---

## Not Scoped as Tasks

Two gaps have no task and no owner. **Strong completeness over ℚ-time**: weak completeness is done
(`derivable_of_validQTime`), but compactness goes through ultrapowers of ℚ, which are dense yet no
longer ℚ-time — Cantor gives an order isomorphism, not a group one. Unlike Discrete and Dedekind it
is not known to be impossible. **Genuine `Set Formula` strong completeness** for Base and Dense:
its gate, the shift-set representation theorem, has been passed, but the ultraproduct work behind
it is unfiled.

## Maintenance

`/review` Step 2.5 (`.claude/scripts/roadmap-integration.sh`) parses the `## Phase N:` headings and
`- [ ]` checkboxes above and annotates an item once its `(Task N)` reaches `completed`; `/todo`
surfaces the same completions when archiving. Annotated items are dropped when their phase is next
revised — the durable record is `specs/CHANGE_LOG.md` and `specs/archive/`. Update the phases when
`/task --expand`, `/spawn` or a dependency change alters the graph, and treat any claim here that
no check can reproduce as a defect in this file rather than a fact about the tree. The periodic
re-run of the decidability inventory is owned by `scripts/generate-decidability-inventory.sh`,
which regenerates the PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED inventory from the tree and
diffs it (`--diff`) against the committed `scripts/decidability-inventory-baseline.txt`; that
baseline was extracted from section 1 of
`specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
(moved into the archive when that task was archived).

## Related

- `.claude/context/formats/roadmap-format.md` — this file's parseable structure
- `.claude/context/patterns/batch-orchestration-guardrails.md` — why the run blocks are sequences
- `specs/TODO.md` — task records, Task Order and dependency waves
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
