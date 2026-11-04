# Roadmap

*Open work only, hand-maintained. This file is batch ordering and the rulings that gate it —
nothing else. The mathematics and the (C)/(S)/(W) verdict table live in
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` (the authority); per-task detail in
`specs/TODO.md`; finished work in `specs/CHANGE_LOG.md` and `specs/archive/`.*

**The aim is `Decidable (PlusValidZTime φ)` — decidability of L⁺ over discrete time.** Stage 1 is
that front and preempts everything else for agent time. Stages 2–4 are subordinate.

## Rulings in force

Each is a user ruling or a recorded decision an agent may not override. The argument for each
lives in the cited record, not here.

- **Decidability before completeness** (2026-11-02). Deciding validity makes the valid set r.e.,
  and Craig then gives a recursive axiomatization — so Stage 1 settles `559`'s `(P1)`.
  Completeness the other way yields only r.e.-ness. Caveat: Craig buys *an* axiomatization, not a
  natural one.
- **The pivot has fired** (2026-11-02). `761` is blocked on open mathematics, not on a ruling, so
  the subordinate front runs in parallel rather than waiting. The ordering above is unchanged.
- **The object language is L^▷; the Stage 1 retarget is gated, not decided** (2026-11-04). L^▷ is
  already built at `FormalSystem/OpenLanguage/` (1,611 lines, sorry-free, no proof system) as a
  separate inductive with `ofPlus : PlusFormula → OpenFormula`; that embedding plus `⊡φ ↔ ▷◁φ`
  *is* the absorption of L⁺, a theorem rather than a migration.
- **`⊡` stays primitive.** "Definable" means a proved biconditional with the primitive retained.
  Eliminating it would change `⊡`'s truth conditions off the regular class (the `←` half needs
  `[F.IsRegular]`) and discard the decidability front's one working anchor
  (`stab_mem_tpOf_iff_cell`, one bit per cell).
- **No constructor is added to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, and L⁺ is not
  renamed.** Absorb-and-rename is REFUSED: mutating that inductive would turn
  `plus_incomplete_base`, `blc_not_plusDerivable_base` and `not_plus_complete_base` into
  statements about a different language. L⁺ stays an embedded sub-language.
- **`854` HAS RETURNED, and the verdict is SPLIT BY FRAME CLASS** (report
  `854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`).
  - **At `.ZTime` and `.RTime`: POSITIVE.** `▷`/`◁` *are* L⁺-definable, uniformly in their
    argument — a translation `tr` with `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)` at every
    model, world and time. The elimination `▷(α ∨ β) ↔ α ∨ ⊡β` is compiled-live; the paper half
    is Gabbay separation (GHR Thm 10.2.9 over ℤ, Thm 10.3.20 over Dedekind-complete flows).
  - **At `.Base` and `.Dense`: OPEN, obstruction located.** The only general `▷`-elimination goes
    through separation, and U/S is **not separable over ℚ-time** (separation ⇒ expressive
    completeness, GHR Thm 9.3.1; U/S not expressively complete over ℚ, Rabinovich 2014). ℚ is a
    `TemporalOrder`, so no translation obtained this way is valid at `.Dense`/`.Base`.
  - **The Stage 1 retarget is therefore answered negatively at ZTime, at no further cost**: over ℤ
    every L^▷ formula *is* an L⁺ formula under an effective translation, so there is no expressive
    gain to retarget onto. This is an expressiveness statement only — no decidability or
    completeness claim.
  - **Spend nothing further on a ℤ-time separation.** `sinkFrame` and every `.ZTime` frame are
    excluded as separators: on every ℤ-time frame `▷φ` coincides with an L⁺ formula. A negative
    answer, if one exists, lives on a non-Dedekind-complete duration (ℚ first, ℚ ×ₗ ℤ second).
  - New validity worth recording: `▷φ⁺ ↔ ⊡φ⁺` for pure-future `φ⁺` (`ofutP_of_futDet`), on every
    regular frame; the rigidity companion is `ofutP_of_pastDet`.
- **The Base/Dense open item is `859`** — the follow-on the verdict's R3 proposed, now filed and
  `[RESEARCHING]`. It runs the negative route (a ℚ-time bisimulation separating a Stavi/`γ_π⁺`-type
  candidate) against the positive one (a `▷`-specific elimination avoiding full separation). A
  precisely located obstruction is a complete outcome. **`856` is gated on it.**
- **L^▷ work stays confined** to `833`, `855`, `856`, `859`, and no `▷`/`◁` clause is added to
  `clSig`, `LocalRun` or `Anchored`.
- **Gate asymmetry.** `(P1)` is the gate at Base/Dense/RTime, where its r.e. status is open with a
  located obstruction. At ZTime it is already settled affirmatively *on paper* (`559` item (k)),
  so `559`'s `(P2)` is gated on `833` and `(P0b)` alone, **not** on Stage 1. What Stage 1 adds at
  ZTime is a constructive settlement.
- **Stage 1 runs R1 (the gluing route) alone; there is no fallback.** `734` (R2, mosaics) is a
  *consumer* of R1, not an alternative — deciding mosaics presupposes deciding `⊡`. Nothing on
  the critical path may be gated on it.
- **Presentation (a) for `761`** (`819`): the set-valued per-state datum in maximum-certified form
  (`D` over `Q × ClType φ × K`, `ladderRealized` the fibre equation). **No tuple index is to be
  stated at any parameters**; `K` is a carrier coordinate whose parameters are outputs of the
  counter-lift lemma.
- **Route B, over `cohBi`** (`815`): the certificate is sufficient at the label level over the
  strict-since relation (`realizes_of_certAdm_cohBi`). The two-sided claim for `coh` is refuted —
  **no backward propagation theorem is ever to be claimed for `coh`**. Both arms stay existential.
  Route A (generalized-Büchi nonemptiness) is not to be entered without a decision record.
- **What no path changes.** Completeness is gated by closedness of the canonical bundle (`559`
  item (c)) and by `(P1)`; decidability by `852`'s agreement lemma. `▷`/`◁` supply no closure
  principle and no decision procedure. The language extension decides *where to look for an
  engine*, never closes either gap.

## Run these next

```bash
/orchestrate 859 --research --lit   # THE LIVE GATE: is ▷ L⁺-definable at Base/Dense? 854 answered ZTime/RTime positively and left this as the single open item. Gates 856 and the Base-class language ruling
/orchestrate 833                    # the L^▷ keystone, ~40 lines of transcription — AFTER 761's current cycle clears docs/theorem-index.md, never concurrently
/orchestrate 855 --hard --lit       # the one-sided ▷/◁ transport against the five-row refutation table — its own cycle (collides with live 761 on specs/evidence/ and check-evidence-probes.sh)
```

**`761` is at `[IMPLEMENTING]` 24/37 (plan v11, Phase 11.12 next) — do not batch anything that
shares its scope.** Its `file_scope` is the widest in the repository (the whole `RaySummary`
library set, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`,
`scripts/check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/`, `specs/state.json`,
`specs/TODO.md`), so **`833`, `855`, `852`, `853` and `763` all serialize behind it**. That
serialization is correct and must not be worked around. `859` collides with nothing.

**`761`'s open core is `852`, with `853` beside it.** `852` is the model-level pumping lemma for
`tpOf` along a ladder path — hit independently in three implementation rounds, costed by no phase
of any plan version, so it must be **authored rather than cited** (citing `prodPre_periodic`
closes a cycle rather than discharging one); its obvious shape is refuted and compiled
(`ladder-splice-type-refutation.lean`), and it waits on `855`. `853` is the Phase 11.8 insertion
cascade — both names gated on a single owed construction, its obvious route refuted rather than
absent, with no insertion/lengthening walk constructor anywhere under `FormalSystem/`.

**Do not dispatch `836`, `838`, `844`, `849`, `850` or `851`.** That chain is spent: `850`/`849`/
`844`/`851` are `[COMPLETED]`, `836` is `[BLOCKED]`, `838` is `[PARTIAL]` on a framing its own
successors measured false. Re-planning this area from `838`'s two-sided framing is barred — read
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
# Stage 1 — L⁺ decidability; run to exhaustion before anything below
/orchestrate 855 --hard --lit    # PATH A measurement 2 — its own cycle, never with 761
/orchestrate 852 --hard --lit    # the open core: the tpOf pumping lemma, authored not cited. Waits on 855
/orchestrate 853 --hard --lit    # the Phase 11.8 insertion cascade. Shares LadderAgree.lean with 761 and 852
/orchestrate 837                 # Challenge-statement repair; barred from any implement dispatch by Statement Fidelity
/orchestrate 763 --hard --lit    # the lift and the Decidable (PlusValidZTime φ) corollary — waits on 761
/orchestrate 714,781 --hard      # sliced-certificate internals
# Stage 2 — the L^▷ front (Path A), then supporting semantics and metalogic
/orchestrate 859 --research --lit   # the Base/Dense open item left by 854. Gates 856 and the Base-class language ruling
/orchestrate 833                    # land ⊡φ ↔ ▷◁φ. Shares docs/theorem-index.md with live 761
/orchestrate 856 --hard             # the L^▷ proof system. HARD-GATED: unnecessary at ZTime/RTime (854), undecided at Base/Dense pending 859 — do not enter
/orchestrate 664,559,570 --lit      # corpus ingest, then TM⁺ completeness rounds and the C3 open question
/orchestrate 830 --hard             # Γ-generalize decidableValidZTime; does NOT advance the L⁺ aim
# Stage 3 — datasets, examples, documentation, hygiene
/orchestrate 847,848             # external-source-store pair: phase commits drop source-store paths
/orchestrate 845                 # name the typst-sync gate as a refusal cause — waits on 839
/orchestrate 803,804,829         # build-cost front: SubformulaProperty elaboration, fan-in, .lake/build CI cache
/orchestrate 298,282,296,231,219 # the dataset chain behind the c7 labeling bug
/orchestrate 178,604             # worked Examples/ pipeline and zstd .jsonl support
/orchestrate 743                 # doc gate: typst-sync Check 1 namespace resolution
/orchestrate 751,787             # file_scope backfill for the overlap gate; unguarded .lake reader audit
/orchestrate 777,779,780,816     # commit-path and plan-compliance records; 816 waits on 777
/orchestrate 772,783             # jq re-serialization of formatting-sensitive records
/orchestrate 753,774             # conclusion-stage null-resolution drops, refuted-REASON recording
/orchestrate 857,858,810,842     # agent-system defects: handoff-validation crash, --audit-verdict argv overflow, gate16, defect recording
/orchestrate 768                 # lean-challenge-snapshot — separate cycle from 842 (shares the script)
/orchestrate 817,818             # phantom-row inventory and directory-rollup tables
/orchestrate 729                 # purpose-written .title fields so TODO.md stops rendering descriptions
/orchestrate 832                 # local-disk reclamation (user decision on data/'s .partial files)
/orchestrate 257                 # only once the Stage 0 token exists
# Stage 4 — the long fronts
/orchestrate 481 --hard          # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: the Log(all) = Log(ZTime) ∩ Log(Dense) dichotomy
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — needs 428's scope ruled
/orchestrate 430,412,482 --hard --lit    # the spine's terminus
/orchestrate 502,497 --research --lit    # the STSA literature gate, then the G-operator gap
/orchestrate 498,499,500 --hard  # the representation's two sides and their reconciliation
/orchestrate 125,501,543 --hard  # the Jónsson–Tarski capstone, Until/Since on STSA, MF correspondence
/orchestrate 177                 # last in the programme: README, docs/ and docstring polish
```

Each line is one invocation. Batches are dependency-inclusive — the engine re-derives eligibility
every cycle, so a batch holding both a blocker and its dependent is correct. `MAX_TASKS` is 8; the
work-cycle budget is per task, per invocation (5 default, 13 under `--hard`), so **re-run the same
line until every member reports terminal**. Shared file scope serializes a batch rather than
breaking it; a task with no declared `file_scope` is invisible to the overlap gate (the blindness
`751` remediates). See `.claude/context/patterns/batch-orchestration-guardrails.md`.

## Stage 0 — User rulings (no agent may transition these)

- [ ] Rule on **127** and **128** (time addition, interior operator): long-standing abandonment
      candidates, antagonistic to the termination work Stage 4 depends on
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one edge (`465`) is discharged and its `blockers` says "paused
      at 4/5 cycles, NOT blocked", so the marker is mis-set: `/revise 428` to add phases for its
      four residual hypotheses, or `/spawn 428` to split them out
- [ ] Give **785**, **813**, **814** and **822–827** a disposition — frozen like the seven, or
      re-sited. All nine declare `agent-system/**` paths absent from this repository
- [ ] Rule on **807**'s positive verdict: `(q S ⊥) → ⊡(q S ⊥)` characterizes backward determinism
      over regular `ℤ`-frames, making the know-time-do-not-forget family a candidate reduction
      target. Options: (A, recommended) keep Stage 1 moving and scope the transfer question as its
      own task with the HV89/HVV PDFs in hand; (B) halt Stage 1 until settled; (C) record the
      probe only

**713** is held by ruling (2026-10-03): its argued CTL⋆ 2EXPTIME lower bound is a citable ceiling
with no consumer. **734** is `[HOLD]`; only the paywalled *Handbook of Modal Logic* ch. 11
§§5.10–5.11 (Hodkinson & Reynolds, pp. 655–720) remain, confirmed absent from the local Zotero
library. Reactivation condition: `specs/literature-index.json#hodkinson_2006.hazard`. Acquiring it
lifts a hold; it does not advance the aim.

## Not batched, and why

- **127, 128** await Stage 0 rulings; **713**, **734** are `HOLD` by ruling.
- **730, 741, 752, 767, 768, 769, 770 are frozen: undispatchable from this repository.** Each
  names an edit target resolving only under the agent-system source store
  (`~/.config/nvim/agent-system/**`; this repo's `.claude-extensions.json` declares no
  `source_dir`, so the path is not derivable from it). Migration is tracked in the source store's
  own task space (`~/.config/nvim/specs/390_migrate_mis_sited_agent_system_tasks`), not here.
- The frozen set is **enumerated by that migration record, not derivable from `file_scope`**:
  753, 772, 774, 777, 779, 780, 783 also edit the source store but are batched above by ruling,
  each editing at the mirroring source path and redeploying afterwards.
- **Thirteen more have the frozen shape without a disposition: 785, 813, 814, 822–827, 834/835,
  840/843** (Stage 0 item above). They collide with one another too — 785/813/814 share the lean
  extension's `index-entries.json`; 822/827/835 share core's; 834 shares
  `docs/architecture/orchestrate-state-machine.md` with 823.
- **834 is worth reading even if its disposition goes against it**: an `[IMPLEMENTING]`
  re-dispatch fires even when the handoff's recorded next action was a plan revision, because the
  blocker-research aux chain is a dead drop with no receipt — `orchestrate-cycle-plan.sh` clears
  `aux_pending[t]` at emission time, so a fork that never writes `.blocker-research.json` leaves
  no pending entry, no `plan-revision` row is ever emitted, and the task falls back into the
  known-blocked phase. `MAX_BLOCKER_ESCALATIONS` never fires. This is the mechanism behind `761`'s
  repeated re-entries into blocked phases.
- **784** tracks the freeze and is `[BLOCKED]` on the migration. It owns the only part this repo
  can do: verify the records in the source store, delete them from `specs/state.json`, regenerate
  `specs/TODO.md`, and drop this section.
- **Completed tasks awaiting archival** sit in `active_projects` and read the open count high in
  any check that does not filter on status. Run `/todo`.

**Reading the coverage appendix.** It lists *ready* tasks absent from **`## Run these next`**
alone — never computed from `## Next batches` or this section. A task batched in Stage 1 and
deliberately kept out of the immediate run list appears there correctly; its presence is not a gap.

## Do not re-attempt

- **Four tuple-shaped index shapes for `ladderRealized` are refuted on compiled ground**
  (`ladder-cell-refutation`, `ladder-cell-index-obstructions`, `ladder-residue-index-refutation`,
  `ladder-joint-index-refutation`). The tuple-widening line is spent; **no seventh coordinate is
  to be proposed.**
- **Gate 8 is sidestepped, not passed** — the `stab`/`box` clauses are present but unexercised.
- **`HasForwardSlack` is a genuine regime, not a missing lemma.** The upper residual inequality is
  refuted by a climbing-register ladder path (`ClimbWitness` in `LadderChain.lean`); there is no
  Drift-level invariant to isolate. **Do not re-attempt route (a).**
- **The unconditional `buildTableau_isSome` is FALSE by construction** at the engine's
  `maxBranches := 50000` guard, at any fuel. The whole decidable-branch-gate family collapses to
  `false` on any branch that mints a world, so `429` is a redesign, not a repair.
- **ℤ-time validity of L is already decided** (`Compression.decidableValidZTime`), so the
  deliverable is the four-class `isValid` biconditional, not a first decidability theorem.
- **`481`'s obstruction is precise**: `universeClosedAt_signedUniverse_of_propositional` is not
  stateable, because `UniverseClosedAt`'s clause 1 universally quantifies an unconstrained `ord`
  while every route through the time coordinate carries `OrdTimesKnown b ord`, non-removable
  in-source.
- **`482` must re-verify its own anchors first**: `Verified/Refutation/` does not exist and
  `ProofExtraction.lean` holds no verifier declaration.
- On any `C16` unused-binder red, prefer the signature edit to a `scripts/nolints.json` entry,
  check call sites first, and **do not run `lake exe runLinter --update`**.
- **A verification claim is only as wide as the flags it was made under.**
  `check-module-invariants.sh --emit-inventory --check` exits 0 while the bare invocation exits 1;
  prefer the bare form whenever the question is "is the tree green". The warning budget's counts
  are a ceiling that may only decrease — never reach for `--update`.

## Cross-stage sequencing

- **`559` is a TM⁺ task, not TM⋆** (its directory name is a legacy misnomer). Its object language
  is L^▷ by ruling; `⊡φ ↔ ▷◁φ ↔ ◁▷φ` holds on every regular task frame, choice-free, so `⊡` is
  definable and no L⁺ result is traded away. `(P0a)` is `833`, `(P0b)` is `854` — **returned**,
  class-split, so `559`'s (n1)–(n2) survive at ZTime only as restatements: (n2)'s rigidity schema
  `▷ψ⁻ ↔ ψ⁻` is `ofutP_of_pastDet`, its companion `▷φ⁺ ↔ ⊡φ⁺` is `ofutP_of_futDet`. (n3) stays
  open at Base/Dense. `(P0c)` is unaffected (invariance, not definability). `(P0d)` (`LC_n` in
  `▷`-form at ZTime) is now an L⁺ question by `openValidIn_ztime_iff_tr`; the forward-splice
  argument `559` names is still the way to settle it.
- **`559` is not to build the proof system** — its own constraints forbid changes under
  `FormalSystem/`. That is `856`, now gated on `859` rather than `854`: there is nothing for it
  to do at ZTime/RTime, and its rationale survives only at Base/Dense. No completeness statement about L^▷ is
  stateable until it lands. Its three acceptance baselines are `559`'s: soundness over the class,
  conservativity over TM⁺ in both directions, and collapse under `Determined`.
- **Do not open `(P2)` while `761`/`836` are live** — the reason is the coordination note, not the
  gate: `(P2)` and the certificate line's agreement lemma target the same mathematics from two
  directions. Whichever front reaches it first states it in reusable form and the other cites it.
- **The binding obstruction on the completeness front is closedness of the canonical bundle**
  (`559` item (c)), not `(P1)`. PS/US give paste-closure, MF translation-closure, and nothing
  gives closedness. The cure of record is `LC_n` plus progress measures in the state.
- **Stage 2's one invisible collision** is the one-line import in
  `FormalSystem/Semantics/Presheaf.lean`, which no task declares. Batch only tasks already
  serialized by a dependency edge, and re-run `lake build` after each aggregator edit.
- **Stage 3**: `803`/`804` both touch `Verified/Termination/SubformulaProperty.lean` and serialize
  inside one batch — that module is the repository's largest rebuild cost (1103s on a full guarded
  build). `829` is a different lever and does not serialize with them.
- **Stage 4**: `411`, `412` and every algebraic task declare an empty or absent `file_scope` —
  scope them at plan time before running any wave concurrently. The spine's head is clear (`428`'s
  one edge is discharged); it starts at its Stage 0 scope ruling.

## Not scoped as tasks

**Strong completeness over ℚ-time**: weak completeness is done (`derivable_of_validQTime`), but
compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time — Cantor gives an
order isomorphism, not a group one. Unlike Discrete and Dedekind it is not known to be impossible.
**Genuine `Set Formula` strong completeness** for Base and Dense: its gate, the shift-set
representation theorem, has been passed, but the ultraproduct work behind it is unfiled.

`app:gluing` is live in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and proved in
full generality (`FormalSystem/Semantics/Gluing.lean`). `app:Structure` and
`app:presheaf-dictionary` are **cut** from the paper. Treat a cut clause as a specification to
implement, never as a theorem to cite.

## Maintenance

Hand-curated: completed items are removed by hand when a stage is revised, and the durable record
is `specs/CHANGE_LOG.md` and `specs/archive/`. Update the batches when `/task --expand`, `/spawn`
or a dependency change alters the graph, and treat any claim here that no check can reproduce as a
defect in this file rather than a fact about the tree.

`roadmap-integration.sh --regenerate` is safe against this file. It retains every `## ` section
byte-for-byte **except** the run-order section (`## Run these next` — the first section holding a
fenced `/orchestrate` block), whose body it round-trips, stripping the previously-generated
coverage appendix and appending a fresh one. `/orchestrate`'s conclusion stage runs it as a
mandated step, so do not delete the appended block by hand — the next run re-adds it.

**THE ONE WAY TO LOSE AUTHORED WORK HERE.** `strip_coverage_appendix` stops reading at the
`**Coverage appendix (uncovered tasks)**:` marker and discards everything after it *within the
run-order section*. Keep authored content above that marker, and leave the appendix last in its
section.

`--prune` reaches only the run-order section and drops terminal tasks from run lines; it is kept
out of unattended runs because it removes content outright. The decidability inventory
(PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree by
`scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
