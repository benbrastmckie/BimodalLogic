# Research Report: Task #836

**Task**: 836 - Ladder type-preserving cell-agreement construction (the construction `CellLEZeroConstOfKappaEq` needs, left open by the refutation of `AtomPreservingCountMove`)
**Started**: 2026-11-03T00:44:39Z
**Completed**: 2026-11-03T01:52:00Z
**Effort**: 2.5 hours (reading 1.0, analysis 0.75, compiled prototype 0.75)
**Dependencies**: None (parent task 761 is the consumer; its plan 08 gates Phases 11.6, 11.7 and 12-18 on this report)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (2241 lines, read in full at the header, splice, index-map, cell-bridge, transport and obligation sections), `CounterQuotient.lean` (`kappa`, `clipIdx`, `ParamsOk` (K1)-(K4), `Bof`, `cascadeBound`, `objCycleLens`, `prodCycleLens`, `SatCl`), `RunLayer.lean` (`Drift`, `Count`, `Rlad`, `exists_rlad_hist_of_walk`), `LadderModel.lean` (`Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`), `Certificate.lean` (`locPred`, `linkPred`, `linkPredB`, `cohIdle`), `AnchorLayer.lean` (`box_mem_tpOf_iff`), `FormalSystem/PlusLanguage/PlusTruth.lean` (`PlusTruth.untl_iff`, `snce_iff`, `atom_iff`, `neg_iff`, `and_iff`)
- Task 761 record: `plans/08_cell-agreement-construction-handoff.md` (Overview, Phases 11.2, 11.6, 11.8, Lean Challenge Statements), `handoffs/phase-11.5-handoff-20261102T215926Z.md`, `issues.jsonl` entries `iss_1793655395836_WUA3Kc`, `iss_1792373250168_HQM6Je`, `iss_1792404913585_GTqC0g`, `iss_1792402772629_BNdiN5`, `iss_1792401253858_iZyQNA`, `prototype/step0-budget-check.lean`, `prototype/alt-history-cell-check.lean` (header)
- Wired probes: `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` (Probe761C, read in full), `ladder-splice-type-refutation.lean` (Probe761S, header and non-claims)
- Literature (briefing entries): Hodkinson-Wolter-Zakharyaschev 2000, chunks 27-28 (Lemma 17, Definition 18, Lemma 19); Thomas 1997 (composition method summary; PDF not in corpus); Libkin 2004 ch. 3 (Lemma 3.7, composition for linear orders)
- Lean MCP: `lean_local_search` reported `index: unavailable` throughout, so every existence/absence claim below is grep-backed (degraded tier), as recorded in this task's `issues.jsonl`
- Compiled this session: `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/cell-obligation-refutation.lean` (468 lines, `lake env lean` through `lake-build-guard.sh`, exit 0, 0 errors, 0 warnings, six `#print axioms` lines all `[propext, Classical.choice, Quot.sound]`)
**Artifacts**:
- `specs/836_ladder_type_preserving_cell_agreement_construction/reports/01_type-preserving-cell-agreement-construction.md` (this report)
- `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/cell-obligation-refutation.lean` (compiled prototype; NOT a wired probe, NOT gate-covered)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The obligation itself is refuted, and the refutation is compiled.** `CellLEZeroConstOfKappaEq` is FALSE at Probe761C's own two-state object, at the periodicity fixpoint's OWN parameter outputs (`Tcof`, `Tnof`, `Pof`, `Bof`), for a stab-free closure. `Probe836A.cellLEZeroConstOfKappaEq_refuted` and the non-vacuity bundle `exists_refuting_cell_collision` compile standalone with no `sorry`, no axiom, no `native_decide`. This answers Q5 in the strongest form the dispatch asked for, and it is the input a third plan must receive FIRST: no construction can prove the obligation as filed, because it is false.
- **The mechanism is the register's FORWARD window, which `kappa`'s gap coordinate does not see.** The next-deadline register is `1`-Lipschitz (`nxtAt_lipschitz`) and its value at the first idle position after `z`'s region IS the countdown of the following region (`cntAt_eq_nxtAt_of_idle_pend`), so `nxtAt z ≤ cntAt z + I₁ + L₁ - 1` where `I₁`/`L₁` are the lengths of the next idle run and next region. A `U`-only formula of bounded `X`-depth (`X ψ := ⊥ U ψ`) pins `I₁ = 1`, `L₁ = 2`, hence bounds the register at `z` by `c + 2`; the states `(q, c, c + 2)` and `(q, c, c + 2 + (P + 1))` collide under `kappa` because `(K4)` sets `B = Bof = max (2·dBack + 1) 2 = 2` for an `S`-free formula and clips both gaps at `2B`. The type carrying that formula lies in the first cell and in no type of the second. `(K4)` accounts for the BACKWARD exactness depth `dBack` only; the symmetric forward quantity is absent from `ParamsOk`, and the clipped-gap design of `kappa` is unsound against it for every `B ≥ 2` (the formula family scales with `B`).
- **Q1 is settled affirmatively on paper, clause by clause, for BOTH the duplication and the deletion of a type-respecting block**, at the full statement `∀ w, tpOf σ' w = tpOf σ (spliceIdx u l w)` (every position, block interiors included), with the planner's device confirmed against `PlusTruth.untl_iff`/`snce_iff` (strict witness, guard strictly between, nothing required at the evaluation point or the witness) and against HWZ 2000 Lemma 17, whose `⇒`-case for `ψ₁ U ψ₂` is literally "apply the endpoint equality to `ψ₁ U ψ₂` itself". The type lemma needs NO pending-region hypothesis; those enter only through the admissibility layer. The exact Lean statement shape is recorded under Findings.
- **Q2: exactness is reachable certificate-free in the saturated regime only through the boundary fact "a realized stab-free pair-cycle's length lies in `prodCycleLens`"**, which consumes `(K1)`'s first conjunct. That fact is NOT circular (it uses only the Hintikka and one-step link conditions on realized types, never `certStabK`, `Dmax`, `kappa` or the agreement), but it does breach `LadderAgree.lean`'s certificate-freedom grep, so it belongs in a new module. Without it, neither pigeonhole variant (a) nor eventual periodicity (b) reaches `c + m·(P+1)` exactly; (b) is false as stated.
- **Q3/Q4: the `n` coordinate is free only inside the two Lipschitz windows, and the type-blind cascade of Phase 11.8 is not consumable by a type-preserving construction.** Re-profiling `n` over an unchanged walk is type-invisible (landed half (i)), but the ramp must fit between the pins; a region or idle run shorter than the budget cannot be lengthened type-respectingly by this device, and a tight doubling chain (regions of lengths `2^j - 1` with unit idle runs) defeats any cascade that pumps the ORIGINAL past. The refutation above is the sharper form of the same window.
- **Q6: nothing of this can live in `LadderAgree.lean`** (159 lines of headroom, and the boundary fact names `cohIdle`); the recommended placement is `RaySummary/LadderPump.lean` (type lemmas and deletion admissibility, certificate-free) plus `RaySummary/LadderChain.lean` (the realized-chain bridge), with the refutation wired as the forty-seventh probe.
- **Recommended route (a user decision, set non-blocking on `.return-meta.json`)**: wire the refutation, then repair `(K4)` with a forward exactness depth `dFwd` (the `untl` nesting depth, mirroring `dBack`) so that `B` exceeds what any closure formula can pin forward, restate `CellLEZeroConstOfKappaEq` and the filed `cellAt_const_of_kappa_eq`/`ladderRealized` against the repaired predicate, and only then plan the construction from the Q1 lemmas. Task 761's prohibition on strengthening `ParamsOk` was written against a true-but-hard statement; it cannot bind against a false one.

## Context & Scope

The depth-`0` cell-level agreement of task 761's cell-level route is stated in `LadderAgree.lean`
as the Prop-valued schema `CellLEZeroConstOfKappaEq`: under `ParamsOk`, for a stab-free closure
and a `kappa`-collision between two admissible counter pairs at the same object state, the cells
`cellAt (ladderModel …) φ (z, ⟨(q, c, n), _⟩) z` and `cellAt … (z, ⟨(q, c', n'), _⟩) z` are
EQUAL. Its named construction `AtomPreservingCountMove` was refuted by Phase 11.5 (Probe761C);
the dispatch asked for the construction that would replace it — one preserving the realized TYPE
without preserving the valuation pointwise — through six questions Q1-Q6, with Q5 asking whether
the obligation itself has a separating object before a third plan is written.

Research answered Q5 first, because it decides what the other five are about. The answer is a
compiled separating object. The remaining questions are answered as inputs to the REPAIRED
obligation the plan will have to state, and every answer below says which of its claims are
verified clause-by-clause on paper, which are compiled, and which are open.

Constraints respected: no certificate object is cited in any proposed construction that would
live in `LadderAgree.lean`; the one certificate-side bridge Q2 needs is named as such and
placed in its own module; nothing recommends `sorry`, an axiom, a vacuous definition, or a
raised parameter as a workaround; the only parameter change proposed is a repair to a condition
shown to be too weak by a compiled refutation.

## Findings

### Codebase Patterns

- **The two layers and their bridge.** Replacement constructions are stated on functions
  `g : ℤ → LadderState Q pend` stepping along `RladAdm` (`IsLadderPath`); types are stated on
  `WorldHistory`s of `ladderFrameAdm`; `exists_hist_of_isLadderPath`,
  `exists_isLadderPath_of_hist` and `mem_cellAt_ladder_iff` identify them, the last reading the
  cell at `(z, x)` as `{tpOf … τ z | g ladder path, g z = x, τ.state t = (t, g t)}` with offset
  `0`. Every construction below is performed on `g` and read through this bridge.
- **What the counters are.** `Count` (`RunLayer.lean:261`) constrains the countdown only:
  pend-to-pend decrements, pend-to-idle requires `0`, idle-to-pend sets the new countdown to the
  register (`cntAt_eq_nxtAt_of_idle_pend` — THE PIN), idle positions carry `0`. The register
  `nxtAt` is constrained ONLY by `Drift` (`1`-Lipschitz, `nxtAt_lipschitz`,
  `nxtAt_lipschitz_two_sided`) and by the pins. Consequently a region start's countdown equals
  the region's length minus one (`cntAt_sub_of_pend`, `not_pend_of_count`), so each pin's VALUE is
  forced by the walk and only the register's path between pins is free.
- **The two windows.** Backward: `cntAt_le_nxtAt_succ_of_idle_past` (`c ≤ n + 1` whenever an idle
  position lies in the past) and its contrapositive `pend_past_of_nxtAt_lt`. Forward (derived in
  this session from the same two facts, NOT landed as a named lemma): if the first idle position
  after `z`'s region is `e = z + c + 1`, the next idle run has length `I₁` and the next region
  length `L₁`, then `nxtAt (e + I₁ - 1) = L₁ - 1` and Lipschitz over `c + I₁` steps gives
  `nxtAt z ≤ c + I₁ + L₁ - 1`. `RunLayer.lean`'s `forward_window` (`|L - n| ≤ c + j`) is the
  same inequality in the certificate layer's vocabulary.
- **The truth clauses.** `PlusTruth.untl_iff` / `snce_iff` (`PlusTruth.lean:140-146`) are strict
  on the witness (`t < s`), require the guard strictly between (`t < r → r < s`), and require
  nothing at `t` or at `s`. `PlusTruth.box_iff` quantifies over histories at the SAME time, but
  `box_mem_tpOf_iff` (`AnchorLayer.lean:186`) shows the `□`-bit is independent of BOTH history
  and time, so `box_mem_tpOf_transfer` carries a `□` letter across a time shift — which the Q1
  lemma needs, since `spliceIdx` moves positions.
- **The landed inductions' shape.** `truthAt_iff_of_lab_eq_of_stabPinned` and half (i) induct on
  the formula with the predicate `StabPinned L`, one case per clause, and the `U`/`S` cases use
  the IH at other positions of the same history with the identity index map. The Q1 lemma is the
  same induction with a NON-identity, non-monotone index map and one extra hypothesis consumed in
  exactly the two seam sub-cases.
- **`kappa` and `(K1)`-`(K4)`.** `kappa` has five coordinates: `min c Tc`, `c % (P+1)`,
  `min n Tn`, `n % (P+1)`, `clipIdx B c n` where `clipIdx` clips `n - c` to `[-B, B]`.
  `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 ≤ B`, `dBack` counting `snce` nesting only;
  `Bof = max (2 * dBack φ + 1) 2`. No conjunct of `ParamsOk` relates `B` to the `untl` nesting
  depth, and no conjunct relates `Tc` to `P`.
- **What `prodCycleLens` requires.** `0 < l ≤ card (ProdState Q φ)`, an `l`-periodic
  `cohIdle`-walk, pending throughout, every point `SatCl`. `cohIdle x y` is `step ∧ locCoh x ∧
  locCoh y ∧ untlLink ∧ snceLink`; `locPred` constrains only the `atom`, `bot`, `imp` arms
  (`Certificate.lean:796-801`, modal and temporal arms unconstrained); `linkPred` is the strict
  one-step `U` unfolding `ψ U χ ∈ T ↔ χ ∈ T' ∨ (ψ ∈ T' ∧ ψ U χ ∈ T')` and `linkPredB` its `S`
  mirror. `SatCl x` asks for an infinite forward `cohIdle`-walk from `x`.
- **Headroom.** `LadderAgree.lean` is at 2241 lines under `set_option linter.style.longFile 2400`
  (package default 1500, `lakefile.toml:34`); its certificate-freedom grep (Phase 11.2's list:
  `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|
  LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod`) is a stated
  verification criterion of every open phase of plan 08.
- **The reserved name is claimed by nothing.** `grep -rn cellLE_zero_const_of_kappa_eq` over the
  tree hits only `LadderAgree.lean`'s docstrings (lines 2168, 2222), `specs/TODO.md` and
  `specs/ROADMAP.md`; `lean_local_search` returned the schema `CellLEZeroConstOfKappaEq` as a
  `def` with `index: unavailable`, so the grep is the evidence of record.

### External Resources

- **HWZ 2000, Lemma 17** (`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`,
  chunk 27-28; entry flagged UNVERIFIED in the briefing, read directly): for a quasimodel
  `⟨f, R⟩` with `f(n) = f(m)`, `n < m`, the DELETION `f^{≤n} ∗ f^{>m}` with runs
  `r₁^{≤n} ∗ r₂^{>m}` for `r₁(n) = r₂(m)` is a quasimodel. The `⇒`-case for `ψ₁ U ψ₂ ∈ r₁(k)`,
  `k ≤ n`: take the witness `l > k`; if `l ≤ n` done; otherwise `ψ₁ U ψ₂ ∈ r₁(n) = r₂(m)` and `r₂`
  is a run — the endpoint equality applied to `ψ₁ U ψ₂` ITSELF, with `ψ₁` at `n` supplied by the
  original guard. Their run condition is the same strict witness / strict-between guard as
  `PlusTruth.untl_iff`. This is exactly the planner's sketch; HWZ state deletion only (Lemma 19
  then builds periodicity by repeated deletion of repeating quasistates), and the duplication
  case below is its mirror with the SAME device.
- **Composition method** (Thomas 1997 as summarised in the corpus — PDF absent — and Libkin
  2004 Lemma 3.7): the rank-`k` type of `(L, a)` is determined by the types of `L^{≤a}` and
  `L^{≥a}`. The temporal-logic form used in Q3/Q4 below: along one history, the truth of every
  closure formula at positions `≥ z` is determined by the walk on `[z, ∞)` and the closure type at
  `z` (for `ψ S χ` at `w > z`: either witnessed inside `[z, w)`, or `ψ` on `[z, w)` and `ψ S χ`
  at `z`). This is why only the register, never the past walk, couples a future surgery to the
  past — and why the pins are the whole obstruction in regime B.
- **Aperiodicity (background, not consumed).** `U`/`S`-definable properties are star-free, so
  the cell at large `c` cannot count `c` modulo anything; the residue coordinate of `kappa` exists
  for the CERTIFICATE graph's cycles, not for the model-level cell. The refutation below is a
  forward-counting statement of bounded depth, which aperiodicity permits.

### Q5 first: the obligation has a separating object, and it is compiled

**Statement refuted.** `Probe836A.cellLEZeroConstOfKappaEq_refuted :
¬ CellLEZeroConstOfKappaEq stepC pendC fwdC bwdC labC chiD TcC TnC PC BC`, where the object is
Probe761C's (`Qc = Fin 2`, state `0` pending, `1` idle, `stepC` complete, `labC` carrying the
pending bit as the atom `p`), `TcC/TnC/PC/BC` are `Tcof/Tnof/Pof/Bof` at `chiD`, and
`paramsOkD := paramsOk_params …` discharges `ParamsOk` with NO parameter touched. The
non-vacuity bundle `exists_refuting_cell_collision` carries, in one statement: `n ≠ n'`, the
`kappa`-collision, `ParamsOk`, stab-freedom of the closure, a ladder path through EACH of the two
states, and the refutation.

**The formula.** `chiD := a U (¬a ∧ X(a ∧ X(a ∧ X ¬a)))` with `X ψ := ⊥ U ψ` (`X_iff` compiles
`PlusTruthAt M τ t (X ψ) ↔ PlusTruthAt M τ (t + 1) ψ` over `ℤ`). Read at a pending position `z`
with countdown `c`: the guard forces the witness to be the region's first idle position
`z + c + 1` (`cntAt_sub_of_pend`, `not_pend_of_count`), and the `X`-chain pins the next idle run
to length exactly `1` and the next region to length exactly `2`. `dBack chiD = 0`, so
`BC = Bof = 2` (`BC_eq_two`).

**The collision.** `c0 := max TcC TnC`; the pairs are `(c0, c0 + 2)` and
`(c0, c0 + 2 + (PC + 1))`. Both clipped coordinates sit at their thresholds, the residues agree
by `Nat.add_mod_right`, and `clipIdx 2 c0 (c0 + 2) = 4 = clipIdx 2 c0 (c0 + 2 + (PC + 1))` because
both gaps are `≥ B = 2` (`kappa_D`).

**The witness in the first cell** (`gD`, `gD_isPath`, `chiD_true`): pending on `(-∞, c0]` with
countdown `c0 - v`, idle at `c0 + 1`, pending at `c0 + 2, c0 + 3` with countdowns `1, 0`, idle
from `c0 + 4`; register `c0 + 2` on `(-∞, 0]`, descending by one per step to `1` at `c0 + 1`
(the pin for the length-`2` region), constant `1` after. The descent of `c0 + 1` over `c0 + 1`
steps is exactly Lipschitz-tight. `chiD` holds at `0` along it.

**Why the second cell has no such type** (`not_chiD_of_path`): any ladder path `g'` through
`(0, c0, n')` at `0` along which `chiD` holds at `0` has its witness at `c0 + 1` (idle), pending
at `c0 + 2, c0 + 3`, idle at `c0 + 4`; so `cntAt g' (c0 + 3) = 0` (`cntAt_eq_zero_of_pend_idle`),
`cntAt g' (c0 + 2) = 1` (`cntAt_succ_of_pend_pend`), `nxtAt g' (c0 + 1) = 1`
(`cntAt_eq_nxtAt_of_idle_pend`), and `nxtAt_lipschitz` over `c0 + 1` steps gives
`n' ≤ c0 + 2`. With `n' = c0 + 2 + (PC + 1) ≥ c0 + 3`, contradiction. The type
`tpOf … τ 0 ∋ chiD` is therefore in `cellAt … (0, ⟨(0, c0, c0 + 2), _⟩) 0` and in no member of
`cellAt … (0, ⟨(0, c0, c0 + 2 + (PC + 1)), _⟩) 0`, so the two cells differ.

**What this does and does not refute.** It refutes the schema exactly as written, at the
fixpoint's own outputs, with `ParamsOk` discharged by the landed `paramsOk_params` — so it also
refutes task 761's filed Challenge statements `cellAt_const_of_kappa_eq` and `ladderRealized`
(the fibre equation implies the agreement) at the SAME tuple, since both quantify over every
`ParamsOk` tuple. It refutes nothing about half (i), the atom-valuation agreement, `altWalkPath`,
the splice admissibility layer, or `ladderSound`/`ladderLift` (which carry no `ParamsOk`). The
mechanism is not the `c`-coordinate obstruction of Probe761C (the two states here have the SAME
countdown); it is the `n`-coordinate: Probe761C's `nxt_free` was free only because its object had
no region start in the FUTURE either, and the dispatch's own Q4 anticipated the forward window
"`cntAt_le_nxtAt_succ_of_idle_past` / `pend_past_of_nxtAt_lt` impose" — the mirror of that window,
forward, is what the cell reads.

**The refutation scales with `B`.** For any `B ≥ 2` take `chiD_B` with `I₁ = 1` and
`L₁ = B` pinned by an `X`-chain of depth `B + 2` (still `S`-free, so `(K4)` admits `B`): the
witness has `n = c + B` (tight descent to the pin `B - 1`) and the partner `n' = n + (P + 1)`
needs `n' ≤ c + B`. So no choice of `B` as a function of `dBack` alone repairs `(K4)`; the
missing quantity is a FORWARD exactness depth. Conversely, a closure formula of `untl` nesting
depth `d` can pin `I₁ + L₁` only up to about `d`, so `B ≥ dFwd φ + 2` (precise constant to be
fixed by the proof) is the shape of the repair; whether the repaired statement is TRUE is then
the construction question Q1-Q4 address, not another refutation this research found.

**The prototype is not wired.** It lives under `specs/836_…/prototype/` and compiles with
`lake env lean` through the build guard; promoting it to
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` and a row in
`check-evidence-probes.sh` is the plan's first phase (Q6).

### Q1: the type-preserving duplication and deletion of a type-respecting block

**Answer: yes, both, at EVERY position** (not only outside the block), and the planner's
device is exactly right and exactly sufficient. The lemma is a statement about truth along two
histories related by an index map; it needs no pending-region hypothesis, no `ParamsOk`, no
divisibility, and no pin condition — those belong to the admissibility layer that produces the
second path.

**Duplication, Lean statement shape** (to be pinned as a Challenge statement):

```lean
theorem tpOf_eq_spliceIdx_of_tpOf_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (u : ℤ) (l : ℕ) (hl : 0 < l)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ w : ℤ, objAt g' w = objAt g (spliceIdx u l w))
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
      = tpOf (ladderModel step pend fwd bwd lab) φ σ (spliceIdx u l w)
```

with `v := u + l` the block's far endpoint. The truth-level form inducts on `ψ` with the invariant
`ψ ∈ plusSubformulaClosure φ` (closure lemmas `plusClosure_untl_left/right`,
`plusClosure_snce_left/right`, `plusClosure_box`, and the `imp` projections pass it to
subformulas), proving `∀ w, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ`. The
pinned-letter form (`StabPinned L` with an `hL` hypothesis at `(w, spliceIdx u l w)`) is the
shape Phase 11.6 would consume and should be the one stated, with the stab-free theorem as its
`L := fun _ => False` instance — exactly as half (i) is organised.

**Deletion, Lean statement shape**: the same with `delIdx u l w := if w < u then w else w + l`
(strictly monotone; image `ℤ \ [u, v)`) in place of `spliceIdx`, and the same `hty`.

**Proof, verified clause by clause on paper this session.** Let `E(θ)` abbreviate the endpoint
equality `truth(σ, u, θ) ↔ truth(σ, v, θ)` for `θ ∈ closure`, which `hty` gives through
`mem_tpOf_iff`.
- `atom`: `hobj` and `atom_iff_pend`-style unfolding. `bot`, `imp`: structural. `box`:
  `box_mem_tpOf_transfer` (times differ, so `Iff.rfl` is NOT available here; the transfer lemma
  is). `stab`: vacuous under `hno` (or `hL` in the pinned form).
- `untl ψ χ`, duplication, `σ' → σ`: witness `s > w` on `σ'`, guard on `(w, s)`. If `w` and `s`
  lie on the same side of the seam `u + l`, `spliceIdx` is an order isomorphism there — done by
  the IH. If `w < u + l ≤ s` and `s - l > w`: witness `s - l`, and the guard set `(w, u + l) ∪
  [u, s - l)` retracts onto a superset of `(w, s - l)`. If `s - l ≤ w` (the witness folds back
  onto or before `w`, forcing `w ∈ [u, u + l)`): the IH gives on `σ`: `χ` at `s - l ∈ [u, w]`, `ψ`
  on `(w, v)` and on `[u, s - l)`. Sub-case `s - l > u`: then `ψ U χ` holds at `u` on `σ`
  (witness `s - l`), so by `E(ψ U χ)` it holds at `v` with some witness `s'' > v`; `ψ` at `u`
  (from `[u, s - l)`) gives `ψ` at `v` by `E(ψ)`; the guard on `(w, s'')` is `(w, v) ∪ {v} ∪
  (v, s'')`. Sub-case `s - l = u`: `χ` at `u`, so `χ` at `v` by `E(χ)`, witness `v > w` with guard
  `(w, v)`. This is HWZ's `⇒`-case transported to the duplication.
- `untl`, duplication, `σ → σ'`: witness `s₀ > spliceIdx w`. For `w ≥ u + l` shift by `l`. For
  `w < u`: if `s₀ < v` take `s₀`, else take `s₀ + l` (guard `(w, v) ∪ [u, s₀)` retracted, both
  inside `(w, s₀)`). For `w ∈ [u, v)` with `s₀ ≥ v`: if `s₀ = v`, `χ` at `v` gives `χ` at `u`
  (`E(χ)`) and the witness `u + l` on `σ'` works with guard `(w, v)`; if `s₀ > v`, `ψ` at `v`
  gives `ψ` at `u`, `ψ U χ` at `v` gives `ψ U χ` at `u` with witness `s₁ > u`: if `s₁ ≤ w` use
  `s₁ + l` (guard retracts to `(w, v) ∪ [u, s₁)`), if `w < s₁ < v` use `s₁`, if `s₁ ≥ v` then `ψ`
  on `[u, v)` and the witness `s₀ + l` closes.
- `snce ψ χ`: the mirror, with the fold now in the FIRST copy (`w ≥ u + l`, witness
  `s ∈ [w - l, v)`): `ψ S χ` at `v` on `σ` from the retracted witness, hence at `u` by
  `E(ψ S χ)`, with `ψ` on `[u, w - l)` supplied by the retracted guard. Converse symmetric,
  using `E(ψ)` at the one position (`u`) the retracted guard misses.
- Deletion: `delIdx` is monotone, so witnesses transport forward trivially; the only gap is the
  deleted block `[u, v)` inside a guard interval or carrying the witness, and the same four
  sub-cases (`s + l > v` / `= v`, `s₀ ∈ [u, v)` with `s₀ > u` / `= u`) close them through
  `E(ψ)`, `E(χ)`, `E(ψ U χ)` and their `S` mirrors. This is HWZ Lemma 17 verbatim.

**Conventions confirmed.** Strictness is essential and consistent across all three sources:
the witness is strictly later, the guard is required strictly between, and `ψ` is required
neither at the evaluation point nor at the witness — in `PlusTruth.untl_iff`, in
`untl_mem_tpOf_iff`, and in HWZ's run condition. The device uses the hypothesis for `ψ U χ`
itself and never the induction hypothesis for it; `E(ψ)`/`E(χ)` are used at exactly one position
each (`u` or `v`), never at interior positions.

**Hypotheses the admissibility layer adds** (not the type lemma): for duplication,
`pend (objAt g u) = true`, `l ≤ cntAt g u` (block inside one region, `cntAt_sub_of_pend`),
`objAt g u = objAt g (u + l)`, and the pin side condition of `exists_spliced_ladderPath` (or the
pending-forever regime, `exists_spliced_ladderPath_of_pend_past`). For deletion the mirror
`delObj`/`delCnt` with the three `Count` readings and a pin condition that LOWERS the region's
pin by `l` — not landed; its proofs mirror `spliceCnt_idle/pend_pend/pend_idle` and
`exists_spliced_ladderPath_of_pend_past` line for line.

**Existence of the block.** `card Q * 2 ^ |closure| + 1 ≤ Tc` (`step0-budget-check.lean`,
`budget_le_Tc`), so a region of countdown `≥ Tc` after `z` carries two positions with equal
`(objAt, tpOf)` at distance `l ≤ card (ProdState Q φ)` — the pigeonhole is
`Fintype.exists_ne_map_eq_of_card_lt` on `Fin (budget + 1) → Q × Finset PlusFormula`, with the
type component ranging over `(plusSubformulaClosure φ).powerset` (`tpOf_subset_closure`-style
membership, available through `mem_tpOf_iff`).

### Q2: reaching the exact target `c + m·(P+1)`

The saturated-regime collision (`eq_or_both_ge_of_min_eq`, `kappa_eq_components`) puts
`c, c' ≥ Tc` with `c' = c + m·(P + 1)`, `m ≥ 1` arbitrary. Duplicating a type-respecting block of
length `l` `d` times moves `cntAt z` by exactly `d·l` (`spliceCnt_add_of_mem_region`, iterated;
the Q1 lemma keeps the type at `z`); deleting moves it by `-d·l`. The target is reached iff
`m·(P + 1)` lies in the set of shifts the available block lengths generate.

- **(a) Pigeonhole on `(objAt, tpOf, position mod (P + 1))`.** Yields `l = d·(P + 1)` with
  `1 ≤ d ≤ budget`, but needs `budget·(P + 1) + 1` positions in the region, and NO conjunct of
  `ParamsOk` bounds `P` by `Tc` (`P + 1` is a common multiple of up to `card (ProdState Q φ)` cycle
  lengths; `Tc ≥ cascadeBound` is independent of it). Even where available it still needs
  `d ∣ m`: duplicating a `d·(P+1)`-block `k` times reaches `c + k·d·(P+1)`, and a second block of
  length `d'·(P+1)` only widens this to multiples of `gcd(d, d')·(P+1)`. So (a) needs `d = 1` or a
  coprime pair, neither guaranteed.
- **(b) Eventual periodicity of the realized `(objAt, tpOf)` sequence with period dividing
  `P + 1`.** FALSE as stated: inside a pending region the walk is any pending `step`-path (on the
  two-state pending graph `{0 ↔ 1, 0 → 0}` the walk `0 1 0 0 1 0 0 0 1 …` is aperiodic, and so are
  its types). HWZ obtain periodicity by CONSTRUCTING a periodic quasimodel through repeated
  deletion (Lemma 19), never by proving the given one periodic. A model-level pumping lemma of
  that shape would be (a)/(c) in disguise.
- **(c) The boundary fact.** A type-respecting block `(u, v)` with every position pending is a
  closed walk in the product graph `Q × ClType φ` whose consecutive pairs are REALIZED
  `(objAt, tpOf)` pairs along one history. Its length lies in `prodCycleLens step pend lab φ`
  provided: `locCoh` holds at every realized pair (the `atom`/`bot`/`imp` Hintikka conditions,
  which `atom_mem_tpOf_ladder_iff`, `bot_not_mem_tpOf` and `imp_mem_tpOf_iff` give directly);
  `untlLink`/`snceLink` hold across consecutive realized pairs (the strict one-step unfoldings,
  derivable from `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff` over `ℤ` by splitting the witness at
  `z + 1`); `SatCl` at every point (the `l`-periodic walk itself is the infinite forward
  `cohIdle`-walk, so it is immediate from the cycle); and `l ≤ card (ProdState Q φ)` (the
  pigeonhole budget, `card_prodState`). Then `(K1)`'s FIRST conjunct `∀ l ∈ prodCycleLens, l ∣ P+1`
  (`hp.1.1`) gives `l ∣ P + 1`, and `d := m·(P + 1) / l` duplications reach the target EXACTLY.
  This is the only certificate-free-at-the-parameter-level route to exactness this research
  found, and it is exactly the route `iss_1792402772629_BNdiN5` declined.

**Is consuming (c) at depth `0` circular?** No. The recorded circularity
(`LadderAgree.lean` header, `iss_1792373250168_HQM6Je`) runs through `certStabK` — the `⊡` bits of
class-equivalent members of a certified set are collapsed, and a `⊡` bit is a cell datum
(`stab_mem_tpOf_iff_cell`) — and through `certBiInfK`; discharging THOSE on a set containing a
realized item requires the agreement. The boundary fact reads `locCoh`, `untlLink`, `snceLink`
and `SatCl` only: no `certStabK`, no `certBiInfK`, no `Dmax`, no `kappa`, no class-level object,
and for a stab-free closure `locPred`'s unconstrained `stab` arm is never reached. It is the
LOCAL, one-directional half of obligation (S) ("realized types are locally coherent"), which
does not read the agreement. What it breaches is `LadderAgree.lean`'s certificate-freedom
CONVENTION (the grep names `cohIdle`), which is a placement contract, not a proof-theoretic
cycle — hence Q6's new-module recommendation. The second recorded obstruction
(`prodPre_periodic`'s bridge to `tpOf` IS (S)/(C')) is untouched: nothing here cites
`prodPre_periodic`, `prodPreStep`, `satThreshold` or `satPeriod`.

**Route-decision input, stated as such.** Exactness via (c) is available in the saturated
regime for BOTH inclusions (the longer region deletes, the shorter duplicates; both are `≥ Tc`).
Whether to admit the bridge module is the plan's and the user's call; this research records only
that the alternative devices (a) and (b) do not reach the target.

### Q3: the pin cascade under type preservation

- **Re-profiling `n` over an unchanged walk is type-invisible.** `tpOf_eq_of_objAt_eq_of_pinned`
  / `tpOf_stabFree_eq_of_objAt_eq` (half (i)) cover it exactly: `lab` never reads `n`, and the
  `U`/`S` clauses read positions, not counters. So any register profile satisfying `Drift` and the
  pins realizes the SAME stab-free type as the original — this half of Q3 is settled by what is
  landed.
- **The ramp has two windows, not one.** Inserting a type-respecting block of length `l` after
  `z` in `z`'s region raises the region's pin (at its start `s`) by `l`. Backward: the gap to the
  previous pin at `s_prev` has slack `σ_back = (s - s_prev) - |n(s) - n(s_prev)|`, and the ramp
  fits iff `l ≤ σ_back`; with pin values forced to be region lengths minus one (`cntAt_sub_of_pend`),
  `σ_back = I₀ + 2·L_{-1} - L₀` for region lengths `L` and idle-run length `I₀`. Forward: the
  register at `z` must reach the NEXT pin, `n' ≤ c' + I₁ + L₁ - 1` — the window the refutation
  exploits. Neither window is enlarged by re-profiling alone.
- **Can a short run or region be lengthened type-respectingly?** Not by this device: a stretch
  shorter than `card (ProdState Q φ) + 1` need not contain two positions with equal
  `(objAt, tpOf)`, and lengthening it type-blindly is Probe761S's refuted move (nested
  eventualities count occurrences at any distance). Long idle runs (`≥ budget + 1`) and long
  regions CAN be pumped by any multiple of a type-respecting block they contain, with no
  divisibility needed for a past region (only `z`'s own region's shift must be exact).
- **The halving cascade and the object that defeats it.** With a short idle run before `s`,
  Lipschitz forces `L₀ ≤ 2·L_{-1} + I₀`, so region `-1` is long and can absorb half the deficit
  (`l_{-1} ≥ l/2`), passing `l/2` back — `(K2)`'s `iter_doubling` in reverse. On the TIGHT
  DOUBLING CHAIN (regions of lengths `2^j - 1`, `j = 1..J`, unit idle runs, register climbing by
  exactly `1` per step, a ladder path by `cntAt_eq_nxtAt_of_idle_pend` and `Drift`) every gap has
  slack `0`, the chain has only `≈ log₂(Tc)` pumpable regions, and the deficit `l/2^k` (floored at
  the block granularity) reaches a region too short to pump for every `l ≥ Tc/budget` — and for
  every `l` when the block granularity exceeds `1`. So NO construction that pumps the ORIGINAL
  path's past closes regime B in general.
- **What would close regime B (not landed, not proved).** A past-extension: duplicate a
  type-respecting block that SPANS a region start (so each copy carries a pin), then pump the
  copies by increasing amounts (`≤ L_copy + 1` per copy); the type at `z` is preserved by the Q1
  lemma at every step, the register is rebuilt by `exists_ladderPath_of_walk` from the new pins,
  and the time shift of `z` is absorbed by `cellAt_eq_cellAt`/`tpOf_timeShift`. Its existence
  condition (a spanning block, which needs two idle-run positions with equal `(objAt, tpOf)`, or a
  long idle run) is NOT guaranteed by `ParamsOk` as far as this research could see — the
  `2^{card ProdState}·(tIdle + 2)` shape of `cascadeBound` is suggestive of a pigeonhole over the
  doubling chain's region starts, but no proof is in hand. This is the open combinatorial core of
  the repaired obligation in regime B.
- **Is Phase 11.8 a prerequisite?** No, and it is not reusable either. Phase 11.8's cascade
  lengthens idle runs by repeating an idle object state (type-blind) and serves
  `exists_spliced_ladderPath_of_idle_past` for (C') at the ADMISSIBILITY level; a type-preserving
  construction may only pump type-respecting blocks, so it needs its own cascade (the
  past-extension above) and cannot cite 11.8's. The two share the finiteness and sizing facts of
  Phase 11.2 (regime exhaustiveness via `clipIdx_regime_of_eq`, finiteness of pinned regions
  between an idle position and the splice point), which are independent of which cascade consumes
  them.

### Q4: the `n` coordinate by collision regime

`kappa_eq_components` with `c < c'` (both `≥ Tc`, equal residues) leaves these cases for `n`:
- **`n = n'`** (exact below `Tn`, or equal above). The duplication after `z` raises `z`'s pin by
  `l = m·(P+1)`; the register must still be `n` at `z`. Regime A (`n + 2 ≤ c`, every path pending
  forever into the past by `pend_past_of_nxtAt_lt`): no pin below, the register is rebuilt freely
  with `n'(z) = n`, constrained only by the pins ABOVE — the original's, displaced by `l`
  (`exists_spliced_ladderPath_of_pend_past` discharges admissibility; the register value at `z`
  is then adjusted inside the forward window, which the displacement by `l` widens by `l`). This
  regime is fully constructible from landed material plus the Q1 lemma plus (c). Regime B (idle
  in the past): the backward ramp of `l` must be absorbed — Q3's open past-extension.
- **`n' = n + m·(P+1)` with equal clipped gap** (`clipIdx_regime_of_eq` at `2 ≤ B` keeps both
  countdowns in one regime; the common-shift family `kappa_eq_of_shift`). The register on `[s, z]`
  is the original's plus `l`, so the step-to-step profile needs no change there; the ramp is
  entirely at the backward gap before `s` (regime B) or absent (regime A). The forward window is
  unchanged in slack: `n + l ≤ (c + l) + I₁ + L₁ - 1` iff `n ≤ c + I₁ + L₁ - 1`.
- **Both gaps clipped at `B` with `n' - n ≠ c' - c`** (`n' = n + m'·(P+1)`, `m' ≠ m`, both gaps
  `≥ B`). The register at `z` must move by `m'·(P+1)` while the countdown moves by `m·(P+1)`; the
  forward window `n' ≤ c' + I₁ + L₁ - 1` then requires the NEXT idle run or region to be long
  enough, and a closure formula can pin both to be short — this is exactly the refuted case
  (`m = 0`, `m' = 1`). Under a repaired `(K4)` with `B > dFwd`, the formula can no longer pin
  `I₁ + L₁ < B`, but the construction must still LENGTHEN the next idle run or region
  type-respectingly when the original's are short — i.e. Q1 and Q2 recur in the next region, and
  the same past-extension device is needed FORWARD. So the honest answer to Q4's last clause is:
  a re-profile of `n` alone suffices only inside the two Lipschitz windows; outside them a forced,
  type-respecting lengthening of the next (or previous) region is required, and it is not landed.

### Q6: placement and the consumed interface

- **`LadderAgree.lean` cannot host the construction.** 159 lines of headroom under its
  `longFile 2400` baseline against an estimated 350-600 lines (type lemma in pinned form with
  six clause cases and four seam sub-cases each for `U` and `S`, the deletion mirror of the
  splice layer, the `(objAt, tpOf)` pigeonhole, the regime-A assembly), and the Q2 bridge names
  `cohIdle`/`SatCl`/`prodCycleLens`, which its certificate-freedom grep forbids. Raising the
  baseline again is not the right move: the module's docstring defines it as "one argument about
  ladder paths", and the bridge is a different argument.
- **Recommended modules.**
  - `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — imports `LadderAgree`
    only; certificate-free under the SAME grep; carries `delIdx`, `delObj`, `delCnt`, the three
    `Count` readings and `exists_deleted_ladderPath(_of_pend_past)`, the Q1 lemmas in pinned and
    stab-free form, the `(objAt, tpOf)` pigeonhole `exists_typeBlock_of_budget_le_cnt`, and the
    regime-A assembly `exists_ladderPath_through_shifted_of_pend_past` (a path through
    `(q, c + d·l, n')` realizing the same stab-free type at `z`).
  - `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — imports `LadderPump`
    and `CounterQuotient`; the bridge `realized_typeBlock_mem_prodCycleLens` (Q2 (c)) and the
    exact-shift corollary consuming `hp.1.1`. This module is NOT certificate-free by design and
    says so in its header; the depth-`0` theorem under the repaired `(K4)` would be stated here,
    and `LadderAgree.lean` keeps its contract intact.
  - `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` — the
    prototype promoted verbatim as the forty-seventh wired probe, with a
    `check-evidence-probes.sh` row beside Probe761C's (line 1777 of the deployed script).
  - Wiring per the in-repo pattern: axiom pins in
    `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (currently at `longFile 1800`),
    generated inventory blocks in `RaySummary/README.md` via `check-module-invariants.sh
    --emit-inventory`, `typst/generated/status.typ` line counts.
- **Landed lemmas consumed, by module.** From `LadderAgree.lean`: `spliceIdx`, `spliceEmb`,
  `spliceIdx_of_lt/ge`, `spliceObj_eq_objAt_spliceIdx`, `spliceIdx_spliceEmb`, `spliceObj`,
  `spliceCnt`, `spliceCnt_add_of_mem_region`, `spliceObj_eq_of_le`, `exists_ladderPath_of_walk`
  (with its `hpins`/`hn₀` side conditions), `exists_spliced_ladderPath`,
  `exists_spliced_ladderPath_of_pend_past`, `spliced_at_region`, `pinCompat_of_ladderPath`,
  `cntAt_eq_nxtAt_of_idle_pend`, `cntAt_sub_of_pend`, `not_pend_of_count`, `nxtAt_lipschitz`,
  `nxtAt_lipschitz_two_sided`, `pend_past_of_nxtAt_lt`, `cntAt_le_nxtAt_succ_of_idle_past`,
  `kappa_eq_components`, `eq_or_both_ge_of_min_eq`, `clipIdx_regime_of_eq`, `kappa_eq_of_shift`,
  `exists_hist_of_isLadderPath`, `mem_cellAt_ladder_iff`, `atom_mem_tpOf_ladder_iff`,
  `box_mem_tpOf_transfer`, `untl_mem_tpOf_iff`, `snce_mem_tpOf_iff`, `StabPinned`,
  `stabPinned_false_of_mem_closure`, `tpOf_eq_of_objAt_eq_of_pinned`,
  `tpOf_stabFree_eq_of_objAt_eq`, `tpOf_stabFree_eq_of_lab_eq`. From `AnchorLayer.lean`:
  `mem_tpOf_iff`, `box_mem_tpOf_iff`, `bot_not_mem_tpOf`, `imp_mem_tpOf_iff`, `tpOf_timeShift`,
  `cellAt_eq_cellAt`. From `CounterQuotient.lean`: `kappa`, `clipIdx`, `ParamsOk`, `paramsOkK4`,
  `Bof`, `dBack`, `prodCycleLens`, `SatCl`, `card_prodState` (prototype `step0-budget-check`,
  to be promoted). From `Certificate.lean` (bridge module only): `cohIdle`, `locCoh`, `locPred`,
  `untlLink`, `snceLink`, `linkPred`, `linkPredB`, `ProdState`, `ClType`. From `PlusTruth.lean`:
  `untl_iff`, `snce_iff`, `atom_iff`, `neg_iff`, `and_iff`, `box_iff`, `bot_false`.

### Recommendations

1. **Wire the refutation first** (one phase, interface tier): promote the prototype to the
   evidence directory, add the `check-evidence-probes.sh` row, and record in `LadderAgree.lean`'s
   obligation docstring and in `RaySummary/README.md` that `CellLEZeroConstOfKappaEq` is REFUTED
   at the fixpoint's own outputs, with the mechanism (forward Lipschitz window vs. the gap clip).
   Do not delete the schema: its refutation is a theorem about a named object, on the precedent
   of `AtomPreservingCountMove`.
2. **Decide the repair of `(K4)` before any construction phase** (the user decision carried on
   `.return-meta.json`). Recommended: add `dFwd : PlusFormula → ℕ` (the `untl` nesting depth,
   mirroring `dBack`), strengthen `paramsOkK4` to `2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧
   2 ≤ B` (the factor `2` is the conservative mirror of the backward bound; the proof of the
   repaired statement fixes the constant), redefine `Bof` accordingly, re-prove `paramsOk_params`
   and `not_paramsOk_allZero`, and re-check every landed consumer of `B` (gate 1's
   `gate1_cell_ne` reads the gap at distance `2`, which a larger `B` preserves). This changes the
   recorded Challenge signatures only through the definition of `ParamsOk`, not their text.
3. **Then plan the construction in two certificate-free pieces and one bridge**, in this order:
   the Q1 type lemmas (duplication, deletion, pinned form), the deletion admissibility mirror,
   the regime-A assembly, the Q2 bridge and exact shift — each a Lean Challenge statement with the
   shapes recorded above. State the depth-`0` theorem under the repaired `(K4)` as the Goal of the
   bridge module.
4. **Treat regime B as the open core and probe it before committing hours**: compile the tight
   doubling chain as a prototype (`tightChain_isLadderPath`, `tightChain_slack_zero`) and attempt
   the past-extension on it for one `l`; if the spanning-block existence condition cannot be
   derived from `ParamsOk`, the repaired obligation must be restated for regime A (the
   pending-forever-into-the-past class, where it is constructible) and regime B escalated as a
   `[BLOCKED]` design question rather than approached by a fourth construction.
5. **Do not re-enter Phase 11.6 of task 761 on any base case other than a LANDED theorem under
   the repaired predicate**; and note for its planner that the pinned-letter case of the pumping
   lemma at depth `≥ 1` needs the shift at every position before the block to be
   `kappa`-invisible, which forces the pumped block's length to be `≡ 0 (mod P+1)` and its
   position at countdown `≥ Tc` — a constraint the depth-`0` construction does not have.

## Decisions

- Answered Q5 before Q1-Q4 and compiled the separating object rather than sketching it: a
  compiled refutation is the one input that changes what the plan may state, and the dispatch
  asked for a compiled probe either way.
- Compiled the refutation at `B = Bof` (the fixpoint's own output) rather than at a hand-picked
  `B = 2`, so that the universal quantification over `ParamsOk` tuples is not the only thing
  refuted.
- Kept the prototype under `specs/836_…/prototype/` and did not wire it: wiring touches the
  evidence gate and the README inventory, which is implementation work, and this dispatch's
  deliverable is the report.
- Verified the Q1 lemma on paper in all sub-cases rather than attempting to compile it: its
  Lean form is a 200-plus-line induction whose value to the plan is its STATEMENT shape, which
  is recorded; its proof is the construction phase's work.
- Did not propose weakening the obligation to "cells agree up to the register's forward window"
  or similar: the record's own prohibition against positionwise narrowings and quiet restatements
  applies, and the repair that keeps the filed Goals' text is the parameter condition.

## Risks & Mitigations

- **The repaired `(K4)` may still be insufficient.** Mitigation: the refutation family in Q5
  shows exactly which quantity the gap clip must dominate (`I₁ + L₁` pinned forward); before
  re-proving `paramsOk_params`, compile a second probe at the repaired predicate attempting the
  same separation with a formula of `untl` depth `≥ B` — it must fail to be constructible.
- **Regime B may be genuinely open under the repaired predicate.** Mitigation: Recommendation 4;
  the regime split is already a landed lemma (`clipIdx_regime_of_eq`), so a regime-A-only
  theorem is statable without narrowing by position.
- **The Q2 bridge may be read as the recorded circularity.** Mitigation: its statement names no
  class-level or certificate-set object; the plan should carry a grep criterion on the bridge
  module forbidding `certStabK|certBiInfK|certAdmK|Dmax|kappa|prodPre_periodic|satThreshold|
  satPeriod` so the distinction is mechanical.
- **Changing `ParamsOk` ripples into `CounterQuotient.lean`, the typst records and the
  Challenge snapshot.** Mitigation: it is a definitional change in one conjunct plus `Bof`; every
  consumer of `B` is reachable by `lean_references`/grep on `paramsOkK4` and `Bof`, and the
  Challenge statements reference `ParamsOk` by name, so their text is unchanged.
- **The `lean_local_search` index was unavailable throughout.** Every "claimed by nothing" and
  "not landed" claim here is grep-backed; the plan should re-run the two greps
  (`cellLE_zero_const_of_kappa_eq`, `tpOf_[A-Za-z_]*_of_splice`) at its own authoring time.

## Tactic Survey Results

The one proof developed this session is a model-level refutation on a concrete object, not a
goal for automation; the survey below records what the compiled prototype actually used.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `IsLadderPath` of the piecewise witness path (six position cases) | `rcases lt_trichotomy` + `rw` of explicit evaluation lemmas + `simp only [Count, pendC_zero, pendC_one, Bool.false_eq_true, if_true, if_false, …]` + `omega` | success | explicit positions (`_` placeholders defeat `by omega` inside `rw`); `Int.toNat` handled by `omega` |
| `Drift` of the piecewise register | `unfold Drift nD; split_ifs <;> omega` | success | none |
| `X ψ` one-step reading over `Duration` | `obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s` then `Int.lt_add_one_iff`, `Int.lt_iff_add_one_le`, `lt_of_le_of_ne`, `omega` | success | `omega` cannot see hypotheses typed at the frame's `Duration`; substitute an `ℤ`-typed copy first |
| `kappa` collision with one coordinate shifted | `simp only [kappa, Prod.mk.injEq, Fin.mk.injEq, true_and]` + `omega` + `Nat.add_mod_right` + `unfold clipIdx; split <;> split <;> omega` | success | `Fin.ext rfl` on the `%` coordinate hits max recursion (it unfolds `c0 := max Tcof Tnof`); the `simp only` route from `kappa_eq_of_shift` avoids it |
| `Bof … = 2` | `simp [BC, Bof, dBack_chiD]` | success | `dBack chiD = 0` by `simp [dBack, chiD, …]` |
| register bound from the pin and Lipschitz | `omega` on `natAbs`, `cntAt_eq_nxtAt_of_idle_pend`, `cntAt_succ_of_pend_pend`, `cntAt_eq_zero_of_pend_idle`, `nxtAt_lipschitz` | success | positions rewritten to `s` first with `push_cast; ring` |

`lean_multi_attempt` and `lean_hammer_premise` were not used: the prototype is a standalone
file compiled through the guard, and the LSP index was unavailable.

## Context Extension Recommendations

- **Topic**: the two Lipschitz windows of the next-deadline register (backward: landed as
  `cntAt_le_nxtAt_succ_of_idle_past`; forward: `nxtAt z ≤ cntAt z + I₁ + L₁ - 1`, derived here).
- **Gap**: `context/project/lean4/` and the `RaySummary/README.md` describe the backward window
  and `(K4)`'s `dBack` but nowhere state that the cell reads the register FORWARD through the next
  region's pin, which is the fact the gap clip must respect.
- **Recommendation**: once the forward window is landed as a named lemma, add a short
  "What the cell reads of the register" subsection to `RaySummary/README.md`'s `LadderAgree`
  entry, pairing the two windows with `kappa`'s gap coordinate and naming the refutation probe.

## Appendix

- Search queries used: `grep -rn cellLE_zero_const_of_kappa_eq` (tree-wide);
  `grep -n "Lemma 17\|splice\|f (n) = f (m)"` over the HWZ 2000 chunk directory;
  `grep -n "def untlLink\|def snceLink\|def linkPredB\|def locCoh\|def locPred"` in
  `Certificate.lean`; `lean_local_search cellLE_zero_const_of_kappa_eq` and
  `lean_local_search CellLEZeroConstOfKappaEq` (both `index: unavailable`).
- Compile log of the final prototype: `lake-build-guard.sh build --timeout 500 -- env lean
  specs/836_…/prototype/cell-obligation-refutation.lean`, exit 0, `error` count 0, `warning`
  count 0, six `#print axioms` lines each `[propext, Classical.choice, Quot.sound]`; file census
  `sorry|native_decide|^axiom|:= True|:= trivial` count 0.
- Literature references: HWZ 2000 chunks 27-28 (Lemma 17, Definition 18, Lemma 19); Libkin 2004
  ch. 3 (Lemma 3.7); Thomas 1997 corpus summary (PDF absent, per its own header).
- Task 761 records cited: plan 08 Overview (route decision and budget discussion), Phase 11.2,
  Phase 11.6 (gate note and step design), Phase 11.8, Lean Challenge Statements block; Phase 11.5
  handoff (the three options, the "genuine fork" paragraph); the five issue entries named in the
  dispatch.
