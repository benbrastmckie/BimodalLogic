# Research Report: Task #820

**Task**: 820 - Ladder counter-lift lemma, research-first, gated
**Started**: 2026-10-18T17:38:15Z
**Completed**: 2026-10-18T18:21:00Z
**Effort**: 1 research round (reading of the compiled record; one 544-line compiled prototype, 0 sorry; no library edits, nothing wired)
**Dependencies**: None (parent: task 761, which this record gates; 763 waits on 761)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/{RunLayer,LadderModel,AnchorLayer}.lean` read from source; the wired probes `ladder-cell-refutation`, `ladder-cell-index-obstructions`, `ladder-joint-index-refutation`, `closure-indexed-periodicity`, `closure-profile-gate-rerun`, `nside-modulus-gate`, `realizable-type-certificate`, `certificate-sufficiency-dovetailing`, `no-pending-forever-ray` under `specs/evidence/seam-gluing-ray-product/` -- headers in full, the definitions `coh`, `cohBi`, `certAdm` and its six fields, `Realizes`, `realizes_of_certAdm_cohBi`, `hist_path5`, `gap_le_region_age`, `region_start_beyond_depth`, `second_region_any_length`, `prodPreN_eventually_periodic`, `nside_collides` from source); the decision report `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md` (Findings 1-3, section 6, the gate recommendation); `scripts/check-evidence-probes.sh` (wiring shape); `.claude/context/project/lean4/domain/ladder-counter-observables.md`; `specs/ROADMAP.md` "Run these next"; lean-lsp MCP (`lean_local_search` for the pigeonhole lemma's module); literature: HWZ 2000 Lemma 17 (the splice lemma) read from the corpus chunk, UNVERIFIED-summary provenance, orientation only; the FTS search was degraded this round (recorded on the issue log)
**Artifacts**: - `specs/820_ladder_counter_lift_lemma_gated/reports/01_counter-lift-lemma-gated.md` (this report)
  - `specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean` (544 lines, 0 sorry, compiles clean with `lake env lean`, exit 0; research-level, NOT wired into `check-evidence-probes.sh`; axioms at most `[propext, Classical.choice, Quot.sound]`, see the appendix)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The three derived items are now theorems** (compiled this round, generic in the object, each two pins plus the `Drift` Lipschitz bound): `forward_window` (`|L - n| ≤ c + j`), `backward_constraint` (`n ∈ [c - 1, c + 2s + 1]`, with the region-start pin `c + s`), `region_doubling` (`|L' - L| ≤ L + j + 1`, so `L' ≤ 2L + j + 1`), `doubling_attained` (the bound is attained at `j = 1` on the two-state object) and `iter_doubling` (`a k + J + 1 ≤ 2^k (a 0 + J + 1)`). No pending run is needed between the pins, which is why each statement carries only the idle/pending letters at the pin positions; this is also why the three items are cheap and the lemma is not.
- **Finding 1 (new, compiled): the completeness clause of the dispatch's statement shape is FALSE, positionwise, for every finite counter quotient.** `no_positionwise_lift`: for every finite `K`, every `κ : ℕ × ℕ → K`, and every relation `R` on `Bool × K` that is SOUND for the two-state object (every consecutive pair of a history projects into `R`), some `R`-chain is the projection of no history. Mechanism: a history with a length-one region (which pins the deadline before it at `0`), an idle run whose deadline climbs by one per step to `m`, and a region of countdown `m` (which pins the deadline before it at `m`) is Lipschitz-tight; the finite quotient repeats a class along the climb (pigeonhole), and cutting the loop between the repeat leaves a locally valid chain whose two pins sit at distance `< m`. The cut is HWZ 2000's Lemma 17 splice performed on the projection: sound where the run set is free, unsound here because the run set is `Rlad`'s. Consequence: "every such chain lifts to an `RladAdm` history with the same sequence" cannot be the statement; the viable completeness clause is the **pumping form** (section 6), with the state at position `0` kept and run lengths adjusted in saturated zones.
- **Finding 2 (structural, derived, not compiled): the counters constrain an object walk through its pins only.** Along any `Rlad` history the countdown at a pending position is the number of pending positions after it in its region (forced by `Count`), the idle countdown is `0`, and the next deadline is a `1`-Lipschitz function whose only constraints are the pins (`n` at an idle end equals the following region's countdown). Hence an object walk through `q` with remaining pending count `c` is the projection of a history through `(q, c, n)` iff its pin sequence is consecutive-Lipschitz and the two pins nearest `0` lie in the forward window and the backward constraint of `n` -- the **pin lemma**, with the three compiled items as its soundness half and a McShane-style `1`-Lipschitz extension as its lift half (not compiled; the plan's first library-level target). This reduces the counter-lift lemma to (i) the pin lemma, (ii) eventual periodicity of achievable run lengths between rigid anchors in the finite certificate graph, and (iii) a feasibility computation whose outputs are `K`'s parameters.
- **Finding 3: the two hazards are not mechanisms.** *Gap shift under pumping* is the pin cascade: lengthening the current region by `P` raises its start pin by `P`, which the previous idle run absorbs (if its deadline class is saturated and its type admits repetition), else the previous region's saturated zone absorbs by re-routing `n`, else the cascade lengthens the previous region by `P` and recurses, terminating at an absorbing idle run or a pending-forever past; with the thresholds ordered (section 6, (K3)) a short region before a long one forces the idle run between them to be long, so the cascade always terminates. *Short idle runs* are the **exponential-threshold** fact: a formula of depth about `2k + 3` can pin the first region to length `0`, every idle run to length `1`, and the number of regions since to `k`, which by `iter_doubling` bounds the current region's countdown by `2^k - 2`; so `K`'s threshold must exceed `2^k - 2` for that formula -- exponential in depth, a count, computed by the cascade and not by the formula's depth. This confirms "computed, not guessed" and refutes any parameter rule polynomial in depth; it does not threaten existence.
- **Finding 4: the forced shape of `K` is refined, not widened.** For `c` beyond threshold the walk set depends on `n` only through the clipped gap `n - c` (the forward window's lower edge `n - c - j` and the backward constraint's `s ≥ (n - c - 1)/2`); the coordinates `min n T`, `n mod P` matter only when `c` is small (the window `[n - c - j, n + c + j]` then covers fewer than `P` residues, which is gate 9's separation half). Six coordinates remain the shape; two of them are conditional. No seventh coordinate; no tuple index proposed.
- **Gate table designed, not run** (Appendix A): a 4-cycle fixture `Q4 = Bool × Fin 4` with product period `4`; gates 1, 2, 9 (both halves) with their formulas, pairs and expected verdicts; the gap-shift gate (expected COLLISION with the absorber exhibited); the short-idle gate as the exponential-threshold separation `(a, 2^k - 2, n)` against `(a, 2^k - 2 + P, n + P)` for every `(T ≤ 2^k - 2, P, B)`; and the statement-shape gate, already compiled. Every row names its compiled ground.
- **A negative outcome is NOT reached.** Nothing found is a seventh mechanism resistant to every `K` of the forced shape; what was found is that the lemma must be stated in pumping form and that its parameters have a third source (the cascade bound) beside the profile period and the formula-derived clip. The ladder route stays open; what remains is proof work (Recommendations).
- Guardrails honoured: no tuple index stated as a candidate at any parameters (`K` is a carrier coordinate throughout); no seventh coordinate; no complexity claim or upper bound -- `c + j`, `2s + 1`, `2L + j + 1`, `2^k` and the enumeration over `Finset (Q × ClType φ × K)` are counts; no finiteness added (`anchorCells_finite`, `anchorCells_ncard_le` untouched); the `box`/`stab` acceptance clause kept in every statement sketched; zero debt (no Buchi/MSO lemma cited in place of a proof; HWZ Lemma 17 orients and sources nothing); Route A not entered; nothing under `FormalSystem/`, `Tests/`, `scripts/` or `specs/evidence/` edited; no `LadderCons`, `ladderRealized` or factorization lemma stated under any name.

## Context & Scope

**What was asked.** Research-first and gated: before any sufficiency attempt, compile the gate table (gates 1, 2, 9 both halves, the gap-shift gate, the short-idle gate) on a fixture with product period at least four; the first compile targets are the three derived arithmetic items; what transfers is listed and is not re-proved; obligation (4) (`certStab` per `(q, κ)`) is recorded; the hard constraints and the negative-outcome clause bind. The statement shape is explicitly not pinned.

**What this round did with that.** The dispatch's gate table is a plan for an evidence probe (`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`, the task's own `file_scope`), and a research dispatch does not write wired probes. This round therefore (a) compiled the three first compile targets as a research-level prototype under the task directory, exactly as the 819 round compiled `no-pending-forever-ray` before it was promoted; (b) analysed the lift at the level of object walks and pins, which exposed the statement-shape defect (Finding 1) and compiled its refutation; (c) designed each gate -- fixture, pair, formula, both halves, expected verdict, compiled ground (Appendix A) -- so the plan can phase the probe without re-deriving it; and (d) assessed the two hazards against the pin arithmetic (Finding 3).

**Scope limits.** No gate is RUN here (no `cellAt`, no model layer, no formula appears in the prototype); the gate verdicts in Appendix A are EXPECTED verdicts with their reasons, not compiled ones, and are labelled so. The pin lemma's lift half (the Lipschitz extension) is stated and not compiled. The semantic periodicity of realizable types along long regions and idle runs (obligation (1)'s semantic half) is used as an assumption in section 6 and is named as such.

## Findings

### Codebase Patterns

#### 1. Verified starting state (read from source this round)

| Object | Where | What it fixes |
|---|---|---|
| `Count px py c n c'` | `RunLayer.lean:261-262` | pending→pending `c' + 1 = c`; idle→pending `c' = n`; →idle `c' = 0 ∧ (px → c = 0)` |
| `Drift n n'` | `RunLayer.lean:254` | `n' ∈ {n - 1, n, n + 1}` at every step |
| `Rlad step pend` | `RunLayer.lean:268-271` | `step ∧ (idle source → c = 0) ∧ Drift ∧ Count`; time-invariant |
| `Adm`, `LadderState`, `RladAdm`, `ladderModel` | `LadderModel.lean` | the admissible carrier; valuation reads `q` only |
| `cellAt`, `stab_mem_tpOf_iff` | `AnchorLayer.lean:140-220` | a cell is a set of closure types per STATE; the `stab` bit is per cell |
| `coh`, `cohBi` | dovetailing `:864-868, 1118-1120` | `step ∧ pend x ∧ pend y ∧ locCoh ∧ locCoh ∧ untlLink (∧ snceLink)` -- both endpoints pending |
| `certAdm` | dovetailing `:1012-1014` | `certLoc ∧ certBiInf ∧ certFwd ∧ certBwd ∧ certStab ∧ certBox`; `certStab` fibres over `q` |
| `realizes_of_certAdm_cohBi` | dovetailing `:1519` | label-level sufficiency for `cohBi` (region-interior, per 819's Finding 1) |
| `hist_path5` | joint-index `:851` | every history of a ladder frame is a sliced-step path (the model-layer bridge every gate needs) |
| `gap_le_region_age`, `region_start_beyond_depth`, `second_region_any_length` | index-obstructions `:893-981` | transfer unchanged |
| `prodPreN_eventually_periodic` | closure-indexed `:157` | obligation (1)'s cheap half, any product step relation |
| `nside_collides` | nside-modulus `:189` | gate 9's collision half at the INDEX level, every `(T, P, B)` |

Carried, not re-run: every gate verdict of the record (gates 1, 2 NOT ADDRESSED; 3 CARRIED; 4-5 DISARMED; 6 INTERNALISED; 7 PASSED in definability form; 8 SIDESTEPPED; 9 OPEN), read from the probe headers.

#### 2. What was compiled this round (the prototype)

`specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean`, namespace `Probe820`, importing `RunLayer` and `Mathlib.Data.Fintype.Pigeonhole` only.

| Theorem | Statement (abridged) | Hypotheses | Axioms |
|---|---|---|---|
| `drift_step`, `drift_ray` | `Drift` is `1`-Lipschitz per step and along a ray | -- | `[propext, Classical.choice, Quot.sound]` |
| `pin_region_start` | idle→pending: `y.2.1 = x.2.2` | the two letters | `[propext]` |
| `pin_region_end` | pending→idle: `x.2.1 = 0` | the two letters | `[propext]` |
| `forward_window` | `L = n_{c+j}` and `|L - n| ≤ c + j` | idle at offset `c + j`, pending at `c + j + 1` | `[propext, Classical.choice, Quot.sound]` |
| `backward_constraint` | pin `c + s`; `c - 1 ≤ n ≤ c + 2s + 1` | pending at `0..s` back, idle at `s + 1` back | same |
| `region_doubling` | `|L' - L| ≤ L + j + 1`, `L' ≤ 2L + j + 1` | idle at `0`, pending at `1`, idle at `L + 1 + j`, pending at `L + 2 + j` | same |
| `iter_doubling` | `a k + J + 1 ≤ 2^k (a 0 + J + 1)` | `a (k+1) ≤ 2 a k + J + 1` | `[propext, Quot.sound]` |
| `doubling_attained` | `growRay L` reaches countdown `2L + 2` after one idle state | -- (two-state object) | `[propext, Quot.sound]` |
| `no_positionwise_lift` | section 3 | `[Finite K]`, `R` sound | `[propext, Classical.choice, Quot.sound]` |

`Classical.choice` enters through `omega`'s `Int` normalisation in `drift_step` (checked: `pin_region_start` is `[propext]` alone). No `native_decide`, no `sorry`.

#### 3. Finding 1 -- the positionwise lift is impossible for every finite quotient (compiled)

Statement, verbatim from the prototype:

```lean
theorem no_positionwise_lift {K : Type} [Finite K] (κ : ℕ × ℕ → K)
    (R : Bool × K → Bool × K → Prop)
    (sound : ∀ σ : ℤ → Bool × ℕ × ℕ, IsHist σ → ∀ t, R (proj κ (σ t)) (proj κ (σ (t + 1)))) :
    ¬ ∀ ξ : ℤ → Bool × K, (∀ t, R (ξ t) (ξ (t + 1))) →
      ∃ σ : ℤ → Bool × ℕ × ℕ, IsHist σ ∧ ∀ t, proj κ (σ t) = ξ t
```

Here `IsHist σ := ∀ t, Rlad stepB pendB t (σ t) (σ (t + 1))` on the two-state object (`stepB ≡ true`, `pendB = id`) and `proj κ x := (x.1, κ (x.2.1, x.2.2))`. The relation `R` is arbitrary subject to soundness -- in particular the image relation of `Count`/`Drift` on any `K` of the forced shape, at any parameters. Only the object letter and the class are projected; adding the closure type to the chain (as the dispatch's statement does) makes the refutation a fortiori, since the types fix the pending/idle pattern and the pattern fixes the pins.

Why it matters for the statement shape: the dispatch's completeness clause -- "every such chain through `(q, κ(c, n))` lifts to an `RladAdm` history through `(q, c, n)` with the same type sequence" -- is a positionwise lift; the theorem says no finite `K` and no local `R_K` satisfies it, so a plan that pinned it in a Challenge block would be pinning a false statement. What survives is the PUMPING form (section 6): the lift may insert and delete loops in saturated zones, and only the state at position `0` is kept.

Why it is not a seventh mechanism: nothing here says a cell depends on more than `K`; it says the CHAIN language of real histories is not local (two run lengths are compared: the deadline climb before a pin and the length of the region after it), so no local relation on classes captures it exactly. The datum `D` is unaffected; the realization theorem's proof is affected in the shape of its lift.

Literature: this is HWZ 2000's Lemma 17 (`f ≤n * f >m` at a repeated quasistate `f(n) = f(m)`, with the run set spliced `R ≤n * R >m`) performed on the projection; the corpus README already records that their run set is chosen freely and ours is not, and this theorem is the compiled form of why that difference is load-bearing. (UNVERIFIED-summary provenance; orientation only.)

#### 4. Finding 2 -- the pin lemma (derived; soundness half compiled)

Along any `Rlad` history:
- at a pending position the countdown equals the number of pending positions strictly after it in its region (`count_pending_step` chained with `pin_region_end`; the region is finite forward by `exists_idle_of_rlad_ray`), and at an idle position it is `0`;
- the next deadline is `1`-Lipschitz (`drift_ray`, `drift_hist`) and is pinned at exactly the idle ends: `n` at an idle end equals the following region's countdown (`pin_region_start`); nowhere else does `Count` read `n`.

Hence the walk `w : ℤ → Q` of a history determines its countdown sequence outright, and `n` is any `1`-Lipschitz function matching the pins. Conversely (the lift half, DERIVED, not compiled): given an object walk through `q` whose pending position at `0` has `c` pending positions after it in its region, and given `n`, a history through `(q, c, n)` exists iff the pins are pairwise Lipschitz-compatible and compatible with `n` at `0` -- and pairwise compatibility reduces to CONSECUTIVE pins by the triangle inequality, i.e. to the region-doubling inequality `|L_{k+1} - L_k| ≤ L_k + j_k + 1` at every boundary, plus the forward window and the backward constraint at the two pins nearest `0`. The extension is the standard `1`-Lipschitz (McShane) extension on `ℤ`, clamped at `0`; with pins growing at most linearly it is a finite supremum, or a greedy walk toward the next pin on each side.

Consequence for the cell: for `box`/`stab`-free `φ`, `cellAt (q, c, n)` is `{tpOf w 0 : w ∈ W(q, c, n)}` where `W(q, c, n)` is the set of walks admitted by the pin lemma; `(c, n)` enter only through (i) `c` as the distance to the forced first idle state and (ii) the three inequalities of the pins nearest `0`. For `stab`-bearing `φ` the `stab` letter at position `i` reads the cell of the STATE at `i` (`stab_mem_tpOf_iff`), which is where the induction on `stab`-depth and `certStab` per `(q, κ)` (obligation (4)) enter; nothing changes in the counter analysis.

#### 5. Finding 4 -- how `n` is visible, and the refined shape of `K` (derived)

With `c` fixed and `g := n - c`:
- Forward: after an idle run of length `j` the next region's countdown lies in `[g - j, 2c + g + j]` in terms of `g` -- i.e. `L ≥ n - c - j` (a LOWER edge, nontrivial exactly when the gap exceeds `j`; this is mechanism (1)) and `L ≤ n + c + j` (an upper edge beyond any threshold once `c` is large). For `c` large the window has width `2(c + j) + 1 ≥ P` and covers every residue; for `c` small it does not, and `n mod P` is visible through `L mod P` -- gate 9's separation half, which on a fixture with product period `P ≥ 4` fires at `c = 0, j = 1` (three of `P` residues).
- Backward: a region start at distance `s` exists iff `n ≥ c - 1` and `s ≥ (n - c - 1)/2`; a pending-forever past is available for every `(q, c, n)` whose object has a backward-infinite pending walk through `q` (so "there was a region start" is realizable iff `g ≥ -1`); the achievable `s` form an unbounded interval, so beyond the backward exactness threshold only the lower bound on `s` -- the clipped gap -- is visible.

So for `c ≥ T` the walk set depends on `n` through the clipped gap alone; `min n T`, `n mod P` carry information only for `c < T`. The six-coordinate shape of the 819 record is confirmed and sharpened: two coordinates are conditional on a third. This is a shape statement about the carrier coordinate `K`, recorded so the plan does not re-derive it; it proposes no index.

#### 5a. Finding 3 -- the two hazards against the pin arithmetic (derived)

*Gap shift under pumping.* To move `c` to `c + P` inside its class, lengthen the current region by `P` at its start (on a fixture whose pending walk is a cycle of length dividing `P`, the start letter is unchanged). By the pin lemma this raises the region-start pin by `P`, so `n` must be `P` higher at the previous idle end -- and, to keep every gap class inside the current region, `P` higher at every position from there on, which is exactly "pumped in step". The previous idle end's deadline rises by `P` in one of three ways, tried in order: (i) the previous idle run is lengthened by `P` (its deadline climbs `P` more; admissible when its deadline class is saturated and its type sequence admits a `P`-loop -- an idle run whose type says "the next position is pending" admits none, which is the short-idle hazard's shape); (ii) the previous region's deadline is re-routed upward by `P` inside its saturated-gap zone (admissible when that region's climb has slack, i.e. its pin was not at the doubling bound); (iii) the previous region is itself lengthened by `P` and the cascade recurses one region further back. The cascade terminates at the first absorbing idle run or at a pending-forever past (where `n` is unconstrained). It cannot run into a rigid dead end once the thresholds are ordered as in (K3): a short (exact) region followed by a long (saturated) one forces, by `region_doubling`, an idle run between them of length at least `L_{k+1} - 2L_k - 2`, which is long -- hence absorbing -- whenever `T_c ≥ 2 T_short + T_idle + 2`. So the hazard is the pin cascade, and the pin arithmetic says where it stops; expected verdict at the gate: COLLISION.

*Short idle runs cannot absorb.* When the formula pins the idle runs AND the regions before the current one, the cascade has no absorber -- and then the current region cannot be long: with the first region pinned to countdown `0`, every idle run to length `1`, and `k` regions since, `iter_doubling` (with `J = 1`) bounds the current countdown by `2^k - 2`. A formula of depth about `2k + 3` expresses exactly that past (an idle-forever stretch, one pending state, then `k` alternations of "pending since idle"), so the type carrying it is realized at `(a, 2^k - 2, n)` -- `doubling_attained` iterated -- and at no state with countdown `2^k - 2 + P`. Every `K` whose threshold is at most `2^k - 2` identifies the two, whatever `P` and `B`. The hazard is therefore a statement about the SIZE of `T_c`: it is at least exponential in the formula's depth, it is finite (a rigid past of bounded depth forces a bounded countdown, and there are finitely many rigid pasts of bounded depth up to the certificate graph's equivalence), and it is computed by the cascade -- which is the "computed, not guessed" the dispatch anticipated. Expected verdict at the gate: SEPARATION for every polynomial-in-depth threshold, i.e. a refutation of any such parameter rule, and no obstruction to the lemma.

Neither hazard produces a pair of same-class states with different cells once `T_c` exceeds the cascade bound and `P` is a multiple of the graph period; that is the sense in which neither is a seventh mechanism.

#### 6. The lemma, restated in the shape the findings allow (sketch for the planner; nothing pinned)

Fix the object `(Q, step, pend, lab)` and `φ`. Let `K` be the quotient `(min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])` and `R_K` the image of `Count`/`Drift` on classes (decidable; its static nonemptiness per class is part of the carrier). The certificate graph is `Q × ClType φ × K` under the idle-extended `cohBi` (the two `pend` conjuncts of `coh` dropped; `R_K` on the `K` component; `certStab` per `(q, κ)`); `D` is its maximum `certAdm`-certified subset.

- **(S) Soundness.** Every `RladAdm` history projects to a bi-infinite chain in `D` (types by the truth clauses and fulfilment along the history, `box` by `box_mem_tpOf_iff`, `stab` by `stab_mem_tpOf_iff` GIVEN the consequence below at lower `stab`-depth). Unchanged from the dispatch.
- **(C') Completeness, pumping form.** For every bi-infinite certificate chain `ξ` and every `(c, n) ∈ ξ(0).κ` there is an `RladAdm` history `σ` through `(q, c, n)` whose projection is a certificate chain `ξ'` with `ξ'(0) = ξ(0)`, and `tpOf σ 0 = ξ(0).T`. The history is obtained by replacing saturated segments of `ξ` (between rigid anchors: exact `c`, exact `n`, exact gap) by certificate paths of other lengths in the same residue class, until the pin lemma's inequalities hold, then applying the pin lemma and the label-level sufficiency on the resulting walk. Replacement preserves local coherence and fulfilment (an eventuality pending at a segment's end is pending at the replacement's end).
- **(K) Parameters as outputs, three sources.** (K1) `P`: a common multiple of the cycle lengths of the certificate graph restricted to saturated classes -- so that between any two states of a saturated zone the achievable path lengths above a threshold are a full residue class mod `P` (eventual periodicity of path-length sets in a finite graph; `prodPreN_eventually_periodic` is the set-level form). (K2) `T_c`: at least the cascade bound -- the largest region countdown a rigid (all-exact) past can force -- which `iter_doubling` shows is exponential in the number of pinned regions and which the certificate graph's rigid structures determine; and at least the semantic periodicity threshold of obligation (1). (K3) Ordering: `T_n ≥ T_c + 2ℓ₀ - 1` where `ℓ₀` is the longest shortest-path between saturated states, so that a saturated deadline pin always leaves room to re-route a region's saturated prefix; and `T_c ≥ 2 T_short + T_idle + 2` so that a short region followed by a long one forces a long (absorbing) idle run between them. (K4) `B`: at least `2 d_back + 1` for the formula's backward exactness depth, and at least `2` (gate 1), and large enough that an exact gap with exact `c` never hides a saturated `n` inconsistently (static class nonemptiness handles the rest).
- **Consequence** (unchanged): by induction on `stab`-nesting depth, `cellAt (ladderModel …) φ (t, (q, c, n)) z = cellAt … (t, (q, c', n')) z` whenever `κ(c, n) = κ(c', n')`; and `ladderRealized` is the fibre equation. The factorization lemma is a corollary, `K`'s parameters its outputs.

What is assumed and not proved here: the semantic periodicity -- that the closure types realized along a region (resp. an idle run) at countdown beyond `T` (resp. deadline beyond `T`) are periodic with period `P` -- which is the realizable-type iteration's first repeat of the dispatch, now identified as the periodicity of path-length sets in the certificate graph rather than of profile sets. The cascade argument of 5a uses it at every "invisible lengthening".

### External Resources

- **HWZ 2000** (corpus entry of UNVERIFIED-summary provenance; orientation only): Lemma 17 (splice at a repeated quasistate), Lemma 19 (ultimately periodic state function), Lemma 32 (a "subtler deleting technique" with an equivalence `∼ⁿ` on positions). Lemma 17 is `no_positionwise_lift`'s cut; Lemma 32's refinement is the published hint that deletion must respect more than the local state -- here the pins.
- **Biere et al. 2006** (UNVERIFIED): "ultimately periodic" remains the term for the run-length sets of (K1).
- Mathlib: `Finite.exists_ne_map_eq_of_infinite` (`Mathlib/Data/Fintype/Pigeonhole.lean`, verified by `lean_local_search`; not reachable from `RunLayer`'s imports, so the prototype imports it explicitly). `ring` and `nlinarith` are not available under `RunLayer`'s import set; `omega` and `norm_num` are. No Mathlib declaration is the gap.

### Recommendations

1. **Restate the lemma in pumping form before anything is pinned** (section 6, (S)/(C')). The plan's Lean Challenge Statements must not carry a positionwise lift; `no_positionwise_lift` is the reason, and it should be promoted into the wired probe so the reason cannot rot.
2. **Promote the prototype into `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`** (the task's `file_scope`) as that probe's arithmetic layer, with a decision-row block in `scripts/check-evidence-probes.sh` naming the nine theorems; then build the gate table of Appendix A on top of it in phases, one gate per phase, each phase ending with `lake env lean` on the probe and the axiom check.
3. **Fixture: the 4-cycle object** `Q4 := Bool × Fin 4`, `pend4 q := q.1`, pending edges `(true, i) → (true, i + 1)`, `(true, i) → (false, i)`, idle self-loop and `(false, i) → (true, i)`; letters `ℓ_i` reading the index, `p` reading pending. Its pending walk is deterministic (so `hist_path`-style run lemmas are as cheap as on the two-state fixture) and its product period is `4` for any closure naming the letters, which makes the `c = 0, j = 1` window proper (three of four residues).
4. **Run the gates in this order**: statement-shape (done), 1, 2, 9-separation, short-idle (exponential threshold), 9-collision, gap-shift -- cheapest and most decisive first; the last two are closure-specific cell EQUALITIES and are the expensive rows.
5. **Compile the pin lemma's lift half** as the first library-level target after the gates (a `1`-Lipschitz extension on `ℤ` with pins; generic in the object); it is what makes (C') a chain-replacement argument rather than a counter argument.
6. **Keep the three hazards' verdicts honest**: the gap-shift and short-idle gates are expected to PASS (collision resp. parameter-size), and a refutation of either would be a complete result; record `[BLOCKED]`-to-closed only on a compiled refutation, never a weakened substitute.
7. **Do not state a tuple index**; where the parameters are written, write them as outputs with their three sources ((K1)-(K4)) and update `ladder-counter-observables.md` (at its source-store path) with the exponential-threshold fact and the pin lemma once compiled.

## Decisions

- **D1.** The dispatch's completeness clause is refuted positionwise (compiled) and replaced, for planning purposes, by the pumping form (C'); the statement remains unpinned.
- **D2.** The three derived items are compiled as a research-level prototype under the task directory, not wired; promotion is the plan's first phase.
- **D3.** The fixture for the gate table is the 4-cycle object; the coprime-cycle fixture of the record (period 3) is not reused because its window at `c = 0, j = 1` covers every residue.
- **D4.** The hazards are assessed as absorbed (gap shift) and as a parameter-size fact (short idle); neither is filed as a mechanism; the negative branch stays live until the two expensive gates compile.
- **D5.** `K`'s parameters have three sources (graph period, cascade bound, formula-derived clip), all counts, all outputs; the record's "first repeat of the realizable-type iteration" names (K1) only, and the plan should say so.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| The semantic periodicity assumption (section 6) fails on some object/formula -- types along a long region are not `P`-periodic in the countdown | the pumping form's "invisible lengthening" breaks; a genuine obstruction | it is obligation (1)'s semantic half, named in the record; gate 9-collision and the gap-shift gate exercise it on the fixture before any general attempt |
| The cascade bound (K2) is not computable from the certificate graph as cheaply as claimed | `T_c` cannot be exhibited as an output | the short-idle gate forces the bound's existence per formula; the plan should compute it on the fixture by hand (`iter_doubling` with `J = 1`) before claiming a general recipe |
| The 9-collision and gap-shift gates (cell EQUALITIES) are too expensive at probe level | the table stays incomplete | state each as closure-specific (the fixture formula's closure only) with an explicit pumped history and per-member truth lemmas, as `qp_cell_eq_of_depth_parity` did; escalate, never weaken the name |
| `Classical.choice` in the prototype's axiom foot is read as a defect | none (standard) | it enters via `omega` on `Int`; `pin_region_start` shows the `[propext]`-only core |
| The prototype is cited as if wired | rot | Recommendation 2; until then every citation of it says "prototype, not wired" |
| `certStab` kept at fibre-over-`q` | wrong `stab` bits (F2(a) of the 761 record) | obligation (4) unchanged: rebuild per `(q, κ)`; gate 8 SIDESTEPPED until a `stab`-bearing fixture runs |

## Tactic Survey Results

No tactic survey of a model-layer goal was performed (no `cellAt` goal exists yet). The prototype's proofs record the tactics that closed them, for the promotion:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `drift_step` (`Drift` as two `≤`) | `simp only [Drift] at hd; omega` | success | `hd := h.2.2.1` |
| `pin_region_start` / `pin_region_end` | `rw [hx, hy, count_ft]` / `count_tf` | success | `Count` unfolding lemmas `count_tt/tf/ft/ff` by `simp [Count]` |
| `forward_window`, `region_doubling` | two `have`s (pin, `drift_ray`) then `refine ⟨_, ?_, ?_⟩ <;> omega` | success | no pending run needed |
| `backward_constraint` | `countdown_back` by induction + reversed `drift` by induction, `omega` | success | -- |
| `iter_doubling` | `Nat.mul_le_mul_left`, `rw [pow_succ, mul_comm, mul_assoc]`, `generalize`, `omega` | success | `nlinarith`/`ring` unavailable under the import |
| `growRay_isRay` | per-case value equations (`growRay_zero/pend/idle/next` by `simp [growRay, h…]`) then `rw`, `simp [Drift, Count]`, `omega` | success | deciding `if`s via explicit `have`s, not inside `simp` |
| `tightHist_isHist` | `by_cases` ladder on `t`, `simp only [tightHist, h…, if_false, if_true]`, `omega` | success | `set … with h` followed by `clear_value` so `simp` does not zeta-unfold |
| `no_positionwise_lift` | `Finite.exists_ne_map_eq_of_infinite`, `wlog hlt : k < k'`, `set`/`clear_value`, letter lemmas by `show` + `rw [if_pos/if_neg]`, `countdown_of_run`, `omega` | success | `simp` arithmetic normal forms drift from stated hypotheses; explicit `if_neg h` rewrites are robust |

Axioms as in section 2; `#print axioms` on all six headline theorems is at the end of the file.

## Context Extension Recommendations

- **Topic**: the pin lemma. **Gap**: `ladder-counter-observables.md` records what the counters make observable but not that the countdown is determined by the walk and `n` is constrained only at idle ends. **Recommendation**: a "What the counters constrain" item stating the pin lemma, at the source-store path, once its lift half is compiled.
- **Topic**: the positionwise-lift impossibility. **Gap**: nothing in the context says why a class-level chain relation cannot be exact. **Recommendation**: one paragraph beside the parameter-origin rule citing `no_positionwise_lift` once promoted, and naming the pumping form as the shape of the completeness clause.
- **Topic**: the three parameter sources. **Gap**: the rule names the formula (for `B`, `T`) and the object-closure product (for `P`); the cascade bound is a third source and is exponential in depth. **Recommendation**: add (K2) with `iter_doubling` as its arithmetic.

## Appendix

### A. The gate table, designed (expected verdicts with their compiled ground)

Fixture `Q4` as in Recommendation 3; `a := (true, 0)`; `X χ := ⊥ U χ`; `Y χ := ⊥ S χ`; types written as "the type containing ψ".

| Gate | Pair | Formula / closure | Expected verdict (NOT compiled) | Compiled ground |
|---|---|---|---|---|
| 1 | `(a, B, B+1)` vs `(a, B, B+2)` | `p U (¬p ∧ X(p ∧ X ¬p))` | cells differ: the next region can have countdown `0` from the first (`L ≥ n - c - j = 0`) and not from the second (`L ≥ 1`); `K`'s gap coordinate separates for `B ≥ 2` | `forward_window` (lower edge); `cell_ne` (two-state), `gate1_gap_separates` (index) |
| 2 | `(a, c, n)` vs `(a, c+1, n)` | `p U (¬p ∧ ℓ_{c mod 4})` | cells differ: the forced run ends at index `c mod 4`; `K`'s residue coordinate separates iff `P` is a multiple of `4` | `count_pending_step`, `pin_region_end`; `cell_succ_ne` (two-state), `gate2_residue_separates` (index) |
| 9-sep | `(a, 0, n)` vs `(a, 0, n+m)`, `4 ∤ m`, `n ≥ 1` | `X(¬p ∧ X(p ∧ (p U (¬p ∧ ℓ_{n+2}))))` | cells differ: at `c = 0, j = 1` the window is `{n-1, n, n+1}`, three of four residues; the type with `ℓ_{n+2}` is realized at `(a, 0, n+m)` iff `m ∈ {1,2,3} mod 4` -- so `K`'s `n`-modulus must be a multiple of the product period | `forward_window` at `c = 0`; `nside_collides` (the index collides at every `(T, P, B)` whose modulus is `P + 1`, so the semantic half decides) |
| 9-col | `(a, 0, n)` vs `(a, 0, n+4)`, `n ≥ 2` | the closure of the 9-sep formula | cells EQUAL (closure-specific): pump the next region by `4` with `n` raised by `4` from `0` to its idle end and onward; the closure is `snce`-free, so the past is replaced by a pending-forever past | `forward_window`; `second_region_any_length`; per-member truth lemmas |
| gap-shift | `(a, c, n)` vs `(a, c+4, n+4)`, `c ≥ T`, same clipped gap | a closure with a `snce` member reading the region start's letter and the previous idle run's length | cells EQUAL: lengthen the current region by `4` at its start (start letter unchanged mod `4`), raise `n` by `4` from the previous idle run on, lengthen that idle run by `4` (self-loop) when its length is not pinned, else cascade; with the type pinning the previous idle run AND region short, `c ≥ T` is unrealizable on both sides | `backward_constraint`, `region_doubling`, `doubling_attained`; `gPast_isPath` (pending-forever pasts) |
| short-idle (exponential threshold) | `(a, 2^k - 2, n)` vs `(a, 2^k - 2 + P, n + P)`, every `(T ≤ 2^k - 2, P ≥ 1, B)` | `ψ_k`: all idle runs of length `1` (depth 2), an idle-forever past before a single pending state (depth 3), exactly `k` region starts since (depth about `2k`) | cells differ: `ψ_k`'s type is realized at the first (the maximal-growth walk, `doubling_attained` iterated) and at no history through the second (`iter_doubling` with `J = 1` bounds the current countdown by `2^k - 2`); every `K` with `T ≤ 2^k - 2` collides on the pair, so `T` is at least exponential in depth | `iter_doubling`, `doubling_attained`, `backward_constraint`, `region_doubling` |
| statement-shape | generic (`K`, `κ`, sound `R`) | -- | REFUTED, compiled: no positionwise lift | `no_positionwise_lift` |

A gate probing one coordinate certifies one coordinate; passing an earlier row says nothing about a later one. Gate 8 stays SIDESTEPPED (no `stab` member in any closure above); gate 3 stays CARRIED.

### B. Files and commands

- Prototype: `specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean`; compile `lake env lean specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean` (exit 0, four lint warnings removed, 544 lines, `grep -c sorry` = 0). Axiom profile from the file's own `#print axioms` lines: `forward_window`, `backward_constraint`, `region_doubling`, `no_positionwise_lift` on `[propext, Classical.choice, Quot.sound]`; `iter_doubling`, `doubling_attained` on `[propext, Quot.sound]`; `pin_region_start`, `pin_region_end` on `[propext]`.
- Read in full or in their load-bearing parts: the dispatch file; the 819 report; the ten probe headers listed under Sources; `RunLayer.lean:236-300`; `LadderModel.lean` whole; `AnchorLayer.lean:95-240`; dovetailing `:826-880, 978-1030, 1110-1130, 1232-1245, 1515-1535`; joint-index `:711-870`; index-obstructions `:880-1005`; nside-modulus whole; `check-evidence-probes.sh:1-40, 1380-1430, 1500-1515`; `ladder-counter-observables.md` whole; ROADMAP `:13-66, 167-250`.
- Searches: `lean_local_search` for `exists_ne_map_eq_of_infinite` and `not_injective_infinite_finite` (index `error`, hits returned by name; the import was verified by compiling); `literature-search.sh "splice lemma periodic state function quasimodel"` (degraded, no results; the HWZ chunk was read directly and Lemma 17 located by `grep`); no Mathlib natural-language search was needed (no Mathlib lemma is the gap).
- Issue log: one `win` (literature search degraded, proceeded on the compiled record), one `win` (prototype compiled on the fourth pass; `ring`/`nlinarith` unavailable, `omega` sufficed; explicit `Pigeonhole` import). No blocking issue.
