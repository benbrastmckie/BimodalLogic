# Phase 23 — Frame-relative validity `⊨_F` (`def:frame-validity`)

- **Task**: 414 — refactor semantics to total-history validity
- **Phase**: 23 (OPTIONAL), the plan's final owed phase
- **Dispatch**: `dispatch_seq` 4, session `sess_1786573183_94ad61`
- **Plan**: `plans/04_seriality-witness-termination-fix.md`
- **Status**: `[COMPLETED]` — plan reaches 31/31
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

## What this phase was, and why it took four dispatches

Charter §8's optional deliverable: `def:frame-validity`'s `⊨_F` had no Lean counterpart at all.
The Lean work itself is small — one definition and four short theorems, no induction, green on the
first build. What held it up twice was a **precondition**, not the content.

Phase 23 consumes two paper anchors (`def:frame-validity`, `cor:occurrence`) and is therefore
gated on `bash scripts/check-paper-definitions.sh`. Across dispatches 1 and 2 that gate failed
case (c) against a live paper-side drift wave — first 1 drifted anchor, then 3, plus three newly
introduced anchors the record did not track at all. Both blocked dispatches declined to narrow the
gate to "anchors this phase happens to consume", even though **both had already verified that this
phase's own two anchors were unchanged**. That was the right call: the record's provenance pin is
whole-file, so absorbing one anchor of a three-anchor wave would have re-pinned the record to a
state whose other quoted anchors were stale — a record asserting a clean pin it did not have.

The blocker was cleared by commit `5de357c70`, which absorbed all three drifted anchors together
and re-pinned `FILE_CHECKSUM` + `LINE_COUNT` once. This dispatch re-ran the gate first, before
consuming any definition, and got **exit 0, case (a)** (silent pass; whole-file checksum equals the
pin). The two consumed anchors were confirmed at their pinned hashes for the third independent
time: `def:frame-validity` = `2bcc85b0…`, `cor:occurrence` = `b0228712…`.

## What landed

All in `FormalSystem/Semantics/Validity.lean`, in a new section after `end Validity`.

| Declaration | Content |
|---|---|
| `TaskFrame.ValidOn` | `def:frame-validity` on the nose: `∀ (M : TaskModel F) (τ : F.HF) (x : D), TruthAt M τ.val x φ` |
| `TaskFrame.not_validOn_bot` | Never-vacuity: `¬ F.ValidOn ⊥`, hypothesis-parameterized on the frame axioms |
| `TaskFrame.hF_nonempty_of_frameAxioms` | `cor:occurrence`'s closing clause (`H_F ≠ ∅`), restated adjacent to what it justifies |
| `Validity.valid_iff_forall_validOn` | `valid φ ↔ ∀ D F, F.ValidOn φ` |
| `Validity.validOn_of_valid` | Forward half in usable form |

One import added (`FormalSystem.Semantics.Extension.Extension`, for `PartialHistory.occurrence`).
No import cycle: the extension chain does not import `Validity`.

### Three encoding decisions worth recording

**Bundled `F.HF`, not the predicate form.** `WorldHistory.lean`'s Decision-A encoding note draws
the line: the bundled subtype is used where `H_F` appears as an object in its own right, the
predicate form `(τ : WorldHistory F) (hτ : τ.IsTotal)` where totality is a hypothesis.
`def:frame-validity` reads "possible world `τ ∈ H_F`", so the bundled form is correct here — and it
is why `valid_iff_forall_validOn`'s proof is nothing but the `.val`/`.property` bridge in both
directions.

**A theorem, not an alias.** The plan was explicit that relating `ValidOn` to `valid` must be a
theorem so no parallel validity notion is created. The machine-checked payoff is visible in the
axiom audit: `valid_iff_forall_validOn` reports **`propext` alone** — no `Classical.choice`, no
`Quot.sound`. The equivalence genuinely adds no mathematical content, which is exactly the claim
its docstring makes.

**No `⊨_F` notation.** `Truth.lean` records that a `TruthAt` notation was dropped for conflicting
with this file's `⊨` validity notation; a subscripted variant sits in the same parser
neighbourhood for no gain. Dot-notation `F.ValidOn φ` carries the reading. The plan's task list did
not ask for notation, so this is a recorded choice, not a deviation.

### Hypothesis form, and what unlocks the intrinsic form

`not_validOn_bot` takes *Spherical*, *Seriality*, *Interpolation*, *Limit* and a world state as
arguments, inheriting `PartialHistory.occurrence`'s shape verbatim rather than re-deriving it. This
is forced: `TaskFrame` carries neither the four axioms nor a nonemptiness field. Once the
frame-axiom-field refactor recorded in `Step.lean`'s "Invariant for a future frame-axiom-field
refactor" lands — making `TaskFrame.spherical` definitionally `Spherical TaskRel`, and likewise for
the others — the statement collapses to `¬ F.ValidOn ⊥` with `F` its only argument, mechanically.

## Deviation

One, and it is a rule override rather than a judgment call. The plan's second task asked the
docstring to record that the frame-intrinsic form "arrives with task 420 phase 10".
`.claude/rules/no-task-references-in-deliverables.md` forbids task-qualified phase references
outside `specs/**`, and `validate-no-task-references.sh` **blocked the write** at PreToolUse. The
same fact is recorded against the durable anchor the repository already uses for it — `Step.lean`'s
"Invariant for a future frame-axiom-field refactor", which is precisely what
`Extension/Extension.lean` cites for the frame-intrinsic form of `cor:occurrence`. The task/phase
pointer is preserved in the plan file, where it is permitted.

## Verification — baseline held on every row

| Check | Baseline | Measured | Verdict |
|---|---|---|---|
| Paper-definitions gate | case (a)/(b) | **exit 0, case (a)**, zero output | pass |
| `lake build` (tree-wide) | green, 2331 jobs | green, **2331 jobs**, exit 0 | unchanged |
| Live sorries (non-Boneyard) | exactly 1, `WeakCanonical/Transfer.lean` | exactly **1** compiler warning, `Transfer.lean:1068` (decl head for the `:1084` site) | unchanged |
| New axioms | 0 | **0** — the four `^axiom ` matches outside Boneyard are all docstring prose, not declarations | unchanged |
| `lake build FormalSystem.Semantics.Validity` | — | green, 820 jobs, **first attempt** | — |
| `#guard_msgs` mismatches in `lake build BimodalTest` | exactly 7, at named rows | **7**, at exactly the named rows (`BoxSpreadProbe:165`; `RegionGateProbe:299,330`; `TableauConformance:873,885,910,916`) | unchanged |

`lake build BimodalTest` exits **1**, because `#guard_msgs` mismatches are errors. That is the
baseline condition, not a regression: these are the pre-existing rows baselined 2026-07-29 against
an engine-behaviour change owned elsewhere, excluded by name from the Phase 29 re-baseline for the
eighth consecutive dispatch. **No probe row moved**, so there is nothing to report as a finding and
nothing was re-baselined.

Per-declaration axiom audit (`lean_verify`):

- `TaskFrame.not_validOn_bot` → `[propext, Classical.choice, Quot.sound]`. Choice is expected and
  correct: it enters through `cor:occurrence`, whose proof runs through Zorn — the paper's own
  footnote says so ("a theorem of ZFC, in contrast with the choice-free derivation of the zero
  loops").
- `Validity.valid_iff_forall_validOn` → `[propext]`.

Neither reports `sorryAx`.

## Plan housekeeping performed

The Phase 23 heading was reset from `[BLOCKED]` to `[COMPLETED]`. The stale `**BLOCKER**` block
and the `#### Re-adjudication (2026-08-12, dispatch_seq 1)` subsection were retired and replaced
with a short cleared-blocker note plus the two facts from them worth keeping: that the drift never
touched this phase's anchors, and that the correct unit of absorption is the whole wave rather than
the convenient anchor. The durable account of what drifted and why lives in
`specs/paper-definitions-of-record.md`'s own "Drift correction" sections.

## Sorry inventory

Empty for this phase. Nothing was deferred, and no strategic sorry was landed. The repository's
single live sorry (`WeakCanonical/Transfer.lean:1084`) is pre-existing and out of scope.
