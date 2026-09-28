# Research Report: Task #683

**Task**: 683 - State-sharing witness structure and C3
**Started**: 2026-09-27T21:20:00-07:00
**Completed**: 2026-09-27T21:45:00-07:00
**Effort**: 3-6 weeks (implementation), decomposed into 7 phases below
**Dependencies**: None blocking. Shares `FormalSystem/Semantics/ShiftSet.lean` with a sibling
task's `file_scope`; this task should treat that file as read-only (see Risks).
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/{ShiftSet,TaskFrame,TruthClauses}.lean`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean`,
  `FormalSystem/Metalogic/Decidability/BiLasso/**`,
  `FormalSystem/PlusLanguage/{Formula,PlusTruth,PlusDeterminism}.lean`,
  `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean`
- Evidence probe: `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
- Literature source: the consuming repository's adequacy document,
  `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
  (section "Why the design is deterministic"; §7.1 A1)
- Prior in-repo research: `specs/680_record_compression_prerequisite_satisfiable/reports/01_compression-prerequisite-satisfiable.md`
- lean-lsp MCP: not required; every fact below was read from source in-tree
**Artifacts**: - `specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The received account is correct about where the weight sits, and I can now say exactly what
  replaces each load-bearing piece.** Limit and Saturation are indeed not the obstacle, and —
  this is new — neither loses its discharge route under state-sharing. Limit still comes from
  `TaskFrame.limit_of_succOrder` (`Semantics/TaskFrame.lean:1591`), which needs only
  `R w 0 u → u = w`, not determinism. Saturation loses
  `TaskFrame.saturation_of_fib_subsingleton` (`:2181`) but lands on the already-proved
  `TaskFrame.saturation_of_fib_finite` (`:2222`), whose docstring says it exists precisely to
  "reach infinite carriers that `saturation_of_finite` does not" — the branching carrier has
  finite fibres (at most `|lassos|` classes per time) on an infinite carrier, which is that
  lemma's exact niche. **No new frame-axiom work is needed.**

- **Condition (C3) `BoxFaithful` does not need redesigning. It survives verbatim.** This
  contradicts the task description and ADEQUACY's "redesigning condition (C3)", and it is the
  single most consequential finding here. `BoxFaithful` reads
  `bx χ = true ↔ ∀ i t, χ ∈ W.L i t` (`WitnessFamily/Predicates.lean:106-109`). The label
  realized at time `t` by a *recombined* history is `L i t` for some member index `i` — a
  recombined history's label set at each position is drawn from exactly the same pool as the
  members'. Adding recombined histories therefore adds **no new labels** for `□` to range over,
  so the biconditional's right-hand side is unchanged. What breaks is not (C3) but (C1)
  `LocalCoherentLab` and (C2) `FulfillingLab`, both of which are stated *per lasso*
  (`∀ i : Fin W.lassos.length`) and say nothing about a history that changes index.

- **Recommended design: `share`, threads, and four condition changes.** Add to `WitnessFamily` a
  decidable, periodically-encoded field `share : ℤ → Fin lassos.length → Fin lassos.length → Bool`
  (an equivalence relation at each time). The frame's world states become the `share`-classes
  `⟦(i,u)⟧`; a history becomes a **thread** `θ : ℤ → Fin lassos.length` with
  `share (u+1) (θ u) (θ (u+1))` for all `u`. The condition set becomes: (C0) atom coherence
  across `share` — new, and mandatory because the valuation now reads a class, not a pair;
  (C1') local coherence with the `untl`/`snce` one-step clauses taken **across** `share`-linked
  index pairs; (C2') fulfilment as an "on every thread" property, not a per-lasso one; (C3)
  **unchanged**; (C5) the stability clause `⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`.
  Setting `share u i j := (i = j)` recovers the current device exactly: threads collapse to
  constants, (C0) and (C1') collapse to the present clauses, (C2') collapses to
  `FulfillingLab`, and (C5) collapses to `⊡φ ↔ φ`.

- **Decidability is preserved, and the "infinitely many walks" worry dissolves — but not where
  the task description places it.** No condition ever quantifies over walks. (C0), (C1') and
  (C5) are one-step/one-position conditions, finite by the existing periodic-window reduction
  (`WitnessFamily/Decide.lean:336` `coherent_iff_window`, window
  `[-2·nb, nm + 2·nf)` at `:325-328`). (C2') is the only condition with genuinely new content:
  "every thread from `(i,u)` fulfils `untl g e`" is a CTL-style `A[g U e]` least-fixpoint
  computation on the **finite** periodic position graph (vertices `(i, u)` in the window,
  edges from `share`), decidable by bounded `Finset` iteration. This — not (C3) — is the hard
  constraint the task description was pointing at.

- **`Probe476.fmp_false` does not transfer to this design, and the plan must not assume it
  does.** The probe refutes a finite small-model property for `IntPresentation` — a **time-free**
  finite digraph in which all walks are histories, where pumping a repeated state bi-infinitely
  produces a `p`-free history. A state-sharing witness family keeps the time coordinate in the
  carrier (`Fin L × ℤ`, quotiented only *within* a time), so no cycle can be pumped
  bi-infinitely into a history that skips a position — the pigeonhole step the probe turns on has
  no analogue. The obstruction shape is shared (recombination adds histories); the fatal
  consequence is not. Asserting otherwise would wrongly kill the design before it is tried.

- **The two devices coexist behind one interface with no shared proof.** `Refutes Γ Del`
  (`WitnessFamily/Agreement.lean:269-272`) existentially quantifies the frame, so a branching
  family discharging it does not touch the deterministic producer. This is the concrete
  mechanism satisfying the dispatch's "add alongside, do not replace"; `refutes_of_certifies`
  stays as it is and gains a sibling.

- **`ShiftSet` cannot host the branching carrier and must not be touched.** `ShiftSet.sh` is a
  plain function `Carrier → ↑D → Carrier`, which is exactly what makes `total_eq_orbit`
  (`Semantics/ShiftSet.lean:261`) a four-line proof. A parallel construction is required —
  `ShiftSet.frame`/`model`/`hist`/`forward_repr`/`total_eq_orbit` all need branching twins. That
  is the single largest implementation cost and the honest price of the change.

## Context & Scope

**What was researched.** The precise mechanism by which determinism is load-bearing in the
bi-lasso / witness-family decision layer; what a state-sharing (branching) replacement would have
to look like; which existing lemmas survive, which must be replaced, and whether the result stays
decidable. The scope clarification in the dispatch is binding: the deterministic device is an
existing shipped consumer contract and must keep working unchanged; the branching structure is an
**addition**.

**Constraints honoured.** Zero-debt: every recommendation below has a sorry-free path, and where
a step is genuinely hard I say so and recommend decomposition rather than deferral. No new axioms
are proposed anywhere. No task-number citations appear in any text destined for `FormalSystem/**`.

**What is out of scope.** The A1 compression theorem (the consuming repository records it as open
with a named route; it is a separate line). Any change to `ShiftSet.lean`, `BiLasso/**`'s existing
proofs, or the exported JSON field names (`back`, `mid`, `fwd`, `bx`, `lassos` are an export
contract — `WitnessFamily/Basic.lean:31-35`).

## Literature Proof Structure

**Source**: `ADEQUACY.md`, consuming repository
(`~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`),
section "Why the design is deterministic" (lines 306-341), with §7.1 (A1) at 548-641 for
context on what is *not* being attempted here.
**Strategy**: a localization argument — the document isolates which of four frame conditions
and which of four certificate conditions carry the determinism assumption, by naming the exact
Lean lemma each one is discharged by.

### Step Map

1. Limit is genuinely non-free over a general duration order, but is discharged trivially over
   `ℤ` — [ADEQUACY] "Why the design is deterministic", bullet 1; cites
   `ShiftSet.SepNotDerivable.sep_not_derivable` and `WitnessFamily/Std.lean:73-80`.
2. Saturation is free **only** from subsingleton fibres — [ADEQUACY] bullet 2; cites
   `TaskFrame.saturation_of_fib_subsingleton` consumed at `Semantics/ShiftSet.lean:172`.
3. Therefore the real obstruction is Lemma 2 (`total_eq_orbit`) and the Box case of Lemma 4 —
   [ADEQUACY] the bold paragraph at line 328.
4. Recombination at a shared state falsifies `total_eq_orbit`, hence Corollary 2.2
   (`H_F` = the certified histories), hence the Box case — [ADEQUACY] lines 329-336.
5. This is claimed to be "the same obstruction `Probe476.fmp_false` records for finite
   digraphs" — [ADEQUACY] lines 336-338.
6. Consequence: state-sharing requires re-proving Lemma 2 and **redesigning (C3)** —
   [ADEQUACY] lines 340-341.

### Dependencies

- Step 3 depends on Steps 1 and 2 (it is the residue after those two are eliminated).
- Step 4 depends on Step 3.
- Step 6 depends on Steps 4 and 5.

### Translation Findings (where the Lean reading refines the source)

- **Steps 1-2 are correct but incomplete as a guide.** Step 2's "free *only* from subsingleton
  fibres" is true of the route `ShiftSet.lean` actually takes, but the repository already
  contains the weaker-hypothesis route the branching design needs
  (`TaskFrame.saturation_of_fib_finite`, `Semantics/TaskFrame.lean:2222`). The source's framing
  invites a reader to conclude Saturation must be re-argued from scratch; it must not.
- **Step 5 is an over-transfer.** See Findings > Probe476 below. The probe's carrier is
  time-free; the witness family's is not.
- **Step 6's second half is wrong, and this is load-bearing for planning.** (C3) needs no
  redesign. The conditions that need redesign are (C1) and (C2), which the source does not
  mention at all. A plan built literally on Step 6 would spend its effort in the wrong module
  (`Predicates.lean`'s `BoxFaithful`) and leave the actual defect (`LocalCoherentLab` and
  `FulfillingLab` being per-lasso) unaddressed.

### Potential Formalization Challenges

- Step 4's replacement (the threads characterization) is an induction over `ℤ` in both
  directions, not the current one-liner off `respects_task 0`.
- (C2')'s fixpoint computation has no existing analogue in-tree at the "all paths" strength;
  `BiLasso/GoodCycle.lean` is the closest template and is single-cycle.

## Findings

### Codebase Patterns

**The device, precisely.**

`WitnessFamily` (`WitnessFamily/Basic.lean`) is a box guess `bx : Formula → Bool` plus a
non-empty list of `LabelledLasso C`. A `LabelledLasso` is three label lists
(`back`, `mid`, `fwd`, with `back ≠ []` and `fwd ≠ []`) decoded into a bi-infinite
`lab : ℤ → Finset Formula` by `Periodic.unrollOf`. There are **no states at all** — the module
header is explicit: "the labels **are** the object". `W.L i t` is lasso `i`'s label at time `t`.

`WitnessFamily.std` (`WitnessFamily/Std.lean:64-70`) presents this as a `ShiftSet intOrder` with

```lean
def std (W : WitnessFamily Γ Del) : ShiftSet intOrder :=
  ShiftSet.ofIntAction (Fin W.lassos.length × ℤ) ⟨(W.mainIdx, 0)⟩
    (fun w d => (w.1, w.2 + d))
    ...
    (fun p w => Formula.atom p ∈ W.L w.1 w.2)
```

The carrier is `Fin L × ℤ` and the shift translates the **time coordinate only**. The lasso
index never changes. That one line is the determinism: a world state is a (lasso, time) pair, and
the unique history through it is that lasso.

**Why `total_eq_orbit` is a four-line proof.** `ShiftSet.fibre`'s task relation is
`PosRel w x u := u = S.sh w x` (`Semantics/ShiftSet.lean:201-204`) — functional by construction.
Hence

```lean
theorem total_eq_orbit (S : ShiftSet D) (σ : WorldHistory S.frame) :
    σ = S.hist (σ.state 0) := by
  refine WorldHistory.ext_state fun r => ?_
  have := (S.fibre_taskRel _ _ _).mp (σ.respects_task 0 r)
  rw [sub_zero] at this
  exact this
```

(`Semantics/ShiftSet.lean:261-266`). It is consumed in exactly one place inside `ShiftSet`, the
`box` case of `forward_repr` (`:302-307`), which is the shape the certificate's box case inherits.

**The four certificate conditions** (`WitnessFamily/Predicates.lean`):

| | Name | Line | Quantifier shape | Survives state-sharing? |
|---|---|---|---|---|
| (C1) | `LocalCoherentLab` | `:72-90` | `∀ i t`, clauses at `t`, `t+1`, `t-1` **on the same `i`** | **No** — needs cross-`share` clauses |
| (C2) | `FulfillingLab` | `:93-103` | `∀ i t`, `∃ s` **on the same `i`** | **No** — needs "on every thread" |
| (C3) | `BoxFaithful` | `:106-109` | `bx χ = true ↔ ∀ i t, χ ∈ W.L i t` | **Yes, verbatim** |
| (C4) | `Target` | `:115-117` | main lasso only | Yes |

Verbatim, the two that break and the one that does not:

```lean
def LocalCoherentLab (W : WitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin W.lassos.length) (t : ℤ),
    (Formula.bot ∉ W.L i t) ∧ ...
    (∀ g e : Formula, Formula.untl g e ∈ closureOf (Γ ++ Del) →
        (Formula.untl g e ∈ W.L i t ↔
          (e ∈ W.L i (t + 1) ∨ (g ∈ W.L i (t + 1) ∧ Formula.untl g e ∈ W.L i (t + 1))))) ∧ ...

def FulfillingLab (W : WitnessFamily Γ Del) : Prop :=
  (∀ (i : Fin W.lassos.length) (t : ℤ) (g e : Formula), Formula.untl g e ∈ W.L i t →
      ∃ s : ℤ, t < s ∧ e ∈ W.L i s ∧ ∀ r : ℤ, t < r → r < s → g ∈ W.L i r) ∧ ...

def BoxFaithful (W : WitnessFamily Γ Del) : Prop :=
  ∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) →
    (W.bx χ = true ↔ ∀ (i : Fin W.lassos.length) (t : ℤ), χ ∈ W.L i t)
```

Note the repeated `W.L i _` in (C1) and (C2) and its absence from (C3)'s right-hand side, which
mentions only the *label set*. That asymmetry is the whole finding.

**Atoms are the hidden fifth condition.** `Predicates.lean`'s header says: "**Atoms are
deliberately unconstrained.** That is not an omission — it is what makes the agreement theorem's
`atom` case `Iff.rfl`". That works only because the valuation in `std` reads
`Formula.atom p ∈ W.L w.1 w.2` at the **pair** `w = (i,t)`. Once `(i,t)` and `(j,t)` are the same
world state, the valuation must read a class, and `Iff.rfl` is no longer available: atom
coherence across `share` becomes a mandatory new condition. No source I read anticipates this.

**Why box faithfulness quantifies over *all* times.** `WitnessFamily.sh_surj`
(`Std.lean:94-97`) — "`sh` at a fixed duration is surjective on the carrier. This is the whole
content of the `box` case of agreement: quantifying over shifted points is quantifying over all
points." The state at time `t` of the history through carrier point `(i,s)` is `(i, s+t)`, and
`s` ranges over `ℤ`, so `□` at any fixed time ranges over every `(i,u)`. This is exactly why (C3)
is `∀ i t` and exactly why it stays correct under recombination.

**The interface the branching device can plug into unchanged.** `Agreement.lean:269-272`
defines the exported existence statement

```lean
def Refutes (Γ Del : Context) : Prop :=
  ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (u : F.Duration),
    (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ)
```

and `refutes_of_certifies` (`:282-284`) is the only thing a checker's accepting branch needs.
`Refutes` existentially quantifies the frame, so a *branching* family that produces a different
frame still discharges the same `Refutes Γ Del`. The two devices therefore coexist behind one
interface with no change to the deterministic path — this is the concrete mechanism by which the
scope clarification's "add alongside, do not replace" is satisfiable. Note however that
`truth_iff_mem` (`:209-214`) is composed through `ShiftSet.forward_repr`, so the branching family
needs its own `forward_repr` twin; it cannot reuse that one.

**The `Decidable` surface that must be mirrored.** Fifteen instances in
`WitnessFamily/Decide.lean`, ending in `decidableCertifies` (`:936`), which is the only one a
checker names: `instDecidableLabClauseAt` (`:293`), `instDecidableCoherentAt` (`:304`),
`instDecidableCoherent` (`:384`), `instDecidableUntlOblB` (`:428`), `instDecidableSnceOblB`
(`:433`), `instDecidableEventClauseAt` (`:601`), `instDecidableFulfilAt` (`:611`),
`instDecidableFulfil` (`:790`), `decidableLocalCoherentLab` (`:866`), `decidableFulfillingLab`
(`:879`), `instDecidableMemAll` (`:891`), `instDecidableBoxClause` (`:904`),
`decidableBoxFaithful` (`:924`), `decidableTarget` (`:928`), `decidableCertifies` (`:936`).
Of these, `decidableBoxFaithful`, `instDecidableMemAll`, `instDecidableBoxClause` and
`decidableTarget` are reusable as-is under the recommendation below, because (C3) and (C4) do
not change.

**The decidability engine.** `WitnessFamily/Decide.lean` reduces `∀ t : ℤ` checks to a finite
window: `labCohWindowLo Λ := -2 * Λ.nb` (`:325`), `labCohWindowHi Λ := Λ.nm + 2 * Λ.nf` (`:328`),
and `coherent_iff_window` (`:336`) proves the reduction. `untlObl_shift_fwd` / `snceObl_shift_back`
/ `untlObl_shift_back` / `snceObl_shift_fwd` (`:497, :513, :536, :566`) are the periodicity
lemmas that make the fulfilment scan finite. Any new condition must be encoded so that these
same window lemmas apply — which is why `share` should be encoded as three lists decoded by
`Periodic.unrollOf`, matching the labels, rather than as an arbitrary function.

**The frame axioms, with their branching discharge routes.** All four are already available:

| Axiom | Statement (`Semantics/TaskFrame.lean`) | Current route | Branching route |
|---|---|---|---|
| `Compositional` | `:805-806` | `compositional_reflect_of_reflective` | Same shape; concatenate/split threads |
| `Serial` | `:763-764` | `shRel_serial` | Every class has a successor and predecessor class |
| `Limit` | `:828-829` | `sep` field / `limit_of_shift` (`:1619`) | **`limit_of_succOrder` (`:1591`)** — needs only `R w 0 u → u = w` |
| `Saturation` | `:683-685` | `saturation_of_fib_subsingleton` (`:2181`) | **`saturation_of_fib_finite` (`:2222`)** |

`saturation_of_fib_finite`'s own docstring: "the finite-*fibres* variant of `cor:saturation-finite`,
which is the finite-*carrier* result (`saturation_of_finite` above) and does not apply when `W`
is infinite. It sits strictly between its two neighbours". The branching carrier is infinite (the
`ℤ` coordinate) with finite fibres (at most `|lassos|` classes at each time). This lemma was
written for exactly this case.

**The stability modal, verbatim.** `FormalSystem/PlusLanguage/PlusTruth.lean:84-93`:

```lean
def PlusTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : PlusFormula → Prop
  ...
  | .box φ => ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ
```

`□` quantifies over all histories; `⊡` over histories agreeing on the **world state** at `t`.
`states_eq_of_deterministic` (`PlusLanguage/PlusDeterminism.lean:104-113`) is the singleton
bridge — on a deterministic frame, agreement at one time forces agreement at every time — and
`stab_iff_of_deterministic` (`:123`) is the resulting collapse `⊡φ ↔ φ`. Both are `[propext]`-only,
no `Classical.choice`. The chain `total_eq_orbit → deterministic frame → stab_iff_of_deterministic`
is precisely why the present device is *blind* to `⊡` rather than merely incomplete for it.

**An existing lemma that constrains the design.** `stab_state_only`
(`PlusLanguage/PlusTruth.lean` header, line 43): "`⊡φ` depends on the world state **alone**, at
any two times — the fact that licenses treating each `⊡χ` as a fresh state-valued atom", used by
`Metalogic/Conservativity/Plus/Atomization.lean` (`plusTruthAt_iff_atomize`). The proposed (C5)
`⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u` immediately yields
`share u i j → (⊡φ ∈ L i u ↔ ⊡φ ∈ L j u)` because `share u` is an equivalence — i.e. (C5) is
consistent with `stab_state_only` by construction, and `Atomization.lean` is the transfer
machinery that will let `⊡` be handled without re-proving the base-language cases.

**`Probe476.fmp_false`, read directly.**
(`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`.)
Witness `ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` — "every history meets `p`, and meets it at most once
from the left". Positive half: satisfied by the `ℤ`-carrier shift set with `p` true only at state
`0`. Negative half, in the probe's own words: "no `IntPresentation` satisfies `ψ` at any
history/time: a history `τ` meets `p` at some `a`; left of `a` it is `p`-free; pigeonhole on
`card+1` times finds a repeated state; **the resulting cycle, pumped bi-infinitely, is itself a
history (all walks are histories)** that never meets `p`". The probe is sorry-free
(`[propext, Classical.choice, Quot.sound]`) and is compile-checked by
`scripts/check-evidence-probes.sh`.

The pigeonhole step requires the state space to be **finite and time-free**, so that a repeated
state licenses a bi-infinite pump. A state-sharing witness family's world states are
`share`-classes of `(i, u)` pairs, quotiented only *within* a time: `(i,u)` and `(j,u)` can be
identified, `(i,u)` and `(i,u')` never are. The state space is infinite, no state recurs at two
times, and there is nothing to pigeonhole. The obstruction *shape* the document names
("recombined paths add histories that Box must range over") is real and is the reason (C1)/(C2)
must change; the probe's *conclusion* (no finite model for `ψ`) does not transfer.

### External Resources

- **Mathlib**: no new Mathlib lemmas are required. `Std.lean` already pins the `SuccPred` imports
  the `ℤ`-time instances need (`Mathlib.Data.Int.SuccPred`,
  `Mathlib.Order.SuccPred.LinearLocallyFinite`), and its header records the `@`-with-four-
  `inferInstanceAs` idiom that a branching twin must copy verbatim (a `haveI` shadows the
  `SuccOrder` instance `IsSuccArchimedean` is indexed by and fails to elaborate). `Finset`,
  `Quotient`, and `Setoid` from core/Mathlib cover the class construction.
- **Existing in-repo machinery to reuse rather than rebuild**:
  `FormalSystem/Semantics/HistoryMorphism.lean` and `FormalSystem/Semantics/TruthTransport.lean`
  (for transporting truth across the frame isomorphism that recovers the deterministic case);
  `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean` (the single-cycle template for
  the (C2') fixpoint); `Periodic.unrollOf` and `WitnessFamily/Decide.lean`'s window lemmas.
- **Cited literature (not consulted directly; recorded because ADEQUACY §7.1 names it for the
  adjacent A1 line)**: Gabbay-Kurucz-Wolter-Zakharyaschev, *Many-Dimensional Modal Logics*
  (2003), Theorems 3.29, 5.30, 5.32, 11.7, 11.21. Not needed for this task's deliverables.

### Recommendations

**R1. Add a `share` field; do not modify `LabelledLasso`.** The export contract
(`WitnessFamily/Basic.lean:31-35`) fixes `back`, `mid`, `fwd`, `bx`, `lassos`. Introduce a new
structure that *extends* `WitnessFamily` with one field, so the JSON export stays a prefix:

```lean
structure SharingWitnessFamily (Γ Del : Context) extends WitnessFamily Γ Del where
  shareBack : List (List (Fin toWitnessFamily.lassos.length × Fin toWitnessFamily.lassos.length))
  shareMid  : List (...)
  shareFwd  : List (...)
  shareBack_ne : shareBack ≠ []
  shareFwd_ne  : shareFwd ≠ []
  -- decoded by `Periodic.unrollOf`, so `Decide.lean`'s window lemmas apply unchanged
  share_equiv : ∀ u, Equivalence (fun i j => (i,j) ∈ shareAt u)
```

The exact field shape is a planning decision; the binding requirement is that `share` decode
through `Periodic.unrollOf` with the same three-segment scheme as `lab`, so that
`coherent_iff_window` (`Decide.lean:336`) and the four `*_shift_*` periodicity lemmas
(`:497, :513, :536, :566`) generalize by instantiation rather than by re-proof.

**R2. Define the frame directly; do not route through `ShiftSet`.** `ShiftSet.sh` is a function
and cannot express branching. Build a `FrameOver intOrder` whose `WorldState` is the quotient of
`Fin L × ℤ` by `share`-at-the-same-time, and whose `PosRel ⟦(i,u)⟧ d ⟦(j,u+d)⟧` holds iff there
is a length-`d` thread segment. Discharge `IsRegular` with: `comp` by thread
concatenation/splitting, `serial` by "every class continues" (immediate — each lasso continues),
`limit` by `TaskFrame.limit_of_succOrder`, `saturation` by `TaskFrame.saturation_of_fib_finite`.
`ShiftSet.lean` stays untouched.

**R3. The replacement for `total_eq_orbit` is a threads characterization.** Define

```lean
structure Thread (W : SharingWitnessFamily Γ Del) where
  idx : ℤ → Fin W.lassos.length
  step : ∀ u, W.share (u+1) (idx u) (idx (u+1))
```

and prove `total_eq_thread : ∀ σ : WorldHistory frame, ∃ θ : Thread W, ∃ s : ℤ,
∀ t, σ.state t = ⟦(θ.idx (s+t), s+t)⟧`. Unlike `total_eq_orbit` this is a two-directional
recursion over `ℤ` rather than a consequence of `respects_task 0` alone; budget a phase for it.
A `Thread` with `share = (· = ·)` is a constant function, so `Thread ≃ Fin L` there and the
statement degenerates to `total_eq_orbit`'s content.

**R4. Change (C1) and (C2); leave (C3) and (C4) alone.**

- (C0) **atom coherence** (new): `∀ u i j, share u i j → ∀ p, (Formula.atom p ∈ L i u ↔ Formula.atom p ∈ L j u)`.
  Required to make the class-level valuation well-defined. Decidable by window scan.
- (C1') **cross-step local coherence**: replace `W.L i (t+1)` by `W.L j (t+1)` universally
  quantified over `j` with `share (t+1) i j`, and dually for `snce` with `share t`:
  `∀ i j t, share (t+1) i j → (untl g e ∈ L i t ↔ (e ∈ L j (t+1) ∨ (g ∈ L j (t+1) ∧ untl g e ∈ L j (t+1))))`.
  The `bot`, `imp` and `box` clauses are unchanged. Decidable: one extra finite `∀ j`.
- (C2') **thread fulfilment**: `untl g e ∈ L i u` iff **every** thread through `(i,u)` delivers
  `e` with `g` throughout the gap. On the finite periodic position graph (vertices `(i, u)` for
  `u` in `[labCohWindowLo, labCohWindowHi)`, edges `(i,u) → (j,u+1)` when `share (u+1) i j`)
  this is the least fixpoint of `A[g U e]`, computable by `Finset` iteration bounded by the
  vertex count. Dual for `snce` on the reversed graph.
- (C3) `BoxFaithful` — **verbatim, no change**. Justification in the Executive Summary and in
  Codebase Patterns above.
- (C4) `Target` — unchanged.
- (C5) **stability** (new, only for the `⊡` language):
  `⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`. Decidable, one finite `∀ j`.

**R5. Recover the deterministic case by instantiation plus a frame isomorphism.** Define
`WitnessFamily.toSharing W` with `share u i j := decide (i = j)`, prove each new condition
reduces to its old counterpart, and prove a frame isomorphism
`sharingFrame (W.toSharing) ≅ W.std.frame`, transporting truth with
`Semantics/TruthTransport.lean` / `HistoryMorphism.lean`. **Caveat, stated plainly**: the two
frames are isomorphic, not definitionally equal (one is a `Quotient` of `Fin L × ℤ`, the other is
`Fin L × ℤ`), so "the existing agreement theorem and `Decidable` instances are specialized, not
re-proved" is achievable only up to that transport. Budget the transport; do not plan on `rfl`.

**R5b. Plug into `Refutes`, not into `WitnessFamily.std`.** Give the sharing family its own
`joint_countermodel`/`refutes_of_certifies` pair landing in the *same* `Refutes Γ Del`
(`Agreement.lean:269-272`). Because `Refutes` quantifies the frame existentially, this adds a
second producer for one interface and touches no existing proof. Reuse `decidableBoxFaithful`,
`instDecidableMemAll`, `instDecidableBoxClause` and `decidableTarget` verbatim; mirror the other
eleven.

**R6. Sorry-free path exists; no axioms.** Every step above is a finite construction or a
finite-graph fixpoint. The one place where a planner might be tempted to defer is (C2')'s
fixpoint termination proof; the standard discharge is well-founded recursion on the cardinality
of the shrinking `Finset` of "not yet known to fulfil" vertices, which is the same measure
`GoodCycle.lean` already uses in its single-cycle form. If any phase turns out not to close,
the correct response is to mark the task `[BLOCKED]` for user review, not to introduce `sorry`.

**R7. Suggested phase decomposition** (each phase ≈ one agent run, each ending green):

1. `share` field, its `Periodic.unrollOf` decoding, and the periodicity lemmas by instantiation.
2. The branching frame + `IsRegular` (the four discharges of R2).
3. `Thread` and `total_eq_thread` (R3).
4. (C0), (C1'), (C5) and their `Decidable` instances via the window reduction.
5. (C2') — the fixpoint, its correctness lemma, and its `Decidable` instance. Largest phase;
   consider splitting into "graph + fixpoint" and "correctness".
6. The agreement theorem for the sharing family, with (C3) reused verbatim.
7. `toSharing`, the frame isomorphism, and the specialization corollaries (R5); documentation
   updates to `WitnessFamily/README.md` and `BiLasso/README.md`.

## Decisions

- **D1.** Treat ADEQUACY's "redesigning condition (C3)" as refuted by the Lean reading, and say so
  explicitly in the plan and in any documentation this task writes, rather than silently
  diverging. The documentation this task touches should state that (C3) is recombination-stable
  because its right-hand side mentions only the label set.
- **D2.** Do not modify `FormalSystem/Semantics/ShiftSet.lean`. It is in this task's declared
  `file_scope` but the deterministic path depends on it and a sibling task also claims it. Any
  needed change there is a separate request.
- **D3.** Add the branching structure in new files under
  `FormalSystem/Metalogic/Decidability/WitnessFamily/` rather than editing `Basic.lean` and
  `Predicates.lean` in place beyond the minimum. The declared `file_scope` does not yet list the
  new files; the plan should extend it.
- **D4.** Encode `share` with the same three-segment periodic scheme as the labels. This is the
  decision that makes decidability fall out of existing lemmas rather than needing new ones.
- **D5.** Do not cite `Probe476.fmp_false` as an obstruction to this design. Cite it, accurately,
  as the refutation of the *time-free finite digraph* small-model hypothesis, which is what it is.

## Risks & Mitigations

| Risk | Sev | Lik | Mitigation |
|---|---|---|---|
| A plan built on ADEQUACY's literal Step 6 rewrites `BoxFaithful` and leaves (C1)/(C2) per-lasso, producing an unsound certificate that still type-checks | H | M | D1: state the correction in the plan's own words; make phase 4/5 the (C1')/(C2') work and phase 6 explicitly reuse (C3) unchanged |
| `ShiftSet.lean` edited by this task, regressing the shipped deterministic path | H | M | D2: read-only. Cite `total_eq_orbit` by name, never by line (a sibling task shifts those lines) |
| (C2')'s fixpoint phase overruns and invites a `sorry` | H | M | R7 splits it; `GoodCycle.lean`'s cardinality measure is the template; escalate to `[BLOCKED]` rather than defer |
| The frame isomorphism in R5 is assumed definitional and the specialization phase stalls | M | H | R5 states the caveat up front; `TruthTransport.lean`/`HistoryMorphism.lean` are the tools; budget the phase |
| Atom coherence (C0) is missed because the current design's header says atoms are "deliberately unconstrained" | H | M | Called out explicitly in Codebase Patterns and R4; the agreement theorem's `atom` case stops being `Iff.rfl` and that is the tell |
| The JSON export contract breaks when `share` is added | M | L | R1 extends rather than edits; `back`/`mid`/`fwd`/`bx`/`lassos` keep their names and positions |
| `share` encoded as a bare function, losing the window reduction and hence decidability | H | M | D4 makes the periodic encoding a hard requirement of the plan |
| Task-number citations leak into `FormalSystem/**` documentation | M | M | Cite durable anchors only (`total_eq_orbit`, `saturation_of_fib_finite`, `stab_iff_of_deterministic`, `Probe476.fmp_false`) |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This dispatch produced no open proof goals to
  attack: the deliverable is a design for structures and conditions that do not yet exist in the
  tree, so there was no position at which `lean_multi_attempt`, `lean_state_search` or
  `lean_hammer_premise` could be run. Every claim above was established by reading source
  in-tree. The first genuine tactic surface appears at R7 phase 2 (`IsRegular` discharges), where
  the four named helper lemmas (`limit_of_succOrder`, `saturation_of_fib_finite`,
  `compositional_reflect_of_reflective`, `serial_reflect_of_reflective`) are expected to close
  the goals by direct application.

## Context Extension Recommendations

- **Topic**: The determinism-vs-branching trade in the decision layer.
  **Gap**: No context file records which frame axiom has which discharge route under which
  hypothesis; the information is spread across `TaskFrame.lean`'s 2000+ lines and an external
  adequacy document.
  **Recommendation**: Add `context/project/lean4/domain/frame-axiom-discharge-routes.md` with the
  four-row table from Codebase Patterns above (axiom, statement line, deterministic route,
  branching route).
- **Topic**: Cross-repository claims that the Lean reading refutes.
  **Gap**: `docs/reference/transcription-audit-surface.md` tracks citation *location* drift but
  not citation *content* divergence; the (C3) finding is a content divergence.
  **Recommendation**: Extend that document (or add a sibling) with a "content divergence" table
  so a correction like D1 has a durable home outside a task report.

## Appendix

### Search queries and commands used

- `grep -rln "lasso\|Lasso" --include="*.lean"` (excluding `.lake`) — module inventory
- `grep -rn "total_eq_orbit"` across `*.lean`, `*.md`, `*.typ` — every use site, in-repo and in
  task artifacts
- `grep -n "theorem saturation_of_fib_finite\|...\|def Saturation\|def Limit\|..." -A 14 FormalSystem/Semantics/TaskFrame.lean`
- `grep -n "stab" -B3 -A10 FormalSystem/PlusLanguage/PlusTruth.lean`
- `grep -n "C3" ~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
- `jq '.active_projects[] | select(.project_number==683)' specs/state.json` — declared `file_scope`
- No rate-limited Mathlib search tool was needed; no MCP tool failures occurred.

### Line-anchored citations

- `FormalSystem/Semantics/ShiftSet.lean:201-204` — `fibre`, the functional `PosRel`
- `FormalSystem/Semantics/ShiftSet.lean:261-266` — `total_eq_orbit`
- `FormalSystem/Semantics/ShiftSet.lean:302-307` — the `box` case that consumes it
- `FormalSystem/Semantics/TaskFrame.lean:683-685` — `Saturation`
- `FormalSystem/Semantics/TaskFrame.lean:828-829` — `Limit`
- `FormalSystem/Semantics/TaskFrame.lean:1591-1599` — `limit_of_succOrder`
- `FormalSystem/Semantics/TaskFrame.lean:2181-2188` — `saturation_of_fib_subsingleton`
- `FormalSystem/Semantics/TaskFrame.lean:2222-2236` — `saturation_of_fib_finite`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean:31-35` — the export contract
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean:75-88` — `LabelledLasso`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean:72-117` — (C1)-(C4)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean:64-70` — `std`, the determinism
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean:94-97` — `sh_surj`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean:325-336` — the window reduction
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean:125, 209, 282` —
  `shiftTruth_iff_mem`, `truth_iff_mem`, `refutes_of_certifies`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean:269-272` — `Refutes`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean:936` — `decidableCertifies`
- `FormalSystem/PlusLanguage/PlusTruth.lean:84-93` — `PlusTruthAt`, the `box` and `stab` clauses
- `FormalSystem/PlusLanguage/PlusDeterminism.lean:104-113` — `states_eq_of_deterministic`
- `FormalSystem/PlusLanguage/PlusDeterminism.lean:123` — `stab_iff_of_deterministic`
- `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` — `plusTruthAt_iff_atomize`
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean:1-13`
  — `Probe476.fmp_false`
- `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md:306-341`
  — "Why the design is deterministic"; `:548-641` — §7.1 (A1, open)
