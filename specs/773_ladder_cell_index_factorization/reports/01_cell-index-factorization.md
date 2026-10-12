# Research Report: the ladder cell index, and the refutation of its gap-carrying candidate

- **Task**: 773 - Ladder cell index factorization
- **Started**: 2026-10-11T00:00:00Z
- **Completed**: 2026-10-11T02:30:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None (research-first; consumer is the ladder realization record's Phase 1)
- **Sources/Inputs**:
  - `specs/773_ladder_cell_index_factorization/prototype/README.md`, `prototype/gap-index-test.lean` (pre-landed evidence, read in full first)
  - `specs/761_ladder_realization_theorem/.blocker-research.json` (predecessor blocker analysis)
  - `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (the known refutation, via the prototype's verbatim fixture copy)
  - `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`, `LadderModel.lean`, `AnchorLayer.lean`
  - `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`
  - `FormalSystem/PlusLanguage/Formula.lean`, `PlusTruth.lean`
  - lean-lsp MCP: not used (see Appendix); evidence tier is compiled probes under `lake env lean`
- **Artifacts**:
  - `specs/773_ladder_cell_index_factorization/reports/01_cell-index-factorization.md` (this report)
  - `specs/773_ladder_cell_index_factorization/prototype/parity-index-refutation.lean` (484 lines, `lake env lean` exit 0, no `sorry`, standard axioms)
  - `specs/773_ladder_cell_index_factorization/prototype/route-c-finite-width.lean` (77 lines, `lake env lean` exit 0, no `sorry`, standard axioms)
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The dispatch's TARGET is refuted, uniformly in `B`.** The gap-carrying three-coordinate index
  `(q, min c B, min n B, clip (n - c) [-B, B])` does not factor `cellAt`, on an object whose
  `step` relation makes the PARITY of the countdown `c` observable at the region end — a distance
  `c + 1` away, which `min c B` cannot reach. Machine-checked: `ladderIndex_not_factoring`,
  `exists_form_refuted`, `exhibited_form_refuted` in `prototype/parity-index-refutation.lean`.
- **The obstruction is NOT the gap.** The witnessing pair carries EQUAL next-deadlines `n` and two
  gaps that both saturate the clip at `+B`, so the gap coordinate is doing its job and the
  countdown coordinate is what fails. The predecessor record's anticipated risk ("clipping the gap
  loses distinctions at `|n - c| > B'`") is not where the candidate dies.
- **The dispatch's cheap falsification gate PASSES, but only for `2 ≤ B`** (`gate_separates`); at
  `B ≤ 1` the clip range is narrower than the gaps being separated and the candidate already
  collides on the known refutation's own pair (`gate_collides_below_two`). So the gate was worth
  running and is not vacuous — it simply does not catch the real defect.
- **Route (C) is dead for the general goal, by a landed theorem rather than a conjecture.** A
  deadline-bounded ladder sub-carrier is finite (`bounded_ladder_finite`); on a finite carrier the
  run layer's `ofSlicedStepFinBranch` is literally `FrameOver.ofSlicedStep` (`rfl`,
  `finBranch_eq_ofSlicedStep`); so every bounded-deadline ladder model validates `Φ.neg`
  (`bounded_width_validates_Phi_neg`) and none can refute it, while `Φ.neg` is a ℤ-time
  non-validity. Route (C)'s premise is FALSE at `φ = Φ.neg`. Do not spend a phase on it.
- **Recommended repair: one or two RESIDUE coordinates, not a deeper gap analysis.** What
  `cellAt` reads at distance `c + 1` is the object state at the region end — a `step`-reachability
  datum in `c + 1` steps, eventually periodic in `c`. Carrying `c % P` beside `min c B` restores
  it; the same argument applied to the second region end forces `n % P` as well. The residue
  coordinate separates the refuting pair (`index_res_separates`); that it SUFFICES is argued, not
  proved.
- **No sorry-free path to the dispatch's lemma as stated exists, because the lemma is false.** The
  task should not proceed to implement the stated target. The next dispatch is a re-scoped index
  definition plus its own falsification gate, which is a planning decision the user may want to
  confirm (see `user_decision` on `.return-meta.json`).

## Context & Scope

The ladder realization half cannot be STATED without a computable cell index: `hitOf` requires
`[Fintype Q]`, the admissible carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}`
is infinite (`Rlad_slice_infinite`), and the two-coordinate index `Q × Fin (B+1) × Fin (B+1)` is
refuted uniformly in `B`. The dispatch targets a third coordinate carrying the gap `n - c`, with
the method "FALSIFY FIRST": gate the candidate against the known refutation's fixture before
attempting the general proof, then hunt a fresh refutation.

Scope of this research: (1) run the gate; (2) hunt the fresh refutation; (3) test route (C)'s
premise in parallel. All three are now settled. What is NOT in scope and remains open: the
positive factorization lemma for any repaired index — no such lemma is claimed here, and nothing
in this report asserts that a finite index exists.

Constraints respected: zero-debt (no `sorry`, no new axiom, no vacuous definition in either
probe); the probes are prototypes, NOT wired into `scripts/check-evidence-probes.sh`.

## Findings

### The object and what it observes

- `Count` (in `RunLayer.lean`) forces, pending→pending, `c' + 1 = c`: the countdown runs to `0`
  with **no early discharge**. Hence from a pending state with countdown `c`, the states at
  distances `0..c` are pending and the state at distance **exactly `c + 1`** is idle. This is the
  one unbounded-distance position a formula can name without counting to it.
- `step : Q → Q → Bool` is **independent of the counters**. Nothing stops `step` from alternating a
  tag on every pending step and copying it onto the idle state that ends the region. Then the
  object state at distance `c + 1` encodes `c mod 2`, and an atom reading that tag, under
  `p U (r ∧ a)`, reads `c mod 2` at unbounded distance.
- `ladderModel`'s valuation reads the object component `q` and nothing else, so this is entirely a
  statement about `step`, not about the counters or the labelling of counters.

### The refutation (machine-checked)

`prototype/parity-index-refutation.lean`, 484 lines, `lake env lean` exit 0, no `sorry`; the
headline theorems carry `[propext, Classical.choice, Quot.sound]` and `gate_separates` carries
`[propext, Quot.sound]`.

- Object: `Qp := Bool × Bool` read as `(pending?, tag)`, `pendP q = q.1`, `stepP` flipping the tag
  on each pending step and copying it onto the ending idle state. Both seriality conditions hold on
  the admissible carrier (`fwdP`, `bwdP`), so `ladderFrameAdm` and `ladderModel` are available
  exactly as the tree builds them.
- `pending_run`, `idle_at`: the region is **deterministic in the object component** — countdown
  down by one and tag flipped by one per step, idle at `c + 1` carrying the tag of the last
  pending state. Drift freedom touches neither.
- `truth_phiP`: `PlusTruthAt M σ 0 (p U (r ∧ a)) ↔ tagAt tg c = true`, for every history through a
  pending state `((true, tg), c, n)`. The truth value is a function of the STATE, and that function
  reads `c mod 2`. Neither `n` nor any drift choice appears.
- `cell_succ_ne`: `cellAt M phiP (q, c, n) 0 ≠ cellAt M phiP (q, c + 1, n) 0` **for every `c` and
  every `n`**, with `n` held FIXED. This is the general obstruction statement: any index whose
  countdown coordinate has finite range must identify two countdowns of opposite parity at equal
  `n`, and is therefore unsound.
- `index_collide` + `ladderIndex_not_factoring`: at every `B`, the pair
  `((true,false), 2B, 4B+2)` and `((true,false), 2B+1, 4B+2)` receives the SAME candidate index —
  object components equal, both countdowns saturating `min _ B`, both gaps (`2B+2`, `2B+1`)
  saturating the clip at `+B` — and the two cells differ. Both the exhibited-`B` form (at
  `B = |cl phiP|`) and the `∃ B` fallback are refuted.

### The dispatch's falsification gate: outcome

- `gate_separates (B) (hB : 2 ≤ B)`: on the known refutation's own pair, counters `(B, B+1)`
  against `(B, B+2)`, the gap coordinate gives `B+1` against `B+2`. The gate PASSES — the existing
  refutation does not kill the gap-carrying candidate, which is what the dispatch asked to check.
- `gate_collides_below_two (B) (hB : B ≤ 1)`: at `B ≤ 1` the same pair collides. The `φ`-derived
  bound must exceed the gaps `φ` can see, which is the pre-landed finding (B) restated as a lower
  bound on `B` rather than as a free choice.
- Consequence: the gate is sound but weak. It tests only the gap coordinate against the one known
  mechanism. The defect found here lives in a coordinate the gate does not probe.

### Route (C): bound the carrier instead of indexing it

`prototype/route-c-finite-width.lean`, 77 lines, `lake env lean` exit 0, no `sorry`.

- `bounded_ladder_finite`: `{x : LadderState Q pend // x.1.2.1 ≤ N ∧ x.1.2.2 ≤ N}` is finite for
  finite `Q` — route (C)'s own claim, confirmed.
- `finBranch_eq_ofSlicedStep`: for finite `W`, `ofSlicedStepFinBranch R hf hb fwd bwd =
  FrameOver.ofSlicedStep R fwd bwd` **by `rfl`**. The two constructors differ only in which proof
  discharges `Saturation`, and proof irrelevance is definitional. So no transport is needed to
  apply a finite-width result to a ladder frame.
- `bounded_width_validates_Phi_neg`: therefore every model on such a frame validates `Φ.neg`, via
  `NoFiniteWidth.no_finite_width_sat` applied unchanged. With
  `Phi_neg_not_valid : ¬ PlusValidZTime Φ.neg` (re-checked here, not merely quoted), route (C)'s
  premise — "every refutable `φ` has a refuting ladder object with deadlines `≤ N(φ)`" — is FALSE,
  with `φ = Φ.neg` the counterexample.
- This is the same obstruction `RunLayer.lean`'s design decision already records against capping
  the counters ("a fixed cap on the counters gives a finite slice, and every finite-width
  `ofSlicedStep` model validates the ℤ-time non-validity `Φ.neg`"). Route (C) is a re-proposal of
  the capped-counter design the ladder was built to avoid; the prototype README's framing of its
  cost (a sharper seriality condition) understates it.
- Narrow carve-out, stated honestly: nothing above forbids a bounded carrier for a target that
  *does* have a finite-width countermodel. `not_finite_width_fmp`'s own disclaimer says as much.
  What is refuted is route (C) as the GENERAL route, which is how the prototype proposes it
  ("it dissolves the problem").

### What the past adds, and what it does not

`PlusFormula` has a past operator (`snce`), so `tpOf` is not a future-only datum and a factorization
proof must determine the achievable PASTS of a state as well. The ladder's backward structure makes
this a gap question rather than a new one:

- Backward pending steps give `c₀ = c + 1` with `n₀ ∈ {n-1, n, n+1}`, so the gap **decreases** by
  `0`, `1`, or `2` per backward step; a region-start predecessor (idle→pending) requires `c = n₀`
  with `|n - n₀| ≤ 1`, i.e. gap `∈ {-1, 0, 1}`.
- So a state with gap `g` has its region start at least `⌈(g-1)/2⌉` steps back, and "the region
  started ≤ k steps ago is possible" is governed by `g ≤ 1 + 2k`. The gap coordinate, clipped above
  the formula's past-depth, serves the past as well as the future. This is an argument, not a
  proved lemma, and it is the reason the past is not listed as a separate obstruction.

### The repair, and why it is the cheapest live direction

- What is observable at distance `c + 1` is the object state at the region end: the set of `q'`
  reachable from `q` in exactly `c + 1` `step`-transitions with the pending pattern. For a relation
  on a finite set this set is **eventually periodic in `c`** (threshold and period bounded in
  `|Q|`), so `min c T` together with `c % P` determines it where `min c B` alone does not.
- `index_res_separates`: adding `c % 2` separates the refuting pair at every `B`. Cheap, and it
  confirms the repair addresses THIS refutation.
- The same reasoning applied one region later forces a residue on `n` too. From a state `(q, c, n)`
  the achievable next-region lengths form the interval `[max(0, gap-1), n + c + 1]`, of width
  `2c + 3`. When `c ≥ P` that interval covers every residue class and nothing further is
  observable; when `c < P` and `n` is large, it does not, and the residue `n % P` becomes visible.
  So the repaired shape is `(q, min c T, c % P, min n T, n % P, clip (n - c) [-B, B])` — still a
  `Fintype` by construction, still syntactic in `φ` and the object.
- **Honest limit**: that this six-coordinate shape SUFFICES is argued from the structure of `Count`,
  `Drift` and `step`, not proved, and no probe here tests it beyond the one separation check. A
  further refutation at the second region end is the obvious next falsification target.

## Decisions

- **The dispatch's target lemma is not to be attempted as stated.** It is false; attempting it
  would end in a `sorry` or a weakened same-named statement, both forbidden.
- **The refutation is recorded as a prototype, not wired.** Both new files follow
  `gap-index-test.lean`'s posture: compiled under `lake env lean`, not registered in
  `scripts/check-evidence-probes.sh`. Wiring is a separate decision for the implementation phase.
- **Route (C) is closed, by citation plus a machine-checked derivation**, rather than left as a
  parallel track. The three-line derivation (`bounded_ladder_finite` → `finBranch_eq_ofSlicedStep`
  → `bounded_width_validates_Phi_neg`) is in the probe so the closure is checkable and not a
  quotation.
- **The gap coordinate is retained in the recommended shape.** The known refutation's mechanism is
  real and gap-shaped; this research adds a second mechanism, it does not displace the first.
- **The pre-landed findings are not contradicted.** (A) the gap is unbounded — untouched and still
  true. (B) the refuting formula is blind among gaps `≥ 2` — untouched; this report's object uses a
  DIFFERENT formula and a different coordinate, so (B)'s "the known refutation does not lift" and
  this report's "a different refutation applies" are consistent. (C) is refuted as above.

## Recommendations

1. **(Blocking, next dispatch)** Re-scope the index to the residue-carrying shape
   `(q, min c T, c % P, min n T, n % P, clip (n - c) [-B, B])`, with `T`, `P` derived from the
   object (`|Q|`-bounded threshold and period) and `B` from `φ` (its `X`-nesting depth or
   `|cl φ|`), per pre-landed finding (B)'s constraint that the gap bound must come from `φ` and
   never from the counters.
2. **(Blocking, before any proof attempt)** Run a THREE-part falsification gate on the re-scoped
   candidate, not a one-part one: (i) the known gap pair `(B, B+1)` vs `(B, B+2)`; (ii) the parity
   pair `(2B, 4B+2)` vs `(2B+1, 4B+2)` of this report; (iii) a fresh attempt at the second region
   end, where the achievable-interval argument above is weakest. The lesson of this dispatch is that
   a gate probing one coordinate certifies one coordinate.
3. **(High)** If (iii) refutes the six-coordinate shape too, the conclusion to record is that no
   FIXED-ARITY index of this family works and the realization half needs a different presentation
   of a cell (a set-valued per-state datum over a quotient, not a tuple), not a seventh coordinate.
4. **(Medium)** Do not reopen route (C) as a general route; if a bounded carrier is wanted for a
   restricted target, state the restriction explicitly and cite `not_finite_width_fmp`'s own
   carve-out rather than the prototype README's framing.
5. **(Medium)** When the index lands, the box/stab acceptance clause follows over the same index
   (`box_mem_tpOf_iff` is one global bit; `stab_mem_tpOf_iff` is that cell's bit) — unchanged from
   the predecessor analysis, and still the reason the clause must not be dropped to make the
   structure writable.
6. **(Low)** Consider wiring `parity-index-refutation.lean` as an evidence probe once the re-scoped
   index exists, so that any future index candidate is gated against the parity mechanism
   mechanically.

## Risks & Mitigations

- **Risk**: the refutation uses an object whose idle states never restart a region, which a reviewer
  may call degenerate. **Mitigation**: both seriality conditions are proved on the admissible
  carrier (`fwdP`, `bwdP`), which is everything `ladderFrameAdm` requires; nothing in the argument
  consults the post-idle structure (the until is forced to fire at `c + 1`). Adding a second region
  would not change `truth_phiP`.
- **Risk**: in the eventual application the object is not arbitrary — it is built from `φ`'s closure
  types — so one might hope the generic refutation does not bind. **Mitigation**: the dispatch's
  lemma is stated generically in the object, so it is refuted as stated; and a quasimodel's step
  relation encodes arbitrary type-successions, so period structure is to be expected there rather
  than excluded. Relying on application objects being special would need its own theorem.
- **Risk**: the recommended repair is argued, not proved, and could itself be refuted.
  **Mitigation**: recommendation 2 makes the falsification gate a precondition of the proof attempt,
  and recommendation 3 names the conclusion to draw if it fails, so a refutation there is a recorded
  outcome rather than a dead end.
- **Risk**: `T` and `P` bounded in `|Q|` can be exponential in `|cl φ|`. **Mitigation**: every
  quantity here is a COUNT, never a complexity bound — the same posture `LadderModel.lean` already
  states. A `Fintype` is what the realization half needs; nothing claims a procedure.

## Tactic Survey Results

Survey performed only where a proof obligation was actually open; the probes were written and
discharged in this session, so the table records what closed each class of goal rather than a
speculative portfolio sweep.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Count`/`Drift` case arithmetic after `rw [count_tt]` | `omega` | success | handles `Int.toNat` and `min` directly |
| `tagAt` parity step (`tagAt tg (i+1) = !(tagAt tg i)`) | `split_ifs <;> omega` / `simp` | success | `Int.emod` by the literal `2` is in omega's fragment |
| `stepP` Boolean obligations | `cases <Bool term> <;> simp [stepP]` | success | opaque Bools need the case split; bare `simp` leaves an `if` |
| index collision (`Fin`/`Prod` equality of clipped counters) | `simp only [..., Prod.mk.injEq, Fin.mk.injEq, true_and]` then `omega` | success | `omega` handles the conjunction of `min` equalities |
| `0 < s` style goals on `F.Duration` | `omega` | fail | `F.Duration`'s order is not syntactically `Int.lt`; needs `show (0 : ℤ) < _ by omega` or a `have h' : _ := h` re-ascription first |
| finiteness of the bounded sub-carrier | `Finite.of_injective` + `simp only [Prod.mk.injEq, Fin.mk.injEq]` | success | injection into `Q × Fin (N+1) × Fin (N+1)` |
| `ofSlicedStepFinBranch = ofSlicedStep` | `rfl` | success | definitional proof irrelevance; no transport lemma needed |

`lean_multi_attempt` and `lean_hammer_premise` were not used: every goal here is a hand-shaped
case analysis in a bespoke fixture, and the compile loop under `lake env lean` was the faster
oracle (whole-file feedback in one call).

## Literature Proof Structure

Not applicable — no literature source is referenced by the task description or the pre-landed
evidence. The pre-landed prototype and the predecessor blocker record are in-tree artifacts, not
external literature, and are treated as inputs to be re-derived rather than as a source to follow.

## Context Extension Recommendations

- **Topic**: what a clipped coordinate of a ladder state can and cannot preserve.
- **Gap**: `context/project/lean4/` has no note recording that `Count`'s no-early-discharge clause
  puts an unbounded-distance observable at exactly `c + 1`, which is the structural reason every
  "clip the counters" proposal fails. Each attempt has rediscovered it from scratch.
- **Recommendation**: add `context/project/lean4/domain/ladder-counter-observables.md` recording
  the three mechanisms now known (gap-at-the-first-idle; object-state-at-the-region-end, i.e.
  `c mod P`; finite width via `not_finite_width_fmp`) and the gate each one implies, so a future
  index candidate is checked against all three before a proof is attempted.

## Appendix

### Probe invocations

- `lake env lean specs/773_ladder_cell_index_factorization/prototype/parity-index-refutation.lean`
  — exit 0, no warnings, no `sorry` (`grep -c sorry` = 0).
- `lake env lean specs/773_ladder_cell_index_factorization/prototype/route-c-finite-width.lean`
  — exit 0.
- `#print axioms` on the headline theorems: `[propext, Classical.choice, Quot.sound]`;
  `gate_separates` carries `[propext, Quot.sound]`.

### Declarations of record

- Refutation: `cell_succ_ne`, `index_collide`, `ladderIndex_not_factoring`,
  `exhibited_form_refuted`, `exists_form_refuted`.
- Mechanism: `pending_run`, `idle_at`, `truth_phiP`, `tagAt_ne_succ`.
- Gate: `gate_separates`, `gate_collides_below_two`, `index_res_separates`.
- Route (C): `bounded_ladder_finite`, `finBranch_eq_ofSlicedStep`,
  `bounded_width_validates_Phi_neg`, `Phi_neg_not_valid`.

### Evidence tier

lean-lsp MCP tools were not called in this dispatch: the work was fixture construction and proof,
for which the whole-file `lake env lean` loop gives stronger evidence than a position query, and no
Mathlib name search was needed (every lemma consumed is in-tree and was read directly from source).
No search tool's rate limit was touched, and no empty-result-as-absence inference is relied on
anywhere in this report.
