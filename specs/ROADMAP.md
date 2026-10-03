# Roadmap

*Derived from `specs/state.json` and `specs/TODO.md`'s Task Order (2026-10-02). Open work only;
completed work is recorded in `specs/CHANGE_LOG.md` and `specs/archive/`. Reference material —
the BX axiom layers, the irreflexive truth semantics, the canonical-model and quasimodel
construction — lives in `README.md`, the module docstrings and `typst/BimodalReference.typ`,
not here; it was removed from this file on 2026-10-02 as duplicative (and, for the axiom counts,
stale against `README.md`). Recover it from git: `git log --follow -- specs/ROADMAP.md`.*

## Fronts

| Front | Open tasks | Delivers |
|---|---|---|
| User decisions | — | Status calls on the parked records, and the Hugging Face token |
| **Gluing route to decidability** | **718, 719** | **Possible worlds as all ways of gluing a backward ray to a forward ray; the stab fibre; decidability by that means** |
| L⁺ sliced certificates | 705, 706, 709, 710, 714, 716 | The landed incompleteness theorems, the liveAt defect, the periodicity theorem |
| Categorical structure | 563, 564, 565, 566, 567, 616, 617, 618 | The behavior presheaf and every clause of `app:presheaf-dictionary` |
| Publication and data | 178, 231, 282, 296, 298, 604, 219, 177 | Worked examples; the dataset pipeline; the final docs pass |
| Metalogic questions | 543, 559, 570, 664 | MF rigidity; TM⋆ completeness; the C3 question; one literature source |
| TM tableau spine | 464, 465, 428, 429, 410, 411, 430, 412, 482, 481 | Totality, the truth-lemma repair, the semantic lift, decidability of provability |
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
      an open statement. Moving it to a terminal status is a programme-level call (Task 712)
- [ ] Rule on task 711, the ω-automata determinization substrate: it was filed only to make the
      blocker visible, and the route it names is now closed, so the honest outcome is ABANDONED
      rather than completed (Task 711)
- [ ] Rule on task 713, the CTL⋆ 2EXPTIME reduction: optional, filed not scheduled, nothing
      depends on it; abandon or keep as a write-up note (Task 713)
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

**Status**: Live — the programme's priority front by author directive, 2026-10-02. Task 718 is
unblocked today. To be carried through **research, design and implementation**, not filed as a
research note.

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

- [ ] Research and rank the routes: whether each landed refutation is *genuinely* two-sided or
      merely *stated* two-sidedly, re-derived over ω-sequences; the ray layer's status (colimit of
      bounded sections, hence Saturation-dependent, versus separate primitive versus a
      `PartialHistory` with a ray domain); and the ω-automata question, which collapses into the
      infinite-fibre question rather than sitting beside it (Task 718)
- [ ] Design and implement the ray layer, the seam-gluing operator the paper calls `⌢_z`, and the
      **stab-fibre characterisation** — that `stab_clause`'s quantification domain is the fibre
      product over the seam state. A refutation of that characterisation is the most valuable
      outcome and must land as a theorem, since every downstream route assumes it (Task 719)
- [ ] Settle the **effective extension theorem** question: whether the binary seam gluing, which
      the live `app:gluing` proves from convexity and the task constraint alone, generalises the
      Tier A effective extension theorem that `BiLasso/Orbit.lean` built only for the bi-lasso
      case. Worth landing even if decidability stalls (Task 719, deliverable 4)
- [ ] Assess **task-coherence-preserving filtration**, the route `JPL/metalogic.tex` names as
      standard for FMP with the obstacle that the quotient must preserve Nullity and
      Compositionality. It appears nowhere among the routes this programme has tried or refuted
      (Task 718)

**Source of record.** The gluing theorem is `app:gluing` in
`~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — **live** in the paper, proved, with
its seam case written as the pasting principle `ρ ⌢_z σ` but **commented out**. `app:Structure`
and `app:presheaf-dictionary` are **cut** from the paper entirely: that material is the author's
own mathematics with the supporting results promised elsewhere, and this repository is where
elsewhere is. Treat cut clauses as a specification to implement, never as a theorem to cite.

**Carry this caution.** Gluing does **not** bound the fibre — "all ways" is the largest choice, a
full product. The route concedes infinite fibres and seeks a finite *presentation*, which is the
only move `not_finite_width_fmp` leaves open. And the binary seam case is choice-free while the
*directed* case needs Saturation (`app:gluing`'s footnote supplies the `D = ℚ` counterexample);
an ω-ray built by iterated gluing is a directed colimit, so do not assume the choice-free case.

**Blocked by**: Task 718 (→ 719); Tasks 563, 564 (→ 719)
**Topics**: decidability, categorical-structure
**Run**:
```
/orchestrate 563, 718   # the substrate and the route round, in parallel; scopes are disjoint
/orchestrate 719        # after 718's verdict and 564's seam gluing land
```

---

## Phase 2: L⁺ Sliced Certificates (High Priority)

**Status**: Live — the active front; every task is unblocked today.

What the incompleteness round settled, and what the phase now builds on: the time-sliced
certificate class is incomplete for full L⁺ **and** for the CTL-like fragment, and no
certificate class presenting finite per-time fibres is complete, whatever its clauses. The
obstruction is finite *width* (limit closure plus finite fibres contradicts König) — strictly
stronger than the earlier finite-*carrier* failure. Both are machine-checked but live under task
probes, not in `FormalSystem/`.

- [ ] Fix the `liveT`/`liveAt` non-termination: the landed fixpoint does not return in 300s on a
      4-position total-edge certificate while being instant on self-loop ones. This is a defect
      in shipped, gated code, not an unbuilt feature (Task 716)
- [ ] Land the finite-width refutation as library theorems under
      `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, with the separating witness
      `Φ := θ' ∧ □(stab F p → ¬ stab ¬ X p)` (Task 710)
- [ ] Land task 706's finite-carrier refutations into `FormalSystem/`; they exist only under that
      task's own probes, so no acceptance gate can cite them yet (Task 706)
- [ ] Record the `trans_refl` verdict: RETAIN — roughly 87 term-level sites across 18 files need
      the self-step. Land the label-level congruences that are the bounded residual (Task 705)
- [ ] Evaluate carrying full labels in the certificate, which would make `posAt` a singleton and
      delete both liveness filters; the question is whether decidability of the check survives
      (Task 714)
- [ ] Prove finite width ⇒ eventually periodic (finding F4): every finite-width sliced structure
      satisfying a target has an eventually periodic model of the same width — the sufficiency
      half of the exact characterisation (Task 709)

**Blocked by**: Task 710 (→ 709)
**Topics**: decidability, incompleteness
**Run**:
```
/orchestrate 716        # first: owns PlusSlicedCertificate/{Live,Check,Examples}
/orchestrate 714 --research   # beside it: declares no file_scope, research-only
/orchestrate 710        # then, in this order -- the three below overlap pairwise
/orchestrate 706        # shares PlusSlicedCertificate.lean + docs/theorem-index.md with 710
/orchestrate 705        # shares scripts/check-module-invariants.sh with 706
/orchestrate 709 --hard # last: needs 710 landed; the one real theorem on this front
```
These five cannot be batched: 705, 706 and 710 all declare `docs/theorem-index.md`, 706 and 710
both declare `PlusSlicedCertificate.lean`, and 706 and 716 both declare
`scripts/certificate-witness-inventory.txt`. Task 709 is the phase's substance and the only item
that is open mathematics; its two forced repairs to Hodkinson–Wolter–Zakharyaschev (one-sided
live sets in the quasistate, and fulfilment secured at every live position at once by an
idempotent Ramsey colour) are the work. Do not file a fourth certificate class first — any class
with finite fibres is already refuted.

---

## Phase 3: The Behavior Presheaf (High Priority)

**Status**: Live — task 563 is unblocked today and gates the rest.

Each clause below is a clause of `app:presheaf-dictionary` in the PossibleWorlds paper, and each
has a proved hook already in the tree, which is why the cluster is bounded rather than open.

- [ ] Promote the presheaf skeleton into the library: the section type `Beh F l`, restriction
      along `Tr p`, functoriality, and the Germs clause (Task 563)
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

**Blocked by**: Task 563 (→ all); Task 565 (→ 566); Tasks 564, 616 (→ 618)
**Topics**: categorical-structure
**Run**:
```
/orchestrate 563                    # the library skeleton the rest instantiate
/orchestrate 564,565,567,616,617    # the clause wave
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
      (`isValid_sound`); no `isValid`-shaped `iff` is written until it can be proved (Task 430)
- [ ] Prove the refutation core and decidability of provability with its completeness corollaries
      (Task 412)
- [ ] Discharge proof-extraction completeness, eliminating `.extractionFailed` on a genuinely
      closed tableau. `Verified/Refutation/` does not exist and `verifyProof` is the constant stub
      `fun _ _ => true`. OPEN MATHEMATICS, multi-month; must not be re-described as engineering
      (Task 482)

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

1. `/orchestrate 563, 718` — the presheaf substrate and the gluing-route round, in parallel;
   their scopes are disjoint (Phase 1 — **the priority front**)
2. `/orchestrate 719` once 718's verdict and 564's seam gluing have landed — the ray layer, the
   `⌢_z` operator and the stab-fibre characterisation (Phase 1)
3. `/orchestrate 716`, then `710 → 706 → 705`, with `714 --research` beside them (Phase 2 — live)
4. `/orchestrate 563`, then the clause wave `564,565,567,616,617`, then `566,618` (Phase 3 — live)
5. `/orchestrate 709 --hard` once 710 lands — the one real theorem on the live front
6. `/orchestrate 178,604` and the dataset chain `298 → 282,296 → 231 → 219` (Phase 4 — independent)
7. `/orchestrate 664`, then `543 --hard`, `559 --research --lit`, `570 --research` (Phase 5)
8. `/orchestrate 464 --hard --lit` and `481 --hard`, then the spine in chain order (Phase 6)
9. `/orchestrate 502 --research --lit`, then the algebraic waves (Phase 7)
10. `/orchestrate 177` last, once its 26 dependencies have landed

Three points are reviewed before later work commits to them: task 709's F4 route (its declined
alternative is to restrict the fragment instead); task 464's `gapPotential` design, which the
whole spine's termination argument rests on; and task 502's literature verdict, which fixes the
STSA axiom set.

`--hard` suits 709, 464, 428, 429, 430, 482, 499, 125 and 543. `--lit` suits 464, 482, 502, 559
and 709 — the sub-index at `specs/literature-index.json` already carries the
Hodkinson–Wolter–Zakharyaschev, bundled-trees and CTL⋆ sources the L⁺ front depends on.

---

## Open Risks

| Risk | Status | Owning task |
|---|---|---|
| **No certificate class with finite per-time fibres is complete for L⁺, nor for the CTL-like fragment. A successor class must present infinite fibres (root paths of a finite class graph), for which there is no checker precedent** | MACHINE-CHECKED (under task probes, not in `FormalSystem/`) | Task 710 (land it), Task 709 (the sufficiency half) |
| **`liveAt` does not return on a 4-position total-edge certificate — a defect in landed, gated code** | REPRODUCER IN HAND | Task 716 |
| **Zero sorries does not mean zero open mathematics.** `verifyProof` is `fun _ _ => true`; `Verified/Refutation/` does not exist; no `isValid φ fc = true ↔ ⊨ φ` biconditional exists, proven or otherwise. None carries a sorry because none is a stated theorem | CONFIRMED | Tasks 482, 430 |
| **Decidability of full L⁺: the gluing route is now the programme's priority, superseding "no route in sight".** Worlds as all ways of gluing a backward ray to a forward ray at a seam; `⊡`'s clause already quantifies over exactly those re-gluings, and `mem_HF_iff_adjacent` already proves `H_F` is the bi-infinite step-paths. The open question is whether the `BiLasso` `back`/`mid`/`fwd` presentation can range over *path sets* rather than single lists while keeping the `⊡` check decidable | **PRIORITY FRONT — research, design and implement** (author directive 2026-10-02) | Tasks 718, 719 (see Phase 1) |
| **ω-automata determinization is still absent from this tree and from Mathlib.** It is no longer the blocker for a refuted statement, but it is the only known way to summarise "all root paths" finitely, so the gluing route may require it after all | STATUS UNSETTLED — in scope for Task 718 | Task 711 (parked; see Phase 0) |
| **Task-coherence-preserving filtration has never been tried.** `JPL/metalogic.tex` names filtration as the standard FMP technique and the obstacle as preserving Nullity and Compositionality under the quotient; it appears in no route this programme has tried or refuted | UNASSESSED | Task 718 |
| **Strong completeness over ℚ-time is open.** Weak completeness is done (`derivable_of_validQTime`), but compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time; Cantor gives an order isomorphism, not a group one. Unlike Discrete and Dedekind, it is not known to be impossible | NOT SCOPED AS A TASK | — |
| **Genuine `Set Formula` strong completeness (Base/Dense) is unscoped.** Its gate (the shift-set representation theorem) has been passed, but the ultraproduct work behind it has no task | NOT SCOPED AS A TASK | — |
| **L⁺ Z-time validity is 2EXPTIME-hard by a reduction that is argued, not formalized.** It is the external ceiling on every compensation the programme can offer for incompleteness | ARGUED | Task 713 (parked; see Phase 0) |
| **Task 177 carries 26 dependencies**, including the entire tableau spine, so the final documentation state cannot be reached before Phase 5 lands | BY CONSTRUCTION | Task 177 |

---

## Success Metrics

- [ ] Every open task reaches `[COMPLETED]` in `specs/state.json`, or is closed at a stated and
      reasoned exclusion
- [ ] The tree stays at zero structural sorries and no new axioms, verified by
      `scripts/check-module-invariants.sh` check C3; every status claim in this file names the
      check that grounds it
- [ ] Every refutation the programme has produced lives in `FormalSystem/` as a cited theorem,
      not only under a task's `probes/` (Tasks 706, 710)
- [ ] `liveAt` returns on every certificate shape in `scripts/certificate-witness-inventory.txt`,
      Tier 2 included (Task 716)
- [ ] Finite width ⇒ eventually periodic is machine-checked, giving the exact characterisation of
      what the sliced class certifies (Task 709)
- [ ] Every clause of `app:presheaf-dictionary` has a sorry-free Lean counterpart (Tasks 563–567,
      616–618)
- [ ] `isValid φ fc = true ↔ ⊨ φ` is proved, with `Decidable (⊨ φ)` for all four frame classes,
      and no `.extractionFailed` outcome survives on a closed tableau (Tasks 430, 412, 482)
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

## Related

- `.claude/context/formats/roadmap-format.md` — this file's parseable structure
- `.claude/context/patterns/roadmap-update.md` — annotation and update process
- `.claude/context/patterns/batch-orchestration-guardrails.md` — why the Run blocks above are
  split into sequences
- `specs/TODO.md` — Task Order and dependency waves (the source of the phases above)
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
- `specs/CHANGE_LOG.md`, `specs/archive/` — completed work
