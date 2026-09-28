# Phase 14 Handoff — Task 683 (final)

## Immediate next action

**None within this task.** All fourteen plan phases are closed and the full gate set is green.
This file exists as the terminal record: what landed, what is deliberately absent, and where a
successor should look first.

## State

| Phase | Marker | Notes |
|---|---|---|
| 1-5 | `[COMPLETED]` | `Sharing/{Basic,Thread,Frame,Histories}.lean` |
| 6 | `[COMPLETED WITH EXCLUSIONS]` | `Sharing/Predicates.lean`; (C5) excluded by user decision |
| 7 | `[COMPLETED]` | `Sharing/Decide.lean` — the combined window, (C0)/(C1') decidable |
| 8 | `[COMPLETED]` | `Sharing/Fulfil.lean` — the position graph and the `A[g U e]` fixpoint |
| 9 | `[COMPLETED WITH EXCLUSIONS]` | (C2') and its (C1')-relative decision procedure |
| 10 | `[COMPLETED]` | `Sharing/Agreement.lean` — the branching `model` and **T1** `truth_iff_mem` |
| 11 | `[COMPLETED]` | `Certifies`, `decidableCertifies`, the second `Refutes` producer |
| 12 | `[COMPLETED]` | `Sharing/Specialize.lean` — `toSharing` and the four condition reductions |
| 13 | `[COMPLETED]` | The frame isomorphism and truth transport |
| 14 | `[COMPLETED]` | `Sharing/README.md`, the (C3) correction, the final gate |

Full `lake build` green (2750 jobs, exit 0, zero `error:` lines). Sorry count 0. Axiom count 14,
unchanged. `#print axioms` on all fifteen pinned Goals reports exactly
`[propext, Classical.choice, Quot.sound]`. `git diff` on `Semantics/ShiftSet.lean` and on the
five deterministic `WitnessFamily/*.lean` modules is empty against the dispatch's own starting
commit.

## What a successor inherits

Read `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` first — it is the
durable map and carries the module table, the `share` encoding rationale, the condition
break/reuse table with the (C3) correction, the (C2') decidability limitation, the accurate
`Probe476.fmp_false` scoping, the three-part (C5) status, and the consuming-checker hand-off.

The two modules added in this dispatch:

### `Sharing/Agreement.lean`

- `model` — the branching `TaskModel`; takes the (C0) proof as an argument, because the
  valuation is a `Quotient.lift` and is not well defined without it.
- `untl_mem_along_thread` / `snce_mem_along_thread` — the deterministic inner inductions run
  along a thread instead of along a lasso, with `θ.step` and `thread_share_pred` supplying the
  sharing side condition at each step.
- `truth_iff_mem` — **T1**. Stated at `TruthAt` directly (there is no `ShiftTruth` layer),
  generalised over the thread and the time offset.
- `Certifies`, `decidableCertifies`, `truth_main_iff_mem`, `not_consequence_ztime`,
  `joint_countermodel`, `refutes_of_certifies`.

### `Sharing/Specialize.lean`

- `WitnessFamily.toSharing` and `share_toSharing`, `atomCoherent_toSharing`,
  `localCoherentShare_toSharing`, `threadFulfilling_toSharing`, `certifies_toSharing`.
- `thread_toSharing_eq_zero` / `thread_toSharing_idx` — every thread at the diagonal is
  constant. **Reuse these** rather than re-deriving; the proof is an `Int.induction_on` on the
  step field and is easy to get wrong in the negative branch.
- `stateEquiv` / `histEquiv` / `truthIso` / `truth_iff_mem_toSharing` — the isomorphism and the
  transport.

## Traps, continuing the numbering from the Phase 9 handoff

18. **`W.std.Carrier` does not unfold at reducible transparency.** It is a structure field of a
    plain `def` (`ShiftSet.ofIntAction`), so a `rw` whose pattern is typed at
    `Fin |lassos| × ℤ` silently fails to fire against a term typed at `W.std.frame.WorldState`,
    with a confusing "not type-correct under the `implicit` transparency level" note.
    `stateEquiv_cls_pair`, `cls_stateEquiv` and `taskRel_toSharing'` exist purely so the
    obligations can be discharged by `exact` (default transparency) instead of by `rw`.
19. **`Quotient.inductionOn` yields `⟦p⟧`, not `S.cls p.1 p.2`.** A `rw` with
    `SharingWitnessFamily.frame_taskRel` will not match until the pair is destructured
    (`obtain ⟨i, u⟩ := p`), after which the two spellings coincide syntactically. Prefer
    `Iff.trans (S.frame_taskRel _ _ _) ?_` over `rw`, which unifies up to reducibility.
20. **`Int.induction_on`'s alternative names are not `hz`/`hp`/`hn` here.** `induction u using
    Int.induction_on with | hz => …` is rejected; the expected names are `zero`/`succ`/`pred`.
    `refine Int.induction_on u rfl ?_ ?_` avoids the question entirely and is what is used.
21. **`simp` does not always reduce `x ∈ [a]` to `x = a`** in this import closure — it did in
    one place in `Specialize.lean` and not in another, with no visible difference. Use
    `List.mem_cons.mp` explicitly, and close a residual `x ∈ []` with `cases h`, not
    `simp at h`, which leaves the goal open.
22. **The `show` tactic is linted.** `linter.style.show` rejects a `show` that changes the goal;
    use `change`.
23. **The unused-simp-argument linter is on.** A `simp only [...]` list with a lemma that never
    fires is a build warning naming the lemma. Trim the list rather than suppressing it.

## What is deliberately absent

- **(C5) `StabFaithful` and the `⊡` case of the truth lemma.** Not stateable at a
  `Formula`-indexed certificate; the modal is `PlusFormula.stab` on a separate inductive. A
  follow-up needs an L⁺-indexed certificate datatype, which also re-opens the JSON export
  contract. `Sharing/README.md` records this in three parts.
- **A standalone `Decidable (ThreadFulfilling S)`.** Accepted as coherence-relative by user
  decision. The unconditional form would need a cycle edge `-1 → -NB-1` in the position graph's
  backward region and the fixpoint lemmas re-proved against the larger walk set.
- **A `Sharing/Examples.lean`.** There is no exhibited family satisfying the deterministic (C2)
  but failing (C2'). That is the direct non-vacuity witness for the whole design and is the
  single most valuable follow-up.
- **Any change to the consuming model checker.** Deliberately untouched; the hand-off is prose.
