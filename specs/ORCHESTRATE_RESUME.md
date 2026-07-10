# Resume brief — orchestrate 337,335,321,341,309,333

Session `sess_1783639750_29c89e`. Halted after Wave 1 at user direction.
HEAD at halt: `f09c77bde`. Build green (1720 jobs). No locks held. Nothing half-edited.

Delete this file once the cluster is re-planned.

## Where the batch stands

| Task | Status | Note |
|------|--------|------|
| 337 | **completed** | Both deliverables landed, axiom-clean |
| 335 | partial (2/5) | Completeness half landed; Phases 3–5 hard-blocked |
| 321 | partial | Not dispatched |
| 341 | not_started | Not dispatched; must run LAST (refactor) |
| 309 | blocked | Not dispatched |
| 333 | partial | Not dispatched; **is the actual unblocker** |

## The blocker: a real dependency cycle

Task 335 Phases 3–5 need `kvE2_sepValid` / `kvE2_sepArrL` / `kvE2_sepArrR` redefined.
That redefinition **is** task 333's whole scope. But `dependencies[]` declares:

```
333 -> 321 -> 335        and in substance      335 -> 333
```

The edge `335 -> 333` was never declared, so the batch validated as a clean 4-wave DAG.
Kahn's algorithm cannot see an edge that isn't there.

Root obstruction, landed and machine-checked: the multi-owner soundness `hgate`
forward-zone conjunct (`SubBracket2V.lean:1873-1877`) at a cross-σ slot point is
underdetermined by the faithful carrier's realized content. Five recorded failed closers
= channel exhaustion. See the **O4 CRUX RECORD**, `SharedWitness.lean:6566-6659`.

### Suggested corrected order

`333` (carrier redefinition) → `335` Phases 3–5 → `321` → `309` → `341` (refactor, last).

333's declared dependency on 321 looks wrong: it needs 321's *findings*, which are already
landed in-source as the O4 CRUX RECORD — not 321's completion.

## Before dispatching 333: re-plan it

333's description is **stale**. It promises to discharge two strategic sorries by name:

- `kvE2_sepSingleton_coverage_left:1796` — **does not exist** (0 grep hits)
- `kvE2_sepBody_singleton_complete_left:1952` — **does not exist** (0 grep hits)

`SharedWitness.lean` has **0 real sorries**; all 7 occurrences are prose comments. The
task-340/342 redesign superseded both. Re-plan against current source first — task 337
needed two plan revisions for exactly this failure mode, and 335's revision caught a bad
line number plus an already-landed phase.

## What task 337 delivered (verified, not just reported)

- `kvE2_sepDisjunct'_holds_of_honest` (`SharedWitness.lean:9240`)
- `kvE2_sepBody_holds_of_honest` (`SharedWitness.lean:9262`) — what 335 consumes

Both public, sorry-free, axioms exactly `{propext, Classical.choice, Quot.sound}`.
Purely additive after the authorized fix (250 + 432 + 522 insertions, 0 deletions).

**Faithfulness fix landed** (report 13): the `.rXW` slot-value ε-predicate was a
byte-identical copy of `.lXU`, carrying the left-interior upper bound `anchorVal` where the
pivot `w` was required. The `v < w` bound was present in zone `kvE_sub2_zXU`
(`SubBracket2.lean:123`, coord-1 `(true,false)`) but discarded by `kvE_sub2_zoneHolds_zXU`'s
`⟨hp0, _, hp2, _⟩`. Restored at 3 sites. Task 342's theorems re-verified clean afterwards —
the fix was a restoration, not a patch.

**Tie-class semantics disambiguated** (report 14): three distinct rank keys, previously
conflated —
- `kvE2_sepSlotGIdx` (SW:1920) — carrier-level, tie-**admitting**, what the grouping uses
- `kvE2_sepSlotHonestGIdx` (SW:3807) — model-level, **injective** (`_injOn`)
- `kvE2_sepSlotHonestVIdx` (SW:5831) — value-only, ties **collapse**

The `(A)↔(C)` bridge `kvE2_sepSlotGIdx_honestOrder'` (SW:7868) already existed.

## Traps — carry these into every future dispatch

1. **Vacuous close.** `kvE2_sepHonest_hLR_absurd` (`SharedWitness.lean:5738`) proves an
   unsatisfiable hypothesis package exists in this file. Closing any goal through it (or
   `False.elim`) typechecks, builds green, and proves **nothing**. Grep for it.
2. **Wrong order.** Only the PRIMED `kvE2_sepHonestOrder'` (SW:5974) is correct.
   `kvE2_sepModelOrder` (SW:1476) and the unprimed `kvE2_sepHonestOrder` (SW:3891) carry
   injective payloads that force singleton tie classes and make grouped obligations FALSE
   under genuine ties. A proof against them is unsound-by-construction *and compiles*.
3. **`hLR` is deleted.** Any phase reintroducing an interiority hypothesis on realized types
   is wrong by construction.

## Tooling / infra defects found

- **`lean_verify` (MCP) is unreliable on `SharedWitness.lean`** — returns contradictory
  `sorryAx` from stale LSP state after an external `lake build`. Use
  `#print axioms <fully.qualified.name>` via `lake env lean`. Trust a fresh `lake build`
  over LSP diagnostics.
- **`state.json` has duplicate `project_number` entries: 290 and 300** (92 entries, 90
  unique). This breaks `generate-todo.sh:243` (`jq` returns two values where one is
  expected). Left untouched — you decide which copy is authoritative.
- **Task-lock release leaks.** Six stale locks were found at session start (327, 330, 331,
  334, 342 on completed tasks; 337 from a `/plan` run that committed and exited). Cleared.
  The release step is not running on exit.
- **Subagent handoff compliance is unreliable.** One dispatch wrote `task`,
  `phases_completed`, `phases_total`, `sorry_count` all `null`; another *claimed* to write a
  handoff it never wrote and listed it as an artifact. Both caught only by checking the file
  on disk. The orchestrator reads **nothing else** — verify, don't trust.

## Known out-of-scope debt

`KampPrior.lean` has 2 real sorries (lines 351, 354). Wiring the gate into `KampPrior:351`
(threading `ExistProviders` through `nf_nvar_exist_all_depths`'s `Nat.rec`/`n=1` case) is
scope item **R-B**, a distinct downstream task. See the scope docstring at the top of
`NfMultiAnchorBridge/OuterGate.lean`.

## Uncommitted, pre-existing (not from this session)

- `specs/340_.../plans/03_perslot-individual-slot-refinement.md` (modified)
- `specs/340_.../working-progress-1783582863.patch` (untracked)

## Artifacts worth reading first

- `specs/337_.../reports/13_rxw-faithfulness-audit.md` — the `.rXW` verdict
- `specs/337_.../reports/14_tie-class-semantics-audit.md` — the three rank keys
- `specs/335_.../handoffs/phase-3-handoff-20260710T0315Z.md` — grounded soundness blocker
- `specs/.orchestrator-multi-state.json`, `specs/.return-meta-multi.json` — machine state
