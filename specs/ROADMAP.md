# Roadmap

*Open work only, hand-maintained (last edited 2026-10-13). This file is batch ordering and the
rulings that gate it — nothing else. The mathematics, the (C)/(S)/(W) verdict table and every
guardrail against a refuted shape live in `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
(the authority); per-task detail lives in `specs/TODO.md`; finished work in `specs/CHANGE_LOG.md`
and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate and run only
when Stage 1 is blocked on a user ruling or on open mathematics.

## Next batches

```bash
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 778                 # record the P / P+1 modulus convention for the residue index
/orchestrate 761 --hard --lit    # ladder realization theorem — BLOCKED on the Stage 0 index ruling
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — waits on 761 alone
/orchestrate 714,781,782 --hard  # sliced-certificate internals: full-label evaluation, Phase 5 hoist, Shape D leaf cache
# Stage 2 — supporting semantics and metalogic
/orchestrate 616,618             # duration monoid BD⁺ and its twisted-arrow category, then Path(F) and cor:path-fibration
/orchestrate 617,566             # the Reflection and Possible Worlds clauses of app:presheaf-dictionary
/orchestrate 664,559,570 --lit   # corpus ingest first, then TM⋆ canonical-model rounds and the C3 open question
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 298,282,296,231,219 # the dataset chain behind the c7 labeling bug
/orchestrate 178,604             # worked Examples/ pipeline and zstd-compressed .jsonl support
/orchestrate 743,744             # doc gates: typst-sync Check 1 namespace resolution, GENERATED markers on inventory tables
/orchestrate 751                 # file_scope backfill so the overlap gate can see contended paths
/orchestrate 756                 # re-pin lem:nullity after the JPL paper strengthened it
/orchestrate 777,779,780         # commit-path and plan-compliance records from the 775 run
/orchestrate 772,783             # jq re-serialization of formatting-sensitive records, bounded in-file block edits
/orchestrate 753,774             # conclusion-stage null-resolution drops, refuted-REASON recording
/orchestrate 729                 # purpose-written .title fields so TODO.md stops rendering descriptions
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 464,465,481 --hard  # the termination measure: gapPotential, the terminus family, the refuted predicate
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — stalled behind 428's Stage 0 scope ruling
/orchestrate 430,412,482 --hard --lit    # the spine's terminus: semantic lift, Track B finish, proof extraction
/orchestrate 502,497 --research --lit    # the literature gate on the STSA axiom set, then the G-operator gap
/orchestrate 498,499,500 --hard  # the representation's two sides, Cm(F) and Uf(A), and their reconciliation
/orchestrate 125,501,543 --hard  # the Jónsson–Tarski capstone, Until/Since on STSA, the MF correspondence check
/orchestrate 177                 # last in the programme: README, docs/ and docstring polish
```

Each line is one invocation. Batches are dependency-inclusive — the engine re-derives eligibility
every cycle, so a batch holding both a blocker and its dependent is correct. `MAX_TASKS` is 8; the
work-cycle budget is per task, per invocation (5 default, 13 under `--hard`), so **re-run the same
line until every member reports terminal**. Shared file scope serializes a batch rather than
breaking it; a task with no declared `file_scope` is invisible to the overlap gate — the blindness
751 remediates. See `.claude/context/patterns/batch-orchestration-guardrails.md`.

**Not batched, and why.** 127, 128 and 709 await Stage 0 rulings; 713 is `HOLD` by ruling and 734
is `PARTIAL` by ruling.

**730, 741, 752, 767, 768, 769, 770 are undispatchable from this repository** and are deliberately
absent from every line above. Each names an edit target that resolves only under the agent-system
source store (`source_dir` in `.claude-extensions.json` → `~/.config/nvim/agent-system/**`); this
repo carries only the deployed `.claude/` tree, so a dispatch here can read nothing it is meant to
edit and commit nothing it manages to write. Their migration into the source store's own task space
is tracked there, not here — do not re-add them to a batch, and do not attempt the underlying work
from this repo. Note also that part of 768's third defect is already landed and committed in the
lean source store, so that record must be re-read before any implementation.

**784** is the tracker for that freeze and is itself `[BLOCKED]` on the migration. It owns the only
part this repository can do: once the seven have landed in the source store, verify them there,
delete them from `specs/state.json`, regenerate `specs/TODO.md`, and drop the paragraph above.

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] **761's cell-index ruling — the Stage 1 critical path.** A finite index of which cell a
      ladder state has needs a formula-derived clip AND threshold, and a modulus dominating every
      letter-definable sub-object period; the positive factorization lemma is stated nowhere, and
      three candidate indices are refuted (760 two-counter stabilization, 773 gap-carrying,
      775 residue-carrying). Choose: parameter-coupled index with jointly derived (T, P, B),
      set-valued per-state datum over a quotient, or the index-free run-layer half (R2) — then a
      successor task gated against all five refutation mechanisms before any proof attempt
- [ ] Rule on **428**'s scope. Its `blockers` says "paused at 4/5 cycles, NOT blocked", so the
      marker is mis-set and the next step is a scope decision: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Re-rule on **709**'s value before dispatching it. It was R1's F4 summary step (finite width ⇒
      eventually periodic) and R1 returned a negative verdict; any surviving statement must name its
      restricted fragment and say why `not_finite_width_fmp` does not refute it

**713** is held by ruling (2026-10-03): its ARGUED CTL⋆ 2EXPTIME lower bound is a citable sanity
ceiling with no consumer. **734** (route R2, mosaics) is `[PARTIAL]` by ruling and is **not** a
fallback route — R2 is a *consumer* of R1, since deciding mosaics presupposes deciding `⊡`.

## Stage 1 — Decidability of L⁺

The route is the **gluing route** (R1): a possible world is a way of gluing a backward ray to a
forward ray at a seam, conceding infinite fibres and seeking a finite *presentation*. The aim is
OPEN by every route. **Stage 1 proceeds on R1 alone; there is no fallback.**

Of 735's three requirements, **(C) Hit-level completeness is now a settled theorem**
(`exists_hitPresented`, every regular `ℤ`-model, `sizeBound φ k` a count); **(S)** landed for
`box`/`stab`-free `φ` at one seam; **(W)** landed its anchor layer, its run-layer frame scheme and
the admissible carrier (`ladderFrameAdm`, `ladderModel`). Three things remain open:

- **761 — the ladder realization theorem** (`LadderCons`, `ladderRealized` per cell, for ALL `φ`
  including `box`/`stab` letters — where (S)'s limitation lands by the README's assignment).
  `[BLOCKED]` on the Stage 0 cell-index ruling, not on any dependency; 760 and 775 are both landed.
  NOT costable until that ruling lands.
- **763 — the lift** (`not_plusValidZTime_iff_ladderRefutes`, `objBound φ` a count) and the
  `Decidable (PlusValidZTime φ)` corollary by bounded enumeration — the AIM. Its 762 edge is
  discharged; it waits on 761 alone. 761 and 763 share the `RaySummary` library set and serialize
  through the edge between them.
- **714 — sliced-certificate full-label evaluation**: does removing the `TailStable` junk-position
  obstruction preserve decidability of the check? 716's `liveAt` non-termination is fixed.
  **Do not file a fourth certificate class** — no class presenting finite per-time fibres is
  complete whatever its clauses (`PlusSlicedCertificate/Limits/`).

**Guardrails are not restated here.** Every constraint that rules a proposal out — closure-indexed
letters over the time axis, no finite-fibre or finite-width assumption, no upper bound of any kind,
zero external-lemma debt, the forward-only and device-inertness limits on claims, and the closed
routes (filtration R4 by `no_finite_carrier_sat`/`not_finite_width_fmp`; translation R5, which
routes back to R1) — is authored in the `RaySummary` README and `docs/theorem-index.md`. Read those
before proposing a shape.

**Two risks not covered there**, both unrealized and neither filed as a task:

| Failure mode | Evidence that locates it |
|---|---|
| No constructor for infinite-width, finitely branching regular frames | `Rbad`/`Rok` refuted as repair shapes (`b2b-frame-constructor-branching.lean`); the positive halves need TWO-SIDED finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) is neither refuted nor built |
| A closed L⁺ formula forces backward determinism on a regular `ℤ`-frame — the one route by which a published negative result could reach L⁺ | `stab`'s clause (`PlusTruth.lean:93`) fails the backward closure of the historical-necessity tradition (Thomason 1984 §4 Def. 6(2); Caleiro–Viganò–Volpe Def. 2.5 `Wdc`), which is why the corpus's negatives do not apply. If forcing is possible, the know-time-do-not-forget family becomes a reduction target. **Cheap check, named and not filed**: one fixture; `Probe719Backward` and `Probe733Mirror` already inhabit the backward factor |

The corpus position — why no published negative result reaches TM/L⁺, and why that is not evidence
of decidability — is recorded in `specs/literature/README.md`.

## Stage 2 — Supporting semantics and metalogic

Bounded rather than open: each remaining presheaf item is a clause of `app:presheaf-dictionary` with
a proved hook already in the tree. **The one collision the gate cannot see**: every presheaf task
needs a one-line import in `FormalSystem/Semantics/Presheaf.lean`, which no task declares — so batch
only tasks already serialized by a dependency edge, and re-run `lake build` after each aggregator
edit. 664 runs before 559 and 570 so they have the corpus. **543 is not runnable here**; it depends
on 500 and batches with Stage 4's capstone.

## Stage 3 — Datasets, examples, documentation, hygiene

Independent of every other stage. Re-check 298's line and metadata counts first — a long c7
regeneration was observed running and may have completed. Run 744 before any task that hand-edits
the `RaySummary`/`KTypeSummary` inventory tables (INV fails only on a stale *wrapped* block, so four
of six counts had drifted while the gate stayed green). 257 shares `data/README.md` with 282.

## Stage 4 — The long fronts (low priority)

Two chains, both containing open mathematics: the TM tableau spine (464 → 465 → 428 → 429 → 410 →
411 → 430 → 412 → 482) and the algebraic representation front (502 → 497 → 498/499/500 → 125 → 501).
**Every algebraic task declares an empty or absent `file_scope`, as do 410, 411 and 412** — scope
them at plan time before running any wave concurrently.

Three things must not be re-attempted: the unconditional `buildTableau_isSome` is FALSE by
construction at the engine's `maxBranches := 50000` guard, at any fuel; the whole decidable-branch-gate
family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk`)
collapses to `false` on any branch that mints a world, so 429 is a redesign, not a repair
(the C9 register is in `scripts/check-module-invariants.sh`; the gate tombstones themselves are in
`Tests/BimodalTest/Metalogic/Decidability/RegionGateProbe.lean` and its siblings — **not** in
`MintBound.lean`, which an earlier edition of this file cited and which carries none of them); and
ℤ-time validity of L is **already decided**
by the witness-family route (`Compression.decidableValidZTime`), so the deliverable is the
four-class `isValid` biconditional, not a first decidability theorem. 481's obstruction is precise:
`universeClosedAt_signedUniverse_of_propositional` is not stateable, because `UniverseClosedAt`'s
clause 1 universally quantifies an unconstrained `ord` while every route through the time coordinate
carries `OrdTimesKnown b ord`, proved non-removable in-source — a C9 register entry is a complete
outcome for it. 482 is open mathematics, multi-month, and must re-verify its own anchors first:
`Verified/Refutation/` does not exist and `ProofExtraction.lean` holds no verifier declaration.

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

Hand-curated: **completed items are removed by hand when a stage is revised**, and the durable
record is `specs/CHANGE_LOG.md` and `specs/archive/`. Update the batches when `/task --expand`,
`/spawn` or a dependency change alters the graph, and treat any claim here that no check can
reproduce as a defect in this file rather than a fact about the tree.

**Do not run `roadmap-integration.sh` against this file in either write mode.** `--regenerate` is
no longer the silent no-op an earlier note here claimed: it exits 0 and *does* write, but
half-applies to this authored layout — appending a `**Coverage appendix (uncovered tasks)**` fenced
block without assembling the `## Open work` / `## Next` sections or touching the authored Stage
prose — and emits its only diagnostic as an HTML-comment stderr marker rather than a named message,
so a caller cannot tell the outcomes apart. `--prune` separately mis-parses any Run line whose
flags follow the task list: the whitespace-stripping pass merges the flag into the last task id, so
a flagged multi-task line silently loses that task and a flagged single-task line vanishes whole.
Both defects are filed in the agent-system source store (the `--prune` parse bug as its own record;
the `--regenerate` half-application inside the mis-sited 752, which must migrate before it can be
worked). The decidability
inventory (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree
by `scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
