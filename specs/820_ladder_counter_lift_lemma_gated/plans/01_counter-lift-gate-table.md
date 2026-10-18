# Implementation Plan: Task #820

- **Task**: 820 - Ladder counter-lift lemma, research-first, gated
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: None (parent record: task 761, which this task gates; 763 waits on 761)
- **Research Inputs**: specs/820_ladder_counter_lift_lemma_gated/reports/01_counter-lift-lemma-gated.md
- **Artifacts**: plans/01_counter-lift-gate-table.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round turned the three derived arithmetic items into theorems (a 544-line, 0-sorry
prototype under this task's directory), refuted the dispatch's positionwise completeness clause
for every finite counter quotient (`no_positionwise_lift`, compiled), replaced it for planning
purposes by the pumping form, reduced the lift to the pin lemma, assessed both hazards as the pin
cascade (absorbed) and the exponential-threshold fact (a parameter-size output), and DESIGNED the
gate table on a 4-cycle fixture with expected verdicts and compiled ground. Nothing was RUN at the
model layer. This plan runs it: promote the prototype into the wired evidence probe
`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` (the task's own `file_scope`),
build the 4-cycle fixture at the model layer, compile the gate rows in the research's order
(cheapest and most decisive first: 1, 2, 9-separation, short-idle, 9-collision, gap-shift), then
compile the pin lemma's lift half (the 1-Lipschitz extension with pins) as the first generic
target after the gates, and close by recording the verdicts in the probe header, the evidence
guard, the README, the ROADMAP and the source-store context file.

Definition of done: every gate row of the research's Appendix A carries a COMPILED verdict
(SEPARATION or COLLISION, each a theorem in the wired probe, or a compiled refutation with the
obstruction exhibited), the probe is wired and green under `scripts/check-evidence-probes.sh`,
`no_positionwise_lift` is promoted so the statement-shape reason cannot rot, the lift half of the
pin lemma is a theorem, and the records say exactly what was compiled and what was not. The
counter-lift lemma itself ((S)/(C') in pumping form, with `K`'s parameters as outputs) is NOT
proved here: a green gate table LICENSES its two halves for the successor record (the ladder
realization theorem), and a compiled refutation at either decision gate (Phases 6, 7) CLOSES the
ladder route; the dispatch sizes the lemma by an open problem and this plan invents no figure for
it. The 16 hours above cost the gate table and the lift half, which are proof work with known
shapes, and nothing else.

### Research Integration

From `reports/01_counter-lift-lemma-gated.md`:
- Finding 1 (compiled): no positionwise lift for any finite `K` and any sound local `R`. The
  plan's Challenge statements therefore carry NO positionwise completeness clause; the pumping
  form (C') is recorded in the probe header as the licensed shape, not pinned as a theorem.
- Finding 2 (derived): the pin lemma. Soundness half = the three compiled items; lift half = a
  1-Lipschitz (McShane) extension on `ℤ` through the idle-end pins. Phase 8 compiles the lift
  half as two generic theorems (`drift_extension_of_pins`, `exists_rlad_hist_of_walk`).
- Finding 3 (derived): the gap-shift hazard is the pin cascade, terminating at an absorbing idle
  run or a pending-forever past; the short-idle hazard is the exponential-threshold fact
  (`iter_doubling` with `J = 1`). Phases 5 and 7 run these as gates with the expected verdicts
  COLLISION (gap-shift) and SEPARATION-for-every-small-threshold (short-idle).
- Finding 4 (derived): `K`'s six-coordinate shape is confirmed, two coordinates conditional on a
  third. No tuple index is stated anywhere in this plan; where a class-collision statement is
  needed (Phase 5) it is stated on the index BODY as a shape, exactly as `nside_collides` does.
- Appendix A: the gate table with the fixture `Q4 := Bool × Fin 4`, pairs, formulas, expected
  verdicts and compiled ground. Phases 3-7 are its rows in the recommended order.
- Recommendations 1-7 are followed one-for-one: restate in pumping form (header, Phase 1 and 9);
  promote the prototype (Phase 1); 4-cycle fixture (Phase 2); gate order (Phases 3-7); lift half
  after the gates (Phase 8); honest hazard verdicts with the negative branch live (Phases 6-7,
  Rollback/Contingency); no tuple index, parameters as outputs, context file updated at the
  source-store path (Phase 9).
- Tactic survey carried: `omega`/`norm_num` available under the `RunLayer` import, `ring`/
  `nlinarith` not; `Mathlib.Data.Fintype.Pigeonhole` imported explicitly for
  `Finite.exists_ne_map_eq_of_infinite`; `set … with h` then `clear_value` before `simp`; explicit
  `if_pos`/`if_neg` rewrites over `simp` arithmetic normalisation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` "Run these next" lists this task first and names it the gate on 761 ("a
refutation there closes the ladder route"); Stage 1's adequacy bullet names the two hazards as
this task's first gates. This plan advances exactly that item. The ROADMAP edit itself is
implementation work (Phase 9, `file_scope`), never done by the planner.

## Goals & Non-Goals

**Goals**:
- `forward_window` — the forward window, promoted into the wired probe unchanged in statement.
- `backward_constraint` — the backward constraint with the region-start pin, promoted unchanged.
- `region_doubling` — the region-doubling inequality, promoted unchanged.
- `iter_doubling` — the iterated doubling bound, promoted unchanged.
- `no_positionwise_lift` — the statement-shape refutation, promoted with its two auxiliary
  definitions inlined so the pinned statement is self-contained.
- `drift_extension_of_pins` — a 1-Lipschitz function on the integers through any pairwise
  compatible family of pins (the McShane extension, clamped at zero).
- `exists_rlad_hist_of_walk` — the pin lemma's lift half: an object walk with its forced
  countdown and pairwise compatible idle-end pins, plus a deadline at position zero compatible
  with every pin, is the object projection of a ladder history through that deadline.

**Non-Goals**:
- The counter-lift lemma (S)/(C') itself, `LadderCons`, `ladderRealized`, the factorization
  lemma for `K`, `K`'s parameters `(T, P, B)` as exhibited values, `certStab` per `(q, κ)`
  (obligation (4)), or any statement mentioning `HitPresented` or `PlusValidZTime`.
- A tuple index stated as a candidate at any parameters (hard constraint). Phase 5's
  class-collision companion is a statement on the index body as a SHAPE, in the sense and the
  wording of `nside-modulus-gate.lean`'s header, and the probe header says so.
- A seventh coordinate; any complexity claim or upper bound (every quantity is a count); any
  finiteness added (`anchorCells_finite`, `anchorCells_ncard_le` untouched); dropping the
  `box`/`stab` acceptance clause from any statement sketched; any Buchi/MSO lemma cited in place
  of a proof (zero debt); Route A.
- Gate 8 (SIDESTEPPED: no `stab` member in any closure below) and gate 3 (CARRIED) — unchanged.
- Any edit under `FormalSystem/` other than `RaySummary/README.md`; any edit to the deployed
  mirror `.claude/context/project/lean4/domain/ladder-counter-observables.md` (the source-store
  path is edited instead).

**Fixture-level gate theorems (not Challenge-pinned)**: the gate rows are closure-specific cell
inequalities and equalities over the model-layer fixture of Phase 2, whose definitions a
standalone Challenge module cannot carry (the snapshot tool forces every declaration body to
`sorry`, fixture definitions included). Their intended statements are recorded per phase below
under "Target statement"; the plan-compliance rule's statement-fidelity obligation applies to
them by name and shape as written there, and any weakening is escalated, never substituted.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A decision gate (Phase 6 or 7) compiles as a REFUTATION: the expected cell equality fails and an inequality compiles | the ladder route closes for both presentations | L | This is a complete result, not a failure: before declaring a mechanism, check the pair against a larger modulus (8) and a larger threshold on the fixture (Phase 6/7 contingency tasks); if resistant to every `K` of the forced shape, record `[BLOCKED]`-to-closed with the obstruction compiled (Phase 9, negative branch), never a weakened same-named substitute |
| The cell EQUALITIES (Phases 6, 7) are too expensive at probe level: the cell is not a singleton on `Q4` (the pending walk is deterministic but idle runs and region lengths are free), so `cellAt_eq_singleton` does not apply | the two expensive rows overrun | M | State each equality closure-specifically; prove both inclusions by per-member truth lemmas showing each closure member's truth at position 0 is a function of a finite datum (next region's end index; previous idle run's length; start letter) and that the datum sets achievable from the two states coincide, via explicit pumped histories built with `hist_of_path4`; escalate as `[PARTIAL]` with the compiled half recorded if the budget is exceeded — never weaken the statement under its name |
| The short-idle family `ψ_k` for general `k` needs a recursive formula and an induction over `k` that does not fit one phase | the exponential-in-depth claim stays at the arithmetic level | M | Phase 5 REQUIRES the `k = 1` instance (the mechanism, with the class-collision companion) and treats the family as a scoped stretch with an explicit outcome line in the header: "compiled at `k = 1`" or "family compiled"; the exponential claim is then carried by `iter_doubling` plus the instance, and the header says exactly that |
| The semantic periodicity assumption (types along a long region are `P`-periodic in the countdown) fails on `Q4` for the closures chosen | the pumping constructions of Phases 6-7 break | L | The 4-cycle fixture's pending walk is deterministic with period 4, so pumping a region by 4 preserves every letter sequence; both gates exercise this on the fixture before any general attempt, which is the point of running them first |
| `Classical.choice` in the axiom foot read as a defect | none | L | It enters through `omega` on `Int`; the header records the per-theorem axiom profile (the prototype's `#print axioms` lines are carried over and re-checked) |
| Fixture seriality (`fwd4`/`bwd4`) and the sliced-path bridge (`hist_path4`/`hist_of_path4`) cost more than expected on a 4-cycle object | Phase 2 overruns | L | Copy the shape of `fwd5`/`bwd5`/`hist_path5`/`hist_of_path5` from `ladder-residue-index-refutation.lean` (same `Bool × Fin 4` carrier type, different step relation); every edge of `step4` is decided by `decide` |
| README / ROADMAP / context-file edits cite a task number | violates `no-task-references-in-deliverables` (README and the context file are deliverables) | M | Cite the probe filename and theorem names as the durable anchors; task numbers only inside `specs/**` (ROADMAP is exempt) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. The chain is fully sequential by design:
Phases 1-8 all edit the single probe file, and the research's gate order (cheapest and most
decisive first) is itself a dependency — a refutation at an early row changes what the later
rows must say.

### Phase 1: Promote the Prototype into the Wired Probe [COMPLETED]

**Goal**: The research-level prototype becomes the arithmetic layer of the wired evidence probe
`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`, guarded by
`scripts/check-evidence-probes.sh`, so that `no_positionwise_lift` and the three compiled items
cannot rot.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` from
      `specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean`:
      namespace `Probe820`, imports `RunLayer` and `Mathlib.Data.Fintype.Pigeonhole` (the
      model-layer imports `AnchorLayer`, `LadderModel` are added in Phase 2), every theorem of
      the prototype carried with statement unchanged (`count_tt/tf/ft/ff`, `drift_step`,
      `drift_ray`, `pin_region_start`, `pin_region_end`, `count_pending_step`,
      `forward_window`, `countdown_back`, `backward_constraint`, `region_doubling`,
      `iter_doubling`, `growRay*`, `doubling_attained`, `drift_hist`, `countdown_of_run`,
      `tightHist*`, `cutChain`, `no_positionwise_lift`).
- [x] Restate `no_positionwise_lift` so its pinned form is self-contained: inline `IsHist` as
      `∀ t, Rlad (Q := Bool) (fun _ _ => true) (fun q => q) t (σ t) (σ (t + 1))` and `proj κ x`
      as `(x.1, κ (x.2.1, x.2.2))` in the STATEMENT (keep the two `def`s for the proof body if
      convenient, but the theorem's signature must match `## Lean Challenge Statements`).
- [x] Write the probe header in the house shape (`no-pending-forever-ray.lean` is the template):
      headline; "What was asked"; "What is settled" (the arithmetic layer, with the per-theorem
      axiom profile); the gate table of the research's Appendix A reproduced with every verdict
      marked `DESIGNED, NOT YET COMPILED` (Phases 3-7 flip each row); the statement in pumping
      form (S)/(C') and the parameter sources (K1)-(K4) recorded verbatim as the LICENSED shape,
      labelled "not a theorem of this file"; "What this does NOT say" (no tuple index at any
      parameters, no seventh coordinate, no bound — every quantity a count, no finiteness added,
      the `box`/`stab` acceptance clause kept, no `LadderCons`/`ladderRealized`/factorization
      lemma under any name, gate 8 SIDESTEPPED, gate 3 CARRIED, zero debt, Route A not entered);
      the compile line.
- [x] Keep the `#print axioms` block at the end of the file (six headline theorems) and extend
      it as later phases add theorems.
- [x] Wire the probe: add `"seam-gluing-ray-product/counter-lift-gates"` to the `WIRED` array of
      `scripts/check-evidence-probes.sh` immediately after the `no-pending-forever-ray` entry,
      and add a decision-row block in the table above the array (same column shape as the
      `no-pending-forever-ray` row) naming the nine arithmetic theorems and stating that the
      gate rows are `DESIGNED` pending Phases 3-7; the row is rewritten in Phase 9 with the final
      verdicts.
- [x] Leave the prototype under the task directory untouched (it is the research record); add
      one line to its header comment pointing at the wired probe as the copy of record.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the prototype carries 23 declarations and six `#print axioms` lines
(carried from the research report's section 2 and Appendix B; `grep -c "^theorem\|^def"` on the
prototype at implementation time confirms the count before the copy).

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
plus `bash scripts/check-evidence-probes.sh` are the complete covering check: the probe lives
outside every Lake target root, the guard script is the only consumer of the new `WIRED` entry,
and nothing under `FormalSystem/` changes.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - new wired probe, arithmetic layer
- `scripts/check-evidence-probes.sh` - `WIRED` entry and decision-row block
- `specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean` - one header line pointing at the wired copy

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` exits 0 with no
  errors; `grep -c sorry` on the probe prints 0.
- The `#print axioms` output matches the research's profile: `forward_window`,
  `backward_constraint`, `region_doubling`, `no_positionwise_lift` on
  `[propext, Classical.choice, Quot.sound]`; `iter_doubling`, `doubling_attained` on
  `[propext, Quot.sound]`.
- `bash scripts/check-evidence-probes.sh` exits 0 and lists the new probe as checked and tracked
  (`git add -- specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` before the run;
  the guard tests `git ls-files`).
- The header's gate table has one row per Appendix A row, every verdict `DESIGNED, NOT YET
  COMPILED`.

---

### Phase 2: The 4-Cycle Fixture at the Model Layer [COMPLETED]

**Goal**: The fixture every gate row needs — the object `Q4`, its admissible ladder frame and
model, the history-to-path bridge, the letter lemmas and the generic history constructors — so
that Phases 3-7 each prove one gate and build no infrastructure.

**Tasks**:
- [x] Add the imports `FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer` and
      `FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`, and `open FormalSystem.Syntax
      FormalSystem.Semantics FormalSystem.PlusLanguage` as the model-layer probes do.
- [x] The object: `abbrev Q4 : Type := Bool × Fin 4`; `pend4 q := q.1`; `step4` with exactly the
      edges `(true, i) → (true, i + 1)`, `(true, i) → (false, i)`, `(false, i) → (false, i)`,
      `(false, i) → (true, i)` (indices mod 4, `Fin 4` arithmetic); `step4_nxt`, `step4_prv`,
      `step4_idle_self`, `step4_idle_start` by `decide`; the seriality witnesses `fwd4`, `bwd4`
      in the shape `ladderFrameAdm` requires (copy `fwd5`/`bwd5` of
      `ladder-residue-index-refutation.lean`, lines near its `F5` definition).
- [x] The letters: atoms `pA` ("p", pending) and `lA i` ("l0".."l3", the index); `lab4 q a`
      reads `q.1` for `pA` and `q.2 = i` for `lA i`; `PlusFormula` abbreviations `p`, `ℓ i`,
      `X χ := .untl .bot χ`, `Y χ := .snce .bot χ`, `neg`, `and` as the other probes write them.
- [x] `F4 := ladderFrameAdm step4 pend4 fwd4 bwd4` with the `IsRegular` instance, `M4 :=
      ladderModel step4 pend4 fwd4 bwd4 lab4`; `st4 (i : Fin 4) (c n : ℕ) : LadderState Q4 pend4`
      (pending), `idl4 (i : Fin 4) (n : ℕ)` (idle, countdown 0); `a4 := st4 0`.
- [x] The bridge: `hist_path4 (σ : WorldHistory F4) : ∃ k g, IsSlicedStepPath (RladAdm step4
      pend4) k g ∧ σ.path = fun t => (t + k, g t)` and `hist_of_path4`, both through
      `ofSlicedStepFinBranch_mem_HF_iff` exactly as `hist_path5`/`hist_of_path5`.
- [x] Letters along a history: `p_at`, `l_at` (`PlusTruthAt`-level membership lemmas reading
      `lab4` through `M4`), by `simp [M4, ladderModel, lab4]`.
- [x] Run lemmas on `Q4`: `pending_walk4` — along a sliced-step path, from `(true, i)` with
      countdown `c` the next `c` positions are pending at indices `i + 1, …, i + c` and position
      `c + 1` is idle at index `i + c` (from `count_pending_step`, `pin_region_end` and
      `step4`'s pending edges; the pending walk is deterministic); `idle_run4` — an idle run
      stays at its index; `region_start4` — the first pending state after an idle run at index
      `i` is `(true, i)` with countdown equal to the idle state's next deadline
      (`pin_region_start`).
- [x] Generic history constructors (each an `IsSlicedStepPath (RladAdm step4 pend4) 0 g` for an
      explicit `g`): `gPast4` — a pending-forever past from any pending state (the backward
      completion; template `gPast_isPath` of `ladder-liveness-forward-only.lean`); `region4 L j`
      — a region of countdown `L` followed by an idle run of length `j` followed by a region of
      any countdown within the forward window, concatenable; `second_region_any_length4` (the
      `Q4` port of `second_region_any_length`). These are the pieces Phases 3-7 glue. *(deviation: altered — `region4 L j` is realized as `region4 i c n j L` (the forced region, an idle run of length `j ≥ 1`, a region of countdown `L` in the window, idle forever) with `region4_rlad` its ray proof and `second_region_any_length4` the realization theorem; concatenation is through the generic `twoRay`/`gPast4` glue rather than a separate `region4`-to-`region4` concatenator, which no gate needs)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: `step4` has exactly 16 edges `= true` (4 indices × 4 edge kinds); the
implementer confirms by `decide` on the enumerated relation before relying on determinism of the
pending walk.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — the only file edited, outside every Lake target root, with no
consumer other than the guard script wired in Phase 1.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - fixture section `/-! ## The 4-cycle fixture -/`

**Verification**:
- The probe compiles (`lake env lean …`, exit 0, 0 sorry).
- `hist_of_path4` applied to `gPast4` yields a `WorldHistory F4` (a non-vacuity check, stated as
  a theorem `exists_hist4`).
- `pending_walk4` is stated for every `i : Fin 4` and every `c`, not for the pair of one gate.

---

### Phase 3: Gates 1 and 2 on the 4-Cycle Fixture [COMPLETED]

**Goal**: The two NOT ADDRESSED rows of the record are compiled on `Q4` as cell inequalities,
each with its compiled ground named: gate 1 (the gap is observable at large counters) and gate 2
(consecutive countdowns are observable through the end letter).

**Target statements**:
- `gate1_cell_ne (B : ℕ) : cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 1)) 0 ≠ cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 2)) 0`
  with `phi1 := p U (¬p ∧ X (p ∧ X ¬p))` — the `Q4` port of `cell_ne`
  (`ladder-cell-refutation.lean`); the witness is a history whose next region has countdown `0`
  after exactly one idle state (`L ≥ n - c - j = 0`), and the obstruction at the second state is
  the forward window's lower edge (`forward_window`: `L ≥ 1`).
- `gate2_cell_ne (c n : ℕ) : cellAt M4 (phi2 c) ((0 : ℤ), st4 0 c n) 0 ≠ cellAt M4 (phi2 c) ((0 : ℤ), st4 0 (c + 1) n) 0`
  with `phi2 c := p U (¬p ∧ ℓ (c mod 4))` — the forced run ends at index `c mod 4`
  (`pending_walk4`, `pin_region_end`) from the first state and at `(c + 1) mod 4` from the
  second.

**Tasks**:
- [x] `phi1`, the per-member truth lemmas for its closure at the two states, `exists_phi1_mem_cell`
      (witness via `hist_of_path4` on an explicit path built from `region4 0 1` glued to
      `gPast4`), `phi1_not_mem_of_mem_cell` (every history through `st4 0 B (B + 2)` has, at the
      first idle state, next deadline `≥ 1` by `drift_ray`, so the next region's countdown is
      `≥ 1` by `pin_region_start`), `gate1_cell_ne`.
- [x] `phi2`, its truth lemmas, `gate2_cell_ne` by the same two-sided pattern, with
      `pending_walk4` supplying the end index on both sides.
- [x] Flip the two header rows to their compiled verdicts (`SEPARATION`, with the theorem names).
- [x] Add both theorems to the `#print axioms` block.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - section `/-! ## Gates 1 and 2 -/`

**Verification**:
- Both theorems compile with the statements above (no added hypothesis, no specialised
  quantifier); the probe compiles, 0 sorry.
- Non-vacuity: `exists_phi1_mem_cell` and its gate-2 twin are stated and compiled BEFORE the
  inequalities (an inequality between empty cells would say nothing).
- Axiom foot at most `[propext, Classical.choice, Quot.sound]` on both.

---

### Phase 4: Gate 9, Separation Half [COMPLETED]

**Goal**: The n-side separation at `c = 0, j = 1`: on a fixture of product period 4 the forward
window `{n - 1, n, n + 1}` covers three of four residues, so a shift `m` with `4 ∤ m` is
observable — which, together with the already-compiled index-level collision `nside_collides`,
decides that `K`'s `n`-modulus must be a multiple of the product period.

**Target statement**:
- `gate9_sep_cell_ne (n m : ℕ) (hn : 1 ≤ n) (hm : ¬ 4 ∣ m) : cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 n) 0 ≠ cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 (n + m)) 0`
  with `phi9 n := X (¬p ∧ X (p ∧ (p U (¬p ∧ ℓ ((n + 2) mod 4)))))`: from `(a, 0, n)` the next
  region's countdown lies in `{n - 1, n, n + 1}` (`forward_window` at `c = 0`, `j = 1`) so its
  end index is never `(n + 2) mod 4`; from `(a, 0, n + m)` with `4 ∤ m` one of
  `{n + m - 1, n + m, n + m + 1}` is `≡ n + 2 (mod 4)`.

**Tasks**:
- [x] `phi9`, its closure's truth lemmas at position 0 (the three nested `X`/`U` members, each a
      function of the next region's end index), the witness history at `(a, 0, n + m)` (choose
      the countdown in the window with the right residue; `region4` and `gPast4`), the
      obstruction at `(a, 0, n)` (`forward_window`, `pending_walk4`, a `Fin 4` residue case
      split by `omega`/`decide`), `gate9_sep_cell_ne`.
- [x] Record in the header that the index-level collision half is `nside_collides`
      (`nside-modulus-gate.lean`, every `(T, P, B)` with modulus `P + 1`) and is cited, not
      re-proved; the semantic half decides.
- [x] Flip the 9-sep header row to `SEPARATION`; extend the axiom block.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - section `/-! ## Gate 9, separation -/`

**Verification**:
- `gate9_sep_cell_ne` compiles with the statement above; the hypothesis `¬ 4 ∣ m` is the ONLY
  arithmetic hypothesis on `m` (a proof needing `m < 4` or `m` odd has specialised the gate and
  must be escalated, not accepted).
- Non-vacuity witness compiled first; probe compiles, 0 sorry.

---

### Phase 5: The Short-Idle Gate (Exponential Threshold) [COMPLETED]

**Goal**: The short-idle hazard run as a gate in the shape the research found it to have: a
formula pinning a rigid past (idle forever, one pending state, idle runs of length 1) bounds the
current region's countdown, so every `K` whose countdown threshold is at most that bound
identifies two states with different cells — the threshold is a cascade OUTPUT, not a
formula-depth guess. The `k = 1` instance is required; the family is a scoped stretch.

**Target statements**:
- `short_idle_cell_ne (P : ℕ) (hP : 1 ≤ P) : cellAt M4 psi1 ((0 : ℤ), st4 0 2 2) 0 ≠ cellAt M4 psi1 ((0 : ℤ), st4 0 (2 + P) (2 + P)) 0`
  with `psi1 := p ∧ Y (¬p ∧ Y (p ∧ Y (¬p ∧ ¬(⊤ S p))))` (the current region starts now; the
  previous idle run has length 1; before it a single pending state; before that idle forever):
  realized at `(a, 2, 2)` by the maximal-growth walk (`doubling_attained` at `L = 0`: countdown
  `2` after one idle state), and at no history through `(a, 2 + P, 2 + P)` because
  `region_doubling` with `L = 0`, `j = 1` bounds the countdown at the region start by `2`.
- `short_idle_shape_collides (T P B : ℕ) (hT : T ≤ 2) (hT' : T ≤ 2) : ` the six-coordinate SHAPE
  `(min c T, c mod P', min n T, n mod P', clip (n - c))` agrees on the pair for every modulus
  `P' = P + 1` dividing `P` — stated on the index body `ladderIndexJnt` ported from
  `nside-modulus-gate.lean` in that probe's own sense (a shape gated for a carrier coordinate,
  not an index revived), so the pair is a same-class pair for every `K` of the forced shape with
  threshold `≤ 2`.
- Stretch (family): `psi : ℕ → PlusFormula` by recursion (`psi 0 := p ∧ Y (¬p ∧ ¬(⊤ S p))`,
  `psi (k + 1) := p ∧ Y (¬p ∧ (p S (¬p ∧ Y (psi k))))`-shaped, exact clauses to be fixed at
  implementation), with `short_idle_family_cell_ne (k P : ℕ) (hP : 1 ≤ P) :` the pair
  `(a, 2^(k+1) - 2, ·)` vs `(a, 2^(k+1) - 2 + P, ·)` separated — the bound is COMPUTED by
  `iter_doubling` with `J = 1` on the fixture before the pair is written down, never read off the
  research's prose (whose `2^k - 2` counts regions from a different base).

**Tasks**:
- [x] Compute the bound by hand on `Q4` first: first region countdown `0`, idle run `1`, then
      `region_doubling` gives `L₁ ≤ 2`, attained by `doubling_attained`; write the pair from that
      computation and record the computation in the header (this is "computed, not guessed").
- [x] `psi1`, its truth lemmas (the `Y`/`S` members are functions of the three positions before
      0 and of "idle forever before"), the witness history (`growRay`-shaped on `Q4`:
      `gIdleForever4` then one pending state then one idle then the region), the obstruction
      (`backward_constraint` and `region_doubling` along any history through the second state),
      `short_idle_cell_ne`.
- [x] `ladderIndexJnt` ported with statement unchanged; `short_idle_shape_collides`. *(deviation: altered — the target's duplicated binder `(hT' : T ≤ 2)` is read as the divisibility clause its prose names, `(hP : (P' + 1) ∣ P)`; the literal statement without it is false for `P ≥ 2`; `short_idle_threshold_refuted` added as the conjunction with the cell inequality)*
- [ ] Stretch, time-boxed to the remainder of the phase: `psi k`, its truth lemmas by induction,
      `short_idle_family_cell_ne`. *(deviation: skipped — the time-boxed stretch was not taken; the header row reads `SEPARATION (compiled at k = 1; family at the arithmetic level by iter_doubling, not compiled)`, one of the two outcomes the plan names)* Outcome recorded either way in the header row: `SEPARATION
      (compiled at k = 1; family compiled)` or `SEPARATION (compiled at k = 1; family at the
      arithmetic level by iter_doubling, not compiled)`.
- [x] Extend the axiom block.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: the fixture bound for the `k = 1` pair is `2` (from `region_doubling` with
`L = 0`, `j = 1`, carried from the research report's Finding 3 and its prototype's
`doubling_attained`); confirmed at implementation time by `#eval`/`decide` on the explicit
maximal-growth path before `psi1` is written.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - section `/-! ## The short-idle gate -/`

**Verification**:
- `short_idle_cell_ne` and `short_idle_shape_collides` compile with the statements above; the
  pair is written from the hand computation recorded in the header.
- The header row states which of the two family outcomes occurred, in those words.
- Probe compiles, 0 sorry; axiom foot at most `[propext, Classical.choice, Quot.sound]`.

---

### Phase 6: Gate 9, Collision Half (Decision Gate) [COMPLETED]

**Goal**: The expected COLLISION at the product period: `(a, 0, n)` and `(a, 0, n + 4)` have
EQUAL cells for the closure of `phi9` — pumping the next region by 4 with `n` raised by 4 from
position 0 onward preserves every closure member's truth at 0, and the closure is `snce`-free so
the past is replaced by a pending-forever past. This is a decision gate: equality licenses the
modulus clause of (K1); a compiled inequality at the product period is a candidate seventh
mechanism and routes to the contingency.

**Target statement**:
- `gate9_col_cell_eq (n : ℕ) (hn : 2 ≤ n) : cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 n) 0 = cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 (n + 4)) 0`
  (the closure of the Phase 4 formula; `hn` keeps the window away from the clip at `0`).

**Tasks**:
- [x] Per-member truth lemmas for `cl (phi9 n)` at position 0 as functions of a finite datum
      `d := (next region's end index)` — the only thing the closure sees from position 0 (every
      member is an `X`/`U` nest over `p` and one `ℓ`); state `tpOf_eq_of_datum`: two histories
      through pending states with countdown 0 and equal data have equal types at 0.
- [x] The datum sets: `datum_achievable (a, 0, n) = {(n - 1) mod 4, n mod 4, (n + 1) mod 4}` as
      a set equality (both inclusions: `forward_window` for `⊆`, `region4`/`second_region_any_length4`
      with `gPast4` for `⊇`), and the same set at `n + 4`.
- [x] `gate9_col_cell_eq` from the two: every type in one cell is `tpOf` of a history whose datum
      is achievable from the other state, hence (by `tpOf_eq_of_datum` and a history built from
      the constructors) in the other cell; both inclusions, `Set.ext`.
- [x] Contingency check, run ONLY if the equality cannot be closed and an inequality compiles
      instead *(not applicable: the equality closed, `gate9_col_cell_eq`; no modulus-8 check was needed)*: state the same pair at modulus 8 (`n + 8`) and with the clip raised; if equality
      is restored the row reads `COLLISION at a multiple of the product period, the modulus
      clause sharpened` (not a mechanism); if no multiple restores it, compile the inequality as
      `gate9_col_refuted`, mark this phase `[BLOCKED]`, and take the negative branch (Phase 9).
- [x] Flip the 9-col header row; extend the axiom block.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - section `/-! ## Gate 9, collision -/`

**Verification**:
- `gate9_col_cell_eq` compiles with the statement above — an EQUALITY of `cellAt` values, never
  a subset, never a statement about one type; or the contingency's compiled refutation with the
  phase marked `[BLOCKED]`.
- `datum_achievable` is a two-sided set equality, so the collision does not rest on an
  under-approximation of either cell.
- Probe compiles, 0 sorry.

---

### Phase 7: The Gap-Shift Gate (Decision Gate) [NOT STARTED]

**Goal**: The gap-shift hazard run as a gate: with a closure carrying a `snce` member that reads
the region start's letter and one that pins the previous idle run's length, the pair `(a, c, n)`
vs `(a, c + 4, n + 4)` (same clipped gap, `c` beyond a fixture threshold) has EQUAL cells — the
pin cascade terminates with the absorber exhibited (the previous idle run is pinned to length 1,
so the previous region's saturated zone absorbs, else the previous region is lengthened by 4 and
the idle run before it, which the closure does not see, absorbs). Equality licenses the cascade
reading of Finding 3; a resistant inequality is the other candidate seventh mechanism.

**Target statement**:
- `gap_shift_cell_eq (c n : ℕ) (hc : T₀ ≤ c) (hn : n = c + g₀) : cellAt M4 chi ((0 : ℤ), st4 0 c n) 0 = cellAt M4 chi ((0 : ℤ), st4 0 (c + 4) (n + 4)) 0`
  with `chi := (p S (ℓ i₀ ∧ Y ¬p)) ∧ (p S (¬p ∧ Y p)) ∧ (p U (¬p ∧ X (p ∧ ℓ j₀)))` (region
  started at letter `ℓ i₀`; previous idle run of length exactly 1; next region starts at letter
  `ℓ j₀`), where `T₀` is the fixture threshold COMPUTED in the first task below and `g₀` a fixed
  gap inside the clip (the exact `i₀`, `j₀`, `g₀` are fixed at implementation so that both states
  are realizable — non-vacuity first). The hypothesis set may be adjusted ONLY to keep the pair
  realizable and the gap equal; `c` and `c + 4` with `n` and `n + 4` is the pair, unchanged.

**Tasks**:
- [ ] Compute `T₀` on `Q4` by hand from the cascade: the current region's start pin is `c + s`;
      with the previous idle run pinned at length 1 and the previous region free, the absorber
      is the previous region's saturated zone when `c + 4 ≤ 2 L_prev + 2` (`region_doubling`),
      else the previous region lengthened by 4 with the idle run before it (unseen by `chi`)
      lengthened by 4; record the computation and `T₀` in the header (a count).
- [ ] Non-vacuity: explicit histories through both states realizing a type containing `chi`
      (`hist_of_path4` on paths glued from `gPast4`, `region4`, an idle run of length 1, the
      current region, and a free future).
- [ ] Per-member truth lemmas for `cl chi` at position 0 as functions of the finite datum
      (start letter, previous idle run length `= 1`, next region's start letter — the last is
      always `ℓ (end index)`, read through `pending_walk4`); `tpOf_eq_of_datum'`.
- [ ] The datum sets achievable from the two states coincide: the `⊆` direction by the pins
      (`backward_constraint`, `region_doubling`, `forward_window`), the `⊇` direction by the
      pumped histories — the current region lengthened by 4 at its start (letter unchanged mod
      4), `n` raised by 4 from the previous idle run onward, the previous region lengthened by 4
      when its slack is exhausted, the idle run before it lengthened by 4, every later region
      lengthened by 4 (pumped in step; the forward cascade of Phase 6).
- [ ] `gap_shift_cell_eq`; the absorber exhibited as its own lemma `absorber4` (the lengthened
      previous region / idle run is an `IsSlicedStepPath`), so the header can point at it.
- [ ] Contingency, as in Phase 6: if an inequality compiles instead, try modulus 8 and a larger
      `T₀`; if resistant, compile `gap_shift_refuted`, mark `[BLOCKED]`, take the negative branch.
- [ ] Flip the gap-shift header row; extend the axiom block.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: the cascade on this closure terminates at depth 2 (previous region, then
the idle run before it), so `T₀` is a small count derived from one application of
`region_doubling`; confirmed at implementation by the hand computation recorded in the header
before `chi` is fixed.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - section `/-! ## The gap-shift gate -/`

**Verification**:
- `gap_shift_cell_eq` compiles as an EQUALITY of cells on the pair `(c, n)`/`(c + 4, n + 4)`, or
  the contingency's compiled refutation with `[BLOCKED]`.
- Both non-vacuity witnesses compiled before the equality; `absorber4` compiled and named in the
  header row.
- Probe compiles, 0 sorry.

---

### Phase 8: The Pin Lemma's Lift Half [NOT STARTED]

**Goal**: The first generic target after the gates: a 1-Lipschitz deadline function through any
pairwise compatible family of pins, and the lift of an object walk with its forced countdown to a
ladder history — what makes (C') a chain-replacement argument rather than a counter argument.

**Target statements**: exactly the two signatures `drift_extension_of_pins` and
`exists_rlad_hist_of_walk` under `## Lean Challenge Statements` (generic in `Q`, `step`, `pend`;
placed in the probe's `Generic` section, not under `FormalSystem/` — moving them into
`RunLayer.lean` is a successor's choice, outside this task's `file_scope`).

**Tasks**:
- [ ] `drift_extension_of_pins`: the McShane extension `n t := ` the least `a + |t - s|` over
      pins `(s, a)` (as a `Nat.find` over the nonempty set, or `0` when there is no pin —
      case split on `∃ s a, pin s = some a`); 1-Lipschitz by the triangle inequality on
      `natAbs`; through every pin by compatibility. `omega` on `Int` for the inequalities.
- [ ] `exists_rlad_hist_of_walk`: define `pin t := some (c (t + 1))` at idle ends, `some n₀` at
      `0` (consistent with an idle end at `0` by `hn₀`), `none` elsewhere; apply the extension;
      check the four conjuncts of `Rlad` per step by the letter case split (`count_tt/tf/ft/ff`),
      with `n 0 = n₀`.
- [ ] Header: the pin lemma stated once (soundness half = `forward_window`,
      `backward_constraint`, `region_doubling`; lift half = these two theorems), and the
      remark that this is where the lift's counter argument ends and the chain-replacement
      argument of (C') begins.
- [ ] Extend the axiom block with both.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
is the complete covering check — single file, outside every Lake target root.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - `Generic` section, `/-! ### The pin lemma, lift half -/`

**Verification**:
- Both theorems compile with the pinned signatures (checked against `## Lean Challenge
  Statements` by `bash .claude/scripts/lean-challenge-snapshot.sh --check`, advisory).
- Probe compiles, 0 sorry; axiom foot at most `[propext, Classical.choice, Quot.sound]`.

---

### Phase 9: Records — Header, Guard, README, ROADMAP, Context File [NOT STARTED]

**Goal**: Every record says exactly what was compiled: the probe header's gate table carries only
compiled verdicts, the evidence guard's decision row names them, the RaySummary README's (W)
narrative and the ROADMAP's "Run these next"/Stage 1 text reflect the outcome, and the
source-store context file gains the pin lemma, the positionwise-lift impossibility and the third
parameter source. Either outcome branch is recorded honestly.

**Tasks**:
- [ ] Probe header: final gate table (every row `SEPARATION`/`COLLISION` with theorem names, or
      `REFUTED` with the compiled obstruction), the (S)/(C') statement and (K1)-(K4) left as the
      LICENSED shape (positive branch) or struck as closed (negative branch), the "does NOT say"
      list re-checked against the hard constraints, the per-theorem axiom profile from the final
      `#print axioms` run.
- [ ] `scripts/check-evidence-probes.sh`: rewrite the Phase 1 decision-row block with the final
      verdicts and the decision it holds in place (positive: the counter-lift lemma's two halves
      are licensed in pumping form with parameters as outputs; negative: the ladder route is
      closed on the compiled obstruction, named).
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: extend the (W) paragraph that
      cites `no-pending-forever-ray.lean` (near the end of the file) with one paragraph citing
      `counter-lift-gates.lean` by filename and theorem names — the positionwise lift refuted,
      the pumping form, the gate verdicts, the pin lemma — with NO task number (deliverable
      file; cite the probe, not the task) and no draft-history wording.
- [ ] `specs/ROADMAP.md`: "Run these next" — drop the `/orchestrate 820` line and un-gate 761
      (positive) or replace both with the closed-route note (negative); Stage 1's adequacy
      bullet — the two hazards now carry compiled verdicts; the "761 waits on 820" sentence
      updated accordingly. Task numbers are permitted here (`specs/**`).
- [ ] Context file at the SOURCE-STORE path
      `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
      (never the deployed mirror): a "What the counters constrain" item (the pin lemma, both
      halves, by theorem name); one paragraph beside the parameter-origin rule citing
      `no_positionwise_lift` and naming the pumping form as the shape of the completeness clause;
      the third parameter source (K2, the cascade bound, `iter_doubling` its arithmetic) added to
      the rule's list with the "carrier coordinate vs index" distinction. No task numbers.
- [ ] Issue log: record the gate outcomes (`win` per compiled row, `issue` per contingency taken)
      with `issue-record.sh` as they land, not reconstructed here.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` - final header
- `scripts/check-evidence-probes.sh` - final decision row
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - (W) paragraph
- `specs/ROADMAP.md` - "Run these next", Stage 1 adequacy and 761 bullets
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` - pin lemma, positionwise-lift paragraph, third parameter source

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` (the complete gate set) exits 0.
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe checked and tracked.
- `bash scripts/check-module-invariants.sh` exits 0 (the README edit touches no module table
  figure).
- `bash .claude/scripts/check-task-references.sh` reports no new occurrence in the README or
  the context file.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` reports no drift on the seven
  pinned identifiers (advisory; a drift finding is investigated, never silently accepted).
- The final `#print axioms` output is pasted into the header and matches the per-theorem
  profile stated there.

## Lean Challenge Statements

Seven generic declarations, every body `sorry`, importing `RunLayer` and the pigeonhole module
only: the four arithmetic items promoted unchanged from the research prototype (`forward_window`,
`backward_constraint`, `region_doubling`, `iter_doubling`), the statement-shape refutation with
its two auxiliary definitions inlined (`no_positionwise_lift`), and the pin lemma's lift half
(`drift_extension_of_pins`, `exists_rlad_hist_of_walk`). No positionwise completeness clause is
pinned anywhere, per the research's Recommendation 1. The fixture-level gate theorems are not
pinned here (see "Fixture-level gate theorems" under Goals & Non-Goals). The block was compiled
standalone at plan-authoring time with `lake env lean` (see the plan's Testing & Validation).

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import Mathlib.Data.Fintype.Pigeonhole

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe820

section Generic

variable {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)

theorem forward_window (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1)))
    (j : ℕ) (hidle : pend (f ((f 0).2.1 + j)).1 = false)
    (hnext : pend (f ((f 0).2.1 + j + 1)).1 = true) :
    (f ((f 0).2.1 + j + 1)).2.1 = (f ((f 0).2.1 + j)).2.2 ∧
      (f ((f 0).2.1 + j + 1)).2.1 ≤ (f 0).2.2 + ((f 0).2.1 + j) ∧
      (f 0).2.2 ≤ (f ((f 0).2.1 + j + 1)).2.1 + ((f 0).2.1 + j) := sorry

theorem backward_constraint (x : ℕ → Q × ℕ × ℕ) (hx : ∀ i, Rlad step pend t (x (i + 1)) (x i))
    (s : ℕ) (hp : ∀ i, i ≤ s → pend (x i).1 = true) (hs : pend (x (s + 1)).1 = false) :
    (x (s + 1)).2.2 = (x 0).2.1 + s ∧
      (x 0).2.1 ≤ (x 0).2.2 + 1 ∧ (x 0).2.2 ≤ (x 0).2.1 + 2 * s + 1 := sorry

theorem region_doubling (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1)))
    (h0 : pend (f 0).1 = false) (h1 : pend (f 1).1 = true) (j : ℕ)
    (hidle : pend (f ((f 0).2.2 + 1 + j)).1 = false)
    (hnext : pend (f ((f 0).2.2 + 1 + j + 1)).1 = true) :
    (f 1).2.1 = (f 0).2.2 ∧
      (f ((f 0).2.2 + 1 + j + 1)).2.1 = (f ((f 0).2.2 + 1 + j)).2.2 ∧
      (f ((f 0).2.2 + 1 + j + 1)).2.1 ≤ 2 * (f 0).2.2 + j + 1 ∧
      (f 0).2.2 ≤ (f ((f 0).2.2 + 1 + j + 1)).2.1 + (f 0).2.2 + j + 1 := sorry

theorem iter_doubling (a : ℕ → ℕ) (J : ℕ) (h : ∀ k, a (k + 1) ≤ 2 * a k + J + 1) :
    ∀ k, a k + J + 1 ≤ 2 ^ k * (a 0 + J + 1) := sorry

theorem drift_extension_of_pins (pin : ℤ → Option ℕ)
    (hcompat : ∀ s t a b, pin s = some a → pin t = some b →
      ((a : ℤ) - b).natAbs ≤ (s - t).natAbs) :
    ∃ n : ℤ → ℕ, (∀ t, Drift (n t) (n (t + 1))) ∧ ∀ t a, pin t = some a → n t = a := sorry

theorem exists_rlad_hist_of_walk (w : ℤ → Q) (c : ℤ → ℕ) (n₀ : ℕ)
    (hw : ∀ t, step (w t) (w (t + 1)) = true)
    (hidle : ∀ t, pend (w t) = false → c t = 0)
    (hpp : ∀ t, pend (w t) = true → pend (w (t + 1)) = true → c (t + 1) + 1 = c t)
    (hpi : ∀ t, pend (w t) = true → pend (w (t + 1)) = false → c t = 0)
    (hpins : ∀ s t, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w t) = false → pend (w (t + 1)) = true →
      ((c (s + 1) : ℤ) - c (t + 1)).natAbs ≤ (s - t).natAbs)
    (hn₀ : ∀ t, pend (w t) = false → pend (w (t + 1)) = true →
      ((c (t + 1) : ℤ) - n₀).natAbs ≤ t.natAbs) :
    ∃ n : ℤ → ℕ, n 0 = n₀ ∧
      ∀ t', Rlad step pend t (w t', c t', n t') (w (t' + 1), c (t' + 1), n (t' + 1)) := sorry

end Generic

theorem no_positionwise_lift {K : Type} [Finite K] (κ : ℕ × ℕ → K)
    (R : Bool × K → Bool × K → Prop)
    (sound : ∀ σ : ℤ → Bool × ℕ × ℕ,
      (∀ t, Rlad (Q := Bool) (fun _ _ => true) (fun q => q) t (σ t) (σ (t + 1))) →
      ∀ t, R ((σ t).1, κ ((σ t).2.1, (σ t).2.2))
        ((σ (t + 1)).1, κ ((σ (t + 1)).2.1, (σ (t + 1)).2.2))) :
    ¬ ∀ ξ : ℤ → Bool × K, (∀ t, R (ξ t) (ξ (t + 1))) →
      ∃ σ : ℤ → Bool × ℕ × ℕ,
        (∀ t, Rlad (Q := Bool) (fun _ _ => true) (fun q => q) t (σ t) (σ (t + 1))) ∧
        ∀ t, ((σ t).1, κ ((σ t).2.1, (σ t).2.2)) = ξ t := sorry

end Probe820
```

## Testing & Validation

- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` exits 0
      after every phase; `grep -c sorry` prints 0 at every phase close.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with the new probe listed as checked and
      tracked (Phase 1 onward).
- [ ] The `#print axioms` block reports at most `[propext, Classical.choice, Quot.sound]` on
      every headline theorem; no `native_decide`, no `sorryAx`.
- [ ] Non-vacuity witnesses precede every inequality and every equality (an inequality between
      empty cells and an equality of empty cells both say nothing).
- [ ] Every gate theorem has the statement its phase's "Target statement" gives; a needed extra
      hypothesis is escalated as a `[BLOCKED]`/`[PARTIAL]` phase, not accepted.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check` on the seven pinned identifiers
      (advisory).
- [ ] The Challenge block above compiles standalone with `lake env lean` (seven
      `declaration uses 'sorry'` warnings, no errors) — run at plan-authoring time and re-run at
      Phase 8.
- [ ] `bash .claude/scripts/verify-deploy.sh`, `bash scripts/check-module-invariants.sh`,
      `bash .claude/scripts/check-task-references.sh` exit 0 at Phase 9.
- [ ] `bash .claude/scripts/validate-artifact.sh specs/820_ladder_counter_lift_lemma_gated/plans/01_counter-lift-gate-table.md plan` exits 0.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` — the wired probe: arithmetic
  layer, 4-cycle fixture, six gate rows compiled, the pin lemma's lift half, header with the
  compiled gate table and the licensed (S)/(C') shape.
- `scripts/check-evidence-probes.sh` — `WIRED` entry and decision row.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — one (W) paragraph.
- `specs/ROADMAP.md` — "Run these next" and Stage 1 updated.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
  — pin lemma, positionwise-lift paragraph, third parameter source.
- `specs/820_ladder_counter_lift_lemma_gated/summaries/01_counter-lift-gate-table-summary.md` —
  written by the implementation postflight.

## Rollback/Contingency

- **Negative branch (a decision gate refutes).** If Phase 6 or 7 compiles an inequality
  resistant to every `K` of the forced shape (modulus 8 and a larger threshold tried on the
  fixture, both failing), that is a COMPLETE RESULT: the phase is marked `[BLOCKED]` with the
  obstruction compiled under its own name (`gate9_col_refuted` / `gap_shift_refuted`), Phase 8 is
  closed `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing the
  compiled refutation (the lift half serves no route that is closed), and Phase 9 records
  `[BLOCKED]`-to-closed for the ladder route in the header, the guard row, the README and the
  ROADMAP — never a weakened same-named substitute, never a `[NOT STARTED]` left dangling.
- **Overrun on an expensive row.** A cell equality that does not close within its phase is
  recorded `[PARTIAL]` with the compiled inclusion(s) and the per-member truth lemmas kept
  (they are green sub-steps and are committed as such); the next dispatch resumes from the
  progress file. The statement is never narrowed to make it close.
- **Reverting the probe.** The probe is outside every Lake target root, so a broken state breaks
  nothing but the guard script; a genuine rollback of uncommitted probe edits follows
  `context/contracts/recovery.md`'s rollback rung (snapshot-then-rollback, task number explicit);
  an ordinary defensive checkpoint before a long pumping proof uses
  `bash .claude/scripts/git-snapshot.sh 820 --no-revert`. Commits are per green sub-step through
  `.claude/scripts/git-commit-scoped.sh` with an explicit file list (never `git add -A`).
- **Context-file edit.** The source-store file is outside this repository; if it is unreachable
  at implementation time, record the intended paragraphs in the probe header's "What this
  records elsewhere" note and open an issue-log entry rather than editing the deployed mirror.
