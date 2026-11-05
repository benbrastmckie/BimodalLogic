# Roadmap

*Open work only, hand-maintained: batch ordering and the rulings that gate it, nothing else. The
mathematics and the (C)/(S)/(W) verdict table live in
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` (the authority); per-task detail in
`specs/TODO.md`; finished work in `specs/CHANGE_LOG.md` and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate.

**One exception now outranks Stage 1: `864` must run before the next `/todo`.** It ports the
limit-closure schema (`lcN`, `lcN_valid_full`, `omega_limit`) out of `559`'s probe directory,
which `/todo` archives. `559` completed as a NARROWED task whose description states that "The
LC-schema and axiomatizability discussion in report 03 is NOT part of this deliverable", so that
content is landed nowhere under `FormalSystem/` and is owned by nothing else. Archiving first
does not destroy it (it moves to `specs/archive/`), but it leaves the only candidate complete
axiomatization for TM⁺ out of the live tree with no task pointing at it.

## Rulings in force

Each is a user ruling or a recorded decision an agent may not override. The argument lives in the
cited record, not here.

- **Decidability before completeness** (2026-11-02). Deciding validity makes the valid set r.e.,
  and Craig then gives a recursive axiomatization — so Stage 1 settles `559`'s `(P1)`. Caveat:
  Craig buys *an* axiomatization, not a natural one.
- **The object language is L^▷.** It is built at `FormalSystem/OpenLanguage/` (sorry-free) as a
  separate inductive with `ofPlus : PlusFormula → OpenFormula`; that embedding plus `⊡φ ↔ ▷◁φ`
  *is* the absorption of L⁺, a theorem rather than a migration. The biconditional is **landed**
  (`833`): `⊡φ ↔ ▷◁φ ↔ ◁▷φ`, four pointwise results in `OpenTruth.lean` and both implications as
  `OpenValid` in `OpenValidity.lean`, on every regular task frame, choice-free. `559`'s `(P0a)` is
  discharged.
- **`⊡` stays primitive**; "definable" means a proved biconditional with the primitive retained.
  Eliminating it would change `⊡`'s truth conditions off the regular class (the `←` half needs
  `[F.IsRegular]`) and discard the front's one working anchor (`stab_mem_tpOf_iff_cell`, one bit
  per cell).
- **No constructor is added to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, and L⁺ is not
  renamed.** Absorb-and-rename is REFUSED: mutating that inductive would turn
  `plus_incomplete_base`, `blc_not_plusDerivable_base` and `not_plus_complete_base` into
  statements about a different language. L⁺ stays embedded.
- **`▷`'s definability is SETTLED, and the verdict splits by frame class** (`854` then `859`;
  reports `854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`
  and `859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md`).
  - **ZTime/RTime: POSITIVE.** `▷`/`◁` are L⁺-definable uniformly in their argument — a
    translation `tr` with `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)` at every model, world
    and time. `▷(α ∨ β) ↔ α ∨ ⊡β` is compiled-live; the paper half is Gabbay separation (GHR Thm
    10.2.9 over ℤ, 10.3.20 over Dedekind-complete flows). New validities: `▷φ⁺ ↔ ⊡φ⁺` for
    pure-future `φ⁺` (`ofutP_of_futDet`) and the rigidity companion `ofutP_of_pastDet`.
  - **Base/Dense: NEGATIVE.** `▷` is a genuine expressive extension of L⁺ over
    non-Dedekind-complete time, not notation for it. Landed as the fourteenth numbered
    Independence result, `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` (33
    declarations, sorry-free). Mechanism — the round's main finding: `▷ψ` is past-determined
    (`ofut_pastDet`), so a separator must be pure-past, and the **marker gadget** supplies the
    anchor every U/S-inexpressible property needs at a gap endpoint —
    `θ := ¬m ∧ ⊞m`, `ν := θ ∨ ⟡θ`, `R := p ∧ ⊞(ν → p)`, `Δ' := S(¬(p ∧ ¬R), ¬p)`. `θ` holds at
    exactly one point (`theta_eq_iff`), `ν` names the closed past (`nu_iff_le`), `R` names
    backward-run membership without naming the run's lower endpoint (`run_iff`), and `▷` installs
    the marker for free because `m` occurs only inside `θ` — so `▷` computes `DeltaProp` exactly
    (`dofut_probe_iff`, `ofut_neg_probe_iff`).
  - **The one paper step of record** is the collapse: `DeltaProp` is not L⁺-expressible on a
    ℚ-time regular frame, by transposing GHR Lemma 12.4.2 from their flow to `ℚ` (every L⁺ formula
    uniformly equivalent to one of `p, ¬p, ⊤, ⊥`; two nice ℚ-structures agreeing on `p(t)`
    disagree on `DeltaProp`, run order type `ℤ` against `ω + 1 + ω`). Not formalized in this tree;
    the reduction theorem that consumes it is conditional and says so
    (`ofut_not_plusDefinable_of_deltaProp_inexpressible`).
  - **`OfutPlusDefinable` is the truth-level notion.** Nothing here refutes a
    validity-level-only translation.
  - **Spend nothing further on a ℤ-time separation.** `sinkFrame` and every `.ZTime` frame are
    excluded as separators.
  - ***Limit* forbids the naive permissive ℚ-frame** — at a frame whose states are the atom
    colours alone, a finite-state history over a dense duration is a uniformly-discrete step
    function, leaving no gap to anchor `Δ'` at. `colourClock`/`colourFibre` removes the
    obstruction (clock discharges *Limit*, finiteness discharges *Saturation*) and its
    `IsRegular` instance is compiled-live. Any future attempt here starts from that frame.
- **The Stage 1 retarget is answered negatively.** Over ℤ every L^▷ formula *is* an L⁺ formula
  under an effective translation, so there is no expressive gain to retarget Stage 1 onto. The
  Base/Dense extension is real but off Stage 1's class. Expressiveness only — no decidability or
  completeness claim either way.
- **The open modals are closed on the decidability front** (`855`, 2026-11-04;
  `855_one_sided_open_modal_type_transport_probe/reports/01_one-sided-open-modal-transport.md`).
  The one-sided ▷/◁ factorization does not crack the transport condition: all six refutation
  mechanisms survive it, two strictly harder, and ▷/◁ are the only two projections. **Two-line
  test for any successor**: name the half-line the counter is read from and the one the formula is
  read from; if both are "forward", `cntAt_eq_of_pend_eq_fwd` plus mechanism 5 already refutes it.
- **L^▷ work is confined to its own task set** — `856`, `866`, `867`, `868` (and `860`, which
  discharges `hmarkers` for the landed non-definability module). No `▷`/`◁` clause is added to
  `clSig`, `LocalRun` or `Anchored`: the containment is about the Stage 1 engine's own
  definitions, not about how many L^▷ tasks exist.
- **Both L^▷ gaps bottom out in L⁺, not in `▷`/`◁`** — the structural reason the set above is
  cheap and the aim above is not. `FormalSystem/OpenLanguage.lean` records that L^▷ "is semantic
  only: it has no proof system", so `856` owes one, but only at Base/Dense where `859` showed `▷`
  says strictly more than L⁺; at ZTime/RTime `854`'s definability result makes TM⁺ already the
  proof system through `tr`. Past that, completeness for L^▷ reduces to a question the tree
  answers negatively or not at all: TM⁺ is **incomplete** at Base (`plus_incomplete_base`) and
  completeness of any recursive extension is open at every class and stated nowhere. That
  question is `865`'s, and before `865` was filed it was owned by nobody.
- **Two hypotheses carry the landed definability verdicts and neither is formalized.**
  `SeparationOver` (GHR Thm 10.2.9 / 10.3.20) carries the positive half — `867` discharges it at
  ZTime and makes `tr` executable. `hinexpr` carries the negative half. **`hinexpr` is
  deliberately not filed**: formalizing it (the `N` collapse induction, the two ℚ run order types,
  the Cantor isomorphism) would harden an expressiveness record whose verdict is already settled
  on `859`'s report, and advances neither completeness nor decidability. Do not file it for those
  goals; `859`'s R3 states its own terms if a consumer ever appears.
- **Gate asymmetry.** `(P1)` gates at Base/Dense/RTime, where its r.e. status is open with a
  located obstruction. At ZTime it is settled affirmatively *on paper* (`559` item (k)), so
  `559`'s `(P2)` is gated on `(P0b)` alone, **not** on Stage 1, which adds a constructive
  settlement there.
- **Stage 1 runs R1 (the gluing route) alone; there is no fallback.** `734` (R2, mosaics) is a
  *consumer* of R1 — deciding mosaics presupposes deciding `⊡`. Nothing on the critical path may
  be gated on it.
- **Presentation (a) for `761`** (`819`): the set-valued per-state datum in maximum-certified form
  (`D` over `Q × ClType φ × K`, `ladderRealized` the fibre equation). **No tuple index is to be
  stated at any parameters**; `K` is a carrier coordinate whose parameters are outputs of the
  counter-lift lemma.
- **Route B, over `cohBi`** (`815`): the certificate is sufficient at the label level over the
  strict-since relation (`realizes_of_certAdm_cohBi`), both arms existential. The two-sided claim
  for `coh` is refuted — **no backward propagation theorem is ever to be claimed for `coh`**.
  Route A (generalized-Büchi nonemptiness) is not to be entered without a decision record.
- **What no path changes.** Completeness is gated by closedness of the canonical bundle (`559`
  item (c)) and by `(P1)`. `▷`/`◁` supply no closure principle and no decision procedure — the
  language extension decides *where to look for an engine*, never closes either gap.
- **`852` is not the only decidability route, and `866` has now measured it: YES at step 4,
  amended at step 1.** `559`'s report 03 §1.3 argues on paper that ZTime validity is decidable by
  an MSO encoding over the ω-branching tree plus Rabin's theorem — five steps, independent of the
  ladder front, needing neither `852`'s pumping lemma nor `761`'s realization theorem nor `763`'s
  lift, and independent of Gabbay separation (`867`'s `SeparationOver`). `▷`/`◁` **do ride** step
  4's encoding: the per-walk agreement restriction they need is first-order over the tree's order
  relation with no added quantifier alternation, the same shape as `⊡`'s "∀P' ∋ x" with an
  MSO-expressible restriction, exactly as hypothesized. The cost is an amendment at step 1 (the
  per-state witness economy is unsound for `▷`/`◁`; countability survives on a coarser indexing)
  — see report 03 §1.3's amendment block and
  `866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`. **This
  reaches ZTime only** (Base/Dense/RTime stay open with the obstruction at report 03 §1.4) **and
  remains a paper result, not formalized and not planned for formalization** (Mathlib has no MSO,
  no ω-automata, no Rabin tree theorem — see that report's finding 8). It does **not** close
  `Decidable (PlusValidZTime φ)` constructively, which is still Stage 1's own aim, and does not
  extend the landed `decidableValidZTime` / `decidableDerivableZTime` (base `Formula` only).

## Run these next

```bash
/orchestrate 864                 # FIRST, AND BEFORE /todo: port the LC schema out of 559's probe before its directory is archived
/orchestrate 866                 # cheapest decidability answer for L^▷: does the MSO/Rabin route carry ▷/◁? Report only
/orchestrate 868                 # cheap and compounding: the L^▷→L⁺ transfer corollaries, stated conditionally
/orchestrate 852 --hard --lit    # THE OPEN CORE: the tpOf pumping lemma, authored not cited
/orchestrate 838,853 --hard --lit # the Phase 11.8 insertion cascade, batched with its blocker
/orchestrate 856 --hard          # UNGATED by 854/859: the L^▷ proof system has confirmed work at Base/Dense only
/todo                            # 11 completed tasks (559, 828, 833, 844, 846, 849, 850, 851, 854, 855, 859) read the open count high — RUN 864 FIRST
```

**`761` is `[HOLD]`, parked mid-plan-v11 at Phase 11.12** precisely so `855`/`852`/`853`/`856` can
dispatch without its 40-path `file_scope` blocking them. **Its scope no longer serializes the
Stage 1 front** — that is the point of the hold. `[HOLD]` is not resumable by an ordinary command:
resuming needs `update-task-status.sh preflight ... unhold` or an explicit
`/orchestrate 761 --implement` override, and doing so re-imposes the serialization on everything
sharing the `RaySummary` library set, `docs/theorem-index.md`,
`scripts/check-module-invariants.sh`, `scripts/check-evidence-probes.sh`,
`specs/evidence/seam-gluing-ray-product/`, `specs/state.json` and `specs/TODO.md`. Finish the
open core first.

**`761`'s open core is `852`, with `853` beside it.** `852` is the model-level pumping lemma for
`tpOf` along a ladder path — hit independently in three implementation rounds, costed by no plan
phase, so it must be **authored rather than cited** (citing `prodPre_periodic` closes a cycle
rather than discharging one); its obvious shape is refuted and compiled
(`ladder-splice-type-refutation.lean`). `855` leaves its terms **unchanged** (the one-sided
reading of it is the same refuted splice shape), so it runs on the existing record. `853` is the
Phase 11.8 insertion cascade, blocked on `838`: batch as `/orchestrate 838,853` or drop the edge.
Both are gated on one owed construction whose obvious route is refuted rather than absent, with no
insertion/lengthening walk constructor anywhere under `FormalSystem/`.

**Do not dispatch `838`, `844`, `849`, `850` or `851`** except as `853`'s predecessor. That chain
is spent: `844`/`849`/`850`/`851` are `[COMPLETED]` and `838` is `[PARTIAL]` on a framing its own
successors measured false. Re-planning the area from `838`'s two-sided framing is barred — read
`844`'s and `849`'s records and `838`'s `.blocker-research.json` first.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 127,128,178,502,570,604,664,714
/orchestrate 729,730,741,743,751,752,753,767
/orchestrate 768,769,770,772,774,777,779,780
/orchestrate 781,785,787,803,804,810,813,817
/orchestrate 818,821,825,829,830,831,832,837
/orchestrate 839,841,842,847,848,857,858,860
```

## Next batches

```bash
# Stage 0.5 — pre-archival rescue and the two cheap measurements; ahead of Stage 1
/orchestrate 864                 # the LC-schema port; must precede /todo
/orchestrate 865 --lit           # owns the TM⁺ candidate axiomatization and the Reynolds automaton obstruction (gated on 864)
/orchestrate 866                 # the MSO/Rabin route for ▷/◁ — settles whether Stage 1 gates L^▷ decidability at all
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 852 --hard --lit    # the open core: the tpOf pumping lemma
/orchestrate 838,853 --hard --lit # the insertion cascade with its blocker. Shares LadderAgree.lean with 852
/orchestrate 837                 # Challenge-statement repair (researched); barred from any implement dispatch by Statement Fidelity
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — needs 761 resumed
/orchestrate 714,781 --hard      # sliced-certificate internals (781 researched)
# Stage 2 — the L^▷ front, then supporting semantics and metalogic
/orchestrate 856 --hard             # the L^▷ proof system: unnecessary at ZTime/RTime (854), genuine work at Base/Dense (859)
/orchestrate 868                    # the L^▷→L⁺ transfer corollaries; antecedents stay open by design
/orchestrate 867 --hard --lit       # formalize Gabbay separation, discharging SeparationOver and making tr executable. Weighed against 866's verdict: the MSO route makes SeparationOver unnecessary for L^▷ ZTime decidability specifically, so 867 is no longer load-bearing for THAT question — but tr's own expressiveness value is independent and unaffected, so 867 stands on that value alone
/orchestrate 860                    # the colourClock bridge discharging hmarkers (researched). Re-point its scope at the landed Independence module first
/orchestrate 664,559,570 --lit      # corpus ingest, then TM⁺ completeness rounds and the C3 open question
/orchestrate 830 --hard             # Γ-generalize decidableValidZTime; does NOT advance the L⁺ aim
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 847,848             # external-source-store pair: phase commits drop source-store paths
/orchestrate 845                 # name the typst-sync gate as a refusal cause — waits on 839
/orchestrate 803,804,829         # build-cost front: SubformulaProperty elaboration, fan-in, .lake/build CI cache
/orchestrate 298,282,296,231     # the dataset chain behind the c7 labeling bug (298/282/296 partial)
/orchestrate 178,604             # worked Examples/ pipeline and zstd .jsonl support
/orchestrate 743                 # doc gate: typst-sync Check 1 namespace resolution
/orchestrate 751,787             # file_scope backfill for the overlap gate; unguarded .lake reader audit
/orchestrate 777,779,780,816     # commit-path and plan-compliance records; 816 waits on 777
/orchestrate 772,783             # jq re-serialization of formatting-sensitive records
/orchestrate 753,774             # conclusion-stage null-resolution drops, refuted-REASON recording
/orchestrate 857,858,810,842     # agent-system defects: handoff-validation crash, --audit-verdict argv overflow, gate16, defect recording
/orchestrate 768                 # lean-challenge-snapshot — separate cycle from 842 (shares the script)
/orchestrate 817,818,821,860     # phantom-row inventory, directory-rollup tables (821/860 researched)
/orchestrate 729                 # purpose-written .title fields so TODO.md stops rendering descriptions
/orchestrate 832                 # local-disk reclamation (user decision on data/'s .partial files)
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 481 --hard          # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: the Log(all) = Log(ZTime) ∩ Log(Dense) dichotomy
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — needs 428's scope ruled; 410 planned
/orchestrate 430,412,482 --hard --lit    # the spine's terminus
/orchestrate 502,497 --research --lit    # the STSA literature gate, then the G-operator gap
/orchestrate 498,499,500 --hard  # the representation's two sides and their reconciliation
/orchestrate 125,501,543 --hard  # the Jónsson–Tarski capstone, Until/Since on STSA, MF correspondence
/orchestrate 177                 # last in the programme: README, docs/ and docstring polish
```

Each line is one invocation. Batches are dependency-inclusive — the engine re-derives eligibility
every cycle, so a batch holding a blocker and its dependent is correct, and one holding a
dependent *without* its out-of-batch blocker is dead weight. `MAX_TASKS` is 8; the work-cycle
budget is per task, per invocation (5 default, 13 under `--hard`), so **re-run the same line until
every member reports terminal**. Shared file scope serializes a batch rather than breaking it; a
task with no declared `file_scope` is invisible to the overlap gate (the blindness `751`
remediates). See `.claude/context/patterns/batch-orchestration-guardrails.md`.

**`866`'s filing-ready follow-up (R1, not yet a task number).** A Lean task: `▷`/`◁` truth
invariance along a history-lifting morphism with ray-agreement lifting, plus the ZTime
construction of such a lifting from `TwoWayBounded`. Shape: one new field or standalone
hypothesis beside `HistMap.lift` ("a history of the image frame agreeing with the image of `τ'`
up to `x` lifts to a history of the source agreeing with `τ'` up to `x`"), its mirror for `◁`,
their derivation over ℤ from `TwoWayBounded.step`/`forth` via the existing forward/backward
sequence machinery, and an `open_invariance` theorem over `OpenFormula` reusing
`plus_invariance`'s seven cases. Cost estimate carried from
`866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`'s
recommendation R1: **150-350 lines, one implementation phase**. Independent of G1, G2, Rabin,
Gabbay separation (`867`) and the ladder/`RaySummary` front — file it with `/task` whenever
convenient; nothing above gates it.

**`866`'s MSO/Rabin decidability step itself (report recommendation R2): do not file.** Formalizing
step 5 of report 03 §1.3 means formalizing Rabin's tree theorem from scratch (determinization of
parity/Rabin automata over infinite trees) — Mathlib has no MSO syntax, no ω-automata, no
determinization of ω-automata, and no Rabin tree theorem (two `lean_leansearch` queries this
session, held evidence). A multi-year project of a different kind from anything in this
repository; keep the ZTime decidability of L^▷ as a paper result.

## Stage 0 — User rulings (no agent may transition these)

- [ ] **Decide when `761` comes off `[HOLD]`.** Resuming it re-serializes the Stage 1 front behind
      its 40-path scope (see `## Run these next`); `763` is gated on it. Recommended: finish `852`
      and `853` first
- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one edge (`465`) is discharged and its `blockers` says "paused
      at 4/5 cycles, NOT blocked", so the marker is mis-set: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Give **785**, **813**, **814** and **822–827** a disposition — frozen like the seven, or
      re-sited. All nine declare `agent-system/**` paths absent from this repo
- [ ] Rule on **807**'s positive verdict: `(q S ⊥) → ⊡(q S ⊥)` characterizes backward determinism
      over regular `ℤ`-frames, making the know-time-do-not-forget family a candidate reduction
      target. Options: (A, recommended) scope the transfer question as its own task with the
      HV89/HVV PDFs in hand and keep Stage 1 moving; (B) halt Stage 1 until settled; (C) record
      the probe only

**713** is held by ruling (2026-10-03): its argued CTL⋆ 2EXPTIME lower bound is a citable ceiling
with no consumer. **734** is `[HOLD]` on the paywalled *Handbook of Modal Logic* ch. 11
§§5.10–5.11 (Hodkinson & Reynolds, pp. 655–720), absent from the local Zotero library;
reactivation condition `specs/literature-index.json#hodkinson_2006.hazard`. Acquiring it lifts a
hold, not the aim.

## Not batched, and why

- **127, 128** await Stage 0 rulings; **713**, **734** are `HOLD` by ruling, **761** by the Stage 0
  item above.
- **730, 741, 752, 767, 768, 769, 770 are frozen: undispatchable from this repository.** Each
  names an edit target resolving only under the agent-system source store
  (`~/.config/nvim/agent-system/**`; this repo's `.claude-extensions.json` declares no
  `source_dir`). Migration is tracked in that store's own task space
  (`~/.config/nvim/specs/390_migrate_mis_sited_agent_system_tasks`). The set is **enumerated by
  that record, not derivable from `file_scope`**: 753, 772, 774, 777, 779, 780, 783 also edit the
  source store but are batched above by ruling, each editing at the mirroring source path and
  redeploying afterwards.
- **Thirteen more have the frozen shape without a disposition: 785, 813, 814, 822–827, 834/835,
  840/843** (Stage 0 item above). They collide with one another too — 785/813/814 share the lean
  extension's `index-entries.json`; 822/827/835 share core's; 834 shares
  `docs/architecture/orchestrate-state-machine.md` with 823.
- **834 is worth reading even if its disposition goes against it**: the blocker-research aux chain
  is a dead drop with no receipt (`orchestrate-cycle-plan.sh` clears `aux_pending[t]` at emission
  time), so a fork that never writes `.blocker-research.json` emits no `plan-revision` row,
  `MAX_BLOCKER_ESCALATIONS` never fires, and an `[IMPLEMENTING]` task falls back into the
  known-blocked phase. This is the mechanism behind `761`'s repeated re-entries.
- **784** tracks the freeze, `[BLOCKED]` on the migration. It owns the only part this repo can do:
  verify the records in the source store, delete them from `specs/state.json`, regenerate
  `specs/TODO.md`, and drop this section.
- **Nine completed tasks await archival** (828, 833, 844, 846, 849, 850, 851, 854, 859). They sit
  in `active_projects` and read the open count high in any check that does not filter on status.
  Run `/todo`.

**Reading the coverage appendix.** It lists *ready* tasks absent from **`## Run these next`**
alone — never computed from `## Next batches` or this section. A Stage 1 task deliberately kept
out of the immediate run list appears there correctly; its presence is not a gap.

## Do not re-attempt

- **Four tuple-shaped index shapes for `ladderRealized` are refuted on compiled ground**
  (`ladder-cell-refutation`, `ladder-cell-index-obstructions`, `ladder-residue-index-refutation`,
  `ladder-joint-index-refutation`). The tuple-widening line is spent; **no seventh coordinate is
  to be proposed.**
- **The pointwise transport line is spent too, one-sided forms included** — see the `855` ruling
  above and its two-line half-line test before proposing any successor.
- **A ▷-specific elimination avoiding full separation is refuted** (`859`'s R3b). At
  `.Base`/`.Dense` there is no elimination to find; at ZTime/RTime `854` already has one.
- **Gate 8 is sidestepped, not passed** — the `stab`/`box` clauses are present but unexercised.
- **`HasForwardSlack` is a genuine regime, not a missing lemma.** The upper residual inequality is
  refuted by a climbing-register ladder path (`ClimbWitness` in `LadderChain.lean`); there is no
  Drift-level invariant to isolate. **Do not re-attempt route (a).** The live route is the one
  `LadderChain.lean` already occupies: the upward cell inclusion
  `cellAt_subset_of_shift_of_pend_past` and the path-level downward inclusion
  `mem_cellAt_of_shift_of_hasForwardSlack_exact`, with the gap to `CellLEZeroConstOfKappaEq` being
  the tight (doubling) chain of pins — not a one-sidedness gap.
- **The unconditional `buildTableau_isSome` is FALSE by construction** at the engine's
  `maxBranches := 50000` guard, at any fuel. The whole decidable-branch-gate family collapses to
  `false` on any branch that mints a world, so `429` is a redesign, not a repair.
- **ℤ-time validity of L is already decided** (`Compression.decidableValidZTime`), so the
  deliverable is the four-class `isValid` biconditional, not a first decidability theorem.
- **`481`'s obstruction is precise**: `universeClosedAt_signedUniverse_of_propositional` is not
  stateable, because `UniverseClosedAt`'s clause 1 universally quantifies an unconstrained `ord`
  while every route through the time coordinate carries `OrdTimesKnown b ord`, non-removable
  in-source. **`482` must re-verify its own anchors first**: `Verified/Refutation/` does not exist
  and `ProofExtraction.lean` holds no verifier declaration.
- On any `C16` unused-binder red, prefer the signature edit to a `scripts/nolints.json` entry,
  check call sites first, and **do not run `lake exe runLinter --update`**.
- **A verification claim is only as wide as the flags it was made under.**
  `check-module-invariants.sh --emit-inventory --check` exits 0 while the bare invocation exits 1;
  prefer the bare form whenever the question is "is the tree green". The warning budget's counts
  are a ceiling that may only decrease — never reach for `--update`.
- **A probe is only measured once it is tracked.** `check_probe` tests
  `git ls-files --error-unmatch` *after* its presence test, so a new probe must be `git add`-ed in
  the same round or the gate reports `FAIL (untracked: ...)`. Probes compile outside the Lake
  module graph, so **no probe can import another** — shared objects are re-derived verbatim.

## Cross-stage sequencing

- **`559` is a TM⁺ task, not TM⋆** (its directory name is a legacy misnomer). `(P0a)` is `833`,
  **landed**; `(P0b)` is `854`+`859`, **closed both ways**, so (n1)–(n2) survive at ZTime only as
  restatements — (n2)'s rigidity schema `▷ψ⁻ ↔ ψ⁻` is `ofutP_of_pastDet`, its companion is
  `ofutP_of_futDet` — while (n3) is answered negatively at Base/Dense. `(P0c)` is unaffected
  (invariance, not definability). `(P0d)` (`LC_n` in `▷`-form at ZTime) is an L⁺ question by
  `openValidIn_ztime_iff_tr`, still settled by the forward-splice argument `559` names.
- **`559` is not to build the proof system** — its own constraints forbid changes under
  `FormalSystem/`. That is `856`, now **ungated**: nothing for it to do at ZTime/RTime, but `859`
  confirms genuine expressive content at Base/Dense, so no completeness statement about L^▷ is
  stateable until it lands. Its three acceptance baselines are `559`'s: soundness over the class,
  conservativity over TM⁺ in both directions, and collapse under `Determined`.
- **Do not open `(P2)` while `761` is live** — coordination, not the gate: `(P2)` and the
  certificate line's agreement lemma target the same mathematics from two directions. Whichever
  front reaches it first states it in reusable form and the other cites it.
- **The binding obstruction on the completeness front is closedness of the canonical bundle**
  (`559` item (c)), not `(P1)`. PS/US give paste-closure, MF translation-closure, and nothing
  gives closedness. The cure of record is `LC_n` plus progress measures in the state.
- **Stage 2's one invisible collision** is the one-line import in
  `FormalSystem/Semantics/Presheaf.lean`, which no task declares. Batch only tasks already
  serialized by a dependency edge, and re-run `lake build` after each aggregator edit.
- **Stage 3**: `803`/`804` both touch `Verified/Termination/SubformulaProperty.lean` and serialize
  inside one batch — the repository's largest rebuild cost (1103s on a full guarded build). `829`
  is a different lever and does not serialize with them.
- **Stage 4**: `411`, `412` and every algebraic task declare an empty or absent `file_scope` —
  scope them at plan time before running any wave concurrently. The spine's head is clear (`428`'s
  one edge is discharged); it starts at its Stage 0 scope ruling.

## Not scoped as tasks

**Strong completeness over ℚ-time**: weak completeness is done (`derivable_of_validQTime`), but
compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time — Cantor gives an
order isomorphism, not a group one. Unlike Discrete and Dedekind it is not known to be impossible.
**Genuine `Set Formula` strong completeness** for Base and Dense: its gate, the shift-set
representation theorem, is passed, but the ultraproduct work behind it is unfiled.
**Formalizing `859`'s collapse step** (GHR Lemma 12.4.2 over `ℚ`) would discharge the hypothesis
`ofut_not_plusDefinable_of_deltaProp_inexpressible` carries; the frame to build it on is
`colourFibre`.

`app:gluing` is live in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and proved in
full generality (`FormalSystem/Semantics/Gluing.lean`). `app:Structure` and
`app:presheaf-dictionary` are **cut** — treat a cut clause as a specification to implement, never
as a theorem to cite.

## Maintenance

Hand-curated: completed items are removed by hand when a stage is revised; the durable record is
`specs/CHANGE_LOG.md` and `specs/archive/`. Update the batches when `/task --expand`, `/spawn` or
a dependency change alters the graph, and treat any claim here that no check can reproduce as a
defect in this file rather than a fact about the tree.

`roadmap-integration.sh --regenerate` is safe against this file: it retains every `## ` section
byte-for-byte **except** the run-order section (`## Run these next` — the first holding a fenced
`/orchestrate` block), whose body it round-trips, stripping the generated coverage appendix and
appending a fresh one. `/orchestrate`'s conclusion stage runs it as a mandated step, so do not
delete the appended block by hand.

**THE ONE WAY TO LOSE AUTHORED WORK HERE.** `strip_coverage_appendix` stops reading at the
`**Coverage appendix (uncovered tasks)**:` marker and discards everything after it *within the
run-order section*. Keep authored content above that marker, and leave the appendix last in its
section.

`--prune` reaches only the run-order section and drops terminal tasks from run lines; it is kept
out of unattended runs because it removes content outright. The decidability inventory (PROVED /
NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree by
`scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `FormalSystem/Metalogic/Independence/README.md` — the fourteen underivability and undefinability results
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
