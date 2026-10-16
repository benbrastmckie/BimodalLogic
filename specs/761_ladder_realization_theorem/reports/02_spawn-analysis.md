# Blocker Analysis: Task #761

**Parent Task**: #761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
**Generated**: 2026-10-16
**Blocker**: The three filed declarations cannot be STATED, not merely unproved. `ladderRealized`
reached its `[Fintype Q]` obligation through `hitOf (truncate B …)`, and `truncate` is defined
nowhere in `FormalSystem/` (its only coherent reading, `Q × Fin (B+1) × Fin (B+1)`, is refuted and
deleted). What is missing is a computable indexing function `idx : LadderState Q pend → I`,
`[Fintype I]`, through which `cellAt` factors, plus the positive factorization lemma for it — open
in every shape, for every index, as of this session.

**Correction to this task's own stale artifact**: `specs/761_ladder_realization_theorem/.blocker-research.json`,
dated 2026-10-11 and predating the fourteenth wired probe, is STALE. Its
`solution_path` recommends gating the gap-carrying candidate `(q, min c B', min n B', clip (n-c)
[-B', B'])` — exactly the candidate `ladder-cell-index-obstructions.lean` has since refuted
(`exhibited_form_refuted`, `exists_form_refuted`, `cell_succ_ne`). A dispatch that read that file
without cross-checking the probes it predates would follow a dead route. This report supersedes
it; Section "What a first round should do" below proposes its correction as the new task's first
step, since the file lives under `specs/761_ladder_realization_theorem/` and this is a record
updating 761's own status.

Note on this report's own artifact slot: an earlier round (commit `f38925eae`) filed a different
`reports/02_spawn-analysis.md` recommending that no new task was needed because task 775 (then
active, parent 773) was already the correctly-scoped successor, and wiring a `761 → 775`
dependency edge (now present in `state.json`'s `dependencies: [760, 775]`) would suffice. Task 775
has since closed `[COMPLETED]` (archived at `specs/archive/775_residue_index_factorization_lemma/`)
with a NEGATIVE verdict at both of its object-exhibited parameters — it did not unblock 761, and
could not have, because the parameter-origin rule it discovered requires formula-joint
derivation that 775's own scope did not attempt. This report replaces that recommendation with a
concrete new task targeting the next candidate the rule names.

## Root Cause

**The index sub-problem, not a failed proof, is what blocks 761.** Three independent,
library-anchored reasons force every per-cell soundness statement for the ladder — hence
`ladderRealized`, and the `box`/`stab` acceptance clause `LadderCons` would need — to presuppose
a finite index of ladder states:

1. `Probe760.cell_ne` (in `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`)
   defeats saturation for every `Q`-indexed candidate: `cellAt M φ (w1 B) 0 ≠ cellAt M φ (w2 B) 0`
   for every `B`, uniformly.
2. `Count true true` (`FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`) runs a pending
   region's countdown down to `0` exactly, so its first idle state sits at distance exactly `c + 1`
   and the `Q`-projection of a seam fibre is a proper
   subset of the `Q`-runs; a presentation over `Q` over-approximates `HitCl` even for
   `box`/`stab`-free φ.
3. `PlusTruth.lean:93`'s `stab` clause collapses any per-state labelling into `ψ ↔ ⊡ψ`
   (`Probe747.stab_iff_of_presented_nowUnique`'s conclusion with both hypotheses dropped), so a
   finite per-cell object must carry a SET of types per ladder state — expressible only through a
   finite index of those states.

**Three candidate index shapes have been refuted on compiled ground**, each the subject of a
closed, archived predecessor record:

| Candidate | Probe (under `specs/evidence/seam-gluing-ray-product/`) | Refuting declarations | Predecessor task |
|---|---|---|---|
| counter-pair clipping `(q, min c B, min n B)` | `ladder-cell-refutation.lean` | `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted` | `760` (parent record) |
| gap-carrying `(q, min c B, min n B, clip (n-c) [-B, B])` | `ladder-cell-index-obstructions.lean` | `exhibited_form_refuted`, `exists_form_refuted`, `cell_succ_ne`, `gate_gap_separates`, `consec_mod_ne`; `bounded_ladder_finite` + `bounded_width_validates_Phi_neg` close the bounded-carrier route in general | `773` (archived, `specs/archive/773_ladder_cell_index_factorization/`) |
| residue-carrying `ladderIndexRes T P B` (six coordinates: `q, min c T, c%(P+1), min n T, n%(P+1), clip (n-c)[-B,B]`), at its OBJECT-EXHIBITED `(T, P)` | `ladder-residue-index-refutation.lean` | `object_only_parameters_refuted` (mechanism 4); `reach_period_refuted` (mechanism 5) | `775` (archived, `specs/archive/775_residue_index_factorization_lemma/`) |

775's own closing line is the operative one: "the positive lemma for parameters depending on the
object and the formula jointly is OPEN and stated nowhere" — 775 refuted only the
object-exhibited instantiation of `ladderIndexRes`'s `(T, P)`; it never attempted, let alone
gated, the formula-joint instantiation the parameter-origin rule requires.

**Mechanism, not fixture accident.** The current deadline forces a pending region to end at
`z + c` (`pending_run`, `idle_at`); `Count`'s idle clause copies the next deadline at that first
idle; `Drift` (`n' = n ∨ n' = n+1 ∨ n'+1 = n`) spreads it over `[n-c-1, n+c+1]`. A hypothesis of
the shape `B ≤ c, c', n, n'` bounds each counter separately and never their difference — this is
why every independently-clipped-counter candidate fails, and why a joint, formula-coupled
derivation is the only shape not yet refuted.

## The Governing Guidance (cited, not re-derived)

`.claude/context/project/lean4/domain/ladder-counter-observables.md` (deployed; source-store
original at `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
per `.claude/rules/source-store-deploy-boundary.md` — any edit to this guidance must land there,
never at the deployed path) carries, and the new task inherits verbatim:

**The five-part falsification gate** (run BEFORE any sufficiency attempt, each cell a compiled
theorem):

| Gate | Pair | What it probes |
|------|------|----------------|
| 1 | counters `(B, B+1)` vs `(B, B+2)` | mechanism (1): does the candidate keep a small gap apart at large counters? |
| 2 | counters `(2B, 4B+2)` vs `(2B+1, 4B+2)` | mechanism (2): does the candidate keep consecutive countdowns apart? |
| 3 | one region further out, and in the past direction | survives a second region boundary and a `snce`-reachable region start |
| 4 | `(q, T, n)` vs `(q, T+(P+1), n)` at `n = T+(P+1)+B`, under `X^(T+1) r` | mechanism (4): is the threshold at least the formula's `untl`-nesting depth? |
| 5 | on the coprime-cycle object, `(a, 3(P+1)(T+1), n)` vs `(a, 3(P+1)(T+1)+(P+1), n)`, under `p U (r ∧ ℓ_a)` with `⊤ U ℓ_d` in the closure | mechanism (5): is the modulus a multiple of every letter-definable sub-object's period? |

Gates 4 and 5 are refutations of the EXHIBITED parameters, not separations a candidate passes —
775's candidate survived gates 1-3 and died at 4 and 5 because `T` and `P` were taken from the
object alone. "A gate probing one coordinate certifies one coordinate": passing gates 1-3 says
nothing about 4 and 5.

**The parameter-origin rule** (necessary, by refutation; sufficiency OPEN):
- `B` (gap clip) — FORMULA-derived: its `X`-nesting depth (or `|cl φ|`) AND its `snce`-nesting
  depth (the past-direction refinement).
- `T` (threshold) — FORMULA-derived: at least its `untl`-nesting depth. Mechanism (4) refutes
  every threshold fixed independently of the formula.
- `P+1` (modulus) — a multiple of the period of every letter-definable sub-object of the OBJECT,
  coupled to the formula's letters (which sub-objects a formula can carve out depends on which
  letters it forbids). A divisibility condition, not a magnitude one.
- Instantiation convention: `P := m - 1` for modulus `m`, `1 ≤ m`; `2 ≤ m` is forced (at `m=1`
  the index collapses to the already-refuted clipped-coordinate candidate).
- The error this rule exists to prevent: deriving `B` from the counters, or `T`/`P` from the
  object alone.

**The named next candidate**: parameters `(T, P, B)` derived from the object AND the formula
JOINTLY — not yet gated, let alone attempted, by any predecessor.

**The four open proof obligations** a successor positive lemma would meet (named so a future
round does not rediscover them):
1. Eventual periodicity of the realizable types in the countdown, over the product of the object
   with the closure.
2. A region-length pumping lemma for `untl`/`snce`-depth-bounded formulas.
3. The next deadline's coupling through `Drift`.
4. The `box`/`stab` letters through the anchor-layer equations (`box_mem_tpOf_iff`,
   `stab_mem_tpOf_iff`).

**What IS proved positively** is fixture-level only: `qp_cell_eq_of_depth_parity` on the
two-state object, for box/stab-free φ, where every history through a pending state is forced onto
one object path (`qp_forced_path`) — explicitly NOT the factorization lemma, since the general
object has region restarts and its histories through a pending state do not share an object path.

**What is NOT in question**: the SET of cells of any regular ℤ-model is finite and bounded
(`anchorCells_finite`, `anchorCells_ncard_le : ≤ 2^(2^|cl φ|)`, `RaySummary/AnchorLayer.lean`),
untouched by any of the above.

## Precedent Outcomes

- **773** (`specs/archive/773_ladder_cell_index_factorization/`) — refuted its filed
  gap-carrying target, then defined and gated the residue-carrying successor. ~1.6h actual
  against a 9.5h estimate. Closed `[COMPLETED]` on a refutation stated as the deliberate, named
  outcome.
- **775** (`specs/archive/775_residue_index_factorization_lemma/`) — refuted the residue
  candidate at both object-exhibited parameters (mechanisms 4, 5), delivered the fifteenth wired
  evidence probe (`ladder-residue-index-refutation.lean`, 1549 lines, 0 sorry, 0 axiom, no
  `native_decide`), plus the fixture-level sufficiency theorem `qp_cell_eq_of_depth_parity`
  explicitly not the factorization lemma. ~1h actual against a 9h estimate. Closed `[COMPLETED]`.
- Both precedents ran on the `/orchestrate --research`-first, verdict-first posture that `559`
  (active, `researched`) models: reports and sorry-free probe files under the task's own
  directory only; no `FormalSystem/`/`Tests/` edits.

## What a first round should do, in order

1. Correct or delete `specs/761_ladder_realization_theorem/.blocker-research.json` (stale;
   recommends a refuted candidate) — in scope because it lives under 761's own directory and this
   record updates 761's status.
2. Define the jointly-derived candidate: `B := max (X-nesting depth of φ) (snce-nesting depth of
   φ)` (or `|cl φ|`, whichever the probe's existing helpers already compute); `T := ` at least
   the `untl`-nesting depth of φ; `P+1 := ` a multiple of the period of every letter-definable
   sub-object of the given ladder object, reachable via a letter-restricted variant of
   `reachN_eventually_periodic` (`specs/archive/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`,
   landed as part of the fourteenth probe).
3. Run the five-part gate above as compiled theorems, gates 4 and 5 specifically rebuilt against
   the FORMULA-derived `T`, `B` (not object-exhibited), before any sufficiency attempt.
4. Report the verdict — survive or refute — as the deliverable. A refutation is an acceptable and
   explicitly successful outcome, exactly as 773 and 775 record it; it must not be followed by a
   weakened same-named substitute for `ladderRealized` or `LadderCons`.
5. If the gate is survived, attempt the positive factorization lemma carrying the four open
   obligations verbatim; if not costable within this round, name the obligations as the next
   round's scope rather than attempting a shortcut.

## Proposed New Tasks

### New Item 0: Gate and attempt the formula-coupled residue index against the five-part falsification table
- **Effort**: ~3-5 hours for the correction + gate run + report (precedents closed in ~1-1.6h
  against ~9h filed estimates); the positive sufficiency attempt beyond a survived gate is NOT
  costable and may be deferred to a successor record.
- **Task Type**: lean4
- **Rationale**: This is the one candidate shape the governing guidance names as ungated — every
  prior candidate (counter-pair, gap-carrying, residue-at-object-exhibited-parameters) is refuted
  on compiled ground. Running the five-part gate first, against formula-derived `T` and `B`
  rather than object-exhibited ones, is the cheapest next falsification/survival test and is what
  773 and 775's own closing records name as the open next step.
- **Depends on**: None (research-first; no predecessor task is a prerequisite — 773 and 775 are
  both archived and their declarations are already landed artifacts this task reads from, not
  waits on).

## Dependency Reasoning

- **Single task, no internal dependencies**: the task is one coherent unit of work (correct the
  stale artifact, define the candidate, run the gate, report the verdict) matching the cadence
  773 and 775 each ran as one task. Splitting the gate run from the candidate definition would
  separate two steps whose implementation details are inseparable — the gate pairs in rows 4 and
  5 are stated IN TERMS OF the candidate's `T`, `P`, `B`, so there is no independent order in
  which to do them.
- **No dependency on 773 or 775**: both are terminal (`[COMPLETED]`, archived); their
  declarations (`reachN_eventually_periodic`, `ladderIndexRes`, the five mechanisms) are already
  landed, compiled artifacts this task reads and ports from, not work this task's own
  implementer needs to redo or wait on.

## File Footprint Overlap Check (Component 4a)

N/A — a single proposed task has no sibling in `new_tasks[]` to overlap with; the pairwise
overlap algorithm has nothing to compare.

## After Completion

Once the spawned task is complete, resume task #761 with `/implement 761`.

The blocker will be resolved — or narrowed to a named, gated OPEN candidate with its four proof
obligations — because: a refutation of the formula-coupled candidate would complete the
falsification of every index shape the governing guidance currently anticipates, forcing the
successor direction already on record (a set-valued per-state datum over a quotient, not a wider
tuple) into the next `/spawn` round; a survival of the gate would, for the first time, license an
actual sufficiency attempt at the factorization lemma, which is the one remaining prerequisite
`ladderRealized` and `LadderCons`'s `box`/`stab` clause both need before they can be STATED.
