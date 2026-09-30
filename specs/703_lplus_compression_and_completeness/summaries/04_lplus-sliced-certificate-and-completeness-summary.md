# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-30T00:52:00Z (dispatch 21); 2026-09-30T01:20:00Z (dispatch 23)
- **Completed**: 2026-09-30T02:30:00Z
- **Effort**: ~30 minutes (dispatch 21, Phase 9) + ~70 minutes (dispatch 23, Phases 10-13)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.SharingSkeleton`,
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` (both landed).
  `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is NOT consumed by Stage 1 — see
  Verification.
- **Artifacts**: plans/04_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Stage 1 of the plan is complete and Stage 2 is open.** Five of twenty-one phases are closed —
Phase 9 by dispatch 21, and Phases 10, 11, 12 and 13 by dispatch 23. **The L⁺ compression statement
is now refuted, as a theorem of the tree.** Phase 11 is the load-bearing one: `not_plusCertifies_pumpTarget` proves that
**no** `PlusSharingWitnessFamily` certifies `pumpTarget p`, at any time, for any lasso count, any
segment length, any period and under no hypothesis whatsoever on the succession relation. What
was previously a withdrawal recorded in a report is now a theorem with a counterexample formula,
and the tree's own documentation has been corrected to stop overstating the class's coverage.

Soundness was never in question and is not now. `PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` are byte-identical in statement, and both still print exactly
`[propext, Classical.choice, Quot.sound]` after every change here.

Stage 2 — the time-sliced certificate — is **opened**, not finished. Phase 13 lands its three
types, its readout and its bi-seriality condition, with the plan's pinned field lists confirmed by
writing two of the checker's four clause groups against them rather than by asserting they will do.
Phases 14-21 remain: eight phases, including the plan's own two highest-risk ones (15, computed
liveness; 16, tail-stability with its counterexample fixture) and Phase 19, the only completeness
theorem this research supports.

## What Changed

### Phase 9 (dispatch 21, already landed on `main` as `9355b68fe`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` — **created**, 456
  lines: the five tense/stability abbreviations (`Xp`, `X¬p`, `Fp`, `⟐Xp`, `⟐X¬p`), the two limit
  targets `hopTarget` = `□⟐Xp → (□⟐X¬p → ⊥)` and `pumpTarget` = `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`,
  the two shared antecedents on the permissive frame, both ℤ-time non-validity theorems, and the
  13-step and 17-step closure-membership chains with the `untl`-shape characterizations. All
  parametric in `(p : Atom)`.

### Phase 10 (this dispatch, commit `09ab45be9`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean` — **created**, ~320
  lines:
  - `hopFree_branchesTrue`, `hopFree_branchesFalse` — every position of *any* certifying family has
    a share-class member branching to `p` and one branching to `¬p`. No hop-freedom hypothesis:
    these are facts about the whole class, derived from (C4), (C1')'s `imp` clause, (C3), (C5) and
    the reflexive instance of (C1')'s `untl` clause.
  - `hopFree_deviates` — (C0) then forces, at every time, a successor state of the main index's
    state **distinct from its own**.
  - `not_plusCertifies_hopTarget_of_hopFree` — the counting step, and the only place hop-freedom is
    spent: `lift` tracks each deviation by a succession path, hop-freedom makes that path constant,
    so `lassos.length + 1` deviation times need `lassos.length + 1` pairwise-distinct indices in a
    type of cardinality `lassos.length`.
  - `not_exists_hopFree_plusCertifies_hopTarget` — the existential form the plan's Lean Challenge
    Statement pins.
  - A "What this does **not** say" docstring section: hop-freedom is incomplete; `TransId.lean`'s
    four collapse theorems remain true and remain in the tree; the theorem bounds a *strategy*, not
    the substrate; and `hopTarget p` is refutable, just not this way.

### Phase 11 (this dispatch, commit `726b6d99f`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` — **created**,
  ~445 lines:
  - `seqPostpone` — the long-postponement branching sequence, stated over abstract successor
    functions so it carries no family
  - `not_plusCertifies_pumpTarget` — **the class-level incompleteness.** Start on the main index at
    time `S.NM` (inside the forward-periodic region), follow `¬p`-successors for
    `k := S.lassos.length * S.perFwd + 1` steps, then take one `p`-successor; `lift` tracks it;
    (C0) transports the atom facts onto the tracking path; `⊤ ∈` every label propagates `Fp`
    backwards along it; pigeonhole over the `n + 1` times spaced by `S.NF` gives `v < v'` with the
    same index; `transRaw_congr_NF` and `data_congr_fwd` make the folded path a genuine `S.Thread`
    with the same labels; that thread carries `Fp` at `v` and never reads `p`, contradicting (C2').
  - `not_exists_plusCertifies_pumpTarget`, `plusCompression_fails_at_pumpTarget`
  - A "scope of the failure" docstring section stating, at its true generality, that the root cause
    is limit closure against a finite, eventually periodic, all-threads-fulfilling structure, and
    that **no bound repairs it**.

### Phase 13 (this dispatch, commit `5908fc924`) — Stage 2 opens

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Basic.lean` — **created**, 604 lines:
  - `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate` with exactly the fields the plan's second
    Lean Challenge Statement block pins. **No `lift`, `trans`, `witness`, `stepR` or `stateLab`
    field** — each absence is a decision the module docstring names and justifies, and a grep for
    those five as field names over all three structures returns 0.
  - `PlusGraphPath.datum`/`.lab`/`.st`, `.datum_mem`, `.lab_sub`, `.n_pos`, three decoding-region
    lemmas, four periodicity lemmas
  - `PlusSlicedCertificate.slice`/`.edge`/`.slab`/`.slab_sub`, three decoding-region lemmas,
    `slice_periodic_back`/`_fwd`, and `exists_window_eq` — proved by **residue**, not by induction
  - `PlusSlice.BiSerialAt`, `.BiSerial`, `.BiSerialWindow`, and `biSerial_iff_window` in **both**
    directions (`←` is what the checker needs, `→` what the frame construction needs)
  - `BoxFaithful` (C3) and `Target` (C4) — two of the checker's four clause groups, written here
    against the declared fields because that, and not an assertion, is what discharges this phase's
    Scope Hypothesis; plus `forall_slab_iff_window`, showing the box clause's `∀ t` quantifier costs
    the checker nothing. Phase 17 consumes these rather than restating them.
  - `onePointCertificate` and `slice_onePointCertificate` — the finite-graph special case, exhibited
    **and proved** to have a constant slice sequence. "Nothing was lost by slicing" is a theorem
    here, not a claim.
  - Two lemmas the `Formula`-side readout layer does not state, because that side never needs a
    decoded datum's *membership*: `getD_mem_of_lt` and `cyc_mem`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — **created**, the aggregator,
  with a header stating why this subtree exists beside `PlusWitnessFamily/` (which is sound and
  stays) and which of `Limits/`'s two failures each design choice answers.
- `FormalSystem/Metalogic/Decidability.lean` — one added import.

### Phase 12 (this dispatch — the record corrections and the gate pins)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — a new `### Non-empty is not
  complete` subsection under the "the certificate class was empty, and is not any more" heading.
  The heading's claim stays (it is true); what is added is that non-empty is not complete, by
  `not_exists_plusCertifies_pumpTarget`, and that **which fragment the class does cover is an open
  question**. Plus the two `## Submodules` bullets for the new modules.
- `…/PlusWitnessFamily/Incompleteness.lean` — the header sentence "It no longer records an
  obstruction, because there is no longer one to record" corrected: it no longer records *the*
  obstruction it once recorded (the `share`-congruence collapse), but there **is** one to record, at
  a different target and for a different reason, and it is named and pointed at.
- `…/PlusWitnessFamily/README.md` — "What failed, and is now repaired, was completeness of the
  certificate class" qualified to "**on these two targets**", with completeness in general recorded
  as refuted rather than repaired.
- `…/PlusWitnessFamily/TransId.lean` — a new `## There is no compression, and hop-freedom is
  incomplete` section; "the compression's choice" softened to "the intended producer's choice"; and
  an explicit statement that the four collapse theorems remain true, remain proved, and are kept.
- `…/WitnessFamily/Sharing/README.md` — the "empty certificate class that bounds what it can
  refute" cross-reference corrected. Per Phase 12's conditional instruction, this **was** a
  coverage claim about the live L⁺ class rather than a note on pre-redesign history, so it was
  corrected and the reasoning is recorded inline.
- `…/PlusWitnessFamily/Compression/Extract.lean` — a new `## The alignment half is retained and
  unused` section: everything from `plusAlignOffset` (line 147) through
  `exists_plusLabelledLasso_of_history_aligned` (line 770) has no consumer and is expected to have
  none, why it is kept rather than deleted, and that **C17's dead-declaration census is expected to
  report it**. C17 is reporting-only, so this is documentation of an intended state, not a waiver.
- `docs/theorem-index.md` — **four** rows added after the `not_untl_shift_share_congr` anchor, for
  `not_plusValidZTime_hopTarget`, `not_exists_hopFree_plusCertifies_hopTarget`,
  `not_plusValidZTime_pumpTarget` and `not_exists_plusCertifies_pumpTarget`. Paper label `—`; frame
  class `ZTime` for the two non-validities and `—` for the two incompleteness theorems; axioms
  `pcq pinned:C2`.
- `scripts/check-module-invariants.sh` — the same four names added to the `AX_SRC` heredoc and to
  the `AXIOM_BASELINE` heredoc **in the same relative order** (C2 is a whole-string equality), and
  the C2 pass message's number word moved from `eighteen` to `twenty-two`.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `Boneyard/README.md` —
  generated inventory blocks regenerated by `check-module-invariants.sh --emit-inventory` for the
  two added modules.
- `FormalSystem.lean` — regenerated twice by `lake exe mk_all --lib FormalSystem`, never
  hand-edited (invariant C33).
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix` for the file and
  line-count drift each commit causes; the repository's pre-commit gate requires it.

## Decisions

- **The three forced-successor facts are named lemmas in `HopFree.lean` and re-derived, not
  imported, in `NoCertificate.lean`.** This is not duplication by oversight: `plusClosureOf` is
  indexed by the context, so `hopClosure p` and `pumpClosure p` are distinct `Finset PlusFormula`
  values and no membership fact transports between them without a monotonicity principle neither
  limit theorem needs. The plan's Phase 11 task list says so explicitly.
- **`not_exists_hopFree_plusCertifies_hopTarget` was given the plan's pinned existential shape, and
  the universally-quantified workhorse was renamed.** The first version of Phase 10 stated the
  theorem as `(S) (t) (hid) : ¬ S.PlusCertifies t`, which is logically equivalent to the plan's
  `¬ ∃ S t, hid ∧ PlusCertifies` but is **not the same statement**. Since the Lean Challenge
  Statement block pins the flagship shapes and the plan's own risk register exists to stop exactly
  this kind of silent drift, the pinned shape was added under the pinned name and the workhorse
  became `not_plusCertifies_hopTarget_of_hopFree`. The theorem-index row and the C2 baseline cite
  the pinned name.
- **The two limit theorems are parametric in `(p : Atom)`.** Strictly stronger than the Challenge
  block's atom-free shape, and available because `natModel`'s valuation is atom-agnostic.
- **Hop-freedom's incompleteness is recorded as bounding a strategy, not the substrate.** Deleting
  `TransId.lean`'s four collapse theorems was considered and rejected: they are true statements
  about what hop-freedom buys a producer that already has per-lasso data, and the fact that no
  general producer can feed them does not touch them. Their header now says this.
- **The retained-and-unused alignment half of `Compression/Extract.lean` is kept, not deleted.** It
  is correct, non-trivial, and its `two_mul_plusAlignOffset_le` arithmetic is cheaper to keep than
  to re-derive; and deleting it would erase the record of what the withdrawn route required.

## Plan Deviations

- **Phase 10, altered**: the three forced-successor steps were factored into named lemmas rather
  than left inline, because each is a fact about an arbitrary family and Phase 11 asks for the same
  three facts.
- **Phase 10, altered**: the probe's `Int.induction_on` route to "a hop-free succession path is
  constant" did not elaborate in this module's import closure. Replaced with an `ℕ`-shift lemma
  plus `omega`.
- **Phase 10, altered (statement shape)**: see Decisions — the pinned existential form was added
  and the workhorse renamed, after the first version drifted from the Challenge block.
- **Phase 11, altered**: three explicit Mathlib imports added (`Mathlib.Data.Fintype.Pigeonhole`,
  `Mathlib.Tactic.Ring`, `Mathlib.Tactic.WLOG`), which the plan's file list did not anticipate
  because the probe it transcribes does `import FormalSystem`.
- **Phase 11, Scope Hypothesis resolved, not split**: the module is ~445 lines and fit one run. No
  decomposition into 11.1/11.2 was needed and none was made.
- **Phase 12, Scope Hypothesis confirmed**: the gate edits were exactly the asserted ten
  line-groups, and `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc moved from
  **18 to 22**, as predicted.
- **Phase 12, added work not in the plan**: the `INV` invariant (generated inventory blocks in four
  `README.md` files) went stale because two modules were added. Fixed in this phase by
  `check-module-invariants.sh --emit-inventory`, per the phase's own instruction to fix rather than
  defer anything the new subtree newly breaks.
- **Phase 12, excluded**: invariant **B0** does not pass. See Verification.
- **Phase 13, Scope Hypothesis confirmed, both halves**: the field lists are sufficient (confirmed
  by *writing* `BiSerial`, `BoxFaithful` and `Target` against them — no field was found missing or
  wrong, so no correction to the Challenge block was needed), and the generic readout lemmas
  instantiate at `PlusSlice n C` with no change (confirmed by reading their binders: all six are
  over `{α : Type*} [Inhabited α]`).
- **Phase 13, altered**: `Inhabited (PlusSlice n C)` needs no `n_pos` — the inert slice is definable
  at `n = 0`, so the hypothesis is not threaded. `Inhabited (Finset PlusFormula × Fin n)` is
  supplied from `back_ne` (the path's own `back.head`) rather than from a positivity field, which
  makes the default automatically a *member* of the path's data; `PlusGraphPath.n_pos` is recovered
  as a theorem.
- **Phase 13, altered**: `BiSerial` is the `∀ t` form and `BiSerialWindow` the window-decided one,
  not the other way round as the plan's wording has it — `G.frame (h : G.BiSerial)` reads the
  condition at an arbitrary time, so the `∀ t` form has to be the one the Challenge signature names.
  Both exist and `biSerial_iff_window` proves them equivalent, so nothing is lost.
- **Phase 13, altered**: `exists_window_eq` is proved by residue rather than by the double induction
  the plan's "extended to all `t` by the two periodicity lemmas" suggests. Stating bi-seriality *at
  one slice* is what makes that possible. Both periodicity lemmas are still proved and exported.
- **Phases 14-21, not started.**

## Verification

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2780 jobs** through Phase 12 and **2782 jobs** after Phase 13, **zero** `error:` and **zero**
  `warning:` lines over both captured streams. Run four times over the dispatch (after Phase 11,
  after the Phase 12 docstring edits, after the statement-shape fix, and after Phase 13), clean each
  time. Tier 3 confirmed: the `.olean` of `Limits/HopFree`,
  `Limits/NoCertificate`, `Limits/Targets`, `PlusWitnessFamily` and the `FormalSystem` root are all
  newer than their sources.
- **A false pass was caught and must be recorded.** `lake-build-guard.sh` shares its lock, result
  and log files **by hardlink** between the main tree and every `.orchestrate-worktrees/*` worktree
  (verified: `.lake/build-guard.log` has the same inode in both). The first guarded build in this
  dispatch therefore **replayed a stale main-tree result and reported `exit_status=0` for a module
  that had never been compiled** — with no `.olean` written. Every build after that passed
  `--no-share`. Any future dispatch building inside a worktree must do the same and must confirm
  the verdict against `.olean` timestamps rather than the exit code alone.
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots; empty inventory).
- Vacuous count: **0 attributable to this task.** The repository-wide scan reports one pre-existing
  match, `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`), outside this task's file scope and not a placeholder — the
  ℤ-time history's domain is total by construction. Reported rather than silently filtered.
- Axiom count: **unchanged at 14** over all resolved roots. No new module declares an `axiom`.
  `#print axioms` on every new declaration across all four new files returns a subset of
  `[propext, Classical.choice, Quot.sound]` — `getD_mem_of_lt` needs only `[propext]` and `cyc_mem`
  only `[propext, Quot.sound]`.
- **Phase 13's field-absence criterion was checked by reading the declarations, not assumed.**
  `PlusGraphPath` has exactly `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`label_sub`; `PlusSlice` exactly
  `edge`/`lab`/`lab_sub`; `PlusSlicedCertificate` exactly
  `n`/`n_pos`/`back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`bx`/`target`/`targetTime`. A grep for `lift`,
  `trans`, `witness`, `stepR`, `stateLab` as field names returns 0.
- **The gate was last run in full at Phase 12** (verdict below). Phase 13's four added/changed files
  postdate it; its own verification tier is `interface`, and Stage 2's gate rows and axiom pins are
  assigned to Phase 21, so no C2 divergence is possible from Phase 13's declarations. A full gate
  re-run belongs to the next dispatch.
- **Soundness survives, measured**: `plusTruth_iff_mem` and `plusRefutes_of_certifies` both still
  print exactly `[propext, Classical.choice, Quot.sound]`, and neither statement was edited.
- `bash scripts/check-module-invariants.sh`: **one check group fails, B0, and it is environmental.**
  - `PASS C2 all twenty-two pinned axiom sets match baseline` — the four new pins verified against
    a live compile, not transcribed.
  - `PASS C15` for all 61 paper-anchor citations and all 231 theorem-index rows carrying their
    anchor (or `Paper: —`) at the declaration.
  - `PASS` for C8, C11, C16, C21, C22, C23, C24, C25, C25N, C33, C34b, C35, C9D and the rest.
  - `INV` failed on the first run and **passes now** — it was genuinely caused by the two added
    modules and was fixed, not waived.
  - `FAIL B0 expected exactly 1 Boneyard directory at ./Boneyard, found 2` — **enumerated,
    reasoned, evidenced exclusion.** The second directory is
    `./.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard`, a leftover *harness* worktree from the
    aborted dispatch 21, still registered in `git worktree list`. It is gitignored, contains no
    work of this task, and its only commit (`228168b3b`) is already landed on `main` as
    `9355b68fe`, so nothing is lost by removing it. **It fails identically at `main`'s own HEAD
    with none of this dispatch's changes present** — confirmed by running the same `find` in the
    main tree with the dispatch worktree excluded. It was deliberately **not** removed here:
    deleting a registered git worktree belonging to another session is a destructive git operation
    outside an implementation agent's scope, and `/refresh` is the sanctioned remedy. One command
    clears it: `git worktree remove --force .claude/worktrees/agent-aa19bfa3bfef394ff`.
- `scripts/typst-sync-check.sh`: PASS after `--fix` (status.typ, module map and machine appendix all
  in sync). The repository's pre-commit hook is this check in `--counts-only` form and was confirmed
  green.
- Tests: N/A — no executable added and no test surface changed.
- Files verified: Yes.
- **No file under `/home/benjamin/Projects/ModelChecker` was created, edited or staged.** Confirmed:
  `git -C /home/benjamin/Projects/ModelChecker status --porcelain` shows only its pre-existing
  ` M specs/events.jsonl`, unchanged before and after the read.

## The paired repository's export contract

Phase 12's original bullet instructed the implementer to record that the contract "changes shape
from a list of lassos to a finite model … whose search bound is a bound on the number of world
states". **Plan v4's own amendment supersedes that**, on report 706's Q1.3 and Q7, and the
superseded wording is not recorded here. The five points the amendment directs be recorded instead
are, restated so that this summary is self-contained:

1. The **finite-graph** certificate must not become an export contract: it cannot represent
   countermodels the current lasso-family contract already represents — `θ.neg` is a `⊡`-free
   target the landed L family certifies and no finite-carrier certificate can.
2. The intended L⁺ contract is the **time-sliced graph**: per slice, an edge matrix and a state
   labelling; three segments `back`/`mid`/`fwd` of slices; one target path and time; `bx`. The
   current lasso family is the special case of `k` lassos with edges `i → i` only, so the wire
   format is a **strict extension, not a replacement**.
3. The search bound is a **tuple** `(n, nb, nm, nf)` — slice width and three segment lengths. **No
   bound on `n` is proved for any L⁺ target**, and none should be configured from a formula yet.
   "The search bound is a bound on the number of world states" is wrong in kind: there is no finite
   number of world states to bound. For `⊡`-free targets the landed L bounds apply unchanged, and
   the registry's period-folding caveat carries over to `nb`/`nf`.
4. The checker additionally requires **tail-stability**, so a search that finds a countermodel with
   unstable tails must re-present it with the pre-period moved into `mid` and the period multiplied.
5. The never-report-validity discipline stands: an empty search at any bound licenses nothing for
   L⁺ targets containing `⊡`, and will until a finite model property is proved.

**What this dispatch adds to that, from Stage 1's own results**: the compression bound that
`ModelChecker`'s #200 lists as the fourth of its four needs **does not exist, and cannot exist for
the landed certificate class.** That is no longer an expectation to be managed — it is
`not_exists_plusCertifies_pumpTarget`. The cross-repository hand-off note's item 5 ("the L⁺
compression theorem and its bound — task 703") is therefore answered in the negative, and the
O3 bound warning that note carries forward ("the paired repository's search-bound expectations for
#200's fourth need must not be set from the `Formula` side's `|closure| + 1` figure") is upgraded
from a caution to a settled fact: there is no `|closure| + 1` figure, and no figure of any shape,
for a class that certifies nothing at `pumpTarget`.

**Status of the confirmatory read.** The read of `/home/benjamin/Projects/ModelChecker`'s *current*
export format and bound configuration was delegated to a read-only subagent, which had not reported
by the time this dispatch closed — and which is owned by the parent session, so its report is
addressed there rather than into this dispatch's record. Whoever receives it should reconcile it
against points 1-5 above and, if it corrects any of them, amend this section rather than adding a
second account; whatever it establishes is a confirmation of, or a correction to, points 1-5 above,
which come from this repository's own report 706 rather than from an assumption about the paired
repository. The obligation to read rather than assume is therefore **partially discharged**: the
five points recorded above are read off report 706 and plan v4, not off the paired repository, and
a successor closing Phase 21 should complete the read. This is stated plainly rather than presented
as a completed read.

## Impacts

- **The L⁺ compression statement is refuted in the tree.** `plusCompression_fails_at_pumpTarget`
  bundles the non-validity and the absence of a certificate, so the withdrawal can be cited as one
  declaration rather than argued from a report.
- **Stage 2's design constraints are now forced rather than chosen.** "All-threads fulfilment is
  replaced by fulfilment of live positions only" is exactly what
  `not_exists_plusCertifies_pumpTarget` compels; Phases 13-21 inherit it as a theorem.
- **The hop-free producer is retired as a completeness strategy while its theorems survive.** Any
  future producer of L⁺ certificates now has a named reason not to be hop-free.
- **Four new C2 pins.** The two non-validities and the two incompleteness theorems are now pinned
  against a live compile, so a later change that silently widened their foundation would be a hard
  stop rather than a quiet regression.
- The `Limits/` subtree is self-contained: nothing outside it changed behaviourally, and the only
  edits to existing Lean modules are docstrings plus two import lines and the generated root.

## Follow-ups

- **Stage 2 is opened but not finished; Phases 14-21 remain, eight phases.** Phase 13 landed the
  three types, the readout and bi-seriality. What is left: the frame on `ℤ × Fin n` and its
  histories characterization (14), computed liveness with **both** directions (15), tail-stability
  with its four-state counterexample fixture (16), the decidable checker (17), soundness into the
  unchanged `PlusRefutes` export (18), completeness relative to tail-stable sliced models (19), the
  embedding of the landed L witness family (20), and the acceptance gates and closing record (21).
  **No Stage 2 probe exists**, so unlike Phases 9-11 none of it can be transcribed. Phases 15 and 16
  are the plan's own two highest-risk phases and 16 is deliberately scheduled before the checker.
- **Phase 17 should consume `BoxFaithful`, `Target` and `forall_slab_iff_window` from Phase 13
  rather than restating them.** They were written in Phase 13 specifically to discharge its Scope
  Hypothesis, and duplicating them would leave two definitions of the same clause group.
- **B0** is open and environmental: `git worktree remove --force
  .claude/worktrees/agent-aa19bfa3bfef394ff` in the main tree clears it. Until then
  `check-module-invariants.sh` reports one failing group in both the main tree and any worktree.
- **Four Mathlib names are unavailable in these modules' import closures** and cost iteration this
  dispatch: `ring`, `neg_one_mul`, `dvd_rfl`, `add_sub_cancel_right`, `le_or_lt` and
  `List.getD_eq_getElem`. Working substitutes are recorded in the Phase 13 handoff. Any further
  transcription from a probe (every probe does `import FormalSystem`) should expect to hit this.
- **The build-guard hardlink sharing is a live false-pass hazard** for every worktree-based
  dispatch in this repository, not just this task. Recorded in full under Verification. A fix in
  the guard (keying the result path on the resolved project root rather than sharing it) would
  close it; `--no-share` is the workaround.
- **Complete the paired-repository read** before Phase 21 closes, and reconcile it against the five
  points recorded above.
- **`trans_refl` remains a live risk, now for the two landed limit modules.** Both call
  `S.trans_refl'` at one identified step (obtaining the one-step `untl` unfolding at the *same*
  index). If task 699 Part A's proposed follow-on drops `trans_refl` from the substrate, both
  modules need a different route to that step. Phase 9's `Targets.lean` is unaffected.
- **`plusValidZTime_iff_plusValidInt` is still unconsumed.** Stage 1 states its non-validities
  against `PlusValidZTime` and never mentions `PlusValidInt`, consistent with plan v4's note that
  the carrier-normalization prerequisite is no longer on this plan's critical path.

## References

- `specs/703_lplus_compression_and_completeness/plans/04_lplus-sliced-certificate-and-completeness.md`
  — the plan. Phases 9, 10, 11 and 13 are `[COMPLETED]` and Phase 12 is
  `[COMPLETED WITH EXCLUSIONS]`, each with a `Verification — MEASURED` block under its heading.
- `specs/703_lplus_compression_and_completeness/probes/HopFreeIncomplete.lean` and
  `probes/NoFiniteCertificate.lean` — the provenance record for Phases 10 and 11; untouched, as the
  plan requires.
- `specs/703_lplus_compression_and_completeness/handoffs/phase-10-handoff-20260930T014500Z.md`,
  `handoffs/phase-11-handoff-20260930T015500Z.md`,
  `handoffs/phase-12-handoff-20260930T021000Z.md`,
  `handoffs/phase-13-handoff-20260930T023000Z.md`
- `specs/703_lplus_compression_and_completeness/.dispatch/23.md` — this dispatch's context
- `specs/archive/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md` — the
  five must-land results and the O3 bound warning this task answers
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/` — Stage 1's three landed modules
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/` — Stage 2's first landed module
