# Roadmap

*Open work only, hand-maintained (last edited 2026-10-16). This file is batch ordering and the
rulings that gate it — nothing else. The mathematics, the (C)/(S)/(W) verdict table and every
guardrail against a refuted shape live in `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
(the authority); per-task detail lives in `specs/TODO.md`; finished work in `specs/CHANGE_LOG.md`
and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate and run only
when Stage 1 is blocked on a user ruling or on open mathematics.

## Run these next

```bash
/orchestrate 808                  # CI IS RED: the C16 env_linter failure; cheap, blocks nothing, fix first
/orchestrate 809 --research --lit # THE critical path: adequacy of the realizable-type relation
```

`808` is a one-binder signature edit; `809` is the single record on the critical path. Everything
else below is subordinate to `809`.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 127,128,178,502,559,566,570,604
/orchestrate 616,617,664,709,714,729,730,741
/orchestrate 743,744,751,752,753,767,768,769
/orchestrate 770,772,774,777,779,780,781,782
/orchestrate 785,787,803,804,810,811
```

## Next batches

```bash
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 809 --research --lit # adequacy: a relation computing REALIZABLE, not locally coherent, types
/orchestrate 761 --hard --lit    # ladder realization theorem — BLOCKED; see the 805 note in Stage 1
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — waits on 761 alone
/orchestrate 714,781,782 --hard  # sliced-certificate internals: full-label evaluation, Phase 5 hoist, Shape D leaf cache
/orchestrate 807 --research --lit # cheap check: can a closed L⁺ formula force backward determinism on a regular ℤ-frame?
# Stage 2 — supporting semantics and metalogic
/orchestrate 616,618             # duration monoid BD⁺ and its twisted-arrow category, then Path(F) and cor:path-fibration
/orchestrate 617,566             # the Reflection and Possible Worlds clauses of app:presheaf-dictionary
/orchestrate 664,559,570 --lit   # corpus ingest first, then TM⋆ canonical-model rounds and the C3 open question
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 803,804             # the build-cost front: SubformulaProperty's elaboration time, then its fan-in
/orchestrate 298,282,296,231,219 # the dataset chain behind the c7 labeling bug
/orchestrate 178,604             # worked Examples/ pipeline and zstd-compressed .jsonl support
/orchestrate 743,744             # doc gates: typst-sync Check 1 namespace resolution, GENERATED markers on inventory tables
/orchestrate 751,787             # file_scope backfill for the overlap gate; the unguarded .lake reader audit
/orchestrate 777,779,780         # commit-path and plan-compliance records from the ladder-index run
/orchestrate 772,783             # jq re-serialization of formatting-sensitive records, bounded in-file block edits
/orchestrate 753,774             # conclusion-stage null-resolution drops, refuted-REASON recording
/orchestrate 729                 # purpose-written .title fields so TODO.md stops rendering descriptions
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 464,465 --hard      # the termination measure: gapPotential, then the terminus family — RUN BEFORE the spine
/orchestrate 481 --hard          # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — needs 465 landed and 428's scope ruled
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

## Not batched, and why

- **127, 128 and 709** await Stage 0 rulings; **713** is `HOLD` by ruling and **734** is `PARTIAL`
  by ruling.
- **730, 741, 752, 767, 768, 769 and 770 are frozen: undispatchable from this repository**, and
  deliberately absent from every line above. Each names an edit target that resolves only under the
  agent-system source store (`source_dir` in `.claude-extensions.json` →
  `~/.config/nvim/agent-system/**`); this repo carries only the deployed `.claude/` tree, so a
  dispatch here can read nothing it is meant to edit and commit nothing it manages to write. Their
  migration into the source store's own task space is tracked there
  (`~/.config/nvim/specs/390_migrate_mis_sited_agent_system_tasks`, still `[NOT STARTED]`), not
  here — do not re-add them to a batch, and do not attempt the underlying work from this repo.
- The frozen set is **enumerated by that migration record, not derivable from `file_scope`**:
  753, 772, 774, 777, 779, 780 and 783 also edit the source store and are batched above by ruling,
  each editing at the mirroring source path and redeploying afterwards.
- **785 has the frozen shape and is not among the seven** — its entire `file_scope` is
  `agent-system/extensions/lean/**`, a path that does not exist in this repository. It needs the
  same disposition as the seven and has not been given one.
- **784** is the tracker for the freeze and is itself `[BLOCKED]` on the migration. It owns the only
  part this repository can do: once the records have landed in the source store, verify them there,
  delete them from `specs/state.json`, regenerate `specs/TODO.md`, and drop this section.
- **805** is substantively spent — its refutation is the record 806 was filed against — but it sits
  at `[RESEARCHED]`, so it is still a live dependency edge on 761. See the 761 bullet in Stage 1.

Every other open task appears in exactly one batch line above, except the two in **Run these
next**, which repeat for priority.

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its `blockers` says "paused at 4/5 cycles, NOT blocked", so the
      marker is mis-set and the next step is a scope decision: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Re-rule on **709**'s value before dispatching it. It was the finite-width ⇒ eventually
      periodic summary step of the run-layer programme, which returned a negative verdict; any
      surviving statement must name its restricted fragment and say why `not_finite_width_fmp` does
      not refute it
- [ ] Close **805** or rule it open. It blocks 761 by a dependency edge while carrying no remaining
      work; its gate 6 is the finding 806 was built on
- [ ] Give **785** a disposition — frozen like the seven, or re-sited

**713** is held by ruling (2026-10-03): its ARGUED CTL⋆ 2EXPTIME lower bound is a citable sanity
ceiling with no consumer. **734** (route R2, mosaics) is `[PARTIAL]` by ruling and is **not** a
fallback route — R2 is a *consumer* of R1, since deciding mosaics presupposes deciding `⊡`.

## Stage 1 — Decidability of L⁺

The route is the **gluing route** (R1): a possible world is a way of gluing a backward ray to a
forward ray at a seam, conceding infinite fibres and seeking a finite *presentation*. The aim is
OPEN by every route. **Stage 1 proceeds on R1 alone; there is no fallback.**

Of the three requirements in the README's verdict table, **(C) Hit-level completeness is a settled
theorem** (`exists_hitPresented`, every regular `ℤ`-model, `sizeBound φ k` a count); **(S)** landed
for `box`/`stab`-free `φ` at one seam; **(W)** landed its anchor layer, its run-layer frame scheme
and the admissible carrier (`ladderFrameAdm`, `ladderModel`). Three things remain open:

- **809 — adequacy of the realizable-type relation.** `ladderRealized` cannot be STATED: its
  `[Fintype Q]` obligation ran through `truncate B`, which is defined nowhere in `FormalSystem/`.
  What is missing is a computable `LadderState Q pend → I` through which `cellAt` factors. **Four
  tuple-shaped index shapes are refuted on compiled ground** — counter-pair clipping
  (`ladder-cell-refutation.lean`), clipped/gap-carrying (`ladder-cell-index-obstructions.lean`),
  the six-coordinate residue-carrying candidate at its object-exhibited parameters
  (`ladder-residue-index-refutation.lean`), and the same body at jointly derived parameters
  (`ladder-joint-index-refutation.lean`, whose gate 6 refutes via a formula carving out a
  sub-object no set of atoms carves out, by forbidding a *pattern* instead of a letter). **The
  tuple-widening line is spent; no seventh coordinate is to be proposed.** The successor
  presentation — a set-valued per-state datum over a quotient — then **survived its first round**
  (the nineteenth wired probe; `WIRED` now 36): eventual periodicity of the countdown over the
  **object-closure product** is discharged (`closure-indexed-periodicity.lean`, an instance of
  `iterate_eventually_periodic` on a finite carrier), gate 6 is *internalised*
  (`prof6_separates_gate6_pair` separates gate 6's own pair for every modulus coprime to three,
  with no parameter to choose), gate 5 is disarmed and exhibited, and gate 7 passed in its
  definability form — all on the coprime-cycle fixture, in `closure-profile-gate-rerun.lean`
  (`Probe806`) and `nside-modulus-gate.lean` (`Probe806N`). **What that round did NOT settle, and
  809 owns:** adequacy — a coherence relation computing *realizable* rather than merely locally
  coherent types, with untl/snce fulfilment. The round carries only the LOCAL relation `coh6` on
  one fixture. Adequacy is **the gate on everything after it**. Also open, and 809's scope: the two
  gates specific to a set-valued presentation that the tuple-shaped table has no rows for
  (non-circularity, stab self-reference); gate 8 is **SIDESTEPPED, not passed**; gate 3 is
  **CARRIED**; gates 1 and 2 are **NOT ADDRESSED** (with a compiled qualification — Branch
  N-VERIFIED: the refuted tuple's n-side coordinates pass gates 1 and 2 and are still blind to the
  shift the datum has to see); gate 9 is **OPEN**. A gate probing one coordinate certifies one
  coordinate only. The set of cells stays finite (`anchorCells_ncard_le`); only the
  index/presentation is open. The declined alternative (R2: an index-free, `box`/`stab`-free
  run-layer half, `slive` retained) stays on record but is not pursued — it would not reach the
  `box`/`stab` letters Stage 1 needs.
- **761 — the ladder realization theorem** (`LadderCons`, `ladderRealized` per cell, for ALL `φ`
  including `box`/`stab` letters — where (S)'s limitation lands by the README's assignment).
  `[BLOCKED]`. Its dependency edges on 760, 775 and 806 are discharged; **805 is the one edge still
  open on the graph**, though it carries no remaining work (Stage 0). Substantively 761 waits on
  **809's adequacy verdict**, which no edge yet records — add `--depends-on-add 809` if you want the
  graph to say so. NOT costable until adequacy returns.
- **763 — the lift** (`not_plusValidZTime_iff_ladderRefutes`, `objBound φ` a count) and the
  `Decidable (PlusValidZTime φ)` corollary by bounded enumeration — the AIM. It waits on 761 alone.
  761 and 763 share the `RaySummary` library set and serialize through the edge between them.
- **714 — sliced-certificate full-label evaluation**: does removing the `TailStable` junk-position
  obstruction preserve decidability of the check? The `liveAt` non-termination that blocked it is
  fixed. **Do not file a fourth certificate class** — no class presenting finite per-time fibres is
  complete whatever its clauses (`PlusSlicedCertificate/Limits/`).

**Guardrails are not restated here.** Every constraint that rules a proposal out — closure-indexed
letters over the time axis, no finite-fibre or finite-width assumption, no upper bound of any kind,
zero external-lemma debt, the forward-only and device-inertness limits on claims, and the closed
routes (filtration R4 by `no_finite_carrier_sat`/`not_finite_width_fmp`; translation R5, which
routes back to R1) — is authored in the `RaySummary` README and `docs/theorem-index.md`. Read those
before proposing a shape.

A refutation is a successful outcome, and is **not** to be followed by a weakened, same-named
substitute for `ladderRealized` or `LadderCons`; do not state a `LadderCons` without the box/stab
clause (`stab_mem_tpOf_iff` is per cell).

**Two risks not covered there**, both unrealized:

| Failure mode | Evidence that locates it |
|---|---|
| No constructor for infinite-width, finitely branching regular frames | `Rbad`/`Rok` refuted as repair shapes (`b2b-frame-constructor-branching.lean`); the positive halves need TWO-SIDED finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) is neither refuted nor built. **Not yet filed** — unlike the row below this is not a one-fixture check; scoping a task needs a reading of `Limits/NoFiniteWidth.lean:132` and the `b2b-frame-constructor-branching.lean` refutation first |
| A closed L⁺ formula forces backward determinism on a regular `ℤ`-frame — the one route by which a published negative result could reach L⁺ | `stab`'s clause (`PlusLanguage/PlusTruth.lean:93`) fails the backward closure of the historical-necessity tradition (Thomason 1984 §4 Def. 6(2); Caleiro–Viganò–Volpe Def. 2.5 `Wdc`), which is why the corpus's negatives do not apply. If forcing is possible, the know-time-do-not-forget family becomes a reduction target. **Filed as 807**: one fixture; `Probe719Backward` and `Probe733Mirror` already inhabit the backward factor |

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

Independent of every other stage. **808 is red right now** — `check-module-invariants.sh` exits 1 on
`FAIL C16`, an unused `[Finite F.WorldState]` on `mem_HF_iff_no_forbidden`
(`FormalSystem/Semantics/ShiftFiniteType.lean:149`), inherited from a commit under another task and
beyond `scripts/nolints.json`'s baseline. Prefer the signature edit to a nolints entry, check the
call sites first, and **do not run `lake exe runLinter --update`**, which would grandfather the
regression wholesale.

803 and 804 both touch `Verified/Termination/SubformulaProperty.lean`, so the pair serializes inside
one batch; that module is the repository's single largest rebuild cost (1103s measured on a full
guarded build) and any edit to the syntax or proof-system layer wakes it, so paper-alignment work
pays for it repeatedly — run the pair early. Re-check 298's line and metadata counts first: a long
c7 regeneration was observed running and may have completed. Run 744 before any task that
hand-edits the `RaySummary`/`KTypeSummary` inventory tables (INV fails only on a stale *wrapped*
block, so four of six counts had drifted while the gate stayed green). 257 shares `data/README.md`
with 282.

## Stage 4 — The long fronts (low priority)

Two chains, both containing open mathematics: the TM tableau spine (464 → 465 → 428 → 429 → 410 →
411 → 430 → 412 → 482) and the algebraic representation front (502 → 497 → 498/499/500 → 125 → 501).
**The spine cannot start at 428**: 428 is `[BLOCKED]` on 465, which waits on 464, so run `464,465`
before the spine's middle line. **411 and 412 declare an empty or absent `file_scope`, as does every
algebraic task** — scope them at plan time before running any wave concurrently. (410 now declares
one; it overlaps `typst/generated/status.typ` with other work.)

Three things must not be re-attempted: the unconditional `buildTableau_isSome` is FALSE by
construction at the engine's `maxBranches := 50000` guard, at any fuel; the whole decidable-branch-gate
family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk`)
collapses to `false` on any branch that mints a world, so 429 is a redesign, not a repair (the C9
register is in `scripts/check-module-invariants.sh`; the gate tombstones are in
`Tests/BimodalTest/Metalogic/Decidability/RegionGateProbe.lean` and its siblings, **not** in
`MintBound.lean`, which carries none of them); and ℤ-time validity of L is **already decided** by
the witness-family route (`Compression.decidableValidZTime`), so the deliverable is the four-class
`isValid` biconditional, not a first decidability theorem. 481's obstruction is precise:
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

`app:gluing` is live in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and proved in
the library in full generality (`FormalSystem/Semantics/Gluing.lean`). `app:Structure` and
`app:presheaf-dictionary` are **cut** from the paper. Treat a cut clause as a specification to
implement, never as a theorem to cite.

## Maintenance

Hand-curated: **completed items are removed by hand when a stage is revised**, and the durable
record is `specs/CHANGE_LOG.md` and `specs/archive/`. Update the batches when `/task --expand`,
`/spawn` or a dependency change alters the graph, and treat any claim here that no check can
reproduce as a defect in this file rather than a fact about the tree.

**Do not run `roadmap-integration.sh` against this file in either write mode.** `--regenerate`
exits 0 and does write, but half-applies to this authored layout: it appends a
`**Coverage appendix (uncovered tasks)**` fenced block without assembling the `## Open work` /
`## Next` sections or touching the authored Stage prose, and emits its only diagnostic as an
HTML-comment stderr marker rather than a named message, so a caller cannot tell the outcomes apart.
`--prune` separately mis-parses any Run line whose flags follow the task list: the
whitespace-stripping pass merges the flag into the last task id, so a flagged multi-task line
silently loses that task and a flagged single-task line vanishes whole. Both defects are filed in
the agent-system source store (752), which is **frozen and undispatchable from here**.

**The conflict this leaves standing**: `/orchestrate`'s own conclusion stage runs
`roadmap-integration.sh --regenerate` as a mandated step
(`.claude/context/contracts/conclusion-stage.md`, Step 5), so every `/orchestrate` invocation
re-injects the coverage-appendix block into this file against the ruling above. Until 752 is
unfrozen, **delete the appended block by hand after an orchestrate run** — that is the only remedy
available from this repository. The decidability inventory
(PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree by
`scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
