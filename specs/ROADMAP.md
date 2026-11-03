# Roadmap

*Open work only, hand-maintained (last edited 2026-11-03). This file is batch ordering and the
rulings that gate it — nothing else. The mathematics, the (C)/(S)/(W) verdict table and every
guardrail against a refuted shape live in `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
(the authority); per-task detail lives in `specs/TODO.md`; finished work in `specs/CHANGE_LOG.md`
and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate and run only
when Stage 1 is blocked on a user ruling or on open mathematics.

**ORDERING RULING (2026-11-02, user): decidability before completeness, and the two are not
symmetric.** Deciding validity makes the valid set r.e., and an r.e. valid set means a recursive
axiomatization exists (Craig) — so landing Stage 1 *settles* `559`'s priority question `(P1)`, the
gate on the whole completeness programme by that task's own USER DECISION. Completeness going the
other way yields only r.e.-ness, never decidability: that would additionally need non-validity
r.e., which is what `not_finite_width_fmp` makes hard here. Stage 1 is also the better-resourced
front — (C) is a settled theorem, (S) and (W)'s anchor layer are landed, all six of `761`'s edges
are discharged — whereas the completeness engine's only blueprint is a published *sketch*. The
caveat, stated so it is not oversold: Craig's trick buys *an* axiomatization, not a natural one, so
finding a natural system stays real work; what Stage 1 removes is the risk that the search is for
something nonexistent. **The pivot, if `761` blocks on open mathematics rather than on a ruling**,
is `559`'s `(P1)` at Base — not its engine: `(P1)` is independent of ZTime, has a located
obstruction, and either verdict pays (positive opens Base, negative unlocks the bundled fallback
that `559`'s USER DECISION otherwise forbids).

**THE PIVOT HAS FIRED (2026-11-02), and the ruling stays in force.** `761` is blocked on open
mathematics, not on a ruling: Phase 11.5 closed `[BLOCKED]` on its own plan-sanctioned refuting
branch, the construction it named is refuted on compiled ground, and the construction that would
replace it is stated nowhere in the tree (Stage 1 below). Decidability-before-completeness is
unchanged; what the pivot licenses is the subordinate front running in parallel rather than
waiting.

**One asymmetry in the gate, stated so the ruling is not read as stronger than it is.** `(P1)` is
the gate at **Base/Dense/RTime**, where its r.e. status is OPEN with a located obstruction. At
**ZTime it is already settled affirmatively on paper** — `559` item (k), report 03 §1.3, resting on
recalled Rabin with the finite model property not established. So `559`'s `(P2)`, which targets
ZTime specifically, is **not** gated on Stage 1: it is gated on `833` and on `(P0b)` alone. What
Stage 1 would add at ZTime is a *constructive* settlement of a question the paper route already
answers non-constructively — which is also why that route is no substitute for Stage 1's own aim.

## Run these next

```bash
/orchestrate 844 --hard --lit   # the front's live mathematics: the re-anchored deletion half, narrowed to a nxt-exposure plus ONE bounded inequality
/revise 761                     # THE critical path, and it needs a PLAN not a dispatch: Phase 11.5 is [BLOCKED] and 11.6 inducts from its unproved base case, so 11.6-11.7 and 12-18 are unreachable and only 11.2 is enterable
/orchestrate 833                # the L^▷ keystone, ~40 lines of transcription — NOT in the same cycle as 761/763/844, which it collides with on docs/theorem-index.md
```

**Do not re-dispatch `761` as an implement round.** Its plan's critical path is severed at Phase
11.5, so a dispatch spends its cycle budget on phases that cannot close — which is exactly what the
last round showed, closing 11.3 and 11.4 cleanly and then hitting the wall at 11.5. `/revise 761`
with the refutation as input is the cheap move; `844` carries the mathematics meanwhile.

**Do not dispatch `836` either: it is `[BLOCKED]` and the front has descended past it.** The chain
is `836` → `838` → `844`, and `844` is the only member of it that is dispatchable. Dispatching
`836` re-enters a record whose own successor already refuted the framing it was filed under.

`833` is the one implementation step the completeness front needs before it can be run at all
(`559` declares it, and by the gate asymmetry above `(P2)` waits on `833` rather than on Stage 1).
It does not touch the `RaySummary` set.

**THE OPEN CORE IS NARROWER THAN IT WAS FILED AS (2026-11-03), and this is the ruling that moves
the front.** `838` was filed as a TWO-SIDED open core on the strength of a spanning-block device
refuted in both directions. Two of its three load-bearing claims did not survive. First, `(K1)`
provably does not constrain a spanning block's length at all — settled by compiled refutation, not
left open, so no amount of work on that device pays. Second, and the one that matters for ordering:
the "forward register cascade" that blocked Phase 5 **rests on a mistake**. The deletion mirror it
called unlanded is landed and green, and defeats the exact bound by re-anchoring the anchor VALUE
while leaving the anchor POSITION fixed; `tightChain_slack_zero` does not refute that route,
because zero slack is exactly what the re-anchored bound consumes. What remains is a missing
`nxt`-exposure plus ONE bounded inequality at ONE region start. **Do not re-plan this area from the
two-sided framing** — read `844`'s record and `838`'s `.blocker-research.json` first; they carry
the refutation with the declaration names and line numbers.

**SUFFICIENCY RETURNED (`815`).** The certificate is sufficient at the LABEL level over the
strict-since relation `cohBi` (`realizes_of_certAdm_cohBi`); the two-sided claim for `coh` is
REFUTED (`sufficiency_refuted`, the backward arm and only the backward arm). The rulings this
carries: Route B's relation is `cohBi`, by name; no backward propagation theorem is ever to be
claimed for `coh`; both arms stay EXISTENTIAL (`ULive`/`SLive` remain the wrong strength); and
realizability here is label-level, so the semantic step from a fulfilling label chain to
membership of a type in a cell (obligation (d)) is what remains of adequacy. The compiled detail,
the gate dispositions and the refuted index shapes are in Stage 1 below.

`761` declares six edges (`760`, `775`, `805`, `806`, `819`, `820`). All six are now discharged —
`819` landed the presentation decision and **`820`'s counter-lift gate table is compiled and
COLLIDES at both decision gates** (`gate9_col_cell_eq`, `gap_shift_cell_eq`, each an EQUALITY of
`cellAt` values), so neither hazard is a seventh mechanism, the ladder route is NOT closed, and
the counter-lift lemma's two halves are LICENSED in pumping form — licensed, not proved: (S), the
pumping completeness clause and the parameter sources are `761`'s obligations to discharge. The decision: presentation (a) is chosen, the set-valued per-state
datum in its maximum-certified form (`D`, the maximum `certAdm`-certified subset of the carrier
`Q × ClType φ × K`; `ladderRealized` the fibre equation; the factorization lemma a corollary);
presentation (b), a parameter-coupled tuple index stated alone, is dominated on every obligation,
incomplete as a presentation (a tuple class carries no types) and barred by the refutation record —
reported, not proposed. The ruling: no tuple index is to be stated at any parameters; `K` is a
carrier coordinate whose parameters are outputs of the lemma. `761` inherits the idle-extended
`cohBi` on that carrier and the label-level limit, now read as region-interior.
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

**Red gate, not on the critical path, and a few minutes' work.** The upward-import count is
settled: `docs/ARCHITECTURE.md` now records **eight** lines and no upward-import check fails, so
that condition is discharged and its record is closed. A DIFFERENT gate is red in its place, and it
is this session's own regression rather than an inherited one: `scripts/check-module-invariants.sh`
exits 1 on **C28, the compiler-warning budget**, reporting two entries above
`scripts/warning-budget.txt` — `linter.style.longFile` and `linter.style.longLine`, both NEW with
no baseline entry, both in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`. That file was
edited to wire the forty-seventh probe, which pushed it past the long-file limit and left one long
line.

**Why it was reported green, which is the part worth remembering.** The dispatch that introduced it
ran `check-module-invariants.sh --emit-inventory --check`, which exits 0 — C28 is not in that
check selection. A bare `check-module-invariants.sh` is what exits 1. A verification claim is only
as wide as the flags it was made under, so prefer the bare invocation when the question is "is the
tree green", and never read a flagged subset's exit 0 as the whole gate passing. The budget's
counts are a ceiling that may only decrease: fix the two warnings and let the count drop in the
same commit, and do NOT reach for `--update`, which rewrites the file wholesale from current
findings and would bless the regression along with everything else.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 127,128,178,502,570,604,664,714
/orchestrate 729,730,741,743,751,752,753,767
/orchestrate 768,769,770,772,774,777,779,780
/orchestrate 781,785,787,803,804,810,813,817
/orchestrate 818,821,825,829,830,831,832,837
/orchestrate 839,841,842,847,848
```

## Next batches

```bash
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 844 --hard --lit    # the live front: the re-anchored deletion half — a nxt-exposure plus ONE bounded inequality (836 is [BLOCKED]; the chain 836 -> 838 -> 844 descends past it)
/revise 761                      # NOT an implement dispatch: Phase 11.5 is [BLOCKED] and severs the plan's critical path (only 11.2 is enterable)
/orchestrate 837                 # the sanctioned Challenge-statement repair (ParamsOk vs. existential quantification), barred from any implement dispatch by Statement Fidelity
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — waits on 761, which now waits on the 836 -> 838 -> 844 chain
/orchestrate 714,781 --hard      # sliced-certificate internals: full-label evaluation, Phase 5 hoist
# Stage 2 — supporting semantics and metalogic
/orchestrate 833                 # land ⊡φ ↔ ▷◁φ in OpenLanguage; 559's (P2) waits on it, NOT on Stage 1. Shares docs/theorem-index.md with 761/763/844 — never in the same cycle as Stage 1
/orchestrate 664,559,570 --lit   # corpus ingest first, then TM⁺ completeness rounds (559, now over L^▷) and the C3 open question
/orchestrate 830 --hard          # Γ-generalize the landed Compression.decidableValidZTime; strengthens L, does NOT advance the L⁺ aim
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 847,848             # the external-source-store pair: phase commits silently drop source-store paths; the test sweep is permanently red for the same one cause (24 of 156 suites)
/orchestrate 845                 # name the typst-sync gate as a commit refusal's cause instead of reporting a generic PARTIAL commit — waits on 839
/todo                            # 821 is DISCHARGED IN SUBSTANCE, not open mathematics: Check 12 now passes and allocation is dense. Close the record or re-scope it; do not re-dispatch it as filed
/orchestrate 803,804,829         # the build-cost front: SubformulaProperty's elaboration time, its fan-in, then the absent .lake/build CI cache
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
/orchestrate 832                 # local-disk reclamation: .opencode_OLD/ (62M, safe) and data/'s two abandoned .partial files (390M, user decision)
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 481 --hard          # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: state and attempt the Log(all) = Log(ZTime) ∩ Log(Dense) dichotomy that gates any dense-time certificate route
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
- **Eleven tasks have the frozen shape and are not among the seven: 785, 813, 814, 822–827, and
  834/835.** Each declares a `file_scope` wholly (785, 813, 822–827, 834, 835) or almost wholly
  (814) under `agent-system/**`, a path that does not exist in this repository — `ls -d
  agent-system` fails here. They collide with one another too: 785, 813 and 814 share the lean
  extension's `index-entries.json`; 822, 827 and 835 share the core extension's; and 834 shares
  `docs/architecture/orchestrate-state-machine.md` with 823. They need the same disposition as the
  seven and have not been given one.

  **834 and 835 were filed on 2026-11-02** by an `/orchestrate` conclusion stage, from defects
  observed while running 761. They are recorded here rather than in a batch line because they carry
  the frozen shape, and they are worth reading even if the disposition goes against them:

  - **834** — an `[IMPLEMENTING]` re-dispatch fires even when the handoff's own recorded next action
    was a PLAN REVISION, because the blocker-research aux chain is **a dead drop with no receipt**:
    `orchestrate-cycle-plan.sh` clears `aux_pending[t]` at *emission* time, before anything confirms
    the fork wrote `.blocker-research.json`, so if that write never happens the pending entry is
    already gone, the later file test fails, no cycle ever emits the `plan-revision` row, and the
    task falls back to status-derived routing into the known-blocked phase.
    `MAX_BLOCKER_ESCALATIONS` never fires because the counter advances on the signal being
    *re-recorded*, not on a round producing nothing. This is the mechanism behind 761's own
    repeated re-entries into blocked phases, so it is not a cosmetic defect.
  - **835** — a generic cross-extension provision in core's `plan-format.md` that a repo-wide gate
    criterion be stated relative to a recorded baseline rather than as an absolute zero. 785 owns
    the lean-extension siting of the same finding; 835 owns only the generic clause, with an
    explicit division-of-labour pointer each way.

  Three further defects from the same round were **already owned** and were not re-filed: the
  `lake-build-guard.sh` stale-replay (767), and the two `lean-challenge-snapshot.sh` items (768,
  813). Two of those may be stale: the backtick-token misparse 768 records appears **already fixed**
  by commit `42c23f442`, and 813's exit-73 refusal already carries a documented `--force` bypass, so
  that item may be discoverability rather than a tool gap. Neither record was amended — that is a
  `/revise` call.
- **784** is the tracker for the freeze and is itself `[BLOCKED]` on the migration. It owns the only
  part this repository can do: once the records have landed in the source store, verify them there,
  delete them from `specs/state.json`, regenerate `specs/TODO.md`, and drop this section.
Every other open task appears in exactly one batch line above, except the items repeated in
**Run these next** for priority. Re-checked mechanically on 2026-11-02 against `state.json`: of 81
open tasks, every one is either in a batch line or named in this section. The count moved by four
that day — 834/835 (frozen, named above) and 836/837 (Stage 1, batched).

**Reading the generated coverage appendix.** It is not a list of unbatched tasks. It lists the
tasks whose status is *ready* that are absent from **`## Run these next`** alone — coverage is
computed from that section's body, never from `## Next batches` or from this section. So a task
batched in Stage 1 and deliberately kept out of the immediate run list (837, today) appears there
correctly, and its presence is not a gap to close.

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one dependency edge (`465`) is discharged and its `blockers`
      says "paused at 4/5 cycles, NOT blocked", so the marker is mis-set and the next step is a
      scope decision: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Give **785**, **813**, **814** and **822–827** a disposition — frozen like the seven, or
      re-sited. All nine declare `agent-system/**` paths absent from this repository
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

- **Adequacy — SUFFICIENCY RETURNED (`815`); PRESENTATION CHOSEN (`819`); what remains is (2), (3) jointly — the counter-lift lemma — then the semantic step (d).** The index
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
  remains of adequacy is the counter-lift lemma — obligations (2) and (3) jointly — and then the
  semantic step (obligation (d)). The route is Route B (check a candidate realizable
  set), chosen over Route A (decide generalized-Büchi nonemptiness — a missing nested fixpoint,
  real work, not to be entered without a decision record). Still open alongside it: **gate 8 is
  SIDESTEPPED, not passed** (the `stab`/`box` clauses are present but unexercised; exercising
  them needs a fixture whose closure has `stab` members); gate 3 is **CARRIED**. Gates 1, 2 and 9
  are **ADDRESSED AND COMPILED** on `820`'s 4-cycle fixture
  (`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`): SEPARATION at gate 1
  (`gate1_cell_ne`), gate 2 (`gate2_cell_ne`) and gate 9's n-side separation half
  (`gate9_sep_cell_ne`), COLLISION at gate 9's collision half (`gate9_col_cell_eq`), and the
  earlier compiled qualification — Branch N-VERIFIED, that the refuted tuple's n-side coordinates
  pass gates 1 and 2 while staying blind to the shift the datum has to see — stands unchanged.
  A gate probing one coordinate certifies one coordinate only. The set of cells stays
  finite (`anchorCells_ncard_le`); only the index/presentation is open. The declined alternative
  (R2: an index-free, `box`/`stab`-free run-layer half, `slive` retained) stays on record but is
  not pursued — it would not reach the `box`/`stab` letters Stage 1 needs.

  **Presentation chosen** (`819`; decision report
  `specs/archive/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`):
  the index is `D`, the maximum `certAdm`-certified subset of the carrier `Q × ClType φ × K`, where
  `K` is a quotient of the two ladder counters; `ladderRealized` is the fibre equation (`cellAt` at
  `(q, c, n)` equals the fibre of `D` at `(q, κ(c, n))`); the factorization lemma for `K` is its
  corollary, with `K`'s parameters as OUTPUTS of the counter-lift lemma — `K` is a carrier
  coordinate, not an index, and no tuple index is stated at any parameters. Finding 1, compiled:
  the certified chains of record are REGION-INTERIOR — `coh`/`cohBi` require `pend` at both
  endpoints and no forward `Rlad` ray is pending forever (wired probe
  `no-pending-forever-ray.lean`: `exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`) — so
  the label-level results compose only through the counter-lift lemma (soundness: every `RladAdm`
  history projects to a class-level chain over the carrier under the idle-extended `cohBi`;
  completeness: every such chain lifts). Finding 3, exactness: `Real` is itself certified given
  constancy of `cellAt` on `K`-classes and every certified set lies inside it, so the maximum
  certified set is `Real` and is computable by enumeration over `Finset (Q × ClType φ × K)` — a
  count of candidates, no bound of any kind; this is the decision record the Route A sentence
  above asked for, and its verdict is that Route A is not entered. The lemma's two hazards were
  `820`'s first gates: gap shift under pumping (lengthening a region by `P` lowers every earlier
  gap by `P` unless `n` is pumped in step, which the previous idle run must absorb) and short idle
  runs that cannot absorb a deadline shift (`L_{k+1} ≤ 2 L_k + j_k + 1`). **Both now carry compiled
  verdicts, and both COLLIDE** (`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`:
  `gap_shift_cell_eq`, with the absorber exhibited as `absorber4`; `gate9_col_cell_eq`), each an
  EQUALITY of `cellAt` values with non-vacuity witnessed on both sides first — so neither hazard is
  a seventh mechanism and the negative branch is closed out, not merely unexercised. The same probe
  compiles the statement-shape refutation `no_positionwise_lift` (no POSITIONWISE lift exists for
  ANY finite `K`, so the completeness clause must PUMP) and the pin lemma's lift half
  (`drift_extension_of_pins`, `exists_rlad_hist_of_walk`), which is where the lift's counter
  argument ends: what remains is the chain-replacement argument on the type sequence.
- **761 — the ladder realization theorem** (`LadderCons`, `ladderRealized` per cell, for ALL `φ`
  including `box`/`stab` letters — where (S)'s limitation lands by the README's assignment).
  `[IMPLEMENTING]`, and **blocked at its own heart — revise it, do not dispatch it.** All six of
  its declared edges are discharged (760/775 archived, 805/806 `[COMPLETED]`, 819 the presentation
  decision, 820 the counter-lift gate table), so nothing *gates* it; what stops it is open
  mathematics inside it. Phases 11.3 and 11.4 landed clean (below); **Phase 11.5, the depth-0
  cell-level agreement on `κ`-classes, closed `[BLOCKED]` on the refuting branch its own task
  provided for** (commit `9347d41d1`, the 46th wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`). Phase 11.6
  inducts from 11.5's base case, which is STATED and proved nowhere, so 11.6-11.7 and 12-18 are
  unreachable along this route and **11.2 is the only enterable phase left** — and its single
  consumer, Phase 15, is itself unreachable. The successor mathematics is 836; the barred
  Challenge-statement repair is 837.

  **What 11.5 established, and the distinction that is not a hedge.** `CellLEZeroConstOfKappaEq`
  is stated as a Prop-valued schema in `LadderAgree.lean` and the name
  `cellLE_zero_const_of_kappa_eq` is reserved and claimed by nothing. The construction it needs was
  identified as `AtomPreservingCountMove` — an atom-row-preserving ladder path through the other
  counter pair, which is exactly the hypothesis of 11.4's `tpOf_stabFree_eq_of_lab_eq`, the only
  landed way to make two ladder paths realize the same stab-free type — and **that construction is
  REFUTED**, generally, with the mechanism compiled: `cntAt_eq_of_pend_eq` sharpens
  `cntAt_eq_of_obj_eq` to the hypothesis its proof actually consumes, making the countdown a
  function of the **pend profile alone**, so moving `c` moves the pend profile;
  `pendFactorsLab_of_atom` shows the pending bit factors through the atom row as soon as the
  labelling carries it as one of its atoms, which a statement quantifying over every
  `lab : Q → Atom → Bool` does not exclude; `cntAt_eq_of_lab_eq_of_pendFactorsLab` then forbids any
  atom-row-preserving path from carrying a different countdown anywhere. The `n` half closes
  (`nxt_free`); the obstruction is confined to `c` by construction. Non-vacuity is carried on both
  sides in one statement (`exists_refuting_collision`: `ParamsOk` at the periodicity fixpoint's own
  outputs, a populated `kappa`-collision at `c ≠ c'` through `kappa_eq_of_shift`, and a ladder path
  through EACH of the two ladder states). **What is refuted is the CONSTRUCTION, not the
  obligation**: a cell is a set of types over all histories through a state, two ladder paths can
  realize the same closure type without agreeing on a single atom row, and the probe exhibits a
  path through each state while saying nothing about whether the two cells coincide. The obligation
  is neither proved nor refuted.

  **The index/transport line is now five refutations deep, every one by the same mechanism — the
  counter is observable through the closure, so it cannot be quotiented away.** Read the table
  before proposing a shape; the tuple-widening line was already declared spent and the pointwise
  transport line is spent too.

  | | Refuted shape | Mechanism | Probe |
  |---|---|---|---|
  | 1 | counter-pair clipping | the gap `n − c` is observable, so bounding each counter bounds nothing the cells depend on | `ladder-cell-refutation.lean` |
  | 2 | clipped/gap-carrying (third coordinate) | a pending region's first idle state sits at distance exactly `c + 1`, where the countdown's PARITY is observable | `ladder-cell-index-obstructions.lean` |
  | 3 | six-coordinate residue-carrying, object-exhibited parameters | the threshold must be formula-derived and the modulus a multiple of every letter-definable sub-object's period | `ladder-residue-index-refutation.lean` |
  | 4 | the same body at jointly derived parameters | a formula carves out a sub-object no set of atoms carves out, by forbidding a *pattern* rather than a letter | `ladder-joint-index-refutation.lean` |
  | 5 | `AtomPreservingCountMove` (pointwise-valuation transport) | the countdown is a function of the pend profile alone, and `pend` factors through the atom row | `ladder-cell-agreement-refutation.lean` |

  **Three live moves, in the order they should be tried.** (a) **Attack the obligation, not another
  construction**: five refutations by one mechanism is evidence `cellAt` may not be constant on
  `K`-classes at all, and a deliberate refutation attempt on `CellLEZeroConstOfKappaEq` pays either
  way — a refutation drops presentation (a) before more rounds are spent inside it, a failed attempt
  localizes what `K` must quotient by. (b) **Re-open `819`'s Route A / Route B decision**: it chose
  Route B (check a candidate realizable set) over Route A (decide generalized-Büchi nonemptiness)
  *because* `Real` is computable by enumeration and B was therefore cheaper; B's check is precisely
  the blocked agreement, so the cost comparison the decision rested on has changed. (c) **Stop
  quotienting the counter and decide the counter system instead**: the index line tries to make the
  counter invisible and every refutation says it is not, while the ladder's counters are tightly
  disciplined (`Count` a deterministic countdown while pending and pinned at `0` while idle, `Drift`
  at most `±1` per step) — the reversal-bounded / one-counter shape whose emptiness is decidable in
  the literature. Nothing of that is in Mathlib, so it is bespoke, and it embraces the observability
  problem rather than dodging it; it is named here as the architecturally distinct option, not as a
  costed plan.

  **One asset the decidability front has not used.** `⊡φ ↔ ▷◁φ ↔ ◁▷φ` holds on every regular task
  frame, choice-free (`559` probe 05; `833` lands it in the library), and `559` item (n1) records it
  as "the TWO-SIDED DECOMPOSITION report 03 §4 named as the device the engine lacks" — the
  metatheory's `plusStab_iff_rays` promoted to syntax. It is currently filed on the completeness
  front only. What `836` needs is transport that preserves the realized TYPE without preserving the
  valuation pointwise, and `▷`/`◁` give a ONE-SIDED factorization of exactly that condition (`▷`
  fixes the past and varies the future over `AgreeUpTo`, `◁` fixes the future and varies the past
  over `AgreeFrom`), while the ladder's `c` is a FORWARD deadline countdown and refutation 5's
  mechanism is a statement about forward structure. So a one-sided transport has a principled reason
  to behave differently from the refuted two-sided pointwise one. **This is a conjecture recorded as
  one cheap probe's worth of work, not a result and not a route** — it is cheap only because `833`
  is a transcription of an already-compiled proof. `559`'s COORDINATION NOTE is the reason it
  belongs on this page at all: `(P2)` and this front's agreement lemma "target THE SAME MATHEMATICS
  from two directions", and the blocked obligation IS that lemma.

  **What landed before the wall, and is not at risk.** Phase 11.3 promoted the alternative-history
  construction into `LadderAgree.lean` as ten gate-covered declarations, generalised off the
  prototype's three-state fixture to an arbitrary object. Phase 11.4 landed the atom-valuation
  closure agreement at the pointwise-`lab` hypothesis the ladder model's valuation actually reads
  (not half (i)'s object-walk equality), and **settled its own open question affirmatively: the
  `box` arm WIDENS** — `box_mem_tpOf_transfer`'s only hypothesis beyond closure membership is
  same-model, and both compared histories are histories of the same `ladderModel`, so that induction
  case is `Iff.rfl`. The usable fragment is therefore **stab-free with `□` included**, strictly wider
  than the route decision assumed. Through all of it: full build green, `sorry` 0, and the repo-wide
  axiom count and vacuous count unchanged.

  `820` returned the POSITIVE branch: both decision gates collide, so the ladder route was not
  closed and the counter-lift lemma's two halves are licensed in pumping form, with `K`'s parameters
  as outputs of the first repeat of the realizable-type iteration. **Licensed is not proved**, and
  Phase 11.5 is where that distinction became load-bearing — (S), (C') and the parameter sources are
  this task's own obligations, and a gate probing one coordinate certifies one coordinate. It
  inherits presentation (a) — `D` the
  maximum `certAdm`-certified subset of the carrier `Q × ClType φ × K`, `ladderRealized` the fibre
  equation — the idle-extended `cohBi` on that carrier, the `certStab`-per-`(q, κ)` rebuild, and
  the label-level qualification of `815` with its region-interior reading:
  `realizes_of_certAdm_cohBi` is sufficiency for the interior of one region and transfers to the
  region segments of a ladder history, never to the history itself. The **sufficiency verdict** it
  waited on is in (`815`, above): the mathematics is costable over that relation.
- **836 — the type-preserving construction**, Phase 11.5's successor and now the front's open
  mathematics. A construction preserving the realized TYPE without preserving the valuation
  pointwise; stated nowhere in the tree. Filed as a child of 761 with the refutation, its mechanism
  and the available ground in its description: 11.4's
  `truthAt_iff_of_lab_eq_of_stabBoxFree` / `truthAt_iff_of_lab_eq_of_stabPinned` /
  `tpOf_stabFree_eq_of_lab_eq` / `tpOf_stabBoxFree_eq_of_lab_eq` with the `box` arm widened, and
  11.3's `altWalkPath` / `altWalkPath_eq_of_objAt_eq`. Read the five-row refutation table above
  before proposing a shape. **It is now `[BLOCKED]` and the front has descended through it** — see
  `838` and `844` below, which carry what is left of it.
- **838 — the pin layer, landed; the open core narrower than it was filed as.** Five of six phases
  are in, certificate-free and green: `RaySummary/LadderPin.lean` carries the pin-free dichotomy
  (`idle_of_idle_of_no_pin_below`, `pend_past_or_idle_of_no_pin_below`,
  `pendPast_or_cntAt_le_nxtAt_succ`) and a pigeonhole over the PINS rather than over one region's
  interior, so its block SPANS a pin (`exists_pinTypeBlock_of_budget_lt_pins`,
  `exists_spanningBlock_of_pins_below`); `LadderChain.lean` gains `two_pow_card_prodState_le_Tc`.
  All five pin at a subset of `[propext, Classical.choice, Quot.sound]`. **Phase 4 settled a
  question rather than leaving it open: `(K1)` provably does NOT constrain the length of a
  type-respecting block spanning a pin** — both cycle-length conjuncts carry "pending throughout"
  on the walk they quantify while a spanning block's walk is idle at the pin inside it
  (`spanning_walk_not_pending`), and `satPeriod` is a datum of `step`/`lab`/`φ` alone. The refuting
  object is the alternating path. A `(K1)` amendment is a separate decision, not part of this
  record. Phase 5 closed `[BLOCKED]`; nothing was landed under the reserved name
  `cellLE_zero_const_of_kappa_eq`, which is still claimed by nothing.
- **844 — the re-anchored deletion half, and the live front.** It exists because `838`'s reported
  blocker DOES NOT HOLD as stated, which is the one thing to read before touching this area. The
  deletion mirror reported unlanded IS landed and green: `exists_deleted_ladderPath_of_pend_past`
  (`LadderPump.lean:287`) already defeats the exact bound called undischargeable, by passing
  `nxtAt g (l : ℤ)` — the anchor value re-read at the SHIFTED position — and closing the anchor
  clause via `nxtAt_lipschitz_two_sided` with zero slack. So `tightChain_slack_zero` does not
  refute the route; zero slack is precisely what the re-anchored bound consumes. The root cause is
  an anchor-POSITION mismatch between two landed layers, not a register cascade: the lift is
  hardwired to position 0 while the deletion window sits at `a` and reads `l` positions right, and
  `n₀` is a FREE PARAMETER of the lift rather than a datum of `g`. The genuine residual, never
  reached by the blocked phase, is that the landed deletion theorem exposes only `objAt`/`cntAt`
  while its consumer `cellAt_subset_of_shift_of_pend_past` needs `nxtAt g' z = n` — **a missing
  `nxt`-exposure, plus ONE bounded inequality at ONE region start**, since `hstart` collapses the
  cascade to the nearest pin. Route: a `z`-anchored lift conjugating the landed
  `isLadderPath_shift`, a `nxt`-exposing deletion theorem re-running the landed one through it,
  then `|nxtAt g (v₀+l) − n| ≤ v₀ − a` from the landed forward window. If that inequality is false
  the honest outcome is a named side hypothesis on a single region start — a regime restriction with
  a finite witness, never a reopened open core and never a weakened statement under the reserved
  name.
- **837 — the barred Challenge-statement repair.** `cellAt_const_of_kappa_eq` and `ladderRealized`
  are refuted as recorded, because both universally quantify `(Tc Tn P B : Nat)` with no hypothesis
  relating the parameters to the object, the formula, or each other — at `Tc = Tn = P = B = 0` the
  quotient is a subsingleton and `cell_succ_ne` refutes constancy for every `c` and `n`. The two
  candidate repairs (add a `ParamsOk Tc Tn P B` hypothesis carrying (K1)-(K4), or existentially
  quantify the parameters) are each a change to a RECORDED Challenge statement, which
  `plan-compliance.md`'s Statement Fidelity forbids an implement dispatch from making — which is why
  761's Phases 9 and 13 closed `[BLOCKED]` rather than proceeding, correctly. `paramsOk_params`
  already discharges `ParamsOk` at the periodicity fixpoint's own outputs, so repair (a) has a
  landed witness. Deliverable is a sanctioned decision with the revised statement recorded, not an
  implementation. Also settles Phase 8's internal inconsistency (promoting
  `realizes_of_certAdm_cohBi` while the Scope Hypothesis says `certAdm` is not promoted).
- **763 — the lift** (`not_plusValidZTime_iff_ladderRefutes`, `objBound φ` a count) and the
  `Decidable (PlusValidZTime φ)` corollary by bounded enumeration — the AIM. It waits on 761 alone,
  and 761 now waits on 836, so this is two open steps away rather than one. 761 and 763 share the
  `RaySummary` library set and serialize through the edge between them.
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

**559 is a TM⁺ task, not a TM⋆ one** — its directory name is a legacy misnomer; its own AIM is a
sound and complete proof system for the stability modal `⊡` over the all-histories task semantics.
Its object language is now **L^▷** by user ruling (2026-11-02): L⁺ plus the manuscript's
open-future `▷` and open-past `◁`, whose semantics is already built and sorry-free at
`FormalSystem/OpenLanguage/`. The ruling rests on one compiled fact —
`⊡φ ↔ ▷◁φ ↔ ◁▷φ` on every regular task frame, choice-free
(`specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean`)
— so `⊡` is definable and no L⁺ result is traded away; and it buys the two-sided decomposition the
engine obstruction named, plus a sound home for the Ockhamist axiom HN, which is valid for `▷`
(`hnOpen_openValid`) and refuted for `⊡` (`hnStab_refuted_sinkFrame`). It does **not** close the
gap: the binding obstruction is closedness of the canonical bundle, `▷`/`◁` supply no closure
principle, and an `LC_n`-style schema is still required. **Nothing here is a completeness claim**,
and the four cheap discriminating checks (559's `(P0)`) run before any engine work. The first of
them, `(P0a)`, is **task 833** — landing that biconditional in the library, with its
`docs/theorem-index.md` row and its README rows — which 559 cannot do itself because its own hard
constraints forbid any change under `FormalSystem/`; **559 declares 833 as a dependency**, and 833
has no blockers. Note also that
this front and Stage 1 meet: a decision procedure for `PlusValidZTime` makes the `⊡`-validities
r.e., which is 559's `(P1)` gate at ZTime, and report 03 §1.3's MSO/Rabin argument already settles
that gate on paper — non-constructively, which is why it is no route to Stage 1's own aim.

**Scope of the next `559` round, and the one churn hazard on this page.** Run it for `(P0b)`,
`(P0c)` and `(P0d)` only — three probes: whether `▷` is L⁺-definable at all (a positive answer
retires the language ruling, so run it first), whether `tw_invariance`/`clock_invariance` extend to
`▷`/`◁`, and whether `LC_n` holds in its `▷` form over ℤ. **`(P0b)` genuinely is first**: if `▷`
turns out L⁺-definable the language ruling is a notational change and nothing in item (n)'s
consequences survives as new content, so it gates the other two and the engine both.

**Do not open `(P2)`, the ZTime truth lemma, while `761`/`836` are live** — but the reason is the
COORDINATION NOTE, not the gate. 559 records that `(P2)` and the certificate line's agreement lemma
"target THE SAME MATHEMATICS from two directions. Neither should prove it twice", and the obligation
`836` now carries IS that lemma, so the collision is live rather than hypothetical. What has
*changed* is the reading of the gate: by the asymmetry recorded at the top of this file, `(P1)` is
already settled affirmatively at ZTime on paper, so `(P2)` is not waiting on Stage 1 to be
licensed — it is waiting on `833`, on `(P0b)`, and on not duplicating `836`. Whichever of the two
fronts reaches the agreement lemma first states it in reusable form and the other cites it; that is
559's own instruction and it is now the operative sequencing rule between the two stages.

**The binding obstruction on this front is unchanged, and it is not `(P1)`.** It is closedness of
the canonical bundle (559 item (c)): all-histories semantics = *closed* bundles, PS/US give
paste-closure, MF gives translation-closure, and **nothing gives closedness**. The cure of record is
`LC_n` in the logic plus progress measures carried in the state (items (i), (j)), with `LC_n`
already ZTime-valid for every `n ≥ 1` (`lcN_valid_full`). `▷`/`◁` supply no closure principle — the
language ruling is a decision about where to look for an engine, never a claim that it closes the
gap.

## Stage 3 — Datasets, examples, documentation, hygiene

Independent of every other stage. Standing rule on any `C16` unused-binder red: prefer the
signature edit to a `scripts/nolints.json` entry, check the call sites first, and **do not run
`lake exe runLinter --update`**, which would grandfather the regression wholesale.

803 and 804 both touch `Verified/Termination/SubformulaProperty.lean`, so the pair serializes inside
one batch; that module is the repository's single largest rebuild cost (1103s measured on a full
guarded build) and any edit to the syntax or proof-system layer wakes it, so paper-alignment work
pays for it repeatedly — run the pair early. **829 is a different lever and does not serialize with
them**: it adds the `actions/cache` step for `.lake/build` that no workflow currently has (only
`use-mathlib-cache: true` is set, in all three), so every CI run re-elaborates 716 modules /
371,441 lines from scratch. 803/804 cut what one module costs to elaborate; 829 stops paying that
cost twice. Its `precompileModules` and matrix-split notes are measured experiments, not part of
the cache change, and neither lands without a before/after timing. Re-check 298's line and
metadata counts before dispatching it. The `RaySummary`/`KTypeSummary` inventory tables are
wrapped, so INV now catches a drifted count; a task that hand-edits one still re-runs the
generator rather than editing the wrapped block. 257 shares `data/README.md` with 282.

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

**`roadmap-integration.sh --regenerate` is safe against this file, and the stage layout is now
taught.** Re-verified 2026-11-02 against the live script, by dry run and by reading it: the
`--regenerate` path is `mode_regenerate_stage`, which retains every `## ` section byte-for-byte
**except** the run-order section (`## Run these next` — the first section holding a fenced
`/orchestrate` block), whose body it round-trips, stripping the previously-generated coverage
appendix and appending a freshly rendered one. A dry run reports `retained=11` and its only diff is
that appendix, so the authored Stage prose is not at risk and stale copies do not accumulate. One
residual defect, cosmetic: the diagnostic is still an HTML-comment marker on stderr
(`<!-- roadmap-generation mode=... -->`) rather than a named message.

**`--prune`'s flag-merge defect is fixed.** Its source-store record
(`prune_next_body_flag_misparse_drops_active_task`) is completed, and the fix is verified here on
two fixture shapes against scratch copies, never the live file: a flagged multi-task Run line drops
only the terminal id and keeps both the surviving id and the trailing flags
(`/orchestrate 761,820 --hard --lit` → `/orchestrate 761 --hard --lit`), and a flagged single-task
line whose only task is terminal is removed whole. `--prune` also reaches only the run-order
section; every other section is retained byte-for-byte.

**THE ONE WAY TO LOSE AUTHORED WORK IN THIS FILE.** `strip_coverage_appendix` stops reading at the
`**Coverage appendix (uncovered tasks)**:` marker and discards everything after it *within the
run-order section*. Anything authored below that marker inside `## Run these next` is therefore
destroyed by the next `--regenerate`, silently and with exit 0. Keep authored content above the
appendix, and leave the appendix last in its section.

**No hand-deletion after an orchestrate run.** `/orchestrate`'s conclusion stage runs
`roadmap-integration.sh --regenerate` as a mandated step
(`.claude/context/contracts/conclusion-stage.md`, Step 5). That is the intended path rather than a
conflict with this file: it refreshes the coverage index idempotently. The former standing
instruction to delete the appended block by hand no longer applies — deleting it only means the
next run re-adds it. What is left of the source-store record (752) is the diagnostic-message half
alone; it remains **frozen and undispatchable from here**, and its own description predates both
fixes above. The decidability inventory
(PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree by
`scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
