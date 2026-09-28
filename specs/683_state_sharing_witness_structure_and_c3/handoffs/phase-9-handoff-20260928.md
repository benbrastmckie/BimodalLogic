# Phase 9 Handoff — Task 683

## Immediate next action

Resume at **Phase 10** (`forward_repr` and the truth lemma for the sharing family, in a new
`Sharing/Agreement.lean`). Nothing in Phase 9 blocks it. Read "What Phase 10 inherits" below
before writing, and read "The Phase 9 exclusion, and what it costs Phase 11" before writing
Phase 11.

## State

| Phase | Marker | Notes |
|---|---|---|
| 1-5 | `[COMPLETED]` | `Sharing/Basic.lean`, `Thread.lean`, `Frame.lean`, `Histories.lean` |
| 6 | `[COMPLETED WITH EXCLUSIONS]` | `Sharing/Predicates.lean`; (C5) excluded by user decision |
| 7 | `[COMPLETED]` | `Sharing/Decide.lean` — the combined window, (C0)/(C1') decidable |
| 8 | `[COMPLETED]` | `Sharing/Fulfil.lean` — the position graph and the `A[g U e]` fixpoint |
| 9 | `[COMPLETED WITH EXCLUSIONS]` | (C2'), both correctness directions, the (C1')-relative decision procedure; the standalone `Decidable (ThreadFulfilling S)` instance is excluded |
| 10-14 | `[NOT STARTED]` | |

Full `lake build` green. Sorry count 0. Axiom count unchanged. `#print axioms` on every new
declaration reports exactly `[propext, Classical.choice, Quot.sound]`. `git diff` on
`Semantics/ShiftSet.lean` and on all five deterministic `WitnessFamily/*.lean` modules is empty.

## What Phase 10 inherits

### From `Sharing/Predicates.lean`

- `ThreadFulfilling` — (C2'), the universal-path form, `untl` and `snce` halves conjoined.
- `fulfillingLab_of_thread` — (C2') implies the deterministic (C2), by the constant thread.
  The mirror of `localCoherentLab_of_share`; Phase 12 consumes both.

### From `Sharing/Fulfil.lean` (new in this dispatch)

- **Fold relations.** `FoldRel` (forward) and `FoldRelB` (backward), with `refl`/`symm`/`trans`,
  `foldRel_rep`, `foldRel_L` (and `B` duals), `foldRel_succ`, `foldRelB_pred`,
  `foldRel_nextTime`, `foldRelB_prevTime`, and the two window folds `exists_fold_fwd`,
  `exists_fold_back`. These are the general tool for moving between a graph time and a real
  time; Phase 10's `forward_repr` will want them wherever a label is read at a folded position.
- **Walks as threads.** `FwdWalk` / `BwdWalk` (an infinite walk plus its start vertex),
  `mem_verts`, `time_succ`, `share_succ`, the fold invariants `FwdWalk.foldRel` /
  `BwdWalk.foldRelB`, the index functions `walkIdx` with `walkIdx_add` / `walkIdx_sub` /
  `walkIdx_le` / `walkIdx_ge`, and `toThread`. **This is the construction Phase 10 should reuse
  if it needs to exhibit a thread**, rather than building one by hand.
- **(C1') propagation.** `untl_thread_step`, `snce_thread_step`, `thread_share_pred`,
  `untl_propagate` / `untl_propagate_le`, `snce_propagate` / `snce_propagate_ge`, and the two
  "event implies fulfilment" lemmas `untl_fulfil_of_exists` / `snce_fulfil_of_exists`.
  `thread_share_pred` in particular (`share t (θ.idx t) (θ.idx (t-1))`) is the small lemma the
  `snce` case of any thread induction needs and is easy to re-derive by accident.
- **Correctness.** `thread_untl_of_mem_untlFix` / `thread_snce_of_mem_snceFix` (soundness, both
  unconditional), `window_of_threadFulfilling` (completeness, unconditional),
  `threadFulfilling_of_window` (the (C1')-relative converse).
- **Decision procedure.** `fulfilClauseAt`, `FulfilWindow`, `decidableFulfilWindow`,
  `untlFix_of_window` / `snceFix_of_window`, `cohWindow_lo_mem` / `cohWindow_hi_pred_mem`,
  `threadFulfilling_iff_window`, `decidableThreadFulfilling` (a term, takes `hlc`), and
  `decidableCoherentShareAndFulfilling` (a genuine `instance` on the conjunction).

## The Phase 9 exclusion, and what it costs Phase 11

There is **no** standalone `Decidable (ThreadFulfilling S)`. The window reduction's far-left
case is closed by (C1') propagation, not by folding, and that is recorded at length in
`Sharing/Fulfil.lean`'s header and in the plan's Phase 9 Reasoned Exclusions table.

Consequence for Phase 11: assemble `decidableCertifies` from **four** pieces, not five —
`decidableAtomCoherent`, `decidableCoherentShareAndFulfilling` (covering both (C1') and (C2')),
`decidableBoxFaithful` and `decidableTarget` — and order `Certifies`' projections so the
`LocalCoherentShare ∧ ThreadFulfilling` pair is adjacent, or state `Certifies` as a structure
and prove its `Decidable` by `decidable_of_iff` through the reassociated conjunction. Nothing
is lost: `Certifies` carries (C1') anyway.

**This is a live user decision**, relayed on `.return-meta.json` as `user_decision`. The two
options are (1) keep the plan's standalone instance and find the genuinely unconditional
far-left argument — which would need the graph's backward region to carry a cycle edge
`-1 → -NB-1` in addition to `-1 → 0`, i.e. a Phase 8 revision — or (2) accept the
coherence-relative form as landed. Option 2 is what is implemented; option 1 is not ruled out
mathematically, only out of scope for this dispatch.

## Traps, in addition to the twelve recorded in the Phase 6 and Phase 8 handoffs

13. **`le_or_lt` does not exist here.** `lt_or_ge` does, and is what the rest of this directory
    uses. Split with `rcases lt_or_ge a b with h | h` and swap the branch bodies.
14. **`ring` is not available in `Sharing/Fulfil.lean`'s import closure.** `omega` covers every
    integer identity this phase needed, including the `Nat.cast` ones; `push_cast; omega` covers
    the rest.
15. **`rw [← h]` with `h : u + ↑k = t` rewrites `t` *inside* `(t - u).toNat` as well**, which
    silently turns a provable goal into an unprovable one. Prove the `walkIdx` equations by
    `simp only [walkIdx, if_pos …, hx]` with an explicit `toNat` equation `hx`, never by
    rewriting the time backwards.
16. **`push Not` on `¬(A ∧ B)` yields `A → ¬B`, not `¬A ∨ ¬B`.** The escape-function statement
    in `window_of_threadFulfilling` is phrased as `g ∈ L y → y ∉ untlFix` for exactly that
    reason; phrasing it as a disjunction costs a classical `by_cases` at every use site.
17. **`Sharing/Fulfil.lean` now carries `set_option linter.style.longFile 1700`**, placed
    immediately after the module docstring as `lakefile.toml` prescribes. Any further growth
    past 1700 lines must either raise that baseline or split the module; the linter also
    complains if the file shrinks more than 100 lines below it.
