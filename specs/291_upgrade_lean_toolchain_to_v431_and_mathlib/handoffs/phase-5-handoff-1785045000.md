# Handoff — Phase 5 partial (third implementation dispatch)

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Session**: `sess_1784959849_77d9d9`
- **HEAD at handoff**: `ac3aaab72`
- **Tree state**: clean except `specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`, which
  were already modified before this dispatch and are not mine to stage.

## Where things stand

| Measure | Start of dispatch | End of dispatch |
|---|---|---|
| `Theories/` modules elaborating | 326 / 430 | **373 / 430** |
| Modules blocked behind a failure | 104 | **57** |
| `lake build` errors | 39, in 7 files | **5, in 1 file** |
| Files with errors | 7 | **1** (`Kamp/ExteriorNegation.lean`) |
| New `sorry` | 0 | **0** (`git diff` of `Theories/` vs the Phase 2 pin commit adds none) |
| New axioms | 0 | **0** |
| `backward.*` options | 0 | **0** |
| Source files repaired this dispatch | — | 19 |
| `(deterministic) timeout` errors seen | unmeasured | **0** |

**Read the error count with the same caveat as before**, but note it now points the other way:
the count fell 39 -> 5 *while* 47 more modules elaborated, so both signals agree for the first
time in this task. The waves in between went 39 -> 59 -> 15 -> 4 -> 13 -> 48 -> 46 -> 7 -> 5;
every rise was a newly-reached module, never a regression.

**Metric correction — the earlier handoffs' "modules elaborated N / 1877" figures were wrong.**
1877 is lake's *job* counter for the whole build graph, and the `[N/1877]` marker records where
the scheduler happened to stop, not how much elaborated; it read `1837/1877` both at 46 errors
and at 5. `Theories/` contains **430** modules. The defensible measure is
`430 - (failing + transitive dependents)`, computed from the import graph:

```bash
# failing modules -> blocked closure -> elaborated count
python3 - <<'EOF'
import os, re, collections
mods = {}
for dp, _, fns in os.walk('Theories'):
    for fn in fns:
        if fn.endswith('.lean'):
            p = os.path.join(dp, fn)
            name = 'Bimodal' + p[len('Theories/Bimodal'):-5].replace('/', '.')
            mods[name] = [i for i in re.findall(r'^import\s+(\S+)', open(p).read(), re.M)
                          if i.startswith('Bimodal')]
rev = collections.defaultdict(list)
for m, ims in mods.items():
    for i in ims:
        rev[i].append(m)
seen = set(FAILING); stack = list(FAILING)          # FAILING = list of failing module names
while stack:
    for d in rev.get(stack.pop(), []):
        if d not in seen:
            seen.add(d); stack.append(d)
print(len(mods) - len(seen), '/', len(mods))
EOF
```

Use this, not the `[N/1877]` marker, for every future progress report on this task.

**Phase 6 is now measurable and it reads clean.** `SharedWitness.lean` (12,800 lines),
`SubBracket2V`, `SplitPoint` and the rest of the heartbeat-sensitive set all elaborated with
**zero** `(deterministic) timeout` errors and no `maxHeartbeats` change. The plan's biggest
projected cost risk did not materialise. Confirm with a final full build once Phase 5 closes,
then Phase 6 can be closed as a no-op with that evidence recorded.

## Immediate next action

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` — 5 errors, one root cause,
and **the fix is already identified**. Do not re-derive it.

The five errors are at `:935`, `:951`, `:961`, `:972` (all `unsolved goals` on a
`zs ∈ kvE2_futPossibleZones` membership) and `:1707` (`rcases` "not a free variable" after a
`simp only … at hzp` that only unfolded one `List.mem_cons` level).

The diagnostic that pins it down comes from running
`simp only [kvE2_futPossibleZones]; simp only [List.mem_cons]` at `:948`:

```
`simp` made no progress
Note: The target expression is not type-correct under the `implicit` transparency level …
Full error:
  Application type mismatch: The argument kvE2_sep_zPastX3
  has type ZoneSpec 3 but is expected to have type Fin 3 → Bool × Bool
  in the application Fin.cons (true, false) kvE2_sep_zPastX3
```

So the **list literal `kvE2_futPossibleZones` is itself not type-correct at `implicit`
transparency**: `Fin.cons`'s implicit motive is solved as `fun _ => Bool × Bool`, so the second
argument's expected type is `Fin 3 → Bool × Bool` while `kvE2_sep_zPastX3 : ZoneSpec 3`. Every
`simp`/`rcases` step that has to traverse this list stalls.

**The fix is the `orderedSumPt` pattern (inventory rows N7/N8), applied to `Fin.cons` at
`ZoneSpec`.** Add next to `ZoneSpec` in `Kamp/NfEFold.lean`:

```lean
/-- `Fin.cons` at the `ZoneSpec` type: both the argument and the result type are declared as
    `ZoneSpec`, so the term is type-correct at `implicit`/`reducible` transparency. A bare
    `Fin.cons p zs` is not — see the note on `ZoneSpec`. -/
def zoneCons {n : Nat} (p : Bool × Bool) (zs : ZoneSpec n) : ZoneSpec (n + 1) := Fin.cons p zs

@[simp] theorem zoneCons_eq {n : Nat} (p : Bool × Bool) (zs : ZoneSpec n) :
    zoneCons p zs = Fin.cons p zs := rfl
```

Then replace `Fin.cons` with `zoneCons` at the `ZoneSpec` sites in `ExteriorNegation.lean`:
`kvE2_futPossibleZones` (9 entries), `kvE2_futSpikeZoneBit`'s eight `if zs = …` conditions (they
currently carry a `show ZoneSpec 4 from` ascription that works — `zoneCons` supersedes it), and
the goal-side occurrences produced by `rw [← Fin.cons_self_tail zs, hzeq0]` around `:945`, which
is what `zoneCons_eq` is for.

**Verified while narrowing this** (do not redo):
- `show ZoneSpec 4 from Fin.cons …` **does** fix `Decidable` synthesis on `if zs = …` (that is
  why `kvE2_futSpikeZoneBit`'s eight conditions now compile). It does **not** fix the list
  traversal, because there the problem is the *argument* type, not the result type. A named
  helper fixes both; the ascription fixes only one.
- Putting `show ZoneSpec 4 from` on the *list entries* was tried and reverted: it changes nothing
  (the ascription is not a term) and it desynchronises the entries from the bare `Fin.cons` the
  goal side produces.
- A parenthesised `(e : T)` ascription is never sufficient anywhere in this family; only
  `show T from e` propagates far enough.

## Repair patterns from this dispatch (all reusable, all in the inventory as N7-N15)

1. **Projection at the unfolded type** (N7) — `qnf.1` elaborates as
   `@Prod.fst (AtomKind sig n → Bool) _ qnf`, so `Decidable` search and `rw` motive construction
   both reject it. Fix with `show NormalForm sig 0 n from qnf.1`, or go term-level
   (`(lemma …).mp h` instead of `rw [lemma] at h`).
2. **`of_decide_eq_true` / `decide_eq_false` take `p` from the *expected type*** — so
   `exact of_decide_eq_true h` re-introduces the bad goal. Bind through
   `have h' : <ascribed type> := of_decide_eq_true h` (or plain `have h' := …` when the
   hypothesis carries the good instance) and then `exact h'`.
3. **`split_ifs` silently half-applies** (N8) when the motive is not type-correct at `implicit`
   transparency: it introduces the named hypotheses but does not substitute the `dite`. The
   cascade (`unknown identifier hyb`, a negated hypothesis in the wrong branch, "No goals to be
   solved") looks like name drift and is not. Fix the underlying type, not the name list.
4. **`simpa only [Fin.cons, …] using h` -> `exact h`** (N14) — 40+ sites. Fully mechanical; the
   error signature is `Type mismatch: After simplification, term h has type X but is expected to
   have type Y` where `Y` is `X` with `Fin.cases`/`Fin.cons` left unreduced.
5. **`simp` leaves `X = X`** (N10) — append `rfl`.
6. **A failed instance poisons `decide` far away** (N15) — a stuck `decide` whose message ends
   `reduction got stuck at the Decidable instance sorry` is a *cascade*. Look for a failed
   instance declaration earlier in the file before investigating the `decide`.

## The `@[reducible]` decision, generalised

`@[reducible]` on `extendedStructure` / `extendedStructureWithMu` cleared **48 errors in
`StaviCompleteness.lean` in one change** with no regression anywhere. The rule that distinguishes
it from the rejected `orderedSum` case:

> `@[reducible]` on a structure-instance def is safe iff, for every class whose instance the
> structure carries as a field, the unfolded carrier admits **no instance other than the one the
> field supplies**.

For `extendedStructure*`: `.carrier` unfolds only to the still-semireducible `ExtendedCarrier`,
whose sole registered order instance (`extendedLinearOrder`) is exactly `carrier_order`. For
`orderedSum`: `.carrier` unfolded to a raw `Sigma`, where Mathlib's `Sigma.preorder` outranked
the local order — a silently different order. Both rationales are recorded in docstrings on the
definitions themselves.

**`NormalForm` was NOT marked reducible.** The prior handoff flagged it as the untried lever; it
turned out to be unnecessary — every `NormalForm`-related failure yielded to the `show … from`
and term-level repairs above, at far lower blast radius. Leave it semireducible.

## Do not relitigate

Everything in `handoffs/phase-4-handoff-1784965800.md` and
`handoffs/phase-5-handoff-1784999000.md` still stands, plus:

- `@[reducible]` on `orderedSum` — still rejected, for the reason above.
- `@[reducible]` on `extendedStructure` / `extendedStructureWithMu` — **accepted and landed**.
- `@[reducible]` on `NormalForm` — **not needed**; do not apply it.
- `List.Chain'` -> `List.IsChain` rename is done in both files that used it. Note the non-obvious
  mapping: old `chain'_cons'` -> new `isChain_cons`, old `chain'_cons` -> new `isChain_cons_cons`.
- `show ZoneSpec 4 from` on `kvE2_futSpikeZoneBit`'s `if` conditions is load-bearing — keep it
  (or supersede it with `zoneCons`, but do not simply delete it).

## Verification commands

```bash
lake build                                                   # full; frontier at 1873/1877
lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegation   # scoped, ~2.5s
grep -c 'deterministic) timeout' <build.log>                 # Phase 6 gate; currently 0
git diff 29b9cea6f -- Theories/ | grep '^+' | grep -c sorry  # zero-debt gate; currently 0
bash baseline/compare-exes.sh baseline/exe <new-capture>      # Phase 8 gate
```

## Phase status

- Phases 1-4: `[COMPLETED]`.
- Phase 5: `[PARTIAL]` — 5 errors in 1 file, root cause identified and fix specified above.
- Phase 6: `[IN PROGRESS]` but effectively measured — **zero timeouts** across the whole corpus
  including the four files the plan named as the heaviest. Close it as a no-op once the build is
  green, recording the measurement.
- Phases 7-10: `[NOT STARTED]`. Phase 7's residue is now just the `ExteriorNegation.lean` cluster.
