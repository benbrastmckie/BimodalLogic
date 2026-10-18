# Research Report: Task #819

**Task**: 819 - Ladder cell presentation design decision
**Started**: 2026-10-18T14:32:56Z
**Completed**: 2026-10-18T14:53:18Z
**Effort**: 1 research round (reading of the compiled record, one 69-line compiled prototype, no library edits)
**Dependencies**: None (parent: task 761, which this decision gates)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/{RunLayer,LadderModel,AnchorLayer,Realize,Trace}.lean`, the RaySummary README's "(W): what landed and what did not"), the wired probes 12-21 under `specs/evidence/seam-gluing-ray-product/` (headers read in full, core definitions read from source), the design-of-record specs (`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C, H4; `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` "Ranking ratification"), the research reports and plans of tasks 761, 805, 806, 809, 815, `.claude/context/project/lean4/domain/ladder-counter-observables.md`, `specs/ROADMAP.md`; lean-lsp MCP not needed (no Mathlib lemma is the gap; every declaration cited was read from its source); literature briefing consulted for orientation only (no literature source is cited by the task, so the Literature Extraction Protocol does not apply)
**Artifacts**: - `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md` (this report)
  - `specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean` (69 lines, 0 sorry, compiles clean with `lake env lean`; axioms `[propext, Quot.sound]` at most; research-level, not wired into the evidence gate)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Recommendation: presentation (a), the set-valued per-state datum, reaffirmed on the merits and not as the record's lean — in a sharpened form.** The datum is `D`, the MAXIMUM `certAdm`-certified subset of a finite carrier `Q × ClType φ × K`, where `K` is a quotient of the two ladder counters; the realization theorem is `cellAt (ladderModel …) φ (t, x) z = ` the fibre of `D` at `(q, [x])`; the factorization lemma is a corollary of that theorem, never its hypothesis; and no tuple is ever stated as an index of cells. (b), a parameter-coupled tuple index stated on its own, is not merely disfavoured but **dominated and incomplete**: every proof step it needs is a step of (a)'s proof, the parameter exhibition it adds is the component refuted three times, and a tuple without a per-class SET of types realizes nothing (finding F2 of the 761 record). It is reported as such and not proposed.
- **Finding 1 (new, compiled this round): the set-valued presentation on record is a REGION-INTERIOR object, not a ladder object.** `coh` and `cohBi` require `pend` at BOTH endpoints (`closure-profile-gate-rerun.lean:399-401`, `certificate-sufficiency-dovetailing.lean:864-866`); `certBiInf` and `Realizes` therefore quantify over all-pending bi-infinite chains; and this round's prototype proves `exists_idle_of_rlad_ray` — a forward `Rlad` ray reaches an idle state within `c₀ + 1` steps — so **no `Realizes`-chain is the object projection of any `Rlad` history** (`no_rlad_ray_of_pending_forever`). The label-level sufficiency of task 815 is sufficiency for the interior of one region. The ladder datum still owes the composition of regions across idle runs under `Count`/`Drift`; that is exactly where obligations (2) and (3) live, and neither has been started. This sharpens, and does not contradict, the 806 report's own scope caveat ("over a fixed `E`, the countdown profile over-approximates; this is obligation (c)").
- **Finding 2 (structural): any computable per-ladder-state datum must reduce the two unbounded counters to finite data, and the arithmetic of `Count`/`Drift` forces that reduction to have the SHAPE threshold + residue + clipped gap — the shape of the refuted six-coordinate body — as the counter component `K` of the carrier.** Mechanisms (1), (2) and (4) each force one component (gap, residue, threshold at least the formula's depth), on compiled ground. This is NOT a new index candidate and must not be read as tuple-widening: `K` does not factor `cellAt` on its own (that is precisely the refuted claim); `D` does. `K`'s parameters are OUTPUTS of the pumping lemma (the first repeat of the realizable-type iteration on the object-closure product), never inputs exhibited from the object or from the letters, which is what the sixteenth probe's header reserved as "a DIFFERENT candidate, not gated here". The honest consequence, stated so nobody rediscovers it: **a positive result for (a) entails a factorization lemma for a counter quotient of this shape at those emergent parameters** — (a) and (b) are layers, not alternatives, and the design decision is which layer is STATED as the index (the set) and where the parameters come from (the fixpoint).
- **Finding 3: exactness.** The realization theorem needs `D` to equal the ACTUAL realizable set, not an under-approximation: with `R ⊊ Real` the `stab` bits computed against `R` are wrong (F2(c) of the 761 record), so Route B's `R ⊆ Real` alone is insufficient for `box`/`stab`-bearing `φ`. Route A (decide generalized-Büchi nonemptiness) is NOT needed: `Real` is itself certified (by `stab_mem_tpOf_iff`, `box_mem_tpOf_iff` and the truth clauses, GIVEN constancy of `cellAt` on `K`-classes), every certified `R` lies inside `Real` (sufficiency), hence `Real` is the MAXIMUM certified set and is computable by enumeration over `Finset (Q × ClType φ × K)` — a count of candidates, not a bound of any kind. `LadderCons` then reads: `certAdm R ∧ R` maximal.
- **The real open problem, named: the COUNTER-LIFT (pumping) LEMMA**, obligations (2) and (3) taken jointly. Statement shape: every `Rlad` history projects to a chain over `Q × ClType φ × K` whose counter classes follow the class-level `Count`/`Drift` relation, and every such chain through `(q, [c, n])` lifts to an `Rlad` history through `(q, c, n)` with the same closure-type sequence; the parameters of `K` are those for which the class relation is both sound (image) and complete (lifts). Its consequence, by induction on `stab`-nesting depth, is constancy of `cellAt` on `K`-classes, which is what Finding 3 needs. Nothing on record obstructs it; much of its arithmetic is compiled (the `Drift` window at the first idle, `gap_le_region_age`, `region_start_beyond_depth`, `second_region_any_length`); two hazards found this round are recorded in §2 and §5 (pumping a region shifts the gap at every earlier position; a short idle run cannot absorb a deadline shift) and are the first gates a successor must run. **(a)'s viability rests on this lemma, which is unproved; the dispatch requires that it be named rather than assumed, and it is.**
- **A negative outcome is not reached, and the branch is stated.** No evidence says neither presentation discharges the four obligations: what is missing is proof work with no compiled obstruction. If the counter-lift lemma fails — if one of the hazards is a genuine seventh mechanism resistant to every `K` of the forced shape — then NO computable per-ladder-state datum exists in either presentation, because both need it, and that would close the ladder route on evidence the way filtration was closed. That is "what it would take".
- Obligation (4) is dischargeable in either presentation but ONLY with `K` in the carrier: the `stab` fibre is per ladder cell, i.e. per `(q, κ)`, so `certStab` as compiled (fibre over `q` in `Q × ClType φ`) is the wrong granularity for the ladder (F2(a)) and must be rebuilt per `(q, κ)`. Gate 8 stays SIDESTEPPED until a `stab`-bearing fixture is run.
- Guardrails honoured: no complexity claim; every quantity named is a count; `anchorCells_finite` and `anchorCells_ncard_le` untouched (the SET of cells was never in question); the acceptance clause is kept in every statement shape sketched; no seventh coordinate and no wider tuple; the three earlier negatives and their gates untouched; nothing under `FormalSystem/` or `Tests/` edited; no `LadderCons`, `ladderRealized` or `ladderCons_localRun` stated under any name.

## Context & Scope

**What was asked.** Choose between (a) a set-valued per-state datum over a quotient and (b) a parameter-coupled index, assessed against the four obligations named in the fifteenth probe's header — (1) eventual periodicity of realizable types in the countdown over the object-closure product, (2) a region-length pumping lemma for `untl`/`snce`-depth-bounded formulas, (3) the next deadline's coupling through `Drift`, (4) the `box`/`stab` letters through the anchor-layer equations — with (3) as the viability test, under the hard constraint that nothing of the refuted tuple shape be proposed, and with a negative outcome admitted as a complete result.

**Record drift, recorded as an issue.** The dispatch description is a snapshot at the fifteenth probe. The evidence directory now holds probes 16-21: `ladder-joint-index-refutation.lean` (the six-tuple at rule-derived parameters, refuted by gate 6's pattern-definable sub-object), `closure-indexed-periodicity.lean` (obligation (1)'s cheap half, with the product step relation a parameter), `closure-profile-gate-rerun.lean` and `nside-modulus-gate.lean` (the set-valued countdown profile's gate table; gates 1-2 NOT ADDRESSED, 3 CARRIED, 4-5 DISARMED, 6 INTERNALISED, 7 PASSED in definability form, 8 SIDESTEPPED, 9 OPEN), `realizable-type-adequacy-gap.lean` (local coherence admits an undischarged eventuality), `realizable-type-certificate.lean` (the certificate `certAdm`, existential fulfilment, `box`/`stab` as checked biconditionals) and `certificate-sufficiency-dovetailing.lean` (the dovetailing theorem; sufficiency refuted for `coh`, proved for `cohBi` at the label level). This report assesses the presentations against THAT record. The ROADMAP's "761 over `cohBi`, realizability label-level" is the plan this decision feeds.

**Constraints observed.** Scope limited to this task's directory; one research-level prototype compiled, not wired into `check-evidence-probes.sh` (it is a prototype under the task directory, per the parent record's scope line, not a wired evidence probe). No Mathlib search was run: the decision turns on the project's own definitions, every one of which was read from source, and no step of the open problem is a missing Mathlib lemma.

## Findings

### Codebase Patterns

#### 1. Verified starting state (read from source this round)

| Object | Where | What it fixes |
|---|---|---|
| `Count px py c n c'` | `RunLayer.lean:261-262` | pending→pending: `c' + 1 = c`; idle→pending: `c' = n`; →idle: `c' = 0 ∧ (px → c = 0)` |
| `Drift n n'` | `RunLayer.lean:254` | `n' ∈ {n-1, n, n+1}` at EVERY step |
| `Rlad step pend` | `RunLayer.lean:268-271` | `step ∧ (idle source → c = 0) ∧ Drift ∧ Count`; time-invariant |
| `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`, `ladderModel` | `LadderModel.lean` | carrier `{(q,c,n) // pend q = false → c = 0}`, infinite slice; valuation reads `q` only |
| `tpOf`, `cellAt`, `cellAt_eq_cellAt` | `AnchorLayer.lean:104-156` | a cell is the SET of closure types over histories through a world state; time-independent |
| `box_mem_tpOf_iff`, `stab_mem_tpOf_iff` | `AnchorLayer.lean:186-220` | `□ψ` one global bit; `⊡ψ ∈ tpOf σ z ↔ ∀ σ' through σ.state z, ψ ∈ tpOf σ' z` — PER CELL |
| `coh`, `cohBi` | gate-rerun `:399-401`; dovetailing `:864-866, 1118-1120` | `step ∧ pend x ∧ pend y ∧ locCoh x ∧ locCoh y ∧ untlLink` (+ `snceLink`) — both endpoints PENDING |
| `certAdm`, `certBiInf`, `certFwd/Bwd`, `certStab`, `certBox` | dovetailing `:980-1014` | fibres over `q` in `Q × ClType φ`; existential discharge inside `R` via `euLfp` |
| `Realizes rel R x` | dovetailing `:1235` | a bi-infinite `cohR`-chain through `x`, forward- and backward-fulfilling |
| `Prof6 k` | gate-rerun `:~410` | `(prodPreStep coh6)^[k] Ea`: states from which a `k`-step PENDING chain reaches the fibre over `a` |

Compiled negatives relied on, not re-run: `cell_ne` (gap observable), `cell_succ_ne`/`ladderIndex_not_factoring` (parity observable), `object_only_parameters_refuted`/`reach_period_refuted` (object-exhibited parameters), `joint_parameters_refuted`/`rule_derived_parameters_refuted` (letter-rule modulus), `bounded_width_validates_Phi_neg` (bounded carrier), `nside_collides` (n-side shape blind to the modulus shift), `gPast_isPath` (backward-infinite pending histories exist), `sufficiency_refuted` (the backward arm for `coh`).

#### 2. The arithmetic of `Count`/`Drift` — what the counters actually constrain

Everything a ladder datum must know about the counters is finite arithmetic on region lengths and idle lengths. Written out once, marked compiled or derived (derived = read off the definitions this round, paper-level, no theorem):

- **Forward, first region** (compiled: `pending_run`/`idle_at` in the twelfth and fourteenth probes; the `Drift` window in the twelfth). From pending `(q, c, n)`: offsets `0..c` are pending with countdowns `c, …, 0` (`c + 1` states); offset `c + 1` is the first idle state, whose deadline `n₁` satisfies `|n₁ - n| ≤ c + 1`.
- **The idle run and the next region** (derived). If the idle run has `j ≥ 1` states, the next region starts at offset `c + j + 1` with countdown `L = ` the deadline at the last idle state, so `|L - n| ≤ c + j`: the achievable `(j, L)` pairs are exactly `{(j, L) : |L - n| ≤ c + j}`. For `j ≥ ⌈P/2⌉` the window covers every residue mod any `P`; for small `j` it covers residues in an interval of half-width `c + j` around `n`. This is the whole content of obligation (3): `n` enters the cell ONLY through these windows (and their mirror). The "standing obstruction" — every second-region length is reachable from every pending state — is this window with `j` unbounded; it is a reason the far future is independent of `n`, not an obstruction to a datum.
- **Region doubling** (derived). At a region start the new deadline is within `1` of the new countdown `L_k` (`Count false true` then `Drift`), and it has `L_k + j_k` steps to reach the next region's length, so `L_{k+1} ≤ 2 L_k + j_k + 1` for every consecutive pair; backward, `L_k ≥ (L_{k+1} - j_k - 1)/2`. Region lengths can at most roughly double per region (plus the idle length) and, read backward, at most roughly halve. This constraint has been exhibited by NO probe and is the first candidate for a seventh mechanism.
- **Backward, the current region** (derived; consistent with the compiled `gap_le_region_age`/`region_start_beyond_depth`). If the current region started `s` steps ago, `n ∈ [c - 1, c + 2s + 1]`. So a state with `n < c - 1` has only pending-forever pasts (admissible: `gPast_isPath`), and a large gap `n - c` forces `s ≥ (n - c - 1)/2`.
- **No pending-forever future** (compiled this round: `exists_idle_of_rlad_ray`). Within `c₀ + 1` steps a forward `Rlad` ray is idle.

#### 3. Finding 1 — the set-valued presentation on record is region-interior (compiled)

`coh`'s docstring in the eighteenth probe says it plainly: "the countdown profile lives on the pending sub-object, because `Count`'s `py ∧ px → c' + 1 = c` clause is what makes the countdown measure distance." That was the right scoping for a PROFILE. The certificate and `Realizes` inherited it: `certBiInf` demands a `cohR`-successor and -predecessor inside `R` for every member, and `Realizes` is a bi-infinite `cohR`-chain, so every certified realizability witness is an all-pending bi-infinite object walk. By `no_rlad_ray_of_pending_forever` (this task's prototype), no such walk is the object projection of any `Rlad` history. Hence:

- `realizes_of_certAdm_cohBi` (task 815) is sufficiency for the interior of a single region of the object, read as if it never ended. It is correct and it transfers (a region of a ladder history IS a `cohBi`-chain segment), but it is not ladder realizability and the ROADMAP's "semantic step (d): from a fulfilling label chain to a type in a cell" cannot be taken from it for `ladderModel` as stated: there is no `Rlad` history to take it to.
- The ladder datum must COMPOSE: pending regions (where `cohBi` applies) through idle runs (where the relation must be extended — `coh`'s two `pend` conjuncts dropped or replaced by the `Count`/`Drift` clauses on the counter classes) with the arithmetic of §2 enforced at the boundaries. Obligations (2) and (3) are exactly this composition; neither has been started, and the record's gate table marks them NOT ADDRESSED (gates 1, 2) and OPEN (gate 9) for the same reason.

This does not refute anything on record; it relocates where the remaining work is.

#### 4. Finding 2 — the counter quotient is forced, in shape, by the arithmetic; it is a carrier component, not an index

A computable `LadderState Q pend → I` with `I` finite must identify infinitely many counter pairs. The compiled mechanisms say what any sound identification must preserve: the gap `n - c` where it is small (mechanism (1), `cell_ne`); the countdown exactly where it is small and its residue where it is large (mechanisms (2) and (4): the parity at the region end, the exact distance to the forced first idle state up to the formula's `untl`-depth); the next deadline through the windows of §2, which by the same two mechanisms applied to the next region means `n` exactly where small and its residue where large (gate 9's collision pair is this shape's one open check). So the counter component of ANY sound finite carrier is, up to coarsening, `K = (min c T, c mod P, min n T', n mod P, clip (n - c) [-B, B])` — six coordinates, the refuted body's shape. Three things make this a finding and not a proposal of the refuted candidate:

1. **`K` does not factor `cellAt`.** The refuted statements were all `index x = index y → cellAt x = cellAt y` for a tuple `index`. Here the thing that factors `cellAt` is `D`, a set of closure types per `(q, κ)`; `K` is a coordinate of the carrier `D` is computed over. A tuple class carries no types (F2 of the 761 record: a per-cell object must carry a SET of types per ladder state), so the tuple alone is not even a complete presentation.
2. **The parameters are outputs.** `T`, `P`, `B` are the threshold, period and clip for which the counter-lift lemma (§6) holds — read off the first repeat of the realizable-type iteration on the object-closure product, where the eighteenth probe already found "no parameter to choose". Mechanisms (4), (5), (6) each attack a parameter fixed BEFORE the closure dynamics (from the object graph, or from the letters); a parameter that is the period of the realizable-type dynamics itself is what the sixteenth probe's header reserved: "A candidate whose modulus is derived from the object-closure product is a DIFFERENT candidate, not gated here."
3. **It is gated before it is used.** Nothing here says this `K` passes a seventh gate; §5 names two candidate gates no probe has run.

The reading to guard against, in the 806 report's own words: "one could re-present [the profile] as `(q, min c T*, c % (P*+1), …)` and land back in the tuple family. That re-presentation is not what is proposed." This report agrees, and adds the point that report did not: the proof of (a) will nevertheless CONTAIN the statement "`cellAt` is constant on `K`-classes" as a lemma (§6), because the completeness half needs it (Finding 3). Hiding that would be the loop this task exists to break; stating it is not tuple-widening.

#### 5. Finding 3 — exactness, and why Route A is still not needed

The realization theorem must give the cell EXACTLY. If `D`'s fibre at `(q, κ)` were a proper subset of the real cell, a chain type `T` with `⊡ψ ∈ T` because `ψ` holds on every `D`-type could be semantically false at the lifted history (some real history through the state falsifies `ψ`), so `T` would not be `tpOf` of anything — the semantic step fails at the `stab` case. Route B as compiled (check a guessed `R`) yields only `R ⊆ Real`.

Exactness is recoverable inside Route B. Let `Real ⊆ Q × ClType φ × K` be the set of `(q, T, κ)` with `T ∈ cellAt (q, c, n)` for some `(c, n) ∈ κ`. Then: (i) every certified `R` with `R ⊇ Real` satisfies `R ⊆ Real` (sufficiency with the `stab` case closed by induction on formula complexity — the `⟹` direction uses `Real ⊆ R`, the `⟸` direction uses the induction hypothesis on a chain through each `R`-fibre member); (ii) `Real` itself is certified — `certLoc`, `certBiInf`, `certFwd/Bwd` by the truth clauses and fulfilment along actual histories, `certBox` by `box_mem_tpOf_iff`, `certStab` by `stab_mem_tpOf_iff` PROVIDED `cellAt` is constant on `K`-classes (otherwise `Real`'s fibre at `(q, κ)` is a union over the class and the biconditional can fail); (iii) hence `Real` is the maximum certified set, and a maximal certified set is unique and equals `Real`. `D := ` the maximum certified subset is computable by enumerating `Finset (Q × ClType φ × K)` — at most `2^(|Q| · 2^|cl φ| · |K|)` candidates, a COUNT of candidates and not a complexity claim of any kind. Nothing decides generalized-Büchi nonemptiness; the record's ruling against entering Route A without a decision record stands, and this IS the decision record's reason it need not be entered.

The dependency is explicit: Finding 3 consumes constancy of `cellAt` on `K`-classes, which is the counter-lift lemma's consequence (§6). That is why §6 is the open problem and not a side lemma.

#### 6. The open problem, named: the counter-lift lemma (obligations (2) and (3) jointly)

**Statement shape** (research-level; not pinned, not a Challenge block). Fix the object `(Q, step, pend, lab)` and `φ`. There are `T`, `P ≥ 1`, `B` (counts) and a decidable relation `R_K` on `K` such that, writing `κ : ℕ × ℕ → K` for the quotient map:
- *soundness*: every `RladAdm` history `σ` projects to a bi-infinite chain `t ↦ (q_t, tpOf σ t, κ(c_t, n_t))` whose consecutive counter classes satisfy `R_K` and whose consecutive types satisfy the idle-extended `cohBi` link;
- *completeness (the lift)*: every bi-infinite chain over `Q × ClType φ × K` satisfying those two relations, with `(q, κ(c, n))` at position `0`, is the projection of an `RladAdm` history through `(q, c, n)` with the SAME type sequence.

**Consequence**: by induction on `stab`-nesting depth (treating lower-depth `box`/`stab` letters as letters of `(q, κ)`, which the induction hypothesis licenses), `cellAt (ladderModel …) φ (t, (q, c, n)) z = cellAt … (t, (q, c', n')) z` whenever `κ(c, n) = κ(c', n')`. This is the factorization lemma for `K`; it is a LEMMA of (a), and it is of the shape the sixteenth probe reserved.

**What is already compiled toward it**: obligation (1)'s cheap half (`prodPreN_eventually_periodic`, any product step relation on the finite carrier); the one-region profile's period on the coprime-cycle fixture (`profR_period_three`, gate 6 internalised); the existential fulfilment fixpoint and the dovetailing theorem (`exists_dovetail_chain`, generic over a finite graph); the arithmetic in §2 that is compiled; and this round's `exists_idle_of_rlad_ray`.

**Two hazards found this round, to be run as gates BEFORE any sufficiency attempt** (a gate probing one coordinate certifies one coordinate):
- *Gap shift under pumping.* Lengthening the current region by `P` (to move `c` within its class) raises `c` at every EARLIER position by `P`, so the gap `n - c` at those positions drops by `P`; unless `n` is pumped in step (`Drift` permits `+1` per inserted step), positions whose gap was inside the clip window change class. Pumping `n` in step is consistent with the region-start pin (`n` within `1` of the region length) only if the PREVIOUS idle run can absorb the shift.
- *Short idle runs cannot absorb.* With `L_{k+1} ≤ 2 L_k + j_k + 1`, a region following a short region and a short idle run is bounded by exact small arithmetic; a class-level chain must carry enough of `(L_k, j_k)` exactly to see this, which may force `T` above the formula-derived depth bound and must be computed, not guessed. This is also the shape a gate-9 refuting half would exploit: the n-side pair `(q, c, n)` vs `(q, c, n + m)` separates when `2(c + j) + 1 < ` the product period and `m` is not a multiple of it (a 4- or 5-cycle fixture with the gate-6 pattern formula at `c = 0`, `j = 1`), and collides when `m` is a multiple of the product period — the parameter-origin rule again, which is why gate 9 is expected to pass only at the product period and to refute every other modulus.

Neither hazard is a refutation; each is where a seventh mechanism would live if there is one.

#### 7. The assessment, obligation by obligation

| Obligation | (a) set-valued datum `D` over `Q × ClType φ × K` | (b) parameter-coupled tuple index stated alone |
|---|---|---|
| (1) periodicity over the product | cheap half compiled (`prodPreN_eventually_periodic`); adequacy = Finding 3's exactness, resolved by the maximum certified set; the semantic half is §6 | needed identically — the tuple's `(T, P)` ARE this periodicity's threshold and period; without `D` there is nothing periodic to point at |
| (2) pumping lemma | §6, the open problem; hazards named | needed identically; is the whole proof of the tuple's soundness |
| (3) `Drift` coupling | §2's windows; dischargeable in principle; `K` carries `n`'s class; no compiled obstruction | needed identically; the n-side shape passed gates 1-2 and is blind to the modulus shift (`nside_collides`), gate 9 OPEN |
| (4) `box`/`stab` | `certBox` global; `certStab` rebuilt per `(q, κ)`; closed by the formula induction of Finding 3 | the tuple gives the fibre index but no fibre CONTENT; a `LadderCons` over it must still carry a set of types per class, i.e. must become (a) |
| Parameter-origin exposure (mechanisms 4-6) | none in the statement: `D`'s definition has no parameter; `K`'s parameters are outputs of (2) | total: the tuple is stated AT parameters, and three refutations were refutations of exactly that |
| Completeness as a presentation (F2) | complete: a set of types per class | incomplete: no types |
| Hard constraint of the dispatch | honoured: no tuple proposed as index; `K` is a carrier coordinate | violated by construction |

**Verdict on (b)**: dominated by (a) on every row, incomplete as a presentation, and barred by the hard constraint. Its one honest content — that a sound tuple-shaped quotient at product-derived parameters exists if (a) succeeds — is a COROLLARY of (a) and is recorded as such (§4, §6). It is reported, not proposed.

**Why (a) is not "the refuted tuple with better parameters" either**, answering the dispatch's question for the presentation actually recommended: the index is `D`; `D` has no parameter; `K` is forced in shape by compiled arithmetic and its parameters are outputs of the pumping lemma; and the factorization lemma for `K` is a consequence of the realization theorem's proof, not a hypothesis of a statement.

#### 8. What the statements would look like (sketch for the planner; nothing pinned)

- `structure LadderCons (φ) (lab) (step) (pend) (R : Finset (Q × ClType φ × K)) : Prop` — `certAdm` over the idle-extended `cohBi` and the class relation `R_K`, with `certStab` per `(q, κ)`, PLUS maximality (`∀ R' ⊃ R, ¬ certAdm R'`). Decidable on the finite carrier. The `box`/`stab` clause is intrinsic to `certAdm`; no `LadderCons` without it can be written in this shape, which is the acceptance clause the record demands.
- `theorem ladderRealized … : cellAt (ladderModel step pend fwd bwd lab) φ (t, ⟨(q, c, n), h⟩) z = {T | (q, T, κ (c, n)) ∈ R}` — per ladder state, for ALL `φ`, `box`/`stab` letters included, at the Hit level (a set of types per state, never a trace). The factorization lemma `κ(c,n) = κ(c',n') → cellAt … = cellAt …` is `ladderRealized` applied twice.
- The lift (task 763) enumerates `(Q, lab, step, pend, R)` with `Fintype.card Q ≤ objBound φ` and `R ⊆ Q × ClType φ × K`, both counts; `LadderRefutes` reads a refuting type off `R`.

`hitOf (truncate B …)` stays withdrawn; `truncate` is not reintroduced. `slive` is retained, `ulive` replaced, per the 761 amendment.

### External Resources

- **Hodkinson–Wolter–Zakharyaschev 2000** (corpus entry of UNVERIFIED-summary provenance; orientation only, sources no claim): the quasimodel `⟨f, R⟩` with a periodic state function and the splice lemma is the published analogue of the counter-lift lemma. The README already records why it does not apply as published: the run set here is the path set of a fixed frame and cannot be chosen; that is precisely why the lift has to be PROVED for `Rlad` paths rather than taken.
- **Biere et al. 2006** (UNVERIFIED): "ultimately periodic" is the established adjective for the eventual-periodicity side condition; use it in the successor record rather than coining.
- No Mathlib declaration is the gap. `iterate_eventually_periodic` (pigeonhole on a finite type) is already ported into the seventeenth probe; the `Fintype`/`Finset` enumeration Finding 3 needs is standard and nothing in it is missing.

### Recommendations

1. **Adopt presentation (a) in the maximum-certified form** (§5, §8): index = the set `D`; carrier = `Q × ClType φ × K`; `LadderCons` = `certAdm` over the idle-extended `cohBi` plus maximality; `ladderRealized` = the fibre equation. Record the decision so task 761 inherits it.
2. **File the counter-lift lemma as its own research-first record, gated before any sufficiency attempt**, with a gate table of its own: gates 1, 2 and 9 (n-side, both halves), the gap-shift gate and the short-idle gate of §6, on a fixture with a product period of at least four (so the n-side windows of half-width `c + j ≤ 1` are proper). A refutation there is a complete result and closes the ladder route; a pass licenses the two theorem halves.
3. **Rebuild the relation and the certificate for the ladder before the semantic step**: extend `cohBi` across idle steps (drop the two `pend` conjuncts in favour of the `Count`/`Drift` class clauses), add `K` to the carrier, restate `certStab` per `(q, κ)`. The compiled region-interior results (`profR_*`, `realizes_of_certAdm_cohBi`, `exists_dovetail_chain`) transfer to the region segments of the extended relation and need not be re-proved.
4. **Amend the plan of record's wording** for 761 from "over `cohBi`, realizability label-level" to "over the idle-extended `cohBi` on the carrier `Q × ClType φ × K`; the label-level results are region-interior and compose only through the counter-lift lemma". The ROADMAP line that reads "the semantic step (d) is what remains of adequacy" should read "(2), (3) jointly — the counter-lift lemma — then (d)".
5. **Do not state a tuple index**, at any parameters, as a candidate; if the counter-lift lemma lands, record the factorization lemma for `K` as a corollary of `ladderRealized` with its parameters named as outputs, and update `ladder-counter-observables.md` (at its source-store path) to say that the parameter-origin rule is satisfied by construction when the parameters are the pumping lemma's own.
6. **Keep the negative branch live**: if either §6 hazard is a genuine mechanism, report `[BLOCKED]`-to-closed for the ladder route with the obstruction compiled, never a weakened same-named substitute.

## Decisions

- **D1.** Presentation (a) over (b), on the merits of §7: (b) is dominated, incomplete as a presentation (F2), and barred by the hard constraint; (a) is complete and parameter-free in its statement.
- **D2.** The counter quotient `K` is a carrier coordinate of (a), forced in shape by compiled arithmetic, with parameters that are outputs of the pumping lemma; it is NOT an index candidate and no gate is run on it as one. The entailed factorization lemma for `K` is recorded as a lemma/corollary of (a), not hidden.
- **D3.** Exactness by the maximum certified set, not by Route A; the decision record the ROADMAP asked for before entering Route A is this report, and its verdict is that Route A is unnecessary.
- **D4.** The counter-lift lemma is the named open problem on which (a)'s viability rests; it is gated before it is attempted.
- **D5.** One research-level prototype under this task's directory; nothing wired, nothing in `FormalSystem/`.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| The counter-lift lemma fails at one of the §6 hazards (a seventh mechanism) | closes the ladder route | gate first (Recommendation 2); a compiled refutation is a complete outcome; no weakened substitute |
| Finding 2 read as tuple-widening and a tuple filed as the index | contradicts the record's ruling | §4 and D2 state the distinction; Recommendation 5 forbids the statement; the index is `D` |
| The maximum-certified enumeration described as a bound | violates the no-complexity guardrail | every figure is a count of candidates; say so wherever it appears |
| `certStab` kept at fibre-over-`q` granularity | wrong `stab` bits on the ladder (F2(a)) | rebuild per `(q, κ)` (Recommendation 3) |
| The backward arm: backward-infinite pending histories exist (`gPast_isPath`) | `K` must admit `c` unbounded into the past | `K`'s `c`-side threshold class is open-ended; the lift's backward half must allow a pending-forever past at `n < c - 1` |
| Gate 8 remains SIDESTEPPED | `stab` self-reference unexercised | run the extended certificate on a fixture whose closure has a `stab` member before claiming (4) |
| Treating `realizes_of_certAdm_cohBi` as ladder realizability | a semantic step with no history to land on | Finding 1 (compiled); Recommendation 4 |

## Tactic Survey Results

No tactic survey of the obligations was performed (no Lean goal of the open problem exists yet). The prototype's three theorems record the tactics that closed them, for the port:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `count_pending_step` (`Count true true` gives `c' + 1 = c`) | `simpa [Count, hx, hy] using hc` | success | `hc := h.2.2.2` |
| `exists_idle_of_rlad_ray` (idle within `c₀ + 1`) | `by_contra` + `induction … with` + `omega` | success | derive `pend … = true` from the negated goal via `by simpa using h` (avoids `push_neg`, deprecated for `push Not`) |
| `no_rlad_ray_of_pending_forever` | `obtain` + `rw` + `Bool.noConfusion` | success | contrapositive of the above |

Axioms: `count_pending_step` `[propext]`; the other two `[propext, Quot.sound]`. No `Classical.choice`, no `native_decide`, no `sorry`.

## Context Extension Recommendations

- **Topic**: the arithmetic coupling of the ladder counters. **Gap**: `ladder-counter-observables.md` records the six mechanisms and the parameter-origin rule but not the forward window `|L - n| ≤ c + j`, the backward constraint `n ≥ c - 1`, the region-doubling inequality, or the "no pending-forever future" fact. **Recommendation**: add a "What the counters constrain" section once the derived items are compiled, at the source-store path (`agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`), never the deployed mirror.
- **Topic**: the region-interior scope of `coh`/`cohBi`. **Gap**: nothing in the context files says the certified chains are all-pending and never `Rlad` histories. **Recommendation**: one paragraph in the same file pointing at `coh`'s two `pend` conjuncts and at this task's prototype.
- **Topic**: "carrier coordinate vs index". **Gap**: the distinction in §4 is what keeps the tuple shape from being re-filed as a candidate. **Recommendation**: record it beside the parameter-origin rule.

## Appendix

- Files read in full or in their load-bearing parts: dispatch file; probes 12-21 headers (`ladder-cell-refutation`, `ladder-cell-index-obstructions`, `ladder-residue-index-refutation`, `ladder-joint-index-refutation`, `closure-indexed-periodicity`, `closure-profile-gate-rerun`, `nside-modulus-gate`, `realizable-type-adequacy-gap`, `realizable-type-certificate`, `certificate-sufficiency-dovetailing`) and the definitions `coh`, `cohBi`, `certAdm` and its six fields, `Realizes`, `Prof6`, `ProdState`, `ClType`; `RunLayer.lean:236-275`; `LadderModel.lean` whole; `AnchorLayer.lean:95-235`; README "(W): what landed and what did not"; 757 spec Sections A, C, H4; 721 "Ranking ratification"; 806 report §2, §4-6; 809 report §6-7; 815 report §7; 761 plan "Research Integration"; `ladder-counter-observables.md` whole; ROADMAP "Run these next", Stage 0, Stage 1.
- Prototype: `specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean`; compile `lake env lean specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean` (exit 0, no warnings); axiom profile confirmed by `#print axioms` on a scratch copy.
- Searches: none against Mathlib (not applicable); `grep` for `idle|Rlad|Drift|counter|ladderModel` across the set-valued probes and reports (counts in Finding 1's support: the three set-valued probes contain no `Rlad`, no `counter`, no `ladderModel`).
- Issue log: one `issue` (stale dispatch snapshot, minor), one `win` (the structural claim compiled on the second pass).
