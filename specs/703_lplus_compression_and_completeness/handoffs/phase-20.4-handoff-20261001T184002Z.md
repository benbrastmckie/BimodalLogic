# Handoff: Task 703, sub-phase 20.4 complete

- **Dispatch**: seq 52, session sess_1790878557_2f4b14
- **Worktree**: /home/benjamin/Projects/BimodalLogic/.orchestrate-worktrees/703-52 (branch orchestrate/task-703-52)
- **Commits**: f082fbfc4 (20.3), 779cd6b9a (20.4)

## Immediate next action

Sub-phase 20.5 — `hTS` at the embedding, `hconc`, and the flagship. The filter is landed, so the
remaining obligation is the GENERAL theorem: `(W.sliced tt).TailStable` for an arbitrary certifying
`W : WitnessFamily [] [φ]`, at every residue of both periods. Seven certificates now return
favourable (two `untl`, two atomic `snce`, two `⊥`-targets, plus `Fixture.cert` returning
UNfavourable and correctly so).

## What landed at 20.4

`TailStable`'s backward conjunct is now the mirror-filtered one. The operative definition is

```
(∀ r ∈ Finset.range G.NBnat,
    G.iterBack (-G.NB - r) (G.liveAt (-G.NB - r)) G.NBnat ∩ G.bwdLiveAt (-G.NB - r)
      = G.liveAt (-G.NB - r))
∧ (∀ r ∈ Finset.range G.NFnat, ... ∩ G.fwdLiveAt ... = ...)
```

### Stable.lean
- `bwdLiveAt`, `mem_bwdLiveAt`, `bwdLiveAt_subset_posAt`, `liveAt_subset_bwdLiveAt`, `L₀bwd`,
  `L₀_subset_L₀bwd` — the promoted filter (`bwdLiveAtCand` is gone)
- `foldB_tail`, `prevTime_le_left`, `mem_L₀bwd_of_bwdLive_tail` — the soundness chain, mirroring
  `foldF_head` / `nextTime_ge_right` / `mem_R₀fwd_of_fwdLive_head`
- `foldB_shift`, `mem_bwdLiveAt_of_bwdLive_tail` — their generic (arbitrary negative reference time)
  forms, mirroring `foldF_shift` / `mem_fwdLiveAt_of_fwdLive_head`
- Asymmetry note DELETED; replaced by one note saying both directions carry an obstruction, each
  caught by its own iterate, each needing its own filter, as a consequence of `posAt`'s
  over-approximation
- `tailStable_back` now states the FILTERED `r = 0` instance; `tailStable_of_raw` re-proved on both
  sides; `liveAt_refBack_subset_Φ`, `L₀_subset_Φ_back_L₀`, `liveAt_refBack_subset_iterBack`,
  `L₀_subset_iterBack` added as the one-sided replacements
- `iterBack_liveAt_refBack` and `iterBack_L₀` now take `TailStableRaw` (mirroring
  `iterFwd_liveAt_refFwd` / `iterFwd_R₀`)
- `forall_mem_L₀_of_live_tail` added; `mem_L₀_of_live_tail` is its one-liner wrapper, so its
  STATEMENT is unchanged for consumers
- `forall_mem_liveAt_of_live_tail` added; `mem_liveAt_of_live_refBack` routes through it
- `set_option linter.style.longFile 1700` added (file is 1528 lines)

### Tail.lean
- `live_of_mem_liveAt_tail`'s `hstab` is now the INCLUSION `liveAt t₀ ⊆ iterBack t₀ (liveAt t₀) (j * NBnat)`
  (was the equation), mirroring `live_of_mem_liveAt_head`. `live_of_mem_liveAt_refBack` and
  `live_of_mem_L₀_tail` re-routed to `liveAt_refBack_subset_iterBack` / `L₀_subset_iterBack`. All
  three statements unchanged for consumers.

### EmbedComplete.lean
- Candidate retired: `bwdLiveAtCand`, `liveAt_subset_bwdLiveAtCand`, `TailStableMirror`,
  `decidableTailStableMirror` all deleted
- `TailStableBack` is now the FILTERED isolated conjunct; the raw one is `TailStableBackRaw`;
  `tailStableBack_of_raw` relates them; `tailStable_iff_conjuncts` is still `Iff.rfl`
- Verdicts restated: `snceProbeFamily_not_tailStableBackRaw` / `snceProbeFamily_tailStableBack` /
  `snceProbeFamily_tailStable` (POSITIVE now — the repair discharges the refutation), same for
  `snceProbeLiveFamily`; `emptyFamily_tailStableBack`, `liveFamily_tailStableBack`
- Asymmetry paragraph at the old `:497-501` DELETED
- New `BotTargets` namespace: `⊥ U ⊥` and `⊥ S ⊥` with `not_validZTime_botUntl` /
  `not_validZTime_botSnce`, `botUntlFamily_certifies` / `botSnceFamily_certifies`,
  `botUntlFamily_not_tailStableRaw` / `botSnceFamily_not_tailStableBackRaw`, and
  `botUntlFamily_tailStable` / `botSnceFamily_tailStable`

### FixtureStable.lean
- `Φ_back_L₀_inter_ne_cert` added — the FILTERED backward conjunct still fails at `Fixture.cert`,
  a `⊇` failure no filter repairs. `not_tailStable_cert`'s first component is stated against it, so
  the demand is confirmed non-vacuous after the repair
- Standing probe-shape rule added to the module header

### Position.lean
- Header note: `posAt` over-approximates; the `⊆`/`⊇` dichotomy; a `⊆` failure is filterable and a
  `⊇` failure is not; `TailStable` is therefore a demand and not a theorem; and the same fact is
  what closes option 2 (the undischargeable positions are determined by `posAt`, not by any family)

## Verification at 20.4 (every item passed)

- `lake build` exit 0, "Build completed successfully (2805 jobs)", zero `error:` lines
- `example (G) : Decidable G.TailStable := inferInstance` elaborates — decidability SYNTHESIZED
- `Fixture.not_tailStable_cert` holds, first component against the filtered conjunct
- `Sound.lean` and `Complete.lean` untouched (empty `git diff`) and elaborate
- `PlusWitnessFamily/Agreement.lean` and `WitnessFamily/Compression/Family.lean`: empty `git diff`
- zero `sorry`; repo `^axiom ` count 12, unchanged; axioms on every new declaration checked are
  exactly `[propext, Classical.choice, Quot.sound]`
- no module states the both-filtered demand is a theorem; no module retains the deleted asymmetry
  claim (greps clean)

## Deviations

One, annotated on the plan checklist item: the `⊥`-target regression pair landed in
`EmbedComplete.lean`'s new `BotTargets` namespace rather than in `FixtureStable.lean`, because the
pair needs `WitnessFamily` and `.sliced`, which `FixtureStable.lean` does not carry and
`EmbedComplete.lean` already does beside the two `snce` probes. `FixtureStable.lean`'s header names
the namespace, so the record is reachable from where the plan said to put it.
