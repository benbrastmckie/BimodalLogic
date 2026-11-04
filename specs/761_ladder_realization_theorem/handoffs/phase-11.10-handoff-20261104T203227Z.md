# Phase 11.10 Handoff — The Idle-Past Interface Decision Probe

- **Task**: 761
- **Phase**: 11.10 (Plan v11, `plans/11_idle-insertion-cascade-restatement.md`)
- **Dispatch**: `dispatch_seq` 33, session `sess_1793823065_4dcf25`
- **Phase marker at close**: `[COMPLETED]`

## Immediate next action

Phase 11.11 is OPEN. Its worked example at a single instance now exists on disk:
`specs/evidence/seam-gluing-ray-product/ladder-idle-past-interface-decision.lean` carries `wW`,
`cW`, `cW_of_idle`, `cW_pend_pend`, `cW_pend_idle`, `pinW_eq` and `cW_pin` — the insertion walk,
its countdown, its four local ladder conditions and its pin arithmetic — all at the single
instance `(s, a, v, l, p) = (2, 3, 3, 1, 2)` on the tight doubling chain. Phase 11.11's job is to
generalise that shape into a library-level primitive; Phases 11.12 and 11.13 follow in their
recorded order.

## Verdict

**WITNESSED.** The restated interface-level existential
`exists_ladderPath_at_region_of_idle_past` is **NOT refuted** on the one compiled object that
refutes the `spliceObj`-shaped conclusion.

`idle_past_interface_witnessed` exhibits a ladder path `gW` over `(stepC, pendC)` with
`objAt gW 3 = objAt tightChain 3` and `cntAt gW 3 = cntAt tightChain 3 + 1` (that is, `3 = 2 + 1`).
`exists_ladderPath_at_region_on_tightChain_instance` restates it in existential shape AT THE
INSTANCE, not under the unlanded declaration's name.

## Current proof state

Nothing is open. Every declaration of the probe compiles; `#print axioms` on each headline reports
a subset of `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no custom axiom, no
`native_decide`, no raised `maxRecDepth`/`maxHeartbeats`.

## Key decisions

1. **A probe cannot import another probe** — READ, not assumed. `check_probe` in
   `scripts/check-evidence-probes.sh` invokes `lake env lean` on a file outside the Lake module
   graph, so the chain's objects (`idleT`, `wT`, `cT`, `pin_eq`, `cT_pin_succ`, `cT_pend_pend`,
   `cT_pend_idle`, `tightChain_exists`, `tightChain`, `tightChain_objAt`, `tightChain_cntAt`) are
   RE-DERIVED verbatim inside the new probe's own namespace `Probe761IdlePast`.
   `ladder-tight-chain-nonliftability.lean` is byte-identical and was never opened for writing.

2. **The witness is the CASCADE walk, and it needs BOTH moves.** The phase's own task line named
   only the insertion; the insertion alone moves no countdown at the comparison position, because
   it lengthens an idle run BELOW that position while the countdown there reads the distance to the
   next idle position ABOVE. The witness therefore carries the region lengthening (`3, 4, 5` →
   `3, 4, 5, 6`, with the chain's idle positions `2 ^ j - 2` for `j ≥ 3` displaced up to
   `2 ^ j - 1`) AND the insertion at the witness `p = 2` with the past strictly below pushed down
   by `1`. The first raises the countdown; the second restores pin compatibility.

3. **The pin arithmetic has a closed form, and that is why the proof is cheap.** The cascade walk
   `wW` is idle exactly at `x ≤ -1`, at `1`, at `2`, and at `2 ^ j - 1` for `j ≥ 3`; its pins are
   `-1`, `2` and `2 ^ j - 1`. `cW_pin` states the region-start countdown as `s + 1` at the two low
   pins and `s - 1` at every high one, which collapses `hpinsW` (pairwise compatibility) and `hn0W`
   (base register `n₀ = 1`) to a four-case `omega` each.

4. **The chain makes the pending-forever half VACUOUS.** It is idle at every `v ≤ 0`, so no
   position of it has a pending-forever past at all. The landed
   `exists_ladderPath_at_region_of_pend_past` cannot be applied here; the idle-past half is the
   only half this object exercises. That is what makes the chain the right decision object rather
   than merely an admissible one.

5. **Why the splice fails and the cascade does not**, in one line of arithmetic:
   `spliceObj tightChain 3 1` raises the region start `2` to countdown `3` while leaving the pin at
   `0` below it with countdown `0`, and `|3 - 0| = 3 > |2 - 0| = 2` violates the pairwise condition
   `pinCompat_of_ladderPath` proves NECESSARY for any ladder path whatsoever.

## Non-generality (carry this forward verbatim)

`Qc := Fin 2` with `stepC : Qc → Qc → Bool := fun _ _ => true` is TOTAL, so
`exists_ladderPath_of_walk`'s `hw` discharges by `rfl` and the witness pays NONE of the self-loop
cost the general statement pays. **This probe decides REFUTABILITY and never PROVABILITY.** A
positive answer here is not a proof of `exists_ladderPath_at_region_of_idle_past` and is not a step
toward one. Nothing is landed under `exists_ladderPath_at_region_of_idle_past`,
`exists_ladderPath_at_region` or `exists_spliced_ladderPath_of_idle_past`, in the library or in the
probe.

## Deviations

- **The REFUTED branch was not reached**, and is FORECLOSED on this instance rather than merely
  unattempted: a compiled witness and a compiled refutation of the same existential cannot both
  exist. Annotated inline on the corresponding checklist item.
- **The insertion-only recipe in the WITNESSED task line was corrected**, not worked around — see
  key decision 2. Annotated inline on that checklist item.
- **`hw` discharges by `rfl`, not `decide`** as the task line anticipated: `stepC` is literally
  `fun _ _ => true`.

## Measurement correction (not a deviation of this phase's work)

The phase's Verification list carried the baseline `the ^axiom counts are 10 and 2`. Measured at
close: `grep -rn '^axiom ' FormalSystem` is **12**, `Tests` is **2**, and
`git grep -c '^axiom ' HEAD` over the same two roots returns the SAME 12 and 2. UNCHANGED by this
phase, which touches no file under `FormalSystem/` or `Tests/` at all; the recorded `10` was stale
when plan v11 was authored. The criterion's intent — no new axiom — is met. The vacuous-definition
grep is 1, exactly the recorded baseline.

## Verification at close

| Item | Result |
|------|--------|
| Probe compiles standalone through the build guard | exit 0, 0 warnings |
| `#print axioms` on every headline | subset of `[propext, Classical.choice, Quot.sound]` |
| `ladder-tight-chain-nonliftability.lean` unmodified | `git status --short` empty on that path |
| Instance non-vacuous | `instance_is_in_regime`, all eight clauses compiled as facts |
| Non-generality sentence present | own `## NON-GENERALITY` section + both headlines + gate table |
| No library module touched | `git diff --stat HEAD -- FormalSystem Tests BimodalTools` empty |
| Three unclaimed names stay unclaimed | grep returns docstring prose only |
| `bash scripts/check-evidence-probes.sh` | `PASS  all 50 wired probe(s) compile`, exit 0 (delta +1 against 49) |
| `bash .claude/scripts/lean-sorry-census.sh` | exit 0, `sorry_count: 0` |
| Vacuous grep / axiom counts | 1 (unchanged) / 12 and 2 (unchanged vs `HEAD`) |
| `bash .claude/scripts/check-task-references.sh --quiet` | exit 0 |
| Full-project `lake build` through the guard | exit 0, `Build completed successfully (2895 jobs)`, 0 `error:` |

## Plan-revision sentinel

`.plan-revised.json` carries `revised_at: 1793822703`, which PRECEDES this dispatch's
`dispatch_start_ts: 1793823203`. No fresh revision landed mid-phase; the Phase 11.10 section was
re-read directly from plan v11 before the first edit.
