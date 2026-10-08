# Roadmap

*Open work only, derived from `specs/state.json` (2026-10-08). Finished work lives in
`specs/CHANGE_LOG.md` and `specs/archive/`. Per-task detail lives in the task records; the
mathematics — the BX axiom layers, the irreflexive truth semantics, the canonical-model and
quasimodel constructions — lives in `README.md`, the module docstrings and
`typst/BimodalReference.typ`. This file is ordering and rationale, and duplicates neither.*

**The programme's aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.**
Stage 1 is that front and preempts everything else for agent time. Stages 2–4 are subordinate and
may be run only when Stage 1 is blocked on a user ruling or on open mathematics.

Stage ← phase crosswalk, for task records citing the old phase numbers: **Stage 0** = Phase 0,
**Stage 1** = Phases 1–2, **Stage 2** = Phases 3 and 5, **Stage 3** = Phase 4, **Stage 4** =
Phases 6 and 7.

## Run order at a glance

```bash
# Stage 1 — decidability of L⁺; run to exhaustion before anything below
/orchestrate 739,740 --hard --lit
/orchestrate 745 --hard --lit
/orchestrate 746 --hard --lit
/orchestrate 733,734 --lit
/orchestrate 747 --hard --lit
/orchestrate 716,714 --hard
/orchestrate 712 --hard                 # only after Stage 0 corrects its marker
/orchestrate 725,720
# Stage 2 — supporting semantics and metalogic
/orchestrate 616,618
/orchestrate 617,566
/orchestrate 664,559,570 --lit
# Stage 3 — datasets, examples, documentation
/orchestrate 298,282,296,231,219
/orchestrate 178,604
/orchestrate 743,744
/orchestrate 257                        # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 464,465,481 --hard
/orchestrate 428,429,410,411 --hard
/orchestrate 430,412,482 --hard --lit
/orchestrate 502,497 --research --lit
/orchestrate 498,499,500 --hard
/orchestrate 125,501,543 --hard
/orchestrate 177                        # last in the programme
```

**How a batch behaves.** Each line is one `/orchestrate` invocation. Batches are
dependency-inclusive: the engine re-derives eligibility every cycle, so a batch holding both a
blocker and its dependent is correct — the blocker runs first and the dependent waves in behind it.
`MAX_TASKS` is 8, and the work-cycle budget is **per task, per invocation**, resetting each time: 5
by default and 13 under `--hard`. A long batch may still need re-invocation, so **re-run the same
line until it reports every member terminal**. A batch whose members share a declared file is not
broken, only serialized. A task with no declared `file_scope` is invisible to the overlap gate — a
known blindness, counted by `validate-state.sh`, and the reason Stage 1 carries dependency edges
rather than relying on per-cycle deferral.

---

## Stage 0 — User rulings and marker corrections

No agent may transition these, and three of them gate dispatches below.

- [ ] Rule on **127** and **128**, the object-language extensions (time addition, interior
      operator): long-standing abandonment candidates, antagonistic to the termination work Stage 4
      depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Correct **712**'s `[BLOCKED]` marker — it is the only task in the tree whose `[BLOCKED]`
      status carries no `blockers` entry. Its disposition is not unknown: close it as a refutation
      record, first verifying that the library theorem *is* 712's statement, since a weaker or
      differently shaped result would make "refuted" an overclaim. `[ABANDONED]` was rejected by
      ruling — the question was asked and definitively answered no, and a reader deserves that
      answer rather than silence
- [ ] Rule on **428**'s scope. Its `blockers` field records "paused at 4/5 cycles, NOT blocked", so
      the `[BLOCKED]` marker is mis-set and the recorded next step is a human scope decision, not
      another implement dispatch: `/revise 428` to add phases for its four residual hypotheses, or
      `/spawn 428` to split them out
- [ ] Re-rule on **709**'s value before dispatching it at all. It was R1's summary step (F4, finite
      width ⇒ eventually periodic) and R1 returned a negative verdict; any surviving statement must
      name its restricted fragment and say in its docstring why `not_finite_width_fmp` does not
      refute it

**713 is held by ruling (2026-10-03)** and is not schedulable: its ARGUED CTL⋆ 2EXPTIME lower bound
is a citable sanity ceiling with no consumer, and nothing may derive an upper bound from it.

---

## Stage 1 — Decidability of L⁺ (preempts everything)

Two sub-fronts: the **gluing route** — a possible world is a way of gluing a backward ray to a
forward ray at a seam — and the **sliced-certificate** class behind it. The aim is OPEN by every
route; gluing is ranked first and is the only route with an end-to-end owner.

**735's verdict (2026-10-08) sets the agenda.** The ray-product presentation as landed cannot
deliver the decision procedure, by the wired probe `Probe735.not_presented`; its deliverable is that
verdict plus a conditional per-seam check (`decidableStabOfPresented`, vacuous on model A). The
three requirements the verdict named are FILED as **745 (C)** Hit-level completeness with a
computable bound, **746 (S)** Hit-level soundness, and **747 (W)** a closure-wide quasimodel. Their
statement shapes under `[F.IsRegular]`, L⁺ and ℤ time are authored in the `RaySummary` README's "The
verdict" table, which is their authority, not this file.

**The order is cheapest-discriminator-first**, because two route-killing questions are each one
probe on a fixture that already exists, and either answer redirects thousands of lines.

- **`/orchestrate 739,740 --hard --lit`** — wave 1. **739** is the cheap discriminator: it asks
  whether the depth-2 stratification survives a three-state fixture with two states *sharing* the
  depth-1 stratum. It is what *licenses* the finite per-time alphabet the whole time-axis route
  rests on, so it is the most upstream question on the front, and the landed positive is weak by its
  own header's admission (a two-state fixture answers it trivially). **740** is housekeeping that
  must *precede* 745 and 746, because it rewrites three `KTypeSummary` signatures and the axiom-pin
  test that both of those add pins to. Scopes are disjoint, so the two batch cleanly.

- **`/orchestrate 745 --hard --lit`** — **(C)**, gated on 739 for the gate script and for the
  alphabet licensing. **Probe before bound**: phase 1 settles whether `HitPresented` holds on the
  existing model-A fixture, before any work on the computable bound the verdict costs at "not in
  sight". `Probe735.not_presented` refutes the *trace-level* hypothesis, but the Hit-level one is
  **OPEN, not refuted** — the pumped limit's forward type differs from every seam trace's type, so
  the refutation does not transfer. A refutation here is a complete outcome and moots (W).

- **`/orchestrate 746 --hard --lit`** — **(S)**, ungated and parallel-eligible with the above: the
  construction is the HWZ 2000 Thm 14 ⇐ formalization and keeps standalone value whatever (C)
  returns. `Probe735.not_presented` does **not** refute it, because that probe quantifies over
  arbitrary models while (S) builds the model from the presentation. Est. 1,200–2,000 lines plus a
  300–500 line regular-frame prerequisite, both CARRIED-UNVERIFIED — re-verify the frame-constructor
  figure first, and test backward finite branching cheapest, since `[Finite W]` funnels through one
  crude lemma.

- **`/orchestrate 733,734 --lit`** — evidence and fallback, serialized behind 739 on the gate
  script. **733** re-runs E1 on a backward-**nondeterministic** mirror fixture; the landed positive
  is on a backward-deterministic fixture whose backward factor is a singleton — the one region where
  the finite-width obstruction cannot appear — so a failure here falsifies the two-factor
  presentation. **734** is route R2 (mosaics), which cannot be promoted on textual grounds until
  both its E4 experiment and the missing Hodkinson–Reynolds Handbook §§5.10–5.11 bodies land.
  **Promote this line if 739 or 745 refutes**: R2 is the route to switch to.

- **`/orchestrate 747 --hard --lit`** — **(W)**, gated on 745 and 746, because (C) and (S) together
  still speak of one seam. The verdict costs it at nothing, which is information rather than an
  oversight, so its phase 1 is characterization.

- **`/orchestrate 716,714 --hard`** — the sliced-certificate sub-front. **716** is a defect in
  shipped, gated code, not an unbuilt feature: the `liveT`/`liveAt` fixpoint does not return in 300s
  on a 4-position total-edge certificate while being instant on self-loop ones. **714** evaluates
  carrying full labels, which would delete both liveness filters; the open question is whether
  decidability of the check survives. **Do not file a fourth certificate class** — no class
  presenting finite per-time fibres is complete whatever its clauses, and both halves of that
  obstruction are landed under `PlusSlicedCertificate/Limits/`.

- **`/orchestrate 712 --hard`** — the refutation-record closeout, dispatchable only after Stage 0
  corrects its marker; until then it is admitted and then stalls.

- **`/orchestrate 725,720`** — closeouts, last on this front. **725** is a close-as-subsumed ruling
  (719 landed E1 first, the subsumption condition 725's own record names). **720** re-points
  `FMP/README.md` and `scripts/check-evidence-probes.sh` from `WIRED_REPO` probe paths to the landed
  library names, or closes as subsumed if the landings leave no probe to move; it is gated behind
  734 on that script, and two archived paths in it were already repaired, so re-check what remains
  before planning. **709 is deliberately absent**; see Stage 0.

**Four constraints that rule work out.**

1. The substrate must work over the **time axis with a finite alphabet of per-time summaries, never
   over states** — forced by `not_finite_width_fmp`, which refutes pigeonhole-tier lasso summaries
   on the infinite acyclic fibre.
2. Gluing does **not** bound the fibre. The route concedes infinite fibres and seeks a finite
   *presentation*; any phase reintroducing a finite-fibre or finite-width assumption is reproducing
   a refuted shape.
3. **No upper bound is claimed anywhere.** The ARGUED CTL⋆ 2EXPTIME ceiling (713, held) rules
   proposals out and is never an upper-bound source.
4. **Zero debt**: no external Büchi/MSO lemma cited in place of a proof, and no cslib `require` —
   `~/Projects/cslib/` is a read-only reference, since a require edge would drag this tree 76
   Mathlib commits forward.

**Two limits on what a result may claim.** The `⊡(Pp)` backward side is fixed only by
`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture, with **no backward
Bool-fixture bridge**, so a forward-only result must say so rather than implying symmetry. And the
`⊡(Fp)`/`⊡(Pp)` shapes are **device-inert** on finite fixtures, so no record may claim they
discriminate between devices.

**Routes closed, not to be re-attempted.** **Filtration** (R4) for ℤ-time, by the landed
`PlusSlicedCertificate/Limits/` pair `no_finite_carrier_sat` and `not_finite_width_fmp` — cite those
library names, not the archived `Probe706.`/`Probe710.` spellings; the residue is dense durations
only. **Translation to a decidable FO fragment** (R5) is low value: the monodic decidability proof
*is* the quasimodel method, which routes straight back to R1/R2.

---

## Stage 2 — Supporting semantics and metalogic

Runnable today and subordinate. The behaviour-presheaf cluster is bounded rather than open — each
remaining item is a clause of `app:presheaf-dictionary` with a proved hook already in the tree, the
skeleton and four clauses having landed under `FormalSystem/Semantics/Presheaf/`. Two of the three
metalogic items are research-only by their own classification and land no library change.

- **`/orchestrate 616,618`** — the duration monoid `BD⁺` and its twisted-arrow category, then the
  path category `Path(F)` and `cor:path-fibration`. 618 depends on 616, so they never run
  concurrently and the aggregator below is safe.

- **`/orchestrate 617,566`** — the two remaining clauses, Reflection and Possible Worlds. Run only
  after adding `Presheaf.lean` to both scopes.

- **`/orchestrate 664,559,570 --lit`** — **664** first, so the others have the corpus: it ingests
  the Cmiel–Kuhlmann–Kuhlmann ball-space paper the corpus lacks (Kupferman–Vardi FOCS 2005 and
  Grädel–Thomas–Wilke LNCS 2500 are also WANTED and absent from every tier). **559** runs further
  verdict-first rounds on the nondeterministic canonical model for TM⋆ completeness — reports and
  probes only, no change to `FormalSystem/`. **570** is the C3 question, an open research question
  rather than an implementation task.

**Aggregator warning — the one collision the gate cannot see.** Every presheaf task needs a one-line
import in `FormalSystem/Semantics/Presheaf.lean`, which no task declares and which sits outside
every declared scope, so two concurrent writers conflict invisibly. The durable fix is to add that
path to each task's `file_scope`; until then, batch only tasks already serialized by a dependency
edge, and re-run `lake build` after each aggregator edit.

**543 is not runnable here** — it depends on 500, so it batches with Stage 4's algebraic capstone.

---

## Stage 3 — Datasets, examples and documentation

Independent of every other stage.

- **`/orchestrate 298,282,296,231,219`** — the dataset chain in one dependency-ordered batch: 298 is
  its root (282, 296 and 231 depend on it, 219 on 231), fixing the c7 labeling bug at formula
  ~13750 that causes unbounded memory growth in timeout handling. Re-check 298's line and metadata
  counts before treating it as blocked — a long c7 regeneration was observed running and may have
  completed.

- **`/orchestrate 178,604`** — disjoint scopes: the publication-quality worked `Examples/` pipeline
  (including decidability of the propositional fragment, the fragment genuinely decidable today),
  and zstd-compressed `.jsonl` support across the pipeline (c7 is already 17G → 153M as
  `.jsonl.zst`).

- **`/orchestrate 743,744`** — doc-gate hygiene; one script and two READMEs, so scopes are disjoint.
  **743**: `typst-sync-check.sh` Check 1 FAILS today on exactly one finding and the citation it
  rejects is CORRECT, because the check greps the dotted string literally and resolves no
  namespaces — so the fix is either namespace resolution or a ruling on the convention. **744**
  wraps the `RaySummary` and `KTypeSummary` inventory tables in `BEGIN GENERATED` markers; four of
  six line counts there had drifted while the gate stayed green, because the INV check fails only on
  a stale *wrapped* block. Run 744 before any task that hand-edits those tables.

- **`/orchestrate 257`** — once the Stage 0 token exists. Shares `data/README.md` with 282.

- **`/orchestrate 177`** — last in the programme: final README, `docs/` and module-docstring polish,
  carrying 26 dependencies including the whole tableau spine.

---

## Stage 4 — The long fronts (low priority)

Two chains, both deprioritized relative to Stage 1 and both containing open mathematics: the TM
tableau spine (464 → 465 → 428 → 429 → 410 → 411 → 430 → 412 → 482) and the algebraic
representation front (502 → 497 → 498/499/500 → 125 → 501). **Every algebraic task declares an
empty or absent `file_scope`, as do 410, 411 and 412** — scope them at plan time before running any
wave concurrently, or the gate cannot see the overlaps.

**Three facts bound the tableau front.** Two must not be re-attempted: the unconditional
`buildTableau_isSome` is FALSE by construction at the engine's `maxBranches := 50000` guard, at any
fuel; and the whole decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch that mints a world — so
429 is a redesign, not a repair. The tombstone list is the C9 register in `MintBound.lean`. The
third bounds what the front may claim: ℤ-time validity of L is **already decided** by the
witness-family route (`Compression.decidableValidZTime`), so the deliverable here is the four-class
`isValid` biconditional, not the first decidability theorem.

- **`/orchestrate 464,465,481 --hard`** — the termination measure. 464 lands `gapPotential`, the one
  genuinely open mathematical question on the totality terminus, and 465 is dependency-ordered
  behind it on `MintBound.lean`. **481 is blocked on a precise obstruction**, recorded in its
  `blockers`: `universeClosedAt_signedUniverse_of_propositional` is not stateable, because
  `UniverseClosedAt`'s clause 1 universally quantifies an unconstrained `ord` while every route
  through the time coordinate carries `OrdTimesKnown b ord`, proved non-removable in-source. A C9
  register entry is a complete outcome for it.

- **`/orchestrate 428,429,410,411 --hard`** — the spine's middle. The whole line sits behind 428 in
  the dependency graph, so it stalls until Stage 0 rules on 428's scope and a revised plan gives it
  phases to dispatch against. 410 is already `[PLANNED]` and admits `--implement` directly if it
  must move ahead of that ruling.

- **`/orchestrate 430,412,482 --hard --lit`** — the terminus. For **430**, only `isValid_sound` has
  landed: no `isValid`-shaped `iff` is written until it can be proved, and the ZTime instance must
  agree with `Compression.decidableValidZTime`. **482** is OPEN MATHEMATICS, multi-month, and must
  not be re-described as engineering; `Verified/Refutation/` does not exist and
  `ProofExtraction.lean` holds no verifier declaration, so it must re-verify its own anchors first.

- **`/orchestrate 502,497 --research --lit`** — the algebraic front's literature gate; nothing below
  it starts first, since 502 must fix the STSA axiom set against Goldblatt and BRV before anything
  is built on it. 497's seed is 361 lines behind `#exit` in
  `Boneyard/UltrafilterFrame/TenseS5Algebra.lean`.

- **`/orchestrate 498,499,500 --hard`** — the representation's two sides (`Cm(F)`, `Uf(A)`) and
  their reconciliation. 499 is HARD: its seed is 1189 lines behind `#exit` with 4 sorry hits. 500
  exists so that two parallel representation theorems are not developed and then reconciled.

- **`/orchestrate 125,501,543 --hard`** — the Jónsson–Tarski capstone, the Until/Since extension of
  STSA, and the MF frame-correspondence machine-check. 543 unblocks once 500 lands and declares
  `README.md`, so never the same cycle as 177.

---

## Not scoped as tasks

Two gaps have no task and no owner. **Strong completeness over ℚ-time**: weak completeness is done
(`derivable_of_validQTime`), but compactness goes through ultrapowers of ℚ, which are dense yet no
longer ℚ-time — Cantor gives an order isomorphism, not a group one. Unlike Discrete and Dedekind it
is not known to be impossible. **Genuine `Set Formula` strong completeness** for Base and Dense: its
gate, the shift-set representation theorem, has been passed, but the ultraproduct work behind it is
unfiled.

`app:gluing` is live and proved in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, its
seam case written as `ρ ⌢_z σ` but commented out; `app:Structure` and `app:presheaf-dictionary` are
**cut** from the paper. Treat a cut clause as a specification to implement, never as a theorem to
cite.

## Maintenance

**This file is hand-curated prose and is not mechanically parsed or annotated** — `/review`'s own
Roadmap Progress section says so and points here instead. So **completed items must be removed by
hand when a stage is revised**; the durable record of finished work is `specs/CHANGE_LOG.md` and
`specs/archive/`, and `/todo` surfaces completions when archiving. Update the stages when
`/task --expand`, `/spawn` or a dependency change alters the graph, and treat any claim here that no
check can reproduce as a defect in this file rather than a fact about the tree. The decidability
inventory (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree
by `scripts/generate-decidability-inventory.sh --diff`.

This edition is organized by **stage**, not by the `## Phase N:` headings and per-item checkboxes of
`.claude/context/formats/roadmap-format.md`; the crosswalk at the top maps the two, and Stage 0 is
the one remaining checkbox list. Agent-system and repo-hygiene records (729, 730, 731, 741) are
tracked in `specs/TODO.md` only and are deliberately unstaged here.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `.claude/context/formats/roadmap-format.md` — the legacy parseable structure, superseded above
- `specs/TODO.md` — task records, Task Order and dependency waves
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
