# FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/

The certificate the L⁺ semantics actually has: a **time-sliced** bi-serial labelled graph
presenting a frame on the infinite carrier `ℤ × Fin n` with finite fibres. A slice width, a
three-segment eventually periodic sequence of slices, a per-time edge relation, a per-time slice
labelling, a box guess, and a target path with its own segments and its own target time.
`Check.Certifies` is the decidable condition the checker accepts such an object under, and
`decidableCertifies` is synthesized from the clauses rather than postulated.

## Why this subtree exists beside `../PlusWitnessFamily/`

`../PlusWitnessFamily/` is sound and stays. What it is not is **complete**, and neither failure is
a missing bound — both are structural. Two matter here.

- **All-threads fulfilment.** (C2') is a demand about *every* thread of a finite, eventually
  periodic presentation, so every cycle reachable in the periodic region is a thread, and a target
  whose countermodels must contain a cycle with an exit under a pending eventuality is out of
  reach. `../PlusWitnessFamily/Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget`
  exhibits one such target, under no hypothesis at all. This subtree replaces the demand with
  **fulfilment of live positions only**, *computed* as a fixpoint rather than demanded as a field,
  so a path that postpones an eventuality forever is simply a different, truthful, labelled path.
- **The finite carrier.** A certificate presenting a finite-carrier frame cannot certify a
  `⊡`-free ℤ-time non-validity that the landed `Formula`-side witness family already certifies: no
  frame built by `FrameOver.ofStep` satisfies that formula's negation at any finite carrier. The
  carrier here is `ℤ × Fin n` — infinite, with finite fibres.

Absolute-time alignment also disappears, because a slice's own time is the only time there is:
there are no rows pinned to an absolute origin, so there is no period to align and no offset to
compute. That is why `../PlusWitnessFamily/Compression/Extract.lean`'s alignment half is retained
and unused.

**Soundness is not at issue in either direction.** `PlusSharingWitnessFamily.plusTruth_iff_mem`
and `...plusRefutes_of_certifies` are untouched by this subtree, and this subtree's own soundness
direction targets the same unchanged export, `PlusWitnessFamily.PlusRefutes Γ Del`. What is new is
the completeness side.

## The route

Six layers, in the dependency order the modules' own `import` lines give. Two modules are
independent roots reached by nothing earlier — `Splice` and `Fixpoint` — and are placed at the
layer where they are first consumed.

1. **The object, its frame, and the window's arithmetic.** `Basic` fixes the certificate and its
   three-segment readout; `Frame` presents it; `Window` does the least-common-multiple arithmetic
   the folds rest on.
2. **Declarative liveness.** `Position` builds the finite position space over one slice and the
   one-step position graph; `Live` states liveness as a property of the certificate's own runs;
   `Canon` shows a fulfilling run's labelling is *forced* by its state path. `Splice` is the
   factorization that justifies reading liveness as a forward half intersected with a backward one.
3. **The rolled carrier and the computed fixpoints.** `Timed` rolls the carrier; `Fixpoint`
   supplies the existential fixpoint machinery at an arbitrary finite graph; `Computed` instantiates
   four fixpoints at the timed graph; `Fold` and `Unroll` read a graph walk back onto the genuine
   time line; `LiveFix` is the eventuality-aware nested fixpoint.
4. **The bridge.** `Bridge` proves computed and declarative liveness coincide at a window time, and
   yields the `Decidable` instance for liveness.
5. **The width fixture, the transfer operators, and the tail.** `Fixture` fixes the window's width
   by exhibiting what a single period misses — and it **imports `Bridge`**, so the computed
   machinery genuinely precedes it rather than following it. `Stable` in turn imports `Fixture`:
   the fixture is a dependency of the transfer operators, not an afterthought to them. `Tail`
   completes the linchpin's reverse direction, `FixtureStable` records the verdict against
   re-presentation, and `HalfRun` supplies the one-directional form a caller with an explicit
   half-line needs.
6. **The checker, its two theorems, and the embedding.** `Check`, `Sound`, `Complete`, then
   `Embed`, `EmbedComplete` and `Examples`.

## Modules

| Module | Contents |
|---|---|
| `Basic.lean` | The object itself: `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate`, the three-segment readout with its decoding-region and periodicity lemmas, `exists_window_eq`, bi-seriality in both the `∀ t` and the window-decided form with `biSerial_iff_window` bridging them, and `onePointCertificate` — the finite-graph special case, exhibited rather than asserted. `BoxFaithful` lives here, unweakened and **unused** by `Certifies` |
| `Frame.lean` | The presented frame `G.frame h` on the **infinite** carrier `ℤ × Fin G.n`, its infinitude proved rather than asserted; the model `G.model h`; the history space `mem_HF_iff_slicedPath` in both directions; `pathHistory`; and the shift-normalization pair `plusTruthAt_shiftBack` / `timeShift_offset_zero` |
| `Window.lean` | The **combined** window: `NB` / `NF` / `NM` from the least common multiples of the certificate's *and the target path's* own segment lengths, the six compatibility facts, the doubled endpoints `winLo` / `winHi` with `winTimes`, and the fold `exists_win_eq` / `forall_iff_win` reducing a `∀ t` claim over both the slice sequence and the decoded target path to the window — which `Basic.lean`'s slice-only fold cannot state |
| `Splice.lean` | The factorization: `histories_through_paste`, `truth_of_agree_of_type_eq` with its paste instance `label_splices_of_type_eq`, and `forall_forall_or_iff`, assembled into `stab_factors` and its `⊡`-shaped reading `not_stab_factors`. This is the justification for reading `live` as the intersection of a forward and a backward half |
| `Position.lean` | The finite position space over one slice with its cardinality, the one-step position graph `succP` / `predP` with their adjointness, and `mem_succP_of_path`. Its header records the counterexample retiring the totality obligation once expected of `succP`, and the `⊆`-versus-`⊇` dichotomy behind the backward transfer's two independent failure modes |
| `Live.lean` | Liveness as a property of the certificate's **own runs**: `LabRun`, the two halves `FwdLive` / `BwdLive` and their conjunction `Live`, the propagation lemmas `untl_push` / `snce_push`, the label-level splice, and **both** directions of the characterization — `live_of_path`, `exists_path_of_live`, `live_iff` — at an arbitrary `t : ℤ` |
| `Canon.lean` | The **canonical labelling**: `canAt` by recursion on the formula, `canLab`, `canRun`, by which every `G.edge`-path is a locally coherent, fulfilling `LabRun` on (C3b) alone; the uniqueness half `canAt_iff_mem_lab` / `lab_eq_canLab`; and `live_iff_canLab`, reading the live set off the edge-path space with nothing else in it and nothing missing. The true type cannot play this role; that module's header records why |
| `Timed.lean` | The **rolled** timed carrier `TPos := G.Pos × ℤ` with its finite vertex set `verts` — `TPos` is deliberately *not* a `Fintype`, and the one a fixpoint needs comes free from `verts` — and the wrapping `nextTime` / `prevTime` with their edge, membership and **faithfulness** lemmas: the wraps preserve the slice sequence, the target path's data and the position space alike |
| `Fixpoint.lean` | The existential fixpoint machinery at an arbitrary finite graph: `Nu.gfp` at an arbitrary deflating monotone contraction (stated at an arbitrary operator, because the eventuality-aware fixpoint is a *nested* one), `EGFix.gfp` (an infinite walk exists), `EUFix.lfp` (some walk delivers) — each with membership proved **equivalent** to the existence of the walk it describes — and `EUFix.lfp_mono_V`. `AUFix` is the universal operator and is **deliberately unused**; the header records why an existential outer fixpoint cannot consume a universal inner one |
| `Computed.lean` | The four fixpoints at the timed graph: `fwdWalkable` / `bwdWalkable` and `untlReach` / `snceReach`, each with **both** directions of its graph-theoretic characterization. It **claims no equality with `Live`** — that equality is the bridge, and nothing here stands in for it |
| `Fold.lean` | The two folding relations `FoldF` / `FoldB` on times, each wrap proved to be a fold, and folded times proved to carry the same slice, target datum, edge relation, position space and one-step position graph. Each relation carries the **residue** condition rather than the data agreement it implies, because only the residue survives a common step |
| `Unroll.lean` | A graph walk read as a ℤ-indexed half-run: `fwdWalk_foldF` / `bwdWalk_foldB` are the induction placing a walk's window time at step `k` fold-equivalent to the genuine time, and the rest is that composed with `Fold`'s transports, with `fwdWalkPos` / `bwdWalkPos` reading positions off as functions of the time. It builds no `LabRun` and mentions no `Live` |
| `LiveFix.lean` | The **eventuality-aware** liveness fixpoint: `fwdLiveT` / `bwdLiveT` / `liveT` as a nested `Nu.gfp` whose inner reachability is relativized to the set being contracted, both directions of its fixpoint characterization, and `exists_fwdLive_walk` / `exists_bwdLive_walk` — one infinite walk inside the fixpoint discharging every eventuality pending anywhere along it. Mentions `Live` nowhere |
| `Bridge.lean` | The equality of computed and declarative liveness at a **window time**, by the position-level splice `runOfWalks` of a forward and a backward walk, and the `Decidable` instance for liveness it yields. The completeness direction factors into halves and needs no box clause; the soundness direction consumes both halves at once and needs (C3b). `mem_fwdLiveT_of_fwdLive_fold` and `mem_bwdLiveT_of_bwdLive_fold` are a genuine mirror pair |
| `Fixture.lean` | The **window-width fixture**: a bi-serial certificate of back period `1` in which one position is live at `-1` and occupied by no run at any time `≤ -2`, although the slice and the position set are literally the same at all those times — `live_not_determined_by_slice`. This rules out the single-period window and confirms the doubled lower endpoint, stated against the real endpoints by `Fixture.window_verdict`. Also holds the re-presentation family `certRep` with `certRep_slice_shift` |
| `Stable.lean` | The one-**combined**-period transfer operators `ΦBack` / `ΦFwd` built from `stepBack` / `stepFwd`, monotone at each level; the two subset lemmas placing their images on the window's endpoint slices; the soundness direction `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` and its two-directional counterpart; and `TailStable` with `decidableTailStable`, a **residue-indexed** demand with one conjunct per residue of each period, `tailStable_back` / `tailStable_fwd` recovering the single-equation conjuncts as the zero-residue instances. `L₀` / `R₀` are read off the bridge's equality, and the **forward** direction of the linchpin is here, `mem_L₀_of_live_tail` |
| `Tail.lean` | The **reverse** direction of the linchpin, which needs a genuine run rather than an iterate: the three-region position families `tailPos` / `headPos` at an arbitrary reference time, built from a shifted reference run, a transfer chain and a second reference run, with `live_of_mem_L₀_tail` / `live_of_mem_R₀_head` as headlines and `tailStable_iff_window` / `tailStable_iff_window_fwd` as the biconditionals they complete at every time down either periodic tail. `exists_win_live_eq` gives every time a window representative carrying the same slice **and** the same live set |
| `FixtureStable.lean` | The verdict **against** `exists_tailStable_repr`, which is therefore not stated here in any form: `Fixture.ΦBack_L₀_inter_ne_cert` (the *filtered* backward conjunct fails, a `⊇` failure no filter repairs), `Fixture.not_tailStable_cert` (both conjuncts fail, for two genuinely different reasons — a pre-period showing through, which absorption does address, and a right-end reachability obstruction, which it does not), and `Fixture.not_tailStable`: **no member of the re-presentation family is tail-stable**, for every pre-period and every pair of period multipliers. Also the standing rule recorded below |
| `HalfRun.lean` | One-directional liveness from an explicit half-line, for a caller that already has the other direction: `mem_iterBack_of_run` / `mem_iterFwd_of_run` (a run is a chain), `exists_bwdHalfRun_of_mem_bwdLiveT` / `exists_fwdHalfRun_of_mem_fwdLiveT` (the rolled fair walk, unrolled at a fold-equivalent root), and `live_of_bwdHalf_chain_run` / `live_of_run_chain_fwdHalf`. The far region is a half-line position family rather than a *shifted* run, so no periodicity of the slice sequence is consumed there and the construction is available at every residue — including the one at which `Tail.lean`'s far-region shift would cross the origin |
| `Check.lean` | The **decidable checker**: `Certifies` as nine clauses, with `decidableCertifies` synthesized and each structural conjunct's instance confirmed in isolation. The existential side is stated on the position graph rather than on `PlusLocalCoherentSeqLab`, fulfilment is supplied by the computed live set rather than demanded of the target path, and the box clause is read on live positions rather than on the slice labelling — that module's header gives, for each of the three, why it is the only decidable form available. `forall_iff_win_succ` is the one-step-lookahead fold the `succP` clause needs |
| `Sound.lean` | The **truth lemma** and the refutation interface: `plusTruthAt_iff_canAt` relates truth in the presented model along an arbitrary edge path to `Canon`'s canonical membership predicate — not to a run's label, which would argue in a circle — and `plusRefutes_of_certifies` lands `PlusWitnessFamily.PlusRefutes Γ Del` **unchanged**, beside the landed sharing-family result and not in place of it. The `□` case reads the box clause through `plusBox_const`, the `⊡` case reads (C5) at the window representative, and `untl` / `snce` transfer directly because `canAt` takes the existential form of both |
| `Complete.lean` | The **converse**: `SlabTrue` (the slice labelling reports the truth of its own `□`- and `⊡`-arguments; the atoms need no clause, the presented model's valuation *being* the labelling), the truth lemma from that alone with no checker clause as a hypothesis, and the three semantic clauses of `Certifies` constructed in the one order their dependencies permit — (C3b) first, then (C5) and the box clause. `exists_plusSlicedCertificate_of_tailStable_countermodel` is the headline. The produced certificate agrees with the given one on **six** fields rather than four, and that is forced: the combined window is a least common multiple of the certificate's *and the target path's* own segment lengths. `Probe.exists_certifying_triv` exhibits a certificate meeting every hypothesis, so the statement is not empty |
| `Embed.lean` | The **construction** half of the embedding of the landed `Formula`-side witness family: `Periodic.segBack` / `segMid` / `segFwd` materialize an eventually periodic function as the three segments decoding back to it; `plusClosureOf_ofCtx` identifies an embedded context's L⁺ closure with the image of the base closure — whence **no `⊡`-formula is in an embedded closure at all**, so (C5) and `SlabTrue`'s second clause are vacuous there; and `WitnessFamily.sliced` is the certificate, slice width the lasso count, edges `i → i` only, slice sequence and target path cut at the family's common periods. `sliced_biSerial` is proved; tail-stability is **evaluated** at two embedded certificates and **not** claimed in general |
| `EmbedComplete.lean` | The **semantic** half of the same embedding: a truth lemma for the embedded model standing on the family's own four certification conditions and on nothing the certificate has yet to establish — `Sound.lean`'s truth lemma cannot serve, taking as hypotheses exactly what an embedded certificate is trying to establish. The self-loop edge relation makes a direct induction cheap, every history of the embedded frame having a **constant** index, so the `□` clause collapses to a quantifier over one index and one offset. `sliced_target_lab_eq_canLab` and `sliced_slabTrue` are two of the four hypotheses of the completeness headline; the `BotTargets` namespace holds the permanent regression pair |
| `Examples.lean` | The class's **non-vacuity record**: `liveFamily_sliced_certifies`, the exhibited interesting witness of `Certifies` at a non-empty closure with a live `untl` obligation — beside `Complete.lean`'s antecedent failure at the empty closure — and the lifted sharing-class witness |

## The carrier is infinite, with finite fibres, and that is forced

The carrier's infinitude is proved here, not asserted, and its time fibres are finite, of size
`G.n`. This is not a convenience. A certificate whose presented frame has a **finite carrier**
cannot certify a `⊡`-free ℤ-time non-validity that the landed `Formula`-side witness family already
certifies, so a finite-carrier certificate class is incomplete for a fragment in which the
`Formula`-side route is complete. The infinite carrier with finite fibres is the weakest shape that
escapes that obstruction while keeping every per-time object a `Finset` — which is what keeps the
checker decidable.

Restricting the language to the CTL-like fragment does **not** rescue the finite-carrier shape: the
`⊡`-free non-validity that defeats it already lies inside that fragment, so the sliced shape is
needed there too.

## What is proved, what is refuted, and what is open

**Proved.**

- **Soundness.** `Sound.plusRefutes_of_certifies`: an accepted certificate produces
  `PlusWitnessFamily.PlusRefutes Γ Del`, the **unchanged** export the landed
  `PlusSharingWitnessFamily.plusRefutes_of_certifies` lands. The landed sharing-family interface is
  untouched.
- **Relative completeness.** `Complete.exists_plusSlicedCertificate_of_tailStable_countermodel`: a
  bi-serial, tail-stable, semantically labelled structure carrying a canonically labelled refuting
  path at a window time admits a box guess the checker accepts — on the same carrier, with the same
  target path and the same target time. No hypothesis bounds the slice width or any segment length.
- **The embedding.** `WitnessFamily.sliced` with `sliced_biSerial`, and
  `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`: every ℤ-time
  non-validity of an embedded `Formula` admits an accepted sliced certificate, so the class is
  non-vacuous on `⊡`-free targets and at least as strong there as the landed L class.

**Refuted.**

- The **finite-carrier** finite model property for this certificate shape, unconditionally, and not
  rescued by restriction to the CTL-like fragment.
- `exists_tailStable_repr` — that every certificate has a tail-stable re-presentation with an
  isomorphic frame. `FixtureStable.lean` proves it false, and it is therefore **not stated in any
  weakened form** anywhere in this subtree.

**Open.**

- The **sliced** finite model property. No module here states it, implies it, or treats it as
  settled either way, and nothing above bears on it. It is a separate piece of work.

**Neither proved nor refuted, and not a theorem at all.** The expected slice width is doubly
exponential in the target. That is a **research finding**, recorded as such: no slice-width bound,
no tail-period bound and no complexity claim is proved anywhere in this subtree, and none should be
read into it.

## The condition set as it stands: nine conjuncts

Read off the landed `Check.Certifies` — nine, not four or five:

1. `BiSerial` — every time has an outgoing and an incoming edge (structural).
2. `TailStable` — the residue-indexed, liveness-filtered tail transfer equation (structural).
3. (C3b) `BoxLabelFaithful` — the box guess agrees with the slice labelling on state shapes.
4. `BoxLiveFaithful` — the box clause, read on **live** positions.
5. `G.targetTime ∈ G.winTimes`.
6. `TargetPathPos`.
7. `G.targetPos G.targetTime ∈ G.liveAt G.targetTime`.
8. (C4) `Target` — the premises and the negated conclusions at the target time.
9. (C5) `StabFaithful` — the stability-modal clause.

(C3) `BoxFaithful` is **not** a conjunct. `AgreesOnState` pins the slice labelling to a position's
label only on the state shapes, so for a formula of any other shape its slice membership is
unconstrained data and the demand would be about the wrong object. `BoxFaithful` therefore stays in
`Basic.lean`, unweakened and unused by `Certifies`, and the clause carried instead is
`BoxLiveFaithful`. Clauses 5-7 are target-group side conditions; the window membership is forced by
the computed live set existing only at window times, and narrows the class not at all.

**What (C3b) costs.** It narrows the class only away from certificates whose slice labelling
contradicts their own box guess — and away from no certificate a countermodel presents, since
`Complete.lean` constructs the guess from the labelling.

**What `TailStable` costs.** The forward conjunct is **liveness-filtered** and the backward conjunct
carries the mirror filter: one filter per obligation direction, so reachable-but-dead positions are
filtered out rather than required to be live. The demand is **residue-indexed** — a bounded
quantifier over each period's residues, which is what the `⊡` clause of the truth lemma requires —
with the zero-residue instances recovering the single-equation conjuncts verbatim. Deciding it costs
one `Φ` application per residue of each period rather than two, each over a live-position set that
is itself a fixpoint. The narrowing is **not** harmless: `FixtureStable.not_tailStable_cert`
exhibits a certificate the demand rejects. And the both-filtered demand is **not** a theorem —
`TailStable` is a field of `Certifies`, a per-certificate demand — because the backward conjunct
fails in two independent ways and only one is filterable: a `⊆` failure, junk positions a filter
removes, and a `⊇` failure, a pre-period repaired by absorption and by no filter.

## Where the asymmetry lies

Not in the bridge's two fold lemmas: those are a genuine mirror pair. What is one-directional is
the **forward filter**, for a stated reason — the backward fold relates two negative times, so it
does not reach the right tail at all, and on the right tail only the forward readout is available.

## STANDING RULE: a probe of a `TailStable`-like demand must carry both an `untl` and a `snce`

Binding on every future fixture in this subtree and on every evaluation of a `TailStable`-like
demand anywhere in it. `TailStable` has two conjuncts, each with its own obligation direction and
its own liveness filter, and a closure carrying only one of the two eventuality operators exercises
only one conjunct while the decision procedure reports on their conjunction. That is not a
hypothetical hazard: a favourable verdict for the whole demand was twice returned from `untl`-only
certificates, and the `snce`-direction obstruction they concealed was found only later. The two
smallest witnesses of each direction are kept as a **permanent regression pair** in
`EmbedComplete.lean`'s `BotTargets` namespace.

## Dependencies

- **Imports**: internal to this directory per the route above, plus `../PlusWitnessFamily/Closure`
  and `../BiLasso/Periodic` (`Basic`), `FormalSystem.Semantics.SlicedFrame` and
  `FormalSystem.PlusLanguage.PlusTruth` (`Frame`), `FormalSystem.PlusLanguage.PlusPasting`
  (`Splice`), `../PlusWitnessFamily/Compression/Types` (`Position`, `Sound`),
  `../PlusWitnessFamily/Agreement` (`Sound`), `../WitnessFamily/Agreement` (`Embed`),
  `../WitnessFamily/Compression/Family` and `FormalSystem.PlusLanguage.PlusValidity`
  (`EmbedComplete`), `../WitnessFamily/Sharing/Specialize` (`Examples`), and Mathlib
  (`Fixpoint`, `Window`).
- **Imported by**: all 25 modules are imported by the re-export `../PlusSlicedCertificate.lean`
  beside this directory, which `../Decidability.lean` imports.

This subtree is sorry-free and axiom-free.

## Related Documentation

- [The time-sliced certificate re-export](../PlusSlicedCertificate.lean)
- [PlusWitnessFamily README](../PlusWitnessFamily/README.md)
- [The limits of the L⁺ certificate class](../PlusWitnessFamily/Limits/README.md)
- [The L⁺ compression layer](../PlusWitnessFamily/Compression/README.md)
- [Decidability README](../README.md)

---

*Last verified: 2026-10-02*
