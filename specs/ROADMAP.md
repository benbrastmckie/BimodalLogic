# Roadmap

*Open work only, hand-maintained (last edited 2026-10-18). This file is batch ordering and the
rulings that gate it — nothing else. The mathematics, the (C)/(S)/(W) verdict table and every
guardrail against a refuted shape live in `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
(the authority); per-task detail lives in `specs/TODO.md`; finished work in `specs/CHANGE_LOG.md`
and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate and run only
when Stage 1 is blocked on a user ruling or on open mathematics.

## Run these next

```bash
/orchestrate 819                # GATES 761: choose the ladder-cell presentation, or settle the direction negatively
/orchestrate 761 --hard --lit   # THE critical path, once 819 lands: the ladder realization theorem, over the two-arm relation `cohBi`
```

**SUFFICIENCY RETURNED (`815`).** The certificate is sufficient at the LABEL level over the
strict-since relation `cohBi` (`realizes_of_certAdm_cohBi`); the two-sided claim for `coh` is
REFUTED (`sufficiency_refuted`, the backward arm and only the backward arm). The rulings this
carries: Route B's relation is `cohBi`, by name; no backward propagation theorem is ever to be
claimed for `coh`; both arms stay EXISTENTIAL (`ULive`/`SLive` remain the wrong strength); and
realizability here is label-level, so the semantic step from a fulfilling label chain to
membership of a type in a cell (obligation (d)) is what remains of adequacy. The compiled detail,
the gate dispositions and the refuted index shapes are in Stage 1 below.

`761` declares five edges (`760`, `775`, `805`, `806`, `819`). Four are discharged and the
sufficiency verdict is in, so the mathematics is costable; **`819` is the one edge still open** and
gates the dispatch. `761` inherits the `cohBi` relation and the label-level limit.
Infrastructure repairs (`810` and the agent-system records `813`/`814`, whose edit targets resolve
only under the source store's own tree) are subordinate to all of it — they fix how the system
reports and gates, not what is proved, and none of them gates the critical path.

**Not on the critical path, and not a substitute for it**: acquiring *Handbook of Modal Logic*
ch. 11 (Hodkinson & Reynolds, "Temporal Logic", pp. 655–720, DOI 10.1016/S1570-2464(07)80014-0)
lifts `734`'s hold and closes its acceptance clause. Only §5.10 "Mosaics" and §5.11 "Monodic
fragments" are needed. Confirmed absent from the local Zotero library: it holds Handbook ch. 6
and ch. 10 as per-chapter offprints — ch. 10 ends at p. 653, the target starts at p. 655 — and no
volume-level PDF, so there is nothing to extract the chapter from. Institutional access or
purchase is the route. Because R2 consumes R1, this unblocks a record; it does not advance the
aim.

## Next batches

```bash
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 819                 # ladder-cell presentation decision — the one open edge on 761; run first
/orchestrate 761 --hard --lit    # ladder realization theorem over `cohBi`, realizability label-level (815) — needs 819
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — waits on 761 alone
/orchestrate 714,781 --hard      # sliced-certificate internals: full-label evaluation, Phase 5 hoist
# Stage 2 — supporting semantics and metalogic
/orchestrate 664,559,570 --lit   # corpus ingest first, then TM⋆ canonical-model rounds and the C3 open question
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 803,804             # the build-cost front: SubformulaProperty's elaboration time, then its fan-in
/orchestrate 298,282,296,231,219 # the dataset chain behind the c7 labeling bug
/orchestrate 178,604             # worked Examples/ pipeline and zstd-compressed .jsonl support
/orchestrate 743                 # doc gate: typst-sync Check 1 namespace resolution
/orchestrate 751,787             # file_scope backfill for the overlap gate; the unguarded .lake reader audit
/orchestrate 777,779,780,816     # commit-path and plan-compliance records; 816 (snapshot artifacts in phase commits) waits on 777
/orchestrate 772,783             # jq re-serialization of formatting-sensitive records, bounded in-file block edits
/orchestrate 753,774             # conclusion-stage null-resolution drops, refuted-REASON recording
/orchestrate 810                 # agent-system defect group: unfollowable batch-gate directive, vacuous-pass snapshot regex, refutation-inverting compliance check, literature --read path, gate16 — run in a separate cycle from 768 (shares lean-challenge-snapshot.sh)
/orchestrate 817,818             # wrap the remaining phantom-row inventory and directory-rollup tables
/orchestrate 729                 # purpose-written .title fields so TODO.md stops rendering descriptions
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 481 --hard          # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — 465 landed; needs 428's scope ruled
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

- **127 and 128** await Stage 0 rulings; **713** and **734** are both `HOLD` by ruling.
- **730, 741, 752, 767, 768, 769 and 770 are frozen: undispatchable from this repository**, and
  deliberately absent from every line above. Each names an edit target that resolves only under the
  agent-system source store (`~/.config/nvim/agent-system/**`; this repository's
  `.claude-extensions.json` declares no `source_dir` key, so the path is not derivable from it);
  this repo carries only the deployed `.claude/` tree, so a
  dispatch here can read nothing it is meant to edit and commit nothing it manages to write. Their
  migration into the source store's own task space is tracked there
  (`~/.config/nvim/specs/390_migrate_mis_sited_agent_system_tasks`, still `[NOT STARTED]`), not
  here — do not re-add them to a batch, and do not attempt the underlying work from this repo.
- The frozen set is **enumerated by that migration record, not derivable from `file_scope`**:
  753, 772, 774, 777, 779, 780 and 783 also edit the source store and are batched above by ruling,
  each editing at the mirroring source path and redeploying afterwards.
- **785, 813 and 814 have the frozen shape and are not among the seven** — each declares a
  `file_scope` that is wholly (785, 813) or almost wholly (814) under
  `agent-system/extensions/lean/**`, a path that does not exist in this repository, and all three
  share `index-entries.json`, so they collide with one another as well. They need the same
  disposition as the seven and have not been given one.
- **784** is the tracker for the freeze and is itself `[BLOCKED]` on the migration. It owns the only
  part this repository can do: once the records have landed in the source store, verify them there,
  delete them from `specs/state.json`, regenerate `specs/TODO.md`, and drop this section.
Every other open task appears in exactly one batch line above, except the two in **Run these
next**, which repeat for priority.

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one dependency edge (`465`) is discharged and its `blockers`
      says "paused at 4/5 cycles, NOT blocked", so the marker is mis-set and the next step is a
      scope decision: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Give **785**, **813** and **814** a disposition — frozen like the seven, or re-sited
- [ ] Rule on **807**'s positive verdict: `(q S ⊥) → ⊡(q S ⊥)` characterizes backward determinism
      over regular `ℤ`-frames (`backward-determinism-forcing-formula.lean`), so the
      know-time-do-not-forget family is a candidate reduction target. Options: (A, recommended)
      keep Stage 1 moving and scope the transfer question — whether relativizing finitely many
      `Yχ → ⊡Yχ` instances (χ over ψ's closure) reaches a non-r.e. row of Halpern–van der
      Meyden–Vardi 2004's Table 1 or the single-agent row that "simplifies" — as its own task with
      the HV89/HVV PDFs in hand; (B) halt Stage 1 until that is settled; (C) record the probe
      only, no follow-up

**713** is held by ruling (2026-10-03): its ARGUED CTL⋆ 2EXPTIME lower bound is a citable sanity
ceiling with no consumer. **734** (route R2, mosaics) is `[HOLD]` by ruling and is **not** a
fallback route — R2 is a *consumer* of R1, since deciding mosaics presupposes deciding `⊡`. Its
probe half is landed, wired and committed; only the paywalled Handbook §§5.10–5.11 remain, which
is why it is held rather than partial (two post-completion implement dispatches found nothing to
advance). Reactivation condition: `specs/literature-index.json#hodkinson_2006.hazard`. Because R2
consumes R1, **nothing on the critical path may be gated on it**: the spurious `734` edge that
once held adequacy back was audited and dropped, and that verdict is durable — `734`'s own report
records its landed `StabSaturated` predicate as identically true with `SH1` the only non-trivial
content, so the probe carries nothing adequacy consumes.

## Stage 1 — Decidability of L⁺

The route is the **gluing route** (R1): a possible world is a way of gluing a backward ray to a
forward ray at a seam, conceding infinite fibres and seeking a finite *presentation*. The aim is
OPEN by every route. **Stage 1 proceeds on R1 alone; there is no fallback.**

Of the three requirements in the README's verdict table, **(C) Hit-level completeness is a settled
theorem** (`exists_hitPresented`, every regular `ℤ`-model, `sizeBound φ k` a count); **(S)** landed
for `box`/`stab`-free `φ` at one seam; **(W)** landed its anchor layer, its run-layer frame scheme
and the admissible carrier (`ladderFrameAdm`, `ladderModel`). Three things remain open:

- **Adequacy — SUFFICIENCY RETURNED (`815`); the semantic step, obligation (d), is what remains.** The index
  sub-problem's history: `ladderRealized` cannot be STATED while no computable
  `LadderState Q pend → I` exists for `cellAt` to factor through. **Four tuple-shaped index shapes
  are refuted on compiled ground** — counter-pair clipping (`ladder-cell-refutation.lean`),
  clipped/gap-carrying (`ladder-cell-index-obstructions.lean`), the six-coordinate
  residue-carrying candidate at its object-exhibited parameters
  (`ladder-residue-index-refutation.lean`), and the same body at jointly derived parameters
  (`ladder-joint-index-refutation.lean`, whose gate 6 refutes via a formula carving out a
  sub-object no set of atoms carves out, by forbidding a *pattern* instead of a letter). **The
  tuple-widening line is spent; no seventh coordinate is to be proposed.**

  The set-valued successor presentation then survived two rounds. Eventual periodicity of the
  countdown over the **object-closure product** is discharged (`closure-indexed-periodicity.lean`,
  an instance of `iterate_eventually_periodic` on a finite carrier); gate 6 is *internalised*
  (`prof6_separates_gate6_pair` separates gate 6's own pair for every modulus coprime to three,
  with no parameter to choose); gate 5 is disarmed and exhibited; gate 7 passed in its
  definability form — all on the coprime-cycle fixture, in `closure-profile-gate-rerun.lean`
  (`Probe806`) and `nside-modulus-gate.lean` (`Probe806N`). The round after it landed the
  **certificate presentation** itself (`realizable-type-certificate.lean`, eighteen theorems
  sorry-free): the existential until-fixpoint as the dual of `AUFix`, the compiled
  universal-versus-existential separation on a cycle with an exit
  (`au_lfp_ne_eu_lfp_on_exit_graph`), `box`/`stab` as checked biconditionals, non-vacuity
  (`cert_accepts_Rchi`), and the separation from local coherence (`coh_accepts_Rev` +
  `cert_rejects_Rev`). The gap itself is compiled too
  (`realizable-type-adequacy-gap.lean`): a `coh6`-coherent 3-cycle carrying `ev = ⊤ U psi2` at
  every position and `psi2` at none.

  **Sufficiency returned** (`815`, `certificate-sufficiency-dovetailing.lean`, seventeen theorems
  sorry-free): the dovetailing argument is a theorem (`exists_dovetail_chain`); the two-sided
  claim for `coh` is refuted (`sufficiency_refuted`, backward arm only); the repair is the
  strict-since link `cohBi`, under which the certificate is sufficient at the label level
  (`realizes_of_certAdm_cohBi`), non-vacuously in both arms (`cert_accepts_R4`,
  `realizes_y0_R4`), at no cost on a `snce`-free closure; condition (3)'s bound is derived
  (`eu_mem_lfp_path_le_card`). Route B's relation is `cohBi`; both arms stay existential; what
  remains of adequacy is the semantic step (obligation (d)). The route is Route B (check a candidate realizable
  set), chosen over Route A (decide generalized-Büchi nonemptiness — a missing nested fixpoint,
  real work, not to be entered without a decision record). Still open alongside it: **gate 8 is
  SIDESTEPPED, not passed** (the `stab`/`box` clauses are present but unexercised; exercising
  them needs a fixture whose closure has `stab` members); gate 3 is **CARRIED**; gates 1 and 2
  are **NOT ADDRESSED** (compiled qualification — Branch N-VERIFIED: the refuted tuple's n-side
  coordinates pass gates 1 and 2 and are still blind to the shift the datum has to see); gate 9
  is **OPEN**. A gate probing one coordinate certifies one coordinate only. The set of cells stays
  finite (`anchorCells_ncard_le`); only the index/presentation is open. The declined alternative
  (R2: an index-free, `box`/`stab`-free run-layer half, `slive` retained) stays on record but is
  not pursued — it would not reach the `box`/`stab` letters Stage 1 needs.
- **761 — the ladder realization theorem** (`LadderCons`, `ladderRealized` per cell, for ALL `φ`
  including `box`/`stab` letters — where (S)'s limitation lands by the README's assignment).
  `[BLOCKED]`. **Four of its five declared edges are discharged** (760/775 archived, 805/806
  `[COMPLETED]`); **`819` — the ladder-cell presentation decision — is the one still open**, so a
  bare `/orchestrate 761` defers on it. Run `819` first, or batch the two and let the engine
  serialize them. The **sufficiency verdict** it waited on is in (`815`, above): the mathematics is
  costable, over the relation `cohBi`, with every realizability statement it inherits label-level.
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

**Two risks not covered there** — the first unrealized, the second now realized with its Stage 0 ruling pending:

| Failure mode | Evidence that locates it |
|---|---|
| No constructor for infinite-width, finitely branching regular frames | `Rbad`/`Rok` refuted as repair shapes (`b2b-frame-constructor-branching.lean`); the positive halves need TWO-SIDED finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) is neither refuted nor built. **Not yet filed** — unlike the row below this is not a one-fixture check; scoping a task needs a reading of `Limits/NoFiniteWidth.lean:132` and the `b2b-frame-constructor-branching.lean` refutation first |
| A closed L⁺ formula forces backward determinism on a regular `ℤ`-frame — the one route by which a published negative result could reach L⁺ | **REALIZED (closed check, positive verdict; 807)**: `(q S ⊥) → ⊡(q S ⊥)` is valid on a regular `ℤ`-frame iff the frame is backward deterministic (`backward-determinism-forcing-formula.lean`: `valid_iff_histBwdDet`, choice-free at `[propext, Quot.sound]`; `valid_iff_stepBwdDet` on regular frames; refuted on `Probe733Mirror`, valid on the forward-branching `Probe719Backward`, so it forces backward and not forward determinism). `ℤ`-specific: on dense time `q S ⊥` is unsatisfiable and the formula forces nothing, consistent with `deterministic_not_plusDefinable`. The know-time-do-not-forget family is therefore a candidate reduction target; the reduction is NOT attempted and no undecidability is claimed — Thomason's own T×W tradition is axiomatizable and Kamp-valid decidable (1984 §4), and every corpus negative found needs ≥ 2 informed agents while L⁺ has one. **Stage 0 ruling pending.** |

The corpus position — why no published negative result reaches TM/L⁺, and why that is not evidence
of decidability — is recorded in `specs/literature/README.md`.

## Stage 2 — Supporting semantics and metalogic

Every `app:presheaf-dictionary` clause scoped as a task is landed; what remains here is the
canonical-model and corpus work. Should a further presheaf module be filed, **the one collision the
gate cannot see** is the one-line import in `FormalSystem/Semantics/Presheaf.lean`, which no task
declares — batch only tasks already serialized by a dependency edge, and re-run `lake build` after
each aggregator edit. 664 runs before 559 and 570 so they have the corpus. **543 is not runnable here**; it depends
on 500 and batches with Stage 4's capstone.

## Stage 3 — Datasets, examples, documentation, hygiene

Independent of every other stage. Standing rule on any `C16` unused-binder red: prefer the
signature edit to a `scripts/nolints.json` entry, check the call sites first, and **do not run
`lake exe runLinter --update`**, which would grandfather the regression wholesale.

803 and 804 both touch `Verified/Termination/SubformulaProperty.lean`, so the pair serializes inside
one batch; that module is the repository's single largest rebuild cost (1103s measured on a full
guarded build) and any edit to the syntax or proof-system layer wakes it, so paper-alignment work
pays for it repeatedly — run the pair early. Re-check 298's line and metadata counts before
dispatching it. The `RaySummary`/`KTypeSummary` inventory tables are wrapped, so INV now catches a
drifted count; a task that hand-edits one still re-runs the generator rather than editing the
wrapped block. 257 shares `data/README.md` with 282.

## Stage 4 — The long fronts (low priority)

Two chains, both containing open mathematics: the TM tableau spine (428 → 429 → 410 → 411 → 430 →
412 → 482) and the algebraic representation front (502 → 497 → 498/499/500 → 125 → 501). **The
spine's head is now clear**: 464 and 465 are landed, so 428's one edge is discharged and the spine
starts at its Stage 0 scope ruling. **411 and 412 declare an empty or absent `file_scope`, as does every
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
