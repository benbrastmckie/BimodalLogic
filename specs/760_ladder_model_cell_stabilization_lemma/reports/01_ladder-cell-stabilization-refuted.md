# Research Report: Task #760

**Task**: 760 - Ladder model, admissibility set Adm, and the cell-stabilization lemma ladderCell_stabilizes over both counters (c, n)
**Started**: 2026-10-11T08:20:43Z
**Completed**: 2026-10-11T08:47:03Z
**Effort**: ~1.5 hours (one research dispatch, including a compiled prototype)
**Dependencies**: 758 (logical, positive verdict re-read), 759 (serialization only)
**Sources/Inputs**: - Codebase (`RaySummary/RunLayer.lean`, `RaySummary/AnchorLayer.lean`, `PlusLanguage/PlusTruth.lean`, `Semantics/SlicedFrame.lean`, `Semantics/IntNormalForm.lean`, the ninth and tenth wired probes), Mathlib (`Set.Finite.preimage`, `Function.Injective.injOn`), lean-lsp MCP (`lean_run_code`, `lean_local_search`), the design of record `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (Sections 0, A, H3-H6), literature briefing (HWZ 2000, orientation only)
**Artifacts**: - specs/760_ladder_model_cell_stabilization_lemma/reports/01_ladder-cell-stabilization-refuted.md (this report)
- specs/760_ladder_model_cell_stabilization_lemma/prototype/ladder-cell-refutation-proto.lean (compiled prototype, 488 lines, 0 errors / 0 warnings, every headline theorem at `[propext, Classical.choice, Quot.sound]` or less)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **F1 — the landed frame cannot be instantiated.** `ladderFrame step pend fwd bwd` takes
  `fwd : ∀ t x, ∃ y, Rlad step pend t x y` over the FULL carrier `Q × ℕ × ℕ`, but `Rlad` carries
  the clause `pend x.1 = false → x.2.1 = 0`, so the idle state `(q, 1, 0)` has no successor and no
  predecessor; and if every state is pending, `(q, 0, n)` has no successor (`Count true true`
  demands `c' + 1 = 0`). `fwd` is therefore unsatisfiable for EVERY object (`Probe760.no_fwd`,
  machine-checked), and `bwd` fails for every object with an idle state (`no_bwd_of_idle`). No
  `TaskModel` over `ladderFrame` can ever be built; the ninth wired probe never instantiated it
  (its `ladder_isRegular` is generic in `fwd`/`bwd`). The admissibility set `Adm` the README names
  is forced to be a CARRIER restriction — `{x // x.2.1 ∈ Adm pend x.1}` with
  `Adm pend q = {c | pend q = false → c = 0}` — not a side condition on the object.
- **F2 — the stabilization lemma is FALSE in both filed forms**, on the repaired carrier, for the
  two-state object `Q = Bool` (`pend = id`, `step` total, `p` at the pending state, `r` at the
  idle one) and `φ := p U (r ∧ X(p ∧ X r))` with `X χ := ⊥ U χ` (`|cl φ| = 12`):
  `cellAt (a, B, B+1) ≠ cellAt (a, B, B+2)` for EVERY `B` (`Probe760.cell_ne`), so both the
  exhibited-`B` form (`exhibited_form_refuted`) and the `∃ B` fallback (`exists_form_refuted`)
  fail. Mechanism: the current deadline forces the region to end at `z + c`, and the next-deadline
  counter at that idle lies in `[n - c - 1, n + c + 1]`, so the GAP `n - c` is observable — the
  next region has length exactly one on some history through `(a, B, B+1)` and length `≥ 2` on
  every history through `(a, B, B+2)`. The hypothesis "`c, c', n, n' ≥ B`" bounds each counter
  but not their difference, and `Count`'s idle clause `c' = n` is exactly what makes the
  difference visible. T1's positive verdict does not transfer: `Node` is one-region and has no
  next-deadline counter.
- **Recommended approach**: the design of record's own contingency — the stabilization lemma is
  **[BLOCKED]** with the obstruction recorded, never a sorry, axiom, vacuous definition,
  trace-level hypothesis or capped ladder. The obstruction already exists as a compiled prototype;
  landing it as the twelfth wired probe plus the README/theorem-index records is one implement
  dispatch. The successor design (the finite cell index `Q × Fin (B+1) × Fin (B+1)` that T4-T6
  build on is gone, and `ladderFrame` itself needs the carrier repair) is a user matter, raised as
  a non-blocking `user_decision`.

## Context & Scope

The dispatch asked for (i) `ladderModel` over `ladderFrame`, (ii) a definition of `Adm`, and
(iii) `ladderCell_stabilizes` over both counters, with the bound `B := |cl φ|` exhibited and an
`∃ B` fallback — "either form yields finitely many deadline classes per counter and a finite cell
index `Q × Fin (B+1) × Fin (B+1)`, which the realization record builds on". The CONTINGENCY named
one failure mode (T1 refuting at the fixture); T1 was positive. This research re-derived every
input against the tree (Section 0 of the design record was re-checked by compile, not copied) and
tested the statement's truth before anything else, because the bound shape of a lemma that is
false has no cost.

Constraints honoured: zero debt (no sorry, axiom, vacuous definition, trace-level `Presented`
hypothesis, capped ladder or cslib require anywhere in the prototype); guardrails (a)-(e) of the
dispatch (time-axis object over the closure alphabet; the slice `Q × ℕ × ℕ` stays infinite and the
refutation bounds nothing; no upper bound anywhere; direction-neutral mechanism — the refutation
is forward-looking, a past-looking twin is noted at paper level only). `B` is a count throughout;
nothing here is a complexity statement.

**A type-shape note on the filed statement.** `cellAt (ladderModel …) φ (q, c, n) z` does not
typecheck: the world state of a sliced frame is `ℤ × W`, so the state is `(t, (q, c, n))` (and on
the repaired carrier `(t, ⟨(q, c, n), h⟩)`). The ℤ component is invisible to the valuation and to
`cellAt` (both `cellAt_eq_cellAt` and a time shift of the history absorb it), but the planner must
write it. The prototype's `w₁ B`/`w₂ B` show the shape.

## Findings

### Codebase Patterns

**The ladder's one-step semantics (`RunLayer.lean`, re-read).**
`Rlad step pend _ x y := step x.1 y.1 = true ∧ (pend x.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2
∧ Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1`, with
`Count px py c n c' := if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px → c = 0))`
and `Drift n n' := n' = n ∨ n' = n + 1 ∨ n' + 1 = n`. Consequences used below, each proved in the
prototype on concrete Booleans (`count_tt`, `count_tf`, `count_ft`, `count_ff`):

1. a pending state with `c ≥ 1` has only pending successors, with `c - 1`;
2. a pending state with `c = 0` has only idle successors, with `c' = 0`;
3. an idle state's pending successors carry `c' = n` (the idle state's OWN next deadline), its
   idle successors `c' = 0`;
4. `n` moves by at most one per step, at every step.

So from `(q, c, n)` pending at time `z`, every history is pending exactly on `[z, z + c]`, idle at
`z + c + 1` with `n_{z+c+1} ∈ [n - c - 1, n + c + 1]`, and the region after that idle (if it starts
at once) has `c = n_{z+c+1}`, i.e. length `n_{z+c+1} + 1`.

**F1 — `ladderFrame`'s hypotheses are unsatisfiable (machine-checked).**
`ladderFrame … (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t-1) y x)`
quantifies `x` over all of `Q × ℕ × ℕ`. The clause `pend x.1 = false → x.2.1 = 0` is on the
SOURCE of every step, so `x = (q, 1, 0)` with `pend q = false` has no successor (`no_fwd`, idle
case) and, since `Count _ false _ _ c'` forces `c' = 0`, no predecessor either (`no_bwd_of_idle`).
If `pend` is constantly `true`, `x = (q, 0, 0)` has no successor because `Count true true 0 n c'`
is `c' + 1 = 0` (`no_fwd`, all-pending case). Hence no object supplies `fwd`; `ladderFrame`,
`ladderFrame_isRegular`, `ladderFrame_step` and the ninth probe's `ladder_isRegular` are theorems
about a frame with no instances. This is not a `def := True` vacuity (the definitions are
meaningful); it is the unsatisfiable-hypothesis form, and it makes deliverable (i) of the dispatch
— `ladderModel : TaskModel (ladderFrame …).toTaskFrame` — literally constructible but
uninhabitable in use. **The README's own phrase is the fix**: "an admissibility restriction
`c ∈ Adm q` on the ladder's carrier". The prototype's repair, generic in the object:

```lean
def Adm {Q : Type} (pend : Q → Bool) (q : Q) : Set ℕ := {c | pend q = false → c = 0}
abbrev LadderState (Q : Type) (pend : Q → Bool) : Type := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}
def RladAdm step pend : ℤ → LadderState Q pend → LadderState Q pend → Prop := fun t x y => Rlad step pend t x.1 y.1
theorem RladAdm_fwd [Finite Q] : FwdFinBranch (RladAdm step pend) :=
  fun t x => (Rlad_fwd step pend t x.1).preimage Subtype.val_injective.injOn   -- and `_bwd` likewise
def ladderFrameAdm … (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (bwd : …) : FrameOver intOrder :=
  ofSlicedStepFinBranch (RladAdm step pend) (RladAdm_fwd step pend) (RladAdm_bwd step pend) fwd bwd
def ladderModel … (lab : Q → Atom → Bool) : TaskModel (ladderFrameAdm step pend fwd bwd).toTaskFrame where
  valuation := fun (w : ℤ × LadderState Q pend) p => lab w.2.1.1 p = true
```

Two-sided finite branching is the library's `Rlad_fwd`/`Rlad_bwd` pulled back along
`Subtype.val` (one line each); regularity is `ofSlicedStepFinBranch_isRegular` unchanged; the
slice `LadderState Q pend` is still infinite (the pending states carry every `c`). On this carrier
`fwd`/`bwd` become genuine, satisfiable object conditions — the prototype discharges them for
`Q = Bool` (`fwdB`, `bwdB`) — and the natural general statement of `Adm`'s companion
("which objects supply `fwd`/`bwd`") is: every pending `q` has a pending `step`-successor, an idle
`step`-successor and a pending `step`-predecessor; every idle `q` has some successor and some
predecessor. This research states that condition and does not prove it is also sufficient; it is
a short lemma for the successor record.

**F2 — the stabilization statement is false (machine-checked).** On `ladderFrameAdm stepB pendB`
with `Q = Bool`, `pendB = id`, `stepB ≡ true`, `labB` reading `p` at `true` and `r` at `false`, and
`φ := untl p (r.and (X (p.and (X r))))`, `X χ := untl bot χ`:

- *Positive half* (`phi_pos`, `exists_phi_mem_cell₁`): the explicit path `gPos B` — idle
  `(false, 0, B)` for `t < 0`, then `(true, B - m, B + 1 - m)` for `0 ≤ m ≤ B`, `(false, 0, 0)`,
  `(true, 0, 0)`, `(false, 0, 0)` forever — is an `RladAdm` step path (`gPos_isPath`), so a
  history of the frame by `ofSlicedStepFinBranch_mem_HF_iff`; it passes through
  `(0, (true, B, B+1))` and satisfies `φ` at `0` with witness `s = B + 1`.
- *Negative half* (`not_phi_of_gap_two`, `phi_not_mem_of_mem_cell₂`): every history through
  `(0, (true, B, B+2))` is an offset step path (`hist_path`); by forward determinism
  (`pending_run`) it is pending on `[0, B]` with `c` counting down and `n ≥ B + 2 - i` at step `i`;
  so `B + 1` is idle with `n ≥ 1` (`idle_at`); its successor is idle or pending with `c ≥ 1`
  (`after_idle`), and in the latter case `B + 3` is pending too (`after_pending`). The `untl`
  witness `s` must satisfy `r`, so `s = B + 1` (the only idle in `(0, B + 1]`; beyond it the guard
  `p` fails at `B + 1`), and there `X(p ∧ X r)` fails either way.
- Hence `cellAt M φ (w₁ B) 0 ≠ cellAt M φ (w₂ B) 0` for every `B` (`cell_ne`), where
  `w₁ B = (0, ⟨(true, B, B+1), _⟩)` and `w₂ B = (0, ⟨(true, B, B+2), _⟩)`. The exhibited form is
  refuted at `c = c' = |cl φ| = 12`, `n = 13`, `n' = 14` (`exhibited_form_refuted`); the `∃ B`
  form is refuted because the witness is uniform in `B` (`exists_form_refuted`).

The semantics facts load-bearing here, each re-read in `PlusTruth.lean`: `untl` is STRICT
(`∃ s, t < s ∧ … ∧ ∀ r, t < r → r < s → …`), which is what makes `X χ := untl bot χ` the
next-time operator (`truth_X`, mirroring the fixture's `truth_Xp`); the atom clause reads
`M.valuation (τ.state t)`; `WorldHistory.path := τ.state` definitionally.

**A second, past-looking refutation (paper level, not machine-checked).** A pending state
`(q, c, n)` has an idle predecessor only if `n ≥ c - 1`: going back `j` pending steps the current
deadline is `c + j`, the idle before it must carry `n = c + j`, and `n` can have moved by at most
`j + 1` since, so `c + j ≤ n + j + 1`. For `n < c - 1` every history has a pending-forever past
(possible on `Q = Bool`), and `snce ⊤ r` (`Pr`) is false at `(a, B+2, B)` on every history and
true at `(a, B, B)` on some. So the gap is visible backward as well, with a 4-member closure. The
statement is direction-neutral and fails in both directions; the compiled witness is forward-only,
as every probe in this collection is.

**What is actually observable in `(c, n)`, and what a true statement would have to say.** From the
one-step semantics: the region end `z + c` (exactly); the first idle's `n` range
`[n - c - 1, n + c + 1]`, hence the length of a region starting right after it; whether an idle
predecessor exists (`n ≥ c - 1`) and the least distance to it (`j ≥ ⌈(n - c - 1)/2⌉`). All three
are functions of `c`, `n` AND `n - c`. Closure formulas of size `B` can see positions and lengths
only up to about `B` (the `X`-depth of `cl φ`), so the plausible true index of a cell is
`(q, min c B', min n B', clip (n - c) [-B', B'])` for some `B'` syntactic in `|cl φ|` — three
clipped coordinates, not two. This research does not claim that index is sufficient. Proving it
is an indistinguishability theorem (a stuttering/EF-type argument for strict `untl`/`snce` with
definable `X`, under `stab` quantifying over the histories through the same state and `box` over
all) for ARBITRARY finite objects, where the `Q`-word inside a region is an arbitrary `step`-path;
the tenth probe's technique (every history canonical; four relative-position classes; one
`simp only` over the enumerated closure) does not generalize to that, and no comparable statement
exists in the tree. It is research-level and not costable, exactly as the design record said of
the original before T1 — and T1's figure (346 lines, one dispatch) was for the one-region case
only.

**Why this breaks the filed successor chain, precisely.** H4 (task 761) states `LadderCons` and
`ladderRealized` per ladder cell on the index `Q × Fin (B+1) × Fin (B+1)`; H6 (task 763) assembles
`objBound φ` as cells × deadline classes from that index. Both read the stabilization lemma's
conclusion as "the cell at `(q, c, n)` is a function of `(q, min c B, min n B)`". That function
does not exist (F2); whatever replaces it carries at least the clipped gap, and the realization
theorem's per-cell hypothesis must be re-stated over it. `anchorCells_finite`/`anchorCells_ncard_le`
are untouched: the SET of cells of any model is still finite and bounded; what is lost is the
claimed computable index of WHICH cell a ladder state has.

**Evidence tier.** `lean_local_search` reported `index: warming` on every call, so no empty
result was treated as absence; every name in this report was verified by compiling the prototype
(`lake env lean`, routed through the build guard, three rounds, final round exit 0, no warnings).
`#print axioms` for the five headline theorems: `no_fwd` and `cell_ne`, `exhibited_form_refuted`,
`exists_form_refuted` at `[propext, Classical.choice, Quot.sound]`; `no_bwd_of_idle` at
`[propext]`. `Classical.choice` enters through `ofSlicedStepFinBranch_mem_HF_iff` (the
regular-frame history characterization), as the eighth to tenth probes already note.

### External Resources

- **Mathlib** (verified by compile): `Set.Finite.preimage (I : Set.InjOn f (f ⁻¹' s)) (h : s.Finite)`
  (`Mathlib/Data/Set/Finite/Basic.lean`) with `Subtype.val_injective.injOn`
  (`Function.Injective.injOn`, `Mathlib/Data/Set/Function.lean`) is all the repaired carrier
  needs for finite branching. `Int.toNat_of_nonneg`, `Prod.ext`, `Subtype.ext`, `Bool.noConfusion`,
  `Bool.false_ne_true` for the bookkeeping.
- **Literature** (orientation only, no claim sourced). HWZ 2000's quasimodel `⟨f, R⟩`
  (Definitions 10-12; corpus entry of UNVERIFIED-summary provenance) chooses the run set `R`
  freely, which is why no deadline counter and no stabilization lemma occur there — the ladder
  exists because in this semantics the run set is the path set of a frame. The phenomenon behind
  F2 is the classical one that LTL with a next operator counts up to its nesting depth and no
  further (the stuttering principle for `LTL(X^m, U^n)`, Kučera–Strejček; NOT in the corpus, cited
  from memory as orientation for the "clipped gap" shape, and to be verified before any formal
  use). It says nothing about `stab`/`box`, which quantify across histories.
- **Rate-limited search tools** (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`,
  `lean_state_search`, `lean_hammer_premise`) were not needed: the two Mathlib lemmas were located
  by `grep` in `.lake/packages/mathlib` and confirmed by compile; no MCP failure occurred.

### Recommendations

**R1 (recommended) — the record's own contingency: `[BLOCKED]`, with the obstruction landed.**
The design record (Section A) and the README both say "if it fails the honest outcome is
`[BLOCKED]`, never a finite-fibre retreat"; the dispatch's CONTINGENCY names the same outcome for
the one failure mode it anticipated. The failure arrived by a different route (the `n`-counter,
not the fixture), and the honest outcome is the same. Plan shape:

1. Port the prototype to `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`
   (the twelfth wired probe; header per the 758/759 pattern — verdict NEGATIVE, mechanism, what it
   does NOT say, axiom foot, compile line); one `WIRED` array entry and one table row in
   `scripts/check-evidence-probes.sh`; `#print axioms` on the five headline theorems. The
   prototype already compiles clean; this is the 758 Phase 2 shape (one dispatch).
2. Record the obstruction: one "A twelfth wired probe, …" paragraph in the RaySummary README's
   `## Evidence`, and amend the two sentences that now misdescribe the state — the README's
   "(W): what landed and what did not", item 1 ("plausible, unproved" → refuted in the filed
   form, with the mechanism and the carrier defect), and the `docs/theorem-index.md` row of
   `ladderFrame_isRegular` ("whose first lemma … is unproved" → refuted in the filed form; and the
   frame's seriality hypotheses are unsatisfiable on the full carrier). Durable anchors only; no
   task numbers outside `specs/**`.
3. Mark the lemma `[BLOCKED]` in the plan with the obstruction, and return the successor design
   to the user (see Decisions D4): whether `RunLayer.lean`'s `ladderFrame` is repaired in place
   (outside this task's file scope) or beside (`LadderModel.lean`), and what statement replaces
   the stabilization lemma for T4-T6.

Narrower file scope than filed: no library module is created, so `RaySummary.lean`,
`FormalSystem.lean`, `KTypeSummaryAxiomTest.lean` and the C14 heredocs are untouched;
`status.typ` regenerates. Collisions: 744 (README, invariants script — not touched under R1),
410 (`status.typ`); the evidence script collides with 734 as for 758/759.

**R2 — land the sound parts in the library now (`LadderModel.lean`), by `/revise`.** `Adm`,
`LadderState`, `RladAdm` with its two branching lemmas, `ladderFrameAdm`, `ladderModel`, the
uninstantiability record for `ladderFrame`, and the negative theorem `ladderCell_not_stabilizes`
as a library result in the manner of `not_finite_width_fmp` — with C14 pins in both heredocs and
the test, theorem-index rows carrying the count-not-complexity sentence, aggregator imports. This
is what any successor needs and the prototype is ~80% of it, but it fixes a carrier design
(subtype) the user may want to make differently (repairing `ladderFrame` in place, so that the
ninth probe and the pins follow), and it lands a module whose titular theorem is a refutation. It
is the natural follow-up once the user has ruled; it should not be chosen by an agent.

**R3 — a repaired positive lemma** (cells determined by `(q, min c B', min n B', clip (n - c))`).
Research-first, not costable, and its proof technique does not exist in the tree (see Findings).
Not recommended as this task's deliverable; recorded so the planner does not re-derive it.

**Forbidden under every option** (dispatch; `lean4.md`): proving the filed statement over the
landed `ladderFrame` — it is provable there ONLY because `fwd` can never be supplied, i.e. by
unsatisfiable hypotheses, which is the vacuity the zero-debt gate exists to refuse; sorry; axiom;
`def := True`; a capped ladder (`Probe750.capped_carrier_finite` + `not_finite_width_fmp`); a
trace-level `Presented` hypothesis; weakening the statement under the same name
(`plan-compliance.md`, Statement Fidelity). The plan's `## Lean Challenge Statements` under R1
are the five negative theorems, verbatim from the prototype.

## Decisions

- **D1 — verify by prototype, not by argument.** The finding overturns a filed design record and
  the dispatch's own statement, so a paper argument alone was judged insufficient. The prototype
  compiled in three guard-routed rounds; both findings are theorems.
- **D2 — refute on the repaired carrier.** The filed statement over the landed `ladderFrame` is
  vacuously true (F1), so refuting it there is impossible and meaningless; the refutation is
  stated on the carrier any honest successor must use, and it is therefore also the verdict on the
  statement the design record intended.
- **D3 — witness uniform in `B`.** The counters `(B, B+1)` versus `(B, B+2)` were chosen so that
  one proof refutes the exhibited form (instantiate `B := |cl φ| = 12`) and the `∃ B` form at once;
  no closure cardinality is computed inside the proof.
- **D4 — `user_decision`, non-blocking, recommending R1.** The choice between R1 and R2 is a
  design-of-record matter the dispatch forbids an agent to settle for T5 and, by the same
  reasoning, for the chain T3 → T4 → T6; it is reversible within the repository, so the loop may
  proceed on R1 while the user is asked.
- **D5 — `RunLayer.lean` is not edited.** It is outside this task's file scope, and the F1 repair
  in place (restricting `ladderFrame`'s carrier) changes a C14-pinned declaration and the ninth
  probe; that is the user's call (R2 or a new record).

## Risks & Mitigations

- **A planner or implementer "proves" the filed lemma over `ladderFrame`.** It will typecheck and
  close, by hypotheses nobody can supply. Mitigation: the Challenge statements are the negatives;
  the plan must say in words that `fwd`/`bwd` over the full carrier are unsatisfiable (F1), and
  cite `no_fwd`.
- **T4-T6 proceed on the filed index.** Their dependency edges on 760 are logical; a `[BLOCKED]`
  760 holds them. Mitigation: the README amendment names the index as refuted; the
  `user_decision` asks for the successor design.
- **The subtype carrier is taken as the design.** It is a prototype shape; alternatives (repairing
  `ladderFrame` in place; a sigma over `Adm`) are equally valid. Mitigation: the probe header
  says "a carrier restriction of this shape", not "the carrier".
- **Documentation debt in `RunLayer.lean`'s docstrings** (they describe `ladderFrame` as the
  constructor of obligation (i); its hypotheses are unsatisfiable). Outside file scope under R1;
  recorded in the issue log and in the README amendment, which is in scope.
- **Gate collisions**: README (744, and 759 if re-opened), `check-evidence-probes.sh` (734),
  `status.typ` (410) — left to the admission gate as the dispatch says.
- **Past-direction refutation is unverified.** It is flagged paper-level; nothing depends on it.

## Tactic Survey Results

Informal survey from the prototype (no `lean_multi_attempt` sweep; the goals were closed
directly):

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Rlad` step on explicit `futPos` values (16 `if` branches) | `split_ifs <;> simp [Drift, Count] <;> omega` | success | `rlad_iff` first |
| `Count` on concrete Booleans inside a hypothesis with a cast | `simp [Count] at h` | fail (rewrote `↑(i+1)` to `↑i + 1`, breaking `omega`'s atoms) | — |
| same | `rw [count_tt] at h` (four one-line lemmas `count_tt/tf/ft/ff`) | success | `simp [Count]` proves each lemma |
| `(s : F.Duration) < s'` goals from the `untl` witness | `omega` | fail (`<` on `F.Duration` not seen) | — |
| same | `rintro ⟨(s' : ℤ), …⟩` + `have : (s : ℤ) < s' := h` then `omega` | success | the fixture's `truth_Xp` idiom |
| `Prod.mk` equality under the `F.WorldState` abbreviation | `simp only [Prod.mk.injEq]` | fail (does not see through `F`) | — |
| same | `congrArg (fun w : ℤ × LadderState _ _ => w.2.1) h`, `Prod.ext rfl (Subtype.ext _)` | success | — |
| finite branching on the subtype carrier | `(Rlad_fwd … t x.1).preimage Subtype.val_injective.injOn` | success | `Set.Finite.preimage` |
| `pA ≠ rA` on `Atom` string literals | `simp [pA, rA]` | success | — |
| `#eval (plusSubformulaClosure φ).card` | `#eval` | `12` | computable closure |

## Context Extension Recommendations

- **Topic**: sliced-frame probes — `omega` and `F.Duration`.
- **Gap**: every probe re-discovers that the `untl`/`snce` witness has type `F.Duration`, which
  `omega` does not treat as `ℤ`; the fixture's `(s' : ℤ)` ascription idiom is undocumented.
- **Recommendation**: a short pattern note under `context/project/lean4/patterns/` ("sliced-frame
  probe idioms": ascribe the witness, bridge `path`/`state` by `congrFun`, use `congrArg`/`Prod.ext`
  through `F.WorldState`, evaluate `Count`-style Boolean `if`s by `rw` with concrete-Boolean lemmas
  rather than `simp` when casts are present, pull finite branching back along `Subtype.val` with
  `Set.Finite.preimage`). Source-store edit, outside this task's scope.

## Appendix

**Compile commands (all routed through the guard, `env` is allowlisted):**
`bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/760_ladder_model_cell_stabilization_lemma/prototype/ladder-cell-refutation-proto.lean`
— round 1: 20 errors (tactic-level); round 2: 1 error (`simp [Count]` cast rewriting); round 3:
exit 0, no warnings.

**`#print axioms` (round 3):**
- `Probe760.no_fwd` — `[propext, Classical.choice, Quot.sound]`
- `Probe760.no_bwd_of_idle` — `[propext]`
- `Probe760.cell_ne` — `[propext, Classical.choice, Quot.sound]`
- `Probe760.exhibited_form_refuted` — `[propext, Classical.choice, Quot.sound]`
- `Probe760.exists_form_refuted` — `[propext, Classical.choice, Quot.sound]`

**`lean_run_code` checks:** F1 standalone (`no_fwd`, `no_bwd_of_idle` against
`RaySummary.RunLayer` alone — success, same axioms); `#eval (plusSubformulaClosure φ).card = 12`.

**Searches:** `lean_local_search` ×2 (`WorldHistory.path`, `Function.Injective.injOn`; index
`warming` both times, hits confirmed by compile); `grep` over `FormalSystem/`, `Tests/`,
`specs/evidence/`, `scripts/check-evidence-probes.sh`, `scripts/check-module-invariants.sh`
(C14 heredoc pair at lines 2009-2332, `C14LEAN` at 2336), `docs/theorem-index.md`,
`.lake/packages/mathlib/Mathlib/Data/Set/Finite/Basic.lean`.

**Files read (durable anchors):** `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`
(`Drift` 254, `Count` 261, `Rlad` 268, `ladderFrame` 342); `…/AnchorLayer.lean` (`cellAt` 132,
`anchorCells_ncard_le` 324); `FormalSystem/PlusLanguage/PlusTruth.lean` (`PlusTruthAt` 84-93);
`FormalSystem/Semantics/SlicedFrame.lean` (`IsSlicedStepPath` 340);
`FormalSystem/Semantics/IntNormalForm.lean` (`WorldHistory.path` 286, `mem_HF_iff_adjacent` 348);
`specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` (T1, 346 lines) and
`deadline-ladder-branching.lean` (ninth probe, 103 lines); the RaySummary README ("(W): what
landed and what did not", `## Evidence`); the design record Sections 0.2 rows 11, 16, 17, A, H3-H6.

**Issue log:** two entries recorded as they arose (`issues.jsonl`): the design-record defect
(F1 + F2, severity blocking, resolution open, channel follow_up_task) and a win (both findings
machine-checked within the research dispatch, with the two tactic idioms worth remembering).
