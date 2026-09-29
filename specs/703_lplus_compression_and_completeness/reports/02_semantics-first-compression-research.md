# Research Report: Task #703 (Round 2, Semantics First)

**Task**: 703 - lplus_compression_and_completeness
**Started**: 2026-09-29T20:42:48Z
**Completed**: 2026-09-29T21:45:00Z
**Effort**: ~1 hour (forced second research round; four Lean probes compiled)
**Dependencies**: 695 (landed), 696 (landed). Round-1 report, plan Phase 7 and Phase 8 BLOCKER records, `.decisions.json`
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/{TaskFrame,PartialHistory,IntNormalForm}.lean`, `FormalSystem/PlusLanguage/{PlusTruth,PlusPasting,PlusNonValidities}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/{Skeleton,Window}.lean`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/**`); four Lean probes compiled with `lake env lean` against the built tree; literature corpus (`~/Projects/Literature/sources/reynolds_2001`, `.../emerson_and_halpern_-_1986_-_...`); prior task artifacts (round-1 report, plan v1, 700 cross-repository note)
**Artifacts**: - `specs/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md`; `specs/703_lplus_compression_and_completeness/probes/{NoFiniteCertificate,HopFreeIncomplete,TypePreservingPaste,HoppingCertificateExists}.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The theorem this task is asked to prove is false as stated, and this is machine-checked.**
  `probes/NoFiniteCertificate.lean` proves that the formula
  `phi0 := □⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))` is not ℤ-time valid, and that **no**
  `PlusSharingWitnessFamily [] [phi0]` satisfies `PlusCertifies t` at any `t`. The result holds
  for every lasso count, every segment length and every succession relation. It is sorry-free
  and depends only on `[propext, Classical.choice, Quot.sound]`. No choice of bounds repairs the
  Lean Challenge Statement.
- **The root cause is a mismatch between the semantics and the certificate class, not a budget.**
  The presented frame's histories are *all* state paths (limit closed). The certificate is finite
  and eventually periodic, and (C2') requires *every* thread to discharge its eventualities. A
  model that branches forever while an eventuality is pending needs state paths that postpone
  the eventuality arbitrarily long. A pumping argument turns a long postponement into a thread
  that postpones forever.
- **The plan's chosen route is incomplete for a second, independent reason.**
  `probes/HopFreeIncomplete.lean` proves that no hop-free family (`trans u i j → i = j`)
  certifies `phi1 := □⟐Xp → (□⟐X¬p → ⊥)`, a target with no long-range eventuality at all.
  `probes/HoppingCertificateExists.lean` exhibits a four-lasso free-succession family that does.
  So round 1's Recommendation 1 (`transId` plus splice closure) cannot prove the theorem even
  where the theorem is true.
- **The four recorded obstructions are one problem seen three times, one misdiagnosis, and all
  four sit downstream of the fatal fifth.** Padding (a), alignment (b) and saturation (d) are
  all caused by representing a shift-invariant, state-based model as independently compressed
  rows pinned to absolute time. The splice seam (c) was misdiagnosed: histories splice freely
  (`PlusLanguage.paste` is landed); what does not splice freely is a label row.
- **The semantics has a natural finite object, and it is not a list of lassos.** Over ℤ a regular
  task frame *is* a bi-serial one-step graph and its histories are exactly the bi-infinite step
  paths. Truth is shift invariant and `⊡` is state determined. The natural countermodel is a
  finite bi-serial labelled graph, with period one and no time origin.
- **Complexity: doubly exponential is the honest expectation.** CTL* embeds into L⁺ over ℤ, so
  ℤ-time validity is 2EXPTIME-hard. The singly exponential *segment* bounds of landed Phases 3
  to 7 are true, but they bound one history's type sequence and say nothing about the state
  space. Whether a singly exponential *state* bound is possible is unknown.
- **Recommendation**: stop Phases 8 to 13, withdraw the Lean Challenge Statement, and re-scope to
  a finite-graph certificate whose liveness is computed rather than demanded. This needs a user
  decision, which is raised as blocking in the return metadata.

## Context & Scope

This is a forced second research round on a task blocked at Phase 8 of 13. The dispatch carries
the user's three-part brief: semantics first, then the problems and their root causes, then the
range of solutions, evaluated last and against criteria fixed from the first two parts. The
report follows that order.

Scope boundaries honoured:

- Research only. No file under `FormalSystem/` was edited and the plan was not revised.
- All probes are under `specs/703_lplus_compression_and_completeness/probes/`.
- Soundness is untouched. `PlusSharingWitnessFamily.plusTruth_iff_mem` and
  `...plusRefutes_of_certifies` are read, used as background, and not proposed for change.
- No `.orchestrator-handoff.json` was written.

### Verification status of each claim

Every finding below carries one of five labels.

| Label | Meaning |
|---|---|
| **[checked]** | Proved in a probe that compiles sorry-free against the built tree, axioms listed |
| **[computed]** | Accepted by running a landed `Decidable` instance (`#guard`); not a kernel proof |
| **[landed]** | A declaration already in the tree, cited by name |
| **[argued]** | A paper argument in this report, not machine-checked |
| **[literature]** | Read from the literature corpus, cited by the paper's own labels |

### Corrections to round 1

Four statements in `reports/01_lplus-compression-completeness-research.md` are wrong and should
not be carried into any later artifact.

1. *F3, "splicing two histories of an arbitrary task frame at a common state does not
   automatically yield a history".* False on every regular frame. `PlusLanguage.paste`
   (`FormalSystem/PlusLanguage/PlusPasting.lean:111`) constructs the spliced history from
   *Compositionality* alone. **[landed]**
2. *Recommendation 1, take `trans := transIdOf`.* Provably incomplete. **[checked]**
3. *O3, the lasso count is bounded by `2^|closure| × W`.* No bound exists for the landed class,
   because for some targets no family exists. **[checked]**
4. *Recommendation 6, "every obligation identified is a finite construction or a bounded
   induction".* False for the same reason.

Round 1's O1 (decidability of `LiftableRaw`) and O4 (product undecidability does not apply) are
unaffected.

## Findings

### Part 1 - The semantics, which is not a product logic

#### 1.1 Five structural facts, and what each one buys

**S1. Over ℤ, the all-pairs condition is the adjacent-pairs condition.** **[landed]**
`WorldHistory.respects_task` is stated for all pairs of times. Over `intOrder` this is no
stronger than stepping between consecutive times: `FrameOver.taskRel_eq_iter` says the task
relation at duration `n` is the `n`-fold iterate of the one-step relation, and
`FrameOver.mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean:348`) says `H_F` is exactly the
set of bi-infinite step paths. `FrameOver.ofStep` (`IntNormalForm.lean:456`) goes the other way:
a bi-serial relation on a finite nonempty carrier generates a regular ℤ-frame.

*What it buys.* A ℤ-time countermodel is a bi-serial directed graph with a valuation. Nothing
else. The histories are not data; they are generated.

**S2. Truth is shift invariant.** **[landed]** `plusTruthAt_timeShift`
(`PlusLanguage/PlusTruth.lean:264`). A point `(σ, t)` and the point `(σ shifted by t, 0)` satisfy
the same formulas.

*What it buys.* There is no absolute time. `□φ` at `t` quantifies over all histories at `t`,
which by shifting is all points of the model, so `□` is a global constant.

**S3. `⊡` is state determined, at any two times.** **[landed]** `stab_state_only`
(`PlusTruth.lean:332`) and `stab_congr_state`. The Phase 8 lemmas
`plusTypeAtM_stab_congr_state` and `plusTypeAtM_atom_congr_state`
(`Compression/Saturate.lean`) are this fact read on types.

*What it buys.* Three things.

- The *state formulas* of a closure are its atoms, its `⊡χ` and its `□χ`. Their truth is a
  function of the world state. A countermodel can carry them as a **labelling of states**.
- `□χ` holds exactly when `⊡χ` holds at every state. `box_stab_iff` is the landed form. So `□`
  needs no separate witness structure once `⊡` is handled.
- Each `⊡χ` can be treated as a fresh state-valued atom
  (`Metalogic/Conservativity/Plus/Atomization.lean` already does this). Under that reading truth
  along one history is plain linear temporal logic with past, over the word of state labels.

**S4. Fusion closure and limit closure.** **[landed]** for fusion, by S1 for limit.
`paste` splices `ρ` up to `t` with `σ` after `t` whenever `ρ.state t = σ.state t`. With S2 the
splice also works across different times: shift first, then paste. By S1 every step path is a
history, so the set of histories is limit closed as well.

*What it buys.* The histories through a state are the **product of its possible pasts and its
possible futures**. This is the header of `PlusPasting.lean` in its own words.

*When a splice is not a history.* Only off the regular class. `paste_rel_le_lt` uses
*Compositionality* across the seam and `F.reflection` for the reverse orientation, and uses
nothing else. No discreteness is needed for fusion. Limit closure, by contrast, is ℤ-specific.

**S5. Type-preserving pasting.** **[checked]** `probes/TypePreservingPaste.lean`,
`truth_paste_of_type_eq`. If `ρ` and `σ` share a state at `t` and agree at `t` on every formula
of a subformula-closed set `C`, then `paste ρ σ t` satisfies exactly `ρ`'s `C`-formulas at every
time `≤ t` and exactly `σ`'s at every time `≥ t`. The proof is a structural induction, uses no
frame-class assumption beyond what `paste` needs, and uses no discreteness. Axioms:
`[propext, Classical.choice, Quot.sound]`.

*What it buys.* This is the correct form of the "seam" fact. A *history* can be cut and rejoined
at any shared state. A *label row* can be cut and rejoined exactly where state **and type**
agree. It also makes liveness factor: a position `(state, type)` lies on a bi-infinite fulfilling
labelled path if and only if it has a fulfilling forward half and a fulfilling backward half.

#### 1.2 Methods that use the construction, against methods imported from elsewhere

| Method | Origin | Fit |
|---|---|---|
| Per-history lasso extraction | Linear temporal logic, and the `Formula`-side theorem | Compresses one history's type sequence by cutting between equal types. Correct and landed (Phases 3 to 7). It discards which *state* each position sits on, and it re-times the history. Both losses are exactly what (C5) then needs back |
| Quasimodels for products | GKWZ, `PTL × S5` | Presupposes commutativity and Church-Rosser. Round 1's F5 showed the stability modal has neither. Not applicable |
| Bundled-tree filtration | Ockhamist logic with arbitrary bundles | Not applicable. S1 forces the full bundle: every step path is a history |
| **State-space quotient with atomized `⊡`** | This semantics (S1, S3) | Works on the graph, not on histories. One label per state for the state formulas. Linear-time reasoning runs over the product of the graph with the types |
| **Liveness by fixpoint on the product graph** | S4, S5 | Replaces both the demanded `lift` field and the all-threads (C2'). Forward and backward halves are computed separately, by S5 |

#### 1.3 Joint compression

The family of histories can be compressed jointly, and the right joint object has **period one
and no time origin**. By S1 and S2 the model is a time-homogeneous graph. A shared period larger
than one is an artefact of listing histories as rows against absolute time.

The (C5) witness demand shows the difference most clearly. On a row family a witness for
`(i, u)` is an index sharing `i`'s state *at time `u`*, so it must be aligned. On a graph a
witness for state `w` is any history through `w`, at any time, because by S2 it can be shifted.
**Alignment is free on a graph because there is nothing to align to.**

#### 1.4 The finite object that represents a countermodel

A finite bi-serial labelled graph, together with one eventually periodic path through it and a
time on that path.

| | List of independently extracted lassos | Finite labelled graph |
|---|---|---|
| Unit of representation | A history | A world state |
| Time | Absolute, per row | None (shift invariant) |
| Histories presented | The rows, plus whatever threads hop between them | All step paths, by S1 |
| `⊡` witnesses | Must be listed as rows and aligned | Any path through the state |
| Tracking every history | Demanded, as the `lift` field | Free: every path has its own true type sequence |
| Fulfilment | Every thread must fulfil | Only live positions count; liveness is computed |
| Periods | Product of all cycle lengths | One |

#### 1.5 What the landed certificate actually presents

The landed frame's world states are `share`-classes of `(index, time)` pairs, and
`SharingSkeleton.total_eq_thread` says every world history is a thread's trace. `Step` is a
class-level relation, so the frame's histories are **all paths through the time-stamped class
graph**. The presented model is therefore limit closed, as S1 requires of any genuine ℤ-frame.
The labels, however, live on `(index, time)` positions of a finite, eventually periodic
structure, and (C2') asks every path through that structure to fulfil. Section 2.5 shows these
two facts are incompatible for some targets.

#### 1.6 The complexity picture

**Claim C1. CTL\* satisfiability reduces to L⁺ ℤ-time satisfiability.** **[argued]**

- Translate the path quantifier `A` to `⊡`, next to `⊥ U ·`, and non-strict until to
  `e ∨ (g ∧ (g U e))`. The closure grows linearly.
- A translated formula is pure future with `⊡` leaves. `truth_congr_agreeFrom` **[landed]** says
  its truth at `(σ, t)` depends only on `σ` from `t` on.
- By S4 the futures of the histories through a state `w` are exactly the forward step paths from
  `w`. So `⊡` means what `A` means.
- A total Kripke structure becomes bi-serial by adding one fresh state with a self-loop and an
  edge to the root. Forward paths from the original states are unchanged.

**Consequence.** ℤ-time validity of L⁺ is 2EXPTIME-hard. **[literature]** The lower bound for
CTL\* is Vardi and Stockmeyer 1985 and the matching upper bound is Emerson and Jutla 1988, both
as reported in the introduction of Reynolds 2001, "An Axiomatization of Full Computation Tree
Logic".

**What is true, singly exponential.** The segment bounds. `plusCompressionBound` is
`max ((2κ+1)·2^κ, 2·2^κ)` and `exists_plusLabelledLasso_of_history_realized` proves every single
history compresses within it. **[landed]** This is a bound on one history's *type* sequence.

**What is plausibly doubly exponential.** The state space. The natural invariant of a state is
its *bundle*, the set of types realized by histories through it. There are up to `2^(2^κ)`
bundles. Identifying states by bundle is not even sufficient: it can create a new path that
postpones an eventuality forever, which is the classical failure of filtration for branching
time with limit closure. **[literature]** Reynolds 2001 describes exactly this: "in the limit,
the step-by-step construction produces many more paths than were ever chosen explicitly".
CTL\*'s known finite models are doubly exponential.

**What remains unknown.**

- Whether a singly exponential state bound holds for L⁺. Nothing here excludes it
  unconditionally. A singly exponential certificate checkable in time polynomial in its size
  would put a 2EXPTIME-hard problem in NEXPTIME, which is widely disbelieved but not refuted.
- Whether the past operators, the global `□` and the two-sided quantification of `⊡` raise the
  complexity above CTL\*'s. S5 suggests they do not, since past and future halves separate, but
  this is not proved.
- The reduction in C1 is argued, not formalized.

### Part 2 - The specific problems and their root causes

#### 2.1 (a) The Phase 7 common-cycle-length invariant

*Symptom.* Padding by repetition reaches only multiples of a cycle's length. Extracted cycle
lengths range over `1 … 2^κ` and need not divide the bound. `perBack` is a product, not a least
common multiple.

*Verified.* `perBack := |repBack| * ∏ |back_i|` at `PlusWitnessFamily/Decide.lean:181`.
**[landed]** The numbers in the BLOCKER are right, and the gap grows fast:

| κ | `plusCompressionBound` | `lcm(1 … 2^κ)` |
|---|---|---|
| 2 | 20 | 12 |
| 3 | 56 | 840 |
| 4 | 144 | 720,720 |
| 5 | 352 | about 1.4 × 10^14 |

*Root cause.* Each history is compressed against its own recurrence times, and the certificate
then has to decode all rows against one clock. A common period is a requirement created by the
row representation. The semantics has no period (S2).

#### 2.2 (b) The Phase 8 alignment budget

*Symptom.* (C5) pins its witness to the same time `u`. `shiftBy` moves a mark at a cost of one
`mid` entry per step. Demand times spread over the combined period.

*Is the window collapse legitimate?* Yes. `stabFaithful_iff_window`
(`Decide.lean:754`) is a proved biconditional, through `exists_window_repr`. **[landed]** The
BLOCKER's first step, that the compression "has to establish the condition at every time
directly", is wrong as logic: the theorem may be applied in either direction.

*Does that help?* No. The window is `[-2·NB, NM + 2·NF)` and `NB`, `NF` are the products of
2.1. With up to exponentially many lassos the window is itself doubly exponential in `κ`. The
BLOCKER's conclusion stands although its premise is misstated.

*Was the every-time obligation mis-scoped?* Yes, but not in the way the question suggests. The
mis-scoping is not "every time instead of a window". It is "**every time instead of every
state**". By S2 and S3 the demand is a property of a world state. Indexing it by time multiplies
one demand by the length of the window and then requires each copy to be aligned.

*Root cause.* The same as (a): absolute time in a shift-invariant semantics, combined with rows
whose compressions are mutually inconsistent in time.

#### 2.3 (c) The anticipated Phase 10 splice-closure seam

*Symptom as recorded.* Splicing two histories at a shared state may not give a history, so the
spliced index's label row must be justified at the seam.

*Verified.* The recorded diagnosis is wrong. `paste` is landed and needs only *Compositionality*.
**[landed]** What is true is S5: the *label row* splices only where the types agree too.
**[checked]**

*What the obligation really is.* `SpliceClosedRaw` with index-identity succession asks the
**index set** to be closed under splicing. For a target that branches at every time, that
closure is infinite. `probes/HopFreeIncomplete.lean` proves the consequence directly: under
`hid`, `lift` makes every state path class-equal to a constant index, so a family with `n`
indices presents at most `n` state paths, and `n + 1` pairwise distinct ones are constructed.
**[checked]**

*Root cause.* Histories are the unit of representation. A branching model has infinitely many
histories, so no finite list of them is closed under fusion. This is not an expensive
obligation. It is an impossible one.

#### 2.4 (d) The exponential lasso-count saturation

*Symptom.* Each (C5) witness is a new index. It raises its own demands at every window time
against its own class. The saturation closes, if at all, at the number of type rows times the
window.

*Root cause.* Again the unit of representation. On a graph a state needs at most one witness
path per failing `⊡χ`, and the witness raises no demands of its own, because its states are
already states of the graph and carry their own labels.

#### 2.5 (e) The obstruction that was not yet recorded, and is fatal

**Statement.** **[checked]** `Probe703.compression_statement_fails`:

```
¬ PlusValidZTime phi0 ∧
  ¬ ∃ (S : PlusSharingWitnessFamily [] [phi0]) (t : ℤ), S.PlusCertifies t
```

**The argument, in the order the probe runs it.**

1. (C4) and the `imp` and `box` clauses of (C1') force both box guesses true. (C3) puts `⟐Xp`
   and `⟐X¬p` in every label.
2. (C5) and (C0) then give every state, at every time, a successor state with `p` and one
   without.
3. Start in the forward-periodic region at `u0 := NM`. Follow `¬p`-successors for
   `k := n · perFwd + 1` steps, then take a `p`-successor. This is a `Step`-path.
4. `lift` supplies a thread `τ` tracking it. By (C0) `τ` reads `¬p` throughout the run and `p`
   at its end. By the `untl` clause of (C1') read backwards along `τ`, `Fp` is labelled along
   the whole run.
5. Pigeonhole over the `n + 1` times `u0 + 2 + m · NF`: two of them carry the same index.
6. Loop the thread between those two times. `transRaw_congr_NF` and `data_congr_fwd` make the
   loop a genuine thread with the same labels. **[landed]**
7. The looped thread carries `Fp` at its entry and never reads `p`. This contradicts (C2').

**Root cause.** Three facts that cannot hold together for this target.

- The presented frame is limit closed (S1). A path that postpones `p` for any finite length
  exists, and each needs a truthful thread.
- The certificate is finite and eventually periodic, so long postponements can be pumped.
- (C2') quantifies over **all** threads, so the pumped thread must fulfil, and it cannot.

In automata terms, the landed class can express only *safety* structure on threads, and the
true type sequences of a branching model are defined by a *fairness* condition. The
correct types of the path that stays in `¬p` forever (`G¬p`) and of a path that leaves late
(`Fp`) differ at the same state, and nothing finite and fulfilment-closed separates them.

**Scope of the failure.** It is not a corner case. Any target whose countermodels must contain,
in a periodic region, a cycle with an exit under a pending eventuality is affected. `G⟐Fp`-style
conditions, fairness-like properties and most genuinely branching specifications are of this
kind.

#### 2.6 One problem or four

| Obstruction | Root cause |
|---|---|
| (a) padding | R1: rows against absolute time |
| (b) alignment | R1 |
| (d) saturation | R1, with R2 |
| (c) splice seam | R2: histories, not states, as the unit. Misdiagnosed in the record |
| (e) no certificate | R3: all-threads fulfilment on a finite structure, against limit closure |

- **R1 and R2 are one design decision seen from two sides**: independent per-lasso extraction
  with no shared state structure and no shared time structure. So (a), (b), (c) and (d) are one
  problem seen four times, as the brief suspected.
- **R3 is a different problem and is the decisive one.** Solving R1 and R2 inside the landed
  certificate class would still leave the theorem false.

### Part 3 - The range of solutions, evaluated last

#### 3.1 Criteria, fixed from Parts 1 and 2

| # | Criterion | Source |
|---|---|---|
| K1 | **The target statement is true.** The class must certify `phi0` and `phi1` | 2.5, 2.3 |
| K2 | No absolute time in the branching substrate | S2, 2.1, 2.2 |
| K3 | States, not histories, as the unit. State formulas carried as a state labelling | S3, 2.3, 2.4 |
| K4 | Tracking of every history is free by construction, not a demanded field | S1, S4, 2.5 |
| K5 | Fulfilment is asked of live positions only | S5, 2.5 |
| K6 | Landed `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their statements | Brief |
| K7 | The check is decidable, and formalizable with the fixpoint machinery already in the tree | Programme |
| K8 | Bounds are stated at their true order | Brief |
| K9 | Reuse of landed Phases 1 to 7 | Cost |

K1 is a gate. A candidate that fails it cannot be the task's resolution, whatever its other
merits.

#### 3.2 The candidates

| # | Candidate | K1 | Statement change | Re-proof of Phases 1 to 7 | Resulting bounds | Risk |
|---|---|---|---|---|---|---|
| A | Widen the `mid` bound only | **Fails** | `mid` conjunct | None | Would need about `lcm(1 … 2^κ)`, doubly exponential, and still certifies nothing for `phi0` | Certain failure |
| B | Recover a common cycle length in `exists_good_cycle_of_plusTypeSeq` | **Fails** | None or `back`/`fwd` conjuncts | Phase 4 and its consumers | As A | Certain failure |
| C | Seam-preserving rotation | **Fails** | None | Phase 7 tail | Unchanged | Certain failure |
| D | Joint compression with a shared period, inside the landed class | **Fails** | Bounds | Phases 7, 8 | Shared period removes (a), (b) | Certain failure on `phi0` |
| E | Restate with honest bounds, same class | **Fails** | Bounds | None | None exists | Certain failure |
| F | Restrict the theorem to a fragment the landed class covers | Holds by restriction | Adds a hypothesis on `φ` | Depends on the fragment | Unknown | The fragment is not characterized. Likely small |
| G | Fair-thread repair of the landed class | Plausible | New sibling class | Phases 2 to 7 reused | Unknown | High: the repaired `lift` is an inclusion between fair path languages |
| **H** | **Finite-graph certificate, liveness computed** | **Expected** | New certificate type and new theorem | Phases 2 to 7 reused, Phase 1 unused | States: doubly exponential expected. Evaluation path: singly exponential in `κ` times the state count | Soundness medium. Completeness is research-level |

**On A to E.** The probe's statement quantifies over every family. Each of these changes a
bound or a construction and leaves the certificate class alone, so each inherits the refutation.
They are recorded because the brief asks for them, not because any is viable.

**On F.** A fragment theorem is true by construction once the fragment is right. A candidate is
targets in which `⊡` does not occur under `□`, `U` or `S`, which covers the two gate targets.
This is a guess, not a finding. It would deliver a compression theorem for a fragment that
excludes most branching properties, so it cannot serve as the programme's completeness result.

**On G.** Keep rows and time stamps. Replace (C2') by the per-lasso `PlusFulfillingLab`, and
replace `lift` by "every `Step`-path is tracked by a *fulfilling* succession path". Soundness
would go through with threads restricted to fulfilling ones. The cost is in the check: the new
`lift` is an inclusion between bi-infinite fair path languages, which needs complementation of
a fairness automaton. Nothing in the tree supports that, and R1 and R2 remain.

#### 3.3 The ideal target: candidate H in detail

**The certificate.**

- A finite carrier `Fin n`, a Boolean one-step relation, and its forward and backward seriality.
  The frame is `FrameOver.ofStep`. **[landed]**
- A valuation of the closure's atoms on states.
- A state labelling for the closure's `⊡χ`, and the box guess `bx`.
- One eventually periodic step path with labels, and a time on it, for the target.
- For each state `w` and each `⊡χ` absent from its label, one labelled witness path through `w`
  that omits `χ`.

**The conditions.**

- *Existential side.* Each witness path, and the target path, is locally coherent, fulfilling,
  follows the one-step relation, and agrees with the state labelling on state formulas. This is
  the landed per-lasso machinery (`PlusLocalCoherentLab`, `PlusFulfillingLab`) with one added
  clause.
- *Universal side.* For each state `w` and each `⊡χ` in its label: no **live** position
  `(w, Δ)` omits `χ`. Positions are all Hintikka types over the subformulas of `χ` that agree
  with the state labelling. Live means forward-live and backward-live, each a fixpoint on the
  finite product graph. By S5 the two halves combine.
- *Box.* `bx χ` is true exactly when `χ` is in every live position of every state.

**Why each root cause disappears.**

| Root cause | In H |
|---|---|
| R1, absolute time | The graph has none. No periods, no window, no alignment |
| R2, histories as unit | States are the unit. Witness paths raise no demands of their own |
| R3, all-threads fulfilment | Fulfilment is asked only of live positions. A path that postpones forever is simply a different, truthful, labelled path |
| Demanded `lift` | Gone. Every history has its true type sequence, and the position set contains every type |

**Soundness.** A structural induction on the formula, over labelled paths restricted to the
subformulas of the formula in hand. The temporal cases are the ones `plusTruth_iff_mem` already
proves along a thread. The `stab` case uses the universal side one way and the witness path the
other way. The result is the landed interface `PlusWitnessFamily.PlusRefutes Γ Del`, so the
refutation interface is unchanged and K6 holds: nothing landed is edited.

**Completeness.** This is the finite model property for L⁺ over ℤ with a computable bound. It
is the hard part and it is not in the tree. The natural quotient by bundles fails for the
reason in 1.6. The known proofs for CTL\* go through deterministic automata for the path
formulas.

**Theorem statement.** The old statement is withdrawn. The new one has the shape

```
theorem exists_plusGraphCertificate_of_not_plusValidZTime (φ) (h : ¬ PlusValidZTime φ) :
    ∃ G : PlusGraphCertificate [] [φ],
      G.n ≤ plusStateBound [] [φ] ∧ (path segment bounds) ∧ (canonical bx) ∧ G.Certifies
```

with `plusStateBound` of whatever order the completeness proof delivers.

**Effect on the paired model checker.** **[argued]** The export contract becomes a finite model:
states, edges, valuation, state labels, one path and a time. The search bound is a bound on the
number of world states. The expectation to relay is *doubly exponential in the closure in the
worst case*, not the `|closure| + 1` of the `Formula` side and not the `2^|closure| × W` of
round 1. The paired repository was not read in this round, so its current export format is an
assumption to be checked.

**Reuse of landed work.**

| Landed | Status under H |
|---|---|
| Phase 1, `TransId.lean` | True, unused. Not a completeness route |
| Phases 2 to 6, types, cycles, fulfilment, readout | Reused unchanged for the target path and the witness paths |
| Phase 7, extraction and `shiftBy` | Extraction reused. `shiftBy` and `plusAlignOffset` unused, because nothing is aligned |
| Phase 8, `Saturate.lean` demand layer | Reused. Its state congruences are the state labelling's well-definedness |

#### 3.4 Ideal target and acceptable fallback, separated

**Ideal.** H in full: certificate, checker, soundness, and the finite model property with a
proved bound. This yields decidability of L⁺ ℤ-time validity. The bound's order is whatever is
true, and any computable bound suffices for decidability.

**Acceptable fallback, in stages that each land something true.**

1. *Record the refutation.* Land the two probe theorems as real declarations beside
   `PlusWitnessFamily/Incompleteness.lean`, correct the module documentation that describes the
   class as covering its hardest targets, and relay the finding across repositories.
2. *H without completeness.* Certificate, checker and soundness. This already gives
   **completeness relative to finite models**: every finite-graph countermodel is certifiable,
   because the certificate is the model and the checker decides truth on it. A model checker
   that finds a finite countermodel can then always have it verified.
3. *Completeness by fragment.* First the fragment where each `⊡` governs a single temporal
   operator, the analogue of CTL, for which singly exponential finite models are standard.
   Then full L⁺.

Stage 2 is the smallest result that is both true and useful. It does not depend on any unknown.

### Codebase Patterns

- `FrameOver.ofStep` and `mem_HF_iff_adjacent` make a finite graph a first-class ℤ-frame. No new
  frame construction is needed for H.
- `AUFix` (`WitnessFamily/Sharing/Fulfil.lean`) is a least fixpoint on an arbitrary finite
  vertex type with a `Finset`-valued successor function. It mentions no formula. It is the right
  base for the liveness computation, which additionally needs the existential fair-path
  fixpoint.
- `SharingWindow.FwdWalk.toThread` already turns a walk in the folded position graph into a
  thread. The pumping step of the refutation is the same device used directly on real times.
- The landed (C2') decision procedure is slow in practice. On a four-lasso family with combined
  period 8 it did not finish in 150 seconds interpreted. **[computed]** The other five
  conditions ran in under 4 seconds each.

### External Resources

- Reynolds 2001, "An Axiomatization of Full Computation Tree Logic", introduction: CTL\*
  decidable in deterministic double exponential time (Emerson and Jutla 1988), matching the
  lower bound of Vardi and Stockmeyer 1985; and the discussion of why limit closure defeats
  step-by-step and filtration constructions. Corpus entry `reynolds_2001`.
- Emerson and Halpern 1986, "Sometimes and Not Never Revisited", Section 3: a set of paths is
  R-generable if and only if it is suffix closed, fusion closed and limit closed. S1 says the
  histories of a regular ℤ-frame are R-generable. Corpus entry `emerson_and_halpern_-_1986_-_…`.
- Both corpus entries carry the rule "cite by the paper's own labels". Any statement relied on
  in a proof must be checked against the source first.

### Recommendations

1. **Stop implementation of Phases 8 to 13.** They aim at a false statement.
2. **Withdraw the Lean Challenge Statement** for
   `exists_plusSharingWitnessFamily_of_not_plusValidZTime`. It cannot be proved at any bound.
3. **Do not take any of resolutions 1 to 3 of the Phase 8 BLOCKER.** All three fail K1.
4. **Treat the cycle-6 decision to drop Invariant A as moot.** It was sound reasoning about a
   route that does not reach the theorem.
5. **Adopt candidate H as the ideal target and stage 2 of 3.4 as the first deliverable.**
6. **Land the refutation** as stage 1, so that the certificate class's actual coverage is a
   theorem of the tree rather than a finding in a report.
7. **Relay to the paired repository** that the fourth need of its stability-modal task, the
   compression bound, does not exist for the landed certificate class.
8. **Give the finite model property its own research-first task.** It is the programme's real
   open problem and is at least as hard as the corresponding result for CTL\*.
9. **Sorry-free throughout.** None of the above needs a placeholder or a new axiom. If the
   finite model property cannot be proved, the correct outcome is a task marked blocked and a
   landed stage 2, not a deferred obligation.

## Decisions

- **D1. The task's target is recorded as refuted, not as blocked on a budget.** Evidence:
  `probes/NoFiniteCertificate.lean`.
- **D2. The plan was not revised and no `FormalSystem/` file was edited**, per the dispatch.
- **D3. A blocking user decision is raised.** Every way forward changes the task's deliverable,
  and the choice between a fragment theorem, a repaired class and a new certificate type is a
  programme-level preference the artifacts cannot settle.
- **D4. Probes are kept as task artifacts**, under `probes/`, and are not proposed for the
  library in their current form. Stage 1 of 3.4 would restate them in library style.
- **D5. Round 1's O2 and O3 answers are superseded.** O1 and O4 stand.
- **D6. No `.orchestrator-handoff.json` is written.** The outcome is returned through
  `.return-meta.json` only.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The finite model property for L⁺ is too expensive to formalize | High | Stage the work as in 3.4. Stage 2 is independent of it and lands a true, useful theorem |
| R2 | The true state bound is doubly exponential and makes enumeration impractical | Medium | Any computable bound gives decidability. State the bound at its true order and relay it. Search in practice is the model checker's job, verification is the checker's |
| R3 | The CTL\* reduction in 1.6 has a gap | Low to medium | It is labelled argued. It affects the complexity picture only. The refutation in 2.5 does not depend on it |
| R4 | The probes were compiled against built `.olean` files that could be stale | Low | Checked: every relevant source file is older than its `.olean`. Re-run the four commands in the Appendix after any rebuild |
| R5 | `HoppingCertificateExists.lean` rests on computation for five of six conditions | Low | It supports a delimiting remark only. The two refutations are kernel-checked |
| R6 | Downstream task 704 depends on 703 and on the certificate class's shape | Medium | Hold 704 until the user decision is taken. Its non-vacuity gates should be restated against whichever class survives |
| R7 | Documentation in the tree now overstates the class's coverage | Medium | Stage 1 corrects it. Until then this report is the record |

## Tactic Survey Results

No open goal of the library was under investigation, so the survey protocol's premise search
was not run. The table records what closed the probes' own goals.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| Integer arithmetic on times and residues | `omega` | success | After `Int.emod_add_mul_ediv`, `Int.add_mul_emod_self_left` supplied as facts |
| Strict order on `NF.Duration` | `omega` | fail, then success | Needed `generalize (show ℤ from r) = z` first, since the carrier is a definitional alias of `ℤ` |
| Pigeonhole on `Fin (n+1) → Fin n` | `Fintype.exists_ne_map_eq_of_card_lt` | success | `by simp` for the cardinality |
| Injectivity contradiction | `Fintype.card_le_of_injective` then `simp` | success | default |
| Closure shape, every `untl` has guard `⊥` | `decide` | success | Kernel evaluation of `plusClosureOf` on a 15-element closure |
| Negated universal from (C5) | `push Not` | success | `push_neg` is deprecated on this toolchain |
| `PlusCertifies` on a concrete family | `#guard` on the landed instance | five of six conditions succeed; the (C1') and (C2') conjunction times out | (C2') was proved from (C1') by hand instead |

## Context Extension Recommendations

- **Topic**: The ℤ-time semantics as a graph semantics.
  **Gap**: `context/project/logic/` has no note recording that a regular ℤ-frame is a bi-serial
  graph whose histories are all step paths, that truth is shift invariant, and that the
  histories are R-generable in the sense of Emerson and Halpern. Both research rounds of this
  task had to rediscover it, and round 1 got the fusion half wrong.
  **Recommendation**: add `context/project/logic/domain/ztime-graph-semantics.md`, citing
  `mem_HF_iff_adjacent`, `ofStep`, `plusTruthAt_timeShift`, `stab_state_only` and `paste`.
- **Topic**: Limit closure and finite certificates.
  **Gap**: No context file warns that a finite, fulfilment-closed structure cannot present a
  limit-closed branching model with a pending eventuality.
  **Recommendation**: add `context/project/logic/domain/limit-closure-and-fairness.md` with the
  pumping argument of 2.5 and the pointer to Reynolds 2001.
- **Topic**: Probing with `lake env lean`.
  **Gap**: The Lean context documents `lake build` discipline but not the cheaper pattern of
  compiling a standalone probe against the built tree, which took about three seconds per probe
  here and needed no build.
  **Recommendation**: add a short section to `context/project/lean4/operations/long-builds.md`.

## Appendix

### Probes

All four are under `specs/703_lplus_compression_and_completeness/probes/`. Each was compiled
from the repository root with `lake env lean <file>`.

| File | Main declarations | Result |
|---|---|---|
| `NoFiniteCertificate.lean` | `not_plusValidZTime_phi0`, `no_certificate`, `compression_statement_fails` | Compiles, no errors, no `sorry`. Axioms `[propext, Classical.choice, Quot.sound]` |
| `HopFreeIncomplete.lean` | `not_plusValidZTime_phi1`, `no_hopFree_certificate` | Same |
| `TypePreservingPaste.lean` | `truth_of_agree_of_type_eq`, `truth_paste_of_type_eq` | Same |
| `HoppingCertificateExists.lean` | `fam`, five `#guard`s, `closure_shape`, `fam_fulfilling` | Compiles. (C0), (C1'), (C3), (C4), (C5) accepted by computation; (C2') proved from (C1') |

### The two targets, in primitive syntax

```
Xp   := untl ⊥ p          X¬p  := untl ⊥ (p → ⊥)        Fp := untl (⊥ → ⊥) p
⟐Xp  := (⊡(Xp → ⊥)) → ⊥   ⟐X¬p := (⊡(X¬p → ⊥)) → ⊥
phi0 := □⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))
phi1 := □⟐Xp → (□⟐X¬p → ⊥)
```

Both are refuted on the permissive frame `PlusLanguage.NF` with `natModel`, at the constant
history and time `0`.

### Files read

| File | Why |
|---|---|
| `Semantics/PartialHistory.lean`, `Semantics/TaskFrame.lean` | `respects_task`, `FrameOver`, `IsRegular` |
| `Semantics/IntNormalForm.lean` | The ℤ normal form, `mem_HF_iff_adjacent`, `ofStep` |
| `PlusLanguage/PlusTruth.lean` | The seven clauses, shift invariance, `stab_state_only` |
| `PlusLanguage/PlusPasting.lean` | `paste`, the agreement lemmas, the purity congruences |
| `PlusLanguage/PlusNonValidities.lean` | `NF`, `natHist`, `natModel` |
| `WitnessFamily/Sharing/Skeleton.lean` | `LiftableRaw`, `SpliceClosedRaw`, `Thread`, the four sufficient conditions |
| `WitnessFamily/Sharing/Window.lean` | The combined window, the congruences, `FwdWalk.toThread` |
| `PlusWitnessFamily/{Basic,Predicates,Closure,Agreement,Decide,Fulfil,Incompleteness,Examples}.lean` | The certificate, its six conditions and their decision procedures |
| `PlusWitnessFamily/Compression/{Types,Cycle,Fulfil,Extract,Saturate}.lean` | Landed Phases 2 to 8 |
| Plan v1, Phase 7 and Phase 8 BLOCKER records; `.decisions.json`; round-1 report | The record being examined |
| `specs/archive/700_…/notes/02_cross-repo-handoff.md` | What the paired repository expects from this task |

### Searches

- Repository: `structure FrameOver`, `class IsRegular`, `ofStep`, `mem_HF_iff_adjacent`,
  `def perBack`, `stabFaithful_iff_window`, `def PlusCertifies`, `structure Thread`.
- Literature corpus: `double exponential`, `limit clos`, `fusion clos`, `R-generable`.
- No rate-limited Mathlib search tool was needed. The two Mathlib lemmas used,
  `Fintype.exists_ne_map_eq_of_card_lt` and `Fintype.card_le_of_injective`, were confirmed by
  compilation.
