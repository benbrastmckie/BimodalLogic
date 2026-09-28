# Phase 6 Handoff — Task 683

## Immediate next action

Decide (C5) — see the BLOCKER entry on Phase 6 of
`plans/01_state-sharing-witness-structure.md` — then resume at **Phase 7**
(`Sharing/Decide.lean`), which does not depend on (C5).

## State

| Phase | Marker | Notes |
|---|---|---|
| 1 | `[COMPLETED]` | `Sharing/Basic.lean` |
| 2 | `[COMPLETED]` | `Sharing/Thread.lean` |
| 3 | `[COMPLETED]` | `Sharing/Frame.lean` (frame + comp + serial) |
| 4 | `[COMPLETED]` | `Sharing/Frame.lean` (limit, saturation, IsRegular, ℤ-time) |
| 5 | `[COMPLETED]` | `Sharing/Histories.lean` |
| 6 | `[PARTIAL]` | `Sharing/Predicates.lean`; (C0) and (C1') landed, (C5) blocked |
| 7-14 | `[NOT STARTED]` | |

Full `lake build` is green (2746 jobs, exit 0). Sorry count 0. Axiom count unchanged.
`#print axioms` on every landed pinned Goal reports exactly
`[propext, Classical.choice, Quot.sound]`.

## What the next dispatch inherits

- `SharingWitnessFamily` with `rep` / `share` (kernel of a periodic representative map),
  `share_refl/symm/trans`, `rep_sub_back_length`, `rep_add_fwd_length`, `rep_idem'`,
  `share_rep`, `decidableShare`.
- `Step` (class-level one step), `ReachN` (n steps) with `reachN_congr_left/right`,
  `reachN_const`, `reachN_one`, `reachN_add`, `decidableReachN`; `Thread` with `const`, `ext`,
  `step'`, `reachN`.
- `shareSetoid`, `WorldState`, `cls`, `cls_eq`, `share_of_cls_eq`, `time`, `exists_cls`, `Conn`
  (+ `conn_symm`, `conn_of_reachN`, two congruences), `RelZ`, `relZ_cls` (an `Iff.rfl` —
  the workhorse for building and destructing the relation at classes), `relZ_reflection`,
  `frame`, `frame_taskRel`, `instIsRegular`, `instIsRegularTask`, `frame_isZTime`,
  `frame_sat_ztime`, `frame_sat_base`.
- `hist`, `hist_state`, `conn_thread`, `thread_is_history`, `total_eq_thread`.
- `AtomCoherent`, `LocalCoherentShare`, `localCoherentLab_of_share`, `untl_self_of_share`,
  `snce_self_of_share`.

## Traps this dispatch hit, so the next one does not

1. **`ring` and `push_cast` are not reliably in scope** in these modules. Use `omega`, via a
   named private lemma for the recurring `u + ((m+1 : ℕ) : ℤ) = u + 1 + (m : ℤ)` regrouping
   (`Thread.lean`'s `int_succ_shift` / `int_zero_shift`). `Nat.cast_zero` is not a known constant
   here either.
2. **`rw [Periodic.unrollOf]` and `rw [Periodic.cyc]` fail** in this directory: their equation
   lemmas carry an `[Inhabited α]` argument, and the decoding runs at `repIdInhabited`, which is
   deliberately not an instance. Take the instance explicitly and unfold with a `rfl`-proved
   local `have`, as `unrollOf_mem_or_default` does.
3. **`Quotient.inductionOn` must come before destructuring** a `RelZ` hypothesis about a
   quantified state. `rintro ⟨C', ⟨_, _⟩, _⟩` fails ("not an inductive datatype"); introduce
   `C'`, `revert` the hypotheses, induct, then `rintro`.
4. **`subst` on `C = S.cls i (S.time C)`** fails (`C` occurs on the right). Induct on the
   quotient and `obtain ⟨i, u⟩ := p` instead.
5. The style linter rejects a `show` that changes the goal — use `change`.
6. Build every module through `bash .claude/scripts/lake-build-guard.sh build --timeout 900 --
   build <Module>`, detached via `run_in_background: true`. Foreground builds livelock.

## Phase 7 starting notes

The three one-position/one-step conditions to decide are (C0) `AtomCoherent`, (C1')
`LocalCoherentShare` and — once (C5) is resolved — `StabFaithful`. `decidableShare` and
`decidableReachN` already exist, and `Fin S.lassos.length` is a `Fintype`, so the inner
`∀ j`/`∃ j` quantifiers are decidable; what remains is the periodic-window reduction over `t`,
against `Decide.lean`'s existing window lemmas, widened by the `share` period
(`nbr`/`nmr`/`nfr` on `Sharing/Basic.lean`).
