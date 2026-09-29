# Sharing — State-Sharing Witness Families and the Branching Certificate

A `WitnessFamily` presents a model whose task relation is **functional**: from a lasso index and
a time there is exactly one successor, the same lasso one step later. A
`SharingWitnessFamily` adds a per-time equivalence on lasso indices — at time `u`, indices `i`
and `j` may name the *same* world state — so a history can cross from one lasso to another at a
shared state and the presented task relation **branches**.

This directory is an **addition**. Nothing in it edits `../Basic.lean`, `../Predicates.lean`,
`../Std.lean`, `../Agreement.lean` or `../Decide.lean`, and nothing edits
`../../../../Semantics/ShiftSet.lean`. The deterministic device is recovered as the instance
where every representative map is the identity (`Specialize.lean`), so the two coexist as two
producers for the one `WitnessFamily.Refutes` interface rather than as rival developments.

## Modules

| Module | Lines | Role |
|--------|-------|------|
| `Skeleton.lean` | 944 | **`SharingSkeleton`**, the label-free branching substrate: `rep`, `share`, `Thread`/`Step`/`ReachN`, the quotient frame and all four `def:frame` constraints, `hist` and `total_eq_thread` |
| `Basic.lean` | 208 | `SharingWitnessFamily`, its `skeleton` projection, and the re-exports of `rep`, `share`, the equivalence laws and the two periodicities |
| `Thread.lean` | 179 | Re-exports of `Thread` (the branching analogue of a lasso orbit), the class-level `Step`, `ReachN` and its four congruences |
| `Frame.lean` | 258 | Re-exports of `shareSetoid`, `WorldState`, the duration-free `Conn`, the two-sided `RelZ`, the `FrameOver intOrder` `frame`, and all four `def:frame` constraints |
| `Histories.lean` | 105 | Re-exports of `hist`, `thread_is_history` and **`total_eq_thread`** — the replacement for `ShiftSet.total_eq_orbit` |
| `Predicates.lean` | 226 | (C0) `AtomCoherent`, (C1') `LocalCoherentShare`, (C2') `ThreadFulfilling`, and the two unconditional reductions to the deterministic conditions |
| `Decide.lean` | 567 | The combined window, the two window collapses, and the instances for (C0) and (C1') |
| `Fulfil.lean` | 1669 | The finite position graph, the `A[g U e]` least fixpoint, (C2')'s correctness in both directions, and the (C1')-relative decision procedure |
| `Agreement.lean` | 411 | The branching `model`, the two inner inductions along a thread, **T1** `truth_iff_mem`, the bundle `Certifies`, `decidableCertifies`, and `refutes_of_certifies` |
| `Specialize.lean` | 455 | `WitnessFamily.toSharing`, the four condition reductions, `certifies_toSharing`, the frame isomorphism `stateEquiv`/`histEquiv`/`truthIso` and the transported agreement |

## The substrate is label-free, and lives on `SharingSkeleton`

`Basic.lean`, `Thread.lean`, `Frame.lean` and `Histories.lean` were together 1,065 lines, and
across all four the tokens `Formula`, `.L `, `.lab` and `.bx` occurred **zero** times. The
substrate is not *approximately* language-agnostic; it is exactly language-agnostic, and the
`Formula` indexing it carried was incidental.

`SharingSkeleton` (`Skeleton.lean`) is that datum on its own: an index count `n`, three periodic
segments of representative maps `Fin n → Fin n`, and — since the succession redesign — three
further segments of Boolean succession matrices `Fin n → Fin n → Bool` at the representatives'
own periods, plus the `lift` field they create. Every construction the branching device is built
from — `share`, the threads, the quotient frame over `intOrder`, and the world histories that
frame admits — is a function of it, and `SharingWitnessFamily.skeleton` is the projection
through which the family inherits the whole theory rather than re-proving it.

**The fourth datum, and why it is there.** `share u i j` answers "do `i` and `j` name the same
world state at `u`". `trans u i j` answers "may a history on `i` at `u` continue on `j` at
`u + 1`". While `Thread.step` read `share (u+1) (idx u) (idx (u+1))`, one relation carried both
questions, and a backward coherence clause written in the only relation available could not help
but quantify over the `⊡` modality's own class. Separating them is what the redesign did; the
correction below records the defect that forced it and the certificates that now exist because of
it.

`trans` is **arrival-pruned**: `trans u i j` is `transRaw u i j = true ∧ share (u+1) i j`, the
raw succession bit conjoined with the arrival share. That second conjunct is what keeps the frame
untouched — `Step u i j := ∃ i', share u i i' ∧ share (u+1) i' j` is byte-identical to what it
was, and every frame lemma with it — while still letting succession be strictly sparser than
state-identity.

**`lift` is a genuine obligation.** While succession *was* `share (u+1)`, "every world history is
a thread's trace" came free: a `Step`-path's own intermediates already formed a thread. Once
succession is a separate relation a `Step`-path may cross between indices that no `trans`-step
connects, so `LiftableRaw` has to be demanded rather than derived, and it is demanded label-free,
beside `rep_idem`, which is what keeps `total_eq_thread` stated exactly as it was. The field is
not defensive: `specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean` gives
the landed (C5) witness the no-hopping succession bundle, changes nothing else, and shows
`LiftableRaw` becomes false.

Three sufficient conditions discharge `lift` in practice, all in `Skeleton.lean`:
`liftable_of_transFullOf` for a producer that does not mean to constrain succession at all (and
which every pre-redesign producer uses, so the fourth datum changed no theorem's content);
`liftable_of_constant_below` and its mirror `liftable_of_constant_above` for a producer that is
discrete on one side of a cut and shares totally on the other, which is the shape both gate
families have.

The four modules above are therefore re-export shells. Every name they have always exported still
resolves at its original statement and with its original implicit/explicit argument structure;
nothing downstream — `Predicates.lean`, `Decide.lean`, `Fulfil.lean`, `Agreement.lean`,
`Specialize.lean` — was edited for the split.

Two mechanisms in the shells are worth knowing about before editing them:

* `SharingWitnessFamily.skeleton` is `@[reducible]`, so `Fin S.skeleton.n` and
  `Fin S.lassos.length` unify at the transparency `rw`'s keyed matching uses. Without it,
  rewrites whose pattern mentions `share` fail against terms whose indices came from a thread.
* `SharingWitnessFamily.Thread.step` and `SharingWitnessFamily.Conn` are restated rather than
  delegated: the first so that dot notation on a family thread yields a proposition phrased at
  the family's own `share`, the second so that `unfold SharingWitnessFamily.Conn` still exposes
  the `if` that `Specialize.lean` splits on. Both are the same proposition as the skeleton's, and
  each is proved once, on the skeleton.

Why this matters beyond tidiness: a certificate indexed by a *different* formula type — the
L⁺ certificate that states the stability condition (C5) natively over `PlusFormula.stab` —
projects onto the same `SharingSkeleton` and inherits these 944 lines rather than duplicating
them.

## `share` is the kernel of a map, not a relation field

The sharing datum could have been three lists of *relations* on `Fin |lassos|` together with a
proof that each is an equivalence. It is instead three lists of **representative maps**
`Fin |lassos| → Fin |lassos|`, decoded by the same `Periodic.unrollOf` scheme that decodes the
labels, with

```
share u i j  :=  rep u i = rep u j
```

Two consequences, both deliberate:

* `share u` is an equivalence relation *for free* — it is the kernel of a function — so
  `share_refl`, `share_symm` and `share_trans` are `rfl`, `Eq.symm` and `Eq.trans`, and the
  structure carries no `share_equiv` field to discharge.
* The datum decodes through `Periodic.unrollOf`, so the leftward and rightward periodicities are
  instantiations of `Periodic.unrollOf_sub_back_length` and `Periodic.unrollOf_add_fwd_length`
  with no new arithmetic, and the window reduction that makes the label conditions decidable
  applies to the sharing conditions by the same argument.

The out-of-range default of the decoding is the identity map, so outside the three encoded
segments `share` degenerates to equality — the deterministic reading — rather than to an
arbitrary collapse. `rep_idem` is not needed for the equivalence laws; it is what makes the
decoded map an honest *choice of representatives*, which the quotient carrier and the
specialization consume.

The parent's five fields — `back`, `mid`, `fwd`, `bx`, `lassos` — are inherited, not
re-declared, so the model checker's JSON export contract is unchanged. `repBack`, `repMid` and
`repFwd` extend it additively.

## The thread characterization replaces the orbit characterization

`ShiftSet.total_eq_orbit` says that every world history of the deterministic device's frame is
a lasso orbit. It is true **because the task relation is functional**: `respects_task 0` alone
pins every state. Once two lassos may share a state, a history can cross between them and that
argument fails.

`Histories.lean`'s `total_eq_thread` is the replacement: every world history of
`SharingWitnessFamily.frame` is the trace of a **thread** — a bi-infinite choice of lasso index
that only ever changes across a shared state — from some time offset, and conversely every
thread traces a world history (`thread_is_history`).

Two details worth not rediscovering:

* **A thread cannot be time-shifted.** `share` is decoded from three periodic segments indexed
  by *absolute* time, so `share u` and `share (u + d)` are different relations for a general
  `d`. Time offsets therefore live in the history's parametrization — `total_eq_thread` carries
  an explicit `s : ℤ` and reads `θ.idx (s + t)` at time `s + t` — never in the thread.
* **`Thread`'s step field is `trans u (idx u) (idx (u+1))`**, the arrival-pruned succession
  relation, narrower than the frame's `Step u i j = ∃ i', share u i i' ∧ share (u+1) i' j` and —
  since the redesign — narrower than `share (u+1) (idx u) (idx (u+1))` too. Arrival pruning still
  gives the sharing fact, which is what `thread_share_succ` exports and what every consumer that
  predates the redesign reads. What it no longer gives is the converse: not every pair sharing
  the arrival state is a step, and that gap is exactly the room the redesign bought.
* **`total_eq_thread` is now proved from `lift`.** Its extraction half is unchanged: a world
  history yields a `Step`-path. Its gluing half used to observe that the path's own intermediates
  were consecutive in `share (u+1)`, hence a thread; with succession a separate relation that no
  longer follows, and the tracking path is supplied by the skeleton's `lift` field instead. The
  statement is byte-identical.

## Which conditions break under recombination, and which do not

| Condition | Status | Why |
|---|---|---|
| (C0) `AtomCoherent` | **new, mandatory** | The branching carrier is a quotient, so the valuation reads a `share`-class; a `Quotient.lift` needs shared indices to agree on atoms. Without it the valuation is not even well defined |
| (C1) `LocalCoherentLab` | **replaced** by (C1') `LocalCoherentShare`, over `trans` | Its two temporal clauses are stated per lasso, silently assuming a history never leaves the lasso it starts on. The branching form quantifies the `untl` unfolding over succession *out of* `t` and the `snce` unfolding over succession *into* it. An earlier version quantified both over `share`-classes and collapsed branching on both temporal sides; see the correction below for that defect and for the repair |
| (C2) `FulfillingLab` | **replaced** by (C2') `ThreadFulfilling` | It reads an eventuality's discharge off the one lasso the label sits on. The branching form is a universal path quantifier — `A[g U e]` — over every thread through the position |
| (C3) `BoxFaithful` | **reused verbatim** | See the correction below |
| (C4) `Target` | **reused verbatim** | It names a time on the main lasso and mentions neither the frame nor its histories |

### Correction: (C3) is recombination-stable

`WitnessFamily.BoxFaithful` reads

```
bx χ = true ↔ ∀ i t, χ ∈ W.L i t
```

Its right-hand side quantifies over the **label pool** — every position of every lasso — and
mentions no history, no orbit and no task relation. A recombined history visits the positions
`(θ.idx t, t)`, each of which is one of those same positions, so recombination adds **no new
label** for `□` to range over and the condition's content is unchanged. `Agreement.lean` applies
it unchanged, and the `box` case of the truth lemma is grounded in `total_eq_thread` rather than
in a redesigned condition.

The received account of this design named (C3) as the load-bearing obstruction requiring
redesign. The Lean reading refutes that: the two conditions that genuinely break are (C1) and
(C2), both of which are stated *per lasso*. What (C3) needs is not a new statement but a new
histories characterization underneath it, which is what `total_eq_thread` supplies.

### Correction: (C1') over `share` was not a repair; (C1') over `trans` is

The received account of this design named (C1') as *the* fix for recombination, with no
qualification. The Lean reading refuted that for the clause as originally written, and the
substrate redesign is what restored it. Both halves are machine-checked, and this section records
them in that order because the second is only intelligible as an answer to the first.

**The defect.** The two clauses looked asymmetric, and an earlier version of this section read
that asymmetry as a half-repair. The `snce` clause quantified its predecessor over the
`share`-class at the label's **own** time `t`; the `untl` clause quantified its successor over
the class at `t+1`. Read the `snce` clause twice — once at `i` with the shared index `j`, once at
`j` with itself, using reflexivity of `share` — and it forced any two indices naming the same
world state at `t` to agree on every `snce` formula of the closure. Past-tense truth in a
presented model was a function of the world state, which is exactly the backward branching (C1')
was supposed to admit.

The `untl` clause's extra step bought nothing. Reading it at `t - 1` instead of at `t` turned
`share t i j` into `share ((t-1)+1) i j`, so the one clause at `(i, t-1)` applied to both `i` and
`j`, and the two readings forced class agreement on the one-step unfolding at `t`. The collapse
was displaced by one step, not avoided — which is why re-timing one clause to match the other was
never a repair.

The price was a completeness failure on both sides: no six-condition L⁺ family certified any
instance of `(g S e) → ⊡(g S e)` or of `Fp → (¬p → ⊡Fp)`, while both targets are genuine ℤ-time
non-validities. Five declarations in `PlusWitnessFamily/Incompleteness.lean` recorded that, and
all five are now retired.

**The rule of thumb** the defect exposed, stated once because it will recur: a condition that
quantifies over the one-step **reach** of a position collapses whenever that reach is a whole
`share`-class — at either time, and whichever temporal direction it points. Naming `t+1` rather
than `t` is not what matters; being a `share`-class is. A condition is recombination-stable
exactly when its quantifier ranges over something *other* than a class, which is why (C3)
survives verbatim: its right-hand side quantifies the label pool and mentions no class at all.

**Where the asymmetry came from.** Not from the clause's wording, and so not fixable by
re-wording it. `Thread.step` read `share (u+1) (idx u) (idx (u+1))`: one-step succession was
*defined* as membership of the same `share`-class at the arriving time. The single relation
therefore carried two jobs — the `⊡` quantifier's class, and the thread's step — and a backward
clause written in terms of the only relation available could not help but quantify over the
class.

**The repair.** `SharingSkeleton` gained the fourth periodic datum described under *The substrate
is label-free* above, `Thread.step` became `trans u (idx u) (idx (u+1))`, and (C1')'s two clauses
were re-quantified: the `untl` clause over `S.trans t i j`, the `snce` clause over
`S.trans (t-1) k i`. The two are now symmetric — succession out of `t`, succession into `t` —
rather than one reading a class at `t` and the other a class at `t+1`. Succession is strictly
finer than state-identity at a time, so the doubled clause reading that produced the congruences
no longer type-checks.

**The evidence that the repair is real, not cosmetic.** A redesign can reproduce a defect in a
differently-spelled clause and still break the old proof term, so "the old theorem no longer
elaborates" settles nothing. Four theorems settle it.

* `PlusWitnessFamily/Examples.lean`'s `plusCertifies_stabSnce_example` and
  `plusCertifies_stabUntl_example` are six-condition certificates, at `t = 0`, for the two
  targets no family could certify before. Their sharing is **non-trivial**: Family A's indices
  `0` and `1` name one world state from the origin on, Family B's up to and including it, and in
  each case the two indices disagree on the relevant label at the origin.
* `Incompleteness.lean`'s `not_snce_share_congr` and `not_untl_shift_share_congr` *refute* the
  two retired congruence statements on those same families. The redesigned (C1') therefore does
  not merely fail to prove them; it is satisfied by families on which they are false.

Both families get their non-trivial sharing from the no-hopping succession bundle `transIdOf`:
succession is index-identity while sharing is not, which is precisely the separation the single
relation made inexpressible.

**A position is a history type, and some neighbour agreement is therefore forced.** The repair
does not, and should not, drive the residual agreement to nothing. An index at a time names a
*history type* — a full bi-infinite labelling, not a world state — so two indices standing in the
succession relation still constrain one another's labels at the one step they share.
`Sharing/Agreement.lean` states exactly how much, as `untl_succ_congr` and `snce_pred_congr`:
all the successors of one position agree on the `untl` unfolding, and all its predecessors agree
on the `snce` unfolding. That is what a position *being* a history type requires, and it is not a
relapse: the defect was never neighbour agreement, it was neighbour agreement over a class that
the `⊡` quantifier also ranges over. Two indices sharing a state at `t` need not have a common
successor, and that gap is where the certificates live.

Nothing here touches soundness. `Agreement.lean`'s truth lemma and `refutes_of_certifies` are
unaffected across the whole redesign, and their statements are byte-identical to their
pre-refactor form.

## Deciding (C2'): the finite position graph and the `A[g U e]` fixpoint

The walks of a branching structure are infinitely many, so decidability is the hard constraint,
not the conditions themselves. `Fulfil.lean` folds the bi-infinite position space onto a finite
position graph over the combined window, computes the `A[g U e]` least fixpoint over that graph,
and connects the two by the same window reduction that decides (C0) and (C1').

**A recorded limitation.** The window reduction for (C2') carries a `LocalCoherentShare`
hypothesis: its far-left case is closed by (C1') propagation, not by folding. There is therefore
**no standalone `Decidable (ThreadFulfilling S)`**; what `Fulfil.lean` exports is a hypothesised
`Decidable` term (`decidableThreadFulfilling`) plus a genuine instance on the conjunction,
`decidableCoherentShareAndFulfilling`. `Certifies` nests (C1') and (C2') as a single conjunct so
that `decidableCertifies` is a bare `inferInstanceAs` over four instances rather than five.
Nothing downstream loses anything, because the bundle carries (C1') either way. Closing the gap
would need the position graph's backward region to carry a cycle edge `-1 → -NB-1` alongside
`-1 → 0`, and the fixpoint lemmas re-proved against the strictly larger walk set; that is a
possible future refinement, not a defect.

## `Probe476.fmp_false` does not bear on this design

`Probe476.fmp_false` refutes a finite model property for **time-free finite digraphs**: it shows
there is no candidate-list function assigning each non-valid formula a finite `IntPresentation`
satisfying that formula's negation at one of its states. Its engine is a pigeonhole step that
collapses a finite digraph's states, and that step has **no analogue here**, because the time
coordinate stays in the carrier: `SharingWitnessFamily.WorldState` is a quotient of
`Fin |lassos| × ℤ` that never identifies pairs at different times, so the carrier is infinite by
construction and nothing is being pigeonholed into a finite state set.

The probe is therefore a reason to prefer a *labelled family* over a finite presentation as the
searched object — which is why `../Basic.lean` cites it — and is **not** an obstruction to
admitting recombined histories. Citing it as one confuses the finiteness of the certificate with
the finiteness of the model it presents; only the first is claimed.

## (C5), the stability clause: not here, and why

### (a) It is not part of this device

`WitnessFamily` is indexed by `FormalSystem.Syntax.Context = List Formula`, and
`FormalSystem.Syntax.Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`,
`untl`, `snce`. The stability modal `⊡` is `FormalSystem.PlusLanguage.PlusFormula.stab`, a
constructor of a **separate inductive** (`PlusLanguage/Formula.lean` records the
separate-inductive decision and the constructor-to-constructor embedding). There is therefore no
`⊡φ` to write on the left of a stability clause at this datatype, and the agreement induction in
`Agreement.lean` is complete over six constructors with no `⊡` case missing.

### (b) What this device nonetheless delivers for it

`FormalSystem.PlusLanguage.states_eq_of_deterministic` shows that on a frame whose task relation
is functional, any two histories through a common state agree at every time, and
`FormalSystem.PlusLanguage.stab_iff_of_deterministic` turns that into the collapse `⊡φ ↔ φ` at
every point. The deterministic witness device presents a frame whose task relation *is*
functional, so both apply and `⊡` is the identity there: the device is blind to the stability
modal **by construction**, not merely incomplete for it, and cannot be repaired by adding a
truth clause.

`SharingWitnessFamily.frame`'s task relation is not functional — a state shared by two lassos
has one successor per lasso through it — so neither lemma applies to it and the collapse does
not hold. That is precisely the obstruction a stability modal was blocked on, and it is what
this directory removes.

### (c) What the follow-up delivered

An L⁺-indexed certificate datatype: `LabelledLasso`, `closureOf`, `WitnessFamily`, its
conditions and its agreement theorem all re-indexed over `PlusFormula`. That landed as
`../../PlusWitnessFamily/`.

What it revealed is that the re-index alone was not enough, and the remaining obligation was at
the substrate level rather than the label level. That obligation has since been discharged too.
`SharingSkeleton` now carries a **fourth periodic datum** beside `repBack`/`repMid`/`repFwd`:
three lists `transBack`/`transMid`/`transFwd` of Boolean matrices, decoded by the same
`Periodic.unrollOf` scheme and carrying the representatives' own periods, giving the
arrival-pruned relation `trans u : Fin n → Fin n → Prop`. `Thread.step` reads
`trans u (idx u) (idx (u+1))`, which splits the two jobs the single relation used to carry:

* `share` keeps the `⊡` quantifier, the quotient carrier, (C0) and (C5) — everything that asks
  "which indices name this state now";
* `trans` carries one-step branching — everything that asks "which index may follow this one".

The datum brought one obligation with it, `lift`, and the *substrate* section above says why it
cannot be derived. The non-vacuity gate the design asked for was met before the record was
retired, on both temporal sides and by construction: see the (C1') correction above for the two
certificates and the two refutations.

**(C2')'s recorded limitation was re-examined, not inherited by default.** It survives, and the
reason it survives is now known. Its window reduction's far-left and far-right cases consume
exactly the relation `θ.step` supplies, so the re-quantification transferred verbatim and needed
no new hypothesis. The limitation is about the backward region of the position graph being a
path rather than a cycle — a statement about the *graph*, not about the substrate datum — which
is why changing the datum did not touch it. It is restated below.

**Deferred: exact closure.** The `lift` field is discharged in practice by one of three
sufficient conditions (`liftable_of_transFullOf`, `liftable_of_constant_below`,
`liftable_of_constant_above`), each strictly stronger than `LiftableRaw` itself. A decidable
window-local characterization — `LiftWindow`, `liftable_of_liftWindow` and
`Decidable LiftWindow` — would let a producer's `lift` obligation be *checked* rather than
supplied by a matching sufficient condition. That is named follow-up work and is deliberately not
part of this design.

## Hand-off to the consuming model checker

Nothing in the consuming repository is edited by this work, and no existing certificate becomes
invalid: a deterministic certificate remains a deterministic certificate, checked by the
unchanged `WitnessFamily` path. To *emit* a sharing certificate instead, a checker would need to
add three fields to what it already exports and nothing else:

* `repBack`, `repMid`, `repFwd` — three lists of representative maps on the lasso index set,
  the same three-segment periodic shape as the existing `back`/`mid`/`fwd` label segments, with
  the two cycles non-empty. An index map is exportable as a list of naturals of length
  `|lassos|`.
* Each listed map must be **idempotent**, which is the `rep_idem` field: it is what makes the
  map a choice of class representatives rather than an arbitrary function. A checker that
  computes classes and then picks each class's least member satisfies it automatically.
* `transBack`, `transMid`, `transFwd` — three **optional** lists of Boolean succession matrices
  on the same index set, one matrix per entry of the corresponding `rep` list, so
  `|transBack| = |repBack|` and likewise for the other two. A matrix is exportable as
  `|lassos|` rows of `|lassos|` booleans. Every listed matrix must be reflexive, which is the
  `trans_refl` field: staying on one index is always a legitimate step.
* **Absent means full.** A checker that omits the three succession lists is read as supplying
  the all-true matrix at every time, which is exactly the pre-redesign substrate: succession is
  then the arrival share and nothing changes. This is what makes the extension **additive** —
  every certificate emitted before the redesign is still a valid certificate, unchanged, and no
  consumer is required to compute a succession relation it has no use for.
* The existing five fields (`back`, `mid`, `fwd`, `bx`, `lassos`) are unchanged in name,
  meaning and shape.

A checker that *does* emit succession lists takes on one further obligation, the skeleton's
`lift` field: every `Step`-path of the presented frame must be tracked, up to `share`, by a
succession path. It is not checkable from the three lists alone, and it is not vacuous — see the
*substrate* section above. In practice a checker discharges it by emitting a succession relation
of one of the three recognized shapes (free, or discrete on one side of a cut and total on the
other), each of which has a lemma in `Skeleton.lean` that closes the obligation outright.

On the checking side the accepting branch changes from `WitnessFamily.refutes_of_certifies` to
`SharingWitnessFamily.refutes_of_certifies`, whose codomain is the **same**
`WitnessFamily.Refutes Γ Del`; a consumer written against `Refutes` needs no change at all, and
that is true across the succession redesign as well — the codomain did not move. The conditions
to decide become five rather than four, with (C1') and (C2') decided jointly.

## The deterministic device as the diagonal instance

`Specialize.lean` sets all three representative segments to `id`, so `share u i j ↔ i = j`, and
proves:

* (C0) holds unconditionally — which is the explanation of `../Predicates.lean`'s deliberate
  omission of an atom clause;
* (C1') ↔ (C1) and (C2') ↔ (C2), the converses of the two unconditional implications in
  `Predicates.lean`, available only at the diagonal because every thread there is constant;
* `certifies_toSharing`, assembling the branching bundle from the deterministic one;
* `stateEquiv` / `histEquiv` / `truthIso`, exhibiting `(W.toSharing).frame` and `W.std.frame` as
  isomorphic and transporting truth across, with `truth_iff_mem_toSharing` the branching
  agreement theorem read in the deterministic model.

**The isomorphism is not an equality.** `W.std.frame`'s carrier is `Fin |lassos| × ℤ`;
`(W.toSharing).frame`'s is a quotient of that type by equality. A quotient by equality is
equivalent to what it quotients, never equal to it, so `Quotient.lift id` and `Quotient.mk` are
mutually inverse but the two types are distinct. The `histEquiv` round trip is the cost of that,
and it cannot be collapsed to `rfl`.

## Dependencies

Within the repository: `../Basic.lean`, `../Predicates.lean`, `../Closure.lean`, `../Std.lean`,
`../Agreement.lean` and `../Decide.lean` (all read, none modified);
`../../BiLasso/Periodic.lean` for the three-segment decoding; `Semantics/TaskFrame.lean`,
`Semantics/Truth.lean`, `Semantics/TruthTransport.lean`, `Semantics/Validity.lean` and
`Semantics/FrameClassValidity.lean`. From Mathlib: `Data.Fintype.Pi`, `Data.Int.SuccPred` and
`Order.SuccPred.LinearLocallyFinite`.

## Related Documentation

- `../README.md` — the deterministic device and the soundness-half scope statement
- `../../BiLasso/README.md` — the single-lasso development and its stability-modal scope note
- `FormalSystem/PlusLanguage/PlusDeterminism.lean` — `states_eq_of_deterministic` and
  `stab_iff_of_deterministic`, the two lemmas the stability discussion above turns on
- [PlusWitnessFamily README](../../PlusWitnessFamily/README.md) — the landed L⁺ re-index, and
  the empty certificate class that bounds what it can refute
