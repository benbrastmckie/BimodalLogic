# Transfer Ledger — Proposal Packet (Task #872, Phase 2)

**Nothing in this document has been filed.** No task number has been allocated, `specs/state.json`
and `specs/TODO.md` are untouched by this packet, and Component 7 confirmation (the user's
explicit go/no-go on which rows below become tasks) is outstanding. This file is a
backlog-reconciled proposal set for the conclusion stage to act on, not a to-do list and not a
commitment.

## Read this before the table: a priority ruling bears directly on every row below

While this phase was being written, a concurrent session landed, first as a live uncommitted edit
to `specs/state.json` (`last_updated` `2026-11-05T18:21:07Z`) and then as the committed
`specs/ROADMAP.md` rewrite `d863cb374` ("roadmap: refocus on L-plus, demote L^open to
exploration"), a `PRIORITY RULING (2026-11-05, user): DEMOTED` annotation on six existing tasks in
the L^▷ transfer programme — **860, 869, 873, 874, 875, 876**. `specs/ROADMAP.md` now reads, as
committed fact: *"The aim is completeness and decidability of L⁺, the stability-modal language...
L^▷ is a secondary line of investigation, kept and not abandoned (user ruling, 2026-11-05)."* One
of the six tasks' own description states the operational consequence verbatim: *"do not dispatch
it ahead of, or batch it with, L-plus critical-path work."*

This is now settled, committed state, not a transient observation — both `specs/ROADMAP.md` and
`specs/state.json` agree as of commit `d863cb374`.

**Every proposal below (T1–T5) extends the L^▷ transfer programme** — the same programme the
ruling just demoted. None of them carries the demotion annotation yet, simply because none of
them exists as a filed task yet. **If any of T1–T5 is filed, it should be filed with the same
annotation already applied to 860/869/873/874/875/876**, not as ordinary, immediately-dispatchable
work. This packet does not decide whether to file any of them at all given the ruling — that is
exactly the kind of judgment call this dispatch defers to the user, and `.return-meta.json` for
this dispatch sets `user_decision` accordingly. The table below is produced in full regardless,
per the plan's mandate, so the decision is a single read rather than a re-derivation if and when
the user chooses to revisit L^▷ work.

## Component 0 — the task-count test, applied to T1–T6 before anything was written

The report's six prose recommendations (T1–T6) were tested against the standard's task-count
test before any proposal was drafted. Default is consolidation; a row survives as its own
proposal only under a named divide reason.

| Row | Resolution | Divide reason / absorption target |
|---|---|---|
| T1 (state-locality fragment) | **Proposal** (below) | (a) disjoint file scope — new file, no existing task owns it |
| T2 (semantics-support lemmas) | **Proposal** (below) | (a) disjoint file scope from every other surviving proposal; optionally absorbs R42 as a final phase per the report |
| T3 (axiom-set non-redundancy) | **Proposal** (below) | (c) real dependency ordering — hard-gated on task 856's soundness phase, which landed (phase 12, committed) during this ledger task's own research/implement cycle |
| T4 (direct embedding) | **Proposal** (below) | (a) disjoint file scope, (c) real ordering vs. tasks 873/874 (both already declare `Formula.lean` in `file_scope`) |
| T5 (`hmarkers`) | **Proposal** (below), reduced scope | checked against task 860 (`[researched]`, `file_scope`: `FormalSystem/Semantics/Frames/TranslationProduct.lean` only) — 860 does **not** yet discharge the bridge lemma (still researched, not implemented) and does not touch `OpenFutureUndefinable.lean`, so T5 is disjoint in file scope from 860 but genuinely gated behind it (divide reason (c)); not a duplicate, not yet an application |
| T6 (discrete/`⊡`-indexed abbreviations) | **Not filed** — absorbed | into task **873** (open language subformula closure): both are pure syntax over `FormalSystem/OpenLanguage/Formula.lean`-adjacent territory (873 already derives `DecidableEq` there), the same layer, and T6's content (`next`/`prev`/`would`/`after`/`Will`/`will`/`Could`/`could` plus `atom_injective`) is too small (divide-reason (d) fails — it is *under*, not over, one dispatch) to justify its own task. If 873 is filed or revised, its scope should explicitly pick this up as a cheap addendum. |

Five proposals survive: **T1, T2, T3, T4, T5**. This is within the plan's own 3–5 scope
hypothesis window.

## Component 4a — pairwise file-scope overlap (within the packet, and against the existing backlog)

No two of T1–T5 share a `file_scope` entry with each other. Against the **existing, filed**
backlog (via `audit-task-proposals.sh`, full verdicts in `proposals-audit.ndjson`, one line per
proposal, 470–484 verdicts each against the whole open-task corpus):

| Proposal | `scope-blind` (collapsed) | shared-path-backed overlaps (rendered below) | purely-semantic non-new verdicts (collapsed) |
|---|---:|---|---:|
| T1 | 456 | 1 | 19 |
| T2 | 456 | 1 | 13 |
| T3 | 455 | 2 | 19 |
| T4 | 455 | 3 | 16 |
| T5 | 451 | 1 | 32 |

**Interpretive note**: `scope-blind` (no `file_scope` on the comparison target — the dominant
verdict, as the plan's own risk table anticipated) is collapsed to a count per the plan's
instruction. This packet extends the same collapse to the *purely-semantic* non-`genuinely-new`
verdicts (`duplicate-of-open`/`subset-of-open`/`covered-by-closed` with `shared_paths: null`,
i.e. text-similarity matches with no file-level corroboration) — rendering all 19+13+19+16+32 of
these individually would bury the five mechanically-grounded overlaps below in noise with no
added evidentiary value; the full, unfiltered list of every verdict is preserved verbatim in
`proposals-audit.ndjson` for anyone who wants it. **No proposal returned a `genuinely-new`
verdict** — every one of them overlaps something in this densely-related corner of the backlog,
which is expected given task 872 exists precisely because this territory is crowded.

**Shared-path-backed overlaps** (the mechanically real ones):

- **T1** vs. task **876** (`subset-of-open`, shared: `OpenStateLocal.lean`) — 876 declares a bare
  directory root `FormalSystem/OpenLanguage/` as its `file_scope` (itself a pre-existing
  violation of the no-directory-root rule this packet was told to avoid), which trivially
  contains every T1–T4 file. 876 is `[NOT STARTED]` and is itself one of the six tasks the live
  priority ruling just demoted (off both critical paths). Not a real duplicate of content; a
  scope-breadth artifact.
- **T2** vs. task **876** (`subset-of-open`, shared: all 4 of T2's files) — same directory-root
  artifact as above.
- **T3** vs. task **856** (`subset-of-open`, shared: `OpenAxioms.lean`) — real and expected: 856
  declares `OpenAxioms.lean` in its own `file_scope` and is still mid-flight (phase 15, in
  progress). T3 must not run concurrently against the same file; see the ordering constraints
  below.
- **T3** vs. task **876** (`subset-of-open`, shared: `OpenAxioms.lean`) — directory-root artifact,
  as above.
- **T4** vs. tasks **873**, **874**, **876** (`subset-of-open`, shared: `Formula.lean` for 873/874;
  directory-root artifact for 876) — 873 and 874 are real, narrow overlaps (both declare
  `Formula.lean` specifically, not a directory root); see the ordering constraints below.
- **T5** vs. task **875** (`subset-of-open`, shared: `OpenFutureUndefinable.lean`) — 875 declares
  a bare directory root `FormalSystem/Metalogic/Independence/` (same pre-existing artifact class
  as 876's). Not a real content duplicate — 875 is about incompleteness transfer at Base, a
  different result, that happens to live in the same directory.

## Component 7 — the confirmation table

| # | Title | Task Type | Effort | Dependencies | Backlog Check |
|---|---|---|---|---|---|
| — | T1 — The L^▷ state-locality fragment | lean4 | moderate | none (856 phase 12 soundness, needed only if a derivability row is wanted, already landed) | `subset-of-open` vs. 876 `(auto: file overlap — directory-root artifact)`; 19 semantic-only matches collapsed, see NDJSON |
| — | T2 — The L^▷ semantics-support lemmas | lean4 | small-to-moderate | task 869 `(auto: file overlap — real, see ordering below)` | `subset-of-open` vs. 876 `(auto: file overlap — directory-root artifact)`; 13 semantic-only matches collapsed |
| — | T3 — L^▷ axiom-set non-redundancy | lean4 | moderate-to-large | task 856 closes entirely (currently phase 15, in progress) `(auto: file overlap — real)` | `subset-of-open` vs. 856 `(auto: file overlap — real)` and vs. 876 `(auto: file overlap — directory-root artifact)`; 19 semantic-only matches collapsed |
| — | T4 — Name the direct L-to-L^▷ embedding | lean4 | small | tasks 873, 874 `(auto: file overlap — real, see ordering below)` | `subset-of-open` vs. 873, 874 `(auto: file overlap — real)` and vs. 876 `(auto: file overlap — directory-root artifact)`; 16 semantic-only matches collapsed |
| — | T5 — Specialize `ofut_not_plusDefinable_of_deltaProp_inexpressible` | lean4 | trivial | task 860 (hard gate, not yet satisfied — 860 is `[researched]`, not implemented) | `subset-of-open` vs. 875 `(auto: file overlap — directory-root artifact, not a content duplicate)`; 32 semantic-only matches collapsed |

`#` is deliberately left unallocated — these are proposals, not tasks.

## The two ordering constraints

1. **T4 (direct embedding) must be sequenced before tasks 873 and 874**, both of which declare
   `FormalSystem/OpenLanguage/Formula.lean` in their own `file_scope` and both of which would
   otherwise edit the same file independently. This is a **revision** of the report's original
   framing: the report named task **856 phase 13** as the thing T4 must precede, but phase 13
   landed (committed `e3392ff51`) during this ledger task's own Phase 1 audit, using the unnamed
   composite rather than T4's proposed name — so that specific edge is now moot (already
   happened), and the governing edge is the one against 873/874, which have not yet started.
   T4 is small and should land first regardless; its own description above notes that Forward.lean
   (phase 13) is now a candidate for a follow-up rewrite once T4's name exists, not a blocker.
2. **T2 shares `FormalSystem/OpenLanguage/` and `FormalSystem/Semantics/` territory with task 869**
   (open modal invariance ray agreement lifting — `[NOT STARTED]`, `file_scope` includes
   `FormalSystem/OpenLanguage/OpenInvariance.lean` and `FormalSystem/OpenLanguage.lean`). T2
   proposes `openValidIn_iff_recurrenceFree` and the reflection rows; 869 proposes `open_invariance`
   over `OpenFormula`, touching the same truth recursion. Must be batched together or given an
   explicit dependency edge; never dispatched concurrently.

Both constraints are stated here as the plan requires; neither has been acted on (no
`--depends-on-add`, no state edit) by this dispatch.

## Rows blocked on open mathematics — not proposed as tasks

Carried forward unchanged from the report's own closing section, since Phase 2's non-goal is to
audit and package the report's recommendations, not re-derive them:

1. **Completeness of any extension of the TM⁺ axiom set, at any class.** OPEN.
2. **TM⁺ decidability.** OPEN — the L^▷ reductions are already landed in conditional form (task
   868, `[COMPLETED]`); the correct response is application once the L-plus antecedent lands, not
   a new task.
3. **The 35-row ZTime certificate front** (`PlusSharingWitnessFamily`, `PlusSlicedCertificate`,
   `NoFiniteWidth`, `FiniteCarrier`) — recommend explicitly deferring the L^▷ reading of this block
   until the L-plus side closes.
4. **`hinexpr`** — the inexpressibility of `MarkerGadget.DeltaProp`, derived in prose and
   UNVERIFIED in Lean. A substantial research-grade Lean task, not a transfer.

None of these four is a candidate for filing from this packet, independent of the priority-ruling
discussion above.
