# Research Report: Task #714

**Task**: 714 - Evaluate full labels in the sliced certificate
**Started**: 2026-11-12T00:00:00Z
**Completed**: 2026-11-12T00:00:00Z
**Effort**: 1 research round (dispatch 5)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/**`,
  `FormalSystem/PlusLanguage/**`), kernel evaluation via `decide` / `#eval` under
  `lake env lean`, prior research report `06_tailstable-backward-conjunct-repair.md`
  (archived under `specs/archive/703_lplus_compression_and_completeness/reports/`)
**Artifacts**: - `specs/714_evaluate_full_labels_in_sliced_certificate/reports/01_full-labels-sliced-certificate.md`
  - `specs/714_evaluate_full_labels_in_sliced_certificate/probes/FullLabels.lean` (ten
    `decide`-level results, zero sorries, every result on
    `[propext, Classical.choice, Quot.sound]`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Decidability is not the obstruction, and the deferral note's stated reason is not the
  binding one.** Full-label agreement (`X = G.slab t w` in place of `AgreesOnState`) is a
  `Finset` equality: `decidableCertifies` synthesizes exactly as it does today, and the
  position space *shrinks* from `n · 2^|closure|` to at most `n`. Nothing in `Check.lean`'s
  decision procedure is lost. The search gets cheaper, not undecidable.
- **The binding obstruction is the stability modal `⊡`.** `PlusTruthAt`'s `stab` clause reads
  `∀ σ, τ.state t = σ.state t → …`: the comparison class is the set of *history types realized
  at one world state at one time*, which is exactly the multiplicity of labels over one state
  in `posAt`/`liveAt`. Full labels make that class a singleton at every point, so a full-label
  certificate can only present models in which `⊡φ ↔ φ` — the deterministic collapse already
  named in `PlusLanguage/PlusDeterminism.lean`. Measured: at both landed `⊡`-carrying
  non-vacuity witnesses, `liveAt 0` has **4** positions over **2** states.
- **Both landed `⊡`-carrying witnesses die outright under full labels**, and for a sharper
  reason than the modal one: the slice labelling is a *state description*, not a type.
  `certA.slab 0 0 = ∅` is not even `LabCoherent` (the closure's implication `Pp → ⊡Pp` is
  missing from it), so `posAtFull certA 0 = ∅` and `posAtFull certB 0 = ∅` — proved. Option 3
  is not a tightening of the existing structure; it silently re-types the `slab` field.
- **The task description's premise — "full labels make `posAt` a singleton, so no junk position
  could exist" — is false as a general claim and true on the embedded route.** It is false
  because singleton-per-state says nothing about whether that one label is dead:
  `posAtFull Fixture.cert (-1) ≠ Fixture.cert.liveAt (-1)`, both of cardinality 2, so a dead
  full-label position exists *and* a live position is lost. It is true on the embedded route,
  where the slab is a fulfilling family run's own label: at all three embedded certificates —
  `botSnceFamily.sliced 0` (the `⊥ S ⊥` witness that forced the backward filter),
  `botUntlFamily.sliced 0` (the `⊥ U ⊥` witness that forced the forward filter) and
  `liveFamily.sliced (-1)` — `posAtFull t = liveAt t` at **every** window time, proved.
- **So on the embedded route both filters would indeed be vacuous, but the property doing the
  work is the embedding, not the label refinement.** `TailStableMirror` and the forward filter
  would be deletable only in the sense of being satisfied trivially at those certificates; the
  demand itself could not be deleted from `TailStable`, because `Fixture.cert` shows a
  full-label position that is not live.
- **The superset failure survives independently**, as expected: it is a failure of the
  *presentation* (an unabsorbed pre-period), not of the label alphabet. Full labels do delete
  `Fixture.p₀` (`p₀ ∉ posAtFull cert (-1)`, measured), but they delete it by deleting a live
  position too, which is a loss and not a repair.
- **Recommendation: keep the landed option-1 design.** Option 3's real cost is not "most of
  Stage 2 again"; it is a different certificate class — full labels *plus* an explicit
  state-sharing relation on slices, mirroring `PlusSharingWitnessFamily` — together with a
  rebuilt frame construction. That is a larger programme than the one the deferral note priced,
  and it buys a `TailStable` simplification that the landed two-filter shape already delivers.

## Context & Scope

This round answers the four questions the task description puts, and nothing else:

1. Can the `TailStable` junk-position obstruction be removed at its root by carrying full labels?
2. Does decidability of the certificate check survive full labels?
3. If not, does a weaker label refinement shrink `posAt` enough to drop both filters while
   keeping the search decidable?
4. Does the superset (`⊇`) failure mode — `Fixture.cert`'s pre-period, repaired by absorption —
   likewise disappear under full labels, or survive independently?

No file under `FormalSystem/**` was changed. The probe is a standalone file under the task's
`probes/` directory, elaborated with `lake env lean` against the built library.

**What "full labels" means here, precisely.** The certificate already carries a full
`Finset PlusFormula` per slice state: `PlusSlicedCertificate.slab t w = (G.slice t).lab w`, with
`slab_sub` putting it inside the closure. Option 3 is therefore *not* a change to the
`PlusSlicedCertificate` structure's fields. It is a change to one predicate — replacing

```
AgreesOnState G t w X  :=  ∀ ψ ∈ closure, IsStateShape ψ → (ψ ∈ X ↔ ψ ∈ G.slab t w)
```

by full agreement `X = G.slab t w`, and hence replacing

```
posAt G t = univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ G.AgreesOnState t p.1 p.2.1)
```

by the probe's

```
posAtFull G t = univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ p.2.1 = G.slab t p.1)
```

Every measurement below is of `posAtFull` against the landed `posAt` and `liveAt`.

## Findings

### F1 — Decidability survives, trivially, and the position space shrinks

`AgreesOnState` is decided by `decidableAgreesOnState`, a bounded quantifier over the closure.
Full agreement is a single `Finset PlusFormula` equality, which has `DecidableEq` already. Every
other clause of `Certifies` is unchanged in shape: `LabCoherent`, `StepClause`, `succP`, `predP`,
`liveT`, `liveAt`, `winTimes`, `TailStable`, `StabFaithful`, `BoxLiveFaithful` and
`TargetPathPos` all read `posAt` through its `Finset` interface and nothing else.
`decidableCertifies` is synthesized by `unfold Certifies; infer_instance`; the synthesis does not
change.

`card_Pos` reads `Fintype.card G.Pos = G.n * 2 ^ |plusClosureOf (Γ ++ Del)|`. That is the ambient
type's cardinality and is unaffected, but `posAt`'s own size drops from "every coherent
state-agreeing label" to "at most one label per state". Measured at the two hand-built witnesses:
`(certA.posAt 0).card = 4` against `(posAtFull certA 0).card = 0`; at `Fixture.cert`,
`(posAt (-1)).card = 4` against `(posAtFull (-1)).card = 2`; at the three embedded certificates,
`posAt` is `2` and `posAtFull` is `1` at every measured time.

**So the deferral note's stated reason — "it costs the decidable search `Check.lean` is built
around" — is not the binding objection.** Read as "the decision procedure is lost", it is wrong.
Read as "most of Stage 2's proof development is rewritten", it is right but is a cost, not an
obstruction, and the findings below are the obstruction.

### F2 — The binding obstruction is `⊡`, and it is a semantic one

`PlusTruthAt`'s clauses, verbatim:

```
| .box  φ => ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
| .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ
```

`□` quantifies over *all* histories and is history- and time-independent (`plusBox_const`,
`box_global`). `⊡` quantifies over the histories **sharing the present world state** — the
`⟨τ⟩_t` class of `def:BLstar-semantics`. The frame the certificate presents has carrier
`ℤ × Fin G.n` (`Frame.lean`), so "sharing the present world state" is "same `(t, w)`", and the
types realized in that class are exactly the labels of the live positions over `w` at `t`. That
is why `StabFaithful` reads

```
⊡χ ∈ G.slab t w  ↔  ∀ p ∈ G.liveAt t, p.1 = w → χ ∈ p.2.1
```

Under full labels there is at most one position over each state, so the right-hand side collapses
to `χ ∈ G.slab t w` whenever that position is live, and to `True` otherwise. A full-label
certificate can therefore only present models satisfying `⊡φ ↔ φ` at every point — which is
exactly `PlusDeterminism.stab_iff_of_deterministic`, the collapse over deterministic frames. **The
multiplicity of labels over one state is not an over-approximation artifact in the `⊡` direction;
it is the semantic content of `⊡`.**

This is measured rather than argued, at the two landed `⊡`-carrying non-vacuity witnesses:

| Certificate | target | `(posAt 0).card` | `(liveAt 0).card` | distinct live states |
|---|---|---|---|---|
| `TotalEdge.certA` | `Pp → ⊡Pp` | 4 | 4 | **2** |
| `TotalEdge.certB` | `(U⊤p) → ((p → ⊥) → ⊡(U⊤p))` | 4 | 4 | **2** |

`certA_live_multiplicity` and `certB_live_multiplicity` state the comparison as theorems:
`((liveAt 0).image Prod.fst).card < (liveAt 0).card`. Two live labels sit over each state at that
time, and the whole `⊡`-content of these two certificates is the difference between them.

**The only repair is a different structure.** To keep `⊡` under full labels, the slice would have
to carry an explicit state-sharing relation grouping slots that denote the same world state, and
`⊡` would quantify over the class rather than over `p.1 = w`. That is the shape
`PlusSharingWitnessFamily` already has on the family side (`WitnessFamily/Sharing/Agreement.lean`),
and it changes the frame construction too, since `FrameOver.ofSlicedStep`'s carrier would become
a quotient of `Fin n`. That is a new certificate class, not a refinement of this one.

### F3 — The two `⊡`-carrying witnesses die outright, for a sharper reason than F2

The slice labelling is a **state description**, not a type, and option 3 silently re-types it.
`certA.sliceA.lab w = if w = 1 then {p, Pp} else ∅`, and the closure of `targetA` contains the
implication `Pp → ⊡Pp`. `LabCoherent`'s implication clause demands
`(Pp → ⊡Pp) ∈ X ↔ (Pp ∈ X → ⊡Pp ∈ X)`, whose right-hand side is vacuously true at `X = ∅`. So:

| Result | Statement |
|---|---|
| `certA_slab_not_labCoherent` | `¬ LabCoherent [] [targetA atomP] (certA.slab 0 0)` |
| `certA_posAtFull_empty` | `posAtFull certA 0 = ∅` |
| `certB_posAtFull_empty` | `posAtFull certB 0 = ∅` |
| `certA_target_not_full` | `certA.target.lab 0 ≠ certA.slab 0 (certA.target.st 0)` |
| `certB_target_not_full` | `certB.target.lab 0 ≠ certB.slab 0 (certB.target.st 0)` |

Under option 3 both landed total-edge witnesses have an **empty position space**, so
`TargetPathPos` and `targetPos targetTime ∈ liveAt targetTime` both fail and neither certifies.
The target-path mismatch is independent of the coherence one and would survive any repair of the
slabs: `pathA`'s label at time `0` is `{⊤, Pp}` at state `0` while `slab 0 0` is `∅` — the target
path's label is a *type* and the slab is a *state*, and option 3 is the demand that they be the
same object.

This is the fact `BoxLiveFaithful`'s own docstring already records from the other side: "for a `χ`
of any other shape `χ ∈ G.slab t w` is unconstrained data, and a demand stated against it would
neither follow from nor imply `χ`'s holding at the carrier element". Option 3 is precisely the
demand that docstring rejects, promoted from the box clause to the position space.

### F4 — On the embedded route the premise holds, but the embedding is what makes it hold

The embedded certificate sets `(W.sliced tt).slab t i = trLab (W.L i t)` (`sliced_slab`) — the
slab *is* the family slot's full label, and the family's label sequence is a coherent, fulfilling
run. So every full-label position lies on a genuine fulfilling path and is bi-live. Measured at
all three embedded certificates, at every window time:

| Result | Statement |
|---|---|
| `botSnce_posAtFull_eq_liveAt` | `∀ t ∈ winTimes, posAtFull (botSnceFamily.sliced 0) t = liveAt t` |
| `botUntl_posAtFull_eq_liveAt` | `∀ t ∈ winTimes, posAtFull (botUntlFamily.sliced 0) t = liveAt t` |
| `liveFamily_posAtFull_eq_liveAt` | `∀ t ∈ winTimes, posAtFull (liveFamily.sliced (-1)) t = liveAt t` |

with cardinalities `posAt = 2`, `posAtFull = liveAt = 1` at each measured time. The deleted
element is in each case exactly the junk position: at `⊥ S ⊥` it is the backward-dead
`{⊥ S ⊥}`, at `⊥ U ⊥` the forward-dead `{⊥ U ⊥}`, and at `liveFamily` the one that makes
`liveFamily_not_tailStableRaw` true today.

**What follows, and what does not.** Since `posAtFull t = liveAt t` at every window time, a
liveness fixpoint recomputed over `posAtFull` lands on the same set — every run witnessing a
position's liveness stays inside `liveAt`, hence inside `posAtFull` — so `posAt' = liveAt'` and
both `TailStable` conjuncts hold *raw* at these three certificates. In that sense the task
description's claim is confirmed: at the two `⊥`-targets that each forced one filter, full labels
remove the obstruction at its source.

What does **not** follow is that the filters become deletable from the definition. The property
doing the work is `slab t i = trLab (W.L i t)` with `W` fulfilling — a property of the embedding.
It is not implied by full-label agreement, as F5 shows.

### F5 — Full labels do not make junk positions impossible

`Fixture.cert` is the hand-built fixture the `TailStable` demand exists for. Measured:

| Quantity | Value |
|---|---|
| `(cert.posAt (-1)).card` | 4 |
| `(posAtFull cert (-1)).card` | 2 |
| `(cert.liveAt (-1)).card` | 2 |
| `posAtFull cert (-1) = cert.liveAt (-1)` | **false** |
| `Fixture.p₀ ∈ posAtFull cert (-1)` | **false** |

Two equal-cardinality but unequal sets: there is a full-label position that is **not live**, and
a live position that full labels **delete**. So "carrying full labels makes `posAt` a singleton,
so no junk position could exist" is false as stated — singleton-per-state says nothing about
whether that one label is backward- or forward-dead. The junk-ness of a label is a property of
the label and the closure, which is exactly the finding the prior report recorded about `posAt`;
restricting *how many* labels sit over a state does not change *which* labels are dead.

**(4) The superset failure survives independently.** `p₀ ∉ posAtFull cert (-1)`, so the particular
witness `mem_L₀_p₀` / `not_mem_ΦBack_L₀_p₀` is deleted — but deleted together with a genuinely
live position, which is a loss of content, not a repair. The failure mode itself is a property of
the *presentation*: a live position at the reference time with no live predecessor one whole
period back, because the pre-period was never absorbed into `mid`. Nothing about the label
alphabet bears on it, and `Position.lean`'s header already states the structural reason —
intersecting can only shrink the left-hand side, so no filter and no `posAt` refinement closes a
`⊇` gap. The repair remains absorption.

### F6 — (3) There is no cheaper weaker label refinement

The question is whether some refinement of `posAt` strictly between `AgreesOnState` and full
agreement deletes the dead labels while keeping the search decidable. The answer is no, for a
structural reason:

* a label is backward-dead exactly when `predP` is empty along every backward chain, which is the
  greatest fixpoint `bwdLiveT` and nothing smaller — `predP_eq_empty_of_bot_snce`'s one-step case
  is the degenerate instance, and a one-step condition does not catch a label whose predecessors
  exist but die two steps back;
* so any refinement of `posAt` that deletes exactly the backward-dead labels must compute
  backward liveness on the position graph, i.e. must be `bwdLiveT`;
* but `posAt` is what `succP`/`predP` are defined over, so folding `bwdLiveT` into `posAt` makes
  the three mutually recursive, and the stratified form of exactly that recursion is what
  `Stable.lean` already carries as `bwdLiveAt` applied at the demand.

In other words, "refine `posAt` so the filter can be dropped" and "keep the filter" are the same
computation applied at two different places, and the landed design applies it at the cheaper one.
A genuinely weaker *local* refinement — strengthening `LabCoherent` with a syntactic side
condition on `snce`/`untl` membership — is not available either, because `snce g e ∈ X` imposes
no condition at all on `X` itself; the whole content of the clause is the relation to the
previous label, which is `StepClause`, which `posAt` deliberately does not read.

### Codebase Patterns

- `slab` carries a full `Finset PlusFormula` already, and `AgreesOnState` deliberately reads only
  the `IsStateShape` part. The gap between the two is where the `⊡`/history multiplicity lives,
  and it is not slack to be tightened.
- The three-way separation — `LabCoherent` (one label), `StepClause` (two labels), fulfilment
  (the fixpoint) — is what makes `posAt` cheap and the liveness computation the only expensive
  part. Any full-label variant collapses the first two into the slab and moves the whole burden
  onto whichever clause then has to certify that the slab is a type.
- Both landed non-vacuity witnesses (`certA`, `certB`) use slabs that are *not* `LabCoherent`.
  That is legitimate under the current design and is the most compact evidence that `slab` and
  `Lab` are different kinds of object.
- `#eval` on `Finset.toList` fails to compile (`Finset.toList` is noncomputable); use `Finset.card`,
  `Finset.image … |>.card`, or a `decide`-level theorem instead.
- `set_option maxRecDepth 4000000` plus `maxHeartbeats 2000000` is the working envelope for a
  `decide` over a `liveAt` computation at these certificates, matching `Examples.lean`'s own caps.

### External Resources

No external search was needed: every question was settled inside the repository, by kernel
evaluation or by reading landed definitions. No Mathlib lemma was missing, and no rate-limited
search tool was used.

### Recommendations

- **R1 — Do not adopt option 3; keep the landed option-1 (two-filter) design.**
  [VERIFIED: FAIL -- gate: `decidableCertifies` run against the full-label position space at the
  landed `⊡`-carrying witnesses, via `posAtFull certA 0 = ∅` and `posAtFull certB 0 = ∅`, both
  proved by `decide` in `probes/FullLabels.lean`; neither witness certifies under full labels;
  revised to: keep the landed two-filter design and record option 3's refutation at
  `Position.lean`'s header, per R2]. Option 3
  deletes the class's `⊡` coverage, which is a recorded asset (two non-vacuity witnesses at
  `⊡`-carrying targets, plus `Limits/NoFiniteWidth.lean`'s `⊡` incompleteness witness), and it
  does not deliver the invariant it was wanted for (F5).
- **R2 — Record the refutation in one durable place, as a positive statement.**
  `[No compiled gate applicable]` `Position.lean`'s header already explains why `posAt`
  over-approximates and what it costs the tail-stability demands. Add one paragraph saying what
  the over-approximation *buys*: the multiplicity of labels over one state at one time is the
  comparison class of `PlusTruthAt`'s `stab` clause, so collapsing `posAt` to one label per state
  restricts the class to models in which `⊡φ ↔ φ`. Cite `certA`/`certB`'s measured live-label
  multiplicity as the witness, and `PlusDeterminism.stab_iff_of_deterministic` as the name of the
  collapse. This closes the option-3 line the way the prior report's R2 closed option 2.
- **R3 — Land the probe's embedded-route equalities as a regression triple.**
  [VERIFIED: PASS -- gate: elaboration under `lake env lean`;
  `botSnce_posAtFull_eq_liveAt`, `botUntl_posAtFull_eq_liveAt` and
  `liveFamily_posAtFull_eq_liveAt` each elaborate clean with `maxRecDepth 4000000` /
  `maxHeartbeats 2000000`, zero sorries, axioms `[propext, Classical.choice, Quot.sound]`].
  They state, at the three embedded certificates,
  that the full-label position space coincides with the computed live set — which is the precise,
  checkable form of "the embedding produces no junk positions". That is a fact about the
  embedding worth pinning independently of option 3, and it is the natural home for the prior
  report's open obligation R1 (a general proof that embedded certificates satisfy the filtered
  backward conjunct). Site them beside `EmbedComplete.lean`'s `botSnceFamily` / `botUntlFamily`
  block, stating `posAtFull` as a local definition in that module rather than promoting it into
  `Position.lean`, so that no consumer of `posAt` is touched.
- **R4 — If option 3 is ever revisited, revisit it as a new class, not a refinement.**
  `[No compiled gate applicable]` The viable shape is: full labels *plus* an explicit
  state-sharing relation on slice slots, with `⊡` quantifying over a sharing class and the frame
  carrier becoming the quotient. That mirrors `PlusSharingWitnessFamily` and would need its own
  soundness and completeness development, its own frame construction and its own limit results.
  It is not "most of Stage 2 again"; it is a parallel subtree. It should only be opened against a
  stated benefit the two-filter design does not already give.
- **R5 — Leave the `⊇` repair where it is.** `[No compiled gate applicable]` Absorption of the
  pre-period into `mid` remains the only repair for the superset failure; F5 confirms no label
  refinement reaches it, and `Position.lean`'s header already says why.

## Decisions

- **D1 — (2) Decidability survives full labels.** The replacement predicate is a `Finset`
  equality and the position space shrinks; `decidableCertifies` is unaffected. The deferral
  note's stated reason is a rework cost, not a decidability loss.
- **D2 — (1) The obstruction cannot be removed at its root this way.** Full labels collapse the
  `⊡` comparison class to a singleton and kill both landed `⊡`-carrying witnesses outright
  (empty `posAtFull`). The label multiplicity in `posAt` is the semantic content of `⊡`.
- **D3 — The task description's premise is confirmed on the embedded route only.**
  `posAtFull = liveAt` at every window time at all three embedded certificates, including the two
  `⊥`-targets that each forced one filter — but it fails at `Fixture.cert`, so it is a property
  of the embedding and not of the label refinement.
- **D4 — (3) No weaker label refinement is available.** Any refinement that deletes exactly the
  dead labels must compute one-directional liveness on the position graph, which is the filter
  under another name, applied at a more expensive place.
- **D5 — (4) The superset failure survives independently.** It is a presentation failure
  (unabsorbed pre-period); full labels delete its witness only by deleting a live position with
  it. Absorption remains the repair.
- **D6 — The landed two-filter design stands as the ideal target**, for the reason the prior
  report gave (symmetry) and now for a second one: it is the only design on the table that keeps
  the `⊡` content of the class.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The `⊡`-collapse argument is stated semantically and measured at two certificates, not proved as a general theorem about the class | Medium | The measurement is of the quantity the `stab` clause reads (`liveAt` restricted to one state), at the only two `⊡`-carrying witnesses the class has. A general theorem would be `StabFaithful` under `posAtFull` implies `⊡χ ∈ slab ↔ χ ∈ slab`, which is one `simp` from the collapsed quantifier; it is worth landing only if R2's paragraph is judged to need it |
| R2 | `certA`/`certB` could be rebuilt with `LabCoherent` slabs, weakening F3 | Low | F3 is not the load-bearing finding; F2 is. A rebuilt `certA` still has two live labels over one state and still loses its `⊡` content. F3's value is that it shows option 3 re-types the `slab` field, which no rebuild changes |
| R3 | A reader later re-proposes option 3 from the prior report's D7 fallback list | Low | R2 above: record the refutation at `Position.lean`'s header, where the over-approximation is already discussed, as a positive statement about the `stab` clause's comparison class |
| R4 | R3's regression triple adds `decide`-heavy declarations to `EmbedComplete.lean`, whose build cost is already significant | Low-medium | The three measured computations are each at `posAt` cardinality 2 over four or six window times — the cheapest fixpoints in the subtree. Carry explicit finite `maxHeartbeats` caps, as `Examples.lean` does, so a cost regression fails the build rather than slowing it |
| R5 | The probe's `posAtFull` is a local definition and could drift from any future `posAt` change | Low | It is three lines and is stated beside the landed `posAt`; R3 sites it in the same module as its consumers |

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `certA.target.lab 0 ≠ certA.slab 0 (certA.target.st 0)` | `decide` | success | `maxRecDepth 100000` |
| `certB.target.lab 0 ≠ certB.slab 0 (certB.target.st 0)` | `decide` | success | `maxRecDepth 100000` |
| `¬ LabCoherent [] [targetA atomP] (certA.slab 0 0)` | `decide` | success | `maxRecDepth 400000` |
| `posAtFull certA 0 = ∅` / `posAtFull certB 0 = ∅` | `decide` | success | `maxRecDepth 400000` |
| `((certA.liveAt 0).image Prod.fst).card < (certA.liveAt 0).card` | `decide` | success | `maxRecDepth 4000000`, `maxHeartbeats 2000000`; fails with "maximum recursion depth" at the default |
| `∀ t ∈ winTimes, posAtFull (botSnceFamily.sliced 0) t = liveAt t` | `decide` | success | `maxRecDepth 4000000`, `maxHeartbeats 2000000` |
| `∀ t ∈ winTimes, posAtFull (botUntlFamily.sliced 0) t = liveAt t` | `decide` | success | same |
| `∀ t ∈ winTimes, posAtFull (liveFamily.sliced (-1)) t = liveAt t` | `decide` | success | same |
| cardinality readouts (`posAt`, `posAtFull`, `liveAt`, `winTimes`) | `#eval` | success | `Finset.card` only — `Finset.toList` is noncomputable and will not compile under `#eval` |

## Context Extension Recommendations

- **Topic**: what the `posAt` over-approximation *buys*, as distinct from what it costs.
  **Gap**: `Position.lean`'s header, `Stable.lean`'s docstrings and the prior research round all
  state the cost (two filters, two failure modes). Nothing states the benefit — that the label
  multiplicity over one state at one time is the comparison class of `PlusTruthAt`'s `stab`
  clause, so it is the class's entire `⊡` content and cannot be collapsed.
  **Recommendation**: fold this into the `context/project/lean4/domain/position-overapproximation.md`
  the prior round already recommended, as its second half, rather than creating a second file.

## Appendix

### Probe

`specs/714_evaluate_full_labels_in_sliced_certificate/probes/FullLabels.lean`, five parts
(A: the two total-edge witnesses under full labels; B: live-label multiplicity; C: the embedded
`⊡`-free route; D: the two `⊥`-targets that forced each filter; E: the superset failure).
Elaborates clean under `lake env lean`; zero `sorry`; all ten theorems report
`[propext, Classical.choice, Quot.sound]`.

### Files read

- `PlusSlicedCertificate/Position.lean` (whole), `Check.lean` (1-120, 350-600), `Basic.lean`
  (328-450), `Frame.lean` (1-80), `Sound.lean` (37-230), `Complete.lean` (1-70), `Stable.lean`
  (490-850), `Embed.lean` (470-620, 690-851), `EmbedComplete.lean` (820-880), `Examples.lean`
  (whole), `Fixture.lean` (255-340, 847-1058), `FixtureStable.lean` (declaration list),
  `Limits/README.md`
- `PlusLanguage/Formula.lean` (91-116), `PlusLanguage/PlusTruth.lean` (80-100, 140, 203-381),
  `PlusWitnessFamily/Limits/Targets.lean` (20-135)
- `specs/archive/703_lplus_compression_and_completeness/reports/06_tailstable-backward-conjunct-repair.md`

### Searches and lookups used

`grep` over `FormalSystem/**` for `decidableCertifies`, `structure PlusSlicedCertificate`,
`def sliced`, `sliced_slab`, `trLab`, `pumpTarget`, `botFamily`/`botSnce`/`TailStableMirror`,
`def liveFamily`, `def liveAt`/`TailStable`/`fwdLiveAt`/`bwdLiveAt`, `def targetPos`,
`inductive PlusFormula`, `stab`. No web search and no rate-limited Mathlib search tool was used.
