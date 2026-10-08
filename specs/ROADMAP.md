# Roadmap

*Open work only, derived from `specs/state.json` (2026-10-08). Completed work is recorded in
`specs/CHANGE_LOG.md` and `specs/archive/`; reference material — the BX axiom layers, the
irreflexive truth semantics, the canonical-model and quasimodel constructions — lives in
`README.md`, the module docstrings and `typst/BimodalReference.typ`. Phase numbers are stable
identifiers cited from task records, so they are **not** a run order: the Run Order below is.
Agent-system and repo-hygiene records (729, 730, 731, 741) are tracked in `specs/TODO.md` only and
are deliberately unphased here.*

**The programme's aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.**
Phases 1 and 2 are that front and preempt everything else for agent time. Phases 3–7 are
subordinate and may be run only when the decidability front is blocked on a user ruling or on
open mathematics.

## Run Order

Each line is one `/orchestrate` invocation. Batches are dependency-inclusive: the engine
re-derives eligibility every cycle from the dependency graph, so a batch containing both a
blocker and its dependent is correct — the blocker runs first and the dependent waves in behind
it. `MAX_TASKS` is 8 and the work-cycle budget is **per task, per invocation**, resetting each time:
5 by default and 13 under `--hard` (measured 2026-10-08 — a 10-phase `--hard` task consumed 12 of
its 13, and a sibling in the same batch drew on its own full 13, so batching did not starve it).
A long batch may still need re-invocation: **re-run the same line until it reports every member
terminal.** A batch whose members share a declared file is not broken, only serialized — the
admission gate defers the collider each cycle until its sibling goes terminal.

```bash
# --- Decidability front (Phases 1-2): run these to exhaustion before anything below ---
# 742 and 735 are COMPLETE (2026-10-08). The ray-product route R1 closed with a NEGATIVE
# verdict, so nothing below is R1's critical path any more: every remaining line here is
# evidence, fallback or housekeeping. Reviving a critical path requires FILING (C), (S) or (W)
# (RaySummary README, "The verdict") — the user's call, which this roadmap does not make.
/orchestrate 739,733,734,725 --lit    # evidence probes + one ruling; serialized on the collection.
                                      # 734 is the mosaic route R2 and is now the live fallback
/orchestrate 709,740 --hard           # F4 summary step + KTypeSummary housekeeping. NOTE: 709 was
                                      # R1's summary step; re-rule on its value before dispatching
/orchestrate 716,714,712 --hard       # sliced-certificate defect, label evaluation, closure.
                                      # 712 is [BLOCKED] with NO reason recorded — see Phase 1
/orchestrate 720                      # citation re-point; shares the evidence collection above

# --- Subordinate fronts, in priority order ---
/orchestrate 616,618                  # Presheaf: strict chain, so no aggregator contention
/orchestrate 617,566                  # Presheaf: see the aggregator warning in Phase 3
/orchestrate 664,559,570 --lit        # metalogic + literature; all three unblocked
/orchestrate 298,282,296,231,219      # dataset chain: 298 unblocks the rest
/orchestrate 178,604                  # docs/pipeline, disjoint scopes
/orchestrate 464,465,481 --hard       # tableau spine entry; 464/465 share MintBound.lean
/orchestrate 428,429,410,411 --hard   # spine middle; 428 is [BLOCKED], see Phase 6
/orchestrate 430,412,482 --hard --lit # spine terminus; 482 is open mathematics
/orchestrate 502,497 --research --lit # algebraic: the literature gate
/orchestrate 498,499,500 --hard       # complex algebra + ultrafilter frame
/orchestrate 125,501,543 --hard       # Jonsson-Tarski capstone; 543 unblocks once 500 lands
/orchestrate 177                      # last in the programme: 26 dependencies
```

Blocked on a user ruling, not schedulable: **257** (Hugging Face credential), **127**/**128**
(Phase 0), **713** (held by ruling of 2026-10-03).

---

## Phase 0: User Decisions (High Priority)

User-only rulings; no agent may transition these.

- [ ] Rule on tasks 127 and 128, the object-language extensions (time addition, interior
      operator): long-standing abandonment candidates, antagonistic to the termination work the
      tableau spine depends on (Task 127, Task 128)
- [ ] Supply the Hugging Face account and token task 257 is blocked on (Task 257)

```
# user-only; no orchestration command applies
```

---

## Phase 1: The Gluing Route to Decidability (Highest Priority)

A possible world is a way of **gluing** a backward ray to a forward ray at a seam. The aim is OPEN
by every route; this is the ranked-first route and the only one with an end-to-end owner.

**Standing results.** The `⊛` quantification domain *is* the fibre product of the past-ray and
future-ray spaces over the seam state (`plusStab_iff_rays`, `plusStab_iff_omega`), under
**`[F.IsRegular]`**, never unconditionally; carrier normalization is landed
(`plusValidZTime_iff_plusValidInt`). The substrate is landed as `WeakCanonical/KTypeSummary/` —
Büchi's complementation chain in the monadic k-type idiom over the ℤ time axis, sorry-free on
standard axioms. The device is the **time-axis Ramsey-coloured summary** over in-tree
`Nat.exists_strictMono_const_pair_colour` (resolve by name, never by line), **framed by** the
MSO-over-⟨ℤ,<⟩ quasimodel route (Hodkinson–Wolter–Zakharyaschev 2000;
Gabbay–Kurucz–Wolter–Zakharyaschev 2003). Record:
`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.

**The reduction's content is one object: `Hit`.** The landed bundle `Presents` was characterized as
**seam decidedness** — inhabited iff `⊛φ ∨ ⊛¬φ` at the seam (`exists_presents_iff`), with an
E2-fixture seam admitting no inhabitant — so `colours` in that shape was a seam condition, not the
reduction. The corrected interface is landed: `⊛φ` is a hypothesis-free finite conjunction over the
realized family triples `Hit` (`plusStab_iff_forall_hit`), and `PresentsMulti` is inhabited
outright. The cluster supplies Büchi's complementation half in full, and the realizability half is
now landed **as far as a presentation**: `hitOf` is computable on a finite labelled presentation
and is exactly the family triples of its runs (`mem_hitOf_iff`), a history's closure trace is the
unique anchored local run (`clTrace_localRun`, `eq_clTrace_of_localRun_anchored`), and a seam's
`HitCl` **is** `hitOf` under the explicit realization hypothesis `Presented`
(`hit_eq_hitOf_of_presented`) — which is discharged for **no** non-trivial model. The residue is
exactly that discharge: constructing a regular model from a presentation (B2b), the successor
bullet below. `Hit` is still never computed for a model outright.

**The critical path to `Decidable (PlusValidZTime φ)` is NOT through B2b.** 735 landed its
verdict (RaySummary README, "The verdict"): the ray-product presentation as
landed — `seamOmegaEquiv` + `hitOf` + `Presented` — cannot deliver the decision procedure, by the
wired probe `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
(`Probe735.not_presented`: `Presented` fails on a three-state regular ℤ-model for every finite
presentation), and that verdict does not depend on B2b. B2b is requirement **(S)** only —
Hit-level soundness, the realization of a presentation by a constructed regular model — and (S)
alone is not sufficient: **(C)** Hit-level completeness with a computable bound (`Presented`
cannot carry it, by the probe; the Hit-level hypothesis's satisfiability is OPEN) and **(W)** a
closure-wide quasimodel over all seams and times (`box` per time, `stab` per state, nested under
`untl`/`snce`) are unfiled requirements, named with their statement shapes under `[F.IsRegular]`,
L⁺, ℤ time in the RaySummary README. The ray-product presentation's deliverable on this front is
the verdict plus the conditional per-seam check (`decidableStabOfPresented`, under `Presented`,
vacuous on model A). Filing (C), (S) or (W), and any dependency edit, is the user's call; this
roadmap files nothing. Everything else in this phase is evidence or fallback.

**Four constraints that rule work out.** (1) The substrate must work over the **time axis with a
finite alphabet of per-time summaries, never over states** — forced by
`…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`, which refutes pigeonhole-tier lasso
summaries on the infinite acyclic fibre. (2) Gluing does **not** bound the fibre: the route
concedes infinite fibres and seeks a finite *presentation*. Any phase reintroducing a finite-fibre
or finite-width assumption is reproducing a refuted shape. (3) **No upper bound is claimed
anywhere**; the ARGUED CTL⋆ 2EXPTIME ceiling (Task 713, held) rules proposals out and is never an
upper-bound source. (4) **Zero debt**: no external Büchi/MSO lemma cited in place of a proof, and
no cslib `require` — `~/Projects/cslib/` is a read-only reference, since a require edge would drag
this tree 76 Mathlib commits forward.

Two honest limits stay open: the `⊡(Pp)` backward side is fixed only by
`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture, with **no backward
Bool-fixture bridge**, so a forward-only result must say so rather than implying symmetry; and the
`⊡(Fp)`/`⊡(Pp)` shapes are **device-inert** on finite fixtures, so no record may claim they
discriminate between devices.

- [ ] Realize a seam presentation — HWZ 2000 Thm 14 ⇐ for the `⊡` fibre, the B2b successor
      record: product summaries `BwdSummary × FwdSummary` of the two atom-sequence ray languages
      (the fibre is a product, `seamOmegaEquiv`, so a per-state summary must be splice-closed),
      an infinite committed-state slice (a finite step graph on a finite slice realizes limit
      paths, so deferred eventualities need committed chains), a `Saturation` constructor for
      sliced frames with finitely many fibre shapes per time (`ofSlicedStep_saturation` is
      `[Finite W]`-only; est. 300-500 lines, CARRIED from 742's research), and `hit_modelOf` —
      `Presented (modelOf P) … P`, discharging the hypothesis `hit_eq_hitOf_of_presented` is
      conditional on. Est. 1,200-2,000 lines, HIGH, CARRIED-UNVERIFIED. 735's soundness depends
      on it: without a discharged `Presented` the assembly's `Bool` is conditional. Either the
      construction lands, or a per-sub-obstruction machine-checked verdict does. `file_scope`
      MUST be set at plan time (successor of Task 742; to be filed). Consistency conditions must
      exclude pumpable eventuality-deferring run sets (`presented_localRun`); completeness is out
      of this record's reach (`presented-not-complete.lean`): it is requirement (S) of 735's
      verdict and only (S), and 735's verdict does not depend on it. Filing it, and any dependency
      edit, remains the user's call
- [ ] Prove F4, finite width ⇒ eventually periodic, as R1's **summary step**. A Ramsey colour was
      selected, so F4 *is* the device. Any surviving statement must name its restricted fragment
      and say in its docstring why `not_finite_width_fmp` does not refute it (Task 709)
- [ ] Run E2's **real** test: the depth-2 stratification falsifier on a fixture with three or more
      states, two of them *sharing* the depth-1 stratum, plus the `⊡(Fp → ⊡Pp)`-shaped mixed
      formulas the landed probe leaves out. The landed positive is weak — a two-state fixture has
      one state per stratum value, so the question is answered trivially. At stake is what
      licenses the finite per-time alphabet (Task 739)
- [ ] Probe the backward dual on a backward-**nondeterministic** mirror fixture. E1 is POSITIVE
      and wired, but on a backward-*deterministic* fixture whose backward factor is a singleton —
      the one region where the finite-width obstruction cannot appear. A failure here falsifies
      the two-factor presentation (Task 733)
- [ ] Run experiment **E4** for route R2 (mosaics): decide `StabSaturated` on mixed germ states,
      not the same-state corner it is proved in, and acquire the Hodkinson–Reynolds Handbook
      §§5.10–5.11 bodies the corpus lacks. R2 cannot be promoted on textual grounds until both
      land (Task 734)
- [ ] Housekeeping: restate `kType_finite`, `exists_matching_factorization` and
      `finite_family_triples` over `[Finite sig.preds]` (strictly stronger) and retire their six
      linter suppressions, or record per declaration the statement-fidelity reason the pinned
      `[Fintype] [DecidableEq]` form stays (Task 740)
- [ ] Rule on task 725 as close-as-subsumed: task 719 landed E1 first, which is the subsumption
      condition 725's own record names (Task 725)

**Routes closed, not to be re-attempted.** **Filtration** (R4) for ℤ-time, by the landed
`PlusSlicedCertificate/Limits/` pair `no_finite_carrier_sat` and `not_finite_width_fmp` — cite
those library names, not the archived `Probe706.`/`Probe710.` spellings; residue is dense durations
only. **Translation to a decidable FO fragment** (R5) is low: the monodic decidability proof *is*
the quasimodel method, routing back to R1/R2.

**Contention.** 739, 733 and 734 are three writers on `scripts/check-evidence-probes.sh` and
`specs/evidence/seam-gluing-ray-product/`, and 720 (Phase 2) is a fourth — batched together they
serialize rather than fail. 740 overlaps `RaySummary/` and `KTypeSummary/` with the now-complete
742, so it is clear to batch with 709.

```bash
/orchestrate 739,733,734,725 --lit    # serialized on the evidence collection; 734 is R2, the
                                      # live fallback now that R1 has returned its verdict
/orchestrate 709,740 --hard           # re-rule on 709 first: it was R1's summary step
```

---

## Phase 2: L⁺ Sliced Certificates (High Priority)

The time-sliced certificate class is incomplete for full L⁺ **and** for the CTL-like fragment, and
no class presenting finite per-time fibres is complete whatever its clauses — the obstruction is
finite *width* (limit closure plus finite fibres contradicts König), strictly stronger than the
earlier finite-*carrier* failure, and both halves are landed under `PlusSlicedCertificate/Limits/`.
**Do not file a fourth certificate class.**

- [ ] Fix the `liveT`/`liveAt` non-termination: the landed fixpoint does not return in 300s on a
      4-position total-edge certificate while being instant on self-loop ones. A defect in
      shipped, gated code, not an unbuilt feature (Task 716)
- [ ] Evaluate carrying full labels in the certificate, which would make `posAt` a singleton and
      delete both liveness filters; the question is whether decidability of the check survives
      (Task 714)
- [ ] Close task 712 as a refutation record, **first verifying that the library theorem IS 712's
      statement** — a weaker or differently shaped result would make "refuted" an overclaim.
      `[ABANDONED]` was rejected by ruling: the question was asked and definitively answered no,
      and a future reader deserves that answer rather than silence (Task 712)
- [ ] Re-point the `FMP/README.md` and `scripts/check-evidence-probes.sh` citations from the
      `WIRED_REPO` probe paths to the landed library names, or close as subsumed if the landings
      leave no probe to move. Re-check what remains before planning: two archived `WIRED_REPO`
      paths in that script were already repaired (Task 720)

```bash
/orchestrate 716,714,712 --hard   # 716 owns PlusSlicedCertificate/{Live,Check,Examples}
/orchestrate 720                  # separately: shares the evidence collection with Phase 1
```

---

## Phase 3: The Behavior Presheaf (High Priority)

Each item is a clause of `app:presheaf-dictionary` with a proved hook already in the tree, which is
why the cluster is bounded rather than open. The skeleton and the Sheaf, Totality, Directed Gluing
and Determinism clauses have landed under `FormalSystem/Semantics/Presheaf/` (with
`Beh.germEquiv : Beh F 0 ≃ F.WorldState`); four clauses remain.

**Aggregator warning — the one collision the gate cannot see.** Every task here needs a one-line
import in `FormalSystem/Semantics/Presheaf.lean`, which no task declares and which sits outside
every declared scope. Two concurrent writers will conflict invisibly. The durable fix is to add
that path to each task's `file_scope` so the gate serializes them; until then, batch only tasks
already serialized by a dependency edge, and re-run `lake build` after each aggregator edit.

- [ ] Formalize the duration monoid `BD⁺`, its twisted-arrow category, and
      `lem:interval-twisted-arrow` (Task 616)
- [ ] Formalize the path category `Path(F)` and `cor:path-fibration`: `len` is a discrete Conduché
      fibration whose presheaf is `Beh(F)` (Task 618)
- [ ] Prove the Reflection clause: `Beh(F) ≅ Beh(F⁻) ∘ ref` (Task 617)
- [ ] Prove the Possible Worlds clause `H_F ≅ lim Beh(F)(2x)`, via the existing
      `FrameOver.mem_HF_iff_adjacent` (Task 566)

```bash
/orchestrate 616,618      # safe: 618 depends on 616, so they never run concurrently
/orchestrate 617,566      # only after adding Presheaf.lean to both scopes
```

---

## Phase 4: Examples, Dataset Pipeline and Final Docs (Medium Priority)

Independent of every other phase. Task 177 runs last in the programme — it carries 26 dependencies
including the whole tableau spine — and is listed here only because it owns the documentation
territory. Task 298 is the chain's root: 282, 296 and 231 all depend on it, and 219 on 231.

- [ ] Fix the c7 labeling bug at formula ~13750 that causes unbounded memory growth in the
      decision procedure's timeout handling, then regenerate the c7 dataset. Before treating this
      as blocked, re-check the line and metadata counts: a long c7 regeneration was observed
      running and may have completed (Task 298)
- [ ] Flip complexity-9 generation from stratified to exhaustive by default (Task 282)
- [ ] Re-add the six derived binary temporal operators to the enumerator so they survive
      deduplication (Task 296)
- [ ] Build the regeneration automation so every dataset rebuild updates its downstream artifacts
      and documentation fields (Task 231)
- [ ] Calibrate baseline difficulty by running bmlogic-bench through at least three LLMs
      (Task 219)
- [ ] Expand `Examples/` with the publication-quality worked pipeline: soundness and completeness
      on a concrete formula, plus decidability of the propositional fragment, the fragment that is
      genuinely decidable today (Task 178)
- [ ] Add zstd-compressed `.jsonl` support across the pipeline (c7 is already 17G → 153M on disk
      as `.jsonl.zst`) (Task 604)
- [ ] Run the Hugging Face upload the prior round left unexecuted, then confirm
      `data/hf-dataset/PUBLISHING.md`'s Migration Status; blocked on the Phase 0 credential
      (Task 257)
- [ ] Final README, `docs/` and module-docstring polish (Task 177)

```bash
/orchestrate 298,282,296,231,219   # one dependency-ordered batch; 298 first, 219 last
/orchestrate 178,604               # disjoint scopes
/orchestrate 257                   # once the token exists; shares data/README.md with 282
/orchestrate 177                   # last in the programme
```

---

## Phase 5: Metalogic Questions and Literature (Medium Priority)

Three are runnable today. **Task 543 is not**: it depends on task 500, which is live in Phase 7
behind 497 and 502 — so 543 batches with the algebraic capstone, not here. Two of the three are
research-only by their own classification and land no library change.

- [ ] Acquire and ingest the Cmiel–Kuhlmann–Kuhlmann ball-space paper; the corpus has no copy.
      Kupferman–Vardi FOCS 2005 and Grädel–Thomas–Wilke LNCS 2500 are also still WANTED, both
      recorded as absent from every tier (Task 664)
- [ ] Run further verdict-first rounds on the nondeterministic canonical model for TM⋆
      completeness — reports and probes only, no changes to `FormalSystem/` (Task 559)
- [ ] Settle the C3 question: is the domain-restricted consequence relation's logic Burgess–Xu
      without unboundedness, plus S5? An open research question, not an implementation task
      (Task 570)
- [ ] Machine-check the principal MF frame-correspondence rigidity results researched in the
      PossibleWorlds paper repository; six external reports exist and must be read first. Declares
      `README.md`, so never the same cycle as 177 (Task 543)

```bash
/orchestrate 664,559,570 --lit   # 664 first so 543 and 559 have the corpus
# 543 runs with Phase 7's capstone batch, once 500 has landed
```

---

## Phase 6: The TM Tableau Spine (Low Priority)

The longest chain in the programme, three of whose links are open mathematics. Deprioritized
relative to Phases 1 and 2.

**Three facts bound the front.** Two must not be re-attempted: the unconditional
`buildTableau_isSome` is FALSE by construction at the engine's `maxBranches := 50000` guard, at any
fuel; and the whole decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch that mints a world — so
task 429 is a redesign, not a repair. The tombstone list is the C9 register in `MintBound.lean`. The
third bounds what the front may claim: ℤ-time validity of L is **already decided** by the
witness-family route (`Compression.decidableValidZTime`), so the deliverable here is the four-class
`isValid` biconditional, not the first decidability theorem.

**Two admission notes.** Task 428 is `[BLOCKED]` and task 481 is `[BLOCKED]` with no recorded
reason while its own description classifies it as a runnable repair-or-replace — lift the block or
force the dispatch. Tasks 410, 411 and 412 declare no `file_scope`; 410 is already `[PLANNED]`, so
it admits `--implement` directly.

- [ ] Design and land `gapPotential`, the density coordinate of the termination measure — the one
      genuinely open mathematical question on the totality terminus (Task 464)
- [ ] Complete the terminus restatement family at the repaired residuals: the fourteen
      restatements recorded as a reasoned exclusion (Task 465)
- [ ] Repair or replace the `UnorderedSuccessorLabelClosed` residual, refuted in-tree at a nonempty
      universe; a C9 register entry is a complete, valid outcome (Task 481)
- [ ] Prove engine totality at a quantified branch budget, via the amortized mint-bound route
      (Task 428)
- [ ] Redesign the truth-lemma side conditions — propagate `T(□φ)` to the freshly minted world,
      with its own `RuleSound` obligation (Task 429)
- [ ] Internalize tableau branches and prove the routine rule admissibilities (Task 410)
- [ ] Prove the hard admissibility lemmas for the Until/Since trichotomy and the
      discrete/Dedekind rules (Task 411)
- [ ] The semantic lift `valid_iff_allClosed`, and with it the `isValid φ fc = true ↔ ⊨ φ`
      biconditional and the four `Decidable (⊨ φ)` instances. Only the sound direction has landed
      (`isValid_sound`); no `isValid`-shaped `iff` is written until it can be proved, and the ZTime
      instance must agree with `Compression.decidableValidZTime` (Task 430)
- [ ] Prove the refutation core and decidability of provability with its completeness corollaries
      (Task 412)
- [ ] Discharge proof-extraction completeness, eliminating `.extractionFailed` on a genuinely
      closed tableau. `Verified/Refutation/` does not exist and no verifier declaration exists in
      `ProofExtraction.lean`, so this record must re-verify its own anchors first. OPEN
      MATHEMATICS, multi-month; must not be re-described as engineering (Task 482)

```bash
/orchestrate 464,465,481 --hard       # 464/465 share MintBound.lean and are dep-ordered
/orchestrate 428,429,410,411 --hard
/orchestrate 430,412,482 --hard --lit
```

---

## Phase 7: Algebraic Representation (Low Priority)

Five waves to the Jónsson–Tarski capstone, gated on the front's own literature verdict. **Every
task here declares an empty or absent `file_scope`** — scope them at plan time before running any
wave concurrently, or the gate cannot see the overlaps.

- [ ] Ground the front in Goldblatt and BRV **before** the STSA axiom set is fixed; this gates
      everything below it transitively (Task 502)
- [ ] Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap;
      the seed is 361 lines behind `#exit` in `Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
      (Task 497)
- [ ] Build the complex algebra `Cm(F)`: the powerset STSA over a `TaskFrame` (Task 498)
- [ ] Build the ultrafilter frame `Uf(A)` and prove it is a `TaskFrame`; HARD — the seed is 1189
      lines behind `#exit` with 4 sorry hits (Task 499)
- [ ] Reconcile the ShiftSet representation, landed for the compactness route, with the STSA route,
      so two parallel representation theorems are not developed and then reconciled (Task 500)
- [ ] Prove the Jónsson–Tarski representation theorem: `η(a) = {U | a ∈ U}` is an injective STSA
      homomorphism `A → Cm(Uf(A))` — the capstone (Task 125)
- [ ] Extend STSA with the binary Until and Since operators, which the live object language has as
      primitives (Task 501)

```bash
/orchestrate 502,497 --research --lit   # the literature gate; nothing below starts first
/orchestrate 498,499,500 --hard
/orchestrate 125,501,543 --hard         # 543 unblocks once 500 lands
```

---

## Not Scoped as Tasks

Two gaps have no task and no owner. **Strong completeness over ℚ-time**: weak completeness is done
(`derivable_of_validQTime`), but compactness goes through ultrapowers of ℚ, which are dense yet no
longer ℚ-time — Cantor gives an order isomorphism, not a group one. Unlike Discrete and Dedekind it
is not known to be impossible. **Genuine `Set Formula` strong completeness** for Base and Dense:
its gate, the shift-set representation theorem, has been passed, but the ultraproduct work behind it
is unfiled.

`app:gluing` is live and proved in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, its
seam case written as `ρ ⌢_z σ` but commented out; `app:Structure` and `app:presheaf-dictionary` are
**cut** from the paper. Treat a cut clause as a specification to implement, never as a theorem to
cite.

## Maintenance

**This file is hand-curated prose and is not mechanically parsed or annotated.** `/review`'s own
Roadmap Progress section says so explicitly and points here instead; the
`roadmap-integration.sh` that once annotated completed items exists only in the source store, is
not deployed, and has a `deprecated/` twin beside it. The `## Phase N:` headings and `- [ ]`
checkboxes still follow `.claude/context/formats/roadmap-format.md` so the structure stays
machine-readable if annotation is ever restored, but nothing updates them today: **completed items
must be removed by hand when a phase is revised.** The durable record of finished work is
`specs/CHANGE_LOG.md` and `specs/archive/`, and `/todo` surfaces completions when archiving.

Update the phases when `/task --expand`, `/spawn` or a dependency change alters the graph, and
treat any claim here that no check can reproduce as a defect in this file rather than a fact about
the tree. The decidability inventory (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is
regenerated and diffed from the tree by `scripts/generate-decidability-inventory.sh --diff`.

A task with no declared `file_scope` is invisible to the batch admission gate's overlap detection —
a known blindness, not an exemption. `validate-state.sh` reports the count.

## Related

- `.claude/context/formats/roadmap-format.md` — this file's parseable structure
- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
