# Research Report: Task #703

**Task**: 703 - L⁺ compression and completeness
**Started**: 2026-10-01T17:33:00Z
**Completed**: 2026-10-01T18:40:00Z
**Effort**: 1 research round (dispatch 50)
**Dependencies**: task 695 (landed), task 696 (substrate as finally corrected), task 699 Parts A/B
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/**`,
  `WitnessFamily/**`, `Semantics/**`), lean-lsp MCP, kernel evaluation via `decide`, prior reports
  `01_lplus-compression-completeness-research.md` and `02_semantics-first-compression-research.md`,
  handoff `phase-20-handoff-20261001T163527Z.md`
**Artifacts**: - `specs/703_lplus_compression_and_completeness/reports/06_tailstable-backward-conjunct-repair.md`
  - `specs/703_lplus_compression_and_completeness/probes/TailStableBackForced.lean` (377 lines,
    elaborates clean, zero sorries, every result on `[propext, Classical.choice, Quot.sound]`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **(a) The soft link HOLDS.** `e S g` with atomic guard and event is a genuine ℤ-time
  non-validity, and the closure type of every world of the all-false countermodel is empty —
  both now kernel-checked (`not_validZTime_snceTarget`, `typeAtM_empty`). Dispatch 49's
  refutation stands; the question does not dissolve.
- **(b) The undischargeable `snce` positions are FORCED, and option 2 is IMPOSSIBLE as framed.**
  The dead position is not a property of the family's labels at all. `posAt` admits *every*
  closure subset that is internally coherent and agrees with the slice labelling on the state
  shapes — atoms, `□`, `⊡` — and temporal obligations are pinned by nothing. At the target
  `⊥ S ⊥` the closure is `{⊥ S ⊥, ⊥}`, which carries **no** state shape and **no** implication,
  so `posAt` is the *same two-label set for every certificate over that target*, and
  `LocalCoherentLab` additionally forces **every label of every certifying family to be empty**
  (`all_labels_empty`). The backward conjunct fails there, measured at three families spanning
  two slice widths and three period triples. No strengthening of the compression theorem's
  output can touch a set its output does not determine.
- **(c) And strengthening compression would NOT permit removing the forward filter.** The exact
  mirror target `⊥ U ⊥` refutes the **raw** forward demand `Φ_fwd R₀ = R₀` at a family whose
  labels are likewise forced empty, while the landed **filtered** forward conjunct holds there.
  The one reason option 2 might have dominated option 1 does not exist.
- **(d) The dispatch-49 challenge to `Stable.lean`'s asymmetry justification HOLDS.** The
  justification is stated in `Bridge.lean` about the **right** tail and is correct about it; it
  does not cover the left tail, whose times are negative, which `FoldB` does relate
  (`foldB_tail : FoldB (-NB) (-NB - k·NB)` is an arithmetic mirror of the landed `foldF_head`).
  Every backward transport the mirror needs is already landed — `bwdLiveT_greatest`,
  `mem_bwdLiveT_of_bwdLive`, `bwdVert`, `bwdVert_mem_predT`, `foldB_bwdOrbit`, `foldB_posAt`,
  `foldB_predP`, `foldB_prevTime`, `snceLive`, `predT`. Exactly one definition is missing:
  `bwdVertFold`.
- **The ideal target is option 1 — and it is option 1 *because* it is the symmetric design,**
  not because it is the cheapest. With both conjuncts filtered, `TailStable` becomes a single
  shape stated twice, `Stable.lean`'s asymmetry note is deleted rather than amended, and
  `Compression/Family.lean` stays closed, preserving the task description's scope.
- **One tempting stronger target is REFUTED, so it does not get proposed.** The both-filtered
  demand is **not** a theorem: `Fixture.cert.TailStableMirror` is false by `decide`, while
  `Fixture.cert.TailStableFwd` is true. `TailStable` must remain a demand on `Certifies`.

## Context & Scope

This round answers the five questions the user's ruling of 2026-10-01T17:32:07Z put in order,
and nothing else. It does **not** implement a repair.

Obligations O1–O4 named in the task description were answered in round 1
(`reports/01_lplus-compression-completeness-research.md`, findings F2–F5 and decisions D1–D4:
`Liftable` is decidable; the general liftable `trans` routes through `liftable_of_spliceClosed`;
the lasso-count bound is singly exponential rather than `|closure| + 1` or `|closure| × window`;
no GKWZ product-undecidability result bounds this combination). They are not reopened here.

**Soundness is untouched.** `PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` were neither read into any proof nor modified; no file under
`FormalSystem/**` was changed by this round at all.

**One incidental repair landed.** The main tree's `.lake` carried the documented stale-`.olean`
hazard for a **seventh** time — 9 `.olean`s for 23 `PlusSlicedCertificate` modules with every
`.trace` claiming current, and a `FormalSystem.olean` predating `Embed.lean`. The documented
remedy was applied (delete the subtree's `.olean`/`.ir` pairs, the two aggregators and the five
`.lake/build-guard.*` files, then rebuild through the guard). Full `lake build` is green at
**2805 jobs**. The next dispatch's worktree will no longer inherit the stale pairs.

## Findings

### F1 — (a) The soft link is proved, not assumed

Dispatch 49 recorded one link in its chain as "stated, not proved": that `snce g e` with `g`, `e`
atoms is ℤ-time invalid and that the full closure type of every world of such a countermodel is
empty, which is what makes `snceProbeFamily`'s all-empty labelling the labelling a countermodel
actually produces. Both halves are now kernel-checked, in the all-false valuation on the
permissive frame over ℤ:

| Result | Statement |
|---|---|
| `Probe703D50.not_validZTime_snceTarget` | `¬ ValidZTime (Formula.snce (atom g) (atom e))` |
| `Probe703D50.typeAtM_empty` | `typeAtM PModel [] [snceTarget] PHist u = ∅`, at every `u : ℤ` |

The second is the stronger of the two and is the one that was at issue: the closure of the target
is `{e S g, g, e}`, every member is false at every time of that history, so the extracted type is
`∅` everywhere. The refutation therefore rests on nothing soft. **(a) is settled affirmatively.**

### F2 — (b) The dead positions come from `posAt`, not from the family

This is the structural fact the whole adjudication turns on, and it is visible in one definition.
`Position.lean:150` reads

```
posAt G t = univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ G.AgreesOnState t p.1 p.2.1)
```

`LabCoherent` is a condition on the label **alone** (`⊥` absent, the implication clause).
`AgreesOnState` pins only the **state shapes** — `IsStateShape` is `true` at `atom`, `box`, `stab`
and `false` everywhere else — against `G.slab t w`. And `Embed.lean`'s `sliced_slab` says
`(W.sliced tt).slab t i = trLab (W.L i t)`: the family reaches the position graph through the
slice labelling and through nothing else.

So an `untl`- or `snce`-membership of a candidate label is constrained by **no** family datum.
A label carrying a `snce` obligation that no admissible predecessor can discharge is a legitimate
member of `posAt` with empty `predP` and non-empty `succP`, exactly as the dispatch-49 handoff
described — and *which* labels those are is fixed by the closure and the state shapes in it, not
by the family.

**The decisive instance.** Take the smallest target whose closure carries a `snce` obligation and
nothing else, `⊥ S ⊥`. Its closure is `{⊥ S ⊥, ⊥}`. Then:

* there is no implication in it, so `LabCoherent X ↔ ⊥ ∉ X`;
* there is no `atom`, no `□` and no `⊡` in it, so `AgreesOnState` is **vacuous**;
* hence `posAt t` is `Fin n ×ˢ {∅, {⊥ S ⊥}}` at every `t`, for **every** certificate over the
  target — the family cannot influence it even in principle.

Two family-independent halves of that are proved for an arbitrary certificate over an arbitrary
target rather than evaluated:

| Result | Statement |
|---|---|
| `mem_posAt_of_no_state_shape` | a `⊥`-free, implication-clause-satisfying label is in `posAt t` at every slice when the closure has no state shape |
| `predP_eq_empty_of_bot_snce` | a label containing `⊥ S ⊥` has `predP t q = ∅`, at every `t`, in every certificate — no hypothesis on the family, the slice labelling or the edge relation |

And the family side is pinned too:

| Result | Statement |
|---|---|
| `all_labels_empty` | **every** `W : WitnessFamily [] [⊥ S ⊥]` with `W.LocalCoherentLab` has `W.L i t = ∅` at every `i`, `t` |

The proof is two lines of the coherence clauses: `⊥ ∉ L i t` is clause 1, and the `snce` clause
`⊥ S ⊥ ∈ L i t ↔ (⊥ ∈ L i (t-1) ∨ (⊥ ∈ L i (t-1) ∧ …))` has a right-hand side that clause 1
makes false. So a certifying family over this target is free **only** in its lasso count and its
three segment lengths — which is exactly what the three evaluated instances vary.

**The verdicts**, all by `decide` at compression-admissible families:

| Family | `n` | `perB`/`perM`/`perF` | `Certifies 0` | `TailStableBack` | `TailStableFwd` | `TailStableMirror` |
|---|---|---|---|---|---|---|
| `botFamily` | 1 | 1 / 0 / 1 | true | **false** | true | true |
| `botFamilyLong` | 1 | 2 / 3 / 2 | true | **false** | true | true |
| `botFamilyWide` | 2 | mixed | true | **false** | true | true |

`not_validZTime_botSnce` establishes that `⊥ S ⊥` is a genuine ℤ-time non-validity, so the
compression theorem applies to it and these families are not off-specification.

**Why this is a demonstration of impossibility and not one more counterexample.** Option 2 asks
for a strengthened *output* of `exists_witnessFamily_of_not_validZTime` — a further property of
the produced `W` — that excludes the junk positions. At this target the produced `W` is
label-determined (`all_labels_empty`) and the junk position is `posAt`-determined independently
of `W`. There is no property of `W` left to strengthen that could move the verdict. **(b)
returns FORCED.**

A note on the one escape that does exist and does not generalise: for the *atomic* target
`e S g`, a family that labels `g` at every world and `e` at none also certifies, and there the
junk label `{e S g, g}` is backward-live, so the obstruction is absent. That is a guard-saturation
trick available when the guard is a free atom. It is unavailable at `⊥ S ⊥`, where the guard is
`⊥` and `LabCoherent` forbids it from any label. So the escape is an artifact of the particular
probe target dispatch 49 chose, not a route to option 2.

### F3 — (c) The forward filter is not removable either

If the dead positions were a compression artifact, then strengthening compression would let the
forward liveness filter — landed at sub-phase 16.3 on the user's option-2 ruling of
2026-09-30T19:31:18Z — be removed, restoring symmetry by having *neither* conjunct filtered. The
dispatch's own question (c) names this as the specific reason option 2 might dominate option 1.

It does not. The exact mirror target `⊥ U ⊥` has closure `{⊥ U ⊥, ⊥}`, again with no state shape
and no implication, so `posAt` is again family-independent, and `all_labels_empty_untl` forces
every label empty by the `untl` clause in the same two lines. The verdicts:

| Result | Verdict |
|---|---|
| `botUFamily_certifies` | `Certifies 0` — true |
| `botUFamily_Φ_fwd_R₀_ne` | `Φ_fwd R₀ ≠ R₀` — **the raw forward demand fails** |
| `botUFamily_not_tailStableRaw` | `¬ TailStableRaw` |
| `botUFamily_tailStableFwd` | the landed **filtered** forward conjunct — true |
| `botUFamily_tailStableBack` | the unfiltered **backward** conjunct — true |

So the forward filter is removable only if compression could stop producing families over
`⊥ U ⊥`, which it cannot: the target is ℤ-time invalid (`not_validZTime_botUntl`) and is an
ordinary instance of the flagship's own statement. **(c) returns NO.** The two targets `⊥ U ⊥`
and `⊥ S ⊥` are a perfectly symmetric pair of smallest witnesses, one per obligation direction,
and each forces a filter on its own side.

**The asymmetry has a one-line explanation, now that both sides are measured.** `untlClauseAt X Y`
constrains the **earlier** label from the later one, and `snceClauseAt X Y` constrains the
**later** label from the earlier one. So an unfulfillable `untl` label has empty `succP` and
non-empty `predP` — forward-dead, caught by `iterFwd`, repaired by a forward filter; and an
unfulfillable `snce` label has empty `predP` and non-empty `succP` — backward-dead, caught by
`iterBack`, repaired by a backward filter. There is nothing asymmetric about the certificate; the
asymmetry was in which obligation direction the probes happened to carry. Sub-phase 20.1's two
favourable certificates both carried an `untl` closure and no `snce` at all, which is exactly why
they missed it.

### F4 — (d) The asymmetry justification is about the right tail, and the challenge holds

The justification exists in two places. `Stable.lean`'s note at `fwdLiveAt` and inside
`TailStable`'s docstring says "`FoldB` relates two negative times only, so no backward
counterpart of `mem_fwdLiveT_of_fwdLive_fold` exists **at the right tail**". The primary text is
`Bridge.lean:306-309`, under the heading "**Why there is no backward counterpart**", and it reads:

> `FoldB` relates two *negative* times, so it does not relate the right-tail times
> `G.NM + G.NF + k * G.NF` at all … That asymmetry is the reason the repaired forward conjunct of
> `TailStable` filters by the **forward** computed liveness and not by `liveAt`.

**Adjudication: the challenge is correct, and the note is correct about what it is about.** The
note explains why the *forward* conjunct's filter is `fwdLiveAt` rather than `liveAt`. It says
nothing against a *backward* fold lemma at the *left* tail, and it cannot, because:

* the left-tail times `-NB - k·NB` are all negative, so `FoldB`'s side condition is met;
* `foldB_tail : FoldB (-NB) (-NB - k·NB)` is immediate — both negative, and
  `(-NB) % NB = (-NB - k·NB) % NB = 0` — an exact arithmetic mirror of the landed `foldF_head`;
* a backward walk out of `-NB` stays in the left tail: `prevTime u = u - 1`, or `-NB - 1` at the
  left edge by `prevTime_edge`, so the mirror of `nextTime_ge_right` is an `omega` away.

What is already landed, and was built symmetrically: `bwdLiveT_greatest`,
`mem_bwdLiveT_of_bwdLive`, `bwdOrbit`, `foldB_bwdOrbit`, `bwdVert`, `bwdVert_mem_verts`,
`bwdVert_mem_predT`, `predT`, `snceLive` / `snceLiveAt`, `foldB_slice`, `foldB_posAt`,
`foldB_predP`, `foldB_prevTime`, `foldB_edge`, `foldB_target_datum`, `exists_foldB`.

**Exactly one definition is missing**: `bwdVertFold` (the off-diagonal `bwdVert`, mirroring
`fwdVertFold R s s' k`). `bwdVert` — its diagonal — exists. So the dispatch-49 cost estimate is
confirmed as the realistic one and the `Stable.lean` comment's implication that the mirror has
nothing to stand on is **not** supported by `Fold.lean`'s or `Bridge.lean`'s contents.

### F5 — The tempting stronger target is refuted, and should not be proposed

Before settling on option 1 it is worth asking whether the both-filtered demand is a **theorem**
for every certificate — in which case `TailStable` could be dropped from `Certifies` altogether,
which would dominate every option on the table. The heuristic for it is real: a position in
`Φ_back L₀` has a successor chain into the live set, hence looks forward-live, so filtering by
backward liveness ought to leave exactly the live positions.

**It is false, and the refutation is already in the tree.** `Fixture.cert` is the hand-built
certificate the whole demand exists for. Evaluated:

| Proposition at `Fixture.cert` | Verdict |
|---|---|
| `TailStableBack` | false (consistent with the landed `Fixture.Φ_back_L₀_ne_cert`) |
| `TailStableFwd` | **true** |
| `TailStableMirror` | **false** |

So the mirror filter does **not** repair `Fixture.cert`, and `TailStable` stays a genuine demand.
The reason is worth recording because it is a distinction the existing docstrings imply but never
state as a dichotomy — **the backward conjunct can fail in two independent ways**:

1. **a `⊆` failure**: a reachable-but-backward-dead junk position sits in `Φ_back L₀ \ L₀`. This
   is what every embedded certificate exhibits, and a filter removes it, because a filter only
   deletes elements from the left-hand side.
2. **a `⊇` failure**: a position live at the reference time has no backward extension across a
   whole period, so `L₀ ⊄ Φ_back L₀`. This is `Fixture.cert`'s failure — `mem_L₀_p₀` together
   with `not_mem_Φ_back_L₀_p₀`, the pre-period showing through. **No filter can repair it**, and
   the landed docstring already says the repair for it is absorbing the pre-period.

The forward conjunct's landed filter addresses (1) only, and `Fixture.cert`'s forward failure was
of type (1), which is why `not_mem_R₀fwd_pR` sufficed there. The mirror filter likewise addresses
(1) only — and (1) is precisely what the embedded route hits.

### Codebase Patterns

- `posAt` as a deliberate over-approximation is this subtree's central design choice and the
  source of both filters. `Position.lean`'s own header already records the matching fact that
  `succP` is not total on the position space and that this "is not a defect" — the same
  phenomenon read forwards. The two filters are the tail-stability-level consequence of that
  same decision, and the module header is the right place to say so once.
- Every forward/backward pair in `Fold.lean`, `Bridge.lean`, `Stable.lean` and `Tail.lean` was
  built as a mirror pair, with the single exception of `fwdVertFold`. The repair is therefore
  transcription against a landed twin at every step, not new mathematics — which is the main
  reason to trust the cost estimate.
- `Truth.bot_false`, `Truth.snce_iff`, `Truth.untl_iff`, `permissive_realizes` and
  `TaskFrame.isZTime_of_instances` are the idiom for a ℤ-time invalidity witness; the
  `Examples/Walkthrough.lean` `notValidZTimeGg` proof is the model to copy.
- `Finset.eq_empty_iff_forall_notMem` is the Mathlib spelling at this pin (not
  `..._forall_not_mem`).

### External Resources

No external search was needed for this round: every question was settled inside the repository,
by kernel evaluation or by reading the landed definitions. No Mathlib lemma was missing.

### Recommendations

**R1 — Adopt option 1, and adopt it as the symmetric design.** Replace `TailStable`'s backward
conjunct by the filtered one, promoting `bwdLiveAtCand` into `Stable.lean` as `bwdLiveAt` beside
`fwdLiveAt`. Record the reason as symmetry, not as cost: both obligation directions carry an
unfulfillable-label obstruction, each caught by its own iterate, each needing its own filter. The
`Stable.lean` asymmetry note is then **deleted**, not amended, and `Bridge.lean`'s "why there is
no backward counterpart" paragraph is rewritten to say what it actually establishes — that the
*forward* filter must be one-directional because `FoldB` does not reach the right tail.

**R2 — Do not pursue option 2, and record why in one durable sentence.** Not "it was expensive",
but: *the position space is an over-approximation determined by the closure and the state shapes,
so a family-level strengthening cannot reach it; there is a ℤ-time non-validity whose closure
admits a backward-dead coherent label at every slice of every certificate over it.* This also
keeps `Compression/Family.lean` closed and the task description's scope intact — the scope
widening the user accepted as a consequence of aiming high turns out not to be needed.

**R3 — Phase the implementation as two phases under H8 sizing.**

*Phase A — the backward fold lemma* (`Bridge.lean`, ~90 lines, no consumer changes):
`bwdVertFold`, `bwdVertFold_lab`, `bwdVertFold_snd`, `bwdVertFold_self`,
`bwdVertFold_mem_verts`, `bwdVertFold_mem_predT`, `mem_bwdLiveT_of_bwdLive_fold`, with
`mem_bwdLiveT_of_bwdLive` restated as its diagonal instance. Transcribe `Bridge.lean:241-370`
with `predT` / `snceLive` / `snceLiveAt` / `bwdLiveT_greatest` / `foldB_*` in place of the
forward names. This phase is independently green and independently committable.

*Phase B — the filter and the restatements* (`Stable.lean`, `Tail.lean`, ~200 lines):
`bwdLiveAt` and its three lemmas, `L₀bwd`, `L₀_subset_L₀bwd`, `foldB_tail`,
`prevTime_le_left`, `mem_L₀bwd_of_bwdLive_tail`; then the conjunct swap and the restatements
below, each against a landed forward twin.

**R4 — The restatement list, by name, with its forward twin.** Every entry already exists on the
forward side in the shape the backward side needs, because 16.3 did this once already.

| Backward declaration to restate | Landed forward twin to copy |
|---|---|
| `Stable.tailStable_back` | `Stable.tailStable_fwd` |
| `Stable.liveAt_refBack_subset_Φ` (new) | `Stable.liveAt_refFwd_subset_Φ` |
| `Stable.L₀_subset_Φ_back_L₀` (new) | `Stable.R₀_subset_Φ_fwd_R₀` |
| `Stable.iterBack_liveAt_refBack` → restate from `TailStableRaw` | `Stable.iterFwd_liveAt_refFwd` (already from `TailStableRaw`) |
| `Stable.iterBack_L₀` → restate from `TailStableRaw` | `Stable.iterFwd_R₀` |
| `Stable.liveAt_refBack_subset_iterBack` (new one-sided replacement) | `Stable.liveAt_refFwd_subset_iterFwd` |
| `Stable.L₀_subset_iterBack` (new) | `Stable.R₀_subset_iterFwd` |
| `Stable.mem_L₀_of_live_tail` | `Stable.mem_R₀_of_live_head` (filter step via `mem_R₀fwd_of_fwdLive_head`) |
| `Stable.mem_liveAt_of_live_refBack` | `Stable.mem_liveAt_of_live_refFwd` |
| `Stable.liveAt_winLo_subset_L₀` | the right-tail counterpart |
| `Stable.tailStable_of_raw` (first component) | its second component, already adjusted |
| `Tail.live_of_mem_liveAt_refBack`, `Tail.live_of_mem_L₀_tail` | `Tail.live_of_mem_liveAt_refFwd`, `Tail.live_of_mem_R₀_head` |
| `Tail.tailStable_iff_window`, `liveAt_tail_eq_L₀`, `liveAt_winLo_eq_L₀` | `Tail.tailStable_iff_window_fwd` and its pair |
| `Tail.exists_win_live_eq` — **left branch only** | the right branch, unchanged |
| `FixtureStable.not_tailStable_cert` | restate its first component against the filtered conjunct; `TailStableMirror` is false at `cert` by `decide`, so the fixture's verdict survives |

**R5 — Carry the two `⊥`-targets into the Lean tree as a permanent regression pair.** `⊥ U ⊥`
and `⊥ S ⊥` are the smallest witnesses that each conjunct needs its filter, they decide in
milliseconds, and they are the pair whose absence let sub-phase 20.1 return a favourable verdict
from two `untl`-only certificates. Land them beside `FixtureStable.lean`'s fixtures. Per the
user's C9 ruling of 2026-09-30, cite them as the library declarations they then are, and state
the mathematical claim — that a ℤ-time non-validity exists whose closure admits a backward-dead
coherent label at every slice of every certificate over it — rather than attributing anything to
a probe file.

**R6 — Add a standing probe-shape rule to the plan.** Any future evaluation of a `TailStable`-like
demand must carry **both** an `untl` and a `snce` in its closure. Dispatch 49 already recorded
this; it should become a checkable sentence in the plan rather than a handoff remark.

## Decisions

- **D1 — (a) is answered YES.** The soft link is kernel-checked. Dispatch 49's refutation stands
  unconditionally.
- **D2 — (b) is answered FORCED.** With a demonstration of impossibility, which is the condition
  the user's ruling set for falling back: the junk positions are determined by the closure and the
  state shapes through `posAt`, not by the family, and at `⊥ S ⊥` the family is label-determined
  while `posAt` is family-independent.
- **D3 — (c) is answered NO.** The forward filter is not removable; the mirror target `⊥ U ⊥`
  refutes the raw forward demand at a label-determined family. Option 2's distinguishing
  advantage does not exist.
- **D4 — (d) is answered: the challenge HOLDS.** The justification is about the right tail. The
  left tail's times are negative, `FoldB` relates them, and only `bwdVertFold` is missing.
- **D5 — The ideal target is option 1**, adopted as the symmetric design rather than as the
  cheap one. It is not a fallback from option 2: it is what option 2 was wanted *for*, reached by
  the route that is actually available.
- **D6 — The both-filtered demand is NOT a theorem** (`Fixture.cert.TailStableMirror` is false),
  so `TailStable` stays a field of `Certifies` and no attempt should be made to discharge it
  universally.
- **D7 — (e) The fallback ordering, should Phase A's `mem_bwdLiveT_of_bwdLive_fold` fail to
  close** (the only identified way option 1 can fail):
  1. **Option 1 as specified** — PRIMARY.
  2. **Option 1 with a weaker filter**: filter by `bwdLiveAt` at the reference time only where
     the soundness lemma is available, accepting a narrower certificate class, and record the
     narrowing exactly as sub-phase 18.3's residue indexing was recorded.
  3. **Option 3, route change** — the certificate carries full labels rather than only the state
     part, so `posAt` becomes a singleton and no junk position exists. This is the only repair
     that removes the obstruction at its source, and it costs the decidable search `Check.lean`
     is built around; it is most of Stage 2 again.
  4. **Option 4, stated limitation** — last, and only with the `⊥ S ⊥` witness quoted, because a
     limitation recorded without its smallest witness is not a usable record.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | A general proof that *embedded* certificates satisfy the mirror-filtered backward conjunct is still owed; the evidence is seven certificates (two `untl`, two atomic `snce`, three `⊥ S ⊥`) | Medium | This is Phase 20's own obligation under either option and is not created by option 1. Prove the `⊆` direction from `fwdLiveT`'s own gfp unfolding along the `stepBack` chain; the `⊇` direction from the genuine run that witnesses liveness |
| R2 | `mem_bwdLiveT_of_bwdLive_fold` could fail in a way the forward twin does not reveal | Low | Every input it needs is landed and was checked by name in F4; `foldB_tail`'s arithmetic was verified. Phase A is independently green, so the risk is discovered before any consumer is touched |
| R3 | The restatement list touches `exists_win_live_eq`, which Phase 18's truth lemma consumes | Medium | Only the **left** branch changes; the right branch was already rebuilt at 16.3 against the filtered forward conjunct and is the template |
| R4 | A reader later re-proposes option 2 from the dispatch-49 handoff's three-option list | Low | R2 above: record the impossibility as a positive statement about `posAt`, in `Position.lean`'s header where the over-approximation is already discussed |
| R5 | The stale-`.olean` hazard recurs an eighth time in a fresh worktree | Low-medium | The main tree is now clean and rebuilt at 2805 jobs, so hardlinked worktrees inherit current pairs. The hazard's recurrence count should be carried in the next handoff regardless |

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Certifies` and the four `TailStable*` verdicts at seven families | `decide` | success | `set_option maxRecDepth 40000` needed for `perB = 2` / `n = 2` families; the one-slot family needs none |
| `Fixture.cert.TailStableMirror` | `decide` | success (proved **false**) | `maxRecDepth 40000` |
| closure enumeration `botSnce_closure_cases` | `simp` | success | `[closureOf, botSnce, Syntax.subformulaClosure, Syntax.Formula.subformulas]`; a following `tauto` is *rejected* as "no goals" — `simp` closes it alone |
| `typeAtM_empty` | `rw` + `rcases` | success | `Finset.eq_empty_iff_forall_notMem`, `mem_typeAtM` |
| `not_validZTime_*` | `intro` + `rw` + `obtain` | success | `Truth.snce_iff` / `Truth.untl_iff`, `Truth.bot_false`, `permissive_realizes`, `TaskFrame.isZTime_of_instances` |
| `all_labels_empty` | `rcases` on the coherence clause | success | `LocalCoherentLab`'s fifth clause at `g = e = ⊥`; no automation needed |

Two mechanical notes for the implementer:

1. `subformulaClosure` and `Formula.subformulas` are **ambiguous** under
   `open FormalSystem.Metalogic.Decidability` — there is a `Branch → List Formula` homonym. Qualify
   as `Syntax.subformulaClosure` / `Syntax.Formula.subformulas` in any `simp` set.
2. `permissiveModel`'s valuation is `fun w _ => w = true` and therefore **ignores the atom**: every
   atom has the same truth value along a permissive history. That is harmless for an all-false
   countermodel and would be wrong for any probe that needs two atoms to differ.

## Context Extension Recommendations

- **Topic**: `posAt` as a deliberate over-approximation, and the two filters as its consequence.
  **Gap**: the fact is stated once in `Position.lean`'s header about `succP` totality and once
  more, partially and in the forward direction only, in `Stable.lean`. Nothing states the
  dichotomy of F3 (`untl` ⇒ forward-dead, `snce` ⇒ backward-dead) or the F5 dichotomy (`⊆`
  failures are filterable, `⊇` failures are not).
  **Recommendation**: a short `context/project/lean4/domain/position-overapproximation.md`, or a
  consolidated paragraph in `Position.lean`'s header that both `Stable.lean` docstrings point at
  instead of each restating half of it.

## Appendix

### Probe

`specs/703_lplus_compression_and_completeness/probes/TailStableBackForced.lean`, 377 lines, five
parts (A: the soft link; B: `⊥ S ⊥`; C: `⊥ U ⊥`; D: the family-independent `posAt`/`predP`
lemmas; E: `all_labels_empty`). Elaborates clean under `lake env lean`; zero `sorry`; every
checked result on `[propext, Classical.choice, Quot.sound]`.

### Files read

- `PlusSlicedCertificate/Position.lean` (lines 1-200), `Stable.lean` (120-290, 520-850, 870-940,
  1000-1230), `Tail.lean` (575-660), `Fold.lean` (55-270), `Bridge.lean` (100-370),
  `Embed.lean` (540-660), `EmbedComplete.lean` (420-689), `FixtureStable.lean` (160-359)
- `WitnessFamily/Compression/Family.lean` (153-183), `WitnessFamily/Compression/Types.lean`
  (81-96), `WitnessFamily/Predicates.lean` (67-134), `WitnessFamily/Closure.lean` (20-110)
- `Semantics/Truth.lean` (275-285, 440-475), `Semantics/IntTransfer.lean` (300-360),
  `Semantics/Frames/Standard.lean` (110-145), `Semantics/Correspondence/DurationFrames.lean`
  (160-215), `Examples/Walkthrough.lean` (240-340)
- `reports/01_lplus-compression-completeness-research.md`,
  `reports/02_semantics-first-compression-research.md`,
  `handoffs/phase-20-handoff-20261001T163527Z.md`

### Searches and lookups used

`grep` over `FormalSystem/**` for `exists_witnessFamily_of_not_validZTime`, `ValidInt`,
`FrameOver intOrder`, `typeAtM`, `closureOf`, `plusClosureOf`, `TailStable*`, `bwdLiveAtCand`,
`fwdVertFold`/`bwdVertFold`, `mem_fwdLiveT_of_fwdLive_fold`, `FoldB`, `prevTime`,
`subset_closureOf`, `hTS.1`; Mathlib grep for `eq_empty_iff_forall`. No web search and no
rate-limited Mathlib search tool was needed.
