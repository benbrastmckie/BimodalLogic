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

`SharingSkeleton` (`Skeleton.lean`) is that datum on its own: an index count `n` and three
periodic segments of representative maps `Fin n → Fin n`. Every construction the branching device
is built from — `share`, the threads, the quotient frame over `intOrder`, and the world histories
that frame admits — is a function of it, and `SharingWitnessFamily.skeleton` is the projection
through which the family inherits the whole theory rather than re-proving it.

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
* **`Thread`'s step field is the tight one**, `share (u+1) (idx u) (idx (u+1))`, narrower than
  the frame's `Step u i j = ∃ i', share u i i' ∧ share (u+1) i' j`. That costs nothing, because a
  history's index at `u` may be chosen *knowing* the step it is about to take: the witness `i'`
  supplied by `Step` is itself a legitimate name for the state at `u`, and is what the thread
  records. There is no two-directional recursion and no gluing.

## Which conditions break under recombination, and which do not

| Condition | Status | Why |
|---|---|---|
| (C0) `AtomCoherent` | **new, mandatory** | The branching carrier is a quotient, so the valuation reads a `share`-class; a `Quotient.lift` needs shared indices to agree on atoms. Without it the valuation is not even well defined |
| (C1) `LocalCoherentLab` | **replaced** by (C1') `LocalCoherentShare`, and only half repaired | Its two temporal clauses are stated per lasso, silently assuming a history never leaves the lasso it starts on. The branching form quantifies the `untl` unfolding over every shared successor and the `snce` unfolding over every shared predecessor. The `untl` half is a genuine repair; the `snce` half collapses backward branching, at a completeness price the received account did not record. See the correction below |
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

### Correction: (C1') is only half a repair

The received account of this design named (C1') as *the* fix for recombination, with no
qualification. The Lean reading shows it is only half a fix, and the other half fails.

The two temporal clauses are not symmetric, although they read as though they were. The `untl`
clause quantifies its successor **forward along a thread**, so it says nothing about two indices
at a single time. The `snce` clause quantifies its predecessor over the `share`-class at the
label's **own** time `t`. Read that clause twice — once at `i` with the shared index `j`, once at
`j` with itself, using reflexivity of `share` — and it forces any two indices naming the same
world state at `t` to agree on every `snce` formula of the closure. Past-tense truth in a
presented model is a function of the world state, which is exactly the backward branching (C1')
was supposed to admit.

The price is a completeness failure, machine-checked on the L⁺ side where the stability modal
exists to observe it. `PlusWitnessFamily/Incompleteness.lean` proves that no six-condition L⁺
family certifies any instance of `(g S e) → ⊡(g S e)` — `not_plusCertifies_stabSnce`, and
`not_plusCertifies_stabSnce_premise` for the negated-premise placement — while
`not_plusValidZTime_stabSnce` shows `Pp → ⊡Pp` is a genuine ℤ-time non-validity. The certificate
class is *empty* for those targets, not merely large. `snce_share_congr` is the one-line root
cause, and it uses (C1') and nothing else.

**The rule of thumb**, stated once because it will recur: a condition that quantifies over the
`share`-class at a label's **own** time forces the class to agree on that label. Conditions that
quantify forward or backward along a thread do not. So a condition is recombination-stable exactly
when its quantifier leaves the class, which is why (C3) survives verbatim — its right-hand side
quantifies the label pool and mentions no class at all.

**Where the asymmetry comes from.** Not from the clause's wording, and so not fixable by
re-wording it. `Thread.step` reads `share (u+1) (idx u) (idx (u+1))`: one-step succession is
*defined* as membership of the same `share`-class at the arriving time. The single relation
therefore carries two jobs — the `⊡` quantifier's class, and the thread's step — and a backward
clause written in terms of the only relation available cannot help but quantify over the class.
Separating those two jobs is a substrate change, not a clause change; `### (c) What a follow-up
needs` below states what it takes.

Nothing here touches soundness. `Agreement.lean`'s truth lemma and `refutes_of_certifies` are
unaffected, and a family meeting the conditions still presents a genuine countermodel. What is
refuted is the claim that (C1') restores completeness under recombination.

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

### (c) What a follow-up needs

An L⁺-indexed certificate datatype: `LabelledLasso`, `closureOf`, `WitnessFamily`, its
conditions and its agreement theorem all re-indexed over `PlusFormula`. That re-indexing also
re-opens the model checker's JSON export contract, since the exported label sets would carry
`PlusFormula` rather than `Formula`. It is a separate, substantial addition, not a clause.

That re-index has since landed, as `../../PlusWitnessFamily/`. What it revealed is that the
re-index alone is not enough, and the remaining obligation is at the substrate level rather than
at the label level — see the (C1') correction above for the obstruction.

A follow-up needs a **fourth periodic datum** beside `repBack`/`repMid`/`repFwd`: three lists
`transBack`/`transMid`/`transFwd`, decoded by the same `Periodic.unrollOf` scheme, giving a
one-step relation `trans u : Fin n → Fin n → Prop`. `Thread.step` then reads
`trans u (idx u) (idx (u+1))` rather than `share (u+1) (idx u) (idx (u+1))`, which splits the two
jobs the single relation currently carries:

* `share` keeps the `⊡` quantifier, the quotient carrier, (C0) and (C5) — everything that asks
  "which indices name this state now";
* `trans` carries one-step branching — everything that asks "which index may follow this one".

Two consequences to plan for. The export contract gains three fields, additively, exactly as
`repBack`/`repMid`/`repFwd` did, so the model checker is not re-opened beyond that. And the
re-proof surface is large: `Predicates.lean`, `Decide.lean`, `Fulfil.lean`, `Agreement.lean` and
`Specialize.lean` here, their four counterparts on the L⁺ side, and both READMEs, with the two
`Fulfil.lean` modules dominating.

The **non-vacuity gate comes first**, before the fixpoint layer is re-proved: one concrete family
satisfying all six redesigned conditions at non-trivial sharing, plus a check that the redesigned
(C1') no longer entails `snce_share_congr`. Without that second check the redesign can reproduce
the present defect while type-checking. Note also that (C2')'s window reduction already carries a
recorded (C1')-relative limitation (below), which the redesign has to re-examine rather than
inherit.

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
* The existing five fields (`back`, `mid`, `fwd`, `bx`, `lassos`) are unchanged in name,
  meaning and shape.

On the checking side the accepting branch changes from `WitnessFamily.refutes_of_certifies` to
`SharingWitnessFamily.refutes_of_certifies`, whose codomain is the **same**
`WitnessFamily.Refutes Γ Del`; a consumer written against `Refutes` needs no change at all. The
conditions to decide become five rather than four, with (C1') and (C2') decided jointly.

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
