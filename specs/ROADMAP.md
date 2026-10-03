# Roadmap

*Derived from `specs/state.json` and `specs/TODO.md`'s Task Order (2026-10-03). Open work only;
completed work is recorded in `specs/CHANGE_LOG.md` and `specs/archive/`. Reference material —
the BX axiom layers, the irreflexive truth semantics, the canonical-model and quasimodel
construction — lives in `README.md`, the module docstrings and `typst/BimodalReference.typ`,
not here; it was removed from this file on 2026-10-02 as duplicative (and, for the axiom counts,
stale against `README.md`). Recover it from git: `git log --follow -- specs/ROADMAP.md`. Since the
2026-10-02 revision, the interval-site/behavior-presheaf layer
(`FormalSystem/Semantics/Presheaf/{Site,Behavior}.lean`, task 563, with the Germs clause
`Beh.germEquiv : Beh F 0 ≃ F.WorldState`) and the omega-sequence round (task 718, five probes
under `specs/evidence/seam-gluing-ray-product/`) have landed; this revision reconciles the file
with them per task 721's review
(`specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md`, cited below as
"the scope spec").*

## Fronts

| Front | Open tasks | Delivers |
|---|---|---|
| User decisions | — | Status calls on the parked records, and the Hugging Face token |
| **Gluing route to decidability** | **719, 720, 721, 711 (revised per the scope spec, Section B); 709 if Section D is adopted** | **Possible worlds as all ways of gluing a backward ray to a forward ray; the stab fibre (keystone proved under `[F.IsRegular]`); decidability by that means. 718 completed 2026-10-03** |
| L⁺ sliced certificates | 705, 706, 710, 714, 716 (709 moves to the gluing route if the scope spec's Section D is adopted; it stays here until then) | The landed incompleteness theorems and their library landing, the liveAt defect |
| Categorical structure | 564, 565, 566, 567, 616, 617, 618 | Every remaining clause of `app:presheaf-dictionary` (the skeleton, task 563, landed 2026-10-03) |
| Publication and data | 178, 231, 282, 296, 298, 604, 219, 177 | Worked examples; the dataset pipeline; the final docs pass |
| Metalogic questions | 543, 559, 570, 664 | MF rigidity; TM⋆ completeness; the C3 question; one literature source |
| TM tableau spine | 464, 465, 428, 429, 410, 411, 430, 412, 482, 481 | Totality, the truth-lemma repair, the semantic lift, and the four-class `isValid` biconditional. Z-time validity of L is **already decided** by another route -- `Compression.decidableValidZTime` (`FrameClass.ZTime`, `Formula` with no `⊡`, empty premises) -- so the spine's deliverable is the four-class statement, not the first decidability theorem |
| Algebraic representation | 502, 497, 498, 499, 500, 125, 501 | The Jónsson–Tarski representation theorem for TM |
| Parked | 127, 128, 257, 711, 712, 713 | Nothing until a user ruling (see Phase 0) |

51 open tasks. Each phase below is one `/orchestrate` batch, or a
named sequence of them where declared `file_scope` values overlap — a batch whose members share
a file is deferred every cycle by the admission gate and makes no progress (see
`.claude/context/patterns/batch-orchestration-guardrails.md`).

The live front is **Phase 1, the gluing route** — made the programme's priority by author
directive on 2026-10-02, to be carried through research, design **and** implementation rather
than left as a research note. Phases 2 and 3 remain live beside it and feed it. The 2026-09-08
author directive that deferred decidability and open mathematics has been overtaken by the L⁺
programme (tasks 695–716, all dispatched since), and is not restated here.

---

## Phase 0: User Decisions (High Priority)

**Status**: Live — user-only. No agent may transition these.

- [ ] Rule on task 712, the L⁺ sliced finite model property: its statement is machine-checked
      FALSE (`not_sliced_complete`, `not_finite_width_fmp`), so the record is a refutation, not
      an open statement. Moving it to a terminal status is a programme-level call (Task 712).
      *Evidence added 2026-10-03 (scope spec, Section A):* its dependency edge on 711 gated
      proving a refuted statement and is now meaningless -- removable by `/revise 712`; closing
      as a refutation record waits on the library landing of Section F. Not decided here
- [ ] Rule on task 711, the ω-automata determinization substrate: it was filed only to make the
      blocker visible, and the route it names is now closed, so the honest outcome is ABANDONED
      rather than completed (Task 711). *Evidence added 2026-10-03 (scope spec, Section B):* the
      718 decision's condition for reviving it ("after R1's falsification probes 1-3 land") is now
      MET, and the probes showed a universal, complementation-shaped device is necessary
      (`Probe718PathQuantifier.exists_ne_stab`) without showing Safra/Piterman specifically is; a
      third option, REVISE (re-describe as the universal-summary substrate for the `⊡` fibre check,
      keep blocked pending device selection), is on the table beside ABANDON. Newly answerable;
      not decided here
- [ ] Rule on task 713, the CTL⋆ 2EXPTIME reduction: optional, filed not scheduled, nothing
      depends on it; abandon or keep as a write-up note (Task 713). *Evidence added 2026-10-03
      (scope spec, Section C):* 718, 719 and 721 all cite its ARGUED lower bound as the sanity
      ceiling on any proposed decision procedure, so it is load-bearing as a check even unproved;
      no upper-bound claim may be landed from it. Not decided here
- [x] **RULED 2026-10-03 by the user: Option A -- library landing.** The Success Metric "every
      refutation lives in `FormalSystem/`" stands as written: tasks 706 and 710 land
      `Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` as `FormalSystem/`
      theorems, and 720 re-points citations to library names. Option B (accepting the CI-guarded
      `specs/evidence/` collection as the home of refutations) is **rejected**. This supersedes
      the autonomous cycle-1 adoption in task 721, which was explicitly not a user ruling; the
      ruling is now the user's own (Tasks 706, 710, 720; scope spec, Section F)
- [ ] Rule on tasks 127 and 128, the object-language extensions (time addition, interior
      operator): long-standing abandonment candidates, antagonistic to the termination work the
      tableau spine depends on (Task 127, Task 128)
- [ ] Supply the Hugging Face account and token that task 257 is blocked on (Task 257)

**Blocked by**: none
**Run**:
```
# user-only; no orchestration command applies
```

---

## Phase 1: The Gluing Route to Decidability (Highest Priority)

**Status**: Live — the programme's priority front by author directive, 2026-10-02. Task 718's
round is complete (2026-10-03): five sorry-free probes under `specs/evidence/seam-gluing-ray-product/`,
all guarded by `scripts/check-evidence-probes.sh`. To be carried through **research, design and
implementation**, not filed as a research note.

**The idea.** Define a possible world as a way of **gluing** a sequence of next states to a
sequence of states from which to have arrived — and take *all* ways of doing so. A world is then
a pair of rays agreeing at a seam, and the world-set is the fibre product
`{backward rays into s} ×ₛ {forward rays out of s}` over the seam state.

**Why this is not a new semantics but a reading of the landed one.** Three facts, each verified
against source:

1. `StabClause.stab_clause` in `FormalSystem/Semantics/TruthClauses.lean` reads
   `T M τ t (stab φ) ↔ ∀ σ : WorldHistory F, τ.state t = σ.state t → T M σ t φ`, with the
   docstring "`⊡φ` holds iff `φ` holds at every world history in the same state at the current
   time". The hypothesis `τ.state t = σ.state t` **is** the seam, so `⊡` already quantifies over
   exactly the re-gluings at the present state. This is `⊡`, **not** `□`: the `box` clause carries
   no state-agreement conjunct and is the full S5 history quantifier.
2. `FrameOver.mem_HF_iff_adjacent` (`FormalSystem/Semantics/IntNormalForm.lean`) establishes that
   over ℤ, `H_F` **is exactly the bi-infinite step-paths**. Possible worlds already *are* paths.
3. `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` states the consequence in its own
   docstring: a decision procedure "cannot quantify over `H_F` directly … there are uncountably
   many", and supplies the finite presentation instead — a `BiLasso` of three lists, **`back`,
   `mid`, `fwd`**. That is the gluing, already landed in finitely presented form, and it is the
   route the stab-free decidability work actually took.

**The precise question this phase exists to answer.** The `BiLasso` presentation glues a *single*
backward list to a *single* forward list. `⊡` needs the whole fibre over the seam, and
`not_finite_width_fmp` proves no class with finite per-time fibres is complete. So the question is
whether `back`/`fwd` can range over **path sets** — root paths of a finite class graph — rather
than single lists, and whether the resulting `⊡` check stays decidable. That is exactly the
"infinite fibres (root paths of a finite class graph)" successor shape the refutation record
demanded, so the demand and this idea are one object, not two.

- [x] Research and rank the routes: whether each landed refutation is *genuinely* two-sided or
      merely *stated* two-sidedly, re-derived over ω-sequences; the ray layer's status (colimit of
      bounded sections, hence Saturation-dependent, versus separate primitive versus a
      `PartialHistory` with a ray domain); and the ω-automata question, which collapses into the
      infinite-fibre question rather than sitting beside it (Task 718) *(Completed: Task 718,
      2026-10-03 — verdicts: the ω move is a decomposition, not a re-basing; the ray layer is a
      `PartialHistory` with a half-line domain, no colimit needed; the ω-automata question became
      the universal-summary question, see below)*
- [x] The **stab-fibre characterisation** is PROVED at probe level, not open: `Probe718.seamFibreEquiv`
      / `plusStab_iff_rays` (general frame) and `seamOmegaEquiv` / `plusStab_iff_omega` (over ℤ),
      every one under the hypothesis **`[F.IsRegular]`** discharged through `TaskFrame.comp` plus
      the reflection convention — not unconditional. Task 719's job is to **promote** them with
      that hypothesis verbatim (Task 718) *(Completed: Task 718, 2026-10-03 — keystone proved
      under `[F.IsRegular]`; `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean`)*
- [x] Filtration assessed and CLOSED for ℤ-time: no truth-lemma-bearing filtration can land on a
      finite world type over ℤ — `Probe706.no_finite_carrier_sat` (`[Finite F.WorldState]`;
      `⊡`-free witness, a fact about TM itself) and `Probe710.not_finite_width_fmp` (`[Finite W]`;
      `⊡`-bearing witness, L⁺-specific). Dense durations are the only residue (Task 718)
      *(Completed: Task 718, 2026-10-03 — filtration closed for ℤ)*
- [x] The ω-sequence re-derivation of the refutations: both are genuinely two-sided over
      ω-sequences, and the forward finite-graph `⊡` summary holds on the `Bool` fixture
      (`Probe718FiniteGraph.will_iff_allPathsMeet`); the **backward dual is not separately proved**
      (symmetric fixture, recorded exclusion), and the existential summary provably diverges
      (`Probe718PathQuantifier.exists_ne_stab`) (Task 718) *(Completed: Task 718, 2026-10-03 —
      forward factor only; backward dual is experiment E1 below)*
- [ ] Design and implement the ray layer, the seam-gluing operator the paper calls `⌢_z`, and the
      promotion of the **stab-fibre characterisation** into `FormalSystem/` with `[F.IsRegular]`
      verbatim on every promoted keystone declaration (Task 719)
- [ ] Settle the **effective extension theorem** question: whether the binary seam gluing, which
      the live `app:gluing` proves from convexity and the task constraint alone, generalises the
      Tier A effective extension theorem that `BiLasso/Orbit.lean` built only for the bi-lasso
      case. 718 found it REACHABLE with a stated limit (a pair of rays, not an arbitrary
      `PartialHistory`). Worth landing even if decidability stalls (Task 719, deliverable 4)
- [ ] Run the three falsification experiments of the surviving route, cheapest first, before
      anything is funded: **E1** the backward-dual finite-graph probe on a *time-asymmetric*
      fixture (reuse `Probe710.Node`/`Step`; decide `⊡(Pp)` by backward reachability) — the
      phase's first probe, because the finite-width obstruction lives in the backward factor and
      the symmetric fixture cannot see it; **E2** the depth-2 stratification probe; **E3** a
      device-selection probe comparing the candidate universal-summary devices (Safra/Piterman;
      Safraless; MSO over ⟨ℤ,<⟩ plus Büchi; a Ramsey colour) on the `⊡(Fp)`/`⊡(Pp)` shapes
      (Task 719, deliverable 5; or the scope spec's H4 if 719 is not dispatched this cycle)

**Source of record.** The gluing theorem is `app:gluing` in
`~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — **live** in the paper, proved, with
its seam case written as the pasting principle `ρ ⌢_z σ` but **commented out**. `app:Structure`
and `app:presheaf-dictionary` are **cut** from the paper entirely: that material is the author's
own mathematics with the supporting results promised elsewhere, and this repository is where
elsewhere is. Treat cut clauses as a specification to implement, never as a theorem to cite.

**The determinization-funding decision, verbatim** (`specs/718_omega_sequence_decidability_full_lplus/.decisions.json`,
cycle 1): "Revive 711 only after R1's falsification probes 1-3 land, so determinization is funded
on evidence of necessity rather than expectation". The probes landed; **its evidence condition is
met**, and what they showed is necessity of *a* universal, complementation-shaped summary device,
not of Safra/Piterman specifically. Whether 711 is revived, revised, or abandoned is the Phase 0
call above; this file funds nothing.

**Carry this caution.** Gluing does **not** bound the fibre — "all ways" is the largest choice, a
full product. The route concedes infinite fibres and seeks a finite *presentation*, which is the
only move `not_finite_width_fmp` leaves open. And the binary seam case is choice-free while the
*directed* case needs Saturation (`app:gluing`'s footnote supplies the `D = ℚ` counterexample);
an ω-ray built by iterated gluing is a directed colimit, so do not assume the choice-free case.

**Blocked by**: Task 564 (→ 719)
**Topics**: decidability, categorical-structure
**Run**:
```
/orchestrate 719        # after 564's seam gluing lands; 718 and 563 are done
/orchestrate 720        # after 706 and 710 land (Phase 2); collides with 719 on nothing, with 710 on check-evidence-probes.sh
```

---

## Phase 2: L⁺ Sliced Certificates (High Priority)

**Status**: Live — every task is unblocked today except 720 (waits on 706, 710).

What the incompleteness round settled, and what the phase now builds on: the time-sliced
certificate class is incomplete for full L⁺ **and** for the CTL-like fragment, and no
certificate class presenting finite per-time fibres is complete, whatever its clauses. The
obstruction is finite *width* (limit closure plus finite fibres contradicts König) — strictly
stronger than the earlier finite-*carrier* failure. Both are machine-checked but live under task
probes, not in `FormalSystem/` (`Probe710.not_finite_width_fmp`, `Probe706.no_finite_carrier_sat`,
both `WIRED_REPO` in `scripts/check-evidence-probes.sh`, both ℤ-only; the finite-carrier witness
is `⊡`-free and so a fact about TM itself, the finite-width witness uses `⊡` and so is L⁺-specific).
Landing them is read here as **Option A** of the scope spec's Section F — adopted autonomously in
task 721 cycle 1, pending the Phase 0 confirmation above.

- [ ] Fix the `liveT`/`liveAt` non-termination: the landed fixpoint does not return in 300s on a
      4-position total-edge certificate while being instant on self-loop ones. This is a defect
      in shipped, gated code, not an unbuilt feature (Task 716)
- [ ] Land the finite-width refutation as library theorems under
      `PlusSlicedCertificate/Limits/NoFiniteWidth.lean` — `not_finite_width_fmp`,
      `not_sliced_complete`, the core `no_finite_width_sat` with its `[Finite W] [Nonempty W]`
      hypotheses — with the separating witness `Φ := θ' ∧ □(stab F p → ¬ stab ¬ X p)` (Task 710;
      scope spec Section F, Option A)
- [ ] Land task 706's finite-carrier refutations into `FormalSystem/` — `no_finite_carrier_sat`
      (`[Finite F.WorldState]`), `no_ofStep_sat`, `not_finite_carrier_fmp`, with
      `θ_eq_ofFormula` stated so the `⊡`-free status of the witness is on record; they exist only
      under that task's own probes, so no acceptance gate can cite them yet (Task 706; scope spec
      Section F, Option A)
- [ ] Re-point the `FMP/README.md` and `scripts/check-evidence-probes.sh` citations from the two
      `WIRED_REPO` probe paths to the landed library names, or close as subsumed if the landing
      leaves no probe to move (Task 720; scope spec Section F)
- [ ] Record the `trans_refl` verdict: RETAIN — roughly 87 term-level sites across 18 files need
      the self-step. Land the label-level congruences that are the bounded residual (Task 705)
- [ ] Evaluate carrying full labels in the certificate, which would make `posAt` a singleton and
      delete both liveness filters; the question is whether decidability of the check survives
      (Task 714)
- [ ] Finite width ⇒ eventually periodic (finding F4) is **R1's summary step, not a route**:
      718 demoted it to a component of the gluing route, and its premise (finite width) is refuted
      for any complete class. The scope spec's Section D re-sequences it under 719 (add
      dependency 719); if R1 selects an automaton acceptance condition over a Ramsey colour, 709
      closes as a reasoned exclusion with its fallback (restrict to safety/bounded-step `⊡`)
      recorded (Task 709)

**Blocked by**: Task 710 (→ 709); Tasks 706, 710 (→ 720); Task 719 (→ 709, if Section D is adopted)
**Topics**: decidability, incompleteness
**Run**:
```
/orchestrate 716        # first: owns PlusSlicedCertificate/{Live,Check,Examples}
/orchestrate 714 --research   # beside it: declares no file_scope, research-only
/orchestrate 710        # then, in this order -- the three below overlap pairwise
/orchestrate 706        # shares PlusSlicedCertificate.lean + docs/theorem-index.md with 710
/orchestrate 705        # shares scripts/check-module-invariants.sh with 706
/orchestrate 720        # after 706 and 710: re-point the citations (shares check-evidence-probes.sh with 710)
/orchestrate 709 --hard # under the gluing route, after 719 (Section D); not Phase 2's capstone
```
These cannot be batched: 705, 706 and 710 all declare `docs/theorem-index.md`, 706 and 710
both declare `PlusSlicedCertificate.lean`, 706 and 716 both declare
`scripts/certificate-witness-inventory.txt`, and 710 and 720 both declare
`scripts/check-evidence-probes.sh`. Task 709's F4 statement is no longer this phase's substance:
718 demoted it to the summary step of the gluing route (R3, a component of R1), so its two forced
repairs to Hodkinson–Wolter–Zakharyaschev (one-sided live sets in the quasistate, and fulfilment
secured at every live position at once by an idempotent Ramsey colour) are work *for* R1, done
only if R1 chooses a Ramsey colour over an automaton acceptance condition. Do not file a fourth
certificate class first — any class with finite fibres is already refuted.

---

## Phase 3: The Behavior Presheaf (High Priority)

**Status**: Live — task 563 landed 2026-10-03 (`FormalSystem/Semantics/Presheaf/{Site,Behavior}.lean`),
so the clause wave is unblocked.

Each clause below is a clause of `app:presheaf-dictionary` in the PossibleWorlds paper, and each
has a proved hook already in the tree, which is why the cluster is bounded rather than open.

- [x] Promote the presheaf skeleton into the library: the section type `Beh F l`, restriction
      along `Tr p`, functoriality, and the Germs clause (Task 563) *(Completed: Task 563,
      2026-10-03 — `Beh.germEquiv (F) [F.IsRegular] : Beh F 0 ≃ F.WorldState` landed in
      `Semantics/Presheaf/Behavior.lean`)*
- [ ] Prove `app:gluing` for two sections whose germs agree at the seam, plus the two restriction
      identities and uniqueness; the composition step is already proved as `glue_seam` (Task 564)
- [ ] Prove the Totality and Directed Gluing clauses — both wrappers on the fully proved
      `thm:extension` (Task 565)
- [ ] Prove the Determinism clause, `F` deterministic iff every restriction map is injective,
      against `states_eq_of_deterministic` (Task 567)
- [ ] Prove the Reflection clause: `Beh(F) ≅ Beh(F⁻) ∘ ref` (Task 617)
- [ ] Formalize the duration monoid `BD⁺`, its twisted-arrow category, and
      `lem:interval-twisted-arrow` (Task 616)
- [ ] Prove the Possible Worlds clause: `H_F ≅ lim Beh(F)(2x)`, via the existing
      `FrameOver.mem_HF_iff_adjacent` (Task 566)
- [ ] Formalize the path category `Path(F)` and `cor:path-fibration`: `len` is a discrete
      Conduché fibration whose presheaf is `Beh(F)` (Task 618)

**Blocked by**: Task 565 (→ 566); Tasks 564, 616 (→ 618)
**Topics**: categorical-structure
**Run**:
```
/orchestrate 564,565,567,616,617    # the clause wave (563, the skeleton, is done)
/orchestrate 566,618                # the two limits
```
**Scopes were declared on all eight on 2026-10-02**, one module each under
`FormalSystem/Semantics/Presheaf/`, so the admission gate can now serialize them. One hazard
remains and the clause wave above must respect it: every task adding a module to the cluster also
needs a one-line import in the aggregator `FormalSystem/Semantics/Presheaf.lean`, which task 563
owns and which is deliberately **not** in the other seven scopes — putting it there would defer
the whole front every cycle. That line is therefore a shared touch the gate cannot see, so
**run this front in batches of at most two, or singly** — never as one wide wave — and re-run
`lake build` after each aggregator edit. The constraint is recorded in all seven task
descriptions.

---

## Phase 4: Examples, Dataset Pipeline and Final Docs (Medium Priority)

**Status**: Live and independent of every other phase.

- [ ] Expand `Examples/` with the publication-quality worked pipeline: soundness and completeness
      on a concrete formula, plus decidability of the propositional fragment — the fragment that
      is genuinely decidable today (Task 178)
- [ ] Fix the c7 labeling bug at formula ~13750 that causes unbounded memory growth in the
      decision procedure's timeout handling, then regenerate the c7 dataset (Task 298)
- [ ] Re-add the six derived binary temporal operators to the enumerator so they survive
      deduplication (Task 296)
- [ ] Flip complexity-9 generation from stratified to exhaustive by default (Task 282)
- [ ] Add zstd-compressed `.jsonl` support across the pipeline (c7 is already 17G → 153M on disk
      as `.jsonl.zst`) (Task 604)
- [ ] Build the regeneration automation so every dataset rebuild updates its downstream artifacts
      and documentation fields (Task 231)
- [ ] Calibrate baseline difficulty by running bmlogic-bench through at least three LLMs
      (Task 219)
- [ ] Final README, `docs/` and module-docstring polish, gated on 26 dependencies including the
      whole tableau spine (Task 177)

**Blocked by**: Task 298 (→ 231, 282, 296); Task 231 (→ 219); 26 tasks (→ 177)
**Topics**: formula-refactor, dataset-enhancement
**Run**:
```
/orchestrate 178,604        # neither touches the dataset files
/orchestrate 298            # alone: owns DatasetGenerator.lean + data/bmlogic-c7.jsonl
/orchestrate 282,296        # after 298; disjoint scopes
/orchestrate 231            # then the automation, then 219 behind it
/orchestrate 219
```
Task 177 runs last in the programme, not here; it is listed in this phase because it owns the
documentation territory. Before treating 298 as blocked, re-check the line and metadata counts —
a long c7 regeneration was observed running and may have completed.

---

## Phase 5: Metalogic Questions and Literature (Medium Priority)

**Status**: Live — 543 and 559 are unblocked; 570 waits on 568 (completed), so it is runnable.

- [ ] Machine-check the principal MF frame-correspondence rigidity results researched in the
      PossibleWorlds paper repository (six external reports; read them first) (Task 543)
- [ ] Run further verdict-first rounds on the nondeterministic canonical model for TM⋆
      completeness — reports and probes only, no changes to `FormalSystem/` (Task 559)
- [ ] Settle the C3 question: is the domain-restricted consequence relation's logic Burgess–Xu
      without unboundedness, plus S5? An open research question, not an implementation task
      (Task 570)
- [ ] Acquire and ingest the Cmiel–Kuhlmann–Kuhlmann ball-space paper; the corpus has no copy
      (Task 664)

**Blocked by**: none
**Topics**: metalogic, literature
**Run**:
```
/orchestrate 664                      # acquire and ingest first; 543 and 559 use --lit
/orchestrate 543 --hard
/orchestrate 559 --research --lit     # verdict-first; stops after research
/orchestrate 570 --research           # research-only by its own classification
```
Task 543's declared `file_scope` includes `README.md` and `FormalSystem.lean`, which collide with
task 177's; run them in different cycles.

---

## Phase 6: The TM Tableau Spine (Low Priority)

**Status**: Partly blocked. Nine waves from 464 to 482, the longest chain in the programme, and
three of its links are open mathematics. Deprioritized relative to Phases 1 and 2.

Two facts bound this front and must not be re-attempted: the unconditional `buildTableau_isSome`
is FALSE by construction at the engine's `maxBranches := 50000` guard, at any fuel; and the whole
decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch that mints a world.
Task 429 is a redesign, not a repair. The full tombstone list is the C9 register inside
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`.

One fact the spine's own prose does not yet state: `Decidable (ValidZTime φ)` **is proved**, by the
witness-family route, not the tableau —
`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime : (φ : Formula) → Decidable
(ValidZTime φ)` (`WitnessFamily/Compression/Assembly.lean`; `FrameClass.ZTime`, `Formula` with no
`⊡`, empty premises, a `def`, axioms `[propext, Classical.choice, Quot.sound]`). The spine's
deliverable is therefore the **four-class** `isValid` biconditional; it is the only route filed for
Base, Dense and RTime, not the only route to any decidability result.

- [ ] Design and land `gapPotential`, the density coordinate of the termination measure — the one
      genuinely open mathematical question on the totality terminus (Task 464)
- [ ] Repair or replace the `UnorderedSuccessorLabelClosed` residual, the fifth termination
      residual, refuted in-tree at a nonempty universe; a C9 register entry is a complete,
      valid outcome (Task 481)
- [ ] Complete the terminus restatement family at the repaired residuals: the fourteen
      restatements task 433 recorded as a reasoned exclusion (Task 465)
- [ ] Prove engine totality at a quantified branch budget, via the amortized mint-bound route
      (Task 428)
- [ ] Redesign the truth-lemma side conditions — propagate `T(□φ)` to the freshly minted world,
      with its own `RuleSound` obligation (Task 429)
- [ ] Internalize tableau branches and prove the routine rule admissibilities (Task 410)
- [ ] Prove the hard admissibility lemmas for the Until/Since trichotomy and the
      discrete/Dedekind rules (Task 411)
- [ ] The semantic lift: `valid_iff_allClosed`, and with it the `isValid φ fc = true ↔ ⊨ φ`
      biconditional and the four `Decidable (⊨ φ)` instances. Only the sound direction has landed
      (`isValid_sound`); no `isValid`-shaped `iff` is written until it can be proved. The ZTime
      instance has an independent oracle it must agree with — `Compression.decidableValidZTime`
      (ZTime, `Formula`, empty premises) — cross-check L-E3 of the scope spec (Task 430)
- [ ] Prove the refutation core and decidability of provability with its completeness corollaries
      (Task 412)
- [ ] Discharge proof-extraction completeness, eliminating `.extractionFailed` on a genuinely
      closed tableau. `Verified/Refutation/` does not exist, and no verifier declaration exists in
      `ProofExtraction.lean` (the `verifyProof` stub 482's description names is absent from the tree
      as of 2026-10-03; 482 should re-verify its own anchors). OPEN MATHEMATICS, multi-month; must
      not be re-described as engineering (Task 482)

**Blocked by**: Task 464 (→ 465) → 428 → 429 → 410 → 411 → 430 → 412 → 482
**Topics**: decidability
**Run**:
```
/orchestrate 464 --hard --lit   # the open measure question; research-heavy
/orchestrate 481 --hard         # parallel entry, recommended before or alongside 465
/orchestrate 465                # then strictly in chain order, one per cycle:
/orchestrate 428 --hard
/orchestrate 429 --hard
/orchestrate 410
/orchestrate 411
/orchestrate 430 --hard
/orchestrate 412
/orchestrate 482 --hard --lit
```
464 and 481 both fall under `MintBound/`, so they are not batched; 465 (owning `MintBound.lean`)
and 481 (owning `MintBound/ClosureResidual.lean`) are disjoint and may run together. Tasks 410,
411, 412 declare no `file_scope`. Task 481 is `[BLOCKED]` with no recorded reason; its own
description classifies it as runnable repair-or-replace, so lift the block or force the dispatch.

---

## Phase 7: Algebraic Representation (Low Priority)

**Status**: Waits on its own research gate. Five waves to the capstone.

- [ ] Ground the front in Goldblatt and BRV **before** the STSA axiom set is fixed; this gates
      everything below it transitively (Task 502)
- [ ] Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap;
      the seed is 361 lines behind `#exit` in `Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
      (Task 497)
- [ ] Reconcile the ShiftSet representation (landed for the compactness route) with the STSA
      route, so two parallel representation theorems are not developed and then reconciled
      (Task 500)
- [ ] Build the complex algebra `Cm(F)`: the powerset STSA over a `TaskFrame` (Task 498)
- [ ] Build the ultrafilter frame `Uf(A)` and prove it is a `TaskFrame`; HARD. The seed is 1189
      lines behind `#exit` with 4 sorry hits (Task 499)
- [ ] Prove the Jónsson–Tarski representation theorem: `η(a) = {U | a ∈ U}` is an injective STSA
      homomorphism `A → Cm(Uf(A))` — the capstone (Task 125)
- [ ] Extend STSA with the binary Until and Since operators, which the live object language has
      as primitives (Task 501)

**Blocked by**: Task 502 (→ 497) → {498, 499, 500} → 125 → 501
**Topics**: algebraic-representation
**Run**:
```
/orchestrate 502 --research --lit   # the literature gate; nothing below it starts first
/orchestrate 497
/orchestrate 498,499,500 --hard     # all three declare no file_scope
/orchestrate 125 --hard
/orchestrate 501
```
Every task on this front declares an empty `file_scope`; scope them before running the
three-task wave concurrently.

---

## Recommended Execution Order

1. ~~`/orchestrate 563, 718`~~ — both completed 2026-10-03 (Phase 1 — **the priority front**)
2. `/orchestrate 719` once 564's seam gluing has landed — the ray layer, the `⌢_z` operator and
   the promotion of the stab-fibre characterisation under `[F.IsRegular]`, with **E1** (the
   backward-dual probe on a time-asymmetric fixture) as its first probe (Phase 1)
3. `/orchestrate 716`, then `710 → 706 → 705`, then `720`, with `714 --research` beside them
   (Phase 2 — live)
4. The clause wave `564,565,567,616,617`, then `566,618` (Phase 3 — live; 563 is done)
5. `/orchestrate 709 --hard` under the gluing route once 719 lands — F4 as R1's summary step, not
   "the one real theorem" (scope spec, Section D)
6. `/orchestrate 178,604` and the dataset chain `298 → 282,296 → 231 → 219` (Phase 4 — independent)
7. `/orchestrate 664`, then `543 --hard`, `559 --research --lit`, `570 --research` (Phase 5)
8. `/orchestrate 464 --hard --lit` and `481 --hard`, then the spine in chain order (Phase 6)
9. `/orchestrate 502 --research --lit`, then the algebraic waves (Phase 7)
10. `/orchestrate 177` last, once its 26 dependencies have landed

Four points are reviewed before later work commits to them: E1's outcome (a backward-dual failure
falsifies R1's two-factor presentation); task 709's F4 step (its declined alternative is to
restrict the fragment instead); task 464's `gapPotential` design, which the whole spine's
termination argument rests on; and task 502's literature verdict, which fixes the STSA axiom set.

`--hard` suits 709, 464, 428, 429, 430, 482, 499, 125 and 543. `--lit` suits 464, 482, 502, 559
and 709 — the sub-index at `specs/literature-index.json` already carries the
Hodkinson–Wolter–Zakharyaschev, bundled-trees and CTL⋆ sources the L⁺ front depends on.

---

## Open Risks

| Risk | Status | Owning task |
|---|---|---|
| **No certificate class with finite per-time fibres is complete for L⁺, nor for the CTL-like fragment. A successor class must present infinite fibres (root paths of a finite class graph), for which there is no checker precedent** | MACHINE-CHECKED (`Probe710.not_finite_width_fmp`, `not_sliced_complete`; under task probes, not in `FormalSystem/`) | Task 710 (land it, Option A), Task 720 (re-point citations); Task 709 only as R1's summary step |
| **`liveAt` does not return on a 4-position total-edge certificate — a defect in landed, gated code** | REPRODUCER IN HAND | Task 716 |
| **Zero sorries does not mean zero open mathematics.** Proof extraction has no verifier at all (`grep -rn verifyProof FormalSystem/` is empty as of 2026-10-03 -- the `verifyProof` stub named in task 482's description is not in `ProofExtraction.lean`; `.extractionFailed` is a live `DecisionResult` outcome, `Correctness.lean`); `Verified/Refutation/` does not exist; no `isValid φ fc = true ↔ ⊨ φ` biconditional exists, proven or otherwise. None carries a sorry because none is a stated theorem. Companion fact: `Decidable (ValidZTime φ)` *does* exist by the witness-family route (`Compression.decidableValidZTime`, ZTime, `Formula`, empty premises), so for ℤ-time validity of L the risk is one of *description*, not of absence | CONFIRMED | Tasks 482, 430 |
| **Decidability of full L⁺: the gluing route is now the programme's priority, superseding "no route in sight".** Worlds as all ways of gluing a backward ray to a forward ray at a seam; `⊡`'s clause already quantifies over exactly those re-gluings, and `mem_HF_iff_adjacent` already proves `H_F` is the bi-infinite step-paths. The keystone is proved under `[F.IsRegular]` (`Probe718.seamFibreEquiv`, `plusStab_iff_omega`); the open question is whether the `⊡` fibre check over path sets stays decidable — only the forward finite-graph factor is proved, the backward dual (where the finite-width obstruction lives) is unproved, and the universal-summary device is unselected | **PRIORITY FRONT — design and implement; E1 first** (author directive 2026-10-02; 718 completed 2026-10-03) | Tasks 719, 720, 711 (revised per the scope spec, Section B) |
| **A universal, complementation-shaped summary device is NECESSARY on the gluing route** — the existential summary provably diverges from `⊡` (`Probe718PathQuantifier.exists_ne_stab`, `exists_ne_universal`). **Safra/Piterman determinization specifically is NOT shown necessary**: Safraless procedures, MSO over ⟨ℤ,<⟩ plus Büchi (no Safra construction), and a Ramsey colour are live alternatives; none is formalized in this tree or Mathlib. Device selection is experiment E3 | NECESSITY SHOWN; DEVICE UNSELECTED (E3 pending) | Task 711 (revised per the scope spec, Section B; Phase 0 ruling pending) |
| **Task-coherence-preserving filtration is CLOSED for ℤ-time.** No truth-lemma-bearing filtration can land on a finite world type over ℤ: `Probe706.no_finite_carrier_sat` (`[Finite F.WorldState]`, `⊡`-free witness — a fact about TM itself) and `Probe710.not_finite_width_fmp` (`[Finite W]`, `⊡`-bearing witness — L⁺-specific). The only residue is dense durations, not the programme's target | CLOSED FOR ℤ (probe level); dense residue OPEN | Tasks 706, 710 (library landing, Option A), 720 (citations) |
| **Strong completeness over ℚ-time is open.** Weak completeness is done (`derivable_of_validQTime`), but compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time; Cantor gives an order isomorphism, not a group one. Unlike Discrete and Dedekind, it is not known to be impossible | NOT SCOPED AS A TASK | — |
| **Genuine `Set Formula` strong completeness (Base/Dense) is unscoped.** Its gate (the shift-set representation theorem) has been passed, but the ultraproduct work behind it has no task | NOT SCOPED AS A TASK | — |
| **L⁺ Z-time validity is 2EXPTIME-hard by a reduction that is argued, not formalized.** It is the external ceiling on every compensation the programme can offer for incompleteness, and the sanity ceiling cited by 718, 719 and 721 on any proposed procedure; no upper bound is claimed anywhere in this programme | ARGUED | Task 713 (parked; see Phase 0) |
| **Programme-level surfaces understate L.** `README.md`, `FormalSystem/README.md` ("sound direction only"), ADR-007, `known-limitations.md`, `BiLasso/README.md` and `typst/FormalFoundations.typ` ("No decidability theorem is machine-checked") describe only the tableau and so state or imply that nothing is decided, while `Compression.decidableValidZTime` decides ℤ-time validity of L (`FrameClass.ZTime`, `Formula` with no `⊡`, empty premises). The two families of claims are about different statements and no surface says so | CONFIRMED (task 721, Section 0 row 27) | New task H1 of the scope spec (unfiled) |
| **`docs/theorem-index.md`'s three witness-family decidability rows claim `pinned:C14` with no baseline entry.** `scripts/check-module-invariants.sh` names `exists_witnessFamily_of_not_validZTime`, `validZTime_iff_noCertifiedCandidate` and `Compression.decidableValidZTime` (the `Decidable (ValidZTime φ)` result for `Formula`, i.e. `FrameClass.ZTime`, no `⊡`) only in the C-check shadowing allowlist; the index's "every declaration here is machine-pinned" is false for exactly the rows this programme now headlines | CONFIRMED by grep (task 721, Section 0 rows 25-26) | New task H2 of the scope spec (unfiled) |
| **Task 177 carries 26 dependencies**, including the entire tableau spine, so the final documentation state cannot be reached before Phase 5 lands | BY CONSTRUCTION | Task 177 |

---

## Success Metrics

- [ ] Every open task reaches `[COMPLETED]` in `specs/state.json`, or is closed at a stated and
      reasoned exclusion
- [ ] The tree stays at zero structural sorries and no new axioms, verified by
      `scripts/check-module-invariants.sh` check C3; every status claim in this file names the
      check that grounds it
- [ ] Every refutation the programme has produced lives in `FormalSystem/` as a cited theorem,
      not only under a task's `probes/` (Tasks 706, 710) — the Option A reading, adopted
      autonomously in task 721 cycle 1; confirm or overturn in Phase 0 (scope spec, Section F)
- [ ] The `pinned:C14` claim on the three witness-family decidability rows of
      `docs/theorem-index.md` is grounded in a C14 baseline entry (scope spec, H2)
- [ ] `liveAt` returns on every certificate shape in `scripts/certificate-witness-inventory.txt`,
      Tier 2 included (Task 716)
- [ ] Finite width ⇒ eventually periodic is machine-checked, giving the exact characterisation of
      what the sliced class certifies (Task 709)
- [ ] Every clause of `app:presheaf-dictionary` has a sorry-free Lean counterpart (Tasks 563–567,
      616–618)
- [ ] `isValid φ fc = true ↔ ⊨ φ` is proved, with `Decidable (⊨ φ)` for all four frame classes,
      and no `.extractionFailed` outcome survives on a closed tableau (Tasks 430, 412, 482) —
      noting that `Decidable (ValidZTime φ)` is already proved by the witness-family route
      (`Compression.decidableValidZTime`, ZTime, `Formula`, empty premises), and the ZTime instance
      of the former must agree with it
- [ ] The Jónsson–Tarski representation theorem is proved for TM with Until and Since
      (Tasks 125, 501)
- [ ] `Examples/` demonstrates the verified pipeline end to end on a concrete formula, and
      `README.md`, `docs/` and the module docstrings match the tree (Tasks 178, 177)

---

## Maintenance

This file is read by `/review` (Step 2.5, `.claude/scripts/roadmap-integration.sh`), which
cross-references each `(Task N)` reference against `specs/state.json` and annotates
`- [x] ... *(Completed: Task N, DATE)*` once a referenced task reaches `completed`. `/todo`
surfaces the same completions when archiving. Annotated items are dropped when their phase is
next revised; the durable record is `specs/CHANGE_LOG.md`. Update the phase list when
`/task --expand`, `/spawn` or a dependency change alters the graph — the waves in
`specs/TODO.md` are the source, and a claim this file makes that no check can reproduce is a
defect in the file, not a fact about the tree.

The decidability inventory this file's Fronts, Phase 1/2/6 and Open Risks rely on has a baseline:
`specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
§1 (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED, by declaration name), re-verified in the
scope spec's Section 0. Until the scope spec's **H5** ("make this review re-runnable") is filed and
built, the owner of the periodic re-run is that unfiled task — i.e. nobody; a review older than
the last change to `docs/theorem-index.md`'s Decidability rows or to
`scripts/check-evidence-probes.sh`'s `WIRED`/`WIRED_REPO` arrays is stale.

## Related

- `.claude/context/formats/roadmap-format.md` — this file's parseable structure
- `.claude/context/patterns/roadmap-update.md` — annotation and update process
- `.claude/context/patterns/batch-orchestration-guardrails.md` — why the Run blocks above are
  split into sequences
- `specs/TODO.md` — Task Order and dependency waves (the source of the phases above)
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
- `specs/CHANGE_LOG.md`, `specs/archive/` — completed work
