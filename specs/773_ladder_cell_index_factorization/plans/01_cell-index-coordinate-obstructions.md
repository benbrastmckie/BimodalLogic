# Implementation Plan: Task #773

- **Task**: 773 - Ladder cell index factorization: a computable index through which `cellAt` factors
- **Status**: [IMPLEMENTING]
- **Effort**: 9.5 hours
- **Dependencies**: None (research-first; parent record 761, whose Phase 1 is `[BLOCKED]` on this sub-problem)
- **Research Inputs**: specs/773_ladder_cell_index_factorization/reports/01_cell-index-factorization.md
- **Artifacts**: plans/01_cell-index-coordinate-obstructions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The dispatch's TARGET — the gap-carrying three-coordinate index
`(q, min c B, min n B, clip (n - c) [-B, B])` and its factorization lemma — is REFUTED uniformly
in `B` by this task's own research, machine-checked in
`prototype/parity-index-refutation.lean`: `Count true true` forces the countdown to run to `0`
exactly, so the first idle state sits at distance `c + 1`, and a `step` relation that alternates
a tag on every pending step makes `c mod 2` observable there through `p U (r ∧ a)`. The
witnessing pair carries EQUAL next-deadlines and two gaps that both saturate the clip, so the
gap coordinate is not what fails — the countdown coordinate is. Route (C) of the pre-landed
prototype (bound the carrier instead of indexing it) is closed by a second machine-checked
derivation. The factorization lemma as filed is therefore not attemptable: it is false, and a
`sorry` or a same-named weaker restatement is forbidden (`plan-compliance.md`, Statement
Fidelity). The user ruled in cycle 1 (decisions file): **re-scope within this task** — define
the residue-carrying index, gate it against all three known mechanisms, then attempt the lemma.

This plan executes that ruling as a falsify-first decision-gate plan. Phase 1 defines the
re-scoped six-coordinate index `(q, min c T, c % P, min n T, n % P, clip (n - c) [-B, B])` and
runs the two CHEAP gates (the known gap pair; the parity pair) before any proof attempt. Phase 2
runs the third gate — the second-region-end hunt the research names as the place its own
sufficiency argument is weakest — as three enumerated, bounded attempts with both outcomes
pre-specified. Phase 3 lands, independently of either gate, the generic theorem that makes the
residue coordinates well-founded rather than ad hoc: `step`-reachability on a finite object is
eventually periodic in the number of steps, so the index's `T` and `P` are EXHIBITED from the
object instead of assumed. Phases 4-8 land the record: the fourteenth wired evidence probe
carrying the refutation, the route-(C) closure, the gates and the periodicity lemma; its gate
wiring; the in-tree record amendments that stop the refuted candidate being described as
plausible; and the context note that stops the next attempt rediscovering the three mechanisms
from scratch. **Definition of done**: the probe compiles and is wired, every record sentence
naming the gap candidate names it as refuted, and the positive factorization lemma is recorded
as OPEN — never stated, never sorry'd, never weakened.

### Research Integration

- **F1 (the filed TARGET is false), carried verbatim and not re-derived.** `cell_succ_ne (tg) (c)
  (n) : cellAt M phiP (wP tg c n) 0 ≠ cellAt M phiP (wP tg (c+1) n) 0` for EVERY `c` and `n` with
  `n` held FIXED; `index_collide B` puts `((true,false), 2B, 4B+2)` and
  `((true,false), 2B+1, 4B+2)` at the same candidate index at every `B` (object components equal,
  both countdowns saturating `min _ B`, both gaps `2B+2`/`2B+1` saturating the clip at `+B`);
  hence `ladderIndex_not_factoring B` for every `B`, and both filed forms — exhibited at
  `B = |cl phiP|` (`exhibited_form_refuted`) and `∃ B` (`exists_form_refuted`). Compiled oracle:
  `prototype/parity-index-refutation.lean`, 484 lines, `lake env lean` exit 0, no `sorry`,
  `[propext, Classical.choice, Quot.sound]`.
- **F2 (the mechanism, and why it is not the gap).** `Count`'s no-early-discharge clause puts an
  unbounded-distance observable at exactly `c + 1`: the object state at the region end, a
  `step`-reachability datum in `c + 1` steps. `step` is independent of the counters, so it may
  alternate a tag per pending step and copy it onto the ending idle state. `truth_phiP` reads
  that tag, so the truth value of `phiP` at a pending state is a function of `c mod 2` and of
  nothing else — not of `n`, not of any drift choice.
- **F3 (the dispatch's one-part gate passed, and was still too weak).** `gate_separates (B)
  (hB : 2 ≤ B)` — the known refutation's pair `(B, B+1)` vs `(B, B+2)` IS separated by the gap
  coordinate, so the dispatch's falsification test was sound and non-vacuous;
  `gate_collides_below_two (B) (hB : B ≤ 1)` — and it fails at `B ≤ 1`, which is pre-landed
  finding (B) restated as a lower bound on the `φ`-derived clip rather than a free choice. The
  operative lesson, carried into Phase 1 and Phase 2: **a gate probing one coordinate certifies
  one coordinate**, so the re-scoped candidate is gated three ways before any proof attempt.
- **F4 (route (C) is closed by a landed theorem, not a conjecture).** `bounded_ladder_finite` (the
  deadline-bounded sub-carrier IS finite, as route (C) claims) → `finBranch_eq_ofSlicedStep` (on a
  finite carrier `ofSlicedStepFinBranch R hf hb fwd bwd = FrameOver.ofSlicedStep R fwd bwd` by
  `rfl`; the two differ only in which proof discharges `Saturation`, and proof irrelevance is
  definitional, so no transport lemma is needed) → `bounded_width_validates_Phi_neg` (every model
  on such a frame validates `Φ.neg` through `NoFiniteWidth.no_finite_width_sat`, applied
  unchanged), against `Phi_neg_not_valid : ¬ PlusValidZTime NoFiniteWidth.Φ.neg`. Route (C)'s
  premise is FALSE at `φ = Φ.neg`. Compiled oracle: `prototype/route-c-finite-width.lean`, 77
  lines, exit 0. This plan does NOT re-attack route (C); it ports the closure so the citation is
  machine-checked rather than quoted, and Phase 6 carries the narrow carve-out the research states
  honestly (a bounded carrier remains available for a target that DOES have a finite-width
  countermodel — `not_finite_width_fmp`'s own disclaimer; what is refuted is route (C) as the
  GENERAL route).
- **F5 (the repair, and its honest limit).** What is observable at the region end is eventually
  periodic in `c` for a relation on a finite set, so `min c T` together with `c % P` determines it
  where `min c T` alone does not (`index_res_separates` confirms the separation on the refuting
  pair at period 2). The same reasoning one region later forces `n % P`: from `(q, c, n)` the
  achievable next-region lengths form the interval `[max(0, gap - 1), n + c + 1]`, of width
  `2c + 3`, which covers every residue class once `c ≥ P` and does not when `c < P` with `n`
  large. The gap coordinate is RETAINED — the known gap mechanism is real and gap-shaped, and
  this research adds a second mechanism rather than displacing the first. **That the six-coordinate
  shape SUFFICES is argued, not proved**, and this plan does not claim it: Phase 2 attacks it,
  Phase 3 lands only the periodicity theorem the argument rests on, and no phase states the
  factorization lemma.
- **F6 (the clip bound's origin), carried from pre-landed finding (B).** The gap coordinate's
  bound `B` MUST be derived from `φ` (its `X`-nesting depth, or `|cl φ|`), NEVER from the
  counters; `T` and `P` come from the OBJECT. `gate_collides_below_two` is the lower-bound half of
  the same constraint. Phase 1's index signature keeps the three parameters separate for exactly
  this reason, and no phase ties `B` to `T` or `P`.
- **F7 (the past is a gap question, not a new one).** `PlusFormula` has `snce`, so `tpOf` is not
  future-only; backward pending steps give `c₀ = c + 1` with `n₀ ∈ {n-1, n, n+1}`, a
  region-start predecessor needs gap `∈ {-1, 0, 1}`, so "the region started ≤ k steps ago" is
  governed by `g ≤ 1 + 2k` and the clipped gap serves the past as well as the future. This is an
  ARGUMENT, not a landed lemma, which is why Phase 2's attempt (iii-b) probes it directly rather
  than relying on it.
- **F8 (what stays untouched).** `anchorCells_finite` and `anchorCells_ncard_le` are untouched:
  the SET of cells is still finite and bounded. What is absent is only the computable INDEX. The
  `box`/`stab` acceptance clause rides on that same index (`stab_mem_tpOf_iff` is that cell's
  bit, `box_mem_tpOf_iff` one global bit), so nothing here licenses dropping the clause to make a
  structure writable. Every quantity named in this plan is a COUNT; no complexity bound is
  claimed anywhere.
- **Tactic notes carried from the report's Tactic Survey** (port the calls, do not re-derive):
  `Count`/`Drift` case arithmetic after `rw [count_tt]` closes by `omega`, which handles
  `Int.toNat` and `min` directly; `tagAt` parity steps by `split_ifs <;> omega` or `simp`
  (`Int.emod` by the literal `2` is in omega's fragment); opaque `Bool` obligations need
  `cases <term> <;> simp [stepP]` — bare `simp` leaves an `if`; index collisions by
  `simp only [..., Prod.mk.injEq, Fin.mk.injEq, true_and]` then `omega`; finiteness of the
  bounded sub-carrier by `Finite.of_injective` plus `simp only [Prod.mk.injEq, Fin.mk.injEq]`;
  `ofSlicedStepFinBranch = ofSlicedStep` by `rfl`. Known failure: `omega` does NOT close `0 < s`
  on `F.Duration` (its order is not syntactically `Int.lt`) — re-ascribe first.
- **Not planned**, from the report's own prioritisation: recommendation 3's successor (a
  set-valued per-state datum over a quotient) is named in the records as the direction to take if
  Phase 2 refutes, and is not designed here; no library module under `FormalSystem/` gains a
  declaration (only `LadderModel.lean`'s module docstring is amended); no Hit-level twin of the
  refutation is attempted.

### Prior Plan Reference

No prior plan for this task. The shape precedent is
`specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md` — the record
this sub-problem blocks — and its two recorded lessons are carried here: the plan-level
`- **Status**:` field is reserved for `update-plan-status.sh` via the postflight and must NOT be
hand-edited by the implementer; and a probe file must be `git add`-ed before the evidence gate
runs, because the gate's rule is "tracked, not merely present". Its effort calibration (six
phases, 4.5 hours estimated, ~1.5 hours actual for a port-plus-records round) is the reason this
plan's port and record phases are costed at 1.5 and 1 hour rather than higher; the two research
phases (1-3) carry the genuine uncertainty and are costed accordingly.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted, is not edited,
and no roadmap phases are added (the orchestrate conclusion regenerates it).

## Goals & Non-Goals

**Goals**:
(The identifier set equals the twelve theorem declarations of the Lean Challenge Statements
block below. Every other backtickable name in this block is deliberately left unbackticked,
because the snapshot tool reads every backticked token here as a Goal.)
- `cell_succ_ne` — the cells at (q, c, n) and (q, c+1, n) differ for every c and every n with n held fixed: the countdown's parity is observable at the region end, so no index whose countdown coordinate has finite range can be sound.
- `ladderIndex_not_factoring` — the gap-carrying three-coordinate index does not factor the realized cells, at every clip bound.
- `exhibited_form_refuted` — the exhibited-bound form of the filed statement, at the closure cardinality, is refuted.
- `exists_form_refuted` — the existential form of the filed statement is refuted; the witness is uniform in the bound.
- `gate_gap_separates` — the re-scoped residue-carrying index separates the known gap pair at every clip bound of at least two.
- `gate_parity_separates` — the re-scoped residue-carrying index separates the parity pair that refutes the three-coordinate candidate, at every modulus of at least two.
- `bounded_ladder_finite` — the deadline-bounded admissible ladder sub-carrier is finite for a finite object.
- `finBranch_eq_ofSlicedStep` — on a finite carrier the run layer's finite-branching frame constructor is definitionally the sliced-step one.
- `bounded_width_validates_Phi_neg` — therefore every model on such a frame validates the finite-width non-validity.
- `Phi_neg_not_valid` — that formula is not valid over integer time, so the bounded-carrier route cannot reach it.
- `iterate_eventually_periodic` — iteration of any endofunction of a finite type is eventually periodic, with a threshold and a period.
- `reachN_eventually_periodic` — hence the step-reachability set of a finite object is eventually periodic in the number of steps, which EXHIBITS the threshold and period the re-scoped index's two residue coordinates are taken at.

**Non-Goals**:
- **No factorization lemma is stated, in any shape.** Not for the refuted three-coordinate
  candidate (it is false), not for the re-scoped six-coordinate candidate (its sufficiency is
  argued, not proved — Phase 2 attacks it and Phase 3 lands only the periodicity theorem beneath
  the argument). No sorry, no axiom, no vacuous definition, no hypothesis added to a filed
  statement, no same-named weaker restatement (`plan-compliance.md`, Statement Fidelity).
- No declaration is added to any module under FormalSystem/: no new library module, no
  LadderRealize, no LadderCons of any shape, no index claimed in the library. The only edit
  inside FormalSystem/ is the module docstring of the admissible-carrier module and one row of
  the cluster README.
- No reopening of the bounded-carrier route as a general route; the narrow carve-out is recorded
  by citing the finite-width limitation's own disclaimer, never the prototype README's framing.
- No seventh coordinate is added on speculation. If Phase 2 refutes the six-coordinate shape, the
  recorded conclusion is the research's recommendation 3 — that no fixed-arity index of this
  family works and the realization half needs a different presentation of a cell — not a wider
  tuple.
- No upper bound and no complexity bound, for the index or for anything it feeds; every quantity
  named is a count, the same posture the admissible-carrier module already states.
- Nothing about HitPresented; no declaration mentions PlusValidZTime; the cell-set finiteness and
  cardinality results stay untouched; the acceptance clause is never dropped.
- No edit to ROADMAP.md, to the parent record's description, or to any other task's description;
  no new task is spawned by this plan (the successor decision is the user's).
- No task number appears in any file outside specs/ — the evidence-script row, the cluster README,
  the theorem index and the context note cite durable anchors only (filenames, declaration names,
  section headings).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer reads the user's "then attempt the factorization lemma" ruling as licence to state the lemma with a hypothesis added, a quantifier specialised, or a `sorry` body | H | M | The Non-Goals forbid it outright; the Challenge block contains no factorization statement; Phase 3's deliverable is the periodicity theorem and nothing else; Phase 6's record sentences say in words that the positive lemma is OPEN. A same-named weaker statement is the one defect this record exists to prevent |
| Phase 2's hunt is open-ended and consumes the whole budget | H | M | Three enumerated attempts (iii-a, iii-b, iii-c) with a stated expected outcome for each and an explicit stop condition; the phase closes on the enumeration, not on a verdict, and "no refutation found on these three attempts" is a recorded outcome with the honest caveat that it is not a proof |
| Phase 3's periodicity lemma turns out to need a Mathlib name that does not exist, and is re-derived badly | M | M | The proof is pigeonhole on an infinite-domain finite-codomain map followed by induction; `lean_local_search` then `lean_leansearch` for an existing eventual-periodicity lemma BEFORE writing it, with the index-state interpretation rule from the dispatch's readiness block observed (only `index: consulted` makes an empty result proof of absence) |
| The parity gate's general-modulus obligation (`2B % (P+1) ≠ (2B+1) % (P+1)`) resists `omega`, which cannot reason about a symbolic modulus | M | H | Named in Phase 1's tasks with the recipe: from the equality derive `Nat.ModEq`, then `Nat.ModEq.dvd` gives `(P+1 : ℤ) ∣ 1`, then `Int.le_of_dvd` gives `P + 1 ≤ 1` against `1 ≤ P`. Fixing the modulus at 2 to dodge this would weaken a Challenge statement and is forbidden |
| The ported probe drifts from the compiled prototypes and a statement changes | M | L | The two prototypes are compiled oracles (exit 0 at research time, re-compiled at the start of Phase 4); the twelve Goal signatures are diffed byte-for-byte against the Challenge block; `lean-challenge-snapshot.sh --check 773 .` is available as an ADVISORY drift check whose verdict never fails a phase on its own |
| A record amendment re-describes the refuted gap candidate as plausible, or introduces a cost figure | M | M | Phase 6 greps every touched record for `clip`, `n - c`, `Fin (B+1)`, `min c B` and requires each surviving occurrence to sit in a sentence naming it refuted; the no-bound sentence is restated in each amended passage |
| A record amendment trips C9 (`check-module-invariants.sh` matches `specs/[0-9]{3}_`), the task-reference lint, the README lint, or C14's stale-count tripwire | M | M | Cite only `specs/evidence/...` paths, declaration names and section headings; introduce no axiom or sorry COUNT in any amended markdown; no record-versioning language ("no longer", "previously") — state the current fact |
| The context note lands in the deployed tree and is wiped by the next regeneration | M | M | Phase 7 targets `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/` (resolved from `.claude-extensions.json`'s `source_dir` at plan time); the deployed mirror under `.claude/` is never hand-authored and arrives with the next regeneration, which Phase 7 states as the expected outcome rather than a gap |
| `state-write.sh` is refused on the `specs/.scope-lock` mutex — several orchestrations are live in this repo | M | M | Bounded retry (3 attempts, 30 s apart); on persistent refusal Phase 6 closes `[PARTIAL]` with the in-tree record edits committed and the description amendment named as the remainder; never bypass the mutex, never hand-edit `state.json` |
| The evidence gate run (32 probes) exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; it is a sequence of `lake env lean` calls, not a `lake build` |
| A concurrent unguarded `lake` invocation collides with a guarded build | L | M | Every `lake` call in this plan goes through `lake-build-guard.sh`; an unexplained failure during concurrent work is checked against a competing unguarded build before being read as a regression (`rules/lean4.md`) |
| `typst-status-counts.sh` (pre-commit) regenerates `typst/generated/status.typ` with a diff | L | L | No library declaration changes, so no diff is expected; if the hook regenerates it, commit it with the phase that triggered it and record the fact in the summary |
| `file_scope` drift: the filed scope predates the re-scope and names neither the probe nor the record files | L | H | `Files to modify` below is the harvest source; the plan-postflight file-scope widening notice will fire for the added paths — expected, not a defect |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |
| 4 | 5, 6, 7 | 4 |
| 5 | 8 | 5, 6, 7 |

Phases within the same wave can execute in parallel. **Phase 1 is a decision gate**: if either
cheap gate COLLIDES, the re-scoped candidate is dead on the known mechanisms and Phases 2 and 3
close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 1's own
measurement, while Phases 4-8 still land the record (the refutation, the route-(C) closure and
the collision itself). **Phase 2 is the second decision gate**, with both branches
pre-specified in its own body. **Phase 4 depends on Phases 2 and 3 for its header content, not
for their success**: a `[BLOCKED]`, `[PARTIAL]` or `[COMPLETED WITH EXCLUSIONS]` Phase 2 or 3
determines WHICH sentence Phase 4's header carries and never prevents Phase 4 from running — the
record is the deliverable that does not depend on the research outcome. Phase 8 is the final
phase: it depends transitively on every other phase and re-observes their measurements through
the full gate set.

### Phase 1: The Re-Scoped Residue-Carrying Index and the Two Cheap Gates [COMPLETED]

**Goal**: Define the six-coordinate index
`(q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])` as a `Fintype`-valued
function generic in the object, and gate it — before any proof attempt — against the two
mechanisms already known to kill clipped-coordinate candidates: the gap pair that killed the
two-coordinate index, and the parity pair that killed the three-coordinate one.

**Tasks**:
- [x] Re-compile both research prototypes through the guard, as the oracles every later phase
      relies on:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/773_ladder_cell_index_factorization/prototype/parity-index-refutation.lean`
      and the same for `prototype/route-c-finite-width.lean`. Both must exit 0 with no warnings.
      If either does not, STOP and report — every later phase ports from them.
- [x] Create `specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean` with a
      PROTOTYPE header (not a wired probe) naming: what the three-coordinate candidate was, why
      it is refuted (the region-end observable at distance `c + 1`), and what this file tests —
      two cheap separations, never a sufficiency claim.
- [x] Reuse the parity fixture's object verbatim from `prototype/parity-index-refutation.lean`
      (`Qp`, `pendP`, `stepP`, and the admissible-state constructor), importing the same three
      modules. Do not author a second object; the index is generic in the object and the gates
      only read the counters and the object component.
- [x] Define `ladderIndexRes (T P B : ℕ) {Q} {pend} (x : LadderState Q pend)` at the exact
      signature in the Lean Challenge Statements block, with the three parameters kept SEPARATE:
      `T` and `P` are object-derived (Phase 3 exhibits them), `B` is `φ`-derived (pre-landed
      finding (B)). The two residue coordinates use modulus `P + 1` so that `Fin (P + 1)` is
      inhabited with no side hypothesis; the `Fin` bounds discharge by `Nat.mod_lt _
      (Nat.succ_pos P)` and `omega`.
- [x] Prove `gate_gap_separates (T P B : ℕ) (hB : 2 ≤ B)` on the pair with counters `(B, B+1)`
      and `(B, B+2)`: the gap coordinate gives `min (B+1) (2*B)` against `min (B+2) (2*B)`, which
      differ for `2 ≤ B`. Expect `simp only [..., Prod.mk.injEq, Fin.mk.injEq]` then `omega`.
- [x] Prove `gate_parity_separates (T P B : ℕ) (hP : 1 ≤ P)` on the pair with counters `(2B,
      4B+2)` and `(2B+1, 4B+2)` — the pair that refutes the three-coordinate index, with EQUAL
      next-deadlines and both gaps saturating the clip. The separating coordinate is `c % (P+1)`,
      and the obligation `2*B % (P+1) ≠ (2*B+1) % (P+1)` is NOT in omega's fragment (symbolic
      modulus): derive `Nat.ModEq` from the assumed equality, apply `Nat.ModEq.dvd` to get
      `(P+1 : ℤ) ∣ 1`, then `Int.le_of_dvd` and `omega` against `1 ≤ P`. Search for an existing
      Mathlib consecutive-residue lemma first (`lean_local_search`, then `lean_leansearch`);
      fixing the modulus at a literal to dodge this obligation would weaken a Challenge statement
      and is forbidden.
- [x] Close with `#print axioms` for both gate theorems, and compile through the guard.
- [x] **Decision gate**: record which branch holds. If BOTH gates separate, Phases 2 and 3 run as
      written. If EITHER collides, write the collision as a named theorem in this file, record it
      in the phase body, and mark Phases 2 and 3 `[COMPLETED WITH EXCLUSIONS]` with a
      `#### Reasoned Exclusions` record whose Evidence column cites this phase's compiled
      collision theorem; Phases 4-8 then land the record of a candidate dead on the known
      mechanisms.
- [x] `git add` the new file and commit per the green-substep mandate.

#### Decision Gate Outcome: BOTH GATES SEPARATE

Measured in this dispatch, not predicted. `residue-index-gate.lean` compiles through the guard at
exit 0 with zero `error` and zero `warning` lines, and both gate theorems close at the pinned
signatures over `LadderState` values:

| Gate | Theorem | Separating coordinate | Axioms |
|------|---------|----------------------|--------|
| Gap pair `(B, B+1)` vs `(B, B+2)`, `2 ≤ B` | `gate_gap_separates` | the clipped gap `min ((n + B) - c) (2B)` | `[propext, Quot.sound]` |
| Parity pair `(2B, 4B+2)` vs `(2B+1, 4B+2)`, `1 ≤ P` | `gate_parity_separates` | the countdown residue `c % (P + 1)` | `[propext, Classical.choice, Quot.sound]` |

Neither gate collides, so **Phases 2 and 3 run as written** and no `#### Reasoned Exclusions`
record is opened. The parity gate is stated at a SYMBOLIC modulus: the supporting arithmetic
`consec_mod_ne` derives `(P+1 : ℤ) ∣ 1` from the congruence through `Nat.ModEq.dvd` and
`Int.le_of_dvd`, so no retreat to a literal modulus was taken.

The honest limit, carried forward: a gate probing one coordinate certifies one coordinate. Both
cheap gates passing says the two mechanisms already KNOWN to kill clipped-coordinate candidates do
not lift to the re-scoped shape — it does not say the six coordinates suffice, which is Phase 2's
target and is asserted nowhere.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The file is ~110-170 lines (a ~50-line header, the fixture reused at ~25
lines, the index definition at ~12, two gate proofs at ~35). Confirm with `wc -l`; a figure
outside 90-220 is a signal that a fixture was duplicated rather than reused, or that a gate was
proved on raw arithmetic instead of on ladder states — not a defect in itself.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean`
exiting 0 is the complete covering check — the file is a prototype outside the Lake build graph,
nothing imports it, and it modifies no library module, so no other compilation unit can be
affected.

**Files to modify**:
- `specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean` - new prototype: the six-coordinate index and the two cheap gates

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean`
  prints nothing.
- Both gate theorems appear with exactly the signatures in `## Lean Challenge Statements`, stated
  over `LadderState` values (not over bare arithmetic), with `#print axioms` lines printed.
- The index definition's three parameters are independent: no task couples `B` to `T` or `P`, and
  no gate theorem's hypothesis set mentions a counter-derived bound on `B`.
- The decision-gate branch is recorded in this phase's body before Phase 2 or 3 begins.

---

### Phase 2: The Third Gate — the Second-Region-End Hunt [COMPLETED]

**Goal**: Attack the six-coordinate candidate where the research says its own sufficiency
argument is weakest — one region further out, and in the past direction — through three
enumerated, bounded attempts, and record which of the two pre-specified outcomes holds.

**Tasks**:
- [x] Create `specs/773_ladder_cell_index_factorization/prototype/second-region-hunt.lean` with a
      PROTOTYPE header stating the target (the six-coordinate index of the sibling prototype), the
      argument under attack (from `(q, c, n)` the achievable next-region lengths form
      `[max(0, gap - 1), n + c + 1]`, of width `2c + 3`, so once `c ≥ P` every residue class is
      covered and nothing further is observable), and the three attempts below with their
      expected outcomes — written BEFORE the attempts are run, so a null result is a recorded
      prediction rather than a retrofit.
- [x] **(iii-a) The second region's end.** Extend the parity object so that `step` tags the end of
      the SECOND region with the parity of that region's length, and ask whether a pair agreeing
      on all six coordinates can have different achievable second-region-end tag SETS. Expected
      outcome: NO refutation once `T ≥ P`, because the window's position is
      `(n - c - 1) mod (P+1)`, which the two residue coordinates already determine, and its width
      `2c + 3` exceeds the modulus exactly when `min c T` saturates. Record either the refutation
      or the precise reason the window is determined.
- [x] **(iii-b) The past direction.** Report finding F7 is an ARGUMENT: a state with gap `g` has
      its region start at least `⌈(g-1)/2⌉ ` steps back, so the clipped gap is claimed to serve
      the past as well as the future. Probe it: take a pair with EQUAL clipped gap and different
      true gaps, both above the clip, with small `c`, and ask whether a `snce`-letter separates
      them. Expected outcome: no separation for a formula whose past-depth is below the clip, and
      a refutation if one is found at or above it — in which case the clip bound's `φ`-derivation
      must cover past depth too, which is the finding to record.
- [x] **(iii-c) One region further.** Iterate (iii-a) to the third region end, where the
      achievable-interval widths compound. Expected outcome: subsumed by (iii-a)'s determinacy
      argument; run it only if (iii-a) closes without a refutation, and stop after it either way.
- [x] **Stop condition, binding**: the phase closes on this enumeration, never on a verdict. Do
      not open a fourth attempt, do not widen the index, and do not begin a sufficiency proof.
- [x] **Decision gate, both branches pre-specified**:
      - **Branch R (a refutation is found)**: land it as a named theorem in this file with
        `#print axioms`, and record in the phase body that the conclusion for the record is the
        research's recommendation 3 — no fixed-arity index of this family works, and the
        realization half needs a different presentation of a cell (a set-valued per-state datum
        over a quotient), NOT a seventh coordinate. Phase 4's header carries that sentence.
      - **Branch P (no refutation on these three attempts)**: record exactly that, with the
        honest caveat the research insists on — three attempts on one fixture family show that
        the known and the nearest unknown mechanisms do not lift, not that the general
        factorization holds. Phase 4's header carries that sentence instead, and the positive
        lemma stays OPEN and unstated.
- [x] Compile through the guard and commit per the green-substep mandate.

#### Decision Gate Outcome: BRANCH P — no refutation on these three attempts

`second-region-hunt.lean` (351 lines, inside the "a figure above 400 is a signal" bound) compiles
through the guard at exit 0 with zero `error` and zero `warning` lines; zero-debt grep count 0.
The three predictions are written in the file header ABOVE every declaration, each with its
result recorded beside it.

**The sentence Phase 4's header carries verbatim**:

> No refutation was found on these three attempts. Three attempts on one fixture family show that
> the known mechanisms and the nearest unknown one do not lift to the six-coordinate shape; they
> do not show that the general factorization holds, which remains OPEN and is stated nowhere.

Per-attempt measurement:

| Attempt | Predicted | Measured | Settling declarations |
|---------|-----------|----------|----------------------|
| (iii-a) second region's end | no refutation, because the achievable window is positioned by the residue coordinates | no refutation, but the predicted REASON is refuted: there is no window. `Count false false` holds the countdown at `0` through an idle interval of any length while `Drift` moves the next deadline one per step either way, so EVERY second-region length is reachable from EVERY pending state — independently of `T`, `P` and `B` | `second_region_any_length`, `second_region_end_tag_achievable`, `second_region_sets_agree` |
| (iii-b) the past direction | no separation below the clip; a refutation at or above it would force past depth into the clip's `φ`-derivation | no refutation. Report finding F7's ARGUMENT is now an arithmetic bound: gap rises ≤ 2 per pending step, ≤ 1 at a region start, so a state `j` steps past its region start has gap ≤ `2j - 1`; contrapositively a gap above `2k - 1` puts every region start beyond `k` backward steps. The attempt's pair (countdown `1`, deadlines `2B+1`/`2B+2`) saturates the clip identically with region starts ≥ `B + 1` steps back. **Recorded refinement**: the clip bound's `φ`-derivation must cover `snce`-nesting depth as well as `X`-nesting depth | `gap_step_le`, `gap_region_start_le_one`, `gap_le_region_age`, `region_start_beyond_depth`, `clipped_gap_collides` |
| (iii-c) one region further | subsumed by (iii-a) | subsumed, and more cleanly: (iii-a)'s theorem is stated from an ARBITRARY pending state, so iteration is one application of transitivity and no widths compound | `third_region_any_length` |

The stop condition was honoured: no fourth attempt, no seventh coordinate, no sufficiency proof
begun. Two limits are stated in the file itself rather than left to a reader — the (iii-a)
theorems are REACHABILITY statements about the admissible carrier, not truth statements about
`cellAt`; and the (iii-b) bound locates a region START, which is not the same as showing no
`snce`-formula separates the pair.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~180-300 lines (a ~60-line header carrying the three predictions, one
extended fixture at ~70, and the attempts at ~50-150 depending on which branch holds). Confirm
with `wc -l`; a figure above 400 is a signal that a fourth attempt was opened against the stop
condition, not a defect in itself.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/773_ladder_cell_index_factorization/prototype/second-region-hunt.lean`
exiting 0 is the complete covering check — a prototype outside the Lake build graph that nothing
imports and that modifies no library module.

**Files to modify**:
- `specs/773_ladder_cell_index_factorization/prototype/second-region-hunt.lean` - new prototype: the third gate's three enumerated attempts and their outcome

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines; no `sorry`,
  no `axiom`, no vacuous-definition pattern (grep count 0).
- The header's three predictions are present and were written before the attempts (they appear
  above the declarations in the file, and each attempt's result is recorded beside its
  prediction).
- Exactly one of Branch R / Branch P is recorded in the phase body, with the sentence Phase 4's
  header is to carry quoted verbatim.
- No declaration in this file states, or partially states, a factorization lemma; no index wider
  than six coordinates is defined.

---

### Phase 3: Eventual Periodicity — Exhibiting the Index's Threshold and Period [COMPLETED]

**Goal**: Land the generic theorem that makes the two residue coordinates well-founded rather
than ad hoc: iteration of an endofunction of a finite type is eventually periodic, hence the
`step`-reachability set of a finite object is eventually periodic in the number of steps, so the
index's `T` and `P` are EXHIBITED from the object instead of assumed.

**Tasks**:
- [x] Search for an existing Mathlib eventual-periodicity lemma before writing one:
      `lean_local_search` for a local declaration, then `lean_leansearch` /`lean_loogle` for
      `f^[n] a` periodicity on a finite type. Observe the dispatch's index-state rule: only
      `index: consulted` makes an empty result proof of absence; announce the evidence tier if the
      index is `warming` or `unavailable` rather than reporting absence.
- [x] Create `specs/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`
      and prove `iterate_eventually_periodic {A} [Finite A] (f : A → A) (a : A) : ∃ T P, 1 ≤ P ∧
      ∀ k, T ≤ k → f^[k + P] a = f^[k] a` at exactly the Challenge signature. Route: pigeonhole on
      `n ↦ f^[n] a` (infinite domain, finite codomain) for two indices `i < j` with equal
      iterates, take `T := i`, `P := j - i`, then induct on `k - T` using
      `Function.iterate_add_apply`. If Mathlib already has the statement, cite it and prove this
      one from it rather than re-deriving — the goal is the exhibited pair, not a novel proof.
- [x] Define the one-step reachability map `reachStep step S := S.biUnion (fun q =>
      Finset.univ.filter (fun q' => step q q' = true))` on `Finset Q` for `[Fintype Q]
      [DecidableEq Q]`, and prove `reachN_eventually_periodic` at exactly the Challenge
      signature by applying `iterate_eventually_periodic` at `A := Finset Q` (a `Fintype`, hence
      `Finite`).
- [x] Record in the file header, as prose and not as a claim: this exhibits the `T` and `P` the
      six-coordinate index's residue coordinates are taken at, for the datum the region-end
      observable is (`step`-reachability in `c + 1` steps); it is NOT the factorization lemma and
      says nothing about whether the six coordinates suffice. State that `B` remains
      `φ`-derived and is untouched by this phase.
- [x] Close with `#print axioms` for both theorems, compile through the guard, and commit per the
      green-substep mandate.

#### Outcome

`reach-eventual-periodicity.lean` (114 lines) compiles through the guard at exit 0, zero `error`
and zero `warning` lines. Both theorems close at the pinned signatures with
`[propext, Classical.choice, Quot.sound]`, and the period is `1 ≤ P` in both, so neither
conclusion is vacuous.

**Search evidence tier, announced rather than overstated**: `lean_local_search` for a local
eventual-periodicity declaration returned nothing but reported its symbol index as `warming`, NOT
`consulted` — by the dispatch readiness block's own interpretation rule that is not proof of
absence. `lean_leansearch` was unreachable (HTTP 500 on two attempts). `lean_loogle` on
`?f^[?n + ?p] ?a = ?f^[?n] ?a` surfaced only `Function.iterate_add_minimalPeriod_eq`, which
requires `x ∈ Function.periodicPts f` and so does not cover an arbitrary starting point. The
plan's named route (pigeonhole via `Finite.exists_ne_map_eq_of_infinite`, then
`Function.iterate_add_apply`) was therefore taken, at 14 lines; the deliverable is the exhibited
pair, not a novel proof.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~90-160 lines (a ~35-line header, the generic lemma at ~40-70, the
reachability corollary at ~20). Confirm with `wc -l`; a figure above 250 is a signal that the
pigeonhole step was re-derived from scratch where a Mathlib lemma exists.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`
exiting 0 is the complete covering check — a prototype outside the Lake build graph that nothing
imports and that modifies no library module.

**Files to modify**:
- `specs/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean` - new prototype: the generic eventual-periodicity theorem and its reachability corollary

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines; no `sorry`,
  no `axiom`, no vacuous-definition pattern (grep count 0).
- Both theorems appear with exactly the signatures in `## Lean Challenge Statements`, with
  `#print axioms` lines printed.
- The period is genuinely positive in both statements (`1 ≤ P` present, not `0 ≤ P`), so the
  conclusion is not vacuous.
- The header states that this is not the factorization lemma and claims no sufficiency.

---

### Phase 4: Author the Fourteenth Wired Probe [NOT STARTED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` —
the collection's record of what a ladder cell index cannot be — carrying the mandated header
followed by the ported declarations under `namespace Probe773`, compiling under `lake env lean`
with no `sorry`, no axiom, no vacuous definition, and the twelve Challenge statements verbatim.

**Tasks**:
- [ ] Write the header docstring (`/- … -/`, before the imports, modeled on
      `ladder-cell-refutation.lean`'s and `ladder-liveness-forward-only.lean`'s), containing in
      this order:
      - Title line: the clipped-coordinate cell index of the admissible ladder carrier is
        REFUTED at a second, independent coordinate — the countdown's parity, observable at the
        region end — uniformly in the clip bound; the bounded-carrier alternative is closed by the
        finite-width limitation; what remains is a gated candidate and an exhibited threshold and
        period, not a factorization lemma.
      - **What was asked**: the filed TARGET verbatim — the gap-carrying three-coordinate index
        and `ladderIndex B x = ladderIndex B y → cellAt M φ (t,x) z = cellAt M φ (t,y) z`, in both
        the exhibited-bound and existential forms.
      - **Why it is false** (the mechanism, citing landed declarations and proving nothing in
        prose): `Count true true` forces `c' + 1 = c`, so the first idle state sits at distance
        exactly `c + 1`; `step` is independent of the counters, so it may alternate a tag per
        pending step and copy it onto the ending idle state; an atom reading that tag under
        `p U (r ∧ a)` reads `c mod 2` at unbounded distance. The witnessing pair carries EQUAL
        next-deadlines and two gaps that both saturate the clip, so the gap coordinate is not what
        fails. Note that the gap mechanism of the twelfth probe is real and NOT displaced: it
        killed a small gap at large counters, which is why the gap coordinate is retained.
      - **What the earlier one-part gate did and did not certify**: the known refutation's own
        pair IS separated by a gap coordinate for a clip bound of at least two, and collides
        below it — so the clip bound must come from `φ` and never from the counters — and a gate
        probing one coordinate certifies one coordinate.
      - **The bounded-carrier alternative, closed**: the deadline-bounded sub-carrier is finite;
        on a finite carrier the run layer's finite-branching constructor is definitionally the
        sliced-step one; so every model on such a frame validates the finite-width non-validity,
        which is not valid over integer time. Its premise fails. State the narrow carve-out
        honestly: a bounded carrier remains available for a target that DOES have a finite-width
        countermodel, citing that limitation's own disclaimer — what is refuted is the route as
        the GENERAL route.
      - **What is gated and what is exhibited**: the six-coordinate residue-carrying candidate
        separates both known pairs; the step-reachability datum the region end exposes is
        eventually periodic, which exhibits the threshold and period its residue coordinates are
        taken at; and the third gate's outcome, in the exact sentence Phase 2 recorded (Branch R
        or Branch P).
      - **What this probe does NOT say**: no factorization lemma for any index, in any shape —
        the six-coordinate candidate's sufficiency is argued, not proved, and is asserted nowhere;
        no seventh coordinate; no upper bound and no complexity bound (every quantity is a count);
        no finiteness added and the cell-set finiteness and cardinality results untouched; nothing
        about HitPresented, no mention of PlusValidZTime; no library module created and no
        declaration added under FormalSystem/; the acceptance clause is never dropped (the stab
        letter is that cell's bit); the successor design is not chosen here.
      - Axiom foot sentence (the per-theorem `#print axioms` outcomes) and the compile line
        `lake env lean specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`.
      - **No task number anywhere in the header** — durable anchors only (filenames, declaration
        names, section headings).
- [ ] Imports and opens: the run layer, the anchor layer, the admissible-carrier module, and the
      finite-width limitation module, exactly as the prototypes take them; `open` the same four
      namespaces; `namespace Probe773`.
- [ ] Port the parity refutation from `prototype/parity-index-refutation.lean` in order, keeping
      names, statements and docstrings: the object and its two seriality facts, the frame and
      model, the three letters and the formula, the history lemmas, the tag function, the forced
      run and the idle position, the truth lemma, the reference history, the cells, and
      `cell_succ_ne`; then the candidate index with `index_collide`,
      `ladderIndex_not_factoring`, `exhibited_form_refuted`, `exists_form_refuted`. Rename
      nothing; identifiers are already ASCII for the snapshot tool's regex.
- [ ] Port the bounded-carrier closure from `prototype/route-c-finite-width.lean`:
      `bounded_ladder_finite`, `finBranch_eq_ofSlicedStep`, `bounded_width_validates_Phi_neg`,
      `Phi_neg_not_valid`.
- [ ] Port Phase 1's index and gates (`ladderIndexRes`, `gate_gap_separates`,
      `gate_parity_separates`), Phase 3's two theorems (`iterate_eventually_periodic`,
      `reachN_eventually_periodic`), and whatever named theorem Phase 2's branch produced.
- [ ] Close with `end Probe773` and `#print axioms` for all twelve Goal declarations.
- [ ] Compile through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1200 -- env lean specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`.
- [ ] `git add` the new file — the gate's rule is "tracked, not merely present", and Phase 5
      fails otherwise — and commit per the green-substep mandate.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The probe is ~700-900 lines (484 ported from the parity prototype and 77
from the bounded-carrier prototype, both by `wc -l` at research time and re-confirmed in Phase 1;
~60 ported from Phase 1, ~50 from Phase 3, plus Phase 2's result and a ~130-170 line header).
Confirm with `wc -l`; a figure outside 600-1050 is a signal that a header section was dropped or a
declaration duplicated, not a defect in itself.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1200 -- env lean specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
exiting 0 is the complete covering check — the probe sits outside the Lake build graph, nothing
imports it, and it modifies no library module, so no other compilation unit can be affected.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` - new probe file (header plus ported proofs)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` lines and zero `warning` lines, and the
  `#print axioms` lines read as the prototypes' did (`[propext, Classical.choice, Quot.sound]` on
  the refutation theorems, `[propext, Quot.sound]` on the gate theorems).
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
  prints nothing.
- All twelve Goal declarations appear with exactly the signatures in
  `## Lean Challenge Statements` (docstrings may precede them);
  `bash .claude/scripts/lean-challenge-snapshot.sh --check 773 .` is available as an ADVISORY
  drift check whose verdict alone never fails this phase.
- Header read-through confirms every bullet of the first task is present, including the
  "gap mechanism not displaced" sentence, the clip-bound-from-φ sentence, the bounded-carrier
  carve-out, Phase 2's recorded outcome sentence verbatim, and the full "does NOT say" list.
- `grep -nE "specs/[0-9]{3}_|task [0-9]" specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
  prints nothing.
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
  exits 0.

---

### Phase 5: Wire the Probe into the Evidence Gate [NOT STARTED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh` so the gate compiles it on
every run, with a table row recording the decision it holds in place.

**Tasks**:
- [ ] Add a table row in the `# --- WIRED ---` comment table, directly after the
      `seam-gluing-ray-product/ladder-liveness-forward-only` row (the row block ends at the line
      before `WIRED=(`), in the same two-column wrapped `# probe | decision` format, headed for
      the run layer's phase-2 soundness half and its cell-index sub-problem, and stating: the
      clipped-coordinate index family is refuted at a SECOND coordinate (the countdown's parity,
      observable at the region end at distance `c + 1`) uniformly in the clip bound, with the
      witnessing pair carrying equal next-deadlines and both gaps saturating the clip; the
      bounded-carrier alternative is closed by the finite-width limitation (its premise fails at
      the non-validity the limitation exhibits), with the narrow carve-out named; what IS landed
      is a gated six-coordinate candidate and an exhibited threshold and period, never a
      factorization lemma. What it does NOT say: no index is claimed to factor the cells in any
      shape; no bound of any kind and no complexity bound; no finiteness added and the cell-set
      finiteness and cardinality results untouched; nothing about HitPresented or PlusValidZTime;
      no library module; the successor design not chosen. Axiom summary as printed by the probe.
      **No task number anywhere in the row.**
- [ ] Append `"seam-gluing-ray-product/ladder-cell-index-obstructions"` to the `WIRED=(` array
      immediately after `"seam-gluing-ray-product/ladder-liveness-forward-only"`.
- [ ] `bash -n scripts/check-evidence-probes.sh` (syntax), then run the gate detached with a
      bounded waiter per `context/patterns/bounded-build-waiter.md` — it is a sequence of
      `lake env lean` calls, not a `lake build`.
- [ ] Commit the script edit.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` followed by a full run of
`bash scripts/check-evidence-probes.sh` is the complete covering check — the script's own
execution exercises every line this phase edits, and nothing else in the repository reads the
`WIRED` array.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one table row in the WIRED comment table, one entry in the WIRED array

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0.
- The gate run reports one more wired probe than before (32 by the array plus its repository-path
  companion) with every probe PASS, and names the new probe in its output.
- `grep -nE "specs/[0-9]{3}_|task [0-9]" scripts/check-evidence-probes.sh` finds no occurrence
  introduced by this phase.
- The new row's text asserts no index, no bound and no complexity figure.

---

### Phase 6: Amend the In-Tree Records [NOT STARTED]

**Goal**: Stop every in-tree record describing the gap-carrying candidate as the plausible true
index, and record the refutation, the bounded-carrier closure and the open status of the positive
lemma, without introducing a count, a bound or a task reference.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` — module DOCSTRING only,
      no declaration touched: amend the "What this module does not hold" bullet that currently
      reads that a candidate carrying a third clipped coordinate for the gap is research-level and
      asserted nowhere, so that it states the current fact — the clipped-coordinate family is
      refuted at the countdown coordinate as well as bounded at the gap one, by the fourteenth
      wired probe; the computable index remains absent; the cell-set finiteness and cardinality
      results stay untouched; and the bounded-carrier alternative is closed as a general route.
      State the fact, with no record-versioning language ("no longer", "previously", "formerly").
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — three amendments:
      (a) the `LadderModel.lean` row of "What it holds", whose "no index of a ladder cell claimed"
      clause gains the refutation citation; (b) the requirement (W) row and the
      "(W): what landed and what did not" passage whose sentence currently reads that the
      plausible true index carries a third clipped coordinate and is not claimed — replace it with
      the refutation and the open status of the positive lemma, keeping the sub-problem's
      characterization (it is the hypothesis of the realization theorem, not a side question)
      unchanged; (c) a new Evidence paragraph after the thirteenth probe's paragraph, in the same
      shape, for the fourteenth probe: what it establishes, by which declarations, with the axiom
      summary, and the full "what it does not say" tail including the untouched cell-set results
      and the absent cost figure. Update the record's `Last verified` line if the file carries one.
- [ ] `docs/theorem-index.md` — amend the clauses in the admissible-carrier rows (the frame rows
      and the model row) that read "no index of a ladder cell claimed in any shape" so they also
      name the refutation of the clipped-coordinate family and cite the new probe path. Touch no
      declaration cell and no axiom cell, and introduce no count, so the C14 baseline pair and its
      stale-count tripwire stay satisfied.
- [ ] `specs/state.json` — amend this task's `description` through
      `bash .claude/scripts/state-write.sh` (never a hand edit) so the record does not continue to
      assert the refuted TARGET: keep the sub-problem statement and the three things the
      predecessor record conflates, replace the TARGET and METHOD paragraphs with the re-scoped
      candidate, the three-part gate and the exhibited threshold and period, and state that the
      positive factorization lemma is open. On a mutex refusal, retry 3 times 30 s apart, then
      close this phase `[PARTIAL]` with the record edits committed and this step named as the
      remainder. Regenerate `specs/TODO.md` with `bash .claude/scripts/generate-todo.sh`; never
      hand-edit it.
- [ ] Verify the library module still elaborates after the docstring edit (scoped guarded build),
      then commit per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Four files, with roughly one amended bullet in the module docstring, three
amendments in the cluster README (one of them a new paragraph), and three to five amended row
clauses in the theorem index. Confirm at implementation time by grepping each file for the
clipped-coordinate phrases below; a count outside two to eight amended clauses in the theorem
index is a signal that rows were missed or over-edited, not a defect in itself.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
plus `bash scripts/check-module-invariants.sh`, `bash scripts/readme-lint.sh` and
`bash .claude/scripts/check-task-references.sh` are the cheapest checks covering this phase's
blast radius: the only code-bearing edit is a module docstring in one library module, whose
scoped build catches a malformed comment delimiter, and the three lints own every markdown
surface touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` - module docstring bullet amended; no declaration touched
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the module row, the requirement row and its narrative passage, plus a new Evidence paragraph
- `docs/theorem-index.md` - the clipped-coordinate clauses in the admissible-carrier rows
- `specs/state.json` - this task's description, through state-write.sh
- `specs/TODO.md` - regenerated by generate-todo.sh, never hand-edited

**Verification**:
- The scoped guarded build of the admissible-carrier module exits 0 with no new warning.
- `check-module-invariants.sh`, `readme-lint.sh` and `check-task-references.sh` all exit 0.
- `grep -nE "clip|n - c|Fin \(B \+ 1\)|min c B" ` over the four touched files: every surviving
  occurrence sits in a sentence naming it refuted, bounded or research-level, and no occurrence
  describes it as the plausible true index.
- No amended passage introduces an axiom or sorry COUNT, a bound, or a complexity figure; no
  amended passage uses record-versioning language.
- `grep -nE "specs/[0-9]{3}_|task [0-9]" ` over the three non-specs files finds no occurrence
  introduced by this phase.
- `specs/state.json`: only this task's `description` and `last_updated` changed —
  `jq -S` equality of every other entry against HEAD; `specs/TODO.md` regenerated.

---

### Phase 7: Land the Counter-Observables Context Note in the Source Store [NOT STARTED]

**Goal**: Execute the research report's Context Extension Recommendation — record the three
mechanisms now known to defeat a clipped-coordinate ladder index, and the gate each one implies,
so the next index candidate is checked against all three before a proof is attempted rather than
rediscovering them.

**Tasks**:
- [ ] Resolve the edit target from `.claude-extensions.json`'s `source_dir` for the lean
      extension (plan-time value:
      `/home/benjamin/.config/nvim/agent-system/extensions/lean`) and write
      `context/project/lean4/domain/ladder-counter-observables.md` beneath it. **Never hand-author
      the deployed mirror under `.claude/`** (`rules/source-store-deploy-boundary.md`): the
      deployed copy is a disposable artifact and arrives with the next regeneration, which is the
      expected outcome of this phase rather than a gap.
- [ ] Content, in the shape the sibling domain notes use: (1) the structural fact that makes every
      "clip the counters" proposal fail — the no-early-discharge clause puts an unbounded-distance
      observable at exactly `c + 1`, the region end, and the step relation is independent of the
      counters; (2) the three mechanisms — the gap at the first idle state, the object state at
      the region end (the countdown residue), and finite width via the finite-width limitation —
      each with the declaration names that settle it and the probe file that carries them; (3) the
      gate each mechanism implies, as the three-part falsification gate to run BEFORE any proof
      attempt, with the lesson that a gate probing one coordinate certifies one coordinate; (4)
      the parameter-origin rule: the gap clip comes from the formula, the threshold and period
      from the object, never the reverse; (5) what is still open — the positive factorization
      lemma for any index, stated as open and unclaimed.
- [ ] Cite durable anchors only: declaration names, probe filenames under `specs/evidence/`,
      module paths, and section headings. No task number, no `specs/{NNN}_` path, no axiom or
      sorry count, no bound, no record-versioning language.
- [ ] Note in one line whether the lean extension's context index requires a registration entry
      for a new domain file; if it does, add it in the same source-store tree, and if it does not,
      say so rather than leaving the question silent.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Tier Justification**: The edit is one new guidance markdown file with zero executable surface,
for which `suite_selection_select` returns `__FULL_SWEEP__` (no suite covers it), so the honest
covering check is `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` (doc-lint and
task-reference lint) together with a diff read-through confirming every hunk is prose.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` - new context note in the extension source store (deployed mirror not hand-authored)

**Verification**:
- The file exists at the source-store path and nothing was written under `.claude/`
  (`git status --short .claude/` shows no change, and the deployed tree is gitignored anyway).
- Read-through confirms all five content items are present, each mechanism naming its settling
  declarations and its probe file.
- `grep -nE "specs/[0-9]{3}_|task [0-9]|no longer|previously|formerly" ` over the new file prints
  nothing.
- The file claims no factorization lemma, no bound and no count, and states the positive lemma as
  open.

---

### Phase 8: Full Gate and Final Verification [NOT STARTED]

**Goal**: Re-observe every phase's measurement through the repository's complete gate set, with
nothing trusted on sight.

**Tasks**:
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` (all gates, no
      `--only-gate` narrowing and no `--skip-slow`), `bash scripts/check-evidence-probes.sh`,
      `bash scripts/check-module-invariants.sh`, `bash scripts/readme-lint.sh`,
      `bash .claude/scripts/check-task-references.sh`, `bash scripts/typst-sync-check.sh` (if
      present in this tree), and the full guarded project build
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Every run goes
      detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`, and the
      verdict is read from the guard's own result rather than a pipe exit code.
- [ ] Re-grep the whole repository for a zero-debt violation introduced by this task: no `sorry`,
      no `axiom`, no vacuous-definition pattern in the probe or the three prototypes.
- [ ] Confirm the task's resting posture: the positive factorization lemma is stated nowhere; no
      declaration was added under `FormalSystem/`; the acceptance clause was not dropped; no file
      outside `specs/` carries a task number introduced here.
- [ ] If the pre-commit hook regenerates `typst/generated/status.typ`, commit the regenerated file
      with this phase and record the fact in the summary.
- [ ] Final commit for the phase.

**Timing**: 1 hour

**Depends on**: 5, 6, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `typst/generated/status.typ` - only if the pre-commit hook regenerates it; no edit is planned

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 with every gate it aggregates passing, run in
  this dispatch and observed green rather than trusted on sight.
- `check-evidence-probes.sh` reports every wired probe PASS, including the new one.
- `check-module-invariants.sh`, `readme-lint.sh`, `check-task-references.sh` and the full guarded
  `lake build` all exit 0.
- Zero-debt grep across the probe and the three prototypes returns no match for `sorry`,
  `^axiom `, or a vacuous-definition pattern.
- The twelve Challenge statements are present at their pinned signatures in the wired probe;
  `lean-challenge-snapshot.sh --check 773 .` is run as an advisory drift check and its verdict is
  reported, never used alone to fail the task.
- No phase heading carries a status other than `[COMPLETED]`, `[COMPLETED WITH EXCLUSIONS]`,
  `[PARTIAL]` or `[BLOCKED]` as its own body justifies; the plan-level `- **Status**:` field is
  left for the postflight and is not hand-edited.

---

## Lean Challenge Statements

The twelve `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which the snapshot tool
(`lean-challenge-snapshot.sh`) neither counts as a Goal nor rewrites — but it DOES swallow any
non-`theorem` text sitting between two `theorem` declarations into the preceding `:= sorry`, so
every `abbrev` precedes the first `theorem`. The two proof-carrying fixture facts the probe proves
in full (`fwdP`, `bwdP`) appear here as `sorry`-bodied `abbrev`s: they are not Goals, their
statements are pinned by position only. Definitional bodies (the object, the step relation, the
labelling, the two indices, the reachability map) are part of the contract and are written out;
the probe uses `def`/`theorem` for them, exactly as the prototypes do. Identifiers are ASCII for
the snapshot tool's regex. The third gate's outcome theorem (Phase 2, Branch R) is deliberately
NOT pinned here: its statement is not known at plan time, so it is an outcome rather than a
commitment, and it is not a Goal.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe773

abbrev Qp : Type := Bool × Bool

abbrev pendP : Qp → Bool := fun q => q.1

abbrev stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

-- Proved as theorems in the probe; `abbrev` here only so the snapshot tool keeps the ordering.
abbrev fwdP : ∀ t x, ∃ y, RladAdm stepP pendP t x y := sorry
abbrev bwdP : ∀ t x, ∃ y, RladAdm stepP pendP (t - 1) y x := sorry

abbrev F : FrameOver intOrder := ladderFrameAdm stepP pendP fwdP bwdP

abbrev pA : Atom := ⟨"p", none⟩
abbrev rA : Atom := ⟨"r", none⟩
abbrev aA : Atom := ⟨"a", none⟩

abbrev labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

abbrev M : TaskModel F.toTaskFrame := ladderModel stepP pendP fwdP bwdP labP

abbrev phiP : PlusFormula := .untl (.atom pA) ((.atom rA).and (.atom aA))

abbrev st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

abbrev wP (tg : Bool) (c n : ℕ) : F.WorldState := ((0 : ℤ), st tg c n)

/-- The refuted candidate: the gap-carrying three-coordinate index. -/
abbrev ladderIndex (B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (B + 1) × Fin (B + 1) × Fin (2 * B + 1) :=
  (x.1.1, ⟨min x.1.2.1 B, by omega⟩, ⟨min x.1.2.2 B, by omega⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- The re-scoped candidate: thresholds and residues on both counters beside the clipped gap.
`T` and `P` are object-derived (`reachN_eventually_periodic` exhibits them); `B` is
formula-derived and is never tied to either. -/
abbrev ladderIndexRes (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- One step of reachability under the object's step relation. -/
abbrev reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

theorem cell_succ_ne (tg : Bool) (c n : ℕ) :
    cellAt M phiP (wP tg c n) 0 ≠ cellAt M phiP (wP tg (c + 1) n) 0 := sorry

theorem ladderIndex_not_factoring (B : ℕ) :
    ¬ ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := sorry

theorem exhibited_form_refuted :
    ¬ ∀ x y : LadderState Qp pendP,
        ladderIndex (plusSubformulaClosure phiP).card x
          = ladderIndex (plusSubformulaClosure phiP).card y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := sorry

theorem exists_form_refuted :
    ¬ ∃ B : ℕ, ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := sorry

theorem gate_gap_separates (T P B : ℕ) (hB : 2 ≤ B) :
    ladderIndexRes T P B (st false B (B + 1)) ≠ ladderIndexRes T P B (st false B (B + 2)) := sorry

theorem gate_parity_separates (T P B : ℕ) (hP : 1 ≤ P) :
    ladderIndexRes T P B (st false (2 * B) (4 * B + 2))
      ≠ ladderIndexRes T P B (st false (2 * B + 1) (4 * B + 2)) := sorry

theorem bounded_ladder_finite {Q : Type} [Finite Q] (pend : Q → Bool) (N : ℕ) :
    Finite {x : LadderState Q pend // x.1.2.1 ≤ N ∧ x.1.2.2 ≤ N} := sorry

theorem finBranch_eq_ofSlicedStep {W : Type} [Finite W] [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    ofSlicedStepFinBranch R hf hb fwd bwd = FrameOver.ofSlicedStep R fwd bwd := sorry

theorem bounded_width_validates_Phi_neg {W : Type} [Finite W] [Nonempty W]
    (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
    (M : TaskModel (ofSlicedStepFinBranch R hf hb fwd bwd).toTaskFrame)
    (τ : WorldHistory (ofSlicedStepFinBranch R hf hb fwd bwd)) (t : ℤ) :
    PlusTruthAt M τ t NoFiniteWidth.Φ.neg := sorry

theorem Phi_neg_not_valid : ¬ PlusValidZTime NoFiniteWidth.Φ.neg := sorry

theorem iterate_eventually_periodic {A : Type} [Finite A] (f : A → A) (a : A) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k → f^[k + P] a = f^[k] a := sorry

theorem reachN_eventually_periodic {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (S : Finset Q) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (reachStep step)^[k + P] S = (reachStep step)^[k] S := sorry

end Probe773
```

## Testing & Validation

- [ ] Both research prototypes re-compile through the build guard at exit 0 with no warnings
      before anything is ported from them (Phase 1's first task).
- [ ] The three new prototypes and the wired probe each compile under the gate's own command
      (`lake env lean`, through the guard) with 0 errors and 0 warnings, and print their
      `#print axioms` lines.
- [ ] No `sorry`, `axiom`, or vacuous-definition pattern in any file this task writes (grep count
      0 in each).
- [ ] The twelve Goal declarations in the wired probe match the Lean Challenge Statements block
      exactly; `lean-challenge-snapshot.sh --check 773 .` is run as an advisory drift check and
      its verdict reported, never used alone to fail a phase.
- [ ] `check-evidence-probes.sh` reports every wired probe PASS, including the new one.
- [ ] `check-module-invariants.sh`, `check-task-references.sh`, `readme-lint.sh`,
      `typst-sync-check.sh` (if present), `verify-deploy.sh` (full, no narrowing) and the full
      guarded `lake build` all exit 0.
- [ ] Record read-through: every surviving mention of the clipped-coordinate candidate in the
      amended records names it refuted, bounded or research-level; the bounded-carrier carve-out
      cites the finite-width limitation's own disclaimer; no amended passage introduces a count, a
      bound or record-versioning language.
- [ ] No factorization lemma is stated anywhere, in any shape, for any index; no declaration was
      added under `FormalSystem/`; the acceptance clause is intact.
- [ ] No file outside `specs/` carries a task number introduced by this task.
- [ ] `specs/state.json`: only this task's `description` and `last_updated` changed; `TODO.md`
      regenerated, never hand-edited; the plan-level `- **Status**:` field left to the postflight.

## Artifacts & Outputs

- `specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean` (new — the six-coordinate index and the two cheap gates)
- `specs/773_ladder_cell_index_factorization/prototype/second-region-hunt.lean` (new — the third gate's three enumerated attempts and its recorded outcome)
- `specs/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean` (new — the exhibited threshold and period)
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` (new, tracked, wired — the fourteenth probe)
- `scripts/check-evidence-probes.sh` (one table row, one WIRED entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (module docstring bullet; no declaration touched)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (module row, requirement row, narrative passage, new Evidence paragraph)
- `docs/theorem-index.md` (clipped-coordinate clauses in the admissible-carrier rows)
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` (new context note in the extension source store)
- `specs/state.json` (this task's description, through state-write.sh) and the regenerated `specs/TODO.md`
- `specs/773_ladder_cell_index_factorization/prototype/parity-index-refutation.lean` and `prototype/route-c-finite-width.lean` (plan-time compiled oracles, already written by research)
- `specs/773_ladder_cell_index_factorization/summaries/01_cell-index-coordinate-obstructions-summary.md`
- This plan

## Rollback/Contingency

- Each phase is one to five files and commits per green substep; reverting a phase is reverting
  its commit(s). No phase requires discarding uncommitted work, so no snapshot-then-rollback
  recipe is planned; if a genuine rollback of uncommitted changes becomes necessary, follow
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override flag — never a bare precautionary checkpoint.
- If a ported declaration does not compile, STOP and compare against the prototype line by line:
  both prototypes are compiled oracles, re-confirmed in Phase 1. Do not re-derive the proof and do
  not substitute a different decomposition (`plan-compliance.md`). If a Challenge statement does
  not close as written, record the failure in the probe header as a further obstruction and mark
  the phase `[BLOCKED]` — never a `sorry`, an axiom, a vacuous definition, a weakened signature,
  or a retreat to a fixed literal modulus.
- If Phase 1's cheap gates collide, the re-scoped candidate is dead on the known mechanisms:
  Phases 2 and 3 close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record
  citing Phase 1's compiled collision theorem, and Phases 4-8 land that outcome as the record. No
  seventh coordinate is attempted inside this task.
- If Phase 2 finds a refutation, the recorded conclusion is that no fixed-arity index of this
  family works and the realization half needs a different presentation of a cell; the successor
  design is the user's decision, not this task's.
- If Phase 5's gate run fails on the new entry, remove the entry and the row (the probe file
  stays, tracked but unwired) rather than weakening any statement.
- If `state-write.sh` is refused three times on the mutex, Phase 6 closes `[PARTIAL]` with the
  in-tree record edits committed and the description amendment named as the remainder; the
  amendment is then applied by the next dispatch, never by hand.
- Any factorization lemma, any index claimed to factor the cells, any seventh coordinate, or any
  `LadderCons`-shaped structure written under this task is a defect, not progress.
