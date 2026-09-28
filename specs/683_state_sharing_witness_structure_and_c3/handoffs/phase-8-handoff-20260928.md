# Phase 8 Handoff — Task 683

## Immediate next action

Resume at **Phase 9** (`ThreadFulfilling` and the correctness of the Phase 8 fixpoint against
it). Read "Phase 9 design, worked out" below before writing anything: the design was carried
far enough in this dispatch to identify one genuinely hard sub-problem, and the route through
it is recorded here so the next dispatch does not re-derive it.

## State

| Phase | Marker | Notes |
|---|---|---|
| 1-5 | `[COMPLETED]` | `Sharing/Basic.lean`, `Thread.lean`, `Frame.lean`, `Histories.lean` |
| 6 | `[COMPLETED WITH EXCLUSIONS]` | `Sharing/Predicates.lean`; (C5) excluded by user decision |
| 7 | `[COMPLETED]` | `Sharing/Decide.lean` — the combined window, (C0)/(C1') decidable |
| 8 | `[COMPLETED]` | `Sharing/Fulfil.lean` — the position graph and the `A[g U e]` fixpoint |
| 9-14 | `[NOT STARTED]` | |

Full `lake build` green (2748 jobs, exit 0). Sorry count 0. Axiom count 14, unchanged from the
dispatch's baseline. `#print axioms` on every new declaration reports exactly
`[propext, Classical.choice, Quot.sound]`. `git diff` on `Semantics/ShiftSet.lean` and on all
five deterministic `WitnessFamily/*.lean` modules is empty.

## What Phase 9 inherits

### From `Sharing/Decide.lean` (Phase 7)

- `perBack = |repBack| · ∏ᵢ |backᵢ|`, `perFwd = |repFwd| · ∏ᵢ |fwdᵢ|`,
  `perMid = |repMid| + Σᵢ |midᵢ|`, with `NB`/`NF`/`NM` their integer casts;
  `NB_pos`, `NF_pos`, `NM_nonneg`, `nbr_dvd_NB`, `nfr_dvd_NF`, `nmr_le_NM`,
  `lasso_nb_dvd_NB`, `lasso_nf_dvd_NF`, `lasso_nm_le_NM`.
- `emod_of_dvd` (equal residues descend to a divisor), `get_mem`, `le_sum_of_mem`.
- `Periodic.unrollOf_congr_back` / `unrollOf_congr_fwd` — generic, with the `Inhabited`
  argument explicit; `rep_congr_back` / `rep_congr_fwd` are their instantiations.
- **`data_congr_back` / `data_congr_fwd`** — the workhorses. At two times congruent modulo the
  combined period, the representative map *and every lasso's label* agree.
- `cohWindowLo = -2·NB`, `cohWindowHi = NM + 2·NF`, and **`exists_window_repr`**: every `t` has
  a window representative `t'` with `rep t = rep t'`, `rep (t+1) = rep (t'+1)` and label
  agreement at `t-1`, `t`, `t+1`.
- `atomClauseAt`, `atomCoherentData`, `AtomCoherentAt`, `atomCoherent_iff_at`,
  `atomCoherentAt_congr`, `atomCoherent_iff_window`, `decidableAtomCoherent`.
- `shareClauseAt`, `coherentShareData`, `CoherentShareAt`, `localCoherentShare_iff_at`,
  `coherentShareAt_congr`, `localCoherentShare_iff_window`, `decidableLocalCoherentShare`.

### From `Sharing/Fulfil.lean` (Phase 8)

- `AUFix.step` / `step_mono` / `iter` / `iter_subset` / `iter_succ_mono` / `iter_mono` /
  `iter_stab` / `exists_stab` / `lfp` / `lfp_subset` / `lfp_fixed` / `lfp_least` /
  **`mem_lfp_iff`** / **`lfp_induction`**, all at an arbitrary vertex type and successor
  function.
- `Pos = Fin |lassos| × ℤ`, `winTimes`, `verts`, `mem_verts`.
- `nextTime` / `prevTime` with `nextTime_edge`, `prevTime_edge`, `nextTime_mem`, `prevTime_mem`,
  and the four data-preservation lemmas **`rep_nextTime`, `L_nextTime`, `rep_prevTime`,
  `L_prevTime`**.
- `succF` / `predF` with `mem_succF`, `mem_predF`, `succF_subset`, `predF_subset`,
  `succF_nonempty`, `predF_nonempty` (no dead ends — `share_refl` always continues a walk).
- `atPos`, `atPos_iff`, `untlFix`, `snceFix`, `untlFix_subset`, `snceFix_subset`,
  **`mem_untlFix_iff`**, **`mem_snceFix_iff`**, **`untlFix_induction`**, **`snceFix_induction`**.
- A `SmokeTest` section whose three `#guard`s pin the computed answers on a one-lasso family.

## Phase 9 design, worked out

### The fold invariant (needed to read a graph walk as a ℤ-walk)

`fold`-equality of data is **not** stable under `+1` at the window boundaries, so the naive
induction "data at the graph's `k`-th time equals data at `u + k`" does not go through. The
invariant that does is

```
FoldRel t t'  :=  t = t'  ∨  (NM ≤ t ∧ NM ≤ t' ∧ (t - NM) % NF = (t' - NM) % NF)
```

and it **is** preserved by `(nextTime, +1)`:

* first disjunct, no wrap: `nextTime t = t + 1 = t' + 1`, first disjunct again;
* first disjunct, wrap: `nextTime_edge` gives `t = NM + 2·NF - 1`, so `nextTime t = NM + NF` and
  `t' + 1 = NM + 2·NF`; both are `≥ NM` and congruent mod `NF`, second disjunct;
* second disjunct, no wrap: add `1` to both sides, still `≥ NM`, still congruent;
* second disjunct, wrap: `nextTime t = NM + NF ≡ t + 1` mod `NF`, and `t + 1 ≡ t' + 1`.

`data_congr_fwd` then gives `rep t = rep t'` and `L i t = L i t'` in the second disjunct, so the
whole data agrees along the walk. The `prevTime` mirror uses the dual relation with `< 0` and
`% NB`, and `data_congr_back`.

### Completeness (a vertex outside the fixpoint admits a counterexample thread)

`lfp_fixed` turns `v ∉ untlFix g e` (with `v ∈ verts`) into: there is `w ∈ succF v` with
`e ∉ L w` and (`g ∉ L w` or `w ∉ untlFix g e`). Iterating by choice gives either a finite walk
ending at a position carrying neither the event nor the guard, or an infinite walk staying
outside the fixpoint with the guard throughout and the event never. Both are counterexamples.
Lifting to a bi-infinite `Thread` is unproblematic: forward use the walk (transported along
`FoldRel`), backward use `step_refl` to stay on the same index. `succF_nonempty` is what
guarantees the walk can always be continued.

### The hard sub-problem, and the route through it

**The problem.** `ThreadFulfilling` quantifies over all `u : ℤ`, including `u < cohWindowLo`.
Folding a far-left position into the window is *not* obviously obligation-preserving for a
**universal** path quantifier: the real forward ray from `u ≪ -2·NB` winds around the backward
cycle several extra times before reaching the origin, and a walk's guard obligations over that
longer prefix are not the representative's. This is the branching analogue of
`WitnessFamily/Decide.lean`'s `untlObl_shift_back`, whose own proof works only because the
obligation there is **existential**: when the witness lies at or beyond the origin, the guard
is known across a complete residue system and `mem_all_neg_of_period` spreads it over the whole
negative region. That argument does not transpose directly.

**The route.** Use (C1') propagation. If `untl g e ∈ L i t` and `LocalCoherentShare` holds, then
along *any* walk from `(i, t)`, at each step either `e` is delivered or both `g` and
`untl g e` hold at the successor. So the only possible counterexample walk is "guard forever,
event never", and its guard obligations over the extra backward-cycle prefix are automatically
satisfied. The far-left shift then reduces to the representative's own failure.

**The consequence for the plan, to raise rather than pre-empt.** That route makes the window
reduction depend on `LocalCoherentShare`, so the natural statement is

```
LocalCoherentShare S → (ThreadFulfilling S ↔ <window/fixpoint check>)
```

rather than a standalone `Decidable (ThreadFulfilling S)` instance. Phase 9's fourth task and
its first Verification bullet both ask for the standalone instance
(`example (S) : Decidable (ThreadFulfilling S) := inferInstance`). If the unconditional
reduction cannot be closed, that is a **plan deviation on a `.lean` file** and
`.claude/rules/plan-compliance.md` requires marking Phase 9 `[BLOCKED]` and raising it, not
silently restating the deliverable. Two options to put to the user at that point:

1. Keep `Decidable (ThreadFulfilling S)` and find the unconditional far-left argument (the true
   branching analogue of `untlObl_shift_back`).
2. Weaken the deliverable to the coherence-relative equivalence above and decide the *bundle*
   `Certifies` instead, which is the only place the conjunction is ever consumed. `Certifies`
   already carries `LocalCoherentShare`, so nothing downstream loses anything — but Phase 11's
   `decidableCertifies` twin would then be assembled differently from the deterministic one.

Do not assume option 2 without asking; the unconditional version may well close.

## Traps, in addition to the six in the Phase 6 handoff

7. **`Int.natCast_le` does not exist here.** Use `exact_mod_cast` for `ℕ → ℤ` order facts.
   `Int.natCast_pos`, `Int.natCast_dvd_natCast`, `Int.natCast_nonneg` and
   `Int.emod_emod_of_dvd` all do exist and were used.
8. **`List.single_le_sum` and `Finset.not_mem_empty` do not exist here.** A three-line induction
   (`le_sum_of_mem` in `Sharing/Decide.lean`) replaces the first; `by simp` replaces the second.
9. **`emod_shift` and `reduce_emod` live in `LabelledLasso`**, not at the file's top level, so
   from `SharingWitnessFamily` they are `LabelledLasso.emod_shift`.
10. **`push_neg` is deprecated** in this toolchain; use `push Not at h`.
11. **`#guard` trips `linter.hashCommand`.** Precede each with
    `set_option linter.hashCommand false in`, as `WitnessFamily/Examples.lean` does.
12. **The style linter still rejects a goal-changing `show`** (Phase 6 trap 5) — it fired again
    in `AUFix.lfp_fixed`. Use `change`.
