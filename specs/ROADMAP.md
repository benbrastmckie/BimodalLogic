# Roadmap

*Open work only; hand-maintained (last edited 2026-10-10), not generated — `roadmap-integration.sh
--regenerate` aborts silently against this layout and writes nothing. Finished work lives in
`specs/CHANGE_LOG.md` and `specs/archive/`. Per-task detail lives in the task records
(`specs/TODO.md`); the mathematics and the (C)/(S)/(W) verdict table live in `README.md`, the
module docstrings, `FormalSystem/Metalogic/Decidability/RaySummary/README.md` and
`typst/BimodalReference.typ`. This file is ordering and rationale, and duplicates neither.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate and run only
when Stage 1 is blocked on a user ruling or on open mathematics.

## Next batches

```bash
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 758,759 --hard      # the two Node-fixture probes: cell stabilization, then HitPresented for a ⊡-bearing formula
/orchestrate 720                 # CI repair: untracked WIRED_REPO + the missing tracked-ness check
/orchestrate 760,761 --hard --lit # ladder model + stabilization lemma over (c, n), then the ladder realization theorem
/orchestrate 762,763 --hard --lit # (C)'s general row, then the lift and the Decidable (PlusValidZTime φ) corollary
/orchestrate 716,714 --hard      # the sliced-certificate sub-front
/orchestrate 712 --hard          # only after Stage 0 corrects its marker
# Stage 2 — supporting semantics and metalogic
/orchestrate 616,618
/orchestrate 617,566
/orchestrate 664,559,570 --lit
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 298,282,296,231,219
/orchestrate 178,604
/orchestrate 743,744
/orchestrate 751,752
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 464,465,481 --hard
/orchestrate 428,429,410,411 --hard
/orchestrate 430,412,482 --hard --lit
/orchestrate 502,497 --research --lit
/orchestrate 498,499,500 --hard
/orchestrate 125,501,543 --hard
/orchestrate 177                 # last in the programme
```

Each line is one invocation. Batches are dependency-inclusive — the engine re-derives eligibility
every cycle, so a batch holding both a blocker and its dependent is correct. `MAX_TASKS` is 8; the
work-cycle budget is per task, per invocation (5 default, 13 under `--hard`), so **re-run the same
line until every member reports terminal**. Shared file scope serializes a batch rather than
breaking it; a task with no declared `file_scope` is invisible to the overlap gate — the blindness
751 remediates. See `.claude/context/patterns/batch-orchestration-guardrails.md`.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 127,128,709,729,730,741,753,756
/orchestrate 764,765,766,767,768,769,770,771
```

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Correct **712**'s `[BLOCKED]` marker — the only `[BLOCKED]` task with no `blockers` entry.
      Close it as a refutation record, first verifying the library theorem *is* 712's statement;
      `[ABANDONED]` was rejected by ruling, since the question was answered and a reader deserves
      the answer
- [ ] Rule on **428**'s scope. Its `blockers` says "paused at 4/5 cycles, NOT blocked", so the
      marker is mis-set and the next step is a scope decision: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Re-rule on **709**'s value before dispatching it. It was R1's F4 summary step (finite width ⇒
      eventually periodic) and R1 returned a negative verdict; any surviving statement must name its
      restricted fragment and say why `not_finite_width_fmp` does not refute it

**713 is held by ruling (2026-10-03)** and is not schedulable: its ARGUED CTL⋆ 2EXPTIME lower bound
is a citable sanity ceiling with no consumer. **734** (route R2, mosaics) is `[PARTIAL]` by ruling
and is **not** a fallback route — see Stage 1.

## Stage 1 — Decidability of L⁺

The route is the **gluing route** (R1): a possible world is a way of gluing a backward ray to a
forward ray at a seam, conceding infinite fibres and seeking a finite *presentation*. The aim is
OPEN by every route. **Stage 1 proceeds on R1 alone; there is no fallback.** R2 is a *consumer* of
R1, not an alternative — deciding mosaics presupposes deciding `⊡`, which is R1's reachability
summary, and its literal falsifier is unsatisfiable (`Probe718Mosaic.StabSaturated` is a tautology).

The three requirements named by 735's verdict are **(C)** Hit-level completeness with a computable
bound, **(S)** Hit-level soundness, **(W)** a closure-wide quasimodel. Their statement shapes, what
landed, and what did not are authored in the `RaySummary` README's "The verdict" table, which is
their authority. (S) landed for `box`/`stab`-free `φ` at one seam; (C) landed its probe half and, on model A, its
bound half as a count (`Probe745.hitPresented_modelA`, window `presentationSize k`); (W) landed its
anchor layer and its run-layer frame scheme (`ladderFrame`, `ladderFrame_isRegular`). What remains
open is below: the three obligations of the verdict table, filed as six records in dependency
order (design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`).

- **758 — `Node` fixture probe, cell stabilization** (`preCell_stable`, `preCell_zero_ne`,
  `postCell_stable` on `NoFiniteWidth.M` for `Φ`, fallback `D`): run-layer phase 2's FIRST statement
  tested where 750's mitigation R-A said to test it. Depth: none (cells). Costable: 400-800 lines,
  1-2 dispatches. No edges. Either verdict is the deliverable; a failure is recorded as the
  obstruction, never a finite-fibre retreat.

- **759 — `Node` fixture probe, `HitPresented` for a `⊡`-bearing formula at an infinite-width seam**
  (`hitPresented_node` or `not_hitPresented_node`, seam `(t, pre k)`, every `k ≥ 1`). **This is the
  highest-information probe on the frontier**: the only Hit-level positive is `box`/`stab`-free on a
  finite-width slice, and nothing tests either untested axis. **A Hit-level negative there is a
  Stage 0 ruling, not an agent transition** — it blocks R1 at (C) with no fallback, and 762/763
  then wait on the user. Depth `1 ≤ k`. Costable with a wide band. Serialization edge on 758.

- **760 — ladder model, `Adm`, and `ladderCell_stabilizes` over BOTH counters `(c, n)`** with the
  bound `B := |cl φ|` exhibited (fallback `∃ B`) — a count of closure formulas, never a complexity
  bound. Logical edge on 758 (the verdict fixes the bound shape); serialization edge on 759. NOT
  costable until 758 reports; `[BLOCKED]` is the honest outcome if stabilization fails.

- **761 — ladder realization theorem** (`LadderCons`, `ladderRealized` per ladder cell, for ALL `φ`
  including `box`/`stab` letters — where (S)'s `box`/`stab` limitation lands, by the README's own
  assignment; no standalone (S) record). Hit-level, on the infinite-width admissible-carrier frame
  `ladderFrameAdm` (`ladderFrame` has no instances) (WIDTH and COLLAPSE,
  `w-soundness-shape-refuted.lean`, forbid the trace level and `modelOf`'s frame). Logical edge on
  760. NOT costable (760 landed no bound — the stabilization lemma is refuted and the cell index is
  an open sub-problem; sized by how much of `Realize.lean` transfers).

- **762 — (C)'s general row** (`exists_hitPresented` with `sizeBound φ k` a count, every regular
  `ℤ`-model). Open mathematics, research-first. Logical edge on 759 (a negative there makes it
  false); serialization edge on 761. NOT costable; `[BLOCKED]` honest.

- **763 — the lift** (`not_plusValidZTime_iff_ladderRefutes`, `objBound φ` a count) and the
  `Decidable (PlusValidZTime φ)` corollary by bounded enumeration — the AIM, stated here and nowhere
  earlier. Depth `k = 1`. Logical edges on 761 and 762. NOT costable until both have shapes and the
  open cell-index sub-problem is resolved.

  The four library records (760-763) share `RaySummary.lean`, `FormalSystem.lean`, the C14 pins,
  `docs/theorem-index.md`, the `RaySummary` README and `typst/generated/status.typ`; they
  serialize through edges inside the set. Collisions OUTSIDE the set — 744 (README, invariants
  script), 734 (`check-evidence-probes.sh`, Stage 0), 410 (`status.typ`) — are the admission
  gate's to serialize, with no cross-set edge.

- **720 — CI repair**, ahead of the sliced pair because a red gate on every push outranks a local
  defect. Two of three `WIRED_REPO` entries in `scripts/check-evidence-probes.sh` point at files git
  does not track (an archival `mv` un-tracked them; the gate tests `[ ! -f ]` only, at `:717-720`),
  and `ci.yml:352-356` fails the job on a clean checkout. The deliverable is the **tracked-ness
  check** (`git ls-files --error-unmatch`, failing loudly), because the mechanism recurs on the next
  archival move.

- **716, 714 — the sliced-certificate sub-front.** **716** is a defect in shipped, gated code: the
  `liveT`/`liveAt` fixpoint does not return in 300 s on a 4-position total-edge certificate while
  being instant on self-loop ones. **714** evaluates carrying full labels, which would delete both
  liveness filters; the open question is whether decidability of the check survives. **Do not file a
  fourth certificate class** — no class presenting finite per-time fibres is complete whatever its
  clauses, both halves of that obstruction being landed under `PlusSlicedCertificate/Limits/`.

- **712 —** the refutation-record closeout; dispatchable only after Stage 0 corrects its marker,
  until then it is admitted and stalls.

### Guardrails — what is ruled out

1. The substrate works over the **time axis with a finite alphabet of per-time summaries, never
   over states** (forced by `not_finite_width_fmp`). **That alphabet is closure-indexed** — one
   label per `⊡`-subformula of the atomized target, backward labels included — because the depth-2
   value is machine-checked *not* a function of the depth-1 stratum. Any phase assuming a
   one-bit-per-depth summary reproduces a refuted shape. The tree already satisfies this:
   `clSig φ := subformulas φ ⊕ Unit` (`Closure.lean:80-81`).
2. Gluing does **not** bound the fibre; any phase reintroducing a finite-fibre or finite-width
   assumption reproduces a refuted shape.
3. **No upper bound is claimed anywhere.** The held 2EXPTIME ceiling rules proposals out and is
   never an upper-bound source.
4. **Zero debt**: no external Büchi/MSO lemma cited in place of a proof, and no cslib `require` —
   `~/Projects/cslib/` is read-only reference, since a require edge drags this tree 76 Mathlib
   commits forward.
5. **Two limits on claims.** The `⊡(Pp)` backward side is fixed only by
   `Probe719Backward.pastStab_iff_allBwdPathsMeet`, with no backward Bool-fixture bridge, so a
   forward-only result must say so rather than implying symmetry; and `⊡(Fp)`/`⊡(Pp)` are
   device-inert on finite fixtures, so no record may claim they discriminate between devices.

**Closed, not to be re-attempted.** **Filtration** (R4) for ℤ-time, by the landed
`PlusSlicedCertificate/Limits/` pair `no_finite_carrier_sat` and `not_finite_width_fmp` — cite those
library names; the residue is dense durations only. **Translation to a decidable FO fragment** (R5)
is low value: the monodic decidability proof *is* the quasimodel method, which routes back to R1.

### Named risks (none realized)

| Failure mode | Evidence that locates it |
|---|---|
| No constructor for infinite-width, finitely branching regular frames | `Rbad`/`Rok` refuted as repair shapes (`b2b-frame-constructor-branching.lean`); the positive halves need TWO-SIDED finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) is neither refuted nor built |
| The factorization-transport lemma does not close on model A | Not in the tree; never attempted |
| Hit-level completeness fails for some regular `ℤ`-model | One positive fixture, zero negatives, no general argument; trace level is false (`Probe735.not_presented`) and does not transfer. **759** tests it on both untested axes (`⊡`-bearing formula, infinite width); a negative there is a Stage 0 ruling |
| A closed L⁺ formula forces backward determinism on a regular `ℤ`-frame — the one route by which a published negative result could reach L⁺ | `stab`'s clause (`PlusTruth.lean:93`) fails the backward closure of the historical-necessity tradition (Thomason 1984 §4 Def. 6(2); Caleiro–Viganò–Volpe Def. 2.5 `Wdc`), which is why the corpus's negatives do not apply. If forcing is possible, the know-time-do-not-forget family becomes a reduction target. **Cheap check, named and not filed**: one fixture; `Probe719Backward` and `Probe733Mirror` already inhabit the backward factor |

**Literature position.** TM/L⁺ over regular `ℤ`-frames evades every published negative result in the
corpus for a boring reason: none has a hypothesis TM meets (each needs a second
linear/transitive/`K` factor commuting with time, three commuting factors, or a difference
operator — and `stab` is not a product coordinate). The published positives decide *sublogics* of
TM/L⁺, and decidability is not inherited by extensions. **So the literature settles L⁺ in neither
direction, and "evades" is not evidence of decidability.**

## Stage 2 — Supporting semantics and metalogic

Bounded rather than open: each remaining presheaf item is a clause of `app:presheaf-dictionary` with
a proved hook already in the tree, the skeleton and four clauses having landed under
`FormalSystem/Semantics/Presheaf/`.

- **616, 618** — the duration monoid `BD⁺` and its twisted-arrow category, then `Path(F)` and
  `cor:path-fibration`. 618 depends on 616, so they never run concurrently.
- **617, 566** — the Reflection and Possible Worlds clauses. Run only after adding `Presheaf.lean`
  to both scopes.
- **664, 559, 570 `--lit`** — 664 first, so the others have the corpus (it ingests the
  Cmiel–Kuhlmann–Kuhlmann ball-space paper; Kupferman–Vardi FOCS 2005 and Grädel–Thomas–Wilke
  LNCS 2500 are also wanted and absent). 559 runs further verdict-first rounds on the
  nondeterministic canonical model for TM⋆ completeness — reports and probes only. 570 is the C3
  open research question.

**The one collision the gate cannot see**: every presheaf task needs a one-line import in
`FormalSystem/Semantics/Presheaf.lean`, which no task declares. Batch only tasks already serialized
by a dependency edge, and re-run `lake build` after each aggregator edit. **543 is not runnable
here** — it depends on 500 and batches with Stage 4's capstone.

## Stage 3 — Datasets, examples, documentation, hygiene

Independent of every other stage.

- **298, 282, 296, 231, 219** — the dataset chain, dependency-ordered behind 298 (the c7 labeling
  bug at formula ~13750 causing unbounded memory growth in timeout handling). Re-check 298's line
  and metadata counts first: a long c7 regeneration was observed running and may have completed.
- **178, 604** — the publication-quality worked `Examples/` pipeline (including the propositional
  fragment, genuinely decidable today) and zstd-compressed `.jsonl` support (c7 is 17G → 153M).
- **743, 744** — doc-gate hygiene. **743**: `typst-sync-check.sh` Check 1 fails on one finding whose
  citation is CORRECT, because the check greps the dotted string and resolves no namespaces — so the
  fix is namespace resolution or a ruling on the convention. **744** wraps the `RaySummary` and
  `KTypeSummary` inventory tables in `BEGIN GENERATED` markers (four of six counts had drifted while
  the gate stayed green, since INV fails only on a stale *wrapped* block); run it before any task
  that hand-edits those tables.
- **751, 752** — `file_scope` backfill (26 missing-key tasks of 54 non-terminal, plus three coarse
  whole-directory declarations: 177, 720, 750 — read the live `validate-state.sh` output, not a
  carried snapshot) and the silent `roadmap-integration.sh --regenerate` abort.
- **257** — once the Stage 0 token exists. Shares `data/README.md` with 282.
- **177** — last in the programme: README, `docs/` and module-docstring polish, carrying 26
  dependencies including the whole tableau spine.

## Stage 4 — The long fronts (low priority)

Two chains, both containing open mathematics: the TM tableau spine (464 → 465 → 428 → 429 → 410 →
411 → 430 → 412 → 482) and the algebraic representation front (502 → 497 → 498/499/500 → 125 → 501).
**Every algebraic task declares an empty or absent `file_scope`, as do 410, 411 and 412** — scope
them at plan time before running any wave concurrently.

Two things must not be re-attempted: the unconditional `buildTableau_isSome` is FALSE by
construction at the engine's `maxBranches := 50000` guard, at any fuel; and the whole
decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`, `regionLabelCheck`,
`rayUpOk`/`rayDnOk`) collapses to `false` on any branch that mints a world — so 429 is a redesign,
not a repair (tombstones: the C9 register in `MintBound.lean`). And ℤ-time validity of L is
**already decided** by the witness-family route (`Compression.decidableValidZTime`), so the
deliverable here is the four-class `isValid` biconditional, not a first decidability theorem.

- **464, 465, 481 `--hard`** — the termination measure. 464 lands `gapPotential`, the one genuinely
  open question on the totality terminus; 465 is dependency-ordered behind it on `MintBound.lean`.
  **481 is blocked on a precise obstruction**: `universeClosedAt_signedUniverse_of_propositional` is
  not stateable, because `UniverseClosedAt`'s clause 1 universally quantifies an unconstrained `ord`
  while every route through the time coordinate carries `OrdTimesKnown b ord`, proved non-removable
  in-source. A C9 register entry is a complete outcome for it.
- **428, 429, 410, 411 `--hard`** — the spine's middle, stalled behind 428 until Stage 0 rules on
  its scope. 410 is `[PLANNED]` and admits `--implement` directly if it must move ahead of that
  ruling.
- **430, 412, 482 `--hard --lit`** — the terminus. For **430**, only `isValid_sound` has landed: no
  `isValid`-shaped `iff` until it can be proved, and the ZTime instance must agree with
  `Compression.decidableValidZTime`. **482** is open mathematics, multi-month, and must not be
  re-described as engineering — `Verified/Refutation/` does not exist and `ProofExtraction.lean`
  holds no verifier declaration, so it must re-verify its own anchors first.
- **502, 497 `--research --lit`** — the literature gate; 502 must fix the STSA axiom set against
  Goldblatt and BRV before anything is built on it. 497's seed is 361 lines behind `#exit` in
  `Boneyard/UltrafilterFrame/TenseS5Algebra.lean`.
- **498, 499, 500 `--hard`** — the representation's two sides (`Cm(F)`, `Uf(A)`) and their
  reconciliation. 499 is hard: its seed is 1189 lines behind `#exit` with 4 sorry hits. 500 exists
  so two parallel representation theorems are not developed and then reconciled.
- **125, 501, 543 `--hard`** — the Jónsson–Tarski capstone, the Until/Since extension of STSA, and
  the MF frame-correspondence machine-check. 543 unblocks once 500 lands and declares `README.md`,
  so never the same cycle as 177.

## Not scoped as tasks

**Strong completeness over ℚ-time**: weak completeness is done (`derivable_of_validQTime`), but
compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time — Cantor gives an
order isomorphism, not a group one. Unlike Discrete and Dedekind it is not known to be impossible.
**Genuine `Set Formula` strong completeness** for Base and Dense: its gate, the shift-set
representation theorem, has been passed, but the ultraproduct work behind it is unfiled.

`app:gluing` is live and proved in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, its
seam case written as `ρ ⌢_z σ` but commented out; `app:Structure` and `app:presheaf-dictionary` are
**cut** from the paper. Treat a cut clause as a specification to implement, never as a theorem to
cite.

## Maintenance

Hand-curated prose, not mechanically parsed or annotated (`/review`'s Roadmap Progress section
points here instead), so **completed items are removed by hand when a stage is revised**; the
durable record is `specs/CHANGE_LOG.md` and `specs/archive/`. Update the stages when
`/task --expand`, `/spawn` or a dependency change alters the graph, and treat any claim here that no
check can reproduce as a defect in this file rather than a fact about the tree. The decidability
inventory (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree
by `scripts/generate-decidability-inventory.sh --diff`. Agent-system records (729, 730, 731, 741)
are tracked in `specs/TODO.md` only and are deliberately unstaged here.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `.claude/context/formats/roadmap-format.md` — the legacy parseable structure, superseded above
- `specs/TODO.md` — task records, Task Order and dependency waves
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
